# Remove Consistent Escape Route Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the versus-only escape-route plugin, add the missing SourceKeyValues provider for the existing campaign VScript purifier, and commit the package cleanup.

**Architecture:** Retire the versus-only plugin at the package boundary by deleting its load directive and private SMX/gamedata pair. Add the upstream SourcePawn provider and compiled SMX to the common plugin load sequence, reusing the repository's existing matching include and gamedata.

**Tech Stack:** SourceMod plugin package, SourceMod CFG, Git, PowerShell.

**Baseline / Authority Refs:** `AGENTS.md`, `README.md`, `cfg/generalfixes.cfg`, and the approved design in `Docs/aegis/specs/2026-08-06-remove-consistent-escaperoute-design.md`.

**Compatibility Boundary:** All other `generalfixes.cfg` load entries remain unchanged. The new provider uses SourceMod 1.12 and the existing `l4d2_source_keyvalues.inc`/gamedata contracts; it loads before `fix/l4d2_vscript_purifier.smx`.

**Verification:** Search outside `Docs/aegis` for zero remaining retired-plugin references, compile the new provider with the project compiler, run `git -c core.whitespace=cr-at-eol diff --check`, review the staged diff, and inspect the resulting commit.

---

### Task 1: Retire the campaign-inapplicable plugin

**Files:**
- Modify: `cfg/generalfixes.cfg:56`
- Delete: `addons/sourcemod/plugins/fix/l4d_consistent_escaperoute.smx`
- Delete: `addons/sourcemod/gamedata/l4d_consistent_escaperoute.txt`

**Why this task exists:** The package targets campaign servers, while this plugin preserves versus-half escape routes and currently fails at startup because its `TheEscapeRoute` gamedata address is unavailable.

**Impact / Compatibility:** Campaign behavior loses no required feature. Other fix plugins and the shared `left4dhooks` dependency remain in place.

**Repair Track:** Remove the package load reference so SourceMod no longer attempts to initialize the incompatible plugin.

**Retirement Track:** Retire the plugin binary and its private gamedata because no remaining repository reference depends on them.

**Verification:**

- [ ] **Step 1: Confirm the scoped references and files**

```powershell
rg -n -i --glob '!Docs/aegis/**' "l4d_consistent_escaperoute|TheEscapeRoute" .
Test-Path -LiteralPath 'addons/sourcemod/plugins/fix/l4d_consistent_escaperoute.smx'
Test-Path -LiteralPath 'addons/sourcemod/gamedata/l4d_consistent_escaperoute.txt'
```

Expected: the load directive is the only package reference to remove, and both scoped files exist before the change.

- [ ] **Step 2: Remove the load directive and private artifacts**

Delete the exact load line from `cfg/generalfixes.cfg`, then delete the two exact scoped files listed above.

- [ ] **Step 3: Verify the retirement**

```powershell
rg -n -i --glob '!Docs/aegis/**' "l4d_consistent_escaperoute" .
Test-Path -LiteralPath 'addons/sourcemod/plugins/fix/l4d_consistent_escaperoute.smx'
Test-Path -LiteralPath 'addons/sourcemod/gamedata/l4d_consistent_escaperoute.txt'
git -c core.whitespace=cr-at-eol diff --check
git status --short
```

Expected: the search produces no output, both `Test-Path` commands return `False`, `git -c core.whitespace=cr-at-eol diff --check` produces no output, and status contains only the approved documentation plus the config, provider, license, and two retirement paths.

### Task 2: Add the SourceKeyValues provider

**Files:**
- Create: `addons/sourcemod/scripting/l4d2_source_keyvalues.sp`
- Create: `addons/sourcemod/plugins/l4d2_source_keyvalues.smx`
- Create: `LICENSES/l4d2_source_keyvalues-GPL-3.0.txt`
- Modify: `cfg/generalfixes.cfg:4`
- Reuse: `addons/sourcemod/scripting/include/l4d2_source_keyvalues.inc`
- Reuse: `addons/sourcemod/gamedata/l4d2_source_keyvalues.txt`

**Why this task exists:** `fix/l4d2_vscript_purifier.smx` declares `l4d2_source_keyvalues` as a required plugin, but this package currently contains only its include and gamedata.

**Impact / Compatibility:** The provider registers the SourceKeyValues natives used by the purifier. It must be loaded before the purifier entry near the end of `generalfixes.cfg`; no purifier source or gamedata changes are needed.

**Verification:**

- [ ] **Step 1: Add the upstream source**

Copy `l4d2_source_keyvalues.sp` and the upstream GPL-3.0 license from `fdxx/l4d2_source_keyvalues` commit `c07cb559a62c14fa61c17f1244f185e2078f4330` into the exact source and license paths above. Keep the existing project include and gamedata unchanged after comparing them with upstream.

- [ ] **Step 2: Add the provider to the load order**

Insert this line immediately after `sm plugins load vscript.smx` in `cfg/generalfixes.cfg`:

```cfg
sm plugins load l4d2_source_keyvalues.smx
```

- [ ] **Step 3: Compile the provider**

```powershell
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\l4d2_source_keyvalues.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\l4d2_source_keyvalues.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

Expected: compiler exit code 0 with no warnings, and the output SMX exists.

- [ ] **Step 4: Verify dependency ordering and source contracts**

```powershell
$cfg = Get-Content -LiteralPath 'cfg/generalfixes.cfg' -Raw
if ($cfg.IndexOf('sm plugins load l4d2_source_keyvalues.smx') -gt $cfg.IndexOf('sm plugins load fix/l4d2_vscript_purifier.smx')) { throw 'SourceKeyValues loads after its consumer' }
if (-not (Select-String -LiteralPath 'addons/sourcemod/scripting/l4d2_source_keyvalues.sp' -Pattern 'RegPluginLibrary\("l4d2_source_keyvalues"\)' -Quiet)) { throw 'SourceKeyValues library registration is missing' }
git -c core.whitespace=cr-at-eol diff --check
```

Expected: the ordering and source contract checks pass with no diff-check output.

- [ ] **Step 4: Commit the cleanup**

```powershell
git add Docs/aegis/specs/2026-08-06-remove-consistent-escaperoute-design.md Docs/aegis/plans/2026-08-06-remove-consistent-escaperoute.md LICENSES/l4d2_source_keyvalues-GPL-3.0.txt cfg/generalfixes.cfg addons/sourcemod/plugins/fix/l4d_consistent_escaperoute.smx addons/sourcemod/gamedata/l4d_consistent_escaperoute.txt addons/sourcemod/scripting/l4d2_source_keyvalues.sp addons/sourcemod/plugins/l4d2_source_keyvalues.smx
git commit -m "chore: 清理战役服插件依赖"
```
