$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/transition_restore_fix.sp'
$gamedataPath = Join-Path $repo 'addons/sourcemod/gamedata/transition_restore_fix.txt'
$generalFixesPath = Join-Path $repo 'cfg/generalfixes.cfg'
$source = Get-Content -Raw -LiteralPath $sourcePath
$gamedata = Get-Content -Raw -LiteralPath $gamedataPath
$generalFixes = Get-Content -Raw -LiteralPath $generalFixesPath
$sharedPluginText = (Get-ChildItem -LiteralPath (Join-Path $repo 'cfg/cfgogl') -Recurse -File -Filter 'shared_plugins.cfg' | ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }) -join "`n"

function Assert-Matches([string] $Text, [string] $Pattern, [string] $Message) {
    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NotMatches([string] $Text, [string] $Pattern, [string] $Message) {
    if ($Text -match $Pattern) {
        throw $Message
    }
}

Assert-Matches $source 'GetAddress\("SavedPlayersCount"\)' 'Source must request the plural SavedPlayersCount gamedata address.'
Assert-Matches $source 'GetAddress\("SavedSurvivorBotsCount"\)' 'Source must request the plural SavedSurvivorBotsCount gamedata address.'
Assert-NotMatches $source 'GetAddress\("SavedPlayerCount"\)' 'The stale singular SavedPlayerCount lookup must be retired.'
Assert-NotMatches $source 'GetAddress\("SavedSurvivorBotCount"\)' 'The stale singular SavedSurvivorBotCount lookup must be retired.'
Assert-Matches $source 'DynamicDetour\.FromConf\(hGameData, "DD::PlayerSaveData::Restore"\)' 'PlayerSaveData::Restore must be detoured during restart restoration.'
Assert-Matches $source 'DD_PlayerSaveData_Restore_Pre' 'The PlayerSaveData restore pre-hook must exist.'
Assert-Matches $source 'DD_PlayerSaveData_Restore_Post' 'The PlayerSaveData restore post-hook must exist.'
Assert-Matches $source 'FindBotDataByModelName' 'Model-based bot save-data selection must exist.'
Assert-Matches $source 'FindBotDataByCharacter' 'Character-based bot save-data selection must exist.'
Assert-Matches $source 'SavedLevelRestartSurvivorBotsCount' 'Restart bot save-data selection must use its gamedata address.'
Assert-Matches $source 'PrecacheModel\(ModelName, true\)' 'Saved survivor models must be precached before human restoration.'
Assert-Matches $source 'GetClientTeam\(player\) != 2' 'Restore must ignore non-survivor or invalid player entities.'
Assert-Matches $source 'g_aBotData\.FindValue\(ptr\) != -1' 'Bot save-data selection must skip consumed records.'
Assert-NotMatches $source 'priority.*\? 2 : 3' 'Bot save-data selection must not reuse consumed records.'
Assert-Matches $gamedata '"SavedPlayersCount"' 'Gamedata must define SavedPlayersCount.'
Assert-Matches $gamedata '"SavedSurvivorBotsCount"' 'Gamedata must define SavedSurvivorBotsCount.'
Assert-Matches $gamedata '"SavedLevelRestartSurvivorBotsCount"' 'Gamedata must define SavedLevelRestartSurvivorBotsCount.'
Assert-Matches $generalFixes 'sm plugins load fix/transition_restore_fix\.smx' 'generalfixes.cfg must be the canonical explicit plugin loader.'
Assert-NotMatches $sharedPluginText 'sm plugins load transition_restore_fix\.cfg' 'Mode shared plugin configs must not try to load the cvar cfg as a plugin.'

Write-Host 'transition restore contract passed.'
