# 插件配置

使用!match/!rmatch选择配置项

1. **战役系列**
   > 战役系列通常支持4+人

   * *coop_base 轻改战役包/基础插件*
      > 这个插件包基本不修改游戏内容，提供接近于原版的4/8+人体验
      > 大多数配置也会读取本配置的插件文件
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础3只35s，4人以上每多1人+1只/-2s复活CD，允许Relax阶段
      * 移除牛冲锋减伤，HT空爆伤害为150
      * 生还者AI增强
      * 限制~~速砍~~，连跳，闲置躲伤害（将直接旁观）等操作。
      * 特感数量/复活CD/DPS数量/Relax阶段等都可手动调节
      * 可使用!slots设置位置
      * 战役/药抗bug修复系列插件，详见plugins/fix
      * 开局自带uzi+双枪
      * 武器配置：v1
      * 允许非旁观者使用!panel查看队伍状态
      * 可以使用!drop/!g丢弃道具
      * 可以R键给其他人道具
      * 地图小僵尸限制受z_common_limit影响

         <details>
         <summary>插件配置</summary>
         > 加载的插件不代表一定会使用到
         ```
         
            //------------------------
            // Sourcemod 基础插件
            //------------------------
            sm plugins load basebans.smx
            sm plugins load basecommands.smx
            sm plugins load basecomm.smx
            sm plugins load admin-flatfile.smx
            sm plugins load adminhelp.smx
            sm plugins load adminmenu.smx
            sm plugins load funcommands.smx
            sm plugins load playercommands.smx
            // 空服自动重启
            sm plugins load sm_RestartEmpty.smx
            // 投票控制，阻止返回大厅/特定配置阻止切换难度
            sm plugins load vote_block.smx
            // all4dead 刷物品插件
            sm plugins load all4dead2.smx
            // 服务器网络cvar自动设置
            sm plugins load setrates.smx
            //sourcebans++
            sm plugins load sbpp_main.smx
            sm plugins load sbpp_checker.smx
            sm plugins load sbpp_admcfg.smx
            sm plugins load sbpp_comms.smx
            sm plugins load sbpp_report.smx
            sm plugins load sbpp_sleuth.smx
            // LAC反作弊
            sm plugins load lilac.smx
            // 广告
            sm plugins load advertisements.smx
            // 连接提示
            sm plugins load cannounce.smx
            // left4dhooks前置
            sm plugins load left4dhooks.smx
            // 自定义投票，用于!votemenu
            sm plugins load customvotes.smx
            // 跳舞插件
            sm plugins load fortnite_l4d1_2.smx
            // 自动管理大厅匹配
            sm plugins load l4d2_unreservelobby.smx
            // 服务端指令
            sm plugins load sm_fake_server_cmd.smx
            // 多倍补给
            sm plugins load l4d2_more_medicals.smx
            // 第三人称状态接口
            sm plugins load ThirdPersonShoulder_Detect.smx
            // 显示谁在开麦
            sm plugins load show_mic.smx
            // 多特插件 用于重载脚本来实现修改刷特设置
            sm plugins load script_reloader.smx
            // 多特插件 使用cvar来控制脚本中特感数量相关的值，以及      跳过     Relax等的控制
            sm plugins load Si_SpawnSetting.smx
            // MVP 
            sm plugins load kills.smx
            // 技巧检测
            sm plugins load l4d2_skill_detect.smx
            // 加载超时踢出
            sm plugins load l4d2_kickloading.smx
            // tank刷新提示，4+玩家修改Tank的血量
            sm plugins load l4d2_tank_hp.smx
            // 死亡喷漆
            sm plugins load enhancedsprays.smx
            // 多人支持，用于创建生还者bot
            sm plugins load l4d_CreateSurvivorBot.smx
            // 多人支持，用于玩家数量管理
            sm plugins load l4dmultislots.smx
            // 防装备错乱
            sm plugins load transition_restore_fix.cfg
            // 关闭友伤
            sm plugins load no_friendly-fire.smx
            // 友伤提示
            sm plugins load l4dffannounce.smx
            // 尸体布娃娃
            sm plugins load l4d2_server_ragdoll.smx 
            // ai加强（新版
            sm plugins load l4d2_sb_ai_improver.smx
            // ai灌油
            sm plugins load scavengebotsds.smx
            // 闲置修复，防止角色错乱
            sm plugins load survivor_afk_fix.smx
            // 杂项插件，主要控制备弹倍率
            sm plugins load server_misc.smx
            // 玩家管理，!swapto，以及!s旁观
            sm plugins load playermanagement.smx
            // 三方图
            sm plugins load l4d2_abbw_msgr.smx
            // 自动切图
            sm plugins load MapChanger.smx
            // 超过950备弹提示
            sm plugins load l4d2_show_ammo_remaining.smx
            // 榴弹 正常化 可补备弹
            sm plugins load GrenadeLauncher_AmmoPile_patch.smx
            // m60 正常化 可补备弹
            sm plugins load M60_NoDrop_AmmoPile_patch.smx
            // tank 伤害公告
            sm plugins load l4d_tank_damage_announce.smx
            // witch 伤害公告
            sm plugins load l4d_witch_damage_announce.smx
            // 武器属性设定
            sm plugins load l4d2_weapon_attributes.smx
            // 喷子静态扩散
            sm plugins load l4d2_static_shotgun_spread.smx
            // 连跳崴脚插件
            sm plugins load l4d2_nobhaps.smx
            // 沙雕操作高光+慢动作
            sm plugins load l4d2_karma_kill.smx
            // 换图
            sm plugins load l4d2_mapchanger.smx
            // 开位
            sm plugins load slots_vote.smx
            // !zs 自杀插件
            sm plugins load l4d_kill_survivor.smx
            // 特感tp 仅在需要的配置中启用
            sm plugins load infected_teleport.smx
            // 回血系统 小于特定血量时回复虚血
            sm plugins load automatic_healing.smx
            // 回血系统 杀僵尸+3hp
            sm plugins load l4d_kill_heal.smx
            // 队伍面板 !panel
            sm plugins load l4d_teamspanel.smx
            // 标点 z-看
            sm plugins load l4d2_item_hint.smx
            // 标点 z-等等
            sm plugins load InstHint.smx
            // 队友连杀公告
            sm plugins load l4d_announcer_killing_spree.smx
            // 移除小僵尸尸体
            sm plugins load l4d_common_ragdolls_be_gone.smx
            // 爬梯开枪
            sm plugins load l4d2_ladder_rambos.smx
            // 显示生还者腿（玉足）
            sm plugins load _[L4D2]Survivor_Legs.smx
            // 黑白提示
            sm plugins load LMC_Black_and_White_Notifier.smx
            // 特感血条
            sm plugins load l4d_infectedhp.smx
            // 击杀反馈
            sm plugins load killsound.smx
            // 暂停（坏的）
            sm plugins load pause.smx
            // 进度 !current
            sm plugins load current.smx
            // 手雷秒丢
            sm plugins load l4d_grenade_throw.smx
            // 暖服机进图自动刷图
            sm plugins load warmbot_autorestart.smx
            // 丢物品（!g）
            sm plugins load l4d2drop.smx
            // r给物品
            sm plugins load l4d_gear_transfer.smx
            // debug
            //sm plugins load sm_vprofiler.smx
            // 模式展示，主用于查服bot
            sm plugins load config_show.smx
            // 踢bot
            sm plugins load kick_bot.smx
            // 服务器跳转
            sm plugins load serverhop.smx
            // 提示队伍推进进度
            sm plugins load l4d_coop_markers.smx
            // admin复活
            sm plugins load l4d_sm_respawn.smx
            // 根据端口cfg
            sm plugins load run_portcfg.smx
            // 刷特速度测试
            sm plugins load spawnspeed_test.smx
            //---------------------------
            // Matchmaking Plugins
            //---------------------------
            // confogl 本插件包是从药抗插件修改来的
            sm plugins load confoglcompmod.smx
            // 配置投票插件
            sm plugins load match_vote.smx
         ```
         </details>
      </details>


   * *coop_hard 逛街多人多特*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础8只15s，4人以上每多1人+2只，允许Relax阶段
      * Tank的血量倍率调整为"0.75;1.25;1.75;2.25"
      * 3倍特殊弹药包提供的弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。
      * 过关回满血
      * 拉人时间：3s
      * 投掷物没有预热时间，可以立刻丢出
      * 武器配置：v3
      * 近战对tank的伤害固定为450
      * 自动复活

      </details> 

   * *coop_fire 无限火力*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础8只0s，4人以上每多1人+2只D，跳过Relax阶段
         > note: 该模式初始6个生还者bot
      * 特感传送条件：5秒不可见
      * TANK现在会击飞倒地的和吃饼的生还
      * Tank的血量倍率调整为1.5/2.8/4.1/5.5
      * 近战对tank的伤害固定为450
      * 无限弹药和投掷物
      * 4倍特殊弹药包提供的弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 自动复活
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * 倒地受伤间隔修改为0.1s, 小僵尸倒地单次伤害修改为35
      * 生还倒地可使用主武器，可造成友伤，倒地射速调整为0.1s，可使用药品自救
      * 过关回满血
      * 默认关闭友伤
      * 拉人时间：3s
      * 投掷物没有预热时间，可以立刻丢出
      * 武器配置：v3
      </details>

   * *coop_himiko 秘密子能带飞*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础14只15s，4人以上每多1人+2只/-0s复活CD，允许Relax阶段
      * 特感传送条件：8秒不可见
      * 3倍弹药
      * 生还倒地可使用主武器，可造成友伤，倒地射速调整为0.1s
      * 投掷物没有预热时间，可以立刻丢出
      * 自动复活
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * Tank现在会击飞倒地的和吃饼的生还
      * Tank的血量倍率调整为1.2/2.4/3.0/4.0
      * 近战对tank的伤害固定为450
      * 过关回满血
      * 锁定专家难度
      * 投掷物没有预热时间，可以立刻丢出
      * 武器配置：v2
      </details>
   
   * *community5_multi 多人逛街死门*
      > 基于community5_noobplus
      <details>
      * 默认刷特：基础5只0s，4人以上每多1人加1特，跳过Relax阶段
      * 2倍特殊弹药包提供的弹药
      </details>

