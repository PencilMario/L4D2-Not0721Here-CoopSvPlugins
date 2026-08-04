$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/maphint_translator.sp'
$certPath = Join-Path $repo 'addons/sourcemod/configs/ripext/ca-bundle.crt'

if (-not (Test-Path -LiteralPath $sourcePath)) { throw 'maphint_translator source is missing' }

$source = Get-Content -Raw -LiteralPath $sourcePath
if (-not $source.Contains('#include <ripext>')) { throw 'maphint_translator no longer uses RIPExt' }
if (-not $source.Contains('https://api.deepseek.com/chat/completions')) { throw 'DeepSeek HTTPS endpoint contract changed' }
if (-not $source.Contains('sm_maphint_translate_deepl_key')) { throw 'DeepL key ConVar is missing' }
if (-not $source.Contains('https://api-free.deepl.com/v2/translate')) { throw 'DeepL Free endpoint is not the default' }
if (-not $source.Contains('DeepL-Auth-Key %s')) { throw 'DeepL authorization contract is missing' }
if (-not $source.Contains('body.SetString("target_lang", "ZH-HANS")')) { throw 'DeepL target language contract is missing' }
if (-not $source.Contains('OnDeepLTranslationResponse')) { throw 'DeepL response callback is missing' }
if (-not $source.Contains('StartDeepLTranslation(sourceText)')) { throw 'DeepSeek terminal failure does not start DeepL' }
if (-not $source.Contains('sm_maphint_translate_progress')) { throw 'progress ConVar is missing' }
if (-not $source.Contains('StringMap g_startupTranslationTexts')) { throw 'unique startup translation tracking is missing' }
if (-not $source.Contains('ScheduleEntityTranslation(entity, 0, true)')) { throw 'map-start scans are not tagged' }
if (-not $source.Contains('ScheduleEntityTranslation(entity, 0, false)')) { throw 'runtime scans are not excluded' }
if (-not $source.Contains('int processing = g_startupTotal - g_startupSucceeded - g_startupFailed')) { throw 'processing count contract is missing' }
if (-not $source.Contains('[地图翻译] 正在翻译:%s\n总计: %i, 成功: %i, 失败: %i, 处理中: %i')) { throw 'progress hint format changed' }
if (-not $source.Contains("json[i] == '\r'")) { throw 'JSON parser does not skip carriage returns' }
if (-not $source.Contains("json[i] == '\n'")) { throw 'JSON parser does not skip line feeds' }
if (-not $source.Contains('int out = 0;')) { throw 'JSON parser output index is not initialized' }

if (-not (Test-Path -LiteralPath $certPath)) {
    throw 'missing RIPExt CA bundle: addons/sourcemod/configs/ripext/ca-bundle.crt'
}

$cert = Get-Content -Raw -LiteralPath $certPath
if (-not $cert.Contains('-----BEGIN CERTIFICATE-----')) { throw 'RIPExt CA bundle has no certificate blocks' }
if (-not $cert.Contains('-----END CERTIFICATE-----')) { throw 'RIPExt CA bundle has incomplete certificate blocks' }

'maphint_translator RIPExt contract passed'
