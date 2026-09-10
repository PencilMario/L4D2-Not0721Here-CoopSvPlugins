#define PL_FILENAME			"entity_guard"
#define PL_VERSION			"1.0.1"
#define PL_URL				"https://forums.alliedmods.net/showthread.php?t=352673"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// Obsolete
///#define SUPPRESS_TRANSMIT

#define FLAGS_CVAR			FCVAR_NOTIFY
#define FLAGS_CVAR_VERSION	FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_SPONLY
#define FLAGS_COMMAND_BASIC	ADMFLAG_GENERIC
#define FLAGS_NOTIFY		ADMFLAG_GENERIC

#define MAX_ENTITIES		2048 // 1 << 11
#define PL_TAG				"[Entity Guard] "

#define MIN_LOG_SPIKE_SPAWN	5
#define MIN_SEC_HIGH_SPAWN	50
#define MIN_SEC_ENT_LEAK	150
#define MIN_SEC_ENT_JUMP	200

#define QUARANTINE_CONSEC	3
#define QUARANTINE_STRIKE	3
#define QUARANTINE_FORGIVE	10
#define QUARANTINE_SUSPECT	80
#define QUARANTINE_TRIGGER	100

#define MAX_LEN_CLASSNAME	48
#define MAX_LEN_MAP_NAME	48
#define MAX_LEN_CONFIG		64
#define MAX_LEN_LARGE_BUFF	4096
#define MAX_LEN_REPORT		8192

#define WAIT_SOFT_DELETE	0.5
#define WAIT_AUDIT_START	2.0
#define WAIT_TICK_CLEANUP	10

#define OFFSET_CRITICAL		64
#define OFFSET_HARD			144
#define OFFSET_SOFT			240
#define OFFSET_CLEANUP		272

#define OFFSET_CLEANUP_BAN	128
#define OFFSET_SLAY_BAN		OFFSET_HARD
#define CLEAN_UNBAN_BUFFER	40

#define STR_CRITICAL		"CRITICAL"
#define STR_HARD			"Hard"
#define STR_SOFT			"Soft"
#define STR_SAFE			"Optimal"
#define STR_CLEANUP			"Cleanup"
#define STR_CLASS_UNKNOWN	"class_unknown"

#define DELETE_SINGLE		1
#define DELETE_BATCH		5
#define DELETE_BATCH_CRIT	20

#define CLEANUP_RELAX		75
#define CLEANUP_PANIC		250

#define MAX_HEALTHY_QUEUE	3000
#define MODEL_STRESS_TEST	"models/error.mdl"

#define INVALID_REFERENCE	-1
#define LOG_SPACE			"                       : "

enum {Guard_Normal, Guard_Immediate};
enum {Janitor_Initial, Janitor_Resume};

enum ThresholdType {Threshold_None, Threshold_Critical, Threshold_Hard,
Threshold_Soft, Threshold_Cleanup};
enum CleaningStage {Cleaning_Blacklist, Cleaning_Slaughter, Cleaning_Done};

const int g_iEntLimit_Critical = MAX_ENTITIES - OFFSET_CRITICAL,
	g_iEntLimit_Hard = MAX_ENTITIES - OFFSET_HARD,
	g_iEntLimit_Soft = MAX_ENTITIES - OFFSET_SOFT,
	g_iCleaningPanic = (MAX_ENTITIES - OFFSET_CLEANUP) + 1, // Threshold/trigger
	g_iCleaningSafeLimit = MAX_ENTITIES - OFFSET_CLEANUP_BAN,
	g_iSlayCmdSafe = MAX_ENTITIES - OFFSET_SLAY_BAN;

ThresholdType g_iPanicThreshold;
#if defined SUPPRESS_TRANSMIT
ThresholdType g_iPendingType[MAX_ENTITIES];
#endif

CleaningStage g_iCleaningPhase;

char g_sPanicConfig[MAX_LEN_CONFIG];
char g_sLogPath[PLATFORM_MAX_PATH], g_sMapName[MAX_LEN_MAP_NAME],
g_sWarpClass[MAXPLAYERS + 1][MAX_LEN_CLASSNAME]; // Impossible to init!

int g_iPriorityMode, g_iGarbageReport, g_iCleanupLogMin;
int g_iCleaningType, g_iBlacklistJobs, g_iSlaughterJobs, g_iInitialPopulation,
g_iCreationTick[MAX_ENTITIES], g_iRoundSession = 0, g_iLastCensusSession = -1,
g_iPropSession = -1, g_iEntityCount = 0, g_iPeakCount = 0, g_iPendingMode = -1,
g_iDeathMarkedRef[MAX_ENTITIES] = {INVALID_REFERENCE, ...},
g_iRoundKillCount = 0, g_iRoundGarbageCount = 0, g_iTotalKept = 0,
g_iTotalDiscarded = 0, g_iWarpIndex[MAXPLAYERS + 1] = {-1, ...},
g_iWarpQueueType[MAXPLAYERS + 1] = {0, ...};

float g_fNotifyInterval, g_fDiagInterval;
float g_fLastDelete = 0.0;

bool g_bEnabled, g_bIgnoreWhitelist, g_bIgnoreBlacklist, g_bBlackPurgeHard,
g_bAuditClass, g_bAuditLeak, g_bCleanupLog;
bool g_bGuardPanic, g_bJanitorPanic, g_bIsInitPhase = false,
g_bCensusDone = false, g_bRoundEnded = false, g_bConfigLoaded = false,
g_bReportLogged = false, g_bCleaning = false, g_bCleaningBanned = false,
g_bGuardPending = false, g_bIgnorePlayer = false, g_bQuarantined = false,
g_bSyncPending = false, g_bLateLoaded = false, g_bAuditAllowed = false,
g_bAuditing = false, g_bIsManualCleanup = false, g_bStressTesting = false,
g_bFrameComplete = true;

ConVar g_hEnabled, g_hPriorityMode, g_hBlackPurgeHard, g_hIgnoreWhitelist,
g_hIgnoreBlacklist, g_hAuditClass, g_hAuditLeak, g_hNotifyInterval,
g_hDiagInterval, g_hCleanupLogMin, g_hCleanupLog, g_hGarbageReport,
g_hPanicThreshold, g_hPanicConfig;
ConVar g_hSvHibernation, g_hSmHibernation;

ArrayList g_hBlacklistQueue, g_hSlaughterQueue, g_hBlacklistBackup,
g_hSlaughterBackup, g_hDynamicWhitelist, g_hTrashPartials, g_hProtectedPartials,
g_hUniqueResults = null, g_hStressEntities = null;

StringMap g_hClassnameTracker, g_hConsecutiveSpawns, g_hQuarantineStrikes,
g_hWhitelistClasses, g_hBlacklistClasses, g_hBlacklistClasses_Frame, g_hTrashMap
, g_hProtectedMap, g_hQuarantineForbidden, g_hQueueStats = null,
g_hOriginalFlags = null, g_hStressLookup = null;

