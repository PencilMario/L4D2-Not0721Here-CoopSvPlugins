#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "L4D2 Anti Friendly Fire Down",
    author = "SP",
    description = "Prevents repeated friendly fire from incapacitating survivors and reflects excess damage.",
    version = "1.0.0",
    url = ""
};

bool g_bDownedByPair[MAXPLAYERS + 1][MAXPLAYERS + 1];

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_incapacitated", Event_PlayerIncapped, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerIncapped, EventHookMode_Post);
    HookEvent("revive_success", Event_PlayerRevived, EventHookMode_Post);
    HookEvent("round_start", Event_ResetState, EventHookMode_PostNoCopy);
    HookEvent("mission_lost", Event_ResetState, EventHookMode_PostNoCopy);
    HookEvent("map_transition", Event_ResetState, EventHookMode_PostNoCopy);

    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client))
        {
            SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
        }
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
    ClearClientPairs(client);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidSurvivor(client))
    {
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    }
}

public void Event_PlayerIncapped(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (!IsValidSurvivor(victim) || !IsValidSurvivor(attacker) || attacker == victim)
    {
        return;
    }

    g_bDownedByPair[attacker][victim] = true;
}

public void Event_PlayerRevived(Event event, const char[] name, bool dontBroadcast)
{
    // Pair state intentionally survives revive and respawn.
}

public void Event_ResetState(Event event, const char[] name, bool dontBroadcast)
{
    ResetAllPairs();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage,
    int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
    if (!IsValidSurvivor(victim) || !IsValidSurvivor(attacker) || victim == attacker)
    {
        return Plugin_Continue;
    }

    if (!g_bDownedByPair[attacker][victim] || damage <= 0.0 || !IsPlayerAlive(victim)
        || GetEntProp(victim, Prop_Send, "m_isIncapacitated") != 0)
    {
        return Plugin_Continue;
    }

    float victimHealth = float(GetClientHealth(victim));
    if (damage < victimHealth)
    {
        return Plugin_Continue;
    }

    float reflectedDamage = damage;
    damage = 0.0;

    if (reflectedDamage > 0.0 && IsPlayerAlive(attacker))
    {
        float attackerHealth = float(GetClientHealth(attacker));
        float safeDamage = attackerHealth - 1.0;
        if (safeDamage > 0.0)
        {
            if (reflectedDamage > safeDamage)
            {
                reflectedDamage = safeDamage;
            }
            // Apply reflected damage directly so this protection can never
            // trigger the normal incapacitation path on the attacker.
            SetEntityHealth(attacker, RoundToFloor(attackerHealth - reflectedDamage));
        }
    }

    if (IsClientInGame(attacker))
    {
        PrintToChat(attacker, "\x04[!]\x01 你对 \x03%N\x01 玩家黑枪太多了。", victim);
    }

    return Plugin_Changed;
}

bool IsValidSurvivor(int client)
{
    return client >= 1 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}

void ResetAllPairs()
{
    for (int attacker = 1; attacker <= MaxClients; attacker++)
    {
        for (int victim = 1; victim <= MaxClients; victim++)
        {
            g_bDownedByPair[attacker][victim] = false;
        }
    }
}

void ClearClientPairs(int client)
{
    for (int other = 1; other <= MaxClients; other++)
    {
        g_bDownedByPair[client][other] = false;
        g_bDownedByPair[other][client] = false;
    }
}
