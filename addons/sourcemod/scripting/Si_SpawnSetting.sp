#include <sourcemod>
#include <sdktools>
#include <multicolors>

ConVar SS_1_SiNum;
ConVar SS_Time;

ConVar g_cAutoMode, g_cAutoTime, g_cAutoPerPTimeDe, g_cAutoSiLim, g_cAutoSiPIn;

public Plugin myinfo =
{
	name = "Ast SI Spawn Set Plugin",
	author = "Sir.P",
	description = "修改特感脚本的刷新数量",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_SetAiSpawns", Cmd_SetAiSpawns);
	RegConsoleCmd("sm_SetAiTime", Cmd_SetAiTime);
	SS_1_SiNum = CreateConVar("sss_1P", "18", "特感数量");
	SS_Time = CreateConVar("SS_Time", "15", "刷新间隔");

	g_cAutoMode = CreateConVar("sm_ss_automode", "1", "自动调整刷特模式（4+生还玩家）");
	g_cAutoPerPTimeDe = CreateConVar("sm_ss_autoperdetime", "1", "每多一名生还，特感的复活时间减少多少s");
	g_cAutoTime = CreateConVar("sm_ss_autotime", "35", "一只特感的基础复活时间");
	g_cAutoSiLim = CreateConVar("sm_ss_autosilim", "3", "在4名玩家时，基础特感数量");
	g_cAutoSiPIn = CreateConVar("sm_ss_autoperinsi", "1", "每多一名生还，增加几只特感");

	HookEvent("round_start", RoundStart_Event);

	HookConVarChange(SS_1_SiNum, reload_script);
	HookConVarChange(SS_Time, reload_script);
}

public Action RoundStart_Event(Event event, const String:name[], bool:dontBroadcast){
	FakeClientCommand(1, "sm_reloadscript");
	return Plugin_Continue;
}
public reload_script(Handle:convar, const String:oldValue[], const String:newValue[]){
	FakeClientCommand(1, "sm_reloadscript");
}
public void OnClientConnected(int client)
{
	if (IsFakeClient(client)) return;
	if (!g_cAutoMode.IntValue) return;
	AutoSetSi();
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue);

}
public void OnClientDisconnect(int client)
{
	OnClientConnected(client);
}
void AutoSetSi()
{
	int players = GetConnectedPlayer(0);
	if (players <= 4)
	{
		SS_1_SiNum.IntValue = g_cAutoSiLim.IntValue;
		SS_Time.IntValue = g_cAutoTime.IntValue;
		isLegalSetting();
		return;
	}
	SS_1_SiNum.IntValue = g_cAutoSiLim.IntValue + g_cAutoSiPIn.IntValue * (players - 4);
	SS_Time.IntValue = g_cAutoTime.IntValue - g_cAutoPerPTimeDe.IntValue * (players - 4);
	isLegalSetting();
	return;
}

void isLegalSetting()
{
	ConVar sv_setmax = FindConVar("sv_setmax");
	int players = GetConnectedPlayer(0);
	if (players + SS_1_SiNum.IntValue > sv_setmax.IntValue) SS_1_SiNum.IntValue = sv_setmax.IntValue - players;
	if (SS_Time.IntValue < 0) SS_Time.IntValue = 0;
	return;
}

public int SILimit(int num){
	int Si = num/6;
	if (Si*6 != num) Si++;
	if (Si <= 0) Si=1;
	return Si
}

int GetConnectedPlayer(int client) {
	int count;
	for (int i = 1; i <= MaxClients; i++) {
		if (i != client && IsClientAuthorized(i) && !IsFakeClient(i))
			count++;
	}
	return count;
}


public Action Cmd_SetAiTime(int client, int args)
{
	int time;
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_SetAiTime <刷新间隔>");
		return Plugin_Handled;
	}
	time = GetCmdArgInt(1);
	SS_Time.IntValue = time;
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%N{default}修改了特感刷新配置", client);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue);
	FakeClientCommand(client, "sm_reloadscript");
	return Plugin_Continue;
}

public Action Cmd_SetAiSpawns(int client, int args)
{
	int SiNum;

	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_SetAiSpawns <特感数量>");
		return Plugin_Handled;
	}
	SiNum = GetCmdArgInt(1);
	SS_1_SiNum.IntValue = SiNum;
	
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue);
	FakeClientCommand(client, "sm_reloadscript");
	return Plugin_Continue;
}