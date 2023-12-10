#include <sourcemod>
#include <left4dhooks>
#include <l4d2util_survivors>
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

enum FirstAddonMapList
{
    AC1,AC2,AC3,AC4,AC5,AC6,
	FirstAddonMapList_Size 
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

char L4D2_FirstAddonMaps[FirstAddonMapList_Size][] = {
    "bdp_bunker01",// 深埋
    "zc_m1", //增城
    "uf1_boulevard",
    "msd1_town",
    "wfp1_track",
    "dw_woods", //黑色木头
};

public void OnPluginStart(){
    LoadSDK();

    RegServerCmd("sm_warptoper", CMD_TeleportAllSurvivortoPercent);
}

public Action CMD_TeleportAllSurvivortoPercent(int args){
    char buf[32];
    GetCmdArg(1, buf, sizeof(buf));
    float fTarget = StringToFloat(buf);
    fTarget = (fTarget > 0.1) ? fTarget : 0.1;
    if (fTarget >= 1.0){
        ServerCommand("sm_svcmd warp_all_survivors_to_checkpoint");
        return Plugin_Handled;
    }
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (GetClientTeam(i) == L4D2Team_Survivor) ProcessSurPredictModel(i, g_vTeleportPos, g_vTepeportAng, fTarget);
        }
    }
    return Plugin_Handled;
}

public void OnClientAuthorized(iTarget, const char[] strTargetSteamId)
{
    if (StrEqual(strTargetSteamId, WARMBOT_STEAMID)) 
    {
        if (!g_bMapChanged) CreateTimer(25.0, Timer_CheckAndRestartNewMap);
        else CreateTimer(5.0, Timer_TeleportWarmBot, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_TeleportWarmBot(Handle timer)
{
    int warmbot = GetWarmBot();
    if (warmbot == 0) return Plugin_Stop;
    if (!IsClientInGame(warmbot)) return Plugin_Continue;
    if (CountTruePlayers() < 1){
        if (!IsIncapacitated(warmbot) || !IsHangingFromLedge(warmbot)){
            ProcessSurPredictModel(warmbot, g_vTeleportPos, g_vTepeportAng, GetRandomFloat(0.1, 0.5));
            return Plugin_Continue;
        }
    }
    return Plugin_Stop;
}
public Action Timer_CheckAndRestartNewMap(Handle timer)
{
    if (CountTruePlayers() < 1){
        int map
        int c2addonmap = GetRandomInt(0, 1)
        if (c2addonmap == 0){
            map = GetRandomInt(0, view_as<int>(FirstMapList_Size)-1)
        } else {
            map = GetRandomInt(0, view_as<int>(FirstAddonMapList_Size)-1)
        }
        ServerCommand("changelevel %s", c2addonmap == 0 ? L4D2_FirstMaps[map] : L4D2_FirstAddonMaps[map])
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
void ProcessSurPredictModel(int client, float vPos[3], float vAng[3], float Target)
{
    // 从 -12% 反方向获取位置
    for (float p = Target; p > 0.0; p -= 0.01)
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
    

    TeleportEntity(client, vPos, vAng, NULL_VECTOR);
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
