void InitItemFlagMap()
{
	g_hItemFlagMap = CreateTrie();
	g_hItemFlagMap.SetValue("weapon_melee"			, FLAG_WEAPON | FLAG_MELEE );
	g_hItemFlagMap.SetValue("weapon_chainsaw"		, FLAG_WEAPON | FLAG_MELEE | FLAG_CHAINSAW);
	g_hItemFlagMap.SetValue("weapon_pistol"			, FLAG_WEAPON | FLAG_PISTOL );
	g_hItemFlagMap.SetValue("weapon_pistol_magnum"	, FLAG_WEAPON | FLAG_PISTOL_EXTRA );
	g_hItemFlagMap.SetValue("weapon_smg"			, FLAG_WEAPON | FLAG_SMG | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_smg_silenced"	, FLAG_WEAPON | FLAG_SMG | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_smg_mp5"		, FLAG_WEAPON | FLAG_SMG | FLAG_TIER1 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_pumpshotgun"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_shotgun_chrome"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER1 );
	g_hItemFlagMap.SetValue("weapon_autoshotgun"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_shotgun_spas"	, FLAG_WEAPON | FLAG_SHOTGUN | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle"			, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle_ak47"		, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle_desert"	, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_rifle_sg552"	, FLAG_WEAPON | FLAG_ASSAULT | FLAG_TIER2 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_hunting_rifle"	, FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_sniper_military", FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 );
	g_hItemFlagMap.SetValue("weapon_sniper_scout"	, FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_sniper_awp"		, FLAG_WEAPON | FLAG_SNIPER | FLAG_TIER2 | FLAG_CSS );
	g_hItemFlagMap.SetValue("weapon_first_aid_kit"	, FLAG_ITEM | FLAG_HEAL | FLAG_MEDKIT);
	g_hItemFlagMap.SetValue("weapon_defibrillator"	, FLAG_ITEM | FLAG_HEAL | FLAG_DEFIB);
	g_hItemFlagMap.SetValue("weapon_pain_pills"		, FLAG_ITEM | FLAG_HEAL );
	g_hItemFlagMap.SetValue("weapon_adrenaline"		, FLAG_ITEM | FLAG_HEAL );
	g_hItemFlagMap.SetValue("weapon_molotov"		, FLAG_WEAPON | FLAG_GREN );
	g_hItemFlagMap.SetValue("weapon_pipe_bomb"		, FLAG_WEAPON | FLAG_GREN );
	g_hItemFlagMap.SetValue("weapon_vomitjar"		, FLAG_WEAPON | FLAG_GREN );
	g_hItemFlagMap.SetValue("weapon_gascan"			, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_propanetank"	, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_oxygentank"		, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_gnome"			, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_cola_bottles"	, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_fireworkcrate"	, FLAG_ITEM | FLAG_CARRY );
	g_hItemFlagMap.SetValue("weapon_grenade_launcher", FLAG_WEAPON | FLAG_GL | FLAG_TIER3 );
	g_hItemFlagMap.SetValue("weapon_rifle_m60"		, FLAG_WEAPON | FLAG_M60 | FLAG_TIER3 );
	g_hItemFlagMap.SetValue("weapon_upgradepack_incendiary"	, FLAG_ITEM | FLAG_UPGRADE );
	g_hItemFlagMap.SetValue("weapon_upgradepack_explosive"	, FLAG_ITEM | FLAG_UPGRADE );
	g_hItemFlagMap.SetValue("weapon_ammo"			, FLAG_ITEM | FLAG_AMMO );
	g_hItemFlagMap.SetValue("weapon_ammo_pack"		, FLAG_ITEM | FLAG_AMMO | FLAG_UPGRADE );
	g_hItemFlagMap.SetValue("upgrade_item"			, FLAG_ITEM | FLAG_UPGRADE );
	g_bInitItemFlags = true;
}

void InitMeleeIDs()
{
	g_hMeleeIDs = CreateTrie();
	int iTable = FindStringTable("meleeweapons");

	if( iTable == INVALID_STRING_TABLE ) // Default to known IDs
	{
		PrintToServer("InitMeleeIDs: no meleeweapons table!!!");
		g_hMeleeIDs.SetValue("fireaxe",				0);
		g_hMeleeIDs.SetValue("frying_pan",			1);
		g_hMeleeIDs.SetValue("machete",				2);
		g_hMeleeIDs.SetValue("baseball_bat",		3);
		g_hMeleeIDs.SetValue("crowbar",				4);
		g_hMeleeIDs.SetValue("cricket_bat",			5);
		g_hMeleeIDs.SetValue("tonfa",				6);
		g_hMeleeIDs.SetValue("katana",				7);
		g_hMeleeIDs.SetValue("electric_guitar",		8);
		g_hMeleeIDs.SetValue("knife",				9);
		g_hMeleeIDs.SetValue("golfclub",			10);
		g_hMeleeIDs.SetValue("pitchfork",			11);
		g_hMeleeIDs.SetValue("shovel",				12);
	} else {
		// Get actual IDs
		int iNum = GetStringTableNumStrings(iTable);
		char sName[PLATFORM_MAX_PATH];

		for( int i = 0; i < iNum; i++ )
		{
			ReadStringTable(iTable, i, sName, sizeof(sName));
			//PrintToServer("InitMeleeIDs: %s id %d", sName, i);
			g_hMeleeIDs.SetValue(sName, i);
		}
	}
	g_hMeleeIDs.SetValue("chainsaw", 16);

	g_bInitMeleeIDs = true;
}

void InitMeleePrefs()
{
	static char sBuffer[32];
	static int iMeleeID, iValue;

	for (int i = 0; i < 16; i++)
		g_iMeleePreference[i] = -1;

	Handle hKeys = CreateTrieSnapshot(g_hMeleePref);
	int size = GetTrieSize(g_hMeleePref);
	//PrintToServer("InitMeleePrefs: g_hMeleePref size %d", size);
	for (int i = 0; i < size; i++)
	{
		GetTrieSnapshotKey(hKeys, i, sBuffer, sizeof(sBuffer));
		if (g_hMeleeIDs.GetValue(sBuffer, iMeleeID))
		{
			g_hMeleePref.GetValue(sBuffer, iValue);
			//PrintToServer("%d %s %d", iMeleeID, sBuffer, iValue);
			g_iMeleePreference[iMeleeID] = iValue;
		}
	}
	delete hKeys;
	g_bInitMeleePrefs = true;
}

void InitCheckCases()
{
	g_hCheckCases = CreateTrie();
	g_hCheckCases.SetValue("witch", 1 );
	g_hCheckCases.SetValue("weapon_ammo_spawn", 2 );
	g_hCheckCases.SetValue("upgrade_laser_sight", 3 );
	g_hCheckCases.SetValue("upgrade_ammo_explosive", 4 );
	g_hCheckCases.SetValue("upgrade_ammo_incendiary", 4 );
	g_bInitCheckCases = true;
}

void InitMaxAmmo()
{
	int iMaxAmmo, iAmmoOverride[56];
	char sArgs[16][8], sBuffer[2][4];
	L4D2WeaponId iWeaponID;

	if ( strlen(g_sCvar_Ammo_Type_Override) && ExplodeString(g_sCvar_Ammo_Type_Override, " ", sArgs, sizeof(sArgs), sizeof(sArgs[]), true) )
	{
		for (int i = 0; i < sizeof(sArgs); i++)
		{
			if (ExplodeString(sArgs[i], ":", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]), true) == 2)
				iAmmoOverride[StringToInt(sBuffer[0])] = StringToInt(sBuffer[1]);
		}
	}

	for (int i = 0; i < 56; i++) // L4D2WeaponId_MAX is 56
	{
		iWeaponID = view_as<L4D2WeaponId>(i);
		iMaxAmmo = -1;
		if (iAmmoOverride[i])
		{
			g_iMaxAmmo[i] = iAmmoOverride[i];
			//if (g_bCvar_Debug)
			//	PrintToServer("InitMaxAmmo: %s max ammo %d (override)", IBWeaponName[i], g_iMaxAmmo[i]);
			continue;
		}
		switch(iWeaponID)
		{
			case L4D2WeaponId_Pistol, L4D2WeaponId_PistolMagnum:
				iMaxAmmo = g_iCvar_MaxAmmo_Pistol;
			case L4D2WeaponId_Smg, L4D2WeaponId_SmgSilenced, L4D2WeaponId_SmgMP5:
				iMaxAmmo = g_iCvar_MaxAmmo_SMG;
			case L4D2WeaponId_Pumpshotgun, L4D2WeaponId_ShotgunChrome:
				iMaxAmmo = g_iCvar_MaxAmmo_Shotgun;
			case L4D2WeaponId_Autoshotgun, L4D2WeaponId_ShotgunSpas:
				iMaxAmmo = g_iCvar_MaxAmmo_AutoShotgun;
			case L4D2WeaponId_Rifle, L4D2WeaponId_RifleAK47, L4D2WeaponId_RifleDesert, L4D2WeaponId_RifleSG552:
				iMaxAmmo = g_iCvar_MaxAmmo_AssaultRifle;
			case L4D2WeaponId_HuntingRifle:
				iMaxAmmo = g_iCvar_MaxAmmo_HuntRifle;
			case L4D2WeaponId_SniperMilitary, L4D2WeaponId_SniperScout, L4D2WeaponId_SniperAWP:
				iMaxAmmo = g_iCvar_MaxAmmo_SniperRifle;
			case L4D2WeaponId_GrenadeLauncher:
				iMaxAmmo = g_iCvar_MaxAmmo_GrenLauncher;
			case L4D2WeaponId_RifleM60:
				iMaxAmmo = g_iCvar_MaxAmmo_M60;
			case L4D2WeaponId_FirstAidKit:
				iMaxAmmo = g_iCvar_MaxAmmo_Medkit;
			case L4D2WeaponId_Adrenaline:
				iMaxAmmo = g_iCvar_MaxAmmo_Adrenaline;
			case L4D2WeaponId_PainPills:
				iMaxAmmo = g_iCvar_MaxAmmo_PainPills;
			case L4D2WeaponId_FragAmmo, L4D2WeaponId_IncendiaryAmmo:
				iMaxAmmo = g_iCvar_MaxAmmo_AmmoPack;
			case L4D2WeaponId_Chainsaw:
				iMaxAmmo = g_iCvar_MaxAmmo_Chainsaw;
			case L4D2WeaponId_PipeBomb:
				iMaxAmmo = g_iCvar_MaxAmmo_PipeBomb;
			case L4D2WeaponId_Molotov:
				iMaxAmmo = g_iCvar_MaxAmmo_Molotov;
			case L4D2WeaponId_Vomitjar:
				iMaxAmmo = g_iCvar_MaxAmmo_VomitJar;
		}
		g_iMaxAmmo[i] = iMaxAmmo;
		//if (g_bCvar_Debug && iMaxAmmo > -1)
		//	PrintToServer("InitMaxAmmo: %s max ammo %d", IBWeaponName[i], g_iMaxAmmo[i]);
	}

	for (int i = 0; i > MAXENTITIES; i++)
	{
		g_iWeapon_MaxAmmo[i] = g_iMaxAmmo[g_iWeaponID[i]];
	}
	g_bInitMaxAmmo = true;
}

void InitWeaponAndTierMap()
{
	//g_iWeaponTier[L4D2WeaponId_None] = -1;
	//g_iWeaponTier[L4D2WeaponId_Pistol] = 0;
	//g_iWeaponTier[L4D2WeaponId_Smg] = 1;
	//g_iWeaponTier[L4D2WeaponId_Pumpshotgun] = 1;
	//g_iWeaponTier[L4D2WeaponId_Autoshotgun] = 2;
	//g_iWeaponTier[L4D2WeaponId_Rifle] = 2;
	//g_iWeaponTier[L4D2WeaponId_HuntingRifle] = 2;
	//g_iWeaponTier[L4D2WeaponId_SmgSilenced] = 1;
	//g_iWeaponTier[L4D2WeaponId_ShotgunChrome] = 1;
	//g_iWeaponTier[L4D2WeaponId_RifleDesert] = 2;
	//g_iWeaponTier[L4D2WeaponId_SniperMilitary] = 2;
	//g_iWeaponTier[L4D2WeaponId_ShotgunSpas] = 2;
	//g_iWeaponTier[L4D2WeaponId_FirstAidKit] = 0;
	//g_iWeaponTier[L4D2WeaponId_Molotov] = 0;
	//g_iWeaponTier[L4D2WeaponId_PipeBomb] = 0;
	//g_iWeaponTier[L4D2WeaponId_PainPills] = 0;
	//g_iWeaponTier[L4D2WeaponId_Gascan] = 0;
	//g_iWeaponTier[L4D2WeaponId_PropaneTank] = 0;
	//g_iWeaponTier[L4D2WeaponId_OxygenTank] = 0;
	//g_iWeaponTier[L4D2WeaponId_Melee] = 0;
	//g_iWeaponTier[L4D2WeaponId_Chainsaw] = 0;
	g_iWeaponTier[L4D2WeaponId_GrenadeLauncher] = 3;
	g_iWeaponTier[L4D2WeaponId_AmmoPack] = -1;
	//g_iWeaponTier[L4D2WeaponId_Adrenaline] = 0;
	//g_iWeaponTier[L4D2WeaponId_Defibrillator] = 0;
	//g_iWeaponTier[L4D2WeaponId_Vomitjar] = 0;
	//g_iWeaponTier[L4D2WeaponId_RifleAK47] = 0;
	//g_iWeaponTier[L4D2WeaponId_GnomeChompski] = 0;
	//g_iWeaponTier[L4D2WeaponId_ColaBottles] = 0;
	//g_iWeaponTier[L4D2WeaponId_FireworksBox] = 0;
	//g_iWeaponTier[L4D2WeaponId_IncendiaryAmmo] = 0;
	//g_iWeaponTier[L4D2WeaponId_FragAmmo] = 0;
	//g_iWeaponTier[L4D2WeaponId_PistolMagnum] = 0;
	//g_iWeaponTier[L4D2WeaponId_SmgMP5] = 1;
	//g_iWeaponTier[L4D2WeaponId_RifleSG552] = 2;
	//g_iWeaponTier[L4D2WeaponId_SniperAWP] = 2;
	//g_iWeaponTier[L4D2WeaponId_SniperScout] = 2;
	g_iWeaponTier[L4D2WeaponId_RifleM60] = 3;
	g_iWeaponTier[L4D2WeaponId_Machinegun] = -1;
	g_iWeaponTier[L4D2WeaponId_FatalVomit] = -1;
	g_iWeaponTier[L4D2WeaponId_ExplodingSplat] = -1;
	g_iWeaponTier[L4D2WeaponId_LungePounce] = -1;
	g_iWeaponTier[L4D2WeaponId_Lounge] = -1;
	g_iWeaponTier[L4D2WeaponId_FullPull] = -1;
	g_iWeaponTier[L4D2WeaponId_Choke] = -1;
	g_iWeaponTier[L4D2WeaponId_ThrowingRock] = -1;
	g_iWeaponTier[L4D2WeaponId_TurboPhysics] = -1;
	g_iWeaponTier[L4D2WeaponId_Ammo] = -1;
	g_iWeaponTier[L4D2WeaponId_UpgradeItem] = -1;

	g_bIsSemiAuto[L4D2WeaponId_Pistol] = true;
	g_bIsSemiAuto[L4D2WeaponId_PistolMagnum] = true;
	g_bIsSemiAuto[L4D2WeaponId_Pumpshotgun] = true;
	g_bIsSemiAuto[L4D2WeaponId_ShotgunChrome] = true;
	g_bIsSemiAuto[L4D2WeaponId_Autoshotgun] = true;
	g_bIsSemiAuto[L4D2WeaponId_ShotgunSpas] = true;
	g_bIsSemiAuto[L4D2WeaponId_HuntingRifle] = true;
	g_bIsSemiAuto[L4D2WeaponId_SniperMilitary] = true;
	g_bIsSemiAuto[L4D2WeaponId_SniperScout] = true;
	g_bIsSemiAuto[L4D2WeaponId_SniperAWP] = true;
	g_bIsSemiAuto[L4D2WeaponId_GrenadeLauncher] = true;
	g_bIsSemiAuto[L4D2WeaponId_PainPills] = true;
	g_bIsSemiAuto[L4D2WeaponId_Adrenaline] = true;
	g_bIsSemiAuto[L4D2WeaponId_PipeBomb] = true;
	g_bIsSemiAuto[L4D2WeaponId_Molotov] = true;
	g_bIsSemiAuto[L4D2WeaponId_Vomitjar] = true;

	g_hWeaponMap = CreateTrie();

	for (int i = 0; i < 56; i++) // L4D2WeaponId_MAX is 56
		g_hWeaponMap.SetValue(IBWeaponName[i], true);

	if (L4D_HasMapStarted())
		UpdateWeaponTiers();
	else
		RequestFrame(UpdateWeaponTiers);

	g_bInitWeaponMap = true;
}

void UpdateWeaponTiers()
{
	for (int i = 0; i < 38; i++) // 37 L4D2WeaponId_RifleM60
	{
		if(g_iWeaponTier[i] != 3 && g_iWeaponTier[i] != -1)
		{
			g_iWeaponTier[i] = L4D2_GetIntWeaponAttribute(IBWeaponName[i], L4D2IWA_Tier);
			//PrintToServer("UpdateWeaponTiers: %d %s %d, mapstart %b", i, IBWeaponName[i], g_iWeaponTier[i], L4D_HasMapStarted());
		}
	}
}

void GetEntityModelname(int iEntity, char[] sModelName, int iMaxLength)
{
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, iMaxLength);
}

