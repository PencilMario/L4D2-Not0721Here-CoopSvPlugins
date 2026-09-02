#include "l4d2_sb_ai_improver/perception.inc"

#include "l4d2_sb_ai_improver/inventory.inc"

#include "l4d2_sb_ai_improver/utilities.inc"

#include "l4d2_sb_ai_improver/navigation_cache.inc"

void LBI_GetNavAreaCenter(int iNavArea, float fResult[3])
{
	Address hAddress = view_as<Address>(iNavArea);
	fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_Center), NumberType_Int32));
	fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_Center + 4), NumberType_Int32));
	fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_Center + 8), NumberType_Int32));
}

int LBI_GetNavAreaParent(int iNavArea)
{
	return (LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_Parent), NumberType_Int32));
}

bool LBI_IsDamagingNavArea(int iNavArea, bool bIgnoreWitches = false)
{
	if (!iNavArea)
		return false;

	float fNow = GetGameTime();
	for (int i = 0; i < NAV_DAMAGING_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationDamagingCache_Expiry[i]
			&& g_iNavigationDamagingCache_NavArea[i] == iNavArea
			&& g_bNavigationDamagingCache_IgnoreWitches[i] == bIgnoreWitches)
			return g_bNavigationDamagingCache_Result[i];
	}

	bool bResult = LBI_IsDamagingNavAreaImpl(iNavArea, bIgnoreWitches);
	int iCacheSlot = g_iNavigationDamagingCache_NextSlot;
	g_iNavigationDamagingCache_NextSlot = (g_iNavigationDamagingCache_NextSlot + 1) % NAV_DAMAGING_CACHE_SIZE;
	g_fNavigationDamagingCache_Expiry[iCacheSlot] = GetProcessCacheExpiry();
	g_iNavigationDamagingCache_NavArea[iCacheSlot] = iNavArea;
	g_bNavigationDamagingCache_IgnoreWitches[iCacheSlot] = bIgnoreWitches;
	g_bNavigationDamagingCache_Result[iCacheSlot] = bResult;
	return bResult;
}

bool LBI_IsDamagingNavAreaImpl(int iNavArea, bool bIgnoreWitches = false)
{
	int iTickCount = LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_DamagingTickCount), NumberType_Int32);
	if (GetGameTickCount() <= iTickCount)
	{
		if (!bIgnoreWitches && L4D2_GetWitchCount() > 0)
		{
			int iWitch = INVALID_ENT_REFERENCE;
			float fWitchPos[3], fClosePoint[3];
			while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
			{
				GetEntityAbsOrigin(iWitch, fWitchPos);
				LBI_GetClosestPointOnNavArea(iNavArea, fWitchPos, fClosePoint);
				if (GetVectorDistance(fWitchPos, fClosePoint, true) <= 14400.0)return false;
			}
		}
		return true;
	}
	return false;
}

bool LBI_IsDamagingPosition(const float fPos[3])
{
	float fNow = GetGameTime();
	for (int i = 0; i < NAV_DAMAGE_POSITION_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationDamagePositionCache_Expiry[i]
			&& GetVectorDistance(g_fNavigationDamagePositionCache_Position[i], fPos, true) <= GetNavigationCachePositionTolerance())
			return g_bNavigationDamagePositionCache_Result[i];
	}

	int iCloseArea = LBI_GetNearestNavAreaCached(fPos);
	bool bResult = (iCloseArea && LBI_IsDamagingNavArea(iCloseArea));
	int iCacheSlot = g_iNavigationDamagePositionCache_NextSlot;
	g_iNavigationDamagePositionCache_NextSlot = (g_iNavigationDamagePositionCache_NextSlot + 1) % NAV_DAMAGE_POSITION_CACHE_SIZE;
	g_fNavigationDamagePositionCache_Expiry[iCacheSlot] = GetProcessCacheExpiry();
	g_fNavigationDamagePositionCache_Position[iCacheSlot] = fPos;
	g_bNavigationDamagePositionCache_Result[iCacheSlot] = bResult;
	return bResult;
}

void LBI_GetNavAreaCorners(int iNavArea, float fNWCorner[3], float fSECorner[3])
{
	Address hAddress = view_as<Address>(iNavArea);
	for (int i = 0; i < 3; i++)
	{
		fNWCorner[i] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner + (4 * i)), NumberType_Int32));
		fSECorner[i] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner + (4 * i)), NumberType_Int32));
	}
}

void LBI_GetClosestPointOnNavArea(int iNavArea, const float fPos[3], float fClosePoint[3])
{
	float fNWCorner[3], fSECorner[3];
	LBI_GetNavAreaCorners(iNavArea, fNWCorner, fSECorner);

	float fNewPos[3];
	fNewPos[0] = fsel((fPos[0] - fNWCorner[0]), fPos[0], fNWCorner[0]);
	fNewPos[0] = fsel((fNewPos[0] - fSECorner[0]), fSECorner[0], fNewPos[0]);

	fNewPos[1] = fsel((fPos[1] - fNWCorner[1]), fPos[1], fNWCorner[1]);
	fNewPos[1] = fsel((fNewPos[1] - fSECorner[1]), fSECorner[1], fNewPos[1]);

	fNewPos[2] = LBI_GetNavAreaZ(iNavArea, fNewPos[0], fNewPos[1]);

	fClosePoint = fNewPos;
}

