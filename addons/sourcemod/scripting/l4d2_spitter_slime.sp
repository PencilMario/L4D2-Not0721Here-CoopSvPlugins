#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"
#define ZOMBIECLASS_SPITTER 4
#define MAX_SLIMES 32
#define MAX_TRACKED_ENTITIES 2048
#define SLIME_UPDATE_INTERVAL 0.05
#define ARC_TWO_PI 6.28318530718

#define MODEL_GAS_CAN "models/props_junk/gascan001a.mdl"
#define PARTICLE_GAS_BLAST "gas_explosion_initialburst_blast"
#define PARTICLE_GAS_FIRE "weapon_pipebomb_child_fire"
#define SOUND_EXPLODE_1 "weapons/hegrenade/explode3.wav"
#define SOUND_EXPLODE_2 "weapons/hegrenade/explode5.wav"

enum struct SlimeState
{
	int entRef;
	int target;
	bool tracking;
	float targetOffset[3];
	float arcStart[3];
	float arcEnd[3];
	float arcStartedAt;
	float arcDuration;
	float lastPos[3];
}

ConVar g_hSlimeEnable;
ConVar g_hSlimeInterval;
ConVar g_hSlimeMax;
ConVar g_hSlimeRadius;
ConVar g_hSlimeReturnDistance;
ConVar g_hSlimeTargetRange;
ConVar g_hSlimeSpeed;
ConVar g_hSlimeArcHeight;
ConVar g_hSlimeDamage;
ConVar g_hSlimeHitRadius;

ConVar g_hGasEnable;
ConVar g_hGasCooldown;
ConVar g_hGasSpeed;
ConVar g_hGasArcHeight;
ConVar g_hGasDamage;
ConVar g_hGasRadius;
ConVar g_hGasKnockback;
ConVar g_hGasKnockup;
ConVar g_hGasHurtSurvivors;
ConVar g_hGasHurtInfected;

SlimeState g_Slimes[MAXPLAYERS + 1][MAX_SLIMES];
int g_SlimeCount[MAXPLAYERS + 1];
Handle g_SlimeTimers[MAXPLAYERS + 1];
int g_GasRefs[MAXPLAYERS + 1];
int g_GasOwner[MAX_TRACKED_ENTITIES];
bool g_GasExploded[MAX_TRACKED_ENTITIES];
float g_GasIgnoreUntil[MAX_TRACKED_ENTITIES];
Handle g_UpdateTimer;

