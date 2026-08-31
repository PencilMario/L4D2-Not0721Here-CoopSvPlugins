int GetEntityOwner(int iEntity)
{
	int iOwner = GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity");
	if (!IsClientSurvivor(iOwner) || L4D_GetPlayerCurrentWeapon(iOwner) == iEntity)
		return iOwner;

	for (int i = 0; i <= 5; i++)
	{
		if (GetClientWeaponInventory(iOwner, i) != iEntity)continue;
		return iOwner;
	}
	return -1;
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if (iEntity <= 0 || iEntity > MAXENTITIES)
		return;

	g_iItem_Used[iEntity] = 0; // Clear used item bitfield
	g_iWeaponID[iEntity] = 0;
	g_iMeleeID[iEntity] = -1;
	g_iItemFlags[iEntity] = 0;
	CheckEntityForStuff(iEntity, sClassname);
}

void CheckEntityForStuff(int iEntity, const char[] sClassname)
{
	static int iCheckCase;
	static int iItemFlags;
	static L4D2WeaponId iWeaponID;
	static char sWeaponName[64];

	if (!g_bInitCheckCases)
	{
		InitCheckCases();
		//PrintToServer("CheckEntityForStuff: InitCheckCases");
	}

	if(!g_hCheckCases.GetValue(sClassname, iCheckCase))
		iCheckCase = 0;

	switch(iCheckCase)
	{
		case 1:	//witch
		{
			if (g_hWitchList)
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
					if (iWitchRef == iEntity)return;
				}

				int iIndex = g_hWitchList.Push(EntIndexToEntRef(iEntity));
				g_hWitchList.Set(iIndex, 0, 1);
				SDKHook(iEntity, SDKHook_OnTakeDamage, OnWitchTakeDamage);
				return;
			}
		}

		case 2:	//ammo
		{
			PushEntityIntoArrayList(g_hAmmopileList, iEntity);
			g_iWeaponID[iEntity] = 54; // L4D2WeaponId_Ammo
			g_iItemFlags[iEntity] = FLAG_ITEM | FLAG_AMMO;
			return;
		}

		case 3:	//laser sight
		{
			PushEntityIntoArrayList(g_hLaserSightList, iEntity);
			return;
		}

		case 4:	//deployed ammo upgrade
		{
			PushEntityIntoArrayList(g_hDeployedAmmoPacks, iEntity);
			g_iWeaponID[iEntity] = 22; // L4D2WeaponId_AmmoPack, idk if this makes sense actually
			g_iItemFlags[iEntity] = FLAG_ITEM | FLAG_AMMO | FLAG_UPGRADE;
			return;
		}
	}

	if ( !GetWeaponClassname(iEntity, sWeaponName, sizeof(sWeaponName)) )
		return;

	iWeaponID = L4D2WeaponId_None;
	if(!g_hWeaponToIDMap.GetValue(sWeaponName, iWeaponID))
		return;
	g_iWeaponID[iEntity] = view_as<int>(iWeaponID);

	if (iWeaponID == L4D2WeaponId_Melee)
	{
		if(g_iCvar_Debug & DEBUG_WEP_DATA)
			LogDebugMessage("CheckEntityForStuff: %d %s %d %s", iEntity, sClassname, iWeaponID, sWeaponName);
		if(!g_bInitMeleeIDs) InitMeleeIDs();
		g_iMeleeID[iEntity] = GetMeleeID(iEntity);
	}

	iItemFlags = 0;
	if (!g_bInitItemFlags)
	{
		InitItemFlagMap();
		//PrintToServer("CheckEntityForStuff: InitItemFlagMap");
	}
	g_hItemFlagMap.GetValue(sWeaponName, iItemFlags);
	g_iItemFlags[iEntity] = iItemFlags;

	if (iWeaponID > L4D2WeaponId_Machinegun && iWeaponID < L4D2WeaponId_Ammo)
		return;

	switch(iWeaponID)
	{
		case L4D2WeaponId_None: return;

		case L4D2WeaponId_Pistol, L4D2WeaponId_PistolMagnum:
			PushEntityIntoArrayList(g_hPistolList, iEntity);

		case L4D2WeaponId_Melee, L4D2WeaponId_Chainsaw:
			PushEntityIntoArrayList(g_hMeleeList, iEntity);

		case L4D2WeaponId_Smg, L4D2WeaponId_SmgSilenced, L4D2WeaponId_SmgMP5:
			PushEntityIntoArrayList(g_hSMGList, iEntity);

		case L4D2WeaponId_Pumpshotgun, L4D2WeaponId_ShotgunChrome:
			PushEntityIntoArrayList(g_hShotgunT1List, iEntity);

		case L4D2WeaponId_Rifle, L4D2WeaponId_RifleAK47, L4D2WeaponId_RifleDesert, L4D2WeaponId_RifleSG552:
			PushEntityIntoArrayList(g_hAssaultRifleList, iEntity);

		case L4D2WeaponId_Autoshotgun, L4D2WeaponId_ShotgunSpas:
			PushEntityIntoArrayList(g_hShotgunT2List, iEntity);

		case L4D2WeaponId_HuntingRifle, L4D2WeaponId_SniperMilitary, L4D2WeaponId_SniperScout, L4D2WeaponId_SniperAWP:
			PushEntityIntoArrayList(g_hSniperRifleList, iEntity);

		case L4D2WeaponId_PipeBomb, L4D2WeaponId_Molotov, L4D2WeaponId_Vomitjar:
			PushEntityIntoArrayList(g_hGrenadeList, iEntity);

		case L4D2WeaponId_RifleM60, L4D2WeaponId_GrenadeLauncher:
			PushEntityIntoArrayList(g_hTier3List, iEntity);

		case L4D2WeaponId_FragAmmo, L4D2WeaponId_IncendiaryAmmo:
			PushEntityIntoArrayList(g_hUpgradePackList, iEntity);

		case L4D2WeaponId_FirstAidKit:
			PushEntityIntoArrayList(g_hFirstAidKitList, iEntity);

		case L4D2WeaponId_Defibrillator:
			PushEntityIntoArrayList(g_hDefibrillatorList, iEntity);

		case L4D2WeaponId_PainPills:
			PushEntityIntoArrayList(g_hPainPillsList, iEntity);

		case L4D2WeaponId_Adrenaline:
			PushEntityIntoArrayList(g_hAdrenalineList, iEntity);
	}

	if (iWeaponID == L4D2WeaponId_Chainsaw)
	{
		g_iWeapon_Clip1[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iWeapon_MaxAmmo[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iWeapon_AmmoLeft[iEntity] = g_iCvar_MaxAmmo_Chainsaw;
		g_iMeleeID[iEntity] = 16;
		return;
	}

	if ( g_iWeaponTier[iWeaponID] != 0 )
	{
		g_iWeapon_Clip1[iEntity] = L4D2_GetIntWeaponAttribute(sWeaponName, L4D2IWA_ClipSize);
		g_iWeapon_MaxAmmo[iEntity] = GetWeaponMaxAmmo(iEntity);
		g_iWeapon_AmmoLeft[iEntity] = g_iWeapon_MaxAmmo[iEntity];
	}
}

public Action RecheckWeaponSpawn(Handle timer, int iEntity)
{
	if(!IsValidEdict(iEntity))
		return Plugin_Handled;

	char sEntClassname[64];
	GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
	CheckEntityForStuff(iEntity, sEntClassname);
	return Plugin_Handled;
}

bool ShouldUseFlowDistance()
{
	if (!L4D_IsSurvivalMode() && !L4D2_IsScavengeMode())
	{
		int iFinStage = L4D2_GetCurrentFinaleStage();
		return (iFinStage == 18 || iFinStage == 0);
	}

	return false;
}

void PushEntityIntoArrayList(ArrayList hArrayList, int iEntity)
{
	if (!hArrayList)return;
	int iEntRef = EntIndexToEntRef(iEntity);
	int iArrayEnt = hArrayList.FindValue(iEntRef);
	if (iArrayEnt == -1)hArrayList.Push(iEntRef);
}

public void OnEntityDestroyed(int iEntity)
{
	if (iEntity <= 0 || iEntity > MAXENTITIES)
		return;

	g_iItem_Used[iEntity] = 0; // Clear used item bitfield
	g_iWeaponID[iEntity] = 0;
	g_iMeleeID[iEntity] = -1;
	g_iItemFlags[iEntity] = 0;

	CheckArrayListForEntityRemoval(g_hMeleeList, iEntity);
	CheckArrayListForEntityRemoval(g_hPistolList, iEntity);
	CheckArrayListForEntityRemoval(g_hSMGList, iEntity);
	CheckArrayListForEntityRemoval(g_hShotgunT1List, iEntity);
	CheckArrayListForEntityRemoval(g_hShotgunT2List, iEntity);
	CheckArrayListForEntityRemoval(g_hAssaultRifleList, iEntity);
	CheckArrayListForEntityRemoval(g_hSniperRifleList, iEntity);
	CheckArrayListForEntityRemoval(g_hTier3List, iEntity);
	CheckArrayListForEntityRemoval(g_hFirstAidKitList, iEntity);
	CheckArrayListForEntityRemoval(g_hDefibrillatorList, iEntity);
	CheckArrayListForEntityRemoval(g_hPainPillsList, iEntity);
	CheckArrayListForEntityRemoval(g_hAdrenalineList, iEntity);
	CheckArrayListForEntityRemoval(g_hGrenadeList, iEntity);
	CheckArrayListForEntityRemoval(g_hUpgradePackList, iEntity);

	CheckArrayListForEntityRemoval(g_hAmmopileList, iEntity);
	CheckArrayListForEntityRemoval(g_hLaserSightList, iEntity);
	CheckArrayListForEntityRemoval(g_hDeployedAmmoPacks, iEntity);
	CheckArrayListForEntityRemoval(g_hForbiddenItemList, iEntity);

	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSurvivorBot_VisionMemory_State[i][iEntity] = g_iSurvivorBot_VisionMemory_State_FOV[i][iEntity] = 0;
		g_fSurvivorBot_VisionMemory_Time[i][iEntity] = g_fSurvivorBot_VisionMemory_Time_FOV[i][iEntity] = GetGameTime();
	}
}

