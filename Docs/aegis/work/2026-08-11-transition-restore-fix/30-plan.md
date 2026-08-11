# Transition Restore Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the transition restore plugin load with its gamedata and restore the complete survivor save record selected by the 1.2.5 implementation path.

**Architecture:** Keep the plugin's custom low-level detours and memory patch because Left 4 DHooks does not expose the required save-record selector or `PlayerSaveData::Restore` hook. Restore the historical bot-data selection path and align source address names with the canonical gamedata.

**Tech Stack:** SourcePawn 1.12, DHooks, SourceScramble, PowerShell contract tests.

**Baseline / Authority Refs:** `AGENTS.md`, `addons/sourcemod/gamedata/transition_restore_fix.txt`, `addons/sourcemod/scripting/transition_restore_fix.sp`, commits `27d73a6b` and `d1a081f9`, `addons/sourcemod/scripting/include/left4dhooks.inc`.

**Compatibility Boundary:** Preserve `restart_keep_identity` behavior, the existing UserID memory patch, survivor-count patch, gamedata names/signatures, and the deletion of the duplicate root `.smx`. Do not modify Left 4 DHooks or add a weapon-class-specific fallback.

**Verification:** Run the new contract test in RED before the source change, run it GREEN after the change, compile with the project compiler, run repository PowerShell tests, and run `git diff --check`.

---

### Task 1: Prove the transition restore contract fails

**Files:**
- Create: `tests/transition_restore_fix_contract.tests.ps1`

**Repair Track:** The test will require plural gamedata address names and the full `PlayerSaveData::Restore` selection path.

**Retirement Track:** No runtime path is retired by the test; it prevents the singular-name and identity-only implementation from returning.

- [ ] Add assertions for the plural `GetAddress` calls, the `PlayerSaveData::Restore` detour, the bot-data selectors, and the matching gamedata keys.
- [ ] Run the test and record the expected failure against the current source.

### Task 2: Restore complete save-record selection

**Files:**
- Modify: `addons/sourcemod/scripting/transition_restore_fix.sp:23-53,131-240,242-362`

**Repair Track:** Change the two stale address lookups to the existing plural keys and restore `PlayerSaveData::Restore` pre/post handling plus model/character-based bot save-record selection from `27d73a6b`.

**Retirement Track:** The identity-only restart path is replaced by full save-record selection for bot or unmatched-player data. The UserID patch and existing spectator/fill-slot detours remain active.

- [ ] Implement the smallest source diff that satisfies the contract test and preserves current compile APIs.
- [ ] Run the targeted contract test and compile the plugin.

### Task 3: Regression verification

**Files:**
- Create: `Docs/aegis/work/2026-08-11-transition-restore-fix/50-evidence.md`

- [ ] Run all repository PowerShell tests and the targeted transition contract test.
- [ ] Run `git diff --check` and inspect the final diff for unrelated changes.
- [ ] Record the compile result and the remaining live-server verification requirement.
