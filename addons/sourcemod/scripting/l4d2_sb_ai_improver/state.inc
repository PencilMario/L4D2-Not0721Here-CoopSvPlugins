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
#define VISIBILITY_CACHE_POSITION_TOLERANCE_SQR 1024.0
#define VISIBILITY_CACHE_SIZE 64
#define VISIBILITY_CACHE_WAYS 4
#define VISIBILITY_CACHE_SET_COUNT 16
#define TRACE_ENTITY_UNKNOWN 0
#define TRACE_ENTITY_DOOR 1
#define TRACE_ENTITY_OTHER 2
#define VECTOR_TRACE_CACHE_SIZE 64
#define VECTOR_TRACE_CACHE_WAYS 4
#define VECTOR_TRACE_CACHE_SET_COUNT 16
#define VECTOR_TRACE_CACHE_QUANTIZATION 8.0
#define VECTOR_TRACE_CACHE_POSITION_TOLERANCE_SQR 64.0
#define AIM_TRACE_CACHE_POSITION_TOLERANCE_SQR 0.01

#define HUMAN_HEIGHT				71.0
#define HUMAN_HALF_HEIGHT			35.5

#define DEBUG_NONE		0
#define DEBUG_NAV		1 << 0
#define DEBUG_MOVE		1 << 1
#define DEBUG_SCAVENGE	1 << 2
#define DEBUG_MISC		1 << 3
//#define DEBUG_HUD		1 << 4
#define DEBUG_WEP_DATA	1 << 5

#define HUD_FLAG_ALIGN_LEFT	256
#define HUD_FLAG_TEXT		8192
#define HUD_FLAG_NOTVISIBLE	16384

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

char IBWeaponName[56][32];

char IBVScriptCommands[][] =
{
	"MOVE",
	"USE"
};

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
ConVar g_hCvar_GameDifficulty;
ConVar g_hCvar_SurvivorLimpHealth;
ConVar g_hCvar_TankRockHealth;
ConVar g_hCvar_GasCanUseDuration;
ConVar g_hCvar_ChaseBileRange;
ConVar g_hCvar_ServerGravity;
ConVar g_hCvar_BileCoverDuration_Bot;
ConVar g_hCvar_BileCoverDuration_PZ;

ConVar g_hCvar_MaxMeleeSurvivors;
ConVar g_hCvar_BotsShootThrough;
ConVar g_hCvar_BotsFriendlyFire;
ConVar g_hCvar_BotsDisabled;
ConVar g_hCvar_BotsDontShoot;
ConVar g_hCvar_BotsVomitBlindTime;

char g_sCvar_GameDifficulty[12];
int g_iCvar_SurvivorLimpHealth;
int g_iCvar_TankRockHealth;
float g_fCvar_GasCanUseDuration;
float g_fCvar_ChaseBileRange;
float g_fCvar_ServerGravity;
float g_fCvar_BileCoverDuration_Bot;
float g_fCvar_BileCoverDuration_PZ;

int g_iCvar_MaxMeleeSurvivors;
bool g_bCvar_BotsShootThrough;
bool g_bCvar_BotsFriendlyFire;
bool g_bCvar_BotsDisabled;
bool g_bCvar_BotsDontShoot;
float g_fCvar_BotsVomitBlindTime;

/*============ AMMO RELATED CONVARS =================================================================*/
ConVar g_hCvar_MaxAmmo_Pistol;
ConVar g_hCvar_MaxAmmo_AssaultRifle;
ConVar g_hCvar_MaxAmmo_SMG;
ConVar g_hCvar_MaxAmmo_M60;
ConVar g_hCvar_MaxAmmo_Shotgun;
ConVar g_hCvar_MaxAmmo_AutoShotgun;
ConVar g_hCvar_MaxAmmo_HuntRifle;
ConVar g_hCvar_MaxAmmo_SniperRifle;
ConVar g_hCvar_MaxAmmo_PipeBomb;
ConVar g_hCvar_MaxAmmo_Molotov;
ConVar g_hCvar_MaxAmmo_VomitJar;
ConVar g_hCvar_MaxAmmo_PainPills;
ConVar g_hCvar_MaxAmmo_GrenLauncher;
ConVar g_hCvar_MaxAmmo_Adrenaline;
ConVar g_hCvar_MaxAmmo_Chainsaw;
ConVar g_hCvar_MaxAmmo_AmmoPack;
ConVar g_hCvar_MaxAmmo_Medkit;
ConVar g_hCvar_Ammo_Type_Override;

