$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$runtime = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/runtime.inc')
$state = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc')

if ($runtime -notmatch 'iClient < 1 \|\| iClient > MaxClients \|\| !IsClientInGame\(iClient\)') {
    throw 'RunCmd must reject invalid clients before starting snapshot work'
}

if ($runtime -notmatch 'float fNow = GetGameTime\(\);') {
    throw 'RunCmd must capture game time once for its fixed-work guard'
}

if ($runtime -notmatch 'UpdateClientGlobalInfoAt\(iClient, fAngles, fNow\)' -or $runtime -notmatch 'UpdateClientNavArea\(iClient, fNow\)') {
    throw 'RunCmd must pass the captured time into snapshot updates'
}

if ($runtime -notmatch 'void UpdateClientInventory\(int iClient, float fNow\)') {
    throw 'inventory snapshot must have a centralized updater'
}

if ($runtime -notmatch 'if \(fNow < g_fClientInventory_Expiry\[iClient\]\)') {
    throw 'inventory snapshot must short-circuit until its expiry'
}

if ($runtime -notmatch 'UpdateClientInventory\(iClient, fNow\)') {
    throw 'RunCmd must use the inventory snapshot updater'
}

if ($state -notmatch 'float g_fClientInventory_Expiry\[MAXPLAYERS\+1\];') {
    throw 'inventory snapshot expiry state is missing'
}

$events = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/events.inc')
$combat = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/combat.inc')
if ($events -notmatch 'g_fClientInventory_Expiry\[iClient\] = 0\.0;') {
    throw 'weapon-fire changes must invalidate the inventory snapshot'
}
if ($combat -notmatch 'g_fClientInventory_Expiry\[iClient\] = 0\.0;') {
    throw 'weapon-switch changes must invalidate the inventory snapshot'
}

if ($runtime -notmatch '(?s)bool bIsSurvivor = IsClientSurvivor\(iClient\);.*?PerformanceBudgetEndStage\(iClient\);.*?TraceMetricsMaybeLogSummary\(\);.*?if \(!bIsSurvivor\)\s*return Plugin_Continue;') {
    throw 'non-survivor RunCmd path must close the performance stage and emit the shared summary before returning'
}

if ($runtime -notmatch 'if \(g_bCvar_BotsDisabled \|\| g_bCutsceneIsPlaying \|\| !g_iClientNavArea\[iClient\] \|\| fNow <= g_fClient_ThinkFunctionDelay\[iClient\] \|\| !IsFakeClient\(iClient\)\)') {
    throw 'RunCmd bot guard is missing'
}

if ($runtime -notmatch 'g_iPerformanceBudget_EnteredBotThink\+\+') {
    throw 'RunCmd must count entries into bot think'
}

if ($state -notmatch 'g_bPerformanceBudgetEnabled' -or $state -notmatch 'g_iPerformanceBudget_StageDepth') {
    throw 'runtime budget state is missing'
}

'l4d2_sb_ai runtime budget contract passed'
