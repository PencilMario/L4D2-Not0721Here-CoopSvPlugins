$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/better_closed_friendfire.sp'
$source = Get-Content -Raw -LiteralPath $sourcePath

$required = @(
    'bool IsValidInGameClient(int client)',
    'return client >= 1 && client <= MaxClients && IsClientInGame(client);',
    'if (!IsValidInGameClient(victim) || !IsValidInGameClient(attacker))'
)

foreach ($token in $required) {
    if (-not $source.Contains($token)) {
        throw "missing client-boundary contract token: $token"
    }
}

if ($source.Contains('if (IsClientInGame(victim) && IsClientInGame(attacker))')) {
    throw 'damage callback still calls IsClientInGame before validating client indexes'
}

'better_closed_friendfire client-boundary contract passed'
