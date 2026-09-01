$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$main = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver.sp')
$all = $main
Get-ChildItem -LiteralPath $sourceRoot -Filter '*.inc' | ForEach-Object { $all += Get-Content -Raw -LiteralPath $_.FullName }

foreach ($token in @(
    'g_bPerformanceBudgetEnabled',
    'g_iPerformanceBudget_RunCmdCalls',
    'PerformanceBudgetBeginStage',
    'PerformanceBudgetEndStage',
    'snapshot',
    'perception',
    'decision',
    'trace_navigation',
    'scavenge',
    'rescue',
    'entered_bot_think'
)) {
    if (-not $all.Contains($token)) { throw "missing performance budget contract token: $token" }
}

if (-not $all.Contains('g_bPerformanceBudgetEnabled = g_bCvar_PerformanceLogging;')) {
    throw 'performance budget instrumentation must follow the performance logging switch'
}

'l4d2_sb_ai performance budget contract passed'
