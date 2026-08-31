$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$source = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/sm_vprofiler.sp')
$sharedPlugins = Get-Content -Raw -LiteralPath (Join-Path $repo 'cfg/cfgogl/coop_base/shared_plugins.cfg')
$versusSharedPlugins = Get-Content -Raw -LiteralPath (Join-Path $repo 'cfg/cfgogl/versus_isfullshit/shared_plugins.cfg')

function Require-Text([string] $Text, [string] $Needle, [string] $Message) {
    if (-not $Text.Contains($Needle)) { throw $Message }
}

Require-Text $source '#include <logger>' 'sm_vprofiler must include logger.inc'
Require-Text $source '#include <console>' 'sm_vprofiler must include ServerCommandEx support'
Require-Text $source 'Logger g_hProfilerLogger;' 'sm_vprofiler must own a dedicated logger'
Require-Text $source 'new Logger("sm_vprofiler", LoggerType_NewLogFile)' 'sm_vprofiler must write to its dedicated log file'
Require-Text $source 'BuildPath(Path_SM, g_PathProfilerLogger, sizeof(g_PathProfilerLogger), "logs/sm_vprofiler.log")' 'sm_vprofiler must expose its dedicated logger path'
Require-Text $source 'g_hProfilerLogger.info("VPROF_START' 'sm_debug start must write a logger entry'
Require-Text $source 'logger=%s' 'sm_debug start must report the dedicated logger path'
Require-Text $source 'Profiler result written to: %s' 'sm_debug stop must report the dedicated logger path'
Require-Text $source 'const int VPROF_CAPTURE_MAX_BYTES = 1048576;' 'direct vprof capture must use a large buffer'
Require-Text $source 'char g_sProfilerOutput[VPROF_CAPTURE_MAX_BYTES];' 'direct vprof capture must keep the large output buffer alive'
Require-Text $source 'ServerCommandEx(g_sProfilerOutput, sizeof(g_sProfilerOutput), "sm prof dump vprof")' 'vprof dump output must be captured directly'
Require-Text $source 'WriteProfilerOutputToLogger(g_sProfilerOutput)' 'direct vprof output must be written to the logger'
Require-Text $source 'VPROF_RESULT_CAPTURE_TRUNCATED' 'truncated direct output must be reported'
Require-Text $source 'VPROF_RESULT_CAPTURE_EMPTY' 'empty direct output must be reported'
Require-Text $source 'MAX_LOG_LINE - 1' 'logger writes must be split below the logger line limit'
Require-Text $source 'void AppendProfilerResultToLogger' 'vprof results must have a logger append helper'
Require-Text $source 'g_hProfilerLogger.lograw("%s", sChunk)' 'vprof result chunks must be written through logger.inc'
Require-Text $source 'FileSize(g_PathCosole)' 'L4D2 console output must retain its existing mirror source'
Require-Text $source 'AppendProfilerResultToLogger(g_PathProfilerLog)' 'L4D2 profiler output must be appended after mirroring'
Require-Text $source 'AppendProfilerResultToLogger(g_PathProfilerLog' 'non-L4D2 profiler output must be appended to the logger file'
Require-Text $sharedPlugins 'sm plugins load sm_vprofiler.smx' 'coop_base must load sm_vprofiler'
Require-Text $versusSharedPlugins 'sm plugins load sm_vprofiler.smx' 'versus_isfullshit must load sm_vprofiler'

$captureBytes = [regex]::Match($source, 'const int VPROF_CAPTURE_MAX_BYTES = (\d+);').Groups[1].Value
if ([int]$captureBytes -lt (512 * 128)) {
    throw 'direct vprof capture buffer must cover at least 512 lines at 128 bytes per line'
}

$stopPos = $source.IndexOf('ServerCommand("sm prof stop vprof")')
$dumpPos = $source.IndexOf('ServerCommandEx(g_sProfilerOutput')
if ($stopPos -lt 0 -or $dumpPos -lt 0 -or $stopPos -ge $dumpPos) {
    throw 'vprof stop must be queued before direct dump capture'
}

'sm_vprofiler logger contract passed'
