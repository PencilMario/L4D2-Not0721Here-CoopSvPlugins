/*
*	Incapped Weapons Patch
*	Copyright (C) 2023 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



#define PLUGIN_VERSION 		"1.30"

/*=======================================================================================
	Plugin Info:

*	Name	:	[L4D & L4D2] Incapped Weapons Patch
*	Author	:	SilverShot
*	Descrp	:	Patches the game to allow using Weapons while Incapped, instead of changing weapons scripts.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=322859
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.30 (18-Aug-2023)
	- Added cvar "l4d_incapped_weapons_health" to set a players main health when they revive themselves. Requested by "Shao".
	- Now sets the players temporary health on revive to "survivor_revive_health" games cvar value.

1.29 (19-Jun-2023)
	- Fixed "CanDeploy" byte mis-match error. Thanks to "Mika Misori" for reporting.

1.28 (10-Mar-2023)
	- L4D2: Fixed grenade throwing animation not being blocked. Thanks to "BystanderZK" for reporting.

1.27 (20-Feb-2023)
	- L4D2: Fixed Survivors not taking damage from incapped players when reviving them. Thanks to "Lux" and "Psyk0tik" for help.
	- L4D2: GameData file updated.

1.26 (19-Feb-2023)
	- Various small fixes with late loading and unloading the plugin.
	- Fixed cvar "l4d_incapped_weapons_friendly" not correctly calculating damage applied to Survivors from weapons.
	- L4D2: Fixed Survivors not taking damage from incapped players. Thanks to "BystanderZK" for reporting and "Marttt" for testing on Linux.
	- L4D2: GameData file updated.

1.25 (10-Feb-2023)
	- Fixed error when "CanDeploy" is already patched, for whatever reason. Thanks to "knifeeeee" for reporting.

1.24 (24-Jan-2023)
	- Added cvar "l4d_incapped_weapons_friendly" to scale friendly fire damage from incapped Survivors. Requested by "choppledpickusfungus".

1.23 (08-Jan-2023)
	- Plugin now requires SourceMod 1.11 version of DHooks.
	- Plugin now requires "Left 4 DHooks Direct" plugin, used for Adrenaline and Reviving.
	- Fixed not always healing or reviving. Thanks to "BystanderZK" for reporting.
	- Fixed not always allowing pills and adrenaline while incapped, when health was above 100. Thanks to "apples1949" for reporting.
	- Added Simplified Chinese translations. Thanks to "apples1949" for providing.
	- Translations updated to use a better title instead of "[Revive]" when healing.
	- GameData file updated.

1.22 (24-Dec-2022)
	- Fixed printing the color codes instead of using them when translations are missing. Thanks to "HarryPotter" for reporting.
	- Fixed displaying hints about using Pills/Adrenaline when they are restricted. Thanks to "HarryPotter" for reporting.
	- Fixed infinite animation loop when holding mouse1 with Adrenaline. Thanks to "ForTheSakura" for reporting.
	- Fixed displaying the wrong hint for Adrenaline when revive option was set.

1.21 (21-Dec-2022)
	- Added cvars "l4d_incapped_weapons_delay_pills" and "l4d_incapped_weapons_delay_adren" to set a delay before reviving. Requested by "BystanderZK".
	- Added cvar "l4d_incapped_weapons_delay_text" to optionally display a hint when using a delayed revive.
	- Added cvar "l4d_incapped_weapons_heal_text" to display a hint about using pills or adrenaline when incapacitated.
	- Added optional translations support for delayed revive.

1.20 (12-Dec-2022)
	- Added cvar "l4d_incapped_weapons_heal_revive" to control if players should revive into black and white status. Requested by "BystanderZK".
	- Fixed cvar "l4d_incapped_weapons_throw" having inverted logic. Thanks to "BystanderZK" for reporting.
	- Fixed the PipeBomb effects not displaying. Thanks to "BystanderZK" for reporting.
	- Fixed taking pills in L4D1 not healing or reviving.
	- These changes are compatible with the "Heartbeat" plugin.

1.19 (09-Dec-2022)
	- Forgot to remove debug messages printing to chat. Thanks to "NoroHime" for reporting.

1.18 (06-Dec-2022)
	- Added extra checks when using Pills and Adrenaline.
	- Fixed equipping melee weapons reducing all damage given to other Survivors. Thanks to "gabuch2" for reporting.

1.17 (05-Dec-2022)
	- Fixed unhooking the wrong Think function, breaking the "pain_pills_health_threshold" cvar.
	- Changed cvars "l4d_incapped_weapons_heal_adren" and "l4d_incapped_weapons_heal_pills" to accept "-1" which will revive a player.

1.16 (05-Dec-2022)
	- Added feature to allow Pills and Adrenaline to be used while incapped. Requires the "Left 4 DHooks" plugin.
	- Added cvars "l4d_incapped_weapons_heal_adren" and "l4d_incapped_weapons_heal_pills" to control healing amount while incapped.

1.15 (22-Nov-2022)
	- Fixed cvar "l4d_incapped_weapons_throw" not preventing standing up animation when plugin is late loaded. Thanks to "TBK Duy" for reporting.

1.14 (12-Nov-2022)
	- Added cvar "l4d_incapped_weapons_throw" to optionally prevent the standing up animation when throwing grenades.
	- Now optionally uses "Left 4 DHooks" plugin to prevent standing up animation when throwing grenades.

1.13a (09-Jul-2021)
	- L4D2: Fixed GameData file from the "2.2.2.0" update.

1.13 (16-Jun-2021)
	- L4D2: Optimized plugin by resetting Melee damage hooks on map end and round start.
	- L4D2: Compatibility update for "2.2.1.3" update. Thanks to "Dragokas" for fixing.
	- GameData .txt file updated.

1.12 (08-Mar-2021)
	- Added cvar "l4d_incapped_weapons_melee" to control Melee weapon damage to Survivors. Thanks to "Mystik Spiral" for reporting.

1.11 (15-Jan-2021)
	- Fixed weapons being blocked when incapped and changing team. Thanks to "HarryPotter" for reporting.

1.10 (10-May-2020)
	- Added better error log message when gamedata file is missing.
	- Extra checks to prevent "IsAllowedGameMode" throwing errors.

1.9 (12-Apr-2020)
	- Now keeps the active weapon selected unless it's restricted.
	- Fixed not being able to switch to melee weapons.
	- Fixed pistols possibly disappearing sometimes.
	- Fixed potential of duped pistols when dropped after incap.
	- Extra checks to prevent "IsAllowedGameMode" throwing errors.

1.8 (09-Apr-2020)
	- Fixed again not always restricting weapons correctly on incap. Thanks to "MasterMind420" for reporting.

1.7 (08-Apr-2020)
	- Fixed not equipping melee weapons when allowed on incap.

1.6 (08-Apr-2020)
	- Fixed breaking pistols, due to the last update.

1.5 (08-Apr-2020)
	- Fixed ammo being wiped when incapped, due to 1.3 update. Thanks to "Dragokas" for reporting.
	- Fixed not always restricting weapons correctly on incap. Thanks to "MasterMind420" for reporting.

1.4 (07-Apr-2020)
	- Fixed throwing a pistol when dual wielding. Thanks to "MasterMind420" for reporting.

1.3 (07-Apr-2020)
	- Fixed not equipping a valid weapon when the last equipped weapon was restricted.
	- Removed the ability to block pistols.
	- Thanks to "MasterMind420" for reporting.

1.2 (07-Apr-2020)
	- Fixed L4D1 Linux crashing. Only the plugin updated. Thanks to "Dragokas" for testing.

1.1 (07-Apr-2020)
	- Fixed hooking the L4D2 pistol cvar in L4D1. Thanks to "Alliance" for reporting.

1.0 (06-Apr-2020)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <left4dhooks>

#define CVAR_FLAGS			FCVAR_NOTIFY
#define GAMEDATA			"l4d_incapped_weapons"

#define PARTICLE_FUSE		"weapon_pipebomb_fuse"
#define PARTICLE_LIGHT		"weapon_pipebomb_blinking_light"

#define TIMER_REVIVE		0.2		// How often the timer ticks for delayed revive
#define HEAL_ANIM_ADREN		1.3		// How long the healing animation lasts before applying the heal
#define HEAL_ANIM_PILLS		0.6		// How long the healing animation lasts before applying the heal
#define DELAY_HINT			1.0		// Delay incapacitated event hint message


ConVar g_hCvarAllow, g_hCvarMPGameMode, g_hCvarMaxIncap, g_hCvarIncapHealth, g_hCvarReviveHealth, g_hCvarReviveTemp, g_hCvarDelayAdren, g_hCvarDelayPills, g_hCvarDelayText, g_hCvarHealAdren, g_hCvarHealPills,
	g_hCvarHealRevive, g_hCvarHealText, g_hCvarFriendly, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarMelee, g_hCvarPist, g_hCvarRest, g_hCvarThrow;
bool g_bTranslations, g_bMapStarted, g_bLeft4Dead2, g_bHeartbeat, g_bGrenadeFix, g_bLateLoad, g_bCvarAllow, g_bCvarThrow;
int g_iCvarDelayText, g_iCvarMaxIncap, g_iCvarIncapHealth, g_iCvarReviveHealth, g_iCvarReviveTemp, g_iCvarHealAdren, g_iCvarHealPills, g_iCvarHealText, g_iCvarHealRevive, g_iCvarPist, g_iCvarMelee, g_iHint[MAXPLAYERS+1];
float g_fCvarDelayAdren, g_fCvarDelayPills, g_fCvarFriendly, g_fReviveTimer[MAXPLAYERS+1];
Handle g_hTimerUseHealth[MAXPLAYERS+1];
Handle g_hTimerRevive[MAXPLAYERS+1];
bool g_bHasHeal[MAXPLAYERS+1];

ArrayList g_ByteSaved_Deploy, g_ByteSaved_OnIncap, g_ByteSaved_FireBullet;
Address g_Address_Deploy, g_Address_OnIncap, g_Address_FireBullet;
DynamicDetour g_hDetourFireBullet, g_hDetourCanUseOnSelf;

ArrayList g_aRestrict;
StringMap g_aWeaponIDs;

// From "Heartbeat" plugin
native int Heartbeat_GetRevives(int client);
native void Heartbeat_SetRevives(int client, int reviveCount, bool reviveLogic = true);



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Incapped Weapons Patch",
	author = "SilverShot",
	description = "Patches the game to allow using Weapons while Incapped, instead of changing weapons scripts.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=322859"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead ) g_bLeft4Dead2 = false;
	else if( test == Engine_Left4Dead2 ) g_bLeft4Dead2 = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	MarkNativeAsOptional("Heartbeat_GetRevives");
	MarkNativeAsOptional("Heartbeat_SetRevives");

	g_bLateLoad = late;

	RegPluginLibrary("l4d_incapped_weapons");

	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if( strcmp(name, "l4d_heartbeat") == 0 )
	{
		g_bHeartbeat = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if( strcmp(name, "l4d_heartbeat") == 0 )
	{
		g_bHeartbeat = false;
	}
}

public void OnAllPluginsLoaded()
{
	if( FindConVar("incapped_weapons_enable") != null )
	{
		SetFailState("Delete the old \"Incapped Weapons\" plugin to run this one.");
	}

	g_bGrenadeFix = FindConVar("l4d_unlimited_grenades_version") != null;
}

public void OnPluginStart()
{
	// ====================================================================================================
	// GAMEDATA
	// ====================================================================================================
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA);
	if( FileExists(sPath) == false ) SetFailState("\n==========\nMissing required file: \"%s\".\nRead installation instructions again.\n==========", sPath);

	Handle hGameData = LoadGameConfigFile(GAMEDATA);
	if( hGameData == null ) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);



	// Patch deploy - To allow weapons to be equipped while incapped
	int iOffset = GameConfGetOffset(hGameData, "CanDeploy_Offset");
	if( iOffset == -1 ) SetFailState("Failed to load \"CanDeploy_Offset\" offset.");

	int iByteMatch = GameConfGetOffset(hGameData, "CanDeploy_Byte");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"CanDeploy_Byte\" byte.");

	int iByteCount = GameConfGetOffset(hGameData, "CanDeploy_Count");
	if( iByteCount == -1 ) SetFailState("Failed to load \"CanDeploy_Count\" count.");

	g_Address_Deploy = GameConfGetAddress(hGameData, "CanDeploy");
	if( !g_Address_Deploy ) SetFailState("Failed to load \"CanDeploy\" address.");

	g_Address_Deploy += view_as<Address>(iOffset);
	g_ByteSaved_Deploy = new ArrayList();

	for( int i = 0; i < iByteCount; i++ )
	{
		g_ByteSaved_Deploy.Push(LoadFromAddress(g_Address_Deploy + view_as<Address>(i), NumberType_Int8));
	}

	if( g_ByteSaved_Deploy.Get(0) != iByteMatch )
	{
		if( g_ByteSaved_Deploy.Get(0) != (iByteCount == 1 ? 0x78 : 0x90) ) SetFailState("Failed to load 'CanDeploy', byte mis-match @ %d (0x%02X != 0x%02X)", iOffset, g_ByteSaved_Deploy.Get(0), iByteMatch);
	}



	if( g_bLeft4Dead2 )
	{
		// Patch melee - To allow melee weapons to be used while incapped
		iOffset = GameConfGetOffset(hGameData, "OnIncap_Offset");
		if( iOffset == -1 ) SetFailState("Failed to load \"OnIncap_Offset\" offset.");

		iByteMatch = GameConfGetOffset(hGameData, "OnIncap_Byte");
		if( iByteMatch == -1 ) SetFailState("Failed to load \"OnIncap_Byte\" byte.");

		iByteCount = GameConfGetOffset(hGameData, "OnIncap_Count");
		if( iByteCount == -1 ) SetFailState("Failed to load \"OnIncap_Count\" count.");

		g_Address_OnIncap = GameConfGetAddress(hGameData, "OnIncapacitatedAsSurvivor");
		if( !g_Address_OnIncap ) SetFailState("Failed to load \"OnIncapacitatedAsSurvivor\" address.");

		g_Address_OnIncap += view_as<Address>(iOffset);
		g_ByteSaved_OnIncap = new ArrayList();

		for( int i = 0; i < iByteCount; i++ )
		{
			g_ByteSaved_OnIncap.Push(LoadFromAddress(g_Address_OnIncap + view_as<Address>(i), NumberType_Int8));
		}

		if( g_ByteSaved_OnIncap.Get(0) != iByteMatch ) SetFailState("Failed to load 'OnIncap', byte mis-match @ %d (0x%02X != 0x%02X)", iOffset, g_ByteSaved_OnIncap.Get(0), iByteMatch);



		// Patch FireBullet - To allow shooting Survivors while incapped
		iOffset = GameConfGetOffset(hGameData, "FireBullet_Offset");
		if( iOffset == -1 ) SetFailState("Failed to load \"FireBullet_Offset\" offset.");

		iByteMatch = GameConfGetOffset(hGameData, "FireBullet_Byte");
		if( iByteMatch == -1 ) SetFailState("Failed to load \"FireBullet_Byte\" byte.");

		iByteCount = GameConfGetOffset(hGameData, "FireBullet_Count");
		if( iByteCount == -1 ) SetFailState("Failed to load \"FireBullet_Count\" count.");

		g_Address_FireBullet = GameConfGetAddress(hGameData, "FireBullet");
		if( !g_Address_FireBullet ) SetFailState("Failed to load \"FireBullet\" address.");

		g_Address_FireBullet += view_as<Address>(iOffset);
		g_ByteSaved_FireBullet = new ArrayList();

		for( int i = 0; i < iByteCount; i++ )
		{
			g_ByteSaved_FireBullet.Push(LoadFromAddress(g_Address_FireBullet + view_as<Address>(i), NumberType_Int8));
		}

		if( g_ByteSaved_FireBullet.Get(0) != iByteMatch ) SetFailState("Failed to load 'FireBullet', byte mis-match @ %d (0x%02X != 0x%02X)", iOffset, g_ByteSaved_FireBullet.Get(0), iByteMatch);
	}



	// ====================================================================================================
	// DETOURS
	// ====================================================================================================
	if( g_bLeft4Dead2 )
	{
		g_hDetourFireBullet = DynamicDetour.FromConf(hGameData, "IW::CTerrorGun::FireBullet");
		if( !g_hDetourFireBullet ) SetFailState("Failed to find \"CTerrorGun::FireBullet\" signature.");

		g_hDetourCanUseOnSelf = DynamicDetour.FromConf(hGameData, "IW::CPainPills::CanUseOnSelf");
		if( !g_hDetourCanUseOnSelf ) SetFailState("Failed to find \"CPainPills::CanUseOnSelf\" signature.");
	}
	else
	{
		g_hDetourCanUseOnSelf = DynamicDetour.FromConf(hGameData, "IW::CPainPills::PrimaryAttack");
		if( !g_hDetourCanUseOnSelf ) SetFailState("Failed to find \"CPainPills::PrimaryAttack\" signature.");
	}

	delete hGameData;



	// ====================================================================================================
	// CVARS
	// ====================================================================================================
	g_hCvarAllow =			CreateConVar(	"l4d_incapped_weapons_allow",			"1",					"0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	g_hCvarModes =			CreateConVar(	"l4d_incapped_weapons_modes",			"",						"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar(	"l4d_incapped_weapons_modes_off",		"",						"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar(	"l4d_incapped_weapons_modes_tog",		"0",					"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );

	if( g_bLeft4Dead2 )
		g_hCvarDelayAdren =	CreateConVar(	"l4d_incapped_weapons_delay_adren",		"5.0",					"0.0=Off. How many seconds a player must wait after using Adrenaline to be revived.", CVAR_FLAGS);
	g_hCvarDelayPills =		CreateConVar(	"l4d_incapped_weapons_delay_pills",		"5.0",					"0.0=Off. How many seconds a player must wait after using Pills to be revived.", CVAR_FLAGS);
	g_hCvarDelayText =		CreateConVar(	"l4d_incapped_weapons_delay_text",		"2",					"0=Off. 1=Print to chat. 2=Print to hint box. Display to player how long until they are revived, when using a _delay cvar.", CVAR_FLAGS);

	g_hCvarFriendly =		CreateConVar(	"l4d_incapped_weapons_friendly",		"1.0",					"0.0=None. 1.0=Default damage. Scales an incapped Survivors friendly fire damage to other Survivors.", CVAR_FLAGS);

	if( g_bLeft4Dead2 )
		g_hCvarHealAdren =	CreateConVar(	"l4d_incapped_weapons_heal_adren",		"50",					"-1=Revive player. 0=Off. How much to heal a player when they use Adrenaline whilst incapped.", CVAR_FLAGS);
	g_hCvarHealPills =		CreateConVar(	"l4d_incapped_weapons_heal_pills",		"50",					"-1=Revive player. 0=Off. How much to heal a player when they use Pain Pills whilst incapped.", CVAR_FLAGS);
	g_hCvarHealRevive =		CreateConVar(	"l4d_incapped_weapons_heal_revive",		"0",					"0=Off. Should player enter black and white status when reviving using: 1=Pills. 2=Adrenaline. 3=Both.", CVAR_FLAGS);
	g_hCvarHealText =		CreateConVar(	"l4d_incapped_weapons_heal_text",		"1",					"0=Off. 1=Print to chat. 2=Print to hint box. Print a message when incapacitated that Pills/Adrenaline can be used to heal/revive.", CVAR_FLAGS);

	if( g_bLeft4Dead2 )
	{
		g_hCvarMelee =		CreateConVar(	"l4d_incapped_weapons_melee",			"0",					"0=No friendly fire. 1=Allow friendly fire. When using Melee weapons should they hurt other Survivors.", CVAR_FLAGS);
		g_hCvarPist =		CreateConVar(	"l4d_incapped_weapons_pistol",			"0",					"0=Don't give pistol (allows Melee weapons to be used). 1=Give pistol (game default).", CVAR_FLAGS);
		g_hCvarRest =		CreateConVar(	"l4d_incapped_weapons_restrict",		"12,24,30,31",			"Empty string to allow all. Prevent these weapon/item IDs from being used while incapped. See plugin post for details.", CVAR_FLAGS);
	} else {
		g_hCvarRest =		CreateConVar(	"l4d_incapped_weapons_restrict",		"8",					"Empty string to allow all. Prevent these weapon/item IDs from being used while incapped. See plugin post for details.", CVAR_FLAGS);
	}

	g_hCvarReviveHealth =	CreateConVar(	"l4d_incapped_weapons_health",			"30",					"How much health to give a player when they revive themselves.", CVAR_FLAGS);
	g_hCvarThrow =			CreateConVar(	"l4d_incapped_weapons_throw",			"1",					"0=Block grenade throwing animation to prevent standing up during throw (requires Left4DHooks plugin). 1=Allow throwing animation.", CVAR_FLAGS);

	CreateConVar(							"l4d_incapped_weapons_version",			PLUGIN_VERSION,			"Incapped Weapons plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,					"l4d_incapped_weapons");

	g_hCvarMaxIncap = FindConVar("survivor_max_incapacitated_count");
	g_hCvarReviveTemp = FindConVar("survivor_revive_health");
	g_hCvarIncapHealth = FindConVar("survivor_incap_health");
	g_hCvarMPGameMode = FindConVar("mp_gamemode");

	g_hCvarFriendly.AddChangeHook(ConVarChanged_Cvars);

	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);

	if( g_bLeft4Dead2 )
	{
		g_hCvarDelayAdren.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarHealAdren.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarPist.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarMelee.AddChangeHook(ConVarChanged_Cvars);
	}
	g_hCvarDelayPills.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDelayText.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHealPills.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHealRevive.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHealText.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarMaxIncap.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarIncapHealth.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarReviveHealth.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarReviveTemp.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarRest.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarThrow.AddChangeHook(ConVarChanged_Cvars);



	// ====================================================================================================
	// TRANSLATIONS
	// ====================================================================================================
	BuildPath(Path_SM, sPath, sizeof(sPath), "translations/incapped_weapons.phrases.txt");
	if( FileExists(sPath) )
	{
		g_bTranslations = true;
		LoadTranslations("incapped_weapons.phrases");
	}



	// ====================================================================================================
	// WEAPON RESTRICTION
	// ====================================================================================================
	// Taken from "Left 4 DHooks Direct", see for complete list.
	g_aWeaponIDs = new StringMap();

	if( g_bLeft4Dead2 )
	{
		g_aWeaponIDs.SetValue("weapon_pistol",						1);
		g_aWeaponIDs.SetValue("weapon_smg",							2);
		g_aWeaponIDs.SetValue("weapon_pumpshotgun",					3);
		g_aWeaponIDs.SetValue("weapon_autoshotgun",					4);
		g_aWeaponIDs.SetValue("weapon_rifle",						5);
		g_aWeaponIDs.SetValue("weapon_hunting_rifle",				6);
		g_aWeaponIDs.SetValue("weapon_smg_silenced",				7);
		g_aWeaponIDs.SetValue("weapon_shotgun_chrome",				8);
		g_aWeaponIDs.SetValue("weapon_rifle_desert",				9);
		g_aWeaponIDs.SetValue("weapon_sniper_military",				10);
		g_aWeaponIDs.SetValue("weapon_shotgun_spas",				11);
		g_aWeaponIDs.SetValue("weapon_first_aid_kit",				12);
		g_aWeaponIDs.SetValue("weapon_molotov",						13);
		g_aWeaponIDs.SetValue("weapon_pipe_bomb",					14);
		g_aWeaponIDs.SetValue("weapon_pain_pills",					15);
		g_aWeaponIDs.SetValue("weapon_melee",						19);
		g_aWeaponIDs.SetValue("weapon_chainsaw",					20);
		g_aWeaponIDs.SetValue("weapon_grenade_launcher",			21);
		g_aWeaponIDs.SetValue("weapon_adrenaline",					23);
		g_aWeaponIDs.SetValue("weapon_defibrillator",				24);
		g_aWeaponIDs.SetValue("weapon_vomitjar",					25);
		g_aWeaponIDs.SetValue("weapon_rifle_ak47",					26);
		g_aWeaponIDs.SetValue("weapon_upgradepack_incendiary",		30);
		g_aWeaponIDs.SetValue("weapon_upgradepack_explosive",		31);
		g_aWeaponIDs.SetValue("weapon_pistol_magnum",				32);
		g_aWeaponIDs.SetValue("weapon_smg_mp5",						33);
		g_aWeaponIDs.SetValue("weapon_rifle_sg552",					34);
		g_aWeaponIDs.SetValue("weapon_sniper_awp",					35);
		g_aWeaponIDs.SetValue("weapon_sniper_scout",				36);
		g_aWeaponIDs.SetValue("weapon_rifle_m60",					37);
	} else {
		g_aWeaponIDs.SetValue("weapon_pistol",						1);
		g_aWeaponIDs.SetValue("weapon_smg",							2);
		g_aWeaponIDs.SetValue("weapon_pumpshotgun",					3);
		g_aWeaponIDs.SetValue("weapon_autoshotgun",					4);
		g_aWeaponIDs.SetValue("weapon_rifle",						5);
		g_aWeaponIDs.SetValue("weapon_hunting_rifle",				6);
		g_aWeaponIDs.SetValue("weapon_first_aid_kit",				8);
		g_aWeaponIDs.SetValue("weapon_molotov",						9);
		g_aWeaponIDs.SetValue("weapon_pipe_bomb",					10);
		g_aWeaponIDs.SetValue("weapon_pain_pills",					12);
	}



	// ====================================================================================================
	// LATE LOAD
	// ====================================================================================================
	if( g_bLateLoad )
	{
		IsAllowed();

		g_bHeartbeat = LibraryExists("l4d_heartbeat");

		if( g_bCvarAllow )
		{
			int weapon;

			for( int i = 1; i <= MaxClients; i++ )
			{
				if( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && GetEntProp(i, Prop_Send, "m_isIncapacitated", 1) && GetEntProp(i, Prop_Send, "m_isHangingFromLedge", 1) == 0 )
				{
					SDKHook(i, SDKHook_WeaponCanSwitchTo, CanSwitchTo);
					
					weapon = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
					if( weapon != -1 ) CanSwitchTo(i, weapon);

					if( (!g_bCvarThrow || g_iCvarHealAdren || g_iCvarHealPills) && !IsFakeClient(i) )
					{
						// Heal with Pills/Adrenaline
						if( !g_bLeft4Dead2 && (g_iCvarHealPills || g_iCvarHealAdren) )
						{
							SDKHook(i, SDKHook_PreThink, OnThinkPre);
						}

						// Prevent standing up animation when throwing grenades, or hook healing in L4D2
						if( !g_bCvarThrow || g_bLeft4Dead2 ) // L4D2 uses anim hook for detecting pills, L4D1 uses the PreThink
						{
							AnimHookEnable(i, OnAnimPre);
						}
					}
				}
			}
		}
	}

	AddCommandListener(CommandListenerGive, "give");
}

Action CommandListenerGive(int client, const char[] command, int args)
{
	if( g_bCvarAllow && args > 0 )
	{
		char buffer[8];
		GetCmdArg(1, buffer, sizeof(buffer));

		if( strcmp(buffer, "health", false) == 0 )
		{
			DamageHook(true);
		}
	}

	return Plugin_Continue;
}

public void OnPluginEnd()
{
	PatchAddress(false);
	PatchBullet(false);
	PatchMelee(false);
}



// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnMapStart()
{
	// PipeBomb projectile
	PrecacheParticle(PARTICLE_FUSE);
	PrecacheParticle(PARTICLE_LIGHT);

	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetPlugin();

	DamageHook(false);

	for( int i = 1; i <= MaxClients; i++ )
		ClearVars(i);
}

public void OnClientPutInServer(int client)
{
	if( g_bCvarAllow )
	{
		DamageHook(true);
	}
}

public void OnClientDisconnect(int client)
{
	ClearVars(client);
}

void ClearVars(int client)
{
	delete g_hTimerRevive[client];
	delete g_hTimerUseHealth[client];

	g_bHasHeal[client] = false;
	g_fReviveTimer[client] = 0.0;
	g_iHint[client] = 0;
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	if( g_bLeft4Dead2 )
	{
		g_iCvarHealAdren = g_hCvarHealAdren.IntValue;
		g_fCvarDelayAdren = g_hCvarDelayAdren.FloatValue;
	}
	g_fCvarDelayPills = g_hCvarDelayPills.FloatValue;
	g_iCvarDelayText = g_hCvarDelayText.IntValue;
	g_fCvarFriendly = g_hCvarFriendly.FloatValue;
	g_iCvarHealPills = g_hCvarHealPills.IntValue;
	g_iCvarHealRevive = g_hCvarHealRevive.IntValue;
	g_iCvarHealText = g_hCvarHealText.IntValue;
	g_iCvarMaxIncap = g_hCvarMaxIncap.IntValue;
	g_iCvarIncapHealth = g_hCvarIncapHealth.IntValue;
	g_iCvarReviveHealth = g_hCvarReviveHealth.IntValue;
	g_iCvarReviveTemp = g_hCvarReviveTemp.IntValue;
	g_bCvarThrow = g_hCvarThrow.BoolValue;

	if( g_bLeft4Dead2 )
	{
		g_iCvarPist = g_hCvarPist.IntValue;
		g_iCvarMelee = g_hCvarMelee.IntValue;

		PatchBullet(g_bCvarAllow && g_fCvarFriendly != 0.0);
		PatchMelee(g_bCvarAllow && g_iCvarPist == 0);
		DamageHook(g_bCvarAllow);
	}

	// Add weapon IDs to array
	char sTemp[128];
	g_hCvarRest.GetString(sTemp, sizeof(sTemp));

	delete g_aRestrict;
	g_aRestrict = new ArrayList();

	if( sTemp[0] )
	{
		StrCat(sTemp, sizeof(sTemp), ",");

		int index, last;
		while( (index = StrContains(sTemp[last], ",")) != -1 )
		{
			sTemp[last + index] = 0;
			g_aRestrict.Push(StringToInt(sTemp[last]));
			sTemp[last + index] = ',';
			last += index + 1;
		}
	}
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
		PatchAddress(true);
		PatchBullet(g_fCvarFriendly != 0.0);
		PatchMelee(g_iCvarPist == 0);
		HookEvents();
		DetourAdd();
		DamageHook(true);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		PatchAddress(false);
		PatchBullet(false);
		PatchMelee(false);
		UnhookEvents();
		DetourRem();
		ResetPlugin();
		DamageHook(false);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_bMapStarted == false )
			return false;

		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}



// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("player_incapacitated",		Event_Incapped);
	HookEvent("revive_success",				Event_ReviveSuccess);
	HookEvent("player_spawn",				Event_PlayerSpawn);
	HookEvent("player_death",				Event_PlayerDeath);
	HookEvent("player_team",				Event_PlayerDeath);
	HookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
}

void UnhookEvents()
{
	UnhookEvent("player_incapacitated",		Event_Incapped);
	UnhookEvent("revive_success",			Event_ReviveSuccess);
	UnhookEvent("player_spawn",				Event_PlayerSpawn);
	UnhookEvent("player_death",				Event_PlayerDeath);
	UnhookEvent("player_team",				Event_PlayerDeath);
	UnhookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
}

void Event_Incapped(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if( client && GetClientTeam(client) == 2 )
	{
		if( (!g_bCvarThrow || g_iCvarHealAdren || g_iCvarHealPills) && !IsFakeClient(client) )
		{
			// Heal with Pills/Adrenaline
			if( !g_bLeft4Dead2 && (g_iCvarHealPills || g_iCvarHealAdren) )
			{
				SDKHook(client, SDKHook_PreThink, OnThinkPre);
			}

			// Prevent standing up animation when throwing grenades, or hook healing in L4D2
			if( !g_bCvarThrow || g_bLeft4Dead2 ) // L4D2 uses anim hook for detecting pills, L4D1 uses the PreThink
			{
				AnimHookEnable(client, OnAnimPre);
			}

			// Heal or Revive hint text
			if( g_iCvarHealText )
			{
				CreateTimer(DELAY_HINT, TimerIncap, userid);
			}
		}

		// Melee weapons block friendly fire
		DamageHook(true);

		// For weapon restrictions
		SDKHook(client, SDKHook_WeaponCanSwitchTo, CanSwitchTo);

		// Active allowed
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( weapon != -1 && ValidateWeapon(client, weapon) ) return;

		// Switch to primary/pistol/melee/other valid if current weapon restricted, otherwise do nothing.
		for( int i = 0; i < 5; i++ )
		{
			weapon = GetPlayerWeaponSlot(client, i);
			if( weapon != -1 && ValidateWeapon(client, weapon) )
			{
				return;
			}
		}
	}
}

bool ValidateWeapon(int client, int weapon)
{
	static char classname[32];
	GetEdictClassname(weapon, classname, sizeof(classname));

	int index;
	g_aWeaponIDs.GetValue(classname, index);

	if( g_bLeft4Dead2 )
	{
		if( index == 15 || index == 23 ) // Pills / Adren
			g_bHasHeal[client] = true;
		else
			g_bHasHeal[client] = false;
	}
	else
	{
		g_bHasHeal[client] = index == 12; // Pills
	}

	if( index != 0 && g_aRestrict.FindValue(index) == -1 )
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		return true;
	}

	return false;
}

Action TimerIncap(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if( client && IsClientInGame(client) )
	{
		static char sTemp[256];
		int item = GetPlayerWeaponSlot(client, 4);
		if( item != -1 )
		{
			int type;

			// Check healing item type
			GetEdictClassname(item, sTemp, sizeof(sTemp));

			if( strncmp(sTemp[7], "pain", 4) == 0 )
			{
				if( g_iCvarHealPills == -1 ) type = 1;
				else type = 2;
			}
			else if( g_bLeft4Dead2 && strncmp(sTemp[7], "adren", 5) == 0 )
			{
				if( g_iCvarHealAdren == -1 ) type = 3;
				else type = 4;
			}

			// Prevent message if item type blocked
			switch( type )
			{
				case 1, 2: if( (g_bLeft4Dead2 && g_aRestrict.FindValue(15) != -1) || (!g_bLeft4Dead2 && g_aRestrict.FindValue(12) != -1) ) return Plugin_Continue;
				case 3, 4: if( g_aRestrict.FindValue(23) != -1 ) return Plugin_Continue;
			}

			// Show hints for item type held and type of feature
			if( type )
			{
				if( g_bTranslations )
				{
					switch( type )
					{
						case 1: sTemp = "Revive_UsePills";
						case 2: sTemp = "Heal_UsePills";
						case 3: sTemp = "Revive_UseAdren";
						case 4: sTemp = "Heal_UseAdren";
					}

					switch( g_iCvarHealText )
					{
						case 2: CPrintHintText(client, "%T", sTemp, client);
						default: CPrintToChat(client, "%T", sTemp, client);
					}
				}
				else
				{
					switch( g_iCvarHealText )
					{
						case 2:
						{
							switch( type )
							{
								case 1: sTemp = "[Revive] you can use Pills to revive";
								case 2: sTemp = "[Revive] you can use Pills to heal";
								case 3: sTemp = "[Revive] you can use Adrenaline to revive";
								case 4: sTemp = "[Revive] you can use Adrenaline to heal";
							}

							PrintHintText(client, sTemp);
						}
						default:
						{
							switch( type )
							{
								case 1: sTemp = "\x05[Revive] \x01you can use \x04Pills \x01to revive";
								case 2: sTemp = "\x05[Revive] \x01you can use \x04Pills \x01to heal";
								case 3: sTemp = "\x05[Revive] \x01you can use \x04Adrenaline \x01to revive";
								case 4: sTemp = "\x05[Revive] \x01you can use \x04Adrenaline \x01to heal";
							}

							PrintToChat(client, sTemp);
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client )
	{
		ClearVars(client);

		DamageHook(true);

		SDKUnhook(client, SDKHook_PreThink, OnThinkPre);
		SDKUnhook(client, SDKHook_WeaponCanSwitchTo, CanSwitchTo);
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client && GetClientTeam(client) == 2 )
	{
		ClearVars(client);

		DamageHook(true);

		AnimHookDisable(client, OnAnimPre);

		SDKUnhook(client, SDKHook_PreThink, OnThinkPre);
		SDKUnhook(client, SDKHook_WeaponCanSwitchTo, CanSwitchTo);
	}
}

void Event_ReviveSuccess(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("subject"));
	if( client && GetClientTeam(client) == 2 )
	{
		g_hTimerRevive[client] = null; // Null here, otherwise deleting throws timer errors because the timer is closing itself at this point with return Plugin_Stop
		ClearVars(client);

		DamageHook(true);

		AnimHookDisable(client, OnAnimPre);

		SDKUnhook(client, SDKHook_PreThink, OnThinkPre);
		SDKUnhook(client, SDKHook_WeaponCanSwitchTo, CanSwitchTo);
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();

	DamageHook(false);
}

void ResetPlugin()
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		ClearVars(i);

		if( IsClientInGame(i) )
		{
			AnimHookDisable(i, OnAnimPre);

			ClearVars(i);

			SDKUnhook(i, SDKHook_PreThink, OnThinkPre);
			SDKUnhook(i, SDKHook_WeaponCanSwitchTo, CanSwitchTo);
		}
	}
}



// ====================================================================================================
//					DAMAGE HOOKS
// ====================================================================================================
// Hook players OnTakeDamage if someone is incapped - to block melee weapon damage to survivors, or modify weapon damage inflicted on Survivors
void DamageHook(bool enable)
{
	// Only enable under these conditions
	if( g_fCvarFriendly == 1.0 && (!g_bLeft4Dead2 || g_iCvarPist != 0 || g_iCvarMelee != 0) ) return;

	bool incapped;

	// Check someone is incapped
	if( enable )
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && GetEntProp(i, Prop_Send, "m_isIncapacitated", 1) && GetEntProp(i, Prop_Send, "m_isHangingFromLedge", 1) == 0 )
			{
				incapped = true;
				break;
			}
		}
	}

	// Unhook and enable if required and someone incapped
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame(i) )
		{
			SDKUnhook(i, SDKHook_OnTakeDamageAlive, OnTakeDamage);

			if( enable && incapped && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
			{
				SDKHook(i, SDKHook_OnTakeDamageAlive, OnTakeDamage);
			}
		}
	}
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if( victim > 0 && victim <= MaxClients && attacker > 0 && attacker <= MaxClients && GetClientTeam(victim) == 2 && GetClientTeam(attacker) == 2 && GetEntProp(attacker, Prop_Send, "m_isIncapacitated", 1) && GetEntProp(attacker, Prop_Send, "m_isHangingFromLedge", 1) == 0 )
	{
		if( g_bLeft4Dead2 && g_iCvarPist == 0 && g_iCvarMelee == 0 && inflictor > MaxClients && IsValidEntity(inflictor) )
		{
			static char classname[16];
			GetEdictClassname(inflictor, classname, sizeof(classname));

			if( strcmp(classname[7], "melee") == 0 )
			{
				damage = 0.0;
				return Plugin_Changed;
			}
		}

		if( g_fCvarFriendly != 1.0 )
		{
			damage *= g_fCvarFriendly;
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}



// ====================================================================================================
//					RESTRICT
// ====================================================================================================
// Restrict certain weapons
Action CanSwitchTo(int client, int weapon)
{
	// This causes the animation to sometimes partially skip on L4D1 and doesn't seem to have any effect on L4D2, so removing.
	// if( g_hTimerUseHealth[client] ) return Plugin_Handled; // Block while using Pills/Adrenaline

	g_bHasHeal[client] = false;

	static char classname[32];
	GetEdictClassname(weapon, classname, sizeof(classname));

	int index;
	g_aWeaponIDs.GetValue(classname, index);

	if( index == 0 || g_aRestrict.FindValue(index) != -1 )
		return Plugin_Handled;

	if( g_bLeft4Dead2 )
	{
		if( index == 15 || index == 23 ) // Pills / Adren
			g_bHasHeal[client] = true;
		else
			g_bHasHeal[client] = false;
	}
	else
	{
		g_bHasHeal[client] = index == 12; // Pills
	}

	return Plugin_Continue;
}



// ====================================================================================================
//					THINK - can use pills/adrenaline
// ====================================================================================================
void OnThinkPre(int client)
{
	if( g_bHasHeal[client] ) // Only set in L4D1
	{
		if( GetClientButtons(client) & IN_ATTACK )
		{
			g_bHasHeal[client] = false;
			HealSetup(client, true);
		}
	}
}



// ====================================================================================================
//					ANIMATION HOOK
// ====================================================================================================
// Uses "Activity" numbers, which means 1 animation number is the same for all Survivors.
// Detect pills/adrenaline use to heal players and detect grenade throwing
Action OnAnimPre(int client, int &anim)
{
	if( g_bLeft4Dead2 )
	{
		switch( anim )
		{
			case L4D2_ACT_TERROR_USE_PILLS:
			{
				if( g_iCvarHealPills && g_bHasHeal[client] )
				{
					HealSetup(client, true);
				}
			}

			case L4D2_ACT_TERROR_USE_ADRENALINE:
			{
				if( g_iCvarHealAdren && g_bHasHeal[client] )
				{
					HealSetup(client, false);
				}
			}

			case L4D2_ACT_PRIMARYATTACK_GREN1_IDLE, L4D2_ACT_PRIMARYATTACK_GREN2_IDLE:
			{
				if( !g_bCvarThrow )
				{
					anim = L4D2_ACT_IDLE_INCAP_PISTOL;
					return Plugin_Changed;
				}
			}
		}
	}
	else
	{
		if( g_bHasHeal[client] )
		{
			switch( anim )
			{
				/* Does not work in L4D1
				case ACT_TERROR_USE_PILLS
				{
					if( g_iCvarHealPills )
					{
						HealSetup(client, true);
					}
				}
				// */

				case L4D1_ACT_PRIMARYATTACK_GREN1_IDLE, L4D1_ACT_PRIMARYATTACK_GREN2_IDLE:
				{
					if( !g_bCvarThrow )
					{
						anim = L4D1_ACT_IDLE_INCAP_PISTOL;
						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}



// ====================================================================================================
//					HEAL and REVIVE
// ====================================================================================================
// Heal player with pills/adrenaline
void HealSetup(int client, bool pills)
{
	// Timeout to prevent spamming and fast animation
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( weapon != 1 )
	{
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + (pills ? HEAL_ANIM_PILLS : HEAL_ANIM_ADREN) + 0.2);

		// Heal when animation is complete and delete weapon
		DataPack dPack = new DataPack();

		delete g_hTimerUseHealth[client];

		if( pills )
			g_hTimerUseHealth[client] = CreateTimer(HEAL_ANIM_PILLS, TimerPills, dPack);
		else
			g_hTimerUseHealth[client] = CreateTimer(HEAL_ANIM_ADREN, TimerAdren, dPack);

		dPack.WriteCell(GetClientUserId(client));
		dPack.WriteCell(EntIndexToEntRef(weapon));
	}
}

