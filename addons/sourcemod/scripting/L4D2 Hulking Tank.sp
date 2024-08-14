#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define L4D2 Hulking Tank
#define PLUGIN_VERSION "1.11"

#define STRING_LENGHT								56
#define ZOMBIECLASS_TANK 					    	8

static const char GAMEDATA_FILENAME[]				= "l4d2addresses";
static const float SLAP_VERTICAL_MULTIPLIER			= 1.5;
static int laggedMovementOffset 						= 0;
static int frustrationOffset							= 0;
static int aiTank;

ConVar cvarBurningRage;
ConVar cvarBurningRageFist;
ConVar cvarBurningRageDamage;
ConVar cvarBurningRageSpeed;

ConVar cvarHibernation;
ConVar cvarHibernationCooldown;
ConVar cvarHibernationDamage;
ConVar cvarHibernationDuration;
ConVar cvarHibernationRegen;
Handle cvarHibernationTimer[MAXPLAYERS+1] = INVALID_HANDLE;
Handle cvarHibernationCooldownTimer[MAXPLAYERS+1] = INVALID_HANDLE;

ConVar cvarPhantomTank;
ConVar cvarPhantomTankDuration;
Handle cvarPhantomTankTimer;
Handle cvarPhantomTankTimerAI;

ConVar cvarSmoulderingEarth;
ConVar cvarSmoulderingEarthDamage;
ConVar cvarSmoulderingEarthRange;
ConVar cvarSmoulderingEarthPower;
ConVar cvarSmoulderingEarthType;

ConVar cvarTitanFist;
ConVar cvarTitanFistIncap;
ConVar cvarTitanFistCooldown;
ConVar cvarTitanFistDamage;
ConVar cvarTitanFistPower;
ConVar cvarTitanFistRange;

ConVar cvarTitanicBellow;
ConVar cvarTitanicBellowCooldown;
ConVar cvarTitanicBellowHealth;
ConVar cvarTitanicBellowPower;
ConVar cvarTitanicBellowDamage;
ConVar cvarTitanicBellowRange;
ConVar cvarTitanicBellowType;

Handle PluginStartTimer = INVALID_HANDLE;
Handle cvarResetDelayTimer[MAXPLAYERS+1];

bool isBurningRage = false;
bool isBurningRageFist = false;
bool isFrustrated = false;
bool isHibernation = false;
bool isPhantomTank = false;
bool isSmoulderingEarth = false;
bool isTitanFist = false;
bool isTitanFistIncap = false;
bool isTitanicBellow = false;
bool isHibernating[MAXPLAYERS+1] = false;
bool isHibernationCooldown[MAXPLAYERS+1] = false;
bool buttondelay[MAXPLAYERS+1] = false;
bool isMapRunning = false;

float cooldownTitanFist[MAXPLAYERS+1] = 0.0;
float cooldownTitanicBellow[MAXPLAYERS+1] = 0.0;

public Plugin myinfo = 
{
    name = "[L4D2] Hulking Tank",
    author = "Mortiegama",
    description = "Brings a set of psychotic abilities to the Hulking Tank.",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?p=2105537#post2105537"
}

	//Special Thanks:
	//Karma - Tank Skill Roar
	//https://forums.alliedmods.net/showthread.php?t=126919
	
	//panxiaohai - Tank's Burning Rock
	//https://forums.alliedmods.net/showthread.php?t=139691
	
