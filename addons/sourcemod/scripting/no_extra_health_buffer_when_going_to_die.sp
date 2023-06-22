#define PLUGIN_VERSION	"1.0"
#define PLUGIN_NAME		"No Extra Health Buffer When Going To Die"
#define PLUGIN_PREFIX	"no_extra_health_buffer_when_going_to_die"

#pragma tabsize 0
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "little_froy",
	description = "game play",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=343146"
};

bool Late_load;

bool is_survivor_alright(int client)
{
	return !GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

Action on_take_damage_alive(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if(damage >= 1.0 && GetClientTeam(victim) == 2 && IsPlayerAlive(victim) && is_survivor_alright(victim) && !GetEntProp(victim, Prop_Send, "m_isGoingToDie") && GetClientHealth(victim) - RoundToFloor(damage) < 1)
    {
        damage += 1.0;
        return Plugin_Changed;
    }
    return Plugin_Continue; 
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamageAlive, on_take_damage_alive);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    if(GetEngineVersion() != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "this plugin only runs in \"Left 4 Dead 2\"");
        return APLRes_SilentFailure;
    }
    Late_load = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar(PLUGIN_PREFIX ... "_version", PLUGIN_VERSION, "version of " ... PLUGIN_NAME, FCVAR_NOTIFY | FCVAR_DONTRECORD);

    if(Late_load)
    {
        for(int client = 1; client <= MaxClients; client++)
        {
            if(IsClientInGame(client))
            {
                OnClientPutInServer(client);
            }
        }
    }
}
	