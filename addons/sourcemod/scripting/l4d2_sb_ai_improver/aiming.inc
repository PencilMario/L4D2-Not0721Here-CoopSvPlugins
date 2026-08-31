bool SurvivorBot_IsTargetShootable(int iClient, int iTarget, int iCurWeapon, float fAimPos[3])
{
	int iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	bool bInViewCone = (GetClientAimTarget(iClient, false) == iTarget);
	if (!bInViewCone)
	{
		float fCone = 2.0 * (512.0 / GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[iTarget]));
		if (iCurWeapon == iPrimarySlot && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
			fCone *= 2.0;
		bInViewCone = ( FVectorInViewCone(iClient, g_fClientCenteroid[iTarget], fCone) && IsVisibleEntity(iClient, iTarget) );
	}

	if (IsValidClient(iTarget))
	{
		if (bInViewCone)
		{
			L4D2ZombieClassType iClass = L4D2_GetPlayerZombieClass(iTarget);
			if (iClass == L4D2ZombieClass_Boomer && GetClientDistance(iClient, iTarget, true) <= BOT_BOOMER_AVOID_RADIUS_SQR)
				return false;
			if (iClass == L4D2ZombieClass_Tank && iCurWeapon == iPrimarySlot && GetWeaponClip1(iCurWeapon) < 3 && IsWeaponReloading(iCurWeapon, false) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
				return false;
		}

		if (GetClientTeam(iTarget) == 2 && !L4D_IsPlayerPinned(iTarget) && !L4D_IsPlayerIncapacitated(iClient))
		{
			if (bInViewCone && !g_bCvar_BotsShootThrough && (iCurWeapon == iPrimarySlot || iCurWeapon == GetClientWeaponInventory(iClient, 1)
				&& ( ~g_iClientInvFlags[iClient] & FLAG_MELEE || GetClientDistance(iClient, iTarget) <= 96.0)))
				return false;

			if (g_bCvar_BotsFriendlyFire)
			{
				if (GetClientDistance(iClient, iTarget, true) <= 256.0)
					return false;
				if (iCurWeapon == iPrimarySlot && GetWeaponClip1(iCurWeapon) != 0 && GetVectorDistance(fAimPos, g_fClientCenteroid[iTarget], true) <= 90000.0
				&& g_iClientInvFlags[iClient] & FLAG_GL && GetVectorVisible(fAimPos, g_fClientCenteroid[iTarget]))
					return false;
			}
		}

		return true;
	}

	return bInViewCone;
}

bool SurvivorBot_CanFreelyFireWeapon(int iClient)
{
	int iCurWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (g_bCvar_AlwaysCarryProp && iCurWeapon == GetClientWeaponInventory(iClient, 5))
	{
		if (g_bCvar_AlwaysCarryProp)return false;
		int iTeamCount = (g_iSurvivorBot_NearbyFriends[iClient] / 2); if (iTeamCount < 1)iTeamCount = 1;
		int iDropLimitCount = RoundFloat(GetCommonHitsUntilDown(iClient, 0.5) * float(iTeamCount));
		return (g_iSurvivorBot_ThreatInfectedCount[iClient] >= iDropLimitCount);
	}

	float fAimPos[3]; GetClientAimPosition(iClient, fAimPos);
	if (iCurWeapon == GetClientWeaponInventory(iClient, 0))
	{
		int iClip = GetWeaponClip1(iCurWeapon);
		if (g_bCvar_BotsFriendlyFire && iClip != 0 && GetVectorDistance(fAimPos, g_fClientCenteroid[iClient], true) <= 90000.0
		&& g_iClientInvFlags[iClient] & FLAG_GL && GetVectorVisible(fAimPos, g_fClientCenteroid[iClient]))
		{
			if (IsEntityExists(g_iSurvivorBot_TargetInfected[iClient]) && ( ~g_iClientInvFlags[iClient] & FLAG_MELEE
			|| GetVectorDistance(fAimPos, g_fClientCenteroid[iClient], true) <= g_fCvar_ImprovedMelee_SwitchRange))
				SwitchWeaponSlot(iClient, 1);

			return false;
		}

		if (iClip < 2 && IsWeaponReloading(iCurWeapon, false) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN)
			return false;
	}

	float fCurDist, fLastDist = -1.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iClient || !IsClientInGame(i) || !IsPlayerAlive(i))continue;

		fCurDist = GetVectorDistance(g_fClientEyePos[iClient], g_fClientCenteroid[i], true);
		if (fLastDist != -1.0 && fCurDist >= fLastDist)continue;
		fLastDist = fCurDist;

		if (SurvivorBot_IsTargetShootable(iClient, i, iCurWeapon, fAimPos))continue;
		return false;
	}

	return (SurvivorBot_AbleToShootWeapon(iClient));
}

