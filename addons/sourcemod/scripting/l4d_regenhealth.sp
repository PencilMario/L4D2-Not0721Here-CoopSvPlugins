#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <left4dhooks>
#include <l4d2util>

Handle g_hHealingTimer;
// 开关
ConVar g_cHealEnabled;
// 呼吸回血
ConVar g_cHealRec_PerTick, g_cHealRec_MaxHealth;
// 呼吸回血 - 根据血型决定回血速度(tick)
ConVar g_cHealRec_HealSpeedRed, g_cHealRec_HealSpeedYellow, g_cHealRec_HealSpeedGreen;
// 呼吸回血 - 受伤暂停时间Tick
ConVar g_cHealRec_HealInjuredPause;
// 击杀回血
ConVar g_cHealKill_PerTick, g_cHeal_MaxHealth;
int g_iHealHealth[MAXPLAYERS + 1];
int g_iNextHealTick[MAXPLAYERS + 1];

public Plugin myinfo = {
	name = "Heal me！",
	author = "sp",
	description = "随便写的回血插件",
	version = "0.1",
	url = ""
};

public void OnPluginStart()
{
    g_cHealEnabled = CreateConVar("sm_heal_enable", "1", "插件是否启用");
    g_cHeal_MaxHealth = CreateConVar("sm_heal_maxhealth", "200", "回血上限");
    g_cHealRec_PerTick = CreateConVar("sm_healtime_health", "1", "呼吸回血每跳的回血值");
    g_cHealRec_MaxHealth = CreateConVar("sm_healtime_health", "60", "呼吸回血的上限值");
    g_cHealRec_HealInjuredPause = CreateConVar("sm_healtime_injuredpausetime", "30", "受伤时, 暂停多久回血");
    g_cHealRec_HealSpeedRed = CreateConVar("sm_healtime_redtime", "2", "红血时，多久回血一次（单位为0.1s，下同）");
    g_cHealRec_HealSpeedYellow = CreateConVar("sm_healtime_redtime", "5", "黄血时，多久回血一次（单位为0.1s，下同）");
    g_cHealRec_HealSpeedGreen = CreateConVar("sm_healtime_redtime", "13", "绿血时，多久回血一次（单位为0.1s，下同）");
    g_cHealKill_PerTick = CreateConVar("sm_healkill_persi", "3", "杀一只特感的回血数(也许是杀一只ss...");
    

    HookEvent("player_hurt", PlayerHure_Event);
	HookEvent("player_death", PlayerDeath_Event);

}

public void OnMapStart()
{
    g_hHealingTimer = CreateTimer(0.1, Timer_Health, _,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Health(Handle timer)
{
    if (g_cHealEnabled.IntValue)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && GetClientTeam(i) == L4D2Team_Survivor){
                g_iNextHealTick[i]--;
                if (g_iHealHealth[i]){
                    AddPlayerHealth2(i, g_iHealHealth[i]);
                    g_iHealHealth[i] = 0;
                } 
                if (!g_iNextHealTick[i])
                {
                    AddPlayerHealth(i, g_cHealRec_PerTick.IntValue);
                    int h = GetPlayerHealth(i);
                    if (h<g_cHealRec_MaxHealth.IntValue) g_iNextHealTick[i] = g_cHealRec_HealSpeedGreen.IntValue;
                    if (h<40 && h<g_cHealRec_MaxHealth.IntValue) g_iNextHealTick[i] = g_cHealRec_HealSpeedYellow.IntValue;
                    if (h<25 && h<g_cHealRec_MaxHealth.IntValue) g_iNextHealTick[i] = g_cHealRec_HealSpeedRed.IntValue;
                }
            }
        }
    }
    return Plugin_Continue;
}

public int GetPlayerHealth(int player){
	return GetClientHealth(player);
}

public void SetPlayerHealthRe(int player, int health){
	if (health > g_cHealRec_MaxHealth.IntValue) health = g_cHealRec_MaxHealth.IntValue;
	int h2 = L4D_GetPlayerTempHealth(player);
	if(h2 + health < g_cHealRec_MaxHealth.IntValue){
		SetEntityHealth(player, health);
	}
	else{
		SetEntityHealth(player, g_cHealRec_MaxHealth.IntValue-h2);
	}
}

public void SetPlayerHealth(int player, int health){
	if (health > g_cHeal_MaxHealth.IntValue) health = g_cHeal_MaxHealth.IntValue;
	int h2 = L4D_GetPlayerTempHealth(player);
	if(h2 + health < g_cHeal_MaxHealth.IntValue){
		SetEntityHealth(player, health);
	}
	else{
		SetEntityHealth(player, g_cHeal_MaxHealth.IntValue-h2);
	}
}

public void AddPlayerHealth(int player, int health)
{
    int h = GetPlayerHealth(player);
    SetPlayerHealthRe(player, h+health);
}
public void AddPlayerHealth2(int player, int health)
{
    int h = GetPlayerHealth(player);
    SetPlayerHealth(player, h+health);
}
public Action PlayerHure_Event(Event event, const char name[], bool dontBroadcast){
	int player = GetClientOfUserId(event.GetInt("userid"))
	if (IsClientInGame(player) && GetClientTeam(player)==L4D_TEAM_SURVIVOR){
		if (!IsIncapacitated(player))
		{
			g_iNextHealTick[player] = g_cHealRec_HealInjuredPause.IntValue;
		}
	}
}
public Action PlayerDeath_Event(Event event, const char name[], bool dontBroadcast){
	//if (event.GetBool("headshot") == false) return;
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (GetClientTeam(client)==L4D_TEAM_SURVIVOR){ 
        if (g_cHealEnabled.IntValue) g_iHealHealth[client] += g_cHealKill_PerTick.IntValue;
	}
}