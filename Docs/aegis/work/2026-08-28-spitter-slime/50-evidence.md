# Spitter Slime Replacement Evidence

## 本轮最新验证

- RED：加入引擎物理、速度 steering、2 倍索敌速度、100 命中半径、3 秒 idle 生命周期和索敌超时契约后，旧实现按预期失败。
- GREEN：`& "$PSHOME\pwsh.exe" -NoProfile -File .\tests\l4d2_spitter_slime_contract.tests.ps1` 输出 `Spitter slime contract passed`，退出码 `0`。
- Compile：使用 `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe`（SourcePawn `1.12.0.7221`）编译 `addons/sourcemod/scripting/l4d2_spitter_slime.sp`，退出码 `0`；输出 `Code size: 47272 bytes`、`Data size: 245736 bytes`、`Stack/heap size: 17212 bytes`、`Total requirements: 310220 bytes`，无编译错误，生成目标 `.smx`。
- Whitespace：`git diff --check` 退出码 `0`，无输出。
- Owner audit：目标模式、目标插件目录和 SourcePawn 源码目录没有 `L4D2 Spitter Supergirl` / `l4d_ssg_` 残留；检查输出为 `No retired Spitter owner references in scoped paths.`。
- Binary：`addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx` 存在，大小 `24128` bytes；本轮最终 SHA-256 为 `6DF65AD06A8AFF758212746F9E5AC83EB7CF776DEFD7A5254A0DA93F33912CC0`。
- Worktree：修改范围为设计/证据记录、粘液 SourcePawn、目标模式 ConVar、契约测试和新 `.smx`；两个既有无关未跟踪工作目录未被触碰。

## 已由静态/编译证据证明

- 粘液使用 `L4D2_SpitterPrj` 创建原生可见 `spitter_projectile`，保留实体碰撞 hull，使用 `MOVETYPE_FLYGRAVITY` 和引擎 bounce collision；插件只通过速度向量 steering，旧手动位置积分和 `SLIME_BOUNCE_DAMPING` 已移除。
- 每只 Spitter 独立维护粘液实体引用、生成计时器、生成/索敌生命周期和汽油桶引用；目标初选经过 `TR_TraceRayFilterEx` 可视性筛选，目标距离小于配置半径（默认 `100`）时通过 `SDKHooks_TakeDamage` 命中。
- 索敌速度倍率是可配置 ConVar，默认 `2.0`；无目标超过 `3.0` 秒、已索敌超过 `5.0` 秒未命中时清理粘液；死亡、离队、断线、回合/地图清理共用 owner cleanup。
- `L4D2_ActivateAbility_Spitter` 永久替换 `IN_ATTACK`；汽油桶碰撞/两秒引信只触发一次爆炸，保留粒子、声音、SDKDamage 和直接速度击退路径；没有 `point_hurt`、`env_explosion`、Fling 或 `IN_ATTACK2`。

## Advisory review 与运行时边界

- 已请求只读代码审查，但代理在等待窗口内未返回可用报告，之后已关闭；未把代理状态当作通过依据。主线程完成源码、接口、配置和 diff 审查。
- 当前环境没有可用的 L4D2 实服。粘液/汽油桶在游戏引擎中的实际碰撞反射、客户端模型/粒子显示、每只 owner 的实服清理、真实 SDKDamage 数值和直接击退手感仍需部署后检查。

## Evidence boundary

- Evidence Used：本轮失败/通过契约、SourcePawn 编译输出、`git diff --check`、owner `rg` 审计、目标二进制存在性和 SHA-256。
- Not Loaded：没有加载完整 L4D2 实服日志、碰撞录像或客户端截图；这些运行时 payload 在当前环境不可用。
- Confidence：B——源码和编译/静态契约有直接证据，真实引擎碰撞和视觉表现仍是明确的部署残余风险。
