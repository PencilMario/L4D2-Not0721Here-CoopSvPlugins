#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required
#define L4D2 Destructive Hunter
#define PLUGIN_VERSION "1.13"
#define ZOMBIECLASS_HUNTER 3

char GAMEDATA_FILENAME[]				= "l4d2_viciousplugins";
char VELOCITY_ENTPROP[]				= "m_vecVelocity";
float SLAP_VERTICAL_MULTIPLIER			= 1.5;
Handle cvarInfernoClaw;
Handle cvarInfernoClawDamage;
Handle cvarKevlarSkin;
Handle cvarKevlarSkinTimer[MAXPLAYERS+1];
Handle cvarLashingClaw;
Handle cvarLashingClawChance;
Handle cvarLashingClawDamage;
Handle cvarLashingClawRange;
Handle cvarLashingClawPower;
Handle cvarLashingClawTimer[MAXPLAYERS+1];
Handle cvarSledgehammer;
Handle cvarSledgehammerCap;
Handle cvarSledgehammerMultiplier;
Handle cvarShunpo;
Handle cvarShunpoAmount;
Handle cvarShunpoCooldown;
Handle cvarShunpoDuration;
Handle cvarShunpoTimer[MAXPLAYERS+1];
Handle cvarShurikenClaw;
Handle cvarShurikenClawCooldown;
Handle cvarShurikenClawDamage;
Handle cvarShurikenClawRange;
Handle cvarShurikenClawIgnite;
Handle cvarShurikenClawIgniteChance;
Handle cvarShurikenClawIgniteDamage;
Handle cvarShurikenClawIgniteDuration;
Handle cvarShurikenClawIgniteTimer[MAXPLAYERS+1];
Handle cvarAnnounce;
Handle PluginStartTimer;
bool isAnnounce = false;
bool isSledgehammer = false;
bool isShunpo = false;
bool isShurikenClaw = false;
bool isShurikenClawIgnite = false;
bool isLashingClaw = false;
bool isInfernoClaw = false;
bool isKevlarSkin = false;
float startPosition[MAXPLAYERS+1][3];
float endPosition[MAXPLAYERS+1][3];
float cooldownShunpo[MAXPLAYERS+1] = { 0.0 };
float cooldownShurikenClaw[MAXPLAYERS+1] = { 0.0 };
int scignite[MAXPLAYERS+1];

public Plugin myinfo = 
{
    name = "[L4D2] Destructive Hunter",
    author = "Mortiegama",
    description = "Allows for unique Hunter abilities to the destructive beast.",
    version = PLUGIN_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?p=2097674#post2097674"
}

	//Special Thanks:
	//n3wton - Jockey Pounce Damage:
	//http://forums.alliedmods.net/showthread.php?p=1172322
	
