// RUN: bishengir-opt %s --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,1),(ub,1)]" | FileCheck %s --check-prefix=L1
// RUN: bishengir-opt %s --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,1),(ub,5)]" | FileCheck %s --check-prefix=UB
// RUN: bishengir-opt %s --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,1),(ub,5)]" | FileCheck %s --check-prefix=BOTH
// RUN: bishengir-opt %s --hivm-mark-multi-buffer="enable-auto=false multibuffer-mode=[(gm,1),(l1,3),(l0c,1),(ub,5)]" | FileCheck %s --check-prefix=OFF

// A plain GM->L1 load must use the L1 count, independently of UB settings.
// L1-LABEL: func.func @copy_spaces
// UB-LABEL: func.func @copy_spaces
// BOTH-LABEL: func.func @copy_spaces
// OFF-LABEL: func.func @copy_spaces
// OFF-NOT: annotation.mark
func.func @copy_spaces(%in: memref<16x16xf32, #hivm.address_space<gm>>,
                       %out: memref<16x16xf32, #hivm.address_space<gm>>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c7 = arith.constant 7 : index
  scf.for %i = %c0 to %c7 step %c1 {
    // L1: %[[A:.*]] = memref.alloc()
    // L1-NEXT: annotation.mark %[[A]] {hivm.multi_buffer = 3 : i32}
    // UB: %[[A:.*]] = memref.alloc()
    // UB-NOT: annotation.mark %[[A]]
    // BOTH: %[[A:.*]] = memref.alloc()
    // BOTH-NEXT: annotation.mark %[[A]] {hivm.multi_buffer = 3 : i32}
    %a = memref.alloc() : memref<16x16xf32, #hivm.address_space<cbuf>>
    hivm.hir.load ins(%in : memref<16x16xf32, #hivm.address_space<gm>>)
      outs(%a : memref<16x16xf32, #hivm.address_space<cbuf>>)
    // L1: %[[B:.*]] = memref.alloc()
    // L1-NOT: annotation.mark %[[B]]
    // UB: %[[B:.*]] = memref.alloc()
    // UB-NEXT: annotation.mark %[[B]] {hivm.multi_buffer = 5 : i32}
    // BOTH: %[[B:.*]] = memref.alloc()
    // BOTH-NEXT: annotation.mark %[[B]] {hivm.multi_buffer = 5 : i32}
    %b = memref.alloc() : memref<16x16xf32, #hivm.address_space<ub>>
    hivm.hir.load ins(%in : memref<16x16xf32, #hivm.address_space<gm>>)
      outs(%b : memref<16x16xf32, #hivm.address_space<ub>>)
    hivm.hir.store ins(%b : memref<16x16xf32, #hivm.address_space<ub>>)
      outs(%out : memref<16x16xf32, #hivm.address_space<gm>>)
  }
  return
}
