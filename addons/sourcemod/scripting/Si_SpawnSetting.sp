#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#include <sirputil/better_mutations4.sp>

ConVar g_cvMaxSpecials;
ConVar g_cvRespawnInterval;
ConVar g_cvRelaxEnabled, g_cvFastRespawnMode;
ConVar g_cvDpsSpecialLimit;
ConVar g_cvAutoScaleEnabled, g_cvAutoBaseInterval, g_cvAutoIntervalReductionPerPlayer, g_cvAutoBaseSpecials, g_cvAutoSpecialsPerPlayer;
ConVar g_cvMutation4FixEnabled;
ConVar g_cvBattlefieldRespawnInterval, g_cvInitialSpawnDelayMax, g_cvInitialSpawnDelayMaxExtra;
ConVar g_cvInitialSpawnDelayMin, g_cvFinaleOfferLength, g_cvOriginalOfferLength;

int g_iMaxSpecials;
int g_iSpecialClassLimits[7];
float g_fSpecialRespawnInterval;

Handle g_hFastRespawnTimer;
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
	RegConsoleCmd("sm_si_spawn_set_limit", Command_SetSpecialLimit);
	RegConsoleCmd("sm_si_spawn_set_interval", Command_SetRespawnInterval);
	RegConsoleCmd("sm_si_spawn_set_dps_limit", Command_SetDpsSpecialLimit);
	g_cvMaxSpecials = CreateConVar("si_spawn_max_specials", "3", "特感数量");
	g_cvRespawnInterval = CreateConVar("si_spawn_respawn_interval", "35", "刷新间隔");
	g_cvRelaxEnabled = CreateConVar("si_spawn_relax_enabled", "1", "允许relax");
	g_cvFastRespawnMode = CreateConVar("si_spawn_fast_respawn_mode", "0", "跳过relax时, 是否快速补特");
	g_cvDpsSpecialLimit = CreateConVar("si_spawn_dps_special_limit", "10", "DPS特感数量限制");
	g_cvAutoScaleEnabled = CreateConVar("si_spawn_auto_scale_enabled", "1", "自动调整刷特模式（4+生还玩家）");
	g_cvAutoIntervalReductionPerPlayer = CreateConVar("si_spawn_auto_interval_reduction", "1", "每多一名生还，特感的复活时间减少多少s");
	g_cvAutoBaseInterval = CreateConVar("si_spawn_auto_base_interval", "35", "一只特感的基础复活时间");
	g_cvAutoBaseSpecials = CreateConVar("si_spawn_auto_base_specials", "3", "在4名玩家时，基础特感数量");
	g_cvAutoSpecialsPerPlayer = CreateConVar("si_spawn_auto_specials_per_player", "1", "每多一名生还，增加几只特感");
	g_cvMutation4FixEnabled = CreateConVar("si_spawn_mutation4_fix_enabled", "0", "是否启用绝境修复");

	g_cvBattlefieldRespawnInterval = FindConVar("director_special_battlefield_respawn_interval");
	g_cvInitialSpawnDelayMax = FindConVar("director_special_initial_spawn_delay_max");
	g_cvInitialSpawnDelayMaxExtra = FindConVar("director_special_initial_spawn_delay_max_extra");
	g_cvInitialSpawnDelayMin = FindConVar("director_special_initial_spawn_delay_min");
	g_cvFinaleOfferLength = FindConVar("director_special_finale_offer_length");
	g_cvOriginalOfferLength = FindConVar("director_special_original_offer_length");
	

	HookEvent("round_start", Event_RoundStart);

	HookConVarChange(g_cvMaxSpecials, ConVarChanged_SpawnSetting);
	HookConVarChange(g_cvRespawnInterval, ConVarChanged_SpawnSetting);
	HookConVarChange(g_cvAutoScaleEnabled, ConVarChanged_SpawnSetting);
	HookConVarChange(g_cvDpsSpecialLimit, ConVarChanged_SpawnSetting);

	HookConVarChange(g_cvRelaxEnabled, ConVarChanged_Relax);
	HookConVarChange(g_cvMutation4FixEnabled, ConVarChanged_Mutation4Fix)

	RefreshDirectorSettings();
	
}

