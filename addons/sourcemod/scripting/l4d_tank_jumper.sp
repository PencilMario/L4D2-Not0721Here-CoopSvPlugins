
/*=======================================================================================
	Change Log:

1.5 (18-Oct-2022)
	- Fixed game difficulty incorrectly detected.

1.4 (24-Nov-2020)
	- Prevents double-jump

1.3 (09-May-2020)
	- Double "no jump time" 15 => 30.
	- added "mode 2" during "no jump time" - fake hulk.
	- added "l4d_tankjump_chance" ConVar. Def.: 10 %.

1.2 (26-Mar-2020)
	- Jumer tank is disabled on 'Normal' and 'Easy' difficulties.

1.1 (12-Mar-2020)
	- Added "hulk" ability.

1.0 (01-Mar-2020)
	- First commit.
	
========================================================================================
	Commands:
	
	nothing
	
========================================================================================
	Credits:
	
	AK978 - for "Tank Jump" plugin I inspired from
	https://forums.alliedmods.net/showthread.php?p=2595688
	
	Lux - for mixing sound method.

========================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
//#include <sdkhooks>
 
#define CVAR_FLAGS	  FCVAR_NOTIFY

#define DEBUG 0

#define PLUGIN_VERSION "1.5"

public Plugin myinfo = 
{
	name = "[L4D] DragoTanks: Jumper Tank (Hulk)",
	author = "Alex Dragokas",
	description = "",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas"
};

int g_iVelocity;
int g_iJumperTank;
int g_iCvarJumperChance;
Handle g_iTimerJump[MAXPLAYERS+1];

bool g_bLeft4Dead2, g_bEnabled, g_bJumper[MAXPLAYERS+1], g_bDelayJump[MAXPLAYERS+1], g_bBlockSound;
float g_fJumpChange[MAXPLAYERS+1];
float g_fResulting[3];

ConVar g_hCvarJumperEnable;
ConVar g_hCvarJumperChance;
ConVar g_hCvarJumperNumber;
ConVar g_hCvarAllowEasy, g_hCvarAllowNormal, g_hCvarAllowHard, g_hCvarAllowExpert;
ConVar g_ConVarDifficulty;

bool g_bEasy = false;
bool g_bNormal = false;
bool g_bHard = false;
bool g_bExpert = false;

char g_sSoundDamage[] = "player/damage2.wav";
char g_sSoundAh[][] = 
{
	"player/death1.wav",
	"player/death2.wav",
	"player/death3.wav",
	"player/death4.wav",
	"player/death5.wav",
	"player/death6.wav"
};
char g_sSoundHulk[][] = 
{
	"player/tank/voice/breathe/tank_dormant_05.wav",
	"player/tank/voice/breathe/tank_dormant_06.wav",
	"player/tank/voice/breathe/tank_dormant_07.wav",
	"player/tank/voice/breathe/tank_dormant_08.wav",
	"player/tank/voice/breathe/tank_dormant_10.wav"
};
char g_sSoundHulk2[][] = 
{
	"player/tank/voice/growl/tank_spot_prey_05.wav",
	"player/tank/voice/growl/tank_spot_prey_06.wav",
	"player/tank/voice/growl/tank_spot_prey_07.wav",
	"player/tank/voice/growl/tank_spot_prey_08.wav",
	"player/tank/voice/growl/tank_spot_prey_09.wav"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test == Engine_Left4Dead2) {
		g_bLeft4Dead2 = true;	  
	}
	else if (test != Engine_Left4Dead) {
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	//g_bLateload = late;
	return APLRes_Success;
}

// ====================================================================================================
//					START / CONFIG 
// ====================================================================================================

public void OnPluginStart()
{
	LoadTranslations("l4d_tankjump.phrases");

	CreateConVar("l4d_tankjump_version", 		PLUGIN_VERSION, 	"Plugin version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	g_hCvarJumperEnable = CreateConVar("l4d_tankjump_enable", 		"1", 		"Enable Jumper tank (1 - Yes, 0 - No)", FCVAR_NOTIFY);
	g_hCvarJumperChance = CreateConVar("l4d_tankjump_chance", 		"100", 		"% chance the Jumper tank appear", FCVAR_NOTIFY);
	g_hCvarJumperNumber = CreateConVar("l4d_tankjump_number", 		"1", 		"When this number of tanks appeared simultaneously, convert last tank to jumper", FCVAR_NOTIFY);
	g_hCvarAllowEasy 	= CreateConVar("l4d_tankjump_allow_easy", 	"1", 		"Allow jumper tank on game difficulty: Easy? (0 - No, 1 - Yes)", FCVAR_NOTIFY);
	g_hCvarAllowNormal 	= CreateConVar("l4d_tankjump_allow_normal", "1", 		"Allow jumper tank on game difficulty: Normal? (0 - No, 1 - Yes)", FCVAR_NOTIFY);
	g_hCvarAllowHard 	= CreateConVar("l4d_tankjump_allow_hard", 	"1", 		"Allow jumper tank on game difficulty: Hard? (0 - No, 1 - Yes)", FCVAR_NOTIFY);
	g_hCvarAllowExpert 	= CreateConVar("l4d_tankjump_allow_expert", "1", 		"Allow jumper tank on game difficulty: Expert? (0 - No, 1 - Yes)", FCVAR_NOTIFY);
	
	AutoExecConfig(true, "l4d_tank_jumper");
	
	if((g_iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]")) == -1)
	{
		SetFailState("Could not find offset for CBasePlayer::m_vecVelocity[0]");
	}
	
	g_ConVarDifficulty = FindConVar("z_difficulty");
	
	#if DEBUG
	RegConsoleCmd("sm_hulk", CmdHulk, "Test julk jump");
	#endif

	GetCvars();
	GetDifficulty();
	
	g_hCvarJumperEnable.AddChangeHook(ConVarChanged);
	g_hCvarJumperChance.AddChangeHook(ConVarChanged);
	g_ConVarDifficulty.AddChangeHook(ConVarDiffChanged);
	
	AddNormalSoundHook(OnNormalSoundPlay);
}

public Action CmdHulk(int client, int args)
{
	int tank = GetAnyTank();
	if (tank != -1)
	{
		HulkJump(tank);
	}
	return Plugin_Handled;
}

public void OnMapStart()
{
	PrecacheEffect("ParticleEffect");
	PrecacheGeneric("particles/environment_fx.pcf", true);
	
	//PrecacheParticleEffect("awning_collapse");
	//PrecacheParticleEffect("pillardust");
	
	//PrecacheParticleEffect("railroad_light_explode_b");
	PrecacheParticleEffect("aircraft_destroy_fastFireTrail");
	
	//PrecacheParticleEffect("ibeam_break");
	PrecacheParticleEffect("sheetrock");
	
	for (int i = 0; i < sizeof g_sSoundAh; i++)
	{
		PrecacheSound(g_sSoundAh[i], true);
	}
	for (int i = 0; i < sizeof g_sSoundHulk; i++)
	{
		PrecacheSound(g_sSoundHulk[i], true);
	}
	for (int i = 0; i < sizeof g_sSoundHulk2; i++)
	{
		PrecacheSound(g_sSoundHulk2[i], true);
	}
	PrecacheSound(g_sSoundDamage, true);
}

public void ConVarDiffChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetDifficulty();
}

void GetDifficulty()
{
	g_bEasy = false;
	g_bNormal = false;
	g_bHard = false;
	g_bExpert = false;

	static char sDif[32];
	g_ConVarDifficulty.GetString(sDif, sizeof(sDif));
	if (StrEqual(sDif, "Easy", false)) {
		g_bEasy = true;
	}
	else if (StrEqual(sDif, "Normal", false)) {
		g_bNormal = true;
	}
	else if (StrEqual(sDif, "Hard", false)) {
		g_bHard = true;
	}
	else if (StrEqual(sDif, "Impossible", false)) {
		g_bExpert = true;
	}
}
 
public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}
 
void GetCvars()
{
	g_bEnabled = g_hCvarJumperEnable.BoolValue;
	g_iCvarJumperChance = g_hCvarJumperChance.IntValue;
	InitHook();
}
 
void InitHook()
{
	static bool bHooked;

	if (g_bEnabled) {
		if (!bHooked) {
			//HookEvent("round_start",		eStart,   	EventHookMode_PostNoCopy);
			HookEvent("tank_spawn",			eTankSpawn,	EventHookMode_Post);
			//HookEvent("tank_killed",		eDie,		EventHookMode_Pre);
			HookEvent("round_end",			eEnd,	 	EventHookMode_PostNoCopy);
			HookEvent("map_transition",		eEnd,	 	EventHookMode_PostNoCopy);
			HookEvent("player_hurt",		eHurt,	 	EventHookMode_Post);
			bHooked = true;
		}
	} else {
		if (bHooked) {
			//UnhookEvent("round_start",		eStart,   	EventHookMode_PostNoCopy);
			UnhookEvent("tank_spawn",		eTankSpawn,	EventHookMode_Post);
			//UnhookEvent("tank_killed",		eDie,		EventHookMode_Pre);
			UnhookEvent("round_end",		eEnd,	 	EventHookMode_PostNoCopy);
			UnhookEvent("map_transition",	eEnd,	 	EventHookMode_PostNoCopy);
			UnhookEvent("player_hurt",		eHurt,	 	EventHookMode_Post);
			bHooked = false;
		}
	}
}

bool IsAllowed()
{
	if( g_bEasy && g_hCvarAllowEasy.IntValue )
	{
		return true;
	}
	if( g_bNormal && g_hCvarAllowNormal.IntValue )
	{
		return true;
	}
	if( g_bHard && g_hCvarAllowHard.IntValue )
	{
		return true;
	}
	if( g_bExpert && g_hCvarAllowExpert.IntValue )
	{
		return true;
	}
	return false;
}

// ====================================================================================================
//					SOUND
// ====================================================================================================

public Action OnNormalSoundPlay(int clients[MAXPLAYERS], int &numClients,
		char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level,
		int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if ( g_bBlockSound && entity == g_iJumperTank )
	{
		if ( -1 != StrContains(sample, "tank") )
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================

public void OnMapEnd()
{
	Clear();
}

public void eEnd(Event event, const char[] name, bool dontbroadcast)
{
	Clear();
}

void Clear()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		KillTimerSafe(i);
		g_bDelayJump[i] = false;
	}
}

void KillTimerSafe(int client)
{
	if (g_iTimerJump[client] != INVALID_HANDLE)
	{
		delete g_iTimerJump[client];
	}
}

public void eTankSpawn(Event event, const char[] name, bool dontbroadcast)
{
	const float fStartDelay = 1.0;
	
	int UserId = event.GetInt("userid");
	int tank = GetClientOfUserId(UserId);

	if ( g_bEnabled && GetTankCount() == g_hCvarJumperNumber.IntValue && IsAllowed() && GetRandomInt( 1, 100 ) <= g_iCvarJumperChance )
	{
		SetEntityGravity(tank, 2.0);
		
		DataPack dp = new DataPack();
		dp.WriteCell(UserId);
		dp.WriteFloat(fStartDelay);
		dp.WriteCell(tank);
		g_iTimerJump[tank] = CreateTimer(fStartDelay, Timer_Jump, dp, TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
		g_fJumpChange[tank] = GetEngineTime();
		g_bJumper[tank] = true;
		g_iJumperTank = tank;
	}
	else {
		g_bJumper[tank] = false;
		if ( g_iJumperTank == tank )
		{
			g_iJumperTank = 0;
		}
	}
}

Action Timer_Jump(Handle timer, DataPack dp)
{
	dp.Reset();
	int tank = GetClientOfUserId(dp.ReadCell());
	float delay = dp.ReadFloat();

	if ( g_bDelayJump[tank] ) // delay jump until 'Hulk jump' finished
	{
		return Plugin_Continue;
	}
	
	if ( tank && IsClientInGame(tank) && IsPlayerAlive(tank) )
	{
		if ( delay != 0.0 )
		{
			if( IsOnGround(tank) ) // v.1.4.
			{
				SetEntityGravity(tank, 2.0);
				AddVelocity(tank, delay * GetRandomFloat(450.0, 580.0));
			}
		}
	}
	else {
		g_iTimerJump[dp.ReadCell()] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	if ( delay == 0.0)
	{
		int nMode = GetRandomInt(1, 3); // 33 %
		
		switch( nMode )
		{
			case 1: {
				if( IsOnGround(tank) )
				{
					int iAnim = GetEntProp(tank, Prop_Send, "m_nSequence");
					
					switch (iAnim) {
						case 1, 9, 12, 49: {
							HulkJump(tank);
							return Plugin_Continue;
						}
					}
				}
			}
			case 2: {
				if( GetRandomInt(1, 2) == 1 ) // 15 %
				{
					// fake hulk jump
					if( IsOnGround(tank) ) // v.1.4.
					{
						SetEntityGravity(tank, 1.0);
						AddVelocity(tank, 1000.0);
					}
				}
			}
		}
	}
	
	if ( GetEngineTime() - g_fJumpChange[tank] > (delay == 0.0 ? 30.0 : 5.0) )
	{
		delay += 0.5;
		
		if ( delay > 2.0 )
		{
			delay = 0.0;
		}
		
		DataPack dp2 = new DataPack();
		dp2.WriteCell(GetClientUserId(tank));
		dp2.WriteFloat(delay);
		dp2.WriteCell(tank);
		
		g_iTimerJump[tank] = CreateTimer(delay == 0.0 ? 0.5 : delay, Timer_Jump, dp2, TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
		g_fJumpChange[tank] = GetEngineTime();
		
		SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", delay == 0.5 ? 1.5 : 1.0);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void eHurt(Event event, const char[] name, bool dontbroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int type = event.GetInt("type");
	int victim = GetClientOfUserId(event.GetInt("userid"));

	if ( type == 128 && 0 < victim <= MaxClients && IsTank(attacker) )
	{
		static char weapon[32];
		event.GetString("weapon", weapon, sizeof weapon);

		if( strcmp(weapon, "tank_claw") == 0 )
		{
			if ( g_bJumper[attacker] )
			{
				if ( IsClientInGame(victim) && GetClientTeam(victim) == 2 && !IsIncapped(victim) )
				{
					PushCommonInfected(attacker, victim, 5.0, 520.0);
				}
			}
		}
	}
}

void HulkJump(int tank)
{
	//sound
	
	float height = GetDistanceToRoof(tank);
	
	if ( height < 600.0)
	{
		return;
	}
	
	g_bBlockSound = true;
	
	SetEntityGravity(tank, 1.0);
	AddVelocity(tank, 1000.0);
	
	g_bDelayJump[tank] = true;
	
	//SpawnEffect(tank, "awning_collapse");
	//SpawnEffect(tank, "railroad_light_explode_b");
	SpawnEffect(tank, "aircraft_destroy_fastFireTrail");
	
	float vPos[3];
	GetEntPropVector(tank, Prop_Send, "m_vecOrigin", vPos);
	
	MixSound(g_sSoundHulk[GetRandomInt(0, (sizeof g_sSoundHulk)-1)], vPos);
	//EmitAmbientSound(g_sSoundHulk[GetRandomInt(0, (sizeof g_sSoundHulk)-1)], vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 60, 0.0);
	
	CreateTimer(2.5, Timer_HulkEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.3, Timer_SoundHulk, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_SoundHulk(Handle timer, int UserId)
{
	int tank = GetClientOfUserId(UserId);
	
	if ( IsTank(tank) )
	{
		float vPos[3];
		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", vPos);
		
		MixSound(g_sSoundHulk[GetRandomInt(0, (sizeof g_sSoundHulk)-1)], vPos);
	}
	return Plugin_Continue;
}

Action Timer_HulkEffect(Handle timer, int UserId)
{
	int tank = GetClientOfUserId(UserId);
	
	if ( IsTank(tank) )
	{
		HulkEffect(tank);
		g_bDelayJump[tank] = false;
	}
	return Plugin_Continue;
}

void HulkEffect(int tank)
{
	const float fMaxDist = 300.0; // 150.0;

	float vTank[3], vPlayer[3], vPlane[3], dist;
	
	//SpawnEffect(tank, "pillardust");
	//SpawnEffect(tank, "ibeam_break"); // no materials
	SpawnEffect(tank, "sheetrock");
	
	GetClientAbsOrigin(tank, vTank);
	
	HurtRadius(vTank, fMaxDist, 10.0, tank);
	
	float vAng[3];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( i != tank && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
		{
			GetClientAbsOrigin(i, vPlayer);
			vPlane = vPlayer;
			vPlane[2] = vTank[2];
			
			dist = GetVectorDistance(vTank, vPlane);

			if ( dist < fMaxDist )
			{
				PushCommonInfected(tank, i, 750.0, 300.0, false);
				ScreenShake(i, 25.0);
				
				GetEntPropVector(i, Prop_Send, "m_angRotation", vAng);
				vAng[0] = -60.0;
				TeleportEntity(i, NULL_VECTOR, vAng, NULL_VECTOR);
				
				EmitSoundCustom(i, g_sSoundDamage);
				EmitSoundCustom(i, g_sSoundAh[GetRandomInt(0, (sizeof g_sSoundAh)-1)]);
			}
		}
	}
	
	// if player is under the tank ?
	
	int client = GetFloorEntity (tank);
	
	if ( 1 <= client <= MaxClients )
	{
		if ( !IsIncapped(client) )
		{
			IncapPlayer(client);
			CPrintToChatAll("\x01%t \x03 %N", "knocked_down", client);
		}
	}
	
	g_bBlockSound = false;
}

// ====================================================================================================
//					STOCKS
// ====================================================================================================

stock void CPrintToChatAll(const char[] format, any ...)
{
	static char buffer[192];
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame(i) && !IsFakeClient(i) )
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 2);
			PrintToChat(i, buffer);
		}
	}
}

stock void MixSound(char[] Snd, float vPos[3])
{
	EmitAmbientSound(Snd, vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.8, 120, 0.0);
	EmitAmbientSound(Snd, vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.7, 110, 0.0);
	EmitAmbientSound(Snd, vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.6, 90, 0.0);
	EmitAmbientSound(Snd, vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.5, 80, 0.0);
	EmitAmbientSound(Snd, vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.4, 70, 0.0);
	EmitAmbientSound(Snd, vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 0.3, 60, 0.0);
	EmitAmbientSound(g_sSoundHulk2[GetRandomInt(0, (sizeof g_sSoundHulk2)-1)], vPos, SOUND_FROM_WORLD, 150, SND_NOFLAGS, 1.0, 60, 0.0);
}

bool IsOnGround(int client)
{
	return (GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == 0);
}

public void ScreenShake(int client, float intensity)
{
	Handle msg;
	msg = StartMessageOne("Shake", client);
	
	BfWriteByte(msg, 0);
 	BfWriteFloat(msg, intensity);
 	BfWriteFloat(msg, 10.0);
 	BfWriteFloat(msg, 3.0);
	EndMessage();
}

void EmitSoundCustom(int client, char[] sound, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL, 
	int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, float origin[3] = NULL_VECTOR, 
	float dir[3] = NULL_VECTOR, bool updatePos = true, float soundtime = 0.0)
{
	int clients[1];
	clients[0] = client;
	EmitSound(clients, 1, sound, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

void HurtRadius(float vOrigin[3], float fRadius, float hp, int activator)
{
	int entity = CreateEntityByName("point_hurt");
	if ( entity != -1 )
	{
		char sTemp[8];
		FloatToString(fRadius, sTemp, sizeof(sTemp));
		DispatchKeyValue(entity, "DamageRadius", sTemp);
		FloatToString(hp, sTemp, sizeof(sTemp));
		DispatchKeyValue(entity, "Damage", sTemp);
		DispatchKeyValue(entity, "DamageType", "64"); // BLAST
		TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Hurt", activator);
		RemoveEdict(entity);
	}
}

void IncapPlayer(int client)
{
	SetEntityHealth(client, 1);
	SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
	SetEntityHealth(client, FindConVar("survivor_incap_health").IntValue);
}

// smooth teleport in eye view direction (with collision)
//
stock void PushCommonInfected(int client, int target, float distance, float jump_power = 251.0, bool bFrame = true)
{
	static float angle[3], dir[3], current[3];
	
	GetClientEyeAngles(client, angle);
	GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(dir, distance);
	
	GetEntDataVector(target, g_iVelocity, current);
	//resulting[0] = current[0] + dir[0];
	//resulting[1] = current[1] + dir[1];
	g_fResulting[0] = dir[0];
	g_fResulting[1] = dir[1];
	g_fResulting[2] = jump_power; // min. 251
	
	if ( bFrame )
	{
		RequestFrame(OnFramePush, GetClientUserId(target));
	}
	else {
		TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, g_fResulting);
	}
}

public void OnFramePush(int UserId)
{
	int target = GetClientOfUserId(UserId);
	if (target)
	{
		TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, g_fResulting);
	}
}

stock bool IsIncapped(int client)
{
	if( GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) > 0 )
		return true;
	return false;
}

public void AddVelocity(int tank, float fSpeed)
{
	float vecVelocity[3];
	GetEntDataVector(tank, g_iVelocity, vecVelocity);
	vecVelocity[2] = fSpeed;
	TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

int GetTankCount()
{
	int iTanks = 0;
	for (int i = 1; i <= MaxClients; i++)
		if (IsTank(i) && IsPlayerAlive(i) && GetEntProp(i, Prop_Send, "m_isIncapacitated", 1) == 0)
			iTanks++;
			
	return iTanks;
}
 
stock bool IsTank(int &client)
{
	if( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 )
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( class == (g_bLeft4Dead2 ? 8 : 5 ))
			return true;
	}
	return false;
}

stock float GetDistanceToRoof(int client, float maxheigth = 3000.0)
{ 
	float vMin[3], vMax[3], vOrigin[3], vEnd[3], vStart[3], fDistance = 0.0;
	GetClientAbsOrigin(client, vStart);
	vStart[2] += 10.0;
	vEnd[0] = vStart[0];
	vEnd[1] = vStart[1];
	vEnd[2] = vStart[2] + maxheigth;
	GetClientMins(client, vMin);
	GetClientMaxs(client, vMax);
	GetClientAbsOrigin(client, vOrigin);
	Handle hTrace = TR_TraceHullFilterEx(vOrigin, vEnd, vMin, vMax, MASK_PLAYERSOLID, TraceRayNoPlayers, client);
	if (hTrace != INVALID_HANDLE) {
		if(TR_DidHit(hTrace))
		{
			float fEndPos[3];
			TR_GetEndPosition(fEndPos, hTrace);
			vStart[2] -= 10.0;
			fDistance = GetVectorDistance(vStart, fEndPos);
		}
		else {
			fDistance = maxheigth;
		}
		CloseHandle(hTrace);
	}
	return fDistance; 
}

stock int GetFloorEntity(int client, float maxheigth = 3000.0)
{
	float vMin[3], vMax[3], vOrigin[3], vEnd[3], vStart[3];
	
	if(GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == 0)
		return -1;
	
	GetClientAbsOrigin(client, vStart);
	
	vStart[2] += 10.0;
	vEnd[0] = vStart[0];
	vEnd[1] = vStart[1];
	vEnd[2] = vStart[2] - maxheigth;
	GetClientMins(client, vMin);
	GetClientMaxs(client, vMax);
	vMin[0] -= 5.0;
	vMin[1] -= 5.0;
	vMax[0] += 5.0;
	vMax[1] += 5.0;
	GetClientAbsOrigin(client, vOrigin);
	int entity = -1;
	Handle hTrace = TR_TraceHullFilterEx(vOrigin, vEnd, vMin, vMax, MASK_PLAYERSOLID, TraceRayAnything, client);
	if (hTrace != INVALID_HANDLE) {
		if(TR_DidHit(hTrace))
		{
			entity = TR_GetEntityIndex(hTrace);
		}
		CloseHandle(hTrace);
	}
	return entity; 
}

public bool TraceRayAnything(int entity, int mask, any data)
{
    if(entity == data)
    {
        return false;
    }
    return true;
}

public bool TraceRayNoPlayers(int entity, int mask, any data)
{
    if(entity == data || (entity >= 1 && entity <= MaxClients))
    {
        return false;
    }
    return true;
}

stock void PrecacheEffect(const char[] sEffectName) // thanks to Dr. Api
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("EffectDispatch");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, sEffectName);
    LockStringTables(save);
}

stock void PrecacheParticleEffect(const char[] sEffectName) // thanks to Dr. Api
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, sEffectName);
    LockStringTables(save);
}

int GetAnyTank()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsTank(i) && IsPlayerAlive(i) )
		{
			return i;
		}
	}
	return -1;
}

void SpawnEffect(int client, char[] sParticleName)
{
	float pos[3];
	
	GetClientEyePosition(client, pos);
	//	GetClientAbsOrigin(client, pos);
	
	int iEntity = CreateEntityByName("info_particle_system", -1);
	if (iEntity != -1)
	{	
		//float vAng[3];
		DispatchKeyValue(iEntity, "effect_name", sParticleName);
		DispatchKeyValueVector(iEntity, "origin", pos);
		//DispatchKeyValueVector(iEntity, "angles", vAng);
		DispatchSpawn(iEntity);
		SetVariantString("!activator");
		AcceptEntityInput(iEntity, "SetParent", client);
		SetVariantString("!activator");
		AcceptEntityInput(iEntity, "SetParentAttachment", client);
		
		ActivateEntity(iEntity);
		AcceptEntityInput(iEntity, "Start");
		SetVariantString("OnUser1 !self:kill::5.0:1");
		AcceptEntityInput(iEntity, "AddOutput");
		AcceptEntityInput(iEntity, "FireUser1");
	}
}
