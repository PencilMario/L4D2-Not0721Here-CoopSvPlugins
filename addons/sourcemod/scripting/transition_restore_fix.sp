#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <dhooks>
#include <sourcescramble>

#define PLUGIN_VERSION		"1.2.5"

#define DEBUG 0

#define GAMEDATA	"transition_restore_fix"

Handle
	g_hSDK_KeyValues_GetString,
	g_hSDK_KeyValues_SetString,
	g_hSDK_CDirector_IsInTransition;

#if DEBUG
Handle
	g_hSDK_CTerrorPlayer_TransitionRestore;
#endif

ConVar
	g_hKeepIdentity,
	g_hPrecacheAllSur,
	g_cChooseBotData;

ArrayList
	g_aBotData;

Address
	g_pThis,
	g_pData,
	g_pDirector,
	g_pSavedPlayersCount,
	g_pSavedSurvivorBotsCount,
	g_pSavedLevelRestartSurvivorBotsCount;

MemoryPatch
	g_mpRestoreByUserId;

DynamicDetour
	g_ddCDirector_Restart;

bool
	g_bOnRestart,
	g_bChooseBotData;

#if DEBUG
int
	g_iOff_m_isTransitioned;
#endif

enum struct PlayerSaveData
{
	char ModelName[PLATFORM_MAX_PATH];
	char character[4];
}

PlayerSaveData
	g_eSavedData;

public Plugin myinfo =
{
	name = "Transition Restore Fix",
	author = "sorallll",
	description = "Restoring transition data by player's UserId instead of character",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=336287"
};

public void OnPluginStart()
{
	vInitGameData();
	g_aBotData = new ArrayList();

	CreateConVar("transition_restore_fix_version", PLUGIN_VERSION, "Transition Restore Fix plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hKeepIdentity = CreateConVar("restart_keep_identity", "1", "Whether to keep the current character and model after the mission lost and restarts? (0=restore to pre-transition identity, 1=game default)", FCVAR_NOTIFY);
	g_cChooseBotData = CreateConVar("choose_bot_data", "0", "Which field selects bot data after restart? 0=model name, 1=survivor character.", FCVAR_NOTIFY);
	g_hPrecacheAllSur = FindConVar("precache_all_survivors");

	g_hKeepIdentity.AddChangeHook(vConVarChanged);
	g_cChooseBotData.AddChangeHook(vChooseBotDataChanged);

	AutoExecConfig(true, "transition_restore_fix");

	#if DEBUG
	RegAdminCmd("sm_restore", cmdRestore, ADMFLAG_ROOT);
	#endif
}

public void OnPluginEnd()
{
	if (g_pThis)
		StoreToAddress(g_pThis, g_pData, NumberType_Int32);
}

#if DEBUG
Action cmdRestore(int client, int args)
{
	if (!client || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2)
		return Plugin_Handled;

	SetEntData(client, g_iOff_m_isTransitioned, 1);
	SDKCall(g_hSDK_CTerrorPlayer_TransitionRestore, client);
	return Plugin_Handled;
}
#endif

public void OnConfigsExecuted()
{
	g_bChooseBotData = g_cChooseBotData.BoolValue;
	vToggleDetours(g_hKeepIdentity.BoolValue);
}

void vConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	vToggleDetours(g_hKeepIdentity.BoolValue);
}

void vChooseBotDataChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bChooseBotData = g_cChooseBotData.BoolValue;
}

void vToggleDetours(bool bToggle)
{
	static bool bToggled;
	if (!bToggled && bToggle) {
		bToggled = true;

		if (!g_ddCDirector_Restart.Enable(Hook_Pre, DD_CDirector_Restart_Pre))
			SetFailState("Failed to detour pre: \"DD::CDirector::Restart\"");
		
		if (!g_ddCDirector_Restart.Enable(Hook_Post, DD_CDirector_Restart_Post))
			SetFailState("Failed to detour post: \"DD::CDirector::Restart\"");
	}
	else if (bToggled && !bToggle) {
		bToggled = false;

		if (!g_ddCDirector_Restart.Disable(Hook_Pre, DD_CDirector_Restart_Pre))
			SetFailState("Failed to disable detour pre: \"DD::CDirector::Restart\"");

		if (!g_ddCDirector_Restart.Disable(Hook_Post, DD_CDirector_Restart_Post))
			SetFailState("Failed to disable detour post: \"DD::CDirector::Restart\"");
	}
}

