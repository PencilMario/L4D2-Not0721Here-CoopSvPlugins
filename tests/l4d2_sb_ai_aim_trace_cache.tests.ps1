$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$state = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'state.inc')
$runtime = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'runtime.inc')
$perception = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'perception.inc')

foreach ($token in @(
    'g_iClientCommandGeneration',
    'g_iClientAimCacheGeneration',
    'g_bClientAimCacheValid',
    'g_fClientAimCacheEyePos',
    'g_fClientAimCacheAngles',
    'g_fClientAimCachePos'
)) {
    if (-not $state.Contains($token)) { throw "missing aim cache state: $token" }
}

if ($runtime -notmatch '(?s)public Action OnPlayerRunCmd\([^)]*\).*?g_iClientCommandGeneration\[iClient\]\+\+') {
    throw 'each valid RunCmd must advance the client command generation'
}
if ($perception -notmatch '(?s)void GetClientAimPosition\(int iClient, float fAimPos\[3\]\).*?g_iClientAimCacheGeneration\[iClient\] == g_iClientCommandGeneration\[iClient\]') {
    throw 'aim lookup must require the current command generation'
}
if ($perception -notmatch '(?s)GetVectorDistance\(g_fClientAimCacheEyePos\[iClient\].*g_fClientEyePos\[iClient\]') {
    throw 'aim cache must validate the eye position key'
}
if ($perception -notmatch '(?s)GetVectorDistance\(g_fClientAimCacheAngles\[iClient\].*g_fClientEyeAng\[iClient\]') {
    throw 'aim cache must validate the eye angle key'
}
if ($perception -notmatch '(?s)TraceMetricsRecordCacheHit\(TRACE_METRIC_AIM\).*return') {
    throw 'same-command aim queries must return the cached endpoint without tracing'
}
if ($perception -notmatch '(?s)TraceMetricsRecordCacheMiss\(TRACE_METRIC_AIM\).*TraceMetricsRecordTraceCall\(TRACE_METRIC_AIM\)') {
    throw 'aim cache misses must account for the trace call'
}
if ($perception -notmatch '(?s)g_iClientAimCacheGeneration\[iClient\] = g_iClientCommandGeneration\[iClient\].*g_bClientAimCacheValid\[iClient\] = true') {
    throw 'aim cache fills must be scoped to the current command generation'
}
if ($runtime -notmatch '(?s)g_iClientCommandGeneration\[iClient\]\+\+.*g_bClientAimCacheValid\[iClient\]\s*=\s*false') {
    throw 'a new command must invalidate the previous aim result'
}
if ($perception -notmatch '(?s)if \(g_bPerformanceBudgetEnabled\)[\s\S]*TraceMetricsRecordCacheHit\(TRACE_METRIC_AIM\)') {
    throw 'aim hit metrics must remain gated by performance logging'
}
$aimBody = [regex]::Match($perception, '(?s)void GetClientAimPosition\(int iClient, float fAimPos\[3\]\).*?(?=int GetVectorTraceCacheHash)').Value
if ($aimBody -match 'GetProcessCacheExpiry\(') {
    throw 'aim cache must not use the process TTL across commands'
}

'l4d2_sb_ai aim trace cache contract passed'
