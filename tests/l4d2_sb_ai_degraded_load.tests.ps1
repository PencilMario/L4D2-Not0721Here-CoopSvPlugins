$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$root = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$state = Get-Content -Raw -LiteralPath (Join-Path $root 'state.inc')
$convars = Get-Content -Raw -LiteralPath (Join-Path $root 'convars.inc')
$runtime = Get-Content -Raw -LiteralPath (Join-Path $root 'runtime.inc')
$perception = Get-Content -Raw -LiteralPath (Join-Path $root 'perception.inc')
$aiming = Get-Content -Raw -LiteralPath (Join-Path $root 'aiming.inc')
$utilities = Get-Content -Raw -LiteralPath (Join-Path $root 'utilities.inc')
$navigationCache = Get-Content -Raw -LiteralPath (Join-Path $root 'navigation_cache.inc')
$botThink = Get-Content -Raw -LiteralPath (Join-Path $root 'bot_think.inc')
$degraded = Get-Content -Raw -LiteralPath (Join-Path $root 'degraded.inc')

foreach ($token in @(
    'g_hCvar_DegradedForce',
    'g_hCvar_DegradedFrameStepMs',
    'g_iDegradedLoadLevel',
    'g_fDegradedFrameAverageMs',
    'UpdateDegradedLoadLevel',
    'bool IsAiDegraded(int iLevel = 1)',
    'GetGameFrameTime() * 1000.0',
    'GetTickInterval() * 1000.0',
    'g_hCvar_DegradedForce.AddChangeHook(OnConVarChanged)',
    'g_hCvar_DegradedFrameStepMs.AddChangeHook(OnConVarChanged)',
    'ResetDegradedLoadState()',
    'GetAiEntityCenteroidCached'
)) {
    if (-not ($state + $convars + $runtime + $perception + $aiming + $utilities + $degraded).Contains($token)) {
        throw "missing degraded-load contract token: $token"
    }
}

if ($runtime -notmatch '(?s)float fFrameMs = GetGameFrameTime\(\) \* 1000\.0;.*?g_fDegradedFrameAverageMs.*?g_fCvar_DegradedFrameStepMs') {
    throw 'automatic degradation must use an average frame duration and configurable step'
}

if ($runtime -notmatch '(?s)void ApplyDegradedLoadLevel.*?ResetVisibilityCaches\(\).*?ResetNavigationCaches\(\).*?ResetAiEntityCenteroidCache\(\)') {
    throw 'degraded level transitions must invalidate mode-sensitive caches'
}

if ($degraded -notmatch '(?s)void ResetProcessCaches.*?ResetAiEntityCenteroidCache\(\).*?ResetVisibilityCaches\(\).*?ResetNavigationCaches\(\).*?ResetVectorTraceCache\(\).*?g_fClientGlobalInfo_Expiry') {
    throw 'ib_process_time changes must invalidate every process-window cache'
}

if ($perception -notmatch '(?s)bool TraceVisibleEntity.*?if (bDidHit || IsAiDegraded())') {
    throw 'degraded entity visibility must stop after the first LOS trace'
}

if ($perception -notmatch '(?s)GetInfectedCounts.*?\(!IsValidClient\(iClient\) \|\| !IsAiDegraded\(\)\).*?GetVectorVisible\(fClientPos, fInfectedPos\)') {
    throw 'infected-count degraded branch must guard the second LOS before calling it'
}

if ($aiming -notmatch '(?s)GetClosestToEyePosEntityBonePos.*?if \(IsAiDegraded\(\)\).*?return;') {
    throw 'degraded melee aiming must bypass the bone sweep'
}

if ($aiming -notmatch '(?s)GetTargetAimPart.*?if \(IsAiDegraded\(2\)\).*?return;') {
    throw 'higher degraded aiming level must bypass all target bone resolution'
}

if ($navigationCache -notmatch '(?s)float fFraction = TR_GetFraction\(hResult\); delete hResult;.*?if \(IsAiDegraded\(\)\)return false;') {
    throw 'degraded nav visibility must use the center trace only'
}

if ($botThink -notmatch 'iTankPropVisibilityChecks = 0' -or $botThink -notmatch 'IsAiDegraded\(2\).*?iTankPropVisibilityChecks' -or $botThink -notmatch 'IsAiDegraded\(3\) \? 1 : 2') {
    throw 'degraded tank-rock selection must cap visibility candidates'
}

'l4d2_sb_ai degraded-load contract passed'
