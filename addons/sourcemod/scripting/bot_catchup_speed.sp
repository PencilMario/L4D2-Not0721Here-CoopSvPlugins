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
    description = "Helps survivor Bots catch the nearest living human",
    version = "2.1.0",
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

    if (ShouldGatherBotsInEndCheckpoint())
    {
        GatherBotsInEndCheckpoint();
        return Plugin_Continue;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || !IsFakeClient(client) ||
            GetClientTeam(client) != TEAM_SURVIVOR || !IsPlayerAlive(client))
        {
            continue;
        }

        int nearestHuman;
        float distance;
        if (!FindNearestLivingHuman(client, nearestHuman, distance))
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            UpdateCatchupAdrenaline(client, false);
            continue;
        }

        float catchupSteps;
        bool enableAdrenaline;
        CalculateCatchupState(client, nearestHuman, distance, mapFlow, catchupSteps, enableAdrenaline);

        float speed = 1.0 + catchupSteps * 0.1;
        if (catchupSteps > 0.0 && !Player_IsVisible_To_AnyPlayer(client, true))
        {
            speed *= 1.25;
        }
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed);

        UpdateCatchupAdrenaline(client, enableAdrenaline);
    }

    return Plugin_Continue;
}

bool FindNearestLivingHuman(int client, int &nearestHuman, float &nearestDistance)
{
    float clientPos[3], humanPos[3];
    GetClientAbsOrigin(client, clientPos);

    bool found = false;
    for (int human = 1; human <= MaxClients; human++)
    {
        if (!IsClientInGame(human) || IsFakeClient(human) ||
            GetClientTeam(human) != TEAM_SURVIVOR || !IsPlayerAlive(human))
        {
            continue;
        }

        GetClientAbsOrigin(human, humanPos);
        float distance = GetVectorDistance(clientPos, humanPos);
        if (!found || distance < nearestDistance)
        {
            nearestHuman = human;
            nearestDistance = distance;
            found = true;
        }
    }
    return found;
}

void CalculateCatchupState(int bot, int human, float distance, float mapFlow,
    float &catchupSteps, bool &enableAdrenaline)
{
    float botFlow = L4D2Direct_GetFlowDistance(bot);
    float humanFlow = L4D2Direct_GetFlowDistance(human);

    if (mapFlow > 0.0 && botFlow >= 0.0 && humanFlow >= 0.0)
    {
        float lagPercent = (humanFlow - botFlow) / mapFlow * 100.0;
        if (lagPercent < 0.0)
        {
            lagPercent = 0.0;
        }
        catchupSteps = float(RoundToFloor(lagPercent));
        enableAdrenaline = lagPercent > ADRENALINE_THRESHOLD;
        return;
    }

    catchupSteps = float(RoundToFloor(distance / 1000.0));
    enableAdrenaline = distance > 10000.0;
}

bool ShouldGatherBotsInEndCheckpoint()
{
    bool foundLivingHuman = false;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || GetClientTeam(client) != TEAM_SURVIVOR ||
            !IsPlayerAlive(client))
        {
            continue;
        }

        if (IsClientIncapped(client) || IsClientHanging(client))
        {
            return false;
        }

        if (!IsFakeClient(client))
        {
            foundLivingHuman = true;
            if (!L4D_IsInLastCheckpoint(client))
            {
                return false;
            }
        }
    }

    return foundLivingHuman;
}

void GatherBotsInEndCheckpoint()
{
    for (int bot = 1; bot <= MaxClients; bot++)
    {
        if (!IsClientInGame(bot) || !IsFakeClient(bot) ||
            GetClientTeam(bot) != TEAM_SURVIVOR || !IsPlayerAlive(bot) ||
            L4D_IsInLastCheckpoint(bot))
        {
            continue;
        }

        int nearestHuman;
        float distance;
        if (!FindNearestLivingHuman(bot, nearestHuman, distance))
        {
            continue;
        }

        float destination[3];
        GetClientAbsOrigin(nearestHuman, destination);
        TeleportEntity(bot, destination, NULL_VECTOR, NULL_VECTOR);
        L4D_WarpToValidPositionIfStuck(bot);
        SetEntPropFloat(bot, Prop_Send, "m_flLaggedMovementValue", 1.0);
        UpdateCatchupAdrenaline(bot, false);
    }
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
