$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$workflow = Get-Content -LiteralPath (Join-Path $root '.github/workflows/compile_and_release.yml') -Raw

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

Assert-Contains $workflow "      - 'cfg/**'" 'Pushes that modify cfg must trigger the workflow.'
Assert-Contains $workflow 'git diff --quiet addons/sourcemod/plugins/' 'Compiled plugin changes must remain eligible for release creation.'
Assert-Contains $workflow 'git diff --quiet "${{ github.event.before }}" "${{ github.sha }}" -- cfg/' 'Configuration changes must be compared across the pushed commit range.'

Write-Host 'configuration release trigger checks passed'
