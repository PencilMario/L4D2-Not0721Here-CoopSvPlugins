void SurvivorBotThink(int iClient, int &iButtons, int iWpnSlots[6])
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	SurvivorBotThinkImpl(iClient, iButtons, iWpnSlots);
	LogSlowCalculation("SurvivorBotThink", fStartedAt, iClient);
}

void SurvivorBotThinkImpl(int iClient, int &iButtons, int iWpnSlots[6])
{
	g_iSurvivorBot_DefibTarget[iClient] = -1;
	g_bSurvivorBot_PreventFire[iClient] = false;

	if (g_bSurvivorBot_TankRetreatActive[iClient] && (L4D_IsPlayerIncapacitated(iClient) || L4D_IsPlayerHangingFromLedge(iClient)))
	{
		StopTankRetreat(iClient);
	}

	int iCurWeapon = L4D_GetPlayerCurrentWeapon(iClient);

	static int iTeamLeader, iGameDifficulty, iDefibTarget, iTeamCount, iAlivePlayers, iTankRock, iTankTarget, iWitchHarasser, iTankProp;
	static bool bFriendIsNearBoomer, bFriendIsNearThrowArea, bTeamHasHumanPlayer;
	if (!g_bBotProcessing_IsProcessed[iClient] && GetGameTime() > g_fBotProcessing_NextProcessTime)
	{
		g_iSurvivorBot_NearbyFriends[iClient] = 0;
		if (g_iBotProcessing_ProcessedCount == 0)
			RefreshCommonInfectedMeleeTargetMarks();
		g_iSurvivorBot_TargetInfected[iClient] = GetClosestInfected(iClient, 4000.0);
		float fInfectedCountRanges[3] = {125.0, 300.0, 500.0};
		int iInfectedCounts[3];
		GetInfectedCounts(iClient, fInfectedCountRanges, iInfectedCounts);
		g_iSurvivorBot_ThreatInfectedCount[iClient] = iInfectedCounts[0];
		g_iSurvivorBot_NearestInfectedCount[iClient] = iInfectedCounts[1];
		g_iSurvivorBot_NearbyInfectedCount[iClient] = iInfectedCounts[2];
		if (g_bCvar_GrenadeThrow_Enabled && iWpnSlots[2] != -1)
		{
			g_iSurvivorBot_GrenadeInfectedCount[iClient] = GetInfectedCount(iClient, g_fCvar_GrenadeThrow_ThrowRange, CalculateGrenadeThrowInfectedCount(), _, false);
		}

		iTeamLeader = iClient;
		iGameDifficulty = GetCurrentGameDifficulty();
		iTeamCount = GetTeamPlayerCount(2);
		iAlivePlayers = 1;

		iTankTarget = 0;
		g_iSurvivorBot_PinnedFriend[iClient] = 0;
		g_iSurvivorBot_IncapacitatedFriend[iClient] = 0;

		bFriendIsNearThrowArea = false;
		bFriendIsNearBoomer = false;
		bTeamHasHumanPlayer = false;

		int iTeam;
		L4D2ZombieClassType iClientClass;
		float fCurDist, fCurDist2;
		float fLastDist = -1.0;
		float fLastDist2 = -1.0;
		float fLastDist3 = -1.0;
		float fLastDist4 = -1.0;
		bool bUseFlowDist = ShouldUseFlowDistance();

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			fCurDist = GetClientDistance(iClient, i, true);
			iTeam = GetClientTeam(i);

			if (iTeam == 2)
			{
				if (!bTeamHasHumanPlayer || !IsFakeClient(i))
				{
					fCurDist2 = ((bUseFlowDist && !bTeamHasHumanPlayer) ? L4D2Direct_GetFlowDistance(i) : fCurDist);
					if (fLastDist4 == -1.0 || bUseFlowDist && !bTeamHasHumanPlayer && fCurDist2 > fLastDist4 || fCurDist2 < fLastDist4)
					{
						iTeamLeader = i;
						//if (g_iCvar_Debug & DEBUG_NAV && g_iCvar_DebugClient == iClient)
						//	g_iTeamLeader = i;
						fLastDist4 = fCurDist2;
						if (!bTeamHasHumanPlayer)bTeamHasHumanPlayer = (!IsFakeClient(i));
					}
				}

				if (i == iClient)
					continue;

				iAlivePlayers++;

				if ((fLastDist == -1.0 || fCurDist < fLastDist) && L4D_IsPlayerPinned(i))
				{
					g_iSurvivorBot_PinnedFriend[iClient] = i;
					fLastDist = fCurDist;
				}

				if ((fLastDist2 == -1.0 || fCurDist < fLastDist2) && L4D_IsPlayerIncapacitated(i))
				{
					g_iSurvivorBot_IncapacitatedFriend[iClient] = i;
					fLastDist2 = fCurDist;
				}

				if (!bFriendIsNearBoomer)
					bFriendIsNearBoomer = IsSurvivorNearBoomer(i);

				if (fCurDist <= 262144.0 && !L4D_IsPlayerIncapacitated(i) && !L4D_IsPlayerPinned(i))
					g_iSurvivorBot_NearbyFriends[iClient] += 1;

				if (!bFriendIsNearThrowArea)
					bFriendIsNearThrowArea = (GetVectorDistance(g_fClientAbsOrigin[i], g_fSurvivorBot_Grenade_ThrowPos[iClient], true) <= BOT_GRENADE_CHECK_RADIUS_SQR && IsEntityExists(g_iSurvivorBot_Grenade_ThrowTarget[iClient]) && SurvivorHasGrenade(iClient) == 2);
			}
			else if (iTeam == 3 && !L4D_IsPlayerGhost(i))
			{
				iClientClass = L4D2_GetPlayerZombieClass(i);
				if ((fLastDist3 == -1.0 || fCurDist < fLastDist3) && iClientClass == L4D2ZombieClass_Tank && !L4D_IsPlayerIncapacitated(i) && (fCurDist <= 1048576.0 || fCurDist <= 16777216.0 && IsVisibleEntity(iClient, i)))
				{
					iTankTarget = i;
					fLastDist3 = fCurDist;
				}
			}
		}

		iDefibTarget = 0;
		if (g_bCvar_DefibRevive_Enabled)
		{
			fLastDist = -1.0;
			int iSurvivor = INVALID_ENT_REFERENCE;
			while ((iSurvivor = FindEntityByClassname(iSurvivor, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iClient, iSurvivor, true);
				if (fLastDist == -1.0 || fCurDist < fLastDist)
				{
					iDefibTarget = iSurvivor;
					fLastDist = fCurDist;
				}
			}
		}

		iTankProp = -1;
		iTankRock = -1;
		if (iTankTarget != 0)
		{
			fLastDist = -1.0;
			int iPropRock = INVALID_ENT_REFERENCE;
			while ((iPropRock = FindEntityByClassname(iPropRock, "tank_rock")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iClient, iPropRock, true);
				if (fLastDist != -1.0 && fCurDist >= fLastDist || !IsVisibleEntity(iClient, iPropRock))
					continue;

				iTankRock = iPropRock;
				fLastDist = fCurDist;
			}

			fLastDist = -1.0;
			iPropRock = INVALID_ENT_REFERENCE;
			while ((iPropRock = FindEntityByClassname(iPropRock, "prop_car_alarm")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iTankTarget, iPropRock, true);
				if (fCurDist > 250000.0 || fLastDist != -1.0 && fCurDist >= fLastDist || !IsVisibleEntity(iTankTarget, iPropRock) || !IsVisibleEntity(iClient, iPropRock))
					continue;

				iTankProp = iPropRock;
				fLastDist = fCurDist;
			}
			iPropRock = INVALID_ENT_REFERENCE;
			while ((iPropRock = FindEntityByClassname(iPropRock, "prop_physics")) != INVALID_ENT_REFERENCE)
			{
				fCurDist = GetEntityDistance(iTankTarget, iPropRock, true);
				if (fCurDist > 250000.0 || fLastDist != -1.0 && fCurDist >= fLastDist || !GetEntProp(iPropRock, Prop_Send, "m_hasTankGlow") || !IsVisibleEntity(iTankTarget, iPropRock) || !IsVisibleEntity(iClient, iPropRock))
					continue;

				iTankProp = iPropRock;
				fLastDist = fCurDist;
			}
		}

		g_iSurvivorBot_WitchTarget[iClient] = -1;

		iWitchHarasser = 0;
		fLastDist = -1.0;
		int iWitchRef, iHarasserRef;
		for (int i = 0; i < g_hWitchList.Length; i++)
		{
			iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
			if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
			{
				g_hWitchList.Erase(i);
				continue;
			}

			iHarasserRef = g_hWitchList.Get(i, 1);
			if (iHarasserRef != -1)
				iHarasserRef = GetClientOfUserId(iHarasserRef);
			if (iWitchHarasser && !iHarasserRef) continue;

			fCurDist = GetEntityDistance(iClient, iWitchRef, true);
			if (fLastDist != -1.0 && fCurDist >= fLastDist) continue;

			g_iSurvivorBot_WitchTarget[iClient] = iWitchRef;
			iWitchHarasser = iHarasserRef; fLastDist = fCurDist;
		}
		g_bSurvivorBot_IsWitchHarasser[iClient] = (iWitchHarasser == iClient);

		g_iBotProcessing_ProcessedCount++;
		g_bBotProcessing_IsProcessed[iClient] = true;
	}

	if (L4D_IsPlayerHangingFromLedge(iClient))
		return;

	if (GetEntityMoveType(iClient) == MOVETYPE_LADDER)
	{
		g_fSurvivorBot_TimeSinceLeftLadder[iClient] = GetGameTime() + 2.0;
		return;
	}

	if (IsValidVector(g_fSurvivorBot_LookPosition[iClient]))
	{
		if (GetGameTime() < g_fSurvivorBot_LookPosition_Duration[iClient])
		{
			SnapViewToPosition(iClient, g_fSurvivorBot_LookPosition[iClient]);
		}
		else
		{
			SetVectorToZero(g_fSurvivorBot_LookPosition[iClient]);
		}
	}

	if (iCurWeapon != -1)
	{
		if (iCurWeapon == iWpnSlots[0] && GetSurvivorBotWeaponPreference(iClient) == L4D_WEAPON_PREFERENCE_SECONDARY)
		{
			SwitchWeaponSlot(iClient, 1);
		}

		if (g_bSurvivorBot_ForceWeaponReload[iClient])
		{
			iButtons |= IN_RELOAD;
			g_bSurvivorBot_ForceWeaponReload[iClient] = false;
		}
		else if (GetGameTime() <= g_fSurvivorBot_BlockWeaponReloadTime[iClient])
		{
			iButtons &= ~IN_RELOAD;
		}

		if (!SurvivorBot_CanFreelyFireWeapon(iClient))
		{
			g_bSurvivorBot_PreventFire[iClient] = true;
			iButtons &= ~IN_ATTACK;
		}

		if (g_bSurvivorBot_ForceBash[iClient])
		{
			g_bSurvivorBot_ForceBash[iClient] = false;
			iButtons |= IN_ATTACK2;
		}

		// if we're not occupied and our primary is loaded, switch to pistol (to reload)
		if (iCurWeapon == iWpnSlots[0] && !IsWeaponReloading(iCurWeapon, false) && GetGameTime() > GetWeaponNextFireTime(iCurWeapon)
			&& LBI_IsSurvivorBotAvailable(iClient) && !LBI_IsSurvivorInCombat(iClient) && ( g_iClientInvFlags[iClient] & FLAG_M60 || GetWeaponClip1(iCurWeapon) == GetWeaponClipSize(iCurWeapon) )
			&& g_iClientInvFlags[iClient] & (FLAG_PISTOL | FLAG_PISTOL_EXTRA) && GetWeaponClip1(iWpnSlots[1]) != GetWeaponClipSize(iWpnSlots[1]))
		{
			g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
			SwitchWeaponSlot(iClient, 1);
		}
	}

	int iPinnedFriend = g_iSurvivorBot_PinnedFriend[iClient];
	if (IsValidClient(g_iSurvivorBot_RescueVictim[iClient]))
		iPinnedFriend = g_iSurvivorBot_RescueVictim[iClient];
	if (IsValidVector(g_fSurvivorBot_MovePos_Position[iClient]))
	{
		float fMovePos[3]; fMovePos = g_fSurvivorBot_MovePos_Position[iClient];
		float fMoveDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true);
		float fMoveTolerance = g_fSurvivorBot_MovePos_Tolerance[iClient];
		float fMoveDuration = g_fSurvivorBot_MovePos_Duration[iClient];

		if (GetGameTime() > fMoveDuration || fMoveTolerance >= 0.0 && fMoveDist <= (fMoveTolerance*fMoveTolerance) ||
			!g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] && LBI_IsDamagingPosition(fMovePos) || !LBI_IsReachablePosition(iClient, fMovePos, false) ||
			IsPinnedFriendMoveBlocked(iPinnedFriend)
		)
		{
			ClearMoveToPosition(iClient);
		}
		else if (GetGameTime() > g_fSurvivorBot_NextMoveCommandTime[iClient])
		{
			L4D2_CommandABot(iClient, 0, BOT_CMD_MOVE, fMovePos);
			g_fSurvivorBot_NextMoveCommandTime[iClient] = GetGameTime() + BOT_CMD_MOVE_INTERVAL;
		}
	}

	int iInfectedTarget = g_iSurvivorBot_TargetInfected[iClient];
	// PINNED FRIEND RESCUE
	float fPinnedRescueNow = GetGameTime();
	if (g_iCvar_HelpPinnedFriend_Enabled != 0 && fPinnedRescueNow > g_fSurvivorBot_PinnedReactTime[iClient]
		&& IsPinnedFriendReactionAllowed(iClient, iPinnedFriend) && TryBeginPinnedRescueThink(iClient, fPinnedRescueNow))
	{
		int iAttacker = g_iSurvivorBot_RescueAttacker[iClient];
		if (IsValidClient(iAttacker))
		{
			float fFriendDist = GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iPinnedFriend], true);
			bool bCanShoot = (iCurWeapon != -1 && g_iCvar_HelpPinnedFriend_Enabled & (1 << 0) != 0 && fFriendDist <= g_fCvar_HelpPinnedFriend_ShootRange_Sqr
				&& (iCurWeapon != iWpnSlots[1] || !SurvivorHasMeleeWeapon(iClient) || GetClientDistance(iClient, iAttacker, true) <= g_fCvar_ImprovedMelee_AttackRange_Sqr)
				&& SurvivorBot_AbleToShootWeapon(iClient) && CheckIfCanRescueImmobilizedFriend(iClient));

			int iCanShove;
			if (g_iCvar_HelpPinnedFriend_Enabled & (1 << 1) != 0)
			{
				iCanShove = (fFriendDist <= g_fCvar_HelpPinnedFriend_ShoveRange_Sqr ? 1 : (GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iAttacker], true) <= g_fCvar_HelpPinnedFriend_ShoveRange_Sqr ? 2 : 0));
			}

			L4D2ZombieClassType iZombieClass = g_iPinnedRescueClass[iPinnedFriend];
			float fAttackerAimPos[3];
			bool bAttackerVisible;
			if (bCanShoot)
			{
				if (iZombieClass == L4D2ZombieClass_Jockey || iZombieClass == L4D2ZombieClass_Smoker)
				{
					bAttackerVisible = GetPinnedRescueAimPosition(iAttacker, iZombieClass, fAttackerAimPos);
					if (bAttackerVisible)
						bAttackerVisible = IsPinnedRescueAimVisible(iClient, fAttackerAimPos);
				}
				else
				{
					GetTargetAimPart(iClient, iAttacker, fAttackerAimPos);
					bAttackerVisible = HasVisualContactWithEntity(iClient, iAttacker, false, fAttackerAimPos);
				}
			}

			if (iZombieClass != L4D2ZombieClass_Smoker)
			{
				if (iWpnSlots[0] != -1 && g_iWeapon_AmmoLeft[iWpnSlots[0]] > 0 && g_iWeapon_Clip1[iWpnSlots[0]] > 0 && iCurWeapon == iWpnSlots[1] && SurvivorHasMeleeWeapon(iClient) && fFriendDist > g_fCvar_ImprovedMelee_AimRange_Sqr)
				{
					g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
					SwitchWeaponSlot(iClient, 0);
				}
				else
				{
					if (bCanShoot && fFriendDist <= 262144.0 && iCurWeapon == iWpnSlots[0] && IsWeaponReloading(iCurWeapon) && GetWeaponClip1(iWpnSlots[1]) > 0 && !SurvivorHasShotgun(iClient) && !SurvivorHasSniperRifle(iClient) && !SurvivorHasMeleeWeapon(iClient))
					{
						g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
						SwitchWeaponSlot(iClient, 1);
					}
				}

				if (iCanShove != 0 && iZombieClass != L4D2ZombieClass_Charger && !L4D_IsPlayerIncapacitated(iClient))
				{
					SnapViewToPosition(iClient, (iCanShove == 1 ? g_fClientCenteroid[iPinnedFriend] : g_fClientCenteroid[iAttacker]));
					iButtons |= IN_ATTACK2;
				}
				else if (bCanShoot && bAttackerVisible)
				{
					SnapViewToPosition(iClient, fAttackerAimPos);
					PressAttackButton(iClient, iButtons); // help pinned
				}
			}
			else
			{
				if (!L4D_IsPlayerIncapacitated(iClient))
				{
					if (iCanShove != 0)
					{
						SnapViewToPosition(iClient, (iCanShove == 1 ? g_fClientCenteroid[iPinnedFriend] : g_fClientCenteroid[iAttacker]));
						iButtons |= IN_ATTACK2;
					}
				}

				if (bCanShoot)
				{
					if (bAttackerVisible)
					{
						SnapViewToPosition(iClient, fAttackerAimPos);
						PressAttackButton(iClient, iButtons); // help pinned
					}
				}
			}
		}
	}
	// END PINNED FRIEND RESCUE

	bool bTankRetreat = false;
	if (IsValidClient(iTankTarget) && IsPlayerAlive(iTankTarget))
	{
		int iVictim = g_iInfectedBot_CurrentVictim[iTankTarget];
		float fTankDist = GetClientDistance(iClient, iTankTarget, true);
		float fHeightDist = (fTankDist + (g_fClientAbsOrigin[iClient][2] - g_fClientAbsOrigin[iTankTarget][2]));
		if (fHeightDist <= 1638400.0 && (g_bCvar_AvoidTanksWithProp && IsEntityExists(iTankProp) || g_bCvar_TakeCoverFromRocks && g_bInfectedBot_IsThrowing[iTankTarget]) && (iVictim == iClient || GetClientDistance(iClient, iVictim, true) <= 65536.0) && IsVisibleEntity(iClient, iTankTarget, MASK_SHOT_HULL))
		{
			if (strcmp(g_sSurvivorBot_MovePos_Name[iClient], "TakeCover") != 0)
			{
				TakeCoverFromEntity(iClient, (IsEntityExists(iTankProp) ? iTankProp : iTankTarget), 768.0);
			}
		}
		else
		{
			bool bTankVisible = IsVisibleEntity(iClient, iTankTarget, MASK_SHOT_HULL);
			if (!g_bInfectedBot_IsThrowing[iTankTarget] || !bTankVisible)
			{
				ClearMoveToPosition(iClient, "TakeCover");
			}
			if (!L4D_IsPlayerIncapacitated(iClient) && (fTankDist <= 147456.0 || fTankDist <= 589824.0 && bTankVisible))
			{
				bTankRetreat = true;
				L4D2_CommandABot(iClient, iTankTarget, BOT_CMD_RETREAT);
				g_bSurvivorBot_TankRetreatActive[iClient] = true;
			}
		}

		if (g_bCvar_TankRock_ShootEnabled && g_iCvar_TankRockHealth > 0 && IsEntityExists(iTankRock))
		{
			float fRockPos[3]; GetEntityCenteroid(iTankRock, fRockPos);

			if (GetVectorDistance(g_fClientEyePos[iClient], fRockPos, true) <= g_fCvar_TankRock_ShootRange && SurvivorBot_AbleToShootWeapon(iClient) &&
				(iCurWeapon != iWpnSlots[1] || !SurvivorHasMeleeWeapon(iClient)) && !IsSurvivorBusy(iClient) && HasVisualContactWithEntity(iClient, iTankRock, false, fRockPos))
			{
				SnapViewToPosition(iClient, fRockPos);
				PressAttackButton(iClient, iButtons); // shoot tank rock
			}
		}
	}
	if (g_bSurvivorBot_TankRetreatActive[iClient] && !bTankRetreat)
	{
		StopTankRetreat(iClient);
	}

	int iWitchTarget = g_iSurvivorBot_WitchTarget[iClient];
	if (IsEntityExists(iWitchTarget) && GetEntityHealth(iWitchTarget) > 0)
	{
		float fWitchOrigin[3]; GetEntityAbsOrigin(iWitchTarget, fWitchOrigin);
		float fWitchDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fWitchOrigin, true);

		float fFirePos[3];
		GetTargetAimPart(iClient, iWitchTarget, fFirePos);

		int iHasShotgun = SurvivorHasShotgun(iClient);

		if (iWitchHarasser == -1 || IsValidClient(iWitchHarasser))
		{
			if ((iCurWeapon == iWpnSlots[0] || iCurWeapon == iWpnSlots[1]) && SurvivorBot_AbleToShootWeapon(iClient))
			{
				float fShootRange = g_fCvar_TargetSelection_ShootRange;
				if (iCurWeapon == iWpnSlots[1])
				{
					if (!SurvivorHasMeleeWeapon(iClient))fShootRange = g_fCvar_TargetSelection_ShootRange4;
					else fShootRange = g_fCvar_ImprovedMelee_AttackRange;
				}
				else if (iHasShotgun)fShootRange = g_fCvar_TargetSelection_ShootRange2;
				else if (SurvivorHasSniperRifle(iClient))fShootRange = g_fCvar_TargetSelection_ShootRange3;

				bool bWitchVisible = HasVisualContactWithEntity(iClient, iWitchTarget, false);
				if (fWitchDist <= (fShootRange*fShootRange) && bWitchVisible)
				{
					SnapViewToPosition(iClient, fFirePos);
					bool bFired = PressAttackButton(iClient, iButtons); // shoot witch
					if (iHasShotgun == 1 && bFired)g_bSurvivorBot_ForceBash[iClient] = true;

					if (fShootRange != g_fCvar_TargetSelection_ShootRange2 && fShootRange != g_fCvar_ImprovedMelee_AttackRange)
					{
						ClearMoveToPosition(iClient, "GoToWitch");
					}
				}
				else if (iWitchHarasser != iClient && fWitchDist <= 4000000.0)
				{
					SetMoveToPosition(iClient, fWitchOrigin, 3, "GoToWitch", 0.0, (( bWitchVisible && (iWitchHarasser == -1 || !L4D_IsPlayerIncapacitated(iWitchHarasser)) ) ? (fShootRange > 192.0 ? 192.0 : fShootRange) : 0.0), true);
				}
			}

			if (iWitchHarasser == iClient && fWitchDist <= 1048576.0 && !L4D_IsPlayerIncapacitated(iClient))
			{
				L4D2_CommandABot(iClient, iWitchTarget, BOT_CMD_RETREAT);
			}
		}
		else
		{
			float fWalkDist = g_fCvar_WitchBehavior_WalkWhenNearby;
			if (fWalkDist != 0.0 && fWitchDist <= (fWalkDist*fWalkDist) && (GetEntPropFloat(iWitchTarget, Prop_Send, "m_rage") <= 0.2 && GetEntPropFloat(iWitchTarget, Prop_Send, "m_wanderrage") <= 0.66) && !LBI_IsSurvivorInCombat(iClient))
			{
				iButtons |= IN_SPEED;
			}

			int iCrowning = g_iCvar_WitchBehavior_AllowCrowning;
			if ((iCrowning == 2 || iCrowning == 1 && !bTeamHasHumanPlayer) && iCurWeapon == iWpnSlots[0] && fWitchDist <= 1048576.0 && !L4D_IsPlayerOnThirdStrike(iClient) && (!IsValidClient(iTeamLeader) || fWitchDist <= 262144.0) && !IsWeaponReloading(iCurWeapon, false) && iHasShotgun && IsVisibleEntity(iClient, iWitchTarget))
			{
				if (fWitchDist <= 4096.0)
				{
					ClearMoveToPosition(iClient, "GoToWitch");
					SnapViewToPosition(iClient, fFirePos);
					bool bFired = PressAttackButton(iClient, iButtons); // shoot witch
					if (iHasShotgun == 1 && bFired)g_bSurvivorBot_ForceBash[iClient] = true;
				}
				else if (LBI_IsSurvivorBotAvailable(iClient))
				{
					bool bApproachWitch = !ShouldUseFlowDistance();
					if (!bApproachWitch)
					{
						Address pArea = L4D2Direct_GetTerrorNavArea(fWitchOrigin);
						bApproachWitch = (pArea != Address_Null && L4D2Direct_GetTerrorNavAreaFlow(pArea) >= L4D2Direct_GetFlowDistance(iClient));
					}
					if (bApproachWitch)SetMoveToPosition(iClient, fWitchOrigin, 2, "GoToWitch", 0.0, 0.0, true);

					if (fWitchDist <= 16384.0)
					{
						SnapViewToPosition(iClient, fFirePos);
					}
				}
			}
		}
	}

	float fInfectedDist = -1.0;
	if (IsEntityExists(iInfectedTarget))
	{
		float fInfectedPos[3]; GetEntityCenteroid(iInfectedTarget, fInfectedPos);
		float fInfectedOrigin[3]; GetEntityAbsOrigin(iInfectedTarget, fInfectedOrigin);
		fInfectedDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fInfectedOrigin, true);

		L4D2ZombieClassType iInfectedClass = L4D2ZombieClass_NotInfected;
		if (IsValidClient(iInfectedTarget))iInfectedClass = L4D2_GetPlayerZombieClass(iInfectedTarget);

		if (g_bCvar_ImprovedMelee_Enabled)
		{
			int iMeleeType = SurvivorHasMeleeWeapon(iClient);
			if (iMeleeType != 0)
			{
				if (iCurWeapon == iWpnSlots[1])
				{
					float fAimPosition[3]; GetClosestToEyePosEntityBonePos(iClient, iInfectedTarget, fAimPosition);
					float fMeleeDistance = GetVectorDistance(g_fClientEyePos[iClient], fAimPosition, true);

					if (fMeleeDistance <= g_fCvar_ImprovedMelee_AimRange_Sqr)
					{
						g_fSurvivorBot_BlockWeaponSwitchTime[iClient] = (GetGameTime() + (iMeleeType == 2 ? 3.0 : 1.0));
						SnapViewToPosition(iClient, fAimPosition);
					}

					if (!g_bSurvivorBot_PreventFire[iClient] && fMeleeDistance <= g_fCvar_ImprovedMelee_AttackRange_Sqr && (iGameDifficulty == 4 || (!IsSurvivorBusy(iClient)
						|| g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, (float(g_iSurvivorBot_NearbyFriends[iClient]) / (iTeamCount - 1))))))
					{
						float fAttackTime = (iMeleeType == 2 ? GetRandomFloat(0.33, 0.8) : GetRandomFloat(0.1, 0.33));
						g_fSurvivorBot_MeleeAttackTime[iClient] = (GetGameTime() + fAttackTime);
					}

					if (GetGameTime() < g_fSurvivorBot_MeleeAttackTime[iClient])
					{
						bool bShouldShove = (iInfectedClass != L4D2ZombieClass_Charger && GetRandomInt(1, (iMeleeType == 2 ? 200 : g_iCvar_ImprovedMelee_ShoveChance)) == 1
							&& (!g_bExtensionActions || iInfectedClass != L4D2ZombieClass_NotInfected || !IsCommonInfectedStumbled(iInfectedTarget)));
						iButtons |= ( bShouldShove ? IN_ATTACK2 : IN_ATTACK );
					}

					bool bStopApproaching = true;
					if (g_fCvar_ImprovedMelee_ApproachRange > 0.0 && GetGameTime() > g_fSurvivorBot_MeleeApproachTime[iClient] && !IsSurvivorBotBlindedByVomit(iClient) && !IsValidClient(iPinnedFriend)
						&& (!IsValidClient(iTankTarget) || GetClientDistance(iClient, iTankTarget, true) > 1048576.0) && LBI_IsReachableEntity(iClient, iInfectedTarget) && !IsFinaleEscapeVehicleArrived()
						&& (iInfectedClass == L4D2ZombieClass_NotInfected || (L4D_IsPlayerStaggering(iInfectedTarget) || L4D_GetPinnedSurvivor(iInfectedTarget) != 0) && !L4D_IsAnySurvivorInCheckpoint()))
					{
						Address pArea;
						float fMovePos[3]; GetEntityAbsOrigin(iInfectedTarget, fMovePos);
						if (!ShouldUseFlowDistance() || (pArea = L4D2Direct_GetTerrorNavArea(fMovePos)) == Address_Null || L4D2Direct_GetTerrorNavAreaFlow(pArea) >= (L4D2Direct_GetFlowDistance(iClient) - SquareRoot(g_fCvar_ImprovedMelee_ApproachRange*0.5)))
						{
							float fLeaderDist = ((iInfectedClass == L4D2ZombieClass_NotInfected && iTeamLeader != iClient && IsValidClient(iTeamLeader)) ? GetClientTravelDistance(iTeamLeader, fMovePos, true) : -2.0);
							if (fLeaderDist == -2.0 || fLeaderDist != -1.0 && fLeaderDist <= (g_fCvar_ImprovedMelee_ApproachRange * 0.75))
							{
								float fTravelDist = GetNavDistance(fMovePos, g_fClientAbsOrigin[iClient], iInfectedTarget);
								if (fTravelDist != -1.0 && fTravelDist <= g_fCvar_ImprovedMelee_ApproachRange)
								{
									SetMoveToPosition(iClient, fMovePos, 2, "ApproachMelee");
									bStopApproaching = false;
								}
							}
						}
					}
					if (bStopApproaching)ClearMoveToPosition(iClient, "ApproachMelee");
				}
				else if (iCurWeapon == iWpnSlots[0])
				{
					int iMeleeSwitchCount = ((iMeleeType != 2) ? g_iCvar_ImprovedMelee_SwitchCount : g_iCvar_ImprovedMelee_SwitchCount2);
					float fMeleeSwitchRange = (g_fCvar_ImprovedMelee_SwitchRange * ((iMeleeType == 2) ? 1.5 : (g_iClientInvFlags[iClient] & FLAG_SHOTGUN ? 0.66 : 1.0)));
					if (fInfectedDist <= fMeleeSwitchRange && !IsValidClient(iTankTarget) && ( ~g_iClientInvFlags[iClient] & FLAG_SHOTGUN || GetWeaponClip1(iCurWeapon) <= 0 ))
					{
						if (iInfectedClass != L4D2ZombieClass_NotInfected)
						{
							if (g_iInfectedBot_CurrentVictim[iInfectedTarget] != iClient || L4D_GetPinnedSurvivor(iInfectedTarget) != 0 || L4D_IsPlayerStaggering(iInfectedTarget))
							{
								SwitchWeaponSlot(iClient, 1);
								g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime() + ((iMeleeType == 2) ? 2.0 : 0.1);
							}
						}
						else if (g_iSurvivorBot_NearbyInfectedCount[iClient] >= iMeleeSwitchCount && !IsValidClient(iPinnedFriend) &&
							(GetCurrentGameDifficulty() == 4 || !IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, 0.75)))
						{
							SwitchWeaponSlot(iClient, 1);
							g_fSurvivorBot_MeleeApproachTime[iClient] = GetGameTime() + ((iMeleeType == 2) ? 2.0 : 0.66);
						}
					}
				}
			}
		}

		if ((g_iCvar_AutoShove_Enabled == 1 || g_iCvar_AutoShove_Enabled == 2 && !FVectorInViewAngle(iClient, fInfectedPos)) && fInfectedDist <= 6400.0 && !L4D_IsPlayerIncapacitated(iClient)
			&& (!IsSurvivorBusy(iClient) || g_iSurvivorBot_ThreatInfectedCount[iClient] >= GetCommonHitsUntilDown(iClient, (float(g_iSurvivorBot_NearbyFriends[iClient]) / (iTeamCount - 1))))
			&& (~g_iClientInvFlags[iClient] & FLAG_MELEE || iCurWeapon != iWpnSlots[1]))
		{
			if (IsSurvivorCarryingProp(iClient) || (iInfectedClass == L4D2ZombieClass_NotInfected || iInfectedClass != L4D2ZombieClass_Charger && iInfectedClass != L4D2ZombieClass_Tank && !L4D_IsPlayerStaggering(iInfectedTarget) && !IsUsingSpecialAbility(iInfectedTarget)) && GetRandomInt(1, 4) == 1)
			{
				SnapViewToPosition(iClient, fInfectedPos);
				iButtons |= IN_ATTACK2;
			}
			else if (SurvivorBot_AbleToShootWeapon(iClient))
			{
				SnapViewToPosition(iClient, fInfectedPos);
				PressAttackButton(iClient, iButtons);
			}
		}
	}

	if (g_bCvar_TargetSelection_Enabled && !IsValidClient(iPinnedFriend) && !IsSurvivorBusy(iClient) && (IsValidClient(iTankTarget) || IsEntityExists(iInfectedTarget)))
	{
		int iFireTarget = iInfectedTarget;
		if (IsEntityExists(iFireTarget))
		{
			if (g_bCvar_TargetSelection_IgnoreDociles && !IsValidClient(iFireTarget) && !IsCommonInfectedAttacking(iFireTarget))
			{
				iFireTarget = -1;
			}
			if (IsValidClient(iTankTarget) && (fInfectedDist > 1048576.0 || GetClientDistance(iClient, iTankTarget, true) < fInfectedDist))
			{
				iFireTarget = iTankTarget;
			}
		}
		else if (IsValidClient(iTankTarget))
		{
			iFireTarget = iTankTarget;
		}

		if (IsEntityExists(iFireTarget) && HasVisualContactWithEntity(iClient, iFireTarget, (iFireTarget != iTankTarget)))
		{
			L4D2ZombieClassType iInfectedClass = L4D2ZombieClass_NotInfected;
			if (IsValidClient(iFireTarget))iInfectedClass = L4D2_GetPlayerZombieClass(iFireTarget);

			float fFirePos[3]; GetTargetAimPart(iClient, iFireTarget, fFirePos);
			float fTargetDist = GetVectorDistance(g_fClientEyePos[iClient], fFirePos, true);

			if (iInfectedClass != L4D2ZombieClass_Boomer || !bFriendIsNearBoomer && fTargetDist > BOT_BOOMER_AVOID_RADIUS_SQR)
			{
				if (iCurWeapon == iWpnSlots[0])
				{
					float fShootRange = g_fCvar_TargetSelection_ShootRange;
					if (SurvivorHasShotgun(iClient))
					{
						fShootRange = g_fCvar_TargetSelection_ShootRange2;
						if (fTargetDist <= (g_fCvar_TargetSelection_ShootRange4*g_fCvar_TargetSelection_ShootRange4) && fTargetDist > ((fShootRange * 1.1)*(fShootRange * 1.1))
							&& GetGameTime() > g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] && !IsWeaponReloading(iCurWeapon, false) && ~g_iClientInvFlags[iClient] & FLAG_MELEE )
						{
							g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime() + GetRandomFloat(1.0, 3.0);
							g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
							SwitchWeaponSlot(iClient, 1);
						}
					}
					else if (g_iClientInvFlags[iClient] & FLAG_SNIPER)
					{
						fShootRange = g_fCvar_TargetSelection_ShootRange3;
					}

					if (fTargetDist <= (fShootRange*fShootRange) && SurvivorBot_AbleToShootWeapon(iClient))
					{
						SnapViewToPosition(iClient, fFirePos);
						PressAttackButton(iClient, iButtons);
					}
				}
				else if (iCurWeapon == iWpnSlots[1] && ~g_iClientInvFlags[iClient] & FLAG_MELEE)
				{
					float fShotgunRange = (g_fCvar_TargetSelection_ShootRange2 * 0.75);
					if (fTargetDist <= (fShotgunRange*fShotgunRange) && GetGameTime() > g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient]
						&& GetClientPrimaryAmmo(iClient) > 0 && !IsWeaponReloading(iCurWeapon) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
					{
						g_fSurvivorBot_NextWeaponRangeSwitchTime[iClient] = GetGameTime() + GetRandomFloat(1.0, 3.0);
						g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
						SwitchWeaponSlot(iClient, 0);
					}

					if (L4D_IsPlayerIncapacitated(iClient) || fTargetDist <= (g_fCvar_TargetSelection_ShootRange4*g_fCvar_TargetSelection_ShootRange4) && SurvivorBot_AbleToShootWeapon(iClient))
					{
						SnapViewToPosition(iClient, fFirePos);
						PressAttackButton(iClient, iButtons);
					}
				}
			}
		}
	}

	if (g_bCvar_GrenadeThrow_Enabled && iWpnSlots[2] != -1 && (IsEntityExists(iInfectedTarget) || IsValidClient(iTankTarget)))
	{
		float fThrowPosition[3];
		int iThrowTarget = -1, iGrenadeType = SurvivorHasGrenade(iClient);

		bool bIsThrowTargetTank = false;
		if (iGrenadeType != 1 && IsValidClient(iTankTarget) && !L4D_IsPlayerIncapacitated(iTankTarget) && (GetEntityHealth(iTankTarget) - 1500) >= RoundFloat((GetEntityMaxHealth(iTankTarget) - 1500) * 0.33) && GetClientDistance(iClient, iTankTarget, true) <= (g_fCvar_GrenadeThrow_ThrowRange*g_fCvar_GrenadeThrow_ThrowRange))
		{
			iThrowTarget = iTankTarget;
			GetEntityAbsOrigin(iTankTarget, fThrowPosition);
			bIsThrowTargetTank = true;
		}
		else
		{
			int iPossibleTarget = (iGrenadeType != 2 ? GetFarthestInfected(iClient, g_fCvar_GrenadeThrow_ThrowRange) : iInfectedTarget);
			if (iPossibleTarget > 0)
			{
				iThrowTarget = iPossibleTarget;
				GetEntityAbsOrigin(iPossibleTarget, fThrowPosition);
			}
		}
		g_iSurvivorBot_Grenade_ThrowTarget[iClient] = iThrowTarget;

		if (IsEntityExists(iThrowTarget))
		{
			if (iGrenadeType == 2)
			{
				float fThrowAngles[3], fTargetForward[3], fMidPos[3];
				MakeVectorFromPoints(fThrowPosition, g_fClientEyePos[iClient], fThrowAngles);
				NormalizeVector(fThrowAngles, fThrowAngles);
				GetVectorAngles(fThrowAngles, fThrowAngles);

				GetAngleVectors(fThrowAngles, fTargetForward, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(fTargetForward, fTargetForward);

				float fThrowDist = GetVectorDistance(g_fClientAbsOrigin[iClient], fThrowPosition);
				fMidPos[0] = fThrowPosition[0] + (fTargetForward[0] * (fThrowDist * 0.5));
				fMidPos[1] = fThrowPosition[1] + (fTargetForward[1] * (fThrowDist * 0.5));
				fMidPos[2] = fThrowPosition[2] + (fTargetForward[2] * (fThrowDist * 0.5));

				if (GetVectorDistance(g_fClientAbsOrigin[iClient], fMidPos, true) > BOT_GRENADE_CHECK_RADIUS_SQR)
				{
					float fTraceStart[3]; fTraceStart = fMidPos; fTraceStart[2] + HUMAN_HALF_HEIGHT;
					float fAngleDown[3] = {90.0, 0.0, 0.0};
					Handle hGroundCheck = TR_TraceRayFilterEx(fTraceStart, fAngleDown, MASK_PLAYERSOLID, RayType_Infinite, Base_TraceFilter);
					float fTrHitPos[3]; TR_GetEndPosition(fTrHitPos, hGroundCheck); delete hGroundCheck;

					float fHeightDiff = FloatAbs(fTrHitPos[2] - fThrowPosition[2]);
					if (fHeightDiff < 96.0)
					{
						fThrowPosition = fMidPos;
					}
				}
			}

			if (iCurWeapon == iWpnSlots[2])
			{
				int iThrowArea = LBI_GetNearestNavAreaCached(fThrowPosition, 300.0, true, false, false, 3);
				if (iThrowArea)LBI_GetClosestPointOnNavArea(iThrowArea, fThrowPosition, fThrowPosition);

				float fThrowVel[3]; CalculateTrajectory(g_fClientEyePos[iClient], fThrowPosition, 700.0, 0.4, fThrowVel);
				AddVectors(g_fClientEyePos[iClient], fThrowVel, g_fSurvivorBot_Grenade_AimPos[iClient]);

				float fThrowTrajectory[3];
				fThrowTrajectory = fThrowPosition;
				fThrowTrajectory[2] += (g_fSurvivorBot_Grenade_AimPos[iClient][2] - g_fClientEyePos[iClient][2]);

				Handle hCeilingCheck = TR_TraceRayFilterEx(g_fClientEyePos[iClient], fThrowTrajectory, MASK_SOLID, RayType_EndPoint, Base_TraceFilter);
				g_fSurvivorBot_Grenade_AimPos[iClient][2] *= TR_GetFraction(hCeilingCheck); delete hCeilingCheck;

				g_fSurvivorBot_Grenade_ThrowPos[iClient] = fThrowPosition;

				if (g_iSurvivorBot_ThreatInfectedCount[iClient] < GetCommonHitsUntilDown(iClient, 0.33) && CheckIsUnableToThrowGrenade(iClient, iThrowTarget, g_fClientAbsOrigin[iClient], fThrowPosition, bFriendIsNearThrowArea, bIsThrowTargetTank))
				{
					g_bSurvivorBot_ForceSwitchWeapon[iClient] = true;
					SwitchWeaponSlot(iClient, ((GetClientPrimaryAmmo(iClient) > 0) ? 0 : 1));

					if (iGrenadeType == 2)
					{
						if (GetGameTime() > g_fSurvivorBot_Grenade_NextThrowTime_Molotov)
						{
							g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + GetRandomFloat(0.75, 1.5);
						}
					}
					else if (GetGameTime() > g_fSurvivorBot_Grenade_NextThrowTime)
					{
						g_fSurvivorBot_Grenade_NextThrowTime = GetGameTime() + GetRandomFloat(0.75, 1.5);
					}
				}
				else
				{
					SnapViewToPosition(iClient, g_fSurvivorBot_Grenade_AimPos[iClient]);
					PressAttackButton(iClient, iButtons); //throw grenade
				}
			}
			else if (CheckCanThrowGrenade(iClient, iThrowTarget, g_fClientAbsOrigin[iClient], fThrowPosition, bFriendIsNearThrowArea, bIsThrowTargetTank))
			{
				SwitchWeaponSlot(iClient, 2);
			}
		}
	}

	if (L4D_IsPlayerIncapacitated(iClient))
		return;

	if (g_bCvar_DeployUpgradePacks && iWpnSlots[0] != -1 && iWpnSlots[3] != -1 && !LBI_IsSurvivorInCombat(iClient) && g_iClientInvFlags[iClient] & FLAG_UPGRADE)
	{
		bool bHasDeployedPackNearby = false;
		int iActiveDeployers = (GetSurvivorTeamActiveItemCount(L4D2WeaponId_IncendiaryAmmo) + GetSurvivorTeamActiveItemCount(L4D2WeaponId_FragAmmo));
		if (g_hDeployedAmmoPacks)
		{
			for (int i = 0; i < g_hDeployedAmmoPacks.Length; i++)
			{
				if (GetEntityDistance(iClient, g_hDeployedAmmoPacks.Get(i), true) > 589824.0)continue;
				bHasDeployedPackNearby = true;
				break;
			}
		}

		int iPrimSlot, iPrimaryCount, iUpgradedCount;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientSurvivor(i))
				continue;

			iPrimSlot = GetClientWeaponInventory(i, 0);
			if (iPrimSlot == -1)continue;

			iPrimaryCount++;
			if (GetEntProp(iPrimSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 1) > 0)
			{
				iUpgradedCount++;
			}
		}

		bool bCanSwitch = (!bHasDeployedPackNearby && iUpgradedCount < RoundFloat(iAlivePlayers * 0.25) && iPrimaryCount >= RoundFloat(iTeamCount * 0.25) && !IsValidClient(iTankTarget));
		if (iCurWeapon == iWpnSlots[3])
		{
			if (iActiveDeployers > 1 || IsValidClient(iTeamLeader) && GetClientDistance(iClient, iTeamLeader, true) >= 65536.0 || !bCanSwitch)
			{
				SwitchWeaponSlot(iClient, (GetClientPrimaryAmmo(iClient) > 0 ? 0 : 1));
			}
			else
			{
				PressAttackButton(iClient, iButtons); // deploy ammo pack
			}
		}
		else if (bCanSwitch && iActiveDeployers == 0 && LBI_IsSurvivorBotAvailable(iClient) && (!IsValidClient(iTeamLeader) || GetClientDistance(iClient, iTeamLeader, true) <= 36864.0))
		{
			SwitchWeaponSlot(iClient, 3);
		}
	}

	if (g_bCvar_DefibRevive_Enabled && IsEntityExists(iDefibTarget) && !IsValidClient(iTankTarget) && !IsValidClient(iPinnedFriend) && !LBI_IsSurvivorInCombat(iClient))
	{
		float fDefibPos[3]; GetEntityAbsOrigin(iDefibTarget, fDefibPos);
		float fDefibDist = GetVectorDistance(g_fClientEyePos[iClient], fDefibPos, true);
		if (fDefibDist <= (g_fCvar_DefibRevive_ScanDist*g_fCvar_DefibRevive_ScanDist) && !LBI_IsDamagingPosition(fDefibPos))
		{
			g_iSurvivorBot_DefibTarget[iClient] = iDefibTarget;

			if ( g_iClientInvFlags[iClient] & FLAG_DEFIB )
			{
				if (L4D2_GetPlayerUseActionTarget(iClient) == iDefibTarget || fDefibDist <= 9216.0)
				{
					if (iCurWeapon == iWpnSlots[3])
					{
						SnapViewToPosition(iClient, fDefibPos);
						PressAttackButton(iClient, iButtons); // use defib
					}
					else
					{
						SwitchWeaponSlot(iClient, 3);
					}
				}
				else if (!IsSurvivorBotBlindedByVomit(iClient) && !IsFinaleEscapeVehicleArrived() && LBI_IsSurvivorBotAvailable(iClient) && LBI_IsReachablePosition(iClient, fDefibPos) &&
					g_iSurvivorBot_NearbyInfectedCount[iClient] < GetCommonHitsUntilDown(iClient, 0.66) && !IsValidClient(g_iSurvivorBot_IncapacitatedFriend[iClient])
				)
				{
					SetMoveToPosition(iClient, fDefibPos, 2, "DefibPlayer");
				}
			}
		}
	}

	static float fRndSearchTime;
	if (g_iCvar_ItemScavenge_Items != 0 && GetGameTime() > g_fSurvivorBot_NextScavengeItemScanTime[iClient])
	{
		g_iSurvivorBot_ScavengeItem[iClient] = CheckForItemsToScavenge(iClient);
		fRndSearchTime = GetGameTime() + GetRandomFloat(0.5, 1.5);
		g_fSurvivorBot_NextScavengeItemScanTime[iClient] = fRndSearchTime;
	}

	int iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	if (IsEntityExists(iScavengeItem))
	{
		if (IsValidClient(GetEntityOwner(iScavengeItem)))
		{
			ClearMoveToPosition(iClient, "ScavengeItem");
			g_iSurvivorBot_ScavengeItem[iClient] = -1;
			g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
		}
		else
		{
			int iUseButton = IN_USE;
			bool bHoldKey = false;
			float fUseRange = g_fCvar_ItemScavenge_PickupRange;
			static bool bIncreasedTime = false;

			static char sScavengeItem[64]; GetEntityClassname(iScavengeItem, sScavengeItem, sizeof(sScavengeItem));
			char sClientName[128];
			GetClientName(iClient, sClientName, sizeof(sClientName));

			if (strcmp(sScavengeItem, "point_prop_use_target") == 0 && IsSurvivorCarryingProp(iClient))
			{
				iUseButton = IN_ATTACK;
				bHoldKey = true;
				fUseRange = 32.0;

				if (bIncreasedTime && L4D2_GetPlayerUseAction(iClient) != L4D2UseAction_PouringGas)
				{
					bIncreasedTime = false;
				}
			}
			else if (strcmp(sScavengeItem, "func_button_timed") == 0)
			{
				bHoldKey = true;
				fUseRange = 96.0;

				if (bIncreasedTime && L4D2_GetPlayerUseAction(iClient) == L4D2UseAction_None && g_fSurvivorBot_NextScavengeItemScanTime[iClient] == fRndSearchTime)
				{
					bIncreasedTime = false;
				}
			}

			if (!IsSurvivorBotBlindedByVomit(iClient) && (bHoldKey || !IsSurvivorBusy(iClient, true, true, true)))
			{
				float fItemPos[3]; GetEntityCenteroid(iScavengeItem, fItemPos);
				if (GetVectorDistance(g_fClientEyePos[iClient], fItemPos, true) <= (fUseRange*fUseRange) && IsVisibleEntity(iClient, iScavengeItem))
				{
					if (GetGameTime() > g_fSurvivorBot_NextUsePressTime[iClient])
					{
						BotLookAtPosition(iClient, fItemPos, 0.33);
						if ( LBI_FindUseEntity( iClient, fUseRange ) == iScavengeItem )
						{
							if (!bHoldKey)
							{
								g_fSurvivorBot_NextUsePressTime[iClient] = GetGameTime() + GetRandomFloat(0.1, 0.33);
								if (GetRandomInt(1, 2) == 1)iButtons |= iUseButton;
							}
							else
							{
								iButtons |= iUseButton;
								if (!bIncreasedTime)
								{
									bIncreasedTime = true;

									float fAddTime;
									if (strcmp(sScavengeItem, "func_button_timed") != 0)
									{
										fAddTime = g_fCvar_GasCanUseDuration;
									}
									else
									{
										fAddTime = GetEntPropFloat(iScavengeItem, Prop_Data, "m_nUseTime");
									}

									if (L4D2_IsUnderAdrenalineEffect(iClient))fAddTime *= 0.5;
									g_fSurvivorBot_NextScavengeItemScanTime[iClient] = GetGameTime() + fAddTime + 0.33;
								}
							}
						}
					}
				}
				else
				{
					static bool bAllowScavenge, bCanRegroup;
					static int iScavengeArea, iLeaderArea, iHits, iInfected;
					static float fMaxDist, fDist, fDistanceToRegroup, fScavengePos[3];

					bAllowScavenge = true;
					fScavengePos = fItemPos;
					fDistanceToRegroup = -1.0;
					fMaxDist = g_fCvar_ItemScavenge_ApproachVisibleRange;
					if (!bTeamHasHumanPlayer)
						fMaxDist *= g_fCvar_ItemScavenge_NoHumansRangeMultiplier;
					iScavengeArea = LBI_GetNearestNavAreaCached(fItemPos, 140.0, true, true, false);
					iLeaderArea = LBI_GetNearestNavAreaCached(g_fClientAbsOrigin[iTeamLeader], 140.0, true, true, false);

					if (iScavengeArea && iLeaderArea)
					{
						LBI_GetClosestPointOnNavArea(iScavengeArea, fItemPos, fScavengePos);
						if ( bTeamHasHumanPlayer && !LBI_IsNavAreaPartiallyVisible(iScavengeArea, g_fClientEyePos[iClient], iClient) )
							fMaxDist = g_fCvar_ItemScavenge_ApproachRange;

						iHits = GetCommonHitsUntilDown(iClient, 0.66);
						iInfected = g_iSurvivorBot_NearbyInfectedCount[iClient];
						if (iInfected > 0)
						{
							fDist = fMaxDist/((iInfected+1)/iHits);
							if (fMaxDist > fDist) fMaxDist = fDist;
						}

						bCanRegroup = LBI_NavAreaBuildPathCached(iScavengeArea, iLeaderArea, fMaxDist, 2, false);
						if (bCanRegroup)
							fDistanceToRegroup = GetNavDistance(fScavengePos, g_fClientAbsOrigin[iTeamLeader], iScavengeItem, false);
					}
					else
						bAllowScavenge = false;

					if ( bAllowScavenge && bCanRegroup && fDistanceToRegroup != -1.0 && fDistanceToRegroup < fMaxDist && !LBI_IsDamagingPosition(fScavengePos) && !IsFinaleEscapeVehicleArrived() &&
						(!IsValidClient(iTankTarget) || GetClientDistance(iClient, iTankTarget, true) > 262144.0 && GetVectorDistance(g_fClientAbsOrigin[iTankTarget], fScavengePos, true) > 147456.0)
					)
					{
						SetMoveToPosition(iClient, fScavengePos, 1, "ScavengeItem");
					}
					else
					{
						ClearMoveToPosition(iClient, "ScavengeItem");
						g_iSurvivorBot_ScavengeItem[iClient] = -1;
						g_fSurvivorBot_ScavengeItemDist[iClient] = -1.0;
					}
				}
			}
		}
	}
}
