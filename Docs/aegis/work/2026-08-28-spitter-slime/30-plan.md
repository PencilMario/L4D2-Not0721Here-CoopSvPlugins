# Spitter Slime and Gas-can Replacement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:test-driven-development for each behavior slice. This plan is executed inline in the current workspace because the SourcePawn runtime and generated `.smx` must be verified together.

**Goal:** Replace the `versus_isfullshit`-only `L4D2 Spitter Supergirl` plugin with a new per-Spitter visible slime system and an `IN_ATTACK` gas-can ability.

**Architecture:** One SourcePawn plugin owns all Spitter state. Each Spitter has an independent timer, fixed-size slime slots containing entity references and arc/target state, and one gas-can entity reference. A short global timer moves slimes and performs lifecycle cleanup; `L4D2_ActivateAbility_Spitter` blocks the original spit only after a gas can is created successfully. All player damage is issued by `SDKHooks_TakeDamage`; particle entities and direct `TeleportEntity` velocity provide visual and knockback effects without an explosion damage entity or Fling SDK call.

**Tech Stack:** SourceMod/SourcePawn 1.12, `sdktools`, `sdkhooks`, existing Left4DHooks natives/forwards, PowerShell static contract tests, the repository `spcomp.exe`.

**Baseline / Authority Refs:** `AGENTS.md`; `Docs/aegis/specs/2026-08-28-spitter-slime-design.md`; `Docs/aegis/work/2026-08-28-spitter-slime/00-intent.md`; `10-baseline-readset.md`; `20-impact.md`; `cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg`; `versus.cfg`; `addons/sourcemod/scripting/L4D2 Spitter Supergirl.sp`; `addons/sourcemod/scripting/include/left4dhooks.inc`; `left4dhooks_stocks.inc`; `l4d_grenades.sp`; existing `tests/*.tests.ps1`.

**Compatibility Boundary:** Only `versus_isfullshit` changes. Keep `left4dhooks.smx`, other mode/plugin loaders, `z_spit_interval`, ordinary projectiles, and all other special infected logic unchanged. The old Supergirl source, binary, and loader line retire only after the new source/config/binary contract passes. A gas-can creation failure returns `Plugin_Continue`, preserving the original spit as the explicit safety fallback.

**Verification:** Run the new PowerShell contract first while the source is absent and record the expected failure; after implementation run it again, compile the new source with the project’s SourcePawn 1.12 command, verify the `.smx` exists, run `git diff --check`, and inspect the final loader/config diff. Server-only collision, particle visibility, and knockback feel remain deployment checks documented in the design.

---

### Task 1: Add the failing contract test

**Files:**
- Create: `tests/l4d2_spitter_slime_contract.tests.ps1`

**Why this task exists:** The feature changes a mode loader, a compiled plugin, and two damage paths. The contract protects the user-visible replacement and the non-negotiable SDKDamage/no-hard-stun boundary before any implementation is written.

**Impact / Compatibility:** The test reads files only. It must fail because the new source is missing, not because the test itself has a syntax error. It must reject loading both old and new plugins, `point_hurt`, `env_explosion`, `L4D2_CTerrorPlayer_Fling`, and `IN_ATTACK2`.

**Verification:**

- [ ] **Step 1: Write the failing test**

Create the file with this complete content:

