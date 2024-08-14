#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1

#define L4D2 Noxious Smoker
#define PLUGIN_VERSION "1.2"

#define STRING_LENGHT								56
#define ZOMBIECLASS_SMOKER 							1
#define DEBUG 										0

char GAMEDATA_FILENAME[] 			= "l4d2_viciousplugins";
static const Float:SLAP_VERTICAL_MULTIPLIER			= 1.5;
static const Float:TRACE_TOLERANCE 					= 25.0;
int MODEL_DEFIB;

char WeaponNames[][] =
{
	//0-16
	"weapon_pumpshotgun", "weapon_autoshotgun", "weapon_rifle", "weapon_smg", "weapon_hunting_rifle", "weapon_sniper_scout", "weapon_sniper_military", "weapon_sniper_awp", "weapon_smg_silenced",
	"weapon_smg_mp5", "weapon_shotgun_spas", "weapon_shotgun_chrome", "weapon_rifle_sg552", "weapon_rifle_desert", "weapon_rifle_ak47", "weapon_grenade_launcher", "weapon_rifle_m60", 
	//17-20
	"weapon_pistol", "weapon_pistol_magnum", "weapon_chainsaw", 	"weapon_melee", 
	//21-23 
	"weapon_pipe_bomb", "weapon_molotov", "weapon_vomitjar", 
	//24-27
	"weapon_first_aid_kit", "weapon_defibrillator", "weapon_upgradepack_explosive", 	"weapon_upgradepack_incendiary", 
	//28-29
	"weapon_pain_pills", "weapon_adrenaline", 
	//30-35
	"weapon_gascan", "weapon_propanetank", "weapon_oxygentank", "weapon_gnome", "weapon_cola_bottles", "weapon_fireworkcrate" 
};

// ===========================================
// Smoker Setup
// ===========================================

// =================================
// Asphyxiation
// =================================

//Handles
new Handle:cvarAsphyxiation;
new Handle:cvarAsphyxiationDamage;
new Handle:cvarAsphyxiationFrequency;
new Handle:cvarAsphyxiationRange;
new Handle:cvarAsphyxiationTimer[MAXPLAYERS+1] = INVALID_HANDLE;
Handle ConfigFile;

//Bools
new bool:isAsphyxiation = false;

// =================================
// Collapsed Lung
// =================================

//Handles
new Handle:cvarCollapsedLung;
new Handle:cvarCollapsedLungChance;
new Handle:cvarCollapsedLungDamage;
new Handle:cvarCollapsedLungDuration;
new Handle:cvarCollapsedLungTimer[MAXPLAYERS + 1] = INVALID_HANDLE;

//Bools
new bool:isCollapsedLung = false;

//Strings
new collapsedlung[MAXPLAYERS+1];

// =================================
// Methane Blast
// =================================

//Handles
new Handle:cvarMethaneBlast;
new Handle:cvarMethaneBlastInnerPower;
new Handle:cvarMethaneBlastOuterPower;
new Handle:cvarMethaneBlastInnerDamage;
new Handle:cvarMethaneBlastOuterDamage;
new Handle:cvarMethaneBlastInnerRange;
new Handle:cvarMethaneBlastOuterRange;

//Bools
new bool:isMethaneBlast = false;

// =================================
// Methane Leak
// =================================

//Bools
new bool:isMethaneLeak = true;

