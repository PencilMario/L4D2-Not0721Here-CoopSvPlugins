# Baseline Read Set Hint

## Authority and project boundary

- `AGENTS.md`: SourcePawn 1.12 compiler and include paths.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/README.md`: composition-root include order and `state.inc` shared-state ownership.
- `Docs/aegis/INDEX.md`: existing Aegis task-record location and naming.

## Runtime baseline

- `addons/sourcemod/scripting/l4d2_sb_ai_improver/runtime.inc`: every survivor Bot usercmd enters `SurvivorBotThink`; current rescue branch is in the per-usercmd path.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc`: current pinned-friend branch performs `L4D_GetPinnedInfected`, `GetTargetAimPart`, visibility checks, and shooting/shoving decisions.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/rescue.inc`: current nearest-Bot rank cache, rescue eligibility, and look helpers.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/events.inc`: current grab event only schedules reaction time; round/client reset paths are present.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/lifecycle.inc`: current event registration and plugin lifecycle.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc`: current pinned reaction arrays, cache expiry helper, and shared state owner.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/aiming.inc`: generic bone-based `GetTargetAimPart` and existing bone guards.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc`: trace and visibility-memory implementations.

## Existing tests and constraints

- `tests/l4d2_sb_ai_pinned_reaction.tests.ps1`: nearest reaction count, zero-disable, and mode configuration contract.
- `tests/l4d2_sb_ai_remaining_optimizations.tests.ps1`: pinned rank-cache token contract.
- `tests/l4d2_sb_ai_bone_guard.tests.ps1`: exactly one guarded bone SDKCall owner and origin fallback.
- `tests/l4d2_sb_ai_improver_modules.tests.ps1`: module composition and include-order contract.
- Project files are LF; changed source must retain that line-ending convention.
