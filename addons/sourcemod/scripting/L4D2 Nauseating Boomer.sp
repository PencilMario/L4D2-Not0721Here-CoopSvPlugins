#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required
#define L4D2 Nauseating Boomer
#define PLUGIN_VERSION				"1.2a"

#define STRING_LENGHT				56
#define ZOMBIECLASS_BOOMER 			2
#define TRANSLATIONS_FILENAME		"L4D2 Nauseating Boomer.phrases"

char GAMEDATA_FILENAME[]				= "l4d2_viciousplugins";
char VELOCITY_ENTPROP[]					= "m_vecVelocity";
float SLAP_VERTICAL_MULTIPLIER			= 1.5;
float TRACE_TOLERANCE 					= 25.0;

bool isBileBelly = false;

Handle cvarBileBelly;
Handle cvarBileBellyAmount;

bool isBileBlast = false;

Handle cvarBileBlast;
Handle cvarBileBlastInnerPower;
Handle cvarBileBlastOuterPower;
Handle cvarBileBlastInnerDamage;
Handle cvarBileBlastOuterDamage;
Handle cvarBileBlastInnerRange;
Handle cvarBileBlastOuterRange;

bool isBileFeet = false;

Handle cvarBileFeet;
Handle cvarBileFeetSpeed;
Handle cvarBileFeetTimer[MAXPLAYERS+1] = { INVALID_HANDLE };

bool isBileMask = false;
bool isBileMaskTilDry = false;

Handle cvarBileMask;
Handle cvarBileMaskState;
Handle cvarBileMaskAmount;
Handle cvarBileMaskDuration;
Handle cvarBileMaskTimer[MAXPLAYERS + 1];

bool isBilePimple = false;

Handle cvarBilePimple;
Handle cvarBilePimpleChance;
Handle cvarBilePimpleDamage;
Handle cvarBilePimpleRange;
Handle cvarBilePimpleTimer[MAXPLAYERS+1];

bool isBileShower = false;
bool isBileShowerTimeout;

Handle cvarBileShower;
Handle cvarBileShowerTimeout;
Handle cvarBileShowerTimer[MAXPLAYERS + 1];

bool isBileSwipe = false;

Handle cvarBileSwipe;
Handle cvarBileSwipeChance;
Handle cvarBileSwipeDamage;
Handle cvarBileSwipeDuration;
Handle cvarBileSwipeTimer[MAXPLAYERS + 1];

int bileswipe[MAXPLAYERS+1];

bool isBileThrow = false;

Handle cvarBileThrow;
Handle cvarBileThrowCooldown;
Handle cvarBileThrowDamage;
Handle cvarBileThrowRange;

bool isExplosiveDiarrhea = true;

Handle cvarExplosiveDiarrhea;
Handle cvarExplosiveDiarrheaRange;

bool isFlatulence = true;

Handle cvarFlatulence;
Handle cvarFlatulenceChance;
Handle cvarFlatulenceCooldown;
Handle cvarFlatulenceDamage;
Handle cvarFlatulenceDuration;
Handle cvarFlatulencePeriod;
Handle cvarFlatulenceRadius;
Handle ConfigFile;
Handle cvarFlatulenceTimer[MAXPLAYERS+1];
Handle cvarFlatulenceTimerCloud[MAXPLAYERS+1];

Handle PluginStartTimer;
Handle sdkCallVomitOnPlayer;
Handle sdkCallFling;

float cooldownBileThrow[MAXPLAYERS+1] = { 0.0 };

int laggedMovementOffset = 0;

public Plugin myinfo =
{
	name = "[L4D2] Nauseating Boomer",
	author = "Mortiegama",
	description = "Allows for unique Boomer abilities to spread its nauseating bile.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=2094483#post2094483"
}

	//Special Thanks:
	//AtomicStryker - Boomer Bit** Slap:
	//https://forums.alliedmods.net/showthread.php?t=97952

	//Special Thanks:
	//AtomicStryker - Smoker Cloud Damage:
	//https://forums.alliedmods.net/showthread.php?t=97952

void LoadPluginTranslations()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, PLATFORM_MAX_PATH, "translations/%s.txt", TRANSLATIONS_FILENAME);
	if (FileExists(sPath))
		LoadTranslations(TRANSLATIONS_FILENAME);
	else
		SetFailState("Missing required translation file on 'translations/%s.txt', please re-download.", TRANSLATIONS_FILENAME);
}

