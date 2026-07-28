int GetFarthestInfected(int iClient, float fDistance = -1.0)
{
	int iInfected = -1;

	float fInfectedDist;
	float fInfectedPos[3];
	float fLastDist = -1.0;

	int i = INVALID_ENT_REFERENCE;
	while ((i = FindEntityByClassname(i, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (!IsCommonInfectedAlive(i))
			continue;

		GetEntityCenteroid(i, fInfectedPos);
		fInfectedDist = GetVectorDistance(g_fClientEyePos[iClient], fInfectedPos, true);
		if (fDistance > 0.0 && fInfectedDist > (fDistance*fDistance) || fLastDist != -1.0 && fInfectedDist <= fLastDist || !IsVisibleVector(iClient, fInfectedPos))
			continue;

		iInfected = i;
		fLastDist = fInfectedDist;
	}

	return iInfected;
}

void CheckEntityForVisibility(int iClient, int iEntity, bool bFOVOnly = false, float fOverridePos[3] = NULL_VECTOR)
{
	float fVisionTime = (bFOVOnly ? g_fSurvivorBot_VisionMemory_Time_FOV[iClient][iEntity] : g_fSurvivorBot_VisionMemory_Time[iClient][iEntity]);
	if (GetGameTime() < fVisionTime)return;

	float fCheckPos[3];
	if (IsNullVector(fOverridePos))GetEntityCenteroid(iEntity, fCheckPos);
	else fCheckPos = fOverridePos;
	if (bFOVOnly && !FVectorInViewCone(iClient, fCheckPos))return;

	float fNoticeTime;
	bool bIsVisible = IsVisibleEntity(iClient, iEntity);
	float fEntityDist = GetVectorDistance(g_fClientEyePos[iClient], fCheckPos, true);
	float fDot = RadToDeg(ArcCosine(GetLineOfSightDotProduct(iClient, fCheckPos)));

	float fMaxDist = 16777216.0;

	int iVisionState = (bFOVOnly ? g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] : g_iSurvivorBot_VisionMemory_State[iClient][iEntity]);
	if (!bFOVOnly)
	{
		fNoticeTime = (ClampFloat(0.66 * (fDot / 165.0) + (fEntityDist / fMaxDist), 0.1, 1.5) * g_fCvar_Vision_NoticeTimeScale);
		switch(iVisionState)
		{
			case 0:
			{
				if (!bIsVisible)return;
				g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 1;
				g_fSurvivorBot_VisionMemory_Time[iClient][iEntity] = GetGameTime() + fNoticeTime;
			}
			case 1:
			{
				g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = (bIsVisible ? 2 : 0);
			}
			case 2:
			{
				if (!bIsVisible)g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 3;
			}
			case 3:
			{
				if (bIsVisible)
				{
					g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 2;
					return;
				}
				if ((GetGameTime() - fVisionTime) >= 15.0)
				{
					g_iSurvivorBot_VisionMemory_State[iClient][iEntity] = 0;
					return;
				}
				g_fSurvivorBot_VisionMemory_Time[iClient][iEntity] = GetGameTime() + ClampFloat(fNoticeTime * 0.33, 0.1, fNoticeTime);
			}
		}
	}
	else
	{
		fNoticeTime = (ClampFloat(0.33 * (fDot / g_fCvar_Vision_FieldOfView) + (fEntityDist / fMaxDist), 0.1, 0.75) * g_fCvar_Vision_NoticeTimeScale);
		switch(iVisionState)
		{
			case 0:
			{
				if (!bIsVisible)return;
				g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 1;
				g_fSurvivorBot_VisionMemory_Time_FOV[iClient][iEntity] = GetGameTime() + fNoticeTime;
			}
			case 1:
			{
				g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = (bIsVisible ? 2 : 0);
			}
			case 2:
			{
				if (!bIsVisible)g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 3;
			}
			case 3:
			{
				g_fSurvivorBot_VisionMemory_Time_FOV[iClient][iEntity] = GetGameTime() + fNoticeTime;
				if (bIsVisible)
				{
					g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 2;
					return;
				}
				if ((GetGameTime() - fVisionTime) >= 15.0)
				{
					g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] = 0;
					return;
				}
			}
		}
	}
}

