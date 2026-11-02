// -----// IR Dump After MarkMultiBuffer (hivm-mark-multi-buffer) //----- //
func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, mix_mode = "mix", parallel_mode = "simd"} {
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %c16 = arith.constant 16 : index
  %true = arith.constant true
  %c24_i32 = arith.constant 24 : i32
  %0 = arith.muli %arg7, %arg8 : i32
  %1 = arith.muli %0, %arg9 : i32
  annotation.mark %1 {logical_block_num} : i32
  %2 = hivm.hir.get_block_idx -> i64
  %3 = arith.trunci %2 : i64 to i32
  scf.for %arg10 = %3 to %1 step %c24_i32  : i32 {
    hivm.hir.set_mask_norm
    %4 = arith.remsi %arg10, %arg7 : i32
    %5 = arith.index_cast %arg6 : i32 to index
    %6 = arith.index_cast %4 : i32 to index
    scf.for %arg11 = %c0 to %5 step %c1 {
      %7 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 256 + (s1 * s2) * 256)>()[%arg11, %6, %5]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>
      %alloc = memref.alloc() : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %alloc_1 = memref.alloc() : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%reinterpret_cast : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>) outs(%alloc : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.load ins(%reinterpret_cast_0 : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>) outs(%alloc_1 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %8 = bufferization.to_tensor %alloc restrict writable : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %9 = bufferization.to_tensor %alloc_1 restrict writable : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %10 = tensor.empty() : tensor<1x1x16x16xf32>
      %11 = hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%8, %9, %true, %c16, %c16, %c16 : tensor<1x1x16x16xf16>, tensor<1x1x16x16xf16>, i1, index, index, index) outs(%10 : tensor<1x1x16x16xf32>) -> tensor<1x1x16x16xf32>
      %reinterpret_cast_2 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [16, 16], strides: [16, 1] : memref<?xf16> to memref<16x16xf16, strided<[16, 1], offset: ?>>
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%11 : tensor<1x1x16x16xf32>) outs(%reinterpret_cast_2 : memref<16x16xf16, strided<[16, 1], offset: ?>>)
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  return
}

// -----// IR Dump After PlanMemory (hivm-plan-memory) //----- //
#map = affine_map<()[s0, s1, s2] -> (s0 * 256 + (s1 * s2) * 256)>
module attributes {dlti.target_system_spec = #dlti.target_system_spec<"NPU" : #hacc.target_device_spec<#dlti.dl_entry<"AI_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"CUBE_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"VECTOR_CORE_COUNT", 48 : i32>, #dlti.dl_entry<"UB_SIZE", 1572864 : i32>, #dlti.dl_entry<"L1_SIZE", 4194304 : i32>, #dlti.dl_entry<"L0A_SIZE", 524288 : i32>, #dlti.dl_entry<"L0B_SIZE", 524288 : i32>, #dlti.dl_entry<"L0C_SIZE", 1048576 : i32>, #dlti.dl_entry<"UB_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L1_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L0C_ALIGN_SIZE", 4096 : i32>>>, hacc.hivmc_compatible_print = false, hacc.hivmc_version = #hacc.hivmc_version<"0.0.0">, hacc.target = #hacc.target<"Ascend910_9382">, hivm.module_core_type = #hivm.module_core_type<AIC>, memref.memref_as_ptr} {
  func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, mix_mode = "mix", parallel_mode = "simd"} {
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c16 = arith.constant 16 : index
    %true = arith.constant true
    %c24_i32 = arith.constant 24 : i32
    %0 = arith.muli %arg7, %arg8 : i32
    %1 = arith.muli %0, %arg9 : i32
    annotation.mark %1 {logical_block_num} : i32
    %2 = hivm.hir.get_block_idx -> i64
    %3 = arith.trunci %2 : i64 to i32
    scf.for %arg10 = %3 to %1 step %c24_i32  : i32 {
      hivm.hir.set_mask_norm
      %4 = arith.remsi %arg10, %arg7 : i32
      %5 = arith.index_cast %arg6 : i32 to index
      %6 = arith.index_cast %4 : i32 to index
      scf.for %arg11 = %c0 to %5 step %c1 {
        %7 = affine.apply #map()[%arg11, %6, %5]
        %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>
        %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>
        %alloc = memref.alloc() : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        %alloc_1 = memref.alloc() : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%reinterpret_cast : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>) outs(%alloc : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        hivm.hir.load ins(%reinterpret_cast_0 : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>>) outs(%alloc_1 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        %8 = bufferization.to_tensor %alloc restrict writable : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        %9 = bufferization.to_tensor %alloc_1 restrict writable : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        %10 = tensor.empty() : tensor<1x1x16x16xf32>
        %11 = hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%8, %9, %true, %c16, %c16, %c16 : tensor<1x1x16x16xf16>, tensor<1x1x16x16xf16>, i1, index, index, index) outs(%10 : tensor<1x1x16x16xf32>) -> tensor<1x1x16x16xf32>
        %reinterpret_cast_2 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [16, 16], strides: [16, 1] : memref<?xf16> to memref<16x16xf16, strided<[16, 1], offset: ?>>
        hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%11 : tensor<1x1x16x16xf32>) outs(%reinterpret_cast_2 : memref<16x16xf16, strided<[16, 1], offset: ?>>)
      } {fixpipe_for_mmad_result_already_inserted = true}
    } {autoblockify.subloop}
    return
  }
}