public Plugin myinfo =
{
	name = "[L4D2] Spitter Slime",
	author = "Not0721Here",
	description = "Replaces the versus_isfullshit Spitter enhancement with controlled slime and gas-can attacks.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_Left4Dead2)
	{
		SetFailState("This plugin requires Left 4 Dead 2.");
	}

	if (!LibraryExists("left4dhooks"))
	{
		SetFailState("This plugin requires left4dhooks.smx.");
	}

	CreateConVars();
	InitializeState();
	PrecacheAssets();

	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundCleanup, EventHookMode_PostNoCopy);
	HookEvent("mission_lost", Event_RoundCleanup, EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundCleanup, EventHookMode_PostNoCopy);

	HookConVarChange(g_hSlimeEnable, OnSlimeEnableChanged);
	HookConVarChange(g_hSlimeInterval, OnSlimeIntervalChanged);
	StartUpdateTimer();
	CreateTimer(0.1, Timer_StartupScan, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapStart()
{
	PrecacheAssets();
	StartUpdateTimer();
}

public void OnMapEnd()
{
	CleanupAllSpitters();
	StopUpdateTimer();
}

public void OnPluginEnd()
{
	CleanupAllSpitters();
	StopUpdateTimer();
}

public void OnClientDisconnect(int client)
{
	CleanupSpitter(client);
}

void CreateConVars()
{
	CreateConVar("l4d2_spitter_slime_version", PLUGIN_VERSION, "Spitter slime plugin version.", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);

	g_hSlimeEnable = CreateConVar("l4d2_spitter_slime_enable", "1", "Enable controlled visible slime projectiles.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSlimeInterval = CreateConVar("l4d2_spitter_slime_interval", "0.3", "Seconds between slime creations for each Spitter.", FCVAR_NOTIFY, true, 0.05, true, 60.0);
	g_hSlimeMax = CreateConVar("l4d2_spitter_slime_max", "5", "Maximum number of slimes owned by each Spitter.", FCVAR_NOTIFY, true, 0.0, true, float(MAX_SLIMES));
	g_hSlimeRadius = CreateConVar("l4d2_spitter_slime_radius", "180.0", "Maximum random local radius for an idle slime.", FCVAR_NOTIFY, true, 0.0, true, 2000.0);
	g_hSlimeReturnDistance = CreateConVar("l4d2_spitter_slime_return_distance", "600.0", "Distance at which a slime returns to its Spitter.", FCVAR_NOTIFY, true, 1.0, true, 5000.0);
	g_hSlimeTargetRange = CreateConVar("l4d2_spitter_slime_target_range", "300.0", "Visible survivor search range around a Spitter.", FCVAR_NOTIFY, true, 0.0, true, 5000.0);
	g_hSlimeSpeed = CreateConVar("l4d2_spitter_slime_speed", "450.0", "Slime movement speed.", FCVAR_NOTIFY, true, 1.0, true, 5000.0);
	g_hSlimeArcHeight = CreateConVar("l4d2_spitter_slime_arc_height", "80.0", "Idle and tracking slime parabolic height.", FCVAR_NOTIFY, true, 0.0, true, 2000.0);
	g_hSlimeDamage = CreateConVar("l4d2_spitter_slime_damage", "10.0", "SDKDamage dealt when a slime reaches a survivor.", FCVAR_NOTIFY, true, 0.0, true, 10000.0);
	g_hSlimeHitRadius = CreateConVar("l4d2_spitter_slime_hit_radius", "32.0", "Slime survivor hit radius.", FCVAR_NOTIFY, true, 1.0, true, 256.0);

	g_hGasEnable = CreateConVar("l4d2_spitter_gas_enable", "1", "Replace the Spitter IN_ATTACK ability with a gas can.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGasCooldown = CreateConVar("l4d2_spitter_gas_cooldown", "5.0", "Gas-can ability cooldown in seconds.", FCVAR_NOTIFY, true, 0.0, true, 60.0);
	g_hGasSpeed = CreateConVar("l4d2_spitter_gas_speed", "700.0", "Initial gas-can forward speed.", FCVAR_NOTIFY, true, 1.0, true, 5000.0);
	g_hGasArcHeight = CreateConVar("l4d2_spitter_gas_arc_height", "140.0", "Initial gas-can upward impulse for its parabola.", FCVAR_NOTIFY, true, 0.0, true, 2000.0);
	g_hGasDamage = CreateConVar("l4d2_spitter_gas_damage", "50.0", "SDKDamage dealt by a gas-can blast.", FCVAR_NOTIFY, true, 0.0, true, 10000.0);
	g_hGasRadius = CreateConVar("l4d2_spitter_gas_radius", "250.0", "Gas-can blast damage and knockback radius.", FCVAR_NOTIFY, true, 0.0, true, 3000.0);
	g_hGasKnockback = CreateConVar("l4d2_spitter_gas_knockback", "300.0", "Horizontal direct velocity from a gas-can blast.", FCVAR_NOTIFY, true, 0.0, true, 3000.0);
	g_hGasKnockup = CreateConVar("l4d2_spitter_gas_knockup", "100.0", "Vertical direct velocity from a gas-can blast.", FCVAR_NOTIFY, true, 0.0, true, 3000.0);
	g_hGasHurtSurvivors = CreateConVar("l4d2_spitter_gas_hurt_survivors", "1", "Allow gas-can blasts to damage survivors.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGasHurtInfected = CreateConVar("l4d2_spitter_gas_hurt_infected", "0", "Allow gas-can blasts to damage infected players.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

void InitializeState()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		g_SlimeTimers[client] = null;
		g_SlimeCount[client] = 0;
		g_GasRefs[client] = INVALID_ENT_REFERENCE;
		for (int slot = 0; slot < MAX_SLIMES; slot++)
		{
			ResetSlimeState(client, slot);
		}
	}

	for (int entity = 0; entity < MAX_TRACKED_ENTITIES; entity++)
	{
		g_GasOwner[entity] = 0;
		g_GasExploded[entity] = false;
		g_GasIgnoreUntil[entity] = 0.0;
	}
}

void PrecacheAssets()
{
	PrecacheModel(MODEL_GAS_CAN, true);
	PrecacheSound(SOUND_EXPLODE_1, true);
	PrecacheSound(SOUND_EXPLODE_2, true);
	L4D_PrecacheParticle(PARTICLE_GAS_BLAST);
	L4D_PrecacheParticle(PARTICLE_GAS_FIRE);
}

void ResetSlimeState(int client, int slot)
{
	g_Slimes[client][slot].entRef = INVALID_ENT_REFERENCE;
	g_Slimes[client][slot].target = 0;
	g_Slimes[client][slot].tracking = false;
	g_Slimes[client][slot].targetOffset[0] = 0.0;
	g_Slimes[client][slot].targetOffset[1] = 0.0;
	g_Slimes[client][slot].targetOffset[2] = 0.0;
	g_Slimes[client][slot].arcStart[0] = 0.0;
	g_Slimes[client][slot].arcStart[1] = 0.0;
	g_Slimes[client][slot].arcStart[2] = 0.0;
	g_Slimes[client][slot].arcEnd[0] = 0.0;
	g_Slimes[client][slot].arcEnd[1] = 0.0;
	g_Slimes[client][slot].arcEnd[2] = 0.0;
	g_Slimes[client][slot].arcStartedAt = 0.0;
	g_Slimes[client][slot].arcDuration = 0.0;
	g_Slimes[client][slot].lastPos[0] = 0.0;
	g_Slimes[client][slot].lastPos[1] = 0.0;
	g_Slimes[client][slot].lastPos[2] = 0.0;
}

void StopUpdateTimer()
{
	if (g_UpdateTimer != null)
	{
		KillTimer(g_UpdateTimer);
		g_UpdateTimer = null;
	}
}

void StartUpdateTimer()
{
	StopUpdateTimer();
	g_UpdateTimer = CreateTimer(SLIME_UPDATE_INTERVAL, Timer_UpdateSlimes, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void CleanupAllSpitters()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		CleanupSpitter(client);
	}
}

void CleanupSpitter(int client)
{
	if (client < 1 || client > MaxClients)
	{
		return;
	}

	if (g_SlimeTimers[client] != null)
	{
		KillTimer(g_SlimeTimers[client]);
		g_SlimeTimers[client] = null;
	}

	for (int slot = 0; slot < MAX_SLIMES; slot++)
	{
		DestroySlimeSlot(client, slot);
	}
	g_SlimeCount[client] = 0;

	int gas = EntRefToEntIndex(g_GasRefs[client]);
	if (gas != INVALID_ENT_REFERENCE && IsValidEntity(gas))
	{
		if (gas < MAX_TRACKED_ENTITIES)
		{
			g_GasExploded[gas] = true;
			g_GasOwner[gas] = 0;
		}
		RemoveEntity(gas);
	}
	g_GasRefs[client] = INVALID_ENT_REFERENCE;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidSpitter(client))
	{
		CleanupSpitter(client);
		StartSpitter(client);
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	CleanupSpitter(GetClientOfUserId(event.GetInt("userid")));
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int oldTeam = event.GetInt("oldteam");
	int newTeam = event.GetInt("team");

	if (oldTeam == 3 || newTeam != 3)
	{
		CleanupSpitter(client);
	}
	if (newTeam == 3 && IsValidSpitter(client))
	{
		StartSpitter(client);
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(0.1, Timer_StartupScan, _, TIMER_FLAG_NO_MAPCHANGE);
}

void Event_RoundCleanup(Event event, const char[] name, bool dontBroadcast)
{
	CleanupAllSpitters();
}

public Action Timer_StartupScan(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidSpitter(client))
		{
			StartSpitter(client);
		}
	}
	return Plugin_Stop;
}

void OnSlimeIntervalChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsValidSpitter(client))
		{
			continue;
		}
		if (g_SlimeTimers[client] != null)
		{
			KillTimer(g_SlimeTimers[client]);
			g_SlimeTimers[client] = null;
		}
		StartSpitter(client);
	}
}

void OnSlimeEnableChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!g_hSlimeEnable.BoolValue)
		{
			if (g_SlimeTimers[client] != null)
			{
				KillTimer(g_SlimeTimers[client]);
				g_SlimeTimers[client] = null;
			}
			ClearSlimes(client);
			continue;
		}

		if (IsValidSpitter(client))
		{
			StartSpitter(client);
		}
	}
}

bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

bool IsValidSpitter(int client)
{
	return IsValidClient(client)
		&& IsPlayerAlive(client)
		&& GetClientTeam(client) == 3
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_SPITTER
		&& GetEntProp(client, Prop_Send, "m_isGhost") == 0;
}

bool IsValidSurvivor(int client)
{
	return IsValidClient(client)
		&& IsPlayerAlive(client)
		&& GetClientTeam(client) == 2;
}

void StartSpitter(int client)
{
	if (!IsValidSpitter(client) || !g_hSlimeEnable.BoolValue)
	{
		return;
	}
	if (g_SlimeTimers[client] != null)
	{
		return;
	}

	g_SlimeTimers[client] = CreateTimer(
		g_hSlimeInterval.FloatValue,
		Timer_SpawnSlime,
		GetClientUserId(client),
		TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_SpawnSlime(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidSpitter(client))
	{
		if (client > 0 && client <= MaxClients)
		{
			g_SlimeTimers[client] = null;
			CleanupSpitter(client);
		}
		return Plugin_Stop;
	}

	if (g_hSlimeEnable.BoolValue)
	{
		CreateSlime(client);
	}
	return Plugin_Continue;
}

void CreateSlime(int client)
{
	int maximum = g_hSlimeMax.IntValue;
	if (!g_hSlimeEnable.BoolValue || maximum <= 0)
	{
		return;
	}
	if (maximum > MAX_SLIMES)
	{
		maximum = MAX_SLIMES;
	}

	CleanupInvalidSlimes(client);
	TrimSlimes(client, maximum);
	if (g_SlimeCount[client] >= maximum)
	{
		return;
	}

	int slot = FindFreeSlimeSlot(client);
	if (slot == -1)
	{
		return;
	}

	float position[3];
	float angles[3];
	float zero[3] = { 0.0, 0.0, 0.0 };
	GetClientAbsOrigin(client, position);
	position[2] += 36.0;
	GetClientEyeAngles(client, angles);

	int entity = L4D2_SpitterPrj(client, position, angles, zero, zero);
	if (entity <= MaxClients || !IsValidEntity(entity))
	{
		LogError("L4D2_SpitterPrj failed for Spitter %N.", client);
		return;
	}

	if (HasEntProp(entity, Prop_Send, "m_hThrower"))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
	}
	if (HasEntProp(entity, Prop_Send, "m_DmgRadius"))
	{
		SetEntPropFloat(entity, Prop_Send, "m_DmgRadius", 0.0);
	}
	if (HasEntProp(entity, Prop_Send, "m_bIsLive"))
	{
		SetEntProp(entity, Prop_Send, "m_bIsLive", 1);
	}
	if (HasEntProp(entity, Prop_Send, "m_CollisionGroup"))
	{
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
	}
	if (HasEntProp(entity, Prop_Send, "m_nSolidType"))
	{
		SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
	}
	SetEntityMoveType(entity, MOVETYPE_NONE);

	g_Slimes[client][slot].entRef = EntIndexToEntRef(entity);
	g_Slimes[client][slot].lastPos = position;
	g_SlimeCount[client]++;
	BeginRandomArc(client, slot, position);
}

