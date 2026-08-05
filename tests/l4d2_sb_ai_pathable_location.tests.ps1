$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$movementPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/movement.inc'
$movement = Get-Content -Raw -LiteralPath $movementPath

$required = @(
    'local player = GetPlayerFromUserID(iClient)',
    'if (player == null) return Vector(0, 0, 0)',
    'local location = player.TryGetPathableLocationWithin(fRadius)',
    'return location == null ? Vector(0, 0, 0) : location'
)

foreach ($token in $required) {
    if (-not $movement.Contains($token)) {
        throw "missing null-safe pathable-location contract token: $token"
    }
}

if ($movement.Contains('return GetPlayerFromUserID(iClient).TryGetPathableLocationWithin(fRadius)')) {
    throw 'pathable-location wrapper still exposes null as FIELD_TYPEUNKNOWN'
}

'l4d2_sb_ai pathable-location contract passed'
