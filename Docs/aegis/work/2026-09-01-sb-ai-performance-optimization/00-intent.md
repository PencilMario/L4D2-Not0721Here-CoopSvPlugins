# Task Intent Draft

- 目标：执行 `2026-09-01-sb-ai-performance-optimization` 计划，降低 Survivor Bot 高频路径的 CPU/Trace 成本。
- 范围：`l4d2_sb_ai_improver` 的观测、RunCmd 固定工作、感知/Trace、实体/物品扫描和救援动作；保留现有行为和接口。
- 非目标：不重写 NextBot、不调整 Bot 策略/难度、不更换 Left4DHooks native、不做异步 Trace。
- 风险提示：缓存过期会影响反应延迟；EntRef、跨地图状态和 SourcePawn 编译兼容性必须优先验证。
