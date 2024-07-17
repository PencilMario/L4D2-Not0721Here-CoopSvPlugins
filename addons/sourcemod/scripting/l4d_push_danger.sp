/*
*	Push Away From Danger - Acid and Fire
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



#define PLUGIN_VERSION 		"1.1"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D & L4D2] Push Away From Danger - Acid and Fire
*	Author	:	SilverShot
*	Descrp	:	Pushes bots or players away from fires and spitter acid.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=347947
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.1 (17-Jun-2024)
	- Added cvar "l4d_push_danger_damage_types" - What damage type can push a player away: 1=Acid, 2=Burn, 3=Both. Default: 3.
	- Fixed cvar "l4d_push_danger_allow" having no affect.
	- Fixed debug message spam.
	- Thanks to "BloodyBlade" for changes.

1.0 (03-Jun-2024)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>


#define CVAR_FLAGS			FCVAR_NOTIFY
#define TYPE_BOTS 			(1 << 0)
#define TYPE_HUMAN	 		(1 << 1)


ConVar g_hCvarMPGameMode, g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarTypes, g_hCvarDamageTypes;
bool g_bCvarAllow, g_bLeft4Dead2;
int g_iCvarTypes, g_iCvarDamageTypes;

int g_iDmgInterval[MAXPLAYERS] = {3};



// ====================================================================================================
//					PLUGIN
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Push Away From Danger - Acid and Fire",
	author = "SilverShot",
	description = "Pushes bots or players away from fires and spitter acid.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=347947"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test == Engine_Left4Dead ) g_bLeft4Dead2 = false;
	else if( test == Engine_Left4Dead2 ) g_bLeft4Dead2 = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	// =================
	// CVARS
	// =================
	g_hCvarAllow =			CreateConVar(	"l4d_push_danger_allow",			"1",					"0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	g_hCvarModes =			CreateConVar(	"l4d_push_danger_modes",			"",						"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar(	"l4d_push_danger_modes_off",		"",						"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar(	"l4d_push_danger_modes_tog",		"0",					"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarTypes =			CreateConVar(	"l4d_push_danger_types",			"1",					"Who should be pushed away from acid/fire damage: 1=Bots, 2=Humans, 3=Both.", CVAR_FLAGS );
	g_hCvarDamageTypes = 	CreateConVar(	"l4d_push_danger_damage_types",		"3",					"What damage type can push a player away: 1=Acid, 2=Burn, 3=Both.", CVAR_FLAGS );
	CreateConVar(							"l4d_push_danger_version",			PLUGIN_VERSION,			"Push Away From Danger plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD );
	AutoExecConfig(true,					"l4d_push_danger");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarTypes.AddChangeHook(ConVarChanged_Cvars);

	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame(i) )
		{
			OnClientPutInServer(i);
		}
	}
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
	g_iCvarTypes = g_hCvarTypes.IntValue;
	g_iCvarDamageTypes = g_hCvarDamageTypes.IntValue;
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
	}
}

int g_iCurrentMode;
public void L4D_OnGameModeChange(int gamemode)
{
	g_iCurrentMode = gamemode;
}

bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_iCurrentMode == 0 )
			g_iCurrentMode = L4D_GetGameModeType();

		if( g_iCurrentMode == 0 )
			return false;

		switch( g_iCurrentMode ) // Left4DHooks values are flipped for these modes, sadly
		{
			case 2:		g_iCurrentMode = 4;
			case 4:		g_iCurrentMode = 2;
		}

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



// ====================================================================================================
//					EVENTS
// ====================================================================================================
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if( g_bCvarAllow && (damagetype == 263168 || damagetype == 265216) || damagetype & DMG_BURN )
	{
		if( GetClientTeam(victim) == 2 )
		{
			if( g_iCvarTypes != 3 )
			{
				bool fake = IsFakeClient(victim);
				if( fake && g_iCvarTypes == 2 ) return Plugin_Continue;
				if( !fake && g_iCvarTypes == 1 ) return Plugin_Continue;
			}

			static char classname[16];
			bool checked;
			bool pass;

			if( g_iCvarDamageTypes & (1<<0) )
			{
				if( g_bLeft4Dead2 && (damagetype == 263168 || damagetype == 265216) )
				{
					GetEntityClassname(inflictor, classname, sizeof(classname));
					checked = true;

					if( strcmp(classname, "insect_swarm") == 0 )
					{
						pass = true;
					}
				}
			}

			if( !pass && g_iCvarDamageTypes & (1<<1) )
			{
				if( (damagetype & DMG_BURN) )
				{
					if( !checked )
					{
						GetEntityClassname(inflictor, classname, sizeof(classname));
					}

					if( strcmp(classname, "inferno") == 0 )
					{
						pass = true;
					}
				}
			}

			if( pass )
			{
				L4D_StaggerPlayer(victim, inflictor, NULL_VECTOR);
				if (g_iDmgInterval[victim]-- < 0){
					g_iDmgInterval[victim] = 7;
				}
				else {damage = 0.1;return Plugin_Handled;}
			}
		}
	}

	return Plugin_Continue;
}