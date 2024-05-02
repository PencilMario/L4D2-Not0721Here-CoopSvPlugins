#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <treeutil/treeutil.sp>
#pragma newdecls required

public void OnMapStart(){
    CreateTimer(5.0, Timer_CheckAllBot, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckAllBot(Handle t){
    bool go = false;
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i)){go = true;break;}
    }
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (IsFakeClient(i)){
                if (!Player_IsVisible_To_AnyPlayer(i) && go){
                    if (GetClosetSurvivor(i, -1, true) > 1200)  setClientSpeed(i, 1.6);
                    else setClientSpeed(i, 1.25);
                }
                else setClientSpeed(i, 1.0);
            }
        }
    }
    return Plugin_Continue;
}
float setClientSpeed(int client, float speedmulti){
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speedmulti);
	return speedmulti;
}