bool HasVisualContactWithEntity(int iClient, int iEntity, bool bFOVState = true, float fOverridePos[3] = NULL_VECTOR)
{
	CheckEntityForVisibility(iClient, iEntity, bFOVState, fOverridePos);
	int iState = (bFOVState ? g_iSurvivorBot_VisionMemory_State_FOV[iClient][iEntity] : g_iSurvivorBot_VisionMemory_State[iClient][iEntity]);
	return (iState == 2);
}

stock float ClampFloat(float fValue, float fMin, float fMax)
{
	return (fValue > fMax) ? fMax : ((fValue < fMin) ? fMin : fValue);
}

int GetClosestInfected(int iClient, float fDistance = -1.0)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	int iResult = GetClosestInfectedImpl(iClient, fDistance);
	LogSlowCalculation("GetClosestInfected", fStartedAt, iClient, iResult);
	return iResult;
}

int GetClosestInfectedImpl(int iClient, float fDistance = -1.0)
{
	static int iInfected, iCloseInfected, iThrownPipeBomb;
	static float fInfectedDist, fLastDist;
	static bool bIsAttacking, bIsChasingSomething, bBileWasThrown;

	bIsChasingSomething = false;
	iThrownPipeBomb = (FindEntityByClassname(-1, "pipe_bomb_projectile"));
	bBileWasThrown = (FindEntityByClassname(-1, "info_goal_infected_chase") != -1);
	iCloseInfected = -1;
	fLastDist = -1.0;
	iInfected = INVALID_ENT_REFERENCE;
	while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (!IsCommonInfectedAlive(iInfected))
			continue;

		fInfectedDist = GetEntityDistance(iClient, iInfected, true);
		if (fDistance > 0.0 && fInfectedDist > (fDistance*fDistance) || fLastDist != -1.0 && fInfectedDist >= fLastDist)
			continue;

		bIsChasingSomething = (fInfectedDist > 25600.0 && (bBileWasThrown || iThrownPipeBomb > 0 && GetEntityDistance(iInfected, iThrownPipeBomb, true) <= 65536.0));
		if (!bIsChasingSomething && fInfectedDist > 9216.0)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				bIsChasingSomething = (iClient != i && IsClientSurvivor(i) && g_iSurvivorBot_TargetInfected[i] == iInfected && IsWeaponSlotActive(i, 1) && IsEntityExists(g_iSurvivorBot_TargetInfected[i]) && SurvivorHasMeleeWeapon(i) != 0);
				if (bIsChasingSomething)break;
			}
		}

		if (bIsChasingSomething || !IsVisibleEntity(iClient, iInfected))
			continue;

		iCloseInfected = iInfected;
		fLastDist = fInfectedDist;
	}

	bIsAttacking = false;
	for (iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (!IsSpecialInfected(iInfected) || L4D2_GetPlayerZombieClass(iInfected) == L4D2ZombieClass_Tank || bIsAttacking && !IsUsingSpecialAbility(iInfected))
			continue;

		fInfectedDist = GetClientDistance(iClient, iInfected, true);
		if (fDistance > 0.0 && fInfectedDist > (fDistance*fDistance) || fLastDist != -1.0 && fInfectedDist >= fLastDist || !IsVisibleEntity(iClient, iInfected, MASK_VISIBLE_AND_NPCS))
			continue;

		iCloseInfected = iInfected;
		fLastDist = fInfectedDist;
		bIsAttacking = IsUsingSpecialAbility(iInfected);
	}

	return iCloseInfected;
}

int GetInfectedCount(int iClient, float fDistanceLimit = -1.0, int iMaxLimit = -1, bool bVisible = true, bool bAttackingOnly = true)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	int iResult = GetInfectedCountImpl(iClient, fDistanceLimit, iMaxLimit, bVisible, bAttackingOnly);
	LogSlowCalculation("GetInfectedCount", fStartedAt, iClient, iResult);
	return iResult;
}

