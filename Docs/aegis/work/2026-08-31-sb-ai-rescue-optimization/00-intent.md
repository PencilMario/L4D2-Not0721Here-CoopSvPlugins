# Task Intent Draft

## Requested outcome

优化 `l4d2_sb_ai_improver.sp` 的救援 Jockey/Smoker 性能，重点降低约 10 个生还者 Bot 时 `OnPlayerRunCmd` 中重复救援计算的成本。

## Approved scope

1. 救援逻辑在廉价条件不满足时提前返回，并给每个 Bot 增加救援评估间隔。
2. Jockey/Smoker 使用不查询骨骼的专用瞄准位置和低成本可见性检查。
3. 由抓取/释放/死亡/复活事件维护救援攻击者、受害者和候选 Bot 关系。

## Non-goals

- 不改变原生 `LiberateBesiegedFriend` 行为。
- 不改变普通特感原有通用瞄准路径。
- 不改变 `ib_help_pinned_enabled`、反应延迟、射击/推搡距离或 `ib_help_pinned_reaction_bots=0` 的语义。
- 不在本次工作中声称已经完成真实 L4D2 服务器上的帧耗时验证。

## Risk hints

- 事件字段和释放时序必须覆盖 Hunter、Smoker、Jockey、Charger 携带/扑击状态。
- 事件协调器必须在地图、回合、客户端生命周期和失控事件后清理状态。
- 低成本瞄准会减少骨骼候选点数量，需要保留有效的目标位置和可见性保护。