int g_iCvar_MaxAmmo_Pistol;
int g_iCvar_MaxAmmo_AssaultRifle;
int g_iCvar_MaxAmmo_SMG;
int g_iCvar_MaxAmmo_M60;
int g_iCvar_MaxAmmo_Shotgun;
int g_iCvar_MaxAmmo_AutoShotgun;
int g_iCvar_MaxAmmo_HuntRifle;
int g_iCvar_MaxAmmo_SniperRifle;
int g_iCvar_MaxAmmo_PipeBomb;
int g_iCvar_MaxAmmo_Molotov;
int g_iCvar_MaxAmmo_VomitJar;
int g_iCvar_MaxAmmo_PainPills;
int g_iCvar_MaxAmmo_GrenLauncher;
int g_iCvar_MaxAmmo_Adrenaline;
int g_iCvar_MaxAmmo_Chainsaw;
int g_iCvar_MaxAmmo_AmmoPack;
int g_iCvar_MaxAmmo_Medkit;
char g_sCvar_Ammo_Type_Override[32];

/*============ MELEE RELATED CONVARS =================================================================*/
ConVar g_hCvar_ImprovedMelee_MaxCount;

ConVar g_hCvar_ImprovedMelee_Enabled;
ConVar g_hCvar_ImprovedMelee_SwitchCount;
ConVar g_hCvar_ImprovedMelee_SwitchRange;
ConVar g_hCvar_ImprovedMelee_ApproachRange;
ConVar g_hCvar_ImprovedMelee_AimRange;
ConVar g_hCvar_ImprovedMelee_AttackRange;
ConVar g_hCvar_ImprovedMelee_ShoveChance;

bool g_bCvar_ImprovedMelee_Enabled;
int g_iCvar_ImprovedMelee_SwitchCount;
int g_iCvar_ImprovedMelee_ShoveChance;
float g_fCvar_ImprovedMelee_SwitchRange;
float g_fCvar_ImprovedMelee_ApproachRange;
float g_fCvar_ImprovedMelee_AimRange_Sqr;
float g_fCvar_ImprovedMelee_AttackRange;
float g_fCvar_ImprovedMelee_AttackRange_Sqr;

ConVar g_hCvar_ImprovedMelee_ChainsawLimit;
ConVar g_hCvar_ImprovedMelee_SwitchCount2;

int g_iCvar_ImprovedMelee_ChainsawLimit;
int g_iCvar_ImprovedMelee_SwitchCount2;
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
ConVar g_hCvar_Vision_FieldOfView;
float g_fCvar_Vision_FieldOfView;

ConVar g_hCvar_Vision_NoticeTimeScale;
float g_fCvar_Vision_NoticeTimeScale;

