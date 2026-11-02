# #837 L1/L0C Nbuffer 设计审阅稿

2026-11-02，公开审阅版本。测试源代码5e1813a86，提交代码b2b8e4aee；两者9个文件内容逐字节相同，仅两个测试路径改名，见[补丁审计](../audit/patch-scope.json)。当前尚未提交上游PR或通过官方验收。

## 基线与范围

官方GitCode master基线`446641ac2a1708f9b2dcb25bc7d1a89fa747ea42`，LLVM子模块`953bd530f84c21763273e5f03a66b95c99465eef`。上游`3ac318047`已实现per-level mode、通用N地址分配、GSS与地址选择，不能重复申报。

本次补齐两个确认缺口：

1. 普通GM→L1 Load原先只在UB模式注册，L1-only漏标，混合配置会错误使用UB数量。修复应让缓冲区使用自身空间的count。
2. 两个PlanMemory都会先展开N−1份StorageEntry，之后才做容量检查。最大合法signed-i32数量可在诊断前耗尽Host内存；应先拒绝单环已必然超容量的请求。

不重写已有GSS，不更改数学精度、Golden、默认count、显式mark优先级或overflow重试策略。不把普通Triton fractal前端的独立布局问题并入本任务重构。

## Pass路径与具体修改

路径均相对源码根。

| 阶段 | 文件/位置 | 行为与本次修改 |
|---|---|---|
| 标记 | `bishengir/lib/Dialect/HIVM/Transforms/MarkMultiBuffer.cpp` | pattern携带AddressSpace；L1注册ND2NZ与Load，L0C注册Fixpipe，UB注册Load/Store；先核对局部operand空间再trace根alloc。Store verifier仅允许UB→GM，不额外注册L1 Store。 |
| 生命周期/分配 | `.../Transforms/PlanMemory.cpp`、`.../Transforms/regbase/PlanMemory.cpp` | 保留现有liveness、inplace merge、slot relation、对齐与冲突求解；MergeInplaceSE后、ExpandMultiBufferStorageEntry前加入单环容量下界检查。 |
| 同步 | `.../Transforms/GraphSyncSolver/SyncSolverBase.cpp`、EventIdSolver/CodeGen | 复用现有按地址列表与读写冲突求同步/事件数量的算法；v1/v2联合验证，无新增C++修改。 |
| 轮转 | `.../Transforms/EnableMultiBuffer.cpp`、MultiBufferLoopAdapter/LowerCounter | 复用通用N路选择与共享循环计数器；已有二路快路径保留。 |
| 流水线 | `.../Pipelines/HIVMPipelines.cpp`及regbase同类路径 | 本地Mark→Plan→Lower/Decompose→InferMemScope→GSS/InjectSync→EnableMultiBuffer→LowerCounter；不改变顺序。 |
| 功能说明 | `docs/source/{zh_cn,en}/developer_guide/features/multi_buffer.md` | 纠正mode未提供/本地固定2的旧描述，说明L1普通Load、各层数量、容量与禁用限制。 |

## IR、索引及生命周期契约

IR公共契约保持：`annotation.mark {hivm.multi_buffer = N : i32}` → 带N个物理地址的`hivm.hir.pointer_cast` → 基于实际地址/别名的同步 → 共享loop counter按N取余进行地址选择。配置不等于成功分配，验收要核对实际IR与设备运行。

Load目标可以经expand_shape等view被MMAD使用：标记trace到同一根alloc，PlanMemory对根存储和views采用一致生命周期；不能把view当成新buffer。每次所属逻辑循环迭代推进一次counter。不同N的L1与L0C可共享循环counter、分别取余；事件数由GSS根据别名和预算独立求解，不强行假定每个槽必须占一个事件。

独立输出tile每次外层迭代可轮转L0C；跨K分块的累加必须保持同一L0C值活过内层循环，只在外层输出tile轮转。DT新增两段K输入并用CPU FP32矩阵乘加验证，防止中途换槽/错误初始化。

for支持非零下界/非单位步长的既有adapter；while使用共享计数存储且不能改变原循环结果签名。嵌套buffer由所属循环驱动；parallel/forall等不满足轮转前提的循环仍拒绝自动标记。禁用总开关与N=1不创建自动多缓冲，已有显式mark不覆盖。

## 容量及硬件约束

通过HACC设备spec读取对应空间容量、对齐和目标约束，不在新代码中硬编码型号。A3测试spec的L1=4194304bits、L0C=1048576bits；64KiB L1×8和32KiB L0C×4精确容纳，多1槽必须overflow。RegBase另用Ascend950PR_950z spec验证联合路径；本次未宣称950设备实测。

同一非空环的N份物理存储必须互不重叠，单环未对齐大小`bits*N`是必需容量的下界。比较`bits > capacity / count`避免整数乘法溢出；成立时将饱和乘法结果写入既有failApplyBufferInfo，返回PLAN_FAILED，沿用原诊断与外层编译回退。检查位于inplace merge之后，扩展N份实体之前。不成立不代表一定可放下：对齐、其他活跃buffer、生命周期复用仍交给原规划器。

GSS保留MTE2→MTE1 RAW与MTE1→MTE2 WAR、M→FIX与FIX→M以及累加依赖；首轮初始化和尾部排空不可删除。N=5/8及额外N=9/16的两输入压力场景通过设备正确性并核对实际槽数，事件求解可保守同步，但不能静默把物理N降成1。容量失败按项目惯例重试或报错，性能实验开启tuning mode禁止容量回退，逐份检查未降级。

## 验证与实测结论

公开验证入口见[验证说明](../README.md)、[原始数据](../results/performance/results.json)与[复现命令](../REPRODUCE.md)。

- lit覆盖空间隔离/总开关、L1/L0C不同N、普通Load及ND2NZ的Mark/两Plan/GSSv1/v2/轮转、容量精确边界/超界及最大signed-i32 N。普通Load基线失败、候选通过；全仓1340=1193通过+147不支持、0失败。
- A3显式packed-zN HIVM：两版本、6种数量组合、3种循环、两种同步，72编译配置×8种迭代=576次精度检查；所有Plan地址槽数逐份核对。合法HIR经正常编译器与源码配套模板生成设备二进制，非只改配置或检查mark。
- 额外N=9/16事件压力8配置×8迭代=64次数值及8份分配检查全部通过。DT独立输出与K累加各70配置，候选/基线各140/140通过，原有rtol/atol=1e-3。区分源码编译器与预装工具，实际调用命令/输入SHA/二进制SHA有记录，使用隔离cache。
- 性能输入24组×256次64³、A/B物理zN、输出ND；相同CPU生成输入、预打包均在计时外。100预热、30样本×50调用，样本级AB/BA与模式反序，NPU events，计时前后校验。L1=3/L0C=4官方代码基线57.751μs→候选50.074μs，耗时−13.295%；30对样本全改善。单缓冲控制的IR与设备二进制SHA完全相同。收益来自原先L1仅1槽的普通Load现在实际分配3槽并与MTE1/M流水重叠；L0C两版本同为4槽。

这证明代表性用例收益，不意味着高N普遍优于2或所有模型都提速。普通Triton fractal前端在两版本均因未消除convert_layout触发stride-align断言，原始失败保留；性能用合法显式HIVM入口，不声称解决了该前端问题。全仓构建限制项、官方smoke/internal CI与最终验收必须单列。

