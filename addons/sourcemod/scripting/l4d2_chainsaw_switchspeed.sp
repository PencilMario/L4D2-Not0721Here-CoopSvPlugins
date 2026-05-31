#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#define PLUGIN_VERSION "1.0"
#define MAX_ENTITY_LIMIT 2049

public Plugin myinfo =
{
	name = "[L4D2] Chainsaw switch speed",
	author = "Miuwiki",
	description = "Reduce the start time after switching to a chainsaw",
	version = PLUGIN_VERSION,
	url = "http://www.miuwiki.site"
}

/*
 * ============================================================================
 * Information:
 * Adjusts chainsaw deploy duration and playback rate together.
 * ============================================================================
 */

#define GAME_DATA "l4d2_chainsaw_switchspeed"

ConVar
	cvar_chainsaw_switchspeed;

float
	g_chainsaw_switchspeed,
	g_chainsaw_playback_rate[MAX_ENTITY_LIMIT],
	g_chainsaw_restore_time[MAX_ENTITY_LIMIT];

Handle
	g_hDeployModifier,
	g_hDeploy,
	g_SDKCall_ChainsawStopAttack;


public void OnPluginStart()
{
	LoadGameData();

	cvar_chainsaw_switchspeed = CreateConVar("l4d2_chainsaw_switchspeed", "1.0", "time reduced when switching chainsaw, 0.5 means use half the time than origin", 0, true, 0.0, true, 1.0);
	cvar_chainsaw_switchspeed.AddChangeHook(CvarHook);
}

public void OnConfigsExecuted()
{
	g_chainsaw_switchspeed = cvar_chainsaw_switchspeed.FloatValue;
}

void CvarHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_chainsaw_switchspeed = cvar_chainsaw_switchspeed.FloatValue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (entity <= 0 || entity >= MAX_ENTITY_LIMIT)
		return;

	if (strcmp(classname, "weapon_chainsaw") != 0)
		return;

	DHookEntity(g_hDeployModifier, true, entity);
	DHookEntity(g_hDeploy, true, entity);
}

public Action Timer_StopSwitchAnimation(Handle timer, int weaponRef)
{
	int weapon = EntRefToEntIndex(weaponRef);
	if (weapon == INVALID_ENT_REFERENCE || weapon <= 0 || weapon >= MAX_ENTITY_LIMIT)
		return Plugin_Stop;

	if (g_chainsaw_restore_time[weapon] > GetGameTime() + 0.01)
		return Plugin_Stop;

	SDKCall(g_SDKCall_ChainsawStopAttack, weapon);
	SetEntPropFloat(weapon, Prop_Send, "m_flPlaybackRate", 1.0);
	SetEntPropFloat(weapon, Prop_Send, "m_flCycle", 1.0);

	int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon) {
		int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		if (viewmodel > MaxClients && IsValidEntity(viewmodel)) {
			SetEntProp(viewmodel, Prop_Send, "m_nLayerSequence", 3);
		}
	}

	g_chainsaw_playback_rate[weapon] = 0.0;
	g_chainsaw_restore_time[weapon] = 0.0;
	return Plugin_Stop;
}

public MRESReturn OnDeployModifier(int weapon, Handle hReturn)
{
	float durationMultiplier = ClampFloatAboveZero(g_chainsaw_switchspeed);
	float currentModifier = DHookGetReturn(hReturn);
	float playbackRate = 1.0 / durationMultiplier;

	if (weapon > 0 && weapon < MAX_ENTITY_LIMIT) {
		g_chainsaw_playback_rate[weapon] = playbackRate;
	}

	DHookSetReturn(hReturn, ClampFloatAboveZero(currentModifier * durationMultiplier));
	return MRES_Override;
}

public MRESReturn OnDeploy(int weapon)
{
	if (weapon <= 0 || weapon >= MAX_ENTITY_LIMIT)
		return MRES_Ignored;

	if (g_chainsaw_playback_rate[weapon] <= 0.0) {
		g_chainsaw_playback_rate[weapon] = 1.0;
	}

	float playbackRate = g_chainsaw_playback_rate[weapon];
	float gameTime = GetGameTime();
	float restoreTime = ScaleNextAttackTime(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime, playbackRate);

	int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (client > 0 && client <= MaxClients) {
		float nextAttack = ScaleNextAttackTime(client, Prop_Send, "m_flNextAttack", gameTime, playbackRate);
		if (nextAttack > restoreTime) {
			restoreTime = nextAttack;
		}
	}

	SetEntPropFloat(weapon, Prop_Send, "m_flPlaybackRate", playbackRate);

	g_chainsaw_restore_time[weapon] = restoreTime;
	if (restoreTime > gameTime) {
		CreateTimer(restoreTime - gameTime, Timer_StopSwitchAnimation, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
	} else {
		CreateTimer(0.0, Timer_StopSwitchAnimation, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
	}

	return MRES_Ignored;
}

float ScaleNextAttackTime(int entity, PropType propType, const char[] propName, float gameTime, float playbackRate)
{
	if (playbackRate <= 1.0)
		return GetEntPropFloat(entity, propType, propName);

	float nextAttack = GetEntPropFloat(entity, propType, propName);
	if (nextAttack <= gameTime)
		return nextAttack;

	nextAttack = gameTime + ((nextAttack - gameTime) / playbackRate);
	SetEntPropFloat(entity, propType, propName, nextAttack);
	return nextAttack;
}

void LoadGameData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAME_DATA);
	if(FileExists(sPath) == false) 
		SetFailState("\n==========\nMissing required file: \"%s\".\n==========", sPath);

	GameData hGameData = new GameData(GAME_DATA);
	if(hGameData == null) 
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAME_DATA);

	int offset = GameConfGetOffset(hGameData, "CTerrorWeapon::GetDeployDurationModifier");
	if (offset == -1)
		SetFailState("Unable to get offset for 'CTerrorWeapon::GetDeployDurationModifier'");

	g_hDeployModifier = DHookCreate(offset, HookType_Entity, ReturnType_Float, ThisPointer_CBaseEntity, OnDeployModifier);

	offset = GameConfGetOffset(hGameData, "CTerrorWeapon::Deploy");
	if (offset == -1)
		SetFailState("Unable to get offset for 'CTerrorWeapon::Deploy'");

	g_hDeploy = DHookCreate(offset, HookType_Entity, ReturnType_Unknown, ThisPointer_CBaseEntity, OnDeploy);

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CChainsaw::StopAttack");
	if (!(g_SDKCall_ChainsawStopAttack = EndPrepSDKCall()))
		SetFailState("failed to load signature");
	
	delete hGameData;
}

float ClampFloatAboveZero(float value)
{
	return value <= 0.0 ? 0.00001 : value;
}

bool IsChainsaw(int weapon)
{
	if (weapon <= MaxClients || !IsValidEntity(weapon))
		return false;

	char weaponName[64];
	GetEntityClassname(weapon, weaponName, sizeof(weaponName));
	return strcmp(weaponName, "weapon_chainsaw") == 0;
}
