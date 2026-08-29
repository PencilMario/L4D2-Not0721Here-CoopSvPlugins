# L4D2 喷吐者粘液与汽油桶技能替换设计

## 目标

将 `cfg/cfgogl/versus_isfullshit` 当前加载的 `L4D2 Spitter Supergirl` 替换为一个全新插件。新插件只服务于该配置，提供两条互相独立的玩法：

1. 喷吐者存活时持续生成可见的原生 `spitter_projectile` 粘液。粘液先在喷吐者附近随机飞行；喷吐者附近出现可视生还者后，粘液随机选择其中一名并以抛物线追踪，命中造成一次伤害。
2. 拦截喷吐者的 `IN_ATTACK`，阻止普通吐酸，改为以抛物线发射一个可见汽油桶。汽油桶撞到任何对象后播放爆炸特效和声音，对配置范围内目标造成伤害并直接施加击退，不造成硬直。

本设计只改变 `versus_isfullshit` 的专用喷吐者强化能力，不改变其他模式、普通武器投掷物或其他特感插件。

## 已确认的行为

- 粘液上限按每只喷吐者分别计算。
- 喷吐者死亡、离场、回合结束或换图时，清理该喷吐者的所有粘液。
- 粘液实体必须使用游戏默认喷吐物的可见实体，即 `spitter_projectile`。
- 每个粘液独立随机分配目标；允许多个粘液同时选择同一生还者。
- 目标优先选择当前可视的生还者。
- 主动技能替换 `IN_ATTACK`，不是 `IN_ATTACK2`。
- 汽油桶命中任何对象都触发爆炸。
- 汽油桶碰墙也算命中；若两秒内没有碰撞，则由可配置引信触发爆炸。
- 主动技能永久替换为汽油桶；只要替换开关开启，每次 `IN_ATTACK` 都拦截普通吐酸。
- 爆炸必须有粒子特效和声音。
- 伤害统一使用 SDKDamage，即 `SDKHooks_TakeDamage`；爆炸击退不使用会触发硬直的 `Fling` 或带游戏伤害/物理冲击的 `env_explosion`。

## 候选方案与选择

### 方案 A：原生口水实体加插件控制轨迹（采用）

通过现有 Left4DHooks 的 `L4D2_SpitterPrj` 创建原生 `spitter_projectile`，创建后交给插件控制位置、目标和命中检测。这样保留游戏默认口水视觉，同时通过自有碰撞 trace 和 Detour 避免闲置粘液撞墙生成无关酸池；未索敌时碰撞按石头方式反弹，轨迹、归位和命中也可以稳定地按 ConVar 控制。

### 方案 B：完全使用游戏物理驱动的口水实体

代码较短，但闲置粘液会受到原生碰撞和酸液爆炸逻辑影响，难以保证始终围绕喷吐者飞行，也可能产生未要求的酸池。

### 方案 C：使用普通模型或粒子模拟粘液

轨迹容易控制，但不再是用户指定的默认口水实体，视觉和游戏实体行为不一致。

选择方案 A。汽油桶则使用独立的 `prop_physics`，因为它需要真实碰撞来满足“命中任何对象爆炸”。

## 插件边界与依赖

新增以下文件：

- `addons/sourcemod/scripting/l4d2_spitter_slime.sp`
- `addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx`

更新：

- `cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg`：删除旧插件加载项，加入新插件加载项。
- `cfg/cfgogl/versus_isfullshit/versus.cfg`：写入新插件的模式级默认 ConVar。

退役以下旧 owner：

- `addons/sourcemod/scripting/L4D2 Spitter Supergirl.sp`
- `addons/sourcemod/plugins/optional/L4D2 Spitter Supergirl.smx`

新插件依赖当前 shared plugin 中已经加载的 `left4dhooks.smx`，源码包含 `<left4dhooks>`、`<sdktools>` 和 `<sdkhooks>`。不新增 gamedata；复用 `L4D2_SpitterPrj`、`L4D2_ActivateAbility_Spitter` 和 `L4D2_SetCustomAbilityCooldown`。