public Plugin myinfo =
{
	name = "Entity Guard: Overflow Crash Fix",
	author = "steeg",
	description = "Attempts to prevent 'Ed_Alloc: no free edict' crashes with automated cleanup and deep diagnostic tools.",
	version = PL_VERSION,
	url = PL_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary(PL_FILENAME);

	CreateNative("Guard_GetEdictCount", Native_GetEdictCount);
	CreateNative("Guard_GetPeakEdicts", Native_GetPeakEdicts);

	g_bLateLoaded = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("entity_guard_version", PL_VERSION, "Entity Guard version", FLAGS_CVAR_VERSION);
	g_hEnabled = CreateConVar("entity_guard_enabled", "1", "Enable Entity Guard (0: Off)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hPriorityMode = CreateConVar("entity_guard_priority_mode", "1", "Set removal priority (0: Oldest entities + purge blacklisted on spawn, 1: Oldest blacklisted, 2: Oldest Live-spawned blacklisted)", FLAGS_CVAR, true, 0.0, true, 2.0);
	g_hBlackPurgeHard = CreateConVar("entity_guard_black_purge", "0", "When mode is 0, purge blacklisted entities if the X threshold is hit (0: Soft, 1: Hard)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hIgnoreWhitelist = CreateConVar("entity_guard_ignore_whitelist", "0", "Skip whitelist check (NOT recommended) (0: Off)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hIgnoreBlacklist = CreateConVar("entity_guard_ignore_blacklist", "0", "Skip blacklist check (0: Off)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hAuditClass = CreateConVar("entity_guard_audit_class", "0", "Always audit entity classname count per second for analysis (0: Soft threshold only)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hAuditLeak = CreateConVar("entity_guard_audit_leak", "0", "Always audit total entity leak per second for analysis (0: Soft threshold only)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hNotifyInterval = CreateConVar("entity_guard_notify_interval", "60.0", "Cooldown in seconds to notify admins about threshold reached / entity kill (0: Off notification)", FLAGS_CVAR, true, 0.0);
	g_hDiagInterval = CreateConVar("entity_guard_diag_interval", "10.0", "Delay between auto-diagnostics. Lower values (e.g., 1.0) provide more data but slightly higher CPU usage.", FLAGS_CVAR, true, 1.0);
	g_hCleanupLog = CreateConVar("entity_guard_cleanup_log", "1", "Log sweet Janitor's queue(s) cleanup result (0: Off)", FLAGS_CVAR, true, 0.0, true, 1.0);
	g_hCleanupLogMin = CreateConVar("entity_guard_cleanup_log_min", "10", "Min. entities discarded to trigger a cleanup log. Aborts always log. (0: Log all activity)", FLAGS_CVAR, true, 0.0);
	g_hGarbageReport = CreateConVar("entity_guard_garbage_report", "2", "Set the condition to log garbage data in the end report (0: Off, 1: Garbage > 0, 2: Kills > 0 & garbage > 0)", FLAGS_CVAR, true, 0.0, true, 2.0);
	g_hPanicThreshold = CreateConVar("entity_guard_panic_threshold", "0", "The crisis level that triggers the panic config. (0: Off, 1: Critical, 2: Hard, 3: Soft, 4: Cleaning)", FLAGS_CVAR, true, 0.0, true, 4.0);
	g_hPanicConfig = CreateConVar("entity_guard_panic_config", "", "Config file to execute when Panic threshold is hit (Empty: None/Off)", FLAGS_CVAR);

	AutoExecConfig(_, PL_FILENAME);
	SyncFromConVars();
	bool enabled = g_bEnabled;
	ToggleConVarHooks(enabled);

	g_hSvHibernation = FindConVar(GetEngineBranch() == Engine_TF2 ? "tf_allow_server_hibernation" : "sv_hibernate_when_empty");

	// Management & troubleshooting
	RegAdminCmd("sm_guardtest", Command_RunStressTest, ADMFLAG_ROOT, "Spawns props to stress-test prevention logic. Args: <count|0:wipe> [frame:batchCount]");
	RegAdminCmd("sm_guardflags", Command_ToggleCommandCheat, ADMFLAG_CHEATS, "[Debug] Toggles FCVAR_CHEAT on a command. Args: <command> [0:strip|1:add|2:reset]");
	RegAdminCmd("sm_guardkill", Command_RemoveEntity, ADMFLAG_CHEATS, "Removes an entity index. Args: <index> [1:force]");
	RegAdminCmd("sm_guardwipe", Command_RemoveAllEntities, ADMFLAG_CHEATS, "Forcefully removes all entities of a specific classname.");
	RegAdminCmd("sm_guardclear", Command_ClearQuarantine, ADMFLAG_CONFIG, "Resets strike counts and clears the dynamic (stubborn) entity quarantine.");
	RegAdminCmd("sm_guardflush", Command_FlushQueues, ADMFLAG_CONFIG, "Manually triggers an immediate cleanup of Blacklist and Slaughter queues.");
	RegAdminCmd("sm_guardlist", Command_DumpConfig, ADMFLAG_CONFIG, "Dumps all internal lists (Whitelists, Blacklists, Trash, Protected, Forbidden) to console.");
	RegAdminCmd("sm_guardplayer", Command_IgnorePlayer, ADMFLAG_CONFIG, "Toggles/Sets whether player slots are ignored during emergency removals. Args: [0:off|1:on]");
	RegAdminCmd("sm_guardreload", Command_ReloadConfig, ADMFLAG_CONFIG, "Reloads Guard configuration and optionally re-scans existing entities. Args: [1:applyRules]");
	RegAdminCmd("sm_guardsync", Command_UpdateEntityCount, ADMFLAG_CONFIG, "Forces synchronizing internal edict count to a reliable source.");
	// Navigation & hide-and-seek
	RegAdminCmd("sm_guardwarp", Command_WarpToEntity, ADMFLAG_CONFIG, "Warps the admin to a specific entity index. Tip: Use 'sm_guardedict <classname> 1' to list indices of a class.");
	RegAdminCmd("sm_guardwarpc", Command_WarpToClassname, ADMFLAG_CONFIG, "Warp-cycle through all map entities of a class. Args: <classname|0:reset> [1:newest/goBack]");
	RegAdminCmd("sm_guardwarpq", Command_WarpToVictim, ADMFLAG_CONFIG, "Warp-cycle through entities in queues. Args: <1:black|2:slaug> <classname|0:reset> [1:newest/goBack]");
	// Diagnostics & monitoring
	RegAdminCmd("sm_guarddiag", Command_RunDiagnostics, ADMFLAG_CONFIG, "Runs an Auditor diagnostic: Analyzes queue health, queue classname, and stubborn culprits.");
	RegAdminCmd("sm_guardclass", Command_GetEntityClass, FLAGS_COMMAND_BASIC, "Returns entity classname, reference, and world position for a specific index.");
	RegAdminCmd("sm_guardedict", Command_IsEdictByClassname, FLAGS_COMMAND_BASIC, "Verifies if a classname is an edict and optionally lists indices. Args: <classname> [1:listIndices]");
	RegAdminCmd("sm_guardinfo", Command_DisplayStatus, FLAGS_COMMAND_BASIC, "Displays real-time edict counts, peak usage, and internal queue health.");
	RegAdminCmd("sm_guardmap", Command_PrintEntityMap, FLAGS_COMMAND_BASIC, "Displays a visual map of the edict slot usage and fragmentation.");
	RegAdminCmd("sm_guardreport", Command_LogEntityReport, FLAGS_COMMAND_BASIC, "Prints a comprehensive breakdown of entity counts by classname. Args: [1:manual]");

	ToggleEventHooks(enabled);
	UpdateCommandHook(OnSlayCommand, enabled, "sm_slay");
	ToggleHandles(enabled);
	if (enabled) LoadGuardConfig();
	BuildPath(Path_SM, g_sLogPath, sizeof g_sLogPath, "logs/%s.log", PL_FILENAME);

	if (g_bLateLoaded)
	{
		GetCurrentMap(g_sMapName, sizeof g_sMapName);

		// Fix internal vs. engine/manual desync (Next frame is still desync)
		// Unload -> 600 stress ents wiped -> Late load -> Engine 500, Internal 1100 (includes the dead 600 ents)
		if (enabled)
			CreateTimer(0.1, Timer_SyncOnLateLoad, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnAllPluginsLoaded()
{
	g_hSmHibernation = FindConVar("sm_hibernate_when_empty");
}

void SyncFromConVars()
{
	g_bEnabled = g_hEnabled.BoolValue;
	g_iPriorityMode = g_hPriorityMode.IntValue;
	g_bBlackPurgeHard = g_hBlackPurgeHard.BoolValue;
	g_bIgnoreWhitelist = g_hIgnoreWhitelist.BoolValue;
	g_bIgnoreBlacklist = g_hIgnoreBlacklist.BoolValue;
	g_bAuditClass = g_hAuditClass.BoolValue;
	g_bAuditLeak = g_hAuditLeak.BoolValue;
	g_fNotifyInterval = g_hNotifyInterval.FloatValue;
	g_fDiagInterval = g_hDiagInterval.FloatValue;
	g_bCleanupLog = g_hCleanupLog.BoolValue;
	g_iCleanupLogMin = g_hCleanupLogMin.IntValue;
	g_iGarbageReport = g_hGarbageReport.IntValue;
	g_iPanicThreshold = view_as<ThresholdType>(g_hPanicThreshold.IntValue);
	g_hPanicConfig.GetString(g_sPanicConfig, sizeof g_sPanicConfig);
}

void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	// Keep CVar values from before plugin reload. Also stop "Guard Mode change..." etc.
	if (g_bLateLoaded)
		return;

	if (convar == g_hEnabled)
	{
		bool enabled = StringToBool(newValue);

		if (enabled == g_bEnabled)
			return; // No double hooks

		g_bEnabled = enabled;
		ToggleConVarHooks(enabled);
		ToggleEventHooks(enabled);
		UpdateCommandHook(OnSlayCommand, enabled, "sm_slay");
		ToggleHandles(enabled);

		if (enabled)
		{
			SyncFromConVars();
			LoadGuardConfig(); // After we have handle data
			SyncEntityCount();
			ReconcileEntityCensus(); // g_bCensusDone set to true
			g_bAuditAllowed = true;
		}
		else
		{
			ResetRoundState();
			g_bCensusDone = false;
			g_bAuditAllowed = false;
			g_bIsInitPhase = false;
			g_bConfigLoaded = false;
			g_bSyncPending = false;
			g_iRoundSession = 0;
			g_iLastCensusSession = -1;
			g_iPendingMode = -1;
			g_iEntityCount = 0;
			g_iPeakCount = 0;
		}
	}
	else if (convar == g_hPriorityMode)
	{
		static const char revert[] = "%sGuard Mode change reverted. Pending change aborted.",
			change[] = "%sGuard Mode change detected. This will be applied on the next map.";
		int newmode = StringToInt(newValue);

		if (newmode == g_iPriorityMode) // No double notifications
		{
			// Init phase check to ignore 'revert' by .cfg execed (which triggers the hook)
			if (!g_bIsInitPhase && g_iPendingMode != -1)
			{
				// Mode was changed but set back to current mode
				g_iPendingMode = -1;
				PrintToServer(revert, PL_TAG);
				PrintToAdmins(FLAGS_NOTIFY, revert, PL_TAG);
			}

			return;
		}

		if (newmode == g_iPendingMode)
			return;

		g_iPendingMode = newmode;
		PrintToServer(change, PL_TAG);
		PrintToAdmins(FLAGS_NOTIFY, change, PL_TAG);
	}
	else if (convar == g_hBlackPurgeHard)	g_bBlackPurgeHard = StringToBool(newValue);
	else if (convar == g_hIgnoreWhitelist)	g_bIgnoreWhitelist = StringToBool(newValue);
	else if (convar == g_hIgnoreBlacklist)	g_bIgnoreBlacklist = StringToBool(newValue);
	else if (convar == g_hAuditClass)		g_bAuditClass = StringToBool(newValue);
	else if (convar == g_hAuditLeak)		g_bAuditLeak = StringToBool(newValue);
	else if (convar == g_hNotifyInterval)	g_fNotifyInterval = StringToFloat(newValue);
	else if (convar == g_hDiagInterval)		g_fDiagInterval = StringToFloat(newValue);
	else if (convar == g_hCleanupLog)		g_bCleanupLog = StringToBool(newValue);
	else if (convar == g_hCleanupLogMin)	g_iCleanupLogMin = StringToInt(newValue);
	else if (convar == g_hGarbageReport)	g_iGarbageReport = StringToInt(newValue);
	else if (convar == g_hPanicThreshold)	g_iPanicThreshold = view_as<ThresholdType>(StringToInt(newValue));
	else if (convar == g_hPanicConfig)
	{
		strcopy(g_sPanicConfig, sizeof g_sPanicConfig, newValue);
		TrimString(g_sPanicConfig);
	}
	else if (oldValue[0]) {} // Fix 1.11.0.6646 warning
}

/**
 * Converts a string to a boolean based on its integer value.
 *
 * @param stringValue	The string to convert.
 * @return				True if value is non-zero integer, false otherwise.
 */
stock bool StringToBool(const char[] stringValue)
{
	return StringToInt(stringValue) != 0;
}

void ToggleConVarHooks(bool enabled)
{
	static bool masterhooked = false;
	if (!masterhooked)
	{
		UpdateConVarHook(g_hEnabled, OnConVarChanged, true);
		masterhooked = true;
	}

	UpdateConVarHook(g_hPriorityMode, OnConVarChanged, enabled);
	UpdateConVarHook(g_hBlackPurgeHard, OnConVarChanged, enabled);
	UpdateConVarHook(g_hIgnoreWhitelist, OnConVarChanged, enabled);
	UpdateConVarHook(g_hIgnoreBlacklist, OnConVarChanged, enabled);
	UpdateConVarHook(g_hAuditClass, OnConVarChanged, enabled);
	UpdateConVarHook(g_hAuditLeak, OnConVarChanged, enabled);
	UpdateConVarHook(g_hNotifyInterval, OnConVarChanged, enabled);
	UpdateConVarHook(g_hDiagInterval, OnConVarChanged, enabled);
	UpdateConVarHook(g_hCleanupLog, OnConVarChanged, enabled);
	UpdateConVarHook(g_hCleanupLogMin, OnConVarChanged, enabled);
	UpdateConVarHook(g_hGarbageReport, OnConVarChanged, enabled);
	UpdateConVarHook(g_hPanicThreshold, OnConVarChanged, enabled);
	UpdateConVarHook(g_hPanicConfig, OnConVarChanged, enabled);
}

stock void UpdateConVarHook(ConVar convar, ConVarChanged callback, bool hook)
{
	if (hook)
		convar.AddChangeHook(callback);
	else convar.RemoveChangeHook(callback);
}

void ToggleEventHooks(bool enabled)
{
	EventHookMode nocopy = EventHookMode_PostNoCopy;

	UpdateEventHook("round_start", OnRoundStart, enabled, nocopy);
	UpdateEventHook("round_end", OnRoundEnd, enabled, nocopy);
	UpdateEventHook("player_disconnect", OnPlayerDisconnect, enabled);

	static bool teamStartHooked = false, arenaStartHooked = false, teamEndHooked = false, finalehooked = false; ///"arena_win_panel"
	UpdateEventExHook("teamplay_round_start", OnRoundStart, enabled, teamStartHooked, nocopy);
	UpdateEventExHook("arena_round_start", OnRoundStart, enabled, arenaStartHooked, nocopy);
	UpdateEventExHook("teamplay_round_win", OnRoundEnd, enabled, teamEndHooked, nocopy);
	UpdateEventExHook("finale_win", OnRoundEnd, enabled, finalehooked, nocopy);
}

stock void UpdateEventHook(const char[] name, EventHook callback, bool hook, EventHookMode mode = EventHookMode_Post)
{
	if (hook)
		HookEvent(name, callback, mode);
	else UnhookEvent(name, callback, mode);
}

stock void UpdateEventExHook(const char[] name, EventHook callback, bool hook, bool& hooked, EventHookMode mode = EventHookMode_Post)
{
	if (hook)
	{
		if (!hooked)
			hooked = HookEventEx(name, callback, mode);
	}
	else if (hooked)
	{
		UnhookEvent(name, callback, mode);
		hooked = false;
	}
}

stock void UpdateCommandHook(CommandListener callback, bool hook, const char[] command = "")
{
	if (hook)
		AddCommandListener(callback, command);
	else RemoveCommandListener(callback, command);
}

Action OnSlayCommand(int client, const char[] command, int argc)
{
	// In a modded L4D2 server, it crashes when 27 bots are slayed (ents spawn on death) while ent count is > ~1900
	if (g_iEntityCount <= g_iSlayCmdSafe)
		return Plugin_Continue;

	char target[32];
	GetCmdArg(1, target, sizeof target);

	if (target[0] == '@')
	{
		if
		(
			StrEqual(target, "@all") ||
			StrContains(target, "@bot") != -1 ||
			StrEqual(target, "@alive") ||
			StrEqual(target, "@humans") ||
			StrEqual(target, "@red") ||
			StrEqual(target, "@blue") ||
			StrContains(target, "@ct") != -1 ||
			StrEqual(target, "@t") ||
			StrEqual(target, "@ts") ||
			StrEqual(target, "@s") ||
			StrContains(target, "@surv") != -1 ||
			StrEqual(target, "@sa") ||
			StrEqual(target, "@sb") ||
			StrEqual(target, "@sp") ||
			StrEqual(target, "@i") ||
			StrEqual(target, "@ia") ||
			StrEqual(target, "@ib") ||
			StrContains(target, "@infe") != -1
		)
		{
			ReplyToCommand(client, "%sCommand '%s %s' blocked to prevent edict overflow crash (%d > %d).", PL_TAG, command, target, g_iEntityCount, g_iSlayCmdSafe);
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

void ToggleHandles(bool enabled)
{
	int cells = ByteCountToCells(MAX_LEN_CLASSNAME);
	ToggleArrayList(g_hBlacklistQueue, enabled);
	ToggleArrayList(g_hSlaughterQueue, enabled);
	ToggleArrayList(g_hBlacklistBackup, enabled);
	ToggleArrayList(g_hSlaughterBackup, enabled);
	ToggleStringMap(g_hClassnameTracker, enabled);
	ToggleStringMap(g_hConsecutiveSpawns, enabled);
	ToggleStringMap(g_hQuarantineStrikes, enabled);
	ToggleArrayList(g_hDynamicWhitelist, enabled, cells);
	ToggleStringMap(g_hWhitelistClasses, enabled);
	ToggleStringMap(g_hBlacklistClasses, enabled);
	ToggleStringMap(g_hBlacklistClasses_Frame, enabled);
	ToggleStringMap(g_hTrashMap, enabled);
	ToggleArrayList(g_hTrashPartials, enabled, cells);
	ToggleStringMap(g_hProtectedMap, enabled);
	ToggleArrayList(g_hProtectedPartials, enabled, cells);
	ToggleStringMap(g_hQuarantineForbidden, enabled);

	if (!enabled)
	{
		// Special cases - they're created by certain functions
		delete g_hQueueStats;
		delete g_hUniqueResults;
		delete g_hOriginalFlags;
		WipeStressEntities(); // g_hStressEntities, g_hStressLookup destroyed
	}
}

stock void ToggleArrayList(ArrayList& list, bool create, int blocksize = 1)
{
	if (create)
	{
		if (list == null)
			list = new ArrayList(blocksize);
	}
	else delete list;
}

stock void ToggleStringMap(StringMap& map, bool create)
{
	if (create)
	{
		if (map == null)
			map = new StringMap();
	}
	else delete map;
}

public void OnPluginEnd()
{
	if (g_bEnabled)
		WipeStressEntities();
}

int WipeStressEntities()
{
	if (g_hStressEntities == null)
		return -1;

	int total = g_hStressEntities.Length;
	int deleted = 0;
	for (int i = 0; i < total; i++)
	{
		int ref = g_hStressEntities.Get(i);
		int stress = EntRefToEntIndex(ref);

		// No need for tick check for this mod's creation
		if (stress != INVALID_ENT_REFERENCE && g_iDeathMarkedRef[stress] != ref)
		{
			g_iDeathMarkedRef[stress] = ref;
			KillEntity(stress);
			deleted++;
		}
	}

	delete g_hStressEntities;
	delete g_hStressLookup;

	return deleted;
}

void LoadGuardConfig()
{
	char configpath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, configpath, sizeof configpath, "data/%s.cfg", PL_FILENAME);

	KeyValues guard = new KeyValues("GuardSettings");
	if (!guard.ImportFromFile(configpath))
	{
		guard.Close();
		SetFailState("Missing required config file %s.cfg in /data folder.", PL_FILENAME);
	}

	char buffer[16];
	GetEngineKeyName(GetEngineBranch(), buffer, sizeof buffer);

	ParseConfigSection(guard, "Whitelist", buffer, g_hWhitelistClasses);
	ParseConfigSection(guard, "Blacklist", buffer, g_hBlacklistClasses);
	ParseConfigSection(guard, "BlacklistFrame", buffer, g_hBlacklistClasses_Frame);
	ParseConfigSection(guard, "HighPriorityTrash", buffer, g_hTrashMap, g_hTrashPartials);
	ParseConfigSection(guard, "Protected", buffer, g_hProtectedMap, g_hProtectedPartials);
	ParseConfigSection(guard, "ForbiddenFromQuarantine", buffer, g_hQuarantineForbidden);

	guard.Close();
}

stock EngineVersion GetEngineBranch()
{
	static EngineVersion version = Engine_Unknown;
	return version != Engine_Unknown ? version : (version = GetEngineVersion());
}

void GetEngineKeyName(EngineVersion version, char[] buffer, int maxlen)
{
	switch (version)
	{
		case Engine_CSGO: strcopy(buffer, maxlen, "csgo");
		case Engine_CSS: strcopy(buffer, maxlen, "css");
		case Engine_Insurgency: strcopy(buffer, maxlen, "ins");
		case Engine_Left4Dead: strcopy(buffer, maxlen, "l4d1");
		case Engine_Left4Dead2: strcopy(buffer, maxlen, "l4d2");
		case Engine_TF2: strcopy(buffer, maxlen, "tf2");
		default: strcopy(buffer, maxlen, "other");
	}
}

void ParseConfigSection(KeyValues key, const char[] section, const char[] engine, StringMap targetmap, ArrayList partials = null)
{
	targetmap.Clear();
	if (partials != null)
		partials.Clear();

	if (key.JumpToKey(section))
	{
		if (key.JumpToKey("all"))
		{
			ExtractKeysToLists(key, targetmap, partials);
			key.GoBack();
		}

		if (key.JumpToKey(engine))
		{
			ExtractKeysToLists(key, targetmap, partials);
			key.GoBack();
		}

		if (!strncmp(engine, "l4d", 3) && key.JumpToKey("l4dseries"))
		{
			ExtractKeysToLists(key, targetmap, partials);
			key.GoBack();
		}
	}

	key.Rewind();
}

void ExtractKeysToLists(KeyValues key, StringMap map, ArrayList partials = null)
{
	if (!key.GotoFirstSubKey(false))
		return;

	char value[4], clsname[MAX_LEN_CLASSNAME];
	bool haspartials = partials != null;
	do
	{
		if (haspartials)
		{
			key.GetString(NULL_STRING, value, sizeof value, "");
			if (value[0] == '\0' || value[0] == '0')
				continue;
		}
		else if (key.GetNum(NULL_STRING, 0) == 0)
			continue;

		key.GetSectionName(clsname, sizeof clsname);

		if (haspartials && value[0] == '*')
			partials.PushString(clsname);
		else map.SetValue(clsname, 1);
	}
	while (key.GotoNextKey(false));

	key.GoBack();
}

void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bSyncPending)
		ResyncInternalCount(1);

	if (g_bRoundEnded)		// Round ended without map end
	{
		g_iRoundSession++;
		g_iPeakCount = g_iEntityCount; // Sync
		ResetRoundState();	// Reset g_bRoundEnded
		ReconcileEntityCensus();
	}
}

public void OnMapStart()
{
	if (!g_bEnabled)
		return; // Stopping on the next map if it's just off

	g_bConfigLoaded = false; // Reset on map change only
	g_iRoundSession++;
	ResetRoundState();

	if (g_bLateLoaded)
		g_bAuditAllowed = true;
	// Timer starts ticking on map start
	else CreateTimer(WAIT_AUDIT_START, Timer_UnlockAudit, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_UnlockAudit(Handle timer)
{
	g_bAuditAllowed = true;
	return Plugin_Continue;
}

void ResetRoundState()
{
	for (int i = 0; i < sizeof g_iDeathMarkedRef; i++)
		g_iDeathMarkedRef[i] = INVALID_REFERENCE;
	g_iRoundKillCount = 0;
	g_iRoundGarbageCount = 0;
	g_fLastDelete = 0.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iWarpIndex[i] = -1;
		g_sWarpClass[i][0] = '\0';
		g_iWarpQueueType[i] = 0;
	}
	g_bRoundEnded = false;
	g_bReportLogged = false;
	g_bCleaning = false;
	g_bCleaningBanned = false;
	g_bGuardPending = false;
	g_bAuditing = false;
	g_bIgnorePlayer = false;
	// With null checks (Handles get destroyed when disabled in OnConVarChanged)
	ReleaseQuarantine();
	ResetCommandFlags();
	if (g_hConsecutiveSpawns != null) g_hConsecutiveSpawns.Clear();
	if (g_hQuarantineStrikes != null) g_hQuarantineStrikes.Clear();
	delete g_hStressEntities; // Entities get auto-removed on round/map end
	delete g_hStressLookup;
}

void ReleaseQuarantine()
{
	if (!g_bQuarantined)
		return;

	if (g_hDynamicWhitelist && g_hWhitelistClasses)
	{
		char clsname[MAX_LEN_CLASSNAME];
		int size = g_hDynamicWhitelist.Length;
		for (int i = 0; i < size; i++)
		{
			g_hDynamicWhitelist.GetString(i, clsname, sizeof clsname);
			g_hWhitelistClasses.Remove(clsname);
		}

		g_hDynamicWhitelist.Clear();
	}

	g_bQuarantined = false;
}

void ResetCommandFlags()
{
	if (g_hOriginalFlags == null)
		return;

	StringMapSnapshot defaults = g_hOriginalFlags.Snapshot();

	int size = defaults.Length;
	char buffer[48];
	for (int i = 0; i < size; i++)
	{
		defaults.GetKey(i, buffer, sizeof buffer);

		int oriflags;
		if (g_hOriginalFlags.GetValue(buffer, oriflags))
		{
			SetCommandFlags(buffer, oriflags);
			PrintToServer("%sReset: Command '%s' restored to default flags %d.", PL_TAG, buffer, oriflags);
		}
	}

	delete g_hOriginalFlags;
	defaults.Close();
}

public void OnConfigsExecuted()
{
	if (!g_bEnabled)
		return;

	// Apply before reconciling and after CVar .cfg execed
	if (g_iPendingMode != -1)
	{
		g_hPriorityMode.IntValue = g_iPendingMode; // Restore overwritten value
		g_iPriorityMode = g_iPendingMode;
		g_iPendingMode = -1;
	}

	g_bIsInitPhase = false;

	if (!g_bLateLoaded) // OnConfigsExecuted called on late load, late load recon using timer
		ReconcileEntityCensus();
	if (g_bSyncPending)
		ResyncInternalCount(2);
}

Action Timer_SyncOnLateLoad(Handle timer)
{
	SyncEntityCount(); // Wait at least next frame, otherwise report_entities fails
	ReconcileEntityCensus();

	return Plugin_Continue;
}

void ReconcileEntityCensus()
{
	if (g_bIsInitPhase) // Prioritize configs execed if map actually ended
		return;

	if (g_iLastCensusSession != g_iRoundSession)
	{
		PopulateQueuesWithExistingEntities();
		g_iLastCensusSession = g_iRoundSession;
	}
}

void PopulateQueuesWithExistingEntities()
{
	g_hBlacklistQueue.Clear();
	g_hSlaughterQueue.Clear();
	g_hBlacklistBackup.Clear();
	g_hSlaughterBackup.Clear();

	ArrayList trash = new ArrayList();
	ArrayList generic = new ArrayList();
	ArrayList preserved = new ArrayList(); // "'protected' is a newly reserved keyword..."

	int totalexisting = 0, failcount = 0;
	char clsname[MAX_LEN_CLASSNAME], buffer[MAX_LEN_CLASSNAME];
	int size_trashpart = g_hTrashPartials.Length;
	int size_protectpart = g_hProtectedPartials.Length;
	for (int i = g_bLateLoaded ? 1 : MaxClients + 1; i < MAX_ENTITIES; i++)
	{
		if (!IsValidEdict(i))
			continue;

		totalexisting++;

		if (!GetEdictClassname(i, clsname, sizeof clsname))
		{
			failcount++;
			continue;
		}

		if (!IsEntityWhitelisted(clsname))
		{
			int ref = EntIndexToEntRef(i);
			if (g_iPriorityMode == 1 && IsEntityBlacklisted(clsname))
				g_hBlacklistQueue.Push(ref);
			else if (IsHighPriorityTrash(clsname, size_trashpart, buffer, sizeof buffer))
				trash.Push(ref);
			else if (IsProtectedClass(clsname, size_protectpart, buffer, sizeof buffer))
				preserved.Push(ref);
			else generic.Push(ref);
		}
	}

	PushEntsToSlaughQueue(trash);		// Trash stays at the front
	PushEntsToSlaughQueue(generic);		// Generic stays in the middle
	PushEntsToSlaughQueue(preserved);	// Protected stays at the back

	trash.Close();
	generic.Close();
	preserved.Close();

	g_iInitialPopulation = g_hBlacklistQueue.Length + g_hSlaughterQueue.Length;
	PrintToServer("%sCensus  - Initialized queue(s) with %d/%d existing entities (Session: %d, Late: %s).", PL_TAG, g_iInitialPopulation, totalexisting + 1, g_iRoundSession, g_bLateLoaded ? "Yes" : "No"); // + 0/worldspawn

	g_bLateLoaded = false;
	g_bCensusDone = true;

	if (failcount)
		LogError("Census - %d entities failed whitelist and rules checks.", failcount);
}

void PushEntsToSlaughQueue(ArrayList list)
{
	int size = list.Length;
	for (int i = 0; i < size; i++)
		g_hSlaughterQueue.Push(list.Get(i));
}

bool IsHighPriorityTrash(const char[] clsname, int size, char[] buffer, int maxlen)
{
	if (g_hTrashMap.ContainsKey(clsname))
		return true;

	for (int i = 0; i < size; i++)
	{
		g_hTrashPartials.GetString(i, buffer, maxlen);
		if (StrContains(clsname, buffer) != -1)
			return true;
	}

	return false;
}

bool IsProtectedClass(const char[] clsname, int size, char[] buffer, int maxlen)
{
	if (g_hProtectedMap.ContainsKey(clsname))
		return true;

	for (int i = 0; i < size; i++)
	{
		g_hProtectedPartials.GetString(i, buffer, maxlen);
		if (StrContains(clsname, buffer) != -1)
			return true;
	}

	return false;
}

public void OnClientPutInServer(int client)
{
	if (g_bEnabled && g_bSyncPending && !IsFakeClient(client))
	{
		// Count off by one (redundant plus of 1/player) if next frame or slower
		CreateTimer(0.1, Timer_SyncOnWakeUp, 3, TIMER_FLAG_NO_MAPCHANGE);
		g_bSyncPending = false;
	}
}

Action Timer_SyncOnWakeUp(Handle timer, any stage)
{
	ResyncInternalCount(stage);
	return Plugin_Continue;
}

// Pre-re-sync 1&2/3 for accurate info cmds in hibernation
void ResyncInternalCount(int stage)
{
	char syncstage[8] = "3/3";
	if (stage == 2)
		syncstage = "2/3";
	else if (stage == 1)
		syncstage = "1/3";

	PrintToServer("%sPending Sync %s: Server %s. Re-synchronizing internal counts...", PL_TAG, syncstage, stage == 3 ? "woke up" : "hibernating");
	SyncEntityCount(); // Wait until fully woken up
}

void SyncEntityCount(bool syncpeak = true)
{
	char buffer[MAX_LEN_REPORT];
	ServerCommandExForced(buffer, sizeof buffer, "report_entities");

	bool manual = false;
	int entities = ParseEdictCountFromReport(buffer);
	if (entities == -1)
	{
		entities = CountEdicts();
		manual = true;
	}

	g_iEntityCount = entities;
	if (syncpeak)
		g_iPeakCount = entities;
	PrintToServer("%sEntity count synchronization complete: %d (%s)", PL_TAG, entities, manual ? "Manual" : "Engine");
}

stock int ServerCommandExForced(char[] buffer, int maxLen, const char[] command, const char[] args = "")
{
	int flags = GetCommandFlags(command);
	if (flags == INVALID_FCVAR_FLAGS)
		return INVALID_FCVAR_FLAGS;

	bool hasCheat = flags & FCVAR_CHEAT != 0;
	if (hasCheat)
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	ServerCommandEx(buffer, maxLen, args[0] == '\0' ? "%s" : "%s %s", command, args);
	if (hasCheat)
		SetCommandFlags(command, flags);

	return flags;
}

// Not used anymore
stock int ServerCommandForced(const char[] command, const char[] args = "")
{
	int flags = GetCommandFlags(command);
	if (flags == INVALID_FCVAR_FLAGS)
		return INVALID_FCVAR_FLAGS;

	bool hasCheat = flags & FCVAR_CHEAT != 0;
	if (hasCheat)
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	ServerCommand(args[0] == '\0' ? "%s" : "%s %s", command, args);
	ServerExecute();
	if (hasCheat)
		SetCommandFlags(command, flags);

	return flags;
}

stock int ParseEdictCountFromReport(const char[] report)
{
	if (report[0] == '\0')
		return -1;

	int index = StrContains(report, " edicts)"); // ', xxxx edicts)'
	if (index == -1)
		return -1;

	int start = index;
	while (start > 0 && report[start - 1] != ' ')
		start--;

	char number[8];
	strcopy(number, (index - start) + 1, report[start]);

	ReplaceString(number, sizeof number, ",", ""); // In case it has a comma
	return StringToInt(number);
}

// IsValidEdict is probably more accurate. IsValidEntity works too, and is faster
// IsValidEdict is slower probably because in cpp, there's additional redundant IsFree() check when GetEdict() already checks it
stock int CountEdicts()
{
	int maxedicts = GetMaxEntities();
	int count = 0;
	for (int i = 0; i < maxedicts; i++)
		if (IsValidEdict(i))
			count++;

	return count;
}

// The slower FindEntityByClassname version (unused)
stock int CountEdicts2()
{
	int i = -1, count = 0;
	while ((i = FindEntityByClassname(i, "*")) != -1)
		if (i >= 0)
			count++;

	return count;
}

// 'bot' key seems not getting updated (always false)
// This event annoyingly fires twice per player
// [Last map] Last Human DC -> Hibernate -> Round Start -> Map End -> [New first map] Round start -> Map Start
void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || IsFakeClient(client)) // Invalid userid passable here, needs !=0 check
		return;

	g_iWarpIndex[client] = -1;
	g_sWarpClass[client][0] = '\0';
	g_iWarpQueueType[client] = 0;

	if (IsAboutToHibernate())
	{
		g_bSyncPending = true;
		g_bCensusDone = false;
		g_bRoundEnded = false;
		LogEndReport();
	}
}

bool IsAboutToHibernate()
{
	if (!IsLastHumanPlayer()) // More efficient than CountHumanPlayers() == 1
		return false;

	if (g_hSmHibernation != null) // delayhibernate plugin
		return g_hSmHibernation.IntValue != -1;

	if (g_hSvHibernation != null)
		return g_hSvHibernation.IntValue == 1;

	return true; // CSS, DoD:S, ... (no game hibernation CVar)
}

stock bool IsLastHumanPlayer()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i) || IsFakeClient(i))
			continue;

		if (++count > 1)
			return false;
	}

	return true;
}

// Not used anymore
/**bool CountHumanPlayers()
{
	return CountPlayers(false, _, true);
}*/

stock int CountPlayers(bool inGameOnly = true, int team = -1, bool noBots = false, bool aliveOnly = false)
{
	bool checkTeam = team != -1;

	if (checkTeam && (team < 1 || team > 4))
		return -1;

	if (!inGameOnly && (checkTeam || aliveOnly))
		inGameOnly = true;

	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (inGameOnly ? !IsClientInGame(i) : !IsClientConnected(i))
			continue;

		if ((!checkTeam || GetClientTeam(i) == team) &&
			(!noBots || !IsFakeClient(i)) &&
			(!aliveOnly || IsPlayerAlive(i)))
			count++;
	}

	return count;
}

