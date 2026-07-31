# README Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the stale configuration reference in `Docs/readme.md` with an accurate, readable guide derived from the current repository configuration.

**Architecture:** Treat active CFG files and plugin command definitions as canonical data, then present stable facts in overview tables and mode-specific detail sections. Avoid copying volatile full plugin load files into the README; link them instead.

**Tech Stack:** Markdown, SourceMod CFG, PowerShell verification commands

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-07-31-readme-refresh-design.md`, `cfg/cfgogl/`, `cfg/cfgogl/coop_base/shared_plugins.cfg`, `addons/sourcemod/configs/customvotes.cfg`

**Compatibility Boundary:** Preserve intentional configuration identifiers and display names; change documentation only and leave runtime files untouched.

**Verification:** Compare documented mode identifiers with active directories, scan for retired command names, validate Markdown structures, and run `git diff --check`.

---

### Task 1: Build the current configuration inventory

**Files:**
- Read: `cfg/cfgogl/*`
- Read: `addons/sourcemod/configs/matchmodes.txt`
- Read: `addons/sourcemod/configs/customvotes.cfg`
- Read: `addons/sourcemod/scripting/Si_SpawnSetting.sp`

**Why this task exists:**
- The existing README contains stale identifiers and values, so every replacement claim needs a current repository source.

**Impact / Compatibility:**
- Read-only investigation; unresolved or conflicting claims are omitted rather than guessed.

**Verification:**
- Every mode selected for documentation maps to an active `cfg/cfgogl/<mode>/` directory and a match-mode entry when applicable.

- [ ] **Step 1: List active modes and user-facing names**

Run:

```powershell
Get-ChildItem cfg/cfgogl -Directory | Select-Object -ExpandProperty Name
Get-Content addons/sourcemod/configs/matchmodes.txt
```

Expected: an inventory containing the current mode identifiers and display names.

- [ ] **Step 2: Extract effective mode settings and inheritance**

Run:

```powershell
rg -n "exec|si_spawn_|z_difficulty|survivor_limit|sm_setammomulti|tank|weapon_improve" cfg/cfgogl
```

Expected: evidence for spawn values, inherited base configs, difficulty, survivor limits, ammo, Tank, and weapon variants.

- [ ] **Step 3: Confirm current vote controls and spawn terminology**

Run:

```powershell
rg -n "si_spawn_|sm_si_spawn_|Relax|DPS" addons/sourcemod/configs/customvotes.cfg addons/sourcemod/scripting/Si_SpawnSetting.sp
```

Expected: only the current `si_spawn` namespace and current command semantics.

### Task 2: Rewrite the configuration guide

**Files:**
- Modify: `Docs/readme.md`

**Why this task exists:**
- Readers need a scannable overview and accurate details without maintaining a duplicated plugin load file.

**Impact / Compatibility:**
- Preserve intentional names and voice. Retire stale duplicated plugin lines and obsolete historical explanations from the README only.

**Repair Track:**
- Canonical owners are active mode CFG files and plugin definitions.
- Replace stale names, values, and command terminology with repository-backed descriptions.

**Retirement Track:**
- Remove the copied full plugin load list and unsupported historical notes.
- Keep a categorized plugin summary and direct links to canonical files.

**Verification:**
- The document includes navigation, grouped mode overview, mode details, current mechanisms, and categorized plugin/fix summaries.

- [ ] **Step 1: Replace the document with the approved structure**

Edit `Docs/readme.md` using the inventory from Task 1. Use Markdown tables for comparisons and `<details>` only for mode-specific detail blocks.

- [ ] **Step 2: Review every factual statement against its owner**

Run targeted `rg` searches against the corresponding CFG or plugin source for each numerical or command claim. Remove claims without evidence.

### Task 3: Validate and review the finished README

**Files:**
- Verify: `Docs/readme.md`

**Why this task exists:**
- A formatting rewrite can introduce broken links, malformed HTML blocks, or accidentally retain stale identifiers.

**Impact / Compatibility:**
- Verification must show that only documentation/task records changed and runtime files remain untouched.

**Verification:**
- All commands below succeed and the final diff matches the approved scope.

- [ ] **Step 1: Run structural checks**

Run:

```powershell
$text = Get-Content -Raw Docs/readme.md
if (($text | Select-String '<details>' -AllMatches).Matches.Count -ne ($text | Select-String '</details>' -AllMatches).Matches.Count) { throw 'Unbalanced details tags' }
if (($text | Select-String '```' -AllMatches).Matches.Count % 2) { throw 'Unbalanced code fences' }
git diff --check
```

Expected: no errors or whitespace warnings.

- [ ] **Step 2: Check mode identifiers and retired terminology**

Run:

```powershell
rg -n "mutation4_expect|realisn_jimen|script_reloader|sm_setspawn|sm_setinterval" Docs/readme.md
```

Expected: no matches.

- [ ] **Step 3: Review scope and diff**

Run:

```powershell
git status --short
git diff --stat
git diff -- Docs/readme.md
```

Expected: runtime files are unchanged and the README diff implements the approved structure.

