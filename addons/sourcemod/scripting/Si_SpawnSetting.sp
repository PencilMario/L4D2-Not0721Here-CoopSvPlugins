#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#include <sirputil/better_mutations4.sp>
#include <l4d2util>

ConVar SS_1_SiNum;
ConVar SS_Time;
ConVar SS_EnableRelax, SS_EnableFastRespawn;
ConVar SS_DPSLimit;
ConVar g_cAutoMode, g_cAutoTime, g_cAutoPerPTimeDe, g_cAutoSiLim, g_cAutoSiPIn;
ConVar g_cEnableM4Fix;
ConVar g_cBattlefieldRespawn, g_cInitialDelayMax, g_cInitialDelayMaxExtra;
ConVar g_cInitialDelayMin, g_cFinaleOfferLength, g_cOriginalOfferLength;

int g_iMaxSpecials;
int g_iClassLimit[7];
float g_fSpecialRespawnInterval;

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
	SS_EnableFastRespawn = CreateConVar("SS_FastRespawn", "0", "跳过relax时, 是否快速补特");
	SS_DPSLimit = CreateConVar("SS_DPSSiLimit", "10", "DPS特感数量限制");
	g_cAutoMode = CreateConVar("sm_ss_automode", "1", "自动调整刷特模式（4+生还玩家）");
	g_cAutoPerPTimeDe = CreateConVar("sm_ss_autoperdetime", "1", "每多一名生还，特感的复活时间减少多少s");
	g_cAutoTime = CreateConVar("sm_ss_autotime", "35", "一只特感的基础复活时间");
	g_cAutoSiLim = CreateConVar("sm_ss_autosilim", "3", "在4名玩家时，基础特感数量");
	g_cAutoSiPIn = CreateConVar("sm_ss_autoperinsi", "1", "每多一名生还，增加几只特感");
	g_cEnableM4Fix = CreateConVar("sm_ss_fixm4spawn", "0", "是否启用绝境修复");

	g_cBattlefieldRespawn = FindConVar("director_special_battlefield_respawn_interval");
	g_cInitialDelayMax = FindConVar("director_special_initial_spawn_delay_max");
	g_cInitialDelayMaxExtra = FindConVar("director_special_initial_spawn_delay_max_extra");
	g_cInitialDelayMin = FindConVar("director_special_initial_spawn_delay_min");
	g_cFinaleOfferLength = FindConVar("director_special_finale_offer_length");
	g_cOriginalOfferLength = FindConVar("director_special_original_offer_length");
	

	HookEvent("round_start", RoundStart_Event);

	HookConVarChange(SS_1_SiNum, OnSpawnSettingChanged);
	HookConVarChange(SS_Time, OnSpawnSettingChanged);
	HookConVarChange(g_cAutoMode, OnSpawnSettingChanged);
	HookConVarChange(SS_DPSLimit, OnSpawnSettingChanged);

	HookConVarChange(SS_EnableRelax, OnRelaxChanged);
	HookConVarChange(g_cEnableM4Fix, OnM4FixChanged)

	RefreshDirectorSettings();
	
}