/*============ TANK RELATED CONVARS ==================================================================*/
ConVar g_hCvar_TankRock_ShootEnabled;
ConVar g_hCvar_TankRock_ShootRange;
bool g_bCvar_TankRock_ShootEnabled;
float g_fCvar_TankRock_ShootRange;
/*============ SAVE RELATED CONVARS ==================================================================*/
ConVar g_hCvar_AutoShove_Enabled;
int g_iCvar_AutoShove_Enabled;
/*----------------------------------------------------------------------------------------------------*/
ConVar g_hCvar_FireBash_Chance1;
ConVar g_hCvar_FireBash_Chance2;
int g_iCvar_FireBash_Chance1;
int g_iCvar_FireBash_Chance2;
/*----------------------------------------------------------------------------------------------------*/
ConVar g_hCvar_HelpPinnedFriend_Enabled;
ConVar g_hCvar_HelpPinnedFriend_ShootRange;
ConVar g_hCvar_HelpPinnedFriend_ShoveRange;
ConVar g_hCvar_HelpPinnedFriend_ReactionBots;
ConVar g_hCvar_HelpPinnedFriend_ReactionInterval;
ConVar g_hCvar_HelpPinnedFriend_MaxDistance;
int g_iCvar_HelpPinnedFriend_Enabled;
int g_iCvar_HelpPinnedFriend_ReactionBots;
float g_fCvar_HelpPinnedFriend_ReactionInterval;
float g_fCvar_HelpPinnedFriend_MaxDistance_Sqr;
//static float g_fCvar_HelpPinnedFriend_ShootRange;
float g_fCvar_HelpPinnedFriend_ShootRange_Sqr;
float g_fCvar_HelpPinnedFriend_ShoveRange_Sqr;
/*============ WEAPON RELATED CONVARS ================================================================*/
ConVar g_hCvar_BotWeaponPreference_ForceMagnum;
bool g_bCvar_BotWeaponPreference_ForceMagnum;

ConVar g_hCvar_BotWeaponPreference_Rochelle;
ConVar g_hCvar_BotWeaponPreference_Zoey;
ConVar g_hCvar_BotWeaponPreference_Ellis;
ConVar g_hCvar_BotWeaponPreference_Coach;
ConVar g_hCvar_BotWeaponPreference_Francis;
ConVar g_hCvar_BotWeaponPreference_Nick;
ConVar g_hCvar_BotWeaponPreference_Louis;
ConVar g_hCvar_BotWeaponPreference_Bill;

int g_iCvar_BotWeaponPreference_Rochelle;
int g_iCvar_BotWeaponPreference_Zoey;
int g_iCvar_BotWeaponPreference_Ellis;
int g_iCvar_BotWeaponPreference_Coach;
int g_iCvar_BotWeaponPreference_Francis;
int g_iCvar_BotWeaponPreference_Nick;
int g_iCvar_BotWeaponPreference_Louis;
int g_iCvar_BotWeaponPreference_Bill;
/*----------------------------------------------------------------------------------------------------*/
ConVar g_hCvar_SwapSameTypePrimaries;
bool g_bCvar_SwapSameTypePrimaries;
/*------------ TIER 3 --------------------------------------------------------------------------------*/
ConVar g_hCvar_MaxWeaponTier3_M60;
ConVar g_hCvar_MaxWeaponTier3_GLauncher;
ConVar g_hCvar_T3_Refill;

int g_iCvar_MaxWeaponTier3_M60;
int g_iCvar_MaxWeaponTier3_GLauncher;
int g_iCvar_T3_Refill;

/*============ GRENADE RELATED CONVARS ===============================================================*/
ConVar g_hCvar_GrenadeThrow_Enabled;
ConVar g_hCvar_GrenadeThrow_GrenadeTypes;
ConVar g_hCvar_GrenadeThrow_ThrowRange;
ConVar g_hCvar_GrenadeThrow_HordeSize;
ConVar g_hCvar_GrenadeThrow_NextThrowTime1;
ConVar g_hCvar_GrenadeThrow_NextThrowTime2;
/*----------------------------------------------------------------------------------------------------*/
bool g_bCvar_GrenadeThrow_Enabled;
int g_iCvar_GrenadeThrow_GrenadeTypes;
float g_fCvar_GrenadeThrow_ThrowRange;
float g_fCvar_GrenadeThrow_HordeSize;
float g_fCvar_GrenadeThrow_NextThrowTime1;
float g_fCvar_GrenadeThrow_NextThrowTime2;
/*----------------------------------------------------------------------------------------------------*/
ConVar g_hCvar_SwapSameTypeGrenades;
bool g_bCvar_SwapSameTypeGrenades;

/*============ DEFIB RELATED CONVARS =================================================================*/
ConVar g_hCvar_DefibRevive_Enabled;
ConVar g_hCvar_DefibRevive_ScanDist;