void CheckArrayListForEntityRemoval(ArrayList hArrayList, int iEntity)
{
	if (!hArrayList)return;
	int iArrayEnt = hArrayList.FindValue(EntIndexToEntRef(iEntity));
	if (iArrayEnt != -1)hArrayList.Erase(iArrayEnt);
}

public void OnMapStart()
{
	g_bMapStarted = true;
	ResetNavigationCaches();
	ResetTeamInventoryCaches();
	GetCurrentMap(g_sCurrentMapName, sizeof(g_sCurrentMapName));
	for (int i = 1; i <= MaxClients; i++)g_fClient_ThinkFunctionDelay[i] = GetGameTime() + (g_bLateLoad ? 1.0 : 10.0);
	CreateEntityArrayLists();

	CreateVScriptCommandDetour();
	g_vsCommand.Register();

	InitMeleeIDs();

	static char sEntClassname[64];
	for (int i = 0; i < MAXENTITIES; i++)
	{
		g_iItem_Used[i] = 0;
		g_iWeaponID[i] = 0;
		g_iMeleeID[i] = -1;
		g_iItemFlags[i] = 0;
		if (!IsEntityExists(i))continue;
		GetEntityClassname(i, sEntClassname, sizeof(sEntClassname));
		CheckEntityForStuff(i, sEntClassname);
	}
}

