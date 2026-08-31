$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$tankSourcePath = Join-Path $repo 'addons/sourcemod/scripting/L4D2 Hulking Tank.sp'
$smokerSourcePath = Join-Path $repo 'addons/sourcemod/scripting/L4D2 Noxious Smoker.sp'
$modeConfigPath = Join-Path $repo 'cfg/cfgogl/versus_isfullshit/versus.cfg'

foreach ($path in @($tankSourcePath, $smokerSourcePath, $modeConfigPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing required contract input: $path"
    }
}

$tankSource = Get-Content -Raw -LiteralPath $tankSourcePath
$smokerSource = Get-Content -Raw -LiteralPath $smokerSourcePath
$modeConfig = Get-Content -Raw -LiteralPath $modeConfigPath
$errors = [System.Collections.Generic.List[string]]::new()

function Require-Pattern {
    param([string]$Text, [string]$Pattern, [string]$Message)
    if ($Text -notmatch $Pattern) { $errors.Add($Message) }
}

function Require-GuardedCallCount {
    param([string]$Text, [string]$CallPattern, [int]$ExpectedCount, [string]$Name)

    $callCount = ([regex]::Matches($Text, $CallPattern)).Count
    $guardPattern = "(?ms)if\s*\(\s*GetConVarBool\(cvarAbilityStagger\)\s*\)\s*\{\s*${CallPattern}"
    $guardedCount = ([regex]::Matches($Text, $guardPattern)).Count
    if ($callCount -ne $ExpectedCount) {
        $errors.Add("$Name must retain exactly $ExpectedCount custom stagger calls; found $callCount")
    } elseif ($guardedCount -ne $ExpectedCount) {
        $errors.Add("$Name has $ExpectedCount custom stagger calls but only $guardedCount guarded calls")
    }
}

Require-Pattern $tankSource 'CreateConVar\("l4d_htm_ability_stagger",\s*"1"' 'Hulking Tank stagger control must default to enabled.'
Require-Pattern $smokerSource 'CreateConVar\("l4d_nsm_ability_stagger",\s*"1"' 'Noxious Smoker stagger control must default to enabled.'
Require-Pattern $modeConfig '(?m)^\s*confogl_addcvar\s+l4d_htm_ability_stagger\s+0\s*$' 'versus_isfullshit must disable Hulking Tank ability stagger.'
Require-Pattern $modeConfig '(?m)^\s*confogl_addcvar\s+l4d_nsm_ability_stagger\s+0\s*$' 'versus_isfullshit must disable Noxious Smoker ability stagger.'

Require-GuardedCallCount $tankSource 'SDKCall\(MySDKCall,' 3 'Hulking Tank'
Require-GuardedCallCount $smokerSource 'SDKCall\(sdkCallFling,' 4 'Noxious Smoker Fling'
Require-GuardedCallCount $smokerSource 'SDKCall\(sdkOnStaggered,' 1 'Noxious Smoker direct stagger'

Require-Pattern $tankSource '(?ms)stock void Fling_TitanFist\(.*?GetConVarBool\(cvarAbilityStagger\).*?\}\s*Damage_TitanFist\(' 'Hulking Tank must retain Damage_TitanFist outside its optional Fling.'
Require-Pattern $tankSource '(?ms)stock void Fling_TitanicBellow\(.*?GetConVarBool\(cvarAbilityStagger\).*?\}\s*Damage_TitanicBellow\(' 'Hulking Tank must retain Damage_TitanicBellow outside its optional Fling.'
Require-Pattern $tankSource '(?ms)stock void Fling_SmoulderingEarth\(.*?GetConVarBool\(cvarAbilityStagger\).*?\}\s*Damage_SmoulderingEarth\(' 'Hulking Tank must retain Damage_SmoulderingEarth outside its optional Fling.'

Require-Pattern $tankSource '(?ms)stock void Fling_TitanFist\(.*?GetConVarBool\(cvarAbilityStagger\)\s*\)\s*\{\s*SDKCall\(MySDKCall,\s*victim,' 'Titan Fist Fling must be individually guarded.'
Require-Pattern $tankSource '(?ms)stock void Fling_TitanicBellow\(.*?GetConVarBool\(cvarAbilityStagger\)\s*\)\s*\{\s*SDKCall\(MySDKCall,\s*target,' 'Titanic Bellow Fling must be individually guarded.'
Require-Pattern $tankSource '(?ms)stock void Fling_SmoulderingEarth\(.*?GetConVarBool\(cvarAbilityStagger\)\s*\)\s*\{\s*SDKCall\(MySDKCall,\s*victim,' 'Smouldering Earth Fling must be individually guarded.'

Require-Pattern $smokerSource '(?ms)public Action:SmokerAbility_MethaneBlast\(.*?GetConVarBool\(cvarAbilityStagger\).*?SDKCall\(sdkCallFling,.*?GetConVarBool\(cvarAbilityStagger\).*?SDKCall\(sdkCallFling,' 'Both Methane Blast ranges must be individually guarded.'
Require-Pattern $smokerSource '(?ms)public Action:SmokerAbility_MethaneStrike\(.*?GetConVarBool\(cvarAbilityStagger\).*?SDKCall\(sdkOnStaggered,' 'Methane Strike must be individually guarded.'
Require-Pattern $smokerSource '(?ms)public SmokerAbility_TongueWhip\(.*?GetConVarBool\(cvarAbilityStagger\).*?SDKCall\(sdkCallFling,' 'Tongue Whip must be individually guarded.'
Require-Pattern $smokerSource '(?ms)public Action:SmokerAbility_VoidPocket\(.*?GetConVarBool\(cvarAbilityStagger\).*?SDKCall\(sdkCallFling,' 'Void Pocket must be individually guarded.'

Require-Pattern $smokerSource '(?ms)public Action:SmokerAbility_MethaneBlast\(.*?DamageHook\(victim, smoker, damage\);.*?if\s*\(\s*GetConVarBool\(cvarAbilityStagger\)' 'Methane Blast damage must remain outside its optional Fling.'
Require-Pattern $smokerSource '(?ms)public SmokerAbility_TongueWhip\(.*?DamageHook\(target, smoker, damage\);.*?if\s*\(\s*GetConVarBool\(cvarAbilityStagger\)' 'Tongue Whip damage must remain outside its optional Fling.'

if ($smokerSource -notmatch '(?ms)SDKCall\(sdkCallFling,.*?\n\s*\}') {
    $errors.Add('Noxious Smoker source must retain the existing Fling code inside a conditional block.')
}

if ($errors.Count -gt 0) {
    throw "Versus ability stagger contract failed:`n$($errors -join "`n")"
}

'Versus ability stagger contract passed'
