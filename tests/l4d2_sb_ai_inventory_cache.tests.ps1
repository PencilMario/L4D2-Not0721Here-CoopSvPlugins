$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$inventoryPath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/inventory.inc'
$inventory = Get-Content -Raw -LiteralPath $inventoryPath

$required = @(
    'g_fTeamInventoryCache_Expiry',
    'g_iTeamInventoryCache_Flag1',
    'g_iTeamInventoryCache_Flag2',
    'g_fTeamItemCache_Expiry',
    'GetTeamInventoryCacheExpiry'
)
foreach ($token in $required) {
    if (-not $inventory.Contains($token)) { throw "missing team inventory cache contract token: $token" }
}

'l4d2_sb_ai inventory cache contract passed'
