#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define MAX_ENTITIES		2048

#define PLUGIN_VERSION		"1.4"
#define PLUGIN_CONTACT		"github.com/mewtani"

#define PLUGIN_NAME			"[RUM][Server Mgmt] Vote Map"
#define PLUGIN_DESCRIPTION	"Campaign / Map Voting"
#define CONFIG				"votemap.cfg"
#define CVAR_SHOW			FCVAR_NOTIFY | FCVAR_PLUGIN

#include <sourcemod>
#include <sdktools>
#include "wrap.inc"
#undef REQUIRE_PLUGIN
#include "readyup.inc"

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_CONTACT,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_CONTACT,
};

new i_IsEnabled;
new i_VoteTimeAllotted;
new i_SurvivalRounds;
new i_FinaleAttempts;
new i_TimeDelay;

new i_Rounds;
new i_TimeRemaining;
new i_RestrictCount;
new bool:b_IsVoteComplete;

new String:i_HasVoted[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

new String:s_rup[32];
new String:NextMap[PLATFORM_MAX_PATH];

new Handle:a_MapList1;
new Handle:a_MapList2;
new Handle:a_MapListIdentifier;
new Handle:a_MapListDescription;
new Handle:a_MapListRestricted;

new String:white[4];
new String:green[4];
new String:blue[4];
new String:orange[4];

new bool:bHasRandomMapped = false;
new bool:b_IsCustomVote = false;

public OnPluginStart()
{
	CreateConVar("rum_votemap", PLUGIN_VERSION, "version header", CVAR_SHOW);
	SetConVarString(FindConVar("rum_votemap"), PLUGIN_VERSION);

	LoadTranslations("common.phrases");
	LoadTranslations("rum_votemap.phrases");

	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");

	a_MapList1										= CreateArray(64);
	a_MapList2										= CreateArray(64);
	a_MapListIdentifier								= CreateArray(64);
	a_MapListDescription							= CreateArray(64);
	a_MapListRestricted								= CreateArray(64);

	RegConsoleCmd("votemap", CMD_VoteMap);
}

public Action:CMD_VoteMap(client, args) {

	if (!b_IsVoteComplete && !b_IsCustomVote) {

		b_IsCustomVote = true;
		StartVotemap();
	}
	if (b_IsCustomVote || b_IsVoteComplete) BuildMenu(client);
	return Plugin_Handled;
}

stock RestrictMap(String:Mapname_a[]) {

	if (i_RestrictCount > 0) {

		new size									= GetArraySize(a_MapListRestricted);
		decl String:Mapname[64];

		for (new i = size - 2; i >= 0; i--) {

			GetArrayString(a_MapListRestricted, i, Mapname, sizeof(Mapname));
			SetArrayString(a_MapListRestricted, i + 1, Mapname);
		}
		// Now that we've shifted everything, let's set the new value to the first slot.
		SetArrayString(a_MapListRestricted, 0, Mapname_a);
	}
}

stock bool:IsMapAllowed(String:Mapname_a[]) {

	if (i_RestrictCount < 1) return true;

	new size										= GetArraySize(a_MapListRestricted);
	decl String:Mapname[64];
	for (new i = 0; i < size; i++) {

		GetArrayString(a_MapListRestricted, i, Mapname, sizeof(Mapname));
		if (StrEqual(Mapname, Mapname_a)) return false;
	}

	return true;
}

public ReadyUp_AllClientsLoaded() {

	if (bHasRandomMapped) NextMap											= "none";
	ReadyUp_NtvCallModule("rotation.cfg", "ignore rotation", 0);
	b_IsVoteComplete								= false;

	//ReadyUp_NtvGetMapList();
}

public ReadyUp_IsEmptyOnDisconnect() {

	if (bHasRandomMapped) bHasRandomMapped = false;
	OnFirstLoadRandomCampaign();
}

public ReadyUp_ReadyUpEnd() {

	if (i_IsEnabled == 1 && !b_IsVoteComplete && IsChangeMap()) {

		StartVotemap();
	}
}

stock VotesRequired() {

	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i)) count++;
	}
	if (count > 1) count = (count / 2) + 1;
	return count;
}

