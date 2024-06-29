#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define MAX_ENTITIES		2048

#define PLUGIN_VERSION		"8.2"
#define PLUGIN_CONTACT		"github.com/mewtani"

#define PLUGIN_NAME			"Ready Up"
#define PLUGIN_DESCRIPTION	"A pre-game management plugin with an extensive API"
#define CVAR_SHOW			FCVAR_NOTIFY | FCVAR_PLUGIN

#define PLUGIN_LIBRARY		"readyup"

#define CHECKPOINT_DOOR_CLOSED	0
#define CHECKPOINT_DOOR_OPENED	2
#define CHECKPOINT_DOOR_MOVING	3

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin:myinfo = {

	name = PLUGIN_NAME,
	author = PLUGIN_CONTACT,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_CONTACT,
};

// sometimes readyup calls forwards twice... we're going to temporarily fix that with bools.
new bool:b_IsSaferoomDoorOpened;
new bool:b_IsReadyUpOver;
new bool:b_IsReadyUpStart;
new bool:bIsCheckpointRotating;
new survivorInCheckpoint[MAXPLAYERS+1];
new DeleteTheDoors;
new iForceCampaign;
static Handle:g_SurvivorEnteredCheckpoint			= INVALID_HANDLE;
static Handle:g_IsGroupMemberStatus					= INVALID_HANDLE;
static Handle:g_IsSaferoomDoorDestroyed				= INVALID_HANDLE;
static Handle:g_IsFirstClientLoaded					= INVALID_HANDLE;
static Handle:g_IsAllClientsLoaded					= INVALID_HANDLE;
static Handle:g_IsReadyUpStart						= INVALID_HANDLE;
static Handle:g_IsReadyUpEnd						= INVALID_HANDLE;
static Handle:g_IsRoundEnd							= INVALID_HANDLE;
static Handle:g_IsCheckpointDoorOpened				= INVALID_HANDLE;
static Handle:g_IsMapTransition						= INVALID_HANDLE;
static Handle:g_IsFinaleWon							= INVALID_HANDLE;
static Handle:g_IsRoundEndFailed					= INVALID_HANDLE;
static Handle:g_IsSaferoomLocked					= INVALID_HANDLE;
static Handle:g_IsClientLoaded						= INVALID_HANDLE;
static Handle:g_IsLoadConfig						= INVALID_HANDLE;
static Handle:g_IsLoadConfigEx						= INVALID_HANDLE;
static Handle:g_ParseConfigFailed					= INVALID_HANDLE;
static Handle:g_CommandTriggered					= INVALID_HANDLE;
static Handle:g_SendCommands						= INVALID_HANDLE;
static Handle:g_IsTrueDisconnect					= INVALID_HANDLE;
static Handle:g_SlotChange							= INVALID_HANDLE;
static Handle:g_EntryDenied							= INVALID_HANDLE;
static Handle:g_EntryAllowed						= INVALID_HANDLE;
static Handle:g_TeamAssigned						= INVALID_HANDLE;
static Handle:g_SurvivorControl						= INVALID_HANDLE;
static Handle:g_TeamChange							= INVALID_HANDLE;
static Handle:g_Header								= INVALID_HANDLE;
static Handle:g_GetCampaignName						= INVALID_HANDLE;
static Handle:g_FirstClientSpawn					= INVALID_HANDLE;
static Handle:g_CallModule							= INVALID_HANDLE;
static Handle:g_MapList								= INVALID_HANDLE;
static Handle:g_FriendlyFire						= INVALID_HANDLE;
static Handle:g_EntityStatistics					= INVALID_HANDLE;
static OFFSET_LOCKED								= 0;

new Handle:g_IsClientConnection						= INVALID_HANDLE;
new Handle:g_IsFreezeTimer							= INVALID_HANDLE;
new Handle:g_ForceReadyUpStartTimer					= INVALID_HANDLE;
new Handle:g_IsMatchStart							= INVALID_HANDLE;
new Handle:Match_Countdown							= INVALID_HANDLE;
new Handle:g_ChangeValue							= INVALID_HANDLE;
new Handle:g_GetMaxSurvivorCount					= INVALID_HANDLE;
new Handle:g_IsAllTalk;
new Handle:g_IsGameMode;
new String:s_IsGameMode[64];
new String:white[4];
new String:green[4];
new String:blue[4];
new String:orange[4];
new String:s_Log[PLATFORM_MAX_PATH];
new String:s_Config[PLATFORM_MAX_PATH];
new String:s_Path[PLATFORM_MAX_PATH];
new bool:IsReadyUpLoaded;
new bool:bIsReadyUpEligible;
new bool:b_ReadyUpOver;
new bool:b_IsMapComplete;
new bool:b_IsFirstClientSpawn;
new bool:b_IsTransition;
new bool:b_IsReadyUp;
new bool:b_IsFirstClientLoaded;
new bool:b_IsAllClientsLoaded;
new bool:b_IsRoundOver;
new bool:b_IsFinaleWon;
new bool:b_IsTeamsFlipped;
new bool:b_IsIntermission;
new bool:b_IsFirstRound;
new bool:b_IsInStartArea[MAXPLAYERS + 1];
new bool:b_IsExitedStartArea;
new bool:b_IsFirstHumanSpawn;
new bool:b_IsHideHud[MAXPLAYERS + 1];
new bool:b_IsReady[MAXPLAYERS + 1];
new bool:b_IsParseConfig;
new StoreKeys;
new KeyCount;
new String:lastClient[64];
new i_RoundCount;
new SaferoomDoor;
new EndOfMapDoor;
new i_IsReadyUpHalftime;
new i_IsReadyUpIgnored;
new i_ReadyUpTime;
new i_ReadyUpTimeFirst;
new i_IsHudDisabled;
new i_IsWarmupAllTalk;
new i_IsFreeze;
new i_IsDisplayLoading;
new i_IsPeriodicCountdown;
new i_CoopMapRounds;
new i_SurvivalMapRounds;
new String:GamemodeSurvival[512];
new String:GamemodeCoop[512];
new String:GamemodeVersus[512];
new String:GamemodeScavenge[512];
new String:ForceStartMaps[512];
new i_IsConnectionMessage;
new i_IsLoadedMessage;
new i_IsConnectionTimeout;
new i_IsDoorForcedOpen;
new i_IsPeriodicTime;
new i_IsMajority;
new i_IsMajorityTimer;
new String:s_Cmd_ForceStart[64];
new String:s_Cmd_ToggleHud[64];
new String:s_Cmd_ToggleReady[64];
new String:s_Cmd_ToggleBots[64];
new String:CurrentCampaignName[64];
new String:s_rup[32];
new Handle:a_FirstMap;
new Handle:a_FinalMap;
new Handle:a_CampaignMapDescriptionKey;
new Handle:a_CampaignMapDescriptionValue;
new Handle:a_SurvivalMap;
new Handle:a_SurvivalMapNext;
new Handle:a_SurvivalMapDescriptionKey;
new Handle:a_SurvivalMapDescriptionValue;
new Handle:a_KeyConfig;
new Handle:a_ValueConfig;
new String:s_SectionConfig[64];
new String:s_ActiveConfig[64];
new Handle:a_SectionConfig;
new Handle:a_PluginLoadQueue;
new Handle:a_PluginLoadQueue_Count;
new Handle:a_RegisteredCommands;
new Handle:a_RegisteredCommands_Description;
new Handle:a_RegisteredCommands_Flags;
new iMaxSurvivorsAllowed;
new iMinSurvivorsAllowed;
new Handle:g_InfectedBotLimit	= INVALID_HANDLE;
new Handle:g_CampaignStatus		= INVALID_HANDLE;
new Handle:g_MinimumSurvivors	= INVALID_HANDLE;
new Handle:g_CreateCompanion	= INVALID_HANDLE;
new Handle:g_IsEmptyOnDisconnect = INVALID_HANDLE;

new iMaxSurvivorBotsAllowed;
new iStartingSurvivors;
new iBotCountdownTime;
new iBotIntervalTime;
new iMinSurvivors = -1;
new bool:bNoBots[MAXPLAYERS + 1];
new Handle:t_SetBotTimer = INVALID_HANDLE;
new Float:endPos[3];

