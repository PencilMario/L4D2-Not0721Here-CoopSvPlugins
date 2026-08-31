Action OnSurvivorSwitchWeapon(int iClient, int iWeapon)
{
	if (!IsClientSurvivor(iClient) || !IsFakeClient(iClient) || g_bSurvivorBot_ForceSwitchWeapon[iClient] || !IsEntityExists(iWeapon) || L4D_IsPlayerIncapacitated(iClient))
	{
		g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
		return Plugin_Continue;
	}

	int iCurWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (iCurWeapon == -1 || iWeapon == iCurWeapon || GetWeaponClip1(iCurWeapon) < 0)
	{
		g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
		return Plugin_Continue;
	}

	if (iWeapon == GetClientWeaponInventory(iClient, 0))
	{
		if (GetSurvivorBotWeaponPreference(iClient) == L4D_WEAPON_PREFERENCE_SECONDARY)
		{
			SwitchWeaponSlot(iClient, 1);
			return Plugin_Handled;
		}

		if (iCurWeapon == GetClientWeaponInventory(iClient, 1))
		{
			if ( g_iClientInvFlags[iClient] & FLAG_MELEE )
			{
				if (GetGameTime() <= g_fSurvivorBot_BlockWeaponSwitchTime[iClient])
				{
					return Plugin_Handled;
				}
			}
			else if (IsWeaponReloading(iCurWeapon) || GetWeaponClip1(iCurWeapon) != GetWeaponClipSize(iCurWeapon) && !LBI_IsSurvivorInCombat(iClient))
			{
				g_bSurvivorBot_ForceWeaponReload[iClient] = true;
				return Plugin_Handled;
			}
		}
	}
	else if (iWeapon == GetClientWeaponInventory(iClient, 1))
	{
		if (iCurWeapon == GetClientWeaponInventory(iClient, 0) && GetClientPrimaryAmmo(iClient) > 0)
		{
			if (g_iSurvivorBot_NearbyInfectedCount[iClient] < g_iCvar_ImprovedMelee_SwitchCount2 && g_iClientInvFlags[iClient] & FLAG_CHAINSAW)
			{
				return Plugin_Handled;
			}

			if (GetSurvivorBotWeaponPreference(iClient) != L4D_WEAPON_PREFERENCE_SECONDARY && ( ~g_iClientInvFlags[iClient] & FLAG_MELEE
				|| g_iSurvivorBot_NearbyInfectedCount[iClient] < g_iCvar_ImprovedMelee_SwitchCount )
				&& ((g_bCvar_DontSwitchToPistol && g_iClientInvFlags[iClient] & FLAG_SNIPER) || g_iClientInvFlags[iClient] & FLAG_SHOTGUN))
			{
				return Plugin_Handled;
			}
		}
	}

	if (IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && iCurWeapon == GetClientWeaponInventory(iClient, 3) && g_iClientInvFlags[iClient] & FLAG_DEFIB)
	{
		return Plugin_Handled;
	}

	if (g_bCvar_AlwaysCarryProp && IsSurvivorCarryingProp(iClient) && (iWeapon == GetClientWeaponInventory(iClient, 0) || iWeapon == GetClientWeaponInventory(iClient, 1)))
	{
		int iTeamCount = (g_iSurvivorBot_NearbyFriends[iClient] / 2); if (iTeamCount < 1)iTeamCount = 1;
		int iDropLimitCount = RoundFloat(GetCommonHitsUntilDown(iClient, 0.5) * float(iTeamCount));
		if (g_iSurvivorBot_ThreatInfectedCount[iClient] < iDropLimitCount)return Plugin_Handled;
	}

	g_bSurvivorBot_ForceSwitchWeapon[iClient] = false;
	return Plugin_Continue;
}

#define ACID_ESCAPE_PATH_ATTEMPTS 6

