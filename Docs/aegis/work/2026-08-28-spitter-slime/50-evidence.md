# Spitter Slime Replacement Evidence

## Verification

- RED：扩展审查契约后，`& "$PSHOME\pwsh.exe" -NoProfile -File .\tests\l4d2_spitter_slime_contract.tests.ps1` 按预期失败，先报告计时器重建、enable 热修改、live 标志、物理伤害隔离、冷却失败回退和旧根目录二进制残留；后续增加粒子预缓存与失效 owner attacker 契约后，又按预期报告这两项缺失。
- GREEN：同一契约在修复后输出 `Spitter slime contract passed`。
- Latest correction RED：加入“活动汽油桶仍保持 `IN_ATTACK` 拦截”的契约后，测试按预期失败并明确报告该 guard 缺失；恢复 guard 后重新通过。
- Compile：`E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe` 使用项目 SourcePawn `1.12.0.7221` 编译 `l4d2_spitter_slime.sp`，生成 `addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx`，退出码为 `0`。最新编译器输出为 `Code size: 56288 bytes`、`Data size: 310916 bytes` 和 `Total requirements: 384116 bytes`，未报告 warning；目标二进制大小为 `26468` bytes。
- Whitespace：`git diff --check` 退出码为 `0`，无输出。
- Owner audit：在 `cfg/cfgogl/versus_isfullshit`、目标插件目录和 SourcePawn 源码目录内检索 `L4D2 Spitter Supergirl` / `l4d_ssg_` 无结果；模式 loader 保留新插件，模式配置保留全部新 ConVar。
- Fix commits：`6da5d6c3 fix(spitter): 修复生命周期与煤气罐回退`；`fbd2147f fix(spitter): 补齐特效预缓存与伤害回退`。

## Scope proven

- 新插件使用 `L4D2_SpitterPrj` 创建原生可见 `spitter_projectile`，按每只喷吐者维护粘液引用、生成计时器和汽油桶引用。
- 粘液目标经过 `TR_TraceRayFilterEx` 可视性筛选，粘液命中和汽油桶范围伤害均使用 `SDKHooks_TakeDamage`。
- `L4D2_ActivateAbility_Spitter` 是 `IN_ATTACK` 永久替换入口；汽油桶使用可见模型，碰撞只触发一次爆炸，包含两组粒子和爆炸声音，并以直接速度写入击退；活动汽油桶存在时仍保持拦截。
- 换图可重建全局更新计时器；`l4d2_spitter_slime_enable` 热修改会停止/清理或重启当前喷吐者状态；汽油桶物理伤害缩放为 `0.0`；冷却设置失败会删除汽油桶并返回原版能力回退。
- 爆炸粒子在加载/换图时显式预缓存；owner 已失效时仍以有效 inflictor 作为 SDKDamage attacker，避免向伤害 native 传入无效 `0`。
- 旧目标模式 loader、旧源文件、目标目录旧二进制和根目录重复旧二进制均不再作为 owner。

## Advisory review

- 已请求 Ptolemy 对 `6d75e3b3..6da5d6c3` 做独立只读审查，但代理未在等待窗口内返回报告，之后已不可查询；未把该请求当作通过依据。
- 主线程随后重新读取完整源码、Left4DHooks / SDKHooks 接口和现有粒子实现，发现并以 RED→GREEN 修复粒子预缓存和失效 owner attacker 两个风险；本地审查结论仍是 advisory evidence，不是高层级 merge 或运行时 completion 授权。

## Runtime follow-up

当前环境没有可用的 L4D2 实服，因此以下项目仍需部署后验证：粘液和汽油桶在引擎中的实际碰撞与显示、每只喷吐者上限和独立清理、随机可视目标命中、爆炸特效/声音、SDKDamage 实际数值，以及直接速度击退不会产生 Charger 式硬直。用临时输出做同源码编译时，编译退出码为 `0`，但 `.smx` 的 SHA-256 每次可能不同，因此未把二进制哈希相等作为验收条件。
