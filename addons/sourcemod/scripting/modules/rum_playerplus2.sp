#define			TEAM_SPECTATOR							1
#define			TEAM_SURVIVOR							2
#define			TEAM_INFECTED							3
#define			MAX_ENTITIES							2048
#define			PLUGIN_VERSION							"2.3"
#define			PLUGIN_CONTACT							""
#define			PLUGIN_NAME								"PLAYERPLUS"
#define			PLUGIN_DESCRIPTION						"bot manager"
#define			CVAR_SHOW								FCVAR_NOTIFY | FCVAR_PLUGIN

#define NICK_MODEL				"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL			"models/survivors/survivor_producer.mdl"
#define COACH_MODEL				"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL				"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL				"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL			"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL				"models/survivors/survivor_manager.mdl"
#define BILL_MODEL				"models/survivors/survivor_namvet.mdl"

#include		<sourcemod>
#include		<sdktools>
#include		"wrap.inc"

#undef			REQUIRE_PLUGIN
#include		"readyup.inc"
#include		"l4d_stocks.inc"

public Plugin:myinfo = { name = PLUGIN_NAME, author = PLUGIN_CONTACT, description = PLUGIN_DESCRIPTION, version = PLUGIN_VERSION, url = PLUGIN_CONTACT };

new Handle:g_sGameConf									= INVALID_HANDLE;
new Handle:hSetHumanSpec								= INVALID_HANDLE;
new Handle:hTakeOverBot									= INVALID_HANDLE;
new Handle:hRoundRespawn								= INVALID_HANDLE;
new String:white[4];
new String:green[4];
new String:blue[4];
new String:orange[4];
new iMinSurvivors;
new iNumClientsLoading;

public OnPluginStart()
{
	CreateConVar("rum_playerplus2", PLUGIN_VERSION, "version header", CVAR_SHOW);
	SetConVarString(FindConVar("rum_playerplus2"), PLUGIN_VERSION);

	LoadTranslations("rum_playerplus.phrases");

	g_sGameConf = LoadGameConfigFile("rum_playerplus");
	if (g_sGameConf != INVALID_HANDLE)
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(g_sGameConf, SDKConf_Signature, "SetHumanSpec");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		hSetHumanSpec = EndPrepSDKCall();
	
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(g_sGameConf, SDKConf_Signature, "TakeOverBot");
		PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
		hTakeOverBot = EndPrepSDKCall();

		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(g_sGameConf, SDKConf_Signature, "RoundRespawn");
		hRoundRespawn = EndPrepSDKCall();
	}
	else SetFailState("File not found: .../gamedata/rum_playerplus.txt");

	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");

	AddCommandListener(Cmd_JoinTeam, "jointeam");
}

