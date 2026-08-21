# Survivor Bot Bone Query Guard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent `l4d2_sb_ai_improver` from entering the engine's bone SDKCalls when a target entity has no usable model data, while preserving normal bone-based aiming.

**Architecture:** `navigation.inc` will own one model-readiness predicate and one guarded `LookupBone` wrapper. `aiming.inc` and `LBI_GetBonePosition` will use those canonical helpers; failed bone queries will retain an entity-origin fallback instead of reading uninitialized vectors.

**Tech Stack:** SourcePawn 1.12, SourceMod SDKTools, PowerShell structural tests, the repository's known-good `spcomp.exe`.

**Baseline / Authority Refs:** `AGENTS.md` compiler command; `addons/sourcemod/scripting/l4d2_sb_ai_improver/README.md` include-order and module ownership rules; crash report `D:/Windows/Download/8ff6146defd66e08c94a975c6a2c2d97d4c3fd1d488007f4e41ce799f42ffd1e.ai`; approved design in the preceding conversation.

**Compatibility Boundary:** Keep the existing `CBaseAnimating::LookupBone` gamedata signature and normal bone aiming behavior. Only invalid/unready model states take the fallback path. Do not alter other plugins or globally disable improved bot behavior.

**Verification:** RED/GREEN PowerShell guard test, existing module contract test, candidate SourcePawn compilation to a temporary SMX and the tracked plugin artifact, and `git diff --check` plus clean-scope review.

---

### Task 1: Add a failing bone-guard contract test

**Files:**
- Create: `tests/l4d2_sb_ai_bone_guard.tests.ps1`

**Why this task exists:** The current code calls `g_hLookupBone` directly from aiming code and only checks edict validity in the position helper. The test encodes the approved invariant that all bone lookups must pass through one guard and that both aim functions must retain a safe origin fallback.

**Impact / Compatibility:** This is a static contract test because the repository has no local L4D2 runtime harness. It must fail against the current implementation before any production code is changed.

**Verification:** Run `& .\\tests\\l4d2_sb_ai_bone_guard.tests.ps1`; expected result is a deliberate failure reporting the missing guard.

- [x] **Step 1: Write the failing test**

```powershell
$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$aimingPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/aiming.inc'
$navigationPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc'
$aiming = Get-Content -Raw -LiteralPath $aimingPath
$navigation = Get-Content -Raw -LiteralPath $navigationPath

foreach ($required in @(
    'bool LBI_IsBoneQueryReady(int iEntity)',
    'HasEntProp(iEntity, Prop_Send, "m_nModelIndex")',
    'GetEntProp(iEntity, Prop_Send, "m_nModelIndex")',
    'HasEntProp(iEntity, Prop_Data, "m_ModelName")',
    'GetEntPropString(iEntity, Prop_Data, "m_ModelName"',
    'int LBI_LookupBone(int iEntity, const char[] sBoneName)',
    'int iBoneIndex = LBI_LookupBone(iEntity, sBoneName)'
)) {
    if (-not $navigation.Contains($required)) {
        throw "Missing required bone guard contract: $required"
    }
}

if (([regex]::Matches($navigation + $aiming, 'SDKCall\\(g_hLookupBone')).Count -ne 1) {
    throw 'g_hLookupBone must have exactly one guarded SDKCall owner'
}

if (-not $aiming.Contains('if (!LBI_IsBoneQueryReady(iTarget))')) {
    throw 'aiming.inc must short-circuit unready target models'
}

if (-not $aiming.Contains('GetEntityAbsOrigin(iTarget, fAimPos)')) {
    throw 'aiming.inc must preserve an entity-origin fallback'
}

'l4d2_sb_ai bone guard contract passed'
```

- [x] **Step 2: Run test to verify it fails**

Run: `& .\\tests\\l4d2_sb_ai_bone_guard.tests.ps1`

Expected: FAIL with `Missing required bone guard contract: bool LBI_IsBoneQueryReady(int iEntity)`.

---

### Task 2: Add the canonical guarded SDKCall owner

