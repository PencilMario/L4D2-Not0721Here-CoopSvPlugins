# Verification evidence

## Contract

- Baseline search, excluding compiled binaries and the approved historical
  mapping table, found 233 lines containing legacy public names.
- Final word-bounded search finds zero legacy ConVar or command names outside
  `2026-07-30-si-spawn-naming-migration-design.md`.
- All 11 new ConVars have exact `CreateConVar` declarations in
  `Si_SpawnSetting.sp`.
- All 3 new commands have exact `RegConsoleCmd` declarations.
- All 14 new public names have repository consumers.
- The approved old internal identifiers have zero matches in the canonical
  plugin.

## Compilation

Compiler: `E:/GithubKu/L4d2_0721sv_plugins/spcomp.exe`, SourcePawn
`1.12.0.7221`, with the Competitive-Rework include directory first.

- `Si_SpawnSetting.sp`: exit 0; one existing `halflife.inc` deprecation warning.
- `server_setting.sp`: exit 0; existing deprecation and unused-index warnings.
- `l4d_teamspanel.sp`: exit 0; one existing deprecation warning.
- `extra_menu_test.sp`: exit 1 with 26 errors at unchanged lines 108-144 because
  `extra_menu.inc` requires arguments 9 and 10 while the historical test calls
  omit them. Compiling the unmodified main-worktree version with the same
  compiler reproduces the identical 26 errors. The migrated lines begin at 155,
  so this is a bounded pre-existing test-plugin build defect.

## Diff and ownership

- `git -c core.whitespace=cr-at-eol diff --check`: exit 0.
- Runtime changes are exact-name substitutions across the canonical plugin,
  SourcePawn consumers, six retained mode VScripts, Confogl presets, custom
  votes, and advertisements.
- Obsolete `sm_reloadscript` suffixes were removed only from SI-setting actions
  in `customvotes.cfg` and `extra_menu_test.sp`.
- No legacy alias or second configuration owner was added.

## Runtime verification still required

1. Load the rebuilt production plugins and confirm all 11 new ConVars exist.
2. Exercise all 3 new console commands.
3. Open the server settings menu and verify edits reach the new ConVars.
4. Run custom votes and Confogl presets that configure SI spawning.
5. Confirm advertisements resolve the renamed placeholders.
6. Verify retained mode scripts read the new names during mode initialization.

Repository-external configurations must be migrated separately by their owners.
