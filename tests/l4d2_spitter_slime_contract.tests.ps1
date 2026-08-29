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
Require-Text $source 'StartUpdateTimer' 'The global slime update timer must be restartable after a map change.'
Require-Pattern $source '(?ms)public void OnMapStart\(\)\s*\{.*?StartUpdateTimer\(\);' 'OnMapStart must restart the global slime update timer.'
Require-Text $source 'OnSlimeEnableChanged' 'Slime enable changes must be handled while the plugin is loaded.'
Require-Text $source 'TR_TraceRayFilterEx' 'Targets must be selected using a visibility trace.'
Require-Text $source 'SDKHook(entity, SDKHook_Touch' 'Gas cans must explode on contact with any entity.'
Require-Text $source 'gas_explosion_initialburst_blast' 'Gas explosion must have its initial blast particle.'
Require-Text $source 'weapon_pipebomb_child_fire' 'Gas explosion must have its child-fire particle.'
Require-Pattern $source 'L4D_PrecacheParticle\(PARTICLE_GAS_BLAST\)' 'Gas blast particle must be precached.'
Require-Pattern $source 'L4D_PrecacheParticle\(PARTICLE_GAS_FIRE\)' 'Gas child-fire particle must be precached.'
Require-Text $source 'weapons/hegrenade/explode3.wav' 'Gas explosion must play an explosion sound.'
Require-Text $source 'weapons/hegrenade/explode5.wav' 'Gas explosion must have the alternate explosion sound.'
Require-Text $source 'models/props_junk/gascan001a.mdl' 'The active projectile must be a visible gas can.'
Require-Text $source 'IN_ATTACK' 'The replacement must document/use the IN_ATTACK path.'
Require-Pattern $source 'SetEntProp\(entity,\s*Prop_Send,\s*"m_bIsLive",\s*1\s*\)' 'Native slime must retain its live visual state.'
Require-Pattern $source 'DispatchKeyValue\(entity,\s*"physdamagescale",\s*"0\.0"\)' 'Gas cans must not inflict engine physics damage.'
Require-Pattern $source 'if\s*\(!L4D2_SetCustomAbilityCooldown\(client,\s*g_hGasCooldown\.FloatValue\)\)' 'Gas-can creation must fail safely when its cooldown cannot be set.'
Require-Pattern $source 'int attacker = owner;\s*if\s*\(!IsValidClient\(attacker\)\)\s*\{\s*attacker = inflictor;\s*\}' 'Gas damage must keep a valid SDKDamage attacker when the owner has left.'

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

$legacyRootBinaryPath = Join-Path $repo 'addons/sourcemod/plugins/L4D2 Spitter Supergirl.smx'
if (Test-Path -LiteralPath $legacyRootBinaryPath) {
    $errors.Add("The retired root plugin binary still exists: $legacyRootBinaryPath")
}

if (-not (Test-Path -LiteralPath $binaryPath)) {
    $errors.Add("Missing compiled plugin: $binaryPath")
}

if ($errors.Count -gt 0) {
    throw "Spitter slime contract failed:`n$($errors -join "`n")"
}

'Spitter slime contract passed'
