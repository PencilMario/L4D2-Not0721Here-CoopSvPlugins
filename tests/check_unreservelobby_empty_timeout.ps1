$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$pluginPath = Join-Path $root 'addons/sourcemod/scripting/l4d2_unreservelobby.sp'
$plugin = Get-Content -LiteralPath $pluginPath -Raw

function Assert-Contains {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -notmatch [regex]::Escape($Pattern)) {
        throw $Message
    }
}

Assert-Contains $plugin 'l4d_unreserve_empty_timeout' 'Plugin must expose a configurable empty-server lobby timeout cvar.'
Assert-Contains $plugin 'g_cvCookie.AddChangeHook(CvarChanged_Cookie)' 'Cookie changes must schedule or cancel the empty-server timeout.'
Assert-Contains $plugin 'CreateTimer(float(g_iEmptyTimeout), Timer_UnreserveEmptyLobby' 'Plugin must create a one-shot empty-server unreserve timer.'
Assert-Contains $plugin 'public Action Timer_UnreserveEmptyLobby(Handle timer)' 'Plugin must implement the empty-server unreserve timer callback.'
Assert-Contains $plugin 'GetConnectedPlayer(-1) > 0' 'Timer callback must re-check that no human players are connected before unreserving.'
Assert-Contains $plugin 'RemoveLobbyReservation(true)' 'Timer callback must remove the lobby reservation through the shared unreserve helper.'
Assert-Contains $plugin 'delete g_hEmptyUnreserveTimer' 'Plugin must cancel the pending empty-server timer when conditions no longer apply.'

Write-Host 'unreservelobby empty timeout checks passed'
