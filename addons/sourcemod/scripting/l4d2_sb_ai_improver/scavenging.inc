public Action L4D2_OnFindScavengeItem(int iClient, int &iItem)
{
	if (!IsEntityExists(iItem))
		return Plugin_Continue;

	static bool bIsValidScavenge;
	static int iPrimarySlot, iPrimaryAmmo, iTier3Primary, iSecondarySlot, iItemFlags, iScavengeItem, iItemTier, iWpnTier, iBotPreference;
	static char sWeaponName[64];

	sWeaponName[0] = EOS;
	GetEntityClassname(iItem, sWeaponName, sizeof(sWeaponName));
	iItemTier = GetWeaponTier(iItem);
	if (!strcmp(sWeaponName, "weapon_spawn") && (g_iWeaponID[iItem] <= 0 || iItemTier == -1))
	{
		float fItemPos[3];
		GetEntityAbsOrigin(iItem, fItemPos);
		if (g_iCvar_Debug & DEBUG_SCAVENGE && (g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient))
			LogDebugMessage("OnFindScavengeItem: %d %s wepid %d tier %d\npos %.2f %.2f %.2f", iItem, sWeaponName, g_iWeaponID[iItem], iItemTier, fItemPos[0], fItemPos[1], fItemPos[2]);
		CheckEntityForStuff(iItem, sWeaponName);
		return Plugin_Handled;
	}

	iItemFlags = g_iItemFlags[iItem];
	if (g_bCvar_SwitchOffCSSWeapons && iItemFlags & FLAG_CSS)
		return Plugin_Handled;

	iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	iTier3Primary = SurvivorHasTier3Weapon(iClient);
	iScavengeItem = g_iSurvivorBot_ScavengeItem[iClient];
	bIsValidScavenge = (iScavengeItem != -1 && IsValidEntity(iScavengeItem));
	iPrimaryAmmo = 0;
	if (iPrimarySlot != -1)
		iPrimaryAmmo = g_iWeapon_Clip1[iPrimarySlot] + g_iWeapon_AmmoLeft[iPrimarySlot];

	if(g_iCvar_Debug & DEBUG_SCAVENGE && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
	{
		char sClientName[128], sEntClass[64], sEntClassname[64];
		GetClientName(iClient, sClientName, sizeof(sClientName));
		if (iPrimarySlot != -1)
			strcopy( sEntClass, 64, IBWeaponName[g_iWeaponID[iPrimarySlot]] );
		if (bIsValidScavenge)
			GetEntityClassname(iScavengeItem, sEntClassname, sizeof(sEntClassname));
		LogDebugMessage("OnFindScavengeItem: %s has %s ammo %d, goes for %s weapon ID %d, ScavengeItem %s", sClientName, sEntClass, iPrimaryAmmo, sWeaponName, g_iWeaponID[iItem], sEntClassname);
	}

	if (IsEntityExists(iPrimarySlot))
	{
		iItemTier = GetWeaponTier(iItem);
		if ( iItemTier > 0 && bIsValidScavenge && (g_iWeaponID[iScavengeItem] == 54 || GetWeaponTier(iScavengeItem) > 0) ) // L4D2WeaponId_Ammo = 54
			return Plugin_Handled;

		iWpnTier = GetWeaponTier(iPrimarySlot);
		iBotPreference = GetSurvivorBotWeaponPreference(iClient);
		if (iBotPreference != 0)
		{
			if ( !iTier3Primary && (iWpnTier == 2 || iWpnTier == 1 && iBotPreference == L4D_WEAPON_PREFERENCE_SMG) && WeaponHasEnoughAmmoLeft(iPrimarySlot))
			{
				if (iBotPreference != L4D_WEAPON_PREFERENCE_ASSAULTRIFLE && iItemFlags & FLAG_ASSAULT)
					return Plugin_Handled;
				if (iBotPreference != L4D_WEAPON_PREFERENCE_SHOTGUN && iItemFlags & FLAG_SHOTGUN && iItemFlags & FLAG_TIER2)
					return Plugin_Handled;
				if (iBotPreference != L4D_WEAPON_PREFERENCE_SNIPERRIFLE && iItemFlags & FLAG_SNIPER)
					return Plugin_Handled;
			}
		}
		//if(g_bCvar_Debug)
		//	PrintToServer("WeaponHasEnoughAmmoLeft %b ItemTier %d", WeaponHasEnoughAmmoLeft(iPrimarySlot), iItemTier);

		if ( iItemTier > 0 && iPrimaryAmmo >= g_iWeapon_MaxAmmo[iPrimarySlot] * 0.25
			&& (iTier3Primary == 1 && GetSurvivorTeamInventoryCount(FLAG_GL) <= g_iCvar_MaxWeaponTier3_GLauncher
			|| iTier3Primary == 2 && GetSurvivorTeamInventoryCount(FLAG_M60) <= g_iCvar_MaxWeaponTier3_M60) )
		{
			return Plugin_Handled;
		}
		else if (iItemTier != 0 && GetClientPrimaryAmmo(iClient) < GetWeaponMaxAmmo(iPrimarySlot))
		{
			int iAmmoPileItem = GetItemFromArrayList(g_hAmmopileList, iClient, 1024.0, _, _, _, false);
			if (iAmmoPileItem != -1)
				return Plugin_Handled;
		}
	}

	iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	if (IsEntityExists(iSecondarySlot))
	{
		// if i have magnum and prefer it to pistol
		if ( iItemFlags & FLAG_PISTOL && g_bCvar_BotWeaponPreference_ForceMagnum && SurvivorHasPistol(iClient) == 3 )
			return Plugin_Handled;

		// if it's melee AND i don't have melee AND team has enough melee OR i have chainsaw AND not too many chainsaw/melee in team
		if ( iItemFlags & FLAG_MELEE && (~g_iClientInvFlags[iClient] & FLAG_MELEE && ( GetSurvivorTeamInventoryCount(FLAG_MELEE) >= g_iCvar_MaxMeleeSurvivors )
			|| g_iClientInvFlags[iClient] & FLAG_CHAINSAW && GetSurvivorTeamInventoryCount(FLAG_CHAINSAW) <= g_iCvar_ImprovedMelee_ChainsawLimit) )
			return Plugin_Handled;

		// if it's pistols AND i have chainsaw AND it has fuel AND not too many chainsaw in team
		if ( iItemFlags & (FLAG_PISTOL | FLAG_PISTOL_EXTRA) && g_iClientInvFlags[iClient] & FLAG_CHAINSAW
			&& GetSurvivorTeamInventoryCount(FLAG_CHAINSAW) <= g_iCvar_ImprovedMelee_ChainsawLimit
			&& g_iWeapon_Clip1[iSecondarySlot] > RoundFloat(GetWeaponMaxAmmo(iSecondarySlot) * 0.25) )
			return Plugin_Handled;
	}

	if ( IsWeaponSlotActive(iClient, 3) && iItemFlags & (FLAG_MEDKIT | FLAG_DEFIB) && g_iClientInvFlags[iClient] & FLAG_UPGRADE )
		return Plugin_Handled;

	if ( iItemFlags & FLAG_MEDKIT && IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && g_iClientInvFlags[iClient] & FLAG_DEFIB )
		return Plugin_Handled;

	return Plugin_Continue;
}

bool WeaponHasEnoughAmmoLeft(int iWeapon)
{
	return (g_iWeapon_MaxAmmo[iWeapon] > 0 && (g_iWeapon_AmmoLeft[iWeapon] + g_iWeapon_Clip1[iWeapon]) >= RoundFloat(g_iWeapon_MaxAmmo[iWeapon] * 0.33));
}

stock bool IsEntityWeapon(int iEntity, bool bNoSpawn = false)
{
	if (!IsEntityExists(iEntity))
		return false;

	char sEntClass[64]; GetWeaponClassname(iEntity, sEntClass, sizeof(sEntClass));
	if (strcmp(sEntClass, "predicted_viewmodel") == 0 || bNoSpawn && strcmp(sEntClass, "weapon_spawn") == 0)
		return false;

	ReplaceString(sEntClass, sizeof(sEntClass), "_spawn", "", false);
	return (L4D2_IsValidWeaponName(sEntClass));
}

int CheckForItemsToScavenge(int iClient)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	int iResult = CheckForItemsToScavengeImpl(iClient);
	LogSlowCalculation("CheckForItemsToScavenge", fStartedAt, iClient, iResult);
	return iResult;
}

