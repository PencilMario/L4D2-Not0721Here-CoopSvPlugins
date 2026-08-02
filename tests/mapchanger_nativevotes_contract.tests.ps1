$ErrorActionPreference = 'Stop'

$sourcePath = Join-Path $PSScriptRoot '..\addons\sourcemod\scripting\MapChanger.sp'
$source = Get-Content -LiteralPath $sourcePath -Raw

function Assert-Matches([string] $Pattern, [string] $Message) {
    if ($source -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NotMatches([string] $Pattern, [string] $Message) {
    if ($source -match $Pattern) {
        throw $Message
    }
}

Assert-Matches '#include\s+<nativevotes>' 'MapChanger must require the NativeVotes include.'
Assert-Matches 'NativeVotes_Create\s*\([^;]*NativeVotesType_Custom_YesNo' 'The map vote must use a NativeVotes custom yes/no panel.'
Assert-Matches 'NativeVotes_Display\s*\(' 'The map vote must be displayed through NativeVotes.'
Assert-Matches 'NativeVotes_DisplayPass' 'A successful map vote must show the NativeVotes pass result.'
Assert-Matches 'NativeVotes_DisplayFail' 'A failed map vote must show the NativeVotes fail result.'
Assert-Matches 'NativeVotes_Cancel\s*\(' 'Veto and votepass must cancel the active NativeVotes panel.'
Assert-NotMatches 'Handle_VoteMapMenu' 'The old SourceMod map-vote menu callback must be retired.'
Assert-Matches 'Handle_VoteMarkMenu' 'The separate rating vote must remain unchanged.'

Write-Host 'MapChanger NativeVotes contract passed.'
