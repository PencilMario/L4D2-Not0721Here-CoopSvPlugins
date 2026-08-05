bool TakeCoverFromPosition(int iClient, float fPosition[3], float fSearchDist = 384.0)
{
	float fSelfToPos[3]; MakeVectorFromPoints(g_fClientEyePos[iClient], fPosition, fSelfToPos);
	NormalizeVector(fSelfToPos, fSelfToPos);

	float fDot, fPathPos[3], fPathOffset[3], fSelfToMovePos[3];
	for (int i = 0; i < 10; i++)
	{
		VScript_TryGetPathableLocationWithin(iClient, fSearchDist, fPathPos);
		if (!IsValidVector(fPathPos) || LBI_IsDamagingPosition(fPathPos))continue;

		fPathOffset = fPathPos; fPathOffset[2] + HUMAN_HALF_HEIGHT;

		MakeVectorFromPoints(g_fClientEyePos[iClient], fPathPos, fSelfToMovePos);
		NormalizeVector(fSelfToMovePos, fSelfToMovePos);

		fDot = GetVectorDotProduct(fSelfToPos, fSelfToMovePos);
		if (fDot > 0.2 || GetVectorVisible(fPosition, fPathOffset))continue;

		SetMoveToPosition(iClient, fPathPos, 3, "TakeCover");
		return true;
	}

	return false;
}

bool TakeCoverFromEntity(int iClient, int iEntity, float fSearchDist = 384.0)
{
	float fEntityPos[3];
	if (IsValidClient(iEntity))GetClientEyePosition(iEntity, fEntityPos);
	else GetEntityCenteroid(iEntity, fEntityPos);
	return (TakeCoverFromPosition(iClient, fEntityPos, fSearchDist));
}

void StopTankRetreat(int iClient)
{
	g_bSurvivorBot_TankRetreatActive[iClient] = false;
	L4D2_CommandABot(iClient, 0, BOT_CMD_RESET);

	// RESET also cancels a MOVE command that RETREAT may have overridden.
	// Restore the plugin-owned move immediately when one is still active.
	if (IsValidVector(g_fSurvivorBot_MovePos_Position[iClient]) && GetGameTime() <= g_fSurvivorBot_MovePos_Duration[iClient])
	{
		L4D2_CommandABot(iClient, 0, BOT_CMD_MOVE, g_fSurvivorBot_MovePos_Position[iClient]);
		g_fSurvivorBot_NextMoveCommandTime[iClient] = GetGameTime() + BOT_CMD_MOVE_INTERVAL;
	}
}