public void OnMapEnd()
{
	if (!g_bEnabled)
		return;

	g_bCensusDone = false;
	g_bRoundEnded = false;
	LogEndReport();
}

void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnded = true;
	g_bCensusDone = false;
	LogEndReport();
}

void LogEndReport()
{
	if (g_bReportLogged)
		return;

	int killcount = g_iRoundKillCount;
	int garbagecount = g_iRoundGarbageCount;
	bool logGarbage = garbagecount && (g_iGarbageReport == 1 || g_iGarbageReport == 2 && killcount);

	if (!killcount && !logGarbage)
		return;

	char threshold[12];
	GetThresholdName(threshold, sizeof threshold, g_iPeakCount);

	char peakvalue[12], kills[12];
	IntToCommas(g_iPeakCount, peakvalue, sizeof peakvalue);
	IntToCommas(killcount, kills, sizeof kills);

	#define HEADER				"=========== ROUND END REPORT ===========\n" ... \
		LOG_SPACE ...			"[Map: %s]\n" ... \
		LOG_SPACE ...			"Peak Load Recorded				: %s entities\n" ... \
		LOG_SPACE ...			"Threat Level Reached			: %s threshold\n" ... \
		LOG_SPACE ...			"----------------------------------------\n" ... \
		LOG_SPACE ...			"Guard Active Neutralizations	: %s kills\n"
	if (logGarbage)
	{
		char garbage[12], total[12];
		IntToCommas(garbagecount, garbage, sizeof garbage);
		IntToCommas(killcount + garbagecount, total, sizeof total);

		LogToFileEx(g_sLogPath, HEADER ...
			LOG_SPACE ...		"Janitor Garbage Collections	: %s invalids\n" ...
			LOG_SPACE ...		"----------------------------------------\n" ...
			LOG_SPACE ...		"Total Operational Impact		: %s units\n" ...
			LOG_SPACE ...		"========================================",
			g_sMapName, peakvalue, threshold, kills, garbage, total);
	}
	else LogToFileEx(g_sLogPath, HEADER ...
		LOG_SPACE ...			"========================================",
		g_sMapName, peakvalue, threshold, kills);
	#undef HEADER

	g_bReportLogged = true;
}

// Improved from stock FormatNumber
/**
 * Formats an integer into a string with thousands separators (1000 -> 1,000).
 * This supports both positive and negative values.
 *
 * @param number		Integer to format.
 * @param buffer		Destination string buffer.
 * @param maxlen		Destination buffer length (includes null terminator).
 * @return				Number of characters written to the buffer, not
 *						including the null terminator.
 */
stock int IntToCommas(int number, char[] buffer, int maxlen)
{
	char raw[16];
	int rawLen = IntToString(number, raw, sizeof raw);

	if (rawLen >= maxlen)
		return strcopy(buffer, maxlen, raw);

	int digits = raw[0] == '-' ? rawLen - 1 : rawLen;
	if (digits < 4)
		return strcopy(buffer, maxlen, raw);

	int commas = (digits - 1) / 3; // Last index / 3
	int destLen = rawLen + commas;

	if (destLen >= maxlen)
		return strcopy(buffer, maxlen, raw);

	buffer[destLen] = '\0';

	int lastDest = destLen - 1;
	int count = 0;
	for (int i = rawLen - 1; i >= 0; i--)
	{
		buffer[lastDest--] = raw[i]; // Copy the digit
		count++;

		if (count == 3 && i > 0 && raw[i - 1] != '-')
		{
			buffer[lastDest--] = ',';
			count = 0;
		}
	}

	return destLen;
}

// Not called on late load (for ent lump safety?)
public void OnMapInit(const char[] mapName)
{
	if (!g_bEnabled)
		return;

	g_bIsInitPhase = true;
	g_bAuditAllowed = false;
	g_iPeakCount = g_iEntityCount = 0; // Reset before 0/worldspawn created
	strcopy(g_sMapName, sizeof g_sMapName, mapName);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bEnabled || entity < 0)
		return;

	int count = ++g_iEntityCount;

	if (count > g_iPeakCount)
		g_iPeakCount = count;

	// Skip ghost entities burst before census done
	if (g_bCensusDone && !IsEntityWhitelisted(classname))
		ProcessThresholds(count, entity, classname);
}

bool IsEntityWhitelisted(const char[] clsname)
{
	return !g_bIgnoreWhitelist && g_hWhitelistClasses.ContainsKey(clsname);
}

int Native_GetPeakEdicts(Handle plugin, int numParams)
{
	return g_iPeakCount;
}

public void OnEntityDestroyed(int entity)
{
	if (!g_bEnabled || entity < 0)
		return;

	g_iEntityCount--;
	g_iDeathMarkedRef[entity] = INVALID_REFERENCE; // Reset if engine actually clears the slot
}

// Obsolete. A simple 0 <= entity is enough as non-edicts are negative refs
// Modern SM internally converts index to ref, while Valve uses pure index 0-4095 (most Source)
// It seems SM forgets to update this docs in FindEntityByClassname which are now misleading:
// @return		Entity index >= 0 if found, -1 otherwise.		// It does return negative ref!
// @error		Invalid start entity or lack of mod support.	// Using negative ref works!
stock bool IsEdictEntity(int edict)
{
	static int threshold = 0;
	return 0 <= edict < (threshold != 0 ? threshold : (threshold = GetMaxEntities()));
}

int Native_GetEdictCount(Handle plugin, int numParams)
{
	return g_iEntityCount > 0 ? g_iEntityCount : 0;
}