2. **写实系列**
   > 写实模式并不在本服计划之内

   * *realism_solo 写专单通*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础3只45s，允许Relax阶段
      * 锁定专家难度
      * 最多1名生还，最大玩家数限制为1
      </details>

3. **绝境系列**
   > 全绝境可投票开启绝境不停刷修复

   * *mutation4_noobplus 逛街绝境混野版*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础8只15s，允许Relax阶段
      * 3倍弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 锁定专家难度
      * 过关回满血
      * 最多4名生还
      * 启用绝境不停刷修复
      </details>

   * *mutation4_solo 绝境单通*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础8只15s，限制0只DPS特感，允许Relax阶段
      * 锁定专家难度
      * 过关回满血
      * 最多1名生还，最大玩家数限制为1
      </details>

   * *mutation4_ez 逛街绝境*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础14只15s，允许Relax阶段
      * 3倍弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 锁定专家难度
      * 过关回满血
      * 最多4名生还
      </details>

   * *mutation4 14特*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础14只15s，允许Relax阶段
      * 牛冲锋带有减伤/HT空爆伤害恢复
      * 3倍弹药
      * 锁定专家难度
      * 过关回满血
      * 最多4名生还
      </details>

   * *mutation4_expect 28特6控*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础28只15s，限制4只DPS特感，允许Relax阶段
      * 牛冲锋带有减伤/HT空爆伤害恢复
      * 4倍弹药
      * 锁定专家难度
      * 过关回满血
      * 最多4名生还，最大玩家数限制为4
      * 仅允许旁观者使用!panel查看队伍状态
      </details>