Action TimerAdren(Handle timer, DataPack dPack)
{
	HealPlayer(dPack, false);
	return Plugin_Continue;
}

Action TimerPills(Handle timer, DataPack dPack)
{
	HealPlayer(dPack, true);
	return Plugin_Continue;
}

void HealPlayer(DataPack dPack, bool pills)
{
	dPack.Reset();

	int userid = dPack.ReadCell();
	int weapon = dPack.ReadCell();

	delete dPack;

	// Validate client
	int client = GetClientOfUserId(userid);

	g_hTimerUseHealth[client] = null;

	if( client && IsClientInGame(client) && IsPlayerAlive(client) && GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) )
	{
		// Delete pills/adrenaline
		if( EntRefToEntIndex(weapon) != INVALID_ENT_REFERENCE )
		{
			RemovePlayerItem(client, weapon);
			RemoveEntity(weapon);
		}

		// Healing
		if( (pills ? g_iCvarHealPills : g_iCvarHealAdren) == -1 )
		{
			// Revive player
			switch( pills )
			{
				case true:
				{
					if( g_fCvarDelayPills == 0.0 )
					{
						RevivePlayer(client, true);
					}
					else
					{
						if( g_fReviveTimer[client] == 0.0 )
						{
							g_iHint[client] = 0;
							g_fReviveTimer[client] = g_fCvarDelayPills;
							delete g_hTimerRevive[client];

							DataPack dpTimer;
							g_hTimerRevive[client] = CreateDataTimer(TIMER_REVIVE, TimerRevive, dpTimer, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							dpTimer.WriteCell(userid);
							dpTimer.WriteCell(true);
						}
					}
				}
				case false:
				{
					if( g_fCvarDelayAdren == 0.0 )
					{
						RevivePlayer(client, false);
					}
					else
					{
						if( g_fReviveTimer[client] == 0.0 )
						{
							g_iHint[client] = 0;
							g_fReviveTimer[client] = g_fCvarDelayAdren;
							delete g_hTimerRevive[client];

							DataPack dpTimer;
							g_hTimerRevive[client] = CreateDataTimer(TIMER_REVIVE, TimerRevive, dpTimer, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							dpTimer.WriteCell(userid);
							dpTimer.WriteCell(false);
						}
					}
				}
			}
		}
		else
		{
			// Heal player
			int health = GetClientHealth(client);
			health += (pills ? g_iCvarHealPills : g_iCvarHealAdren);
			if( health > g_iCvarIncapHealth ) health = g_iCvarIncapHealth;
			SetEntityHealth(client, health);
		}

		// Fire event
		if( g_bLeft4Dead2 && pills == false )
		{
			// This fires the event and creates the Adrenaline effects
			L4D2_UseAdrenaline(client, 15.0, false);
		}
		else
		{
			Event hEvent = CreateEvent("pills_used");
			hEvent.SetInt("userid", userid);
			hEvent.Fire();
		}
	}
}

Action TimerRevive(Handle timer, DataPack dPack)
{
	dPack.Reset();
	int client = dPack.ReadCell();

	client = GetClientOfUserId(client);
	if( client && IsClientInGame(client) )
	{
		g_fReviveTimer[client] -= TIMER_REVIVE;

		// Hint
		if( g_iCvarDelayText )
		{
			int secs = RoundToCeil(g_fReviveTimer[client]);
			if( secs != g_iHint[client] )
			{
				g_iHint[client] = secs;

				if( secs )
				{
					if( g_bTranslations )
					{
						switch( g_iCvarDelayText )
						{
							case 2: CPrintHintText(client, "%T", "Revive_Wait", client, secs);
							default: CPrintToChat(client, "%T", "Revive_Wait", client, secs);
						}
					}
					else
					{
						switch( g_iCvarDelayText )
						{
							case 2: PrintHintText(client, "Reviving in %d", secs);
							default: PrintToChat(client, "\x05Reviving \x01in \x04%d", secs);
						}
					}
				}
				else
				{
					if( g_bTranslations )
					{
						switch( g_iCvarDelayText )
						{
							case 2: CPrintHintText(client, "%T", "Revive_Done", client, secs);
							default: CPrintToChat(client, "%T", "Revive_Done", client, secs);
						}
					}
					else
					{
						switch( g_iCvarDelayText )
						{
							case 2: PrintHintText(client, "Revived!", secs);
							default: PrintToChat(client, "\x05\x05Revived!", secs);
						}
					}
				}
			}
		}

		// Revive
		if( g_fReviveTimer[client] <= 0.0 )
		{
			g_fReviveTimer[client] = 0.0;

			bool pills = dPack.ReadCell();

			RevivePlayer(client, pills);
		}
		else
		{
			return Plugin_Continue;
		}
	}

	g_hTimerRevive[client] = null;
	return Plugin_Stop;
}

void RevivePlayer(int client, bool pills)
{
	L4D_ReviveSurvivor(client);

	// Revive black and white
	int test = pills ? 0 : 1;

	if( g_iCvarHealRevive & (1 << test) )
	{
		if( g_bHeartbeat )
		{
			Heartbeat_SetRevives(client, g_iCvarMaxIncap);
			if( g_bLeft4Dead2 )
			{
				SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iCvarMaxIncap);
			}
		}
		else
		{
			if( g_bLeft4Dead2 )
				SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 1);

			SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iCvarMaxIncap);
			SetEntProp(client, Prop_Send, "m_isGoingToDie", 1);
		}
	}

	if( g_iCvarReviveHealth )
	{
		SetEntityHealth(client, g_iCvarReviveHealth);
	}

	if( g_iCvarReviveTemp )
	{
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", float(g_iCvarReviveTemp));
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	}
}



