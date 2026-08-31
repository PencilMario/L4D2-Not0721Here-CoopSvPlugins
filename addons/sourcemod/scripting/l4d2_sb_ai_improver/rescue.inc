bool CheckIfCanRescueImmobilizedFriend(int iClient)
{
	if (IsSurvivorBotBlindedByVomit(iClient))
		return false;

	if (!L4D_IsPlayerIncapacitated(iClient))
	{
		if (g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.33))
			return false;

		if (IsSurvivorBusy(iClient))
			return false;
	}

	return true;
}

void ResetPinnedReactionCaches()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_fPinnedReactionCache_Expiry[i] = 0.0;
		SetVectorToZero(g_fPinnedReactionCache_Position[i]);
		for (int j = 1; j <= MaxClients; j++)
			g_iPinnedReactionRank[i][j] = 0;
	}
}

void BuildPinnedReactionRanks(int iPinnedFriend)
{
	int iBots[MAXPLAYERS+1];
	float fDistances[MAXPLAYERS+1];
	int iCount;

	for (int i = 1; i <= MaxClients; i++)
		g_iPinnedReactionRank[iPinnedFriend][i] = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iPinnedFriend || !IsClientSurvivor(i) || !IsFakeClient(i))
			continue;

		iBots[iCount] = i;
		fDistances[iCount] = GetVectorDistance(g_fClientAbsOrigin[i], g_fClientAbsOrigin[iPinnedFriend], true);
		iCount++;
	}

	for (int i = 1; i < iCount; i++)
	{
		int iBot = iBots[i];
		float fDistance = fDistances[i];
		int j = i - 1;
		while (j >= 0 && (fDistance < fDistances[j] || fDistance == fDistances[j] && iBot < iBots[j]))
		{
			iBots[j + 1] = iBots[j];
			fDistances[j + 1] = fDistances[j];
			j--;
		}
		iBots[j + 1] = iBot;
		fDistances[j + 1] = fDistance;
	}

	for (int i = 0; i < iCount; i++)
		g_iPinnedReactionRank[iPinnedFriend][iBots[i]] = i + 1;

	g_fPinnedReactionCache_Position[iPinnedFriend] = g_fClientAbsOrigin[iPinnedFriend];
	g_fPinnedReactionCache_Expiry[iPinnedFriend] = GetProcessCacheExpiry();
}

bool IsPinnedFriendReactionAllowed(int iClient, int iPinnedFriend)
{
	if (g_iCvar_HelpPinnedFriend_ReactionBots <= 0 || !IsClientSurvivor(iClient) || !IsFakeClient(iClient) || !IsValidClient(iPinnedFriend))
		return false;

	float fNow = GetGameTime();
	if (fNow >= g_fPinnedReactionCache_Expiry[iPinnedFriend]
		|| GetVectorDistance(g_fPinnedReactionCache_Position[iPinnedFriend], g_fClientAbsOrigin[iPinnedFriend], true) > GetNavigationCachePositionTolerance())
		BuildPinnedReactionRanks(iPinnedFriend);

	int iRank = g_iPinnedReactionRank[iPinnedFriend][iClient];
	return (iRank > 0 && iRank <= g_iCvar_HelpPinnedFriend_ReactionBots);
}

void BotLookAtPosition(int iClient, float fLookPos[3], float fLookDuration = 0.33)
{
	g_fSurvivorBot_LookPosition[iClient] = fLookPos;
	g_fSurvivorBot_LookPosition_Duration[iClient] = GetGameTime() + fLookDuration;
}

bool IsUsingSpecialAbility(int iClient)
{
	if (!IsSpecialInfected(iClient))
		return false;

	int iAbilityEntity = L4D_GetPlayerCustomAbility(iClient);
	if (iAbilityEntity == -1)return false;

	static char sProperty[16];
	switch(L4D2_GetPlayerZombieClass(iClient))
	{
		case L4D2ZombieClass_Boomer: 	sProperty = "m_isSpraying";
		case L4D2ZombieClass_Hunter: 	sProperty = "m_isLunging";
		case L4D2ZombieClass_Jockey: 	sProperty = "m_isLeaping";
		case L4D2ZombieClass_Charger: 	sProperty = "m_isCharging";
		case L4D2ZombieClass_Smoker: 	sProperty = "m_tongueState";
		default: 						return false;
	}

	if (!HasEntProp(iAbilityEntity, Prop_Send, sProperty))
		return false;

	return (GetEntProp(iAbilityEntity, Prop_Send, sProperty) > 0);
}
