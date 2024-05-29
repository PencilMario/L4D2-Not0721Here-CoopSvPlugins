#pragma semicolon 1
#pragma newdecls required

// #define DEBUG 1
#define PLUGIN_VERSION "1.1"

#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <sdkhooks>
#include <left4dhooks>
#include <jutils>
#include <l4d_info_editor>
#undef REQUIRE_PLUGIN
#include <l4d2_skill_detect>

// SETTINGS

// Each coordinate (x,y,z) is rounded to nearest multiple of this. 
#define HEATMAP_POINT_SIZE 10
#define MAX_HEATMAP_VISUALS 200
#define HEATMAP_PAGINATION_SIZE 500

public Plugin myinfo = 
{
	name =  "L4D2 Stats Recorder", 
	author = "jackzmc", 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://github.com/Jackzmc/sourcemod-plugins"
};

static ConVar hServerTags, hZDifficulty, hClownMode, hPopulationClowns, hMinShove, hMaxShove, hClownModeChangeChance;
ConVar hHeatmapInterval;
ConVar hHeatmapActive;
static Handle hHonkCounterTimer;
Database g_db;
static char gamemode[32], serverTags[255];
static bool lateLoaded; //Has finale started?

int g_iLastBoomUser;
float g_iLastBoomTime;

enum struct Game {
	int difficulty;
	int startTime;
	int finaleStartTime;
	int clownHonks;
	bool isVersusSwitched;
	bool finished; // finale_vehicle_ready triggered
	bool submitted; // finale_win triggered
	char gamemode[32];
	char uuid[64];
	char name[64];
	bool isCustomMap;

	bool IsVersusMode() {
		return StrEqual(this.gamemode, "versus") || StrEqual(this.gamemode, "scavenge");
	}

	void GetMap() {
		GetCurrentMap(this.name, sizeof(this.name));
		this.isCustomMap = this.name[0] != 'c' || !IsCharNumeric(this.name[1]) || this.name[2] != 'm';
	}
}

enum PointRecordType {
	PType_Generic = 0,
	PType_FinishCampaign,
	PType_CommonKill,
	PType_SpecialKill,
	PType_TankKill,
	PType_WitchKill,
	PType_TankKill_Solo,
	PType_TankKill_Melee,
	PType_Headshot,
	PType_FriendlyFire,
	PType_HealOther,
	PType_ReviveOther,
	PType_ResurrectOther,
	PType_DeployAmmo
}

enum struct WeaponStatistics {
	float minutesUsed;
	int totalDamage;
	int headshots;
	int kills;
}

#define MAX_VALID_WEAPONS 19
char VALID_WEAPONS[MAX_VALID_WEAPONS][] = {
	"weapon_melee", "weapon_chainsaw", "weapon_rifle_sg552", "weapon_smg", "weapon_rifle_ak47", "weapon_rifle", "weapon_rifle_desert", "weapon_pistol", "weapon_pistol_magnum", "weapon_autoshotgun", "weapon_shotgun_chrome", "weapon_sniper_scout", "weapon_sniper_military", "weapon_sniper_awp", "weapon_smg_silenced", "weapon_smg_mp5", "weapon_shotgun_spas", "weapon_rifle_m60", "weapon_pumpshotgun"
};

enum struct ActiveWeaponData {
	StringMap pendingStats;
	char classname[32];
	int pickupTime;
	int damage;
	int kills;
	int headshots;

	void Init() {
		this.Reset();
		this.pendingStats = new StringMap();
	}

	void Reset(bool full = false) {
		this.classname[0] = '\0';
		this.damage = 0;
		this.kills = 0;
		this.headshots = 0;
		this.pickupTime = 0;
		if(full) {
			this.Flush();
		}
	}

	void Flush() {
		if(this.pendingStats != null) {
			this.pendingStats.Clear();
		}
	}

	void SetActiveWeapon(int weapon) {
		if(this.pendingStats == null || !IsValidEntity(weapon)) return;

		// If there was a previous active weapon, up its data before we reset
		if(this.classname[0] != '\0') {
			WeaponStatistics stats;
			this.pendingStats.GetArray(this.classname, stats, sizeof(stats));
			stats.totalDamage += this.damage;
			stats.kills += this.kills;
			stats.headshots += this.headshots;
			if(this.pickupTime != 0)
				stats.minutesUsed += (GetTime() - this.pickupTime);
			this.pendingStats.SetArray(this.classname, stats, sizeof(stats));
		}

		// Reset the data for the new cur weapon
		this.Reset();

		// Check if it's a valid weapon
		char classname[32];
		GetEntityClassname(weapon, classname, sizeof(classname));
		for(int i = 0; i < MAX_VALID_WEAPONS; i++) {
			if(StrEqual(VALID_WEAPONS[i], classname)) {
				this.pickupTime = GetTime();
				if(StrEqual(classname, "weapon_melee")) {
					GetEntPropString(weapon, Prop_Data, "m_strMapSetScriptName", this.classname, sizeof(this.classname));
				} else {
					strcopy(this.classname, sizeof(this.classname), classname);
				}
				break;
			}
		}
	}
}

enum struct Player {
	char steamid[32];
	int damageSurvivorGiven;
	int damageInfectedRec;
	int damageInfectedGiven;
	int damageSurvivorFF;
	int damageSurvivorFFCount;
	int damageFFTaken;
	int damageFFTakenCount;
	int doorOpens;
	int witchKills;
	int startedPlaying;
	int points;
	int upgradePacksDeployed;
	int finaleTimeStart;
	int molotovDamage;
	int pipeKills;
	int molotovKills;
	int minigunKills;
	int clownsHonked;

	//Used for table: stats_games;
	int m_checkpointZombieKills;
	int m_checkpointSurvivorDamage;
	int m_checkpointMedkitsUsed;
	int m_checkpointPillsUsed;
	int m_checkpointMolotovsUsed;
	int m_checkpointPipebombsUsed;
	int m_checkpointBoomerBilesUsed;
	int m_checkpointAdrenalinesUsed;
	int m_checkpointDefibrillatorsUsed;
	int m_checkpointDamageTaken;
	int m_checkpointReviveOtherCount;
	int m_checkpointFirstAidShared;
	int m_checkpointIncaps;
	int m_checkpointAccuracy;
	int m_checkpointDeaths;
	int m_checkpointMeleeKills;
	int sBoomerKills;
	int sSmokerKills;
	int sJockeyKills;
	int sHunterKills;
	int sSpitterKills;
	int sChargerKills;

	// Pulled from database:
	int connections;
	int firstJoinedTime; // When user first joined server (first recorded statistics)
	int lastJoinedTime; // When the user last connected

	int joinedGameTime; // When user joined game session (not connected)

	ActiveWeaponData wpn;

	int idleStartTime;
	int totalIdleTime;

	ArrayList pointsQueue;
	ArrayList pendingHeatmaps;

	void Init() {
		this.wpn.Init();
		this.pointsQueue = new ArrayList(3); // [ type, amount, time ]
		this.pendingHeatmaps = new ArrayList(sizeof(PendingHeatMapData));
	}

	void RecordHeatMap(HeatMapType type, const float pos[3]) {
		if(!hHeatmapActive.BoolValue || this.pendingHeatmaps == null) return;
		PendingHeatMapData hmd;
		hmd.timestamp = GetTime();
		hmd.type = type;
		int intPos[3];
		intPos[0] = RoundFloat(pos[0] / float(HEATMAP_POINT_SIZE)) * HEATMAP_POINT_SIZE;
		intPos[1] = RoundFloat(pos[1] / float(HEATMAP_POINT_SIZE)) * HEATMAP_POINT_SIZE;
		intPos[2] = RoundFloat(pos[2] / float(HEATMAP_POINT_SIZE)) * HEATMAP_POINT_SIZE;
		hmd.pos = intPos;
		this.pendingHeatmaps.PushArray(hmd);
	}

