#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION		"2.1"
#define CVAR_FLAGS		FCVAR_PLUGIN|FCVAR_NOTIFY
#define CONFIG_DATA		"data/scavengebotsds.cfg"
#define CONFIG_FINALE_DATA		"data/scavengefinalebotsds.cfg"
#define CONFIG_SCAVENGE_DATA		"data/scavengegamebotsds.cfg"

static Handle:hScavengeBotsDS = INVALID_HANDLE;
static bool:bScavengeBotsDS = false;

static Handle:hScavengeBuddy = INVALID_HANDLE;
static bool:bScavengeBuddy = false;

static BotAction[MAXPLAYERS+1];
static BotTarget[MAXPLAYERS+1];
static BotAIUpdate[MAXPLAYERS+1];
static Float:BotCheckPos[MAXPLAYERS+1][3];
static BotAbortTick[MAXPLAYERS+1];
static BotUseGasCan[MAXPLAYERS+1];
static BotBuddy[MAXPLAYERS+1];
static Float:hpMultiplier;

static GasNozzle;
static Float:NozzleOrigin[3];
static Float:NozzleAngles[3];
static Float:NozzleOrigin2[3];
static Float:NozzleAngles2[3];
static Float:NozzleOrigin3[3];
static Float:NozzleAngles3[3];

static bool:bScavengeInProgress = false;
static bool:bFinaleScavengeInProgress = false;
static bool:bScavengeGameInProgress = false;
static bool:FinaleHasStarted = false;
static bool:EscapeReady = false;

public Plugin:myinfo =
{
	name = "[L4D2] ScavengeBotsDS",
	author = "Machine/Xanaguy/ArcticCerebrate",
	description = "Survivor Bots Scavenging now more compatible overall.",
	version = PLUGIN_VERSION,
	url = ""
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:game[12];
	GetGameFolderName(game, sizeof(game));
	if (strcmp(game, "left4dead2", false))
	{
		strcopy(error, err_max, "ScavengeBotsDS only supports Left4Dead2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public OnPluginStart()
{
	hScavengeBotsDS = CreateConVar("scavengebotsds_on", "1", "Enable ScavengeBots? 0=off, 1=on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	bScavengeBotsDS = GetConVarBool(hScavengeBotsDS);
	
	hScavengeBuddy = CreateConVar("scavengebotsds_buddy", "0", "Enable ScavengeBots Buddy System? 0=off, 1=on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	bScavengeBuddy = GetConVarBool(hScavengeBuddy);
	
	hpMultiplier = GetConVarFloat(FindConVar("sb_temp_health_consider_factor"));

	HookEvent("finale_start", Finale_Start);
	HookEvent("gauntlet_finale_start", Finale_Start);
	HookEvent("player_use", Start_Scavenging);
	HookEvent("gascan_pour_completed", Start_Scavenging);
	HookEvent("instructor_server_hint_create", Start_Scavenging);
	HookEvent("finale_vehicle_incoming", Stop_Scavenging);
	HookEvent("finale_vehicle_ready", Stop_Scavenging);
	HookEvent("finale_escape_start", Stop_Scavenging);
	HookEvent("scavenge_round_start", Scavenge_Round_Start);
	HookEvent("round_start", Round_Start);
	HookEvent("weapon_drop", Weapon_Drop);
	HookEvent("scavenge_round_halftime", ResetBools);
	HookEvent("scavenge_round_finished", ResetBools);
	HookEvent("round_end", ResetBools);
	HookEvent("map_transition", ResetBools);
	HookEvent("mission_lost", ResetBools);
	HookEvent("finale_win", ResetBools);
	HookEvent("round_start_pre_entity", ResetBools);

	HookConVarChange(hScavengeBotsDS, ConVarChanged);
	HookConVarChange(hScavengeBuddy, ConVarChanged);

	CreateTimer(0.1, BotUpdate, _, TIMER_REPEAT);
	
	AutoExecConfig(true, "l4d2_scavengebotsds");
}

public OnMapStart()
{
	bFinaleScavengeInProgress = false;
	bScavengeInProgress = false;
	bScavengeGameInProgress = false;
	FinaleHasStarted = false;
	EscapeReady = false;
}

public Action:ResetBools(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(0.1, CallBotsOff, 0);
}

public ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == hScavengeBotsDS)
	{
		bScavengeBotsDS = GetConVarBool(hScavengeBotsDS);
		new oldval = StringToInt(oldValue);
		new newval = StringToInt(newValue);
		if (oldval != newval)
		{
			if (newval == 0)
			{
				for (new i=1; i<=MaxClients; i++)
				{
					if (IsBot(i))
					{
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(i));
					}
				}
			}
			else
			{
				if (GetConVarInt(FindConVar("sb_unstick")) == 1)
				{
					SetConVarInt(FindConVar("sb_unstick"), 0);
				}
			}
		}
	}
	if (convar == hScavengeBuddy)
	{
		bScavengeBuddy = GetConVarBool(hScavengeBuddy);
	}
}
public Action:Finale_Start(Handle:event, String:event_name[], bool:dontBroadcast)
{
	FinaleHasStarted = true;
	bScavengeGameInProgress = false;
	bScavengeInProgress = false;
	
	new entity = -1;
	
	if (!IsInvalidMap())
	{
		while ((entity = FindEntityByClassname(entity, "game_scavenge_progress_display")) != -1)
		{
			bFinaleScavengeInProgress = true;
			LoadFinaleConfig();
		}
		while ((entity = FindEntityByClassname(entity, "point_prop_use_target")) != INVALID_ENT_REFERENCE)
		{
			GasNozzle = entity;
			HookSingleEntityOutput(entity, "OnUseStarted", OnUseStarted);
			HookSingleEntityOutput(entity, "OnUseCancelled", OnUseCancelled);
			HookSingleEntityOutput(entity, "OnUseFinished", OnUseFinished);
		}
	}
}

public Action:Scavenge_Round_Start(Handle:event, String:event_name[], bool:dontBroadcast)
{
	if (!IsInvalidMap())
	{
		bScavengeGameInProgress = true;
		LoadScavengeConfig();
		new entity = -1;
		
		while ((entity = FindEntityByClassname(entity, "point_prop_use_target")) != INVALID_ENT_REFERENCE)
		{
			GasNozzle = entity;
			HookSingleEntityOutput(entity, "OnUseStarted", OnUseStarted);
			HookSingleEntityOutput(entity, "OnUseCancelled", OnUseCancelled);
			HookSingleEntityOutput(entity, "OnUseFinished", OnUseFinished);
		}
	}
}

public Action:Stop_Scavenging(Handle:event, String:event_name[], bool:dontBroadcast)
{
	bScavengeInProgress = false;
	bFinaleScavengeInProgress = false;
	EscapeReady = true;
	CreateTimer(0.2, EscapeTime);
	if (bScavengeBotsDS)
	{
		for (new client=1; client<=MaxClients; client++)
		{
			if (IsBot(client))
			{
				L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
			}
		}
	}
}
public Action:Round_Start(Handle:event, String:event_name[], bool:dontBroadcast)
{
	ResetVariables();
	for (new i=1; i<=MaxClients; i++)
	{
		ResetClientArrays(i);
	}
}

public Action:Start_Scavenging(Handle:event, String:event_name[], bool:dontBroadcast)
{
	CreateTimer(0.1, ScavengeDoubleCheckStart);
}

public Action:Weapon_Drop(Handle:event, const String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new entity = GetEventInt(event,"propid");

	if (bScavengeInProgress)
	{
		if (entity > 0 && IsValidEntity(entity))
		{
			decl String:classname[24];
			GetEdictClassname(entity, classname, sizeof(classname));
			if (StrEqual(classname, "weapon_gascan", false))
			{
				SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
				new glowcolor = RGB_TO_INT(255, 150, 0);
				SetEntProp(entity, Prop_Send, "m_glowColorOverride", glowcolor);
				if (IsBot(client))
				{
					if (BotTarget[client] == entity)
					{
						BotTarget[client] = -1;
					}
				}
			}
		}
	}
}
public OnClientPostAdminCheck(client)
{
	ResetClientArrays(client);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}
public OnClientDisconnect(client)
{
	ResetClientArrays(client);
}
stock ResetVariables()
{
	bScavengeInProgress = false;
	bFinaleScavengeInProgress = false;
	bScavengeGameInProgress = false;
	FinaleHasStarted = false;
	EscapeReady = false;
}
stock ResetClientArrays(client)
{
	BotAction[client] = -1;
	BotTarget[client] = -1;
	BotAIUpdate[client] = -1;
	BotUseGasCan[client] = -1;
	BotAbortTick[client] = -1;
	for (new i=0; i<=2; i++)
	{
		BotCheckPos[client][i] = 0.0;
	}
	BotBuddy[client] = -1;
}
stock LoadConfig()
{
	decl String:Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Path, sizeof(Path), "%s", CONFIG_DATA);
	if (!FileExists(Path))
	{
		PrintToServer("ScavengeBotsDS Error: Cannot read the config %s", Path);
		bScavengeInProgress = false;
		return;
	}
	new Handle:File = CreateKeyValues("maps");
	if (!FileToKeyValues(File, Path))
	{
		PrintToServer("ScavengeBotsDS Error: Failed to get maps from %s", Path);
		bScavengeInProgress = false;
		CloseHandle(File);
		return;
	}
	decl String:Map[PLATFORM_MAX_PATH];
	GetCurrentMap(Map, sizeof(Map));
	if (!KvJumpToKey(File, Map))
	{
		PrintToServer("ScavengeBotsDS Error: Failed to get map from %s", Path);
		bScavengeInProgress = false;
		CloseHandle(File);
		return;
	}
	if (FinaleHasStarted)
	{
		bScavengeInProgress = false;
		CloseHandle(File);
		return;
	}
	KvGetVector(File, "origin", NozzleOrigin2);
	KvGetVector(File, "angles", NozzleAngles2);
	CloseHandle(File);
}

stock LoadFinaleConfig()
{	
	decl String:Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Path, sizeof(Path), "%s", CONFIG_FINALE_DATA);
	if (!FileExists(Path))
	{
		PrintToServer("ScavengeBotsDS Error: Cannot read the config %s", Path);
		bFinaleScavengeInProgress = false;
		return;
	}
	new Handle:FinaleFile = CreateKeyValues("finalemaps");
	if (!FileToKeyValues(FinaleFile, Path))
	{
		PrintToServer("ScavengeBotsDS Error: Failed to get maps from %s", Path);
		bFinaleScavengeInProgress = false;
		CloseHandle(FinaleFile);
		return;
	}
	decl String:Map[PLATFORM_MAX_PATH];
	GetCurrentMap(Map, sizeof(Map));
	if (!KvJumpToKey(FinaleFile, Map))
	{
		PrintToServer("ScavengeBotsDS Error: Failed to get map from %s", Path);
		bFinaleScavengeInProgress = false;
		CloseHandle(FinaleFile);
		return;
	}
	KvGetVector(FinaleFile, "origin", NozzleOrigin);
	KvGetVector(FinaleFile, "angles", NozzleAngles);
	CloseHandle(FinaleFile);
}