public void OnPluginStart()
{
	CreateConVar("l4d_htm_version", PLUGIN_VERSION, "Hulking Tank Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	cvarBurningRage = CreateConVar("l4d_htm_burningrage", "1", "Enables the Burning Rage ability, Tank's movement speed increases when on fire. (Def 1)", 0, true, 0.0, false, _);
	cvarBurningRageFist = CreateConVar("l4d_htm_burningragefist", "1", "Enables the Burning Rage Fist ability, Tank deals extra damage when on fire. (Def 1)", 0, true, 0.0, false, _);
	cvarBurningRageSpeed = CreateConVar("l4d_htm_burningragespeed", "1.25", "How much of a speed boost does Burning Rage give. (Def 1.25)", 0, true, 0.0, false, _);
	cvarBurningRageDamage = CreateConVar("l4d_htm_burningragedamage", "5", "Amount of extra damage done to Survivors while Tank is on fire. (Def 3)", 0, true, 0.0, false, _);

	cvarHibernation = CreateConVar("l4d_htm_hibernation", "1", "Enables the Hibernation ability, Tank stops to hibernate and will regenerate health while taking extra damage. (Def 1)", 0, true, 0.0, false, _);
	cvarHibernationCooldown = CreateConVar("l4d_htm_hibernationcooldown", "60", "Amount of time before the Tank can Hibernate again. (Def 120)", 0, true, 0.0, false, _);
	cvarHibernationDamage = CreateConVar("l4d_htm_hibernationdamage", "1.5", "Multiplier for damage received by Tank while Hibernating. (Def 2.0)", 0, true, 0.0, false, _);
	cvarHibernationDuration = CreateConVar("l4d_htm_hibernationduration", "20.0", "Amount of time the Hibernation will take before completion. (Def 10.0)", 0, true, 0.0, false, _);
	cvarHibernationRegen = CreateConVar("l4d_htm_hibernationregen", "9000.0", "Amount of health the Tank will be set to once done Hibernating. (Def 6000.0)", 0, true, 0.0, false, _);

	cvarPhantomTank = CreateConVar("l4d_htm_phantomtank", "1", "Enables the Phanton Tank ability, when spawning the Tank will be immune to damage and fire until a player takes control. (Def 1)", 0, true, 0.0, false, _);
	cvarPhantomTankDuration = CreateConVar("l4d_htm_phantomtankduration", "3.0", "Amount of time after a player takes control of the Tank that the damage and fire immunity ends. (Def 3.0)", 0, true, 0.0, false, _);

	cvarSmoulderingEarth = CreateConVar("l4d_htm_SmoulderingEarth", "1", "Enables the Smouldering Earth ability, Tank is able to throw a burning rock that explodes when hitting the ground. (Def 1)", 0, true, 0.0, false, _);
	cvarSmoulderingEarthDamage = CreateConVar("l4d_htm_smoulderingearthdamage", "7", "Damage the exploding rock causes nearby Survivors. (Def 7)", 0, true, 0.0, false, _);
	cvarSmoulderingEarthRange = CreateConVar("l4d_htm_smoulderingearthrange", "300.0", "Area around the exploding rock that will reach Survivors. (Def 300.0)", 0, true, 0.0, false, _);
	cvarSmoulderingEarthPower = CreateConVar("l4d_htm_smoulderingearthpower", "200.0", "Amount of power behind the explosion. (Def 200.0)", 0, true, 0.0, false, _);
	cvarSmoulderingEarthType = CreateConVar("l4d_htm_smoulderingearthtype", "2", "Type of rock thrown, 1 = Rock is always on fire, 2 = Rock only on fire if Tank is on fire.", 0, true, 1.0, true, 2.0);

	cvarTitanFist = CreateConVar("l4d_htm_titanfist", "1", "Enables the Titan Fist ability, Tank is able to send out shockwaves through the air with its fist. (Def 1)", 0, true, 0.0, false, _);
	cvarTitanFistIncap = CreateConVar("l4d_htm_titanfistincap", "1", "Enables the Titan Fist Incap ability, if a Survivor is incapped by the Tank punch they will still be flung. (Def 1)", 0, true, 0.0, false, _);
	cvarTitanFistCooldown = CreateConVar("l4d_htm_titanfistcooldown", "20", "Amount of time before the Tank can send another Titan Fist shockwave. (Def 15)", 0, true, 0.0, false, _);
	cvarTitanFistDamage = CreateConVar("l4d_htm_titanfistdamage", "10", "Amount of damage done to Survivors hit by the Titan Fist shockwave. (Def 5)", 0, true, 0.0, false, _);
	cvarTitanFistPower = CreateConVar("l4d_htm_titanfistpower", "200.0", "Force behind the Titan Fist shockwave. (Def 200.0)", 0, true, 0.0, false, _);
	cvarTitanFistRange = CreateConVar("l4d_htm_titanfistrange", "700.0", "Distance the Titan Fist shockwave will travel. (Def 700.0)", 0, true, 0.0, false, _);

	cvarTitanicBellow = CreateConVar("l4d_htm_titanicbellow", "1", "Enables the Titanic Bellow ability, Tank is able to roar and send nearby Survivors flying or pull them to the Tank. (Def 1)", 0, true, 0.0, false, _);
	cvarTitanicBellowCooldown = CreateConVar("l4d_htm_titanicbellowcooldown", "10.0", "Amount of time between Titanic Bellows. (Def 5.0)", 0, true, 0.0, false, _);
	cvarTitanicBellowHealth = CreateConVar("l4d_htm_titanicbellowhealth", "0", "Amount of health the Tank must be at (or below) to use Titanic Belllow (0 = disabled). (Def 0)", 0, true, 0.0, false, _);
	cvarTitanicBellowPower = CreateConVar("l4d_htm_titanicbellowpower", "300.0", "Power behind the inner range of Methane Blast. (Def 300.0)", 0, true, 0.0, false, _);
	cvarTitanicBellowDamage = CreateConVar("l4d_htm_titanicbellowdamage", "10", "Damage the force of the roar causes to nearby survivors. (Def 10)", 0, true, 0.0, false, _);
	cvarTitanicBellowRange = CreateConVar("l4d_htm_titanicbellowrange", "700.0", "Area around the Tank the bellow will reach. (Def 700.0)", 0, true, 0.0, false, _);
	cvarTitanicBellowType = CreateConVar("l4d_htm_titanicbellowtype", "1", "Type of roar, 1 = Survivors are pushed away from Tank, 2 = Survivors are pulled towards Tank.", 0, true, 1.0, true, 2.0);

	HookEvent("player_incapacitated", Event_PlayerIncap);
	HookEvent("tank_spawn", Event_TankSpawned);
	HookEvent("tank_frustrated", Event_TankFrustrated, EventHookMode_Pre);
	
	//AutoExecConfig(true, "plugin.L4D2.HulkingTank");
	PluginStartTimer = CreateTimer(3.0, OnPluginStart_Delayed);
}

public Action OnPluginStart_Delayed(Handle timer)
{	
	if (GetConVarInt(cvarBurningRage))
	{
		isBurningRage = true;
	}
	
	if (GetConVarInt(cvarBurningRageFist))
	{
		isBurningRageFist = true;
	}
	
	if (GetConVarInt(cvarHibernation))
	{
		isHibernation = true;
	}
	
	if (GetConVarInt(cvarPhantomTank))
	{
		isPhantomTank = true;
	}
	
	if (GetConVarInt(cvarSmoulderingEarth))
	{
		isSmoulderingEarth = true;
	}
	
	if (GetConVarInt(cvarTitanFist))
	{
		isTitanFist = true;
	}
	
	if (GetConVarInt(cvarTitanFistIncap))
	{
		isTitanFistIncap = true;
	}
	
	if (GetConVarInt(cvarTitanicBellow))
	{
		isTitanicBellow = true;
	}
	
	laggedMovementOffset = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");
	frustrationOffset = FindSendPropInfo("Tank","m_frustration");
	
	if(PluginStartTimer != INVALID_HANDLE)
	{
 		KillTimer(PluginStartTimer);
		PluginStartTimer = INVALID_HANDLE;
	}
	
	return Plugin_Stop;
}

public void OnMapStart()
{
	PrecacheParticle("gas_explosion_pump");
	isMapRunning = true;
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action Event_TankSpawned(Event event, const char[] name, bool dontBroadcast)
{
	int tank = GetClientOfUserId(GetEventInt(event, "userid"));
	if (isPhantomTank && IsValidClient(tank) && GetClientTeam(tank) == 3)
	{
		if (IsFakeClient(tank) && !isFrustrated)
		{
			SetEntityMoveType(tank, MOVETYPE_NONE);
			SetEntProp(tank, Prop_Data, "m_fFlags", GetEntProp(tank, Prop_Data, "m_fFlags") | FL_GODMODE);
			SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
			SetEntityRenderColor(tank, 255, 255, 255, 0);
			cvarPhantomTankTimerAI = CreateTimer(6.0, Timer_PhantomTankAI);
			aiTank = tank;
		}
		
		if (!IsFakeClient(tank) && !isFrustrated)
		{
			SetEntityMoveType(tank, MOVETYPE_WALK);
			SetEntProp(tank, Prop_Data, "m_fFlags", GetEntProp(tank, Prop_Data, "m_fFlags") | FL_GODMODE);
			cvarPhantomTankTimer = CreateTimer(GetConVarFloat(cvarPhantomTankDuration), Timer_PhantomTank);
			aiTank = 0;
		}
	}
	isFrustrated = false;
}

public Action Event_TankFrustrated(Event event, const char[] name, bool dontBroadcast)
{
	isFrustrated = true;
}

public Action Timer_PhantomTank(Handle timer) //extinguishes  a tank, and resets it's health
{
	PhantomTankRemoval();
	
	if (cvarPhantomTankTimer != INVALID_HANDLE)
	{
		KillTimer(cvarPhantomTankTimer);
		cvarPhantomTankTimer = INVALID_HANDLE;
	}

	return Plugin_Stop;
}

public Action Timer_PhantomTankAI(Handle timer) //Thaws an AI tank, it will only fire after 5 seconds which means it was not passed to a player.  Either because of no player infected, or being passed to AI
{
	if (!aiTank || !IsValidTank(aiTank) || !IsFakeClient(aiTank))
	{
		aiTank = 0;
		return Plugin_Stop;
	}
	
	PhantomTankRemoval();
	aiTank = 0;
	
	if (IsValidTank(aiTank))
	{
		SetEntityMoveType(aiTank, MOVETYPE_WALK);
	}
	
	if (cvarPhantomTankTimerAI != INVALID_HANDLE)
	{
		KillTimer(cvarPhantomTankTimerAI);
		cvarPhantomTankTimerAI = INVALID_HANDLE;
	}	
	
	return Plugin_Stop;
}

static void PhantomTankRemoval()
{
	for (int tank = 1; tank <= MaxClients; tank++)
	{
		if (IsValidTank(tank))
		{
			SetEntityMoveType(aiTank, MOVETYPE_WALK);
			SetEntProp(tank, Prop_Data, "m_fFlags", GetEntProp(tank, Prop_Data, "m_fFlags") & ~FL_GODMODE);
			SetEntityRenderColor(tank, 255, 255, 255, 255);
			ExtinguishEntity(tank);
		}
	}
}

// ===========================================
// Tank Ability - Burning Rage
// ===========================================
// Description: When on fire the Tank can move faster and hit harder.

public Action OnTakeDamage(int victim, int  &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidTank(victim))
	{
		if (isBurningRage)
		{
			if ((damagetype == 8 || damagetype == 2056 || damagetype == 268435464))
			{
				SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamage);
				PrintHintText(victim, "You're on fire, your Burning Rage has increased your speed!");
				SetEntDataFloat(victim, laggedMovementOffset, 1.0*GetConVarFloat(cvarBurningRageSpeed), true);
				return Plugin_Handled;
			}
		}
		
		if (isHibernating[victim])
		{
			float damagemod = GetConVarFloat(cvarHibernationDamage);
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage * damagemod;
			}
		}
	}

	if (isBurningRageFist && IsValidTank(attacker))
	{
		if (IsPlayerOnFire(attacker) && IsValidClient(victim) && GetClientTeam(victim) == 2)
		{
			float damagemod = GetConVarFloat(cvarBurningRageDamage);
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage + damagemod;
			}
		}
	}

	return Plugin_Changed;
}