// ====================================================================================================
//					PIPEBOMB EFFECTS
// ====================================================================================================
public void OnEntityCreated(int entity, const char[] classname)
{
	if( g_bCvarAllow && !g_bGrenadeFix && strcmp(classname, "pipe_bomb_projectile") == 0 )
	{
		RequestFrame(OnFrameSpawn, EntIndexToEntRef(entity));
	}
}

void OnFrameSpawn(int entity)
{
	if( EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
	{
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if( client > 0 && client <= MaxClients && GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) == 1 )
		{
			CreateParticle(entity, 0);
			CreateParticle(entity, 1);
		}
	}
}

void CreateParticle(int target, int type)
{
	int entity = CreateEntityByName("info_particle_system");
	if( type == 0 )	DispatchKeyValue(entity, "effect_name", PARTICLE_FUSE);
	else			DispatchKeyValue(entity, "effect_name", PARTICLE_LIGHT);

	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Start");

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", target);

	if( type == 0 )	SetVariantString("fuse");
	else			SetVariantString("pipebomb_light");
	AcceptEntityInput(entity, "SetParentAttachment", target);
}

void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}



// ====================================================================================================
//					DETOUR
// ====================================================================================================
void DetourAdd()
{
	if( g_bLeft4Dead2 )
	{
		if( !g_hDetourFireBullet.Enable(Hook_Pre, CTerrorGun_FireBullet_Pre) )
			SetFailState("Failed to detour \"CTerrorGun::FireBullet\" pre.");

		if( !g_hDetourFireBullet.Enable(Hook_Post, CTerrorGun_FireBullet_Post) )
			SetFailState("Failed to detour \"CTerrorGun::FireBullet\" post.");

		if( !g_hDetourCanUseOnSelf.Enable(Hook_Pre, CPainPills_CanUseOnSelf) )
			SetFailState("Failed to detour \"CPainPills::CanUseOnSelf\".");
	}
	else
	{
		if( !g_hDetourCanUseOnSelf.Enable(Hook_Pre, CPainPills_PrimaryAttack) )
			SetFailState("Failed to detour \"CPainPills::PrimaryAttack\".");
	}
}

