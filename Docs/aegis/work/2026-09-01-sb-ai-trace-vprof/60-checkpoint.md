# Todo Checkpoint Draft

## Current state

- Current task: close the implementation with verified static/build evidence.
- Completed: VProf analysis and plan; Task 1 instrumentation; Task 2 64-slot/4-way entity LOS cache; Task 3 vector LOS cache; Task 4 entity classification/door-state cache; Task 5 command-local aim deduplication; focused contracts and prior SourcePawn 1.12 compiles.
- Active slice: none; the implementation is merged into `main`.
- Next: deploy to a fixed L4D2 test server for the planned 1000-frame VProf and behavior replay.
- Blockers: no local L4D2 server for runtime VProf or behavior sampling.

## Evidence

- Initial commits: `f4c0071f`, `4fc19841`; cache commits `60ce1eca`, `200a4aee`, `5eb024e1`.
- Full PowerShell contract suite: `SUMMARY total=34 passed=34 failed=0`.
- SourcePawn 1.12 compile: exit code 0; only the existing `CreateDialog` deprecation warning.
- Entity classification now uses classname fast paths, probes `m_eDoorState` once only for non-standard/unknown classes, and marks failed lookups as `TRACE_ENTITY_OTHER` to prevent repeated probing.
- On-map entity scanning pre-classifies trace entities; door `OnOpen`/`OnClose`/`OnFullyOpen`/`OnFullyClosed` outputs invalidate dynamic state.
- Ordinary query expiry remains `GetProcessCacheExpiry()` (`ib_process_time`); action traces remain command/frame scoped.

## Drift check draft

- Scope: Trace observability and cache reduction in `l4d2_sb_ai_improver`; no public ConVar/native/forward changes.
- Compatibility: preserve Bot decision order, three-point entity LOS fallback, door blocking semantics, and lifecycle invalidation API names.
- Retirement: detailed metrics remain diagnostic-only and gated by `ib_performance_logging`; the old 8-slot ring and per-callback `HasEntProp` path are retired, while the three-point LOS fallback remains for behavior compatibility.
- Decision: static/build verification is complete; real-server VProf, behavior replay, and quantitative acceptance thresholds remain `needs-verification` and are explicitly deferred to deployment.