int FindFreeSlimeSlot(int client)
{
	for (int slot = 0; slot < MAX_SLIMES; slot++)
	{
		if (g_Slimes[client][slot].entRef == INVALID_ENT_REFERENCE)
		{
			return slot;
		}
	}
	return -1;
}

void CleanupInvalidSlimes(int client)
{
	for (int slot = 0; slot < MAX_SLIMES; slot++)
	{
		if (g_Slimes[client][slot].entRef == INVALID_ENT_REFERENCE)
		{
			continue;
		}
		int entity = EntRefToEntIndex(g_Slimes[client][slot].entRef);
		if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
		{
			DestroySlimeSlot(client, slot);
		}
	}
}

void TrimSlimes(int client, int maximum)
{
	CleanupInvalidSlimes(client);
	for (int slot = MAX_SLIMES - 1; slot >= 0 && g_SlimeCount[client] > maximum; slot--)
	{
		DestroySlimeSlot(client, slot);
	}
}

void DestroySlimeSlot(int client, int slot)
{
	int ref = g_Slimes[client][slot].entRef;
	if (ref != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(ref);
		if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		if (g_SlimeCount[client] > 0)
		{
			g_SlimeCount[client]--;
		}
	}
	ResetSlimeState(client, slot);
}

public Action Timer_UpdateSlimes(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsValidSpitter(client))
		{
			if (g_SlimeCount[client] > 0 || g_SlimeTimers[client] != null || g_GasRefs[client] != INVALID_ENT_REFERENCE)
			{
				CleanupSpitter(client);
			}
			continue;
		}

		ValidateGasReference(client);
		if (!g_hSlimeEnable.BoolValue)
		{
			ClearSlimes(client);
			continue;
		}

		int maximum = g_hSlimeMax.IntValue;
		if (maximum < 0)
		{
			maximum = 0;
		}
		if (maximum > MAX_SLIMES)
		{
			maximum = MAX_SLIMES;
		}
		TrimSlimes(client, maximum);

		for (int slot = 0; slot < MAX_SLIMES; slot++)
		{
			int entity = EntRefToEntIndex(g_Slimes[client][slot].entRef);
			if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
			{
				if (g_Slimes[client][slot].entRef != INVALID_ENT_REFERENCE)
				{
					DestroySlimeSlot(client, slot);
				}
				continue;
			}
			UpdateSlime(client, slot, entity);
		}
	}
	return Plugin_Continue;
}

