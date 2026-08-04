# 武器配置

## v1

这个配置的主要目的是让一些前期武器有一些更加平衡的数据，不至于前期坐牢一年后期连狙起飞
配置数据来源于药抗配置

```
//Zonemod 2.8.3
sm_weapon smg spreadpershot 0.22
sm_weapon smg maxmovespread 2
sm_weapon smg damage 22
sm_weapon smg rangemod 0.78
sm_weapon smg reloadduration 1.8
sm_weapon smg_silenced spreadpershot 0.26
sm_weapon smg_silenced maxmovespread 2.45
sm_weapon smg_silenced rangemod 0.81
sm_weapon smg_silenced reloadduration 2
sm_weapon weapon_smg_mp5 damage 23
sm_weapon weapon_smg_mp5 spreadpershot 0.25
sm_weapon weapon_smg_mp5 maxmovespread 2.1
sm_weapon weapon_smg_mp5 rangemod 0.83
sm_weapon weapon_smg_mp5 reloadduration 2.1

sm_weapon shotgun_chrome scatterpitch 4
sm_weapon shotgun_chrome scatteryaw 4
sm_weapon pumpshotgun damage 17
sm_weapon pumpshotgun bullets 16
sm_weapon pumpshotgun scatterpitch 3
sm_weapon pumpshotgun scatteryaw 5

sm_weapon sniper_scout damage 185
sm_weapon sniper_scout maxmovespread 0.75
sm_weapon sniper_awp damage 240
sm_weapon sniper_awp maxmovespread 0.75
```

## v2

进一步加强T1武器，同时略微加强部分冷门T2武器。

```
//smg
sm_weapon smg spreadpershot 0.22
sm_weapon smg maxmovespread 2
sm_weapon smg damage 24
sm_weapon smg rangemod 0.78
sm_weapon smg reloadduration 1.8
sm_weapon smg_silenced damage 28
sm_weapon smg_silenced spreadpershot 0.26
sm_weapon smg_silenced maxmovespread 2.45
sm_weapon smg_silenced rangemod 0.81
sm_weapon smg_silenced reloadduration 2
sm_weapon weapon_smg_mp5 damage 25
sm_weapon weapon_smg_mp5 spreadpershot 0.25
sm_weapon weapon_smg_mp5 maxmovespread 2.1
sm_weapon weapon_smg_mp5 rangemod 0.83
sm_weapon weapon_smg_mp5 reloadduration 2.1
// 单喷
sm_weapon shotgun_chrome damage 17
sm_weapon shotgun_chrome bullets 16
sm_weapon shotgun_chrome scatterpitch 4
sm_weapon shotgun_chrome scatteryaw 4
sm_weapon shotgun_chrome clipsize 9
sm_weapon pumpshotgun damage 18
sm_weapon pumpshotgun bullets 18
sm_weapon pumpshotgun scatterpitch 3
sm_weapon pumpshotgun scatteryaw 5
sm_weapon pumpshotgun clipsize 9

sm_weapon sniper_scout damage 225
sm_weapon sniper_scout maxmovespread 0.15
sm_weapon sniper_awp damage 290
sm_weapon sniper_awp maxmovespread 0.50

// 连喷
// 多特连喷的续航过于拉跨，主打一手增强续航
sm_weapon weapon_autoshotgun clipsize 13
sm_weapon weapon_autoshotgun reloaddurationmult 0.75
sm_weapon weapon_autoshotgun damage 20
sm_weapon weapon_autoshotgun bullets 14
sm_weapon weapon_shotgun_spas clipsize 13
sm_weapon weapon_shotgun_spas reloaddurationmult 0.75
sm_weapon weapon_shotgun_spas damage 13
sm_weapon weapon_shotgun_spas bullets 20

// 突击步枪

// m16的伤害已经拉跨了，给点子弹和精准度弥补一下
sm_weapon weapon_rifle maxmovespread 4.4
sm_weapon weapon_rifle clipsize 60

// 总不能让scar的定位被m16顶下去
sm_weapon weapon_rifle_desert maxmovespread 3.6
sm_weapon weapon_rifle_desert clipsize 72

// ak 意思意思
sm_weapon weapon_rifle_ak47 damage 64

// sg552 拉点伤害和弹药 反正你能开镜
sm_weapon weapon_rifle_sg552 damage 39
sm_weapon weapon_rifle_sg552 clipsize 55

```

