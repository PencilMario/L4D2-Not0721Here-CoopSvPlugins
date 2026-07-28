$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/bot_catchup_speed.sp'
if (-not (Test-Path -LiteralPath $sourcePath)) { throw 'renamed source is missing' }

$source = Get-Content -Raw -LiteralPath $sourcePath
$required = @(
    '#include <left4dhooks>',
    'L4D2Direct_GetFlowDistance',
    'L4D2Direct_GetMapMaxFlowDistance',
    'RoundToFloor',
    '* 0.1',
    '*= 1.25',
    '#define ADRENALINE_THRESHOLD 10.0',
    '> ADRENALINE_THRESHOLD',
    'L4D2_UseAdrenaline',
    'HookEvent("entity_shoved"',
    'GetEntityClassname',
    '"infected"',
    'AcceptEntityInput(entity, "Kill")'
)
foreach ($needle in $required) {
    if (-not $source.Contains($needle)) { throw "missing contract token: $needle" }
}

$configs = @(
    'cfg/cfgogl/versus_isfullshit/shared_plugins.cfg',
    'cfg/cfgogl/coop_base/shared_plugins.cfg',
    'cfg/cfgogl/coop_rpg/shared_plugins.cfg'
)
foreach ($relative in $configs) {
    $content = Get-Content -Raw -LiteralPath (Join-Path $repo $relative)
    if (-not $content.Contains('sm plugins load bot_catchup_speed.smx')) { throw "new load reference missing: $relative" }
    if ($content.Contains('bot_missing_movement')) { throw "stale load reference: $relative" }
}

'bot_catchup_speed contract passed'