	void ResetFull() {
		this.steamid[0] = '\0';
		this.points = 0;
		this.idleStartTime = 0;
		this.totalIdleTime = 0;
		if(this.pointsQueue != null)
			this.pointsQueue.Clear();
		if(this.pendingHeatmaps != null) {
			this.pendingHeatmaps.Clear();
		}
		this.wpn.Reset(true);
	}

	void RecordPoint(PointRecordType type, int amount = 1) {
		this.points += amount;
		// Common kills are too spammy 
		if(type != PType_CommonKill) {
			int index = this.pointsQueue.Push(type);
			this.pointsQueue.Set(index, amount, 1);
			this.pointsQueue.Set(index, GetTime(), 2);
		}
	}
}
Player players[MAXPLAYERS+1];
Game game;

#include <stats/heatmaps.sp>

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("Stats_GetPoints", Native_GetPoints);
	if(late) lateLoaded = true;
	return APLRes_Success;
}
//TODO: player_use (Check laser sights usage)
//TODO: Versus as infected stats
//TODO: Move kills to queue stats not on demand
//TODO: Track if lasers were had?

public void OnPluginStart() {
	EngineVersion g_Game = GetEngineVersion();
	if(g_Game != Engine_Left4Dead2) {
		SetFailState("This plugin is for L4D/L4D2 only.");	
	}
	if(!SQL_CheckConfig("stats")) {
		SetFailState("No database entry for 'stats'; no database to connect to.");
	} else if(!ConnectDB()) {
		SetFailState("Failed to connect to database.");
	}

	if(lateLoaded) {
		//If plugin late loaded, grab all real user's steamids again, then recreate user
		for(int i = 1; i <= MaxClients; i++) {
			if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) {
				char steamid[32];
				GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid));
				//Recreate user (grabs points, so it won't reset)
				SetupUserInDB(i, steamid);
			}
		}
	}

	hClownModeChangeChance = CreateConVar("l4d2_clown_mutate_chance", "0.3", "Percent chance of population changing", FCVAR_NONE, true, 0.0, true, 1.0);
	hClownMode = CreateConVar("l4d2_honk_mode", "0", "Shows a live clown honk count and increased shove amount.\n0 = OFF, 1 = ON, 2 = Randomly change population", FCVAR_NONE, true, 0.0, true, 2.0);
	hMinShove = FindConVar("z_gun_swing_coop_min_penalty");
	hMaxShove = FindConVar("z_gun_swing_coop_max_penalty");

	hClownMode.AddChangeHook(CVC_ClownModeChanged);

	hServerTags = CreateConVar("l4d2_statsrecorder_tags", "", "A comma-seperated list of tags that will be used to identity this server.");
	hServerTags.GetString(serverTags, sizeof(serverTags));
	hServerTags.AddChangeHook(CVC_TagsChanged);

	ConVar hGamemode = FindConVar("mp_gamemode");
	hGamemode.GetString(gamemode, sizeof(gamemode));
	hGamemode.AddChangeHook(CVC_GamemodeChange);

	hZDifficulty = FindConVar("z_difficulty");

	hHeatmapActive = CreateConVar("l4d2_statsrecorder_heatmaps_enabled", "1", "Should heatmap data be recorded? 1 for ON. Visualize heatmaps with /heatmaps", FCVAR_NONE, true, 0.1);
	hHeatmapInterval = CreateConVar("l4d2_statsrecorder_heatmap_interval", "60", "Determines how often position heatmaps are recorded in seconds.", FCVAR_NONE, true, 0.1);


	HookEvent("player_bot_replace", Event_PlayerEnterIdle);
	HookEvent("bot_player_replace", Event_PlayerLeaveIdle);
	//Hook all events to track statistics
	HookEvent("player_disconnect", Event_PlayerFullDisconnect);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_incapacitated", Event_PlayerIncap);
	HookEvent("pills_used", Event_ItemUsed);
	HookEvent("defibrillator_used", Event_ItemUsed);
	HookEvent("adrenaline_used", Event_ItemUsed);
	HookEvent("heal_success", Event_ItemUsed);
	HookEvent("revive_success", Event_ItemUsed); //Yes it's not an item. No I don't care.
	HookEvent("melee_kill", Event_MeleeKill);
	HookEvent("tank_killed", Event_TankKilled);
	HookEvent("witch_killed", Event_WitchKilled);
	HookEvent("infected_hurt", Event_InfectedHurt);
	HookEvent("infected_death", Event_InfectedDeath);
	HookEvent("door_open", Event_DoorOpened);
	HookEvent("upgrade_pack_used", Event_UpgradePackUsed);
	HookEvent("triggered_car_alarm", Event_CarAlarm);
	//Used for campaign recording:
	HookEvent("finale_start", Event_FinaleStart);
	HookEvent("gauntlet_finale_start", Event_FinaleStart);
	HookEvent("finale_vehicle_ready", Event_FinaleVehicleReady);
	HookEvent("finale_win", Event_FinaleWin);
	HookEvent("hegrenade_detonate", Event_GrenadeDenonate);
	//Used to transition checkpoint statistics for stats_games
	HookEvent("game_init", Event_GameStart);
	HookEvent("round_end", Event_RoundEnd);

	HookEvent("boomer_exploded", Event_BoomerExploded);
	HookEvent("versus_round_start", Event_VersusRoundStart);
	HookEvent("map_transition", Event_MapTransition);
	HookEvent("player_ledge_grab", Event_LedgeGrab);
	HookEvent("player_first_spawn", Event_PlayerFirstSpawn);
	HookEvent("player_left_safe_area", Event_PlayerLeftStartArea);
	AddNormalSoundHook(SoundHook);
	#if defined DEBUG
	RegConsoleCmd("sm_debug_stats", Command_DebugStats, "Debug stats");
	#endif
	RegAdminCmd("sm_stats", Command_PlayerStats, ADMFLAG_GENERIC);
	RegAdminCmd("sm_heatmaps", Command_Heatmaps, ADMFLAG_GENERIC);
	RegAdminCmd("sm_heatmap", Command_Heatmaps, ADMFLAG_GENERIC);

	AutoExecConfig(true, "l4d2_stats_recorder");

	for(int i = 1; i <= MaxClients; i++) {
		players[i].Init();
	}

	CreateTimer(hHeatmapInterval.FloatValue, Timer_HeatMapInterval, _, TIMER_REPEAT);
}