public Action Timer_Hibernation(Handle timer, any client)
{
	Reset_Hibernation(client);

	if (IsValidTank(client))
	{
		int TankHP = GetConVarInt(cvarHibernationRegen);
		SetEntProp(client, Prop_Send, "m_iHealth", TankHP, 1);
	}

	if (cvarHibernationTimer[client] != INVALID_HANDLE)
	{
		KillTimer(cvarHibernationTimer[client]);
		cvarHibernationTimer[client] = INVALID_HANDLE;
	}
	
	return Plugin_Stop;
}

public Action Timer_HibernationCooldown(Handle timer, any client)
{
	isHibernationCooldown[client] = false;

	if(cvarHibernationCooldownTimer[client] != INVALID_HANDLE)
	{
		KillTimer(cvarHibernationCooldownTimer[client]);
		cvarHibernationCooldownTimer[client] = INVALID_HANDLE;
	}	

	return Plugin_Stop;	
}

public void Reset_Hibernation(int client)
{
	KillProgressBar(client);
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntData(client, frustrationOffset, 1);
	isHibernating[client] = false;
}

stock void SetupProgressBar(int client, float time)
{
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", time);
}

stock void KillProgressBar(int client)
{
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", 0.0);
}
				
// ===========================================
// Tank Ability - Titan Fist
// ===========================================
// Description: The Tank's swing will also hit any Survivors in range.