## 运行时结构

插件使用每个喷吐者独立的 owner state，并以实体引用而不是裸实体编号保存子实体：

- 每个喷吐者一个生成计时器状态。
- 每个喷吐者一个粘液实体引用列表。
- 每个粘液保存当前模式（随机反弹/追踪）、目标 client、生成时间、首次索敌状态、索敌开始时间、随机移动目标和当前速度大小。
- 每个喷吐者最多一个正在飞行的汽油桶引用；汽油桶爆炸有一次性 guard，避免多次 Touch 重复伤害。
- 一个短间隔的全局更新循环负责检查 owner 距离、索敌、命中距离和生命周期；游戏引擎负责粘液的实际移动与碰撞，粘液生成仍按各喷吐者的生成间隔执行。

生命周期入口：

1. `player_spawn` 发现存活喷吐者后启动其粘液生成状态。
2. 更新循环和实体引用检查发现喷吐者无效、死亡或成为幽灵时，停止其计时器并清理所有粘液。
3. `player_death`、`player_team`、`OnClientDisconnect`、回合结束、地图结束和 `OnPluginEnd` 都调用同一套 owner cleanup。
4. `L4D2_ActivateAbility_Spitter` 在 `l4d2_spitter_gas_enable` 开启时拦截原版能力并发射汽油桶。

## 粘液轨迹和目标流程

### 生成与随机飞行

每次生成时，插件使用 `L4D2_SpitterPrj` 以当前喷吐者为 owner 创建原生可见口水实体，保留实体碰撞 hull，并设置为由游戏引擎计算轨迹的移动类型。插件只通过速度向量控制初始方向，不在全局更新循环中逐帧传送位置；原生 `Detonate` 与酸池 Spread 仍被拦截，因此不会把随机粘液变成酸池。

粘液没有目标时，插件围绕 owner 选择 `l4d2_spitter_slime_radius` 内的随机方向和短时移动目标，设置 `MOVETYPE_FLYGRAVITY` 与速度向量，由游戏重力和碰撞计算自然轨迹。碰撞后沿引擎给出的碰撞方向继续反弹；反弹只改变方向，不使用衰减系数，不丢失碰撞前速度大小。随机移动目标到期后重新设置速度，确保粘液持续围绕 Spitter 活动。

每次更新先检查粘液与 owner 的三维距离。超过 `l4d2_spitter_slime_return_distance` 时，粘液立即传送到喷吐者附近、清除旧目标并重新设置随机速度。粘液从生成起计时；若在 `l4d2_spitter_slime_idle_lifetime` 秒内一直没有成功进入索敌阶段，则直接删除，避免无目标粘液永久存在。

### 可视目标和追踪

目标候选必须满足：

- client 在游戏内、属于生还者队伍且存活；
- owner 与生还者距离不超过 `l4d2_spitter_slime_target_range`；
- 从喷吐者视点到生还者视点的视线检测没有被世界几何遮挡。

每个无目标粘液从候选列表中随机选择一名生还者。进入索敌阶段后仍保持 `MOVETYPE_FLYGRAVITY`，以当前粘液位置为起点计算带重力补偿和弧高的弹道速度，并将其速度提高到普通速度的约两倍；每次更新重新设置该速度向量，以跟随移动目标。目标失效或碰撞事件未命中目标时不转回手动位置轨迹，而是重新设置朝向当前目标的带重力速度。进入目标距离小于 `l4d2_spitter_slime_hit_radius`（默认 `100`）时即视为命中；如果在 `l4d2_spitter_slime_miss_timeout` 内仍未命中，则删除该粘液。

命中生还者后，使用 SDKDamage 的 `SDKHooks_TakeDamage` 以 owner 作为攻击归属造成一次 `l4d2_spitter_slime_damage`，随后立即销毁该粘液并从 owner 列表移除。距离检测和碰撞事件都可触发同一命中 guard，一个粘液不会对同一目标重复造成伤害。