int CheckForItemsToScavengeImpl(int iClient)
{
	static int iItem, iArrayItem, iItemBits, iItemFlags,
		iPrimarySlot, iTier3Primary, iMinAmmo, iWpnPreference,
		iSecondarySlot, iMeleeCount, iChainsawCount, iMeleeType, iCurrentMeleePref,
		iGrenadeSlot, iGrenadeTypeLimit;

	ArrayList hItemList = new ArrayList();

	iPrimarySlot = GetClientWeaponInventory(iClient, 0);
	iSecondarySlot = GetClientWeaponInventory(iClient, 1);
	iGrenadeSlot = GetClientWeaponInventory(iClient, 2);
	iTier3Primary = SurvivorHasTier3Weapon(iClient);
	iWpnPreference = GetSurvivorBotWeaponPreference(iClient);
	iItem = -1;
	iItemBits = g_iCvar_ItemScavenge_Items;

	if (iItemBits & PICKUP_PRIMARY && iPrimarySlot == -1)	// if can pick primary AND no primary
	{
		iArrayItem = GetItemFromArrayList(g_hAssaultRifleList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hShotgunT2List, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hSniperRifleList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hShotgunT1List, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = GetItemFromArrayList(g_hSMGList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if ( iWpnPreference && iWpnPreference != L4D_WEAPON_PREFERENCE_SECONDARY && !iTier3Primary )
	{
		ArrayList hWeaponList;
		bool bHasWep = false;

		switch(iWpnPreference)
		{
			case L4D_WEAPON_PREFERENCE_ASSAULTRIFLE:
			{
				hWeaponList = g_hAssaultRifleList;
				bHasWep = SurvivorHasAssaultRifle(iClient);
			}
			case L4D_WEAPON_PREFERENCE_SHOTGUN:
			{
				hWeaponList = g_hShotgunT2List;
				bHasWep = SurvivorHasShotgun(iClient) > 1;
			}
			case L4D_WEAPON_PREFERENCE_SNIPERRIFLE:
			{
				hWeaponList = g_hSniperRifleList;
				bHasWep = SurvivorHasSniperRifle(iClient);
			}
			case L4D_WEAPON_PREFERENCE_SMG:
			{
				hWeaponList = g_hSMGList;
				bHasWep = SurvivorHasSMG(iClient);
			}
		}

		if (!bHasWep && iItemBits & PICKUP_PRIMARY || GetWeaponTier(iPrimarySlot) == 1 && iWpnPreference != L4D_WEAPON_PREFERENCE_SMG)
		{
			iArrayItem = GetItemFromArrayList(hWeaponList, iClient);
			if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
			{
				hItemList.Push(iArrayItem);
			}
		}
	}

	if (iWpnPreference != L4D_WEAPON_PREFERENCE_SECONDARY)
	{
		if ( !iTier3Primary && GetSurvivorTeamInventoryCount(FLAG_GL) < g_iCvar_MaxWeaponTier3_GLauncher )
		{
			iArrayItem = GetItemFromArrayList(g_hTier3List, iClient, _, 21); // L4D2WeaponId_GrenadeLauncher
			if (iArrayItem != -1)
			{
				hItemList.Push(iArrayItem);
			}
		}

		if ( !iTier3Primary && GetSurvivorTeamInventoryCount(FLAG_M60) < g_iCvar_MaxWeaponTier3_M60 )
		{
			iArrayItem = GetItemFromArrayList(g_hTier3List, iClient, _, 37); // L4D2WeaponId_RifleM60
			if (iArrayItem != -1)
			{
				hItemList.Push(iArrayItem);
			}
		}
	}

	if ( iItemBits & PICKUP_DEFIB && GetClientWeaponInventory(iClient, 3) == -1 || IsEntityExists(g_iSurvivorBot_DefibTarget[iClient]) && !(g_iClientInvFlags[iClient] & FLAG_DEFIB) )
	{
		iArrayItem = GetItemFromArrayList(g_hDefibrillatorList, iClient);
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (GetClientWeaponInventory(iClient, 3) == -1)
	{
		iArrayItem = (~iItemBits & PICKUP_MEDKIT ? -1 : GetItemFromArrayList(g_hFirstAidKitList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = (~iItemBits & PICKUP_UPGRADE ? -1 : GetItemFromArrayList(g_hUpgradePackList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (GetClientWeaponInventory(iClient, 4) == -1)
	{
		iArrayItem = (~iItemBits & PICKUP_PILLS ? -1 : GetItemFromArrayList(g_hPainPillsList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = (~iItemBits & PICKUP_ADREN ? -1 : GetItemFromArrayList(g_hAdrenalineList, iClient));
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}

	if (iGrenadeSlot == -1)
	{
		iArrayItem = ((iItemBits & PICKUP_PIPE) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, 14) : -1); // L4D2WeaponId_PipeBomb
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = ((iItemBits & PICKUP_MOLO) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, 13) : -1); // L4D2WeaponId_Molotov
		if (iArrayItem != -1)hItemList.Push(iArrayItem);

		iArrayItem = ((iItemBits & PICKUP_BILE) ? GetItemFromArrayList(g_hGrenadeList, iClient, _, 25) : -1); // L4D2WeaponId_Vomitjar
		if (iArrayItem != -1)hItemList.Push(iArrayItem);
	}
	else if (g_bCvar_SwapSameTypeGrenades)
	{
		iGrenadeTypeLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_GREN) * 0.55);
		if (iGrenadeTypeLimit < 1)iGrenadeTypeLimit = 1;

		if (GetSurvivorTeamItemCount(L4D2_GetWeaponId(iGrenadeSlot)) > iGrenadeTypeLimit)
		{
			iArrayItem = GetItemFromArrayList(g_hGrenadeList, iClient, _, -g_iWeaponID[iGrenadeSlot]);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
	}

	iMinAmmo = 0;
	if (iPrimarySlot != -1)
	{
		iItemFlags = g_iItemFlags[iPrimarySlot];
		iMinAmmo = GetWeaponMaxAmmo(iPrimarySlot);

		if (iItemBits & PICKUP_AMMO && (!iTier3Primary || iTier3Primary & g_iCvar_T3_Refill))	// if can pick up ammo
		{
			if (!L4D_IsInFirstCheckpoint(iClient))
				iMinAmmo = RoundFloat(iMinAmmo * ((!LBI_IsSurvivorInCombat(iClient) && !L4D_HasVisibleThreats(iClient)) ? 0.75 : 0.5));

			//if(g_bCvar_Debug)
			//{
			//	char sClientName[128];
			//	GetClientName(iClient, sClientName, sizeof(sClientName));
			//	PrintToServer("%s iMinAmmo %d primary ammo %d", sClientName, iMinAmmo, GetClientPrimaryAmmo(iClient));
			//}

			if (GetClientPrimaryAmmo(iClient) < iMinAmmo)
			{
				iArrayItem = GetItemFromArrayList(g_hAmmopileList, iClient);
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}
		}

		if (g_bCvar_SwapSameTypePrimaries && !iTier3Primary)
		{
			if (iWpnPreference != L4D_WEAPON_PREFERENCE_SMG)
			{
				int iSMGCount = GetSurvivorTeamInventoryCount(FLAG_SMG);
				int iShotgunCount = GetSurvivorTeamInventoryCount(FLAG_SHOTGUN, FLAG_TIER1);

				int iTier1Limit = RoundToCeil((iSMGCount + iShotgunCount) * 0.5);
				if (iTier1Limit < 1)iTier1Limit = 1;

				if ( iShotgunCount > iTier1Limit && iItemFlags & FLAG_SHOTGUN && iItemFlags & FLAG_TIER1 )
				{
					iArrayItem = GetItemFromArrayList(g_hSMGList, iClient);
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}
				}
				else if ( iSMGCount > iTier1Limit && iItemFlags & FLAG_SMG )
				{
					iArrayItem = GetItemFromArrayList(g_hShotgunT1List, iClient);
					if (iArrayItem != -1 && (IsWeaponNearAmmoPile(iArrayItem, iClient) || WeaponHasEnoughAmmoLeft(iArrayItem)))
					{
						hItemList.Push(iArrayItem);
					}
				}
			}

			int iPrimaryCount = GetSurvivorTeamItemCount(L4D2_GetWeaponId(iPrimarySlot));
			int iWepLimit = -1;
			ArrayList hWepArray;
			if (SurvivorHasShotgun(iClient))
			{
				hWepArray = g_hShotgunT2List;
				iWepLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_SHOTGUN, FLAG_TIER2) * 0.5);
			}
			else if (SurvivorHasAssaultRifle(iClient))
			{
				hWepArray = g_hAssaultRifleList;
				iWepLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_ASSAULT) * 0.5);
			}
			else if (SurvivorHasSniperRifle(iClient))
			{
				hWepArray = g_hSniperRifleList;
				iWepLimit = RoundFloat(GetSurvivorTeamInventoryCount(FLAG_SNIPER) * 0.5);
			}
			if (iWepLimit != -1 && iWepLimit < 1)iWepLimit = 1;

			if (iPrimaryCount > iWepLimit)
			{
				iArrayItem = GetItemFromArrayList(hWepArray, iClient, _, -g_iWeaponID[iPrimarySlot]);
				if (iArrayItem != -1 && (WeaponHasEnoughAmmoLeft(iArrayItem) || IsWeaponNearAmmoPile(iArrayItem, iClient)))
				{
					hItemList.Push(iArrayItem);
				}
			}
		}

		int iUpgradeBits = GetEntProp(iPrimarySlot, Prop_Send, "m_upgradeBitVec");
		if (~iUpgradeBits & L4D2_WEPUPGFLAG_LASER && iItemBits & PICKUP_LASER)
		{
			iArrayItem = GetItemFromArrayList(g_hLaserSightList, iClient);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
		if ( iItemBits & PICKUP_AMMOPACK && !(iUpgradeBits & (L4D2_WEPUPGFLAG_INCENDIARY|L4D2_WEPUPGFLAG_EXPLOSIVE)) )
		{
			iArrayItem = GetItemFromArrayList(g_hDeployedAmmoPacks, iClient);
			if (iArrayItem != -1)hItemList.Push(iArrayItem);
		}
	}

	if (iSecondarySlot != -1)
	{
		iMeleeCount = GetSurvivorTeamInventoryCount(FLAG_MELEE, -FLAG_CHAINSAW);
		iChainsawCount = GetSurvivorTeamInventoryCount(FLAG_CHAINSAW);
		iMeleeType = SurvivorHasMeleeWeapon(iClient);
		static bool bFoundMelee;

		if (iMeleeType != 0)
		{
			if(g_iCvar_Debug & DEBUG_WEP_DATA && g_iCvar_Debug & DEBUG_SCAVENGE)
			{
				char sEntClassname[64], sClientName[128];
				GetClientName(iClient, sClientName, sizeof(sClientName));
				GetEntityClassname(iSecondarySlot, sEntClassname, sizeof(sEntClassname));
				LogDebugMessage("%s %d %s MeleeID %d", sClientName, iSecondarySlot, sEntClassname, g_iMeleeID[iSecondarySlot]);
			}
			iCurrentMeleePref = g_iMeleeID[iSecondarySlot] < 0 ? -1 : GetMeleePreference(iSecondarySlot);
			if (iMeleeType != 2)
			{
				// look for chainsaw
				bFoundMelee = false;
				if (iItemBits & PICKUP_CHAINSAW && (iMeleeCount + iChainsawCount) <= g_iCvar_MaxMeleeSurvivors && iChainsawCount < g_iCvar_ImprovedMelee_ChainsawLimit)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 20); // L4D2WeaponId_Chainsaw
					if (iArrayItem != -1 && g_iWeapon_Clip1[iArrayItem] > RoundFloat(GetWeaponMaxAmmo(iArrayItem) * 0.25))
					{
						bFoundMelee = true;
						hItemList.Push(iArrayItem);
					}
				}
				// look for better melee
				if (iCurrentMeleePref != -1 && !bFoundMelee && iItemBits & PICKUP_SECONDARY && (iMeleeCount + iChainsawCount) <= g_iCvar_MaxMeleeSurvivors)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 19); // L4D2WeaponId_Melee
					if (iArrayItem != -1 && GetMeleePreference(iArrayItem) > iCurrentMeleePref)
						hItemList.Push(iArrayItem);
				}
			}
			// drop excess or low fuel chainsaw for other melee/pistols
			else if ( iMeleeType == 2 && (iChainsawCount > g_iCvar_ImprovedMelee_ChainsawLimit || g_iWeapon_Clip1[iSecondarySlot] <= RoundFloat(GetWeaponMaxAmmo(iSecondarySlot) * 0.25)) )
			{
				bFoundMelee = false;
				if (iMeleeCount < g_iCvar_MaxMeleeSurvivors)
				{
					iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 19); // L4D2WeaponId_Melee
					if (iArrayItem != -1)
					{
						bFoundMelee = true;
						hItemList.Push(iArrayItem);
					}
				}
				if (!bFoundMelee)
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient);
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				}
			}
			// drop excess melee for any pistol
			if ((iMeleeCount + iChainsawCount) > g_iCvar_MaxMeleeSurvivors && (iMeleeType != 2 || iChainsawCount > g_iCvar_ImprovedMelee_ChainsawLimit))
			{
				iArrayItem = GetItemFromArrayList(g_hPistolList, iClient);
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}
		}
		else if (iItemBits & PICKUP_SECONDARY)
		{
			if ((iMeleeCount + iChainsawCount) < g_iCvar_MaxMeleeSurvivors)
			{
				iArrayItem = GetItemFromArrayList(g_hMeleeList, iClient, _, 19); // L4D2WeaponId_Melee
				if (iArrayItem != -1)hItemList.Push(iArrayItem);
			}

			int iHasPistol = SurvivorHasPistol(iClient);
			if ( iHasPistol != 0 )
			{
				if ( g_bCvar_BotWeaponPreference_ForceMagnum && iHasPistol != 3 || GetSurvivorTeamItemCount(L4D2WeaponId_PistolMagnum) == 0 )
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient, _, 32); // L4D2WeaponId_PistolMagnum
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				}
				else if ( iHasPistol == 1 )
				{
					iArrayItem = GetItemFromArrayList(g_hPistolList, iClient, _, 1); // L4D2WeaponId_Pistol
					if (iArrayItem != -1)hItemList.Push(iArrayItem);
				}
			}
		}
	}

	if (hItemList.Length > 0)
	{
		int iCurItem;
		float fCurDist;
		float fLastDist = -1.0;
		for (int i = 0; i < hItemList.Length; i++)
		{
			iCurItem = hItemList.Get(i);
			fCurDist = GetClientDistanceToItem(iClient, iCurItem, true);
			if (fLastDist != -1.0 && fCurDist >= fLastDist)continue;

			iItem = iCurItem;
			fLastDist = fCurDist;
		}
		g_fSurvivorBot_ScavengeItemDist[iClient] = fLastDist;
	}
	delete hItemList;

	if(g_iCvar_Debug & DEBUG_SCAVENGE && iItem != -1 && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
	{
		char sEntClassname[64],sClientName[128];
		GetClientName(iClient, sClientName, sizeof(sClientName));
		if(iItem != -1)
			GetEntityClassname(iItem, sEntClassname, sizeof(sEntClassname));
		LogDebugMessage( "CheckForItemsToScavenge: %s MinAmmo %d Ammo %d HasTier3 %d iItem %d %s", sClientName,
		iMinAmmo, GetClientPrimaryAmmo(iClient), iTier3Primary, iItem, sEntClassname );
	}

	return iItem;
}

