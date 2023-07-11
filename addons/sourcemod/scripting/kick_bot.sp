#include <sourcemod>
#include <l4d2util_survivors>
public void OnPluginStart(){
    RegServerCmd("sm_kb", CMD_KickBots, "kickbot");
    RegServerCmd("sm_kickbot", CMD_KickBots, "kickbot");
}

public Action CMD_KickBots(int args){
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (GetClientTeam(i) == L4D2Team_Survivor && IsFakeClient(i)){
                KickClient(i);
            }
        }
    }
    return Plugin_Handled;
}