#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// #define _DEBUG

#if defined _DEBUG
	#define LOG(%0) LogMessage(%0)
#else
	stock void LogMessageEx() {}
	#define LOG(%0) LogMessageEx()
#endif

#define _MIN(%0,%1) (((%0) > (%1)) ? (%1) : (%0))
#define _MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

#define RGB_TO_VALUE(%0,%1,%2) ((%0) + ((%1) * 256) + ((%2) * 65536))

#define CONFIG "data/l4d2_airdrop_info.cfg"

#define MAX_AIRPLANES_INFO 8
#define MAX_AIRDROPS_INFO 8
#define MAX_FLARES_INFO 8

#define MAX_AIRPLANES 12
#define MAX_AIRDROPS 12
#define MAX_FLARES 24

#define PARTICLE_FLARE		"flare_burning"
#define PARTICLE_FUSE		"weapon_pipebomb_fuse"

#define MODEL_FLARE 		"models/props_lighting/light_flares.mdl"

#define AC130_MODEL 		"models/props_vehicles/c130.mdl"
#define AC130_SOUND 		"animation/c130_flyby.wav"

#define AC130_KILL_TIME 15.0
#define NAVIGATION_EXTENT_THRESHOLD 300.0
#define GROUND_THRESHOLD 80.0

public Plugin myinfo =
{
	name = "[L4D2] Airdrop",
	author = "BHaType",
	version = "0.6"
}

enum SECTION_TYPE
{
	SECTION_NONE = (1 << 0),
	SECTION_GLOBAL_SETTINGS = (1 << 1),
	SECTION_GLOBAL_WEAPONS = (1 << 2),
	SECTION_AIRPLANE_INFO = (1 << 3),
	SECTION_AIRDROP_INFO = (1 << 4),
	SECTION_PRIVATE_WEAPONS_INFO = (1 << 5),
	SECTION_PRIVATE_FLARES_INFO = (1 << 6),
	SECTION_PRIVATE_GLOW_INFO = (1 << 7)
}

enum EDropType
{
	BREAKABLE = 1,
	PRESS,
	TOUCH,
	MAX_DROP_TYPES
};

enum EFlareType
{
	STATIC_FLARE,
	DYNAMIC_FLARE
};

enum EFlareSpawnType
{
	RELATIVE,
	RANDOM,
	NAVIGATION
};

enum struct WeaponInfo
{
	StringMap map;
	ArrayList list;
	
	int count;
	int weight;
	
	bool init;
	
	void Init()
	{
		if ( this.init )
			return;
			
		this.init = true;
		this.map = new StringMap();
		this.list = new ArrayList();
	}
	
	void Add( const char[] weapon, const char[] weight )
	{
		int iWeight = StringToInt(weight);
		
		char temp[4];
		IntToString(this.count, temp, sizeof temp);
		
		this.map.SetValue(weapon, iWeight);
		this.map.SetString(temp, weapon);
		
		this.list.Push(iWeight);
		
		this.count++;
		this.weight += iWeight;
	}
	
	void Clear()
	{
		this.weight = 0;
		
		this.map.Clear();
		this.list.Clear();
	}
}

enum struct FlareInfo
{
	int color[3];
	int count;
	int count_per_crate;
	int light_distance;
	int length;
	int alpha;
	
	float relative_origin[3];
	float alivetime;
	float radius;
	float gravity;
	float density;
	float spawn_interval;
	float last_spawn;
	
	EFlareType flare_type;
	EFlareSpawnType spawn_type;
}

enum struct GlowInfo
{
	int type;
	int range;
	int color;
}

enum struct AirdropInfo
{
	int health;
	int weapons_count;
	
	float relative_origin[3];
	float mins[3];
	float maxs[3];
	float alivetime;
	float parachute_speed;

	char model[PLATFORM_MAX_PATH];
	char parachute[PLATFORM_MAX_PATH];
	char name[64];
	char use_time[12];
	
	GlowInfo glow_info;
	FlareInfo flare_info;
	WeaponInfo weapons_info;
	EDropType type;
}

enum struct AirplaneInfo
{
	int airdrop_count;
	
	float droptime;
	float airdropdelay;
	float density;
	
	char name[64];
	char specification[64];
}

enum struct FlareManager
{
	int count;
	int flares[MAX_FLARES];
	
	int Add( int flare )
	{
		if ( this.count == MAX_FLARES )
		{
			LogError("You exceed flares limit reduce their count or expand limit...");
			return -1;
		}
		
		this.flares[this.count++] = EntIndexToEntRef(flare);
		return this.count - 1;
	}
	
