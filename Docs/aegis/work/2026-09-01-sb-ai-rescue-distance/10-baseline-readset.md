# Baseline Read Set: Pinned Rescue Maximum Distance

## Authority and constraints

- `AGENTS.md`: use the project SourcePawn 1.12 compiler command and include paths; existing legacy warnings are accepted when compilation succeeds.
- `Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/20-spec.md`: rescue coordinator owns forced pinned rescue; shared client snapshots have one `ib_process_time`-based refresh owner.
- `Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/50-evidence.md`: the preceding rescue optimization is compiled and statically verified.

## Source owners

- `addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc`: CVar handles and cached values.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/convars.inc`: CVar registration, hooks, and cache synchronization.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/rescue.inc`: pinned rescue cheap gate and cached-position distance check.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/runtime.inc`: sole owner of global client snapshot refresh; unchanged by this task.
- `cfg/cfgogl/versus_isfullshit/versus.cfg`: profile-specific CVar override.
- `tests/l4d2_sb_ai_rescue_optimization.tests.ps1`: static rescue contract regression test.

## Baseline evidence

Command:

```powershell
& pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1
```

Result: `l4d2_sb_ai rescue optimization contract passed`.

Current implementation has no `ib_help_pinned_max_distance` declaration or distance gate. The rescue branch uses `IsPinnedFriendReactionAllowed()` before expensive aim/visibility/action work and reads `g_fClientAbsOrigin` snapshots maintained by `runtime.inc`.