public APLRes:AskPluginLoad2(Handle:g_Me, bool:b_IsLate, String:s_Error[], s_ErrorMaxSize) {

	if (LibraryExists(PLUGIN_LIBRARY)) {
	
		strcopy(s_Error, s_ErrorMaxSize, "Plugin Already Loaded");
		return APLRes_SilentFailure;
	}

	if (!IsDedicatedServer()) {

		strcopy(s_Error, s_ErrorMaxSize, "Listen Server Not Supported");
		return APLRes_Failure;
	}

	decl String:s_GameFolder[32];
	GetGameFolderName(s_GameFolder, sizeof(s_GameFolder));
	if (!StrEqual(s_GameFolder, "left4dead2", false)) {

		strcopy(s_Error, s_ErrorMaxSize, "Game Not Supported");
		return APLRes_Failure;
	}

	RegPluginLibrary(PLUGIN_LIBRARY);
	g_IsFirstClientLoaded							= CreateGlobalForward("ReadyUp_FirstClientLoaded", ET_Ignore);
	g_FirstClientSpawn								= CreateGlobalForward("ReadyUp_FirstClientSpawn", ET_Ignore);
	g_IsAllClientsLoaded							= CreateGlobalForward("ReadyUp_AllClientsLoaded", ET_Ignore);
	g_IsReadyUpStart								= CreateGlobalForward("ReadyUp_ReadyUpStart", ET_Ignore);
	g_IsReadyUpEnd									= CreateGlobalForward("ReadyUp_ReadyUpEnd", ET_Ignore);
	g_IsRoundEnd									= CreateGlobalForward("ReadyUp_RoundIsOver", ET_Event, Param_Cell)
	g_IsCheckpointDoorOpened						= CreateGlobalForward("ReadyUp_CheckpointDoorStartOpened", ET_Ignore);
	g_IsMapTransition								= CreateGlobalForward("ReadyUp_CoopMapEnd", ET_Ignore);
	g_IsFinaleWon									= CreateGlobalForward("ReadyUp_CampaignComplete", ET_Ignore);
	g_IsRoundEndFailed								= CreateGlobalForward("ReadyUp_CoopMapFailed", ET_Event, Param_Cell);
	g_IsSaferoomLocked								= CreateGlobalForward("ReadyUp_SaferoomLocked", ET_Ignore);
	g_IsClientLoaded								= CreateGlobalForward("ReadyUp_IsClientLoaded", ET_Event, Param_Cell);
	g_IsLoadConfig									= CreateGlobalForward("ReadyUp_LoadFromConfig", ET_Event, Param_Cell, Param_Cell);
	g_IsLoadConfigEx								= CreateGlobalForward("ReadyUp_LoadFromConfigEx", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_String, Param_Cell);
	g_ParseConfigFailed								= CreateGlobalForward("ReadyUp_ParseConfigFailed", ET_Event, Param_String, Param_String);
	g_CommandTriggered								= CreateGlobalForward("ReadyUp_Command", ET_Event, Param_Cell, Param_String);
	g_SendCommands									= CreateGlobalForward("ReadyUp_ListCommands", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_IsTrueDisconnect								= CreateGlobalForward("ReadyUp_TrueDisconnect", ET_Event, Param_Cell);
	g_SlotChange									= CreateGlobalForward("ReadyUp_SlotChangeNotice", ET_Ignore);
	g_EntryDenied									= CreateGlobalForward("ReadyUp_FwdEntryDenied", ET_Ignore);
	g_EntryAllowed									= CreateGlobalForward("ReadyUp_FwdEntryAllowed", ET_Event, Param_Cell);
	g_TeamAssigned									= CreateGlobalForward("ReadyUp_FwdTeamAssigned", ET_Event, Param_Cell, Param_Cell);
	g_SurvivorControl								= CreateGlobalForward("ReadyUp_FwdSurvivorControl", ET_Event, Param_Cell);
	g_TeamChange									= CreateGlobalForward("ReadyUp_FwdChangeTeam", ET_Event, Param_Cell, Param_Cell);
	g_Header										= CreateGlobalForward("ReadyUp_FwdGetHeader", ET_Event, Param_String);
	g_GetCampaignName								= CreateGlobalForward("ReadyUp_FwdGetCampaignName", ET_Event, Param_String);
	g_CallModule									= CreateGlobalForward("ReadyUp_FwdCallModule", ET_Event, Param_String, Param_String, Param_Cell);
	g_MapList										= CreateGlobalForward("ReadyUp_FwdGetMapList", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_FriendlyFire									= CreateGlobalForward("ReadyUp_FwdFriendlyFire", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_IsSaferoomDoorDestroyed						= CreateGlobalForward("ReadyUp_SaferoomDoorDestroyed", ET_Ignore);
	g_ChangeValue									= CreateGlobalForward("ReadyUp_ChangeConfigValue", ET_Event, Param_String, Param_String);
	g_GetMaxSurvivorCount							= CreateGlobalForward("ReadyUp_GetMaxSurvivorCount", ET_Event, Param_Cell);
	g_InfectedBotLimit								= CreateGlobalForward("ReadyUp_SetInfectedBotLimit", ET_Event, Param_Cell);
	g_CampaignStatus								= CreateGlobalForward("ReadyUp_GetCampaignStatus", ET_Event, Param_Cell);
	g_MinimumSurvivors								= CreateGlobalForward("ReadyUp_SetSurvivorMinimum", ET_Event, Param_Cell);
	g_CreateCompanion								= CreateGlobalForward("ReadyUp_CreateCompanion", ET_Event, Param_Cell, Param_String);
	g_IsGroupMemberStatus							= CreateGlobalForward("ReadyUp_GroupMemberStatus", ET_Event, Param_Cell, Param_Cell);
	g_IsEmptyOnDisconnect							= CreateGlobalForward("ReadyUp_IsEmptyOnDisconnect", ET_Ignore);
	g_EntityStatistics								= CreateGlobalForward("ReadyUp_FwdStatistics", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_SurvivorEnteredCheckpoint						= CreateGlobalForward("ReadyUp_SurvivorEnteredCheckpoint", ET_Event, Param_Cell);

	CreateNative("ReadyUp_IsTeamsFlipped", Native_IsTeamsFlipped);
	CreateNative("ReadyUp_ParseConfig", Native_ParseConfig);
	CreateNative("ReadyUp_ParseConfigEx", Native_ParseConfigEx);
	CreateNative("ReadyUp_GetGameMode", Native_GetGameMode);
	CreateNative("ReadyUp_RegisterCommand", Native_RegisterCommand);
	CreateNative("ReadyUp_RemoveCommand", Native_RemoveCommand);
	CreateNative("ReadyUp_GetCommands", Native_GetCommands);
	CreateNative("ReadyUp_SlotChangeSuccess", Native_SlotChange);
	CreateNative("ReadyUp_NtvEntryDenied", Native_EntryDenied);
	CreateNative("ReadyUp_NtvEntryAllowed", Native_EntryAllowed);
	CreateNative("ReadyUp_NtvTeamAssigned", Native_TeamAssigned);
	CreateNative("ReadyUp_NtvChangeTeam", Native_ChangeTeam);
	CreateNative("ReadyUp_NtvSurvivorControl", Native_SurvivorControl);
	CreateNative("ReadyUp_NtvGetHeader", Native_GetHeader);
	CreateNative("ReadyUp_NtvGetCampaignName", Native_GetCampaignName);
	CreateNative("ReadyUp_NtvCallModule", Native_CallModule);
	CreateNative("ReadyUp_NtvGetMapList", Native_GetMapList);
	CreateNative("ReadyUp_NtvConfigProcessing", Native_ConfigProcessing);
	CreateNative("ReadyUp_NtvFriendlyFire", Native_FriendlyFire);
	CreateNative("ReadyUp_NtvIsCampaignFinale", Native_IsCampaignFinale);
	CreateNative("ReadyUp_NtvHandicapChanged", Native_HandicapChanged);
	CreateNative("ReadyUp_NtvCreateCompanion", Native_CreateCompanion);
	CreateNative("ReadyUp_NtvGroupMemberStatus", Native_GroupMemberStatus);
	CreateNative("ReadyUp_NtvIsEmptyOnDisconnect", Native_IsEmptyOnDisconnect);
	CreateNative("ReadyUp_NtvStatistics", Native_Statistics);
	return APLRes_Success;
}

stock Now_IsLoadConfigForward() {
	if (b_IsParseConfig) {
		Call_StartForward(g_IsLoadConfig);
		Call_PushCell(a_KeyConfig);
		Call_PushCell(a_ValueConfig);
		Call_Finish();

		Call_StartForward(g_IsLoadConfigEx);
		Call_PushCell(a_KeyConfig);
		Call_PushCell(a_ValueConfig);
		Call_PushCell(a_SectionConfig);
		Call_PushString(s_ActiveConfig);
		Call_PushCell(KeyCount);
		Call_Finish();

		//ClearArray(Handle:a_KeyConfig);
		//ClearArray(Handle:a_ValueConfig);

		new a_Size									= GetArraySize(a_PluginLoadQueue);
		if (a_Size > 0) {

			decl String:p_config[PLATFORM_MAX_PATH];
			GetArrayString(Handle:a_PluginLoadQueue, 0, p_config, sizeof(p_config));

			decl String:path[PLATFORM_MAX_PATH];
			GetArrayString(Handle:a_PluginLoadQueue, 0, path, sizeof(path));

			RemoveFromArray(Handle:a_PluginLoadQueue, 0);

			BuildPath(Path_SM, path, sizeof(path), "configs/readyup/%s", path);
	
			if (!FileExists(path)) {

				decl String:error[PLATFORM_MAX_PATH];
				Format(error, sizeof(error), "File not found: %s", path);
				SetFailState("%s", path);

				Call_StartForward(g_ParseConfigFailed);
				Call_PushString(p_config);
				Call_PushString(error);
				Call_Finish();

				return;
			}

			strcopy(s_ActiveConfig, sizeof(s_ActiveConfig), p_config);

			StoreKeys								= GetArrayCell(Handle:a_PluginLoadQueue_Count, 0);
			RemoveFromArray(Handle:a_PluginLoadQueue_Count, 0);
			ClearArray(Handle:a_SectionConfig);

			KeyCount								= 0;
			ProcessConfigFile(path);
			return;
		}
		else {

			ClearArray(Handle:a_PluginLoadQueue);
			ClearArray(Handle:a_PluginLoadQueue_Count);
		}

		b_IsParseConfig								= false;
	}
}

public OnPluginStart() {

	CreateConVar("readyup_version", PLUGIN_VERSION, "version header", CVAR_SHOW);
	OFFSET_LOCKED									= FindSendPropInfo("CPropDoorRotatingCheckpoint", "m_bLocked");

	g_IsAllTalk										= FindConVar("sv_alltalk");
	g_IsGameMode									= FindConVar("mp_gamemode");

	GetConVarString(g_IsGameMode, s_IsGameMode, sizeof(s_IsGameMode));

	BuildPath(Path_SM, s_Log, sizeof(s_Log), "logs/");
	Format(s_Log, sizeof(s_Log), "%sreadyup.log", s_Log);

	HookEvent("map_transition", Event_MapTransition);
	HookEvent("mission_lost", Event_MissionLost);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_left_start_area", Event_PlayerLeftStartArea);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("door_open", Event_StartDoorOpened);
	HookEvent("finale_win", Event_FinaleWin);
	HookEvent("survival_round_start", Event_SurvivalRoundStart);
	HookEvent("scavenge_round_start", Event_ScavengeRoundStart);
	HookEvent("scavenge_round_finished", Event_ScavengeRoundEnd);
	HookEvent("player_disconnect", Event_PlayerDisconnect);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_entered_checkpoint", Event_PlayerEnteredCheckpoint);
	HookEvent("player_left_checkpoint", Event_PlayerLeftCheckpoint);
	HookEvent("player_death", Event_PlayerDeath);

	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");

	LoadTranslations("common.phrases");
	LoadTranslations("readyup.phrases");

	a_FirstMap										= CreateArray(8);
	a_FinalMap										= CreateArray(8);
	a_SurvivalMap									= CreateArray(8);
	a_SurvivalMapNext								= CreateArray(8);

	a_CampaignMapDescriptionKey						= CreateArray(8);
	a_CampaignMapDescriptionValue					= CreateArray(8);
	a_SurvivalMapDescriptionKey						= CreateArray(8);
	a_SurvivalMapDescriptionValue					= CreateArray(8);

	a_KeyConfig										= CreateArray(16);
	a_ValueConfig									= CreateArray(16);
	a_PluginLoadQueue								= CreateArray(8);
	a_PluginLoadQueue_Count							= CreateArray(8);
	a_SectionConfig									= CreateArray(16);

	a_RegisteredCommands							= CreateArray(8);
	a_RegisteredCommands_Description				= CreateArray(8);
	a_RegisteredCommands_Flags						= CreateArray(8);

	AddCommandListener(CommandListener, "say");
	AddCommandListener(CommandListener, "say_team");

	RegConsoleCmd("survivors", CMD_SetBotMinimum);

	if (!IsReadyUpLoaded) {

		IsReadyUpLoaded = true;
		bIsReadyUpEligible = true;
	}
}

public Action:CommandListener(client, String:command[], argc) {

	decl String:a_command[128];
	decl String:sBuffer[128];
	GetCmdArg(1, sBuffer, sizeof(sBuffer));
	StripQuotes(sBuffer);

	if (sBuffer[0] != '!' && sBuffer[0] != '/') return;

	decl a_flags;

	new a_Size										= GetArraySize(a_RegisteredCommands);

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:a_RegisteredCommands, i, a_command, sizeof(a_command));
		if (StrContains(sBuffer, a_command) != -1) {

			a_flags									= GetArrayCell(Handle:a_RegisteredCommands_Flags, i);

			if (a_flags == 0 || (GetUserFlagBits(client) & a_flags) || (GetUserFlagBits(client) & ADMFLAG_ROOT)) {

				Call_StartForward(g_CommandTriggered);
				Call_PushCell(client);
				Call_PushString(a_command);
				Call_Finish();
			}

			break;
		}
	}
}

stock Now_RegisterCommands() {

	PushArrayString(Handle:a_RegisteredCommands, s_Cmd_ForceStart);
	PushArrayString(Handle:a_RegisteredCommands_Description, "Forces the ready up period to end.");
	PushArrayCell(Handle:a_RegisteredCommands_Flags, ADMFLAG_KICK);

	PushArrayString(Handle:a_RegisteredCommands, s_Cmd_ToggleHud);
	PushArrayString(Handle:a_RegisteredCommands_Description, "Toggles the hud on/off.");
	PushArrayCell(Handle:a_RegisteredCommands_Flags, 0);

	PushArrayString(Handle:a_RegisteredCommands, s_Cmd_ToggleReady);
	PushArrayString(Handle:a_RegisteredCommands_Description, "Toggles ready/not ready.");
	PushArrayCell(Handle:a_RegisteredCommands_Flags, 0);

	PushArrayString(Handle:a_RegisteredCommands, s_Cmd_ToggleBots);
	PushArrayString(Handle:a_RegisteredCommands_Description, "Votes for bot adjustments.");
	PushArrayCell(Handle:a_RegisteredCommands_Flags, 0);
}

public ReadyUp_Command(client, String:command[]) {

	if (StrEqual(command, s_Cmd_ForceStart)) Cmd_ForceStart(client);
	else if (StrEqual(command, s_Cmd_ToggleHud)) Cmd_ToggleHud(client);
	else if (StrEqual(command, s_Cmd_ToggleReady)) Cmd_ToggleReady(client);
	else if (StrEqual(command, s_Cmd_ToggleBots)) {
		if (t_SetBotTimer != INVALID_HANDLE) Cmd_ToggleBots(client);
	}
}

public Native_Statistics(Handle:plugin, params) {
	new targetPlayer = GetNativeCell(1);
	new resultType = GetNativeCell(2);
	new amount = GetNativeCell(3);

	Call_StartForward(g_EntityStatistics);
	Call_PushCell(targetPlayer);
	Call_PushCell(resultType);
	Call_PushCell(amount);
	Call_Finish();
}

public Native_GetMapList(Handle:plugin, params) {
	
	Call_StartForward(g_MapList);
	if (GetGamemodeType() == 3) {

		Call_PushCell(a_SurvivalMap);
		Call_PushCell(a_SurvivalMapNext);
		Call_PushCell(a_SurvivalMapDescriptionKey);
		Call_PushCell(a_SurvivalMapDescriptionValue)
	}
	else {

		Call_PushCell(a_FirstMap);
		Call_PushCell(a_FinalMap);
		Call_PushCell(a_CampaignMapDescriptionKey);
		Call_PushCell(a_CampaignMapDescriptionValue);
	}
	Call_Finish();
}

public Native_CreateCompanion(Handle:plugin, params) {

	new client = GetNativeCell(1);
	decl String:CompanionName[64];
	GetNativeString(2, CompanionName, sizeof(CompanionName));

	Call_StartForward(g_CreateCompanion);
	Call_PushCell(client);
	Call_PushString(CompanionName);
	Call_Finish();
}

public Native_CallModule(Handle:plugin, params) {
	
	decl String:s_command1[128];
	GetNativeString(1, s_command1, sizeof(s_command1));

	decl String:s_command2[128];
	GetNativeString(2, s_command2, sizeof(s_command2));

	new i_command									= GetNativeCell(3);

	Call_StartForward(g_CallModule);
	Call_PushString(s_command1);
	Call_PushString(s_command2);
	Call_PushCell(i_command);
	Call_Finish();
}

public Native_GetHeader(Handle:plugin, params) {

	Call_StartForward(g_Header);
	Call_PushString(s_rup);
	Call_Finish();
}

public Native_GetCampaignName(Handle:plugin, params) {

	Call_StartForward(g_GetCampaignName);
	Call_PushString(CurrentCampaignName);
	Call_Finish();
}

public Native_IsCampaignFinale(Handle:plugin, params) {

	Call_StartForward(g_CampaignStatus);
	if (IsEligibleMap(1)) Call_PushCell(1);
	else if (IsEligibleMap(0)) Call_PushCell(0);
	else Call_PushCell(-1);
	Call_Finish();
}

public Native_GroupMemberStatus(Handle:plugin, params) {

	new client		= GetNativeCell(1);
	new groupStatus = GetNativeCell(2);

	Call_StartForward(g_IsGroupMemberStatus);
	Call_PushCell(client);
	Call_PushCell(groupStatus);
	Call_Finish();
}

public Native_IsEmptyOnDisconnect(Handle:plugin, params) {

	Call_StartForward(g_IsEmptyOnDisconnect);
	Call_Finish();
}

public Native_HandicapChanged(Handle:plugin, params) {

	new handicaplevel				= GetNativeCell(1);

	if (handicaplevel < 1) handicaplevel = 1;

	Call_StartForward(g_InfectedBotLimit);
	Call_PushCell(handicaplevel);
	Call_Finish();
}

public Native_ConfigProcessing(Handle:plugin, params) {

	if (b_IsParseConfig) return 1;
	else return 0;
}

public Native_SurvivorControl(Handle:plugin, params) {

	new client										= GetNativeCell(1);

	Call_StartForward(g_SurvivorControl);
	Call_PushCell(client);
	Call_Finish();
}

public Native_TeamAssigned(Handle:plugin, params) {

	new client										= GetNativeCell(1);
	new team										= GetNativeCell(2);

	Call_StartForward(g_TeamAssigned);
	Call_PushCell(client);
	Call_PushCell(team);
	Call_Finish();
}

public Native_ChangeTeam(Handle:plugin, params) {

	new client										= GetNativeCell(1);
	new team										= GetNativeCell(2);

	if (iMaxSurvivorsAllowed > 1) {

		Call_StartForward(g_TeamChange);
		Call_PushCell(client);
		Call_PushCell(team);
		Call_Finish();
	}
}

public Native_FriendlyFire(Handle:plugin, params) {

	new client										= GetNativeCell(1);
	new victim										= GetNativeCell(2);
	new amount										= GetNativeCell(3);
	new health										= GetNativeCell(4);
	new isfire										= GetNativeCell(5);
	new bonusDamage									= GetNativeCell(6);

	Call_StartForward(g_FriendlyFire);
	Call_PushCell(client);
	Call_PushCell(victim);
	Call_PushCell(amount);
	Call_PushCell(health);
	Call_PushCell(isfire);
	Call_PushCell(bonusDamage);
	Call_Finish();
}

public Native_RegisterCommand(Handle:plugin, params) {

	decl String:command[128];
	decl String:description[128];

	new len;
	GetNativeStringLength(1, len);

	if (len <= 0) return false;

	GetNativeString(1, command, sizeof(command));

	GetNativeString(2, description, sizeof(description));
	new flags										= GetNativeCell(3);

	new a_Size										= GetArraySize(a_RegisteredCommands);

	decl String:a_command[128];

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:a_RegisteredCommands, i, a_command, sizeof(a_command));
		if (StrEqual(command, a_command)) return false;
	}

	PushArrayString(Handle:a_RegisteredCommands, command);
	PushArrayString(Handle:a_RegisteredCommands_Description, description);
	PushArrayCell(Handle:a_RegisteredCommands_Flags, flags);
	AddCommandListener(CommandListener, command);

	return true;
}

