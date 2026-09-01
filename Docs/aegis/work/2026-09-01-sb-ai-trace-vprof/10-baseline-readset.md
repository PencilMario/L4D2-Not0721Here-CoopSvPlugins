# Baseline Read Set

- `AGENTS.md`: SourcePawn 1.12 compiler and include paths.
- `docs/aegis/work/2026-09-01-sb-ai-trace-vprof/30-analysis-and-plan.md` (controller workspace): VProf evidence and six-task implementation plan.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc`: entity/vector LOS and `Base_TraceFilter` owners.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc`: nav visibility Trace owner.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc`: grenade ground/ceiling Trace owners.
- `addons/sourcemod/scripting/l4d2_sb_ai_improver/runtime.inc`, `debug.inc`, `state.inc`: command boundary and performance logging state.
- Baseline: 30 existing PowerShell tests pass on the clean worktree.
