$ErrorActionPreference = 'Stop'
$path = Join-Path $PSScriptRoot '..\addons\sourcemod\scripting\l4d2_anti_friendly_fire_down.sp'
if (-not (Test-Path $path)) { throw 'anti-friendly-fire plugin source is missing' }
$source = Get-Content -Raw $path
@(
  'SDKHook_OnTakeDamage',
  'player_incapacitated',
  'player_death',
  'revive_success',
  'mission_lost',
  'map_transition',
  'PrintToChat',
  'g_bDownedByPair'
) | ForEach-Object {
  if ($source -notmatch [regex]::Escape($_)) { throw "missing contract: $_" }
}
Write-Output 'anti-friendly-fire contract passed'