//Handles
new Handle:cvarMethaneLeak;
new Handle:cvarMethaneLeakCooldown;
new Handle:cvarMethaneLeakDamage;
new Handle:cvarMethaneLeakDuration;
new Handle:cvarMethaneLeakPeriod;
new Handle:cvarMethaneLeakRadius;
new Handle:cvarMethaneLeakTimer[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:cvarMethaneLeakTimerCloud[MAXPLAYERS+1] = INVALID_HANDLE;

// =================================
// Methane Strike
// =================================

//Bools
new bool:isMethaneStrike = true;

//Handles
new Handle:cvarMethaneStrike;

// =================================
// Moon Walk
// =================================

//Handles
new Handle:cvarMoonWalk;
new Handle:cvarMoonWalkSpeed;
new Handle:cvarMoonWalkStretch;
new Handle:MoonWalkTimer[MAXPLAYERS+1] = INVALID_HANDLE;

//Bools
new bool:isMoonWalk = false;
new bool:moonwalk[MAXPLAYERS+1] = false;

// =================================
// Restrained Hostage
// =================================

//Handles
new Handle:cvarRestrainedHostage;
new Handle:cvarRestrainedHostageAmount;
new Handle:cvarRestrainedHostageDamage;

//Bools
new bool:isRestrainedHostage = false;

// =================================
// Smoke Screen
// =================================

//Handles
new Handle:cvarSmokeScreen;
new Handle:cvarSmokeScreenChance;

//Bools
new bool:isSmokeScreen = false;

// =================================
// Tongue Strip
// =================================

//Bools
new bool:isTongueStrip = false;

//Handles
new Handle:cvarTongueStrip;
new Handle:cvarTongueStripChance;
new Handle:cvarTongueStripTimer;

// =================================
// Tongue Whip
// =================================

//Handles
new Handle:cvarTongueWhip;
new Handle:cvarTongueWhipPower;
new Handle:cvarTongueWhipDamage;
new Handle:cvarTongueWhipRange;

//Bools
new bool:isTongueWhip = false;

// =================================
// Void Pocket
// =================================

//Handles
new Handle:cvarVoidPocket;
new Handle:cvarVoidPocketCooldown;
new Handle:cvarVoidPocketPower;
new Handle:cvarVoidPocketRange;

//Bools
new bool:isVoidPocket = false;

//Floats
new Float:cooldownVoidPocket[MAXPLAYERS+1] = 0.0;

// ===========================================
// Generic Setup
// ===========================================

//Bools
new bool:isChoking[MAXPLAYERS+1] = false;

//Handles
new Handle:PluginStartTimer = INVALID_HANDLE;
static Handle:sdkCallFling			 = 	INVALID_HANDLE;
static Handle:sdkOnStaggered         =  INVALID_HANDLE;
static laggedMovementOffset = 0;

// ===========================================
// Plugin Info
// ===========================================

public Plugin:myinfo = 
{
    name = "[L4D2] Noxious Smoker",
    author = "Mortiegama",
    description = "Allows for unique Smoker abilities to spread its noxious aura.",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?p=2093026#post2093026"
}

	//Special Thanks:
	//AtomicStryker - Boomer Bit** Slap:
	//https://forums.alliedmods.net/showthread.php?t=97952
	
	//Olj - Smoke IT! (Moonwalk):
	//http://forums.alliedmods.net/showthread.php?p=936834
	
	//Machine - Weapon Drop
	//https://forums.alliedmods.net/showthread.php?t=123098

// ===========================================
// Plugin Start
// ===========================================

public OnPluginStart()
{
	CreateConVar("l4d_nsm_version", PLUGIN_VERSION, "Noxious Smoker Version", FCVAR_DONTRECORD|FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Asphyxiation
	// ======================================
	cvarAsphyxiation = CreateConVar("l4d_nsm_asphyxiation", "1", "Enables Asphyxiation ability: The Smoker pulls out the oxygen from the air around it causing nearby Survivors to struggle to breathe. (Def 1)", FCVAR_NOTIFY);
	cvarAsphyxiationFrequency = CreateConVar("l4d_nsm_asphyxiationfrequency", "1.0", "Frequency in which a Survivor nearby the Smoker will be injured. (Def 1.0)", FCVAR_NOTIFY);
	cvarAsphyxiationDamage = CreateConVar("l4d_nsm_asphyxiationdamage", "5", "Amount of damage caused by Asphyxiation. (Def 5)", FCVAR_NOTIFY);
	cvarAsphyxiationRange = CreateConVar("l4d_nsm_asphyxiationrange", "300.0", "Range around the Smoker that can cause Asphyxiation of Survivors. (Def 300.0)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Collapsed Lung
	// ======================================
	cvarCollapsedLung = CreateConVar("l4d_nsm_collapsedlung", "1", "Enables Collapsed Lung ability: The sheer crushing force of the Smoker's tongue causes the Survivors lungs to collapse. (Def 1)", FCVAR_NOTIFY);
	cvarCollapsedLungChance = CreateConVar("l4d_nsm_collapsedlungchance", "100", "Chance that a Survivor's lungs are collapsed. (100 = 100%). (Def 100)", FCVAR_NOTIFY);
	cvarCollapsedLungDuration = CreateConVar("l4d_nsm_collapsedlungduration", "5", "For how many seconds does the Collapsed Lung last. (Def 5)", FCVAR_NOTIFY);
	cvarCollapsedLungDamage = CreateConVar("l4d_nsm_collapsedlungdamage", "1", "How much damage is inflicted by Collapsed Lung each second. (Def 1)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Methane Blast
	// ======================================	
	cvarMethaneBlast = CreateConVar("l4d_nsm_methaneblast", "1", "Enables Methane Blast ability: When the Smoker is killed, the pressurized gas inside its body ignites causing an explosion. (Def 1)", FCVAR_NOTIFY);
	cvarMethaneBlastInnerPower = CreateConVar("l4d_nsm_methaneblastinnerpower", "300.0", "Power behind the inner range of Methane Blast. (Def 300.0)", FCVAR_NOTIFY);
	cvarMethaneBlastOuterPower = CreateConVar("l4d_nsm_methaneblastouterpower", "100.0", "Power behind the outer range of Methane Blast. (Def 100.0)", FCVAR_NOTIFY);
	cvarMethaneBlastInnerDamage = CreateConVar("l4d_nsm_methaneblastinnerdamage", "15", "Amount of damage caused in the inner range of Methane Blast. (Def 15)", FCVAR_NOTIFY);
	cvarMethaneBlastOuterDamage = CreateConVar("l4d_nsm_methaneblastouterdamage", "5", "Amount of damage caused in the outer range of Methane Blast. (Def 5)", FCVAR_NOTIFY);
	cvarMethaneBlastInnerRange = CreateConVar("l4d_nsm_methaneblastinnerrange", "75.0", "Range the inner blast radius will extend from Methane Blast. (Def 75.0)", FCVAR_NOTIFY);
	cvarMethaneBlastOuterRange = CreateConVar("l4d_nsm_methaneblastouterrange", "150.0", "Range the outer blast radius will extend from Methane Blast. (Def 150.0)", FCVAR_NOTIFY);

	// ======================================
	// Boomer Ability: Methane Leak
	// ======================================
	cvarMethaneLeak = CreateConVar("l4d_nbm_methaneleak", "1", "Enables Methane Leak ability: With methane gas barely contained in his body, the Smoker lets out a methane cloud that causes damage to anyone standing inside. (Def 1)", FCVAR_NOTIFY);
	cvarMethaneLeakCooldown = CreateConVar("l4d_nbm_methaneleakcooldown", "60.0", "Period of time between methane leaks. (Def 60.0)", FCVAR_NOTIFY);
	cvarMethaneLeakDamage = CreateConVar("l4d_nbm_methaneleakdamage", "5", "Amount of damage caused to Survivors standing in a methane cloud. (Def 5)", FCVAR_NOTIFY);
	cvarMethaneLeakDuration = CreateConVar("l4d_nbm_methaneleakduration", "10.0", "Period of time the methane cloud persists. (Def 10.0)", FCVAR_NOTIFY);
	cvarMethaneLeakPeriod = CreateConVar("l4d_nbm_methaneleakperiod", "2.0", "Frequency that standing in the methane cloud will cause damage. (Def 2.0)", FCVAR_NOTIFY);
	cvarMethaneLeakRadius = CreateConVar("l4d_nbm_methaneleakradius", "100.0", "Radius that the methane cloud will cover. (Def 100.0)", FCVAR_NOTIFY);

	// ======================================
	// Boomer Ability: Methane Strike
	// ======================================
	cvarMethaneStrike = CreateConVar("l4d_nbm_methanestrike", "1", "Enables Methane Strike ability: When shoved, the Smoker lets out a strike of Methane gas that will also caused whoever shoved him to stumble. (Def 1)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Moon Walk
	// ======================================
	cvarMoonWalk = CreateConVar("l4d_nsm_moonwalk", "1", "Enables Moon Walk ability: After wrapping up its victim, the Smoker is able to slowly move backwards, either dragging the survivor or stretching his tongue. (Def 1)", FCVAR_NOTIFY);
	cvarMoonWalkSpeed = CreateConVar("l4d_nsm_moonwalkspeed", "0.4", "How fast will the Smoker can move after a tongue grab and drag. (Def 0.4)", FCVAR_NOTIFY);
	cvarMoonWalkStretch = CreateConVar("l4d_nsm_moonwalkstretch", "2000", "How far the Smokers tongue can stretch before it snaps. (Def 2000)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Restrained Hostage
	// ======================================
	cvarRestrainedHostage = CreateConVar("l4d_nsm_restrainedhostage", "1", "Enables Restrained Hostage ability: The Smoker will use a victim it is currently choking to shield itself from damage. (Def 1)", FCVAR_NOTIFY);
	cvarRestrainedHostageAmount = CreateConVar("l4d_nsm_restrainedhostageamount", "0.5", "Percent of damage the Smoker avoids using a Survivor as a Hostage. (Def 0.5)", FCVAR_NOTIFY);
	cvarRestrainedHostageDamage = CreateConVar("l4d_nsm_restrainedhostagedamage", "3", "How much damage is inflicted to the Survivor being used as a Hostage. (Def 3)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Smoke Screen
	// ======================================
	cvarSmokeScreen = CreateConVar("l4d_nsm_smokescreen", "1", "Enables Smoke Screen ability: The Smokers continually pumps smoke around it's body which helps obscure his form from attacks. (Def 1)", FCVAR_NOTIFY);
	cvarSmokeScreenChance = CreateConVar("l4d_nsm_smokescreenchance", "20", "Chance that Smoke Screen will cause an attack to miss. (20 = 20%). (Def 20)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Tongue Strip
	// ======================================
	cvarTongueStrip = CreateConVar("l4d_nsm_tonguestrip", "1", "Enables Tongue Strip Ability: As the slippery tongue coils around the Survivor, it has a chance to knock out whatever item they were holding last. (Def 1)", FCVAR_NOTIFY);
	cvarTongueStripChance = CreateConVar("l4d_nsm_tonguestripchance", "50", "Chance that the Smoker's tongue will strip an item. (50 = 50%). (Def 50)", FCVAR_NOTIFY);

	// ======================================
	// Smoker Ability: Tongue Whip
	// ======================================
	cvarTongueWhip = CreateConVar("l4d_nsm_tonguewhip", "1", "Enables Tongue Whip ability: When the Smoker's tongue is broken while dragging a victim, the force of the snap causes it to whip out and strike nearby survivors. (Def 1)", FCVAR_NOTIFY);
	cvarTongueWhipPower = CreateConVar("l4d_nsm_tonguewhippower", "100.0", "Power behind the Smoker's tongue whip. (Def 100.0)", FCVAR_NOTIFY);
	cvarTongueWhipDamage = CreateConVar("l4d_nsm_tonguewhipdamage", "10", "Amount of damage the Smoker's tongue will inflict when whipped. (Def 10)", FCVAR_NOTIFY);
	cvarTongueWhipRange = CreateConVar("l4d_nsm_tonguewhiprange", "500.0", "How far the Smoker will be able to whip its tongue. (Def 500.0)", FCVAR_NOTIFY);
	
	// ======================================
	// Smoker Ability: Void Pocket
	// ======================================
	cvarVoidPocket = CreateConVar("l4d_nsm_voidpocket", "1", "Enables Void Pocket ability: The Smoker sucks all the air around him to himself causing Survivors to fly towards him. (Press Reload) (Def 1)", FCVAR_NOTIFY);
	cvarVoidPocketCooldown = CreateConVar("l4d_nsm_voidpocketcooldown", "5.0", "Amount of time between Void Pocket abilities. (Def 5.0)", FCVAR_NOTIFY);
	cvarVoidPocketPower = CreateConVar("l4d_nsm_voidpocketpower", "200.0", "Power of the pull from the Void Pocket. (Def 200.0)", FCVAR_NOTIFY);
	cvarVoidPocketRange = CreateConVar("l4d_nsm_voidpocketrange", "200.0", "Range the Void Pocket will pull Survivors from.(Def 200.0)", FCVAR_NOTIFY);

	// ======================================
	// Hook Events
	// ======================================
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("choke_start", Event_ChokeStart);
	HookEvent("choke_end", Event_ChokeEnd);
	HookEvent("tongue_grab", Event_TongueGrab);
	HookEvent("tongue_release", Event_TongueRelease, EventHookMode_Pre);
	HookEvent("player_shoved", Event_PlayerShoved);
	
	laggedMovementOffset = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");
	
	//AutoExecConfig(true, "plugin.L4D2.NoxiousSmoker");
	PluginStartTimer = CreateTimer(3.0, OnPluginStart_Delayed);
	
	// ======================================
	// Prep SDK Calls
	// ======================================
	ConfigFile = LoadGameConfigFile(GAMEDATA_FILENAME);
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_Fling");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkCallFling = EndPrepSDKCall();
	if (sdkCallFling == INVALID_HANDLE)
	{
		SetFailState("Cant initialize Fling SDKCall");
		return;
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer::OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	sdkOnStaggered = EndPrepSDKCall();
	if (sdkOnStaggered == INVALID_HANDLE)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::OnStaggered(CBaseEntity *, Vector  const*)\" signature, check the file version!");
	}
	
	CloseHandle(ConfigFile);
}

// ===========================================
// Plugin Start Delayed
// ===========================================

public Action:OnPluginStart_Delayed(Handle:timer)
{	
	if (GetConVarInt(cvarAsphyxiation))
	{
		isAsphyxiation = true;
	}
	
	if (GetConVarInt(cvarCollapsedLung))
	{
		isCollapsedLung = true;
	}
	
	if (GetConVarInt(cvarMethaneBlast))
	{
		isMethaneBlast = true;
	}
	
	if (GetConVarInt(cvarMethaneLeak))
	{
		isMethaneLeak = true;
	}
	
	if (GetConVarInt(cvarMethaneStrike))
	{
		isMethaneStrike = true;
	}
	
	if (GetConVarInt(cvarMoonWalk))
	{
		isMoonWalk = true;
	}
	
	if (GetConVarInt(cvarRestrainedHostage))
	{
		isRestrainedHostage = true;
	}
	
	if (GetConVarInt(cvarSmokeScreen))
	{
		isSmokeScreen = true;
	}
	
	if (GetConVarInt(cvarTongueStrip))
	{
		isTongueStrip = true;
	}
	
	if (GetConVarInt(cvarTongueWhip))
	{
		isTongueWhip = true;
	}
	
	if (GetConVarInt(cvarVoidPocket))
	{
		isVoidPocket = true;
	}
	
	if(PluginStartTimer != INVALID_HANDLE)
	{
 		KillTimer(PluginStartTimer);
		PluginStartTimer = INVALID_HANDLE;
	}
	
	return Plugin_Stop;
}

// ====================================================================================================================
// ===========================================                              =========================================== 
// ===========================================            SMOKER            =========================================== 
// ===========================================                              =========================================== 
// ====================================================================================================================

// ===========================================
// Smoker Setup Events
// ===========================================

public Event_PlayerSpawn (Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	if (IsValidSmoker(client))
	{
		if (isAsphyxiation)
		{
			SmokerAbility_Asphyxiation(client);
		}
		
		// =================================
		// Smoker Ability: Methane Leak
		// =================================
		if (isMethaneLeak)
		{
			SmokerAbility_MethaneLeak(client);
		}
	}
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (IsValidSmoker(victim))
	{
		if (isRestrainedHostage && isChoking[victim] && IsValidClient(attacker))
		{
			new Float:damagemod = GetConVarFloat(cvarRestrainedHostageAmount);
			
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage * damagemod;
			}
			
			new hostage = GetEntPropEnt(victim, Prop_Send, "m_tongueVictim");
			
			if (IsValidClient(hostage))
			{
				new dmg = GetConVarInt(cvarRestrainedHostageDamage);
				DamageHook(hostage, victim, dmg);
			}
		}
		
		if (isSmokeScreen && !isChoking[victim] && IsValidClient(attacker))
		{
			new SmokeScreenPercent = GetRandomInt(0, 99);
			new SmokeScreenChance = (GetConVarInt(cvarSmokeScreenChance));

			if (SmokeScreenPercent < SmokeScreenChance)
			{
				damage = damage * 0;
			}
		}
	}

	return Plugin_Changed;
}

// ===========================================
// Player Death
// ===========================================

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (isMethaneBlast)
	{
		SmokerAbility_MethaneBlast(client);
	}
}

// ===========================================
// Player Shoved
// ===========================================

public Event_PlayerShoved(Handle:event, const String:name[], bool:dontBroadcast)
{
	new smoker = GetClientOfUserId(GetEventInt(event, "userid"));
	new survivor = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (isMethaneStrike)
	{
		SmokerAbility_MethaneStrike(smoker, survivor);
	}
}

// ===========================================
// Smoker Generic Calls
// ===========================================
// Description: This will call and sort all Smoker Events

public Event_TongueGrab (Handle:event, const String:name[], bool:dontBroadcast)
{
	new smoker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));

	if (IsValidSmoker(smoker))
	{
		isChoking[smoker] = true;
	}
	
	#if DEBUG
	PrintToChatAll("Tongue Grab occurred.");
	#endif
	
	if (isMoonWalk)
	{
		SmokerAbility_Moonwalk_Start(smoker, victim);
	}
	
	if (isTongueStrip)
	{
		SmokerAbility_TongueStrip(smoker, victim);
	}
}

public Action:Event_TongueRelease(Handle:event, const String:name[], bool:dontBroadcast)
{
	new smoker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));

	if (IsValidSmoker(smoker))
	{
		isChoking[smoker] = false;
	}
	
	#if DEBUG
	PrintToChatAll("Tongue has been released.");
	#endif
	
	if (isCollapsedLung)
	{
		SmokerAbility_CollapsedLung(victim, smoker);
	}
	
	if (isMoonWalk)
	{
		SmokerAbility_Moonwalk_End(smoker);
	}
	
	if (isTongueWhip)
	{
		SmokerAbility_TongueWhip(victim, smoker);
	}
}

public Event_ChokeStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new smoker = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsValidSmoker(smoker))
	{
		isChoking[smoker] = true;
	}
	
	#if DEBUG
	PrintToChatAll("Choke has started.");
	#endif
}

