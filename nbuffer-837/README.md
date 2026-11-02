# AscendNPU-IR #837：公开审阅与验证材料

本目录独立发布于公开源码 fork 的 **evidence 分支**，无需访问私人工作台。上游代码补丁在 **submit 分支**，不包含本目录、原始数据或构建产物。当前只准备审阅，尚未创建上游PR、发送review请求或申请官方验收。

- 提交分支：`task/ascendnpu-ir-837-nbuffer-submit-20261102`，提交 **b2b8e4aee78127532a821296ae7a6c17575506a2**。
- 验证源代码：**5e1813a86e95db051ff9005fbdcacbaed12af2cc**；基线 **446641ac2a1708f9b2dcb25bc7d1a89fa747ea42**，LLVM **953bd530f84c21763273e5f03a66b95c99465eef**。
- DT代码：**1b1878cb64f8164c2a47ab2bedadf4d5d6805abc**，公开于 [GitCode DT fork](https://gitcode.com/miku1122/AscendNPU-IR-DT)。测试文件同时冻结在[repro](repro/test_l1_l0c_nbuffer.py)。
- 提交树9个文件与已验证树内容逐字节相同，仅两个SyncSolver测试改名为`multi-buffer`以匹配现有归属规则。没有新编译器修改或伪称重新实测，详见[补丁范围审计](audit/patch-scope.json)。
- 准备时最新上游`c46bf6a235d71f80dd20f2c61a27879ba5d16eea`比验证基线多6个提交；只做无冲突合并检查，保留经过验证的基线，没有把新上游内容冒充已测。该合并树相对最新master仍只有本任务9个文件。

## 审阅入口

| 材料 | 链接 |
|---|---|
| 待提交PR描述（尚未发布PR） | [PR_DESCRIPTION.md](PR_DESCRIPTION.md) |
| 设计、Pass顺序、生命周期/容量/同步策略 | [design/DESIGN.md](design/DESIGN.md) |
| 从源码构建、lit、DT、设备矩阵与性能复现 | [REPRODUCE.md](REPRODUCE.md) |
| reviewer规则、匹配结果与建议人选 | [audit/REVIEWERS.md](audit/REVIEWERS.md) |
| 只有本任务改动的完整补丁 | [audit/submission.patch](audit/submission.patch) |
| 完整180个性能样本与编译命令/二进制SHA | [results.json](results/performance/results.json)、[CSV](results/performance/raw_samples.csv) |
| 较早探索数据（含短循环无稳定收益，不用于本修复归因） | [earlier-nd2nz](results/earlier-nd2nz/README.md) |
| 统计摘要与实际buffer槽数 | [SUMMARY.json](results/performance/SUMMARY.json)、[allocation-checks.json](results/performance/allocation-checks.json) |
| 性能输入HIR及两版本代表性四阶段IR | [input.mlir](results/performance/input.mlir)、[baseline](results/performance/baseline-nbuf/passes.mlir)、[candidate](results/performance/candidate-nbuf/passes.mlir) |
| 完整lit结果 | [日志](results/check-bishengir-review-ready.log)、[退出码](results/check-bishengir-review-ready.exit) |
| DT候选与基线结果 | [候选独立tile](results/final-candidate-device-matrix.log)、[候选累加](results/final-candidate-accum-matrix.log)、[基线140项](results/final-baseline-device-matrix.log) |
| 72配置/576次设备检查与槽数 | [results](results/device-matrix/results.json)、[slots](results/device-matrix/allocation-checks.json) |
| N=9/16事件压力64次检查 | [results](results/event-pressure/results.json)、[slots](results/event-pressure/allocation-checks.json) |
| 环境、源码与二进制身份 | [环境](results/continuation-environment.txt)、[SHA](results/final-identity-sha256.txt)、[调用审计摘要](results/compiler-audit-summary.json) |

## 结果与边界

A3/aarch64，Ubuntu24.04.5，CANN9.2.0、driver26.1.1、Python3.11.15、Triton3.6.0、torch_npu2.10.0.post7，Clang15/CMake3.28.3/Ninja1.13.2，Release+assertions。使用源码配套c220 O0/O2模板。下列是已执行记录，非官方验收：

- 全仓lit：**1340发现、1193通过、147不支持、0失败**。不支持项不当作通过。此前缺工具/默认lit并发耗尽fd的修复是补工具、限制并发，未删测试、改阈值或加unsupported。
- 普通Load联合测试：原基线因L1只有1地址而失败；候选membase/RegBase与GSS v1/v2通过。容量恰好容纳/超界/最大signed-i32 N在两个规划器通过。
- DT：候选和基线各**140/140通过**；独立输出tile70、两段K累加70，CPU FP32参考转f16，原rtol/atol均1e-3。
- 显式packed-zN HIVM：两版本×6种数量×3循环×2同步=**72配置、576次设备检查**；另有N=9/16事件压力**8配置、64次设备检查**。零/短/尾迭代、for/while/嵌套均覆盖，80份Plan IR实际槽数全部核对。

| 配置 | 官方代码基线中位μs | 候选中位μs |
|---|---:|---:|
| L1=1/L0C=1 | 74.264 | 74.556 |
| L1=2/L0C=2 | 58.428 | 50.858 |
| L1=3/L0C=4 | 57.751 | 50.074 |

同Nbuffer配置耗时降低 **13.294571%**。30组配对全部改善（11.534826%–14.827378%）。单缓冲的两版本IR/设备二进制SHA完全相同；Nbuffer的L0C均4槽、L1实际分别1/3槽，覆盖了普通Load修复的执行差异。24组×256次64³，100次预热、30样本×50调用，同进程样本级AB/BA及模式反序，NPU events；全部样本保留，计时前后精度校验。输入A/B在计时外同样预打包为物理zN，输出ND。

这是该代表用例的收益，不是所有模型、更高N普遍优于双缓冲或官方验收结论。950只有IR/Pass验证，未设备实测。普通Triton fractal前端在两版本均有已有convert_layout/stride-align断言；性能采用合法显式HIVM入口，不声称修好了前端。编译器基线版本标签可能仍为c327（当时checkout），其编译器C++恢复官方446641；以原始源码/二进制SHA和命令识别，不能只看version标签。

导出的复现程序只将固定实验目录改为`NBUFFER_ROOT`，未改数学、编译参数、精度或测量方法；原/导出脚本SHA见[provenance.json](repro/provenance.json)。所有材料文件SHA见[MANIFEST.json](MANIFEST.json)。无SSH凭据、个人信息邮件、设备二进制或大构建日志。

## 公开可访问性

同一evidence分支也推送至公开GitHub fork `Miiikuuu/AscendNPU-IR`。匿名HTTP读取首个快照的README、复现命令和原始性能JSON均返回200，逐文件SHA与本地完全相同，见[audit/public-access-first-snapshot.json](audit/public-access-first-snapshot.json)。GitCode已登录网页可见同一内容；其raw域对匿名请求返回403，因此不把raw域当唯一下载入口，可用公开GitHub镜像或Git HTTPS获取evidence分支。材料无需私人工作台权限。
