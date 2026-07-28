# Baseline Read Set

- `addons/sourcemod/scripting/l4d2_sb_ai_improver.sp`: canonical plugin implementation, 6,795 lines before this work.
- `addons/sourcemod/scripting/include/vscript.inc`: declares `fieldtype_t` only when `_l4dh_included` is absent.
- `addons/sourcemod/scripting/include/left4dhooks.inc`: declares the canonical L4D `fieldtype_t`.
- User-provided compiler command: SourcePawn 1.12.0.7221 with repository and Competitive-Rework include paths.

Compatibility boundary: retain one SMX, public callbacks, ConVars, function bodies, statement order, and runtime scheduling.