public void  Event_PlayerIncap(Event event, char[] event_name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event,"userid"));
	int client = GetClientOfUserId(GetEventInt(event,"attacker"));
	
	char weapon[16];
	GetEventString(event, "weapon", weapon, 16);
	if(!StrEqual(weapon, "tank_claw")){return;}
	
	if(isTitanFistIncap && IsValidTank(client) && !IsPlayerGhost(client))
	{
		if (IsValidClient(victim) && GetClientTeam(victim) == 2  && !IsSurvivorPinned(victim))
		{
			float tankPos[3];
			float survivorPos[3];
			GetClientEyePosition(client, tankPos);
			GetClientEyePosition(victim, survivorPos);

			char sRadius[256];
			char sPower[256];
			int magnitude = GetConVarInt(cvarTitanFistPower);
			IntToString(GetConVarInt(cvarTitanFistRange), sRadius, sizeof(sRadius));
			IntToString(magnitude, sPower, sizeof(sPower));
			int exPhys = CreateEntityByName("env_physexplosion");
	
			//Set up physics movement explosion
			DispatchKeyValue(exPhys, "radius", sRadius);
			DispatchKeyValue(exPhys, "magnitude", sPower);
			DispatchSpawn(exPhys);
			TeleportEntity(exPhys, tankPos, NULL_VECTOR, NULL_VECTOR);
					
			//BOOM!
			AcceptEntityInput(exPhys, "Explode");

			float traceVec[3], ResultingVec[3], CurrentVelVec[3];
			float power = GetConVarFloat(cvarTitanFistPower);
			MakeVectorFromPoints(tankPos, survivorPos, traceVec);				// draw a line from car to Survivor
			GetVectorAngles(traceVec, ResultingVec);							// get the angles of that line

			ResultingVec[0] = Cosine(DegToRad(ResultingVec[1])) * power;	// use trigonometric magic
			ResultingVec[1] = Sine(DegToRad(ResultingVec[1])) * power;
			ResultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;

			GetEntPropVector(victim, Prop_Data, "m_vecVelocity", CurrentVelVec);		// add whatever the Survivor had before
			ResultingVec[0] += CurrentVelVec[0];
			ResultingVec[1] += CurrentVelVec[1];
			ResultingVec[2] += CurrentVelVec[2];
			
			Fling_TitanFist(victim, ResultingVec, client);
		}
	}
}

