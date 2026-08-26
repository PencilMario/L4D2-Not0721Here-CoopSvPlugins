# Zombie Character Select 多语言支持设计

## 已批准范围

只支持 `en` 和 `chi`。用户可见的聊天提示、限制 HUD 和感染者类别名称使用插件专用 phrases 文件；内部调试日志仍可使用英文类别名。

## 方案比较

1. **只替换聊天提示。** 改动最小，但 HUD 和动态类别名仍固定英文，不能满足完整的玩家可见多语言需求。
2. **逐玩家 `%T` + 逐玩家 HUD（推荐）。** 翻译目标始终明确，混合语言玩家各自看到正确语言；只改动消息/HUD 层，不触碰选择和限制状态机。
3. **统一设置全局翻译目标后继续共用 HUD。** 代码较短，但共享面板只能包含一种语言，且异步/循环调用容易依赖残留的全局翻译目标。

采用方案 2。

## 结构与数据流

`OnPluginStart` 调用 `LoadTranslations("l4d2_zcs_redux.phrases")`。聊天消息通过 `%T` 把玩家索引作为翻译目标参数传入。类别 ID 继续由现有数组处理；新增一个与类别 ID 对齐的 phrase-key 数组，辅助函数将类别名格式化为指定玩家的本地化文本。HUD 遍历可见的感染者玩家，为每人创建面板、翻译标题/类别名/冷却标记、发送后立即关闭。

翻译键使用插件前缀，避免与其他插件冲突：

`ZCS_NotifyKey`、`ZCS_LimitsUp`、`ZCS_CooldownWait`、`ZCS_ClassesUpAllow`、`ZCS_ClassesUpDeny`、`ZCS_NotifyLock`、`ZCS_SwitchLock`、`ZCS_HudTitle`、`ZCS_HudLine`、`ZCS_HudCooldown`，以及 `ZCS_Class_Smoker` 至 `ZCS_Class_Survivor` 中 HUD/提示需要的类别名称键。

## `%T` 使用约束

单个客户端输出采用：

```sourcepawn
PrintToChat(client, "%T", "ZCS_NotifyKey", client, ...);
FormatEx(buffer, sizeof(buffer), "%T", phrase, client, ...);
```

不使用依赖全局目标的 `%t`。翻译后的类别名先按目标客户端格式化为字符串，再作为外层消息的 `%s` 参数，避免嵌套翻译目标不明确。

## 兼容性与错误边界

- `en`、`chi` 两个语言项都必须存在；SourceMod 的普通语言回退机制继续负责其他语言玩家。
- `sm_buy` 的英文类别参数、内部数组、调试日志和 ConVar 行为不变。
- HUD 只有原来符合条件的感染者鬼魂玩家会收到，面板关闭条件和显示周期不变。
- 翻译资源缺失时由 SourceMod 按其标准 phrases 回退；源码不增加第二套硬编码消息回退。

## 验证

新增 PowerShell 静态契约测试，先在基线源码上确认失败，再检查 phrases 键、`LoadTranslations`、显式 `%T` 目标、逐玩家 HUD 和无旧硬编码提示。随后用仓库规定的 SourcePawn 编译器编译，并运行前序 Tank 契约测试和差异检查。没有 live server 时，明确记录游戏内混合语言 HUD 的运行时验证未完成。
