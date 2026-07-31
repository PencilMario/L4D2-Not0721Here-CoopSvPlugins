# Charger Melee 350 Binding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bind `l4d2_melee_damage_charger 350` to every selectable mode whose effective `sm_aidmgfix_enable` contains bit `2`, and document the resulting behavior.

**Architecture:** A PowerShell contract test reads the real match-mode menu and mode CFG files, treating the plugin defaults (`sm_aidmgfix_enable=3`, Charger melee override disabled) as the baseline. Each affected mode explicitly owns its 350 override; modes with effective values `0` or `1` remain untouched.

**Tech Stack:** SourceMod CFG, PowerShell regression test, Markdown

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-07-31-readme-refresh-design.md`, `addons/sourcemod/scripting/l4d2_ai_damagefix.sp` historical source at `eca1ebff`, `addons/sourcemod/scripting/l4d2_melee_damage_control.sp`, `addons/sourcemod/configs/matchmodes.txt`

**Compatibility Boundary:** Do not change `sm_aidmgfix_enable`, AI damage-fix plugin logic, or modes whose effective bitmask lacks bit `2`. The last hit against a Charger remains capped to its current health by the existing plugin.

**Verification:** Run the new contract test, existing PowerShell tests, README structure/link checks, and `git diff --check`.

---

### Task 1: Add the configuration contract test

**Files:**
- Create: `tests/charger_melee_damage_contract.tests.ps1`

**Why this task exists:**
- Future mode additions or bitmask changes must not silently break the coupling between Charger charge-damage normalization and melee damage.

**Impact / Compatibility:**
- Test only; reads current menu modes and CFG files without changing runtime state.

**Verification:**
- Test fails before CFG changes and names affected modes missing the 350 override.

- [ ] **Step 1: Write the contract test**

The test must parse selectable directories from `matchmodes.txt`, resolve an explicit `sm_aidmgfix_enable` or default to `3`, and require exactly one `l4d2_melee_damage_charger 350` setting when `(value -band 2) -ne 0`. Values `0` and `1` must have no Charger melee override.

- [ ] **Step 2: Run RED verification**

Run:

```powershell
pwsh -NoProfile -File tests/charger_melee_damage_contract.tests.ps1
```

Expected: non-zero exit with the current bit-2 modes listed as missing `l4d2_melee_damage_charger 350`.

### Task 2: Add explicit mode overrides

**Files:**
- Modify: affected files under `cfg/cfgogl/<mode>/`

**Why this task exists:**
- The existing melee plugin supports fixed Charger damage but defaults the feature off.

**Impact / Compatibility:**
- Only selectable modes whose effective `sm_aidmgfix_enable` is `2` or `3` receive the override.
- Modes with effective values `0` or `1` retain plugin default `-1`.

**Repair Track:**
- Canonical owners are the affected mode-specific CFG files.
- Add `confogl_addcvar l4d2_melee_damage_charger 350` beside the mode's damage/spawn settings.

**Retirement Track:**
- No old runtime owner is replaced; the previously disabled Charger override becomes explicitly mode-owned.
- No fallback or global default is added.

**Verification:**
- The contract test passes and reports every current selectable mode checked.

- [ ] **Step 1: Add the minimal CFG settings**

Add one explicit 350 override to each bit-2 mode and no other mode.

- [ ] **Step 2: Run GREEN verification**

Run:

```powershell
pwsh -NoProfile -File tests/charger_melee_damage_contract.tests.ps1
```

Expected: exit 0 with all selectable modes checked.

### Task 3: Update README and evidence

**Files:**
- Modify: `Docs/readme.md`
- Create: `Docs/aegis/work/2026-07-31-charger-melee-350/50-evidence.md`
- Modify: `Docs/aegis/INDEX.md`

**Why this task exists:**
- Operators need to see that bit-2 modes combine removed Charger charge reduction with fixed 350 melee damage.

**Impact / Compatibility:**
- Documentation must distinguish 350-per-swing from the final hit, which is capped to remaining health.

**Verification:**
- README maps all 24 selectable modes to their actual effective AI/Charger settings.

- [ ] **Step 1: Update overview and mechanism text**

Show `350` for all bit-2 modes and explain the remaining-health cap.

- [ ] **Step 2: Run full regression and document evidence**

Run:

```powershell
Get-ChildItem tests -Filter '*.ps1' | ForEach-Object { pwsh -NoProfile -File $_.FullName; if ($LASTEXITCODE) { throw "Failed: $($_.Name)" } }
git diff --check
```

Expected: all tests exit 0 and the diff check is clean.
