$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$perceptionPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc'
$thinkPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc'
$perception = Get-Content -Raw -LiteralPath $perceptionPath
$think = Get-Content -Raw -LiteralPath $thinkPath

if (-not $perception.Contains('IsSurvivorNearBoomer')) { throw 'missing shared boomer-threat cache helper' }
if (-not $perception.Contains('g_fSurvivorNearBoomerCache_Expiry')) { throw 'missing boomer-threat cache expiry' }
if (-not $think.Contains('IsSurvivorNearBoomer(i)')) { throw 'bot think does not use shared boomer-threat cache' }
if ($think.Contains('for (int j = 1; j <= MaxClients; j++)')) { throw 'bot think still contains per-teammate boomer client scan' }

'l4d2_sb_ai boomer cache contract passed'
