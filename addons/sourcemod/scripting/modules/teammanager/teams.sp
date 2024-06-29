stock TM_GetCampaignScore(value)
{
	new count = 0;
	for (new i = 0; i <= mapcounter; i++)
	{
		count += MapScores[i][value];
	}
	return count;
}

public Handle:Top10Players (client)
{
	new Handle:menu = CreatePanel();
	new String:text[32 + MAX_NAME_LENGTH];
	Format(text, sizeof(text), "Top 10 Players Menu", client);
	SetPanelTitle(menu, text);

	for (new i = 0; i <= 9; i++)
	{
		Format(text, sizeof(text), "%d.) %s", i + 1, TopRankedPlayers[i]);
		DrawPanelText(menu, text);
	}
	Format(text, sizeof(text), "%T", "Previous Page", client);
	DrawPanelItem(menu, text);

	return menu;
}

public Top10Players_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClientAndClose(TeamManagerMenu(client), client, TeamManagerMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:TeamManagerMenu (client)
{
	new Handle:menu = CreatePanel();
	decl String:text[512];
	Format(text, sizeof(text), "%T", "menu title", client);
	SetPanelTitle(menu, text);

	new count			=	GetTeamPlayers(TEAM_SPECTATOR);
	Format(text, sizeof(text), "%T", "spectator team", client, count);
	DrawPanelItem(menu, text);
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SPECTATOR) {

			Format(text, sizeof(text), "(s) %N", i);
			DrawPanelText(menu, text);
		}
	}
	count				=	GetTeamPlayers(TEAM_SURVIVOR);
	Format(text, sizeof(text), "%T", "survivor team", client, count);
	DrawPanelItem(menu, text);
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (IsPlayerAlive(i) && !IsIncapacitated(i)) Format(text, sizeof(text), "(a) %N", i);
			else if (IsPlayerAlive(i) && IsIncapacitated(i)) Format(text, sizeof(text), "(i) %N", i);
			else Format(text, sizeof(text), "(d) %N", i);
			DrawPanelText(menu, text);
		}
	}
	if (ReadyUp_GetGameMode() == 2) {

		count			=	GetTeamPlayers(TEAM_INFECTED);
		Format(text, sizeof(text), "%T", "infected team", client, count);
		DrawPanelItem(menu, text);
		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) {

				if (IsPlayerAlive(i) && !IsGhost(i)) Format(text, sizeof(text), "(a) %N", i);
				else if (IsPlayerAlive(i) && IsGhost(i)) Format(text, sizeof(text), "(g) %N", i);
				else Format(text, sizeof(text), "(d) %N", i);
				DrawPanelText(menu, text);
			}
		}
	}

	Format(text, sizeof(text), "%T", "View Server Rankings", client);
	DrawPanelItem(menu, text);

	return menu;
}

public TeamManagerMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1: {

				if (GetClientTeam(client) != TEAM_SPECTATOR) {

					//IsNotHere[client] = true;
					//ReadyUp_NtvChangeTeam(client, TEAM_SPECTATOR);

					//if (HasCommandAccessEx(client, "a") || HasCommandAccessEx(client, "k") || HasCommandAccessEx(client, "z")) {

					IsNotHere[client] = true;
					ReadyUp_NtvChangeTeam(client, TEAM_SPECTATOR);
					//}
					/*else {

						PrintToChat(client, "%T", "reserved for admins", client, green, white, orange);
						SendPanelToClientAndClose(TeamManagerMenu(client), client, TeamManagerMenu_Init, MENU_TIME_FOREVER);
					}*/
				}
			}
			case 2: {

				if (GetClientTeam(client) != TEAM_SURVIVOR) {

					IsNotHere[client] = false;
					SelectTargetTeam(client, TEAM_SURVIVOR);
				}
			}
			case 3: {

				if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) {

					if (GetClientTeam(client) != TEAM_INFECTED) {

						IsNotHere[client] = false;
						SelectTargetTeam(client, TEAM_INFECTED);
					}
				}
				else {

					if (!bLoadAttempted[client]) {

						bLoadAttempted[client] = true;
						LoadPlayerData(client);
					}
					SendPanelToClientAndClose(TeamManagerRankings(client), client, TeamManagerRankings_Init, MENU_TIME_FOREVER);
				}
			}
			case 4:
			{
				if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) {

					if (!bLoadAttempted[client])
					{
						bLoadAttempted[client] = true;
						LoadPlayerData(client);
					}
					SendPanelToClientAndClose(TeamManagerRankings(client), client, TeamManagerRankings_Init, MENU_TIME_FOREVER);
				}
			}
		}
	}
	if (topmenu != INVALID_HANDLE)
	{
		CloseHandle(topmenu);
	}
}