public void OnPluginStart()
{
	CreateConVar("l4d_dhm_version", PLUGIN_VERSION, "Destructive Hunter Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvarInfernoClaw = CreateConVar("l4d_dhm_infernoclaw", "1", "Enables the ability Inferno Claw which adds extra damage to Survivors when Hunter is on fire. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarInfernoClawDamage = CreateConVar("l4d_dhm_infernoclawdamage", "3", "Amount of extra damage caused by Inferno Claw. (Def 3)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarKevlarSkin = CreateConVar("l4d_dhm_kevlarskin", "1", "Enables the ability Kevlar Skin, which allows the Hunter to take reduced damage from fire. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarLashingClaw = CreateConVar("l4d_dhm_lashingclaw", "1", "Enables the ability for the Hunter to lash at nearby survivors while pounced, sending the breaker flying and hurting them. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarLashingClawChance = CreateConVar("l4d_dhm_lashingclawchance", "15", "Chance that a Survivor will be hit from the Hunter's Lashing Claws. (Def 15)(15 = 15%)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarLashingClawDamage = CreateConVar("l4d_dhm_lashingclawdamage", "7", "Amount of damage the Lashing Claws will cause. (Def 7)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarLashingClawRange = CreateConVar("l4d_dhm_lashingclawrange", "400.0", "Distance the Hunter's Lashing Claws reach while pounced. (Def 400.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarLashingClawPower = CreateConVar("l4d_dhm_lashingclawpower", "200.0", "Power behind the Lashing Claws. (Def 200.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarSledgehammer = CreateConVar("l4d_dhm_sledgehammer", "1", "Enables the ability for the Hunter to inflict damage based on the distance of the pounce. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarSledgehammerCap = CreateConVar("l4d_dhm_sledgehammercap", "100", "Maximum amount of damage the Hunter can inflict while pouncing. (Should be Survivor health max). (Def 100)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarSledgehammerMultiplier = CreateConVar("l4d_dhm_sledgehammermultiplier", "1.0", "Amount to multiply the damage dealt by the Hunter when pouncing. (Def 1.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShunpo = CreateConVar("l4d_dhm_shunpo", "1", "Enables the ability for the Hunter to activate Shunpo when taking damage. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShunpoAmount = CreateConVar("l4d_dhm_shunpoamount", "0.2", "Percent of damage the Hunter avoids while using Shunpo. (Def 0.2)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShunpoCooldown = CreateConVar("l4d_dhm_shunpocooldown", "5.0", "Cooldown period after the Shunpo has been used before the next Shunpo. (Def 5.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShunpoDuration = CreateConVar("l4d_dhm_shunpoduration", "3.0", "Amount of time the Shunpo will last. (Def 3.0)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClaw = CreateConVar("l4d_dhm_shurikenclaw", "1", "Enables the ability for the Hunter to throw Shuriken Claws at the Survivor. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClawCooldown = CreateConVar("l4d_dhm_shurikenclawcooldown", "1.5", "Amount of time between Shuriken Claw throws. (Def 1.5)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClawDamage = CreateConVar("l4d_dhm_shurikenclawdamage", "2", "Amount of damage the Shuriken Claws deal to Survivors that are hit. (Def 2)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClawRange = CreateConVar("l4d_dhm_shurikenclawrange", "700", "Distance the Hunter is able to throw the Shuriken Claws. (Def 700)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClawIgnite = CreateConVar("l4d_vts_shurikenclawignite", "1", "Allows the Hunter to ignite Survivors with Shuriken Claw while on fire. (Def 1)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClawIgniteChance = CreateConVar("l4d_vts_shurikenclawignitechance", "50", "Chance that the Shuriken Claw will ignite a Survivor. (50 = 50%). (Def 50)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarShurikenClawIgniteDuration = CreateConVar("l4d_vts_shurikenclawigniteduration", "6", "For how many seconds will the Survivor remain ignited. (Def 6)", FCVAR_NOTIFY, true, 1.0, false, _);
	cvarShurikenClawIgniteDamage = CreateConVar("l4d_vts_shurikenclawignitedamage", "2", "How much damage is by the flames each second. (Def 2)", FCVAR_NOTIFY, true, 0.0, false, _);
	cvarAnnounce = CreateConVar("l4d_dhm_announce", "1", "Will annoucements be made to the Survivors?");
	HookEvent("lunge_pounce", Event_LungePounce);
	HookEvent("ability_use", Event_AbilityUse);
	HookEvent("player_death", Event_PlayerDeath);
	//AutoExecConfig(true, "plugin.L4D2.DestructiveHunter");
	PluginStartTimer = CreateTimer(3.0, OnPluginStart_Delayed);
}

public Action OnPluginStart_Delayed(Handle timer)
{
	if (GetConVarInt(cvarInfernoClaw))
	{
		isInfernoClaw = true;
	}
	if (GetConVarInt(cvarKevlarSkin))
	{
		isKevlarSkin= true;
	}
	if (GetConVarInt(cvarLashingClaw))
	{
		isLashingClaw = true;
	}
	if (GetConVarInt(cvarShurikenClaw))
	{
		isShurikenClaw = true;
	}
	if (GetConVarInt(cvarShurikenClawIgnite))
	{
		isShurikenClawIgnite = true;
	}
	if (GetConVarInt(cvarShunpo))
	{
		isShunpo = true;
	}
	if (GetConVarInt(cvarSledgehammer))
	{
		isSledgehammer = true;
	}
	if (GetConVarInt(cvarAnnounce))
	{
		isAnnounce = true;
	}
	if (PluginStartTimer != null)
	{
 		KillTimer(PluginStartTimer);
		PluginStartTimer = null;
	}
	return Plugin_Stop;
}

public void OnMapStart()
{
	PrecacheParticle("fire_small_01");
	PrecacheParticle("fire_small_base");
	PrecacheParticle("fire_small_flameouts");
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

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsValidDeadHunter(client))
	{
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage_KevlarSkin);
	}
	
	return Plugin_Continue;
}

public Action Event_AbilityUse(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsValidClient(client))
	{
		char infAbility[24];
		GetEventString(event, "ability", infAbility, 24);
		
		if (StrEqual(infAbility, "ability_lunge", false) == true)
		{
			GetClientAbsOrigin(client, startPosition[client]);
		}
	}
	
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidHunter(victim))
	{
		if (isShunpo && IsValidClient(attacker) && IsShunpoReady(victim))
		{
			float damagemod = GetConVarFloat(cvarShunpoAmount);
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage * damagemod;
			}
			cvarShunpoTimer[victim] = CreateTimer(GetConVarFloat(cvarShunpoDuration), Timer_Shunpo, victim);
			PrintHintText(victim, "你激活了瞬步，受到的伤害减半。");
		}
		if ((damagetype == 8 || damagetype == 2056 || damagetype == 268435464) && isKevlarSkin)
		{
			damage = 0.0;
			SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamage);
			cvarKevlarSkinTimer[victim] = CreateTimer(0.2, Timer_KevlarSkin, victim);
			return Plugin_Handled;
		}
	}
	if (IsValidHunter(attacker))
	{
		if (isInfernoClaw && IsPlayerOnFire(attacker) && IsValidClient(victim))
		{
			float damagemod = GetConVarFloat(cvarInfernoClawDamage);			
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage + damagemod;
			}
		}
	}
	return Plugin_Changed;
}

public Action OnTakeDamage_KevlarSkin(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (damagetype == 8 || damagetype == 2056 || damagetype == 268435464)
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Timer_KevlarSkin(Handle timer, any victim)
{
	SDKHook(victim, SDKHook_OnTakeDamage, OnTakeDamage_KevlarSkin);
	IgniteEntity(victim, 6000.0);
	if (cvarKevlarSkinTimer[victim] != null)
	{
		KillTimer(cvarKevlarSkinTimer[victim]);
		cvarKevlarSkinTimer[victim] = null;
	}			
	return Plugin_Stop;
}

public Action Event_LungePounce(Event event, const char[] name, bool dontBrodcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));
	if (IsValidClient(client) && IsValidClient(victim))
	{
		if (isSledgehammer)
		{
			Sledgehammer(client, victim);
		}
		if (isLashingClaw)
		{
			cvarLashingClawTimer[client] = CreateTimer(1.0, Timer_LashingClaw, client, TIMER_REPEAT);
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_LashingClaw(Handle timer, any attacker)
{
	if (!IsValidClient(attacker) || GetClientTeam(attacker) != 3 || !IsHunterPounced(attacker))
	{
		if (cvarLashingClawTimer[attacker] != null)
		{
			KillTimer(cvarLashingClawTimer[attacker]);
			cvarLashingClawTimer[attacker] = null;
		}
		return Plugin_Stop;
	}
	for (int victim=1; victim<=MaxClients; victim++)
	if (IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == 2 && IsHunterPounced(attacker))
	{
		int pouncee = GetEntPropEnt(attacker, Prop_Send, "m_pounceVictim");
		int LashingClawChance = GetRandomInt(0, 99);
		int LashingClawPercent = (GetConVarInt(cvarLashingClawChance));
		if (victim != pouncee && LashingClawChance <= LashingClawPercent)
		{
			float v_pos[3];
			GetClientEyePosition(victim, v_pos);		
			float targetVector[3];
			float distance;
			float range = GetConVarFloat(cvarLashingClawRange);
			GetClientEyePosition(attacker, targetVector);
			distance = GetVectorDistance(targetVector, v_pos);
			if (distance <= range)
			{
				float HeadingVector[3];
				float AimVector[3];
				float power = GetConVarFloat(cvarLashingClawPower);
				GetClientEyeAngles(attacker, HeadingVector);
				AimVector[0] = Cosine(DegToRad(HeadingVector[1])) * power;
				AimVector[1] = Sine(DegToRad(HeadingVector[1])) * power;
				float current[3];
				GetEntPropVector(victim, Prop_Data, VELOCITY_ENTPROP, current);
				float resulting[3];
				resulting[0] = current[0] + AimVector[0];	
				resulting[1] = current[1] + AimVector[1];
				resulting[2] = power * SLAP_VERTICAL_MULTIPLIER;
				Fling_LashingClaw(victim, resulting, attacker);
			}
		}
	}
	return Plugin_Continue;
}

stock void Fling_LashingClaw(int victim, float vector[3], int attacker, float incaptime = 3.0)
{
	Handle MySDKCall;
	Handle ConfigFile = LoadGameConfigFile(GAMEDATA_FILENAME);
	StartPrepSDKCall(SDKCall_Player);
	bool bFlingFuncLoaded = PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_Fling");
	if (!bFlingFuncLoaded)
	{
		LogError("Could not load the Fling signature");
	}
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	if (MySDKCall == null)
	{
		LogError("Could not prep the Fling function");
	}
	SDKCall(MySDKCall, victim, vector, 76, attacker, incaptime);
	Damage_LashingClaw(attacker, victim);
}

public Action Damage_LashingClaw(int attacker, int victim)
{
	int damage = GetConVarInt(cvarLashingClawDamage);
	HurtEntity(victim, attacker, float(damage));
/* 	float victimPos[3];
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
	DispatchKeyValue(entPointHurt, "DamageType", "0");
	DispatchSpawn(entPointHurt);
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (attacker && attacker < MaxClients && IsClientInGame(attacker)) ? attacker : -1);
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	AcceptEntityInput(entPointHurt, "kill");
 */	if (isAnnounce) 
	{
		PrintHintText(attacker, "你的爪子击中了一个生还者，造成了%i点伤害。", damage);
		PrintHintText(victim, "你被Hunter的爪子鞭打，造成了%i点伤害。", damage);	
	}
	return Plugin_Continue;
}

void Sledgehammer(int client, int victim)
{
	GetClientAbsOrigin(client, endPosition[client]);
	int distance = RoundFloat(GetVectorDistance(startPosition[client], endPosition[client]));
	int damage = RoundFloat(distance * 0.02);
	int maxdamage = GetConVarInt(cvarSledgehammerCap);
	float multiplier = GetConVarFloat(cvarSledgehammerMultiplier);
	damage = RoundFloat(damage * multiplier);
	if (damage < 0.0)
	{
		return;
	}
	if (damage > maxdamage)
	{
		damage = maxdamage;
	}
	HurtEntity(victim, client, float(damage));
/* 	float victimPos[3];
	char strDamage[16];
	char strDamageTarget[16];
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, strDamage, sizeof(strDamage));
	Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", victim);
	int entPointHurt = CreateEntityByName("point_hurt");
	if (!IsValidEntity(entPointHurt) || !IsValidEdict(entPointHurt))
	{
		return;
	}
	HurtEntity(victim, client, damage)
	DispatchKeyValue(victim, "targetname", strDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", strDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", strDamage);
	DispatchKeyValue(entPointHurt, "DamageType", "0");
	DispatchSpawn(entPointHurt);
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (client && client < MaxClients && IsClientInGame(client)) ? client : -1);
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	AcceptEntityInput(entPointHurt, "kill");
 */	if (isAnnounce) 
	{
		PrintHintText(client, "你跃过了%i距离到达生还者身上，造成了%i点伤害。", distance, damage);
		PrintHintText(victim, "一个Jockey跃过了%i距离到你身上，造成了%i点伤害。", distance, damage);	
	}
}

public Action Timer_Shunpo(Handle timer, any client)
{
	if (IsValidClient(client))
	{
		PrintHintText(client, "你的瞬步效果已消失，你将受到全额伤害。");
		cooldownShunpo[client] = GetEngineTime();
	}
	if (cvarShunpoTimer[client] != null)
	{
		KillTimer(cvarShunpoTimer[client]);
		cvarShunpoTimer[client] = null;
	}
	return Plugin_Stop;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (buttons & IN_ATTACK2 && IsValidClient(client) && GetClientTeam(client) == 3 && IsValidHunter(client) && !IsPlayerGhost(client))
	{
		if (isShurikenClaw && IsShurikenClawReady(client) && !IsHunterPounced(client))
		{
			float range = GetConVarFloat(cvarShurikenClawRange);
			for (int victim=1; victim<=MaxClients; victim++)
			if (IsValidClient(victim) && GetClientTeam(victim) == 2 && ClientViews(client, victim, range))
			{
				float attackerPos[3];
				float victimPos[3];
				GetClientEyePosition(client, attackerPos);
				GetClientEyePosition(victim, victimPos);
				ShowParticle(attackerPos, "hunter_claw_child_spray", 3.0);	
				ShowParticle(victimPos, "hunter_claw_child_spray", 3.0);	
				Damage_ShurikenClaw(client, victim);
				cooldownShurikenClaw[client] = GetEngineTime();
				if (isShurikenClawIgnite && IsPlayerOnFire(client))
				{
					CreateParticle(victim, "fire_small_01", 10.0);
					ShurikenClawIgnite(victim, client);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Damage_ShurikenClaw(int client, int victim)
{
	float damage = GetConVarFloat(cvarShurikenClawDamage);
	HurtEntity(victim, client, damage);
	if (isAnnounce) 
	{
		PrintHintText(client, "你的手里剑爪造成了%.0f点伤害。", damage);
		PrintHintText(victim, "你被手里剑爪击中，造成了%.0f点伤害。", damage);
	}
	return Plugin_Continue;
}
void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_GENERIC);
}
void ShurikenClawIgnite(int victim, int attacker)
{
	int ShurikenClawIgniteChance = GetRandomInt(0, 99);
	int ShurikenClawIgnitePercent = (GetConVarInt(cvarShurikenClawIgniteChance));
	if (IsValidClient(victim) && GetClientTeam(victim) == 2 && ShurikenClawIgniteChance < ShurikenClawIgnitePercent)
	{
		if (scignite[victim] <= 0)
		{
			scignite[victim] = (GetConVarInt(cvarShurikenClawIgniteDuration));
			Handle dataPack = CreateDataPack();
			cvarShurikenClawIgniteTimer[victim] = CreateDataTimer(1.0, Timer_ShurikenClawIgnite, dataPack, TIMER_REPEAT);
			WritePackCell(dataPack, victim);
			WritePackCell(dataPack, attacker);
		}
	}
}

public Action Timer_ShurikenClawIgnite(Handle timer, any dataPack) 
{
	ResetPack(dataPack);
	int victim = ReadPackCell(dataPack);
	int attacker = ReadPackCell(dataPack);
	if (IsValidClient(victim))
	{
		if (scignite[victim] <= 0)
		{
			if (cvarShurikenClawIgniteTimer[victim] != null)
			{
				KillTimer(cvarShurikenClawIgniteTimer[victim]);
				cvarShurikenClawIgniteTimer[victim] = null;
			}
			return Plugin_Stop;
		}
		Damage_ShurikenClawIgnite(victim, attacker);
		if (scignite[victim] > 0) 
		{
			scignite[victim] -= 1;
		}
	}
	return Plugin_Continue;
}

public Action Damage_ShurikenClawIgnite(int victim, int attacker)
{
	int damage = GetConVarInt(cvarShurikenClawIgniteDamage);
	HurtEntity(victim, attacker, float(damage));
/* 	float victimPos[3];
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
	AcceptEntityInput(entPointHurt, "Hurt", (attacker && attacker < MaxClients && IsClientInGame(attacker)) ? attacker : -1);
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	AcceptEntityInput(entPointHurt, "kill"); */
	return Plugin_Continue;
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
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold)
	{
		return false;
	}
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace))
	{
		delete hTrace;
		return false;
	}
	delete hTrace;
	return true;
}

public bool ClientViewsFilter(int entity, int ask, any junk)
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

void PrecacheParticle(char[] particlename)
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
		}
	}
	return Plugin_Continue;
}

int CreateParticle(int victim, char[] particlename, float time)
{
	int entity = CreateEntityByName("info_particle_system");
	DispatchKeyValue(entity, "effect_name", particlename);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Start");
	SetVariantString("!activator"); 
	AcceptEntityInput(entity, "SetParent", victim);
	SetVariantString("forward");
	AcceptEntityInput(entity, "SetParentAttachment");
	float vPos[3];
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("OnUser1 !self:Stop::2.9:-1");
	AcceptEntityInput(entity, "AddOutput");
	SetVariantString("OnUser1 !self:FireUser2::3:-1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
	SetVariantString("OnUser2 !self:Start::0:-1");
	AcceptEntityInput(entity, "AddOutput");
	SetVariantString("OnUser2 !self:FireUser1::0:-1");
	AcceptEntityInput(entity, "AddOutput");
	time = GetConVarFloat(cvarShurikenClawIgniteDuration);
	CreateTimer(time, DeleteParticles, entity, TIMER_FLAG_NO_MAPCHANGE);
	return EntIndexToEntRef(entity);
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client));
}

bool IsValidDeadClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsPlayerAlive(client));
}

bool IsValidHunter(int client)
{
	if (IsValidClient(client))
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == ZOMBIECLASS_HUNTER)
		{
			return true;
		}
	}
	return false;
}

bool IsValidDeadHunter(int client)
{
	if (IsValidDeadClient(client))
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == ZOMBIECLASS_HUNTER)
		{
			return true;
		}
	}
	return false;
}

bool IsPlayerGhost(int client)
{
	if (IsValidClient(client))
	{
		if (GetEntProp(client, Prop_Send, "m_isGhost"))
		{
			return true;
		}
	}
	return false;
}

bool IsHunterPounced(int client)
{
	int victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
	if (victim > 0 && victim != client)
	{
		return true;
	}
	return false;
}

bool IsShunpoReady(int client)
{
	return ((GetEngineTime() - cooldownShunpo[client]) > GetConVarFloat(cvarShunpoCooldown));
}

bool IsShurikenClawReady(int client)
{
	return ((GetEngineTime() - cooldownShurikenClaw[client]) > GetConVarFloat(cvarShurikenClawCooldown));
}

bool IsPlayerOnFire(int client)
{
	if (IsValidClient(client))
	{
		if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE)
		{
			return true;
		}
	}
	return false;
}