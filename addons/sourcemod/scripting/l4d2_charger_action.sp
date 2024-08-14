/*
*	Charger Actions
*	Copyright (C) 2023 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



#define PLUGIN_VERSION 		"1.14"

/*=======================================================================================
	Plugin Info:

*	Name	:	[L4D2] Charger Actions
*	Descrp	:	Changes how the Charger can be used.
*	Author	:	SilverShot
*	Link	:	https://forums.alliedmods.net/showthread.php?t=309321
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.14 (24-Sep-2023)
	- Fixed not resetting variables causing some rare bugs. Thanks to "Voevoda" for reporting.

1.13 (25-May-2023)
	- Changed cvar "l4d2_charger_incapped" to control if the Charger can pickup incapped players who are pinned while charging. Requested by "fortheloveof98".
	- Fixed incapped players being revived when a Charger carrying them dies. Thanks to "Mosey" for reporting.

1.12 (10-Feb-2023)
	- Added cvar "l4d2_charger_incapped" to automatically pick up incapacitated Survivors when Charging over them. Requested by "Voevoda"
	- Picking up an incapacitated Survivor now shows the carry animation on the Survivor.
	- Fixed the 3rd person view positioning of a carried survivor. This will somewhat obscure the Chargers 1st person view unfortunately.
	- Fixed punching whilst Charging allowing to steer for a split second. Thanks to "alasfourom" for reporting.

1.11 (05-Jul-2022)
	- Fixed invalid entity error caused by some 3rd party plugins. Thanks to "Voevoda" for reporting.

1.10 (15-Jun-2022)
	- Fixed small mistake in coding when detecting incapacitated players.

1.9 (20-Mar-2022)
	- Minor change to block pressing attack key when repeat charge is off.
	- Updated GameData signatures to avoid breaking when detoured by the "Left4DHooks" plugin version 1.90 or newer.

1.8 (14-Nov-2021)
	- Changes to fix warnings when compiling on SourceMod 1.11.
	- Updated GameData signatures to avoid breaking when detoured by the "Left4DHooks" plugin.

1.7 (23-May-2020)
	- Added check and fix for Survivors stuck in the falling animation. Thanks to "hoanganh81097" for reporting.

1.6 (15-May-2020)
	- Re-added blocking listen servers.
	- Replaced "point_hurt" entity with "SDKHooks_TakeDamage" function.

1.5 (10-May-2020)
	- Added better error log message when gamedata file is missing.
	- No longer blocking listen servers.
	- Various changes to tidy up code.

1.4 (20-Jan-2020)
	- Added cvar "l4d2_charger_jumps" to limit number of jumps per charge. Requested by "Ethan Max".
	- Optimized cvars for faster CPU processing.

1.3 (17-Jan-2020)
	- Fixed "l4d2_charger_punch" not working unless "l4d2_charger_pickup" was enabled. Thanks to "Ethan Max" for reporting.

1.2 (01-Nov-2019)
	- Big thanks to "paul92" for lots of help testing.
	- Added cvar "l4d2_charger_damage" to deal damage when hitting or grabbing a survivor.
	- Changed cvar "l4d2_charger_finish" by adding "4" to allow carrying after charging.
	- Fixed cvar "l4d2_charger_repeat" not working. Pummel is moved to Scope/Zoom button (MMB/M3) when on.
	- Fixed punching while charging not working without the "Charger Steering" plugin.
	- Players will be able to steer very slightly for 1 frame when punching while charging.
	- This is the only method I know to enable punching while charging. Other attempts failed.

1.1 (10-Oct-2019)
	- Added cvar "l4d2_charger_bots" to control if bots can grab or push survivors when Charging.
	- Fixed not being able to pick up Survivors during Charging.

1.0.2 (10-Sep-2019)
	- Removed PrintToChatAll "Attack time" debug spew...

1.0.1 (01-Jun-2019)
	- Minor changes to code, has no affect and not required.

1.0 (21-Jul-2018)
	- Initial release.

======================================================================================*/