//When plugin is being unloaded: flush all user's statistics.
public void OnPluginEnd() {
	for(int i=1; i<=MaxClients;i++) {
		if(IsClientInGame(i) && !IsFakeClient(i) && players[i].steamid[0]) {
			FlushQueuedStats(i, false);
		}
	}
	ClearHeatMapEntities();
}
//////////////////////////////////
// TIMER
/////////////////////////////////
Action Timer_HeatMapInterval(Handle h) {
	// Skip recording any points when visualizing or escape vehicle ready
	if(!hHeatmapActive.BoolValue || game.finished || IsHeatMapVisualActive()) return Plugin_Continue;

	float pos[3];
	for(int i=1; i<=MaxClients;i++) {
		if(IsClientInGame(i) && !IsFakeClient(i) && players[i].steamid[0]) {
			MoveType moveType = GetEntityMoveType(i);
			if(moveType != MOVETYPE_WALK && moveType != MOVETYPE_LADDER) continue;
			GetClientAbsOrigin(i, pos);
			players[i].RecordHeatMap(HeatMap_Periodic, pos);
			if(players[i].pendingHeatmaps.Length > 25) {
				SubmitHeatmaps(i);
			}
		}
	}
	return Plugin_Continue;
}
/////////////////////////////////
// CONVAR CHANGES
/////////////////////////////////
public void CVC_GamemodeChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	strcopy(game.gamemode, sizeof(game.gamemode), newValue);
	strcopy(gamemode, sizeof(gamemode), newValue);
}
public void CVC_TagsChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	strcopy(serverTags, sizeof(serverTags), newValue);
}
public void CVC_ClownModeChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	hPopulationClowns = FindConVar("l4d2_population_clowns");
	if(hPopulationClowns == null) {
		PrintToServer("[Stats] ERROR: Missing plugin for clown mode");
		return;
	}
	if(hClownMode.IntValue > 0) {
		hMinShove.IntValue = 20;
		hMaxShove.IntValue = 40;
		hPopulationClowns.FloatValue = 0.4;
		hHonkCounterTimer = CreateTimer(15.0, Timer_HonkCounter, _, TIMER_REPEAT);
	} else {
		hMinShove.IntValue = 5;
		hMaxShove.IntValue = 15;
		hPopulationClowns.FloatValue = 0.0;
		if(hHonkCounterTimer != null) {
			delete hHonkCounterTimer;
		}
	}
}
public Action Timer_HonkCounter(Handle h) { 
	int honks, honker = -1;
	for(int j = 1; j <= MaxClients; j++) {
		if(players[j].clownsHonked > 0 && (players[j].clownsHonked > honks || honker == -1) && !IsFakeClient(j)) {
			honker = j;
			honks = players[j].clownsHonked;
		}
	}
	if(honker > 0) {
		for(int i = 1; i <= MaxClients; i++) {
			if(players[i].clownsHonked > 0 && IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2) {
				PrintHintText(i, "Top Honker: %N (%d honks)\nYou: %d honks", honker, honks, players[i].clownsHonked);
			}
		}
	}
	if(hClownMode.IntValue == 2 && GetURandomFloat() < hClownModeChangeChance.FloatValue) {
		if(GetRandomFloat() > 0.6)
			hPopulationClowns.FloatValue = 0.0;
		else 
			hPopulationClowns.FloatValue = GetRandomFloat();
		PrintToConsoleAll("Honk Mode: New population %.0f%%", hPopulationClowns.FloatValue * 100);
	}
	return Plugin_Continue; 
}
/////////////////////////////////
// PLAYER AUTH
/////////////////////////////////
public void OnClientAuthorized(int client, const char[] auth) {
	if(client > 0 && !IsFakeClient(client)) {
		char steamid[32];
		strcopy(steamid, sizeof(steamid), auth);
		SetupUserInDB(client, steamid);
	}
}
public void OnClientPutInServer(int client) {
	if(!IsFakeClient(client)) {
		SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitch);
	}
}
public void OnClientDisconnect(int client) {
	//Check if any pending stats to send.
	if(!IsFakeClient(client) && IsClientInGame(client)) {
		//Record campaign session, incase they leave early. 
		//Should only fire if disconnects after escape_vehicle_ready and before finale_win (credits screen)
		if(game.finished && game.uuid[0] && players[client].steamid[0]) {
			IncrementSessionStat(client);
			RecordCampaign(client);
			IncrementStat(client, "finales_won", 1);
			players[client].RecordPoint(PType_FinishCampaign, 200);
		}

		FlushQueuedStats(client, true);
		players[client].ResetFull();

		//ResetSessionStats(client); //Can't reset session stats cause transitions!
	}
}

void Event_PlayerFirstSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0) {
		players[client].joinedGameTime = GetTime();
	}
}

void Event_PlayerFullDisconnect(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0) {
		players[client].ResetFull();
	}
}

void Event_PlayerEnterIdle(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("player"));
	if(client > 0) {
		players[client].idleStartTime = GetTime();
	}
}

void Event_PlayerLeaveIdle(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("player"));
	if(client > 0 && players[client].idleStartTime > 0) {
		players[client].idleStartTime = 0;
		players[client].totalIdleTime = GetTime() - players[client].idleStartTime;
	}
}

///////////////////////////////////
//DB METHODS
//////////////////////////////////

bool ConnectDB() {
	char error[255];
	g_db = SQL_Connect("stats", true, error, sizeof(error));
	if (g_db == null) {
		LogError("Database error %s", error);
		delete g_db;
		return false;
	} else {
		PrintToServer("Connected to database stats");
		SQL_LockDatabase(g_db);
		SQL_FastQuery(g_db, "SET NAMES \"UTF8mb4\"");  
		SQL_UnlockDatabase(g_db);
		g_db.SetCharset("utf8mb4");
		return true;
	}
}
//Setups a user, this tries to fetch user by steamid
void SetupUserInDB(int client, const char steamid[32]) {
	if(client > 0 && !IsFakeClient(client)) {
		players[client].ResetFull();

		strcopy(players[client].steamid, 32, steamid);
		players[client].startedPlaying = GetTime();
		char query[128];
		

		// TODO: 	connections, first_join last_join
		Format(query, sizeof(query), "SELECT last_alias,points,connections,created_date,last_join_date FROM stats_users WHERE steamid='%s'", steamid);
		SQL_TQuery(g_db, DBCT_CheckUserExistance, query, GetClientUserId(client));
	}
}
//Increments a statistic by X amount
void IncrementStat(int client, const char[] name, int amount = 1, bool lowPriority = true) {
	if(client > 0 && !IsFakeClient(client) && IsClientConnected(client)) {
		//Only run if client valid client, AND has steamid. Not probably necessarily anymore.
		if (players[client].steamid[0]) {
			if(g_db == INVALID_HANDLE) {
				LogError("Database handle is invalid.");
				return;
			}
			int escaped_name_size = 2*strlen(name)+1;
			char[] escaped_name = new char[escaped_name_size];
			char query[255];
			g_db.Escape(name, escaped_name, escaped_name_size);
			Format(query, sizeof(query), "UPDATE stats_users SET `%s`=`%s`+%d WHERE steamid='%s'", escaped_name, escaped_name, amount, players[client].steamid);
			#if defined DEBUG
			PrintToServer("[Debug] Updating Stat %s (+%d) for %N (%d) [%s]", name, amount, client, client, players[client].steamid);
			#endif 
			SQL_TQuery(g_db, DBCT_Generic, query, _, lowPriority ? DBPrio_Low : DBPrio_Normal);
		}
	}
}

