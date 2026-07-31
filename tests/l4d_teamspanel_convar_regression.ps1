$sourcePath = Join-Path $PSScriptRoot "..\addons\sourcemod\scripting\l4d_teamspanel.sp"
$source = Get-Content -Raw $sourcePath

if ($source -match 'Format\([^;]+g_cMaxSpecials\.IntValue') {
    throw "BuildPrintPanel directly dereferences the optional si_spawn_max_specials ConVar"
}

if ($source -notmatch 'g_cMaxSpecials\s*==\s*null') {
    throw "The optional si_spawn_max_specials ConVar is not guarded against load-order failures"
}

if ($source -notmatch 'FindConVar\("si_spawn_max_specials"\)') {
    throw "The panel no longer binds to si_spawn_max_specials"
}

Write-Output "l4d_teamspanel ConVar regression check passed"