// CTerrorPlayer::Fling(Vector  const&, PlayerAnimEvent_t, CBaseCombatCharacter *, float)
stock void Fling_TitanFist(int victim, float vector[3], int attacker, float incaptime = 3.0)
{
	Handle MySDKCall = INVALID_HANDLE;
	Handle ConfigFile = LoadGameConfigFile(GAMEDATA_FILENAME);
	
	StartPrepSDKCall(SDKCall_Player);
	bool bFlingFuncLoaded = PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_Fling");
	if(!bFlingFuncLoaded)
	{
		LogError("Could not load the Fling signature");
	}
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);

	MySDKCall = EndPrepSDKCall();
	if(MySDKCall == INVALID_HANDLE)
	{
		LogError("Could not prep the Fling function");
	}
	
	SDKCall(MySDKCall, victim, vector, 76, attacker, incaptime); //76 is the 'got bounced' animation in L4D2
	Damage_TitanFist(attacker, victim);
}

public Action Damage_TitanFist(int attacker, int victim)
{
	int damage = GetConVarInt(cvarTitanFistDamage);
	float victimPos[3];
	char StrDamage[16], StrDamageTarget[16];
			
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, StrDamage, sizeof(StrDamage));
	Format(StrDamageTarget, sizeof(StrDamageTarget), "hurtme%d", victim);
	
	int entPointHurt = CreateEntityByName("point_hurt");
	if(!entPointHurt) return;

	// Config, create point_hurt
	DispatchKeyValue(victim, "targetname", StrDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", StrDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", StrDamage);
	DispatchKeyValue(entPointHurt, "DamageType", "0"); // DMG_GENERIC
	DispatchSpawn(entPointHurt);
	
	// Teleport, activate point_hurt
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (attacker && attacker < MaxClients && IsClientInGame(attacker)) ? attacker : -1);
	
	// Config, delete point_hurt
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	RemoveEdict(entPointHurt);
	
	PrintHintText(attacker, "Your Titan Claw inflicted %i damage.", damage);
	PrintHintText(victim, "You were hit with Titan Claw, causing %i damage and sending you flying.", damage);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(buttons & IN_ATTACK && IsValidTank(client) && !IsPlayerGhost(client))
	{
		if (isTitanFist && IsTitanFistReady(client) && !isHibernating[client])
		{
			cooldownTitanFist[client] = GetEngineTime();
			for (int victim = 1; victim <= MaxClients; victim++)

			if (IsValidClient(victim) && GetClientTeam(victim) == 2  && !IsSurvivorPinned(victim))
			{
				float tankPos[3];
				float survivorPos[3];
				float distance;
				float range = GetConVarFloat(cvarTitanFistRange);
				GetClientEyePosition(client, tankPos);
				GetClientEyePosition(victim, survivorPos);
				distance = GetVectorDistance(survivorPos, tankPos);
								
				if (distance < range)
				{
					char sRadius[256];
					char sPower[256];
					int magnitude = GetConVarInt(cvarTitanFistPower);
					IntToString(GetConVarInt(cvarTitanFistRange), sRadius, sizeof(sRadius));
					IntToString(magnitude, sPower, sizeof(sPower));
					int exPhys = CreateEntityByName("env_physexplosion");
	
					//Set up physics movement explosion
					DispatchKeyValue(exPhys, "radius", sRadius);
					DispatchKeyValue(exPhys, "magnitude", sPower);
					DispatchSpawn(exPhys);
					TeleportEntity(exPhys, tankPos, NULL_VECTOR, NULL_VECTOR);
					
					//BOOM!
					AcceptEntityInput(exPhys, "Explode");
	
					float traceVec[3], ResultingVec[3], CurrentVelVec[3];
					float power = GetConVarFloat(cvarTitanFistPower);
					MakeVectorFromPoints(tankPos, survivorPos, traceVec);				// draw a line from car to Survivor
					GetVectorAngles(traceVec, ResultingVec);							// get the angles of that line
					
					ResultingVec[0] = Cosine(DegToRad(ResultingVec[1])) * power;	// use trigonometric magic
					ResultingVec[1] = Sine(DegToRad(ResultingVec[1])) * power;
					ResultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
					
					GetEntPropVector(victim, Prop_Data, "m_vecVelocity", CurrentVelVec);		// add whatever the Survivor had before
					ResultingVec[0] += CurrentVelVec[0];
					ResultingVec[1] += CurrentVelVec[1];
					ResultingVec[2] += CurrentVelVec[2];
					
					Fling_TitanFist(victim, ResultingVec, client);
				}
			}
		}

		if (isHibernating[client])
		{
			buttons &= ~IN_ATTACK;
		}
	}
	
	if(buttons & IN_ATTACK2 && IsValidTank(client) && isHibernating[client])
	{
		buttons &= ~IN_ATTACK2;
	}
	
	if (buttons & IN_ATTACK2 && aiTank && client == aiTank && IsFakeClient(aiTank) && IsValidTank(aiTank))
	{
		buttons &= ~IN_ATTACK2;
	}
	
	if ((buttons & IN_ZOOM) && IsValidTank(client) && !IsPlayerGhost(client) && !isHibernating[client]) 
	{
		if (isTitanicBellow && IsTitanicBellowReady(client) && !isHibernating[client])
		{
			int ReqHP = GetConVarInt(cvarTitanicBellowHealth);
			int HP = GetClientHealth(client);
			
			if (ReqHP > 0 && HP > ReqHP)
			{
				PrintHintText(client, "Your health must be below %i before you can use Titanic Bellow.", ReqHP);
				return;
			}
			
			cooldownTitanicBellow[client] = GetEngineTime();			
			for (int victim=1; victim<=MaxClients; victim++)

			if (IsValidClient(victim) && GetClientTeam(victim) == 2  && !IsSurvivorPinned(victim))
			{
				float tankPos[3];
				float survivorPos[3];
				float distance;
				float range = GetConVarFloat(cvarTitanicBellowRange);
				GetClientEyePosition(client, tankPos);
				GetClientEyePosition(victim, survivorPos);
				distance = GetVectorDistance(survivorPos, tankPos);
								
				if (distance < range)
				{
					char sRadius[256];
					char sPower[256];
					int RoarType = GetConVarInt(cvarTitanicBellowType);
					int magnitude;
					if (RoarType == 1) magnitude = GetConVarInt(cvarTitanicBellowPower);
					if (RoarType == 2) magnitude = GetConVarInt(cvarTitanicBellowPower) * -1;
					IntToString(GetConVarInt(cvarTitanicBellowRange), sRadius, sizeof(sRadius));
					IntToString(magnitude, sPower, sizeof(sPower));
					int exPhys = CreateEntityByName("env_physexplosion");
	
					//Set up physics movement explosion
					DispatchKeyValue(exPhys, "radius", sRadius);
					DispatchKeyValue(exPhys, "magnitude", sPower);
					DispatchSpawn(exPhys);
					TeleportEntity(exPhys, tankPos, NULL_VECTOR, NULL_VECTOR);
					
					//BOOM!
					AcceptEntityInput(exPhys, "Explode");
	
					float traceVec[3], ResultingVec[3], CurrentVelVec[3];
					float power = GetConVarFloat(cvarTitanicBellowPower);
					MakeVectorFromPoints(tankPos, survivorPos, traceVec);				// draw a line from car to Survivor
					GetVectorAngles(traceVec, ResultingVec);							// get the angles of that line
					
					ResultingVec[0] = Cosine(DegToRad(ResultingVec[1])) * power;	// use trigonometric magic
					ResultingVec[1] = Sine(DegToRad(ResultingVec[1])) * power;
					ResultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
					
					GetEntPropVector(victim, Prop_Data, "m_vecVelocity", CurrentVelVec);		// add whatever the Survivor had before
					ResultingVec[0] += CurrentVelVec[0];
					ResultingVec[1] += CurrentVelVec[1];
					ResultingVec[2] += CurrentVelVec[2];
					
					if (RoarType == 2)
					{
						ResultingVec[0] = ResultingVec[0] * -1;
						ResultingVec[1] = ResultingVec[1] * -1;
					}
					
					Fling_TitanicBellow(victim, ResultingVec, client);
				}
			}
		}
	}
	
	if(buttons & IN_USE && isHibernation)
	{
		if (IsValidTank(client) && !isHibernating[client] && !buttondelay[client] && !isHibernationCooldown[client])
		{
			isHibernating[client] = true;
			isHibernationCooldown[client] = true;
			buttondelay[client] = true;
			
			SetEntityMoveType(client, MOVETYPE_NONE);
			SetEntData(client, frustrationOffset, 0);
			SetupProgressBar(client, GetConVarFloat(cvarHibernationDuration));
					
			cvarHibernationCooldownTimer[client] = CreateTimer(GetConVarFloat(cvarHibernationCooldown), Timer_HibernationCooldown, client);
			cvarHibernationTimer[client] = CreateTimer(GetConVarFloat(cvarHibernationDuration), Timer_Hibernation, client);
			cvarResetDelayTimer[client] = CreateTimer(1.0, ResetDelay, client);
			
			PrintHintText(client, "You are Hibernating.");
		}
		
		if (IsValidTank(client) && isHibernating[client] && !buttondelay[client])
		{
			Reset_Hibernation(client);
			buttondelay[client] = true;
			cvarResetDelayTimer[client] = CreateTimer(1.0, ResetDelay, client);
		}
	}
}

