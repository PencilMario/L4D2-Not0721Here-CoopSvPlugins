# Baseline Read Set

- `AGENTS.md`: 项目编译约定。
- `README.md`: 仓库用途和部署边界。
- `cfg/cfgogl/versus_isfullshit/versus.cfg`: 当前自动回血 CVar。
- `cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg`: 开局回血插件加载入口。
- `addons/sourcemod/scripting/automatic_healing.sp`: 自动回血 CVar 默认值和 health buffer 行为。
- `addons/sourcemod/scripting/level_start_heal.sp`: 开局回血 CVar、恢复逻辑和回合/玩家替换流程。
- `Docs/aegis/specs/2026-08-26-survivor-healing-tuning-design.md`: 已批准设计。

当前基线：工作区无未提交改动；配置为 `automatic_healing_max 60`、`automatic_healing_repeat_interval 0.15`，没有 `automatic_healing_health` 配置项；`level_start_heal_health` 尚未写入该模式配置，插件源码默认值为 100。