/*
// STUFF FOR TESTING:
sm_ted_selectself; sm_ted_watch; sm_ted_stopwatch
sm_cvar sm_tentdev_watchinterval 0.1; sm_ted_ignore m_flSimulationTime; sm_ted_ignore m_flAnimTime; sm_ted_ignore m_nTickBase; sm_ted_ignore m_flCycle; ; sm_ted_ignore m_cellX; sm_ted_ignore m_vecOrigin; sm_ted_ignore m_angRotation; sm_ted_ignore m_flPoseParameter; sm_ted_ignore m_nSequence; sm_ted_ignore m_nNewSequenceParity; sm_ted_ignore m_nResetEventsParity; sm_ted_ignore m_vecVelocity[0]; sm_ted_ignore m_vecVelocity[1]; sm_ted_ignore m_angEyeAngles[0]; sm_ted_ignore m_angEyeAngles[1]; sm_ted_ignore m_fServerAnimStartTime; sm_ted_ignore m_cellY;

sm_v; jointeam 3; sm_cvar z_charge_interval 1; z_charge_duration 5; z_spawn charger; l4d2_charger_charge 0; l4d2_charger_pickup; l4d2_charger_pummel 2; l4d2_charger_repeat 1; l4d2_charger_shove 1; l4d2_charger_finish 4

sm_propi m_pummelVictim; sm_propi m_carryVictim; sm_propi m_pummelAttacker; sm_propi m_carryAttacker
sm_prop m_pummelVictim; sm_prop m_carryVictim; sm_prop m_pummelAttacker; sm_prop m_carryAttacker
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#define CVAR_FLAGS			FCVAR_NOTIFY
#define GAMEDATA			"l4d2_charger_action"
#define DEBUG				0


static const char g_Sounds[3][] =
{
	"player/charger/hit/charger_smash_01.wav",
	"player/charger/hit/charger_smash_02.wav",
	"player/charger/hit/charger_smash_03.wav"
};

ConVar g_hCvarAllow, g_hCvarBots, g_hCvarCharge, g_hCvarDamage, g_hCvarFinish, g_hCvarIncap, g_hCvarJump, g_hCvarJumps, g_hCvarPickup, g_hCvarPummel, g_hCvarPunch, g_hCvarRepeat, g_hCvarShove, g_hCvarInterval;
int g_iCvarBots, g_iCvarCharge, g_iCvarDamage, g_iCvarFinish, g_iCvarIncap, g_iCvarJump, g_iCvarJumps, g_iCvarPickup, g_iCvarPummel, g_iCvarPunch, g_iCvarRepeat, g_iCvarShove, g_iCvarInterval;
bool g_bCvarAllow;

Handle g_hSDK_Throw, g_hSDK_QueuePummelVictim, g_hSDK_OnPummelEnded, g_hSDK_OnStartCarryingVictim;
Handle g_hDetourCollision;
Handle g_hChargerIncap[MAXPLAYERS+1];
bool g_bCharging[MAXPLAYERS+1];
bool g_bIncapped[MAXPLAYERS+1];
bool g_bPunched[MAXPLAYERS+1];
float g_fCharge[MAXPLAYERS+1];
float g_fThrown[MAXPLAYERS+1];
float g_fPunch[MAXPLAYERS+1];
int g_iJumped[MAXPLAYERS+1];



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D2] Charger Actions",
	author = "SilverShot",
	description = "Changes how the Charger can be used.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=309321"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if( !IsDedicatedServer() )
	{
		strcopy(error, err_max, "Get a dedicated server. This plugin does not work on Listen servers.");
		return APLRes_SilentFailure;
	}

	if( GetEngineVersion() != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_Failure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	// ====================================================================================================
	// Cvars
	// ====================================================================================================
	g_hCvarAllow =	CreateConVar(		"l4d2_charger_allow",		"1",	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS);
	g_hCvarBots =	CreateConVar(		"l4d2_charger_bots",		"1",	"Bots can: 0=Grab survivor on contact (game default). 1=Fling survivors on contact instead of grab. 2=Random choice.", CVAR_FLAGS);
	g_hCvarCharge =	CreateConVar(		"l4d2_charger_charge",		"1",	"Humans can: 0=Grab survivor on contact (game default). 1=Fling survivors on contact instead of grab.", CVAR_FLAGS);
	g_hCvarDamage =	CreateConVar(		"l4d2_charger_damage",		"10",	"Amount of damage to deal on collision when hitting or grabbing a survivor.", CVAR_FLAGS);
	g_hCvarFinish =	CreateConVar(		"l4d2_charger_finish",		"3",	"After carrying and charging: 0=Pummel (game default). 1=Drop survivor. 2=Drop when a carried survivor is incapacitated. 3=Both 1 and 2. 4=Continue to carry.", CVAR_FLAGS);
	g_hCvarIncap =	CreateConVar(		"l4d2_charger_incapped",	"1",	"Allow chargers to automatically pick up incapacitated players whilst charging over them. 0=Off. 1=On. 2=Only when not pinned by other Special Infected.", CVAR_FLAGS);
	g_hCvarJump =	CreateConVar(		"l4d2_charger_jump",		"2",	"Allow chargers to jump while charging. 0=Off. 1=When alone. 2=Also when carrying a survivor.", CVAR_FLAGS);
	g_hCvarJumps =	CreateConVar(		"l4d2_charger_jumps",		"0",	"0=Unlimited. Maximum number of jumps per charge.", CVAR_FLAGS);
	g_hCvarPickup =	CreateConVar(		"l4d2_charger_pickup",		"31",	"Allow chargers to carry and drop survivors with the melee button (RMB). 0=Off. 1=Grab Incapped. 2=Grab Standing. 4=Drop Incapped. 8=Drop Standing. 16=Grab while charging (requires l4d2_charger_punch cvar). Add numbers together.", CVAR_FLAGS);
	g_hCvarPummel =	CreateConVar(		"l4d2_charger_pummel",		"2",	"Allow pummel to be started and stopped while carrying a survivor (LMB) or Scope/Zoom (MMB/M3) when l4d2_charger_repeat is on. 0=Off. 1=Incapped only. 2=Any survivor.", CVAR_FLAGS);
	g_hCvarPunch =	CreateConVar(		"l4d2_charger_punch",		"1",	"0=Off. 1=Allow punching while charging.", CVAR_FLAGS);
	g_hCvarRepeat =	CreateConVar(		"l4d2_charger_repeat",		"0",	"0=Off. 1=Allow charging while carrying either after charging or after grabbing a survivor and after the charge meter has refilled.", CVAR_FLAGS);
	g_hCvarShove =	CreateConVar(		"l4d2_charger_shove",		"7",	"Survivors can shove chargers to release pummelled victims. 0=Off. 1=Release only. 2=Stumble survivor. 4=Stumble charger. 7=All. Add numbers together.", CVAR_FLAGS);
	CreateConVar(						"l4d2_charger_version",		PLUGIN_VERSION,	"Charger Actions plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,				"l4d2_charger_action");

	g_hCvarInterval = FindConVar("z_charge_interval");

	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarBots.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarCharge.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDamage.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarFinish.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarIncap.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarJump.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarJumps.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarPickup.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarPummel.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarPunch.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarRepeat.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarShove.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarInterval.AddChangeHook(ConVarChanged_Cvars);

	// RegAdminCmd("sm_char",sm_char, ADMFLAG_ROOT);
	// RegAdminCmd("sm_cha",sm_cha, ADMFLAG_ROOT);
}

/*
Action sm_char(int client, int args)
{
	SDKCall(g_hSDK_Throw, client, GetClientAimTarget(client), 10.0, false);
	return Plugin_Handled;
}

Action sm_cha(int client, int args)
{
	float time = 5.0;
	int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
	if( GetEntPropFloat(ability, Prop_Send, "m_timestamp") < GetGameTime() + time + 1 )
		SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + time + 1);
	int weapon = GetPlayerWeaponSlot(client, 0);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + time);

	return Plugin_Handled;
}
// */

