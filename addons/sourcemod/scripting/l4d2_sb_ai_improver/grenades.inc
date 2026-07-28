int CalculateGrenadeThrowInfectedCount()
{
	int iFreeSurvivors;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || L4D_IsPlayerBoomerBiled(i) || L4D_IsPlayerIncapacitated(i) || L4D_IsPlayerPinned(i) || GetClientRealHealth(i) <= RoundFloat(g_iCvar_SurvivorLimpHealth * 0.8))
			continue;

		iFreeSurvivors++;
		if ( IsWeaponSlotActive(i, 1) && g_iClientInvFlags[i] & FLAG_CHAINSAW )
			iFreeSurvivors++;
	}

	float fCountScale = g_fCvar_GrenadeThrow_HordeSize;
	int iFinalCount = RoundFloat(iFreeSurvivors * fCountScale);
	if (iFinalCount < 1)iFinalCount = RoundFloat(fCountScale);
	if (L4D2_IsTankInPlay())iFinalCount = RoundFloat(iFinalCount * 0.66);
	return iFinalCount;
}

bool CheckCanThrowGrenade(int iClient, int iTarget, float fClientPos[3], float fThrowPos[3], bool bTeammateNearThrowArea, bool bIsThrowTargetTank)
{
	if (g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.33))
		return false;

	if (IsWeaponReloading(L4D_GetPlayerCurrentWeapon(iClient)))
		return false;

	if (IsSurvivorBusy(iClient, _, true, true))
		return false;

	int iGrenadeType = SurvivorHasGrenade(iClient);
	if (iGrenadeType == 0)return false;

	int iGrenadeBit = (iGrenadeType == 2 ? 1 : iGrenadeType == 3 ? 2 : 0);
	if (g_iCvar_GrenadeThrow_GrenadeTypes & (1 << iGrenadeBit) == 0)return false;

	if (iGrenadeType == 2)
	{
		if (bTeammateNearThrowArea)
		{
			return false;
		}

		if (GetGameTime() < g_fSurvivorBot_Grenade_NextThrowTime_Molotov)
		{
			return false;
		}

		if ((fThrowPos[2] - fClientPos[2]) > 256.0)
		{
			return false;
		}

		if (IsEntityOnFire(iTarget))
		{
			return false;
		}

		if (GetVectorDistance(fClientPos, fThrowPos, true) <= BOT_GRENADE_CHECK_RADIUS_SQR)
		{
			return false;
		}

		if (IsFinaleEscapeVehicleArrived())
		{
			return false;
		}
	}
	else if (GetGameTime() < g_fSurvivorBot_Grenade_NextThrowTime)
	{
		return false;
	}

	if (GetPinnedSurvivorCount() != 0)
		return false;

	int iActiveGrenades = (GetSurvivorTeamActiveItemCount(L4D2WeaponId_PipeBomb) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Molotov) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Vomitjar));
	if (iActiveGrenades >= 1)
		return false;

	if (bIsThrowTargetTank == true)
	{
		if (iGrenadeType == 1)
			return false;

		if (iGrenadeType == 3)
		{
			if (GetGameTime() <= g_fInfectedBot_CoveredInVomitTime[iTarget])
				return false;

			if (GetInfectedCount(iTarget, g_fCvar_ChaseBileRange, 10, _, false) < 10)
				return false;
		}

		if (!IsVisibleEntity(iClient, iTarget, MASK_SHOT_HULL))
			return false;
	}
	else
	{
		if (iGrenadeType == 2)
			return false;

		int iThrowCount = CalculateGrenadeThrowInfectedCount();
		if (g_iSurvivorBot_GrenadeInfectedCount[iClient] < iThrowCount)
		{
			return false;
		}

		int iChaseEnt = INVALID_ENT_REFERENCE;
		float fItRange = (g_fCvar_ChaseBileRange*g_fCvar_ChaseBileRange);
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "info_goal_infected_chase")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > fItRange)continue;
			return false;
		}

		iChaseEnt = INVALID_ENT_REFERENCE;
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "pipe_bomb_projectile")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > 1048576.0)continue;
			return false;
		}
	}

	if (iGrenadeType == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientSurvivor(i) || !L4D_IsPlayerBoomerBiled(i))continue;
			return false;
		}
	}

	return true;
}

