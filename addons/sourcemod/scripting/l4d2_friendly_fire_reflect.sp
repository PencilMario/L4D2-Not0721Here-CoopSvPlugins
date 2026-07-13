#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#pragma semicolon 1
#pragma newdecls required

ConVar g_Enable, g_DamageThreshold, g_BlockThreshold, g_IncidentLimit, g_Level1Mult, g_Level2Mult, g_Protected, g_Notify;
StringMap g_Damage, g_Incidents, g_Level;
bool g_InReflect;
int g_EntityOwner[2049], g_LastAttacker[MAXPLAYERS + 1];
bool g_CountedDown[MAXPLAYERS + 1];

public Plugin myinfo = { name = "L4D2 Friendly Fire Reflect", author = "Not0721Here", description = "章节友伤累计与反伤", version = "1.0" };

public void OnPluginStart() {
    g_Enable = CreateConVar("l4d2_ff_reflect_enable", "1");
    g_DamageThreshold = CreateConVar("l4d2_ff_reflect_damage_threshold", "500.0");
    g_BlockThreshold = CreateConVar("l4d2_ff_reflect_block_threshold", "1000.0");
    g_IncidentLimit = CreateConVar("l4d2_ff_reflect_incident_limit", "3");
    g_Level1Mult = CreateConVar("l4d2_ff_reflect_level1_multiplier", "1.0");
    g_Level2Mult = CreateConVar("l4d2_ff_reflect_level2_multiplier", "2.0");
    g_Protected = CreateConVar("l4d2_ff_reflect_protected_sources", "1");
    g_Notify = CreateConVar("l4d2_ff_reflect_notify", "1");
    AutoExecConfig(true, "l4d2_friendly_fire_reflect");
    g_Damage = new StringMap(); g_Incidents = new StringMap(); g_Level = new StringMap();
    HookEvent("player_incapacitated", Event_Incap, EventHookMode_Post);
    HookEvent("player_death", Event_Death, EventHookMode_Post);
    HookEvent("revive_success", Event_Revive, EventHookMode_Post);
    HookEvent("round_start", Event_ResetDowned); HookEvent("mission_lost", Event_ResetDowned);
    for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
}
public void OnMapStart() { delete g_Damage; delete g_Incidents; delete g_Level; g_Damage = new StringMap(); g_Incidents = new StringMap(); g_Level = new StringMap(); }
public void OnClientPutInServer(int client) { SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); }
public void OnEntityCreated(int entity, const char[] classname) { if (entity > MaxClients && entity < sizeof(g_EntityOwner) && ProtectedClass(classname)) SDKHook(entity, SDKHook_OnTakeDamage, OnPropDamage); }
public Action OnPropDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) { if (Survivor(attacker) && victim < sizeof(g_EntityOwner)) g_EntityOwner[victim] = GetClientUserId(attacker); return Plugin_Continue; }

void SteamKey(int client, char[] key, int len) { GetClientAuthId(client, AuthId_Steam2, key, len); }
float GetMapFloat(StringMap map, const char[] key) { int bits; return map.GetValue(key, bits) ? view_as<float>(bits) : 0.0; }
void SetMapFloat(StringMap map, const char[] key, float value) { map.SetValue(key, view_as<int>(value)); }
int GetMapInt(StringMap map, const char[] key) { int value; return map.GetValue(key, value) ? value : 0; }

