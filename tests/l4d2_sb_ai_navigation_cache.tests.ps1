$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$navigationPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc'
$navigationCachePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation_cache.inc'
$statePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc'
$navigation = (Get-Content -Raw -LiteralPath $navigationPath) + (Get-Content -Raw -LiteralPath $navigationCachePath)
$state = Get-Content -Raw -LiteralPath $statePath
$navigation = $state + $navigation

$required = @(
    'g_fCvar_NextProcessTime',
    'g_iNavigationCacheClient',
    'g_iNavigationCacheGoalEntity',
    'GetNavigationCacheCycleKey',
    'LBI_IsReachableEntityImpl'
)
foreach ($token in $required) {
    if (-not $navigation.Contains($token)) { throw "missing navigation cache contract token: $token" }
}

'l4d2_sb_ai navigation cache contract passed'