bool CheckIsUnableToThrowGrenade(int iClient, int iTarget, float fClientPos[3], float fThrowPos[3], bool bTeammateNearThrowArea, bool bIsThrowTargetTank)
{
	int iActiveGrenades = (GetSurvivorTeamActiveItemCount(L4D2WeaponId_PipeBomb) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Molotov) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_Vomitjar));
	if (iActiveGrenades > 1)
		return true;

	int iGrenadeType = SurvivorHasGrenade(iClient);
	if (iGrenadeType == 2)
	{
		if (bTeammateNearThrowArea)
			return true;

		if ((fThrowPos[2] - fClientPos[2]) > 256.0)
			return true;

		if (GetVectorDistance(fClientPos, fThrowPos, true) <= BOT_GRENADE_CHECK_RADIUS_SQR)
			return true;

		if (IsEntityOnFire(iTarget))
			return true;
	}

	if (bIsThrowTargetTank)
	{
		if (iGrenadeType == 1)
			return true;

		if (iGrenadeType == 3)
		{
			if (GetGameTime() <= g_fInfectedBot_CoveredInVomitTime[iTarget])
				return true;

			if (GetInfectedCount(iTarget, g_fCvar_ChaseBileRange, 10, _, false) < 10)
				return true;
		}

		if (!IsVisibleEntity(iClient, iTarget, MASK_SHOT_HULL))
			return true;
	}
	else
	{
		if (iGrenadeType == 2)
			return true;

		int iThrowCount = CalculateGrenadeThrowInfectedCount();
		if (g_iSurvivorBot_GrenadeInfectedCount[iClient] < RoundFloat(iThrowCount * 0.33))
		{
			return true;
		}

		int iChaseEnt = INVALID_ENT_REFERENCE;
		float fItRange = (g_fCvar_ChaseBileRange*g_fCvar_ChaseBileRange);
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "info_goal_infected_chase")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > fItRange)continue;
			return true;
		}

		iChaseEnt = INVALID_ENT_REFERENCE;
		while ((iChaseEnt = FindEntityByClassname(iChaseEnt, "pipe_bomb_projectile")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntityDistance(iChaseEnt, iTarget, true) > 1048576.0)continue;
			return true;
		}
	}

	if (iGrenadeType == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientSurvivor(i) || !L4D_IsPlayerBoomerBiled(i))continue;
			return true;
		}
	}

	return false;
}

void CalculateTrajectory(float fStartPos[3], float fEndPos[3], float fVelocity, float fGravityScale = 1.0, float fResult[3])
{
	MakeVectorFromPoints(fStartPos, fEndPos, fResult);
	fResult[2] = 0.0;

	float fPos_X = GetVectorLength(fResult);
	float fPos_Y = fEndPos[2] - fStartPos[2];

	float fGravity = (g_fCvar_ServerGravity * fGravityScale);

	float fSqrtCalc1 = (fVelocity * fVelocity * fVelocity * fVelocity);
	float fSqrtCalc2 = fGravity * ((fGravity * (fPos_X * fPos_X)) + (2.0 * fPos_Y * (fVelocity * fVelocity)));

	float fCalcSum = (fSqrtCalc1 - fSqrtCalc2);
	if (fCalcSum < 0.0)fCalcSum = FloatAbs(fCalcSum);

	float fAngSqrt = SquareRoot(fCalcSum);
	float fAngPos = ArcTangent(((fVelocity * fVelocity) + fAngSqrt) / (fGravity * fPos_X));
	float fAngNeg = ArcTangent(((fVelocity * fVelocity) - fAngSqrt) / (fGravity * fPos_X));

	float fPitch = ((fAngPos > fAngNeg) ? fAngNeg : fAngPos);
	fResult[2] = (Tangent(fPitch) * fPos_X);

	NormalizeVector(fResult, fResult);
	ScaleVector(fResult, fVelocity);
}
