#define		TEAM_SURVIVOR				2
#define     PLUGIN_NAME                 "Teleport Rushers"
#define		PLUGIN_VERSION				"0.2"

#define     PLUGIN_CONFIG               "teleportrushers.cfg"

#include	<sourcemod>
#include    <sdktools>
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

new Float:fRushingDistanceRequired;
new Float:fRequiredPercentageTeamBehind;
new iRequiredTeammatesBehind;

public Plugin:myinfo = { name = PLUGIN_NAME, version = PLUGIN_VERSION, };

public OnPluginStart() {
	CreateConVar("rum_teleportrushers", PLUGIN_VERSION, "version");
	SetConVarString(FindConVar("rum_teleportrushers"), PLUGIN_VERSION);
}

public ReadyUp_SurvivorEnteredCheckpoint(client) {
    IsRushingAheadOfMajority(client);
}

IsRushingAheadOfMajority(client) {
    new numberOfHumans = 0;
    for (new i = 1; i <= MaxClients; i++) {
        if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
        numberOfHumans++;
    }
    new numberOfHumansOutOfRange = 0;
    new Float:clientPos[3];
    GetClientAbsOrigin(client, clientPos);
    new Float:otherSurvivorPos[3];
    new teleportTarget = -1;
    for (new i = 1; i <= MaxClients; i++) {
        if (i == client || !IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
        GetClientAbsOrigin(i, otherSurvivorPos);
        if (GetVectorDistance(clientPos, otherSurvivorPos) <= fRushingDistanceRequired) continue;
        teleportTarget = i;
        numberOfHumansOutOfRange++;
    }
    if (numberOfHumansOutOfRange > iRequiredTeammatesBehind) {
        new Float:fPercentageOfTeamOutsideRange = (numberOfHumansOutOfRange * 1.0) / (numberOfHumans * 1.0);
        if (fPercentageOfTeamOutsideRange >= fRequiredPercentageTeamBehind) {
            GetClientAbsOrigin(teleportTarget, otherSurvivorPos);
            TeleportEntity(client, otherSurvivorPos, NULL_VECTOR, NULL_VECTOR);
            PrintToChat(client, "\x04Stay with your team or \x03don't enter \x04the checkpoint!");
        }
    }
    //else PrintToChat(client, "%d humans out of range, %d teammates required behind to flag you, %3.2f / %3.2f required percentage of team behind you.", numberOfHumansOutOfRange, iRequiredTeammatesBehind, fPercentageOfTeamOutsideRange, fRequiredPercentageTeamBehind);
}

bool:IsLegitimateClient(client) {
	if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) return false;
	return true;
}

public OnConfigsExecuted() { CreateTimer(0.1, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE); }

public Action:Timer_ExecuteConfig(Handle:timer) {
	if (ReadyUp_NtvConfigProcessing() == 0) {

		ReadyUp_ParseConfig(PLUGIN_CONFIG);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public ReadyUp_ParseConfigFailed(String:config[], String:error[]) {
	if (StrEqual(config, PLUGIN_CONFIG)) SetFailState("%s , %s", config, error);
}

public ReadyUp_LoadFromConfigEx(Handle:keys, Handle:values, Handle:section, String:configname[], KeyCount) {
    if (StrEqual(configname, PLUGIN_CONFIG)) {
        decl String:key[PLATFORM_MAX_PATH];
        decl String:val[PLATFORM_MAX_PATH];
        new size = GetArraySize(keys);
        for (new i = 0; i < size; i++) {
            GetArrayString(Handle:keys, i, key, sizeof(key));
            GetArrayString(Handle:values, i, val, sizeof(val));
            if (StrEqual(key, "rushing distance?")) fRushingDistanceRequired							= StringToFloat(val);
            if (StrEqual(key, "teammates behind percentage required?")) fRequiredPercentageTeamBehind	= StringToFloat(val);
            if (StrEqual(key, "teammates behind number required?")) iRequiredTeammatesBehind			= StringToInt(val);
        }
    }
}