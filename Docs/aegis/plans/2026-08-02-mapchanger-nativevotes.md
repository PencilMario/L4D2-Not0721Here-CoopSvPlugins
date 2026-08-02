# MapChanger NativeVotes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace only MapChanger's change-map vote UI with NativeVotes while preserving its existing map selection, timing, access, veto/pass, logging, and map-change behavior.

**Architecture:** `MapChanger.sp` remains the sole owner of the vote lifecycle. The delayed map vote creates a `NativeVotesType_Custom_YesNo` vote, supplies per-client localized titles through the NativeVotes redraw action, and routes completion or cancellation into the existing post-vote action. The separate campaign-rating vote remains a SourceMod menu vote.

**Tech Stack:** SourcePawn, SourceMod, NativeVotes

**Baseline / Authority Refs:** User-approved design in the 2026-08-02 request; `addons/sourcemod/scripting/MapChanger.sp`; `addons/sourcemod/scripting/include/nativevotes.inc`

**Compatibility Boundary:** Do not change map menus, permissions, cooldowns, delayed announcement, vote duration, single-root-admin shortcut, rating votes, translations, logs, or the eventual `L4D_ChangeLevel` path. NativeVotes becomes a required plugin dependency.

**Verification:** Run `tests/mapchanger_nativevotes_contract.tests.ps1`, then compile `addons/sourcemod/scripting/MapChanger.sp` with the repository SourceMod include set.

---

### Task 1: Lock The Vote Contract

**Files:**
- Create: `tests/mapchanger_nativevotes_contract.tests.ps1`
- Test: `tests/mapchanger_nativevotes_contract.tests.ps1`

**Why this task exists:** The test distinguishes the requested NativeVotes map vote from the rating vote that must remain unchanged.

**Impact / Compatibility:** Static assertions cover the dependency, NativeVotes creation/display/result UI, and retirement of `Handle_VoteMapMenu` without prohibiting `Handle_VoteMarkMenu`.

**Verification:** `pwsh -NoProfile -File tests/mapchanger_nativevotes_contract.tests.ps1` must fail before implementation and pass afterward.

- [x] Write assertions for the approved contract.
- [x] Run the test and confirm it fails because MapChanger does not include or call NativeVotes.

### Task 2: Migrate The Change-Map Vote

**Files:**
- Modify: `addons/sourcemod/scripting/MapChanger.sp`

**Why this task exists:** Players must see and cast the change-map vote through L4D's native vote panel.

**Impact / Compatibility:** `StartVoteMap`, its delayed timer, veto/pass commands, localized title rendering, and completion handling are affected. `StartVoteMark` is not affected.

**Repair Track:** The canonical map-vote owner changes from SourceMod `Menu` to NativeVotes. The smallest change replaces creation, delayed display, callback handling, and cancellation calls while retaining the surrounding state and action code.

**Retirement Track:** `Handle_VoteMapMenu` and map-vote calls to SourceMod `CancelVote` retire completely. The SourceMod vote code for rating remains active because it is outside the requested scope.

**Verification:** The Task 1 contract test passes and SourcePawn compilation succeeds.

- [x] Add the NativeVotes include and active vote handle.
- [x] Create and display a delayed custom yes/no NativeVote with the original duration and initiator.
- [x] Localize the native panel title per client and handle pass/fail/cancel/end actions.
- [x] Route `sm_veto` and `sm_votepass` through `NativeVotes_Cancel` while preserving the existing outcome.
- [x] Run the contract test until it passes.

### Task 3: Compile And Review The Migration

**Files:**
- Verify: `addons/sourcemod/scripting/MapChanger.sp`
- Verify: `tests/mapchanger_nativevotes_contract.tests.ps1`

**Why this task exists:** NativeVotes callback signatures and handle lifetime rules must be accepted by the actual SourcePawn compiler.

**Impact / Compatibility:** This checks the full plugin compile boundary and verifies the diff contains no rating-vote migration or unrelated edits.

**Verification:** Contract test exits 0; compiler exits 0; `git diff --check` exits 0; targeted diff review confirms only the approved behavior changed.

- [x] Compile MapChanger with the available SourcePawn compiler and includes.
- [x] Run `git diff --check` and inspect the targeted diff.
- [x] Record any runtime-only residual risk, especially the absence of an attached L4D2 server session.
