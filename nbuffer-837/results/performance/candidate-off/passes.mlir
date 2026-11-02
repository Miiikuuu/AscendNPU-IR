// -----// IR Dump After MarkMultiBuffer (hivm-mark-multi-buffer) //----- //
func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, mix_mode = "mix", parallel_mode = "simd"} {
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
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
      %7 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>()[%arg11, %6, %5]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>
      %alloc = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %alloc_1 = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%reinterpret_cast : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>) outs(%alloc : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.load ins(%reinterpret_cast_0 : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>) outs(%alloc_1 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %8 = bufferization.to_tensor %alloc restrict writable : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %9 = bufferization.to_tensor %alloc_1 restrict writable : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %10 = tensor.empty() : tensor<4x4x16x16xf32>
      %11 = hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%8, %9, %true, %c64, %c64, %c64 : tensor<4x4x16x16xf16>, tensor<4x4x16x16xf16>, i1, index, index, index) outs(%10 : tensor<4x4x16x16xf32>) -> tensor<4x4x16x16xf32>
      %reinterpret_cast_2 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [64, 64], strides: [64, 1] : memref<?xf16> to memref<64x64xf16, strided<[64, 1], offset: ?>>
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%11 : tensor<4x4x16x16xf32>) outs(%reinterpret_cast_2 : memref<64x64xf16, strided<[64, 1], offset: ?>>)
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  return
}

// -----// IR Dump After PlanMemory (hivm-plan-memory) //----- //
#map = affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>
module attributes {dlti.target_system_spec = #dlti.target_system_spec<"NPU" : #hacc.target_device_spec<#dlti.dl_entry<"AI_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"CUBE_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"VECTOR_CORE_COUNT", 48 : i32>, #dlti.dl_entry<"UB_SIZE", 1572864 : i32>, #dlti.dl_entry<"L1_SIZE", 4194304 : i32>, #dlti.dl_entry<"L0A_SIZE", 524288 : i32>, #dlti.dl_entry<"L0B_SIZE", 524288 : i32>, #dlti.dl_entry<"L0C_SIZE", 1048576 : i32>, #dlti.dl_entry<"UB_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L1_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L0C_ALIGN_SIZE", 4096 : i32>>>, hacc.hivmc_compatible_print = false, hacc.hivmc_version = #hacc.hivmc_version<"0.0.0">, hacc.target = #hacc.target<"Ascend910_9382">, hivm.module_core_type = #hivm.module_core_type<AIC>, memref.memref_as_ptr} {
  func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, mix_mode = "mix", parallel_mode = "simd"} {
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
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
        %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>
        %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>
        %alloc = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %alloc_1 = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%reinterpret_cast : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>) outs(%alloc : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        hivm.hir.load ins(%reinterpret_cast_0 : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>>) outs(%alloc_1 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        %8 = bufferization.to_tensor %alloc restrict writable : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %9 = bufferization.to_tensor %alloc_1 restrict writable : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %10 = tensor.empty() : tensor<4x4x16x16xf32>
        %11 = hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%8, %9, %true, %c64, %c64, %c64 : tensor<4x4x16x16xf16>, tensor<4x4x16x16xf16>, i1, index, index, index) outs(%10 : tensor<4x4x16x16xf32>) -> tensor<4x4x16x16xf32>
        %reinterpret_cast_2 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [64, 64], strides: [64, 1] : memref<?xf16> to memref<64x64xf16, strided<[64, 1], offset: ?>>
        hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%11 : tensor<4x4x16x16xf32>) outs(%reinterpret_cast_2 : memref<64x64xf16, strided<[64, 1], offset: ?>>)
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
  %c64 = arith.constant 64 : index
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
      %7 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>()[%arg11, %6, %4]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %alloc = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %alloc_1 = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_2 = memref.collapse_shape %alloc [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_2 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %collapse_shape_3 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_4 = memref.collapse_shape %alloc_1 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape_3 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_4 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %alloc_5 = memref.alloc() {alignment = 64 : i64} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%alloc, %alloc_1, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%alloc_5 : memref<4x4x16x16xf32, #hivm.address_space<cc>>)
      %reinterpret_cast_6 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%alloc_5 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_6 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  return
}