public void OnMapInit()
{
	if (g_cEnableM4Fix.IntValue == 1) CheckValues();
}
public Action RoundStart_Event(Event event, const String:name[], bool:dontBroadcast){
	if (g_cAutoMode.IntValue == 1) AutoSetSi();
	else RefreshDirectorSettings();
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
public OnSpawnSettingChanged(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (convar == g_cAutoMode && g_cAutoMode.IntValue == 1) AutoSetSi();
	else RefreshDirectorSettings();
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
	ApplyRelaxConVars();
}

public Action Timer_RestartMap(Handle Timer){
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	ServerCommand("changelevel %s", mapname);
	return Plugin_Handled;
}
public Action Timer_ResetSpecialsCountdownTime(Handle Timer)
{
	if (SS_EnableFastRespawn.IntValue < 1) return Plugin_Continue;
	float nowTime;
	for (int i = 1; i < 7; i++)
	{
		CountdownTimer SiTimer = L4D2Direct_GetSIClassSpawnTimer(i);
		nowTime = CTimer_GetTimestamp(SiTimer);
		CTimer_SetTimestamp(SiTimer, nowTime - 20.0);
		
		IntervalTimer SITimer2 = L4D2Direct_GetSIClassDeathTimer(i);
		nowTime = ITimer_GetTimestamp(SITimer2);
		ITimer_SetTimestamp(SITimer2, nowTime - 20.0);
	}
	if (SS_EnableFastRespawn.IntValue < 2) return Plugin_Continue;
	for (int i = 1; i <= MaxClients; i++){
		if (!IsClientInGame(i)) continue;
		if (!IsFakeClient(i)) continue;
		if (!IsInfected(i)) continue;
		//if (L4D2_GetPlayerZombieClass(i) == L4D2Infected_Spitter) continue;
		if (!IsPlayerAlive(i)) KickClient(i);
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
	if (sv_setmax != null && players + SS_1_SiNum.IntValue > sv_setmax.IntValue) SS_1_SiNum.IntValue = sv_setmax.IntValue - players;
	if (SS_1_SiNum.IntValue < 0) SS_1_SiNum.IntValue = 0;
	if (SS_Time.IntValue < 0) SS_Time.IntValue = 0;
	return;
}

void RefreshDirectorSettings()
{
	isLegalSetting();
	g_iMaxSpecials = SS_1_SiNum.IntValue;
	g_fSpecialRespawnInterval = SS_Time.FloatValue;
	CalculateClassLimits(g_iMaxSpecials, SS_DPSLimit.IntValue);
	ApplyRelaxConVars();
}

void CalculateClassLimits(int maxSpecials, int dpsLimit)
{
	for (int zombieClass = 1; zombieClass <= 6; zombieClass++)
		g_iClassLimit[zombieClass] = 0;

	int allocationOrder[6] = {3, 5, 1, 6, 4, 2}; // Hunter, Jockey, Smoker, Charger, Spitter, Boomer
	int allocationCount = maxSpecials < 6 ? 6 : maxSpecials;
	int index;

	for (int i = 0; i < allocationCount; i++)
	{
		if (dpsLimit <= 0 && index > 3) index = 0;

		int zombieClass = allocationOrder[index];
		g_iClassLimit[zombieClass]++;
		index++;

		int dpsCount = g_iClassLimit[4] + g_iClassLimit[2];
		if (dpsCount >= dpsLimit && index > 3) index = 0;
		else if (index > 5) index = 0;
	}
}

void ApplyRelaxConVars()
{
	bool relax = SS_EnableRelax.BoolValue;
	SetOptionalConVar(g_cBattlefieldRespawn, relax ? 10.0 : 2.0);
	SetOptionalConVar(g_cInitialDelayMax, relax ? 60.0 : 1.0);
	SetOptionalConVar(g_cInitialDelayMaxExtra, relax ? 180.0 : 2.0);
	SetOptionalConVar(g_cInitialDelayMin, relax ? 30.0 : 0.0);
	SetOptionalConVar(g_cFinaleOfferLength, relax ? 10.0 : 1.0);
	SetOptionalConVar(g_cOriginalOfferLength, relax ? 30.0 : 1.0);
}

void SetOptionalConVar(ConVar convar, float value)
{
	if (convar != null) convar.FloatValue = value;
}

public Action L4D_OnGetScriptValueInt(const char[] key, int &retVal)
{
	if (StrEqual(key, "MaxSpecials") || StrEqual(key, "cm_MaxSpecials") ||
		StrEqual(key, "BaseSpecialLimit") || StrEqual(key, "cm_BaseSpecialLimit") ||
		StrEqual(key, "DominatorLimit") || StrEqual(key, "cm_DominatorLimit"))
	{
		retVal = g_iMaxSpecials;
		return Plugin_Handled;
	}

	int zombieClass;
	if (StrEqual(key, "SmokerLimit") || StrEqual(key, "cm_SmokerLimit")) zombieClass = 1;
	else if (StrEqual(key, "BoomerLimit") || StrEqual(key, "cm_BoomerLimit")) zombieClass = 2;
	else if (StrEqual(key, "HunterLimit") || StrEqual(key, "cm_HunterLimit")) zombieClass = 3;
	else if (StrEqual(key, "SpitterLimit") || StrEqual(key, "cm_SpitterLimit")) zombieClass = 4;
	else if (StrEqual(key, "JockeyLimit") || StrEqual(key, "cm_JockeyLimit")) zombieClass = 5;
	else if (StrEqual(key, "ChargerLimit") || StrEqual(key, "cm_ChargerLimit")) zombieClass = 6;

	if (zombieClass > 0)
	{
		retVal = g_iClassLimit[zombieClass];
		return Plugin_Handled;
	}

	if (!SS_EnableRelax.BoolValue)
	{
		if (StrEqual(key, "LookTempo"))
		{
			retVal = 1;
			return Plugin_Handled;
		}
		if (StrEqual(key, "LockTempo"))
		{
			retVal = 0;
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action L4D_OnGetScriptValueFloat(const char[] key, float &retVal)
{
	if (StrEqual(key, "SpecialRespawnInterval") ||
		StrEqual(key, "GetSpecialSlotCountdownTime") ||
		StrEqual(key, "cm_SpecialRespawnInterval") ||
		StrEqual(key, "cm_SpecialSlotCountdownTime"))
	{
		retVal = g_fSpecialRespawnInterval;
		return Plugin_Handled;
	}

	if (SS_EnableRelax.BoolValue) return Plugin_Continue;

	if (StrEqual(key, "IntensityRelaxThreshold")) retVal = 1.01;
	else if (StrEqual(key, "RelaxMaxFlowTravel")) retVal = 0.0;
	else if (StrEqual(key, "RelaxMaxInterval")) retVal = 0.5;
	else if (StrEqual(key, "RelaxMinInterval")) retVal = 0.0;
	else if (StrEqual(key, "SustainPeakMinTime")) retVal = 0.0;
	else if (StrEqual(key, "SustainPeakMaxTime")) retVal = 0.1;
	else return Plugin_Continue;

	return Plugin_Handled;
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
	return Plugin_Continue;
}
