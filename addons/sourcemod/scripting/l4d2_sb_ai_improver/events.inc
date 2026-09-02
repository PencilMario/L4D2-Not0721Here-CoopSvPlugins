void Event_OnRoundStart(Event hEvent, const char[] sName, bool bBroadcast)
{
	ResetDataOnRoundChange();
}

public void Event_OnTraceDoorStateChanged(const char[] sOutput, int iCaller, int iActivator, float fDelay)
{
	if (iCaller > 0 && iCaller <= MAXENTITIES)
		g_fTraceDoorStateExpiry[iCaller] = 0.0;
}

void Event_OnRoundEnd(Event hEvent, const char[] sName, bool bBroadcast)
{
	ResetDataOnRoundChange();
}

float g_fClient_ThinkFunctionDelay[MAXPLAYERS+1];
void ResetDataOnRoundChange()
{
	ResetPerformanceBudgetCounters();
	g_iBotProcessing_ProcessedCount = 0;
	g_fBotProcessing_NextProcessTime = GetProcessCacheExpiry();
	g_fSurvivorBot_Grenade_NextThrowTime = g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + 5.0;
	ResetNavigationCaches();
	ResetTeamInventoryCaches();
	ResetPinnedReactionCaches();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (GetGameTime() > g_fClient_ThinkFunctionDelay[i])g_fClient_ThinkFunctionDelay[i] = GetGameTime() + 5.0;
		if (!IsClientInGame(i))continue;
		ResetClientPluginVariables(i);
	}
}

public void OnClientPutInServer(int iClient)
{
	OnClientJoinServer(iClient);
}

void OnClientJoinServer(int iClient)
{
	InvalidatePinnedRescueClient(iClient);
	InvalidateClientGlobalInfo(iClient);
	SDKHook(iClient, SDKHook_WeaponSwitch, OnSurvivorSwitchWeapon);
	SDKHook(iClient, SDKHook_OnTakeDamage, OnSurvivorTakeDamage);
	g_fClient_ThinkFunctionDelay[iClient] = GetGameTime() + 5.0;
	ResetClientPluginVariables(iClient);
}

public void OnClientDisconnect(int iClient)
{
	InvalidatePinnedRescueClient(iClient);
	InvalidateClientGlobalInfo(iClient);
	SDKUnhook(iClient, SDKHook_WeaponSwitch, OnSurvivorSwitchWeapon);
	SDKUnhook(iClient, SDKHook_OnTakeDamage, OnSurvivorTakeDamage);
	g_fClient_ThinkFunctionDelay[iClient] = GetGameTime() + 5.0;
	ResetClientPluginVariables(iClient);
}

