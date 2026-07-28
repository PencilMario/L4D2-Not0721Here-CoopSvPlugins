MRESReturn Detour_CommandIssued(DHookReturn hReturn, DHookParam hParam)
{
	static int iCommand, iUserID, iClient, iTarget;
	iCommand = hParam.Get(1);
	iUserID = hParam.Get(2);
	iTarget = hParam.Get(3);
	iClient = GetClientOfUserId(iUserID);

	if (g_iCvar_Debug & DEBUG_MOVE && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
	{
		char sEntClassname[64], sClientName[128];
		if (iClient > -1)
			GetClientName(iClient, sClientName, sizeof(sClientName));
		if (iTarget > -1)
			GetEntityClassname(iTarget, sEntClassname, sizeof(sEntClassname));
		PrintToServer("Received %s command for %d %s, target %d %s", IBVScriptCommands[iCommand-1], iClient, (iClient > 0 ? sClientName : "everyone"), iTarget, (iTarget != -1 ? sEntClassname : "not defined"));
	}

	if (iCommand == 1)
	{
		if (iClient <= 0)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientSurvivor(i) || !IsFakeClient(i))
					continue;
				ClearMoveToPosition(i);
			}
		}
		else
			ClearMoveToPosition(iClient);
	}

	hReturn.Value = true;
	return MRES_Supercede;
}

MRESReturn DTR_OnSurvivorBotGetAvoidRange(int iClient, Handle hReturn, Handle hParams)
{
	int iTarget = DHookGetParam(hParams, 1);
	float fAvoidRange = DHookGetReturn(hReturn);
	float fInitRange = DHookGetReturn(hReturn);

	if (fAvoidRange == 125.0)
	{
		if (iTarget <= MaxClients)
		{
			fAvoidRange = ((!IsUsingSpecialAbility(iTarget) && IsValidClient(L4D_GetPinnedSurvivor(iTarget))) ? 0.0 : 200.0);
		}
		else if (SurvivorHasMeleeWeapon(iClient))
		{
			fAvoidRange = 0.0;
		}
	}
	else if (fAvoidRange == 450.0)
	{
		int iVictim = g_iInfectedBot_CurrentVictim[iTarget];
		fAvoidRange = ((iVictim == iClient || iVictim > 0 && GetClientDistance(iVictim, iClient, true) <= 160000.0) ? 700.0 : 300.0);
	}
	else if (fAvoidRange == 300.0 && g_iSurvivorBot_WitchTarget[iClient] != -1 && g_bSurvivorBot_IsWitchHarasser[iClient])
	{
		fAvoidRange = 800.0;
	}

	if (IsSurvivorCarryingProp(iClient))
	{
		fAvoidRange += 200.0;
	}

	//PrintToServer("%N = %i, %f/%f", iClient, iTarget, fAvoidRange, fInitRange);

	if (fInitRange != fAvoidRange)
	{
		DHookSetReturn(hReturn, fAvoidRange);
		return MRES_ChangedOverride;
	}

	return MRES_Ignored;
}

MRESReturn DTR_OnInfernoTouchNavArea(int iInferno, Handle hReturn, Handle hParams)
{
	bool bIsTouching = DHookGetReturn(hReturn);
	if (!bIsTouching)return MRES_Ignored;

	int iNavArea = DHookGetParam(hParams, 1);
	if (!iNavArea)return MRES_Ignored;

	float fAreaPos[3];
	bool bCanBlock = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2 || L4D_IsPlayerIncapacitated(i) || L4D_IsPlayerPinned(i))
			continue;

		bCanBlock = (g_iClientNavArea[i] != iNavArea);
		if (!bCanBlock)break;

		LBI_GetClosestPointOnNavArea(iNavArea, g_fClientAbsOrigin[i], fAreaPos);
		bCanBlock = (GetVectorDistance(g_fClientAbsOrigin[i], fAreaPos, true) > 4096.0);
		if (!bCanBlock)break;
	}

	if (bCanBlock)
		SDKCall(g_hMarkNavAreaAsBlocked, iNavArea, 2, iInferno, true);

	return MRES_Ignored;
}

MRESReturn DTR_OnFindUseEntity(int iClient, Handle hReturn, Handle hParams)
{
	static int iScavengeItem;
	static float fDistance, fScavengePos[3];

	if (!IsValidClient(iClient) || !IsFakeClient(iClient))
		return MRES_Ignored;

	iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	if (!IsEntityExists(iScavengeItem))
		return MRES_Ignored;

	GetEntityAbsOrigin(iScavengeItem, fScavengePos);
	fDistance = GetVectorDistance(g_fClientAbsOrigin[iClient], fScavengePos, true);
	if (fDistance > g_fCvar_ItemScavenge_PickupRange_Sqr)
	{
		if (g_iCvar_Debug & DEBUG_SCAVENGE && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
		{
			char sEntClassname[64],sClientName[128];
			GetClientName(iClient, sClientName, sizeof(sClientName));
			GetEntityClassname(iScavengeItem, sEntClassname, sizeof(sEntClassname));
			PrintToServer("DTR_OnFindUseEntity: Preventing %s from grabbing %s, distance %.2f", sClientName, sEntClassname, SquareRoot(fDistance));
		}
		return MRES_Ignored;
	}

	DHookSetReturn(hReturn, iScavengeItem);
	return MRES_ChangedOverride;
}
