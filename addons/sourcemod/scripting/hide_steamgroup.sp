/*
*	[ANY] Hide SteamGroup ID
*	Copyright (C) 2021 Silvers
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



#define PLUGIN_VERSION		"1.0"

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>



public Plugin myinfo =
{
	name = "[ANY] Hide SteamGroup ID",
	author = "SilverShot",
	description = "Prevents the servers sv_steamgroup ID being shown on tracking websites and stolen by others.",
	version = PLUGIN_VERSION,
	url = "https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers"
}

public void OnPluginStart()
{
	ConVar hCvar = FindConVar("sv_steamgroup");
	if( hCvar )
	{
		hCvar.Flags = hCvar.Flags & ~FCVAR_NOTIFY;
	}

	CreateConVar("hide_steamgroup_version", PLUGIN_VERSION, "Hide SteamGroup ID plugin version.");
}