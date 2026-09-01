$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$main = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver.sp')
$all = $main
Get-ChildItem -LiteralPath $sourceRoot -Filter '*.inc' | ForEach-Object { $all += Get-Content -Raw -LiteralPath $_.FullName }

foreach ($category in @(
    'TRACE_METRIC_ENTITY_LOS',
    'TRACE_METRIC_VECTOR_LOS',
    'TRACE_METRIC_AIM',
    'TRACE_METRIC_GRENADE_GROUND',
    'TRACE_METRIC_GRENADE_CEILING',
    'TRACE_METRIC_NAV_VISIBLE'
)) {
    if (-not $all.Contains($category)) { throw "missing trace metric category: $category" }
}

foreach ($counter in @(
    'g_iTraceMetrics_Attempts',
    'g_iTraceMetrics_CacheHits',
    'g_iTraceMetrics_CacheMisses',
    'g_iTraceMetrics_TraceCalls',
    'g_iTraceMetrics_Fallback2',
    'g_iTraceMetrics_Fallback3',
    'g_iTraceMetrics_FilterCallbacks'
)) {
    if (-not $all.Contains($counter)) { throw "missing trace metric counter: $counter" }
}

foreach ($helper in @(
    'TraceMetricsRecordAttempt',
    'TraceMetricsRecordCacheHit',
    'TraceMetricsRecordCacheMiss',
    'TraceMetricsRecordTraceCall',
    'TraceMetricsRecordFallback',
    'TraceMetricsMaybeLogSummary'
)) {
    if (-not $all.Contains($helper)) { throw "missing trace metric helper: $helper" }
}

if (-not $all.Contains('GetProcessCacheExpiry()')) {
    throw 'trace metric summary must use the shared ib_process_time expiry helper'
}

if ($all -notmatch '(?s)bool\s+Base_TraceFilter\s*\([^)]*\).*?g_iTraceMetrics_FilterCallbacks') {
    throw 'Base_TraceFilter must record filter callbacks'
}

$expectedTraceCalls = @{
    'TRACE_METRIC_ENTITY_LOS' = 3
    'TRACE_METRIC_VECTOR_LOS' = 2
    'TRACE_METRIC_AIM' = 1
    'TRACE_METRIC_GRENADE_GROUND' = 1
    'TRACE_METRIC_GRENADE_CEILING' = 1
    'TRACE_METRIC_NAV_VISIBLE' = 2
}
foreach ($category in $expectedTraceCalls.Keys) {
    $count = [regex]::Matches($all, "TraceMetricsRecordTraceCall\($category\)").Count
    if ($count -ne $expectedTraceCalls[$category]) {
        throw "expected $($expectedTraceCalls[$category]) classified trace calls for $category, found $count"
    }
}

if ([regex]::Matches($all, 'TR_TraceRayFilterEx\(').Count -ne 10) {
    throw 'trace metrics contract expects the existing 10 trace call sites to remain explicit'
}

if (-not $all.Contains('if (!g_bPerformanceBudgetEnabled)')) {
    throw 'trace metric counters must be guarded when performance logging is disabled'
}

if ($all -notmatch '(?s)TraceMetricsMaybeLogSummary\(.*?GetProcessCacheExpiry\(\)') {
    throw 'trace metrics must summarize on the ib_process_time cadence'
}

'l4d2_sb_ai trace metrics contract passed'
