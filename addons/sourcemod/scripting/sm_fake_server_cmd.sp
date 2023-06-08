#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

char g_cCurrentCmd[64];

public void OnPluginStart()
{
    RegServerCmd("sm_svcmd", Cmd_ServerCommand, "服务端执行作弊指令");
}

public Action Cmd_ServerCommand(int args)
{
    GetCmdArgString(g_cCurrentCmd, 64);
    CheatCommand(g_cCurrentCmd);
    return Plugin_Handled;
}

public void CheatCommand(char[] strCommand)
{
    int flags = GetCommandFlags(strCommand);
    SetCommandFlags(strCommand, flags & ~FCVAR_CHEAT);
    ServerCommand("%s", strCommand);
    Format(g_cCurrentCmd, 64, "%s", strCommand);
    //SetCommandFlags(strCommand, flags);
    CreateTimer(0.5, RestoreCheatFlag);
}

public Action RestoreCheatFlag(Handle timer)
{
    int flags = GetCommandFlags(g_cCurrentCmd);
    SetCommandFlags(g_cCurrentCmd, flags | FCVAR_CHEAT);
    return Plugin_Stop;
}