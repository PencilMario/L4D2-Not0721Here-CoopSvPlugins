#include <sourcemod>

#define WARMBOT_STEAMID "STEAM_1:1:695917591"
bool g_bMapChanged;
enum FirstMapList
{
    C1,C2,C3,C4,C5,C6,C7,C8,C9,C19,C11,C12,C13,C14,
	FirstMapList_Size 
}

char L4D2_FirstMaps[FirstMapList_Size][] = {
    "c1m1_hotel",
    "c2m1_highway",
    "c3m1_plankcountry",
    "c4m1_milltown_a",
    "c5m1_waterfront",
    "c6m1_riverbank",
    "c7m1_docks",
    "c8m1_apartment",
    "c9m1_alleys",
    "c10m1_caves",
    "c11m1_greenhouse",
    "c12m1_hilltop",
    "c13m1_alpinecreek",
    "c14m1_junkyard"
};

public void OnClientAuthorized(iTarget, const char[] strTargetSteamId)
{
    if (StrEqual(strTargetSteamId, WARMBOT_STEAMID) && !g_bMapChanged) CreateTimer(60.0, Timer_CheckAndRestartNewMap)
}

public Action Timer_CheckAndRestartNewMap(Handle timer)
{
    if (CountTruePlayers() < 1){
        int map = GetRandomInt(0, view_as<int>(FirstMapList_Size)-1)
        ServerCommand("changelevel %s", L4D2_FirstMaps[map])
        g_bMapChanged = true;
    }
    return Plugin_Stop;
}

public int CountTruePlayers()
{
    int count = 0;
    for (int i = 1; i <=MaxClients; i++){
        if (IsClientInGame(i) && !IsFakeClient(i) && !IsWarmBot(i)) count++;
    }
    return count;
}

bool IsWarmBot(int client)
{
    char steamid[64];
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid))
    return StrEqual(steamid, WARMBOT_STEAMID);
}