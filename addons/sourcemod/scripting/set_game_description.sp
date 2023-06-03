#include <sourcemod>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

char g_sName[64];
char g_sMapName[64];
ConVar config;

public Plugin myinfo = {
    name = "Description",
    author = "sp",
    description = "修改游戏desc",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart(){
    config = CreateConVar("l4d_config_name", "", "配置名称");
}

public void OnMapStart()
{   
    char cfgName[32];
    if (config != INVALID_HANDLE){
        config.GetString(cfgName, sizeof(cfgName));
        Format(g_sName, sizeof(g_sName), "%s", cfgName);
    }
    GetCurrentMap(g_sMapName, sizeof(g_sMapName));
}

public void OnGameFrame()
{
    SteamWorks_SetGameDescription(g_sName);
    SteamWorks_SetMapName(g_sMapName);
}
