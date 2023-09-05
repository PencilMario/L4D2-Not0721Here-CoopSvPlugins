/*======================================================================================
	This is a modified version of Bot Improver
	
	Notable changes here:
	
	OnPlayerRunCmd()
	SurvivorBotThink() - slight change for witch targeting, also changed item scavenge behavior
	CheckEntityForStuff()
	CheckForItemsToScavenge()
	GetItemFromArrayList()
	GetWeaponClassname()
	GetWeaponMaxAmmo()
	GetWeaponTier()
	SurvivorHasPistol() and similar
	GetSurvivorTeamInventoryCount() - new
	GetClientDistanceToItem() - to replace GetEntityDistance()
	L4D2_OnFindScavengeItem()
	
	GetNavDistance() - to replace GetVectorTravelDistance(). If you pass an entity ID to it, it will remember
	if distance to the entity could not be measured, and won't hammer the server with more useless calculations. Yay!
	
	GetClientTravelDistance() - L4D2_IsReachable is used instead of L4D2_NavAreaBuildPath. It does essentially same thing,
	outputs same boolean, and does not cause as much lag as the other function.
	
	LBI_IsReachablePosition() - argument to ignore LOS when picking nearest nav area.
	LBI_IsPathToPositionDangerous() - L4D2_IsReachable is used instead of L4D2_NavAreaBuildPath. Additional cutoff for amount of processed nav areas.
	DTR_OnFindUseEntity() - prevent bots from grabbing items from absurd distances.
	VScript_TryGetPathableLocationWithin() - new

======================================================================================*/

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>


#include <profiler>
#include <adt_trie>
#include <vscript> //https://github.com/FortyTwoFortyTwo/VScript
#include <dhooks>
#include <left4dhooks>
#undef REQUIRE_EXTENSIONS
#include <actions>
#define REQUIRE_EXTENSIONS

public Plugin myinfo = 
{
	name 		= "[L4D2] Survivor Bot AI Improver",
	author 		= "Emana202, Kerouha",
	description = "Attempt at improving survivor bots' AI and behaviour as much as possible.",
	version 	= "1.5k",
	url 		= "https://forums.alliedmods.net/showthread.php?t=342872"
}

#define MAXENTITIES 				2048
#define MAP_SCAN_TIMER_INTERVAL		2.0

#define BOT_BOOMER_AVOID_RADIUS_SQR		40000.0
#define BOT_GRENADE_CHECK_RADIUS_SQR	90000.0
#define BOT_CMD_MOVE_INTERVAL 		0.8

#define HUMAN_HEIGHT				71.0
#define HUMAN_HALF_HEIGHT			35.5

#define FLAG_NOITEM		0
#define FLAG_ITEM		1 << 0
#define FLAG_WEAPON		1 << 1
#define FLAG_CSS		1 << 2
#define FLAG_AMMO		1 << 3
#define FLAG_UPGRADE	1 << 4
#define FLAG_CARRY		1 << 5
#define FLAG_MELEE		1 << 6
#define FLAG_TIER1		1 << 7
#define FLAG_TIER2		1 << 8
#define FLAG_TIER3		1 << 9
#define FLAG_PISTOL		1 << 10
#define FLAG_PISTOL_EXTRA 1 << 11
#define FLAG_SMG		1 << 12
#define FLAG_SHOTGUN	1 << 13
#define FLAG_ASSAULT	1 << 14
#define FLAG_SNIPER		1 << 15
#define FLAG_CHAINSAW	1 << 16
#define FLAG_GL			1 << 17
#define FLAG_M60		1 << 18
#define FLAG_HEAL		1 << 19
#define FLAG_GREN		1 << 20
#define FLAG_DEFIB		1 << 21
#define FLAG_MEDKIT		1 << 22

#define STATE_NEEDS_COVER	1 << 0
#define STATE_NEEDS_AMMO	1 << 1
#define STATE_NEEDS_WEAPON	1 << 2
#define STATE_WOULD_HEAL	1 << 3
#define STATE_WOULD_PICK_MELEE 1 << 4
#define STATE_WOULD_PICK_T3	1 << 5

#define PICKUP_PIPE		1 << 0
#define PICKUP_MOLO		1 << 1
#define PICKUP_BILE		1 << 2
#define PICKUP_MEDKIT	1 << 3
#define PICKUP_DEFIB	1 << 4
#define PICKUP_UPGRADE	1 << 5	//deployable ammo boxes
#define PICKUP_PILLS	1 << 6
#define PICKUP_ADREN	1 << 7
#define PICKUP_LASER	1 << 8
#define PICKUP_AMMOPACK 1 << 9	//flame/frag rounds from deployed boxes
#define PICKUP_AMMO		1 << 10
#define PICKUP_CHAINSAW	1 << 11
#define PICKUP_SECONDARY 1 << 12
#define PICKUP_PRIMARY	1 << 13

//0: Disable, 1: Pipe Bomb, 2: Molotov, 4: Bile Bomb, 8: Medkit, 16: Defibrillator, 32: UpgradePack, 64: Pain Pills
//128: Adrenaline, 256: Laser Sights, 512: Ammopack, 1024: Ammopile, 2048: Chainsaw, 4096: Secondary Weapons, 8192: Primary Weapons

static const char IBWeaponName[][] =
{
	"weapon_none",					// 0
	"weapon_pistol",				// 1
	"weapon_smg",					// 2
	"weapon_pumpshotgun",			// 3
	"weapon_autoshotgun",			// 4
	"weapon_rifle",					// 5
	"weapon_hunting_rifle",			// 6
	"weapon_smg_silenced",			// 7
	"weapon_shotgun_chrome",		// 8
	"weapon_rifle_desert",			// 9
	"weapon_sniper_military",		// 10
	"weapon_shotgun_spas",			// 11
	"weapon_first_aid_kit",			// 12
	"weapon_molotov",				// 13
	"weapon_pipe_bomb",				// 14
	"weapon_pain_pills",			// 15
	"weapon_gascan",				// 16
	"weapon_propanetank",			// 17
	"weapon_oxygentank",			// 18
	"weapon_melee",					// 19
	"weapon_chainsaw",				// 20
	"weapon_grenade_launcher",		// 21
	"weapon_ammo_pack",				// 22
	"weapon_adrenaline",			// 23
	"weapon_defibrillator",			// 24
	"weapon_vomitjar",				// 25
	"weapon_rifle_ak47",			// 26
	"weapon_gnome",					// 27
	"weapon_cola_bottles",			// 28
	"weapon_fireworkcrate",			// 29
	"weapon_upgradepack_incendiary",// 30
	"weapon_upgradepack_explosive",	// 31
	"weapon_pistol_magnum",			// 32
	"weapon_smg_mp5",				// 33
	"weapon_rifle_sg552",			// 34
	"weapon_sniper_awp",			// 35
	"weapon_sniper_scout",			// 36
	"weapon_rifle_m60",				// 37
	"weapon_tank_claw",				// 38
	"weapon_hunter_claw",			// 39
	"weapon_charger_claw",			// 40
	"weapon_boomer_claw",			// 41
	"weapon_smoker_claw",			// 42
	"weapon_spitter_claw",			// 43
	"weapon_jockey_claw",			// 44
	"weapon_machinegun",			// 45
	"vomit",						// 46
	"splat",						// 47
	"pounce",						// 48
	"lounge",						// 49
	"pull",							// 50
	"choke",						// 51
	"rock",							// 52
	"physics",						// 53
	"weapon_ammo",					// 54
	"upgrade_item"					// 55
};

static const char IBItemFlagName[23][12] =
{
	"ITEM",
	"WEAPON",
	"CSS",
	"AMMO",
	"UPGRADE",
	"CARRY",
	"MELEE",
	"TIER1",
	"TIER2",
	"TIER3",
	"PISTOL",
	"PISTOL_EXTRA",
	"SMG",
	"SHOTGUN",
	"ASSAULT",
	"SNIPER",
	"CHAINSAW",
	"GL",
	"M60",
	"HEAL",
	"GREN",
	"DEFIB",
	"MEDKIT"
};
/*
static const char IBStateName[][] =
{
	"Needs cover",
	"Needs ammo",
	"Needs weapon",
	"Would heal if extra helath/defib found",
	"Would pick Tier 3 weapon"
};
*/
enum
{
	L4D_SURVIVOR_NICK			= 1,
	L4D_SURVIVOR_ROCHELLE 		= 2,
	L4D_SURVIVOR_COACH			= 3,
	L4D_SURVIVOR_ELLIS			= 4,
	L4D_SURVIVOR_BILL			= 5,
	L4D_SURVIVOR_ZOEY			= 6,
	L4D_SURVIVOR_FRANCIS		= 7,
	L4D_SURVIVOR_LOUIS 			= 8
}

enum
{
	L4D_WEAPON_PREFERENCE_ASSAULTRIFLE 	= 1,
	L4D_WEAPON_PREFERENCE_SHOTGUN		= 2,
	L4D_WEAPON_PREFERENCE_SNIPERRIFLE	= 3,
	L4D_WEAPON_PREFERENCE_SMG			= 4,
	L4D_WEAPON_PREFERENCE_SECONDARY		= 5
}

/*============ IN-GAME CONVARS =======================================================================*/
static ConVar g_hCvar_GameDifficulty; 
static ConVar g_hCvar_SurvivorLimpHealth;
static ConVar g_hCvar_TankRockHealth;
static ConVar g_hCvar_GasCanUseDuration;
static ConVar g_hCvar_ChaseBileRange;
static ConVar g_hCvar_ServerGravity;
static ConVar g_hCvar_BileCoverDuration_Bot;
static ConVar g_hCvar_BileCoverDuration_PZ;

static ConVar g_hCvar_MaxMeleeSurvivors; 
static ConVar g_hCvar_BotsShootThrough;
static ConVar g_hCvar_BotsFriendlyFire;
static ConVar g_hCvar_BotsDisabled;
static ConVar g_hCvar_BotsDontShoot;
static ConVar g_hCvar_BotsVomitBlindTime;

static char g_sCvar_GameDifficulty[12]; 
static int g_iCvar_SurvivorLimpHealth; 
static int g_iCvar_TankRockHealth; 
static float g_fCvar_GasCanUseDuration; 
static float g_fCvar_ChaseBileRange; 
static float g_fCvar_ServerGravity; 
static float g_fCvar_BileCoverDuration_Bot;
static float g_fCvar_BileCoverDuration_PZ;

static int g_iCvar_MaxMeleeSurvivors; 
static bool g_bCvar_BotsShootThrough;
static bool g_bCvar_BotsFriendlyFire;
static bool g_bCvar_BotsDisabled;
static bool g_bCvar_BotsDontShoot;
static float g_fCvar_BotsVomitBlindTime;

/*============ AMMO RELATED CONVARS =================================================================*/
static ConVar g_hCvar_MaxAmmo_Pistol;
static ConVar g_hCvar_MaxAmmo_AssaultRifle;
static ConVar g_hCvar_MaxAmmo_SMG;
static ConVar g_hCvar_MaxAmmo_M60;
static ConVar g_hCvar_MaxAmmo_Shotgun;
static ConVar g_hCvar_MaxAmmo_AutoShotgun;
static ConVar g_hCvar_MaxAmmo_HuntRifle;
static ConVar g_hCvar_MaxAmmo_SniperRifle;
static ConVar g_hCvar_MaxAmmo_PipeBomb;
static ConVar g_hCvar_MaxAmmo_Molotov;
static ConVar g_hCvar_MaxAmmo_VomitJar;
static ConVar g_hCvar_MaxAmmo_PainPills;
static ConVar g_hCvar_MaxAmmo_GrenLauncher;
static ConVar g_hCvar_MaxAmmo_Adrenaline;
static ConVar g_hCvar_MaxAmmo_Chainsaw;
static ConVar g_hCvar_MaxAmmo_AmmoPack;
static ConVar g_hCvar_MaxAmmo_Medkit;
static ConVar g_hCvar_Ammo_Type_Override;

static int g_iCvar_MaxAmmo_Pistol;
static int g_iCvar_MaxAmmo_AssaultRifle;
static int g_iCvar_MaxAmmo_SMG;
static int g_iCvar_MaxAmmo_M60;
static int g_iCvar_MaxAmmo_Shotgun;
static int g_iCvar_MaxAmmo_AutoShotgun;
static int g_iCvar_MaxAmmo_HuntRifle;
static int g_iCvar_MaxAmmo_SniperRifle;
static int g_iCvar_MaxAmmo_PipeBomb;
static int g_iCvar_MaxAmmo_Molotov;
static int g_iCvar_MaxAmmo_VomitJar;
static int g_iCvar_MaxAmmo_PainPills;
static int g_iCvar_MaxAmmo_GrenLauncher;
static int g_iCvar_MaxAmmo_Adrenaline;
static int g_iCvar_MaxAmmo_Chainsaw;
static int g_iCvar_MaxAmmo_AmmoPack;
static int g_iCvar_MaxAmmo_Medkit;
static char g_sCvar_Ammo_Type_Override[32];

/*============ MELEE RELATED CONVARS =================================================================*/
static ConVar g_hCvar_ImprovedMelee_MaxCount;

static ConVar g_hCvar_ImprovedMelee_Enabled;
static ConVar g_hCvar_ImprovedMelee_SwitchCount;
static ConVar g_hCvar_ImprovedMelee_SwitchRange;
static ConVar g_hCvar_ImprovedMelee_ApproachRange;
static ConVar g_hCvar_ImprovedMelee_AimRange;
static ConVar g_hCvar_ImprovedMelee_AttackRange;
static ConVar g_hCvar_ImprovedMelee_ShoveChance;

static bool g_bCvar_ImprovedMelee_Enabled;
static int g_iCvar_ImprovedMelee_SwitchCount; 
static int g_iCvar_ImprovedMelee_ShoveChance; 
static float g_fCvar_ImprovedMelee_SwitchRange; 
static float g_fCvar_ImprovedMelee_ApproachRange;
static float g_fCvar_ImprovedMelee_AimRange_Sqr;
static float g_fCvar_ImprovedMelee_AttackRange;
static float g_fCvar_ImprovedMelee_AttackRange_Sqr;

static ConVar g_hCvar_ImprovedMelee_ChainsawLimit;
static ConVar g_hCvar_ImprovedMelee_SwitchCount2;

static int g_iCvar_ImprovedMelee_ChainsawLimit;
static int g_iCvar_ImprovedMelee_SwitchCount2;
/*============ TARGET SELECTION CONVARS ==================================================================*/
ConVar g_hCvar_TargetSelection_Enabled;
ConVar g_hCvar_TargetSelection_ShootRange;
ConVar g_hCvar_TargetSelection_ShootRange2;
ConVar g_hCvar_TargetSelection_ShootRange3;
ConVar g_hCvar_TargetSelection_ShootRange4;
ConVar g_hCvar_TargetSelection_IgnoreDociles;

bool g_bCvar_TargetSelection_Enabled;
float g_fCvar_TargetSelection_ShootRange;
float g_fCvar_TargetSelection_ShootRange2;
float g_fCvar_TargetSelection_ShootRange3;
float g_fCvar_TargetSelection_ShootRange4;
bool g_bCvar_TargetSelection_IgnoreDociles;
/*----------------------------------------------------------------------------------------------------*/
static ConVar g_hCvar_Vision_FieldOfView;
static float g_fCvar_Vision_FieldOfView;

static ConVar g_hCvar_Vision_NoticeTimeScale;
static float g_fCvar_Vision_NoticeTimeScale;

/*============ TANK RELATED CONVARS ==================================================================*/
static ConVar g_hCvar_TankRock_ShootEnabled;
static ConVar g_hCvar_TankRock_ShootRange;
static bool g_bCvar_TankRock_ShootEnabled;
static float g_fCvar_TankRock_ShootRange;
/*============ SAVE RELATED CONVARS ==================================================================*/
static ConVar g_hCvar_AutoShove_Enabled;
static int g_iCvar_AutoShove_Enabled;
/*----------------------------------------------------------------------------------------------------*/
static ConVar g_hCvar_FireBash_Chance1;
static ConVar g_hCvar_FireBash_Chance2;
static int g_iCvar_FireBash_Chance1;
static int g_iCvar_FireBash_Chance2;
/*----------------------------------------------------------------------------------------------------*/
static ConVar g_hCvar_HelpPinnedFriend_Enabled;
static ConVar g_hCvar_HelpPinnedFriend_ShootRange;
static ConVar g_hCvar_HelpPinnedFriend_ShoveRange;
static int g_iCvar_HelpPinnedFriend_Enabled;
//static float g_fCvar_HelpPinnedFriend_ShootRange;
static float g_fCvar_HelpPinnedFriend_ShootRange_Sqr;
static float g_fCvar_HelpPinnedFriend_ShoveRange_Sqr;
/*============ WEAPON RELATED CONVARS ================================================================*/
static ConVar g_hCvar_BotWeaponPreference_ForceMagnum;
static bool g_bCvar_BotWeaponPreference_ForceMagnum;

static ConVar g_hCvar_BotWeaponPreference_Rochelle;
static ConVar g_hCvar_BotWeaponPreference_Zoey; 
static ConVar g_hCvar_BotWeaponPreference_Ellis; 
static ConVar g_hCvar_BotWeaponPreference_Coach; 
static ConVar g_hCvar_BotWeaponPreference_Francis; 
static ConVar g_hCvar_BotWeaponPreference_Nick;
static ConVar g_hCvar_BotWeaponPreference_Louis; 
static ConVar g_hCvar_BotWeaponPreference_Bill;

static int g_iCvar_BotWeaponPreference_Rochelle;
static int g_iCvar_BotWeaponPreference_Zoey;
static int g_iCvar_BotWeaponPreference_Ellis; 
static int g_iCvar_BotWeaponPreference_Coach;
static int g_iCvar_BotWeaponPreference_Francis;
static int g_iCvar_BotWeaponPreference_Nick;
static int g_iCvar_BotWeaponPreference_Louis;
static int g_iCvar_BotWeaponPreference_Bill;
/*----------------------------------------------------------------------------------------------------*/
static ConVar g_hCvar_SwapSameTypePrimaries;
static bool g_bCvar_SwapSameTypePrimaries;
/*------------ TIER 3 --------------------------------------------------------------------------------*/
static ConVar g_hCvar_MaxWeaponTier3_M60;
static ConVar g_hCvar_MaxWeaponTier3_GLauncher;
static ConVar g_hCvar_T3_Refill;

static int g_iCvar_MaxWeaponTier3_M60;
static int g_iCvar_MaxWeaponTier3_GLauncher;
static int g_iCvar_T3_Refill;

/*============ GRENADE RELATED CONVARS ===============================================================*/
static ConVar g_hCvar_GrenadeThrow_Enabled;
static ConVar g_hCvar_GrenadeThrow_GrenadeTypes;
static ConVar g_hCvar_GrenadeThrow_ThrowRange;
static ConVar g_hCvar_GrenadeThrow_HordeSize; 
static ConVar g_hCvar_GrenadeThrow_NextThrowTime1;
static ConVar g_hCvar_GrenadeThrow_NextThrowTime2;
/*----------------------------------------------------------------------------------------------------*/
static bool g_bCvar_GrenadeThrow_Enabled;
static int g_iCvar_GrenadeThrow_GrenadeTypes; 
static float g_fCvar_GrenadeThrow_ThrowRange; 
static float g_fCvar_GrenadeThrow_HordeSize; 
static float g_fCvar_GrenadeThrow_NextThrowTime1;
static float g_fCvar_GrenadeThrow_NextThrowTime2;
/*----------------------------------------------------------------------------------------------------*/
static ConVar g_hCvar_SwapSameTypeGrenades;
static bool g_bCvar_SwapSameTypeGrenades;

/*============ DEFIB RELATED CONVARS =================================================================*/
static ConVar g_hCvar_DefibRevive_Enabled; 
static ConVar g_hCvar_DefibRevive_ScanDist; 

static bool g_bCvar_DefibRevive_Enabled; 
static float g_fCvar_DefibRevive_ScanDist;

/*============ ITEM SCAVENGE RELATED CONVARS =========================================================*/
static ConVar g_hCvar_ItemScavenge_Models; 
static ConVar g_hCvar_ItemScavenge_Items; 
static ConVar g_hCvar_ItemScavenge_ApproachRange; 
static ConVar g_hCvar_ItemScavenge_ApproachVisibleRange; 
static ConVar g_hCvar_ItemScavenge_PickupRange; 
static ConVar g_hCvar_ItemScavenge_MapSearchRange; 
static ConVar g_hCvar_ItemScavenge_NoHumansRangeMultiplier; 

static int g_iCvar_ItemScavenge_Models;
static int g_iCvar_ItemScavenge_Items;
static float g_fCvar_ItemScavenge_ApproachRange;
static float g_fCvar_ItemScavenge_ApproachVisibleRange;
static float g_fCvar_ItemScavenge_PickupRange;
static float g_fCvar_ItemScavenge_PickupRange_Sqr;
static float g_fCvar_ItemScavenge_MapSearchRange_Sqr;
static float g_fCvar_ItemScavenge_NoHumansRangeMultiplier;

/*============ WITCH RELATED CONVARS =========================================================*/
static ConVar g_hCvar_WitchBehavior_WalkWhenNearby;
static ConVar g_hCvar_WitchBehavior_AllowCrowning;

static float g_fCvar_WitchBehavior_WalkWhenNearby;
static int g_iCvar_WitchBehavior_AllowCrowning;

/*============ PERFOMANCE RELATED CONVARS =========================================================*/
static ConVar g_hCvar_NextProcessTime;
static float g_fCvar_NextProcessTime;

/*============ MISC CONVARS =========================================================*/
static ConVar g_hCvar_AlwaysCarryProp;
static ConVar g_hCvar_SpitterAcidEvasion;
static ConVar g_hCvar_SwitchOffCSSWeapons;
static ConVar g_hCvar_KeepMovingInCombat;
static ConVar g_hCvar_ChargerEvasion;
static ConVar g_hCvar_DeployUpgradePacks;
static ConVar g_hCvar_DontSwitchToPistol;
static ConVar g_hCvar_TakeCoverFromRocks;
static ConVar g_hCvar_AvoidTanksWithProp;
static ConVar g_hCvar_NoFallDmgOnLadderFail;

static bool g_bCvar_SpitterAcidEvasion;
static bool g_bCvar_AlwaysCarryProp;
static bool g_bCvar_SwitchOffCSSWeapons;
static bool g_bCvar_ChargerEvasion;
static bool g_bCvar_DeployUpgradePacks;
static bool g_bCvar_DontSwitchToPistol;
static bool g_bCvar_TakeCoverFromRocks;
static bool g_bCvar_AvoidTanksWithProp;
static bool g_bCvar_NoFallDmgOnLadderFail;

/*============ VARIABLES =========================================================*/
static float g_fSurvivorBot_NextPressAttackTime[MAXPLAYERS+1];

static int g_iSurvivorBot_TargetInfected[MAXPLAYERS+1];
static int g_iSurvivorBot_IncapacitatedFriend[MAXPLAYERS+1];
static int g_iSurvivorBot_PinnedFriend[MAXPLAYERS+1];

static int g_iSurvivorBot_WitchTarget[MAXPLAYERS+1];
static bool g_bSurvivorBot_IsWitchHarasser[MAXPLAYERS+1];

static bool g_bSurvivorBot_PreventFire[MAXPLAYERS+1];

static bool g_bClient_IsLookingAtPosition[MAXPLAYERS+1];
static bool g_bClient_IsFiringWeapon[MAXPLAYERS+1];

static int g_iSurvivorBot_ScavengeItem[MAXPLAYERS+1];
static float g_fSurvivorBot_ScavengeItemDist[MAXPLAYERS+1];
static float g_fSurvivorBot_NextUsePressTime[MAXPLAYERS+1];
static float g_fSurvivorBot_NextScavengeItemScanTime[MAXPLAYERS+1];

static float g_fSurvivorBot_VomitBlindedTime[MAXPLAYERS+1];

static float g_fSurvivorBot_NextMoveCommandTime[MAXPLAYERS+1];

static float g_fSurvivorBot_BlockWeaponSwitchTime[MAXPLAYERS+1];
static float g_fSurvivorBot_BlockWeaponReloadTime[MAXPLAYERS+1];

static float g_fSurvivorBot_MeleeApproachTime[MAXPLAYERS+1];
static float g_fSurvivorBot_MeleeAttackTime[MAXPLAYERS+1];

static float g_fSurvivorBot_TimeSinceLeftLadder[MAXPLAYERS+1];

static int g_iSurvivorBot_DefibTarget[MAXPLAYERS+1];

static int g_iSurvivorBot_Grenade_ThrowTarget[MAXPLAYERS+1];
static float g_fSurvivorBot_Grenade_ThrowPos[MAXPLAYERS+1][3];
static float g_fSurvivorBot_Grenade_AimPos[MAXPLAYERS+1][3];

static float g_fSurvivorBot_Grenade_NextThrowTime;
static float g_fSurvivorBot_Grenade_NextThrowTime_Molotov;

static float g_fSurvivorBot_LookPosition[MAXPLAYERS+1][3];
static float g_fSurvivorBot_LookPosition_Duration[MAXPLAYERS+1];

static float g_fSurvivorBot_MovePos_Position[MAXPLAYERS+1][3];
static float g_fSurvivorBot_MovePos_Duration[MAXPLAYERS+1];
static int g_iSurvivorBot_MovePos_Priority[MAXPLAYERS+1];
static float g_fSurvivorBot_MovePos_Tolerance[MAXPLAYERS+1];
static bool g_bSurvivorBot_MovePos_IgnoreDamaging[MAXPLAYERS+1];
static char g_sSurvivorBot_MovePos_Name[MAXPLAYERS+1][64];

static bool g_bSurvivorBot_ForceSwitchWeapon[MAXPLAYERS+1];
static bool g_bSurvivorBot_ForceBash[MAXPLAYERS+1];

static float g_fSurvivorBot_PinnedReactTime[MAXPLAYERS+1];

static int g_iSurvivorBot_NearbyInfectedCount[MAXPLAYERS+1]; 
static int g_iSurvivorBot_NearestInfectedCount[MAXPLAYERS+1]; 
static int g_iSurvivorBot_ThreatInfectedCount[MAXPLAYERS+1]; 
static int g_iSurvivorBot_GrenadeInfectedCount[MAXPLAYERS+1];

static int g_iSurvivorBot_VisionMemory_State[MAXPLAYERS+1][MAXENTITIES+1];
static int g_iSurvivorBot_VisionMemory_State_FOV[MAXPLAYERS+1][MAXENTITIES+1];

static float g_fSurvivorBot_VisionMemory_Time[MAXPLAYERS+1][MAXENTITIES+1];
static float g_fSurvivorBot_VisionMemory_Time_FOV[MAXPLAYERS+1][MAXENTITIES+1];

static float g_fSurvivorBot_NextWeaponRangeSwitchTime[MAXPLAYERS+1];

static bool g_bSurvivorBot_ForceWeaponReload[MAXPLAYERS+1];

static int g_iSurvivorBot_NearbyFriends[MAXPLAYERS+1];

static int g_iBotProcessing_ProcessedCount;
static bool g_bBotProcessing_IsProcessed[MAXPLAYERS+1];
static float g_fBotProcessing_NextProcessTime;

static int g_iInfectedBot_CurrentVictim[MAXPLAYERS+1];
static bool g_bInfectedBot_IsThrowing[MAXPLAYERS+1];
static float g_fInfectedBot_CoveredInVomitTime[MAXPLAYERS+1];

static bool g_bMapStarted;
static bool g_bCutsceneIsPlaying;
static char g_sCurrentMapName[128];

// ----------------------------------------------------------------------------------------------------
// TESTING
// ----------------------------------------------------------------------------------------------------
static ConVar g_hCvar_Debug;
static int g_bCvar_Debug;

//static int g_iTester;
static int g_iTeamLeader;
static int g_iTestTraceEnt;
static int g_iTestSubject;
//static int g_iTimesPostponed;

Profiler g_pProf;

// ----------------------------------------------------------------------------------------------------
// CLIENT GLOBAL DATA
// ----------------------------------------------------------------------------------------------------
static float g_fClientEyePos[MAXPLAYERS+1][3];
static float g_fClientEyeAng[MAXPLAYERS+1][3];
static float g_fClientAbsOrigin[MAXPLAYERS+1][3];
static float g_fClientCenteroid[MAXPLAYERS+1][3];
static int g_iClientNavArea[MAXPLAYERS+1];
static int g_iClientInventory[MAXPLAYERS+1][6];
static int g_iClientInvFlags[MAXPLAYERS+1];
//static int g_iClientState[MAXPLAYERS+1];

// ----------------------------------------------------------------------------------------------------
// WEAPON GLOBAL DATA
// ----------------------------------------------------------------------------------------------------
static bool g_bInitCheckCases;
static bool g_bInitItemFlags;
static bool g_bInitMaxAmmo;
static bool g_bInitWeaponMap;
static bool g_bInitWeaponMdlMap;
static bool g_bInitWeaponSpawnMap;
static bool g_bInitWeaponToIDMap;

static bool g_bIsSemiAuto[56];
static int g_iWeaponID[MAXENTITIES+1];
static int g_iItemFlags[MAXENTITIES+1];
static int g_iMaxAmmo[56];
static int g_iWeaponTier[56];
static int g_iWeapon_Clip1[MAXENTITIES+1];
static int g_iWeapon_MaxAmmo[MAXENTITIES+1]; 
static int g_iWeapon_AmmoLeft[MAXENTITIES+1];
static int g_iItem_Used[MAXENTITIES+1]; // To fix bots grabbing same ammo upgrade repeatedly

static Handle g_hCheckWeaponTimer;

// ----------------------------------------------------------------------------------------------------
// LOOKUP HASH MAPS
// ----------------------------------------------------------------------------------------------------
StringMap g_hItemFlagMap;
StringMap g_hWeaponMap;
StringMap g_hWeaponSpawnMap;
StringMap g_hWeaponMdlMap;
StringMap g_hWeaponToIDMap;
StringMap g_hCheckCases;

// ----------------------------------------------------------------------------------------------------
// VSCRIPT
// ----------------------------------------------------------------------------------------------------
static VScriptExecute g_vsPathWithin;
static bool g_bInitPathWithin;

// ----------------------------------------------------------------------------------------------------
// ENTITY ARRAYLISTS
// ----------------------------------------------------------------------------------------------------
static ArrayList g_hMeleeList;
static ArrayList g_hPistolList;
static ArrayList g_hSMGList;
static ArrayList g_hShotgunT1List;
static ArrayList g_hShotgunT2List;
static ArrayList g_hAssaultRifleList;
static ArrayList g_hSniperRifleList;
static ArrayList g_hTier3List;
static ArrayList g_hGrenadeList;
static ArrayList g_hFirstAidKitList;
static ArrayList g_hDefibrillatorList;
static ArrayList g_hUpgradePackList;
static ArrayList g_hPainPillsList;
static ArrayList g_hAdrenalineList;

static ArrayList g_hAmmopileList;
static ArrayList g_hLaserSightList;
static ArrayList g_hDeployedAmmoPacks;
static ArrayList g_hForbiddenItemList;
static ArrayList g_hWeaponsToCheckLater;

static ArrayList g_hWitchList;

// ----------------------------------------------------------------------------------------------------
// PREVENT REPEATED UNSUCCESSFUL PATH DISTANCE CALCULATION
// ----------------------------------------------------------------------------------------------------
static ArrayList g_hBadPathEntities;
static Handle g_hClearBadPathTimer;

// ----------------------------------------------------------------------------------------------------
// CHARACTER MODEL BONES
// ----------------------------------------------------------------------------------------------------
static const char g_sBoneNames_Old[][] =
{
	"ValveBiped.Bip01_Head1", 
	"ValveBiped.Bip01_Spine", 
	"ValveBiped.Bip01_Spine1", 
	"ValveBiped.Bip01_Spine2", 
	"ValveBiped.Bip01_Spine4", 
	"ValveBiped.Bip01_L_UpperArm", 
	"ValveBiped.Bip01_L_Forearm", 
	"ValveBiped.Bip01_L_Hand", 
	"ValveBiped.Bip01_R_UpperArm", 
	"ValveBiped.Bip01_R_Forearm", 
	"ValveBiped.Bip01_R_Hand", 
	"ValveBiped.Bip01_Pelvis", 
	"ValveBiped.Bip01_L_Thigh", 
	"ValveBiped.Bip01_L_Knee", 
	"ValveBiped.Bip01_L_Foot", 
	"ValveBiped.Bip01_R_Thigh", 
	"ValveBiped.Bip01_R_Knee", 
	"ValveBiped.Bip01_R_Foot"
};
static const char g_sBoneNames_New[][] =
{
	"bip_head",
	"bip_spine_0",
	"bip_spine_1",
	"bip_spine_2",
	"bip_spine_3",
	"bip_upperArm_L",
	"bip_lowerArm_L",
	"bip_hand_L",
	"bip_upperArm_R",
	"bip_lowerArm_R",
	"bip_hand_R",
	"bip_pelvis",
	"bip_hip_L",
	"bip_knee_L",
	"bip_foot_L",
	"bip_hip_R",
	"bip_knee_R",
	"bip_foot_R"
};

static bool g_bLateLoad;
static bool g_bExtensionActions;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	// ----------------------------------------------------------------------------------------------------
	// GAMEDATA RELATED
	// ----------------------------------------------------------------------------------------------------
	Handle hGameConfig = LoadGameConfigFile("l4d2_improved_bots");
	if (!hGameConfig)SetFailState("Failed to find 'l4d2_improved_bots.txt' game config.");

	CreateAllSDKCalls(hGameConfig);
	CreateAllDetours(hGameConfig);

	delete hGameConfig;

	// ----------------------------------------------------------------------------------------------------
	// EVENT HOOKS
	// ----------------------------------------------------------------------------------------------------
	HookEvent("round_start", 			Event_OnRoundStart);
	HookEvent("round_end", 				Event_OnRoundEnd);

	HookEvent("weapon_fire", 			Event_OnWeaponFire);
	HookEvent("player_death", 			Event_OnPlayerDeath);
	HookEvent("player_use",				Event_OnPlayerUse);
	
	HookEvent("player_incapacitated_start",	Event_OnIncap);
	HookEvent("revive_success",			Event_OnRevive);
	HookEvent("defibrillator_used",		Event_OnRevive);
	
	HookEvent("lunge_pounce", 			Event_OnSurvivorGrabbed);
	HookEvent("tongue_grab", 			Event_OnSurvivorGrabbed);
	HookEvent("jockey_ride", 			Event_OnSurvivorGrabbed);
	HookEvent("charger_carry_start", 	Event_OnSurvivorGrabbed);

	HookEvent("charger_charge_start",	Event_OnChargeStart);
	
	HookEvent("witch_harasser_set", 	Event_OnWitchHaraserSet);
	
	RegAdminCmd("sm_printitemflags",CmdPrintFlag, 2, "For testing"); // ADMFLAG_GENERIC = 2
	RegAdminCmd("sm_haskey",		CmdHasKey, 2, "For testing");
	RegAdminCmd("sm_weptiers",		CmdWepTiers, 2, "For testing");
	RegAdminCmd("sm_testvscript",	CmdVScript, 2, "For testing");
	RegAdminCmd("sm_invdbg",		CmdInvDbg, 2, "Print all players' inventory flags");
	RegAdminCmd("sm_invcount",		CmdInvCount, 2, "Count players with flags of your choice");
	RegAdminCmd("sm_setsubject",	CmdSetTestSubj, 2, "Set player to test against");
	RegAdminCmd("sm_recheck_items",	CmdRecheck, 2, "For testing");
	RegAdminCmd("sm_test_path",		CmdTestPath, 2, "Test pathfinding");
	RegAdminCmd("sm_closest_nav",	CmdGetClosestNav, 2, "Test pathfinding");
	RegAdminCmd("sm_botfakecmd",	CmdBotFakeCmd, 2, "Bots will execute a command of your choice");
	RegAdminCmd("sm_print_trie",	CmdPrintTrie, 2, "Trie harder");
	RegAdminCmd("sm_get_item_info",	CmdGetItemInfo, 2, "Get info about item you aiming at");

	// ----------------------------------------------------------------------------------------------------
	// CONSOLE VARIABLES
	// ----------------------------------------------------------------------------------------------------
	CreateAndHookConVars();
	AutoExecConfig(true, "l4d2_improved_bots");

	// ----------------------------------------------------------------------------------------------------
	// MISC
	// ----------------------------------------------------------------------------------------------------	
	if (g_bLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))continue;
			OnClientJoinServer(i);
		}
	}

	g_bExtensionActions = LibraryExists("actionslib");
	
	g_pProf = CreateProfiler();
	
	if (!g_bInitWeaponToIDMap)
	{
		InitWeaponToIDMap();
		PrintToServer("OnPluginStart: init g_hWeaponToIDMap");
	}
	if (!g_bInitItemFlags)
	{
		InitItemFlagMap();
		PrintToServer("OnPluginStart: init g_hItemFlagMap");
	}
}

void CreateAndHookConVars()
{
	g_hCvar_GameDifficulty 							= FindConVar("z_difficulty");
	g_hCvar_SurvivorLimpHealth 						= FindConVar("survivor_limp_health");
	g_hCvar_TankRockHealth 							= FindConVar("z_tank_throw_health");
	g_hCvar_GasCanUseDuration 						= FindConVar("gas_can_use_duration");
	g_hCvar_ChaseBileRange							= FindConVar("z_notice_it_range");
	g_hCvar_ServerGravity							= FindConVar("sv_gravity");
	g_hCvar_BileCoverDuration_Bot					= FindConVar("vomitjar_duration_infected_bot");
	g_hCvar_BileCoverDuration_PZ					= FindConVar("vomitjar_duration_infected_pz");

	g_hCvar_MaxMeleeSurvivors 						= FindConVar("sb_max_team_melee_weapons");
	g_hCvar_BotsShootThrough 						= FindConVar("sb_allow_shoot_through_survivors");
	g_hCvar_BotsFriendlyFire 						= FindConVar("sb_friendlyfire");
	g_hCvar_BotsDisabled 							= FindConVar("sb_stop");
	g_hCvar_BotsDontShoot 							= FindConVar("sb_dont_shoot");
	g_hCvar_BotsVomitBlindTime 						= FindConVar("sb_vomit_blind_time");

	g_hCvar_MaxAmmo_Pistol							= FindConVar("ammo_pistol_max");
	g_hCvar_MaxAmmo_AssaultRifle					= FindConVar("ammo_assaultrifle_max");
	g_hCvar_MaxAmmo_SMG								= FindConVar("ammo_smg_max");
	g_hCvar_MaxAmmo_M60								= FindConVar("ammo_m60_max");
	g_hCvar_MaxAmmo_Shotgun							= FindConVar("ammo_shotgun_max");
	g_hCvar_MaxAmmo_AutoShotgun						= FindConVar("ammo_autoshotgun_max");
	g_hCvar_MaxAmmo_HuntRifle						= FindConVar("ammo_huntingrifle_max");
	g_hCvar_MaxAmmo_SniperRifle						= FindConVar("ammo_sniperrifle_max");
	g_hCvar_MaxAmmo_PipeBomb						= FindConVar("ammo_pipebomb_max");
	g_hCvar_MaxAmmo_Molotov							= FindConVar("ammo_molotov_max");
	g_hCvar_MaxAmmo_VomitJar						= FindConVar("ammo_vomitjar_max");
	g_hCvar_MaxAmmo_PainPills						= FindConVar("ammo_painpills_max");
	g_hCvar_MaxAmmo_GrenLauncher					= FindConVar("ammo_grenadelauncher_max");
	g_hCvar_MaxAmmo_Adrenaline						= FindConVar("ammo_adrenaline_max");
	g_hCvar_MaxAmmo_Chainsaw						= FindConVar("ammo_chainsaw_max");
	g_hCvar_MaxAmmo_AmmoPack						= FindConVar("ammo_ammo_pack_max");
	g_hCvar_MaxAmmo_Medkit							= FindConVar("ammo_firstaid_max");
	
	g_hCvar_Ammo_Type_Override 						= CreateConVar("ib_ammotype_override", "", "If your server has weapons with modified ammo types/amounts, put them here in a following format: \"weapon_id:ammo_max weapon_id:ammo_max ...\"", FCVAR_NOTIFY);

	g_hCvar_ImprovedMelee_Enabled 					= CreateConVar("ib_melee_enabled", "1", "Enables survivor bots' improved melee behaviour.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ImprovedMelee_MaxCount 					= CreateConVar("ib_melee_max_team", "2", "The total number of melee weapons allowed on the team. <0: Bots never use melee>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_SwitchCount 				= CreateConVar("ib_melee_switch_count", "3", "The nearby infected count required for bot to switch to their melee weapon.", FCVAR_NOTIFY, true, 1.0);
	g_hCvar_ImprovedMelee_SwitchRange 				= CreateConVar("ib_melee_switch_range", "250", "Range at which bot's target should be to switch to melee weapon.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_ApproachRange				= CreateConVar("ib_melee_approach_range", "120", "Range at which bot's target should be to approach it. <0: Disable Approaching>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_AimRange 					= CreateConVar("ib_melee_aim_range", "125", "Range at which bot's target should be to start taking aim at it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_AttackRange 				= CreateConVar("ib_melee_attack_range", "70", "Range at which bot's target should be to start attacking it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_ShoveChance 				= CreateConVar("ib_melee_shove_chance", "4", "Chance for bot to bash target instead of attacking with melee. <0: Disable Bashing>", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_ImprovedMelee_ChainsawLimit 			= CreateConVar("ib_melee_chainsaw_limit", "1", "The total number of chainsaws allowed on the team. <0: Bots never use chainsaw>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_SwitchCount2 				= CreateConVar("ib_melee_chainsaw_switch_count", "6", "The nearby infected count required for bot to switch to chainsaw.", FCVAR_NOTIFY, true, 1.0);

	g_hCvar_TargetSelection_Enabled					= CreateConVar("ib_targeting_enabled", "1", "Enables survivor bots' improved target selection.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TargetSelection_ShootRange				= CreateConVar("ib_targeting_range", "2000", "Range at which target need to be for bots to start firing at it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange2				= CreateConVar("ib_targeting_range_shotgun", "750", "Range at which target need to be for bots to start firing at it with shotgun.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange3				= CreateConVar("ib_targeting_range_sniperrifle", "3000", "Range at which target need to be for bots to start firing at it with sniper rifle.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange4				= CreateConVar("ib_targeting_range_pistol", "1500", "Range at which target need to be for bots to start firing at it with secondary weapon.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_IgnoreDociles			= CreateConVar("ib_targeting_ignoredociles", "1", "If bots shouldn't target common infected that are currently not attacking survivors.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_GrenadeThrow_Enabled 					= CreateConVar("ib_gren_enabled", "1", "Enables survivor bots throwing grenades.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_GrenadeThrow_GrenadeTypes				= CreateConVar("ib_gren_types", "7", "What grenades should survivor bots throw? <1: Pipe-Bomb, 2: Molotov, 4: Bile Bomb. Add numbers together.>", FCVAR_NOTIFY, true, 1.0, true, 7.0);
	g_hCvar_GrenadeThrow_ThrowRange					= CreateConVar("ib_gren_throw_range", "1500", "Range at which target needs to be for bot to throw grenade at it.", FCVAR_NOTIFY);
	g_hCvar_GrenadeThrow_HordeSize 					= CreateConVar("ib_gren_horde_size_multiplier", "5.0", "Infected count required to throw grenade Multiplier (Value * SurvivorCount).", FCVAR_NOTIFY, true, 1.0);
	g_hCvar_GrenadeThrow_NextThrowTime1 			= CreateConVar("ib_gren_next_throw_time_min", "20", "First number to pick to randomize next grenade throw time.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_GrenadeThrow_NextThrowTime2 			= CreateConVar("ib_gren_next_throw_time_max", "30", "Second number to pick to randomize next grenade throw time.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_TankRock_ShootEnabled 					= CreateConVar("ib_shootattankrocks_enabled", "1", "Enables survivor bots shooting tank's thrown rocks.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TankRock_ShootRange 					= CreateConVar("ib_shootattankrocks_range", "1500", "Range at which rock needs to be for bot to start shooting at it.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_AutoShove_Enabled						= CreateConVar("ib_autoshove_enabled", "1", "Makes survivor bots automatically shove every nearby infected. <0: Disabled, 1: All infected, 2: Only if infected is behind them>", FCVAR_NOTIFY, true, 0.0, true, 2.0);

	g_hCvar_HelpPinnedFriend_Enabled				= CreateConVar("ib_help_pinned_enabled", "3", "Makes survivor bots force attack pinned survivor's SI if possible. <0: Disabled, 1: Shoot at attacker, 2: Shove the attacker if close enough. Add numbers together.>", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_HelpPinnedFriend_ShootRange				= CreateConVar("ib_help_pinned_shootrange", "2000", "Range at which bots will start firing at SI.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_HelpPinnedFriend_ShoveRange				= CreateConVar("ib_help_pinned_shoverange", "75", "Range at which bots will start to bash SI.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_DefibRevive_Enabled						= CreateConVar("ib_defib_revive_enabled", "1", "Enable bots reviving dead players with defibrillators if they have one available.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DefibRevive_ScanDist 					= CreateConVar("ib_defib_revive_distance", "2000", "Range at which survivor's dead body should be for bot to consider it reviveable.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_FireBash_Chance1						= CreateConVar("ib_shove_chance_pump", "4", "Chance at which survivor bot may shove after firing a pump-action shotgun. <0: Disabled, 1: Always>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_FireBash_Chance2						= CreateConVar("ib_shove_chance_css", "3", "Chance at which survivor bot may shove after firing a bolt-action sniper rifle. <0: Disabled, 1: Always>", FCVAR_NOTIFY, true, 0.0);
	
	g_hCvar_ItemScavenge_Models						= CreateConVar("ib_grab_models", "0", "If enabled, objects with certain models will be considered as scavengeable items.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ItemScavenge_Items 						= CreateConVar("ib_grab_enabled", "16383", "Enable improved bot item scavenging for specified items. <0: Disable, 1: Pipe Bomb, 2: Molotov, 4: Bile Bomb, 8: Medkit, 16: Defibrillator, 32: UpgradePack, 64: Pain Pills, 128: Adrenaline, 256: Laser Sights, 512: Ammopack, 1024: Ammopile, 2048: Chainsaw, 4096: Secondary Weapons, 8192: Primary Weapons. Add numbers together>", FCVAR_NOTIFY, true, 0.0, true, 16383.0);
	g_hCvar_ItemScavenge_ApproachRange 				= CreateConVar("ib_grab_distance", "300", "Distance at which item should be for bot to move it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_ApproachVisibleRange 		= CreateConVar("ib_grab_visible_distance", "600", "Distance at which a visible item should be for bot to move it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_PickupRange 				= CreateConVar("ib_grab_pickup_distance", "100", "Distance at which item should be for bot to able to pick it up.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_MapSearchRange 			= CreateConVar("ib_grab_mapsearchdistance", "2500", "How close should the item be to the survivor bot to able to count it when searching?", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_NoHumansRangeMultiplier	= CreateConVar("ib_grab_nohumans_rangemultiplier", "1.2", "The bots' scavenge distance is multiplied to this value when there's no human players left in the team.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_BotWeaponPreference_Nick 				= CreateConVar("ib_pref_nick", "1", "Bot Nick's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Rochelle 			= CreateConVar("ib_pref_rochelle", "1", "Bot Rochelle's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Coach 				= CreateConVar("ib_pref_coach", "2", "Bot Coach's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Ellis 				= CreateConVar("ib_pref_ellis", "3", "Bot Ellis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Bill  				= CreateConVar("ib_pref_bill", "1", "Bot Bill's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Zoey 				= CreateConVar("ib_pref_zoey", "3", "Bot Zoey's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Francis 			= CreateConVar("ib_pref_francis", "2", "Bot Francis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Louis 				= CreateConVar("ib_pref_louis", "1", "Bot Louis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_ForceMagnum 		= CreateConVar("ib_pref_magnums_only", "0", "If every survivor bot should only use magnum instead of regular pistol if possible.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_SwapSameTypePrimaries 					= CreateConVar("ib_mix_primaries", "1", "Makes survivor bots change their primary weapon subtype if there's too much of the same one, Ex. change AK-47 to M16 or SPAS-12 to Autoshotgun.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_SwapSameTypeGrenades 					= CreateConVar("ib_mix_grenades", "1", "Makes survivor bots change their grenade type if there's too much of the same one, Ex. Pipe-Bomb to Molotov.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_T3_Refill 								= CreateConVar("ib_t3_refill", "3", "Should bots pick up ammo when carrying a Tier 3 weapon? Keep disabled if your server does not allow that. <0: Disabled, 1: Grenade Launcher, 2: M60, 3: Both>", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_MaxWeaponTier3_M60 						= CreateConVar("ib_t3_limit_m60", "2", "The total number of M60s allowed on the team. <0: Bots never use M60>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_MaxWeaponTier3_GLauncher 				= CreateConVar("ib_t3_limit_gl", "2", "The total number of grenade launchers allowed on the team. <0: Bots never use grenade launcher>", FCVAR_NOTIFY, true, 0.0);
	
	g_hCvar_Vision_FieldOfView 						= CreateConVar("ib_vision_fov", "75.0", "The field of view of survivor bots.", FCVAR_NOTIFY, true, 0.0, true, 180.0);
	g_hCvar_Vision_NoticeTimeScale 					= CreateConVar("ib_vision_noticetimescale", "1.1", "The time required for bots to notice enemy target is multiplied to this value.", FCVAR_NOTIFY, true, 0.0, true, 4.0);
	
	g_hCvar_SpitterAcidEvasion						= CreateConVar("ib_evade_spit", "1", "Enables survivor bots' improved spitter acid evasion", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_AlwaysCarryProp							= CreateConVar("ib_alwayscarryprop", "1", "If enabled, survivor bot will keep holding the prop it currently has unless it's swarmed by a mob, every teammate needs help, or it wants to use an item.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_KeepMovingInCombat						= CreateConVar("ib_keepmovingincombat", "1", "If bots shouldn't stop moving in combat when there's no human players in team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_SwitchOffCSSWeapons						= CreateConVar("ib_avoid_css", "0", "If bots should change their primary weapon to other one if they're using CSS weapons.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ChargerEvasion							= CreateConVar("ib_evade_charge", "1", "Enables survivor bots's charger dodging behavior.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DeployUpgradePacks						= CreateConVar("ib_deployupgradepacks", "1", "If bots should deploy their upgrade pack when available and not in combat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DontSwitchToPistol						= CreateConVar("ib_dontswitchtopistol", "0", "If bots shouldn't switch to their pistol while they have sniper rifle equiped.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TakeCoverFromRocks						= CreateConVar("ib_takecoverfromtankrocks", "1", "If bots should take cover from tank's thrown rocks.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_AvoidTanksWithProp						= CreateConVar("ib_avoidtanksnearpunchableprops", "1", "If bots should avoid and retreat from tanks that are nearby punchable props like cars.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_NoFallDmgOnLadderFail					= CreateConVar("ib_nofalldmgonladderfail", "0", "If enabled, survivor bots won't take fall damage if they were climbing a ladder just before that.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_WitchBehavior_WalkWhenNearby			= CreateConVar("ib_witchbehavior_walkwhennearby", "0", "Survivor bots will start walking near witch if they're this range near her and she's not disturbed. <0: Disabled>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_WitchBehavior_AllowCrowning				= CreateConVar("ib_witchbehavior_allowcrowning", "1", "Allows survivor bots to crown witch on their path if they're holding any shotgun type weapon. <0: Disabled; 1: Only if survivor team doesn't have any human players; 2:Enabled>", FCVAR_NOTIFY, true, 0.0, true, 2.0);

	g_hCvar_NextProcessTime 						= CreateConVar("ib_process_time", "0.2", "Bots' data computing time delay (infected count, nearby friends, etc). Increasing the value might help increasing the game performance, but slow down bots.", FCVAR_NOTIFY, true, 0.033);
	g_hCvar_Debug 									= CreateConVar("ib_debug", "1", "Spam console/chat in hopes of finding a a clue for your problems. Prints WILL LAG on Windows GUI!", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_GameDifficulty.AddChangeHook(OnConVarChanged);
	g_hCvar_SurvivorLimpHealth.AddChangeHook(OnConVarChanged);
	g_hCvar_TankRockHealth.AddChangeHook(OnConVarChanged);
	g_hCvar_GasCanUseDuration.AddChangeHook(OnConVarChanged);
	g_hCvar_ChaseBileRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ServerGravity.AddChangeHook(OnConVarChanged);
	g_hCvar_BileCoverDuration_Bot.AddChangeHook(OnConVarChanged);
	g_hCvar_BileCoverDuration_PZ.AddChangeHook(OnConVarChanged);
	
	g_hCvar_MaxAmmo_Pistol.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_AssaultRifle.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_SMG.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_M60.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Shotgun.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_AutoShotgun.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_HuntRifle.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_SniperRifle.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_PipeBomb.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Molotov.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_VomitJar.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_PainPills.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_GrenLauncher.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Adrenaline.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Chainsaw.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_AmmoPack.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Medkit.AddChangeHook(OnConVarChanged);
	
	g_hCvar_Ammo_Type_Override.AddChangeHook(OnConVarChanged);

	g_hCvar_MaxMeleeSurvivors.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsShootThrough.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsFriendlyFire.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsDisabled.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsDontShoot.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsVomitBlindTime.AddChangeHook(OnConVarChanged);

	g_hCvar_ImprovedMelee_MaxCount.AddChangeHook(OnConVarChanged);

	g_hCvar_ImprovedMelee_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_SwitchCount.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_SwitchRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_ApproachRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_AimRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_AttackRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_ShoveChance.AddChangeHook(OnConVarChanged);
	
	g_hCvar_ImprovedMelee_ChainsawLimit.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_SwitchCount2.AddChangeHook(OnConVarChanged);

	g_hCvar_TargetSelection_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange2.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange3.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange4.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_IgnoreDociles.AddChangeHook(OnConVarChanged);

	g_hCvar_GrenadeThrow_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_GrenadeTypes.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_ThrowRange.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_HordeSize.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_NextThrowTime1.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_NextThrowTime2.AddChangeHook(OnConVarChanged);

	g_hCvar_TankRock_ShootEnabled.AddChangeHook(OnConVarChanged);
	g_hCvar_TankRock_ShootRange.AddChangeHook(OnConVarChanged);

	g_hCvar_AutoShove_Enabled.AddChangeHook(OnConVarChanged);
	
	g_hCvar_HelpPinnedFriend_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_ShootRange.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_ShoveRange.AddChangeHook(OnConVarChanged);

	g_hCvar_DefibRevive_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_DefibRevive_ScanDist.AddChangeHook(OnConVarChanged);
	
	g_hCvar_FireBash_Chance1.AddChangeHook(OnConVarChanged);
	g_hCvar_FireBash_Chance2.AddChangeHook(OnConVarChanged);
	
	g_hCvar_ItemScavenge_Models.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_Items.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_ApproachRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_ApproachVisibleRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_PickupRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_MapSearchRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_NoHumansRangeMultiplier.AddChangeHook(OnConVarChanged);

	g_hCvar_BotWeaponPreference_ForceMagnum.AddChangeHook(OnConVarChanged);
	
	g_hCvar_BotWeaponPreference_Nick.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Louis.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Bill.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Rochelle.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Zoey.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Ellis.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Coach.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Francis.AddChangeHook(OnConVarChanged);
	
	g_hCvar_SwapSameTypePrimaries.AddChangeHook(OnConVarChanged);
	g_hCvar_SwapSameTypeGrenades.AddChangeHook(OnConVarChanged);

	g_hCvar_T3_Refill.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxWeaponTier3_M60.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxWeaponTier3_GLauncher.AddChangeHook(OnConVarChanged);
	
	g_hCvar_Vision_FieldOfView.AddChangeHook(OnConVarChanged);
	g_hCvar_Vision_NoticeTimeScale.AddChangeHook(OnConVarChanged);
	
	g_hCvar_SpitterAcidEvasion.AddChangeHook(OnConVarChanged);
	g_hCvar_AlwaysCarryProp.AddChangeHook(OnConVarChanged);
	g_hCvar_KeepMovingInCombat.AddChangeHook(OnConVarChanged);
	g_hCvar_SwitchOffCSSWeapons.AddChangeHook(OnConVarChanged);
	g_hCvar_ChargerEvasion.AddChangeHook(OnConVarChanged);
	g_hCvar_DeployUpgradePacks.AddChangeHook(OnConVarChanged);
	g_hCvar_DontSwitchToPistol.AddChangeHook(OnConVarChanged);
	g_hCvar_TakeCoverFromRocks.AddChangeHook(OnConVarChanged);
	g_hCvar_AvoidTanksWithProp.AddChangeHook(OnConVarChanged);
	g_hCvar_NoFallDmgOnLadderFail.AddChangeHook(OnConVarChanged);

	g_hCvar_WitchBehavior_WalkWhenNearby.AddChangeHook(OnConVarChanged);
	g_hCvar_WitchBehavior_AllowCrowning.AddChangeHook(OnConVarChanged);
	
	g_hCvar_NextProcessTime.AddChangeHook(OnConVarChanged);
	g_hCvar_Debug.AddChangeHook(OnConVarChanged);
}

public void OnAllPluginsLoaded()
{
	UpdateConVarValues();
}

public void OnConfigsExecuted()
{
	UpdateConVarValues();
}

void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	UpdateConVarValues();
}

void UpdateConVarValues()
{	
	g_hCvar_GameDifficulty.GetString(g_sCvar_GameDifficulty, sizeof(g_sCvar_GameDifficulty));
	g_iCvar_SurvivorLimpHealth 							= g_hCvar_SurvivorLimpHealth.IntValue;
	g_iCvar_TankRockHealth 								= g_hCvar_TankRockHealth.IntValue;
	g_fCvar_GasCanUseDuration 							= g_hCvar_GasCanUseDuration.FloatValue;
	g_fCvar_ChaseBileRange 								= g_hCvar_ChaseBileRange.FloatValue;
	g_fCvar_ServerGravity 								= g_hCvar_ServerGravity.FloatValue;
	g_fCvar_BileCoverDuration_Bot 						= g_hCvar_BileCoverDuration_Bot.FloatValue;
	g_fCvar_BileCoverDuration_PZ 						= g_hCvar_BileCoverDuration_PZ.FloatValue;

	g_iCvar_MaxAmmo_Pistol								= g_hCvar_MaxAmmo_Pistol.IntValue;
	g_iCvar_MaxAmmo_AssaultRifle						= g_hCvar_MaxAmmo_AssaultRifle.IntValue;
	g_iCvar_MaxAmmo_SMG									= g_hCvar_MaxAmmo_SMG.IntValue;
	g_iCvar_MaxAmmo_M60									= g_hCvar_MaxAmmo_M60.IntValue;
	g_iCvar_MaxAmmo_Shotgun								= g_hCvar_MaxAmmo_Shotgun.IntValue;
	g_iCvar_MaxAmmo_AutoShotgun							= g_hCvar_MaxAmmo_AutoShotgun.IntValue;
	g_iCvar_MaxAmmo_HuntRifle							= g_hCvar_MaxAmmo_HuntRifle.IntValue;	
	g_iCvar_MaxAmmo_SniperRifle							= g_hCvar_MaxAmmo_SniperRifle.IntValue;
	g_iCvar_MaxAmmo_PipeBomb							= g_hCvar_MaxAmmo_PipeBomb.IntValue;	
	g_iCvar_MaxAmmo_Molotov								= g_hCvar_MaxAmmo_Molotov.IntValue;
	g_iCvar_MaxAmmo_VomitJar							= g_hCvar_MaxAmmo_VomitJar.IntValue;
	g_iCvar_MaxAmmo_PainPills							= g_hCvar_MaxAmmo_PainPills.IntValue;
	g_iCvar_MaxAmmo_GrenLauncher						= g_hCvar_MaxAmmo_GrenLauncher.IntValue;
	g_iCvar_MaxAmmo_Adrenaline							= g_hCvar_MaxAmmo_Adrenaline.IntValue;
	g_iCvar_MaxAmmo_Chainsaw							= g_hCvar_MaxAmmo_Chainsaw.IntValue;
	g_iCvar_MaxAmmo_AmmoPack							= g_hCvar_MaxAmmo_AmmoPack.IntValue;
	g_iCvar_MaxAmmo_Medkit								= g_hCvar_MaxAmmo_Medkit.IntValue;
	
	char sArgs[32];
	g_hCvar_Ammo_Type_Override.GetString( sArgs, sizeof(sArgs));
	if (strcmp(sArgs, g_sCvar_Ammo_Type_Override))
	{
		//if (g_bCvar_Debug)
		PrintToServer("UpdateConVarValues: InitMaxAmmo");
		strcopy(g_sCvar_Ammo_Type_Override, sizeof(g_sCvar_Ammo_Type_Override), sArgs);
		InitMaxAmmo();
	}

	g_bCvar_BotsShootThrough 							= g_hCvar_BotsShootThrough.BoolValue;
	g_bCvar_BotsFriendlyFire 							= g_hCvar_BotsFriendlyFire.BoolValue;
	g_bCvar_BotsDisabled								= g_hCvar_BotsDisabled.BoolValue;
	g_bCvar_BotsDontShoot								= g_hCvar_BotsDontShoot.BoolValue;
	g_fCvar_BotsVomitBlindTime							= g_hCvar_BotsVomitBlindTime.FloatValue;

	g_hCvar_MaxMeleeSurvivors.IntValue					= g_hCvar_ImprovedMelee_MaxCount.IntValue;
	g_iCvar_MaxMeleeSurvivors 							= g_hCvar_MaxMeleeSurvivors.IntValue;

	g_bCvar_ImprovedMelee_Enabled 						= g_hCvar_ImprovedMelee_Enabled.BoolValue;
	g_iCvar_ImprovedMelee_SwitchCount 					= g_hCvar_ImprovedMelee_SwitchCount.IntValue;
	g_iCvar_ImprovedMelee_ShoveChance 					= g_hCvar_ImprovedMelee_ShoveChance.IntValue;
	g_fCvar_ImprovedMelee_SwitchRange 					= (g_hCvar_ImprovedMelee_SwitchRange.FloatValue*g_hCvar_ImprovedMelee_SwitchRange.FloatValue);
	g_fCvar_ImprovedMelee_ApproachRange 				= (g_hCvar_ImprovedMelee_ApproachRange.FloatValue*g_hCvar_ImprovedMelee_ApproachRange.FloatValue);
	g_fCvar_ImprovedMelee_AimRange_Sqr					= (g_hCvar_ImprovedMelee_AimRange.FloatValue*g_hCvar_ImprovedMelee_AimRange.FloatValue);
	g_fCvar_ImprovedMelee_AttackRange 					= g_hCvar_ImprovedMelee_AttackRange.FloatValue;
	g_fCvar_ImprovedMelee_AttackRange_Sqr 				= (g_hCvar_ImprovedMelee_AttackRange.FloatValue * g_hCvar_ImprovedMelee_AttackRange.FloatValue);
	
	g_iCvar_ImprovedMelee_ChainsawLimit 				= g_hCvar_ImprovedMelee_ChainsawLimit.IntValue;
	g_iCvar_ImprovedMelee_SwitchCount2 					= g_hCvar_ImprovedMelee_SwitchCount2.IntValue;

	g_bCvar_TargetSelection_Enabled						= g_hCvar_TargetSelection_Enabled.BoolValue;
	g_fCvar_TargetSelection_ShootRange					= g_hCvar_TargetSelection_ShootRange.FloatValue;
	g_fCvar_TargetSelection_ShootRange2					= g_hCvar_TargetSelection_ShootRange2.FloatValue;
	g_fCvar_TargetSelection_ShootRange3					= g_hCvar_TargetSelection_ShootRange3.FloatValue;
	g_fCvar_TargetSelection_ShootRange4					= g_hCvar_TargetSelection_ShootRange4.FloatValue;
	g_bCvar_TargetSelection_IgnoreDociles				= g_hCvar_TargetSelection_IgnoreDociles.BoolValue;

	g_bCvar_BotWeaponPreference_ForceMagnum 			= g_hCvar_BotWeaponPreference_ForceMagnum.BoolValue;
	
	g_iCvar_BotWeaponPreference_Nick 					= g_hCvar_BotWeaponPreference_Nick.IntValue;
	g_iCvar_BotWeaponPreference_Louis 					= g_hCvar_BotWeaponPreference_Louis.IntValue;
	g_iCvar_BotWeaponPreference_Bill 					= g_hCvar_BotWeaponPreference_Bill.IntValue;
	g_iCvar_BotWeaponPreference_Rochelle 				= g_hCvar_BotWeaponPreference_Rochelle.IntValue;
	g_iCvar_BotWeaponPreference_Zoey 					= g_hCvar_BotWeaponPreference_Zoey.IntValue;
	g_iCvar_BotWeaponPreference_Ellis 					= g_hCvar_BotWeaponPreference_Ellis.IntValue;
	g_iCvar_BotWeaponPreference_Coach 					= g_hCvar_BotWeaponPreference_Coach.IntValue;
	g_iCvar_BotWeaponPreference_Francis 				= g_hCvar_BotWeaponPreference_Francis.IntValue;

	g_bCvar_GrenadeThrow_Enabled 						= g_hCvar_GrenadeThrow_Enabled.BoolValue;
	g_iCvar_GrenadeThrow_GrenadeTypes 					= g_hCvar_GrenadeThrow_GrenadeTypes.IntValue;
	g_fCvar_GrenadeThrow_ThrowRange 					= g_hCvar_GrenadeThrow_ThrowRange.FloatValue;
	g_fCvar_GrenadeThrow_HordeSize 						= g_hCvar_GrenadeThrow_HordeSize.FloatValue;
	g_fCvar_GrenadeThrow_NextThrowTime1 				= g_hCvar_GrenadeThrow_NextThrowTime1.FloatValue;
	g_fCvar_GrenadeThrow_NextThrowTime2 				= g_hCvar_GrenadeThrow_NextThrowTime2.FloatValue;

	g_bCvar_TankRock_ShootEnabled						= g_hCvar_TankRock_ShootEnabled.BoolValue;
	g_fCvar_TankRock_ShootRange							= (g_hCvar_TankRock_ShootRange.FloatValue*g_hCvar_TankRock_ShootRange.FloatValue);

	g_bCvar_DefibRevive_Enabled 						= g_hCvar_DefibRevive_Enabled.BoolValue;
	g_fCvar_DefibRevive_ScanDist 						= g_hCvar_DefibRevive_ScanDist.FloatValue;

	g_iCvar_FireBash_Chance1 							= g_hCvar_FireBash_Chance1.IntValue;
	g_iCvar_FireBash_Chance2 							= g_hCvar_FireBash_Chance2.IntValue;

	g_iCvar_AutoShove_Enabled 							= g_hCvar_AutoShove_Enabled.BoolValue;
	
	g_iCvar_HelpPinnedFriend_Enabled 					= g_hCvar_HelpPinnedFriend_Enabled.IntValue;
	//g_fCvar_HelpPinnedFriend_ShootRange 				= g_hCvar_HelpPinnedFriend_ShootRange.FloatValue;
	g_fCvar_HelpPinnedFriend_ShootRange_Sqr				= (g_hCvar_HelpPinnedFriend_ShootRange.FloatValue * g_hCvar_HelpPinnedFriend_ShootRange.FloatValue);
	g_fCvar_HelpPinnedFriend_ShoveRange_Sqr 			= (g_hCvar_HelpPinnedFriend_ShoveRange.FloatValue * g_hCvar_HelpPinnedFriend_ShoveRange.FloatValue);
	
	g_iCvar_ItemScavenge_Models 						= g_hCvar_ItemScavenge_Models.IntValue;
	g_iCvar_ItemScavenge_Items 							= g_hCvar_ItemScavenge_Items.IntValue;
	g_fCvar_ItemScavenge_ApproachRange 					= g_hCvar_ItemScavenge_ApproachRange.FloatValue;
	g_fCvar_ItemScavenge_ApproachVisibleRange 			= g_hCvar_ItemScavenge_ApproachVisibleRange.FloatValue;
	g_fCvar_ItemScavenge_PickupRange 					= g_hCvar_ItemScavenge_PickupRange.FloatValue;
	g_fCvar_ItemScavenge_PickupRange_Sqr				= (g_hCvar_ItemScavenge_PickupRange.FloatValue * g_hCvar_ItemScavenge_PickupRange.FloatValue);
	g_fCvar_ItemScavenge_MapSearchRange_Sqr				= (g_hCvar_ItemScavenge_MapSearchRange.FloatValue * g_hCvar_ItemScavenge_MapSearchRange.FloatValue);
	g_fCvar_ItemScavenge_NoHumansRangeMultiplier 		= g_hCvar_ItemScavenge_NoHumansRangeMultiplier.FloatValue;

	g_bCvar_SwapSameTypePrimaries 						= g_hCvar_SwapSameTypePrimaries.BoolValue;
	g_bCvar_SwapSameTypeGrenades 						= g_hCvar_SwapSameTypeGrenades.BoolValue;
	
	g_iCvar_T3_Refill									= g_hCvar_T3_Refill.IntValue;
	g_iCvar_MaxWeaponTier3_M60 							= g_hCvar_MaxWeaponTier3_M60.IntValue;
	g_iCvar_MaxWeaponTier3_GLauncher 					= g_hCvar_MaxWeaponTier3_GLauncher.IntValue;
	
	g_fCvar_Vision_FieldOfView 							= g_hCvar_Vision_FieldOfView.FloatValue;
	g_fCvar_Vision_NoticeTimeScale 						= g_hCvar_Vision_NoticeTimeScale.FloatValue;
	
	g_bCvar_SpitterAcidEvasion							= g_hCvar_SpitterAcidEvasion.BoolValue;
	g_bCvar_AlwaysCarryProp								= g_hCvar_AlwaysCarryProp.BoolValue;
	g_bCvar_SwitchOffCSSWeapons							= g_hCvar_SwitchOffCSSWeapons.BoolValue;
	g_bCvar_ChargerEvasion								= g_hCvar_ChargerEvasion.BoolValue;
	g_bCvar_DeployUpgradePacks							= g_hCvar_DeployUpgradePacks.BoolValue;
	g_bCvar_DontSwitchToPistol							= g_hCvar_DontSwitchToPistol.BoolValue;
	g_bCvar_TakeCoverFromRocks							= g_hCvar_TakeCoverFromRocks.BoolValue;
	g_bCvar_AvoidTanksWithProp							= g_hCvar_AvoidTanksWithProp.BoolValue;
	g_bCvar_NoFallDmgOnLadderFail						= g_hCvar_NoFallDmgOnLadderFail.BoolValue;

	if (g_bMapStarted)
	{
		char sShouldHurryCode[64]; FormatEx(sShouldHurryCode, sizeof(sShouldHurryCode), "DirectorScript.GetDirectorOptions().cm_ShouldHurry <- %i", g_hCvar_KeepMovingInCombat.IntValue);
		L4D2_ExecVScriptCode(sShouldHurryCode);
	}

	g_fCvar_WitchBehavior_WalkWhenNearby 				= g_hCvar_WitchBehavior_WalkWhenNearby.FloatValue;
	g_iCvar_WitchBehavior_AllowCrowning 				= g_hCvar_WitchBehavior_AllowCrowning.IntValue;

	g_fCvar_NextProcessTime 							= g_hCvar_NextProcessTime.FloatValue;
	g_bCvar_Debug 										= g_hCvar_Debug.BoolValue;
}

static Handle g_hCalcAbsolutePosition;

static Handle g_hLookupBone; 
static Handle g_hGetBonePosition; 

static Handle g_hGetMaxClip1;
static Handle g_hFindUseEntity;
static Handle g_hIsInCombat;

static Handle g_hIsReachableNavArea; 
static Handle g_hIsAvailable; 

static Handle g_hMarkNavAreaAsBlocked;
//static Handle g_hSubdivideNavArea;

static Handle g_hSurvivorLegsRetreat;

static int g_iNavArea_Center;
static int g_iNavArea_Parent;
static int g_iNavArea_NWCorner;
static int g_iNavArea_SECorner;
static int g_iNavArea_InvDXCorners;
static int g_iNavArea_InvDYCorners;
static int g_iNavArea_DamagingTickCount;

void CreateAllSDKCalls(Handle hGameData)
{
	if ((g_iNavArea_Center = GameConfGetOffset(hGameData, "CNavArea::m_center")) == -1)
		SetFailState("Failed to get CNavArea::m_center offset.");
	if ((g_iNavArea_Parent = GameConfGetOffset(hGameData, "CNavArea::m_parent")) == -1)
		SetFailState("Failed to get CNavArea::m_parent offset.");
	if ((g_iNavArea_NWCorner = GameConfGetOffset(hGameData, "CNavArea::m_nwCorner")) == -1)
		SetFailState("Failed to get CNavArea::m_nwCorner offset.");
	if ((g_iNavArea_SECorner = GameConfGetOffset(hGameData, "CNavArea::m_seCorner")) == -1)
		SetFailState("Failed to get CNavArea::m_seCorner offset.");
	if ((g_iNavArea_InvDXCorners = GameConfGetOffset(hGameData, "CNavArea::m_invDxCorners")) == -1)
		SetFailState("Failed to get CNavArea::m_invDxCorners offset.");
	if ((g_iNavArea_InvDYCorners = GameConfGetOffset(hGameData, "CNavArea::m_invDyCorners")) == -1)
		SetFailState("Failed to get CNavArea::m_invDyCorners offset.");
	if ((g_iNavArea_DamagingTickCount = GameConfGetOffset(hGameData, "CNavArea::m_damagingTickCount")) == -1)
		SetFailState("Failed to get CNavArea::m_damagingTickCount offset.");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseEntity::CalcAbsolutePosition");
	if ((g_hCalcAbsolutePosition = EndPrepSDKCall()) == null) 
		SetFailState("Failed to create SDKCall for CBaseEntity::CalcAbsolutePosition signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == null) 
		SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == null) 
		SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "CBaseCombatWeapon::GetMaxClip1");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hGetMaxClip1 = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseCombatWeapon::GetMaxClip1 virtual!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SurvivorBot::IsReachable<CNavArea>");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsReachableNavArea = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SurvivorBot::IsReachable<CNavArea> signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SurvivorBot::IsAvailable");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsAvailable = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SurvivorBot::IsAvailable signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::FindUseEntity");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hFindUseEntity = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CTerrorPlayer::FindUseEntity signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::IsInCombat");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsInCombat = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CTerrorPlayer::IsInCombat signature!");	

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CNavArea::MarkAsBlocked");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hMarkNavAreaAsBlocked = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CNavArea::MarkAsBlocked signature!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SurvivorLegsRetreat::SurvivorLegsRetreat");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hSurvivorLegsRetreat = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SurvivorLegsRetreat::SurvivorLegsRetreat signature!");

}

static Handle g_hOnFindUseEntity;
static Handle g_hOnInfernoTouchNavArea;
static Handle g_hOnGetAvoidRange;

void CreateAllDetours(Handle hGameData)
{
	g_hOnFindUseEntity = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_CBaseEntity, ThisPointer_CBaseEntity);
	if (!g_hOnFindUseEntity)SetFailState("Failed to setup detour for CTerrorPlayer::FindUseEntity");
	if (!DHookSetFromConf(g_hOnFindUseEntity, hGameData, SDKConf_Signature, "CTerrorPlayer::FindUseEntity"))
		SetFailState("Failed to load CTerrorPlayer::FindUseEntity signature from gamedata");
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Float);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Float);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Float);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Bool);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Bool);
	if (!DHookEnableDetour(g_hOnFindUseEntity, true, DTR_OnFindUseEntity))
		SetFailState("Failed to detour CTerrorPlayer::FindUseEntity.");

	g_hOnInfernoTouchNavArea = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_CBaseEntity);
	if (!g_hOnInfernoTouchNavArea)SetFailState("Failed to setup detour for CInferno::IsTouching<CNavArea>");
	if (!DHookSetFromConf(g_hOnInfernoTouchNavArea, hGameData, SDKConf_Signature, "CInferno::IsTouching<CNavArea>"))
		SetFailState("Failed to load CInferno::IsTouching<CNavArea> signature from gamedata");
	DHookAddParam(g_hOnInfernoTouchNavArea, HookParamType_Int);
	if (!DHookEnableDetour(g_hOnInfernoTouchNavArea, true, DTR_OnInfernoTouchNavArea))
		SetFailState("Failed to detour CInferno::IsTouching<CNavArea>.");

	g_hOnGetAvoidRange = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Float, ThisPointer_CBaseEntity);
	if (!g_hOnGetAvoidRange)SetFailState("Failed to setup detour for SurvivorBot::GetAvoidRange");
	if (!DHookSetFromConf(g_hOnGetAvoidRange, hGameData, SDKConf_Signature, "SurvivorBot::GetAvoidRange"))
		SetFailState("Failed to load SurvivorBot::GetAvoidRange signature from gamedata");
	DHookAddParam(g_hOnGetAvoidRange, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(g_hOnGetAvoidRange, true, DTR_OnSurvivorBotGetAvoidRange))
		SetFailState("Failed to detour SurvivorBot::GetAvoidRange.");	
}

void Event_OnRoundStart(Event hEvent, const char[] sName, bool bBroadcast)
{
	ResetDataOnRoundChange();
}

void Event_OnRoundEnd(Event hEvent, const char[] sName, bool bBroadcast)
{
	ResetDataOnRoundChange();
}

static float g_fClient_ThinkFunctionDelay[MAXPLAYERS+1];
void ResetDataOnRoundChange()
{
	g_iBotProcessing_ProcessedCount = 0;
	g_fBotProcessing_NextProcessTime = GetGameTime() + g_fCvar_NextProcessTime;
	g_fSurvivorBot_Grenade_NextThrowTime = g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + 5.0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (GetGameTime() > g_fClient_ThinkFunctionDelay[i])g_fClient_ThinkFunctionDelay[i] = GetGameTime() + 5.0;
		if (!IsClientInGame(i))continue;
		ResetClientPluginVariables(i);
	}
}

public void OnClientPutInServer(int iClient)
{
	OnClientJoinServer(iClient);
}

void OnClientJoinServer(int iClient)
{
	SDKHook(iClient, SDKHook_WeaponSwitch, OnSurvivorSwitchWeapon);
	SDKHook(iClient, SDKHook_OnTakeDamage, OnSurvivorTakeDamage);
	g_fClient_ThinkFunctionDelay[iClient] = GetGameTime() + 5.0;
	ResetClientPluginVariables(iClient);
}

public void OnClientDisconnect(int iClient)
{
	SDKUnhook(iClient, SDKHook_WeaponSwitch, OnSurvivorSwitchWeapon);
	SDKUnhook(iClient, SDKHook_OnTakeDamage, OnSurvivorTakeDamage);
	g_fClient_ThinkFunctionDelay[iClient] = GetGameTime() + 5.0;
	ResetClientPluginVariables(iClient);
}

void ResetClientPluginVariables(int iClient)
{	
	g_bBotProcessing_IsProcessed[iClient] = false;

	g_iSurvivorBot_TargetInfected[iClient] = -1;	
	g_iSurvivorBot_WitchTarget[iClient] = -1;	
	g_iSurvivorBot_ThreatInfectedCount[iClient] = 0;
	g_iSurvivorBot_NearbyInfectedCount[iClient] = 0;
	g_iSurvivorBot_NearestInfectedCount[iClient] = 0;
	g_iSurvivorBot_GrenadeInfectedCount[iClient] = 0;
	g_iSurvivorBot_ScavengeItem[iClient] = -1;
	g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
	g_iSurvivorBot_DefibTarget[iClient] = -1;
	g_iSurvivorBot_Grenade_ThrowTarget[iClient] = -1;
	g_iSurvivorBot_MovePos_Priority[iClient] = 0;
	
	g_sSurvivorBot_MovePos_Name[iClient][0] = 0;
	g_fSurvivorBot_MovePos_Tolerance[iClient] = -1.0;

	g_bSurvivorBot_IsWitchHarasser[iClient] = false;
	g_bSurvivorBot_ForceWeaponReload[iClient] = false;
	g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
	g_bSurvivorBot_ForceBash[iClient] = false;
	g_bSurvivorBot_PreventFire[iClient] = false;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = false;

	g_fSurvivorBot_PinnedReactTime[iClient] = GetGameTime();
	g_fSurvivorBot_NextUsePressTime[iClient] = GetGameTime() + 0.33;
	g_fSurvivorBot_NextScavengeItemScanTime[iClient] = GetGameTime() + 1.0;
	g_fSurvivorBot_BlockWeaponReloadTime[iClient] = GetGameTime();
	g_fSurvivorBot_BlockWeaponSwitchTime[iClient] = GetGameTime();
	g_fSurvivorBot_VomitBlindedTime[iClient] = GetGameTime();
	g_fSurvivorBot_TimeSinceLeftLadder[iClient] = GetGameTime();
	g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime();
	g_fSurvivorBot_MeleeAttackTime[iClient] = GetGameTime();
	g_fSurvivorBot_NextMoveCommandTime[iClient] = GetGameTime() + BOT_CMD_MOVE_INTERVAL;
	g_fSurvivorBot_LookPosition_Duration[iClient] = GetGameTime();
	g_fSurvivorBot_NextPressAttackTime[iClient] = GetGameTime();
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime();
	g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime();

	SetVectorToZero(g_fSurvivorBot_Grenade_ThrowPos[iClient]);
	SetVectorToZero(g_fSurvivorBot_Grenade_AimPos[iClient]);
	SetVectorToZero(g_fSurvivorBot_LookPosition[iClient]);
	SetVectorToZero(g_fSurvivorBot_MovePos_Position[iClient]);

	for (int i = 0; i < MAXENTITIES; i++)
	{
		g_iSurvivorBot_VisionMemory_State[iClient][i] = g_iSurvivorBot_VisionMemory_State_FOV[iClient][i] = 0;
		g_fSurvivorBot_VisionMemory_Time[iClient][i] = g_fSurvivorBot_VisionMemory_Time_FOV[iClient][i] = GetGameTime();
	}

	if (!IsValidClient(iClient) || !IsFakeClient(iClient) || GetClientTeam(iClient) != 2)
		return;

	L4D2_CommandABot(iClient, 0, BOT_CMD_RESET);
}

void Event_OnWeaponFire(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iItemFlags/*, iWeaponID*/, iUserID, iClient;
	static char sWeaponName[64]/*, sClientName[128]*/;
	iUserID = hEvent.GetInt("userid");
	//iWeaponID = hEvent.GetInt("weaponid");
	iClient = GetClientOfUserId(iUserID);
	if (!IsFakeClient(iClient))return;
	
	hEvent.GetString("weapon", sWeaponName, sizeof(sWeaponName));
	
	if (!g_bInitItemFlags)
	{
		InitItemFlagMap();
		//if(g_bCvar_Debug)
		//	PrintToServer("Event_OnWeaponFire: g_hItemFlagMap not initialized, doing now");
	}
	g_hItemFlagMap.GetValue(sWeaponName, iItemFlags);
	//if(g_bCvar_Debug)
	//{
	//	GetClientName(iClient, sClientName, sizeof(sClientName));
	//	PrintToServer("OnWeaponFire %s iUserID %d iWeaponID %d %s", sClientName, iUserID, iWeaponID, sWeaponName);
	//}

	if ( GetRandomInt(1, g_iCvar_FireBash_Chance1) == 1 && iItemFlags & FLAG_SHOTGUN && iItemFlags & FLAG_TIER1 )
	{
		g_bSurvivorBot_ForceBash[iClient] = true;
	}
	else if ( GetRandomInt(1, g_iCvar_FireBash_Chance2) == 1 && iItemFlags & FLAG_SNIPER && iItemFlags & FLAG_CSS )
	{
		g_bSurvivorBot_ForceBash[iClient] = true;
	}
}

void Event_OnPlayerDeath(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iVictim = GetClientOfUserId(hEvent.GetInt("userid"));
	int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	int iInfected = hEvent.GetInt("entityid");

	if (g_iSurvivorBot_TargetInfected[iAttacker] == iVictim || g_iSurvivorBot_TargetInfected[iAttacker] == iInfected)
	{
		g_iSurvivorBot_TargetInfected[iAttacker] = -1;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSurvivorBot_VisionMemory_State[i][iVictim] = g_iSurvivorBot_VisionMemory_State_FOV[i][iVictim] = 0;
		g_fSurvivorBot_VisionMemory_Time[i][iVictim] = g_fSurvivorBot_VisionMemory_Time_FOV[i][iVictim] = GetGameTime();
	}

	g_bInfectedBot_IsThrowing[iVictim] = false;
	g_fInfectedBot_CoveredInVomitTime[iVictim] = GetGameTime();
}

void Event_OnIncap(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iUserID, iSecondarySlot, iEntRef, iIndex;
	iUserID = hEvent.GetInt("userid");
	iClient = GetClientOfUserId(iUserID);
	iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	
	//if(g_bCvar_Debug)
	//{
	//	char sClientName[128];
	//	GetClientName(iClient, sClientName, sizeof(sClientName));
	//	PrintToServer("OnIncap: %s's secondary %s is now forbidden item", sClientName, IBWeaponName[g_iWeaponID[iSecondarySlot]]);
	//}
	
	if (iSecondarySlot != -1)
	{
		iEntRef = EntIndexToEntRef(iSecondarySlot);
		iIndex = g_hForbiddenItemList.Push(iEntRef);
		g_hForbiddenItemList.Set(iIndex, iClient, 1);
	}
}

void Event_OnRevive(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iUserID, iOwner, iEntIndex;
	iUserID = hEvent.GetInt("subject");
	iClient = GetClientOfUserId(iUserID);
	
	for (int i = 0; i < g_hForbiddenItemList.Length; i++)
	{
		iEntIndex = EntRefToEntIndex(g_hForbiddenItemList.Get(i));
		iOwner = g_hForbiddenItemList.Get(i, 1);
		if (iEntIndex == INVALID_ENT_REFERENCE || !IsEntityExists(iEntIndex) || iClient == iOwner)
		{
			g_hForbiddenItemList.Erase(i);
			//if(g_bCvar_Debug)
			//{
			//	char sClientName[128];
			//	GetClientName(iClient, sClientName, sizeof(sClientName));
			//	PrintToServer("Releasing %s's %s!", sClientName, IBWeaponName[g_iWeaponID[iEntIndex]]);
			//}
			continue;
		}
	}
}

// Mark entity as used by certain client
void Event_OnPlayerUse(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iEntity;
	iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	iEntity = hEvent.GetInt("targetid");
	
	g_iItem_Used[iEntity] |= (1 << (iClient - 1));
	if (IsFakeClient(iClient) && iEntity == g_iSurvivorBot_ScavengeItem[iClient] && g_iWeaponID[iEntity])
	{
		ClearMoveToPosition(iClient, "ScavengeItem");
		g_iSurvivorBot_ScavengeItem[iClient] = -1;
		g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
	}
}

void Event_OnSurvivorGrabbed(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iVictim = GetClientOfUserId(hEvent.GetInt("victim"));
	if (!IsValidClient(iVictim))return;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || !IsFakeClient(i))continue;
		float fReactTime = GetRandomFloat(0.33, 0.66); if (i == iVictim)fReactTime *= 0.5;
		g_fSurvivorBot_PinnedReactTime[i] = GetGameTime() + fReactTime;
	}
}

void Event_OnChargeStart(Event hEvent, const char[] sName, bool bBroadcast)
{
	if (!g_bCvar_ChargerEvasion)return;

	int iCharger = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!IsValidClient(iCharger))return;

	float fChargerForward[3]; GetClientAbsAngles(iCharger, fChargerForward);
	GetAngleVectors(fChargerForward, fChargerForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fChargerForward, fChargerForward);

	int iMoveArea;
	float fChargeDist, fChargeHitDist;
	float fChargeHitPos[3], fClientRight[3], fMovePos[3];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || !IsFakeClient(i) || !FEntityInViewAngle(iCharger, i, 5.0) || GetClientDistance(i, iCharger, true) <= 36864.0 || !IsVisibleEntity(iCharger, i, MASK_PLAYERSOLID))
			continue;

		MakeVectorFromPoints(g_fClientAbsOrigin[i], g_fClientAbsOrigin[iCharger], fClientRight);
		GetAngleVectors(fClientRight, NULL_VECTOR, fClientRight, NULL_VECTOR);
		NormalizeVector(fClientRight, fClientRight);

		fChargeDist = GetVectorDistance(g_fClientCenteroid[i], g_fClientCenteroid[iCharger]);
		fChargeHitPos[0] = g_fClientCenteroid[iCharger][0] + (fChargerForward[0] * fChargeDist);
		fChargeHitPos[1] = g_fClientCenteroid[iCharger][1] + (fChargerForward[1] * fChargeDist);
		fChargeHitPos[2] = g_fClientCenteroid[iCharger][2] + (fChargerForward[2] * fChargeDist);

		fChargeHitDist = GetVectorDistance(g_fClientCenteroid[i], fChargeHitPos);
		for (int k = 1; k <= 2; k++)
		{
			fMovePos[0] = g_fClientAbsOrigin[i][0] + (fClientRight[0] * ((k == 1 ? 256.0 : -256.0) - fChargeHitDist));
			fMovePos[1] = g_fClientAbsOrigin[i][1] + (fClientRight[1] * ((k == 1 ? 256.0 : -256.0) - fChargeHitDist));
			fMovePos[2] = g_fClientAbsOrigin[i][2] + (fClientRight[2] * ((k == 1 ? 256.0 : -256.0) - fChargeHitDist));

			iMoveArea = L4D_GetNearestNavArea(fMovePos);
			if (iMoveArea)
			{
				LBI_GetClosestPointOnNavArea(iMoveArea, fMovePos, fMovePos);
				if (!FVectorInViewAngle(iCharger, fMovePos, 5.0) && LBI_IsReachableNavArea(i, iMoveArea))
				{
					float fMoveDist = GetClientTravelDistance(i, fMovePos, true);
					if (fMoveDist != -1.0 && fMoveDist <= 147456.0)
					{
						SetMoveToPosition(i, fMovePos, 3, "EvadeCharge");
						break;
					}
				}
			}

			if (k == 2)TakeCoverFromEntity(i, iCharger, 512.0);
		}
	}
}

void Event_OnWitchHaraserSet(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iUserID;
	iUserID = hEvent.GetInt("userid");
	iClient = GetClientOfUserId(iUserID);
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || GetClientTeam(iClient) != 2)return;

	int iWitch = hEvent.GetInt("witchid");

	int iWitchRef;
	for (int i = 0; i < g_hWitchList.Length; i++)
	{
		iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
		if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
		{
			g_hWitchList.Erase(i);
			continue;
		}
		if (iWitchRef == iWitch)
		{
			g_hWitchList.Set(i, iUserID, 1);
			break;
		}
	}
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3])
{
	GetClientEyePosition(iClient, g_fClientEyePos[iClient]);
	g_fClientEyeAng[iClient] = fAngles;
	GetClientAbsOrigin(iClient, g_fClientAbsOrigin[iClient]);
	GetEntityCenteroid(iClient, g_fClientCenteroid[iClient]);
	g_iClientNavArea[iClient] = L4D_GetLastKnownArea(iClient);

	if (!IsClientSurvivor(iClient))
		return Plugin_Continue;

	g_bClient_IsFiringWeapon[iClient] = false;
	g_bClient_IsLookingAtPosition[iClient] = false;
	g_iClientInvFlags[iClient] = 0;

	static int iWpnSlot, iWpnSlots[6];
	
	// instead of comparing strings
	// we represent survivors’ inventory as bit flags
	for (int i = 0; i <= 5; i++)
	{
		iWpnSlot = GetPlayerWeaponSlot(iClient, i);
		if ( iWpnSlot > 0 && iWpnSlot <= MAXENTITIES && IsValidEdict(iWpnSlot) )
		{
			iWpnSlots[i] = iWpnSlot;
			g_iClientInvFlags[iClient] |= g_iItemFlags[iWpnSlot];
			
			if( g_iWeaponID[iWpnSlot] == 1 && (GetEntProp(iWpnSlot, Prop_Send, "m_isDualWielding") != 0 || GetEntProp(iWpnSlot, Prop_Send, "m_hasDualWeapons") != 0) )
				g_iClientInvFlags[iClient] |= FLAG_PISTOL_EXTRA;
		}
		else
			iWpnSlots[i] = -1;
	}
	g_iClientInventory[iClient] = iWpnSlots;

	if (iWpnSlots[0] != -1)
	{
		g_iWeapon_Clip1[iWpnSlots[0]] = GetWeaponClip1(iWpnSlots[0]);
		g_iWeapon_MaxAmmo[iWpnSlots[0]] = GetWeaponMaxAmmo(iWpnSlots[0]);
		g_iWeapon_AmmoLeft[iWpnSlots[0]] = GetClientPrimaryAmmo(iClient);
	}
	if (iWpnSlots[1] != -1)
	{
		g_iWeapon_Clip1[iWpnSlots[1]] = GetWeaponClip1(iWpnSlots[1]);
	}

	if (g_bCvar_BotsDisabled || g_bCutsceneIsPlaying || !g_iClientNavArea[iClient] || GetGameTime() <= g_fClient_ThinkFunctionDelay[iClient] || !IsFakeClient(iClient))
		return Plugin_Continue;

	SurvivorBotThink(iClient, iButtons, iWpnSlots);

	if (GetGameTime() > g_fBotProcessing_NextProcessTime && g_iBotProcessing_ProcessedCount >= GetTeamPlayerCount(2, true, true))
	{
		g_iBotProcessing_ProcessedCount = 0;
		g_fBotProcessing_NextProcessTime = GetGameTime() + g_fCvar_NextProcessTime;
		for (int i = 1; i <= MaxClients; i++)g_bBotProcessing_IsProcessed[i] = false;
	}

	return Plugin_Continue;
}

public void L4D_OnForceSurvivorPositions()
{
	g_bCutsceneIsPlaying = true;
}

public void L4D_OnReleaseSurvivorPositions()
{
	g_bCutsceneIsPlaying = false;
}

int GetClientWeaponInventory(int iClient, int iSlot)
{
	return (g_iClientInventory[iClient][iSlot]);
}

public void L4D_OnCThrowActivate_Post(int iAbility)
{
	int iOwner = GetEntityOwner(iAbility);
	if (IsValidClient(iOwner))g_bInfectedBot_IsThrowing[iOwner] = true;
}

public void L4D_TankRock_OnRelease_Post(int iTank, int iRock, const float fVecPos[3], const float fVecAng[3], const float fVecVel[3], const float fVecRot[3])
{
	if (IsValidClient(iTank))g_bInfectedBot_IsThrowing[iTank] = false;
}

public void L4D2_OnStagger_Post(int iTarget, int iSource)
{
	g_bInfectedBot_IsThrowing[iTarget] = false;
}

stock void VScript_DebugDrawLine(float fStartPos[3], float fEndPos[3], int iColorR = 255, int iColorG = 255, int iColorB = 255, bool bZTest = false, float fDrawTime = 1.0)
{
	static char sScriptCode[256]; FormatEx(sScriptCode, sizeof(sScriptCode), "DebugDrawLine(Vector(%f, %f, %f), Vector(%f, %f, %f), %i, %i, %i, %s, %f)",
		fStartPos[0], fStartPos[1], fStartPos[2], fEndPos[0], fEndPos[1], fEndPos[2], iColorR, iColorG, iColorB, (bZTest ? "true" : "false"), fDrawTime);
	L4D2_ExecVScriptCode(sScriptCode);
}

void SurvivorBotThink(int iClient, int &iButtons, int iWpnSlots[6])
{
	g_iSurvivorBot_DefibTarget[iClient] = -1;
	g_bSurvivorBot_PreventFire[iClient] = false;

	int iCurWeapon = L4D_GetPlayerCurrentWeapon(iClient);

	static int iTeamLeader, iGameDifficulty, iDefibTarget, iTeamCount, iAlivePlayers, iTankRock, iTankTarget, iWitchHarasser, iTankProp;
	static bool bFriendIsNearBoomer, bFriendIsNearThrowArea, bTeamHasHumanPlayer; 
	if (!g_bBotProcessing_IsProcessed[iClient] && GetGameTime() > g_fBotProcessing_NextProcessTime)
	{
		g_iSurvivorBot_NearbyFriends[iClient] = 0;
		g_iSurvivorBot_TargetInfected[iClient] = GetClosestInfected(iClient, 4000.0);
		g_iSurvivorBot_ThreatInfectedCount[iClient] = GetInfectedCount(iClient, 125.0);
		g_iSurvivorBot_NearestInfectedCount[iClient] = GetInfectedCount(iClient, 300.0);
		g_iSurvivorBot_NearbyInfectedCount[iClient] = GetInfectedCount(iClient, 500.0);
		if (g_bCvar_GrenadeThrow_Enabled && iWpnSlots[2] != -1)
		{
			g_iSurvivorBot_GrenadeInfectedCount[iClient] = GetInfectedCount(iClient, g_fCvar_GrenadeThrow_ThrowRange, CalculateGrenadeThrowInfectedCount(), _, false);
		}

		iTeamLeader = iClient;
		iGameDifficulty = GetCurrentGameDifficulty();
		iTeamCount = GetTeamPlayerCount(2);
		iAlivePlayers = 1;
		
		iTankTarget = 0;
		g_iSurvivorBot_PinnedFriend[iClient] = 0;
		g_iSurvivorBot_IncapacitatedFriend[iClient] = 0;

		bFriendIsNearThrowArea = false;
		bFriendIsNearBoomer = false;
		bTeamHasHumanPlayer = false;

		int iTeam;
		L4D2ZombieClassType iClientClass;
		float fCurDist, fCurDist2;
		float fLastDist = -1.0;
		float fLastDist2 = -1.0;
		float fLastDist3 = -1.0;
		float fLastDist4 = -1.0;
		bool bUseFlowDist = ShouldUseFlowDistance();

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			fCurDist = GetClientDistance(iClient, i, true);
			iTeam = GetClientTeam(i);

			if (iTeam == 2)
			{
				if (!bTeamHasHumanPlayer || !IsFakeClient(i))
				{
					fCurDist2 = ((bUseFlowDist && !bTeamHasHumanPlayer) ? L4D2Direct_GetFlowDistance(i) : fCurDist);
					if (fLastDist4 == -1.0 || bUseFlowDist && !bTeamHasHumanPlayer && fCurDist2 > fLastDist4 || fCurDist2 < fLastDist4)
					{
						iTeamLeader = i;
						if (g_bCvar_Debug && g_iTestSubject == iClient)
							g_iTeamLeader = i;
						fLastDist4 = fCurDist2;
						if (!bTeamHasHumanPlayer)bTeamHasHumanPlayer = (!IsFakeClient(i));
					}
				}

				if (i == iClient)
					continue;

				iAlivePlayers++;

				if ((fLastDist == -1.0 || fCurDist < fLastDist) && L4D_IsPlayerPinned(i))
				{
					g_iSurvivorBot_PinnedFriend[iClient] = i;
					fLastDist = fCurDist;
				}
				
				if ((fLastDist2 == -1.0 || fCurDist < fLastDist2) && L4D_IsPlayerIncapacitated(i))
				{
					g_iSurvivorBot_IncapacitatedFriend[iClient] = i;
					fLastDist2 = fCurDist;
				}

				if (!bFriendIsNearBoomer)
				{
					for (int j = 1; j <= MaxClients; j++)
					{
						bFriendIsNearBoomer = (j != iClient && j != i && IsClientInGame(j) && GetClientTeam(j) == 3 && IsPlayerAlive(j) && !L4D_IsPlayerGhost(j) && 
							GetClientDistance(i, j, true) <= BOT_BOOMER_AVOID_RADIUS_SQR && L4D2_GetPlayerZombieClass(j) == L4D2ZombieClass_Boomer && IsVisibleEntity(j, i, MASK_VISIBLE_AND_NPCS)
						);
						if (bFriendIsNearBoomer)break;
					}
				}

				if (fCurDist <= 262144.0 && !L4D_IsPlayerIncapacitated(i) && !L4D_IsPlayerPinned(i))
					g_iSurvivorBot_NearbyFriends[iClient] += 1;
				
				if (!bFriendIsNearThrowArea)
					bFriendIsNearThrowArea = (GetVectorDistance(g_fClientAbsOrigin[i], g_fSurvivorBot_Grenade_ThrowPos[iClient], true) <= BOT_GRENADE_CHECK_RADIUS_SQR && IsEntityExists(g_iSurvivorBot_Grenade_ThrowTarget[iClient]) && SurvivorHasGrenade(iClient) == 2);
			}
			else if (iTeam == 3 && !L4D_IsPlayerGhost(i))
			{
				iClientClass = L4D2_GetPlayerZombieClass(i);
				if ((fLastDist3 == -1.0 || fCurDist < fLastDist3) && iClientClass == L4D2ZombieClass_Tank && !L4D_IsPlayerIncapacitated(i) && (fCurDist <= 1048576.0 || fCurDist <= 16777216.0 && IsVisibleEntity(iClient, i)))
				{
					iTankTarget = i;
					fLastDist3 = fCurDist;
				}
			}
		}

		iDefibTarget = 0;
		if (g_bCvar_DefibRevive_Enabled)
		{			
			fLastDist = -1.0;
			int iSurvivor = INVALID_ENT_REFERENCE;
			while ((iSurvivor = FindEntityByClassname(iSurvivor, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iClient, iSurvivor, true);
				if (fLastDist == -1.0 || fCurDist < fLastDist)
				{
					iDefibTarget = iSurvivor;				
					fLastDist = fCurDist;
				}
			}
		}

		iTankProp = -1;
		iTankRock = -1;
		if (iTankTarget != 0)
		{
			fLastDist = -1.0;
			int iPropRock = INVALID_ENT_REFERENCE;
			while ((iPropRock = FindEntityByClassname(iPropRock, "tank_rock")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iClient, iPropRock, true);
				if (fLastDist != -1.0 && fCurDist >= fLastDist || !IsVisibleEntity(iClient, iPropRock))
					continue;

				iTankRock = iPropRock;
				fLastDist = fCurDist;
			}

			fLastDist = -1.0;
			iPropRock = INVALID_ENT_REFERENCE;
			while ((iPropRock = FindEntityByClassname(iPropRock, "prop_car_alarm")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iTankTarget, iPropRock, true);
				if (fCurDist > 250000.0 || fLastDist != -1.0 && fCurDist >= fLastDist || !IsVisibleEntity(iTankTarget, iPropRock) || !IsVisibleEntity(iClient, iPropRock))
					continue;

				iTankProp = iPropRock;
				fLastDist = fCurDist;
			}
			iPropRock = INVALID_ENT_REFERENCE;
			while ((iPropRock = FindEntityByClassname(iPropRock, "prop_physics")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iTankTarget, iPropRock, true);
				if (fCurDist > 250000.0 || fLastDist != -1.0 && fCurDist >= fLastDist || !GetEntProp(iPropRock, Prop_Send, "m_hasTankGlow") || !IsVisibleEntity(iTankTarget, iPropRock) || !IsVisibleEntity(iClient, iPropRock))
					continue;

				iTankProp = iPropRock;
				fLastDist = fCurDist;
			}
		}

		g_iSurvivorBot_WitchTarget[iClient] = -1;

		iWitchHarasser = 0;
		fLastDist = -1.0;
		int iWitchRef, iHarasserRef;
		for (int i = 0; i < g_hWitchList.Length; i++)
		{
			iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
			if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
			{
				g_hWitchList.Erase(i);
				continue;
			}
			
			iHarasserRef = g_hWitchList.Get(i, 1);
			if (iHarasserRef != -1)
				iHarasserRef = GetClientOfUserId(iHarasserRef);
			if (iWitchHarasser && !iHarasserRef) continue;

			fCurDist = GetEntityDistance(iClient, iWitchRef, true);
			if (fLastDist != -1.0 && fCurDist >= fLastDist) continue;

			g_iSurvivorBot_WitchTarget[iClient] = iWitchRef;
			iWitchHarasser = iHarasserRef; fLastDist = fCurDist;
		}
		g_bSurvivorBot_IsWitchHarasser[iClient] = (iWitchHarasser == iClient);

		g_iBotProcessing_ProcessedCount++;
		g_bBotProcessing_IsProcessed[iClient] = true;
	}

	if (L4D_IsPlayerHangingFromLedge(iClient))
		return;

	if (GetEntityMoveType(iClient) == MOVETYPE_LADDER)
	{
		g_fSurvivorBot_TimeSinceLeftLadder[iClient] = GetGameTime() + 2.0;
		return;
	}

	if (IsValidVector(g_fSurvivorBot_LookPosition[iClient]))
	{ 
		if (GetGameTime() < g_fSurvivorBot_LookPosition_Duration[iClient])
		{
			SnapViewToPosition(iClient, g_fSurvivorBot_LookPosition[iClient]);
		}
		else
		{
			SetVectorToZero(g_fSurvivorBot_LookPosition[iClient]);
		}
	}

	if (iCurWeapon != -1)
	{
		if (iCurWeapon == iWpnSlots[0] && GetSurvivorBotWeaponPreference(iClient) == L4D_WEAPON_PREFERENCE_SECONDARY)
		{
			SwitchWeaponSlot(iClient, 1);
		}

		if (g_bSurvivorBot_ForceWeaponReload[iClient])
		{
			iButtons |= IN_RELOAD;
			g_bSurvivorBot_ForceWeaponReload[iClient] = false;
		}
		else if (GetGameTime() <= g_fSurvivorBot_BlockWeaponReloadTime[iClient])
		{
			iButtons &= ~IN_RELOAD;
		}

		if (!SurvivorBot_CanFreelyFireWeapon(iClient))
		{
			g_bSurvivorBot_PreventFire[iClient] = true;
			iButtons &= ~IN_ATTACK;
		}

		if (g_bSurvivorBot_ForceBash[iClient])
		{
			g_bSurvivorBot_ForceBash[iClient] = false;
			iButtons |= IN_ATTACK2;
		}
		
		// if we're not occupied and our primary is loaded, switch to pistol (to reload)
		if (iCurWeapon == iWpnSlots[0] && !IsWeaponReloading(iCurWeapon, false) && GetGameTime() > GetWeaponNextFireTime(iCurWeapon)
			&& LBI_IsSurvivorBotAvailable(iClient) && !LBI_IsSurvivorInCombat(iClient) && ( g_iClientInvFlags[iClient] & FLAG_M60 || GetWeaponClip1(iCurWeapon) == GetWeaponClipSize(iCurWeapon) )
			&& g_iClientInvFlags[iClient] & (FLAG_PISTOL | FLAG_PISTOL_EXTRA) && GetWeaponClip1(iWpnSlots[1]) != GetWeaponClipSize(iWpnSlots[1]))
		{
			g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
			SwitchWeaponSlot(iClient, 1);
		}
	}

	int iPinnedFriend = g_iSurvivorBot_PinnedFriend[iClient];
	if (IsValidVector(g_fSurvivorBot_MovePos_Position[iClient]))
	{
		float fMovePos[3]; fMovePos = g_fSurvivorBot_MovePos_Position[iClient];
		float fMoveDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true);						
		float fMoveTolerance = g_fSurvivorBot_MovePos_Tolerance[iClient];
		float fMoveDuration = g_fSurvivorBot_MovePos_Duration[iClient];

		if (GetGameTime() > fMoveDuration || fMoveTolerance >= 0.0 && fMoveDist <= (fMoveTolerance*fMoveTolerance) || 
			!g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] && LBI_IsDamagingPosition(fMovePos) || !LBI_IsReachablePosition(iClient, fMovePos, false) || 
			IsValidClient(iPinnedFriend) && L4D_GetPinnedInfected(iPinnedFriend) != 0 && L4D2_GetPlayerZombieClass(L4D_GetPinnedInfected(iPinnedFriend)) != L4D2ZombieClass_Smoker
		)
		{
			ClearMoveToPosition(iClient);
		}
		else if (GetGameTime() > g_fSurvivorBot_NextMoveCommandTime[iClient])
		{	
			L4D2_CommandABot(iClient, 0, BOT_CMD_MOVE, fMovePos);
			g_fSurvivorBot_NextMoveCommandTime[iClient] = GetGameTime() + BOT_CMD_MOVE_INTERVAL;
		}
	}

	int iInfectedTarget = g_iSurvivorBot_TargetInfected[iClient];
	if (GetGameTime() > g_fSurvivorBot_PinnedReactTime[iClient] && IsValidClient(iPinnedFriend))
	{
		int iAttacker = L4D_GetPinnedInfected(iPinnedFriend);
		if (IsValidClient(iAttacker))
		{
			float fAttackerAimPos[3]; GetTargetAimPart(iClient, iAttacker, fAttackerAimPos);			
			bool bAttackerVisible = HasVisualContactWithEntity(iClient, iAttacker, false, fAttackerAimPos);

			float fFriendDist = GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iPinnedFriend], true);
			bool bCanShoot = (iCurWeapon != -1 && g_iCvar_HelpPinnedFriend_Enabled & (1 << 0) != 0 && fFriendDist <= g_fCvar_HelpPinnedFriend_ShootRange_Sqr
				&& (iCurWeapon != iWpnSlots[1] || !SurvivorHasMeleeWeapon(iClient) || GetClientDistance(iClient, iAttacker, true) <= g_fCvar_ImprovedMelee_AttackRange_Sqr)
				&& SurvivorBot_AbleToShootWeapon(iClient) && CheckIfCanRescueImmobilizedFriend(iClient));

			int iCanShove;
			if (g_iCvar_HelpPinnedFriend_Enabled & (1 << 1) != 0)
			{
				iCanShove = (fFriendDist <= g_fCvar_HelpPinnedFriend_ShoveRange_Sqr ? 1 : (GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iAttacker], true) <= g_fCvar_HelpPinnedFriend_ShoveRange_Sqr ? 2 : 0));
			}

			L4D2ZombieClassType iZombieClass = L4D2_GetPlayerZombieClass(iAttacker);
			if (iZombieClass != L4D2ZombieClass_Smoker)
			{
				if (iWpnSlots[0] != -1 && g_iWeapon_AmmoLeft[iWpnSlots[0]] > 0 && g_iWeapon_Clip1[iWpnSlots[0]] > 0 && iCurWeapon == iWpnSlots[1] && SurvivorHasMeleeWeapon(iClient) && fFriendDist > g_fCvar_ImprovedMelee_AimRange_Sqr)
				{
					g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
					SwitchWeaponSlot(iClient, 0);
				}
				else
				{
					if (bCanShoot && fFriendDist <= 262144.0 && iCurWeapon == iWpnSlots[0] && IsWeaponReloading(iCurWeapon) && GetWeaponClip1(iWpnSlots[1]) > 0 && !SurvivorHasShotgun(iClient) && !SurvivorHasSniperRifle(iClient) && !SurvivorHasMeleeWeapon(iClient))
					{
						g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
						SwitchWeaponSlot(iClient, 1);
					}
				}

				if (iCanShove != 0 && iZombieClass != L4D2ZombieClass_Charger && !L4D_IsPlayerIncapacitated(iClient))
				{
					SnapViewToPosition(iClient, (iCanShove == 1 ? g_fClientCenteroid[iPinnedFriend] : g_fClientCenteroid[iAttacker]));
					iButtons |= IN_ATTACK2;
				}
				else if (bCanShoot && bAttackerVisible)
				{
					SnapViewToPosition(iClient, fAttackerAimPos);
					PressAttackButton(iClient, iButtons); // help pinned
				}
			}
			else
			{
				if (!L4D_IsPlayerIncapacitated(iClient))
				{
					if (iCanShove != 0)
					{
						SnapViewToPosition(iClient, (iCanShove == 1 ? g_fClientCenteroid[iPinnedFriend] : g_fClientCenteroid[iAttacker]));
						iButtons |= IN_ATTACK2;
					}
				}

				if (bCanShoot)
				{
					if (bAttackerVisible)
					{
						SnapViewToPosition(iClient, fAttackerAimPos);
						PressAttackButton(iClient, iButtons); // help pinned
					}
					else 
					{
						float fTipPos[3]; GetEntPropVector(L4D_GetPlayerCustomAbility(iAttacker), Prop_Send, "m_tipPosition", fTipPos);
						if (!IsValidVector(fTipPos))fTipPos = g_fClientEyePos[iPinnedFriend];	

						if (IsVisibleVector(iClient, fTipPos))
						{
							float fMidPos[3];
							fMidPos[0] = ((g_fClientEyePos[iAttacker][0] + fTipPos[0]) / 2.0);
							fMidPos[1] = ((g_fClientEyePos[iAttacker][1] + fTipPos[1]) / 2.0);
							fMidPos[2] = ((g_fClientEyePos[iAttacker][2] + fTipPos[2]) / 2.0);

							SnapViewToPosition(iClient, (IsVisibleVector(iClient, fMidPos) ? fMidPos : fTipPos));
							PressAttackButton(iClient, iButtons); // help pinned
						}
					}
				}
			}
		}
	}

	if (IsValidClient(iTankTarget))
	{
		int iVictim = g_iInfectedBot_CurrentVictim[iTankTarget];
		float fTankDist = GetClientDistance(iClient, iTankTarget, true);
		float fHeightDist = (fTankDist + (g_fClientAbsOrigin[iClient][2] - g_fClientAbsOrigin[iTankTarget][2]));
		if (fHeightDist <= 1638400.0 && (g_bCvar_AvoidTanksWithProp && IsEntityExists(iTankProp) || g_bCvar_TakeCoverFromRocks && g_bInfectedBot_IsThrowing[iTankTarget]) && (iVictim == iClient || GetClientDistance(iClient, iVictim, true) <= 65536.0) && IsVisibleEntity(iClient, iTankTarget, MASK_SHOT_HULL))
		{
			if (strcmp(g_sSurvivorBot_MovePos_Name[iClient], "TakeCover") != 0)
			{
				TakeCoverFromEntity(iClient, (IsEntityExists(iTankProp) ? iTankProp : iTankTarget), 768.0);
			}
		}
		else
		{
			bool bTankVisible = IsVisibleEntity(iClient, iTankTarget, MASK_SHOT_HULL);
			if (!g_bInfectedBot_IsThrowing[iTankTarget] || !bTankVisible)
			{
				ClearMoveToPosition(iClient, "TakeCover");	
			}
			if (fTankDist <= 147456.0 || fTankDist <= 589824.0 && bTankVisible)
			{
				L4D2_CommandABot(iClient, iTankTarget, BOT_CMD_RETREAT);
			}
		}

		if (g_bCvar_TankRock_ShootEnabled && g_iCvar_TankRockHealth > 0 && IsEntityExists(iTankRock))
		{
			float fRockPos[3]; GetEntityCenteroid(iTankRock, fRockPos);

			if (GetVectorDistance(g_fClientEyePos[iClient], fRockPos, true) <= g_fCvar_TankRock_ShootRange && SurvivorBot_AbleToShootWeapon(iClient) && 
				(iCurWeapon != iWpnSlots[1] || !SurvivorHasMeleeWeapon(iClient)) && !IsSurvivorBusy(iClient) && HasVisualContactWithEntity(iClient, iTankRock, false, fRockPos))
			{
				SnapViewToPosition(iClient, fRockPos);
				PressAttackButton(iClient, iButtons); // shoot tank rock
			}
		}
	}

	int iWitchTarget = g_iSurvivorBot_WitchTarget[iClient];
	if (IsEntityExists(iWitchTarget) && GetEntityHealth(iWitchTarget) > 0)
	{
		float fWitchOrigin[3]; GetEntityAbsOrigin(iWitchTarget, fWitchOrigin);
		float fWitchDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fWitchOrigin, true);

		float fFirePos[3]; 
		GetTargetAimPart(iClient, iWitchTarget, fFirePos);

		int iHasShotgun = SurvivorHasShotgun(iClient);

		if (iWitchHarasser == -1 || IsValidClient(iWitchHarasser))
		{
			if ((iCurWeapon == iWpnSlots[0] || iCurWeapon == iWpnSlots[1]) && SurvivorBot_AbleToShootWeapon(iClient))
			{
				float fShootRange = g_fCvar_TargetSelection_ShootRange;
				if (iCurWeapon == iWpnSlots[1])
				{
					if (!SurvivorHasMeleeWeapon(iClient))fShootRange = g_fCvar_TargetSelection_ShootRange4;
					else fShootRange = g_fCvar_ImprovedMelee_AttackRange;
				}
				else if (iHasShotgun)fShootRange = g_fCvar_TargetSelection_ShootRange2;
				else if (SurvivorHasSniperRifle(iClient))fShootRange = g_fCvar_TargetSelection_ShootRange3;

				bool bWitchVisible = HasVisualContactWithEntity(iClient, iWitchTarget, false);
				if (fWitchDist <= (fShootRange*fShootRange) && bWitchVisible)
				{
					SnapViewToPosition(iClient, fFirePos);				
					bool bFired = PressAttackButton(iClient, iButtons); // shoot witch
					if (iHasShotgun == 1 && bFired)g_bSurvivorBot_ForceBash[iClient] = true;

					if (fShootRange != g_fCvar_TargetSelection_ShootRange2 && fShootRange != g_fCvar_ImprovedMelee_AttackRange)
					{
						ClearMoveToPosition(iClient, "GoToWitch");
					}
				}
				else if (iWitchHarasser != iClient && fWitchDist <= 4000000.0)
				{
					SetMoveToPosition(iClient, fWitchOrigin, 3, "GoToWitch", 0.0, (( bWitchVisible && (iWitchHarasser == -1 || !L4D_IsPlayerIncapacitated(iWitchHarasser)) ) ? (fShootRange > 192.0 ? 192.0 : fShootRange) : 0.0), true);
				}
			}

			if (iWitchHarasser == iClient && fWitchDist <= 1048576.0 && !L4D_IsPlayerIncapacitated(iClient))
			{
				L4D2_CommandABot(iClient, iWitchTarget, BOT_CMD_RETREAT);
			}
		}
		else 
		{
			float fWalkDist = g_fCvar_WitchBehavior_WalkWhenNearby;
			if (fWalkDist != 0.0 && fWitchDist <= (fWalkDist*fWalkDist) && (GetEntPropFloat(iWitchTarget, Prop_Send, "m_rage") <= 0.2 && GetEntPropFloat(iWitchTarget, Prop_Send, "m_wanderrage") <= 0.66) && !LBI_IsSurvivorInCombat(iClient))
			{
				iButtons |= IN_SPEED;
			}

			int iCrowning = g_iCvar_WitchBehavior_AllowCrowning;
			if ((iCrowning == 2 || iCrowning == 1 && !bTeamHasHumanPlayer) && iCurWeapon == iWpnSlots[0] && fWitchDist <= 1048576.0 && !L4D_IsPlayerOnThirdStrike(iClient) && (!IsValidClient(iTeamLeader) || fWitchDist <= 262144.0) && !IsWeaponReloading(iCurWeapon, false) && iHasShotgun && IsVisibleEntity(iClient, iWitchTarget))
			{
				if (fWitchDist <= 4096.0)
				{
					ClearMoveToPosition(iClient, "GoToWitch");
					SnapViewToPosition(iClient, fFirePos);
					bool bFired = PressAttackButton(iClient, iButtons); // shoot witch
					if (iHasShotgun == 1 && bFired)g_bSurvivorBot_ForceBash[iClient] = true;
				}
				else if (LBI_IsSurvivorBotAvailable(iClient))
				{
					bool bApproachWitch = !ShouldUseFlowDistance();
					if (!bApproachWitch)
					{
						Address pArea = L4D2Direct_GetTerrorNavArea(fWitchOrigin);
						bApproachWitch = (pArea != Address_Null && L4D2Direct_GetTerrorNavAreaFlow(pArea) >= L4D2Direct_GetFlowDistance(iClient));
					}
					if (bApproachWitch)SetMoveToPosition(iClient, fWitchOrigin, 2, "GoToWitch", 0.0, 0.0, true);

					if (fWitchDist <= 16384.0)
					{
						SnapViewToPosition(iClient, fFirePos);
					}
				}
			}
		}
	}

	float fInfectedDist = -1.0;
	if (IsEntityExists(iInfectedTarget))
	{
		float fInfectedPos[3]; GetEntityCenteroid(iInfectedTarget, fInfectedPos);
		float fInfectedOrigin[3]; GetEntityAbsOrigin(iInfectedTarget, fInfectedOrigin);
		fInfectedDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fInfectedOrigin, true);
		
		L4D2ZombieClassType iInfectedClass = L4D2ZombieClass_NotInfected;
		if (IsValidClient(iInfectedTarget))iInfectedClass = L4D2_GetPlayerZombieClass(iInfectedTarget);

		if (g_bCvar_ImprovedMelee_Enabled)
		{
			int iMeleeType = SurvivorHasMeleeWeapon(iClient);
			if (iMeleeType != 0)
			{
				if (iCurWeapon == iWpnSlots[1])
				{
					float fAimPosition[3]; GetClosestToEyePosEntityBonePos(iClient, iInfectedTarget, fAimPosition);
					float fMeleeDistance = GetVectorDistance(g_fClientEyePos[iClient], fAimPosition, true);
					
					if (fMeleeDistance <= g_fCvar_ImprovedMelee_AimRange_Sqr)
					{
						g_fSurvivorBot_BlockWeaponSwitchTime[iClient] = (GetGameTime() + (iMeleeType == 2 ? 3.0 : 1.0));
						SnapViewToPosition(iClient, fAimPosition);
					}

					if (!g_bSurvivorBot_PreventFire[iClient] && fMeleeDistance <= g_fCvar_ImprovedMelee_AttackRange_Sqr && (iGameDifficulty == 4 || (!IsSurvivorBusy(iClient)
						|| g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, (float(g_iSurvivorBot_NearbyFriends[iClient]) / (iTeamCount - 1))))))
					{
						float fAttackTime = (iMeleeType == 2 ? GetRandomFloat(0.33, 0.8) : GetRandomFloat(0.1, 0.33));
						g_fSurvivorBot_MeleeAttackTime[iClient] = (GetGameTime() + fAttackTime);
					}

					if (GetGameTime() < g_fSurvivorBot_MeleeAttackTime[iClient])
					{
						bool bShouldShove = (iInfectedClass != L4D2ZombieClass_Charger && GetRandomInt(1, (iMeleeType == 2 ? 200 : g_iCvar_ImprovedMelee_ShoveChance)) == 1
							&& (!g_bExtensionActions || iInfectedClass != L4D2ZombieClass_NotInfected || !IsCommonInfectedStumbled(iInfectedTarget)));
						iButtons |= ( bShouldShove ? IN_ATTACK2 : IN_ATTACK );
					}

					bool bStopApproaching = true;
					if (g_fCvar_ImprovedMelee_ApproachRange > 0.0 && GetGameTime() > g_fSurvivorBot_MeleeApproachTime[iClient] && !IsSurvivorBotBlindedByVomit(iClient) && !IsValidClient(iPinnedFriend)
						&& (!IsValidClient(iTankTarget) || GetClientDistance(iClient, iTankTarget, true) > 1048576.0) && LBI_IsReachableEntity(iClient, iInfectedTarget) && !IsFinaleEscapeVehicleArrived()
						&& (iInfectedClass == L4D2ZombieClass_NotInfected || (L4D_IsPlayerStaggering(iInfectedTarget) || L4D_GetPinnedSurvivor(iInfectedTarget) != 0) && !L4D_IsAnySurvivorInCheckpoint()))
					{
						Address pArea;
						float fMovePos[3]; GetEntityAbsOrigin(iInfectedTarget, fMovePos);
						if (!ShouldUseFlowDistance() || (pArea = L4D2Direct_GetTerrorNavArea(fMovePos)) == Address_Null || L4D2Direct_GetTerrorNavAreaFlow(pArea) >= (L4D2Direct_GetFlowDistance(iClient) - SquareRoot(g_fCvar_ImprovedMelee_ApproachRange*0.5)))
						{
							float fLeaderDist = ((iInfectedClass == L4D2ZombieClass_NotInfected && iTeamLeader != iClient && IsValidClient(iTeamLeader)) ? GetClientTravelDistance(iTeamLeader, fMovePos, true) : -2.0);
							if (fLeaderDist == -2.0 || fLeaderDist != -1.0 && fLeaderDist <= (g_fCvar_ImprovedMelee_ApproachRange * 0.75))
							{
								float fTravelDist = GetNavDistance(fMovePos, g_fClientAbsOrigin[iClient], iInfectedTarget);
								if (fTravelDist != -1.0 && fTravelDist <= g_fCvar_ImprovedMelee_ApproachRange)
								{
									SetMoveToPosition(iClient, fMovePos, 2, "ApproachMelee");
									bStopApproaching = false;
								}
							}
						}
					}
					if (bStopApproaching)ClearMoveToPosition(iClient, "ApproachMelee");
				}
				else if (iCurWeapon == iWpnSlots[0])
				{
					int iMeleeSwitchCount = ((iMeleeType != 2) ? g_iCvar_ImprovedMelee_SwitchCount : g_iCvar_ImprovedMelee_SwitchCount2);
					float fMeleeSwitchRange = (g_fCvar_ImprovedMelee_SwitchRange * ((iMeleeType == 2) ? 1.5 : (g_iClientInvFlags[iClient] & FLAG_SHOTGUN ? 0.66 : 1.0)));
					if (fInfectedDist <= fMeleeSwitchRange && !IsValidClient(iTankTarget) && ( ~g_iClientInvFlags[iClient] & FLAG_SHOTGUN || GetWeaponClip1(iCurWeapon) <= 0 ))
					{ 
						if (iInfectedClass != L4D2ZombieClass_NotInfected)
						{
							if (g_iInfectedBot_CurrentVictim[iInfectedTarget] != iClient || L4D_GetPinnedSurvivor(iInfectedTarget) != 0 || L4D_IsPlayerStaggering(iInfectedTarget))
							{
								SwitchWeaponSlot(iClient, 1);
								g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime() + ((iMeleeType == 2) ? 2.0 : 0.1);
							}
						}
						else if (g_iSurvivorBot_NearbyInfectedCount[iClient] >= iMeleeSwitchCount && !IsValidClient(iPinnedFriend) &&
							(GetCurrentGameDifficulty() == 4 || !IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.75)))
						{
							SwitchWeaponSlot(iClient, 1);
							g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime() + ((iMeleeType == 2) ? 2.0 : 0.66);
						}
					}
				}
			}
		}

		if ((g_iCvar_AutoShove_Enabled == 1 || g_iCvar_AutoShove_Enabled == 2 && !FVectorInViewAngle(iClient, fInfectedPos)) && fInfectedDist <= 6400.0 && !L4D_IsPlayerIncapacitated(iClient)
			&& (!IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, (float(g_iSurvivorBot_NearbyFriends[iClient]) / (iTeamCount - 1))))
			&& (~g_iClientInvFlags[iClient] & FLAG_MELEE || iCurWeapon != iWpnSlots[1]))
		{
			if (IsSurvivorCarryingProp(iClient) || (iInfectedClass == L4D2ZombieClass_NotInfected || iInfectedClass != L4D2ZombieClass_Charger && iInfectedClass != L4D2ZombieClass_Tank && !L4D_IsPlayerStaggering(iInfectedTarget) && !IsUsingSpecialAbility(iInfectedTarget)) && GetRandomInt(1, 4) == 1)
			{
				SnapViewToPosition(iClient, fInfectedPos);
				iButtons |= IN_ATTACK2;
			}
			else if (SurvivorBot_AbleToShootWeapon(iClient))
			{
				SnapViewToPosition(iClient, fInfectedPos);
				PressAttackButton(iClient, iButtons);
				//if(g_bCvar_Debug && iCurWeapon == iWpnSlots[1])
				//{
				//	char sClientName[128];
				//	GetClientName(iClient, sClientName, sizeof(sClientName));
				//	PrintToServer("%s presses attack button... \n 1st code suspect \n IN_ATTACK %d IN_ATTACK2 %d", sClientName, (iButtons & IN_ATTACK), (iButtons & IN_ATTACK2));
				//}
			}
		}
	}

	if (g_bCvar_TargetSelection_Enabled && !IsValidClient(iPinnedFriend) && !IsSurvivorBusy(iClient) && (IsValidClient(iTankTarget) || IsEntityExists(iInfectedTarget)))
	{
		int iFireTarget = iInfectedTarget;
		if (IsEntityExists(iFireTarget))
		{
			if (g_bCvar_TargetSelection_IgnoreDociles && !IsValidClient(iFireTarget) && !IsCommonInfectedAttacking(iFireTarget))
			{
				iFireTarget = -1;
			}
			if (IsValidClient(iTankTarget) && (fInfectedDist > 1048576.0 || GetClientDistance(iClient, iTankTarget, true) < fInfectedDist))
			{
				iFireTarget = iTankTarget;
			}
		}
		else if (IsValidClient(iTankTarget))
		{
			iFireTarget = iTankTarget;
		}

		if (IsEntityExists(iFireTarget) && HasVisualContactWithEntity(iClient, iFireTarget, (iFireTarget != iTankTarget)))
		{
			L4D2ZombieClassType iInfectedClass = L4D2ZombieClass_NotInfected;
			if (IsValidClient(iFireTarget))iInfectedClass = L4D2_GetPlayerZombieClass(iFireTarget);

			float fFirePos[3]; GetTargetAimPart(iClient, iFireTarget, fFirePos);
			float fTargetDist = GetVectorDistance(g_fClientEyePos[iClient], fFirePos, true);

			if (iInfectedClass != L4D2ZombieClass_Boomer || !bFriendIsNearBoomer && fTargetDist > BOT_BOOMER_AVOID_RADIUS_SQR)
			{
				if (iCurWeapon == iWpnSlots[0])
				{
					float fShootRange = g_fCvar_TargetSelection_ShootRange;
					if (SurvivorHasShotgun(iClient))
					{
						fShootRange = g_fCvar_TargetSelection_ShootRange2;
						if (fTargetDist <= (g_fCvar_TargetSelection_ShootRange4*g_fCvar_TargetSelection_ShootRange4) && fTargetDist > ((fShootRange * 1.1)*(fShootRange * 1.1))
							&& GetGameTime() > g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] && !IsWeaponReloading(iCurWeapon, false) && ~g_iClientInvFlags[iClient] & FLAG_MELEE )
						{
							g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime() + GetRandomFloat(1.0, 3.0);
							g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
							SwitchWeaponSlot(iClient, 1);
						}
					}
					else if (g_iClientInvFlags[iClient] & FLAG_SNIPER)
					{
						fShootRange = g_fCvar_TargetSelection_ShootRange3;
					}

					if (fTargetDist <= (fShootRange*fShootRange) && SurvivorBot_AbleToShootWeapon(iClient))
					{
						SnapViewToPosition(iClient, fFirePos);
						PressAttackButton(iClient, iButtons);
						//if(g_bCvar_Debug && iCurWeapon == iWpnSlots[1])
						//{
						//	char sClientName[128];
						//	GetClientName(iClient, sClientName, sizeof(sClientName));
						//	PrintToServer("%s presses attack button... \n 2nd code suspect \n IN_ATTACK %d IN_ATTACK2 %d", sClientName, (iButtons & IN_ATTACK), (iButtons & IN_ATTACK2));
						//}
					}
				}
				else if (iCurWeapon == iWpnSlots[1] && ~g_iClientInvFlags[iClient] & FLAG_MELEE)
				{
					float fShotgunRange = (g_fCvar_TargetSelection_ShootRange2 * 0.75);
					if (fTargetDist <= (fShotgunRange*fShotgunRange) && GetGameTime() > g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient]
						&& GetClientPrimaryAmmo(iClient) > 0 && !IsWeaponReloading(iCurWeapon) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
					{
						g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime() + GetRandomFloat(1.0, 3.0);
						g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
						SwitchWeaponSlot(iClient, 0);
					}

					if (L4D_IsPlayerIncapacitated(iClient) || fTargetDist <= (g_fCvar_TargetSelection_ShootRange4*g_fCvar_TargetSelection_ShootRange4) && SurvivorBot_AbleToShootWeapon(iClient))
					{
						SnapViewToPosition(iClient, fFirePos);
						PressAttackButton(iClient, iButtons);
						//if(g_bCvar_Debug && iCurWeapon == iWpnSlots[1])
						//{
						//	char sClientName[128];
						//	GetClientName(iClient, sClientName, sizeof(sClientName));
						//	PrintToServer("%s presses attack button... \n 3rd code suspect \n IN_ATTACK %d IN_ATTACK2 %d", sClientName, (iButtons & IN_ATTACK), (iButtons & IN_ATTACK2));
						//}
					}
				}
			}
		}
	}

	if (g_bCvar_GrenadeThrow_Enabled && iWpnSlots[2] != -1 && (IsEntityExists(iInfectedTarget) || IsValidClient(iTankTarget)))
	{
		float fThrowPosition[3];
		int iThrowTarget = -1, iGrenadeType = SurvivorHasGrenade(iClient);

		bool bIsThrowTargetTank = false;
		if (iGrenadeType != 1 && IsValidClient(iTankTarget) && !L4D_IsPlayerIncapacitated(iTankTarget) && (GetEntityHealth(iTankTarget) - 1500) >= RoundFloat((GetEntityMaxHealth(iTankTarget) - 1500) * 0.33) && GetClientDistance(iClient, iTankTarget, true) <= (g_fCvar_GrenadeThrow_ThrowRange*g_fCvar_GrenadeThrow_ThrowRange))
		{
			iThrowTarget = iTankTarget;
			GetEntityAbsOrigin(iTankTarget, fThrowPosition);
			bIsThrowTargetTank = true;
		}
		else
		{
			int iPossibleTarget = (iGrenadeType != 2 ? GetFarthestInfected(iClient, g_fCvar_GrenadeThrow_ThrowRange) : iInfectedTarget);
			if (iPossibleTarget > 0)
			{
				iThrowTarget = iPossibleTarget;
				GetEntityAbsOrigin(iPossibleTarget, fThrowPosition);
			}
		}
		g_iSurvivorBot_Grenade_ThrowTarget[iClient] = iThrowTarget;

		if (IsEntityExists(iThrowTarget))
		{
			if (iGrenadeType == 2)
			{
				float fThrowAngles[3], fTargetForward[3], fMidPos[3];
				MakeVectorFromPoints(fThrowPosition, g_fClientEyePos[iClient], fThrowAngles);
				NormalizeVector(fThrowAngles, fThrowAngles);
				GetVectorAngles(fThrowAngles, fThrowAngles);

				GetAngleVectors(fThrowAngles, fTargetForward, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(fTargetForward, fTargetForward);

				float fThrowDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fThrowPosition);
				fMidPos[0] = fThrowPosition[0] + (fTargetForward[0] * (fThrowDist * 0.5));
				fMidPos[1] = fThrowPosition[1] + (fTargetForward[1] * (fThrowDist * 0.5));
				fMidPos[2] = fThrowPosition[2] + (fTargetForward[2] * (fThrowDist * 0.5));

				if (GetVectorDistance(g_fClientAbsOrigin[iClient], fMidPos, true) > BOT_GRENADE_CHECK_RADIUS_SQR)
				{
					float fTraceStart[3]; fTraceStart = fMidPos; fTraceStart[2] + HUMAN_HALF_HEIGHT;
					float fAngleDown[3] = {90.0, 0.0, 0.0};
					Handle hGroundCheck = TR_TraceRayFilterEx(fTraceStart, fAngleDown, MASK_PLAYERSOLID, RayType_Infinite, Base_TraceFilter);
					float fTrHitPos[3]; TR_GetEndPosition(fTrHitPos, hGroundCheck); delete hGroundCheck;

					float fHeightDiff = FloatAbs(fTrHitPos[2] - fThrowPosition[2]);
					if (fHeightDiff < 96.0)
					{
						fThrowPosition = fMidPos;
					}
				}
			}

			if (iCurWeapon == iWpnSlots[2])
			{
				int iThrowArea = L4D_GetNearestNavArea(fThrowPosition, _, true, false, _, 3);
				if (iThrowArea)LBI_GetClosestPointOnNavArea(iThrowArea, fThrowPosition, fThrowPosition);

				float fThrowVel[3]; CalculateTrajectory(g_fClientEyePos[iClient], fThrowPosition, 700.0, 0.4, fThrowVel);
				AddVectors(g_fClientEyePos[iClient], fThrowVel, g_fSurvivorBot_Grenade_AimPos[iClient]);

				float fThrowTrajectory[3];
				fThrowTrajectory = fThrowPosition;
				fThrowTrajectory[2] += (g_fSurvivorBot_Grenade_AimPos[iClient][2] - g_fClientEyePos[iClient][2]);

				Handle hCeilingCheck = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fThrowTrajectory, MASK_SOLID, RayType_EndPoint, Base_TraceFilter);
				g_fSurvivorBot_Grenade_AimPos[iClient][2] *= TR_GetFraction(hCeilingCheck); delete hCeilingCheck;

				g_fSurvivorBot_Grenade_ThrowPos[iClient] = fThrowPosition;

				if (g_iSurvivorBot_ThreatInfectedCount[iClient] < GetCommonHitsUntilDown(iClient, 0.33) && CheckIsUnableToThrowGrenade(iClient, iThrowTarget, g_fClientAbsOrigin[iClient], fThrowPosition, bFriendIsNearThrowArea, bIsThrowTargetTank))
				{
					g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
					SwitchWeaponSlot(iClient, ((GetClientPrimaryAmmo(iClient) > 0) ? 0 : 1));

					if (iGrenadeType == 2)
					{
						if (GetGameTime() > g_fSurvivorBot_Grenade_NextThrowTime_Molotov)
						{
							g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + GetRandomFloat(0.75, 1.5);
						}
					}
					else if (GetGameTime() > g_fSurvivorBot_Grenade_NextThrowTime)
					{
						g_fSurvivorBot_Grenade_NextThrowTime = GetGameTime() + GetRandomFloat(0.75, 1.5);
					}
				}
				else
				{
					SnapViewToPosition(iClient, g_fSurvivorBot_Grenade_AimPos[iClient]);
					PressAttackButton(iClient, iButtons); //throw grenade
				}
			}
			else if (CheckCanThrowGrenade(iClient, iThrowTarget, g_fClientAbsOrigin[iClient], fThrowPosition, bFriendIsNearThrowArea, bIsThrowTargetTank))
			{
				SwitchWeaponSlot(iClient, 2);
			}
		}
	}

	if (L4D_IsPlayerIncapacitated(iClient))
		return;

	if (g_bCvar_DeployUpgradePacks && iWpnSlots[0] != -1 && iWpnSlots[3] != -1 && !LBI_IsSurvivorInCombat(iClient) && g_iClientInvFlags[iClient] & FLAG_UPGRADE)
	{
		bool bHasDeployedPackNearby = false;
		int iActiveDeployers = (GetSurvivorTeamActiveItemCount(L4D2WeaponId_IncendiaryAmmo) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_FragAmmo));
		if (g_hDeployedAmmoPacks)
		{
			for (int i = 0; i < g_hDeployedAmmoPacks.Length; i++)
			{
				if (GetEntityDistance(iClient, g_hDeployedAmmoPacks.Get(i), true) > 589824.0)continue;
				bHasDeployedPackNearby = true;
				break;
			}
		}
		
		int iPrimSlot, iPrimaryCount, iUpgradedCount;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientSurvivor(i))
				continue;
				
			iPrimSlot = GetClientWeaponInventory(i, 0);
			if (iPrimSlot == -1)continue;
			
			iPrimaryCount++;
			if (GetEntProp(iPrimSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 1) > 0)
			{
				iUpgradedCount++;
			}
		}

		bool bCanSwitch = (!bHasDeployedPackNearby && iUpgradedCount < RoundFloat(iAlivePlayers * 0.25) && iPrimaryCount >= RoundFloat(iTeamCount * 0.25) && !IsValidClient(iTankTarget));
		if (iCurWeapon == iWpnSlots[3])
		{
			if (iActiveDeployers > 1 || IsValidClient(iTeamLeader) && GetClientDistance(iClient, iTeamLeader, true) >= 65536.0 || !bCanSwitch)
			{
				SwitchWeaponSlot(iClient, (GetClientPrimaryAmmo(iClient) > 0 ? 0 : 1));
			}
			else
			{
				PressAttackButton(iClient, iButtons); // deploy ammo pack
			}
		}
		else if (bCanSwitch && iActiveDeployers == 0 && LBI_IsSurvivorBotAvailable(iClient) && (!IsValidClient(iTeamLeader) || GetClientDistance(iClient, iTeamLeader, true) <= 36864.0))
		{
			SwitchWeaponSlot(iClient, 3);
		}
	}

	if (g_bCvar_DefibRevive_Enabled && IsEntityExists(iDefibTarget) && !IsValidClient(iTankTarget) && !IsValidClient(iPinnedFriend) && !LBI_IsSurvivorInCombat(iClient))
	{
		float fDefibPos[3]; GetEntityAbsOrigin(iDefibTarget, fDefibPos);
		float fDefibDist = GetVectorDistance(g_fClientEyePos[iClient], fDefibPos, true);
		if (fDefibDist <= (g_fCvar_DefibRevive_ScanDist*g_fCvar_DefibRevive_ScanDist) && !LBI_IsDamagingPosition(fDefibPos))
		{
			g_iSurvivorBot_DefibTarget[iClient] = iDefibTarget;

			if ( g_iClientInvFlags[iClient] & FLAG_DEFIB )
			{
				if (L4D2_GetPlayerUseActionTarget(iClient) == iDefibTarget || fDefibDist <= 9216.0)
				{
					if (iCurWeapon == iWpnSlots[3])
					{
						SnapViewToPosition(iClient, fDefibPos);
						PressAttackButton(iClient, iButtons); // use defib
					}
					else
					{
						SwitchWeaponSlot(iClient, 3);
					}
				}
				else if (!IsSurvivorBotBlindedByVomit(iClient) && !IsFinaleEscapeVehicleArrived() && LBI_IsSurvivorBotAvailable(iClient) && LBI_IsReachablePosition(iClient, fDefibPos) && 
					g_iSurvivorBot_NearbyInfectedCount[iClient] < GetCommonHitsUntilDown(iClient, 0.66) && !IsValidClient(g_iSurvivorBot_IncapacitatedFriend[iClient])
				)
				{
					SetMoveToPosition(iClient, fDefibPos, 2, "DefibPlayer");
				}
			}
		}
	}

	static float fRndSearchTime;
	if (g_iCvar_ItemScavenge_Items != 0 && GetGameTime() > g_fSurvivorBot_NextScavengeItemScanTime[iClient])
	{
		g_iSurvivorBot_ScavengeItem[iClient] = CheckForItemsToScavenge(iClient);		
		fRndSearchTime = GetGameTime() + GetRandomFloat(0.5, 1.5);
		g_fSurvivorBot_NextScavengeItemScanTime[iClient] = fRndSearchTime;
	}

	int iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	if (IsEntityExists(iScavengeItem))
	{
		if (IsValidClient(GetEntityOwner(iScavengeItem)))
		{
			ClearMoveToPosition(iClient, "ScavengeItem");
			g_iSurvivorBot_ScavengeItem[iClient] = -1;
			g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
		}
		else
		{
			int iUseButton = IN_USE;
			bool bHoldKey = false;
			float fUseRange = g_fCvar_ItemScavenge_PickupRange;
			static bool bIncreasedTime = false;

			static char sScavengeItem[64]; GetEntityClassname(iScavengeItem, sScavengeItem, sizeof(sScavengeItem));
			char sClientName[128];
			GetClientName(iClient, sClientName, sizeof(sClientName));
			
			if (strcmp(sScavengeItem, "point_prop_use_target") == 0 && IsSurvivorCarryingProp(iClient))
			{
				iUseButton = IN_ATTACK;
				bHoldKey = true;
				fUseRange = 32.0;

				if (bIncreasedTime && L4D2_GetPlayerUseAction(iClient) != L4D2UseAction_PouringGas)
				{
					bIncreasedTime = false;
				}
			}
			else if (strcmp(sScavengeItem, "func_button_timed") == 0)
			{
				bHoldKey = true;
				fUseRange = 96.0;

				if (bIncreasedTime && L4D2_GetPlayerUseAction(iClient) == L4D2UseAction_None && g_fSurvivorBot_NextScavengeItemScanTime[iClient] == fRndSearchTime)
				{
					bIncreasedTime = false;
				}
			}

			if (!IsSurvivorBotBlindedByVomit(iClient) && (bHoldKey || !IsSurvivorBusy(iClient, true, true, true)))
			{
				float fItemPos[3]; GetEntityCenteroid(iScavengeItem, fItemPos);
				if (GetVectorDistance(g_fClientEyePos[iClient], fItemPos, true) <= (fUseRange*fUseRange) && IsVisibleEntity(iClient, iScavengeItem))
				{
					if (GetGameTime() > g_fSurvivorBot_NextUsePressTime[iClient])
					{
						BotLookAtPosition(iClient, fItemPos, 0.33);
						if ( LBI_FindUseEntity( iClient, fUseRange ) == iScavengeItem )
						{
							if (!bHoldKey)
							{
								g_fSurvivorBot_NextUsePressTime[iClient] = GetGameTime() + GetRandomFloat(0.1, 0.33);
								if (GetRandomInt(1, 2) == 1)iButtons |= iUseButton;
							}
							else
							{ 
								iButtons |= iUseButton;
								if (!bIncreasedTime)
								{
									bIncreasedTime = true;

									float fAddTime;
									if (strcmp(sScavengeItem, "func_button_timed") != 0)
									{
										fAddTime = g_fCvar_GasCanUseDuration;
									}
									else
									{
										fAddTime = GetEntPropFloat(iScavengeItem, Prop_Data, "m_nUseTime");
									}

									if (L4D2_IsUnderAdrenalineEffect(iClient))fAddTime *= 0.5;
									g_fSurvivorBot_NextScavengeItemScanTime[iClient] = GetGameTime() + fAddTime + 0.33;
								}
							}
						}
					}
				}
				else
				{
					static bool bAllowScavenge, bCanRegroup;
					static int iScavengeArea, iLeaderArea, iHits, iInfected;
					static float fMaxDist, fDist, fDistanceToRegroup, fScavengePos[3]; 
					
					bAllowScavenge = true;
					fScavengePos = fItemPos;
					fDistanceToRegroup = -1.0;
					fMaxDist = g_fCvar_ItemScavenge_ApproachVisibleRange;
					if (!bTeamHasHumanPlayer)
						fMaxDist *= g_fCvar_ItemScavenge_NoHumansRangeMultiplier;
					iScavengeArea = L4D_GetNearestNavArea(fItemPos, 140.0, true, true, false);
					iLeaderArea = L4D_GetNearestNavArea(g_fClientAbsOrigin[iTeamLeader], 140.0, true, true, false);
					
					if (iScavengeArea && iLeaderArea)
					{										
						LBI_GetClosestPointOnNavArea(iScavengeArea, fItemPos, fScavengePos);
						if ( bTeamHasHumanPlayer && !LBI_IsNavAreaPartiallyVisible(iScavengeArea, g_fClientEyePos[iClient], iClient) )
							fMaxDist = g_fCvar_ItemScavenge_ApproachRange;
						
						iHits = GetCommonHitsUntilDown(iClient, 0.66);
						iInfected = g_iSurvivorBot_NearbyInfectedCount[iClient];
						if (iInfected > 0)
						{
							fDist = fMaxDist/((iInfected+1)/iHits);
							if (fMaxDist > fDist) fMaxDist = fDist;
						}
						
						bCanRegroup = L4D2_NavAreaBuildPath(view_as<Address>(iScavengeArea), view_as<Address>(iLeaderArea), fMaxDist, 2, false);
						if (bCanRegroup)
							fDistanceToRegroup = GetNavDistance(fScavengePos, g_fClientAbsOrigin[iTeamLeader], iScavengeItem, false);
					}
					else
						bAllowScavenge = false;

					if ( bAllowScavenge && bCanRegroup && fDistanceToRegroup != -1.0 && fDistanceToRegroup < fMaxDist && !LBI_IsDamagingPosition(fScavengePos) && !IsFinaleEscapeVehicleArrived() &&
						(!IsValidClient(iTankTarget) || GetClientDistance(iClient, iTankTarget, true) > 262144.0 && GetVectorDistance(g_fClientAbsOrigin[iTankTarget], fScavengePos, true) > 147456.0)
					)
					{
						SetMoveToPosition(iClient, fScavengePos, 1, "ScavengeItem");
					}
					else
					{
						ClearMoveToPosition(iClient, "ScavengeItem");
						g_iSurvivorBot_ScavengeItem[iClient] = -1;
						g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
					}
				}
			}
		}
	}
}

Action OnSurvivorSwitchWeapon(int iClient, int iWeapon) 
{
	if (!IsClientSurvivor(iClient) || !IsFakeClient(iClient) || g_bSurvivorBot_ForceSwitchWeapon[iClient] || !IsEntityExists(iWeapon) || L4D_IsPlayerIncapacitated(iClient))
	{
		g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
		return Plugin_Continue;
	}

	int iCurWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (iCurWeapon == -1 || iWeapon == iCurWeapon || GetWeaponClip1(iCurWeapon) < 0)
	{
		g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
		return Plugin_Continue;
	}

	if (iWeapon == GetClientWeaponInventory(iClient, 0))
	{
		if (GetSurvivorBotWeaponPreference(iClient) == L4D_WEAPON_PREFERENCE_SECONDARY)
		{
			SwitchWeaponSlot(iClient, 1);
			return Plugin_Handled;
		}

		if (iCurWeapon == GetClientWeaponInventory(iClient, 1))
		{
			if ( g_iClientInvFlags[iClient] & FLAG_MELEE )
			{
				if (GetGameTime() <= g_fSurvivorBot_BlockWeaponSwitchTime[iClient])
				{
					return Plugin_Handled;
				}
			}
			else if (IsWeaponReloading(iCurWeapon) || GetWeaponClip1(iCurWeapon) != GetWeaponClipSize(iCurWeapon) && !LBI_IsSurvivorInCombat(iClient))
			{
				g_bSurvivorBot_ForceWeaponReload[iClient] = true;
				return Plugin_Handled;
			}
		}
	}
	else if (iWeapon == GetClientWeaponInventory(iClient, 1)) 
	{
		if (iCurWeapon == GetClientWeaponInventory(iClient, 0) && GetClientPrimaryAmmo(iClient) > 0)
		{
			if (g_iSurvivorBot_NearbyInfectedCount[iClient] < g_iCvar_ImprovedMelee_SwitchCount2 && g_iClientInvFlags[iClient] & FLAG_CHAINSAW)
			{
				return Plugin_Handled;
			}

			if (GetSurvivorBotWeaponPreference(iClient) != L4D_WEAPON_PREFERENCE_SECONDARY && ( ~g_iClientInvFlags[iClient] & FLAG_MELEE
				|| g_iSurvivorBot_NearbyInfectedCount[iClient] < g_iCvar_ImprovedMelee_SwitchCount )
				&& ((g_bCvar_DontSwitchToPistol && g_iClientInvFlags[iClient] & FLAG_SNIPER) || g_iClientInvFlags[iClient] & FLAG_SHOTGUN))
			{
				return Plugin_Handled;
			}
		}
	}

	if (IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && iCurWeapon == GetClientWeaponInventory(iClient, 3) && g_iClientInvFlags[iClient] & FLAG_DEFIB)
	{
		return Plugin_Handled;
	}

	if (g_bCvar_AlwaysCarryProp && IsSurvivorCarryingProp(iClient) && (iWeapon == GetClientWeaponInventory(iClient, 0) || iWeapon == GetClientWeaponInventory(iClient, 1)))
	{
		int iTeamCount = (g_iSurvivorBot_NearbyFriends[iClient] / 2); if (iTeamCount < 1)iTeamCount = 1;
		int iDropLimitCount = RoundFloat(GetCommonHitsUntilDown(iClient, 0.5) * float(iTeamCount));
		if (g_iSurvivorBot_ThreatInfectedCount[iClient] < iDropLimitCount)return Plugin_Handled;
	}

	g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
	return Plugin_Continue;
}

Action OnSurvivorTakeDamage(int iClient, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType) 
{
	if (GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
		return Plugin_Continue;

	if (IsWitch(iAttacker))
	{
		int iWitchRef;
		for (int i = 0; i < g_hWitchList.Length; i++)
		{
			iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
			if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
			{
				g_hWitchList.Erase(i);
				continue;
			}
			if (iWitchRef == iAttacker)
			{
				g_hWitchList.Set(i, GetClientUserId(iClient), 1);
				break;
			}
		}
	}

	if (!IsFakeClient(iClient))
		return Plugin_Continue;

	if (IsSurvivorBotBlindedByVomit(iClient) && (IsValidClient(iAttacker) && GetClientTeam(iAttacker) == 3 || IsCommonInfected(iAttacker)))
	{
		float fLookPos[3]; GetEntityCenteroid(iAttacker, fLookPos);
		BotLookAtPosition(iClient, fLookPos, 1.0);
		g_bSurvivorBot_ForceBash[iClient] = true;
	}

	if (g_bCvar_NoFallDmgOnLadderFail && iDamageType & DMG_FALL && GetGameTime() <= g_fSurvivorBot_TimeSinceLeftLadder[iClient])
	{
		fDamage = 0.0;
		return Plugin_Changed; 
	}

	if (!g_bCvar_SpitterAcidEvasion || !IsEntityExists(iInflictor) || strcmp(g_sSurvivorBot_MovePos_Name[iClient], "EscapeInferno") == 0)
		return Plugin_Continue; 

	static char sInfClass[16]; GetEntityClassname(iInflictor, sInfClass, sizeof(sInfClass));
	if (strcmp(sInfClass, "insect_swarm") != 0 && strcmp(sInfClass, "inferno") != 0)return Plugin_Continue; 

	int iNavArea;
	float fCurDist, fLastDist = -1.0;
	float fEscapePos[3], fPathPos[3];
	for (int i = 0; i < 12; i++)
	{
		VScript_TryGetPathableLocationWithin(iClient, 250.0 + (50.0 * i), fPathPos);
		if (!IsValidVector(fPathPos))continue;

		fCurDist = GetClientTravelDistance(iClient, fPathPos, true);
		if (fLastDist != -1.0 && fCurDist >= fLastDist)
			continue;

		iNavArea = L4D_GetNearestNavArea(fPathPos);
		if (!iNavArea || LBI_IsDamagingNavArea(iNavArea, true) || !LBI_IsReachableNavArea(iClient, iNavArea))
			continue;

		fLastDist = fCurDist;
		fEscapePos = fPathPos;
	}

	if (IsValidVector(fEscapePos))
		SetMoveToPosition(iClient, fEscapePos, 4, "EscapeInferno", 0.0, 5.0, true, true);

	return Plugin_Continue; 
}


Action OnWitchTakeDamage(int iWitch, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType) 
{
	if ( iDamageType & (DMG_BULLET | DMG_BLAST | DMG_BLAST_SURFACE) )
	{
		CreateTimer(0.1, CheckWitchStumble, iWitch);
	}
	return Plugin_Continue; 
}

public Action CheckWitchStumble(Handle timer, int iWitch)
{
	if (IsEntityExists(iWitch))
	{
		static int iWitchRef;
		static float fWitchRage;
		
		for (int i = 0; i < g_hWitchList.Length; i++)
		{
			iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
			if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
			{
				g_hWitchList.Erase(i);
				continue;
			}
			if (iWitchRef == iWitch)
			{
				fWitchRage = GetEntPropFloat(iWitch, Prop_Send, "m_rage");
				if (g_hWitchList.Get(i, 1) == 0 && fWitchRage > 0.99)
				{
					g_hWitchList.Set(i, -1, 1);
					SDKUnhook(iWitch, SDKHook_OnTakeDamage, OnWitchTakeDamage);
					break;
				}
			}
		}
	}
	return Plugin_Handled;
}

bool TakeCoverFromPosition(int iClient, float fPosition[3], float fSearchDist = 384.0)
{
	float fSelfToPos[3]; MakeVectorFromPoints(g_fClientEyePos[iClient], fPosition, fSelfToPos);
	NormalizeVector(fSelfToPos, fSelfToPos);

	float fDot, fPathPos[3], fPathOffset[3], fSelfToMovePos[3];
	for (int i = 0; i < 10; i++)
	{
		VScript_TryGetPathableLocationWithin(iClient, fSearchDist, fPathPos);
		if (!IsValidVector(fPathPos) || LBI_IsDamagingPosition(fPathPos))continue;

		fPathOffset = fPathPos; fPathOffset[2] + HUMAN_HALF_HEIGHT;

		MakeVectorFromPoints(g_fClientEyePos[iClient], fPathPos, fSelfToMovePos);
		NormalizeVector(fSelfToMovePos, fSelfToMovePos);

		fDot = GetVectorDotProduct(fSelfToPos, fSelfToMovePos);
		if (fDot > 0.2 || GetVectorVisible(fPosition, fPathOffset))continue;

		SetMoveToPosition(iClient, fPathPos, 3, "TakeCover");
		return true;
	}

	return false;
}

bool TakeCoverFromEntity(int iClient, int iEntity, float fSearchDist = 384.0)
{
	float fEntityPos[3];
	if (IsValidClient(iEntity))GetClientEyePosition(iEntity, fEntityPos);
	else GetEntityCenteroid(iEntity, fEntityPos);
	return (TakeCoverFromPosition(iClient, fEntityPos, fSearchDist));
}

void ClearMoveToPosition(int iClient, const char[] sCheckName = "")
{
	if (sCheckName[0] != 0 && strcmp(g_sSurvivorBot_MovePos_Name[iClient], sCheckName) != 0)
		return;

	if (!IsValidVector(g_fSurvivorBot_MovePos_Position[iClient]) || LBI_IsDamagingNavArea(g_iClientNavArea[iClient]))
		return;

	g_iSurvivorBot_MovePos_Priority[iClient] = -1;
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime();
	g_fSurvivorBot_MovePos_Tolerance[iClient] = -1.0;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = false;
	g_sSurvivorBot_MovePos_Name[iClient][0] = 0;

	SetVectorToZero(g_fSurvivorBot_MovePos_Position[iClient]);
	L4D2_CommandABot(iClient, 0, BOT_CMD_RESET);
}

void SetMoveToPosition(int iClient, float fMovePos[3], int iPriority, const char[] sName = "", float fAddDuration = 0.66, float fDistTolerance = -1.0, bool bIgnoreDamaging = false, bool bIgnoreCheckpoints = false)
{
	if (iPriority < g_iSurvivorBot_MovePos_Priority[iClient] || IsValidVector(g_fSurvivorBot_MovePos_Position[iClient]))
		return;

	if (fDistTolerance >= 0.0 && GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true) <= (fDistTolerance*fDistTolerance))
		return;

	if (!bIgnoreDamaging && (LBI_IsDamagingNavArea(g_iClientNavArea[iClient]) || LBI_IsDamagingPosition(fMovePos)))
		return;

	if (!bIgnoreCheckpoints && LBI_IsPositionInsideCheckpoint(g_fClientAbsOrigin[iClient]) && !LBI_IsPositionInsideCheckpoint(fMovePos))
		return;

	//float fTravelDist = GetClientTravelDistance(iClient, fMovePos, true);
	float fTravelDist = GetNavDistance(g_fClientAbsOrigin[iClient], fMovePos, _, false);
	if (fTravelDist <= 0.0)fTravelDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true);

	float fMaxSpeed = GetClientMaxSpeed(iClient);
	//g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime() + (fTravelDist / (fMaxSpeed*fMaxSpeed)) + fAddDuration;
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime() + (fTravelDist / fMaxSpeed) + fAddDuration;

	strcopy(g_sSurvivorBot_MovePos_Name[iClient], 64, sName);

	g_fSurvivorBot_MovePos_Position[iClient] = fMovePos;
	g_iSurvivorBot_MovePos_Priority[iClient] = iPriority;
	g_fSurvivorBot_MovePos_Tolerance[iClient] = fDistTolerance;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = bIgnoreDamaging;
}

// oh heelll nah
void LBI_TryGetPathableLocationWithin(int iClient, float fRadius, float fBuffer[3])
{
	char sBuffer[512];
	FormatEx(sBuffer, sizeof(sBuffer), "local ply = GetPlayerFromUserID(%i);\
		local location = ply.TryGetPathableLocationWithin(%f);\
		local spaceChar = 32;\
		<RETURN>location.x.tostring() + spaceChar.tochar() + location.y.tostring() + spaceChar.tochar() + location.z.tostring()</RETURN>", GetClientUserId(iClient), fRadius);
	L4D2_GetVScriptOutput(sBuffer, sBuffer, sizeof(sBuffer));

	char sCoordinate[64];
	SplitString(sBuffer, " ", sCoordinate, sizeof(sCoordinate));
	fBuffer[0] = StringToFloat(sCoordinate);
	FormatEx(sCoordinate, sizeof(sCoordinate), "%s ", sCoordinate);
	ReplaceString(sBuffer, sizeof(sBuffer), sCoordinate, "");

	SplitString(sBuffer, " ", sCoordinate, sizeof(sCoordinate));
	fBuffer[1] = StringToFloat(sCoordinate);
	FormatEx(sCoordinate, sizeof(sCoordinate), "%s ", sCoordinate);
	ReplaceString(sBuffer, sizeof(sBuffer), sCoordinate, "");

	fBuffer[2] = StringToFloat(sBuffer);
}

void InitPathWithin()
{
	/*
	::IBPathWithin <- function (iClient, fRadius)
	{
		local ply = GetPlayerFromUserID(iClient);
		return ply.TryGetPathableLocationWithin(fRadius)
	}
	*/
	
	HSCRIPT script = VScript_CompileScript("::IBPathWithin <- function (iClient, fRadius) { return GetPlayerFromUserID(iClient).TryGetPathableLocationWithin(fRadius) }");
	VScriptExecute execute = new VScriptExecute(script);
	ScriptStatus_t valid = execute.Execute();
	delete execute;
	script.ReleaseScript();
	PrintToServer("InitPathWithin: execute status %d, status_done: %b", valid, (valid == SCRIPT_DONE));
	
	g_vsPathWithin = new VScriptExecute(HSCRIPT_RootTable.GetValue("IBPathWithin"));
	
	g_bInitPathWithin = true;
}

void VScript_TryGetPathableLocationWithin(int iClient, float fRadius, float fBuffer[3])
{
	static int iUserID;
	
	if(!g_bInitPathWithin)
		InitPathWithin();
	
	iUserID = GetClientUserId(iClient);
	g_vsPathWithin.SetParam(1, FIELD_INTEGER, iUserID);
	g_vsPathWithin.SetParam(2, FIELD_FLOAT, fRadius);
	g_vsPathWithin.Execute();
	g_vsPathWithin.GetReturnVector(fBuffer);
}

bool SurvivorBot_IsTargetShootable(int iClient, int iTarget, int iCurWeapon, float fAimPos[3])
{
	int iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	bool bInViewCone = (GetClientAimTarget(iClient, false) == iTarget);	
	if (!bInViewCone)
	{
		float fCone = 2.0 * (512.0 / GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iTarget]));
		if (iCurWeapon == iPrimarySlot && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
			fCone *= 2.0;
		bInViewCone = ( FVectorInViewCone(iClient, g_fClientCenteroid[iTarget], fCone) && IsVisibleEntity(iClient, iTarget) );
	}

	if (IsValidClient(iTarget))
	{
		if (bInViewCone)
		{
			L4D2ZombieClassType iClass = L4D2_GetPlayerZombieClass(iTarget);
			if (iClass == L4D2ZombieClass_Boomer && GetClientDistance(iClient, iTarget, true) <= BOT_BOOMER_AVOID_RADIUS_SQR)
				return false;
			if (iClass == L4D2ZombieClass_Tank && iCurWeapon == iPrimarySlot && GetWeaponClip1(iCurWeapon) < 3 && IsWeaponReloading(iCurWeapon, false) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
				return false;
		}

		if (GetClientTeam(iTarget) == 2 && !L4D_IsPlayerPinned(iTarget) && !L4D_IsPlayerIncapacitated(iClient))
		{
			if (bInViewCone && !g_bCvar_BotsShootThrough && (iCurWeapon == iPrimarySlot || iCurWeapon == GetClientWeaponInventory(iClient, 1)
				&& ( ~g_iClientInvFlags[iClient] & FLAG_MELEE || GetClientDistance(iClient, iTarget) <= 96.0)))
				return false;

			if (g_bCvar_BotsFriendlyFire) 
			{
				if (GetClientDistance(iClient, iTarget, true) <= 256.0)
					return false;
				if (iCurWeapon == iPrimarySlot && GetWeaponClip1(iCurWeapon) != 0 && GetVectorDistance(fAimPos, g_fClientCenteroid[iTarget], true) <= 90000.0
				&& g_iClientInvFlags[iClient] & FLAG_GL && GetVectorVisible(fAimPos, g_fClientCenteroid[iTarget]))
					return false;
			}
		}
		
		return true;
	}

	return bInViewCone;
}

bool SurvivorBot_CanFreelyFireWeapon(int iClient)
{	
	int iCurWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (g_bCvar_AlwaysCarryProp && iCurWeapon == GetClientWeaponInventory(iClient, 5))
	{
		if (g_bCvar_AlwaysCarryProp)return false;
		int iTeamCount = (g_iSurvivorBot_NearbyFriends[iClient] / 2); if (iTeamCount < 1)iTeamCount = 1;
		int iDropLimitCount = RoundFloat(GetCommonHitsUntilDown(iClient, 0.5) * float(iTeamCount));
		return (g_iSurvivorBot_ThreatInfectedCount[iClient] >= iDropLimitCount);
	}

	float fAimPos[3]; GetClientAimPosition(iClient, fAimPos);
	if (iCurWeapon == GetClientWeaponInventory(iClient, 0))
	{
		int iClip = GetWeaponClip1(iCurWeapon);
		if (g_bCvar_BotsFriendlyFire && iClip != 0 && GetVectorDistance(fAimPos, g_fClientCenteroid[iClient], true) <= 90000.0
		&& g_iClientInvFlags[iClient] & FLAG_GL && GetVectorVisible(fAimPos, g_fClientCenteroid[iClient]))
		{
			if (IsEntityExists(g_iSurvivorBot_TargetInfected[iClient]) && ( ~g_iClientInvFlags[iClient] & FLAG_MELEE
			|| GetVectorDistance(fAimPos, g_fClientCenteroid[iClient], true) <= g_fCvar_ImprovedMelee_SwitchRange))
				SwitchWeaponSlot(iClient, 1);

			return false;
		}

		if (iClip < 2 && IsWeaponReloading(iCurWeapon, false) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
			return false;
	}

	float fCurDist, fLastDist = -1.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iClient || !IsClientInGame(i) || !IsPlayerAlive(i))continue;

		fCurDist = GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iClient], true);
		if (fLastDist != -1.0 && fCurDist >= fLastDist)continue;
		fLastDist = fCurDist;

		if (SurvivorBot_IsTargetShootable(iClient, i, iCurWeapon, fAimPos))continue;
		return false;
	}

	return (SurvivorBot_AbleToShootWeapon(iClient));
}

bool SurvivorBot_AbleToShootWeapon(int iClient)
{
	return (!IsWeaponReloading(L4D_GetPlayerCurrentWeapon(iClient)) && !L4D_IsPlayerStaggering(iClient));
}

void GetClosestToEyePosEntityBonePos(int iClient, int iTarget, float fAimPos[3])
{
	float fBoneDist, fBonePos[3], fAimPartPos[3], fLastDist = -1.0;
	if (SDKCall(g_hLookupBone, iTarget, "ValveBiped.Bip01_Pelvis") != -1)
	{
		for (int i = 0; i < sizeof(g_sBoneNames_Old); i++)
		{
			if (!LBI_GetBonePosition(iTarget, g_sBoneNames_Old[i], fBonePos))
				continue;

			fBoneDist = GetVectorDistance(g_fClientEyePos[iClient], fBonePos, true);
			if (fLastDist != -1.0 && fBoneDist >= fLastDist)continue;

			fLastDist = fBoneDist;
			fAimPartPos = fBonePos;
		}
	}
	else
	{
		for (int i = 0; i < sizeof(g_sBoneNames_New); i++)
		{
			if (!LBI_GetBonePosition(iTarget, g_sBoneNames_New[i], fBonePos))
				continue;

			fBoneDist = GetVectorDistance(g_fClientEyePos[iClient], fBonePos, true);
			if (fLastDist != -1.0 && fBoneDist >= fLastDist)continue;
			
			fLastDist = fBoneDist;
			fAimPartPos = fBonePos;
		}
	}
	fAimPos = fAimPartPos;
}

void GetTargetAimPart(int iClient, int iTarget, float fAimPos[3])
{
	if (IsWeaponSlotActive(iClient, 0) && g_iClientInvFlags[iClient] & FLAG_GL && (!IsValidClient(iTarget) || L4D2_GetPlayerZombieClass(iTarget) != L4D2ZombieClass_Jockey))
	{
		GetEntityAbsOrigin(iTarget, fAimPos);
		return;
	}

	static char sAimBone[64];
	float fDist = GetEntityDistance(iClient, iTarget, true);
	bool bIsUsingOldSkeleton = (SDKCall(g_hLookupBone, iTarget, "ValveBiped.Bip01_Pelvis") != -1);
	if (IsWitch(iTarget) && fDist <= 65536.0 && IsWeaponSlotActive(iClient, 0) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN || (L4D_IsPlayerIncapacitated(iClient)
		&& fDist <= 147456.0 || L4D2_IsRealismMode() && fDist <= 262144.0) && (!IsValidClient(iTarget) || L4D2_GetPlayerZombieClass(iTarget) != L4D2ZombieClass_Tank))
	{
		sAimBone = (bIsUsingOldSkeleton ? "ValveBiped.Bip01_Head1" : "bip_head");
	}
	else
	{
		sAimBone = (bIsUsingOldSkeleton ? "ValveBiped.Bip01_Spine2" : "bip_spine_2");
	}

	float fAimPartPos[3]; 
	LBI_GetBonePosition(iTarget, sAimBone, fAimPartPos);

	if (!IsVisibleVector(iClient, fAimPartPos))
	{
		bool bVisibleOther = false;
		if (bIsUsingOldSkeleton)
		{
			for (int i = 0; i < sizeof(g_sBoneNames_Old); i++)
			{
				if (!LBI_GetBonePosition(iTarget, g_sBoneNames_Old[i], fAimPartPos))
				continue;

				if (IsVisibleVector(iClient, fAimPartPos))
				{
					bVisibleOther = true;
					break;
				}
			}
		}
		else
		{
			for (int i = 0; i < sizeof(g_sBoneNames_New); i++)
			{
				if (!LBI_GetBonePosition(iTarget, g_sBoneNames_New[i], fAimPartPos))
				continue;

				if (IsVisibleVector(iClient, fAimPartPos))
				{
					bVisibleOther = true;
					break;
				}
			}
		}
		if (!bVisibleOther)return;
	}

	fAimPos = fAimPartPos;
}

bool CheckIfCanRescueImmobilizedFriend(int iClient)
{
	if (IsSurvivorBotBlindedByVomit(iClient))
		return false;

	if (!L4D_IsPlayerIncapacitated(iClient)) 
	{		
		if (g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.33))
			return false;

		if (IsSurvivorBusy(iClient))
			return false;
	}

	return true;
}

void BotLookAtPosition(int iClient, float fLookPos[3], float fLookDuration = 0.33)
{
	g_fSurvivorBot_LookPosition[iClient] = fLookPos;
	g_fSurvivorBot_LookPosition_Duration[iClient] = GetGameTime() + fLookDuration;
}

bool IsUsingSpecialAbility(int iClient)
{
	if (!IsSpecialInfected(iClient))
		return false;

	int iAbilityEntity = L4D_GetPlayerCustomAbility(iClient);
	if (iAbilityEntity == -1)return false;

	static char sProperty[16];
	switch(L4D2_GetPlayerZombieClass(iClient))
	{
		case L4D2ZombieClass_Boomer: 	sProperty = "m_isSpraying";
		case L4D2ZombieClass_Hunter: 	sProperty = "m_isLunging";
		case L4D2ZombieClass_Jockey: 	sProperty = "m_isLeaping";
		case L4D2ZombieClass_Charger: 	sProperty = "m_isCharging";
		case L4D2ZombieClass_Smoker: 	sProperty = "m_tongueState";
		default: 						return false;
	}

	if (!HasEntProp(iAbilityEntity, Prop_Send, sProperty))
		return false;

	return (GetEntProp(iAbilityEntity, Prop_Send, sProperty) > 0);
}

int CalculateGrenadeThrowInfectedCount()
{
	int iFreeSurvivors;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || L4D_IsPlayerBoomerBiled(i) || L4D_IsPlayerIncapacitated(i) || L4D_IsPlayerPinned(i) || GetClientRealHealth(i) <= RoundFloat(g_iCvar_SurvivorLimpHealth * 0.8))
			continue;

		iFreeSurvivors++;
		if ( IsWeaponSlotActive(i, 1) && g_iClientInvFlags[i] & FLAG_CHAINSAW )
			iFreeSurvivors++;
	}

	float fCountScale = g_fCvar_GrenadeThrow_HordeSize;
	int iFinalCount = RoundFloat(iFreeSurvivors * fCountScale);
	if (iFinalCount < 1)iFinalCount = RoundFloat(fCountScale);
	if (L4D2_IsTankInPlay())iFinalCount = RoundFloat(iFinalCount * 0.66);
	return iFinalCount;
}

bool CheckCanThrowGrenade(int iClient, int iTarget, float fClientPos[3], float fThrowPos[3], bool bTeammateNearThrowArea, bool bIsThrowTargetTank)
{
	if (g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.33))
		return false;

	if (IsWeaponReloading(L4D_GetPlayerCurrentWeapon(iClient)))
		return false;

	if (IsSurvivorBusy(iClient, _, true, true))
		return false;

	int iGrenadeType = SurvivorHasGrenade(iClient);
	if (iGrenadeType == 0)return false;

	int iGrenadeBit = (iGrenadeType == 2 ? 1 : iGrenadeType == 3 ? 2 : 0);
	if (g_iCvar_GrenadeThrow_GrenadeTypes & (1 << iGrenadeBit) == 0)return false;

	if (iGrenadeType == 2) 
	{
		if (bTeammateNearThrowArea)
		{
			return false;
		}

		if (GetGameTime() < g_fSurvivorBot_Grenade_NextThrowTime_Molotov)
		{
			return false;
		}

		if ((fThrowPos[2] - fClientPos[2]) > 256.0)
		{
			return false;
		}
					
		if (IsEntityOnFire(iTarget))
		{
			return false;
		}

		if (GetVectorDistance(fClientPos, fThrowPos, true) <= BOT_GRENADE_CHECK_RADIUS_SQR)
		{
			return false;
		}

		if (IsFinaleEscapeVehicleArrived())
		{
			return false;
		}
	}
	else if (GetGameTime() < g_fSurvivorBot_Grenade_NextThrowTime)
	{
		return false;
	}

	if (GetPinnedSurvivorCount() != 0)
		return false;

	int iActiveGrenades = (GetSurvivorTeamActiveItemCount(L4D2WeaponId_PipeBomb) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Molotov) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Vomitjar));
	if (iActiveGrenades >= 1)
		return false;

	if (bIsThrowTargetTank == true)
	{
		if (iGrenadeType == 1)
			return false;

		if (iGrenadeType == 3)
		{
			if (GetGameTime() <= g_fInfectedBot_CoveredInVomitTime[iTarget])
				return false;

			if (GetInfectedCount(iTarget, g_fCvar_ChaseBileRange, 10, _, false) < 10)
				return false;
		}

		if (!IsVisibleEntity(iClient, iTarget, MASK_SHOT_HULL))
			return false;
	}
	else
	{
		if (iGrenadeType == 2)
			return false;

		int iThrowCount = CalculateGrenadeThrowInfectedCount();		
		if (g_iSurvivorBot_GrenadeInfectedCount[iClient] < iThrowCount)
		{
			return false;
		}

		int iChaseEnt = INVALID_ENT_REFERENCE;
		float fItRange = (g_fCvar_ChaseBileRange*g_fCvar_ChaseBileRange);
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "info_goal_infected_chase")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > fItRange)continue;
			return false;
		}

		iChaseEnt = INVALID_ENT_REFERENCE;
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "pipe_bomb_projectile")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > 1048576.0)continue;
			return false;
		}
	}

	if (iGrenadeType == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientSurvivor(i) || !L4D_IsPlayerBoomerBiled(i))continue;
			return false;
		}
	}

	return true;
}

bool CheckIsUnableToThrowGrenade(int iClient, int iTarget, float fClientPos[3], float fThrowPos[3], bool bTeammateNearThrowArea, bool bIsThrowTargetTank)
{
	int iActiveGrenades = (GetSurvivorTeamActiveItemCount(L4D2WeaponId_PipeBomb) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Molotov) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Vomitjar));
	if (iActiveGrenades > 1)
		return true;

	int iGrenadeType = SurvivorHasGrenade(iClient);
	if (iGrenadeType == 2)
	{
		if (bTeammateNearThrowArea)
			return true;

		if ((fThrowPos[2] - fClientPos[2]) > 256.0)
			return true;

		if (GetVectorDistance(fClientPos, fThrowPos, true) <= BOT_GRENADE_CHECK_RADIUS_SQR)
			return true;
					
		if (IsEntityOnFire(iTarget))
			return true;
	}

	if (bIsThrowTargetTank)
	{
		if (iGrenadeType == 1)
			return true;

		if (iGrenadeType == 3)
		{
			if (GetGameTime() <= g_fInfectedBot_CoveredInVomitTime[iTarget])
				return true;

			if (GetInfectedCount(iTarget, g_fCvar_ChaseBileRange, 10, _, false) < 10)
				return true;
		}

		if (!IsVisibleEntity(iClient, iTarget, MASK_SHOT_HULL))
			return true;
	}
	else
	{
		if (iGrenadeType == 2)
			return true;

		int iThrowCount = CalculateGrenadeThrowInfectedCount();
		if (g_iSurvivorBot_GrenadeInfectedCount[iClient] < RoundFloat(iThrowCount * 0.33))
		{
			return true;
		}

		int iChaseEnt = INVALID_ENT_REFERENCE;
		float fItRange = (g_fCvar_ChaseBileRange*g_fCvar_ChaseBileRange);
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "info_goal_infected_chase")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > fItRange)continue;
			return true;
		}

		iChaseEnt = INVALID_ENT_REFERENCE;
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "pipe_bomb_projectile")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > 1048576.0)continue;
			return true;
		}
	}

	if (iGrenadeType == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientSurvivor(i) || !L4D_IsPlayerBoomerBiled(i))continue;
			return true;
		}
	}

	return false;
}

void CalculateTrajectory(float fStartPos[3], float fEndPos[3], float fVelocity, float fGravityScale = 1.0, float fResult[3])
{
	MakeVectorFromPoints(fStartPos, fEndPos, fResult);
	fResult[2] = 0.0;

	float fPos_X = GetVectorLength(fResult);
	float fPos_Y = fEndPos[2] - fStartPos[2];

	float fGravity = (g_fCvar_ServerGravity * fGravityScale);

	float fSqrtCalc1 = (fVelocity * fVelocity * fVelocity * fVelocity);
	float fSqrtCalc2 = fGravity * ((fGravity * (fPos_X * fPos_X)) + (2.0 * fPos_Y * (fVelocity * fVelocity)));

	float fCalcSum = (fSqrtCalc1 - fSqrtCalc2);	
	if (fCalcSum < 0.0)fCalcSum = FloatAbs(fCalcSum);

	float fAngSqrt = SquareRoot(fCalcSum);
	float fAngPos = ArcTangent(((fVelocity * fVelocity) + fAngSqrt) / (fGravity * fPos_X));
	float fAngNeg = ArcTangent(((fVelocity * fVelocity) - fAngSqrt) / (fGravity * fPos_X));

	float fPitch = ((fAngPos > fAngNeg) ? fAngNeg : fAngPos);
	fResult[2] = (Tangent(fPitch) * fPos_X);

	NormalizeVector(fResult, fResult);
	ScaleVector(fResult, fVelocity);
}

float GetCommonInfectedDamage()
{
	switch(GetCurrentGameDifficulty())
	{
		case 1:	return 1.0;
		case 3:	return 5.0;
		case 4: return 20.0;
		default: return 2.0;
	}
}

int GetCommonHitsUntilDown(int iClient, float fScale = 1.0)
{
	int iHits = RoundToFloor((GetClientRealHealth(iClient) / GetCommonInfectedDamage()) * fScale);
	if (iHits < 1)iHits = 1;
	return iHits;
}

float GetClientMaxSpeed(int iClient)
{
	return (GetEntPropFloat(iClient, Prop_Send, "m_flMaxspeed") * GetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue"));
}

bool PressAttackButton(int iClient, int &buttons, float fFireRate = -1.0)
{
	if (g_bClient_IsFiringWeapon[iClient])
		return false;
	
	static int iWeapon, iPistol;
	static float fClampDist, fCycleTime, fNextFireT, fAimPos[3];
	static L4D2WeaponId iWeaponID;
	iWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (iWeapon == -1)return false;

	if (IsFakeClient(iClient) && (g_bCvar_BotsDontShoot || g_bSurvivorBot_PreventFire[iClient]))
		return false;

	iWeaponID = view_as<L4D2WeaponId>(g_iWeaponID[iWeapon]);
	fNextFireT = fFireRate;
	iPistol = (iWeaponID == L4D2WeaponId_Pistol ? 1 : iWeaponID == L4D2WeaponId_PistolMagnum ? 2 : 0);
	if (fNextFireT <= 0.0 && (iPistol != 0 || GetWeaponTier(iWeapon) > 0))
	{
		fCycleTime = GetWeaponCycleTime(iWeapon);
		if (iPistol == 1 && g_iClientInvFlags[iClient] & FLAG_PISTOL_EXTRA)
			fCycleTime *= 2.5;
		GetClientAimPosition(iClient, fAimPos);

		fClampDist = 1800.0;
		if (iPistol == 2)
			fClampDist *= 0.5;
		else if (GetEntProp(iWeapon, Prop_Send, "m_upgradeBitVec") & L4D2_WEPUPGFLAG_LASER)
			fClampDist *= 2.0;

		fNextFireT = (fCycleTime * (GetVectorDistance(g_fClientEyePos[iClient], fAimPos) / fClampDist));
	}

	if (fNextFireT < GetGameFrameTime())
	{
		if (g_bIsSemiAuto[iWeaponID])
			fNextFireT = GetGameFrameTime();
	}

	if (fNextFireT <= 0.0 || GetGameTime() > g_fSurvivorBot_NextPressAttackTime[iClient])
	{
		if (GetWeaponClip1(iWeapon) > 0)g_fSurvivorBot_BlockWeaponReloadTime[iClient] = GetGameTime() + 2.0;
		buttons |= IN_ATTACK;
		g_bClient_IsFiringWeapon[iClient] = true;
		g_fSurvivorBot_NextPressAttackTime[iClient] = GetGameTime() + fNextFireT;
		return true;
	}
	return false;
}

int GetWeaponAmmoType(int iWeapon)
{
	if (!HasEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType"))return -1;
	return (GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType"));
}

int GetClientPrimaryAmmo(int iClient)
{	
	int iPrimaryWeapon = GetClientWeaponInventory(iClient, 0);
	if (iPrimaryWeapon == -1)return -1;

	int iAmmoType = GetWeaponAmmoType(iPrimaryWeapon);
	if (iAmmoType == -1)return -1;

	return (GetEntProp(iClient, Prop_Send, "m_iAmmo", _, iAmmoType));
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
	if (IsFakeClient(victim) && GetGameTime() >= g_fSurvivorBot_VomitBlindedTime[victim])
		g_fSurvivorBot_VomitBlindedTime[victim] = GetGameTime() + g_fCvar_BotsVomitBlindTime;

	return Plugin_Continue;
}

public Action L4D2_OnHitByVomitJar(int victim, int &attacker)
{
	float fInterval = 180.0;
	if (IsSpecialInfected(victim))
		fInterval = (IsFakeClient(victim) ? g_fCvar_BileCoverDuration_Bot : g_fCvar_BileCoverDuration_PZ);

	g_fInfectedBot_CoveredInVomitTime[victim] = GetGameTime() + fInterval;
	return Plugin_Continue;
}

bool L4D_IsPlayerBoomerBiled(int iClient)
{
	return (GetGameTime() <= GetEntPropFloat(iClient, Prop_Send, "m_itTimer", 1));
}

bool L4D2_IsUnderAdrenalineEffect(int iClient)
{
	return (!!GetEntProp(iClient, Prop_Send, "m_bAdrenalineActive"));
}

public Action L4D2_OnFindScavengeItem(int iClient, int &iItem)
{
	if (!IsEntityExists(iItem))
		return Plugin_Continue;
	
	static bool bIsValidScavenge;
	static int iPrimarySlot, iPrimaryAmmo, iTier3Primary, iSecondarySlot, iItemFlags, iScavengeItem, iItemTier, iWpnTier, iBotPreference;
	static char sWeaponName[64];
	
	sWeaponName[0] = EOS;
	GetEntityClassname(iItem, sWeaponName, sizeof(sWeaponName));
	iItemTier = GetWeaponTier(iItem);
	if (!strcmp(sWeaponName, "weapon_spawn") && (g_iWeaponID[iItem] <= 0 || iItemTier == -1))
	{
		float fItemPos[3];
		GetEntityAbsOrigin(iItem, fItemPos);
		PrintToServer("OnFindScavengeItem: %d %s wepid %d tier %d\npos %.2f %.2f %.2f", iItem, sWeaponName, g_iWeaponID[iItem], iItemTier, fItemPos[0], fItemPos[1], fItemPos[2]);
		CheckEntityForStuff(iItem, sWeaponName);
		return Plugin_Handled;
	}
	
	iItemFlags = g_iItemFlags[iItem];
	if (g_bCvar_SwitchOffCSSWeapons && iItemFlags & FLAG_CSS)
		return Plugin_Handled;
	
	iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	iTier3Primary = SurvivorHasTier3Weapon(iClient);
	iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	bIsValidScavenge = (iScavengeItem != -1 && IsValidEntity(iScavengeItem));
	iPrimaryAmmo = 0;
	if (iPrimarySlot != -1)
		iPrimaryAmmo = g_iWeapon_Clip1[iPrimarySlot] + g_iWeapon_AmmoLeft[iPrimarySlot];
	
	if(g_bCvar_Debug)
	{
		char sClientName[128], sEntClass[64], sEntClassname[64];
		GetClientName(iClient, sClientName, sizeof(sClientName));
		if (iPrimarySlot != -1)
			strcopy( sEntClass, 64, IBWeaponName[g_iWeaponID[iPrimarySlot]] );
		if (bIsValidScavenge)
			GetEntityClassname(iScavengeItem, sEntClassname, sizeof(sEntClassname));
		PrintToServer("OnFindScavengeItem: %s has %s ammo %d, goes for %s weapon ID %d, ScavengeItem %s", sClientName, sEntClass, iPrimaryAmmo, sWeaponName, g_iWeaponID[iItem], sEntClassname);
	}
	
	if (IsEntityExists(iPrimarySlot))
	{
		iItemTier = GetWeaponTier(iItem);
		if ( iItemTier > 0 && bIsValidScavenge && (g_iWeaponID[iScavengeItem] == 54 || GetWeaponTier(iScavengeItem) > 0) ) // L4D2WeaponId_Ammo = 54
			return Plugin_Handled;
		
		iWpnTier = GetWeaponTier(iPrimarySlot);
		iBotPreference = GetSurvivorBotWeaponPreference(iClient);
		if (iBotPreference != 0)
		{
			if ( !iTier3Primary && (iWpnTier == 2 || iWpnTier == 1 && iBotPreference == L4D_WEAPON_PREFERENCE_SMG) && WeaponHasEnoughAmmoLeft(iPrimarySlot))
			{
				if (iBotPreference != L4D_WEAPON_PREFERENCE_ASSAULTRIFLE && iItemFlags & FLAG_ASSAULT)
					return Plugin_Handled;
				if (iBotPreference != L4D_WEAPON_PREFERENCE_SHOTGUN && iItemFlags & FLAG_SHOTGUN && iItemFlags & FLAG_TIER2)
					return Plugin_Handled;
				if (iBotPreference != L4D_WEAPON_PREFERENCE_SNIPERRIFLE && iItemFlags & FLAG_SNIPER)
					return Plugin_Handled;
			}
		}
		if(g_bCvar_Debug)
			PrintToServer("WeaponHasEnoughAmmoLeft %b ItemTier %d", WeaponHasEnoughAmmoLeft(iPrimarySlot), iItemTier);
		
		if ( iItemTier > 0 && iPrimaryAmmo >= g_iWeapon_MaxAmmo[iPrimarySlot] * 0.25
			&& (iTier3Primary == 1 && GetSurvivorTeamInventoryCount(FLAG_GL) <= g_iCvar_MaxWeaponTier3_GLauncher
			|| iTier3Primary == 2 && GetSurvivorTeamInventoryCount(FLAG_M60) <= g_iCvar_MaxWeaponTier3_M60) )
		{
			return Plugin_Handled;
		}
		else if (iItemTier != 0 && GetClientPrimaryAmmo(iClient) < GetWeaponMaxAmmo(iPrimarySlot))
		{
			int iAmmoPileItem = GetItemFromArrayList(g_hAmmopileList, iClient, 1024.0, _, _, _, false);
			if (iAmmoPileItem != -1)
				return Plugin_Handled;
		}
	}

	iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	if (IsEntityExists(iSecondarySlot))
	{
		// if i have magnum and prefer it to pistol
		if ( iItemFlags & FLAG_PISTOL && g_bCvar_BotWeaponPreference_ForceMagnum && SurvivorHasPistol(iClient) == 3 )
			return Plugin_Handled;
		
		// if it's melee AND i don't have melee AND team has enough melee OR i have chainsaw AND not too many chainsaw/melee in team
		if ( iItemFlags & FLAG_MELEE && (~g_iClientInvFlags[iClient] & FLAG_MELEE && ( GetSurvivorTeamInventoryCount(FLAG_MELEE) >= g_iCvar_MaxMeleeSurvivors )
			|| g_iClientInvFlags[iClient] & FLAG_CHAINSAW && GetSurvivorTeamInventoryCount(FLAG_CHAINSAW) <= g_iCvar_ImprovedMelee_ChainsawLimit) )
			return Plugin_Handled;
			
		// if it's pistols AND i have chainsaw AND it has fuel AND not too many chainsaw in team
		if ( iItemFlags & (FLAG_PISTOL | FLAG_PISTOL_EXTRA) && g_iClientInvFlags[iClient] & FLAG_CHAINSAW
			&& GetSurvivorTeamInventoryCount(FLAG_CHAINSAW) <= g_iCvar_ImprovedMelee_ChainsawLimit
			&& g_iWeapon_Clip1[iSecondarySlot] > RoundFloat(GetWeaponMaxAmmo(iSecondarySlot) * 0.25) )
			return Plugin_Handled;
	}

	if ( IsWeaponSlotActive(iClient, 3) && iItemFlags & (FLAG_MEDKIT | FLAG_DEFIB) && g_iClientInvFlags[iClient] & FLAG_UPGRADE )
		return Plugin_Handled;

	if ( iItemFlags & FLAG_MEDKIT && IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && g_iClientInvFlags[iClient] & FLAG_DEFIB )
		return Plugin_Handled;

	return Plugin_Continue;
}

bool WeaponHasEnoughAmmoLeft(int iWeapon)
{
	return (g_iWeapon_MaxAmmo[iWeapon] > 0 && (g_iWeapon_AmmoLeft[iWeapon] + g_iWeapon_Clip1[iWeapon]) >= RoundFloat(g_iWeapon_MaxAmmo[iWeapon] * 0.33));
}

stock bool IsEntityWeapon(int iEntity, bool bNoSpawn = false)
{
	if (!IsEntityExists(iEntity))
		return false;

	char sEntClass[64]; GetWeaponClassname(iEntity, sEntClass, sizeof(sEntClass));
	if (strcmp(sEntClass, "predicted_viewmodel") == 0 || bNoSpawn && strcmp(sEntClass, "weapon_spawn") == 0)
		return false;

	ReplaceString(sEntClass, sizeof(sEntClass), "_spawn", "", false);
	return (L4D2_IsValidWeaponName(sEntClass));
}

int CheckForItemsToScavenge(int iClient)
{
	static int iItem, iArrayItem, iItemBits, iItemFlags, iPrimarySlot, iTier3Primary, iMinAmmo, iSecondarySlot, iMeleeCount, iChainsawCount, iMeleeType, iGrenadeSlot, iGrenadeTypeLimit, iWpnPreference;

	ArrayList hItemList = new ArrayList();

	iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	iGrenadeSlot = GetClientWeaponInventory(iClient, 2);
	iTier3Primary = SurvivorHasTier3Weapon(iClient);
	iWpnPreference = GetSurvivorBotWeaponPreference(iClient);
	iItem = -1;
	iItemBits = g_iCvar_ItemScavenge_Items;
	
	if (iItemBits & PICKUP_PRIMARY && iPrimarySlot == -1)	// if can pick primary AND no primary
	{
		iArrayItem = GetItemFromArrayList(g_hAssaultRifleList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hShotgunT2List, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hSniperRifleList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hShotgunT1List, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hSMGList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if ( iWpnPreference && iWpnPreference != L4D_WEAPON_PREFERENCE_SECONDARY && !iTier3Primary )
	{
		ArrayList hWeaponList;
		bool bHasWep = false;

		switch(iWpnPreference)
		{
			case L4D_WEAPON_PREFERENCE_ASSAULTRIFLE:
			{
				hWeaponList = g_hAssaultRifleList;
				bHasWep = SurvivorHasAssaultRifle(iClient);
			}
			case L4D_WEAPON_PREFERENCE_SHOTGUN:
			{
				hWeaponList = g_hShotgunT2List;
				bHasWep = SurvivorHasShotgun(iClient) > 1;
			}
			case L4D_WEAPON_PREFERENCE_SNIPERRIFLE:
			{
				hWeaponList = g_hSniperRifleList;
				bHasWep = SurvivorHasSniperRifle(iClient);
			}
			case L4D_WEAPON_PREFERENCE_SMG:
			{
				hWeaponList = g_hSMGList;
				bHasWep = SurvivorHasSMG(iClient);
			}
		}

		if (!bHasWep && iItemBits & PICKUP_PRIMARY || GetWeaponTier(iPrimarySlot) == 1 && iWpnPreference != L4D_WEAPON_PREFERENCE_SMG)
		{
			iArrayItem = GetItemFromArrayList(hWeaponList, iClient);
			if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
			{
				hItemList.Push(iArrayItem);
			}
		}
	}

	if (iWpnPreference != L4D_WEAPON_PREFERENCE_SECONDARY)
	{
		if ( !iTier3Primary && GetSurvivorTeamInventoryCount(FLAG_GL) < g_iCvar_MaxWeaponTier3_GLauncher )
		{
			iArrayItem = GetItemFromArrayList(g_hTier3List, iClient, _, 21); // L4D2WeaponId_GrenadeLauncher
			if (iArrayItem != -1)
			{
				hItemList.Push(iArrayItem);
			}
		}

		if ( !iTier3Primary && GetSurvivorTeamInventoryCount(FLAG_M60) < g_iCvar_MaxWeaponTier3_M60 )
		{
			iArrayItem = GetItemFromArrayList(g_hTier3List, iClient, _, 37); // L4D2WeaponId_RifleM60
			if (iArrayItem != -1)
			{
				hItemList.Push(iArrayItem);
			}
		}
	}

	if ( iItemBits & PICKUP_DEFIB && GetClientWeaponInventory(iClient, 3) == -1 || IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && !(g_iClientInvFlags[iClient] & FLAG_DEFIB) )
	{
		iArrayItem = GetItemFromArrayList(g_hDefibrillatorList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (GetClientWeaponInventory(iClient, 3) == -1)
	{
		iArrayItem = (~iItemBits & PICKUP_MEDKIT ? -1 : GetItemFromArrayList(g_hFirstAidKitList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = (~iItemBits & PICKUP_UPGRADE ? -1 : GetItemFromArrayList(g_hUpgradePackList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (GetClientWeaponInventory(iClient, 4) == -1)
	{
		iArrayItem = (~iItemBits & PICKUP_PILLS ? -1 : GetItemFromArrayList(g_hPainPillsList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = (~iItemBits & PICKUP_ADREN ? -1 : GetItemFromArrayList(g_hAdrenalineList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (iGrenadeSlot == -1)
	{
		iArrayItem = ((iItemBits & PICKUP_PIPE) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, 14) : -1); // L4D2WeaponId_PipeBomb
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = ((iItemBits & PICKUP_MOLO) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, 13) : -1); // L4D2WeaponId_Molotov
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = ((iItemBits & PICKUP_BILE) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, 25) : -1); // L4D2WeaponId_Vomitjar
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}
	else if (g_bCvar_SwapSameTypeGrenades)
	{
		iGrenadeTypeLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_GREN) * 0.55);
		if (iGrenadeTypeLimit < 1)iGrenadeTypeLimit = 1;

		if (GetSurvivorTeamItemCount(L4D2_GetWeaponId(iGrenadeSlot)) > iGrenadeTypeLimit)
		{
			iArrayItem = GetItemFromArrayList(g_hGrenadeList, iClient, _, -g_iWeaponID[iGrenadeSlot]);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
	}
	
	iMinAmmo = 0;
	if (iPrimarySlot != -1)
	{
		iItemFlags = g_iItemFlags[iPrimarySlot];
		iMinAmmo = GetWeaponMaxAmmo(iPrimarySlot);
		
		if (iItemBits & PICKUP_AMMO && (!iTier3Primary || iTier3Primary & g_iCvar_T3_Refill))	// if can pick up ammo
		{
			if (!L4D_IsInFirstCheckpoint(iClient))
				iMinAmmo = RoundFloat(iMinAmmo * ((!LBI_IsSurvivorInCombat(iClient) && !L4D_HasVisibleThreats(iClient)) ? 0.75 : 0.5));
		
			//if(g_bCvar_Debug)
			//{
			//	char sClientName[128];
			//	GetClientName(iClient, sClientName, sizeof(sClientName));
			//	PrintToServer("%s iMinAmmo %d primary ammo %d", sClientName, iMinAmmo, GetClientPrimaryAmmo(iClient));
			//}
		
			if (GetClientPrimaryAmmo(iClient) < iMinAmmo)
			{
				iArrayItem = GetItemFromArrayList(g_hAmmopileList, iClient);
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}
		}
		
		if (g_bCvar_SwapSameTypePrimaries && !iTier3Primary)
		{
			if (iWpnPreference != L4D_WEAPON_PREFERENCE_SMG)
			{
				int iSMGCount = GetSurvivorTeamInventoryCount(FLAG_SMG);
				int iShotgunCount = GetSurvivorTeamInventoryCount(FLAG_SHOTGUN, FLAG_TIER1);

				int iTier1Limit = RoundToCeil((iSMGCount + iShotgunCount) * 0.5);
				if (iTier1Limit < 1)iTier1Limit = 1;

				if ( iShotgunCount > iTier1Limit && iItemFlags & FLAG_SHOTGUN && iItemFlags & FLAG_TIER1 )
				{
					iArrayItem = GetItemFromArrayList(g_hSMGList, iClient);
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}
				}
				else if ( iSMGCount > iTier1Limit && iItemFlags & FLAG_SMG )
				{
					iArrayItem = GetItemFromArrayList(g_hShotgunT1List, iClient);
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}
				}
			}

			int iPrimaryCount = GetSurvivorTeamItemCount(L4D2_GetWeaponId(iPrimarySlot));
			int iWepLimit = -1;
			ArrayList hWepArray;
			if (SurvivorHasShotgun(iClient))
			{
				hWepArray = g_hShotgunT2List;
				iWepLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_SHOTGUN, FLAG_TIER2) * 0.5);
			}
			else if (SurvivorHasAssaultRifle(iClient))
			{
				hWepArray = g_hAssaultRifleList;
				iWepLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_ASSAULT) * 0.5);
			}
			else if (SurvivorHasSniperRifle(iClient))
			{
				hWepArray = g_hSniperRifleList;
				iWepLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_SNIPER) * 0.5);
			}
			if (iWepLimit != -1 && iWepLimit < 1)iWepLimit = 1;

			if (iPrimaryCount > iWepLimit)
			{
				iArrayItem = GetItemFromArrayList(hWepArray, iClient, _, -g_iWeaponID[iPrimarySlot]);
				if (iArrayItem != -1 && (WeaponHasEnoughAmmoLeft(iArrayItem) || IsWeaponNearAmmoPile(iArrayItem, iClient)))
				{
					hItemList.Push(iArrayItem);
				}
			}
		}

		int iUpgradeBits = GetEntProp(iPrimarySlot, Prop_Send, "m_upgradeBitVec");
		if (~iUpgradeBits & L4D2_WEPUPGFLAG_LASER && iItemBits & PICKUP_LASER)
		{
			iArrayItem = GetItemFromArrayList(g_hLaserSightList, iClient);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
		if ( iItemBits & PICKUP_AMMOPACK && !(iUpgradeBits & (L4D2_WEPUPGFLAG_INCENDIARY|L4D2_WEPUPGFLAG_EXPLOSIVE)) )
		{
			iArrayItem = GetItemFromArrayList(g_hDeployedAmmoPacks, iClient);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
	}

	if (iSecondarySlot != -1)
	{
		iMeleeCount = GetSurvivorTeamInventoryCount(FLAG_MELEE, -FLAG_CHAINSAW);
		iChainsawCount = GetSurvivorTeamInventoryCount(FLAG_CHAINSAW);
		iMeleeType = SurvivorHasMeleeWeapon(iClient);

		if (iMeleeType != 0)
		{
			// look for chainsaw
			if (iMeleeType != 2)
			{
				if (iItemBits & PICKUP_CHAINSAW && (iMeleeCount + iChainsawCount) <= g_iCvar_MaxMeleeSurvivors && iChainsawCount < g_iCvar_ImprovedMelee_ChainsawLimit)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 20); // L4D2WeaponId_Chainsaw
					if (iArrayItem != -1 && g_iWeapon_Clip1[iArrayItem] > RoundFloat(GetWeaponMaxAmmo(iArrayItem) * 0.25))
					{
						hItemList.Push(iArrayItem);
					}
				}
			}
			// look for low fuel chainsaw replacement
			else if ( iMeleeType == 2 && (iChainsawCount > g_iCvar_ImprovedMelee_ChainsawLimit || g_iWeapon_Clip1[iSecondarySlot] <= RoundFloat(GetWeaponMaxAmmo(iSecondarySlot) * 0.25)) )
			{
				bool bFoundMelee = false;
				if (iMeleeCount < g_iCvar_MaxMeleeSurvivors)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 19); // L4D2WeaponId_Melee
					if (iArrayItem != -1)
					{
						bFoundMelee = true;
						hItemList.Push(iArrayItem); 
					}
				}
				if (!bFoundMelee)
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient);
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				}
			}

			if ((iMeleeCount + iChainsawCount) > g_iCvar_MaxMeleeSurvivors && (iMeleeType != 2 || iChainsawCount > g_iCvar_ImprovedMelee_ChainsawLimit))
			{
				iArrayItem = GetItemFromArrayList(g_hPistolList, iClient);
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}
		}
		else if (iItemBits & PICKUP_SECONDARY)
		{
			if ((iMeleeCount + iChainsawCount) < g_iCvar_MaxMeleeSurvivors)
			{
				iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 19); // L4D2WeaponId_Melee
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}
			
			int iHasPistol = SurvivorHasPistol(iClient);
			if ( iHasPistol != 0 )
			{
				if ( g_bCvar_BotWeaponPreference_ForceMagnum && iHasPistol != 3 || GetSurvivorTeamItemCount(L4D2WeaponId_PistolMagnum) == 0 )
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient, _, 32); // L4D2WeaponId_PistolMagnum
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				}
				else if ( iHasPistol == 1 )
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient, _, 1); // L4D2WeaponId_Pistol
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				} 
			}
		}
	}

	if (hItemList.Length > 0)
	{
		int iCurItem;
		float fCurDist;
		float fLastDist = -1.0;
		for (int i = 0; i < hItemList.Length; i++)
		{
			iCurItem = hItemList.Get(i);
			fCurDist = GetClientDistanceToItem(iClient, iCurItem, true);
			if (fLastDist != -1.0 && fCurDist >= fLastDist)continue;

			iItem = iCurItem;
			fLastDist = fCurDist;
		}
		g_fSurvivorBot_ScavengeItemDist[iClient] = fLastDist;
	}
	delete hItemList;
	
	if(g_bCvar_Debug && iItem != -1)
	{
		char sEntClassname[64],sClientName[128];
		GetClientName(iClient, sClientName, sizeof(sClientName));
		if(iItem != -1)
			GetEntityClassname(iItem, sEntClassname, sizeof(sEntClassname));
		PrintToServer( "CheckForItemsToScavenge: %s MinAmmo %d Ammo %d HasTier3 %d iItem %d %s", sClientName,
		iMinAmmo, GetClientPrimaryAmmo(iClient), iTier3Primary, iItem, sEntClassname );
	}
	
	return iItem;
}

int GetSurvivorBotWeaponPreference(int iClient)
{
	switch(GetClientSurvivorType(iClient))
	{
		case L4D_SURVIVOR_ROCHELLE:	return g_iCvar_BotWeaponPreference_Rochelle;
		case L4D_SURVIVOR_COACH:	return g_iCvar_BotWeaponPreference_Coach;
		case L4D_SURVIVOR_ELLIS:	return g_iCvar_BotWeaponPreference_Ellis;
		case L4D_SURVIVOR_BILL:		return g_iCvar_BotWeaponPreference_Bill;
		case L4D_SURVIVOR_ZOEY:		return g_iCvar_BotWeaponPreference_Zoey;
		case L4D_SURVIVOR_FRANCIS:	return g_iCvar_BotWeaponPreference_Francis;
		case L4D_SURVIVOR_LOUIS:	return g_iCvar_BotWeaponPreference_Louis;
		default:					return g_iCvar_BotWeaponPreference_Nick;
	}
}

int GetPinnedSurvivorCount()
{
	int iCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || !L4D_IsPlayerPinned(i))continue;
		iCount++;
	}
	return iCount;
}

int ItemSpawnerHasEnoughItems(int iSpawner)
{
	return (!HasEntProp(iSpawner, Prop_Data, "m_itemCount") ? 9999 : GetEntProp(iSpawner, Prop_Data, "m_itemCount"));
}

bool IsWeaponNearAmmoPile(int iWeapon, int iOwner = -1)
{
	int iAmmoPile = GetItemFromArrayList(g_hAmmopileList, iWeapon, _, _, _, false);
	return (iAmmoPile != -1 && (iOwner == -1 || LBI_IsReachableEntity(iOwner, iAmmoPile)));
}

// 4th argument is now a number instead of a string
// if number >0, look for a specific weapon ID
// if number is negative, particular weapon ID is skipped/avoided
// check for sModelName is never used, let's keep it that way ;)
int GetItemFromArrayList(ArrayList hArrayList, int iClient, float fDistance = -1.0, int iWeaponID = 0, const char[] sModelName = "", bool bCheckIsReachable = true, bool bCheckIsVisible = true)
{
	if (!hArrayList || hArrayList.Length <= 0)return -1;
	if (fDistance == -1.0)fDistance = g_fCvar_ItemScavenge_ApproachVisibleRange;

	static float fCheckDist, fCurDist, fPickupRange, fClientPos[3], fEntityPos[3];
	static int iEntRef, iEntIndex, iNavArea, iUseCount, iItemFlags;
	static bool bIsCoop, bInCheckpoint, bIsTaken, bInUseRange, bValidClient;

 	//char sWeaponName[MAX_TARGET_LENGTH];
	static char sEntityModel[PLATFORM_MAX_PATH];

	GetEntityAbsOrigin(iClient, fClientPos);
	bValidClient = IsValidClient(iClient);
	if (bValidClient)
	{
		bIsCoop = L4D2_IsGenericCooperativeMode(); 
		bInCheckpoint = LBI_IsPositionInsideCheckpoint(g_fClientAbsOrigin[iClient]);
		fPickupRange = g_fCvar_ItemScavenge_PickupRange_Sqr;
	}

	for (int i = 0; i < hArrayList.Length; i++)
	{
		iEntRef = hArrayList.Get(i);
		
		if (g_hForbiddenItemList.FindValue(iEntRef) != -1)
		{
			//if(g_bCvar_Debug)
			//{
			//	iEntIndex = EntRefToEntIndex(iEntRef);
			//	PrintToServer("Will not allow snatching %s", IBWeaponName[g_iWeaponID[iEntIndex]]);
			//}
			continue;
		}
		
		iEntIndex = EntRefToEntIndex(iEntRef);
		if (iEntIndex == INVALID_ENT_REFERENCE || IsValidClient(GetEntityOwner(iEntIndex)))
			continue;
		
		iItemFlags = g_iItemFlags[iEntIndex];
		if (g_bCvar_SwitchOffCSSWeapons && iItemFlags & FLAG_CSS)
			continue;

		iUseCount = ItemSpawnerHasEnoughItems(iEntIndex);
		if (iUseCount == 0)continue;

		if (!GetEntityAbsOrigin(iEntIndex, fEntityPos) || GetVectorDistance(fClientPos, fEntityPos, true) > g_fCvar_ItemScavenge_MapSearchRange_Sqr)
			continue;

		if (sModelName[0] != 0)
		{
			GetEntityModelname(iEntIndex, sEntityModel, sizeof(sEntityModel));
			if (strcmp(sEntityModel, sModelName, false) != 0)continue;
		}
		
		//if(g_bCvar_Debug)
		//	PrintToServer("%s %b",IBWeaponName[g_iWeaponID[iEntIndex]], iItemFlags);
	
		//skip if ammo upgrade is already used
		if ( g_iItem_Used[iEntIndex] & (1 << (iClient - 1)) && iItemFlags & FLAG_AMMO && iItemFlags & FLAG_UPGRADE )
			continue;
		
		//skip if weapon ID is avoided
		if ( iWeaponID < 0 && g_iWeaponID[iEntIndex] == -iWeaponID )
			continue;
		
		//skip if WRONG weapon ID
		if ( iWeaponID > 0 && g_iWeaponID[iEntIndex] != iWeaponID )
			continue;
		
		fCheckDist = fDistance; 
		if (bValidClient)
		{
			if ( GetWeaponTier(iEntIndex) > 0 && (g_iWeapon_Clip1[iEntIndex] + g_iWeapon_AmmoLeft[iEntIndex]) <= g_iWeapon_MaxAmmo[iEntIndex] * 0.25 )
				continue;

			if ( iUseCount == 1 && iItemFlags & FLAG_AMMO )
			{
				bIsTaken = false;
				for (int j = 1; j <= MaxClients; j++)
				{
					if (j == iClient || !IsClientSurvivor(j) || !IsFakeClient(j) || iEntIndex != g_iSurvivorBot_ScavengeItem[j] || !IsEntityExists(g_iSurvivorBot_ScavengeItem[j]))
						continue;

					bIsTaken = true;
					break;
				}
				if (bIsTaken)continue;
			}

			bInUseRange = (GetVectorDistance(g_fClientEyePos[iClient], fEntityPos, true) <= fPickupRange);
			if (!bInUseRange)
			{
				if (bIsCoop && bInCheckpoint && !LBI_IsPositionInsideCheckpoint(fEntityPos))
					continue;

				if (bCheckIsReachable && !LBI_IsReachableEntity(iClient, iEntIndex))
					continue;

				if (bCheckIsVisible && fDistance > g_fCvar_ItemScavenge_ApproachRange)
				{ 
					iNavArea = L4D_GetNearestNavArea(fEntityPos, _, true, true, false);
					if (iNavArea && !LBI_IsNavAreaPartiallyVisible(iNavArea, g_fClientEyePos[iClient], iClient))
					{
						fCheckDist = g_fCvar_ItemScavenge_ApproachRange;
					}
				}
			}
		}

		fCurDist = GetVectorDistance(fClientPos, fEntityPos, true);
		if (!bInUseRange && fCurDist > (fCheckDist*fCheckDist))continue;

		return iEntIndex;
	}

	return -1;
}

int GetEntityOwner(int iEntity)
{
	int iOwner = GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity");
	if (!IsClientSurvivor(iOwner) || L4D_GetPlayerCurrentWeapon(iOwner) == iEntity)
		return iOwner;

	for (int i = 0; i <= 5; i++)
	{
		if (GetClientWeaponInventory(iOwner, i) != iEntity)continue;
		return iOwner;
	}
	return -1;
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if (iEntity <= 0 || iEntity > MAXENTITIES)
		return;
		
	g_iItem_Used[iEntity] = 0; // Clear used item bitfield
	g_iWeaponID[iEntity] = 0;
	g_iItemFlags[iEntity] = 0;
	CheckEntityForStuff(iEntity, sClassname);
}

void CheckEntityForStuff(int iEntity, const char[] sClassname)
{
	static int iCheckCase;
	static int iItemFlags;
	static L4D2WeaponId iWeaponID;
	static char sWeaponName[64];
	
	if (!g_bInitCheckCases)
	{
		InitCheckCases();
		PrintToServer("CheckEntityForStuff: InitCheckCases");
	}
	
	if(!g_hCheckCases.GetValue(sClassname, iCheckCase))
		iCheckCase = 0;
	
	switch(iCheckCase)
	{
		case 1:	//witch
		{
			if (g_hWitchList)
			{
				int iWitchRef;
				for (int i = 0; i < g_hWitchList.Length; i++)
				{
					iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
					if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
					{
						g_hWitchList.Erase(i);
						continue;
					}
					if (iWitchRef == iEntity)return;
				}
		
				int iIndex = g_hWitchList.Push(EntIndexToEntRef(iEntity));
				g_hWitchList.Set(iIndex, 0, 1);
				SDKHook(iEntity, SDKHook_OnTakeDamage, OnWitchTakeDamage);
				return;
			}
		}
		
		case 2:	//ammo
		{
			PushEntityIntoArrayList(g_hAmmopileList, iEntity);
			g_iWeaponID[iEntity] = 54; // L4D2WeaponId_Ammo
			g_iItemFlags[iEntity] = FLAG_ITEM | FLAG_AMMO;
			return;
		}
		
		case 3:	//laser sight
		{
			PushEntityIntoArrayList(g_hLaserSightList, iEntity);
			return;
		}
		
		case 4:	//deployed ammo upgrade
		{
			PushEntityIntoArrayList(g_hDeployedAmmoPacks, iEntity);
			g_iWeaponID[iEntity] = 22; // L4D2WeaponId_AmmoPack, idk if this makes sense actually
			g_iItemFlags[iEntity] = FLAG_ITEM | FLAG_AMMO | FLAG_UPGRADE;
			return;
		}
		
		case 5:	//thrown pipebomb or bile
		{
			g_fSurvivorBot_Grenade_NextThrowTime = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
			return;
		}
		
		case 6:	//thrown molotov
		{
			g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
			return;
		}
	}
	
	if ( !GetWeaponClassname(iEntity, sWeaponName, sizeof(sWeaponName)) )
		return;
	
	iWeaponID = L4D2WeaponId_None;
	if (!g_bInitWeaponToIDMap)
	{
		InitWeaponToIDMap();
		PrintToServer("CheckEntityForStuff: InitWeaponToIDMap");
	}
	
	if(!g_hWeaponToIDMap.GetValue(sWeaponName, iWeaponID))
	{
		return;
	}
	g_iWeaponID[iEntity] = view_as<int>(iWeaponID);
	
	iItemFlags = 0;
	if (!g_bInitItemFlags)
	{
		InitItemFlagMap();
		PrintToServer("CheckEntityForStuff: InitItemFlagMap");
	}
	g_hItemFlagMap.GetValue(sWeaponName, iItemFlags);
	g_iItemFlags[iEntity] = iItemFlags;
	
	switch(iWeaponID)
	{
		case L4D2WeaponId_None: return;
		
		case L4D2WeaponId_Pistol, L4D2WeaponId_PistolMagnum:
			PushEntityIntoArrayList(g_hPistolList, iEntity);
		
		case L4D2WeaponId_Melee, L4D2WeaponId_Chainsaw:
			PushEntityIntoArrayList(g_hMeleeList, iEntity);
		
		case L4D2WeaponId_Smg, L4D2WeaponId_SmgSilenced, L4D2WeaponId_SmgMP5:
			PushEntityIntoArrayList(g_hSMGList, iEntity);
		
		case L4D2WeaponId_Pumpshotgun, L4D2WeaponId_ShotgunChrome:
			PushEntityIntoArrayList(g_hShotgunT1List, iEntity);
		
		case L4D2WeaponId_Rifle, L4D2WeaponId_RifleAK47, L4D2WeaponId_RifleDesert, L4D2WeaponId_RifleSG552:
			PushEntityIntoArrayList(g_hAssaultRifleList, iEntity);
		
		case L4D2WeaponId_Autoshotgun, L4D2WeaponId_ShotgunSpas:
			PushEntityIntoArrayList(g_hShotgunT2List, iEntity);
		
		case L4D2WeaponId_HuntingRifle, L4D2WeaponId_SniperMilitary, L4D2WeaponId_SniperScout, L4D2WeaponId_SniperAWP:
			PushEntityIntoArrayList(g_hSniperRifleList, iEntity);
		
		case L4D2WeaponId_PipeBomb, L4D2WeaponId_Molotov, L4D2WeaponId_Vomitjar:
			PushEntityIntoArrayList(g_hGrenadeList, iEntity);
		
		case L4D2WeaponId_RifleM60, L4D2WeaponId_GrenadeLauncher:
			PushEntityIntoArrayList(g_hTier3List, iEntity);
		
		case L4D2WeaponId_FragAmmo, L4D2WeaponId_IncendiaryAmmo:
			PushEntityIntoArrayList(g_hUpgradePackList, iEntity);
		
		case L4D2WeaponId_FirstAidKit:
			PushEntityIntoArrayList(g_hFirstAidKitList, iEntity);
		
		case L4D2WeaponId_Defibrillator:
			PushEntityIntoArrayList(g_hDefibrillatorList, iEntity);
		
		case L4D2WeaponId_PainPills:
			PushEntityIntoArrayList(g_hPainPillsList, iEntity);
		
		case L4D2WeaponId_Adrenaline:
			PushEntityIntoArrayList(g_hAdrenalineList, iEntity);
	}

	if (iWeaponID == L4D2WeaponId_Chainsaw)
	{
		g_iWeapon_Clip1[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iWeapon_MaxAmmo[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iWeapon_AmmoLeft[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		return;
	}
	
	if ( g_iWeaponTier[iWeaponID] != 0 )
	{
		g_iWeapon_Clip1[iEntity] = L4D2_GetIntWeaponAttribute(sWeaponName, L4D2IWA_ClipSize);
		g_iWeapon_MaxAmmo[iEntity] = GetWeaponMaxAmmo(iEntity);
		g_iWeapon_AmmoLeft[iEntity] = g_iWeapon_MaxAmmo[iEntity];
	}
}

public Action RecheckWeaponSpawn(Handle timer, int iEntity)
{
	if(!IsValidEdict(iEntity))
		return Plugin_Handled;
	
	char sEntClassname[64];
	GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
	CheckEntityForStuff(iEntity, sEntClassname);
	return Plugin_Handled;
}

bool ShouldUseFlowDistance()
{
	if (!L4D_IsSurvivalMode() && !L4D2_IsScavengeMode())
	{
		int iFinStage = L4D2_GetCurrentFinaleStage();
		return (iFinStage == 18 || iFinStage == 0);
	}

	return false;
}

void PushEntityIntoArrayList(ArrayList hArrayList, int iEntity)
{
	if (!hArrayList)return;
	int iEntRef = EntIndexToEntRef(iEntity);
	int iArrayEnt = hArrayList.FindValue(iEntRef);
	if (iArrayEnt == -1)hArrayList.Push(iEntRef);
}

public void OnEntityDestroyed(int iEntity)
{
	if (iEntity <= 0 || iEntity > MAXENTITIES) 
		return;
		
	g_iItem_Used[iEntity] = 0; // Clear used item bitfield
	g_iWeaponID[iEntity] = 0;
	g_iItemFlags[iEntity] = 0;

	CheckArrayListForEntityRemoval(g_hMeleeList, iEntity);
	CheckArrayListForEntityRemoval(g_hPistolList, iEntity);
	CheckArrayListForEntityRemoval(g_hSMGList, iEntity);
	CheckArrayListForEntityRemoval(g_hShotgunT1List, iEntity);
	CheckArrayListForEntityRemoval(g_hShotgunT2List, iEntity);
	CheckArrayListForEntityRemoval(g_hAssaultRifleList, iEntity);
	CheckArrayListForEntityRemoval(g_hSniperRifleList, iEntity);
	CheckArrayListForEntityRemoval(g_hTier3List, iEntity);
	CheckArrayListForEntityRemoval(g_hFirstAidKitList, iEntity);
	CheckArrayListForEntityRemoval(g_hDefibrillatorList, iEntity);
	CheckArrayListForEntityRemoval(g_hPainPillsList, iEntity);
	CheckArrayListForEntityRemoval(g_hAdrenalineList, iEntity);
	CheckArrayListForEntityRemoval(g_hGrenadeList, iEntity);
	CheckArrayListForEntityRemoval(g_hUpgradePackList, iEntity);

	CheckArrayListForEntityRemoval(g_hAmmopileList, iEntity);
	CheckArrayListForEntityRemoval(g_hLaserSightList, iEntity);
	CheckArrayListForEntityRemoval(g_hDeployedAmmoPacks, iEntity);
	CheckArrayListForEntityRemoval(g_hForbiddenItemList, iEntity);

	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSurvivorBot_VisionMemory_State[i][iEntity] = g_iSurvivorBot_VisionMemory_State_FOV[i][iEntity] = 0;
		g_fSurvivorBot_VisionMemory_Time[i][iEntity] = g_fSurvivorBot_VisionMemory_Time_FOV[i][iEntity] = GetGameTime();
	}
}

void CheckArrayListForEntityRemoval(ArrayList hArrayList, int iEntity)
{
	if (!hArrayList)return;
	int iArrayEnt = hArrayList.FindValue(EntIndexToEntRef(iEntity));
	if (iArrayEnt != -1)hArrayList.Erase(iArrayEnt);
}

public void OnMapStart()
{
	g_bMapStarted = true;
	GetCurrentMap(g_sCurrentMapName, sizeof(g_sCurrentMapName));
	for (int i = 1; i <= MaxClients; i++)g_fClient_ThinkFunctionDelay[i] = GetGameTime() + (g_bLateLoad ? 1.0 : 10.0);
	CreateEntityArrayLists();

	static char sEntClassname[64];
	for (int i = 0; i < MAXENTITIES; i++)
	{
		g_iItem_Used[i] = 0;
		g_iWeaponID[i] = 0;
		g_iItemFlags[i] = 0;
		if (!IsEntityExists(i))continue;
		GetEntityClassname(i, sEntClassname, sizeof(sEntClassname));
		CheckEntityForStuff(i, sEntClassname);
	}
}

void CheckWeaponsLater()
{
	static int iEntIndex;
	static char sEntClassname[64];
	
	int count = 0;
	int i = 0;
	while (i < g_hWeaponsToCheckLater.Length)
	{
		iEntIndex = EntRefToEntIndex(g_hWeaponsToCheckLater.Get(i));
		if (iEntIndex != INVALID_ENT_REFERENCE && IsEntityExists(iEntIndex))
		{
			GetEntityClassname(iEntIndex, sEntClassname, sizeof(sEntClassname));
			CheckEntityForStuff(iEntIndex, sEntClassname);
			if (g_iWeaponID[iEntIndex] != 0)
			{
				g_hWeaponsToCheckLater.Erase(i);
				count++;
			}
			else
			{
				PrintToServer("CheckWeaponsLater: %d %s still having weapon id of 0, stopping and checking again soon\nprocessed %d items", iEntIndex, sEntClassname, count);
				return;
			}
		}
		else
		{
			g_hWeaponsToCheckLater.Erase(i);
			count++;
		}
	}
	g_hCheckWeaponTimer = INVALID_HANDLE;
	PrintToServer("CheckWeaponsLater: list cleared, processed %d items", count);
}

public Action CheckWeaponsEvenLater(Handle timer)
{
	CheckWeaponsLater();
	return Plugin_Handled;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	g_sCurrentMapName[0] = 0;
	ClearEntityArrayLists();
	ClearHashMaps();
	
	g_bInitPathWithin = false;
	g_hClearBadPathTimer = INVALID_HANDLE;
	g_hCheckWeaponTimer = INVALID_HANDLE;
}

void CreateEntityArrayLists()
{
	g_hMeleeList 			= new ArrayList();
	g_hPistolList 			= new ArrayList();
	g_hSMGList 				= new ArrayList();
	g_hShotgunT1List 		= new ArrayList();
	g_hShotgunT2List 		= new ArrayList();
	g_hAssaultRifleList 	= new ArrayList();
	g_hSniperRifleList 		= new ArrayList();
	g_hTier3List 			= new ArrayList();
	g_hAmmopileList 		= new ArrayList();
	g_hUpgradePackList 		= new ArrayList();
	g_hLaserSightList 		= new ArrayList();
	g_hFirstAidKitList 		= new ArrayList();
	g_hDefibrillatorList 	= new ArrayList();
	g_hPainPillsList 		= new ArrayList();
	g_hAdrenalineList 		= new ArrayList();
	g_hGrenadeList 			= new ArrayList();
	g_hDeployedAmmoPacks 	= new ArrayList();
	g_hForbiddenItemList 	= new ArrayList(2);
	g_hWitchList 			= new ArrayList(2);
	g_hBadPathEntities 		= new ArrayList();
	g_hWeaponsToCheckLater 	= new ArrayList();
}

void ClearEntityArrayLists()
{
	g_hMeleeList.Clear();
	g_hPistolList.Clear();
	g_hSMGList.Clear();
	g_hShotgunT1List.Clear();
	g_hShotgunT2List.Clear();
	g_hAssaultRifleList.Clear();
	g_hSniperRifleList.Clear();
	g_hTier3List.Clear();
	g_hAmmopileList.Clear();
	g_hUpgradePackList.Clear();
	g_hLaserSightList.Clear();
	g_hFirstAidKitList.Clear();
	g_hDefibrillatorList.Clear();
	g_hPainPillsList.Clear();
	g_hAdrenalineList.Clear();
	g_hGrenadeList.Clear();
	g_hDeployedAmmoPacks.Clear();
	g_hForbiddenItemList.Clear();
	g_hWitchList.Clear();
	g_hBadPathEntities.Clear();
	g_hWeaponsToCheckLater.Clear();
}

void ClearHashMaps()
{
	if(g_hCheckCases != INVALID_HANDLE)
		g_hCheckCases.Clear();
	if(g_hItemFlagMap != INVALID_HANDLE)
		g_hItemFlagMap.Clear();
	if(g_hWeaponMap != INVALID_HANDLE)
		g_hWeaponMap.Clear();
	if(g_hWeaponMdlMap != INVALID_HANDLE)
		g_hWeaponMdlMap.Clear();
	if(g_hWeaponSpawnMap != INVALID_HANDLE)
		g_hWeaponSpawnMap.Clear();
	if(g_hWeaponToIDMap != INVALID_HANDLE)
		g_hWeaponToIDMap.Clear();
	
	g_bInitCheckCases = false;
	g_bInitMaxAmmo = false;
	g_bInitItemFlags = false;
	g_bInitWeaponMap = false;
	g_bInitWeaponMdlMap = false;
	g_bInitWeaponSpawnMap = false;
	g_bInitWeaponToIDMap = false;
}

void InitWeaponMdlMap()
{
	g_hWeaponMdlMap = CreateTrie();
	//melee
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_knife_t.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_bat.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_cricket_bat.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_crowbar.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_electric_guitar.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_fireaxe.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_frying_pan.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_golfclub.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_katana.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_machete.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_pitchfork.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_riotshield.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_shovel.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_tonfa.mdl", "wepon_melee");
	g_hWeaponMdlMap.SetString("models/weapons/melee/w_chainsaw.mdl", "weapon_chainsaw");
	
	//pisols
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_pistol_a.mdl", "weapon_pistol");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_pistol_a_dual.mdl", "weapon_pistol");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_pistol_b.mdl", "weapon_pistol");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_desert_eagle.mdl", "weapon_pistol_magnum");
	
	//smgs
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_smg_uzi.mdl", "weapon_smg");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_smg_a.mdl", "weapon_smg_silenced");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_smg_mp5.mdl", "weapon_smg_mp5");
	
	//tier 1 shotguns
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_pumpshotgun_a.mdl", "weapon_shotgun_chrome");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_shotgun.mdl", "weapon_pumpshotgun");
	
	//assault rifles
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_rifle_m16a2.mdl", "weapon_rifle");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_rifle_ak47.mdl", "weapon_rifle_ak47");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_desert_rifle.mdl", "weapon_rifle_desert");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_rifle_sg552.mdl", "weapon_rifle_sg552");
	
	//tier 2 shotguns
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_autoshot_m4super.mdl", "weapon_autoshotgun");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_shotgun_spas.mdl", "weapon_shotgun_spas");
	
	//sniper
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_sniper_mini14.mdl", "weapon_hunting_rifle");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_sniper_military.mdl", "weapon_sniper_military");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_sniper_scout.mdl", "weapon_sniper_scout");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_sniper_awp.mdl", "weapon_sniper_awp");
	
	//tier 3
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_grenade_launcher.mdl", "weapon_grenade_launcher");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_m60.mdl", "weapon_rifle_m60");
	
	//grenades
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_pipebomb.mdl", "weapon_pipe_bomb");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_molotov.mdl", "weapon_molotov");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_bile_flask.mdl", "weapon_vomitjar");
	
	//ammo
	g_hWeaponMdlMap.SetString("models/props/terror/ammo_stack.mdl", "weapon_ammo");
	g_hWeaponMdlMap.SetString("models/props_unique/spawn_apartment/coffeeammo.mdl", "weapon_ammo");
	
	//medical
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_medkit.mdl", "weapon_first_aid_kit");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_painpills.mdl", "weapon_pain_pills");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_defibrillator.mdl", "weapon_defibrillator");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_adrenaline.mdl", "weapon_adrenaline");
	
	//upgrade
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_incendiary_ammopack.mdl", "weapon_upgradepack_incendiary");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_eq_explosive_ammopack.mdl", "weapon_upgradepack_explosive");
	
	//carry props
	g_hWeaponMdlMap.SetString("models/props_junk/gascan001a.mdl", "weapon_gascan");
	g_hWeaponMdlMap.SetString("models/props_junk/propanecanister001a.mdl", "weapon_propanetank");
	g_hWeaponMdlMap.SetString("models/props_equipment/oxygentank01.mdl", "weapon_oxygentank");
	g_hWeaponMdlMap.SetString("models/props_junk/gnome.mdl", "weapon_gnome");
	g_hWeaponMdlMap.SetString("models/w_models/weapons/w_cola.mdl", "weapon_cola_bottles");
	g_hWeaponMdlMap.SetString("models/props_junk/explosive_box001.mdl", "weapon_fireworkcrate");
	
	g_bInitWeaponMdlMap = true;
}

void InitItemFlagMap()
{
	g_hItemFlagMap = CreateTrie();
	g_hItemFlagMap.SetValue("weapon_melee"			, FLAG_WEAPON | FLAG_MELEE );
	g_hItemFlagMap.SetValue("weapon_chainsaw"		, FLAG_WEAPON | FLAG_MELEE | FLAG_CHAINSAW);
	g_hItemFlagMap.SetValue("weapon_pistol"			, FLAG_WEAPON | FLAG_PISTOL );
	g_hItemFlagMap.SetValue("weapon_pistol_magnum"	, FLAG_WEAPON | FLAG_PISTOL_EXTRA );
	g_hItemFlagMap.SetValue("weapon_smg"			, FLAG_WEAPON | FLAG_SMG | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_smg_silenced"	, FLAG_WEAPON | FLAG_SMG | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_smg_mp5"		, FLAG_WEAPON | FLAG_SMG | FLAG_TIER1 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_pumpshotgun"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_shotgun_chrome"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_autoshotgun"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_shotgun_spas"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle"			, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle_ak47"		, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle_desert"	, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle_sg552"	, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_hunting_rifle"	, FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_sniper_military", FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_sniper_scout"	, FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_sniper_awp"		, FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_first_aid_kit"	, FLAG_ITEM | FLAG_HEAL | FLAG_MEDKIT);
	g_hItemFlagMap.SetValue("weapon_defibrillator"	, FLAG_ITEM | FLAG_HEAL | FLAG_DEFIB);
	g_hItemFlagMap.SetValue("weapon_pain_pills"		, FLAG_ITEM | FLAG_HEAL );
	g_hItemFlagMap.SetValue("weapon_adrenaline"		, FLAG_ITEM | FLAG_HEAL );
	g_hItemFlagMap.SetValue("weapon_molotov"		, FLAG_WEAPON | FLAG_GREN );
	g_hItemFlagMap.SetValue("weapon_pipe_bomb"		, FLAG_WEAPON | FLAG_GREN );
	g_hItemFlagMap.SetValue("weapon_vomitjar"		, FLAG_WEAPON | FLAG_GREN );
	g_hItemFlagMap.SetValue("weapon_gascan"			, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_propanetank"	, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_oxygentank"		, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_gnome"			, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_cola_bottles"	, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_fireworkcrate"	, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_grenade_launcher", FLAG_WEAPON | FLAG_GL | FLAG_TIER3 );
	g_hItemFlagMap.SetValue("weapon_rifle_m60"		, FLAG_WEAPON | FLAG_M60 | FLAG_TIER3 );
	g_hItemFlagMap.SetValue("weapon_upgradepack_incendiary"	, FLAG_ITEM | FLAG_UPGRADE );
	g_hItemFlagMap.SetValue("weapon_upgradepack_explosive"	, FLAG_ITEM | FLAG_UPGRADE );
	g_hItemFlagMap.SetValue("weapon_ammo"			, FLAG_ITEM | FLAG_AMMO );
	g_hItemFlagMap.SetValue("weapon_ammo_pack"		, FLAG_ITEM | FLAG_AMMO | FLAG_UPGRADE );
	g_hItemFlagMap.SetValue("upgrade_item"			, FLAG_ITEM | FLAG_UPGRADE );
	g_bInitItemFlags = true;
}

void InitCheckCases()
{
	g_hCheckCases = CreateTrie();
	g_hCheckCases.SetValue("witch", 1 );
	g_hCheckCases.SetValue("weapon_ammo_spawn", 2 );
	g_hCheckCases.SetValue("upgrade_laser_sight", 3 );
	g_hCheckCases.SetValue("upgrade_ammo_explosive", 4 );
	g_hCheckCases.SetValue("upgrade_ammo_incendiary", 4 );
	g_hCheckCases.SetValue("pipe_bomb_projectile", 5 );
	g_hCheckCases.SetValue("vomitjar_projectile", 5 );
	g_hCheckCases.SetValue("molotov_projectile", 6 );
	g_bInitCheckCases = true;
}

void InitWeaponSpawnMap()
{
	g_hWeaponSpawnMap = CreateTrie();
	g_hWeaponSpawnMap.SetString("weapon_melee_spawn", "weapon_melee");
	g_hWeaponSpawnMap.SetString("weapon_pistol_spawn", "weapon_pistol");
	g_hWeaponSpawnMap.SetString("weapon_smg_spawn", "weapon_smg");
	g_hWeaponSpawnMap.SetString("weapon_pumpshotgun_spawn", "weapon_pumpshotgun");
	g_hWeaponSpawnMap.SetString("weapon_autoshotgun_spawn", "weapon_autoshotgun");
	g_hWeaponSpawnMap.SetString("weapon_rifle_spawn", "weapon_rifle");
	g_hWeaponSpawnMap.SetString("weapon_hunting_rifle_spawn", "weapon_hunting_rifle");
	g_hWeaponSpawnMap.SetString("weapon_smg_silenced_spawn", "weapon_smg_silenced");
	g_hWeaponSpawnMap.SetString("weapon_shotgun_chrome_spawn", "weapon_shotgun_chrome");
	g_hWeaponSpawnMap.SetString("weapon_rifle_desert_spawn", "weapon_rifle_desert");
	g_hWeaponSpawnMap.SetString("weapon_sniper_military_spawn", "weapon_sniper_military");
	g_hWeaponSpawnMap.SetString("weapon_shotgun_spas_spawn", "weapon_shotgun_spas");
	g_hWeaponSpawnMap.SetString("weapon_first_aid_kit_spawn", "weapon_first_aid_kit");
	g_hWeaponSpawnMap.SetString("weapon_molotov_spawn", "weapon_molotov");
	g_hWeaponSpawnMap.SetString("weapon_pipe_bomb_spawn", "weapon_pipe_bomb");
	g_hWeaponSpawnMap.SetString("weapon_pain_pills_spawn", "weapon_pain_pills");
	g_hWeaponSpawnMap.SetString("weapon_gascan_spawn", "weapon_gascan");
	g_hWeaponSpawnMap.SetString("weapon_chainsaw_spawn", "weapon_chainsaw");
	g_hWeaponSpawnMap.SetString("weapon_grenade_launcher_spawn", "weapon_grenade_launcher");
	g_hWeaponSpawnMap.SetString("weapon_adrenaline_spawn", "weapon_adrenaline");
	g_hWeaponSpawnMap.SetString("weapon_defibrillator_spawn", "weapon_defibrillator");
	g_hWeaponSpawnMap.SetString("weapon_vomitjar_spawn", "weapon_vomitjar");
	g_hWeaponSpawnMap.SetString("weapon_rifle_ak47_spawn", "weapon_rifle_ak47");
	g_hWeaponSpawnMap.SetString("weapon_upgradepack_incendiary_spawn", "weapon_upgradepack_incendiary");
	g_hWeaponSpawnMap.SetString("weapon_upgradepack_explosive_spawn", "weapon_upgradepack_explosive");
	g_hWeaponSpawnMap.SetString("weapon_pistol_magnum_spawn", "weapon_pistol_magnum");
	g_hWeaponSpawnMap.SetString("weapon_smg_mp5_spawn", "weapon_smg_mp5");
	g_hWeaponSpawnMap.SetString("weapon_rifle_sg552_spawn", "weapon_rifle_sg552");
	g_hWeaponSpawnMap.SetString("weapon_sniper_awp_spawn", "weapon_sniper_awp");
	g_hWeaponSpawnMap.SetString("weapon_sniper_scout_spawn", "weapon_sniper_scout");
	g_hWeaponSpawnMap.SetString("weapon_rifle_m60_spawn", "weapon_rifle_m60");
	g_bInitWeaponSpawnMap = true;
}

void InitWeaponToIDMap()
{
	g_hWeaponToIDMap = CreateTrie();
	g_hWeaponToIDMap.SetValue("weapon_melee"			, L4D2WeaponId_Melee );
	g_hWeaponToIDMap.SetValue("weapon_chainsaw"			, L4D2WeaponId_Chainsaw );
	g_hWeaponToIDMap.SetValue("weapon_pistol"			, L4D2WeaponId_Pistol );
	g_hWeaponToIDMap.SetValue("weapon_pistol_magnum"	, L4D2WeaponId_PistolMagnum );
	g_hWeaponToIDMap.SetValue("weapon_smg"				, L4D2WeaponId_Smg );
	g_hWeaponToIDMap.SetValue("weapon_smg_silenced"		, L4D2WeaponId_SmgSilenced );
	g_hWeaponToIDMap.SetValue("weapon_smg_mp5"			, L4D2WeaponId_SmgMP5 );
	g_hWeaponToIDMap.SetValue("weapon_pumpshotgun"		, L4D2WeaponId_Pumpshotgun );
	g_hWeaponToIDMap.SetValue("weapon_shotgun_chrome"	, L4D2WeaponId_ShotgunChrome );
	g_hWeaponToIDMap.SetValue("weapon_autoshotgun"		, L4D2WeaponId_Autoshotgun );
	g_hWeaponToIDMap.SetValue("weapon_shotgun_spas"		, L4D2WeaponId_ShotgunSpas );
	g_hWeaponToIDMap.SetValue("weapon_rifle"			, L4D2WeaponId_Rifle );
	g_hWeaponToIDMap.SetValue("weapon_rifle_ak47"		, L4D2WeaponId_RifleAK47 );
	g_hWeaponToIDMap.SetValue("weapon_rifle_desert"		, L4D2WeaponId_RifleDesert );
	g_hWeaponToIDMap.SetValue("weapon_rifle_sg552"		, L4D2WeaponId_RifleSG552 );
	g_hWeaponToIDMap.SetValue("weapon_hunting_rifle"	, L4D2WeaponId_HuntingRifle );
	g_hWeaponToIDMap.SetValue("weapon_sniper_military"	, L4D2WeaponId_SniperMilitary );
	g_hWeaponToIDMap.SetValue("weapon_sniper_scout"		, L4D2WeaponId_SniperScout );
	g_hWeaponToIDMap.SetValue("weapon_sniper_awp"		, L4D2WeaponId_SniperAWP );
	g_hWeaponToIDMap.SetValue("weapon_first_aid_kit"	, L4D2WeaponId_FirstAidKit );
	g_hWeaponToIDMap.SetValue("weapon_defibrillator"	, L4D2WeaponId_Defibrillator );
	g_hWeaponToIDMap.SetValue("weapon_pain_pills"		, L4D2WeaponId_PainPills );
	g_hWeaponToIDMap.SetValue("weapon_adrenaline"		, L4D2WeaponId_Adrenaline );
	g_hWeaponToIDMap.SetValue("weapon_molotov"			, L4D2WeaponId_Molotov );
	g_hWeaponToIDMap.SetValue("weapon_pipe_bomb"		, L4D2WeaponId_PipeBomb );
	g_hWeaponToIDMap.SetValue("weapon_vomitjar"			, L4D2WeaponId_Vomitjar );
	g_hWeaponToIDMap.SetValue("weapon_gascan"			, L4D2WeaponId_Gascan );
	g_hWeaponToIDMap.SetValue("weapon_propanetank"		, L4D2WeaponId_PropaneTank );
	g_hWeaponToIDMap.SetValue("weapon_oxygentank"		, L4D2WeaponId_OxygenTank );
	g_hWeaponToIDMap.SetValue("weapon_gnome"			, L4D2WeaponId_GnomeChompski );
	g_hWeaponToIDMap.SetValue("weapon_cola_bottles"		, L4D2WeaponId_ColaBottles );
	g_hWeaponToIDMap.SetValue("weapon_fireworkcrate"	, L4D2WeaponId_FireworksBox );
	g_hWeaponToIDMap.SetValue("weapon_grenade_launcher"	, L4D2WeaponId_GrenadeLauncher );
	g_hWeaponToIDMap.SetValue("weapon_rifle_m60"		, L4D2WeaponId_RifleM60 );
	g_hWeaponToIDMap.SetValue("weapon_upgradepack_incendiary", L4D2WeaponId_IncendiaryAmmo );
	g_hWeaponToIDMap.SetValue("weapon_upgradepack_explosive" , L4D2WeaponId_FragAmmo );
	g_hWeaponToIDMap.SetValue("weapon_ammo"				, L4D2WeaponId_Ammo );
	g_hWeaponToIDMap.SetValue("weapon_ammo_pack"		, L4D2WeaponId_AmmoPack );
	g_hWeaponToIDMap.SetValue("upgrade_item"			, L4D2WeaponId_UpgradeItem );
	g_hWeaponToIDMap.SetValue("weapon_machinegun"		, L4D2WeaponId_Machinegun);
	g_hWeaponToIDMap.SetValue("vomit"					, L4D2WeaponId_FatalVomit );
	g_hWeaponToIDMap.SetValue("splat"					, L4D2WeaponId_ExplodingSplat );
	g_hWeaponToIDMap.SetValue("pounce"					, L4D2WeaponId_LungePounce );
	g_hWeaponToIDMap.SetValue("lounge"					, L4D2WeaponId_Lounge );
	g_hWeaponToIDMap.SetValue("pull"					, L4D2WeaponId_FullPull );
	g_hWeaponToIDMap.SetValue("choke"					, L4D2WeaponId_Choke );
	g_hWeaponToIDMap.SetValue("rock"					, L4D2WeaponId_ThrowingRock );
	g_hWeaponToIDMap.SetValue("physics"					, L4D2WeaponId_TurboPhysics );
	g_bInitWeaponToIDMap = true;
}

void InitMaxAmmo()
{
	int iMaxAmmo, iAmmoOverride[56];
	char sArgs[16][8], sBuffer[2][4];
	L4D2WeaponId iWeaponID;
	
	if ( strlen(g_sCvar_Ammo_Type_Override) && ExplodeString(g_sCvar_Ammo_Type_Override, " ", sArgs, sizeof(sArgs), sizeof(sArgs[]), true) )
	{
		for (int i = 0; i < sizeof(sArgs); i++)
		{
			if (ExplodeString(sArgs[i], ":", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]), true) == 2)
				iAmmoOverride[StringToInt(sBuffer[0])] = StringToInt(sBuffer[1]);
		}
	}
	
	for (int i = 0; i < 56; i++) // L4D2WeaponId_MAX is 56
	{
		iWeaponID = view_as<L4D2WeaponId>(i);
		iMaxAmmo = -1;
		if (iAmmoOverride[i])
		{
			g_iMaxAmmo[i] = iAmmoOverride[i];
			//if (g_bCvar_Debug)
			//	PrintToServer("InitMaxAmmo: %s max ammo %d (override)", IBWeaponName[i], g_iMaxAmmo[i]);
			continue;
		}
		switch(iWeaponID)
		{
			case L4D2WeaponId_Pistol, L4D2WeaponId_PistolMagnum:
				iMaxAmmo = g_iCvar_MaxAmmo_Pistol;
			case L4D2WeaponId_Smg, L4D2WeaponId_SmgSilenced, L4D2WeaponId_SmgMP5:
				iMaxAmmo = g_iCvar_MaxAmmo_SMG;
			case L4D2WeaponId_Pumpshotgun, L4D2WeaponId_ShotgunChrome:
				iMaxAmmo = g_iCvar_MaxAmmo_Shotgun;
			case L4D2WeaponId_Autoshotgun, L4D2WeaponId_ShotgunSpas:
				iMaxAmmo = g_iCvar_MaxAmmo_AutoShotgun;
			case L4D2WeaponId_Rifle, L4D2WeaponId_RifleAK47, L4D2WeaponId_RifleDesert, L4D2WeaponId_RifleSG552:
				iMaxAmmo = g_iCvar_MaxAmmo_AssaultRifle;
			case L4D2WeaponId_HuntingRifle:
				iMaxAmmo = g_iCvar_MaxAmmo_HuntRifle;
			case L4D2WeaponId_SniperMilitary, L4D2WeaponId_SniperScout, L4D2WeaponId_SniperAWP:
				iMaxAmmo = g_iCvar_MaxAmmo_SniperRifle;
			case L4D2WeaponId_GrenadeLauncher:
				iMaxAmmo = g_iCvar_MaxAmmo_GrenLauncher;
			case L4D2WeaponId_RifleM60:
				iMaxAmmo = g_iCvar_MaxAmmo_M60;
			case L4D2WeaponId_FirstAidKit:
				iMaxAmmo = g_iCvar_MaxAmmo_Medkit;
			case L4D2WeaponId_Adrenaline:
				iMaxAmmo = g_iCvar_MaxAmmo_Adrenaline;
			case L4D2WeaponId_PainPills:
				iMaxAmmo = g_iCvar_MaxAmmo_PainPills;
			case L4D2WeaponId_FragAmmo, L4D2WeaponId_IncendiaryAmmo:
				iMaxAmmo = g_iCvar_MaxAmmo_AmmoPack;
			case L4D2WeaponId_Chainsaw:
				iMaxAmmo = g_iCvar_MaxAmmo_Chainsaw;
			case L4D2WeaponId_PipeBomb:
				iMaxAmmo = g_iCvar_MaxAmmo_PipeBomb;
			case L4D2WeaponId_Molotov:
				iMaxAmmo = g_iCvar_MaxAmmo_Molotov;
			case L4D2WeaponId_Vomitjar:
				iMaxAmmo = g_iCvar_MaxAmmo_VomitJar;
		}
		g_iMaxAmmo[i] = iMaxAmmo;
		//if (g_bCvar_Debug && iMaxAmmo > -1)
		//	PrintToServer("InitMaxAmmo: %s max ammo %d", IBWeaponName[i], g_iMaxAmmo[i]);
	}
	
	for (int i = 0; i > MAXENTITIES; i++)
	{
		g_iWeapon_MaxAmmo[i] = g_iMaxAmmo[g_iWeaponID[i]];
	}
	g_bInitMaxAmmo = true;
}

void InitWeaponAndTierMap()
{
	//g_iWeaponTier[L4D2WeaponId_None] = -1;
	//g_iWeaponTier[L4D2WeaponId_Pistol] = 0;
	//g_iWeaponTier[L4D2WeaponId_Smg] = 1;
	//g_iWeaponTier[L4D2WeaponId_Pumpshotgun] = 1;
	//g_iWeaponTier[L4D2WeaponId_Autoshotgun] = 2;
	//g_iWeaponTier[L4D2WeaponId_Rifle] = 2;
	//g_iWeaponTier[L4D2WeaponId_HuntingRifle] = 2;
	//g_iWeaponTier[L4D2WeaponId_SmgSilenced] = 1;
	//g_iWeaponTier[L4D2WeaponId_ShotgunChrome] = 1;
	//g_iWeaponTier[L4D2WeaponId_RifleDesert] = 2;
	//g_iWeaponTier[L4D2WeaponId_SniperMilitary] = 2;
	//g_iWeaponTier[L4D2WeaponId_ShotgunSpas] = 2;
	//g_iWeaponTier[L4D2WeaponId_FirstAidKit] = 0;
	//g_iWeaponTier[L4D2WeaponId_Molotov] = 0;
	//g_iWeaponTier[L4D2WeaponId_PipeBomb] = 0;
	//g_iWeaponTier[L4D2WeaponId_PainPills] = 0;
	//g_iWeaponTier[L4D2WeaponId_Gascan] = 0;
	//g_iWeaponTier[L4D2WeaponId_PropaneTank] = 0;
	//g_iWeaponTier[L4D2WeaponId_OxygenTank] = 0;
	//g_iWeaponTier[L4D2WeaponId_Melee] = 0;
	//g_iWeaponTier[L4D2WeaponId_Chainsaw] = 0;
	g_iWeaponTier[L4D2WeaponId_GrenadeLauncher] = 3;
	g_iWeaponTier[L4D2WeaponId_AmmoPack] = -1;
	//g_iWeaponTier[L4D2WeaponId_Adrenaline] = 0;
	//g_iWeaponTier[L4D2WeaponId_Defibrillator] = 0;
	//g_iWeaponTier[L4D2WeaponId_Vomitjar] = 0;
	//g_iWeaponTier[L4D2WeaponId_RifleAK47] = 0;
	//g_iWeaponTier[L4D2WeaponId_GnomeChompski] = 0;
	//g_iWeaponTier[L4D2WeaponId_ColaBottles] = 0;
	//g_iWeaponTier[L4D2WeaponId_FireworksBox] = 0;
	//g_iWeaponTier[L4D2WeaponId_IncendiaryAmmo] = 0;
	//g_iWeaponTier[L4D2WeaponId_FragAmmo] = 0;
	//g_iWeaponTier[L4D2WeaponId_PistolMagnum] = 0;
	//g_iWeaponTier[L4D2WeaponId_SmgMP5] = 1;
	//g_iWeaponTier[L4D2WeaponId_RifleSG552] = 2;
	//g_iWeaponTier[L4D2WeaponId_SniperAWP] = 2;
	//g_iWeaponTier[L4D2WeaponId_SniperScout] = 2;
	g_iWeaponTier[L4D2WeaponId_RifleM60] = 3;
	g_iWeaponTier[L4D2WeaponId_Machinegun] = -1;
	g_iWeaponTier[L4D2WeaponId_FatalVomit] = -1;
	g_iWeaponTier[L4D2WeaponId_ExplodingSplat] = -1;
	g_iWeaponTier[L4D2WeaponId_LungePounce] = -1;
	g_iWeaponTier[L4D2WeaponId_Lounge] = -1;
	g_iWeaponTier[L4D2WeaponId_FullPull] = -1;
	g_iWeaponTier[L4D2WeaponId_Choke] = -1;
	g_iWeaponTier[L4D2WeaponId_ThrowingRock] = -1;
	g_iWeaponTier[L4D2WeaponId_TurboPhysics] = -1;
	g_iWeaponTier[L4D2WeaponId_Ammo] = -1;
	g_iWeaponTier[L4D2WeaponId_UpgradeItem] = -1;
	
	g_bIsSemiAuto[L4D2WeaponId_Pistol] = true;
	g_bIsSemiAuto[L4D2WeaponId_PistolMagnum] = true;
	g_bIsSemiAuto[L4D2WeaponId_Pumpshotgun] = true;
	g_bIsSemiAuto[L4D2WeaponId_ShotgunChrome] = true;
	g_bIsSemiAuto[L4D2WeaponId_Autoshotgun] = true;
	g_bIsSemiAuto[L4D2WeaponId_ShotgunSpas] = true;
	g_bIsSemiAuto[L4D2WeaponId_HuntingRifle] = true;
	g_bIsSemiAuto[L4D2WeaponId_SniperMilitary] = true;
	g_bIsSemiAuto[L4D2WeaponId_SniperScout] = true;
	g_bIsSemiAuto[L4D2WeaponId_SniperAWP] = true;
	g_bIsSemiAuto[L4D2WeaponId_GrenadeLauncher] = true;
	g_bIsSemiAuto[L4D2WeaponId_PainPills] = true;
	g_bIsSemiAuto[L4D2WeaponId_Adrenaline] = true;
	g_bIsSemiAuto[L4D2WeaponId_PipeBomb] = true;
	g_bIsSemiAuto[L4D2WeaponId_Molotov] = true;
	g_bIsSemiAuto[L4D2WeaponId_Vomitjar] = true;
	
	g_hWeaponMap = CreateTrie();
	
	for (int i = 0; i < 56; i++) // L4D2WeaponId_MAX is 56
		g_hWeaponMap.SetValue(IBWeaponName[i], true);
	
	if (L4D_HasMapStarted())
		UpdateWeaponTiers();
	else
		RequestFrame(UpdateWeaponTiers);
	
	g_bInitWeaponMap = true;
}

void UpdateWeaponTiers()
{
	for (int i = 0; i < 38; i++) // 37 L4D2WeaponId_RifleM60
	{
		if(g_iWeaponTier[i] != 3 && g_iWeaponTier[i] != -1)
			g_iWeaponTier[i] = L4D2_GetIntWeaponAttribute(IBWeaponName[i], L4D2IWA_Tier);
	}
}

void GetEntityModelname(int iEntity, char[] sModelName, int iMaxLength)
{
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, iMaxLength);
}

float GetClientDistance(int iClient, int iTarget, bool bSquared = false)
{
	return GetVectorDistance(g_fClientAbsOrigin[iClient], g_fClientAbsOrigin[iTarget], bSquared);
}

float GetEntityDistance(int iEntity, int iTarget, bool bSquared = false)
{
	float fEntityPos[3]; GetEntityAbsOrigin(iEntity, fEntityPos);
	float fTargetPos[3]; GetEntityAbsOrigin(iTarget, fTargetPos);
	return (GetVectorDistance(fEntityPos, fTargetPos, bSquared));
}

bool IsValidVector(const float fVector[3])
{
	int iCheck;
	for (int i = 0; i < 3; ++i)
	{
		if (fVector[i] != 0.0000)break;
		++iCheck;
	}
	return view_as<bool>(iCheck != 3);
}

int GetEntityHealth(int iEntity)
{
	return (GetEntProp(iEntity, Prop_Data, "m_iHealth"));
}

int GetEntityMaxHealth(int iEntity)
{
	return (GetEntProp(iEntity, Prop_Data, "m_iMaxHealth"));
}

float GetWeaponCycleTime(int iWeapon)
{
	static char sWeaponName[64];
	GetWeaponClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	if (!L4D2_IsValidWeapon(sWeaponName))return -1.0;
	return L4D2_GetFloatWeaponAttribute(sWeaponName, L4D2FWA_CycleTime);
}

//Get max ammo for entity depending on weapon ID
//
//When this is called, we assume that weapon id is known, and available in g_iWeaponID
//
//Instead of figuring out weapon name or ammo type from prop data, we use "lookup table", that's initiated once per round at worst
//
int GetWeaponMaxAmmo(int iWeapon)
{
	if (!g_bInitMaxAmmo)
	{
		InitMaxAmmo();
		PrintToServer("GetWeaponMaxAmmo: InitMaxAmmo");
	}
	
	return g_iMaxAmmo[g_iWeaponID[iWeapon]];
}

int GetWeaponTier(int iWeapon)
{
	return g_iWeaponTier[g_iWeaponID[iWeapon]];
}

bool IsSurvivorCarryingProp(int iClient)
{
	return (IsWeaponSlotActive(iClient, 5));
}

//	Get weapon classname from entity ID
//	Return 0 if weapon is not recognized
//	1 if it's weapon proper
//	-1 if the entity is not exactly a weapon (may be weapon_spawn)
int GetWeaponClassname(int iWeapon, char[] sBuffer, int iMaxLength)
{
	//static char classname[64];
	//strcopy( classname, sizeof(classname), sBuffer );
	
	if ( !GetEdictClassname(iWeapon, sBuffer, iMaxLength) )
		return 0;
	
	if (!g_bInitWeaponMap)
	{
		InitWeaponAndTierMap();
		PrintToServer("GetWeaponClassname: InitWeaponAndTierMap");
	}
	if( g_hWeaponMap.ContainsKey(sBuffer) ) // if it's a weapon name already, just get on with it
	{
		//if (g_bCvar_Debug)
		//	PrintToServer("Classname %s exists as key, id %d", sBuffer, iWeapon);
		
		return 1;
	}
	
	if (!g_bInitWeaponSpawnMap)
	{
		InitWeaponSpawnMap();
		PrintToServer("GetWeaponClassname: InitWeaponSpawnMap");
	}
	if( g_hWeaponSpawnMap.GetString(sBuffer, sBuffer, iMaxLength) )
	{
		//if (g_bCvar_Debug)
		//	PrintToServer("Got weapon name %s from WeaponMap for id %d classname %s", sBuffer, iWeapon, classname);
		
		return -1;
	}
	
	if (strcmp(sBuffer, "weapon_spawn") == 0)
	{
		int iWeaponID = GetEntProp(iWeapon, Prop_Send, "m_weaponID");
		if (iWeaponID == 0)
		{
			PushEntityIntoArrayList(g_hWeaponsToCheckLater, iWeapon);
			if (g_hCheckWeaponTimer == INVALID_HANDLE)
				g_hCheckWeaponTimer = CreateTimer(0.1, CheckWeaponsEvenLater);
			return 0;
		}
		
		strcopy( sBuffer, iMaxLength, IBWeaponName[iWeaponID] );
		
		//if (g_bCvar_Debug)
		//	PrintToServer("Got weapon name %s from IBWeaponName for id %d classname %s", IBWeaponName[iWeaponID], iWeapon, classname);
		
		return -1;
	}
	
	if(g_iCvar_ItemScavenge_Models)
	{
		static char sWeaponModel[PLATFORM_MAX_PATH];
		GetEntityModelname(iWeapon, sWeaponModel, sizeof(sWeaponModel));
		
		if (!g_bInitWeaponMdlMap)
		{
			InitWeaponMdlMap();
			PrintToServer("GetWeaponClassname: InitWeaponMdlMap");
		}
		if( g_hWeaponMdlMap.GetString(sWeaponModel, sBuffer, iMaxLength) )
		{
			//if (g_bCvar_Debug)
			//	PrintToServer("Judged weapon class %s by model from id %d classname %s!", sBuffer, iWeapon, classname);
			
			return -1;
		}
	}
	
	//if (g_bCvar_Debug)
	//	PrintToServer("Could not recognize weapon from entity %d %s! buffer %s model %s", iWeapon, classname, sBuffer, sWeaponModel);
	
	return 0;
}

int GetClientSurvivorType(int iClient)
{
	static char sModelname[PLATFORM_MAX_PATH]; GetClientModel(iClient, sModelname, sizeof(sModelname));
	switch(sModelname[29])
	{
		case 'b': 	return L4D_SURVIVOR_NICK;
		case 'd': 	return L4D_SURVIVOR_ROCHELLE;
		case 'c': 	return L4D_SURVIVOR_COACH;
		case 'h': 	return L4D_SURVIVOR_ELLIS;
		case 'v': 	return L4D_SURVIVOR_BILL;
		case 'n': 	return L4D_SURVIVOR_ZOEY;
		case 'e': 	return L4D_SURVIVOR_FRANCIS;
		case 'a': 	return L4D_SURVIVOR_LOUIS;
		default:	return 0;
	}
}

bool IsEntityExists(int iEntity)
{
	return (iEntity > 0 && (iEntity <= MAXENTITIES && IsValidEdict(iEntity) || iEntity > MAXENTITIES && IsValidEntity(iEntity)));
}

bool IsCommonInfected(int iEntity)
{
	static char sEntClass[64]; GetEntityClassname(iEntity, sEntClass, sizeof(sEntClass));
	return (strcmp(sEntClass, "infected") == 0);
}

bool IsCommonInfectedAttacking(int iEntity)
{
	if (HasEntProp(iEntity, Prop_Send, "m_mobRush") && GetEntProp(iEntity, Prop_Send, "m_mobRush") != 0)
		return true;

	return (HasEntProp(iEntity, Prop_Send, "m_clientLookatTarget") && GetEntProp(iEntity, Prop_Send, "m_clientLookatTarget") != -1);
}

bool IsCommonInfectedAlive(int iEntity)
{
	return (GetEntProp(iEntity, Prop_Data, "m_lifeState") == 0 && GetEntProp(iEntity, Prop_Send, "m_bIsBurning") == 0);
}

bool IsCommonInfectedStumbled(int iEntity)
{
	if (!g_bExtensionActions)return false;
	return (ActionsManager.GetAction(iEntity, "InfectedShoved") != INVALID_ACTION);
}

int GetFarthestInfected(int iClient, float fDistance = -1.0)
{
	int iInfected = -1;

	float fInfectedDist; 
	float fInfectedPos[3];
	float fLastDist = -1.0;
	
	int i = INVALID_ENT_REFERENCE;
	while ((i = FindEntityByClassname(i, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (!IsCommonInfectedAlive(i))
			continue;
		
		GetEntityCenteroid(i, fInfectedPos);
		fInfectedDist = GetVectorDistance(g_fClientEyePos[iClient], fInfectedPos, true);
		if (fDistance > 0.0 && fInfectedDist > (fDistance*fDistance) || fLastDist != -1.0 && fInfectedDist <= fLastDist || !IsVisibleVector(iClient, fInfectedPos))
			continue;

		iInfected = i;
		fLastDist = fInfectedDist;
	}

	return iInfected;
}

void CheckEntityForVisibility(int iClient, int iEntity, bool bFOVOnly = false, float fOverridePos[3] = NULL_VECTOR)
{
	float fVisionTime = (bFOVOnly ? g_fSurvivorBot_VisionMemory_Time_FOV[iClient][iEntity] : g_fSurvivorBot_VisionMemory_Time[iClient][iEntity]);
	if (GetGameTime() < fVisionTime)return;

	float fCheckPos[3];
	if (IsNullVector(fOverridePos))GetEntityCenteroid(iEntity, fCheckPos);
	else fCheckPos = fOverridePos;
	if (bFOVOnly && !FVectorInViewCone(iClient, fCheckPos))return;

	float fNoticeTime;
	bool bIsVisible = IsVisibleEntity(iClient, iEntity);
	float fEntityDist = GetVectorDistance(g_fClientEyePos[iClient], fCheckPos, true);
	float fDot = RadToDeg(ArcCosine(GetLineOfSightDotProduct(iClient, fCheckPos)));
	
	float fMaxDist = 16777216.0;

	int iVisionState = (bFOVOnly ? g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] : g_iSurvivorBot_VisionMemory_State[iClient][iEntity]);
	if (!bFOVOnly)
	{
		fNoticeTime = (ClampFloat(0.66 * (fDot / 165.0) + (fEntityDist / fMaxDist), 0.1, 1.5) * g_fCvar_Vision_NoticeTimeScale);
		switch(iVisionState)
		{
			case 0:
			{
				if (!bIsVisible)return;
				g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 1;
				g_fSurvivorBot_VisionMemory_Time[iClient][iEntity] = GetGameTime() + fNoticeTime;
			}
			case 1:
			{
				g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = (bIsVisible ? 2 : 0);
			}
			case 2:
			{
				if (!bIsVisible)g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 3;
			}
			case 3:
			{
				if (bIsVisible)
				{
					g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 2;
					return;
				}
				if ((GetGameTime() - fVisionTime) >= 15.0)
				{
					g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 0;
					return;
				}
				g_fSurvivorBot_VisionMemory_Time[iClient][iEntity] = GetGameTime() + ClampFloat(fNoticeTime * 0.33, 0.1, fNoticeTime);
			}
		}
	}
	else
	{
		fNoticeTime = (ClampFloat(0.33 * (fDot / g_fCvar_Vision_FieldOfView) + (fEntityDist / fMaxDist), 0.1, 0.75) * g_fCvar_Vision_NoticeTimeScale);
		switch(iVisionState)
		{
			case 0:
			{
				if (!bIsVisible)return;
				g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 1;
				g_fSurvivorBot_VisionMemory_Time_FOV[iClient][iEntity] = GetGameTime() + fNoticeTime;
			}
			case 1:
			{
				g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = (bIsVisible ? 2 : 0);
			}
			case 2:
			{
				if (!bIsVisible)g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 3;
			}
			case 3:
			{
				g_fSurvivorBot_VisionMemory_Time_FOV[iClient][iEntity] = GetGameTime() + fNoticeTime;
				if (bIsVisible)
				{
					g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 2;
					return;
				}
				if ((GetGameTime() - fVisionTime) >= 15.0)
				{
					g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 0;
					return;
				}
			}
		}
	}
}

bool HasVisualContactWithEntity(int iClient, int iEntity, bool bFOVState = true, float fOverridePos[3] = NULL_VECTOR)
{
	CheckEntityForVisibility(iClient, iEntity, bFOVState, fOverridePos);
	int iState = (bFOVState ? g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] : g_iSurvivorBot_VisionMemory_State[iClient][iEntity]);
	return (iState == 2);
}

stock float ClampFloat(float fValue, float fMin, float fMax)
{
	return (fValue > fMax) ? fMax : ((fValue < fMin) ? fMin : fValue);
}

int GetClosestInfected(int iClient, float fDistance = -1.0)
{
	static int iInfected, iCloseInfected, iThrownPipeBomb;
	static float fInfectedDist, fLastDist;
	static bool bIsAttacking, bIsChasingSomething, bBileWasThrown;

	bIsChasingSomething = false;
	iThrownPipeBomb = (FindEntityByClassname(-1, "pipe_bomb_projectile"));
	bBileWasThrown = (FindEntityByClassname(-1, "info_goal_infected_chase") != -1);
	iCloseInfected = -1;
	fLastDist = -1.0;
	iInfected = INVALID_ENT_REFERENCE;
	while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (!IsCommonInfectedAlive(iInfected))
			continue;

		fInfectedDist = GetEntityDistance(iClient, iInfected, true);
		if (fDistance > 0.0 && fInfectedDist > (fDistance*fDistance) || fLastDist != -1.0 && fInfectedDist >= fLastDist)
			continue;

		bIsChasingSomething = (fInfectedDist > 25600.0 && (bBileWasThrown || iThrownPipeBomb > 0 && GetEntityDistance(iInfected, iThrownPipeBomb, true) <= 65536.0));
		if (!bIsChasingSomething && fInfectedDist > 9216.0)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				bIsChasingSomething = (iClient != i && IsClientSurvivor(i) && g_iSurvivorBot_TargetInfected[i] == iInfected && IsWeaponSlotActive(i, 1) && IsEntityExists(g_iSurvivorBot_TargetInfected[i]) && SurvivorHasMeleeWeapon(i) != 0);
				if (bIsChasingSomething)break;
			}
		}

		if (bIsChasingSomething || !IsVisibleEntity(iClient, iInfected))
			continue;

		iCloseInfected = iInfected;
		fLastDist = fInfectedDist;
	}

	bIsAttacking = false;
	for (iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (!IsSpecialInfected(iInfected) || L4D2_GetPlayerZombieClass(iInfected) == L4D2ZombieClass_Tank || bIsAttacking && !IsUsingSpecialAbility(iInfected))
			continue;

		fInfectedDist = GetClientDistance(iClient, iInfected, true);
		if (fDistance > 0.0 && fInfectedDist > (fDistance*fDistance) || fLastDist != -1.0 && fInfectedDist >= fLastDist || !IsVisibleEntity(iClient, iInfected, MASK_VISIBLE_AND_NPCS))
			continue;

		iCloseInfected = iInfected;
		fLastDist = fInfectedDist;
		bIsAttacking = IsUsingSpecialAbility(iInfected);
	}

	return iCloseInfected;
}

int GetInfectedCount(int iClient, float fDistanceLimit = -1.0, int iMaxLimit = -1, bool bVisible = true, bool bAttackingOnly = true)
{
	static int i, iCount;
	static float fClientPos[3], fInfectedPos[3];
	GetEntityCenteroid(iClient, fClientPos);
	
	i = INVALID_ENT_REFERENCE;
	iCount = 0;
	while ((i = FindEntityByClassname(i, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (!IsCommonInfectedAlive(i) || bAttackingOnly && !IsCommonInfectedAttacking(i))
			continue;

		GetEntityCenteroid(i, fInfectedPos);
		if (fDistanceLimit > 0.0 && GetVectorDistance(fClientPos, fInfectedPos, true) > (fDistanceLimit*fDistanceLimit) || bVisible && (IsValidClient(iClient) && !IsVisibleVector(iClient, fInfectedPos, MASK_VISIBLE_AND_NPCS) || !GetVectorVisible(fClientPos, fInfectedPos)))
			continue;

		iCount++;
		if (iMaxLimit > 0 && iCount >= iMaxLimit)return iCount;
	}

	return iCount;
}

bool IsSpecialInfected(int iClient)
{
	return (IsValidClient(iClient) && GetClientTeam(iClient) == 3 && IsPlayerAlive(iClient) && !L4D_IsPlayerGhost(iClient));
}

bool IsWitch(int iEntity)
{
	static char sClass[12]; GetEntityClassname(iEntity, sClass, sizeof(sClass));
	return (strcmp(sClass, "witch") == 0);
}

bool IsSurvivorBusy(int iClient, bool bHoldingGrenade = false, bool bHoldingMedkit = false, bool bHoldingPills = false)
{
	if (bHoldingGrenade && IsWeaponSlotActive(iClient, 2) || bHoldingMedkit && IsWeaponSlotActive(iClient, 3) || bHoldingPills && IsWeaponSlotActive(iClient, 4))
		return true;

	L4D2UseAction iUseAction = L4D2_GetPlayerUseAction(iClient);
	if (iUseAction != L4D2UseAction_None && (bHoldingMedkit || iUseAction != L4D2UseAction_Healing && iUseAction != L4D2UseAction_Defibing))
		return true;

	if (L4D_GetPlayerReviveTarget(iClient) > 0)
		return true;

	if (L4D_IsPlayerStaggering(iClient))
		return true;

	return false;
}

bool IsVisibleVector(int iClient, float fPos[3], int iMask = MASK_SHOT)
{
	if (IsFakeClient(iClient) && GetClientTeam(iClient) == 2 && IsSurvivorBotBlindedByVomit(iClient))
		return false;

	Handle hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fPos, iMask, RayType_EndPoint, Base_TraceFilter);
	float fFraction = TR_GetFraction(hResult); delete hResult;
	return (fFraction == 1.0);
}

bool IsVisibleEntity(int iClient, int iTarget, int iMask = MASK_SHOT)
{
	if (IsFakeClient(iClient) && GetClientTeam(iClient) == 2 && IsSurvivorBotBlindedByVomit(iClient))
		return false;

	float fTargetPos[3];
	GetEntityAbsOrigin(iTarget, fTargetPos);

	Handle hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fTargetPos, iMask, RayType_EndPoint, Base_TraceFilter, iTarget);
	bool bDidHit = (TR_GetFraction(hResult) == 1.0 && !TR_StartSolid(hResult) || TR_GetEntityIndex(hResult) == iTarget); delete hResult;
	if (!bDidHit)
	{
		float fViewOffset[3]; 
		GetEntPropVector(iTarget, Prop_Data, "m_vecViewOffset", fViewOffset);
		AddVectors(fTargetPos, fViewOffset, fTargetPos);

		hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fTargetPos, iMask, RayType_EndPoint, Base_TraceFilter, iTarget);
		bDidHit = (TR_GetFraction(hResult) == 1.0 && !TR_StartSolid(hResult) || TR_GetEntityIndex(hResult) == iTarget); delete hResult;
		if (!bDidHit)
		{
			GetEntityCenteroid(iTarget, fTargetPos);
			
			hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fTargetPos, iMask, RayType_EndPoint, Base_TraceFilter, iTarget);
			bDidHit = (TR_GetFraction(hResult) == 1.0 && !TR_StartSolid(hResult) || TR_GetEntityIndex(hResult) == iTarget); delete hResult;
		}
	}
	return (bDidHit);
}

float GetLineOfSightDotProduct(int iClient, const float fVecSpot[3])
{
	float fLineOfSight[3]; 
	MakeVectorFromPoints(g_fClientEyePos[iClient], fVecSpot, fLineOfSight);
	NormalizeVector(fLineOfSight, fLineOfSight);

	float fEyeDirection[3];
	GetAngleVectors(g_fClientEyeAng[iClient], fEyeDirection, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fEyeDirection, fEyeDirection);

	return GetVectorDotProduct(fLineOfSight, fEyeDirection);
}

bool FVectorInViewCone(int iClient, const float fVecSpot[3], float fCone = -1.0)
{
	if (fCone == -1.0)fCone = g_fCvar_Vision_FieldOfView;
	return (RadToDeg(ArcCosine(GetLineOfSightDotProduct(iClient, fVecSpot))) <= fCone);
}

float GetViewAnglesDotProduct(int iClient, const float fVecSpot[3])
{
	float fLineOfSight[3]; 
	MakeVectorFromPoints(g_fClientAbsOrigin[iClient], fVecSpot, fLineOfSight);
	fLineOfSight[2] = 0.0;
	NormalizeVector(fLineOfSight, fLineOfSight);

	float fDirection[3]; GetClientAbsAngles(iClient, fDirection);
	GetAngleVectors(fDirection, fDirection, NULL_VECTOR, NULL_VECTOR);
	fDirection[2] = 0.0;
	NormalizeVector(fDirection, fDirection);

	return GetVectorDotProduct(fLineOfSight, fDirection);
}

bool FVectorInViewAngle(int iClient, const float fVecSpot[3], float fAngle = -1.0)
{
	if (fAngle == -1.0)fAngle = g_fCvar_Vision_FieldOfView;
	return (RadToDeg(ArcCosine(GetViewAnglesDotProduct(iClient, fVecSpot))) <= fAngle);
}

bool FEntityInViewAngle(int iClient, int iEntity, float fAngle = -1.0)
{
	if (fAngle == -1.0)fAngle = g_fCvar_Vision_FieldOfView;
	float fEntityAbsOrigin[3]; GetEntityCenteroid(iEntity, fEntityAbsOrigin);
	return (RadToDeg(ArcCosine(GetViewAnglesDotProduct(iClient, fEntityAbsOrigin))) <= fAngle);
}

void SnapViewToPosition(int iClient, const float fPos[3])
{
	if (g_bClient_IsLookingAtPosition[iClient])
		return;
	
	float fDesiredDir[3];
	MakeVectorFromPoints(g_fClientEyePos[iClient], fPos, fDesiredDir);
	GetVectorAngles(fDesiredDir, fDesiredDir);

	float fEyeAngles[3];
	fEyeAngles[0] = (g_fClientEyeAng[iClient][0] + NormalizeAngle(fDesiredDir[0] - g_fClientEyeAng[iClient][0]));
	fEyeAngles[1] = (g_fClientEyeAng[iClient][1] + NormalizeAngle(fDesiredDir[1] - g_fClientEyeAng[iClient][1]));
	fEyeAngles[2] = 0.0;

	TeleportEntity(iClient, NULL_VECTOR, fEyeAngles, NULL_VECTOR);
	g_bClient_IsLookingAtPosition[iClient] = true;
}

float NormalizeAngle(float fAngle)
{
	fAngle = (fAngle - RoundToFloor(fAngle / 360.0) * 360.0);
	if (fAngle > 180.0)fAngle -= 360.0;
	else if (fAngle < -180.0)fAngle += 360.0;
	return fAngle;
}

void GetClientAimPosition(int iClient, float fAimPos[3])
{
	Handle hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], g_fClientEyeAng[iClient], MASK_SHOT, RayType_Infinite, Base_TraceFilter);
	TR_GetEndPosition(fAimPos, hResult); delete hResult;
}

bool GetVectorVisible(float fStart[3], float fEnd[3], int iMask = MASK_VISIBLE_AND_NPCS)
{
	Handle hResult = TR_TraceRayFilterEx(fStart, fEnd, iMask, RayType_EndPoint, Base_TraceFilter);
	float fFraction = TR_GetFraction(hResult); delete hResult; return (fFraction == 1.0);
}

bool Base_TraceFilter(int iEntity, int iContentsMask, int iData)
{
	return (iEntity == iData || HasEntProp(iEntity, Prop_Data, "m_eDoorState") && L4D_GetDoorState(iEntity) != DOOR_STATE_OPENED);
}

void SwitchWeaponSlot(int iClient, int iSlot)
{
	int iWeapon = GetClientWeaponInventory(iClient, iSlot);
	if (iWeapon == -1 || L4D_GetPlayerCurrentWeapon(iClient) == iWeapon)
		return;

	static char sWeaponName[64]; GetEdictClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	FakeClientCommand(iClient, "use %s", sWeaponName);
	//FakeClientCommand(iClient, "slot%d", iSlot);
}

bool IsWeaponSlotActive(int iClient, int iSlot)
{
	return (GetClientWeaponInventory(iClient, iSlot) == L4D_GetPlayerCurrentWeapon(iClient));
}

bool SurvivorHasSMG(int iClient)
{
	return ( g_iClientInvFlags[iClient] & FLAG_SMG != 0 );
}

bool SurvivorHasAssaultRifle(int iClient)
{
	static int iSlot, iItemFlags;
	
	iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1) return false;
	
	iItemFlags = g_iClientInvFlags[iClient];
	
	return ( iItemFlags & FLAG_ASSAULT ? true : false);
}

int SurvivorHasShotgun(int iClient)
{
	return ( (g_iClientInvFlags[iClient] & FLAG_SHOTGUN != 0) + (g_iClientInvFlags[iClient] & FLAG_SHOTGUN && g_iClientInvFlags[iClient] & FLAG_TIER2) );
}

// Used to return int, which was unused
bool SurvivorHasSniperRifle(int iClient)
{
	return ( g_iClientInvFlags[iClient] & FLAG_SNIPER != 0 );
}

int SurvivorHasTier3Weapon(int iClient)
{
	return ( (g_iClientInvFlags[iClient] & FLAG_TIER3 != 0) + (g_iClientInvFlags[iClient] & FLAG_M60 != 0) );
}

int SurvivorHasGrenade(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 2);
	if (iSlot == -1)return 0;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	switch(sWepName[7])
	{
		case 'p': return 1;
		case 'm': return 2;
		case 'v': return 3;
		default: return 0;
	}
}

//returns the same thing! :)
stock int SurvivorHasHealthKit(int iClient)
{
	return ( (g_iClientInvFlags[iClient] >> 22 & 1) + (g_iClientInvFlags[iClient] >> 20 & 2) + (g_iClientInvFlags[iClient] >> 4 & 1) * 3 );
}

int SurvivorHasMeleeWeapon(int iClient)
{
	return ( (g_iClientInvFlags[iClient] >> 6 & 1) + (g_iClientInvFlags[iClient] >> 16 & 1) );
}

int SurvivorHasPistol(int iClient)
{
	static int iSlot, iItemFlags;
	
	iSlot = GetClientWeaponInventory(iClient, 1);
	if (iSlot == -1) return 0;
	
	iItemFlags = g_iClientInvFlags[iClient];
	
	if ( iItemFlags & FLAG_PISTOL_EXTRA && !(iItemFlags & FLAG_PISTOL) )
		return 3;
	else
		return ( (GetEntProp(iSlot, Prop_Send, "m_isDualWielding") != 0 || GetEntProp(iSlot, Prop_Send, "m_hasDualWeapons") != 0) ? 2 : (iItemFlags & FLAG_PISTOL ? 1 : 0) );
}

int GetSurvivorTeamActiveItemCount(const L4D2WeaponId iWeaponID)
{
	int iCount, iWeaponSlot, iCurWeapon;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))continue;
		iCurWeapon = L4D_GetPlayerCurrentWeapon(i);

		for (int j = 0; j <= 5; j++)
		{
			iWeaponSlot = GetClientWeaponInventory(i, j);
			if (IsEntityExists(iWeaponSlot) && iCurWeapon == iWeaponSlot && L4D2_GetWeaponId(iWeaponSlot) == iWeaponID)
			{
				iCount++; 
				break;
			}
		}
	}
	return iCount;
}

int GetSurvivorTeamItemCount(const L4D2WeaponId iWeaponID)
{
	static int iCount, iWeaponSlot;
	iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))
			continue;
		for (int j = 0; j <= 5; j++)
		{
			iWeaponSlot = GetClientWeaponInventory(i, j);
			if (IsEntityExists(iWeaponSlot) && L4D2_GetWeaponId(iWeaponSlot) == iWeaponID)
			{
				iCount++; 
				break;
			}
		}
	}
	return iCount;
}

/*
	Use this whenever you need to count survivors with an item of certain category(inventory flag)
	e.g. an assault rifle, a melee weapon, a grenade etc
	
	Second argument ~ "AND"
	Sending multiple flags in one argument ~ "OR"
	Negative argument ~ "NOT", don't put multiple flags under one argument, 
	e.g.
	(FLAG_PISTOL | FLAG_PISTOL_EXTRA) will count survivors that carry either pistol(s) or Magnum
	(FLAG_SHOTGUN, FLAG_TIER1) – survivors with Tier 1 shotguns
	(-FLAG_PISTOL, FLAG_PISTOL_EXTRA) – survivors with Magnum specifically
*/
int GetSurvivorTeamInventoryCount(int iFlag, int iFlag2 = 0)
{
	static int iCount;
	static bool bNegate, bNegate2;
	
	bNegate = (iFlag < 0);
	bNegate2 = (iFlag2 < 0);
	
	iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))
			continue;
		if ( (bNegate ? ~g_iClientInvFlags[i] & -iFlag : g_iClientInvFlags[i] & iFlag)
			&& (iFlag2 ? (bNegate2 ? ~g_iClientInvFlags[i] & -iFlag2 : g_iClientInvFlags[i] & iFlag2) : 1) )
		{
			iCount++;
		}
	}
	return iCount;
}

bool IsWeaponReloading(int iWeapon, bool bIgnoreShotguns = true)
{
	if (!IsEntityExists(iWeapon) || !HasEntProp(iWeapon, Prop_Data, "m_bInReload"))
		return false;

	bool bInReload = !!GetEntProp(iWeapon, Prop_Data, "m_bInReload");
	if (bInReload && bIgnoreShotguns)
	{
		static int iItemFlags;
		iItemFlags = g_iItemFlags[iWeapon];
		
		return !(iItemFlags & FLAG_SHOTGUN);
	}
	return (bInReload);
}

Action CmdPrintFlag(int client, int args)
{
	int i, iItemFlags, iWeaponID, tier, size, iMaxAmmo;
	char sKey[64];
	Handle hKeys = CreateTrieSnapshot(g_hItemFlagMap);
	
	size = GetTrieSize(g_hItemFlagMap);
	
	PrintToServer("%d items in map", size);
	for (i = 0; i < size; i++)
	{
		GetTrieSnapshotKey(hKeys, i, sKey, 64);
		g_hItemFlagMap.GetValue(sKey, iItemFlags);
		g_hWeaponToIDMap.GetValue(sKey, iWeaponID);
		tier = g_iWeaponTier[iWeaponID];
		iMaxAmmo = g_iMaxAmmo[iWeaponID];
		PrintToServer("%s wepid %d flags %b tier %d maxammo %d", sKey, iWeaponID, iItemFlags, tier, iMaxAmmo);
	}
	
	delete hKeys;
	return Plugin_Handled;
}

Action CmdPrintTrie(int client, int args)
{
	PrintToServer("====== CmdPrintTrie ======");
	if (g_hItemFlagMap != INVALID_HANDLE)
		PrintTrie(g_hCheckCases, "g_hCheckCases", 0);
	else
		PrintToServer("!!! g_hCheckCases does not exist!");
	
	if (g_hItemFlagMap != INVALID_HANDLE)
		PrintTrie(g_hItemFlagMap, "g_hItemFlagMap", 0);
	else
		PrintToServer("!!! g_hItemFlagMap does not exist!");
	
	if (g_hWeaponMap != INVALID_HANDLE)
		PrintTrie(g_hWeaponMap, "g_hWeaponMap", 0);
	else
		PrintToServer("!!! g_hWeaponMap does not exist!");
	
	if (g_hWeaponSpawnMap != INVALID_HANDLE)
		PrintTrie(g_hWeaponSpawnMap, "g_hWeaponSpawnMap", 1);
	else
		PrintToServer("!!! g_hWeaponSpawnMap does not exist!");
	
	if (g_hWeaponToIDMap != INVALID_HANDLE)
		PrintTrie(g_hWeaponToIDMap, "g_hWeaponToIDMap", 0);
	else
		PrintToServer("!!! g_hWeaponToIDMap does not exist!");
	
	return Plugin_Handled;
}

void PrintTrie(StringMap map, const char[] sMapName = "", int type = 0)
{
	int value;
	char sKey[64], sBuffer[64];
	Handle hKeys = CreateTrieSnapshot(map);
	int size = GetTrieSize(map);
	PrintToServer("=== Map %s has %d elements", sMapName, size);
	
	for (int i = 0; i < size; i++)
	{
		value = 0;
		sKey[0] = EOS;
		sBuffer[0] = EOS;
		GetTrieSnapshotKey(hKeys, i, sKey, 64);
		if (type == 0)
		{
			map.GetValue(sKey, value);
			PrintToServer("key %s value %d", sKey, value);
		}
		else
		{
			map.GetString(sKey, sBuffer, 64);
			PrintToServer("key %s value %s", sKey, sBuffer);
		}
	}
}

Action CmdHasKey(int client, int args)
{
	int flags = -99;
	char sKey[64];
	
	GetCmdArg(1, sKey, 64);
	
	if(GetCmdArgInt(2))
		TrimString(sKey);
	
	if(GetTrieValue(g_hItemFlagMap, sKey, flags))
		PrintToServer("key find");
	else
		PrintToServer("key no find");
	
	PrintToServer("%s %d", sKey, flags);
	
	return Plugin_Handled;
}

Action CmdInvDbg(int client, int args)
{
	static char sWeaponName[64], sClientName[128], sBuffer[128];
	static int iWpnSlot;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsClientSurvivor(i) )
			continue;
		
		GetClientName(i, sClientName, sizeof(sClientName));
		PrintToServer("Client %s", sClientName);
		sBuffer[0] = EOS;
		for (int j = 0; j <= 23; j++)
		{
			if (g_iClientInvFlags[i] & (1 << j))
			{
				char flag[12];
				strcopy(flag, sizeof(flag), IBItemFlagName[j]);
				Format(sBuffer, sizeof(sBuffer), "%s\n%s", sBuffer, flag);
			}
		}
		if (g_iClientInventory[i][0] != -1)
			PrintToServer("Primary ammo %d, MaxAmmo %d, HasMelee %d, HasMedkit %d", (GetWeaponClip1(g_iClientInventory[i][0]) + GetClientPrimaryAmmo(i)),
			GetWeaponMaxAmmo(g_iClientInventory[i][0]), SurvivorHasMeleeWeapon(i), SurvivorHasHealthKit(i));
		PrintToServer("Inventory flags %b %s", g_iClientInvFlags[i], sBuffer);
		for (int j = 0; j <= 5; j++)
		{
			iWpnSlot = g_iClientInventory[i][j];
			if ( iWpnSlot != -1 )
			{
				GetEntityClassname(iWpnSlot, sWeaponName, sizeof(sWeaponName));
				PrintToServer("%s", sWeaponName);
			}
		}
	}
	
	return Plugin_Handled;
}

//	i've spent too much time on this
//	but hey, it helped me fix the function
//	(it was two missing minus signs)
Action CmdInvCount(int client, int args)
{
	bool bNegate;
	int i, j, iCount, iFlag, iFlag2, arguments;
	char sArgs[128], sBuffer[2][64], sFlag[8][32], sFlag2[8][32];
	
	PrintToServer("Testing survivor count with inventory(tm)");
	
	if ( GetCmdArgString(sArgs, sizeof(sArgs)) < 1 )
	{
		ReplyToCommand(client, "Empty argument");
		return Plugin_Handled;
	}
	//ReplyToCommand(client, "\"%s\"", sArgs);
	arguments = ExplodeString(sArgs, " ", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]), true);
	if ( arguments < 1 )
	{
		ReplyToCommand(client, "Could not parse any arguments");
		return Plugin_Handled;
	}
	
	ArrayList hFlags = new ArrayList(32);
	if ( StrContains(sBuffer[0][0], "-") == 0 )
	{
		ReplyToCommand(client, "NOT");
		bNegate = true;
	}
	i = view_as<int>(bNegate);
	j = ExplodeString(sBuffer[0][i], "|", sFlag, sizeof(sFlag), sizeof(sFlag[]), true);
	for (i = 0; i < j; i++)
	{
		ReplyToCommand(client, "\"%s\"", sFlag[i]);
		hFlags.PushString(sFlag[i]);
	}
	
	for (i = 0; i < sizeof(IBItemFlagName); i++)
	{
		j = FindStringInArray(hFlags, IBItemFlagName[i]);
		if ( j != -1)
		{
			iFlag |= 1 << i;
			RemoveFromArray(hFlags, j);
		}
	}
	
	PrintToServer("First argument %d bits %b", iFlag, iFlag);
	if (bNegate) iFlag = -iFlag;
	
	if( arguments > 1 )
	{
		ReplyToCommand(client, "AND");
		ClearArray(hFlags);
		bNegate = false;
		
		if ( StrContains(sBuffer[1][0], "-") == 0 )
		{
			ReplyToCommand(client, "NOT");
			bNegate = true;
		}
		i = view_as<int>(bNegate);
		j = ExplodeString(sBuffer[1][i], "|", sFlag2, sizeof(sFlag2), sizeof(sFlag2[]), true);
		for (i = 0; i < j; i++)
		{
			ReplyToCommand(client, "\"%s\"", sFlag2[i]);
			PushArrayString(hFlags, sFlag2[i]);
		}
		
		for (i = 0; i < sizeof(IBItemFlagName); i++)
		{
			j = FindStringInArray(hFlags, IBItemFlagName[i]);
			if ( j != -1)
			{
				iFlag2 |= 1 << i;
				RemoveFromArray(hFlags, j);
			}
		}
		
		PrintToServer("Second argument %d bits %b", iFlag2, iFlag2);
		if (bNegate) iFlag2 = -iFlag2;
	}
	else
		ReplyToCommand(client, "No second argument");

	iCount = GetSurvivorTeamInventoryCount(iFlag, iFlag2);
	ReplyToCommand(client, "%d players qualified", iCount);
	
	delete hFlags;
	return Plugin_Handled;
}

Action CmdBotFakeCmd(int client, int args)
{
	char sArgs[128];
	
	if ( GetCmdArgString(sArgs, sizeof(sArgs)) < 1 )
	{
		ReplyToCommand(client, "Empty argument");
		return Plugin_Handled;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsClientSurvivor(i) )
		{
			FakeClientCommand(i, "%s", sArgs);
		}
	}
	
	return Plugin_Handled;
}

Action CmdSetTestSubj(int client, int args)
{
	static int i, iClient;
	static char sBuffer[64], sClientName[128];
	
	iClient = 0;
	if ( GetCmdArgString(sBuffer, sizeof(sBuffer)) < 1 )
	{
		ReplyToCommand(client, "No name specified");
	}
	else
	{
		TrimString(sBuffer);
		for (i = 1; i <= MaxClients; i++)
		{
			GetClientName(i, sClientName, sizeof(sClientName));
			if ( StrContains(sClientName, sBuffer, false) > -1 )
			{
				iClient = i;
				break;
			}
		}
	}
	
	if(!iClient)
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if ( IsClientSurvivor(i) )
			{
				iClient = i;
				break;
			}
		}
	}
	
	if(iClient)
	{
		GetClientName(iClient, sClientName, sizeof(sClientName));
		g_iTestSubject = iClient;
		ReplyToCommand(client, "Set client %d %s as test subject", iClient, sClientName);
	}
	else
	{
		ReplyToCommand(client, "Could not set test subject");
	}
	
	return Plugin_Handled;
}

Action CmdGetClosestNav(int client, int args)
{
	static bool bAnyZ, bCheckLOS, bGround;
	static int choice, iTeam, iArea;
	static float fDist, fTargetPos[3], t;
	static char sEntClassname[64], sClientName[128];
	
	choice = GetCmdArgInt(1);
	
	fDist = GetCmdArgFloat(2);
	if( fDist <= 0.0 || fDist > 1000.0)
	{
		ReplyToCommand(client, "Invalid distance %.1f", fDist);
		return Plugin_Handled;
	}
	
	bAnyZ = (GetCmdArgInt(3) != 0);
	bCheckLOS = (GetCmdArgInt(4) != 0);
	bGround = (GetCmdArgInt(5) != 0);
	
	if (choice == 1)
	{
		if(client == 0)
		{
			ReplyToCommand(client, "Can not use from console if first argument != 0");
			return Plugin_Handled;	
		}
		g_iTestTraceEnt = -1;
		Handle hTrace = TR_TraceRayFilterEx(g_fClientEyePos[client], g_fClientEyeAng[client], MASK_SHOT, RayType_Infinite, CTraceFilterItems);
		delete hTrace;
		if (g_iTestTraceEnt == -1)
		{
			ReplyToCommand(client, "No item found");
			return Plugin_Handled;
		}
		GetEntityClassname(g_iTestTraceEnt, sEntClassname, sizeof(sEntClassname));
		ReplyToCommand(client, "Finding nearest area for %s", sEntClassname);
		GetEntityAbsOrigin(g_iTestTraceEnt, fTargetPos);
		ReplyToCommand(client, "Position %.2f %.2f %.2f", fTargetPos[0], fTargetPos[1], fTargetPos[2]);
		iTeam = GetClientTeam(client);
	}
	else
	{
		if ( !IsValidClient(g_iTestSubject) || !IsPlayerAlive(g_iTestSubject) )
		{
			ReplyToCommand (client, "Not a valid test subject");
			return Plugin_Handled;	
		}
		GetClientName(g_iTestSubject, sClientName, sizeof(sClientName));
		ReplyToCommand(client, "Finding nearest area for client %s", sClientName);
		fTargetPos = g_fClientAbsOrigin[g_iTestSubject];
		ReplyToCommand(client, "Position %.2f %.2f %.2f", fTargetPos[0], fTargetPos[1], fTargetPos[2]);
		iTeam = GetClientTeam(g_iTestSubject);
	}
	
	StartProfiling(g_pProf);
	iArea = L4D_GetNearestNavArea(fTargetPos, fDist, bAnyZ, bCheckLOS, bGround, iTeam);
	StopProfiling(g_pProf);
	t = GetProfilerTime(g_pProf);
	ReplyToCommand(client, "L4D_GetNearestNavArea(maxDist %.1f anyZ %b checkLOS %b checkGround %b teamID %d)\nreturn %d in %.8f seconds",fDist,bAnyZ,bCheckLOS,bGround,iTeam,view_as<int>(iArea),t);
	return Plugin_Handled;
}

Action CmdGetItemInfo(int client, int args)
{
	static char sEntClassname[64], sWeaponName[64], sBuffer[128];
	static int iItemFlags, iWeaponID;
	
	if(client == 0)
	{
		ReplyToCommand(client, "Can not use from console");
		return Plugin_Handled;	
	}
	
	g_iTestTraceEnt = -1;
	Handle hTrace = TR_TraceRayFilterEx(g_fClientEyePos[client], g_fClientEyeAng[client], MASK_SHOT, RayType_Infinite, CTraceFilterItems);
	delete hTrace;
	if (g_iTestTraceEnt == -1)
	{
		ReplyToCommand(client, "No item found");
		return Plugin_Handled;
	}
	
	iItemFlags = 0;
	iWeaponID = 0;
	GetEntityClassname(g_iTestTraceEnt, sEntClassname, sizeof(sEntClassname));
	GetWeaponClassname(g_iTestTraceEnt, sWeaponName, sizeof(sWeaponName));
	g_hItemFlagMap.GetValue(sWeaponName, iItemFlags);
	g_hWeaponToIDMap.GetValue(sWeaponName, iWeaponID);
	ReplyToCommand(client, "Entity %d \"%s\", weapon \"%s\"", g_iTestTraceEnt, sEntClassname, sWeaponName);
	sBuffer[0] = EOS;
	for (int j = 0; j <= 23; j++)
	{
		if (g_iItemFlags[g_iTestTraceEnt] & (1 << j))
		{
			char flag[12];
			strcopy(flag, sizeof(flag), IBItemFlagName[j]);
			Format(sBuffer, sizeof(sBuffer), "%s %s", sBuffer, flag);
		}
	}
	ReplyToCommand(client, "Inventory flags: %s\n%b\n%b", sBuffer, g_iItemFlags[g_iTestTraceEnt], iItemFlags);
	ReplyToCommand(client, "L4D2_GetWeaponId %d, g_iWeaponID %d, g_hWeaponToIDMap %d", L4D2_GetWeaponId(g_iTestTraceEnt), g_iWeaponID[g_iTestTraceEnt], iWeaponID);
	
	return Plugin_Handled;
}

bool CTraceFilterItems(int iEntity, int iContentsMask)
{
	static char sEntClassname[64];
	//GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
	//PrintToServer("CTraceFilterItems: %d %s, %d", iEntity, sEntClassname, g_iWeaponID[iEntity]);
	if (g_iTestTraceEnt == -1 && GetWeaponClassname(iEntity, sEntClassname, sizeof(sEntClassname)))
		g_iTestTraceEnt = iEntity;
	return true;
}

Action CmdTestPath(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "Use this command as a player while looking at an entity");
		return Plugin_Handled;	
	}
	
	static bool bIsReachable;
	static int iEntity, iTeam, iStartArea, iGoalArea, iLeaderArea, choice, argument;
	static char sEntClassname[64], sClientName[128];
	static float fDist, argument2, t, fTargetPos[3];
	
	iEntity = GetClientAimTarget(client, false);
	if ((iEntity == -1) || (!IsValidEntity (iEntity)))
	{
		ReplyToCommand (client, "Invalid entity");
		return Plugin_Handled;	
	}
	if ( !IsValidClient(g_iTestSubject) || !IsPlayerAlive(g_iTestSubject) )
	{
		ReplyToCommand (client, "Test subject must be valid/alive");
		return Plugin_Handled;	
	}
	
	choice = GetCmdArgInt(1);
	argument = GetCmdArgInt(2);
	argument2 = GetCmdArgFloat(3);
	
	iTeam = GetClientTeam(g_iTestSubject);
	GetClientName(g_iTestSubject, sClientName, sizeof(sClientName));
	GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
	GetEntityAbsOrigin(iEntity, fTargetPos);
	iStartArea = L4D_GetNearestNavArea(g_fClientAbsOrigin[g_iTestSubject], 140.0, true, true, false, iTeam);
	iLeaderArea = L4D_GetNearestNavArea(g_fClientAbsOrigin[g_iTeamLeader], 140.0, true, true, false, iTeam);
	iGoalArea = L4D_GetNearestNavArea(fTargetPos, 140.0, true, true, false, iTeam);
	ReplyToCommand(client, "Client %s Entity %s", sClientName, sEntClassname);
	
	switch(choice)
	{
		case 6:
		{
			char sLeaderName[128];
			GetClientName(g_iTeamLeader, sLeaderName, sizeof(sLeaderName));
			ReplyToCommand(client, "Team leader: %s", sLeaderName);
			StartProfiling(g_pProf);
			bool bCanRegroup;
			float fScavengePos[3];
			if (iGoalArea)
				LBI_GetClosestPointOnNavArea(iGoalArea, fTargetPos, fScavengePos);
			else
			{
				StopProfiling(g_pProf);
				t = GetProfilerTime(g_pProf);
				ReplyToCommand(client, "Could not find nav area for item, took %.8f seconds", t);
				return Plugin_Handled;
			}
			float fDistanceToItem = GetClientDistanceToItem(g_iTestSubject, iEntity);
			if (fDistanceToItem < 0.0)
			{
				StopProfiling(g_pProf);
				t = GetProfilerTime(g_pProf);
				ReplyToCommand(client, "Failed to calculate distance to item, took %.8f seconds", t);
				return Plugin_Handled;
			}
			if (!iLeaderArea)
			{
				StopProfiling(g_pProf);
				t = GetProfilerTime(g_pProf);
				ReplyToCommand(client, "Could not find team leader nav area, took %.8f seconds", t);
				return Plugin_Handled;
			}
			bCanRegroup = L4D2_NavAreaBuildPath(view_as<Address>(iGoalArea), view_as<Address>(iLeaderArea), fDistanceToItem, iTeam, false);
			if (!bCanRegroup)
			{
				StopProfiling(g_pProf);
				t = GetProfilerTime(g_pProf);
				ReplyToCommand(client, "Path from item to leader is either longer or unavailable, took %.8f seconds", t);
				return Plugin_Handled;
			}
			float fDistanceToRegroup = GetNavDistance(fScavengePos, g_fClientAbsOrigin[g_iTeamLeader], iEntity, false);
			if (fDistanceToRegroup < 0.0)
			{
				StopProfiling(g_pProf);
				t = GetProfilerTime(g_pProf);
				ReplyToCommand(client, "Failed to calculate distance to regroup to leader, took %.8f seconds", t);
				return Plugin_Handled;
			}
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "fDistanceToItem %.2f fDistanceToRegroup %.2f in %.8f seconds", fDistanceToItem, fDistanceToRegroup, t);
		}
		case 5:
		{
			StartProfiling(g_pProf);
			fDist = GetClientDistanceToItem(g_iTestSubject, iEntity, (argument != 0));
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "GetClientDistanceToItem fDist %.2f in %.8f seconds", fDist, t);
		}
		case 4:
		{
			if (!iStartArea || !iGoalArea)
			{
				ReplyToCommand(client, "Could not get nearest area, start %d goal %d", iStartArea, iGoalArea);
				return Plugin_Handled;
			}
			StartProfiling(g_pProf);
			bIsReachable = L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), argument2, iTeam, (argument != 0));
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "L4D2_NavAreaBuildPath %b in %.8f seconds", bIsReachable, t);
		}
		case 3:
		{
			StartProfiling(g_pProf);
			fDist = GetClientTravelDistance(g_iTestSubject, fTargetPos, (argument != 0));
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "GetClientTravelDistance fDist %.2f in %.8f seconds", fDist, t);
		}
		case 2:
		{
			StartProfiling(g_pProf);
			fDist = GetEntityTravelDistance(g_iTestSubject, iEntity, (argument != 0));
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "GetEntityTravelDistance fDist %.2f in %.8f seconds", fDist, t);
		}
		case 1:
		{
			StartProfiling(g_pProf);
			fDist = L4D2_NavAreaTravelDistance(g_fClientAbsOrigin[g_iTestSubject], fTargetPos, (argument != 0));
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "L4D2_NavAreaTravelDistance fDist %.2f in %.8f seconds", fDist, t);
		}
		case 0:
		{
			StartProfiling(g_pProf);
			bIsReachable = L4D2_IsReachable(g_iTestSubject, fTargetPos);
			StopProfiling(g_pProf);
			t = GetProfilerTime(g_pProf);
			ReplyToCommand(client, "L4D2_IsReachable %b in %.8f seconds", bIsReachable, t);
		}
		default: ReplyToCommand(client, "Wrong argument %d", choice);
	}
	return Plugin_Handled;	
}

Action CmdRecheck(int client, int args)
{
	static int count, k;
	static float t;
	static char sEntClassname[64];
	
	k = GetCmdArgInt(1);
	StartProfiling(g_pProf);
	for (int i = 0; i < MAXENTITIES; i++)
	{
		g_iItem_Used[i] = 0;
		g_iWeaponID[i] = 0;
		g_iItemFlags[i] = 0;
		if ( !IsValidEdict(i) ) continue;
		GetEntityClassname(i, sEntClassname, sizeof(sEntClassname));
		CheckEntityForStuff(i, sEntClassname);
		if (k && g_iWeaponID[i])
			PrintToServer("%s %d %b", sEntClassname, g_iWeaponID[i], g_iItemFlags[i]);
		count++;
	}
	StopProfiling(g_pProf);
	t = GetProfilerTime(g_pProf);
	ReplyToCommand(client, "Rechecked %d entities, took %.8f seconds", count, t);
	
	return Plugin_Handled;
}

Action CmdWepTiers(int client, int args)
{
	for (int i = 0; i < 38; i++) // 37 L4D2WeaponId_RifleM60
	{
		PrintToServer("%s %d", IBWeaponName[i], L4D2_GetIntWeaponAttribute(IBWeaponName[i], L4D2IWA_Tier));
	}
	
	return Plugin_Handled;
}

Action CmdVScript(int client, int args)
{
	float fPos[3];
	float radius = GetCmdArgFloat(1);
	float t1 = 0.0;
	float t2 = 0.0;
	int iClient = (client | 0);
	
	if(iClient < 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if ( !IsClientSurvivor(i) )
				continue;
			iClient = i;
			break;
		}
	}
	
	if(radius == 0.0)
		radius = 200.0;
	
	ReplyToCommand(client, "Testing on client id %d radius %.1f", iClient, radius);
	
	StartProfiling(g_pProf);
	LBI_TryGetPathableLocationWithin(iClient, radius, fPos);
	StopProfiling(g_pProf);
	t1 = GetProfilerTime(g_pProf);
	ReplyToCommand(client, "LBI found pos %.2f %.2f %.2f in %.8f seconds", fPos[0], fPos[1], fPos[2], t1);
	
	StartProfiling(g_pProf);
	VScript_TryGetPathableLocationWithin(iClient, radius, fPos);
	StopProfiling(g_pProf);
	t2 = GetProfilerTime(g_pProf);
	ReplyToCommand(client, "VS found pos %.2f %.2f %.2f in %.8f seconds", fPos[0], fPos[1], fPos[2], t2);
	
	return Plugin_Handled;
}

stock float GetWeaponNextFireTime(int iWeapon)
{
	return (GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack"));
}

stock int GetWeaponClip1(int iWeapon) 
{
	return (GetEntProp(iWeapon, Prop_Send, "m_iClip1"));
}

stock int GetWeaponClipSize(int iWeapon)
{
	return (SDKCall(g_hGetMaxClip1, iWeapon));
}

stock int GetTeamPlayerCount(int iTeam, bool bOnlyAlive=false, bool bOnlyBots=false)
{
	int iCount;
	int iTeamCount = GetTeamClientCount(iTeam);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (!bOnlyAlive || IsPlayerAlive(i)) && (!bOnlyBots || IsFakeClient(i)) && GetClientTeam(i) == iTeam)
		{
			iCount++;
			if (iCount >= iTeamCount)break;
		}
	}
	return iCount;
}

stock int IsFinaleEscapeVehicleArrived()
{
	return (L4D2_IsGenericCooperativeMode() && L4D_IsMissionFinalMap() && L4D2_GetCurrentFinaleStage() == 6);
}

stock int GetCurrentGameDifficulty()
{
	if (!L4D2_IsGenericCooperativeMode())return 2;
	switch(g_sCvar_GameDifficulty[0])
	{
		case 'E', 'e': return 1;
		case 'H', 'h': return 3;
		case 'I', 'i': return 4;
		default: return 2;
	}
}

stock int GetClientRealHealth(int iClient)
{
	return RoundFloat(GetClientHealth(iClient) + L4D_GetTempHealth(iClient));
}

bool IsSurvivorBotBlindedByVomit(int iClient)
{
	return (GetGameTime() < g_fSurvivorBot_VomitBlindedTime[iClient]);
}

stock bool IsEntityOnFire(int iEntity)
{
	return (GetEntityFlags(iEntity) & FL_ONFIRE) != 0;
}

stock bool IsValidClient(int iClient) 
{
	return (1 <= iClient <= MaxClients && IsClientInGame(iClient)); 
}

stock bool IsClientSurvivor(int iClient)
{
	return (IsValidClient(iClient) && GetClientTeam(iClient) == 2 && IsPlayerAlive(iClient));
}

stock void SetVectorToZero(float fVec[3])
{
	for (int i = 0; i < 3; i++)fVec[i] = 0.0;
}

stock bool GetEntityAbsOrigin(int iEntity, float fResult[3])
{
	if (!IsEntityExists(iEntity))return false;
	SDKCall(g_hCalcAbsolutePosition, iEntity);
	GetEntPropVector(iEntity, Prop_Data, "m_vecAbsOrigin", fResult);
	return (IsValidVector(fResult));
}

stock bool GetEntityCenteroid(int iEntity, float fResult[3])
{
	int iOffset; static char sClass[64];
	GetEntityAbsOrigin(iEntity, fResult);

	if (!GetEntityNetClass(iEntity, sClass, sizeof(sClass)) || (iOffset = FindSendPropInfo(sClass, "m_vecMins")) == -1)
		return false;

	float fMins[3], fMaxs[3];
	GetEntDataVector(iEntity, iOffset, fMins);
	GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", fMaxs);

	fResult[0] += (fMins[0] + fMaxs[0]) * 0.5;
	fResult[1] += (fMins[1] + fMaxs[1]) * 0.5;
	fResult[2] += (fMins[2] + fMaxs[2]) * 0.5;

	return true;
}

void LBI_GetNavAreaCenter(int iNavArea, float fResult[3])
{
	Address hAddress = view_as<Address>(iNavArea);	
	fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_Center), NumberType_Int32));
	fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_Center + 4), NumberType_Int32));
	fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_Center + 8), NumberType_Int32));
}

int LBI_GetNavAreaParent(int iNavArea)
{
	return (LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_Parent), NumberType_Int32));
}

bool LBI_IsDamagingNavArea(int iNavArea, bool bIgnoreWitches = false)
{	
	int iTickCount = LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_DamagingTickCount), NumberType_Int32);
	if (GetGameTickCount() <= iTickCount)
	{
		if (!bIgnoreWitches && L4D2_GetWitchCount() > 0)
		{
			int iWitch = INVALID_ENT_REFERENCE;
			float fWitchPos[3], fClosePoint[3];
			while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
			{
				GetEntityAbsOrigin(iWitch, fWitchPos);
				LBI_GetClosestPointOnNavArea(iNavArea, fWitchPos, fClosePoint);
				if (GetVectorDistance(fWitchPos, fClosePoint, true) <= 14400.0)return false;
			}
		}
		return true;
	}
	return false;
}

bool LBI_IsDamagingPosition(const float fPos[3])
{
	int iCloseArea = L4D_GetNearestNavArea(fPos);
	return (iCloseArea && LBI_IsDamagingNavArea(iCloseArea));
}

void LBI_GetNavAreaCorners(int iNavArea, float fNWCorner[3], float fSECorner[3])
{
	Address hAddress = view_as<Address>(iNavArea);
	for (int i = 0; i < 3; i++)
	{
		fNWCorner[i] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner + (4 * i)), NumberType_Int32));
		fSECorner[i] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner + (4 * i)), NumberType_Int32));
	}
}

void LBI_GetClosestPointOnNavArea(int iNavArea, const float fPos[3], float fClosePoint[3])
{
	float fNWCorner[3], fSECorner[3];
	LBI_GetNavAreaCorners(iNavArea, fNWCorner, fSECorner);

	float fNewPos[3];
	fNewPos[0] = fsel((fPos[0] - fNWCorner[0]), fPos[0], fNWCorner[0]);
	fNewPos[0] = fsel((fNewPos[0] - fSECorner[0]), fSECorner[0], fNewPos[0]);
	
	fNewPos[1] = fsel((fPos[1] - fNWCorner[1]), fPos[1], fNWCorner[1]);
	fNewPos[1] = fsel((fNewPos[1] - fSECorner[1]), fSECorner[1], fNewPos[1]);

	fNewPos[2] = LBI_GetNavAreaZ(iNavArea, fNewPos[0], fNewPos[1]);

	fClosePoint = fNewPos;
}

float LBI_GetNavAreaZ(int iNavArea, float x, float y)
{
	float fNWCorner[3], fSECorner[3];
	LBI_GetNavAreaCorners(iNavArea, fNWCorner, fSECorner);

	float fInvDXCorners = view_as<float>(LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_InvDXCorners), NumberType_Int32));
	float fInvDYCorners = view_as<float>(LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_InvDYCorners), NumberType_Int32));

	float u = (x - fNWCorner[0]) * fInvDXCorners;
	float v = (y - fNWCorner[1]) * fInvDYCorners;
	
	u = fsel(u, u, 0.0);
	u = fsel(u - 1.0, 1.0, u);

	v = fsel(v, v, 0.0);
	v = fsel(v - 1.0, 1.0, v);

	float fNorthZ = fNWCorner[2] + u * (fSECorner[2] - fNWCorner[2]);
	float fSouthZ = fNWCorner[2] + u * (fSECorner[2] - fNWCorner[2]);

	return (fNorthZ + v * (fSouthZ - fSouthZ));
}

stock float fsel(float fComparand, float fValGE, float fLT)
{
	return (fComparand >= 0.0 ? fValGE : fLT);
}

void LBI_GetNavAreaCorner(int iNavArea, int iCorner, float fResult[3])
{
	Address hAddress = view_as<Address>(iNavArea);
	switch(iCorner)
	{
		case 0:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+8), NumberType_Int32));
		}
		case 1:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+8), NumberType_Int32));
		}
		case 2:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+8), NumberType_Int32));
		}
		case 3:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+8), NumberType_Int32));
		}
		default:
		{
			return;
		}
	}
}

bool LBI_IsNavAreaPartiallyVisible(int iNavArea, const float fEyePos[3], int iIgnoreEntity = -1)
{
	float fOffset = (0.75 * HUMAN_HEIGHT);
	
	float fCenter[3]; LBI_GetNavAreaCenter(iNavArea, fCenter);
	fCenter[2] += fOffset;

	Handle hResult = TR_TraceRayFilterEx(fEyePos, fCenter, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, CTraceFilterNoNPCsOrPlayer, iIgnoreEntity);
	float fFraction = TR_GetFraction(hResult); delete hResult;
	if (fFraction == 1.0)return true;

	float fEyeToCenter[3];
	MakeVectorFromPoints(fEyePos, fCenter, fEyeToCenter);
	NormalizeVector(fEyeToCenter, fEyeToCenter);

	float fCorner[3], fEyeToCorner[3];
	for (int i = 0; i < 4; ++i)
	{
		LBI_GetNavAreaCorner(iNavArea, i, fCorner);
		fCorner[2] += fOffset;

		MakeVectorFromPoints(fEyePos, fCorner, fEyeToCorner);
		NormalizeVector(fEyeToCorner, fEyeToCorner);
		if (GetVectorDotProduct(fEyeToCorner, fEyeToCenter) >= 0.98)
			continue;

		fCorner[2] += fOffset;
		hResult = TR_TraceRayFilterEx(fEyePos, fCorner, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, CTraceFilterNoNPCsOrPlayer, iIgnoreEntity);
		fFraction = TR_GetFraction(hResult); delete hResult;
		if (fFraction == 1.0)return true;
	}

	return false;
}

bool CTraceFilterNoNPCsOrPlayer(int iEntity, int iContentsMask, int iIgnore)
{
	if (iEntity == 0 || IsValidClient(iEntity))
		return true;

	static char sClassname[64]; GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	if (strncmp(sClassname, "func_door", 9) == 0 || strncmp(sClassname, "prop_door", 9) == 0)
		return false;

	if (strcmp(sClassname, "func_brush") == 0)
	{
		int iSolidity = GetEntProp(iEntity, Prop_Data, "m_iSolidity");
		return (iSolidity == 2);
	}

	if ((strcmp(sClassname, "func_breakable_surf") == 0 || strcmp(sClassname, "func_breakable") == 0 && GetEntityHealth(iEntity) > 0) && GetEntProp(iEntity, Prop_Data, "m_takedamage") == 2)
		return false;

	if (strcmp(sClassname, "func_playerinfected_clip") == 0)
		return false;

	return (iEntity != iIgnore);
}

bool LBI_IsPositionInsideCheckpoint(const float fPos[3])
{
	if (!L4D2_IsGenericCooperativeMode())
		return false;

	Address pNavArea = view_as<Address>(L4D_GetNearestNavArea(fPos));
	if (pNavArea == Address_Null)return false;

	int iAttributes = L4D_GetNavArea_SpawnAttributes(pNavArea);
	return ((iAttributes & NAV_SPAWN_FINALE) == 0 && (iAttributes & NAV_SPAWN_CHECKPOINT) != 0);
}

float GetClientTravelDistance(int iClient, float fGoalPos[3], bool bSquared = false)
{
	if (!g_bMapStarted)return -1.0;
	
	static bool bIsReachable;
	static int iStartArea, iGoalArea, iArea, iCount;
	static float t;

	StartProfiling(g_pProf);
	iStartArea = g_iClientNavArea[iClient];
	if (!iStartArea)
	{
		StopProfiling(g_pProf);
		t = GetProfilerTime(g_pProf);
		if(g_bCvar_Debug && t > 0.001)
			PrintToServer("GetClientTravelDist took %.8f seconds !iStartArea", t);
		return -1.0;
	}

	iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, false, GetClientTeam(iClient)); // need to think about which checkLOS and checkGround bools to put here
	if (!iGoalArea)
	{
		StopProfiling(g_pProf);
		t = GetProfilerTime(g_pProf);
		if(g_bCvar_Debug && t > 0.001)
			PrintToServer("GetClientTravelDist took %.8f seconds !iGoalArea", t);
		return -1.0;
	}

	//if (!L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), 0.0, GetClientTeam(iClient), false))
	bIsReachable = L4D2_IsReachable(iClient, fGoalPos);
	if (!bIsReachable)
	{
		StopProfiling(g_pProf);
		t = GetProfilerTime(g_pProf);
		if(g_bCvar_Debug && t > 0.001)
		{
			char sClientName[128];
			GetClientName(iClient, sClientName, sizeof(sClientName));
			PrintToServer("GetClientTravelDist took %.8f seconds !IsReachable, Client %s, bIsReachable %b, fGoalPos %.1f %.1f %.1f", t, sClientName, bIsReachable, fGoalPos[0], fGoalPos[1], fGoalPos[2]);
		}
		return -1.0;
	}

	iArea = LBI_GetNavAreaParent(iGoalArea);
	if (!iArea)
	{
		StopProfiling(g_pProf);
		t = GetProfilerTime(g_pProf);
		if(g_bCvar_Debug && t > 0.001)
			PrintToServer("GetClientTravelDist took %.8f seconds !iArea", t);
		return GetVectorDistance(g_fClientAbsOrigin[iClient], fGoalPos, bSquared);
	}

	float fClosePoint[3]; LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	float fDistance = GetVectorDistance(fClosePoint, fGoalPos, bSquared);
	float fParentCenter[3];
	
	iCount = 0;
	for (; LBI_GetNavAreaParent(iArea); iArea = LBI_GetNavAreaParent(iArea))
	{
		if (iCount > 50)
			break;
		LBI_GetClosestPointOnNavArea(LBI_GetNavAreaParent(iArea), fGoalPos, fParentCenter);
		LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
		fDistance += GetVectorDistance(fClosePoint, fParentCenter, bSquared);
		iCount++;
	}
	//if(g_bCvar_Debug && iCount > 20)
	//	PrintToServer("GetClientTravelDist %d iterations of lag loop", iCount);

	LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	fDistance += GetVectorDistance(g_fClientAbsOrigin[iClient], fClosePoint, bSquared);
	
	StopProfiling(g_pProf);
	t = GetProfilerTime(g_pProf);
	if(g_bCvar_Debug && t > 0.001)
	{
		char sClientName[128];
		GetClientName(iClient, sClientName, sizeof(sClientName));
		PrintToServer("GetClientTravelDist took %.8f seconds, iCount %d, Client %s, bIsReachable %b, fDistance %.2f, fGoalPos %.1f %.1f %.1f",
			t, iCount, sClientName, bIsReachable, fDistance, fGoalPos[0], fGoalPos[1], fGoalPos[2]);
	}
	return fDistance;
}

//to replace GetEntityTravelDistance()
float GetClientDistanceToItem(int iClient, int iEntity, bool bIgnoreNavBlockers = true)
{
	if (!g_bMapStarted)
		return -1.0;
	
	static bool bIsReachable;
	static int iGoalArea;
	static float fDistance, fEntityPos[3], fTargetPos[3]/*, t*/;
	
	//StartProfiling(g_pProf);
	//get or calculate target position
	iGoalArea = 0;
	if(IsValidClient(iEntity))
		fTargetPos = g_fClientAbsOrigin[iEntity];
	else
	{
		GetEntityAbsOrigin(iEntity, fEntityPos);
		iGoalArea = L4D_GetNearestNavArea(fEntityPos, 300.0, true, true, false, GetClientTeam(iClient));
		if (!iGoalArea)
			return -1.0;
		L4D_GetNavAreaCenter(view_as<Address>(iGoalArea), fTargetPos);
	}
	
	//if bot, use L4D2_IsReachable
	if (IsFakeClient(iClient))
	{
		bIsReachable = L4D2_IsReachable(iClient, fEntityPos);
		if (!bIsReachable)
			return -1.0;
	}
	
	fDistance = L4D2_NavAreaTravelDistance(g_fClientAbsOrigin[iClient], fTargetPos, bIgnoreNavBlockers);
	if (iGoalArea)
		fDistance += GetVectorDistance(fTargetPos, fEntityPos, false);
	
	//StopProfiling(g_pProf);
	//t = GetProfilerTime(g_pProf);
	//if(g_bCvar_Debug && t > 0.001)
	//{
	//	char sClientName[128], sClassname[64];
	//	GetClientName(iClient, sClientName, sizeof(sClientName));
	//	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	//	PrintToServer("GetClientDistanceToItem took %.8f seconds, %d Client %s, Target %s, fDistance %.2f, fTargetPos %.1f %.1f %.1f", t, iClient, sClientName, sClassname, fDistance, fTargetPos[0], fTargetPos[1], fTargetPos[2]);
	//}
	
	return fDistance;
}

float GetEntityTravelDistance(int iClient, int iEntity, bool bSquared = false)
{
	if (!g_bMapStarted)return -1.0;

	static int iStartArea, iGoalArea, iArea, iTeam, iCount;
	static float /*t, */fEntityPos[3], fTargetPos[3];
	
	//StartProfiling(g_pProf);
	if (IsValidClient(iClient))
	{
		iTeam = GetClientTeam(iClient);
		iStartArea = g_iClientNavArea[iClient];
		fEntityPos = g_fClientAbsOrigin[iClient];
	}
	else
	{
		GetEntityAbsOrigin(iClient, fEntityPos);
		iStartArea = L4D_GetNearestNavArea(fEntityPos, _, true, true, true, iTeam);
	}
	if (!iStartArea)
	{
		//StopProfiling(g_pProf);
		//t = GetProfilerTime(g_pProf);
		//if(g_bCvar_Debug && t > 0.001)
		//	PrintToServer("GetEntTravelDist took %.8f seconds !iStartArea", t);
		return -1.0;
	}

	if (IsValidClient(iEntity))
	{
		iGoalArea = g_iClientNavArea[iEntity];
		fTargetPos = g_fClientAbsOrigin[iEntity];
	}
	else
	{
		GetEntityAbsOrigin(iEntity, fTargetPos);
		iGoalArea = L4D_GetNearestNavArea(fTargetPos, _, true, true, true, iTeam);
	}
	if (!iGoalArea)
	{
		//StopProfiling(g_pProf);
		//t = GetProfilerTime(g_pProf);
		//if(g_bCvar_Debug && t > 0.001)
		//	PrintToServer("GetEntTravelDist took %.8f seconds !iGoalArea", t);
		return -1.0;
	}
	
	if (!L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), 0.0, iTeam, false))
	{
		//StopProfiling(g_pProf);
		//t = GetProfilerTime(g_pProf);
		//if(g_bCvar_Debug && t > 0.001)
		//{
		//	char sClientName[128], sClassname[64];
		//	GetClientName(iClient, sClientName, sizeof(sClientName));
		//	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		//	PrintToServer("GetEntTravelDist took %.8f seconds !L4D2_NavAreaBuildPath, %d Client %s, Target %s, fTargetPos %.1f %.1f %.1f", t, iClient, sClientName, sClassname, fTargetPos[0], fTargetPos[1], fTargetPos[2]);
		//}
		return -1.0;
	}

	iArea = LBI_GetNavAreaParent(iGoalArea);
	if (!iArea)
	{
		//StopProfiling(g_pProf);
		//t = GetProfilerTime(g_pProf);
		//if(g_bCvar_Debug && t > 0.001)
		//	PrintToServer("GetEntTravelDist took %.8f seconds !iArea", t);
		return GetVectorDistance(g_fClientAbsOrigin[iClient], fEntityPos, bSquared);
	}

	float fClosePoint[3]; LBI_GetClosestPointOnNavArea(iArea, fEntityPos, fClosePoint);
	float fDistance = GetVectorDistance(fClosePoint, fEntityPos, bSquared);

	float fParentCenter[3];
	iCount = 0;
	for (; LBI_GetNavAreaParent(iArea); iArea = LBI_GetNavAreaParent(iArea))
	{
		//if (iCount > 10000)
		//	break;
		LBI_GetClosestPointOnNavArea(LBI_GetNavAreaParent(iArea), fEntityPos, fParentCenter);
		LBI_GetClosestPointOnNavArea(iArea, fEntityPos, fClosePoint);
		fDistance += GetVectorDistance(fClosePoint, fParentCenter, bSquared);
		iCount++;
	}
	//if(g_bCvar_Debug && iCount > 20)
	//	PrintToServer("GetEntTravelDist %d iterations of lag loop", iCount);

	LBI_GetClosestPointOnNavArea(iArea, fEntityPos, fClosePoint);
	fDistance += GetVectorDistance(g_fClientAbsOrigin[iClient], fClosePoint, bSquared);
	
	//StopProfiling(g_pProf);
	//t = GetProfilerTime(g_pProf);
	//if(g_bCvar_Debug && t > 0.001)
	//{
	//	char sClientName[128], sClassname[64];
	//	GetClientName(iClient, sClientName, sizeof(sClientName));
	//	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	//	PrintToServer("GetEntTravelDist took %.8f seconds after lag loop, %d Client %s, Target %s, fDistance %.2f, fTargetPos %.1f %.1f %.1f", t, iClient, sClientName, sClassname, fDistance, fTargetPos[0], fTargetPos[1], fTargetPos[2]);
	//}
	return fDistance;
}

//to replace GetVectorTravelDistance()
float GetNavDistance(float fStartPos[3], float fGoalPos[3], int iEntity = -1, bool bCheckLOS = true)
{
	if (!g_bMapStarted)return -1.0;
	
	static int iStartArea, iGoalArea;
	static float fDistance;
	static char sEntClassname[64];
	
	sEntClassname[0] = EOS;
	if (iEntity != -1)
		GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
	
	if (iEntity != -1 && g_hBadPathEntities.FindValue(EntIndexToEntRef(iEntity)) != -1)
	{
		//if(g_bCvar_Debug)
		//	PrintToServer("GetNavDistance: entity %d %s is in bad pathing table", iEntity, sEntClassname);
		return -1.0;
	}

	iStartArea = L4D_GetNearestNavArea(fStartPos, 140.0, true, bCheckLOS, false, 2);
	if (!iStartArea)
	{
		if(g_bCvar_Debug)
			PrintToServer("GetNavDistance: could not find iStartArea, fStartPos %.2f %.2f %.2f ent %d %s", fStartPos[0], fStartPos[1], fStartPos[2], iEntity, sEntClassname);
		if(iEntity != -1)
			PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		return -1.0;
	}
	
	iGoalArea = L4D_GetNearestNavArea(fGoalPos, 140.0, true, bCheckLOS, false, 2);
	if (!iGoalArea)
	{
		if(g_bCvar_Debug)
			PrintToServer("GetNavDistance: could not find iGoalArea, fGoalPos %.2f %.2f %.2f ent %d %s", fGoalPos[0], fGoalPos[1], fGoalPos[2], iEntity, sEntClassname);
		if(iEntity != -1)
			PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		return -1.0;
	}
	
	fDistance = L4D2_NavAreaTravelDistance(fStartPos, fGoalPos, true);
	if (g_bCvar_Debug && fDistance < 0.0)
		PrintToServer("GetNavDistance: fDistance %.2f fStartPos %.2f %.2f %.2f ent %d %s", fDistance, fStartPos[0], fStartPos[1], fStartPos[2], iEntity, sEntClassname);
	
	if (iEntity != -1 && fDistance < 0.0)
	{
		PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		if (g_hClearBadPathTimer == INVALID_HANDLE)
			g_hClearBadPathTimer = CreateTimer(0.1, ClearBadPathEntsTable);
	}
	
	return fDistance;
}

public Action ClearBadPathEntsTable(Handle timer)
{
	g_hBadPathEntities.Clear();
	g_hClearBadPathTimer = INVALID_HANDLE;
	return Plugin_Handled;
}

bool LBI_GetBonePosition(int iEntity, const char[] sBoneName, float fBuffer[3])
{
	if (!IsEntityExists(iEntity))return false;

	int iBoneIndex = SDKCall(g_hLookupBone, iEntity, sBoneName);
	if (iBoneIndex == -1)return false;

	static float fUnusedAngles[3];
	SDKCall(g_hGetBonePosition, iEntity, iBoneIndex, fBuffer, fUnusedAngles);

	return (IsValidVector(fBuffer));
}

bool LBI_IsSurvivorInCombat(int iClient, bool bUnknown = false)
{
	return (SDKCall(g_hIsInCombat, iClient, bUnknown));
}

int LBI_FindUseEntity(int iClient, float fCheckDist = 96.0, float fFloat_1 = 0.0, float fFloat_2 = 0.0, bool bBool_1 = false, bool bBool_2 = false)
{
	return (SDKCall(g_hFindUseEntity, iClient, fCheckDist, fFloat_1, fFloat_2, bBool_1, bBool_2));
}

bool LBI_IsSurvivorBotAvailable(int iClient)
{
	return (SDKCall(g_hIsAvailable, iClient));
}

bool LBI_IsReachableNavArea(int iClient, int iGoalArea, int iStartArea = -1)
{
	int iLastArea = g_iClientNavArea[iClient];
	if (!iLastArea)return false;
	
	if (iStartArea == -1)iStartArea = iLastArea;
	return (iStartArea && (iStartArea == iGoalArea || SDKCall(g_hIsReachableNavArea, iClient, iStartArea, iGoalArea)));
}

// don't fucking break the game if the position is 1mm inside of a prop, or 1mm below ground, a'ight??
bool LBI_IsReachablePosition(int iClient, const float fPos[3], bool bCheckLOS = true)
{
	int iNearArea = L4D_GetNearestNavArea(fPos, 200.0, true, bCheckLOS, false, 0);
	return (iNearArea && LBI_IsReachableNavArea(iClient, iNearArea));
}

bool LBI_IsReachableEntity(int iClient, int iEntity)
{
	if (!IsEntityExists(iEntity) || IsValidClient(iEntity) && !g_iClientNavArea[iEntity])return false;
	float fEntityPos[3]; GetEntityAbsOrigin(iEntity, fEntityPos);
	return (LBI_IsReachablePosition(iClient, fEntityPos));
}

MRESReturn DTR_OnSurvivorBotGetAvoidRange(int iClient, Handle hReturn, Handle hParams)
{
	int iTarget = DHookGetParam(hParams, 1); 
	float fAvoidRange = DHookGetReturn(hReturn);
	float fInitRange = DHookGetReturn(hReturn);

	if (fAvoidRange == 125.0)
	{
		if (iTarget <= MaxClients)
		{
			fAvoidRange = ((!IsUsingSpecialAbility(iTarget) && IsValidClient(L4D_GetPinnedSurvivor(iTarget))) ? 0.0 : 200.0);
		}
		else if (SurvivorHasMeleeWeapon(iClient))
		{
			fAvoidRange = 0.0;
		}
	}
	else if (fAvoidRange == 450.0)
	{
		int iVictim = g_iInfectedBot_CurrentVictim[iTarget];
		fAvoidRange = ((iVictim == iClient || iVictim > 0 && GetClientDistance(iVictim, iClient, true) <= 160000.0) ? 700.0 : 300.0);
	}
	else if (fAvoidRange == 300.0 && g_iSurvivorBot_WitchTarget[iClient] != -1 && g_bSurvivorBot_IsWitchHarasser[iClient])
	{
		fAvoidRange = 800.0;
	}

	if (IsSurvivorCarryingProp(iClient))
	{
		fAvoidRange += 200.0;
	}

	//PrintToServer("%N = %i, %f/%f", iClient, iTarget, fAvoidRange, fInitRange);

	if (fInitRange != fAvoidRange)
	{
		DHookSetReturn(hReturn, fAvoidRange);
		return MRES_ChangedOverride;
	}

	return MRES_Ignored;
}

MRESReturn DTR_OnInfernoTouchNavArea(int iInferno, Handle hReturn, Handle hParams)
{
	bool bIsTouching = DHookGetReturn(hReturn);
	if (!bIsTouching)return MRES_Ignored;

	int iNavArea = DHookGetParam(hParams, 1);
	if (!iNavArea)return MRES_Ignored;

	float fAreaPos[3];
	bool bCanBlock = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2 || L4D_IsPlayerIncapacitated(i) || L4D_IsPlayerPinned(i))
			continue;

		bCanBlock = (g_iClientNavArea[i] != iNavArea);
		if (!bCanBlock)break;

		LBI_GetClosestPointOnNavArea(iNavArea, g_fClientAbsOrigin[i], fAreaPos);
		bCanBlock = (GetVectorDistance(g_fClientAbsOrigin[i], fAreaPos, true) > 4096.0);
		if (!bCanBlock)break;
	}

	if (bCanBlock)
		SDKCall(g_hMarkNavAreaAsBlocked, iNavArea, 2, iInferno, true);

	return MRES_Ignored;
}

MRESReturn DTR_OnFindUseEntity(int iClient, Handle hReturn, Handle hParams)
{
	static int iScavengeItem;
	static float fDistance, fScavengePos[3];
	
	if (!IsValidClient(iClient) || !IsFakeClient(iClient))
		return MRES_Ignored;

	iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	if (!IsEntityExists(iScavengeItem))
		return MRES_Ignored;
	
	GetEntityAbsOrigin(iScavengeItem, fScavengePos);
	fDistance = GetVectorDistance(g_fClientAbsOrigin[iClient], fScavengePos, true);
	if (fDistance > g_fCvar_ItemScavenge_PickupRange_Sqr)
	{
		//if (g_bCvar_Debug)
		//{
		//	char sEntClassname[64],sClientName[128];
		//	GetClientName(iClient, sClientName, sizeof(sClientName));
		//	GetEntityClassname(iScavengeItem, sEntClassname, sizeof(sEntClassname));
		//	PrintToServer("DTR_OnFindUseEntity: Preventing %s from grabbing %s, distance %.2f", sClientName, sEntClassname, SquareRoot(fDistance));
		//}
		return MRES_Ignored;
	}
	
	DHookSetReturn(hReturn, iScavengeItem);
	return MRES_ChangedOverride;
}

int LBI_IsPathToPositionDangerous(int iClient, float fGoalPos[3])
{
	if (!g_bMapStarted)return -1;

	static int iClientArea, iGoalArea, iParent, iCount, iTank;
	static float fTankDist, fGoalDist, fGoalOffset[3], fAreaPos[3];
	
	if (L4D2_IsTankInPlay())
	{
		ArrayList hTankList = new ArrayList();
		
		fGoalOffset = fGoalPos;
		fGoalOffset[2] += HUMAN_HALF_HEIGHT;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (i == iClient || !IsClientInGame(i) || !IsPlayerAlive(i) || L4D2_GetPlayerZombieClass(i) != L4D2ZombieClass_Tank || L4D_IsPlayerIncapacitated(i))
				continue;

			fGoalDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fGoalPos, true);
			if (fGoalDist <= 90000.0 && GetVectorDistance(g_fClientAbsOrigin[i], fGoalPos, true) <= 22500.0 && IsVisibleVector(i, fGoalOffset, MASK_VISIBLE_AND_NPCS))
			{
				delete hTankList;
				return i;
			}

			if (fGoalDist > 250000)
			{
				fTankDist = GetClientTravelDistance(i, g_fClientAbsOrigin[iClient], true);
				if (fTankDist <= 62500.0 || fTankDist <= 562500.0 && g_iInfectedBot_CurrentVictim[i] == iClient && IsVisibleEntity(iClient, i, MASK_VISIBLE_AND_NPCS))
				{
					delete hTankList;
					return i;
				}
			}

			hTankList.Push(i);
		}

		iClientArea = g_iClientNavArea[iClient];
		if (!iClientArea)
		{
			delete hTankList;
			return -1;
		}

		iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, true);
		if (!iGoalArea)
		{
			delete hTankList;
			return -1;
		}

		//(!L4D2_NavAreaBuildPath(view_as<Address>(iClientArea), view_as<Address>(iGoalArea), 0.0, 2, false))
		if (!L4D2_IsReachable(iClient, fGoalPos))
		{
			delete hTankList;
			return -1;
		}
		
		iParent = LBI_GetNavAreaParent(iGoalArea);
		if (iParent)
		{
			iCount = 0;
			for (; LBI_GetNavAreaParent(iParent); iParent = LBI_GetNavAreaParent(iParent))
			{
				if (iCount > 25)
					//i ain't calculating all that
					//happy for you though
					//or sorry that happened
					break;
				for (int i = 0; i < hTankList.Length; i++)
				{
					iTank = hTankList.Get(i);

					if (g_iClientNavArea[iTank] != iParent)
					{
						LBI_GetClosestPointOnNavArea(iParent, g_fClientAbsOrigin[iTank], fAreaPos);
						if (g_iInfectedBot_CurrentVictim[iTank] != iClient && GetVectorDistance(g_fClientAbsOrigin[iTank], fAreaPos, true) > 22500.0)continue;
					}

					delete hTankList;
					return (g_iInfectedBot_CurrentVictim[iTank] == iClient ? iTank : 0);
				}
				iCount++;
			}
			//if(g_bCvar_Debug && iCount > 10)
			//	PrintToServer("IsPathToPositionDangerous: %d iterations of lag loop", iCount);
		}
		delete hTankList;
	}

	return -1;
}

public Action L4D2_OnChooseVictim(int iInfected, int &iTarget)
{
	g_iInfectedBot_CurrentVictim[iInfected] = iTarget;
	return Plugin_Continue;
}

public void OnActionCreated(BehaviorAction hAction, int iActor, const char[] sName)
{
	if (strcmp(sName[8], "LegsRegroup") == 0)
	{
		hAction.OnUpdatePost = OnRegroupWithTeamAction;
	}
	else if (strcmp(sName[8], "LiberateBesiegedFriend") == 0)
	{
		hAction.OnUpdatePost = OnMoveToIncapacitatedFriendAction;
	}
}

Action OnRegroupWithTeamAction(BehaviorAction hAction, int iActor, float fInterval, ActionResult hResult)
{
	int iLeader = (hAction.Get(0x34) & 0xFFF);
	if (!IsValidClient(iLeader))return Plugin_Continue;

	int iPathDangerous = LBI_IsPathToPositionDangerous(iActor, g_fClientAbsOrigin[iLeader]);
	if (iPathDangerous == -1)return Plugin_Continue;

	if (iPathDangerous != 0)
	{
		hResult.type = CHANGE_TO;
		hResult.action = CreateSurvivorLegsRetreatAction(iPathDangerous);
		return Plugin_Handled;
	}

	hResult.type = DONE;
	return Plugin_Changed;
}

Action OnMoveToIncapacitatedFriendAction(BehaviorAction hAction, int iActor, float fInterval, ActionResult hResult)
{
	int iFriend = (hAction.Get(0x34) & 0xFFF);
	if (!IsValidClient(iFriend) || L4D_GetPlayerReviveTarget(iActor) == iFriend || GetClientDistance(iActor, iFriend, true) <= 15625.0 && IsVisibleEntity(iActor, iFriend))
		return Plugin_Continue;

	int iPathDangerous = LBI_IsPathToPositionDangerous(iActor, g_fClientAbsOrigin[iFriend]);
	if (iPathDangerous == -1)return Plugin_Continue;

	if (iPathDangerous != 0)
	{
		hResult.type = CHANGE_TO;
		hResult.action = CreateSurvivorLegsRetreatAction(iPathDangerous);
		return Plugin_Handled;
	}

	hResult.type = DONE;
	return Plugin_Changed;
}

BehaviorAction CreateSurvivorLegsRetreatAction(int iThreat)
{
	BehaviorAction hAction = ActionsManager.Allocate(0x745A);
	SDKCall(g_hSurvivorLegsRetreat, hAction, iThreat);
	return hAction;
}