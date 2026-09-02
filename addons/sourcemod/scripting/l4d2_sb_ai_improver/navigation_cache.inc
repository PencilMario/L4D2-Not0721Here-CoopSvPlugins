#define NAV_AREA_LOOKUP_CACHE_SIZE 64
#define NAV_DAMAGING_CACHE_SIZE 64
#define NAV_DAMAGE_POSITION_CACHE_SIZE 32
#define NAV_REACHABLE_AREA_CACHE_SIZE 32
#define NAV_REACHABLE_POSITION_CACHE_SIZE 8
#define NAV_VISIBLE_CACHE_SIZE 32
#define NAV_DISTANCE_CACHE_SIZE 64
#define NAV_BUILD_PATH_CACHE_SIZE 32

float g_fNavigationAreaLookupCache_Expiry[NAV_AREA_LOOKUP_CACHE_SIZE];
float g_fNavigationAreaLookupCache_Position[NAV_AREA_LOOKUP_CACHE_SIZE][3];
float g_fNavigationAreaLookupCache_MaxDist[NAV_AREA_LOOKUP_CACHE_SIZE];
int g_iNavigationAreaLookupCache_Result[NAV_AREA_LOOKUP_CACHE_SIZE];
int g_iNavigationAreaLookupCache_Team[NAV_AREA_LOOKUP_CACHE_SIZE];
bool g_bNavigationAreaLookupCache_AnyZ[NAV_AREA_LOOKUP_CACHE_SIZE];
bool g_bNavigationAreaLookupCache_CheckLOS[NAV_AREA_LOOKUP_CACHE_SIZE];
bool g_bNavigationAreaLookupCache_CheckGround[NAV_AREA_LOOKUP_CACHE_SIZE];
int g_iNavigationAreaLookupCache_NextSlot;

float g_fNavigationDamagingCache_Expiry[NAV_DAMAGING_CACHE_SIZE];
int g_iNavigationDamagingCache_NavArea[NAV_DAMAGING_CACHE_SIZE];
bool g_bNavigationDamagingCache_IgnoreWitches[NAV_DAMAGING_CACHE_SIZE];
bool g_bNavigationDamagingCache_Result[NAV_DAMAGING_CACHE_SIZE];
int g_iNavigationDamagingCache_NextSlot;

float g_fNavigationDamagePositionCache_Expiry[NAV_DAMAGE_POSITION_CACHE_SIZE];
float g_fNavigationDamagePositionCache_Position[NAV_DAMAGE_POSITION_CACHE_SIZE][3];
bool g_bNavigationDamagePositionCache_Result[NAV_DAMAGE_POSITION_CACHE_SIZE];
int g_iNavigationDamagePositionCache_NextSlot;

float g_fNavigationReachableAreaCache_Expiry[MAXPLAYERS+1][NAV_REACHABLE_AREA_CACHE_SIZE];
int g_iNavigationReachableAreaCache_StartArea[MAXPLAYERS+1][NAV_REACHABLE_AREA_CACHE_SIZE];
int g_iNavigationReachableAreaCache_GoalArea[MAXPLAYERS+1][NAV_REACHABLE_AREA_CACHE_SIZE];
bool g_bNavigationReachableAreaCache_Result[MAXPLAYERS+1][NAV_REACHABLE_AREA_CACHE_SIZE];
int g_iNavigationReachableAreaCache_NextSlot[MAXPLAYERS+1];

float g_fNavigationReachablePositionCache_Expiry[MAXPLAYERS+1][NAV_REACHABLE_POSITION_CACHE_SIZE];
float g_fNavigationReachablePositionCache_Position[MAXPLAYERS+1][NAV_REACHABLE_POSITION_CACHE_SIZE][3];
int g_iNavigationReachablePositionCache_StartArea[MAXPLAYERS+1][NAV_REACHABLE_POSITION_CACHE_SIZE];
bool g_bNavigationReachablePositionCache_CheckLOS[MAXPLAYERS+1][NAV_REACHABLE_POSITION_CACHE_SIZE];
bool g_bNavigationReachablePositionCache_Result[MAXPLAYERS+1][NAV_REACHABLE_POSITION_CACHE_SIZE];
int g_iNavigationReachablePositionCache_NextSlot[MAXPLAYERS+1];

