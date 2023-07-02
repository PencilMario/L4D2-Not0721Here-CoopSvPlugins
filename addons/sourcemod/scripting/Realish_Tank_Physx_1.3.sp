#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.3"

public Plugin:myinfo =
{
	name = "Realish_Tank_Phyx",
	author = "Ludastar (Armonic)",
	description = "Add's knockback to all attacks to survivor's from tanks",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2429846#post2429846"
};

static ZOMBIECLASS_TANK;
static bool:g_bAllowHurt = false;

static bool:g_bRockPhyx = false;
static bool:g_bIncapKnockBack = false;
static bool:g_bKnockBackPreIncap = false;
static Float:g_fRockForce = 666.6;
static bool:g_bAllDisabled = false;

static Handle:hCvar_RockPhyx = INVALID_HANDLE;
static Handle:hCvar_IncapKnockBack = INVALID_HANDLE;
static Handle:hCvar_KnockBackPreIncap = INVALID_HANDLE;
static Handle:hCvar_fRockForce = INVALID_HANDLE;

static iRockRef[MAXPLAYERS+1];
static bHitByRock[2048+1];

#define ENABLE_AUTOEXEC true

public OnPluginStart()
{
	decl String:sGameName[12];
	GetGameFolderName(sGameName, sizeof(sGameName));
	if(StrEqual(sGameName, "left4dead"))
	ZOMBIECLASS_TANK = 5;
	else if(StrEqual(sGameName, "left4dead2"))
	ZOMBIECLASS_TANK = 8;
	else
	SetFailState("This plugin only runs on Left 4 Dead and Left 4 Dead 2!");
	
	CreateConVar("Realish_Tank_Phyx", PLUGIN_VERSION, "Version of Realish_Tank_Phyxs", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_REPLICATED);
	
	hCvar_RockPhyx = CreateConVar("rtp_rockphyx", "1", "Enable or Disable RockPhyx", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_IncapKnockBack = CreateConVar("rtp_incapknockBack", "1", "Enable or Disable Incapped slap", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_KnockBackPreIncap = CreateConVar("rtp_KnockBackPreIncap", "1", "Enable or Disable Pre incapped flying", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_fRockForce = CreateConVar("rtp_rockforce", "800.0", "Force of the rock, very high values send you flying very fast&far", FCVAR_NOTIFY, true, 1.0, true, 2147483647.0);
	
	HookConVarChange(hCvar_RockPhyx, eConvarChanged);
	HookConVarChange(hCvar_IncapKnockBack, eConvarChanged);
	HookConVarChange(hCvar_KnockBackPreIncap, eConvarChanged);
	HookConVarChange(hCvar_fRockForce, eConvarChanged);
	
	#if ENABLE_AUTOEXEC
	AutoExecConfig(true, "Realish_Tank_Phyx");
	#endif
	
	CvarsChanged();
}

static CvarsChanged()
{
	g_bRockPhyx = GetConVarInt(hCvar_RockPhyx) > 0;
	g_bIncapKnockBack = GetConVarInt(hCvar_IncapKnockBack) > 0;
	g_bKnockBackPreIncap = GetConVarInt(hCvar_KnockBackPreIncap) > 0;
	g_fRockForce = GetConVarFloat(hCvar_fRockForce);
	
	if(!g_bRockPhyx && !g_bIncapKnockBack && !g_bKnockBackPreIncap)
		g_bAllDisabled = true;
	else
		g_bAllDisabled = false;
}

public Action:eOnTakeDamage(iVictim, &iAttacker, &iInflictor, &Float:fDamage, &iDamagetype)
{
	if(g_bAllDisabled)
	return Plugin_Continue;
	
	if(g_bAllowHurt)
	return Plugin_Continue;
	
	if(iAttacker < 1 || iAttacker > MaxClients || !IsClientInGame(iAttacker) || GetClientTeam(iAttacker) != 3 || GetEntProp(iAttacker, Prop_Send, "m_zombieClass") != ZOMBIECLASS_TANK)
	return Plugin_Continue;
	
	if(!IsSurvivorAlive(iVictim))
	return Plugin_Continue;
	
	
	static String:sWeapon[18];
	if(g_bRockPhyx)
	{
		GetEntityClassname(iInflictor, sWeapon, sizeof(sWeapon));
		if(sWeapon[0] == 't' && StrEqual(sWeapon, "tank_rock", false))
		{
			bHitByRock[iInflictor] = GetClientUserId(iVictim);
			iRockRef[iVictim] = EntIndexToEntRef(iInflictor);
			
			static Float:fPos[3];
			GetEntPropVector(iVictim, Prop_Send, "m_vecOrigin", fPos);
			static Handle:trace;
			trace = TR_TraceRayFilterEx(fPos, Float:{270.0, 0.0, 0.0}, MASK_SHOT, RayType_Infinite, _TraceFilter);
			
			static Float:fEnd[3];
			TR_GetEndPosition(fEnd, trace); // retrieve our trace endpoint
			CloseHandle(trace);
			trace = INVALID_HANDLE;
			
			static Float:fDist;
			fDist = GetVectorDistance(fPos, fEnd);
			
			if(fDist > 150.0)
			{
				fPos[2] += 40.0;
				TeleportEntity(iVictim, fPos, NULL_VECTOR, NULL_VECTOR);
			}
			else if(fDist > 125.0)
			{
				fPos[2] += 25.0;
				TeleportEntity(iVictim, fPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	
	GetClientWeapon(iAttacker, sWeapon, sizeof(sWeapon));// i do a classname check so it will work on l4d1 also
	if(StrContains(sWeapon, "tank_claw", false) == -1)// for l4d1 support also
	return Plugin_Continue;
	
	if(GetEntProp(iVictim, Prop_Send, "m_isIncapacitated", 1))
	{
		if(!g_bIncapKnockBack)
			return Plugin_Continue;
		
		static Float:fAngles[3];
		GetClientEyeAngles(iAttacker, fAngles);
		
		fAngles[0] = 340.0;
		SetEntityFlags(iVictim, GetEntityFlags(iVictim) & ~FL_ONGROUND);
		Entity_PushForce(iVictim, float(GetTankThrowForce()), fAngles, 0.0, false);
		return Plugin_Continue;
	}
	else
	{
		if(!g_bKnockBackPreIncap)
		return Plugin_Continue;
	
		static iDamage;
		iDamage = RoundFloat(fDamage);
		static iHealth;
		iHealth = L4D_GetPlayerTempHealth(iVictim) + GetEntProp(iVictim, Prop_Send, "m_iHealth");
		
		if(iHealth > iDamage)
		return Plugin_Continue;
		
		new Handle:hPack = CreateDataPack();
		WritePackCell(hPack, GetClientUserId(iVictim));
		WritePackCell(hPack, iDamage);
		WritePackCell(hPack, iAttacker);
		
		RequestFrame(NextFrame, hPack);
		return Plugin_Handled;
	}
}

public NextFrame(any:hPack)
{
	ResetPack(hPack);
	static iVictim;
	iVictim = GetClientOfUserId(ReadPackCell(hPack));
	
	if(!IsSurvivorAlive(iVictim))
	{
		CloseHandle(hPack);
		return;
	}
	
	static iDamage;
	iDamage = ReadPackCell(hPack);
	static iAttacker;
	iAttacker = ReadPackCell(hPack);
	CloseHandle(hPack);
	
	if(iAttacker < 1)
		iAttacker = 0;
		
	g_bAllowHurt = true;
	Entity_Hurt(iVictim, iDamage, iAttacker, DMG_VEHICLE);//we use point hurt here to prevent anybugs so we use the normal damage system instead
	g_bAllowHurt = false;// prevent endless loop with sdkhooks
	
}

public OnEntityDestroyed(iEntity)
{
	if(iEntity < MaxClients+1 || iEntity > 2048)
		return;
	
	static iClient;
	iClient = GetClientOfUserId(bHitByRock[iEntity]);
	if(iClient < 1 || iClient > MaxClients)
		return;
	
	if(!IsValidEntRef(iRockRef[iClient]))
		return;
	
	static Float:fClient[3];
	GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", fClient);
	
	static Float:fRockPos[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fRockPos);
	
	static Float:fAngles[3];
	static Float:fAimVector[3];
	MakeVectorFromPoints(fRockPos, fClient, fAimVector);
	GetVectorAngles(fAimVector, fAngles);
	
	if(fAngles[0] < 270.0)
	fAngles[0] = 360.0;
	if(fAngles[0] < 340.0)
	fAngles[0] = 340.0;
	
	Entity_PushForce(iClient, g_fRockForce, fAngles, 0.0, false); //this does not seem to work in OnTakeDamage hook but works here quite strange
	bHitByRock[iEntity] = -1;
}

static IsSurvivorAlive(iClient)
{
	if(iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
		return false;
	return true;
}

static bool:Entity_Hurt(entity, damage, attacker=0, damageType=DMG_GENERIC, const String:fakeClassName[]="")
{
	static point_hurt = INVALID_ENT_REFERENCE;
	
	if (point_hurt == INVALID_ENT_REFERENCE || !IsValidEntity(point_hurt)) {
		point_hurt = EntIndexToEntRef(Entity_Create("point_hurt"));
		
		if (point_hurt == INVALID_ENT_REFERENCE) {
			return false;
		}
		
		DispatchSpawn(point_hurt);
	}
	
	AcceptEntityInput(point_hurt, "TurnOn");
	SetEntProp(point_hurt, Prop_Data, "m_nDamage", damage);
	SetEntProp(point_hurt, Prop_Data, "m_bitsDamageType", damageType);
	Entity_PointHurtAtTarget(point_hurt, entity);
	
	if (fakeClassName[0] != '\0') {
		Entity_SetClassName(point_hurt, fakeClassName);
	}
	
	AcceptEntityInput(point_hurt, "Hurt", attacker);
	AcceptEntityInput(point_hurt, "TurnOff");
	
	if (fakeClassName[0] != '\0') {
		Entity_SetClassName(point_hurt, "point_hurt");
	}
	
	return true;
}

static Entity_Create(const String:className[], ForceEdictIndex=-1)
{
	if (ForceEdictIndex != -1 && IsValidEntity(ForceEdictIndex)) {
		return INVALID_ENT_REFERENCE;
	}
	
	return CreateEntityByName(className, ForceEdictIndex);
}

static Entity_PointHurtAtTarget(entity, target, const String:name[]="")
{
	decl String:targetName[128];
	Entity_GetTargetName(entity, targetName, sizeof(targetName));
	
	if (name[0] == '\0') {
		
		if (targetName[0] == '\0') {
			// Let's generate our own name
			Format(
					targetName,
					sizeof(targetName),
					"_smlib_Entity_PointHurtAtTarget:%d",
					target
					);
		}
	}
	else {
		strcopy(targetName, sizeof(targetName), name);
	}
	
	DispatchKeyValue(entity, "DamageTarget", targetName);
	Entity_SetName(target, targetName);
}

static Entity_SetName(entity, const String:name[], any:...)
{
	decl String:format[128];
	VFormat(format, sizeof(format), name, 3);
	
	return DispatchKeyValue(entity, "targetname", format);
}

static Entity_GetTargetName(entity, String:buffer[], size)
{
	return GetEntPropString(entity, Prop_Data, "m_target", buffer, size);
}

static Entity_SetClassName(entity, const String:className[])
{
	return DispatchKeyValue(entity, "classname", className);
}

static L4D_GetPlayerTempHealth(client)
{
	static Handle:painPillsDecayCvar = INVALID_HANDLE;
	if (painPillsDecayCvar == INVALID_HANDLE)
	{
		painPillsDecayCvar = FindConVar("pain_pills_decay_rate");
		if (painPillsDecayCvar == INVALID_HANDLE)
		{
			SetFailState("pain_pills_decay_rate not found.");
		}
	}
	
	static tempHealth;
	tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(painPillsDecayCvar))) - 1;
	return tempHealth < 0 ? 0 : tempHealth;
}

static GetTankThrowForce()
{
	static Handle:hThrowForce = INVALID_HANDLE;
	if (hThrowForce == INVALID_HANDLE)
	{
		hThrowForce = FindConVar("z_tank_throw_force");
		if (hThrowForce == INVALID_HANDLE)
			SetFailState("z_tank_throw_force not found.");
	}
	
	return GetConVarInt(hThrowForce);
}

public bool:_TraceFilter(iEntity, contentsMask)
{
	decl String:sClassName[11];
	GetEntityClassname(iEntity, sClassName, sizeof(sClassName));
	
	if(sClassName[0] != 'i' || !StrEqual(sClassName, "infected"))
	{
		return false;
	}
	else if(sClassName[0] != 'w' || !StrEqual(sClassName, "witch"))
	{
		return false;
	}
	else if(iEntity > 0 && iEntity <= MaxClients)
	{
		return false;
	}
	return true;
	
}

public OnClientPutInServer(iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamage, eOnTakeDamage);
}

public eConvarChanged(Handle:hCvar, const String:sOldVal[], const String:sNewVal[])
{
	CvarsChanged();
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

static bool:IsValidEntRef(iEntRef)
{
	return (iEntRef != 0 && EntRefToEntIndex(iEntRef) != INVALID_ENT_REFERENCE);
}