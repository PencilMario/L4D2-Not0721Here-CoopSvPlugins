// Level 1: one-point LOS, no bone fallback, cached centroids.
// Level 2: origin-only aiming and capped Tank prop visibility candidates.
// Level 3: center-only nav visibility and no grenade ground Trace.

void CreateDegradedConVars()
{
	g_hCvar_DegradedForce = CreateConVar("ib_ai_degraded_force", "0", "AI degradation level: 0=auto, 1-3=force.", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_DegradedFrameStepMs = CreateConVar("ib_ai_degraded_frame_step_ms", "4.0", "Average frame-ms increase per automatic degradation level.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_DegradedForce.AddChangeHook(OnConVarChanged);
	g_hCvar_DegradedFrameStepMs.AddChangeHook(OnConVarChanged);
}

void UpdateDegradedConVarValues()
{
	int iForce = g_hCvar_DegradedForce.IntValue;
	float fStep = g_hCvar_DegradedFrameStepMs.FloatValue;
	if (iForce == g_iCvar_DegradedForce && fStep == g_fCvar_DegradedFrameStepMs)
		return;

	g_iCvar_DegradedForce = iForce;
	g_fCvar_DegradedFrameStepMs = fStep;
	ResetDegradedLoadState();
}

void ResetProcessCaches()
{
	ResetAiEntityCenteroidCache();
	ResetVisibilityCaches();
	ResetNavigationCaches();
	ResetVectorTraceCache();
	for (int i = 1; i <= MaxClients; i++)
		g_fClientGlobalInfo_Expiry[i] = 0.0;
}
