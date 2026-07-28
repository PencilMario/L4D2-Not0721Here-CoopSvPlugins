# Survivor Bot AI Modularization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the 6,795-line Survivor Bot AI plugin into responsibility-oriented internal modules while retaining one behavior-compatible SMX.

**Architecture:** Keep the `.sp` file as composition root and use textual `.inc` modules at the original declaration positions. The first pass extracts contiguous, lower-coupling responsibility regions; later performance work can introduce explicit state interfaces.

**Tech Stack:** SourcePawn 1.12, SourceMod, Left 4 DHooks, VScript, PowerShell contract tests.

**Baseline / Authority Refs:** Approved conversation design and `10-baseline-readset.md`.

**Compatibility Boundary:** No AI decision, callback signature, ConVar, timing, or generated plugin name changes.

**Verification:** Structural contract test and compilation with the exact user-provided compiler/search paths.

---

### Task 1: Establish a buildable baseline

- [ ] Add and run the structural contract test to observe failure.
- [ ] Order `left4dhooks` before `vscript` so the latter's existing compatibility guard suppresses its duplicate enum.
- [ ] Compile before moving functions and record any additional pre-existing compiler errors.

### Task 2: Extract responsibility modules

- [ ] Extract ConVar setup/update code to `convars.inc`.
- [ ] Extract event and client lifecycle callbacks to `events.inc`.
- [ ] Extract item/weapon knowledge and entity cache code to `weapons.inc`.
- [ ] Extract navigation and reachability helpers to `navigation.inc`.
- [ ] Extract BehaviorActions and related detours to `actions.inc`.
- [ ] Preserve textual ordering by placing each include at its former code position.

### Task 3: Verify compatibility

- [ ] Run the structural contract test.
- [ ] Compile to a temporary SMX using SourcePawn 1.12.0.7221 and all provided include paths.
- [ ] Inspect the diff for accidental behavior edits and record residual runtime risk.

**Repair Track:** Resolve duplicate `fieldtype_t` ownership through include ordering; `left4dhooks.inc` remains canonical.

**Retirement Track:** Retire the monolithic ownership of extracted functions; retain a single plugin composition root and defer hot-path algorithm changes.