**Files:**
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc:377-387`

**Why this task exists:** The engine crash occurs inside `Studio_BoneIndexByName` after a `LookupBone` SDKCall. The canonical owner must reject invalid edicts, absent model indices, absent model names, and empty bone names before entering the engine.

**Impact / Compatibility:** Normal entities with a nonzero model index and nonempty model name continue to use the same gamedata signature and return value. The old direct `SDKCall(g_hLookupBone, ...)` path is retired and replaced by `LBI_LookupBone`; `LBI_GetBonePosition` remains the public internal helper used by aiming.

**Repair Track:** Add `LBI_IsBoneQueryReady` and `LBI_LookupBone`; recheck readiness before `GetBonePosition` to reduce a model-destruction race between the two calls.

**Retirement Track:** The direct `SDKCall(g_hLookupBone, ...)` calls in `aiming.inc` and `LBI_GetBonePosition` retire. The gamedata signature remains because the guarded wrapper still owns the normal path.

**Verification:** The new guard test passes; the SourcePawn compiler accepts the helper and all callers.

- [x] **Step 1: Write minimal implementation**

```sourcepawn
bool LBI_IsBoneQueryReady(int iEntity)
{
	if (!IsEntityExists(iEntity))return false;
	if (!HasEntProp(iEntity, Prop_Send, "m_nModelIndex") || GetEntProp(iEntity, Prop_Send, "m_nModelIndex") <= 0)return false;
	if (!HasEntProp(iEntity, Prop_Data, "m_ModelName"))return false;

	static char sModelName[PLATFORM_MAX_PATH];
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	return (sModelName[0] != '\0');
}

int LBI_LookupBone(int iEntity, const char[] sBoneName)
{
	if (!LBI_IsBoneQueryReady(iEntity) || sBoneName[0] == '\0')return -1;
	return SDKCall(g_hLookupBone, iEntity, sBoneName);
}

bool LBI_GetBonePosition(int iEntity, const char[] sBoneName, float fBuffer[3])
{
	int iBoneIndex = LBI_LookupBone(iEntity, sBoneName);
	if (iBoneIndex == -1 || !LBI_IsBoneQueryReady(iEntity))return false;

	static float fUnusedAngles[3];
	SDKCall(g_hGetBonePosition, iEntity, iBoneIndex, fBuffer, fUnusedAngles);

	return (IsValidVector(fBuffer));
}
```

- [x] **Step 2: Run the target test**

Run: `& .\\tests\\l4d2_sb_ai_bone_guard.tests.ps1`

Expected: PASS with `l4d2_sb_ai bone guard contract passed`.

---

### Task 3: Route aiming through the guard and preserve fallback output

**Files:**
- Modify: `addons/sourcemod/scripting/l4d2_sb_ai_improver/aiming.inc:96-152`

**Why this task exists:** `GetClosestToEyePosEntityBonePos` and `GetTargetAimPart` currently call `g_hLookupBone` directly and can leave output vectors uninitialized when a bone lookup fails.

**Impact / Compatibility:** Initialize the output to zero, populate it with `GetEntityAbsOrigin` when available, and return early for an unready model. For ready models, retain the existing skeleton selection, visibility checks, and bone preference order.

**Repair Track:** Replace direct lookups with `LBI_LookupBone`; check `LBI_GetBonePosition` before using its output. The fallback changes only failure cases.

**Retirement Track:** No fallback owner is added outside the canonical aiming module; the previous uninitialized-vector behavior is retired.

**Verification:** The guard test must pass, the module contract must pass, and the candidate plugin must compile.

- [x] **Step 1: Update the closest-bone aim path**

Initialize `fAimPos`, call `GetEntityAbsOrigin`, return when `LBI_IsBoneQueryReady` is false, and replace the direct lookup with `LBI_LookupBone`.

- [x] **Step 2: Update the general target aim path**

Initialize `fAimPos` with the entity-origin fallback before the model guard. Replace the direct lookup with `LBI_LookupBone` and return when the primary `LBI_GetBonePosition` call fails.

- [x] **Step 3: Run the guard test and compiler**

Run the guard test, the existing module test, and compile `l4d2_sb_ai_improver.sp` first to a unique file under `[System.IO.Path]::GetTempPath()` and then to the tracked `addons/sourcemod/plugins/l4d2_sb_ai_improver.smx` using the AGENTS.md include paths. Expected: both tests exit 0 and both compiler invocations exit 0 with SMX outputs.

---

### Task 4: Review the patch and preserve rollback scope

**Files:**
- Review: `tests/l4d2_sb_ai_bone_guard.tests.ps1`
- Review: `addons/sourcemod/scripting/l4d2_sb_ai_improver/aiming.inc`
- Review: `addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc`

**Why this task exists:** Confirm the guard is centralized, the old direct owner is gone, no gamedata or unrelated plugin changed, and the live `.smx` is not overwritten accidentally.

**Impact / Compatibility:** The only runtime behavior change is a safe origin fallback when model data is unavailable. The tracked SMX is rebuilt from the reviewed source; no commit, server connection, plugin unload, or server-side deployment is part of this task.

**Verification:** Run `git diff --check`, `git status --short`, inspect the diff, and report runtime reproduction as still required because no local L4D2 server is available.

- [x] **Step 1: Run final checks**

```powershell
git diff --check
git status --short
```

- [x] **Step 2: Record residual risk**

The guard reduces invalid-model SDKCall crashes but cannot make the check and engine call atomic. Reproduce on `c3m2_swamp` with the rebuilt SMX before treating the crash as fully closed.
