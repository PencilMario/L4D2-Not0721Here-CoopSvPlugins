# Gun Game 付费插件模块化设计

**Status:** Approved

## Intent

将本地付费插件 `addons/sourcemod/scripting/L4D2_NEW_GG_3_9_2026_CN.sp` 从约 2 万行的单体源码拆成职责清晰的 SourcePawn include 模块，同时继续编译为一个运行时插件。第一阶段只改善源码结构和维护边界，保持已有 L4D2 Gun Game 行为；后续 L4D/L4D2 兼容或移植工作通过集中式兼容层处理。

付费源码、拆出的模块、构建产物和本任务的详细实现记录均属于本地私有工作内容，不上传、不推送到 GitHub，也不复制到公开目录。

## Scope

- 保留原插件入口文件和插件身份；入口负责外部 include、共享声明、模块装配和必要的生命周期路由。
- 将实现拆为共享声明/状态、L4D2 兼容、生命周期、回合控制、战斗与排名、武器分发、特殊武器效果、投票、菜单/HUD、持久化、网络与遗留测试工具等模块。
- 初期采用文本 include 组合：仍只生成一个 `L4D2_NEW_GG_3_9_2026_CN.smx`，不生成多个互相依赖的运行时插件。
- 保持命令、ConVar、翻译短语键、数据文件路径、gamedata 名称、资源路径、模式编号、地图列表和现有管理行为不变。
- 将当前 L4D2 特有的 Tank 类别、结局/生还地图判断、地图列表和依赖游戏签名集中在兼容边界，为未来跨版本移植留出替换点。
- 每个拆分阶段都用可复现的 SourcePawn 编译和静态契约检查验证。

## Non-goals

- 不在本阶段修改 Gun Game 的玩法数值、伤害规则、排名规则、投票规则或资源内容。
- 不把插件拆成多个 `.smx`，不新增跨插件 native/forward API。
- 不将旧版 `smlib`、`socket` 或其他依赖升级为 SourcePawn 1.12 语法；1.12 兼容性是后续独立迁移任务。
- 不清理或修改 `D:\Windows\Download\L4D_GunGame`，该目录只作只读依赖和版本参考。
- 不处理与 Gun Game 无关的仓库文件、服务器配置或公开发布流程。

## Architecture

SourcePawn include 是同一编译单元的文本组合，因此模块之间不通过运行时加载通信。模块只拥有自己的函数实现；共享数组、句柄、常量和枚举集中声明一次，生命周期回调集中注册一次，再路由到模块处理函数。

实际目录使用 `addons/sourcemod/scripting/gungame/` 及其 `weapons/` 子目录，避免与仓库已有的独立 `scripting/modules/*.sp` 插件混淆。

```text
L4D2_NEW_GG_3_9_2026_CN.sp
  |-- 00_shared.inc       常量、枚举、公共辅助、武器/地图元数据
  |-- 01_state.inc        全局状态、定时器、玩家/回合状态初始化
  |-- 02_compat_l4d2.inc  L4D2 地图、Tank 类别、gamedata/SDK 包装
  |-- 10_lifecycle.inc    Plugin/Map/Client/Entity/GameFrame 入口与注册
  |-- 20_round.inc        回合、地图、复活、队伍、机器人、Tank 控制
  |-- 30_combat.inc       伤害、击杀、Witch、等级推进、死亡处理
  |-- 40_weapon_core.inc  武器等级分发、拾取、开火路由、玩家输入
  |-- weapons/*.inc       特殊武器实体、追踪、碰撞、特效和清理
  |-- 50_vote.inc         玩家投票、模式投票、地图投票
  |-- 60_ui.inc           HUD、菜单、排名面板、管理员面板、音效提示
  |-- 70_persistence.inc  玩家排名、地图排名、KeyValues 文件读写
  |-- 80_network.inc      Socket 服务器查询、下载提示和回调
  `-- 90_legacy_tools.inc 压力测试、坐标记录和原有维护命令