float GetClientDistance(int iClient, int iTarget, bool bSquared = false)
{
	return GetVectorDistance(g_fClientAbsOrigin[iClient], g_fClientAbsOrigin[iTarget], bSquared);
}

float GetEntityDistance(int iEntity, int iTarget, bool bSquared = false)
{
	float fEntityPos[3]; GetEntityAbsOrigin(iEntity, fEntityPos);
	float fTargetPos[3]; GetEntityAbsOrigin(iTarget, fTargetPos);
	return (GetVectorDistance(fEntityPos, fTargetPos, bSquared));
}

bool IsValidVector(const float fVector[3])
{
	int iCheck;
	for (int i = 0; i < 3; ++i)
	{
		if (fVector[i] != 0.0000)break;
		++iCheck;
	}
	return view_as<bool>(iCheck != 3);
}

int GetEntityHealth(int iEntity)
{
	return (GetEntProp(iEntity, Prop_Data, "m_iHealth"));
}

int GetEntityMaxHealth(int iEntity)
{
	return (GetEntProp(iEntity, Prop_Data, "m_iMaxHealth"));
}

float GetWeaponCycleTime(int iWeapon)
{
	static char sWeaponName[64];
	GetWeaponClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	if (!L4D2_IsValidWeapon(sWeaponName))return -1.0;
	return L4D2_GetFloatWeaponAttribute(sWeaponName, L4D2FWA_CycleTime);
}