int GetSurvivorBotWeaponPreference(int iClient)
{
	switch(GetClientSurvivorType(iClient))
	{
		case L4D_SURVIVOR_ROCHELLE:	return g_iCvar_BotWeaponPreference_Rochelle;
		case L4D_SURVIVOR_COACH:	return g_iCvar_BotWeaponPreference_Coach;
		case L4D_SURVIVOR_ELLIS:	return g_iCvar_BotWeaponPreference_Ellis;
		case L4D_SURVIVOR_BILL:		return g_iCvar_BotWeaponPreference_Bill;
		case L4D_SURVIVOR_ZOEY:		return g_iCvar_BotWeaponPreference_Zoey;
		case L4D_SURVIVOR_FRANCIS:	return g_iCvar_BotWeaponPreference_Francis;
		case L4D_SURVIVOR_LOUIS:	return g_iCvar_BotWeaponPreference_Louis;
		default:					return g_iCvar_BotWeaponPreference_Nick;
	}
}

int GetPinnedSurvivorCount()
{
	int iCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i) || !L4D_IsPlayerPinned(i))continue;
		iCount++;
	}
	return iCount;
}

int ItemSpawnerHasEnoughItems(int iSpawner)
{
	return (!HasEntProp(iSpawner, Prop_Data, "m_itemCount") ? 9999 : GetEntProp(iSpawner, Prop_Data, "m_itemCount"));
}