public Event_ChokeEnd (Handle:event, const String:name[], bool:dontBroadcast)
{
	new smoker = GetClientOfUserId(GetEventInt(event,"userid"));
	
	if (IsValidSmoker(smoker))
	{
		isChoking[smoker] = false;
	}
	
	#if DEBUG
	PrintToChatAll("Choke has ended.");
	#endif
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (buttons & IN_RELOAD && IsValidSmoker(client) && isVoidPocket)
	{
		SmokerAbility_VoidPocket(client);
	}
}

// ===========================================
// Smoker Ability: Asphyxiation 
// ===========================================
// Description: The Smoker pulls out the oxygen from the air around it causing nearby Survivors to struggle to breathe.

public Action:SmokerAbility_Asphyxiation(smoker)
{
	if (IsValidSmoker(smoker))
	{
		new Float:frequency = GetConVarFloat(cvarAsphyxiationFrequency);
		cvarAsphyxiationTimer[smoker] = CreateTimer(frequency, Timer_Asphyxiation, smoker, TIMER_REPEAT);
	}
}

public Action:Timer_Asphyxiation(Handle:timer, any:smoker)
{
	if (!IsValidSmoker(smoker))
	{
		if (cvarAsphyxiationTimer[smoker] != INVALID_HANDLE)
		{
			KillTimer(cvarAsphyxiationTimer[smoker]);
			cvarAsphyxiationTimer[smoker] = INVALID_HANDLE;
		}	
	
		return Plugin_Stop;
	}

	for (new victim=1; victim<=MaxClients; victim++)
	
	if (IsValidClient(victim) && IsValidSmoker(smoker) && GetClientTeam(victim) == 2)
	{
		decl Float:v_pos[3];
		GetClientEyePosition(victim, v_pos);		
		decl Float:targetVector[3];
		decl Float:distance;
		new Float:range = GetConVarFloat(cvarAsphyxiationRange);
		GetClientEyePosition(smoker, targetVector);
		distance = GetVectorDistance(targetVector, v_pos);
		
		#if DEBUG
		PrintToChatAll("Distance: %f Client: %n", distance, victim);
		#endif
		
		if (distance <= range)
		{
			new damage = GetConVarInt(cvarAsphyxiationDamage);
			DamageHook(victim, smoker, damage);
		}
	}
	
	return Plugin_Continue;
}




