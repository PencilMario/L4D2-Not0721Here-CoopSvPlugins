# Survivor Bot AI Trace/VProf 分析与解决计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 `战役-console (3).txt` 和 `战役-console (4).txt`，解释 `l4d2_sb_ai_improver` CPU 占用高的直接原因，并以 `ib_process_time` 为一般缓存周期，分阶段降低 `OnPlayerRunCmd`、Trace 和 `Base_TraceFilter` 成本。

**Architecture:** 保留 `l4d2_sb_ai_improver.sp` 作为组合根，优化分别归属 `runtime.inc`（调度）、`perception.inc`（LOS/Trace）、`state.inc`（缓存状态）和 `entity_registry.inc`（实体分类及失效）。先补按调用用途统计的 Trace 观测，再优化调用数量，最后优化过滤回调本身；不把 `Base_TraceFilter` 的缓存当成 Trace 结果缓存的替代品。

**Tech Stack:** SourcePawn 1.12、SourceMod SDKTools、Left4DHooks、VProf、PowerShell 合同测试。

**Baseline / Authority Refs:** `AGENTS.md`；`D:\Windows\Download\战役-console (3).txt`；`D:\Windows\Download\战役-console (4).txt`；`addons/sourcemod/scripting/l4d2_sb_ai_improver/{runtime,perception,state,entity_registry,bot_think,navigation}.inc`；用户确认“一般计算周期/缓存过期条件使用 `ib_process_time`”。

**Compatibility Boundary:** 不改变公开 ConVar、native/forward、Bot 决策优先级和门的阻挡语义。一般查询缓存使用 `GetProcessCacheExpiry()`；实体销毁/索引复用、换图及门状态事件可提前失效。瞄准点和投掷碰撞等逐帧动作 Trace 只允许同一 command/frame 去重，不允许直接复用最长 0.2 秒的旧结果。

**Verification:** 静态合同测试 + SourcePawn 编译 + 固定战役条件下重新采样；验收以每帧/每次 RunCmd 的归一化指标为主，不比较累计毫秒。

---

## 1. VProf 证据

两份采样时长不同：`(3)` 为 742 帧，`(4)` 为 1100 帧，因此累计调用数不能直接比较，必须使用 `Calls/Frame`、`Avg/Frame` 和 `Avg/Call`。

| 指标 | `(3)` | `(4)` | 变化 |
|---|---:|---:|---:|
| `CEngine::Frame` 平均 | 57.959 ms/frame | 67.397 ms/frame | +16.3% |
| `OnPlayerRunCmd` 调用 | 81.714/frame | 94.751/frame | +16.0% |
| `OnPlayerRunCmd` 含子项 | 18.694 ms/frame | 23.793 ms/frame | +27.3% |
| `OnPlayerRunCmd` 平均单次 | 0.229 ms | 0.251 ms | +9.6% |
| `OnPlayerRunCmd` self | 14.02% | 15.71% | 增加 1.69 pct |
| `Base_TraceFilter` 调用 | 1955.210/frame | 3361.461/frame | +71.9% |
| `Base_TraceFilter` self | 0.582 ms/frame | 0.983 ms/frame | +68.9% |
| 每次 RunCmd 对应 filter 回调 | 23.93 | 35.48 | +48.3% |
| `TraceRayAgainstLeafAndEntityList` | 3.272 ms/frame | 3.504 ms/frame | +7.1% |
| `EnumerateElementsAlongRay` | 3.533 ms/frame | 4.538 ms/frame | +28.4% |
| `NavAreaBuildPath` | 0.333 ms/frame | 0.460 ms/frame | +38.1% |

结论：`(4)` 的总负载更高，但插件退化不只是采样更长或 RunCmd 更多。RunCmd 频率只增加 16%，`Base_TraceFilter` 每帧却增加 72%，且每次 RunCmd 对应过滤回调增加 48%。这表明新场景中每次决策触发了更多 Trace，或每条射线穿过了更多候选实体；两者共同放大 SourcePawn 回调开销。

## 2. 为什么插件占用高

