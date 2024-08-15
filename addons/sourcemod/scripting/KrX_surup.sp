/************************************************************************
* -----------------------------------------------------------------------
* KrX's Survivor Upgrades
* by KrX a.k.a Whosat
* AlliedModders https://forums.alliedmods.net/showthread.php?t=100507
* Plugin Homepage: http://krx.ath.cx/l4d/plugins/KrX_surup/
* -----------------------------------------------------------------------
* KrX's Survivor Upgrades is a complete rewrite of the original 
* Survivor Upgrades plugin by Jerrith
* (URL: https://forums.alliedmods.net/showthread.php?t=95365)
* 
* He stopped providing support for the plugin after awhile and some
* members of the AlliedModders forums helped put together some requested
* features. They were then put together by MagnoT and then uploaded, but 
* he did not provide support for the plugin.
* 
* KrX then copied out parts of MagnoT's version and put them into the
* original Survivor Upgrades and cleaned up some parts of the code.
* It was supported by him, releasing versions with the version number of
* the original plugin with 'k' and the release number following that. 
* 
* Survivor Upgrades_K v1.4k3 was the last release of Survivor Upgrades_K,
* KrX rewrote the whole plugin and released it as KrX's Survivor Upgrades
* -----------------------------------------------------------------------
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
* -----------------------------------------------------------------------
* Thank you testers: Chaotic Llama, alicia, Talonrages, AngryVag, Naow, olj
* Thank you translators: olj, 0cube
* And special thanks to olj for his Adrenaline implementation, and his and 
* Chaotic Llama's help with helping out in the forums =)
* -----------------------------------------------------------------------
* CHANGELOG:
* ----------
* Version 1.0.0
*  - Initial Release
* Version 1.0.1
*  - Fixed versus issues as reported by Chaotic Llama and olj
*  - Fixed SpecialAmmo counter showing for Infected's attack2.
* Version 1.0.2
*  - Fixed Server Print message always showing that its enabled
*     (Thanks Chaotic Llama)
*  - Fixed bug where SpecialAmmo count will decrease if throwing nades 
*     or eatin' pills (Thanks edoom)
*  - Fixed Tank HP sometimes dropping to 150hp (thanks olj)
*     If you're not getting that error, change BOOL_FIX_TANKHP to 0
*  - Fixed some precompiler directives throwing out errors 
*     (thanks chunXray)
*  - Added options for SpecialAmmo tracking: surup_upgrade_specialammo_show
*     0 to not show, 1 for CenterText, 2 for HintText, 3 for ChatText
* Version 1.0.3
*  - Moved gamemode convar caching into OnConfigsExecuted for reliability
*  - Fixed Tank workaround (thanks olj)
*  - Added verbosity checks to announcing (thanks quadhog)
* Version 1.0.4
*  - Fixed announcement that bots still get upgrades from killing events
*  - Added amount to deduct from a shotgun shot for SpecialAmmo:
*     surup_upgrade_specialammo_minussg
*  - Added more checks before giving upgrades to hopefully fix tank
* Version 1.0.5
*  - Added bot checks to all announcement statements
*  - Added check to ensure that SpecialAmmo does not go below 0
*  - Added checks for team for Player Replaced Bot and viceversa
*  - Added check for KillsCount & Amount in InfectedDeath (thanks voiderest)
* Version 1.1.0
*  - Fixed bots getting upgrades even when surup_upgrade_bots disables it
*  - Added new upgrade event: Reaching safe room (Mimics L4D's def. system)
*     surup_upgrades_reach_saferoom (Default 1)
*  - Added check for bad convar value for Shotgun specialammo
*  - Edited line for /upghelp 3 to reflect Shotgun specialammo.
*  - Changed default value for surup_upgrades_kill_award to 1
*  - Removed workaround for tank's 150hp, bugfixed
*  - Code optimizations
*  *- This release requires you to update your KrX_surup.phrases.txt!
* Version 1.1.1
*  - Fixed messages still showing for bots dying if upgrades disabled
*  - Fixed InfectedDeath spamming errors in log
*  - Messages about survivors receiving upgrades when there are no human
*     survivors showing no longer show...
*  - Added feature to ignite tanks for vs, nonvs or both (similar to SI)
*     surup_upgrade_incendiary_ignitetank_nonvs "1"
*     surup_upgrade_incendiary_ignitetank_vs "0"
*  - Added German translation by 0cube
*  - Removed convar surup_upgrade_incendiary_ignitetank
* Version 1.1.2
*  - Added new upgrade: Adrenaline (adapted from olj's pills addiction)
*     Gives the player a speed boost, 1.35x by default
*     surup_upgrade_adrenaline_multiplier "1.35"
*     surup_allow_adrenaline "1"
*  - Added new feature: Individual tracking of ammo
*     Allows a player to choose one specialammo to use, switching to next 
*     ammotype or returning to normal once finished
*  - Added new feature: Ammunition Menu Tracker
*     Allows a player to track his ammunition left as he shoots
*     Can be turned on or off by player
*     Usage: Say /ammotype
*  - Plugin Optimizations
*  *- This release requires you to update your KrX_surup.phrases.txt!
* Version 1.1.3
*  - Panel now shows 9999 SpecialAmmo if server has infinite ammo defined
*  - Panel no longer disappears if Persistent Menu is on when using Normal
*  - Panel now refreshes when more ammo is added
*  - Panel now decays faster if you do not shoot (10s instead of 30s)
*  - Fixed the other SpecialAmmotype being removed when switching ammotype
*  - Player being fully upgraded now shows only if Verbosity is > 2
*  - Player can now choose whether he wants the ammocounter to appear 
*     through the /ammotype panel.
*  - Text to inform player of saying /ammotype now appears as a Hint, and
*     is now translatable.
*  - Bots now use SpecialAmmo (switches to last given specialammo)
*  - Its worth mentioning that a player can now only use one specialammo
*     at a time, but can hold both and switch anytime by saying/ammotype
*      Also note that the Persistent Menu option is to help in quickswitch
*  - Removed BOOL_TRACK_SPECIALAMMO directive
*  *- This release requires you to update your KrX_surup.phrases.txt!
* Version 1.1.4
*  - Panel does not show by default for each player
*     Or otherwise through directive BOOL_OFF_PERSISTENT_MENU
*  - Added new Panel option: Autoswitch. If On, switches to specialammo
*     when you receive it (On by default)
*  - Added Plugin Compatibility: PillsAddiction by olj
*  - Added funcs for KrX_surup. To use, open .sp and see 'Plugin Natives'
*  - Fixed Adrenaline resetting every mapchange bug
*  - Fixed bots not changing to Incendiary Ammo when they get the upgrade
*  *- This release requires you to update your KrX_surup.phrases.txt!
* Version 1.1.5
*  - Added hint text for laser toggle
*  - Laser sights are on by default, but can be turned off by default
*     by setting BOOL_ON_LASER_SIGHTS
*  - Laser sights for bots can always be on by setting BOOL_FORCE_BOT_LASER
*  - On versus, players receiving upgrades announcement should now be seen
*     by all players, infected included
*  - Fixed PlayerDeath messages not firing
*  - On PlayerDeath, his kills counter now resets
*  - RemoveAllUpgrades now removes Adrenaline as well
*  - Fixed new clients after a map taking over the ammopanel settings of 
*     the previous player
*  - Fixed infinite Hollow Point ammo bug
*  - Fixed some versus-specific check bugs
*  - Change default value of adrenaline multiplier to 1.25
*  - Added more natives: AddUpgrade, RemoveUpgrade and KrXsurupIsEnabled
*  - Added valid client and team checks for natives
* Version 1.1.6
*  - Fixed listplayerupgrades admin command showing wrong specialammo
*  - Fixed KrXsurupIsEnabled native not working: BOOL_SELECTIVE_GAMEMODES
*  - Removed BOOL_ON_LASER_SIGHTS, replaced by surup_laser_default_state
*  - Persistent Menu setting now resets for Versus so it doesn't show for
*     Infected. This is done as opposed to adding checks everytime before 
*     showing ammotype panel to reduce serverload
*  - Fixed upgrades retaining after a versus round
*  - Fixed upgrade errors due to some laser checkings at mapchange
*  - Added checks for if player is bot before sending panel via WeaponFire
*  - Added BOOL_ON_AUTOSWITCH, BOOL_SHOW_AMMOPANEL
*  - Added surup_versus_announce_to_all
*  - Removed BOOL_OFF_PERSISTENT_MENU, replaced by
*     surup_upgrade_specialammo_panel_state "0"
*  - Fixed removeupgrade admin command not removing specialammo
*  - removeallupgrades admin command now can remove for specific target.
*     to remove for all, use "removeallupgrades @all"
*  - listplayerupgrades admin command can now have many targets, or @all
*  - Added extra loop check for setting survivor_upgrades to fix rare bug
************************************************************************/

// Set these to completely remove sections of the plugin during compilation
// to reduce plugin load on the server
// Please only disable those sections you do not use at all
// If unsure, leave all at 1 (default)

// 		Enable upgrades on		1=enable, 0=disable
#define BOOL_UPGRADE_HEAL           1		// Compile getting Upgrades on Healing events?
#define BOOL_UPGRADE_WITCH          1		// Compile getting Upgrades on Witch events?
#define BOOL_UPGRADE_TANK           1		// Compile getting Upgrades on Tank events?
#define BOOL_UPGRADE_KILLS          1		// Compile getting Upgrades on Killing events?
#define BOOL_UPGRADE_SAFEROOM       1		// Compile getting Upgrades upon reaching saferoom?
#define BOOL_TRACK_MEGAKILLS        1		// Compile inclusion of minigun and blast kills in Kill Counter?
#define BOOL_SHOW_SPECIALAMMO       1		// Compile showing of SpecialAmmo left on top of crosshair?
#define BOOL_SHOW_AMMOPANEL         1		// Compile the ammopanel?
#define BOOL_ON_AUTOSWITCH          1		// Compile initial state of SA AutoSwitch (1 for On)
#define BOOL_FORCE_BOT_LASER        1		// Compile making all bots always have lasers?
#define BOOL_ALLOW_INCENDIARY       1		// Compile Incendiary Ammo?
#define BOOL_DONT_RETAIN_UPGRADES   1		// Compile removing of upgrades on MissionLost, MapTransition, PlayerDeath?
#define BOOL_SHOW_SERVER_MESSAGES   1		// Compile PrintToServer(); messages?
#define BOOL_SELECTIVE_GAMEMODES    0		// Compile GameMode Checks?
#define BOOL_ADMIN_COMMANDS         1		// Compile admin commands?
#define BOOL_ANNOUNCE_PLUGIN        1		// Compile Announce at connect that server is running plugin?
#define BOOL_FORCE_MOTD             1		// Compile setting of motd_enabled 1 to fix servers not showing MOTD?

#define PLUGIN_TAG_C		"\x04[\x03Upgrades\x04]\x01"	// Tag which appears at the start of every chat line output

/**********************************************************************/
/* DO NOT EDIT BELOW THIS LINE IF YOU DO NOT KNOW WHAT YOU ARE DOING! */
/**********************************************************************/

/*** -- Plugin headers -- ***/

#include <sourcemod>
#include <sdktools>

#if !BOOL_UPGRADE_KILLS
#undef BOOL_TRACK_MEGAKILLS
#define BOOL_TRACK_MEGAKILLS 0
#endif

#if !BOOL_SHOW_SPECIALAMMO
#undef BOOL_SHOW_AMMOPANEL
#define BOOL_SHOW_AMMOPANEL 0
#endif

#if !BOOL_SHOW_AMMOPANEL
#undef BOOL_ON_AUTOSWITCH
#define BOOL_ON_AUTOSWITCH 1
#endif

// Enable debug messages?
#define DEBUG 0
// Enable (very highly possibly bugged) experimental features?
#define DEBUG_EXPERIMENTAL 0
// Enable this is if you encounter survivor_upgrades convar resetting itself
#define FIX_RARE_BUG_METHOD 0

#define PLUGIN_TAG			"[KrX's SurUp]"
#define PLUGIN_VERSION		"1.1.6"
#define PLUGIN_CONFIGFILE	"KrX_surup"

// Cvar stuffs
#define CVAR_FLAGS 			FCVAR_PLUGIN|FCVAR_NOTIFY
#define CVAR_MAX_UPGRADES 	15.0

// Max stuffs
#define MAX_LEN_GAMEMODE			8		// As of 05Aug09: "survival"
#define MAX_UPGRADES				31		// Max Index to upgrade
#define MAX_VALID_UPGRADES			15		// Total upgrades available
#define MAX_SPECIALAMMOTYPES		2		// Total number of SpecialAmmotypes

#define SURVIVORS_TEAMNUM			2		// Survivors team number
#define INFECTED_TEAMNUM			3		// Infected team number

// Use semicolon to break all statements
#pragma semicolon 1

/*** -- END Plugin headers -- ***/

/*** -- Global Variables Declaration -- ***/

// SDK Upgrade function handles (to be defined in OnPluginStart();)
new Handle:AddUpgrade = INVALID_HANDLE;							// AddUpgrade to be re-assigned later
new Handle:RemoveUpgrade = INVALID_HANDLE;						// RemoveUpgrade to be re-assigned later

// Initialisation variables
new bool:b_Hooked = false;										// Has plugin hooked events?

// Client-unique Variables
new bool:b_Upgrades_GivenInit[MAXPLAYERS+1];					// Has client received initial upgrades?
new bool:b_Upgrades_Client[MAXPLAYERS+1][MAX_VALID_UPGRADES+1];	// Does client have specific upgrade?
new bool:b_Upgrades_Laser[MAXPLAYERS+1];						// Tracking for Laser toggle
#if BOOL_SHOW_AMMOPANEL
new bool:b_Persistent_Menu[MAXPLAYERS+1];						// Tracking for persistent menus
#endif
new bool:b_SpecialAmmo_AutoSwitch[MAXPLAYERS+1];				// Tracking for AutoSwitching of SA
new g_Upgrades_SpecialAmmotype[MAXPLAYERS+1];					// Track current specialammotype being used
#if BOOL_SHOW_SPECIALAMMO
new bool:b_Show_Ammocount[MAXPLAYERS+1];						// Tracking for showing AmmoCounts
#endif
new g_Upgrades_SpecialAmmo[MAX_SPECIALAMMOTYPES][MAXPLAYERS+1];	// Track special ammo bullets
#if BOOL_UPGRADE_KILLS
new g_Upgrades_TrackKills[MAXPLAYERS+1];						// Track number of kills
#endif
#if DEBUG_EXPERIMENTAL
#if BOOL_DONT_RETAIN_UPGRADES
new g_Upgrades_Dead[MAXPLAYERS+1];								// Tracks for dead players (to give new upgrades when they respawn)
#endif
#endif
new bool:b_BotControlled[MAXPLAYERS+1];							// Is client controlled by bot?

// Upgrade information (to be defined in OnPluginStart();)
new IndexToUpgrade[MAX_VALID_UPGRADES+1];						// SDKcall index for L4D-built-in upgrades
new String:UpgradeShortInfo[MAX_VALID_UPGRADES+1][256];			// Short info for chattext
new String:UpgradeLongInfo[MAX_VALID_UPGRADES+1][1024];			// Long info for help text
new Handle:UpgradeAllowed[MAX_VALID_UPGRADES+1];				// For ConVar checking if upgrade is allowed
new String:UpgradeSpecialAmmoName[MAX_SPECIALAMMOTYPES][1024];	// Name for specialammotypes

// ConVar handles: upgrade-related
new Handle:UpgradesSpawnAll = INVALID_HANDLE;					// surup_upgrades_spawn_all
#if BOOL_UPGRADE_WITCH
new Handle:UpgradesWitchCr0wned = INVALID_HANDLE;				// surup_upgrades_witch_cr0wned
new Handle:UpgradesWitchKiller = INVALID_HANDLE;				// surup_upgrades_witch_killer
new Handle:UpgradesWitchAll = INVALID_HANDLE;					// surup_upgrades_witch_all
#endif
#if BOOL_UPGRADE_TANK
new Handle:UpgradesTankSpawn = INVALID_HANDLE;					// surup_upgrades_tank_spawn
new Handle:UpgradesTankKiller = INVALID_HANDLE;					// surup_upgrades_tank_killer
new Handle:UpgradesTankAll = INVALID_HANDLE;					// surup_upgrades_tank_all
#endif
#if BOOL_UPGRADE_HEAL
new Handle:UpgradesHealPlayer = INVALID_HANDLE;					// surup_upgrades_heal_player
new Handle:UpgradesHealSelf = INVALID_HANDLE;					// surup_upgrades_heal_self
new Handle:UpgradesHealAmount = INVALID_HANDLE;					// surup_upgrades_heal_amount
#endif
#if BOOL_UPGRADE_KILLS
new Handle:UpgradesKillCount = INVALID_HANDLE;					// surup_upgrades_kill_count
new Handle:UpgradesKillAmount = INVALID_HANDLE;					// surup_upgrades_kill_amount
new Handle:UpgradesKillAward = INVALID_HANDLE;					// surup_upgrades_kill_award
#endif
#if BOOL_UPGRADE_SAFEROOM
new Handle:UpgradesReachSaferoom = INVALID_HANDLE;				// surup_upgrades_reach_saferoom
#if DEBUG_EXPERIMENTAL
new Handle:UpgradesReachCrescendo = INVALID_HANDLE;				// surup_upgrades_reach_crescendo
#endif
#endif
new Handle:UpgradeSpecialAmmoCount = INVALID_HANDLE;			// surup_upgrade_specialammo_count
new Handle:UpgradeSpecialAmmoMinusSG = INVALID_HANDLE;			// surup_upgrade_specialammo_minussg
#if BOOL_SHOW_SPECIALAMMO
new Handle:UpgradeSpecialAmmoShow = INVALID_HANDLE;				// surup_upgrade_specialammo_show
#if BOOL_SHOW_AMMOPANEL
new Handle:UpgradeSpecialAmmoPanelState = INVALID_HANDLE;		// surup_upgrade_specialammo_panel_state
#endif
#endif
#if BOOL_ALLOW_INCENDIARY
new Handle:UpgradeIncendiaryIgniteTankNoVS = INVALID_HANDLE;	// surup_upgrade_incendiary_ignitetank_nonvs
new Handle:UpgradeIncendiaryIgniteTankVS = INVALID_HANDLE;		// surup_upgrade_incendiary_ignitetank_vs
new Handle:UpgradeIncendiaryIgniteSpecNoVS = INVALID_HANDLE;	// surup_upgrade_incendiary_ignitespecial_nonvs
new Handle:UpgradeIncendiaryIgniteSpecVS = INVALID_HANDLE;		// surup_upgrade_incendiary_ignitespecial_vs
#endif
new Handle:UpgradeAdrenalineMult = INVALID_HANDLE;				// surup_upgrade_adrenaline_multiplier
new Handle:UpgradeReloaderSpeed = INVALID_HANDLE;				// surup_upgrade_reloader_speed
new Handle:UpgradeReloaderShotgunSpeed = INVALID_HANDLE;		// surup_upgrade_reloader_shotgunspeed
#if BOOL_DONT_RETAIN_UPGRADES
new Handle:ResetOnMissionLost = INVALID_HANDLE;					// surup_reset_on_missionlost
new Handle:ResetOnMapChange = INVALID_HANDLE;					// surup_reset_on_mapchange
new Handle:ResetOnDeath = INVALID_HANDLE;						// surup_reset_on_death
#endif
new Handle:LaserDefaultState = INVALID_HANDLE;					// surup_laser_default_state
// ConVar handles: plugin-related
#if BOOL_SELECTIVE_GAMEMODES
new Handle:EnableCoop = INVALID_HANDLE;							// surup_enable_coop
new Handle:EnableSv = INVALID_HANDLE;							// surup_enable_sv
new Handle:EnableVersus = INVALID_HANDLE;						// surup_enable_vs
#endif
new Handle:UpgradeBots = INVALID_HANDLE;						// surup_upgrade_bots
new Handle:VersusAnnounceToAll = INVALID_HANDLE;				// surup_versus_announce_to_all
new Handle:PluginVerbosity = INVALID_HANDLE;					// surup_verbosity

