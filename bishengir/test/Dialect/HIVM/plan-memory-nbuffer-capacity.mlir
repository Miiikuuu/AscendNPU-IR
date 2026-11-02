// RUN: bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,8),(l0c,1),(ub,1)]" -hivm-plan-memory -split-input-file | FileCheck %s --check-prefix=L1-FIT
// RUN: bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,4),(ub,1)]" -hivm-plan-memory -split-input-file | FileCheck %s --check-prefix=CC-FIT
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,9),(l0c,1),(ub,1)]" -hivm-plan-memory -split-input-file 2>&1 | FileCheck %s --check-prefix=L1-OVER
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,5),(ub,1)]" -hivm-plan-memory -split-input-file 2>&1 | FileCheck %s --check-prefix=CC-OVER
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,2147483647),(l0c,1),(ub,1)]" -hivm-plan-memory -split-input-file 2>&1 | FileCheck %s --check-prefix=L1-HUGE
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,2147483647),(ub,1)]" -hivm-plan-memory -split-input-file 2>&1 | FileCheck %s --check-prefix=CC-HUGE
// RUN: bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,8),(l0c,1),(ub,1)]" -hivm-plan-memory-regbase -split-input-file | FileCheck %s --check-prefix=L1-FIT
// RUN: bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,4),(ub,1)]" -hivm-plan-memory-regbase -split-input-file | FileCheck %s --check-prefix=CC-FIT
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,9),(l0c,1),(ub,1)]" -hivm-plan-memory-regbase -split-input-file 2>&1 | FileCheck %s --check-prefix=L1-OVER
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,5),(ub,1)]" -hivm-plan-memory-regbase -split-input-file 2>&1 | FileCheck %s --check-prefix=CC-OVER
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,2147483647),(l0c,1),(ub,1)]" -hivm-plan-memory-regbase -split-input-file 2>&1 | FileCheck %s --check-prefix=L1-HUGE
// RUN: not bishengir-opt %s -hacc-append-device-spec=target=Ascend910B1 --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,1),(l0c,2147483647),(ub,1)]" -hivm-plan-memory-regbase -split-input-file 2>&1 | FileCheck %s --check-prefix=CC-HUGE

// The device limits are in bits: L1=4194304, L0C=1048576. All slots must
// fit, including when the loop has fewer iterations than the slot count.
// Maximum accepted signed-i32 counts must report capacity failure without
// constructing billions of StorageEntries first, in either planner.
// L1-HUGE: cbuf overflow, requires 1125899906318336 bits while 4194304 bits available!
// CC-HUGE: cc overflow, requires 562949953159168 bits while 1048576 bits available!
// L1-OVER: cbuf overflow, requires 4718592 bits while 4194304 bits available!
// CC-OVER: cc overflow, requires 1310720 bits while 1048576 bits available!
// L1-FIT-LABEL: func.func @l1_capacity
// L1-FIT: hivm.hir.pointer_cast(%{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}) : memref<32x4x16x16xf16, #hivm.address_space<cbuf>>
func.func @l1_capacity(%in: memref<64x512xf16, #hivm.address_space<gm>>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  scf.for %i = %c0 to %c2 step %c1 {
    %l1 = memref.alloc() : memref<32x4x16x16xf16, #hivm.address_space<cbuf>>
    hivm.hir.nd2nz {dst_continuous} ins(%in : memref<64x512xf16, #hivm.address_space<gm>>)
      outs(%l1 : memref<32x4x16x16xf16, #hivm.address_space<cbuf>>)
  }
  return
}

// -----
// CC-FIT-LABEL: func.func @l0c_capacity
// CC-FIT: hivm.hir.pointer_cast(%{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}, %{{[^,()]+}}) : memref<8x4x16x16xf32, #hivm.address_space<cc>>
func.func @l0c_capacity(%a: memref<64x16xf16, #hivm.address_space<gm>>,
                       %b: memref<16x128xf16, #hivm.address_space<gm>>,
                       %out: memref<64x128xf32, #hivm.address_space<gm>>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %c16 = arith.constant 16 : index
  %c64 = arith.constant 64 : index
  %c128 = arith.constant 128 : index
  %true = arith.constant true
  scf.for %i = %c0 to %c2 step %c1 {
    %al = memref.alloc() : memref<1x4x16x16xf16, #hivm.address_space<cbuf>>
    %bl = memref.alloc() : memref<8x1x16x16xf16, #hivm.address_space<cbuf>>
    hivm.hir.nd2nz {dst_continuous} ins(%a : memref<64x16xf16, #hivm.address_space<gm>>)
      outs(%al : memref<1x4x16x16xf16, #hivm.address_space<cbuf>>)
    hivm.hir.nd2nz {dst_continuous} ins(%b : memref<16x128xf16, #hivm.address_space<gm>>)
      outs(%bl : memref<8x1x16x16xf16, #hivm.address_space<cbuf>>)
    %cc = memref.alloc() : memref<8x4x16x16xf32, #hivm.address_space<cc>>
    hivm.hir.mmadL1 ins(%al, %bl, %true, %c64, %c128, %c16 :
      memref<1x4x16x16xf16, #hivm.address_space<cbuf>>,
      memref<8x1x16x16xf16, #hivm.address_space<cbuf>>, i1, index, index, index)
      outs(%cc : memref<8x4x16x16xf32, #hivm.address_space<cc>>)
    hivm.hir.fixpipe {enable_nz2nd} ins(%cc : memref<8x4x16x16xf32, #hivm.address_space<cc>>)
      outs(%out : memref<64x128xf32, #hivm.address_space<gm>>)
  }
  return
}