public Native_EntryDenied(Handle:plugin, params) {

	Call_StartForward(g_EntryDenied);
	Call_Finish();
}

public Native_EntryAllowed(Handle:plugin, params) {

	new client										= GetNativeCell(1);

	Call_StartForward(g_EntryAllowed);
	Call_PushCell(client);
	Call_Finish();
}

public Native_GetCommands(Handle:plugin, params) {

	new client										= GetNativeCell(1);

	Call_StartForward(g_SendCommands);
	Call_PushCell(client);
	Call_PushCell(Handle:a_RegisteredCommands);
	Call_PushCell(Handle:a_RegisteredCommands_Description);
	Call_PushCell(Handle:a_RegisteredCommands_Flags);
	Call_Finish();
}

public Native_SlotChange(Handle:plugin, params) {

	Call_StartForward(g_SlotChange);
	Call_Finish();
}

public Native_RemoveCommand(Handle:plugin, params) {

	decl String:command[128];

	GetNativeString(1, command, sizeof(command));

	new a_Size										= GetArraySize(a_RegisteredCommands);

	decl String:a_command[128];

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:a_RegisteredCommands, i, a_command, sizeof(a_command));
		if (StrEqual(command, a_command)) {

			RemoveFromArray(Handle:a_RegisteredCommands, i);
			RemoveFromArray(Handle:a_RegisteredCommands_Description, i);
			RemoveFromArray(Handle:a_RegisteredCommands_Flags, i);

			return true;
		}
	}

	return false;
}

public ClearRegisteredCommands() {

	ClearArray(Handle:a_RegisteredCommands);
	ClearArray(Handle:a_RegisteredCommands_Description);
	ClearArray(Handle:a_RegisteredCommands_Flags);
}
/*
public Action:Event_Customs(Handle:event, const String:event_name[], bool:dontBroadcast) {

	new a_Size;
	a_Size												= GetArraySize(Handle:a_RegisteredEvents);
	new attacker;
	new victim;
	new infected;

	decl String:name[64];
	decl String:s_attacker[64];
	decl String:s_victim[64];
	decl String:s_infected[64];

	for (new i = 0; i < a_Size; i++) {

		GetConVarString(Handle:a_RegisteredEvents, i, name, sizeof(name));

		if (StrEqual(name, event_name)) {

			GetArrayString(Handle:a_RegisteredEvents_attacker, i, s_attacker, sizeof(s_attacker));
			GetArrayString(Handle:a_RegisteredEvents_victim, i, s_victim, sizeof(s_victim));
			GetArrayString(Handle:a_RegisteredEvents_infected, i, s_infected, sizeof(s_infected));
			
			if (!StrEqual(s_attacker), "0") attacker = GetClientOfUserId(GetEventInt(event, s_attacker));
			if (!StrEqual(s_victim), "0") victim = GetClientOfUserId(GetEventInt(event, s_victim));
			if (!StrEqual(s_infected), "0") infected = GetClientOfUserId(GetEventInt(event, s_infected));

			CallEvent(name, i, dontBroadcast, attacker, victim, infected);

			break;
		}
	}
}
*/

stock Cmd_ForceStart(client) {

	Now_OpenSaferoomDoor();
	if (i_IsReadyUpIgnored > 0) return;
	if (!b_IsReadyUp && client > 0) {

		PrintToChat(client, "%T", "command sm_forcestart is unavailable", client, s_rup);
	}
	else {

		b_IsReadyUp									= false;
		Now_OnReadyUpEnd();

		if (client == 0) {

			Now_OpenSaferoomDoor();
			//DeleteSaferoomDoors();
		}

		for (new i = 1; i <= MaxClients; i++) {

			if (!IsClientInGame(i) || !IsValidEntity(i)) continue;
			if (!IsClientActual(i)) continue;
			SetEntityMoveType(i, MOVETYPE_WALK);
			b_IsReady[i]							= true;
		}
	}
}

stock Cmd_ToggleHud(client) {

	if (i_IsReadyUpIgnored > 0) return;
	if (!i_IsHudDisabled) {

		if (b_IsHideHud[client]) {

			PrintToChat(client, "%T", "hud enabled", client, s_rup, blue);
			b_IsHideHud[client]							= false;
		}
		else {

			PrintToChat(client, "%T", "hud disabled", client, s_rup, orange);
			b_IsHideHud[client]							= true;
		}
	}
}