public void OnPluginStart()
{
	LoadPluginTranslations();

	CreateConVar("l4d_nbm_version", PLUGIN_VERSION, "Nauseating Boomer Version", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY);

	cvarBileBelly = CreateConVar("l4d_nbm_bilebelly", "1", "Enables Bile Belly ability: Due to the bulbous bile filled belly, it is hard to cause direct damage to the Boomer. (Def 1)");
	cvarBileBellyAmount = CreateConVar("l4d_nbm_bilebellyamount", "0.5", "Percent of damage the Boomer avoids thanks to it's belly. (Def 0.5)");

	cvarBileBlast = CreateConVar("l4d_nbm_bileblast", "1", "Enables Bile Blast ability: Due to bile and methane building up, when the Boomer dies the pressure releases causing a shockwave to damage and send Survivors flying. (Def 1)");
	cvarBileBlastInnerPower = CreateConVar("l4d_nbm_bileblastinnerpower", "200.0", "Power behind the inner range of Bile Blast. (Def 200.0)");
	cvarBileBlastOuterPower = CreateConVar("l4d_nbm_bileblastouterpower", "100.0", "Power behind the outer range of Bile Blast. (Def 100.0)");
	cvarBileBlastInnerDamage = CreateConVar("l4d_nbm_bileblastinnerdamage", "15", "Amount of damage caused in the inner range of Bile Blast. (Def 15)");
	cvarBileBlastOuterDamage = CreateConVar("l4d_nbm_bileblastouterdamage", "5", "Amount of damage caused in the outer range of Bile Blast. (Def 5)");
	cvarBileBlastInnerRange = CreateConVar("l4d_nbm_bileblastinnerrange", "250.0", "Range the inner blast radius will extend from Bile Blast. (Def 200.0)");
	cvarBileBlastOuterRange = CreateConVar("l4d_nbm_bileblastouterrange", "400.0", "Range the outer blast radius will extend from Bile Blast. (Def 300.0)");

	cvarBileFeet = CreateConVar("l4d_nbm_bilefeet", "1", "Enables Bile Feet ability: A slick coating of bile on its body allows the Boomer to move with increased speed. (Def 1)");
	cvarBileFeetSpeed = CreateConVar("l4d_nbm_bilefeetspeed", "1.5", "How much does Bile Feet increase the Boomer movement speed. (Def 1.5)");

	cvarBileMask = CreateConVar("l4d_nbm_bilemask", "1", "Enables Bile Mask ability: When covered in bile, the Survivors entire view (HUD) is completely covered. (Def 1)");
	cvarBileMaskState = CreateConVar("l4d_nbm_bilemaskstate", "1", "Duration HUD Remains Hidden (0 = Cvar Set Duration, 1 = Until Bile Dries). (Def 1)");
	cvarBileMaskAmount = CreateConVar("l4d_nbm_bilemaskamount", "200", "Amount of visibility covered by the Boomer's bile (0 = None, 255 = Total). (Def 200)");
	cvarBileMaskDuration = CreateConVar("l4d_nbm_bilemaskduration", "-1", "How long is the HUD hidden for after vomit (-1 = Until Dry, 0< is period of time). (Def -1)");

	cvarBilePimple = CreateConVar("l4d_nbm_bilepimple", "1", "Enables Bile Pimple ability: At any moment one of the Boomer's Bile filled Pimples could pop and spray any Survivor nearby. (Def 1)");
	cvarBilePimpleChance = CreateConVar("l4d_nbm_bilepimplechance", "5", "Chance that a Survivor will be hit with Bile from an exploding Pimple. (Def 5)(5 = 5%)");
	cvarBilePimpleDamage = CreateConVar("l4d_nbm_bilepimpledamage", "10", "Amount of damage the Bile from an exploding Pimple will cause. (Def 10)");
	cvarBilePimpleRange = CreateConVar("l4d_nbm_bilepimplerange", "500.0", "Distance Bile will reach from an Exploding Pimple. (Def 500.0)");

	cvarBileShower = CreateConVar("l4d_nbm_bileshower", "1", "Enables Bile Shower ability: When the Boomer vomits on something, it will summon a larger mob of common infected. (Def 1)");
	cvarBileShowerTimeout = CreateConVar("l4d_nbm_bileshowertimeout", "10", "How many seconds must a Boomer wait before summoning another mob. (Def 10)");

	cvarBileSwipe = CreateConVar("l4d_nbm_bileswipe", "1", "Enables Bile Swipe ability: Due to the Boomer's sharp bile covered claws, it has a chance of inflicting burning bile wounds to survivors. (Def 1)");
	cvarBileSwipeChance = CreateConVar("l4d_nbm_bileswipechance", "100", "Chance that the Boomer's claws will cause a burning bile wound. (100 = 100%) (Def 100)");
	cvarBileSwipeDuration = CreateConVar("l4d_nbm_bileswipeduration", "10", "For how many seconds does the Bile Swipe last. (Def 10)");
	cvarBileSwipeDamage = CreateConVar("l4d_nbm_bileswipedamage", "1", "How much damage is inflicted by Bile Swipe each second. (Def 1)");

	cvarBileThrow = CreateConVar("l4d_nbm_bilethrow", "1", "Enables Bile Throw ability: The Boomer spits into its hand and throws globs of vomit at Survivors it can see. (Def 1)");
	cvarBileThrowCooldown = CreateConVar("l4d_nbm_bilethrowcooldown", "8.0", "Period of time before Bile Throw can be used again. (Def 8.0)");
	cvarBileThrowDamage = CreateConVar("l4d_nbm_bilethrowdamage", "10", "Amount of damage the Bile Throw deals to Survivors that are hit. (Def 10)");
	cvarBileThrowRange = CreateConVar("l4d_nbm_bilethrowrange", "700", "Distance the Boomer is able to throw Bile. (Def 700)");

	cvarExplosiveDiarrhea = CreateConVar("l4d_nbm_explosivediarrhea", "1", "Enables Explosive Diarrhea ability: The pressure of the bile inside its body cause the Boomer to fire out both ends when vomiting. (Def 1)");
	cvarExplosiveDiarrheaRange = CreateConVar("l4d_nbm_explosivediarrhearange", "100", "Distance the diarrhea can travel behind the Boomer. (Def 100)");

	cvarFlatulence = CreateConVar("l4d_nbm_flatulence", "1", "Enables Flatulence ability: Due to excess bile in it's body, the Boomer will on occassion expel a bile gas that causes damage to anyone standing inside the cloud. (Def 1)", FCVAR_NOTIFY);
	cvarFlatulenceChance = CreateConVar("l4d_nbm_flatulencechance", "20", "Chance that those affected by the Flatulence cloud will be biled. (20 = 20%) (Def 20)", FCVAR_NOTIFY);
	cvarFlatulenceCooldown = CreateConVar("l4d_nbm_flatulencecooldown", "60.0", "Period of time between Flatulence farts. (Def 60.0)", FCVAR_NOTIFY);
	cvarFlatulenceDamage = CreateConVar("l4d_nbm_flatulencedamage", "5", "Amount of damage caused to Survivors standing in a Flatulence cloud. (Def 5)", FCVAR_NOTIFY);
	cvarFlatulenceDuration = CreateConVar("l4d_nbm_flatulenceduration", "10.0", "Period of time the Flatulence cloud persists. (Def 10.0)", FCVAR_NOTIFY);
	cvarFlatulencePeriod = CreateConVar("l4d_nbm_flatulenceperiod", "2.0", "Frequency that standing in the Flatulence cloud will cause damage. (Def 2.0)", FCVAR_NOTIFY);
	cvarFlatulenceRadius = CreateConVar("l4d_nbm_flatulenceradius", "100.0", "Radius that the Flatulence cloud will cover. (Def 100.0)", FCVAR_NOTIFY);

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("ability_use", Event_AbilityUse);
	//AutoExecConfig(true, "plugin.L4D2.NauseatingBoomer");
	PluginStartTimer = CreateTimer(3.0, OnPluginStart_Delayed);
	ConfigFile = LoadGameConfigFile(GAMEDATA_FILENAME);
	laggedMovementOffset = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	sdkCallVomitOnPlayer = EndPrepSDKCall();
	if (sdkCallVomitOnPlayer == null)
	{
		SetFailState("Cant initialize OnVomitedUpon SDKCall");
		return;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_Fling");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkCallFling = EndPrepSDKCall();
	if (sdkCallFling == null)
	{
		SetFailState("Cant initialize Fling SDKCall");
		return;
	}
	delete ConfigFile;
}

public Action OnPluginStart_Delayed(Handle timer)
{
	if (GetConVarInt(cvarBileBlast))
	{
		isBileBlast = true;
	}
	if (GetConVarInt(cvarBileFeet))
	{
		isBileFeet = true;
	}
	if (GetConVarInt(cvarBilePimple))
	{
		isBilePimple = true;
	}
	if (GetConVarInt(cvarBileBelly))
	{
		isBileBelly = true;
	}
	if (GetConVarInt(cvarBileMask))
	{
		isBileMask = true;
	}
	if (GetConVarInt(cvarBileMaskState))
	{
		isBileMaskTilDry = true;
	}
	if (GetConVarInt(cvarBilePimple))
	{
		isBilePimple = true;
	}
	if (GetConVarInt(cvarBileShower))
	{
		isBileShower = true;
	}
	if (GetConVarInt(cvarBileSwipe))
	{
		isBileSwipe = true;
	}
	if (GetConVarInt(cvarBileThrow))
	{
		isBileThrow = true;
	}
	if (GetConVarInt(cvarExplosiveDiarrhea))
	{
		isExplosiveDiarrhea = true;
	}
	if (GetConVarInt(cvarFlatulence))
	{
		isFlatulence = true;
	}
	if (PluginStartTimer != null)
	{
 		KillTimer(PluginStartTimer);
		PluginStartTimer = null;
	}
	return Plugin_Stop;
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action Event_PlayerSpawn(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidBoomer(client))
	{

		if (isBileFeet)
		{
			BoomerAbility_BileFeet(client);

		}

		if (isBilePimple)
		{
			BoomerAbility_BilePimple(client);

		}

		if (isFlatulence)
		{
			BoomerAbility_Flatulence(client);
		}
	}
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidDeadBoomer(client))
	{

		if (isBileBlast)
		{
			BoomerAbility_BileBlast(client);
		}
	}
	return Plugin_Continue;
}

