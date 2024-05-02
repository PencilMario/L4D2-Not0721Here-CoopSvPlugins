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
    float speed = 1.0;
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i)){go = true;break;}
    }
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i)){
                speed = 1.0;
                int cl = GetClosetSurvivor(i, -1, true);
                int te = GetClosetSurvivorDistance(i, cl, true);
                if (!Player_IsVisible_To_AnyPlayer(i, true) && go){
                    speed += 0.1;
                }
                speed += whatSpeedNeed(te);
                setClientSpeed(i, speed);
            }
        }
    }
    return Plugin_Continue;
}
float whatSpeedNeed(int distance){
    return float(distance) / 10000;
}
float setClientSpeed(int client, float speedmulti){
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speedmulti);
    return speedmulti;
}