Action OnSurvivorTakeDamage(int iClient, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType)
{
	if (GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
		return Plugin_Continue;

	if (IsWitch(iAttacker))
	{
		int iWitchRef;
		for (int i = 0; i < g_hWitchList.Length; i++)
		{
			iWitchRef = EntRefToEntIndex(g_hWitchList.Get(i));
			if (iWitchRef == INVALID_ENT_REFERENCE || !IsEntityExists(iWitchRef))
			{
				g_hWitchList.Erase(i);
				continue;
			}
			if (iWitchRef == iAttacker)
			{
				g_hWitchList.Set(i, GetClientUserId(iClient), 1);
				break;
			}
		}
	}

	if (!IsFakeClient(iClient))
		return Plugin_Continue;

	if (IsSurvivorBotBlindedByVomit(iClient) && (IsValidClient(iAttacker) && GetClientTeam(iAttacker) == 3 || IsCommonInfected(iAttacker)))
	{
		float fLookPos[3]; GetEntityCenteroid(iAttacker, fLookPos);
		BotLookAtPosition(iClient, fLookPos, 1.0);
		g_bSurvivorBot_ForceBash[iClient] = true;
	}

	if (g_bCvar_NoFallDmgOnLadderFail && iDamageType & DMG_FALL && GetGameTime() <= g_fSurvivorBot_TimeSinceLeftLadder[iClient])
	{
		fDamage = 0.0;
		return Plugin_Changed;
	}

	if (!g_bCvar_SpitterAcidEvasion || !IsEntityExists(iInflictor) || strcmp(g_sSurvivorBot_MovePos_Name[iClient], "EscapeInferno") == 0)
		return Plugin_Continue;

	static char sInfClass[16]; GetEntityClassname(iInflictor, sInfClass, sizeof(sInfClass));
	if (strcmp(sInfClass, "insect_swarm") != 0 && strcmp(sInfClass, "inferno") != 0)return Plugin_Continue;

	int iInflictorRef = EntIndexToEntRef(iInflictor);
	float fNow = GetGameTime();
	if (fNow < g_fSurvivorBot_AcidEscapeCache_Expiry[iClient]
		&& g_iSurvivorBot_AcidEscapeCache_Inflictor[iClient] == iInflictorRef
		&& GetVectorDistance(g_fSurvivorBot_AcidEscapeCache_ClientPos[iClient], g_fClientAbsOrigin[iClient], true) <= GetNavigationCachePositionTolerance())
	{
		if (g_bSurvivorBot_AcidEscapeCache_Result[iClient])
			SetMoveToPosition(iClient, g_fSurvivorBot_AcidEscapeCache_ResultPos[iClient], 4, "EscapeInferno", 0.0, 5.0, true, true);
		return Plugin_Continue;
	}

	int iNavArea;
	float fCurDist, fLastDist = -1.0;
	float fEscapePos[3], fPathPos[3];
	SetVectorToZero(fEscapePos);
	for (int i = 0; i < ACID_ESCAPE_PATH_ATTEMPTS; i++)
	{
		VScript_TryGetPathableLocationWithin(iClient, 250.0 + (50.0 * i), fPathPos);
		if (!IsValidVector(fPathPos))continue;

		fCurDist = GetClientTravelDistance(iClient, fPathPos, true);
		if (fLastDist != -1.0 && fCurDist >= fLastDist)
			continue;

		iNavArea = LBI_GetNearestNavAreaCached(fPathPos);
		if (!iNavArea || LBI_IsDamagingNavArea(iNavArea, true) || !LBI_IsReachableNavArea(iClient, iNavArea))
			continue;

		fLastDist = fCurDist;
		fEscapePos = fPathPos;
	}

	g_fSurvivorBot_AcidEscapeCache_Expiry[iClient] = GetProcessCacheExpiry();
	g_iSurvivorBot_AcidEscapeCache_Inflictor[iClient] = iInflictorRef;
	g_fSurvivorBot_AcidEscapeCache_ClientPos[iClient] = g_fClientAbsOrigin[iClient];
	g_bSurvivorBot_AcidEscapeCache_Result[iClient] = IsValidVector(fEscapePos);
	if (g_bSurvivorBot_AcidEscapeCache_Result[iClient])
		g_fSurvivorBot_AcidEscapeCache_ResultPos[iClient] = fEscapePos;

	if (IsValidVector(fEscapePos))
		SetMoveToPosition(iClient, fEscapePos, 4, "EscapeInferno", 0.0, 5.0, true, true);

	return Plugin_Continue;
}


Action OnWitchTakeDamage(int iWitch, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType)
{
	if ( iDamageType & (DMG_BULLET | DMG_BLAST | DMG_BLAST_SURFACE) )
	{
		CreateTimer(0.1, CheckWitchStumble, iWitch);
	}
	return Plugin_Continue;
}

public Action CheckWitchStumble(Handle timer, int iWitch)
{
	if (IsEntityExists(iWitch))
	{
		static int iWitchRef;
		static float fWitchRage;

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
				fWitchRage = GetEntPropFloat(iWitch, Prop_Send, "m_rage");
				if (g_hWitchList.Get(i, 1) == 0 && fWitchRage > 0.99)
				{
					g_hWitchList.Set(i, -1, 1);
					SDKUnhook(iWitch, SDKHook_OnTakeDamage, OnWitchTakeDamage);
					break;
				}
			}
		}
	}
	return Plugin_Handled;
}