4. 死门系列
   * *community5_noobplus 逛街死门混野版*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础5只0s，跳过Relax阶段
      * 特感传送条件：8秒不可见
      * 3倍弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 锁定专家难度
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * 过关回满血
      * 最多4名生还
      </details>

   * *community5_ez 逛街死门12特0秒*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础12只0s，限制2只DPS特感，跳过Relax阶段
      * 特感传送条件：8秒不可见
      * 3倍弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 锁定专家难度
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * 过关回满血
      * 最多4名生还
      </details>

   * *community5 死门10特0秒*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础10只0s，限制2只DPS特感，跳过Relax阶段
      * 特感传送条件：8秒不可见
      * 牛冲锋带有减伤/HT空爆伤害恢复
      * 3倍弹药
      * 锁定专家难度
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * 过关回满血
      * 最多4名生还
      * 仅允许旁观者使用!panel查看队伍状态
      </details>

   * *community5_himiko 秘密子来了都过了*
      > 基于coop_base
      <details>
      <summary>配置细节</summary>

      * 默认刷特：基础24只0s，限制3只DPS特感，跳过Relax阶段
      * 特感传送条件：8秒不可见
      * 7倍弹药
      * 投掷物没有预热时间，可以立刻丢出
      * 允许复活
      * 锁定专家难度
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * 过关回满血
      * 武器配置：v3
      </details>