public Action ResetDelay(Handle timer, any client)
{
	buttondelay[client] = false;
	
	if (cvarResetDelayTimer[client] != INVALID_HANDLE)
	{
		KillTimer(cvarResetDelayTimer[client]);
		cvarResetDelayTimer[client] = INVALID_HANDLE;
	}
	
	return Plugin_Stop;
}

stock void Fling_TitanicBellow(int target, float vector[3], int attacker, float incaptime = 3.0)
{
	Handle MySDKCall = INVALID_HANDLE;
	Handle ConfigFile = LoadGameConfigFile(GAMEDATA_FILENAME);
	
	StartPrepSDKCall(SDKCall_Player);
	bool bFlingFuncLoaded = PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_Fling");
	if(!bFlingFuncLoaded)
	{
		LogError("Could not load the Fling signature");
	}
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);

	MySDKCall = EndPrepSDKCall();
	if(MySDKCall == INVALID_HANDLE)
	{
		LogError("Could not prep the Fling function");
	}
	
	SDKCall(MySDKCall, target, vector, 76, attacker, incaptime); //76 is the 'got bounced' animation in L4D2 // 96 95 98 80 81 back  82 84  jump 86 roll 87 88 91 92 jump 93 
	Damage_TitanicBellow(attacker, target);
}

