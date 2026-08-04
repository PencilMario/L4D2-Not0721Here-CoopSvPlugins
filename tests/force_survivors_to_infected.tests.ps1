$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/optional/force_survivors_to_infected.sp'
$configPath = Join-Path $repo 'cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg'

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing plugin source: $sourcePath"
}

$source = Get-Content -Raw -LiteralPath $sourcePath
$config = Get-Content -Raw -LiteralPath $configPath
$errors = [System.Collections.Generic.List[string]]::new()

function Require-Pattern {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -notmatch $Pattern) {
        $errors.Add($Message)
    }
}

Require-Pattern $source 'HookEvent\("player_team",\s*Event_PlayerTeam\)' 'Plugin must listen for every player team change.'
Require-Pattern $source 'event\.GetInt\("team"\)\s*!=\s*2' 'Plugin must react only when a player enters the Survivor team.'
Require-Pattern $source 'IsFakeClient\(client\)' 'Plugin must leave bots unchanged.'
Require-Pattern $source 'RequestFrame\(MoveSurvivorToInfected,\s*GetClientUserId\(client\)\)' 'Plugin must defer the team move and identify the client safely.'
Require-Pattern $source 'GetClientTeam\(client\)\s*!=\s*2' 'Deferred callback must verify the player is still a Survivor.'
Require-Pattern $source 'ChangeClientTeam\(client,\s*3\)' 'Eligible human Survivors must be moved to the Infected team.'
Require-Pattern $config '(?m)^sm plugins load optional/force_survivors_to_infected\.smx\s*$' 'versus_isfullshit must load the optional plugin.'

if ($errors.Count -gt 0) {
    throw "Force Survivors to Infected contract failed:`n$($errors -join "`n")"
}

'Force Survivors to Infected contract passed'