### 2.1 高频入口把所有成本乘以 Bot command rate

`runtime.inc:78` 的 `OnPlayerRunCmd` 是顶层入口。采样 `(4)` 中它每帧执行 94.751 次，含子项占总采样 33.58%，self 占 15.71%。`SurvivorBotThink` 由该入口直接调用，战斗、感知、拾取、救援、导航都挂在这条路径下。因此即使单个 SourcePawn 判断很便宜，也会被客户端数、tickrate 和 Bot 数相乘。

`Base_TraceFilter` 只解释其中约 1.39% 的直接 self 时间，不能把全部 33.58% 都归因于过滤器。真正的根因是高频入口中存在重复的实体枚举、可见性判断、native/property 查询和 Trace；过滤器是最清晰的放大结果之一。

### 2.2 当前实体可见性缓存容量不足，容易发生循环扫描抖动

`state.inc:17` 的 `VISIBILITY_CACHE_SIZE` 只有 8；`perception.inc:388` 每次命中需要线性扫描 8 槽。`GetClosestInfectedImpl` 等函数会在一轮中遍历超过 8 个 common infected。第 9 个目标会覆盖第 1 个目标，下一次扫描又从第 1 个开始，形成典型 round-robin cache thrashing。缓存虽已按 `GetProcessCacheExpiry()` 过期，但容量/索引方式使许多条目在 TTL 到期前就被覆盖。

此外缓存只覆盖 `IsVisibleEntity`，且只对生还者 Bot 启用。`IsVisibleVector`、`GetVectorVisible` 和 `GetClientAimPosition` 仍然每次直接调用 `TR_TraceRayFilterEx`。

### 2.3 单次实体 LOS miss 最多产生三条 Trace

`TraceVisibleEntity` 依次检查目标 origin、view offset、centroid。首次命中只需一次 Trace，但不可见目标或前两个点被挡时需要两到三次。大量目标扫描时，远处/被遮挡目标恰好是多数，因此 miss 路径比 hit 路径更贵。当前缓存能复用最终结果，但容量抖动后相同 miss 会再次支付三条 Trace。

### 2.4 向量可见性路径未共享结果，部分循环一次候选做两条 LOS

`GetInfectedCounts` 和 `GetInfectedCountImpl` 对可见候选先调用 `IsVisibleVector(client eye -> infected centroid)`，随后又调用 `GetVectorVisible(client centroid -> infected centroid)`。这是两个不同起点，语义上不是完全相同的射线，但都位于 common infected 的循环内部，且两条路径都没有缓存。只要候选通过第一条 LOS，就必然继续执行第二条。

`GetClientAimPosition` 也被 aiming/weapons 路径调用；相同 client、相同 command 和相同眼角度下可安全共享一次结果，但当前没有 command-local cache。

### 2.5 `Base_TraceFilter` 在每个候选实体上重复做属性和 native 查询

当前实现：

```sourcepawn
return (iEntity == iData
    || HasEntProp(iEntity, Prop_Data, "m_eDoorState")
    && L4D_GetDoorState(iEntity) != DOOR_STATE_OPENED);
```

一次 Trace 会枚举多个实体，每个候选都跨 JIT 调用 SourcePawn filter。除目标实体外，每次都调用 `HasEntProp`；对门还继续调用 `L4D_GetDoorState`。`(4)` 中该回调达到 3361.461 次/frame。即使平均单次小于显示精度，累计仍为 0.983 ms/frame，峰值 6.427 ms。

过滤器真正需要的稳定信息只有“这个实体是不是门”；门的开关状态是动态信息。把两者每次一起查询是错误的成本分层。

### 2.6 Trace 的引擎成本不能靠缓存 filter 返回值完全消除

缓存 `Base_TraceFilter(entity)` 只能减少 `HasEntProp`/classname/native 成本，无法减少 `EnumerateElementsAlongRay`、碰撞树遍历和 filter 被调用的次数。`(4)` 中 `EnumerateElementsAlongRay` 为 4.538 ms/frame，明显高于 filter 的 0.983 ms/frame。因此最高优先级必须是避免发起重复 Trace，其次才是让不可避免的 filter 回调走 O(1) 快路径。