5. 开牢！
   > 从别人群偷来的模式，狠狠的开牢！

   * *community5_610 死门|6特10s*
     > 基于coop_base
     <details>
      <summary>配置细节</summary>

      * 默认刷特：基础6只10s，限制4只DPS特感，跳过Relax阶段
      * 特感传送条件：8秒不可见
      * 牛冲锋带有减伤/HT空爆伤害恢复
      * 3倍弹药
      * 锁定专家难度
      * 过关回满血
      * 最多4名生还
      * 仅允许旁观者使用!panel查看队伍状态
      </details>
      
   * *realism_miaomei 写专|秒妹老师の4k血妹*
     > 基于coop_base
     <details>
      <summary>配置细节</summary>

      * 默认刷特：基础3只45s，允许Relax阶段
      * 牛冲锋带有减伤/HT空爆伤害恢复
      * witch的血量为4000
      * 锁定专家难度
      * 最多4名生还
      * 仅允许旁观者使用!panel查看队伍状态
      </details>

   * *coop_fuckmap 战役|什么吊图*
     > 基于coop_base
     <details>
      <summary>配置细节</summary>

     * 默认刷特：基础6只15s，允许Relax阶段
     * TANK现在会击飞倒地的和吃饼的生还
     * 牛冲锋带有减伤/HT空爆伤害恢复
     * 投掷物没有预热时间，可以立刻丢出
     * 投掷物现在有更多功能
     * Tank的血量倍率调整为"1.2;1.5;2.0;2.5"
     * 近战对tank的伤害固定为450
     * 自动复活
     * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
     * 倒地受伤间隔修改为0.1s, 小僵尸倒地单次伤害修改为35，倒地可使用药品自救
     * 技能商店
     * 生还倒地可使用主武器，可造成友伤，倒地射速调整为0.1s
     * 电击器现在有攻击功能
     * 2倍特殊弹药包提供的备弹
     * 锁定专家难度
     * 过关回满血
     * 武器配置：v3
     * 3倍弹药
      </details>

   * *community2 感染季节|绝境14特*
      > 基于coop_base
     <details>
      <summary>配置细节</summary>

      * 默认刷特：基础6只15s，允许Relax阶段
      * ~~牛冲锋带有减伤/HT空爆伤害恢复~~ 但是没牛没HT
      * 3倍弹药
      * 锁定专家难度
      * 过关回满血
      </details>

   *coop_annelike 战役|饼干的Anne改战役*
      > 基于coop_base

      * 默认刷特：基础6只15s，跳过relax阶段
      * Tank的血量倍率调整为"1.5;1.5;1.8;2.0"
      * anne同款AI增强
      * 过关回满血

   * *realisn_jimen 几门*
      > 施工中 基于coop_base
      <details>
      * 默认刷特：基础6只15s，跳过relax阶段
      * 写实模式，但倒地即死
      * 特感ai增强
      * 近战范围调整为175
      * 坦克伤害调整为专家20
      * 允许回血：<40每0.7秒回复1，受伤暂停5秒。击杀小ss和特感+3，爆头额外+4（一共+7），上限200
      * 3倍弹药
      * 锁定专家难度
      * 过关回满血
      </details>
   * *coop_rpg skyrpg*
      > 我去 真搞上rpg了
      <details>
      * !部分投票设置没有作用
      </details>
6. pro配置

   * *professional base*
      > pro系列的基础配置
      * 相比coop_base, 移除绝大多数娱乐性插件
      * 移除投票插件，不能在中途修改难度 ;)

