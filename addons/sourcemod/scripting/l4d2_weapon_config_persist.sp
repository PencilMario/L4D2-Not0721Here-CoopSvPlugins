#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define PLUGIN_VERSION "1.0.0"
#define REPLAY_DELAY 2.0

ConVar g_hSavedConfig;
ConVar g_hSavedAmmoMulti;
Handle g_hReplayTimer = null;

public Plugin myinfo =
{
	name = "L4D2 Weapon Config Persist",
	author = "Not0721Here",
	description = "Persists voted weapon config across map changes.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	g_hSavedConfig = CreateConVar(
		"sm_weapon_config_persist_current",
		"",
		"Saved weapon config profile. Empty means use match default.",
		FCVAR_DONTRECORD | FCVAR_PROTECTED
	);
	g_hSavedAmmoMulti = CreateConVar(
		"sm_weapon_config_persist_ammo_multi",
		"",
		"Saved ammo multiplier. Empty means use match default.",
		FCVAR_DONTRECORD | FCVAR_PROTECTED
	);

	RegAdminCmd("sm_persist_weapon_config", Cmd_PersistWeaponConfig, ADMFLAG_CONFIG, "Save and apply weapon config: v1, v2, v3.");
	RegAdminCmd("sm_persist_ammo_multi", Cmd_PersistAmmoMulti, ADMFLAG_CONFIG, "Save and apply ammo multiplier.");
	RegAdminCmd("sm_clear_weapon_config", Cmd_ClearWeaponConfig, ADMFLAG_CONFIG, "Clear saved weapon config and ammo multiplier.");
	RegAdminCmd("sm_weapon_config_status", Cmd_WeaponConfigStatus, ADMFLAG_CONFIG, "Show saved weapon config and ammo multiplier.");
}

public void OnConfigsExecuted()
{
	char sConfig[16];
	char sAmmoMulti[16];
	g_hSavedConfig.GetString(sConfig, sizeof(sConfig));
	g_hSavedAmmoMulti.GetString(sAmmoMulti, sizeof(sAmmoMulti));

	if (sConfig[0] == '\0' && sAmmoMulti[0] == '\0') {
		return;
	}

	StartReplayTimer();
}

public void OnMapEnd()
{
	StopReplayTimer();
}

public Action Cmd_PersistWeaponConfig(int client, int args)
{
	if (args < 1) {
		ReplyToCommand(client, "[WeaponConfig] Usage: sm_persist_weapon_config <v1|v2|v3>");
		return Plugin_Handled;
	}

	char sConfig[16];
	GetCmdArg(1, sConfig, sizeof(sConfig));

	if (!IsValidWeaponConfig(sConfig)) {
		ReplyToCommand(client, "[WeaponConfig] Unknown weapon config '%s'. Use v1, v2, or v3.", sConfig);
		return Plugin_Handled;
	}

	g_hSavedConfig.SetString(sConfig);
	ApplyWeaponConfig(sConfig, true);

	return Plugin_Handled;
}

public Action Cmd_PersistAmmoMulti(int client, int args)
{
	if (args < 1) {
		ReplyToCommand(client, "[WeaponConfig] Usage: sm_persist_ammo_multi <multiplier>");
		return Plugin_Handled;
	}

	char sAmmoMulti[16];
	GetCmdArg(1, sAmmoMulti, sizeof(sAmmoMulti));

	if (!IsValidAmmoMulti(sAmmoMulti)) {
		ReplyToCommand(client, "[WeaponConfig] Invalid ammo multiplier '%s'. Use a value greater than 0.", sAmmoMulti);
		return Plugin_Handled;
	}

	g_hSavedAmmoMulti.SetString(sAmmoMulti);
	ApplyAmmoMulti(sAmmoMulti, true);

	return Plugin_Handled;
}

public Action Cmd_ClearWeaponConfig(int client, int args)
{
	g_hSavedConfig.SetString("");
	g_hSavedAmmoMulti.SetString("");
	StopReplayTimer();
	ReplyToCommand(client, "[WeaponConfig] Saved weapon config and ammo multiplier cleared. Match default will be used.");

	return Plugin_Handled;
}