public void OnMapStart()
{
	g_hPrecacheAllSur.SetInt(1);
}

void vInitGameData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/%s.txt", GAMEDATA);
	if (!FileExists(sPath))
		SetFailState("\n==========\nMissing required file: \"%s\".\n==========", sPath);

	GameData hGameData = new GameData(GAMEDATA);
	if (!hGameData)
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	g_pDirector = hGameData.GetAddress("CDirector");
	if (!g_pDirector)
		SetFailState("Failed to find address: \"CDirector\"");

	g_pSavedPlayersCount = hGameData.GetAddress("SavedPlayersCount");
	if (!g_pSavedPlayersCount)
		SetFailState("Failed to find address: \"SavedPlayersCount\"");

	g_pSavedSurvivorBotsCount = hGameData.GetAddress("SavedSurvivorBotsCount");
	if (!g_pSavedSurvivorBotsCount)
		SetFailState("Failed to find address: \"SavedSurvivorBotsCount\"");

	g_pSavedLevelRestartSurvivorBotsCount = hGameData.GetAddress("SavedLevelRestartSurvivorBotsCount");
	if (!g_pSavedLevelRestartSurvivorBotsCount)
		SetFailState("Failed to find address: \"SavedLevelRestartSurvivorBotsCount\"");

	StartPrepSDKCall(SDKCall_Raw);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "KeyValues::GetString"))
		SetFailState("Failed to find signature: \"KeyValues::GetString\"");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	if (!(g_hSDK_KeyValues_GetString = EndPrepSDKCall()))
		SetFailState("Failed to create SDKCall: \"KeyValues::GetString\"");

	StartPrepSDKCall(SDKCall_Raw);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "KeyValues::SetString"))
		SetFailState("Failed to find signature: \"KeyValues::SetString\"");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if (!(g_hSDK_KeyValues_SetString = EndPrepSDKCall()))
		SetFailState("Failed to create SDKCall: \"KeyValues::SetString\"");

	StartPrepSDKCall(SDKCall_Raw);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CDirector::IsInTransition"))
		SetFailState("Failed to find signature: \"CDirector::IsInTransition\"");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if (!(g_hSDK_CDirector_IsInTransition = EndPrepSDKCall()))
		SetFailState("Failed to create SDKCall: \"CDirector::IsInTransition\"");

	#if DEBUG
	g_iOff_m_isTransitioned = hGameData.GetOffset("CTerrorPlayer::IsTransitioned::m_isTransitioned");
	if (g_iOff_m_isTransitioned == -1)
		SetFailState("Failed to find offset: \"CTerrorPlayer::IsTransitioned::m_isTransitioned\"");

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::TransitionRestore"))
		SetFailState("Failed to find signature: \"CTerrorPlayer::TransitionRestore\"");
	if (!(g_hSDK_CTerrorPlayer_TransitionRestore = EndPrepSDKCall()))
		SetFailState("Failed to create SDKCall: \"CTerrorPlayer::TransitionRestore\"");
	#endif

	vInitPatchs(hGameData);
	vSetupDetours(hGameData);

	delete hGameData;
}

void vInitPatchs(GameData hGameData = null)
{
	g_mpRestoreByUserId = MemoryPatch.CreateFromConf(hGameData, "CTerrorPlayer::TransitionRestore::RestoreByUserId");
	if (!g_mpRestoreByUserId.Validate())
		SetFailState("Failed to verify patch: \"CTerrorPlayer::TransitionRestore::RestoreByUserId\"");

	MemoryPatch patch = MemoryPatch.CreateFromConf(hGameData, "RestoreTransitionedSurvivorBots::MaxRestoreSurvivorBots");
	if (!patch.Validate())
		SetFailState("Failed to verify patch: \"RestoreTransitionedSurvivorBots::MaxRestoreSurvivorBots\"");
	else if (patch.Enable()) {
		StoreToAddress(patch.Address + view_as<Address>(2), hGameData.GetOffset("OS") ? MaxClients : MaxClients + 1, NumberType_Int8);
		PrintToServer("[%s] Enabled patch: \"RestoreTransitionedSurvivorBots::MaxRestoreSurvivorBots\"", GAMEDATA);
	}
}

