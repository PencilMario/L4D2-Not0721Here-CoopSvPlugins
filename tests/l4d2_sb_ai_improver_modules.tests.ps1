$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver.sp'
$moduleRoot = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver'
$source = Get-Content -Raw -LiteralPath $sourcePath

$left4dPos = $source.IndexOf('#include <left4dhooks>')
$vscriptPos = $source.IndexOf('#include <vscript>')
if ($left4dPos -lt 0 -or $vscriptPos -lt 0 -or $left4dPos -gt $vscriptPos) {
    throw 'left4dhooks must be included before vscript to avoid duplicate fieldtype_t declarations'
}

$modules = @(
    'state.inc',
    'lifecycle.inc',
    'convars.inc',
    'bootstrap.inc',
    'events.inc',
    'debug.inc',
    'runtime.inc',
    'bot_think.inc',
    'combat.inc',
    'movement.inc',
    'aiming.inc',
    'rescue.inc',
    'grenades.inc',
    'weapons.inc',
    'scavenging.inc',
    'entity_registry.inc',
    'weapon_data.inc',
    'navigation.inc',
    'navigation_cache.inc',
    'perception.inc',
    'inventory.inc',
    'utilities.inc',
    'detours.inc',
    'actions.inc'
)
$moduleSources = $source
Get-ChildItem -LiteralPath $moduleRoot -Filter '*.inc' | ForEach-Object {
    $moduleSources += Get-Content -Raw -LiteralPath $_.FullName
}
foreach ($module in $modules) {
    $path = Join-Path $moduleRoot $module
    if (-not (Test-Path -LiteralPath $path)) { throw "missing module: $module" }
    $includeDirective = '#include "l4d2_sb_ai_improver/{0}"' -f $module
    if (-not $moduleSources.Contains($includeDirective)) {
        throw "module graph does not include: $module"
    }
    $sizeLimit = if ($module -eq 'bot_think.inc') { 45000 } else { 35000 }
    if ((Get-Item -LiteralPath $path).Length -ge $sizeLimit) { throw "module remains oversized: $module" }
}

if ((Get-Content -LiteralPath $sourcePath).Count -ge 100) {
    throw 'composition root must remain below 100 lines'
}

'l4d2_sb_ai_improver module contract passed'