```

## Module Ownership

| 模块 | 唯一职责 | 主要兼容约束 |
| --- | --- | --- |
| `00_shared.inc` | 共用常量、枚举、地图/武器名称、实体和字符串辅助 | 保留已有索引、数组大小和翻译键 |
| `01_state.inc` | 玩家、回合、排名、定时器和特效句柄的单一声明及重置 | 禁止重复声明或改变默认值 |
| `02_compat_l4d2.inc` | L4D2 特有地图、Tank 类别、签名调用和引擎包装 | 当前 L4D2 Tank 类别为 8；未来移植只替换此边界 |
| `10_lifecycle.inc` | 唯一的公共生命周期回调、事件/Hook/命令注册、资源预缓存 | 不重复注册 Hook，不改变启动失败条件 |
| `20_round.inc` | 地图切换、回合开始/结束、复活、队伍和机器人/Tank 控制 | 保留模式 0-6 和现有地图流程 |
| `30_combat.inc` | 伤害、Witch、击杀、等级、死亡和奖励推进 | 保留伤害/死亡链路和击杀排名顺序 |
| `40_weapon_core.inc` | 当前等级武器选择、分发、拾取限制和通用开火入口 | 保留 29 个武器索引及 `weapon_fire` 行为 |
| `weapons/*.inc` | 按效果族拆分特殊武器实现，并提供统一清理入口 | 保留实体 classname、计时器和碰撞行为 |
| `50_vote.inc` | 玩家投票、模式/地图投票、冷却与投票菜单回调 | 保留 ConVar 名称、投票阈值和结果动作 |
| `60_ui.inc` | 排名/HUD/管理面板、提示音和语音提示 | 保留面板顺序、翻译键和用户可见文本 |
| `70_persistence.inc` | `rank`/`map_rank`/坐标数据的读写和排序 | 保留文件格式、SteamID 键和写入时机 |
| `80_network.inc` | Socket UDP 查询、服务器列表和下载进度 | 保留失败回调与客户端提示，不新增外连目标 |
| `90_legacy_tools.inc` | 原有测试、压力测试、坐标存储和维护辅助 | 第一阶段只搬移，不改变可用性或权限 |

特殊武器按行为族拆分，避免 29 个微型模块互相引用：投射物/追踪类、光束/射线类、火焰/爆炸类、陷阱/实体类和 Tank/环境类。若某个武器同时依赖多个效果族，武器入口归 `40_weapon_core.inc`，实体生命周期仍由其唯一效果模块负责。

## Data Flow

1. SourceMod 调用入口文件中的唯一 `OnPluginStart`；入口初始化共享状态、L4D2 兼容包装，然后调用各模块初始化函数。
2. 生命周期模块完成事件、命令、UserMessage 和 SDKHook 注册；公共回调只作为路由，不在入口中复制业务逻辑。
3. 回合/玩家事件进入 `round` 或 `combat` 模块；等级变化通过共享状态通知武器分发和 UI/统计模块。
4. `weapon_fire`、玩家输入、实体碰撞和定时器回调进入武器核心或对应效果族；所有创建的实体和计时器必须由同一效果模块登记并清理。
5. 用户投票和管理员面板只改变既有状态/命令；持久化模块在原有回合/地图时机写入 KeyValues，网络模块只负责已有 Socket 查询与进度提示。

## Interface Rules

- 现有全局变量和公共回调名称在第一阶段保持不变；新建模块函数使用 `GG_` 前缀，减少未来命名冲突。
- 任何事件、命令、UserMessage、SDKHook 和实体销毁路径只能有一个 owner。其他模块通过 `GG_On...` 路由函数接收通知。
- 共享状态只在 `01_state.inc` 声明和重置；模块不得自行创建同名数组、句柄或替代状态。
- 定时器回调保留其原有数据参数和 `TIMER_FLAG_NO_MAPCHANGE` 语义；迁移时同步检查客户端、实体引用和句柄有效性。
- 模块拆分不引入新的 fallback、重复 Hook 或兼容分支；若必须引入适配器，必须在同一任务中说明旧 owner 的收敛或退场条件。

## Error Handling

- 缺失 `l4d_takeover`、复活或武器 gamedata 时保留原有 `SetFailState`/禁用行为，不静默降级。
- 实体引用、客户端、句柄、KeyValues 文件和 Socket 状态沿用现有保护；拆分不得把清理逻辑留在原单体路径之外。
- 地图结束时由生命周期模块触发所有模块的清理入口；特殊武器模块必须取消自己的玩家定时器、实体 Hook 和实体句柄。
- Socket 错误继续通过已有回调反馈到状态和日志；不把网络失败转换为阻塞启动错误。

## Verification

### 编译基线

当前源码已用备份目录中的 SourcePawn 1.6 编译器成功编译，存在历史 warning；这是第一阶段保持旧语法兼容的基线。项目 SourcePawn 1.12 编译器目前会在旧版 `smlib` 上报保留字和旧 enum struct 错误，因此不能把“模块拆分成功”和“1.12 迁移成功”混为一个验收条件。

每个拆分批次都运行旧编译器，输出到临时目录，不写入公开插件目录。最终至少验证：

- 编译退出码为 0，并生成单一 `L4D2_NEW_GG_3_9_2026_CN.smx`。
- `public` 生命周期入口、注册的命令和 ConVar 名称没有重复或遗漏。
- 29 个武器枚举、资源预缓存调用、数据文件路径、gamedata 名称和翻译加载键仍存在。
- 原始单体实现不再与拆出的模块同时编译，避免重复函数、变量和 Hook owner。
- `git diff --check` 通过；付费源码及模块路径仍处于本地私有排除/未发布边界。

### 回归与人工验证

静态回归覆盖符号、字符串和编译契约；运行时需要在 L4D2 服务器手动验证主流程：加载插件、加入/离开、回合开始、武器升级、特殊武器使用、死亡/复活、Witch/Tank/机器人控制、玩家投票、管理员面板、排名写入、地图切换以及 Socket/下载提示。当前工作区没有可自动启动的 L4D2 专用服务器，因此真实实体物理、网络下载和客户端 HUD 仍属于后续人工验证范围。

## Compatibility Boundary

必须保持以下外部可观察行为：

- 插件继续以一个 `.smx` 加载，插件名、版本和加载顺序不变。
- 现有 `sm_*` 命令、`gg_*` ConVar、翻译短语、KeyValues 数据格式和 gamedata 文件名不变。
- 模式 0-6、L4D2 地图列表、结局/生还地图判断、Tank 类别 8、玩家队伍切换和复活 SDK 调用保持不变。
- 29 个武器的等级顺序、武器实体、特效、伤害、声音、资源路径和清理时机保持不变。
- 现有启动失败条件、Socket 失败日志、客户端下载提示和管理员权限行为保持不变。

未来 L4D/L4D2 兼容差异必须优先落在 `02_compat_l4d2.inc`、地图/资源元数据和必要的 gamedata 适配中；不得为了移植在每个武器和战斗分支中复制游戏判断。

## Repair Track

- **Root cause:** 业务、生命周期、实体效果、UI、持久化和网络逻辑共享一个 2 万行编译单元，修改边界和清理责任不清晰。
- **Canonical owner:** 新的 `gungame/` include 模块按职责拥有实现；入口文件只保留装配和唯一生命周期路由。
- **Smallest change:** 先做保持函数语义的搬移与路由，再单独处理命名、状态封装或 1.12 语法升级。
- **Compatibility:** 外部命令、ConVar、资源、数据格式、事件顺序和一个 `.smx` 的运行时边界不变。
- **Verification:** 每批次旧编译器编译、静态符号契约、差异检查，最终由 L4D2 服务器手动走主流程。

## Retirement Track

- **Retired object:** 原入口文件中被搬移的重复实现区块。
- **Action:** 搬移后从入口单体正文删除，入口只 include 一个 canonical owner；不保留旧实现副本或兼容 fallback。
- **Retained boundary:** 原插件文件名、`.smx` 产物名、公开命令/ConVar/资源和运行时 Hook 仍保留。
- **Trigger for future cleanup:** 当模块拆分和 L4D2 运行时回归完成后，才可评估 `newdecls`、1.12 依赖升级或进一步状态封装；这些不属于本阶段。

## Facts, Assumptions, Unknowns

### Facts

- 当前私有源码约 20,112 行、596 KB；工作区中的文件与指定备份目录的 2026 L4D2 版本 SHA-256 一致。
- 源码包含约 163 次 `PrecacheSound`、67 次 `PrecacheModel`、45 次 `PrecacheParticle`、166 个定时器创建点、20 个事件 Hook、60 个 SDKHook 点、15 个控制台命令、4 个管理命令和 11 个 ConVar。
- 备份目录提供旧 SourcePawn 1.6 编译器、`smlib`/`socket` 头文件、`gungame.phrases.txt`、`l4d_takeover.txt`、`l4drespawn.txt` 和 `gg_weapons.txt` 等参考依赖。

### Assumptions

- SourcePawn 编译器将 include 文件组合为一个编译单元，允许模块共享同一组全局声明和函数符号。
- 第一阶段可以通过保留旧语法和旧依赖，先获得结构拆分的编译证据。
- 用户接受设计文档和后续实现只保留在本地工作区，不进行远程 Git 操作。

### Unknowns

- 当前工作区没有可供自动化运行的 L4D2 服务器，拆分后真实实体碰撞、声音、HUD、客户端下载和 Socket 行为尚未自动验证。
- SourcePawn 1.12 迁移所需的现代 `smlib`/颜色头文件和旧 API 替换范围，需另建迁移任务后评估。
- 某些原有函数存在跨区域隐式依赖；正式拆分时需由逐批编译和符号检查确认实际 include 顺序。

## Working Drafts

- **TaskIntentDraft:** 在不改变 Gun Game 外部行为的前提下，把付费 L4D2 插件拆成可定位、可独立检查的 include 模块，并为未来游戏差异迁移保留集中边界。
- **BaselineReadSetHint:** `AGENTS.md`、`README.md`、`Docs/aegis/README.md`、目标源码、现有 `scripting/modules/` include 模式、指定备份目录中的同版本源码/编译器/依赖和当前 Git 状态。
- **ImpactStatementDraft:** 影响一个私有 SourcePawn 编译单元及其本地构建依赖；运行时产物仍为单一 Gun Game `.smx`。最大风险是跨模块全局状态、计时器/实体清理和公共 Hook owner 重复。