// -----// IR Dump After PlanMemory (hivm-plan-memory) //----- //
#map = affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>
module attributes {dlti.target_system_spec = #dlti.target_system_spec<"NPU" : #hacc.target_device_spec<#dlti.dl_entry<"AI_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"CUBE_CORE_COUNT", 24 : i32>, #dlti.dl_entry<"VECTOR_CORE_COUNT", 48 : i32>, #dlti.dl_entry<"UB_SIZE", 1572864 : i32>, #dlti.dl_entry<"L1_SIZE", 4194304 : i32>, #dlti.dl_entry<"L0A_SIZE", 524288 : i32>, #dlti.dl_entry<"L0B_SIZE", 524288 : i32>, #dlti.dl_entry<"L0C_SIZE", 1048576 : i32>, #dlti.dl_entry<"UB_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L1_ALIGN_SIZE", 256 : i32>, #dlti.dl_entry<"L0C_ALIGN_SIZE", 4096 : i32>>>, hacc.hivmc_compatible_print = false, hacc.hivmc_version = #hacc.hivmc_version<"0.0.0">, hacc.target = #hacc.target<"Ascend910_9382">, hivm.module_core_type = #hivm.module_core_type<AIC>, memref.memref_as_ptr} {
  func.func @_packed_tiles_infer_task_type_function() -> i8 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_task_type_function>} {
    %c20_i8 = arith.constant 20 : i8
    return %c20_i8 : i8
  }
  func.func @_packed_tiles(%arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>}, %arg1: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}, %arg2: memref<?xi8, #hivm.address_space<gm>> {hacc.arg_type = #hacc.arg_type<workspace>}, %arg3: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg4: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 0 : i32}, %arg5: memref<?xf16, #hivm.address_space<gm>> {tt.tensor_kind = 1 : i32}, %arg6: i32, %arg7: i32, %arg8: i32, %arg9: i32) attributes {SyncBlockLockArgIdx = 0 : i64, WorkspaceArgIdx = 1 : i64, func_dyn_memref_args = dense<[false, true, true, true, true, true, false, false, false, false]> : vector<10xi1>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>, hivm.storage_aligned, mix_mode = "mix", parallel_mode = "simd"} {
    %c8192_i64 = arith.constant 8192 : i64
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
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
        %7 = affine.apply #map()[%arg11, %6, %4]
        %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
        %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%7], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
        %8 = hivm.hir.pointer_cast(%c0_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %9 = hivm.hir.pointer_cast(%c8192_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape_1 = memref.collapse_shape %8 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_1 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        %collapse_shape_2 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape_3 = memref.collapse_shape %9 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%collapse_shape_2 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_3 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        %10 = hivm.hir.pointer_cast(%c0_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
        hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%8, %9, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%10 : memref<4x4x16x16xf32, #hivm.address_space<cc>>)
        %reinterpret_cast_4 = memref.reinterpret_cast %arg5 to offset: [%7], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
        hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%10 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_4 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
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
  %c1_i64 = arith.constant 1 : i64
  %c0_i64 = arith.constant 0 : i64
  %c0_i64_0 = arith.constant 0 : i64
  %c1_i64_1 = arith.constant 1 : i64
  %c8192_i64 = arith.constant 8192 : i64
  %c0_i64_2 = arith.constant 0 : i64
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
  %true = arith.constant true
  %c24_i32 = arith.constant 24 : i32
  %0 = arith.muli %arg7, %arg8 : i32
  %1 = arith.muli %0, %arg9 : i32
  annotation.mark %1 {logical_block_num} : i32
  %2 = hivm.hir.get_block_idx -> i64
  %3 = arith.trunci %2 : i64 to i32
  %4 = arith.index_cast %arg6 : i32 to index
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
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
      %c0_i64_3 = arith.constant 0 : i64
      %c1_i64_4 = arith.constant 1 : i64
      %10 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>()[%arg11, %6, %4]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%10], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_5 = memref.reinterpret_cast %arg4 to offset: [%10], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %11 = hivm.hir.pointer_cast(%c0_i64_2) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %12 = hivm.hir.pointer_cast(%c8192_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_6 = memref.collapse_shape %11 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
      hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_6 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID0>]
      %collapse_shape_7 = memref.collapse_shape %reinterpret_cast_5 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_8 = memref.collapse_shape %12 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
      hivm.hir.load ins(%collapse_shape_7 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_8 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID1>]
      %13 = hivm.hir.pointer_cast(%c0_i64_2) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
      %c-1_i64 = arith.constant -1 : i64
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%11, %12, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%13 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) sync_related_args(%c0_i64_0, %c1_i64_1, %c0_i64, %c1_i64, %9, %c0_i64_3, %c1_i64_4 : i64, i64, i64, i64, i64, i64, i64)
      hivm.hir.set_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      %reinterpret_cast_9 = memref.reinterpret_cast %arg5 to offset: [%10], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.wait_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%13 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_9 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
      hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
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
  %c1_i64 = arith.constant 1 : i64
  %c0_i64 = arith.constant 0 : i64
  %c8192_i64 = arith.constant 8192 : i64
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
  %true = arith.constant true
  %c24_i32 = arith.constant 24 : i32
  %0 = arith.muli %arg7, %arg8 : i32
  %1 = arith.muli %0, %arg9 : i32
  annotation.mark %1 {logical_block_num} : i32
  %2 = hivm.hir.get_block_idx -> i64
  %3 = arith.trunci %2 : i64 to i32
  %4 = arith.index_cast %arg6 : i32 to index
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
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
      %10 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>()[%arg11, %6, %4]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%10], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%10], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %11 = hivm.hir.pointer_cast(%c0_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %12 = hivm.hir.pointer_cast(%c8192_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_1 = memref.collapse_shape %11 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
      hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_1 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID0>]
      %collapse_shape_2 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_3 = memref.collapse_shape %12 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
      hivm.hir.load ins(%collapse_shape_2 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_3 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID1>]
      %13 = hivm.hir.pointer_cast(%c0_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%11, %12, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%13 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) sync_related_args(%c0_i64, %c1_i64, %c0_i64, %c1_i64, %9, %c0_i64, %c1_i64 : i64, i64, i64, i64, i64, i64, i64)
      hivm.hir.set_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      %reinterpret_cast_4 = memref.reinterpret_cast %arg5 to offset: [%10], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.wait_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%13 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_4 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
      hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
  hivm.hir.pipe_barrier[<PIPE_ALL>]
  return
}

bisheng: warning: the flag '--cce-aicore-input-parameter-size=1536' has been deprecated and will be ignored [-Wunused-command-line-argument]
warning: overriding the module target triple with aarch64-unknown-linux-gnu [-Woverride-module]
1 warning generated.