// ===========================================
// Smoker Ability: Collapsed Lung
// ===========================================
// Description: The sheer crushing force of the Smoker's tongue causes the Survivors lungs to collapse.

public Action:SmokerAbility_CollapsedLung(victim, smoker)
{
	if (IsValidClient(victim) && GetClientTeam(victim) == 2)
	{
		new CollapsedLungChance = GetRandomInt(0, 99);
		new CollapsedLungPercent = (GetConVarInt(cvarCollapsedLungChance));

		if (isCollapsedLung && CollapsedLungChance < CollapsedLungPercent)
		{
			if(collapsedlung[victim] <= 0)
			{
				collapsedlung[victim] = (GetConVarInt(cvarCollapsedLungDuration));
				
				new Handle:dataPack = CreateDataPack();
				cvarCollapsedLungTimer[victim] = CreateDataTimer(1.0, Timer_CollapsedLung, dataPack, TIMER_REPEAT);
				WritePackCell(dataPack, victim);
				WritePackCell(dataPack, smoker);
			}
			
			#if DEBUG
			PrintToChatAll("Collapsed Lung: Survivor has been affected.");
			#endif
		}
	}
}		
		
public Action:Timer_CollapsedLung(Handle:timer, any:dataPack) 
{
	ResetPack(dataPack);
	new victim = ReadPackCell(dataPack);
	new smoker = ReadPackCell(dataPack);
	
	if (IsValidClient(victim))
	{
		if(collapsedlung[victim] <= 0) 
		{
			if (cvarCollapsedLungTimer[victim] != INVALID_HANDLE)
			{
				KillTimer(cvarCollapsedLungTimer[victim]);
				cvarCollapsedLungTimer[victim] = INVALID_HANDLE;
			}
				
			return Plugin_Stop;
		}
		
		new damage = GetConVarInt(cvarCollapsedLungDamage);
		DamageHook(victim, smoker, damage);
		
		if(collapsedlung[victim] > 0) 
		{
			collapsedlung[victim] -= 1;
		}
	}
	
	return Plugin_Continue;
}




// ===========================================
// Smoker Ability: Methane Blast
// ===========================================
// Description: When the Smoker is killed, the pressurized gas inside its body ignites causing an explosion.