void RecordCampaign(int client) {
	if (client > 0 && IsClientInGame(client)) {
		char query[1023];

		if(players[client].m_checkpointZombieKills == 0) {
			PrintToServer("Warn: Client %N for %s | 0 zombie kills", client, game.uuid);
		}

		char model[64];
		GetClientModel(client, model, sizeof(model));

		// unused now:
		char topWeapon[1];

		int ping = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iPing", _, client);
		if(ping < 0) ping = 0;

		int finaleTimeTotal = (game.finaleStartTime > 0) ? GetTime() - game.finaleStartTime : 0;
		Format(query, sizeof(query), "INSERT INTO stats_games (`steamid`, `map`, `gamemode`,`campaignID`, `finale_time`, `join_time`,`date_start`,`date_end`, `zombieKills`, `survivorDamage`, `MedkitsUsed`, `PillsUsed`, `MolotovsUsed`, `PipebombsUsed`, `BoomerBilesUsed`, `AdrenalinesUsed`, `DefibrillatorsUsed`, `DamageTaken`, `ReviveOtherCount`, `FirstAidShared`, `Incaps`, `Deaths`, `MeleeKills`, `difficulty`, `ping`,`boomer_kills`,`smoker_kills`,`jockey_kills`,`hunter_kills`,`spitter_kills`,`charger_kills`,`server_tags`,`characterType`,`honks`,`top_weapon`, `SurvivorFFCount`, `SurvivorFFTakenCount`, `SurvivorFFDamage`, `SurvivorFFTakenDamage`) VALUES ('%s','%s','%s','%s',%d,%d,%d,UNIX_TIMESTAMP(),%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%s',%d,%d,'%s',%d,%d,%d,%d)",
			players[client].steamid,
			game.name,
			gamemode,
			game.uuid,
			finaleTimeTotal,
			players[client].joinedGameTime,
			game.startTime > 0 ? game.startTime : game.finaleStartTime, //incase iGameStartTime not set: use finaleTimeStart
			//unix_timestamp(),
			players[client].m_checkpointZombieKills,
			players[client].m_checkpointSurvivorDamage,
			players[client].m_checkpointMedkitsUsed,
			players[client].m_checkpointPillsUsed,
			players[client].m_checkpointMolotovsUsed,
			players[client].m_checkpointPipebombsUsed,
			players[client].m_checkpointBoomerBilesUsed,
			players[client].m_checkpointAdrenalinesUsed,
			players[client].m_checkpointDefibrillatorsUsed,
			players[client].m_checkpointDamageTaken,
			players[client].m_checkpointReviveOtherCount,
			players[client].m_checkpointFirstAidShared,
			players[client].m_checkpointIncaps,
			players[client].m_checkpointDeaths,
			players[client].m_checkpointMeleeKills,
			game.difficulty,
			ping, //record user ping
			players[client].sBoomerKills,
			players[client].sSmokerKills,
			players[client].sJockeyKills,
			players[client].sHunterKills,
			players[client].sSpitterKills,
			players[client].sChargerKills,
			serverTags,
			GetSurvivorType(model),
			players[client].clownsHonked,
			topWeapon,
			players[client].damageSurvivorFFCount, //SurvivorFFCount
			players[client].damageFFTakenCount, //SurvivorFFTakenCount
			players[client].damageSurvivorFF, //SurvivorFFDamage
			players[client].damageFFTaken //SurvivorFFTakenDamage
		);
		SQL_LockDatabase(g_db);
		bool result = SQL_FastQuery(g_db, query);
		SQL_UnlockDatabase(g_db);
		if(!result) {
			char error[128];
			SQL_GetError(g_db, error, sizeof(error));
			LogError("[l4d2_stats_recorder] RecordCampaign for %d failed. UUID %s | Query: `%s` | Error: %s", game.uuid, client, query, error);
		}
	}
}
//Flushes all the tracked statistics, and runs UPDATE SQL query on user. Then resets the variables to 0
void FlushQueuedStats(int client, bool disconnect) {
	//Update stats (don't bother checking if 0.)
	int minutes_played = (GetTime() - players[client].startedPlaying) / 60;
	//Incase somehow startedPlaying[client] not set (plugin reloaded?), defualt to 0
	if(minutes_played >= 2147483645) {
		players[client].startedPlaying = GetTime();
		minutes_played = 0;
	}
	//Prevent points from being reset by not recording until user has gotten a point. 
	if(players[client].points > 0) {
		char query[1023];
		Format(query, sizeof(query), "UPDATE stats_users SET survivor_damage_give=survivor_damage_give+%d,survivor_damage_rec=survivor_damage_rec+%d, infected_damage_give=infected_damage_give+%d,infected_damage_rec=infected_damage_rec+%d,survivor_ff=survivor_ff+%d,survivor_ff_rec=survivor_ff_rec+%d,common_kills=common_kills+%d,common_headshots=common_headshots+%d,melee_kills=melee_kills+%d,door_opens=door_opens+%d,damage_to_tank=damage_to_tank+%d, damage_witch=damage_witch+%d,minutes_played=minutes_played+%d, kills_witch=kills_witch+%d, points=%d, packs_used=packs_used+%d, damage_molotov=damage_molotov+%d, kills_molotov=kills_molotov+%d, kills_pipe=kills_pipe+%d, kills_minigun=kills_minigun+%d, clowns_honked=clowns_honked+%d WHERE steamid='%s'",
			//VARIABLE													//COLUMN NAME

			players[client].damageSurvivorGiven, 						//survivor_damage_give
			GetEntProp(client, Prop_Send, "m_checkpointDamageTaken"),   //survivor_damage_rec
			players[client].damageInfectedGiven,  						//infected_damage_give
			players[client].damageInfectedRec,   						//infected_damage_rec
			players[client].damageSurvivorFF,    						//survivor_ff
			players[client].damageFFTaken,								//survivor_ff_rec
			GetEntProp(client, Prop_Send, "m_checkpointZombieKills"), 	//common_kills
			GetEntProp(client, Prop_Send, "m_checkpointHeadshots"),   	//common_headshots
			GetEntProp(client, Prop_Send, "m_checkpointMeleeKills"),  	//melee_kills
			players[client].doorOpens, 									//door_opens
			GetEntProp(client, Prop_Send, "m_checkpointDamageToTank"),  //damage_to_tank
			GetEntProp(client, Prop_Send, "m_checkpointDamageToWitch"), //damage_witch
			minutes_played, 											//minutes_played
			players[client].witchKills, 								//kills_witch
			players[client].points, 									//points
			players[client].upgradePacksDeployed, 						//packs_used
			players[client].molotovDamage, 								//damage_molotov
			players[client].pipeKills, 									//kills_pipe,
			players[client].molotovKills,								//kills_molotov
			players[client].minigunKills,								//kills_minigun
			players[client].clownsHonked,								//clowns_honked
			players[client].steamid[0]
		);
		
		//If disconnected, can't put on another thread for some reason: Push it out fast
		if(disconnect) {
			SQL_LockDatabase(g_db);
			SQL_FastQuery(g_db, query);
			SQL_UnlockDatabase(g_db);
			ResetInternal(client, true);
		}else{
			SQL_TQuery(g_db, DBCT_FlushQueuedStats, query, GetClientUserId(client));
			SubmitPoints(client);
			SubmitWeaponStats(client);
			SubmitHeatmaps(client);
		}
	}
}

void SubmitPoints(int client) {
	if(players[client].pointsQueue.Length > 0) {
		char query[4098];
		Format(query, sizeof(query), "INSERT INTO stats_points (steamid,type,amount,timestamp) VALUES ");
		for(int i = 0; i < players[client].pointsQueue.Length; i++) {
			int type = players[client].pointsQueue.Get(i, 0);
			int amount = players[client].pointsQueue.Get(i, 1);
			int timestamp = players[client].pointsQueue.Get(i, 2);
			Format(query, sizeof(query), "%s('%s',%d,%d,%d)%c",
				query,
				players[client].steamid,
				type,
				amount,
				timestamp,
				i == players[client].pointsQueue.Length - 1 ? ' ' : ',' // No trailing comma on last entry
			);
		}
		SQL_TQuery(g_db, DBCT_Generic, query, _, DBPrio_Low);
		players[client].pointsQueue.Clear();
	}
}

void SubmitWeaponStats(int client) {
	if(players[client].wpn.pendingStats != null && players[client].wpn.pendingStats.Size > 0) {
		// Force save weapon stats, instead of waiting for player to switch weapon
		char query[512], weapon[64];
		
		StringMapSnapshot snapshot = players[client].wpn.pendingStats.Snapshot();
		WeaponStatistics stats;
		for(int i = 0; i < snapshot.Length; i++) {
			snapshot.GetKey(i, weapon, sizeof(weapon));
			if(weapon[0] == '\0') continue;
			players[client].wpn.pendingStats.GetArray(weapon, stats, sizeof(stats));
			if(stats.minutesUsed == 0) continue;
			g_db.Format(query, sizeof(query), 
				"INSERT INTO stats_weapons_usage (steamid,weapon,minutesUsed,totalDamage,kills,headshots) VALUES ('%s','%s',%f,%d,%d,%d) ON DUPLICATE KEY UPDATE minutesUsed=minutesUsed+%f,totalDamage=totalDamage+%d,kills=kills+%d,headshots=headshots+%d",
				players[client].steamid,
				weapon,
				stats.minutesUsed,
				stats.totalDamage,
				stats.kills,
				stats.headshots,
				stats.minutesUsed,
				stats.totalDamage,
				stats.kills,
				stats.headshots
			);
			g_db.Query(DBCT_Generic, query, _, DBPrio_Low);
		}
	}
} 

