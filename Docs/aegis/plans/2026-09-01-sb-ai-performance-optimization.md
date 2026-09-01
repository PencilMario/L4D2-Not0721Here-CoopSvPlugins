# Survivor Bot AI 性能优化计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 根据 `D:\Windows\Download\战役-console (1).txt` 的服务器性能采样，降低 `l4d2_sb_ai_improver` 在生还者 Bot 高频执行路径中的 CPU 和 Trace 开销，同时保持 Bot 决策行为、Left4DHooks 接口和现有配置兼容。

**架构：** 保留 `l4d2_sb_ai_improver.sp` 的组合根和现有 include 顺序。先为 `OnPlayerRunCmd`/`SurvivorBotThink` 增加可分段观测，再把每 tick 固定工作与低频感知工作分离；对视线 Trace、感染者枚举、物品扫描和导航查询使用已有缓存/实体注册表扩展，避免在高频回调中重复计算。

**技术栈：** SourcePawn 1.12、SourceMod SDKTools/SDKHooks、Left4DHooks、现有 PowerShell 静态测试、项目 `spcomp.exe`。

**基线/权威引用：**
- `AGENTS.md`：唯一已知的 SourcePawn 编译器和 include 路径。
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/README.md`：组合根、include 顺序和模块所有权边界。
- `runtime.inc`、`bot_think.inc`、`perception.inc`、`navigation.inc`、`scavenging.inc`、`entity_registry.inc`：对应运行、决策、感知、导航、物品和实体索引实现。
- 日志证据：`OnPlayerRunCmd` 总 8810.711 ms / 28941 次，占采样 21.97%，平均 0.304 ms、峰值 54.131 ms；`Base_TraceFilter` 911560 次、288.981 ms；`OnMoveToIncapacitatedFriendAction` 5689 次、51.044 ms；`OnEntityCreated` 613 次、2.184 ms，`OnEntityDestroyed` 590 次、4.532 ms。

**兼容性边界：** 不改变 ConVar 名称/默认值、公开 native/forward、Bot 决策优先级、实体分类、救援/战斗安全条件和 include 顺序。缓存必须在客户端、地图、武器、目标或实体销毁时失效；性能日志关闭时不得增加持续性日志或高频计时开销。

**缓存时限规则：** 所有新增或重构的查询缓存统一通过 `GetProcessCacheExpiry()` 计算过期时间，该 helper 使用 `ib_process_time`（`g_fCvar_NextProcessTime`）。`0.0` 仅用于主动失效/生命周期重置；投掷冷却、换枪阻塞、视觉注意记忆等行为计时器不属于查询缓存，继续使用各自语义时长。

**验证：** 每个切片运行对应 PowerShell 静态测试；最终使用 `AGENTS.md` 中的 `spcomp.exe` 编译，运行全部 `tests/*.tests.ps1`，并用同一战役场景重新采样比较 RunCmd、Trace 和救援耗时。

---

## 事实、假设与未知

- **事实：** `OnPlayerRunCmd` 对所有客户端先更新位置/导航，再对生还者扫描库存；`g_fBotProcessing_NextProcessTime` 只分摊部分感知计算。
- **事实：** `GetClosestInfected`、`GetInfectedCounts`、可见性函数、救援动作和投掷轨迹会触发大量 Trace；过滤器自身不贵，但调用次数很高。
- **假设：** 日志代表真实战役压力；未假设特定地图或 Bot 数量。
- **未知：** 现有采样未拆分 `SurvivorBotThinkImpl` 阶段，也未给出 `ib_next_process_time`、缓存命中率和每帧 Bot 数，必须先补观测。

## 优先级总览

| 优先级 | 工作线 | 文件 | 目标 |
|---|---|---|---|
| P0 | 分段观测与调度基线 | `debug.inc`, `runtime.inc`, `bot_think.inc`, `state.inc` | 找出 54 ms 尖峰来源 |
| P1 | RunCmd 固定成本 | `runtime.inc`, `state.inc`, `convars.inc` | 减少每 tick 快照和重复 native |
| P1 | 感知/Trace 合并 | `perception.inc`, `navigation.inc`, `bot_think.inc` | 减少约 91 万次过滤器调用 |
| P2 | 实体/物品扫描 | `entity_registry.inc`, `scavenging.inc` | 降低线性查找和扫描尖峰 |
| P2 | 救援动作去重 | `rescue.inc`, `actions.inc`, `state.inc` | 降低 5689 次救援动作成本 |
| P3 | 回归和采样门槛 | `tests/`, 证据文档 | 证明收益并可回滚 |

## 实施任务

### Task 1: 建立可比较的性能基线

**文件：** 修改 `debug.inc`、`runtime.inc`、`bot_think.inc`、`state.inc`；新增 `tests/l4d2_sb_ai_performance_budget.tests.ps1`。

- 将 `SurvivorBotThink` 计时拆成快照、共享感知、决策、Trace/导航、物品扫描、救援六类阶段；仅在 `ib_performance_logging=1` 且超过阈值时记录。
- 记录 Bot 数、每阶段耗时、每次 RunCmd 是否进入 Bot think，区分非 Bot 客户端成本。
- 静态测试检查标记、默认关闭分支和日志字段稳定，不依赖游戏服务器。
- **验证：** `pwsh -File tests/l4d2_sb_ai_performance_budget.tests.ps1`；编译并确认日志关闭时无新增输出。

### Task 2: 收紧 `OnPlayerRunCmd` 固定工作

**文件：** `runtime.inc`、`state.inc`、必要时 `convars.inc`。

- 最早返回非生还者、非 Bot、`sb_stop`、过场或未初始化状态；保留影响引擎 forward 的必要状态更新。
- 将位置、眼睛位置、中心点、武器槽和弹药读取按独立 expiry 分组；位置未变且未到期时不重复 native 调用。
- 在单次回调缓存 `GetGameTime()`、当前武器、团队计数和状态判断。
- 不延后正在进行的救援/投掷状态机；目标选择、开火、换武器和按钮写入仍按原决策频率执行。
- **验收：** 现有模块/日志测试通过；同场景 RunCmd 平均耗时下降，反应延迟无明显回归。

### Task 3: 合并感知查询并减少视线 Trace

**文件：** `perception.inc`、`navigation.inc`、`bot_think.inc`。

- 为 Bot/实体建立短 expiry 可见性缓存，key 包含 Bot、实体、mask、FOV 模式和目标位置版本；销毁、目标切换、换图时失效。
- 在感染者、Tank/witch/prop 扫描之间共享位置、距离和可见性结果，同一阶段禁止重复 `IsVisibleEntity`。
- 对 `IsVisibleEntity` 三点 fallback 增加失败短期记忆和实体类型限制，保持原命中判定。
- `Base_TraceFilter` 保持门/目标逻辑，不加入昂贵查询；由调用方减少 Trace。
- **验收目标：** `Base_TraceFilter` 调用次数下降至少 30%，RunCmd 平均耗时下降至少 20%；若反应变慢，缩短 expiry 而不是移除安全检查。

### Task 4: 优化实体注册表和物品扫描

**文件：** `entity_registry.inc`、`scavenging.inc`、`state.inc`。

- 以实体类别 bitmask 或等价登记替代 `PushEntityIntoArrayList` 的重复 `FindValue`；同一生命周期只登记一次。
- `OnEntityDestroyed` 按实体所属 mask 删除，避免每次销毁扫描全部列表；保留 EntRef 校验。
- `GetItemFromArrayListImpl` 先做 weapon id/flags/距离粗筛，再做可达性、可见性和导航查询；清理失效 EntRef 时同步移除。
- 将 `CheckForItemsToScavenge` 的多次列表查询合并为一次候选选择，保持现有优先级和 `ib_grab_*` 语义。
- **兼容性验证：** 拾取优先级、CSS 武器拒绝、弹药占用、checkpoint 和 Tank 安全条件合同测试通过；列表长度不增长。

### Task 5: 救援动作专项去重

**文件：** `rescue.inc`、`actions.inc`、`state.inc`。

- 以被控生还者、救援者、pinned/incap 状态和 nav 位置版本缓存救援候选与危险路径；状态变化、移动超过阈值或 expiry 到期才重算。
- `OnMoveToIncapacitatedFriendAction` 先使用缓存的距离/可见性/可达性，再创建或更新移动 Action。
- 保留 Tank、acid、checkpoint、ledge、finale 等拒绝条件；缓存只覆盖纯查询结果。
- **验收目标：** Action 平均耗时下降 30%，峰值不超过 1 ms；救援成功率和取消条件与基线一致。

### Task 6: 回归、编译和发布门槛

**文件：** `tests/*.tests.ps1` 和本计划的证据记录。

- 运行全部现有和新增 PowerShell 测试。
- 使用 `AGENTS.md` 指定命令编译 `l4d2_sb_ai_improver.sp`，必须出现 `Compilation successful.`；接受已知旧警告。
- 用 `git diff --check` 检查格式；固定战役、难度、人数、采样时长，比较 RunCmd 平均/P95/P99、Trace 次数、救援耗时和行为结果。
- 任一行为回归无法解释时，只回滚最近一个切片，不合并多个未验证缓存。

```powershell
Get-ChildItem tests/*.tests.ps1 | ForEach-Object { pwsh -File $_.FullName }
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\l4d2_sb_ai_improver.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\l4d2_sb_ai_improver.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
git diff --check
```

## 退役轨迹与非目标

- 保留现有全局、导航、视觉记忆缓存和 `LogSlowCalculation`；收缩 RunCmd 全量快照、逐列表深搜和无条件三次可见性 fallback。
- 新阶段计时连续两个真实战役采样窗口稳定后，删除临时 debug 字段和迁移计时；此之前不删除旧日志入口。
- 不重写 NextBot 行为树、不更换 Left4DHooks native、不调整 Bot 难度/武器策略、不把 Trace 放到异步线程。

## 剩余风险

- expiry 过长会增加视觉/救援延迟，必须联合性能和行为指标调参。
- 新缓存必须接入 `OnMapStart`、`OnMapEnd`、`OnEntityDestroyed`，防止跨地图脏数据。
- 采样受地图、Bot 数量和其他插件影响，前后必须固定测试条件，不能只比较单次峰值。
