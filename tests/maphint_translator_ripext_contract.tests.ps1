$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/maphint_translator.sp'
$certPath = Join-Path $repo 'addons/sourcemod/configs/ripext/ca-bundle.crt'

if (-not (Test-Path -LiteralPath $sourcePath)) { throw 'maphint_translator source is missing' }

$source = Get-Content -Raw -LiteralPath $sourcePath
if (-not $source.Contains('#include <ripext>')) { throw 'maphint_translator no longer uses RIPExt' }
if (-not $source.Contains('https://api.deepseek.com/chat/completions')) { throw 'DeepSeek HTTPS endpoint contract changed' }

if (-not (Test-Path -LiteralPath $certPath)) {
    throw 'missing RIPExt CA bundle: addons/sourcemod/configs/ripext/ca-bundle.crt'
}

$cert = Get-Content -Raw -LiteralPath $certPath
if (-not $cert.Contains('-----BEGIN CERTIFICATE-----')) { throw 'RIPExt CA bundle has no certificate blocks' }
if (-not $cert.Contains('-----END CERTIFICATE-----')) { throw 'RIPExt CA bundle has incomplete certificate blocks' }

'maphint_translator RIPExt contract passed'
