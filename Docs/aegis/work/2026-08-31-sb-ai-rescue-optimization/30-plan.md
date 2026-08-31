# Survivor Bot Rescue Performance Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove repeated per-usercmd Jockey/Smoker rescue discovery and expensive aim probing while preserving all configured rescue behavior.

**Architecture:** `state.inc` owns coordinator state and per-Bot cooldown. `rescue.inc` receives grab/release lifecycle events, builds nearest-Bot ranks once per event, exposes O(1) assignment checks, and supplies specialized Jockey/Smoker aim positions. `events.inc` translates game events; `bot_think.inc` keeps the existing action decisions behind an early gate and uses specialized aim only for Jockey/Smoker.

**Tech Stack:** SourcePawn 1.12, SourceMod SDKTools/SDKHooks, Left4DHooks, existing PowerShell static contracts.

**Baseline / Authority Refs:** `AGENTS.md`, `addons/sourcemod/scripting/l4d2_sb_ai_improver/README.md`, `Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/00-intent.md`, `10-baseline-readset.md`, and `20-spec.md`.

**Compatibility Boundary:** Preserve nearest-rank and tie-break behavior, cvar zero-disable semantics, reaction delay, shoot/shove range and weapon guards, visibility blindness rules, native rescue actions, generic targeting, and include order. Retire only the per-usercmd pinned-attacker discovery and generic Jockey/Smoker bone fallback.

**Verification:** Run the new rescue optimization contract RED before source edits; run it GREEN after each slice; compile `l4d2_sb_ai_improver.sp` with `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe`; run all `tests/*.tests.ps1`; run `git diff --check` with CRLF tolerance and inspect the tracked plugin binary change.

---

### Task 1: State contract and event-driven rescue coordinator

**Files:**

- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/rescue.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/events.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/lifecycle.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/entity_registry.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc`.
- Test: `tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.

**Why this task exists:** The current usercmd path rediscovers the pinned attacker and evaluates every Bot even though grab/release state changes only on events. The coordinator makes candidate assignment and invalidation explicit and bounded.

**Repair Track:** Move attacker/victim/class ownership to coordinator arrays, build nearest ranks at grab/rebuild events, and gate the existing branch with an O(1) assignment check. Keep the current rank helper name and its cvar semantics so existing contracts and behavior remain compatible.

**Retirement Track:** Retire `L4D_GetPinnedInfected(iPinnedFriend)` from the per-usercmd rescue branch and retire rank-cache rebuilding from `IsPinnedFriendReactionAllowed`. Keep the rank arrays and helper as the coordinator's compatibility-facing lookup owner; they are not deleted because existing callers/contracts depend on them.

**Verification:** The new contract must assert state arrays, grab/release hooks, coordinator calls, direct assignment checks, and absence of the old per-usercmd attacker lookup. Run the focused contract before source edits and record the expected missing-token failure.

- [ ] **Step 1: Add the failing coordinator contract.**

  Assert the exact state names `g_iPinnedRescueAttacker`, `g_iPinnedRescueClass`, `g_bPinnedRescueActive`, `g_iSurvivorBot_RescueVictim`, `g_iSurvivorBot_RescueAttacker`, and `g_fSurvivorBot_NextPinnedRescueThinkTime`; assert coordinator functions, grab/release hooks, and the bot-think coordinator gate. Assert the rescue section no longer contains `L4D_GetPinnedInfected(iPinnedFriend)`.

- [ ] **Step 2: Run the contract and confirm RED.**

  Run `& .\tests\l4d2_sb_ai_rescue_optimization.tests.ps1` from the worktree. It must fail because the new state/coordinator tokens do not yet exist; fix the test itself if it errors for a parsing reason.

- [ ] **Step 3: Add coordinator state and reset ownership.**

  Add the arrays to `state.inc`; extend `ResetPinnedReactionCaches` and `ResetClientPluginVariables`/map lifecycle calls so active rows, assignments, ranks, and cooldowns cannot survive a client or map boundary.

- [ ] **Step 4: Implement event-driven transitions.**

  Add `StartPinnedRescueCoordinator`, `InvalidatePinnedRescueCoordinator`, `InvalidatePinnedRescueClient`, and `RebuildPinnedRescueCoordinator` to `rescue.inc`. Keep nearest-distance insertion and client-index tie breaking in `BuildPinnedReactionRanks`; assign the closest eligible victim per Bot. Make `IsPinnedFriendReactionAllowed` only validate cvars, active state, rank, and assignment.

- [ ] **Step 5: Connect grab, release, death, and revive events.**

  Pass `userid` attacker plus `victim` to the start transition; hook `pounce_end`, `tongue_release`, `jockey_ride_end`, `charger_carry_end`, and `charger_pummel_end` to invalidation. Invalidate on player death and revive, and keep round/map/client resets.

- [ ] **Step 6: Run focused and existing rescue contracts.**

  Run `& .\tests\l4d2_sb_ai_rescue_optimization.tests.ps1`, `& .\tests\l4d2_sb_ai_pinned_reaction.tests.ps1`, and `& .\tests\l4d2_sb_ai_remaining_optimizations.tests.ps1`.