public Action:SmokerAbility_MethaneBlast(smoker)
{
	if (IsValidDeadSmoker(smoker) && isMethaneBlast)
	{
		for (new victim=1; victim<=MaxClients; victim++)
		{
			if (IsValidClient(victim) && GetClientTeam(victim) != 3 && !IsSurvivorPinned(victim))
			{
				decl Float:smokerPos[3];
				decl Float:survivorPos[3];
				decl Float:distance;
				GetClientEyePosition(smoker, smokerPos);
				GetClientEyePosition(victim, survivorPos);
				new Float:range1 = GetConVarFloat(cvarMethaneBlastInnerRange);
				new Float:range2 = GetConVarFloat(cvarMethaneBlastOuterRange);
				distance = GetVectorDistance(smokerPos, survivorPos);
				if (distance < range1)
				{
					decl String:sRadius[256];
					decl String:sPower[256];
					new magnitude = GetConVarInt(cvarMethaneBlastInnerPower);
					IntToString(GetConVarInt(cvarMethaneBlastInnerRange), sRadius, sizeof(sRadius));
					IntToString(magnitude, sPower, sizeof(sPower));
					new exPhys = CreateEntityByName("env_physexplosion");
		
					//Set up physics movement explosion
					DispatchKeyValue(exPhys, "radius", sRadius);
					DispatchKeyValue(exPhys, "magnitude", sPower);
					DispatchSpawn(exPhys);
					TeleportEntity(exPhys, smokerPos, NULL_VECTOR, NULL_VECTOR);
						
					//BOOM!
					AcceptEntityInput(exPhys, "Explode");
		
					decl Float:traceVec[3], Float:resultingVec[3], Float:currentVelVec[3];
					new Float:power = GetConVarFloat(cvarMethaneBlastInnerPower);
					MakeVectorFromPoints(smokerPos, survivorPos, traceVec);				// draw a line from car to Survivor
					GetVectorAngles(traceVec, resultingVec);							// get the angles of that line
					
					resultingVec[0] = Cosine(DegToRad(resultingVec[1])) * power;	// use trigonometric magic
					resultingVec[1] = Sine(DegToRad(resultingVec[1])) * power;
					resultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
					
					GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
					resultingVec[0] += currentVelVec[0];
					resultingVec[1] += currentVelVec[1];
					resultingVec[2] += currentVelVec[2];
									
					new damage = GetConVarInt(cvarMethaneBlastInnerDamage);
					DamageHook(victim, smoker, damage);

					new Float:incaptime = 3.0;
					SDKCall(sdkCallFling, victim, resultingVec, 76, smoker, incaptime); //76 is the 'got bounced' animation in L4D2
				}
					
				if (distance < range2 && distance > range1)
				{
					decl String:sRadius[256];
					decl String:sPower[256];
					new magnitude = GetConVarInt(cvarMethaneBlastOuterPower);
					IntToString(GetConVarInt(cvarMethaneBlastOuterRange), sRadius, sizeof(sRadius));
					IntToString(magnitude, sPower, sizeof(sPower));
					new exPhys = CreateEntityByName("env_physexplosion");
		
					//Set up physics movement explosion
					DispatchKeyValue(exPhys, "radius", sRadius);
					DispatchKeyValue(exPhys, "magnitude", sPower);
					DispatchSpawn(exPhys);
					TeleportEntity(exPhys, smokerPos, NULL_VECTOR, NULL_VECTOR);
						
					//BOOM!
					AcceptEntityInput(exPhys, "Explode");
		
					decl Float:traceVec[3], Float:resultingVec[3], Float:currentVelVec[3];
					new Float:power = GetConVarFloat(cvarMethaneBlastOuterPower);
					MakeVectorFromPoints(smokerPos, survivorPos, traceVec);				// draw a line from car to Survivor
					GetVectorAngles(traceVec, resultingVec);							// get the angles of that line
					
					resultingVec[0] = Cosine(DegToRad(resultingVec[1])) * power;	// use trigonometric magic
					resultingVec[1] = Sine(DegToRad(resultingVec[1])) * power;
					resultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
					
					GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
					resultingVec[0] += currentVelVec[0];
					resultingVec[1] += currentVelVec[1];
					resultingVec[2] += currentVelVec[2];
									
					new damage = GetConVarInt(cvarMethaneBlastOuterDamage);
					DamageHook(victim, smoker, damage);

					new Float:incaptime = 3.0;
					SDKCall(sdkCallFling, victim, resultingVec, 76, smoker, incaptime); //76 is the 'got bounced' animation in L4D2
				}
			}
		}
	}
}




// ===========================================
// Smoker Ability: Methane Leak
// ===========================================
// Description: With methane gas barely contained in his body, the Smoker lets out a methane cloud that causes damage to anyone standing inside.

public Action:SmokerAbility_MethaneLeak(smoker)
{
	Prepare_MethaneLeak(smoker);
	new Float:time = GetConVarFloat(cvarMethaneLeakCooldown);
	cvarMethaneLeakTimer[smoker] = CreateTimer(time, Timer_MethaneLeak, smoker, TIMER_REPEAT);
}

public Action:Timer_MethaneLeak(Handle:timer, any:smoker)
{
	if (!IsValidSmoker(smoker) || IsPlayerGhost(smoker))
	{
		if (cvarMethaneLeakTimer[smoker] != INVALID_HANDLE)
		{
			KillTimer(cvarMethaneLeakTimer[smoker]);
			cvarMethaneLeakTimer[smoker] = INVALID_HANDLE;
		}	
	
		return Plugin_Stop;
	}
	Prepare_MethaneLeak(smoker);
	
	return Plugin_Continue;
}
	
public Action:Prepare_MethaneLeak(smoker)
{	
	decl Float:vecPos[3];
	GetClientEyePosition(smoker, vecPos);
	
	new Float:targettime = GetEngineTime() + GetConVarFloat(cvarMethaneLeakDuration);
	ShowParticle(vecPos, "smoker_smokecloud", targettime);

	new Handle:dataPack = CreateDataPack();
	WritePackCell(dataPack, smoker);
	WritePackFloat(dataPack, vecPos[0]);
	WritePackFloat(dataPack, vecPos[1]);
	WritePackFloat(dataPack, vecPos[2]);
	WritePackFloat(dataPack, targettime);
	
	new Float:time = GetConVarFloat(cvarMethaneLeakPeriod);
	cvarMethaneLeakTimerCloud[smoker] = CreateTimer(time, Timer_MethaneLeakCloud, dataPack, TIMER_REPEAT);
}