## 3. 根因判断

**直接根因：** `OnPlayerRunCmd` 的高频决策循环对大量候选重复执行 LOS/Trace，而当前 8 槽可见性缓存无法容纳一次感染者扫描的工作集，向量 Trace 和同 command 瞄准 Trace 又未纳入共享。

**次级根因：** 每条 Trace 对命中的候选实体回调 `Base_TraceFilter`，该回调没有实体类型缓存，重复执行 `HasEntProp` 和门状态 native。

**架构原因：** 缓存按 helper 零散添加，而不是以“一次 Bot 计算周期”为共享查询上下文；调用方看不到本周期是否已经对同一个 `(observer, target/endpoints, mask)` 做过等价 Trace。

**Canonical owners:** `perception.inc` 负责 Trace/LOS 语义及结果缓存；`entity_registry.inc` 负责实体静态分类与生命周期失效；`state.inc` 只存状态；`runtime.inc` 负责建立 command/process 周期，不直接拥有 LOS 规则。

**未知项：** VProf 没有按 `IsVisibleEntity`、`IsVisibleVector`、`GetVectorVisible`、投掷和导航拆分 Trace 次数，所以目前不能严谨断言哪一个调用点占最大份额。Task 1 必须先补计数，不能直接删除 LOS 分支。

## 4. 缓存与失效规范

### 4.1 一般规则

- 查询结果写入时统一使用 `GetProcessCacheExpiry()`，其值为 `GetGameTime() + g_fCvar_NextProcessTime`，即 `ib_process_time`。
- 不新增 `ib_trace_cache_time`、固定 0.05/0.1 秒或另一套普通 TTL。
- 当 `ib_process_time` 改变时，不必批量改写旧 expiry；旧条目自然过期，新条目使用新值。若需要配置立即生效，可在现有 change hook 中清空 Trace cache，但不是正确性必需。
- `0.0` 只用于主动失效和生命周期重置。

### 4.2 cache key

实体 LOS key 至少包含：

```text
observer entref + target entref + contents mask + LOS mode
```

命中时还必须检查 observer eye position 和 target position 是否在 32 units 容差内。实体索引用 entref/version 校验，防止销毁后索引复用命中旧数据。

向量 LOS key 至少包含：

```text
start quantized position + end quantized position + contents mask + ray type
```

不要用字符串拼 key。使用定长结构和整数化坐标；一般缓存仍按 `ib_process_time` 过期。只缓存纯 LOS boolean/fraction，不缓存 Handle。

### 4.3 主动失效

- `OnEntityCreated`/`OnEntityDestroyed`：清除该 entindex/entref 的实体 LOS、实体分类和门状态缓存。
- `OnMapStart`/`OnMapEnd`：清空全部 Trace cache generation/expiry。
- client disconnect/team/spawn：清该 observer 的缓存。
- door open/close/break/lock/unlock：只失效该门的动态阻挡状态；即使事件遗漏，`ib_process_time` TTL 仍提供上限。
- 目标移动超过 32 units或 observer eye 移动超过 32 units：实体 LOS lookup 直接 miss，不等待 TTL。

### 4.4 不使用普通 TTL 的例外

- `GetClientAimPosition`：按同一 command/frame + eye angles 版本缓存，下一 command 强制失效；否则 0.2 秒旧瞄准点会影响射击。
- 手雷落地/天花板轨迹：只在同一次投掷求解中共享，不跨投掷周期缓存。
- 动态物理物体的精确碰撞 fraction/end position：除非 key 包含完整位置版本，否则不跨 frame 缓存。

这些是动作结果，不属于“一般计算周期”查询；其余普通感知/分类缓存均遵循 `ib_process_time`。

## 5. 实施计划

### Task 1: 建立 Trace 分类计数基线

**Files:** Modify `perception.inc`, `navigation.inc`, `bot_think.inc`, `debug.inc`, `state.inc`; create `tests/l4d2_sb_ai_trace_metrics.tests.ps1`.