void ProcessThresholds(int count, int entity, const char[] clsname)
{
	int ref = EntIndexToEntRef(entity);
	int tick = GetGameTickCount();
	g_iCreationTick[entity] = tick;

	if (count > g_iEntLimit_Critical) // Ask Lord GabeN for help!
	{
		MarkEntityForDeath(entity, ref, clsname, Threshold_Critical);
		LoadPanicConfig(Threshold_Critical);
	}
	else switch (g_iPriorityMode) // Already excludes 0 because of g_bCensusDone check
	{
		case 0: (!g_bCleaning ? g_hSlaughterQueue : g_hSlaughterBackup).Push(ref);
		case 1, 2: IsEntityBlacklisted(clsname) ?
			(!g_bCleaning ? g_hBlacklistQueue : g_hBlacklistBackup).Push(ref) :
			(!g_bCleaning ? g_hSlaughterQueue : g_hSlaughterBackup).Push(ref);
	}

	if (count > g_iEntLimit_Hard)
	{
		PurgeBlacklistEntity(entity, ref, clsname, tick, Threshold_Hard);

		int freecount = count > g_iEntLimit_Critical ? DELETE_BATCH_CRIT : DELETE_BATCH;
		int killed = FreeOldestEntities(freecount, tick); // Guard Panic mode

		if (killed)
		{
			float time = GetGameTime();
			g_fLastDelete = time; // Reset relax mode after we're done in panic
			NotifyAdmins(time, Threshold_Hard, count, killed);
		}

		LoadPanicConfig(Threshold_Hard);
	}
	else if (count > g_iEntLimit_Soft)
	{
		if (!g_bBlackPurgeHard)
			PurgeBlacklistEntity(entity, ref, clsname, tick, Threshold_Soft);

		float time = GetGameTime();
		int killed;
		if (IsCooldownOver(g_fLastDelete, WAIT_SOFT_DELETE, time) &&
			(killed = FreeOldestEntities(DELETE_SINGLE, tick))) // Guard Relax mode
			NotifyAdmins(time, Threshold_Soft, count, killed);

		LoadPanicConfig(Threshold_Soft);
	}

	CleanupQueue(count, tick);
	AuditEntitySpawns(clsname, ref, count > g_iEntLimit_Soft);
}

bool IsEntityBlacklisted(const char[] clsname)
{
	return !g_bIgnoreBlacklist && g_hBlacklistClasses.ContainsKey(clsname);
}

void PurgeBlacklistEntity(int entity, int ref, const char[] clsname, int tick, ThresholdType type)
{
	if (!g_iPriorityMode && !g_bIgnoreBlacklist && g_iDeathMarkedRef[entity] != ref)
	{
		static int lastTick = -1;
		if (g_hBlacklistClasses.ContainsKey(clsname) ||
			!IsWithinTickInterval(lastTick, _, tick) && g_hBlacklistClasses_Frame.ContainsKey(clsname))
			MarkEntityForDeath(entity, ref, clsname, type);
	}
}

void MarkEntityForDeath(int entity, int ref, const char[] clsname, ThresholdType type)
{
	g_iDeathMarkedRef[entity] = ref;

	#if defined SUPPRESS_TRANSMIT
	g_iPendingType[entity] = type;
	SDKHook(entity, SDKHook_Spawn, Hook_Spawn);
	 #pragma unused clsname // Fix annoying warning
	///if (clsname[0]) {} ///clsname[0] = 0;
	#else
	DeferRemoveEntity(entity, ref, clsname, type);
	#endif
}

// Obsolete experiment for 'SendTable_GetNumFlatProps' or 'Read Access Violation' crashes
// Try to force stop networking immediately on spawn
#if defined SUPPRESS_TRANSMIT
Action Hook_Spawn(int entity)
{
	SDKUnhook(entity, SDKHook_Spawn, Hook_Spawn);

	int flags = GetEdictFlags(entity);
	int newflags = (flags & ~(FL_EDICT_CHANGED | FL_FULL_EDICT_CHANGED))
		| FL_EDICT_DONTSEND; // Keep FL_EDICT_FULL (4)

	SetEdictFlags(entity, newflags);
	DeferRemoveEntity(entity, EntIndexToEntRef(entity), "", g_iPendingType[entity]);

	return Plugin_Continue; // Let it finish, blocking can cause crash I think for certain ents
}
#endif

void DeferRemoveEntity(int entity, int ref, const char[] clsname, ThresholdType type)
{
	bool isSpotlight = clsname[0] == 'p' && !strcmp(clsname, "point_spotlight");
	// Smuggle a bool inside ref to avoid big boy GetEdictClassname()
	RequestFrame(Frame_RemoveEntity, isSpotlight ? -ref : ref);

	bool normal = clsname[0] != '\0';

	static char buffer[MAX_LEN_CLASSNAME]; // Declare this to shorten lines
	if (!normal)
	{
		if (!IsValidEdict(entity) || !GetEdictClassname(entity, buffer, sizeof buffer))
			strcopy(buffer, sizeof buffer, STR_CLASS_UNKNOWN);
	}

	bool isplayer = IsPlayerIndex(entity);
	switch (type)
	{
		case Threshold_Critical: PrintToServer(
			"%sGuard   - %s threshold! Marked for %s%s new entity: %d (%s)",
			PL_TAG, STR_CRITICAL, isplayer ? "kick" : "death", normal ? "" : " & neutralized", entity, normal ? clsname : buffer);
		case Threshold_Hard: PrintToServer(
			"%sGuard   - %s threshold! Marked for %s%s new entity: %d (%s/Black)",
			PL_TAG, STR_HARD, isplayer ? "kick" : "death", normal ? "" : " & neutralized", entity, normal ? clsname : buffer);
		case Threshold_Soft: PrintToServer(
			"%sGuard   - %s threshold! Marked for %s%s new entity: %d (%s/Black)",
			PL_TAG, STR_SOFT, isplayer ? "kick" : "death", normal ? "" : " & neutralized", entity, normal ? clsname : buffer);
	}
}

void Frame_RemoveEntity(any ref)
{
	bool isSpotlight = ref > 0;

	int entity = EntRefToEntIndex(isSpotlight ? -ref : ref);
	if (entity == INVALID_ENT_REFERENCE) // Stops on next round/map as ents wiped = invalid
		return;

	if (IsPlayerIndex(entity))
	{
		if (KickPlayer(entity, true))
			g_iRoundKillCount++;
	}
	else ///if GetEntityAddress(entity) != Address_Null
	{
		if (isSpotlight)
			KillSpotlightSafely(entity);
		else KillEntity(entity);
		g_iRoundKillCount++;
	}
}

int FreeOldestEntities(int killcount, int tick = -1, int emergency = Guard_Normal)
{
	static int lastTick = -1;
	// tick != -1 -> Guard_Normal
	if (tick != -1 && killcount != DELETE_BATCH_CRIT && IsWithinTickInterval(lastTick, _, tick) ||
		// Pending already set before, wait for ProcessGuardPriority() to set Guard_Immediate
		// Note: DELETE_BATCH_CRIT is blockable here, so it waits Guard_Immediate to kill stuffs. Then it will do the massacre after g_bGuardPending is false
		emergency == Guard_Normal && g_bGuardPending)
		return 0;

	g_bGuardPending = false;
	bool panic = killcount >= DELETE_BATCH;

	// If it's both critical and cleaning time, we touch the queue(s) anyway
	// It shouldn't affect cleaning index because we just set item to invalid ref not Erase() etc.
	if (g_bCleaning && killcount != DELETE_BATCH_CRIT)
	{
		g_bGuardPending = true; // Force Janitor to finish her jobs (next frame)
		g_bGuardPanic = panic;

		return 0;
	}

	int killed = 0;
	if (g_iPriorityMode)
		killed += ProcessDeleteQueue(g_hBlacklistQueue, killcount, panic, tick, "/Black", emergency ? (g_iCleaningPhase == Cleaning_Blacklist ? " (Abort Black)" : " (Abort Slaug)") : "");

	if (killed < killcount)
		killed += ProcessDeleteQueue(g_hSlaughterQueue, killcount - killed, panic, tick, "", emergency ? (g_iCleaningPhase == Cleaning_Blacklist ? " (Abort Black)" : " (Abort Slaug)") : "");

	return killed;
}

int ProcessDeleteQueue(ArrayList queue, int killneeded, bool panic, int tick, const char[] suffix, const char[] stage)
{
	int size = queue.Length;
	int killed = 0;
	for (int i = 0; i < size && killed < killneeded; i++)
	{
		int ref = queue.Get(i);
		if (ref == INVALID_REFERENCE)
			continue;

		int target = EntRefToEntIndex(ref);
		bool young = false;
		if (target == INVALID_ENT_REFERENCE || (young = g_iCreationTick[target] == tick) || g_iDeathMarkedRef[target] == ref) ///|| GetEntityAddress(target) == Address_Null
		{
			queue.Set(i, INVALID_REFERENCE);
			// In mode 2, black queue emptied much faster, it would often target young ents.
			// Killing youngsters is fatal. Some mods start throwing error. We ignore it first.
			// And then we send it back to main queue when Janitor finishes her stuffs
			if (young)
				(queue == g_hBlacklistQueue ? g_hBlacklistBackup : g_hSlaughterBackup).Push(ref);

			continue;
		}

		g_iDeathMarkedRef[target] = ref;

		static char clsname[MAX_LEN_CLASSNAME];
		if (!IsValidEdict(target) || !GetEdictClassname(target, clsname, sizeof clsname))
			strcopy(clsname, sizeof clsname, STR_CLASS_UNKNOWN);

		bool isplayer = IsPlayerIndex(target);

		bool kicked = false;
		if (!isplayer)
		{
			if (clsname[0] == 'p' && !strcmp(clsname, "point_spotlight"))
				KillSpotlightSafely(target);
			else KillEntity(target);
			killed++;
			g_iRoundKillCount++;
		}
		else if ((kicked = KickPlayer(target, false)))
		{
			killed++;
			g_iRoundKillCount++;
		}

		queue.Set(i, INVALID_REFERENCE); // Let Janitor swings broom, faster alt to Erase()
		if (!isplayer || kicked)
			PrintToServer("%sGuard   - %s threshold%s! %s oldest entity: %d (%s%s)", PL_TAG, panic ? "Hard" : "Soft", stage, !isplayer ? "Killed" : "Kicked", target, clsname, suffix);
	}

	return killed;
}

stock bool IsPlayerIndex(int client)
{
	return 0 < client <= MaxClients;
}

stock void KillSpotlightSafely(int spotlight)
{
	AcceptEntityInput(spotlight, "LightOff");
	RequestFrame(Frame_DelayKillSpotlight, EntIndexToEntRef(spotlight));
}

stock void Frame_DelayKillSpotlight(any ref)
{
	int spotlight = EntRefToEntIndex(ref);
	if (spotlight != INVALID_ENT_REFERENCE)
		AcceptEntityInput(spotlight, "Kill"); // Requires a delay!
}

stock void KillEntity(int entity)
{
	#if SOURCEMOD_V_MAJOR > 1 || SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR > 9 || \
		SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR == 9 && SOURCEMOD_V_REV >= 6225
	RemoveEntity(entity);
	#else
	AcceptEntityInput(entity, "Kill");
	#endif
}

bool KickPlayer(int client, bool isnew)
{
	if (g_bIgnorePlayer || !IsFakeClient(client))
	{
		g_iDeathMarkedRef[client] = INVALID_REFERENCE; // Unlock back
		PrintToServer("%sGuard   - Unmarked for kick %s entity: %d (Reason: %s)", PL_TAG, isnew ? "New" : "Old", client, g_bIgnorePlayer ? "Ignored" : "Human");

		return false;
	}

	KickClient(client, "Guard: Logic Kick"); // Use the safer kick instead of kill
	return true;
}

void CleanupQueue(int count, int tick)
{
	bool panic = count >= g_iCleaningPanic;

	if (panic)
		LoadPanicConfig(Threshold_Cleanup);

	static int lastTick = -1;
	if (g_bCleaning || IsWithinTickInterval(lastTick, panic ?
		WAIT_TICK_CLEANUP : WAIT_TICK_CLEANUP * 10, tick)) // 60 tick: Per 0.167/1.67s
		return;

	if (count > g_iCleaningSafeLimit) // Unsafe
		g_bCleaningBanned = true;
	else if (g_bCleaningBanned && count < g_iCleaningSafeLimit - CLEAN_UNBAN_BUFFER)
		g_bCleaningBanned = false; // Unban default: 1880, just below Hard (1904)

	if (g_bCleaningBanned)
		return;

	int size_black = g_iPriorityMode ? (g_iBlacklistJobs = g_hBlacklistQueue.Length) : 0;
	int size_slaug = g_iSlaughterJobs = g_hSlaughterQueue.Length;
	if (panic || g_iPriorityMode && size_black > MAX_HEALTHY_QUEUE ||
		size_slaug > MAX_HEALTHY_QUEUE)
	{
		if (size_black)
			g_iCleaningPhase = Cleaning_Blacklist;
		else if (size_slaug)
			g_iCleaningPhase = Cleaning_Slaughter;
		else return;

		g_bCleaning = true;
		g_iTotalKept = g_iTotalDiscarded = 0;
		ExecuteCleanupStep(Janitor_Initial, panic);
	}
}

void LoadPanicConfig(ThresholdType type)
{
	if (type == g_iPanicThreshold && !g_bConfigLoaded && g_sPanicConfig[0])
	{
		ServerCommand("exec %s", g_sPanicConfig);
		g_bConfigLoaded = true;

		char threshold[12];
		GetThresholdName(threshold, sizeof threshold, _, type);

		#define LOG "%s threshold! Panic config '%s' loaded on current map %s."
		PrintToServer("%sDoctor  - " ... LOG, PL_TAG, threshold, g_sPanicConfig, g_sMapName);
		PrintToAdmins(FLAGS_NOTIFY, "%sDoctor - " ... LOG, PL_TAG, threshold, g_sPanicConfig, g_sMapName);
		LogToFileEx(g_sLogPath, LOG, threshold, g_sPanicConfig, g_sMapName);
		#undef LOG
	}
}

/**
 * Checks if the current game tick is within a specified interval since the last
 * recorded tick.
 *
 * @param lastTick		Variable storing the last tick.
 * @param interval		Number of ticks to wait before returning false again
 *						(0: Only returns false once per tick).
 * @param tick			Current game tick. Optionally uses pre-fetched tick.
 * @return				True if the interval is not yet passed, false otherwise.
 */
stock bool IsWithinTickInterval(int& lastTick, int interval = 0, int tick = -1)
{
	if (tick == -1)
		tick = GetGameTickCount();

	if (tick <= lastTick + interval)
		return true;

	lastTick = tick;
	return false;
}

void GetThresholdName(char[] buffer, int maxlen, int count = -1, ThresholdType type = Threshold_None)
{
	if (count != -1)
		if (count > g_iEntLimit_Critical)	strcopy(buffer, maxlen, STR_CRITICAL);
		else if (count > g_iEntLimit_Hard)	strcopy(buffer, maxlen, STR_HARD);
		else if (count > g_iEntLimit_Soft)	strcopy(buffer, maxlen, STR_SOFT);
		else if (count >= g_iCleaningPanic)	strcopy(buffer, maxlen, STR_CLEANUP);
		else								strcopy(buffer, maxlen, STR_SAFE);
	else switch (type)
	{
		case Threshold_Critical:	strcopy(buffer, maxlen, STR_CRITICAL);
		case Threshold_Hard:		strcopy(buffer, maxlen, STR_HARD);
		case Threshold_Soft:		strcopy(buffer, maxlen, STR_SOFT);
		case Threshold_Cleanup:		strcopy(buffer, maxlen, STR_CLEANUP);
		case Threshold_None:		strcopy(buffer, maxlen, STR_SAFE);
		default:					strcopy(buffer, maxlen, "Unknown");
	}
}

void ExecuteCleanupStep(int cleanuptype, bool panic)
{
	static int read, write;
	if (cleanuptype == Janitor_Initial)
		read = write = 0;

	bool isblacklist = g_iCleaningPhase == Cleaning_Blacklist;
	int size = isblacklist ? g_iBlacklistJobs : g_iSlaughterJobs;
	ArrayList queue = isblacklist ? g_hBlacklistQueue : g_hSlaughterQueue;
	g_bJanitorPanic = panic;

	if (g_bGuardPending || g_iEntityCount > g_iCleaningSafeLimit)
	{
		if (!g_bGuardPending) g_bCleaningBanned = true;
		FinishCleanup(queue, read, write, size); // Unfinished, forced

		return;
	}

	// Keep queue compact by sliding valid ents to the front
	int processed = 0;
	int limit = g_bIsManualCleanup ? size : (panic ? CLEANUP_PANIC : CLEANUP_RELAX);
	while (read < size && processed < limit)
	{
		int ref = queue.Get(read);
		if (ref != INVALID_REFERENCE && IsValidEntityByRef(ref))
		{
			if (write != read)
				queue.Set(write, ref);
			write++; // Valid - move to next slot
		}

		read++;
		processed++;
	}

	if (read >= size)
		FinishCleanup(queue, read, write, size); // Finished batch, collect garbage
	else
	{
		g_iCleaningType = Janitor_Resume;
		RequestFrame(Frame_DoAnotherCleanup, g_iRoundSession); // Unfinished, schedule next chunk
	}
}

stock bool IsValidEntityByRef(int ref)
{
	return EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE;
}

