#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <l4d2util_infected>
int g_iTimerTime;
enum struct SpawnSpeed{
    float time;
    int totalSI;
    int SIcount[10];
    int SiInterval[10];
}
SpawnSpeed SIData;
Panel g_hPanel;
public void OnPluginStart(){
    RegAdminCmd("sm_spawnspeedtest", Cmd_StartTest, ADMFLAG_ROOT, "执行测试");
}

void ResetData(){
    SIData.time = 0.0;
    SIData.totalSI = 0;
    for (int i = 0; i < sizeof(SIData.SIcount); i++)
    {
        SIData.SIcount[i] = 0;
    }
}

public Action Cmd_StartTest(int client, int args){
    if (args < 1)
	{
		PrintToServer("[SM] Usage: sm_spawnspeedtest <sec>");
        return Plugin_Handled;
    }
    ResetData();
    g_iTimerTime = GetCmdArgInt(1);
    PrintToChatAll("开始执行特感生成速度测试，请尽量保持推进");
    CreateTimer(1.0, Timer_TestLoop, _, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Handled;
}

public Action Timer_TestLoop(Handle timer){
    g_hPanel = new Panel();

    SIData.time++;
    for (int i = 0; i < sizeof(SIData.SiInterval); i++)
    {
        SIData.SiInterval[i]++;
    }
    for (int i = 1; i <= MaxClients; i++){
        if (!IsClientInGame(i)) continue;
        if (!IsInfected(i)) continue;
        if (!IsFakeClient(i)) continue;
        if (!IsPlayerAlive(i)) continue;
        SIData.SIcount[L4D2_GetPlayerZombieClass(i)]++;
        SIData.SiInterval[L4D2_GetPlayerZombieClass(i)] = 0;
        SIData.totalSI++;
        ForcePlayerSuicide(i);
    }
    char buffer[128];
    Format(buffer, sizeof(buffer), ">>>特感刷新速度测试中 -- 剩余%is<<<", g_iTimerTime);
    g_hPanel.SetTitle(buffer);
    g_hPanel.DrawText("");
    Format(buffer, sizeof(buffer), "已生成特感: %i / 上次刷新间隔", SIData.totalSI);
    g_hPanel.DrawText(buffer);
    
    Format(buffer, sizeof(buffer), "Smoker: %i/%is", SIData.SIcount[L4D2ZombieClass_Smoker], SIData.SiInterval[L4D2ZombieClass_Smoker]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Boomer: %i/%is", SIData.SIcount[L4D2ZombieClass_Boomer], SIData.SiInterval[L4D2ZombieClass_Boomer]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Hunter: %i/%is", SIData.SIcount[L4D2ZombieClass_Hunter], SIData.SiInterval[L4D2ZombieClass_Hunter]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Spitter: %i/%is", SIData.SIcount[L4D2ZombieClass_Spitter], SIData.SiInterval[L4D2ZombieClass_Spitter]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Jockey: %i/%is", SIData.SIcount[L4D2ZombieClass_Jockey], SIData.SiInterval[L4D2ZombieClass_Jockey]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Charger: %i/%is", SIData.SIcount[L4D2ZombieClass_Charger], SIData.SiInterval[L4D2ZombieClass_Charger]);
    g_hPanel.DrawText(buffer);
    g_hPanel.DrawText("");
    Format(buffer, sizeof(buffer), "平均刷特速度: %.1f/5s", float(SIData.totalSI) / ((SIData.time) / 5.0));
    g_hPanel.DrawText(buffer);

    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (!IsFakeClient(i)){
                g_hPanel.Send(i, DoNothing, 20);
            }
        }
    }
    g_hPanel.Close();
    if (--g_iTimerTime < 0){
        FinishPrint();
        return Plugin_Stop;
    }
    CreateTimer(1.0, Timer_TestLoop, _, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}
void FinishPrint(){
    g_hPanel = new Panel();
    char buffer[128];
    g_hPanel.SetTitle(">>> 特感刷新速度测试完成! <<<");
    g_hPanel.DrawText("");
    Format(buffer, sizeof(buffer), "已生成特感: %i / 上次刷新间隔", SIData.totalSI);
    g_hPanel.DrawText(buffer);
    
    Format(buffer, sizeof(buffer), "Smoker: %i/%is", SIData.SIcount[L4D2ZombieClass_Smoker], SIData.SiInterval[L4D2ZombieClass_Smoker]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Boomer: %i/%is", SIData.SIcount[L4D2ZombieClass_Boomer], SIData.SiInterval[L4D2ZombieClass_Boomer]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Hunter: %i/%is", SIData.SIcount[L4D2ZombieClass_Hunter], SIData.SiInterval[L4D2ZombieClass_Hunter]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Spitter: %i/%is", SIData.SIcount[L4D2ZombieClass_Spitter], SIData.SiInterval[L4D2ZombieClass_Spitter]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Jockey: %i/%is", SIData.SIcount[L4D2ZombieClass_Jockey], SIData.SiInterval[L4D2ZombieClass_Jockey]);
    g_hPanel.DrawText(buffer);
    Format(buffer, sizeof(buffer), "Charger: %i/%is", SIData.SIcount[L4D2ZombieClass_Charger], SIData.SiInterval[L4D2ZombieClass_Charger]);
    g_hPanel.DrawText(buffer);
    g_hPanel.DrawText("");
    Format(buffer, sizeof(buffer), "平均刷特速度: %.1f/5s", float(SIData.totalSI) / ((SIData.time) / 5.0));
    g_hPanel.DrawText(buffer);

    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (!IsFakeClient(i)){
                g_hPanel.Send(i, DoNothing, MENU_TIME_FOREVER);
            }
        }
    }
    g_hPanel.Close();
}
public int DoNothing(Handle menu, MenuAction action, int param1, int param2){
    return 0;
}