void ResetClientPluginVariables(int iClient)
{
	g_bBotProcessing_IsProcessed[iClient] = false;
	InvalidateVisibilityCacheClient(iClient);
	g_bClientAimCacheValid[iClient] = false;
	g_iClientAimCacheGeneration[iClient] = 0;
	g_iClientCommandGeneration[iClient] = 0;

	g_iSurvivorBot_TargetInfected[iClient] = -1;
	g_iSurvivorBot_WitchTarget[iClient] = -1;
	g_iSurvivorBot_ThreatInfectedCount[iClient] = 0;
	g_iSurvivorBot_NearbyInfectedCount[iClient] = 0;
	g_iSurvivorBot_NearestInfectedCount[iClient] = 0;
	g_iSurvivorBot_GrenadeInfectedCount[iClient] = 0;
	g_iSurvivorBot_ScavengeItem[iClient] = -1;
	g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
	g_iSurvivorBot_DefibTarget[iClient] = -1;
	g_iSurvivorBot_Grenade_ThrowTarget[iClient] = -1;
	g_iClientNavArea[iClient] = 0;
	g_fClientInventory_Expiry[iClient] = 0.0;
	InvalidateClientGlobalInfo(iClient);
	g_fClientNavAreaCache_Expiry[iClient] = 0.0;
	g_fTakeCoverCache_Expiry[iClient] = 0.0;
	g_fTakeCoverCache_SearchDist[iClient] = -1.0;
	g_bTakeCoverCache_Result[iClient] = false;
	g_fSurvivorBot_AcidEscapeCache_Expiry[iClient] = 0.0;
	g_iSurvivorBot_AcidEscapeCache_Inflictor[iClient] = -1;
	g_bSurvivorBot_AcidEscapeCache_Result[iClient] = false;
	g_fPinnedReactionCache_Expiry[iClient] = 0.0;
	g_iSurvivorBot_MovePos_Priority[iClient] = 0;
	g_bSurvivorBot_TankRetreatActive[iClient] = false;

	g_sSurvivorBot_MovePos_Name[iClient][0] = 0;
	g_fSurvivorBot_MovePos_Tolerance[iClient] = -1.0;

	g_bSurvivorBot_IsWitchHarasser[iClient] = false;
	g_bSurvivorBot_ForceWeaponReload[iClient] = false;
	g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
	g_bSurvivorBot_ForceBash[iClient] = false;
	g_bSurvivorBot_PreventFire[iClient] = false;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = false;

	g_fSurvivorBot_PinnedReactTime[iClient] = GetGameTime();
	g_fSurvivorBot_NextPinnedRescueThinkTime[iClient] = GetGameTime();
	g_fSurvivorBot_NextUsePressTime[iClient] = GetGameTime() + 0.33;
	g_fSurvivorBot_NextScavengeItemScanTime[iClient] = GetGameTime() + 1.0;
	g_fSurvivorBot_BlockWeaponReloadTime[iClient] = GetGameTime();
	g_fSurvivorBot_BlockWeaponSwitchTime[iClient] = GetGameTime();
	g_fSurvivorBot_VomitBlindedTime[iClient] = GetGameTime();
	g_fSurvivorBot_TimeSinceLeftLadder[iClient] = GetGameTime();
	g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime();
	g_fSurvivorBot_MeleeAttackTime[iClient] = GetGameTime();
	g_fSurvivorBot_NextMoveCommandTime[iClient] = GetGameTime() + BOT_CMD_MOVE_INTERVAL;
	g_fSurvivorBot_LookPosition_Duration[iClient] = GetGameTime();
	g_fSurvivorBot_NextPressAttackTime[iClient] = GetGameTime();
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime();
	g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime();

	SetVectorToZero(g_fSurvivorBot_Grenade_ThrowPos[iClient]);
	SetVectorToZero(g_fSurvivorBot_Grenade_AimPos[iClient]);
	SetVectorToZero(g_fSurvivorBot_LookPosition[iClient]);
	SetVectorToZero(g_fSurvivorBot_MovePos_Position[iClient]);
	SetVectorToZero(g_fClientNavAreaCache_Position[iClient]);
	SetVectorToZero(g_fTakeCoverCache_ClientPos[iClient]);
	SetVectorToZero(g_fTakeCoverCache_SourcePos[iClient]);
	SetVectorToZero(g_fTakeCoverCache_ResultPos[iClient]);
	SetVectorToZero(g_fSurvivorBot_AcidEscapeCache_ClientPos[iClient]);
	SetVectorToZero(g_fSurvivorBot_AcidEscapeCache_ResultPos[iClient]);

	for (int i = 0; i < MAXENTITIES; i++)
	{
		g_iSurvivorBot_VisionMemory_State[iClient][i] = g_iSurvivorBot_VisionMemory_State_FOV[iClient][i] = 0;
		g_fSurvivorBot_VisionMemory_Time[iClient][i] = g_fSurvivorBot_VisionMemory_Time_FOV[iClient][i] = GetGameTime();
	}

	if (!IsValidClient(iClient) || !IsFakeClient(iClient) || GetClientTeam(iClient) != 2)
		return;

	L4D2_CommandABot(iClient, 0, BOT_CMD_RESET);
}

void Event_OnWeaponFire(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iItemFlags /*, iWeaponID */, iUserID, iClient;
	static char sWeaponName[64]/*, sClientName[128]*/;
	iUserID = hEvent.GetInt("userid");
	//iWeaponID = hEvent.GetInt("weaponid");
	iClient = GetClientOfUserId(iUserID);
	if (!IsFakeClient(iClient))return;
	g_fClientInventory_Expiry[iClient] = 0.0;

	hEvent.GetString("weapon", sWeaponName, sizeof(sWeaponName));

	if (!g_bInitItemFlags)
	{
		InitItemFlagMap();
		//if(g_bCvar_Debug)
		//	PrintToServer("Event_OnWeaponFire: g_hItemFlagMap not initialized, doing now");
	}
	g_hItemFlagMap.GetValue(sWeaponName, iItemFlags);

	if ( GetRandomInt(1, g_iCvar_FireBash_Chance1) == 1 && iItemFlags & FLAG_SHOTGUN && iItemFlags & FLAG_TIER1 )
	{
		g_bSurvivorBot_ForceBash[iClient] = true;
	}
	else if ( GetRandomInt(1, g_iCvar_FireBash_Chance2) == 1 && iItemFlags & FLAG_SNIPER && iItemFlags & FLAG_CSS )
	{
		g_bSurvivorBot_ForceBash[iClient] = true;
	}

	RequestFrame(NullifyAimPunch, iClient);
}