float LBI_GetNavAreaZ(int iNavArea, float x, float y)
{
	float fNWCorner[3], fSECorner[3];
	LBI_GetNavAreaCorners(iNavArea, fNWCorner, fSECorner);

	float fInvDXCorners = view_as<float>(LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_InvDXCorners), NumberType_Int32));
	float fInvDYCorners = view_as<float>(LoadFromAddress(view_as<Address>(iNavArea) + view_as<Address>(g_iNavArea_InvDYCorners), NumberType_Int32));

	float u = (x - fNWCorner[0]) * fInvDXCorners;
	float v = (y - fNWCorner[1]) * fInvDYCorners;

	u = fsel(u, u, 0.0);
	u = fsel(u - 1.0, 1.0, u);

	v = fsel(v, v, 0.0);
	v = fsel(v - 1.0, 1.0, v);

	float fNorthZ = fNWCorner[2] + u * (fSECorner[2] - fNWCorner[2]);
	float fSouthZ = fNWCorner[2] + u * (fSECorner[2] - fNWCorner[2]);

	return (fNorthZ + v * (fSouthZ - fSouthZ));
}

stock float fsel(float fComparand, float fValGE, float fLT)
{
	return (fComparand >= 0.0 ? fValGE : fLT);
}

void LBI_GetNavAreaCorner(int iNavArea, int iCorner, float fResult[3])
{
	Address hAddress = view_as<Address>(iNavArea);
	switch(iCorner)
	{
		case 0:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+8), NumberType_Int32));
		}
		case 1:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner+8), NumberType_Int32));
		}
		case 2:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_NWCorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+8), NumberType_Int32));
		}
		case 3:
		{
			fResult[0] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner), NumberType_Int32));
			fResult[1] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+4), NumberType_Int32));
			fResult[2] = view_as<float>(LoadFromAddress(hAddress + view_as<Address>(g_iNavArea_SECorner+8), NumberType_Int32));
		}
		default:
		{
			return;
		}
	}
}

bool CTraceFilterNoNPCsOrPlayer(int iEntity, int iContentsMask, int iIgnore)
{
	if (iEntity == 0 || IsValidClient(iEntity))
		return true;

	static char sClassname[64]; GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	if (strncmp(sClassname, "func_door", 9) == 0 || strncmp(sClassname, "prop_door", 9) == 0)
		return false;

	if (strcmp(sClassname, "func_brush") == 0)
	{
		int iSolidity = GetEntProp(iEntity, Prop_Data, "m_iSolidity");
		return (iSolidity == 2);
	}

	if ((strcmp(sClassname, "func_breakable_surf") == 0 || strcmp(sClassname, "func_breakable") == 0 && GetEntityHealth(iEntity) > 0) && GetEntProp(iEntity, Prop_Data, "m_takedamage") == 2)
		return false;

	if (strcmp(sClassname, "func_playerinfected_clip") == 0)
		return false;

	return (iEntity != iIgnore);
}

bool LBI_IsPositionInsideCheckpoint(const float fPos[3])
{
	if (!L4D2_IsGenericCooperativeMode())
		return false;

	Address pNavArea = view_as<Address>(LBI_GetNearestNavAreaCached(fPos));
	if (pNavArea == Address_Null)return false;

	int iAttributes = L4D_GetNavArea_SpawnAttributes(pNavArea);
	return ((iAttributes & NAV_SPAWN_FINALE) == 0 && (iAttributes & NAV_SPAWN_CHECKPOINT) != 0);
}

void ResetNavigationCaches()
{
	for (int i = 0; i < NAV_AREA_LOOKUP_CACHE_SIZE; i++)
		g_fNavigationAreaLookupCache_Expiry[i] = 0.0;
	for (int i = 0; i < NAV_DAMAGING_CACHE_SIZE; i++)
		g_fNavigationDamagingCache_Expiry[i] = 0.0;
	for (int i = 0; i < NAV_DAMAGE_POSITION_CACHE_SIZE; i++)
		g_fNavigationDamagePositionCache_Expiry[i] = 0.0;
	for (int i = 0; i < NAV_VISIBLE_CACHE_SIZE; i++)
		g_fNavigationVisibleCache_Expiry[i] = 0.0;
	for (int i = 0; i < NAV_DISTANCE_CACHE_SIZE; i++)
		g_fNavigationDistanceCache_Expiry[i] = 0.0;
	for (int i = 0; i < NAV_BUILD_PATH_CACHE_SIZE; i++)
		g_fNavigationBuildPathCache_Expiry[i] = 0.0;

	g_iNavigationAreaLookupCache_NextSlot = 0;
	g_iNavigationDamagingCache_NextSlot = 0;
	g_iNavigationDamagePositionCache_NextSlot = 0;
	g_iNavigationVisibleCache_NextSlot = 0;
	g_iNavigationDistanceCache_NextSlot = 0;
	g_iNavigationBuildPathCache_NextSlot = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		g_iClientNavArea[i] = 0;
		g_fClientNavAreaCache_Expiry[i] = 0.0;
		SetVectorToZero(g_fClientNavAreaCache_Position[i]);
		g_fNavigationTravelCache_Expiry[i] = 0.0;
		g_fNavigationDangerCache_Expiry[i] = 0.0;
		g_iNavigationReachableAreaCache_NextSlot[i] = 0;
		g_iNavigationReachablePositionCache_NextSlot[i] = 0;
		g_fSurvivorNearBoomerCache_Expiry[i] = 0.0;

		for (int j = 0; j < MAXENTITIES + 1; j++)
			g_fNavigationCache_Expiry[i][j] = 0.0;
		for (int j = 0; j < NAV_REACHABLE_AREA_CACHE_SIZE; j++)
			g_fNavigationReachableAreaCache_Expiry[i][j] = 0.0;
		for (int j = 0; j < NAV_REACHABLE_POSITION_CACHE_SIZE; j++)
			g_fNavigationReachablePositionCache_Expiry[i][j] = 0.0;
	}

	for (int i = 1; i <= MAXENTITIES; i++)
		g_iCommonInfectedMeleeTargetMask[i] = 0;
}