```powershell
$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_spitter_slime.sp'
$binaryPath = Join-Path $repo 'addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx'
$loaderPath = Join-Path $repo 'cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg'
$modeConfigPath = Join-Path $repo 'cfg/cfgogl/versus_isfullshit/versus.cfg'

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing new plugin source: $sourcePath"
}

$source = Get-Content -Raw -LiteralPath $sourcePath
$loader = Get-Content -Raw -LiteralPath $loaderPath
$modeConfig = Get-Content -Raw -LiteralPath $modeConfigPath
$errors = [System.Collections.Generic.List[string]]::new()

function Require-Text {
    param([string]$Text, [string]$Needle, [string]$Message)
    if (-not $Text.Contains($Needle)) { $errors.Add($Message) }
}

function Require-Pattern {
    param([string]$Text, [string]$Pattern, [string]$Message)
    if ($Text -notmatch $Pattern) { $errors.Add($Message) }
}

Require-Text $source '#include <left4dhooks>' 'The plugin must use the existing Left4DHooks dependency.'
Require-Text $source '#include <sdktools>' 'The plugin must include sdktools.'
Require-Text $source '#include <sdkhooks>' 'The plugin must include sdkhooks.'
Require-Text $source 'L4D2_SpitterPrj' 'Slime must be the native spitter_projectile entity.'
Require-Text $source 'L4D2_ActivateAbility_Spitter' 'The original Spitter ability hook is missing.'
Require-Text $source 'L4D2_SetCustomAbilityCooldown' 'The gas-can ability must set its custom cooldown.'
Require-Text $source 'SDKHooks_TakeDamage' 'Player damage must use SDKDamage.'
Require-Text $source 'EntIndexToEntRef' 'Child entities must be stored as entity references.'
Require-Text $source 'EntRefToEntIndex' 'Child entity references must be validated before use.'
Require-Text $source 'CleanupSpitter' 'A shared per-Spitter cleanup owner is required.'
Require-Text $source 'HookEvent("player_death"' 'Spitter death must clean its child entities.'
Require-Text $source 'HookEvent("player_team"' 'Leaving the infected team must clean its child entities.'
Require-Text $source 'OnClientDisconnect' 'Disconnect cleanup is required.'
Require-Text $source 'OnPluginEnd' 'Plugin shutdown cleanup is required.'
Require-Text $source 'TR_TraceRayFilterEx' 'Targets must be selected using a visibility trace.'
Require-Text $source 'SDKHook(entity, SDKHook_Touch' 'Gas cans must explode on contact with any entity.'
Require-Text $source 'gas_explosion_initialburst_blast' 'Gas explosion must have its initial blast particle.'
Require-Text $source 'weapon_pipebomb_child_fire' 'Gas explosion must have its child-fire particle.'
Require-Text $source 'weapons/hegrenade/explode3.wav' 'Gas explosion must play an explosion sound.'
Require-Text $source 'weapons/hegrenade/explode5.wav' 'Gas explosion must have the alternate explosion sound.'
Require-Text $source 'models/props_junk/gascan001a.mdl' 'The active projectile must be a visible gas can.'
Require-Text $source 'IN_ATTACK' 'The replacement must document/use the IN_ATTACK path.'

foreach ($cvar in @(
    'l4d2_spitter_slime_enable',
    'l4d2_spitter_slime_interval',
    'l4d2_spitter_slime_max',
    'l4d2_spitter_slime_radius',
    'l4d2_spitter_slime_return_distance',
    'l4d2_spitter_slime_target_range',
    'l4d2_spitter_slime_speed',
    'l4d2_spitter_slime_arc_height',
    'l4d2_spitter_slime_damage',
    'l4d2_spitter_slime_hit_radius',
    'l4d2_spitter_gas_enable',
    'l4d2_spitter_gas_cooldown',
    'l4d2_spitter_gas_speed',
    'l4d2_spitter_gas_arc_height',
    'l4d2_spitter_gas_damage',
    'l4d2_spitter_gas_radius',
    'l4d2_spitter_gas_knockback',
    'l4d2_spitter_gas_knockup',
    'l4d2_spitter_gas_hurt_survivors',
    'l4d2_spitter_gas_hurt_infected'
)) {
    Require-Text $source $cvar "Missing plugin ConVar: $cvar"
    Require-Pattern $modeConfig "(?m)^confogl_addcvar\s+$cvar\s+" "Missing versus_isfullshit ConVar: $cvar"
}

Require-Pattern $modeConfig '(?m)^confogl_addcvar\s+l4d2_spitter_slime_interval\s+0\.3\s*$' 'Slime interval default must be 0.3 seconds.'
Require-Pattern $modeConfig '(?m)^confogl_addcvar\s+l4d2_spitter_slime_target_range\s+300(?:\.0)?\s*$' 'Slime target range default must be 300.'
Require-Pattern $modeConfig '(?m)^confogl_addcvar\s+l4d2_spitter_slime_max\s+5\s*$' 'Each Spitter must default to five slimes.'

if (($source | Select-String -Pattern 'SDKHooks_TakeDamage' -AllMatches).Matches.Count -lt 2) {
    $errors.Add('Slime and gas damage must each have an SDKHooks_TakeDamage path.')
}

foreach ($forbidden in @('point_hurt', 'env_explosion', 'L4D2_CTerrorPlayer_Fling', 'IN_ATTACK2')) {
    if ($source.Contains($forbidden)) { $errors.Add("Forbidden alternate path remains: $forbidden") }
}

Require-Pattern $loader '(?m)^sm plugins load optional/l4d2_spitter_slime\.smx\s*$' 'versus_isfullshit must load the new plugin.'
if ($loader -match '(?im)^sm plugins load .*L4D2 Spitter Supergirl\.smx\s*$') {
    $errors.Add('The retired Supergirl plugin is still loaded.')
}

if (-not (Test-Path -LiteralPath $binaryPath)) {
    $errors.Add("Missing compiled plugin: $binaryPath")
}

if ($errors.Count -gt 0) {
    throw "Spitter slime contract failed:`n$($errors -join "`n")"
}

