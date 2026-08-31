$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$source = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver.sp')
$state = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/state.inc')
$convars = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/convars.inc')
$botThink = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/bot_think.inc')
$rescue = Get-Content -Raw -LiteralPath (Join-Path $repo 'addons/sourcemod/scripting/l4d2_sb_ai_improver/rescue.inc')
$sharedPlugins = Get-Content -Raw -LiteralPath (Join-Path $repo 'cfg/cfgogl/versus_isfullshit/shared_plugins.cfg')
$versus = Get-Content -Raw -LiteralPath (Join-Path $repo 'cfg/cfgogl/versus_isfullshit/versus.cfg')

function Require-Text([string] $Text, [string] $Needle, [string] $Message) {
    if (-not $Text.Contains($Needle)) {
        throw $Message
    }
}

function Require-Pattern([string] $Text, [string] $Pattern, [string] $Message) {
    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

Require-Pattern $state 'ConVar g_hCvar_HelpPinnedFriend_ReactionBots' 'The reaction-bot ConVar handle is missing.'
Require-Pattern $state 'int g_iCvar_HelpPinnedFriend_ReactionBots' 'The cached reaction-bot ConVar value is missing.'
Require-Pattern $convars 'CreateConVar\("ib_help_pinned_reaction_bots",\s*"2"' 'The reaction-bot ConVar must default to 2.'
Require-Pattern $convars 'ib_help_pinned_reaction_bots[^\n]*0:\s*Plugin does not process this reaction' 'The reaction-bot ConVar must document that 0 disables plugin reaction.'
Require-Text $convars 'g_hCvar_HelpPinnedFriend_ReactionBots.AddChangeHook(OnConVarChanged);' 'The reaction-bot ConVar must refresh when changed.'
Require-Pattern $convars 'g_iCvar_HelpPinnedFriend_ReactionBots\s*=\s*g_hCvar_HelpPinnedFriend_ReactionBots\.IntValue;' 'The reaction-bot ConVar cache assignment is missing.'

Require-Text $rescue 'bool IsPinnedFriendReactionAllowed(int iClient, int iPinnedFriend)' 'The nearest-reaction helper is missing.'
Require-Text $rescue 'g_iCvar_HelpPinnedFriend_ReactionBots <= 0' 'Zero must disable the plugin reaction helper.'
Require-Text $rescue 'IsFakeClient(i)' 'Nearest-reaction ranking must only count survivor Bots.'
Require-Text $rescue 'GetVectorDistance(g_fClientAbsOrigin[i], g_fClientAbsOrigin[iPinnedFriend], true)' 'Nearest-reaction ranking must use distance to the controlled teammate.'
Require-Text $rescue 'g_iPinnedReactionRank[iPinnedFriend][iClient]' 'Nearest-reaction ranking must use the cached rank for the current Bot.'
Require-Pattern $botThink 'IsPinnedFriendReactionAllowed\(iClient,\s*iPinnedFriend\)' 'Pinned-friend reaction must be gated by the nearest-Bot helper.'

Require-Pattern $sharedPlugins '(?m)^sm plugins load l4d2_sb_ai_improver\.smx\s*$' 'versus_isfullshit must load the Survivor Bot AI Improver again.'
Require-Pattern $versus '(?m)^confogl_addcvar ib_help_pinned_reaction_bots 2\s*$' 'versus_isfullshit must configure the default reaction-bot count.'

'l4d2_sb_ai pinned-reaction contract passed'