void ClearMoveToPosition(int iClient, const char[] sCheckName = "")
{
	if (g_iCvar_Debug & DEBUG_MOVE && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
	{
		static int iAbort;
		static char sBuffer[128], sClientName[128];

		iAbort = view_as<int>(sCheckName[0] != 0 && strcmp(g_sSurvivorBot_MovePos_Name[iClient], sCheckName) != 0)
			| view_as<int>(!IsValidVector(g_fSurvivorBot_MovePos_Position[iClient])) << 1
			| view_as<int>(LBI_IsDamagingNavArea(g_iClientNavArea[iClient])) << 2;

		sBuffer[0] = EOS;
		sClientName[0] = EOS;
		GetClientName(iClient, sClientName, sizeof(sClientName));

		Format(sBuffer, sizeof(sBuffer), "ClearMoveToPosition %d %s type %s%s%s%s%s", iClient, sClientName,
			(sCheckName[0] != 0 ? sCheckName : "not specified"), (iAbort != 0 ? ", aborted " : ""),
			(iAbort & 1 ? "(different move cmd)" : ""),(iAbort & 2 ? "(invalid pos)" : ""),(iAbort & 4 ? "(damaging nav)" : ""));
		PrintToServer(sBuffer);

		if (iAbort != 0)
			return;
	}
	else if ( sCheckName[0] != 0 && strcmp(g_sSurvivorBot_MovePos_Name[iClient], sCheckName) != 0
			|| !IsValidVector(g_fSurvivorBot_MovePos_Position[iClient])
			|| LBI_IsDamagingNavArea(g_iClientNavArea[iClient]) )
		return;

	g_iSurvivorBot_MovePos_Priority[iClient] = -1;
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime();
	g_fSurvivorBot_MovePos_Tolerance[iClient] = -1.0;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = false;
	g_sSurvivorBot_MovePos_Name[iClient][0] = 0;

	SetVectorToZero(g_fSurvivorBot_MovePos_Position[iClient]);
	L4D2_CommandABot(iClient, 0, BOT_CMD_RESET);
}

void SetMoveToPosition(int iClient, float fMovePos[3], int iPriority, const char[] sName = "", float fAddDuration = 0.66, float fDistTolerance = -1.0, bool bIgnoreDamaging = false, bool bIgnoreCheckpoints = false)
{
	static int iAbort;
	static float fNavDist, fTravelDist, fMaxSpeed, fMoveTime;
	static char sBuffer[320], sClientName[128];

	if (g_iCvar_Debug & DEBUG_MOVE && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
	{
		iAbort = view_as<int>(iPriority < g_iSurvivorBot_MovePos_Priority[iClient])
			| view_as<int>(IsValidVector(g_fSurvivorBot_MovePos_Position[iClient])) << 1
			| view_as<int>(fDistTolerance >= 0.0 && GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true) <= (fDistTolerance*fDistTolerance)) << 2
			| view_as<int>(!bIgnoreDamaging && (LBI_IsDamagingNavArea(g_iClientNavArea[iClient]) || LBI_IsDamagingPosition(fMovePos))) << 3
			| view_as<int>(!bIgnoreCheckpoints && LBI_IsPositionInsideCheckpoint(g_fClientAbsOrigin[iClient]) && !LBI_IsPositionInsideCheckpoint(fMovePos)) << 4;

		sBuffer[0] = EOS;
		sClientName[0] = EOS;
	}
	else if ( iPriority < g_iSurvivorBot_MovePos_Priority[iClient] || IsValidVector(g_fSurvivorBot_MovePos_Position[iClient])
			|| fDistTolerance >= 0.0 && GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos, true) <= (fDistTolerance*fDistTolerance)
			|| !bIgnoreDamaging && (LBI_IsDamagingNavArea(g_iClientNavArea[iClient]) || LBI_IsDamagingPosition(fMovePos))
			|| !bIgnoreCheckpoints && LBI_IsPositionInsideCheckpoint(g_fClientAbsOrigin[iClient]) && !LBI_IsPositionInsideCheckpoint(fMovePos) )
		return;

	//float fTravelDist = GetClientTravelDistance(iClient, fMovePos, true);
	fNavDist = GetNavDistance(g_fClientAbsOrigin[iClient], fMovePos, _, false);
	fTravelDist = fNavDist <= 0.0 ? GetVectorDistance(g_fClientAbsOrigin[iClient], fMovePos) : fNavDist;
	fMaxSpeed = GetClientMaxSpeed(iClient);
	fMoveTime = fTravelDist / fMaxSpeed + fAddDuration;

	if (g_iCvar_Debug & DEBUG_MOVE && ( g_iCvar_DebugClient == 0 || iClient == g_iCvar_DebugClient ))
	{
		GetClientName(iClient, sClientName, sizeof(sClientName));

		Format(sBuffer, sizeof(sBuffer), "SetMoveToPosition %d %s %d %s fAddDur %.2f fDistTol %.2f%s%s\
			\nfNavDist %.2f fTravelDist %.2f fMaxSpeed %.2f fMoveTime %.2f iAbort %d\n%s%s%s%s%s",
			iClient, sClientName, iPriority, sName, fAddDuration, fDistTolerance,
			(bIgnoreDamaging ? "(ignore damaging)" : ""), (bIgnoreCheckpoints ? "(ignore checkpoint)" : ""),
			fNavDist, fTravelDist, fMaxSpeed, fMoveTime, iAbort,
			(iAbort & 1 ? "(lower priority)" : ""),(iAbort & 2 ? "(valid pos)" : ""),(iAbort & 4 ? "(close enough)" : ""),
			(iAbort & 8 ? "(damaging position)" : ""),(iAbort & 16 ? "(outside of checkpoint)" : ""));
		PrintToServer(sBuffer);

		if (iAbort != 0)
			return;
	}

	strcopy(g_sSurvivorBot_MovePos_Name[iClient], 64, sName);
	//g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime() + (fTravelDist / (fMaxSpeed*fMaxSpeed)) + fAddDuration;
	g_fSurvivorBot_MovePos_Duration[iClient] = GetGameTime() + fMoveTime;
	g_fSurvivorBot_MovePos_Position[iClient] = fMovePos;
	g_iSurvivorBot_MovePos_Priority[iClient] = iPriority;
	g_fSurvivorBot_MovePos_Tolerance[iClient] = fDistTolerance;
	g_bSurvivorBot_MovePos_IgnoreDamaging[iClient] = bIgnoreDamaging;
}

void InitPathWithin()
{
	/*
	::IBPathWithin <- function (iClient, fRadius)
	{
		local ply = GetPlayerFromUserID(iClient);
		return ply.TryGetPathableLocationWithin(fRadius)
	}
	*/

	HSCRIPT script = VScript_CompileScript("::IBPathWithin <- function (iClient, fRadius) { local player = GetPlayerFromUserID(iClient); if (player == null) return Vector(0, 0, 0); local location = player.TryGetPathableLocationWithin(fRadius); return location == null ? Vector(0, 0, 0) : location }");
	VScriptExecute execute = new VScriptExecute(script);
	ScriptStatus_t valid = execute.Execute();
	delete execute;
	script.ReleaseScript();
	PrintToServer("InitPathWithin: execute status %d, status_done: %b", valid, (valid == SCRIPT_DONE));

	g_vsPathWithin = new VScriptExecute(HSCRIPT_RootTable.GetValue("IBPathWithin"));

	g_bInitPathWithin = true;
}

void VScript_TryGetPathableLocationWithin(int iClient, float fRadius, float fBuffer[3])
{
	static int iUserID;

	if(!g_bInitPathWithin)
		InitPathWithin();

	iUserID = GetClientUserId(iClient);
	g_vsPathWithin.SetParam(1, FIELD_INTEGER, iUserID);
	g_vsPathWithin.SetParam(2, FIELD_FLOAT, fRadius);
	g_vsPathWithin.Execute();
	g_vsPathWithin.GetReturnVector(fBuffer);
}
