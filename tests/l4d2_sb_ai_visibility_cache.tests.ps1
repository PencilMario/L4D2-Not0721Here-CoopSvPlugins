$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$state = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc')
$perception = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc')
$registry = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/entity_registry.inc')

foreach ($token in @(
    'g_fSurvivorBot_VisibilityCache_Expiry',
    'g_iSurvivorBot_VisibilityCache_Target',
    'g_iSurvivorBot_VisibilityCache_Mask',
    'g_bSurvivorBot_VisibilityCache_FOV',
    'g_bSurvivorBot_VisibilityCache_Result',
    'g_fSurvivorBot_VisibilityCache_TargetPos'
)) {
    if (-not $state.Contains($token)) { throw "missing visibility cache state: $token" }
}

if ($perception -notmatch 'bool GetCachedVisibleEntity\(int iClient, int iTarget, int iMask, bool bFOVState') {
    throw 'visibility cache must have a centralized entity query helper'
}
if ($perception -notmatch 'GetCachedVisibleEntity\(iClient, iTarget, iMask') {
    throw 'IsVisibleEntity must use the centralized visibility cache'
}
if ($perception -notmatch 'if \(!IsFakeClient\(iClient\) \|\| GetClientTeam\(iClient\) != 2\)') {
    throw 'visibility cache must be limited to survivor bots'
}
if ($registry -notmatch 'InvalidateVisibilityCacheEntity\(iEntity\);') {
    throw 'entity creation/destruction must invalidate reused visibility cache slots'
}
if ($perception -notmatch 'g_fSurvivorBot_VisibilityCache_Expiry\[iClient\]\[iSlot\] = GetProcessCacheExpiry\(\)') {
    throw 'visibility cache must use the shared process expiry'
}
if ($registry -notmatch 'g_fSurvivorBot_VisibilityCache_Expiry\[i\]\[j\] = 0\.0;') {
    throw 'entity destruction must invalidate visibility cache entries'
}
if ($registry -notmatch 'void ResetVisibilityCaches\(\)') {
    throw 'visibility cache must have a lifecycle reset helper'
}
if ($registry -notmatch 'OnMapEnd\(\)[\s\S]*ResetVisibilityCaches\(\);') {
    throw 'map end must clear visibility cache entries'
}

'l4d2_sb_ai visibility cache contract passed'
