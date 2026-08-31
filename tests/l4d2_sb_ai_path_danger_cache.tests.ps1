$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$navigationPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc'
$navigation = Get-Content -Raw -LiteralPath $navigationPath

$required = @(
    'g_fNavigationDangerCache_Expiry',
    'g_fNavigationDangerCache_GoalPos',
    'g_iNavigationDangerCache_StartArea',
    'LBI_IsPathToPositionDangerousImpl'
)
foreach ($token in $required) {
    if (-not $navigation.Contains($token)) { throw "missing path danger cache contract token: $token" }
}

'l4d2_sb_ai path danger cache contract passed'
