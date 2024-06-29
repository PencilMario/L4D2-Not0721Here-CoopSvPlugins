public ReadyUp_IsClientLoaded(client) {

	if (IsNotHere[client] && GetClientTeam(client) != TEAM_SPECTATOR) ReadyUp_NtvChangeTeam(client, TEAM_SPECTATOR);
	else if (ReadyUp_GetGameMode() == GAMEMODE_VERSUS) {

		if (Team[client] == 0) FindPlayerNewTeam(client);
		else {

			new bool:b_IsFlipped = false;
			if (GameRules_GetProp("m_bAreTeamsFlipped")) b_IsFlipped = true;

			if (TM_GetCampaignScore(0) != TM_GetCampaignScore(1)) {

				if (!b_IsFlipped && Team[client] == TM_GetCampaignScore(0) || b_IsFlipped && Team[client] == TM_GetCampaignScore(1)) {

					if (GetClientTeam(client) != TEAM_SURVIVOR) ReadyUp_NtvChangeTeam(client, TEAM_SURVIVOR);
				}
				else if (GetClientTeam(client) != TEAM_INFECTED) ReadyUp_NtvChangeTeam(client, TEAM_INFECTED);
			}
			else if (Team[client] > 0 && GetClientTeam(client) != Team[client]) ReadyUp_NtvChangeTeam(client, Team[client]);
		}
	}
	//else if (ReadyUp_GetGameMode() != GAMEMODE_VERSUS) CreateTimer(1.0, Timer_SetSurvivorModel, client, TIMER_FLAG_NO_MAPCHANGE);
	if (!bIsConnected[client]) {

		bIsConnected[client] = true;
		CreateTimer(1.0, Timer_SetSurvivorModel, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	IdleCounter[client] = 0;
}

public ReadyUp_TrueDisconnect(client) {

	IsNotHere[client] = false;
	Team[client] = 0;
	bIsConnected[client] = false;

	if (!bRoundOver)
	{
		CheckTeams(client);	// so we know whether the teams need to be balanced or not.
		if (GetClientTeam(client) == TEAM_SURVIVOR) SurvivorRoundsPlayed[client]++;
		else if (GetClientTeam(client) == TEAM_INFECTED) InfectedRoundsPlayed[client]++;
	}
	IdleCounter[client] = 0;

	bLoadAttempted[client] = false;
	SavePlayerData(client);
}

stock AutoTeamBalancer()
{
	if (ReadyUp_GetGameMode() != GAMEMODE_VERSUS) return;
	new TargetTeam = IsTeamCountUnbalanced(true);
	new IgnoreTeam = IsTeamCountUnbalanced(false);
	if (IgnoreTeam > 0)	// This value is only 0 if the teams are even, or it is not possible to give each team an even number of players.
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsLegitimateClient(i) && !IsFakeClient(i)) GetClientRank(i);
		}

		new RankLowPosition			= 0;
		new RankHighPosition		= RankMaximum;

		new RankPosition			=	0;

		if (bTeamsFlipped && TargetTeam == TEAM_SURVIVOR ||
			!bTeamsFlipped && TargetTeam == TEAM_INFECTED)
		{
			if (TM_GetCampaignScore(1) >= TM_GetCampaignScore(0)) RankPosition = RankHighPosition;
			else RankPosition = RankLowPosition;
		}
		else if (bTeamsFlipped && TargetTeam == TEAM_INFECTED ||
			!bTeamsFlipped && TargetTeam == TEAM_SURVIVOR)
		{
			if (TM_GetCampaignScore(0) >= TM_GetCampaignScore(1)) RankPosition = RankHighPosition;
			else RankPosition = RankLowPosition;
		}

		new client	=	-1;
		while (client == -1 && IsValidTeamPlayers(IgnoreTeam))
		{
			while (IsValidTeamPlayersAtRank(IgnoreTeam, RankPosition))
			{
				client	=	GetRandomInt(1, MaxClients);
				if (!IsClientHuman(client) || GetClientTeam(client) == TargetTeam || Rank[client] != RankPosition || (IgnoreTeam == 3 && FindZombieClass(client) == ZOMBIECLASS_TANK)) client = -1;
				else
				{
					// we show a message on-screen, since otherwise the player wouldn't see it.
					ReadyUp_NtvChangeTeam(client, TargetTeam);
					new String:Name[512];
					GetClientName(client, Name, sizeof(Name));
					if (TargetTeam == TEAM_SURVIVOR) PrintToChatAll("%t", "Player Forced Survivor Team", white, blue, Name, green);
					else PrintToChatAll("%t", "Player Forced Infected Team", white, orange, Name, green);
				}
			}
			if (bTeamsFlipped && TargetTeam == TEAM_SURVIVOR ||
			!bTeamsFlipped && TargetTeam == TEAM_INFECTED)
			{
				if (TM_GetCampaignScore(1) >= TM_GetCampaignScore(0)) RankPosition--;
				else RankPosition++;
			}
			else if (bTeamsFlipped && TargetTeam == TEAM_INFECTED ||
				!bTeamsFlipped && TargetTeam == TEAM_SURVIVOR)
			{
				if (TM_GetCampaignScore(0) >= TM_GetCampaignScore(1)) RankPosition--;
				else RankPosition++;
			}
		}
	}
}