void SubmitHeatmaps(int client) {
	if(players[client].pendingHeatmaps != null && players[client].pendingHeatmaps.Length > 0) {
		PendingHeatMapData hmd;
		char query[2048];
		Format(query, sizeof(query), "INSERT INTO stats_heatmaps (steamid,map,timestamp,type,x,y,z) VALUES ");
		int length = players[client].pendingHeatmaps.Length;
		char commaChar = ',';
		for(int i = 0; i < length; i++) {
			players[client].pendingHeatmaps.GetArray(i, hmd);
			// Add commas to every entry but trailing
			if(i == length - 1) {
				commaChar = ' ';
			}
			Format(query, sizeof(query), "%s('%s','%s',%d,%d,%d,%d,%d)%c", 
				query,
				players[client].steamid,
				game.name, //map nam
				hmd.timestamp,
				hmd.type,
				hmd.pos[0],
				hmd.pos[1],
				hmd.pos[2],
				commaChar
			);
		}

		SQL_TQuery(g_db, DBCT_Generic, query, _, DBPrio_Low);
		// Resize using the new length - old length, incase new data shows up.
		players[client].pendingHeatmaps.Erase(length-1);
	}
}

//Record a special kill to local variable
void IncrementSpecialKill(int client, int special) {
	switch(special) {
		case 1: players[client].sSmokerKills++;
		case 2: players[client].sBoomerKills++;
		case 3: players[client].sHunterKills++;
		case 4: players[client].sSpitterKills++;
		case 5: players[client].sJockeyKills++;
		case 6: players[client].sChargerKills++;
	}
}
//Called ONLY on game_start
void ResetSessionStats(int client, bool resetAll) {
	players[client].m_checkpointZombieKills =			0;
	players[client].m_checkpointSurvivorDamage = 		0;
	players[client].m_checkpointMedkitsUsed = 			0;
	players[client].m_checkpointPillsUsed = 			0;
	players[client].m_checkpointMolotovsUsed = 			0;
	players[client].m_checkpointPipebombsUsed = 		0;
	players[client].m_checkpointBoomerBilesUsed = 		0;
	players[client].m_checkpointAdrenalinesUsed = 		0;
	players[client].m_checkpointDefibrillatorsUsed = 	0;
	players[client].m_checkpointDamageTaken =			0;
	players[client].m_checkpointReviveOtherCount = 		0;
	players[client].m_checkpointFirstAidShared = 		0;
	players[client].m_checkpointIncaps  = 				0;
	if(resetAll) players[client].m_checkpointDeaths = 	0;
	players[client].m_checkpointMeleeKills = 			0;
	players[client].sBoomerKills  = 0;
	players[client].sSmokerKills  = 0;
	players[client].sJockeyKills  = 0;
	players[client].sHunterKills  = 0;
	players[client].sSpitterKills = 0;
	players[client].sChargerKills = 0;
	players[client].clownsHonked  = 0;

	players[client].damageSurvivorFF 		= 0;
	players[client].damageFFTaken 			= 0;
	players[client].damageSurvivorFFCount   = 0;
	players[client].damageFFTakenCount 		= 0;
}
//Called via FlushQueuedStats which is called on disconnects / map transitions / game_start or round_end
void ResetInternal(int client, bool disconnect) {
	players[client].damageSurvivorGiven 	= 0;
	players[client].doorOpens 				= 0;
	players[client].witchKills 				= 0;
	players[client].upgradePacksDeployed 	= 0;
	players[client].molotovDamage 			= 0;
	players[client].pipeKills 				= 0;
	players[client].molotovKills 			= 0;
	players[client].minigunKills 			= 0;
	if(!disconnect) {
		players[client].startedPlaying = GetTime();
	}
	players[client].wpn.Flush();
}
void IncrementSessionStat(int client) {
	players[client].m_checkpointZombieKills += 			GetEntProp(client, Prop_Send, "m_checkpointZombieKills");
	players[client].m_checkpointSurvivorDamage += 		players[client].damageSurvivorFF;
	players[client].m_checkpointMedkitsUsed += 			GetEntProp(client, Prop_Send, "m_checkpointMedkitsUsed");
	players[client].m_checkpointPillsUsed += 			GetEntProp(client, Prop_Send, "m_checkpointPillsUsed");
	players[client].m_checkpointMolotovsUsed += 		GetEntProp(client, Prop_Send, "m_checkpointMolotovsUsed");
	players[client].m_checkpointPipebombsUsed += 		GetEntProp(client, Prop_Send, "m_checkpointPipebombsUsed");
	players[client].m_checkpointBoomerBilesUsed += 		GetEntProp(client, Prop_Send, "m_checkpointBoomerBilesUsed");
	players[client].m_checkpointAdrenalinesUsed += 		GetEntProp(client, Prop_Send, "m_checkpointAdrenalinesUsed");
	players[client].m_checkpointDefibrillatorsUsed += 	GetEntProp(client, Prop_Send, "m_checkpointDefibrillatorsUsed");
	players[client].m_checkpointDamageTaken +=			GetEntProp(client, Prop_Send, "m_checkpointDamageTaken");
	players[client].m_checkpointReviveOtherCount += 	GetEntProp(client, Prop_Send, "m_checkpointReviveOtherCount");
	players[client].m_checkpointFirstAidShared += 		GetEntProp(client, Prop_Send, "m_checkpointFirstAidShared");
	players[client].m_checkpointIncaps  += 				GetEntProp(client, Prop_Send, "m_checkpointIncaps");
	players[client].m_checkpointDeaths += 				GetEntProp(client, Prop_Send, "m_checkpointDeaths");
	players[client].m_checkpointMeleeKills += 			GetEntProp(client, Prop_Send, "m_checkpointMeleeKills");
	PrintToServer("[l4d2_stats_recorder] Incremented checkpoint stats for %N", client);
}

