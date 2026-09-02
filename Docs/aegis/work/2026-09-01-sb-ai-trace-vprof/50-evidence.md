# Trace/VProf 优化验证证据

## 静态合同

在当前工作区运行全部 `tests/*.tests.ps1`：35/35 通过。新增/修改的 Trace、缓存、运行时和重载降级合同均通过：

- `l4d2_sb_ai_trace_metrics.tests.ps1`
- `l4d2_sb_ai_visibility_cache.tests.ps1`
- `l4d2_sb_ai_vector_trace_cache.tests.ps1`
- `l4d2_sb_ai_trace_filter_cache.tests.ps1`
- `l4d2_sb_ai_aim_trace_cache.tests.ps1`
- `l4d2_sb_ai_runtime_budget.tests.ps1`
- `l4d2_sb_ai_degraded_load.tests.ps1`

本次完整运行命令为：

```powershell
Get-ChildItem tests/*.tests.ps1 | Sort-Object Name | ForEach-Object {
    pwsh -NoProfile -File $_.FullName
}
```

结果汇总：`SUMMARY total=35 passed=35 failed=0`。

## 编译

使用项目 SourcePawn 1.12 编译器编译 `l4d2_sb_ai_improver.sp`，退出码为 0，生成 `addons/sourcemod/plugins/l4d2_sb_ai_improver.smx`（代码大小 305680 bytes）。本次编译未报告错误或警告。

## 实现证据

- 实体 LOS：每 observer 64 槽、16 组、4-way，key 含 entref/mask/mode，并校验 observer/target 位置；过期统一为 `GetProcessCacheExpiry()`。
- 向量 LOS：64 槽、4-way，8-unit 量化 hash 后复核原坐标、mask 和 RayType；只缓存 boolean，地图/时钟回退显式清空。
- `Base_TraceFilter`：目标实体先命中；普通实体 O(1) 返回 false；门分类在注册/未知慢路径只探测一次，动态门状态按 `GetProcessCacheExpiry()` 缓存并由门输出主动失效。
- Aim Trace：以 client command generation 为边界，同一 command 且眼位/角度未变时复用；不跨 command 使用 process TTL。
- 重载降级：增加自动 EMA 帧时长等级和强制等级 ConVar；等级 1/2/3 依次减少实体 LOS fallback、骨骼解算、NavArea 角点 Trace、Tank 道具候选和手雷 ground Trace；降级位置快照按 `ib_process_time` 共享。

## 未验证项

当前没有本地 L4D2 实时服务器，因此尚未取得固定地图/人数/tickrate 下的新 VProf 采样，也未完成 common infected 压力、开火选择和三点 LOS 行为回放。部署前应按分析计划采样至少 1000 帧，并报告每帧归一化指标。

## 证据边界

- 静态合同和编译是本次已验证范围；它们不能替代真实服务器上的 VProf 或行为回放。
- 未加载两份 VProf 原始全文，仅使用分析计划中已归一化的指标摘要；原始文件仍保留在用户指定的下载目录，可按需复查。
- 置信度：B。核心代码路径有直接静态/编译证据，性能收益和行为等价性仍需真实服务器采样确认。