public void OnAllPluginsLoaded()
{
	// ====================================================================================================
	// GAMEDATA
	// ====================================================================================================
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA);
	if( FileExists(sPath) == false ) SetFailState("\n==========\nMissing required file: \"%s\".\nRead installation instructions again.\n==========", sPath);

	Handle hGameData = LoadGameConfigFile(GAMEDATA);
	if( hGameData == null ) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);



	// ====================================================================================================
	// Detours
	// ====================================================================================================
	g_hDetourCollision = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Int, ThisPointer_Ignore);
	if( !g_hDetourCollision )
		SetFailState("Failed to setup detour handle.");

	if( !DHookSetFromConf(g_hDetourCollision, hGameData, SDKConf_Signature, "CCharge::HandleCustomCollision") )
		SetFailState("Failed to find signature: CCharge::HandleCustomCollision");

	DHookAddParam(g_hDetourCollision, HookParamType_CBaseEntity);
	DHookAddParam(g_hDetourCollision, HookParamType_VectorPtr);
	DHookAddParam(g_hDetourCollision, HookParamType_VectorPtr);
	DHookAddParam(g_hDetourCollision, HookParamType_ObjectPtr);
	DHookAddParam(g_hDetourCollision, HookParamType_ObjectPtr);



	// ====================================================================================================
	// SDK Calls
	// ====================================================================================================
	// ThrowImpactedSurvivor
	StartPrepSDKCall(SDKCall_Static);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "ThrowImpactedSurvivor") == false )
		SetFailState("Failed to find signature: ThrowImpactedSurvivor");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	g_hSDK_Throw = EndPrepSDKCall();
	if( g_hSDK_Throw == null )
		SetFailState("Failed to create SDKCall: ThrowImpactedSurvivor");

	// QueuePummelVictim
	StartPrepSDKCall(SDKCall_Player);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::QueuePummelVictim") == false )
		SetFailState("Failed to find signature: CTerrorPlayer::QueuePummelVictim");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_ByValue);
	g_hSDK_QueuePummelVictim = EndPrepSDKCall();
	if( g_hSDK_QueuePummelVictim == null )
		SetFailState("Failed to create SDKCall: CTerrorPlayer::QueuePummelVictim");

	// OnPummelEnded
	StartPrepSDKCall(SDKCall_Player);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::OnPummelEnded") == false )
		SetFailState("Failed to find signature: CTerrorPlayer::OnPummelEnded");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDK_OnPummelEnded = EndPrepSDKCall();
	if( g_hSDK_OnPummelEnded == null )
		SetFailState("Failed to create SDKCall: CTerrorPlayer::OnPummelEnded");

	// OnStartCarryingVictim
	StartPrepSDKCall(SDKCall_Player);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::OnStartCarryingVictim") == false )
		SetFailState("Failed to find signature: CTerrorPlayer::OnStartCarryingVictim");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDK_OnStartCarryingVictim = EndPrepSDKCall();
	if( g_hSDK_OnStartCarryingVictim == null )
		SetFailState("Failed to create SDKCall: CTerrorPlayer::OnStartCarryingVictim");

	delete hGameData;
}

public void OnMapStart()
{
	for( int i = 0; i < sizeof(g_Sounds); i++ )
	{
		PrecacheSound(g_Sounds[i]);
	}
}

public void OnMapEnd()
{
	ResetPlugin();
}

public void OnClientDisconnect(int client)
{
	delete g_hChargerIncap[client];
}



// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarFinish	= g_hCvarFinish.IntValue;
	g_iCvarIncap	= g_hCvarIncap.IntValue;
	g_iCvarBots		= g_hCvarBots.IntValue;
	g_iCvarCharge	= g_hCvarCharge.IntValue;
	g_iCvarDamage	= g_hCvarDamage.IntValue;
	g_iCvarJump		= g_hCvarJump.IntValue;
	g_iCvarJumps	= g_hCvarJumps.IntValue;
	g_iCvarPickup	= g_hCvarPickup.IntValue;
	g_iCvarPummel	= g_hCvarPummel.IntValue;
	g_iCvarPunch	= g_hCvarPunch.IntValue;
	g_iCvarRepeat	= g_hCvarRepeat.IntValue;
	g_iCvarShove	= g_hCvarShove.IntValue;
	g_iCvarInterval	= g_hCvarInterval.IntValue;

	ToggleDetour();
}

void IsAllowed()
{
	bool bAllowCvar = g_hCvarAllow.BoolValue;
	GetCvars();

	if( g_bCvarAllow == false && bAllowCvar == true )
	{
		AddCommandListener(OnJoinTeam, "jointeam");

		HookEvents();
		g_bCvarAllow = true;
		ToggleDetour();
	}

	else if( g_bCvarAllow == true && bAllowCvar == false )
	{
		RemoveCommandListener(OnJoinTeam, "jointeam");

		UnhookEvents();
		g_bCvarAllow = false;
		ToggleDetour();
	}
}



// ====================================================================================================
//					DETOUR
// ====================================================================================================
void ToggleDetour()
{
	static bool state;

	if( g_bCvarAllow && (g_iCvarCharge || g_iCvarBots) && state == false )
	{
		#if DEBUG
		PrintToServer("Charger: Detour Enable;");
		#endif

		state = true;
		if( !DHookEnableDetour(g_hDetourCollision, false, HandleCustomCollision) )
			SetFailState("Failed to detour: CCharge::HandleCustomCollision");
	}

	if( (!g_bCvarAllow || (!g_iCvarCharge && !g_iCvarBots)) && state == true )
	{
		#if DEBUG
		PrintToServer("Charger: Detour Disable;");
		#endif

		state = false;
		DHookDisableDetour(g_hDetourCollision, false, HandleCustomCollision);
	}
}

MRESReturn HandleCustomCollision(Handle hReturn, Handle hParams)
{
	int victim = DHookGetParam(hParams, 1);

	#if DEBUG
	if( victim ) PrintToServer("Charger: Collision %d", victim);
	#endif

	if( victim > 0 && victim <= MaxClients )
	{
		if( GetGameTime() > g_fThrown[victim] )
		{
			float vPos[3], vPos2[3];
			DHookGetParamVector(hParams, 2, vPos); // Collision position

			// Find charger client who caused the collision
			int client;
			float calc;
			float dist = 1000.0;
			for( int i = 1; i <= MaxClients; i++ )
			{
				if( g_bCharging[i] && IsClientInGame(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i) )
				{
					GetClientAbsOrigin(i, vPos2);
					calc = GetVectorDistance(vPos, vPos2);
					
					if( calc < dist )
					{
						dist = calc;
						client = i;
					}
				}
			}

			if( client && dist < 30 )
			{
				// Not bot and fling enabled. OR. Bot and random chance OR bot fling enabled.
				int bot = IsFakeClient(client);
				if( (!bot && g_iCvarCharge) || (bot && (g_iCvarBots == 2 ? GetRandomInt(0, 1) : g_iCvarBots)) )
				{
					#if DEBUG
					PrintToServer("ChargerThrow: %N hit %N. Range: (%0.1f)", client, victim, dist);
					#endif

					g_fThrown[victim] = GetGameTime() + 1.0;
					SDKCall(g_hSDK_Throw, client, victim, 0.1, false);
					EmitSoundToAll(g_Sounds[GetRandomInt(0, sizeof(g_Sounds) - 1)], client, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);

					if( g_iCvarDamage )
						HurtEntity(victim, client);
				} else {
					return MRES_Ignored;
				}
			}
		}

		DHookSetReturn(hReturn, 0); // Block collision
		return MRES_Supercede;
	}

	return MRES_Ignored;
}



// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("round_start",				Event_RoundStart);
	HookEvent("player_hurt",				Event_PlayerHurt);
	HookEvent("player_shoved",				Event_PlayerShoved);
	HookEvent("player_spawn",				Event_PlayerSpawn);
	HookEvent("revive_success",				Event_PlayerRevive);
	HookEvent("charger_pummel_end",			Event_PummelEnd);
	HookEvent("charger_carry_end",			Event_PummelEnd);
	HookEvent("charger_carry_start",		Event_CarryStart);
	HookEvent("charger_charge_end",			Event_ChargeStop);
	HookEvent("charger_pummel_start",		Event_PummelStart);
	HookEvent("player_incapacitated",		Event_PlayerIncap);
	HookEvent("charger_charge_start",		Event_ChargeStart);
}

void UnhookEvents()
{
	UnhookEvent("round_start",				Event_RoundStart);
	UnhookEvent("player_hurt",				Event_PlayerHurt);
	UnhookEvent("player_shoved",			Event_PlayerShoved);
	UnhookEvent("player_spawn",				Event_PlayerSpawn);
	UnhookEvent("revive_success",			Event_PlayerRevive);
	UnhookEvent("charger_pummel_end",		Event_PummelEnd);
	UnhookEvent("charger_carry_end",		Event_PummelEnd);
	UnhookEvent("charger_carry_start",		Event_CarryStart);
	UnhookEvent("charger_charge_end",		Event_ChargeStop);
	UnhookEvent("charger_pummel_start",		Event_PummelStart);
	UnhookEvent("player_incapacitated",		Event_PlayerIncap);
	UnhookEvent("charger_charge_start",		Event_ChargeStart);
}