stock float GetNavigationCacheCycleKey()
{
	return GetProcessCacheExpiry();
}

float GetNavigationCachePositionTolerance()
{
	return 256.0; // 16 units squared; moving targets invalidate beyond this.
}

int LBI_GetNearestNavAreaCached(const float fPos[3], float fMaxDist = 300.0, bool bAnyZ = false, bool bCheckLOS = false, bool bCheckGround = false, int iTeam = 2)
{
	float fNow = GetGameTime();
	for (int i = 0; i < NAV_AREA_LOOKUP_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationAreaLookupCache_Expiry[i]
			&& g_iNavigationAreaLookupCache_Team[i] == iTeam
			&& g_bNavigationAreaLookupCache_AnyZ[i] == bAnyZ
			&& g_bNavigationAreaLookupCache_CheckLOS[i] == bCheckLOS
			&& g_bNavigationAreaLookupCache_CheckGround[i] == bCheckGround
			&& FloatAbs(g_fNavigationAreaLookupCache_MaxDist[i] - fMaxDist) <= 0.01
			&& GetVectorDistance(g_fNavigationAreaLookupCache_Position[i], fPos, true) <= GetNavigationCachePositionTolerance())
			return g_iNavigationAreaLookupCache_Result[i];
	}

	int iResult = L4D_GetNearestNavArea(fPos, fMaxDist, bAnyZ, bCheckLOS, bCheckGround, iTeam);
	int iCacheSlot = g_iNavigationAreaLookupCache_NextSlot;
	g_iNavigationAreaLookupCache_NextSlot = (g_iNavigationAreaLookupCache_NextSlot + 1) % NAV_AREA_LOOKUP_CACHE_SIZE;
	g_fNavigationAreaLookupCache_Expiry[iCacheSlot] = GetProcessCacheExpiry();
	g_fNavigationAreaLookupCache_Position[iCacheSlot] = fPos;
	g_fNavigationAreaLookupCache_MaxDist[iCacheSlot] = fMaxDist;
	g_iNavigationAreaLookupCache_Result[iCacheSlot] = iResult;
	g_iNavigationAreaLookupCache_Team[iCacheSlot] = iTeam;
	g_bNavigationAreaLookupCache_AnyZ[iCacheSlot] = bAnyZ;
	g_bNavigationAreaLookupCache_CheckLOS[iCacheSlot] = bCheckLOS;
	g_bNavigationAreaLookupCache_CheckGround[iCacheSlot] = bCheckGround;
	return iResult;
}

float GetClientTravelDistance(int iClient, float fGoalPos[3], bool bSquared = false)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	PerformanceBudgetBeginStage("trace_navigation");
	float fResult;
	float fNow = GetGameTime();
	int iStartArea = (IsValidClient(iClient) ? g_iClientNavArea[iClient] : 0);
	if (iStartArea && fNow < g_fNavigationTravelCache_Expiry[iClient]
		&& g_iNavigationTravelCache_StartArea[iClient] == iStartArea
		&& g_bNavigationTravelCache_Squared[iClient] == bSquared
		&& GetVectorDistance(g_fNavigationTravelCache_GoalPos[iClient], fGoalPos, true) <= GetNavigationCachePositionTolerance())
	{
		fResult = g_fNavigationTravelCache_Result[iClient];
	}
	else
	{
		fResult = GetClientTravelDistanceImpl(iClient, fGoalPos, bSquared);
		if (iStartArea)
		{
			g_fNavigationTravelCache_Expiry[iClient] = GetProcessCacheExpiry();
			g_fNavigationTravelCache_GoalPos[iClient] = fGoalPos;
			g_fNavigationTravelCache_Result[iClient] = fResult;
			g_iNavigationTravelCache_StartArea[iClient] = iStartArea;
			g_bNavigationTravelCache_Squared[iClient] = bSquared;
		}
	}
	PerformanceBudgetEndStage(iClient);
	LogSlowCalculation("GetClientTravelDistance", fStartedAt, iClient);
	return fResult;
}