stock LoadScavengeConfig()
{	
	decl String:Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Path, sizeof(Path), "%s", CONFIG_SCAVENGE_DATA);
	if (!FileExists(Path))
	{
		PrintToServer("ScavengeBotsDS Error: Cannot read the config %s", Path);
		bScavengeGameInProgress = false;
		return;
	}
	new Handle:ScavengeFile = CreateKeyValues("scavengemaps");
	if (!FileToKeyValues(ScavengeFile, Path))
	{
		PrintToServer("ScavengeBotsDS Error: Failed to get maps from %s", Path);
		bScavengeGameInProgress = false;
		CloseHandle(ScavengeFile);
		return;
	}
	decl String:Map[PLATFORM_MAX_PATH];
	GetCurrentMap(Map, sizeof(Map));
	if (!KvJumpToKey(ScavengeFile, Map))
	{
		PrintToServer("ScavengeBotsDS Error: Failed to get map from %s", Path);
		bScavengeGameInProgress = false;
		CloseHandle(ScavengeFile);
		return;
	}
	KvGetVector(ScavengeFile, "origin", NozzleOrigin3);
	KvGetVector(ScavengeFile, "angles", NozzleAngles3);
	CloseHandle(ScavengeFile);
}

public Action:BotUpdate(Handle:timer)
{
	if (!IsServerProcessing())
	{
		return Plugin_Continue;
	}
	if (bScavengeBotsDS)
	{
		for (new i=1; i<=MaxClients; i++)
		{
			if (IsBot(i))
			{
				BotAI(i);
			}
		}
	}

	return Plugin_Continue;
}

public Action:CallBotsOff(Handle:Timer)
{
	bFinaleScavengeInProgress = false;
	bScavengeInProgress = false;
	bScavengeGameInProgress = false;
	FinaleHasStarted = false;
	EscapeReady = false;
}

public Action:ScavengeUpdate(Handle:Timer)
{	
	new objective = -1;
	
	while ((objective = FindEntityByClassname(objective, "game_scavenge_progress_display")) != -1)
	{
		if (GetEntProp(objective, Prop_Send, "m_bActive", 1) && !FinaleHasStarted && !bFinaleScavengeInProgress && !bScavengeGameInProgress && !EscapeReady && !IsInvalidMap())
		{
			bScavengeInProgress = true;
		}
		else
		{
			bScavengeInProgress = false;
		}
	}
}

