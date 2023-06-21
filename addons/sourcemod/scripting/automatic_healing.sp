#define PLUGIN_VERSION	"3.5 Simplified"
#define PLUGIN_NAME		"Automatic Healing"
#define PLUGIN_PREFIX	"automatic_healing"

#pragma tabsize 0
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <automatic_healing>

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "little_froy",
	description = "game play",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=336073"
};

ConVar g_cEnable;
ConVar C_buffer_decay_rate;
float O_buffer_decay_rate;
ConVar C_interrupt_on_hurt;
bool O_interrupt_on_hurt;
ConVar C_wait_time;
float O_wait_time;
ConVar C_health;
float O_health;
ConVar C_max;
float O_max;
ConVar C_repeat_interval;
float O_repeat_interval;
ConVar C_fix;
float O_fix;

float O_max_round_to_floor;

float Next_heal_time[MAXPLAYERS+1] = {-1.0, ...};

int get_idled_of_bot(int bot)
{
    if(!HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
    {
        return 0;
    }
	return GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));			
}

bool is_survivor_hanging(int client)
{
	return !!GetEntProp(client, Prop_Send, "m_isHangingFromLedge");
}

bool is_survivor_alright(int client)
{
	return !GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

bool is_survivor_down(int client)
{
	return !is_survivor_alright(client) && !is_survivor_hanging(client);
}

float get_temp_health(int client)
{
	float buffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - (GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * O_buffer_decay_rate;
	return buffer < 0.0 ? 0.0 : buffer;
}

void set_temp_health(int client, float buffer)
{
	if (g_cEnable.IntValue != 1) return;
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", buffer);
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}

void end_heal(int client)
{
	Next_heal_time[client] = -1.0;
}

bool lower_than_heal_max(int client)
{
	return float(GetClientHealth(client)) + get_temp_health(client) < O_max_round_to_floor;
}

void wait_to_heal(int client)
{
	Next_heal_time[client] = GetEngineTime() + O_wait_time;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(GetClientTeam(client) == 2 && IsPlayerAlive(client) && is_survivor_alright(client))
	{
		float health = float(GetClientHealth(client));
		float buffer = get_temp_health(client);
		float all = health + buffer;
		if(all < O_max_round_to_floor)
		{
			if(O_fix > 0.0)
			{
				float before_decimal_point = float(RoundToFloor(buffer));
				if(buffer - before_decimal_point < O_fix)
				{
					buffer = before_decimal_point + O_fix;
					all = health + buffer;
					set_temp_health(client, buffer);
				}
			}
			if(Next_heal_time[client] < 0.0)
			{
				wait_to_heal(client);
			}
			else if(GetEngineTime() >= Next_heal_time[client])
			{
				if(all + O_health < O_max_round_to_floor)
				{
					set_temp_health(client, buffer + O_health);
					Next_heal_time[client] += O_repeat_interval;
				}
				else
				{
					set_temp_health(client, O_max - health);
					end_heal(client);
				}
			}
		}
		else
		{
			end_heal(client);
			if(all < O_max)
			{
				set_temp_health(client, O_max - health);
			}
		}
	}
	else
	{
		end_heal(client);
	}
}

public void OnClientDisconnect_Post(int client)
{
	end_heal(client);
}

void event_round_start(Event event, const char[] name, bool dontBroadcast)
{
	for(int client = 1; client <= MAXPLAYERS; client++)
	{
		end_heal(client);
	}
}

void event_player_hurt(Event event, const char[] name, bool dontBroadcast)
{
	if(!O_interrupt_on_hurt)
	{
		return;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && is_survivor_alright(client) && lower_than_heal_max(client) && event.GetInt("dmg_health") > 0)
	{
		wait_to_heal(client);
	}
}

void event_player_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
    if(client != 0 && IsClientInGame(client) && !IsPlayerAlive(client))
    {
        int team = GetClientTeam(client);
	    if(team == 2)
        {
			end_heal(client);
        }
        else if(team == 1 && IsFakeClient(client))
        {
			int human = get_idled_of_bot(client);
			if(human != 0 && IsClientInGame(human) && !IsFakeClient(human) && GetClientTeam(human) == 2 && !IsPlayerAlive(human))
			{
				end_heal(human);
			}
        }
    }
}

void event_player_ledge_grab(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && is_survivor_hanging(client))
	{
		end_heal(client);
	}
}