# 配置细节

   * 每类特感的数量
  
      按照Hunter->Jockey->Smoker->Charger->Spitter->Boomer依次分配，直到分配的特感数到达限制，

      如果设置了DPS限制，则当分配完Charger之后，如果Spitter和Boomer的总数超过了限制则直接跳至下一圈，即Hunter。

      例如，19特不限制dps则为除HT外的特感都限3，HT限4，而16特限制2dps则口水胖子限制1，HT猴子限制4，舌头牛限3

   * Relax
    
      简单地说，就是是否会在倒地停刷特感/出门秒刷特感/无视生还者的导演压力值。相当于无CD

      ~~即使禁用Relax并把复活CD设置为0秒，也不会死一只补一只，因为导演系统每类特感刷出后有5/20秒的内置CD，目前还没有办法修改~~

      ~~当跳过relax时，每类特感的复活CD将强制设置为0.5s。现在刷特慢的主要原因猜测为特感死亡后疑似仍然占一个slot约7秒，以及部分情况下，导演将单类特感的cd强制设置为5s。~~

      现在跳过Relax时，如无额外投票，将不影响刷特速度。可在跳过基础上额外增加刷特速度：      
      > 当刷特速度为0s28特时，括号内刷特速率为100s内的平均刷特速度。当总特感降低时，因为每类特感数量减少，刷特速率也会随之降低。     
      > 0 - 不启用（8特/5S）     
      > 1 - 设置特感内置CD为1S，这将大幅加快补特速度（约17特/5s）       
      > 2 - 设置特感内置CD为1S+自动踢出非口水死亡特感（约40特/5s）    
      
      刷特速率越快，刷特速度越接近于设置的刷新时间



   * 刷新时间
    
      指的是每个特感槽位的CD。因为导演系统的原因，刷新时间结束后不一定立刻会刷特。一般要大于这个时间。

   * 自动模式
      
      该模式下的刷特配置可以使用!votemenu手动调整，但如果Relax被跳过的配置，votemenu修改后，Relax在换图后重置

   * [武器配置](weapons.md)
   
      武器配置会在每次换图时重置为模式默认

   * 绝境不停刷修复

      部分地图会无视Relax阶段直接刷特，也有部分地图设置了不合理的Relax时长，这个插件解决了问题本身（

