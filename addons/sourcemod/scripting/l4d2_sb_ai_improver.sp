#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <left4dhooks>

#undef REQUIRE_EXTENSIONS
#include <actions>
#define REQUIRE_EXTENSIONS

public Plugin myinfo = 
{
	name 		= "[L4D2] Survivor Bot AI Improver",
	author 		= "Emana202",
	description = "Attempt at improving survivor bots' AI and behaviour as much as possible.",
	version 	= "1.4",
	url 		= "https://forums.alliedmods.net/showthread.php?t=342872"
}

#define MAXENTITIES 				2048
#define MAP_SCAN_TIMER_INTERVAL		2.0

#define BOT_BOOMER_AVOID_RADIUS_SQR		40000.0
#define BOT_GRENADE_CHECK_RADIUS_SQR	90000.0
#define BOT_CMD_MOVE_INTERVAL 		0.8

#define HUMAN_HEIGHT				71.0
#define HUMAN_HALF_HEIGHT			35.5

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

/*============ MELEE RELATED CONVARS =================================================================*/
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
static float g_fCvar_ImprovedMelee_AimRange;
static float g_fCvar_ImprovedMelee_AttackRange;

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
static float g_fCvar_HelpPinnedFriend_ShootRange;
static float g_fCvar_HelpPinnedFriend_ShoveRange;
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
/*----------------------------------------------------------------------------------------------------*/
static ConVar g_hCvar_MaxWeaponTier3_M60;
static ConVar g_hCvar_MaxWeaponTier3_GLauncher;

static int g_iCvar_MaxWeaponTier3_M60;
static int g_iCvar_MaxWeaponTier3_GLauncher;

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
static ConVar g_hCvar_ItemScavenge_Items; 
static ConVar g_hCvar_ItemScavenge_ApproachRange; 
static ConVar g_hCvar_ItemScavenge_ApproachVisibleRange; 
static ConVar g_hCvar_ItemScavenge_PickupRange; 
static ConVar g_hCvar_ItemScavenge_MapSearchRange; 
static ConVar g_hCvar_ItemScavenge_NoHumansRangeMultiplier; 

static int g_iCvar_ItemScavenge_Items;
static float g_fCvar_ItemScavenge_ApproachRange;
static float g_fCvar_ItemScavenge_ApproachVisibleRange;
static float g_fCvar_ItemScavenge_PickupRange;
static float g_fCvar_ItemScavenge_MapSearchRange;
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
static char g_sSurvivorBot_MovePos_Name[MAXPLAYERS+1][512];

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
// CLIENT GLOBAL DATA
// ----------------------------------------------------------------------------------------------------
static float g_fClientEyePos[MAXPLAYERS+1][3];
static float g_fClientEyeAng[MAXPLAYERS+1][3];
static float g_fClientAbsOrigin[MAXPLAYERS+1][3];
static float g_fClientCenteroid[MAXPLAYERS+1][3];
static int g_iClientNavArea[MAXPLAYERS+1];
static int g_iClientInventory[MAXPLAYERS+1][6];

// ----------------------------------------------------------------------------------------------------
// WEAPON GLOBAL DATA
// ----------------------------------------------------------------------------------------------------
static int g_iWeapon_Clip1[MAXENTITIES+1];
static int g_iWeapon_MaxAmmo[MAXENTITIES+1]; 
static int g_iWeapon_AmmoLeft[MAXENTITIES+1];
static int g_iItem_Used[MAXENTITIES+1]; // To fix bots grabbing same ammo upgrade repeatedly

// ----------------------------------------------------------------------------------------------------
// MELEE WEAPON MODELS
// ----------------------------------------------------------------------------------------------------
static const char g_sMeleeWeaponMdls[][] =
{
	"models/weapons/melee/w_katana.mdl",
	"models/weapons/melee/w_fireaxe.mdl",
	"models/weapons/melee/w_machete.mdl",
	"models/weapons/melee/w_electric_guitar.mdl",
	"models/weapons/melee/w_tonfa.mdl",
	"models/weapons/melee/w_golfclub.mdl",
	"models/weapons/melee/w_bat.mdl",
	"models/weapons/melee/w_cricket_bat.mdl",
	"models/weapons/melee/w_frying_pan.mdl",
	"models/weapons/melee/w_crowbar.mdl",
	"models/w_models/weapons/w_knife_t.mdl",
	"models/weapons/melee/w_shovel.mdl",
	"models/weapons/melee/w_pitchfork.mdl",
	"models/weapons/melee/w_riotshield.mdl"
};

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

