# 复现命令

这些是面向新建、独立实验目录的复现步骤。历史测量的实际参数/路径/工具SHA保留在results及各command.json；新构建的路径、版本标签或构建ID可能不同，不能要求二进制SHA与历史机器一致。提交b2b8e4aee和测量代码5e1813a86的9个文件内容相同，仅2项lit路径改名。本文未把整理命令视为新增设备实测。

## 1. 环境与材料

设备复现使用A3（本次Ascend910_9382）、CANN9.2.0及配套ops/driver、Triton3.6.0/torch_npu2.10.0.post7/Python3.11.15。显式HIR loader依赖所记录Triton NPU driver接口；其他发行版若元数据接口不同，需先匹配软件环境，不能绕过错误或精度校验。仅IR测试不需要启动NPU。

源码构建需要Clang15、CMake>=3.28、Ninja>=1.12和LLD。记录环境是240GiB/40CPU，编译16、链接1并发；以下默认编译4、链接1，按远端可用内存调整。源码、build、TMPDIR放磁盘；不要在16GB本机或内存盘/tmp重构建LLVM。

```bash
source /usr/local/Ascend/cann/set_env.sh
export PATH=/usr/local/python3.11.15/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/python3.11.15/lib:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:/usr/local/Ascend/driver/lib64:$LD_LIBRARY_PATH
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 LC_ALL=C
export NBUFFER_BUILD_JOBS=4

# 从公开fork获取，无需私人工作台权限。
git clone --single-branch --branch evidence/ascendnpu-ir-837-20261102 \
  https://gitcode.com/miku1122/AscendNPU-IR.git nbuffer-evidence
export NBUFFER_EVIDENCE="$(realpath nbuffer-evidence)/nbuffer-837"
# 如已下载证据ZIP，NBUFFER_EVIDENCE也可直接指向其中nbuffer-837。

export NBUFFER_ROOT="$PWD/nbuffer-837-lab"
mkdir -p "$NBUFFER_ROOT"/{tools,tmp,results,baseline-bin}
export TMPDIR="$NBUFFER_ROOT/tmp"
git clone --single-branch --branch task/ascendnpu-ir-837-nbuffer-submit-20261102 \
  https://gitcode.com/miku1122/AscendNPU-IR.git "$NBUFFER_ROOT/source"
git -C "$NBUFFER_ROOT/source" checkout b2b8e4aee78127532a821296ae7a6c17575506a2
git -C "$NBUFFER_ROOT/source" submodule update --init third-party/llvm-project
git -C "$NBUFFER_ROOT/source/third-party/llvm-project" rev-parse HEAD
# 必须为953bd530f84c21763273e5f03a66b95c99465eef。

cp "$NBUFFER_EVIDENCE"/repro/*.py "$NBUFFER_ROOT/tools/"
git clone --single-branch --branch task/ascendnpu-ir-837-nbuffer-20261102 \
  https://gitcode.com/miku1122/AscendNPU-IR-DT.git "$NBUFFER_ROOT/dt"
git -C "$NBUFFER_ROOT/dt" checkout 1b1878cb64f8164c2a47ab2bedadf4d5d6805abc
```

## 2. 同构建冻结官方代码基线，再恢复候选

下列restore只用于刚建的实验source目录，不用于含其他工作改动的checkout。基线把本补丁涉及的3份C++全部恢复446641，其余编译器C++原本与该基线一致；只保留新增测试/文档，不影响编译器行为。