stock StartVotemap() {

	b_IsVoteComplete							= true;
	i_TimeRemaining								= i_VoteTimeAllotted;

	// We set the restricted maps list, here. Mapnames that show in it can't be voted on.
	if (GetArraySize(a_MapListRestricted) != i_RestrictCount) {

		ResizeArray(a_MapListRestricted, i_RestrictCount);
		for (new i = 0; i < GetArraySize(a_MapListRestricted); i++) {

			SetArrayString(a_MapListRestricted, i, "none");
		}
	}

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i)) i_HasVoted[i] = "none";
	}

	CreateTimer(1.0, Timer_VoteMap, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_VoteMap(Handle:timer) {

	i_TimeRemaining--;

	if (i_TimeRemaining < 1) {

		i_TimeRemaining								= -1;
		b_IsVoteComplete = false;
		Now_CalculateVotes();

		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientHuman(i)) CancelClientMenu(i, true);
		}

		return Plugin_Stop;
	}

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientHuman(i) && GetClientMenu(i) == MenuSource_None) BuildMenu(i);
	}

	PrintHintTextToAll("%t", "Vote Time Remaining", i_TimeRemaining);

	return Plugin_Continue;
}

stock BuildMenu(client)
{
	new Handle:menu		=	CreateMenu(BuildMenuHandle);

	decl String:text[PLATFORM_MAX_PATH];
	decl String:a_MapName[PLATFORM_MAX_PATH];

	Format(text, sizeof(text), "%T", "Player Vote Display", client, FindMapDescription(i_HasVoted[client]));
	SetMenuTitle(menu, text);

	new a_Size										= GetArraySize(a_MapList1);
	new i_VoteCount[a_Size];

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientHuman(i)) continue;
		if (GetMapVoted(i_HasVoted[i]) == -1) continue;
		i_VoteCount[GetMapVoted(i_HasVoted[i])]++;
	}

	new PlayersCount								= GetHumanPlayers();

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:a_MapList1, i, a_MapName, sizeof(a_MapName));
		if (!IsMapAllowed(a_MapName)) continue;

		Format(text, sizeof(text), "%s (%d / %d)", FindMapDescription(a_MapName), i_VoteCount[i], PlayersCount);
		AddMenuItem(menu, text, text);
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, 0);
}

stock String:FindMapDescription(String:Name[]) {
	
	decl String:TargetName[PLATFORM_MAX_PATH];
	new a_Size										= GetArraySize(a_MapListIdentifier);

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:a_MapListIdentifier, i, TargetName, sizeof(TargetName));

		if (StrEqual(Name, TargetName)) {

			GetArrayString(Handle:a_MapListDescription, i, TargetName, sizeof(TargetName));
			return TargetName;
		}
	}
	strcopy(TargetName, sizeof(TargetName), Name);
	return TargetName;	// if we can't find it, we just display the actual map name.
}