void vSetupDetours(GameData hGameData = null)
{
	g_ddCDirector_Restart = DynamicDetour.FromConf(hGameData, "DD::CDirector::Restart");
	if (!g_ddCDirector_Restart)
		SetFailState("Failed to create DynamicDetour: \"DD::CDirector::Restart\"");

	DynamicDetour dDetour = DynamicDetour.FromConf(hGameData, "DD::CTerrorPlayer::TransitionRestore");
	if (!dDetour)
		SetFailState("Failed to create DynamicDetour: \"DD::CTerrorPlayer::TransitionRestore\"");

	if (!dDetour.Enable(Hook_Pre, DD_CTerrorPlayer_TransitionRestore_Pre))
		SetFailState("Failed to detour pre: \"DD::CTerrorPlayer::TransitionRestore\"");

	if (!dDetour.Enable(Hook_Post, DD_CTerrorPlayer_TransitionRestore_Post))
		SetFailState("Failed to detour post: \"DD::CTerrorPlayer::TransitionRestore\"");

	dDetour = DynamicDetour.FromConf(hGameData, "DD::PlayerSaveData::Restore");
	if (!dDetour)
		SetFailState("Failed to create DynamicDetour: \"DD::PlayerSaveData::Restore\"");

	if (!dDetour.Enable(Hook_Pre, DD_PlayerSaveData_Restore_Pre))
		SetFailState("Failed to detour pre: \"DD::PlayerSaveData::Restore\"");

	if (!dDetour.Enable(Hook_Post, DD_PlayerSaveData_Restore_Post))
		SetFailState("Failed to detour post: \"DD::PlayerSaveData::Restore\"");

	dDetour = DynamicDetour.FromConf(hGameData, "DD::CDirector::IsHumanSpectatorValid");
	if (!dDetour)
		SetFailState("Failed to create DynamicDetour: \"DD::CDirector::IsHumanSpectatorValid\"");

	if (!dDetour.Enable(Hook_Pre, DD_CDirector_IsHumanSpectatorValid_Pre))
		SetFailState("Failed to detour pre: \"DD::CDirector::IsHumanSpectatorValid\"");

	dDetour = DynamicDetour.FromConf(hGameData, "DD::CDirectorSessionManager::FillRemainingSurvivorTeamSlotsWithBots");
	if (!dDetour)
		SetFailState("Failed to create DynamicDetour: \"DD::CDirectorSessionManager::FillRemainingSurvivorTeamSlotsWithBots\"");

	if (!dDetour.Enable(Hook_Pre, DD_CDSManager_FillRemainingSurvivorTeamSlotsWithBots_Pre))
		SetFailState("Failed to detour pre: \"DD::CDirectorSessionManager::FillRemainingSurvivorTeamSlotsWithBots\"");
}

MRESReturn DD_CDirector_Restart_Pre(Address pThis, DHookReturn hReturn)
{
	g_aBotData.Clear();
	g_bOnRestart = true;
	return MRES_Ignored;
}

MRESReturn DD_CDirector_Restart_Post(Address pThis, DHookReturn hReturn)
{
	g_bOnRestart = false;
	return MRES_Ignored;
}

MRESReturn DD_CTerrorPlayer_TransitionRestore_Pre(int pThis, DHookReturn hReturn)
{
	if (IsFakeClient(pThis) || GetClientTeam(pThis) > 2)
		return MRES_Ignored;

	Address pData = pFindSavedDataByUserId(GetClientUserId(pThis));
	if (!pData)
		return MRES_Ignored;

	char value[4];
	SDKCall(g_hSDK_KeyValues_GetString, pData, value, sizeof value, "teamNumber", "0");
	if (StringToInt(value) != 2)
		return MRES_Ignored;

	char ModelName[PLATFORM_MAX_PATH];
	SDKCall(g_hSDK_KeyValues_GetString, pData, ModelName, sizeof ModelName, "ModelName", "");
	if (ModelName[0] && !IsModelPrecached(ModelName))
		PrecacheModel(ModelName, true);

	g_mpRestoreByUserId.Enable();
	return MRES_Ignored;
}