	bool Kill( int i )
	{
		if ( i < 0 || i >= MAX_FLARES )
			return false;
		
		ArrayStack stack = new ArrayStack();
		int entity = EntRefToEntIndex(this.flares[i]);
			
		if ( entity <= MaxClients || !IsValidEntity(entity) )
			return false;

		do
		{
			stack.Push(entity);
		}
		while ( (entity = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")) != -1 && entity > MaxClients );
		
		while( !stack.Empty )
		{
			entity = stack.Pop();
			RemoveEntityTimed(entity);
		}
		
		delete stack;
		return true;
	}
	
	void KillAll()
	{
		for (int i; i < this.count; i++)
		{
			this.Kill(i);
		}
	}
}

enum struct AirdropsManager
{
	int index;
	int crates[MAX_AIRDROPS];
	int parachute[MAX_AIRDROPS];
	
	float lastdrop;
	
	int Add( int crate )
	{
		if ( this.index == MAX_AIRDROPS )
		{
			LogError("You exceed airdrops limit reduce their count or expand limit...");
			return -1;
		}
		
		LOG("Added crate: %i index: %i", crate, this.index);
		
		this.crates[this.index++] = EntIndexToEntRef(crate);
		return this.index - 1;
	}
	
	bool Kill(int i)
	{
		int entity;
		
		if ( (entity = EntRefToEntIndex(this.crates[i])) == INVALID_ENT_REFERENCE || !IsValidEntity(entity) )
			return false;
		
		int button = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		
		if ( button != -1 )
		{
			int client = GetEntPropEnt(button, Prop_Data, "m_hActivator");
			
			if ( client != -1 )
			{
				SetEntProp(client, Prop_Send, "m_iCurrentUseAction", 0);
				SetEntProp(client, Prop_Send, "m_useActionTarget", -1);
			
				SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", 0.0);
				SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", 0.0);
			}
		}
		
		RemoveEntityTimed(entity);
		this.parachute[i] = -1;
		return true;
	}
	
	void KillAll()
	{
		for (int i; i < this.index; i++)
		{
			this.Kill(i);
		}
		
		this.index = 0;
	}
}

enum struct Airplane
{
	int entity;
	int dropped_count;
	int flares_count;
	
	AirdropsManager airdrops_manager;
	FlareManager flare_manager;
	AirplaneInfo airplane_info;
	AirdropInfo airdrop_info;
}

enum struct GlobalSettings
{
	float maxheight;
	float airdrop_timer;
	
	int airdrop_timer_max_count;
	
	char usestring[64];
	
	bool chat_activity;
	bool skyboxonly;
}

GlobalSettings g_Globals;
WeaponInfo g_DefaultWeaponsInfo;

AirplaneInfo g_NextAirplaneInfo;
AirdropInfo g_NextAirdropInfo;

AirplaneInfo g_AirplaneInfo[MAX_AIRPLANES_INFO];
AirdropInfo g_AirdropInfo[MAX_AIRDROPS_INFO];
Airplane g_Airplanes[MAX_AIRPLANES];

int g_iAirplaneInfoCount;
int g_iAirdropInfoCount;
int g_iAirplanesCount;
int g_iAirdropsTimerCount;

int g_iSectionLevel;
SECTION_TYPE g_iSectionType;
SECTION_TYPE g_iLastSectionType;
ArrayStack g_hSectionsStack;

bool g_bLateLoad;
bool g_bL4DHooks;

char g_szPath[PLATFORM_MAX_PATH];
Handle g_hAirdropTimer;

methodmap Random < ArrayList
{
	public Random GetRandom(WeaponInfo info)
	{
		return view_as<Random>(info.list);
	}

	public int GetWeapon( int weights )
	{
		int random = RoundToFloor(GetRandomFloat() * float(weights));
		
		for (int i; i < this.Length; i++)
		{
			random -= this.Get(i);
			
			if ( random < 0 )
				return i;
		}
		
		return GetRandomInt(0, this.Length - 1);
	}
}

native bool L4D_HasAnySurvivorLeftSafeArea();
native int L4D_GetNearestNavArea(const float vecPos[3]);
native void L4D_FindRandomSpot(int NavArea, float vecPos[3]);

public any NAT_CreateAirdrop( Handle plugin, int numParams )
{
	float vOrigin[3], vAngles[3];
	
	GetNativeArray(1, vOrigin, sizeof vOrigin);
	GetNativeArray(2, vAngles, sizeof vAngles);
	
	if ( GetNativeCell(4) && !GetSkyOrigin(vOrigin, vOrigin, g_Globals.skyboxonly) )
	{
		return false;
	}
	
	return CallAirdropRandom(vOrigin, vAngles, GetNativeCell(3));
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("L4D_HasAnySurvivorLeftSafeArea");
	MarkNativeAsOptional("L4D_GetNearestNavArea");
	MarkNativeAsOptional("L4D_FindRandomSpot");
	
	CreateNative("CreateAirdrop", NAT_CreateAirdrop);
	g_bLateLoad = late;
	
	return APLRes_Success;
}

public void OnLibraryAdded( const char[] name )
{
	if ( strcmp(name, "left4dhooks") == 0 )
		g_bL4DHooks = true;
}

public void OnLibraryRemoved( const char[] name )
{
	if ( strcmp(name, "left4dhooks") == 0 )
		g_bL4DHooks = false;
}

public void OnPluginStart()
{
	g_bL4DHooks = LibraryExists("left4dhooks");
	// g_hSectionsStack = new ArrayStack();
	
	BuildPath(Path_SM, g_szPath, sizeof g_szPath, "%s", CONFIG);
	
	if ( !ParseConfig(g_szPath) )
	{
		LogError("Failed to parse config... Aborting");
		return;
	}
	
	RegAdminCmd("sm_ac130", sm_airdrop, ADMFLAG_ROOT);
	RegAdminCmd("sm_airdrop", sm_airdrop, ADMFLAG_ROOT);
	RegAdminCmd("sm_airdrop_specific", sm_airdrop_specific, ADMFLAG_ROOT);
	RegAdminCmd("sm_airdrop_reload_config", sm_airdrop_reload_config, ADMFLAG_ROOT);
	RegAdminCmd("sm_airdrop_info_dump", sm_airdrop_info_dump, ADMFLAG_ROOT);
	RegAdminCmd("sm_airdrop_weapons_rolling_test", sm_airdrop_weapons_rolling_test, ADMFLAG_ROOT);
}

public void OnPluginEnd()
{
	Shutdown();
}

public void OnAllPluginsLoaded()
{
	if ( g_bLateLoad )
	{
		if ( L4D_HasAnySurvivorLeftSafeArea() )
		{
			L4D_OnFirstSurvivorLeftSafeArea(0);
		}
	}
}

public void OnMapStart()
{
	PrecacheModel(AC130_MODEL, true);
	PrecacheModel(MODEL_FLARE, true);
	PrecacheSound(AC130_SOUND, true);
	
	PrecacheAirdrops();
	
	PrecacheParticle(PARTICLE_FLARE);
	PrecacheParticle(PARTICLE_FUSE);
}

public void OnMapEnd()
{
	DeleteEntities();
	g_hAirdropTimer = null;
}

public Action L4D_OnFirstSurvivorLeftSafeArea( int client )
{
	LOG("%N left safe area. Start airdrop timer routine.", client);
	
	if ( g_Globals.airdrop_timer <= 0.0 )
	{	
		LOG("Blocking  airdrop timer because timer is negative (%.2f)", g_Globals.airdrop_timer);
		return Plugin_Continue;
	}
	
	if ( g_hAirdropTimer != null )
		delete g_hAirdropTimer;
	
	LOG("Airdrop will be called in %.2f seconds", g_Globals.airdrop_timer);
	g_iAirdropsTimerCount = 0;
	g_hAirdropTimer = CreateTimer(g_Globals.airdrop_timer, timer_airdrop, .flags = TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action timer_airdrop( Handle timer )
{	
	LOG("Calling airdrop... Timer is called! (%i/%i)", g_iAirdropsTimerCount, g_Globals.airdrop_timer_max_count);
	
	int client = GetRandomPlayer();
	
	if ( client == -1 )
	{
		LOG("Failed to find possible airdrop initiator, aborting...");
		return Plugin_Continue;
	}
	
	float vOrigin[3], vAngles[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	if ( GetSkyOrigin(vOrigin, vOrigin, g_Globals.skyboxonly) && CallAirdropRandom(vOrigin, vAngles) && g_iAirdropsTimerCount++ >= g_Globals.airdrop_timer_max_count )
	{
		LOG("Reached limit of timed airdrops... Stop timer");
		g_hAirdropTimer = null;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action sm_airdrop_weapons_rolling_test( int client, int args )
{
	char szBuffer[64], temp[4];
	GetCmdArg(1, szBuffer, sizeof szBuffer);
	
	int airdropID = FindAirdropInfoByName(szBuffer);
	
	if ( airdropID == -1 )
	{
		ReplyToCommand(client, "Invalid airdrop configuration name (%s)", szBuffer);
		return Plugin_Handled;
	}
	
	AirdropInfo airdropinfo;
	airdropinfo = g_AirdropInfo[airdropID];
	
	int rolls = 500;
	
	if ( args >= 2 )
	{
		GetCmdArg(2, temp, sizeof temp);
		rolls = StringToInt(temp);
	}
	
	Random random;
	WeaponInfo info;
	
	if ( airdropinfo.weapons_info.list == null )
	{
		ReplyToCommand(client, "[Warning] Selected configuration doesn't have \"weapons\" section... Default section will be used");
		random = random.GetRandom(g_DefaultWeaponsInfo);
		info = g_DefaultWeaponsInfo;
	}
	else
	{
		random = random.GetRandom(airdropinfo.weapons_info);
		info = airdropinfo.weapons_info;
	}
	
	int []results = new int[info.count];
	
	for( int i; i < rolls; i++ )
	{	
		int index = random.GetWeapon(info.weight);
		results[index]++;
	}
	
	ReplyToCommand(client, "************************");
	ReplyToCommand(client, "Rolls Results");
	
	for( int i; i < info.count; i++ )
	{
		IntToString(i, temp, sizeof temp);
		info.map.GetString(temp, szBuffer, sizeof szBuffer);
			
		ReplyToCommand(client, "Name: %s, Rolls: %i", szBuffer, results[i]);
	}
	
	ReplyToCommand(client, "************************");
	return Plugin_Handled;
}

public Action sm_airdrop_specific( int client, int args )
{
	char airplane_conf_name[64], airdrop_conf_name[64];
	
	GetCmdArg(1, airplane_conf_name, sizeof airplane_conf_name);
	GetCmdArg(2, airdrop_conf_name, sizeof airdrop_conf_name);
	
	int airplaneID = FindAirplaneInfoByName(airplane_conf_name);
	int airdropID = FindAirdropInfoByName(airdrop_conf_name);

	if ( airplaneID == -1 || airdropID == -1 )
	{
		ReplyToCommand(client, "You must specify valid airplane and airdrop configurations");
		return Plugin_Handled;
	}
	
	g_NextAirplaneInfo = g_AirplaneInfo[airplaneID];
	g_NextAirdropInfo = g_AirdropInfo[airdropID];
	
	if ( !CallAirdropInitiator(client, false, true) )
	{
		ReplyToCommand(client, "Failed to call airdrop");
	}
		
	return Plugin_Handled;
}

public Action sm_airdrop_reload_config( int client, int args )
{	
	if ( !ParseConfig(g_szPath) )
	{
		ReplyToCommand(client, "Failed to parse config...");
	}
	
	return Plugin_Handled;
}

public Action sm_airdrop_info_dump( int client, int args )
{
	ReplyToCommand(client, "************************");
	ReplyToCommand(client, "Airdrops Infos");
	
	for (int i; i < g_iAirdropInfoCount; i++)
	{
		ReplyToCommand(client, "%i. Name: %s Health: %i, Alive Time, %.2f Weapons Count: %i, model: %s", i, g_AirdropInfo[i].name, g_AirdropInfo[i].health, g_AirdropInfo[i].alivetime, g_AirdropInfo[i].weapons_count, g_AirdropInfo[i].model);
	}
	
	ReplyToCommand(client, "************************");
	ReplyToCommand(client, "Airplanes Infos");
	
	for (int i; i < g_iAirplaneInfoCount; i++)
	{
		ReplyToCommand(client, "%i. Name: %s Airdrops Count: %i, Drop Time: %.2f, Drop Delay: %.2f", i, g_AirplaneInfo[i].name, g_AirplaneInfo[i].airdrop_count, g_AirplaneInfo[i].droptime, g_AirplaneInfo[i].airdropdelay);
	}
	
	ReplyToCommand(client, "************************");
	
	return Plugin_Handled;
}

public Action sm_airdrop( int client, int args )
{
	if ( !client )
	{
		ReplyToCommand(client, "In game only.");
		return Plugin_Handled;
	}
	else if ( !CallAirdropInitiator(client, true) )
	{
		ReplyToCommand(client, "Failed to call airdrop");
	}
	
	return Plugin_Handled;
}

bool CallAirdropInitiator( int initiator, bool random, bool noSpecification = false)
{
	float vOrigin[3], vAngles[3];
	
	GetClientEyePosition(initiator, vOrigin);
	GetClientAbsAngles(initiator, vAngles);
	
	if ( !GetSkyOrigin(vOrigin, vOrigin, g_Globals.skyboxonly) )
		return false;
	
	if ( random )
		return CallAirdropRandom(vOrigin, vAngles, initiator);
		
	return CallAirdrop(vOrigin, vAngles, initiator, noSpecification);
}

bool CallAirdropRandom( const float vOrigin[3], const float vAngles[3], int initiator = 0, bool noSpecification = false )
{	
	g_NextAirplaneInfo = g_AirplaneInfo[GetRandomInt(0, g_iAirplaneInfoCount - 1)];
	g_NextAirdropInfo = g_AirdropInfo[GetRandomInt(0, g_iAirdropInfoCount - 1)];
	
	return CallAirdrop(vOrigin, vAngles, initiator, noSpecification);
}

bool CallAirdrop( const float vOrigin[3], const float vAngles[3], int initiator = 0, bool noSpecification = false )
{
	if ( g_Globals.chat_activity && initiator )
	{
		PrintToChatAll("\x04%N \x05called airdrop\x03!", initiator);
	}
	
	int slot = GetFreeAirplaneSlot();
	
	if ( slot == - 1)
	{
		LogMessage("You have reached limit of airdrops, reduce their count or expand limit");
		return false;
	}
	
	float vAng[3];
	vAng = vAngles;
	vAng[0] = 0.0;
	
	int airplane = CreateAirplane(vOrigin, vAng);
	
	Airplane plane;
	
	plane.entity = EntIndexToEntRef(airplane);
	plane.airplane_info = g_NextAirplaneInfo;
	
	if ( plane.airplane_info.specification[0] != '\0' && !noSpecification )
	{
		int airdropID = FindAirdropInfoByName(plane.airplane_info.specification);
		
		if ( airdropID == -1 )
		{
			RemoveEntityTimed(airplane);
			LogError("Invalid airplane specification (Airplane: (%s), Specification: (%s))", plane.airplane_info.name, plane.airplane_info.specification);
			return false;
		}
		
		plane.airdrop_info = g_AirdropInfo[airdropID];
	}
	else
	{
		plane.airdrop_info = g_NextAirdropInfo;
	}
	
	g_Airplanes[slot] = plane;
	
	g_iAirplanesCount++;
	
	CreateTimer(plane.airplane_info.droptime, timer_create_airdrops, plane.entity, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(AC130_KILL_TIME, timer_delete_airplane, slot, TIMER_FLAG_NO_MAPCHANGE);
	
	EmitSoundToAll(AC130_SOUND, airplane, SNDCHAN_AUTO, SNDLEVEL_HELICOPTER);
	SetVariantString("airport_intro_flyby");
	AcceptEntityInput(airplane, "SetAnimation");
	AcceptEntityInput(airplane, "Enable");
	
	LOG("Called airdrop initiator: %N, Airplane name: (%s), Airdrop name: (%s), airdropID: %i", initiator, plane.airplane_info.name, plane.airdrop_info.name, slot);
	return true;
}

public Action timer_delete_airplane( Handle timer, int i )
{
	int airplane = EntRefToEntIndex(g_Airplanes[i].entity);
	
	if ( airplane == INVALID_ENT_REFERENCE || !IsValidEntity(airplane) )
	{
		LogMessage("Something deleted airplane before me...");
	}
	else
	{
		LOG("Deleted airplane ID: %i", i);
		RemoveEntityTimed(airplane);
	}
	
	g_Airplanes[i].entity = -1;
	g_iAirplanesCount--;
	return Plugin_Continue;
}

public Action timer_create_airdrops( Handle timer, int airplane )
{
	if ( (airplane = EntRefToEntIndex(airplane)) == INVALID_ENT_REFERENCE || !IsValidEntity(airplane) )
		return Plugin_Continue;
	
	Airplane plane;
	int i = FindAirplane(airplane, plane);
	
	if ( i == -1 )
	{
		LOG("Failed to find airplane");
		return Plugin_Continue;
	}
	
	LOG("Creating supplies");
	SDKHook(airplane, SDKHook_Think, OnThink);
	return Plugin_Continue;
}

public Action OnThink( int airplane )
{
	Airplane plane;
	int i = FindAirplane(airplane, plane);
	
	if ( i == -1 || ( plane.dropped_count >= plane.airplane_info.airdrop_count && plane.flares_count >= plane.airdrop_info.flare_info.count ) )
	{
		SDKUnhook(airplane, SDKHook_Think, OnThink);
		return Plugin_Continue;
	}
	
	if ( plane.dropped_count < plane.airplane_info.airdrop_count && GetGameTime() - plane.airdrops_manager.lastdrop >= 0.0 )
	{
		plane.airdrops_manager.lastdrop = GetGameTime() + plane.airplane_info.airdropdelay;
		plane.dropped_count++;
		
		int crate, l, parachute;
		float vOrigin[3], vAngles[3], vFwd[3];
		
		GetEntPropVector(airplane, Prop_Send, "m_vecOrigin", vOrigin);
		GetEntPropVector(airplane, Prop_Send, "m_angRotation", vAngles);
		
		GetAngleVectors(vAngles, vFwd, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vFwd, plane.airplane_info.density * plane.dropped_count);
		AddVectors(vOrigin, vFwd, vOrigin);
		
		crate = CreateCrate(vOrigin, plane.airdrop_info);
		l = plane.airdrops_manager.Add(crate);
		
		ApplyCrateSettings(crate, plane.airdrop_info);
		
		if ( (parachute = AttachParachute(crate, plane)) != -1 )
		{
			LOG("Attached parachute to crate airplaneID: %i crateID: %i parachute: %s", i, l, plane.airdrop_info.parachute);
			plane.airdrops_manager.parachute[l] = EntIndexToEntRef(parachute);
			CreateTimer(0.2, timer_parachute_think, i, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		
		CreateTimer(plane.airdrop_info.alivetime, timer_delete_supply, (l << 16) | i, TIMER_FLAG_NO_MAPCHANGE);
		
		if ( plane.airdrop_info.flare_info.flare_type == STATIC_FLARE && plane.airdrop_info.flare_info.count_per_crate > 0 )
		{
			DataPack pack = new DataPack();
			
			pack.WriteCell(EntIndexToEntRef(crate));
			pack.WriteCell(i);
			
			CreateTimer(0.1, timer_crate_flares, pack, TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE | TIMER_FLAG_NO_MAPCHANGE);
		}
		
		LOG("Created supply %i of %i, alivetime: %.2f ... Next drop in %.2f", plane.dropped_count, plane.airplane_info.airdrop_count, plane.airdrop_info.alivetime, plane.airdrops_manager.lastdrop - GetGameTime());
	}
	
	if ( plane.airdrop_info.flare_info.flare_type == DYNAMIC_FLARE && plane.airdrop_info.flare_info.count > 0 && plane.flares_count < plane.airdrop_info.flare_info.count && GetGameTime() - plane.airdrop_info.flare_info.last_spawn >= 0.0 )
	{
		plane.airdrop_info.flare_info.last_spawn = GetGameTime() + plane.airdrop_info.flare_info.spawn_interval;
		plane.flares_count++;
		
		LOG("Creating dynamic flares flareID: %i, interval: %f", plane.flares_count, plane.airdrop_info.flare_info.spawn_interval);
		
		float vOrigin[3], vAngles[3], vFwd[3];
		int projectile, flare;
		
		GetEntPropVector(airplane, Prop_Send, "m_vecOrigin", vOrigin);
		GetEntPropVector(airplane, Prop_Send, "m_angRotation", vAngles);
		
		GetAngleVectors(vAngles, vFwd, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vFwd, plane.airdrop_info.flare_info.density * plane.flares_count);
		AddVectors(vOrigin, vFwd, vOrigin);
		
		vOrigin[2] -= 50.0;
		
		vAngles[0] = GetRandomFloat(89.0, 70.0);
		vAngles[1] = GetRandomFloat(-179.0, 179.0);
		vAngles[2] = 0.0;
		
		GetAngleVectors(vAngles, vFwd, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vFwd, GetRandomFloat(150.0, 450.0));
	
		projectile = CreateProjetile(vOrigin, vAngles, vFwd);
		flare = CreateFlare(view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}), plane.airdrop_info.flare_info);
		
		SetEntityRenderMode(projectile, RENDER_NONE);
		SetEntityGravity(projectile, plane.airdrop_info.flare_info.gravity);
		
		SetEntPropFloat(projectile, Prop_Data, "m_flElasticity", 0.1);
		
		do
		{
			SetVariantString("!activator");
			AcceptEntityInput(flare, "SetParent", projectile);
			
			TeleportEntity(flare, view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
		}
		while ( (flare = GetEntPropEnt(flare, Prop_Send, "m_hOwnerEntity")) != -1 && flare > MaxClients );
		
		SDKHook(projectile, SDKHook_ShouldCollide, OnShouldCollide);
		
		int l = plane.flare_manager.Add(projectile);
		CreateTimer(plane.airdrop_info.flare_info.alivetime, timer_delete_flare, (l << 16) | i, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	g_Airplanes[i] = plane;
	return Plugin_Continue;
}

public bool OnShouldCollide( int entity, int collisiongroup, int contentsmask, bool originalResult )
{
	return false;
}

public Action timer_parachute_think( Handle timer, int i )
{
	int crate, parachute;
	float vVelocity[3], vOrigin[3], vEnd[3];
	Handle ray;
	bool set;
	
	for( int j; j < MAX_AIRDROPS; j++ )
	{
		crate = EntRefToEntIndex(g_Airplanes[i].airdrops_manager.crates[j]);
		
		if ( !crate || !IsValidEntity(crate) )
			continue;
		
		parachute = EntRefToEntIndex(g_Airplanes[i].airdrops_manager.parachute[j]);
		
		if ( !parachute || !IsValidEntity(parachute) )
			continue;
		
		GetEntPropVector(crate, Prop_Send, "m_vecOrigin", vOrigin);
		ray = TR_TraceRayFilterEx(vOrigin, view_as<float>({89.0, 0.0, 0.0}), MASK_SHOT, RayType_Infinite, __TraceFilter);
	
		if ( !TR_DidHit(ray) )
		{
			delete ray;
			continue;
		}
		
		TR_GetEndPosition(vEnd, ray);
		delete ray;
		
		if ( GetVectorDistance(vOrigin, vEnd) >= GROUND_THRESHOLD )
		{
			set = true;
			GetEntPropVector(crate, Prop_Data, "m_vecVelocity", vVelocity);
			vVelocity[2] = g_Airplanes[i].airdrop_info.parachute_speed;
			
			if ( vVelocity[2] > 0.0 )
				vVelocity[2] = -vVelocity[2];
			
			TeleportEntity(crate, NULL_VECTOR, NULL_VECTOR, vVelocity);
		}
		else
		{
			RemoveEntityTimed(parachute);
		}
	}
	
	if ( !set )
	{
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action timer_crate_flares( Handle timer, DataPack pack)
{
	pack.Reset();
	
	int crate = EntRefToEntIndex(pack.ReadCell());
	int i = pack.ReadCell();
	
	if ( crate == INVALID_ENT_REFERENCE || !IsValidEntity(crate) || !IsValidEntity(EntRefToEntIndex(g_Airplanes[i].entity)) )
		return Plugin_Stop;
	
	float vOrigin[3], vEnd[3], vResult[3], vRelative[3];
	GetEntPropVector(crate, Prop_Send, "m_vecOrigin", vOrigin);
	
	Handle ray = TR_TraceRayFilterEx(vOrigin, view_as<float>({89.0, 0.0, 0.0}), MASK_SHOT, RayType_Infinite, __TraceFilter);
	
	if ( !TR_DidHit(ray) )
	{
		delete ray;
		return Plugin_Stop;
	}
	
	TR_GetEndPosition(vEnd, ray);
	delete ray;
	
	if ( GetVectorDistance(vOrigin, vEnd) >= GROUND_THRESHOLD )
		return Plugin_Continue;
	
	LOG("Spawning flares");
	
	for (int j; j < g_Airplanes[i].airdrop_info.flare_info.count_per_crate; j++)
	{	
		float vCorners[2][3], x, y, extent;
		ArrayList areas;
		Address area;
		int flare;
		
		if ( g_Airplanes[i].airdrop_info.flare_info.spawn_type == RELATIVE )
		{
			vRelative = g_Airplanes[i].airdrop_info.flare_info.relative_origin;
			AddVectors(vEnd, vRelative, vResult);
		}
		else if ( g_Airplanes[i].airdrop_info.flare_info.spawn_type == RANDOM )
		{
			x = GetRandomFloat(0.0, g_Airplanes[i].airdrop_info.flare_info.radius);
			y = SquareRoot(Pow(g_Airplanes[i].airdrop_info.flare_info.radius, 2.0) - Pow(x, 2.0));
			
			vRelative[0] += (GetRandomInt(0, 1) ? -x : x);
			vRelative[1] += (GetRandomInt(0, 1) ? -y : y);
			
			AddVectors(vEnd, vRelative, vResult);
		}
		else if ( g_Airplanes[i].airdrop_info.flare_info.spawn_type == NAVIGATION )
		{
			if ( !g_bL4DHooks )
			{
				LogError("You must install Left 4 DHooks to use NAVIGATION spawn type...");
				return Plugin_Stop;
			}
			
			area = view_as<Address>(L4D_GetNearestNavArea(vEnd));
			
			if ( area == Address_Null )
				return Plugin_Stop;
				
			L4D_FindRandomSpot(view_as<int>(area), vResult);
			GetCorners(area, vCorners[0], vCorners[1]);
			
			extent = GetVectorDistance(vCorners[0], vCorners[1]);
			
			if ( extent <= NAVIGATION_EXTENT_THRESHOLD )
			{
				areas = GetAdjacentAreas(area);
				
				if ( !areas.Length )
				{
					delete areas;
					return Plugin_Stop;
				}
				
				area = areas.Get(GetRandomInt(0, areas.Length - 1));
				L4D_FindRandomSpot(view_as<int>(area), vResult);
				
				delete areas;
			}
		}
		
		if ( GetVectorDistance(vEnd, vResult) > g_Airplanes[i].airdrop_info.flare_info.radius )
		{
			float vVec[3];
			MakeVectorFromPoints(vEnd, vResult, vVec);
			NormalizeVector(vVec, vVec);
			ScaleVector(vVec, g_Airplanes[i].airdrop_info.flare_info.radius);
			AddVectors(vVec, vEnd, vResult);
		}
		
		flare = CreateFlare(vResult, view_as<float>({0.0, 0.0, 0.0}), g_Airplanes[i].airdrop_info.flare_info);
		int l = g_Airplanes[i].flare_manager.Add(flare);
		
		if ( l == -1 )
		{
			LogError("Flares limit exceed reduce their count or expand limit");
			break;
		}
		
		CreateTimer(g_Airplanes[i].airdrop_info.flare_info.alivetime, timer_delete_flare, (l << 16) | i, TIMER_FLAG_NO_MAPCHANGE);
		g_Airplanes[i].flares_count++;
	}
	
	return Plugin_Stop;
}

public Action timer_delete_flare( Handle timer, int data )
{
	int flareID = data >> 16;
	int airplaneID = data & 0xFFFF;
	
	g_Airplanes[airplaneID].flare_manager.Kill(flareID);
	g_Airplanes[airplaneID].flares_count--;
	
	LOG("Deleting flare ID: %i Remaining: %i", flareID, g_Airplanes[airplaneID].flares_count);
	return Plugin_Continue;
}

public Action timer_delete_supply( Handle timer, int data )
{
	int supplyID = data >> 16;
	int airplaneID = data & 0xFFFF;
	
	LOG("Deleted supply: %i airplane ID: %i", supplyID + 1, airplaneID);
	
	if ( !g_Airplanes[airplaneID].airdrops_manager.Kill(supplyID) )
	{
		LOG("Failed to delete supply... Probably used");
	}
	
	g_Airplanes[airplaneID].dropped_count--;
	return Plugin_Continue;
}

int CreateAirplane( const float vOrigin[3], const float vAngles[3] )
{	
	int entity = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(entity, "targetname", "ac130");
	DispatchKeyValue(entity, "disableshadows", "1");
	DispatchKeyValue(entity, "solid", "0");
	DispatchKeyValue(entity, "model", AC130_MODEL);
	TeleportEntity(entity, vOrigin, vAngles, NULL_VECTOR);
	DispatchSpawn(entity);
	return entity;
}

int CreateCrate( float vOrigin[3], AirdropInfo info )
{
	int entity = CreateEntityByName("prop_physics_override");	
	
	switch( info.type )
	{
		case BREAKABLE:
		{
			DispatchKeyValueFloat(entity, "health", float(info.health) == 0.0 ? 125.0 : float(info.health));
			DispatchKeyValue(entity, "solid", "6");	
		}
		
		case PRESS:
		{
			DispatchKeyValue(entity, "health", "0");			
			DispatchKeyValue(entity, "solid", "0");			
		}
		
		case TOUCH:
		{
			DispatchKeyValue(entity, "health", "0");			
			DispatchKeyValue(entity, "solid", "6");			
		}
	}
	
	DispatchKeyValueVector(entity, "origin", vOrigin);
	DispatchKeyValue(entity, "targetname", "SupplyDrop");
	DispatchKeyValue(entity, "model", info.model);
	SetEntityModel(entity, info.model);
	DispatchSpawn(entity);
	return entity;
}

void ApplyCrateSettings( int crate, AirdropInfo info )
{
	switch ( info.type )
	{
		case BREAKABLE:
		{
			HookSingleEntityOutput(crate, "OnBreak", OnCrateBreak, true);
		}
		
		case PRESS:
		{
			int button = AttachButtonToCrate(crate, info);
			
			SetEntityModel(button, info.model);
			SetEntPropVector(button, Prop_Send, "m_vecMins", info.mins);
			SetEntPropVector(button, Prop_Send, "m_vecMaxs", info.maxs);

			TeleportEntity(button, info.relative_origin, NULL_VECTOR, NULL_VECTOR);
		}
		
		case TOUCH:
		{
			SDKHook(crate, SDKHook_TouchPost, OnTouch);
		}
	}
	
	SetEntProp(crate, Prop_Send, "m_nGlowRange", info.glow_info.range);
	SetEntProp(crate, Prop_Send, "m_iGlowType", info.glow_info.type);
	SetEntProp(crate, Prop_Send, "m_glowColorOverride", info.glow_info.color);
}

public void OnTouch( int entity, int other )
{
	if ( other > 0 && other <= MaxClients )
	{
		SDKUnhook(entity, SDKHook_TouchPost, OnTouch);
		StartSupplyRoutine(entity);
		AcceptEntityInput(entity, "break");
	}
}

public void OnCrateBreak( const char[] output, int crate, int breaker, float delay )
{
	StartSupplyRoutine(crate);
}

public void OnButtonTimeUp( const char[] output, int button, int presses, float delay )
{
	int crate = GetEntPropEnt(button, Prop_Send, "m_hOwnerEntity");
	
	if ( crate != -1 )
	{
		StartSupplyRoutine(crate);
		AcceptEntityInput(crate, "break");
	}
}

void StartSupplyRoutine( int crate )
{
	Airplane plane;
	int i = FindAirplaneByCrate(crate, plane);
	
	if ( i == -1 )
	{
		LogError("Failed to find airplane... Can't spawn weapons");
		return;
	}
	
	CreateSupplyWeapons(crate, plane.airdrop_info);
	
	// g_Airplanes[i].dropped_count--;
	// g_Airplanes[i].flare_manager.KillAll();
}

void CreateSupplyWeapons( int crate, AirdropInfo dropinfo )
{
	LOG("Starting creating weapons...");
	
	char szName[36];
	int entity, index;
	
	Random random;
	WeaponInfo info;
	
	if ( dropinfo.weapons_info.list == null )
	{
		LOG("Empty or no \"weapons\" section... Use global config");
		random = random.GetRandom(g_DefaultWeaponsInfo);
		info = g_DefaultWeaponsInfo;
	}
	else
	{
		random = random.GetRandom(dropinfo.weapons_info);
		info = dropinfo.weapons_info;
	}
	
	float vOrigin[3];
	GetEntPropVector(crate, Prop_Send, "m_vecOrigin", vOrigin);
	
	for (int i; i < dropinfo.weapons_count; i++)
	{		
		index = random.GetWeapon(info.weight);
		
		IntToString(index, szName, 4);
		info.map.GetString(szName, szName, sizeof szName);
		
		LOG("Creating weapon: %s", szName);
		
		if ( strcmp(szName, "nothing") == 0 )
			continue;
		
		if ( !SpawnMelee(szName, vOrigin) )
		{
			entity = CreateEntityByName(szName);
		
			TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity);
			
			SDKHook(entity, SDKHook_UsePost, OnUse);
		}
	}
}

public void OnUse( int entity, int activator, int caller, UseType type, float value )
{
	SDKUnhook(entity, SDKHook_UsePost, OnUse);
	
	if ( activator > 0 && activator <= MaxClients )
	{
		int ammotype = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType");
		
		if ( ammotype == -1 )
			return;
			
		GivePlayerAmmo(activator, 999, ammotype, true);
	}
}

bool SpawnMelee( const char[] name, const float vOrigin[3] )
{	
	static const char szMeleeNames[][] =
	{
		"baseball_bat",
		"cricket_bat",
		"crowbar",
		"electric_guitar",
		"fireaxe",
		"frying_pan",
		"golfclub",
		"katana",
		"machete",
		"tonfa",
		"knife",
		"shovel",
		"pitchfork"
	};
	
	int index = -1;
	
	for (int i; i < sizeof szMeleeNames; i++)
	{
		if ( StrContains(name, szMeleeNames[i]) != -1 )
		{
			index = i;
			break;
		}
	}
	
	if ( index == -1 )
	{
		return false;
	}
	
	int weapon = CreateEntityByName("weapon_melee");
	DispatchKeyValue(weapon, "melee_script_name", szMeleeNames[index]);
	DispatchSpawn(weapon);

	TeleportEntity(weapon, vOrigin, NULL_VECTOR, NULL_VECTOR);
	
	char szModel[128];
	GetEntPropString(weapon, Prop_Data, "m_ModelName", szModel, sizeof szModel); 
	
	if ( StrContains( szModel, "hunter", false ) != -1 )
		AcceptEntityInput(weapon, "kill");
		
	return true;
}

int AttachParachute( int crate, Airplane plane )
{
	if ( plane.airdrop_info.parachute[0] == '\0' )
		return -1;
	
	int parachute = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(parachute, "solid", "0");
	DispatchKeyValue(parachute, "model", plane.airdrop_info.parachute);
	DispatchSpawn(parachute);
	
	SetVariantString("!activator");
	AcceptEntityInput(parachute, "SetParent", crate);
	
	TeleportEntity(parachute, view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR, NULL_VECTOR);
	return parachute;
}

int AttachButtonToCrate( int crate, AirdropInfo info )
{
	int button = CreateEntityByName("func_button_timed");
	DispatchKeyValue(button, "use_string", g_Globals.usestring);
	DispatchKeyValue(button, "use_time", info.use_time);
	DispatchKeyValue(button, "solid", "0");
	DispatchKeyValue(button, "auto_disable", "1");
	DispatchSpawn(button);
	ActivateEntity(button);
	
	HookSingleEntityOutput(button, "OnTimeUp", OnButtonTimeUp);
	
	SetEntPropEnt(button, Prop_Send, "m_hOwnerEntity", crate);
	SetEntPropEnt(crate, Prop_Send, "m_hOwnerEntity", button);
	SetEntProp(button, Prop_Send, "m_fEffects", GetEntProp(button, Prop_Send, "m_fEffects") | 0x20); /* EF_NODRAW */
	SetEntityRenderMode(button, RENDER_NONE);
	
	SetVariantString("!activator");
	AcceptEntityInput(button, "SetParent", crate);
	
	TeleportEntity(button, view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR, NULL_VECTOR);
	
	return button;
}

int CreateProjetile( const float vOrigin[3], const float vAngles[3], const float vVelocity[3] )
{
	int entity = CreateEntityByName("molotov_projectile");
	DispatchKeyValue(entity, "solid", "0");
	DispatchSpawn(entity);
	TeleportEntity(entity, vOrigin, vAngles, vVelocity);
	return entity;
}

int CreateFlare( float vOrigin[3], float vAngles[3], FlareInfo info )
{
	char szColor[12];
	FormatEx(szColor, sizeof szColor, "%i %i %i", info.color[0], info.color[1], info.color[2]);
	
	int current, next;
	
	current = CreateEntityByName("prop_dynamic");
	next = current;
	
	SetEntityModel(current, MODEL_FLARE);
	TeleportEntity(current, vOrigin, vAngles, NULL_VECTOR);
	DispatchSpawn(current);
	
	vOrigin[2] += 15.0;
	
	current = MakeLightDynamic(vOrigin, view_as<float>({ 90.0, 0.0, 0.0 }), szColor, info.light_distance);
	SetEntPropEnt(current, Prop_Send, "m_hOwnerEntity", next);
	next = current;
	
	vOrigin[2] -= 15.0;
	
	vAngles[1] = GetRandomFloat(1.0, 360.0);
	vAngles[0] = -80.0;
	vOrigin[0] += (1.0 * (Cosine(DegToRad(vAngles[1]))));
	vOrigin[1] += (1.5 * (Sine(DegToRad(vAngles[1]))));
	vOrigin[2] += 1.0;

	current = CreateParticle(PARTICLE_FLARE, vOrigin, vAngles);
	SetEntPropEnt(current, Prop_Send, "m_hOwnerEntity", next);
	next = current;
	
	current = CreateParticle(PARTICLE_FUSE, vOrigin, vAngles);
	SetEntPropEnt(current, Prop_Send, "m_hOwnerEntity", next);
	next = current;
	
	vAngles[0] = -85.0;
	current = MakeEnvSteam(vOrigin, vAngles, szColor, info.alpha, info.length);
	SetEntPropEnt(current, Prop_Send, "m_hOwnerEntity", next);
	next = current;
	
	return next;
}

int CreateParticle( const char[] sParticle, const float vPos[3], const float vAng[3] )
{
	int entity = CreateEntityByName("info_particle_system");

	DispatchKeyValue(entity, "effect_name", sParticle);
	TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "start");
	return entity;
}

int MakeEnvSteam( const float vOrigin[3], const float vAngles[3], const char[] sColor, int iAlpha, int iLength )
{
	int entity = CreateEntityByName("env_steam");
	char sTemp[5];
	DispatchKeyValue(entity, "SpawnFlags", "1");
	DispatchKeyValue(entity, "rendercolor", sColor);
	DispatchKeyValue(entity, "SpreadSpeed", "1");
	DispatchKeyValue(entity, "Speed", "15");
	DispatchKeyValue(entity, "StartSize", "1");
	DispatchKeyValue(entity, "EndSize", "3");
	DispatchKeyValue(entity, "Rate", "10");
	IntToString(iLength, sTemp, sizeof(sTemp));
	DispatchKeyValue(entity, "JetLength", sTemp);
	IntToString(iAlpha, sTemp, sizeof(sTemp));
	DispatchKeyValue(entity, "renderamt", sTemp);
	DispatchKeyValue(entity, "InitialState", "1");
	DispatchKeyValueVector(entity, "origin", vOrigin);
	DispatchKeyValueVector(entity, "angles", vAngles);
	AcceptEntityInput(entity, "TurnOn");
	DispatchSpawn(entity);
	return entity;
}

int MakeLightDynamic(const float vOrigin[3], const float vAngles[3], const char[] sColor, int iDist)
{
	int entity = CreateEntityByName("light_dynamic");
	char sTemp[16];
	Format(sTemp, sizeof(sTemp), "6");
	DispatchKeyValue(entity, "style", sTemp);
	Format(sTemp, sizeof(sTemp), "%s 255", sColor);
	DispatchKeyValue(entity, "_light", sTemp);
	DispatchKeyValue(entity, "brightness", "1");
	DispatchKeyValueFloat(entity, "spotlight_radius", 32.0);
	DispatchKeyValueFloat(entity, "distance", float(iDist));
	TeleportEntity(entity, vOrigin, vAngles, NULL_VECTOR);
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "TurnOn");
	return entity;
}

///////////////////////////////////////////////

stock void NullifyConfig()
{
	AirplaneInfo nullairplane;
	AirdropInfo nullairdrop;
	WeaponInfo nullweaponinfo;
	GlobalSettings nullglobals;
	
	for (int i; i < MAX_AIRPLANES_INFO; i++)
	{
		g_AirplaneInfo[i] = nullairplane;
	}
	
	for (int i; i < MAX_AIRDROPS_INFO; i++)
	{
		g_AirdropInfo[i] = nullairdrop;
	}
	
	g_DefaultWeaponsInfo = nullweaponinfo;
	g_Globals = nullglobals;

	g_iSectionLevel = 0;
	g_iSectionType = SECTION_NONE;
	g_iLastSectionType = SECTION_NONE;
	
	if ( g_hSectionsStack )
	{
		delete g_hSectionsStack;
	}
	
	g_hSectionsStack = new ArrayStack();

	g_iAirplaneInfoCount = 0;
	g_iAirdropInfoCount = 0;
	g_iAirplanesCount = 0;
	g_iAirdropsTimerCount = 0;
}

stock void DeleteEntities()
{
	Airplane nullplane;
	int entity;
	
	for (int i; i < MAX_AIRPLANES; i++)
	{
		if ( (entity = EntRefToEntIndex(g_Airplanes[i].entity)) != INVALID_ENT_REFERENCE && entity && IsValidEntity(entity) )
		{
			RemoveEntityTimed(entity);
		}
		
		g_Airplanes[i].flare_manager.KillAll();
		g_Airplanes[i].airdrops_manager.KillAll();
		g_Airplanes[i] = nullplane;
	}
	
	g_iAirplanesCount = 0;
}

stock void Shutdown()
{
	DeleteEntities();
	
	g_iAirdropInfoCount = 0;
	g_iAirplaneInfoCount = 0;
	g_iSectionLevel = 0;
	g_iSectionType = SECTION_NONE;
	
	delete g_hSectionsStack;
}

stock int GetFreeAirplaneSlot()
{
	if ( g_iAirplanesCount >= MAX_AIRPLANES )
		return -1;
	
	int entity;
	
	for (int i; i < MAX_AIRPLANES; i++)
	{
		if ( !g_Airplanes[i].entity || (entity = EntRefToEntIndex(g_Airplanes[i].entity)) == INVALID_ENT_REFERENCE || !IsValidEntity(entity) )
		{
			if ( g_Airplanes[i].dropped_count > 0 || g_Airplanes[i].flares_count > 0 )
				continue;
				
			return i;
		}
	}
	
	return -1;
}

stock int FindAirdropInfoByName( const char[] name )
{
	for (int i; i < MAX_AIRDROPS_INFO; i++)
	{
		if ( g_AirdropInfo[i].name[0] != '\0' && strcmp(g_AirdropInfo[i].name, name, false) == 0 )
		{
			return i;
		}
	}
	
	return -1;
}

stock int FindAirplaneInfoByName( const char[] name )
{
	for (int i; i < MAX_AIRPLANES_INFO; i++)
	{
		if ( g_AirplaneInfo[i].name[0] != '\0' && strcmp(g_AirplaneInfo[i].name, name, false) == 0 )
		{
			return i;
		}
	}
	
	return -1;
}

stock int FindAirplaneByCrate( int crate, Airplane out )
{
	for (int i; i < MAX_AIRPLANES; i++)
	{
		for (int j; j < g_Airplanes[i].airdrops_manager.index; j++)
		{
			if ( g_Airplanes[i].airdrops_manager.crates[j] == EntIndexToEntRef(crate) )
			{
				out = g_Airplanes[i];
				return i;
			}
		}
	}
	
	return -1;
}

stock int FindAirplane( int plane, Airplane out )
{
	for (int i; i < MAX_AIRPLANES; i++)
	{
		if ( g_Airplanes[i].entity == EntIndexToEntRef(plane) )
		{
			out = g_Airplanes[i];
			return i;
		}
	}
	
	return -1;
}

stock int GetRandomPlayer()
{
	int []players = new int[MaxClients];
	int count;
	
	float vOrigin[3];
	
	for( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
		{
			GetClientEyePosition(i, vOrigin);
			
			if ( GetSkyOrigin(vOrigin, vOrigin, g_Globals.skyboxonly) )
			{
				players[count++] = i;
			}
		}
	}
	
	if ( !count )
		return -1;
	
	return players[GetRandomInt(0, count - 1)];
}

stock void RemoveEntityTimed( int entity, float time = 0.0 )
{
	if ( !entity )
	{
		ThrowError("Tried to delete world...");
		return;
	}
	
	if ( time == 0.0 )
	{
		// RemoveEntity(entity);
		AcceptEntityInput(entity, "KillHierarchy");
		return;
	}
	
	char output[36];
	Format(output, sizeof(output), "OnUser1 !self:KillHierarchy::%f:1", time);
	SetVariantString(output);
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
}

stock void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;

	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}

stock bool GetSkyOrigin( const float vOrigin[3], float out[3], bool skyonly = false )
{
	LOG("Called GetSkyOrigin skyonly: %i", skyonly);
	
	Handle ray = TR_TraceRayFilterEx(vOrigin, view_as<float>({-89.0, 0.0, 0.0}), MASK_ALL, RayType_Infinite, __TraceFilter);
	
	if ( !TR_DidHit(ray) )
	{
		delete ray;
		return false;
	}
	
	if ( skyonly && !(TR_GetSurfaceFlags(ray) & (SURF_SKY | SURF_SKY2D)) )
	{
		LOG("GetSkyOrigin fail skyonly: 1 (NO SKY FOUND)", skyonly);
		delete ray;
		return false;
	}
	
	float vVec[3];
	TR_GetEndPosition(vVec, ray);

	if ( g_Globals.maxheight != 0.0 && GetVectorDistance(vOrigin, vVec) >= g_Globals.maxheight )
	{
		vVec[2] = vOrigin[2] + g_Globals.maxheight;
	}
	else
	{
		vVec[2] -= 20.0;
	}
	
	out = vVec;
	delete ray;
	return true;
}

public bool __TraceFilter( int entity, int mask )
{
	return entity <= 0;
}

///////////////////////////////////////////////

stock ArrayList GetAdjacentAreas( Address area )
{
	ArrayList list = new ArrayList();
	int count;
	
	for (int i; i < 4; i++)
	{
		Address areas = view_as<Address>(LoadFromAddress(area + view_as<Address>(0x58 + 4 * i), NumberType_Int32));
		count = LoadFromAddress(areas, NumberType_Int32);
		
		for (int l; l < count; l++)
		{
			list.Push(LoadFromAddress(areas + view_as<Address>(l * 8 + 4), NumberType_Int32));
		}
	}
	
	return list;
}

void GetCorners( const Address area, float m_nwCorner[3], float m_seCorner[3] )
{
	m_nwCorner[0] = view_as<float>(LoadFromAddress(area + view_as<Address>(4), NumberType_Int32));
	m_nwCorner[1] = view_as<float>(LoadFromAddress(area + view_as<Address>(8), NumberType_Int32));
	m_nwCorner[2] = view_as<float>(LoadFromAddress(area + view_as<Address>(12), NumberType_Int32));
	
	m_seCorner[0] = view_as<float>(LoadFromAddress(area + view_as<Address>(16), NumberType_Int32));
	m_seCorner[1] = view_as<float>(LoadFromAddress(area + view_as<Address>(20), NumberType_Int32));
	m_seCorner[2] = view_as<float>(LoadFromAddress(area + view_as<Address>(24), NumberType_Int32));
}

stock float MIN( float left, float right ) { return ( left < right ? left : right ); }
stock float MAX( float left, float right ) { return ( left > right ? left : right ); }

stock float fsel( float c, float x, float y ) { return ( c >= 0.0 ? x : y ); }	

///////////////////////////////////////////////

bool ParseConfig( const char[] path )
{
	if ( !FileExists(path) )
	{
		LogError("Failed to load config... File doesn't exist");
		return false;
	}
	
	NullifyConfig();
	
	SMCParser parser = new SMCParser();
	char error[128]; 
	int line = 0, col = 0;
	
	parser.OnEnterSection = Config_NewSection;
	parser.OnLeaveSection = Config_EndSection;
	parser.OnKeyValue = Config_KeyValue;
	
	SMCError result = SMC_ParseFile(parser, path, line, col);
	delete parser;
	
	if ( result != SMCError_Okay )
	{
		SMC_GetErrorString(result, error, sizeof(error));
		LogError("%s on line %d, col %d of %s", error, line, col, path);
		return false;
	}
	
	return ( result == SMCError_Okay );
}

#pragma unused g_iLastSectionType
public SMCResult Config_NewSection( Handle parser, const char[] section, bool quotes )
{	
	g_iSectionLevel++;
	g_hSectionsStack.Push(g_iSectionType);
	g_iLastSectionType = g_iSectionType;
	
	if ( g_iSectionLevel == 2 )
	{
		if ( strcmp(section, "Settings", false) == 0 )
		{
			g_iSectionType |= SECTION_GLOBAL_SETTINGS;
		}
		else if ( strcmp(section, "global_weapons", false) == 0 )
		{
			g_iSectionType |= SECTION_GLOBAL_WEAPONS;
		}
		else if ( strncmp(section, "AirdropInfo", 11, false) == 0 )
		{
			g_iSectionType |= SECTION_AIRDROP_INFO;
		}
		else if ( strncmp(section, "AirplaneInfo", 11, false) == 0 )
		{
			g_iSectionType |= SECTION_AIRPLANE_INFO;
		}
	}
	
	if ( g_iSectionLevel == 3 )
	{
		if ( strcmp(section, "weapons", false) == 0 )
		{
			g_iSectionType |= SECTION_PRIVATE_WEAPONS_INFO;
		}
		else if ( strncmp(section, "flare", 5, false) == 0 )
		{
			g_iSectionType |= SECTION_PRIVATE_FLARES_INFO;
		}
		else if ( strcmp(section, "glow", false) == 0 )
		{
			g_iSectionType |= SECTION_PRIVATE_GLOW_INFO;
		}
	}
	
	LOG("%i. Enter %s section ( Current: (%s) Last: (%s) )", g_iSectionLevel, section, FormatSection(g_iSectionType), FormatSection(g_iLastSectionType));
	return SMCParse_Continue;
}

public SMCResult Config_KeyValue( Handle parser, char[] key, char[] value, bool key_quotes, bool value_quotes )
{
	LOG("OnKeyValue \"%s\" \"%s\"", key, value);
	
	if ( g_iSectionType & SECTION_GLOBAL_SETTINGS )
	{
		if ( strcmp(key, "max_height", false) == 0 )
		{
			g_Globals.maxheight = StringToFloat(value);
		}
		else if ( strcmp(key, "airdrop_timer", false) == 0 )
		{
			g_Globals.airdrop_timer = StringToFloat(value);
		}
		else if ( strcmp(key, "airdrop_timer_max_count", false) == 0 )
		{
			g_Globals.airdrop_timer_max_count = StringToInt(value);
		}
		else if ( strcmp(key, "use_string", false) == 0 )
		{
			strcopy(g_Globals.usestring, sizeof GlobalSettings::usestring, value);
		}
		else if ( strcmp(key, "activity", false) == 0 )
		{
			g_Globals.chat_activity = !!StringToInt(value);
		}
		else if ( strcmp(key, "skyboxonly", false) == 0 )
		{
			g_Globals.skyboxonly = !!StringToInt(value);
		}
	}
	else if ( g_iSectionType & SECTION_GLOBAL_WEAPONS )
	{
		g_DefaultWeaponsInfo.Init();
		g_DefaultWeaponsInfo.Add(key, value);
	}
	else if ( g_iSectionType & SECTION_AIRDROP_INFO )
	{
		float vVec[3];
		
		if ( g_iSectionType & SECTION_PRIVATE_WEAPONS_INFO )
		{
			g_AirdropInfo[g_iAirdropInfoCount].weapons_info.Init();
			g_AirdropInfo[g_iAirdropInfoCount].weapons_info.Add(key, value);
		}
		else if ( g_iSectionType & SECTION_PRIVATE_FLARES_INFO )
		{
			if ( strcmp(key, "length", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.length = StringToInt(value);
			}
			else if ( strcmp(key, "light_distance", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.light_distance = StringToInt(value);
			}
			else if ( strcmp(key, "alivetime", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.alivetime = StringToFloat(value);
			}
			else if ( strcmp(key, "radius", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.radius = StringToFloat(value);
			}
			else if ( strcmp(key, "density", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.density = StringToFloat(value);
			}
			else if ( strcmp(key, "spawn_interval", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.spawn_interval = StringToFloat(value);
			}
			else if ( strcmp(key, "gravity", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.gravity = StringToFloat(value);
			}
			else if ( strcmp(key, "count", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.count = _MIN(StringToInt(value), MAX_FLARES);
			}
			else if ( strcmp(key, "count_per_crate", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.count_per_crate = _MIN(StringToInt(value), MAX_FLARES);
			}
			else if ( strcmp(key, "alpha", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.alpha = StringToInt(value);
			}
			else if ( strcmp(key, "spawn_type", false) == 0 )
			{
				if ( strncmp(value, "re", 2, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].flare_info.spawn_type = RELATIVE;
				}
				else if ( strncmp(value, "ra", 2, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].flare_info.spawn_type = RANDOM;
				}
				else if ( strncmp(value, "n", 1, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].flare_info.spawn_type = NAVIGATION;
				}
			}
			else if ( strcmp(key, "flare_type", false) == 0 )
			{
				if ( strncmp(value, "d", 1, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].flare_info.flare_type = DYNAMIC_FLARE;
				}
				else
				{
					g_AirdropInfo[g_iAirdropInfoCount].flare_info.flare_type = STATIC_FLARE;
				}
			}
			else if ( strcmp(key, "color", false) == 0 )
			{
				StringToVector(value, vVec);
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.color[0] = RoundToNearest(vVec[0]);
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.color[1] = RoundToNearest(vVec[1]);
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.color[2] = RoundToNearest(vVec[2]);
			}
			else if ( strcmp(key, "relative_origin", false) == 0 )
			{
				StringToVector(value, vVec);
				g_AirdropInfo[g_iAirdropInfoCount].flare_info.relative_origin = vVec;
			}
		}
		else if ( g_iSectionType & SECTION_PRIVATE_GLOW_INFO )
		{
			if ( strcmp(key, "type", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].glow_info.type = StringToInt(value);
			}
			else if ( strcmp(key, "range", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].glow_info.range = StringToInt(value);
			}
			else if ( strcmp(key, "color", false) == 0 )
			{
				StringToVector(value, vVec);
				g_AirdropInfo[g_iAirdropInfoCount].glow_info.color = RoundToNearest(RGB_TO_VALUE(vVec[0], vVec[1], vVec[2]));
			}
		}
		else
		{
			if ( strcmp(key, "name", false) == 0 )
			{
				strcopy(g_AirdropInfo[g_iAirdropInfoCount].name, sizeof AirdropInfo::name, value);
			}
			else if ( strcmp(key, "health", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].health = StringToInt(value);
			}
			else if ( strcmp(key, "weapons_count", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].weapons_count = StringToInt(value);
			}
			else if ( strcmp(key, "alivetime", false) == 0 )
			{
				LOG("%i %f", g_iAirdropInfoCount, StringToFloat(value));
				g_AirdropInfo[g_iAirdropInfoCount].alivetime = StringToFloat(value);
			}
			else if ( strcmp(key, "model", false) == 0 )
			{
				strcopy(g_AirdropInfo[g_iAirdropInfoCount].model, sizeof AirdropInfo::model, value);
			}
			else if ( strcmp(key, "parachute", false) == 0 )
			{
				strcopy(g_AirdropInfo[g_iAirdropInfoCount].parachute, sizeof AirdropInfo::parachute, value);
			}
			else if ( strcmp(key, "parachute_speed", false) == 0 )
			{
				g_AirdropInfo[g_iAirdropInfoCount].parachute_speed = StringToFloat(value);
			}
			else if ( strcmp(key, "relative_origin", false) == 0 )
			{
				StringToVector(value, vVec);
				g_AirdropInfo[g_iAirdropInfoCount].relative_origin = vVec;
			}
			else if ( strcmp(key, "mins", false) == 0 )
			{
				StringToVector(value, vVec);
				g_AirdropInfo[g_iAirdropInfoCount].mins = vVec;
			}
			else if ( strcmp(key, "maxs", false) == 0 )
			{
				StringToVector(value, vVec);
				g_AirdropInfo[g_iAirdropInfoCount].maxs = vVec;
			}
			else if ( strcmp(key, "droptype", false) == 0 )
			{
				if ( strncmp(value, "B", 1, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].type = BREAKABLE;
				}
				else if ( strncmp(value, "P", 1, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].type = PRESS;
				}
				else if ( strncmp(value, "T", 1, false) == 0 )
				{
					g_AirdropInfo[g_iAirdropInfoCount].type = TOUCH;
				}
			}
			else if ( strcmp(key, "use_time", false) == 0 )
			{
				strcopy(g_AirdropInfo[g_iAirdropInfoCount].use_time, sizeof AirdropInfo::use_time, value);
			}
		}
	}
	else if ( g_iSectionType & SECTION_AIRPLANE_INFO )
	{
		if ( strcmp(key, "airdrop_count", false) == 0 )
		{
			g_AirplaneInfo[g_iAirplaneInfoCount].airdrop_count = StringToInt(value);
			g_AirplaneInfo[g_iAirplaneInfoCount].airdrop_count = _MIN(g_AirplaneInfo[g_iAirplaneInfoCount].airdrop_count, MAX_AIRDROPS);
		}
		else if ( strcmp(key, "droptime", false) == 0 )
		{
			g_AirplaneInfo[g_iAirplaneInfoCount].droptime = StringToFloat(value);
		}
		else if ( strcmp(key, "airdropdelay", false) == 0 )
		{
			g_AirplaneInfo[g_iAirplaneInfoCount].airdropdelay = StringToFloat(value);
		}
		else if ( strcmp(key, "density", false) == 0 )
		{
			g_AirplaneInfo[g_iAirplaneInfoCount].density = StringToFloat(value);
		}
		else if ( strcmp(key, "name", false) == 0 )
		{
			strcopy(g_AirplaneInfo[g_iAirplaneInfoCount].name, sizeof AirplaneInfo::name, value);
		}
		else if ( strcmp(key, "specification", false) == 0 )
		{
			strcopy(g_AirplaneInfo[g_iAirplaneInfoCount].specification, sizeof AirplaneInfo::specification, value);
		}
	}
	
	return SMCParse_Continue;
}

public SMCResult Config_EndSection( Handle parser )
{
	LOG("%i. Leave section ( Current: (%s) Last: (%s) )", g_iSectionLevel, FormatSection(g_iSectionType), FormatSection(g_iLastSectionType));
	
	if ( g_iSectionLevel == 2 )
	{
		if ( g_iSectionType & SECTION_AIRPLANE_INFO )
		{
			g_iAirplaneInfoCount++;
		}
		else if ( g_iSectionType & SECTION_AIRDROP_INFO )
		{
			g_iAirdropInfoCount++;
		}
	}
	
	g_iSectionLevel--;
	g_iSectionType &= g_hSectionsStack.Pop();
	return SMCParse_Continue;
}

void PrecacheAirdrops()
{
	LOG("Caching airdrops %i", g_iAirdropInfoCount);
	
	for (int i; i < g_iAirdropInfoCount; i++)
	{
		PrecacheModel(g_AirdropInfo[i].model, true);
		LOG("Cached model %s", g_AirdropInfo[i].model);
		
		if ( g_AirdropInfo[i].parachute[0] != '\0' )
		{
			PrecacheModel(g_AirdropInfo[i].parachute, true);
			LOG("Cached parachute %s", g_AirdropInfo[i].parachute);
		}
	}
}

stock void StringToVector( const char[] szVec, float out[3] )
{
	char axis[3][12];
	int num = ExplodeString(szVec, " ", axis, sizeof axis, sizeof axis[]);

	for (int i; i < num; i++)
	{
		out[i] = StringToFloat(axis[i]);
	}
}

stock char[] FormatSection( SECTION_TYPE section )
{
	char buffer[128], szSection[36];
	
	if ( section & SECTION_PRIVATE_GLOW_INFO )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_PRIVATE_GLOW_INFO ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	if ( section & SECTION_PRIVATE_FLARES_INFO )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_PRIVATE_FLARES_INFO ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	if ( section & SECTION_PRIVATE_WEAPONS_INFO )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_PRIVATE_WEAPONS_INFO ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	if ( section & SECTION_AIRDROP_INFO )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_AIRDROP_INFO ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	if ( section & SECTION_AIRPLANE_INFO )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_AIRPLANE_INFO ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	if ( section & SECTION_GLOBAL_WEAPONS )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_GLOBAL_WEAPONS ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	if ( section & SECTION_GLOBAL_SETTINGS )
	{
		FormatEx(szSection, sizeof szSection, " SECTION_GLOBAL_SETTINGS ");
		StrCat(buffer, sizeof buffer, szSection);
	}
	
	return buffer;
}