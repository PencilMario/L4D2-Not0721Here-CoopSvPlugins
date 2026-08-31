$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$perceptionPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc'
$thinkPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc'
$perception = Get-Content -Raw -LiteralPath $perceptionPath
$think = Get-Content -Raw -LiteralPath $thinkPath

if (-not $perception.Contains('void GetInfectedCounts')) { throw 'missing merged infected-count helper' }
if (-not $think.Contains('GetInfectedCounts(iClient')) { throw 'bot think does not use merged infected-count helper' }
if ($think.Contains('g_iSurvivorBot_ThreatInfectedCount[iClient] = GetInfectedCount(iClient, 125.0)')) { throw 'bot think still performs separate 125-range scan' }

'l4d2_sb_ai infected-count merge contract passed'