## `IN_ATTACK` 汽油桶技能

`L4D2_ActivateAbility_Spitter` 是喷吐者能力的预拦截入口。汽油桶替换开启时，每次 `IN_ATTACK` 都尝试创建汽油桶并通过 `L4D2_SetCustomAbilityCooldown` 设置 `l4d2_spitter_gas_cooldown`；创建成功且冷却设置成功时返回 `Plugin_Handled`，所以普通吐酸不会生成酸液。已有汽油桶仍在飞行时直接保持 `Plugin_Handled`，避免重复发射或退回普通吐酸；实体创建失败或冷却设置失败才返回 `Plugin_Continue` 作为安全回退。该冷却默认与当前模式的 `z_spit_interval 5` 对齐，但使用独立 ConVar，方便单独调整。

汽油桶使用内置模型 `models/props_junk/gascan001a.mdl` 创建为 `prop_physics`，从喷吐者视点前方生成，以 `l4d2_spitter_gas_speed` 和 `l4d2_spitter_gas_arc_height` 组成初始抛物线速度。发射初始短暂忽略 owner，避免实体在生成点立即撞回喷吐者。

汽油桶的 Touch 处理覆盖墙体、玩家和其他实体。首次有效碰撞时，或在空中超过 `l4d2_spitter_gas_fuse` 秒时：

1. 标记已爆炸并解除 Touch，防止重复处理。
2. 读取碰撞位置并播放内置粒子 `gas_explosion_initialburst_blast` 与 `weapon_pipebomb_child_fire`。
3. 播放 `weapons/hegrenade/explode3.wav` 或 `weapons/hegrenade/explode5.wav`。
4. 遍历爆炸半径内的配置目标，每个目标只处理一次。
5. 用 SDKDamage 的 `SDKHooks_TakeDamage` 施加固定伤害；默认只处理生还者，可由生还者/感染者两个开关分别控制。
6. 直接设置目标速度：水平分量沿爆炸点到目标的方向，垂直分量使用 `l4d2_spitter_gas_knockup`。不调用 `L4D2_CTerrorPlayer_Fling`，也不创建 `env_explosion`。
7. 移除汽油桶并延时清理粒子实体。

因此，爆炸视觉、伤害和击退是三个独立层次；视觉特效不会重复造成伤害或硬直。

## ConVar

插件默认值与模式配置保持一致。数值边界由 `CreateConVar` 限制，运行时修改立即影响后续生成和爆炸。

| ConVar | 默认值 | 作用 |
| --- | ---: | --- |
| `l4d2_spitter_slime_enable` | `1` | 是否生成粘液 |
| `l4d2_spitter_slime_interval` | `0.3` | 粘液生成间隔，最小 `0.05` 秒 |
| `l4d2_spitter_slime_max` | `5` | 每只喷吐者的粘液上限，`0` 关闭生成，最大 `32` |
| `l4d2_spitter_slime_radius` | `180.0` | 随机飞行范围 |
| `l4d2_spitter_slime_return_distance` | `600.0` | 粘液超出该距离后归位 |
| `l4d2_spitter_slime_target_range` | `2000.0` | owner 搜索生还者的范围 |
| `l4d2_spitter_slime_speed` | `450.0` | 粘液飞行速度 |
| `l4d2_spitter_slime_tracking_speed_multiplier` | `2.0` | 索敌阶段相对普通速度的倍率 |
| `l4d2_spitter_slime_arc_height` | `80.0` | 随机阶段的向上速度分量 |
| `l4d2_spitter_slime_damage` | `10.0` | 粘液命中伤害 |
| `l4d2_spitter_slime_hit_radius` | `100.0` | 粘液靠近目标的命中判定半径 |
| `l4d2_spitter_slime_idle_lifetime` | `3.0` | 未进入索敌阶段的粘液最长生命周期 |
| `l4d2_spitter_slime_miss_timeout` | `5.0` | 进入索敌后未命中的最长时间 |
| `l4d2_spitter_gas_enable` | `1` | 是否用汽油桶替换原版吐酸 |
| `l4d2_spitter_gas_cooldown` | `5.0` | 汽油桶技能冷却 |
| `l4d2_spitter_gas_fuse` | `2.0` | 汽油桶空中引信时间 |
| `l4d2_spitter_gas_speed` | `700.0` | 汽油桶初速度 |
| `l4d2_spitter_gas_arc_height` | `140.0` | 汽油桶抛物线高度 |
| `l4d2_spitter_gas_damage` | `50.0` | 爆炸固定伤害 |
| `l4d2_spitter_gas_radius` | `250.0` | 爆炸伤害和击退范围 |
| `l4d2_spitter_gas_knockback` | `300.0` | 水平击退强度 |
| `l4d2_spitter_gas_knockup` | `100.0` | 垂直击退强度 |
| `l4d2_spitter_gas_hurt_survivors` | `1` | 是否伤害生还者 |
| `l4d2_spitter_gas_hurt_infected` | `0` | 是否伤害感染者玩家 |

