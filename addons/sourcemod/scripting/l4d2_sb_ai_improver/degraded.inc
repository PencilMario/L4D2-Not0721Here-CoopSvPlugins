// Level 1: one-point LOS, no bone fallback, cached centroids.
// Level 2: origin-only aiming and capped Tank prop visibility candidates.
// Level 3: center-only nav visibility and no grenade ground Trace.

void CreateDegradedConVars()
{
	g_hCvar_DegradedForce = CreateConVar("ib_ai_degraded_force", "0", "AI degradation level: 0=auto, 1-3=force.", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_DegradedFrameStepMs = CreateConVar("ib_ai_degraded_frame_step_ms", "4.0", "Average frame-ms increase per automatic degradation level.", FCVAR_NOTIFY, true, 0.1);
	g_hCvar_DegradedForce.AddChangeHook(OnConVarChanged);
	g_hCvar_DegradedFrameStepMs.AddChangeHook(OnConVarChanged);
}

void UpdateDegradedConVarValues()
{
	g_iCvar_DegradedForce = g_hCvar_DegradedForce.IntValue;
	g_fCvar_DegradedFrameStepMs = g_hCvar_DegradedFrameStepMs.FloatValue;
	ResetDegradedLoadState();
}
