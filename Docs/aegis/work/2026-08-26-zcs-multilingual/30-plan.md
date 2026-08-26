# Zombie Character Select 多语言支持实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 `l4d2_zcs_redux` 的玩家可见聊天和 HUD 支持 `en`、`chi`，并保持现有感染者选择及 Tank 逻辑不变。

**Architecture:** 使用插件专用 phrases 文件和 `LoadTranslations`。单个客户端输出显式使用 `%T` 与目标客户端索引；类别名称通过 ID 对齐的 phrase-key 数组本地化；HUD 按客户端分别创建面板，避免共享语言。

**Tech Stack:** SourcePawn 1.12、SourceMod、PowerShell 静态契约测试。

**Baseline / Authority Refs:** `AGENTS.md`、`20-spec.md`、`l4d2_zcs_redux.sp`、现有翻译文件、现有 `%T` 调用惯例和前序 Tank 工作记录。

**Compatibility Boundary:** 仅改变用户可见文本的来源和 HUD 面板构建方式；不改变 ConVar、选择顺序、数量限制、Tank 默认关闭状态、`sm_buy` 参数、普通特感总数或现有配置。

**Verification:** 先运行多语言契约测试得到预期 RED，再实现后运行 GREEN；编译 `l4d2_zcs_redux.sp`；运行 `l4d2_zcs_tank_switch.tests.ps1` 及多语言测试；检查工作区差异和换行/空白。

**事实 / 假设 / 未知：** 已确认项目的单人消息惯例是显式 `%T`，`%t` 依赖全局目标；假设普通 phrases 回退满足非 `en`/`chi` 玩家；未知是 live L4D2 中混合语言面板的实际渲染，需手工验证。

### Task 1: 建立失败的多语言契约测试

**Files:**
- Create: `tests/l4d2_zcs_multilingual.tests.ps1`

**Why this task exists:** 锁定翻译资源、加载入口、显式翻译目标和逐玩家 HUD 这些用户可见行为，防止将中文硬编码或共享英文 HUD 带回。

**Verification:**

```powershell
pwsh -NoProfile -File tests/l4d2_zcs_multilingual.tests.ps1
```

预期基线失败，原因包括翻译文件不存在、没有 `LoadTranslations` 和仍存在硬编码提示。

- [x] **Step 1: 写入测试契约**：读取源码和 phrases 文件；断言所有键同时有 `en`/`chi`，源码加载 phrases，七个聊天调用使用 `%T` 和目标客户端，类别名称有本地化路径，HUD 在客户端循环内创建面板，旧中文宏和共享面板结构不存在。
- [x] **Step 2: 运行 RED**：`pwsh -NoProfile -File tests/l4d2_zcs_multilingual.tests.ps1` 按预期以退出码 `1` 失败，报告缺少翻译资源/加载入口/本地化路径；没有 PowerShell 语法错误。

### Task 2: 添加翻译资源和源码接入

**Files:**
- Create: `addons/sourcemod/translations/l4d2_zcs_redux.phrases.txt`
- Modify: `addons/sourcemod/scripting/l4d2_zcs_redux.sp`

**Why this task exists:** 让每个玩家看到与其客户端语言匹配的提示和限制 HUD。

**Impact / Compatibility:** 消息展示层改变；选择/限制状态机及前序 Tank 改动保持不变。

- [x] **Step 1: 添加 `en`/`chi` phrases**：为设计中的每个键提供两种语言，保留聊天颜色控制码和原有格式参数数量。
- [x] **Step 2: 启动时加载翻译**：在 `OnPluginStart` 中加入 `LoadTranslations("l4d2_zcs_redux.phrases");`。
- [x] **Step 3: 替换聊天提示**：将提示宏改为 phrase key，并将每次 `PrintToChat(Client, ...)` 改为 `PrintToChat(Client, "%T", phrase, Client, ...)`。
- [x] **Step 4: 添加类别名称翻译辅助**：用 ID 对齐的 phrase-key 数组和目标客户端参数生成类别名；只把本地化结果传给外层 `%s`。
- [x] **Step 5: 重建逐玩家 HUD**：在满足原条件的玩家循环内创建面板，使用目标玩家翻译标题、类别名、行格式和冷却标记，发送后关闭该面板。
- [x] **Step 6: 运行 GREEN**：`pwsh -NoProfile -File tests/l4d2_zcs_multilingual.tests.ps1` 输出 `Zombie Character Select multilingual contract passed`，退出码 `0`。

### Task 3: 编译和回归验证

**Files:**
- Modify: `Docs/aegis/work/2026-08-26-zcs-multilingual/50-evidence.md`

**Repair Track:** 修复玩家可见文本没有翻译目标和共享 HUD 语言错误的根因，所有权保持在 `l4d2_zcs_redux.sp` 的消息/HUD 代码与其专用 phrases 文件。

**Retirement Track:** 旧的中文 `PLAYER_*` 字符串、固定英文 HUD 标题/类别名和共享面板构建路径退出；内部英文 `g_sBossNames`、`sm_buy` 参数和调试日志保留，因为它们不是玩家本地化输出边界。

- [x] **Step 1: 编译源码**：使用 `AGENTS.md` 指定的 `spcomp.exe`、include 路径编译成功，退出码 `0`；仅有原有两个未使用数组警告。
- [x] **Step 2: 运行回归**：多语言契约、Tank 契约和其余受影响静态测试通过；仓库全量 17 项中只有缺失 `install_release_updaters.sh` 的既有检查失败。
- [x] **Step 3: 检查差异**：执行差异、BOM 和临时编译产物检查，确认没有覆盖前序 Tank/配置改动。
- [x] **Step 4: 记录证据**：证据、未验证的 live server 场景和手工复现步骤已记录在 `50-evidence.md`。