bool IsWeaponNearAmmoPile(int iWeapon, int iOwner = -1)
{
	int iAmmoPile = GetItemFromArrayList(g_hAmmopileList, iWeapon, _, _, _, false);
	return (iAmmoPile != -1 && (iOwner == -1 || LBI_IsReachableEntity(iOwner, iAmmoPile)));
}

// 4th argument is now a number instead of a string
// if number >0, look for a specific weapon ID
// if number is negative, particular weapon ID is skipped/avoided
// check for sModelName is never used, let's keep it that way ;)
int GetItemFromArrayList(ArrayList hArrayList, int iClient, float fDistance = -1.0, int iWeaponID = 0, const char[] sModelName = "", bool bCheckIsReachable = true, bool bCheckIsVisible = true)
{
	float fStartedAt = g_bCvar_PerformanceLogging ? GetEngineTime() : 0.0;
	int iResult = GetItemFromArrayListImpl(hArrayList, iClient, fDistance, iWeaponID, sModelName, bCheckIsReachable, bCheckIsVisible);
	LogSlowCalculation("GetItemFromArrayList", fStartedAt, iClient, iResult);
	return iResult;
}

int GetItemFromArrayListImpl(ArrayList hArrayList, int iClient, float fDistance = -1.0, int iWeaponID = 0, const char[] sModelName = "", bool bCheckIsReachable = true, bool bCheckIsVisible = true)
{
	if (!hArrayList || hArrayList.Length <= 0)return -1;
	if (fDistance == -1.0)fDistance = g_fCvar_ItemScavenge_ApproachVisibleRange;

	static float fCheckDist, fCurDist, fPickupRange, fClientPos[3], fEntityPos[3];
	static int iEntRef, iEntIndex, iNavArea, iUseCount, iItemFlags;
	static bool bIsCoop, bInCheckpoint, bIsTaken, bInUseRange, bValidClient;

 	//char sWeaponName[MAX_TARGET_LENGTH];
	static char sEntityModel[PLATFORM_MAX_PATH];

	GetEntityAbsOrigin(iClient, fClientPos);
	bValidClient = IsValidClient(iClient);
	if (bValidClient)
	{
		bIsCoop = L4D2_IsGenericCooperativeMode();
		bInCheckpoint = LBI_IsPositionInsideCheckpoint(g_fClientAbsOrigin[iClient]);
		fPickupRange = g_fCvar_ItemScavenge_PickupRange_Sqr;
	}

	for (int i = 0; i < hArrayList.Length; i++)
	{
		iEntRef = hArrayList.Get(i);

		if (g_hForbiddenItemList.FindValue(iEntRef) != -1)
		{
			if(g_iCvar_Debug & DEBUG_SCAVENGE)
			{
				iEntIndex = EntRefToEntIndex(iEntRef);
				LogDebugMessage("Will not allow snatching %s", IBWeaponName[g_iWeaponID[iEntIndex]]);
			}
			continue;
		}

		iEntIndex = EntRefToEntIndex(iEntRef);
		if (iEntIndex == INVALID_ENT_REFERENCE || IsValidClient(GetEntityOwner(iEntIndex)))
			continue;

		iItemFlags = g_iItemFlags[iEntIndex];
		if (g_bCvar_SwitchOffCSSWeapons && iItemFlags & FLAG_CSS)
			continue;

		iUseCount = ItemSpawnerHasEnoughItems(iEntIndex);
		if (iUseCount == 0)continue;

		if (!GetEntityAbsOrigin(iEntIndex, fEntityPos) || GetVectorDistance(fClientPos, fEntityPos, true) > g_fCvar_ItemScavenge_MapSearchRange_Sqr)
			continue;

		if (sModelName[0] != 0)
		{
			GetEntityModelname(iEntIndex, sEntityModel, sizeof(sEntityModel));
			if (strcmp(sEntityModel, sModelName, false) != 0)continue;
		}

		//if(g_bCvar_Debug)
		//	PrintToServer("%s %b",IBWeaponName[g_iWeaponID[iEntIndex]], iItemFlags);

		//skip if ammo upgrade is already used
		if ( g_iItem_Used[iEntIndex] & (1 << (iClient - 1)) && iItemFlags & FLAG_AMMO && iItemFlags & FLAG_UPGRADE )
			continue;

		//skip if weapon ID is avoided
		if ( iWeaponID < 0 && g_iWeaponID[iEntIndex] == -iWeaponID )
			continue;

		//skip if WRONG weapon ID
		if ( iWeaponID > 0 && g_iWeaponID[iEntIndex] != iWeaponID )
			continue;

		fCheckDist = fDistance;
		if (bValidClient)
		{
			if ( GetWeaponTier(iEntIndex) > 0 && (g_iWeapon_Clip1[iEntIndex] + g_iWeapon_AmmoLeft[iEntIndex]) <= g_iWeapon_MaxAmmo[iEntIndex] * 0.25 )
				continue;

			if ( iUseCount == 1 && iItemFlags & FLAG_AMMO )
			{
				bIsTaken = false;
				for (int j = 1; j <= MaxClients; j++)
				{
					if (j == iClient || !IsClientSurvivor(j) || !IsFakeClient(j) || iEntIndex != g_iSurvivorBot_ScavengeItem[j] || !IsEntityExists(g_iSurvivorBot_ScavengeItem[j]))
						continue;

					bIsTaken = true;
					break;
				}
				if (bIsTaken)continue;
			}

			bInUseRange = (GetVectorDistance(g_fClientEyePos[iClient], fEntityPos, true) <= fPickupRange);
			if (!bInUseRange)
			{
				if (bIsCoop && bInCheckpoint && !LBI_IsPositionInsideCheckpoint(fEntityPos))
					continue;

				if (bCheckIsReachable && !LBI_IsReachableEntity(iClient, iEntIndex))
					continue;

				if (bCheckIsVisible && fDistance > g_fCvar_ItemScavenge_ApproachRange)
				{
					iNavArea = LBI_GetNearestNavAreaCached(fEntityPos, 300.0, true, true, false);
					if (iNavArea && !LBI_IsNavAreaPartiallyVisible(iNavArea, g_fClientEyePos[iClient], iClient))
					{
						fCheckDist = g_fCvar_ItemScavenge_ApproachRange;
					}
				}
			}
		}

		fCurDist = GetVectorDistance(fClientPos, fEntityPos, true);
		if (!bInUseRange && fCurDist > (fCheckDist*fCheckDist))continue;

		return iEntIndex;
	}

	return -1;
}