## v3

除草配置

```
//smg
sm_weapon smg spreadpershot 0.22
sm_weapon smg maxmovespread 1.7
sm_weapon smg damage 25
sm_weapon smg rangemod 0.78
sm_weapon smg reloadduration 1.8
sm_weapon smg_silenced damage 30
sm_weapon smg_silenced spreadpershot 0.26
sm_weapon smg_silenced maxmovespread 2.45
sm_weapon smg_silenced rangemod 0.81
sm_weapon smg_silenced reloadduration 1.9
sm_weapon weapon_smg_mp5 damage 27
sm_weapon weapon_smg_mp5 spreadpershot 0.25
sm_weapon weapon_smg_mp5 maxmovespread 2.1
sm_weapon weapon_smg_mp5 rangemod 0.83
sm_weapon weapon_smg_mp5 reloadduration 2.1
// 单喷
sm_weapon shotgun_chrome damage 19
sm_weapon shotgun_chrome bullets 17
sm_weapon shotgun_chrome scatterpitch 4
sm_weapon shotgun_chrome scatteryaw 4
sm_weapon shotgun_chrome clipsize 10
sm_weapon shotgun_chrome reloaddurationmult 0.75
sm_weapon pumpshotgun damage 18
sm_weapon pumpshotgun bullets 21
sm_weapon pumpshotgun scatterpitch 4
sm_weapon pumpshotgun scatteryaw 6
sm_weapon pumpshotgun clipsize 10
sm_weapon pumpshotgun reloaddurationmult 0.75

sm_weapon sniper_scout damage 250
sm_weapon sniper_scout maxmovespread 0.15
sm_weapon sniper_awp damage 325
sm_weapon sniper_awp maxmovespread 0.50

// 连喷
// 多特连喷的续航过于拉跨，主打一手增强续航
sm_weapon weapon_autoshotgun clipsize 15
sm_weapon weapon_autoshotgun reloaddurationmult 0.6
sm_weapon weapon_autoshotgun damage 20
sm_weapon weapon_autoshotgun bullets 14
sm_weapon weapon_shotgun_spas clipsize 13
sm_weapon weapon_shotgun_spas reloaddurationmult 0.6
sm_weapon weapon_shotgun_spas damage 15
sm_weapon weapon_shotgun_spas bullets 20

// 突击步枪

// m16的伤害已经拉跨了，给点子弹和精准度弥补一下
sm_weapon weapon_rifle maxmovespread 4
sm_weapon weapon_rifle clipsize 64

// 总不能让scar的定位被m16顶下去
sm_weapon weapon_rifle_desert maxmovespread 2.2
sm_weapon weapon_rifle_desert clipsize 76

// ak 意思意思
sm_weapon weapon_rifle_ak47 damage 70

// sg552 拉点伤害和弹药 反正你能开镜
sm_weapon weapon_rifle_sg552 damage 44
sm_weapon weapon_rifle_sg552 clipsize 61

// m60
sm_weapon weapon_rifle_m60 bullets 2
sm_weapon weapon_rifle_m60 damage 27

// 30连
sm_weapon weapon_sniper_military maxmovespread 3.8

// 15连
sm_weapon weapon_hunting_rifle clipsize 20

// 榴弹
sm_weapon weapon_grenade_launcher reloaddurationmult 0.6
```

## 物品名称对比
> 不是所有物品都进行了修改

