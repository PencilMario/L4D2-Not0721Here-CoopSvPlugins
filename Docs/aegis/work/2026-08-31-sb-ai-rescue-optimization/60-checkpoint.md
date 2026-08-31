# Todo Checkpoint Draft

## Current state

- Current todo: hand off the integrated and verified `main` worktree.
- Completed: baseline readback, approved design record, coordinator implementation, per-Bot interval, Jockey/Smoker aim path, centralized `ib_process_time` snapshots, lifecycle invalidation/recovery, review repairs, focused contracts, complete static suite, SourcePawn compilation, local commit, and fast-forward integration.
- Active slice: final handoff.
- Blocked on: no static or build blocker; no local live L4D2 server is available for runtime timing and event-order smoke tests.
- Next step: run the documented in-game smoke test when a server with the required extensions and gamedata is available.

## Drift check draft

- Scope: still limited to the three approved rescue performance stages.
- Compatibility: existing cvars, rank behavior, visibility rules, generic non-Jockey/Smoker aim, and `ib_process_time` as the sole global snapshot refresh clock remain protected; lifecycle events only invalidate and queue recovery.
- Retirement: per-usercmd pinned-attacker discovery and Jockey/Smoker generic rescue aim are explicit retirement targets; generic aiming remains for other targets.
- Decision: hand off verified evidence; runtime performance and exact event timing remain explicitly unverified.
