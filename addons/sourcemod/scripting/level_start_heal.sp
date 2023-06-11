#define PLUGIN_VERSION	"1.9"
#define PLUGIN_NAME		"Level Start Heal"

#pragma tabsize 0
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>

#define SOUND_HEARTBEAT	"player/heartbeatloop.wav"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "little_froy",
	description = "game play",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=340158"
};

ConVar C_buffer_decay_rate;
ConVar C_health;

float O_buffer_decay_rate;
int O_health;

bool Late_load;

bool First[MAXPLAYERS+1];

bool is_survivor_alright(int client)
{
	return !GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

float get_temp_health(int client)
{
	float buffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - (GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * O_buffer_decay_rate;
	return buffer < 0.0 ? 0.0 : buffer;
}

void set_temp_health(int client, float buffer)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", buffer);
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}

void heal_player(int client)
{
    int health = GetClientHealth(client);
    if(health < O_health)
    {
        float buffer = get_temp_health(client) + float(health) - float(O_health);
        if(buffer < 0.0)
        {
			buffer = 0.0;
        }
		set_temp_health(client, buffer);
        SetEntityHealth(client, O_health);
    }
    SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
    SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);  
    SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 0);
    StopSound(client, SNDCHAN_STATIC, SOUND_HEARTBEAT);
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(GetClientTeam(client) == 2)
	{
		if(IsPlayerAlive(client) && is_survivor_alright(client))
		{
			if(First[client])
			{
				heal_player(client);
				First[client] = false;
			}
		}
		else
		{
			First[client] = false;
		}
	}
	else
	{
		First[client] = true;
	}
}

public void OnClientDisconnect_Post(int client)
{
	First[client] = true;
}

void event_round_start(Event event, const char[] name, bool dontBroadcast)
{
	for(int client = 1; client <= MaxClients; client++)
	{
        First[client] = true;
	}
}

void event_player_bot_replace(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("bot"));
	int prev = GetClientOfUserId(event.GetInt("player"));
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && prev != 0)
	{
        First[client] = First[prev];
	}
}

void event_bot_player_replace(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("player"));
	int prev = GetClientOfUserId(event.GetInt("bot"));
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && prev != 0)
	{
        First[client] = First[prev];
	}
}

void get_cvars()
{
	O_buffer_decay_rate = C_buffer_decay_rate.FloatValue;
    O_health = C_health.IntValue;
}

void convar_changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	get_cvars();
}

public void OnConfigsExecuted()
{
	get_cvars();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    Late_load = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    HookEvent("round_start", event_round_start);
    HookEvent("player_bot_replace", event_player_bot_replace);
	HookEvent("bot_player_replace", event_bot_player_replace);

    C_buffer_decay_rate = FindConVar("pain_pills_decay_rate");
    C_health = CreateConVar("level_start_heal_health", "100", "how many health to heal on level start", _, true, 1.0);

    CreateConVar("level_start_heal_version", PLUGIN_VERSION, "version of " ... PLUGIN_NAME, FCVAR_NOTIFY | FCVAR_DONTRECORD);

    C_buffer_decay_rate.AddChangeHook(convar_changed);
    C_health.AddChangeHook(convar_changed);

    AutoExecConfig(true, "level_start_heal");

	if(Late_load)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!IsClientInGame(client))
			{
				First[client] = true;
			}
		}
	}
}