$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

$installer = Get-Content -LiteralPath (Join-Path $root 'install_release_updaters.sh') -Raw
$update = Get-Content -LiteralPath (Join-Path $root 'update_from_release.sh') -Raw
$fullUpdate = Get-Content -LiteralPath (Join-Path $root 'update_full_from_release.sh') -Raw
$customConfig = Get-Content -LiteralPath (Join-Path $root 'custom_config.sh') -Raw

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

function Assert-NotContains {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -match [regex]::Escape($Pattern)) {
        throw $Message
    }
}

Assert-Contains $installer 'l4d2_coop_update_from_release.sh' 'Installer must use project-specific normal updater target.'
Assert-Contains $installer 'l4d2_coop_update_full_from_release.sh' 'Installer must use project-specific full updater target.'
Assert-Contains $installer 'l4d2_coop_custom_config.sh' 'Installer must use project-specific custom config target.'
Assert-Contains $installer 'l4d2_coop_custom_config_data' 'Installer must use a project-specific custom data directory.'

Assert-NotContains $update '$HOME/custom_config.sh' 'Normal updater must not prefer the shared HOME custom_config.sh.'
Assert-NotContains $fullUpdate '$HOME/custom_config.sh' 'Full updater must not prefer the shared HOME custom_config.sh.'
Assert-Contains $update 'l4d2_coop_custom_config.sh' 'Normal updater must look for the project-specific custom config name.'
Assert-Contains $fullUpdate 'l4d2_coop_custom_config.sh' 'Full updater must look for the project-specific custom config name.'
Assert-Contains $update 'CUSTOM_DATA_DIR="${CUSTOM_DATA_DIR:-$script_dir/l4d2_coop_custom_config_data}"' 'Normal updater must default custom data to its project-specific script directory.'
Assert-Contains $fullUpdate 'CUSTOM_DATA_DIR="${CUSTOM_DATA_DIR:-$script_dir/l4d2_coop_custom_config_data}"' 'Full updater must default custom data to its project-specific script directory.'

Assert-Contains $customConfig 'l4d2_coop_custom_config_data' 'Custom config must use a project-specific default data directory.'

Write-Host 'release updater naming checks passed'
