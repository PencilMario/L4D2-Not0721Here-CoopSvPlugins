# CustomVotes NativeVotes Hard Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Replace accumulated menu voting with one NativeVotes yes/no session after subject selection.

**Architecture:** One active-vote context owns stable subject identity and eligible-pool size. NativeVotes selection actions preserve per-choice notifications, while its result callback supplies final Yes/No counts for the configured custom threshold.

**Tech Stack:** SourcePawn 1.12, SourceMod menus, NativeVotes, multicolors.

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-07-30-customvotes-nativevotes-design.md` and `10-baseline-readset.md`.

**Compatibility Boundary:** Preserve public commands, chat triggers, selection menus, cooldown/call/pass limits, substitutions, notifications, and configured result commands. Accept but ignore legacy `vote` and `multiple` keys.

**Verification:** Static contract script, user-supplied SourcePawn 1.12 compiler command, repository searches, `git diff --check`, and documented server runtime checks.

---

### Task 1: Add failing migration contract

**Files:**
- Create: `Docs/aegis/work/2026-07-30-customvotes-nativevotes/verify.ps1`

**Why this task exists:** Prove the new dependency and retired accumulated-vote owners before production edits.

**Impact / Compatibility:** Static checks cover structural migration; compiler and runtime checks cover SourcePawn/API behavior.

**Verification:** Run `powershell -NoProfile -File Docs/aegis/work/2026-07-30-customvotes-nativevotes/verify.ps1`; initially expect failure because `customvotes.sp` still owns accumulated voting.

- [x] Add assertions requiring `#include <nativevotes>`, a NativeVotes result callback, and no retired accumulated-vote symbols.
- [x] Run the script and record the expected pre-implementation failure.

### Task 2: Introduce NativeVotes session ownership

**Files:**
- Modify: `addons/sourcemod/scripting/customvotes.sp`

**Why this task exists:** Establish one lifecycle owner before replacing four vote paths.

**Impact / Compatibility:** Only one active vote is supported, matching SourceMod and NativeVotes constraints.

**Repair Track:** Replace fragile parallel globals with explicit reset and stable target identity helpers.

**Retirement Track:** Old current-target globals retire once all formatting reads from the context.

**Verification:** Compile after adding context, eligibility, reset, threshold, and failure helpers.

- [x] Add the include, active context fields, and lifecycle helpers.
- [x] Compile with SourcePawn 1.12 and correct all new diagnostics.

### Task 3: Replace all final vote paths

**Files:**
- Modify: `addons/sourcemod/scripting/customvotes.sp`

**Why this task exists:** Make every selected player, map, list option, or simple action start a native yes/no vote.

**Impact / Compatibility:** Selection menus remain; final vote UI and result ownership move to NativeVotes.

**Repair Track:** NativeVotes result counts drive `max(minimum, ceil(pool * ratio))`, pass/fail display, notification, and command execution.

**Retirement Track:** Delete four SourceMod vote menus and their handlers after each caller uses the common NativeVotes starter.

**Verification:** Compile and require all four callers to reach the shared starter.

- [x] Route all four vote types through one NativeVotes creation path.
- [x] Implement selection notification, cancellation, final result, and pass/fail lifecycle callbacks.
- [x] Compile with SourcePawn 1.12.

### Task 4: Remove accumulated state and obsolete config behavior

**Files:**
- Modify: `addons/sourcemod/scripting/customvotes.sp`
- Modify: `addons/sourcemod/configs/customvotes.cfg`

**Why this task exists:** Complete the hard cutover and avoid two competing result owners.

**Impact / Compatibility:** Existing files still parse; `vote` and `multiple` no longer change behavior.

**Repair Track:** Menu labels and disconnect hooks stop reading accumulated selections.

**Retirement Track:** Delete boolean matrices, identity recovery arrays, count/check helpers, parsing flags, and connection lifecycle recovery.

**Verification:** Static contract passes and retired symbol search returns no matches in `customvotes.sp`.

- [x] Remove accumulated arrays, initialization, hooks, branches, helpers, and label counts.
- [x] Mark `vote` and `multiple` obsolete in the config comments.
- [x] Run the static contract and compiler.

### Task 5: Final verification and evidence

**Files:**
- Create: `Docs/aegis/work/2026-07-30-customvotes-nativevotes/50-evidence.md`

**Why this task exists:** Separate compiler/static proof from server-only residual risk.

**Impact / Compatibility:** No production behavior changes in this task.

**Verification:** Run the contract, authoritative compile, focused searches, and `git diff --check`.

- [x] Record command outputs and changed-file scope.
- [x] Record unverified server scenarios: native UI, target disconnect, team pool, cancellation, and competing vote.