public Action:Cmd_JoinTeam(client, String:command[], argc) {

	decl String:a_temp[32];
	GetCmdArg(1, a_temp, sizeof(a_temp));
	if ((StrEqual(a_temp, "Survivor") || StringToInt(a_temp) == TEAM_SURVIVOR) && GetClientTeam(client) != TEAM_SURVIVOR) ChangeTeamSurvivor(client);
	else if (ReadyUp_GetGameMode() == 2 && ((StrEqual(a_temp, "Infected") || StringToInt(a_temp) == TEAM_INFECTED) && GetClientTeam(client) != TEAM_INFECTED)) ChangeClientTeam(client, TEAM_INFECTED);
	else if (StrEqual(a_temp, "Spectator") || StringToInt(a_temp) == TEAM_SPECTATOR) ChangeClientTeam(client, TEAM_SPECTATOR);
	if (StringToInt(a_temp) != TEAM_SURVIVOR) CreateTimer(0.1, Timer_KickSurvivorBots, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public ReadyUp_FwdChangeTeam(client, team) {

	decl String:Name[64];
	GetClientName(client, Name, sizeof(Name));

	if (team == TEAM_SPECTATOR) {

		PrintToChatAll("%t", "Change Team Spectator", green, Name, white, green);
		ChangeClientTeam(client, TEAM_SPECTATOR);
	}
	else if (team == TEAM_SURVIVOR) {

		PrintToChatAll("%t", "Change Team Survivor", green, Name, white, blue);
		ChangeTeamSurvivor(client);
	}
	else if (team == TEAM_INFECTED) {

		PrintToChatAll("%t", "Change Team Infected", green, Name, white, orange);
		ChangeClientTeam(client, TEAM_INFECTED);
	}
	//if (team != TEAM_SURVIVOR) KickSurvivorBots();
	if (team != TEAM_SURVIVOR) CreateTimer(0.2, Timer_CheckSurvivorCount, _, TIMER_FLAG_NO_MAPCHANGE);
}

public ReadyUp_TrueDisconnect(client) {

	//if (GetClientTeam(client) == TEAM_SURVIVOR) KickSurvivorBots();
	if (!IsFakeClient(client)) {

		CreateTimer(0.1, Timer_KickSurvivorBots, _, TIMER_FLAG_NO_MAPCHANGE);
		if (TotalSurvivorCount(true, client) < 1 && iMinSurvivors < 1) {

			// lets other plugins know that there are no more humans and all bots have been removed.

			ReadyUp_NtvIsEmptyOnDisconnect();
		}
	}
}

public Action:Timer_CheckSurvivorCount(Handle:timer) {

	// new oldmin = iMinSurvivors;
	// iMinSurvivors = iMin;
	// //if (oldmin < iMin || oldmin == iMin) CreateSurvivorBots();
	// if (oldmin < iMin) CreateSurvivorBots();
	// else KickSurvivorBots();

	new TotalSurvivors = TotalSurvivorCount();
	new TotalHumanSurvivors = TotalSurvivorCount(true);
	new SurvivorBots = (TotalSurvivors > TotalHumanSurvivors) ? TotalSurvivors - TotalHumanSurvivors : 0;
	if (TotalHumanSurvivors < 1 || TotalHumanSurvivors + SurvivorBots > iMinSurvivors) {
		PrintToChatAll("Kicking survivor bots.");
		KickSurvivorBots();
	}
	else if (iMinSurvivors > TotalHumanSurvivors + SurvivorBots) CreateSurvivorBots();
	// if (TotalSurvivorCount(true) < 1 || TotalSurvivors > iMinSurvivors) CreateTimer(0.1, Timer_KickSurvivorBots, _, TIMER_FLAG_NO_MAPCHANGE);
	// else if (iMinSurvivors > TotalSurvivors) CreateTimer(0.1, Timer_CreateSurvivorBots, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}

public Action:Timer_CreateSurvivorBots(Handle:timer) { CreateSurvivorBots(); return Plugin_Stop; }
public Action:Timer_KickSurvivorBots(Handle:timer) { KickSurvivorBots(); return Plugin_Stop; }
public ReadyUp_CheckpointDoorStartOpened() {

	for (new i = 1; i <= MaxClients; i++) {


		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && !IsPlayerAlive(i)) {

			SDKCall(hRoundRespawn, i);
		}
	}
	KickSurvivorBots();
	//GiveMedKits();
}

public bool:IsClientsConnecting() {

	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

public ReadyUp_SetSurvivorMinimum(iMin) {

	new oldmin = iMinSurvivors;
	iMinSurvivors = iMin;
	//if (oldmin < iMin || oldmin == iMin) CreateSurvivorBots();
	if (oldmin < iMin) CreateSurvivorBots();
	else if (oldmin > iMin) KickSurvivorBots();
}

stock CreateSurvivorBots() {
	if (TotalSurvivorCount(true) < 1) return;	// no bots are created if there are no players.
	new thenumber = iMinSurvivors - TotalSurvivorCount();
	if (thenumber < 1) return;
	//if (IsClientsConnecting()) thenumber = 1;	// if there are still clients connecting, we only create one bot.
	while (thenumber > 0) {

		thenumber--;
		CreateSurvivorBot();
	}
}

public ReadyUp_ReadyUpStart() { CreateTimer(0.2, Timer_KickSurvivorBots, _, TIMER_FLAG_NO_MAPCHANGE); }

/*public GiveMedKits() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && GetPlayerWeaponSlot(i, 3) == -1) ExecCheatCommand(i, "give", "first_aid_kit");
	}
}*/

stock FindClientWithAuthString(String:key[], bool:MustBeExact = false) {

	decl String:AuthId[64];
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i)) {

			GetClientAuthString(i, AuthId, sizeof(AuthId));
			if (MustBeExact && StrEqual(key, AuthId, false) || !MustBeExact && StrContains(key, AuthId, false) != -1) return i;
		}
	}
	return -1;
}

stock bool:IsLegitimateClient(client) {

	if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) return false;
	return true;
}

stock bool:IsSurvivorCompanion(client) {

	decl String:CompanionSteamId[64];
	GetEntPropString(client, Prop_Data, "m_iName", CompanionSteamId, sizeof(CompanionSteamId));
	if (FindClientWithAuthString(CompanionSteamId) != -1) return true;
	return false;
}

public KickSurvivorBots() {

	/*if (TotalHumanCount() > 0 && (TotalSurvivorCount() < 4 || TotalHumanSurvivorCount() < 4)) {

		if (TotalSurvivorCount() < 4) {

			CreateSurvivorBot();
		}
		return;
	}*/
	new TotalSurvs = TotalSurvivorCount();
	new HumanSerfs = TotalSurvivorCount(true);
	new SurvivorBots = (TotalSurvs > HumanSerfs) ? TotalSurvs - HumanSerfs : 0;
	// LogMessage("Total Survs: %d and Required survs: %d", TotalSurvs, iMinSurvivors);
	// PrintToChatAll("Total Survs: %d and Required survs: %d", TotalSurvs, iMinSurvivors);
	//if (HumanSerfs <= iMinSurvivors) return;	// never let it drop below 4 as long as there is at least 1 human player.
	PrintToChatAll("Survivor bots: %d, Total Survs: %d, min survivors: %d", SurvivorBots, SurvivorBots+HumanSerfs, iMinSurvivors);
	for (new i = 1; i <= MaxClients; i++) {
		if (SurvivorBots == 0 || HumanSerfs > 0 && HumanSerfs + SurvivorBots <= iMinSurvivors) break;
		PrintToChatAll("Trying to kick bots.");
		//if (IsClientBot(i) && (GetClientTeam(i) == TEAM_SURVIVOR || IsSurvivorBot(i)) && TotalSurvs > iMinSurvivors) {
		if (IsLegitimateClient(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
			// LogMessage("Kicking Survivor bots.");
			// PrintToChatAll("Kicking survivor bots.");
			L4D_RemoveAllWeapons(i);
			KickClient(i);
			SurvivorBots--;
		}
	}
}

public TotalHumanSurvivorCount() {

	new Count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) Count++;
	}
	return Count;
}