public Action:ScavengeDoubleCheckStart(Handle:Timer)
{
	new objective2 = -1;
	
	while ((objective2 = FindEntityByClassname(objective2, "game_scavenge_progress_display")) != -1)
	{
		if ((GetEntProp(objective2, Prop_Send, "m_bActive", 1)) && !IsScavenge() && !FinaleHasStarted && !bFinaleScavengeInProgress && !bScavengeGameInProgress && !EscapeReady && !IsInvalidMap())
		{
			bScavengeInProgress = true;
			LoadConfig();
		}
		else 
		{
			CreateTimer(0.1, ScavengeUpdate);
		}
	}
	while ((objective2 = FindEntityByClassname(objective2, "point_prop_use_target")) != INVALID_ENT_REFERENCE)
	{
		GasNozzle = objective2;
		HookSingleEntityOutput(objective2, "OnUseStarted", OnUseStarted);
		HookSingleEntityOutput(objective2, "OnUseCancelled", OnUseCancelled);
		HookSingleEntityOutput(objective2, "OnUseFinished", OnUseFinished);
	}
}
public Action:EscapeTime(Handle:Timer)
{
	bFinaleScavengeInProgress = false;
	bScavengeInProgress = false;
	EscapeReady = true;
}

// Finds the nearest carryable gas can to an entity. If "pairedCanDist" is specified, this function will only consider a pair of gas cans within the range specified by "pairedCanDist".
findNearestGas(client, maxDist, pairedCanDist = -1)
{
	new Float:Origin[3], Float:TOrigin[3], Float:distance = 0.0, Float:storeddist = 0.0, storedent = -1;
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "weapon_gascan")) != INVALID_ENT_REFERENCE)
	{
		if (entity != client && IsValidGasCan(entity) && !IsGasCanOwned(entity))
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", TOrigin);
			distance = GetVectorDistance(Origin, TOrigin);
			if (storeddist == 0.0 || storeddist > distance)
			{
				if (distance <= maxDist || maxDist == -1)
				{
					// If not looking for pairs, remember the closest gas can so far. If looking for pairs, only remember if a counterpart gas can exists.
					if (pairedCanDist < 0 || (pairedCanDist >= 0 && findNearestGas(entity, pairedCanDist) > -1))
					{
						storedent = entity;
						storeddist = distance;
					}
				}
			}
		}
	}
	return storedent;
}

// Should use assignBotsGas() unless you need to override standard gas assignment logic.
// Set up Bot assignments to find and collect a gas can near an "origin" entity. "pairedCanDist" specifies max distance of a pair of cans.
assignNearestGas(client, origin, maxDist, pairedCanDist = -1)
{
	new gas = -1;
	gas = findNearestGas(origin, maxDist, pairedCanDist);
	if (gas > -1)
	{
		BotTarget[client] = gas;
		BotAction[client] = 1;
		BotAIUpdate[client] = 10;
		BotUseGasCan[client] = -1;
		BotAbortTick[client] = 50;
	}
	
	return gas;
}

// Assigns Bots to find gas. Assignments will adjust automatically if buddy system is active or not.
assignBotGas(client, origin, maxDist)
{
	if (!IsBot(client))
	{
		return -1;
	}
	
	new gas = -1;
	new b = BotBuddy[client];
	
	if (!bScavengeBuddy)
	{
		return assignNearestGas(client, origin, maxDist);
	}
	
	// If Buddy system is active and neither have assignments, try to find pair of cans.
	if (IsBot(b) && !isBuddyBusy(client) && !isBuddyBusy(b))
	{
		gas = assignNearestGas(client, origin, maxDist, 400);
		if (gas > -1)
		{
			assignNearestGas(b, gas, 400);
			return gas;
		}
		else
		{
			gas = assignNearestGas(client, origin, maxDist);
			if (gas > -1)
			{
				assignNearestGas(b, gas, maxDist);
			}
			return gas;
		}
	}
	else
	{
		// If there is no buddy or buddy already has an assigment, find a single gas can.
		return assignNearestGas(client, origin, maxDist);
	}
}

// Maintain Bot Buddy Pairings
updateBotBuddy(client)
{
	if (bScavengeBuddy)
	{
		// If this bot is alive, just double check we have a buddy assigned.
		if (IsBot(client))
		{
			new isBW = GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike");
			// If no buddy is assigned, find a new buddy
			if (BotBuddy[client] == -1 && isBW == 0)
			{
				for (new i=1; i<=MaxClients; i++)
				{
					if (i != client && IsBot(i) && BotBuddy[i] == -1 && GetEntProp(i, Prop_Send, "m_bIsOnThirdStrike") == 0)
					{
						BotBuddy[client] = i;
						BotBuddy[i] = client;
						break;
					}
				}
			}
			else
			{
				// If a buddy is already assigned, check if bot is healthy enough and they are also buddies with us. If not, break the pairing.
				new i = BotBuddy[client];
				if (!IsBot(i) || GetEntProp(i, Prop_Send, "m_bIsOnThirdStrike") == 1)
				{
					BotBuddy[client] = -1;
					if (IsBot(i))
					{
						BotBuddy[i] = -1;
					}
				}
				else
				{
					if (BotBuddy[i] != client)
					{
						BotBuddy[client] = -1;
						BotBuddy[i] = -1;
					}
				}
				if (client == i)
				{
					BotBuddy[client] = -1;
				}
			}
		}
	}
}

public updateBotMove(client, Float:TOrigin[3])
{
	new Float:Origin[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);

	if (IsPlayerHeld(client) || IsPlayerIncap(client))
	{
		BotAction[client] = 0;	
	}
	if (BotAbortTick[client] > 0)
	{
		new Float:distance = GetVectorDistance(Origin, BotCheckPos[client]);
		if (distance < 15.0)
		{
			BotAbortTick[client] -= 1;
			if (BotAbortTick[client] == 0)
			{
				BotAction[client] = 6;
				BotAbortTick[client] = 60;
				BotAIUpdate[client] = 50;
				L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
				
				return;
			}
		}
		else
		{
			GetClientAbsOrigin(client, BotCheckPos[client]);
			BotAbortTick[client] = 60;
		}
	}

	if (BotAIUpdate[client] > 0)
	{
		BotAIUpdate[client] -= 1;
	}
	if (BotAIUpdate[client] <= 0)
	{
		L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", TOrigin[0], TOrigin[1], TOrigin[2], GetClientUserId(client));
		BotAIUpdate[client] = 10;
	}
}

public moveToEntity(client, item)
{
	new Float:target[3];
	GetEntPropVector(item, Prop_Send, "m_vecOrigin", target);
	
	updateBotMove(client, target);
}

// Check if Buddy Bot is going towards gas can but does not yet have it.
public bool:isBuddyGettingGas(b)
{
	if (IsBot(b) && BotTarget[b] > -1 && (BotAction[b] >= 0 && !IsHoldingGasCan(b)))
	{
		return true;
	}
	return false;
}