void DetourRem()
{
	if( g_bLeft4Dead2 )
	{
		if( !g_hDetourFireBullet.Disable(Hook_Pre, CTerrorGun_FireBullet_Pre) )
			SetFailState("Failed to detour \"CTerrorGun::FireBullet\" pre.");

		if( !g_hDetourFireBullet.Disable(Hook_Post, CTerrorGun_FireBullet_Post) )
			SetFailState("Failed to detour \"CTerrorGun::FireBullet\" post.");

		if( !g_hDetourCanUseOnSelf.Disable(Hook_Pre, CPainPills_CanUseOnSelf) )
			SetFailState("Failed to remove detour \"CPainPills::CanUseOnSelf\".");
	}
	else
	{
		if( !g_hDetourCanUseOnSelf.Disable(Hook_Pre, CPainPills_PrimaryAttack) )
			SetFailState("Failed to remove detour \"CPainPills::PrimaryAttack\".");
	}
}

int g_iReviveOwner, g_iBulletClient;
MRESReturn CTerrorGun_FireBullet_Pre(int pThis)
{
	g_iReviveOwner = -1;

	if( pThis > MaxClients && IsValidEntity(pThis) )
	{
		int client = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");
		if( client > 0 && client <= MaxClients )
		{
			g_iReviveOwner = GetEntProp(client, Prop_Send, "m_reviveOwner");
			if( g_iReviveOwner != -1 )
			{
				g_iBulletClient = client;
				SetEntProp(client, Prop_Send, "m_reviveOwner", -1);
			}
		}
	}

	return MRES_Ignored;
}

