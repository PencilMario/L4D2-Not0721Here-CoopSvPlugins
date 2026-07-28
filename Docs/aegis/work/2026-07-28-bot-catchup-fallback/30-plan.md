# Bot Catch-up Fallback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Bot catch-up follow the nearest living human, retain useful acceleration on maps without Flow, and safely gather Bots after all humans reach the ending checkpoint.

**Architecture:** The 5-second timer first evaluates the ending-checkpoint group teleport. Otherwise, each Bot resolves its nearest living human and chooses either normalized Flow lag or legacy world-distance lag. Both modes feed the same speed, invisibility, adrenaline, and shove state owner.

**Tech Stack:** SourcePawn, SourceMod, SDKTools, Left 4 DHooks, PowerShell contract tests, SourcePawn Compiler 1.12.

**Baseline / Authority Refs:** Approved conversation design and `10-baseline-readset.md`.

**Compatibility Boundary:** Preserve the existing timer, 1.25 invisibility multiplier, strict greater-than adrenaline threshold, ownership-aware adrenaline removal, and common-infected-only shove kill.

**Verification:** RED/GREEN contract test, SourcePawn compilation, stale-artifact check, and `git diff --check`.

---

### Task 1: Nearest-human Flow and distance fallback

- [ ] Extend the contract test to require nearest-human selection and both lag modes.
- [ ] Run it and confirm failure because the new helpers are absent.
- [ ] Implement nearest-human selection, Flow validity checks, and distance fallback.
- [ ] Run the contract test and confirm this slice passes.

### Task 2: Ending-checkpoint Bot gathering

- [ ] Extend the contract test for the conjunctive checkpoint and rescue-safety guards.
- [ ] Run it and confirm failure before adding teleport behavior.
- [ ] Implement checkpoint eligibility, nearest checkpoint-human selection, teleport, and stuck correction.
- [ ] Run the full contract test and compile the plugin.

### Task 3: Regression and evidence

- [ ] Confirm the SMX is refreshed and no unrelated artifacts changed.
- [ ] Run `git diff --check` and inspect the final diff.
- [ ] Record verification evidence and the live-server smoke-test boundary.

**Repair Track:** Replace the global slowest-human Flow baseline with a per-Bot nearest-human baseline and restore legacy distance behavior only when Flow inputs are invalid.

**Retirement Track:** Retire `FindLastLivingHumanFlow`; retain the original 5-second owner, visibility multiplier, and enhancement-state lifecycle.