bool SurvivorBot_AbleToShootWeapon(int iClient)
{
	return (!IsWeaponReloading(L4D_GetPlayerCurrentWeapon(iClient)) && !L4D_IsPlayerStaggering(iClient));
}

void GetClosestToEyePosEntityBonePos(int iClient, int iTarget, float fAimPos[3])
{
	float fBoneDist, fBonePos[3], fAimPartPos[3], fLastDist = -1.0;
	fAimPos[0] = fAimPos[1] = fAimPos[2] = 0.0;
	GetEntityAbsOrigin(iTarget, fAimPos);
	if (!LBI_IsBoneQueryReady(iTarget))return;

	if (LBI_LookupBone(iTarget, "ValveBiped.Bip01_Pelvis") != -1)
	{
		for (int i = 0; i < sizeof(g_sBoneNames_Old); i++)
		{
			if (!LBI_GetBonePosition(iTarget, g_sBoneNames_Old[i], fBonePos))
				continue;

			fBoneDist = GetVectorDistance(g_fClientEyePos[iClient], fBonePos, true);
			if (fLastDist != -1.0 && fBoneDist >= fLastDist)continue;

			fLastDist = fBoneDist;
			fAimPartPos = fBonePos;
		}
	}
	else
	{
		for (int i = 0; i < sizeof(g_sBoneNames_New); i++)
		{
			if (!LBI_GetBonePosition(iTarget, g_sBoneNames_New[i], fBonePos))
				continue;

			fBoneDist = GetVectorDistance(g_fClientEyePos[iClient], fBonePos, true);
			if (fLastDist != -1.0 && fBoneDist >= fLastDist)continue;

			fLastDist = fBoneDist;
			fAimPartPos = fBonePos;
		}
	}
	fAimPos = fAimPartPos;
}

void GetTargetAimPart(int iClient, int iTarget, float fAimPos[3])
{
	fAimPos[0] = fAimPos[1] = fAimPos[2] = 0.0;
	GetEntityAbsOrigin(iTarget, fAimPos);

	if (IsWeaponSlotActive(iClient, 0) && g_iClientInvFlags[iClient] & FLAG_GL && (!IsValidClient(iTarget) || L4D2_GetPlayerZombieClass(iTarget) != L4D2ZombieClass_Jockey))
		return;

	if (!LBI_IsBoneQueryReady(iTarget))return;

	static char sAimBone[64];
	float fDist = GetEntityDistance(iClient, iTarget, true);
	bool bIsUsingOldSkeleton = (LBI_LookupBone(iTarget, "ValveBiped.Bip01_Pelvis") != -1);
	if (IsWitch(iTarget) && fDist <= 65536.0 && IsWeaponSlotActive(iClient, 0) && g_iClientInvFlags[iClient] & FLAG_SHOTGUN || (L4D_IsPlayerIncapacitated(iClient)
		&& fDist <= 147456.0 || L4D2_IsRealismMode() && fDist <= 262144.0) && (!IsValidClient(iTarget) || L4D2_GetPlayerZombieClass(iTarget) != L4D2ZombieClass_Tank))
	{
		sAimBone = (bIsUsingOldSkeleton ? "ValveBiped.Bip01_Head1" : "bip_head");
	}
	else
	{
		sAimBone = (bIsUsingOldSkeleton ? "ValveBiped.Bip01_Spine2" : "bip_spine_2");
	}

	float fAimPartPos[3];
	if (!LBI_GetBonePosition(iTarget, sAimBone, fAimPartPos))return;

	if (!IsVisibleVector(iClient, fAimPartPos))
	{
		bool bVisibleOther = false;
		if (bIsUsingOldSkeleton)
		{
			for (int i = 0; i < sizeof(g_sBoneNames_Old); i++)
			{
				if (!LBI_GetBonePosition(iTarget, g_sBoneNames_Old[i], fAimPartPos))
				continue;

				if (IsVisibleVector(iClient, fAimPartPos))
				{
					bVisibleOther = true;
					break;
				}
			}
		}
		else
		{
			for (int i = 0; i < sizeof(g_sBoneNames_New); i++)
			{
				if (!LBI_GetBonePosition(iTarget, g_sBoneNames_New[i], fAimPartPos))
				continue;

				if (IsVisibleVector(iClient, fAimPartPos))
				{
					bVisibleOther = true;
					break;
				}
			}
		}
		if (!bVisibleOther)return;
	}

	fAimPos = fAimPartPos;
}
