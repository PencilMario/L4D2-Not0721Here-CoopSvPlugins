# Baseline Read Set

- `AGENTS.md`: SourcePawn compiler and include-path authority.
- `addons/sourcemod/scripting/l4d2_zcs_redux.sp`: current class constants, ConVars, ghost entry, selection, counting, limits, cooldown-state, and HUD paths.
- `cfg/cfgogl/versus_isfullshit/versus.cfg`: existing six-class `zcs_*_limit` settings and the retained survivor-AI settings in the main worktree.
- `tests/*.tests.ps1`: repository static contract-test pattern.
- Existing `addons/sourcemod/plugins/optional/l4d2_zcs_redux.smx`: old binary is not an implementation authority and will not be edited in this source change.

**Known facts:** Tank already has class ID `8` and a display name, but the source rejects IDs above Charger, excludes Tank from ghost-entry handling, iterates only classes `1..6`, and has no Tank limit ConVar. The current total-limit slot remains separate from the Tank per-class slot.

**Runtime unknown:** A live L4D2 server is not available for interactive ghost-to-Tank verification; the static contract and compiler checks will cover source integration, with live switching remaining a manual follow-up.


