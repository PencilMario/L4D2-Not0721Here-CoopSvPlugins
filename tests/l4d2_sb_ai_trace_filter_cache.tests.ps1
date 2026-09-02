$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$state = Get-Content -Raw (Join-Path $root 'addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc')
$registry = Get-Content -Raw (Join-Path $root 'addons/sourcemod/scripting/l4d2_sb_ai_improver/entity_registry.inc')
$perception = Get-Content -Raw (Join-Path $root 'addons/sourcemod/scripting/l4d2_sb_ai_improver/perception.inc')
foreach ($x in @('g_iTraceEntityClass','g_iTraceEntityEntRef','g_fTraceDoorStateExpiry','ClassifyTraceEntity','InvalidateTraceFilterEntity')) { if ($state -notmatch $x -and $registry -notmatch $x -and $perception -notmatch $x) { throw "missing $x" } }
if ($perception -match '(?s)bool Base_TraceFilter.*?HasEntProp') { throw 'per-callback HasEntProp remains' }
if ($perception -notmatch 'iEntity == iData' -or $perception -notmatch 'return false' -or $perception -notmatch 'g_iTraceDoorState\[iEntity\] != DOOR_STATE_OPENED') { throw 'filter semantics missing' }
foreach ($x in @('func_door_rotating','prop_door_rotating','OnOpen','OnClose','OnFullyOpen','OnFullyClosed')) { if ($perception -notmatch $x -and $registry -notmatch $x -and (Get-Content -Raw (Join-Path $root 'addons/sourcemod/scripting/l4d2_sb_ai_improver/lifecycle.inc')) -notmatch $x) { throw "missing door output $x" } }
if ($registry -notmatch 'ResetTraceFilterCache\(\)') { throw 'map reset missing' }
if ($registry -notmatch 'HasEntProp\(iEntity, Prop_Data, "m_eDoorState"\)') { throw 'unknown classification slow path missing' }
if ($registry -notmatch '(?s)if \(!bIsDoor\)\s*bIsDoor = HasEntProp\(iEntity, Prop_Data, "m_eDoorState"\)') { throw 'HasEntProp must stay on the unknown-classification slow path' }
if ($registry -notmatch '(?s)ClassifyTraceEntity\(i, sEntClassname\);[\s\S]*CheckEntityForStuff\(i, sEntClassname\);') { throw 'map-start entity scan must pre-classify trace entities' }
'l4d2_sb_ai trace filter cache contract passed'
