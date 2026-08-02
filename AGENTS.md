# Project Instructions

## SourcePawn Compilation

Compile `MapChanger.sp` from PowerShell with the project's known-good SourcePawn 1.12 compiler and include paths:

```powershell
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\MapChanger.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\MapChanger.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

The duplicate final include path from the original command is unnecessary. Existing warnings in `localizer.inc` and legacy `MapChanger.sp` code are accepted when compilation reports `Compilation successful.`