## 错误处理与清理

- Left4DHooks 不可用时插件在加载阶段报告依赖错误；当前配置已保证其先于新插件加载。
- 粘液或汽油桶创建失败时记录错误并释放部分状态；汽油桶创建失败时不拦截原版能力，让游戏保留普通吐酸作为安全回退。
- 所有计时器回调先验证 owner、client 和实体引用；无效引用从列表移除，不访问已回收实体。
- owner 清理具备幂等性，死亡事件、断线事件和回合事件重复触发不会重复删除；清理同时释放汽油桶引用和粘液生命周期状态。
- 爆炸处理具备一次性 guard，避免多个 Touch 或延迟回调重复造成伤害。
- 粒子特效和声音使用 L4D2 内置资源，不新增下载文件；粒子实体在短延时后清理。

## 兼容性边界与非目标

### 保留

- `left4dhooks.smx` 的加载顺序和现有 gamedata。
- `z_spit_interval` 本身以及其他模式的普通喷吐行为。
- 当前模式的其他插件、普通武器投掷物和其他特感能力。

### 退役

- `L4D2 Spitter Supergirl` 的全部强化能力、旧 `l4d_ssg_*` owner 以及其加载项。
- 旧插件与新插件并存加载的可能性。

### 非目标

- 不让闲置粘液生成原版酸池。
- 不为粘液增加公平轮询、优先最近目标或目标锁定菜单；目标分配保持随机。
- 不让汽油桶爆炸伤害物理实体；物理实体只负责触发碰撞爆炸。
- 不使用 `point_hurt`、实体自带爆炸伤害或其他第二套伤害路径；所有玩家伤害都经过 `SDKHooks_TakeDamage`。
- 不新增管理菜单、翻译文件、地图逻辑或服务器下载资源。

## 验证计划与验收标准

### 自动检查

新增 `tests/l4d2_spitter_slime_contract.tests.ps1`，检查：

- 新旧插件加载项的切换；
- 新源码包含依赖、ConVar、按 owner 隔离的实体引用和清理入口；
- 粘液和汽油桶范围伤害都调用 `SDKHooks_TakeDamage`，且没有 `point_hurt`/实体爆炸伤害路径；
- 使用 `L4D2_SpitterPrj`、可视目标射线检测和 `L4D2_ActivateAbility_Spitter`；
- 汽油桶模型、碰撞处理、两组爆炸特效资源和两组音效；
- 不使用 `L4D2_CTerrorPlayer_Fling` 或 `env_explosion` 承担爆炸效果；
- 模式配置包含 `.3` 秒间隔、`2000` 搜索范围、100 命中半径、3 秒未索敌生命周期、5 秒索敌未命中超时、2 秒空中引信和其余默认值。

