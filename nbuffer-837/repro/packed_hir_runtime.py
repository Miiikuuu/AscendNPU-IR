"""Minimal loader for the packed-zN HIVM experiment's documented ABI."""
import ctypes
import hashlib
from pathlib import Path
from types import SimpleNamespace
import torch
import torch_npu  # noqa: F401
from triton.runtime import driver


def load_kernel(path, dynamic=True):
    path = Path(path)
    binary = path.read_bytes()
    callback = ctypes.CDLL(str(path.with_name('libkernel.so')))
    task_type = callback._packed_tiles_infer_task_type_function
    task_type.restype = ctypes.c_int8
    metadata = SimpleNamespace(mix_mode='mix', shared=1, debug=False,
        workspace_size=0, sync_block_lock_layout=0, bs_task_type=task_type(),
        compile_on_910_95=False, parallel_mode='simd', is_pure_simt=False,
        target=driver.active.get_current_target(), shared_mem_dynamic_size=221184,
        program_grid_mapping_applied=False, program_grid_transforms=None,
        row_coalescing_applied=False, auto_blockify_enabled=True,
        ptsm_cap_authorized=False, coalesce_factor=1, coalesce_axis=-1,
        coalesce_grid_ceil_div=False)
    signature = {0: '*fp16', 1: '*fp16', 2: '*fp16'}
    if dynamic:
        signature[3] = 'i32'
    source = SimpleNamespace(signature=signature, constants={})
    launcher = driver.active.launcher_cls(source, metadata)
    device = driver.active.get_current_device()
    module, function, *_ = driver.active.utils.load_binary('_packed_tiles', binary, 1, device, 'mix')
    packed = {'kernel_name': '_packed_tiles', 'hash': hashlib.sha256(binary).hexdigest(),
              'debug': False, 'tensor_kinds': [0, 0, 1]}

    def launch(x, y, out, tiles, groups):
        # Keep the loaded module and callback alive alongside the callable.
        _ = module, callback
        stream = driver.active.get_current_stream(device)
        args = (x, y, out, tiles) if dynamic else (x, y, out)
        launcher(groups, 1, 1, stream, function, packed, None, None, None, *args)

    return launch, {'kernel_sha256': packed['hash'], 'bs_task_type': metadata.bs_task_type}


def make_inputs(groups, tiles, size, nested=False):
    extent = max(1, tiles * (2 if nested else 1))
    shape = (groups, extent, size, size)
    gen = torch.Generator().manual_seed(837)
    x = torch.randn(shape, generator=gen, dtype=torch.float16)
    y = torch.randn(shape, generator=gen, dtype=torch.float16)
    reference = (x.float() @ y.float()).half() if tiles else torch.full(shape, 123, dtype=torch.float16)

    def pack(t):
        return t.reshape(groups, extent, size//16, 16, size//16, 16).permute(0, 1, 4, 2, 3, 5).contiguous()

    xn, yn = pack(x).npu(), pack(y).npu()
    out = torch.full(shape, 123 if not tiles else float('nan'), device='npu', dtype=torch.float16)
    return xn, yn, out, reference


def check(out, reference):
    torch.npu.synchronize()
    torch.testing.assert_close(out.cpu(), reference, rtol=1e-3, atol=1e-3)
