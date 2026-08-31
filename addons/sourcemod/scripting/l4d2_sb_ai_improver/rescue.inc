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
	g_bPinnedRescueRecoveryPending = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		g_fPinnedReactionCache_Expiry[i] = 0.0;
		SetVectorToZero(g_fPinnedReactionCache_Position[i]);
		g_iPinnedRescueAttacker[i] = 0;
		g_iPinnedRescueClass[i] = L4D2ZombieClass_NotInfected;
		g_bPinnedRescueActive[i] = false;
		g_iSurvivorBot_RescueVictim[i] = 0;
		g_iSurvivorBot_RescueAttacker[i] = 0;
		g_fSurvivorBot_NextPinnedRescueThinkTime[i] = 0.0;
		for (int j = 1; j <= MaxClients; j++)
			g_iPinnedReactionRank[i][j] = 0;
	}
}

void ClearPinnedRescueVictimState(int iVictim)
{
	if (iVictim < 1 || iVictim > MaxClients)
		return;

	g_fPinnedReactionCache_Expiry[iVictim] = 0.0;
	SetVectorToZero(g_fPinnedReactionCache_Position[iVictim]);
	g_iPinnedRescueAttacker[iVictim] = 0;
	g_iPinnedRescueClass[iVictim] = L4D2ZombieClass_NotInfected;
	g_bPinnedRescueActive[iVictim] = false;
	for (int i = 1; i <= MaxClients; i++)
		g_iPinnedReactionRank[iVictim][i] = 0;
}

void BuildPinnedReactionRanks(int iPinnedFriend)
{
	if (!IsClientSurvivor(iPinnedFriend) || !g_bPinnedRescueActive[iPinnedFriend])
		return;

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

void RebuildPinnedRescueCoordinator()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSurvivorBot_RescueVictim[i] = 0;
		g_iSurvivorBot_RescueAttacker[i] = 0;
	}

	if (!ArePinnedRescueSnapshotsReady())
	{
		RequestPinnedRescueCoordinatorRecovery();
		return;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!g_bPinnedRescueActive[i])
		{
			for (int j = 1; j <= MaxClients; j++)
				g_iPinnedReactionRank[i][j] = 0;
			continue;
		}

		if (!IsClientSurvivor(i) || !IsValidClient(g_iPinnedRescueAttacker[i]) || !IsPlayerAlive(g_iPinnedRescueAttacker[i]))
		{
			ClearPinnedRescueVictimState(i);
			continue;
		}

		if (g_iCvar_HelpPinnedFriend_ReactionBots > 0)
			BuildPinnedReactionRanks(i);
		else
		{
			for (int j = 1; j <= MaxClients; j++)
				g_iPinnedReactionRank[i][j] = 0;
		}
	}

	if (g_iCvar_HelpPinnedFriend_ReactionBots <= 0)
		return;

	for (int iVictim = 1; iVictim <= MaxClients; iVictim++)
	{
		if (!g_bPinnedRescueActive[iVictim])
			continue;

		for (int iBot = 1; iBot <= MaxClients; iBot++)
		{
			if (g_iPinnedReactionRank[iVictim][iBot] <= 0 || g_iPinnedReactionRank[iVictim][iBot] > g_iCvar_HelpPinnedFriend_ReactionBots
				|| !IsClientSurvivor(iBot) || !IsFakeClient(iBot))
				continue;

			int iCurrentVictim = g_iSurvivorBot_RescueVictim[iBot];
			if (iCurrentVictim != 0)
			{
				float fNewDistance = GetVectorDistance(g_fClientAbsOrigin[iBot], g_fClientAbsOrigin[iVictim], true);
				float fCurrentDistance = GetVectorDistance(g_fClientAbsOrigin[iBot], g_fClientAbsOrigin[iCurrentVictim], true);
				if (fNewDistance > fCurrentDistance || fNewDistance == fCurrentDistance && iVictim > iCurrentVictim)
					continue;
			}

			g_iSurvivorBot_RescueVictim[iBot] = iVictim;
			g_iSurvivorBot_RescueAttacker[iBot] = g_iPinnedRescueAttacker[iVictim];
		}
	}

	float fNow = GetGameTime();
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_iSurvivorBot_RescueVictim[i] != 0)
			g_fSurvivorBot_PinnedReactTime[i] = fNow + GetRandomFloat(0.33, 0.66);
	}
}

bool ArePinnedRescueSnapshotsReady()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsPlayerAlive(i))
			continue;

		int iTeam = GetClientTeam(i);
		if (iTeam != 2 && iTeam != 3)
			continue;
		if (!g_bClientGlobalInfo_Ready[i])
			return false;
	}

	return true;
}

void RecoverPinnedRescueCoordinator()
{
	for (int iVictim = 1; iVictim <= MaxClients; iVictim++)
	{
		if (!IsClientSurvivor(iVictim))
		{
			if (g_bPinnedRescueActive[iVictim])
				ClearPinnedRescueVictimState(iVictim);
			continue;
		}

		int iAttacker = L4D_GetPinnedInfected(iVictim);
		if (!IsSpecialInfected(iAttacker))
		{
			if (g_bPinnedRescueActive[iVictim])
				ClearPinnedRescueVictimState(iVictim);
			continue;
		}

		g_iPinnedRescueAttacker[iVictim] = iAttacker;
		g_iPinnedRescueClass[iVictim] = L4D2_GetPlayerZombieClass(iAttacker);
		g_bPinnedRescueActive[iVictim] = true;
	}

	RebuildPinnedRescueCoordinator();
}

void RequestPinnedRescueCoordinatorRecovery()
{
	g_bPinnedRescueRecoveryPending = true;
}