void FinishCleanup(ArrayList queue, int read, int write, int size)
{
	int kept = write;
	int discarded = read - write;

	g_iTotalKept += kept;
	g_iTotalDiscarded += discarded;
	g_iRoundGarbageCount += discarded;

	bool aborted = read < size;

	if (aborted)
		for (int i = read; i < size; i++)
			queue.Set(write++, queue.Get(i)); // Shift unread items to the front
	queue.Resize(write); // Cut off the garbage at the end

	bool pending = g_bGuardPending;
	CleaningStage stage = g_iCleaningPhase;

	if (!pending && stage == Cleaning_Blacklist && g_iSlaughterJobs)
	{
		g_iCleaningPhase = Cleaning_Slaughter;
		g_iCleaningType = Janitor_Initial;
		if (g_bIsManualCleanup)
			ExecuteCleanupStep(Janitor_Initial, true);
		else RequestFrame(Frame_DoAnotherCleanup, g_iRoundSession); // New frame for moar fps

		return;
	}

	g_bCleaning = false; // Unlock before immediately running pending Guard
	if (pending)
		ProcessGuardPriority();

	if (g_bIsManualCleanup)
	{
		g_bIsManualCleanup = false;
		return;
	}

	int backupscount = PushBackupsToMainQueues();

	if (!g_bCleanupLog)
		return;

	int totaldiscard = g_iTotalDiscarded;
	if (aborted)
		PrintToServer("%sJanitor - %s, abort %s! Processed: %d | Kept: %d | Discarded: %d | New: %d | Pending: %d", PL_TAG, pending ? "Pending Guard" : "Near-critical", stage == Cleaning_Blacklist ? "Black" : "Slaug", read, kept, discarded, backupscount, size - read);
	else if (g_iCleanupLogMin && totaldiscard >= g_iCleanupLogMin ||
		!g_iCleanupLogMin && (totaldiscard || backupscount))
		PrintToServer("%sJanitor - Clean-ups done! Kept: %d | Discarded: %d | New: %d", PL_TAG, g_iTotalKept, totaldiscard, backupscount);
}

void Frame_DoAnotherCleanup(any sessionID)
{
	// Session check handles rare out-of-bound read error
	// Old code: Reset in round start clears arrays -> frame resume on map start -> error
	// New code: Census (round start) clears arrays -> frame resume on map start -> error
	///if (g_bRoundStarted && sessionID == g_iRoundSession)
	if (g_bCensusDone && sessionID == g_iRoundSession)
		ExecuteCleanupStep(g_iCleaningType, g_bJanitorPanic);
	else g_bCleaning = false;
}

void ProcessGuardPriority()
{
	bool panic = g_bGuardPanic;
	int killed = FreeOldestEntities(panic ? DELETE_BATCH : DELETE_SINGLE, _, Guard_Immediate);
	if (killed)
	{
		float time = GetGameTime();
		if (panic) g_fLastDelete = time;
		NotifyAdmins(time, panic ? Threshold_Hard : Threshold_Soft, _, killed);
	}
}

int PushBackupsToMainQueues()
{
	int size_black = g_hBlacklistBackup.Length;
	int size_slaug = g_hSlaughterBackup.Length;

	for (int i = 0; i < size_black; i++)
		g_hBlacklistQueue.Push(g_hBlacklistBackup.Get(i));
	for (int i = 0; i < size_slaug; i++)
		g_hSlaughterQueue.Push(g_hSlaughterBackup.Get(i));

	g_hBlacklistBackup.Clear();
	g_hSlaughterBackup.Clear();

	return size_black + size_slaug;
}

void NotifyAdmins(float gametime, ThresholdType type, int entcount = -1, int killed = 0)
{
	static float lastnotify = 0.0;
	if (!g_fNotifyInterval || !IsCooldownOver(lastnotify, g_fNotifyInterval, gametime))
		return;

	char threshold[12], action[32];
	int limit = -1;
	switch (type)
	{
		case Threshold_Hard:
		{
			bool critical = entcount != -1 && entcount > g_iEntLimit_Critical;
			threshold = critical ? STR_CRITICAL : STR_HARD;
			limit = critical ? g_iEntLimit_Critical : g_iEntLimit_Hard;
			FormatEx(action, sizeof action, critical ? "Marked 1 + Purged %d" : "Purged %d (Batch)", killed);
		}
		case Threshold_Soft:
		{
			threshold = STR_SOFT;
			limit = g_iEntLimit_Soft;
			FormatEx(action, sizeof action, "Purged %d (Single)", killed);
		}
		default: {threshold = "Unknown"; action = "Unknown";}
	}

	char count[8];
	if (entcount == -1)
		count = "?";
	else IntToString(entcount, count, sizeof count);

	PrintToAdmins(FLAGS_NOTIFY, "%s%s Threshold (%s > %d)! Neutralized: %s", PL_TAG, threshold, count, limit, action);
}

// L4D2 - overflow & no print if char len exceeds 249 (colors.inc use 250!)
stock void PrintToAdmins(int flags = ADMFLAG_ROOT, const char[] format, any ...)
{
	char message[250];
	VFormat(message, sizeof message, format, 3);

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetUserFlagBits(i) & (flags | ADMFLAG_ROOT))
			PrintToChat(i, "%s", message);
}

void AuditEntitySpawns(const char[] clsname, int ref, bool forced)
{
	if (!g_bAuditAllowed) // Early map stage
		return;

	if (g_bStressTesting && clsname[0] == 'p' && !strcmp(clsname, "prop_dynamic_override"))
	{
		static char sRef[16];
		IntToString(ref, sRef, sizeof sRef);

		if (g_hStressLookup.ContainsKey(sRef))
			return; // Prevent false-positive quarantine
	}

	static int spawnsThisSecond, startcount;
	static bool countclass, countleak; // CVars could change, so use this

	bool iscleanup = clsname[0] == 'C';
	if (!iscleanup)
	{
		if (!g_bAuditing) // New audit
		{
			bool request = forced || g_bAuditClass || g_bAuditLeak;
			if (!request) // Below threshold & CVars are off
				return;

			g_bAuditing = true; // Keep auditing even if no request for accuracy
			countclass = forced || g_bAuditClass;
			countleak = forced || g_bAuditLeak;
			spawnsThisSecond = 0;
			g_hClassnameTracker.Clear();
			startcount = g_iEntityCount - 1; // Exclude added first entity (off-by-1 error)
			CreateTimer(1.0, Timer_CloseAuditWindow, _, TIMER_FLAG_NO_MAPCHANGE);
		}

		if (countleak)
			spawnsThisSecond++;

		if (countclass)
		{
			int classcount = 0;
			g_hClassnameTracker.GetValue(clsname, classcount);
			g_hClassnameTracker.SetValue(clsname, ++classcount);
		}

		return;
	}

	if (countleak && spawnsThisSecond >= MIN_SEC_ENT_LEAK) // Def: 150
	{
		PrintToServer("%sAuditor - ALERT! Entity Leak: Total %d/sec", PL_TAG, spawnsThisSecond);
		LogToFileEx(g_sLogPath, "Entity Leak	: Total %d/sec", spawnsThisSecond);
	}

	if (countclass) // Run only if we have data
	{
		StringMapSnapshot tracker = g_hClassnameTracker.Snapshot();
		ProcessClassnameCount(tracker);

		int entityjump = g_iEntityCount - startcount; // Net gain (removed ents included)
		if (entityjump >= MIN_SEC_ENT_JUMP) // Huge jump (def: 200) since last sec
		{
			static float lastdiag = 0.0;
			if (g_fDiagInterval <= 1.0 || IsCooldownOver(lastdiag, g_fDiagInterval, GetGameTime()))
				RunInternalDiagnostic(-1, entityjump, tracker);
		}

		tracker.Close();
	}

	g_bAuditing = false;
}

Action Timer_CloseAuditWindow(Handle timer)
{
	if (g_bAuditing) // g_bAuditing is reset if plugin off, or round/map end
		AuditEntitySpawns("Cleanup_time_babe", INVALID_REFERENCE, false);
	return Plugin_Continue;
}

/**
 * Checks if a cooldown has expired since the last recorded time.
 *
 * @param lastTime		Variable storing the last time.
 * @param cooldown		Duration in seconds to wait.
 * @param time			0.0: Use engine time, otherwise use pre-fetched time.
 * @return				True if the cooldown has passed, false otherwise.
 */
stock bool IsCooldownOver(float& lastTime, float cooldown, float time = 0.0)
{
	if (time == 0.0)
		time = GetEngineTime();

	if (time < lastTime || time - lastTime >= cooldown)
	{
		lastTime = time;
		return true;
	}

	return false;
}

void ProcessClassnameCount(StringMapSnapshot tracker)
{
	int size = tracker.Length;
	char keyname[MAX_LEN_CLASSNAME];
	for (int i = 0; i < size; i++)
	{
		tracker.GetKey(i, keyname, sizeof keyname);

		int keyvalue;
		g_hClassnameTracker.GetValue(keyname, keyvalue);

		if (keyvalue < QUARANTINE_FORGIVE) // 0-10
		{
			g_hConsecutiveSpawns.Remove(keyname); // Forgiven, wipe the history

			int strikes = 0;
			if (g_hQuarantineStrikes.GetValue(keyname, strikes) && strikes > 0)
				g_hQuarantineStrikes.SetValue(keyname, --strikes);

			LogHighSpawnEntity(keyname, keyvalue);
			continue;
		}

		if (g_hQuarantineForbidden.ContainsKey(keyname))
		{
			LogHighSpawnEntity(keyname, keyvalue, true);
			continue;
		}

		if (keyvalue >= QUARANTINE_TRIGGER) // 100+, danger zone
			ApplyQuarantineLogic(keyname, keyvalue);
		else if (keyvalue >= QUARANTINE_SUSPECT) // 80-99, still suspicious, keep the count
			LogHighSpawnEntity(keyname, keyvalue);
		else // 10-79, pressure dropped, lower the count
		{
			int consecutive = 0;
			if (g_hConsecutiveSpawns.GetValue(keyname, consecutive) && consecutive > 0)
				g_hConsecutiveSpawns.SetValue(keyname, --consecutive);

			LogHighSpawnEntity(keyname, keyvalue);
		}
	}
}

void LogHighSpawnEntity(const char[] clsname, int spawnrate, bool forbidden = false)
{
	if (spawnrate >= MIN_SEC_HIGH_SPAWN) // Def: 50
	{
		PrintToServer("%sAuditor - ALERT! High spawn rate: %s%s (%d/sec)", PL_TAG, clsname, !forbidden ? "" : "/Forbidden", spawnrate);
		LogToFileEx(g_sLogPath, "High Spawn Rate: %s%s (%d/sec)", clsname, !forbidden ? "" : "/Forbidden", spawnrate);
	}
}

void ApplyQuarantineLogic(const char[] clsname, int spawnrate)
{
	int consecutive = 0;
	g_hConsecutiveSpawns.GetValue(clsname, consecutive);
	g_hConsecutiveSpawns.SetValue(clsname, ++consecutive);

	if (consecutive >= QUARANTINE_CONSEC) // It's been 3 sec (default) of 100+ spawns
	{
		int strikes = 0;
		g_hQuarantineStrikes.GetValue(clsname, strikes);
		g_hQuarantineStrikes.SetValue(clsname, ++strikes);

		if (strikes >= QUARANTINE_STRIKE) // Too stubborn to die, timer script?
		{
			g_hWhitelistClasses.SetValue(clsname, 1);
			g_hDynamicWhitelist.PushString(clsname);
			g_bQuarantined = true;

			g_hQuarantineStrikes.Remove(clsname);
			g_hConsecutiveSpawns.Remove(clsname);

			PrintToServer("%sDoctor  - Quarantine: %s WHITELISTED (Strike %d/%d, persistent loop)", PL_TAG, clsname, strikes, QUARANTINE_STRIKE);
			LogToFileEx(g_sLogPath, "Quarantine     : %s WHITELISTED (Strike %d/%d, persistent loop)", clsname, strikes, QUARANTINE_STRIKE);
		}
		else
		{
			g_hConsecutiveSpawns.Remove(clsname); // Reset the Consecutive heat
			PrintToServer("%sDoctor  - High Spawn Rate: %s (%d/sec). WARNING: Strike %d/%d", PL_TAG, clsname, spawnrate, strikes, QUARANTINE_STRIKE);
			LogToFileEx(g_sLogPath, "High Spawn Rate: %s (%d/sec). WARNING: Strike %d/%d", clsname, spawnrate, strikes, QUARANTINE_STRIKE);
		}
	}
}

void RunInternalDiagnostic(int client, int spikesize = 0, StringMapSnapshot spike = null)
{
	bool auto = client == -1;

	if (auto)
		PrintToServer("%sAuditor - WARNING! Entity spike: +%d/sec", PL_TAG, spikesize);

	char buffer[MAX_LEN_LARGE_BUFF];
	int maxsize = sizeof buffer;
	int pos = 0;

	// Header
	if (auto)
	{
		pos += FormatEx(buffer[pos], maxsize - pos, "[AUTO INTERNAL DIAG]\n");
		pos += FormatEx(buffer[pos], maxsize - pos, "%sGeneral:  Entities: %d | Guard Kills: %d | Spike: +%d/sec\n", LOG_SPACE, g_iEntityCount, g_iRoundKillCount, spikesize);
	}
	else PrintToConsole(client, "%s--- INTERNAL DIAGNOSTIC ---\nGeneral:\n >> Entities: %d | Kills: %d", PL_TAG, g_iEntityCount, g_iRoundKillCount);

	char clsname[MAX_LEN_CLASSNAME];

	// Spike Analysis
	if (auto) // Manual has no tracked last 1s data
	{
		pos += FormatEx(buffer[pos], maxsize - pos, "%sSpike Culprits (Last 1s):\n", LOG_SPACE);

		int size = spike.Length;
		bool found = false;
		for (int i = 0; i < size; i++)
		{
			spike.GetKey(i, clsname, sizeof clsname);

			int count;
			g_hClassnameTracker.GetValue(clsname, count);

			// Only report if it spawned 5+ times (default) during the spike
			if (count >= MIN_LOG_SPIKE_SPAWN)
			{
				found = true;
				pos += FormatEx(buffer[pos], maxsize - pos, "%s >> Class %s: %d spawns\n", LOG_SPACE, clsname, count);
			}
		}

		if (!found)
			pos += FormatEx(buffer[pos], maxsize - pos, "%s >> (none detected over threshold)\n", LOG_SPACE);
	}

	// Use snapshot (Scrapped a lot of code written with async in mind, now much simpler)
	///ArrayList blackmain = g_iPriorityMode ? g_hBlacklistQueue.Clone() : null;
	///ArrayList slaugmain = g_hSlaughterQueue.Clone();

	ArrayList blackmain = g_iPriorityMode ? g_hBlacklistQueue : null;
	ArrayList slaugmain = g_hSlaughterQueue;
	int size_blmain = blackmain != null ? blackmain.Length : 0;
	int size_slmain = slaugmain.Length;

	// Queue Health Analysis
	int size_blback = g_hBlacklistBackup.Length;
	int size_slback = g_hSlaughterBackup.Length;
	LogDiagInfo(client, buffer, maxsize, pos, "Queues Health:\n%s >> Blacklist: Main: %d, Back: %d | Slaughter: Main: %d, Back: %d | Janitor: %s%s", auto ? LOG_SPACE : "", size_blmain, size_blback, size_slmain, size_slback, g_bCleaning ? "BUSY" : "Idle", g_bGuardPending || g_bCleaningBanned ? " (Aborting)" : "");

	// Queue Classname Count Analysis (Oldest to Newest)
	if (g_hQueueStats == null)
	{
		g_hQueueStats = new StringMap();
		g_hUniqueResults = new ArrayList(ByteCountToCells(MAX_LEN_CLASSNAME)); // Unique classnames
	}
	AnalyzeQueue(client, blackmain, size_blmain, "Blacklist", buffer, maxsize, pos);
	AnalyzeQueue(client, slaugmain, size_slmain, "Slaughter", buffer, maxsize, pos);

	// Strike Watchlist
	if (g_hQuarantineStrikes.Size)
	{
		LogDiagInfo(client, buffer, maxsize, pos, "Strike Watchlist:");
		StringMapSnapshot strike = g_hQuarantineStrikes.Snapshot();

		int strikessize = strike.Length;
		char status[12];
		for (int i = 0; i < strikessize; i++)
		{
			strike.GetKey(i, clsname, sizeof clsname);

			int strikes;
			g_hQuarantineStrikes.GetValue(clsname, strikes);

			if (0 < strikes < QUARANTINE_STRIKE)
			{
				bool critical = strikes == QUARANTINE_STRIKE - 1;
				strcopy(status, sizeof status, critical ? "[CRITICAL]" : "[WARNING]");

				LogDiagInfo(client, buffer, maxsize, pos, " >> [%d/%d] %s %s", strikes, QUARANTINE_STRIKE, clsname, status);
			}
		}

		strike.Close();
	}

	// Active Quarantine (Stubborn Entities)
	if (g_bQuarantined)
	{
		LogDiagInfo(client, buffer, maxsize, pos, "Currently Quarantined (Stubborn - Whitelisted):");

		int qtncount = g_hDynamicWhitelist.Length;
		for (int i = 0; i < qtncount; i++)
		{
			g_hDynamicWhitelist.GetString(i, clsname, sizeof clsname);
			LogDiagInfo(client, buffer, maxsize, pos, " >> %s (Status: IGNORED)", clsname);
		}
	}

	LogDiagInfo(client, buffer, maxsize, pos, auto ? "[End Diag]" : "--- End Diag ---");

	if (auto)
	{
		if (pos)
			LogToFileEx(g_sLogPath, "%s", buffer); // Only one LogToFileEx disk I/O op.
	}
	else ReplyToCommand(client, "%sDiagnostic complete. Results printed to your console (~).", PL_TAG);
}

