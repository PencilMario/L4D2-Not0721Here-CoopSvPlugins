# 服务器配置说明

本文档介绍本插件包当前可用的比赛配置、主要玩法差异和通用插件。配置与插件仍在持续调整；出现冲突时，以仓库内的实际 CFG 为准。

## 快速使用

- 使用 `!match` 选择并加载配置。
- 使用 `!rmatch` 结束当前配置并恢复默认状态。
- 使用 `!votemenu` 打开服务器设置投票。
- 使用 `!slots` 投票调整服务器位置数。
- 常用功能：`!panel` 查看队伍状态、`!current` 查看进度、`!drop`/`!g` 丢弃物品、`!s` 进入旁观、`!zs` 自杀。

配置菜单及显示名称由 [`matchmodes.txt`](../addons/sourcemod/configs/matchmodes.txt) 管理。各模式的详细参数位于 [`cfg/cfgogl`](../cfg/cfgogl/)。

## 目录

- [配置总览](#配置总览)
- [战役配置](#战役配置)
- [写实配置](#写实配置)
- [绝境配置](#绝境配置)
- [死门配置](#死门配置)
- [开牢](#开牢)
- [刷特机制](#刷特机制)
- [AI 特感伤害修正](#ai-特感伤害修正)
- [通用插件](#通用插件)
- [通用修复](#通用修复)

## 配置总览

“基础刷特”表示 4 名或更少真人玩家时的最高同屏特感数和单 Slot CD。“人数增长”表示超过 4 名真人后，每增加 1 人带来的特感数/CD 变化。

| 系列 | 配置 | 显示名称 | 基础刷特 | 人数增长 | Relax | AI 伤害修正 / 牛近战 |
| --- | --- | --- | --- | --- | --- | --- |
| 战役 | `coop_base` | 基础战役 | 3 / 35 秒 | +1 / -2 秒 | 允许 | 默认 `3` 修正 / 不固定 |
| 战役 | `coop_hard` | 逛街多人多特 | 8 / 15 秒 | +2 / 不变 | 允许 | 默认 `3` 修正 / 不固定 |
| 战役 | `coop_fire` | 无限火力 | 8 / 0 秒 | +2 / 不变 | 跳过 | 默认 `3` 修正 / 不固定 |
| 战役 | `coop_himiko` | 秘密子能带飞 | 14 / 15 秒 | +2 / 不变 | 允许 | 默认 `3` 修正 / 不固定 |
| 战役 | `community5_multi` | 多人逛街死门 | 5 / 0 秒 | +1 / 不变 | 跳过 | `3` 修正 / 350 |
| 写实 | `realism_solo` | 写专单通 | 14 / 15 秒 | 固定 | 允许 | 默认 `3` 修正 / 不固定 |
| 绝境 | `mutation4_noobplus` | 逛街绝境混野版 | 8 / 15 秒 | 固定 | 允许 | `3` 修正 / 350 |
| 绝境 | `mutation4_solo` | 绝境单通 | 8 / 15 秒 | 固定 | 允许 | 默认 `3` 修正 / 不固定 |
| 绝境 | `mutation4_ez` | 逛街14特 | 14 / 15 秒 | 固定 | 允许 | 默认 `3` 修正 / 不固定 |
| 绝境 | `mutation4` | 绝境14特 | 14 / 15 秒 | 固定 | 允许 | `0` 原版 / 不固定 |
| 绝境 | `mutation4_except` | 绝境28特6控 | 28 / 15 秒 | 固定 | 允许 | `0` 原版 / 不固定 |
| 死门 | `community5_noobplus` | 逛街死门混野版 | 5 / 0 秒 | 固定 | 跳过 | `3` 修正 / 350 |
| 死门 | `community5_ez` | 逛街死门12特0秒 | 12 / 0 秒 | 固定 | 跳过 | 默认 `3` 修正 / 不固定 |
| 死门 | `community5` | 死门10特0秒 | 10 / 0 秒 | 固定 | 跳过 | `0` 原版 / 不固定 |
| 死门 | `community5_himiko` | 秘密子来了都过了 | 24 / 0 秒 | 固定 | 跳过 | `3` 修正 / 350 |
| 开牢！ | `community5_610` | 死门\|6特10s | 6 / 10 秒 | 固定 | 跳过 | `0` 原版 / 不固定 |
| 开牢！ | `community5_jimen` | 几门\|群都死了 | 6 / 15 秒 | 固定 | 跳过 | `0` 原版 / 不固定 |
| 开牢！ | `realism_miaomei` | 写专\|秒妹老师の4k血妹 | 3 / 45 秒 | 固定 | 允许 | `0` 原版 / 不固定 |
| 开牢！ | `coop_fuckmap` | 战役\|什么吊图 | 6 / 15 秒 | +2 / -2 秒 | 允许 | `0` 原版 / 不固定 |
| 开牢！ | `coop_annelike` | 战役\|饼干的Anne改战役 | 6 / 16 秒 | +1 / -2 秒 | 允许 | 默认 `3` 修正 / 不固定 |
| 开牢！ | `community2` | 感染季节\|绝境14特 | 14 / 15 秒 | 固定 | 允许 | `0` 原版 / 不固定 |
| 开牢！ | `coop_wtf` | 战役\|你们玩这么变态的？ | 10 / 0 秒 | +1 / 不变 | 跳过 | `0` 原版 / 不固定 |
| 开牢！ | `coop_rpg` | 战役\|Sky rpg v3.4.7.8 | 5 / 15 秒 | +1 / -2 秒 | 允许 | `0` 原版 / 不固定 |
| 开牢！ | `versus_isfullshit` | 对抗\|救世主大战逆天特感争抢0721 | 8 / 15 秒 | 固定 | 允许 | `0` 原版 / 不固定 |

> [!NOTE]
> 表中的“允许”表示配置未主动关闭 Relax，实际运行值仍可通过投票修改。`coop_wtf` 另外启用了快速补特模式 2。

## 战役配置

战役系列通常支持 4 人以上共同游玩。

<details>
<summary><code>coop_base</code> 基础战役</summary>

- 接近原版的多人战役基础包，也是大多数配置共享设置与插件的来源。
- 基础 3 特 35 秒；超过 4 名真人后，每人增加 1 特并减少 2 秒 CD，CD 最低为 0。
- 6 倍备弹，武器配置 v1。
- 生还者 AI、多人生还者、装备恢复、地图兼容和常见 Bug 修复均在此基础上提供。
- 可使用 `!panel`、`!slots`、`!drop`/`!g` 等通用功能。

配置入口：[`coop_base/confogl.cfg`](../cfg/cfgogl/coop_base/confogl.cfg)

</details>

<details>
<summary><code>coop_hard</code> 逛街多人多特</summary>

- 基础 8 特 15 秒；超过 4 名真人后每人增加 2 特。
- Tank 血量倍率：`0.75 / 1.25 / 1.75 / 2.25`。
- 3 倍备弹和特殊弹药包，武器配置 v3。
- 投掷物快速出手、呼吸回血、快速扶人和自动复活。
- 近战对 Tank 的伤害固定为 450。

</details>

<details>
<summary><code>coop_fire</code> 无限火力</summary>

- 基础 8 特 0 秒；超过 4 名真人后每人增加 2 特，并跳过 Relax。
- 初始额外创建 2 个生还者 Bot，最多 6 名生还者。
- 主武器无限弹药，5 倍特殊弹药包，武器配置 v3。
- 特感不可见 5 秒后允许传送。
- Tank 血量倍率：`1.5 / 2.8 / 4.1 / 5.5`；近战对 Tank 固定 450 伤害。
- 允许回血、击杀回血、倒地使用主武器与药品自救，并加载技能商店。

</details>

<details>
<summary><code>coop_himiko</code> 秘密子能带飞</summary>

- 基础 14 特 15 秒；超过 4 名真人后每人增加 2 特。
- 锁定专家难度，3 倍备弹，武器配置 v2。
- Tank 血量倍率：`1.2 / 2.4 / 3.0 / 4.0`；近战对 Tank 固定 450 伤害。
- 投掷物快速出手、特感传送、呼吸/击杀回血、自动复活和倒地主武器。

</details>

<details>
<summary><code>community5_multi</code> 多人逛街死门</summary>

- 死门玩法，基础 5 特 0 秒；超过 4 名真人后每人增加 1 特，并跳过 Relax。
- 3 倍备弹，特殊弹药包倍率为 2。
- 投掷物快速出手、特感传送、回血和自动复活。

</details>

## 写实配置

<details>
<summary><code>realism_solo</code> 写专单通</summary>

- 写实专家单通，限制 1 名生还者和 1 个服务器位置。
- 固定 14 特 15 秒。
- 1 倍备弹，加载过关回血。

</details>

## 绝境配置

绝境系列均使用 `mutation4` 游戏模式并锁定专家难度。

<details>
<summary><code>mutation4_noobplus</code> 逛街绝境混野版</summary>

- 固定 8 特 15 秒，启用绝境不停刷修复。
- 最多 4 名生还者，3 倍备弹。
- 投掷物快速出手，AI 伤害修正设为混野版配置。

</details>

<details>
<summary><code>mutation4_solo</code> 绝境单通</summary>

- 固定 8 特 15 秒，DPS 特感限制为 0。
- 限制 1 名生还者和 1 个服务器位置，1 倍备弹。

</details>

<details>
<summary><code>mutation4_ez</code> 逛街14特</summary>

- 固定 14 特 15 秒。
- 最多 4 名生还者，3 倍备弹，投掷物快速出手。

</details>

<details>
<summary><code>mutation4</code> 绝境14特</summary>

- 固定 14 特 15 秒。
- 最多 4 名生还者，3 倍备弹。

</details>

<details>
<summary><code>mutation4_except</code> 绝境28特6控</summary>

- 固定 28 特 15 秒，DPS 特感限制为 4。
- 最多 4 名生还者和 4 个服务器位置，4 倍备弹。
- 仅允许旁观者使用 `!panel`。

</details>

## 死门配置

死门系列均使用 `community5` 游戏模式并锁定专家难度。

<details>
<summary><code>community5_noobplus</code> 逛街死门混野版</summary>

- 固定 5 特 0 秒并跳过 Relax。
- 最多 4 名生还者，3 倍备弹。
- 投掷物快速出手、特感传送、呼吸/击杀回血和过关回血。

</details>

<details>
<summary><code>community5_ez</code> 逛街死门12特0秒</summary>

- 固定 12 特 0 秒，DPS 特感限制为 2，并跳过 Relax。
- 最多 4 名生还者，3 倍备弹。
- 投掷物快速出手、特感传送、呼吸/击杀回血和过关回血。

</details>

<details>
<summary><code>community5</code> 死门10特0秒</summary>

- 固定 10 特 0 秒，DPS 特感限制为 2，并跳过 Relax。
- 最多 4 名生还者，3 倍备弹。
- 特感传送、呼吸/击杀回血和过关回血。
- 仅允许旁观者使用 `!panel`。

</details>

<details>
<summary><code>community5_himiko</code> 秘密子来了都过了</summary>

- 固定 24 特 0 秒，DPS 特感限制为 3，并跳过 Relax。
- 7 倍备弹，武器配置 v2。
- 投掷物快速出手、特感传送、呼吸/击杀回血、过关回血和自动复活。

</details>

## 开牢！

从别人群偷来的模式，狠狠的开牢！

<details>
<summary><code>community5_610</code> 死门|6特10s</summary>

- 固定 6 特 10 秒，DPS 特感限制为 4，并跳过 Relax。
- 最多 4 名生还者，3 倍备弹，锁定专家难度。
- 仅允许旁观者使用 `!panel`。

</details>

<details>
<summary><code>community5_jimen</code> 几门|群都死了</summary>

- 写实专家，固定 6 特 15 秒，DPS 特感限制为 2，并跳过 Relax。
- 倒地次数为 0，倒地即死；近战范围为 140。
- 3 倍备弹、特感传送和呼吸回血，不启用击杀回血。

</details>

<details>
<summary><code>realism_miaomei</code> 写专|秒妹老师の4k血妹</summary>

- 写实专家，固定 3 特 45 秒。
- Witch 血量为 4000，最多 4 名生还者，1 倍备弹。
- 仅允许旁观者使用 `!panel`。

</details>

<details>
<summary><code>coop_fuckmap</code> 战役|什么吊图</summary>

- 基础 6 特 15 秒；超过 4 名真人后每人增加 2 特并减少 2 秒 CD。
- 锁定专家难度，3 倍备弹，武器配置 v3。
- Tank 血量倍率：`1.2 / 1.5 / 2.0 / 2.5`；近战对 Tank 固定 450 伤害。
- 投掷物扩展、回血、倒地主武器与药品自救、自动复活、电击器攻击、读条移动和技能系统。

</details>

<details>
<summary><code>coop_annelike</code> 战役|饼干的Anne改战役</summary>

- 基础 6 特 16 秒；超过 4 名真人后每人增加 1 特并减少 2 秒 CD。
- Tank 血量倍率：`1.5 / 1.5 / 1.8 / 2.0`，武器配置 v1。
- 加载 Anne 系列特感 AI、目标选择、Tank 防卡与文字插件。

</details>

<details>
<summary><code>community2</code> 感染季节|绝境14特</summary>

- 固定 14 特 15 秒，锁定专家难度。
- 3 倍备弹和过关回血。

</details>

<details>
<summary><code>coop_wtf</code> 战役|你们玩这么变态的？</summary>

- 基础 10 特 0 秒；超过 4 名真人后每人增加 1 特，跳过 Relax，并启用快速补特模式 2。
- 简单难度，10 倍备弹，武器配置 v3。
- Tank 血量倍率：`3.5 / 4.0 / 4.5 / 5.0`，倒地次数为 0。
- 无限火力、回血、特感传送、倒地主武器与药品自救，并强化 Charger。

</details>

<details>
<summary><code>coop_rpg</code> 战役|Sky rpg v3.4.7.8</summary>

- 基础 5 特 15 秒；超过 4 名真人后每人增加 1 特并减少 2 秒 CD。
- 锁定专家难度，武器配置 v3。
- 加载 `readyup.smx` 与 `rum_rpg_ns.smx`；部分通用投票不会覆盖 RPG 自己的设置。

</details>

<details>
<summary><code>versus_isfullshit</code> 对抗|救世主大战逆天特感争抢0721</summary>

- 对抗模式，固定 8 特 15 秒。
- 初始额外创建 7 个生还者 Bot，支持最多 11 名生还者。
- Tank 血量倍率固定为 2.7，5 倍特殊弹药包，武器配置 v3。
- 加载自动复活、倒地主武器、扩展投掷物和强化特感能力等专用插件。

</details>

## 刷特机制

### 自动人数缩放

启用自动缩放时，以 4 名真人玩家为基准：

```text
最高同屏 = 基础特感数 + 每人增加数 x (真人数 - 4)
单 Slot CD = 基础 CD - 每人减少秒数 x (真人数 - 4)
```

4 人及以下直接使用基础值；CD 不会低于 0。若“真人数 + 特感数”超过服务器的 `sv_setmax`，插件还会降低最高同屏数以避免超出位置上限。

投票可切换自动缩放，或直接设置同屏上限、CD、DPS 限制、Relax、快速补特和绝境修复。当前投票定义见 [`customvotes.cfg`](../addons/sourcemod/configs/customvotes.cfg)。

### 特感种类分配与 DPS 限制

插件按以下顺序循环分配每类特感上限：

```text
Hunter -> Jockey -> Smoker -> Charger -> Spitter -> Boomer
```

这里的 DPS 特感指 Spitter 和 Boomer。达到 `si_spawn_dps_special_limit` 后，本轮会跳过这两类并从 Hunter 重新分配。限制值小于或等于 0 时，分配只在前四种控制类特感中循环。

### Relax

`si_spawn_relax_enabled` 控制是否保留导演的 Relax 节奏：

- `1`：保留较长的初始刷特延迟和导演压力休息阶段。
- `0`：压低初始延迟与 Relax 时间，并覆盖导演脚本中的节奏参数，使刷特持续进行。

`si_spawn_fast_respawn_mode` 只在跳过 Relax 时有意义：模式 1 会持续推进特感出生/死亡计时器，模式 2 还会清理已死亡但仍占用位置的感染者 Bot。

### 当前命令与 ConVar

| 用途 | 命令或 ConVar |
| --- | --- |
| 直接设置最高同屏 | `sm_si_spawn_set_limit <数量>` |
| 直接设置单 Slot CD | `sm_si_spawn_set_interval <秒>` |
| 直接设置 DPS 限制 | `sm_si_spawn_set_dps_limit <数量>` |
| 自动人数缩放 | `si_spawn_auto_scale_enabled` |
| 允许 Relax | `si_spawn_relax_enabled` |
| 快速补特模式 | `si_spawn_fast_respawn_mode` |
| 绝境不停刷修复 | `si_spawn_mutation4_fix_enabled` |

## AI 特感伤害修正

`l4d2_ai_damagefix.smx` 用 `sm_aidmgfix_enable` 位掩码控制 AI Hunter 和 AI Charger 的伤害行为：

| 值 | Hunter 飞扑空爆 | Charger 冲锋减伤 |
| --- | --- | --- |
| `0` | 原版 AI 行为 | 保留原版减伤 |
| `1` | 同一次飞扑累计受伤达到 `z_pounce_damage_interrupt` 时触发空爆 | 保留原版减伤 |
| `2` | 原版 AI 行为 | 移除原版减伤，按玩家 Charger 的伤害处理 |
| `3` | 启用空爆修正 | 移除原版减伤 |

本插件包将 `z_pounce_damage_interrupt` 设为 150。总览中的“`3` 修正 / 350”表示模式显式启用两项 AI 修正，并将生还者对 Charger 的近战伤害固定为每挥 350；最后一击会按 Charger 剩余血量封顶。“默认 `3` 修正 / 不固定”表示插件默认仍会处理 HT 空爆和 Charger 冲锋减伤，但该模式没有显式设置 `sm_aidmgfix_enable`，因此也不添加牛近战固定伤害。“`0` 原版 / 不固定”表示保留两项原版 AI 行为和原版近战命中部位伤害。

## 通用插件

`coop_base` 是大多数配置的插件基础。完整加载顺序以 [`shared_plugins.cfg`](../cfg/cfgogl/coop_base/shared_plugins.cfg) 为准，本文只保留稳定的功能分类：

| 分类 | 主要功能 |
| --- | --- |
| 配置与投票 | Confogl 配置切换、NativeVotes 自定义投票、难度/位置控制、换图 |
| 多人支持 | 创建生还者 Bot、管理人数与旁观、恢复跨图身份和装备、大厅解除预留 |
| 刷特与 AI | 动态刷特、特感传送、生还者 AI、灌油 Bot、Bot 掉队追赶 |
| 战斗与武器 | 武器属性、霰弹枪扩散、M60/榴弹补给、备弹倍率、近战与电锯调整 |
| 状态与反馈 | MVP、Tank/Witch 伤害、队伍面板、黑白提示、特感血条、伤害跳字 |
| 地图与流程 | 三方图提示、自动切图、路线进度、暖服重开、地图提示翻译 |
| 娱乐与便捷 | 跳舞、丢物品、传递物品、死亡喷漆、连杀公告、金币和音效反馈 |
| 管理与稳定性 | 空服重启、网络参数、加载超时处理、端口配置、聊天与连接提示 |

不同模式可在自己的 `confogl_plugins.cfg` 中额外加载自动复活、倒地主武器、技能系统、RPG 或特感强化插件。

## 通用修复

修复插件集中在 [`addons/sourcemod/plugins/fix`](../addons/sourcemod/plugins/fix/)，实际启用清单由 [`cfg/generalfixes.cfg`](../cfg/generalfixes.cfg) 管理。当前主要覆盖：

- **崩溃与安全：** 梯子、HLTV、实体限制、命令缓冲、喷漆与一致性检查。
- **多人战役：** 生还者身份、跨图装备、电击器目标、升级弹药包和闲置接管。
- **特感行为：** Charger 碰撞/目标、Jockey 传送与命中箱、Spitter 冷却与扩散、Smoker 舌头、Tank 石头和终章阶段。
- **导演与地图：** 特感出生、逃生路线、终章可破坏物、出生安全屋和开场跳过。
- **武器与动作：** 换弹打断、手枪延迟、推击持续时间、火箭跳和 SG552 FOV。
- **网络与观战：** 旁观 Tickrate、延迟补偿、卡顿预防和控制台刷屏。

插件文件会随上游修复更新而增删，因此这里不再复制完整文件清单。

## 相关文档

- [部署说明](install.md)
- [武器配置](weapons.md)
- [根目录项目说明](../README.md)