public Action Event_AbilityUse(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (isExplosiveDiarrhea)
	{
		BoomerAbility_ExplosiveDiarrhea(client);
	}
	return Plugin_Continue;
}

public Action Event_PlayerNowIt(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (isBileShower && !isBileShowerTimeout)
	{
		BoomerAbility_BileShower(client);
	}

	if (isBileMask)
	{
		BoomerAbility_BileMask(client);
	}
	return Plugin_Continue;
}

public Action Event_PlayerNotIt(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (isBileMask && isBileMaskTilDry)
	{
		BoomerAbility_BileMaskDry(client);
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidBoomer(attacker) && IsValidClient(victim) && GetClientTeam(victim) == 2)
	{

		char weapon[64];
		GetClientWeapon(attacker, weapon, sizeof(weapon));
		if (isBileSwipe && StrEqual(weapon, "weapon_boomer_claw"))
		{
			BoomerAbility_BileSwipe(victim, attacker);
		}
	}
	if (IsValidClient(attacker) && GetClientTeam(attacker) == 2 && IsValidBoomer(victim))
	{

		if (isBileBelly)
		{
			float damagemod = GetConVarFloat(cvarBileBellyAmount);
			if (FloatCompare(damagemod, 1.0) != 0)
			{
				damage = damage * damagemod;
			}
		}
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{

	if (buttons & IN_ATTACK2 && isBileThrow)
	{
		BoomerAbility_BileThrow(client);
	}
	return Plugin_Continue;
}

void BoomerAbility_BileBlast(int client)
{
	for (int victim=1; victim<=MaxClients; victim++)
	{
		if (IsValidClient(victim) && GetClientTeam(victim) != 3  && !IsSurvivorPinned(client))
		{
			float s_pos[3];
			GetClientEyePosition(client, s_pos);
			float targetVector[3];
			float distance;
			float range1 = GetConVarFloat(cvarBileBlastInnerRange);
			float range2 = GetConVarFloat(cvarBileBlastOuterRange);
			GetClientEyePosition(victim, targetVector);
			distance = GetVectorDistance(targetVector, s_pos);
			if (distance < range1)
			{
				float HeadingVector[3], AimVector[3];
				float power = GetConVarFloat(cvarBileBlastInnerPower);
				GetClientEyeAngles(client, HeadingVector);
				AimVector[0] = Cosine(DegToRad(HeadingVector[1])) * power;
				AimVector[1] = Sine(DegToRad(HeadingVector[1])) * power;
				float current[3];
				GetEntPropVector(victim, Prop_Data, VELOCITY_ENTPROP, current);
				float resulting[3];
				resulting[0] = current[0] + AimVector[0];
				resulting[1] = current[1] + AimVector[1];
				resulting[2] = power * SLAP_VERTICAL_MULTIPLIER;
				int damage = GetConVarInt(cvarBileBlastInnerDamage);
				DamageHook(client, victim, damage);
				float incaptime = 3.0;
				SDKCall(sdkCallFling, victim, resulting, 76, client, incaptime);
			}
			if (distance < range2 && distance > range1)
			{
				float HeadingVector[3], AimVector[3];
				float power = GetConVarFloat(cvarBileBlastOuterPower);
				GetClientEyeAngles(client, HeadingVector);
				AimVector[0] = Cosine(DegToRad(HeadingVector[1])) * power;
				AimVector[1] = Sine(DegToRad(HeadingVector[1])) * power;
				float current[3];
				GetEntPropVector(victim, Prop_Data, VELOCITY_ENTPROP, current);
				float resulting[3];
				resulting[0] = current[0] + AimVector[0];
				resulting[1] = current[1] + AimVector[1];
				resulting[2] = power * SLAP_VERTICAL_MULTIPLIER;
				int damage = GetConVarInt(cvarBileBlastOuterDamage);
				DamageHook(client, victim, damage);
				float incaptime = 3.0;
				SDKCall(sdkCallFling, victim, resulting, 76, client, incaptime);
			}
		}
	}
}

public Action BoomerAbility_BileFeet(int client)
{
	cvarBileFeetTimer[client] = CreateTimer(0.5, Timer_BoomerBileFeet, client);
	return Plugin_Continue;
}

public Action Timer_BoomerBileFeet(Handle timer, any client)
{
	if (IsValidClient(client))
	{
		PrintHintText(client, "%T", "Boomer Bile Feet", client);
		SetEntDataFloat(client, laggedMovementOffset, 1.0*GetConVarFloat(cvarBileFeetSpeed), true);
		SetConVarFloat(FindConVar("z_vomit_fatigue"),0.0,false,false);
	}
	if (cvarBileFeetTimer[client] != null)
	{
 		KillTimer(cvarBileFeetTimer[client]);
		cvarBileFeetTimer[client] = null;
	}
	return Plugin_Stop;
}

void BoomerAbility_BileMask(int client)
{
	if (IsValidClient(client))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetConVarInt(cvarBileMaskAmount));
		if (!isBileMaskTilDry)
		{
			cvarBileMaskTimer[client] = CreateTimer(GetConVarFloat(cvarBileMaskDuration), Timer_BileMask, client);
		}
	}
}