```bash
cd "$NBUFFER_ROOT"
export NBUFFER_BASE=446641ac2a1708f9b2dcb25bc7d1a89fa747ea42
export NBUFFER_CANDIDATE=b2b8e4aee78127532a821296ae7a6c17575506a2
export NBUFFER_MARK=bishengir/lib/Dialect/HIVM/Transforms/MarkMultiBuffer.cpp
export NBUFFER_PLAN=bishengir/lib/Dialect/HIVM/Transforms/PlanMemory.cpp
export NBUFFER_REGPLAN=bishengir/lib/Dialect/HIVM/Transforms/regbase/PlanMemory.cpp
git -C source restore --source="$NBUFFER_BASE" -- "$NBUFFER_MARK" "$NBUFFER_PLAN" "$NBUFFER_REGPLAN"

# 本机CANN9.2记录实际目录为/usr/local/Ascend/cann-9.2.0/bin。
# 使用cann软链可恢复同一安装；若安装路径不同，设置为真实bisheng目录。
export BISHENG_BIN_DIR=/usr/local/Ascend/cann/bin
cmake -S source/third-party/llvm-project/llvm -B build -G Ninja \
  -DCMAKE_C_COMPILER=clang-15 -DCMAKE_CXX_COMPILER=clang++-15 \
  -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_ENABLE_PROJECTS=mlir -DLLVM_EXTERNAL_PROJECTS=bishengir \
  -DLLVM_EXTERNAL_BISHENGIR_SOURCE_DIR="$NBUFFER_ROOT/source" \
  -DLLVM_TARGETS_TO_BUILD=AArch64 -DLLVM_ENABLE_LLD=ON \
  -DLLVM_PARALLEL_LINK_JOBS=1 -DLLVM_LIT_ARGS="-sv -j8" \
  -DBSPUB_DAVINCI_BISHENGIR=ON -DLLVM_BSPUB_DAVINCI_BISHENGIR=ON \
  -DLLVM_BSPUB_DAVINCI_BISHENGIR_A5=ON -DLLVM_BSPUB_DAVINCI_BISHENGIR_A5_NPUIR=ON \
  -DBISHENGIR_ENABLE_PM_CL_OPTIONS=ON -DBISHENGIR_ENABLE_TRITON_COMPILE=ON \
  -DBISHENGIR_PUBLISH=OFF -DBISHENGIR_BUILD_HIVMC=ON \
  -DBISHENGIR_BUILD_TEMPLATE=ON -DBISHENG_COMPILER_PATH="$BISHENG_BIN_DIR"
ninja -C build -j"$NBUFFER_BUILD_JOBS"
ninja -C build -j"$NBUFFER_BUILD_JOBS" mlir-opt mlir-translate
cp -p build/bin/bishengir-opt build/bin/bishengir-compile baseline-bin/
ln -s build/lib lib
sha256sum baseline-bin/bishengir-opt baseline-bin/bishengir-compile > results/baseline-tools.sha256

# 同一源码模板库、构建配置和硬件下恢复本补丁。
git -C source restore --source="$NBUFFER_CANDIDATE" -- "$NBUFFER_MARK" "$NBUFFER_PLAN" "$NBUFFER_REGPLAN"
# rsync等可能保留旧mtime；确保Ninja真正编译了这3份文件。
touch "source/$NBUFFER_MARK" "source/$NBUFFER_PLAN" "source/$NBUFFER_REGPLAN"
ninja -C build -j"$NBUFFER_BUILD_JOBS" bishengir-opt bishengir-compile
sha256sum build/bin/bishengir-opt build/bin/bishengir-compile > results/candidate-tools.sha256
```

E2E必须有源码配套c220 AIC/AIV/MIX和host O0/O2模板。基线工具从baseline-bin/查找兄弟lib/，候选从build/bin查找build/lib，均指向同一模板。不要关闭HIVMC，否则会缺runHIVMCCompileA3等符号；不要用预装compiler冒充源码基线。

## 3. lit与槽数/容量

```bash
cd "$NBUFFER_ROOT"
# 从build内的lit.site.cfg入口运行；不要直接加载源码lit.cfg.py。
build/bin/llvm-lit -sv -j4 \
  build/tools/bishengir/bishengir/test/Dialect/HIVM/mark-multi-buffer-copy-space.mlir \
  build/tools/bishengir/bishengir/test/Dialect/HIVM/plan-memory-nbuffer-capacity.mlir \
  build/tools/bishengir/bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-l0c-multi-buffer-pipeline.mlir \
  build/tools/bishengir/bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-load-multi-buffer-pipeline.mlir
LIT_OPTS=-j8 ninja -C build -j"$NBUFFER_BUILD_JOBS" check-bishengir
```

