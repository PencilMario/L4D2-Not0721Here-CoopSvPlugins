# SI Spawn Naming Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Atomically migrate the SI spawn plugin and every repository consumer to the approved `si_spawn` public namespace and readable SourcePawn identifiers.

**Architecture:** `Si_SpawnSetting.sp` remains the sole setting owner while its public ConVar and command strings change. All repository consumers are mechanically updated in the same branch; legacy names receive no aliases and become a zero-match retirement contract.

**Tech Stack:** SourcePawn, SourceMod configuration, Squirrel VScript, Confogl CFG, PowerShell/rg verification.

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-07-30-si-spawn-naming-migration-design.md`.

**Compatibility Boundary:** Preserve defaults, values, command arguments, Director keys, and spawn behavior. Repository-external consumers are intentionally not supported after the hard cutover.

**Verification:** Red/green repository contract search, compilation of four affected SourcePawn plugins with the server compiler, and `git diff --check`.

---

### Task 1: Establish the legacy-name contract

**Files:**
- Read: all repository files excluding `.git`, `.worktrees`, and `*.smx`

**Why this task exists:** A hard cutover is only safe when the old interface has a measurable retirement condition.

**Impact / Compatibility:** Read-only baseline; proves the test detects existing legacy consumers.

**Verification:** Search all 14 legacy public names and require a nonzero baseline match count.

- [ ] Run the exact legacy-name search before edits and record its nonzero result.
- [ ] Record the set of runtime consumer file categories found.

### Task 2: Rename the canonical SourcePawn owner

**Files:**
- Modify: `addons/sourcemod/scripting/Si_SpawnSetting.sp`

**Why this task exists:** Make declarations and implementation readable while installing the new public contract.

**Impact / Compatibility:** Public names hard-cut; values and behavior remain invariant.

**Repair Track:** Replace inconsistent identifiers and public strings in the canonical owner with the approved mapping, without modifying algorithms.

**Retirement Track:** Old ConVars, old commands, and their callback names retire immediately and receive no aliases.

**Verification:** Compile `Si_SpawnSetting.sp`; inspect diff to confirm changes are naming-only.

- [ ] Rename all ConVar handles, timer/cache variables, callbacks, and helper functions using the approved descriptive map.
- [ ] Replace all 11 `CreateConVar` strings and all 3 registered commands plus usage messages.
- [ ] Compile with `E:/GithubKu/L4d2_0721sv_plugins/spcomp.exe` and the established include order.

### Task 3: Migrate every repository consumer

**Files:**
- Modify: matching SourcePawn consumers under `addons/sourcemod/scripting/`
- Modify: matching configs under `addons/sourcemod/configs/` and `cfg/cfgogl/`
- Modify: matching scripts under `scripts/vscripts/`
- Modify: active Aegis docs naming the interface

**Why this task exists:** Prevent menus, votes, presets, advertisements, panels, and retained mode scripts from reading nonexistent names.

**Impact / Compatibility:** All repository-owned configuration paths switch atomically; unrelated mode-script behavior remains untouched.

**Repair Track:** Mechanically replace exact public names and remove obsolete SI-setting `sm_reloadscript` suffixes.

**Retirement Track:** The legacy interface must reach zero matches outside the historical mapping table in the approved design.

**Verification:** Compile `server_setting.sp`, `extra_menu_test.sp`, and `l4d_teamspanel.sp`; run old/new-name repository searches.

- [ ] Replace exact ConVar and command strings in every baseline match.
- [ ] Remove obsolete reload suffixes from migrated vote/test-menu SI actions.
- [ ] Update active documentation and runtime verification instructions.
- [ ] Compile all three SourcePawn consumers with the server compiler.

### Task 4: Verify and record the cutover

**Files:**
- Modify: `Docs/aegis/work/2026-07-30-si-spawn-naming/40-atomic-tasks.md`
- Create: `Docs/aegis/work/2026-07-30-si-spawn-naming/50-evidence.md`

**Why this task exists:** Distinguish locally proven repository completeness from server-only runtime checks.

**Impact / Compatibility:** Evidence only.

**Verification:** All four compiles exit 0; legacy runtime names have zero matches outside the mapping spec; all new names are present; diff check passes.

- [ ] Re-run all four compiles from clean output paths.
- [ ] Run legacy zero-match and new-name presence assertions.
- [ ] Run `git diff --check` and inspect the changed-file list.
- [ ] Record server runtime checks for menu, votes, advertisements, presets, and direct commands.