public Action Timer_BileMask(Handle timer, any client)
{
	BoomerAbility_BileMaskDry(client);
	if (cvarBileMaskTimer[client] != null)
	{
		KillTimer(cvarBileMaskTimer[client]);
		cvarBileMaskTimer[client] = null;
	}
	return Plugin_Stop;
}

void BoomerAbility_BileMaskDry(int client)
{
	if (IsValidClient(client))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
	}
}

public Action BoomerAbility_BilePimple(int client)
{
	cvarBilePimpleTimer[client] = CreateTimer(0.5, Timer_BilePimple, client, TIMER_REPEAT);
	return Plugin_Continue;
}

public Action Timer_BilePimple(Handle timer, any client)
{
	if (!IsValidBoomer(client) || GetClientTeam(client) != 3)
	{
		if (cvarBilePimpleTimer[client] != null)
		{
			KillTimer(cvarBilePimpleTimer[client]);
			cvarBilePimpleTimer[client] = null;
		}
		return Plugin_Stop;
	}
	for (int victim=1; victim<=MaxClients; victim++)
	if (IsValidClient(victim) && GetClientTeam(victim) == 2)
	{
		int BilePimpleChance = GetRandomInt(0, 99);
		int BilePimplePercent = (GetConVarInt(cvarBilePimpleChance));
		if (BilePimpleChance < BilePimplePercent)
		{
			float v_pos[3];
			GetClientEyePosition(victim, v_pos);
			float targetVector[3];
			float distance;
			float range = GetConVarFloat(cvarBilePimpleRange);
			GetClientEyePosition(client, targetVector);
			distance = GetVectorDistance(targetVector, v_pos);
			if (distance <= range)
			{
				int damage = GetConVarInt(cvarBilePimpleDamage);
				DamageHook(client, victim, damage);
			}
		}
	}
	return Plugin_Continue;
}

