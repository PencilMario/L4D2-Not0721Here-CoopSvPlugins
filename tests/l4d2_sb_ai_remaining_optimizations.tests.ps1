$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$root = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$state = Get-Content -Raw -LiteralPath (Join-Path $root 'state.inc')
$debug = Get-Content -Raw -LiteralPath (Join-Path $root 'debug.inc')
$navigation = Get-Content -Raw -LiteralPath (Join-Path $root 'navigation.inc')
$runtime = Get-Content -Raw -LiteralPath (Join-Path $root 'runtime.inc')
$movement = Get-Content -Raw -LiteralPath (Join-Path $root 'movement.inc')
$combat = Get-Content -Raw -LiteralPath (Join-Path $root 'combat.inc')
$perception = Get-Content -Raw -LiteralPath (Join-Path $root 'perception.inc')
$aiming = Get-Content -Raw -LiteralPath (Join-Path $root 'aiming.inc')
$botThink = Get-Content -Raw -LiteralPath (Join-Path $root 'bot_think.inc')
$inventory = Get-Content -Raw -LiteralPath (Join-Path $root 'inventory.inc')

function Require-Text([string] $Text, [string] $Needle, [string] $Message) {
    if (-not $Text.Contains($Needle)) { throw $Message }
}

Require-Text $state 'float GetProcessCacheExpiry()' 'the shared ib_process_time cache-expiry helper is missing'
Require-Text $state 'return (GetGameTime() + g_fCvar_NextProcessTime);' 'the shared cache-expiry helper must use ib_process_time'
Require-Text $debug 'void LogDebugMessage(const char[] sMessage, any ...)' 'the debug-to-console-and-file helper is missing'
Require-Text $debug 'g_hPerformanceLogger.lograw("[Debug] %s", sBuffer)' 'ib_debug output must be written to the dedicated logger'

foreach ($token in @(
    'LBI_GetNearestNavAreaCached',
    'g_fNavigationAreaLookupCache_Expiry',
    'g_fNavigationDamagePositionCache_Expiry',
    'g_fNavigationReachablePositionCache_Expiry',
    'g_fNavigationVisibleCache_Expiry',
    'g_fNavigationDistanceCache_Expiry',
    'g_fNavigationBuildPathCache_Expiry',
    'LBI_NavAreaBuildPathCached'
)) {
    Require-Text $navigation $token "missing navigation cache contract token: $token"
}

Require-Text $runtime 'g_fClientNavAreaCache_Expiry' 'per-client nav-area cache expiry is missing'
Require-Text $runtime 'UpdateClientNavArea' 'per-client nav-area update helper is missing'
Require-Text $movement 'g_fTakeCoverCache_Expiry' 'take-cover candidate cache is missing'
Require-Text $movement 'TAKE_COVER_PATH_ATTEMPTS' 'take-cover candidate limit is missing'
Require-Text $combat 'g_fSurvivorBot_AcidEscapeCache_Expiry' 'acid-evasion candidate cache is missing'
Require-Text $combat 'ACID_ESCAPE_PATH_ATTEMPTS' 'acid-evasion candidate limit is missing'
Require-Text $perception 'g_iCommonInfectedMeleeTargetMask' 'common-infected melee target snapshot is missing'
Require-Text $perception 'RefreshCommonInfectedMeleeTargetMarks' 'common-infected target snapshot refresh is missing'
Require-Text $aiming 'g_fClientCenteroid[i]' 'friendly-fire distance check must use the loop target'
Require-Text $botThink 'LBI_NavAreaBuildPathCached(' 'item regrouping must use the cached BuildPath owner'
Require-Text $inventory 'GetProcessCacheExpiry()' 'team inventory caches must use the shared expiry helper'
Require-Text (Get-Content -Raw -LiteralPath (Join-Path $root 'rescue.inc')) 'g_fPinnedReactionCache_Expiry' 'pinned reaction ranking cache is missing'
Require-Text (Get-Content -Raw -LiteralPath (Join-Path $root 'rescue.inc')) 'BuildPinnedReactionRanks' 'pinned reaction ranks must be built once per process window'
Require-Text (Get-Content -Raw -LiteralPath (Join-Path $root 'rescue.inc')) 'g_iPinnedReactionRank' 'pinned reaction checks must use cached ranks'

$all = $state + $debug + $navigation + $runtime + $movement + $combat + $perception + $aiming + $botThink + $inventory
if ($all -match 'g_f\w*Cache_Expiry[^\r\n]*GetNavigationCacheCycleKey\(\)|g_f\w*Cache_Expiry[^\r\n]*GetTeamInventoryCacheExpiry\(\)') {
    throw 'cache expiry assignments still bypass the shared ib_process_time helper'
}

'l4d2_sb_ai remaining optimization contract passed'