void NullifyAimPunch(int iClient)
{
	if(IsValidClient(iClient))
		SetEntPropVector(iClient, Prop_Send, "m_vecPunchAngle", view_as<float>({ 0.0, 0.0, 0.0 }));
}

void Event_OnPlayerDeath(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iVictim = GetClientOfUserId(hEvent.GetInt("userid"));
	int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	int iInfected = hEvent.GetInt("entityid");
	InvalidatePinnedRescueClient(iVictim);
	InvalidatePinnedRescueCoordinator(0, iAttacker);

	if (g_iSurvivorBot_TargetInfected[iAttacker] == iVictim || g_iSurvivorBot_TargetInfected[iAttacker] == iInfected)
	{
		g_iSurvivorBot_TargetInfected[iAttacker] = -1;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSurvivorBot_VisionMemory_State[i][iVictim] = g_iSurvivorBot_VisionMemory_State_FOV[i][iVictim] = 0;
		g_fSurvivorBot_VisionMemory_Time[i][iVictim] = g_fSurvivorBot_VisionMemory_Time_FOV[i][iVictim] = GetGameTime();
	}

	g_bInfectedBot_IsThrowing[iVictim] = false;
	g_fInfectedBot_CoveredInVomitTime[iVictim] = GetGameTime();
}

void Event_OnIncap(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iUserID, iSecondarySlot, iEntRef, iIndex;
	iUserID = hEvent.GetInt("userid");
	iClient = GetClientOfUserId(iUserID);
	iSecondarySlot = GetClientWeaponInventory(iClient, 1);

	if (iSecondarySlot != -1)
	{
		iEntRef = EntIndexToEntRef(iSecondarySlot);
		iIndex = g_hForbiddenItemList.FindValue(iEntRef);
		if (iIndex == -1)
			iIndex = g_hForbiddenItemList.Push(iEntRef);
		RegisterEntityListMask(iSecondarySlot, ENTITY_LIST_FORBIDDEN);
		g_hForbiddenItemList.Set(iIndex, iClient, 1);
	}
}

void Event_OnRevive(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iUserID, iOwner, iEntRef, iEntIndex;
	iUserID = hEvent.GetInt("subject");
	iClient = GetClientOfUserId(iUserID);
	InvalidatePinnedRescueClient(iClient);

	for (int i = 0; i < g_hForbiddenItemList.Length; i++)
	{
		iEntRef = g_hForbiddenItemList.Get(i);
		iEntIndex = EntRefToEntIndex(iEntRef);
		iOwner = g_hForbiddenItemList.Get(i, 1);
		if (iEntIndex == INVALID_ENT_REFERENCE || !IsEntityExists(iEntIndex) || iClient == iOwner)
		{
			UnregisterEntityListMaskFromEntRef(iEntRef, ENTITY_LIST_FORBIDDEN);
			g_hForbiddenItemList.Erase(i);
			continue;
		}
	}
}

// Mark entity as used by certain client
void Event_OnPlayerUse(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iEntity;
	iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	iEntity = hEvent.GetInt("targetid");

	g_iItem_Used[iEntity] |= (1 << (iClient - 1));
	if (iClient >= 1 && iClient <= MaxClients)
		g_fClientInventory_Expiry[iClient] = 0.0;
	if (IsFakeClient(iClient) && iEntity == g_iSurvivorBot_ScavengeItem[iClient] && g_iWeaponID[iEntity])
	{
		ClearMoveToPosition(iClient, "ScavengeItem");
		g_iSurvivorBot_ScavengeItem[iClient] = -1;
		g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
	}
}

void Event_OnSurvivorGrabbed(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iVictim = GetClientOfUserId(hEvent.GetInt("victim"));
	int iAttacker = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!IsValidClient(iVictim))return;
	if (!IsValidClient(iAttacker))
		iAttacker = L4D_GetPinnedInfected(iVictim);

	StartPinnedRescueCoordinator(iVictim, iAttacker);
}

void Event_OnSurvivorReleased(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iVictim = GetClientOfUserId(hEvent.GetInt("victim"));
	int iAttacker = GetClientOfUserId(hEvent.GetInt("userid"));
	InvalidatePinnedRescueCoordinator(iVictim, iAttacker);
}

void Event_OnPlayerSpawn(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	InvalidatePinnedRescueClient(iClient);
	InvalidateVisibilityCacheClient(iClient);
	InvalidateClientGlobalInfo(iClient);
	RequestPinnedRescueCoordinatorRecovery();
}