// Check if Buddy Bot is at any stage of gas can retrieval.
public bool:isBuddyBusy(b)
{
	if (IsBot(b) && BotAction[b] >= 0 && BotTarget[b] > -1)
	{
		return true;
	}
	return false;
}

// Buddy Bot AI. Executes Buddy AI Logic and returns true if so. This function is not responsible for checking validity of buddies. Use updateBotBuddy() to maintain correct buddy pairings.
public updateBuddyMove(client)
{
	if (!bScavengeBuddy || !IsBot(client))
	{
		return false;
	}
	
	new buddy = BotBuddy[client];
	new leader = -1;
	new escort = -1;
	
	// Figure out which bot is leader.
	if (client < buddy)
	{
		leader = client;
		escort = buddy;
	}
	else
	{
		leader = buddy;
		escort = client;
	}
	
	// If bot fetching gas is separated from buddy, try to regroup.
	if (isBuddyGettingGas(client) && getPlayerDistance(client, buddy) > 300)
	{
		// Leader has priority path-finding.
		if (client != leader || getPlayerDistance(client, buddy) > 600)
		{
			moveToEntity(client, buddy);
			return true;
		}
	}
	
	// If this bot has no assignment, we will follow the buddy if they do have one.
	if (!isBuddyBusy(client) && isBuddyBusy(buddy))
	{
		// Try to find a neighboring gas can to buddy's target or search for nearby one during return trip.
		new gas = -1;
		if (isBuddyGettingGas(buddy))
		{
			gas = assignBotGas(client, BotTarget[buddy], 600);
		}
		else if (isBuddyBusy(buddy))
		{
			gas = assignBotGas(client, buddy, 600);
		}
		if (gas > -1)
		{
			// Since Leader has priority, make sure leader goes for the farthest gas can first.
			if (getEntityDistance(GasNozzle, BotTarget[leader]) < getEntityDistance(GasNozzle, BotTarget[escort]))
			{
				gas = BotTarget[leader];
				BotTarget[leader] = BotTarget[escort];
				BotTarget[escort] = gas;
			}
		}
		
		
		if (isBuddyGettingGas(buddy))
		{
			moveToEntity(client, BotTarget[buddy]);
		}
		else
		{
			moveToEntity(client, buddy);
		}
		return true;
	}
	
	// If both bots are going to gas cans, the escort will follow leader.
	if (client == escort && isBuddyGettingGas(leader) && isBuddyGettingGas(escort))
	{
		moveToEntity(client, BotTarget[leader]);
		return true;
	}
	
	// If only one bot has gas can, follow buddy only if they are going to gas can.
	if (IsHoldingGasCan(client) && isBuddyGettingGas(buddy))
	{
		moveToEntity(client, BotTarget[buddy]);
		return true;
	}
	
	// If both bots have gas cans, carry gas back while trying to stay together.
	if (IsHoldingGasCan(client) && IsHoldingGasCan(buddy) && getEntityDistance(client, buddy) > 300)
	{
		// Leader has priority if bots end up taking two different paths back home.
		if (client != leader || getEntityDistance(client, buddy) > 600)
		{
			moveToEntity(client, buddy);
			return true;
		}
	}
	
	return false;
}

stock bool:isBuddyNeeded(client)
{
	if (bScavengeBuddy)
	{
		new b = BotBuddy[client];
		if (IsBot(b) && (IsPlayerIncap(b) || IsPlayerHeld(b)))
		{
			return true;
		}
	}
	return false;
}

public bool:shouldEscortFight(client)
{
	if (IsAssistNeeded() || isBuddyNeeded(client) || isCommonNearby(client, 50) || isBuddyNeeded(client) || shouldCover(client) || (isInfectedSighted(client) && isTankActive()) || getPlayerDistance(client, BotBuddy[client]) < 50)
	{
		return true;
	}
	return false;
}

