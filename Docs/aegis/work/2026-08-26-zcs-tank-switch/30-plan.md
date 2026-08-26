# Zombie Character Select Tank Switch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Tank selectable through the existing Zombie Character Select flow while keeping Tank disabled by default.

**Architecture:** Reuse the existing per-class limit and class-cycle machinery. Add one Tank-specific limit slot and ConVar; include class ID `8` in selection/count/HUD loops, while retaining the existing ordinary-SI total at `ZC_TOTAL` and retaining Tank's exclusion from that total. Remove only the Tank guards that made Tank selection impossible.

**Tech Stack:** SourcePawn 1.12, SourceMod, Left 4 DHooks, PowerShell static contract tests.

**Baseline / Authority Refs:** `AGENTS.md`, `addons/sourcemod/scripting/l4d2_zcs_redux.sp`, `cfg/cfgogl/versus_isfullshit/versus.cfg`, and repository `tests/*.tests.ps1` patterns.

**Compatibility Boundary:** Existing six-class ConVars, limits, cooldowns, class order, and ordinary-SI total remain unchanged. Tank is not included in the ordinary total and has no cooldown ConVar. `zcs_tank_limit` defaults to `0`; with the normal `zcs_respect_limits 1`, Tank remains unavailable until explicitly raised.

**Verification:** Run the Tank contract test RED before implementation, run it GREEN after implementation, compile with the known SourcePawn compiler, run relevant repository PowerShell tests, inspect the isolated diff, and use a CRLF-aware whitespace check.

---

### Task 1: Prove the Tank contract fails

**Files:**
- Create: `tests/l4d2_zcs_tank_switch.tests.ps1`

**Repair Track:** The test will assert the missing Tank ConVar, Tank-inclusive class loops, Tank ghost-entry path, and Tank per-class limit slot.

**Retirement Track:** No runtime path is retired by the test; it prevents the old Charger-only boundary from returning.

- [x] Assert `zcs_tank_limit` defaults to `0` with a `0..10` range.
- [x] Assert Tank is accepted by the selection guard, class-name selection, ghost-entry path, cycle/limit/HUD loops, and per-class limit loading.
- [x] Run the test and record the expected failure against the baseline source.

### Task 2: Implement Tank selection and limit handling

**Files:**
- Modify: `addons/sourcemod/scripting/l4d2_zcs_redux.sp`

**Repair Track:** Add the Tank ConVar/handle/cache, extend the limit array and reload path, include Tank in all class-cycle/count/limit/HUD loops, and allow a Tank ghost to enter the existing class-selection routine.

**Retirement Track:** The old Tank early-return and Charger-only selection boundary retire. The ordinary-SI total and all six existing per-class paths remain active.

- [x] Add `g_hTankLimit`, `g_iTankLimit`, `zcs_tank_limit 0`, its change hook, and its reload assignment.
- [x] Extend `g_iZVLimits` capacity and load `g_iZVLimits[ZC_TANK]` without adding Tank to `g_iZVLimits[ZC_TOTAL]`.
- [x] Extend `sm_buy`, ghost-entry, selection, last-class, cooldown-state, and HUD boundaries to `ZC_TANK` where class selection is intended.
- [x] Keep Tank outside the ordinary total and do not add Tank cooldown settings.

### Task 3: Verify source and binary

**Files:**
- Create: `Docs/aegis/work/2026-08-26-zcs-tank-switch/50-evidence.md`

- [x] Run the targeted contract test and confirm it passes.
- [x] Compile `l4d2_zcs_redux.sp` with SourcePawn 1.12 into the isolated worktree's temporary plugin output.
- [x] Run relevant repository contract tests and inspect `git diff --check` with CRLF support.
- [x] Record that live server switching remains unverified and provide the manual check: set `zcs_tank_limit 1`, enter ghost, cycle to Tank or use `sm_buy tank`, and confirm the second Tank is rejected.


