$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$actionsPath = Join-Path $sourceRoot 'actions.inc'
$registryPath = Join-Path $sourceRoot 'entity_registry.inc'
$perceptionPath = Join-Path $sourceRoot 'perception.inc'
$statePath = Join-Path $sourceRoot 'state.inc'

$actions = Get-Content -Raw -LiteralPath $actionsPath
$registry = Get-Content -Raw -LiteralPath $registryPath
$perception = Get-Content -Raw -LiteralPath $perceptionPath
$state = Get-Content -Raw -LiteralPath $statePath

# 1. ActionResult Contract Checks
if ($actions -match 'hResult\.action\s*=\s*INVALID_ACTION') {
    throw 'Contract violation: hResult.action must never be assigned INVALID_ACTION'
}

if ($actions -notmatch '(?s)BehaviorAction hRetreatAction = CreateSurvivorLegsRetreatAction\(iPathDangerous\);\s*if \(hRetreatAction != INVALID_ACTION\)\s*\{\s*hResult\.type = CHANGE_TO;\s*hResult\.action = hRetreatAction;\s*return Plugin_Changed;\s*\}\s*return Plugin_Continue;') {
    throw 'Contract violation: OnRegroupWithTeamAction must validate retreat action handle before modifying hResult and returning Plugin_Changed'
}

if ($actions -notmatch '(?s)BehaviorAction hRetreatAction = CreateSurvivorLegsRetreatAction\(iPathDangerous\);\s*if \(hRetreatAction != INVALID_ACTION\)\s*\{\s*hResult\.type = CHANGE_TO;\s*hResult\.action = hRetreatAction;\s*PerformanceBudgetEndStage\(iActor\);\s*return Plugin_Changed;\s*\}\s*PerformanceBudgetEndStage\(iActor\);\s*return Plugin_Continue;') {
    throw 'Contract violation: OnMoveToIncapacitatedFriendAction must validate retreat action handle and pair PerformanceBudgetEndStage before returning'
}

if ($actions -notmatch '(?s)hResult\.type = DONE;\s*return Plugin_Changed;') {
    throw 'Contract violation: DONE path in OnRegroupWithTeamAction must set type and return Plugin_Changed without setting action'
}

if ($actions -notmatch '(?s)hResult\.type = DONE;\s*PerformanceBudgetEndStage\(iActor\);\s*return Plugin_Changed;') {
    throw 'Contract violation: DONE path in OnMoveToIncapacitatedFriendAction must set type, call PerformanceBudgetEndStage and return Plugin_Changed'
}

# 2. Door State & Trace Filter Checks
if ($state -notmatch '#define TRACE_ENTITY_BLOCKING\s+3') {
    throw 'Contract violation: TRACE_ENTITY_BLOCKING definition missing in state.inc'
}

if ($registry -notmatch '(?s)bool bIsDoor = \(strncmp\(sClass, "func_door", 9\) == 0 \|\| strncmp\(sClass, "prop_door", 9\) == 0\);\s*bool bHasDoorProp = HasEntProp\(iEntity, Prop_Data, "m_eDoorState"\);') {
    throw 'Contract violation: ClassifyTraceEntity must probe m_eDoorState separately from door classname'
}

if ($registry -notmatch '(?s)if \(bHasDoorProp\)\s*\{\s*g_iTraceEntityClass\[iEntity\] = TRACE_ENTITY_DOOR;\s*\}\s*else if \(bIsDoor\)\s*\{\s*g_iTraceEntityClass\[iEntity\] = TRACE_ENTITY_BLOCKING;\s*\}') {
    throw 'Contract violation: ClassifyTraceEntity must assign TRACE_ENTITY_BLOCKING to doors lacking m_eDoorState'
}

if ($perception -notmatch '(?s)if \(g_iTraceEntityClass\[iEntity\] == TRACE_ENTITY_BLOCKING\) return true;') {
    throw 'Contract violation: Base_TraceFilter must return true for TRACE_ENTITY_BLOCKING to preserve blocking semantics'
}

if ($perception -notmatch '(?s)if \(GetGameTime\(\) >= g_fTraceDoorStateExpiry\[iEntity\]\)\s*\{\s*if \(!HasEntProp\(iEntity, Prop_Data, "m_eDoorState"\)\)\s*\{\s*g_iTraceEntityClass\[iEntity\] = TRACE_ENTITY_BLOCKING;\s*g_iTraceDoorState\[iEntity\] = DOOR_STATE_CLOSED;\s*g_fTraceDoorStateExpiry\[iEntity\] = 0\.0;\s*return true;\s*\}\s*g_iTraceDoorState\[iEntity\] = L4D_GetDoorState\(iEntity\);') {
    throw 'Contract violation: Base_TraceFilter must guard L4D_GetDoorState with HasEntProp check at state refresh site'
}

'l4d2_sb_ai issue 1 contract tests passed successfully'
