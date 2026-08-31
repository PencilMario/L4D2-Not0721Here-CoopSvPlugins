# Versus Ability Stagger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the custom Tank and Smoker abilities non-staggering only in `versus_isfullshit` while preserving their other effects.

**Architecture:** Add default-on ConVars to the two plugin owners and gate only their custom `CTerrorPlayer::Fling`/`OnStaggered` SDK calls. Set those ConVars to `0` in the mode's `versus.cfg`, so other modes retain the current default behavior.

**Tech Stack:** SourcePawn 1.12, SourceMod SDKTools/SDKHooks, PowerShell contract tests, Confogl `.cfg` files.

**Baseline / Authority Refs:** `AGENTS.md`, `Docs/aegis/work/2026-08-31-versus-ability-stagger/00-intent.md`, `10-baseline-readset.md`, and the approved `20-spec.md`.

**Compatibility Boundary:** Do not change ordinary Tank attacks, unrelated stagger sources, non-stagger ability effects, or default behavior when either new ConVar is `1`.

**Verification:** Run `tests/versus_ability_stagger_contract.tests.ps1`; compile both modified SourcePawn files with `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe` and the repository include paths; inspect the final diff.

---

### Task 1: Add the failing stagger contract

**Files:**
- Create: `tests/versus_ability_stagger_contract.tests.ps1`

**Why this task exists:** The repository has no live game harness, so a source/config contract must catch a missing gate, an accidentally disabled default, or an unprotected custom stagger call before compilation.

**Impact / Compatibility:** The test reads only the two plugin sources and the selected mode config. It does not change runtime files.

**Verification:** Run `pwsh -NoProfile -File tests/versus_ability_stagger_contract.tests.ps1` from the repository root; before implementation it must fail because the new ConVars and guards are absent.

### Task 2: Implement mode-scoped gates

**Files:**
- Modify: `addons/sourcemod/scripting/L4D2 Hulking Tank.sp` at ConVar declarations/creation and the three Fling helper call sites.
- Modify: `addons/sourcemod/scripting/L4D2 Noxious Smoker.sp` at ConVar declarations/creation and all five custom stagger call sites.
- Modify: `cfg/cfgogl/versus_isfullshit/versus.cfg` near the existing custom Tank/Smoker ConVars.

**Why this task exists:** The custom plugins are the canonical owners of the unwanted hard-stagger calls. A local gate preserves damage and other ability effects without suppressing unrelated game behavior.

**Repair Track:** Add `l4d_htm_ability_stagger` and `l4d_nsm_ability_stagger`, both defaulting to `1`; wrap only the SDK calls that apply custom fling/stagger. Set both mode values to `0`.

**Retirement Track:** No fallback blocker is introduced. The old unconditional custom SDK calls remain available behind the default-on ConVars; no global hook or duplicate suppression path needs retirement.

**Implementation shape:**

```sourcepawn
// Tank plugin
ConVar cvarAbilityStagger;
// in OnPluginStart
cvarAbilityStagger = CreateConVar(
    "l4d_htm_ability_stagger", "1",
    "Enables hard-stagger effects from Hulking Tank abilities. (Def 1)",
    0, true, 0.0, true, 1.0
);
// in each Fling_* helper, immediately before SDKCall
if (GetConVarBool(cvarAbilityStagger))
{
    SDKCall(MySDKCall, victim, vector, 76, attacker, incaptime);
}
// keep the existing Damage_* call after the conditional
```

```sourcepawn
// Smoker plugin
new Handle:cvarAbilityStagger;
// in OnPluginStart
cvarAbilityStagger = CreateConVar(
    "l4d_nsm_ability_stagger", "1",
    "Enables hard-stagger effects from Noxious Smoker abilities. (Def 1)",
    FCVAR_NOTIFY, true, 0.0, true, 1.0
);
// immediately before each custom SDKCall(sdkCallFling, ...)
if (GetConVarBool(cvarAbilityStagger))
{
    SDKCall(sdkCallFling, target, resultingVec, 76, smoker, incaptime);
}
// immediately before SDKCall(sdkOnStaggered, ...)
if (GetConVarBool(cvarAbilityStagger))
{
    SDKCall(sdkOnStaggered, survivor, smoker, smokerPos);
}
```

```cfg
confogl_addcvar l4d_htm_ability_stagger 0
confogl_addcvar l4d_nsm_ability_stagger 0
```

### Task 3: Verify source, binaries, and compatibility

**Files:**
- Modify: `addons/sourcemod/plugins/optional/L4D2 Hulking Tank.smx`
- Modify: `addons/sourcemod/plugins/optional/L4D2 Noxious Smoker.smx`

**Why this task exists:** The deployed server loads compiled binaries, not `.sp` sources. Rebuilding both binaries is required for the config changes to reach the running server.

**Verification:**

```powershell
pwsh -NoProfile -File tests/versus_ability_stagger_contract.tests.ps1
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\scripting\L4D2 Hulking Tank.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\plugins\optional\L4D2 Hulking Tank.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\scripting\L4D2 Noxious Smoker.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\plugins\optional\L4D2 Noxious Smoker.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\.worktrees\ability-stagger-control\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

Expected compiler result: `Compilation successful.` for both files. Finish by checking `git diff --check` and `git diff --stat` in the isolated worktree, and report that live server verification is still required.
