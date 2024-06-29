stock ResetScramble()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i)) bAssigned[i] = false;
	}
}

stock FindValidPlayers()
{
	new count = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i)) {

			if (!HasCommandAccessEx(i, "a")) IsNotHere[i] = false;
			if (IsNotHere[i])
			{
				bAssigned[i] = true;
				if (GetClientTeam(i) != TEAM_SPECTATOR) ReadyUp_NtvChangeTeam(i, TEAM_SPECTATOR);
			}
			if (bAssigned[i] || IsNotHere[i]) continue;
			count++;
		}
	}
	return count;
}

stock PlayersRemaining()
{
	new count = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i)) {

			if (bAssigned[i] || IsNotHere[i]) continue;
			count++;
			bAssigned[i] = false;
		}
	}
	return count;
}

stock FindPlayersRank(RankPosition)
{
	new count = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsLegitimateClient(i) || IsFakeClient(i) || bAssigned[i] || IsNotHere[i] || Rank[i] != RankPosition) continue;
		count++;
	}
	return count;
}

public Scramble(bool:SmartMode)
{
	ResetScramble();
	//new validplayers = FindValidPlayers();

	PrintToChatAll("%t", "Team Scramble", white, blue);

	ResetCampaignScores();

	/*
	//		Don't need to get client ranks anymore, as they're loaded when each player data loads
	//		and only once per round.
																																		*/
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i)) GetClientRank(i);
	}
	CreateTimer(1.0, Timer_SmartScramble, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_SmartScramble(Handle:timer)
{
	static count		=	0;

	count++;
	PrintHintTextToAll("%t", "Smart Scramble Countdown", 5 - count);
	if (count >= 5)
	{
		new RankLowPosition			= 0;
		new RankHighPosition		= RankMaximum;
		new RankPosition			= GetRandomInt(1, 2);
		new AssignCount			= GetRandomInt(2, 3);
		if (RankPosition == 1)		RankPosition = RankLowPosition;
		else						RankPosition = RankHighPosition;
		while (FindValidPlayers() > 0)
		{
			while (FindValidPlayers() > 0 && FindPlayersRank(RankPosition) > 0)
			{
				new client = GetRandomInt(1, MaxClients);

				if (IsLegitimateClient(client) && !IsFakeClient(client) && !bAssigned[client] && !IsNotHere[client] && Rank[client] == RankPosition)
				{
					bAssigned[client] = true;
					if (AssignCount == TEAM_SURVIVOR)
					{
						ReadyUp_NtvChangeTeam(client, TEAM_SURVIVOR);
						AssignCount = TEAM_INFECTED;
					}
					else
					{
						ReadyUp_NtvChangeTeam(client, TEAM_INFECTED);
						AssignCount = TEAM_SURVIVOR;
					}
				}
			}
			if (RankPosition == RankLowPosition)
			{
				RankPosition = RankHighPosition;
				RankLowPosition++;
			}
			else if (RankPosition == RankHighPosition)
			{
				RankPosition = RankLowPosition;
				RankHighPosition--;
			}
		}
		count = 0;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}