/////////////////////////////////
//DATABASE CALLBACKS
/////////////////////////////////
//Handles the CreateDBUser() response. Either updates alias and stores points, or creates new SQL user.
public void DBCT_CheckUserExistance(Handle db, DBResultSet results, const char[] error, any data) {
	if(db == INVALID_HANDLE || results == INVALID_HANDLE) {
		LogError("DBCT_CheckUserExistance returned error: %s", error);
		return;
	}
	//initialize variables
	int client = GetClientOfUserId(data); 
	if(client == 0) return;
	int alias_length = 2*MAX_NAME_LENGTH+1;
	char alias[MAX_NAME_LENGTH], ip[40], country_name[45];
	char[] safe_alias = new char[alias_length];

	//Get a SQL-safe player name, and their counttry and IP
	GetClientName(client, alias, sizeof(alias));
	SQL_EscapeString(g_db, alias, safe_alias, alias_length);
	GetClientIP(client, ip, sizeof(ip));
	GeoipCountry(ip, country_name, sizeof(country_name));

	char query[255]; 
	if(results.RowCount == 0) {
		//user does not exist in db, create now
		Format(query, sizeof(query), "INSERT INTO `stats_users` (`steamid`, `last_alias`, `last_join_date`,`created_date`,`country`) VALUES ('%s', '%s', UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), '%s')", players[client].steamid, safe_alias, country_name);
		g_db.Query(DBCT_Generic, query);

		Format(query, sizeof(query), "%N is joining for the first time", client);
		for(int i = 1; i <= MaxClients; i++) {
			if(IsClientInGame(i) && GetUserAdmin(i) != INVALID_ADMIN_ID) {
				PrintToChat(i, query);
			}
		}
		PrintToServer("[l4d2_stats_recorder] Created new database entry for %N (%s)", client, players[client].steamid);
	} else {
		//User does exist, check if alias is outdated and update some columns (last_join_date, country, connections, or last_alias)
		results.FetchRow();

		// last_alias,points,connections,created_date,last_join_date
		players[client].points = results.FetchInt(1);
		players[client].connections = results.FetchInt(2);
		players[client].firstJoinedTime = results.FetchInt(4);
		players[client].lastJoinedTime = results.FetchInt(4);

		if(players[client].points == 0) {
			PrintToServer("[l4d2_stats_recorder] Warning: Existing player %N (%d) has no points", client, client);
		}
		int connections_amount = lateLoaded ? 0 : 1;

		Format(query, sizeof(query), "UPDATE `stats_users` SET `last_alias`='%s', `last_join_date`=UNIX_TIMESTAMP(), `country`='%s', connections=connections+%d WHERE `steamid`='%s'", safe_alias, country_name, connections_amount, players[client].steamid);
		g_db.Query(DBCT_Generic, query);
	}
}
//Generic database response that logs error
public void DBCT_Generic(Handle db, Handle child, const char[] error, any data) {
	if(db == null || child == null) {
		if(data) {
			LogError("DBCT_Generic query `%s` returned error: %s", data, error);
		} else {
			LogError("DBCT_Generic returned error: %s", error);
		}
	}
}
void SubmitMapInfo() {
	char title[128];
	InfoEditor_GetString(0, "DisplayTitle", title, sizeof(title));
	int chapters = L4D_GetMaxChapters();
	char query[128];
	g_db.Format(query, sizeof(query), "INSERT INTO map_info (mapid,name,chapter_count) VALUES ('%s','%s',%d)", game.name, title, chapters);
	g_db.Query(DBCT_Generic, query, _, DBPrio_Low);
}
public void DBCT_GetUUIDForCampaign(Handle db, DBResultSet results, const char[] error, any data) {
	if(results != INVALID_HANDLE) {
		if(results.FetchRow()) {
			results.FetchString(0, game.uuid, sizeof(game.uuid));
			DBResult result;
			bool hasData = results.FetchInt(1, result) && result == DBVal_Data;
			// PrintToServer("mapinfo: %d. result: %d. hasData:%b", results.FetchInt(1), result, hasData);
			if(!hasData) {
				SubmitMapInfo();
			}
			PrintToServer("UUID for campaign: %s | Difficulty: %d", game.uuid, game.difficulty);
		} else {
			LogError("RecordCampaign, failed to get UUID: no data was returned");
		}
	} else {
		LogError("RecordCampaign, failed to get UUID: %s", error);
	}
}
//After a user's stats were flushed, reset any statistics needed to zero.
public void DBCT_FlushQueuedStats(Handle db, Handle child, const char[] error, int userid) {
	if(db == INVALID_HANDLE || child == INVALID_HANDLE) {
		LogError("DBCT_FlushQueuedStats returned error: %s", error);
	}else{
		int client = GetClientOfUserId(userid);
		if(client > 0)
			ResetInternal(client, false);
	}
}
////////////////////////////
// COMMANDS
///////////////////////////

#define DATE_FORMAT "%F at %I:%M %p"
Action Command_PlayerStats(int client, int args) {
	if(args == 0) {
		ReplyToCommand(client, "Syntax: /stats <player name>");
		return Plugin_Handled;
	}
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	char target_name[MAX_TARGET_LENGTH];
	int target_list[1], target_count;
	bool tn_is_ml;
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			1,
			COMMAND_FILTER_NO_BOTS,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	int player = target_list[0];
	if(player > 0) {
		ReplyToCommand(client, "");
		ReplyToCommand(client, "\x04Name: \x05%N", player);
		ReplyToCommand(client, "\x04Points: \x05%d", players[player].points);
		ReplyToCommand(client, "\x04Joins: \x05%d", players[player].connections);
		FormatTime(arg, sizeof(arg), DATE_FORMAT, players[player].firstJoinedTime);
		ReplyToCommand(client, "\x04First Joined: \x05%s", arg);
		FormatTime(arg, sizeof(arg), DATE_FORMAT, players[player].lastJoinedTime);
		ReplyToCommand(client, "\x04Last Joined: \x05%s", arg);
		if(players[player].idleStartTime > 0) {
			FormatTime(arg, sizeof(arg), DATE_FORMAT, players[player].idleStartTime);
			ReplyToCommand(client, "\x04Idle Start Time: \x05%s", arg);
		}
		ReplyToCommand(client, "\x04Minutes Idle: \x05%d", players[player].totalIdleTime);
	}

	return Plugin_Handled;
}

#if defined DEBUG
public Action Command_DebugStats(int client, int args) {
	if(client == 0 && !IsDedicatedServer()) {
		ReplyToCommand(client, "This command must be used as a player.");
	}else {
		ReplyToCommand(client, "Statistics for %s", players[client].steamid);
		ReplyToCommand(client, "lastDamage = %f", players[client].lastWeaponDamage);
		ReplyToCommand(client, "points = %d", players[client].points);
		for(int i = 1; i <= MaxClients; i++) {
			if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2) {
				ReplyToCommand(client, "p#%i | pending heatmaps: %d | ", i, players[i].pendingHeatmaps.Length, players[i].pointsQueue.Length);
			}
		}
		ReplyToCommand(client, "connections = %d", players[client].connections);
		// ReplyToCommand(client, "Total weapons cache %d", game.weaponUsages.Size);
	}
	return Plugin_Handled;
}
#endif

////////////////////////////
// EVENTS 
////////////////////////////
void Event_PlayerLeftStartArea(Event event, const char[] name, bool dontBroadcast) {
	if(GetSurvivorCount() > 4) return;
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		// Check if they do not have a kit
		if(GetPlayerWeaponSlot(client, 3) == -1) {
			// Check if there are any kits remaining in the safe area (that they did not pickup)
			int entity = -1;
			float pos[3];
			while((entity = FindEntityByClassname(entity, "weapon_first_aid_kit_spawn")) != INVALID_ENT_REFERENCE) {
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
				if(L4D_IsPositionInLastCheckpoint(pos)) {
					PrintToConsoleAll("[Stats] Player %N forgot to pickup a kit", client);
					IncrementStat(client, "forgot_kit_count");
					break;
				}
			}
		}
	}
}
void OnWeaponSwitch(int client, int weapon) {
	// Update weapon when switching to a new one
	if(weapon > -1) {
		
		// TODO: if melee
		players[client].wpn.SetActiveWeapon(weapon);
	}
}
public void Event_BoomerExploded(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(attacker && !IsFakeClient(attacker) && GetClientTeam(attacker) == 2) {
		g_iLastBoomTime = GetGameTime();
		g_iLastBoomUser = attacker;
	}
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion) {
	if(boomerExplosion && GetGameTime() - g_iLastBoomTime < 23.0) {
		if(victim == g_iLastBoomUser)
			IncrementStat(g_iLastBoomUser, "boomer_mellos_self");
		else
			IncrementStat(g_iLastBoomUser, "boomer_mellos");
	}
	return Plugin_Continue;
}

