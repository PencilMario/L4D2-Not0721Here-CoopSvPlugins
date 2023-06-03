#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sourcescramble>

#define MAX 32

public Plugin myinfo =
{
	name = "[L4D2] Server Side Ragdolls",
	author = "BHaType",
	description = "Creates server side regdoll",
	version = "0.2",
	url = ""
};

Handle g_hRagdoll;
ConVar sm_side_dolls_invisible_body, sm_side_dolls_remove;

bool g_bInvisible, g_bRemove;
int g_iRagdolls[MAX];
MemoryBlock memory;

public void OnPluginStart()
{
	memory = new MemoryBlock(0x4C);
	
	sm_side_dolls_invisible_body 	= CreateConVar("sm_side_dolls_invisible_body"	, "0");
	sm_side_dolls_remove 			= CreateConVar("sm_side_dolls_remove"			, "0");
	
	sm_side_dolls_invisible_body.AddChangeHook(OnConVarChanged);
	sm_side_dolls_remove.AddChangeHook(OnConVarChanged);
	
	g_bInvisible = sm_side_dolls_invisible_body.BoolValue;
	g_bRemove = sm_side_dolls_remove.BoolValue;
	
	AutoExecConfig(true, "server_side_ragdolls");
	
	Handle hData = LoadGameConfigFile("l4d2_side_dolls");
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hData, SDKConf_Signature, "CreateServerRagdoll");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hRagdoll = EndPrepSDKCall();		
	
	delete hData;

	HookEvent("player_death", player_death, EventHookMode_Pre);
	
	HookEvent("defibrillator_used", player_respawn, EventHookMode_Pre);
	HookEvent("survivor_rescued", player_respawn, EventHookMode_Pre);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bInvisible = sm_side_dolls_invisible_body.BoolValue;
	g_bRemove = sm_side_dolls_remove.BoolValue;
}

public void OnEntityCreated (int entity, const char[] name)
{
	if (g_bInvisible && strcmp(name, "survivor_death_model") == 0)
		SetEntityRenderMode(entity, RENDER_NONE);
}

public void player_respawn(Event event, const char[] name, bool dontbroadcast)
{
	if (!g_bRemove)
		return;
		
	int client = GetClientOfUserId(event.GetInt("subject"));
	
	if (!client)
		client = GetClientOfUserId(event.GetInt("victim"));
	
	if (!client || GetClientTeam(client) != 2)
		return;
		
	int index = GetIndex(client);
	
	if (index == -1)
		return;
		
	AcceptEntityInput (index, "kill");
}

public void player_death(Event event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!client || GetClientTeam(client) != 2)
		return;
	
	int entity = SDKCall(g_hRagdoll, client, GetEntProp(client, Prop_Send, "m_nForceBone"), memory.Address, 3, true);
	
	if (g_bRemove)
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		g_iRagdolls[GetIndex()] = EntIndexToEntRef(entity);
	}
}

int GetIndex (int client = -1)
{
	int entity;
	
	if (client != -1)
	{
		for (int i; i < MAX; i++)
		{
			if ((entity = EntRefToEntIndex(g_iRagdolls[i])) <= 0 || !IsValidEntity(entity))
				continue;
				
			if (client == GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))
			{
				g_iRagdolls[i] = 0;
				return entity;
			}
		}
		
		return -1;
	}
	
	for (int i; i < MAX; i++)
	{
		if ((entity = EntRefToEntIndex(g_iRagdolls[i])) > 0 && IsValidEntity(entity))
			continue;
			
		return i;
	}
	
	return -1;
}