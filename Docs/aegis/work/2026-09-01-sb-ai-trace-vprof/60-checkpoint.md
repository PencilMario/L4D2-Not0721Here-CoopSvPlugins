# Todo Checkpoint Draft

## Current state

- Current task: close the implementation with verified static/build evidence.
- Completed: VProf analysis and plan; Task 1 instrumentation; Task 2 64-slot/4-way entity LOS cache; Task 3 vector LOS cache; Task 4 entity classification/door-state cache; Task 5 command-local aim deduplication; heavy-load degradation levels; focused contracts and SourcePawn 1.12 compile.
- Active slice: none; the implementation is committed and pushed to `main` at `a6f5463c`.
- Next: deploy to a fixed L4D2 test server for the planned 1000-frame VProf and behavior replay.
- Blockers: no local L4D2 server for runtime VProf or behavior sampling.

## Evidence

- Initial commits: `f4c0071f`, `4fc19841`; cache commits `60ce1eca`, `200a4aee`, `5eb024e1`.
- Full PowerShell contract suite: `SUMMARY passed=35 failed=0`.
- SourcePawn 1.12 compile: exit code 0; code size 305680 bytes; no errors or warnings reported.
- Heavy-load controls: `ib_ai_degraded_force` (`0=auto`, `1-3=force`) and `ib_ai_degraded_frame_step_ms` (EMA frame-ms step).
- Entity classification now uses classname fast paths, probes `m_eDoorState` once only for non-standard/unknown classes, and marks failed lookups as `TRACE_ENTITY_OTHER` to prevent repeated probing.
- On-map entity scanning pre-classifies trace entities; door `OnOpen`/`OnClose`/`OnFullyOpen`/`OnFullyClosed` outputs invalidate dynamic state.
- Ordinary query expiry remains `GetProcessCacheExpiry()` (`ib_process_time`); action traces remain command/frame scoped.

## Drift check draft

- Scope: Trace observability, cache reduction, and opt-in/automatic heavy-load degradation in `l4d2_sb_ai_improver`.
- Compatibility: level 0 preserves existing behavior; ordinary cache expiry remains `ib_process_time`; door blocking semantics and lifecycle invalidation API names remain intact. Levels 1-3 intentionally trade LOS/bone/nav precision for load headroom.
- Retirement: detailed metrics remain diagnostic-only and gated by `ib_performance_logging`; the old 8-slot ring and per-callback `HasEntProp` path are retired, while compatibility fallbacks remain available at level 0/1.
- Decision: static/build verification is complete; real-server VProf, behavior replay, and quantitative acceptance thresholds remain `needs-verification` and are explicitly deferred to deployment.