//Get max ammo for entity depending on weapon ID
//
//When this is called, we assume that weapon id is known, and available in g_iWeaponID
//
//Instead of figuring out weapon name or ammo type from prop data, we use "lookup table", that's initiated once per round at worst
//
int GetWeaponMaxAmmo(int iWeapon)
{
	if (!g_bInitMaxAmmo)
	{
		InitMaxAmmo();
		PrintToServer("GetWeaponMaxAmmo: InitMaxAmmo");
	}

	return g_iMaxAmmo[g_iWeaponID[iWeapon]];
}

int GetWeaponTier(int iWeapon)
{
	return g_iWeaponTier[g_iWeaponID[iWeapon]];
}

bool IsSurvivorCarryingProp(int iClient)
{
	return (IsWeaponSlotActive(iClient, 5));
}

//	Get weapon classname from entity ID
//	Return 0 if weapon is not recognized
//	1 if it's weapon proper
//	-1 if the entity is not exactly a weapon (may be weapon_spawn)
int GetWeaponClassname(int iWeapon, char[] sBuffer, int iMaxLength)
{
	//static char classname[64];
	//strcopy( classname, sizeof(classname), sBuffer );

	if ( !GetEdictClassname(iWeapon, sBuffer, iMaxLength) )
		return 0;

	if (!g_bInitWeaponMap)
	{
		InitWeaponAndTierMap();
		PrintToServer("GetWeaponClassname: InitWeaponAndTierMap");
	}
	if( g_hWeaponMap.ContainsKey(sBuffer) ) // if it's a weapon name already, just get on with it
	{
		//if (g_bCvar_Debug)
		//PrintToServer("Classname %s exists as key, id %d", sBuffer, iWeapon);

		return 1;
	}

	if (strcmp(sBuffer, "weapon_spawn") == 0)
	{
		int iWeaponID = GetEntProp(iWeapon, Prop_Send, "m_weaponID");
		if (iWeaponID == 0)
		{
			PushEntityIntoArrayList(g_hWeaponsToCheckLater, iWeapon);
			if (g_hCheckWeaponTimer == INVALID_HANDLE)
				g_hCheckWeaponTimer = CreateTimer(0.1, CheckWeaponsEvenLater);
			return 0;
		}

		strcopy( sBuffer, iMaxLength, IBWeaponName[iWeaponID] );

		//if (g_bCvar_Debug)
		//PrintToServer("Got weapon name %s from IBWeaponName for id %d classname %s", IBWeaponName[iWeaponID], iWeapon, classname);

		return -1;
	}

	for (int i = strlen(sBuffer); i > 0; --i)
    {
        if(sBuffer[i] == '_')
        {
            sBuffer[i] = EOS;
            break;
        }
    }
	if( g_hWeaponMap.ContainsKey(sBuffer) )
	{
		//if (g_bCvar_Debug)
		//PrintToServer("Got weapon name %s from WeaponMap for id %d classname %s", sBuffer, iWeapon, classname);

		return -1;
	}

	if(g_iCvar_ItemScavenge_Models)
	{
		static char sWeaponModel[PLATFORM_MAX_PATH];
		GetEntityModelname(iWeapon, sWeaponModel, sizeof(sWeaponModel));

		if( g_hWeaponMdlMap.GetString(sWeaponModel, sBuffer, iMaxLength) )
		{
			//if (g_bCvar_Debug)
			//	PrintToServer("Judged weapon class %s by model from id %d classname %s!", sBuffer, iWeapon, classname);

			return -1;
		}
	}

	//if (g_bCvar_Debug)
	//	PrintToServer("Could not recognize weapon from entity %d %s! buffer %s model %s", iWeapon, classname, sBuffer, sWeaponModel);

	return 0;
}