public Handle:TeamManagerRankings (client)
{
	new Handle:menu = CreatePanel();
	new String:pct[32];
	Format(pct, sizeof(pct), "%");
	new String:text[512];
	Format(text, sizeof(text), "%T", "menu title", client);
	SetPanelTitle(menu, text);
	decl String:formattedString[4][64];

	Format(text, sizeof(text), "___________");
	DrawPanelText(menu, text);
	AddCommasToString(CommonKills[client], formattedString[0], sizeof(formattedString[]));
	AddCommasToString(CommonKillsAverage[client], formattedString[1], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Common Kills Rank", client, formattedString[0], formattedString[1], CommonRank[client], CommonKillsAverageRank[client]);
	DrawPanelText(menu, text);

	AddCommasToString(SpecialKills[client], formattedString[0], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Special Kills Rank", client, formattedString[0], SpecialRank[client]);
	DrawPanelText(menu, text);

	AddCommasToString(SurvivorDamage[client], formattedString[0], sizeof(formattedString[]));
	AddCommasToString(SurvivorDamageAverage[client], formattedString[1], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Survivor Damage Rank", client, formattedString[0], formattedString[1], SurvivorDamageRank[client], SurvivorDamageAverageRank[client]);
	DrawPanelText(menu, text);

	AddCommasToString(Rescues[client], formattedString[0], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Survivor Rescues Rank", client, formattedString[0]);
	DrawPanelText(menu, text);

	AddCommasToString(SurvivorIncaps[client], formattedString[0], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Survivor Incaps Rank", client, formattedString[0]);
	DrawPanelText(menu, text);

	AddCommasToString(InfectedDamage[client], formattedString[0], sizeof(formattedString[]));
	AddCommasToString(InfectedDamageAverage[client], formattedString[1], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Infected Damage Rank", client, formattedString[0], formattedString[1], InfectedDamageRank[client], InfectedDamageAverageRank[client]);
	DrawPanelText(menu, text);

	AddCommasToString(InfectedIncaps[client], formattedString[0], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Infected Incaps Rank", client, formattedString[0]);
	DrawPanelText(menu, text);

	AddCommasToString(SurvivorDamageTaken[client], formattedString[0], sizeof(formattedString[]));
	AddCommasToString(SurvivorDamageTakenRank[client], formattedString[1], sizeof(formattedString[]));
	AddCommasToString(SurvivorDamageTakenAverage[client], formattedString[2], sizeof(formattedString[]));
	AddCommasToString(SurvivorDamageTakenAverageRank[client], formattedString[3], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Survivor Damage Taken Rank", client, formattedString[0], formattedString[1], formattedString[2], formattedString[3]);
	DrawPanelText(menu, text);

	AddCommasToString(InfectedDamageTaken[client], formattedString[0], sizeof(formattedString[]));
	AddCommasToString(InfectedDamageTakenRank[client], formattedString[1], sizeof(formattedString[]));
	AddCommasToString(InfectedDamageTakenAverage[client], formattedString[2], sizeof(formattedString[]));
	AddCommasToString(InfectedDamageTakenAverageRank[client], formattedString[3], sizeof(formattedString[]));
	Format(text, sizeof(text), "%T", "Infected Damage Taken Rank", client, formattedString[0], formattedString[1], formattedString[2], formattedString[3]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "%T", "Rank Display", client, Rank[client], RankMaximum);
	DrawPanelText(menu, text);

	Format(text, sizeof(text), "%T", "Previous Page", client);
	DrawPanelItem(menu, text);

	return menu;
}

public TeamManagerRankings_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClientAndClose(TeamManagerMenu(client), client, TeamManagerMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
	if (topmenu != INVALID_HANDLE)
	{
		CloseHandle(topmenu);
	}
}

public GetTop10()
{
	decl String:TQuery[1024];
	Format(TQuery, sizeof(TQuery), "SELECT `Name` FROM `rankings` ORDER BY `RankAvg` ASC LIMIT 10;");
	SQL_TQuery(hDatabase, GetTop10Query, TQuery);
}

public GetClientRank(client)
{
	decl String:TQuery[1024];
	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings`");
	SQL_TQuery(hDatabase, SendRankMaximumQuery, TQuery);

	if (SurvivorRoundsPlayed[client] > 0)
	{
		if (CommonKills[client] > 0) CommonKillsAverage[client] = CommonKills[client] / SurvivorRoundsPlayed[client];
		if (SurvivorDamage[client] > 0) SurvivorDamageAverage[client] = SurvivorDamage[client] / SurvivorRoundsPlayed[client];
	}
	if (InfectedRoundsPlayed[client] > 0)
	{
		if (InfectedDamage[client] > 0) InfectedDamageAverage[client] = InfectedDamage[client] / InfectedRoundsPlayed[client];
	}
	
	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`CK` > '%i');", CommonKills[client]);
	SQL_TQuery(hDatabase, SendCommonsQuery, TQuery, client);
	if (CommonKillsAverage[client] > 0)
	{
		Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`CKA` > '%i');", CommonKillsAverage[client]);
		SQL_TQuery(hDatabase, SendCommonsAverageQuery, TQuery, client);
	}
	else CommonKillsAverageRank[client] = RankMaximum;

	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`SK` > '%i');", SpecialKills[client]);
	SQL_TQuery(hDatabase, SendSpecialQuery, TQuery, client);

	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`SD` > '%i');", SurvivorDamage[client]);
	SQL_TQuery(hDatabase, SendSDamageQuery, TQuery, client);
	if (SurvivorDamageAverage[client] > 0)
	{
		Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`SDA` > '%i');", SurvivorDamageAverage[client]);
		SQL_TQuery(hDatabase, SendSDamageAverageQuery, TQuery, client);
	}
	else SurvivorDamageAverageRank[client] = RankMaximum;
	
	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`ID` > '%i');", InfectedDamage[client]);
	SQL_TQuery(hDatabase, SendIDamageQuery, TQuery, client);
	if (InfectedDamageAverage[client] > 0)
	{
		Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`IDA` > '%i');", InfectedDamageAverage[client]);
		SQL_TQuery(hDatabase, SendIDamageAverageQuery, TQuery, client);
	}
	else InfectedDamageAverageRank[client] = RankMaximum;

	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`SDT` > '%i');", SurvivorDamageTaken[client]);
	SQL_TQuery(hDatabase, SurvivorSendDamageTakenQuery, TQuery, client);
	if (SurvivorDamageTakenAverage[client] > 0)
	{
		Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`SDTA` > '%i');", SurvivorDamageTakenAverage[client]);
		SQL_TQuery(hDatabase, SurvivorSendDamageTakenQueryAverage, TQuery, client);
	}
	else SurvivorDamageTakenAverageRank[client] = RankMaximum;

	Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`IDT` > '%i');", InfectedDamageTaken[client]);
	SQL_TQuery(hDatabase, InfectedSendDamageTakenQuery, TQuery, client);
	if (InfectedDamageTakenAverage[client] > 0)
	{
		Format(TQuery, sizeof(TQuery), "SELECT COUNT(*) FROM `rankings` WHERE (`IDTA` > '%i');", InfectedDamageTakenAverage[client]);
		SQL_TQuery(hDatabase, InfectedSendDamageTakenQueryAverage, TQuery, client);
	}
	else InfectedDamageTakenAverageRank[client] = RankMaximum;

	Rank[client] = (CommonRank[client] + SpecialRank[client] + SurvivorDamageRank[client] + InfectedDamageRank[client] +
	CommonKillsAverageRank[client] + SurvivorDamageAverageRank[client] + InfectedDamageAverageRank[client] +
	SurvivorDamageTakenAverageRank[client] + InfectedDamageTakenAverageRank[client] + SurvivorDamageTakenRank[client] + InfectedDamageTakenRank[client]) / 11;

	if (Rank[client] < 1) Rank[client] = RankMaximum;
}

public FindHumanCount()
{
	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i)) count++;
	}
	return count;
}

stock SelectTargetTeam(client, TeamNumber) {

	if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) {

		if (TeamNumber == TEAM_SURVIVOR && GetPlayerCount(TEAM_SURVIVOR) <= GetPlayerCount(TEAM_INFECTED)) ReadyUp_NtvChangeTeam(client, TEAM_SURVIVOR);
		else if (TeamNumber == TEAM_SURVIVOR && GetPlayerCount(TEAM_SURVIVOR) > GetPlayerCount(TEAM_INFECTED) && GetClientTeam(client) != TEAM_INFECTED) ReadyUp_NtvChangeTeam(client, TEAM_INFECTED);
		else if (TeamNumber == TEAM_INFECTED && GetPlayerCount(TEAM_INFECTED) <= GetPlayerCount(TEAM_SURVIVOR)) ReadyUp_NtvChangeTeam(client, TEAM_INFECTED);
		else if (TeamNumber == TEAM_INFECTED && GetPlayerCount(TEAM_INFECTED) > GetPlayerCount(TEAM_SURVIVOR) && GetClientTeam(client) != TEAM_SURVIVOR) ReadyUp_NtvChangeTeam(client, TEAM_SURVIVOR);
	}
	else if (GetClientTeam(client) != TeamNumber && GetClientTeam(client) == TEAM_SPECTATOR) ReadyUp_NtvChangeTeam(client, TEAM_SURVIVOR);
}

stock GetPlayerCount(TeamNumber) {

	new count = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TeamNumber) count++;
	}

	return count;
}

stock IsTeamCountUnbalanced(bool:IsLessPlayers)
{
	if (GetTeamPlayers(TEAM_INFECTED) > GetTeamPlayers(TEAM_SURVIVOR) + 1)
	{
		if (!IsLessPlayers) return TEAM_INFECTED;
		else return TEAM_SURVIVOR;
	}
	else if (GetTeamPlayers(TEAM_INFECTED) + 1 < GetTeamPlayers(TEAM_SURVIVOR))
	{
		if (!IsLessPlayers) return TEAM_SURVIVOR;
		else return TEAM_INFECTED;
	}
	return 0;
}

stock FindPlayerNewTeam(client) {

	new TeamNumber = 0;
	if (GetPlayerCount(TEAM_INFECTED) == GetPlayerCount(TEAM_SURVIVOR)) {

		TeamNumber = GetRandomInt(1, 100);
		if (TeamNumber <= 50) TeamNumber = 2;
		else TeamNumber = 3;
	}
	else if (GetPlayerCount(TEAM_INFECTED) > GetPlayerCount(TEAM_SURVIVOR)) TeamNumber = TEAM_SURVIVOR;
	else TeamNumber = TEAM_INFECTED;

	if (GetClientTeam(client) != TeamNumber) ReadyUp_NtvChangeTeam(client, TeamNumber);
}

stock bool:IsValidTeamPlayers(TeamNumber)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TeamNumber && (TeamNumber == 2 || FindZombieClass(i) != ZOMBIECLASS_TANK)) return true;
	}
	return false;
}

stock bool:IsValidTeamPlayersAtRank(TeamNumber, value)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TeamNumber && (TeamNumber == 2 || FindZombieClass(i) != ZOMBIECLASS_TANK) && Rank[i] == value) return true;
	}
	return false;
}

stock bool:AnyHumanPlayers()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) return true;
	}
	return false;
}

public Action:Timer_SetSurvivorModel(Handle:timer, any:client)
{
	if (IsClientHuman(client)) FindAndSetSurvivorModel(client);
	return Plugin_Stop;
}

stock FindAndSetSurvivorModel(client)
{
	new String:Model[512];
	if (GetModelCount(client, NICK_MODEL) < 1) Format(Model, sizeof(Model), "%s", NICK_MODEL);
	else if (GetModelCount(client, ROCHELLE_MODEL) < 1) Format(Model, sizeof(Model), "%s", ROCHELLE_MODEL);
	else if (GetModelCount(client, COACH_MODEL) < 1) Format(Model, sizeof(Model), "%s", COACH_MODEL);
	else if (GetModelCount(client, ELLIS_MODEL) < 1) Format(Model, sizeof(Model), "%s", ELLIS_MODEL);
	else if (GetModelCount(client, BILL_MODEL) < 1) Format(Model, sizeof(Model), "%s", BILL_MODEL);
	else if (GetModelCount(client, ZOEY_MODEL) < 1) Format(Model, sizeof(Model), "%s", ZOEY_MODEL);
	else if (GetModelCount(client, FRANCIS_MODEL) < 1) Format(Model, sizeof(Model), "%s", FRANCIS_MODEL);
	else if (GetModelCount(client, LOUIS_MODEL) < 1) Format(Model, sizeof(Model), "%s", LOUIS_MODEL);
	else if (GetModelCount(client, NICK_MODEL) < 2) Format(Model, sizeof(Model), "%s", NICK_MODEL);
	else if (GetModelCount(client, ROCHELLE_MODEL) < 2) Format(Model, sizeof(Model), "%s", ROCHELLE_MODEL);
	else if (GetModelCount(client, COACH_MODEL) < 2) Format(Model, sizeof(Model), "%s", COACH_MODEL);
	else if (GetModelCount(client, ELLIS_MODEL) < 2) Format(Model, sizeof(Model), "%s", ELLIS_MODEL);
	else if (GetModelCount(client, BILL_MODEL) < 2) Format(Model, sizeof(Model), "%s", BILL_MODEL);
	else if (GetModelCount(client, ZOEY_MODEL) < 2) Format(Model, sizeof(Model), "%s", ZOEY_MODEL);
	else if (GetModelCount(client, FRANCIS_MODEL) < 2) Format(Model, sizeof(Model), "%s", FRANCIS_MODEL);
	else if (GetModelCount(client, LOUIS_MODEL) < 2) Format(Model, sizeof(Model), "%s", LOUIS_MODEL);
	else
	{
		new number	=	GetRandomInt(1, 8);
		if (number == 1) Format(Model, sizeof(Model), "%s", NICK_MODEL);
		else if (number == 2) Format(Model, sizeof(Model), "%s", ROCHELLE_MODEL);
		else if (number == 3) Format(Model, sizeof(Model), "%s", COACH_MODEL);
		else if (number == 4) Format(Model, sizeof(Model), "%s", ELLIS_MODEL);
		else if (number == 5) Format(Model, sizeof(Model), "%s", BILL_MODEL);
		else if (number == 6) Format(Model, sizeof(Model), "%s", ZOEY_MODEL);
		else if (number == 7) Format(Model, sizeof(Model), "%s", FRANCIS_MODEL);
		else if (number == 8) Format(Model, sizeof(Model), "%s", LOUIS_MODEL);
	}
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

stock GetModelCount(client, String:Model[])
{
	new count = 0;
	new String:TModel[512];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientActual(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR)
		{
			GetClientModel(i, TModel, sizeof(TModel));
			if (StrEqual(TModel, Model)) count++;
		}
	}
	return count;
}

public TeamAssignmentCheck(bool:b_IsNewMap) {

	if (ReadyUp_GetGameMode() != GAMEMODE_VERSUS) return;
	new bool:b_IsFlipped = false;
	if (GameRules_GetProp("m_bAreTeamsFlipped")) b_IsFlipped = true;

	if (b_IsNewMap) {

		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && !IsNotHere[i]) {

				if (TM_GetCampaignScore(0) != TM_GetCampaignScore(1)) {

					if (Team[i] != TM_GetCampaignScore(1) && Team[i] != TM_GetCampaignScore(0)) {

						Team[i] = 0;
						continue;
					}
					if (!b_IsFlipped && Team[i] == TM_GetCampaignScore(0) || b_IsFlipped && Team[i] == TM_GetCampaignScore(1)) Team[i] = TEAM_SURVIVOR;
					else Team[i] = TEAM_INFECTED;
				}
				if (GetClientTeam(i) == TEAM_SURVIVOR && Team[i] == TEAM_INFECTED || GetClientTeam(i) == TEAM_INFECTED && Team[i] == TEAM_SURVIVOR) ReadyUp_NtvChangeTeam(i, TEAM_SPECTATOR);
				else Team[i] = 0;
			}
		}
		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && Team[i] != 0) CreateTimer(0.2, Timer_TeamCorrection, i, TIMER_FLAG_NO_MAPCHANGE);
		}
		if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) AutoTeamBalancer();
	}
	else {

		for (new i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i)) {

				if (GetClientTeam(i) == TEAM_SPECTATOR) {

					Team[i] = -1;
					IsNotHere[i] = true;
					continue;
				}
				IsNotHere[i] = false;
				if (TM_GetCampaignScore(0) != TM_GetCampaignScore(1)) {

					if (GetClientTeam(i) == TEAM_SURVIVOR && !b_IsFlipped) Team[i] = TM_GetCampaignScore(0);
					else if (GetClientTeam(i) == TEAM_SURVIVOR && b_IsFlipped) Team[i] = TM_GetCampaignScore(1);
					else if (GetClientTeam(i) == TEAM_INFECTED && !b_IsFlipped) Team[i] = TM_GetCampaignScore(1);
					else if (GetClientTeam(i) == TEAM_INFECTED && b_IsFlipped) Team[i] = TM_GetCampaignScore(0);
				}
				else {

					if (GetClientTeam(i) == TEAM_SURVIVOR) Team[i] = TEAM_SURVIVOR;
					else if (GetClientTeam(i) == TEAM_INFECTED) Team[i] = TEAM_INFECTED;
				}
			}
		}
	}
}

public Action:Timer_TeamCorrection(Handle:timer, any:client) {

	if (IsClientInGame(client) && !IsFakeClient(client)) {

		if (Team[client] == TEAM_SURVIVOR) ReadyUp_NtvChangeTeam(client, TEAM_SURVIVOR);
		else if (Team[client] == TEAM_INFECTED) ReadyUp_NtvChangeTeam(client, TEAM_INFECTED);
	}

	return Plugin_Stop;
}

public Action:CMD_SwapPlayer(client, args)
{
	if (args < 2)
	{
		PrintToChat(client, "[STK] Usage: !swap (player | userid) (team no)");
		return Plugin_Handled;
	}
	decl String:arg[MAX_NAME_LENGTH], String:arg2[4];
	GetCmdArg(1, arg, sizeof(arg));
	if (args > 1)
	{
		GetCmdArg(2, arg2, sizeof(arg2));
	}
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	new targetclient;
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) > 0)
	{
		for (new i = 0; i < target_count; i++) targetclient = target_list[i];
		decl String:Name[MAX_NAME_LENGTH];
		GetClientName(targetclient, Name, sizeof(Name));
		if (StringToInt(arg2) == 2)
		{
			if (IsClientHuman(client))
			{
				IsNotHere[targetclient] = false;
				ReadyUp_NtvChangeTeam(targetclient, TEAM_SURVIVOR);
			}
		}
		else if (StringToInt(arg2) == 3)
		{
			IsNotHere[targetclient] = false;
			if (IsClientHuman(client)) ReadyUp_NtvChangeTeam(targetclient, TEAM_INFECTED);
		}
		else if (StringToInt(arg2) == 1)
		{
			IsNotHere[targetclient] = true;
			if (IsClientHuman(client)) ReadyUp_NtvChangeTeam(targetclient, TEAM_SPECTATOR);
		}
		if (StringToInt(arg2) >= 1 && StringToInt(arg2) <= 3) IsNotHere[targetclient] = false;
	}
	return Plugin_Handled;
}

stock AddCommasToString(value, String:theString[], theSize) 
{
	decl String:buffer[64];
	decl String:separator[1];
	separator = ",";
	buffer[0] = '\0'; 
	new divisor = 1000; 
	new offcut = 0;
	
	while (value >= 1000 || value <= -1000)
	{
		offcut = value % divisor;
		value = RoundToFloor(float(value) / float(divisor));
		Format(buffer, sizeof(buffer), "%s%03.d%s", separator, offcut, buffer); 
	}
	
	Format(theString, theSize, "%d%s", value, buffer);
}

stock bool:IsLegitimateClient(client) {

	if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) return false;
	return true;
}

stock bool:IsLegitimateClientAlive(client) {

	if (IsLegitimateClient(client) && IsPlayerAlive(client)) return true;
	return false;
}