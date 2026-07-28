float GetCommonInfectedDamage()
{
	switch(GetCurrentGameDifficulty())
	{
		case 1:	return 1.0;
		case 3:	return 5.0;
		case 4: return 20.0;
		default: return 2.0;
	}
}

int GetCommonHitsUntilDown(int iClient, float fScale = 1.0)
{
	int iHits = RoundToFloor((GetClientRealHealth(iClient) / GetCommonInfectedDamage()) * fScale);
	if (iHits < 1)iHits = 1;
	return iHits;
}

float GetClientMaxSpeed(int iClient)
{
	return (GetEntPropFloat(iClient, Prop_Send, "m_flMaxspeed") * GetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue"));
}

bool PressAttackButton(int iClient, int &buttons, float fFireRate = -1.0)
{
	if (g_bClient_IsFiringWeapon[iClient])
		return false;

	static int iWeapon, iPistol;
	static float fClampDist, fCycleTime, fNextFireT, fAimPos[3];
	static L4D2WeaponId iWeaponID;
	iWeapon = L4D_GetPlayerCurrentWeapon(iClient);
	if (iWeapon == -1)return false;

	if (IsFakeClient(iClient) && (g_bCvar_BotsDontShoot || g_bSurvivorBot_PreventFire[iClient]))
		return false;

	iWeaponID = view_as<L4D2WeaponId>(g_iWeaponID[iWeapon]);
	fNextFireT = fFireRate;
	iPistol = (iWeaponID == L4D2WeaponId_Pistol ? 1 : iWeaponID == L4D2WeaponId_PistolMagnum ? 2 : 0);
	if (fNextFireT <= 0.0 && (iPistol != 0 || GetWeaponTier(iWeapon) > 0))
	{
		fCycleTime = GetWeaponCycleTime(iWeapon);
		if (iPistol == 1 && g_iClientInvFlags[iClient] & FLAG_PISTOL_EXTRA)
			fCycleTime *= 2.5;
		GetClientAimPosition(iClient, fAimPos);

		fClampDist = 1800.0;
		if (iPistol == 2)
			fClampDist *= 0.5;
		else if (GetEntProp(iWeapon, Prop_Send, "m_upgradeBitVec") & L4D2_WEPUPGFLAG_LASER)
			fClampDist *= 2.0;

		fNextFireT = (fCycleTime * (GetVectorDistance(g_fClientEyePos[iClient], fAimPos) / fClampDist));
	}

	if (fNextFireT < GetGameFrameTime())
	{
		if (g_bIsSemiAuto[iWeaponID])
			fNextFireT = GetGameFrameTime();
	}

	if (fNextFireT <= 0.0 || GetGameTime() > g_fSurvivorBot_NextPressAttackTime[iClient])
	{
		if (GetWeaponClip1(iWeapon) > 0)g_fSurvivorBot_BlockWeaponReloadTime[iClient] = GetGameTime() + 2.0;
		buttons |= IN_ATTACK;
		g_bClient_IsFiringWeapon[iClient] = true;
		g_fSurvivorBot_NextPressAttackTime[iClient] = GetGameTime() + fNextFireT;
		return true;
	}
	return false;
}

int GetWeaponAmmoType(int iWeapon)
{
	if (!HasEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType"))return -1;
	return (GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType"));
}

int GetClientPrimaryAmmo(int iClient)
{
	int iPrimaryWeapon = GetClientWeaponInventory(iClient, 0);
	if (iPrimaryWeapon == -1)return -1;

	int iAmmoType = GetWeaponAmmoType(iPrimaryWeapon);
	if (iAmmoType == -1)return -1;

	return (GetEntProp(iClient, Prop_Send, "m_iAmmo", _, iAmmoType));
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
	if (IsFakeClient(victim) && GetGameTime() >= g_fSurvivorBot_VomitBlindedTime[victim])
		g_fSurvivorBot_VomitBlindedTime[victim] = GetGameTime() + g_fCvar_BotsVomitBlindTime;

	return Plugin_Continue;
}

public Action L4D2_OnHitByVomitJar(int victim, int &attacker)
{
	float fInterval = 180.0;
	if (IsSpecialInfected(victim))
		fInterval = (IsFakeClient(victim) ? g_fCvar_BileCoverDuration_Bot : g_fCvar_BileCoverDuration_PZ);

	g_fInfectedBot_CoveredInVomitTime[victim] = GetGameTime() + fInterval;
	return Plugin_Continue;
}

bool L4D_IsPlayerBoomerBiled(int iClient)
{
	return (GetGameTime() <= GetEntPropFloat(iClient, Prop_Send, "m_itTimer", 1));
}

bool L4D2_IsUnderAdrenalineEffect(int iClient)
{
	return (!!GetEntProp(iClient, Prop_Send, "m_bAdrenalineActive"));
}

#include "l4d2_sb_ai_improver/scavenging.inc"

#include "l4d2_sb_ai_improver/entity_registry.inc"

#include "l4d2_sb_ai_improver/weapon_data.inc"

bool IsCommonInfected(int iEntity)
{
	static char sEntClass[64]; GetEntityClassname(iEntity, sEntClass, sizeof(sEntClass));
	return (strcmp(sEntClass, "infected") == 0);
}

bool IsCommonInfectedAttacking(int iEntity)
{
	if (HasEntProp(iEntity, Prop_Send, "m_mobRush") && GetEntProp(iEntity, Prop_Send, "m_mobRush") != 0)
		return true;

	return (HasEntProp(iEntity, Prop_Send, "m_clientLookatTarget") && GetEntProp(iEntity, Prop_Send, "m_clientLookatTarget") != -1);
}

bool IsCommonInfectedAlive(int iEntity)
{
	return (GetEntProp(iEntity, Prop_Data, "m_lifeState") == 0 && GetEntProp(iEntity, Prop_Send, "m_bIsBurning") == 0);
}

bool IsCommonInfectedStumbled(int iEntity)
{
	if (!g_bExtensionActions)return false;
	return (ActionsManager.GetAction(iEntity, "InfectedShoved") != INVALID_ACTION);
}