float g_fNavigationVisibleCache_Expiry[NAV_VISIBLE_CACHE_SIZE];
float g_fNavigationVisibleCache_EyePos[NAV_VISIBLE_CACHE_SIZE][3];
int g_iNavigationVisibleCache_NavArea[NAV_VISIBLE_CACHE_SIZE];
int g_iNavigationVisibleCache_IgnoreEntity[NAV_VISIBLE_CACHE_SIZE];
bool g_bNavigationVisibleCache_Result[NAV_VISIBLE_CACHE_SIZE];
int g_iNavigationVisibleCache_NextSlot;

float g_fNavigationDistanceCache_Expiry[NAV_DISTANCE_CACHE_SIZE];
float g_fNavigationDistanceCache_StartPos[NAV_DISTANCE_CACHE_SIZE][3];
float g_fNavigationDistanceCache_GoalPos[NAV_DISTANCE_CACHE_SIZE][3];
float g_fNavigationDistanceCache_Result[NAV_DISTANCE_CACHE_SIZE];
int g_iNavigationDistanceCache_Entity[NAV_DISTANCE_CACHE_SIZE];
bool g_bNavigationDistanceCache_CheckLOS[NAV_DISTANCE_CACHE_SIZE];
int g_iNavigationDistanceCache_NextSlot;

float g_fNavigationBuildPathCache_Expiry[NAV_BUILD_PATH_CACHE_SIZE];
int g_iNavigationBuildPathCache_StartArea[NAV_BUILD_PATH_CACHE_SIZE];
int g_iNavigationBuildPathCache_GoalArea[NAV_BUILD_PATH_CACHE_SIZE];
float g_fNavigationBuildPathCache_MaxDist[NAV_BUILD_PATH_CACHE_SIZE];
int g_iNavigationBuildPathCache_Team[NAV_BUILD_PATH_CACHE_SIZE];
bool g_bNavigationBuildPathCache_IgnoreBlockers[NAV_BUILD_PATH_CACHE_SIZE];
bool g_bNavigationBuildPathCache_Result[NAV_BUILD_PATH_CACHE_SIZE];
int g_iNavigationBuildPathCache_NextSlot;

float g_fNavigationCache_Expiry[MAXPLAYERS+1][MAXENTITIES+1];
bool g_bNavigationCache_Result[MAXPLAYERS+1][MAXENTITIES+1];
float g_fNavigationCache_Distance[MAXPLAYERS+1][MAXENTITIES+1];
int g_iNavigationCacheClient[MAXPLAYERS+1][MAXENTITIES+1];
int g_iNavigationCacheGoalEntity[MAXPLAYERS+1][MAXENTITIES+1];
int g_iNavigationCache_Type[MAXPLAYERS+1][MAXENTITIES+1];
int g_iNavigationCache_StartArea[MAXPLAYERS+1][MAXENTITIES+1];
float g_fNavigationCache_GoalPos[MAXPLAYERS+1][MAXENTITIES+1][3];
bool g_bNavigationCache_IgnoreNavBlockers[MAXPLAYERS+1][MAXENTITIES+1];

float g_fNavigationTravelCache_Expiry[MAXPLAYERS+1];
float g_fNavigationTravelCache_GoalPos[MAXPLAYERS+1][3];
float g_fNavigationTravelCache_Result[MAXPLAYERS+1];
int g_iNavigationTravelCache_StartArea[MAXPLAYERS+1];
bool g_bNavigationTravelCache_Squared[MAXPLAYERS+1];