public void OnMapInit()
{
	if (g_cvMutation4FixEnabled.IntValue == 1) CheckValues();
}
public Action Event_RoundStart(Event event, const String:name[], bool:dontBroadcast){
	if (g_cvAutoScaleEnabled.IntValue == 1) ApplyAutomaticSpawnSettings();
	else RefreshDirectorSettings();
	if (g_cvRelaxEnabled.IntValue == 1){
		if (g_hFastRespawnTimer != INVALID_HANDLE){
			KillTimer(g_hFastRespawnTimer);
			g_hFastRespawnTimer = INVALID_HANDLE;
		}
	}else{
		g_hFastRespawnTimer = CreateTimer(1.0, Timer_AccelerateSpecialRespawn, _, TIMER_REPEAT);
	}
	return Plugin_Continue;
}
public ConVarChanged_SpawnSetting(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (convar == g_cvAutoScaleEnabled && g_cvAutoScaleEnabled.IntValue == 1) ApplyAutomaticSpawnSettings();
	else RefreshDirectorSettings();
}
public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client)) return;
	if (g_cvAutoScaleEnabled.IntValue != 1) return;
	ApplyAutomaticSpawnSettings();
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	g_cvMaxSpecials.IntValue, GetMinimumClassLimit(g_cvMaxSpecials.IntValue), g_cvRespawnInterval.IntValue, g_cvDpsSpecialLimit.IntValue, g_cvRelaxEnabled.IntValue);
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client)) return;
	if (g_cvAutoScaleEnabled.IntValue != 1) return;
	CreateTimer(2.0, Timer_ApplyAutomaticSpawnSettings,client);
}

public Action Timer_ApplyAutomaticSpawnSettings(Handle timer, int client)
{
	ApplyAutomaticSpawnSettings();
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	g_cvMaxSpecials.IntValue, GetMinimumClassLimit(g_cvMaxSpecials.IntValue), g_cvRespawnInterval.IntValue, g_cvDpsSpecialLimit.IntValue, g_cvRelaxEnabled.IntValue);
	return Plugin_Stop;
}
public ConVarChanged_Mutation4Fix(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (g_cvMutation4FixEnabled.IntValue == 1){
		CheckValues();
	}else{
		g_bFixUnlimitSpawnsEnable = false;
		CPrintToChatAll("{green}[{lightgreen}!{green}] {default}即将重启地图");
		CreateTimer(5.0, Timer_RestartMap);
	}
}
public ConVarChanged_Relax(Handle:convar, const String:oldValue[], const String:newValue[]){
	if (g_cvRelaxEnabled.IntValue == 1){
		if (g_hFastRespawnTimer != INVALID_HANDLE){
			KillTimer(g_hFastRespawnTimer);
			g_hFastRespawnTimer = INVALID_HANDLE;
		}
	}else{
		g_hFastRespawnTimer = CreateTimer(1.0, Timer_AccelerateSpecialRespawn, _, TIMER_REPEAT);
	}
	ApplyRelaxConVars();
}

public Action Timer_RestartMap(Handle Timer){
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	ServerCommand("changelevel %s", mapname);
	return Plugin_Handled;
}
public Action Timer_AccelerateSpecialRespawn(Handle Timer)
{
	if (g_cvFastRespawnMode.IntValue < 1) return Plugin_Continue;
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
	if (g_cvFastRespawnMode.IntValue < 2) return Plugin_Continue;
	for (int i = 1; i <= MaxClients; i++){
		if (!IsClientInGame(i)) continue;
		if (!IsFakeClient(i)) continue;
		if (GetClientTeam(i) != L4D_TEAM_INFECTED) continue;
		//if (L4D2_GetPlayerZombieClass(i) == L4D2Infected_Spitter) continue;
		if (!IsPlayerAlive(i)) KickClient(i);
	}
	return Plugin_Continue;
}

void ApplyAutomaticSpawnSettings()
{
	int players = GetHumanPlayerCount(0);
	if (players <= 4)
	{
		g_cvMaxSpecials.IntValue = g_cvAutoBaseSpecials.IntValue;
		g_cvRespawnInterval.IntValue = g_cvAutoBaseInterval.IntValue;
		ValidateSpawnSettings();
		return;
	}
	g_cvMaxSpecials.IntValue = g_cvAutoBaseSpecials.IntValue + g_cvAutoSpecialsPerPlayer.IntValue * (players - 4);
	g_cvRespawnInterval.IntValue = g_cvAutoBaseInterval.IntValue - g_cvAutoIntervalReductionPerPlayer.IntValue * (players - 4);
	ValidateSpawnSettings();
	return;
}

void ValidateSpawnSettings()
{
	ConVar sv_setmax = FindConVar("sv_setmax");
	int players = GetHumanPlayerCount(0);
	if (sv_setmax != null && players + g_cvMaxSpecials.IntValue > sv_setmax.IntValue) g_cvMaxSpecials.IntValue = sv_setmax.IntValue - players;
	if (g_cvMaxSpecials.IntValue < 0) g_cvMaxSpecials.IntValue = 0;
	if (g_cvRespawnInterval.IntValue < 0) g_cvRespawnInterval.IntValue = 0;
	return;
}

void RefreshDirectorSettings()
{
	ValidateSpawnSettings();
	g_iMaxSpecials = g_cvMaxSpecials.IntValue;
	g_fSpecialRespawnInterval = g_cvRespawnInterval.FloatValue;
	CalculateClassLimits(g_iMaxSpecials, g_cvDpsSpecialLimit.IntValue);
	ApplyRelaxConVars();
}

