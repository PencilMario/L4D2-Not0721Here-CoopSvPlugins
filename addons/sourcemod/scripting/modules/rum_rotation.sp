#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define MAX_ENTITIES		2048

#define PLUGIN_VERSION		"1.1"
#define PLUGIN_CONTACT		"github.com/exskye"

#define PLUGIN_NAME			"[RUM][Server Mgmt] Campaign Rotation"
#define PLUGIN_DESCRIPTION	"Campaign / Map rotation management"
#define CONFIG				"rotation.cfg"
#define CVAR_SHOW			FCVAR_NOTIFY

#include <sourcemod>
#include <sdktools>
#include "wrap.inc"
#undef REQUIRE_PLUGIN
#include "readyup.inc"
#include <l4d2_changelevel>

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_CONTACT,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_CONTACT,
};

int i_TimeDelay;
int i_Random;
int i_MaxAttempts;
int i_MaxSurvivalRounds;

int i_Ignore;
int i_Attempts;
int i_Rounds;

char s_rup[32];
char NextMap[PLATFORM_MAX_PATH];

Handle a_MapList1;
Handle a_MapList2;

int gametype;

public OnPluginStart() {
	CreateConVar("rum_rotation", PLUGIN_VERSION, "version header", CVAR_SHOW);
	SetConVarString(FindConVar("rum_rotation"), PLUGIN_VERSION);
	LoadTranslations("common.phrases");
	LoadTranslations("rum_rotation.phrases");
	a_MapList1 = CreateArray(64);
	a_MapList2 = CreateArray(64);
}

public ReadyUp_FwdCallModule(char[] nameConfig, char[] nameCommand, int value) {
	if (StrEqual(nameConfig, CONFIG) && StrEqual(nameCommand, "ignore rotation")) {
		i_Ignore								= value;
	}
}

public OnConfigsExecuted() {
	i_Attempts = 0;
	i_Rounds = 0;
	CreateTimer(0.1, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ExecuteConfig(Handle timer) {
	if (ReadyUp_NtvConfigProcessing() == 0) {
		ReadyUp_ParseConfig(CONFIG);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public ReadyUp_ParseConfigFailed(char[] config, char[] error) {
	if (StrEqual(config, CONFIG)) {
		SetFailState("%s , %s", config, error);
	}
}

public ReadyUp_LoadFromConfig(Handle key, Handle value) {
	char s_key[32];
	char s_value[32];
	int a_Size						= GetArraySize(key);
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(key, i, s_key, sizeof(s_key));
		GetArrayString(value, i, s_value, sizeof(s_value));
		if (StrEqual(s_key, "delay before map change?")) i_TimeDelay				= StringToInt(s_value);
		else if (StrEqual(s_key, "next map is random?")) i_Random					= StringToInt(s_value);
		else if (StrEqual(s_key, "maximum finale fails?")) i_MaxAttempts			= StringToInt(s_value);
		else if (StrEqual(s_key, "survival rounds played?")) i_MaxSurvivalRounds	= StringToInt(s_value);
	}
	ReadyUp_NtvGetHeader();
	i_Ignore = 0;	// Changes to 1 on campaign finales / start of survival maps if a vote map modules issues the order.
}

public ReadyUp_FwdGetHeader(const char[] header) {
	strcopy(s_rup, sizeof(s_rup), header);
}

public ReadyUp_ReadyUpStart() {
	gametype = ReadyUp_GetGameMode();
}

public ReadyUp_FirstClientLoaded() {
	i_Attempts										= 0;
	ReadyUp_NtvGetMapList();
}

public ReadyUp_FwdGetMapList(Handle MapList1, Handle MapList2) {
	ClearArray(a_MapList1);
	ClearArray(a_MapList2);
	int a_Size = GetArraySize(MapList1);
	char a_Map[128];
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(MapList1, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList1, a_Map);
		GetArrayString(MapList2, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList2, a_Map);
	}
}

public ReadyUp_CampaignComplete() {
	if (gametype == 1) Now_CheckIfChangeMaps();	// don't need IsChangeMaps since this only fires if a campaign finale is won.
}

public ReadyUp_RoundIsOver() {
	if (gametype >= 2) {
		i_Rounds++;
		if (gametype == 2 && i_Rounds >= 2 && IsChangeMap() || gametype == 3 && i_Rounds >= i_MaxSurvivalRounds) Now_CheckIfChangeMaps();
	}
}

public ReadyUp_CoopMapFailed() {
	if (gametype != 2) {
		// Is not a versus round!
		if (gametype == 1 && IsChangeMap() || gametype == 3) i_Attempts++;		// only check IsChangeMap() if a coop game.
		if (i_Attempts >= i_MaxAttempts) {
			Now_CheckIfChangeMaps();
		}
	}
}

stock Now_CheckIfChangeMaps() {
	if (i_Ignore == 1) return;	// Another module is handling rotations.
	Now_GetNextMap(NextMap, sizeof(NextMap));
	i_Attempts	= 0;
	i_Rounds	= 0;
	PrintToChatAll("%t", "next map in rotation", s_rup, NextMap);
	CreateTimer(i_TimeDelay * 1.0, Timer_ChangeMap, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ChangeMap(Handle timer) {
	if (i_Ignore == 0) {
		L4D2_ChangeLevel(NextMap, (gametype == 2) ? true : false);
	}
	return Plugin_Stop;
}

void Now_GetNextMap(char[] nextMapInRotation, int size) {
	char mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	LowerString(mapname);	// fucking linux case-sensitivity;;not really, i love linux. RED HAT FOREVER!!!
	char a_mapname[128];
	int a_Size = GetArraySize(a_MapList2);
	if (i_Random == 1) {
		int random = GetRandomInt(0, a_Size - 1);
		GetArrayString(a_MapList1, random, a_mapname, sizeof(a_mapname));
		LowerString(a_mapname);
		Format(nextMapInRotation, size, "%s", a_mapname);
		return;
	}
	for (int i = 0; i < a_Size; i++) {
		if (gametype != 3) GetArrayString(a_MapList2, i, a_mapname, sizeof(a_mapname));
		else GetArrayString(a_MapList1, i, a_mapname, sizeof(a_mapname));
		LowerString(a_mapname);
		if (!StrEqual(mapname, a_mapname)) continue;
		if (i + 1 < a_Size) {
			if (gametype != 3) GetArrayString(a_MapList1, i + 1, a_mapname, sizeof(a_mapname));
			else GetArrayString(a_MapList2, i + 1, a_mapname, sizeof(a_mapname));
			LowerString(a_mapname);
			Format(nextMapInRotation, size, "%s", a_mapname);
			return;
		}
		break;
	}

	if (gametype != 3) GetArrayString(a_MapList1, 0, a_mapname, sizeof(a_mapname));
	else GetArrayString(a_MapList2, 0, a_mapname, sizeof(a_mapname));
	LowerString(a_mapname);
	Format(nextMapInRotation, size, "%s", a_mapname);
}

bool IsChangeMap() {
	char mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	LowerString(mapname);
	char a_mapname[128];
	int a_Size = GetArraySize(a_MapList2);
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_MapList2, i, a_mapname, sizeof(a_mapname));
		LowerString(a_mapname);
		if (StrEqual(mapname, a_mapname)) return true;
	}
	return false;
}

void LowerString(char[] s) {
	for (int i = 0; i <= strlen(s); i++) {
		if (!IsCharLower(s[i])) s[i] = CharToLower(s[i]);
	}
}