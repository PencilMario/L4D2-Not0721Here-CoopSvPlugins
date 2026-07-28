$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$root = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$main = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver.sp')
$all = $main
Get-ChildItem -LiteralPath $root -Filter '*.inc' | ForEach-Object { $all += Get-Content -Raw -LiteralPath $_.FullName }

$required = @(
    '#include <logger>',
    'sb_ai_performance',
    'LoggerType_NewLogFile',
    'ib_performance_logging',
    'ib_performance_threshold_ms',
    'LogSlowCalculation',
    'GetEngineTime()',
    'g_fCvar_PerformanceThresholdMs / 1000.0',
    'g_hPerformanceLogger.warning',
    'SurvivorBotThinkImpl',
    'CheckForItemsToScavengeImpl',
    'GetItemFromArrayListImpl',
    'GetClosestInfectedImpl',
    'GetInfectedCountImpl',
    'GetClientTravelDistanceImpl',
    'GetClientDistanceToItemImpl',
    'GetNavDistanceImpl',
    'LBI_IsPathToPositionDangerousImpl'
)
foreach ($token in $required) {
    if (-not $all.Contains($token)) { throw "missing performance logging contract token: $token" }
}

'l4d2_sb_ai performance logging contract passed'
