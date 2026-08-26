# 基线读取集

- `AGENTS.md`：SourcePawn 1.12 编译器和 include 路径约束。
- `addons/sourcemod/scripting/l4d2_zcs_redux.sp`：当前硬编码提示、类别名称、`PrintToChat` 调用和共享 HUD 面板实现。
- `addons/sourcemod/translations/`：现有 `.phrases.txt` 格式及 `en`/`chi` 语言代码。
- `addons/sourcemod/scripting/adminhelp.sp`、`free_camera.sp`、`l4d2_charger_steering.sp`：显式 `%T` 的项目惯例。
- `addons/sourcemod/scripting/readyup.sp`：`LoadTranslations("*.phrases")` 的启动惯例。
- `tests/*.tests.ps1`：仓库静态契约测试模式。
- `Docs/aegis/work/2026-08-26-zcs-tank-switch/`：必须保留的前序 Tank 功能记录和工作区改动。

**已确认事实：** 当前插件未调用 `LoadTranslations`；七条玩家提示是中文宏字符串；HUD 使用一个共享面板并直接写入英文标题/类别名；单人 `PrintToChat` 未显式设置翻译目标。

**运行时未知：** 当前环境没有可连接的 L4D2 服务器，无法实测不同客户端语言设置下的游戏内聊天和 HUD 渲染；编译、翻译文件契约和代码静态检查可验证接入完整性。
