#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>


#pragma semicolon 1
#pragma newdecls required

ConVar g_cvarClientFFDistance;
float g_fClientFFPercent[MAXPLAYERS] = {0.0};
float g_fClientLastDoFFTime[MAXPLAYERS] = {0.0};
public Plugin myinfo =
{
	name = "Better Closed Friendfire",
	author = "P",
	description = "近距离友伤机制优化",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
    g_cvarClientFFDistance = CreateConVar("sm_client_ff_distance", "210.0", "距离小于多少时该插件处理友伤", FCVAR_NOTIFY);
    HookEvent("player_spawn", Event_PlayerSpawn);
}


public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));

	HookClient(client);
}

void HookClient(int client) {
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3]) {
    if (IsClientInGame(victim) && IsClientInGame(attacker)){
        if (GetClientTeam(victim) != GetClientTeam(attacker)) return Plugin_Continue;
        float pos1[3], pos2[3];
        GetClientAbsOrigin(victim, pos1);
        GetClientAbsOrigin(attacker, pos2);
        bool isTooFar = GetVectorDistance(pos1, pos2) > g_cvarClientFFDistance.FloatValue;
        if (isTooFar) {
            return Plugin_Continue;
        }

        if (g_fClientLastDoFFTime[attacker] < GetEngineTime() + 10.0 ) {
            g_fClientFFPercent[attacker] -= (GetEngineTime() + 10 - g_fClientLastDoFFTime[attacker]) * 0.01 * 4;
        }

        if (g_fClientFFPercent[attacker] > 1.0) {
            g_fClientFFPercent[attacker] = 1.0;
            return Plugin_Continue;
        }
        if (g_fClientFFPercent[attacker] < 0.0) g_fClientFFPercent[attacker] = 0.0;

        float health = float(GetClientHealth(victim)) + L4D_GetTempHealth(victim);
        float dmgtime = GetEngineTime();
        
        float targetMaxDamagePercent;
        g_fClientFFPercent[attacker] += damage / health;
        g_fClientLastDoFFTime[attacker] = dmgtime;

        PrintToConsole(attacker, "原ff %f | 当前百分比 %.2f",damage ,g_fClientFFPercent[attacker]);
        
        // 高伤害武器
        if (damage / health > 0.5){
            targetMaxDamagePercent = (g_fClientFFPercent[attacker] < 0.6) ? 0.6 : g_fClientFFPercent[attacker];
            damage = damage > health ? health * targetMaxDamagePercent : damage * targetMaxDamagePercent;
        }
        else {
            targetMaxDamagePercent = g_fClientFFPercent[attacker];
            damage *= targetMaxDamagePercent;
        }
        return Plugin_Handled;
    }
    return Plugin_Continue;
}
