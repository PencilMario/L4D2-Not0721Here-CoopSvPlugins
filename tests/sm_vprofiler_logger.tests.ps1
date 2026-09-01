$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$source = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/sm_vprofiler.sp')
$logger = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/include/logger.inc')
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
Require-Text $source 'const int VPROF_CAPTURE_MAX_BYTES = 8388608;' 'direct vprof capture must use an 8 MiB buffer'
Require-Text $source 'char g_sProfilerOutput[VPROF_CAPTURE_MAX_BYTES];' 'direct vprof capture must keep the large output buffer alive'
Require-Text $source 'ServerCommandEx(g_sProfilerOutput, sizeof(g_sProfilerOutput), "sm prof dump vprof")' 'vprof dump output must be captured directly'
Require-Text $source 'WriteProfilerOutputToLogger(g_sProfilerOutput)' 'direct vprof output must be written to the logger'
Require-Text $source 'VPROF_RESULT_CAPTURE_TRUNCATED' 'truncated direct output must be reported'
Require-Text $source 'VPROF_RESULT_CAPTURE_EMPTY' 'empty direct output must be reported'
Require-Text $source 'MAX_LOG_LINE - 1' 'logger writes must be split below the logger line limit'
Require-Text $source 'RequestFrame(OnFrameDump);' 'vprof dump must run on a later frame before stop'
Require-Text $source 'public void OnFrameDump()' 'vprof dump must have a deferred callback'
Require-Text $source 'const int VPROF_CHUNKS_PER_FRAME = 8;' 'profiler result writes must be spread across frames'
Require-Text $source 'RequestFrame(OnFrameWriteProfilerOutput);' 'profiler result writes must be deferred frame by frame'
Require-Text $source 'g_hProfilerLogger.OpenRawFile()' 'profiler output must keep one logger file handle open'
Require-Text $source 'g_hProfilerLogger.WriteRawString(g_hProfilerLogFile, sChunk)' 'profiler chunks must use the logger raw writer'
Require-Text $source 'const int VPROF_MIRROR_BYTES_PER_FRAME = 8192;' 'L4D2 mirror copies must have a per-frame byte budget'
Require-Text $source 'RequestFrame(OnFrameMirrorLog);' 'L4D2 mirror copies must be deferred frame by frame'
Require-Text $source 'public void OnFrameMirrorLog()' 'L4D2 mirror copies must have a deferred callback'
Require-Text $source 'void AppendProfilerResultToLogger' 'vprof results must have a logger append helper'
Require-Text $source 'FileSize(g_PathCosole)' 'L4D2 console output must retain its existing mirror source'
Require-Text $source 'AppendProfilerResultToLogger(g_PathProfilerLog)' 'L4D2 profiler output must be appended after mirroring'
Require-Text $source 'AppendProfilerResultToLogger(g_PathProfilerLog' 'non-L4D2 profiler output must be appended to the logger file'
Require-Text $logger '#define MAX_LOG_LINE 8192' 'logger must accept profiler chunks larger than 512 bytes'
Require-Text $logger 'public File OpenRawFile()' 'logger must expose a reusable raw file handle'
Require-Text $logger 'public bool WriteRawString(File file, const char[] message)' 'logger must expose raw string writes'
Require-Text $logger 'file.WriteString(message, false);' 'raw logger writes must bypass WriteFileLine'
Require-Text $logger 'file.WriteString("\n", false);' 'regular raw logger writes must retain line endings'
Require-Text $sharedPlugins 'sm plugins load sm_vprofiler.smx' 'coop_base must load sm_vprofiler'
Require-Text $versusSharedPlugins 'sm plugins load sm_vprofiler.smx' 'versus_isfullshit must load sm_vprofiler'

$captureBytes = [regex]::Match($source, 'const int VPROF_CAPTURE_MAX_BYTES = (\d+);').Groups[1].Value
if ([int]$captureBytes -lt (8 * 1024 * 1024)) {
    throw 'direct vprof capture buffer must cover at least 8 MiB'
}

$dumpCallbackPos = $source.IndexOf('public void OnFrameDump()')
$dumpCallbackEnd = $source.IndexOf('void SetCvarSilent', $dumpCallbackPos)
$dumpPos = $source.IndexOf('ServerCommandEx(g_sProfilerOutput', $dumpCallbackPos)
$stopPos = $source.IndexOf('ServerCommand("sm prof stop vprof")', $dumpCallbackPos)
if ($dumpCallbackPos -lt 0 -or $dumpCallbackEnd -lt 0 -or $dumpPos -lt 0 -or $stopPos -lt 0 -or
    $dumpPos -ge $dumpCallbackEnd -or $stopPos -ge $dumpCallbackEnd -or $dumpPos -ge $stopPos) {
    throw 'vprof dump must run in a later-frame callback before vprof stop'
}

$mirrorTimerPos = $source.IndexOf('public Action Timer_MirrorLog')
$mirrorCallbackPos = $source.IndexOf('public void OnFrameMirrorLog()', $mirrorTimerPos)
if ($mirrorTimerPos -lt 0 -or $mirrorCallbackPos -lt 0) {
    throw 'L4D2 mirror timer and callback must both exist'
}
$mirrorTimerBody = $source.Substring($mirrorTimerPos, $mirrorCallbackPos - $mirrorTimerPos)
if ($mirrorTimerBody.Contains('while( !hr.EndOfFile() )')) {
    throw 'L4D2 mirror timer must not copy an unbounded console-log tail synchronously'
}

'sm_vprofiler logger contract passed'