'Spitter slime contract passed'
```

- [ ] **Step 2: Run it to verify it fails correctly**

Run:

```powershell
& "$PSHOME\pwsh.exe" -NoProfile -File .\tests\l4d2_spitter_slime_contract.tests.ps1
```

Expected: a terminating `Missing new plugin source` error. Do not create production SourcePawn before observing this failure.

- [ ] **Step 3: Commit the test**

```powershell
git add -- tests/l4d2_spitter_slime_contract.tests.ps1
git commit -m "test(spitter): 增加粘液替换契约"
```

### Task 2: Implement the new runtime owner

**Files:**
- Create: `addons/sourcemod/scripting/l4d2_spitter_slime.sp`

**Why this task exists:** This is the user-visible behavior: independently managed native slime projectiles, visible-survivor targeting, one-hit SDKDamage, and a gas can replacing the Spitter’s left-click ability.

**Impact / Compatibility:** Keep all state per Spitter. Never use a bare child entity index after a callback boundary. Slime projectiles are made non-solid/non-moving after creation so they remain visual entities controlled by the plugin and cannot create unintended acid pools. Gas damage is `DMG_GENERIC` through `SDKHooks_TakeDamage`; knockback is a direct velocity write and never a Fling or entity explosion damage path.

**Verification:** The contract must still fail only for missing config/binary after this source is created; then compile this source with the command in Task 4 and fix every compiler error before proceeding.

- [ ] **Step 1: Add the SourcePawn implementation in test-driven slices**

Implement the following concrete interfaces in this order, running the contract after each coherent slice:

1. Create the ConVars and `SlimeState`/per-owner references:

```sourcepawn
enum struct SlimeState
{
    int entRef;
    int target;
    bool tracking;
    float targetOffset[3];
    float arcStart[3];
    float arcEnd[3];
    float arcStartedAt;
    float arcDuration;
    float lastPos[3];
}

