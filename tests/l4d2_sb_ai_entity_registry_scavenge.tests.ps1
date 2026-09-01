$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$root = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$state = Get-Content -Raw -LiteralPath (Join-Path $root 'state.inc')
$registry = Get-Content -Raw -LiteralPath (Join-Path $root 'entity_registry.inc')
$scavenge = Get-Content -Raw -LiteralPath (Join-Path $root 'scavenging.inc')
$events = Get-Content -Raw -LiteralPath (Join-Path $root 'events.inc')

foreach ($token in @(
    'g_iEntityListMask',
    'ENTITY_LIST_',
    'RemoveEntityFromRegisteredLists',
    'RegisterEntityListMask',
    'ENTITY_LIST_BAD_PATH',
    'ENTITY_LIST_WEAPONS_LATER',
    'ResetEntityListMasks'
)) {
    if (-not ($state + $registry).Contains($token)) { throw "missing entity registry mask contract token: $token" }
}
foreach ($token in @('UnregisterEntityListMask', 'ENTITY_LIST_BAD_PATH', 'ENTITY_LIST_WEAPONS_LATER')) {
    if (-not $registry.Contains($token)) { throw "missing mask cleanup contract token: $token" }
}
if (-not $registry.Contains('g_hBadPathEntities.Clear()')) { throw 'bad-path clear contract is missing' }
if (-not $scavenge.Contains('UnregisterEntityListMaskFromEntRef')) { throw 'stale EntRef mask cleanup is missing' }

if ($registry -match '(?ms)else\s*\{\s*UnregisterEntityListMask\(iEntIndex, ENTITY_LIST_WEAPONS_LATER\);') {
    throw 'invalid delayed-weapon refs must not clear masks through an invalid entity index'
}
if (-not $registry.Contains('UnregisterEntityListMaskFromEntRef(g_hWeaponsToCheckLater.Get(i), ENTITY_LIST_WEAPONS_LATER)')) {
    throw 'delayed-weapon stale EntRefs must clear through the EntRef-aware helper'
}

$reviveInvalid = $events.IndexOf('if (iEntIndex == INVALID_ENT_REFERENCE || !IsEntityExists(iEntIndex) || iClient == iOwner)')
if ($reviveInvalid -lt 0) { throw 'revive forbidden-item cleanup branch is missing' }
$reviveCleanup = $events.IndexOf('UnregisterEntityListMaskFromEntRef', $reviveInvalid)
if ($reviveCleanup -lt 0 -or $reviveCleanup -gt $events.IndexOf('g_hForbiddenItemList.Erase(i)', $reviveInvalid)) {
    throw 'revive cleanup must use the original EntRef before erasing stale entries'
}

$incap = $events.IndexOf('void Event_OnIncap')
$revive = $events.IndexOf('void Event_OnRevive', $incap)
$incapBody = $events.Substring($incap, $revive - $incap)
$incapPush = $incapBody.IndexOf('g_hForbiddenItemList.Push(iEntRef)')
$incapFind = $incapBody.IndexOf('g_hForbiddenItemList.FindValue(iEntRef)')
if ($incapPush -ge 0 -and ($incapFind -lt 0 -or $incapFind -gt $incapPush)) {
    throw 'incapacitated secondary weapons must not be pushed without duplicate protection'
}
if ($incapFind -lt 0) {
    throw 'incapacitated secondary registration must use duplicate-safe list registration'
}

$impl = $scavenge.IndexOf('int GetItemFromArrayListImpl')
$invalid = $scavenge.IndexOf('if (iEntIndex == INVALID_ENT_REFERENCE || !IsEntityExists(iEntIndex))', $impl)
$forbidden = $scavenge.IndexOf('g_iEntityListMask[iEntIndex] & ENTITY_LIST_FORBIDDEN', $impl)
if ($invalid -lt 0 -or $forbidden -lt 0 -or $invalid -gt $forbidden) { throw 'invalid EntRef must be removed before forbidden membership check' }

if (-not $registry.Contains('g_iEntityListMask[iEntity] = 0')) { throw 'entity lifecycle must clear registration masks' }
if ($scavenge.Contains('g_hForbiddenItemList.FindValue(iEntRef)')) { throw 'forbidden membership must use the entity mask instead of a linear lookup' }

$navigation = Get-Content -Raw -LiteralPath (Join-Path $root 'navigation.inc')
if ($navigation.Contains('g_hBadPathEntities.FindValue(EntIndexToEntRef(iEntity))')) { throw 'bad-path membership must use the entity mask instead of a linear lookup' }

$weaponFilter = $scavenge.IndexOf('if (iWeaponID < 0')
$distanceFilter = $scavenge.IndexOf('GetVectorDistance(fClientPos, fEntityPos, true)')
$reachability = $scavenge.IndexOf('LBI_IsReachableEntity(iClient, iEntIndex)')
if ($weaponFilter -lt 0 -or $distanceFilter -lt 0 -or $reachability -lt 0 -or $distanceFilter -gt $reachability) {
    throw 'item scan must apply cheap weapon/distance filters before reachability checks'
}

'l4d2_sb_ai entity registry and scavenge contract passed'