stock Cmd_ToggleReady(client) {

	if (i_IsReadyUpIgnored > 0 || !b_IsAllClientsLoaded) return;
	if (b_IsReadyUp && !i_IsHudDisabled) {

		if (b_IsReady[client]) {

			PrintToChat(client, "%T", "not ready", client, s_rup, orange);
			b_IsReady[client]							= false;
		}
		else {

			PrintToChat(client, "%T", "ready", client, s_rup, blue);
			b_IsReady[client]							= true;

			if (IsMajorityCounter()) {

				if (Match_Countdown == INVALID_HANDLE) Match_Countdown = CreateTimer(1.0, Timer_Match_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

stock Cmd_ToggleBots(client) {

	if (t_SetBotTimer == INVALID_HANDLE) {

		PrintToChat(client, "%T", "no bot vote in progress", client, white, orange, white);
	}
	else {

		if (bNoBots[client]) {

			bNoBots[client] = false;
			PrintToChat(client, "%T", "bot vote: yes", client, white, blue);
		}
		else {

			bNoBots[client] = true;
			PrintToChat(client, "%T", "bot vote: no", client, white, orange);
		}
	}
}

stock bool:IsBotVoteIgnored(bool:breset=false) {

	new votes_for = 0;
	new votes_ags = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (breset) bNoBots[i] = false;
			else {

				if (bNoBots[i]) votes_ags++;
				else votes_for++;
			}
		}
	}
	if (votes_ags > votes_for) return true;
	return false;
}

stock bool:IsMajorityCounter() {

	if (i_IsMajority == 1) {

		new num_Ready			=	0;
		new num_NotReady		=	0;
		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) {

				if (b_IsReady[i]) num_Ready++;
				else num_NotReady++;
			}
		}
		if (num_Ready > num_NotReady) return true;
	}
	return false;
}

public Action:Timer_Match_Countdown(Handle:timer) {

	static i_CountdownTimer					=	-1;
	if (i_CountdownTimer == -1) {

		i_CountdownTimer					=	i_IsMajorityTimer;
	}
	if (!ClientsExist()) return Plugin_Continue;

	i_CountdownTimer--;
	if (i_CountdownTimer < 1 || b_ReadyUpOver) {

		if (!b_ReadyUpOver) Now_OnReadyUpEnd();
		Match_Countdown						=	INVALID_HANDLE;
		i_CountdownTimer					=	-1;
		return Plugin_Stop;
	}
	if (!IsMajorityCounter()) {

		PrintToChatAll("%t", "timer match countdown aborted", orange);
		Match_Countdown						=	INVALID_HANDLE;
		i_CountdownTimer					=	-1;
		return Plugin_Stop;
	}

	PrintHintTextToAll("%t", "timer match countdown", i_CountdownTimer);
	return Plugin_Continue;
}

stock Now_ChangeAllTalk(bool:b_IsEnabled) {

	if (i_IsReadyUpIgnored > 0) return;

	SetConVarFlags(g_IsAllTalk, GetConVarFlags(g_IsAllTalk) & ~FCVAR_NOTIFY);
	SetConVarBool(g_IsAllTalk, b_IsEnabled);

	if (b_IsEnabled) PrintToChatAll("%t", "alltalk enabled", s_rup, green);
	else PrintToChatAll("%t", "alltalk disabled", s_rup, orange);

	SetConVarFlags(g_IsAllTalk, GetConVarFlags(g_IsAllTalk) & FCVAR_NOTIFY);
}

public Action:Event_PlayerTeam(Handle:event, const String:event_name[], bool:dontBroadcast) {

	new client											= GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsClientHuman(client)) return;

	decl String:AuthId[64];
	GetClientAuthString(client, AuthId, sizeof(AuthId));
	if (StrEqual(lastClient, AuthId)) return;

	strcopy(lastClient, sizeof(lastClient), AuthId);

	//Call_StartForward(g_TeamChange);
	//Call_PushCell(client);
	//Call_Finish();

	CreateTimer(1.0, Timer_ClearAuthId, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ClearAuthId(Handle:timer, any:client) {

	if (IsClientHuman(client)) {

		decl String:AuthId[64];

		GetClientAuthString(client, AuthId, sizeof(AuthId));

		if (StrEqual(lastClient, AuthId)) lastClient = "";
	}

	return Plugin_Stop;
}

public Action:Event_PlayerDisconnect(Handle:event, const String:event_name[], bool:dontBroadcast) {

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!client || !IsClientAuthorized(client) || !IsClientInGame(client) || !IsClientHuman(client)) return;
	LogMessage("%N has left the server.", client);
	bNoBots[client] = false;
	Call_StartForward(g_IsTrueDisconnect);
	Call_PushCell(client);
	Call_Finish();
}

public Action:Event_SurvivalRoundStart(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (GetGamemodeType() == 3) Now_OpenSaferoomDoor();
}

public Action:Event_ScavengeRoundStart(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (GetGamemodeType() == 4) Now_OpenSaferoomDoor();
}

public Action:Event_FinaleWin(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (GetGamemodeType() != 2) {

		b_IsFinaleWon									= true;
		Call_StartForward(g_IsFinaleWon);
		Call_Finish();
	}
}

public GetGamemodeType() {

	decl String:CurrentGamemode[64];
	GetConVarString(FindConVar("mp_gamemode"), CurrentGamemode, sizeof(CurrentGamemode));

	if (StrContains(GamemodeCoop, CurrentGamemode, false) != -1) return 1;
	else if (StrContains(GamemodeVersus, CurrentGamemode, false) != -1) return 2;
	else if (StrContains(GamemodeSurvival, CurrentGamemode, false) != -1) return 3;
	else if (StrContains(GamemodeScavenge, CurrentGamemode, false) != -1) return 4;

	return 0;
}

public Action:Event_MapTransition(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (GetGamemodeType() != 2 && !b_IsRoundOver) {

		Call_StartForward(g_IsMapTransition);
		Call_Finish();

		new i_Temp									= GetGamemodeType();
		if (i_Temp == 0) SetFailState("Current gamemode not supported. Please add this gamemode to the configs/readyup/readyup.cfg");
		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();

		bIsReadyUpEligible							= true;
		b_IsRoundOver								= true;
		b_IsTransition								= true;
	}
}

stock bool:IsEligibleMap(i_Type = 0) {

	decl String:s_Map[32];
	GetCurrentMap(s_Map, sizeof(s_Map));
	LowerString(s_Map);

	new a_Size = GetArraySize(a_FirstMap);
	decl String:a_Map[32];
	new bool:isSurvival = (GetGamemodeType() == 3) ? true : false;
	for (new i = 0; i < a_Size; i++) {

		if (isSurvival) GetArrayString(Handle:a_SurvivalMap, i, a_Map, sizeof(a_Map));
		else {
			if (i_Type == 0) GetArrayString(Handle:a_FirstMap, i, a_Map, sizeof(a_Map));
			else GetArrayString(Handle:a_FinalMap, i, a_Map, sizeof(a_Map));
		}
		if (StrEqual(s_Map, a_Map)) return true;
	}
	return false;
}

stock GetCurrentCampaignName() {

	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	LowerString(mapname);
	new size = 0;

	if (iForceCampaign == 1) { 
		new bool:isSurvival = (GetGamemodeType() == 3) ? true : false;
		if (!isSurvival) {

			/*
				Only campaigns in the list are eligible.
			*/
			size = GetArraySize(Handle:a_FirstMap) - 1;
			decl String:mapcheck[64];
			for (new i = 0; i <= size; i++) {
				GetArrayString(Handle:a_FirstMap, i, mapcheck, sizeof(mapcheck));
				if (StrEqual(mapname, mapcheck, false)) {
					// We need to store the campaign description so that if we're on a map in the campaign that isn't
					// the first map, we don't change the map on players.

					// to make code easier, map descriptions must line-up with their campaign counterpart.
					GetArrayString(Handle:a_CampaignMapDescriptionValue, i, CurrentCampaignName, sizeof(CurrentCampaignName));
					return;	// starter map is found in the list, so we don't rotate the map.
				}
			}
			// If we've made it this far, the map in play is either the first map of a campaign NOT in the rotation or its a map in an eligible campaign
			// We need to discern which that is, because we only force a campaign change if the map isn't part of a campaign in the rotation.
			size = GetArraySize(a_CampaignMapDescriptionValue);
			for (new i = 0; i < size; i++) {
				GetArrayString(a_CampaignMapDescriptionValue, i, mapname, sizeof(mapname));	// recycle the string since we don't need its stored value anymore
				if (StrEqual(mapname, CurrentCampaignName, false)) return;	// the current map is part of an eligible campaign, so we don't force a campaign change.
			}
			size--;	// see line 1029;
			if (size > 0) size = GetRandomInt(0, size);
			GetArrayString(Handle:a_FirstMap, size, mapname, sizeof(mapname));
		}
		else if (!IsEligibleMap()) {
			size = GetRandomInt(0, GetArraySize(a_SurvivalMap) - 1);
			GetArrayString(Handle:a_SurvivalMap, size, mapname, sizeof(mapname));
		}
		else return;
		ServerCommand("changelevel %s", mapname);
		return;
	}

	size = GetArraySize(a_CampaignMapDescriptionKey);
	decl String:s_MapDescription[64];

	for (new i = 0; i < size; i++) {

		GetArrayString(Handle:a_CampaignMapDescriptionKey, i, s_MapDescription, sizeof(s_MapDescription));
		if (StrEqual(mapname, s_MapDescription, false)) {

			GetArrayString(Handle:a_CampaignMapDescriptionValue, i, CurrentCampaignName, sizeof(CurrentCampaignName));
			return;
		}
	}
}

public Action:Event_StartDoorOpened(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (b_IsExitedStartArea) return;
	if (i_IsReadyUpIgnored == 1) b_IsExitedStartArea = true;

	new bool:b_IsCheckpointDoor						= GetEventBool(event, "checkpoint");
	Now_StartDoorOpened(b_IsCheckpointDoor);
}

public Action:Event_PlayerSpawn(Handle:event, String:event_name[], bool:dontBroadcast) {

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	//if (!IsClientActual(client) || IsFakeClient(client)) return;
	if (!b_IsFirstClientSpawn) {

		b_IsFirstClientSpawn							= true;

		if (!IsEligibleMap(0) && i_IsFreeze == 0 && i_IsReadyUpIgnored == 0) {

			//SaferoomDoor						= Now_FindAndLockSaferoomDoor();
			ToggleSaferoomDoor(false);	// true to lock.
		}

		Call_StartForward(g_FirstClientSpawn);
		Call_Finish();
	}

	if (GetGamemodeType() == 2) return;
	if (!IsClientActual(client) || GetClientTeam(client) != TEAM_SURVIVOR) return;

	if (b_IsRoundOver && !b_IsFirstHumanSpawn && !b_IsFirstRound && !b_IsTransition) {

		if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		else b_IsIntermission						= false;
		b_IsFirstHumanSpawn							= true;
		bIsReadyUpEligible							= true;
		Now_OnReadyUpStart();
	}
}

public Action:Event_MissionLost(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (GetGamemodeType() == 2) return;

	new i_Temp										= GetGamemodeType();
	if (i_Temp == 0) SetFailState("Current gamemode not supported. Please add this gamemode to the configs/readyup/readyup.cfg");

	//if (!IsEligibleMap(1)) {

	Call_StartForward(g_IsRoundEndFailed);
	Call_PushCell(i_Temp);
	Call_Finish();
	//}
	if (!b_IsRoundOver) {

		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();

		if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		else b_IsIntermission						= false;
		b_IsRoundOver								= true;
		bIsReadyUpEligible							= true;
		i_RoundCount++;
		Now_CheckIsMapComplete();
	}
}

stock Now_CheckIsMapComplete() {

	new i_Temp			= GetGamemodeType();

	if (i_Temp == 1 && i_RoundCount >= i_CoopMapRounds && IsEligibleMap(1) ||
		i_Temp == 2 && i_RoundCount >= 2 ||
		i_Temp == 3 && i_RoundCount >= i_SurvivalMapRounds) {

		b_IsMapComplete								= true;
	}
}



public Native_IsTeamsFlipped(Handle:plugin, params) {

	b_IsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);
	return _:b_IsTeamsFlipped;
}

public Native_ParseConfig(Handle:plugin, params) {

	decl String:p_config[PLATFORM_MAX_PATH];
	new len;
	GetNativeStringLength(1, len);

	if (len <= 0) return;

	GetNativeString(1, p_config, sizeof(p_config));

	NtvCall_ParseConfig(p_config, 0);
}

public Native_ParseConfigEx(Handle:plugin, params) {
	
	decl String:p_config[PLATFORM_MAX_PATH];
	new len;
	GetNativeStringLength(1, len);

	if (len <= 0) return;

	GetNativeString(1, p_config, sizeof(p_config));

	new i_StoreKeyCount							= GetNativeCell(2);

	NtvCall_ParseConfig(p_config, i_StoreKeyCount);
}

public NtvCall_ParseConfig(String:p_config[], storeKey) {

	decl String:error[PLATFORM_MAX_PATH];
	decl String:path[PLATFORM_MAX_PATH];
	strcopy(path, sizeof(path), p_config);
	BuildPath(Path_SM, path, sizeof(path), "configs/readyup/%s", path);

	if (!FileExists(path)) {

		Format(error, sizeof(error), "%s", path);

		Call_StartForward(g_ParseConfigFailed);
		Call_PushString(p_config);
		Call_PushString(error);
		Call_Finish();
		return;
	}

	if (b_IsParseConfig) {

		PushArrayString(Handle:a_PluginLoadQueue, p_config);
		PushArrayCell(Handle:a_PluginLoadQueue_Count, storeKey);
		return;
	}

	b_IsParseConfig									= true;

	strcopy(s_ActiveConfig, sizeof(s_ActiveConfig), p_config);
	StoreKeys									= storeKey;

	ClearArray(Handle:a_SectionConfig);

	ProcessConfigFile(path);
}

public Native_GetGameMode(Handle:plugin, params) { return GetGamemodeType(); }

public Action:Event_ScavengeRoundEnd(Handle:event, String:event_name[], bool:dontBroadcast) {

	new i_Temp										= GetGamemodeType();

	if (i_Temp == 4) {

		if (!b_IsRoundOver) {

			b_IsRoundOver = true;
			bIsReadyUpEligible = true;
			i_RoundCount++;
			Now_CheckIsMapComplete();

			Call_StartForward(g_IsRoundEnd);
			Call_PushCell(i_Temp);
			Call_Finish();

			if (b_IsIntermission) b_IsTransition = true;
			if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
			else b_IsIntermission = false;

			b_IsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);

			if (!b_IsMapComplete) CreateTimer(1.0, Timer_IsNewRound, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			if (i_IsWarmupAllTalk == 1) Now_ChangeAllTalk(true);
			
			for (new i = 1; i <= MaxClients; i++) {

				if (IsClientActual(i)) {
				
					b_IsReady[i]						= false;
					b_IsHideHud[i]						= false;
				}
			}
		}
	}
}

public Action:Event_RoundEnd(Handle:event, String:event_name[], bool:dontBroadcast) {

	new i_Temp										= GetGamemodeType();

	if (i_Temp == 1) return;

	if (!b_IsRoundOver && !b_IsFinaleWon) {

		b_IsRoundOver								= true;
		bIsReadyUpEligible							= true;
		i_RoundCount++;
		Now_CheckIsMapComplete();

		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();

		if (b_IsIntermission) b_IsTransition		= true;
		if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		else b_IsIntermission						= false;

		b_IsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);

		if (!b_IsMapComplete) CreateTimer(1.0, Timer_IsNewRound, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (i_IsWarmupAllTalk == 1) Now_ChangeAllTalk(true);
		
		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientActual(i)) {
			
				b_IsReady[i]						= false;
				b_IsHideHud[i]						= false;
			}
		}
	}
}

public Action:Event_PlayerLeftStartArea(Handle:event, String:event_name[], bool:dontBroadcast) {

	new client										= GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsClientHuman(client) || GetClientTeam(client) != TEAM_SURVIVOR) return;
	b_IsInStartArea[client]							= false;
}

