 /**
 * =============================================================================
 * Ready Up - RPG (C)2014 Michael "Skye" Toth
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

#define TEAM_SPECTATOR			1
#define TEAM_SURVIVOR			2
#define TEAM_INFECTED			3
#define ZOMBIECLASS_SMOKER		1
#define ZOMBIECLASS_BOOMER		2
#define ZOMBIECLASS_HUNTER		3
#define ZOMBIECLASS_SPITTER		4
#define ZOMBIECLASS_JOCKEY		5
#define ZOMBIECLASS_CHARGER		6
#define ZOMBIECLASS_TANK		8
#define PLUGIN_NAME			"[RUM][Team Mgmt] Team Manager"
#define PLUGIN_DESCRIPTION	"Handles team balance and other team related... things."
#define PLUGIN_VERSION		"3.3"
#define PLUGIN_CONTACT		"somewhere"
#define CVAR_SHOW FCVAR_NOTIFY | FCVAR_PLUGIN
#define STEAM_ID_LENGTH			64
#define NICK_NET				0
#define ROCHELLE_NET			1
#define COACH_NET				2
#define ELLIS_NET				3
#define BILL_NET				4
#define ZOEY_NET				5
#define FRANCIS_NET				6
#define LOUIS_NET				7
#define NICK_MODEL				"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL			"models/survivors/survivor_producer.mdl"
#define COACH_MODEL				"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL				"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL				"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL			"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL				"models/survivors/survivor_manager.mdl"
#define BILL_MODEL				"models/survivors/survivor_namvet.mdl"

#define GAMEMODE_VERSUS			2

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <adminmenu>
#include "left4downtown.inc"
#include <l4d2_direct>
#include "l4d_stocks.inc"
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

new IdleCounter[MAXPLAYERS + 1];
new Float:PlayerPos[MAXPLAYERS + 1][3];
new Float:EyePos[MAXPLAYERS + 1][3];
new String:white[4];
new String:blue[4];
new String:orange[4];
new String:green[4];
new Handle:a_MapList1;
new Handle:a_MapList2;
new bool:bIsConnected[MAXPLAYERS + 1];
new bool:IsNotHere[MAXPLAYERS + 1];
new bool:bLoadAttempted[MAXPLAYERS + 1];
new NumRounds;
new bool:bRoundOver;
new MapScores[20][3];
new mapcounter;
new String:TopRankedPlayers[10][512];
new CommonKills[MAXPLAYERS + 1];
new CommonRank[MAXPLAYERS + 1];
new CommonKillsAverage[MAXPLAYERS + 1];
new CommonKillsAverageRank[MAXPLAYERS + 1];
new SpecialKills[MAXPLAYERS + 1];
new SpecialRank[MAXPLAYERS + 1];
new SurvivorDamage[MAXPLAYERS + 1];
new SurvivorDamageRank[MAXPLAYERS + 1];
new SurvivorDamageAverage[MAXPLAYERS + 1];
new SurvivorDamageAverageRank[MAXPLAYERS + 1];
new Rescues[MAXPLAYERS + 1];
new RescuesRank[MAXPLAYERS + 1];
new SurvivorIncaps[MAXPLAYERS + 1];
new SurvivorIncapsRank[MAXPLAYERS + 1];
new InfectedDamage[MAXPLAYERS + 1];
new InfectedDamageRank[MAXPLAYERS + 1];
new InfectedDamageAverage[MAXPLAYERS + 1];
new InfectedDamageAverageRank[MAXPLAYERS + 1];
new InfectedIncaps[MAXPLAYERS + 1];
new InfectedIncapsRank[MAXPLAYERS + 1];
new InfectedRoundsPlayed[MAXPLAYERS + 1];
new SurvivorRoundsPlayed[MAXPLAYERS + 1];
new Rank[MAXPLAYERS + 1];
new RankMaximum;
new bool:bDatabaseLoaded;
new bool:bAssigned[MAXPLAYERS + 1];
new bool:IsLoading[MAXPLAYERS + 1];
new Team[MAXPLAYERS + 1];
new bool:bTeamsFlipped;
new SurvivorDamageTaken[MAXPLAYERS + 1];
new InfectedDamageTaken[MAXPLAYERS + 1];
new SurvivorDamageTakenRank[MAXPLAYERS + 1];
new InfectedDamageTakenRank[MAXPLAYERS + 1];
new SurvivorDamageTakenAverage[MAXPLAYERS + 1];
new InfectedDamageTakenAverage[MAXPLAYERS + 1];
new SurvivorDamageTakenAverageRank[MAXPLAYERS + 1];
new InfectedDamageTakenAverageRank[MAXPLAYERS + 1];

#include											"teammanager/database.sp"
#include											"teammanager/login.sp"
#include											"teammanager/teams.sp"
#include											"teammanager/scramble.sp"
#include											"teammanager/events.sp"

public OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("infected_death", Event_InfectedDeath);
	HookEvent("player_incapacitated", Event_PlayerIncapacitated);
	HookEvent("choke_stopped", Event_ChokeStopped);
	HookEvent("jockey_ride_end", Event_JockeyRideEnd);
	HookEvent("pounce_stopped", Event_PounceStopped);
	HookEvent("revive_success", Event_ReviveSuccess);

	RegConsoleCmd("top10", CMD_Top10Players);
	RegConsoleCmd("team", CMD_Teams);
	RegConsoleCmd("teams", CMD_Teams);
	RegConsoleCmd("go_away_from_keyboard", CMD_BlockVotes);
	RegConsoleCmd("callvote", CMD_BlockVotes);
	RegConsoleCmd("vote", CMD_BlockVotes);
	RegAdminCmd("swap", CMD_SwapPlayer, ADMFLAG_KICK);

	RegConsoleCmd("say", CMD_Say);
	RegConsoleCmd("say_team", CMD_Say);

	Format(white, sizeof(white), "\x01");
	Format(blue, sizeof(blue), "\x03");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");

	LoadTranslations("rum_teammanager.phrases");

	a_MapList1			= CreateArray(64);
	a_MapList2			= CreateArray(64);

	if (!bDatabaseLoaded)
	{
		bDatabaseLoaded = true;
		MySQL_Init();
	}
}

public Action:CMD_Say(client, args) {

	decl String:Command[64];
	GetCmdArg(1, Command, sizeof(Command));
	StripQuotes(Command);
	if (Command[0] != '/' && Command[0] != '!') return Plugin_Continue;

	if (StrEqual(Command[1], "nick", false)) PlayerChooseSurvivorModel(client, NICK_MODEL);
	if (StrEqual(Command[1], "rochelle", false)) PlayerChooseSurvivorModel(client, ROCHELLE_MODEL);
	if (StrEqual(Command[1], "coach", false)) PlayerChooseSurvivorModel(client, COACH_MODEL);
	if (StrEqual(Command[1], "ellis", false)) PlayerChooseSurvivorModel(client, ELLIS_MODEL);
	if (StrEqual(Command[1], "bill", false)) PlayerChooseSurvivorModel(client, BILL_MODEL);
	if (StrEqual(Command[1], "zoey", false)) PlayerChooseSurvivorModel(client, ZOEY_MODEL);
	if (StrEqual(Command[1], "francis", false)) PlayerChooseSurvivorModel(client, FRANCIS_MODEL);
	if (StrEqual(Command[1], "louis", false)) PlayerChooseSurvivorModel(client, LOUIS_MODEL);

	if (Command[0] == '/') return Plugin_Handled;
	return Plugin_Continue;
}

stock FindZombieClass(client)
{
	if (IsLegitimateClient(client)) return GetEntProp(client, Prop_Send, "m_zombieClass");
	return -1;
}

stock bool:L4D1SurvivorsAllowed() {

	// c6m3 and c7m3 will teleport L4D1 survivors to cinematic locations, so we disable them on these two finales.
	decl String:CurrentMap[64];
	GetCurrentMap(CurrentMap, sizeof(CurrentMap));
	if (StrContains(CurrentMap, "c6m3", false) != -1 || StrContains(CurrentMap, "c7m3", false) != -1) return false;
	
	return true;
}

stock PlayerChooseSurvivorModel(client, String:Model[]) {

	if (StrEqual(Model, NICK_MODEL))
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", NICK_NET);
		SetEntityModel(client, NICK_MODEL);
	}
	else if (StrEqual(Model, ROCHELLE_MODEL))
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", ROCHELLE_NET);
		SetEntityModel(client, ROCHELLE_MODEL);
	}
	else if (StrEqual(Model, COACH_MODEL))
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", COACH_NET);
		SetEntityModel(client, COACH_MODEL);
	}
	else if (StrEqual(Model, ELLIS_MODEL))
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", ELLIS_NET);
		SetEntityModel(client, ELLIS_MODEL);
	}
	else if (StrEqual(Model, BILL_MODEL) && L4D1SurvivorsAllowed()) {

		SetEntProp(client, Prop_Send, "m_survivorCharacter", BILL_NET);
		SetEntityModel(client, BILL_MODEL);
	}
	else if (StrEqual(Model, ZOEY_MODEL) && L4D1SurvivorsAllowed())
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", ZOEY_NET);
		SetEntityModel(client, ZOEY_MODEL);
	}
	else if (StrEqual(Model, FRANCIS_MODEL) && L4D1SurvivorsAllowed())
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", FRANCIS_NET);
		SetEntityModel(client, FRANCIS_MODEL);
	}
	else if (StrEqual(Model, LOUIS_MODEL) && L4D1SurvivorsAllowed())
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", LOUIS_NET);
		SetEntityModel(client, LOUIS_MODEL);
	}
}

public Action:CMD_Top10Players(client, args)
{
	SendPanelToClientAndClose(Top10Players(client), client, Top10Players_Init, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action:CMDTeleport(client, args)
{
	if (args < 1)
	{
		PrintToChat(client, "!teleport <player>");
		return;
	}
	decl String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1, arg1, sizeof(arg1));
	if (!StrEqual(arg1, "all", false))
	{
		decl String:target_name[MAX_NAME_LENGTH];
		decl target_list[MAXPLAYERS + 1], target_count, bool:tn_is_ml;
		new name;
		new i = 0;
		if ((target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) > 0)
		{
			for (i = 0; i < target_count; i++) { name = target_list[i]; }
		}
		new survivorsalive = 0;
		for (new j = 1; j <= MaxClients; j++)
		{
			if (!IsClientInGame(j) || IsFakeClient(j) || !IsPlayerAlive(j) || GetClientTeam(j) != 2 || j == name) continue;
			survivorsalive++;
		}
		if (survivorsalive < 1)
		{
			PrintToChat(client, "No survivors found, cannot teleport player.");
			return;
		}
		new survivorfound = 0;
		while (survivorfound == 0)
		{
			i = GetRandomInt(1, MaxClients);
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && i != name)
			{
				new Float:teleport[3];
				GetClientAbsOrigin(i, teleport);
				TeleportEntity(name, Float:teleport, NULL_VECTOR, NULL_VECTOR);
				survivorfound = 1;
				PrintToChatAll("%N teleported %N to %N.", client, name, i);
			}
		}
	}
	else
	{
		if (IsPlayerAlive(client))
		{
			// teleport all human survivors to the players location.
			new Float:SurvivorLocation[3];
			GetClientAbsOrigin(client, SurvivorLocation);
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsClientHuman(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && i != client)
				{
					TeleportEntity(i, Float:SurvivorLocation, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}
}

public Action:CMD_Teams(client, args)
{
	if (!bLoadAttempted[client])
	{
		bLoadAttempted[client] = true;
		LoadPlayerData(client);
	}
	GetClientRank(client);
	SendPanelToClientAndClose(TeamManagerMenu(client), client, TeamManagerMenu_Init, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action:CMD_BlockVotes(client, args)
{
	return Plugin_Handled;
}

public OnConfigsExecuted()
{
	CreateConVar("rum_teammanager", PLUGIN_VERSION, "The current version release of the plugin.", CVAR_SHOW);
	SetConVarString(FindConVar("rum_teammanager"), PLUGIN_VERSION);
}

public ReadyUp_FwdGetMapList(Handle:MapList1, Handle:MapList2) {

	ClearArray(Handle:a_MapList1);
	ClearArray(Handle:a_MapList2);

	new a_Size = GetArraySize(MapList1);

	decl String:a_Map[128];

	for (new i = 0; i < a_Size; i++) {

		GetArrayString(Handle:MapList1, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList1, a_Map);

		GetArrayString(Handle:MapList2, i, a_Map, sizeof(a_Map));
		PushArrayString(a_MapList2, a_Map);
	}
}

stock bool:IsFirstMap() {
	decl String:MapName[64];
	GetCurrentMap(MapName, sizeof(MapName));

	decl String:text[64];
	new size = GetArraySize(a_MapList1);

	for (new i = 0; i < size; i++) {

		GetArrayString(Handle:a_MapList1, i, text, sizeof(text));
		if (StrEqual(MapName, text, false)) return true;
	}

	return false;
}

public ReadyUp_AllClientsLoaded()
{
	if (IsFirstMap() || ReadyUp_GetGameMode() != GAMEMODE_VERSUS) ResetCampaignScores();

	NumRounds = 0;
	if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS)
	{
		if (!IsFirstMap()) TeamAssignmentCheck(true);
		else Scramble(true);
	}
}

public ReadyUp_CoopMapFailed(gamemode) {

	NumRounds--;
	SaveAllPlayers();
}

public ResetCampaignScores()
{
	mapcounter = 0;
	for (new i = 0; i <= 4; i++)
	{
		MapScores[i][0] = 0;
		MapScores[i][1] = 0;
	}
}

stock HumanSurvivorCount() {

	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}

	return count;
}

new bool:b_IsCheckpointDoorStartOpened = false;
public ReadyUp_CheckpointDoorStartOpened() {
	if (!b_IsCheckpointDoorStartOpened) {
		b_IsCheckpointDoorStartOpened		= true;
		CreateTimer(1.0, Timer_CheckForAFK, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public CheckTeams(client)
{
	if (ReadyUp_GetGameMode() != GAMEMODE_VERSUS) return;
	new survivors = 0;
	new infected = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) survivors++;
		else if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) infected++;
	}
	if (infected > survivors) RandomAssignment(TEAM_INFECTED, TEAM_SURVIVOR);
	else if (survivors > infected) RandomAssignment(TEAM_SURVIVOR, TEAM_INFECTED);
	else {

		new random = GetRandomInt(1, 100);
		if (random <= 50) RandomAssignment(TEAM_INFECTED, TEAM_SURVIVOR);
		else RandomAssignment(TEAM_SURVIVOR, TEAM_INFECTED);
	}
}

public ReadyUp_FwdChangeTeam(client, team) {

	//if (team == TEAM_SURVIVOR) CreateTimer(1.0, Timer_SetSurvivorModel, client, TIMER_FLAG_NO_MAPCHANGE);
}

public RandomAssignment(TargetTeam, DestinationTeam)
{
	new String:Name[MAX_NAME_LENGTH];
	new i = 0;
	while (i < 1)
	{
		new client = GetRandomInt(1, MaxClients);
		i = GetClientOfUserId(client);
		if (IsLegitimateClient(i) && !IsFakeClient(i) && (GetClientTeam(i) == TargetTeam || TargetTeam == -1))
		{
			if (DestinationTeam == TEAM_INFECTED)
			{
				ReadyUp_NtvChangeTeam(i, TEAM_INFECTED);
				GetClientName(i, Name, sizeof(Name));
				PrintToChatAll("%t", "Player Forced Infected Team", white, orange, white, Name);
			}
			else if (DestinationTeam == TEAM_SURVIVOR)
			{
				ReadyUp_NtvChangeTeam(i, TEAM_SURVIVOR);
				GetClientName(i, Name, sizeof(Name));
				PrintToChatAll("%t", "Player Forced Survivor Team", white, blue, white, Name);
			}
		}
		else i = 0;
	}
	// Check the teams again, just in case the teams are so imbalanced that they need more players moved.
	//CheckTeams(0);
}

public ReadyUp_ReadyUpEnd()
{
	//LoadAllPlayersData();
	SetConVarInt(FindConVar("director_afk_timeout"), 9999);
	GetTop10();


	/*for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) CreateTimer(1.0, Timer_SetSurvivorModel, i, TIMER_FLAG_NO_MAPCHANGE);
	}*/
	bRoundOver = false;
	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i)) continue;
		IdleCounter[i] = 0;
		if (GetClientTeam(i) != TEAM_SPECTATOR) IsNotHere[i] = false;
	}
}

