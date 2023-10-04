#include <sourcemod>
#include <left4dhooks>

public void OnPluginStart(){
    RegConsoleCmd("sm_postest", CMD_ReachAble_Test)
}

public Action CMD_ReachAble_Test(int client, int args){
    float pos[3], pos2[3];
    int compareclient;
    for (int i = 1; i <= MaxClients; i++){
        if (!IsClientInGame(i)) continue;
        if (i != client) {compareclient = i;break;}
    }
    GetClientAbsOrigin(client, pos);
    GetClientAbsOrigin(compareclient, pos2);
    PrintToConsole(client, "L4D_GetNearestNavArea: %i", L4D_GetNearestNavArea(pos));
    PrintToConsole(client, "L4D2_VScriptWrapper_NavAreaBuildPath: %s", L4D2_VScriptWrapper_NavAreaBuildPath(pos2, pos, 1000.0, false, false, 2, false) ? "true" : "false");
    return Plugin_Handled;
}