$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$source = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/sm_vprofiler.sp')
$sharedPlugins = Get-Content -Raw -LiteralPath (Join-Path $repo 'cfg/cfgogl/coop_base/shared_plugins.cfg')

function Require-Text([string] $Text, [string] $Needle, [string] $Message) {
    if (-not $Text.Contains($Needle)) { throw $Message }
}

Require-Text $source '#include <logger>' 'sm_vprofiler must include logger.inc'
Require-Text $source 'Logger g_hProfilerLogger;' 'sm_vprofiler must own a dedicated logger'
Require-Text $source 'new Logger("sm_vprofiler", LoggerType_NewLogFile)' 'sm_vprofiler must write to its dedicated log file'
Require-Text $source 'g_hProfilerLogger.info("VPROF_START' 'sm_debug start must write a logger entry'
Require-Text $source 'void AppendProfilerResultToLogger' 'vprof results must have a logger append helper'
Require-Text $source 'g_hProfilerLogger.lograw("%s", sLine)' 'vprof result lines must be written through logger.inc'
Require-Text $source 'FileSize(g_PathCosole)' 'L4D2 console output must retain its existing mirror source'
Require-Text $source 'AppendProfilerResultToLogger(g_PathProfilerLog)' 'L4D2 profiler output must be appended after mirroring'
Require-Text $source 'AppendProfilerResultToLogger(g_PathProfilerLog' 'non-L4D2 profiler output must be appended to the logger file'
Require-Text $sharedPlugins 'sm plugins load sm_vprofiler.smx' 'coop_base must load sm_vprofiler'

'sm_vprofiler logger contract passed'
