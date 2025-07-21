//#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <l4d2_skills>

#define SKILL_NAME "牢大肘击"

public Plugin myinfo =
{
	name = "[L4D2] Perfect Shove",
	author = "BHaType",
	description = "Deals damage to shoved specials",
	version = "1.1",
	url = "https://github.com/Vinillia/l4d2_skills"
};

enum struct PerfectShoveExport
{
	BaseSkillExport base;
	float damage_for_specials;
	float damage_for_infected;
}

PerfectShoveExport gExport;
bool g_bLate;
int g_iID;

public void OnPluginStart()
{
	HookEvent("player_shoved", player_shoved);
	HookEvent("entity_shoved", entity_shoved);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLate = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_iID = Skills_Register(SKILL_NAME, ST_ACTIVATION, false);
	
	if (g_bLate)
		Skills_RequestConfigReload();
}

public void player_shoved( Event event, const char[] name, bool noReplicate )
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if ( !attacker || attacker > MaxClients || !IsHaveSkill(attacker) || !IsClientInGame(attacker) )
		return;

	if ( !client || client > MaxClients || !IsClientInGame(client))
		return;
	//L4D_StaggerPlayer(client, attacker, NULL_VECTOR);
	float angle[3];
	GetClientEyeAngles(attacker, angle);
	new Handle:hPack = CreateDataPack();
	WritePackCell(hPack, client);
	WritePackCell(hPack, attacker);
	RequestFrame(extframe, hPack);
	if (GetClientTeam(client) == L4DTeam_Survivor)
	{
		SDKHooks_TakeDamage(client, attacker, attacker, gExport.damage_for_specials * 0.05, 0, -1, NULL_VECTOR, NULL_VECTOR, false);
		return;
	}
	if (GetClientTeam(client) != 3 )
		return;
	SDKHooks_TakeDamage(client, attacker, attacker, gExport.damage_for_specials);
}
void extframe(Handle hPack){
	ResetPack(hPack);
	int attacker = ReadPackCell(hPack);
	int client = ReadPackCell(hPack);
	float angle[3];
	GetClientEyeAngles(attacker, angle);
	Entity_PushForce(client, 400.0, angle, 0.0, false);
	CloseHandle(hPack);
}
public void entity_shoved( Event event, const char[] name, bool noReplicate )
{
	int entity = event.GetInt("entityid");
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if ( !attacker || attacker > MaxClients || !IsHaveSkill(attacker) )
		return;
	
	if ( entity > MaxClients && ClassMatchesComplex(entity, "infected") || ClassMatchesComplex(entity, "witch"))
		SDKHooks_TakeDamage(entity, attacker, attacker, gExport.damage_for_infected);
}

public void Skills_OnGetSettings( KeyValues kv )
{
	EXPORT_START(SKILL_NAME);
	
	EXPORT_SKILL_COST(gExport.base, 8000.0);
	EXPORT_FLOAT_DEFAULT("damage_for_specials", gExport.damage_for_specials, 600.0);
	EXPORT_FLOAT_DEFAULT("damage_for_infected", gExport.damage_for_infected, 600.0);

	EXPORT_FINISH();
}

bool IsHaveSkill( int client )
{
	return Skills_ClientHaveByID(client, g_iID);
}

static Entity_PushForce(iEntity, Float:fForce, Float:fAngles[3], Float:fMax=0.0, bool:bAdd=false)
{
	static Float:fVelocity[3];
	
	fVelocity[0] = fForce * Cosine(DegToRad(fAngles[1])) * Cosine(DegToRad(fAngles[0]));
	fVelocity[1] = fForce * Sine(DegToRad(fAngles[1])) * Cosine(DegToRad(fAngles[0]));
	fVelocity[2] = fForce * Sine(DegToRad(fAngles[0]));
	
	GetAngleVectors(fAngles, fVelocity, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fVelocity, fVelocity);
	ScaleVector(fVelocity, fForce);
	
	if(bAdd) {
		static Float:fMainVelocity[3];
		GetEntPropVector(iEntity, Prop_Data, "m_vecAbsVelocity", fMainVelocity);
		
		fVelocity[0] += fMainVelocity[0];
		fVelocity[1] += fMainVelocity[1];
		fVelocity[2] += fMainVelocity[2];
	}
	
	if(fMax > 0.0) {
		fVelocity[0] = ((fVelocity[0] > fMax) ? fMax : fVelocity[0]);
		fVelocity[1] = ((fVelocity[1] > fMax) ? fMax : fVelocity[1]);
		fVelocity[2] = ((fVelocity[2] > fMax) ? fMax : fVelocity[2]);
	}
	
	TeleportEntity(iEntity, NULL_VECTOR, NULL_VECTOR, fVelocity);
}
