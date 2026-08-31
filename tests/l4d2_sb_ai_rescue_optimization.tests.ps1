$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$root = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$state = Get-Content -Raw -LiteralPath (Join-Path $root 'state.inc')
$convars = Get-Content -Raw -LiteralPath (Join-Path $root 'convars.inc')
$runtime = Get-Content -Raw -LiteralPath (Join-Path $root 'runtime.inc')
$rescue = Get-Content -Raw -LiteralPath (Join-Path $root 'rescue.inc')
$events = Get-Content -Raw -LiteralPath (Join-Path $root 'events.inc')
$lifecycle = Get-Content -Raw -LiteralPath (Join-Path $root 'lifecycle.inc')
$registry = Get-Content -Raw -LiteralPath (Join-Path $root 'entity_registry.inc')
$botThink = Get-Content -Raw -LiteralPath (Join-Path $root 'bot_think.inc')
$versus = Get-Content -Raw -LiteralPath (Join-Path $repo 'cfg/cfgogl/versus_isfullshit/versus.cfg')

function Require-Text([string] $Text, [string] $Needle, [string] $Message) {
    if (-not $Text.Contains($Needle)) { throw $Message }
}

function Require-Pattern([string] $Text, [string] $Pattern, [string] $Message) {
    if ($Text -notmatch $Pattern) { throw $Message }
}

foreach ($required in @(
    'int g_iPinnedRescueAttacker[MAXPLAYERS+1];',
    'L4D2ZombieClassType g_iPinnedRescueClass[MAXPLAYERS+1];',
    'bool g_bPinnedRescueActive[MAXPLAYERS+1];',
    'int g_iSurvivorBot_RescueVictim[MAXPLAYERS+1];',
    'int g_iSurvivorBot_RescueAttacker[MAXPLAYERS+1];',
    'float g_fSurvivorBot_NextPinnedRescueThinkTime[MAXPLAYERS+1];'
)) {
    Require-Text $state $required "missing rescue coordinator state: $required"
}

Require-Text $state 'float g_fClientGlobalInfo_Expiry[MAXPLAYERS+1];' 'global snapshot expiry state is missing'
Require-Text $runtime 'void UpdateClientGlobalInfo(int iClient, const float fAngles[3])' 'global snapshots must have one centralized updater'
Require-Text $runtime 'if (fNow < g_fClientGlobalInfo_Expiry[iClient])' 'global snapshots must short-circuit until ib_process_time expiry'
Require-Text $runtime 'g_fClientGlobalInfo_Expiry[iClient] = GetProcessCacheExpiry();' 'global snapshots must use the ib_process_time expiry helper'
Require-Text $runtime 'g_bClientGlobalInfo_Ready[iClient] = true;' 'global snapshots must publish readiness after refresh'
Require-Text $runtime 'RecoverPinnedRescueCoordinator();' 'late-load rescue recovery must run after snapshot readiness'
$otherModules = Get-ChildItem -LiteralPath $root -Filter '*.inc' | Where-Object { $_.Name -ne 'runtime.inc' }
foreach ($module in $otherModules) {
    $moduleText = Get-Content -Raw -LiteralPath $module.FullName
    if ($moduleText -match 'GetClientEyePosition[^\r\n]*g_fClientEyePos|GetClientAbsOrigin[^\r\n]*g_fClientAbsOrigin|GetEntityCenteroid[^\r\n]*g_fClientCenteroid|g_fClientEyeAng\s*\[[^\]]+\]\s*=') {
        throw "global snapshot refresh is duplicated outside runtime.inc: $($module.Name)"
    }
}

Require-Pattern $convars 'CreateConVar\("ib_help_pinned_reaction_interval",\s*"0\.15"' 'the per-Bot rescue interval cvar must default to 0.15 seconds'
Require-Pattern $convars 'CreateConVar\("ib_help_pinned_max_distance",\s*"5000"' 'the pinned rescue max-distance cvar must default to 5000 units'
Require-Text $convars 'g_hCvar_HelpPinnedFriend_ReactionInterval.AddChangeHook(OnConVarChanged);' 'the rescue interval cvar must be hooked'
Require-Text $convars 'g_hCvar_HelpPinnedFriend_MaxDistance.AddChangeHook(OnConVarChanged);' 'the rescue max-distance cvar must be hooked'
Require-Pattern $convars 'g_fCvar_HelpPinnedFriend_ReactionInterval\s*=\s*g_hCvar_HelpPinnedFriend_ReactionInterval\.FloatValue;' 'the rescue interval cache assignment is missing'
Require-Pattern $convars 'g_fCvar_HelpPinnedFriend_MaxDistance_Sqr\s*=\s*\(g_hCvar_HelpPinnedFriend_MaxDistance\.FloatValue\s*\*\s*g_hCvar_HelpPinnedFriend_MaxDistance\.FloatValue\);' 'the rescue max-distance squared cache assignment is missing'
Require-Pattern $convars 'if\s*\(convar == g_hCvar_HelpPinnedFriend_ReactionBots\)\s*\{?\s*RebuildPinnedRescueCoordinator\(\);' 'reaction-bot cvar changes must rebuild coordinator assignments'
Require-Text $convars 'g_fClientGlobalInfo_Expiry[i] = 0.0;' 'ib_process_time changes must invalidate global snapshots'
Require-Text $rescue 'void RecoverPinnedRescueCoordinator()' 'late-load rescue state recovery is missing'
Require-Text $convars 'g_bPinnedRescueRecoveryPending = g_bLateLoad;' 'configuration load must defer rescue recovery until snapshots are ready'

