"""Independent output tiles exercise L1/L0C slot reuse beyond double buffering."""
from __future__ import annotations

import pytest
import torch
import torch_npu  # noqa: F401
import triton
import triton.language as tl

from src.config import DEFAULT_ASSERT_CLOSE_ATOL, DEFAULT_ASSERT_CLOSE_RTOL

pytestmark = [pytest.mark.chip_a3, pytest.mark.cube_vector]

TILE_M = 16
TILE_N = 16
TILE_K = 32
GROUPS = 8


@triton.jit
def _independent_tiles(A, B, C, TILES: tl.constexpr, BLOCK_M: tl.constexpr,
                       BLOCK_N: tl.constexpr, BLOCK_K: tl.constexpr):
    group = tl.program_id(0)
    rows = tl.arange(0, BLOCK_M)
    cols = tl.arange(0, BLOCK_N)
    reduction = tl.arange(0, BLOCK_K)
    for tile in range(TILES):
        offset = group * TILES + tile
        a = tl.load(A + offset * BLOCK_M * BLOCK_K
                    + rows[:, None] * BLOCK_K + reduction[None, :])
        b = tl.load(B + offset * BLOCK_K * BLOCK_N
                    + reduction[:, None] * BLOCK_N + cols[None, :])
        product = tl.dot(a, b)
        tl.store(C + offset * BLOCK_M * BLOCK_N
                 + rows[:, None] * BLOCK_N + cols[None, :], product)


@pytest.mark.parametrize("sync_solver", [False, True])
@pytest.mark.parametrize("l1,l0c", [(1, 1), (2, 2), (3, 3), (3, 4), (4, 3)])
@pytest.mark.parametrize("tiles", [1, 2, 3, 4, 5, 7, 9])
def test_independent_tiles(triton_npu_env, l1, l0c, tiles, sync_solver):
    # Generate on CPU so the reference does not share the NPU matmul path.
    generator = torch.Generator().manual_seed(837)
    a_cpu = torch.randn((GROUPS, tiles, TILE_M, TILE_K), generator=generator,
                        dtype=torch.float16)
    b_cpu = torch.randn((GROUPS, tiles, TILE_K, TILE_N), generator=generator,
                        dtype=torch.float16)
    expected = (a_cpu.float() @ b_cpu.float()).to(torch.float16)
    a, b = a_cpu.npu(), b_cpu.npu()
    actual = torch.full((GROUPS, tiles, TILE_M, TILE_N), float("nan"),
                        dtype=torch.float16, device="npu")
    _independent_tiles[(GROUPS,)](
        a, b, actual, TILES=tiles, BLOCK_M=TILE_M, BLOCK_N=TILE_N,
        BLOCK_K=TILE_K, multibuffer=True, sync_solver=sync_solver,
        multibuffer_mode={"gm": 1, "l1": l1, "l0c": l0c, "ub": 1})
    torch.npu.synchronize()
    torch.testing.assert_close(actual.cpu(), expected,
                               rtol=DEFAULT_ASSERT_CLOSE_RTOL,
                               atol=DEFAULT_ASSERT_CLOSE_ATOL)


@triton.jit
def _accumulated_tiles(A, B, C, TILES: tl.constexpr, PARTS: tl.constexpr,
                       BLOCK_M: tl.constexpr, BLOCK_N: tl.constexpr,
                       BLOCK_K: tl.constexpr):
    group = tl.program_id(0)
    rows = tl.arange(0, BLOCK_M)
    cols = tl.arange(0, BLOCK_N)
    reduction = tl.arange(0, BLOCK_K)
    for tile in range(TILES):
        acc = tl.full((BLOCK_M, BLOCK_N), 0, tl.float32)
        for part in range(PARTS):
            offset = (group * TILES + tile) * PARTS + part
            a = tl.load(A + offset * BLOCK_M * BLOCK_K
                        + rows[:, None] * BLOCK_K + reduction[None, :])
            b = tl.load(B + offset * BLOCK_K * BLOCK_N
                        + reduction[:, None] * BLOCK_N + cols[None, :])
            acc = tl.dot(a, b, acc)
        offset = group * TILES + tile
        tl.store(C + offset * BLOCK_M * BLOCK_N
                 + rows[:, None] * BLOCK_N + cols[None, :], acc)


@pytest.mark.parametrize("sync_solver", [False, True])
@pytest.mark.parametrize("l1,l0c", [(1, 1), (2, 2), (3, 3), (3, 4), (4, 3)])
@pytest.mark.parametrize("tiles", [1, 2, 3, 4, 5, 7, 9])
def test_accumulated_tiles(triton_npu_env, l1, l0c, tiles, sync_solver):
    # L0C must remain live across both K parts; only the outer tile rotates it.
    parts = 2
    generator = torch.Generator().manual_seed(837)
    a_cpu = torch.randn((GROUPS, tiles, parts, TILE_M, TILE_K),
                        generator=generator, dtype=torch.float16)
    b_cpu = torch.randn((GROUPS, tiles, parts, TILE_K, TILE_N),
                        generator=generator, dtype=torch.float16)
    expected = (a_cpu.float() @ b_cpu.float()).sum(dim=2).to(torch.float16)
    a, b = a_cpu.npu(), b_cpu.npu()
    actual = torch.full((GROUPS, tiles, TILE_M, TILE_N), float("nan"),
                        dtype=torch.float16, device="npu")
    _accumulated_tiles[(GROUPS,)](
        a, b, actual, TILES=tiles, PARTS=parts, BLOCK_M=TILE_M,
        BLOCK_N=TILE_N, BLOCK_K=TILE_K, multibuffer=True,
        sync_solver=sync_solver,
        multibuffer_mode={"gm": 1, "l1": l1, "l0c": l0c, "ub": 1})
    torch.npu.synchronize()
    torch.testing.assert_close(actual.cpu(), expected,
                               rtol=DEFAULT_ASSERT_CLOSE_RTOL,
                               atol=DEFAULT_ASSERT_CLOSE_ATOL)