stock BotAI(client)
{
	if (IsBot(client) && bScavengeInProgress || IsBot(client) && bFinaleScavengeInProgress || IsBot(client) && bScavengeGameInProgress)
	{
		//PrintToChatAll("client %N, action %i, target %i", client, BotAction[client], BotTarget[client]);
		
		new b = -1;
		if (bScavengeBuddy && BotAction[client] > -1)
		{
			updateBotBuddy(client);
			b = BotBuddy[client];
		}
		
		if (BotAction[client] == -1)
		{
			new entity = -1;
			while ((entity = FindEntityByClassname(entity, "weapon_gascan")) != INVALID_ENT_REFERENCE)
			{
				if (IsValidGasCan(entity) && !IsGasCanOwned(entity))
				{
					BotTarget[client] = -1;
					BotAction[client] = 0;
					BotAIUpdate[client] = -1;
					BotUseGasCan[client] = -1;
					BotAbortTick[client] = -1;
					for (new i=0; i<=2; i++)
					{
						BotCheckPos[client][i] = 0.0;
					}
				}
			}
		}
		else if (BotAction[client] == 0)
		{
			if (!IsPlayerHeld(client) && !IsPlayerIncap(client))
			{
				// Buddy System instructions have priority and will interrupt non-buddy logic flow.
				if (bScavengeBuddy && IsBot(b))
				{
					if (updateBuddyMove(client))
					{
						BotAction[client] = 1;
						return;
					}
				}
				
				if (BotTarget[client] > 0)
				{
					new entity = BotTarget[client];
					if (IsGasCan(entity))
					{
						decl Float:TOrigin[3];
						GetEntPropVector(entity, Prop_Send, "m_vecOrigin", TOrigin);
						L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", TOrigin[0], TOrigin[1], TOrigin[2], GetClientUserId(client));
						BotAction[client] = 1;
						BotAIUpdate[client] = 10;
						BotUseGasCan[client] = -1;
						BotAbortTick[client] = 50;
						GetClientAbsOrigin(client, BotCheckPos[client]);
					}
					else
					{
						BotTarget[client] = -1;
					}
				}
				else
				{
					// Try to find gas next to us.
					if (assignBotGas(client, client, 500) > -1)
					{
						return;
					}
					
					// Find gas can near where other survivors are headed if none nearby.
					for (new i=1; i<=MaxClients; i++)
					{
						if (i != client && BotTarget[i] > -1 && IsBot(i) && !IsPlayerIncap(i) && !IsPlayerHeld(i) && isBuddyGettingGas(i))
						{
							if (assignBotGas(client, BotTarget[i], -1) > -1)
							{
								return;
							}
						}
					}
					
					// If no one has any ideas for locations to search, search the entire map for a gas can.
					if (assignBotGas(client, client, -1) > -1)
					{
						return;
					}
					else
					{
						BotAction[client] = -1;
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
						return;
					}
					
					new Float:Origin[3], Float:TOrigin[3], Float:SOrigin[3], Float:distance = 0.0, Float:storeddist = 0.0, storedent = 0;
					GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
					new entity = -1;
					while ((entity = FindEntityByClassname(entity, "weapon_gascan")) != INVALID_ENT_REFERENCE)
					{
						if (IsValidGasCan(entity) && !IsGasCanOwned(entity))
						{
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", TOrigin);
							distance = GetVectorDistance(Origin, TOrigin);
							if (storeddist == 0.0 || storeddist > distance)
							{
								storedent = entity;
								storeddist = distance;
								GetEntPropVector(entity, Prop_Send, "m_vecOrigin", SOrigin);
							}
						}
					}
					if (storedent > 0 && IsValidGasCan(storedent) && !IsGasCanOwned(storedent))
					{
						BotTarget[client] = storedent;
						L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", SOrigin[0], SOrigin[1], SOrigin[2], GetClientUserId(client));
						BotAction[client] = 1;
						BotAIUpdate[client] = 10;
						BotUseGasCan[client] = -1;
						BotAbortTick[client] = 50;
						GetClientAbsOrigin(client, BotCheckPos[client]);
					}
					else
					{
						BotAction[client] = -1;
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
					}
				}
			}
		}
		else if (BotAction[client] == 1)
		{
			decl Float:Origin[3], Float:TOrigin[3];
			
			// Buddy system logic interrupts non-buddy logic
			if (bScavengeBuddy && IsBot(b))
			{
				if (updateBuddyMove(client))
				{
					return;
				}
			}
			
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			new entity = BotTarget[client];
			if (IsGasCan(entity) && !IsGasCanOwned(entity))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", TOrigin);
			}
			else
			{
				BotTarget[client] = -1;
				BotAction[client] = 0;
			}
			if (IsPlayerHeld(client) || IsPlayerIncap(client))
			{
				BotAction[client] = 0;	
			}
			if (BotAbortTick[client] > 0)
			{
				new Float:distance = GetVectorDistance(Origin, BotCheckPos[client]);
				if (distance < 15.0)
				{
					BotAbortTick[client] -= 1;
					if (BotAbortTick[client] == 0)
					{
						// BotTarget[client] = -1;
						BotAction[client] = 6;
						BotAbortTick[client] = 60;
						BotAIUpdate[client] = 50;
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
					}
				}
				else
				{
					GetClientAbsOrigin(client, BotCheckPos[client]);
					BotAbortTick[client] = 60;
				}
			}
			if (BotAIUpdate[client] > 0)
			{
				BotAIUpdate[client] -= 1;
				if (BotAIUpdate[client] == 0)
				{
					if (entity > 0 && IsValidEntity(entity))
					{
						L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", TOrigin[0], TOrigin[1], TOrigin[2], GetClientUserId(client));
						BotAIUpdate[client] = 10;
					}
				}
			}
			new Float:distance = GetVectorDistance(Origin, TOrigin);
			if (distance < 50.0)
			{
				PickupGasCan(client, entity);
			}
			else
			{
				decl Float:ZOrigin[3];
				ZOrigin[0] = Origin[0];
				ZOrigin[1] = Origin[1];
				ZOrigin[2] = Origin[2] + 40.0;
				distance = GetVectorDistance(ZOrigin, TOrigin);
				if (distance < 50.0)
				{
					PickupGasCan(client, entity);
				}
				else
				{
					ZOrigin[2] = Origin[2] - 40.0;
					distance = GetVectorDistance(ZOrigin, TOrigin);
					if (distance < 50.0)
					{
						PickupGasCan(client, entity);
					}
				}
			}
		}
		else if (BotAction[client] == 2)
		{
			if (!IsPlayerHeld(client) && !IsPlayerIncap(client) && IsGasCan(IsHoldingGasCan(client)) && !bScavengeInProgress && bFinaleScavengeInProgress && !bScavengeGameInProgress)
			{
				L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", NozzleOrigin[0], NozzleOrigin[1], NozzleOrigin[2], GetClientUserId(client));
				BotAction[client] = 3;
				BotAIUpdate[client] = 10;
				BotAbortTick[client] = 50;
				GetClientAbsOrigin(client, BotCheckPos[client]);
			}
			else if (!IsPlayerHeld(client) && !IsPlayerIncap(client) && IsGasCan(IsHoldingGasCan(client)) && bScavengeInProgress && !bFinaleScavengeInProgress && !bScavengeGameInProgress)
			{
				L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", NozzleOrigin2[0], NozzleOrigin2[1], NozzleOrigin2[2], GetClientUserId(client));
				BotAction[client] = 3;
				BotAIUpdate[client] = 10;
				BotAbortTick[client] = 50;
				GetClientAbsOrigin(client, BotCheckPos[client]);
			}
			else if (!IsPlayerHeld(client) && !IsPlayerIncap(client) && IsGasCan(IsHoldingGasCan(client)) && !bScavengeInProgress && !bFinaleScavengeInProgress && bScavengeGameInProgress)
			{
				L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", NozzleOrigin3[0], NozzleOrigin3[1], NozzleOrigin3[2], GetClientUserId(client));
				BotAction[client] = 3;
				BotAIUpdate[client] = 10;
				BotAbortTick[client] = 50;
				GetClientAbsOrigin(client, BotCheckPos[client]);
			}
			else
			{
				BotAction[client] = 0;
			}
		}
		else if (BotAction[client] == 3)
		{
			// Buddy system logic interrupts non-buddy logic
			if (bScavengeBuddy && IsBot(b))
			{
				if (updateBuddyMove(client))
				{
					return;
				}
			}
		
			if (IsPlayerHeld(client) || IsPlayerIncap(client) || IsHoldingGasCan(client) == 0)
			{
				BotAction[client] = 0;	
			}
			if (BotAbortTick[client] > 0)
			{
				decl Float:Origin[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				new Float:distance = GetVectorDistance(Origin, BotCheckPos[client]);
				if (distance < 15.0)
				{
					BotAbortTick[client] -= 1;
					if (BotAbortTick[client] == 0)
					{
						// BotTarget[client] = -1;
						BotAction[client] = 6;
						BotAbortTick[client] = 60;
						BotAIUpdate[client] = 50;
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
					}
				}
				else
				{
					GetClientAbsOrigin(client, BotCheckPos[client]);
					BotAbortTick[client] = 60;
				}
			}
			if (BotAIUpdate[client] > 0 && !bScavengeInProgress && bFinaleScavengeInProgress && !bScavengeGameInProgress)
			{
				BotAIUpdate[client] -= 1;
				if (BotAIUpdate[client] == 0)
				{
					L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", NozzleOrigin[0], NozzleOrigin[1], NozzleOrigin[2], GetClientUserId(client));
					BotAIUpdate[client] = 10;
				}
			}
			if (BotAIUpdate[client] > 0 && bScavengeInProgress && !bFinaleScavengeInProgress && !bScavengeGameInProgress)
			{
				BotAIUpdate[client] -= 1;
				if (BotAIUpdate[client] == 0)
				{
					L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", NozzleOrigin2[0], NozzleOrigin2[1], NozzleOrigin2[2], GetClientUserId(client));
					BotAIUpdate[client] = 10;
				}
			}
			if (BotAIUpdate[client] > 0 && !bScavengeInProgress && !bFinaleScavengeInProgress && bScavengeGameInProgress)
			{
				BotAIUpdate[client] -= 1;
				if (BotAIUpdate[client] == 0)
				{
					L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})", NozzleOrigin3[0], NozzleOrigin3[1], NozzleOrigin3[2], GetClientUserId(client));
					BotAIUpdate[client] = 10;
				}
			}
			decl Float:Origin[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			new Float:distance = GetVectorDistance(Origin, NozzleOrigin);
			if (distance < 50.0)
			{
				if (BotUseGasCan[client] == -1)
				{
					BotUseGasCan[client] = 1;
				}
			}
			decl Float:Origin2[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin2);
			new Float:distance2 = GetVectorDistance(Origin2, NozzleOrigin2);
			if (distance2 < 50.0)
			{
				if (BotUseGasCan[client] == -1)
				{
					BotUseGasCan[client] = 1;
				}
			}
			decl Float:Origin3[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin3);
			new Float:distance3 = GetVectorDistance(Origin3, NozzleOrigin3);
			if (distance3 < 50.0)
			{
				if (BotUseGasCan[client] == -1)
				{
					BotUseGasCan[client] = 1;
				}
			}
		}
		else if (BotAction[client] == 4)
		{
			if (!IsAssistNeeded())
			{
				if (IsGasCan(BotTarget[client]) && getEntityDistance(client, BotTarget[client]) > 750)
				{
					BotTarget[client] = -1;
				}
				BotAction[client] = 0;
			}
		}
		else if (BotAction[client] == 5)
		{
			if (!IsPlayerHeld(client) && !IsPlayerIncap(client) && !shouldBotFight(client))
			{
				if (GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike") == 0)
				{
					BotAction[client] = 0;
				}
			}
			
			// If bot needs to heal, abandon the gas can to a healthier bot or simply get back to it later.
			if ((!bScavengeBuddy && shouldHeal(client)) || GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike") == 1)
			{
				BotTarget[client] = -1;
			}
		}
		else if (BotAction[client] == 6)
		{
			if (BotAIUpdate[client] > 0)
			{
				BotAIUpdate[client] -= 1;
				if (BotAIUpdate[client] == 0)
				{
					BotAction[client] = 0;
				}
			}
		}
	}
}

stock PickupGasCan(client, entity)
{
	if (IsBot(client) && entity > 0 && IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "Use", client);
		BotAction[client] = 2;
	}
}
stock bool:IsAssistNeeded()
{
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsSurvivor(i))
		{
			if (IsPlayerIncap(i) || IsPlayerHeld(i))
			{
				if (bScavengeBuddy && !isTankActive())
				{
					new b = BotBuddy[i];
					if (IsBot(b) && !IsPlayerIncap(b) && !IsPlayerHeld(b) && getPlayerDistance(i, b) < 800)
					{
						return false;
					}
				}
				return true;
			}
		}
	}
	return false;
}