bool g_bCvar_DefibRevive_Enabled;
float g_fCvar_DefibRevive_ScanDist;

/*============ ITEM SCAVENGE RELATED CONVARS =========================================================*/
ConVar g_hCvar_ItemScavenge_Models;
ConVar g_hCvar_ItemScavenge_Items;
ConVar g_hCvar_ItemScavenge_ApproachRange;
ConVar g_hCvar_ItemScavenge_ApproachVisibleRange;
ConVar g_hCvar_ItemScavenge_PickupRange;
ConVar g_hCvar_ItemScavenge_MapSearchRange;
ConVar g_hCvar_ItemScavenge_NoHumansRangeMultiplier;

int g_iCvar_ItemScavenge_Models;
int g_iCvar_ItemScavenge_Items;
float g_fCvar_ItemScavenge_ApproachRange;
float g_fCvar_ItemScavenge_ApproachVisibleRange;
float g_fCvar_ItemScavenge_PickupRange;
float g_fCvar_ItemScavenge_PickupRange_Sqr;
float g_fCvar_ItemScavenge_MapSearchRange_Sqr;
float g_fCvar_ItemScavenge_NoHumansRangeMultiplier;

/*============ WITCH RELATED CONVARS =========================================================*/
ConVar g_hCvar_WitchBehavior_WalkWhenNearby;
ConVar g_hCvar_WitchBehavior_AllowCrowning;

float g_fCvar_WitchBehavior_WalkWhenNearby;
int g_iCvar_WitchBehavior_AllowCrowning;

/*============ PERFOMANCE RELATED CONVARS =========================================================*/
ConVar g_hCvar_NextProcessTime;
float g_fCvar_NextProcessTime;

ConVar g_hCvar_DegradedForce;
ConVar g_hCvar_DegradedFrameStepMs;
int g_iCvar_DegradedForce;
float g_fCvar_DegradedFrameStepMs;
float g_fDegradedFrameAverageMs;
float g_fDegradedLastSampleTime;
int g_iDegradedLoadLevel;

ConVar g_hCvar_PerformanceLogging;
ConVar g_hCvar_PerformanceThresholdMs;
bool g_bCvar_PerformanceLogging;
float g_fCvar_PerformanceThresholdMs;
Logger g_hPerformanceLogger;

bool g_bPerformanceBudgetEnabled;
int g_iPerformanceBudget_RunCmdCalls;
int g_iPerformanceBudget_EnteredBotThink;
int g_iPerformanceBudget_StageDepth;
float g_fPerformanceBudget_StageStartedAt[8];
char g_sPerformanceBudget_Stage[8][32];

enum TraceMetricCategory
{
	TRACE_METRIC_NONE = -1,
	TRACE_METRIC_ENTITY_LOS,
	TRACE_METRIC_VECTOR_LOS,
	TRACE_METRIC_AIM,
	TRACE_METRIC_GRENADE_GROUND,
	TRACE_METRIC_GRENADE_CEILING,
	TRACE_METRIC_NAV_VISIBLE,
	TRACE_METRIC_COUNT
}

char g_sTraceMetricCategoryNames[TRACE_METRIC_COUNT][] =
{
	"entity_los",
	"vector_los",
	"aim",
	"grenade_ground",
	"grenade_ceiling",
	"nav_visible"
};

int g_iTraceMetrics_Attempts[TRACE_METRIC_COUNT];
int g_iTraceMetrics_CacheHits[TRACE_METRIC_COUNT];
int g_iTraceMetrics_CacheMisses[TRACE_METRIC_COUNT];
int g_iTraceMetrics_TraceCalls[TRACE_METRIC_COUNT];
int g_iTraceMetrics_Fallback2[TRACE_METRIC_COUNT];
int g_iTraceMetrics_Fallback3[TRACE_METRIC_COUNT];
int g_iTraceMetrics_FilterCallbacks[TRACE_METRIC_COUNT];
int g_iTraceMetrics_ActiveCategory = TRACE_METRIC_NONE;
float g_fTraceMetrics_NextSummaryExpiry;