Action SoundHook(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) {
	if(numClients > 0 && StrContains(sample, "clown") > -1) {
		// The sound of the honk comes from the honker directly, so we loop all the receiving clients
		// Then the one with the exact coordinates of the sound, is the honker 
		float zPos[3], survivorPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
		for(int i = 0; i < numClients; i++) {
			int client = clients[i];
			GetClientAbsOrigin(client, survivorPos);
			if(survivorPos[0] == zPos[0] && survivorPos[1] == zPos[1] && survivorPos[2] == zPos[2]) {
				game.clownHonks++;
				players[client].clownsHonked++;
				return Plugin_Continue;
			}
		}
	}
	return Plugin_Continue;
}
//Records the amount of HP done to infected (zombies)
public void Event_InfectedHurt(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(attacker > 0 && !IsFakeClient(attacker)) {
		int dmg = event.GetInt("amount");
		players[attacker].damageSurvivorGiven += dmg;
		players[attacker].wpn.damage += dmg;
	}
}
public void Event_InfectedDeath(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(attacker > 0 && !IsFakeClient(attacker)) {
		bool blast = event.GetBool("blast");
		bool headshot = event.GetBool("headshot");
		bool using_minigun = event.GetBool("minigun");

		if(headshot) {
			players[attacker].RecordPoint(PType_Headshot, 2);
			players[attacker].wpn.headshots++;
		}

		players[attacker].RecordPoint(PType_CommonKill, 1);
		players[attacker].wpn.kills++;


		if(using_minigun) {
			players[attacker].minigunKills++;
		} else if(blast) {
			players[attacker].pipeKills++;
		}
	}
}
public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) {
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim_team = GetClientTeam(victim);
	int dmg = event.GetInt("dmg_health");
	if(dmg <= 0) return;
	if(attacker > 0 && !IsFakeClient(attacker)) {
		int attacker_team = GetClientTeam(attacker);
		players[attacker].wpn.damage += dmg;


		if(attacker_team == 2) {
			players[attacker].damageSurvivorGiven += dmg;
			char wpn_name[16];
			event.GetString("weapon", wpn_name, sizeof(wpn_name));

			if(victim_team == 3 && StrEqual(wpn_name, "inferno", true)) {
				players[attacker].molotovDamage += dmg;
			}
		} else if(attacker_team == 3) {
			players[attacker].damageInfectedGiven += dmg;
		}
		if(attacker_team == 2 && victim_team == 2) {
			players[attacker].RecordPoint(PType_FriendlyFire, -40);
			players[attacker].damageSurvivorFF += dmg;
			players[attacker].damageSurvivorFFCount++;
			players[victim].damageFFTaken += dmg;
			players[victim].damageFFTakenCount++;
		}
	}
}
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if(victim > 0) {
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		int victim_team = GetClientTeam(victim);

		if(!IsFakeClient(victim)) {
			if(victim_team == 2) {
				IncrementStat(victim, "survivor_deaths", 1);
				float pos[3];
				GetClientAbsOrigin(victim, pos);
				players[victim].RecordHeatMap(HeatMap_Death, pos);
			}
		}

		if(attacker > 0 && !IsFakeClient(attacker) && GetClientTeam(attacker) == 2) {
			if(victim_team == 3) {
				int victim_class = GetEntProp(victim, Prop_Send, "m_zombieClass");
				char class[8], statname[16];
				players[attacker].wpn.kills++;


				if(GetInfectedClassName(victim_class, class, sizeof(class))) {
					IncrementSpecialKill(attacker, victim_class);
					Format(statname, sizeof(statname), "kills_%s", class);
					IncrementStat(attacker, statname, 1);
					players[attacker].RecordPoint(PType_SpecialKill, 6);
				}
				char wpn_name[16];
				event.GetString("weapon", wpn_name, sizeof(wpn_name));
				if(StrEqual(wpn_name, "inferno", true) || StrEqual(wpn_name, "entityflame", true)) {
					players[attacker].molotovKills++;
				}
				IncrementStat(victim, "infected_deaths", 1);
			} else if(victim_team == 2) {
				IncrementStat(attacker, "ff_kills", 1);
				//30 point lost for killing teammate
				players[attacker].RecordPoint(PType_FriendlyFire, -500);
			}
		}
	}
	
}
public void Event_MeleeKill(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		players[client].RecordPoint(PType_CommonKill, 1);
	}
}
public void Event_TankKilled(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int solo = event.GetBool("solo") ? 1 : 0;
	int melee_only = event.GetBool("melee_only") ? 1 : 0;

	if(attacker > 0 && !IsFakeClient(attacker)) {
		if(solo) {
			IncrementStat(attacker, "tanks_killed_solo", 1);
			players[attacker].RecordPoint(PType_TankKill_Solo, 20);
		}
		if(melee_only) {
			players[attacker].RecordPoint(PType_TankKill_Melee, 50);
			IncrementStat(attacker, "tanks_killed_melee", 1);
		}
		players[attacker].RecordPoint(PType_TankKill, 100);
		IncrementStat(attacker, "tanks_killed", 1);
	}
}
public void Event_DoorOpened(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && event.GetBool("closed") && !IsFakeClient(client)) {
		players[client].doorOpens++;

	}
}
void Event_PlayerIncap(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsFakeClient(client) && GetClientTeam(client) == 2) {
		IncrementStat(client, "survivor_incaps", 1);
		float pos[3];
		GetClientAbsOrigin(client, pos);
		players[client].RecordHeatMap(HeatMap_Incap, pos);
	}
}
void Event_LedgeGrab(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsFakeClient(client) && GetClientTeam(client) == 2) {
		float pos[3];
		GetClientAbsOrigin(client, pos);
		players[client].RecordHeatMap(HeatMap_LedgeGrab, pos);
		IncrementStat(client, "survivor_incaps", 1);
	}
}
//Track heals, or defibs
void Event_ItemUsed(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		if(StrEqual(name, "heal_success", true)) {
			int subject = GetClientOfUserId(event.GetInt("subject"));
			if(subject == client) {
				IncrementStat(client, "heal_self", 1);
			}else{
				players[client].RecordPoint(PType_HealOther, 10);
				IncrementStat(client, "heal_others", 1);
			}
		} else if(StrEqual(name, "revive_success", true)) {
			int subject = GetClientOfUserId(event.GetInt("subject"));
			if(subject != client) {
				IncrementStat(client, "revived_others", 1);
				players[client].RecordPoint(PType_ReviveOther, 5);
				IncrementStat(subject, "revived", 1);
			}
		} else if(StrEqual(name, "defibrillator_used", true)) {
			players[client].RecordPoint(PType_ResurrectOther, 7);
			IncrementStat(client, "defibs_used", 1);
		} else{
			IncrementStat(client, name, 1);
		}
	}
}

public void Event_UpgradePackUsed(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		players[client].upgradePacksDeployed++;
		players[client].RecordPoint(PType_DeployAmmo, 2);
	}
}
public void Event_CarAlarm(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		IncrementStat(client, "caralarms_activated", 1);
	}
}
public void Event_WitchKilled(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		players[client].witchKills++;
		players[client].RecordPoint(PType_WitchKill, 50);
	}
}