void BoomerAbility_BileShower(int client)
{
	if (IsValidBoomer(client) && !isBileShowerTimeout)
	{
		isBileShowerTimeout = true;
		cvarBileShowerTimer[client] = CreateTimer(GetConVarFloat(cvarBileShowerTimeout), Timer_BileShower, client);
		int flags = GetCommandFlags("z_spawn_old");
		SetCommandFlags("z_spawn_old", flags & ~FCVAR_CHEAT);
		FakeClientCommand(client,"z_spawn_old mob auto");
		SetCommandFlags("z_spawn_old", flags|FCVAR_CHEAT);
	}
}

public Action Timer_BileShower(Handle timer, any client)
{
	isBileShowerTimeout = false;
	if (cvarBileShowerTimer[client] != null)
	{
		KillTimer(cvarBileShowerTimer[client]);
		cvarBileShowerTimer[client] = null;
	}
	return Plugin_Stop;
}

void BoomerAbility_BileSwipe(int victim, int attacker)
{
	int BileSwipeChance = GetRandomInt(0, 99);
	int BileSwipePercent = (GetConVarInt(cvarBileSwipeChance));
	if (IsValidClient(victim) && GetClientTeam(victim) == 2 && BileSwipeChance < BileSwipePercent)
	{
		PrintHintText(victim, "%T", "Boomer Bile Swipe", victim);
		if (bileswipe[victim] <= 0)
		{
			bileswipe[victim] = (GetConVarInt(cvarBileSwipeDuration));
			Handle dataPack = CreateDataPack();
			cvarBileSwipeTimer[victim] = CreateDataTimer(1.0, Timer_BileSwipe, dataPack, TIMER_REPEAT);
			WritePackCell(dataPack, victim);
			WritePackCell(dataPack, attacker);
		}
	}
}

