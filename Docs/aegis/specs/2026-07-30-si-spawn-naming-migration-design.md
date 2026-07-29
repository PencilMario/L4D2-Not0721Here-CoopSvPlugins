# SI spawn naming migration design

## Intent

Replace the inconsistent SI spawn plugin identifiers, public ConVar names, and
console commands with one readable `si_spawn` namespace. This is a hard cutover:
all repository-owned consumers migrate atomically and no legacy aliases remain.

The migration changes names only. Defaults, command arguments, Director keys,
class allocation, automatic scaling, Relax behavior, and fast-respawn behavior
must remain unchanged.

## Public ConVar mapping

| Old name | New name |
| --- | --- |
| `sss_1P` | `si_spawn_max_specials` |
| `SS_Time` | `si_spawn_respawn_interval` |
| `SS_Relax` | `si_spawn_relax_enabled` |
| `SS_FastRespawn` | `si_spawn_fast_respawn_mode` |
| `SS_DPSSiLimit` | `si_spawn_dps_special_limit` |
| `sm_ss_automode` | `si_spawn_auto_scale_enabled` |
| `sm_ss_autoperdetime` | `si_spawn_auto_interval_reduction` |
| `sm_ss_autotime` | `si_spawn_auto_base_interval` |
| `sm_ss_autosilim` | `si_spawn_auto_base_specials` |
| `sm_ss_autoperinsi` | `si_spawn_auto_specials_per_player` |
| `sm_ss_fixm4spawn` | `si_spawn_mutation4_fix_enabled` |

## Public command mapping

| Old command | New command |
| --- | --- |
| `sm_SetAiSpawns` | `sm_si_spawn_set_limit` |
| `sm_SetAiTime` | `sm_si_spawn_set_interval` |
| `sm_SetDpsLim` | `sm_si_spawn_set_dps_limit` |

Command arguments and effects remain identical. Usage text migrates with the
registered command names.

## SourcePawn naming

ConVar handles use the `g_cv` prefix and descriptive names, including
`g_cvMaxSpecials`, `g_cvRespawnInterval`, `g_cvRelaxEnabled`,
`g_cvFastRespawnMode`, `g_cvDpsSpecialLimit`, and equivalent names for automatic
scaling and Mutation 4 repair settings.

The fast-respawn timer becomes `g_hFastRespawnTimer`; cached class limits become
`g_iSpecialClassLimits`. Functions use action-oriented names such as
`ApplyAutomaticSpawnSettings`, `ValidateSpawnSettings`,
`GetMinimumClassLimit`, `GetHumanPlayerCount`, and descriptive command callback
names.

## Repository consumers

Every exact legacy reference must migrate in the same change:

- `Si_SpawnSetting.sp` and SourcePawn consumers such as the server settings
  menu, test menu, and team panel.
- `coop`, `realism`, `mutation4`, `versus`, `community2`, and `community5`
  VScript consumers retained for non-SI responsibilities.
- Confogl configuration files under `cfg/cfgogl`.
- Custom vote commands and advertisements.
- Active Aegis specifications and verification instructions that name the
  public interface.

Obsolete `sm_reloadscript` suffixes attached to migrated SI settings in custom
votes and the test menu are removed. The global script reloader and unrelated
uses remain outside this migration.

## Compatibility boundary

No legacy ConVars or commands are registered as aliases. Repository-external
startup arguments, private configurations, admin panels, or scripts must be
updated by their owners. This deliberate hard cutover avoids two writable names
for the same setting and keeps one canonical configuration surface.

No mode script is deleted. Only its ConVar lookup strings change. No Director
key, mode behavior, or command value is changed.

## Verification

1. Search the full repository, excluding Git metadata and compiled binaries,
   and require all 11 old ConVar names plus all 3 old commands to have zero
   matches outside the historical mapping in this design record.
2. Confirm all 14 new public names have their expected declaration and consumer
   matches.
3. Compile `Si_SpawnSetting.sp`, `server_setting.sp`, `extra_menu_test.sp`, and
   `l4d_teamspanel.sp` with the server compiler and established include order.
4. Run `git diff --check` and inspect the changed-file list for unrelated edits.
5. Runtime-check the settings menu, votes, advertisements, Confogl presets, and
   direct console commands on a server.

## Design inputs

- Task intent: improve readability of early plugin names and migrate all
  repository dependencies, including public commands.
- Baseline read set: the full repository match set for the 11 legacy ConVars
  and 3 legacy commands, plus the existing Director-hook migration design.
- Impact: configuration interface, menus, votes, VScript reads, and Confogl
  presets change together; runtime spawn behavior is invariant.