public BuildMenuHandle(Handle:menu, MenuAction:action, client, slot)
{
	if (action == MenuAction_Select)
	{
		decl String:a_MapName[PLATFORM_MAX_PATH];

		new pos = -1;
		new size = GetArraySize(a_MapList1);
		for (new i = 0; i < size; i++) {

			GetArrayString(a_MapList1, i, a_MapName, sizeof(a_MapName));
			if (!IsMapAllowed(a_MapName)) continue;
			pos++;

			if (pos == slot) break;
		}

		//GetArrayString(Handle:a_MapList1, slot, a_MapName, sizeof(a_MapName));
		i_HasVoted[client] = a_MapName;
		PrintToChat(client, "%T", "map vote submitted", client, white, green, i_HasVoted[client]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock GetArraySizeEx(String:SearchKey[], String:Delim[] = ":") {

	new count = 0;
	for (new i = 0; i <= strlen(SearchKey); i++) {

		if (StrContains(SearchKey[i], Delim, false) != -1) count++;
	}
	if (count == 0) return -1;
	return count + 1;
}

stock Now_CalculateVotes() {

	new a_Size										= GetArraySize(a_MapList1);

	if (a_Size < 1) return;

	new i_VoteCount[a_Size];
	for (new i = 1; i <= MaxClients; i++) {

		if (!IsClientHuman(i) || GetMapVoted(i_HasVoted[i]) == -1) continue;
		i_VoteCount[GetMapVoted(i_HasVoted[i])]++;
	}

	new pos											= 0;

	decl String:Tiebreaker[64];
	new bool:IsFirst=true;

	for (new i = 0; i < a_Size; i++) {

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
	new tiesize = GetArraySizeEx(Tiebreaker);
	if (tiesize == -1) pos = StringToInt(Tiebreaker);
	else {

		// There was a tie somewhere.
		decl String:FindBest[tiesize][5];
		ExplodeString(Tiebreaker, ":", FindBest, tiesize, 5);
		pos = GetRandomInt(0, tiesize-1);
		pos = StringToInt(FindBest[pos]);
	}

	if (i_VoteCount[pos] > 0) {

		for (new i = 0; i < a_Size; i++) {

			if (i == pos) continue;
			i_VoteCount[i]							= 0;
		}
		if (!b_IsCustomVote || i_VoteCount[pos] >= VotesRequired()) {

			ReadyUp_NtvCallModule("rotation.cfg", "ignore rotation", 1);
			GetArrayString(Handle:a_MapList1, pos, NextMap, sizeof(NextMap));

			RestrictMap(NextMap);	// Add it to the restricted list.

			if (b_IsCustomVote) {

				b_IsCustomVote = false;
				Now_CheckIfChangeMaps();
			}
			else PrintToChatAll("%t", "next map in rotation", s_rup, NextMap, FindMapDescription(NextMap));
		}
		i_VoteCount[pos] = 0;
	}
}

public ReadyUp_TrueDisconnect(client) {
	if (GetHumanPlayers(client) < 1) ChangeMapIfNoHumans();
}

stock ChangeMapIfNoHumans() {
	LogMessage("No human players are in the server, forcing a new campaign.");
	// get the # of campaigns we can pick from
	new numOfCampaigns = GetArraySize(a_MapList1);
	// here we randomly grab one of the campaigns
	new randomCampaign = GetRandomInt(0, numOfCampaigns-1);
	// store the selected campaign in the NextMap string.
	GetArrayString(Handle:a_MapList1, randomCampaign, NextMap, sizeof(NextMap));
	// calls the change map method... will happen on a delay.
	Now_CheckIfChangeMaps();
}

stock GetMapVoted(String:s_MapName[]) {

	//new a_Size										= GetArraySize(a_MapList1);

	decl String:a_Map[PLATFORM_MAX_PATH];
	decl String:s_Map[PLATFORM_MAX_PATH];

	s_Map											= LowerString(s_MapName);

	// Using GetArraySize inside of the loop, because the size seems to be shifting during this point, and it shouldn't be.
	for (new i = 0; i < GetArraySize(a_MapList1); i++) {

		GetArrayString(Handle:a_MapList1, i, a_Map, sizeof(a_Map));
		a_Map										= LowerString(a_Map);

		if (StrEqual(a_Map, s_Map)) return i;
	}

	return -1;
}

public ReadyUp_IsClientLoaded(client) {

	i_HasVoted[client] = "none";
}

public OnConfigsExecuted() {

	i_Rounds										= 0;
	CreateTimer(0.1, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ExecuteConfig(Handle:timer) {

	if (ReadyUp_NtvConfigProcessing() == 0) {

		ReadyUp_ParseConfig(CONFIG);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public ReadyUp_ParseConfigFailed(String:config[], String:error[]) {

	if (StrEqual(config, CONFIG)) {
	
		SetFailState("%s , %s", config, error);
	}
}

public ReadyUp_LoadFromConfig(Handle:key, Handle:value) {

	decl String:s_key[32];
	decl String:s_value[32];

	new a_Size						= GetArraySize(key);

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:key, i, s_key, sizeof(s_key));
		GetArrayString(Handle:value, i, s_value, sizeof(s_value));
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

public ReadyUp_FwdGetHeader(const String:header[]) {

	strcopy(s_rup, sizeof(s_rup), header);
}

public ReadyUp_FwdGetMapList(Handle:MapList1, Handle:MapList2, Handle:MapListIdentifier, Handle:MapListDescription) {

	ClearArray(Handle:a_MapList1);
	ClearArray(Handle:a_MapList2);
	ClearArray(Handle:a_MapListIdentifier);
	ClearArray(Handle:a_MapListDescription);

	new a_Size = GetArraySize(MapList1);

	decl String:a_Map[PLATFORM_MAX_PATH];

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:MapList1, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList1, a_Map);

		GetArrayString(Handle:MapList2, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList2, a_Map);

		GetArrayString(Handle:MapListIdentifier, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapListIdentifier, a_Map);

		GetArrayString(Handle:MapListDescription, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapListDescription, a_Map);
	}
	if (!bHasRandomMapped) OnFirstLoadRandomCampaign();
}

public ReadyUp_CampaignComplete() {

	new gametype										= ReadyUp_GetGameMode();

	if (gametype == 1) Now_CheckIfChangeMaps();	// don't need IsChangeMaps since this only fires if a campaign finale is won.
}

public ReadyUp_RoundIsOver() {

	new gametype										= ReadyUp_GetGameMode();

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

stock OnFirstLoadRandomCampaign() {

	if (bHasRandomMapped) return;

	bHasRandomMapped = true;	// starts false when the plugin first loads and never resets.

	new pos = GetRandomInt(0, GetArraySize(Handle:a_MapList1) - 1);
	GetArrayString(Handle:a_MapList1, pos, NextMap, sizeof(NextMap));

	//RestrictMap(NextMap);	// Add it to the restricted list.
	// Had to comment this out for now, it's bugging out at the start of the plugin load, so will need to investigate later.
	CreateTimer(5.0, Timer_ChangeMap);	// need to give other plugins that use readyup a chance to fully-load. Also, in-case a specific map is forced on startup.
}

stock Now_CheckIfChangeMaps() {

	i_Rounds											= 0;

	if (i_IsEnabled == 0 || StrEqual(NextMap, "none")) return;

	PrintToChatAll("%t", "next map in rotation", s_rup, NextMap, FindMapDescription(NextMap));

	CreateTimer(i_TimeDelay * 1.0, Timer_ChangeMap, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ChangeMap(Handle:timer) {

	ServerCommand("changelevel %s", NextMap);

	return Plugin_Stop;
}

stock bool:IsChangeMap() {

	decl String:mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	mapname											= LowerString(mapname);

	decl String:a_mapname[128];

	new a_Size										= GetArraySize(a_MapList2);

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:a_MapList2, i, a_mapname, sizeof(a_mapname));
		a_mapname									= LowerString(a_mapname);

		if (StrEqual(mapname, a_mapname)) return true;
	}

	return false;
}

stock String:LowerString(String:s[]) {

	decl String:s_[32];
	for (new i = 0; i <= strlen(s); i++) {

		if (!IsCharLower(s[i])) s_[i] = CharToLower(s[i]);
		else s_[i] = s[i];
	}
	return s_;
}

stock GetHumanPlayers(client = -1) {

	new count																			= 0;

	for (new i = 1; i <= MaxClients; i++) {
		if (client != -1 && i == client) continue;
		if (IsClientHuman(i)) count++;
	}

	return count;
}