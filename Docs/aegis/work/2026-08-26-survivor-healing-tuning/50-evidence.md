# Verification Evidence

## Contract test

- RED command: & 'Docs\\aegis\\work\\2026-08-26-survivor-healing-tuning\\verify.ps1'
- RED result: exit code 1 with automatic_healing_max is not 200 against the unchanged baseline.
- GREEN command: the same script after the config/source changes.
- GREEN result: exit code 0 and Healing contract passed.

The contract checks the exact automatic_healing_max 200, automatic_healing_repeat_interval 0.3, and level_start_heal_health 500 directives; it also asserts that no automatic_healing_health directive exists and that the guarded m_iMaxHealth assignment is present.

## Compilation

Command:

```powershell
& 'E:\\GithubKu\\L4d2_0721sv_plugins\\spcomp.exe' `
  'E:\\GithubKu\\L4D2-Not0721Here-CoopSvPlugins\\addons\\sourcemod\\scripting\\level_start_heal.sp' `
  '-oE:\\GithubKu\\L4D2-Not0721Here-CoopSvPlugins\\addons\\sourcemod\\plugins\\optional\\level_start_heal.smx' `
  '-iE:\\GithubKu\\L4D2-Not0721Here-CoopSvPlugins\\addons\\sourcemod\\scripting\\include' `
  '-iE:\\GithubKu\\L4D2-Not0721Here-CoopSvPlugins\\addons\\sourcemod\\scripting' `
  '-iE:\\GithubKu\\L4D2-Competitive-Rework\\addons\\sourcemod\\scripting\\include'
```

Result: SourcePawn Compiler 1.12.0.7221 exited 0. Output sizes were code 8248 bytes, data 3448 bytes, stack/heap 16540 bytes, total requirements 28236 bytes. The generated addons/sourcemod/plugins/optional/level_start_heal.smx exists and is 6379 bytes.

## Diff and scope

- git -c core.whitespace=cr-at-eol diff --check: exit 0, no output.
- Working tree contains the three requested deployed-file changes plus the scoped Aegis task records.
- The unchanged kill-heal plugin still calculates its combined cap as `m_iMaxHealth + 100`; with the requested maximum of 500, that derived cap is 600.
- The source diff is four added lines; the profile diff changes the interval and target and adds the level-start CVar.

## Residual risk

No live L4D2 server was available in this workspace. HUD display, health-buffer interaction with 500 maximum health, the resulting 600 combined kill-heal cap, and respawn/bot replacement behavior remain deployment-time manual checks.
