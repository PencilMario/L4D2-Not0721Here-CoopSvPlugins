# Zombie Character Select 多语言支持验证证据

## 通过的检查

- RED：`pwsh -NoProfile -File tests/l4d2_zcs_multilingual.tests.ps1` 在源码未接入翻译时以退出码 `1` 失败，原因是缺少 phrases 文件、`LoadTranslations`、显式 `%T` 目标和逐玩家 HUD。
- GREEN：同一测试在实现后以退出码 `0` 输出 `Zombie Character Select multilingual contract passed`。
- Tank 回归：`pwsh -NoProfile -File tests/l4d2_zcs_tank_switch.tests.ps1` 以退出码 `0` 输出 `Zombie Character Select Tank contract passed`。
- 编译：使用 `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe` 和 `AGENTS.md` 中的 include 路径编译 `l4d2_zcs_redux.sp`，退出码 `0`。输出为 SourcePawn Compiler `1.12.0.7221`，仅报告已有的 `g_sSINames`、`g_sSIClassnames` 未使用警告。
- 资源编码：`l4d2_zcs_redux.phrases.txt` 以 UTF-8 BOM 开头，并包含 14 个保留的 `0x04` 聊天颜色控制字节。
- 全量静态回归：17 个 PowerShell 测试中 16 个退出码 `0`；唯一失败的 `check_release_updater_names.ps1` 因仓库缺失 `install_release_updaters.sh`，与本次改动无关。
- 临时产物：验证用 `l4d2_zcs_redux_verify.smx` 已从插件目录删除。
- 空白检查：源码与任务记录的 `git diff --check` 无输出；新增未跟踪文件的 `git diff --no-index --check` 也无空白错误输出。最终工作区确认没有验证用 `.smx` 残留。

## 已证明的行为

- 插件加载 `l4d2_zcs_redux.phrases`；所有目标聊天消息使用 `%T` 并显式传入接收玩家索引。
- `en` 与 `chi` 的聊天提示、HUD 标题、HUD 行、冷却标记和七类可选感染者名称均有翻译条目；Witch/Survivor 名称也有完整条目供 helper 回退/扩展使用。
- HUD 为每个接收玩家单独创建和格式化 panel，不会把一种语言的 panel 发送给另一种语言的玩家。
- Tank 的已有选择、独立限制和普通特感总数排除规则未回退；Tank 契约测试通过。

## 未验证与手工步骤

当前没有实时 L4D2 服务器，无法自动确认游戏内客户端语言设置后的聊天和 HUD 实际渲染。手工验证：

1. 启动 L4D2 服务器并加载 `l4d2_zcs_redux.smx` 与新 phrases 文件。
2. 使用一个 `en` 客户端和一个 `chi` 客户端进入感染者鬼魂状态，确认各自看到对应语言的按键提示、类别提示和限制 HUD。
3. 将 `zcs_tank_limit` 设为 `1`，确认 Tank 可选择；再尝试第二只 Tank，确认限制提示按玩家语言显示。