void Event_OnPlayerTeam(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	InvalidatePinnedRescueClient(iClient);
	InvalidateVisibilityCacheClient(iClient);
	InvalidateClientGlobalInfo(iClient);
	RequestPinnedRescueCoordinatorRecovery();
}

void Event_OnPlayerReplacement(Event hEvent, const char[] sName, bool bBroadcast)
{
	int iPlayer = GetClientOfUserId(hEvent.GetInt("player"));
	int iBot = GetClientOfUserId(hEvent.GetInt("bot"));
	InvalidatePinnedRescueClient(iPlayer);
	InvalidatePinnedRescueClient(iBot);
	InvalidateVisibilityCacheClient(iPlayer);
	InvalidateVisibilityCacheClient(iBot);
	InvalidateClientGlobalInfo(iPlayer);
	InvalidateClientGlobalInfo(iBot);
	RequestPinnedRescueCoordinatorRecovery();
}

void Event_OnChargeStart(Event hEvent, const char[] sName, bool bBroadcast)
{
	if (!g_bCvar_ChargerEvasion)return;

	int iCharger = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!IsValidClient(iCharger))return;

	float fChargerForward[3]; GetClientAbsAngles(iCharger, fChargerForward);
	GetAngleVectors(fChargerForward, fChargerForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fChargerForward, fChargerForward);

	int iMoveArea;
	float fChargeDist, fChargeHitDist;
	float fChargeHitPos[3], fClientRight[3], fMovePos[3];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || !IsFakeClient(i) || !FEntityInViewAngle(iCharger, i, 5.0) || GetClientDistance(i, iCharger, true) <= 36864.0 || !IsVisibleEntity(iCharger, i, MASK_PLAYERSOLID))
			continue;

		MakeVectorFromPoints(g_fClientAbsOrigin[i], g_fClientAbsOrigin[iCharger], fClientRight);
		GetAngleVectors(fClientRight, NULL_VECTOR, fClientRight, NULL_VECTOR);
		NormalizeVector(fClientRight, fClientRight);

		fChargeDist = GetVectorDistance(g_fClientCenteroid[i], g_fClientCenteroid[iCharger]);
		fChargeHitPos[0] = g_fClientCenteroid[iCharger][0] + (fChargerForward[0] * fChargeDist);
		fChargeHitPos[1] = g_fClientCenteroid[iCharger][1] + (fChargerForward[1] * fChargeDist);
		fChargeHitPos[2] = g_fClientCenteroid[iCharger][2] + (fChargerForward[2] * fChargeDist);

		fChargeHitDist = GetVectorDistance(g_fClientCenteroid[i], fChargeHitPos);
		for (int k = 1; k <= 2; k++)
		{
			fMovePos[0] = g_fClientAbsOrigin[i][0] + (fClientRight[0] * ((k == 1 ? 256.0 : -256.0) - fChargeHitDist));
			fMovePos[1] = g_fClientAbsOrigin[i][1] + (fClientRight[1] * ((k == 1 ? 256.0 : -256.0) - fChargeHitDist));
			fMovePos[2] = g_fClientAbsOrigin[i][2] + (fClientRight[2] * ((k == 1 ? 256.0 : -256.0) - fChargeHitDist));

			iMoveArea = LBI_GetNearestNavAreaCached(fMovePos);
			if (iMoveArea)
			{
				LBI_GetClosestPointOnNavArea(iMoveArea, fMovePos, fMovePos);
				if (!FVectorInViewAngle(iCharger, fMovePos, 5.0) && LBI_IsReachableNavArea(i, iMoveArea))
				{
					float fMoveDist = GetClientTravelDistance(i, fMovePos, true);
					if (fMoveDist != -1.0 && fMoveDist <= 147456.0)
					{
						SetMoveToPosition(i, fMovePos, 3, "EvadeCharge");
						break;
					}
				}
			}

			if (k == 2)TakeCoverFromEntity(i, iCharger, 512.0);
		}
	}
}

void Event_OnWitchHaraserSet(Event hEvent, const char[] sName, bool bBroadcast)
{
	static int iClient, iUserID;
	iUserID = hEvent.GetInt("userid");
	iClient = GetClientOfUserId(iUserID);
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || GetClientTeam(iClient) != 2)return;

	int iWitch = hEvent.GetInt("witchid");

	int iWitchRef;
	for (int i = 0; i < g_hWitchList.Length; i++)
	{
		iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
		if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
		{
			g_hWitchList.Erase(i);
			continue;
		}
		if (iWitchRef == iWitch)
		{
			g_hWitchList.Set(i, iUserID, 1);
			break;
		}
	}
}
