module attributes {hacc.target = #hacc.target<"Ascend910_9382">} {
  func.func @_packed_tiles(%lock: memref<?xi8>, %workspace: memref<?xi8>,
      %a: memref<?xf16> {tt.tensor_kind = 0 : i32},
      %b: memref<?xf16> {tt.tensor_kind = 0 : i32},
      %out: memref<?xf16> {tt.tensor_kind = 1 : i32},
      %num_tiles: i32, %gx: i32, %gy: i32, %gz: i32, %px: i32, %py: i32, %pz: i32)
      attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64,
                  global_kernel = "local", mix_mode = "mix", parallel_mode = "simd"} {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %tiles = arith.index_cast %num_tiles : i32 to index
    %size = arith.constant 16 : index
    %count = arith.constant 256 : index
    %true = arith.constant true
    %group = arith.index_cast %px : i32 to index
    %c2 = arith.constant 2 : index
    %total = arith.muli %tiles, %c2 : index
    %base = arith.muli %group, %total : index
    scf.for %outer = %c0 to %c2 step %c1 {
    %outer_base = arith.muli %outer, %tiles : index
    scf.for %i = %c0 to %tiles step %c1 {
      %relative = arith.addi %outer_base, %i : index
      %tile = arith.addi %base, %relative : index
      %off = arith.muli %tile, %count : index
      %ag = memref.reinterpret_cast %a to offset: [%off], sizes: [256], strides: [1] : memref<?xf16> to memref<256xf16, strided<[1], offset: ?>>
      %bg = memref.reinterpret_cast %b to offset: [%off], sizes: [256], strides: [1] : memref<?xf16> to memref<256xf16, strided<[1], offset: ?>>
      %al = memref.alloc() : memref<256xf16, #hivm.address_space<cbuf>>
      %bl = memref.alloc() : memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%ag : memref<256xf16, strided<[1], offset: ?>>) outs(%al : memref<256xf16, #hivm.address_space<cbuf>>)
      hivm.hir.load ins(%bg : memref<256xf16, strided<[1], offset: ?>>) outs(%bl : memref<256xf16, #hivm.address_space<cbuf>>)
      %an = memref.expand_shape %al [[0, 1, 2, 3]] output_shape [1, 1, 16, 16] : memref<256xf16, #hivm.address_space<cbuf>> into memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %bn = memref.expand_shape %bl [[0, 1, 2, 3]] output_shape [1, 1, 16, 16] : memref<256xf16, #hivm.address_space<cbuf>> into memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %at = bufferization.to_tensor %an restrict writable : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %bt = bufferization.to_tensor %bn restrict writable : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %init = tensor.empty() : tensor<1x1x16x16xf32>
      %acc = hivm.hir.mmadL1 {already_set_real_mkn, normalized_in_L0C, fixpipe_for_result_already_inserted = true} ins(%at, %bt, %true, %size, %size, %size : tensor<1x1x16x16xf16>, tensor<1x1x16x16xf16>, i1, index, index, index) outs(%init : tensor<1x1x16x16xf32>) -> tensor<1x1x16x16xf32>
      %og = memref.reinterpret_cast %out to offset: [%off], sizes: [16, 16], strides: [16, 1] : memref<?xf16> to memref<16x16xf16, strided<[16, 1], offset: ?>>
      hivm.hir.fixpipe {dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%acc : tensor<1x1x16x16xf32>) outs(%og : memref<16x16xf16, strided<[16, 1], offset: ?>>)
    } {fixpipe_for_mmad_result_already_inserted = true}
    }
    return
  }
}