public Action:Timer_MethaneLeakCloud(Handle:timer, Handle:dataPack)
{
	ResetPack(dataPack);
	new smoker = ReadPackCell(dataPack);
	decl Float:vecPos[3];
	vecPos[0] = ReadPackFloat(dataPack);
	vecPos[1] = ReadPackFloat(dataPack);
	vecPos[2] = ReadPackFloat(dataPack);
	new Float:targettime = ReadPackFloat(dataPack);
	if (targettime - GetEngineTime() < 0 )
	{
		KillTimer(cvarMethaneLeakTimerCloud[smoker]);
		cvarMethaneLeakTimerCloud[smoker] = INVALID_HANDLE;
	
		return Plugin_Stop;
	}
	decl Float:targetVector[3];
	decl Float:distance;
	new Float:radiussetting = GetConVarFloat(cvarMethaneLeakRadius);
	
	for (new victim=1; victim<=MaxClients; victim++)
	{
		if (IsValidClient(victim) && GetClientTeam(victim) == 2)
		{
			GetClientEyePosition(victim, targetVector);
			distance = GetVectorDistance(targetVector, vecPos);
			
			if (distance > radiussetting
			|| !IsVisibleTo(vecPos, targetVector)) continue;
			
			new damage = GetConVarInt(cvarMethaneLeakDamage);
			DamageHook(victim, smoker, damage);
			PrintHintText(victim, "Smoker sẽ thả ra một vùng khí độc hại hơn sau mỗi chu kỳ %f", cvarMethaneLeakCooldown);
		}
	}

	return Plugin_Continue;
}




// ===========================================
// Smoker Ability: Methane Strike
// ===========================================
// Description: When shoved, the Smoker lets out a strike of Methane gas that will also caused whoever shoved him to stumble.

public Action:SmokerAbility_MethaneStrike(smoker, survivor)
{
	if (IsValidSmoker(smoker) && IsValidClient(survivor) && GetClientTeam(survivor) == 2)
	{
		decl Float:smokerPos[3];
		GetEntPropVector(smoker, Prop_Send, "m_vecOrigin", smokerPos);
		new Float:vecOrigin[3];
		GetClientAbsOrigin(survivor, vecOrigin);
		SDKCall(sdkOnStaggered, survivor, smoker, smokerPos);
	}
}




// ===========================================
// Smoker Ability: Moon Walk
// ===========================================
// Description: After wrapping up its victim, the Smoker is able to slowly move backwards, either dragging the survivor or stretching his tongue.

public Action:SmokerAbility_Moonwalk_Start(smoker, victim)
{
	new Handle:pack;

	if (IsValidSmoker(smoker))
	{
		moonwalk[smoker] = true;
		SetEntityMoveType(smoker, MOVETYPE_ISOMETRIC);
		SetEntDataFloat(smoker, laggedMovementOffset, 1.0*GetConVarFloat(cvarMoonWalkSpeed), true);
		MoonWalkTimer[smoker] = CreateDataTimer(0.2, Timer_MoonWalk, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		WritePackCell(pack, smoker);
		WritePackCell(pack, victim);
		
		#if DEBUG
		PrintToChatAll("Moonwalk: Pack has been written and timer started.");
		#endif
	}
}

public Action:Timer_MoonWalk(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new smoker = ReadPackCell(pack);
	
	if ((!IsValidSmoker(smoker))||(GetClientTeam(smoker)!=3)||(moonwalk[smoker] = false))
	{
		KillTimer(MoonWalkTimer[smoker]);
		MoonWalkTimer[smoker] = INVALID_HANDLE;
		return Plugin_Stop;
	}
			
	new victim = ReadPackCell(pack);
	
	if ((!IsValidClient(victim))||(GetClientTeam(victim)!=2)||(moonwalk[smoker] = false))
	{
		KillTimer(MoonWalkTimer[smoker]);
		MoonWalkTimer[smoker] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	new MoonWalkStretch = GetConVarInt(cvarMoonWalkStretch);
	new Float:SmokerPosition[3];
	new Float:VictimPosition[3];
	GetClientAbsOrigin(smoker,SmokerPosition);
	GetClientAbsOrigin(victim,VictimPosition);
	new distance = RoundToNearest(GetVectorDistance(SmokerPosition, VictimPosition));

	if (distance > MoonWalkStretch)
	{
		SlapPlayer(smoker, 0, false);
	}

	return Plugin_Continue;
}

public Action:SmokerAbility_Moonwalk_End(smoker)
{
	if (IsValidSmoker(smoker))
	{
		moonwalk[smoker] = false;
		SetEntityMoveType(smoker, MOVETYPE_CUSTOM);
		SetEntDataFloat(smoker, laggedMovementOffset, 1.0, true);
		
		if (MoonWalkTimer[smoker] != INVALID_HANDLE)
		{
			KillTimer(MoonWalkTimer[smoker]);
			MoonWalkTimer[smoker] = INVALID_HANDLE;
		}
		
		#if DEBUG
		PrintToChatAll("Moonwalk: Cleared this ability.");
		#endif
	}
}




// ===========================================
// Smoker Ability: Tongue Strip
// ===========================================
// Description: As the slippery tongue coils around the Survivor, it has a chance to knock out whatever item they were holding last.

public SmokerAbility_TongueStrip(smoker, victim)
{
	new TongueStripChance = GetRandomInt(0, 99);
	new TongueStripPercent = (GetConVarInt(cvarTongueStripChance));

	if (IsValidSmoker(smoker) && IsValidClient(victim) && GetClientTeam(victim) == 2 && TongueStripChance < TongueStripPercent)
	{
		int slot;
		char weapon[32];
		GetClientWeapon(victim, weapon, sizeof(weapon));
		for (int count=0; count<=35; count++)
		{
			switch(count)
			{
				case 17: slot = 1;
				case 21: slot = 2;
				case 24: slot = 3;
				case 28: slot = 4;
				case 30: slot = 5;
			}
			if (StrEqual(weapon, WeaponNames[count]))
			{
				DropSlot(victim, slot, true);
			}
		}
	}
	return Plugin_Handled;
}

void DropSlot(int client, int slot, bool away)
{
	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
	{
		int weapon = GetPlayerWeaponSlot(client, slot);
		
		if (weapon > 0 && IsValidEntity(weapon) && slot != 1)
		{
			CallWeaponDrop(client, weapon, away);
		}
	}
}

void CallWeaponDrop(int client, int weapon, bool away)
{		
	float vecTarget[3];
	if (GetPlayerEye(client, vecTarget))
	{
		if (GetEntPropFloat(weapon,Prop_Data,"m_flNextPrimaryAttack") >= GetGameTime())
		{
			return;
		}
		
		float vecAngles[3], vecVelocity[3]; 
		GetClientEyeAngles(client, vecAngles);
		
		GetAngleVectors(vecAngles, vecVelocity, NULL_VECTOR, NULL_VECTOR);

		vecVelocity[0] *= 300.0;
		vecVelocity[1] *= 300.0;
		vecVelocity[2] *= 300.0;
		
		SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", -1);
		ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
		
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
		
		if (away)
		{
			TeleportEntity(weapon, NULL_VECTOR, NULL_VECTOR, vecVelocity);
		}
		
		char classname[32];
		GetEdictClassname(weapon, classname, sizeof(classname));
		if (StrEqual(classname,"weapon_defibrillator"))
		{
			SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", MODEL_DEFIB);
		}
	}
}

bool GetPlayerEye(int client, float vecTarget[3]) 
{
	float Origin[3], Angles[3];
	GetClientEyePosition(client, Origin);
	GetClientEyeAngles(client, Angles);

	Handle trace = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace)) 
	{
		TR_GetEndPosition(vecTarget, trace);
		CloseHandle(trace);
		return true;
	}
	
	CloseHandle(trace);
	return false;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > GetMaxClients() || !entity;
}