float GetClientTravelDistanceImpl(int iClient, float fGoalPos[3], bool bSquared = false)
{
	if (!g_bMapStarted)return -1.0;

	static bool bIsReachable;
	static int iStartArea, iGoalArea, iArea, iCount;
	iStartArea = g_iClientNavArea[iClient];
	if (!iStartArea)
		return -1.0;

	iGoalArea = LBI_GetNearestNavAreaCached(fGoalPos, 300.0, true, true, false, GetClientTeam(iClient)); // need to think about which checkLOS and checkGround bools to put here
	if (!iGoalArea)
		return -1.0;

	//if (!L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), 0.0, GetClientTeam(iClient), false))
	bIsReachable = L4D2_IsReachable(iClient, fGoalPos);
	if (!bIsReachable)
		return -1.0;

	iArea = LBI_GetNavAreaParent(iGoalArea);
	if (!iArea)
		return GetVectorDistance(g_fClientAbsOrigin[iClient], fGoalPos, bSquared);

	float fClosePoint[3]; LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	float fDistance = GetVectorDistance(fClosePoint, fGoalPos, bSquared);
	float fParentCenter[3];

	iCount = 0;
	for (; LBI_GetNavAreaParent(iArea); iArea = LBI_GetNavAreaParent(iArea))
	{
		if (iCount > 50)
			break;
		LBI_GetClosestPointOnNavArea(LBI_GetNavAreaParent(iArea), fGoalPos, fParentCenter);
		LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
		fDistance += GetVectorDistance(fClosePoint, fParentCenter, bSquared);
		iCount++;
	}
	//if(g_bCvar_Debug && iCount > 20)
	//	PrintToServer("GetClientTravelDist %d iterations of lag loop", iCount);

	LBI_GetClosestPointOnNavArea(iArea, fGoalPos, fClosePoint);
	fDistance += GetVectorDistance(g_fClientAbsOrigin[iClient], fClosePoint, bSquared);

	return fDistance;
}

float GetClientDistanceToItem(int iClient, int iEntity, bool bIgnoreNavBlockers = true)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	PerformanceBudgetBeginStage("trace_navigation");
	float fResult;
	float fNow = GetGameTime();
	float fEntityPos[3];
	int iStartArea = (IsValidClient(iClient) ? g_iClientNavArea[iClient] : 0);
	bool bCanCache = (iStartArea && iEntity >= 0 && iEntity <= MAXENTITIES && IsEntityExists(iEntity) && GetEntityAbsOrigin(iEntity, fEntityPos));
	if (bCanCache && fNow < g_fNavigationCache_Expiry[iClient][iEntity]
		&& g_iNavigationCache_Type[iClient][iEntity] == 2
		&& g_iNavigationCacheClient[iClient][iEntity] == iClient
		&& g_iNavigationCacheGoalEntity[iClient][iEntity] == iEntity
		&& g_iNavigationCache_StartArea[iClient][iEntity] == iStartArea
		&& g_bNavigationCache_IgnoreNavBlockers[iClient][iEntity] == bIgnoreNavBlockers
		&& GetVectorDistance(g_fNavigationCache_GoalPos[iClient][iEntity], fEntityPos, true) <= GetNavigationCachePositionTolerance())
	{
		fResult = g_fNavigationCache_Distance[iClient][iEntity];
	}
	else
	{
		fResult = GetClientDistanceToItemImpl(iClient, iEntity, bIgnoreNavBlockers);
		if (bCanCache)
		{
			g_fNavigationCache_Expiry[iClient][iEntity] = GetProcessCacheExpiry();
			g_fNavigationCache_GoalPos[iClient][iEntity] = fEntityPos;
			g_fNavigationCache_Distance[iClient][iEntity] = fResult;
			g_iNavigationCacheClient[iClient][iEntity] = iClient;
			g_iNavigationCacheGoalEntity[iClient][iEntity] = iEntity;
			g_iNavigationCache_Type[iClient][iEntity] = 2;
			g_iNavigationCache_StartArea[iClient][iEntity] = iStartArea;
			g_bNavigationCache_IgnoreNavBlockers[iClient][iEntity] = bIgnoreNavBlockers;
		}
	}
	PerformanceBudgetEndStage(iClient);
	LogSlowCalculation("GetClientDistanceToItem", fStartedAt, iClient, iEntity);
	return fResult;
}

float GetClientDistanceToItemImpl(int iClient, int iEntity, bool bIgnoreNavBlockers = true)
{
	if (!g_bMapStarted)
		return -1.0;

	static bool bIsReachable;
	static int iGoalArea;
	static float fDistance, fEntityPos[3], fTargetPos[3];

	//get or calculate target position
	iGoalArea = 0;
	if(IsValidClient(iEntity))
	{
		fTargetPos = g_fClientAbsOrigin[iEntity];
		fEntityPos = fTargetPos;
	}
	else
	{
		GetEntityAbsOrigin(iEntity, fEntityPos);
		iGoalArea = LBI_GetNearestNavAreaCached(fEntityPos, 300.0, true, true, false, GetClientTeam(iClient));
		if (!iGoalArea)
			return -1.0;
		L4D_GetNavAreaCenter(view_as<Address>(iGoalArea), fTargetPos);
	}

	//if bot, use L4D2_IsReachable
	if (IsFakeClient(iClient))
	{
		bIsReachable = L4D2_IsReachable(iClient, fEntityPos);
		if (!bIsReachable)
			return -1.0;
	}

	fDistance = L4D2_NavAreaTravelDistance(g_fClientAbsOrigin[iClient], fTargetPos, bIgnoreNavBlockers);
	if (iGoalArea)
		fDistance += GetVectorDistance(fTargetPos, fEntityPos, false);

	return fDistance;
}

