# Todo Checkpoint Draft

## Current state

- 当前任务：P3 回归、编译和发布门槛。
- 已完成：P0 阶段观测；P1 RunCmd 快照/库存缓存；P1 可见性感知缓存、导航和感染者查询复用；P2 实体注册表 bitmask、失效 EntRef 清理、物品粗筛；P2 救援协调/路径查询缓存；新增合同测试。
- 验证完成：全部 `tests/*.tests.ps1`（30 个）退出码 0（`TOTAL=30 PASSED=30 FAILED=0`）；SourcePawn 1.12 编译退出码 0、无错误并生成 `.smx`，Code size 287564，Data size 13756472，Stack/heap size 17300，Total requirements 14061336（该编译器本次未打印字面量 `Compilation successful.`）；`git diff --check` 通过。
- 未完成：本地没有 L4D2 实时服务器，无法完成固定战役十 Bot 的 RunCmd/Trace/救援实战采样和行为延迟对比。
- 兼容性延期：`CheckForItemsToScavenge` 的多列表候选合并未实施；因列表的 weapon ID、拾取条件、优先级和可达性语义不同，继续合并前需要等价行为 fixture。
- 缓存时限规则：查询缓存统一由 `GetProcessCacheExpiry()` 计算，跟随 `ib_process_time`；`0.0` 只用于失效/重置，投掷、换枪和视觉注意记忆等行为计时器保留独立时长。
- 下一步：保留当前改动供用户审阅；若提供服务器，再按计划固定场景采样并记录 P50/P95/P99、Trace 次数和行为结果。

## Evidence

- 计划：`Docs/aegis/plans/2026-09-01-sb-ai-performance-optimization.md`
- 合同测试：`tests/*.tests.ps1`，30/30 通过。
- 编译：`E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe` + 项目 include 路径；退出码 0、无错误并生成 `.smx`，Code size 287564，Data size 13756472 bytes，Stack/heap size 17300 bytes，Total requirements 14061336 bytes（本次输出未含字面量 `Compilation successful.`）。
- 格式：`git diff --check` 退出码 0。
- 缓存审计：59 个缓存过期赋值检查，`CACHE_EXPIRY_AUDIT=PASS`；查询缓存统一跟随 `ib_process_time`。
- 产物：`addons/sourcemod/plugins/l4d2_sb_ai_improver.smx` 已由最新源码生成。

## Drift check draft

- 范围仍限于性能计划；未修改用户已有 `cfg/cfgogl/versus_isfullshit/confogl.cfg`。
- 兼容性边界仍为现有 ConVar、forward/native、Bot 行为和 include 顺序；公开接口未新增替换。
- 退役轨迹：新阶段计时和缓存稳定前保留 `LogSlowCalculation` 及旧 Trace/决策入口；真实采样后再决定是否收缩临时观测。
- 决策：needs-verification（静态合同、编译和格式证据已齐；真实服务器性能/行为指标仍未知；多列表扫描合并已明确延期）。