// ConVar variable holders (don't need to check variable value every time)
new bool:b_InvalidGameMode = false;								// See: OnConfigsExecuted();
new bool:b_IsVersus = false;									// See: OnConfigsExecuted();
new String:g_CurrentMode[MAX_LEN_GAMEMODE+1];					// mp_gamemode placeholder
#if BOOL_ALLOW_INCENDIARY
new bool:b_IgniteTank = true;									// GetConVarInt("surup_upgrade_incendiary_ignitetank");
new bool:b_IgniteSpecial =  true;								// Depends on GameMode: See OnConfigsExecuted
#endif
new g_Verbosity = 2;											// GetConVarInt("surup_verbosity");
new g_UpgradeBots = 2;											// GetConVarInt("surup_upgrade_bots");
#if BOOL_UPGRADE_HEAL
new g_UpgradesHealPlayer = 0;									// GetConVarInt("surup_upgrades_heal_player");
new g_UpgradesHealSelf = 0;										// GetConVarInt("surup_upgrades_heal_self");
new g_UpgradesHealAmount = 0;									// GetConVarInt("surup_upgrades_heal_amount");
#endif
#if BOOL_UPGRADE_KILLS
new g_UpgradesKillCount = 0;									// GetConVarInt("surup_upgrades_kill_count");
new g_UpgradesKillAmount = 0;									// GetConVarInt("surup_upgrades_kill_amount");
new g_UpgradesKillIA = 0;										// GetConVarInt(UpgradeAllowed[14]);
new g_UpgradesKillHP = 0;										// GetConVarInt(UpgradeAllowed[9]);
new g_UpgradesKillAward = 0;									// GetConVarInt("surup_upgrades_kill_award");
#endif
new g_UpgradeSpecialAmmoCount = 0;								// GetConVarInt("surup_upgrade_specialammo_count");
new g_UpgradeSpecialAmmoMinusSG = 1;							// GetConVarInt("surup_upgrade_specialammo_minussg");
#if BOOL_SHOW_SPECIALAMMO
new g_UpgradeSpecialAmmoShow = 0;								// GetConVarInt("surup_upgrade_specialammo_show");
#endif
#if BOOL_SHOW_AMMOPANEL
new bool:b_UpgradeSpecialAmmoPanelState = false;				// GetConVarBool("surup_upgrade_specialammo_panel_state");
#endif
new Float:g_UpgradeAdrenalineMult = 1.0;						// GetConVarFloat("surup_upgrade_adrenaline_multiplier");
new bool:b_LaserDefaultState = true;							// GetConVarBool("surup_laser_default_state");
new bool:b_VersusAnnounceToAll = true;							// GetConVarBool("surup_versus_announce_to_all");
// Functional Variables
#if BOOL_UPGRADE_TANK
new bool:b_BlockOnTankSpawn = false;							// Prevent giving upgrades for tanks spawn 15 seconds within each other
#endif
new bool:b_Enabled = false;										// Is Survivor Upgrades enabled?
new bool:b_Initialised = false;									// Has initialisation been done?
#if BOOL_DONT_RETAIN_UPGRADES
new bool:b_MissionLost = false;									// Used for MissionLost
#endif
new bool:b_CanAnnounce = false;									// Prevent one-time use upgrades messages coming up randomly
new speedOffset = -1;											// SetEntData offset for Adrenaline
new bool:b_PillsAddictionAdrenaline = false;					// GetConVarBool(FindConVar("l4d_pillsaddiction_adrenaline_boost_enabled"));
#if DEBUG_EXPERIMENTAL
new laserColourOffset[3];										// SetEntData offset for laser's colour
#endif

/*** -- END Global Variables Declaration -- ***/


/*** -- Plugin Initialisation -- ***/

public Plugin:myinfo = 
{
	name = "KrX's Survivor Upgrades",
	author = "KrX (a.k.a Whosat)",
	description = "Gives Survivors upgrades and more",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=100507"
}
/*** -- Plugin Natives -- ***/

// How To Use:
// Of course, include the library. 
//   #include <KrX_surup>
// First, check if the KrX_surup library exists.
//   LibraryExists("KrX_surup");
// Then, if you use a recently added native, check for the version
//   decl String:theVersion[12];
//   KrXsurupVersion(theVersion, strlen(theVersion));
//   if(strcmp(theVersion, "1.1.4") == 1)
// Once you're sure the function exists, do what you want.
// For Example, check if client 3 has the Adrenaline (Index 15) upgrade:
//   if(KrXsurupHasUpgrade(3, 15))
// Or For Example, check how much Incendiary Ammo(SAIndex 2) client 6 has
//   ClientIAAmount = KrXsurupGetSpecialAmmo(6, 2);

/*
// Available natives.
// for ammoType, 0=Normal, 1=HollowPoint, 2=Incendiary
// upgrade Indexes start from 0
// Common causes of failures: wrong ammoType
//  -> Added v1.1.4
KrXsurupVersion(String:buffer, strlen);				// Returns bool, true on success, false on failure.
KrXsurupHasUpgrade(client, upgIndex); 				// Returns bool, with result
KrXsurupMaxUpgrades();								// Returns short, with maximum number of upgrades
KrXsurupIsLaserOn(client);							// Returns bool, with result
KrXsurupCurrentAmmotype(client);					// Returns short, with result. 0=Normal, 1=HollowPoint, 2=Incendiary
KrXsurupChangeAmmotype(client, ammoType);			// Returns bool, true on success, false on failure.
KrXsurupGetSpecialAmmo(client, ammoType);			// Returns short, with amount of ammoType specialAmmo
KrXsurupAddSpecialAmmo(client, ammoType, amount);	// Returns bool, true on success, false on failure.
*/

public bool:AskPluginLoad(Handle:myself, bool:late, String:error[], err_max) {
	// For other plugins to check if player has upgrade
	CreateNative("KrXsurupVersion", __Native_Version);
	CreateNative("KrXsurupIsEnabled", __Native_Is_Enabled);
	CreateNative("KrXsurupMaxUpgrades", __Native_Max_Upgrades);
	CreateNative("KrXsurupHasUpgrade", __Native_Has_Upgrade);
	CreateNative("KrXsurupAddUpgrade", __Native_Add_Upgrade);
	CreateNative("KrXsurupRemoveUpgrade", __Native_Remove_Upgrade);
	CreateNative("KrXsurupIsLaserOn", __Native_Is_Laser_On);
	CreateNative("KrXsurupCurrentAmmotype", __Native_Current_Ammotype);
	CreateNative("KrXsurupChangeAmmotype", __Native_Change_Ammotype);
	CreateNative("KrXsurupGetSpecialAmmo", __Native_Get_SpecialAmmo);
	CreateNative("KrXsurupAddSpecialAmmo", __Native_Add_SpecialAmmo);
	RegPluginLibrary("KrX_surup");
	return true;
}

public __Native_Version(Handle:plugin, numParams) {
	//	"buffer"		"string"	// String buffer to put hardcoded version value into
	//	>returns		"bool"		// True on success, False on failure
	
	new len;
	GetNativeStringLength(1, len);
	
	if(len < 10) return false;
	
	if(SetNativeString(1, PLUGIN_VERSION, len) == SP_ERROR_NONE) 
		return true;
	
	return false;
}

public __Native_Is_Enabled(Handle:plugin, numParams) {
	//  >returns		"bool"		// True if enabled, false if not
	
	if(!b_InvalidGameMode)
		return true;
	else
		return false;
}

public __Native_Max_Upgrades(Handle:plugin, numParams) {
	//	>returns			"short"		// Maximum Valid Upgrades
	
	return MAX_VALID_UPGRADES;
}

public __Native_Has_Upgrade(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	"upgIndex"		"short"		// Upgrade Index (starting from 0)
	//	>returns		"bool"		// Whether client has upgIndex
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);

	return b_Upgrades_Client[client][GetNativeCell(2)];
}

public __Native_Add_Upgrade(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	"upgIndex"		"short"		// Upgrade Index (starting from 0)
	//	>returns		"bool"		// True on success, false on failure.
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	GiveClientSpecificUpgrade(GetNativeCell(1), GetNativeCell(2));
	
	return b_Upgrades_Client[GetNativeCell(1)][GetNativeCell(2)];
}

public __Native_Remove_Upgrade(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	"upgIndex"		"short"		// Upgrade Index (starting from 0)
	//	>returns		"bool"		// True on success, false on failure.
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	RemoveSpecificUpgrade(GetNativeCell(1), GetNativeCell(2));
	
	if(!b_Upgrades_Client[GetNativeCell(1)][GetNativeCell(2)])
		return true;
	else
		return false;
}

public __Native_Is_Laser_On(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	>returns		"bool"		// true = on, false = off
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	return b_Upgrades_Laser[GetNativeCell(1)];
}

public __Native_Current_Ammotype(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	>returns		"short"		// Ammotype. 0=Normal, 1=HollowPoint, 2=Incendiary
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	return g_Upgrades_SpecialAmmotype[GetNativeCell(1)];
}

public __Native_Change_Ammotype(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	"ammoType"		"short"		// Ammotype. 0=Normal, 1=HollowPoint, 2=Incendiary
	//	>returns		"bool"		// True on success, False on failure (Probably wrong ammoType or no ammo)
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	if(GetNativeCell(2) > MAX_SPECIALAMMOTYPES) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Ammotype. Valid values are 0 to %d", MAX_SPECIALAMMOTYPES);
	}
	
	return ChangeAmmoType(GetNativeCell(1), GetNativeCell(2));
}

public __Native_Get_SpecialAmmo(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	"ammoType"		"short"		// Ammotype. 1=HollowPoint, 2=Incendiary
	//	>returns		"short"		// Amount of that SA, else -1 on failure. Probably means wrong ammoType
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	// Check if its not exceeding the number of ammotypes this version has, and you're not checking normal ammo
	if(GetNativeCell(2) <= MAX_SPECIALAMMOTYPES && GetNativeCell(2) != 0) {
		return g_Upgrades_SpecialAmmo[GetNativeCell(2)-1][GetNativeCell(1)];
	} else {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Ammotype. Valid values are 1 to %d", MAX_SPECIALAMMOTYPES);
	}
}

public __Native_Add_SpecialAmmo(Handle:plugin, numParams) {
	//	"client"		"short"		// Client Index
	//	"ammoType"		"short"		// Ammotype. 1=HollowPoint, 2=Incendiary
	//	"amount"		"short"		// Amount of ammo to add. Use negative value to minus
	//	>returns		"bool"		// True on success, false on failure. Possible causes: Invalid ammoType
	
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not a Survivor", client);
	
	if(GetNativeCell(2) <= MAX_SPECIALAMMOTYPES && GetNativeCell(2) != 0) {
		g_Upgrades_SpecialAmmo[GetNativeCell(2)][GetNativeCell(1)] += GetNativeCell(3);
		return true;
	} else {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Ammotype. Valid values are 1 to %d", MAX_SPECIALAMMOTYPES);
	}
}

/*** -- END Plugin Natives -- ***/

