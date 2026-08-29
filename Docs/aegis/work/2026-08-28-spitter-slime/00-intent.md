# TaskIntentDraft

- requested outcome：替换 `versus_isfullshit` 中的旧喷吐者加强插件。
- scope：新 SourcePawn 插件、模式加载/ConVar 配置、二进制和静态契约测试。
- non-goals：不修改其他模式、普通投掷物或其他特感插件。
- risk hints：原生口水实体、能力拦截、实体清理、无硬直击退和旧插件退役。
- damage boundary：粘液和汽油桶伤害统一走 SDKDamage 的 `SDKHooks_TakeDamage`。