void event_player_incapacitated(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && is_survivor_down(client))
	{
		end_heal(client);
	}
}

void event_player_bot_replace(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("bot"));
	if(client != 0)
	{
		int prev = GetClientOfUserId(event.GetInt("player"));
		if(prev != 0)
		{
			Next_heal_time[client] = Next_heal_time[prev];
		}
	}
}

void event_bot_player_replace(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("player"));
	if(client != 0)
	{
		int prev = GetClientOfUserId(event.GetInt("bot"));
		if(prev != 0)
		{
			Next_heal_time[client] = Next_heal_time[prev];
		}
	}
}

void get_cvars()
{
	O_buffer_decay_rate = C_buffer_decay_rate.FloatValue;
	O_interrupt_on_hurt = C_interrupt_on_hurt.BoolValue;
	O_wait_time = C_wait_time.FloatValue;
	O_health = C_health.FloatValue;
	O_max = C_max.FloatValue;
	O_repeat_interval = C_repeat_interval.FloatValue;
	O_fix = C_fix.FloatValue;

	O_max_round_to_floor = float(RoundToFloor(O_max));
}

void convar_changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	get_cvars();
}

public void OnConfigsExecuted()
{
	get_cvars();
}

any native_AutomaticHealing_WaitToHeal(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if(client < 1 || client > MaxClients)
	{
		ThrowNativeError(SP_ERROR_INDEX, "client index %d is out of bound", client);
	}
	if(!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_INDEX, "client index %d is not in game", client);
	}
	if(GetClientTeam(client) != 2 || !IsPlayerAlive(client) || !is_survivor_alright(client))
	{
		ThrowNativeError(SP_ERROR_INDEX, "client index %d is not an alive and none-incapacitated survivor", client);
	}
	if(lower_than_heal_max(client))
	{
		wait_to_heal(client);
		return true;
	}
	else
	{
		return false;
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("AutomaticHealing_WaitToHeal", native_AutomaticHealing_WaitToHeal);
    RegPluginLibrary(PLUGIN_PREFIX);
    return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("round_start", event_round_start);
	HookEvent("player_hurt", event_player_hurt);
	HookEvent("player_death", event_player_death);
	HookEvent("player_ledge_grab", event_player_ledge_grab);
	HookEvent("player_incapacitated", event_player_incapacitated);
	HookEvent("player_bot_replace", event_player_bot_replace);
	HookEvent("bot_player_replace", event_bot_player_replace);

	C_buffer_decay_rate = FindConVar("pain_pills_decay_rate");
	C_buffer_decay_rate.AddChangeHook(convar_changed);
	g_cEnable = CreateConVar(PLUGIN_PREFIX ... "_enable", "0", "1 = enable, 0 = disable.");
	C_interrupt_on_hurt = CreateConVar(PLUGIN_PREFIX ... "_interrupt_on_hurt", "1", "1 = enable, 0 = disable. interrupt healing on hurt?");
	C_interrupt_on_hurt.AddChangeHook(convar_changed);
	C_wait_time = CreateConVar(PLUGIN_PREFIX ... "_wait_time", "5.0", "how long time need to wait after the interruption to start healing", _, true, 0.0);
	C_wait_time.AddChangeHook(convar_changed);
	C_health = CreateConVar(PLUGIN_PREFIX ... "_health", "1.0", "how many health buffer heal once", _, true, 0.1);
	C_health.AddChangeHook(convar_changed);
	C_repeat_interval = CreateConVar(PLUGIN_PREFIX ... "_repeat_interval", "1.0", "repeat interval after healing start", _, true, 0.0);
	C_repeat_interval.AddChangeHook(convar_changed);
	C_max = CreateConVar(PLUGIN_PREFIX ... "_max", "30.2", "max health of healing", _, true, 1.1);
	C_max.AddChangeHook(convar_changed);	
	C_fix = CreateConVar(PLUGIN_PREFIX ... "_fix", "0.2", "when need healing, behind the decimal point, how many health buffer will increase to, if it lower than the value. 0.0 or lower = disable", _, _, _, true, 0.99);
	C_fix.AddChangeHook(convar_changed);
	CreateConVar(PLUGIN_PREFIX ... "_version", PLUGIN_VERSION, "version of " ... PLUGIN_NAME, FCVAR_NOTIFY | FCVAR_DONTRECORD);
	//AutoExecConfig(true, PLUGIN_PREFIX);
}