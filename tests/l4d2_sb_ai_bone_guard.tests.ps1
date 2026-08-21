$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$aimingPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/aiming.inc'
$navigationPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/navigation.inc'
$aiming = Get-Content -Raw -LiteralPath $aimingPath
$navigation = Get-Content -Raw -LiteralPath $navigationPath

foreach ($required in @(
    'bool LBI_IsBoneQueryReady(int iEntity)',
    'HasEntProp(iEntity, Prop_Send, "m_nModelIndex")',
    'GetEntProp(iEntity, Prop_Send, "m_nModelIndex")',
    'HasEntProp(iEntity, Prop_Data, "m_ModelName")',
    'GetEntPropString(iEntity, Prop_Data, "m_ModelName"',
    'int LBI_LookupBone(int iEntity, const char[] sBoneName)',
    'int iBoneIndex = LBI_LookupBone(iEntity, sBoneName)'
)) {
    if (-not $navigation.Contains($required)) {
        throw "Missing required bone guard contract: $required"
    }
}

if (([regex]::Matches($navigation + $aiming, 'SDKCall\(g_hLookupBone')).Count -ne 1) {
    throw 'g_hLookupBone must have exactly one guarded SDKCall owner'
}

if (-not $aiming.Contains('if (!LBI_IsBoneQueryReady(iTarget))')) {
    throw 'aiming.inc must short-circuit unready target models'
}

if (-not $aiming.Contains('GetEntityAbsOrigin(iTarget, fAimPos)')) {
    throw 'aiming.inc must preserve an entity-origin fallback'
}

'l4d2_sb_ai bone guard contract passed'