//to replace GetVectorTravelDistance()
float GetNavDistance(float fStartPos[3], float fGoalPos[3], int iEntity = -1, bool bCheckLOS = true)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	PerformanceBudgetBeginStage("trace_navigation");
	float fResult;
	float fNow = GetGameTime();
	bool bEntityHasBadPath = (iEntity > 0 && iEntity <= MAXENTITIES && (g_iEntityListMask[iEntity] & ENTITY_LIST_BAD_PATH) != 0);
	bool bCacheHit = false;

	if (!bEntityHasBadPath)
	{
		for (int i = 0; i < NAV_DISTANCE_CACHE_SIZE; i++)
		{
			if (fNow < g_fNavigationDistanceCache_Expiry[i]
				&& g_iNavigationDistanceCache_Entity[i] == iEntity
				&& g_bNavigationDistanceCache_CheckLOS[i] == bCheckLOS
				&& GetVectorDistance(g_fNavigationDistanceCache_StartPos[i], fStartPos, true) <= GetNavigationCachePositionTolerance()
				&& GetVectorDistance(g_fNavigationDistanceCache_GoalPos[i], fGoalPos, true) <= GetNavigationCachePositionTolerance())
			{
				fResult = g_fNavigationDistanceCache_Result[i];
				bCacheHit = true;
				break;
			}
		}
	}

	if (!bCacheHit)
	{
		fResult = GetNavDistanceImpl(fStartPos, fGoalPos, iEntity, bCheckLOS);
		if (!bEntityHasBadPath && fResult >= 0.0)
		{
			int iCacheSlot = g_iNavigationDistanceCache_NextSlot;
			g_iNavigationDistanceCache_NextSlot = (g_iNavigationDistanceCache_NextSlot + 1) % NAV_DISTANCE_CACHE_SIZE;
			g_fNavigationDistanceCache_Expiry[iCacheSlot] = GetProcessCacheExpiry();
			g_fNavigationDistanceCache_StartPos[iCacheSlot] = fStartPos;
			g_fNavigationDistanceCache_GoalPos[iCacheSlot] = fGoalPos;
			g_fNavigationDistanceCache_Result[iCacheSlot] = fResult;
			g_iNavigationDistanceCache_Entity[iCacheSlot] = iEntity;
			g_bNavigationDistanceCache_CheckLOS[iCacheSlot] = bCheckLOS;
		}
	}
	PerformanceBudgetEndStage();
	LogSlowCalculation("GetNavDistance", fStartedAt, -1, iEntity);
	return fResult;
}

float GetNavDistanceImpl(float fStartPos[3], float fGoalPos[3], int iEntity = -1, bool bCheckLOS = true)
{
	if (!g_bMapStarted)return -1.0;

	static int iStartArea, iGoalArea;
	static float fDistance;
	static char sEntClassname[64];

	sEntClassname[0] = EOS;
	if (iEntity != -1)
		GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));

	if (iEntity > 0 && iEntity <= MAXENTITIES && (g_iEntityListMask[iEntity] & ENTITY_LIST_BAD_PATH) != 0)
	{
		if(g_iCvar_Debug & DEBUG_NAV)
			LogDebugMessage("GetNavDistance: entity %d %s is in bad pathing table", iEntity, sEntClassname);
		return -1.0;
	}

	iStartArea = LBI_GetNearestNavAreaCached(fStartPos, 140.0, true, bCheckLOS, false, 2);
	if (!iStartArea)
	{
		if(g_iCvar_Debug & DEBUG_NAV)
			LogDebugMessage("GetNavDistance: could not find iStartArea, fStartPos %.2f %.2f %.2f ent %d %s", fStartPos[0], fStartPos[1], fStartPos[2], iEntity, sEntClassname);
		if(iEntity != -1)
			PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		return -1.0;
	}

	iGoalArea = LBI_GetNearestNavAreaCached(fGoalPos, 140.0, true, bCheckLOS, false, 2);
	if (!iGoalArea)
	{
		if(g_iCvar_Debug & DEBUG_NAV)
			LogDebugMessage("GetNavDistance: could not find iGoalArea, fGoalPos %.2f %.2f %.2f ent %d %s", fGoalPos[0], fGoalPos[1], fGoalPos[2], iEntity, sEntClassname);
		if(iEntity != -1)
			PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		return -1.0;
	}

	fDistance = L4D2_NavAreaTravelDistance(fStartPos, fGoalPos, true);
	if (g_iCvar_Debug & DEBUG_NAV && fDistance < 0.0)
		LogDebugMessage("GetNavDistance: fDistance %.2f fStartPos %.2f %.2f %.2f ent %d %s", fDistance, fStartPos[0], fStartPos[1], fStartPos[2], iEntity, sEntClassname);

	if (iEntity != -1 && fDistance < 0.0)
	{
		PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		if (g_hClearBadPathTimer == INVALID_HANDLE)
			g_hClearBadPathTimer = CreateTimer(0.1, ClearBadPathEntsTable);
	}

	return fDistance;
}

