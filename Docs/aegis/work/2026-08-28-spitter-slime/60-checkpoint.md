# TodoCheckpointDraft

- current todo：完成本轮验证并交付最新物理轨迹修正。
- active slice：最终 QA 已通过，准备交付 verified evidence；实服碰撞/视觉检查仍是部署后残余风险。
- completed todos：已读取原始意图、基线和设计；已先观察物理/生命周期契约 RED；已移除手动位置积分和衰减反弹；已加入 `MOVETYPE_FLYGRAVITY`、引擎 bounce、速度 steering、可配置默认 2x 索敌、严格 `<100` 命中、3 秒 idle/5 秒 tracking timeout；已更新模式 ConVar、重新编译二进制并完成契约、编译、空白和 owner 审计。
- evidence refs：`Docs/aegis/specs/2026-08-28-spitter-slime-design.md`；`Docs/aegis/work/2026-08-28-spitter-slime/50-evidence.md`；`tests/l4d2_spitter_slime_contract.tests.ps1`；本轮最终 SourcePawn 编译输出和 `git diff --check`。
- blocked-on：无；没有可用的 L4D2 实服是已记录的部署验证边界，不阻塞静态/编译证据。
- next step：部署到 L4D2 后执行设计文档中的碰撞、目标命中、特效、伤害、清理和击退手动检查。
- drift check：continue；仍只影响目标插件 owner、`versus_isfullshit` 配置、对应契约和工作记录；两个无关未跟踪工作目录未触碰；旧 owner 的 retirement track 保持明确。
