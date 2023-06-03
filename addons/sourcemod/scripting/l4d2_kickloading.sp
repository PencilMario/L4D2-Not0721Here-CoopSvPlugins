#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#define PLUGIN_VERSION "1.2"

public Plugin myinfo = 
{
	name = "L4D Kick Load Stuckers",
	author = "AtomicStryker, HarryPotter",
	description = "踢出卡在服务器连接状态的玩家",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=103203"
}

Handle LoadingTimer[MAXPLAYERS+1] 	= {null};
ConVar cvarDuration 			= null;

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	bLate = late;
	return APLRes_Success; 
}

public void OnPluginStart()
{
	RegAdminCmd("sm_kickloading", KickLoaders, ADMFLAG_KICK, "踢掉所有连接中,却没加入游戏的人");
	RegAdminCmd("sm_kickloader", KickLoaders, ADMFLAG_KICK, "踢掉所有连接中,却没加入游戏的人");
	CreateConVar("l4d_kickloadstuckers_version", PLUGIN_VERSION, "此服务器上的 L4D Kick Load Stuckers 版本 ", 0|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvarDuration = CreateConVar("l4d_kickloadstuckers_duration", "60", "连接中,却没加入游戏的人. (秒 ", 	0|FCVAR_NOTIFY);
	
	AutoExecConfig(true, "l4d_kickloadstuckers");
	
	if(bLate)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsClientConnected(client) && !IsClientInGame(client))
			{
				LoadingTimer[client] = CreateTimer(cvarDuration.FloatValue, CheckClientIngame, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action KickLoaders(int client, int args)
{
	PrintToChatAll("管理员已踢出长时间未加载进入游戏玩家");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && !IsClientInGame(i))
		{
			//BanClient(i, 0, BANFLAG_AUTO, "Slowass Loading", "Slowass Loader");
			KickClient(i, "长时间未加载进入游戏，已被踢出");
		}
	}
	return Plugin_Handled;
}

public void OnClientConnected(int client)
{
	delete LoadingTimer[client];
	LoadingTimer[client] = CreateTimer(cvarDuration.FloatValue, CheckClientIngame, client, TIMER_FLAG_NO_MAPCHANGE); //on successfull connect the Timer is set in motion
}

public void OnClientDisconnect(int client)
{
	delete LoadingTimer[client];
}

public Action CheckClientIngame(Handle timer, any client)
{
	LoadingTimer[client] = null;

	if (!IsClientConnected(client)) return Plugin_Continue; //OnClientDisconnect() should handle this, but you never know
	
	if (!IsClientInGame(client))
	{
		char time[21];
		FormatTime(time, sizeof(time), "%d/%m/%Y %H:%M:%S", -1);
		//player log file code. name and steamid only
		char file[PLATFORM_MAX_PATH];
		char steamid[128];
		BuildPath(Path_SM, file, sizeof(file), "logs/stuckplayerlog.log");
	
		GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
		if (FindAdminByIdentity(AUTHMETHOD_STEAM, steamid) != INVALID_ADMIN_ID)
		{
			LogToFileEx(file, "[%s] %N (%s) - 由于管理员身份免疫踢出", time, client, steamid);
			return Plugin_Continue;
		}
		
		KickClient(client, "长时间未加载进入游戏，已被踢出");
	
		PrintToChatAll("%N 因卡在连接状态 %.0f 秒 而被踢", client, cvarDuration.FloatValue);
		
		LogToFileEx(file, "[%s] %N (%s) - 被 Slowass Loader 插件踢出", time, client, steamid); // this logs their steamids and names. to be banned.
	}
	
	return Plugin_Continue;
}