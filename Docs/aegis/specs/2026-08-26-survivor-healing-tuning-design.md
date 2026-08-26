# Survivor Healing Tuning

**Status:** Approved

## Intent

调整 `versus_isfullshit` 配置中的生还者自动回血节奏，并让开局回血值大于原版 100 时同步成为生还者最大生命值。

## Scope

- 将 `automatic_healing_max` 从 60 调整为 200。
- 将 `automatic_healing_repeat_interval` 从 0.15 调整为 0.3 秒。
- 保持 `automatic_healing_health` 不配置、不修改，继续使用插件默认回复量。
- 将 `level_start_heal_health` 设置为 500。
- 修改 `level_start_heal.sp`：当有效的 `level_start_heal_health` 大于 100 时，将生还者的 `m_iMaxHealth` 设置为该值，再执行已有的开局回血逻辑。
- 重新编译 `addons/sourcemod/plugins/optional/level_start_heal.smx`。

## Design

自动回血仍使用临时生命值（health buffer），所以 200 是自动回血的实血加临时血总目标；本次只改变目标和触发间隔，不改变每次回复的默认数值。开局回血插件继续在生还者进入可操作状态时执行现有回血、清除黑白和倒地次数逻辑；在其恢复生命前，仅对大于 100 的配置值同步设置 `m_iMaxHealth`，从而 `level_start_heal_health=500` 会产生 500 最大生命和 500 开局生命。

## Compatibility Boundary

击杀回血插件的单次回复值和源码保持不变，自动回血等待时间、临时血衰减和开局回血的既有黑白/倒地状态重置也保持不变。`automatic_healing_health` 不新增配置项。由于击杀回血插件已有的总上限公式是 `m_iMaxHealth + 100`，最大生命设为 500 后其总上限自然为 600；这是最大生命变更的预期联动，不另改击杀回血插件。`m_iMaxHealth` 只由大于 100 的开局回血值覆盖；100 及以下沿用游戏或其他插件的现有最大生命值。

## Verification

先运行静态配置/源码契约测试并确认旧状态失败，再修改目标文件并重新运行该测试；使用项目 SourcePawn 编译器编译 `level_start_heal.sp`，检查输出 `.smx` 存在，最后运行 `git diff --check` 并复核差异。服务器内的实际 HUD、伤害和重生流程需要部署后手动验证。

## Working Drafts

- **TaskIntentDraft:** 让该对抗配置的自动回血在总生命低于 200 时按原默认单次回复量、每 0.3 秒运行一次，并让开局值 500 同步为最大生命。
- **BaselineReadSetHint:** `AGENTS.md`、`README.md`、`Docs/aegis/README.md`、`cfg/cfgogl/versus_isfullshit/versus.cfg`、`confogl_plugins.cfg`、`automatic_healing.sp` 和 `level_start_heal.sp`。
- **ImpactStatementDraft:** 影响一个 Confogl 配置和一个 SourceMod 插件源码/二进制；核心兼容边界是保留默认单次自动回血量与既有状态重置，仅新增大于 100 时的最大生命同步。

## Non-goals

- 不调整 `sm_killheal_enable`、击杀回血单次数值或其既有上限公式。
- 不修改 `automatic_healing_health` 的默认值或添加对应配置行。
- 不将自动回血的 200 目标改成全局最大生命值。
