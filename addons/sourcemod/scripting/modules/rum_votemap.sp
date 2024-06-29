#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3
#define MAX_ENTITIES		2048
#define PLUGIN_VERSION		"1.5"
#define PLUGIN_CONTACT		"github.com/exskye"
#define PLUGIN_NAME			"[RUM][Server Mgmt] Vote Map"
#define PLUGIN_DESCRIPTION	"Campaign / Map Voting"
#define CONFIG				"votemap.cfg"

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

int i_IsEnabled;
int i_VoteTimeAllotted;
int i_SurvivalRounds;
int i_FinaleAttempts;
int i_TimeDelay;

int i_Rounds;
int i_TimeRemaining;
int i_RestrictCount;
bool b_IsVoteComplete;

char i_HasVoted[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

char s_rup[32];
char NextMap[PLATFORM_MAX_PATH];

Handle a_MapList1;
Handle a_MapList2;
Handle a_MapListIdentifier;
Handle a_MapListDescription;
Handle a_MapListRestricted;

char white[4];
char green[4];
char blue[4];
char orange[4];

bool bHasRandomMapped = false;
bool b_IsCustomVote = false;

public OnPluginStart() {
	CreateConVar("rum_votemap", PLUGIN_VERSION, "version header");
	SetConVarString(FindConVar("rum_votemap"), PLUGIN_VERSION);
	LoadTranslations("common.phrases");
	LoadTranslations("rum_votemap.phrases");
	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");
	a_MapList1				= CreateArray(16);
	a_MapList2				= CreateArray(16);
	a_MapListIdentifier		= CreateArray(16);
	a_MapListDescription	= CreateArray(16);
	a_MapListRestricted		= CreateArray(16);
	RegConsoleCmd("votemap", CMD_VoteMap);
}

public Action CMD_VoteMap(client, args) {
	if (!b_IsVoteComplete && !b_IsCustomVote) {
		b_IsCustomVote = true;
		StartVotemap();
	}
	if (b_IsCustomVote || b_IsVoteComplete) BuildMenu(client);
	return Plugin_Handled;
}

void RestrictMap(char[] Mapname_a) {
	if (i_RestrictCount > 0) {
		int size = GetArraySize(a_MapListRestricted);
		char Mapname[64];
		for (new i = size - 2; i >= 0; i--) {
			GetArrayString(a_MapListRestricted, i, Mapname, sizeof(Mapname));
			SetArrayString(a_MapListRestricted, i + 1, Mapname);
		}
		// Now that we've shifted everything, let's set the new value to the first slot.
		SetArrayString(a_MapListRestricted, 0, Mapname_a);
	}
}

bool IsMapAllowed(char[] Mapname_a) {
	if (i_RestrictCount < 1) return true;
	int size = GetArraySize(a_MapListRestricted);
	char Mapname[64];
	for (new i = 0; i < size; i++) {
		GetArrayString(a_MapListRestricted, i, Mapname, sizeof(Mapname));
		if (StrEqual(Mapname, Mapname_a)) return false;
	}
	return true;
}

public ReadyUp_AllClientsLoaded() {
	if (bHasRandomMapped) Format(NextMap, sizeof(NextMap), "none");
	ReadyUp_NtvCallModule("rotation.cfg", "ignore rotation", 0);
	b_IsVoteComplete								= false;
	if (i_IsEnabled == 1 && IsChangeMap()) {
		StartVotemap();
	}
}

public ReadyUp_IsEmptyOnDisconnect() {
	if (bHasRandomMapped) bHasRandomMapped = false;
	OnFirstLoadRandomCampaign();
}

int VotesRequired() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || IsFakeClient(i)) continue;
		count++;
	}
	if (count > 1) count = (count / 2) + 1;
	return count;
}

