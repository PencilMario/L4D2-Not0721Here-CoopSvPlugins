# Pinned Rescue Maximum Distance Implementation Plan

> For agentic workers: use the executing-plans or subagent-driven-development workflow and execute the tasks in order.

Goal: Add a cached maximum-distance gate that prevents this plugin from processing forced rescue actions for pinned survivors outside the configured range.

Architecture: Keep the CVar handle and squared threshold in state.inc and convars.inc. Add a rescue-local helper that compares the centralized g_fClientAbsOrigin snapshots, and call it from IsPinnedFriendReactionAllowed(). Do not touch actions.inc or add another snapshot clock.

Baseline and authority: AGENTS.md; Docs/aegis/work/2026-08-31-sb-ai-rescue-optimization/20-spec.md; Docs/aegis/work/2026-09-01-sb-ai-rescue-distance/20-spec.md; tests/l4d2_sb_ai_rescue_optimization.tests.ps1.

Compatibility boundary: Existing coordinator assignment, nearest-Bot limit, reaction interval, Jockey/Smoker aiming, and native LiberateBesiegedFriend movement remain unchanged. A value of 0 disables only this new distance limit.

Verification: target contract RED then GREEN, SourcePawn 1.12 compile, all PowerShell contracts, git diff --check, and an explicit check that runtime.inc and actions.inc are unchanged.

---

### Task 1: Add the failing distance contract

Files:
- Modify: tests/l4d2_sb_ai_rescue_optimization.tests.ps1

Why: Make the new CVar, cache, helper, rescue gate, and profile override observable before production code changes.

Steps:
- [ ] Require the state declarations, CreateConVar default 5000, change hook, and squared cache assignment.
- [ ] Require bool IsPinnedFriendWithinMaxDistance(int iClient, int iPinnedFriend), cached-origin references, and its call from IsPinnedFriendReactionAllowed().
- [ ] Require confogl_addcvar ib_help_pinned_max_distance 1500 in the versus profile.
- [ ] Run pwsh -NoProfile -File tests/l4d2_sb_ai_rescue_optimization.tests.ps1 and verify a non-zero missing-contract failure.
- [ ] Commit with test(sb-ai): define pinned rescue distance contract.

### Task 2: Implement the plugin-distance gate

Files:
- Modify: addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc
- Modify: addons/sourcemod/scripting/l4d2_sb_ai_improver/convars.inc
- Modify: addons/sourcemod/scripting/l4d2_sb_ai_improver/rescue.inc
- Modify: cfg/cfgogl/versus_isfullshit/versus.cfg

Repair Track: Make the existing rescue cheap gate the canonical owner of this distance policy. Use the existing CVar cache and process-window positions; do not add direct entity reads.

Retirement Track: Nothing is removed. Coordinator ranking and native movement remain active and outside this policy.

Steps:
- [ ] Add ConVar g_hCvar_HelpPinnedFriend_MaxDistance and float g_fCvar_HelpPinnedFriend_MaxDistance_Sqr next to the existing pinned-rescue state.
- [ ] Register ib_help_pinned_max_distance with default 5000, minimum 0, and description that 0 disables the limit; hook it with OnConVarChanged.
- [ ] Cache the squared FloatValue in UpdateConVarValues().
- [ ] Add IsPinnedFriendWithinMaxDistance(), returning true when the squared limit is zero and otherwise comparing cached origins with squared distance.
- [ ] Add the helper as a short-circuit rejection in IsPinnedFriendReactionAllowed(), before TryBeginPinnedRescueThink() and action work.
- [ ] Add confogl_addcvar ib_help_pinned_max_distance 1500 to the versus profile.
- [ ] Run the target contract and verify l4d2_sb_ai rescue optimization contract passed.
- [ ] Commit with perf(sb-ai): gate distant pinned rescue processing.

### Task 3: Compile and run regression verification

Files:
- Read/verify: addons/sourcemod/scripting/l4d2_sb_ai_improver/runtime.inc
- Read/verify: addons/sourcemod/scripting/l4d2_sb_ai_improver/actions.inc
- Test: tests/*.ps1

Repair Track: Confirm the new gate uses centralized ib_process_time snapshots.

Retirement Track: Confirm actions.inc is unchanged and no native movement behavior was retired.

Steps:
- [ ] Compile l4d2_sb_ai_improver.sp with E:/GithubKu/L4d2_0721sv_plugins/spcomp.exe and the include paths from AGENTS.md; expect exit 0 and Compilation successful.
- [ ] Run every tests/*.ps1 script and fail if any script exits non-zero.
- [ ] Run git diff --check and verify the changed-file list; runtime.inc and actions.inc must not appear.