public Action:Timer_IsNewRound(Handle:timer) {

	if (!b_IsTransition && !b_IsMapComplete) {
	
		new bool:b_tIsTeamsFlipped					= !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);
		if (b_IsTeamsFlipped == b_tIsTeamsFlipped) return Plugin_Continue;

		Now_OnReadyUpStart();
	}
	return Plugin_Stop;
}

public OnConfigsExecuted() {

	SetConVarString(FindConVar("readyup_version"), PLUGIN_VERSION);
	SetConVarInt(FindConVar("versus_force_start_time"), 99999);

	BuildPath(Path_SM, s_Path, sizeof(s_Path), "configs/readyup/");
	if (!DirExists(s_Path)) CreateDirectory(s_Path, 511);

	//GetConVarString(g_IsGameMode, s_IsGameMode, sizeof(s_IsGameMode));

	BuildPath(Path_SM, s_Config, sizeof(s_Config), "configs/readyup/readyup.cfg");
	if(!FileExists(s_Config)) {
	
		SetFailState("File not found: %s", s_Config);
	}

	decl String:s_MapList[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, s_MapList, sizeof(s_MapList), "configs/readyup/maplist.cfg");
	if (!FileExists(s_MapList)) {

		SetFailState("File not found: %s", s_MapList);
	}

	bIsReadyUpEligible = true;
	b_ReadyUpOver = false;

	ClearRegisteredCommands();

	ClearArray(Handle:a_FirstMap);
	ClearArray(Handle:a_FinalMap);
	ClearArray(Handle:a_SurvivalMap);
	ClearArray(Handle:a_SurvivalMapNext);

	ClearArray(Handle:a_CampaignMapDescriptionKey);
	ClearArray(Handle:a_CampaignMapDescriptionValue);
	ClearArray(Handle:a_SurvivalMapDescriptionKey);
	ClearArray(Handle:a_SurvivalMapDescriptionValue);

	//ClearArray(Handle:a_PluginLoadQueue);

	b_IsParseConfig									= false;

	ProcessConfigFile(s_Config);
	ProcessConfigFile(s_MapList);
	GetCurrentCampaignName();
}

public OnMapStart() {

	b_IsExitedStartArea								= false;
	b_IsFirstClientSpawn							= false;
	g_IsClientConnection							= INVALID_HANDLE;
	g_IsFreezeTimer									= INVALID_HANDLE;
	g_ForceReadyUpStartTimer						= INVALID_HANDLE;
	g_IsMatchStart									= INVALID_HANDLE;
	t_SetBotTimer									= INVALID_HANDLE;
	i_RoundCount									= 0;
	b_IsMapComplete									= false;
	b_IsTransition									= false;
	b_IsFirstClientLoaded							= false;
	b_IsFirstRound									= true;
	b_IsAllClientsLoaded							= false;
	bIsReadyUpEligible = true;
	b_ReadyUpOver = false;

	IsReadyUpLoaded = false;
	b_IsReadyUp = false;
	b_IsRoundOver = false;
	b_IsFinaleWon = false;
	b_IsTeamsFlipped = false;
	b_IsIntermission = false;
	b_IsSaferoomDoorOpened = false;
	b_IsReadyUpOver = false;
	b_IsReadyUpStart = false;

	SaferoomDoor = -1;
	EndOfMapDoor = -1;
	bIsCheckpointRotating = false;
	/*if (!IsEligibleMap(0)) { //} && i_IsReadyUpIgnored == 0) {

		//SaferoomDoor								= Now_FindAndLockSaferoomDoor();
		ToggleSaferoomDoor(false);	// true to unlock.
	}*/
}

stock Now_SetAllClientsToNotReady() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && IsClientActual(i)) {

			b_IsHideHud[i]								= false;
			b_IsReady[i]								= false;
		}
	}
}

stock bool:IsClientsFound() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

