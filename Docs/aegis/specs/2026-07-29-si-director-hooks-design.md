# SI Director hook migration design

## Intent

Move special-infected spawn ownership from mode VScript reloads into
`Si_SpawnSetting.sp`. This first migration removes that plugin's dependency on
`sm_reloadscript` while preserving the existing ConVars, commands, player-count
scaling, class allocation, Relax control, and fast-respawn behavior.

Mode `.nut` files and `script_reloader.sp` remain present because they still own
unrelated mode behavior. Removing those files is explicitly deferred.

## Architecture

`Si_SpawnSetting.sp` becomes the single owner of computed SI settings. Whenever
an input ConVar or the human-player count changes, it recalculates cached values
for the global SI limit, six class limits, and spawn interval.

Left4DHooks forwards expose those cached values whenever `CDirector` reads the
corresponding script keys:

- Integer forward: global, base, dominator, and per-class limits.
- Float forward: special respawn interval, slot countdown, and Relax tempo keys.

Keys with and without the `cm_` prefix are handled where applicable so coop,
realism, mutation, and community modes can query either form.

Ordinary Director ConVars used by the old Relax branch are cached at plugin
startup and written directly when `si_spawn_relax_enabled` changes. The plugin does not use
`FindConVar` inside hot forwards.

## Data flow

1. A command, ConVar change, round start, player join, or delayed disconnect
   updates the configured SI count or interval.
2. One refresh function validates inputs and calculates all six class limits.
3. The refresh function applies Relax-related ordinary ConVars.
4. Future Director reads receive the cached values through
   `L4D_OnGetScriptValueInt` and `L4D_OnGetScriptValueFloat`.
5. Existing live SI are not killed. Existing countdowns may finish under their
   previous state; subsequent Director decisions use the new values.

## Preserved behavior

- `si_spawn_max_specials` controls the maximum and base SI limits.
- `si_spawn_respawn_interval` controls special respawn and slot countdown values.
- `si_spawn_dps_special_limit` bounds the combined configured Boomer and Spitter allowance.
- Allocation retains the order Hunter, Jockey, Smoker, Charger, Spitter,
  Boomer and grants every class at least one allowance when the global limit is
  below six, while the global limit still controls actual concurrency.
- `si_spawn_relax_enabled = 0` overrides tempo values and shortens initial, battlefield, and
  offer intervals. `si_spawn_relax_enabled = 1` leaves script tempo keys to the active mode and
  restores the ordinary ConVars to the old VScript values.
- `si_spawn_fast_respawn_mode` retains its existing direct timer manipulation and optional
  cleanup of dead infected Bots.
- Automatic player-count scaling and `sv_setmax` validation remain intact.

For the invalid/edge case `si_spawn_dps_special_limit <= 0`, Boomer and Spitter limits are
zero. This intentionally fixes the old post-allocation check that could still
grant them slots.

## Compatibility boundary

This phase removes every `sm_reloadscript` call from `Si_SpawnSetting.sp` only.
It does not delete or disable `script_reloader.smx` globally and does not edit
mode `.nut` files. Consequently, a mode script loaded independently may still
contain its historical SI assignments, but the Director read forwards are the
authoritative final override while this plugin is loaded.

The migration continues to require Left4DHooks. Other plugins returning a
handled result for the same Director keys are a configuration conflict and are
outside this phase's scope.

Non-SI behavior in mode scripts, including weapon conversion, map spawner
cleanup, and boss prohibition, remains owned by those scripts.

## Failure handling

- Missing ordinary Director ConVars are tolerated and logged once; available
  settings continue to work.
- Cached limits are initialized before the first Director query.
- Spawn interval is clamped to zero or greater, and the total SI count remains
  constrained by `sv_setmax` when that ConVar is available.
- The hot forwards do not print by default. Any temporary key tracing used for
  runtime verification must be opt-in.

## Verification

Static verification must compile `Si_SpawnSetting.sp`, confirm that it contains
no `sm_reloadscript` dependency, and inspect the diff for unrelated changes.

Runtime verification should cover coop, realism, and mutation4:

1. Change `si_spawn_max_specials` and confirm the maximum concurrent SI changes.
2. Change `si_spawn_respawn_interval` and observe subsequent slot cooldowns.
3. Check all six class limits and the Boomer/Spitter combined cap.
4. Toggle Relax and observe both normal pauses and continuous pressure.
5. Join and leave with automatic mode enabled and verify recalculation.
6. Exercise `si_spawn_fast_respawn_mode` values 0, 1, and 2.

## Design inputs

- Task intent: migrate only SI refresh ownership now and proceed incrementally.
- Baseline read set: `Si_SpawnSetting.sp`, `script_reloader.sp`, `coop.nut`,
  `community2.nut`, `better_mutations4.sp`, and the installed Left4DHooks API.
- Impact: SourceMod becomes authoritative for SI Director reads; mode scripts
  remain authoritative for all unrelated mode behavior.