public Action Timer_BileSwipe(Handle timer, any dataPack)
{
	ResetPack(dataPack);
	int victim = ReadPackCell(dataPack);
	int attacker = ReadPackCell(dataPack);
	if (IsValidClient(victim))
	{
		if (bileswipe[victim] <= 0)
		{
			if (cvarBileSwipeTimer[victim] != null)
			{
				KillTimer(cvarBileSwipeTimer[victim]);
				cvarBileSwipeTimer[victim] = null;
			}
			return Plugin_Stop;
		}
		int damage = GetConVarInt(cvarBileSwipeDamage);
		DamageHook(victim, attacker, damage);
		if (bileswipe[victim] > 0)
		{
			bileswipe[victim] -= 1;
		}
	}
	return Plugin_Continue;
}

public Action BoomerAbility_BileThrow(int client)
{
	if (IsValidBoomer(client) && !IsPlayerGhost(client) && IsBileThrowReady(client))
	{
		float range = GetConVarFloat(cvarBileThrowRange);
		for (int victim=1; victim<=MaxClients; victim++)
		if (IsValidClient(victim) && GetClientTeam(victim) == 2 && ClientViews(client, victim, range))
		{
			float attackerPos[3];
			float victimPos[3];
			GetClientEyePosition(client, attackerPos);
			GetClientEyePosition(victim, victimPos);
			ShowParticle(attackerPos, "boomer_vomit", 3.0);
			ShowParticle(victimPos, "boomer_explode", 3.0);
			SDKCall(sdkCallVomitOnPlayer, victim, client, true);
			cooldownBileThrow[client] = GetEngineTime();
			int damage = GetConVarInt(cvarBileThrowDamage);
			DamageHook(victim, client, damage);
		}
	}
	return Plugin_Continue;
}

