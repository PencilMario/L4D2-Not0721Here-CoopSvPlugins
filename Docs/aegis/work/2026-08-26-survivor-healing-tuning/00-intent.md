# Task Intent

调整 `versus_isfullshit` 的生还者回血行为：自动回血总目标为 200、间隔为 0.3 秒但保持默认单次回复量；开局回血值为 500，并在该值大于 100 时同步设置生还者最大生命值。

范围限定为 `versus.cfg`、`level_start_heal.sp` 及其编译后的可选插件。击杀回血不变。