int GetInfectedCountImpl(int iClient, float fDistanceLimit = -1.0, int iMaxLimit = -1, bool bVisible = true, bool bAttackingOnly = true)
{
	static int i, iCount;
	static float fClientPos[3], fInfectedPos[3];
	GetEntityCenteroid(iClient, fClientPos);

	i = INVALID_ENT_REFERENCE;
	iCount = 0;
	while ((i = FindEntityByClassname(i, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (!IsCommonInfectedAlive(i) || bAttackingOnly && !IsCommonInfectedAttacking(i))
			continue;

		GetEntityCenteroid(i, fInfectedPos);
		if (fDistanceLimit > 0.0 && GetVectorDistance(fClientPos, fInfectedPos, true) > (fDistanceLimit*fDistanceLimit) || bVisible && (IsValidClient(iClient) && !IsVisibleVector(iClient, fInfectedPos, MASK_VISIBLE_AND_NPCS) || !GetVectorVisible(fClientPos, fInfectedPos)))
			continue;

		iCount++;
		if (iMaxLimit > 0 && iCount >= iMaxLimit)return iCount;
	}

	return iCount;
}

bool IsSpecialInfected(int iClient)
{
	return (IsValidClient(iClient) && GetClientTeam(iClient) == 3 && IsPlayerAlive(iClient) && !L4D_IsPlayerGhost(iClient));
}

bool IsWitch(int iEntity)
{
	static char sClass[12]; GetEntityClassname(iEntity, sClass, sizeof(sClass));
	return (strcmp(sClass, "witch") == 0);
}

bool IsSurvivorBusy(int iClient, bool bHoldingGrenade = false, bool bHoldingMedkit = false, bool bHoldingPills = false)
{
	if (bHoldingGrenade && IsWeaponSlotActive(iClient, 2) || bHoldingMedkit && IsWeaponSlotActive(iClient, 3) || bHoldingPills && IsWeaponSlotActive(iClient, 4))
		return true;

	L4D2UseAction iUseAction = L4D2_GetPlayerUseAction(iClient);
	if (iUseAction != L4D2UseAction_None && (bHoldingMedkit || iUseAction != L4D2UseAction_Healing && iUseAction != L4D2UseAction_Defibing))
		return true;

	if (L4D_GetPlayerReviveTarget(iClient) > 0)
		return true;

	if (L4D_IsPlayerStaggering(iClient))
		return true;

	return false;
}

bool IsVisibleVector(int iClient, float fPos[3], int iMask = MASK_SHOT)
{
	if (IsFakeClient(iClient) && GetClientTeam(iClient) == 2 && IsSurvivorBotBlindedByVomit(iClient))
		return false;

	Handle hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fPos, iMask, RayType_EndPoint, Base_TraceFilter);
	float fFraction = TR_GetFraction(hResult); delete hResult;
	return (fFraction == 1.0);
}

bool IsVisibleEntity(int iClient, int iTarget, int iMask = MASK_SHOT)
{
	if (IsFakeClient(iClient) && GetClientTeam(iClient) == 2 && IsSurvivorBotBlindedByVomit(iClient))
		return false;

	float fTargetPos[3];
	GetEntityAbsOrigin(iTarget, fTargetPos);

	Handle hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fTargetPos, iMask, RayType_EndPoint, Base_TraceFilter, iTarget);
	bool bDidHit = (TR_GetFraction(hResult) == 1.0 && !TR_StartSolid(hResult) || TR_GetEntityIndex(hResult) == iTarget); delete hResult;
	if (!bDidHit)
	{
		float fViewOffset[3];
		GetEntPropVector(iTarget, Prop_Data, "m_vecViewOffset", fViewOffset);
		AddVectors(fTargetPos, fViewOffset, fTargetPos);

		hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fTargetPos, iMask, RayType_EndPoint, Base_TraceFilter, iTarget);
		bDidHit = (TR_GetFraction(hResult) == 1.0 && !TR_StartSolid(hResult) || TR_GetEntityIndex(hResult) == iTarget); delete hResult;
		if (!bDidHit)
		{
			GetEntityCenteroid(iTarget, fTargetPos);

			hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fTargetPos, iMask, RayType_EndPoint, Base_TraceFilter, iTarget);
			bDidHit = (TR_GetFraction(hResult) == 1.0 && !TR_StartSolid(hResult) || TR_GetEntityIndex(hResult) == iTarget); delete hResult;
		}
	}
	return (bDidHit);
}

float GetLineOfSightDotProduct(int iClient, const float fVecSpot[3])
{
	float fLineOfSight[3];
	MakeVectorFromPoints(g_fClientEyePos[iClient], fVecSpot, fLineOfSight);
	NormalizeVector(fLineOfSight, fLineOfSight);

	float fEyeDirection[3];
	GetAngleVectors(g_fClientEyeAng[iClient], fEyeDirection, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fEyeDirection, fEyeDirection);

	return GetVectorDotProduct(fLineOfSight, fEyeDirection);
}