MRESReturn DD_CTerrorPlayer_TransitionRestore_Post(int pThis, DHookReturn hReturn)
{
	g_mpRestoreByUserId.Disable();
	return MRES_Ignored;
}

MRESReturn DD_PlayerSaveData_Restore_Pre(Address pThis, DHookParam hParams)
{
	if (!g_bOnRestart)
		return MRES_Ignored;

	int player = hParams.Get(1);
	if (player <= 0 || player > MaxClients || !IsClientInGame(player) || GetClientTeam(player) != 2)
		return MRES_Ignored;

	Address pData;
	char ModelName[128];
	int m_survivorCharacter = GetEntProp(player, Prop_Send, "m_survivorCharacter");
	bool bFakeClient = IsFakeClient(player);
	if (bFakeClient || !pFindSavedDataByUserId(GetClientUserId(player))) {
		GetClientModel(player, ModelName, sizeof ModelName);
		pData = !g_bChooseBotData ? FindBotDataByModelName(ModelName) : FindBotDataByCharacter(m_survivorCharacter);
		if (pData) {
			g_pThis = pThis;
			g_pData = LoadFromAddress(pThis, NumberType_Int32);
			StoreToAddress(pThis, pData, NumberType_Int32);
		}
	}

	if (!pData) {
		pData = LoadFromAddress(pThis, NumberType_Int32);

		char value[4];
		SDKCall(g_hSDK_KeyValues_GetString, pData, value, sizeof value, "teamNumber", "0");
		if (StringToInt(value) != 2)
			return MRES_Ignored;

		if (bFakeClient && g_aBotData.FindValue(pData) == -1)
			g_aBotData.Push(pData);
	}

	char character[4];
	SDKCall(g_hSDK_KeyValues_GetString, pData, ModelName, sizeof ModelName, "ModelName", "");
	SDKCall(g_hSDK_KeyValues_GetString, pData, character, sizeof character, "character", "0");
	strcopy(g_eSavedData.ModelName, sizeof PlayerSaveData::ModelName, ModelName);
	strcopy(g_eSavedData.character, sizeof PlayerSaveData::character, character);

	GetClientModel(player, ModelName, sizeof ModelName);
	SDKCall(g_hSDK_KeyValues_SetString, pData, "ModelName", ModelName);

	IntToString(m_survivorCharacter, character, sizeof character);
	SDKCall(g_hSDK_KeyValues_SetString, pData, "character", character);

	return MRES_Ignored;
}

MRESReturn DD_PlayerSaveData_Restore_Post(Address pThis, DHookParam hParams)
{
	if (!g_bOnRestart)
		return MRES_Ignored;

	if (g_eSavedData.character[0]) {
		Address pData = LoadFromAddress(pThis, NumberType_Int32);
		if (pData) {
			SDKCall(g_hSDK_KeyValues_SetString, pData, "ModelName", g_eSavedData.ModelName);
			SDKCall(g_hSDK_KeyValues_SetString, pData, "character", g_eSavedData.character);
		}

		g_eSavedData.ModelName[0] = '\0';
		g_eSavedData.character[0] = '\0';
	}

	if (g_pThis)
		StoreToAddress(g_pThis, g_pData, NumberType_Int32);

	g_pThis = Address_Null;
	g_pData = Address_Null;
	return MRES_Ignored;
}

/**
* Prevents players joining the game during transition from taking over the Survivor Bot of transitioning players
**/
MRESReturn DD_CDirector_IsHumanSpectatorValid_Pre(Address pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (!GetClientOfUserId(GetEntProp(hParams.Get(1), Prop_Send, "m_humanSpectatorUserID")))
		return MRES_Ignored;

	hReturn.Value = 1;
	return MRES_Supercede;
}