SlimeState g_Slimes[MAXPLAYERS + 1][MAX_SLIMES];
int g_SlimeCount[MAXPLAYERS + 1];
Handle g_SlimeTimers[MAXPLAYERS + 1];
int g_GasRefs[MAXPLAYERS + 1];
int g_GasOwner[MAX_TRACKED_ENTITIES];
bool g_GasExploded[MAX_TRACKED_ENTITIES];
float g_GasIgnoreUntil[MAX_TRACKED_ENTITIES];
Handle g_UpdateTimer;
```

Create all twenty listed ConVars with the design defaults/bounds: interval `0.3` min `0.05`, max slimes `5` range `0..32`, radius `180`, return distance `600`, target range `300`, speed `450`, arc height `80`, slime damage `10`, hit radius `32`, gas enabled `1`, cooldown `5`, gas speed `700`, gas arc height `140`, gas damage `50`, gas radius `250`, knockback `300`, knockup `100`, survivor hurt `1`, infected hurt `0`.

2. Add lifecycle entry points and the single cleanup owner:

```sourcepawn
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast);
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast);
public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast);
public void Event_RoundCleanup(Event event, const char[] name, bool dontBroadcast);
public void OnClientDisconnect(int client);
public void OnPluginEnd();
void CleanupSpitter(int client);
```

`CleanupSpitter` kills the per-owner timer, removes every valid `EntRefToEntIndex` slime, removes its gas can if still valid, resets all slots/guards, and is safe to call repeatedly. Hook `player_spawn`, `player_death`, `player_team`, `round_end`, `mission_lost`, and `map_transition`; use `round_start` to rescan and start valid Spitters. Start a `0.05`-second no-map-change update timer.

3. Add `StartSpitter`, `Timer_SpawnSlime`, `CreateSlime`, and `DestroySlimeSlot`. `CreateSlime` must call `L4D2_SpitterPrj`, set `m_hThrower`, preserve `m_bIsLive` only for the native visual, set collision group/solid type to non-colliding, set `MOVETYPE_NONE`, save `EntIndexToEntRef`, and initialize one random arc. The timer must stop and clean the owner if it is no longer a live non-ghost Spitter and must never exceed the current `l4d2_spitter_slime_max`.

4. Add `FindVisibleSurvivor`, `IsVisibleToSpitter`, and the arc helpers. Candidate filtering must require in-game, alive team-2 players, owner-to-eye distance `<= l4d2_spitter_slime_target_range`, and a `TR_TraceRayFilterEx` from owner eye to survivor eye that either does not hit or hits that survivor. Select `GetRandomInt(0, count - 1)` from the candidate list; do not lock all slimes to one shared target.

5. Add `Timer_UpdateSlimes`, `UpdateSlime`, `BeginRandomArc`, and `BeginTrackingArc`. For an owner-distance breach, teleport the slime to owner origin plus a small vertical offset and reset its target. Random arcs use a random local offset around the owner and `4.0 * arcHeight * progress * (1.0 - progress)` for the parabolic z component. Tracking arcs recalculate from the current slime position to the moving target each tick. Use a point-to-segment distance check against `l4d2_spitter_slime_hit_radius`, call `SDKHooks_TakeDamage(target, owner, owner, damage, DMG_ACID, -1, NULL_VECTOR, slimePos, true)`, then remove that slot immediately.

6. Add `L4D2_ActivateAbility_Spitter` and gas-can helpers. This Left4DHooks forward is the `IN_ATTACK` replacement path (include the literal `IN_ATTACK` in the explanatory comment); when enabled and `CreateGasCan` succeeds, call `L4D2_SetCustomAbilityCooldown` and return `Plugin_Handled`. On entity creation failure return `Plugin_Continue` so normal spit remains available. Create `prop_physics` with `models/props_junk/gascan001a.mdl`, set owner/ref state, apply a forward velocity plus vertical `l4d2_spitter_gas_arc_height`, and hook `SDKHook_Touch`.

7. Add `OnGasCanTouch`, `ExplodeGasCan`, `CreateExplosionParticle`, `DamageGasTargets`, and `ApplyGasKnockback`. The first touch sets `g_GasExploded[entity]` before doing work, unhooks touch, creates `info_particle_system` entities for `gas_explosion_initialburst_blast` and `weapon_pipebomb_child_fire`, randomly emits `weapons/hegrenade/explode3.wav` or `weapons/hegrenade/explode5.wav`, and damages each configured alive survivor/infected player once with `SDKHooks_TakeDamage`. Use `TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, knockbackVelocity)` for direct horizontal/vertical velocity; do not call `L4D2_CTerrorPlayer_Fling`, `point_hurt`, or `env_explosion`. Remove the gas can after the damage loop and delay particle cleanup with entity refs.

- [ ] **Step 2: Run the focused contract before config/binary**

Run the same PowerShell command from Task 1. Expected: the new source-specific checks pass, while the test reports missing loader/config/binary items. This confirms the source itself is being inspected.

- [ ] **Step 3: Compile and fix the implementation**

Run:

```powershell
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\l4d2_spitter_slime.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\optional\l4d2_spitter_slime.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