float g_fNavigationDangerCache_Expiry[MAXPLAYERS+1];
float g_fNavigationDangerCache_GoalPos[MAXPLAYERS+1][3];
int g_iNavigationDangerCache_Result[MAXPLAYERS+1];
int g_iNavigationDangerCache_StartArea[MAXPLAYERS+1];

bool LBI_IsNavAreaPartiallyVisible(int iNavArea, const float fEyePos[3], int iIgnoreEntity = -1)
{
	if (!iNavArea)
		return false;

	if (g_bPerformanceBudgetEnabled)
		TraceMetricsRecordAttempt(TRACE_METRIC_NAV_VISIBLE);

	float fNow = GetGameTime();
	for (int i = 0; i < NAV_VISIBLE_CACHE_SIZE; i++)
	{
		if (fNow < g_fNavigationVisibleCache_Expiry[i]
			&& g_iNavigationVisibleCache_NavArea[i] == iNavArea
			&& g_iNavigationVisibleCache_IgnoreEntity[i] == iIgnoreEntity
			&& GetVectorDistance(g_fNavigationVisibleCache_EyePos[i], fEyePos, true) <= GetNavigationCachePositionTolerance())
		{
			if (g_bPerformanceBudgetEnabled)
				TraceMetricsRecordCacheHit(TRACE_METRIC_NAV_VISIBLE);
			return g_bNavigationVisibleCache_Result[i];
		}
	}

	if (g_bPerformanceBudgetEnabled)
		TraceMetricsRecordCacheMiss(TRACE_METRIC_NAV_VISIBLE);
	bool bResult = LBI_IsNavAreaPartiallyVisibleImpl(iNavArea, fEyePos, iIgnoreEntity);
	int iCacheSlot = g_iNavigationVisibleCache_NextSlot;
	g_iNavigationVisibleCache_NextSlot = (g_iNavigationVisibleCache_NextSlot + 1) % NAV_VISIBLE_CACHE_SIZE;
	g_fNavigationVisibleCache_Expiry[iCacheSlot] = GetProcessCacheExpiry();
	g_iNavigationVisibleCache_NavArea[iCacheSlot] = iNavArea;
	g_iNavigationVisibleCache_IgnoreEntity[iCacheSlot] = iIgnoreEntity;
	g_fNavigationVisibleCache_EyePos[iCacheSlot] = fEyePos;
	g_bNavigationVisibleCache_Result[iCacheSlot] = bResult;
	return bResult;
}

bool LBI_IsNavAreaPartiallyVisibleImpl(int iNavArea, const float fEyePos[3], int iIgnoreEntity = -1)
{
	float fOffset = (0.75 * HUMAN_HEIGHT);

	float fCenter[3]; LBI_GetNavAreaCenter(iNavArea, fCenter);
	fCenter[2] += fOffset;

	if (g_bPerformanceBudgetEnabled)
		TraceMetricsRecordTraceCall(TRACE_METRIC_NAV_VISIBLE);
	Handle hResult = TR_TraceRayFilterEx(fEyePos, fCenter, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, CTraceFilterNoNPCsOrPlayer, iIgnoreEntity);
	if (g_bPerformanceBudgetEnabled)
		TraceMetricsEndTrace();
	float fFraction = TR_GetFraction(hResult); delete hResult;
	if (fFraction == 1.0)return true;
	if (IsAiDegraded())return false;

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
		if (g_bPerformanceBudgetEnabled)
			TraceMetricsRecordTraceCall(TRACE_METRIC_NAV_VISIBLE);
		hResult = TR_TraceRayFilterEx(fEyePos, fCorner, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, CTraceFilterNoNPCsOrPlayer, iIgnoreEntity);
		if (g_bPerformanceBudgetEnabled)
			TraceMetricsEndTrace();
		fFraction = TR_GetFraction(hResult); delete hResult;
		if (fFraction == 1.0)return true;
	}

	return false;
}