float GetProcessCacheExpiry()
{
	return (GetGameTime() + g_fCvar_NextProcessTime);
}

/*============ MISC CONVARS =========================================================*/
ConVar g_hCvar_AlwaysCarryProp;
ConVar g_hCvar_SpitterAcidEvasion;
ConVar g_hCvar_SwitchOffCSSWeapons;
ConVar g_hCvar_KeepMovingInCombat;
ConVar g_hCvar_ChargerEvasion;
ConVar g_hCvar_DeployUpgradePacks;
ConVar g_hCvar_DontSwitchToPistol;
ConVar g_hCvar_TakeCoverFromRocks;
ConVar g_hCvar_AvoidTanksWithProp;
ConVar g_hCvar_NoFallDmgOnLadderFail;

bool g_bCvar_SpitterAcidEvasion;
bool g_bCvar_AlwaysCarryProp;
bool g_bCvar_SwitchOffCSSWeapons;
bool g_bCvar_ChargerEvasion;
bool g_bCvar_DeployUpgradePacks;
bool g_bCvar_DontSwitchToPistol;
bool g_bCvar_TakeCoverFromRocks;
bool g_bCvar_AvoidTanksWithProp;
bool g_bCvar_NoFallDmgOnLadderFail;

/*============ VARIABLES =========================================================*/
float g_fSurvivorBot_NextPressAttackTime[MAXPLAYERS+1];

int g_iSurvivorBot_TargetInfected[MAXPLAYERS+1];
int g_iSurvivorBot_IncapacitatedFriend[MAXPLAYERS+1];
int g_iSurvivorBot_PinnedFriend[MAXPLAYERS+1];

int g_iSurvivorBot_WitchTarget[MAXPLAYERS+1];
bool g_bSurvivorBot_IsWitchHarasser[MAXPLAYERS+1];

bool g_bSurvivorBot_PreventFire[MAXPLAYERS+1];

bool g_bClient_IsLookingAtPosition[MAXPLAYERS+1];
bool g_bClient_IsFiringWeapon[MAXPLAYERS+1];

int g_iSurvivorBot_ScavengeItem[MAXPLAYERS+1];
float g_fSurvivorBot_ScavengeItemDist[MAXPLAYERS+1];
float g_fSurvivorBot_NextUsePressTime[MAXPLAYERS+1];
float g_fSurvivorBot_NextScavengeItemScanTime[MAXPLAYERS+1];

float g_fSurvivorBot_VomitBlindedTime[MAXPLAYERS+1];

float g_fSurvivorBot_NextMoveCommandTime[MAXPLAYERS+1];
bool g_bSurvivorBot_TankRetreatActive[MAXPLAYERS+1];

float g_fSurvivorBot_BlockWeaponSwitchTime[MAXPLAYERS+1];
float g_fSurvivorBot_BlockWeaponReloadTime[MAXPLAYERS+1];

float g_fSurvivorBot_MeleeApproachTime[MAXPLAYERS+1];
float g_fSurvivorBot_MeleeAttackTime[MAXPLAYERS+1];

float g_fSurvivorBot_TimeSinceLeftLadder[MAXPLAYERS+1];

int g_iSurvivorBot_DefibTarget[MAXPLAYERS+1];

int g_iSurvivorBot_Grenade_ThrowTarget[MAXPLAYERS+1];
float g_fSurvivorBot_Grenade_ThrowPos[MAXPLAYERS+1][3];
float g_fSurvivorBot_Grenade_AimPos[MAXPLAYERS+1][3];

float g_fSurvivorBot_Grenade_NextThrowTime;
float g_fSurvivorBot_Grenade_NextThrowTime_Molotov;

float g_fSurvivorBot_LookPosition[MAXPLAYERS+1][3];
float g_fSurvivorBot_LookPosition_Duration[MAXPLAYERS+1];