Expected: `Compilation successful.` and the new `.smx` exists. Warnings from unrelated legacy includes are acceptable only when compilation succeeds.

### Task 3: Switch the mode and retire the old owner

**Files:**
- Modify: `cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg`
- Modify: `cfg/cfgogl/versus_isfullshit/versus.cfg`
- Delete after Task 2 compile: `addons/sourcemod/scripting/L4D2 Spitter Supergirl.sp`
- Delete after Task 2 compile: `addons/sourcemod/plugins/optional/L4D2 Spitter Supergirl.smx`

**Why this task exists:** The new behavior must be loaded only where requested and the old plugin must not run concurrently or retain stale `l4d_ssg_*` behavior.

**Repair Track:** Replace the one old loader line with `sm plugins load optional/l4d2_spitter_slime.smx`; add one `confogl_addcvar` line for each new ConVar using the approved defaults. Keep all unrelated lines and `z_spit_interval` unchanged.

**Retirement Track:** The old Supergirl loader, source, and binary are no longer active after this task. Delete the exact old source/binary only after the new binary has compiled; no other plugin or `l4d_ssg_*` consumer is in scope.

**Verification:** The contract must pass and `rg -n "L4D2 Spitter Supergirl|l4d_ssg_" cfg/cfgogl/versus_isfullshit addons/sourcemod/plugins/optional addons/sourcemod/scripting` must show no target-mode loader/source/binary owner. The unrelated old plugin references outside this target may be reported but must not be edited.

- [ ] **Step 1: Change only the mode loader**

Replace:

```text
sm plugins load "optional/L4D2 Spitter Supergirl.smx"
```

with:

```text
sm plugins load optional/l4d2_spitter_slime.smx
```

- [ ] **Step 2: Add the approved mode ConVars**

Add the following block after `confogl_addcvar zcs_spitter_limit 6` in `versus.cfg`:

```text
confogl_addcvar l4d2_spitter_slime_enable 1
confogl_addcvar l4d2_spitter_slime_interval 0.3
confogl_addcvar l4d2_spitter_slime_max 5
confogl_addcvar l4d2_spitter_slime_radius 180.0
confogl_addcvar l4d2_spitter_slime_return_distance 600.0
confogl_addcvar l4d2_spitter_slime_target_range 300.0
confogl_addcvar l4d2_spitter_slime_speed 450.0
confogl_addcvar l4d2_spitter_slime_arc_height 80.0
confogl_addcvar l4d2_spitter_slime_damage 10.0
confogl_addcvar l4d2_spitter_slime_hit_radius 32.0
confogl_addcvar l4d2_spitter_gas_enable 1
confogl_addcvar l4d2_spitter_gas_cooldown 5.0
confogl_addcvar l4d2_spitter_gas_speed 700.0
confogl_addcvar l4d2_spitter_gas_arc_height 140.0
confogl_addcvar l4d2_spitter_gas_damage 50.0
confogl_addcvar l4d2_spitter_gas_radius 250.0
confogl_addcvar l4d2_spitter_gas_knockback 300.0
confogl_addcvar l4d2_spitter_gas_knockup 100.0
confogl_addcvar l4d2_spitter_gas_hurt_survivors 1
confogl_addcvar l4d2_spitter_gas_hurt_infected 0
```