public Action:Timer_CheckForAFK(Handle:timer) {

	if (bRoundOver || !b_IsCheckpointDoorStartOpened) return Plugin_Stop;
	new Float:pos[3];
	new Float:eye[3];

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i)) continue;
		if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) == TEAM_SPECTATOR || IsIncapacitated(i) || L4D2_GetInfectedAttacker(i) != -1) {

			IdleCounter[i] = 0;
			continue;
		}
		GetClientAbsOrigin(i, pos);
		GetClientEyeAngles(i, eye);
		if (GetVectorDistance(PlayerPos[i], pos) == 0.0 && GetVectorDistance(EyePos[i], eye) == 0.0) {

			/*

				Player appears to be afk and is not ensnared.
			*/
			IdleCounter[i]++;
		}
		else IdleCounter[i] = 0;
		GetClientAbsOrigin(i, PlayerPos[i]);
		GetClientEyeAngles(i, EyePos[i]);
		if (IdleCounter[i] == 60) PrintToChat(i, "%T", "afk warning", i);
		if (IdleCounter[i] == 90) {

			IsNotHere[i] = true;
			ReadyUp_NtvChangeTeam(i, TEAM_SPECTATOR);
			IdleCounter[i] = 0;
			/*if (HasCommandAccessEx(i, "a") || HasCommandAccessEx(i, "k") || HasCommandAccessEx(i, "z")) {

				IsNotHere[i] = true;
				ReadyUp_NtvChangeTeam(i, TEAM_SPECTATOR);
				IdleCounter[i] = 0;
			}
			else {

				IsNotHere[i] = false;
				IdleCounter[i] = 0;
				KickClient(i, "afk");
			}*/
		}
	}
	return Plugin_Continue;
}