**Repair Track:** 解决 VProf 只能看到总 filter 数、无法定位调用方的问题。所有 `TR_TraceRayFilterEx` 通过小型 wrapper 或在现有 helper 周围计数，类别固定为 `entity_los`、`vector_los`、`aim`、`grenade_ground`、`grenade_ceiling`、`nav_visible`。

**Retirement Track:** 计数稳定且两个固定场景采样完成后，可关闭详细 per-category 日志；累计 counter 保留在 `ib_performance_logging` 开关内，不进入默认热路径。

- [ ] 在 `state.inc` 增加每类 `attempt/cache_hit/cache_miss/trace_call/fallback_2/fallback_3/filter_callback` counter。
- [ ] 在 `Base_TraceFilter` 仅当性能日志开启时增加 callback counter。
- [ ] 每个 `ib_process_time` 周期汇总一次，不逐 Trace 写日志。
- [ ] 静态测试断言所有 10 个 `TR_TraceRayFilterEx` 调用点均被分类，日志关闭时 counter 分支不执行。
- [ ] 用 `(4)` 同类场景记录各类别比例；在数据出来前不改变三点 fallback 语义。

**Verification:** `pwsh -NoProfile -File tests/l4d2_sb_ai_trace_metrics.tests.ps1`；日志中满足 `trace_call <= attempt * 3`，并能解释总 Trace 的主要来源。

### Task 2: 将实体 LOS 缓存从 8 槽线性环改为固定容量哈希/组相联缓存

**Files:** Modify `state.inc`, `perception.inc`, `entity_registry.inc`, `events.inc`; modify `tests/l4d2_sb_ai_visibility_cache.tests.ps1`.

**Repair Track:** 修复 common infected 工作集大于 8 时的循环覆盖。推荐每 observer 64 槽、4-way set associative：hash 使用 target entref、mask 和 LOS mode，组内查 4 项；替换最早 expiry 项。容量比直接 `[client][entity][mask]` 小，查找从线性 8 次降为固定最多 4 次，也允许一轮扫描保留更多目标。

缓存条目字段：

```sourcepawn
observer serial (optional per-client generation)
target entref
mask
mode
expiry = GetProcessCacheExpiry()
result
observer eye position[3]
target position[3]
```

**Retirement Track:** 删除旧 `VISIBILITY_CACHE_SIZE 8` 环、`NextSlot` 和 8 槽线性查找；保留现有 `InvalidateVisibilityCacheEntity`/`ResetVisibilityCaches` API 名称，内部改为新结构，避免生命周期调用点分叉。

- [ ] 先增加合同测试：插入 32 个不同 target 后再次查询第 1 个，预期仍命中；不同 mask 不得误命中。
- [ ] 实现 hash/set 查找和最早过期/LRU 近似替换。
- [ ] expiry 一律写 `GetProcessCacheExpiry()`。
- [ ] 保留 32 units 的 observer/target position tolerance。
- [ ] 用 entref 校验 target，client serial/generation 校验 observer。
- [ ] 接入 create/destroy/map/client 生命周期失效。

**Verification:** 静态合同通过；固定场景 `entity_los cache_hit / attempt >= 70%`，并且 `Base_TraceFilter calls/frame` 相对 `(4)` 至少下降 30%。若命中率不足，先检查 hash 冲突/调用 mask 分裂，不先增加 TTL。

### Task 3: 为一般向量 LOS 增加 `ib_process_time` 缓存，并消除同周期等价 Trace

**Files:** Modify `state.inc`, `perception.inc`, `movement.inc`; create `tests/l4d2_sb_ai_vector_trace_cache.tests.ps1`.

**Repair Track:** `IsVisibleVector`/`GetVectorVisible` 使用共享 `GetCachedVectorVisible`。采用 128 槽全局或每 observer 32 槽缓存；key 使用 8-unit 网格量化的 start/end、mask、ray type，保存原始 start/end 再做容差复核，避免 hash 碰撞误命中。expiry 使用 `GetProcessCacheExpiry()`。