//	Determine melee ID ""once"" on entity creation
//	scratch that; volvo gotta mangle entities across multiple frames
int GetMeleeID(int iEntity, bool bRechecking = false)
{
	static char sModelName[64], sEntClassname[64], sBuffer[32];
	static int iMeleeID;

	iMeleeID = -1;
	sBuffer[0] = EOS;

	GetEntityClassname(iEntity, sEntClassname, sizeof(sEntClassname));
	if( bRechecking && strncmp(sEntClassname, "weapon_melee", 12) != 0 )
	{
		if(g_iCvar_Debug & DEBUG_WEP_DATA)
			LogDebugMessage("GetMeleeID: ent %d %s is no more a melee weapon", iEntity, sEntClassname);
		return -1;
	}
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	if(sModelName[0] == EOS)
	{
		if(g_iCvar_Debug & DEBUG_WEP_DATA)
			LogDebugMessage("GetMeleeID: ent %d %s got no model%s", iEntity, sEntClassname, bRechecking ? " when rechecking!" : "");
		RequestFrame(RecheckMelee, iEntity);
		return -1;
	}

	g_hMeleeMdlToID.GetString(sModelName, sBuffer, sizeof(sBuffer));
	g_hMeleeIDs.GetValue(sBuffer, iMeleeID);

	if(g_iCvar_Debug & DEBUG_WEP_DATA)
		LogDebugMessage("GetMeleeID: model %s\nent %d melee #%d %s %s", sModelName, iEntity, iMeleeID, sBuffer, bRechecking ? "(rechecked)" : "");

	return iMeleeID;
}