void StartVotemap() {
	b_IsVoteComplete = true;
	i_TimeRemaining = i_VoteTimeAllotted;
	// We set the restricted maps list, here. Mapnames that show in it can't be voted on.
	if (GetArraySize(a_MapListRestricted) != i_RestrictCount) {
		ResizeArray(a_MapListRestricted, i_RestrictCount);
		int size = GetArraySize(a_MapListRestricted);
		for (int i = 0; i < size; i++) {
			SetArrayString(a_MapListRestricted, i, "none");
		}
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i)) continue;
		Format(i_HasVoted[i], sizeof(i_HasVoted[]), "none");
	}
	CreateTimer(1.0, Timer_VoteMap, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_VoteMap(Handle timer) {
	i_TimeRemaining--;
	if (i_TimeRemaining < 1) {
		i_TimeRemaining = -1;
		b_IsVoteComplete = false;
		Now_CalculateVotes();
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsClientHuman(i)) continue;
			CancelClientMenu(i, true);
		}
		return Plugin_Stop;
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientHuman(i) && GetClientMenu(i) == MenuSource_None) BuildMenu(i);
	}
	PrintHintTextToAll("%t", "Vote Time Remaining", i_TimeRemaining);
	return Plugin_Continue;
}

void BuildMenu(client) {
	Handle menu	= CreateMenu(BuildMenuHandle);
	char text[PLATFORM_MAX_PATH];
	char a_MapName[PLATFORM_MAX_PATH];
	FindMapDescription(i_HasVoted[client], text, sizeof(text));
	Format(text, sizeof(text), "%T", "Player Vote Display", client, text);
	SetMenuTitle(menu, text);
	int a_Size = GetArraySize(a_MapList1);
	int[] i_VoteCount = new int[a_Size];
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientHuman(i)) continue;
		if (GetMapVoted(i_HasVoted[i]) == -1) continue;
		i_VoteCount[GetMapVoted(i_HasVoted[i])]++;
	}
	int PlayersCount = GetHumanPlayers();
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_MapList1, i, a_MapName, sizeof(a_MapName));
		if (!IsMapAllowed(a_MapName)) continue;
		FindMapDescription(a_MapName, text, sizeof(text));
		Format(text, sizeof(text), "%s (%d / %d)", text, i_VoteCount[i], PlayersCount);
		AddMenuItem(menu, text, text);
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, 0);
}

void FindMapDescription(char[] Name, char[] storage, int sizeOfStorage) {
	char TargetName[PLATFORM_MAX_PATH];
	int a_Size = GetArraySize(a_MapListIdentifier);
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_MapListIdentifier, i, TargetName, sizeof(TargetName));
		if (!StrEqual(Name, TargetName)) continue;
		GetArrayString(Handle:a_MapListDescription, i, storage, sizeOfStorage);
		return;
	}
	Format(storage, sizeOfStorage, "%s", Name);
}