MRESReturn CTerrorGun_FireBullet_Post(int pThis)
{
	if( g_iReviveOwner != -1 )
	{
		SetEntProp(g_iBulletClient, Prop_Send, "m_reviveOwner", g_iReviveOwner);
	}

	return MRES_Ignored;
}

MRESReturn CPainPills_CanUseOnSelf(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int client;
	if( !hParams.IsNull(1) )
		client = hParams.Get(1);

	if( client && g_bHasHeal[client] && GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) )
	{
		hReturn.Value = 1;
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

MRESReturn CPainPills_PrimaryAttack(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int client = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");

	if( client != -1 && g_bHasHeal[client] && GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) )
	{
		hReturn.Value = 1;
		return MRES_Supercede;
	}

	return MRES_Ignored;
}



// ====================================================================================================
//					PATCHES
// ====================================================================================================
void PatchAddress(bool patch)
{
	static bool patched;

	if( !patched && patch )
	{
		patched = true;

		int len = g_ByteSaved_Deploy.Length;
		for( int i = 0; i < len; i++ )
		{
			if( len == 1 )
				StoreToAddress(g_Address_Deploy + view_as<Address>(i), 0x78, NumberType_Int8); // 0x75 JNZ (jump short if non zero) to 0x78 JS (jump short if sign) - always jump
			else
				StoreToAddress(g_Address_Deploy + view_as<Address>(i), 0x90, NumberType_Int8);
		}
	}
	else if( patched && !patch )
	{
		patched = false;

		int len = g_ByteSaved_Deploy.Length;
		for( int i = 0; i < len; i++ )
		{
			StoreToAddress(g_Address_Deploy + view_as<Address>(i), g_ByteSaved_Deploy.Get(i), NumberType_Int8);
		}
	}
}