// Grab survivor victim
void ResetPlugin()
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		delete g_hChargerIncap[i];
		g_bCharging[i] = false;
		g_bIncapped[i] = false;
		g_fCharge[i] = 0.0;
		g_fThrown[i] = 0.0;
		g_fPunch[i] = 0.0;
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iCvarPickup )
	{
		if( event.GetInt("type") & DMG_CLUB )
		{
			#if DEBUG
			PrintToServer("Charger: Event_PlayerHurt (%N)", GetClientOfUserId(event.GetInt("userid")));
			#endif

			int client = GetClientOfUserId(event.GetInt("attacker"));
			if( !client || IsFakeClient(client) || !IsCharger(client) ) return;
			if( g_bCharging[client] && (g_iCvarPunch == 0 || g_iCvarPickup & (1<<4) == 0) ) return;

			if( GetGameTime() < g_fThrown[client] )
			{
				#if DEBUG
				PrintToServer("Charger: Grab block: %f / %f (%N)", GetGameTime(), g_fThrown[client], GetClientOfUserId(event.GetInt("userid")));
				#endif
				return;
			}

			int target = GetClientOfUserId(event.GetInt("userid"));
			if( client && target && target <= MaxClients && GetGameTime() > g_fThrown[target] && IsCharger(client) && IsSurvivor(target) )
			{
				#if DEBUG
				PrintToServer("Charger: club %N from %N", GetClientOfUserId(event.GetInt("userid")), client);
				#endif

				if( GetEntPropEnt(client, Prop_Send, "m_carryVictim") != -1 || GetEntPropEnt(client, Prop_Send, "m_pummelVictim") != -1 )
				{
					#if DEBUG
					PrintToServer("Charger: already holding block");
					#endif
					return;
				}

				bool incap = GetEntProp(target, Prop_Send, "m_isIncapacitated", 1) == 1;

				// CARRY INCAP / CARRY STANDING
				if( (incap && g_iCvarPickup & (1<<0)) || (!incap && g_iCvarPickup & (1<<1)) )
				{
					#if DEBUG
					PrintToServer("Charger: Grab %s: %N", incap ? "incap" : "stand", target);
					#endif

					g_bIncapped[target] = incap;
					if( incap )
					{
						SetEntProp(target, Prop_Send, "m_isIncapacitated", 0, 1);
					}

					g_fThrown[client] = GetGameTime() + 0.8;
					SetWeaponAttack(client, true, 0.8);
					SetWeaponAttack(client, false, 0.8);
					SDKCall(g_hSDK_OnStartCarryingVictim, client, target);
					// CreateTimer(0.3, TimerTeleportTarget, GetClientUserId(target));
				}
			}
		}
	}
}

// Unused, old method
/*
Action TimerTeleportTarget(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if( client )
	{
		int target = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
		if( target != -1 && IsClientInGame(target) )
		{
			SetVariantString("!activator");
			AcceptEntityInput(client, "SetParent", target);
			SetVariantString("lhand");
			AcceptEntityInput(client, "SetParentAttachment");

			if( GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) )
				TeleportEntity(client, view_as<float>({ -10.0, -10.0, 5.0 }), NULL_VECTOR, NULL_VECTOR);
			else
			TeleportEntity(client, view_as<float>({ -15.0, 10.0, 5.0 }), NULL_VECTOR, NULL_VECTOR);
			// TeleportEntity(client, view_as<float>({ 1.0, 1.0, 1.0 }), NULL_VECTOR, NULL_VECTOR);
		}
	}

	return Plugin_Continue;
}
// */

// Fix team change freezing client
Action OnJoinTeam(int client, const char[] command, int args)
{
	if( client && IsClientInGame(client) && IsCharger(client) )
	{
		int target = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
		if( target != -1 && IsClientInGame(target) )
		{
			DropVictim(client, target, 0);
		}
		else
		{
			target = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
			if( target != -1 && IsClientInGame(target) )
			{
				DropVictim(client, target, 0);
			}
		}
	}

	return Plugin_Continue;
}

// Reset incapped bool
void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_bIncapped[client] = false;
}

void Event_PlayerRevive(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("subject"));
	g_bIncapped[client] = false;
}

void Event_PummelEnd(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("victim"));
	if( g_bIncapped[client] )
	{
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 1, 1);
	}
}

// Release charger victim
void Event_PlayerShoved(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iCvarShove )
	{
		int target = GetClientOfUserId(event.GetInt("userid")); // Was shoved
		int client = GetClientOfUserId(event.GetInt("attacker")); // By

		if( IsCharger(target) && IsSurvivor(client) )
		{
			int victim = GetEntPropEnt(target, Prop_Send, "m_pummelVictim");
			if( victim != -1 && IsClientInGame(victim) )
			{
				#if DEBUG
				PrintToServer("Charger: Event_PlayerShoved: Drop %d", client);
				#endif

				// Release
				if( g_iCvarShove & (1<<0) )
				{
					g_fThrown[target] = GetGameTime() + 0.6;
					DropVictim(target, victim, 1);
				}

				float vPos[3];

				// Stumble survivor
				if( g_iCvarShove & (1<<1) )
				{
					GetClientAbsOrigin(target, vPos);
					StaggerClient(client, vPos);
				}

				// Stumble charger
				if( g_iCvarShove & (1<<2) )
				{
					GetClientAbsOrigin(client, vPos);
					StaggerClient(target, vPos);
				}
			}
		}
	}
}

