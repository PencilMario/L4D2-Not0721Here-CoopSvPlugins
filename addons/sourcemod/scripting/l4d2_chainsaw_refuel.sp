#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0.0"
#define MAX_ENTITY_LIMIT 2049
#define REFUEL_INTERVAL 1.0

ConVar g_hEnable;
ConVar g_hRefuelTime;

bool g_bEnable;
float g_fRefuelTime;
Handle g_hRefuelTimer = null;
float g_fFuelRemainder[MAX_ENTITY_LIMIT];
int g_iMaxFuel[MAX_ENTITY_LIMIT];

static const int CHAINSAW_MAX_FUEL_PROBE = 9999;

public Plugin myinfo =
{
	name = "[L4D2] Chainsaw Refuel",
	author = "Not0721Here",
	description = "Regenerates chainsaw fuel over time when enabled by weapon configs.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	g_hEnable = CreateConVar(
		"l4d2_chainsaw_refuel_enable",
		"0",
		"Enable chainsaw fuel regeneration. Intended for weapon config v2/v3.",
		FCVAR_NOTIFY,
		true,
		0.0,
		true,
		1.0
	);
	g_hRefuelTime = CreateConVar(
		"l4d2_chainsaw_refuel_time",
		"60.0",
		"Seconds needed to regenerate a chainsaw from empty to full.",
		FCVAR_NOTIFY,
		true,
		1.0
	);
	g_hEnable.AddChangeHook(CvarHook);
	g_hRefuelTime.AddChangeHook(CvarHook);

	RefreshCvars();
	UpdateRefuelTimer();
}

public void OnConfigsExecuted()
{
	RefreshCvars();
	UpdateRefuelTimer();
}

public void OnMapEnd()
{
	StopRefuelTimer();
	ClearFuelRemainders();
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < MAX_ENTITY_LIMIT) {
		g_fFuelRemainder[entity] = 0.0;
		g_iMaxFuel[entity] = 0;
	}
}

void CvarHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	RefreshCvars();
	UpdateRefuelTimer();
}

public Action Timer_RefuelChainsaws(Handle timer)
{
	if (!g_bEnable) {
		g_hRefuelTimer = null;
		return Plugin_Stop;
	}

	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "weapon_chainsaw")) != -1) {
		RefuelChainsaw(entity);
	}

	return Plugin_Continue;
}

void RefuelChainsaw(int entity)
{
	if (entity <= 0 || entity >= MAX_ENTITY_LIMIT || !IsValidEntity(entity)) {
		return;
	}

	int iFuel = GetEntProp(entity, Prop_Send, "m_iClip1");
	if (iFuel < 0) {
		iFuel = 0;
	}

	int iMaxFuel = GetChainsawMaxFuel(entity, iFuel);
	if (iMaxFuel <= 0) {
		return;
	}

	if (iFuel >= iMaxFuel) {
		g_fFuelRemainder[entity] = 0.0;
		if (iFuel > iMaxFuel) {
			SetEntProp(entity, Prop_Send, "m_iClip1", iMaxFuel);
		}
		return;
	}

	float fFuelPerTick = float(iMaxFuel) * REFUEL_INTERVAL / g_fRefuelTime;
	g_fFuelRemainder[entity] += fFuelPerTick;
	int iAddFuel = RoundToFloor(g_fFuelRemainder[entity]);
	if (iAddFuel <= 0) {
		return;
	}

	g_fFuelRemainder[entity] -= float(iAddFuel);
	iFuel += iAddFuel;
	if (iFuel > iMaxFuel) {
		iFuel = iMaxFuel;
		g_fFuelRemainder[entity] = 0.0;
	}

	SetEntProp(entity, Prop_Send, "m_iClip1", iFuel);
}

void RefreshCvars()
{
	g_bEnable = g_hEnable.BoolValue;
	g_fRefuelTime = g_hRefuelTime.FloatValue;
	if (g_fRefuelTime < REFUEL_INTERVAL) {
		g_fRefuelTime = REFUEL_INTERVAL;
	}
}

void UpdateRefuelTimer()
{
	if (g_bEnable) {
		StartRefuelTimer();
	} else {
		StopRefuelTimer();
		ClearFuelRemainders();
	}
}

void StartRefuelTimer()
{
	if (g_hRefuelTimer != null) {
		return;
	}

	g_hRefuelTimer = CreateTimer(REFUEL_INTERVAL, Timer_RefuelChainsaws, _, TIMER_REPEAT);
}

void StopRefuelTimer()
{
	if (g_hRefuelTimer == null) {
		return;
	}

	KillTimer(g_hRefuelTimer);
	g_hRefuelTimer = null;
}

void ClearFuelRemainders()
{
	for (int i = 0; i < MAX_ENTITY_LIMIT; i++) {
		g_fFuelRemainder[i] = 0.0;
		g_iMaxFuel[i] = 0;
	}
}

int GetChainsawMaxFuel(int entity, int iCurrentFuel)
{
	if (g_iMaxFuel[entity] > 0) {
		return g_iMaxFuel[entity];
	}

	SetEntProp(entity, Prop_Send, "m_iClip1", CHAINSAW_MAX_FUEL_PROBE);
	g_iMaxFuel[entity] = GetEntProp(entity, Prop_Send, "m_iClip1");
	SetEntProp(entity, Prop_Send, "m_iClip1", iCurrentFuel);

	return g_iMaxFuel[entity];
}