void StartPinnedRescueCoordinator(int iVictim, int iAttacker)
{
	if (!IsClientSurvivor(iVictim) || !IsSpecialInfected(iAttacker))
	{
		InvalidatePinnedRescueCoordinator(iVictim);
		return;
	}

	g_iPinnedRescueAttacker[iVictim] = iAttacker;
	g_iPinnedRescueClass[iVictim] = L4D2_GetPlayerZombieClass(iAttacker);
	g_bPinnedRescueActive[iVictim] = true;
	RebuildPinnedRescueCoordinator();
}

void InvalidatePinnedRescueCoordinator(int iVictim, int iAttacker = 0)
{
	if (iVictim <= 0 && iAttacker <= 0)
		return;

	bool bChanged;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!g_bPinnedRescueActive[i])
			continue;
		if (iVictim > 0 && i != iVictim)
			continue;
		if (iAttacker > 0 && g_iPinnedRescueAttacker[i] != iAttacker)
			continue;

		ClearPinnedRescueVictimState(i);
		bChanged = true;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		bool bMatchesVictim = (iVictim > 0 && g_iSurvivorBot_RescueVictim[i] == iVictim
			&& (iAttacker <= 0 || g_iSurvivorBot_RescueAttacker[i] == iAttacker));
		bool bMatchesAttacker = (iVictim <= 0 && iAttacker > 0 && g_iSurvivorBot_RescueAttacker[i] == iAttacker);
		if (bMatchesVictim || bMatchesAttacker)
		{
			g_iSurvivorBot_RescueVictim[i] = 0;
			g_iSurvivorBot_RescueAttacker[i] = 0;
			bChanged = true;
		}
	}

	if (bChanged)
		RebuildPinnedRescueCoordinator();
}

void InvalidatePinnedRescueClient(int iClient)
{
	if (iClient < 1 || iClient > MaxClients)
		return;

	bool bChanged;
	if (g_iSurvivorBot_RescueVictim[iClient] != 0 || g_iSurvivorBot_RescueAttacker[iClient] != 0)
	{
		g_iSurvivorBot_RescueVictim[iClient] = 0;
		g_iSurvivorBot_RescueAttacker[iClient] = 0;
		bChanged = true;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bPinnedRescueActive[i] && (i == iClient || g_iPinnedRescueAttacker[i] == iClient))
		{
			ClearPinnedRescueVictimState(i);
			bChanged = true;
		}

		if (g_iPinnedReactionRank[i][iClient] != 0)
		{
			g_iPinnedReactionRank[i][iClient] = 0;
			bChanged = true;
		}
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_iSurvivorBot_RescueVictim[i] == iClient || g_iSurvivorBot_RescueAttacker[i] == iClient)
		{
			g_iSurvivorBot_RescueVictim[i] = 0;
			g_iSurvivorBot_RescueAttacker[i] = 0;
			bChanged = true;
		}
	}

	if (bChanged)
		RebuildPinnedRescueCoordinator();
}

bool IsPinnedFriendReactionAllowed(int iClient, int iPinnedFriend)
{
	if (g_bPinnedRescueRecoveryPending || g_iCvar_HelpPinnedFriend_ReactionBots <= 0 || !IsClientSurvivor(iClient) || !IsFakeClient(iClient) || !IsValidClient(iPinnedFriend)
		|| !g_bPinnedRescueActive[iPinnedFriend] || g_iSurvivorBot_RescueVictim[iClient] != iPinnedFriend
		|| g_iSurvivorBot_RescueAttacker[iClient] != g_iPinnedRescueAttacker[iPinnedFriend]
		|| !IsValidClient(g_iPinnedRescueAttacker[iPinnedFriend]) || !IsPlayerAlive(g_iPinnedRescueAttacker[iPinnedFriend]))
		return false;

	int iRank = g_iPinnedReactionRank[iPinnedFriend][iClient];
	return (iRank > 0 && iRank <= g_iCvar_HelpPinnedFriend_ReactionBots);
}

bool IsPinnedFriendMoveBlocked(int iPinnedFriend)
{
	return (!g_bPinnedRescueRecoveryPending && IsValidClient(iPinnedFriend) && g_bPinnedRescueActive[iPinnedFriend]
		&& g_iPinnedRescueClass[iPinnedFriend] != L4D2ZombieClass_Smoker);
}

bool TryBeginPinnedRescueThink(int iClient, float fNow)
{
	if (fNow <= g_fSurvivorBot_NextPinnedRescueThinkTime[iClient])
		return false;

	g_fSurvivorBot_NextPinnedRescueThinkTime[iClient] = fNow + g_fCvar_HelpPinnedFriend_ReactionInterval;
	return true;
}

bool GetPinnedRescueAimPosition(int iAttacker, L4D2ZombieClassType iZombieClass, float fAimPos[3])
{
	if (!IsValidClient(iAttacker) || !IsPlayerAlive(iAttacker) || !IsValidVector(g_fClientCenteroid[iAttacker]))
		return false;

	fAimPos = g_fClientCenteroid[iAttacker];

	if (iZombieClass == L4D2ZombieClass_Smoker)
	{
		int iAbility = L4D_GetPlayerCustomAbility(iAttacker);
		if (IsEntityExists(iAbility) && HasEntProp(iAbility, Prop_Send, "m_tipPosition"))
		{
			float fTipPos[3];
			GetEntPropVector(iAbility, Prop_Send, "m_tipPosition", fTipPos);
			if (IsValidVector(fTipPos))
				fAimPos = fTipPos;
		}
	}

	return IsValidVector(fAimPos);
}

bool IsPinnedRescueAimVisible(int iClient, float fAimPos[3])
{
	return IsVisibleVector(iClient, fAimPos);
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