/**
* Prevent CDirectorSessionManager::FillRemainingSurvivorTeamSlotsWithBots from triggering before RestoreTransitionedSurvivorBots(void) during transition
**/
MRESReturn DD_CDSManager_FillRemainingSurvivorTeamSlotsWithBots_Pre(Address pThis, DHookReturn hReturn)
{
	if (!SDKCall(g_hSDK_CDirector_IsInTransition, g_pDirector))
		return MRES_Ignored;

	if (!LoadFromAddress(g_pSavedSurvivorBotsCount, NumberType_Int32))
		return MRES_Ignored;

	hReturn.Value = 0;
	return MRES_Supercede;
}

// 读取玩家过关时保存的userID
Address pFindSavedDataByUserId(int userid)
{
	int iSavedPlayerCount = LoadFromAddress(g_pSavedPlayersCount, NumberType_Int32);
	if (!iSavedPlayerCount)
		return Address_Null;

	Address pSavedPlayers = view_as<Address>(LoadFromAddress(g_pSavedPlayersCount + view_as<Address>(4), NumberType_Int32));
	if (!pSavedPlayers)
		return Address_Null;

	Address pThis;
	char userID[12];
	for (int i; i < iSavedPlayerCount; i++) {
		pThis = view_as<Address>(LoadFromAddress(pSavedPlayers + view_as<Address>(4 * i), NumberType_Int32));
		if (!pThis)
			continue;

		SDKCall(g_hSDK_KeyValues_GetString, pThis, userID, sizeof userID, "userID", "0");
		if (StringToInt(userID) == userid)
			return pThis;
	}

	return Address_Null;
}

// Consume only an unused survivor save record with a matching model name.
// If there is no exact match, the game's original record remains selected.
Address FindBotDataByModelName(const char[] model)
{
	int count = LoadFromAddress(g_pSavedLevelRestartSurvivorBotsCount, NumberType_Int32);
	if (!count)
		return Address_Null;

	Address kv = view_as<Address>(LoadFromAddress(g_pSavedLevelRestartSurvivorBotsCount + view_as<Address>(4), NumberType_Int32));
	if (!kv)
		return Address_Null;

	Address ptr;
	char value[128];
	for (int i; i < count; i++) {
		ptr = view_as<Address>(LoadFromAddress(kv + view_as<Address>(4 * i), NumberType_Int32));
		if (!ptr)
			continue;
		if (g_aBotData.FindValue(ptr) != -1)
			continue;

		SDKCall(g_hSDK_KeyValues_GetString, ptr, value, sizeof value, "teamNumber", "0");
		if (StringToInt(value) != 2)
			continue;

		SDKCall(g_hSDK_KeyValues_GetString, ptr, value, sizeof value, "ModelName", "");
		if (strcmp(value, model, false) != 0)
			continue;

		g_aBotData.Push(ptr);
		return ptr;
	}

	return Address_Null;
}

// Consume only an unused survivor save record with a matching character index.
// If there is no exact match, the game's original record remains selected.
Address FindBotDataByCharacter(int character)
{
	int count = LoadFromAddress(g_pSavedLevelRestartSurvivorBotsCount, NumberType_Int32);
	if (!count)
		return Address_Null;

	Address kv = view_as<Address>(LoadFromAddress(g_pSavedLevelRestartSurvivorBotsCount + view_as<Address>(4), NumberType_Int32));
	if (!kv)
		return Address_Null;

	Address ptr;
	char value[128];
	for (int i; i < count; i++) {
		ptr = view_as<Address>(LoadFromAddress(kv + view_as<Address>(4 * i), NumberType_Int32));
		if (!ptr)
			continue;
		if (g_aBotData.FindValue(ptr) != -1)
			continue;

		SDKCall(g_hSDK_KeyValues_GetString, ptr, value, sizeof value, "teamNumber", "0");
		if (StringToInt(value) != 2)
			continue;

		SDKCall(g_hSDK_KeyValues_GetString, ptr, value, sizeof value, "character", "0");
		if (StringToInt(value) != character)
			continue;

		g_aBotData.Push(ptr);
		return ptr;
	}

	return Address_Null;
}