bool FVectorInViewCone(int iClient, const float fVecSpot[3], float fCone = -1.0)
{
	if (fCone == -1.0)fCone = g_fCvar_Vision_FieldOfView;
	return (RadToDeg(ArcCosine(GetLineOfSightDotProduct(iClient, fVecSpot))) <= fCone);
}

float GetViewAnglesDotProduct(int iClient, const float fVecSpot[3])
{
	float fLineOfSight[3];
	MakeVectorFromPoints(g_fClientAbsOrigin[iClient], fVecSpot, fLineOfSight);
	fLineOfSight[2] = 0.0;
	NormalizeVector(fLineOfSight, fLineOfSight);

	float fDirection[3]; GetClientAbsAngles(iClient, fDirection);
	GetAngleVectors(fDirection, fDirection, NULL_VECTOR, NULL_VECTOR);
	fDirection[2] = 0.0;
	NormalizeVector(fDirection, fDirection);

	return GetVectorDotProduct(fLineOfSight, fDirection);
}

bool FVectorInViewAngle(int iClient, const float fVecSpot[3], float fAngle = -1.0)
{
	if (fAngle == -1.0)fAngle = g_fCvar_Vision_FieldOfView;
	return (RadToDeg(ArcCosine(GetViewAnglesDotProduct(iClient, fVecSpot))) <= fAngle);
}

bool FEntityInViewAngle(int iClient, int iEntity, float fAngle = -1.0)
{
	if (fAngle == -1.0)fAngle = g_fCvar_Vision_FieldOfView;
	float fEntityAbsOrigin[3]; GetEntityCenteroid(iEntity, fEntityAbsOrigin);
	return (RadToDeg(ArcCosine(GetViewAnglesDotProduct(iClient, fEntityAbsOrigin))) <= fAngle);
}

void SnapViewToPosition(int iClient, const float fPos[3])
{
	if (g_bClient_IsLookingAtPosition[iClient])
		return;

	float fDesiredDir[3];
	MakeVectorFromPoints(g_fClientEyePos[iClient], fPos, fDesiredDir);
	GetVectorAngles(fDesiredDir, fDesiredDir);

	float fEyeAngles[3];
	fEyeAngles[0] = (g_fClientEyeAng[iClient][0] + NormalizeAngle(fDesiredDir[0] - g_fClientEyeAng[iClient][0]));
	fEyeAngles[1] = (g_fClientEyeAng[iClient][1] + NormalizeAngle(fDesiredDir[1] - g_fClientEyeAng[iClient][1]));
	fEyeAngles[2] = 0.0;

	TeleportEntity(iClient, NULL_VECTOR, fEyeAngles, NULL_VECTOR);
	g_bClient_IsLookingAtPosition[iClient] = true;
}

float NormalizeAngle(float fAngle)
{
	fAngle = (fAngle - RoundToFloor(fAngle / 360.0) * 360.0);
	if (fAngle > 180.0)fAngle -= 360.0;
	else if (fAngle < -180.0)fAngle += 360.0;
	return fAngle;
}

void GetClientAimPosition(int iClient, float fAimPos[3])
{
	Handle hResult = TR_TraceRayFilterEx(g_fClientEyePos[iClient], g_fClientEyeAng[iClient], MASK_SHOT, RayType_Infinite, Base_TraceFilter);
	TR_GetEndPosition(fAimPos, hResult); delete hResult;
}

bool GetVectorVisible(float fStart[3], float fEnd[3], int iMask = MASK_VISIBLE_AND_NPCS)
{
	Handle hResult = TR_TraceRayFilterEx(fStart, fEnd, iMask, RayType_EndPoint, Base_TraceFilter);
	float fFraction = TR_GetFraction(hResult); delete hResult; return (fFraction == 1.0);
}

bool Base_TraceFilter(int iEntity, int iContentsMask, int iData)
{
	return (iEntity == iData || HasEntProp(iEntity, Prop_Data, "m_eDoorState") && L4D_GetDoorState(iEntity) != DOOR_STATE_OPENED);
}