stock Now_OnReadyUpStart() {

	if (b_IsReadyUpStart) return;
	b_IsReadyUpOver = false;
	b_IsReadyUpStart = true;
	b_IsSaferoomDoorOpened = false;
	Call_StartForward(g_MinimumSurvivors);
	Call_PushCell(iMinSurvivors);
	Call_Finish();

	if (b_IsMapComplete || b_IsTransition || !bIsReadyUpEligible) return; // || i_IsReadyUpIgnored == 1) return;

	b_ReadyUpOver									= false;

	Now_SetAllClientsToNotReady();

	b_IsExitedStartArea								= false;
	b_IsFinaleWon									= false;
	EndOfMapDoor = -1;
	UnlockEndOfMapCheckpointDoor();

	decl String:theMap[64];
	GetCurrentMap(theMap, sizeof(theMap));
	if (GetGamemodeType() != 3 && StrContains(theMap, ForceStartMaps, false) != -1) {

		Now_OnReadyUpEnd();
		return;
	}
	if (iMaxSurvivorBotsAllowed > 1 && iMaxSurvivorBotsAllowed != iMinSurvivors) PrintToChatAll("%t", "bot adjustment vote offer", blue, green, iMinSurvivors, orange, green, orange);

	if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 0 && i_IsPeriodicCountdown == 1 && (!IsEligibleMap(0) && i_ReadyUpTime > 0 || IsEligibleMap(0) && i_ReadyUpTimeFirst > 0) && i_IsReadyUpIgnored == 0) {

		new seconds									= 0;
		if (!IsEligibleMap(0)) seconds				= i_ReadyUpTime;
		else seconds								= i_ReadyUpTimeFirst;
		new minutes									= 0;
		
		while (seconds >= 60) {

			seconds									-= 60;
			minutes++;
		}
		PrintToChatAll("%t", "ready up time remaining", s_rup, orange, minutes, green, orange, seconds, green);
	}

	if (b_IsFirstRound) {

		Call_StartForward(g_IsAllClientsLoaded);
		Call_Finish();
	}
	else if (!IsEligibleMap(0) && i_IsFreeze == 0 && b_IsIntermission) { //} && i_IsReadyUpIgnored == 0) {

		//SaferoomDoor								= Now_FindAndLockSaferoomDoor();
		ToggleSaferoomDoor(false);	// true to unlock.
	}
	
	if (GetGamemodeType() != 3) {

		Call_StartForward(g_IsSaferoomLocked);
		Call_Finish();
	}

	Call_StartForward(g_IsReadyUpStart);
	Call_Finish();

	//if (i_IsWarmupAllTalk == 1 && i_IsReadyUpIgnored == 0) Now_ChangeAllTalk(true);

	b_IsAllClientsLoaded							= true;
	b_IsReadyUp										= true;

	if (g_IsFreezeTimer == INVALID_HANDLE) {
	
		g_IsFreezeTimer									= CreateTimer(1.0, Timer_IsFreeze, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	if (i_IsReadyUpIgnored == 2) {
		
		Now_OnReadyUpEnd();
		return;
	}
	else if (!b_IsReadyUp || (b_IsIntermission || b_IsFirstRound) && i_IsReadyUpIgnored == 0) {

		if (!IsEligibleMap(0) && i_ReadyUpTime > 0 || IsEligibleMap(0) && i_ReadyUpTimeFirst > 0) {

			g_IsMatchStart			= CreateTimer(1.0, Timer_IsMatchStart, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			PrintToChatAll("%t", "match ready up", s_rup, blue);
		}
		else Now_OnReadyUpEnd();
	}
	else Now_OnReadyUpEnd();
}

stock Spectators() {

	new count										= 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientConnected(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SPECTATOR) continue;
		count++;
	}
	return count;
}

stock Survivors() {

	new count										= 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientConnected(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

stock Infected() {

	new count										= 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientConnected(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
		count++;
	}
	return count;
}

stock Now_OpenSaferoomDoor() {

	if (b_IsSaferoomDoorOpened) return;
	LogMessage("Saferoom door has \"opened\" - Match start.");
	b_IsSaferoomDoorOpened = true;
	bIsCheckpointRotating = false;

	b_IsExitedStartArea								= true;

	// Safe to clear the plugin load queue, I think.
	//ClearArray(Handle:a_PluginLoadQueue);

	Call_StartForward(g_IsCheckpointDoorOpened);
	Call_Finish();

	if (DeleteTheDoors < 3) {
		if (!IsEligibleMap(0)) {

			if (IsValidEntity(SaferoomDoor)) {
				AcceptEntityInput(SaferoomDoor, "Kill");
				SaferoomDoor = -1;
			}
		}
		Call_StartForward(g_IsSaferoomDoorDestroyed);
		Call_Finish();
		if (DeleteTheDoors == 2) DeleteSaferoomDoors();
	}
}

stock Now_OnReadyUpEnd() {

	if (b_IsReadyUpOver) return;
	b_IsReadyUpOver = true;
	b_IsReadyUpStart = false;

	/*if (!IsClientsFound() && i_IsReadyUpIgnored == 0) {

		if (g_IsClientConnection == INVALID_HANDLE) {

			g_IsClientConnection					= CreateTimer(1.0, Timer_IsClientConnection, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		return;
	}*/
	bIsReadyUpEligible									= false;
	b_ReadyUpOver										= true;

	b_IsFirstHumanSpawn									= false;

	Call_StartForward(g_IsReadyUpEnd);
	Call_Finish();

	if (i_IsWarmupAllTalk == 1) Now_ChangeAllTalk(false);
	decl String:theMap[64];
	GetCurrentMap(theMap, sizeof(theMap));

	if (IsEligibleMap(0) && GetGamemodeType() != 3 || !IsEligibleMap(0) && StrContains(theMap, ForceStartMaps, false) != -1 && GetGamemodeType() != 3) { //} && i_IsReadyUpIgnored == 0) {

		Now_OpenSaferoomDoor();
	}

	//if (i_IsReadyUpIgnored == 0)
	if (i_IsReadyUpIgnored == 0) PrintToChatAll("%t", "match is live", s_rup, blue);
	LogMessage("Ready Up has ended...");

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientActual(i)) continue;
		b_IsReady[i]								= false;
		if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
		b_IsInStartArea[i]							= true;
	}

	b_IsFirstRound									= false;
	b_IsRoundOver									= false;
	b_IsReadyUp										= false;

	if (!IsEligibleMap(0) && i_IsFreeze == 0) {

		if (i_IsDoorForcedOpen > 0) {
		
			CreateTimer(i_IsDoorForcedOpen * 1.0, Timer_IsDoorForcedOpen, _, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(i_IsDoorForcedOpen + 0.85, Timer_IsDoorForcedOpen, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		//Now_UnlockSaferoomDoor();
		ToggleSaferoomDoor(true);	// true to unlock.
	}

	Now_SetAllClientsToNotReady();
	Call_StartForward(g_MinimumSurvivors);
	Call_PushCell(iMinSurvivors);
	Call_Finish();
	//PrintToChatAll("%t", "bot adjustment vote offer", blue, green, iMinSurvivors, orange, green, orange);

	if (i_IsReadyUpHalftime == 1 && i_IsReadyUpIgnored == 0) PrintToChatAll("%t", "intermission", s_rup);
	b_IsIntermission								= false;
}

public Action:Timer_IsDoorForcedOpen(Handle:timer) {

	if (b_IsExitedStartArea || b_IsMapComplete || i_IsReadyUpIgnored == 0) return Plugin_Stop;

	b_IsExitedStartArea								= true;
	Now_DoorForcedOpen("director_force_versus_start");
	return Plugin_Stop;
}

stock Now_StartDoorOpened(bool:checkpoint) {

	if (GetGamemodeType() == 3) return;

	if (checkpoint) {

		Now_OpenSaferoomDoor();
		if (i_IsReadyUpIgnored == 0) {//CreateTimer(0.5, Timer_DeleteSaferoomDoor, _, TIMER_FLAG_NO_MAPCHANGE);

			//DeleteSaferoomDoors();
		}
	}
}

public OnClientConnected(client) {

	if (!IsClientInGame(client) && !IsFakeClient(client)) {

		if (!b_IsFirstClientLoaded) {

			if (!IsEligibleMap(0) && i_IsFreeze == 0 && b_IsIntermission) { //} && i_IsReadyUpIgnored == 0) {

				//SaferoomDoor								= Now_FindAndLockSaferoomDoor();
				ToggleSaferoomDoor(false);	// true to unlock.
			}
		}

		decl String:Name[MAX_NAME_LENGTH];
		GetClientName(client, Name, sizeof(Name));
		PrintToChatAll("%t", "client connected", s_rup, green, Name, white);

		/*Call_StartForward(g_MinimumSurvivors);
		Call_PushCell(iMinSurvivorsAllowed);
		Call_Finish();*/
	}
}

public Action:CMD_SetBotMinimum(client, args) {

	decl String:countReq[64];
	GetCmdArg(1, countReq, sizeof(countReq));
	new iCount = StringToInt(countReq);
	if (iMaxSurvivorBotsAllowed <= 1 || iMaxSurvivorBotsAllowed == iMinSurvivors) return Plugin_Handled;

	if (b_IsSaferoomDoorOpened && iCount >= iMinSurvivors) {	// can call votes to lower player count at any time.

		PrintToChat(client, "%T", "bot count restricted", client, white, orange);
		return Plugin_Handled;
	}
	if (iCount > iMaxSurvivorBotsAllowed) iCount = iMaxSurvivorBotsAllowed;
	else if (iCount < iMinSurvivorsAllowed) iCount = iMinSurvivorsAllowed;

	//if (t_SetBotTimer == INVALID_HANDLE && iCount <= iMaxSurvivorBotsAllowed && iCount >= iMinSurvivorsAllowed) {
	if (t_SetBotTimer == INVALID_HANDLE) {

		PrintToChatAll("%t", "bot adjustment vote called", orange, blue, iMinSurvivors, orange, green, iCount, blue, orange, s_Cmd_ToggleBots, blue);

		new Handle:thepackage;
		t_SetBotTimer = CreateDataTimer(1.0, Timer_SetBotTimer, thepackage, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(thepackage, iCount);
	}

	return Plugin_Handled;
}

public Action:Timer_SetBotTimer(Handle:timer, Handle:thepackage) {

	ResetPack(thepackage);
	new iCount = ReadPackCell(thepackage);

	static CountdownTimer = -1;
	if (CountdownTimer == -1) CountdownTimer = iBotCountdownTime;
	if (b_IsRoundOver) {

		CountdownTimer = -1;
		t_SetBotTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	CountdownTimer--;
	if (CountdownTimer < 1) {

		CountdownTimer = -1;
		PrintToChatAll("%t", "bot count adjusted", blue, white, green, iCount);
		iMinSurvivors = iCount;
		Call_StartForward(g_MinimumSurvivors);
		Call_PushCell(iMinSurvivors);
		Call_Finish();
		t_SetBotTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	else {
		if (iBotIntervalTime < 1) iBotIntervalTime = 1;

		if (IsBotVoteIgnored()) {

			IsBotVoteIgnored(true);
			PrintToChatAll("%t", "bot adjustment aborted", blue, orange);
			CountdownTimer = -1;
			t_SetBotTimer = INVALID_HANDLE;
			return Plugin_Stop;
		}
		else if (CountdownTimer % iBotIntervalTime == 0) PrintToChatAll("%t", "adjust bot count", blue, white, green, iCount, white, orange, CountdownTimer, white);
	}
	return Plugin_Continue;
}


public OnClientPostAdminCheck(client) {

	if (IsClientInGame(client)) {
		b_IsReady[client]	= false;
		survivorInCheckpoint[client] = false;
	}
	
	if (IsClientHuman(client)) {

		Call_StartForward(g_MinimumSurvivors);
		Call_PushCell(iMinSurvivors);
		Call_Finish();

		Call_StartForward(g_IsClientLoaded);
		Call_PushCell(client);
		Call_Finish();

		decl String:Name[MAX_NAME_LENGTH];
		GetClientName(client, Name, sizeof(Name));

		if (i_IsLoadedMessage == 1 && i_IsReadyUpIgnored == 0) PrintToChatAll("%t", "client loaded", s_rup, green, Name, white);

		if (i_IsHudDisabled == 0 && b_IsHideHud[client]) b_IsHideHud[client] = false;

		if (!b_IsTransition) {

			if (!b_IsFirstClientLoaded) {

				if (!IsEligibleMap(0) && i_IsFreeze == 0) { //} && i_IsReadyUpIgnored == 0) {

					//SaferoomDoor					= Now_FindAndLockSaferoomDoor();
					ToggleSaferoomDoor(false);	// true to lock.
				}

				if (GetGamemodeType() != 3) {

					Call_StartForward(g_IsSaferoomLocked);
					Call_Finish();
				}

				if (i_IsWarmupAllTalk == 1 && i_IsReadyUpIgnored == 0) Now_ChangeAllTalk(true);

				Now_RegisterCommands();

				Call_StartForward(g_IsFirstClientLoaded);
				Call_Finish();

				Call_StartForward(g_GetMaxSurvivorCount);
				Call_PushCell(iMaxSurvivorsAllowed);
				Call_Finish();

				b_IsFirstClientLoaded				= true;
				b_IsReadyUp							= true;
				b_IsAllClientsLoaded				= false;

				if (g_IsFreezeTimer == INVALID_HANDLE) {
	
					g_IsFreezeTimer					= CreateTimer(1.0, Timer_IsFreeze, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}

				if (i_IsConnectionTimeout > 0 && !b_IsAllClientsLoaded && g_ForceReadyUpStartTimer == INVALID_HANDLE) {

					g_ForceReadyUpStartTimer		= CreateTimer(1.0, Timer_ForceReadyUpStart, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}

			if (i_IsReadyUpIgnored == 1) {

				b_IsExitedStartArea = true;
				Cmd_ForceStart(0);
			}

			if (!IsClientsLoading() && !b_IsAllClientsLoaded && bIsReadyUpEligible) {

				b_IsIntermission					= false;
				b_IsFirstRound						= true;
				Now_OnReadyUpStart();
			}
		}
	}
}

// stock bool:IsEligiblePlayersReady() {
// 	return false;	// test to see if we can force a countdown timer every time?

// 	/*for (new i = 1; i <= MaxClients; i++) {

// 		if (!IsClientInGame(i) || !IsClientHuman(i)) continue;
// 		if (GetClientTeam(i) != TEAM_SPECTATOR && !b_IsReady[i]) return false;
// 	}
// 	return true;*/
// }

public Action:Timer_ForceReadyUpStart(Handle:timer) {

	static i_TimeoutCounter					= 0;
	i_TimeoutCounter						= i_IsConnectionTimeout;
	if (!IsClientsLoading()) {

		g_ForceReadyUpStartTimer					= INVALID_HANDLE;
		i_IsConnectionTimeout						= i_TimeoutCounter;
		return Plugin_Stop;
	}

	if (i_IsConnectionTimeout > 0) {

		i_IsConnectionTimeout--;

		if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 0 && i_IsPeriodicCountdown == 0 && i_IsReadyUpIgnored < 2) {

			if (IsClientsLoading() && !b_IsAllClientsLoaded || IsClientsLoading() && b_IsAllClientsLoaded && i_IsConnectionTimeout > 0) {

				new seconds							= i_TimeoutCounter;
				new minutes							= 0;

				while (seconds >= 60) {

					seconds							-= 60;
					minutes++;
				}

				if (i_IsConnectionTimeout > 0) PrintHintTextToAll("%t", "connection timeout", minutes, seconds);
			}
		}
		return Plugin_Continue;
	}
	else if (!b_IsAllClientsLoaded) {

		b_IsAllClientsLoaded						= true;
		b_IsIntermission							= false;
		b_IsFirstRound								= true;
		Now_OnReadyUpStart();
	}

	g_ForceReadyUpStartTimer						= INVALID_HANDLE;
	i_IsConnectionTimeout							= i_TimeoutCounter;

	return Plugin_Stop;
}

public Action:Timer_IsFreeze(Handle:timer) {

	if (b_IsMapComplete) {
	
		g_IsFreezeTimer								= INVALID_HANDLE;
		return Plugin_Stop;
	}
	if (!b_IsReadyUp) {

		for (new i = 1; i <= MaxClients; i++) {

			if (!IsClientInGame(i)) continue;
			if (IsClientActual(i) && (GetClientTeam(i) == TEAM_SURVIVOR || i_IsFreeze == 1) && (i_IsFreeze == 1 || IsEligibleMap(0))) {
					
				SetEntityMoveType(i, MOVETYPE_WALK);
			}
		}
		
		g_IsFreezeTimer								= INVALID_HANDLE;
		return Plugin_Stop;
	}
	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientConnected(i) || !IsClientInGame(i)) continue;

		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) {

			if ((IsClientsLoading() && i_IsHudDisabled == 1) || i_IsHudDisabled == 0) {

				if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 1 || i_IsHudDisabled == 0) {

					if (!b_IsHideHud[i]) SendPanelToClientAndClose(ReadyUpMenu(i), i, ReadyUpMenu_Init, 1);
				}
			}
		}

		if (b_IsReadyUp) {

			if (GetGamemodeType() != 3) {

				if (IsClientActual(i) && (GetClientTeam(i) == TEAM_SURVIVOR || i_IsFreeze == 1) && (i_IsFreeze == 1 || IsEligibleMap(0) && i_IsFreeze != 2)) {
					
					SetEntityMoveType(i, MOVETYPE_NONE);
				}
			}
			else {

				SetEntityMoveType(i, MOVETYPE_WALK);
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:Timer_IsMatchStart(Handle:timer) {
	static bool:IsMapEligible				= false;
	static i_TimeoutCounter					= 0;
	if (i_TimeoutCounter == 0) {

		if (!IsEligibleMap(0)) i_TimeoutCounter						= i_ReadyUpTime;
		else i_TimeoutCounter										= i_ReadyUpTimeFirst;
	}
	static i_PeriodicCounter				= 0;
	if (i_PeriodicCounter == 0) i_PeriodicCounter					= i_IsPeriodicTime;

	if (b_IsMapComplete || !b_IsReadyUp) {

		if (!IsEligibleMap(0)) i_ReadyUpTime						= i_TimeoutCounter;
		else i_ReadyUpTimeFirst										= i_TimeoutCounter;

		i_IsPeriodicTime							= i_PeriodicCounter;
		g_IsMatchStart								= INVALID_HANDLE;
		return Plugin_Stop;
	}
	// pause the timer if there are no human non-spectators.
	if (!ClientsExist()) {
		i_ReadyUpTimeFirst  = i_TimeoutCounter;
		i_ReadyUpTime		= i_TimeoutCounter;
		return Plugin_Continue;
	}

	IsMapEligible = IsEligibleMap(0);

	if ((!IsMapEligible && i_ReadyUpTime < 1 || IsMapEligible && i_ReadyUpTimeFirst < 1)) {

		Now_OnReadyUpEnd();
		if (!IsEligibleMap(0)) i_ReadyUpTime		= i_TimeoutCounter;
		else i_ReadyUpTimeFirst						= i_TimeoutCounter;
		i_IsPeriodicTime							= i_PeriodicCounter;
		g_IsMatchStart								= INVALID_HANDLE;
		return Plugin_Stop;
	}

	if (!IsEligibleMap(0) && i_ReadyUpTime > 0 || IsEligibleMap(0) && i_ReadyUpTimeFirst > 0) {

		i_IsPeriodicTime--;

		if (!IsClientsLoading() || b_IsAllClientsLoaded && g_ForceReadyUpStartTimer == INVALID_HANDLE) {

			if (!IsEligibleMap(0)) i_ReadyUpTime--;
			else i_ReadyUpTimeFirst--;
		}
		new seconds	= 0;
		if (IsEligibleMap(0)) seconds		= i_ReadyUpTime;
		else seconds						= i_ReadyUpTimeFirst;
		new minutes							= 0;

		while (seconds >= 60) {

			seconds							-= 60;
			minutes++;
		}
		new bool:clientsAreStillLoading = IsClientsLoading();

		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) {

				if (i_IsHudDisabled == 0 && !b_IsHideHud[i]) SendPanelToClientAndClose(ReadyUpMenu(i), i, ReadyUpMenu_Init, 1);
				else if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 0) {

					//if (i_ReadyUpTime > 0 && g_ForceReadyUpStartTimer == INVALID_HANDLE) {
					if (!clientsAreStillLoading || b_IsAllClientsLoaded && g_ForceReadyUpStartTimer == INVALID_HANDLE) {
						if (i_IsPeriodicCountdown == 0 || i_IsPeriodicTime < 1) PrintHintTextToAll("%t", "warmup time remaining", minutes, seconds);
						if (i_IsPeriodicTime < 1) i_IsPeriodicTime = i_PeriodicCounter; 
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

stock bool:ClientsExist() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && IsClientHuman(i) && GetClientTeam(i) != TEAM_SPECTATOR) return true;
	}
	return false;
}

stock bool:IsSpectators() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && IsClientHuman(i) && GetClientTeam(i) == TEAM_SPECTATOR) return true;
	}
	return false;
}

stock bool:IsClientsLoading() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i)) return true;
	}

	/*if (GetGamemodeType() != 3) {

		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && b_IsHideHud[i]) b_IsReady[i] = true;
		}
	}*/
	return false;
}

stock NumClientsLoading() {

	new count										= 0;

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i)) count++;
	}
	
	return count;
}

