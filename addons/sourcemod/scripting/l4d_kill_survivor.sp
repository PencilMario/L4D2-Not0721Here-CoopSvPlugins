#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#define PLUGIN_VERSION "1.0"

public Plugin myinfo = {
	name		= "[L4D] Kill for Survivors",
	author		= "Danny & FlamFlam",
	description = "use the !kill command in chat",
	version		= PLUGIN_VERSION,
	url			= ""
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_explode", Kill_Me);
	RegConsoleCmd("sm_kill", Kill_Me);
	RegConsoleCmd("sm_zs", Kill_Me);
}

// kill
Action Kill_Me(int client, int args)
{
	if (GetClientTeam(client) == 2)
	{
		if (IsPlayerAlive(client))
		{
			ForcePlayerSuicide(client);
			CPrintToChatAll("[{green}!{default}] {olive}%N{default} 破防了", client);
		}
		else{
			CPrintToChat(client, "[{green}!{default}] 你已经死过了");
		}
	}
	else
	{
		CPrintToChat(client, "[{green}!{default}] 别ob了，进来再死");
	}
	return Plugin_Handled;
}