按 TDD 顺序，先在新源码不存在时运行测试确认失败，再加入源码和配置使契约通过。随后运行 `git diff --check`。

### SourcePawn 编译

使用项目已知可用的 SourcePawn 1.12 编译器和 include 路径编译：

```powershell
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\l4d2_spitter_slime.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\optional\l4d2_spitter_slime.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

验收要求是输出 `Compilation successful.` 并生成新 `.smx`。旧插件二进制不会再作为新配置的加载目标。

### 服务器手动检查

部署到 L4D2 后按以下顺序检查：

1. 加载 `versus_isfullshit`，确认插件列表中只有新插件。
2. 生成一只喷吐者，确认粘液可见、每只喷吐者最多五个，且闲置时由游戏物理在 Spitter 附近飞行。
3. 让喷吐者移动或让粘液远离 owner，确认粘液自动归位；击杀喷吐者，确认其粘液消失。
4. 在 `2000` 范围内放置可视生还者，确认粘液随机选择并设置直接速度，进入约 `100` 范围立即命中；未索敌撞墙时确认由游戏物理反弹且速度大小不降低。
5. 用喷吐者左键，确认不生成普通酸液，汽油桶以抛物线飞行并撞击墙体/玩家/实体后只爆炸一次；让它持续在空中确认 `2` 秒引信爆炸。
6. 确认爆炸位置有粒子特效和声音，范围内生还者受到固定伤害并被直接推开，但没有 Charger 式硬直。
7. 确认无目标粘液超过 `3` 秒删除；索敌后超过未命中超时也删除；修改伤害、范围、间隔、上限、生命周期和击退 ConVar，确认后续实体使用新值。

服务器内的实际碰撞、客户端粒子显示和击退手感属于部署后验证，不由静态契约或编译单独证明。

## Aegis 工作草稿

### TaskIntentDraft

- requested outcome：用新插件替换目标配置中的旧喷吐者强化，增加每只喷吐者独立的可见粘液行为和 `IN_ATTACK` 汽油桶技能。
- scope：一个 SourcePawn 编译单元、一个模式的插件加载/ConVar 配置、对应二进制、契约测试。
- risk hints：原生 `spitter_projectile` 的物理/酸池逻辑、能力预拦截时机、实体和计时器清理、无硬直击退、旧 owner 退役。

### BaselineReadSetHint

- `AGENTS.md`：项目 SourcePawn 编译命令和 warning 边界。
- `README.md`、`Docs/readme.md`：项目部署和模式配置语境。
- `cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg`、`versus.cfg`：当前加载 owner、`z_spit_interval` 和模式配置链。
- `addons/sourcemod/scripting/L4D2 Spitter Supergirl.sp`：旧插件行为和需要退役的 owner。
- `addons/sourcemod/scripting/include/left4dhooks.inc`、`left4dhooks_stocks.inc`：原生口水创建、能力拦截和冷却接口。
- `addons/sourcemod/scripting/l4d_grenades.sp`：现有爆炸粒子、音效和物理实体实现参考。
- `tests/*.tests.ps1`：仓库静态契约测试风格。

### ImpactStatementDraft

- affected layers：SourcePawn 运行时、模式插件加载配置、模式 ConVar、静态契约测试和可部署二进制。
- invariants：每个 owner 的粘液不能跨 owner 清理；所有子实体和计时器必须可回收；随机粘液由游戏计算移动、反弹保持速度大小、无目标 3 秒删除；开启替换时 `IN_ATTACK` 永久使用汽油桶，只有创建或冷却失败才回退原版能力；爆炸视觉不能附带第二套伤害/硬直路径。
- compatibility boundary：只影响 `versus_isfullshit`；保留 Left4DHooks、其他插件、其他模式和原版 `z_spit_interval`。
- retirement：旧 `L4D2 Spitter Supergirl` 源码、二进制和加载项在实现切换中退役。
