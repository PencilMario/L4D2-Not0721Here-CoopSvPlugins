#include <sourcemod>
#include <left4dhooks>
#include <treeutil/treeutil.sp>
enum PlayerPosStatus{
    POS_CantCheckNow,
    POS_OK,
    POS_Bug
}
public void OnPluginStart(){
    RegConsoleCmd("sm_postest", CMD_ReachAble_Test)
}

public Action CMD_ReachAble_Test(int client, int args){
    PrintToConsole(client, "GetClientPosStatus: %i", GetClientPosStatus(client));
    return Plugin_Handled;
}


public PlayerPosStatus GetClientPosStatus(int client){
    float pos[3], pos2[3];
    int compareclient = 0;
    GetClientAbsOrigin(client, pos);
    for (int i = 1; i <= MaxClients; i++){
        if (!IsClientInGame(i)) continue;
        if (!IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;
        GetClientAbsOrigin(i, pos2);
        if (GetVectorDistance(pos, pos2) > 2500.0) continue;
        if (i != client) {compareclient = i;break;}
        
    }
    if (compareclient == 0) return POS_CantCheckNow;
    if (L4D2_VScriptWrapper_NavAreaBuildPath(pos2, pos, GetVectorDistance(pos, pos2)*1.5, false, false, 2, false)) return POS_OK;
    else return POS_Bug;
}