void RecheckMelee(int iEntity)
{
	if(IsValidEntity(iEntity))
		g_iMeleeID[iEntity] = GetMeleeID(iEntity, true);
}

int GetMeleePreference(int iEntity)
{
	static int iMeleeID;

	if(!g_bInitMeleePrefs) InitMeleePrefs();
	iMeleeID = g_iMeleeID[iEntity];

	return (iMeleeID != -1) ? g_iMeleePreference[iMeleeID] : 0;
}

int GetClientSurvivorType(int iClient)
{
	static char sModelname[PLATFORM_MAX_PATH]; GetClientModel(iClient, sModelname, sizeof(sModelname));
	switch(sModelname[29])
	{
		case 'b': 	return L4D_SURVIVOR_NICK;
		case 'd': 	return L4D_SURVIVOR_ROCHELLE;
		case 'c': 	return L4D_SURVIVOR_COACH;
		case 'h': 	return L4D_SURVIVOR_ELLIS;
		case 'v': 	return L4D_SURVIVOR_BILL;
		case 'n': 	return L4D_SURVIVOR_ZOEY;
		case 'e': 	return L4D_SURVIVOR_FRANCIS;
		case 'a': 	return L4D_SURVIVOR_LOUIS;
		default:	return 0;
	}
}

bool IsEntityExists(int iEntity)
{
	return (iEntity > 0 && (iEntity <= MAXENTITIES && IsValidEdict(iEntity) || iEntity > MAXENTITIES && IsValidEntity(iEntity)));
}
