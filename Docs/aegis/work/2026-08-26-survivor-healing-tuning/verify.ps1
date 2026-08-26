param(
    [string]$RepoRoot = (Join-Path $PSScriptRoot '..\..\..\..')
)

$profile = Get-Content -Raw (Join-Path $RepoRoot 'cfg\cfgogl\versus_isfullshit\versus.cfg')
$source = Get-Content -Raw (Join-Path $RepoRoot 'addons\sourcemod\scripting\level_start_heal.sp')

if ($profile -notmatch '(?m)^confogl_addcvar automatic_healing_max 200\s*$') { throw 'automatic_healing_max is not 200' }
if ($profile -notmatch '(?m)^confogl_addcvar automatic_healing_repeat_interval 0\.3\s*$') { throw 'automatic_healing_repeat_interval is not 0.3' }
if ($profile -notmatch '(?m)^confogl_addcvar level_start_heal_health 500\s*$') { throw 'level_start_heal_health is not 500' }
if ($profile -match '(?m)^\s*confogl_addcvar automatic_healing_health\b') { throw 'automatic_healing_health must remain unconfigured' }
if ($source -notmatch 'O_health\s*>\s*100') { throw 'large level-start health guard is missing' }
if ($source -notmatch 'SetEntProp\(client,\s*Prop_Send,\s*"m_iMaxHealth",\s*O_health\)') { throw 'survivor max-health assignment is missing' }

Write-Output 'Healing contract passed.'
