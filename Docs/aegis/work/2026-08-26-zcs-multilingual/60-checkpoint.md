# 多语言支持任务检查点

## TodoCheckpointDraft

- 已完成：读取基线、取得用户确认、写入设计/计划、添加多语言契约并观察 RED、添加 `en`/`chi` phrases、接入显式 `%T`、按玩家生成 HUD、Tank 回归、SourcePawn 编译。
- 当前切片：最终 QA 与差异检查已完成。
- 下一步：向用户交付变更摘要、验证证据和残余风险。

## EvidenceBundleDraft

- `tests/l4d2_zcs_multilingual.tests.ps1`：RED 后 GREEN，当前 GREEN。
- `tests/l4d2_zcs_tank_switch.tests.ps1`：通过。
- `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe`：SourcePawn `1.12.0.7221` 编译退出码 `0`。
- 全量 17 项静态测试：16 项通过；`check_release_updater_names.ps1` 因缺少仓库文件 `install_release_updaters.sh` 失败。
- 空白/副作用检查：源码与任务记录 `git diff --check` 无输出；临时验证 `.smx` 不存在。

## DriftCheckDraft

- 范围：仍只修改 `l4d2_zcs_redux` 的玩家显示层及其测试/任务记录。
- 兼容性：Tank 选择和限制、普通特感总数、既有配置未改变；未暂存前序用户改动。
- Owner/retirement：旧硬编码玩家提示和共享 HUD panel 由专用 phrases 与逐玩家 panel 接替；内部英文类别数组仍保留给调试和命令匹配。
- 决策：`continue`，证据已足以交付已验证范围；实时服务器验证是外部化残余风险，不阻塞静态/编译检查。