void AnalyzeQueue(int client, ArrayList queue, int size, const char[] queuename, char[] buffer, int maxlen, int& index)
{
	if (queue == null)
	{
		LogDiagInfo(client, buffer, maxlen, index, "Current %s Queue Contents: (disabled)", queuename);
		return;
	}

	if (!size)
	{
		LogDiagInfo(client, buffer, maxlen, index, "Current %s Queue: (empty)", queuename);
		return;
	}

	g_hQueueStats.Clear();
	g_hUniqueResults.Clear();
	char clsname[MAX_LEN_CLASSNAME];

	for (int i = 0; i < size; i++)
	{
		int ref = queue.Get(i);
		if (ref == INVALID_REFERENCE)
			continue;

		int entity = EntRefToEntIndex(ref);
		if (entity == INVALID_ENT_REFERENCE || g_iDeathMarkedRef[entity] == ref || !IsValidEdict(entity))
			continue;

		if (GetEdictClassname(entity, clsname, sizeof clsname))
		{
			int count = 0;
			if (!g_hQueueStats.GetValue(clsname, count))
				g_hUniqueResults.PushString(clsname); // First time we see this, add it
			g_hQueueStats.SetValue(clsname, ++count);
		}
	}

	int uniques = g_hUniqueResults.Length;
	if (uniques)
	{
		LogDiagInfo(client, buffer, maxlen, index, "Current %s Queue Contents (Oldest First):", queuename);

		for (int i = 0; i < uniques; i++)
		{
			g_hUniqueResults.GetString(i, clsname, sizeof clsname);

			int count;
			g_hQueueStats.GetValue(clsname, count);

			// %3d looks pretty in console and log
			LogDiagInfo(client, buffer, maxlen, index, " >> [%3d] %s", count, clsname);
		}
	}
	else LogDiagInfo(client, buffer, maxlen, index, "Current %s Queue Contents: (no valid entities)", queuename);
}

void LogDiagInfo(int client, char[] buffer, int maxlen, int& index, const char[] format, any...)
{
	static char info[128];
	VFormat(info, sizeof info, format, 6);

	if (client == -1) // Automated
		index += FormatEx(buffer[index], maxlen - index, "%s%s\n", LOG_SPACE, info);
	else PrintToConsole(client, "%s", info); // Use %s in case % is inside formatted str
}

// =============================================================================

Action Command_RunStressTest(int client, int args)
{
	if (IsDisabledOrServer(client))
		return Plugin_Handled;

	int count, framecount;
	if (args < 1 || args > 2 || !GetCmdArgIntEx(1, count) ||
		args == 2 && (framecount = GetCmdArgInt(2)) < 1)
	{
		ReplyToCommand(client, "%sUsage: sm_guardtest <count|0:wipe> [frame:batchCount]", PL_TAG);
		return Plugin_Handled;
	}

	bool useframe = args == 2;

	if (useframe && !g_bFrameComplete) // Another command could sneak in between frame!!
	{
		ReplyToCommand(client, "%sFrame stress test is already running!", PL_TAG);
		return Plugin_Handled;
	}

	if (count > 0)
	{
		g_bStressTesting = true;
		ReplyToCommand(client, "%s%s, spawning %d props... (Peak: %d, Entity Count: %d, Peak Count: %d)", PL_TAG, useframe ? "Starting Frame-spawn (Safe)" : "Starting Instant loop spawn (Risky)", count, FindHighestEntity(), g_iEntityCount, g_iPeakCount);
		PrecacheModel(MODEL_STRESS_TEST);

		if (g_hStressEntities == null)
		{
			g_hStressEntities = new ArrayList();
			g_hStressLookup = new StringMap();
		}

		float pos[3];
		GetClientAbsOrigin(client, pos);

		float ang[3], fwd[3];
		GetClientEyeAngles(client, ang);
		GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

		pos[0] += fwd[0] * 120.0;
		pos[1] += fwd[1] * 120.0;
		pos[2] += 70.0;

		if (useframe)
		{
			g_bFrameComplete = false; // Lock command
			g_iPropSession = g_iRoundSession;

			DataPack test = new DataPack();
			test.WriteCell(GetClientUserId(client));
			test.WriteCell(count);
			test.WriteCell(framecount);
			test.WriteCell(client && IsCommandFromChat() ? true : false);
			test.WriteFloatArray(pos, sizeof pos);

			RequestFrame(Frame_SpawnNext, test);
		}
		else
		{
			for (int i = 0; i < count; i++)
				SpawnStressProp(pos);
			g_bStressTesting = false;
			ReplyToCommand(client, "%sTest complete. Spawned %d props. ([NEW] Peak: %d, Entity Count: %d, Peak Count: %d)\nUse 'sm_guardtest 0' to wipe the stress entities.", PL_TAG, g_hStressEntities.Length, FindHighestEntity(), g_iEntityCount, g_iPeakCount);
		}
	}
	else if (count == 0)
	{
		int killed = WipeStressEntities();
		ReplyToCommand(client, killed != -1 ? "%sRemoved %d stress entities." : "%sNo stress entity found.", PL_TAG, killed);
	}
	else ReplyToCommand(client, "%sInteger value must be 0 or greater.", PL_TAG);

	return Plugin_Handled;
}

void Frame_SpawnNext(DataPack pack)
{
	if (!g_bEnabled || g_iPropSession != g_iRoundSession) // Wiped
	{
		CompleteFrameTest(pack);
		return;
	}

	pack.Reset();

	int client = GetClientOfUserId(pack.ReadCell());
	if (!client)
	{
		CompleteFrameTest(pack);
		WipeStressEntities(); // Auto-wipe if admin rages quit

		return;
	}

	DataPackPos packpos = pack.Position;

	int remaining = pack.ReadCell();
	int batchsize = pack.ReadCell();
	bool ischat = pack.ReadCell();

	if (!remaining)
	{
		// ReplyToCommand doesn't work outside cmd
		char buffer[192];
		FormatEx(buffer, sizeof buffer, "%sTest complete. Spawned %d props (%d per frame). ([NEW] Peak: %d, Entity Count: %d, Peak Count: %d)\nUse 'sm_guardtest 0' to wipe the stress entities.", PL_TAG, g_hStressEntities.Length, batchsize, FindHighestEntity(), g_iEntityCount, g_iPeakCount);

		if (ischat)
			PrintToChat(client, buffer);
		else PrintToConsole(client, buffer);
		CompleteFrameTest(pack);

		return;
	}

	float pos[3];
	pack.ReadFloatArray(pos, sizeof pos);

	for (int i = 0; i < batchsize && remaining > 0; i++)
	{
		SpawnStressProp(pos);
		remaining--;
	}

	pack.Position = packpos;
	pack.WriteCell(remaining);

	RequestFrame(Frame_SpawnNext, pack); // Recursive frame loop
}

void CompleteFrameTest(DataPack datapack)
{
	datapack.Close();
	g_bFrameComplete = true; // Unlock
	g_bStressTesting = false;
}

void SpawnStressProp(const float fixedpos[3])
{
	int prop = CreateEntityByName("prop_dynamic_override"); /// CreateEdict()
	if (prop == -1)
		return;

	int ref = EntIndexToEntRef(prop);

	static char sRef[16];
	IntToString(ref, sRef, sizeof sRef);

	g_hStressEntities.Push(ref);
	g_hStressLookup.SetValue(sRef, true);

	// Scatter the props
	static float propPos[3];
	propPos[0] = fixedpos[0] + GetRandomFloat(-40.0, 40.0);
	propPos[1] = fixedpos[1] + GetRandomFloat(-40.0, 40.0);
	propPos[2] = fixedpos[2] + GetRandomFloat(-40.0, 40.0);

	TeleportEntity(prop, propPos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(prop, "model", MODEL_STRESS_TEST);
	DispatchKeyValue(prop, "solid", "0");
	DispatchSpawn(prop);
}

Action Command_RemoveEntity(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (args < 1 || args > 2)
	{
		ReplyToCommand(client, "%sUsage: sm_guardkill <index> [1:force]", PL_TAG);
		return Plugin_Handled;
	}

	int entity = GetCmdArgInt(1);
	if (!CheckEdictValidity(client, entity))
		return Plugin_Handled;

	if (IsPlayerIndex(entity))
	{
		ReplyToCommand(client, "%sTarget %d is a Player slot! Use sm_kick instead.", PL_TAG, entity);
		return Plugin_Handled;
	}

	if (g_iCreationTick[entity] == GetGameTickCount())
	{
		ReplyToCommand(client, "%sEntity %d is too young to die. Prevented from removal.", PL_TAG, entity);
		return Plugin_Handled;
	}

	char clsname[MAX_LEN_CLASSNAME];
	GetEdictClassname(entity, clsname, sizeof clsname);

	if (IsEntityWhitelisted(clsname))
	{
		ReplyToCommand(client, "%sEntity %d (%s) is protected by the whitelist.", PL_TAG, entity, clsname);
		return Plugin_Handled;
	}

	int ref = EntIndexToEntRef(entity);
	if (g_iDeathMarkedRef[entity] == ref)
	{
		ReplyToCommand(client, "%sEntity %d (%s) exists, but the Entity is already dying.", PL_TAG, entity, clsname);
		return Plugin_Handled;
	}

	g_iDeathMarkedRef[entity] = ref;

	bool isSpotlight = StrEqual(clsname, "point_spotlight");
	bool force = args == 2 && GetCmdArgInt(2) == 1;
	if (force)
	{
		if (isSpotlight)
			KillSpotlightSafely(entity);
		else RemoveEdict(entity);
		ReplyToCommand(client, "%sForced Kill on: %d (%s)", PL_TAG, entity, clsname);
	}
	else
	{
		if (isSpotlight)
			KillSpotlightSafely(entity);
		else KillEntity(entity);
		ReplyToCommand(client, "%sSafe Kill on: %d (%s)", PL_TAG, entity, clsname);
	}

	return Plugin_Handled;
}

Action Command_RemoveAllEntities(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (args != 1)
	{
		ReplyToCommand(client, "%sUsage: sm_guardwipe <classname>", PL_TAG);
		return Plugin_Handled;
	}

	char buffer[MAX_LEN_CLASSNAME];
	GetCmdArg(1, buffer, sizeof buffer);

	TrimString(buffer);

	if (!IsEntityClassnameValid(client, buffer))
		return Plugin_Handled;

	CheckPreSpawnEntityName(client, buffer);
	WipeEntityByClassname(client, buffer);

	return Plugin_Handled;
}

void WipeEntityByClassname(int client, const char[] clsname)
{
	if (client)
	{
		bool ischat = client && IsCommandFromChat();

		// If cmd is from 0/server, buffer will be empty
		char buffer[64];
		ServerCommandExForced(buffer, sizeof buffer, "ent_remove_all", clsname);

		// ServerExecute() swallows if ReplyToCommand is after it, PrintToChat is immune
		if (ischat)
			PrintToChat(client, "%sEngine Wipe: %s.", PL_TAG, buffer);
		else PrintToConsole(client, "%sEngine Wipe: %s.", PL_TAG, buffer);

		return;
	}

	int player = FindRandomPlayer();
	if (player != -1)
		// FakeClientCommandExForced works too (no buffer swallow). Result printed in console
		ClientCommandForced(player, "ent_remove_all", clsname);
	else
	{
		int i = -1, count = 0;
		int tick = GetGameTickCount();
		bool isSpotlight = StrEqual(clsname, "point_spotlight");
		while ((i = FindEntityByClassname(i, clsname)) != -1)
		{
			bool local = i < 0;

			if (!local && g_iCreationTick[i] == tick)
				continue;

			int ref = local ? i : EntIndexToEntRef(i);
			if (ref == -1 || !local && g_iDeathMarkedRef[i] == ref)
				continue;

			if (!local)
				g_iDeathMarkedRef[i] = ref;

			if (isSpotlight)
				KillSpotlightSafely(i);
			else KillEntity(i);
			count++;
		}

		PrintToServer("%sManual Wipe: Removed %d %s entities.", PL_TAG, count, clsname);
	}
}

// Improved from stock C_FindRandomPlayerByTeam
/**
 * Returns the index of a random player in the server.
 *
 * @param inGameOnly	Optional. If false, connected players are counted.
 *						(Forced true if team or aliveOnly is used)
 * @param team			Optional. Team index (1-4) to filter by.
 * @param noBots		Optional. If true, bots are excluded.
 * @param aliveOnly		Optional. If true, only count alive players.
 * @return				Client index, or -1 if no player found.
 */
stock int FindRandomPlayer(bool inGameOnly = true, int team = -1, bool noBots = false, bool aliveOnly = false)
{
	bool checkTeam = team != -1;

	if (checkTeam && (team < 1 || team > 4))
		return -1;

	if (!inGameOnly && (checkTeam || aliveOnly))
		inGameOnly = true;

	int[] players = new int[MaxClients];
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (inGameOnly ? !IsClientInGame(i) : !IsClientConnected(i))
			continue;

		if ((!checkTeam || GetClientTeam(i) == team) &&
			(!noBots || !IsFakeClient(i)) &&
			(!aliveOnly || IsPlayerAlive(i)))
			players[count++] = i;
	}

	return count > 0 ? players[GetRandomInt(0, count - 1)] : -1;
}

Action Command_ToggleCommandCheat(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	static const char usage[] = "%sUsage: sm_guardflags <command> [0:strip|1:add|2:reset]";

	if (args < 1 || args > 2)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	char buffer[32];
	GetCmdArg(1, buffer, sizeof buffer);

	TrimString(buffer);

	if (!IsStringValid(buffer))
	{
		ReplyToCommand(client, "%sError: '%s' contains invalid characters or spaces.", PL_TAG, buffer);
		return Plugin_Handled;
	}

	int flags = GetCommandFlags(buffer);
	if (flags == INVALID_FCVAR_FLAGS)
	{
		ReplyToCommand(client, "%sError: Command '%s' not found.", PL_TAG, buffer);
		return Plugin_Handled;
	}

	if (args == 1)
	{
		int oriflags;
		if (g_hOriginalFlags == null || !g_hOriginalFlags.GetValue(buffer, oriflags))
			oriflags = flags;

		ReplyToCommand(client, "%sFlags for '%s': %d (Cheat: %s, Default: %d)", PL_TAG, buffer, flags, flags & FCVAR_CHEAT ? "Yes" : "No", oriflags);
		return Plugin_Handled;
	}

	int arg2;
	if (!GetCmdArgIntEx(2, arg2))
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	switch (arg2)
	{
		case 0, 1:
		{
			bool addcheat = arg2 == 1;

			char mod[12];
			mod = addcheat ? "added" : "stripped";

			bool hascheat = (flags & FCVAR_CHEAT) != 0;
			if (hascheat == addcheat)
			{
				ReplyToCommand(client, "%sCommand '%s' already has FCVAR_CHEAT %s.", PL_TAG, buffer, mod);
				return Plugin_Handled;
			}

			if (g_hOriginalFlags == null)
				g_hOriginalFlags = new StringMap();

			if (!g_hOriginalFlags.ContainsKey(buffer))
				g_hOriginalFlags.SetValue(buffer, flags); // Save if yet saved before modifying

			SetCommandFlags(buffer, addcheat ? flags | FCVAR_CHEAT : flags & ~FCVAR_CHEAT);
			ReplyToCommand(client, "%sSuccessfully %s FCVAR_CHEAT for '%s'.", PL_TAG, mod, buffer);
		}
		case 2:
		{
			int oriflags;
			if (g_hOriginalFlags == null || !g_hOriginalFlags.GetValue(buffer, oriflags))
			{
				ReplyToCommand(client, "%sNo original state saved for '%s' (already default flags).", PL_TAG, buffer);
				return Plugin_Handled;
			}

			if (flags != oriflags)
			{
				SetCommandFlags(buffer, oriflags);
				ReplyToCommand(client, "%sReverted '%s' to original flags (%d).", PL_TAG, buffer, oriflags);
			}
			else ReplyToCommand(client, "%sNo flags modification detected for '%s'.", PL_TAG, buffer);

			g_hOriginalFlags.Remove(buffer);
			if (!g_hOriginalFlags.Size)
				delete g_hOriginalFlags;
		}
		default: ReplyToCommand(client, usage, PL_TAG);
	}

	return Plugin_Handled;
}