float FriendlyFactor() {
    char difficulty[32]; GetConVarString(FindConVar("z_difficulty"), difficulty, sizeof(difficulty));
    char name[64]; Format(name, sizeof(name), "survivor_friendly_fire_factor_%s", difficulty);
    ConVar c = FindConVar(name); if (c == null) c = FindConVar("survivor_friendly_fire_factor_normal");
    return c == null ? 0.0 : c.FloatValue;
}
bool Survivor(int c) { return c >= 1 && c <= MaxClients && IsClientInGame(c) && GetClientTeam(c) == 2 && !IsFakeClient(c); }
bool Incapped(int c) { return GetEntProp(c, Prop_Send, "m_isIncapacitated") != 0; }
bool ProtectedClass(const char[] cls) { return StrEqual(cls, "inferno") || StrEqual(cls, "molotov_projectile") || StrEqual(cls, "pipe_bomb_projectile") || StrEqual(cls, "prop_fuel_barrel") || StrEqual(cls, "prop_physics") || StrEqual(cls, "prop_physics_multiplayer"); }
bool ProtectedSource(int entity) { if (entity <= MaxClients || !IsValidEntity(entity)) return false; char cls[64]; GetEntityClassname(entity, cls, sizeof(cls)); if (ProtectedClass(cls)) return true; char model[PLATFORM_MAX_PATH]; GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model)); return StrContains(model, "gascan", false) != -1 || StrContains(model, "propanecanister", false) != -1 || StrContains(model, "oxygentank", false) != -1 || StrContains(model, "fireworks", false) != -1 || StrContains(model, "fuel_barrel", false) != -1; }

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float force[3], float pos[3]) {
    if (g_InReflect || !g_Enable.BoolValue || !Survivor(victim) || damage <= 0.0) return Plugin_Continue;
    if (!Survivor(attacker) && inflictor > MaxClients && inflictor < sizeof(g_EntityOwner)) attacker = GetClientOfUserId(g_EntityOwner[inflictor]);
    if (!Survivor(attacker) || victim == attacker) return Plugin_Continue;
    float factor = FriendlyFactor(); if (factor <= 0.0) return Plugin_Continue;
    char key[64]; SteamKey(attacker, key, sizeof(key)); if (key[0] == '\0') return Plugin_Continue;
    int oldLevel = GetMapInt(g_Level, key); bool wasDown = Incapped(victim);
    float raw = damage; if (!wasDown) SetMapFloat(g_Damage, key, GetMapFloat(g_Damage, key) + raw / factor);
    g_LastAttacker[victim] = GetClientUserId(attacker);
    int incidents = GetMapInt(g_Incidents, key);
    bool isProtectedSource = ProtectedSource(inflictor) || ProtectedSource(weapon);
    if (oldLevel >= 2) { damage = 0.0; Reflect(attacker, raw, g_Level2Mult.FloatValue, isProtectedSource); return Plugin_Changed; }
    if (oldLevel >= 1) { Reflect(attacker, raw, g_Level1Mult.FloatValue, isProtectedSource); }
    float total = GetMapFloat(g_Damage, key);
    int newLevel = oldLevel;
    if (oldLevel < 1 && (total >= g_DamageThreshold.FloatValue || incidents > g_IncidentLimit.IntValue)) newLevel = 1;
    if (oldLevel < 2 && total >= g_BlockThreshold.FloatValue) newLevel = 2;
    if (newLevel > oldLevel) { g_Level.SetValue(key, newLevel); Notify(attacker, newLevel); }
    return oldLevel >= 1 ? Plugin_Changed : Plugin_Continue;
}

void Reflect(int attacker, float damage, float mult, bool isProtectedSource) {
    float amount = damage * mult; if (g_Protected.BoolValue && isProtectedSource && !Incapped(attacker)) amount = MinFloat(amount, float(GetClientHealth(attacker) - 1));
    if (amount <= 0.0) return; g_InReflect = true; SDKHooks_TakeDamage(attacker, 0, 0, amount, DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, true); g_InReflect = false;
}
float MinFloat(float a, float b) { return a < b ? a : b; }
void Notify(int client, int level) { LogMessage("%N friendly-fire reflect level %d", client, level); int mode = g_Notify.IntValue; if (mode >= 1) PrintToChat(client, "\x04[友伤] 你已达到反伤等级 %d", level); if (mode >= 2) PrintToChatAll("\x04[友伤] %N 达到反伤等级 %d", client, level); }
void AddIncident(int victim) { int attacker = GetClientOfUserId(g_LastAttacker[victim]); if (!Survivor(attacker)) return; char key[64]; SteamKey(attacker, key, sizeof(key)); g_Incidents.SetValue(key, GetMapInt(g_Incidents, key) + 1); }
public void Event_Incap(Event event, const char[] name, bool dontBroadcast) { int victim = GetClientOfUserId(event.GetInt("userid")); if (!Survivor(victim) || g_CountedDown[victim]) return; AddIncident(victim); g_CountedDown[victim] = true; }
public void Event_Death(Event event, const char[] name, bool dontBroadcast) { int victim = GetClientOfUserId(event.GetInt("userid")); if (victim < 1 || victim > MaxClients || g_CountedDown[victim]) return; AddIncident(victim); g_CountedDown[victim] = true; }
public void Event_Revive(Event event, const char[] name, bool dontBroadcast) { int victim = GetClientOfUserId(event.GetInt("subject")); if (victim >= 1 && victim <= MaxClients) g_CountedDown[victim] = false; }
public void Event_ResetDowned(Event event, const char[] name, bool dontBroadcast) { for (int i = 1; i <= MaxClients; i++) { g_CountedDown[i] = false; g_LastAttacker[i] = 0; } }
