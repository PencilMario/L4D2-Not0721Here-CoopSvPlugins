public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	// ----------------------------------------------------------------------------------------------------
	// GAMEDATA RELATED
	// ----------------------------------------------------------------------------------------------------
	Handle hGameConfig = LoadGameConfigFile("l4d2_improved_bots");
	if (!hGameConfig)SetFailState("Failed to find 'l4d2_improved_bots.txt' game config.");

	CreateAllSDKCalls(hGameConfig);
	CreateAllDetours(hGameConfig);

	delete hGameConfig;

	// ----------------------------------------------------------------------------------------------------
	// DATA / PREFERENCES
	// ----------------------------------------------------------------------------------------------------

	ParseDataFile();

	// ----------------------------------------------------------------------------------------------------
	// EVENT HOOKS
	// ----------------------------------------------------------------------------------------------------
	HookEvent("round_start", 			Event_OnRoundStart);
	HookEvent("round_end", 				Event_OnRoundEnd);
	HookEntityOutput("func_door", "OnOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door", "OnClose", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door", "OnFullyOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door", "OnFullyClosed", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door", "OnOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door", "OnClose", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door", "OnFullyOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door", "OnFullyClosed", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door_rotating", "OnOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door_rotating", "OnClose", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door_rotating", "OnFullyOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("func_door_rotating", "OnFullyClosed", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door_rotating", "OnOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door_rotating", "OnClose", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door_rotating", "OnFullyOpen", Event_OnTraceDoorStateChanged);
	HookEntityOutput("prop_door_rotating", "OnFullyClosed", Event_OnTraceDoorStateChanged);

	HookEvent("weapon_fire", 			Event_OnWeaponFire);
	HookEvent("player_death", 			Event_OnPlayerDeath);
	HookEvent("player_spawn", 			Event_OnPlayerSpawn);
	HookEvent("player_team", 			Event_OnPlayerTeam);
	HookEvent("player_bot_replace", 	Event_OnPlayerReplacement);
	HookEvent("bot_player_replace", 	Event_OnPlayerReplacement);
	HookEvent("player_use",				Event_OnPlayerUse);

	HookEvent("player_incapacitated_start",	Event_OnIncap);
	HookEvent("revive_success",			Event_OnRevive);
	HookEvent("defibrillator_used",		Event_OnRevive);

	HookEvent("lunge_pounce", 			Event_OnSurvivorGrabbed);
	HookEvent("tongue_grab", 			Event_OnSurvivorGrabbed);
	HookEvent("jockey_ride", 			Event_OnSurvivorGrabbed);
	HookEvent("charger_carry_start", 	Event_OnSurvivorGrabbed);
	HookEvent("charger_pummel_start", 	Event_OnSurvivorGrabbed);
	HookEvent("pounce_end", 			Event_OnSurvivorReleased);
	HookEvent("tongue_release", 		Event_OnSurvivorReleased);
	HookEvent("jockey_ride_end", 		Event_OnSurvivorReleased);
	HookEvent("charger_carry_end", 	Event_OnSurvivorReleased);
	HookEvent("charger_pummel_end", 	Event_OnSurvivorReleased);

	HookEvent("charger_charge_start",	Event_OnChargeStart);

	HookEvent("witch_harasser_set", 	Event_OnWitchHaraserSet);

	RegAdminCmd("sm_ibcvars",	CmdDumpCvars,	ADMFLAG_GENERIC, "Dump some cvars");
	//RegAdminCmd("sm_ibsubject",	CmdSetTestSubj, ADMFLAG_GENERIC, "Set player to test against");

	// ----------------------------------------------------------------------------------------------------
	// CONSOLE VARIABLES
	// ----------------------------------------------------------------------------------------------------
	CreateAndHookConVars();
	AutoExecConfig(true, "l4d2_improved_bots");

	// ----------------------------------------------------------------------------------------------------
	// MISC
	// ----------------------------------------------------------------------------------------------------
	if (g_bLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))continue;
			OnClientJoinServer(i);
		}
	}

	g_bExtensionActions = LibraryExists("actionslib");

	g_hPerformanceLogger = new Logger("sb_ai_performance", LoggerType_NewLogFile);

	if (!g_bInitItemFlags)
	{
		InitItemFlagMap();
		PrintToServer("OnPluginStart: init g_hItemFlagMap");
	}
}