public BuildMenuHandle(Handle menu, MenuAction action, client, slot) {
	if (action == MenuAction_Select) {
		char a_MapName[PLATFORM_MAX_PATH];
		int pos = -1;
		int size = GetArraySize(a_MapList1);
		for (int i = 0; i < size; i++) {
			GetArrayString(a_MapList1, i, a_MapName, sizeof(a_MapName));
			if (!IsMapAllowed(a_MapName)) continue;
			pos++;
			if (pos == slot) break;
		}
		Format(i_HasVoted[client], sizeof(i_HasVoted[]), "%s", a_MapName);
		PrintToChat(client, "%T", "map vote submitted", client, white, green, i_HasVoted[client]);
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

int GetArraySizeEx(char[] SearchKey, char[] Delim = ":") {
	int count = 0;
	for (new i = 0; i <= strlen(SearchKey); i++) {
		if (StrContains(SearchKey[i], Delim, false) != -1) count++;
	}
	if (count == 0) return -1;
	return count + 1;
}

void Now_CalculateVotes() {
	int a_Size = GetArraySize(a_MapList1);
	if (a_Size < 1) return;
	int[] i_VoteCount = new int[a_Size];
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientHuman(i) || GetMapVoted(i_HasVoted[i]) == -1) continue;
		i_VoteCount[GetMapVoted(i_HasVoted[i])]++;
	}
	int pos = 0;
	char Tiebreaker[64];
	bool IsFirst = true;
	for (int i = 0; i < a_Size; i++) {
		if (i_VoteCount[i] > i_VoteCount[pos]) {
			pos	= i;
			Format(Tiebreaker, sizeof(Tiebreaker), "%d", pos);
			IsFirst = true;
		}
		else if (i_VoteCount[i] == i_VoteCount[pos]) {
			if (IsFirst) {
				IsFirst = false;
				Format(Tiebreaker, sizeof(Tiebreaker), "%d:%d", pos, i);
			}
			else {
				Format(Tiebreaker, sizeof(Tiebreaker), "%s:%d", Tiebreaker, i);	// saves the top score.
			}
		}
	}
	int tiesize = GetArraySizeEx(Tiebreaker);
	if (tiesize == -1) pos = StringToInt(Tiebreaker);
	else {
		// There was a tie somewhere.
		char[][] FindBest = new char[tiesize][5];
		ExplodeString(Tiebreaker, ":", FindBest, tiesize, 5);
		pos = GetRandomInt(0, tiesize-1);
		pos = StringToInt(FindBest[pos]);
	}
	if (i_VoteCount[pos] > 0) {
		for (int i = 0; i < a_Size; i++) {
			if (i == pos) continue;
			i_VoteCount[i]							= 0;
		}
		if (!b_IsCustomVote || i_VoteCount[pos] >= VotesRequired()) {
			ReadyUp_NtvCallModule("rotation.cfg", "ignore rotation", 1);
			GetArrayString(a_MapList1, pos, NextMap, sizeof(NextMap));
			RestrictMap(NextMap);	// Add it to the restricted list.
			if (b_IsCustomVote) {
				b_IsCustomVote = false;
				Now_CheckIfChangeMaps();
			}
			else {
				char text[64];
				FindMapDescription(NextMap, text, sizeof(text));
				PrintToChatAll("%t", "next map in rotation", s_rup, NextMap, text);
			}
		}
		i_VoteCount[pos] = 0;
	}
}

public ReadyUp_TrueDisconnect(client) {
	if (GetHumanPlayers(client) < 1) ChangeMapIfNoHumans();
}

void ChangeMapIfNoHumans() {
	LogMessage("No human players are in the server, forcing a new campaign.");
	// get the # of campaigns we can pick from
	int numOfCampaigns = GetArraySize(a_MapList1);
	// here we randomly grab one of the campaigns
	int randomCampaign = GetRandomInt(0, numOfCampaigns-1);
	// store the selected campaign in the NextMap string.
	GetArrayString(a_MapList1, randomCampaign, NextMap, sizeof(NextMap));
	// calls the change map method... will happen on a delay.
	Now_CheckIfChangeMaps();
}

int GetMapVoted(char[] s_MapName) {
	//new a_Size										= GetArraySize(a_MapList1);
	char a_Map[PLATFORM_MAX_PATH];
	char s_Map[PLATFORM_MAX_PATH];
	Format(s_Map, sizeof(s_Map), "%s", s_MapName);
	LowerString(s_Map);
	// Using GetArraySize inside of the loop, because the size seems to be shifting during this point, and it shouldn't be.
	int size = GetArraySize(a_MapList1);
	for (int i = 0; i < size; i++) {
		GetArrayString(a_MapList1, i, a_Map, sizeof(a_Map));
		LowerString(a_Map);
		if (StrEqual(a_Map, s_Map)) return i;
	}
	return -1;
}

public ReadyUp_IsClientLoaded(client) {
	Format(i_HasVoted[client], sizeof(i_HasVoted[]), "none");
}

