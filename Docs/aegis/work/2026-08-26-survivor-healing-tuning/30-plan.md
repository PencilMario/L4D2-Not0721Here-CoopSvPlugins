# Survivor Healing Tuning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tune the versus profile's automatic healing and make the configured level-start healing value above 100 also define survivor maximum health.

**Architecture:** Keep automatic healing's existing health-buffer implementation and change only its profile target and interval. Keep `level_start_heal` as the owner of start-of-round restoration; set `m_iMaxHealth` in its existing `heal_player` path immediately before restoration when the configured value is greater than 100.

**Tech Stack:** SourceMod SourcePawn 1.12, Confogl CFG, PowerShell contract checks, Git.

**Baseline / Authority Refs:** `AGENTS.md`, `README.md`, `Docs/aegis/README.md`, the approved design at `Docs/aegis/specs/2026-08-26-survivor-healing-tuning-design.md`, and the baseline files listed in `Docs/aegis/work/2026-08-26-survivor-healing-tuning/10-baseline-readset.md`.

**Compatibility Boundary:** Do not add or change `automatic_healing_health`; do not change kill-heal single-heal values or its existing `m_iMaxHealth + 100` cap formula, and preserve existing level-start black-and-white/reset behavior. The requested `m_iMaxHealth=500` therefore makes that existing combined cap 600. Only `level_start_heal_health > 100` may overwrite `m_iMaxHealth`.

**Verification:** Run the static contract test red before production edits and green after them; compile `level_start_heal.sp` to the tracked optional SMX with the known project compiler; verify the binary exists, inspect the relevant configuration/source contracts, and run `git -c core.whitespace=cr-at-eol diff --check`.

---

### Task 1: Establish the failing healing contract test

**Files:**
- Create: `Docs/aegis/work/2026-08-26-survivor-healing-tuning/verify.ps1`

**Why this task exists:** Make the requested values and source-level maximum-health contract executable before touching production files.

**Impact / Compatibility:** The script is task evidence only and is outside the deployed plugin/config scope.

**Verification:** Run the script against the baseline. It must fail because the profile still contains 60/0.15 and the source lacks the `m_iMaxHealth` assignment.

- [x] **Step 1: Write the failing test**

```powershell
param(
    [string]$RepoRoot = (Join-Path $PSScriptRoot '..\..\..\..')
)

$profile = Get-Content -Raw (Join-Path $RepoRoot 'cfg\cfgogl\versus_isfullshit\versus.cfg')
$source = Get-Content -Raw (Join-Path $RepoRoot 'addons\sourcemod\scripting\level_start_heal.sp')

if ($profile -notmatch '(?m)^confogl_addcvar automatic_healing_max 200\s*$') { throw 'automatic_healing_max is not 200' }
if ($profile -notmatch '(?m)^confogl_addcvar automatic_healing_repeat_interval 0\.3\s*$') { throw 'automatic_healing_repeat_interval is not 0.3' }
if ($profile -notmatch '(?m)^confogl_addcvar level_start_heal_health 500\s*$') { throw 'level_start_heal_health is not 500' }
if ($profile -match '(?m)^\s*confogl_addcvar automatic_healing_health\b') { throw 'automatic_healing_health must remain unconfigured' }
if ($source -notmatch 'O_health\s*>\s*100') { throw 'large level-start health guard is missing' }
if ($source -notmatch 'SetEntProp\(client,\s*Prop_Send,\s*"m_iMaxHealth",\s*O_health\)') { throw 'survivor max-health assignment is missing' }

Write-Output 'Healing contract passed.'
```

- [x] **Step 2: Run the test and verify the expected failure**

Run:

```powershell
& 'Docs\aegis\work\2026-08-26-survivor-healing-tuning\verify.ps1'
```

Expected: a terminating error reporting that `automatic_healing_max` is not 200. This is the intended RED result from the unchanged baseline.

### Task 2: Update the versus profile

**Files:**
- Modify: `cfg/cfgogl/versus_isfullshit/versus.cfg:14-18`