public OnPluginStart() {
	// Some functions like FindTarget(); needs it
	LoadTranslations("common.phrases");
	LoadTranslations("KrX_surup.phrases");

	// AddUpgrade and RemoveUpgrade SDKCall settings
	// Try the windows version first.
	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "\xA1****\x83***\x57\x8B\xF9\x0F*****\x8B***\x56\x51\xE8****\x8B\xF0\x83\xC4\x04", 34))
	{
		PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer10AddUpgradeE19SurvivorUpgradeType", 0);
	}
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	AddUpgrade = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "\x51\x53\x55\x8B***\x8B\xD9\x56\x8B\xCD\x83\xE1\x1F\xBE\x01\x00\x00\x00\x57\xD3\xE6\x8B\xFD\xC1\xFF\x05\x89***", 32))
	{
		PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer13RemoveUpgradeE19SurvivorUpgradeType", 0);
	}
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	RemoveUpgrade = EndPrepSDKCall();
	
	IndexToUpgrade[0] = 1;
	UpgradeShortInfo[0] = "UPGRADE_0_SHORT";
	UpgradeLongInfo[0] = "UPGRADE_0_LONG";
	UpgradeAllowed[0] = CreateConVar("surup_allow_kevlar_body_armor", "1", "Give the Kevlar Body Armor upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[1] = 8;
	UpgradeShortInfo[1] = "UPGRADE_1_SHORT";
	UpgradeLongInfo[1] = "UPGRADE_1_LONG"; 
	UpgradeAllowed[1] = CreateConVar("surup_allow_raincoat", "1", "Give the Raincoat upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[2] = 11;
	UpgradeShortInfo[2] = "UPGRADE_2_SHORT";
	UpgradeLongInfo[2] = "UPGRADE_2_LONG";
	UpgradeAllowed[2] = CreateConVar("surup_allow_climbing_chalk", "1", "Give the Climbing Chalk upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[3] = 12;
	UpgradeShortInfo[3] = "UPGRADE_3_SHORT";
	UpgradeLongInfo[3] = "UPGRADE_3_LONG";
	UpgradeAllowed[3] = CreateConVar("surup_allow_second_wind", "1", "Give the Second Wind upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[4] = 13;
	UpgradeShortInfo[4] = "UPGRADE_4_SHORT";
	UpgradeLongInfo[4] = "UPGRADE_4_LONG";
	UpgradeAllowed[4] = CreateConVar("surup_allow_goggles", "1", "Give the Goggles upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[5] = 16;
	UpgradeShortInfo[5] = "UPGRADE_5_SHORT";
	UpgradeLongInfo[5] = "UPGRADE_5_LONG";
	UpgradeAllowed[5] = CreateConVar("surup_allow_hot_meal", "0", "Give the Hot Meal upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[6] = 17;
	UpgradeShortInfo[6] = "UPGRADE_6_SHORT";
	UpgradeLongInfo[6] = "UPGRADE_6_LONG";
	UpgradeAllowed[6] = CreateConVar("surup_allow_laser_sight", "2", "Give the Laser Sight upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[7] = 19;
	UpgradeShortInfo[7] = "UPGRADE_7_SHORT";
	UpgradeLongInfo[7] = "UPGRADE_7_LONG";
	UpgradeAllowed[7] = CreateConVar("surup_allow_combat_sling", "1", "Give the Combat Sling upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[8] = 20;
	UpgradeShortInfo[8] = "UPGRADE_8_SHORT";
	UpgradeLongInfo[8] = "UPGRADE_8_LONG";
	UpgradeAllowed[8] = CreateConVar("surup_allow_large_clip", "0", "Give the Large Clip upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[9] = 21;
	UpgradeShortInfo[9] = "UPGRADE_9_SHORT";
	UpgradeLongInfo[9] = "UPGRADE_9_LONG";
	UpgradeAllowed[9] = CreateConVar("surup_allow_hollow_point_ammo", "1", "Give the Hollow Point Ammo upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[10] = 26;
	UpgradeShortInfo[10] = "UPGRADE_10_SHORT";
	UpgradeLongInfo[10] = "UPGRADE_10_LONG";
	UpgradeAllowed[10] = CreateConVar("surup_allow_knife", "1", "Give the Knife upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[11] = 27;
	UpgradeShortInfo[11] = "UPGRADE_11_SHORT";
	UpgradeLongInfo[11] = "UPGRADE_11_LONG";
	UpgradeAllowed[11] = CreateConVar("surup_allow_smelling_salts", "1", "Give the Smelling Salts upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[12] = 28;
	UpgradeShortInfo[12] = "UPGRADE_12_SHORT";
	UpgradeLongInfo[12] = "UPGRADE_12_LONG";
	UpgradeAllowed[12] = CreateConVar("surup_allow_ointment", "1", "Give the Ointment upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[13] = 29;
	UpgradeShortInfo[13] = "UPGRADE_13_SHORT";
	UpgradeLongInfo[13] = "UPGRADE_13_LONG";
	UpgradeAllowed[13] = CreateConVar("surup_allow_reloader", "1", "Give the Reloader upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[14] = 30;
	UpgradeShortInfo[14] = "UPGRADE_14_SHORT";
	UpgradeLongInfo[14] = "UPGRADE_14_LONG";
	UpgradeAllowed[14] = CreateConVar("surup_allow_incendiary_ammo", "1", "Give the Incendiary Ammo upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	IndexToUpgrade[15] = 30;
	UpgradeShortInfo[15] = "UPGRADE_15_SHORT";
	UpgradeLongInfo[15] = "UPGRADE_15_LONG";
	UpgradeAllowed[15] = CreateConVar("surup_allow_adrenaline", "1", "Give the Adrenaline upgrade? (0=No,1=Yes,2=At Spawn)", CVAR_FLAGS, true, 0.0, true, 2.0);
	
	UpgradeSpecialAmmoName[0] = "LABEL_HOLLOWPOINT";
	UpgradeSpecialAmmoName[1] = "LABEL_INCENDIARY";
	
	UpgradesSpawnAll = CreateConVar("surup_upgrades_spawn_all", "3", "How many random upgrades to give survivors when they spawn.", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	#if BOOL_UPGRADE_WITCH
	UpgradesWitchCr0wned = CreateConVar("surup_upgrades_witch_cr0wned", "1", "How many random upgrades to give the survivor who cr0wned (headshot-killed) a witch. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesWitchKiller = CreateConVar("surup_upgrades_witch_killer", "1", "How many random upgrades to give the survivor who personally killed the witch. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesWitchAll = CreateConVar("surup_upgrades_witch_all", "1", "How many random upgrades to give survivors when their team kills the witch. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	#endif
	#if BOOL_UPGRADE_TANK
	UpgradesTankSpawn = CreateConVar("surup_upgrades_tank_spawn", "1", "How many random upgrades to give survivors when a tank spawns. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesTankKiller = CreateConVar("surup_upgrades_tank_killer", "1", "How many random upgrades to give the survivor who personally killed the tank. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesTankAll = CreateConVar("surup_upgrades_tank_all", "1", "How many random upgrades to give survivors when their team kills the tank. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	#endif
	#if BOOL_UPGRADE_HEAL
	UpgradesHealPlayer = CreateConVar("surup_upgrades_heal_person", "1", "How many random upgrades to give a survivor who heals another player. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesHealSelf = CreateConVar("surup_upgrades_heal_self", "1", "How many random upgrades to give a survivor who healed himself. (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesHealAmount = CreateConVar("surup_upgrades_heal_amount", "50", "The minimum amount of health to heal to give an upgrade", CVAR_FLAGS, true, 0.0, true, 100.0);
	#endif
	#if BOOL_UPGRADE_KILLS
	UpgradesKillCount = CreateConVar("surup_upgrades_kill_count", "40", "How many infected a survivor must kill before receiving upgrades? (0=Disabled)", CVAR_FLAGS, true, 0.0);
	UpgradesKillAmount = CreateConVar("surup_upgrades_kill_amount", "1", "How many random upgrades to give survivors when they kill surup_upgrades_kill_count infected, or multiplier of SpecialAmmo giving for surup_upgrades_kill_award 1 (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	UpgradesKillAward = CreateConVar("surup_upgrades_kill_award", "1", "What upgrades to give the player by kills? 0=Random Upgrades, 1=SpecialAmmo only, Add SpecialAmmo if already has both SpecialAmmos, 2=SpecialAmmo, give Random if has both SpecialAmmos", CVAR_FLAGS, true, 0.0, true, 2.0);
	#endif
	#if BOOL_UPGRADE_SAFEROOM
	UpgradesReachSaferoom = CreateConVar("surup_upgrades_reach_saferoom", "1", "How many random upgrades to give survivors when they reach a saferoom? (0=Disabled)", CVAR_FLAGS, true, 0.0, true, CVAR_MAX_UPGRADES);
	#endif
	UpgradeSpecialAmmoCount = CreateConVar("surup_upgrade_specialammo_count", "120", "How many bullets of Incendiary/HollowPoint ammo to give per giveupgrade? (0=unlimited)", CVAR_FLAGS, true, 0.0);
	UpgradeSpecialAmmoMinusSG = CreateConVar("surup_upgrade_specialammo_minussg", "5", "How many bullets (whole number) out of the SpecialAmmo reserve do you deduct when shooting shotgun bullets?", CVAR_FLAGS, true, 1.0);
	#if BOOL_SHOW_SPECIALAMMO
	UpgradeSpecialAmmoShow = CreateConVar("surup_upgrade_specialammo_show", "1", "Show SpecialAmmo remaining? (0=No, 1=CenterText above crosshair, 2=HintText, 3=ChatText-not recommended)", CVAR_FLAGS, true, 0.0, true, 3.0);
	#endif
	#if BOOL_SHOW_AMMOPANEL
	UpgradeSpecialAmmoPanelState = CreateConVar("surup_upgrade_specialammo_panel_state", "0", "Default state of persistent ammopanel. 0=Off, 1=On", CVAR_FLAGS, true, 0.0, true, 1.0);
	#endif
	#if BOOL_ALLOW_INCENDIARY
	UpgradeIncendiaryIgniteTankNoVS = CreateConVar("surup_upgrade_incendiary_ignitetank_nonvs", "1", "Incendiary Ammo upgrade: Does it light the tank on fire on Campaign/Survival? (0=No, 1=Yes)", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeIncendiaryIgniteTankVS = CreateConVar("surup_upgrade_incendiary_ignitetank_vs", "0", "Incendiary Ammo upgrade: Does it light the tank on fire on Versus? (0=No, 1=Yes)", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeIncendiaryIgniteSpecNoVS = CreateConVar("surup_upgrade_incendiary_ignitespecial_nonvs", "1", "Incendiary Ammo upgrade: Does it light up special infected on Campaign/Survival? (0=No, 1=Yes)", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeIncendiaryIgniteSpecVS = CreateConVar("surup_upgrade_incendiary_ignitespecial_vs", "0", "Incendiary Ammo upgrade: Does it light up special infected on Versus? (0=No, 1=Yes)", CVAR_FLAGS, true, 0.0, true, 1.0);
	#endif
	UpgradeAdrenalineMult = CreateConVar("surup_upgrade_adrenaline_multiplier", "1.25", "Adrenaline upgrade: By how much should the player's speed be multiplied by? Put a value below 0 to reduce speed", CVAR_FLAGS, true, 0.0);
	UpgradeReloaderSpeed = CreateConVar("surup_upgrade_reloader_speed", "0.5", "Reloader upgrade: How long should reloads take in seconds?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeReloaderShotgunSpeed = CreateConVar("surup_upgrade_reloader_shotgunspeed", "0.5", "Reloader upgrade: How long should shotgun reloads take in seconds?", CVAR_FLAGS, true, 0.0, true, 1.0);
	#if BOOL_DONT_RETAIN_UPGRADES
	ResetOnMissionLost = CreateConVar("surup_reset_on_missionlost", "0", "Reset all upgrades and don't/re-give initial upgrades on failing a mission? (0=No, 1=Re-give Initial, 2=Lose All Upgrades)", CVAR_FLAGS, true, 0.0, true, 2.0);
	ResetOnMapChange = CreateConVar("surup_reset_on_mapchange", "0", "Reset all upgrades and re-give initial upgrades on map change (Proceeding to next mission)", CVAR_FLAGS, true, 0.0, true, 1.0);
	ResetOnDeath = CreateConVar("surup_reset_on_death", "0", "Reset all upgrades when the player dies? (0=No, 1=Yes, re-give initial on saferoom, 2=Yes, DON'T re-give initial on saferoom)", CVAR_FLAGS, true, 0.0, true, 2.0);
	#endif
	LaserDefaultState = CreateConVar("surup_laser_default_state", "1", "Default state of lasers when given to players. (1=On, 0=Off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeBots = CreateConVar("surup_upgrade_bots", "2", "Do we give upgrades to bots? (0=No,1=Lasers-Only,2=Yes)", CVAR_FLAGS, true, 0.0, true, 2.0);
	VersusAnnounceToAll = CreateConVar("surup_versus_announce_to_all", "1", "Whether we announce to all players, including infected, the names of the upgrades, in versus (1=Yes, 0=No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	PluginVerbosity = CreateConVar("surup_verbosity", "2", "How much text output about upgrades players see (0=None, 3=Max, Default 2).", CVAR_FLAGS, true, 0.0, true, 3.0);
	
	#if BOOL_SELECTIVE_GAMEMODES
	// Game mode Cvars
	EnableCoop = CreateConVar("surup_enable_coop", "1", "Enable/Disable Survivor Upgrades in Coop (0=Disable,1=Enable)", CVAR_FLAGS, true, 0.0, true, 1.0);
	EnableSv = CreateConVar("surup_enable_sv", "1", "Enable/Disable Survivor Upgrades in Survival (0=Disable,1=Enable)", CVAR_FLAGS, true, 0.0, true, 1.0);
	EnableVersus = CreateConVar("surup_enable_vs", "0", "Enable/Disable Survivor Upgrades in Versus (0=Disable,1=Enable)", CVAR_FLAGS, true, 0.0, true, 1.0);
	#endif
	
	// Register commands (RegConsoleCmd also works with "say /<console command>")
	#if DEBUG
	RegAdminCmd("dbgaddupgindex", debug_AddUpgIndex, ADMFLAG_ROOT);
	RegAdminCmd("dbgremupgindex", debug_RemUpgIndex, ADMFLAG_ROOT);
	#endif
	// Admin Commands
	#if BOOL_ADMIN_COMMANDS
	RegAdminCmd("addupgrade", addUpgrade, ADMFLAG_KICK);				// Gives upgrade to client
	RegAdminCmd("removeupgrade", removeUpgrade, ADMFLAG_KICK);			// Takes upgrade from client
	RegAdminCmd("addrandomupgrades", addRandomUpgrades, ADMFLAG_KICK);	// Gives random upgrade to client
	RegAdminCmd("removeallupgrades", clearAllUpgrades, ADMFLAG_KICK);	// Takes all upgrades from client
	RegAdminCmd("listallupgrades", listAllUpgrades, ADMFLAG_KICK);		// Lists all available upgrades
	RegAdminCmd("listplayerupgrades", listPlayerUpgrades, ADMFLAG_KICK);			// Lists upgrades of client
	#endif
	// Client Commands
	RegConsoleCmd("upgrades", ShowUpgrades);					// Lists player's upgrades
	RegConsoleCmd("listupgrades", ShowUpgrades);				// Lists player's upgrades, for backward compatibility
	RegConsoleCmd("laser", ToggleLaser);						// Toggles Laser
	RegConsoleCmd("upghelp", UserHelp);							// Shows help for Upgrades
	#if BOOL_SHOW_AMMOPANEL
	RegConsoleCmd("ammotype", ShowAmmoTypePanel);				// Shows current ammotype and changing ammotypes
	#endif
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Registered Commands.", PLUGIN_TAG);
	#endif
	
	// Variable Initialisation
	#if BOOL_UPGRADE_TANK
	b_BlockOnTankSpawn = false;
	#endif
	b_CanAnnounce = false;
	b_Enabled = false;
	b_Initialised = false;
	#if BOOL_DONT_RETAIN_UPGRADES
	b_MissionLost = false;
	#endif
	
	CreateConVar("survivorupgradeskrx_version", PLUGIN_VERSION, "Version of KrX's Survivor Upgrades", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	// Generate autoconfig in /left4dead/cfg/sourcemod/
	AutoExecConfig(true, PLUGIN_CONFIGFILE);
	
	// Hook round_start to notify players that its been disabled
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public HookEvents() {
	if(!b_Hooked) {
		HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);			// Tracks when the round ends
		#if BOOL_DONT_RETAIN_UPGRADES
		HookEvent("mission_lost", Event_MissionLost, EventHookMode_PostNoCopy);		// Resets players' upgrades on every mission lost
		#endif
		
		#if BOOL_UPGRADE_TANK
		// Tank
		HookEvent("tank_spawn", Event_TankSpawn, EventHookMode_Post);				// Tracks when the Tank Spawns
		HookEvent("tank_killed", Event_TankKilled, EventHookMode_Post);				// Tracks when the Tank dies
		#endif
		
		#if BOOL_UPGRADE_WITCH
		// Witch
		HookEvent("witch_killed", Event_WitchKilled, EventHookMode_Post);			// Tracks when the Witch dies
		HookEvent("award_earned", Event_Award, EventHookMode_Post);					// For cr0wned
		#endif
		
		// Why don't check for BOOL_UPGRADE_HEAL? We need it for Adrenaline!
		// Healing
		HookEvent("heal_success", Event_HealSuccess, EventHookMode_Post);			// Tracks when players heal
		HookEvent("pills_used", Event_PillsUsed, EventHookMode_Post);				// Tracks when players use pills for adrenaline
		
		// Track number of bullets shot
		HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);				// Tracks when weapon is fired
		
		// Player Events
		HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);				// Tracks when the player changes team
		HookEvent("player_bot_replace", Event_PlayerBotReplace, EventHookMode_Pre);	// Tracks when the Player is replaced by a Bot
		HookEvent("bot_player_replace", Event_BotPlayerReplace, EventHookMode_Pre);	// Tracks when the Bot is replaced by a Player
		#if BOOL_ALLOW_INCENDIARY
		HookEvent("infected_hurt", Event_InfectedHurt, EventHookMode_Post);			// Tracks when non-playable infected are hurt
		HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);				// Tracks when playable classes are hurt
		#endif
		#if BOOL_UPGRADE_KILLS
		HookEvent("infected_death", Event_InfectedDeath, EventHookMode_Post);		// Tracks when infected die
		#endif
		#if BOOL_DONT_RETAIN_UPGRADES
		HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);			// Tracks when a player dies
		#endif
		// Only if current GameMode is Versus
		#if BOOL_SELECTIVE_GAMEMODES
		if(strcmp(g_CurrentMode, "versus", false) == 1) {
		#endif
			HookEvent("player_entered_start_area", Event_PlayerEnteredStartArea, EventHookMode_Post);
		#if BOOL_SELECTIVE_GAMEMODES
		}
		#endif
		
		// Ending event
		HookEvent("finale_vehicle_leaving", Event_FinaleVehicleLeaving, EventHookMode_PostNoCopy);
		
		// Client say commands, used to remove all the #L4D_Upgrade stuff
		HookUserMessage(GetUserMessageId("SayText"), SayTextHook, true);
		
		b_Hooked = true;
		
		#if DEBUG
		PrintToServer("%s Server #DEBUG: Events hooked!", PLUGIN_TAG);
		#endif
	}
}

public UnHookEvents() {
	if(b_Hooked) {
		
		UnhookEvent("round_end", Event_RoundEnd);			// Tracks when the round ends
		#if BOOL_DONT_RETAIN_UPGRADES
		UnhookEvent("mission_lost", Event_MissionLost);		// Resets players' upgrades on every mission lost
		#endif
		
		#if BOOL_UPGRADE_TANK
		// Tank
		UnhookEvent("tank_spawn", Event_TankSpawn);			// Tracks when the Tank Spawns
		UnhookEvent("tank_killed", Event_TankKilled);				// Tracks when the Tank dies
		#endif
		
		#if BOOL_UPGRADE_WITCH
		// Witch
		UnhookEvent("witch_killed", Event_WitchKilled);			// Tracks when the Witch dies
		UnhookEvent("award_earned", Event_Award);					// For cr0wned
		#endif
		
		// Why don't check for BOOL_UPGRADE_HEAL? We need it for Adrenaline!
		// Healing
		UnhookEvent("heal_success", Event_HealSuccess);			// Tracks when players heal
		UnhookEvent("pills_used", Event_PillsUsed);				// Tracks when players use pills for adrenaline

		
		// Track number of bullets shot
		UnhookEvent("weapon_fire", Event_WeaponFire);				// Tracks when weapon is fired
		
		// Player Events
		UnhookEvent("player_team", Event_PlayerTeam);				// Tracks when the player changes team
		UnhookEvent("player_bot_replace", Event_PlayerBotReplace);// Tracks when the Player is replaced by a Bot
		UnhookEvent("bot_player_replace", Event_BotPlayerReplace);// Tracks when the Bot is replaced by a Player
		#if BOOL_ALLOW_INCENDIARY
		UnhookEvent("infected_hurt", Event_InfectedHurt);			// Tracks when non-playable infected are hurt
		UnhookEvent("player_hurt", Event_PlayerHurt);				// Tracks when playable classes are hurt
		#endif
		#if BOOL_UPGRADE_KILLS
		UnhookEvent("infected_death", Event_InfectedDeath);		// Tracks when infected die
		#endif
		#if BOOL_DONT_RETAIN_UPGRADES
		UnhookEvent("player_death", Event_PlayerDeath);			// Tracks when a player dies
		#endif
		// Only if current GameMode is Versus
		#if BOOL_SELECTIVE_GAMEMODES
		if(strcmp(g_CurrentMode, "versus", false) == 1) {
		#endif
			UnhookEvent("player_entered_start_area", Event_PlayerEnteredStartArea);
		#if BOOL_SELECTIVE_GAMEMODES
		}
		#endif
		
		// Ending event
		UnhookEvent("finale_vehicle_leaving", Event_FinaleVehicleLeaving);
		
		// Client say commands, used to remove all the #L4D_Upgrade stuff
		UnhookUserMessage(GetUserMessageId("SayText"), SayTextHook, true);
		
		b_Hooked = false;
		
		#if DEBUG
		PrintToServer("%s Server #DEBUG: Events Unhooked!", PLUGIN_TAG);
		#endif
	}
}

public OnConfigsExecuted() {
	// This is called after OnMapStart() and OnAutoConfigsBuffered() -- in that order.
	// Best place to initialize based on ConVar data
	
	// Check For Gamemode - disable according to ConVars
	GetConVarString(FindConVar("mp_gamemode"), g_CurrentMode, MAX_LEN_GAMEMODE+1);
	
	#if BOOL_SELECTIVE_GAMEMODES
	// Check current gamemode then check if enabled
	if (StrContains(g_CurrentMode, "coop", false) != -1 && GetConVarBool(EnableCoop)) {
		b_InvalidGameMode = false;
	} else if (StrContains(g_CurrentMode, "survival", false) != -1 && GetConVarBool(EnableSv)) {
		b_InvalidGameMode = false;
	} else if (StrContains(g_CurrentMode, "versus", false) != -1 && GetConVarBool(EnableVersus)) {
		b_InvalidGameMode = false;
	} else { 
		b_InvalidGameMode = true;
	}
	#else
	b_InvalidGameMode = false;
	#endif
	
	if(strcmp(g_CurrentMode, "versus", false) == 1)
		b_IsVersus = true;
	else
		b_IsVersus = false;
	
	#if BOOL_SELECTIVE_GAMEMODES
	if(!b_InvalidGameMode) {
	#endif
		HookEvents();
		
		new Handle:SurvivorUpgradesConvar = FindConVar("survivor_upgrades");
		
		// Setting of ConVars
		// Use while() loop to ensure convar is set. Hopefully fixes weird rare bug
		#if !FIX_RARE_BUG_METHOD
		while(GetConVarInt(SurvivorUpgradesConvar) != 1) {
		#endif
			SetConVarInt(SurvivorUpgradesConvar, 1, true, false);
		#if !FIX_RARE_BUG_METHOD
		}
		#endif
		
		#if FIX_RARE_BUG_METHOD
		// Add delay of setting survivor_upgrades second time, fixes rare bug of it not activating
		CreateTimer(5.0, SetSurvivorUpgradesCVar);
		#endif
		
		// Reloader Upgrade durations
		SetConVarFloat(FindConVar("survivor_upgrade_reload_duration"), GetConVarFloat(UpgradeReloaderSpeed), true, false);
		SetConVarFloat(FindConVar("survivor_upgrade_reload_shotgun_duration"), GetConVarFloat(UpgradeReloaderShotgunSpeed), true, false);
		
		b_CanAnnounce = true;
		
		// Storing static ConVar values
		#if BOOL_ALLOW_INCENDIARY
		if(b_IsVersus) {
			b_IgniteSpecial = GetConVarBool(UpgradeIncendiaryIgniteSpecVS);
			b_IgniteTank = GetConVarBool(UpgradeIncendiaryIgniteTankVS);
		} else {
			b_IgniteSpecial = GetConVarBool(UpgradeIncendiaryIgniteSpecNoVS);
			b_IgniteTank = GetConVarBool(UpgradeIncendiaryIgniteTankNoVS);
		}
		#endif
		g_Verbosity = GetConVarInt(PluginVerbosity);
		g_UpgradeBots = GetConVarInt(UpgradeBots);
		#if BOOL_UPGRADE_HEAL
		g_UpgradesHealPlayer = GetConVarInt(UpgradesHealPlayer);
		g_UpgradesHealSelf = GetConVarInt(UpgradesHealSelf);
		g_UpgradesHealAmount = GetConVarInt(UpgradesHealAmount);
		#endif
		#if BOOL_UPGRADE_KILLS
		g_UpgradesKillAmount = GetConVarInt(UpgradesKillAmount);
		g_UpgradesKillCount = GetConVarInt(UpgradesKillCount);
		g_UpgradesKillIA = GetConVarInt(UpgradeAllowed[14]);
		g_UpgradesKillHP = GetConVarInt(UpgradeAllowed[9]);
		if(!g_UpgradesKillIA && !g_UpgradesKillHP)
			g_UpgradesKillAward = 0;
		else
			g_UpgradesKillAward = GetConVarInt(UpgradesKillAward);
		#endif
		g_UpgradeSpecialAmmoCount = GetConVarInt(UpgradeSpecialAmmoCount);
		g_UpgradeSpecialAmmoMinusSG = GetConVarInt(UpgradeSpecialAmmoMinusSG);
		if(g_UpgradeSpecialAmmoMinusSG < 1) {
			g_UpgradeSpecialAmmoMinusSG = 1;
		}
		#if BOOL_SHOW_SPECIALAMMO
		g_UpgradeSpecialAmmoShow = GetConVarInt(UpgradeSpecialAmmoShow);
		#endif
		
		b_LaserDefaultState = GetConVarBool(LaserDefaultState);
		b_VersusAnnounceToAll = GetConVarBool(VersusAnnounceToAll);
		
		g_UpgradeAdrenalineMult = GetConVarFloat(UpgradeAdrenalineMult);
		speedOffset = FindSendPropInfo("CTerrorPlayer","m_flLaggedMovementValue");
		// Plugin Compat: olj' Pills Addiction
		if((FindConVar("l4d_pillsaddiction_adrenaline_boost_enabled") != INVALID_HANDLE) && (GetConVarInt(FindConVar("l4d_pillsaddiction_adrenaline_boost_enabled")) == 1)) {
			b_PillsAddictionAdrenaline = true;
		} else {
			b_PillsAddictionAdrenaline = false;
		}
		#if DEBUG_EXPERIMENTAL
		laserColourOffset[0] = FindSendPropInfo("CTEBeamEnts", "r");
		laserColourOffset[1] = FindSendPropInfo("CTEBeamEnts", "g");
		laserColourOffset[2] = FindSendPropInfo("CTEBeamEnts", "b");
		#endif
		
		#if DEBUG
		PrintToServer("%s Server #DEBUG: Gotten ConVars in OnConfigsExecuted!", PLUGIN_TAG);
		#endif
		
		if(!b_Initialised) {
			#if BOOL_SHOW_AMMOPANEL
			b_UpgradeSpecialAmmoPanelState = GetConVarBool(UpgradeSpecialAmmoPanelState);
			#endif
			// Set initial states of stuffs
			for(new _z=0; _z < MAXPLAYERS; _z++) {
				#if BOOL_SHOW_AMMOPANEL
				if(b_UpgradeSpecialAmmoPanelState)
					b_Persistent_Menu[_z] = true;
				else
					b_Persistent_Menu[_z] = false;
				#endif
				#if BOOL_SHOW_SPECIALAMMO
				b_Show_Ammocount[_z] = true;
				#endif
				#if BOOL_ON_AUTOSWITCH
				b_SpecialAmmo_AutoSwitch[_z] = true;
				#else
				b_SpecialAmmo_AutoSwitch[_z] = false;
				#endif
			}
			b_Initialised = true;
			
			#if DEBUG
			PrintToServer("%s Server #DEBUG: Initialization done!", PLUGIN_TAG);
			#endif
		}
		
		// Copied from Jerrith's Survivor Upgrades - anyone has any ideas?
		/*SetConVarInt(FindConVar("vs_max_team_switches"), 9999);
		SetConVarInt(FindConVar("sv_vote_issue_change_difficulty_allowed"), 1, true, false);
		SetConVarInt(FindConVar("sv_vote_issue_change_map_now_allowed"), 1, true, false);
		SetConVarInt(FindConVar("sv_vote_issue_change_mission_allowed"), 1, true, false);
		SetConVarInt(FindConVar("sv_vote_issue_restart_game_allowed"), 1, true, false);*/
		
		#if BOOL_DONT_RETAIN_UPGRADES
		if(GetConVarInt(ResetOnMapChange)) {
			HookEvent("map_transition", Event_RoundEnd, EventHookMode_Pre);			// Resets players' upgrades on next mission
		}
		#endif
		
	#if BOOL_SELECTIVE_GAMEMODES
	} else {
		UnHookEvents();
		g_Verbosity = 0;
		b_CanAnnounce = false;
		b_Enabled = false;
	}
	#endif
	
	#if DEBUG
	PrintToServer("%s Server #DEBUG: ConVars Set in OnConfigsExecuted!", PLUGIN_TAG);
	#endif
	
	// Update ConVar for version display
	SetConVarString(FindConVar("survivorupgradeskrx_version"), PLUGIN_VERSION, false, false);
	
	#if BOOL_FORCE_MOTD
	// Set motd_enabled 1 to fix servers not showing MOTD
	SetConVarString(FindConVar("motd_enabled"), "1", true, false);
	#endif
	
	#if BOOL_SHOW_SERVER_MESSAGES
	PrintToServer("%s Server: KrX's Survivor Upgrades v%s %T", PLUGIN_TAG, PLUGIN_VERSION, "SERVER_LOADED_SUCCESSFULLY", LANG_SERVER);
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode) 
		PrintToServer("%s Server: KrX's Survivor Upgrades %T", PLUGIN_TAG, "SERVER_PLUGIN_DISABLED", LANG_SERVER, g_CurrentMode);
	else
	#endif
		PrintToServer("%s Server: KrX's Survivor Upgrades %T", PLUGIN_TAG, "SERVER_PLUGIN_ENABLED", LANG_SERVER, g_CurrentMode);
	#endif
}

/*** -- END Plugin Initialisation -- ***/

/*** -- Main startup and shutdown functions -- ***/
public ActivateUpgrades() {
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode) {
		SetConVarInt(FindConVar("survivor_upgrades"), 0, true, false);
		PrintToChatAll("%s KrX's Survivor Upgrades v%s %t", PLUGIN_TAG_C, PLUGIN_VERSION, "CHATALL_PLUGIN_DISABLED", g_CurrentMode);
		#if BOOL_SHOW_SERVER_MESSAGES
		PrintToServer("%s KrX's Survivor Upgrades v%s %T", PLUGIN_TAG, PLUGIN_VERSION, "SERVER_PLUGIN_DISABLED", LANG_SERVER, g_CurrentMode);
		#endif
		ResetValues();
	} else {
	#endif
		// Check if Verbosity > 0, then check if survivor_upgrades have been enabled
		if(GetConVarInt(FindConVar("survivor_upgrades"))) {
			b_Enabled = true;
			if(g_Verbosity)
				PrintToChatAll("%s KrX's Survivor Upgrades v%s %t", PLUGIN_TAG_C, PLUGIN_VERSION, "CHATALL_PLUGIN_ENABLED");
		}
		// GiveAllInitialUpgrades
		CreateTimer(1.0, GiveAllInitialUpgrades, 0);
		#if DEBUG
		PrintToServer("%s Server #DEBUG: ActivateUpgrades(); Setting GiveInitialUpgrades to 1.0 seconds", PLUGIN_TAG);
		#endif
		#if BOOL_SHOW_SERVER_MESSAGES
		PrintToServer("%s KrX's Survivor Upgrades v%s %T", PLUGIN_TAG, PLUGIN_VERSION, "SERVER_PLUGIN_ENABLED", LANG_SERVER, g_CurrentMode);
		#endif
	#if BOOL_SELECTIVE_GAMEMODES
	}
	#endif
}

public ResetValues() {
	// Resets all clients values, in-game or not
	b_CanAnnounce = false;
	#if BOOL_UPGRADE_TANK
	b_BlockOnTankSpawn = false;
	#endif
	for(new i = 1; i < MaxClients; i++) {
		g_Upgrades_SpecialAmmotype[i] = 0;
		#if BOOL_SHOW_AMMOPANEL
		if(b_UpgradeSpecialAmmoPanelState)
			b_Persistent_Menu[i] = true;
		else
			b_Persistent_Menu[i] = false;
		#endif
		b_Upgrades_GivenInit[i] = false;
		b_Upgrades_Laser[i] = false;
		b_BotControlled[i] = false;
		for(new k = 0; k < MAX_SPECIALAMMOTYPES; k++) {
			g_Upgrades_SpecialAmmo[k][i] = 0;
		}
		g_Upgrades_SpecialAmmotype[i] = 0;
		#if BOOL_UPGRADE_KILLS
		g_Upgrades_TrackKills[i] = 0;
		#endif
		// Clear plugin registry of client's upgrades, and remove upgrade
		for(new j = 0; j < MAX_VALID_UPGRADES+1; j++) {
			// Clear registry
			b_Upgrades_Client[i][j] = false;
			// Remove upgrade
			if(IsClientInGame(i))
				SDKCall(RemoveUpgrade, i, IndexToUpgrade[j]);
		}
		// Reset Adrenaline
		if(IsClientInGame(i) && IsPlayerAlive(i))
			SetEntDataFloat(i, speedOffset, 1.0, true);
	}
	CreateTimer(0.5, CanAnnounce);
}

/*** -- END Main startup and shutdown functions -- ***/

/*** -- Events! -- ***/

// Order: Event_MissionLost -> Event_RoundEnd -> Event_RoundStart
public Action:Event_MissionLost(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_MissionLost called", PLUGIN_TAG);
	#endif
	
	// event mission_lost will be called before round_end if you lose a mission
	#if BOOL_SHOW_SERVER_MESSAGES
	PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_MISSION_LOST", LANG_SERVER);
	#endif
	#if BOOL_DONT_RETAIN_UPGRADES
	b_MissionLost = true;	// Only set the variable - Event_RoundEnd and Event_RoundStart will handle resetting
	#endif
	
	return Plugin_Continue;
}

// Triggers at any round start, even after a mission_lost
public Action:Event_RoundStart(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_RoundStart called", PLUGIN_TAG);
	#endif
	
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode) {
		ResetValues();
		SetConVarInt(FindConVar("survivor_upgrades"), 0, true, false);
		return Plugin_Continue;
	}
	#endif
	
	#if BOOL_DONT_RETAIN_UPGRADES
	if(!b_MissionLost) {
	#endif
		#if BOOL_UPGRADE_SAFEROOM
		// Reached SafeRoom upgrade
		if(GetConVarInt(UpgradesReachSaferoom) > 0) {
			CreateTimer(0.9, GiveSafeRoomUpgrades, GetConVarInt(UpgradesReachSaferoom));
		}
		#endif
		
		// Activate Upgrades!
		ActivateUpgrades();
		
		if(b_IsVersus)
			RemoveAllUpgrades(INVALID_HANDLE, -1);
		
		#if BOOL_SHOW_SERVER_MESSAGES
		PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_ROUND_START", LANG_SERVER);
		#endif
	#if BOOL_DONT_RETAIN_UPGRADES
	} else {
		// ROUND START AFTER MISSION LOST
		if(GetConVarInt(ResetOnMissionLost)) {
			ResetValues();
			// If its 1, re-give initial upgrades
			if(GetConVarInt(ResetOnMissionLost) == 1) {
				CreateTimer(1.0, GiveAllInitialUpgrades, 0);
			}
			#if BOOL_SHOW_SERVER_MESSAGES
			PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_ROUND_START_LOST_RESET", LANG_SERVER);
			#endif
		} else {
			for(new i = 1; i < MaxClients; i++) {
				if(IsClientInGame(i) && GetClientTeam(i) == SURVIVORS_TEAMNUM) {
					CreateTimer(1.0, ReGiveClientUpgrades, i);
				}
			}
			#if BOOL_SHOW_SERVER_MESSAGES
			PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_ROUND_START_LOST_NORESET", LANG_SERVER);
			#endif
		}
		b_MissionLost = false;	// Reset temp variable
	}
	#endif
	
	// Check Laser
	CreateTimer(10.0, CheckLaser);
	return Plugin_Continue;
}

public Action:Event_RoundEnd(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_RoundEnd called", PLUGIN_TAG);
	#endif
	
	#if BOOL_DONT_RETAIN_UPGRADES
	if(!b_MissionLost) {
		#if BOOL_SHOW_SERVER_MESSAGES
		PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_ROUND_END", LANG_SERVER);
		#endif
		
		// Reset on Map Change, when RoundStart plugin should automatically GiveInitialUpgrades()
		#if BOOL_DONT_RETAIN_UPGRADES
		if(GetConVarInt(ResetOnMapChange))
			ResetValues();
		#endif	
	} else {
	#endif
		// MISSION LOST! =(
		#if BOOL_SHOW_SERVER_MESSAGES
		PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_ROUND_END_LOST", LANG_SERVER);
		#endif
		b_Enabled = false;
	#if BOOL_DONT_RETAIN_UPGRADES
	}
	#endif
	// Turn off survivor upgrades to prevent random upgrade giving at saferoom
	//SetConVarInt(FindConVar("survivor_upgrades"), 0, true, false);
	return Plugin_Continue;
}

// Triggers when the Finale Vehicle is leaving
public Action:Event_FinaleVehicleLeaving(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_FinaleVehicleLeaving called", PLUGIN_TAG);
	#endif
	
	// Finale check - prevent upgrades giving 'cos of tank griefing
	// Disable upgrade-giving
	b_Enabled = false;
	
	// -1 to remove all clients' upgrades
	RemoveAllUpgrades(INVALID_HANDLE, -1);
	
	#if BOOL_SHOW_SERVER_MESSAGES
	PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_FINALE_VEHICLE_LEAVING", LANG_SERVER);
	#endif
	
	return Plugin_Continue;
}

// For Versus Only
public Action:Event_PlayerEnteredStartArea(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PlayerEnteredStartArea called for client #%d: %N", PLUGIN_TAG, GetClientOfUserId(GetEventInt(event, "userid")), GetClientOfUserId(GetEventInt(event, "userid")));
	#endif
	
	CreateTimer(5.0, GiveInitialUpgrades, GetClientOfUserId(GetEventInt(event, "userid")));
	
	return Plugin_Continue;
}

// Player changed team
public Action:Event_PlayerTeam(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PlayerTeam called for %N: %d --> %d", PLUGIN_TAG, GetClientOfUserId(GetEventInt(event, "userid")), GetEventInt(event, "oldteam"), GetEventInt(event, "team"));
	#endif
	
	if(GetEventInt(event, "team") == 2) {
		new clientID = GetClientOfUserId(GetEventInt(event, "userid"));
		CreateTimer(3.0, GiveInitialUpgrades, clientID);
		CreateTimer(4.0, ReGiveClientUpgrades, clientID);
		return Plugin_Continue;
	}
	if(GetEventInt(event, "oldteam") == 2) {
		CreateTimer(2.0, RemoveAllUpgrades, GetClientOfUserId(GetEventInt(event, "userid")));
	}
	
	return Plugin_Continue;
}

// Bot replaced a player
public Action:Event_PlayerBotReplace(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PlayerBotReplace called", PLUGIN_TAG);
	#endif
	
	new playerClient = GetClientOfUserId(GetEventInt(event, "player"));
	new botClient = GetClientOfUserId(GetEventInt(event, "bot"));
	// Don't do anything to infected
	if(GetClientTeam(botClient) != SURVIVORS_TEAMNUM)	return Plugin_Continue;
	// Newly joined bot (not replacing anyone)
	if(playerClient == 0)
		return Plugin_Continue;
	b_Upgrades_GivenInit[botClient] = b_Upgrades_GivenInit[playerClient];
	b_Upgrades_Laser[botClient] = b_Upgrades_Laser[playerClient];
	for(new k = 0; k < MAX_SPECIALAMMOTYPES; k++) {
		g_Upgrades_SpecialAmmo[k][botClient] = g_Upgrades_SpecialAmmo[k][playerClient];
	}
	g_Upgrades_SpecialAmmotype[botClient] = g_Upgrades_SpecialAmmotype[playerClient];
	#if BOOL_UPGRADE_KILLS
	g_Upgrades_TrackKills[botClient] = g_Upgrades_TrackKills[playerClient];
	#endif
	for(new i = 0; i < MAX_VALID_UPGRADES+1; i++) {
		b_Upgrades_Client[botClient][i] = b_Upgrades_Client[playerClient][i];
		#if DEBUG
		if(b_Upgrades_Client[botClient][i]) {
			PrintToConsole(playerClient, "%s %d > %d Upgrade: %t", PLUGIN_TAG, botClient, playerClient, UpgradeShortInfo[i]);
			PrintToServer("%s %d > %d Upgrade: %T", PLUGIN_TAG, botClient, playerClient, UpgradeShortInfo[i], LANG_SERVER);
		}
		#endif
	}
	SetEntDataFloat(playerClient, speedOffset, 1.0, true);
	b_BotControlled[botClient] = true;
	CreateTimer(5.0, GiveInitialUpgrades, botClient);
	CreateTimer(6.0, ReGiveClientUpgrades, botClient);
	CheckLaser(INVALID_HANDLE);
	#if BOOL_SHOW_SERVER_MESSAGES
	PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_BOT_REPLACED_PLAYER", LANG_SERVER, botClient, playerClient);
	#endif
	
	return Plugin_Continue;
}

// Player replaced a bot
public Action:Event_BotPlayerReplace(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_BotPlayerReplace called", PLUGIN_TAG);
	#endif
	
	new playerClient = GetClientOfUserId(GetEventInt(event, "player"));
	new botClient = GetClientOfUserId(GetEventInt(event, "bot"));
	// Don't do anything to infected
	if(GetClientTeam(playerClient) != SURVIVORS_TEAMNUM)	return Plugin_Continue;
	b_Upgrades_GivenInit[playerClient] = b_Upgrades_GivenInit[botClient];
	b_Upgrades_Laser[playerClient] = b_Upgrades_Laser[botClient];
	for(new k = 0; k < MAX_SPECIALAMMOTYPES; k++) {
		g_Upgrades_SpecialAmmo[k][playerClient] = g_Upgrades_SpecialAmmo[k][botClient];
	}
	g_Upgrades_SpecialAmmotype[playerClient] = g_Upgrades_SpecialAmmotype[botClient];
	#if BOOL_UPGRADE_KILLS
	g_Upgrades_TrackKills[playerClient] = g_Upgrades_TrackKills[botClient];
	#endif
	for(new i = 0; i < MAX_VALID_UPGRADES+1; i++) {
		b_Upgrades_Client[playerClient][i] = b_Upgrades_Client[botClient][i];
		#if DEBUG
		if(b_Upgrades_Client[playerClient][i]) {
			PrintToConsole(playerClient, "%s %d > %d Upgrade: %t", PLUGIN_TAG, playerClient, botClient, UpgradeShortInfo[i]);
			PrintToServer("%s %d > %d Upgrade: %T", PLUGIN_TAG, playerClient, botClient, UpgradeShortInfo[i], LANG_SERVER);
		}
		#endif
	}
	SetEntDataFloat(botClient, speedOffset, 1.0, true);
	b_BotControlled[botClient] = false;
	#if BOOL_SHOW_AMMOPANEL
	b_Persistent_Menu[playerClient] = true;
	#endif
	CreateTimer(5.0, GiveInitialUpgrades, playerClient);
	CreateTimer(6.0, ReGiveClientUpgrades, playerClient);
	CheckLaser(INVALID_HANDLE);
	if(g_Verbosity > 0)
		ListMyUpgrades(playerClient, true);
	#if BOOL_SHOW_SERVER_MESSAGES
	PrintToServer("%s Server: %T", PLUGIN_TAG, "SERVER_PLAYER_REPLACED_BOT", LANG_SERVER, playerClient, botClient);
	#endif
	
	return Plugin_Continue;
}

#if BOOL_UPGRADE_HEAL
// Gives a upgrade for who heal another player
// Also checks and re gives Adrenaline
public Action:Event_HealSuccess(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_HealSuccess called", PLUGIN_TAG);
	#endif
	
	// Gives a upgrade for the one who healed somebody
	new healerClient = GetClientOfUserId(GetEventInt(event, "userid"));
	new healedClient = GetClientOfUserId(GetEventInt(event, "subject"));
	
	// Set speed if has adrenaline
	if(b_Upgrades_Client[healedClient][15])
		SetEntDataFloat(healedClient, speedOffset, g_UpgradeAdrenalineMult, true);
	
	if(g_UpgradeBots < 2 && IsFakeClient(healerClient))	return Plugin_Continue;
	
	// If healed self
	if(healerClient == healedClient) {
		if(!g_UpgradesHealSelf)
			return Plugin_Continue;
	} else {
		if(!g_UpgradesHealPlayer)
			return Plugin_Continue;
	}
	
	new amount = GetEventInt(event, "health_restored");
	if(amount < g_UpgradesHealAmount)
		return Plugin_Continue;
	
	if(g_Verbosity > 2) {
		if(healerClient != healedClient)
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_HEAL_PLAYER", healerClient, g_UpgradesHealPlayer, healedClient);
		else
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_HEAL_SELF", healerClient, g_UpgradesHealSelf);
	} else if(g_Verbosity > 1) {
		if(healerClient != healedClient)
			PrintToChat(healerClient, "%s %t", PLUGIN_TAG_C, "CHAT_HEAL_PLAYER", g_UpgradesHealPlayer, healedClient);
		else
			PrintToChat(healerClient, "%s %t", PLUGIN_TAG_C, "CHAT_HEAL_SELF", g_UpgradesHealSelf);
	}
	
	// Only for real players
	if (IsClientInGame(healerClient) && GetClientTeam(healerClient) == SURVIVORS_TEAMNUM) {
		if(healerClient != healedClient)
			GiveClientUpgrades(healerClient, g_UpgradesHealPlayer);
		else
			GiveClientUpgrades(healerClient, g_UpgradesHealSelf);
	}
	
	return Plugin_Continue;
}
#else
// Don't compile Heal? We still need the Adrenaline checks
public Action:Event_HealSuccess(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_HealSuccess called", PLUGIN_TAG);
	#endif
	
	new healedClient = GetClientOfUserId(GetEventInt(event, "subject"));
	
	// Set speed if has adrenaline
	if(b_Upgrades_Client[healedClient][15])
		SetEntDataFloat(healedClient, speedOffset, g_UpgradeAdrenalineMult, true);
	
	return Plugin_Continue;
}
#endif

// For Adrenaline
public Action:Event_PillsUsed(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PillsUsed called", PLUGIN_TAG);
	#endif
	
	new userClient = GetClientOfUserId(GetEventInt(event,"subject"));
	
	// Set speed if has adrenaline, also has support for olj's Pills Addiction
	if(b_Upgrades_Client[userClient][15] && !b_PillsAddictionAdrenaline)
		SetEntDataFloat(userClient, speedOffset, g_UpgradeAdrenalineMult, true);
	
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PillsUsed: PillsAddiction has Adrenaline! Adrenaline not set!");
	#endif
}

public Action:Event_WeaponFire(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG == 2
	PrintToServer("%s Server #DEBUG: Event_WeaponFire called", PLUGIN_TAG);
	#endif
	
	new shooterClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if(GetClientTeam(shooterClient) != SURVIVORS_TEAMNUM)	return Plugin_Continue;
	decl String:weaponName[64];
	GetEventString(event, "weapon", weaponName, 64);
	if(StrContains(weaponName, "pipe", false) != -1 || StrContains(weaponName, "molo", false) != -1 || StrContains(weaponName, "pills", false) != -1)	return Plugin_Continue;
	
	// Check if server has infinite specialammo, then check if is using a specialammo, then Check if has special ammo
	if(g_UpgradeSpecialAmmoCount && g_Upgrades_SpecialAmmotype[shooterClient] != 0 && (b_Upgrades_Client[shooterClient][14] || b_Upgrades_Client[shooterClient][9])) {
		// SpecialAmmo minuser
		if(g_UpgradeSpecialAmmoMinusSG > 1 && StrContains(weaponName, "shotgun", false) != -1) {
			g_Upgrades_SpecialAmmo[g_Upgrades_SpecialAmmotype[shooterClient]-1][shooterClient] -= g_UpgradeSpecialAmmoMinusSG;
		} else {
			g_Upgrades_SpecialAmmo[g_Upgrades_SpecialAmmotype[shooterClient]-1][shooterClient]--;
		}
		// SpecialAmmo checker, remover & switcher
		if(g_Upgrades_SpecialAmmo[g_Upgrades_SpecialAmmotype[shooterClient]-1][shooterClient] <= 0) {
			// Make sure is non-zero
			g_Upgrades_SpecialAmmo[g_Upgrades_SpecialAmmotype[shooterClient]-1][shooterClient] = 0;
			// Remove upgrades
			if(g_Upgrades_SpecialAmmotype[shooterClient] == 1) {
				// HollowPoint
				RemoveSpecificUpgrade(shooterClient, 9);
			} else if(g_Upgrades_SpecialAmmotype[shooterClient] == 2) {
				// Incendiary
				RemoveSpecificUpgrade(shooterClient, 14);
			}
			// Announce that he used finished.
			if(g_Verbosity > 2) {
				if(g_Upgrades_SpecialAmmotype[shooterClient] == 1)
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_SPECIALAMMO_FINISHED_HOLLOWPOINT", shooterClient);
				else if(g_Upgrades_SpecialAmmotype[shooterClient] == 2)
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_SPECIALAMMO_FINISHED_INCENDIARY", shooterClient);
			} else if(g_Verbosity > 1) {
				if(g_Upgrades_SpecialAmmotype[shooterClient] == 1)
					PrintToChat(shooterClient, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_FINISHED_HOLLOWPOINT");
				else if(g_Upgrades_SpecialAmmotype[shooterClient] == 2)
					PrintToChat(shooterClient, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_FINISHED_INCENDIARY");
			}
			// Check if got other SpecialAmmotypes, else use back normal
			for(new i = MAX_SPECIALAMMOTYPES-1; i >= 0; i--) {
				if(g_Upgrades_SpecialAmmo[i][shooterClient] > 0) {
					g_Upgrades_SpecialAmmotype[shooterClient] = i+1;
					i = -1;
				} else {
					g_Upgrades_SpecialAmmotype[shooterClient] = 0;
				}
			}
			ChangeAmmoType(shooterClient, g_Upgrades_SpecialAmmotype[shooterClient]);
		}
		#if BOOL_SHOW_SPECIALAMMO
		if(b_Show_Ammocount[shooterClient]) {
			if(g_UpgradeSpecialAmmoShow == 1) {
				// Show SpecialAmmo left on CenterText
				if(g_Upgrades_SpecialAmmotype[shooterClient] == 1)
					PrintCenterText(shooterClient, "%t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][shooterClient]);
				else if(g_Upgrades_SpecialAmmotype[shooterClient] == 2)
					PrintCenterText(shooterClient, "%t: %d", "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][shooterClient]);
			} else if(g_UpgradeSpecialAmmoShow == 2) {
				// Show SpecialAmmo left on HintText
				if(g_Upgrades_SpecialAmmotype[shooterClient] == 1)
					PrintHintText(shooterClient, "%t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][shooterClient]);
				else if(g_Upgrades_SpecialAmmotype[shooterClient] == 2)
					PrintHintText(shooterClient, "%t: %d", "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][shooterClient]);
			} else if(g_UpgradeSpecialAmmoShow == 3) {
				// Show SpecialAmmo left on CHAT! (NOT RECOMMENDED)
				if(g_Upgrades_SpecialAmmotype[shooterClient] == 1)
					PrintCenterText(shooterClient, "%s %t: %d", PLUGIN_TAG_C, "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][shooterClient]);
				else if(g_Upgrades_SpecialAmmotype[shooterClient] == 2)
					PrintCenterText(shooterClient, "%s %t: %d", PLUGIN_TAG_C, "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][shooterClient]);
			}
		}
		#endif
	}
	#if BOOL_SHOW_AMMOPANEL
	if(b_Persistent_Menu[shooterClient] && !IsFakeClient(shooterClient)) {
		ShowAmmoTypePanel(shooterClient, 0);
	}
	#endif
	return Plugin_Continue;
}

#if BOOL_UPGRADE_KILLS
public Action:Event_InfectedDeath(Handle:event, String:ename[], bool:dontBroadcast) {
	#if DEBUG == 2
	PrintToServer("%s Server #DEBUG: Event_InfectedDeath called", PLUGIN_TAG);
	#endif
	
	// Don't do anything if you're not giving anything for killing
	if(g_UpgradesKillAmount <= 0 || g_UpgradesKillCount <= 0)
		return Plugin_Continue;
	
	new attackerClient = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!attackerClient || (g_UpgradeBots < 2 && IsFakeClient(attackerClient)))	return Plugin_Continue;
	
	#if !BOOL_TRACK_MEGAKILLS
    // MegaKills
	if (!GetEventBool(event, "minigun") && !GetEventBool(event, "blast")) {
	#endif
		g_Upgrades_TrackKills[attackerClient]++;
	#if !BOOL_TRACK_MEGAKILLS
	}
	#endif
	
	if (g_Upgrades_TrackKills[attackerClient] > 1 && ((g_Upgrades_TrackKills[attackerClient]%g_UpgradesKillCount) == 0)) {
		if(attackerClient && GetClientTeam(attackerClient) == SURVIVORS_TEAMNUM) {
			new type;	// 1=random, 2=addammo, 3=incendiary, 4=hollowpoint
			if(g_UpgradesKillAward == 0) {
				// Normal, random upgrade(s)
				type = 1;
			} else if(g_UpgradesKillAward == 1) {
				// SpecialAmmo + Add SpecialAmmo
				
				if(!b_Upgrades_Client[attackerClient][9] && !b_Upgrades_Client[attackerClient][14]) {
					// Has neither
					if(g_UpgradesKillIA)
						type = 3;
					else if(g_UpgradesKillHP)
						type = 4;
				} else if(b_Upgrades_Client[attackerClient][9] && b_Upgrades_Client[attackerClient][14]) {
					// Has both SA, just add ammo (if enabled, else give random)
					type = 2;
				} else if(b_Upgrades_Client[attackerClient][9] && g_UpgradesKillIA) {
					// Has only HP, check if IA is allowed, then give IA
					type = 3;
				} else if(b_Upgrades_Client[attackerClient][14] && g_UpgradesKillHP) {
					// Has only IA, check if HP is allowed, then give HP
					type = 4;
				} else if(b_Upgrades_Client[attackerClient][9] && !g_UpgradesKillIA) {
					// Has only HP and IA is NOT allowed, add ammo (if enabled, else give random)
					type = 2;
				} else if(b_Upgrades_Client[attackerClient][14] && !g_UpgradesKillHP) {
					// Has only IA and HP is NOT allowed, add ammo (if enabled, else give random)
					type = 2;
				}
			} else {
				// SpecialAmmo + Random
				if(!b_Upgrades_Client[attackerClient][9] && !b_Upgrades_Client[attackerClient][14]) {
					// Has neither
					if(g_UpgradesKillIA)
						type = 3;
					else if(g_UpgradesKillHP)
						type = 4;
				} else if(b_Upgrades_Client[attackerClient][9] && b_Upgrades_Client[attackerClient][14]) {
					// Has both SA, give random upgrade
					type = 1;
				} else if(b_Upgrades_Client[attackerClient][9] && g_UpgradesKillIA) {
					// Has only HP, check if IA is allowed, then give IA
					type = 3;
				} else if(b_Upgrades_Client[attackerClient][14] && g_UpgradesKillHP) {
					// Has only IA, check if HP is allowed, then give HP
					type = 4;
				} else if(b_Upgrades_Client[attackerClient][9] && !g_UpgradesKillIA) {
					// Has only HP and IA is NOT allowed, give random
					type = 1;
				} else if(b_Upgrades_Client[attackerClient][14] && !g_UpgradesKillHP) {
					// Has only IA and HP is NOT allowed, give random
					type = 1;
				}
			}
			// 9 = HollowPoint, 14 = Incendiary
			if(type == 1) {
				// Give random
				if(g_Verbosity > 2) {
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_KILLS_RANDOM", attackerClient, g_UpgradesKillAmount, g_UpgradesKillCount);
				} else if(g_Verbosity > 1) {
					PrintToChat(attackerClient, "%s %t", PLUGIN_TAG_C, "CHAT_KILLS_RANDOM", g_UpgradesKillAmount, g_UpgradesKillCount);
				}
				GiveClientUpgrades(attackerClient, g_UpgradesKillAmount);
			} else if(type == 2) {
				// Add SpecialAmmo
				if(g_Verbosity > 2) {
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_KILLS_ADDAMMO", attackerClient, g_UpgradeSpecialAmmoCount*g_UpgradesKillAmount, g_UpgradesKillCount);
				} else if(g_Verbosity > 1) {
					PrintToChat(attackerClient, "%s %t", PLUGIN_TAG_C, "CHAT_KILLS_ADDAMMO", g_UpgradeSpecialAmmoCount*g_UpgradesKillAmount, g_UpgradesKillCount);
				}
				for(new k = 0; k < MAX_SPECIALAMMOTYPES; k++) {
					// Add to specialammoreserve if already has some in there
					if(g_Upgrades_SpecialAmmo[k][attackerClient] > 0)
						g_Upgrades_SpecialAmmo[k][attackerClient] += (g_UpgradeSpecialAmmoCount*g_UpgradesKillAmount);
				}
				#if BOOL_SHOW_AMMOPANEL
				if(b_Persistent_Menu[attackerClient])
					ShowAmmoTypePanel(attackerClient, 0);
				#endif
			} else if(type == 3) {
				// Give Incendiary Ammo
				if(g_Verbosity > 2) {
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_KILLS_INCENDIARY", attackerClient, g_UpgradesKillCount);
				} else if(g_Verbosity > 1) {
					PrintToChat(attackerClient, "%s %t", PLUGIN_TAG_C, "CHAT_KILLS_INCENDIARY", g_UpgradesKillCount);
				}
				GiveClientSpecificUpgrade(attackerClient, 14);
			} else if(type == 4) {
				// Give Hollow Point Ammo
				if(g_Verbosity > 2) {
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_KILLS_HOLLOWPOINT", attackerClient, g_UpgradesKillCount);
				} else if(g_Verbosity > 1) {
					PrintToChat(attackerClient, "%s %t", PLUGIN_TAG_C, "CHAT_KILLS_HOLLOWPOINT", g_UpgradesKillCount);
				}
				GiveClientSpecificUpgrade(attackerClient, 9);
			}
		}
	}
		
	return Plugin_Continue;
}
#endif

#if BOOL_DONT_RETAIN_UPGRADES
public Action:Event_PlayerDeath(Handle:event, String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PlayerDeath called", PLUGIN_TAG);
	#endif
	
	// If userid does not exist, then its not a player who died
	if(!GetEventInt(event, "userid"))
		return Plugin_Continue;
	
	new deadClient = GetClientOfUserId(GetEventInt(event, "userid"));
	// Check if the dead person is a Survivor
	if(GetClientTeam(deadClient) != SURVIVORS_TEAMNUM)
		return Plugin_Continue;
	
	if(GetConVarInt(ResetOnDeath) > 0) {
		if(!IsFakeClient(deadClient) || g_UpgradeBots == 2) {
			if(g_Verbosity > 2) {
				PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_RESET_DEATH", deadClient);
			} else if(g_Verbosity > 1) {
				PrintToChat(deadClient, "%s %t", PLUGIN_TAG_C, "CHAT_RESET_DEATH");
			}
		}
		// Give lasers if its 2
		if(GetConVarInt(UpgradeAllowed[6]) == 2) {
			if(b_Upgrades_Laser[deadClient]) {
				RemoveAllUpgrades(INVALID_HANDLE, deadClient);
				b_Upgrades_Client[deadClient][6] = true;
				b_Upgrades_Laser[deadClient] = true;
				SDKCall(AddUpgrade, deadClient, IndexToUpgrade[6]);
			} else {
				RemoveAllUpgrades(INVALID_HANDLE, deadClient);
				b_Upgrades_Client[deadClient][6] = true;
				b_Upgrades_Laser[deadClient] = true;
			}
		} else {
			RemoveAllUpgrades(INVALID_HANDLE, deadClient);
		}
		// Reset kills counter
		g_Upgrades_TrackKills[deadClient] = 0;
		// Don't re-give initial; set given initial as true ;D
		if(GetConVarInt(ResetOnDeath) == 2)
			b_Upgrades_GivenInit[deadClient] = true;
	}
	
	return Plugin_Continue;
}
#endif

#if BOOL_ALLOW_INCENDIARY
// Incendiary Ammo handling - non-playable classes (Common Infected, Witch)
public Action:Event_InfectedHurt(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG == 2
	PrintToServer("%s Server #DEBUG: Event_InfectedHurt called", PLUGIN_TAG);
	#endif
	
	new attackerClient = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	// Has Incendiary Ammo? Is using Incendiary Ammo? Is Survivor?
	if(!b_Upgrades_Client[attackerClient][14] || g_Upgrades_SpecialAmmotype[attackerClient] != 2 || GetClientTeam(attackerClient) != SURVIVORS_TEAMNUM)
		return Plugin_Continue;
	new infectedEnt = GetEventInt(event, "entityid");
	
	// Witches burn forever, so don't ignite! So make her fireproof!
	decl String:witchName[64];
	GetEntityNetClass(infectedEnt, witchName, 64);
	if(StrContains(witchName, "Witch")==0) {
		return Plugin_Continue;
	}
	
	// Light the entity on fire
	new damagetype = GetEventInt(event, "type");
	#if DEBUG == 1
	PrintToServer("%s #DEBUG: %N's DmgType: %d", PLUGIN_TAG, attackerClient, damagetype);
	#endif
	if(damagetype != 64 && damagetype != 128 && damagetype != 268435464) {
		IgniteEntity(infectedEnt, 360.0, false);
	}
	return Plugin_Continue;
}

// Incendiary Ammo Handling - all playable classes (Hunter, Smoker, Boomer, Tank, Survivors)
public Action:Event_PlayerHurt(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_PlayerHurt called", PLUGIN_TAG);
	#endif
	
	// Check if he did not hurt himself
	if(GetEventInt(event, "attacker") != 0) {
		new attackerClient = GetClientOfUserId(GetEventInt(event, "attacker"));
		// Has Incendiary Ammo? Is using Incendiary Ammo? Is Survivor?
		if(!b_Upgrades_Client[attackerClient][14] || g_Upgrades_SpecialAmmotype[attackerClient] != 2 || GetClientTeam(attackerClient) != SURVIVORS_TEAMNUM)
			return Plugin_Continue;
	} else {
		return Plugin_Continue;
	}
	
	new infectedClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// Is attacked Survivor? Don't set him aflame! Friendly Fire, literally.
	if (GetClientTeam(infectedClient) != INFECTED_TEAMNUM)
		return Plugin_Continue;
	
	decl String:tankModel[64];
	GetClientModel(infectedClient, tankModel, 64);
	if(StrContains(tankModel, "hulk", false) != -1) {
		if(b_IgniteTank) {
			// Light the entity on fire
			new damagetype = GetEventInt(event, "type");
			if(damagetype != 64 && damagetype != 128 && damagetype != 268435464) {
				IgniteEntity(infectedClient, 360.0, false);
			}
		}
	} else if(b_IgniteSpecial) {
		// Light the entity on fire
		new damagetype = GetEventInt(event, "type");
		if(damagetype != 64 && damagetype != 128 && damagetype != 268435464) {
			IgniteEntity(infectedClient, 360.0, false);
		}
	}
	return Plugin_Continue;
}
#endif

#if BOOL_UPGRADE_TANK
public Action:Event_TankSpawn(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_TankSpawn called", PLUGIN_TAG);
	#endif
	if(!b_Enabled)
		return Plugin_Continue;
	if(b_BlockOnTankSpawn) {
		return Plugin_Continue;
	} else {
		// Prevents multiple upgrades for multiple tanks
		CreateTimer(15.0, UnblockTankSpawn);
		b_BlockOnTankSpawn = true;
	}
	new numUpgradesTankSpawn = GetConVarInt(UpgradesTankSpawn);
	if(numUpgradesTankSpawn) {
		for(new i = 1; i < MaxClients; i++) {
			if(!IsClientInGame(i)) continue;
			if(GetClientTeam(i) != SURVIVORS_TEAMNUM) continue;
			if(g_UpgradeBots < 2 && IsFakeClient(i)) continue;
			GiveClientUpgrades(i, numUpgradesTankSpawn);
		}
		if(g_Verbosity > 1) {
			if(g_UpgradeBots < 2 && NoHumanSurvivors()) return Plugin_Continue;
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_INCOMING_TANK");
		}
	}
	return Plugin_Continue;
}

public Action:Event_TankKilled(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_TankKilled called", PLUGIN_TAG);
	#endif
	
	if(!b_Enabled)
		return Plugin_Continue;
	
	new numUpgradesAll = GetConVarInt(UpgradesTankAll);
	new numUpgradesKiller = GetConVarInt(UpgradesTankKiller);
	new killerClient = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (numUpgradesAll > 0 || (numUpgradesKiller > 0 && killerClient != 0))	{
		if(g_Verbosity > 1) {
			if(g_UpgradeBots < 2 && NoHumanSurvivors()) return Plugin_Continue;
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_KILLED_TANK");
		}
		if(numUpgradesAll)
		{
			for(new i = 1; i < MaxClients; i++) {
				if(IsClientInGame(i) && GetClientTeam(i) == SURVIVORS_TEAMNUM && IsPlayerAlive(i)) {
					// 											 ^Give only to surviving survivors
					GiveClientUpgrades(i, numUpgradesAll);
				}
			}
		}
		if(numUpgradesKiller > 0) {
			if(killerClient != 0) {
				if(g_UpgradeBots < 2 && IsFakeClient(killerClient))	return Plugin_Continue;
				if(g_Verbosity > 2) {
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_PRIMARY", killerClient);
				} else if (g_Verbosity > 1) {
					PrintToChat(killerClient, "%s %t", PLUGIN_TAG_C, "CHAT_PRIMARY");
				}
				GiveClientUpgrades(killerClient, numUpgradesKiller);
			} else {
				if(g_Verbosity > 1) {
					if(g_UpgradeBots < 2 && NoHumanSurvivors()) return Plugin_Continue;
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_TANK_NOPRIMARY");
				}
			}
		}
	}
	return Plugin_Continue;
}
#endif

#if BOOL_UPGRADE_WITCH
public Action:Event_WitchKilled(Handle:event, const String:ename[], bool:dontBroadcast) {
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_WitchKilled called", PLUGIN_TAG);
	#endif
	
	new numUpgradesAll = GetConVarInt(UpgradesWitchAll);
	new numUpgradesKiller = GetConVarInt(UpgradesWitchKiller);
	new killerClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (numUpgradesAll > 0 || (numUpgradesKiller > 0 && killerClient != 0)) {
		if(g_Verbosity > 1)	{
			if(g_UpgradeBots < 2 && NoHumanSurvivors()) return Plugin_Continue;
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_KILLED_WITCH");
		}
		if(numUpgradesAll > 0) {
			for(new i = 1; i < MaxClients; i++) {
				if(!IsClientInGame(i) || GetClientTeam(i) != SURVIVORS_TEAMNUM || !IsPlayerAlive(i)) continue;
				// 													^Give only to surviving survivors
				GiveClientUpgrades(i, numUpgradesAll);
			}
		}
		if(numUpgradesKiller > 0) {
			if(killerClient != 0) {
				if(g_UpgradeBots < 2 && IsFakeClient(killerClient))	return Plugin_Continue;
				if(g_Verbosity > 2) {
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_PRIMARY", killerClient);
				} else if (g_Verbosity > 1) {
					PrintToChat(killerClient, "%s %t", PLUGIN_TAG_C, "CHAT_PRIMARY");
				}
				GiveClientUpgrades(killerClient, numUpgradesKiller);
			} else {
				if(g_Verbosity > 1) {
					if(g_UpgradeBots < 2 && NoHumanSurvivors()) return Plugin_Continue;
					PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_WITCH_NOPRIMARY");
				}
			}
		}
	}
	return Plugin_Continue;
}

// For cr0wning
public Action:Event_Award(Handle:event, const String:ename[], bool:dontBroadcast) {
	// "userid"	"short"			// player who earned the award
	// "entityid"	"long"			// client likes ent id
	// "subjectentid"	"long"			// entity id of other party in the award, if any
	// "award"		"short"			// id of award earned
	
	#if DEBUG
	PrintToServer("%s Server #DEBUG: Event_Award called: Award #%d", PLUGIN_TAG, GetEventInt(event, "award"));
	#endif
	
	if(GetEventInt(event, "award") == 19) {	// 19 = cr0wned
		if(GetConVarInt(UpgradesWitchCr0wned)) {
			new killerClient = GetClientOfUserId(GetEventInt(event, "userid"));
			if(g_UpgradeBots < 2 && IsFakeClient(killerClient))	return Plugin_Continue;
			if(g_Verbosity > 2) {
				PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_WITCH_CR0WNED", killerClient);
			} else if (g_Verbosity > 1) {
				PrintToChat(killerClient, "%s %t", PLUGIN_TAG_C, "CHAT_WITCH_CR0WNED");
			}
			GiveClientUpgrades(killerClient, GetConVarInt(UpgradesWitchCr0wned));
		}
	}
	
	return Plugin_Continue;
}
#endif
/*** -- END Events! -- ***/

/*** -- Handling of _expire and description messages -- ***/
public Action:SayTextHook(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init) {
	decl String:message[1024];
	BfReadByte(bf);
	BfReadByte(bf);
	BfReadString(bf, message, 1024);

	if(StrContains(message, "prevent_it_expire") != -1)	{
		if(b_CanAnnounce)
			CreateTimer(0.1, DelayPrintExpire, 1);
		return Plugin_Handled;
	}			
	if(StrContains(message, "ledge_save_expire") != -1)	{
		if(b_CanAnnounce)
			CreateTimer(0.1, DelayPrintExpire, 2);
		return Plugin_Handled;
	}
	if(StrContains(message, "revive_self_expire") != -1) {
		if(b_CanAnnounce)
			CreateTimer(0.1, DelayPrintExpire, 3);
		return Plugin_Handled;
	}
	if(StrContains(message, "knife_expire") != -1) {
		if(b_CanAnnounce)
			CreateTimer(0.1, DelayPrintExpire, 4);
		return Plugin_Handled;
	}
	
	/*if(StrContains(message, "laser_sight_expire") != -1) {
		return Plugin_Handled;
	}*/

	if(StrContains(message, "_expire") != -1) {
		return Plugin_Handled;
	}

	if(StrContains(message, "#L4D_Upgrade_") != -1 && StrContains(message, "description") != -1) {
		return Plugin_Handled;
	}
	
	if(StrContains(message, "NOTIFY_VOMIT_ON") != -1) {
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:DelayPrintExpire(Handle:hTimer, any:text) {
	// Prevents warnings when changing maps
	if(g_Verbosity > 0 && b_CanAnnounce && b_Enabled) {
		if(text == 1) {
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_EXPIRE_RAINCOAT");
		}
		if(text == 2) {
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_EXPIRE_CHALK");
		}
		if(text == 3) {
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_EXPIRE_WIND");
		}
		if(text == 4) {
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_EXPIRE_KNIFE");
		}
	}
}
/*** -- END Handling of _expire and description messages -- ***/

/*** -- Give Upgrades functions -- ***/

public Action:GiveAllInitialUpgrades(Handle:hTimer, any:ClearUpgrades) {
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode)	return;
	#endif
	// ClearUpgrades before giving Initial? ((FORCEFUL))
	if(ClearUpgrades) {
		#if DEBUG
		PrintToServer("%s Server #DEBUG: ClearUpgrades on GiveAllInitialUpgrades", PLUGIN_TAG);
		#endif
		// Prevent _expire messages from coming out while removing all upgrades
		b_CanAnnounce = false;
		for(new i = 1; i < MaxClients; i++) {
			RemoveAllUpgrades(hTimer, i);
			GiveInitialUpgrades(hTimer, i);
		}
		CreateTimer(0.5, CanAnnounce);
	} else {
		// GiveInitialUpgrades to all clients
		for(new i = 1; i < MaxClients; i++)	{
			GiveInitialUpgrades(hTimer, i);
		}
	}
	#if DEBUG
	PrintToServer("%s Server: GiveAllInitialUpgrades(%d); Called!", PLUGIN_TAG, ClearUpgrades);
	#endif
}

public Action:GiveInitialUpgrades(Handle:hTimer, any:client) {
	#if BOOL_SELECTIVE_GAMEMODES
	// 	InvalidGameMode?	Real Client?	Connected?					Survivors?								Already got init upgrades?
	if(b_InvalidGameMode || !client || !IsClientInGame(client) || GetClientTeam(client) != SURVIVORS_TEAMNUM || b_Upgrades_GivenInit[client]) return;
	#else
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != SURVIVORS_TEAMNUM || b_Upgrades_GivenInit[client]) return;
	#endif
	
	if(IsFakeClient(client)) {
		if(g_UpgradeBots == 0) {
			return;
		} else if(g_UpgradeBots == 1) {
			GiveClientSpecificUpgrade(client, 6);
			return;
		}
	}

	for(new i = 0; i < MAX_VALID_UPGRADES+1; i++) {
		// Check for every surup_allow_* if its 2 (2=give at init)
		if(GetConVarInt(UpgradeAllowed[i])==2) {
			GiveClientSpecificUpgrade(client, i);
		}
	}
	
	new numStarting = GetConVarInt(UpgradesSpawnAll);
	if(numStarting) {
		GiveClientUpgrades(client, numStarting);
	}
	
	b_Upgrades_GivenInit[client] = true;
	
	if(g_Verbosity > 1)
		PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHATALL_INFO_SAYUPGRADES");
	
	#if DEBUG
	PrintToServer("%s Server #DEBUG: InitialUpgrades(%d); (%N)!", PLUGIN_TAG, client, client);
	#endif
}

public GiveClientUpgrades(client, numUpgrades) {
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode)	return;
	#endif
	for(new num = 0; num < numUpgrades; num++) {
		new numOwned = GetNumUpgrades(client);
		if(numOwned == MAX_VALID_UPGRADES+1) {
			if(g_Verbosity > 2) {
				PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_INFO_FULLYUPGRADED", client);
			} else if(g_Verbosity > 0) {
				PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_INFO_FULLYUPGRADED");
			}
			return;
		}
		new offset = GetRandomInt(0,MAX_VALID_UPGRADES+1-(numOwned+1));
		new val = 0;
		while(offset > 0 || b_Upgrades_Client[client][val] || GetConVarInt(UpgradeAllowed[val]) != 1) {
			if((!b_Upgrades_Client[client][val]) && GetConVarInt(UpgradeAllowed[val]) == 1) {
				offset--;
			}
			val++;
		}
		GiveClientSpecificUpgrade(client, val);
		#if DEBUG
		PrintToServer("%s Server #DEBUG: ClientUpgrades(%d, %d); (%N has:%d)!", PLUGIN_TAG, client, numUpgrades, client, numOwned);
		#endif
	}
}

public GiveClientSpecificUpgrade(client, upgrade) {
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode)	return;
	#endif
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM)	return;
	if(IsFakeClient(client)) {
		if(g_UpgradeBots == 0 || (g_UpgradeBots == 1 && upgrade != 6))
			return;
	}
	// Always show to all if its versus
	if(b_IsVersus) {
		if(b_VersusAnnounceToAll)
			PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHAT_GOT_UPGRADE", client, UpgradeShortInfo[upgrade]);
	} else if(g_Verbosity > 2) {
		PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHAT_GOT_UPGRADE", client, UpgradeShortInfo[upgrade]);
	} else if(g_Verbosity > 1) {
		PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_YOU_GOT_UPGRADE", UpgradeShortInfo[upgrade]);
	}
	SDKCall(AddUpgrade, client, IndexToUpgrade[upgrade]);
	// Index 30 = Upgrade 14 = Incendiary Ammo (custom upgrade)
	// Index 30 is flashbulb, which is unknown, so we remove it
	// But we still add it for the sound effect =D
	if(IndexToUpgrade[upgrade] == 30) {
		SDKCall(RemoveUpgrade, client, IndexToUpgrade[upgrade]);
	}
	#if DEBUG
	PrintToServer("%s Server #DEBUG: SpecificUpgrade(%d, %d); (%N, %s)!", PLUGIN_TAG, client, upgrade, client, UpgradeShortInfo[upgrade]);
	#endif
	b_Upgrades_Client[client][upgrade] = true;
	if(upgrade == 6) {
		if(b_LaserDefaultState) {
			b_Upgrades_Laser[client] = true;
		} else {
			b_Upgrades_Laser[client] = false;
			SDKCall(RemoveUpgrade, client, IndexToUpgrade[upgrade]);
			CheckLaser(INVALID_HANDLE);
		}
		PrintHintText(client, "%s %t", PLUGIN_TAG, "HINT_SAY_LASER");
		#if DEBUG_EXPERIMENTAL
		SetLaserColour(client);
		#endif
	} else if(upgrade == 15) {
		SetEntDataFloat(client, speedOffset, g_UpgradeAdrenalineMult, true);
	} else if(upgrade == 9) {
		// If its Incendiary, or HollowPoint, add available ammo
		if(g_UpgradeSpecialAmmoCount)
			g_Upgrades_SpecialAmmo[0][client] += g_UpgradeSpecialAmmoCount;
		else
			g_Upgrades_SpecialAmmo[0][client] = 9999;
		#if BOOL_SHOW_SPECIALAMMO
		if(g_UpgradeSpecialAmmoShow == 1) {
			// Show SpecialAmmo left on CenterText
			PrintCenterText(client, "%t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][client]);
		} else if(g_UpgradeSpecialAmmoShow == 2) {
			// Show SpecialAmmo left on HintText
			PrintHintText(client, "%t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][client]);
		} else if(g_UpgradeSpecialAmmoShow == 3) {
			// Show SpecialAmmo left on CHAT! (NOT RECOMMENDED)
			PrintCenterText(client, "%s %t: %d", PLUGIN_TAG_C, "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][client]);
		}
		#endif
		if(g_Upgrades_SpecialAmmotype[client] != 1) {
			SDKCall(RemoveUpgrade, client, IndexToUpgrade[9]);
			PrintHintText(client, "%s %t", PLUGIN_TAG, "HINT_SAY_AMMOTYPE");
		}
		// Switch to AmmoType if player has AutoSwitch on, or is a Bot
		if(b_SpecialAmmo_AutoSwitch[client] || IsFakeClient(client))
			ChangeAmmoType(client, 1);
		#if BOOL_SHOW_AMMOPANEL
		if(b_Persistent_Menu[client])
			ShowAmmoTypePanel(client, 0);
		#endif
	} else if(upgrade == 14) {
		// If its Incendiary, or HollowPoint, add available ammo
		if(g_UpgradeSpecialAmmoCount)
			g_Upgrades_SpecialAmmo[1][client] += g_UpgradeSpecialAmmoCount;
		else
			g_Upgrades_SpecialAmmo[1][client] = 9999;
		#if BOOL_SHOW_SPECIALAMMO
		if(g_UpgradeSpecialAmmoShow == 1) {
			// Show SpecialAmmo left on CenterText
			PrintCenterText(client, "%t: %d", "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][client]);
		} else if(g_UpgradeSpecialAmmoShow == 2) {
			// Show SpecialAmmo left on HintText
			PrintHintText(client, "%t: %d", "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][client]);
		} else if(g_UpgradeSpecialAmmoShow == 3) {
			// Show SpecialAmmo left on CHAT! (NOT RECOMMENDED)
			PrintCenterText(client, "%s %t: %d", PLUGIN_TAG_C, "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][client]);
		}
		#endif
		if(g_Upgrades_SpecialAmmotype[client] != 2) {
			PrintHintText(client, "%s %t", PLUGIN_TAG, "HINT_SAY_AMMOTYPE");
		}
		// Switch to AmmoType if player has AutoSwitch on, or is a Bot
		if(b_SpecialAmmo_AutoSwitch[client] || IsFakeClient(client))
			ChangeAmmoType(client, 2);
		#if BOOL_SHOW_AMMOPANEL
		if(b_Persistent_Menu[client])
			ShowAmmoTypePanel(client, 0);
		#endif
	}
}

// Removes ALL upgrades, regardless of plugin registry, and then re-gives according to plugin registry
// Should wait 1 second after an event to allow survivor_upgrades itself to give its upgrade
public Action:ReGiveClientUpgrades(Handle:hTimer, any:client) {
	#if BOOL_SELECTIVE_GAMEMODES
	if(!b_InvalidGameMode && IsClientInGame(client)) {
	#else
	if(IsClientInGame(client)) {
	#endif
		b_CanAnnounce = false;
		for(new upgrade = 0; upgrade < MAX_VALID_UPGRADES+1; upgrade++) {
			// Remove all first
			SDKCall(RemoveUpgrade, client, IndexToUpgrade[upgrade]);
			// Then give if client has upgrade
			if(b_Upgrades_Client[client][upgrade]) {
				if(upgrade != 9 || g_Upgrades_SpecialAmmotype[client] == 1)
					SDKCall(AddUpgrade, client, IndexToUpgrade[upgrade]);
			}
		}
		// Set speed if has adrenaline
		if(b_Upgrades_Client[client][15])
			SetEntDataFloat(client, speedOffset, g_UpgradeAdrenalineMult, true);
		CreateTimer(1.0, CanAnnounce);
	}
}

/*** -- END Give Upgrades functions -- ***/

/*** -- Remove Upgrades functions -- ***/

// Remove all upgrades of client, -1 to remove upgrades of all clients
public Action:RemoveAllUpgrades(Handle:hTimer, any:client) {
	if(client == -1) {
		// Remove ALL players' upgrades
		for(new i = 1; i < MaxClients; i++) {
			if(IsClientInGame(i)) {
				b_Upgrades_GivenInit[i] = false;
				b_Upgrades_Laser[i] = false;
				#if BOOL_SHOW_AMMOPANEL
				b_Persistent_Menu[i] = false;
				#endif
				for(new k = 0; k < MAX_SPECIALAMMOTYPES; k++) {
					g_Upgrades_SpecialAmmo[k][i] = 0;
				}
				g_Upgrades_SpecialAmmotype[i] = 0;
				#if BOOL_UPGRADE_KILLS
				g_Upgrades_TrackKills[i] = 0;
				#endif
				// Clear plugin registry of client's upgrades, and remove upgrade
				for(new j = 0; j < MAX_VALID_UPGRADES+1; j++) {
					// Clear registry
					b_Upgrades_Client[i][j] = false;
					// Remove upgrade
					SDKCall(RemoveUpgrade, i, IndexToUpgrade[j]);
				}
				// Reset Adrenaline
				SetEntDataFloat(i, speedOffset, 1.0, true);
			}
		}
	} else {
		if(client && IsClientInGame(client)) {
			b_Upgrades_GivenInit[client] = false;
			// Clear plugin registry of client's upgrades, and remove upgrade
			for(new j = 0; j < MAX_VALID_UPGRADES+1; j++) {
				// Clear registry
				b_Upgrades_Client[client][j] = false;
				// Remove all upgrades
				SDKCall(RemoveUpgrade, client, IndexToUpgrade[j]);
			}
			// Reset Adrenaline
			SetEntDataFloat(client, speedOffset, 1.0, true);
		#if DEBUG
		} else {
			PrintToServer("%s Server #DEBUG: RemoveAllUpgrades(%d); That client is not in-game!", PLUGIN_TAG, client);
			return;
		}
		#else
		}
		#endif
	}
	#if DEBUG
	PrintToServer("%s Server #DEBUG: RemoveAllUpgrades(%d); was called.", PLUGIN_TAG, client);
	return;
	#endif
}

public RemoveSpecificUpgrade(client, upgrade) {
	SDKCall(RemoveUpgrade, client, IndexToUpgrade[upgrade]);
	
	if(upgrade == 15) {
		SetEntDataFloat(client, speedOffset, 1.0, true);
	} else if(upgrade == 9) {
		// If its Incendiary, or HollowPoint, remove available ammo
		g_Upgrades_SpecialAmmo[0][client] = 0;
		#if BOOL_SHOW_SPECIALAMMO
		if(g_UpgradeSpecialAmmoShow == 1) {
			// Show SpecialAmmo left on CenterText
			PrintCenterText(client, "%t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][client]);
		} else if(g_UpgradeSpecialAmmoShow == 2) {
			// Show SpecialAmmo left on HintText
			PrintHintText(client, "%t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][client]);
		} else if(g_UpgradeSpecialAmmoShow == 3) {
			// Show SpecialAmmo left on CHAT! (NOT RECOMMENDED)
			PrintCenterText(client, "%s %t: %d", PLUGIN_TAG_C, "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][client]);
		}
		#endif
		if(g_Upgrades_SpecialAmmotype[client] != 1) {
			SDKCall(RemoveUpgrade, client, IndexToUpgrade[9]);
			PrintHintText(client, "%s %t", PLUGIN_TAG, "HINT_SAY_AMMOTYPE");
		}
		// Switch to AmmoType if player has AutoSwitch on, or is a Bot
		if(b_SpecialAmmo_AutoSwitch[client] || IsFakeClient(client))
			ChangeAmmoType(client, 0);
		#if BOOL_SHOW_AMMOPANEL
		if(b_Persistent_Menu[client])
			ShowAmmoTypePanel(client, 0);
		#endif
	} else if(upgrade == 14) {
		// If its Incendiary, or HollowPoint, remove available ammo
		g_Upgrades_SpecialAmmo[1][client] = 0;
		#if BOOL_SHOW_SPECIALAMMO
		if(g_UpgradeSpecialAmmoShow == 1) {
			// Show SpecialAmmo left on CenterText
			PrintCenterText(client, "%t: %d", "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][client]);
		} else if(g_UpgradeSpecialAmmoShow == 2) {
			// Show SpecialAmmo left on HintText
			PrintHintText(client, "%t: %d", "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][client]);
		} else if(g_UpgradeSpecialAmmoShow == 3) {
			// Show SpecialAmmo left on CHAT! (NOT RECOMMENDED)
			PrintCenterText(client, "%s %t: %d", PLUGIN_TAG_C, "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][client]);
		}
		#endif
		// Switch to AmmoType if player has AutoSwitch on, or is a Bot
		if(b_SpecialAmmo_AutoSwitch[client] || IsFakeClient(client))
			ChangeAmmoType(client, 0);
		#if BOOL_SHOW_AMMOPANEL
		if(b_Persistent_Menu[client])
			ShowAmmoTypePanel(client, 0);
		#endif
	}
	b_Upgrades_Client[client][upgrade] = false;
}

/*** -- END Remove Upgrades functions -- ***/

/*** -- Other function helpers -- ***/
// Get how many upgrades a client has according to plugin registry
public GetNumUpgrades(client) {
	new num = 0;
	for(new i = 0; i < MAX_VALID_UPGRADES+1; i++)	{
		if(b_Upgrades_Client[client][i] || GetConVarInt(UpgradeAllowed[i]) != 1) {
			num++;
		}
	}
	return num;
}

#if BOOL_UPGRADE_TANK
public Action:UnblockTankSpawn(Handle:hTimer) {
	b_BlockOnTankSpawn = false;
}
#endif

public ListMyUpgrades(client, bool:brief) {
	for(new upgrade = 0; upgrade < MAX_VALID_UPGRADES+1; upgrade++) {
		if(b_Upgrades_Client[client][upgrade]) {
			PrintToChat(client, "%t", "CHAT_LIST_UPGRADES", client, UpgradeShortInfo[upgrade]);
			if(!brief)	{
				PrintToChat(client, "%t", UpgradeLongInfo[upgrade]);
			}
		}
	}
}

public Action:CanAnnounce(Handle:hTimer) {
	b_CanAnnounce = true;
}
#if BOOL_UPGRADE_SAFEROOM
public Action:GiveSafeRoomUpgrades(Handle:hTimer, any:numberOfUpgrades) {
	new i;
	for(i = 1; i < MaxClients; i++) {
		if(IsClientInGame(i) && GetClientTeam(i) == SURVIVORS_TEAMNUM) {
			GiveClientUpgrades(i, numberOfUpgrades);
		}
	}
	if(g_Verbosity > 1) {
		PrintToChatAll("%s %t", PLUGIN_TAG_C, "CHATALL_REACH_SAFEROOM", numberOfUpgrades);
	}
}
#endif

public NoHumanSurvivors() {
	for(new i = 1; i < MaxClients; i++) {
		if(IsClientInGame(i) && GetClientTeam(i) == SURVIVORS_TEAMNUM && !IsFakeClient(i))
			return 0;
	}
	return 1;
}

public ChangeAmmoType(client, ammoType) {
	if(ammoType == 0) {
		// Switch To Normal
		PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_SWITCHED_NORMAL");
		g_Upgrades_SpecialAmmotype[client] = 0;
		SDKCall(RemoveUpgrade, client, IndexToUpgrade[9]);
		return true;
	} else if(ammoType == 1) {
		// Switch To HollowPoint
		if(g_Upgrades_SpecialAmmo[0][client] > 0) {
			PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_SWITCHED_HOLLOWPOINT");
			g_Upgrades_SpecialAmmotype[client] = 1;
			SDKCall(AddUpgrade, client, IndexToUpgrade[9]);
			return true;
		} else {
			PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_NOT_ENOUGH_HOLLOWPOINT");
			return false;
		}
	} else if(ammoType == 2) {
		// Switch To Incendiary
		if(g_Upgrades_SpecialAmmo[1][client] > 0) {
			PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_SWITCHED_INCENDIARY");
			g_Upgrades_SpecialAmmotype[client] = 2;
			SDKCall(RemoveUpgrade, client, IndexToUpgrade[9]);
			return true;
		} else {
			PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_NOT_ENOUGH_INCENDIARY");
			return false;
		}
	}
	return false;
}

#if FIX_RARE_BUG_METHOD
public Action:SetSurvivorUpgradesCVar(Handle:hTimer) {
	if(GetConVarInt(FindConVar("survivor_upgrades")) == 0) {
		SetConVarInt(FindConVar("survivor_upgrades"), 1, true, false);
		for(new i = 1; i < MaxClients; i++) {
			if(IsClientInGame(i) && GetClientTeam(i) == SURVIVORS_TEAMNUM) {
				CreateTimer(1.0, ReGiveClientUpgrades, i);
			}
		}
	}
}
#endif
/*** -- END Other function helpers -- ***/

/*** -- Commands -- ***/
#if BOOL_ADMIN_COMMANDS
public Action:listAllUpgrades(client, args) {
	// Don't care about args
	new tmpTotal = 0;
	PrintToConsole(client, "%s: %t", PLUGIN_TAG, "CONSOLE_LIST_ALL_UPGRADES");
	for(new upgrade = 0; upgrade < MAX_VALID_UPGRADES+1; upgrade++) {
		if(UpgradeAllowed[upgrade]) {
			PrintToConsole(client, "#%2d| %t", upgrade+1, UpgradeShortInfo[upgrade]);
			tmpTotal++;
		}
	}
	ReplyToCommand(client, "%s: %t", PLUGIN_TAG, "CONSOLE_LISTED_TOTAL_UPGRADES", tmpTotal);
	
	return Plugin_Handled;
}

public Action:listPlayerUpgrades(client, args) {
	if(GetCmdArgs() < 1) {
		ReplyToCommand(client, "Usage: listPlayerUpgrades <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1) {
		targetCount = 0;
		for(new i = 1; i<=GetCmdArgs(); ++i) {
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)	{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k) {
					if(targetList[k] == subTargetList[j]) {
						bAdd = false;
					}
				}
				if(bAdd) {
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0) {
		ReplyToCommand(client, "%t", "No matching clients");
		return Plugin_Handled;
	}
	
	decl target;
	for(new i = 0; i < targetCount; ++i) {
		target = targetList[i];
		PrintToConsole(client, "%s %t", PLUGIN_TAG, "CONSOLE_LIST_UPGRADES", target);
		new tmpTotal = 0;
		for(new upgrade = 0; upgrade < MAX_VALID_UPGRADES+1; upgrade++) {
			if(b_Upgrades_Client[target][upgrade]) {
				PrintToConsole(client, "#%2d| %t", upgrade+1, UpgradeShortInfo[upgrade]);
				tmpTotal++;
			}
		}
		PrintToConsole(client, ">>>| %t: %d || %t: %d", "LABEL_HOLLOWPOINT", g_Upgrades_SpecialAmmo[0][target], "LABEL_INCENDIARY", g_Upgrades_SpecialAmmo[1][target]);
		ReplyToCommand(client, "%s: %t", PLUGIN_TAG, "CONSOLE_LISTED_TOTAL_UPGRADES", tmpTotal);
	}
	
	return Plugin_Handled;
}

public Action:addUpgrade(client, args) {
	if(GetCmdArgs() < 1) {
		ReplyToCommand(client, "Usage: addUpgrade [upgrade id] <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1) {
		targetCount = 0;
		for(new i = 2; i<=GetCmdArgs(); ++i) {
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)	{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k) {
					if(targetList[k] == subTargetList[j]) {
						bAdd = false;
					}
				}
				if(bAdd) {
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0) {
		ReplyToCommand(client, "%t", "No matching clients");
		return Plugin_Handled;
	}
	
	decl String:arg[3];
	GetCmdArg(1, arg, sizeof(arg));
	new upgrade = StringToInt(arg)-1;
	if(upgrade<0 || upgrade >= MAX_VALID_UPGRADES+1) {
		ReplyToCommand(client, "Invalid upgrade index.  Valid values are 1 to %d.", MAX_VALID_UPGRADES+1);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < targetCount; ++i) {
		GiveClientSpecificUpgrade(targetList[i], upgrade);
	}
	return Plugin_Handled;		
}

public Action:addRandomUpgrades(client, args) {
	if(GetCmdArgs() < 1)
	{
		ReplyToCommand(client, "Usage: addRandomUpgrades [number of Upgrades] <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1) {
		targetCount = 0;
		for(new i = 2; i <= GetCmdArgs(); i++) {
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)	{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k) {
					if(targetList[k] == subTargetList[j]) {
						bAdd = false;
					}
				}
				if(bAdd) {
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0) {
		ReplyToCommand(client, "%t", "No matching clients");
		return Plugin_Handled;
	}
	
	decl String:arg[3];
	GetCmdArg(1, arg, sizeof(arg));
	new upgrade = StringToInt(arg);
	
	for(new i = 0; i < targetCount; ++i) {
		GiveClientUpgrades(targetList[i], upgrade);
	}
	return Plugin_Handled;		
}

public Action:removeUpgrade(client, args) {
	if(GetCmdArgs() < 1) {
		ReplyToCommand(client, "Usage: removeUpgrade [upgrade id] <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1) {
		targetCount = 0;
		for(new i = 2; i<=GetCmdArgs(); ++i) {
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)	{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k) {
					if(targetList[k] == subTargetList[j]) {
						bAdd = false;
					}
				}
				if(bAdd) {
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0) {
		ReplyToCommand(client, "%t", "No matching clients");
		return Plugin_Handled;
	}
	
	decl String:arg[3];
	GetCmdArg(1, arg, sizeof(arg));
	new upgrade = StringToInt(arg)-1;
	if(upgrade < 0 || upgrade >= MAX_VALID_UPGRADES+1) {
		ReplyToCommand(client, "Invalid upgrade index.  Valid values are 1 to %d.", MAX_VALID_UPGRADES+1);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < targetCount; ++i) {
		RemoveSpecificUpgrade(targetList[i], upgrade);
	}
	return Plugin_Handled;
}

public Action:clearAllUpgrades(client, args) {
	if(GetCmdArgs() < 1) {
		ReplyToCommand(client, "Usage: removeAllUpgrades <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1) {
		targetCount = 0;
		for(new i = 1; i<=GetCmdArgs(); ++i) {
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)	{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k) {
					if(targetList[k] == subTargetList[j]) {
						bAdd = false;
					}
				}
				if(bAdd) {
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0) {
		ReplyToCommand(client, "%t", "No matching clients");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < targetCount; ++i) {
		RemoveAllUpgrades(INVALID_HANDLE, targetList[i]);
		ReplyToCommand(client, "Removed all upgrades for %N", targetList[i]);
	}
	
	return Plugin_Handled;
}
#endif

public Action:ShowUpgrades(client, args) {
	#if BOOL_SELECTIVE_GAMEMODES
	if(!b_InvalidGameMode) {
	#endif
		ListMyUpgrades(client, false);
	#if BOOL_SELECTIVE_GAMEMODES
	}
	#endif
	
	return Plugin_Handled;
}

#if BOOL_SELECTIVE_GAMEMODES
#if BOOL_ADMIN_COMMANDS
public Action:invalidCmdAdmin(client, args) {
	ReplyToCommand(client, "%s %t", PLUGIN_TAG_C, "CHAT_INFO_DISABLED", g_CurrentMode);
	
	return Plugin_Handled;
}
#endif

public Action:invalidCmdClient(client, args) {
	PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_INFO_DISABLED", g_CurrentMode);
	
	return Plugin_Handled;
}
#endif

public Action:ToggleLaser(client, args) {
	if(!b_Upgrades_Client[client][6]) return Plugin_Handled;
	if(b_Upgrades_Laser[client]) {
		PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_INFO_LASEROFF");
		SDKCall(RemoveUpgrade, client, 17);
		b_Upgrades_Laser[client] = false;
	} else {
		PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_INFO_LASERON");
		SDKCall(AddUpgrade, client, 17);
		b_Upgrades_Laser[client] = true;
	}
	
	return Plugin_Handled;
}
#if BOOL_SHOW_AMMOPANEL
public AmmoTypePanelHandler(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select) {	
		if(param2 <= MAX_SPECIALAMMOTYPES+1) {
			ChangeAmmoType(client, param2-1);
		} else if(param2 == MAX_SPECIALAMMOTYPES+1+1) {
			// Toggle Persistent Menu
			if(b_Persistent_Menu[client])
				b_Persistent_Menu[client] = false;
			else
				b_Persistent_Menu[client] = true;
		} else if(param2 == MAX_SPECIALAMMOTYPES+1+2) {
			// Toggle SpecialAmmo AutoSwitch
			if(b_SpecialAmmo_AutoSwitch[client]) {
				b_SpecialAmmo_AutoSwitch[client] = false;
				PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_AUTOSWITCH_OFF");
			} else {
				b_SpecialAmmo_AutoSwitch[client] = true;
				PrintToChat(client, "%s %t", PLUGIN_TAG_C, "CHAT_SPECIALAMMO_AUTOSWITCH_ON");
			}
		#if BOOL_SHOW_SPECIALAMMO
		} else if(param2 == MAX_SPECIALAMMOTYPES+1+3) {
			// Toggle Showing of AmmoCount
			if(b_Show_Ammocount[client])
				b_Show_Ammocount[client] = false;
			else
				b_Show_Ammocount[client] = true;
		#endif
		}
		
		// If persistent menu, refresh ammopanel
		if(b_Persistent_Menu[client] && GetClientTeam(client) == SURVIVORS_TEAMNUM) {
			ShowAmmoTypePanel(client, 0);
		}
	}
}

public Action:ShowAmmoTypePanel(client, args) {
	#if DEBUG
	PrintToServer("%s #DEBUG: AmmoTypePanel for %N!", PLUGIN_TAG, client);
	#endif
	decl String:tmpString[64];
	Format(tmpString, sizeof(tmpString), "%T", "LABEL_AMMOTYPES", client);
	new Handle:AmmoTypePanel = CreatePanel(GetMenuStyleHandle(MenuStyle_Radio));
	SetPanelTitle(AmmoTypePanel, tmpString);
	
	if(g_Upgrades_SpecialAmmotype[client] == 0)
		Format(tmpString, sizeof(tmpString), "> %T: -", "LABEL_NORMALAMMO", client);
	else
		Format(tmpString, sizeof(tmpString), "%T: -", "LABEL_NORMALAMMO", client);
	DrawPanelItem(AmmoTypePanel, tmpString);
	
	if(g_Upgrades_SpecialAmmotype[client] == 1)
		Format(tmpString, sizeof(tmpString), "> %T: %d", "LABEL_HOLLOWPOINT", client, g_Upgrades_SpecialAmmo[0][client]);
	else
		Format(tmpString, sizeof(tmpString), "%T: %d", "LABEL_HOLLOWPOINT", client, g_Upgrades_SpecialAmmo[0][client]);
	DrawPanelItem(AmmoTypePanel, tmpString);
	
	if(g_Upgrades_SpecialAmmotype[client] == 2)
		Format(tmpString, sizeof(tmpString), "> %T: %d", "LABEL_INCENDIARY", client, g_Upgrades_SpecialAmmo[1][client]);
	else
		Format(tmpString, sizeof(tmpString), "%T: %d", "LABEL_INCENDIARY", client, g_Upgrades_SpecialAmmo[1][client]);
	DrawPanelItem(AmmoTypePanel, tmpString);
	
	DrawPanelItem(AmmoTypePanel, " ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
	
	if(b_Persistent_Menu[client])
		Format(tmpString, sizeof(tmpString), "%T | %T", "LABEL_PERSISTENTMENU", client, "LABEL_YES", client);
	else
		Format(tmpString, sizeof(tmpString), "%T | %T", "LABEL_PERSISTENTMENU", client, "LABEL_NO", client);
	DrawPanelItem(AmmoTypePanel, tmpString);	
	
	if(b_SpecialAmmo_AutoSwitch[client])
		Format(tmpString, sizeof(tmpString), "%T | %T", "LABEL_AUTOSWITCH", client, "LABEL_YES", client);
	else
		Format(tmpString, sizeof(tmpString), "%T | %T", "LABEL_AUTOSWITCH", client, "LABEL_NO", client);
	DrawPanelItem(AmmoTypePanel, tmpString);
	
	#if BOOL_SHOW_SPECIALAMMO
	if(b_Show_Ammocount[client])
		Format(tmpString, sizeof(tmpString), "%T | %T", "LABEL_SHOW_AMMOCOUNT", client, "LABEL_YES", client);
	else
		Format(tmpString, sizeof(tmpString), "%T | %T", "LABEL_SHOW_AMMOCOUNT", client, "LABEL_NO", client);
	DrawPanelItem(AmmoTypePanel, tmpString);
	#endif
	
	if(SendPanelToClient(AmmoTypePanel, client, AmmoTypePanelHandler, 10))
		CloseHandle(AmmoTypePanel);
	
	return Plugin_Handled;
}
#endif

public Action:CheckLaser(Handle:hTimer) {
	for(new i = 1; i < MaxClients; i++) {
		if(IsClientInGame(i)) {
			if(IsFakeClient(i) && b_Upgrades_Client[i][6]) {
				#if BOOL_FORCE_BOT_LASER
				// Turn on lasers for all bots
				SDKCall(RemoveUpgrade, i, 17);
				SDKCall(AddUpgrade, i, 17);
				#endif
			} else {
				if(!b_Upgrades_Laser[i]) {
					// Was NOT activated previous round
					SDKCall(RemoveUpgrade, i, 17);
				} else {
					// Was activated previous round
					SDKCall(RemoveUpgrade, i, 17);
					SDKCall(AddUpgrade, i, 17);
				}
			}
		}
	}
}

public Action:UserHelp(client, args) {
	PrintToChat(client, "\x05| %t", "UPGHELP_HEADER_ENABLED", PLUGIN_VERSION);
	// If InvalidGameMode then there's nothing else to be done.
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode) {
		PrintToChat(client, "\x05| %t", "UPGHELP_HEADER_DISABLED", g_CurrentMode); 
		return Plugin_Handled;
	}
	#endif
	new ask = 1;
	if(GetCmdArgs() >= 1) {
		decl String:arg[3];
		GetCmdArg(1, arg, sizeof(arg));
		ask = StringToInt(arg);
		if(ask > 3 || ask < 1)
			ask = 1;
	}
	if(ask == 1) {
		// Normal help
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_1_SAY");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_LASERTOGGLE");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGRADES");
		#if BOOL_SHOW_AMMOPANEL
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_AMMOTYPE");
		#endif
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGHELP");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGHELP2");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGHELP3");
	} else if(ask == 2) {
		// When do we get upgrades?
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_2_UPGRADESPER");
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_2_MISSIONSTART", GetConVarInt(UpgradesSpawnAll));
		#if BOOL_UPGRADE_KILLS
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_2_KILLS", g_UpgradesKillCount, g_UpgradesKillAmount);
		#endif
		#if BOOL_UPGRADE_TANK
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_2_TANK", GetConVarInt(UpgradesTankSpawn), GetConVarInt(UpgradesTankAll), GetConVarInt(UpgradesTankKiller));
		#endif
		#if BOOL_UPGRADE_WITCH
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_2_WITCH", GetConVarInt(UpgradesWitchAll), GetConVarInt(UpgradesWitchKiller), GetConVarInt(UpgradesWitchCr0wned));
		#endif
		#if BOOL_UPGRADE_HEAL
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_2_HEAL", GetConVarInt(UpgradesHealAmount), GetConVarInt(UpgradesHealPlayer), GetConVarInt(UpgradesHealSelf));
		#endif
	} else if(ask == 3) {
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_SETTINGS");
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_SPECIALAMMO", GetConVarInt(UpgradeSpecialAmmoCount), g_UpgradeSpecialAmmoMinusSG);
		#if BOOL_UPGRADE_KILLS
		#if BOOL_TRACK_MEGAKILLS
		if(GetConVarInt(UpgradesKillAward) == 1)
			PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_MEGAKILLS_AWARD1");
		else if(GetConVarInt(UpgradesKillAward) == 2)
			PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_MEGAKILLS_AWARD2", g_UpgradesKillAmount);
		else
			PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_MEGAKILLS_AWARD0", g_UpgradesKillAmount);
		#else
		if(GetConVarInt(UpgradesKillAward) == 1)
			PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_NOMEGAKILLS_AWARD1");
		else if(GetConVarInt(UpgradesKillAward) == 2)
			PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_NOMEGAKILLS_AWARD2", g_UpgradesKillAmount);
		else
			PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_NOMEGAKILLS_AWARD0", g_UpgradesKillAmount);
		#endif
		#endif
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_RELOADER", GetConVarFloat(UpgradeReloaderSpeed), GetConVarFloat(UpgradeReloaderShotgunSpeed));
		#if BOOL_ALLOW_INCENDIARY
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_3_INCENDIARY", b_IgniteTank, b_IgniteSpecial);
		#endif
	}
	
	return Plugin_Handled;
}

#if BOOL_ANNOUNCE_PLUGIN
// Show help 20 seconds after connecting
public OnClientPutInServer(client) {
	if(g_Verbosity > 0) {
		CreateTimer(20.0, ShowHelp, client);
	}
}

public Action:ShowHelp(Handle:hTimer, any:client) {
	if(!IsClientInGame(client)) return;
	if(GetClientTeam(client) != SURVIVORS_TEAMNUM) return;
	GiveInitialUpgrades(INVALID_HANDLE, client);
	if(IsFakeClient(client)) return;
	
	PrintToChat(client, "\x05| \x01%t", "ANNOUNCE_SERVER_RUNNING", PLUGIN_VERSION);
	#if BOOL_SELECTIVE_GAMEMODES
	if(b_InvalidGameMode) {
		PrintToChat(client, "\x05| \x04%t", "ANNOUNCE_SERVER_NOTRUNNING", g_CurrentMode);
	} else {
	#endif
		// Print everything equivalent to /upghelp (1)
		PrintToChat(client, "\x05| \x01%t", "UPGHELP_1_SAY");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_LASERTOGGLE");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGRADES");
		#if BOOL_SHOW_AMMOPANEL
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_AMMOTYPE");
		#endif
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGHELP");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGHELP2");
		PrintToChat(client, "\x05| \x04%t", "UPGHELP_1_UPGHELP3");
	#if BOOL_SELECTIVE_GAMEMODES
	}
	#endif
}
#endif
/*** -- END Commands -- ***/
#if DEBUG
/*** --- #DEBUG COMMANDS --- ***/
public Action:debug_AddUpgIndex(client, args) {
	if(GetCmdArgs() >= 1) {
		decl String:arg[3];
		GetCmdArg(1, arg, sizeof(arg));
		ask = StringToInt(arg);
		new i = 0;
		for(i = 0; i < MAX_VALID_UPGRADES+1; i++) {
			if(ask == IndexToUpgrade[i]) {
				ReplyToCommand(client, "%s #DEBUG: UpgInd#[%d] is found in PI: #%d, %s", PLUGIN_TAG, ask, i+1, UpgradeShortInfo[i]);
				ReplyToCommand(client, "%s #DEBUG: Use {addupgrade %d #%d} in console to giveupgrade.", PLUGIN_TAG, ask, GetClientUserId(client));
				return Plugin_Handled;
			}
		}
		ReplyToCommand(client, "%s #DEBUG: UpgInd#[%d] being given...", PLUGIN_TAG, ask);
		SDKCall(AddUpgrade, client, ask);
		ReplyToCommand(client, "%s #DEBUG: UpgInd#[%d] given! Use {dbgremupgindex %d} to remove.", PLUGIN_TAG, ask, ask);
	} else {
		ReplyToCommand(client, "%s #DEBUG: Please enter an Upgrade Index to add to %N", PLUGIN_TAG, client);
	}
	
	return Plugin_Handled;
}

public Action:debug_RemUpgIndex(client, args) {
	if(GetCmdArgs() >= 1) {
		decl String:arg[3];
		GetCmdArg(1, arg, sizeof(arg));
		ask = StringToInt(arg);
		new i = 0;
		for(i = 0; i < MAX_VALID_UPGRADES+1; i++) {
			if(ask == IndexToUpgrade[i]) {
				ReplyToCommand(client, "%s #DEBUG: UpgInd#[%d] is found in PI: #%d, %s", PLUGIN_TAG, ask, i+1, UpgradeShortInfo[i]);
				ReplyToCommand(client, "%s #DEBUG: Use {removeupgrade %d #%d} in console to removeupgrade.", PLUGIN_TAG, ask, GetClientUserId(client));
				return Plugin_Handled;
			}
		}
		ReplyToCommand(client, "%s #DEBUG: UpgInd#[%d] being removed...", PLUGIN_TAG, ask);
		SDKCall(RemoveUpgrade, client, ask);
		ReplyToCommand(client, "%s #DEBUG: UpgInd#[%d] removed!", PLUGIN_TAG, ask, ask);
	} else {
		ReplyToCommand(client, "%s #DEBUG: Please enter an Upgrade Index to remove to %N", PLUGIN_TAG, client);
	}
	
	return Plugin_Handled;
}
/*** --- END #DEBUG COMMANDS --- ***/
#endif
#if DEBUG_EXPERIMENTAL
public Action:SetLaserColour(client) {
	SetEntData(client, laserColourOffset[0], 0, 4, true);	//offset 48 (Red)
	SetEntData(client, laserColourOffset[1], 192, 4, true);	//offset 52 (Green)
	SetEntData(client, laserColourOffset[2], 0, 4, true);	//offset 56 (Blue)	
}
#endif