stock bool:isGhost(i)
{
	return bool:GetEntProp(i, Prop_Send, "m_isGhost");
}

stock bool:isInfected(i)
{
	return i > 0 && i <= MaxClients && IsClientInGame(i) && GetClientTeam(i) == 3 && !isGhost(i);
}

// Calculate the angles from client to target
stock computeAimAngles(client, target, Float:angles[3], type = 1)
{
	new Float:target_pos[3];
	new Float:self_pos[3];
	new Float:lookat[3];
	
	GetClientEyePosition(client, self_pos);
	switch (type) {
		case 1: { // Eye (Default)
			GetClientEyePosition(target, target_pos);
		}
		case 2: { // Body
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", target_pos);
		}
		case 3: { // Chest
			GetClientAbsOrigin(target, target_pos);
			target_pos[2] += 45.0;
		}
	}
	MakeVectorFromPoints(self_pos, target_pos, lookat);
	GetVectorAngles(lookat, angles);
}

public bool:traceFilter(entity, mask, any:self)
{
	return entity != self;
}

// Determine if the head of the target can be seen from the client
stock bool:isVisibleTo(client, target)
{
	new bool:ret = false;
	new Float:aim_angles[3];
	new Float:self_pos[3];
	
	GetClientEyePosition(client, self_pos);
	computeAimAngles(client, target, aim_angles);
	
	new Handle:trace = TR_TraceRayFilterEx(self_pos, aim_angles, MASK_VISIBLE, RayType_Infinite, traceFilter, client);
	if (TR_DidHit(trace)) {
		new hit = TR_GetEntityIndex(trace);
		if (hit == target) {
			ret = true;
		}
	}
	CloseHandle(trace);
	return ret;
}

/* Determine if the head of the entity can be seen from the client */
stock bool:isVisibleToEntity(target, client)
{
	new bool:ret = false;
	new Float:aim_angles[3];
	new Float:self_pos[3], Float:target_pos[3];
	new Float:lookat[3];
	
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", target_pos);
	GetClientEyePosition(client, self_pos);
	
	MakeVectorFromPoints(target_pos, self_pos, lookat);
	GetVectorAngles(lookat, aim_angles);
	
	new Handle:trace = TR_TraceRayFilterEx(target_pos, aim_angles, MASK_VISIBLE, RayType_Infinite, traceFilter, target);
	if (TR_DidHit(trace)) {
		new hit = TR_GetEntityIndex(trace);
		if (hit == client) {
			ret = true;
		}
	}
	CloseHandle(trace);
	return ret;
}

public getPlayerDistance(x, y)
{
	new Float:xPos[3];
	new Float:yPos[3];
	
	GetClientAbsOrigin(x, xPos);
	GetClientAbsOrigin(y, yPos);
	
	return RoundToNearest(GetVectorDistance(xPos, yPos, false));
}

public getEntityDistance(client, target)
{
	if (!IsValidEntity(client) || !IsValidEntity(target))
	{
		return -1;
	}
	new Float:selfPos[3];
	new Float:targetPos[3];
	
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", selfPos);
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetPos);
	
	return RoundToNearest(GetVectorDistance(selfPos, targetPos, false));
}

public bool:isInfectedSighted(client)
{
	for (new x = 1; x <= MaxClients; x++)
	{
		// If we see SI, we only worry if it is close enough, but if tank is active we should not take any chances.
		new iDist = 750;
		if (isInfected(x) && IsPlayerAlive(x) && isVisibleTo(client, x) && ((getPlayerDistance(client, x) < iDist) || isTankActive()))
		{
			return true;
		}
	}
	return false;
}

stock bool:IsCommonInfected(iEntity)
{
	if (iEntity && IsValidEntity(iEntity))
	{
		new String:strClassName[64];
		GetEntityClassname(iEntity, strClassName, sizeof(strClassName));
		
		if (StrContains(strClassName, "infected", false) > -1)
			return true;
	}
	return false;
}

