#include <sourcemod>
#include <sdktools>
#include <treeutil/treeutil.sp>


public void OnPluginStart(){
    CreateTimer(8.0, Timer_CheckAndTeleportBot, _, TIMER_REPEAT);
}


public Action Timer_CheckAndTeleportBot(Handle timer){
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (IsFakeClient(i)){
                int closetsur = GetClosetMobileSurvivor(i, -1, false);
                if (closetsur != 0){
                    if (GetClientDistance(i, closetsur) > 2000){
                        // 传送
                        float pos[3]
                        GetClientAbsOrigin(closetsur, pos);
                        TeleportEntity(i , pos, NULL_VECTOR, NULL_VECTOR);
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}