bool LBI_NavAreaBuildPathCached(int iStartArea, int iGoalArea, float fMaxDist, int iTeam, bool bIgnoreNavBlockers)
{
	if (!iStartArea || !iGoalArea)
		return false;

	float fNow = GetGameTime();
	for (int i = 0; i < NAV_BUILD_PATH_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationBuildPathCache_Expiry[i]
			&& g_iNavigationBuildPathCache_StartArea[i] == iStartArea
			&& g_iNavigationBuildPathCache_GoalArea[i] == iGoalArea
			&& g_iNavigationBuildPathCache_Team[i] == iTeam
			&& g_bNavigationBuildPathCache_IgnoreBlockers[i] == bIgnoreNavBlockers
			&& FloatAbs(g_fNavigationBuildPathCache_MaxDist[i] - fMaxDist) <= 0.01)
			return g_bNavigationBuildPathCache_Result[i];
	}

	bool bResult = L4D2_NavAreaBuildPath(view_as<Address>(iStartArea), view_as<Address>(iGoalArea), fMaxDist, iTeam, bIgnoreNavBlockers);
	int iCacheSlot = g_iNavigationBuildPathCache_NextSlot;
	g_iNavigationBuildPathCache_NextSlot = (g_iNavigationBuildPathCache_NextSlot + 1) % NAV_BUILD_PATH_CACHE_SIZE;
	g_fNavigationBuildPathCache_Expiry[iCacheSlot] = GetProcessCacheExpiry();
	g_iNavigationBuildPathCache_StartArea[iCacheSlot] = iStartArea;
	g_iNavigationBuildPathCache_GoalArea[iCacheSlot] = iGoalArea;
	g_fNavigationBuildPathCache_MaxDist[iCacheSlot] = fMaxDist;
	g_iNavigationBuildPathCache_Team[iCacheSlot] = iTeam;
	g_bNavigationBuildPathCache_IgnoreBlockers[iCacheSlot] = bIgnoreNavBlockers;
	g_bNavigationBuildPathCache_Result[iCacheSlot] = bResult;
	return bResult;
}

public Action ClearBadPathEntsTable(Handle timer)
{
	g_hBadPathEntities.Clear();
	for (int i = 1; i <= MAXENTITIES; i++) UnregisterEntityListMask(i, ENTITY_LIST_BAD_PATH);
	g_hClearBadPathTimer = INVALID_HANDLE;
	return Plugin_Handled;
}

bool LBI_IsBoneQueryReady(int iEntity)
{
	if (!IsEntityExists(iEntity))return false;
	if (!HasEntProp(iEntity, Prop_Send, "m_nModelIndex") || GetEntProp(iEntity, Prop_Send, "m_nModelIndex") <= 0)return false;
	if (!HasEntProp(iEntity, Prop_Data, "m_ModelName"))return false;

	static char sModelName[PLATFORM_MAX_PATH];
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	return (sModelName[0] != '\0');
}

int LBI_LookupBone(int iEntity, const char[] sBoneName)
{
	if (!LBI_IsBoneQueryReady(iEntity) || sBoneName[0] == '\0')return -1;
	return SDKCall(g_hLookupBone, iEntity, sBoneName);
}

bool LBI_GetBonePosition(int iEntity, const char[] sBoneName, float fBuffer[3])
{
	fBuffer[0] = fBuffer[1] = fBuffer[2] = 0.0;

	int iBoneIndex = LBI_LookupBone(iEntity, sBoneName);
	if (iBoneIndex == -1 || !LBI_IsBoneQueryReady(iEntity))return false;

	static float fUnusedAngles[3];
	SDKCall(g_hGetBonePosition, iEntity, iBoneIndex, fBuffer, fUnusedAngles);

	return (IsValidVector(fBuffer));
}

bool LBI_IsSurvivorInCombat(int iClient, bool bUnknown = false)
{
	return (SDKCall(g_hIsInCombat, iClient, bUnknown));
}

int LBI_FindUseEntity(int iClient, float fCheckDist = 96.0, float fFloat_1 = 0.0, float fFloat_2 = 0.0, bool bBool_1 = false, bool bBool_2 = false)
{
	return (SDKCall(g_hFindUseEntity, iClient, fCheckDist, fFloat_1, fFloat_2, bBool_1, bBool_2));
}

bool LBI_IsSurvivorBotAvailable(int iClient)
{
	return (SDKCall(g_hIsAvailable, iClient));
}

