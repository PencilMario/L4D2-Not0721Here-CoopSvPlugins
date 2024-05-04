#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

ConVar g_cHealEnable;  
public Plugin myinfo =
{
	name = "[L4D2] killheal",
	author = "SirP",
	description = "回血",
	version = "0.0.1",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("player_death", PlayerDeath_Event);
	g_cHealEnable = CreateConVar("sm_killheal_enable", "0", "是否启用杀特回血")
}



public Action PlayerDeath_Event(Event event, const String:name[], bool:dontBroadcast){
	if (g_cHealEnable.IntValue == 0) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (GetClientTeam(client)==L4D_TEAM_SURVIVOR){ 
		int health = GetPlayerHealth(client);
		SetPlayerHealth(client, health + 3);
		if (event.GetBool("headshot")) SetPlayerHealth(client, health + 7);
	}
	return Plugin_Continue;
}



public int GetPlayerHealth(int player){
	return GetSurvivorPermanentHealth(player);
}
public int GetPlayerTempHealth(int player){
	return GetSurvivorTemporaryHealth(player)
}

public void SetPlayerHealth(int player, int health){
	int maxhealth = GetEntProp(player, Prop_Send, "m_iMaxHealth") + 100;
	if (health >= maxhealth) health=maxhealth;
	new h2;
	h2 = GetPlayerTempHealth(player);
	if(h2 + health < maxhealth){
		SetEntityHealth(player, health);
	}
	else{
		SetEntityHealth(player, maxhealth-h2);
	}
}