public Action BoomerAbility_ExplosiveDiarrhea(int client)
{
	if (IsValidBoomer(client))
	{
		float range = GetConVarFloat(cvarExplosiveDiarrheaRange);
		for (int victim=1; victim<=MaxClients; victim++)
		if (IsValidClient(victim) && GetClientTeam(victim) == 2 && ClientViewsReverse(client, victim, range))
		{
			float attackerPos[3];
			float victimPos[3];
			GetClientEyePosition(client, attackerPos);
			GetClientEyePosition(victim, victimPos);
			ShowParticle(attackerPos, "boomer_vomit", 3.0);
			ShowParticle(victimPos, "boomer_explode", 3.0);
			SDKCall(sdkCallVomitOnPlayer, victim, client, true);
		}
	}
	return Plugin_Continue;
}

public Action BoomerAbility_Flatulence(int client)
{
	Prepare_Flatulence(client);
	float time = GetConVarFloat(cvarFlatulenceCooldown);
	cvarFlatulenceTimer[client] = CreateTimer(time, Timer_Flatulence, client, TIMER_REPEAT);
	return Plugin_Continue;
}

public Action Timer_Flatulence(Handle timer, any client)
{
	if (!IsValidBoomer(client) || IsPlayerGhost(client))
	{
		if (cvarFlatulenceTimer[client] != null)
		{
			KillTimer(cvarFlatulenceTimer[client]);
			cvarFlatulenceTimer[client] = null;
		}
		return Plugin_Stop;
	}
	Prepare_Flatulence(client);
	return Plugin_Continue;
}

public Action Prepare_Flatulence(int client)
{
	float vecPos[3];
	GetClientAbsOrigin(client, vecPos);
	float targettime = GetEngineTime() + GetConVarFloat(cvarFlatulenceDuration);
	ShowParticle(vecPos, "smoker_smokecloud", targettime);
	Handle dataPack = CreateDataPack();
	WritePackCell(dataPack, client);
	WritePackFloat(dataPack, vecPos[0]);
	WritePackFloat(dataPack, vecPos[1]);
	WritePackFloat(dataPack, vecPos[2]);
	WritePackFloat(dataPack, targettime);
	float time = GetConVarFloat(cvarFlatulencePeriod);
	cvarFlatulenceTimerCloud[client] = CreateTimer(time, Timer_FlatulenceCloud, dataPack, TIMER_REPEAT);
	return Plugin_Continue;
}

public Action Timer_FlatulenceCloud(Handle timer, Handle dataPack)
{
	ResetPack(dataPack);
	int client = ReadPackCell(dataPack);
	float vecPos[3];
	vecPos[0] = ReadPackFloat(dataPack);
	vecPos[1] = ReadPackFloat(dataPack);
	vecPos[2] = ReadPackFloat(dataPack);
	float targettime = ReadPackFloat(dataPack);
	if (targettime - GetEngineTime() < 0)
	{
		if (cvarFlatulenceTimerCloud[client] != null)
		{
			KillTimer(cvarFlatulenceTimerCloud[client]);
			cvarFlatulenceTimerCloud[client] = null;
		}
		return Plugin_Stop;
	}
	float targetVector[3];
	float distance;
	float radiussetting = GetConVarFloat(cvarFlatulenceRadius);
	for (int victim=1; victim<=MaxClients; victim++)
	{
		if (IsValidClientAndInGame(client) && IsValidClient(victim) && GetClientTeam(victim) == 2)
		{
			GetClientEyePosition(victim, targetVector);
			distance = GetVectorDistance(targetVector, vecPos);
			if (distance > radiussetting || !IsVisibleTo(vecPos, targetVector))
			{
				continue;
			}
			PrintHintText(victim, "%T", "Boomer Flatulence Cloud", victim);
			int damage = GetConVarInt(cvarFlatulenceDamage);
			DamageHook(victim, client, damage);
			int FlatulenceChance = GetRandomInt(0, 99);
			int FlatulencePercent = (GetConVarInt(cvarFlatulenceChance));
			if (FlatulenceChance < FlatulencePercent)
			{
				SDKCall(sdkCallVomitOnPlayer, victim, client, true);
			}
		}
	}
	return Plugin_Continue;
}

