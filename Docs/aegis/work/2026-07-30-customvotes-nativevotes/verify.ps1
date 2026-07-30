$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')
$sourcePath = Join-Path $repoRoot 'addons\sourcemod\scripting\customvotes.sp'
$source = Get-Content -Raw -LiteralPath $sourcePath
$failures = [System.Collections.Generic.List[string]]::new()

$requiredPatterns = @{
    'required NativeVotes dependency' = '#define REQUIRE_PLUGIN'
    'NativeVotes include' = '#include <nativevotes>'
    'NativeVotes vote type' = 'NativeVotesType_Custom_YesNo'
    'NativeVotes result callback' = 'NativeVotes_SetResultCallback'
    'eligible-pool threshold' = 'g_iActiveVoteEligibleClients'
    'native panel color stripping' = 'CRemoveTags(strTitle, iTitleSize)'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
    if (-not $source.Contains($entry.Value)) {
        $failures.Add("Missing $($entry.Key): $($entry.Value)")
    }
}

$retiredPatterns = @(
    'g_bVoteForTarget',
    'g_bVoteForMap',
    'g_bVoteForOption',
    'g_bVoteForSimple',
    'g_hArrayVotePlayerSteamID',
    'g_hArrayVotePlayerIP',
    'g_bVoteCallVote',
    'g_bVoteMultiple',
    'VoteMenu(hMenu',
    'public bool:CheckVotesFor',
    'public GetVotesFor'
)

foreach ($pattern in $retiredPatterns) {
    if ($source.Contains($pattern)) {
        $failures.Add("Retired voting owner remains: $pattern")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

Write-Output 'CustomVotes NativeVotes migration contract passed.'