public Action Damage_TitanicBellow(int client, int victim)
{
	int damage = 0;
	damage = GetConVarInt(cvarTitanicBellowDamage);
	float victimPos[3];
	char StrDamage[16], StrDamageTarget[16];
			
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, StrDamage, sizeof(StrDamage));
	Format(StrDamageTarget, sizeof(StrDamageTarget), "hurtme%d", victim);
	
	int entPointHurt = CreateEntityByName("point_hurt");
	if(!entPointHurt) return;

	// Config, create point_hurt
	DispatchKeyValue(victim, "targetname", StrDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", StrDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", StrDamage);
	DispatchKeyValue(entPointHurt, "DamageType", "0"); // DMG_GENERIC
	DispatchSpawn(entPointHurt);
	
	// Teleport, activate point_hurt
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (client && client < MaxClients && IsClientInGame(client)) ? client : -1);
	
	// Config, delete point_hurt
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	RemoveEdict(entPointHurt);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(isSmoulderingEarth && StrEqual(classname, "tank_rock", true))
	{
		if(IsValidEntity(entity) && IsValidEdict(entity))
		{
			int RockType = GetConVarInt(cvarSmoulderingEarthType);
			switch(RockType)
			{
				case 1:
				{
					IgniteEntity(entity, 100.0);
				}
				case 2:
				{
					int tank = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
					if (IsValidTank(tank) && IsPlayerOnFire(tank))
					{
						IgniteEntity(entity, 100.0);
					}
				}
			}
		}
	}
}

public void OnEntityDestroyed(int entity)
{	
	if(isSmoulderingEarth && isMapRunning)
	{	
		if(IsValidEntity(entity) && IsValidEdict(entity) && IsPlayerOnFire(entity))
		{
			char classname[24];
			GetEdictClassname(entity, classname, 24);
			
			if (StrEqual(classname, "tank_rock", false) == true)
			{
				float entityPos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
				ShowParticle(entityPos, "gas_explosion_pump", 3.0);
				//PrintToChatAll("Entity Position: %f.", entityPos);

				int tank = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
				if (IsValidTank(tank))
				{
					for (int victim = 1; victim <= MaxClients; victim++)
			
					if (IsValidClient(victim) && GetClientTeam(victim) == 2)
					{
						float victimPos[3];
						GetClientEyePosition(victim, victimPos);
						float distance;
						float range = GetConVarFloat(cvarSmoulderingEarthRange);
						distance = GetVectorDistance(entityPos, victimPos);
						//PrintToChatAll("Distance: %f attacker: %n", distance, victim);
						
						if (distance <= range)
						{
							char sRadius[256];
							char sPower[256];
							int magnitude = GetConVarInt(cvarSmoulderingEarthPower);
							IntToString(GetConVarInt(cvarSmoulderingEarthRange), sRadius, sizeof(sRadius));
							IntToString(magnitude, sPower, sizeof(sPower));
							int exPhys = CreateEntityByName("env_physexplosion");
			
							//Set up physics movement explosion
							DispatchKeyValue(exPhys, "radius", sRadius);
							DispatchKeyValue(exPhys, "magnitude", sPower);
							DispatchSpawn(exPhys);
							TeleportEntity(exPhys, entityPos, NULL_VECTOR, NULL_VECTOR);
							
							//BOOM!
							AcceptEntityInput(exPhys, "Explode");
			
							float traceVec[3], resultingVec[3], currentVelVec[3];
							float power = GetConVarFloat(cvarSmoulderingEarthPower);
							MakeVectorFromPoints(entityPos, victimPos, traceVec);				// draw a line from car to Survivor
							GetVectorAngles(traceVec, resultingVec);							// get the angles of that line
							
							resultingVec[0] = Cosine(DegToRad(resultingVec[1])) * power;	// use trigonometric magic
							resultingVec[1] = Sine(DegToRad(resultingVec[1])) * power;
							resultingVec[2] = power * SLAP_VERTICAL_MULTIPLIER;
							
							GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
							resultingVec[0] += currentVelVec[0];
							resultingVec[1] += currentVelVec[1];
							resultingVec[2] += currentVelVec[2];
							
							Fling_SmoulderingEarth(victim, resultingVec, tank);
						}
					}
				}
			}
		}
	}
}