public bool:isCommonNearby(client, dist)
{
	for (new iEntity = MaxClients+1; iEntity <= 2048; ++iEntity) {
		if (IsCommonInfected(iEntity)
			&& GetEntProp(iEntity, Prop_Data, "m_iHealth") > 0
			&& isVisibleToEntity(iEntity, client))
		{
			new Float:selfPos[3];
			new Float:commonPos[3];
			
			GetClientAbsOrigin(client, selfPos);
			GetEntPropVector(iEntity, Prop_Data, "m_vecAbsOrigin", commonPos);
			
			if (RoundToNearest(GetVectorDistance(selfPos, commonPos, false)) < dist)
			{
				return true;
			}
		}
	}
	return false;
}

public bool:isTankActive()
{
	for (new x = 1; x <= MaxClients; x++)
	{
		if (isInfected(x) && IsPlayerAlive(x))
		{
			new zombieClass = GetEntProp(x, Prop_Send, "m_zombieClass");
			if (zombieClass == 8) {
				return true;
			}
		}
	}
	return false;
}

public bool:hasHealthItem(client)
{
	new hasMedkit = false;
	new aidItem = GetPlayerWeaponSlot(client, 3);
	if (IsValidEdict(aidItem))
	{
		new String:item[128];
		GetEntityClassname(aidItem, item, sizeof(item));
		
		if (StrContains(item, "weapon_first_aid_kit", false) > -1)
		{
			hasMedkit = true;
		}
	}
	
	new hasTempHP = IsValidEdict(GetPlayerWeaponSlot(client, 4));
	
	if (hasMedkit || hasTempHP)
	{
		return true;
	}
	
	return false;
}

public botHP(client)
{
	new baseHP = GetEntProp(client, Prop_Send, "m_iHealth");
	new tempHP = RoundToNearest(GetEntPropFloat(client, Prop_Send, "m_healthBuffer"));
	
	return baseHP + tempHP;
}

public bool:isLowHP(client)
{
	new baseHP = GetEntProp(client, Prop_Send, "m_iHealth");
	new Float:tempHP = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	
	tempHP = tempHP * hpMultiplier;
	
	if (baseHP + tempHP <= 30)
	{
		return true;
	}
	return false;
}

public bool:shouldHeal(client)
{
	if (hasHealthItem(client) && isLowHP(client) && !isTankActive())
	{
		return true;
	}
	return false;
}

// Should bots stick together if one of them needs healing?
public bool:shouldCover(client)
{
	if (isTankActive())
	{
		return false;
	}
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsBot(i) && !IsPlayerIncap(i) && !IsPlayerHeld(i))
		{
			if ((isLowHP(client) || isLowHP(i)) && isVisibleTo(client, i) && getPlayerDistance(client, i) < 500 && (hasHealthItem(client) || hasHealthItem(i)))
			{
				return true;
			}
		}
	}
	return false;
}

public bool:isGasCanClose(client, gas)
{
	if (IsGasCan(gas) && getEntityDistance(client, gas) < 200)
	{
		return true;
	}
	return false;
}

public bool:shouldBotFight(client)
{	
	// If Bot is not currently engaged we fight only when important enemy appears
	if (BotAction[client] != 4 && BotAction[client] != 5)
	{
		if (IsAssistNeeded() || shouldHeal(client) || isInfectedSighted(client) || shouldCover(client) || isBuddyNeeded(client) || (BotAction[client] != -1 && BotAction[client] != 3 && isCommonNearby(client, 100) && !isGasCanClose(client, BotTarget[client])))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		// If Bot is already fighting, we do not stop until all threats are cleared.
		if (!isInfectedSighted(client) && !IsAssistNeeded() && !shouldHeal(client) && !isCommonNearby(client, 100) && !shouldCover(client) && !isBuddyNeeded(client))
		{
			return false;
		}
		else
		{
			return true;
		}
	}
}

