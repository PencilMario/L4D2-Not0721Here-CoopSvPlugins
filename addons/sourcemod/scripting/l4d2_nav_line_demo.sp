#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define _NATIVE_ONLY
#include <l4d_path_to_goal>

#define PLUGIN_VERSION "0.2.0"

public Plugin myinfo =
{
	name = "[L4D2] Periodic Path To Goal",
	author = "sp, OpenAI",
	description = "Periodically draws the Path To Goal route for all human clients.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=352685"
};

ConVar g_cvEnabled;
ConVar g_cvDrawInterval;
ConVar g_cvBeamDuration;
Handle g_hGuideTimer;

public void OnPluginStart()
{
	g_cvEnabled = CreateConVar("l4d2_navline_enabled", "0", "Enable periodic Path To Goal rendering.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvDrawInterval = CreateConVar("l4d2_navline_draw_interval", "5.0", "Seconds between Path To Goal draws.", FCVAR_NOTIFY, true, 1.0, true, 30.0);
	g_cvBeamDuration = CreateConVar("l4d2_navline_duration", "5.0", "Path To Goal beam lifetime in seconds.", FCVAR_NOTIFY, true, 0.1, true, 30.0);

	g_cvEnabled.AddChangeHook(CvarHook_GuideSettings);
	g_cvDrawInterval.AddChangeHook(CvarHook_GuideSettings);
}

public void OnConfigsExecuted()
{
	RefreshGuideTimer(true);
}

public void OnMapStart()
{
	RefreshGuideTimer(false);
}

public void OnMapEnd()
{
	StopGuideTimer();
}

public void CvarHook_GuideSettings(ConVar convar, const char[] oldValue, const char[] newValue)
{
	RefreshGuideTimer(true);
}

void RefreshGuideTimer(bool drawImmediately)
{
	StopGuideTimer();

	if (!g_cvEnabled.BoolValue)
	{
		return;
	}

	if (drawImmediately)
	{
		DrawGuideForAllClients();
	}

	g_hGuideTimer = CreateTimer(g_cvDrawInterval.FloatValue, Timer_PeriodicGuide, _, TIMER_REPEAT);
}

void StopGuideTimer()
{
	if (g_hGuideTimer != null)
	{
		delete g_hGuideTimer;
		g_hGuideTimer = null;
	}
}

public Action Timer_PeriodicGuide(Handle timer)
{
	if (!g_cvEnabled.BoolValue)
	{
		g_hGuideTimer = null;
		return Plugin_Stop;
	}

	DrawGuideForAllClients();
	return Plugin_Continue;
}

void DrawGuideForAllClients()
{
	float duration = g_cvBeamDuration.FloatValue;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			L4D_Path_To_Goal(client, duration);
		}
	}
}
