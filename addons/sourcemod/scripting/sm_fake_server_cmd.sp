#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
char g_cCurrentCmd[64];

public void OnPluginStart()
{
    RegServerCmd("sm_svcmd", Cmd_ServerCommand, "服务端绕过sv_cheats执行作弊指令");
    RegServerCmd("sm_sendvar", Cmd_SendVar, "服务端设置客户端的部分cvar");
}

public Action Cmd_SendVar(int args)
{
    if (args < 2)
	{
		PrintToServer("[SM] Usage: sm_sendvar <cvar> <value>");
    }
    char cvar[64];
    GetCmdArg(1, cvar, sizeof(cvar));
    char value[64];
    GetCmdArg(2, value, sizeof(value));
    for (int i = 1; i <= MaxClients; i++){
        SendConVarValue(i, FindConVar(cvar), value);
    }
    return Plugin_Handled;
}
public Action Cmd_ServerCommand(int args)
{
    GetCmdArgString(g_cCurrentCmd, 64);
    CheatCommand(g_cCurrentCmd);
    return Plugin_Handled;
}

public void CheatCommand(char[] strCommand)
{
    if (view_as<bool>(GetCommandFlags(strCommand) & FCVAR_CHEAT))
    {
        int flags = GetCommandFlags(strCommand);
        SetCommandFlags(strCommand, flags & ~FCVAR_CHEAT);
        ServerCommand("%s", strCommand);
        Format(g_cCurrentCmd, 64, "%s", strCommand);
        DataPack pack;
        CreateDataTimer(0.5, RestoreCheatFlag, pack, TIMER_DATA_HNDL_CLOSE);
        pack.WriteString(strCommand);
    }
    else
    {
        ServerCommand("%s", strCommand);
    }

}

public Action RestoreCheatFlag(Handle timer, DataPack pack)
{
    char cmd[64];
    pack.Reset();
    pack.ReadString(cmd, sizeof(cmd));
    int flags = GetCommandFlags(cmd);
    SetCommandFlags(cmd, flags | FCVAR_CHEAT);
    return Plugin_Stop;
}