**Why this task exists:** Apply the approved automatic-healing target/interval and level-start value without changing the default single-heal amount.

**Impact / Compatibility:** Automatic healing continues to use the plugin's default `automatic_healing_health`; only its total target and interval change. Kill healing remains enabled with the same single-heal values and cap formula; its derived combined cap follows the requested maximum-health value.

**Verification:** The contract test must pass its profile assertions after the exact three value changes.

- [x] **Step 1: Change only the approved profile values**

The resulting block must be:

```cfg
// 回血
confogl_addcvar automatic_healing_enable 1
confogl_addcvar automatic_healing_wait_time 0.3
confogl_addcvar automatic_healing_repeat_interval 0.3
confogl_addcvar automatic_healing_max 200
confogl_addcvar sm_killheal_enable 1
confogl_addcvar level_start_heal_health 500
```

Do not add an `automatic_healing_health` line.

- [x] **Step 2: Run the contract test for the profile slice**

Run:

```powershell
& 'Docs\aegis\work\2026-08-26-survivor-healing-tuning\verify.ps1'
```

Expected: failure moves to the missing `m_iMaxHealth` guard/assignment, proving the profile assertions now pass and the test still exercises the source change.

### Task 3: Synchronize maximum health in the level-start plugin

**Files:**
- Modify: `addons/sourcemod/scripting/level_start_heal.sp:48-65`

**Why this task exists:** Make `level_start_heal_health=500` a real maximum-health value rather than only a one-time entity-health value.

**Impact / Compatibility:** Existing health-buffer preservation and black-and-white/revive-count reset remain intact. Values at or below 100 do not enter the new branch. The unchanged kill-heal plugin will consequently use its existing `m_iMaxHealth + 100` formula.

**Repair Track:** The current owner restores entity health but never updates `m_iMaxHealth`; add the smallest guarded assignment in the same owner function.

**Retirement Track:** No fallback owner is added. The old unconditional 100 default remains for compatibility, while the new guarded assignment becomes the sole path for configured values above 100.

**Verification:** The contract test must pass the source assertions; the plugin must compile with SourcePawn 1.12.

- [x] **Step 1: Add the guarded max-health assignment before existing restoration**

At the start of `heal_player`, after reading `health`, add:

```sourcepawn
    if(O_health > 100)
    {
        SetEntProp(client, Prop_Send, "m_iMaxHealth", O_health);
    }
```

Leave the following existing health-buffer and state-reset statements unchanged.

- [x] **Step 2: Run the contract test and verify GREEN**

Run:

```powershell
& 'Docs\aegis\work\2026-08-26-survivor-healing-tuning\verify.ps1'
```

Expected: `Healing contract passed.` and exit code 0.

### Task 4: Compile and perform regression checks

**Files:**
- Generate: `addons/sourcemod/plugins/optional/level_start_heal.smx`
- Create: `Docs/aegis/work/2026-08-26-survivor-healing-tuning/50-evidence.md`

**Why this task exists:** Verify the deployed artifact matches the changed SourcePawn and record bounded evidence.

**Impact / Compatibility:** Only the tracked optional binary corresponding to `level_start_heal.sp` is regenerated; no other plugin is compiled or changed.

**Verification:**

- [x] **Step 1: Compile the plugin**

```powershell
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\level_start_heal.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\optional\level_start_heal.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

Expected: compiler exit code 0 and `Compilation successful.`.

- [x] **Step 2: Run the complete local verification bundle**

```powershell
& 'Docs\aegis\work\2026-08-26-survivor-healing-tuning\verify.ps1'
if (-not (Test-Path -LiteralPath 'addons\sourcemod\plugins\optional\level_start_heal.smx')) { throw 'compiled level_start_heal.smx is missing' }
git -c core.whitespace=cr-at-eol diff --check
git status --short
```

Expected: the contract prints `Healing contract passed.`, the binary check succeeds, diff-check has no output, and only the approved files are changed.

- [x] **Step 3: Record evidence and residual risk**

Record the exact compiler command/result, contract-test result, diff-check result, and the fact that live server HUD/respawn behavior remains unverified until deployment.