public TotalHumanCount() {

	new Count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i)) Count++;
	}
	return Count;
}

stock bool:IsSurvivorBot(client) {

	if (IsLegitimateClient(client) && IsFakeClient(client)) {

		/*decl String:TheCurr[64];
		GetCurrentMap(TheCurr, sizeof(TheCurr));
		if (StrContains(TheCurr, "helms_deep", false) == -1) {

			if (GetClientTeam(client) == TEAM_SURVIVOR) return true;
		}
		else {*/

		decl String:TheModel[64];
		GetClientModel(client, TheModel, sizeof(TheModel));	// helms deep creates bots that aren't necessarily on the survivor team.
		if (StrEqual(TheModel, NICK_MODEL) ||
			StrEqual(TheModel, ROCHELLE_MODEL) ||
			StrEqual(TheModel, COACH_MODEL) ||
			StrEqual(TheModel, ELLIS_MODEL) ||
			StrEqual(TheModel, ZOEY_MODEL) ||
			StrEqual(TheModel, FRANCIS_MODEL) ||
			StrEqual(TheModel, LOUIS_MODEL) ||
			StrEqual(TheModel, BILL_MODEL)) {

			return true;
		}
	}
	return false;
}

stock TotalSurvivorCount(bool:bIsHumans = false, client = 0) {

	new Count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVOR || IsSurvivorBot(i)) && (client == 0 || client != i)) {

			if (!bIsHumans || !IsFakeClient(i)) Count++;
		}
	}
	return Count;
}

stock CreateSurvivorBot(client = -1, String:CompanionName[] = "Survivor Bot") {
	new survivorBot									= CreateFakeClient(CompanionName);
	if (survivorBot != 0) {

		ChangeClientTeam(survivorBot, TEAM_SURVIVOR);
		if (DispatchKeyValue(survivorBot, "classname", "survivorbot") && DispatchSpawn(survivorBot)) {

			//SDKCall(hRoundRespawn, survivorBot);

			new Float:Pos[3];

			if (IsPlayerAlive(survivorBot)) {

				for (new i = 1; i <= MaxClients; i++) {

					if (i != client && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && i != survivorBot) {

						GetClientAbsOrigin(i, Pos);
						TeleportEntity(survivorBot, Pos, NULL_VECTOR, NULL_VECTOR);
						break;
					}
				}
			}
			KickClient(survivorBot);
			if (client != -1) {
				if (survivorBot != -1) {

					decl String:SteamId[64];
					GetClientAuthString(client, SteamId, sizeof(SteamId));
					SetEntPropString(survivorBot, Prop_Data, "m_iName", SteamId);
				}
			}
		}
	}
}

public ReadyUp_IsClientLoaded(client) {
	KickSurvivorBots();
}

public ChangeTeamSurvivor(client) {

	new survivor										= FindSurvivorBot();

	if (survivor == 0) {
		CreateSurvivorBot(client);
		CreateTimer(1.0, Timer_ChangeTeamSurvivor, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (IsClientInGame(survivor)) {
		SDKCall(hSetHumanSpec, survivor, client);
		SDKCall(hTakeOverBot, client, true);
		//KickSurvivorBots();
		CreateTimer(0.2, Timer_CheckSurvivorCount, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public OnMapStart() {
	CreateTimer(5.0, Timer_CheckSurvivorCount, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ChangeTeamSurvivor(Handle:timer, any:client) {

	if (client > 0 && IsClientInGame(client) && !IsFakeClient(client)) {

		ChangeTeamSurvivor(client);
	}

	return Plugin_Stop;
}

public FindSurvivorBot() {

	//new owner = 0;

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientConnected(i) && IsClientActual(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsFakeClient(i)) {
		
			// This is so that we don't identify a bot that currently has a player assigned to them
			// like a player who is "away from keyboard"
			//owner = GetEntProp(i, Prop_Send, "m_hOwnerEntity");
			//LogMessage("owner is %N", owner);
			//if (IsClientConnected(owner) && IsClientActual(owner) && !IsFakeClient(owner)) continue;
			
			return i;
		}
	}

	return 0;
}