// "%s \"%s\"" fails for command like z_spawn_old "boomer auto"
stock int ClientCommandForced(int client, const char[] command, const char[] args = "", bool fake = true)
{
	int flags = GetCommandFlags(command);
	if (flags == INVALID_FCVAR_FLAGS)
		return INVALID_FCVAR_FLAGS;

	bool hasCheat = flags & FCVAR_CHEAT != 0;

	if (hasCheat)
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);

	if (fake)
		FakeClientCommand(client, args[0] == '\0' ? "%s" : "%s %s", command, args);
	else ClientCommand(client, args[0] == '\0' ? "%s" : "%s %s", command, args);

	if (hasCheat)
		SetCommandFlags(command, flags);
	return flags;
}

// Not used anymore
stock int FakeClientCommandExForced(int client, const char[] command, const char[] args = "")
{
	int flags = GetCommandFlags(command);
	if (flags == INVALID_FCVAR_FLAGS)
		return INVALID_FCVAR_FLAGS;

	if (flags & FCVAR_CHEAT != 0)
	{
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);
		FakeClientCommandEx(client, args[0] == '\0' ? "%s" : "%s %s", command, args);

		DataPack info = new DataPack();
		info.WriteString(command);
		info.WriteCell(flags);

		RequestFrame(Frame_RestoreCommandFlags, info);
	}
	else FakeClientCommandEx(client, args[0] == '\0' ? "%s" : "%s %s", command, args);

	return flags;
}

stock void Frame_RestoreCommandFlags(DataPack pack)
{
	pack.Reset();

	char command[48];
	pack.ReadString(command, sizeof command);

	SetCommandFlags(command, pack.ReadCell());
	pack.Close();
}

Action Command_ClearQuarantine(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (!g_bQuarantined)
	{
		ReplyToCommand(client, "%sDoctor - No active quarantines found. The facility is clean.", PL_TAG);
		return Plugin_Handled;
	}

	g_hQuarantineStrikes.Clear();
	g_hConsecutiveSpawns.Clear();
	ReleaseQuarantine();
	ReplyToCommand(client, "%sDoctor - Reset complete. Quarantine lifted and strike records cleared.", PL_TAG);

	return Plugin_Handled;
}

Action Command_FlushQueues(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (g_bCleaning)
	{
		ReplyToCommand(client, "%sJanitor is already BUSY and swinging broom for you!", PL_TAG);
		return Plugin_Handled;
	}

	if (g_bCleaningBanned)
	{
		ReplyToCommand(client, "%sEntity count is too high (%d). Cleanup is BANNED for safety.", PL_TAG, g_iEntityCount);
		return Plugin_Handled;
	}

	if (g_bGuardPending)
	{
		ReplyToCommand(client, "%sGuard is PENDING. Manual cleanup is currently locked.", PL_TAG);
		return Plugin_Handled;
	}

	int size_black = g_iPriorityMode ? (g_iBlacklistJobs = g_hBlacklistQueue.Length) : 0;
	int size_slaug = g_iSlaughterJobs = g_hSlaughterQueue.Length;

	if (size_black)
		g_iCleaningPhase = Cleaning_Blacklist;
	else if (size_slaug)
		g_iCleaningPhase = Cleaning_Slaughter;
	else
	{
		ReplyToCommand(client, "%sQueue(s) already empty. Nothing to clean.", PL_TAG);
		return Plugin_Handled;
	}

	g_bCleaning = true;
	g_bIsManualCleanup = true;
	g_iTotalKept = g_iTotalDiscarded = 0;

	// 'Processing %d' vs. 'Total: %d' will be identical
	ReplyToCommand(client, "%sManual clean-ups starting: Processing %d items at Ultra speed...", PL_TAG, size_black + size_slaug);
	ExecuteCleanupStep(Janitor_Initial, true);
	ReplyToCommand(client, "%sJanitor - Manual clean-ups done! Kept: %d | Discarded: %d | Total: %d", PL_TAG, g_iTotalKept, g_iTotalDiscarded, g_iTotalKept + g_iTotalDiscarded);

	return Plugin_Handled;
}

Action Command_DumpConfig(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	PrintToConsole(client, "--- %sINTERNAL DATA DUMP ---", PL_TAG);

	DumpMapToConsole(client, "Whitelist", g_hWhitelistClasses);
	DumpMapToConsole(client, "Blacklist", g_hBlacklistClasses);
	DumpMapToConsole(client, "BlacklistFrame", g_hBlacklistClasses_Frame);
	DumpMapToConsole(client, "Trash (Exact)", g_hTrashMap);
	DumpListToConsole(client, "Trash (Wildcards '*')", g_hTrashPartials);
	DumpMapToConsole(client, "Protected (Exact)", g_hProtectedMap);
	DumpListToConsole(client, "Protected (Wildcards '*')", g_hProtectedPartials);
	DumpMapToConsole(client, "Forbidden Quarantine", g_hQuarantineForbidden);

	PrintToConsole(client, "--- END DUMP ---");
	if (client && IsCommandFromChat())
		PrintToChat(client, "%sDebug data dumped to console.", PL_TAG);

	return Plugin_Handled;
}

void DumpMapToConsole(int client, const char[] name, StringMap map)
{
	StringMapSnapshot configs = map.Snapshot();

	int size = configs.Length;
	PrintToConsole(client, ">> Map: %s [%d entries]", name, size);

	char keyname[MAX_LEN_CLASSNAME], suffix[32] = "";
	bool checkdynamic = StrEqual(name, "Whitelist") && g_hDynamicWhitelist.Length;
	for (int i = 0; i < size; i++)
	{
		configs.GetKey(i, keyname, sizeof keyname);

		if (checkdynamic && g_hDynamicWhitelist.FindString(keyname) != -1)
			strcopy(suffix, sizeof suffix, " [DYNAMIC/QUARANTINE]");

		PrintToConsole(client, "   - %s%s", keyname, suffix);
		suffix[0] = 0;
	}

	configs.Close();
}

void DumpListToConsole(int client, const char[] name, ArrayList list)
{
	int size = list.Length;
	PrintToConsole(client, ">> List: %s [%d entries]", name, size);

	char buffer[MAX_LEN_CLASSNAME];
	for (int i = 0; i < size; i++)
	{
		list.GetString(i, buffer, sizeof buffer);
		PrintToConsole(client, "   - (Partial) %s", buffer);
	}
}

Action Command_IgnorePlayer(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	static const char usage[] = "%sUsage: sm_guardplayer [0:off|1:on]",
		info[] = "%sGuard - %s ignoring Player entity (Default: Disabled).";
	switch (args)
	{
		case 0:
		{
			g_bIgnorePlayer = !g_bIgnorePlayer;
			ReplyToCommand(client, info, PL_TAG, g_bIgnorePlayer ? "ENABLED" : "DISABLED");
		}
		case 1:
		{
			int value;
			if (GetCmdArgIntEx(1, value))
			{
				g_bIgnorePlayer = value != 0;
				ReplyToCommand(client, info, PL_TAG, g_bIgnorePlayer ? "ENABLED" : "DISABLED");
			}
			else ReplyToCommand(client, usage, PL_TAG);
		}
		default: ReplyToCommand(client, usage, PL_TAG);
	}

	return Plugin_Handled;
}

Action Command_UpdateEntityCount(int client, int args)
{
	if (!IsPluginDisabled(client))
		SyncEntityCount(false); // Don't mess with peak count while game running!
	return Plugin_Handled;
}

Action Command_WarpToEntity(int client, int args)
{
	if (IsDisabledOrServer(client))
		return Plugin_Handled;

	if (args != 1)
	{
		ReplyToCommand(client, "%sUsage: sm_guardwarp <index>", PL_TAG);
		return Plugin_Handled;
	}

	int entity = GetCmdArgInt(1);
	if (!CheckEdictValidity(client, entity))
		return Plugin_Handled;

	char clsname[MAX_LEN_CLASSNAME];
	GetEdictClassname(entity, clsname, sizeof clsname);

	PerformWarp(client, entity, clsname, true);
	return Plugin_Handled;
}

Action Command_WarpToClassname(int client, int args)
{
	if (IsDisabledOrServer(client))
		return Plugin_Handled;

	if (args < 1 || args > 2)
	{
		ReplyToCommand(client, "%sUsage: sm_guardwarpc <classname|0:reset> [1:newest/goBack]", PL_TAG);
		return Plugin_Handled;
	}

	char targetcls[MAX_LEN_CLASSNAME];
	GetCmdArg(1, targetcls, sizeof targetcls);

	TrimString(targetcls);

	if (IsWarpReset(client, targetcls, false) || !IsEntityClassnameValid(client, targetcls))
		return Plugin_Handled;

	CheckPreSpawnEntityName(client, targetcls);

	if (!StrEqual(targetcls, g_sWarpClass[client])) // New search or changed class
	{
		strcopy(g_sWarpClass[client], sizeof g_sWarpClass[], targetcls);
		g_iWarpIndex[client] = -1;
	}

	// ArrayList which needs .Close() everytime can cause mem. fragmentation?
	// So we use normal array only for small MAX_ENTITIES (Garry's Mod seems to have 8,192)
	#if MAX_ENTITIES > 2048
	ArrayList entities = new ArrayList();

	int i = -1;
	while ((i = FindEntityByClassname(i, targetcls)) != -1)
		entities.Push(i);

	int count = entities.Length;
	#else
	int i = -1, count = 0, entities[MAX_ENTITIES];
	while ((i = FindEntityByClassname(i, targetcls)) != -1 && count < sizeof entities)
		entities[count++] = i;
	#endif

	if (!count)
	{
		ReplyToCommand(client, "%sNo entities found for class: %s", PL_TAG, targetcls);
		#if MAX_ENTITIES > 2048
		entities.Close();
		#endif

		return Plugin_Handled;
	}

	CycleWarpIndex(client, count, args, false);
	#if MAX_ENTITIES > 2048
	PerformWarp(client, entities.Get(g_iWarpIndex[client]), targetcls, false, g_iWarpIndex[client], count);
	entities.Close();
	#else
	PerformWarp(client, entities[g_iWarpIndex[client]], targetcls, false, g_iWarpIndex[client], count);
	#endif

	return Plugin_Handled;
}

Action Command_WarpToVictim(int client, int args)
{
	if (IsDisabledOrServer(client))
		return Plugin_Handled;

	static const char usage[] = "%sUsage: sm_guardwarpq <1:black|2:slaug> <classname|0:reset> [1:newest/goBack]";

	if (args < 2 || args > 3)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	char targetcls[MAX_LEN_CLASSNAME];
	GetCmdArg(2, targetcls, sizeof targetcls);

	TrimString(targetcls);

	if (IsWarpReset(client, targetcls, true) || !IsEntityClassnameValid(client, targetcls))
		return Plugin_Handled;

	int type = GetCmdArgInt(1);
	if (!type)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	CheckPreSpawnEntityName(client, targetcls);

	if (g_iWarpQueueType[client] != type || !StrEqual(targetcls, g_sWarpClass[client]))
	{
		strcopy(g_sWarpClass[client], MAX_LEN_CLASSNAME, targetcls);
		g_iWarpQueueType[client] = type;
		g_iWarpIndex[client] = -1;
	}

	ArrayList queue = type == 1 ? g_hBlacklistQueue : g_hSlaughterQueue;
	int queuesize = queue.Length;

	if (!queuesize)
	{
		ReplyToCommand(client, "%sThe requested queue is empty.", PL_TAG);
		return Plugin_Handled;
	}

	#if MAX_ENTITIES > 2048
	ArrayList entities = new ArrayList();
	#else
	int count = 0, entities[MAX_ENTITIES];
	#endif

	char clsname[MAX_LEN_CLASSNAME];
	for (int i = 0; i < queuesize; i++)
	{
		int entity = EntRefToEntIndex(queue.Get(i));
		if (entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && GetEdictClassname(entity, clsname, sizeof clsname) && StrEqual(clsname, targetcls))
	#if MAX_ENTITIES > 2048
			entities.Push(entity);
	}

	int count = entities.Length;
	#else
			entities[count++] = entity;
	}
	#endif

	if (!count)
	{
		ReplyToCommand(client, "%sNo '%s' found in %s queue.", PL_TAG, targetcls, type == 1 ? "Blacklist" : "Slaughter");
		#if MAX_ENTITIES > 2048
		entities.Close();
		#endif

		return Plugin_Handled;
	}

	CycleWarpIndex(client, count, args, true);
	#if MAX_ENTITIES > 2048
	PerformWarp(client, entities.Get(g_iWarpIndex[client]), targetcls, false, g_iWarpIndex[client], count);
	entities.Close();
	#else
	PerformWarp(client, entities[g_iWarpIndex[client]], targetcls, false, g_iWarpIndex[client], count);
	#endif

	return Plugin_Handled;
}

void CycleWarpIndex(int client, int count, int args, bool isqueue)
{
	int argvalue = isqueue ? 3 : 2;
	bool newest = args == argvalue && GetCmdArgInt(argvalue) == 1;

	if (newest)
	{
		g_iWarpIndex[client]--;
		if (g_iWarpIndex[client] < 0 || g_iWarpIndex[client] >= count) // Count can decrease
			g_iWarpIndex[client] = count - 1;
	}
	else
	{
		g_iWarpIndex[client]++;
		if (g_iWarpIndex[client] < 0 || g_iWarpIndex[client] >= count)
			g_iWarpIndex[client] = 0;
	}
}

void PerformWarp(int client, int target, const char[] class, bool basic, int current = 0, int total = 0)
{
	float pos[3];
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos);
	///GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos); // Prop_Data works too

	pos[2] += 50.0;
	TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);

	if (basic)
		ReplyToCommand(client, "%sTeleported to Entity %d (%s).", PL_TAG, target, class);
	else ReplyToCommand(client, "%s[%d/%d] Warped to %s (Index: %d).", PL_TAG, current + 1, total, class, target); // +1 for UI [1/10]
}

bool IsDisabledOrServer(int client)
{
	if (IsPluginDisabled(client))
		return true;

	if (!client)
	{
		ReplyToCommand(client, "%sCommand must be used %s", PL_TAG, IsDedicatedServer() ? "in game on a dedicated server." : "in chat on a listen server.");
		return true;
	}

	return false;
}

bool IsWarpReset(int client, const char[] buffer, bool isqueue)
{
	if (StrEqual(buffer, "0"))
	{
		g_iWarpIndex[client] = -1;
		g_sWarpClass[client][0] = '\0';
		if (isqueue)
			g_iWarpQueueType[client] = 0;

		ReplyToCommand(client, "%sWarp %s index reset.", PL_TAG, isqueue ? "victim" : "class");
		return true;
	}

	return false;
}

Action Command_ReloadConfig(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (args > 1)
	{
		ReplyToCommand(client, "%sUsage: sm_guardreload [1:applyRules]", PL_TAG);
		return Plugin_Handled;
	}

	LoadGuardConfig();

	if (args == 1 && GetCmdArgInt(1) == 1)
	{
		PopulateQueuesWithExistingEntities();
		ReplyToCommand(client, "%sConfiguration reloaded and current rules applied successfully.", PL_TAG);
	}
	else ReplyToCommand(client, "%sConfiguration reloaded successfully.", PL_TAG);

	return Plugin_Handled;
}

Action Command_RunDiagnostics(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (!g_bAuditAllowed || g_bRoundEnded)
	{
		ReplyToCommand(client, "%sAuditor - %s. Diagnostics suspended.", PL_TAG, !g_bAuditAllowed ? "Map stage too early (garbage data)" : "Round just ended");
		return Plugin_Handled;
	}

	if (g_bAuditing)
	{
		ReplyToCommand(client, "%sAuditor - Audit is currently sampling data. Please wait.", PL_TAG);
		return Plugin_Handled;
	}

	RunInternalDiagnostic(client);
	return Plugin_Handled;
}

Action Command_GetEntityClass(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	if (args != 1)
	{
		ReplyToCommand(client, "%sUsage: sm_guardclass <index>", PL_TAG);
		return Plugin_Handled;
	}

	int entity = GetCmdArgInt(1);
	if (!CheckEdictValidity(client, entity))
		return Plugin_Handled;

	char clsname[MAX_LEN_CLASSNAME];
	GetEdictClassname(entity, clsname, sizeof clsname);

	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos); // Abs - Data map only

	ReplyToCommand(client, "%sIdx %d - Cls: %s | Ref: %d | Pos: %.0f %.0f %.0f", PL_TAG, entity, clsname, EntIndexToEntRef(entity), pos[0], pos[1], pos[2]);
	return Plugin_Handled;
}