public OnPreThink(client)
{
	if (bScavengeBotsDS)
	{
		if (IsBot(client))
		{
			// Drop extra gas cans if scavenge ended. Only relevant in singleplayer where required gas cans are fewer than available.
			if (IsBot(client) && IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client) && !bScavengeInProgress && !bFinaleScavengeInProgress && !bScavengeGameInProgress)
			{
				new buttons = GetClientButtons(client);
				SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
				ResetClientArrays(client);
			}
			
			// If bot loses track of holding gas can, we fix the assignment.
			new holdGas = IsHoldingGasCan(client);
			if (BotTarget[client] == -1 && holdGas > 0)
			{
				BotTarget[client] = holdGas;
				BotAction[client] = 3;
			}
			
			// Stop collecting cans if any significant danger to team is present
			if (!IsPlayerHeld(client) && !IsPlayerIncap(client) && shouldBotFight(client))
			{
				// Drop can if special infected on the field and bot is not in SI kill-mode.
				if (IsGasCan(IsHoldingGasCan(client)))
				{
					new buttons = GetClientButtons(client);
					SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
				}
				
				if (BotAction[client] != -1 && BotAction[client] != 4 && BotAction[client] != 5)
				{
					if (IsAssistNeeded())
					{
						BotAction[client] = 4;
					}
					else
					{
						BotAction[client] = 5;
						
					}
					BotAIUpdate[client] = 10;
					L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
				}
			}
			
			// Double check Bot Update timers are active when we need them
			if (BotAction[client] > 0 && BotAIUpdate[client] < 0)
			{
				BotAIUpdate[client] = 0;
			}
		
			if (BotAction[client] == 1)
			{
				if (GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike") == 1 || shouldHeal(client))
				{
					BotAction[client] = 5;
					L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
				}
				new threats = GetEntProp(client, Prop_Send, "m_hasVisibleThreats");
				if (threats > 0)
				{
					
					// Blindly Shoot to kill
					new buttons = GetClientButtons(client);
					SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
				}
				
				// Fix Rare error where bot is searching for gas can while already holding one.
				if (IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client))
				{
					new buttons = GetClientButtons(client);
					SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
					BotAction[client] = 5;
					BotTarget[client] = -1;
					L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
				}
			}
			else if (BotAction[client] == 2)
			{
				if (IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client))
				{
					new threats = GetEntProp(client, Prop_Send, "m_hasVisibleThreats");
					if (threats > 0)
					{
						new buttons = GetClientButtons(client);
						SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK2);
					}
					if (IsAssistNeeded())
					{
						new buttons = GetClientButtons(client);
						SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
						BotAction[client] = 4;
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
					}
				}
			}
			else if (BotAction[client] == 3)
			{
				if (BotUseGasCan[client] == 1)
				{
					if (IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client) && !bScavengeInProgress && bFinaleScavengeInProgress && !bScavengeGameInProgress)
					{
						new owner = GetEntPropEnt(GasNozzle, Prop_Send, "m_useActionOwner");
						if (owner <= 0)
						{
							TeleportEntity(client, NozzleOrigin, NozzleAngles, NULL_VECTOR);
							new buttons = GetClientButtons(client);
							SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
						}
						else
						{
							new entity = GetEntPropEnt(owner, Prop_Send, "m_hOwner");
							if (entity == client)
							{
								new buttons = GetClientButtons(client);
								SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
							}
						} 
					}
					else if (IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client) && bScavengeInProgress && !bFinaleScavengeInProgress && !bScavengeGameInProgress)
					{
						new owner = GetEntPropEnt(GasNozzle, Prop_Send, "m_useActionOwner");
						if (owner <= 0)
						{
							TeleportEntity(client, NozzleOrigin2, NozzleAngles2, NULL_VECTOR);
							new buttons = GetClientButtons(client);
							SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
						}
						else
						{
							new entity = GetEntPropEnt(owner, Prop_Send, "m_hOwner");
							if (entity == client)
							{
								new buttons = GetClientButtons(client);
								SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
							}
						} 
					}
					else if (IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client) && !bScavengeInProgress && !bFinaleScavengeInProgress && bScavengeGameInProgress)
					{
						new owner = GetEntPropEnt(GasNozzle, Prop_Send, "m_useActionOwner");
						if (owner <= 0)
						{
							TeleportEntity(client, NozzleOrigin3, NozzleAngles3, NULL_VECTOR);
							new buttons = GetClientButtons(client);
							SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
						}
						else
						{
							new entity = GetEntPropEnt(owner, Prop_Send, "m_hOwner");
							if (entity == client)
							{
								new buttons = GetClientButtons(client);
								SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
							}
						} 
					}
				}
				else
				{
					new threats = GetEntProp(client, Prop_Send, "m_hasVisibleThreats");
					if (threats > 0)
					{
						new buttons = GetClientButtons(client);
						SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK2);
					}
					if (IsAssistNeeded() || GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike") == 1)
					{
						new buttons = GetClientButtons(client);
						SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
						BotAction[client] = 4;
						L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
					}
				}
			}
			else if (BotAction[client] == 6)
			{
				if (IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client))
				{
					new buttons = GetClientButtons(client);
					SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
				}
			}
		}
	}
	else if (IsBot(client) && IsGasCan(IsHoldingGasCan(client)) && !IsPlayerHeld(client) && !IsPlayerIncap(client))
	{
		// Drop cans if mod is disabled
		new buttons = GetClientButtons(client);
		SetEntProp(client, Prop_Data, "m_nButtons", buttons|IN_ATTACK);
		L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(client));
		
		if (BotAction[client] != -1)
		{
			ResetClientArrays(client);
		}
	}
}
public OnUseStarted(const String:output[], entity, activator, Float:delay)
{
	new gascan = GetEntPropEnt(entity, Prop_Send, "m_useActionOwner");
	if (gascan > 0 && IsValidEntity(gascan))
	{
		new client = GetEntPropEnt(gascan, Prop_Send, "m_hOwner");
		if (client > 0 && IsValidEntity(client))
		{
			SetEntProp(entity, Prop_Data, "m_iHammerID", client);
		}
	}
}
public OnUseCancelled(const String:output[], entity, activator, Float:delay)
{
	if (entity > 0 && IsValidEntity(entity))
	{
		new client = GetEntProp(entity, Prop_Data, "m_iHammerID");
		if (IsBot(client))
		{
			BotUseGasCan[client] = -1;
			//PrintToChatAll("client %N cancel", client);
		}
	}
}
public OnUseFinished(const String:output[], entity, activator, Float:delay)
{
	if (entity > 0 && IsValidEntity(entity))
	{
		new client = GetEntProp(entity, Prop_Data, "m_iHammerID");
		if (IsBot(client))
		{
			BotTarget[client] = -1;
			BotAction[client] = 0;
			BotAIUpdate[client] = -1;
			BotUseGasCan[client] = -1;
			//PrintToChatAll("client %N finish", client);
		}
	}
}
stock bool:IsPlayerIncap(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	return false;
}
stock bool:IsPlayerHeld(client)
{
	new jockey = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	new charger = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	new hunter = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	new smoker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (jockey > 0 || charger > 0 || hunter > 0 || smoker > 0)
	{
		return true;
	}
	return false;
}
stock bool:IsSurvivor(client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		return true;
	}
	return false;
}
stock bool:IsBot(client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsSurvivor(client) && IsFakeClient(client) && IsPlayerAlive(client))
		{
			new String:classname[16];
			GetEntityNetClass(client, classname, sizeof(classname));
			if (StrEqual(classname, "SurvivorBot", false))
			{
				return true;
			}
		}
	}
	return false;
}
stock bool:IsGasCan(entity)
{
	if (entity > 32 && IsValidEntity(entity))
	{
		decl String: classname[16];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "weapon_gascan", false))
			return true;
	}
	return false;
}
stock bool:IsValidGasCan(entity)
{
	for (new i=1; i<=MaxClients; i++)
	{
		// Added IsBot() check so that dead bots don't claim gas cans.
		if (IsBot(i) && BotTarget[i] > 0)
		{
			if (BotTarget[i] == entity)
			{
				return false;
			}
		}
	}
	return true;
}
stock bool:IsGasCanOwned(entity)
{
	if (IsGasCan(entity))
	{
		new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwner");
		if (owner > 0)
		{
			return true;
		}
	}
	return false;
}
stock IsHoldingGasCan(client)
{
	if (IsBot(client))
	{
		new entity = GetPlayerWeaponSlot(client, 5);
		if (entity > 0 && IsValidEntity(entity))
		{
			decl String:classname[24];
			GetEdictClassname(entity, classname, sizeof(classname));
			if (StrEqual(classname, "weapon_gascan", false))
			{
				return entity;
			}
		}
	}
	return 0;
}
stock RGB_TO_INT(red, green, blue) 
{
	return (blue * 65536) + (green * 256) + red;
}
stock ScriptCommand(client, const String:command[], const String:arguments[], any:...)
{
	new String:vscript[PLATFORM_MAX_PATH];
	VFormat(vscript, sizeof(vscript), arguments, 4);	

	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags ^ FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, vscript);
	SetCommandFlags(command, flags | FCVAR_CHEAT);
}

stock bool:IsScavenge()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "scavenge", false) > -1)
		return true;
	return false;
}

stock bool:IsCoop()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "coop", false) > -1)
		return true;
	return false;
}
stock bool:IsInvalidMap()
{
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	if (StrEqual(mapname, "l4d2_pl_badwater", true))
	{
		return true;
	}
	return false;
}
stock L4D2_RunScript(const String:sCode[], any:...)
{
	static iScriptLogic = INVALID_ENT_REFERENCE;
	if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic)) 
	{
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			SetFailState("Could not create 'logic_script'");
		
		DispatchSpawn(iScriptLogic);
	}
	
	static String:sBuffer[512];
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2);
	
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}