void CheckWeaponsLater()
{
	static int iEntIndex;
	static char sEntClassname[64];

	int count = 0;
	int i = 0;
	while (i < g_hWeaponsToCheckLater.Length)
	{
		iEntIndex = EntRefToEntIndex(g_hWeaponsToCheckLater.Get(i));
		if (iEntIndex != INVALID_ENT_REFERENCE && IsEntityExists(iEntIndex))
		{
			GetEntityClassname(iEntIndex, sEntClassname, sizeof(sEntClassname));
			CheckEntityForStuff(iEntIndex, sEntClassname);
			if (g_iWeaponID[iEntIndex] != 0)
			{
				g_hWeaponsToCheckLater.Erase(i);
				count++;
			}
			else
			{
				PrintToServer("CheckWeaponsLater: %d %s WeaponID %d MeleeID %d, stopping and checking again soon\nprocessed %d items",
					iEntIndex, sEntClassname, g_iWeaponID[iEntIndex], g_iMeleeID[iEntIndex], count);
				return;
			}
		}
		else
		{
			g_hWeaponsToCheckLater.Erase(i);
			count++;
		}
	}
	g_hCheckWeaponTimer = INVALID_HANDLE;
	PrintToServer("CheckWeaponsLater: list cleared, processed %d items", count);
}

