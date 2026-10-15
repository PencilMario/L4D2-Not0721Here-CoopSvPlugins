public Action L4D2_OnChooseVictim(int iInfected, int &iTarget)
{
	g_iInfectedBot_CurrentVictim[iInfected] = iTarget;
	return Plugin_Continue;
}

public void OnActionCreated(BehaviorAction hAction, int iActor, const char[] sName)
{
	if (strcmp(sName[8], "LegsRegroup") == 0)
	{
		hAction.OnUpdatePost = OnRegroupWithTeamAction;
	}
	else if (strcmp(sName[8], "LiberateBesiegedFriend") == 0)
	{
		hAction.OnUpdatePost = OnMoveToIncapacitatedFriendAction;
	}
}

Action OnRegroupWithTeamAction(BehaviorAction hAction, int iActor, float fInterval, ActionResult hResult)
{
	int iLeader = (hAction.Get(0x34) & 0xFFF);
	if (!IsValidClient(iLeader))return Plugin_Continue;

	int iPathDangerous = LBI_IsPathToPositionDangerous(iActor, g_fClientAbsOrigin[iLeader]);
	if (iPathDangerous == -1)return Plugin_Continue;

	if (iPathDangerous != 0)
	{
		BehaviorAction hRetreatAction = CreateSurvivorLegsRetreatAction(iPathDangerous);
		if (hRetreatAction != INVALID_ACTION)
		{
			hResult.type = CHANGE_TO;
			hResult.action = hRetreatAction;
			return Plugin_Changed;
		}

		return Plugin_Continue;
	}

	hResult.type = DONE;
	return Plugin_Changed;
}

Action OnMoveToIncapacitatedFriendAction(BehaviorAction hAction, int iActor, float fInterval, ActionResult hResult)
{
	PerformanceBudgetBeginStage("rescue");
	int iFriend = (hAction.Get(0x34) & 0xFFF);
	if (!IsValidClient(iFriend) || L4D_GetPlayerReviveTarget(iActor) == iFriend || GetClientDistance(iActor, iFriend, true) <= 15625.0 && IsVisibleEntity(iActor, iFriend))
	{
		PerformanceBudgetEndStage(iActor);
		return Plugin_Continue;
	}

	int iPathDangerous = LBI_IsPathToPositionDangerous(iActor, g_fClientAbsOrigin[iFriend]);
	if (iPathDangerous == -1)
	{
		PerformanceBudgetEndStage(iActor);
		return Plugin_Continue;
	}

	if (iPathDangerous != 0)
	{
		BehaviorAction hRetreatAction = CreateSurvivorLegsRetreatAction(iPathDangerous);
		if (hRetreatAction != INVALID_ACTION)
		{
			hResult.type = CHANGE_TO;
			hResult.action = hRetreatAction;
			PerformanceBudgetEndStage(iActor);
			return Plugin_Changed;
		}

		PerformanceBudgetEndStage(iActor);
		return Plugin_Continue;
	}

	hResult.type = DONE;
	PerformanceBudgetEndStage(iActor);
	return Plugin_Changed;
}

BehaviorAction CreateSurvivorLegsRetreatAction(int iThreat)
{
	BehaviorAction hAction = ActionsManager.Allocate(0x745A);
	if (hAction == INVALID_ACTION)
	{
		return INVALID_ACTION;
	}

	SDKCall(g_hSurvivorLegsRetreat, hAction, iThreat);
	return hAction;
}
