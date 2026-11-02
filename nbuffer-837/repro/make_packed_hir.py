from pathlib import Path
import argparse
p = argparse.ArgumentParser()
p.add_argument('--tiles', type=int, default=7)
p.add_argument('--size', type=int, default=16)
p.add_argument('--output', required=True)
p.add_argument('--dynamic', action='store_true')
p.add_argument('--loop', choices=['for', 'while', 'nested'], default='for')
a = p.parse_args()
t, m = a.tiles, a.size
count, edge = m*m, m//16
s = f'''module attributes {{hacc.target = #hacc.target<"Ascend910_9382">}} {{
  func.func @_packed_tiles(%lock: memref<?xi8>, %workspace: memref<?xi8>,
      %a: memref<?xf16> {{tt.tensor_kind = 0 : i32}},
      %b: memref<?xf16> {{tt.tensor_kind = 0 : i32}},
      %out: memref<?xf16> {{tt.tensor_kind = 1 : i32}},
      %gx: i32, %gy: i32, %gz: i32, %px: i32, %py: i32, %pz: i32)
      attributes {{SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64,
                  global_kernel = "local", mix_mode = "mix", parallel_mode = "simd"}} {{
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %tiles = arith.constant {t} : index
    %size = arith.constant {m} : index
    %count = arith.constant {count} : index
    %true = arith.constant true
    %group = arith.index_cast %px : i32 to index
    %base = arith.muli %group, %tiles : index
    scf.for %i = %c0 to %tiles step %c1 {{
      %tile = arith.addi %base, %i : index
      %off = arith.muli %tile, %count : index
      %ag = memref.reinterpret_cast %a to offset: [%off], sizes: [{count}], strides: [1] : memref<?xf16> to memref<{count}xf16, strided<[1], offset: ?>>
      %bg = memref.reinterpret_cast %b to offset: [%off], sizes: [{count}], strides: [1] : memref<?xf16> to memref<{count}xf16, strided<[1], offset: ?>>
      %al = memref.alloc() : memref<{count}xf16, #hivm.address_space<cbuf>>
      %bl = memref.alloc() : memref<{count}xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%ag : memref<{count}xf16, strided<[1], offset: ?>>) outs(%al : memref<{count}xf16, #hivm.address_space<cbuf>>)
      hivm.hir.load ins(%bg : memref<{count}xf16, strided<[1], offset: ?>>) outs(%bl : memref<{count}xf16, #hivm.address_space<cbuf>>)
      %an = memref.expand_shape %al [[0, 1, 2, 3]] output_shape [{edge}, {edge}, 16, 16] : memref<{count}xf16, #hivm.address_space<cbuf>> into memref<{edge}x{edge}x16x16xf16, #hivm.address_space<cbuf>>
      %bn = memref.expand_shape %bl [[0, 1, 2, 3]] output_shape [{edge}, {edge}, 16, 16] : memref<{count}xf16, #hivm.address_space<cbuf>> into memref<{edge}x{edge}x16x16xf16, #hivm.address_space<cbuf>>
      %at = bufferization.to_tensor %an restrict writable : memref<{edge}x{edge}x16x16xf16, #hivm.address_space<cbuf>>
      %bt = bufferization.to_tensor %bn restrict writable : memref<{edge}x{edge}x16x16xf16, #hivm.address_space<cbuf>>
      %init = tensor.empty() : tensor<{edge}x{edge}x16x16xf32>
      %acc = hivm.hir.mmadL1 {{already_set_real_mkn, normalized_in_L0C, fixpipe_for_result_already_inserted = true}} ins(%at, %bt, %true, %size, %size, %size : tensor<{edge}x{edge}x16x16xf16>, tensor<{edge}x{edge}x16x16xf16>, i1, index, index, index) outs(%init : tensor<{edge}x{edge}x16x16xf32>) -> tensor<{edge}x{edge}x16x16xf32>
      %og = memref.reinterpret_cast %out to offset: [%off], sizes: [{m}, {m}], strides: [{m}, 1] : memref<?xf16> to memref<{m}x{m}xf16, strided<[{m}, 1], offset: ?>>
      hivm.hir.fixpipe {{dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>}} ins(%acc : tensor<{edge}x{edge}x16x16xf32>) outs(%og : memref<{m}x{m}xf16, strided<[{m}, 1], offset: ?>>)
    }} {{fixpipe_for_mmad_result_already_inserted = true}}
    return
  }}
}}
'''
if a.dynamic:
    s = s.replace('%gx: i32,', '%num_tiles: i32, %gx: i32,')
    s = s.replace(f'%tiles = arith.constant {t} : index', '%tiles = arith.index_cast %num_tiles : i32 to index')
if a.loop == 'while':
    s = s.replace('scf.for %i = %c0 to %tiles step %c1 {',
        '%r = scf.while (%iv = %c0) : (index) -> index {\n'
        '      %continue = arith.cmpi slt, %iv, %tiles : index\n'
        '      scf.condition(%continue) %iv : index\n'
        '    } do {\n'
        '    ^bb0(%i: index):')
    s = s.replace('    } {fixpipe_for_mmad_result_already_inserted = true}',
        '      %next = arith.addi %i, %c1 : index\n'
        '      scf.yield %next : index\n'
        '    }')
if a.loop == 'nested':
    s = s.replace('%base = arith.muli %group, %tiles : index',
        '%c2 = arith.constant 2 : index\n'
        '    %total = arith.muli %tiles, %c2 : index\n'
        '    %base = arith.muli %group, %total : index')
    s = s.replace('scf.for %i = %c0 to %tiles step %c1 {',
        'scf.for %outer = %c0 to %c2 step %c1 {\n'
        '    %outer_base = arith.muli %outer, %tiles : index\n'
        '    scf.for %i = %c0 to %tiles step %c1 {')
    s = s.replace('%tile = arith.addi %base, %i : index',
        '%relative = arith.addi %outer_base, %i : index\n'
        '      %tile = arith.addi %base, %relative : index')
    s = s.replace('    return\n', '    }\n    return\n')
Path(a.output).write_text(s)
