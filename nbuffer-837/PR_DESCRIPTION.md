# [HIVM][MultiBuffer] fix: honor local buffer counts

## 描述 Description

关联社区任务 [#837](https://gitcode.com/Ascend/AscendNPU-IR/issues/837)。

普通GM→L1 Load原先只在UB模式注册多缓冲：L1-only配置漏标，L1=3/UB=5会给cbuf错误的5槽。此补丁按局部buffer实际地址空间匹配copy pattern，使L1 Load采用L1数量，保留ND2NZ/Fixpipe、UB、显式mark与总开关原语义。

同时，普通与RegBase PlanMemory在展开N份StorageEntry前检查单环容量下界，必然超容量时沿用现有overflow/重试处理，避免极大合法N先耗尽Host内存。除法比较避免乘法溢出，对齐、聚合占用和生命周期复用仍交给原规划器。

上游已具备per-level mode、通用N路分配/GSS/轮转；本补丁补齐上述缺口，没有重复实现这些已有能力，也没有重写GSS。

修改范围：3个C++文件、4个lit文件、2个双语功能文档，共9文件、288插入/29删除。完整[补丁与范围审计](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/audit/patch-scope.json)。不包含其他任务、LLVM/submodule、CODEOWNERS修改、构建产物或验证数据。

## 验证与可复现材料

**公开材料不依赖私人工作台：**

- [GitCode验证材料入口](https://gitcode.com/miku1122/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/README.md)；[公开GitHub镜像](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/README.md)。GitHub匿名读取200并核对文件SHA；GitCode raw匿名403时使用该镜像或Git HTTPS。
- [设计文档](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/design/DESIGN.md)、[源码构建/lit/DT/设备与性能复现命令](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/REPRODUCE.md)。
- [全部180个性能原始样本及实际编译命令/身份](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/results/performance/results.json)、[CSV](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/results/performance/raw_samples.csv)、[统计复核脚本](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/repro/analyze_results.py)。
- [DT提交1b1878c](https://gitcode.com/miku1122/AscendNPU-IR-DT/commit/1b1878cb64f8164c2a47ab2bedadf4d5d6805abc)。

测试代码5e1813a86/基线446641ac，LLVM953bd530；提交b2b8e4aee是保留该基线的整理提交。9个文件内容逐字节一致，仅两项SyncSolver测试改名为multi-buffer；未声称对新的提交ID重新执行NPU测量。最新master c46bf6a2的无冲突合并检查完成，合并树相对master仍只有本任务9文件。

| 验证 | 已执行结果 |
|---|---|
| Release+assertions源码工具及c220 O0/O2模板构建 | 通过；Clang15、CANN9.2、A3/aarch64 |
| 全仓check-bishengir | 1340发现：1193通过、147不支持、0失败 |
| 普通Load联合Mark/两Plan/GSS v1/v2/轮转 | 基线只有1个L1地址而失败；候选membase/RegBase全部通过 |
| 容量精确边界、超界和最大signed-i32 N | 两规划器通过，沿用overflow诊断 |
| DT独立tile与两段K累加 | 候选/基线各140/140通过，原rtol/atol=1e-3 |
| 显式HIR普通Load，for/while/嵌套、两同步、零/短/尾迭代 | 72配置、576次数值检查，72份实际槽数核对全部通过 |
| N=9/16事件压力 | 8配置、64次数值与8份槽数核对全部通过 |

A3同设备/工具链/输入/模板，24组×256个64³ GEMM，A/B物理zN预打包在计时外，输出ND。100预热、30样本×50调用，同进程样本级AB/BA及模式反序，NPU events，计时前后精度校验、保留全部样本。

| 配置 | 官方代码基线中位μs | 候选中位μs |
|---|---:|---:|
| L1=1/L0C=1 | 74.264 | 74.556 |
| L1=2/L0C=2 | 58.428 | 50.858 |
| L1=3/L0C=4 | 57.751 | 50.074 |

同Nbuffer配置耗时降低13.295%，30对样本全部改善（11.535%–14.827%）。单缓冲两版本IR/设备二进制SHA完全相同；Nbuffer的L0C均4槽、L1实际分别1/3槽，因此该对照覆盖普通Load修复。不是所有模型或更高N普遍优于双缓冲的承诺。

范围限制：147项不支持不算通过；950仅IR/Pass核验、无设备实测。普通Triton fractal前端在两版本均有已有布局转换断言；本次使用合法显式HIVM入口，不声称修复了该前端。官方smoke/internal CI与平台验收尚未执行。

## Reviewer归属

两项SyncSolver联合测试采用multi-buffer命名，官方工具确认命中现有 `/bishengir/test/**/*multi-buffer*`，自动owners为@huangyujun123、@hid90099092、@tanshengshun、@renxingdong；未修改CODEOWNERS。详见[规则与完整匹配结果](https://github.com/Miiikuuu/AscendNPU-IR/blob/0b8b1c42833240b9b6c40b0234e252486ce2d550/nbuffer-837/audit/REVIEWERS.md)。

建议多缓冲由@huangyujun123、内存保护由@SL25评审；如需同步专项评审，建议增加实际GSS代码owner @AmmarDab3an。此处是归属/建议，不表示维护者已经接受review请求。

## 类型 Category

- [x] Bug修复 Bugfix
- [ ] 新功能 New feature
- [ ] 代码风格更新 Style changes
- [ ] 重构 Refactor
- [ ] 构建过程或辅助工具变动 Build-related
- [x] 文档内容更新 Docs

## Checklist

- [x] 代码遵循项目风格，改动C++使用根clang-format
- [x] 已自测；测量源代码与提交树的对应关系及路径改名已公开核对
- [x] 已更新相关双语功能文档
- [ ] 已更新独立changelog（本补丁未另增changelog）
- [x] 标题使用fix类型标签

Assisted-by: AI