foreach ($required in @(
    'void StartPinnedRescueCoordinator(int iVictim, int iAttacker)',
    'void InvalidatePinnedRescueCoordinator(int iVictim, int iAttacker = 0)',
    'void InvalidatePinnedRescueClient(int iClient)',
    'void RebuildPinnedRescueCoordinator()',
    'bool GetPinnedRescueAimPosition(int iAttacker, L4D2ZombieClassType iZombieClass, float fAimPos[3])',
    'g_iSurvivorBot_RescueVictim[i]',
    'g_iPinnedRescueAttacker[iPinnedFriend]'
)) {
    Require-Text $rescue $required "missing rescue coordinator/aim contract: $required"
}

Require-Text $rescue 'm_tipPosition' 'Smoker rescue aim must use the tongue tip when available'
Require-Text ($rescue + $botThink) 'IsVisibleVector(iClient, fAimPos)' 'specialized rescue aim must use one direct visibility check'
Require-Text $rescue 'g_fSurvivorBot_NextPinnedRescueThinkTime[iClient]' 'rescue coordinator must own the per-Bot cooldown gate'
Require-Text $state 'ConVar g_hCvar_HelpPinnedFriend_MaxDistance;' 'rescue max-distance cvar state is missing'
Require-Text $state 'float g_fCvar_HelpPinnedFriend_MaxDistance_Sqr;' 'rescue max-distance squared cache state is missing'
Require-Text $rescue 'bool IsPinnedFriendWithinMaxDistance(int iClient, int iPinnedFriend)' 'cached rescue distance helper is missing'
Require-Pattern $rescue 'GetVectorDistance\(g_fClientAbsOrigin\[iClient\],\s*g_fClientAbsOrigin\[iPinnedFriend\],\s*true\)' 'rescue distance helper must use centralized client origin snapshots'
Require-Pattern $rescue 'g_fCvar_HelpPinnedFriend_MaxDistance_Sqr\s*<=\s*0\.0\s*\)\s*return true;' 'zero max distance must disable only the distance limit'
Require-Text $rescue 'IsPinnedFriendWithinMaxDistance(iClient, iPinnedFriend)' 'pinned rescue gate must apply the max-distance helper'
Require-Text $rescue 'IsPinnedFriendMoveBlocked(int iPinnedFriend)' 'move cancellation must use coordinator state'
Require-Text $rescue 'return (!g_bPinnedRescueRecoveryPending && IsValidClient(iPinnedFriend)' 'movement cancellation must not use stale rescue state during recovery'
if ($rescue.Contains('GetEntityCenteroid(iAttacker')) {
    throw 'specialized rescue aim must use the process-window centroid without a per-evaluation entity refresh'
}

foreach ($required in @(
    'HookEvent\("pounce_end",\s*Event_OnSurvivorReleased\)',
    'HookEvent\("tongue_release",\s*Event_OnSurvivorReleased\)',
    'HookEvent\("jockey_ride_end",\s*Event_OnSurvivorReleased\)',
    'HookEvent\("charger_carry_end",\s*Event_OnSurvivorReleased\)',
    'HookEvent\("charger_pummel_end",\s*Event_OnSurvivorReleased\)',
    'HookEvent\("charger_pummel_start",\s*Event_OnSurvivorGrabbed\)',
    'HookEvent\("player_spawn",\s*Event_OnPlayerSpawn\)',
    'HookEvent\("player_team",\s*Event_OnPlayerTeam\)',
    'HookEvent\("player_bot_replace",\s*Event_OnPlayerReplacement\)',
    'HookEvent\("bot_player_replace",\s*Event_OnPlayerReplacement\)'
)) {
    Require-Pattern $lifecycle $required "missing release event hook: $required"
}