public Action Cmd_WeaponConfigStatus(int client, int args)
{
	char sConfig[16];
	char sAmmoMulti[16];
	g_hSavedConfig.GetString(sConfig, sizeof(sConfig));
	g_hSavedAmmoMulti.GetString(sAmmoMulti, sizeof(sAmmoMulti));

	if (sConfig[0] == '\0') {
		ReplyToCommand(client, "[WeaponConfig] No saved weapon config. Match default is active.");
	} else {
		ReplyToCommand(client, "[WeaponConfig] Saved weapon config: %s", sConfig);
	}

	if (sAmmoMulti[0] == '\0') {
		ReplyToCommand(client, "[WeaponConfig] No saved ammo multiplier. Match default is active.");
	} else {
		ReplyToCommand(client, "[WeaponConfig] Saved ammo multiplier: %s", sAmmoMulti);
	}

	return Plugin_Handled;
}

public Action Timer_ReplayWeaponConfig(Handle timer)
{
	g_hReplayTimer = null;

	char sConfig[16];
	char sAmmoMulti[16];
	g_hSavedConfig.GetString(sConfig, sizeof(sConfig));
	g_hSavedAmmoMulti.GetString(sAmmoMulti, sizeof(sAmmoMulti));

	if (sConfig[0] != '\0' && IsValidWeaponConfig(sConfig)) {
		ApplyWeaponConfig(sConfig, false);
	}

	if (sAmmoMulti[0] != '\0' && IsValidAmmoMulti(sAmmoMulti)) {
		ApplyAmmoMulti(sAmmoMulti, false);
	}

	return Plugin_Stop;
}

void StartReplayTimer()
{
	StopReplayTimer();
	g_hReplayTimer = CreateTimer(REPLAY_DELAY, Timer_ReplayWeaponConfig);
}

void StopReplayTimer()
{
	if (g_hReplayTimer == null) {
		return;
	}

	KillTimer(g_hReplayTimer);
	g_hReplayTimer = null;
}

bool IsValidWeaponConfig(const char[] sConfig)
{
	return strcmp(sConfig, "v1", false) == 0
		|| strcmp(sConfig, "v2", false) == 0
		|| strcmp(sConfig, "v3", false) == 0;
}

bool IsValidAmmoMulti(const char[] sAmmoMulti)
{
	float fAmmoMulti = StringToFloat(sAmmoMulti);
	return fAmmoMulti > 0.0;
}

void ApplyWeaponConfig(const char[] sConfig, bool bAnnounce)
{
	char sPath[PLATFORM_MAX_PATH];

	if (!GetWeaponConfigPath(sConfig, sPath, sizeof(sPath))) {
		return;
	}

	ServerCommand("exec %s", sPath);

	if (bAnnounce) {
		PrintToServer("[WeaponConfig] Saved and applied weapon config %s (%s).", sConfig, sPath);
	} else {
		PrintToServer("[WeaponConfig] Replayed saved weapon config %s (%s).", sConfig, sPath);
	}
}

void ApplyAmmoMulti(const char[] sAmmoMulti, bool bAnnounce)
{
	ServerCommand("sm_setammomulti %s", sAmmoMulti);

	if (bAnnounce) {
		PrintToServer("[WeaponConfig] Saved and applied ammo multiplier %s.", sAmmoMulti);
	} else {
		PrintToServer("[WeaponConfig] Replayed saved ammo multiplier %s.", sAmmoMulti);
	}
}

bool GetWeaponConfigPath(const char[] sConfig, char[] sPath, int iMaxLength)
{
	if (strcmp(sConfig, "v1", false) == 0) {
		strcopy(sPath, iMaxLength, "cfgogl/coop_base/weapon_improve_v1.cfg");
		return true;
	}

	if (strcmp(sConfig, "v2", false) == 0) {
		strcopy(sPath, iMaxLength, "cfgogl/coop_base/weapon_improve_v2.cfg");
		return true;
	}

	if (strcmp(sConfig, "v3", false) == 0) {
		strcopy(sPath, iMaxLength, "cfgogl/coop_base/weapon_improve_v3.cfg");
		return true;
	}

	return false;
}