public OnConfigsExecuted() {
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
	int a_Size = GetArraySize(key);
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(key, i, s_key, sizeof(s_key));
		GetArrayString(value, i, s_value, sizeof(s_value));
		if (StrEqual(s_key, "is voting enabled?")) i_IsEnabled					= StringToInt(s_value);
		else if (StrEqual(s_key, "time alloted for vote?")) i_VoteTimeAllotted	= StringToInt(s_value);
		else if (StrEqual(s_key, "survival rounds played?")) i_SurvivalRounds	= StringToInt(s_value);	// if not found, map rotation isn't present, and ends after 1 survival round. (unless another module uses this setting)
		else if (StrEqual(s_key, "maximum finale fails?")) i_FinaleAttempts		= StringToInt(s_value);
		else if (StrEqual(s_key, "delay before map change?")) i_TimeDelay		= StringToInt(s_value);
		else if (StrEqual(s_key, "restricted maps?")) i_RestrictCount			= StringToInt(s_value);
	}
	ReadyUp_NtvGetHeader();
	ReadyUp_NtvGetMapList();
}

public ReadyUp_FwdGetHeader(const char[] header) {
	strcopy(s_rup, sizeof(s_rup), header);
}

public ReadyUp_FwdGetMapList(Handle MapList1, Handle MapList2, Handle MapListIdentifier, Handle MapListDescription) {
	ClearArray(a_MapList1);
	ClearArray(a_MapList2);
	ClearArray(a_MapListIdentifier);
	ClearArray(a_MapListDescription);
	int a_Size = GetArraySize(MapList1);
	char a_Map[PLATFORM_MAX_PATH];
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(MapList1, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList1, a_Map);
		GetArrayString(MapList2, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList2, a_Map);
		GetArrayString(MapListIdentifier, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapListIdentifier, a_Map);
		GetArrayString(MapListDescription, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapListDescription, a_Map);
	}
	if (!bHasRandomMapped) OnFirstLoadRandomCampaign();
}

public ReadyUp_CampaignComplete() {
	int gametype = ReadyUp_GetGameMode();
	if (gametype == 1) Now_CheckIfChangeMaps();	// don't need IsChangeMaps since this only fires if a campaign finale is won.
}

public ReadyUp_RoundIsOver() {
	int gametype = ReadyUp_GetGameMode();
	if (gametype >= 2) {
		i_Rounds++;
		if (gametype == 2 && i_Rounds >= 2 && IsChangeMap() || gametype == 3 && i_Rounds >= i_SurvivalRounds) Now_CheckIfChangeMaps();
	}
}

public ReadyUp_CoopMapFailed(gamemode) {
	//new gametype										= ReadyUp_GetGameMode();
	if (gamemode == 1) {
		i_Rounds++;
		if (i_Rounds >= i_FinaleAttempts && IsChangeMap()) Now_CheckIfChangeMaps();
		else if (IsChangeMap()) PrintToChatAll("%t", "map fail tries", orange, i_Rounds, white, green, i_FinaleAttempts, white);
	}
}

void OnFirstLoadRandomCampaign() {
	if (bHasRandomMapped) return;
	bHasRandomMapped = true;	// starts false when the plugin first loads and never resets.
	int pos = GetRandomInt(0, GetArraySize(a_MapList1) - 1);
	GetArrayString(a_MapList1, pos, NextMap, sizeof(NextMap));
	//RestrictMap(NextMap);	// Add it to the restricted list.
	// Had to comment this out for now, it's bugging out at the start of the plugin load, so will need to investigate later.
	CreateTimer(5.0, Timer_ChangeMap);	// need to give other plugins that use readyup a chance to fully-load. Also, in-case a specific map is forced on startup.
}

void Now_CheckIfChangeMaps() {
	i_Rounds = 0;
	if (i_IsEnabled == 0 || StrEqual(NextMap, "none")) return;
	char text[64];
	FindMapDescription(NextMap, text, sizeof(text));
	PrintToChatAll("%t", "next map in rotation", s_rup, NextMap, text);
	CreateTimer(i_TimeDelay * 1.0, Timer_ChangeMap, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ChangeMap(Handle timer) {
	L4D2_ChangeLevel(NextMap);
	return Plugin_Stop;
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

int GetHumanPlayers(int client = -1) {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (client != -1 && i == client) continue;
		if (IsClientHuman(i)) count++;
	}
	return count;
}