public OnMapStart()
{
	bRoundOver = true;
	b_IsCheckpointDoorStartOpened = false;
	PrecacheModel(NICK_MODEL);
	PrecacheModel(ROCHELLE_MODEL);
	PrecacheModel(COACH_MODEL);
	PrecacheModel(ELLIS_MODEL);
	PrecacheModel(ZOEY_MODEL);
	PrecacheModel(FRANCIS_MODEL);
	PrecacheModel(LOUIS_MODEL);
	PrecacheModel(BILL_MODEL);
}

public ReadyUp_RoundIsOver(gamemode) {
	bRoundOver = false;
	b_IsCheckpointDoorStartOpened = false;

	if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) {

		CalculateSurvivorScores();
	}

	NumRounds++;

	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i)) {

			if (GetClientTeam(i) == TEAM_SURVIVOR) SurvivorRoundsPlayed[i]++;
			else if (GetClientTeam(i) == TEAM_INFECTED) InfectedRoundsPlayed[i]++;
			IdleCounter[i] = 0;
		}
	}

	if (NumRounds >= 2) {

		mapcounter++;
		if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) TeamAssignmentCheck(false);
	}
}

public GetTeamPlayers(team)
{
	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == team) count++;
	}
	return count;
}

stock SendPanelToClientAndClose(Handle:panel, client, MenuHandler:handler, time)
{
	SendPanelToClient(panel, client, handler, time);
	CloseHandle(panel);
}

public GetCampaignScore(team)
{
	new score = 0;
	for (new i = 0; i <= mapcounter; i++)
	{
		if (MapScores[i][team] < 0) MapScores[i][team] *= -1;
		if (MapScores[i][team] > 400) MapScores[i][team] = 400;
		score += MapScores[i][team];
	}
	return score;
}

public CalculateSurvivorScores()
{
	new Float:FlowPercent = GetSurvivorTeamDistance();
	FlowPercent *= 400.0;

	new bFlipped = GameRules_GetProp("m_bAreTeamsFlipped");
	MapScores[mapcounter][bFlipped] += RoundToFloor(FlowPercent);
}

public Float:GetSurvivorTeamDistance()
{
	new Float:value = 0.0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientHuman(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		value += (L4D2Direct_GetFlowDistance(i) / L4D2Direct_GetMapMaxFlowDistance());
	}
	value /= HumanSurvivorCount();

	return value;
}