// RUN: bishengir-opt %s -pass-pipeline='builtin.module(hacc-append-device-spec{target=Ascend910B1},func.func(hivm-mark-multi-buffer{enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]}),hivm-plan-memory)' | FileCheck %s --check-prefix=PLAN
// RUN: bishengir-opt %s -pass-pipeline='builtin.module(hacc-append-device-spec{target=Ascend910B1},func.func(hivm-mark-multi-buffer{enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]}),hivm-plan-memory,func.func(hivm-graph-sync-solver{solver-version=v1},hivm-enable-multi-buffer,hivm-lower-multi-buffer-counter))' | FileCheck %s --check-prefix=ROTATE
// RUN: bishengir-opt %s -pass-pipeline='builtin.module(hacc-append-device-spec{target=Ascend910B1},func.func(hivm-mark-multi-buffer{enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]}),hivm-plan-memory,func.func(hivm-graph-sync-solver{solver-version=v2},hivm-enable-multi-buffer,hivm-lower-multi-buffer-counter))' | FileCheck %s --check-prefix=ROTATE
// RUN: bishengir-opt %s -pass-pipeline='builtin.module(hacc-append-device-spec{target=Ascend910B1},func.func(hivm-mark-multi-buffer{enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]}),hivm-plan-memory-regbase)' | FileCheck %s --check-prefix=PLAN
// RUN: bishengir-opt %s -pass-pipeline='builtin.module(hacc-append-device-spec{target=Ascend910B1},func.func(hivm-mark-multi-buffer{enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]}),hivm-plan-memory-regbase,func.func(hivm-graph-sync-solver{solver-version=v1},hivm-enable-multi-buffer,hivm-lower-multi-buffer-counter))' | FileCheck %s --check-prefix=ROTATE
// RUN: bishengir-opt %s -pass-pipeline='builtin.module(hacc-append-device-spec{target=Ascend910B1},func.func(hivm-mark-multi-buffer{enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]}),hivm-plan-memory-regbase,func.func(hivm-graph-sync-solver{solver-version=v2},hivm-enable-multi-buffer,hivm-lower-multi-buffer-counter))' | FileCheck %s --check-prefix=ROTATE

// Plain GM->L1 loads of prepacked zN storage must use L1 rather than UB.
// Compose marking, allocation, synchronization and rotation for unequal local
// counts. Seven independent output tiles exercise a partial final cycle for
// both counts. This is an IR contract test; device precision and performance
// must be checked separately.
// PLAN-LABEL: func.func @l1_load_nbuffer
// ROTATE-LABEL: func.func @l1_load_nbuffer
func.func @l1_load_nbuffer(%a: memref<256xf16, #hivm.address_space<gm>>,
                         %b: memref<256xf16, #hivm.address_space<gm>>,
                         %out: memref<7x16x16xf32, #hivm.address_space<gm>>)
    attributes {hivm.func_core_type = #hivm.func_core_type<AIC>} {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c7 = arith.constant 7 : index
  %c16 = arith.constant 16 : index
  %true = arith.constant true
  // ROTATE-DAG: %[[THREE:.*]] = arith.constant 3 : i64
  // ROTATE-DAG: %[[FOUR:.*]] = arith.constant 4 : i64
  scf.for %i = %c0 to %c7 step %c1 {
    // PLAN-DAG: hivm.hir.pointer_cast(%{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}) : memref<256xf16, #hivm.address_space<cbuf>>
    %al_flat = memref.alloc() : memref<256xf16, #hivm.address_space<cbuf>>
    %al = memref.expand_shape %al_flat [[0, 1, 2, 3]] output_shape [1, 1, 16, 16] : memref<256xf16, #hivm.address_space<cbuf>> into memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
    // PLAN-DAG: hivm.hir.pointer_cast(%{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}) : memref<256xf16, #hivm.address_space<cbuf>>
    %bl_flat = memref.alloc() : memref<256xf16, #hivm.address_space<cbuf>>
    %bl = memref.expand_shape %bl_flat [[0, 1, 2, 3]] output_shape [1, 1, 16, 16] : memref<256xf16, #hivm.address_space<cbuf>> into memref<1x1x16x16xf16, #hivm.address_space<cbuf>>
    // PLAN-DAG: hivm.hir.pointer_cast(%{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}) : memref<1x1x16x16xf32, #hivm.address_space<cc>>
    %acc = memref.alloc() : memref<1x1x16x16xf32, #hivm.address_space<cc>>
    // ROTATE-DAG: arith.remui %{{.*}}, %[[THREE]] : i64
    // ROTATE-DAG: arith.remui %{{.*}}, %[[FOUR]] : i64
    hivm.hir.load ins(%a : memref<256xf16, #hivm.address_space<gm>>)
      outs(%al_flat : memref<256xf16, #hivm.address_space<cbuf>>)
    hivm.hir.load ins(%b : memref<256xf16, #hivm.address_space<gm>>)
      outs(%bl_flat : memref<256xf16, #hivm.address_space<cbuf>>)
    hivm.hir.mmadL1 ins(%al, %bl, %true, %c16, %c16, %c16 :
      memref<1x1x16x16xf16, #hivm.address_space<cbuf>>,
      memref<1x1x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index)
      outs(%acc : memref<1x1x16x16xf32, #hivm.address_space<cc>>)
    %tile = memref.subview %out[%i, 0, 0] [1, 16, 16] [1, 1, 1] :
      memref<7x16x16xf32, #hivm.address_space<gm>> to
      memref<16x16xf32, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>
    hivm.hir.fixpipe {enable_nz2nd} ins(%acc : memref<1x1x16x16xf32, #hivm.address_space<cc>>)
      outs(%tile : memref<16x16xf32, strided<[16, 1], offset: ?>, #hivm.address_space<gm>>)
  }
  return
}