| Item Type Name | Display Name |
| -------------- | ------------ |
| weapon_none | None |
| weapon_pistol | Pistol |
| weapon_smg | Uzi |
| weapon_pumpshotgun | Pump |
| weapon_autoshotgun | Autoshotgun |
| weapon_rifle | M-16 |
| weapon_hunting_rifle | Hunting Rifle |
| weapon_smg_silenced | Mac |
| weapon_shotgun_chrome | Chrome |
| weapon_rifle_desert | Desert Rifle |
| weapon_sniper_military | Military Sniper |
| weapon_shotgun_spas | SPAS Shotgun |
| weapon_first_aid_kit | First Aid Kit |
| weapon_molotov | Molotov |
| weapon_pipe_bomb | Pipe Bomb |
| weapon_pain_pills | Pills |
| weapon_gascan | Gascan |
| weapon_propanetank | Propane Tank |
| weapon_oxygentank | Oxygen Tank |
| weapon_melee | Melee |
| weapon_chainsaw | Chainsaw |
| weapon_grenade_launcher | Grenade Launcher |
| weapon_ammo_pack | Ammo Pack |
| weapon_adrenaline | Adrenaline |
| weapon_defibrillator | Defibrillator |
| weapon_vomitjar | Bile Bomb |
| weapon_rifle_ak47 | AK-47 |
| weapon_gnome | Gnome |
| weapon_cola_bottles | Cola Bottles |
| weapon_fireworkcrate | Fireworks |
| weapon_upgradepack_incendiary | Incendiary Ammo Pack |
| weapon_upgradepack_explosive | Explosive Ammo Pack |
| weapon_pistol_magnum | Deagle |
| weapon_smg_mp5 | MP5 |
| weapon_rifle_sg552 | SG552 |
| weapon_sniper_awp | AWP |
| weapon_sniper_scout | Scout |
| weapon_rifle_m60 | M60 |
| weapon_tank_claw | Tank Claw |
| weapon_hunter_claw | Hunter Claw |
| weapon_charger_claw | Charger Claw |
| weapon_boomer_claw | Boomer Claw |
| weapon_smoker_claw | Smoker Claw |
| weapon_spitter_claw | Spitter Claw |
| weapon_jockey_claw | Jockey Claw |
| weapon_machinegun | Turret |
| vomit 	| vomit 	|
|splat 	| splat 	|
|pounce 	| pounce 	|
|lounge 	| lounge 	|
|pull 	| pull 	|
|choke 	| choke 	|
|rock 	| rock 	|
|physics 	| physics 	|
|ammo 	| ammo 	|
|upgrade_item 	| upgrade_item |

## 属性名称对比和解释
> 以 `addons/sourcemod/scripting/l4d2_weapon_attributes.sp` 中 `sWeaponAttrShortName` 和 `sWeaponAttrNames` 为准。

| sm_weapon 属性名 | 插件显示名 | 说明 |
| --- | --- | --- |
| damage | Damage | 每发子弹或单颗霰弹弹丸的基础伤害 |
| bullets | Bullets | 每次开火发射的子弹或弹丸数量 |
| clipsize | Clip Size | 弹匣或弹仓容量 |
| bucket | Bucket | 武器脚本里的武器选择分组数值，通常不用于伤害平衡 |
| tier | Tier | 武器脚本里的武器等级数值 |
| speed | Max player speed | 持有该武器时的玩家最大移动速度 |
| spreadpershot | Spread per shot | 每次开火增加的散布量，越低连射越稳 |
| maxspread | Max spread | 连续开火可累计到的最大散布 |
| spreaddecay | Spread decay | 停火后散布回落的速度 |
| minduckspread | Min ducking spread | 蹲下时的最低基础散布 |
| minstandspread | Min standing spread | 站立时的最低基础散布 |
| minairspread | Min in air spread | 空中时的最低基础散布 |
| maxmovespread | Max movement spread | 移动时的最大散布 |
| penlayers | Penetration num layers | 子弹可穿透的层数 |
| penpower | Penetration power | 子弹穿透强度，影响穿透后的伤害表现 |
| penmaxdist | Penetration max dist | 子弹穿透后的最大继续飞行距离 |
| charpenmaxdist | Char penetration max dist | 子弹穿透角色后的最大继续飞行距离 |
| range | Range | 武器有效射程 |
| rangemod | Range modifier | 距离伤害衰减倍率 |
| cycletime | Cycle time | 两次开火之间的间隔，越低射速越快 |
| scatterpitch | Pellet scatter pitch | 霰弹弹丸的垂直散布 |
| scatteryaw | Pellet scatter yaw | 霰弹弹丸的水平散布 |
| verticalpunch | Vertical punch | 开火产生的垂直后坐抬升 |
| horizpunch | Horizontal punch | 开火产生的水平后坐偏移，需要 `z_gun_horiz_punch` 支持 |
| gainrange | Gain range | 伤害增益或衰减计算使用的距离参数 |
| reloadduration | Reload duration | 武器基础换弹时长 |
| tankdamagemult | Tank damage multiplier | 插件额外处理的对 Tank 伤害倍率 |
| reloaddurationmult | Reload duration multiplier | 插件额外处理的霰弹枪装填时长倍率 |


