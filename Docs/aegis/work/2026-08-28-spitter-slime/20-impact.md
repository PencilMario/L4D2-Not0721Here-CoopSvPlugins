# ImpactStatementDraft

- affected layers：SourcePawn 插件运行时、`versus_isfullshit` 配置、部署二进制、契约测试。
- invariants：粘液按 owner 隔离；owner 死亡时完整清理；汽油桶碰撞只爆炸一次；视觉特效不负责伤害；开启替换时 `IN_ATTACK` 永久拦截并发射汽油桶，只有创建或冷却失败时保留原版吐酸回退。
- damage invariant：所有玩家伤害统一通过 `SDKHooks_TakeDamage`，不混用 `point_hurt` 或实体爆炸伤害。
- compatibility boundary：只替换目标模式的旧插件，不改变其他模式和共享插件。
- retirement track：旧 `L4D2 Spitter Supergirl` 源码、二进制和加载行随新插件切换退役。