void PatchBullet(bool patch)
{
	if( !g_bLeft4Dead2 ) return; // L4D1 already allows incapped Survivors to damage other Survivors

	static bool patched;

	if( !patched && patch )
	{
		patched = true;

		int len = g_ByteSaved_FireBullet.Length;
		for( int i = 0; i < len; i++ )
		{
			if( len == 1 )
				StoreToAddress(g_Address_FireBullet + view_as<Address>(i), 0x75, NumberType_Int8); // 0x75 JNZ (jump short if non zero) to 0x78 JS (jump short if sign) - always jump
			else
				StoreToAddress(g_Address_FireBullet + view_as<Address>(i), 0x90, NumberType_Int8);
		}
	}
	else if( patched && !patch )
	{
		patched = false;

		int len = g_ByteSaved_FireBullet.Length;
		for( int i = 0; i < len; i++ )
		{
			StoreToAddress(g_Address_FireBullet + view_as<Address>(i), g_ByteSaved_FireBullet.Get(i), NumberType_Int8);
		}
	}
}

void PatchMelee(bool patch)
{
	if( !g_bLeft4Dead2 ) return;

	static bool patched;

	if( !patched && patch )
	{
		patched = true;

		int len = g_ByteSaved_OnIncap.Length;
		for( int i = 0; i < len; i++ )
		{
			StoreToAddress(g_Address_OnIncap + view_as<Address>(i), 0x90, NumberType_Int8);
		}
	}
	else if( patched && !patch )
	{
		patched = false;

		int len = g_ByteSaved_OnIncap.Length;
		for( int i = 0; i < len; i++ )
		{
			StoreToAddress(g_Address_OnIncap + view_as<Address>(i), g_ByteSaved_OnIncap.Get(i), NumberType_Int8);
		}
	}
}



