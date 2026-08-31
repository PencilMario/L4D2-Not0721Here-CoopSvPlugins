# Checkpoint: Pinned Rescue Maximum Distance

## TodoCheckpointDraft

- Completed: design, baseline read set, spec, implementation plan, and atomic task notes committed in `81db57ac`.
- Completed: isolated sparse worktree created at `.worktrees/sb-ai-rescue-distance`.
- Completed: baseline target contract passed.
- Completed: added the distance contract and committed it as `84762963`.
- Completed: target contract failed as expected on the missing max-distance CVar declaration.
- Completed: implemented the CVar, squared cache, cached-origin helper, rescue cheap gate, and profile override; committed as `4362394a`.
- Completed: target contract passed after implementation.
- Completed: restored the existing 35 KB `convars.inc` module contract by removing dead commented-out code; no runtime behavior changed.
- Completed: target and module contracts passed after the size fix.
- Completed: compiled the merged `main` result with SourcePawn 1.12; exit 0 with only the existing `CreateDialog` deprecation warning.
- Completed: ran all 28 PowerShell contracts from the complete worktree; 27 passed and the only failure is the pre-existing missing `install_release_updaters.sh` fixture.
- Completed: verified `runtime.inc` and `actions.inc` are unchanged relative to the rescue optimization baseline.
- Completed: fast-forward integrated `codex/sb-ai-rescue-distance` into `main` at `519c9b2f`.
- Pending: final diff review and worktree cleanup.

## EvidenceBundleDraft

- Baseline command: `pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.
- Baseline result: `l4d2_sb_ai rescue optimization contract passed`.
- RED command: `pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.
- RED result: failed with `the pinned rescue max-distance cvar must default to 5000 units`.
- GREEN command: `pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.
- GREEN result: `l4d2_sb_ai rescue optimization contract passed`.
- Size-fix command: `pwsh -NoProfile -File tests/l4d2_sb_ai_improver_modules.tests.ps1`.
- Size-fix result: `l4d2_sb_ai_improver module contract passed`; `convars.inc` is 34904 bytes.
- Final compile command: project SourcePawn 1.12 compiler with the AGENTS.md include paths; exit 0; code size 276924 bytes; existing `CreateDialog` deprecation warning only.
- Final full-suite command: each `tests/*.ps1` script under the complete `main` worktree; 28 total, 27 passed, 1 baseline failure (`check_release_updater_names.ps1`, missing `install_release_updaters.sh`).
- Final boundary check: `git diff --name-only c2f62aec HEAD` contains no `runtime.inc` or `actions.inc`; `git diff --check` passed.
- Authority: `AGENTS.md` and the preceding rescue optimization design/spec.

## DriftCheckDraft

- Scope: plugin forced rescue distance gate only.
- Compatibility: native `actions.inc` behavior and centralized `runtime.inc` snapshot owner remain unchanged.
- Retirement: no old owner or fallback is removed.
- Decision: verified evidence supports integration; one unrelated baseline test fixture remains unavailable.

## Next

If the missing baseline fixture is restored, rerun `tests/check_release_updater_names.ps1`; live L4D2 spatial-boundary and performance smoke testing remains the operational follow-up.
