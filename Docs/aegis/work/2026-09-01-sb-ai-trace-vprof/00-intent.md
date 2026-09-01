# Task Intent Draft

- 目标：实现 VProf Trace 优化计划，优先降低 `l4d2_sb_ai_improver` 在 `OnPlayerRunCmd` 中的重复 Trace 和 `Base_TraceFilter` 成本。
- 当前切片：Task 1，仅增加按用途的 Trace 计数；不改变 Bot 行为、不改变 Trace 判定、不添加缓存。
- 缓存规则：一般查询使用 `GetProcessCacheExpiry()`（`ib_process_time`）；逐帧动作结果不得跨 command 复用。
- 完成标准：专项静态测试通过，源码可编译，默认关闭性能日志时不产生逐 Trace 日志或持续计时开销。