bool CheckEdictValidity(int client, int entity)
{
	if (!entity)
	{
		ReplyToCommand(client, "%sIndex 0 (worldspawn) is protected or input is not a number.", PL_TAG, entity);
		return false;
	}

	if (!IsValidEntity(entity))
	{
		ReplyToCommand(client, "%sEntity %d does not exist (already removed or invalid index).", PL_TAG, entity);
		return false;
	}

	if (!IsValidEdict(entity))
	{
		ReplyToCommand(client, "%sEntity %d is a valid entity, it is not an edict or the edict slot has been freed.", PL_TAG, entity);
		return false;
	}

	return true;
}

Action Command_IsEdictByClassname(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	static const char usage[] = "%sUsage: sm_guardedict <classname> [1:listIndices]";

	if (args < 1 || args > 2)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	char targetcls[MAX_LEN_CLASSNAME];
	GetCmdArg(1, targetcls, sizeof targetcls);

	TrimString(targetcls);

	if (!IsEntityClassnameValid(client, targetcls, true) || args == 1)
		return Plugin_Handled;

	if (GetCmdArgInt(2) != 1)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	CheckPreSpawnEntityName(client, targetcls);
	if (client && IsCommandFromChat())
		PrintToChat(client, "%sDumping entity list for '%s' to console...", PL_TAG, targetcls);

	char buffer[MAX_LEN_LARGE_BUFF];
	FormatEx(buffer, sizeof buffer, "--- Entity List for: %s ---\n", targetcls);

	int i = -1, count = 0, zerocount = 0;
	bool checkblack = g_hBlacklistQueue.Length != 0; // No items in mode 0
	char queuelabel[24] = "", line[96];
	float pos[3];
	while ((i = FindEntityByClassname(i, targetcls)) != -1)
	{
		count++;
		bool local = i < 0;
		int ref = local ? i : EntIndexToEntRef(i);

		if (checkblack && !local && g_hBlacklistQueue.FindValue(ref) != -1)
			strcopy(queuelabel, sizeof queuelabel, " [BLACKLIST QUEUE]");
		else if (!local && g_hSlaughterQueue.FindValue(ref) != -1)
			strcopy(queuelabel, sizeof queuelabel, " [SLAUGHTER QUEUE]");
		else queuelabel[0] = 0;

		// m_vecOrigin seemed inaccurate sometimes, it found some 0,0,0 ents, while Abs found none
		GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos);

		if (!pos[0] && !pos[1] && !pos[2])
			zerocount++;

		FormatEx(line, sizeof line, "Idx: %4d | Ref: %d | Pos: %6.0f %6.0f %6.0f%s\n", !local ? i : -1, ref, pos[0], pos[1], pos[2], queuelabel);
		StrCat(buffer, sizeof buffer, line);

		if (strlen(buffer) > sizeof buffer - 200) // Buffer is getting full
		{
			PrintLargeBuffer(client, buffer);
			buffer[0] = '\0';
		}
	}

	if (!count)
		StrCat(buffer, sizeof buffer, "No entities found in-game.\n");
	else
	{
		char summary[64];
		FormatEx(summary, sizeof summary, "--- Summary: %d total | %d at (0,0,0) ---\n", count, zerocount);

		StrCat(buffer, sizeof buffer, summary);
	}

	PrintLargeBuffer(client, buffer);
	return Plugin_Handled;
}

bool IsEntityClassnameValid(int client, const char[] clsname, bool statusreply = false)
{
	if (!IsStringValid(clsname))
	{
		ReplyToCommand(client, "%sError: '%s' contains invalid characters or spaces.", PL_TAG, clsname);
		return false;
	}

	int status = CheckEdictStatusByName(clsname);
	switch (status)
	{
		case -1:
		{
			ReplyToCommand(client, "%sFAILED to create '%s' (Invalid classname or engine restriction).", PL_TAG, clsname);
			return false;
		}
		case 0: if (statusreply)
			ReplyToCommand(client, "%s'%s' is NOT an edict (it is a local entity).", PL_TAG, clsname);
		case 1: if (statusreply)
			ReplyToCommand(client, "%s'%s' is an edict.", PL_TAG, clsname);
	}

	return true;
}

stock bool IsStringValid(const char[] str)
{
	if (str[0] == '\0')
		return false;

	for (int i = 0; str[i] != '\0'; i++)
	{
		switch (str[i])
		{
			case '/', '\\', ':', '*', '?', '"', '<', '>', '|': return false;
		}

		if (IsCharSpace(str[i])) // Also filter \t, \n etc. unlike StrContains(" ")
			return false;
	}

	return true;
}

/**
 * Returns the edict status of an entity's classname.
 *
 * @param clsname		The entity classname to test.
 * @return				1 if it's an edict,
 *						0 if it's a local entity (non-edict), or
 *						-1 if classname is invalid or engine restriction.
 */
stock int CheckEdictStatusByName(const char[] clsname)
{
	int entity = CreateEntityByName(clsname);
	if (entity == -1)
		return -1;

	if (IsValidEdict(entity))
	{
		RemoveEdict(entity);
		return 1;
	}

	AcceptEntityInput(entity, "Kill");
	return 0;
}

void CheckPreSpawnEntityName(int client, const char[] clsname)
{
	bool isdynamic = false;
	bool matched = false;
	switch (clsname[0])
	{
		case 'd': if (StrEqual(clsname, "dynamic_prop"))
			isdynamic = matched = true;
		case 'p': if (StrEqual(clsname, "prop_dynamic_override"))
			isdynamic = matched = true;
		else if (StrEqual(clsname, "prop_physics_override") || StrEqual(clsname, "physics_prop"))
			matched = true;
	}

	if (matched)
		ReplyToCommand(client, "%sDid you mean this '%s' in-game entities?", PL_TAG, isdynamic ? "prop_dynamic" : "prop_physics");
}

Action Command_DisplayStatus(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	char buffer[MAX_LEN_REPORT];
	ServerCommandExForced(buffer, sizeof buffer, "report_entities");

	int entities = ParseEdictCountFromReport(buffer);
	bool manual = false;
	char manualinfo[32] = "";
	if (entities == -1)
	{
		manual = true;
		entities = CountEdicts();
		PrintToServer("%sCommand report_entities returned no data. Manual count is shown instead.", PL_TAG);
	}
	else FormatEx(manualinfo, sizeof manualinfo, " | Manual: %d", CountEdicts());

	char threshold[12];
	GetThresholdName(threshold, sizeof threshold, g_iEntityCount);

	// Internal always matches engine so far, hibernation is a different story
	// Max length for ReplyToCommand seems to be 127, so use separately
	ReplyToCommand(client, "%s--- Entity Status ---\nCount: [SM: ~%d, %s: %d, Internal: %d (%s)]/%d", PL_TAG, GetEntityCount(), !manual ? "Engine" : "Manual", entities, g_iEntityCount, threshold, MAX_ENTITIES);
	ReplyToCommand(client, "Peak Count: %d | Peak Index: %d/%d%s", g_iPeakCount, FindHighestEntity(), MAX_ENTITIES - 1, manualinfo);

	int size_blmain = g_hBlacklistQueue.Length;
	int size_blback = g_hBlacklistBackup.Length;
	int size_slmain = g_hSlaughterQueue.Length;
	int size_slback = g_hSlaughterBackup.Length;
	ReplyToCommand(client, "%s--- Queue Status ---\nBlacklist: Main: %d, Back: %d | Slaughter: Main: %d, Back: %d", PL_TAG, size_blmain, size_blback, size_slmain, size_slback);
	int totalcurrent = size_blmain + size_blback + size_slmain + size_slback;
	int difference = totalcurrent - g_iInitialPopulation;

	char change[16];
	if (difference > 0)
		strcopy(change, sizeof change, "Growth");
	else if (difference < 0)
	{
		strcopy(change, sizeof change, "Shrink");
		difference = -difference;
	}
	else strcopy(change, sizeof change, "Net Change");

	char idletype[16] = "";
	if (g_bGuardPending)
		strcopy(idletype, sizeof idletype, " (Aborting)");
	else if (g_bCleaningBanned)
		strcopy(idletype, sizeof idletype, " (Banned)");

	ReplyToCommand(client, "%s: %d | Janitor: %s%s | Quarantine: %d", change, difference, g_bCleaning ? "BUSY" : "Idle", idletype, g_hDynamicWhitelist.Length);
	return Plugin_Handled;
}

stock int FindHighestEntity()
{
	int maxentity = GetMaxEntities() - 1;
	for (int i = maxentity; i > 0; i--)
		if (IsValidEdict(i))
			return i;

	return 0;
}

Action Command_PrintEntityMap(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	PrintToConsole(client, "%sEntity map:", PL_TAG);
	PrintEdictMap(client, MAX_ENTITIES);

	int frees[MAX_ENTITIES];
	int count = FindEdictHoles(frees, sizeof frees, MAX_ENTITIES);

	PrintToConsole(client, "%sAvailable entity slots:", PL_TAG);
	PrintToConsole(client, "Found %d free edict slots.", count);

	if (count)
	{
		char buffer[512];
		int len = strcopy(buffer, sizeof buffer, "First 20 holes: ");

		int limit = count > 20 ? 20 : count;
		for (int i = 0; i < limit; i++)
			len += FormatEx(buffer[len], sizeof buffer - len, "%d%s",
				frees[i], i < limit - 1 ? ", " : "");

		PrintToConsole(client, "%s...", buffer);
	}

	if (client && IsCommandFromChat())
		PrintToChat(client, "%sEntity map printed to your console (~).", PL_TAG);
	return Plugin_Handled;
}

/**
 * Prints a visual map of edict utilization to the console.
 *
 * @param client		Client index to print to.
 * @param maxEdicts		Maximum number of edicts.
 * @param bucketSize	How many slots one character represents.
 * @param bucketsPerLine How many characters to print before wrapping.
 */
stock void PrintEdictMap(int client, int maxEdicts, int bucketSize = 32, int bucketsPerLine = 32)
{
	PrintToConsole(client, "--- Edict Utilization Map (0 to %d) ---", maxEdicts - 1);
	PrintToConsole(client, "Legend: [.]=Empty  [*]=Mixed  [!]=Full");

	int totalBuckets = maxEdicts / bucketSize;
	int charCount = 0;
	char[] line = new char[bucketsPerLine + 1];
	for (int b = 0; b < totalBuckets; b++)
	{
		int base = b * bucketSize;
		int occupied = 0;
		for (int i = 0; i < bucketSize; i++)
			if (IsValidEdict(base + i))
				occupied++;

		if (occupied == 0)
			line[charCount] = '.';
		else if (occupied == bucketSize)
			line[charCount] = '!';
		else line[charCount] = '*';

		charCount++;

		if (charCount == bucketsPerLine || b == totalBuckets - 1)
		{
			line[charCount] = '\0';
			PrintToConsole(client, "| %s |", line);

			charCount = 0;
		}
	}

	PrintToConsole(client, "---------------------------------------");
}

/**
 * Fills an array with the indices of free edict slots, excluding client slots.
 *
 * @param buffer		Array to store the free indices.
 * @param bufferSize	Size of the buffer array.
 * @param maxEdicts		Maximum number of edicts.
 * @return				Total number of free slots found.
 */
stock int FindEdictHoles(int[] buffer, int bufferSize, int maxEdicts)
{
	int found = 0;
	for (int i = MaxClients + 1; i < maxEdicts; i++)
	{
		if (IsValidEdict(i))
			continue;

		if (found < bufferSize)
			buffer[found] = i;

		found++;
	}

	return found;
}

Action Command_LogEntityReport(int client, int args)
{
	if (IsPluginDisabled(client))
		return Plugin_Handled;

	static const char usage[] = "%sUsage: sm_guardreport [1:manual]";

	if (args > 1)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	int value = args == 1 ? GetCmdArgInt(1) : 0;
	if (args == 1 && value != 1)
	{
		ReplyToCommand(client, usage, PL_TAG);
		return Plugin_Handled;
	}

	bool manual = args == 1 && value == 1;
	if (client)
		if (manual)
			ReportEntityClassnames(client);
		else
		{
			bool ischat = client && IsCommandFromChat();

			char buffer[MAX_LEN_REPORT];
			ServerCommandExForced(buffer, sizeof buffer, "report_entities");

			PrintToConsole(client, "--- Entity Classnames Report ---");
			PrintLargeBuffer(client, buffer);
			if (ischat)
				PrintToChat(client, "%sEntity Class Report sent to console (~).", PL_TAG);
		}
	// Using cmd in server gives an empty buffer (ServerExecute's side effect)
	else
	{
		int player = FindRandomPlayer();
		if (manual || player == -1)
			ReportEntityClassnames(0);
		else
		{
			PrintToServer("--- Entity Classnames Report ---");
			ClientCommandForced(player, "report_entities");
		}
	}

	return Plugin_Handled;
}

stock bool IsCommandFromChat()
{
	return GetCmdReplySource() == SM_REPLY_TO_CHAT;
}

// Have to fight using manual spaces like this "   L" because right alignment don't get respected if we use left alignment before it. SM bug or console bug?
/**
 * Prints a summary of classname frequencies to the specified client's console
 * or the server.
 *
 * Note: Each classname is tagged with E for Edicts or L for Local entities.
 * In certain games, report_entities does not show if a classname is an edict.
 *
 * @param client		Client index to receive the report, or 0 for server.
 */
stock void ReportEntityClassnames(int client)
{
	int i = -1;
	char classname[48];

	int localCount = 0, edictCount = 0, failCount = 0;
	StringMap class = new StringMap(), type = new StringMap();
	ArrayList sorted = new ArrayList(ByteCountToCells(sizeof classname));
	while ((i = FindEntityByClassname(i, "*")) != -1)
	{
		bool local = i < 0;

		if (local)
			localCount++;
		else edictCount++;

		if (!GetEntityClassname(i, classname, sizeof classname))
		{
			failCount++;
			continue;
		}

		int count = 0;
		if (!class.GetValue(classname, count))
		{
			type.SetValue(classname, local);
			sorted.PushString(classname);
		}

		class.SetValue(classname, ++count);
	}

	int size = class.Size;
	int totalEntities = localCount + edictCount;
	sorted.Sort(Sort_Ascending, Sort_String);

	PrintToConsole(client, "--- Entity Classnames Report ---");
	PrintToConsole(client, "%-38s%6s%7s%7s", "Classname", "Type", "Count", "Percent");
	PrintToConsole(client, "----------------------------------------------------------");

	for (i = 0; i < size; i++)
	{
		sorted.GetString(i, classname, sizeof classname);

		int count;
		bool local;
		class.GetValue(classname, count);
		type.GetValue(classname, local);

		float percent = totalEntities > 0 ? (float(count) / totalEntities) * 100.0 : 0.0;
		PrintToConsole(client, "%-38s%6s%5d%8.2f%%", classname, local ? "   L" : "   E", count, percent);
	}

	class.Close();
	type.Close();
	sorted.Close();

	PrintToConsole(client, "----------------------------------------------------------");
	PrintToConsole(client, "Summary: %d Total (%d Local | %d Edicts) | %d Classes", totalEntities, localCount, edictCount, size);
	if (failCount > 0)
		PrintToConsole(client, "(Note: %d entities failed classname lookup)", failCount);
	PrintToConsole(client, "--- End Report ---");
	if (client != 0)
		PrintToChat(client, "[SM] Entity Class Report sent to console (~).");
}

/**
 * Prints a large buffer to a client or server console without truncation.
 *
 * Note: Engine truncates PrintToConsole/PrintToServer at ~1,021 characters
 * (~1,056 for ServerCommandEx buffer). This function bypasses these limits by
 * chunking output into 512-byte segments.
 *
 * @param client		Client index to print to, or 0 for server console.
 * @param buffer		The string buffer to be printed.
 */
stock void PrintLargeBuffer(int client, const char[] buffer)
{
	int linePos = 0;
	char line[512];

	int len = strlen(buffer);
	int lastLine = sizeof line - 1;
	for (int i = 0; i < len; i++)
	{
		char bufferPos = buffer[i];

		if (bufferPos == '\n' || linePos >= lastLine)
		{
			line[linePos] = '\0';
			linePos = 0;

			PrintToConsole(client, "%s", line);

			if (bufferPos == '\n')
				continue; // Don't add newline to the next line buffer
		}

		if (bufferPos != '\r') // For Windows
			line[linePos++] = bufferPos;
	}

	if (linePos > 0)
	{
		// Print remaining text
		line[linePos] = '\0';
		PrintToConsole(client, "%s", line);
	}
}

bool IsPluginDisabled(int client)
{
	if (!g_bEnabled)
	{
		ReplyToCommand(client, "%sEntity Guard is currently disabled.", PL_TAG);
		return true;
	}

	return false;
}