public Handle:ReadyUpMenu(client) {

	new Handle:menu									= CreatePanel();

	decl String:text[1024];

	if (i_IsReadyUpIgnored == 0) {

		if (IsClientsLoading() && !b_IsAllClientsLoaded && g_ForceReadyUpStartTimer != INVALID_HANDLE) {

			new seconds								= i_IsConnectionTimeout;
			new minutes								= 0;

			while (seconds >= 60) {

				seconds								-= 60;
				minutes++;
			}

			Format(text, sizeof(text), "%T", "menu clients loading", client, minutes, seconds, NumClientsLoading());
			DrawPanelText(menu, text);
		}
		else if (IsClientsLoading() && g_ForceReadyUpStartTimer == INVALID_HANDLE || !IsClientsLoading()) {

			new seconds								= 0;
			if (!IsEligibleMap(0)) seconds			= i_ReadyUpTime;
			else seconds							= i_ReadyUpTimeFirst;
			new minutes								= 0;

			while (seconds >= 60) {

				seconds								-= 60;
				minutes++;
			}

			Format(text, sizeof(text), "%T", "ready up countdown", client, minutes, seconds);
			DrawPanelText(menu, text);
		}
	}
	else {

		Format(text, sizeof(text), "%T", "match begin notice", client, NumClientsLoading());
		DrawPanelText(menu, text);
	}

	/*if (IsClientsLoading()) {

		Format(text, sizeof(text), "%T", "players loading", client);
		DrawPanelText(menu, text);

		for (new i = 1; i <= MaxClients; i++) {

			if (!IsClientConnected(i) || IsClientInGame(i) || !IsClientHuman(i)) continue;
			Format(text, sizeof(text), "%N", i);
			DrawPanelText(menu, text);
		}
	}*/

	if (i_IsReadyUpIgnored == 0) {
		decl String:ClientName[64];
		if (i_IsHudDisabled == 0) {
			if (IsClientsLoading() && g_ForceReadyUpStartTimer == INVALID_HANDLE || !IsClientsLoading()) {
				Format(text, sizeof(text), "%T", "readyup panel info", client, PLUGIN_VERSION, iMinSurvivorsAllowed, GetCurrentSurvivorCount(), iMaxSurvivorsAllowed, GetReadyPlayerCount());
				DrawPanelText(menu, text);
				if (b_IsReady[client]) Format(text, sizeof(text), "%T", "i am ready", client);
				else Format(text, sizeof(text), "%T", "i am not ready", client);
				DrawPanelItem(menu, text);
				for (new i = 1; i <= MaxClients; i++) {
					if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientHuman(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
					GetClientName(i, ClientName, sizeof(ClientName));
					if (!b_IsReady[i]) Format(text, sizeof(text), "□");
					else Format(text, sizeof(text), "⛝");
					Format(text, sizeof(text), "%s %s", text, ClientName);
					DrawPanelText(menu, text);
				}
				/*Format(text, sizeof(text), "%T", "players ready", client);
				//DrawPanelText(menu, text);
				for (new i = 1; i <= MaxClients; i++) {
					if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientHuman(i) || !b_IsReady[i] || GetClientTeam(i) == TEAM_SPECTATOR) continue;
					GetClientName(i, ClientName, sizeof(ClientName));
					Format(text, sizeof(text), "%s \n %s", text, ClientName);
					//SQL_EscapeString(EscapeString, text, text, sizeof(text));
				}
				DrawPanelItem(menu, text);
				Format(text, sizeof(text), "%T", "players not ready", client);
				//DrawPanelText(menu, text);
				for (new i = 1; i <= MaxClients; i++) {
					if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientHuman(i) || b_IsReady[i] || GetClientTeam(i) == TEAM_SPECTATOR) continue;
					GetClientName(i, ClientName, sizeof(ClientName));
					Format(text, sizeof(text), "%s \n %s", text, ClientName);
					//SQL_EscapeString(EscapeString, text, text, sizeof(text));
				}
				DrawPanelItem(menu, text);*/
			}
			else {

				Format(text, sizeof(text), "%T", "players loading", client);
				//DrawPanelText(menu, text);

				for (new i = 1; i <= MaxClients; i++) {

					if (!IsClientConnected(i) || IsClientInGame(i) || !IsClientHuman(i)) continue;
					//GetClientName(i, ClientName, sizeof(ClientName));
					Format(text, sizeof(text), "%s \n %N", text, i);
					//SQL_EscapeString(EscapeString, text, text, sizeof(text));

				}
				DrawPanelItem(menu, text);

				Format(text, sizeof(text), "%T", "players waiting", client);
				//DrawPanelText(menu, text);


				for (new i = 1; i <= MaxClients; i++) {

					if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientHuman(i)) continue;
					//GetClientName(i, ClientName, sizeof(ClientName));
					Format(text, sizeof(text), "%s\n%N", text, i);
					//SQL_EscapeString(EscapeString, text, text, sizeof(text));
				}
				DrawPanelItem(menu, text);
			}
			Format(text, sizeof(text), "%T", "hide hud", client);
			DrawPanelItem(menu, text);
		}
	}

	return menu;
}

GetCurrentSurvivorCount(bool:bInfectedInstead = false) {
	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i)) continue;
		if (!bInfectedInstead && GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (bInfectedInstead && GetClientTeam(i) == TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

GetReadyPlayerCount() {
	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
		if (b_IsReady[i]) count++;
	}
	return count;
}

public ReadyUpMenu_Init(Handle:topmenu, MenuAction:action, client, param2) {

	if (action == MenuAction_Select) {

		switch(param2) {

			case 1: {

				if (b_IsAllClientsLoaded) {

					Cmd_ToggleReady(client);
					if (IsMajorityCounter()) {

						if (Match_Countdown == INVALID_HANDLE) Match_Countdown = CreateTimer(1.0, Timer_Match_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}
					//Now_CheckForReadyUpEnd();
				}
				SendPanelToClientAndClose(ReadyUpMenu(client), client, ReadyUpMenu_Init, 1);
			}
			case 2: {

				if (b_IsHideHud[client]) b_IsHideHud[client]	= false;
				else b_IsHideHud[client]						= true;

				SendPanelToClientAndClose(ReadyUpMenu(client), client, ReadyUpMenu_Init, 1);
			}
			default: {

				SendPanelToClientAndClose(ReadyUpMenu(client), client, ReadyUpMenu_Init, 1);
			}
		}
	}

	if (topmenu != INVALID_HANDLE) {

		CloseHandle(topmenu);
	}
}

// stock Now_CheckForReadyUpEnd() {

// 	if (b_IsReadyUp) {

// 		if (!b_ReadyUpOver && IsEligiblePlayersReady() && g_IsMatchStart != INVALID_HANDLE && !IsClientsLoading() || IsEligiblePlayersReady() && g_ForceReadyUpStartTimer == INVALID_HANDLE) {

// 			Now_OnReadyUpEnd();
// 		}
// 	}
// }

stock Now_DoorForcedOpen(const String:command[]) {

	new client												= FindClient();

	if (client > 0) {
	
		ForceCommand(client, command);
		Now_OpenSaferoomDoor();
		//CreateTimer(0.5, Timer_DeleteSaferoomDoor, _, TIMER_FLAG_NO_MAPCHANGE);
		//DeleteSaferoomDoors();
	}
}

stock ForceCommand(client, const String:command[])
{
	new iFlags = GetCommandFlags(command);
	SetCommandFlags(command,iFlags & ~FCVAR_CHEAT);

	FakeClientCommand(client,"%s",command);

	SetCommandFlags(command,iFlags);
	SetCommandFlags(command,iFlags|FCVAR_CHEAT);
}

stock FindClient() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && IsClientInGame(i)) return i;
	}
	
	return 0;
}

stock bool:IsClientActual(client) {
	if (client < 1 || client > MaxClients) return false;
	return true;
}

stock bool:IsClientHuman(client) {
	if (client > 0 && IsClientConnected(client) && IsClientActual(client) && !IsFakeClient(client)) return true;
	return false;
}

bool:IsCommonInfected(entity) {
	if (entity <= 0 || !IsValidEntity(entity)) return false;
	decl String:className[16];
	GetEntityClassname(entity, className, sizeof(className));
	return strcmp(className, "infected") == 0;
}

stock bool:IsLegitimateClient(client) {
	if (!IsClientActual(client) || !IsClientInGame(client)) return false;
	return true;
}

stock bool:AllSurvivorsInCheckpoint() {
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || !IsPlayerAlive(i)) continue;
		if (!survivorInCheckpoint[i]) return false;
	}
   /* Due to a bug with l4d2 pc, sometimes commons will spawn upside down in the ground of the checkpoint when survivors are inside.
	* Because of this, we want to kill all the common infected on the map when this happens.
	* Sometimes special infected are counted as survivors, which means the round won't end when the door closes and all survivors
	* are inside.
	*
	* Because of this, we also need to kill all special infected bots to end the map.
	* I contemplated not killing tanks, but that could be a problem.
	*/
	// for (new i = 1; i <= MaxClients; i++) {
	// 	if (!IsLegitimateClient(i) || !IsFakeClient(i) || IsSurvivorBot(i)) continue;
	// 	ForcePlayerSuicide(i);
	// }
	// for (new i = MaxClients + 1; i < 2048; i++) {
	// 	if (!IsCommonInfected(i)) continue;
	// 	AcceptEntityInput(i, "Kill");
	// }
	return true;
}

stock ForceServerCommand(const String:command[]) {
	
	new iFlags = GetCommandFlags(command);
	SetCommandFlags(command, iFlags & ~(FCVAR_CHEAT|FCVAR_LAUNCHER));
	ServerCommand("%s", command);
	ServerExecute();
	SetCommandFlags(command, iFlags);
	SetCommandFlags(command, iFlags | FCVAR_CHEAT);
}

stock bool:IsClientInCheckpoint(client) {
	new Float:endCheckpointPos[3];
	if (EndOfMapDoor == -1) return false;
	GetEntPropVector(EndOfMapDoor, Prop_Send, "m_vecOrigin", endCheckpointPos);
	new Float:clientPos[3];
	GetClientAbsOrigin(client, clientPos);
	if (GetVectorDistance(clientPos, endCheckpointPos) <= 128.0) return true;
	return false;
}

public Action:Event_PlayerEnteredCheckpoint(Handle:event, String:event_name[], bool:dontBroadcast) {
	if (!b_IsRoundOver && b_IsSaferoomDoorOpened) {
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsClientActual(client) || !IsClientInGame(client) || IsValidZombieClass(client)) return;
		if (!survivorInCheckpoint[client]) {
			if (AllSurvivorsInCheckpoint()) UnlockEndOfMapCheckpointDoor(true);
			else UnlockEndOfMapCheckpointDoor();
			if (IsClientInCheckpoint(client)) {
				survivorInCheckpoint[client] = true;
				Call_StartForward(g_SurvivorEnteredCheckpoint);
				Call_PushCell(client);
				Call_Finish();
			}
		}
	}
}

public Action:Event_PlayerDeath(Handle:event, String:event_name[], bool:dontBroadcast) {
	if (!b_IsRoundOver && b_IsSaferoomDoorOpened) {
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsClientActual(client) || !IsClientInGame(client) || IsValidZombieClass(client)) return;
		if (AllSurvivorsInCheckpoint()) UnlockEndOfMapCheckpointDoor(true);
		else UnlockEndOfMapCheckpointDoor();
	}
}

// we need to check the zombie class since the way I create special infected, they have the same team as survivors.
bool:IsValidZombieClass(client) {	// 9 for survivor
	new zombieclass = GetEntProp(client, Prop_Send, "m_zombieClass");
	if (zombieclass >= 1 && zombieclass <= 8) return true;
	return false;
}

