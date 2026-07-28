#include "l4d2_sb_ai_improver/perception.inc"

#include "l4d2_sb_ai_improver/inventory.inc"

#include "l4d2_sb_ai_improver/utilities.inc"

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
	int iCloseArea = L4D_GetNearestNavArea(fPos);
	return (iCloseArea && LBI_IsDamagingNavArea(iCloseArea));
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

bool LBI_IsNavAreaPartiallyVisible(int iNavArea, const float fEyePos[3], int iIgnoreEntity = -1)
{
	float fOffset = (0.75 * HUMAN_HEIGHT);

	float fCenter[3]; LBI_GetNavAreaCenter(iNavArea, fCenter);
	fCenter[2] += fOffset;

	Handle hResult = TR_TraceRayFilterEx(fEyePos, fCenter, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, CTraceFilterNoNPCsOrPlayer, iIgnoreEntity);
	float fFraction = TR_GetFraction(hResult); delete hResult;
	if (fFraction == 1.0)return true;

	float fEyeToCenter[3];
	MakeVectorFromPoints(fEyePos, fCenter, fEyeToCenter);
	NormalizeVector(fEyeToCenter, fEyeToCenter);

	float fCorner[3], fEyeToCorner[3];
	for (int i = 0; i < 4; ++i)
	{
		LBI_GetNavAreaCorner(iNavArea, i, fCorner);
		fCorner[2] += fOffset;

		MakeVectorFromPoints(fEyePos, fCorner, fEyeToCorner);
		NormalizeVector(fEyeToCorner, fEyeToCorner);
		if (GetVectorDotProduct(fEyeToCorner, fEyeToCenter) >= 0.98)
			continue;

		fCorner[2] += fOffset;
		hResult = TR_TraceRayFilterEx(fEyePos, fCorner, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, CTraceFilterNoNPCsOrPlayer, iIgnoreEntity);
		fFraction = TR_GetFraction(hResult); delete hResult;
		if (fFraction == 1.0)return true;
	}

	return false;
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

	Address pNavArea = view_as<Address>(L4D_GetNearestNavArea(fPos));
	if (pNavArea == Address_Null)return false;

	int iAttributes = L4D_GetNavArea_SpawnAttributes(pNavArea);
	return ((iAttributes & NAV_SPAWN_FINALE) == 0 && (iAttributes & NAV_SPAWN_CHECKPOINT) != 0);
}

float GetClientTravelDistance(int iClient, float fGoalPos[3], bool bSquared = false)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	float fResult = GetClientTravelDistanceImpl(iClient, fGoalPos, bSquared);
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

	iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, false, GetClientTeam(iClient)); // need to think about which checkLOS and checkGround bools to put here
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
	float fResult = GetClientDistanceToItemImpl(iClient, iEntity, bIgnoreNavBlockers);
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
		fTargetPos = g_fClientAbsOrigin[iEntity];
	else
	{
		GetEntityAbsOrigin(iEntity, fEntityPos);
		iGoalArea = L4D_GetNearestNavArea(fEntityPos, 300.0, true, true, false, GetClientTeam(iClient));
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
	float fResult = GetNavDistanceImpl(fStartPos, fGoalPos, iEntity, bCheckLOS);
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

	if (iEntity != -1 && g_hBadPathEntities.FindValue(EntIndexToEntRef(iEntity)) != -1)
	{
		if(g_iCvar_Debug & DEBUG_NAV)
			PrintToServer("GetNavDistance: entity %d %s is in bad pathing table", iEntity, sEntClassname);
		return -1.0;
	}

	iStartArea = L4D_GetNearestNavArea(fStartPos, 140.0, true, bCheckLOS, false, 2);
	if (!iStartArea)
	{
		if(g_iCvar_Debug & DEBUG_NAV)
			PrintToServer("GetNavDistance: could not find iStartArea, fStartPos %.2f %.2f %.2f ent %d %s", fStartPos[0], fStartPos[1], fStartPos[2], iEntity, sEntClassname);
		if(iEntity != -1)
			PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		return -1.0;
	}

	iGoalArea = L4D_GetNearestNavArea(fGoalPos, 140.0, true, bCheckLOS, false, 2);
	if (!iGoalArea)
	{
		if(g_iCvar_Debug & DEBUG_NAV)
			PrintToServer("GetNavDistance: could not find iGoalArea, fGoalPos %.2f %.2f %.2f ent %d %s", fGoalPos[0], fGoalPos[1], fGoalPos[2], iEntity, sEntClassname);
		if(iEntity != -1)
			PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		return -1.0;
	}

	fDistance = L4D2_NavAreaTravelDistance(fStartPos, fGoalPos, true);
	if (g_iCvar_Debug & DEBUG_NAV && fDistance < 0.0)
		PrintToServer("GetNavDistance: fDistance %.2f fStartPos %.2f %.2f %.2f ent %d %s", fDistance, fStartPos[0], fStartPos[1], fStartPos[2], iEntity, sEntClassname);

	if (iEntity != -1 && fDistance < 0.0)
	{
		PushEntityIntoArrayList(g_hBadPathEntities, iEntity);
		if (g_hClearBadPathTimer == INVALID_HANDLE)
			g_hClearBadPathTimer = CreateTimer(0.1, ClearBadPathEntsTable);
	}

	return fDistance;
}

public Action ClearBadPathEntsTable(Handle timer)
{
	g_hBadPathEntities.Clear();
	g_hClearBadPathTimer = INVALID_HANDLE;
	return Plugin_Handled;
}

bool LBI_GetBonePosition(int iEntity, const char[] sBoneName, float fBuffer[3])
{
	if (!IsEntityExists(iEntity))return false;

	int iBoneIndex = SDKCall(g_hLookupBone, iEntity, sBoneName);
	if (iBoneIndex == -1)return false;

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
	int iLastArea = g_iClientNavArea[iClient];
	if (!iLastArea)return false;

	if (iStartArea == -1)iStartArea = iLastArea;
	return (iStartArea && (iStartArea == iGoalArea || SDKCall(g_hIsReachableNavArea, iClient, iStartArea, iGoalArea)));
}

// don't fucking break the game if the position is 1mm inside of a prop, or 1mm below ground, a'ight??
bool LBI_IsReachablePosition(int iClient, const float fPos[3], bool bCheckLOS = true)
{
	int iNearArea = L4D_GetNearestNavArea(fPos, 200.0, true, bCheckLOS, false, 0);
	return (iNearArea && LBI_IsReachableNavArea(iClient, iNearArea));
}

bool LBI_IsReachableEntity(int iClient, int iEntity)
{
	if (!IsEntityExists(iEntity) || IsValidClient(iEntity) && !g_iClientNavArea[iEntity])return false;
	float fEntityPos[3]; GetEntityAbsOrigin(iEntity, fEntityPos);
	return (LBI_IsReachablePosition(iClient, fEntityPos));
}

#include "l4d2_sb_ai_improver/detours.inc"

int LBI_IsPathToPositionDangerous(int iClient, float fGoalPos[3])
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	int iResult = LBI_IsPathToPositionDangerousImpl(iClient, fGoalPos);
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

		iGoalArea = L4D_GetNearestNavArea(fGoalPos, _, true, true, true);
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
				PrintToServer("IsPathToPositionDangerous: %d iterations of lag loop", iCount);
		}
		delete hTankList;
	}

	return -1;
}