// -----// IR Dump After MarkMultiBuffer (hivm-mark-multi-buffer) //----- //
func.func @_packed_tiles_infer_task_type_function() -> i8 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_task_type_function>} {
  %c20_i8 = arith.constant 20 : i8
  return %c20_i8 : i8
}

// -----// IR Dump After MarkMultiBuffer (hivm-mark-multi-buffer) //----- //
func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, hivm.storage_aligned, mix_mode = "mix", parallel_mode = "simd"} {
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %c16 = arith.constant 16 : index
  %true = arith.constant true
  %c24_i32 = arith.constant 24 : i32
  %0 = arith.muli %arg7, %arg8 : i32
  %1 = arith.muli %0, %arg9 : i32
  annotation.mark %1 {logical_block_num} : i32
  %2 = hivm.hir.get_block_idx -> i64
  %3 = arith.trunci %2 : i64 to i32
  %4 = arith.index_cast %arg6 : i32 to index
  scf.for %arg10 = %3 to %1 step %c24_i32  : i32 {
    hivm.hir.set_mask_norm
    %5 = arith.remsi %arg10, %arg7 : i32
    %6 = arith.index_cast %5 : i32 to index
    scf.for %arg11 = %c0 to %4 step %c1 {
      %7 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 256 + (s1 * s2) * 256)>()[%arg11, %6, %4]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %alloc = memref.alloc() : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %alloc {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %alloc_1 = memref.alloc() : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %alloc_1 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_2 = memref.collapse_shape %alloc [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_2 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %collapse_shape_3 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_4 = memref.collapse_shape %alloc_1 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape_3 : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_4 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %alloc_5 = memref.alloc() {alignment = 64 : i64} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      annotation.mark %alloc_5 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%alloc, %alloc_1, %true, %c16, %c16, %c16 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%alloc_5 : memref<1x1x16x16xf32, #hivm.address_space<cc>>)
      %reinterpret_cast_6 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [16, 16], strides: [16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%alloc_5 : memref<1x1x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_6 : memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>)
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  return
}

// -----// IR Dump After PlanMemory (hivm-plan-memory) //----- //
#map = affine_map<()[s0, s1, s2] -> (s0 * 256 + (s1 * s2) * 256)>
module attributes {dlti.target_system_spec = #dlti.target_system_spec<"NPU" : #hacc.target_device_spec<#dlti.dl_entry<"AI_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"CUBE_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"VECTOR_CORE_COUNT", 48 : i32>, #dlti.dl_entry<"UB_SIZE", 1572864 : i32>, #dlti.dl_entry<"L1_SIZE", 4194304 : i32>, #dlti.dl_entry<"L0A_SIZE", 524288 : i32>, #dlti.dl_entry<"L0B_SIZE", 524288 : i32>, #dlti.dl_entry<"L0C_SIZE", 1048576 : i32>, #dlti.dl_entry<"UB_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L1_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L0C_ALIGN_SIZE", 4096 : i32>>>, hacc.hivmc_compatible_print = false, hacc.hivmc_version = #hacc.hivmc_version<"0.0.0">, hacc.target = #hacc.target<"Ascend910_9382">, hivm.module_core_type = #hivm.module_core_type<AIC>, memref.memref_as_ptr} {
  func.func @_packed_tiles_infer_task_type_function() -> i8 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_task_type_function>} {
    %c20_i8 = arith.constant 20 : i8
    return %c20_i8 : i8
  }
  func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, hivm.storage_aligned, mix_mode = "mix", parallel_mode = "simd"} {
    %c15872_i64 = arith.constant 15872 : i64
    %c15360_i64 = arith.constant 15360 : i64
    %c14848_i64 = arith.constant 14848 : i64
    %c14336_i64 = arith.constant 14336 : i64
    %c13824_i64 = arith.constant 13824 : i64
    %c13312_i64 = arith.constant 13312 : i64
    %c12800_i64 = arith.constant 12800 : i64
    %c12288_i64 = arith.constant 12288 : i64
    %c11776_i64 = arith.constant 11776 : i64
    %c11264_i64 = arith.constant 11264 : i64
    %c10752_i64 = arith.constant 10752 : i64
    %c10240_i64 = arith.constant 10240 : i64
    %c9728_i64 = arith.constant 9728 : i64
    %c9216_i64 = arith.constant 9216 : i64
    %c8704_i64 = arith.constant 8704 : i64
    %c512_i64 = arith.constant 512 : i64
    %c8192_i64 = arith.constant 8192 : i64
    %c7680_i64 = arith.constant 7680 : i64
    %c7168_i64 = arith.constant 7168 : i64
    %c6656_i64 = arith.constant 6656 : i64
    %c6144_i64 = arith.constant 6144 : i64
    %c5632_i64 = arith.constant 5632 : i64
    %c5120_i64 = arith.constant 5120 : i64
    %c4608_i64 = arith.constant 4608 : i64
    %c4096_i64 = arith.constant 4096 : i64
    %c3584_i64 = arith.constant 3584 : i64
    %c3072_i64 = arith.constant 3072 : i64
    %c2560_i64 = arith.constant 2560 : i64
    %c2048_i64 = arith.constant 2048 : i64
    %c1536_i64 = arith.constant 1536 : i64
    %c1024_i64 = arith.constant 1024 : i64
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c16 = arith.constant 16 : index
    %true = arith.constant true
    %c24_i32 = arith.constant 24 : i32
    %0 = arith.muli %arg7, %arg8 : i32
    %1 = arith.muli %0, %arg9 : i32
    annotation.mark %1 {logical_block_num} : i32
    %2 = hivm.hir.get_block_idx -> i64
    %3 = arith.trunci %2 : i64 to i32
    %4 = arith.index_cast %arg6 : i32 to index
    scf.for %arg10 = %3 to %1 step %c24_i32  : i32 {
      hivm.hir.set_mask_norm
      %5 = arith.remsi %arg10, %arg7 : i32
      %6 = arith.index_cast %5 : i32 to index
      scf.for %arg11 = %c0 to %4 step %c1 {
        %7 = hivm.hir.pointer_cast(%c0_i64, %c1024_i64, %c2048_i64, %c3072_i64, %c4096_i64, %c5120_i64, %c6144_i64, %c7168_i64, %c8192_i64, %c9216_i64, %c10240_i64, %c11264_i64, %c12288_i64, %c13312_i64, %c14336_i64, %c15360_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
        annotation.mark %7 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
        %8 = hivm.hir.pointer_cast(%c512_i64, %c8704_i64, %c9216_i64, %c9728_i64, %c10240_i64, %c10752_i64, %c11264_i64, %c11776_i64, %c12288_i64, %c12800_i64, %c13312_i64, %c13824_i64, %c14336_i64, %c14848_i64, %c15360_i64, %c15872_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        annotation.mark %8 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        %9 = hivm.hir.pointer_cast(%c0_i64, %c1024_i64, %c1536_i64, %c2048_i64, %c2560_i64, %c3072_i64, %c3584_i64, %c4096_i64, %c4608_i64, %c5120_i64, %c5632_i64, %c6144_i64, %c6656_i64, %c7168_i64, %c7680_i64, %c8192_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        annotation.mark %9 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
        %10 = affine.apply #map()[%arg11, %6, %4]
        %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%10], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
        %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%10], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape_1 = memref.collapse_shape %9 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%collapse_shape : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_1 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        %collapse_shape_2 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape_3 = memref.collapse_shape %8 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%collapse_shape_2 : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_3 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%9, %8, %true, %c16, %c16, %c16 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%7 : memref<1x1x16x16xf32, #hivm.address_space<cc>>)
        %reinterpret_cast_4 = memref.reinterpret_cast %arg5 to offset: [%10], sizes: [16, 16], strides: [16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>
        hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%7 : memref<1x1x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_4 : memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>)
      } {fixpipe_for_mmad_result_already_inserted = true}
    } {autoblockify.subloop}
    return
  }
}


// -----// IR Dump After GraphSyncSolver (hivm-graph-sync-solver) //----- //
func.func @_packed_tiles_infer_task_type_function() -> i8 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_task_type_function>} {
  %c20_i8 = arith.constant 20 : i8
  return %c20_i8 : i8
}

// -----// IR Dump After GraphSyncSolver (hivm-graph-sync-solver) //----- //
func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, hivm.storage_aligned, mix_mode = "mix", parallel_mode = "simd"} {
  %c0_i64 = arith.constant 0 : i64
  %c0_i64_0 = arith.constant 0 : i64
  %c1_i64 = arith.constant 1 : i64
  %c15872_i64 = arith.constant 15872 : i64
  %c15360_i64 = arith.constant 15360 : i64
  %c14848_i64 = arith.constant 14848 : i64
  %c14336_i64 = arith.constant 14336 : i64
  %c13824_i64 = arith.constant 13824 : i64
  %c13312_i64 = arith.constant 13312 : i64
  %c12800_i64 = arith.constant 12800 : i64
  %c12288_i64 = arith.constant 12288 : i64
  %c11776_i64 = arith.constant 11776 : i64
  %c11264_i64 = arith.constant 11264 : i64
  %c10752_i64 = arith.constant 10752 : i64
  %c10240_i64 = arith.constant 10240 : i64
  %c9728_i64 = arith.constant 9728 : i64
  %c9216_i64 = arith.constant 9216 : i64
  %c8704_i64 = arith.constant 8704 : i64
  %c512_i64 = arith.constant 512 : i64
  %c8192_i64 = arith.constant 8192 : i64
  %c7680_i64 = arith.constant 7680 : i64
  %c7168_i64 = arith.constant 7168 : i64
  %c6656_i64 = arith.constant 6656 : i64
  %c6144_i64 = arith.constant 6144 : i64
  %c5632_i64 = arith.constant 5632 : i64
  %c5120_i64 = arith.constant 5120 : i64
  %c4608_i64 = arith.constant 4608 : i64
  %c4096_i64 = arith.constant 4096 : i64
  %c3584_i64 = arith.constant 3584 : i64
  %c3072_i64 = arith.constant 3072 : i64
  %c2560_i64 = arith.constant 2560 : i64
  %c2048_i64 = arith.constant 2048 : i64
  %c1536_i64 = arith.constant 1536 : i64
  %c1024_i64 = arith.constant 1024 : i64
  %c0_i64_1 = arith.constant 0 : i64
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %c16 = arith.constant 16 : index
  %true = arith.constant true
  %c24_i32 = arith.constant 24 : i32
  %0 = arith.muli %arg7, %arg8 : i32
  %1 = arith.muli %0, %arg9 : i32
  annotation.mark %1 {logical_block_num} : i32
  %2 = hivm.hir.get_block_idx -> i64
  %3 = arith.trunci %2 : i64 to i32
  %4 = arith.index_cast %arg6 : i32 to index
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  scf.for %arg10 = %3 to %1 step %c24_i32  : i32 {
    hivm.hir.set_mask_norm
    %5 = arith.remsi %arg10, %arg7 : i32
    %6 = arith.index_cast %5 : i32 to index
    scf.for %arg11 = %c0 to %4 step %c1 {
      %7 = hivm.hir.multi_buffer_counter -> i64
      %8 = arith.index_cast %7 : i64 to index
      %9 = arith.index_cast %8 : index to i64
      %c0_i64_2 = arith.constant 0 : i64
      %c1_i64_3 = arith.constant 1 : i64
      %10 = hivm.hir.pointer_cast(%c0_i64_1, %c1024_i64, %c2048_i64, %c3072_i64, %c4096_i64, %c5120_i64, %c6144_i64, %c7168_i64, %c8192_i64, %c9216_i64, %c10240_i64, %c11264_i64, %c12288_i64, %c13312_i64, %c14336_i64, %c15360_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      annotation.mark %10 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %11 = hivm.hir.pointer_cast(%c512_i64, %c8704_i64, %c9216_i64, %c9728_i64, %c10240_i64, %c10752_i64, %c11264_i64, %c11776_i64, %c12288_i64, %c12800_i64, %c13312_i64, %c13824_i64, %c14336_i64, %c14848_i64, %c15360_i64, %c15872_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %11 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %12 = hivm.hir.pointer_cast(%c0_i64_1, %c1024_i64, %c1536_i64, %c2048_i64, %c2560_i64, %c3072_i64, %c3584_i64, %c4096_i64, %c4608_i64, %c5120_i64, %c5632_i64, %c6144_i64, %c6656_i64, %c7168_i64, %c7680_i64, %c8192_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %12 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %13 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 256 + (s1 * s2) * 256)>()[%arg11, %6, %4]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%13], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_4 = memref.reinterpret_cast %arg4 to offset: [%13], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_5 = memref.collapse_shape %12 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
      hivm.hir.load ins(%collapse_shape : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_5 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID0>]
      %collapse_shape_6 = memref.collapse_shape %reinterpret_cast_4 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_7 = memref.collapse_shape %11 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape_6 : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_7 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID1>]
      hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
      %c-1_i64 = arith.constant -1 : i64
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%12, %11, %true, %c16, %c16, %c16 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%10 : memref<1x1x16x16xf32, #hivm.address_space<cc>>) sync_related_args(%c0_i64_0, %c1_i64, %c-1_i64, %c0_i64, %9, %c0_i64_2, %c1_i64_3 : i64, i64, i64, i64, i64, i64, i64)
      hivm.hir.set_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      %reinterpret_cast_8 = memref.reinterpret_cast %arg5 to offset: [%13], sizes: [16, 16], strides: [16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.wait_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%10 : memref<1x1x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_8 : memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>)
      hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.pipe_barrier[<PIPE_ALL>]
  return
}

// -----// IR Dump After EnableMultiBuffer (hivm-enable-multi-buffer) //----- //
func.func @_packed_tiles_infer_task_type_function() -> i8 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_task_type_function>} {
  %c20_i8 = arith.constant 20 : i8
  return %c20_i8 : i8
}

// -----// IR Dump After EnableMultiBuffer (hivm-enable-multi-buffer) //----- //
func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, hivm.storage_aligned, mix_mode = "mix", parallel_mode = "simd"} {
  %c15_i64 = arith.constant 15 : i64
  %c14_i64 = arith.constant 14 : i64
  %c13_i64 = arith.constant 13 : i64
  %c12_i64 = arith.constant 12 : i64
  %c11_i64 = arith.constant 11 : i64
  %c10_i64 = arith.constant 10 : i64
  %c9_i64 = arith.constant 9 : i64
  %c8_i64 = arith.constant 8 : i64
  %c7_i64 = arith.constant 7 : i64
  %c6_i64 = arith.constant 6 : i64
  %c5_i64 = arith.constant 5 : i64
  %c4_i64 = arith.constant 4 : i64
  %c3_i64 = arith.constant 3 : i64
  %c2_i64 = arith.constant 2 : i64
  %c16_i64 = arith.constant 16 : i64
  %c24_i32 = arith.constant 24 : i32
  %true = arith.constant true
  %c16 = arith.constant 16 : index
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c1_i64 = arith.constant 1 : i64
  %c-1_i64 = arith.constant -1 : i64
  %c7680_i64 = arith.constant 7680 : i64
  %c6656_i64 = arith.constant 6656 : i64
  %c5632_i64 = arith.constant 5632 : i64
  %c4608_i64 = arith.constant 4608 : i64
  %c3584_i64 = arith.constant 3584 : i64
  %c2560_i64 = arith.constant 2560 : i64
  %c1536_i64 = arith.constant 1536 : i64
  %c15872_i64 = arith.constant 15872 : i64
  %c14848_i64 = arith.constant 14848 : i64
  %c13824_i64 = arith.constant 13824 : i64
  %c12800_i64 = arith.constant 12800 : i64
  %c11776_i64 = arith.constant 11776 : i64
  %c10752_i64 = arith.constant 10752 : i64
  %c9728_i64 = arith.constant 9728 : i64
  %c8704_i64 = arith.constant 8704 : i64
  %c512_i64 = arith.constant 512 : i64
  %c0_i64 = arith.constant 0 : i64
  %c1024_i64 = arith.constant 1024 : i64
  %c2048_i64 = arith.constant 2048 : i64
  %c3072_i64 = arith.constant 3072 : i64
  %c4096_i64 = arith.constant 4096 : i64
  %c5120_i64 = arith.constant 5120 : i64
  %c6144_i64 = arith.constant 6144 : i64
  %c7168_i64 = arith.constant 7168 : i64
  %c8192_i64 = arith.constant 8192 : i64
  %c9216_i64 = arith.constant 9216 : i64
  %c10240_i64 = arith.constant 10240 : i64
  %c11264_i64 = arith.constant 11264 : i64
  %c12288_i64 = arith.constant 12288 : i64
  %c13312_i64 = arith.constant 13312 : i64
  %c14336_i64 = arith.constant 14336 : i64
  %c15360_i64 = arith.constant 15360 : i64
  %0 = hivm.hir.pointer_cast(%c0_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %0 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %1 = hivm.hir.pointer_cast(%c1024_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %1 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %2 = hivm.hir.pointer_cast(%c2048_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %2 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %3 = hivm.hir.pointer_cast(%c3072_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %3 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %4 = hivm.hir.pointer_cast(%c4096_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %4 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %5 = hivm.hir.pointer_cast(%c5120_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %5 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %6 = hivm.hir.pointer_cast(%c6144_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %6 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %7 = hivm.hir.pointer_cast(%c7168_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %7 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %8 = hivm.hir.pointer_cast(%c8192_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %8 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %9 = hivm.hir.pointer_cast(%c9216_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %9 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %10 = hivm.hir.pointer_cast(%c10240_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %10 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %11 = hivm.hir.pointer_cast(%c11264_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %11 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %12 = hivm.hir.pointer_cast(%c12288_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %12 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %13 = hivm.hir.pointer_cast(%c13312_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %13 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %14 = hivm.hir.pointer_cast(%c14336_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %14 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %15 = hivm.hir.pointer_cast(%c15360_i64) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %15 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf32, #hivm.address_space<cc>>
  %16 = hivm.hir.pointer_cast(%c512_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %16 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %17 = hivm.hir.pointer_cast(%c8704_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %17 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %18 = hivm.hir.pointer_cast(%c9216_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %18 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %19 = hivm.hir.pointer_cast(%c9728_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %19 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %20 = hivm.hir.pointer_cast(%c10240_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %20 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %21 = hivm.hir.pointer_cast(%c10752_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %21 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %22 = hivm.hir.pointer_cast(%c11264_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %22 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %23 = hivm.hir.pointer_cast(%c11776_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %23 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %24 = hivm.hir.pointer_cast(%c12288_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %24 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %25 = hivm.hir.pointer_cast(%c12800_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %25 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %26 = hivm.hir.pointer_cast(%c13312_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %26 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %27 = hivm.hir.pointer_cast(%c13824_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %27 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %28 = hivm.hir.pointer_cast(%c14336_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %28 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %29 = hivm.hir.pointer_cast(%c14848_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %29 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %30 = hivm.hir.pointer_cast(%c15360_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %30 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %31 = hivm.hir.pointer_cast(%c15872_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %31 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %32 = hivm.hir.pointer_cast(%c0_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %32 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %33 = hivm.hir.pointer_cast(%c1024_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %33 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %34 = hivm.hir.pointer_cast(%c1536_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %34 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %35 = hivm.hir.pointer_cast(%c2048_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %35 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %36 = hivm.hir.pointer_cast(%c2560_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %36 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %37 = hivm.hir.pointer_cast(%c3072_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %37 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %38 = hivm.hir.pointer_cast(%c3584_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %38 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %39 = hivm.hir.pointer_cast(%c4096_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %39 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %40 = hivm.hir.pointer_cast(%c4608_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %40 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %41 = hivm.hir.pointer_cast(%c5120_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %41 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %42 = hivm.hir.pointer_cast(%c5632_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %42 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %43 = hivm.hir.pointer_cast(%c6144_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %43 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %44 = hivm.hir.pointer_cast(%c6656_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %44 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %45 = hivm.hir.pointer_cast(%c7168_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %45 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %46 = hivm.hir.pointer_cast(%c7680_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %46 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %47 = hivm.hir.pointer_cast(%c8192_i64) : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %47 {hivm.multi_buffer = 16 : i32} : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
  %48 = arith.muli %arg7, %arg8 : i32
  %49 = arith.muli %48, %arg9 : i32
  annotation.mark %49 {logical_block_num} : i32
  %50 = hivm.hir.get_block_idx -> i64
  %51 = arith.trunci %50 : i64 to i32
  %52 = arith.index_cast %arg6 : i32 to index
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  scf.for %arg10 = %51 to %49 step %c24_i32  : i32 {
    hivm.hir.set_mask_norm
    %53 = arith.remsi %arg10, %arg7 : i32
    %54 = arith.index_cast %53 : i32 to index
    scf.for %arg11 = %c0 to %52 step %c1 {
      %55 = hivm.hir.multi_buffer_counter -> i64
      %56 = arith.remui %55, %c16_i64 : i64
      %57 = arith.index_cast %56 : i64 to index
      %58 = arith.index_cast %57 : index to i64
      %59 = arith.cmpi eq, %58, %c1_i64 : i64
      %60 = arith.select %59, %1, %0 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %61 = arith.cmpi eq, %58, %c2_i64 : i64
      %62 = arith.select %61, %2, %60 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %63 = arith.cmpi eq, %58, %c3_i64 : i64
      %64 = arith.select %63, %3, %62 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %65 = arith.cmpi eq, %58, %c4_i64 : i64
      %66 = arith.select %65, %4, %64 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %67 = arith.cmpi eq, %58, %c5_i64 : i64
      %68 = arith.select %67, %5, %66 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %69 = arith.cmpi eq, %58, %c6_i64 : i64
      %70 = arith.select %69, %6, %68 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %71 = arith.cmpi eq, %58, %c7_i64 : i64
      %72 = arith.select %71, %7, %70 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %73 = arith.cmpi eq, %58, %c8_i64 : i64
      %74 = arith.select %73, %8, %72 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %75 = arith.cmpi eq, %58, %c9_i64 : i64
      %76 = arith.select %75, %9, %74 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %77 = arith.cmpi eq, %58, %c10_i64 : i64
      %78 = arith.select %77, %10, %76 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %79 = arith.cmpi eq, %58, %c11_i64 : i64
      %80 = arith.select %79, %11, %78 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %81 = arith.cmpi eq, %58, %c12_i64 : i64
      %82 = arith.select %81, %12, %80 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %83 = arith.cmpi eq, %58, %c13_i64 : i64
      %84 = arith.select %83, %13, %82 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %85 = arith.cmpi eq, %58, %c14_i64 : i64
      %86 = arith.select %85, %14, %84 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %87 = arith.cmpi eq, %58, %c15_i64 : i64
      %88 = arith.select %87, %15, %86 : memref<1x1x16x16xf32, #hivm.address_space<cc>>
      %89 = arith.remui %55, %c16_i64 : i64
      %90 = arith.index_cast %89 : i64 to index
      %91 = arith.index_cast %90 : index to i64
      %92 = arith.cmpi eq, %91, %c1_i64 : i64
      %93 = arith.select %92, %17, %16 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %94 = arith.cmpi eq, %91, %c2_i64 : i64
      %95 = arith.select %94, %18, %93 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %96 = arith.cmpi eq, %91, %c3_i64 : i64
      %97 = arith.select %96, %19, %95 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %98 = arith.cmpi eq, %91, %c4_i64 : i64
      %99 = arith.select %98, %20, %97 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %100 = arith.cmpi eq, %91, %c5_i64 : i64
      %101 = arith.select %100, %21, %99 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %102 = arith.cmpi eq, %91, %c6_i64 : i64
      %103 = arith.select %102, %22, %101 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %104 = arith.cmpi eq, %91, %c7_i64 : i64
      %105 = arith.select %104, %23, %103 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %106 = arith.cmpi eq, %91, %c8_i64 : i64
      %107 = arith.select %106, %24, %105 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %108 = arith.cmpi eq, %91, %c9_i64 : i64
      %109 = arith.select %108, %25, %107 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %110 = arith.cmpi eq, %91, %c10_i64 : i64
      %111 = arith.select %110, %26, %109 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %112 = arith.cmpi eq, %91, %c11_i64 : i64
      %113 = arith.select %112, %27, %111 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %114 = arith.cmpi eq, %91, %c12_i64 : i64
      %115 = arith.select %114, %28, %113 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %116 = arith.cmpi eq, %91, %c13_i64 : i64
      %117 = arith.select %116, %29, %115 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %118 = arith.cmpi eq, %91, %c14_i64 : i64
      %119 = arith.select %118, %30, %117 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %120 = arith.cmpi eq, %91, %c15_i64 : i64
      %121 = arith.select %120, %31, %119 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %122 = arith.remui %55, %c16_i64 : i64
      %123 = arith.index_cast %122 : i64 to index
      %124 = arith.index_cast %123 : index to i64
      %125 = arith.cmpi eq, %124, %c1_i64 : i64
      %126 = arith.select %125, %33, %32 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %127 = arith.cmpi eq, %124, %c2_i64 : i64
      %128 = arith.select %127, %34, %126 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %129 = arith.cmpi eq, %124, %c3_i64 : i64
      %130 = arith.select %129, %35, %128 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %131 = arith.cmpi eq, %124, %c4_i64 : i64
      %132 = arith.select %131, %36, %130 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %133 = arith.cmpi eq, %124, %c5_i64 : i64
      %134 = arith.select %133, %37, %132 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %135 = arith.cmpi eq, %124, %c6_i64 : i64
      %136 = arith.select %135, %38, %134 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %137 = arith.cmpi eq, %124, %c7_i64 : i64
      %138 = arith.select %137, %39, %136 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %139 = arith.cmpi eq, %124, %c8_i64 : i64
      %140 = arith.select %139, %40, %138 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %141 = arith.cmpi eq, %124, %c9_i64 : i64
      %142 = arith.select %141, %41, %140 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %143 = arith.cmpi eq, %124, %c10_i64 : i64
      %144 = arith.select %143, %42, %142 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %145 = arith.cmpi eq, %124, %c11_i64 : i64
      %146 = arith.select %145, %43, %144 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %147 = arith.cmpi eq, %124, %c12_i64 : i64
      %148 = arith.select %147, %44, %146 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %149 = arith.cmpi eq, %124, %c13_i64 : i64
      %150 = arith.select %149, %45, %148 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %151 = arith.cmpi eq, %124, %c14_i64 : i64
      %152 = arith.select %151, %46, %150 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %153 = arith.cmpi eq, %124, %c15_i64 : i64
      %154 = arith.select %153, %47, %152 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
      %155 = arith.index_cast %55 : i64 to index
      %156 = arith.index_cast %155 : index to i64
      %157 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 256 + (s1 * s2) * 256)>()[%arg11, %54, %52]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%157], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%157], sizes: [1, 1, 16, 16], strides: [256, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_1 = memref.collapse_shape %154 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
      hivm.hir.load ins(%collapse_shape : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_1 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID0>]
      %collapse_shape_2 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, strided<[256, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_3 = memref.collapse_shape %121 [[0, 1, 2, 3]] : memref<1x1x16x16xf16, #hivm.address_space<cbuf>> into memref<256xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape_2 : memref<256xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_3 : memref<256xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID1>]
      hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%154, %121, %true, %c16, %c16, %c16 : memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%88 : memref<1x1x16x16xf32, #hivm.address_space<cc>>) sync_related_args(%c0_i64, %c1_i64, %c-1_i64, %c0_i64, %156, %c0_i64, %c1_i64 : i64, i64, i64, i64, i64, i64, i64)
      hivm.hir.set_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      %reinterpret_cast_4 = memref.reinterpret_cast %arg5 to offset: [%157], sizes: [16, 16], strides: [16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.wait_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%88 : memref<1x1x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_4 : memref<16x16xf16, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>)
      hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.pipe_barrier[<PIPE_ALL>]
  return
}

bisheng: warning: the flag '--cce-aicore-input-parameter-size=1536' has been deprecated and will be ignored [-Wunused-command-line-argument]
warning: overriding the module target triple with aarch64-unknown-linux-gnu [-Woverride-module]
1 warning generated.