void Event_CarryStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iCvarDamage )
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		int victim = GetClientOfUserId(event.GetInt("victim"));

		if( GetGameTime() > g_fThrown[victim] )
		{
			g_fThrown[victim] = GetGameTime() + 1.0;
			HurtEntity(victim, client);
		}
	}
}

void Event_ChargeStop(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	#if DEBUG
	int victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
	int target = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
	PrintToServer("Charger: Event_ChargeStop %d %d %d", client, target, victim);
	#endif

	g_fThrown[client] = GetGameTime() + 0.5;
	g_bCharging[client] = false;
}

void Event_PummelStart(Event event, const char[] name, bool dontBroadcast)
{
	// DROP AFTER CHARGE
	if( g_iCvarFinish & (1<<0) )
	{
		int client = GetClientOfUserId(event.GetInt("userid"));

		if( GetGameTime() > g_fThrown[client] )
		{
			int target = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");

			#if DEBUG
			PrintToServer("Charger: Event_PummelStart drop %d (%f)", target, GetGameTime() - g_fThrown[client]);
			#endif

			if( target != -1 && IsClientInGame(target) )
			{
				DropVictim(client, target, 0); // Drop after charge
			}
		}
	}
	else if( g_iCvarFinish == 4 )
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if( GetGameTime() > g_fThrown[client] )
		{
			int target = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
			SetEntPropEnt(client, Prop_Send, "m_carryVictim", -1);
			SetEntPropEnt(target, Prop_Send, "m_carryAttacker", -1);
			SDKCall(g_hSDK_OnPummelEnded, client, "", target);

			g_bIncapped[target] = GetEntProp(target, Prop_Send, "m_isIncapacitated", 1) == 1;
			if( g_bIncapped[target] )
			{
				SetEntProp(target, Prop_Send, "m_isIncapacitated", 0, 1);
			}

			g_fThrown[client] = GetGameTime() + 0.8;
			SDKCall(g_hSDK_OnStartCarryingVictim, client, target);
			// CreateTimer(0.3, TimerTeleportTarget, GetClientUserId(target));

			float time = g_iCvarInterval - (GetGameTime() - g_fCharge[client]);
			if( time < 1.0 ) time = 1.0;

			SetWeaponAttack(client, true, time);
			SetWeaponAttack(client, false, 0.6);
		}
	}
}

void Event_PlayerIncap(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iCvarFinish & (1<<1) )
	{
		int target = GetClientOfUserId(event.GetInt("userid"));
		int client = GetClientOfUserId(event.GetInt("attacker"));

		if( client && target && client <= MaxClients && target <= MaxClients && IsCharger(client) && IsClientInGame(target) && IsSurvivor(target) )
		{
			#if DEBUG
			PrintToServer("Charger: Event_PlayerIncap drop %N", target);
			#endif

			DropVictim(client, target); // Drop after charge
		}
	}
}



// ====================================================================================================
//					AUTO PICK UP INCAPPED
// ====================================================================================================
void Event_ChargeStart(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	g_iJumped[client] = 0;
	g_bCharging[client] = true;
	g_fCharge[client] = GetGameTime();

	// Auto pick up
	delete g_hChargerIncap[client];

	if( g_iCvarIncap )
	{
		g_hChargerIncap[client] = CreateTimer(0.1, TimerChargeIncap, userid, TIMER_REPEAT);
	}

	#if DEBUG
	PrintToServer("Charger: Event_ChargeStart %d", client);
	#endif
}

Action TimerChargeIncap(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if( client && g_bCharging[client] && IsClientInGame(client) && GetEntPropEnt(client, Prop_Send, "m_carryVictim") == -1 )
	{
		float vLoc[3], vPos[3];
		GetClientAbsOrigin(client, vLoc);

		for( int target = 1; target <= MaxClients; target++ )
		{
			if( IsClientInGame(target) && GetClientTeam(target) == 2 && IsPlayerAlive(target) && GetEntProp(target, Prop_Send, "m_isIncapacitated", 1) && GetEntProp(target, Prop_Send, "m_isHangingFromLedge", 1) == 0 )
			{
				if( g_iCvarIncap == 2 && (GetEntPropEnt(target, Prop_Send, "m_pounceAttacker") > 0 || GetEntPropEnt(target, Prop_Send, "m_pummelAttacker") > 0 || GetEntPropEnt(target, Prop_Send, "m_carryAttacker") > 0) )
				{
					continue;
				}

				GetClientAbsOrigin(target, vPos);
				if( GetVectorDistance(vLoc, vPos) <= 50.0 )
				{
					g_bIncapped[target] = true;
					SetEntProp(target, Prop_Send, "m_isIncapacitated", 0, 1);

					g_fThrown[client] = GetGameTime() + 0.8;
					SetWeaponAttack(client, true, 0.8);
					SetWeaponAttack(client, false, 0.8);
					SDKCall(g_hSDK_OnStartCarryingVictim, client, target);
					// CreateTimer(0.3, TimerTeleportTarget, GetClientUserId(target));

					g_hChargerIncap[client] = null;

					return Plugin_Stop;
				}
			}
		}

		return Plugin_Continue;
	}

	g_hChargerIncap[client] = null;
	return Plugin_Stop;
}



