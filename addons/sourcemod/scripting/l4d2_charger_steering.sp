/*
*	Charger Steering
*	Copyright (C) 2024 Silvers
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



#define PLUGIN_VERSION 		"1.10"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D2] Charger Steering
*	Author	:	SilverShot
*	Descrp	:	Allows chargers to turn and strafe while charging.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=179034
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.10 (03-Apr-2024)
	- Added cvar "l4d2_charger_steering_flags" to control who is allowed to use steering. Requested by "caphao1101".

1.9 (09-Oct-2020)
	- Changed "OnClientPostAdminCheck" to "OnClientPutInServer" - to fix any issues if Steam service is down.

1.8 (10-May-2020)
	- Extra checks to prevent "IsAllowedGameMode" throwing errors.
	- Various changes to tidy up code.

1.7 (01-Apr-2020)
	- Fixed "IsAllowedGameMode" from throwing errors when the "_tog" cvar was changed before MapStart.
	- Updated these translations file encoding to UTF-8 (to display all characters correctly): German (de).

1.6 (05-May-2018)
	- Converted plugin source to the latest syntax utilizing methodmaps. Requires SourceMod 1.8 or newer.
	- Removed instructor hints due to Valve: FCVAR_SERVER_CAN_EXECUTE prevented server running command: gameinstructor_enable.

1.5 (22-May-2012)
	- Fixed error: "SetEntPropFloat reported: Entity -1 (-1) is invalid".

1.4 (20-May-2012)
	- Added German translations - Thanks to "Dont Fear The Reaper".
	- Fixed errors reported by "Dont Fear The Reaper".

1.3 (15-May-2012)
	- Fixed cvar "l4d2_charger_steering_modes_tog" missing.
	- Small fixes.

1.2 (30-Mar-2012)
	- Fixed a bug which could allow strafing as a survivor.

1.1 (30-Mar-2012)
	- Added cvar "l4d2_charger_steering_modes_off" to control which game modes the plugin works in.
	- Added cvar "l4d2_charger_steering_modes_tog" same as above.
	- Added cvars to control hints and what humans/bots have access to.
	- Added Strafing - Thanks to "dcx2".
	- Added translations and hint messages.
	- Added Russian translations - Thanks to "disawar1".
	- Fixed being able to punch while charging.

1.0 (25-Feb-2012)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define CVAR_FLAGS			FCVAR_NOTIFY
#define CHAT_TAG			"\x05[Charger Steering] \x01"


ConVar g_hCvarAllow, g_hCvarBots, g_hCvarFlags, g_hCvarHint, g_hCvarHints, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarStrafe;
int g_iCvarAllow, g_iCvarBots, g_iCvarFlags, g_iCvarHint, g_iCvarHints, g_iDisplayed[MAXPLAYERS+1];
bool g_bCvarAllow, g_bMapStarted, g_bIsCharging[MAXPLAYERS+1];
float g_fCvarStrafe;



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D2] Charger Steering",
	author = "SilverShot",
	description = "Allows chargers to turn while charging.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=179034"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("chargersteering.phrases");

	g_hCvarAllow =		CreateConVar(	"l4d2_charger_steering_allow",		"3",			"0=Plugin off, 1=Allow steering with mouse, 2=Allow strafing, 3=Both.", CVAR_FLAGS );
	g_hCvarBots =		CreateConVar(	"l4d2_charger_steering_bots",		"2",			"Who can steer with the mouse. 0=Humans Only, 1=AI only, 2=Humans and AI.", CVAR_FLAGS );
	g_hCvarFlags =		CreateConVar(	"l4d2_charger_steering_flags",		"",				"Users with these flags can use the steering. Empty string = anyone.", CVAR_FLAGS);
	g_hCvarHint =		CreateConVar(	"l4d2_charger_steering_hint",		"2",			"Display hint when charging? 0=Off, 1=Chat text, 2=Hint box.", CVAR_FLAGS);
	g_hCvarHints =		CreateConVar(	"l4d2_charger_steering_hints",		"2",			"How many times to display hints, count is reset each map/chapter.", CVAR_FLAGS);
	g_hCvarStrafe =		CreateConVar(	"l4d2_charger_steering_strafe",		"50.0",			"0.0=Off. Other value sets the amount humans strafe to the side.", CVAR_FLAGS );
	g_hCvarModes =		CreateConVar(	"l4d2_charger_steering_modes",		"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =	CreateConVar(	"l4d2_charger_steering_modes_off",	"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog = CreateConVar(		"l4d2_charger_steering_modes_tog",	"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	CreateConVar(						"l4d2_charger_steering_version",	PLUGIN_VERSION, "Charger Steering plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,				"l4d2_charger_steering");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarBots.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarFlags.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHint.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHints.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarStrafe.AddChangeHook(ConVarChanged_Cvars);
}

public void OnClientPutInServer(int client)
{
	g_iDisplayed[client] = 0;
}



// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

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
	char sTemp[32];
	g_hCvarFlags.GetString(sTemp, sizeof(sTemp));
	g_iCvarFlags = ReadFlagString(sTemp);

	g_iCvarBots = g_hCvarBots.IntValue;
	g_iCvarHint = g_hCvarHint.IntValue;
	g_iCvarHints = g_hCvarHints.IntValue;
	g_fCvarStrafe = g_hCvarStrafe.FloatValue;
}

void IsAllowed()
{
	g_iCvarAllow = g_hCvarAllow.IntValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && g_iCvarAllow && bAllowMode == true )
	{
		g_bCvarAllow = true;
		HookEvent("player_spawn",			Event_PlayerSpawn);
		HookEvent("player_death",			Event_PlayerDeath);
		HookEvent("charger_charge_start",	Event_ChargeStart);
		HookEvent("charger_charge_end",		Event_ChargeEnd);
	}

	else if( g_bCvarAllow == true && (g_iCvarAllow == 0 || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		UnhookEvent("player_spawn",			Event_PlayerSpawn);
		UnhookEvent("player_death",			Event_PlayerDeath);
		UnhookEvent("charger_charge_start",	Event_ChargeStart);
		UnhookEvent("charger_charge_end",	Event_ChargeEnd);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_bMapStarted == false )
			return false;

		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}



// ====================================================================================================
//					EVENTS
// ====================================================================================================
void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_bIsCharging[client] = false;
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_bIsCharging[client] = false;
}

void Event_ChargeStart(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_bIsCharging[client] = false;

	if( g_iCvarFlags && CheckCommandAccess(client, "", g_iCvarFlags, true) == false ) return;

	if( g_iCvarAllow >= 2 )
		g_bIsCharging[client] = true;

	if( g_iCvarBots == 2 || (g_iCvarBots == 0 && IsFakeClient(client) == false) || (g_iCvarBots == 1 && IsFakeClient(client) == true) )
	{
		if( g_iCvarAllow != 2 )
		{
			SetEntProp(client, Prop_Send, "m_fFlags", GetEntProp(client, Prop_Send, "m_fFlags") & ~FL_FROZEN);

			int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if( entity != -1 )
				SetEntPropFloat(entity, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 999.9);
		}

		if( !g_iCvarHint || (g_iCvarHint < 3 && g_iDisplayed[client] >= g_iCvarHints) || IsFakeClient(client) )
			return;

		g_iDisplayed[client]++;
		int hint = g_iCvarHint;
		if( hint == 3 )			hint = 1; // Can no longer support instructor hints
		else if( hint == 4 )	hint = 2;

		switch ( hint )
		{
			case 1:		// Print To Chat
			{
				if( g_iCvarAllow == 1 && g_iCvarBots != 1 )
					PrintToChat(client, "%s%T", CHAT_TAG, "ChargerSteering_Mouse", client);
				else if( g_iCvarAllow == 2 && g_fCvarStrafe != 0.0 )
					PrintToChat(client, "%s%T", CHAT_TAG, "ChargerSteering_Strafe", client);
				else if( g_iCvarAllow == 3 && g_fCvarStrafe != 0.0 )
					PrintToChat(client, "%s%T", CHAT_TAG, "ChargerSteering_Both", client);
			}

			case 2:		// Print Hint Text
			{
				if( g_iCvarAllow == 1 && g_iCvarBots != 1 )
					PrintHintText(client, "%T", "ChargerSteering_Mouse", client);
				else if( g_iCvarAllow == 2 && g_fCvarStrafe != 0.0 )
					PrintHintText(client, "%T", "ChargerSteering_Strafe", client);
				else if( g_iCvarAllow == 3 && g_fCvarStrafe != 0.0 )
					PrintHintText(client, "%T", "ChargerSteering_Both", client);
			}
		}
	}
}

void Event_ChargeEnd(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client )
	{
		g_bIsCharging[client] = false;

		if( g_iCvarAllow != 2 && (g_iCvarBots == 2 || (g_iCvarBots == 0 && IsFakeClient(client) == false) || (g_iCvarBots == 1 && IsFakeClient(client) == true)) )
		{
			int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if( entity != -1 )
				SetEntPropFloat(entity, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 1.0);
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if( g_bCvarAllow && g_fCvarStrafe && (buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT) && g_bIsCharging[client] && GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND )
	{
		float vVel[3], vVec[3], vAng[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
		GetClientEyeAngles(client, vAng);

		GetAngleVectors(vAng, NULL_VECTOR, vVec, NULL_VECTOR);
		NormalizeVector(vVec, vVec);

		ScaleVector(vVec, g_fCvarStrafe);
		if( buttons & IN_MOVELEFT )
			ScaleVector(vVec, -1.0);

		AddVectors(vVel, vVec, vVel);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
	}
	return Plugin_Continue;
}