void CalculateClassLimits(int maxSpecials, int dpsLimit)
{
	for (int zombieClass = 1; zombieClass <= 6; zombieClass++)
		g_iSpecialClassLimits[zombieClass] = 0;

	int allocationOrder[6] = {3, 5, 1, 6, 4, 2}; // Hunter, Jockey, Smoker, Charger, Spitter, Boomer
	int allocationCount = maxSpecials < 6 ? 6 : maxSpecials;
	int index;

	for (int i = 0; i < allocationCount; i++)
	{
		if (dpsLimit <= 0 && index > 3) index = 0;

		int zombieClass = allocationOrder[index];
		g_iSpecialClassLimits[zombieClass]++;
		index++;

		int dpsCount = g_iSpecialClassLimits[4] + g_iSpecialClassLimits[2];
		if (dpsCount >= dpsLimit && index > 3) index = 0;
		else if (index > 5) index = 0;
	}
}

void ApplyRelaxConVars()
{
	bool relax = g_cvRelaxEnabled.BoolValue;
	SetOptionalConVar(g_cvBattlefieldRespawnInterval, relax ? 10.0 : 2.0);
	SetOptionalConVar(g_cvInitialSpawnDelayMax, relax ? 60.0 : 1.0);
	SetOptionalConVar(g_cvInitialSpawnDelayMaxExtra, relax ? 180.0 : 2.0);
	SetOptionalConVar(g_cvInitialSpawnDelayMin, relax ? 30.0 : 0.0);
	SetOptionalConVar(g_cvFinaleOfferLength, relax ? 10.0 : 1.0);
	SetOptionalConVar(g_cvOriginalOfferLength, relax ? 30.0 : 1.0);
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
		retVal = g_iSpecialClassLimits[zombieClass];
		return Plugin_Handled;
	}

	if (!g_cvRelaxEnabled.BoolValue)
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

	if (g_cvRelaxEnabled.BoolValue) return Plugin_Continue;

	if (StrEqual(key, "IntensityRelaxThreshold")) retVal = 1.01;
	else if (StrEqual(key, "RelaxMaxFlowTravel")) retVal = 0.0;
	else if (StrEqual(key, "RelaxMaxInterval")) retVal = 0.5;
	else if (StrEqual(key, "RelaxMinInterval")) retVal = 0.0;
	else if (StrEqual(key, "SustainPeakMinTime")) retVal = 0.0;
	else if (StrEqual(key, "SustainPeakMaxTime")) retVal = 0.1;
	else return Plugin_Continue;

	return Plugin_Handled;
}

public int GetMinimumClassLimit(int num){
	int Si = num/6;
	if (Si*6 != num) Si++;
	if (Si <= 0) Si=1;
	return Si
}

int GetHumanPlayerCount(int client) {
	int count;
	for (int i = 1; i <= MaxClients; i++) {
		if (i != client && IsClientAuthorized(i) && !IsFakeClient(i))
			count++;
	}
	return count;
}


public Action Command_SetRespawnInterval(int client, int args)
{
	int time;
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_si_spawn_set_interval <刷新间隔>");
		return Plugin_Handled;
	}
	time = GetCmdArgInt(1);
	g_cvRespawnInterval.IntValue = time;
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	g_cvMaxSpecials.IntValue, GetMinimumClassLimit(g_cvMaxSpecials.IntValue), g_cvRespawnInterval.IntValue, g_cvDpsSpecialLimit.IntValue, g_cvRelaxEnabled.IntValue);
	return Plugin_Continue;
}
public Action Command_SetDpsSpecialLimit(int client, int args)
{
	int SiNum;

	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_si_spawn_set_dps_limit <特感数量>");
		return Plugin_Handled;
	}
	SiNum = GetCmdArgInt(1);
	g_cvDpsSpecialLimit.IntValue = SiNum;
	
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	g_cvMaxSpecials.IntValue, GetMinimumClassLimit(g_cvMaxSpecials.IntValue), g_cvRespawnInterval.IntValue, g_cvDpsSpecialLimit.IntValue, g_cvRelaxEnabled.IntValue);
	return Plugin_Continue;
}
public Action Command_SetSpecialLimit(int client, int args)
{
	int SiNum;

	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_si_spawn_set_limit <特感数量>");
		return Plugin_Handled;
	}
	SiNum = GetCmdArgInt(1);
	g_cvMaxSpecials.IntValue = SiNum;
	
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d{default} ，单类至少{olive}%d{default}只，单SlotCD{olive}%ds{default}，DPS特感限制{olive}%d{default}只，Relax阶段：{olive}%d{default}",	g_cvMaxSpecials.IntValue, GetMinimumClassLimit(g_cvMaxSpecials.IntValue), g_cvRespawnInterval.IntValue, g_cvDpsSpecialLimit.IntValue, g_cvRelaxEnabled.IntValue);
	return Plugin_Continue;
}