# 通用插件修复

   > generalflxes.cfg的内容

   *  **Requirements** 前置插件，部分插件需要前置才能正常运行
   *  **bequiet.smx** 隐藏一些没必要显示的提示
   *  **l4d_skip_intro.smx** 跳过地图开场
   *  **command_buffer.smx** 修复不正确的cvar值导致的'Cbuf_AddText: buffer overflow' 
   *  **Tickratefix.smx** 高Tick下开关门速度，重力修正
   * **l4d2_pistol_delay.smx** 修复在高刷新率下，双手枪开火速度很高
   * **l4d_votepoll_fix.smx** 更改可投票的玩家数量
   * **l4d2_lagcomp_manager.smx** 实体延迟补偿（需要启用sv_unlag）
   * **l4d_console_spam.smx** 防止某些错误/警告信息输出到服务器控制台
   * **l4d2_script_cmd_swap.smx** 阻止script cmd指令并用一个`logic_script`实体代替执行（否则会导致内存泄漏）
   * **playermanagement.smx** 可使用指令sm_swap系列指令调整玩家队伍，允许玩家通过!s自行旁观
   * **l4d2_sound_manipulation.smx** 阻止某些声音（心跳等）
   * **frozen_tank_fix.smx** 修复某些情况坦克不会死亡
   * **l4d2_melee_damage_control.smx** 修改近战对特感的伤害，无论击中哪里，都会造成固定伤害。控制近战对牛/坦克的伤害。
   * ~~**fix_fastmelee.smx** 禁用速砍~~
   * **l4d2_jockeyed_ladder_fix.smx** 修复被猴子控的生还从梯子上缓慢滑下
   * **l4d2_no_post_jockey_deadstops.smx** 修复被猴子控之后仍然能自己推开
   * **l4d2_jockey_jumpcap_patch.smx** 防止猴子在技能CD时能用普通跳跃控人(?存疑)
   * **l4d2_shadow_removal.smx** 移除影子来防止在某些场景因为影子透视
   * **l4d2_explosiondmg_prev.smx** 环境爆炸伤害将不会影响特感
   * **l4d2_car_alarm_hittable_fix.smx** 当坦克拍警报车时，禁用警报车/确保生还碰到警报车时正确触发警报
   * **l4d2_ai_damagefix.smx** 修复AI HT空爆伤害（玩家HT 150)和牛牛减伤，某些配置禁用
   * **l4d2_ladderblock.smx** 生还能顶开在楼梯上的特感（特感也可顶开生还，防止梯子卡克）
   * **FollowTarget_Detour.smx** 修复CMoveableCamera::FollowTarget崩溃
   * **l4d_fix_deathfall_cam.smx** 修复"point_deathfall_camera" 和 "point_viewcontrol*" 永久锁定视角
   * **l4d_pause_message.smx** 如果服务器不支持暂停，阻止pause指令
   * **l4d2_boomer_shenanigans.smx** 确保胖子被推时无法吐人
   * **sv_consistency_fix.smx** 检查一些文件防止作弊
   * **l4d2_hltv_crash_fix.smx** 防止stv崩服
   * **l4d_checkpoint_rock_patch.smx** 在安全屋的玩家，石头判定更严格
   * **l4d2_ellis_hunter_bandaid_fix.smx** 修复Ellis被HT控有更长的起身
   * **l4d2_boomer_ladder_fix.smx** 修复胖子跳跃更容易黏在爬行轨迹上
   * **l4d2_spit_cooldown_frozen_fix.smx** 修复口水技能不进CD
   * **l4d2_spit_spread_patch.smx** 修复口水的一些[奇怪问题](https://github.com/SirPlease/L4D2-Competitive-Rework/commits/master/addons/sourcemod/scripting/l4d2_spit_spread_patch.sp)
   * **l4d_fix_punch_block.smx** 修复小僵尸可能挡住克拳头
   * **l4d_fix_finale_breakable.smx** 修复终章特感无法打破某些墙
   * **l4d2_fix_firsthit.smx** 修复小僵尸出拳很快
   * **l4d2_rock_trace_unblock.smx** 防止HT/猴子/某些生还影响石头判定
   * **l4d_static_punch_getup.smx** 固定被拍后的起身时间
   * **annoyance_exploit_fix.smx** 修复双重投票
   * **l4d_fix_shove_duration.smx** 修复游戏不符合z_gun_swing_duration的值
   * **l4d2_jockey_hitbox_fix.smx** 修复某些情况不能用推救被猴子控的人
   * **l4d_consistent_escaperoute.smx** 没有随机路线（如c5m3的公墓）
   * **l4d2_fix_rocketjump.smx** 修复投掷物/口水/榴弹跳
   * **l4d2_jockey_teleport_fix.smx** 修复虚空猴
   * **l4d2_charge_target_fix.smx** 修复牛的一些问题
   * **l4d2_shove_fix.smx** ~~不知道什么用~~
   * **l4d2_scripted_tank_stage_fix.smx** 修复有的时候终章卡住不刷克
   * **specrates.smx** 旁观30tick
   * **l4d2_fix_common_flee.smx** 修复蹲下/跳跃中的小僵尸无法被推的问题（管道战神————）
   * **Charger_Collision_patch.smx** 修复牛只能撞同模型生还一次
   * **Defib_Fix.smx** 修复电击器电起错误目标
   * **l4d_revive_reload_interrupt.smx** 修复换弹时救队友导致卡弹
   * **l4d_survivor_identity_fix.smx** 修复5+玩家时的装备混乱
   * **l4d2_ladder_patch.smx** 修复因为梯子导致的游戏崩溃
   * **l4d2_vocalizebasedmodel.smx** 玩家语音基于玩家所在的模型发出
   * **lfd_both_fixSG552.smx** 修复SG-552开镜时重新装弹等的fov问题
   * **lfd_both_fixUpgradePack.smx** 修复5+玩家时弹药包的一些问题
   * **survivor_afk_fix.smx** 闲置修复
   * **transition_restore_fix.smx** 多人修复，修复中途进来的玩家接管已在游戏内玩家的bot
   * **witch_prevent_target_loss.smx** 防止witch的仇恨丢失
   * **Witch_Target_patch.smx** 修复witch目标错误
   * **l4d_reload_fix.smx** 修复满弹时，如果修改弹匣数仍然显示换弹动作。修复喷子在15发子弹以后就不再重装子弹。