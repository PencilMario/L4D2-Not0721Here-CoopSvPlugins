$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$state = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'state.inc')
$perception = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'perception.inc')
$movement = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'movement.inc')
$registry = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'entity_registry.inc')

foreach ($token in @(
    'VECTOR_TRACE_CACHE_SIZE',
    'VECTOR_TRACE_CACHE_WAYS',
    'VECTOR_TRACE_CACHE_SET_COUNT',
    'VECTOR_TRACE_CACHE_QUANTIZATION',
    'VECTOR_TRACE_CACHE_POSITION_TOLERANCE_SQR',
    'g_fVectorTraceCache_Expiry',
    'g_fVectorTraceCache_LastQueryTime',
    'g_iVectorTraceCache_Hash',
    'g_iVectorTraceCache_Mask',
    'g_iVectorTraceCache_RayType',
    'g_bVectorTraceCache_Result',
    'g_fVectorTraceCache_Start',
    'g_fVectorTraceCache_End'
)) {
    if (-not $state.Contains($token)) { throw "missing vector trace cache state: $token" }
}

if ($state -notmatch '#define VECTOR_TRACE_CACHE_QUANTIZATION 8\.0') {
    throw 'vector cache hashing must quantize coordinates in eight-unit cells'
}
if ($perception -notmatch 'int GetVectorTraceCacheHash\(const float fStart\[3\], const float fEnd\[3\], int iMask, RayType iRayType\)') {
    throw 'vector cache must use a structured start/end/mask/ray-type hash helper'
}
if ($perception -notmatch 'RoundToFloor\(fStart\[i\] / VECTOR_TRACE_CACHE_QUANTIZATION\)' -or
    $perception -notmatch 'RoundToFloor\(fEnd\[i\] / VECTOR_TRACE_CACHE_QUANTIZATION\)') {
    throw 'vector cache hash must include quantized start and end coordinates'
}
if ($perception -notmatch 'iHash = \(iHash \* 31\) \^ iMask' -or
    $perception -notmatch 'iHash = \(iHash \* 31\) \^ view_as<int>\(iRayType\)') {
    throw 'same endpoints with a different mask or ray type must miss the cache'
}
if ($perception -notmatch 'bool GetCachedVectorVisible\(const float fStart\[3\], const float fEnd\[3\], int iMask, RayType iRayType\)') {
    throw 'vector LOS must have one centralized cache implementation'
}
if ($perception -notmatch 'g_iVectorTraceCache_Hash\[i\] == iHash[\s\S]*g_iVectorTraceCache_Mask\[i\] == iMask[\s\S]*g_iVectorTraceCache_RayType\[i\] == view_as<int>\(iRayType\)') {
    throw 'same endpoint and mask queries must validate the full structured key before a hit'
}
if ($perception -notmatch 'GetVectorDistance\(g_fVectorTraceCache_Start\[i\], fStart, true\) <= VECTOR_TRACE_CACHE_POSITION_TOLERANCE_SQR' -or
    $perception -notmatch 'GetVectorDistance\(g_fVectorTraceCache_End\[i\], fEnd, true\) <= VECTOR_TRACE_CACHE_POSITION_TOLERANCE_SQR') {
    throw 'quantized hash matches must recheck original positions and miss beyond tolerance'
}
if ($perception -notmatch 'fNow < g_fVectorTraceCache_Expiry\[i\]') {
    throw 'expired vector LOS entries must miss before result reuse'
}
if ($perception -notmatch 'if \(fNow < g_fVectorTraceCache_LastQueryTime\)\s*ResetVectorTraceCache\(\);') {
    throw 'a map-time rollback must invalidate vector LOS entries from the previous map'
}
if ($perception -notmatch 'void ResetVectorTraceCache\(\)[\s\S]*g_fVectorTraceCache_Expiry\[i\] = 0\.0;[\s\S]*g_fVectorTraceCache_LastQueryTime = 0\.0;') {
    throw 'vector LOS cache must expose an explicit lifecycle reset helper'
}
if ($registry -notmatch 'OnMapStart\(\)[\s\S]*ResetVectorTraceCache\(\);' -or
    $registry -notmatch 'OnMapEnd\(\)[\s\S]*ResetVectorTraceCache\(\);') {
    throw 'map start and map end must explicitly reset the vector LOS cache'
}
if ($perception -notmatch 'g_fVectorTraceCache_Expiry\[iSlot\] = GetProcessCacheExpiry\(\)') {
    throw 'vector LOS cache must use ib_process_time expiry without a separate TTL'
}
if ($perception -notmatch 'TR_TraceRayFilterEx\(fStart, fEnd, iMask, iRayType, Base_TraceFilter\)') {
    throw 'a cache miss must trace with the ray type included in the cache key'
}
if ($perception -notmatch 'iWay == 0 \|\| g_fVectorTraceCache_Expiry\[i\] < fOldestExpiry') {
    throw 'a full vector cache set must replace its earliest-expiring way'
}
if ($perception -match 'StringMap|Trie|Format\([^\r\n]*VectorTrace|IntToString') {
    throw 'vector LOS cache keys must remain structured and must not allocate strings'
}
if ($state -match 'Handle\s+g_[^;]*VectorTraceCache' -or $perception -match 'g_hVectorTraceCache') {
    throw 'vector LOS cache must store only boolean results, never trace handles'
}
if ($perception -notmatch 'bool IsVisibleVector\(int iClient, float fPos\[3\], int iMask = MASK_SHOT\)[\s\S]*return GetCachedVectorVisible\(g_fClientEyePos\[iClient\], fPos, iMask, RayType_EndPoint\);') {
    throw 'IsVisibleVector API and eye-position semantics must delegate to the vector cache'
}
if ($perception -notmatch 'bool GetVectorVisible\(float fStart\[3\], float fEnd\[3\], int iMask = MASK_VISIBLE_AND_NPCS\)[\s\S]*return GetCachedVectorVisible\(fStart, fEnd, iMask, RayType_EndPoint\);') {
    throw 'GetVectorVisible API must delegate to the vector cache without changing its start position'
}
if ($perception -notmatch 'if \(g_bPerformanceBudgetEnabled\)[\s\S]*TraceMetricsRecordCacheHit\(TRACE_METRIC_VECTOR_LOS\)') {
    throw 'vector cache performance helpers must remain gated by performance logging'
}
if ($perception -notmatch 'if \(g_bPerformanceBudgetEnabled\)[\s\S]*TraceMetricsRecordCacheMiss\(TRACE_METRIC_VECTOR_LOS\)') {
    throw 'vector cache miss metrics must remain gated by performance logging'
}
if ($perception -notmatch 'GetFarthestInfected[\s\S]*IsVisibleVector\(iClient, fInfectedPos\)' -or
    $perception -notmatch 'GetInfectedCount[\s\S]*GetVectorVisible\(fClientPos, fInfectedPos\)') {
    throw 'farthest-infected and infected-count LOS paths must retain the cached public wrappers'
}
if ($movement -notmatch 'TakeCoverFromPosition[\s\S]*GetVectorVisible\(fPosition, fPathOffset\)') {
    throw 'movement LOS must retain the cached public wrapper'
}

'l4d2_sb_ai vector trace cache contract passed'
