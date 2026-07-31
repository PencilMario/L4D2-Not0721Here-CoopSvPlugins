# SI Spawn Mutation Class Limits Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve the official allowed special-infected classes in Mutation 17, Mutation 16, and Mutation 11 while retaining existing spawn controls.

**Architecture:** `Si_SpawnSetting.sp` reads and hooks `mp_gamemode`, then lets a focused mutation allocator populate the existing cached class-limit array before the general allocator runs. A PowerShell contract test protects the mappings and refresh lifecycle, while SourcePawn compilation verifies integration.

**Tech Stack:** SourcePawn 1.12, Left4DHooks, PowerShell, Markdown

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-07-31-si-spawn-mutation-class-limits-design.md`, `Docs/readme.md`, `addons/sourcemod/scripting/Si_SpawnSetting.sp`

**Compatibility Boundary:** Do not clamp the engine's 14-per-class limit in plugin code. Preserve general-mode allocation, DPS-limit behavior, public ConVars and commands, timing, scaling, and Relax behavior.

**Verification:** Run the focused PowerShell contract test red then green, compile `Si_SpawnSetting.sp` with the user-provided compiler and include paths, run all repository PowerShell tests, and run `git diff --check`.

---

### Task 1: Add the mutation allocation contract

**Files:**
- Create: `tests/si_spawn_mutation_limits.tests.ps1`

**Why this task exists:** The test must detect loss of a mode mapping, an allowed-class mapping, the game-mode refresh hook, or accidental plugin-side class clamping.

**Impact / Compatibility:** Read-only source contract; it does not alter runtime state.

**Verification:** `pwsh -NoProfile -File tests/si_spawn_mutation_limits.tests.ps1` must fail before implementation because `Si_SpawnSetting.sp` does not reference the three modes.

- [ ] Write a PowerShell test that loads `Si_SpawnSetting.sp` and requires `mp_gamemode`, a ConVar change hook, case-insensitive matches for `mutation17`, `mutation16`, and `mutation11`, and mutation allocations `{5}`, `{2, 4}`, and `{3}` respectively.
- [ ] Require the test to reject a mutation-path class clamp to 14 while allowing the documentation to mention that engine boundary.
- [ ] Run the test and confirm a non-zero exit caused by the missing mutation implementation.

### Task 2: Implement mode-aware class allocation

**Files:**
- Modify: `addons/sourcemod/scripting/Si_SpawnSetting.sp`

**Why this task exists:** The existing general allocator overrides official mutation class restrictions.

**Impact / Compatibility:** Only cached Director class limits for the three named modes change; all other modes retain the existing allocator.

**Repair Track:** Add `g_cvGameMode`, hook its changes to `RefreshDirectorSettings`, and add a mutation allocator that zeroes all six limits, assigns every slot to Jockey or Hunter for the single-class modes, and alternates Boomer then Spitter for Mutation 16.

**Retirement Track:** The general allocator stops owning these three modes but remains the sole owner for every other mode. No fallback, alias, or VScript owner is added.

**Verification:** The focused contract passes and the SourcePawn compiler exits 0.

- [ ] Add the minimal mutation allocator and invoke it before the existing general allocation loop.
- [ ] Hook `mp_gamemode` changes to the existing refresh path, with null fallback to general allocation.
- [ ] Run the focused test and confirm exit 0.
- [ ] Compile with `E:/GithubKu/L4d2_0721sv_plugins/spcomp.exe`, outputting `addons/sourcemod/plugins/Si_SpawnSetting.smx`, using the repository scripting/include paths and the Competitive-Rework include path.

### Task 3: Document and regress the behavior

**Files:**
- Modify: `Docs/readme.md`
- Modify: `Docs/aegis/INDEX.md`
- Modify: `Docs/aegis/work/2026-07-31-si-spawn-mutations/40-atomic-tasks.md`
- Create: `Docs/aegis/work/2026-07-31-si-spawn-mutations/50-evidence.md`

**Why this task exists:** Operators need the mutation mappings and must understand that 14 is an engine limit, not plugin validation.

**Impact / Compatibility:** Documentation only; state Mutation 16 can reach 28 total as 14 Boomers plus 14 Spitters.

**Verification:** Focused test, all PowerShell regression scripts, final SourcePawn compile, `git diff --check`, and final diff inspection.

- [ ] Add a mutation-specific subsection after general class allocation and DPS rules.
- [ ] Run every `tests/*.ps1` script and require all to exit 0.
- [ ] Recompile the plugin, run `git diff --check`, inspect status/diff, and record exact evidence and runtime residual risk.
- [ ] Commit the implementation with a diff-grounded Conventional Commit message.