stock void Fling_SmoulderingEarth(int victim, float vector[3], int attacker, float incaptime = 3.0)
{
	Handle MySDKCall = INVALID_HANDLE;
	Handle ConfigFile = LoadGameConfigFile(GAMEDATA_FILENAME);
	
	StartPrepSDKCall(SDKCall_Player);
	bool bFlingFuncLoaded = PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_Fling");
	if(!bFlingFuncLoaded)
	{
		LogError("Could not load the Fling signature");
	}
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);

	MySDKCall = EndPrepSDKCall();
	if(MySDKCall == INVALID_HANDLE)
	{
		LogError("Could not prep the Fling function");
	}
	
	SDKCall(MySDKCall, victim, vector, 76, attacker, incaptime); //76 is the 'got bounced' animation in L4D2
	Damage_SmoulderingEarth(attacker, victim);
}

public Action Damage_SmoulderingEarth(int attacker, int victim)
{
	int damage = GetConVarInt(cvarSmoulderingEarthDamage);
	float victimPos[3];
	char strDamage[16], strDamageTarget[16];
			
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, strDamage, sizeof(strDamage));
	Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", victim);
	
	int entPointHurt = CreateEntityByName("point_hurt");
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
	RemoveEdict(entPointHurt);
}

// ----------------------------------------------------------------------------
// ClientViews()
// ----------------------------------------------------------------------------
stock bool ClientViews(int Viewer, int Target, float fMaxDistance = 0.0, float fThreshold = 0.73)
{
	// Retrieve view and target eyes position
	float fViewPos[3];   GetClientEyePosition(Viewer, fViewPos);
	float fViewAng[3];   GetClientEyeAngles(Viewer, fViewAng);
	float fViewDir[3];
	float fTargetPos[3]; GetClientEyePosition(Target, fTargetPos);
	float fTargetDir[3];
	float fDistance[3];
	float fMinDistance = 100.0;

	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);
	
	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
			return false;
	}
	
	if (fMinDistance != -0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) < (fMinDistance*fMinDistance))
			return false;
	}
	
	// Check dot product. If it's negative, that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold) return false;
	
	// Now check if there are no obstacles in between through raycasting
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace)) { CloseHandle(hTrace); return false; }
	CloseHandle(hTrace);

	// Done, it's visible
	return true;
}

// ----------------------------------------------------------------------------
// ClientViewsFilter()
// ----------------------------------------------------------------------------
public bool ClientViewsFilter(int Entity, int Mask, any Junk)
{
	if (Entity >= 1 && Entity <= MaxClients) return false;
	return true;
}
		
public void ShowParticle(float victimPos[3], char[] particlename, float time)
{
	int particle = CreateEntityByName("info_particle_system");
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
 
public void PrecacheParticle(char[] particlename)
{
	int particle = CreateEntityByName("info_particle_system");
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

public Action DeleteParticles(Handle timer, any particle)
{
	if (IsValidEntity(particle))
	{
		char classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "stop");
			AcceptEntityInput(particle, "kill");
			RemoveEdict(particle);
		}
	}
}

public void OnMapEnd()
{
	isMapRunning = false;
}

public int IsValidClient(int client)
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

public int IsValidDeadClient(int client)
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

public int IsValidTank(int client)
{
	if (IsValidClient(client) && GetClientTeam(client) == 3)
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == ZOMBIECLASS_TANK)
			return true;
		return false;
	}
	return false;
}

public int IsPlayerOnFire(int client)
{
	if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE) return true;
	else return false;
}

public int IsPlayerGhost(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost")) return true;
	else return false;
}

public int IsTitanFistReady(int client)
{
	return ((GetEngineTime() - cooldownTitanFist[client]) > GetConVarFloat(cvarTitanFistCooldown));
}

public int IsTitanicBellowReady(int client)
{
	return ((GetEngineTime() - cooldownTitanicBellow[client]) > GetConVarFloat(cvarTitanicBellowCooldown));
}

public int IsSurvivorPinned(int client)
{
	int attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
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