// ====================================================================================================
//					COLORS.INC REPLACEMENT
// ====================================================================================================
void CPrintToChat(int client, char[] message, any ...)
{
	static char buffer[256];
	VFormat(buffer, sizeof(buffer), message, 3);

	ReplaceString(buffer, sizeof(buffer), "{default}",		"\x01");
	ReplaceString(buffer, sizeof(buffer), "{white}",		"\x01");
	ReplaceString(buffer, sizeof(buffer), "{cyan}",			"\x03");
	ReplaceString(buffer, sizeof(buffer), "{lightgreen}",	"\x03");
	ReplaceString(buffer, sizeof(buffer), "{orange}",		"\x04");
	ReplaceString(buffer, sizeof(buffer), "{green}",		"\x04"); // Actually orange in L4D2, but replicating colors.inc behaviour
	ReplaceString(buffer, sizeof(buffer), "{olive}",		"\x05");
	PrintToChat(client, buffer);
}

void CPrintHintText(int client, char[] message, any ...)
{
	static char buffer[256];
	VFormat(buffer, sizeof(buffer), message, 3);

	ReplaceString(buffer, sizeof(buffer), "{default}",		"");
	ReplaceString(buffer, sizeof(buffer), "{white}",		"");
	ReplaceString(buffer, sizeof(buffer), "{cyan}",			"");
	ReplaceString(buffer, sizeof(buffer), "{lightgreen}",	"");
	ReplaceString(buffer, sizeof(buffer), "{orange}",		"");
	ReplaceString(buffer, sizeof(buffer), "{green}",		""); // Actually orange in L4D2, but replicating colors.inc behaviour
	ReplaceString(buffer, sizeof(buffer), "{olive}",		"");
	PrintHintText(client, buffer);
}