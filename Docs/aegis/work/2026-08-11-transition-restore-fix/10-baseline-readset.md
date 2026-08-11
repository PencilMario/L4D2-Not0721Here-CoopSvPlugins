# Baseline Read Set

- `AGENTS.md`: project SourcePawn compilation command.
- `addons/sourcemod/scripting/transition_restore_fix.sp`: current 1.2.0 source and restore flow.
- `addons/sourcemod/gamedata/transition_restore_fix.txt`: address, signature, and patch names.
- Git commit `27d73a6b`: reverted 1.2.5 implementation containing `PlayerSaveData::Restore` selection.
- Git commit `d1a081f9`: current revert that removed that selection path.
- `addons/sourcemod/scripting/include/left4dhooks.inc`: available transition forwards and their parameter/timing contract.
- `tests/*.tests.ps1`: repository static contract-test pattern.

**Known facts:** Current source requests singular saved-count keys while gamedata defines plural keys. Current source does not detour `PlayerSaveData::Restore`; the reverted 1.2.5 source did.

**Runtime unknown:** A live server reproduction is not available in this workspace, so final inventory preservation remains a manual server verification item.