// ====================================================================================================
//					ON PLAYER RUN CMD - ATTACK
// ====================================================================================================
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if( !g_bCvarAllow || !(buttons & IN_JUMP || buttons & IN_ATTACK || buttons & IN_ATTACK2 || buttons & IN_ZOOM) ) return Plugin_Continue;

	if( IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client) && IsCharger(client) )
	{
		// JUMP
		if( buttons & IN_JUMP && g_iCvarJump && GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND )
		{
			if( g_iCvarJump == 2 || GetEntPropEnt(client, Prop_Send, "m_carryVictim") == -1 )
			{
				if( g_iCvarJumps )
				{
					if( g_iJumped[client] >= g_iCvarJumps ) return Plugin_Continue;
					g_iJumped[client]++;
				}

				GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
				vel[2] = 300.0;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
			}
		}
		else if( buttons & IN_ATTACK || buttons & IN_ZOOM )
		{
			#if DEBUG
			PrintToServer("Charge? %N", client);
			#endif

			// PUMMEL START / STOP
			int target = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
			int victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
			if( target != -1 || victim != -1 )
			{
				#if DEBUG
				PrintToServer("Charger: target: %d victim: %d", target, victim);
				#endif

				if( g_iCvarPummel && ((!g_iCvarRepeat && buttons & IN_ATTACK) || (g_iCvarRepeat && buttons & IN_ZOOM)) ) // 0=Off. 1=Incapped only. 2=Any survivor.
				{
					target = target != -1 ? target : victim;

					#if DEBUG
					PrintToServer("Charger: Pummel try %N", target);
					#endif

					if( g_iCvarPummel == 2 || (g_iCvarPummel == 1 && GetEntProp(target, Prop_Send, "m_isIncapacitated", 1) == 1) )
					{
						if( CanWeaponAttack(client, false) )
						{
							if( victim == -1 )
							{
								#if DEBUG
								PrintToServer("Charger: Start manual pummel %d", target);
								#endif

								g_fThrown[client] = GetGameTime() + 0.5;

								if( g_bIncapped[target] )
								{
									SetEntProp(target, Prop_Send, "m_isIncapacitated", 1, 1);
								}

								SDKCall(g_hSDK_QueuePummelVictim, client, target, -1.0);
								SetWeaponAttack(client, true, 0.5);
								SetWeaponAttack(client, false, 1.0);
							} else {
								#if DEBUG
								PrintToServer("Charger: Stop manual pummel %d", target);
								#endif
		
								g_fThrown[client] = GetGameTime() + 1.0;
								SetWeaponAttack(client, true, 2.0);
								SetWeaponAttack(client, false, 0.8);
								DropVictim(client, target);
							}
						}
					}
				}
				else if( !g_iCvarPummel || (g_iCvarPummel && buttons & IN_ZOOM) )
				{
					if( !g_iCvarRepeat )
					{
						#if DEBUG
						PrintToServer("Charger: Repeat charge, carry block");
						#endif

						buttons &= ~IN_ATTACK;
						SetWeaponAttack(client, true, 1.0);
						return Plugin_Changed;
					}
				}
			}
		}
		else if( buttons & IN_ATTACK2 )
		{
			int target = -1;
			int victim = -1;

			if( g_iCvarPickup )
			{
				// CARRY DROP
				target = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
				victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
			}

			if( target != -1 || victim != -1 )
			{
				target = target != -1 ? target : victim;
				if( target != -1 && IsClientInGame(target) )
				{
					if( (GetEntProp(target, Prop_Send, "m_isIncapacitated", 1) == 1 && g_iCvarPickup & (1<<2)) || g_iCvarPickup & (1<<3) )
					{
						#if DEBUG
						PrintToServer("Charger: Carry drop pass. Time: %f / Cur: %f. (%N)", g_fThrown[client], GetGameTime(), target);
						#endif

						if( GetGameTime() > g_fThrown[client] )
						{
							#if DEBUG
							PrintToServer("Charger: Do drop %N", target);
							#endif

							g_fThrown[client] = GetGameTime() + 1.0;
							SetWeaponAttack(client, true, 1.0);
							SetWeaponAttack(client, false, 1.0);
							DropVictim(client, target);
						}
					}
				}
			} else {
				if( g_iCvarPunch && g_bCharging[client] && g_fPunch[client] < GetGameTime() )
				{
					g_fPunch[client] = GetGameTime() + 1.0;
					SetWeaponAttack(client, false, -10.0);

					if( GetEntProp(client, Prop_Send, "m_fFlags") & FL_FROZEN ) // Only remove and reset if not already removed by the "Charger Steering" plugin.
					{
						SetEntProp(client, Prop_Send, "m_fFlags", GetEntProp(client, Prop_Send, "m_fFlags") & ~FL_FROZEN);
						g_bPunched[client] = true;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse)
{
	if( g_bPunched[client] )
	{
		g_bPunched[client] = false;
		SetEntProp(client, Prop_Send, "m_fFlags", GetEntProp(client, Prop_Send, "m_fFlags") | FL_FROZEN);
	}
}



// ====================================================================================================
//					OTHER
// ====================================================================================================
void DropVictim(int client, int target, int stagger = 3) // 1 = Charger, 2 = Survivor
{
	#if DEBUG
	PrintToServer("Charger: Drop Victim %N (stagger %d)", target, stagger);
	PrintToServer("Charger: Attack time %f for %N", g_iCvarInterval - (GetGameTime() - g_fCharge[client]), client);
	#endif

	SDKCall(g_hSDK_OnPummelEnded, client, "", target);

	float time = g_iCvarInterval - (GetGameTime() - g_fCharge[client]);
	if( time < 1.0 ) time = 1.0;

	SetWeaponAttack(client, true, time);
	SetWeaponAttack(client, false, 0.6);

	SetEntPropEnt(client, Prop_Send, "m_carryVictim", -1);
	SetEntPropEnt(target, Prop_Send, "m_carryAttacker", -1);

	bool incap = GetEntProp(target, Prop_Send, "m_isIncapacitated", 1) == 1;
	float vPos[3];

	if( g_bIncapped[target] && !incap )
	{
		SetEntProp(target, Prop_Send, "m_isIncapacitated", 1, 1);
	}

	vPos[0] = incap ? 20.0 : 50.0;
	SetVariantString("!activator");
	AcceptEntityInput(target, "SetParent", client);
	TeleportEntity(target, vPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(target, "ClearParent");

	// Fix stuck in flying animation bug, 0.3 seems enough to cover, any earlier may not always detect the falling anim
	CreateTimer(0.3, TimerFixAnim, GetClientUserId(target));

	// Event
	Event hEvent = CreateEvent("charger_carry_end");
	if( hEvent )
	{
		hEvent.SetInt("userid", GetClientUserId(client));
		hEvent.SetInt("victim", GetClientUserId(target));
		hEvent.Fire();
	}

	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntityMoveType(target, MOVETYPE_WALK);

	// Stagger
	if( stagger & (1<<0) )
	{
		GetClientEyePosition(target, vPos);
		StaggerClient(client, vPos);
	}

	if( stagger & (1<<1) )
	{
		GetClientEyePosition(client, vPos);
		StaggerClient(target, vPos);
	}

	g_fThrown[target] = GetGameTime() + 0.5;
}

Action TimerFixAnim(Handle timer, int target)
{
	target = GetClientOfUserId(target);
	if( target && IsPlayerAlive(target) )
	{
		int seq = GetEntProp(target, Prop_Send, "m_nSequence");
		// "ACT_TERROR_FALL" sequence number
		if( seq == 650 || seq == 665 || seq == 661 || seq == 651 || seq == 554 || seq == 551 ) // Coach, Ellis, Nick, Rochelle, Francis/Zoey, Bill/Louis
		{
			#if DEBUG
			PrintToServer("Charger: Fixing victim stuck falling: %N", target);
			#endif

			float vPos[3];
			GetClientAbsOrigin(target, vPos);
			SetEntityMoveType(target, MOVETYPE_WALK);
			TeleportEntity(target, vPos, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
		}
	}

	return Plugin_Continue;
}

void SetWeaponAttack(int client, bool primary, float time)
{
	if( primary )
	{
		int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
		if( ability != -1 )
		{
			if( GetEntPropFloat(ability, Prop_Send, "m_timestamp") < GetGameTime() + time )
				SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}

	int weapon = GetPlayerWeaponSlot(client, 0);
	if( weapon != -1 )
	{
		if( primary )	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + time);
		if( !primary )	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + time);
	}
}

bool CanWeaponAttack(int client, bool primary)
{
	int weapon = GetPlayerWeaponSlot(client, 0);
	if( weapon != -1 )
	{
		float time = GetGameTime();
		if( primary )	return time - GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") >= 0.0;
		if( !primary )	return time - GetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack") >= 0.0;
	}
	return false;
}

bool IsCharger(int client)
{
	if( GetClientTeam(client) == 3 && GetEntProp(client, Prop_Send, "m_zombieClass") == 6 )
		return true;
	return false;
}

bool IsSurvivor(int client)
{
	if( GetClientTeam(client) == 2 )
		return true;
	return false;
}

// Credit to Timocop for VScript function
void StaggerClient(int userid, float vPos[3])
{
	userid = GetClientUserId(userid);
	int logic = CreateEntityByName("logic_script");
	if( logic == INVALID_ENT_REFERENCE )
	{
		LogError("Could not create 'logic_script");
		return;
	}
	DispatchSpawn(logic);

	char sBuffer[96];
	Format(sBuffer, sizeof(sBuffer), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", userid, RoundFloat(vPos[0]), RoundFloat(vPos[1]), RoundFloat(vPos[2]));
	SetVariantString(sBuffer);
	AcceptEntityInput(logic, "RunScriptCode");
	RemoveEntity(logic);
}

void HurtEntity(int victim, int client)
{
	SDKHooks_TakeDamage(victim, client, client, float(g_iCvarDamage), DMG_CLUB);
}