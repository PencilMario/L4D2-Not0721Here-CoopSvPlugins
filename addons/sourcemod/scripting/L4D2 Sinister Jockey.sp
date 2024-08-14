#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required
#define L4D2 Sinister Jockey
#define PLUGIN_VERSION "1.3"
#define ZOMBIECLASS_JOCKEY 5


Handle PluginStartTimer;
Handle cvarBacterialFeet;
Handle cvarBacterialFeetRide;
Handle cvarBacterialFeetRideSpeed;
Handle cvarBacterialFeetSpeed;
Handle cvarBacterialFeetTimer[MAXPLAYERS+1];
Handle cvarGhostStalker;
Handle cvarGhostStalkerVisibility;
Handle cvarGravityPounce;
Handle cvarGravityPounceCap;
Handle cvarGravityPounceMultiplier;
Handle cvarHumanShield;
Handle cvarHumanShieldAmount;
Handle cvarHumanShieldDamage;
Handle cvarMarionette;
Handle cvarMarionetteCooldown;
Handle cvarMarionetteDuration;
Handle cvarMarionetteRange;
Handle cvarMarionetteTimer[MAXPLAYERS + 1];
int marionette[MAXPLAYERS+1];
float cooldownMarionette[MAXPLAYERS+1];
Handle cvarRodeoJump;
Handle cvarRodeoJumpPower;
bool isRiding[MAXPLAYERS + 1] = { false };
bool isAnnounce = true;
bool isBacterialFeet = false;
bool isBacterialFeetRide = false;
bool isGhostStalker = false;
bool isGravityPounce = false;
bool isHumanShield = false;
bool isMarionette = false;
bool isRodeoJump = false;
float startPosition[MAXPLAYERS+1][3];
float endPosition[MAXPLAYERS+1][3];
Handle cvarResetDelayTimer[MAXPLAYERS+1];
bool buttondelay[MAXPLAYERS+1];
bool isMarionetteJockey[MAXPLAYERS+1];
bool isMarionetteSurvivor[MAXPLAYERS+1];
int laggedMovementOffset = 0;

public Plugin myinfo = 
{
    name = "[L4D2] Sinister Jockey",
    author = "Mortiegama",
    description = "Allows for unique Jockey abilities to empower the small tyrant.",
    version = PLUGIN_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?p=2091791#post2091791"
}

	//Special Thanks:
	//n3wton - Jockey Pounce Damage:
	//http://forums.alliedmods.net/showthread.php?p=1172322
	
