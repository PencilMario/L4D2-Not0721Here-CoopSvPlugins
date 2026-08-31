$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$debugPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/debug.inc'
$lifecyclePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/lifecycle.inc'
$versusPath = Join-Path $repo 'cfg/cfgogl/versus_isfullshit/versus.cfg'
$debug = Get-Content -Raw -LiteralPath $debugPath
$lifecycle = Get-Content -Raw -LiteralPath $lifecyclePath
$versus = Get-Content -Raw -LiteralPath $versusPath

if (-not $debug.Contains('g_hPerformanceLogger.lograw')) { throw 'performance logging must write through Logger.lograw' }
if ($debug.Contains('g_hPerformanceLogger.warning')) { throw 'performance logging must not print slow calculations to console' }
if (-not $lifecycle.Contains('new Logger("sb_ai_performance", LoggerType_NewLogFile)')) { throw 'performance logger must use a separate log file' }
if (-not $versus.Contains('confogl_addcvar ib_performance_logging 1')) { throw 'performance logging must be enabled in versus_isfullshit' }
if (-not $versus.Contains('confogl_addcvar ib_debug 1')) { throw 'navigation debug must be enabled in versus_isfullshit' }

'l4d2_sb_ai performance file/debug contract passed'
