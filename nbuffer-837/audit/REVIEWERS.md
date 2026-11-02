# Reviewer归属核对

核对对象：官方master `c46bf6a235d71f80dd20f2c61a27879ba5d16eea`；提交 `b2b8e4aee78127532a821296ae7a6c17575506a2`。按仓库`tools/codeowners-check/DEVELOPER.en.md` workflow2执行官方工具，原始结果见[codeowners-check.txt](codeowners-check.txt)，完整规则见[CODEOWNERS.snapshot](CODEOWNERS.snapshot)。核对的是文件规则归属；尚未创建PR、发送review邀请或声称维护者已经接受审阅。

## 新SyncSolver用例的自动归属

两项都是验证多缓冲跨Mark/Plan/GSS/轮转的联合用例，文件名统一为仓库已有的`multi-buffer`写法：

- `bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-l0c-multi-buffer-pipeline.mlir`
- `bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-load-multi-buffer-pipeline.mlir`

命中既有 `/bishengir/test/**/*multi-buffer*` 规则，自动owners：**@huangyujun123、@hid90099092、@tanshengshun、@renxingdong**。此前`nbuffer`命名未命中该规则；只改文件名，测试内容字节不变，未添加或扩大CODEOWNERS规则。

## 评审范围与建议

| 范围 | 已存在CODEOWNERS归属 |
|---|---|
| MarkMultiBuffer与上述两个联合测试 | @huangyujun123 @hid90099092 @tanshengshun @renxingdong |
| 两个PlanMemory及容量测试 | @SL25 @ssy_5825 @ykyyky @zhufang_hw @hid90099092 @tanshengshun |
| 双语功能文档 | @wuying123wy @hid90099092 @tanshengshun |
| GSS实现（本补丁未改，但联合测试覆盖） | @AmmarDab3an @tanzirui123123 @hi_sy @hid90099092 @tanshengshun |

拟PR可优先请求@huangyujun123审阅多缓冲标记与测试，@SL25审阅内存容量保护；同步契约如需专项评审，建议增加@AmmarDab3an。GSS名单来自实际GraphSyncSolver代码规则，不谎称SyncSolver测试本身自动分配给该组。最终review请求名单由PR提交时确认。

复核命令（在提交checkout根目录执行；需安装项目工具要求的pathspec）：

```bash
python3 tools/codeowners-check/codeowners-check.py owners --no-resolve \
  bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-l0c-multi-buffer-pipeline.mlir \
  bishengir/test/Dialect/HIVM/SyncSolver/hivm-gss-l1-load-multi-buffer-pipeline.mlir
python3 tools/codeowners-check/codeowners-check.py owners \
  bishengir/lib/Dialect/HIVM/Transforms/GraphSyncSolver/SyncSolverBase.cpp
```