public void OnPluginStart()
{
	CreateConVar("l4d_sjm_version", PLUGIN_VERSION, "Jockey Human Shield Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvarBacterialFeet = CreateConVar("l4d_sjm_bacterialfeet", "1", "Enables the Bacterial Feet ability, the slick coating of Bacteria on the Jockeys feet allows it to move faster. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarBacterialFeetRide = CreateConVar("l4d_sjm_bacterialfeetride", "1", "Enables the Bacterial Feet Ride ability, the Jockey coats the Survivor with bacteria allowing it to ride faster. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarBacterialFeetRideSpeed = CreateConVar("l4d_sjm_bacterialfeetridespeed", "1.5", "Speed increase for the Jockey receives from running. (Def 1.5)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarBacterialFeetSpeed = CreateConVar("l4d_sjm_bacterialfeetspeed", "1.5", "Speed increase the Jockey receives while riding a Survivor. (Def 1.5)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarGhostStalker = CreateConVar("l4d_sjm_ghoststalker", "1", "Enables the ability for the Jockey to use the Survivor as a human shiled while riding. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarGhostStalkerVisibility = CreateConVar("l4d_sjm_ghoststalkervisibility", "20", "Modifies the opacity of the Jockey to become closer to invisible (0-255) (Def 20)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarGravityPounce = CreateConVar("l4d_sjm_gravitypounce", "1", "Enables the ability for the Jockey to inflict damage based on how far he drops on a Survivor. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarGravityPounceCap = CreateConVar("l4d_sjm_gravitypouncecap", "100", "Maximum amount of damage the Jockey can inflict while dropping (Should be Survivor health max). (Def 100)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarGravityPounceMultiplier = CreateConVar("l4d_sjm_gravitypouncemultiplier", "1.0", "Amount to multiply the damage dealt by the Jockey when dropping. (Def 1.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarHumanShield = CreateConVar("l4d_sjm_humanshield", "1", "Enables the ability for the Jockey to use the Survivor as a human shiled while riding. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarHumanShieldAmount = CreateConVar("l4d_sjm_humanshieldamount", "0.4", "Percent of damage the Jockey avoids using a Survivor as a shield. (Def 0.4)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarHumanShieldDamage = CreateConVar("l4d_sjm_humanshielddamage", "2", "How much damage is inflicted to the Survivor being used as a Huamn Shield. (Def 2)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarMarionette = CreateConVar("l4d_sjm_marionette", "1", "Enables the Marionette ability: While pressing the Use key, the Survivor becomes immobilized. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarMarionetteCooldown = CreateConVar("l4d_sjm_marionettecooldown", "20.0", "Amount of time between Marionette abilities. (Def 20.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarMarionetteDuration = CreateConVar("l4d_sjm_marionetteduration", "6.0", "Duration of time the Marionette ability will last. (Def 6.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarMarionetteRange = CreateConVar("l4d_sjm_marionetterange", "700.0", "Distance the Jockey is able to Marionette a Survivor. (Def 700.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarRodeoJump = CreateConVar("l4d_sjm_rodeojump", "1", "Enables the Rodeo Jump ability, Jockey is able to jump while riding a Survivor. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarRodeoJumpPower = CreateConVar("l4d_sjm_rodeojumppower", "400.0", "Power behind the Jockey's jump. (Def 400.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_jump", Event_JockeyJump);
	HookEvent("jockey_ride", Event_JockeyRideStart);
	HookEvent("jockey_ride_end", Event_JockeyRideEnd);
	laggedMovementOffset = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");
	//AutoExecConfig(true, "plugin.L4D2.SinisterJockey");
	PluginStartTimer = CreateTimer(3.0, OnPluginStart_Delayed);
}
	
public Action OnPluginStart_Delayed(Handle timer)
{
	if (GetConVarInt(cvarBacterialFeet))
	{
		isBacterialFeet = true;
	}
	if (GetConVarInt(cvarBacterialFeetRide))
	{
		isBacterialFeetRide = true;
	}
	if (GetConVarInt(cvarGhostStalker))
	{
		isGhostStalker = true;
	}
	if (GetConVarInt(cvarGravityPounce))
	{
		isGravityPounce = true;
	}
	if (GetConVarInt(cvarHumanShield))
	{
		isHumanShield = true;
	}
	if (GetConVarInt(cvarMarionette))
	{
		isMarionette = true;
	}
	if (GetConVarInt(cvarRodeoJump))
	{
		isRodeoJump = true;
	}
	if(PluginStartTimer != null)
	{
 		KillTimer(PluginStartTimer);
		PluginStartTimer = null;
	}
	return Plugin_Stop;
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBrodcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidJockey(client))
	{
		PrintHintText(client, "Press and hold only the USE button to activate the Marionette ability.");
		if (isGhostStalker)
		{
			int Opacity = GetConVarInt(cvarGhostStalkerVisibility);
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, 255, 255, 255, Opacity);
		}
		if (isBacterialFeet)
		{
			cvarBacterialFeetTimer[client] = CreateTimer(0.5, Timer_BacterialFeet, client);
		}
	}
	return Plugin_Continue;
}

public Action Timer_BacterialFeet(Handle timer, any client) 
{
	if (IsValidClient(client))
	{
		PrintHintText(client, "Bacterial Feet has granted you increased movement speed!");
		SetEntDataFloat(client, laggedMovementOffset, 1.0*GetConVarFloat(cvarBacterialFeetSpeed), true);
	}
	if(cvarBacterialFeetTimer[client] != null)
	{
 		KillTimer(cvarBacterialFeetTimer[client]);
		cvarBacterialFeetTimer[client] = null;
	}
	return Plugin_Stop;	
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBrodcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidDeadJockey(client))
	{
		isMarionetteJockey[client] = false;
	}
	return Plugin_Continue;
}

public Action Event_JockeyJump(Event event, const char[] name, bool dontBrodcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidJockey(client) && isGravityPounce)
	{
		GetClientAbsOrigin(client, startPosition[client]);
	}
	return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (IsValidClient(entity) && StrEqual(classname, "infected", false))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidJockey(victim))
	{
		if (isHumanShield && isRiding[victim] && IsValidClient(attacker))
		{
			float damagemod = GetConVarFloat(cvarHumanShieldAmount);
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage * damagemod;
			}
			int shield = GetEntPropEnt(victim, Prop_Send, "m_jockeyVictim");
			if (IsValidClient(shield))
			{
				Damage_HumanShield(victim, shield);
			}
		}
	}
	return Plugin_Changed;
}
	
public Action Event_JockeyRideStart(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));
	if (IsValidClient(client) && IsValidClient(victim))
	{
		isRiding[client] = true;
		if (isBacterialFeetRide)
		{
			SetEntDataFloat(victim, laggedMovementOffset, 1.0*GetConVarFloat(cvarBacterialFeetRideSpeed), true);
		}
		if (isGravityPounce)
		{
			GetClientAbsOrigin(client, endPosition[client]);
			int distance = RoundFloat(startPosition[client][2] - endPosition[client][2]);
			int damage = RoundFloat(distance * 0.4);
			int maxdamage = GetConVarInt(cvarGravityPounceCap);
			float multiplier = GetConVarFloat(cvarGravityPounceMultiplier);
			damage = RoundFloat(damage * multiplier);
			if (damage < 0.0)
			{
				return Plugin_Continue;
			}
			if (damage > maxdamage)
			{
				damage = maxdamage;
			}
			float victimPos[3];
			char strDamage[16];
			char strDamageTarget[16];
			GetClientEyePosition(victim, victimPos);
			IntToString(damage, strDamage, sizeof(strDamage));
			Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", victim);
			int entPointHurt = CreateEntityByName("point_hurt");
			if (!IsValidEntity(entPointHurt) || !IsValidEdict(entPointHurt))
			{
				DispatchKeyValue(victim, "targetname", strDamageTarget);
				DispatchKeyValue(entPointHurt, "DamageTarget", strDamageTarget);
				DispatchKeyValue(entPointHurt, "Damage", strDamage);
				DispatchKeyValue(entPointHurt, "DamageType", "0"); // DMG_GENERIC
				DispatchSpawn(entPointHurt);
				TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
				AcceptEntityInput(entPointHurt, "Hurt", (client && client < MaxClients && IsClientInGame(client)) ? client : -1);
				DispatchKeyValue(entPointHurt, "classname", "point_hurt");
				DispatchKeyValue(victim, "targetname", "null");
				AcceptEntityInput(entPointHurt, "kill");
				if (isAnnounce) 
				{
					PrintHintText(client, "You dropped %i distance on a Survivor, causing %i damage.", distance, damage);
					PrintHintText(victim, "A Jockey dropped %i distance on you, causing %i damage.", distance, damage);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_JockeyRideEnd(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));
	if (IsValidClient(client))
	{
		isRiding[client] = false;
	}
	if (isBacterialFeetRide && IsValidClient(victim))
	{
		SetEntDataFloat(victim, laggedMovementOffset, 1.0, true);
	}
	return Plugin_Continue;
}

public Action Damage_HumanShield(int client, int victim)
{
	int damage = GetConVarInt(cvarHumanShieldDamage);
	float victimPos[3];
	char strDamage[16];
	char strDamageTarget[16];		
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, strDamage, sizeof(strDamage));
	Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", victim);
	int entPointHurt = CreateEntityByName("point_hurt");
	if (!IsValidEntity(entPointHurt) || !IsValidEdict(entPointHurt))

	DispatchKeyValue(victim, "targetname", strDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", strDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", strDamage);
	DispatchKeyValue(entPointHurt, "DamageType", "0"); // DMG_GENERIC
	DispatchSpawn(entPointHurt);
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (client && client < MaxClients && IsClientInGame(client)) ? client : -1);
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	AcceptEntityInput(entPointHurt, "kill");
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (buttons & IN_USE && !isRiding[client] && IsValidClient(client) && GetClientTeam(client) == 3)
	{
		if (isMarionette && IsMarionetteReady(client) && !buttondelay[client])
		{
			float range = GetConVarFloat(cvarMarionetteRange);
			for (int victim = 1; victim <= MaxClients; victim++)
			{
				if (marionette[victim] <= 0 && IsValidClient(victim) && GetClientTeam(victim) == 2 && ClientViews(client, victim, range))
				{
					MarionetteStart(client, victim);
					marionette[victim] = (GetConVarInt(cvarMarionetteDuration) + 1);
					Handle dataPack = CreateDataPack();
					cvarMarionetteTimer[victim] = CreateDataTimer(1.0, Timer_Marionette, dataPack, TIMER_REPEAT);
					WritePackCell(dataPack, victim);
					WritePackCell(dataPack, client);
					return Plugin_Stop;
				}
			}
		}
	}

	if ((buttons & ~IN_USE || !buttons) && isMarionetteJockey[client])
	{
		isMarionetteJockey[client] = false;
	}

	if (buttons & IN_JUMP && isRiding[client] && IsValidClient(client) && GetClientTeam(client) == 3)
	{
		int victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
		if (isRodeoJump && IsPlayerOnGround(client) && IsValidClient(victim) && !buttondelay[client])
		{
			buttondelay[client] = true;
			float velo[3];
			velo[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
			velo[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
			velo[2] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[2]");
			if (vel[2] != 0)
			{
				return Plugin_Stop;
			}
			float vec[3];
			vec[0] = velo[0];
			vec[1] = velo[1];
			vec[2] = velo[2] + GetConVarFloat(cvarRodeoJumpPower);
			cvarResetDelayTimer[client] = CreateTimer(1.0, ResetDelay, client);
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vec);
		}
	}
	return Plugin_Continue;
}

public Action Timer_Marionette(Handle timer, any dataPack) 
{
	ResetPack(dataPack);
	int victim = ReadPackCell(dataPack);
	int client = ReadPackCell(dataPack);
	if (IsValidClient(victim))
	{
		if(marionette[victim] <= 0 || !isMarionetteJockey[client])
		{
			if (cvarMarionetteTimer[victim] != null)
			{
				KillTimer(cvarMarionetteTimer[victim]);
				cvarMarionetteTimer[victim] = null;
			}
			MarionetteStop(client, victim);
			return Plugin_Stop;
		}
		if(marionette[victim] > 0) 
		{
			marionette[victim] -= 1;
			float attackerPos[3];
			float victimPos[3];
			GetClientEyePosition(client, attackerPos);
			GetClientEyePosition(victim, victimPos);
			ShowParticle(attackerPos, "electrical_arc_01_system", 1.0);	
			ShowParticle(victimPos, "electrical_arc_01_system", 1.0);	
		}
	}	
	return Plugin_Continue;
}

void MarionetteStart(int client, int victim)
{
	buttondelay[client] = true;
	cvarResetDelayTimer[client] = CreateTimer(1.0, ResetDelay, client);
	cooldownMarionette[client] = GetEngineTime();
	isMarionetteJockey[client] = true;
	isMarionetteSurvivor[victim] = true;
	SetEntityMoveType(victim, MOVETYPE_NONE);
	float time = GetConVarFloat(cvarMarionetteDuration);
	SetupProgressBar(client, time);
	float attackerPos[3];
	float victimPos[3];
	GetClientEyePosition(client, attackerPos);
	GetClientEyePosition(victim, victimPos);
	ShowParticle(attackerPos, "electrical_arc_01_system", 1.0);	
	ShowParticle(victimPos, "electrical_arc_01_system", 1.0);	
	char playername[64];
	GetClientName(victim, playername, sizeof(playername));
	PrintToChatAll("Player \x05%s \x01has been adjusted.", playername);
}

void MarionetteStop(int client, int victim)
{
	isMarionetteJockey[client] = false;
	isMarionetteSurvivor[victim] = false;
	KillProgressBar(client);
	SetEntityMoveType(victim, MOVETYPE_WALK); 
}

public Action ResetDelay(Handle timer, any client)
{
	buttondelay[client] = false;
	if (cvarResetDelayTimer[client] != null)
	{
		KillTimer(cvarResetDelayTimer[client]);
		cvarResetDelayTimer[client] = null;
	}
	return Plugin_Stop;
}

stock bool ClientViews(int Viewer, int Target, float fMaxDistance=0.0, float fThreshold=0.73)
{
	float fViewPos[3];
	GetClientEyePosition(Viewer, fViewPos);
	float fViewAng[3];
	GetClientEyeAngles(Viewer, fViewAng);
	float fViewDir[3];
	float fTargetPos[3];
	GetClientEyePosition(Target, fTargetPos);
	float fTargetDir[3];
	float fDistance[3];
	float fMinDistance = 100.0;
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
		{
			return false;
		}
	}
	if (fMinDistance != -0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) < (fMinDistance*fMinDistance))
		{
			return false;
		}
	}
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold) return false;
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace))
	{
		delete hTrace;
		return false;
	}
	delete hTrace;
	return true;
}

