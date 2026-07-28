# Bot Catch-up Speed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace distance-based Bot acceleration with map-progress catch-up, sustained adrenaline, and common-infected shove kills.

**Architecture:** Left 4 DHooks supplies navigation-flow inputs and adrenaline effects. The plugin owns per-Bot eligibility state, movement multipliers, and a narrow `entity_shoved` handler that sends `Kill` only to entities whose exact classname is `infected`.

**Tech Stack:** SourcePawn, SourceMod, SDKTools, Left 4 DHooks, PowerShell contract tests, `spcomp`.

**Baseline / Authority Refs:** Approved conversation design and `10-baseline-readset.md`.

**Compatibility Boundary:** Preserve 5-second checks and survivor-Bot-only movement changes; update every old SMX load reference; do not affect non-common targets.

**Verification:** Contract test, repository reference search, and SourcePawn compilation.

---

### Task 1: Lock behavior and rename contract

- [ ] Add a failing contract test for filename references, flow formula, threshold, visibility multiplier, and common-infected filtering.
- [ ] Run it and confirm failure against the old implementation.
- [ ] Rename the source and runtime references.
- [ ] Implement the minimal behavior and rerun the contract test.

### Task 2: Compile and regression-check

- [ ] Compile `bot_catchup_speed.sp` with repository includes.
- [ ] Search for stale `bot_missing_movement` references.
- [ ] Inspect the diff for unrelated or conflicting changes.
- [ ] Record exact verification evidence and residual runtime risk.

**Repair Track:** Replace world-distance logic, whose boost did not represent campaign progress, at its existing plugin owner.

**Retirement Track:** Retire `bot_missing_movement.sp`, its SMX load name, and its distance-derived `whatSpeedNeed` branch; retain the existing visibility helper and 5-second timer.