void ClearSlimes(int client)
{
	for (int slot = 0; slot < MAX_SLIMES; slot++)
	{
		DestroySlimeSlot(client, slot);
	}
	g_SlimeCount[client] = 0;
}

void ValidateGasReference(int client)
{
	if (g_GasRefs[client] == INVALID_ENT_REFERENCE)
	{
		return;
	}

	int entity = EntRefToEntIndex(g_GasRefs[client]);
	if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
	{
		g_GasRefs[client] = INVALID_ENT_REFERENCE;
	}
}

void UpdateSlime(int client, int slot, int entity)
{
	float current[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", current);
	g_Slimes[client][slot].lastPos = current;

	float ownerPosition[3];
	GetClientAbsOrigin(client, ownerPosition);
	if (GetVectorDistance(current, ownerPosition) > g_hSlimeReturnDistance.FloatValue)
	{
		float returnPosition[3];
		returnPosition[0] = ownerPosition[0];
		returnPosition[1] = ownerPosition[1];
		returnPosition[2] = ownerPosition[2] + 36.0;
		TeleportEntity(entity, returnPosition, NULL_VECTOR, NULL_VECTOR);
		g_Slimes[client][slot].lastPos = returnPosition;
		BeginRandomArc(client, slot, returnPosition);
		return;
	}

	if (!g_Slimes[client][slot].tracking)
	{
		int target = FindVisibleSurvivor(client);
		if (target > 0)
		{
			BeginTrackingArc(client, slot, current, target);
		}
	}

	if (g_Slimes[client][slot].tracking)
	{
		int target = g_Slimes[client][slot].target;
		if (!IsValidSlimeTarget(client, target))
		{
			BeginRandomArc(client, slot, current);
			return;
		}
		UpdateTrackingSlime(client, slot, entity, current, target);
		return;
	}

	UpdateRandomSlime(client, slot, entity, current);
}

void BeginRandomArc(int client, int slot, const float start[3])
{
	float radius = g_hSlimeRadius.FloatValue;
	float distance = GetRandomFloat(radius * 0.25, radius);
	float angle = GetRandomFloat(0.0, ARC_TWO_PI);

	g_Slimes[client][slot].target = 0;
	g_Slimes[client][slot].tracking = false;
	g_Slimes[client][slot].targetOffset[0] = Cosine(angle) * distance;
	g_Slimes[client][slot].targetOffset[1] = Sine(angle) * distance;
	g_Slimes[client][slot].targetOffset[2] = GetRandomFloat(-radius * 0.25, radius * 0.35) + 36.0;

	float ownerPosition[3];
	float end[3];
	GetClientAbsOrigin(client, ownerPosition);
	AddVectors(ownerPosition, g_Slimes[client][slot].targetOffset, end);
	SetSlimeArc(client, slot, start, end);
}

void BeginTrackingArc(int client, int slot, const float start[3], int target)
{
	float targetPosition[3];
	GetClientEyePosition(target, targetPosition);
	g_Slimes[client][slot].target = target;
	g_Slimes[client][slot].tracking = true;
	SetSlimeArc(client, slot, start, targetPosition);
}

void SetSlimeArc(int client, int slot, const float start[3], const float end[3])
{
	g_Slimes[client][slot].arcStart = start;
	g_Slimes[client][slot].arcEnd = end;
	g_Slimes[client][slot].arcStartedAt = GetGameTime();
	g_Slimes[client][slot].arcDuration = CalculateArcDuration(GetVectorDistance(start, end), g_hSlimeSpeed.FloatValue);
}

float CalculateArcDuration(float distance, float speed)
{
	if (speed < 1.0)
	{
		speed = 1.0;
	}
	float duration = distance / speed;
	if (duration < SLIME_UPDATE_INTERVAL)
	{
		return SLIME_UPDATE_INTERVAL;
	}
	if (duration > 2.0)
	{
		return 2.0;
	}
	return duration;
}

void UpdateRandomSlime(int client, int slot, int entity, const float current[3])
{
	float ownerPosition[3];
	float end[3];
	GetClientAbsOrigin(client, ownerPosition);
	AddVectors(ownerPosition, g_Slimes[client][slot].targetOffset, end);

	float duration = g_Slimes[client][slot].arcDuration;
	if (duration <= 0.0)
	{
		BeginRandomArc(client, slot, current);
		return;
	}

	float progress = (GetGameTime() - g_Slimes[client][slot].arcStartedAt) / duration;
	if (progress >= 1.0)
	{
		BeginRandomArc(client, slot, current);
		return;
	}
	if (progress < 0.0)
	{
		progress = 0.0;
	}

	float next[3];
	CalculateParabolicPosition(g_Slimes[client][slot].arcStart, end, progress, next);
	TeleportEntity(entity, next, NULL_VECTOR, NULL_VECTOR);
	g_Slimes[client][slot].lastPos = next;
}

void UpdateTrackingSlime(int client, int slot, int entity, const float current[3], int target)
{
	float targetPosition[3];
	GetClientEyePosition(target, targetPosition);
	float distance = GetVectorDistance(current, targetPosition);
	if (distance <= g_hSlimeHitRadius.FloatValue)
	{
		HitSlime(client, slot, entity, target, current);
		return;
	}

	float duration = CalculateArcDuration(distance, g_hSlimeSpeed.FloatValue);
	g_Slimes[client][slot].arcStart = current;
	g_Slimes[client][slot].arcEnd = targetPosition;
	g_Slimes[client][slot].arcStartedAt = GetGameTime();
	g_Slimes[client][slot].arcDuration = duration;

	float progress = SLIME_UPDATE_INTERVAL / duration;
	if (progress > 1.0)
	{
		progress = 1.0;
	}
	float next[3];
	CalculateParabolicPosition(current, targetPosition, progress, next);
	if (GetVectorDistance(targetPosition, next) <= g_hSlimeHitRadius.FloatValue
		|| DistanceToSegment(targetPosition, current, next) <= g_hSlimeHitRadius.FloatValue)
	{
		HitSlime(client, slot, entity, target, next);
		return;
	}

	TeleportEntity(entity, next, NULL_VECTOR, NULL_VECTOR);
	g_Slimes[client][slot].lastPos = next;
}

void CalculateParabolicPosition(const float start[3], const float end[3], float progress, float result[3])
{
	if (progress < 0.0)
	{
		progress = 0.0;
	}
	if (progress > 1.0)
	{
		progress = 1.0;
	}

	result[0] = start[0] + (end[0] - start[0]) * progress;
	result[1] = start[1] + (end[1] - start[1]) * progress;
	result[2] = start[2] + (end[2] - start[2]) * progress;
	result[2] += 4.0 * g_hSlimeArcHeight.FloatValue * progress * (1.0 - progress);
}

float DistanceToSegment(const float point[3], const float start[3], const float end[3])
{
	float segment[3];
	float toPoint[3];
	MakeVectorFromPoints(start, end, segment);
	MakeVectorFromPoints(start, point, toPoint);

	float lengthSquared = GetVectorLength(segment, true);
	if (lengthSquared <= 0.0001)
	{
		return GetVectorDistance(point, start);
	}

	float progress = GetVectorDotProduct(toPoint, segment) / lengthSquared;
	if (progress < 0.0)
	{
		progress = 0.0;
	}
	if (progress > 1.0)
	{
		progress = 1.0;
	}

	float closest[3];
	closest[0] = start[0] + segment[0] * progress;
	closest[1] = start[1] + segment[1] * progress;
	closest[2] = start[2] + segment[2] * progress;
	return GetVectorDistance(point, closest);
}

void HitSlime(int client, int slot, int entity, int target, const float hitPosition[3])
{
	if (IsValidSurvivor(target) && IsValidSpitter(client))
	{
		SDKHooks_TakeDamage(target, entity, client, g_hSlimeDamage.FloatValue, DMG_ACID, -1, NULL_VECTOR, hitPosition, true);
	}
	DestroySlimeSlot(client, slot);
}

int FindVisibleSurvivor(int client)
{
	int candidates[MAXPLAYERS + 1];
	int count = 0;
	float ownerPosition[3];
	GetClientEyePosition(client, ownerPosition);

	for (int target = 1; target <= MaxClients; target++)
	{
		if (!IsValidSurvivor(target))
		{
			continue;
		}

		float targetPosition[3];
		GetClientEyePosition(target, targetPosition);
		if (GetVectorDistance(ownerPosition, targetPosition) > g_hSlimeTargetRange.FloatValue)
		{
			continue;
		}
		if (IsVisibleToSpitter(client, target))
		{
			candidates[count++] = target;
		}
	}

	if (count == 0)
	{
		return 0;
	}
	return candidates[GetRandomInt(0, count - 1)];
}

bool IsValidSlimeTarget(int client, int target)
{
	if (!IsValidSurvivor(target))
	{
		return false;
	}

	float ownerPosition[3];
	float targetPosition[3];
	GetClientEyePosition(client, ownerPosition);
	GetClientEyePosition(target, targetPosition);
	return GetVectorDistance(ownerPosition, targetPosition) <= g_hSlimeTargetRange.FloatValue
		&& IsVisibleToSpitter(client, target);
}

bool IsVisibleToSpitter(int client, int target)
{
	float start[3];
	float end[3];
	GetClientEyePosition(client, start);
	GetClientEyePosition(target, end);

	Handle trace = TR_TraceRayFilterEx(start, end, MASK_VISIBLE, RayType_EndPoint, TraceFilterIgnoreEntity, client);
	bool visible = !TR_DidHit(trace) || TR_GetEntityIndex(trace) == target;
	delete trace;
	return visible;
}

public bool TraceFilterIgnoreEntity(int entity, int contentsMask, any data)
{
	return entity != data;
}

public Action L4D2_ActivateAbility_Spitter(int client, int ability)
{
	// Left4DHooks exposes the Spitter IN_ATTACK ability activation here.
	if (!IsValidSpitter(client) || !g_hGasEnable.BoolValue)
	{
		return Plugin_Continue;
	}

	int gas = CreateGasCan(client);
	if (gas == INVALID_ENT_REFERENCE)
	{
		// Creation failure deliberately keeps the normal spit as a safe fallback.
		return Plugin_Continue;
	}

	if (!L4D2_SetCustomAbilityCooldown(client, g_hGasCooldown.FloatValue))
	{
		g_GasRefs[client] = INVALID_ENT_REFERENCE;
		g_GasOwner[gas] = 0;
		g_GasExploded[gas] = true;
		if (IsValidEntity(gas))
		{
			SDKUnhook(gas, SDKHook_Touch, OnGasCanTouch);
			RemoveEntity(gas);
		}
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

int CreateGasCan(int client)
{
	if (g_GasRefs[client] != INVALID_ENT_REFERENCE)
	{
		int existing = EntRefToEntIndex(g_GasRefs[client]);
		if (existing != INVALID_ENT_REFERENCE && IsValidEntity(existing))
		{
			return INVALID_ENT_REFERENCE;
		}
		g_GasRefs[client] = INVALID_ENT_REFERENCE;
	}

	int entity = CreateEntityByName("prop_physics");
	if (entity == -1)
	{
		LogError("Failed to create the Spitter gas can entity.");
		return INVALID_ENT_REFERENCE;
	}
	if (entity >= MAX_TRACKED_ENTITIES)
	{
		RemoveEntity(entity);
		LogError("Gas can entity index %d exceeds tracking capacity.", entity);
		return INVALID_ENT_REFERENCE;
	}

	DispatchKeyValue(entity, "model", MODEL_GAS_CAN);
	DispatchKeyValue(entity, "physdamagescale", "0.0");
	DispatchSpawn(entity);

	float angles[3];
	float direction[3];
	float start[3];
	float velocity[3];
	GetClientEyeAngles(client, angles);
	GetAngleVectors(angles, direction, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(direction, direction);
	GetClientEyePosition(client, start);
	start[0] += direction[0] * 36.0;
	start[1] += direction[1] * 36.0;
	start[2] += direction[2] * 36.0;
	velocity[0] = direction[0] * g_hGasSpeed.FloatValue;
	velocity[1] = direction[1] * g_hGasSpeed.FloatValue;
	velocity[2] = direction[2] * g_hGasSpeed.FloatValue + g_hGasArcHeight.FloatValue;

	g_GasOwner[entity] = client;
	g_GasExploded[entity] = false;
	g_GasIgnoreUntil[entity] = GetGameTime() + 0.15;
	g_GasRefs[client] = EntIndexToEntRef(entity);
	if (HasEntProp(entity, Prop_Send, "m_hOwnerEntity"))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	}
	SDKHook(entity, SDKHook_Touch, OnGasCanTouch);
	TeleportEntity(entity, start, angles, velocity);
	return entity;
}

public void OnGasCanTouch(int entity, int other)
{
	if (entity < 0 || entity >= MAX_TRACKED_ENTITIES || !IsValidEntity(entity) || g_GasExploded[entity])
	{
		return;
	}

	int owner = g_GasOwner[entity];
	if (other == owner && GetGameTime() < g_GasIgnoreUntil[entity])
	{
		return;
	}
	ExplodeGasCan(entity, owner);
}

void ExplodeGasCan(int entity, int owner)
{
	if (entity < 0 || entity >= MAX_TRACKED_ENTITIES || g_GasExploded[entity])
	{
		return;
	}

	g_GasExploded[entity] = true;
	SDKUnhook(entity, SDKHook_Touch, OnGasCanTouch);

	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	CreateExplosionParticle(PARTICLE_GAS_BLAST, position);
	CreateExplosionParticle(PARTICLE_GAS_FIRE, position);
	if (GetRandomInt(0, 1) == 0)
	{
		EmitSoundToAll(SOUND_EXPLODE_1, entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	}
	else
	{
		EmitSoundToAll(SOUND_EXPLODE_2, entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	}

	DamageGasTargets(entity, owner, position);
	if (owner > 0 && owner <= MaxClients && g_GasRefs[owner] == EntIndexToEntRef(entity))
	{
		g_GasRefs[owner] = INVALID_ENT_REFERENCE;
	}
	g_GasOwner[entity] = 0;
	RemoveEntity(entity);
}

int CreateExplosionParticle(const char[] effectName, const float position[3])
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle == -1)
	{
		LogError("Failed to create explosion particle %s.", effectName);
		return INVALID_ENT_REFERENCE;
	}

	DispatchKeyValue(particle, "effect_name", effectName);
	DispatchSpawn(particle);
	ActivateEntity(particle);
	TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(particle, "start");
	CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	return particle;
}

public Action Timer_RemoveEntity(Handle timer, any entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

void DamageGasTargets(int inflictor, int owner, const float position[3])
{
	int attacker = owner;
	if (!IsValidClient(attacker))
	{
		attacker = inflictor;
	}
	for (int target = 1; target <= MaxClients; target++)
	{
		if (!ShouldHurtGasTarget(target))
		{
			continue;
		}

		float targetPosition[3];
		GetClientAbsOrigin(target, targetPosition);
		if (GetVectorDistance(position, targetPosition) > g_hGasRadius.FloatValue)
		{
			continue;
		}

		// SDKDamage carries the configured damage; no engine-created damage entity is used.
		SDKHooks_TakeDamage(target, inflictor, attacker, g_hGasDamage.FloatValue, DMG_GENERIC, -1, NULL_VECTOR, position, true);
		ApplyGasKnockback(target, position);
	}
}

bool ShouldHurtGasTarget(int target)
{
	if (!IsValidClient(target) || !IsPlayerAlive(target))
	{
		return false;
	}

	int team = GetClientTeam(target);
	if (team == 2)
	{
		return g_hGasHurtSurvivors.BoolValue;
	}
	if (team == 3)
	{
		return g_hGasHurtInfected.BoolValue && GetEntProp(target, Prop_Send, "m_isGhost") == 0;
	}
	return false;
}

void ApplyGasKnockback(int target, const float position[3])
{
	if (!IsValidClient(target) || !IsPlayerAlive(target))
	{
		return;
	}

	float targetPosition[3];
	float direction[3];
	GetClientAbsOrigin(target, targetPosition);
	MakeVectorFromPoints(position, targetPosition, direction);
	direction[2] = 0.0;
	if (GetVectorLength(direction, true) <= 0.0001)
	{
		direction[0] = 1.0;
		direction[1] = 0.0;
	}
	NormalizeVector(direction, direction);

	float velocity[3];
	velocity[0] = direction[0] * g_hGasKnockback.FloatValue;
	velocity[1] = direction[1] * g_hGasKnockback.FloatValue;
	velocity[2] = g_hGasKnockup.FloatValue;
	TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, velocity);
}