public bool ClientViewsFilter(int entity, int mask, any junk)
{
	if (entity >= 1 && entity <= MaxClients)
	{
		return false;
	}
	return true;
}

void ShowParticle(float victimPos[3], char[] particlename, float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(particle))
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
		}
	}
	return Plugin_Continue;
}

public void OnMapEnd()
{
	for (int client=1; client<=MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			isRiding[client] = false;
			isMarionetteJockey[client] = false;
			isMarionetteSurvivor[client] = false;
			marionette[client] = 0;
		}
	}
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client));
}

bool IsValidDeadClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsPlayerAlive(client));
}

bool IsValidJockey(int client)
{
	if (IsValidClient(client) && GetClientTeam(client) == 3)
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == ZOMBIECLASS_JOCKEY)
		{
			return true;
		}
	}
	return false;
}

bool IsValidDeadJockey(int client)
{
	if (IsValidDeadClient(client))
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == ZOMBIECLASS_JOCKEY)
		{
			return true;
		}
	}
	return false;
}

bool IsPlayerOnGround(int client)
{
	if (GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND)
	{
		return true;
	}
	return false;
}

void SetupProgressBar(int client, float time)
{
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", time);
}

void KillProgressBar(int client)
{
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", 0.0);
}

bool IsMarionetteReady(int client)
{
	return ((GetEngineTime() - cooldownMarionette[client]) > GetConVarFloat(cvarMarionetteCooldown));
}