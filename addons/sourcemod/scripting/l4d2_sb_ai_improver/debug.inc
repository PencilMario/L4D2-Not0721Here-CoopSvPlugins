void LogSlowCalculation(const char[] sName, float fStartedAt, int iClient = -1, int iEntity = -1)
{
	if (!g_bCvar_PerformanceLogging)
		return;

	float fElapsed = GetEngineTime() - fStartedAt;
	if (fElapsed < g_fCvar_PerformanceThresholdMs / 1000.0)
		return;

	if (g_hPerformanceLogger != null)
		g_hPerformanceLogger.lograw("[SlowCalculation] name=%s elapsed_ms=%.3f client=%d entity=%d", sName, fElapsed * 1000.0, iClient, iEntity);
}

void LogDebugMessage(const char[] sMessage, any ...)
{
	char sBuffer[512];
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 2);
	PrintToServer("%s", sBuffer);

	if (g_hPerformanceLogger != null)
		g_hPerformanceLogger.lograw("[Debug] %s", sBuffer);
}

Action CmdDumpCvars(int client, int args)
{
	static char sBuffer[64];

	GetConVarString(g_hCvar_AutoShove_Enabled, sBuffer, 64);
	PrintToServer("g_hCvar_AutoShove_Enabled %s", sBuffer);
	PrintToServer("g_iCvar_AutoShove_Enabled %d", g_iCvar_AutoShove_Enabled);

	GetConVarString(g_hCvar_ImprovedMelee_Enabled, sBuffer, 64);
	PrintToServer("g_hCvar_ImprovedMelee_Enabled %s", sBuffer);
	PrintToServer("g_bCvar_ImprovedMelee_Enabled %b", g_bCvar_ImprovedMelee_Enabled);

	GetConVarString(g_hCvar_TargetSelection_Enabled, sBuffer, 64);
	PrintToServer("g_hCvar_TargetSelection_Enabled %s", sBuffer);
	PrintToServer("g_bCvar_TargetSelection_Enabled %b", g_bCvar_TargetSelection_Enabled);

	GetConVarString(g_hCvar_ItemScavenge_Items, sBuffer, 64);
	PrintToServer("g_hCvar_ItemScavenge_Items %s", sBuffer);
	PrintToServer("g_iCvar_ItemScavenge_Items %d", g_iCvar_ItemScavenge_Items);
	return Plugin_Handled;
}