float g_fSurvivorBot_MovePos_Position[MAXPLAYERS+1][3];
float g_fSurvivorBot_MovePos_Duration[MAXPLAYERS+1];
int g_iSurvivorBot_MovePos_Priority[MAXPLAYERS+1];
float g_fSurvivorBot_MovePos_Tolerance[MAXPLAYERS+1];
bool g_bSurvivorBot_MovePos_IgnoreDamaging[MAXPLAYERS+1];
char g_sSurvivorBot_MovePos_Name[MAXPLAYERS+1][64];

bool g_bSurvivorBot_ForceSwitchWeapon[MAXPLAYERS+1];
bool g_bSurvivorBot_ForceBash[MAXPLAYERS+1];

float g_fSurvivorBot_PinnedReactTime[MAXPLAYERS+1];
float g_fSurvivorBot_NextPinnedRescueThinkTime[MAXPLAYERS+1];

int g_iSurvivorBot_NearbyInfectedCount[MAXPLAYERS+1];
int g_iSurvivorBot_NearestInfectedCount[MAXPLAYERS+1];
int g_iSurvivorBot_ThreatInfectedCount[MAXPLAYERS+1];
int g_iSurvivorBot_GrenadeInfectedCount[MAXPLAYERS+1];

int g_iSurvivorBot_VisionMemory_State[MAXPLAYERS+1][MAXENTITIES+1];
int g_iSurvivorBot_VisionMemory_State_FOV[MAXPLAYERS+1][MAXENTITIES+1];

float g_fSurvivorBot_VisionMemory_Time[MAXPLAYERS+1][MAXENTITIES+1];
float g_fSurvivorBot_VisionMemory_Time_FOV[MAXPLAYERS+1][MAXENTITIES+1];

float g_fSurvivorBot_VisibilityCache_Expiry[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE];
int g_iSurvivorBot_VisibilityCache_EntRef[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE];
int g_iSurvivorBot_VisibilityCache_Mask[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE];
int g_iSurvivorBot_VisibilityCache_Mode[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE];
int g_iSurvivorBot_VisibilityCache_ObserverGeneration[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE];
bool g_bSurvivorBot_VisibilityCache_Result[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE];
float g_fSurvivorBot_VisibilityCache_EyePos[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE][3];
float g_fSurvivorBot_VisibilityCache_TargetPos[MAXPLAYERS+1][VISIBILITY_CACHE_SIZE][3];
int g_iSurvivorBot_VisibilityObserverGeneration[MAXPLAYERS+1];

float g_fVectorTraceCache_Expiry[VECTOR_TRACE_CACHE_SIZE];
float g_fVectorTraceCache_LastQueryTime;
int g_iVectorTraceCache_Hash[VECTOR_TRACE_CACHE_SIZE];
int g_iVectorTraceCache_Mask[VECTOR_TRACE_CACHE_SIZE];
int g_iVectorTraceCache_RayType[VECTOR_TRACE_CACHE_SIZE];
bool g_bVectorTraceCache_Result[VECTOR_TRACE_CACHE_SIZE];
float g_fVectorTraceCache_Start[VECTOR_TRACE_CACHE_SIZE][3];
float g_fVectorTraceCache_End[VECTOR_TRACE_CACHE_SIZE][3];

int g_iClientCommandGeneration[MAXPLAYERS+1];
int g_iClientAimCacheGeneration[MAXPLAYERS+1];
bool g_bClientAimCacheValid[MAXPLAYERS+1];
float g_fClientAimCacheEyePos[MAXPLAYERS+1][3];
float g_fClientAimCacheAngles[MAXPLAYERS+1][3];
float g_fClientAimCachePos[MAXPLAYERS+1][3];

float g_fSurvivorBot_NextWeaponRangeSwitchTime[MAXPLAYERS+1];

bool g_bSurvivorBot_ForceWeaponReload[MAXPLAYERS+1];

int g_iSurvivorBot_NearbyFriends[MAXPLAYERS+1];

int g_iBotProcessing_ProcessedCount;
bool g_bBotProcessing_IsProcessed[MAXPLAYERS+1];
float g_fBotProcessing_NextProcessTime;