public Action:Event_PlayerLeftCheckpoint(Handle:event, String:event_name[], bool:dontBroadcast) {
	if (!b_IsRoundOver && b_IsSaferoomDoorOpened) {
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsClientActual(client) || !IsClientInGame(client) || IsValidZombieClass(client) || !IsPlayerAlive(client)) return;
		if (survivorInCheckpoint[client] && EndOfMapDoor != -1) {
			//PrintToChatAll("%N (%d) left the checkpoint.", client, GetEntProp(client, Prop_Send, "m_zombieClass"));
			// new Float:survPos[3];
			// GetClientAbsOrigin(client, survPos);
			// if (GetVectorDistance(survPos, endPos) > 64.0) {
			survivorInCheckpoint[client] = false;
			UnlockEndOfMapCheckpointDoor();
		}
	}
}

stock DeleteSaferoomDoors() {
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
		AcceptEntityInput(ent, "Kill");
	}
}

stock UnlockEndOfMapCheckpointDoor(bool:unlockDoor = false) {
	//if (Survivors() < 1) return;
	if (EndOfMapDoor == -1) {
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
			if (ent == SaferoomDoor) continue;
			if (GetEntProp(ent, Prop_Send, "m_eDoorState") == CHECKPOINT_DOOR_OPENED) {	// the end of map door is the only checkpoint door that is open.
				EndOfMapDoor = ent;
				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", endPos);
				if (DeleteTheDoors >= 3) DispatchKeyValue(EndOfMapDoor, "spawnflags", "32768");
				return;
			}
		}
	}
	else if (DeleteTheDoors >= 3 && EndOfMapDoor >= 0) {
		// If the end of map door exists.
		if (unlockDoor) {
			DispatchKeyValue(EndOfMapDoor, "spawnflags", "8192");
			// If set to 4, once the door unlocks, it never locks again.
			if (DeleteTheDoors == 4) EndOfMapDoor = -2;
		}
		else {
			DispatchKeyValue(EndOfMapDoor, "spawnflags", "32768");
		}
	}
	return;
}
stock ToggleSaferoomDoor(bool:UnlockDoor) {
	if (SaferoomDoor >= 0 && UnlockDoor) {
		DispatchKeyValue(SaferoomDoor, "spawnflags", "8192");
		return;
	}
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
		if (!IsValidEntity(ent)) continue;
		if (bool:GetEntData(ent, OFFSET_LOCKED, 1) && !UnlockDoor) {

			DispatchKeyValue(ent, "spawnflags", "32768");
			SaferoomDoor = ent;
			return;
		}
	}
	return;
}

stock FindEntityByClassnameEx(startEnt, const String:classname[]) {

	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

/*stock Now_UnlockSaferoomDoor() {

	if (SaferoomDoor >= 0 && IsValidEntity(SaferoomDoor)) {

		DispatchKeyValue(SaferoomDoor, "spawnflags", "8192");
	}
}*/

public Action:Timer_DeleteSaferoomDoor(Handle:timer) {
	if (!IsEligibleMap(0) && SaferoomDoor >= 0 && IsValidEntity(SaferoomDoor)) {
		//if (!AcceptEntityInput(SaferoomDoor, "Kill")) RemoveEdict(SaferoomDoor);
		AcceptEntityInput(SaferoomDoor, "Kill");
	}
	Call_StartForward(g_IsSaferoomDoorDestroyed);
	Call_Finish();
}

stock SendPanelToClientAndClose(Handle:panel, client, MenuHandler:handler, time) {

	SendPanelToClient(panel, client, handler, time);
	CloseHandle(panel);
}

stock ProcessConfigFile(const String:file[])
{
	if (!FileExists(file)) {
		
		SetFailState("File not found: %s", file);
	}
	if (!ParseConfigFile(file)) {

		SetFailState("File formatted incorrectly: %s", file);
	}
}

stock bool:ParseConfigFile(const String:file[])
{
	new Handle:hParser = SMC_CreateParser();
	new String:error[128];
	new line = 0;
	new col = 0;

	ClearArray(Handle:a_KeyConfig);
	ClearArray(Handle:a_ValueConfig);

	SMC_SetReaders(hParser, Config_NewSection, Config_KeyValue, Config_EndSection);
	SMC_SetParseEnd(hParser, Config_End);

	new SMCError:result = SMC_ParseFile(hParser, file, line, col);
	CloseHandle(hParser);

	if (result != SMCError_Okay)
	{
		SMC_GetErrorString(result, error, sizeof(error));
		LogToFile(s_Log, "Problem reading %s, line %d, col %d - error: %s", file, line, col, error);
	}

	Now_IsLoadConfigForward();

	return (result == SMCError_Okay);
}

public SMCResult:Config_NewSection(Handle:parser, const String:section[], bool:quotes)
{
	/*if (StrEqual(section, "campaign")) b_IsSurvivalConfig = false;
	else if (StrEqual(section, "survival")) b_IsSurvivalConfig = true;
	else if (StrEqual(section, "campaign description")) b_IsSurvivalDescription = false;
	else if (StrEqual(section, "survival description")) b_IsSurvivalDescription = true;*/

	strcopy(s_SectionConfig, sizeof(s_SectionConfig), section);

	if (StoreKeys == 1) KeyCount++;

	return SMCParse_Continue;
}

public SMCResult:Config_KeyValue(Handle:parser, const String:key[], const String:value[], bool:ley_quotes, bool:value_quotes)
{
	decl String:lower[64];

	// Parse Modules

	if (b_IsParseConfig) {

		PushArrayString(a_KeyConfig, key);
		PushArrayString(a_ValueConfig, value);
		PushArrayString(a_SectionConfig, s_SectionConfig);

		return SMCParse_Continue;
	}
	if (StrEqual(s_SectionConfig, "config")) {

		/*if (StrEqual(key, "header?")) {
		
			strcopy(s_rup, sizeof(s_rup), value);
			Format(s_rup, sizeof(s_rup), "\x04[\x03%s\x04] \x01", s_rup);
		}
		else {

			PushArrayString(a_ReadyUpKeys, key);
			PushArrayString(a_ReadyUpValues, value);
			PushArrayString(a_ReadyUpSection, s_SectionConfig);
		}*/

		if (StrEqual(key, "halftime warmup?")) i_IsReadyUpHalftime = StringToInt(value);
		else if (StrEqual(key, "skip readyup period?")) i_IsReadyUpIgnored = StringToInt(value);
		else if (StrEqual(key, "disable hud?")) i_IsHudDisabled = StringToInt(value);
		else if (StrEqual(key, "preround alltalk?")) i_IsWarmupAllTalk = StringToInt(value);
		else if (StrEqual(key, "freeze players?")) i_IsFreeze = StringToInt(value);
		else if (StrEqual(key, "show loading?")) i_IsDisplayLoading = StringToInt(value);
		else if (StrEqual(key, "periodic countdown?")) i_IsPeriodicCountdown = StringToInt(value);
		else if (StrEqual(key, "coop finale rounds?")) i_CoopMapRounds = StringToInt(value);
		else if (StrEqual(key, "ready up time?")) i_ReadyUpTime = StringToInt(value);
		else if (StrEqual(key, "first map ready up time?")) i_ReadyUpTimeFirst = StringToInt(value);
		else if (StrEqual(key, "survival game modes?")) Format(GamemodeSurvival, sizeof(GamemodeSurvival), "%s", value);
		else if (StrEqual(key, "coop game modes?")) Format(GamemodeCoop, sizeof(GamemodeCoop), "%s", value);
		else if (StrEqual(key, "versus game modes?")) Format(GamemodeVersus, sizeof(GamemodeVersus), "%s", value);
		else if (StrEqual(key, "scavenge game modes?")) Format(GamemodeScavenge, sizeof(GamemodeScavenge), "%s", value);
		else if (StrEqual(key, "connect message?")) i_IsConnectionMessage = StringToInt(value);
		else if (StrEqual(key, "load message?")) i_IsLoadedMessage = StringToInt(value);
		else if (StrEqual(key, "connection timeout delay?")) i_IsConnectionTimeout = StringToInt(value);
		else if (StrEqual(key, "force start door open delay?")) i_IsDoorForcedOpen = StringToInt(value);
		else if (StrEqual(key, "periodic countdown time?")) i_IsPeriodicTime = StringToInt(value);
		else if (StrEqual(key, "forcestart command?")) strcopy(s_Cmd_ForceStart, sizeof(s_Cmd_ForceStart), value);
		else if (StrEqual(key, "togglehud command?")) strcopy(s_Cmd_ToggleHud, sizeof(s_Cmd_ToggleHud), value);
		else if (StrEqual(key, "toggleready command?")) strcopy(s_Cmd_ToggleReady, sizeof(s_Cmd_ToggleReady), value);
		else if (StrEqual(key, "togglebots command?")) strcopy(s_Cmd_ToggleBots, sizeof(s_Cmd_ToggleBots), value);
		else if (StrEqual(key, "majority ready enabled?")) i_IsMajority = StringToInt(value);
		else if (StrEqual(key, "majority ready timer?")) i_IsMajorityTimer = StringToInt(value);
		else if (StrEqual(key, "force start maps?")) Format(ForceStartMaps, sizeof(ForceStartMaps), "%s", value);
		else if (StrEqual(key, "max survivors?")) iMaxSurvivorsAllowed = StringToInt(value);
		else if (StrEqual(key, "min survivors?")) iMinSurvivorsAllowed = StringToInt(value);
		else if (StrEqual(key, "force campaign?")) iForceCampaign = StringToInt(value);
		else if (StrEqual(key, "delete all doors?")) DeleteTheDoors = StringToInt(value);
		else if (StrEqual(key, "max survivor bots?")) iMaxSurvivorBotsAllowed = StringToInt(value);
		else if (StrEqual(key, "starting survivors?")) {

			iStartingSurvivors = StringToInt(value);
			if (iMinSurvivors < 1) iMinSurvivors = iStartingSurvivors;
		}
		else if (StrEqual(key, "bot toggle timer?")) iBotCountdownTime = StringToInt(value);
		else if (StrEqual(key, "bot vote advertisement?")) iBotIntervalTime = StringToInt(value);
		else if (StrEqual(key, "header?")) {
		
			strcopy(s_rup, sizeof(s_rup), value);
			Format(s_rup, sizeof(s_rup), "\x04[\x03%s\x04] \x01", s_rup);
		}
	}
	else {

		// Parse the maplist.cfg
	
		if (StrEqual(s_SectionConfig, "campaign")) {

			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_FirstMap, lower);

			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_FinalMap, lower);
		}
		else if (StrEqual(s_SectionConfig, "campaign description")) {

			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_CampaignMapDescriptionKey, lower);

			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_CampaignMapDescriptionValue, lower);
		}
		else if (StrEqual(s_SectionConfig, "survival")) {

			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_SurvivalMap, lower);

			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_SurvivalMapNext, lower);
		}
		else if (StrEqual(s_SectionConfig, "survival description")) {

			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_SurvivalMapDescriptionKey, lower);

			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_SurvivalMapDescriptionValue, lower);
		}
		
		/*if (!b_IsSurvivalConfig) {

			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_FirstMap, lower);

			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_FinalMap, lower);
		}
		else {

			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_SurvivalMap, lower);

			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_SurvivalMapNext, lower);
		}*/
	}

	return SMCParse_Continue;
}

stock LowerString(String:s[]) {

	for (new i = 0; i <= strlen(s); i++) {
		if (!IsCharLower(s[i])) s[i] = CharToLower(s[i]);
	}
}

public SMCResult:Config_EndSection(Handle:parser) 
{
	return SMCParse_Continue;
}

public Config_End(Handle:parser, bool:halted, bool:failed) 
{
	if (failed)
	{
		SetFailState("Plugin configuration error");
	}
}

#define NICK_MODEL				"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL			"models/survivors/survivor_producer.mdl"
#define COACH_MODEL				"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL				"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL				"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL			"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL				"models/survivors/survivor_manager.mdl"
#define BILL_MODEL				"models/survivors/survivor_namvet.mdl"

stock bool:IsSurvivorBot(client) {
	decl String:TheModel[64];
	GetClientModel(client, TheModel, sizeof(TheModel));	// helms deep creates bots that aren't necessarily on the survivor team.
	if (StrEqual(TheModel, NICK_MODEL) ||
		StrEqual(TheModel, ROCHELLE_MODEL) ||
		StrEqual(TheModel, COACH_MODEL) ||
		StrEqual(TheModel, ELLIS_MODEL) ||
		StrEqual(TheModel, ZOEY_MODEL) ||
		StrEqual(TheModel, FRANCIS_MODEL) ||
		StrEqual(TheModel, LOUIS_MODEL) ||
		StrEqual(TheModel, BILL_MODEL)) return true;
	return false;
}