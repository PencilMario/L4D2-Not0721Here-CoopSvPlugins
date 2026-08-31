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
- Active: compile the final branch and run the full repository regression suite from the complete main worktree.
- Pending: inspect final diff; integrate branch.

## EvidenceBundleDraft

- Baseline command: `pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.
- Baseline result: `l4d2_sb_ai rescue optimization contract passed`.
- RED command: `pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.
- RED result: failed with `the pinned rescue max-distance cvar must default to 5000 units`.
- GREEN command: `pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.
- GREEN result: `l4d2_sb_ai rescue optimization contract passed`.
- Size-fix command: `pwsh -NoProfile -File tests/l4d2_sb_ai_improver_modules.tests.ps1`.
- Size-fix result: `l4d2_sb_ai_improver module contract passed`; `convars.inc` is 34904 bytes.
- Authority: `AGENTS.md` and the preceding rescue optimization design/spec.

## DriftCheckDraft

- Scope: plugin forced rescue distance gate only.
- Compatibility: native `actions.inc` behavior and centralized `runtime.inc` snapshot owner remain unchanged.
- Retirement: no old owner or fallback is removed.
- Decision: continue with compile and regression verification.

## Next

Compile with the project compiler, run all PowerShell contracts, and verify no native action or snapshot owner changed.
