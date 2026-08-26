$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_zcs_redux.sp'

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing plugin source: $sourcePath"
}

$source = Get-Content -Raw -LiteralPath $sourcePath
$errors = [System.Collections.Generic.List[string]]::new()

function Require-SourcePattern {
    param(
        [string]$Pattern,
        [string]$Message
    )

    if ($source -notmatch $Pattern) {
        $errors.Add($Message)
    }
}

Require-SourcePattern '#define ZC_LIMITSIZE\s+ZC_TANK\s*\+\s*1' 'Per-class limit storage must include the Tank class slot.'
Require-SourcePattern 'ConVar g_hTankLimit;' 'Tank limit ConVar handle is missing.'
Require-SourcePattern 'int g_iTankLimit\s*=\s*0;' 'Tank limit cache must default to zero.'
Require-SourcePattern 'CreateConVar\("zcs_tank_limit",\s*"0",[\s\S]*?true,\s*0\.0,\s*true,\s*10\.0\)' 'zcs_tank_limit must default to 0 and be bounded from 0 to 10.'
Require-SourcePattern 'HookConVarChange\(g_hTankLimit,\s*Sub_ConVarsChanged\)' 'Tank limit change hook is missing.'
Require-SourcePattern 'g_iTankLimit\s*=\s*GetConVarInt\(g_hTankLimit\)' 'Tank limit must be reloaded from its ConVar.'
Require-SourcePattern 'g_iZVLimits\[ZC_TANK\]\s*=\s*g_iTankLimit' 'Tank limit must populate the Tank class slot.'

Require-SourcePattern 'for\s*\(int i = ZC_SMOKER; i <= ZC_TANK; i\+\+\)[\s\S]*?g_sBossClassnames\[i\]' 'sm_buy class selection must include Tank names.'
Require-SourcePattern 'stock bool Sub_IsSelectableClass\(any ZClass\)[\s\S]*?ZClass != ZC_WITCH' 'Selectable class helper must include Tank while excluding Witch.'
Require-SourcePattern 'stock int Sub_GetNextClass\(any ZClass\)[\s\S]*?ZC_CHARGER[\s\S]*?ZC_TANK[\s\S]*?ZC_TANK[\s\S]*?ZC_SMOKER' 'Class cycling must add Charger -> Tank -> Smoker.'
Require-SourcePattern 'if\s*\(!Sub_IsSelectableClass\(ZClass\)\)\s*return;' 'Class determination must reject Witch/invalid classes while accepting Tank.'

$selectableLoopCount = ([regex]::Matches($source, 'Sub_IsSelectableClass\(i\)')).Count
if ($selectableLoopCount -lt 3) {
    $errors.Add("Tank-aware class loops are incomplete; expected at least 3 selectable-class guards, found $selectableLoopCount")
}

Require-SourcePattern 'g_iZVLimits\[ZC_TANK\]\s*=\s*g_iTankLimit[\s\S]*?for\s*\(int i = ZC_SMOKER; i <= ZC_CHARGER; i\+\+\)[\s\S]*?g_iZVLimits\[ZC_TOTAL\]\s*\+=' 'Tank must be limited independently and remain outside the ordinary SI total.'
Require-SourcePattern 'Hud_ShowLimits[\s\S]*?i <= ZC_TANK[\s\S]*?Sub_IsSelectableClass\(i\)' 'The limits HUD must display Tank without displaying Witch.'

if ($errors.Count -gt 0) {
    throw "Zombie Character Select Tank contract failed:`n$($errors -join "`n")"
}

'Zombie Character Select Tank contract passed'