bool LBI_IsReachableNavArea(int iClient, int iGoalArea, int iStartArea = -1)
{
	if (!IsValidClient(iClient) || !iGoalArea)
		return false;

	int iLastArea = g_iClientNavArea[iClient];
	if (!iLastArea)return false;

	if (iStartArea == -1)iStartArea = iLastArea;
	if (!iStartArea)
		return false;

	float fNow = GetGameTime();
	for (int i = 0; i < NAV_REACHABLE_AREA_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationReachableAreaCache_Expiry[iClient][i]
			&& g_iNavigationReachableAreaCache_StartArea[iClient][i] == iStartArea
			&& g_iNavigationReachableAreaCache_GoalArea[iClient][i] == iGoalArea)
			return g_bNavigationReachableAreaCache_Result[iClient][i];
	}

	bool bResult = (iStartArea == iGoalArea || SDKCall(g_hIsReachableNavArea, iClient, iStartArea, iGoalArea));
	int iCacheSlot = g_iNavigationReachableAreaCache_NextSlot[iClient];
	g_iNavigationReachableAreaCache_NextSlot[iClient] = (iCacheSlot + 1) % NAV_REACHABLE_AREA_CACHE_SIZE;
	g_fNavigationReachableAreaCache_Expiry[iClient][iCacheSlot] = GetProcessCacheExpiry();
	g_iNavigationReachableAreaCache_StartArea[iClient][iCacheSlot] = iStartArea;
	g_iNavigationReachableAreaCache_GoalArea[iClient][iCacheSlot] = iGoalArea;
	g_bNavigationReachableAreaCache_Result[iClient][iCacheSlot] = bResult;
	return bResult;
}

// don't fucking break the game if the position is 1mm inside of a prop, or 1mm below ground, a'ight??
bool LBI_IsReachablePosition(int iClient, const float fPos[3], bool bCheckLOS = true)
{
	if (!IsValidClient(iClient) || !g_iClientNavArea[iClient])
		return false;

	int iStartArea = g_iClientNavArea[iClient];
	float fNow = GetGameTime();
	for (int i = 0; i < NAV_REACHABLE_POSITION_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationReachablePositionCache_Expiry[iClient][i]
			&& g_iNavigationReachablePositionCache_StartArea[iClient][i] == iStartArea
			&& g_bNavigationReachablePositionCache_CheckLOS[iClient][i] == bCheckLOS
			&& GetVectorDistance(g_fNavigationReachablePositionCache_Position[iClient][i], fPos, true) <= GetNavigationCachePositionTolerance())
			return g_bNavigationReachablePositionCache_Result[iClient][i];
	}

	int iNearArea = LBI_GetNearestNavAreaCached(fPos, 200.0, true, bCheckLOS, false, 0);
	bool bResult = (iNearArea && LBI_IsReachableNavArea(iClient, iNearArea, iStartArea));
	int iCacheSlot = g_iNavigationReachablePositionCache_NextSlot[iClient];
	g_iNavigationReachablePositionCache_NextSlot[iClient] = (iCacheSlot + 1) % NAV_REACHABLE_POSITION_CACHE_SIZE;
	g_fNavigationReachablePositionCache_Expiry[iClient][iCacheSlot] = GetProcessCacheExpiry();
	g_fNavigationReachablePositionCache_Position[iClient][iCacheSlot] = fPos;
	g_iNavigationReachablePositionCache_StartArea[iClient][iCacheSlot] = iStartArea;
	g_bNavigationReachablePositionCache_CheckLOS[iClient][iCacheSlot] = bCheckLOS;
	g_bNavigationReachablePositionCache_Result[iClient][iCacheSlot] = bResult;
	return bResult;
}

bool LBI_IsReachableEntity(int iClient, int iEntity)
{
	if (!IsValidClient(iClient) || iEntity < 0 || iEntity > MAXENTITIES || !IsEntityExists(iEntity))
		return false;

	float fNow = GetGameTime();
	float fEntityPos[3];
	int iStartArea = g_iClientNavArea[iClient];
	if (!iStartArea || !GetEntityAbsOrigin(iEntity, fEntityPos))
		return false;

	if (fNow < g_fNavigationCache_Expiry[iClient][iEntity]
		&& g_iNavigationCache_Type[iClient][iEntity] == 1
		&& g_iNavigationCacheClient[iClient][iEntity] == iClient
		&& g_iNavigationCacheGoalEntity[iClient][iEntity] == iEntity
		&& g_iNavigationCache_StartArea[iClient][iEntity] == iStartArea
		&& GetVectorDistance(g_fNavigationCache_GoalPos[iClient][iEntity], fEntityPos, true) <= GetNavigationCachePositionTolerance())
	{
		return g_bNavigationCache_Result[iClient][iEntity];
	}

	bool bResult = LBI_IsReachableEntityImpl(iClient, iEntity);
	g_fNavigationCache_Expiry[iClient][iEntity] = GetProcessCacheExpiry();
	g_fNavigationCache_GoalPos[iClient][iEntity] = fEntityPos;
	g_bNavigationCache_Result[iClient][iEntity] = bResult;
	g_iNavigationCacheClient[iClient][iEntity] = iClient;
	g_iNavigationCacheGoalEntity[iClient][iEntity] = iEntity;
	g_iNavigationCache_Type[iClient][iEntity] = 1;
	g_iNavigationCache_StartArea[iClient][iEntity] = iStartArea;
	return bResult;
}