// ===========================================
// Smoker Ability: Tongue Whip
// ===========================================
// Description: When the Smoker's tongue is broken while dragging a victim, the force of the snap causes it to whip out and strike nearby survivors.

public SmokerAbility_TongueWhip(victim, smoker)
{	
	if (IsValidClient(victim) && IsValidSmoker(smoker) && GetClientTeam(victim) == 2)
	{
		decl Float:smokerPos[3];
		decl Float:victimPos[3];
		GetClientEyePosition(smoker, smokerPos);
		GetClientEyePosition(victim, victimPos);		
		decl Float:targetPos[3];
		decl Float:distance1;
		decl Float:distance2;
		new Float:range = GetConVarFloat(cvarTongueWhipRange);
		
		for (new target=1; target<=MaxClients; target++)
		{
			if (target != victim && IsValidClient(target) && GetClientTeam(target) == 2 && !IsSurvivorPinned(target))
			{
				#if DEBUG
				PrintToChatAll("Tongue Whip: Found target %N.", target);
				#endif
				
				GetClientEyePosition(target, targetPos);
				distance1 = GetVectorDistance(targetPos, smokerPos);
				distance2 = GetVectorDistance(targetPos, victimPos);
				
				if (distance1 < range || distance2 < range)
				{				
					decl String:sRadius[256];
					decl String:sPower[256];
					new magnitude = GetConVarInt(cvarTongueWhipPower);
					IntToString(GetConVarInt(cvarTongueWhipRange), sRadius, sizeof(sRadius));
					IntToString(magnitude, sPower, sizeof(sPower));
					new exPhys = CreateEntityByName("env_physexplosion");
					
					//Set up physics movement explosion
					DispatchKeyValue(exPhys, "radius", sRadius);
					DispatchKeyValue(exPhys, "magnitude", sPower);
					DispatchSpawn(exPhys);
					TeleportEntity(exPhys, smokerPos, NULL_VECTOR, NULL_VECTOR);
						
					//BOOM!
					AcceptEntityInput(exPhys, "Explode");
				
					decl Float:traceVec[3], Float:resultingVec[3], Float:currentVelVec[3];
					new Float:power = GetConVarFloat(cvarTongueWhipPower);
					MakeVectorFromPoints(smokerPos, targetPos, traceVec);				// draw a line from car to Survivor
					GetVectorAngles(traceVec, resultingVec);							// get the angles of that line
					
					resultingVec[0] = Cosine(DegToRad(resultingVec[1])) * power;	// use trigonometric magic
					resultingVec[1] = Sine(DegToRad(resultingVec[1])) * power;
					resultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
							
					GetEntPropVector(target, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
					resultingVec[0] += currentVelVec[0];
					resultingVec[1] += currentVelVec[1];
					resultingVec[2] += currentVelVec[2];
					
					new damage = GetConVarInt(cvarTongueWhipDamage);
					DamageHook(target, smoker, damage);

					new Float:incaptime = 3.0;
					SDKCall(sdkCallFling, target, resultingVec, 76, smoker, incaptime); //76 is the 'got bounced' animation in L4D2
				}
			}
		}
	}
}




// ===========================================
// Smoker Ability: Void Pocket
// ===========================================
// Description: The Smoker sucks all the air around him to himself causing Survivors to fly towards him. 

public Action:SmokerAbility_VoidPocket(smoker)
{
	if (IsValidSmoker(smoker) && !IsPlayerGhost(smoker) && IsVoidPocketReady(smoker))
	{
		cooldownVoidPocket[smoker] = GetEngineTime();			
		for (new victim=1; victim<=MaxClients; victim++)
		{
    		if (IsValidClient(victim) && (GetClientTeam(victim) == 2)  && IsSurvivorPinned(victim))
    		{
    			decl Float:smokerPos[3];
    			decl Float:survivorPos[3];
    			decl Float:distance;
    			new Float:range = GetConVarFloat(cvarVoidPocketRange);
    			GetClientEyePosition(smoker, smokerPos);
    			GetClientEyePosition(victim, survivorPos);
    			distance = GetVectorDistance(survivorPos, smokerPos);
    			if (distance < range)
    			{
    				decl String:sRadius[256];
    				decl String:sPower[256];
    				new magnitude = GetConVarInt(cvarVoidPocketPower)*-1;
    				IntToString(GetConVarInt(cvarVoidPocketRange), sRadius, sizeof(sRadius));
    				IntToString(magnitude, sPower, sizeof(sPower));
    				new exPhys = CreateEntityByName("env_physexplosion");
    	
    				//Set up physics movement explosion
    				DispatchKeyValue(exPhys, "radius", sRadius);
    				DispatchKeyValue(exPhys, "magnitude", sPower);
    				DispatchSpawn(exPhys);
    				TeleportEntity(exPhys, survivorPos, NULL_VECTOR, NULL_VECTOR);
    					
    				//BOOM!
    				AcceptEntityInput(exPhys, "Explode");
    	
    				decl Float:traceVec[3], Float:resultingVec[3], Float:currentVelVec[3];
    				new Float:power = GetConVarFloat(cvarVoidPocketPower);
    				MakeVectorFromPoints(smokerPos, survivorPos, traceVec);				// draw a line from car to Survivor
    				GetVectorAngles(traceVec, resultingVec);
    				resultingVec[0] = Cosine(DegToRad(resultingVec[1])) * power;	// use trigonometric magic
    				resultingVec[1] = Sine(DegToRad(resultingVec[1])) * power;
    				resultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
    					
    				GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
    				resultingVec[0] += currentVelVec[0];
    				resultingVec[1] += currentVelVec[1];
    				resultingVec[2] += currentVelVec[2];
    				
    				resultingVec[0] = resultingVec[0]*-1;
    				resultingVec[1] = resultingVec[1]*-1;
    				
    				new Float:incaptime = 3.0;
    				SDKCall(sdkCallFling, victim, resultingVec, 76, smoker, incaptime); //76 is the 'got bounced' animation in L4D2
    			}
    		}
		}
	}
}




// ====================================================================================================================
// ===========================================                              =========================================== 
// ===========================================        GENERIC CALLS         =========================================== 
// ===========================================                              =========================================== 
// ====================================================================================================================
void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_GENERIC);
}
public Action:DamageHook(victim, attacker, damage)
{
	HurtEntity(victim, attacker, float(damage));
/* 	decl Float:victimPos[3], String:strDamage[16], String:strDamageTarget[16];
			
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, strDamage, sizeof(strDamage));
	Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", victim);
	
	new entPointHurt = CreateEntityByName("point_hurt");
	if(!entPointHurt) return;

	// Config, create point_hurt
	DispatchKeyValue(victim, "targetname", strDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", strDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", strDamage);
	DispatchKeyValue(entPointHurt, "DamageType", "0"); // DMG_GENERIC
	DispatchSpawn(entPointHurt);
	
	// Teleport, activate point_hurt
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (attacker && attacker < MaxClients && IsClientInGame(attacker)) ? attacker : -1);
	
	// Config, delete point_hurt
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	RemoveEdict(entPointHurt); */
}

