# Verification evidence

## Automated evidence

- Baseline contract check failed before implementation because
  `sm_reloadscript` remained and both Director forwards were absent.
- Compiler: `E:/GithubKu/L4d2_0721sv_plugins/spcomp.exe`, version
  `1.12.0.7221`.
- Include order places the Competitive-Rework include directory before the
  repository include directory. This selects its renamed l4d2util survivor
  constants and avoids the known duplicate declarations with Left4DHooks.
- Final compilation: exit 0, 0 errors, 1 pre-existing deprecation warning from
  `include/halflife.inc:655`; output generated as isolated
  `addons/sourcemod/scripting/compiled/Si_SpawnSetting.smx`.
- Static contract: no `sm_reloadscript` string in `Si_SpawnSetting.sp`; both
  `L4D_OnGetScriptValueInt` and `L4D_OnGetScriptValueFloat` are present.
- `git diff --check`: exit 0.
- Changed runtime source set: only `Si_SpawnSetting.sp`; no mode `.nut` or
  `script_reloader.sp` edit.

## Runtime verification still required

On a server with Left4DHooks loaded, test coop, realism, and mutation4:

1. Set `si_spawn_max_specials` to 3 and 6 and observe the concurrent SI ceiling.
2. Change `si_spawn_respawn_interval` and observe subsequent SI slot cooldowns.
3. Test `si_spawn_dps_special_limit` at 0, 1, and a value above the SI ceiling.
4. Toggle `si_spawn_relax_enabled` and observe normal pauses versus continuous pressure.
5. Join and leave with `si_spawn_auto_scale_enabled 1` and verify count/time scaling.
6. Exercise `si_spawn_fast_respawn_mode` values 0, 1, and 2.

Local evidence proves compilation and static ownership migration; it does not
prove live Director key-query behavior for every game mode.
