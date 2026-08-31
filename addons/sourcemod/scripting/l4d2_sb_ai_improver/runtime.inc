void UpdateClientNavArea(int iClient)
{
	static float fNow;
	fNow = GetGameTime();

	if (!g_iClientNavArea[iClient]
		|| fNow >= g_fClientNavAreaCache_Expiry[iClient]
		|| GetVectorDistance(g_fClientNavAreaCache_Position[iClient], g_fClientAbsOrigin[iClient], true) > 1024.0)
	{
		g_iClientNavArea[iClient] = L4D_GetLastKnownArea(iClient);
		g_fClientNavAreaCache_Position[iClient] = g_fClientAbsOrigin[iClient];
		g_fClientNavAreaCache_Expiry[iClient] = GetProcessCacheExpiry();
	}
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3])
{
	GetClientEyePosition(iClient, g_fClientEyePos[iClient]);
	g_fClientEyeAng[iClient] = fAngles;
	GetClientAbsOrigin(iClient, g_fClientAbsOrigin[iClient]);
	GetEntityCenteroid(iClient, g_fClientCenteroid[iClient]);
	UpdateClientNavArea(iClient);

	if (!IsClientSurvivor(iClient))
		return Plugin_Continue;

	g_bClient_IsFiringWeapon[iClient] = false;
	g_bClient_IsLookingAtPosition[iClient] = false;
	g_iClientInvFlags[iClient] = 0;

	static int iWpnSlot, iWpnSlots[6];

	// instead of comparing strings
	// we represent survivors’ inventory as bit flags
	for (int i = 0; i <= 5; i++)
	{
		iWpnSlot = GetPlayerWeaponSlot(iClient, i);
		if ( iWpnSlot > 0 && iWpnSlot <= MAXENTITIES && IsValidEdict(iWpnSlot) )
		{
			iWpnSlots[i] = iWpnSlot;
			g_iClientInvFlags[iClient] |= g_iItemFlags[iWpnSlot];

			if( g_iWeaponID[iWpnSlot] == 1 && (GetEntProp(iWpnSlot, Prop_Send, "m_isDualWielding") != 0 || GetEntProp(iWpnSlot, Prop_Send, "m_hasDualWeapons") != 0) )
				g_iClientInvFlags[iClient] |= FLAG_PISTOL_EXTRA;
		}
		else
			iWpnSlots[i] = -1;
	}
	g_iClientInventory[iClient] = iWpnSlots;

	if (iWpnSlots[0] != -1)
	{
		g_iWeapon_Clip1[iWpnSlots[0]] = GetWeaponClip1(iWpnSlots[0]);
		g_iWeapon_MaxAmmo[iWpnSlots[0]] = GetWeaponMaxAmmo(iWpnSlots[0]);
		g_iWeapon_AmmoLeft[iWpnSlots[0]] = GetClientPrimaryAmmo(iClient);
	}
	if (iWpnSlots[1] != -1)
	{
		g_iWeapon_Clip1[iWpnSlots[1]] = GetWeaponClip1(iWpnSlots[1]);
	}

	if (g_bCvar_BotsDisabled || g_bCutsceneIsPlaying || !g_iClientNavArea[iClient] || GetGameTime() <= g_fClient_ThinkFunctionDelay[iClient] || !IsFakeClient(iClient))
		return Plugin_Continue;

	SurvivorBotThink(iClient, iButtons, iWpnSlots);

	if (GetGameTime() > g_fBotProcessing_NextProcessTime && g_iBotProcessing_ProcessedCount >= GetTeamPlayerCount(2, true, true))
	{
		g_iBotProcessing_ProcessedCount = 0;
		g_fBotProcessing_NextProcessTime = GetProcessCacheExpiry();
		for (int i = 1; i <= MaxClients; i++)g_bBotProcessing_IsProcessed[i] = false;
	}

	return Plugin_Continue;
}

public void L4D_OnForceSurvivorPositions()
{
	g_bCutsceneIsPlaying = true;
}

public void L4D_OnReleaseSurvivorPositions()
{
	g_bCutsceneIsPlaying = false;
}

int GetClientWeaponInventory(int iClient, int iSlot)
{
	return (g_iClientInventory[iClient][iSlot]);
}

public void L4D_OnCThrowActivate_Post(int iAbility)
{
	int iOwner = GetEntityOwner(iAbility);
	if (IsValidClient(iOwner))g_bInfectedBot_IsThrowing[iOwner] = true;
}

public void L4D_TankRock_OnRelease_Post(int iTank, int iRock, const float fVecPos[3], const float fVecAng[3], const float fVecVel[3], const float fVecRot[3])
{
	if (IsValidClient(iTank))g_bInfectedBot_IsThrowing[iTank] = false;
}

public void L4D2_OnStagger_Post(int iTarget, int iSource)
{
	g_bInfectedBot_IsThrowing[iTarget] = false;
}

stock void VScript_DebugDrawLine(float fStartPos[3], float fEndPos[3], int iColorR = 255, int iColorG = 255, int iColorB = 255, bool bZTest = false, float fDrawTime = 1.0)
{
	static char sScriptCode[256]; FormatEx(sScriptCode, sizeof(sScriptCode), "DebugDrawLine(Vector(%f, %f, %f), Vector(%f, %f, %f), %i, %i, %i, %s, %f)",
		fStartPos[0], fStartPos[1], fStartPos[2], fEndPos[0], fEndPos[1], fEndPos[2], iColorR, iColorG, iColorB, (bZTest ? "true" : "false"), fDrawTime);
	L4D2_ExecVScriptCode(sScriptCode);
}

public Action L4D_PipeBombProjectile_Pre(int client, float vecPos[3], float vecAng[3], float vecVel[3], float vecRot[3])
{
	g_fSurvivorBot_Grenade_NextThrowTime = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
	return Plugin_Continue;
}

public Action L4D2_VomitJarProjectile_Pre(int client, float vecPos[3], float vecAng[3], float vecVel[3], float vecRot[3])
{
	g_fSurvivorBot_Grenade_NextThrowTime = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
	return Plugin_Continue;
}

public Action L4D_MolotovProjectile_Pre(int client, float vecPos[3], float vecAng[3], float vecVel[3], float vecRot[3])
{
	g_fSurvivorBot_Grenade_NextThrowTime_Molotov = GetGameTime() + GetRandomFloat(g_fCvar_GrenadeThrow_NextThrowTime1, g_fCvar_GrenadeThrow_NextThrowTime2);
	return Plugin_Continue;
}
