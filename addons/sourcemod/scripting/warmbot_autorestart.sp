#include <sourcemod>
#include <left4dhooks>
#define GAMEDATA_FILE "l4d_predict_tank_glow"
#include <tankglow/tankglow_defines>
CZombieManager ZombieManager;
#define WARMBOT_STEAMID "STEAM_1:1:695917591"
bool g_bMapChanged;
float g_vTeleportPos[3], g_vTepeportAng[3];
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

public void OnPluginStart(){
    LoadSDK();
}

public void OnClientAuthorized(iTarget, const char[] strTargetSteamId)
{
    if (StrEqual(strTargetSteamId, WARMBOT_STEAMID)) 
    {
        if (!g_bMapChanged) CreateTimer(60.0, Timer_CheckAndRestartNewMap);
        else CreateTimer(5.0, Timer_TeleportWarmBot, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_TeleportWarmBot(Handle timer)
{
    if (GetWarmBot() == 0) return Plugin_Stop;
    if (!IsClientInGame(GetWarmBot())) return Plugin_Continue
    if (CountTruePlayers() < 1){
        ProcessSurPredictModel(g_vTeleportPos, g_vTepeportAng);
    }
    return Plugin_Stop;
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

int GetWarmBot(){
    for (int i = 1; i<= MaxClients; i++){
        if (IsWarmBot(i)) return i;
    }
    return 0;
}
/**
 * 获取TP位置并传送,感谢l4d_predict_tank_glow
 */
int ProcessSurPredictModel(float vPos[3], float vAng[3])
{
    // 从 -12% 反方向获取位置
    for (float p = GetRandomFloat(0.1, 0.5); p > 0.0; p -= 0.01)
    {
        TerrorNavArea nav = GetBossSpawnAreaForFlow(p);
        if (nav.Valid())
        {
            L4D_FindRandomSpot(view_as<int>(nav), vPos);
            vPos[2] -= 8.0; // less floating off ground
            
            vAng[0] = 0.0;
            vAng[1] = GetRandomFloat(0.0, 360.0);
            vAng[2] = 0.0;
            
            break;
        }
    }
    
    //PrintToConsole("已传送warmbot");
    if (GetVectorLength(vPos) == 0.0)
        return -1;
    if (GetWarmBot()) TeleportEntity(GetWarmBot(), vPos, vAng, NULL_VECTOR);
    return 0;

}

TerrorNavArea GetBossSpawnAreaForFlow(float flow)
{
    float vPos[3];
    TheEscapeRoute().GetPositionOnPath(flow, vPos);
    
    TerrorNavArea nav = TerrorNavArea(vPos);
    if (!nav.Valid())
        return NULL_NAV_AREA;
    
    ArrayList aList = new ArrayList();
    while( !nav.IsValidForWanderingPopulation()
        || nav.m_isUnderwater
        || (nav.GetCenter(vPos), vPos[2] += 10.0, !ZombieManager.IsSpaceForZombieHere(vPos))
        || nav.m_activeSurvivors )
    {
        if (aList.FindValue(nav) != -1)
        {
            delete aList;
            return NULL_NAV_AREA;
        }
        
        if (nav.Valid())
            aList.Push(nav);
        
        nav = nav.GetNextEscapeStep();
    }
    
    delete aList;
    return nav;
}
