#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define MOVETYPE_WALK 2
#define MOVETYPE_FLYGRAVITY 5
#define MOVECOLLIDE_DEFAULT 0
#define MOVECOLLIDE_FLY_BOUNCE 1

#define TEAM_INFECTED 3

#define CVAR_FLAGS FCVAR_PLUGIN

new PropMoveCollide;
new PropMoveType;
new PropVelocity;
new PropGhost;

new Handle:GhostFly;
new Handle:FlySpeed;
new Handle:MaxSpeed;

new bool:Flying[MAXPLAYERS+1];
new bool:Eligible[MAXPLAYERS+1];

#define PLUGIN_VERSION "1.1.1"

public Plugin:myinfo =
{
	name = "L4D Ghost Fly",
	author = "Madcap",
	description = "Fly as a ghost.",
	version = PLUGIN_VERSION,
	url = "http://maats.org"
}


public OnPluginStart()
{

	GhostFly = CreateConVar("l4d_ghost_fly", "1", "Turn on/off the ability for ghosts to fly.",CVAR_FLAGS,true,0.0,true,1.0);
	FlySpeed = CreateConVar("l4d_ghost_fly_speed", "50", "Ghost flying speed.",CVAR_FLAGS,true,0.0);
	MaxSpeed = CreateConVar("l4d_ghost_max_speed", "500", "Ghost flying max speed.", CVAR_FLAGS, true, 300.0);
	//AutoExecConfig(true, "sm_plugin_ghost_fly");
	
	CreateConVar("l4d_ghost_fly_version", PLUGIN_VERSION, " Ghost Fly Plugin Version ", FCVAR_REPLICATED|FCVAR_NOTIFY);

	PropMoveCollide = FindSendPropOffs("CBaseEntity",   "movecollide");
	PropMoveType    = FindSendPropOffs("CBaseEntity",   "movetype");
	PropVelocity    = FindSendPropOffs("CBasePlayer",   "m_vecVelocity[0]");
	PropGhost       = FindSendPropInfo("CTerrorPlayer", "m_isGhost");

	HookEvent("ghost_spawn_time", EventGhostNotify2);
	HookEvent("player_first_spawn", EventGhostNotify1);

}

// moving this outside of to save initialization,
new bool:elig;

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{

	if (GetConVarBool(GhostFly))
	{
	
		elig = isEligible(client);

		Eligible[client] = elig;

		if (elig)
		{
			if(buttons & IN_RELOAD)
			{		
				if (Flying[client])
					KeepFlying(client);
				else	
					StartFlying(client);
			}
			else
			{
				if (Flying[client])
					StopFlying(client);
			}	
		}
		else
		{
			if (Flying[client])
				StopFlying(client);
		}
	
	}
}

bool:isEligible(client)
{

	if (!IsClientConnected(client)) return false;
	if (!IsClientInGame(client)) return false;
	if (GetClientTeam(client)!=TEAM_INFECTED) return false;
	if (GetEntData(client, PropGhost, 1)!=1) return false;
	
	return true;
}

public Action:StartFlying(client)
{
	Flying[client]=true;
	SetMoveType(client, MOVETYPE_FLYGRAVITY, MOVECOLLIDE_FLY_BOUNCE);
	AddVelocity(client, GetConVarFloat(FlySpeed));
	return Plugin_Continue;
}

public Action:KeepFlying(client)
{
	AddVelocity(client, GetConVarFloat(FlySpeed));
	return Plugin_Continue;
}

public Action:StopFlying(client)
{
	Flying[client]=false;
	SetMoveType(client, MOVETYPE_WALK, MOVECOLLIDE_DEFAULT);
	return Plugin_Continue;
}

AddVelocity(client, Float:speed)
{
	new Float:maxSpeed = GetConVarFloat(MaxSpeed);
	new Float:vecVelocity[3];
	GetEntDataVector(client, PropVelocity, vecVelocity);
	if ((vecVelocity[2]+speed) > maxSpeed)
		vecVelocity[2] = maxSpeed;
	else
		vecVelocity[2] += speed;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

SetMoveType(client, movetype, movecollide)
{
	SetEntData(client, PropMoveType, movetype);
	SetEntData(client, PropMoveCollide, movecollide);
}

public Action:EventGhostNotify1(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	Notify(client,0);
}


public Action:EventGhostNotify2(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	Notify(client,GetEventInt(event, "spawntime"));
}

public Notify(client,time)
{
	CreateTimer((3.0+time), NotifyClient, client);
}

public Action:NotifyClient(Handle:timer, any:client)
{

	if (isEligible(client)){
		PrintToChat(client, "As a ghost you can fly by holding your RELOAD button.");
	}

}


