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
      annotation.mark %alloc {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %alloc_1 = memref.alloc() : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %alloc_1 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_2 = memref.collapse_shape %alloc [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_2 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %collapse_shape_3 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_4 = memref.collapse_shape %alloc_1 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.load ins(%collapse_shape_3 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_4 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      %alloc_5 = memref.alloc() {alignment = 64 : i64} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      annotation.mark %alloc_5 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
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
    %c49152_i64 = arith.constant 49152 : i64
    %c40960_i64 = arith.constant 40960 : i64
    %c32768_i64 = arith.constant 32768 : i64
    %c8192_i64 = arith.constant 8192 : i64
    %c24576_i64 = arith.constant 24576 : i64
    %c16384_i64 = arith.constant 16384 : i64
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
        %7 = hivm.hir.pointer_cast(%c0_i64, %c16384_i64, %c32768_i64, %c49152_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
        annotation.mark %7 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
        %8 = hivm.hir.pointer_cast(%c8192_i64, %c32768_i64, %c40960_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        annotation.mark %8 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %9 = hivm.hir.pointer_cast(%c0_i64, %c16384_i64, %c24576_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        annotation.mark %9 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
        %10 = affine.apply #map()[%arg11, %6, %4]
        %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%10], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
        %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%10], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape_1 = memref.collapse_shape %9 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_1 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        %collapse_shape_2 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
        %collapse_shape_3 = memref.collapse_shape %8 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
        hivm.hir.load ins(%collapse_shape_2 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_3 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
        hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%9, %8, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%7 : memref<4x4x16x16xf32, #hivm.address_space<cc>>)
        %reinterpret_cast_4 = memref.reinterpret_cast %arg5 to offset: [%10], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
        hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%7 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_4 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
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
  %c1_i64 = arith.constant 1 : i64
  %c49152_i64 = arith.constant 49152 : i64
  %c40960_i64 = arith.constant 40960 : i64
  %c32768_i64 = arith.constant 32768 : i64
  %c8192_i64 = arith.constant 8192 : i64
  %c24576_i64 = arith.constant 24576 : i64
  %c16384_i64 = arith.constant 16384 : i64
  %c0_i64_0 = arith.constant 0 : i64
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
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID2>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID3>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID4>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID5>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID1>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID2>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID3>]
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
      %c0_i64_1 = arith.constant 0 : i64
      %c1_i64_2 = arith.constant 1 : i64
      %c4_i64 = arith.constant 4 : i64
      %10 = arith.remui %7, %c4_i64 : i64
      %11 = arith.index_cast %10 : i64 to index
      %c0_i64_3 = arith.constant 0 : i64
      %c1_i64_4 = arith.constant 1 : i64
      %c1_5 = arith.constant 1 : index
      %12 = arith.cmpi eq, %11, %c1_5 : index
      %13 = arith.select %12, %c1_i64_4, %c0_i64_3 : i64
      %c2_i64 = arith.constant 2 : i64
      %c2 = arith.constant 2 : index
      %14 = arith.cmpi eq, %11, %c2 : index
      %15 = arith.select %14, %c2_i64, %13 : i64
      %c3_i64 = arith.constant 3 : i64
      %c3 = arith.constant 3 : index
      %16 = arith.cmpi eq, %11, %c3 : index
      %17 = arith.select %16, %c3_i64, %15 : i64
      %c3_i64_6 = arith.constant 3 : i64
      %18 = arith.remui %7, %c3_i64_6 : i64
      %19 = arith.index_cast %18 : i64 to index
      %c3_i64_7 = arith.constant 3 : i64
      %c4_i64_8 = arith.constant 4 : i64
      %c1_9 = arith.constant 1 : index
      %20 = arith.cmpi eq, %19, %c1_9 : index
      %21 = arith.select %20, %c4_i64_8, %c3_i64_7 : i64
      %c5_i64 = arith.constant 5 : i64
      %c2_10 = arith.constant 2 : index
      %22 = arith.cmpi eq, %19, %c2_10 : index
      %23 = arith.select %22, %c5_i64, %21 : i64
      %c0_i64_11 = arith.constant 0 : i64
      %c1_i64_12 = arith.constant 1 : i64
      %c1_13 = arith.constant 1 : index
      %24 = arith.cmpi eq, %19, %c1_13 : index
      %25 = arith.select %24, %c1_i64_12, %c0_i64_11 : i64
      %c2_i64_14 = arith.constant 2 : i64
      %c2_15 = arith.constant 2 : index
      %26 = arith.cmpi eq, %19, %c2_15 : index
      %27 = arith.select %26, %c2_i64_14, %25 : i64
      %28 = hivm.hir.pointer_cast(%c0_i64_0, %c16384_i64, %c32768_i64, %c49152_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      annotation.mark %28 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      %29 = hivm.hir.pointer_cast(%c8192_i64, %c32768_i64, %c40960_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %29 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %30 = hivm.hir.pointer_cast(%c0_i64_0, %c16384_i64, %c24576_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      annotation.mark %30 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %31 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>()[%arg11, %6, %4]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%31], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_16 = memref.reinterpret_cast %arg4 to offset: [%31], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_17 = memref.collapse_shape %30 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, %27]
      hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_17 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID0>]
      %collapse_shape_18 = memref.collapse_shape %reinterpret_cast_16 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_19 = memref.collapse_shape %29 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, %23]
      hivm.hir.load ins(%collapse_shape_18 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_19 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID1>]
      hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, %17]
      %c-1_i64 = arith.constant -1 : i64
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%30, %29, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%28 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) sync_related_args(%c0_i64, %c1_i64, %27, %23, %9, %c0_i64_1, %c1_i64_2 : i64, i64, i64, i64, i64, i64, i64)
      hivm.hir.set_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      %reinterpret_cast_20 = memref.reinterpret_cast %arg5 to offset: [%31], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.wait_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      hivm.hir.pipe_barrier[<PIPE_FIX>]
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%28 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_20 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
      hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, %17]
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID2>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID3>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID2>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID3>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID4>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID5>]
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
  %c24_i32 = arith.constant 24 : i32
  %true = arith.constant true
  %c64 = arith.constant 64 : index
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c1_i64 = arith.constant 1 : i64
  %c4_i64 = arith.constant 4 : i64
  %c2_i64 = arith.constant 2 : i64
  %c2 = arith.constant 2 : index
  %c3_i64 = arith.constant 3 : i64
  %c3 = arith.constant 3 : index
  %c5_i64 = arith.constant 5 : i64
  %c24576_i64 = arith.constant 24576 : i64
  %c40960_i64 = arith.constant 40960 : i64
  %c8192_i64 = arith.constant 8192 : i64
  %c0_i64 = arith.constant 0 : i64
  %c16384_i64 = arith.constant 16384 : i64
  %c32768_i64 = arith.constant 32768 : i64
  %c49152_i64 = arith.constant 49152 : i64
  %0 = hivm.hir.pointer_cast(%c0_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %0 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  %1 = hivm.hir.pointer_cast(%c16384_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %1 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  %2 = hivm.hir.pointer_cast(%c32768_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %2 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  %3 = hivm.hir.pointer_cast(%c49152_i64) : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  annotation.mark %3 {hivm.multi_buffer = 4 : i32} : memref<4x4x16x16xf32, #hivm.address_space<cc>>
  %4 = hivm.hir.pointer_cast(%c8192_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %4 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  %5 = hivm.hir.pointer_cast(%c32768_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %5 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  %6 = hivm.hir.pointer_cast(%c40960_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %6 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  %7 = hivm.hir.pointer_cast(%c0_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %7 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  %8 = hivm.hir.pointer_cast(%c16384_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %8 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  %9 = hivm.hir.pointer_cast(%c24576_i64) : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  annotation.mark %9 {hivm.multi_buffer = 3 : i32} : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
  %10 = arith.muli %arg7, %arg8 : i32
  %11 = arith.muli %10, %arg9 : i32
  annotation.mark %11 {logical_block_num} : i32
  %12 = hivm.hir.get_block_idx -> i64
  %13 = arith.trunci %12 : i64 to i32
  %14 = arith.index_cast %arg6 : i32 to index
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID2>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID3>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID4>]
  hivm.hir.set_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID5>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID1>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID2>]
  hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID3>]
  hivm.hir.set_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.set_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  scf.for %arg10 = %13 to %11 step %c24_i32  : i32 {
    hivm.hir.set_mask_norm
    %15 = arith.remsi %arg10, %arg7 : i32
    %16 = arith.index_cast %15 : i32 to index
    scf.for %arg11 = %c0 to %14 step %c1 {
      %17 = hivm.hir.multi_buffer_counter -> i64
      %18 = arith.remui %17, %c4_i64 : i64
      %19 = arith.index_cast %18 : i64 to index
      %20 = arith.index_cast %19 : index to i64
      %21 = arith.cmpi eq, %20, %c1_i64 : i64
      %22 = arith.select %21, %1, %0 : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      %23 = arith.cmpi eq, %20, %c2_i64 : i64
      %24 = arith.select %23, %2, %22 : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      %25 = arith.cmpi eq, %20, %c3_i64 : i64
      %26 = arith.select %25, %3, %24 : memref<4x4x16x16xf32, #hivm.address_space<cc>>
      %27 = arith.remui %17, %c3_i64 : i64
      %28 = arith.index_cast %27 : i64 to index
      %29 = arith.index_cast %28 : index to i64
      %30 = arith.cmpi eq, %29, %c1_i64 : i64
      %31 = arith.select %30, %5, %4 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %32 = arith.cmpi eq, %29, %c2_i64 : i64
      %33 = arith.select %32, %6, %31 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %34 = arith.remui %17, %c3_i64 : i64
      %35 = arith.index_cast %34 : i64 to index
      %36 = arith.index_cast %35 : index to i64
      %37 = arith.cmpi eq, %36, %c1_i64 : i64
      %38 = arith.select %37, %8, %7 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %39 = arith.cmpi eq, %36, %c2_i64 : i64
      %40 = arith.select %39, %9, %38 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>
      %41 = arith.index_cast %17 : i64 to index
      %42 = arith.index_cast %41 : index to i64
      %43 = arith.remui %17, %c4_i64 : i64
      %44 = arith.index_cast %43 : i64 to index
      %45 = arith.cmpi eq, %44, %c1 : index
      %46 = arith.select %45, %c1_i64, %c0_i64 : i64
      %47 = arith.cmpi eq, %44, %c2 : index
      %48 = arith.select %47, %c2_i64, %46 : i64
      %49 = arith.cmpi eq, %44, %c3 : index
      %50 = arith.select %49, %c3_i64, %48 : i64
      %51 = arith.remui %17, %c3_i64 : i64
      %52 = arith.index_cast %51 : i64 to index
      %53 = arith.cmpi eq, %52, %c1 : index
      %54 = arith.select %53, %c4_i64, %c3_i64 : i64
      %55 = arith.cmpi eq, %52, %c2 : index
      %56 = arith.select %55, %c5_i64, %54 : i64
      %57 = arith.cmpi eq, %52, %c1 : index
      %58 = arith.select %57, %c1_i64, %c0_i64 : i64
      %59 = arith.cmpi eq, %52, %c2 : index
      %60 = arith.select %59, %c2_i64, %58 : i64
      %61 = affine.apply affine_map<()[s0, s1, s2] -> (s0 * 4096 + (s1 * s2) * 4096)>()[%arg11, %16, %14]
      %reinterpret_cast = memref.reinterpret_cast %arg3 to offset: [%61], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %reinterpret_cast_0 = memref.reinterpret_cast %arg4 to offset: [%61], sizes: [4, 4, 16, 16], strides: [1024, 256, 16, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape = memref.collapse_shape %reinterpret_cast [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_1 = memref.collapse_shape %40 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, %60]
      hivm.hir.load ins(%collapse_shape : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_1 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID0>]
      %collapse_shape_2 = memref.collapse_shape %reinterpret_cast_0 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, strided<[1024, 256, 16, 1], offset: ?>, #hivm.address_space<gm>> into memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>
      %collapse_shape_3 = memref.collapse_shape %33 [[0, 1, 2, 3]] : memref<4x4x16x16xf16, #hivm.address_space<cbuf>> into memref<4096xf16, #hivm.address_space<cbuf>>
      hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, %56]
      hivm.hir.load ins(%collapse_shape_2 : memref<4096xf16, strided<[1], offset: ?>, #hivm.address_space<gm>>) outs(%collapse_shape_3 : memref<4096xf16, #hivm.address_space<cbuf>>) core_type = <CUBE>
      hivm.hir.set_flag[<PIPE_MTE2>, <PIPE_MTE1>, <EVENT_ID1>]
      hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, %50]
      hivm.hir.mmadL1 {already_set_real_mkn, fixpipe_for_result_already_inserted = true, normalized_in_L0C} ins(%40, %33, %true, %c64, %c64, %c64 : memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, memref<4x4x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index) outs(%26 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) sync_related_args(%c0_i64, %c1_i64, %60, %56, %42, %c0_i64, %c1_i64 : i64, i64, i64, i64, i64, i64, i64)
      hivm.hir.set_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      %reinterpret_cast_4 = memref.reinterpret_cast %arg5 to offset: [%61], sizes: [64, 64], strides: [64, 1] : memref<?xf16, #hivm.address_space<gm>> to memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>
      hivm.hir.wait_flag[<PIPE_M>, <PIPE_FIX>, <EVENT_ID0>]
      hivm.hir.pipe_barrier[<PIPE_FIX>]
      hivm.hir.fixpipe {autoblockify.dma, dma_mode = #hivm.dma_mode<nz2nd>, pre_quant = #hivm.fixpipe_pre_quant_mode<F322F16>} ins(%26 : memref<4x4x16x16xf32, #hivm.address_space<cc>>) outs(%reinterpret_cast_4 : memref<64x64xf16, strided<[64, 1], offset: ?>, #hivm.address_space<gm>>)
      hivm.hir.set_flag[<PIPE_FIX>, <PIPE_M>, %50]
    } {fixpipe_for_mmad_result_already_inserted = true}
  } {autoblockify.subloop}
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_M>, <PIPE_MTE1>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID2>]
  hivm.hir.wait_flag[<PIPE_FIX>, <PIPE_M>, <EVENT_ID3>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID0>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID1>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID2>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID3>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID4>]
  hivm.hir.wait_flag[<PIPE_MTE1>, <PIPE_MTE2>, <EVENT_ID5>]
  hivm.hir.pipe_barrier[<PIPE_ALL>]
  return
}

bisheng: warning: the flag '--cce-aicore-input-parameter-size=1536' has been deprecated and will be ignored [-Wunused-command-line-argument]
warning: overriding the module target triple with aarch64-unknown-linux-gnu [-Woverride-module]
1 warning generated.