### Task 2: Low-cost Jockey/Smoker aim and per-Bot cooldown

**Files:**

- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/convars.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/events.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/rescue.inc`.
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc`.
- Modify: `cfg/cfgogl/versus_isfullshit/versus.cfg`.
- Test: `tests/l4d2_sb_ai_rescue_optimization.tests.ps1`.

**Why this task exists:** Generic rescue aim can perform one preferred bone query plus a fallback sweep and several traces per Bot. With ten Bots this multiplies the same work every command; a short per-Bot interval and one-position special aim bounds it.

**Repair Track:** Add `ib_help_pinned_reaction_interval` defaulting to `0.15` seconds, use the existing cached centroids for Jockeys, and use valid Smoker `m_tipPosition`/centroid data. Keep `HasVisualContactWithEntity` and generic `GetTargetAimPart` for other rescue classes.

**Retirement Track:** The generic bone fallback is retired only for Jockey/Smoker rescue. The general `GetTargetAimPart` implementation, bone guards, and other targeting call sites remain active and must retain their current contracts.

**Verification:** Focused contract asserts the cvar, cache field, early gate ordering tokens, specialized aim function, tip property, one direct visibility path, and no generic attacker aim call in the Jockey/Smoker branch. Compile and rerun rescue plus bone/module contracts.

- [ ] **Step 1: Extend the failing contract with cooldown and aim assertions.**

  Assert the cvar declaration/cache assignment, the per-Bot next-time array and reset, `GetPinnedRescueAimPosition`, `m_tipPosition`, `IsVisibleVector`, and the rescue branch's `g_fSurvivorBot_NextPinnedRescueThinkTime` guard.

- [ ] **Step 2: Run the focused contract and confirm the expected RED failure.**

  The test must fail on the first absent cooldown/aim token rather than a PowerShell error.

- [ ] **Step 3: Add and cache the interval cvar.**

  Register `ib_help_pinned_reaction_interval` with default `0.15`, minimum `0.05`, hook it through `OnConVarChanged`, cache its float value, and set the versus profile explicitly to `0.15`.

- [ ] **Step 4: Add the specialized aim helper.**

  Return `g_fClientCenteroid[iAttacker]` for Jockey; for Smoker read `m_tipPosition` only when the custom ability and send property exist, otherwise use the centroid. Return false for invalid positions.

- [ ] **Step 5: Add the early gate and cooldown.**

  Resolve the event-assigned rescue victim before the branch, check enabled bits, reaction delay, next evaluation time, and `IsPinnedFriendReactionAllowed`, then set the next evaluation time before expensive aim/visibility/action work. Read the event-assigned attacker/class instead of calling `L4D_GetPinnedInfected`.

- [ ] **Step 6: Route Jockey/Smoker through the helper.**

  Use one `IsVisibleVector` for specialized classes; keep the existing generic aim and visual contact for other classes. Preserve all existing action conditionals after aim selection.

- [ ] **Step 7: Run focused contracts and compile.**

  Run the focused rescue, pinned reaction, bone guard, module, and performance contracts, then compile with the exact project command and inspect compiler exit code/output.

### Task 3: Full regression and evidence

**Files:**

- Modify: `Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/40-atomic-tasks.md`.
- Modify: `Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/50-evidence.md`.
- Modify: `Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/60-checkpoint.md`.

**Why this task exists:** Cross-module SourcePawn changes need compiler evidence and all existing static contracts; runtime behavior remains an explicit manual verification item.

**Repair Track:** Verify state, event, runtime gate, and aim changes together through source contracts and compilation.

**Retirement Track:** Confirm the old per-usercmd attacker lookup and Jockey/Smoker generic rescue aim are absent while generic non-rescue aiming remains.

**Verification:** Run every `tests/*.tests.ps1` in sorted order, compile the plugin to the tracked SMX, run `git -c core.whitespace=cr-at-eol diff --check`, inspect `git status`/diff, and record residual live-server risks.

- [ ] **Step 1: Run all static tests.**

  From the worktree run `Get-ChildItem .\tests -Filter '*.tests.ps1' | Sort-Object Name | ForEach-Object { & $_.FullName }`; every script must exit zero.

- [ ] **Step 2: Compile the plugin.**

  Run `& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' 'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\sb-ai-rescue-optimization\addons\sourcemod\scripting\l4d2_sb_ai_improver.sp' '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\sb-ai-rescue-optimization\addons\sourcemod\plugins\l4d2_sb_ai_improver.smx' '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\sb-ai-rescue-optimization\addons\sourcemod\scripting\include' '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\sb-ai-rescue-optimization\addons\sourcemod\scripting' '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'`; record `Compilation successful.` and exit code `0`.

- [ ] **Step 3: Review side effects and evidence.**

  Run `git status --short`, `git diff --stat`, and `git -c core.whitespace=cr-at-eol diff --check`; ensure only intended source/config/test/docs/plugin files changed. Record that no live L4D2 server was available for ten-Bot frame timing.
