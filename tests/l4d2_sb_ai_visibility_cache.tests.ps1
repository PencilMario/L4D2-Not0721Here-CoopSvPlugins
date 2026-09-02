$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$state = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc')
$perception = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc')
$registry = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/entity_registry.inc')
$events = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/events.inc')

foreach ($token in @(
    'g_fSurvivorBot_VisibilityCache_Expiry',
    'g_iSurvivorBot_VisibilityCache_EntRef',
    'g_iSurvivorBot_VisibilityCache_Mask',
    'g_iSurvivorBot_VisibilityCache_Mode',
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

if ($state -notmatch '#define VISIBILITY_CACHE_SIZE 64') {
    throw 'entity visibility cache must provide 64 slots per observer'
}
if ($state -notmatch '#define VISIBILITY_CACHE_WAYS 4') {
    throw 'entity visibility cache must use four-way associativity'
}
if ($state -notmatch '#define VISIBILITY_CACHE_SET_COUNT 16') {
    throw 'entity visibility cache must expose sixteen sets'
}
if ($perception -notmatch 'GetVisibilityCacheSet\(') {
    throw 'entity visibility lookup must select a deterministic hash set'
}
if ($perception -notmatch 'VISIBILITY_CACHE_WAYS') {
    throw 'entity visibility lookup must be bounded by cache associativity'
}
if ($perception -notmatch 'EntIndexToEntRef\(iTarget\)') {
    throw 'entity visibility cache must store entrefs to guard index reuse'
}
if ($perception -notmatch 'g_iSurvivorBot_VisibilityCache_EntRef') {
    throw 'entity visibility cache must validate stored target entrefs'
}
if ($perception -notmatch 'g_iSurvivorBot_VisibilityCache_Mode') {
    throw 'entity visibility cache key must include LOS mode'
}
if ($state -notmatch 'g_iSurvivorBot_VisibilityCache_ObserverGeneration') {
    throw 'entity visibility cache must retain the observer lifecycle generation'
}
if ($state -notmatch 'g_iSurvivorBot_VisibilityCache_EntRef') {
    throw 'entity visibility cache state must retain target entrefs rather than target indices'
}
if ($perception -notmatch 'iSet \* VISIBILITY_CACHE_WAYS') {
    throw 'each hashed set must scan only its four contiguous ways'
}
if ($perception -notmatch 'iTargetEntRef \^ \(iMask \* 31\) \^ \(iMode \* 17\)') {
    throw 'hashing must distinguish target, mask, and LOS mode before selecting a set'
}
if (([regex]::Matches($perception, 'for \(int iWay = 0; iWay < VISIBILITY_CACHE_WAYS; iWay\+\+\)')).Count -lt 1) {
    throw 'visibility lookup and replacement must be bounded to four ways'
}
if ($perception -notmatch 'iWay == 0 \|\| g_fSurvivorBot_VisibilityCache_Expiry\[iClient\]\[i\] < fOldestExpiry') {
    throw 'a full set must replace its earliest expiry rather than always the first way'
}
if ($perception -notmatch '(?s)bool bFoundExpiredSlot = false;.*?if \(fNow >= g_fSurvivorBot_VisibilityCache_Expiry\[iClient\]\[i\] && !bFoundExpiredSlot\).*?else if \(!bFoundExpiredSlot && \(iWay == 0 \|\| g_fSurvivorBot_VisibilityCache_Expiry\[iClient\]\[i\] < fOldestExpiry\)\)') {
    throw 'expired slots must take priority while active slots still select the earliest expiry'
}
if ($perception -match 'iReplacementSlot = i;\s*break;') {
    throw 'an expired way may be a replacement candidate but must not stop later-way hit checks'
}
if ($perception -notmatch 'iReplacementSlot = i;\s*\n\s*bFoundExpiredSlot = true;') {
    throw 'the first expired way must remain the replacement candidate while the set scan continues'
}
if ($perception -match 'VisibilityCache_NextSlot') {
    throw 'visibility cache must retire the global round-robin replacement cursor'
}
if ($perception -notmatch 'g_iSurvivorBot_VisibilityCache_EntRef\[iClient\]\[iSlot\] = iTargetEntRef') {
    throw 'cache fills must record the target entref for index-reuse safety'
}
if ($perception -notmatch 'g_iSurvivorBot_VisibilityCache_Mask\[iClient\]\[i\] == iMask') {
    throw 'different trace masks must not share an entity LOS cache result'
}
if ($state -notmatch '#define VISIBILITY_CACHE_SIZE 64' -or $state -notmatch '#define VISIBILITY_CACHE_WAYS 4') {
    throw 'thirty-two distinct targets require at least eight four-way sets without evicting the first target'
}
if ($perception -notmatch 'g_iSurvivorBot_VisibilityCache_ObserverGeneration\[iClient\]\[i\] == g_iSurvivorBot_VisibilityObserverGeneration\[iClient\]') {
    throw 'a reused observer client slot must not match a prior lifecycle entry'
}
if ($registry -notmatch 'void InvalidateVisibilityCacheClient\(int iClient\)') {
    throw 'visibility cache must have a client lifecycle invalidation helper'
}
if (([regex]::Matches($events, 'InvalidateVisibilityCacheClient\(iClient\);')).Count -lt 3) {
    throw 'client reset, spawn, and team lifecycle paths must invalidate observer cache entries'
}
if ($events -notmatch 'InvalidateVisibilityCacheClient\(iPlayer\);[\s\S]*InvalidateVisibilityCacheClient\(iBot\);') {
    throw 'player and bot replacement must invalidate both observer cache rows'
}
if ($registry -notmatch 'VISIBILITY_CACHE_SIZE') {
    throw 'visibility lifecycle invalidation must cover the expanded cache'
}
if ($registry -notmatch 'iCachedEntity == INVALID_ENT_REFERENCE') {
    throw 'entity lifecycle invalidation must retire stale entrefs after index reuse'
}

'l4d2_sb_ai visibility cache contract passed'
