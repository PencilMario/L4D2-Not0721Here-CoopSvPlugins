#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <treeutil/treeutil.sp>

#define CHECK_INTERVAL 5.0
#define ADRENALINE_REFRESH_TIME 6.0
#define ADRENALINE_THRESHOLD 10.0

bool g_bCatchupAdrenaline[MAXPLAYERS + 1];
bool g_bOwnsAdrenaline[MAXPLAYERS + 1];

public Plugin myinfo =
{
    name = "[L4D2] Survivor Bot Catch-up Speed",
    author = "Not0721Here",
    description = "Speeds up survivor Bots that fall behind every living human",
    version = "2.0.0",
    url = ""
};

public void OnPluginStart()
{
    HookEvent("entity_shoved", Event_EntityShoved);
}

public void OnMapStart()
{
    CreateTimer(CHECK_INTERVAL, Timer_CheckAllBots, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientDisconnect(int client)
{
    g_bCatchupAdrenaline[client] = false;
    g_bOwnsAdrenaline[client] = false;
}

public Action Timer_CheckAllBots(Handle timer)
{
    float mapFlow = L4D2Direct_GetMapMaxFlowDistance();
    float lastHumanFlow = 0.0;
    bool hasLivingHuman = FindLastLivingHumanFlow(lastHumanFlow);

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || !IsFakeClient(client) ||
            GetClientTeam(client) != TEAM_SURVIVOR || !IsPlayerAlive(client))
        {
            continue;
        }

        float lagPercent = 0.0;
        if (hasLivingHuman && mapFlow > 0.0)
        {
            float botFlow = L4D2Direct_GetFlowDistance(client);
            if (botFlow >= 0.0 && botFlow < lastHumanFlow)
            {
                lagPercent = (lastHumanFlow - botFlow) / mapFlow * 100.0;
            }
        }

        float speed = 1.0 + float(RoundToFloor(lagPercent)) * 0.1;
        if (lagPercent > 0.0 && !Player_IsVisible_To_AnyPlayer(client, true))
        {
            speed *= 1.25;
        }
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed);

        UpdateCatchupAdrenaline(client, lagPercent > ADRENALINE_THRESHOLD);
    }

    return Plugin_Continue;
}

bool FindLastLivingHumanFlow(float &lastHumanFlow)
{
    bool found = false;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || IsFakeClient(client) ||
            GetClientTeam(client) != TEAM_SURVIVOR || !IsPlayerAlive(client))
        {
            continue;
        }

        float flow = L4D2Direct_GetFlowDistance(client);
        if (flow < 0.0)
        {
            continue;
        }

        if (!found || flow < lastHumanFlow)
        {
            lastHumanFlow = flow;
            found = true;
        }
    }
    return found;
}

void UpdateCatchupAdrenaline(int client, bool enabled)
{
    if (enabled)
    {
        if (!g_bCatchupAdrenaline[client])
        {
            g_bOwnsAdrenaline[client] = GetEntProp(client, Prop_Send, "m_bAdrenalineActive") == 0;
        }
        g_bCatchupAdrenaline[client] = true;
        L4D2_UseAdrenaline(client, ADRENALINE_REFRESH_TIME, false, false);
        return;
    }

    if (g_bCatchupAdrenaline[client] && g_bOwnsAdrenaline[client])
    {
        SetEntProp(client, Prop_Send, "m_bAdrenalineActive", 0);
    }
    g_bCatchupAdrenaline[client] = false;
    g_bOwnsAdrenaline[client] = false;
}

public void Event_EntityShoved(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (attacker < 1 || attacker > MaxClients || !IsClientInGame(attacker) ||
        !IsFakeClient(attacker) || !g_bCatchupAdrenaline[attacker])
    {
        return;
    }

    int entity = event.GetInt("entityid");
    if (entity <= MaxClients || !IsValidEntity(entity))
    {
        return;
    }

    char classname[32];
    GetEntityClassname(entity, classname, sizeof(classname));
    if (StrEqual(classname, "infected"))
    {
        AcceptEntityInput(entity, "Kill");
    }
}
