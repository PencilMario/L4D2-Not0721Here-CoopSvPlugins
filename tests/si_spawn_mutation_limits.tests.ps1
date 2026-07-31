$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repo 'addons/sourcemod/scripting/Si_SpawnSetting.sp'
$docsPath = Join-Path $repo 'Docs/readme.md'

$source = Get-Content -Raw -LiteralPath $sourcePath
$docs = Get-Content -Raw -LiteralPath $docsPath
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

Require-SourcePattern 'FindConVar\("mp_gamemode"\)' 'mp_gamemode ConVar lookup is missing'
Require-SourcePattern 'HookConVarChange\(g_cvGameMode,\s*ConVarChanged_GameMode\)' 'mp_gamemode change hook is missing'
Require-SourcePattern 'public\s+void\s+ConVarChanged_GameMode[\s\S]*?RefreshDirectorSettings\(\)' 'game-mode callback does not refresh Director settings'

Require-SourcePattern 'StrEqual\(gameMode,\s*"mutation17",\s*false\)[\s\S]*?allocationOrder\[1\]\s*=\s*\{5\}' 'Mutation 17 must allocate Jockey only'
Require-SourcePattern 'StrEqual\(gameMode,\s*"mutation16",\s*false\)[\s\S]*?allocationOrder\[2\]\s*=\s*\{2,\s*4\}' 'Mutation 16 must alternate Boomer then Spitter'
Require-SourcePattern 'StrEqual\(gameMode,\s*"mutation11",\s*false\)[\s\S]*?allocationOrder\[1\]\s*=\s*\{3\}' 'Mutation 11 must allocate Hunter only'
Require-SourcePattern 'if\s*\(CalculateMutationClassLimits\(maxSpecials\)\)\s*return;' 'mutation allocator must precede the general allocator'

if ($source -match '(?is)CalculateMutationClassLimits[\s\S]*?(?:Min|Clamp)[^\r\n]*14') {
    $errors.Add('mutation allocation must not clamp the engine 14-per-class limit in plugin code')
}

foreach ($requiredDocText in @('Mutation17', 'Mutation16', 'Mutation11', '14', '28')) {
    if (-not $docs.Contains($requiredDocText)) {
        $errors.Add("documentation is missing $requiredDocText")
    }
}

if ($errors.Count -gt 0) {
    throw "SI spawn mutation contract failed:`n$($errors -join "`n")"
}

'SI spawn mutation contract passed: 3 mode mappings, hot refresh, engine-limit documentation'