Require-Text $events 'StartPinnedRescueCoordinator(iVictim, iAttacker);' 'grab events must start the rescue coordinator'
Require-Text $events 'void Event_OnSurvivorReleased(Event hEvent' 'release events must invalidate the rescue coordinator'
Require-Text $events 'InvalidatePinnedRescueCoordinator(iVictim, iAttacker);' 'release events must pass victim and attacker to invalidation'
Require-Text $events 'InvalidatePinnedRescueCoordinator(0, iAttacker);' 'death events must invalidate attacker relationships without rebuilding candidate ranks'
Require-Text $events 'InvalidatePinnedRescueClient(iVictim);' 'death/revive events must invalidate client rescue state'
Require-Text $events 'void Event_OnPlayerSpawn(Event hEvent' 'spawn events must invalidate rescue state'
Require-Text $events 'void Event_OnPlayerTeam(Event hEvent' 'team events must invalidate rescue state'
Require-Text $events 'void Event_OnPlayerReplacement(Event hEvent' 'replacement events must invalidate rescue state'
Require-Text $events 'RequestPinnedRescueCoordinatorRecovery();' 'lifecycle events must request rescue coordinator recovery'
Require-Text $rescue 'void RequestPinnedRescueCoordinatorRecovery()' 'lifecycle recovery request owner is missing'
Require-Text $registry 'ResetPinnedReactionCaches();' 'map lifecycle must reset rescue coordinator state'
Require-Text $registry 'g_fClientGlobalInfo_Expiry[i] = 0.0;' 'map lifecycle must invalidate global snapshot expiry'
Require-Text $registry 'g_bClientGlobalInfo_Ready[i] = false;' 'map lifecycle must clear global snapshot readiness'
Require-Pattern $events 'void OnClientJoinServer\(int iClient\)\s*\{\s*InvalidatePinnedRescueClient\(iClient\);' 'client join must invalidate rescue state'
Require-Pattern $events 'public void OnClientDisconnect\(int iClient\)\s*\{\s*InvalidatePinnedRescueClient\(iClient\);' 'client disconnect must invalidate rescue state'
Require-Pattern $rescue 'if \(g_iSurvivorBot_RescueVictim\[iClient\] != 0 \|\| g_iSurvivorBot_RescueAttacker\[iClient\] != 0\)' 'client invalidation must clear the assignment owned by the client slot'

Require-Text $botThink 'TryBeginPinnedRescueThink(iClient, fPinnedRescueNow)' 'bot think must check the per-Bot rescue interval'
Require-Pattern $botThink 'IsPinnedFriendReactionAllowed\(iClient,\s*iPinnedFriend\)' 'bot think must retain the pinned reaction gate'
Require-Text $botThink 'g_iSurvivorBot_RescueAttacker[iClient]' 'bot think must read the event-assigned attacker'
Require-Text $botThink 'GetPinnedRescueAimPosition' 'bot think must route Jockey/Smoker rescue aim through the specialized helper'

$rescueStart = $botThink.IndexOf('// PINNED FRIEND RESCUE')
$rescueEnd = $botThink.IndexOf('// END PINNED FRIEND RESCUE')
if ($rescueStart -lt 0 -or $rescueEnd -le $rescueStart) {
    throw 'bot think rescue block markers are missing'
}
$rescueBlock = $botThink.Substring($rescueStart, $rescueEnd - $rescueStart)
if ($rescueBlock.Contains('L4D_GetPinnedInfected(iPinnedFriend)')) {
    throw 'per-usercmd rescue path must not rediscover the pinned attacker'
}
if ($botThink.Contains('L4D_GetPinnedInfected(iPinnedFriend)')) {
    throw 'per-usercmd Bot Think must not rediscover the pinned attacker'
}
$specialAim = [regex]::Match($rescueBlock, 'if\s*\(iZombieClass == L4D2ZombieClass_Jockey\s*\|\|\s*iZombieClass == L4D2ZombieClass_Smoker\s*\)\s*\{(?<body>.*?)\}\s*else', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $specialAim.Success) {
    throw 'Jockey/Smoker specialized aim branch is missing'
}
if ($specialAim.Groups['body'].Value.Contains('GetTargetAimPart(iClient, iAttacker')) {
    throw 'Jockey/Smoker rescue path must not use the generic attacker bone aim'
}

Require-Pattern $versus '(?m)^confogl_addcvar ib_help_pinned_reaction_interval 0\.15\s*$' 'versus profile must configure the rescue interval'
Require-Pattern $versus '(?m)^confogl_addcvar ib_help_pinned_max_distance 1500\s*$' 'versus profile must configure the rescue max distance'

'l4d2_sb_ai rescue optimization contract passed'