优先把有实体语义的调用改为 `GetCachedVisibleEntity`，不要把 entity target 降级成任意 vector key。`GetInfectedCounts`/`GetInfectedCountImpl` 保留两起点语义，但同一周期相同 helper/candidate 的结果可共享；删除第二条 LOS 必须等行为对照证明等价后单独实施。

**Retirement Track:** `IsVisibleVector` 和 `GetVectorVisible` 名称保留为兼容 wrapper；直接创建 Trace Handle 的逻辑集中到一个 impl，防止新增第三个缓存 owner。

- [ ] 写相同端点/相同 mask 命中、不同 mask miss、移动超容差 miss、expiry 后 miss 的合同测试。
- [ ] 实现结构化 hash，不使用字符串 Trie key。
- [ ] 将 `GetFarthestInfected`、infected count、movement LOS 接入 wrapper。
- [ ] entity 已知的调用点优先传 entity LOS helper。
- [ ] 记录 vector cache hit rate 和避免的 Trace 数。

**Verification:** `vector_los` Trace 数下降至少 50%；common infected 数量和 melee/投掷选择在固定回放场景中与基线一致。

### Task 4: 把 `Base_TraceFilter` 改成 O(1) 实体分类快路径

**Files:** Modify `state.inc`, `entity_registry.inc`, `perception.inc`, `events.inc`; create `tests/l4d2_sb_ai_trace_filter_cache.tests.ps1`.

**Repair Track:** 将稳定的“是否为门”分类从过滤回调移到 `OnEntityCreated`/首次查询。推荐状态：`TRACE_ENTITY_UNKNOWN`、`TRACE_ENTITY_IGNORE`、`TRACE_ENTITY_DOOR`，另存 entref 防索引复用。普通实体回调只需数组读取并返回 false；目标实体先返回 true；只有门才查询动态阻挡状态。

门状态使用：

```text
door entref + blocked/open result + expiry(GetProcessCacheExpiry)
```

门 open/close/break 事件提前把该门 expiry 设为 `0.0`；事件缺失时最迟在 `ib_process_time` 后刷新。不要长期缓存 `L4D_GetDoorState`，也不要把门的动态状态混入永久实体类别。

**Retirement Track:** 从 `Base_TraceFilter` 移除每 callback 的 `HasEntProp`；`HasEntProp` 只允许在实体登记/unknown slow path 使用。unknown slow path 解析后必须写分类，不能每次仍返回 unknown。

- [ ] 建立 entity classification arrays 和 entref guard。
- [ ] `OnEntityCreated` 用 classname 快速标记 `prop_door*`/`func_door*`，不确定类型才调用一次 `HasEntProp`。
- [ ] `OnEntityDestroyed` 清分类、entref、门状态和 expiry。
- [ ] `Base_TraceFilter` 顺序固定为 target fast hit -> world/invalid handling -> class lookup -> door state lookup -> false。
- [ ] 门状态 cache expiry 使用 `GetProcessCacheExpiry()`。
- [ ] 合同测试覆盖普通实体、关闭门、打开门、目标实体和 entindex 复用。

**Verification:** 在 Trace 数相同的 A/B 场景中 `Base_TraceFilter Avg/Call` 或 `self ms/frame` 至少下降 40%；若只降低 filter self 而 Trace 总成本不降，视为预期，继续依赖 Task 2/3 减少调用量。

### Task 5: 同 command 精确 Trace 去重与三点 fallback 分层

**Files:** Modify `runtime.inc`, `state.inc`, `perception.inc`, `aiming.inc`, `weapons.inc`; modify trace metric tests.

**Repair Track:** `GetClientAimPosition` 按 client + command generation + eye position/angles 缓存 end position，同 command 多调用只 Trace 一次。该缓存不用 `ib_process_time` 跨 command 复用。

