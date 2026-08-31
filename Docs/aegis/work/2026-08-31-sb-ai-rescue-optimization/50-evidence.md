# Verification Evidence

This record tracks the fresh checks for the implementation slices and the remaining live-server boundary.

## Known baseline

- Worktree: `.worktrees/sb-ai-rescue-optimization`.
- Base commit: `6b912dd2`.
- The rescue optimization contract was observed RED before the initial implementation; after the lifecycle additions, the same contract was also observed RED on the missing `player_spawn` hook before those production edits.

## Fresh checks

- Focused contracts: rescue optimization, pinned reaction, remaining optimizations, bone guard, module composition, and performance logging — `FOCUSED_SUMMARY passed=6 failed=0`.
- Complete static suite: all repository PowerShell contracts — `TEST_SUMMARY passed=25 failed=0`.
- SourcePawn compiler: `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe` against `l4d2_sb_ai_improver.sp` — exit code `0`; compiler emitted code/data/stack size output.
- The tracked `addons/sourcemod/plugins/l4d2_sb_ai_improver.smx` was regenerated from the current source.
- `git -c core.whitespace=cr-at-eol diff --check` — no whitespace errors.
- Final advisory review found no Critical/Important issues. Two Minor issues were repaired: stale assignments are cleared before deferred recovery, and death invalidation no longer scans candidate ranks for the killer slot.
- After those repairs, the focused contracts again reported `FOCUSED_SUMMARY passed=6 failed=0`; the complete suite reported `TEST_SUMMARY passed=25 failed=0`; the fresh compile reported `COMPILE_EXIT=0`.

## Residual risk

- A live Left 4 Dead 2 server with the installed extensions and gamedata is required to measure ten-Bot frame time and verify all event-field/release timings.
- Static contracts cannot prove the exact Charger carry-to-pummel event order or survivor replacement behavior while a pin is active; the added recovery path reconciles native state after the next ready snapshot window.
- No live L4D2 server was available, so ten-Bot frame-time reduction, event-field timing, and installed-extension compatibility remain manual verification items.