static ArrayList g_hWitchList;
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
	
	HookEvent("lunge_pounce", 			Event_OnSurvivorGrabbed);
	HookEvent("tongue_grab", 			Event_OnSurvivorGrabbed);
	HookEvent("jockey_ride", 			Event_OnSurvivorGrabbed);
	HookEvent("charger_carry_start", 	Event_OnSurvivorGrabbed);

	HookEvent("charger_charge_start",	Event_OnChargeStart);
	
	HookEvent("witch_harasser_set", 	Event_OnWitchHaraserSet);

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

	g_hCvar_ImprovedMelee_Enabled 					= CreateConVar("l4d2_improvedbots_melee_enabled", "1", "Enables survivor bots' improved melee behaviour.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ImprovedMelee_MaxCount 					= CreateConVar("l4d2_improvedbots_melee_max_team", "1", "The total number of melee weapons allowed on the team. <0: Bots never use melee>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_SwitchCount 				= CreateConVar("l4d2_improvedbots_melee_switch_count", "3", "The nearby infected count required for bot to switch to their melee weapon.", FCVAR_NOTIFY, true, 1.0);
	g_hCvar_ImprovedMelee_SwitchRange 				= CreateConVar("l4d2_improvedbots_melee_switch_range", "250", "Range at which bot's target should be to switch to melee weapon.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_ApproachRange				= CreateConVar("l4d2_improvedbots_melee_approach_range", "400", "Range at which bot's target should be to approach it. <0: Disable Approaching>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_AimRange 					= CreateConVar("l4d2_improvedbots_melee_aim_range", "125", "Range at which bot's target should be to start taking aim at it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_AttackRange 				= CreateConVar("l4d2_improvedbots_melee_attack_range", "70", "Range at which bot's target should be to start attacking it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_ShoveChance 				= CreateConVar("l4d2_improvedbots_melee_shove_chance", "4", "Chance for bot to bash target instead of attacking with melee. <0: Disable Bashing>", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_ImprovedMelee_ChainsawLimit 			= CreateConVar("l4d2_improvedbots_melee_chainsaw_limit", "1", "The total number of chainsaws allowed on the team. <0: Bots never use chainsaw>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_SwitchCount2 				= CreateConVar("l4d2_improvedbots_melee_chainsaw_switch_count", "6", "The nearby infected count required for bot to switch to chainsaw.", FCVAR_NOTIFY, true, 1.0);

	g_hCvar_TargetSelection_Enabled					= CreateConVar("l4d2_improvedbots_targetselection_enabled", "1", "Enables survivor bots' improved target selection.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TargetSelection_ShootRange				= CreateConVar("l4d2_improvedbots_targetselection_shootrange", "2000", "Range at which target need to be for bots to start firing at it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange2				= CreateConVar("l4d2_improvedbots_targetselection_shootrange_shotgun", "750", "Range at which target need to be for bots to start firing at it with shotgun.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange3				= CreateConVar("l4d2_improvedbots_targetselection_shootrange_sniperrifle", "3000", "Range at which target need to be for bots to start firing at it with sniper rifle.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange4				= CreateConVar("l4d2_improvedbots_targetselection_shootrange_pistol", "1500", "Range at which target need to be for bots to start firing at it with secondary weapon.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_IgnoreDociles			= CreateConVar("l4d2_improvedbots_targetselection_ignoredociles", "1", "If bots shouldn't target common infected that are currently not attacking survivors.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_GrenadeThrow_Enabled 					= CreateConVar("l4d2_improvedbots_grenadethrowing_enabled", "1", "Enables survivor bots throwing grenades.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_GrenadeThrow_GrenadeTypes				= CreateConVar("l4d2_improvedbots_grenadethrowing_grenadetypes", "7", "What grenades should survivor bots throw? <1: Pipe-Bomb, 2: Molotov, 4: Bile Bomb. Add numbers together.>", FCVAR_NOTIFY, true, 1.0, true, 7.0);
	g_hCvar_GrenadeThrow_ThrowRange					= CreateConVar("l4d2_improvedbots_grenadethrowing_throw_range", "1500", "Range at which target needs to be for bot to throw grenade at it.", FCVAR_NOTIFY);
	g_hCvar_GrenadeThrow_HordeSize 					= CreateConVar("l4d2_improvedbots_grenadethrowing_horde_size_multiplier", "3.75", "Infected count required to throw grenade Multiplier (Value * SurvivorCount).", FCVAR_NOTIFY, true, 1.0);
	g_hCvar_GrenadeThrow_NextThrowTime1 			= CreateConVar("l4d2_improvedbots_grenadethrowing_next_throw_time_min", "20", "First number to pick to randomize next grenade throw time.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_GrenadeThrow_NextThrowTime2 			= CreateConVar("l4d2_improvedbots_grenadethrowing_next_throw_time_max", "30", "Second number to pick to randomize next grenade throw time.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_TankRock_ShootEnabled 					= CreateConVar("l4d2_improvedbots_shootattankrocks_enabled", "1", "Enables survivor bots shooting tank's thrown rocks.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TankRock_ShootRange 					= CreateConVar("l4d2_improvedbots_shootattankrocks_range", "1500", "Range at which rock needs to be for bot to start shooting at it.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_AutoShove_Enabled						= CreateConVar("l4d2_improvedbots_autoshove_enabled", "1", "Makes survivor bots automatically shove every nearby infected. <0: Disabled, 1: All infected, 2: Only if infected is behind them>", FCVAR_NOTIFY, true, 0.0, true, 2.0);

	g_hCvar_HelpPinnedFriend_Enabled				= CreateConVar("l4d2_improvedbots_help_pinnedfriend_enabled", "3", "Makes survivor bots force attack pinned survivor's SI if possible. <0: Disabled, 1: Shoot at attacker, 2: Shove the attacker if close enough. Add numbers together.>", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_HelpPinnedFriend_ShootRange				= CreateConVar("l4d2_improvedbots_help_pinnedfriend_shootrange", "2000", "Range at which bots will start firing at SI.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_HelpPinnedFriend_ShoveRange				= CreateConVar("l4d2_improvedbots_help_pinnedfriend_shoverange", "75", "Range at which bots will start to bash SI.", FCVAR_NOTIFY), true, 0.0;

	g_hCvar_DefibRevive_Enabled						= CreateConVar("l4d2_improvedbots_defib_revive_enabled", "1", "Enable bots reviving dead players with defibrillators if they have one available.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DefibRevive_ScanDist 					= CreateConVar("l4d2_improvedbots_defib_revive_distance", "2000", "Range at which survivor's dead body should be for bot to consider it reviveable.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_FireBash_Chance1						= CreateConVar("l4d2_improvedbots_fireshove_chance_pumpshotguns", "4", "Chance at which survivor bot may shove after firing a pump-action shotgun. <0: Disabled, 1: Always>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_FireBash_Chance2						= CreateConVar("l4d2_improvedbots_fireshove_chance_css_sniperrifles", "3", "Chance at which survivor bot may shove after firing a bolt-action sniper rifle. <0: Disabled, 1: Always>", FCVAR_NOTIFY, true, 0.0);
	
	g_hCvar_ItemScavenge_Items 						= CreateConVar("l4d2_improvedbots_itemscavenge_enabled", "16383", "Enable improved bot item scavenging for specified items. <0: Disable, 1: Pipe Bomb, 2: Molotov, 4: Bile Bomb, 8: Medkit, 16: Defibrillator, 32: UpgradePack, 64: Pain Pills, 128: Adrenaline, 256: Laser Sights, 512: Ammopack, 1024: Ammopile, 2048: Chainsaw, 4096: Secondary Weapons, 8192: Primary Weapons. Add numbers together>", FCVAR_NOTIFY, true, 0.0, true, 16383.0);
	g_hCvar_ItemScavenge_ApproachRange 				= CreateConVar("l4d2_improvedbots_itemscavenge_scavenge_distance", "300", "Distance at which item should be for bot to move it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_ApproachVisibleRange 		= CreateConVar("l4d2_improvedbots_itemscavenge_scavenge_visible_distance", "600", "Distance at which a visible item should be for bot to move it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_PickupRange 				= CreateConVar("l4d2_improvedbots_itemscavenge_pickup_distance", "100", "Distance at which item should be for bot to able to pick it up.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_MapSearchRange 			= CreateConVar("l4d2_improvedbots_itemscavenge_mapsearchdistance", "2500", "How close should the item be to the survivor bot to able to count it when searching?", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_NoHumansRangeMultiplier	= CreateConVar("l4d2_improvedbots_itemscavenge_nohumans_rangemultiplier", "3.0", "The bots' scavenge distance is multiplied to this value when there's no human players left in the team.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_BotWeaponPreference_Nick 				= CreateConVar("l4d2_improvedbots_weapon_preference_nick", "1", "Bot Nick's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Rochelle 			= CreateConVar("l4d2_improvedbots_weapon_preference_rochelle", "1", "Bot Rochelle's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Coach 				= CreateConVar("l4d2_improvedbots_weapon_preference_coach", "2", "Bot Coach's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Ellis 				= CreateConVar("l4d2_improvedbots_weapon_preference_ellis", "3", "Bot Ellis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Bill  				= CreateConVar("l4d2_improvedbots_weapon_preference_bill", "1", "Bot Bill's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Zoey 				= CreateConVar("l4d2_improvedbots_weapon_preference_zoey", "3", "Bot Zoey's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Francis 			= CreateConVar("l4d2_improvedbots_weapon_preference_francis", "2", "Bot Francis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Louis 				= CreateConVar("l4d2_improvedbots_weapon_preference_louis", "1", "Bot Louis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_ForceMagnum 		= CreateConVar("l4d2_improvedbots_weapon_preference_magnums_only", "0", "If every survivor bot should only use magnum instead of regular pistol if possible.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_SwapSameTypePrimaries 					= CreateConVar("l4d2_improvedbots_changeweaponiftoomanysubtype_primaries", "1", "Makes survivor bots change their primary weapon subtype if there's too much of the same one, Ex. change AK-47 to M16 or SPAS-12 to Autoshotgun.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_SwapSameTypeGrenades 					= CreateConVar("l4d2_improvedbots_changeweaponiftoomanysubtype_grenades", "1", "Makes survivor bots change their grenade type if there's too much of the same one, Ex. Pipe-Bomb to Molotov.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_MaxWeaponTier3_M60 						= CreateConVar("l4d2_improvedbots_tier3weaponlimit_m60", "1", "The total number of M60s allowed on the team. <0: Bots never use M60>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_MaxWeaponTier3_GLauncher 				= CreateConVar("l4d2_improvedbots_tier3weaponlimit_grenadelauncher", "1", "The total number of grenade launchers allowed on the team. <0: Bots never use grenade launcher>", FCVAR_NOTIFY, true, 0.0);
	
	g_hCvar_Vision_FieldOfView 						= CreateConVar("l4d2_improvedbots_vision_fieldofview", "60.0", "The field of view of survivor bots.", FCVAR_NOTIFY, true, 0.0, true, 180.0);
	g_hCvar_Vision_NoticeTimeScale 					= CreateConVar("l4d2_improvedbots_vision_noticetimescale", "1.1", "The time required for bots to notice enemy target is multiplied to this value.", FCVAR_NOTIFY, true, 0.0, true, 4.0);
	
	g_hCvar_SpitterAcidEvasion						= CreateConVar("l4d2_improvedbots_evadespitteracids", "1", "Enables survivor bots' improved spitter acid evasion", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_AlwaysCarryProp							= CreateConVar("l4d2_improvedbots_alwayscarryprop", "0", "If survivor bot shouldn't drop his currently carrying prop no matter what.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_KeepMovingInCombat						= CreateConVar("l4d2_improvedbots_keepmovingincombat", "1", "If bots shouldn't stop moving in combat when there's no human players in team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_SwitchOffCSSWeapons						= CreateConVar("l4d2_improvedbots_switchoffcssweapon", "1", "If bots should change their primary weapon to other one if they're using CSS weapons.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ChargerEvasion							= CreateConVar("l4d2_improvedbots_chargerevasion", "1", "Enables survivor bots's charger dodging behavior.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DeployUpgradePacks						= CreateConVar("l4d2_improvedbots_deployupgradepacks", "1", "If bots should deploy their upgrade pack when available and not in combat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DontSwitchToPistol						= CreateConVar("l4d2_improvedbots_dontswitchtopistol", "1", "If bots shouldn't switch to their pistol while they have sniper rifle equiped.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TakeCoverFromRocks						= CreateConVar("l4d2_improvedbots_takecoverfromtankrocks", "1", "If bots should take cover from tank's thrown rocks.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_AvoidTanksWithProp						= CreateConVar("l4d2_improvedbots_avoidtanksnearpunchableprops", "1", "If bots should avoid and retreat from tanks that are nearby punchable props like cars.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_NoFallDmgOnLadderFail					= CreateConVar("l4d2_improvedbots_nofalldmgonladderfail", "1", "If enabled, survivor bots won't take fall damage if they were climbing a ladder just before that.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_WitchBehavior_WalkWhenNearby			= CreateConVar("l4d2_improvedbots_witchbehavior_walkwhennearby", "500", "Survivor bots will start walking near witch if they're this range near her and she's not disturbed. <0: Disabled>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_WitchBehavior_AllowCrowning				= CreateConVar("l4d2_improvedbots_witchbehavior_allowcrowning", "1", "Allows survivor bots to crown witch on their path if they're holding any shotgun type weapon. <0: Disabled; 1: Only if survivor team doesn't have any human players; 2:Enabled>", FCVAR_NOTIFY, true, 0.0, true, 2.0);

	g_hCvar_NextProcessTime 						= CreateConVar("l4d2_improvedbots_process_time", "0.1", "Bots' data computing time delay (infected count, nearby friends, etc). Increasing the value might help increasing the game performance, but slow down bots.", FCVAR_NOTIFY, true, 0.033);

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
	g_fCvar_ImprovedMelee_AimRange 						= (g_hCvar_ImprovedMelee_AimRange.FloatValue*g_hCvar_ImprovedMelee_AimRange.FloatValue);
	g_fCvar_ImprovedMelee_AttackRange 					= g_hCvar_ImprovedMelee_AttackRange.FloatValue;
	
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
	g_fCvar_HelpPinnedFriend_ShootRange 				= g_hCvar_HelpPinnedFriend_ShootRange.FloatValue;
	g_fCvar_HelpPinnedFriend_ShoveRange 				= g_hCvar_HelpPinnedFriend_ShoveRange.FloatValue;
	
	g_iCvar_ItemScavenge_Items 							= g_hCvar_ItemScavenge_Items.IntValue;
	g_fCvar_ItemScavenge_ApproachRange 					= g_hCvar_ItemScavenge_ApproachRange.FloatValue;
	g_fCvar_ItemScavenge_ApproachVisibleRange 			= g_hCvar_ItemScavenge_ApproachVisibleRange.FloatValue;
	g_fCvar_ItemScavenge_PickupRange 					= g_hCvar_ItemScavenge_PickupRange.FloatValue;
	g_fCvar_ItemScavenge_MapSearchRange 				= (g_hCvar_ItemScavenge_MapSearchRange.FloatValue*g_hCvar_ItemScavenge_MapSearchRange.FloatValue);
	g_fCvar_ItemScavenge_NoHumansRangeMultiplier 		= g_hCvar_ItemScavenge_NoHumansRangeMultiplier.FloatValue;

	g_bCvar_SwapSameTypePrimaries 						= g_hCvar_SwapSameTypePrimaries.BoolValue;
	g_bCvar_SwapSameTypeGrenades 						= g_hCvar_SwapSameTypeGrenades.BoolValue;
	
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

	/*
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "Subdivider::SubdivideX");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSubdivideNavArea = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for Subdivider::SubdivideX signature!");
	*/
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

/*void LBI_CommandABot(int iBot, int iCmd, const float fPos[3], int iTarget = -1)
{
	if (!IsValidClient(iBot) || !IsFakeClient(iBot) || !IsPlayerAlive(iBot))
		return;

	char sBuffer[256]; 
	FormatEx(sBuffer, sizeof(sBuffer), "CommandABot({cmd = %i, bot = GetPlayerFromUserID(%i)", iCmd, GetClientUserId(iBot));

	if (!IsNullVector(fPos))
	{
		FormatEx(sBuffer, sizeof(sBuffer), "%s, pos = Vector(%f, %f, %f)", sBuffer, fPos[0], fPos[1], fPos[2]);
	}

	if (iTarget != -1)
	{
		bool bIsPlayer = (IsValidClient(iTarget));
		FormatEx(sBuffer, sizeof(sBuffer), "%s, target = %s(%i)", sBuffer, (bIsPlayer ? "GetPlayerFromUserID" : "EntIndexToHScript"), (!bIsPlayer ? iTarget : GetClientUserId(iTarget)));
	}

	StrCat(sBuffer, sizeof(sBuffer), "})");
	L4D2_ExecVScriptCode(sBuffer);
}*/

void Event_OnWeaponFire(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!IsFakeClient(iClient))return;

	static char sWeaponName[64]; 
	hEvent.GetString("weapon", sWeaponName, sizeof(sWeaponName));

	if (GetRandomInt(1, g_iCvar_FireBash_Chance1) == 1 && (strcmp(sWeaponName, "shotgun_chrome") == 0 || strcmp(sWeaponName, "pumpshotgun") == 0))
	{
		g_bSurvivorBot_ForceBash[iClient] = true;
	}
	else if (GetRandomInt(1, g_iCvar_FireBash_Chance2) == 1 && (strcmp(sWeaponName, "sniper_awp") == 0 || strcmp(sWeaponName, "sniper_scout") == 0))
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

// Mark entity as used by certain client
void Event_OnPlayerUse(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	int iEntity = hEvent.GetInt("targetid");

	int iUsedMask = (g_iItem_Used[iEntity] | 0);
	iUsedMask |= ( 1 << (iClient - 1) );
	g_iItem_Used[iEntity] = iUsedMask;
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
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
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
			g_hWitchList.Set(i, hEvent.GetInt("userid"), 1);
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

	int iWpnSlot, iWpnSlots[6]; 
	for (int i = 0; i <= 5; i++)
	{
		iWpnSlot = GetPlayerWeaponSlot(iClient, i);
		iWpnSlots[i] = (!IsEntityWeapon(iWpnSlot, true) ? -1 : iWpnSlot);
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
	static bool bSmokerOrBoomerNearby, bFriendIsNearBoomer, bFriendIsNearThrowArea, bTeamHasHumanPlayer; 
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
		bSmokerOrBoomerNearby = false;
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
				if (!bSmokerOrBoomerNearby)bSmokerOrBoomerNearby = ((iClientClass == L4D2ZombieClass_Smoker || iClientClass == L4D2ZombieClass_Boomer) && (fCurDist <= 262144.0 || HadVisualContactWithEntity(i, iClient, false)));
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
			
			iHarasserRef = GetClientOfUserId(g_hWitchList.Get(i, 1));
			if (iWitchHarasser != 0 && iHarasserRef == 0)continue;

			fCurDist = GetEntityDistance(iClient, iWitchRef, true);
			if (fLastDist != -1.0 && fCurDist >= fLastDist)continue;

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
	
		if (iCurWeapon == iWpnSlots[0] && !IsWeaponReloading(iCurWeapon, false) && GetGameTime() > GetWeaponNextFireTime(iCurWeapon) 
			&& LBI_IsSurvivorBotAvailable(iClient) && !LBI_IsSurvivorInCombat(iClient) && (SurvivorHasTier3Weapon(iClient) == 2 || 
			GetWeaponClip1(iCurWeapon) == GetWeaponClipSize(iCurWeapon)) && SurvivorHasPistol(iClient) != 0 && GetWeaponClip1(iWpnSlots[1]) != GetWeaponClipSize(iWpnSlots[1]))
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
			!g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] && LBI_IsDamagingPosition(fMovePos) || !LBI_IsReachablePosition(iClient, fMovePos) || 
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
			bool bCanShoot = (iCurWeapon != -1 && g_iCvar_HelpPinnedFriend_Enabled & (1 << 0) != 0 && fFriendDist <= (g_fCvar_HelpPinnedFriend_ShootRange*g_fCvar_HelpPinnedFriend_ShootRange) && (iCurWeapon != iWpnSlots[1] || !SurvivorHasMeleeWeapon(iClient) || GetClientDistance(iClient, iAttacker, true) <= (g_fCvar_ImprovedMelee_AttackRange*g_fCvar_ImprovedMelee_AttackRange)) && SurvivorBot_AbleToShootWeapon(iClient) && CheckIfCanRescueImmobilizedFriend(iClient));

			int iCanShove;
			if (g_iCvar_HelpPinnedFriend_Enabled & (1 << 1) != 0)
			{
				iCanShove = (fFriendDist <= (g_fCvar_HelpPinnedFriend_ShoveRange*g_fCvar_HelpPinnedFriend_ShoveRange) ? 1 : (GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iAttacker], true) <= (g_fCvar_HelpPinnedFriend_ShoveRange*g_fCvar_HelpPinnedFriend_ShoveRange) ? 2 : 0));
			}

			L4D2ZombieClassType iZombieClass = L4D2_GetPlayerZombieClass(iAttacker);
			if (iZombieClass != L4D2ZombieClass_Smoker)
			{
				if (iWpnSlots[0] != -1 && g_iWeapon_AmmoLeft[iWpnSlots[0]] > 0 && g_iWeapon_Clip1[iWpnSlots[0]] > 0 && iCurWeapon == iWpnSlots[1] && SurvivorHasMeleeWeapon(iClient) && fFriendDist > g_fCvar_ImprovedMelee_AimRange)
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
					PressAttackButton(iClient, iButtons);
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
						PressAttackButton(iClient, iButtons);
					}
					else 
					{
						float fTipPos[3]; GetEntPropVector(L4D_GetPlayerCustomAbility(iAttacker), Prop_Send, "m_tipPosition", fTipPos);
						if (!IsValidVector(fTipPos))fTipPos = g_fClientCenteroid[iPinnedFriend];

						if (IsVisibleVector(iClient, fTipPos))
						{
							float fMidPos[3];
							fMidPos[0] = ((g_fClientEyePos[iAttacker][0] + fTipPos[0]) / 2.0);
							fMidPos[1] = ((g_fClientEyePos[iAttacker][1] + fTipPos[1]) / 2.0);
							fMidPos[2] = ((g_fClientEyePos[iAttacker][2] + fTipPos[2]) / 2.0);

							SnapViewToPosition(iClient, (IsVisibleVector(iClient, fMidPos) ? fMidPos : fTipPos));
							PressAttackButton(iClient, iButtons);
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
				PressAttackButton(iClient, iButtons);
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

		if (IsValidClient(iWitchHarasser))
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
					bool bFired = PressAttackButton(iClient, iButtons);
					if (iHasShotgun == 1 && bFired)g_bSurvivorBot_ForceBash[iClient] = true;

					if (fShootRange != g_fCvar_TargetSelection_ShootRange2 && fShootRange != g_fCvar_ImprovedMelee_AttackRange)
					{
						ClearMoveToPosition(iClient, "GoToWitch");
					}
				}
				else if (iWitchHarasser != iClient && fWitchDist <= 4000000.0)
				{
					SetMoveToPosition(iClient, fWitchOrigin, 3, "GoToWitch", 0.0, ((bWitchVisible && !L4D_IsPlayerIncapacitated(iWitchHarasser)) ? (fShootRange > 192.0 ? 192.0 : fShootRange) : 0.0), true);
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
					bool bFired = PressAttackButton(iClient, iButtons);
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
					
					if (fMeleeDistance <= g_fCvar_ImprovedMelee_AimRange)
					{
						if (!bSmokerOrBoomerNearby && !IsValidClient(iPinnedFriend))
							g_fSurvivorBot_BlockWeaponSwitchTime[iClient] = (GetGameTime() + (iMeleeType == 2 ? 3.0 : 1.0));

						SnapViewToPosition(iClient, fAimPosition);
					}

					if (!g_bSurvivorBot_PreventFire[iClient] && fMeleeDistance <= (g_fCvar_ImprovedMelee_AttackRange*g_fCvar_ImprovedMelee_AttackRange) && (iGameDifficulty == 4 || (!IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, (float(g_iSurvivorBot_NearbyFriends[iClient]) / (iTeamCount - 1))))))
					{
						float fAttackTime = (iMeleeType == 2 ? GetRandomFloat(0.33, 0.8) : GetRandomFloat(0.1, 0.33));
						g_fSurvivorBot_MeleeAttackTime[iClient] = (GetGameTime() + fAttackTime);
					}

					if (GetGameTime() < g_fSurvivorBot_MeleeAttackTime[iClient])
					{
						bool bShouldShove = (iInfectedClass != L4D2ZombieClass_Charger && GetRandomInt(1, (iMeleeType == 2 ? 200 : g_iCvar_ImprovedMelee_ShoveChance)) == 1 && (!g_bExtensionActions || iInfectedClass != L4D2ZombieClass_NotInfected || !IsCommonInfectedStumbled(iInfectedTarget)));
						iButtons |= ( bShouldShove ? IN_ATTACK2 : IN_ATTACK );
					}

					bool bStopApproaching = true;
					if (g_fCvar_ImprovedMelee_ApproachRange > 0.0 && GetGameTime() > g_fSurvivorBot_MeleeApproachTime[iClient] && !IsSurvivorBotBlindedByVomit(iClient) && !IsValidClient(iPinnedFriend) && (!IsValidClient(iTankTarget) || GetClientDistance(iClient, iTankTarget, true) > 1048576.0) && LBI_IsReachableEntity(iClient, iInfectedTarget) 
						&& !IsFinaleEscapeVehicleArrived() && (iInfectedClass == L4D2ZombieClass_NotInfected || (L4D_IsPlayerStaggering(iInfectedTarget) || L4D_GetPinnedSurvivor(iInfectedTarget) != 0) && !L4D_IsAnySurvivorInCheckpoint())
					)
					{
						Address pArea;
						float fMovePos[3]; GetEntityAbsOrigin(iInfectedTarget, fMovePos);
						if (!ShouldUseFlowDistance() || (pArea = L4D2Direct_GetTerrorNavArea(fMovePos)) == Address_Null || L4D2Direct_GetTerrorNavAreaFlow(pArea) >= (L4D2Direct_GetFlowDistance(iClient) - SquareRoot(g_fCvar_ImprovedMelee_ApproachRange*0.5)))
						{
							float fLeaderDist = ((iInfectedClass == L4D2ZombieClass_NotInfected && iTeamLeader != iClient && IsValidClient(iTeamLeader)) ? GetClientTravelDistance(iTeamLeader, fMovePos, true) : -2.0);
							if (fLeaderDist == -2.0 || fLeaderDist != -1.0 && fLeaderDist <= (g_fCvar_ImprovedMelee_ApproachRange * 0.75))
							{
								float fTravelDist = GetVectorTravelDistance(fMovePos, g_fClientAbsOrigin[iClient], true);
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
				else if (!bSmokerOrBoomerNearby && iCurWeapon == iWpnSlots[0])
				{
					int iMeleeSwitchCount = ((iMeleeType != 2) ? g_iCvar_ImprovedMelee_SwitchCount : g_iCvar_ImprovedMelee_SwitchCount2);
					float fMeleeSwitchRange = (g_fCvar_ImprovedMelee_SwitchRange * ((iMeleeType == 2) ? 1.5 : ((SurvivorHasShotgun(iClient) || SurvivorHasSniperRifle(iClient)) ? 0.66 : 1.0)));
					if (fInfectedDist <= fMeleeSwitchRange && !IsValidClient(iTankTarget) && (!SurvivorHasShotgun(iClient) || GetWeaponClip1(iCurWeapon) <= 0))
					{ 
						if (iInfectedClass != L4D2ZombieClass_NotInfected)
						{
							if (L4D_GetPinnedSurvivor(iInfectedTarget) != 0 || L4D_IsPlayerStaggering(iInfectedTarget))
							{
								SwitchWeaponSlot(iClient, 1);
								g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime() + ((iMeleeType == 2) ? 2.0 : 0.66);
							}
						}
						else if (g_iSurvivorBot_NearbyInfectedCount[iClient] >= iMeleeSwitchCount && !IsValidClient(iPinnedFriend) && (GetCurrentGameDifficulty() == 4 || !IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.75)))
						{
							SwitchWeaponSlot(iClient, 1);
							g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime() + ((iMeleeType == 2) ? 2.0 : 0.66);
						}
					}
				}
			}
		}

		if ((g_iCvar_AutoShove_Enabled == 1 || g_iCvar_AutoShove_Enabled == 2 && !FVectorInViewAngle(iClient, fInfectedPos)) && fInfectedDist <= 6400.0 && !L4D_IsPlayerIncapacitated(iClient) && (!IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, (float(g_iSurvivorBot_NearbyFriends[iClient]) / (iTeamCount - 1)))) && (!SurvivorHasMeleeWeapon(iClient) || iCurWeapon != iWpnSlots[1]))
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
						if (fTargetDist <= (g_fCvar_TargetSelection_ShootRange4*g_fCvar_TargetSelection_ShootRange4) && fTargetDist > ((fShootRange * 1.1)*(fShootRange * 1.1)) && GetGameTime() > g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] && !IsWeaponReloading(iCurWeapon, false) && !SurvivorHasMeleeWeapon(iClient))
						{
							g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime() + GetRandomFloat(1.0, 3.0);
							g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
							SwitchWeaponSlot(iClient, 1);
						}
					}
					else if (SurvivorHasSniperRifle(iClient))
					{
						fShootRange = g_fCvar_TargetSelection_ShootRange3;
					}

					if (fTargetDist <= (fShootRange*fShootRange) && SurvivorBot_AbleToShootWeapon(iClient))
					{
						SnapViewToPosition(iClient, fFirePos);
						PressAttackButton(iClient, iButtons);
					}
				}
				else if (iCurWeapon == iWpnSlots[1] && !SurvivorHasMeleeWeapon(iClient))
				{
					float fShotgunRange = (g_fCvar_TargetSelection_ShootRange2 * 0.75);
					if (fTargetDist <= (fShotgunRange*fShotgunRange) && GetGameTime() > g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] && GetClientPrimaryAmmo(iClient) > 0 && !IsWeaponReloading(iCurWeapon) && SurvivorHasShotgun(iClient))
					{
						g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime() + GetRandomFloat(1.0, 3.0);
						g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
						SwitchWeaponSlot(iClient, 0);
					}

					if (L4D_IsPlayerIncapacitated(iClient) || fTargetDist <= (g_fCvar_TargetSelection_ShootRange4*g_fCvar_TargetSelection_ShootRange4) && SurvivorBot_AbleToShootWeapon(iClient))
					{
						SnapViewToPosition(iClient, fFirePos);
						PressAttackButton(iClient, iButtons);
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
					PressAttackButton(iClient, iButtons);
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

	if (g_bCvar_DeployUpgradePacks && iWpnSlots[0] != -1 && iWpnSlots[3] != -1 && !LBI_IsSurvivorInCombat(iClient) && SurvivorHasHealthKit(iClient) == 3)
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
				PressAttackButton(iClient, iButtons);
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

			if (SurvivorHasHealthKit(iClient) == 2)
			{
				if (L4D2_GetPlayerUseActionTarget(iClient) == iDefibTarget || fDefibDist <= 9216.0)
				{
					if (iCurWeapon == iWpnSlots[3])
					{
						SnapViewToPosition(iClient, fDefibPos);
						PressAttackButton(iClient, iButtons);
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
		}
		else
		{
			int iUseButton = IN_USE;
			bool bHoldKey = false;
			float fUseRange = g_fCvar_ItemScavenge_PickupRange;
			static bool bIncreasedTime = false;

			static char sScavengeItem[64]; GetEntityClassname(iScavengeItem, sScavengeItem, sizeof(sScavengeItem));
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
					float fScavengePos[3]; 
					fScavengePos = fItemPos;
					
					float fMaxDist = g_fCvar_ItemScavenge_ApproachVisibleRange;
					int iScavengeArea = L4D_GetNearestNavArea(fItemPos, _, true, true, false);
					if (iScavengeArea)
					{										
						LBI_GetClosestPointOnNavArea(iScavengeArea, fItemPos, fScavengePos);
						if (!LBI_IsNavAreaPartiallyVisible(iScavengeArea, g_fClientEyePos[iClient], iClient))
						{
							fMaxDist = g_fCvar_ItemScavenge_ApproachRange;
						}
					}

					float fLeaderDist = -2.0;
					if (iTeamLeader != iClient && IsValidClient(iTeamLeader))
					{
						fLeaderDist = GetClientTravelDistance(iTeamLeader, fScavengePos, true);
					}
					if (!bTeamHasHumanPlayer)fMaxDist *= g_fCvar_ItemScavenge_NoHumansRangeMultiplier;

					if (g_iSurvivorBot_NearbyInfectedCount[iClient] < GetCommonHitsUntilDown(iClient, 0.66) && !LBI_IsDamagingPosition(fScavengePos) && !IsFinaleEscapeVehicleArrived() &&
						(!IsValidClient(iTankTarget) || GetClientDistance(iClient, iTankTarget, true) > 262144.0 && GetVectorDistance(g_fClientAbsOrigin[iTankTarget], fScavengePos, true) > 147456.0) &&
						LBI_IsReachableEntity(iClient, iScavengeItem) && !IsValidClient(g_iSurvivorBot_IncapacitatedFriend[iClient]) && (fLeaderDist == -2.0 || fLeaderDist != -1.0 && fLeaderDist <= ((fMaxDist * 0.75)*(fMaxDist * 0.75)))
					)
					{
						SetMoveToPosition(iClient, fScavengePos, 1, "ScavengeItem");
					}
					else
					{
						ClearMoveToPosition(iClient, "ScavengeItem");								
						g_iSurvivorBot_ScavengeItem[iClient] = -1;
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
			if (SurvivorHasMeleeWeapon(iClient))
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
			if (g_iSurvivorBot_NearbyInfectedCount[iClient] < g_iCvar_ImprovedMelee_SwitchCount2 && SurvivorHasMeleeWeapon(iClient) == 2)
			{
				return Plugin_Handled;
			}

			if (GetSurvivorBotWeaponPreference(iClient) != L4D_WEAPON_PREFERENCE_SECONDARY && (!SurvivorHasMeleeWeapon(iClient) || g_iSurvivorBot_NearbyInfectedCount[iClient] < g_iCvar_ImprovedMelee_SwitchCount) && ((g_bCvar_DontSwitchToPistol && SurvivorHasSniperRifle(iClient)) || SurvivorHasShotgun(iClient)))
			{
				return Plugin_Handled;
			}
		}
	}

	if (IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && iCurWeapon == GetClientWeaponInventory(iClient, 3) && SurvivorHasHealthKit(iClient) == 2)
	{
		return Plugin_Handled;
	}

	if (IsSurvivorCarryingProp(iClient))
	{
		if (g_bCvar_AlwaysCarryProp)return Plugin_Handled;
		if (iWeapon == GetClientWeaponInventory(iClient, 0) || iWeapon == GetClientWeaponInventory(iClient, 1))
		{
			int iTeamCount = (g_iSurvivorBot_NearbyFriends[iClient] / 2); if (iTeamCount < 1)iTeamCount = 1;
			int iDropLimitCount = RoundFloat(GetCommonHitsUntilDown(iClient, 0.5) * float(iTeamCount));
			if (g_iSurvivorBot_ThreatInfectedCount[iClient] < iDropLimitCount)return Plugin_Handled;
		}
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
		LBI_TryGetPathableLocationWithin(iClient, 250.0 + (50.0 * i), fPathPos);
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

bool TakeCoverFromPosition(int iClient, float fPosition[3], float fSearchDist = 384.0)
{
	float fSelfToPos[3]; MakeVectorFromPoints(g_fClientEyePos[iClient], fPosition, fSelfToPos);
	NormalizeVector(fSelfToPos, fSelfToPos);

	float fDot, fPathPos[3], fPathOffset[3], fSelfToMovePos[3];
	for (int i = 0; i < 10; i++)
	{
		LBI_TryGetPathableLocationWithin(iClient, fSearchDist, fPathPos);
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

/*static float g_fSurvivorBot_UpdateRetreatPosTime[MAXPLAYERS+1];
bool TryRetreatingFromEntity(int iClient, int iEntity, float fSearchDist = 1024.0)
{
	if (GetGameTime() <= g_fSurvivorBot_UpdateRetreatPosTime[iClient] && strcmp(g_sSurvivorBot_MovePos_Name[iClient], "RetreatFromEntity") == 0)
		return true;

	float fEntityPos[3]; GetEntityAbsOrigin(iEntity, fEntityPos);
	float fEntityDist = GetVectorTravelDistance(fEntityPos, g_fClientAbsOrigin[iClient], true);

	float fSelfToPos[3]; MakeVectorFromPoints(g_fClientAbsOrigin[iClient], fEntityPos, fSelfToPos);
	NormalizeVector(fSelfToPos, fSelfToPos);

	float fDot, fPathPos[3], fPathOffset[3], fSelfToMovePos[3];
	for (int i = 0; i < 10; i++)
	{
		LBI_TryGetPathableLocationWithin(iClient, fSearchDist, fPathPos);
		if (!IsValidVector(fPathPos) || LBI_IsDamagingPosition(fPathPos))continue;

		fPathOffset = fPathPos; fPathOffset[2] + HUMAN_HALF_HEIGHT;

		MakeVectorFromPoints(g_fClientEyePos[iClient], fPathPos, fSelfToMovePos);
		NormalizeVector(fSelfToMovePos, fSelfToMovePos);

		fDot = GetVectorDotProduct(fSelfToPos, fSelfToMovePos);
		if (fDot > 0.33 || GetVectorTravelDistance(fEntityPos, fPathPos, true) < fEntityDist)continue;

		SetMoveToPosition(iClient, fPathPos, 3, "RetreatFromEntity");
		g_fSurvivorBot_UpdateRetreatPosTime[iClient] = GetGameTime() + 3.0;
		return true;
	}

	return false;
}*/

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

	float fTravelDist = GetClientTravelDistance(iClient, fMovePos, true);
	if (fTravelDist <= 0.0)fTravelDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true);

	float fMaxSpeed = GetClientMaxSpeed(iClient);
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime() + (fTravelDist / (fMaxSpeed*fMaxSpeed)) + fAddDuration;

	strcopy(g_sSurvivorBot_MovePos_Name[iClient], 512, sName);

	g_fSurvivorBot_MovePos_Position[iClient] = fMovePos;
	g_iSurvivorBot_MovePos_Priority[iClient] = iPriority;
	g_fSurvivorBot_MovePos_Tolerance[iClient] = fDistTolerance;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = bIgnoreDamaging;
}

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

bool SurvivorBot_IsTargetShootable(int iClient, int iTarget, int iCurWeapon, float fAimPos[3])
{
	int iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	bool bInViewCone = (GetClientAimTarget(iClient, false) == iTarget);	
	if (!bInViewCone)
	{
		float fCone = 2.0 * (512.0 / GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iTarget]));
		if (iCurWeapon == iPrimarySlot && SurvivorHasShotgun(iClient))fCone *= 2.0;
		bInViewCone = (FVectorInViewCone(iClient, g_fClientCenteroid[iTarget], fCone) && IsVisibleEntity(iClient, iTarget));
	}

	if (IsValidClient(iTarget))
	{
		if (bInViewCone)
		{
			L4D2ZombieClassType iClass = L4D2_GetPlayerZombieClass(iTarget);
			if (iClass == L4D2ZombieClass_Boomer && GetClientDistance(iClient, iTarget, true) <= BOT_BOOMER_AVOID_RADIUS_SQR)
				return false;
			if (iClass == L4D2ZombieClass_Tank && iCurWeapon == iPrimarySlot && GetWeaponClip1(iCurWeapon) < 3 && IsWeaponReloading(iCurWeapon, false) && SurvivorHasShotgun(iClient))
				return false;
		}

		if (GetClientTeam(iTarget) == 2 && !L4D_IsPlayerPinned(iTarget) && !L4D_IsPlayerIncapacitated(iClient))
		{
			if (bInViewCone && !g_bCvar_BotsShootThrough && (iCurWeapon == iPrimarySlot || iCurWeapon == GetClientWeaponInventory(iClient, 1) && (!SurvivorHasMeleeWeapon(iClient) || GetClientDistance(iClient, iTarget) <= 96.0)))
				return false;

			if (g_bCvar_BotsFriendlyFire) 
			{
				if (GetClientDistance(iClient, iTarget, true) <= 256.0)
					return false;
				if (iCurWeapon == iPrimarySlot && GetWeaponClip1(iCurWeapon) != 0 && GetVectorDistance(fAimPos, g_fClientCenteroid[iTarget], true) <= 90000.0 && SurvivorHasTier3Weapon(iClient) == 1 && GetVectorVisible(fAimPos, g_fClientCenteroid[iTarget]))
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
	if (iCurWeapon == GetClientWeaponInventory(iClient, 5))
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
		if (g_bCvar_BotsFriendlyFire && iClip != 0 && GetVectorDistance(fAimPos, g_fClientCenteroid[iClient], true) <= 90000.0 && SurvivorHasTier3Weapon(iClient) == 1 && GetVectorVisible(fAimPos, g_fClientCenteroid[iClient]))
		{
			if (IsEntityExists(g_iSurvivorBot_TargetInfected[iClient]) && (!SurvivorHasMeleeWeapon(iClient) || GetVectorDistance(fAimPos, g_fClientCenteroid[iClient], true) <= g_fCvar_ImprovedMelee_SwitchRange))
				SwitchWeaponSlot(iClient, 1);

			return false;
		}

		if (iClip < 2 && IsWeaponReloading(iCurWeapon, false) && SurvivorHasShotgun(iClient))
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
	if (IsWeaponSlotActive(iClient, 0) && SurvivorHasTier3Weapon(iClient) == 1 && (!IsValidClient(iTarget) || L4D2_GetPlayerZombieClass(iTarget) != L4D2ZombieClass_Jockey))
	{
		GetEntityAbsOrigin(iTarget, fAimPos);
		return;
	}

	static char sAimBone[64];
	float fDist = GetEntityDistance(iClient, iTarget, true);
	bool bIsUsingOldSkeleton = (SDKCall(g_hLookupBone, iTarget, "ValveBiped.Bip01_Pelvis") != -1);
	if (IsWitch(iTarget) && fDist <= 65536.0 && IsWeaponSlotActive(iClient, 0) && SurvivorHasShotgun(iClient) || (L4D_IsPlayerIncapacitated(iClient) && fDist <= 147456.0 || L4D2_IsRealismMode() && fDist <= 262144.0) && (!IsValidClient(iTarget) || L4D2_GetPlayerZombieClass(iTarget) != L4D2ZombieClass_Tank))
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
		if (IsWeaponSlotActive(i, 1) && SurvivorHasMeleeWeapon(i) == 2)iFreeSurvivors++;
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

static const char g_sSemiAutoWeapons[][] = 
{
	"pistol",
	"pistol_magnum",
	"pumpshotgun",
	"shotgun_chrome",
	"autoshotgun",
	"shotgun_spas",
	"hunting_rifle",
	"sniper_military",
	"sniper_scout",
	"sniper_awp",
	"grenade_launcher",
	"pain_pills",
	"adrenaline",
	"pipe_bomb",
	"molotov",
	"vomitjar"
};
bool PressAttackButton(int iClient, int &buttons, float fFireRate = -1.0)
{
	if (g_bClient_IsFiringWeapon[iClient])
		return false;

	int iWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (iWeapon == -1)return false;

	if (IsFakeClient(iClient) && (g_bCvar_BotsDontShoot || g_bSurvivorBot_PreventFire[iClient]))
		return false;

	static char sClassname[64];
	GetEdictClassname(iWeapon, sClassname, sizeof(sClassname));

	float fNextFireT = fFireRate;
	int bIsPistol = (strcmp(sClassname[7], "pistol") == 0 ? 1 : (strcmp(sClassname[7], "pistol_magnum") == 0 ? 2 : 0));
	if (fNextFireT <= 0.0 && (bIsPistol != 0 || GetWeaponTier(iWeapon) > 0))
	{
		float fCycleTime = GetWeaponCycleTime(iWeapon);
		float fAimPos[3]; GetClientAimPosition(iClient, fAimPos);

		float fClampDist = 2048.0;
		if (bIsPistol == 2)fClampDist *= 0.5;
		else if (GetEntProp(iWeapon, Prop_Send, "m_upgradeBitVec") & L4D2_WEPUPGFLAG_LASER)fClampDist *= 2.0;

		fNextFireT = (fCycleTime * (GetVectorDistance(g_fClientEyePos[iClient], fAimPos) / fClampDist));
	}

	if (fNextFireT < GetGameFrameTime())
	{
		for (int i = 0; i < sizeof(g_sSemiAutoWeapons); i++)
		{
			if (strcmp(sClassname[7], g_sSemiAutoWeapons[i]) == 0)
			{
				fNextFireT = GetGameFrameTime();
				break;
			}
		}
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

	char sItemClass[64]; 
	GetWeaponClassname(iItem, sItemClass, sizeof(sItemClass));

	int iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	if (IsEntityExists(iPrimarySlot))
	{
		int iWpnTier = GetWeaponTier(iPrimarySlot);

		int iBotPreference = GetSurvivorBotWeaponPreference(iClient);
		if (iBotPreference != 0)
		{
			if ((iWpnTier == 2 || iWpnTier == 1 && iBotPreference == L4D_WEAPON_PREFERENCE_SMG) && WeaponHasEnoughAmmoLeft(iPrimarySlot))
			{
				if (iBotPreference != L4D_WEAPON_PREFERENCE_ASSAULTRIFLE && (strcmp(sItemClass[7], "rifle") == 0 || strcmp(sItemClass[7], "rifle_ak47") == 0 || strcmp(sItemClass[7], "rifle_desert") == 0 || strcmp(sItemClass[7], "rifle_sg552") == 0))
					return Plugin_Handled;
				if (iBotPreference != L4D_WEAPON_PREFERENCE_SHOTGUN && (strcmp(sItemClass[7], "autoshotgun") == 0 || strcmp(sItemClass[7], "shotgun_spas") == 0))
					return Plugin_Handled;
				if (iBotPreference != L4D_WEAPON_PREFERENCE_SNIPERRIFLE && (strcmp(sItemClass[7], "sniper_military") == 0 || strcmp(sItemClass[7], "sniper_awp") == 0 || strcmp(sItemClass[7], "sniper_scout") == 0 || strcmp(sItemClass[7], "hunting_rifle") == 0))
					return Plugin_Handled;
			}
		}

		int iItemTier = GetWeaponTier(iItem);
		if (iWpnTier == 3) 
		{
			if (strcmp(sItemClass[7], "ammo_spawn") == 0)
				return Plugin_Handled;

			if (iItemTier == 1 || iItemTier == 2) 
			{
				if (SurvivorHasTier3Weapon(iClient) == 2)
				{
					if (GetWeaponClip1(iPrimarySlot) > RoundFloat(GetWeaponClipSize(iPrimarySlot) * 0.2) && GetSurvivorTeamItemCount(L4D2WeaponId_RifleM60) <= g_iCvar_MaxWeaponTier3_M60)
					{
						return Plugin_Handled;
					}
				}
				else if (GetClientPrimaryAmmo(iClient) > RoundFloat(GetWeaponMaxAmmo(iPrimarySlot) * 0.2) && GetSurvivorTeamItemCount(L4D2WeaponId_GrenadeLauncher) <= g_iCvar_MaxWeaponTier3_GLauncher)
				{
					return Plugin_Handled;
				}
			}
		}
		else if (iItemTier != 0 && GetClientPrimaryAmmo(iClient) < GetWeaponMaxAmmo(iPrimarySlot))
		{
			int iAmmoPileItem = GetItemFromArrayList(g_hAmmopileList, iClient, 1024.0, _, _, _, false);
			if (iAmmoPileItem != -1)return Plugin_Handled;
		}
	}

	int iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	if (IsEntityExists(iSecondarySlot))
	{
		if (g_bCvar_BotWeaponPreference_ForceMagnum && SurvivorHasPistol(iClient) == 3 && strcmp(sItemClass[7], "pistol") == 0)
			return Plugin_Handled;

		if (strcmp(sItemClass[7], "melee") == 0 && (!SurvivorHasMeleeWeapon(iClient) && ((GetSurvivorTeamItemCount(L4D2WeaponId_Chainsaw) + GetSurvivorTeamItemCount(L4D2WeaponId_Melee)) >= g_iCvar_MaxMeleeSurvivors) || SurvivorHasMeleeWeapon(iClient) == 2 && GetSurvivorTeamItemCount(L4D2WeaponId_Chainsaw) <= g_iCvar_ImprovedMelee_ChainsawLimit)) 
			return Plugin_Handled;

		if ((strcmp(sItemClass[7], "pistol") == 0 || strcmp(sItemClass[7], "pistol_magnum") == 0) && SurvivorHasMeleeWeapon(iClient) == 2 && GetSurvivorTeamItemCount(L4D2WeaponId_Chainsaw) <= g_iCvar_ImprovedMelee_ChainsawLimit && g_iWeapon_Clip1[iSecondarySlot] > RoundFloat(GetWeaponMaxAmmo(iSecondarySlot) * 0.25) && GetSurvivorTeamItemCount(L4D2WeaponId_Melee) <= g_iCvar_MaxMeleeSurvivors)
			return Plugin_Handled;
	}

	if (IsWeaponSlotActive(iClient, 3) && (strcmp(sItemClass[7], "first_aid_kit") == 0 || strcmp(sItemClass[7], "defibrillator") == 0) && SurvivorHasHealthKit(iClient) == 3)
		return Plugin_Handled;

	if (strcmp(sItemClass[7], "first_aid_kit") == 0 && IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && SurvivorHasHealthKit(iClient) == 2)
		return Plugin_Handled;

	return Plugin_Continue;
}

bool WeaponHasEnoughAmmoLeft(int iWeapon)
{
	return (g_iWeapon_MaxAmmo[iWeapon] > 0 && (g_iWeapon_AmmoLeft[iWeapon] + g_iWeapon_Clip1[iWeapon]) >= RoundFloat(g_iWeapon_MaxAmmo[iWeapon] * 0.33));
}

bool IsEntityWeapon(int iEntity, bool bNoSpawn = false)
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
	int iItem = -1;
	int iItemBits = g_iCvar_ItemScavenge_Items;

	int iArrayItem;
	ArrayList hItemList = new ArrayList();

	int iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	int iTier3Primary = SurvivorHasTier3Weapon(iClient);
	int iWpnPreference = GetSurvivorBotWeaponPreference(iClient);

	if (iItemBits & (1 << 13) != 0 && iPrimarySlot == -1)
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

	if (iWpnPreference != 0 && iWpnPreference != L4D_WEAPON_PREFERENCE_SECONDARY && iTier3Primary == 0)
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
				bHasWep = SurvivorHasShotgun(iClient) > 0;
			}
			case L4D_WEAPON_PREFERENCE_SNIPERRIFLE:
			{
				hWeaponList = g_hSniperRifleList;
				bHasWep = SurvivorHasSniperRifle(iClient) > 0;
			}
			case L4D_WEAPON_PREFERENCE_SMG:
			{
				hWeaponList = g_hSMGList;
				bHasWep = SurvivorHasSMG(iClient);
			}
		}

		if (!bHasWep && iItemBits & (1 << 13) != 0 || GetWeaponTier(iPrimarySlot) == 1 && iWpnPreference != L4D_WEAPON_PREFERENCE_SMG)
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
		if (iTier3Primary != 1 && GetSurvivorTeamItemCount(L4D2WeaponId_GrenadeLauncher) < g_iCvar_MaxWeaponTier3_GLauncher)
		{
			iArrayItem = GetItemFromArrayList(g_hTier3List, iClient, _, "weapon_grenade_launcher");
			if (iArrayItem != -1)
			{
				hItemList.Push(iArrayItem);
			}
		}

		if (iTier3Primary != 2 && GetSurvivorTeamItemCount(L4D2WeaponId_RifleM60) < g_iCvar_MaxWeaponTier3_M60)
		{
			iArrayItem = GetItemFromArrayList(g_hTier3List, iClient, _, "weapon_rifle_m60");
			if (iArrayItem != -1)
			{
				hItemList.Push(iArrayItem);
			}
		}
	}

	if (iItemBits & (1 << 4) != 0 && GetClientWeaponInventory(iClient, 3) == -1 || IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && SurvivorHasHealthKit(iClient) != 2)
	{
		iArrayItem = GetItemFromArrayList(g_hDefibrillatorList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (GetClientWeaponInventory(iClient, 3) == -1)
	{
		iArrayItem = (iItemBits & (1 << 3) == 0 ? -1 : GetItemFromArrayList(g_hFirstAidKitList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = (iItemBits & (1 << 5) == 0 ? -1 : GetItemFromArrayList(g_hUpgradePackList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (GetClientWeaponInventory(iClient, 4) == -1)
	{
		iArrayItem = (iItemBits & (1 << 6) == 0 ? -1 : GetItemFromArrayList(g_hPainPillsList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = (iItemBits & (1 << 7) == 0 ? -1 : GetItemFromArrayList(g_hAdrenalineList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	int iGrenadeSlot = GetClientWeaponInventory(iClient, 2);
	if (iGrenadeSlot == -1)
	{
		iArrayItem = ((iItemBits & (1 << 0) != 0) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, "weapon_pipe_bomb") : -1);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = ((iItemBits & (1 << 1) != 0) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, "weapon_molotov") : -1);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = ((iItemBits & (1 << 2) != 0) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, "weapon_vomitjar") : -1);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}
	else if (g_bCvar_SwapSameTypeGrenades)
	{	
		static char sGrenadeSlot[64]; 
		GetEdictClassname(iGrenadeSlot, sGrenadeSlot, sizeof(sGrenadeSlot));

		static char sAvoidGrenade[64];
		FormatEx(sAvoidGrenade, sizeof(sAvoidGrenade), "!!%s", sGrenadeSlot);

		int iGrenadeTypeLimit = RoundFloat((GetSurvivorTeamItemCount(L4D2WeaponId_PipeBomb) + GetSurvivorTeamItemCount(L4D2WeaponId_Molotov) + GetSurvivorTeamItemCount(L4D2WeaponId_Vomitjar)) * 0.55);
		if (iGrenadeTypeLimit < 1)iGrenadeTypeLimit = 1;

		if (GetSurvivorTeamItemCount(L4D2_GetWeaponId(iGrenadeSlot)) > iGrenadeTypeLimit)
		{
			iArrayItem = GetItemFromArrayList(g_hGrenadeList, iClient, _, sAvoidGrenade);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
	}

	if (iPrimarySlot != -1)
	{
		static char sPrimarySlot[64]; 
		GetEdictClassname(iPrimarySlot, sPrimarySlot, sizeof(sPrimarySlot));

		if (iTier3Primary == 0 && iItemBits & (1 << 10) != 0)
		{
			int iPrimaryMaxAmmo = GetWeaponMaxAmmo(iPrimarySlot);

			int iMinAmmo = iPrimaryMaxAmmo;
			if (!L4D_IsInFirstCheckpoint(iClient))
				iMinAmmo = RoundFloat(iMinAmmo * ((!LBI_IsSurvivorInCombat(iClient) && !L4D_HasVisibleThreats(iClient)) ? 0.75 : 0.5));

			if (GetClientPrimaryAmmo(iClient) < iMinAmmo)
			{
				iArrayItem = GetItemFromArrayList(g_hAmmopileList, iClient);
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}
		}

		if (g_bCvar_SwitchOffCSSWeapons)
		{
			if (strcmp(sPrimarySlot[7], "smg_mp5") == 0)
			{				
				iArrayItem = GetItemFromArrayList(g_hSMGList, iClient, _, "!!smg_mp5");
				if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
				{
					hItemList.Push(iArrayItem);
				}
			}
			else if (strcmp(sPrimarySlot[7], "rifle_sg552") == 0) 
			{				
				iArrayItem = GetItemFromArrayList(g_hAssaultRifleList, iClient, _, "!!rifle_sg552");
				if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
				{
					hItemList.Push(iArrayItem);
				}
			}
			else if (strcmp(sPrimarySlot[7], "sniper_scout") == 0 || strcmp(sPrimarySlot[7], "sniper_awp") == 0)
			{				
				iArrayItem = GetItemFromArrayList(g_hSniperRifleList, iClient, _, "!!sniper_scout");
				if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
				{
					hItemList.Push(iArrayItem);
				}
				else
				{
					iArrayItem = GetItemFromArrayList(g_hSniperRifleList, iClient, _, "!!sniper_awp");
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}	
				}
			}
		}

		if (g_bCvar_SwapSameTypePrimaries)
		{
			if (iWpnPreference != L4D_WEAPON_PREFERENCE_SMG)
			{
				int iSMGCount = (GetSurvivorTeamItemCount(L4D2WeaponId_Smg) + GetSurvivorTeamItemCount(L4D2WeaponId_SmgSilenced) + GetSurvivorTeamItemCount(L4D2WeaponId_SmgMP5));
				int iShotgunCount = (GetSurvivorTeamItemCount(L4D2WeaponId_ShotgunChrome) + GetSurvivorTeamItemCount(L4D2WeaponId_Pumpshotgun));

				int iTier1Limit = RoundToCeil((iSMGCount + iShotgunCount) * 0.5);
				if (iTier1Limit < 1)iTier1Limit = 1;

				if (iShotgunCount > iTier1Limit && (strcmp(sPrimarySlot[7], "shotgun_chrome") == 0 || strcmp(sPrimarySlot[7], "pumpshotgun") == 0))
				{
					iArrayItem = GetItemFromArrayList(g_hSMGList, iClient);
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}
				}
				else if (iSMGCount > iTier1Limit && (strcmp(sPrimarySlot[7], "smg") == 0 || strcmp(sPrimarySlot[7], "smg_silenced") == 0 || strcmp(sPrimarySlot[7], "smg_mp5") == 0))
				{
					iArrayItem = GetItemFromArrayList(g_hShotgunT1List, iClient);
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}
				}
			}

			int iPrimaryCount = GetSurvivorTeamItemCount(L4D2_GetWeaponId(iPrimarySlot));
			static char sAvoidWeapon[64];
			FormatEx(sAvoidWeapon, sizeof(sAvoidWeapon), "!!%s", sPrimarySlot);

			int iWepLimit = -1;
			ArrayList hWepArray;
			if (SurvivorHasShotgun(iClient))
			{
				hWepArray = g_hShotgunT2List;
				iWepLimit = RoundFloat((GetSurvivorTeamItemCount(L4D2WeaponId_Autoshotgun) + GetSurvivorTeamItemCount(L4D2WeaponId_ShotgunSpas)) * 0.5);
			}
			else if (SurvivorHasAssaultRifle(iClient))
			{
				hWepArray = g_hAssaultRifleList;
				iWepLimit = RoundFloat((GetSurvivorTeamItemCount(L4D2WeaponId_Rifle) + GetSurvivorTeamItemCount(L4D2WeaponId_RifleAK47) + GetSurvivorTeamItemCount(L4D2WeaponId_RifleDesert) + GetSurvivorTeamItemCount(L4D2WeaponId_RifleSG552)) * 0.5);
			}
			else if (SurvivorHasSniperRifle(iClient))
			{
				hWepArray = g_hSniperRifleList;
				iWepLimit = RoundFloat((GetSurvivorTeamItemCount(L4D2WeaponId_HuntingRifle) + GetSurvivorTeamItemCount(L4D2WeaponId_SniperMilitary) + GetSurvivorTeamItemCount(L4D2WeaponId_SniperScout) + GetSurvivorTeamItemCount(L4D2WeaponId_SniperAWP)) * 0.5);
			}
			if (iWepLimit != -1 && iWepLimit < 1)iWepLimit = 1;

			if (iPrimaryCount > iWepLimit)
			{
				iArrayItem = GetItemFromArrayList(hWepArray, iClient, _, sAvoidWeapon);
				if (iArrayItem != -1 && (WeaponHasEnoughAmmoLeft(iArrayItem) || IsWeaponNearAmmoPile(iArrayItem, iClient)))
				{
					hItemList.Push(iArrayItem);
				}
			}
		}

		int iUpgradeBits = GetEntProp(iPrimarySlot, Prop_Send, "m_upgradeBitVec");
		if (!(iUpgradeBits & L4D2_WEPUPGFLAG_LASER) && iItemBits & (1 << 8) != 0)
		{
			iArrayItem = GetItemFromArrayList(g_hLaserSightList, iClient);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
		if (iItemBits & (1 << 9) != 0 && !(iUpgradeBits & L4D2_WEPUPGFLAG_INCENDIARY) && !(iUpgradeBits & L4D2_WEPUPGFLAG_EXPLOSIVE))
		{
			iArrayItem = GetItemFromArrayList(g_hDeployedAmmoPacks, iClient);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
	}

	int iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	if (iSecondarySlot != -1)
	{
		int iMeleeCount = GetSurvivorTeamItemCount(L4D2WeaponId_Melee);
		int iChainsawCount = GetSurvivorTeamItemCount(L4D2WeaponId_Chainsaw);
		int iMeleeType = SurvivorHasMeleeWeapon(iClient);

		if (iMeleeType != 0)
		{
			if (iMeleeType != 2)
			{
				if (iItemBits & (1 << 11) != 0 && (iMeleeCount + iChainsawCount) <= g_iCvar_MaxMeleeSurvivors && iChainsawCount < g_iCvar_ImprovedMelee_ChainsawLimit)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, "weapon_chainsaw");
					if (iArrayItem != -1 && g_iWeapon_Clip1[iArrayItem] > RoundFloat(GetWeaponMaxAmmo(iArrayItem) * 0.25))
					{
						hItemList.Push(iArrayItem);
					}
				}
			}
			else if (iChainsawCount > g_iCvar_ImprovedMelee_ChainsawLimit || g_iWeapon_Clip1[iSecondarySlot] <= RoundFloat(GetWeaponMaxAmmo(iSecondarySlot) * 0.25))
			{
				bool bFoundMelee = false;
				if (iMeleeCount < g_iCvar_MaxMeleeSurvivors)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, "weapon_melee");
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
		else if (iItemBits & (1 << 12) != 0)
		{
			if ((iMeleeCount + iChainsawCount) < g_iCvar_MaxMeleeSurvivors)
			{
				iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, "weapon_melee");
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}

			int iHasPistol = SurvivorHasPistol(iClient);
			if (iHasPistol != 0)
			{
				if (g_bCvar_BotWeaponPreference_ForceMagnum && iHasPistol != 3)
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient, _, "weapon_pistol_magnum");
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				}
				else if (iHasPistol == 1)
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient, _, "weapon_pistol");
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
			fCurDist = GetEntityTravelDistance(iClient, iCurItem, true);
			if (fLastDist != -1.0 && fCurDist >= fLastDist)continue;

			iItem = iCurItem;
			fLastDist = fCurDist;
		}
	}

	delete hItemList;
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

int GetItemFromArrayList(ArrayList hArrayList, int iClient, float fDistance = -1.0, const char[] sEntityName = "", const char[] sModelName = "", bool bCheckIsReachable = true, bool bCheckIsVisible = true)
{
	if (!hArrayList || hArrayList.Length <= 0)return -1;
	if (fDistance == -1.0)fDistance = g_fCvar_ItemScavenge_ApproachVisibleRange;

	float fClientPos[3];
	GetEntityAbsOrigin(iClient, fClientPos);

	int iEntIndex, iNavArea, iUseCount;
	float fEntityPos[3];
	float fCheckDist, fCurDist;
	bool bIsTaken, bInUseRange, bValidClient = IsValidClient(iClient);

 	char sWeaponName[MAX_TARGET_LENGTH];
	char sEntityModel[PLATFORM_MAX_PATH];

	int iPrimarySlot, iPrimaryTier;
	float fPickupRange;
	bool bPrimaryHasAmmo, bIsCoop, bInCheckpoint;
	if (bValidClient)
	{
		iPrimarySlot = GetClientWeaponInventory(iClient, 0);
		if (IsEntityExists(iPrimarySlot))
		{
			bPrimaryHasAmmo = WeaponHasEnoughAmmoLeft(iPrimarySlot);
			iPrimaryTier = GetWeaponTier(iPrimarySlot);
		}

		bIsCoop = L4D2_IsGenericCooperativeMode(); 
		bInCheckpoint = LBI_IsPositionInsideCheckpoint(g_fClientAbsOrigin[iClient]);
		fPickupRange = (g_fCvar_ItemScavenge_PickupRange*g_fCvar_ItemScavenge_PickupRange);
	}

	for (int i = 0; i < hArrayList.Length; i++)
	{		
		iEntIndex = EntRefToEntIndex(hArrayList.Get(i));
		if (iEntIndex == INVALID_ENT_REFERENCE || IsValidClient(GetEntityOwner(iEntIndex)))
			continue;

		iUseCount = ItemSpawnerHasEnoughItems(iEntIndex);
		if (iUseCount == 0)continue;

		if (!GetEntityAbsOrigin(iEntIndex, fEntityPos) || GetVectorDistance(fClientPos, fEntityPos, true) > g_fCvar_ItemScavenge_MapSearchRange)
			continue;

		if (sModelName[0] != 0)
		{
			GetEntityModelname(iEntIndex, sEntityModel, sizeof(sEntityModel));
			if (strcmp(sEntityModel, sModelName, false) != 0)continue;
		}

		GetEntityClassname(iEntIndex, sWeaponName, sizeof(sWeaponName));
		if (g_iItem_Used[iEntIndex] & (1 << (iClient - 1)) != 0 && (strcmp(sWeaponName, "upgrade_ammo_explosive") == 0 || strcmp(sWeaponName, "upgrade_ammo_incendiary") == 0) || strcmp(sWeaponName, "prop_dynamic") == 0)
			continue;

		GetWeaponClassname(iEntIndex, sWeaponName, sizeof(sWeaponName));
		if (sEntityName[0] != 0)
		{
			if (sEntityName[0] == '!' && sEntityName[1] == '!') 
			{
				if (strcmp(sWeaponName, sEntityName[2], false) == 0)
				{
					continue;
				}
			}
			else if (strcmp(sWeaponName, sEntityName, false) != 0)
			{
				continue;
			}
		}
		
		fCheckDist = fDistance; 
		if (bValidClient)
		{
			if (g_bCvar_SwitchOffCSSWeapons && iPrimarySlot != -1 && bPrimaryHasAmmo && (iPrimaryTier == 1 && strcmp(sWeaponName[7], "smg_mp5") == 0 || iPrimaryTier == 2 && (strcmp(sWeaponName[7], "rifle_sg552") == 0 || strcmp(sWeaponName[7], "sniper_scout") == 0 || strcmp(sWeaponName[7], "sniper_awp") == 0)))
				continue;

			if (g_iWeapon_AmmoLeft[iEntIndex] <= RoundFloat(g_iWeapon_MaxAmmo[iEntIndex] * 0.2) && strcmp(sWeaponName[7], "grenade_launcher") == 0)
				continue;

			if ((g_iWeapon_Clip1[iEntIndex] <= 0 || g_iWeapon_Clip1[iEntIndex] <= RoundFloat(L4D2_GetIntWeaponAttribute("weapon_rifle_m60", L4D2IWA_ClipSize) * 0.2)) && strcmp(sWeaponName[7], "rifle_m60") == 0)
				continue;

			if (iUseCount == 1 && strcmp(sWeaponName[7], "ammo_spawn") != 0)
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
	CheckEntityForStuff(iEntity, sClassname);
}

void CheckEntityForStuff(int iEntity, const char[] sClassname)
{
	if (g_hWitchList && strcmp(sClassname, "witch") == 0)
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
		g_hWitchList.Set(iIndex, 0, 1); return;
	}

	if (strcmp(sClassname, "weapon_ammo_spawn") == 0)
	{
		PushEntityIntoArrayList(g_hAmmopileList, iEntity);
		return;
	}
	if (strcmp(sClassname, "upgrade_laser_sight") == 0)
	{
		PushEntityIntoArrayList(g_hLaserSightList, iEntity);
		return;
	}
	if (strcmp(sClassname, "upgrade_ammo_explosive") == 0 || strcmp(sClassname, "upgrade_ammo_incendiary") == 0)
	{
		PushEntityIntoArrayList(g_hDeployedAmmoPacks, iEntity);
		return;
	}
	
	if (strcmp(sClassname, "pipe_bomb_projectile") == 0 || strcmp(sClassname, "vomitjar_projectile") == 0)
	{
		g_fSurvivorBot_Grenade_NextThrowTime = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
		return;
	}
	if (strcmp(sClassname, "molotov_projectile") == 0)
	{
		g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
		return;
	}

	L4D2WeaponId iWeaponID = L4D2_GetWeaponId(iEntity);
	if (iWeaponID == L4D2WeaponId_None)return;

	if (iWeaponID == L4D2WeaponId_Pistol || iWeaponID == L4D2WeaponId_PistolMagnum)
		PushEntityIntoArrayList(g_hPistolList, iEntity);
	else if (iWeaponID == L4D2WeaponId_Melee || iWeaponID == L4D2WeaponId_Chainsaw)
		PushEntityIntoArrayList(g_hMeleeList, iEntity);
	else if (iWeaponID == L4D2WeaponId_Smg || iWeaponID == L4D2WeaponId_SmgSilenced || iWeaponID == L4D2WeaponId_SmgMP5)
		PushEntityIntoArrayList(g_hSMGList, iEntity);
	else if (iWeaponID == L4D2WeaponId_Pumpshotgun || iWeaponID == L4D2WeaponId_ShotgunChrome)
		PushEntityIntoArrayList(g_hShotgunT1List, iEntity);
	else if (iWeaponID == L4D2WeaponId_Rifle || iWeaponID == L4D2WeaponId_RifleAK47 || iWeaponID == L4D2WeaponId_RifleDesert || iWeaponID == L4D2WeaponId_RifleSG552)
		PushEntityIntoArrayList(g_hAssaultRifleList, iEntity);
	else if (iWeaponID == L4D2WeaponId_Autoshotgun || iWeaponID == L4D2WeaponId_ShotgunSpas)
		PushEntityIntoArrayList(g_hShotgunT2List, iEntity);
	else if (iWeaponID == L4D2WeaponId_HuntingRifle || iWeaponID == L4D2WeaponId_SniperMilitary || iWeaponID == L4D2WeaponId_SniperScout || iWeaponID == L4D2WeaponId_SniperAWP)
		PushEntityIntoArrayList(g_hSniperRifleList, iEntity);
	else if (iWeaponID == L4D2WeaponId_PipeBomb || iWeaponID == L4D2WeaponId_Molotov || iWeaponID == L4D2WeaponId_Vomitjar)
		PushEntityIntoArrayList(g_hGrenadeList, iEntity);
	else if (iWeaponID == L4D2WeaponId_RifleM60 || iWeaponID == L4D2WeaponId_GrenadeLauncher)
		PushEntityIntoArrayList(g_hTier3List, iEntity);
	else if (iWeaponID == L4D2WeaponId_FragAmmo || iWeaponID == L4D2WeaponId_IncendiaryAmmo)
		PushEntityIntoArrayList(g_hUpgradePackList, iEntity);
	else if (iWeaponID == L4D2WeaponId_FirstAidKit)
		PushEntityIntoArrayList(g_hFirstAidKitList, iEntity);
	else if (iWeaponID == L4D2WeaponId_Defibrillator)
		PushEntityIntoArrayList(g_hDefibrillatorList, iEntity);
	else if (iWeaponID == L4D2WeaponId_PainPills)
		PushEntityIntoArrayList(g_hPainPillsList, iEntity);
	else if (iWeaponID == L4D2WeaponId_Adrenaline)
		PushEntityIntoArrayList(g_hAdrenalineList, iEntity);

	if (iWeaponID == L4D2WeaponId_Chainsaw)
	{
		g_iWeapon_Clip1[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iWeapon_MaxAmmo[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iWeapon_AmmoLeft[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
	}
	else if (iWeaponID != L4D2WeaponId_RifleM60 && iWeaponID != L4D2WeaponId_GrenadeLauncher)
	{
		static char sWeaponName[64];
		if (L4D2_GetWeaponNameByWeaponId(iWeaponID, sWeaponName, sizeof(sWeaponName)) && L4D2_GetIntWeaponAttribute(sWeaponName, L4D2IWA_Tier) != 0)
		{
			g_iWeapon_Clip1[iEntity] = L4D2_GetIntWeaponAttribute(sWeaponName, L4D2IWA_ClipSize);
			g_iWeapon_MaxAmmo[iEntity] = GetWeaponMaxAmmo(iEntity, iWeaponID);
			g_iWeapon_AmmoLeft[iEntity] = g_iWeapon_MaxAmmo[iEntity];
		}
	}

	//if (IsEntityWeapon(iEntity))
	//{
	//	static char sWeaponName[64];
	//	GetWeaponClassname(iEntity, sWeaponName, sizeof(sWeaponName));

	//	if (strcmp(sWeaponName[7], "pistol") == 0 || strcmp(sWeaponName[14], "magnum") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hPistolList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "melee") == 0 || strcmp(sWeaponName[7], "chainsaw") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hMeleeList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "smg") == 0 || strcmp(sWeaponName[11], "silenced") == 0 || strcmp(sWeaponName[7], "smg_mp5") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hSMGList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "pumpshotgun") == 0 || strcmp(sWeaponName[7], "shotgun_chrome") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hShotgunT1List, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "rifle") == 0 || strcmp(sWeaponName[7], "rifle_ak47") == 0 || strcmp(sWeaponName[7], "rifle_desert") == 0 || strcmp(sWeaponName[7], "rifle_sg552") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hAssaultRifleList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "autoshotgun") == 0 || strcmp(sWeaponName[7], "shotgun_spas") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hShotgunT2List, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "hunting_rifle") == 0 || strcmp(sWeaponName[7], "sniper_military") == 0 || strcmp(sWeaponName[7], "sniper_awp") == 0 || strcmp(sWeaponName[7], "sniper_scout") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hSniperRifleList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "pipe_bomb") == 0 || strcmp(sWeaponName[7], "molotov") == 0 || strcmp(sWeaponName[7], "vomitjar") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hGrenadeList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "rifle_m60") == 0 || strcmp(sWeaponName[15], "launcher") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hTier3List, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[19], "explosive") == 0 || strcmp(sWeaponName[19], "incendiary") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hUpgradePackList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "first_aid_kit") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hFirstAidKitList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "defibrillator") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hDefibrillatorList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "pain_pills") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hPainPillsList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "adrenaline") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hAdrenalineList, iEntity);
	//	}
	//	else if (strcmp(sWeaponName[7], "ammo_spawn") == 0)
	//	{
	//		PushEntityIntoArrayList(g_hAmmopileList, iEntity);
	//	}

	//	if ((strcmp(sWeaponName[7], "chainsaw") == 0 || GetWeaponTier(iEntity) > 0) && g_iWeapon_MaxAmmo[iEntity] <= 0)
	//	{
	//		g_iWeapon_Clip1[iEntity] = (strcmp(sWeaponName[7], "chainsaw") == 0 ? GetWeaponMaxAmmo(iEntity) : L4D2_GetIntWeaponAttribute(sWeaponName, L4D2IWA_ClipSize));
	//		g_iWeapon_MaxAmmo[iEntity] = GetWeaponMaxAmmo(iEntity);
	//		g_iWeapon_AmmoLeft[iEntity] = g_iWeapon_MaxAmmo[iEntity];
	//	}
	//}
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

	int iEntity = INVALID_ENT_REFERENCE;
	static char sEntClassname[64];
	while ((iEntity = FindEntityByClassname(iEntity, "*")) != INVALID_ENT_REFERENCE)
	{
		if (!IsEntityExists(iEntity))continue;
		GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
		CheckEntityForStuff(iEntity, sEntClassname);
	}
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	g_sCurrentMapName[0] = 0;
	ClearEntityArrayLists();
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
	g_hWitchList 			= new ArrayList(2);
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
	g_hWitchList.Clear();
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
	static char sWeaponName[64]; GetWeaponClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	if (!L4D2_IsValidWeapon(sWeaponName))return -1.0;
	return L4D2_GetFloatWeaponAttribute(sWeaponName, L4D2FWA_CycleTime);
}

int GetWeaponMaxAmmo(int iWeapon, L4D2WeaponId iWeaponID = L4D2WeaponId_None)
{
	int iAmmoType = GetWeaponAmmoType(iWeapon);
	if (iAmmoType != -1)
	{
		switch(iAmmoType)
		{
			case 1, 2: 	return g_iCvar_MaxAmmo_Pistol;
			case 3: 	return g_iCvar_MaxAmmo_AssaultRifle;
			case 5: 	return g_iCvar_MaxAmmo_SMG;
			case 6: 	return (g_iCvar_MaxAmmo_M60 > 0 ? g_iCvar_MaxAmmo_M60 : L4D2_GetIntWeaponAttribute("weapon_rifle_m60", L4D2IWA_ClipSize));
			case 7: 	return g_iCvar_MaxAmmo_Shotgun;
			case 8: 	return g_iCvar_MaxAmmo_AutoShotgun;
			case 9: 	return g_iCvar_MaxAmmo_HuntRifle;
			case 10: 	return g_iCvar_MaxAmmo_SniperRifle;
			case 12: 	return g_iCvar_MaxAmmo_PipeBomb;
			case 13: 	return g_iCvar_MaxAmmo_Molotov;
			case 14: 	return g_iCvar_MaxAmmo_VomitJar;
			case 15: 	return g_iCvar_MaxAmmo_PainPills;
			case 16: 	
			{
				if (iWeaponID == L4D2WeaponId_None)iWeaponID = L4D2_GetWeaponId(iWeapon);
				return ((iWeaponID == L4D2WeaponId_FragAmmo || iWeaponID == L4D2WeaponId_IncendiaryAmmo) ? g_iCvar_MaxAmmo_AmmoPack : g_iCvar_MaxAmmo_Medkit);
			}
			case 17: 	return g_iCvar_MaxAmmo_GrenLauncher;
			case 18: 	return g_iCvar_MaxAmmo_Adrenaline;
			case 19: 	return g_iCvar_MaxAmmo_Chainsaw;
			default:	return -1;
		}
	}

	if (iWeaponID == L4D2WeaponId_None)
		iWeaponID = L4D2_GetWeaponId(iWeapon);

	if (iWeaponID == L4D2WeaponId_Pistol || iWeaponID == L4D2WeaponId_PistolMagnum)
		return g_iCvar_MaxAmmo_SMG;
	else if (iWeaponID == L4D2WeaponId_Smg || iWeaponID == L4D2WeaponId_SmgSilenced || iWeaponID == L4D2WeaponId_SmgMP5)
		return g_iCvar_MaxAmmo_SMG;
	else if (iWeaponID == L4D2WeaponId_Pumpshotgun || iWeaponID == L4D2WeaponId_ShotgunChrome)
		return g_iCvar_MaxAmmo_Shotgun;
	else if (iWeaponID == L4D2WeaponId_Autoshotgun || iWeaponID == L4D2WeaponId_ShotgunSpas)
		return g_iCvar_MaxAmmo_AutoShotgun;
	else if (iWeaponID == L4D2WeaponId_Rifle || iWeaponID == L4D2WeaponId_RifleAK47 || iWeaponID == L4D2WeaponId_RifleDesert || iWeaponID == L4D2WeaponId_RifleSG552)
		return g_iCvar_MaxAmmo_AssaultRifle;
	else if (iWeaponID == L4D2WeaponId_HuntingRifle)
		return g_iCvar_MaxAmmo_HuntRifle;
	else if (iWeaponID == L4D2WeaponId_SniperMilitary || iWeaponID == L4D2WeaponId_SniperScout || iWeaponID == L4D2WeaponId_SniperAWP)
		return g_iCvar_MaxAmmo_SniperRifle;
	else if (iWeaponID == L4D2WeaponId_GrenadeLauncher)
		return g_iCvar_MaxAmmo_GrenLauncher;
	else if (iWeaponID == L4D2WeaponId_RifleM60)
		return g_iCvar_MaxAmmo_M60;
	else if (iWeaponID == L4D2WeaponId_FirstAidKit)
		return g_iCvar_MaxAmmo_Medkit;
	else if (iWeaponID == L4D2WeaponId_Adrenaline)
		return g_iCvar_MaxAmmo_Adrenaline;
	else if (iWeaponID == L4D2WeaponId_PainPills)
		return g_iCvar_MaxAmmo_PainPills;
	else if (iWeaponID == L4D2WeaponId_FragAmmo || iWeaponID == L4D2WeaponId_IncendiaryAmmo)
		return g_iCvar_MaxAmmo_AmmoPack;
	else if (iWeaponID == L4D2WeaponId_Chainsaw)
		return g_iCvar_MaxAmmo_Chainsaw;
	else if (iWeaponID == L4D2WeaponId_PipeBomb)
		return g_iCvar_MaxAmmo_PipeBomb;
	else if (iWeaponID == L4D2WeaponId_Molotov)
		return g_iCvar_MaxAmmo_Molotov;
	else if (iWeaponID == L4D2WeaponId_Vomitjar)
		return g_iCvar_MaxAmmo_VomitJar;

	return -1;
}

int GetWeaponTier(int iWeapon)
{
	if (!IsEntityWeapon(iWeapon))return -1;
	
	char sWeaponName[64]; GetWeaponClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	if (!L4D2_IsValidWeapon(sWeaponName))return -1;
	
	int iTier = L4D2_GetIntWeaponAttribute(sWeaponName, L4D2IWA_Tier);
	return ((strcmp(sWeaponName[7], "rifle_m60") == 0 || strcmp(sWeaponName[15], "launcher") == 0) && iTier == 0 ? 3 : iTier);
}

/*
static const char g_sCarriableProps[][] = 
{
	"gnome",
	"gascan",
	"propanetank",
	"oxygentank",
	"fireworkcrate",
	"cola_bottles"
};
*/

bool IsSurvivorCarryingProp(int iClient)
{
	return (IsWeaponSlotActive(iClient, 5));

	/*
	char sCurWeaponClass[64]; 
	GetClientWeapon(iClient, sCurWeaponClass, sizeof(sCurWeaponClass));
	for (int i = 0; i < sizeof(g_sCarriableProps); i++)
	{
		if (strcmp(sCurWeaponClass[7], g_sCarriableProps[i]) == 0)
		{
			return true;
		}
	}
	return false;
	*/
}

bool GetWeaponClassname(int iWeapon, char[] sBuffer, int iMaxLength)
{
	L4D2WeaponId iWeaponID = L4D2_GetWeaponId(iWeapon);
	if (iWeaponID != L4D2WeaponId_None)
	{
		L4D2_GetWeaponNameByWeaponId(iWeaponID, sBuffer, iMaxLength);
		if (strcmp(sBuffer, "weapon_ammo") == 0)strcopy(sBuffer, iMaxLength, "weapon_ammo_spawn");
		return true;
	}

	char sWeaponModel[PLATFORM_MAX_PATH];
	GetEntityModelname(iWeapon, sWeaponModel, sizeof(sWeaponModel));

	// SIDEARMS
	if (strcmp(sWeaponModel[24], "w_pistol_a.mdl", false) == 0 || strcmp(sWeaponModel[24], "w_pistol_a_dual.mdl", false) == 0 || strcmp(sWeaponModel[24], "w_pistol_b.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_pistol_magnum");
	else if (strcmp(sWeaponModel[24], "w_desert_eagle.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_pistol_magnum");

	// SMGS
	else if (strcmp(sWeaponModel[24], "w_smg_uzi.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_smg");
	else if (strcmp(sWeaponModel[24], "w_smg_a.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_smg_silenced");
	else if (strcmp(sWeaponModel[24], "w_smg_mp5.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_smg_mp5");

	// TIER 1 SHOTGUNS
	else if (strcmp(sWeaponModel[24], "w_pumpshotgun_a.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_shotgun_chrome");
	else if (strcmp(sWeaponModel[24], "w_shotgun.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_pumpshotgun");

	// ASSAULT RIFLES
	else if (strcmp(sWeaponModel[24], "w_rifle_m16a2.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_rifle");
	else if (strcmp(sWeaponModel[24], "w_rifle_ak47.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_rifle_ak47");
	else if (strcmp(sWeaponModel[24], "w_desert_rifle.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_rifle_desert");
	else if (strcmp(sWeaponModel[24], "w_rifle_sg552.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_rifle_sg552");

	// TIER 2 SHOTGUNS
	else if (strcmp(sWeaponModel[24], "w_autoshot_m4super.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_autoshotgun");
	else if (strcmp(sWeaponModel[24], "w_shotgun_spas.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_shotgun_spas");

	// SNIPER RIFLES
	else if (strcmp(sWeaponModel[24], "w_sniper_mini14.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_hunting_rifle");
	else if (strcmp(sWeaponModel[24], "w_sniper_military.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_sniper_military");
	else if (strcmp(sWeaponModel[24], "w_sniper_scout.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_sniper_scout");
	else if (strcmp(sWeaponModel[24], "w_sniper_awp.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_sniper_awp");

	// TIER 3 WEAPONS
	else if (strcmp(sWeaponModel[24], "w_grenade_launcher.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_grenade_launcher");
	else if (strcmp(sWeaponModel[24], "w_m60.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_rifle_m60");

	// GRENADES
	else if (strcmp(sWeaponModel[24], "w_eq_pipebomb.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_pipe_bomb");
	else if (strcmp(sWeaponModel[24], "w_eq_molotov.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_molotov");
	else if (strcmp(sWeaponModel[24], "w_eq_bile_flask.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_vomitjar");

	// MEDICAL ITEMS
	else if (strcmp(sWeaponModel[24], "w_eq_medkit.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_first_aid_kit");
	else if (strcmp(sWeaponModel[24], "w_eq_painpills.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_pain_pills");
	else if (strcmp(sWeaponModel[24], "w_eq_defibrillator.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_defibrillator");
	else if (strcmp(sWeaponModel[24], "w_eq_adrenaline.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_adrenaline");

	// UPGRADE PACKS
	else if (strcmp(sWeaponModel[24], "w_eq_incendiary_ammopack.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_upgradepack_incendiary");
	else if (strcmp(sWeaponModel[24], "w_eq_explosive_ammopack.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_upgradepack_explosive");

	// AMMO PILE
	else if (strcmp(sWeaponModel[20], "ammo_stack.mdl", false) == 0 || strcmp(sWeaponModel[36], "coffeeammo.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_ammo_spawn");
	
	// CARRIABLE PROPS
	else if (strcmp(sWeaponModel[18], "gascan001a.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_gascan");
	else if (strcmp(sWeaponModel[18], "propanecanister001a.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_propanetank");
	else if (strcmp(sWeaponModel[23], "oxygentank01.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_oxygentank");
	else if (strcmp(sWeaponModel[18], "gnome.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_gnome");
	else if (strcmp(sWeaponModel[24], "w_cola.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_cola_bottles");
	else if (strcmp(sWeaponModel[18], "explosive_box001.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_fireworkcrate");

	// MELEES
	else if (strcmp(sWeaponModel[21], "w_chainsaw.mdl", false) == 0)
		strcopy(sBuffer, iMaxLength, "weapon_chainsaw");
	else
	{
		for (int i = 0; i < sizeof(g_sMeleeWeaponMdls); i++)
		{
			if (strcmp(sWeaponModel, g_sMeleeWeaponMdls[i], false) == 0)
			{
				strcopy(sBuffer, iMaxLength, "weapon_melee");
				break;
			}
		}
	}

	if (sBuffer[0] == 0)
	{
		GetEntityClassname(iWeapon, sBuffer, iMaxLength);
		return false;
	}

	return true;
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

bool HadVisualContactWithEntity(int iClient, int iEntity, bool bFOVState = true, float fOverridePos[3] = NULL_VECTOR)
{
	CheckEntityForVisibility(iClient, iEntity, bFOVState, fOverridePos);
	int iState = (bFOVState ? g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] : g_iSurvivorBot_VisionMemory_State[iClient][iEntity]);
	return (iState == 2 || iState == 3);
}

stock float ClampFloat(float fValue, float fMin, float fMax)
{
	return (fValue > fMax) ? fMax : ((fValue < fMin) ? fMin : fValue);
}

int GetClosestInfected(int iClient, float fDistance = -1.0)
{
	int iCloseInfected = -1;
	float fInfectedDist, fLastDist = -1.0;

	bool bIsChasingSomething = false;
	int iThrownPipeBomb = (FindEntityByClassname(-1, "pipe_bomb_projectile"));
	bool bBileWasThrown = (FindEntityByClassname(-1, "info_goal_infected_chase") != -1);

	int iInfected = INVALID_ENT_REFERENCE;
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

	bool bIsAttacking = false;
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
	int iCount;

	float fClientPos[3];
	GetEntityCenteroid(iClient, fClientPos);

	float fInfectedPos[3];
	int i = INVALID_ENT_REFERENCE;
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
}

bool IsWeaponSlotActive(int iClient, int iSlot)
{
	return (GetClientWeaponInventory(iClient, iSlot) == L4D_GetPlayerCurrentWeapon(iClient));
}

bool SurvivorHasSMG(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1)return false;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	return (strcmp(sWepName[7], "smg") == 0 || strcmp(sWepName[11], "silenced") == 0 || strcmp(sWepName[7], "smg_mp5") == 0);
}

bool SurvivorHasAssaultRifle(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1)return false;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	return (strcmp(sWepName[7], "rifle") == 0 || strcmp(sWepName[7], "rifle_ak47") == 0 || strcmp(sWepName[7], "rifle_desert") == 0 || strcmp(sWepName[7], "rifle_sg552") == 0);
}

int SurvivorHasShotgun(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1)return 0;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	return ((strcmp(sWepName[7], "pumpshotgun") == 0 || strcmp(sWepName[7], "shotgun_chrome") == 0) ? 1 : ((strcmp(sWepName[7], "autoshotgun") == 0 || strcmp(sWepName[7], "shotgun_spas") == 0) ? 2 : 0));
}

int SurvivorHasSniperRifle(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1)return 0;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	return ((strcmp(sWepName[7], "hunting_rifle") == 0 || strcmp(sWepName[7], "sniper_military") == 0) ? 1 : ((strcmp(sWepName[7], "sniper_awp") == 0 || strcmp(sWepName[7], "sniper_scout") == 0) ? 2 : 0));
}

int SurvivorHasTier3Weapon(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1)return 0;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	return (strcmp(sWepName[7], "grenade_launcher") == 0 ? 1 : (strcmp(sWepName[7], "rifle_m60") == 0 ? 2 : 0));
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

int SurvivorHasHealthKit(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 3);
	if (iSlot == -1)return false;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	switch(sWepName[7])
	{
		case 'f': return 1;
		case 'd': return 2;
		case 'u': return 3;
		default: return 0;
	}
}

int SurvivorHasMeleeWeapon(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 1);
	if (iSlot == -1)return 0;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	return ((strcmp(sWepName[7], "melee") == 0) ? 1 : ((strcmp(sWepName[7], "chainsaw") == 0) ? 2 : 0));
}

int SurvivorHasPistol(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 1);
	if (iSlot == -1)return 0;

	static char sWepName[64];  GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	if (strcmp(sWepName[7], "pistol") == 0)
		return ((GetEntProp(iSlot, Prop_Send, "m_isDualWielding") != 0 || GetEntProp(iSlot, Prop_Send, "m_hasDualWeapons") != 0) ? 2 : 1);
	else if (strcmp(sWepName[7], "pistol_magnum") == 0)
		return 3;
	return 0;
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
	int iCount, iWeaponSlot;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))continue;

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

bool IsWeaponReloading(int iWeapon, bool bIgnoreShotguns = true)
{
	if (!IsEntityExists(iWeapon) || !HasEntProp(iWeapon, Prop_Data, "m_bInReload"))
		return false;

	bool bInReload = !!GetEntProp(iWeapon, Prop_Data, "m_bInReload");
	if (bInReload && bIgnoreShotguns)
	{
		static char sClassname[64]; GetEdictClassname(iWeapon, sClassname, sizeof(sClassname));
		return (strcmp(sClassname[7], "pumpshotgun") != 0 && strcmp(sClassname[7], "shotgun_chrome") != 0 && strcmp(sClassname[7], "autoshotgun") != 0 && strcmp(sClassname[7], "shotgun_spas") != 0);
	}
	return (bInReload);
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
	int iStartArea = g_iClientNavArea[iClient];
	if (!iStartArea)return -1.0;

	int iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, true, GetClientTeam(iClient));
	if (!iGoalArea)return -1.0;

	if (!L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), 0.0, GetClientTeam(iClient), false))
		return -1.0;

	int iArea = LBI_GetNavAreaParent(iGoalArea);
	if (!iArea)return GetVectorDistance(g_fClientAbsOrigin[iClient], fGoalPos, bSquared);

	float fClosePoint[3]; LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	float fDistance = GetVectorDistance(fClosePoint, fGoalPos, bSquared);

	float fParentCenter[3];
	for (; LBI_GetNavAreaParent(iArea); iArea = LBI_GetNavAreaParent(iArea))
	{
		LBI_GetClosestPointOnNavArea(LBI_GetNavAreaParent(iArea), fGoalPos, fParentCenter);
		LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
		fDistance += GetVectorDistance(fClosePoint, fParentCenter, bSquared);
	}

	LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	fDistance += GetVectorDistance(g_fClientAbsOrigin[iClient], fClosePoint, bSquared);
	
	return fDistance;
}

float GetEntityTravelDistance(int iClient, int iEntity, bool bSquared = false)
{
	int iStartArea, iTeam; float fEntityPos[3];
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
	if (!iStartArea)return -1.0;

	int iGoalArea; float fTargetPos[3];
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
	if (!iGoalArea)return -1.0;
	
	if (!L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), 0.0, iTeam, false))
		return -1.0;

	int iArea = LBI_GetNavAreaParent(iGoalArea);
	if (!iArea)return GetVectorDistance(g_fClientAbsOrigin[iClient], fEntityPos, bSquared);

	float fClosePoint[3]; LBI_GetClosestPointOnNavArea(iArea, fEntityPos, fClosePoint);
	float fDistance = GetVectorDistance(fClosePoint, fEntityPos, bSquared);

	float fParentCenter[3];
	for (; LBI_GetNavAreaParent(iArea); iArea = LBI_GetNavAreaParent(iArea))
	{
		LBI_GetClosestPointOnNavArea(LBI_GetNavAreaParent(iArea), fEntityPos, fParentCenter);
		LBI_GetClosestPointOnNavArea(iArea, fEntityPos, fClosePoint);
		fDistance += GetVectorDistance(fClosePoint, fParentCenter, bSquared);
	}

	LBI_GetClosestPointOnNavArea(iArea, fEntityPos, fClosePoint);
	fDistance += GetVectorDistance(g_fClientAbsOrigin[iClient], fClosePoint, bSquared);
	
	return fDistance;
}

float GetVectorTravelDistance(float fStartPos[3], float fGoalPos[3], bool bSquared = false, float fMaxLength = 2048.0, int iTeam = 2)
{
	int iStartArea = L4D_GetNearestNavArea(fStartPos, _, true, true, true, iTeam);
	if (!iStartArea)return -1.0;
	
	int iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, true, iTeam);
	if (!iGoalArea)return -1.0;

	if (!L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), fMaxLength, iTeam, false))
		return -1.0;

	int iArea = LBI_GetNavAreaParent(iGoalArea);
	if (!iArea)return GetVectorDistance(fStartPos, fGoalPos, bSquared);

	float fClosePoint[3]; LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	float fDistance = GetVectorDistance(fClosePoint, fGoalPos, bSquared);

	float fParentCenter[3];
	for (; LBI_GetNavAreaParent(iArea); iArea = LBI_GetNavAreaParent(iArea))
	{
		LBI_GetClosestPointOnNavArea(LBI_GetNavAreaParent(iArea), fGoalPos, fParentCenter);
		LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
		fDistance += GetVectorDistance(fClosePoint, fParentCenter, bSquared);
	}

	LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	fDistance += GetVectorDistance(fStartPos, fClosePoint, bSquared);
	
	return fDistance;
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

bool LBI_IsReachablePosition(int iClient, const float fPos[3])
{
	int iNearArea = L4D_GetNearestNavArea(fPos, 200.0, true, true, false, 0);
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

	/* Breaks the map scripts (might make it work only in non-coop maps only...)
	float fNWCorner[3], fSECorner[3];
	LBI_GetNavAreaCorners(iNavArea, fNWCorner, fSECorner);
	if ((fSECorner[0] - fNWCorner[0]) > 100.0 || (fSECorner[1] - fNWCorner[1]) > 100.0)
	{
		SDKCall(g_hSubdivideNavArea, L4D_GetPointer(POINTER_NAVMESH), iNavArea, true, true, 1);
	}
	*/

	return MRES_Ignored;
}

MRESReturn DTR_OnFindUseEntity(int iClient, Handle hReturn, Handle hParams)
{
	if (!IsValidClient(iClient) || !IsFakeClient(iClient))
		return MRES_Ignored;

	int iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	if (!IsEntityExists(iScavengeItem))return MRES_Ignored;

	DHookSetReturn(hReturn, iScavengeItem);
	return MRES_ChangedOverride;
}

int LBI_IsPathToPositionDangerous(int iClient, float fGoalPos[3])
{
	if (L4D2_IsTankInPlay())
	{
		ArrayList hTankList = new ArrayList();
		float fGoalOffset[3]; fGoalOffset = fGoalPos; fGoalOffset[2] += HUMAN_HALF_HEIGHT;

		float fTankDist, fGoalDist;
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

		int iClientArea = g_iClientNavArea[iClient];
		if (!iClientArea)
		{
			delete hTankList;
			return -1;
		}

		int iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, true);
		if (!iGoalArea)
		{
			delete hTankList;
			return -1;
		}

		if (!L4D2_NavAreaBuildPath(view_as<Address>(iClientArea), view_as<Address>(iGoalArea), 0.0, 2, false))
		{
			delete hTankList;
			return -1;
		}

		int iParent = LBI_GetNavAreaParent(iGoalArea);
		if (iParent)
		{
			int iTank; float fAreaPos[3];
			for (; LBI_GetNavAreaParent(iParent); iParent = LBI_GetNavAreaParent(iParent))
			{
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
			}
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
