void SwitchWeaponSlot(int iClient, int iSlot)
{
	int iWeapon = GetClientWeaponInventory(iClient, iSlot);
	if (iWeapon == -1 || L4D_GetPlayerCurrentWeapon(iClient) == iWeapon)
		return;

	static char sWeaponName[64]; GetEdictClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	FakeClientCommand(iClient, "use %s", sWeaponName);
}

bool IsWeaponSlotActive(int iClient, int iSlot)
{
	return (GetClientWeaponInventory(iClient, iSlot) == L4D_GetPlayerCurrentWeapon(iClient));
}

bool SurvivorHasSMG(int iClient)
{
	return ( g_iClientInvFlags[iClient] & FLAG_SMG != 0 );
}

bool SurvivorHasAssaultRifle(int iClient)
{
	static int iSlot, iItemFlags;

	iSlot = GetClientWeaponInventory(iClient, 0);
	if (iSlot == -1) return false;

	iItemFlags = g_iClientInvFlags[iClient];

	return ( iItemFlags & FLAG_ASSAULT ? true : false);
}

int SurvivorHasShotgun(int iClient)
{
	return ( (g_iClientInvFlags[iClient] & FLAG_SHOTGUN != 0) + (g_iClientInvFlags[iClient] & FLAG_SHOTGUN && g_iClientInvFlags[iClient] & FLAG_TIER2) );
}

// Used to return int, which was unused
bool SurvivorHasSniperRifle(int iClient)
{
	return ( g_iClientInvFlags[iClient] & FLAG_SNIPER != 0 );
}

int SurvivorHasTier3Weapon(int iClient)
{
	return ( (g_iClientInvFlags[iClient] & FLAG_TIER3 != 0) + (g_iClientInvFlags[iClient] & FLAG_M60 != 0) );
}

int SurvivorHasGrenade(int iClient)
{
	int iSlot = GetClientWeaponInventory(iClient, 2);
	if (iSlot == -1)return 0;

	static char sWepName[64]; GetEdictClassname(iSlot, sWepName, sizeof(sWepName));
	switch(sWepName[7])
	{
		case 'p': return 1;
		case 'm': return 2;
		case 'v': return 3;
		default: return 0;
	}
}

//returns the same thing! :)
stock int SurvivorHasHealthKit(int iClient)
{
	return ( (g_iClientInvFlags[iClient] >> 22 & 1) + (g_iClientInvFlags[iClient] >> 20 & 2) + (g_iClientInvFlags[iClient] >> 4 & 1) * 3 );
}

int SurvivorHasMeleeWeapon(int iClient)
{
	return ( (g_iClientInvFlags[iClient] >> 6 & 1) + (g_iClientInvFlags[iClient] >> 16 & 1) );
}

int SurvivorHasPistol(int iClient)
{
	static int iSlot, iItemFlags;

	iSlot = GetClientWeaponInventory(iClient, 1);
	if (iSlot == -1) return 0;

	iItemFlags = g_iClientInvFlags[iClient];

	if ( iItemFlags & FLAG_PISTOL_EXTRA && !(iItemFlags & FLAG_PISTOL) )
		return 3;
	else
		return ( (GetEntProp(iSlot, Prop_Send, "m_isDualWielding") != 0 || GetEntProp(iSlot, Prop_Send, "m_hasDualWeapons") != 0) ? 2 : (iItemFlags & FLAG_PISTOL ? 1 : 0) );
}

int GetSurvivorTeamActiveItemCount(const L4D2WeaponId iWeaponID)
{
	int iCount, iWeaponSlot, iCurWeapon;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))continue;
		iCurWeapon = L4D_GetPlayerCurrentWeapon(i);

		for (int j = 0; j <= 5; j++)
		{
			iWeaponSlot = GetClientWeaponInventory(i, j);
			if (IsEntityExists(iWeaponSlot) && iCurWeapon == iWeaponSlot && L4D2_GetWeaponId(iWeaponSlot) == iWeaponID)
			{
				iCount++;
				break;
			}
		}
	}
	return iCount;
}

int GetSurvivorTeamItemCount(const L4D2WeaponId iWeaponID)
{
	static int iCount, iWeaponSlot;
	iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))
			continue;
		for (int j = 0; j <= 5; j++)
		{
			iWeaponSlot = GetClientWeaponInventory(i, j);
			if (IsEntityExists(iWeaponSlot) && L4D2_GetWeaponId(iWeaponSlot) == iWeaponID)
			{
				iCount++;
				break;
			}
		}
	}
	return iCount;
}

/*
	Use this whenever you need to count survivors with an item of certain category(inventory flag)
	e.g. an assault rifle, a melee weapon, a grenade etc

	Second argument ~ "AND"
	Sending multiple flags in one argument ~ "OR"
	Negative argument ~ "NOT", don't put multiple flags under one argument,
	e.g.
	(FLAG_PISTOL | FLAG_PISTOL_EXTRA) will count survivors that carry either pistol(s) or Magnum
	(FLAG_SHOTGUN, FLAG_TIER1) – survivors with Tier 1 shotguns
	(-FLAG_PISTOL, FLAG_PISTOL_EXTRA) – survivors with Magnum specifically
*/
int GetSurvivorTeamInventoryCount(int iFlag, int iFlag2 = 0)
{
	static int iCount;
	static bool bNegate, bNegate2;

	bNegate = (iFlag < 0);
	bNegate2 = (iFlag2 < 0);

	iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientSurvivor(i))
			continue;
		if ( (bNegate ? ~g_iClientInvFlags[i] & -iFlag : g_iClientInvFlags[i] & iFlag)
			&& (iFlag2 ? (bNegate2 ? ~g_iClientInvFlags[i] & -iFlag2 : g_iClientInvFlags[i] & iFlag2) : 1) )
		{
			iCount++;
		}
	}
	return iCount;
}

bool IsWeaponReloading(int iWeapon, bool bIgnoreShotguns = true)
{
	if (!IsEntityExists(iWeapon) || !HasEntProp(iWeapon, Prop_Data, "m_bInReload"))
		return false;

	bool bInReload = !!GetEntProp(iWeapon, Prop_Data, "m_bInReload");
	if (bInReload && bIgnoreShotguns)
	{
		static int iItemFlags;
		iItemFlags = g_iItemFlags[iWeapon];

		return !(iItemFlags & FLAG_SHOTGUN);
	}
	return (bInReload);
}

stock float GetWeaponNextFireTime(int iWeapon)
{
	return (GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack"));
}

stock int GetWeaponClip1(int iWeapon)
{
	return (GetEntProp(iWeapon, Prop_Send, "m_iClip1"));
}

stock int GetWeaponClipSize(int iWeapon)
{
	return (SDKCall(g_hGetMaxClip1, iWeapon));
}
