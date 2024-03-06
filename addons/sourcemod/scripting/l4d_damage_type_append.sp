#define PLUGIN_VERSION "1.1.1"

/*
 *	v1.0 just released; 2-4-22
 *	v1.1 optional: appending melee attack only; 2-4-22
 *	v1.1.1 fix my stupid 'logic and' error; 2-4-22
 */
#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <sourcemod>

#define Witch 7 - 1
#define Survivor 9 - 1

ConVar Enabled; bool enabled;
ConVar Type_apply; int type_apply;
ConVar Type_specifies; int type_specifies;
ConVar Type_targets; int type_targets;
ConVar Melee_only; bool melee_only;

public Plugin myinfo = {
	name = "[L4D & L4D2] Damage Type Append",
	author = "NoroHime",
	description = "Append Damage Type for your Specified Type",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/NoroHime/"
}

public void OnPluginStart() {
	CreateConVar("damage_type_append_version", PLUGIN_VERSION, "Version of Damage Type Append", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	Enabled = CreateConVar("damage_type_append_enable", "1", "Enable 'Damage Type Append'", FCVAR_NOTIFY);
	Type_apply = CreateConVar("damage_type_append_apply", "64", "Damage Type you want to Append 64=DMG_BLAST", FCVAR_NOTIFY);
	Type_specifies = CreateConVar("damage_type_append_specifies", "128", "Which specified types for Append 128=DMG_CLUB", FCVAR_NOTIFY);
	Type_targets = CreateConVar("damage_type_append_targets", "224", "Which Target should be Append, 1=Smoker, 2=Boomer, 4=Hunter, 8=Spitter, 16=Jockey, 32=Charger, 64=Witch, 128=Tank, 256=Survivor, 511=All. Add numbers together.", FCVAR_NOTIFY);
	Melee_only = CreateConVar("damage_type_append_melee_only", "1", "append type only using melee", FCVAR_NOTIFY);

	AutoExecConfig(true, "l4d_damage_type_append");
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("witch_spawn", Event_WitchSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("witch_killed", Event_WitchKilled);

	Enabled.AddChangeHook(Event_ConVarChanged);
	Type_apply.AddChangeHook(Event_ConVarChanged);
	Type_specifies.AddChangeHook(Event_ConVarChanged);
	Type_targets.AddChangeHook(Event_ConVarChanged);
	Melee_only.AddChangeHook(Event_ConVarChanged);
	ApplyCvars();
}

public void Event_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	ApplyCvars();
}

public void OnConfigsExecuted() {
	ApplyCvars();
}

public void ApplyCvars() {
	enabled = Enabled.BoolValue;
	type_apply = Type_apply.IntValue;
	type_specifies = Type_specifies.IntValue;
	type_targets = Type_targets.IntValue;
	melee_only = Melee_only.BoolValue;
}

void HookClient(int client) {
	int team = GetClientTeam(client);

	switch (team) {
		case 2: {
			if (type_targets & (1 << Survivor))
				SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		}
		case 3: {
			int class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if (type_targets & (1 << (class - 1)))
				SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}

public void Event_WitchSpawn(Event event, const char[] name, bool dontBroadcast) {
	int witch = event.GetInt("witchid");

	if (enabled && witch && type_targets & (1 << Witch))
		SDKHook(witch, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void Event_WitchKilled(Event event, const char[] name, bool dontBroadcast) {
	int witch = event.GetInt("witchid");

	if(enabled && witch)
		SDKUnhook(witch, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (enabled && client)
		HookClient(client);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (enabled && client)
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3]) {

	if (damagetype & type_specifies && !(damagetype & type_apply)) {

		if (melee_only && IsValidEntity(weapon)) {

			char weapon_name[32];
			GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));

			if (strcmp(weapon_name, "weapon_melee") == 0) {

				damagetype |= type_apply;

				return Plugin_Changed;
			} else 
				return Plugin_Continue;
		}

		damagetype |= type_apply;

		return Plugin_Changed;
	}
	return Plugin_Continue;
}