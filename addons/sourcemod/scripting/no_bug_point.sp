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


public bool GetClientPosStatus(int client){
    float pos[3], pos2[3];
    GetClientAbsOrigin(client, pos);
    int surt = 0;
    int inft1 = 0;
    int inft2 = 0
    bool result[3];
    while(surt == 0 || surt == client){
        if (GetSurvivorCount() == 1) break;
        surt = GetRandomSurvivor(1);
    }
    inft1 = GetRandomInfected(1);
    inft2 = GetRandomInfected(1);
    if (surt) {
        GetClientAbsOrigin(inft1, pos2);
        result[0] = L4D2_VScriptWrapper_NavAreaBuildPath(pos2, pos, 3000.0, false, false, 2, false);
    }
    if (inft1) {
        GetClientAbsOrigin(inft1, pos2);
        result[1] = L4D2_VScriptWrapper_NavAreaBuildPath(pos2, pos, 3000.0, false, false, 2, false);
    }
    if (inft2) {
        GetClientAbsOrigin(inft2, pos2);
        result[2] = L4D2_VScriptWrapper_NavAreaBuildPath(pos2, pos, 3000.0, false, false, 2, false);
    }
    return result[0] || result [1] || result[2]
}