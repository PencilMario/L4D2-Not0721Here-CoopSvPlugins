#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"

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
 * windows signature is not confirmed since i don't have windows server at all.
 * listening server can't use sm1.12 since a unknown problem.
 * 
 * now plugin start
 * 
 * ============================================================================
 */

#define GAME_DATA "l4d2_chainsaw_switchspeed"

ConVar
	cvar_chainsaw_switchspeed;

float
	g_chainsaw_switchspeed;

Handle g_SDKCall_ChainsawStopAttack;


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


public void OnClientPutInServer(int client)
{
	if( IsFakeClient(client) )
		return;
	
	SDKHook(client, SDKHook_WeaponSwitchPost, SDKCallback_SwitchChainsaw);
}

void SDKCallback_SwitchChainsaw(int client, int weapon)
{
	if( !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2 )
		return;
	
	char weapon_name[64];
	GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
	if( strcmp(weapon_name, "weapon_chainsaw") != 0 )
		return;
	
	SDKHook(client, SDKHook_PostThink, SDKCallback_SetPrimaryAttack);
}

void SDKCallback_SetPrimaryAttack(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	// PrintToChat(client, "hooking chainsaw switching in m_flCycle %f", GetEntPropFloat(weapon, Prop_Send, "m_flCycle"));

	char weapon_name[64];
	GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
	if( strcmp(weapon_name, "weapon_chainsaw") != 0 )
	{
		SDKUnhook(client, SDKHook_PostThink, SDKCallback_SetPrimaryAttack);
		// PrintToChat(client, "stop hook chainsaw switching in not equal weapon");
		return;
	}
		
	if( GetEntPropFloat(weapon, Prop_Send, "m_flCycle") >= g_chainsaw_switchspeed )
	{
		SDKCall(g_SDKCall_ChainsawStopAttack, weapon);
		// PrintToChat(client, "stop hook chainsaw switching in equaling the m_flCycle %f", GetEntPropFloat(weapon, Prop_Send, "m_flCycle"));
		SetEntPropFloat(weapon ,Prop_Send, "m_flPlaybackRate", 1.0);
		SetEntPropFloat(weapon ,Prop_Send, "m_flCycle", 1.0);

		int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		// PrintToChat(client, "m_nLayerSequence  %d", GetEntProp(viewmodel, Prop_Send, "m_nLayerSequence"));
		SetEntProp(viewmodel, Prop_Send, "m_nLayerSequence", 3);
		SDKUnhook(client, SDKHook_PostThink, SDKCallback_SetPrimaryAttack);
	}
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
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CChainsaw::StopAttack");
	// PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN9CChainsaw10StopAttackEv", 0);
	if( !(g_SDKCall_ChainsawStopAttack = EndPrepSDKCall()) )
		SetFailState("failed to load signature");
	
	delete hGameData;
}