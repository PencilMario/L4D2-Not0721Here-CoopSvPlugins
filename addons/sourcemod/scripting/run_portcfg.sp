#include <sourcemod>

ConVar g_cPort;

public void OnPluginStart(){
    g_cPort = FindConVar("hostport");
    RegServerCmd("sm_execportcfg", CMD_RunPortCfg);
    CMD_RunPortCfg(0)
}

public Action CMD_RunPortCfg(int args){
    PrintToServer("exec serverport_%i.cfg", g_cPort.IntValue);
    ServerCommand("exec serverport_%i.cfg", g_cPort.IntValue);
    PrintToServer("exec spcontrol_server/serverport_%i.cfg", g_cPort.IntValue);
    ServerCommand("exec spcontrol_server/serverport_%i.cfg", g_cPort.IntValue);
    return Plugin_Handled;
}

