$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$matchModesPath = Join-Path $repo 'addons/sourcemod/configs/matchmodes.txt'
$cfgoglPath = Join-Path $repo 'cfg/cfgogl'

$matchModes = Get-Content -Raw -LiteralPath $matchModesPath
$modeMatches = [regex]::Matches($matchModes, '(?s)"([^"]+)"\s*\{\s*"name"\s*"[^"]+"')
$modeNames = @($modeMatches | ForEach-Object { $_.Groups[1].Value })
if ($modeNames.Count -eq 0) { throw 'no selectable modes found in matchmodes.txt' }

$errors = [System.Collections.Generic.List[string]]::new()
$bit2ModeCount = 0

foreach ($modeName in $modeNames) {
    $modePath = Join-Path $cfgoglPath $modeName
    if (-not (Test-Path -LiteralPath $modePath -PathType Container)) {
        $errors.Add("$modeName`: configuration directory is missing")
        continue
    }

    $modeConfig = (Get-ChildItem -LiteralPath $modePath -Filter '*.cfg' -File |
        Sort-Object FullName |
        ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }) -join "`n"

    $aiMatches = [regex]::Matches(
        $modeConfig,
        '(?m)^\s*confogl_addcvar\s+sm_aidmgfix_enable\s+([0-3])(?:\s|$)'
    )
    $aiDamageFix = if ($aiMatches.Count -gt 0) {
        [int]$aiMatches[$aiMatches.Count - 1].Groups[1].Value
    } else {
        3
    }

    $chargerMatches = [regex]::Matches(
        $modeConfig,
        '(?m)^\s*confogl_addcvar\s+l4d2_melee_damage_charger\s+([^\s/]+)'
    )

    if (($aiDamageFix -band 2) -ne 0) {
        $bit2ModeCount++
        if ($chargerMatches.Count -ne 1 -or $chargerMatches[0].Groups[1].Value -ne '350') {
            $actual = if ($chargerMatches.Count -eq 0) { 'missing' } else { $chargerMatches.Groups[1].Value -join ', ' }
            $errors.Add("$modeName`: sm_aidmgfix_enable=$aiDamageFix requires exactly one l4d2_melee_damage_charger 350; found $actual")
        }
    } elseif ($chargerMatches.Count -ne 0) {
        $errors.Add("$modeName`: sm_aidmgfix_enable=$aiDamageFix must not override l4d2_melee_damage_charger")
    }
}

if ($errors.Count -gt 0) {
    throw "Charger melee damage contract failed:`n$($errors -join "`n")"
}

"charger melee damage contract passed: $($modeNames.Count) selectable modes checked, $bit2ModeCount modes fixed at 350"
