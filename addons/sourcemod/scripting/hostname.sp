#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo = {
	name = "hostname",
	author = "LinGe",
	description = "服务器名",
	version = "0.1",
	url = "https://github.com/Lin515/L4D_LinGe_Plugins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion game = GetEngineVersion();
	if (game!=Engine_Left4Dead && game!=Engine_Left4Dead2)
	{
		strcopy(error, err_max, "本插件只支持 Left 4 Dead 1&2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

#define HOSTNAME_CONFIG "data/hostname.txt"
ConVar cv_hostname;
char g_hostname[200];

public void OnPluginStart()
{
	KeyValues kv_hostname = new KeyValues("hostname");
	ConVar cv_hostport = FindConVar("hostport");
	cv_hostname	= FindConVar("hostname");

	char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), HOSTNAME_CONFIG);
	if (FileExists(filePath))
	{
		if (!kv_hostname.ImportFromFile(filePath))
		{
			SetFailState("导入 %s 失败！", filePath);
		}
	}

	char port[20];
	FormatEx(port, sizeof(port), "%d", cv_hostport.IntValue);
	kv_hostname.JumpToKey(port);
	kv_hostname.GetString("hostname", g_hostname, sizeof(g_hostname), "Left 4 Dead 2");
	cv_hostname.SetString(g_hostname);
}

public void OnConfigsExecuted()
{
	cv_hostname.SetString(g_hostname);
}