int g_iInfectedBot_CurrentVictim[MAXPLAYERS+1];
bool g_bInfectedBot_IsThrowing[MAXPLAYERS+1];
float g_fInfectedBot_CoveredInVomitTime[MAXPLAYERS+1];

bool g_bMapStarted;
bool g_bCutsceneIsPlaying;
char g_sCurrentMapName[128];

// ----------------------------------------------------------------------------------------------------
// DEBUG / TESTING
// ----------------------------------------------------------------------------------------------------
ConVar g_hCvar_Debug;
int g_iCvar_Debug;
int g_iCvar_DebugClient;

//static int g_iTester;
//static int g_iTeamLeader;
//static int g_iTimesPostponed;
//static int g_iTestSubject;

//static Handle g_hDebugHUDTimer;


// ----------------------------------------------------------------------------------------------------
// CLIENT GLOBAL DATA
// ----------------------------------------------------------------------------------------------------
float g_fClientEyePos[MAXPLAYERS+1][3];
float g_fClientEyeAng[MAXPLAYERS+1][3];
float g_fClientAbsOrigin[MAXPLAYERS+1][3];
float g_fClientCenteroid[MAXPLAYERS+1][3];
float g_fClientGlobalInfo_Expiry[MAXPLAYERS+1];
bool g_bClientGlobalInfo_Ready[MAXPLAYERS+1];
int g_iClientNavArea[MAXPLAYERS+1];
float g_fClientNavAreaCache_Expiry[MAXPLAYERS+1];
float g_fClientNavAreaCache_Position[MAXPLAYERS+1][3];
int g_iClientInventory[MAXPLAYERS+1][6];
int g_iClientInvFlags[MAXPLAYERS+1];
float g_fClientInventory_Expiry[MAXPLAYERS+1];
//static int g_iClientState[MAXPLAYERS+1];

// ----------------------------------------------------------------------------------------------------
// WEAPON GLOBAL DATA
// ----------------------------------------------------------------------------------------------------
bool g_bInitCheckCases;
bool g_bInitItemFlags;
bool g_bInitMaxAmmo;
bool g_bInitWeaponMap;
bool g_bInitMeleeIDs;
bool g_bInitMeleePrefs;

bool g_bIsSemiAuto[56];
int g_iWeaponID[MAXENTITIES+1];
int g_iMeleeID[MAXENTITIES+1];
int g_iMeleePreference[17];
int g_iItemFlags[MAXENTITIES+1];
int g_iMaxAmmo[56];
int g_iWeaponTier[56];
int g_iWeapon_Clip1[MAXENTITIES+1];
int g_iWeapon_MaxAmmo[MAXENTITIES+1];
int g_iWeapon_AmmoLeft[MAXENTITIES+1];
int g_iItem_Used[MAXENTITIES+1]; // To fix bots grabbing same ammo upgrade repeatedly

Handle g_hCheckWeaponTimer;

// ----------------------------------------------------------------------------------------------------
// LOOKUP HASH MAPS
// ----------------------------------------------------------------------------------------------------
StringMap g_hItemFlagMap;
StringMap g_hWeaponMap;
StringMap g_hWeaponMdlMap;
StringMap g_hWeaponToIDMap;
StringMap g_hCheckCases;
StringMap g_hMeleeIDs;
StringMap g_hMeleeMdlToID;
StringMap g_hMeleePref;

// ----------------------------------------------------------------------------------------------------
// DATA FILES
// ----------------------------------------------------------------------------------------------------
int g_iDataFileSection;
int g_iDataFileValueID;

// ----------------------------------------------------------------------------------------------------
// VSCRIPT
// ----------------------------------------------------------------------------------------------------
VScriptFunction g_vsCommand;
VScriptExecute g_vsPathWithin;
bool g_bInitPathWithin;

