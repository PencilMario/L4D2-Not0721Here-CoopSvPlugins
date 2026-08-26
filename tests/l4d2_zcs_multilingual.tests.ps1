$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/l4d2_zcs_redux.sp'
$phrasesPath = Join-Path $repo 'addons/sourcemod/translations/l4d2_zcs_redux.phrases.txt'

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing plugin source: $sourcePath"
}

$source = Get-Content -Raw -LiteralPath $sourcePath
$errors = [System.Collections.Generic.List[string]]::new()

function Require-SourcePattern {
    param(
        [string]$Pattern,
        [string]$Message
    )

    if ($source -notmatch $Pattern) {
        $errors.Add($Message)
    }
}

function Require-PhrasePattern {
    param(
        [string]$Key,
        [string]$Message
    )

    $escapedKey = [regex]::Escape($Key)
    $pattern = '(?ms)"' + $escapedKey + '"\s*\{.*?"en"\s*"[^"]+".*?"chi"\s*"[^"]+".*?\}'
    if ($phrases -notmatch $pattern) {
        $errors.Add($Message)
    }
}

if (-not (Test-Path -LiteralPath $phrasesPath)) {
    $errors.Add("Missing translation file: $phrasesPath")
    $phrases = ''
}
else {
    $phrases = Get-Content -Raw -LiteralPath $phrasesPath
    $phraseBytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $phrasesPath))
    if ($phraseBytes.Length -lt 3 -or $phraseBytes[0] -ne 0xEF -or $phraseBytes[1] -ne 0xBB -or $phraseBytes[2] -ne 0xBF) {
        $errors.Add('Translation file must use the repository standard UTF-8 BOM.')
    }
}

Require-SourcePattern 'LoadTranslations\("l4d2_zcs_redux\.phrases"\)' 'Plugin must load its own translation file.'
Require-SourcePattern 'stock void Sub_GetTranslatedClassName\s*\(' 'Class names must have a per-client translation helper.'
Require-SourcePattern 'g_sBossPhraseKeys\[\]\[\]' 'Class translation phrase keys must be indexed by class ID.'
Require-SourcePattern 'FormatEx\(Buffer, MaxLen, "%T", g_sBossPhraseKeys\[ZClass\], Client\)' 'Class helper must pass the explicit client as the %T target.'

$messageKeys = @(
    'PLAYER_NOTIFY_KEY',
    'PLAYER_LIMITS_UP',
    'PLAYER_COOLDOWN_WAIT',
    'PLAYER_CLASSES_UP_ALLOW',
    'PLAYER_CLASSES_UP_DENY',
    'PLAYER_NOTIFY_LOCK',
    'PLAYER_SWITCH_LOCK'
)

foreach ($key in $messageKeys) {
    Require-SourcePattern ('#define\s+' + $key + '\s+"ZCS_[A-Za-z_]+' ) "$key must refer to a translation phrase key."
    Require-SourcePattern ('PrintToChat\(Client,\s*"%T",\s*' + $key + '\s*,\s*Client(?:,|\))') "$key must be sent with %T and the target Client."
}

Require-SourcePattern '#define PLAYER_HUD_TITLE\s+"ZCS_HudTitle"' 'HUD title must use a translation phrase key.'
Require-SourcePattern '#define PLAYER_HUD_LINE\s+"ZCS_HudLine"' 'HUD rows must use a translation phrase key.'
Require-SourcePattern '#define PLAYER_HUD_COOLDOWN\s+"ZCS_HudCooldown"' 'HUD cooldown marker must use a translation phrase key.'

if ($source -cmatch 'PrintToChat\([^\n]*"%t"') {
    $errors.Add('Direct client chat output must use explicit %T targets instead of global-target %t.')
}

$hud = [regex]::Match($source, '(?ms)public void Hud_ShowLimits\(\).*?\n\}').Value
if ([string]::IsNullOrEmpty($hud)) {
    $errors.Add('Could not isolate Hud_ShowLimits for the HUD contract.')
}
else {
    if ($hud -notmatch 'for\s*\(int i = 1; i <= MaxClients; i\+\+\)[\s\S]*?Handle hPanel = CreatePanel\(\)') {
        $errors.Add('HUD panels must be created inside the per-client recipient loop.')
    }
    if ($hud -notmatch 'FormatEx\([^\n]*"%T"[^\n]*PLAYER_HUD_TITLE[^\n]*i') {
        $errors.Add('HUD title must be translated for the receiving client.')
    }
    if ($hud -notmatch 'FormatEx\([^\n]*"%T"[^\n]*PLAYER_HUD_LINE[^\n]*i') {
        $errors.Add('HUD rows must be translated for the receiving client.')
    }
    if ($hud -notmatch 'SendPanelToClient\(hPanel, i, Hud_LimitsPanel') {
        $errors.Add('HUD panel must be sent to the same client it was translated for.')
    }
}

foreach ($key in @(
    'ZCS_NotifyKey',
    'ZCS_LimitsUp',
    'ZCS_CooldownWait',
    'ZCS_ClassesUpAllow',
    'ZCS_ClassesUpDeny',
    'ZCS_NotifyLock',
    'ZCS_SwitchLock',
    'ZCS_HudTitle',
    'ZCS_HudLine',
    'ZCS_HudCooldown',
    'ZCS_Class_Smoker',
    'ZCS_Class_Boomer',
    'ZCS_Class_Hunter',
    'ZCS_Class_Spitter',
    'ZCS_Class_Jockey',
    'ZCS_Class_Charger',
    'ZCS_Class_Witch',
    'ZCS_Class_Tank',
    'ZCS_Class_Survivor'
)) {
    Require-PhrasePattern $key "Translation phrase $key must contain both en and chi entries."
}

if ($source -match '#define\s+PLAYER_(NOTIFY_KEY|LIMITS_UP|COOLDOWN_WAIT|CLASSES_UP_ALLOW|CLASSES_UP_DENY|NOTIFY_LOCK|SWITCH_LOCK)\s+"\\x04') {
    $errors.Add('Player notification definitions must not contain hard-coded Chinese text.')
}

if ($source -match 'Format\(sPanelBuff,\s*sizeof\(sPanelBuff\),\s*"Infected Limits"') {
    $errors.Add('HUD must not keep a hard-coded English title.')
}

if ($errors.Count -gt 0) {
    throw "Zombie Character Select multilingual contract failed:`n$($errors -join "`n")"
}

'Zombie Character Select multilingual contract passed'