在 Task 1 数据证明 fallback 是主要来源后，按实体类型调整三点顺序：common infected 先 centroid；client 先 eye/view offset；Tank rock/prop 使用 centroid。仍保留最多三个点的旧 fallback 作为第一阶段兼容边界。第二阶段只有在“第二/第三 fallback 命中率低于 1%，但占 Trace 超过 15%”时，才把低价值 fallback 限制到当前攻击目标或近距离目标。

**Retirement Track:** aim Trace 的多个直接 owner 收敛到 `GetClientAimPosition`；fallback 分支是否删除由采样阈值决定，不能凭代码直觉提前删除。

- [ ] 为每 client 增加 command generation 和 aim trace result。
- [ ] RunCmd 开头推进 generation；同 generation 且 angles/eye 不变则命中。
- [ ] 统计 fallback 2/3 的调用与最终命中次数。
- [ ] 仅在阈值满足后限制低价值 fallback，并逐项做行为 A/B。

**Verification:** `aim trace_call <= entered_bot_think`；三点 LOS 的最终 visible 结果、开火选择、witch/Tank rock 处理无可观察回归。

### Task 6: 编译、回归和 VProf 验收

**Files:** Modify/create relevant `tests/*.tests.ps1`; update this work item with `50-evidence.md` after runtime test.

- [ ] 逐 Task 运行专项合同，避免一次合入所有缓存后无法归因。
- [ ] 运行全部 PowerShell 测试。
- [ ] 使用项目 SourcePawn 1.12 编译器和 include 路径编译 `l4d2_sb_ai_improver.sp`。
- [ ] 固定地图、难度、tickrate、总玩家/生还者 Bot 数、common infected 压力和采样帧数，至少采样 1000 帧。
- [ ] 同时报原始值和归一化值：RunCmd calls/frame、ms/call、ms/frame；每类 Trace attempts/hits/misses；Base filter callbacks/frame；Trace engine ms/frame；P95/P99/peak。
- [ ] 逐阶段对比，任何行为回归只回滚最近一个 Task。

```powershell
Get-ChildItem tests/*.tests.ps1 | Sort-Object Name | ForEach-Object {
    pwsh -NoProfile -File $_.FullName
}

& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\l4d2_sb_ai_improver.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\l4d2_sb_ai_improver.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

最终性能验收门槛（相对 `(4)` 同条件）：

| 指标 | 基线 | 目标 |
|---|---:|---:|
| `Base_TraceFilter` calls/frame | 3361.461 | <= 2353（-30%） |
| `Base_TraceFilter` self ms/frame | 0.983 | <= 0.45（约 -54%） |
| `OnPlayerRunCmd` Avg/Call | 0.251 ms | <= 0.200 ms（-20%） |
| `OnPlayerRunCmd` Avg/Frame | 23.793 ms | 在相同 calls/frame 下 <= 19.0 ms |
| entity LOS cache hit rate | 未知 | >= 70% |
| vector LOS Trace 数 | 未知 | 相对 Task 1 基线 -50% |
| 峰值 | 91.737 ms | P99/peak 必须单独报告，且 peak 不得恶化 |

## 6. 实施顺序与停止条件

顺序必须是 `观测 -> 减少 Trace -> filter 快路径 -> 精确动作去重 -> 行为验证`。不要先微优化 `HasEntProp` 后就宣称 Trace 问题解决。

每完成一个 Task 就复测；若某 Task 对对应指标改善低于 10%，停止继续扩大该方案，使用 counter 查明 miss 原因。若连续三个优化尝试都没有改善，回到架构层检查 RunCmd 调度和感知工作集，而不是继续叠加缓存。

## 7. 结论可信度

- **事实置信度 A：** VProf 中 RunCmd、filter、Trace 引擎和导航的调用/耗时数据；源码中的 8 槽缓存、三点 fallback、未缓存向量 Trace、filter 属性/native 查询。
- **根因置信度 B：** “缓存抖动 + 未共享 Trace”由源码和归一化回调增长强烈支持，但缺少按调用用途拆分的 runtime counter。
- **优化收益置信度 B/C：** filter 分类快路径收益方向明确；具体 Trace 减少比例必须由 Task 1 和固定场景复测确认。