// ----------------------------------------------------------------------------------------------------
// ENTITY ARRAYLISTS
// ----------------------------------------------------------------------------------------------------
ArrayList g_hMeleeList;
ArrayList g_hPistolList;
ArrayList g_hSMGList;
ArrayList g_hShotgunT1List;
ArrayList g_hShotgunT2List;
ArrayList g_hAssaultRifleList;
ArrayList g_hSniperRifleList;
ArrayList g_hTier3List;
ArrayList g_hGrenadeList;
ArrayList g_hFirstAidKitList;
ArrayList g_hDefibrillatorList;
ArrayList g_hUpgradePackList;
ArrayList g_hPainPillsList;
ArrayList g_hAdrenalineList;

ArrayList g_hAmmopileList;
ArrayList g_hLaserSightList;
ArrayList g_hDeployedAmmoPacks;
ArrayList g_hForbiddenItemList;
ArrayList g_hWeaponsToCheckLater;

ArrayList g_hWitchList;

// ----------------------------------------------------------------------------------------------------
// PREVENT REPEATED UNSUCCESSFUL PATH DISTANCE CALCULATION
// ----------------------------------------------------------------------------------------------------
ArrayList g_hBadPathEntities;
Handle g_hClearBadPathTimer;

// Bitmask of the registered entity lists; used to avoid probing every list on destroy.
int g_iEntityListMask[MAXENTITIES + 1];
int g_iEntityListEntRef[MAXENTITIES + 1];
int g_iTraceEntityClass[MAXENTITIES + 1];
int g_iTraceEntityEntRef[MAXENTITIES + 1];
int g_iTraceDoorState[MAXENTITIES + 1];
float g_fTraceDoorStateExpiry[MAXENTITIES + 1];

// ----------------------------------------------------------------------------------------------------
// SHARED PERFORMANCE SNAPSHOTS
// ----------------------------------------------------------------------------------------------------
float g_fTakeCoverCache_Expiry[MAXPLAYERS+1];
float g_fTakeCoverCache_ClientPos[MAXPLAYERS+1][3];
float g_fTakeCoverCache_SourcePos[MAXPLAYERS+1][3];
float g_fTakeCoverCache_ResultPos[MAXPLAYERS+1][3];
float g_fTakeCoverCache_SearchDist[MAXPLAYERS+1];
bool g_bTakeCoverCache_Result[MAXPLAYERS+1];

float g_fSurvivorBot_AcidEscapeCache_Expiry[MAXPLAYERS+1];
int g_iSurvivorBot_AcidEscapeCache_Inflictor[MAXPLAYERS+1];
float g_fSurvivorBot_AcidEscapeCache_ClientPos[MAXPLAYERS+1][3];
float g_fSurvivorBot_AcidEscapeCache_ResultPos[MAXPLAYERS+1][3];
bool g_bSurvivorBot_AcidEscapeCache_Result[MAXPLAYERS+1];

float g_fPinnedReactionCache_Expiry[MAXPLAYERS+1];
float g_fPinnedReactionCache_Position[MAXPLAYERS+1][3];
int g_iPinnedReactionRank[MAXPLAYERS+1][MAXPLAYERS+1];
int g_iPinnedRescueAttacker[MAXPLAYERS+1];
L4D2ZombieClassType g_iPinnedRescueClass[MAXPLAYERS+1];
bool g_bPinnedRescueActive[MAXPLAYERS+1];
int g_iSurvivorBot_RescueVictim[MAXPLAYERS+1];
int g_iSurvivorBot_RescueAttacker[MAXPLAYERS+1];
bool g_bPinnedRescueRecoveryPending;

int g_iCommonInfectedMeleeTargetMask[MAXENTITIES+1];

// Only populated while an AI degradation level is active.  Position data is
// shared by all survivor bots for one ib_process_time window.
float g_fAiEntityCenteroidCache_Expiry[MAXENTITIES+1];
int g_iAiEntityCenteroidCache_EntRef[MAXENTITIES+1];
float g_fAiEntityCenteroidCache_Position[MAXENTITIES+1][3];

// ----------------------------------------------------------------------------------------------------
// CHARACTER MODEL BONES
// ----------------------------------------------------------------------------------------------------
char g_sBoneNames_Old[][] =
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
char g_sBoneNames_New[][] =
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

bool g_bLateLoad;
bool g_bExtensionActions;
