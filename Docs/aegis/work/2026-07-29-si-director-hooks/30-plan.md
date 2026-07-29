# SI Director Hooks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `Si_SpawnSetting.sp` directly override SI Director values without calling `sm_reloadscript`.

**Architecture:** Cache computed global and per-class SI limits in SourcePawn, return them from Left4DHooks Director-value forwards, and write Relax-related ordinary Director ConVars directly. Preserve the existing public configuration surface and fast-respawn timer.

**Tech Stack:** SourcePawn, SourceMod ConVars/events/timers, Left4DHooks.

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-07-29-si-director-hooks-design.md` and `addons/sourcemod/scripting/include/left4dhooks.inc`.

**Compatibility Boundary:** Do not edit or disable mode `.nut` files or `script_reloader.sp`; remove only this plugin's reload dependency and retain its commands, ConVar names, automatic scaling, and fast-respawn semantics.

**Verification:** Static contract checks, compilation with local `spcomp64`, `git diff --check`, and a documented runtime checklist for coop/realism/mutation4.

---

### Task 1: Establish migration contract checks

**Files:**
- Modify: `addons/sourcemod/scripting/Si_SpawnSetting.sp`

**Why this task exists:** Detect incomplete retirement of `sm_reloadscript` and ensure the required Left4DHooks forwards exist.

**Impact / Compatibility:** Static checks do not alter runtime behavior.

**Verification:** PowerShell assertions must first fail against the baseline and pass after Task 2.

- [ ] Run a baseline assertion that fails while `Si_SpawnSetting.sp` contains `sm_reloadscript`.
- [ ] Record required forward names: `L4D_OnGetScriptValueInt` and `L4D_OnGetScriptValueFloat`.

### Task 2: Move SI calculation and Director ownership into SourcePawn

**Files:**
- Modify: `addons/sourcemod/scripting/Si_SpawnSetting.sp`

**Why this task exists:** Eliminate reload coupling while retaining the approved spawn behavior.

**Impact / Compatibility:** The plugin becomes the authoritative final owner for SI Director reads. Existing mode scripts remain active for unrelated behavior.

**Repair Track:** The root cause is that configuration changes only reached the Director by reloading the active mode script. The canonical owner becomes `Si_SpawnSetting.sp`; the smallest change adds cached calculations, read forwards, and direct Relax ConVar application.

**Retirement Track:** Calls from this plugin to `sm_reloadscript` retire immediately. The command, loader plugin, and mode scripts remain active until later migrations remove their remaining responsibilities.

**Verification:** Compile and run static assertions.

- [ ] Add cached global and six-class limits plus cached Relax ConVar handles.
- [ ] Port class allocation, including zero DPS-limit behavior.
- [ ] Add integer and float Director-value forwards for prefixed and unprefixed keys.
- [ ] Apply ordinary Relax ConVars directly and return `Plugin_Continue` for Relax tempo keys when Relax is enabled.
- [ ] Replace all reload calls with one refresh function.
- [ ] Compile with `./spcomp64 Si_SpawnSetting.sp -i include -o compiled/Si_SpawnSetting.smx`.

### Task 3: Verify compatibility and record evidence

**Files:**
- Create: `Docs/aegis/work/2026-07-29-si-director-hooks/50-evidence.md`
- Modify: `Docs/aegis/work/2026-07-29-si-director-hooks/40-atomic-tasks.md`

**Why this task exists:** Separate locally proven behavior from server-only runtime validation.

**Impact / Compatibility:** No runtime code changes beyond fixes revealed by verification.

**Verification:** `spcomp64` exits 0, static assertions pass, and `git diff --check` reports no errors.

- [ ] Run compilation and capture warning/error totals.
- [ ] Assert no `sm_reloadscript` remains in the plugin and both forwards exist.
- [ ] Inspect the final diff for edits to mode scripts or the loader.
- [ ] Record the coop/realism/mutation4 runtime checklist as residual verification.