public Action DamageHook(int victim, int attacker, int damage)
{
	char strDamage[16];
	char strDamageTarget[16];
	float victimPos[3];
	GetClientEyePosition(victim, victimPos);
	IntToString(damage, strDamage, sizeof(strDamage));
	Format(strDamageTarget, sizeof(strDamageTarget), "hurtme%d", victim);
	int entPointHurt = CreateEntityByName("point_hurt");
	if (!entPointHurt)

	DispatchKeyValue(victim, "targetname", strDamageTarget);
	DispatchKeyValue(entPointHurt, "DamageTarget", strDamageTarget);
	DispatchKeyValue(entPointHurt, "Damage", strDamage);
	DispatchKeyValue(entPointHurt, "DamageType", "0");
	DispatchSpawn(entPointHurt);
	TeleportEntity(entPointHurt, victimPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entPointHurt, "Hurt", (attacker && attacker < MaxClients && IsClientInGame(attacker)) ? attacker : -1);
	DispatchKeyValue(entPointHurt, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	return Plugin_Continue;
}

public Action FlingHook(int victim, int attacker, float power)
{
	float HeadingVector[3], AimVector[3];
	GetClientEyeAngles(attacker, HeadingVector);
	AimVector[0] = Cosine(DegToRad(HeadingVector[1])) * power;
	AimVector[1] = Sine(DegToRad(HeadingVector[1])) * power;
	float current[3];
	GetEntPropVector(victim, Prop_Data, VELOCITY_ENTPROP, current);
	float resulting[3];
	resulting[0] = current[0] + AimVector[0];
	resulting[1] = current[1] + AimVector[1];
	resulting[2] = power * SLAP_VERTICAL_MULTIPLIER;
	float incaptime = 3.0;
	SDKCall(sdkCallFling, victim, resulting, 76, attacker, incaptime);
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
	float fMinDistance = 100.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
		{
			return false;
		}
	}
	if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) < (fMinDistance*fMinDistance))
	{
		return false;
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

stock bool ClientViewsReverse(int Viewer, int Target, float fMaxDistance=0.0, float fThreshold=0.73)
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
	float fMinDistance = 100.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
		{
			return false;
		}
	}

	if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) < (fMinDistance*fMinDistance))
	{
		return false;
	}
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) > fThreshold)
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

public bool ClientViewsFilter(int entity, int mask, any junk)
{
	return (entity >= 1 && entity <= MaxClients);
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

bool IsVisibleTo(float position[3], float targetposition[3])
{
	float vAngles[3], vLookAt[3];
	MakeVectorFromPoints(position, targetposition, vLookAt);
	GetVectorAngles(vLookAt, vAngles);
	Handle trace = TR_TraceRayFilterEx(position, vAngles, MASK_SHOT, RayType_Infinite, _TraceFilter);
	bool isVisible = false;
	if (TR_DidHit(trace))
	{
		float vStart[3];
		TR_GetEndPosition(vStart, trace);
		if ((GetVectorDistance(position, vStart, false) + TRACE_TOLERANCE) >= GetVectorDistance(position, targetposition))
		{
			isVisible = true;
		}
	}
	else
	{
		//LogError("Tracer Bug: Player-Zombie Trace did not hit anything, WTF");
		isVisible = true;
	}
	delete trace;
	return isVisible;
}

public bool _TraceFilter(int entity, int contentsMask)
{
	return (!entity || !IsValidEntity(entity));
}

bool IsValidClientAndInGame(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client));
}

bool IsValidDeadClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsPlayerAlive(client));
}

bool IsValidBoomer(int client)
{
	if (IsValidClient(client))
	{
		int zombieClass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (zombieClass == ZOMBIECLASS_BOOMER)
		{
			return true;
		}
	}
	return false;
}

bool IsValidDeadBoomer(int client)
{
	if (IsValidDeadClient(client))
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == ZOMBIECLASS_BOOMER)
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

bool IsSurvivorPinned(int client)
{
	int attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	int attacker2 = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
	int attacker3 = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	int attacker4 = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	int attacker5 = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	if ((attacker > 0 && attacker != client) || (attacker2 > 0 && attacker2 != client) || (attacker3 > 0 && attacker3 != client) || (attacker4 > 0 && attacker4 != client) || (attacker5 > 0 && attacker5 != client))
	{
		return true;
	}
	return false;
}

bool IsBileThrowReady(int client)
{
	return ((GetEngineTime() - cooldownBileThrow[client]) > GetConVarFloat(cvarBileThrowCooldown));
}