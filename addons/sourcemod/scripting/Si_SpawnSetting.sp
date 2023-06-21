#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#include <sirputil/better_mutations4.sp>
ConVar SS_1_SiNum;
ConVar SS_Time;
ConVar SS_EnableRelax;
ConVar SS_DPSLimit;
ConVar g_cAutoMode, g_cAutoTime, g_cAutoPerPTimeDe, g_cAutoSiLim, g_cAutoSiPIn;
ConVar g_cEnableM4Fix;

Handle g_TResetSpecialsTimer;
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
	RegConsoleCmd("sm_SetDpsLim", Cmd_SetDpsLim);
	SS_1_SiNum = CreateConVar("sss_1P", "3", "特感数量");
	SS_Time = CreateConVar("SS_Time", "35", "刷新间隔");
	SS_EnableRelax = CreateConVar("SS_Relax", "1", "允许relax");
	SS_DPSLimit = CreateConVar("SS_DPSSiLimit", "10", "DPS特感数量限制");
	g_cAutoMode = CreateConVar("sm_ss_automode", "1", "自动调整刷特模式（4+生还玩家）");
	g_cAutoPerPTimeDe = CreateConVar("sm_ss_autoperdetime", "1", "每多一名生还，特感的复活时间减少多少s");
	g_cAutoTime = CreateConVar("sm_ss_autotime", "35", "一只特感的基础复活时间");
	g_cAutoSiLim = CreateConVar("sm_ss_autosilim", "3", "在4名玩家时，基础特感数量");
	g_cAutoSiPIn = CreateConVar("sm_ss_autoperinsi", "1", "每多一名生还，增加几只特感");
	g_cEnableM4Fix = CreateConVar("sm_ss_fixm4spawn", "0", "是否启用绝境修复");
	

	HookEvent("round_start", RoundStart_Event);

	HookConVarChange(SS_1_SiNum, reload_script);
	HookConVarChange(SS_Time, reload_script);
	HookConVarChange(g_cAutoMode, reload_script);
	HookConVarChange(SS_DPSLimit, reload_script);
	HookConVarChange(SS_EnableRelax, OnRelaxChanged);
	HookConVarChange(g_cEnableM4Fix, OnM4FixChanged)
}
public void OnMapInit()
{
	if (g_cEnableM4Fix.IntValue == 1) CheckValues();
}
public Action RoundStart_Event(Event event, const String:name[], bool:dontBroadcast){
	if (g_cAutoMode.IntValue == 1) AutoSetSi();
	CheatCommand("sm_reloadscript", "");
	if (SS_EnableRelax.IntValue == 1){
		if (g_TResetSpecialsTimer != INVALID_HANDLE){
			KillTimer(g_TResetSpecialsTimer);
			g_TResetSpecialsTimer = INVALID_HANDLE;
		}
	}else{
		g_TResetSpecialsTimer = CreateTimer(1.0, Timer_ResetSpecialsCountdownTime, _, TIMER_REPEAT);
	}
	return Plugin_Continue;
}
public reload_script(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (g_cAutoMode.IntValue == 1) AutoSetSi();
	CheatCommand("sm_reloadscript", "");
}
public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client)) return;
	if (g_cAutoMode.IntValue != 1) return;
	AutoSetSi();
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue, SS_DPSLimit.IntValue, SS_EnableRelax.IntValue);
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client)) return;
	if (g_cAutoMode.IntValue != 1) return;
	CreateTimer(2.0, SetSi,client);
}

public Action SetSi(Handle timer, int client)
{
	AutoSetSi();
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue, SS_DPSLimit.IntValue, SS_EnableRelax.IntValue);
	return Plugin_Stop;
}
public OnM4FixChanged(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (g_cEnableM4Fix.IntValue == 1){
		CheckValues();
	}else{
		g_bFixUnlimitSpawnsEnable = false;
		CPrintToChatAll("{green}[{lightgreen}!{green}] {default}即将重启地图");
		CreateTimer(5.0, Timer_RestartMap);
	}
}
public OnRelaxChanged(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (SS_EnableRelax.IntValue == 1){
		if (g_TResetSpecialsTimer != INVALID_HANDLE){
			KillTimer(g_TResetSpecialsTimer);
			g_TResetSpecialsTimer = INVALID_HANDLE;
		}
	}else{
		g_TResetSpecialsTimer = CreateTimer(1.0, Timer_ResetSpecialsCountdownTime, _, TIMER_REPEAT);
	}
}

public Action Timer_RestartMap(Handle Timer){
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	ServerCommand("changelevel %s", mapname);
	return Plugin_Handled;
}
public Action Timer_ResetSpecialsCountdownTime(Handle Timer)
{
	for (int i = 1; i < 7; i++)
	{
		CountdownTimer SiTimer = L4D2Direct_GetSIClassSpawnTimer(i);
		if (CTimer_GetCountdownDuration(SiTimer) > 5.0) CTimer_Start(SiTimer, 0.5);
	}
	return Plugin_Continue;
}
void AutoSetSi()
{
	int players = GetConnectedPlayer(0);
	if (players <= 4)
	{
		SS_1_SiNum.IntValue = g_cAutoSiLim.IntValue;
		SS_Time.IntValue = g_cAutoTime.IntValue;
		isLegalSetting();
		CheatCommand("sm_reloadscript", "");
		return;
	}
	SS_1_SiNum.IntValue = g_cAutoSiLim.IntValue + g_cAutoSiPIn.IntValue * (players - 4);
	SS_Time.IntValue = g_cAutoTime.IntValue - g_cAutoPerPTimeDe.IntValue * (players - 4);
	isLegalSetting();
	CheatCommand("sm_reloadscript", "");
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
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue, SS_DPSLimit.IntValue, SS_EnableRelax.IntValue);
	CheatCommand("sm_reloadscript", "");
	return Plugin_Continue;
}
public Action Cmd_SetDpsLim(int client, int args)
{
	int SiNum;

	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_SetDpsLim <特感数量>");
		return Plugin_Handled;
	}
	SiNum = GetCmdArgInt(1);
	SS_DPSLimit.IntValue = SiNum;
	
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue, SS_DPSLimit.IntValue, SS_EnableRelax.IntValue);
	CheatCommand("sm_reloadscript", "");
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
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	SS_1_SiNum.IntValue, SILimit(SS_1_SiNum.IntValue), SS_Time.IntValue, SS_DPSLimit.IntValue, SS_EnableRelax.IntValue);
	CheatCommand("sm_reloadscript", "");
	return Plugin_Continue;
}

public void CheatCommand(char[] strCommand, char[] strParam1)
{
	for (int client = 1; client <= MaxClients; ++client)
	{
		if (IsClientInGame(client))
		{
			int flags = GetCommandFlags(strCommand);
			SetCommandFlags(strCommand, flags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "%s %s", strCommand, strParam1);
			SetCommandFlags(strCommand, flags);
			return;
		}
	}
}