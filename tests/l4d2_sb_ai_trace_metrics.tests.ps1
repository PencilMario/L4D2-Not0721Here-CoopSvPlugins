$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$main = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver.sp')
$perception = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'perception.inc')
$navigation = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'navigation.inc')
$navigationCache = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'navigation_cache.inc')
$navigation += $navigationCache
$runtime = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'runtime.inc')
$convars = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'convars.inc')
$debug = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'debug.inc')
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
    'TRACE_METRIC_VECTOR_LOS' = 1
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

if ([regex]::Matches($all, 'TR_TraceRayFilterEx\(').Count -ne 9) {
    throw 'trace metrics contract expects vector LOS wrappers to share one of the 9 explicit trace call sites'
}

if (-not $all.Contains('if (!g_bPerformanceBudgetEnabled)')) {
    throw 'trace metric counters must be guarded when performance logging is disabled'
}

if ($all -notmatch '(?s)TraceMetricsMaybeLogSummary\(.*?GetProcessCacheExpiry\(\)') {
    throw 'trace metrics must summarize on the ib_process_time cadence'
}

if ($perception -notmatch '(?s)if \(g_bPerformanceBudgetEnabled\)\s*\{\s*TraceMetricsRecordAttempt\(TRACE_METRIC_ENTITY_LOS\)') {
    throw 'entity trace metric calls must be guarded when performance logging is disabled'
}
if ($perception -notmatch '(?s)bool Base_TraceFilter\([^)]*\)\s*\{\s*if \(g_bPerformanceBudgetEnabled\)\s*TraceMetricsRecordFilterCallback\(\);') {
    throw 'Base_TraceFilter callback metric must be behind the performance gate'
}
foreach ($sourceFile in @('perception.inc', 'navigation.inc', 'navigation_cache.inc', 'bot_think.inc')) {
    $source = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot $sourceFile)
    foreach ($trace in [regex]::Matches($source, 'TR_TraceRayFilterEx\(')) {
        $afterTrace = $source.Substring($trace.Index, [Math]::Min(500, $source.Length - $trace.Index))
        if ($afterTrace -notmatch '(?s)TR_TraceRayFilterEx\([^;]+;\s*if \(g_bPerformanceBudgetEnabled\)\s*TraceMetricsEndTrace\(\);') {
            throw "$sourceFile has a trace whose TraceMetricsEndTrace call is not gated"
        }
    }
}

if ($navigation -notmatch '(?s)bool LBI_IsNavAreaPartiallyVisible\([^)]*\).*?TraceMetricsRecordAttempt\(TRACE_METRIC_NAV_VISIBLE\).*?for \(int i = 0; i < NAV_VISIBLE_CACHE_SIZE; i\+\+\).*?TraceMetricsRecordCacheHit\(TRACE_METRIC_NAV_VISIBLE\).*?return g_bNavigationVisibleCache_Result\[i\].*?TraceMetricsRecordCacheMiss\(TRACE_METRIC_NAV_VISIBLE\).*?LBI_IsNavAreaPartiallyVisibleImpl') {
    throw 'nav visibility metrics must count attempts, cache hits, and cache misses at the cache owner'
}
if ($navigation -match '(?s)bool LBI_IsNavAreaPartiallyVisibleImpl\([^)]*\).*?TraceMetricsRecord(?:Attempt|CacheMiss)\(TRACE_METRIC_NAV_VISIBLE\)') {
    throw 'nav visibility implementation must only classify actual trace calls'
}

if ($runtime -notmatch '(?s)bool bIsSurvivor = IsClientSurvivor\(iClient\);.*?PerformanceBudgetEndStage\(iClient\);\s*if \(g_bPerformanceBudgetEnabled\)\s*TraceMetricsMaybeLogSummary\(\);\s*if \(!bIsSurvivor\)') {
    throw 'trace summary must run after snapshot work before every valid RunCmd early return'
}
if ([regex]::Matches($runtime, 'TraceMetricsMaybeLogSummary\(\)').Count -ne 1) {
    throw 'OnPlayerRunCmd must have exactly one trace summary call'
}

if ($convars -notmatch 'g_hCvar_PerformanceLogging\.AddChangeHook\(OnPerformanceLoggingChanged\)') {
    throw 'performance logging changes must use the dedicated metric-reset hook'
}
if ($debug -notmatch '(?s)void OnPerformanceLoggingChanged\([^)]*\).*?UpdateConVarValues\(\);\s*ResetPerformanceBudgetCounters\(\);') {
    throw 'performance logging changes must reset trace metrics'
}

'l4d2_sb_ai trace metrics contract passed'
