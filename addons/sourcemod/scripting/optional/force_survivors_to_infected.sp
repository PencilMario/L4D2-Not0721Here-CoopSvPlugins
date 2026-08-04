#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "Force Survivors To Infected",
    author = "P",
    description = "Moves human players from the Survivor team to the Infected team.",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart()
{
    HookEvent("player_team", Event_PlayerTeam);
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    if (event.GetInt("team") != 2)
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client))
    {
        return;
    }

    RequestFrame(MoveSurvivorToInfected, GetClientUserId(client));
}

public void MoveSurvivorToInfected(any userId)
{
    int client = GetClientOfUserId(userId);
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2)
    {
        return;
    }

    ChangeClientTeam(client, 3);
}