- [ ] **Step 3: Delete the exact retired source and binary**

After the new compile succeeds, remove only the two paths listed in this task. This is an authorized retirement required to prevent accidental manual loading of the old owner; it does not touch any other untracked user files.

- [ ] **Step 4: Run the contract**

```powershell
& "$PSHOME\pwsh.exe" -NoProfile -File .\tests\l4d2_spitter_slime_contract.tests.ps1
```

Expected: `Spitter slime contract passed`.

### Task 4: Regression verification and evidence

**Files:**
- Create: `Docs/aegis/work/2026-08-28-spitter-slime/40-atomic-tasks.md`
- Create: `Docs/aegis/work/2026-08-28-spitter-slime/50-evidence.md`
- Create: `Docs/aegis/work/2026-08-28-spitter-slime/60-checkpoint.md`

**Why this task exists:** SourcePawn has no repository-side live L4D2 server harness, so reproducible static/compile evidence and an explicit residual manual-check list are needed before claiming the replacement is ready.

**Verification:** Run the focused contract, compile command, `git diff --check`, and a read-only status/diff audit. The final evidence must say whether live server verification was available; do not claim particle/collision behavior was proven by static checks.

- [ ] **Step 1: Run the complete verification set**

```powershell
& "$PSHOME\pwsh.exe" -NoProfile -File .\tests\l4d2_spitter_slime_contract.tests.ps1
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\l4d2_spitter_slime.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\optional\l4d2_spitter_slime.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
git diff --check
git status --short
git diff -- cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg cfg/cfgogl/versus_isfullshit/versus.cfg tests/l4d2_spitter_slime_contract.tests.ps1 addons/sourcemod/scripting/l4d2_spitter_slime.sp
```

Expected: contract passed, compiler says `Compilation successful.`, diff check emits no output, and only this task’s files appear alongside the already-present unrelated untracked files.

- [ ] **Step 2: Record evidence and residual server checks**

Record command outputs and commit SHAs in `50-evidence.md`. Record the following unverified deployment checks as residual risk: one Spitter never exceeds five slimes; each death removes only that owner’s slimes; visible survivors are randomly targeted; a gas can hits world/player/entity and explodes once with both particles/sound; SDKDamage applies the configured amount; direct velocity knockback does not produce a Charger-style hard stun.

- [ ] **Step 3: Final commit**

```powershell
git add -- addons/sourcemod/scripting/l4d2_spitter_slime.sp addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx cfg/cfgogl/versus_isfullshit tests/l4d2_spitter_slime_contract.tests.ps1 Docs/aegis/work/2026-08-28-spitter-slime
git commit -m "feat(spitter): 用粘液与汽油桶替换旧强化"
```

Do not add the unrelated existing untracked work files to this commit.

---

## Plan self-review

- Spec coverage: native visible `spitter_projectile`, per-owner cap/timers/cleanup, visible random target selection, parabolic movement, SDKDamage slime hit, `IN_ATTACK` gas can, any-object touch, particle/sound effects, configured blast damage, direct knockback, fallback on creation failure, mode-only loader/config, old owner retirement, and compile/static/server verification each have an owning task.
- Placeholder scan: no `TBD`, `TODO`, or unspecified implementation step is used; all code/config snippets and commands are concrete.
- Compatibility check: Left4DHooks and other modes remain unchanged; gas-can fallback and old-loader retirement are explicit.
- Verification check: every task has an exact PowerShell/compiler/read-only audit command and expected result.
- Dual-track check: the new runtime is the repair owner; the old loader/source/binary retire only after the new binary compiles.