public void Event_GrenadeDenonate(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && !IsFakeClient(client)) {
		char wpn_name[32];
		GetClientWeapon(client, wpn_name, sizeof(wpn_name));
	}
}
///THROWABLE TRACKING
//This is used to track throwable throws 
public void OnEntityCreated(int entity, const char[] classname) {
	if(IsValidEntity(entity) && StrContains(classname, "_projectile", true) > -1 && HasEntProp(entity, Prop_Send, "m_hOwnerEntity")) {
		RequestFrame(EntityCreateCallback, entity);
	}
}
void EntityCreateCallback(int entity) {
	if(!HasEntProp(entity, Prop_Send, "m_hOwnerEntity") || !IsValidEntity(entity)) return;
	char class[16];

	GetEntityClassname(entity, class, sizeof(class));
	int entOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(entOwner > 0 && entOwner <= MaxClients) {
		if(StrContains(class, "vomitjar", true) > -1) {
			IncrementStat(entOwner, "throws_puke", 1);
		} else if(StrContains(class, "molotov", true) > -1) {
			IncrementStat(entOwner, "throws_molotov", 1);
		} else if(StrContains(class, "pipe_bomb", true) > -1) {
			IncrementStat(entOwner, "throws_pipe", 1);
		}
	}
}
bool isTransition = false;
////MAP EVENTS
public void Event_GameStart(Event event, const char[] name, bool dontBroadcast) {
	game.startTime = GetTime();
	game.clownHonks = 0;
	game.submitted = false;

	PrintToServer("[l4d2_stats_recorder] Started recording statistics for new session");
	for(int i = 1; i <= MaxClients; i++) {
		ResetSessionStats(i, true);
		ResetInternal(i, true);
	}
}
public void OnMapStart() {
	if(isTransition) {
		isTransition = false;
	}else{
		game.difficulty = GetDifficultyInt();
	}
	game.GetMap();
}
public void OnMapEnd() {
	if(g_HeatMapEntities != null) delete g_HeatMapEntities;
}
public void Event_VersusRoundStart(Event event, const char[] name, bool dontBroadcast) {
	if(game.IsVersusMode()) {
		game.isVersusSwitched = !game.isVersusSwitched; 
	}
}
public void Event_MapTransition(Event event, const char[] name, bool dontBroadcast) {
	isTransition = true;
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && !IsFakeClient(i)) {
			IncrementSessionStat(i);
			FlushQueuedStats(i, false);
		}
	}
}
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
	PrintToServer("[l4d2_stats_recorder] round_end; flushing");
	game.finished = false;
	
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) {
			//ResetSessionStats(i, false);
			FlushQueuedStats(i, false);
		}
	}
}
/*Order of events:
finale_start: Gets UUID
escape_vehicle_ready: IF fired, sets var campaignFinished to true.
finale_win: Record all players, campaignFinished = false

if player disconnects && campaignFinished: record their session. Won't be recorded in finale_win
*/
//Fetch UUID from finale start, should be ready for events finale_win OR escape_vehicle_ready
public void Event_FinaleStart(Event event, const char[] name, bool dontBroadcast) {
	game.finaleStartTime = GetTime();
	game.difficulty = GetDifficultyInt();
	//Use the same UUID for versus
	//FIXME: This was causing UUID to not fire another new one for back-to-back-coop
	//if(game.IsVersusMode && game.isVersusSwitched) return;
	char query[128];
	g_db.Format(query, sizeof(query), "SELECT UUID() AS UUID, (SELECT !ISNULL(mapid) from map_info where mapid = '%s') as mapid", game.name);
	g_db.Query(DBCT_GetUUIDForCampaign, query, _);
}
public void Event_FinaleVehicleReady(Event event, const char[] name, bool dontBroadcast) {
	//Get UUID on finale_start
	if(L4D_IsMissionFinalMap()) {
		game.difficulty = GetDifficultyInt();
		game.finished = true;
	}
}

public void Event_FinaleWin(Event event, const char[] name, bool dontBroadcast) {
	if(!L4D_IsMissionFinalMap() || game.submitted) return;
	game.difficulty = event.GetInt("difficulty");
	game.finished = false;
	char shortID[9];
	StrCat(shortID, sizeof(shortID), game.uuid);

	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && GetClientTeam(i) == 2) {
			int client = i;
			if(IsFakeClient(i)) {
				if(!HasEntProp(i, Prop_Send, "m_humanSpectatorUserID")) continue;
				client = GetClientOfUserId(GetEntPropEnt(i, Prop_Send, "m_humanSpectatorUserID"));
				//get real client
			}
			if(players[client].steamid[0]) {
				players[client].RecordPoint(PType_FinishCampaign, 200);
				IncrementSessionStat(client);
				RecordCampaign(client);
				IncrementStat(client, "finales_won", 1);
				PrintToChat(client, "View this game's statistics at https://jackz.me/c/%s", shortID);
				if(game.clownHonks > 0) {
					PrintToChat(client, "%d clowns were honked this session, you honked %d", game.clownHonks, players[client].clownsHonked);
				}
			}

		}
	}	
	if(game.clownHonks > 0) {
		ArrayList winners = new ArrayList();
		int mostHonks;
		for(int j = 1; j <= MaxClients; j++) {
			if(players[j].clownsHonked <= 0 || !IsClientInGame(j) || IsFakeClient(j)) continue;
			if(players[j].clownsHonked > mostHonks || winners.Length == 0) {
				mostHonks = players[j].clownsHonked;
				// Clear the winners list
				winners.Clear();
				winners.Push(j);
			} else if(players[j].clownsHonked == mostHonks) {
				// They are tied with the current winner, add them to list
				winners.Push(j);
			}
		}

		if(mostHonks > 0) {
			if(winners.Length > 1) {
				char msg[256];
				Format(msg, sizeof(msg), "%N", winners.Get(0));
				for(int i = 1; i < winners.Length; i++) {
					int winner = winners.Get(i);
					if(!IsClientConnected(winner)) continue;
					if(i == winners.Length - 1) {
						// If this is the last winner, use 'and '
						Format(msg, sizeof(msg), "%s and %N", msg, winner);
					} else {
						// In between first and last winner, comma
						Format(msg, sizeof(msg), "%s, %N", msg, winner);
					}
				}
				PrintToChatAll("%s tied for the most clown honks with a count of %d", msg, mostHonks);
			} else {
				int winner = winners.Get(0);
				if(IsClientConnected(winner)) {
					PrintToChatAll("%N had the most clown honks with a count of %d", winner, mostHonks);
				}
			}
		} 
		delete winners;
	}
	for(int i = 1; i <= MaxClients; i++) {
		players[i].clownsHonked = 0;
	}
	game.submitted = true;
	game.clownHonks = 0;
}


////////////////////////////
// FORWARD EVENTS
///////////////////////////
public void OnWitchCrown(int survivor, int damage) {
	IncrementStat(survivor, "witches_crowned", 1);
}
public void OnSmokerSelfClear( int survivor, int smoker, bool withShove ) {
	IncrementStat(survivor, "smokers_selfcleared", 1);
}
public void OnTankRockEaten( int tank, int survivor ) {
	IncrementStat(survivor, "rocks_hitby", 1);
}
public void OnHunterDeadstop(int survivor, int hunter) {
	IncrementStat(survivor, "hunters_deadstopped", 1);
}
public void OnSpecialClear( int clearer, int pinner, int pinvictim, int zombieClass, float timeA, float timeB, bool withShove ) {
	IncrementStat(clearer, "cleared_pinned", 1);
	IncrementStat(pinvictim, "times_pinned", 1);
}
////////////////////////////
// NATIVES
///////////////////////////
public any Native_GetPoints(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	return players[client].points;
}

////////////////////////////
// STOCKS
///////////////////////////
//Simply prints the respected infected's class name based on their numeric id. (not client/user ID)
stock bool GetInfectedClassName(int type, char[] buffer, int bufferSize) {
	switch(type) {
		case 1: strcopy(buffer, bufferSize, "smoker");
		case 2: strcopy(buffer, bufferSize, "boomer");
		case 3: strcopy(buffer, bufferSize, "hunter");
		case 4: strcopy(buffer, bufferSize, "spitter");
		case 5: strcopy(buffer, bufferSize, "jockey");
		case 6: strcopy(buffer, bufferSize, "charger");
		default: return false;
	}
	return true;
}

stock int GetDifficultyInt() {
	char diff[16];
	hZDifficulty.GetString(diff, sizeof(diff));
	if(StrEqual(diff, "easy", false)) return 0;
	else if(StrEqual(diff, "hard", false)) return 2;
	else if(StrEqual(diff, "impossible", false)) return 3;
	else return 1;
}

stock int GetSurvivorCount() {
	int count;
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && GetClientTeam(i) == 2) {
			count++;
		}
	}
	return count;
}