// ----------------------------------------------------------------------------
// ClientViews()
// ----------------------------------------------------------------------------
stock bool:ClientViews(Viewer, Target, Float:fMaxDistance=0.0, Float:fThreshold=0.73)
{
	// Retrieve view and target eyes position
	decl Float:fViewPos[3];   GetClientEyePosition(Viewer, fViewPos);
	decl Float:fViewAng[3];   GetClientEyeAngles(Viewer, fViewAng);
	decl Float:fViewDir[3];
	decl Float:fTargetPos[3]; GetClientEyePosition(Target, fTargetPos);
	decl Float:fTargetDir[3];
	decl Float:fDistance[3];

	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);

	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	new Float:fMinDistance = 100.0;
	
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
			return false;
	}
	
	if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) < (fMinDistance*fMinDistance))
			return false;

	// Check dot product. If it's negative, that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold) return false;

	// Now check if there are no obstacles in between through raycasting
	new Handle:hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace)) { CloseHandle(hTrace); return false; }
	CloseHandle(hTrace);

	// Done, it's visible
	return true;
}

stock bool:ClientViewsReverse(Viewer, Target, Float:fMaxDistance=0.0, Float:fThreshold=0.73)
{
	// Retrieve view and target eyes position
	decl Float:fViewPos[3];   GetClientEyePosition(Viewer, fViewPos);
	decl Float:fViewAng[3];   GetClientEyeAngles(Viewer, fViewAng);
	decl Float:fViewDir[3];
	decl Float:fTargetPos[3]; GetClientEyePosition(Target, fTargetPos);
	decl Float:fTargetDir[3];
	decl Float:fDistance[3];

	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);

	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	new Float:fMinDistance = 100.0;
	
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
			return false;
	}
	
	if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) < (fMinDistance*fMinDistance))
			return false;

	// Check dot product. If it's negative (> fThreshold), that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) > fThreshold) return false;

	// Now check if there are no obstacles in between through raycasting
	new Handle:hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace)) { CloseHandle(hTrace); return false; }
	CloseHandle(hTrace);

	// Done, it's visible
	return true;
}

// ----------------------------------------------------------------------------
// ClientViewsFilter()
// ----------------------------------------------------------------------------
public bool:ClientViewsFilter(Entity, Mask, any:Junk)
{
	if (Entity >= 1 && Entity <= MaxClients) return false;
	return true;
} 

public ShowParticle(Float:victimPos[3], String:particlename[], Float:time)
{
	new particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		TeleportEntity(particle, victimPos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(time, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
	} 
}
 
public PrecacheParticle(String:particlename[])
{
	new particle = CreateEntityByName("info_particle_system");
	
	if (IsValidEdict(particle))
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.01, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:DeleteParticles(Handle:timer, any:particle)
{
	if (IsValidEntity(particle))
	{
		decl String:classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "stop");
			AcceptEntityInput(particle, "kill");
			RemoveEdict(particle);
		}
	}
}

static bool:IsVisibleTo(Float:position[3], Float:targetposition[3])
{
	decl Float:vAngles[3], Float:vLookAt[3];
	
	MakeVectorFromPoints(position, targetposition, vLookAt); // compute vector from start to target
	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace
	
	// execute Trace
	new Handle:trace = TR_TraceRayFilterEx(position, vAngles, MASK_SHOT, RayType_Infinite, _TraceFilter);
	
	new bool:isVisible = false;
	if (TR_DidHit(trace))
	{
		decl Float:vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint
		
		if ((GetVectorDistance(position, vStart, false) + TRACE_TOLERANCE) >= GetVectorDistance(position, targetposition))
		{
			isVisible = true; // if trace ray lenght plus tolerance equal or bigger absolute distance, you hit the target
		}
	}
	else
	{
		LogError("Tracer Bug: Player-Zombie Trace did not hit anything, WTF");
		isVisible = true;
	}
	CloseHandle(trace);
	
	return isVisible;
}

public bool:_TraceFilter(entity, contentsMask)
{
	if (!entity || !IsValidEntity(entity)) // dont let WORLD, or invalid entities be hit
	{
		return false;
	}
	
	return true;
}

public OnMapStart()
{
	MODEL_DEFIB = PrecacheModel("models/w_models/weapons/w_eq_defibrillator.mdl", true);
}

public OnMapEnd()
{
    for (new client=1; client<=MaxClients; client++)
	{
	if (IsValidClient(client))
		{
			isChoking[client] = false;
		}
	}
}




// ====================================================================================================================
// ===========================================                              =========================================== 
// ===========================================          BOOL CALLS          =========================================== 
// ===========================================                              =========================================== 
// ====================================================================================================================

public IsVoidPocketReady(smoker)
{
	return ((GetEngineTime() - cooldownVoidPocket[smoker]) > GetConVarFloat(cvarVoidPocketCooldown));
}

public IsValidSmoker(client)
{
	if (IsValidClient(client) && GetClientTeam(client) == 3)
	{
		new class = GetEntProp(client, Prop_Send, "m_zombieClass");
		
		if (class == ZOMBIECLASS_SMOKER)
			return true;
		
		return false;
	}
	
	return false;
}

public IsValidDeadSmoker(client)
{
	if (IsValidDeadClient(client))
	{
		new class = GetEntProp(client, Prop_Send, "m_zombieClass");
		
		if (class == ZOMBIECLASS_SMOKER)
			return true;
		
		return false;
	}
	
	return false;
}

public IsValidClient(client)
{
	if (client <= 0)
		return false;
		
	if (client > MaxClients)
		return false;
		
	if (!IsClientInGame(client))
		return false;
		
	if (!IsPlayerAlive(client))
		return false;

	return true;
}

public IsValidDeadClient(client)
{
	if (client <= 0)
		return false;
		
	if (client > MaxClients)
		return false;
		
	if (!IsClientInGame(client))
		return false;
		
	if (IsPlayerAlive(client))
		return false;

	return true;
}

public IsPlayerGhost(client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost")) return true;
		else return false;
}

public IsPlayerOnGround(client)
{
	if (GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND) return true;
		else return false;
}

public IsSurvivorPinned(client)
{
	new attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	if (attacker > 0 && attacker != client)
		return true;
		
	attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
	if (attacker > 0 && attacker != client)
		return true;
		
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0 && attacker != client)
		return true;
		
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0 && attacker != client)
		return true;
		
	attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	if (attacker > 0 && attacker != client)
		return true;
		
	return false;
}