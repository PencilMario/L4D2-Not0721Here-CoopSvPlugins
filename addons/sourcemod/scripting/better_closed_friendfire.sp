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
    g_cvarClientFFDistance = CreateConVar("sm_client_ff_distance", "250.0", "距离小于多少时该插件处理友伤", FCVAR_NOTIFY);
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

        if (g_fClientLastDoFFTime[attacker] + 7.0 < GetEngineTime() ) {
            g_fClientFFPercent[attacker] -= (GetEngineTime() - g_fClientLastDoFFTime[attacker] + 7.0) * 0.02;
            PrintToConsole(attacker, "友伤百分比已经降低到%f | -%f", g_fClientFFPercent[attacker], (GetEngineTime() - g_fClientLastDoFFTime[attacker] + 10.0) * 0.005);
        }


        if (g_fClientFFPercent[attacker] < 0.0) g_fClientFFPercent[attacker] = 0.0;

        float health = float(GetClientHealth(victim)) + L4D_GetTempHealth(victim);
        float dmgtime = GetEngineTime();
        
        float targetMaxDamagePercent = g_fClientFFPercent[attacker];
        g_fClientFFPercent[attacker] = g_fClientFFPercent[attacker] + damage / (health > 100.0 ? health : 100.0) * (((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)) ? 3.0 : 1.0);
        g_fClientLastDoFFTime[attacker] = dmgtime;
        if (g_fClientFFPercent[attacker] > 1.0) {
            g_fClientFFPercent[attacker] = 1.0;
        }
        PrintToConsole(attacker, "当前友伤百分比 %f", g_fClientFFPercent[attacker]);
        // 高伤害武器
        if (damage / health > 0.5){
            targetMaxDamagePercent = (targetMaxDamagePercent < 0.6) ? 0.6 : targetMaxDamagePercent;
            damage = damage > health ? health * targetMaxDamagePercent : damage * targetMaxDamagePercent;
        }
        else {
            damage *= targetMaxDamagePercent;
        }
        return Plugin_Changed;
    }
    return Plugin_Continue;
}