public Action CheckWeaponsEvenLater(Handle timer)
{
	CheckWeaponsLater();
	return Plugin_Handled;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetNavigationCaches();
	ResetTeamInventoryCaches();
	g_sCurrentMapName[0] = 0;
	ClearEntityArrayLists();
	ClearHashMaps();

	g_bInitMeleePrefs = false;
	g_bInitPathWithin = false;
	g_hClearBadPathTimer = INVALID_HANDLE;
	g_hCheckWeaponTimer = INVALID_HANDLE;
}

void CreateEntityArrayLists()
{
	g_hMeleeList 			= new ArrayList();
	g_hPistolList 			= new ArrayList();
	g_hSMGList 				= new ArrayList();
	g_hShotgunT1List 		= new ArrayList();
	g_hShotgunT2List 		= new ArrayList();
	g_hAssaultRifleList 	= new ArrayList();
	g_hSniperRifleList 		= new ArrayList();
	g_hTier3List 			= new ArrayList();
	g_hAmmopileList 		= new ArrayList();
	g_hUpgradePackList 		= new ArrayList();
	g_hLaserSightList 		= new ArrayList();
	g_hFirstAidKitList 		= new ArrayList();
	g_hDefibrillatorList 	= new ArrayList();
	g_hPainPillsList 		= new ArrayList();
	g_hAdrenalineList 		= new ArrayList();
	g_hGrenadeList 			= new ArrayList();
	g_hDeployedAmmoPacks 	= new ArrayList();
	g_hForbiddenItemList 	= new ArrayList(2);
	g_hWitchList 			= new ArrayList(2);
	g_hBadPathEntities 		= new ArrayList();
	g_hWeaponsToCheckLater 	= new ArrayList();
}

void ClearEntityArrayLists()
{
	g_hMeleeList.Clear();
	g_hPistolList.Clear();
	g_hSMGList.Clear();
	g_hShotgunT1List.Clear();
	g_hShotgunT2List.Clear();
	g_hAssaultRifleList.Clear();
	g_hSniperRifleList.Clear();
	g_hTier3List.Clear();
	g_hAmmopileList.Clear();
	g_hUpgradePackList.Clear();
	g_hLaserSightList.Clear();
	g_hFirstAidKitList.Clear();
	g_hDefibrillatorList.Clear();
	g_hPainPillsList.Clear();
	g_hAdrenalineList.Clear();
	g_hGrenadeList.Clear();
	g_hDeployedAmmoPacks.Clear();
	g_hForbiddenItemList.Clear();
	g_hWitchList.Clear();
	g_hBadPathEntities.Clear();
	g_hWeaponsToCheckLater.Clear();
}

void ClearHashMaps()
{
	if(g_hMeleeIDs != INVALID_HANDLE)
		g_hMeleeIDs.Clear();
	if(g_hCheckCases != INVALID_HANDLE)
		g_hCheckCases.Clear();
	if(g_hItemFlagMap != INVALID_HANDLE)
		g_hItemFlagMap.Clear();
	if(g_hWeaponMap != INVALID_HANDLE)
		g_hWeaponMap.Clear();

	g_bInitMeleeIDs = false;
	g_bInitCheckCases = false;
	g_bInitMaxAmmo = false;
	g_bInitItemFlags = false;
	g_bInitWeaponMap = false;
}