历史记录为1340发现/1193通过/147不支持/0失败，原日志在results/。可选构建特性不同会改变支持项，不可把unsupported算通过或修改测试来凑数字。

普通Load的原基线应无法满足三地址PLAN检查（预期失败）：

```bash
set -o pipefail
baseline-bin/bishengir-opt \
  source/bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-load-multi-buffer-pipeline.mlir \
  -hacc-append-device-spec=target=Ascend910B1 \
  --hivm-mark-multi-buffer="enable-auto=true multibuffer-mode=[(gm,1),(l1,3),(l0c,4),(ub,1)]" \
  -hivm-plan-memory | build/bin/FileCheck \
  source/bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-load-multi-buffer-pipeline.mlir \
  --check-prefix=PLAN
```

不要对未修复基线执行最大N=2147483647用例；它可能在容量诊断前耗尽Host内存。该巨大N保护只在候选验证。候选容量文件验证两个规划器共12条RUN（精确容纳、超界和极大N），原有精度/诊断断言未放宽。

## 4. DT独立tile与跨K累加

```bash
cd "$NBUFFER_ROOT/dt"
export PYTHONPATH="$NBUFFER_ROOT/tools"
export NBUFFER_COMPILER="$NBUFFER_ROOT/build/bin/bishengir-compile"
export NBUFFER_COMPILER_AUDIT="$NBUFFER_ROOT/results/dt-candidate-audit.jsonl"
export TRITON_CACHE_DIR="$NBUFFER_ROOT/cache-dt-candidate"
python3 -m pytest -q -p nbuffer_compiler_audit src/modules/cube_vector/test_l1_l0c_nbuffer.py

export NBUFFER_COMPILER="$NBUFFER_ROOT/baseline-bin/bishengir-compile"
export NBUFFER_COMPILER_AUDIT="$NBUFFER_ROOT/results/dt-baseline-audit.jsonl"
export TRITON_CACHE_DIR="$NBUFFER_ROOT/cache-dt-baseline"
python3 -m pytest -q -p nbuffer_compiler_audit src/modules/cube_vector/test_l1_l0c_nbuffer.py
```

审计适配器只选择真实工具路径、捕获实际命令和输入SHA，不修改数学计算或测试断言。两版本原记录各140通过。cache隔离，避免用旧kernel报告新compiler通过。

## 5. 普通GM→L1 Load设备矩阵与性能

确认设备空闲，停止本任务其他构建/设备测量，再执行。测试参考为CPU FP32结果转f16，rtol/atol=1e-3；零迭代检查sentinel，编译使用tuning mode禁用容量回退。

```bash
cd "$NBUFFER_ROOT"
export TRITON_CACHE_DIR="$NBUFFER_ROOT/cache-hir"
python3 tools/packed_hir_matrix.py --smoke
python3 tools/packed_hir_matrix.py
python3 tools/packed_hir_matrix.py --event-pressure
python3 tools/perf_packed_hir.py
```

普通矩阵72配置×8迭代=576检查；压力矩阵8×8=64检查。每case保存完整命令、compiler/input SHA、四阶段IR和编译返回码。每份IR的物理cbuf/cc地址数量分别核对为请求N；原基线普通Load保持L1=1。

性能：24组×256个64³独立GEMM。A/B物理zN在计时外同样预打包；相同输入、模板和设备，6个版本/模式先验证数值，100预热、30样本×50调用，同进程样本级AB/BA+模式反序，NPU events计时，结束再次校验。输出results/perf-packed-hir/results.json，保存所有样本；重复实验先另存旧results，以免覆盖证据。

无需设备即可复核已公开的原始数据：

```bash
python3 "$NBUFFER_EVIDENCE/repro/analyze_results.py" \
  "$NBUFFER_EVIDENCE/results/performance/results.json"
```

原始结果180行=2版本×3模式×30样本。报告同配置Nbuffer基线57.751400μs→候选50.073600μs，降低13.294571%；不筛离群值。单缓冲两版本IR和设备kernel SHA完全相同，Nbuffer的L0C均4槽、L1实为1/3槽。代表用例收益不能外推为所有模型或所有硬件收益。