bool LBI_IsReachableEntityImpl(int iClient, int iEntity)
{
	if (!IsEntityExists(iEntity) || IsValidClient(iEntity) && !g_iClientNavArea[iEntity])return false;
	float fEntityPos[3]; GetEntityAbsOrigin(iEntity, fEntityPos);
	return (LBI_IsReachablePosition(iClient, fEntityPos));
}

#include "l4d2_sb_ai_improver/detours.inc"

int LBI_IsPathToPositionDangerous(int iClient, float fGoalPos[3])
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	PerformanceBudgetBeginStage("trace_navigation");
	int iResult;
	float fNow = GetGameTime();
	int iStartArea = (IsValidClient(iClient) ? g_iClientNavArea[iClient] : 0);
	if (iStartArea && fNow < g_fNavigationDangerCache_Expiry[iClient]
		&& g_iNavigationDangerCache_StartArea[iClient] == iStartArea
		&& GetVectorDistance(g_fNavigationDangerCache_GoalPos[iClient], fGoalPos, true) <= GetNavigationCachePositionTolerance())
	{
		iResult = g_iNavigationDangerCache_Result[iClient];
	}
	else
	{
		iResult = LBI_IsPathToPositionDangerousImpl(iClient, fGoalPos);
		if (iStartArea)
		{
			g_fNavigationDangerCache_Expiry[iClient] = GetProcessCacheExpiry();
			g_fNavigationDangerCache_GoalPos[iClient] = fGoalPos;
			g_iNavigationDangerCache_Result[iClient] = iResult;
			g_iNavigationDangerCache_StartArea[iClient] = iStartArea;
		}
	}
	PerformanceBudgetEndStage(iClient);
	LogSlowCalculation("LBI_IsPathToPositionDangerous", fStartedAt, iClient);
	return iResult;
}

int LBI_IsPathToPositionDangerousImpl(int iClient, float fGoalPos[3])
{
	if (!g_bMapStarted)return -1;

	static int iClientArea, iGoalArea, iParent, iCount, iTank;
	static float fTankDist, fGoalDist, fGoalOffset[3], fAreaPos[3];

	if (L4D2_IsTankInPlay())
	{
		ArrayList hTankList = new ArrayList();

		fGoalOffset = fGoalPos;
		fGoalOffset[2] += HUMAN_HALF_HEIGHT;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (i == iClient || !IsClientInGame(i) || !IsPlayerAlive(i) || L4D2_GetPlayerZombieClass(i) != L4D2ZombieClass_Tank || L4D_IsPlayerIncapacitated(i))
				continue;

			fGoalDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fGoalPos, true);
			if (fGoalDist <= 90000.0 && GetVectorDistance(g_fClientAbsOrigin[i], fGoalPos, true) <= 22500.0 && IsVisibleVector(i, fGoalOffset, MASK_VISIBLE_AND_NPCS))
			{
				delete hTankList;
				return i;
			}

			if (fGoalDist > 250000)
			{
				fTankDist = GetClientTravelDistance(i, g_fClientAbsOrigin[iClient], true);
				if (fTankDist <= 62500.0 || fTankDist <= 562500.0 && g_iInfectedBot_CurrentVictim[i] == iClient && IsVisibleEntity(iClient, i, MASK_VISIBLE_AND_NPCS))
				{
					delete hTankList;
					return i;
				}
			}

			hTankList.Push(i);
		}

		iClientArea = g_iClientNavArea[iClient];
		if (!iClientArea)
		{
			delete hTankList;
			return -1;
		}

		iGoalArea = LBI_GetNearestNavAreaCached(fGoalPos, 300.0, true, true, true);
		if (!iGoalArea)
		{
			delete hTankList;
			return -1;
		}

		//(!L4D2_NavAreaBuildPath(view_as<Address>(iClientArea), view_as<Address>(iGoalArea), 0.0, 2, false))
		if (!L4D2_IsReachable(iClient, fGoalPos))
		{
			delete hTankList;
			return -1;
		}

		iParent = LBI_GetNavAreaParent(iGoalArea);
		if (iParent)
		{
			iCount = 0;
			for (; LBI_GetNavAreaParent(iParent); iParent = LBI_GetNavAreaParent(iParent))
			{
				if (iCount > 25)
					//i ain't calculating all that
					//happy for you though
					//or sorry that happened
					break;
				for (int i = 0; i < hTankList.Length; i++)
				{
					iTank = hTankList.Get(i);

					if (g_iClientNavArea[iTank] != iParent)
					{
						LBI_GetClosestPointOnNavArea(iParent, g_fClientAbsOrigin[iTank], fAreaPos);
						if (g_iInfectedBot_CurrentVictim[iTank] != iClient && GetVectorDistance(g_fClientAbsOrigin[iTank], fAreaPos, true) > 22500.0)continue;
					}

					delete hTankList;
					return (g_iInfectedBot_CurrentVictim[iTank] == iClient ? iTank : 0);
				}
				iCount++;
			}
			if(g_iCvar_Debug & DEBUG_NAV && iCount > 10)
				LogDebugMessage("IsPathToPositionDangerous: %d iterations of lag loop", iCount);
		}
		delete hTankList;
	}

	return -1;
}
