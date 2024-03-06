#define PLUGIN_VERSION		"1.1"
#define PLUGIN_PREFIX		"l4d2_"
#define PLUGIN_NAME			"melee_fx"
#define PLUGIN_NAME_FULL	"[L4D2] Melee Weapon Effects"
#define PLUGIN_DESCRIPTION	"more realism(?) for melee weapons"
#define PLUGIN_AUTHOR		"NoroHime"
#define PLUGIN_LINK			"https://forums.alliedmods.net/showthread.php?t=340716"

/**
 *	v1.0 just released; 6-December-2022
 *	v1.1 add new effects, fixes:
 *		- new particles smoke space warping, red spark, blinking, flashing, black hole, hugespark, rain spark, explosion smoke, explosion,
 *		- fix unknown sitaution some melee throw log through L4DD; 9-December-2022
 */

#include <sdkhooks>
#include <sourcemod>
#include <sdktools>

bool bLateLoad = false;

// L4D2 only
enum L4D2IntMeleeWeaponAttributes
{
	L4D2IMWA_DamageFlags,
	L4D2IMWA_RumbleEffect,
	MAX_SIZE_L4D2IntMeleeWeaponAttributes
};

#define IsEntity(%1) (2048 > %1 > MaxClients)

native int L4D2_GetIntMeleeAttribute(int id, L4D2IntMeleeWeaponAttributes attr);
native int L4D2_GetMeleeWeaponIndex(const char[] weaponName);
forward Action L4D2_MeleeGetDamageForVictim(int client, int weapon, int victim, float &damage);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {

	if (late)
		bLateLoad = true;

	MarkNativeAsOptional("L4D2_GetIntMeleeAttribute");
	MarkNativeAsOptional("L4D2_GetMeleeWeaponIndex");

	return APLRes_Success;
}

public void OnAllPluginsLoaded() {
	// Requires Left 4 DHooks Direct
	if( !LibraryExists("left4dhooks") ) {
		LogMessage	("\n==========\nError: You must install \"[L4D & L4D2] Left 4 DHooks Direct\" to run this plugin: https://forums.alliedmods.net/showthread.php?t=321696\n==========\n");
		SetFailState("\n==========\nError: You must install \"[L4D & L4D2] Left 4 DHooks Direct\" to run this plugin: https://forums.alliedmods.net/showthread.php?t=321696\n==========\n");
	}
}

public Plugin myinfo = {
	name =			PLUGIN_NAME_FULL,
	author =		PLUGIN_AUTHOR,
	description =	PLUGIN_DESCRIPTION,
	version =		PLUGIN_VERSION,
	url = 			PLUGIN_LINK
};

ConVar cSlash;		int iSlash;
ConVar cBurn;		int iBurn;
ConVar cClub;		int iClub;
ConVar cBlast;		int iBlast;
ConVar cPosMin;		float flPosMin;
ConVar cPosMax;		float flPosMax;

public void OnPluginStart() {

	CreateConVar					(PLUGIN_NAME, PLUGIN_VERSION,			"Version of " ... PLUGIN_NAME_FULL, FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cSlash =			CreateConVar(PLUGIN_NAME ... "_slash", "1",			"apply which effects for melee has DMG_SLASH 1=spark(temp ents) 2=incendiary ammo 4=explosive\nammo 8=space warping 16=smoke 32=red spark 64=blinking 128=flashing 256=black hole\n512=hugespark 1024=rain spark 2048=explosion smoke 4096=explosion", FCVAR_NOTIFY);
	cBurn =				CreateConVar(PLUGIN_NAME ... "_burn", "2",			"apply which effects for melee has DMG_BURN, detail see *_slash", FCVAR_NOTIFY);
	cClub =				CreateConVar(PLUGIN_NAME ... "_club", "4",			"apply which effects for melee has DMG_CLUB, detail see *_slash", FCVAR_NOTIFY);
	cBlast =			CreateConVar(PLUGIN_NAME ... "_blast", "4",			"apply which effects for melee has DMG_BLAST, detail see *_slash", FCVAR_NOTIFY);
	cPosMin =			CreateConVar(PLUGIN_NAME ... "_pos_min", "30.0",	"min random effects start height", FCVAR_NOTIFY);
	cPosMax =			CreateConVar(PLUGIN_NAME ... "_pos_max", "60.0",	"max random effects start height", FCVAR_NOTIFY);

	AutoExecConfig(true, PLUGIN_PREFIX ... PLUGIN_NAME);

	cSlash.AddChangeHook(OnConVarChanged);
	cBurn.AddChangeHook(OnConVarChanged);
	cClub.AddChangeHook(OnConVarChanged);
	cBlast.AddChangeHook(OnConVarChanged);
	cPosMin.AddChangeHook(OnConVarChanged);
	cPosMax.AddChangeHook(OnConVarChanged);

	ApplyCvars();

	// Late Load
	if (bLateLoad) {

		for (int i = MaxClients + 1; i < 2048; i++)
			if (IsValidEntity(i)) {
				char classname[32];
				GetEntityClassname(i, classname, sizeof(classname));

				if (classname[0] == 'w' && strcmp(classname, "weapon_melee") == 0)
					OnMeleeSpawnPost(i);
			}
	}
}

void ApplyCvars() {

	iSlash = cSlash.IntValue;
	iBurn = cBurn.IntValue;
	iClub = cClub.IntValue;
	iBlast = cBlast.IntValue;
	flPosMin = cPosMin.FloatValue;
	flPosMax = cPosMax.FloatValue;
}
 
void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	ApplyCvars();
}

public void OnConfigsExecuted() {
	ApplyCvars();
}

int iTypeDamage [2048];

#define IMPACT_EXPLOSION_AMMO_WORLD		"impact_explosive_ammo_world"
#define IMPACT_EXPLOSION_AMMO_BODY		"impact_explosive_ammo_small"
#define IMPACT_INCENDIARY_AMMO			"impact_incendiary_generic"
#define PARTICLE_EXPLOSION				"weapon_pipebomb_child_shrapnel"
#define PARTICLE_SMOKE_EXPLOSION		"weapon_pipebomb_generic_smokestreak_parent"
#define PARTICLE_SPARK_RAIN				"weapon_pipebomb_child_sparks2"
#define PARTICLE_HUGESPARK				"weapon_pipebomb_child_sparks3"
#define PARTICLE_BLACKHOLE				"weapon_pipebomb_child_explosion"
#define PARTICLE_FLASHING				"weapon_pipebomb_child_flash_mod"
#define PARTICLE_BLINKING				"weapon_pipebomb_blinking_light"
#define PARTICLE_SPARK_RED				"weapon_pipebomb_child_sparks"
#define PARTICLE_EXPLOSIVEAMMO_SMOKE	"impact_explosive_smoke"
#define PARTICLE_EXPLOSIVEAMMO_WARP		"impact_explosive_warp"

public void OnMapStart() {

	PrecacheParticle(IMPACT_EXPLOSION_AMMO_WORLD);
	PrecacheParticle(IMPACT_EXPLOSION_AMMO_BODY);
	PrecacheParticle(IMPACT_INCENDIARY_AMMO);
	PrecacheParticle(PARTICLE_EXPLOSION);
	PrecacheParticle(PARTICLE_SMOKE_EXPLOSION);
	PrecacheParticle(PARTICLE_SPARK_RAIN);
	PrecacheParticle(PARTICLE_HUGESPARK);
	PrecacheParticle(PARTICLE_BLACKHOLE);
	PrecacheParticle(PARTICLE_BLINKING);
	PrecacheParticle(PARTICLE_SPARK_RED);
	PrecacheParticle(PARTICLE_EXPLOSIVEAMMO_SMOKE);
	PrecacheParticle(PARTICLE_EXPLOSIVEAMMO_WARP);
}

public void OnEntityCreated(int entity, const char[] classname) {

	if ( classname[0] == 'w' && strcmp(classname, "weapon_melee") == 0 )
		SDKHook(entity, SDKHook_SpawnPost, OnMeleeSpawnPost);
}

void OnMeleeSpawnPost(int entity) {

	static char name_melee[32];
	GetEntPropString( entity, Prop_Data, "m_strMapSetScriptName", name_melee, sizeof(name_melee));

	int id = L4D2_GetMeleeWeaponIndex(name_melee);

	if (id != -1)
		iTypeDamage[entity] = L4D2_GetIntMeleeAttribute(id, L4D2IMWA_DamageFlags);
}


public void OnEntityDestroyed(int entity) {

	if (IsEntity(entity))
		iTypeDamage[entity] = 0;
}

enum {
	EFFECT_SPARKS =		(1 << 0),
	EFFECT_INCENDIARY =	(1 << 1),
	EFFECT_EXPLOSIVE =	(1 << 2),
	EFFECT_SPACEWARP =	(1 << 3),
	EFFECT_SMOKE =		(1 << 4),
	EFFECT_SPARKRED =	(1 << 5),
	EFFECT_BLINKING =	(1 << 6),
	EFFECT_FLASHING =	(1 << 7),
	EFFECT_BLACKHOLE =	(1 << 8),
	EFFECT_HUGESPARK =	(1 << 9),
	EFFECT_SPARKRAIN =	(1 << 10),
	EFFECT_SMOKEEXPL =	(1 << 11),
	EFFECT_EXPLOSION =	(1 << 12),
}

public Action L4D2_MeleeGetDamageForVictim(int client, int weapon, int victim, float &damage) {

	int damagetype = iTypeDamage[weapon];

	if ( victim && damagetype ) {

		int effects;
		float vPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecOrigin", vPos);
		vPos[2] += GetRandomFloat(flPosMin, flPosMax);

		if (damagetype & DMG_SLASH)
			effects = iSlash

		if (damagetype & DMG_BURN)
			effects = iBurn

		if (damagetype & DMG_CLUB)
			effects = iClub

		if (damagetype & DMG_BLAST)
			effects = iBlast

		if (effects & EFFECT_SPARKS) {

			float vAngles[3], vDir[3];
			GetClientEyeAngles(client, vAngles);
			GetAngleVectors(vAngles, vDir, NULL_VECTOR, NULL_VECTOR);

			TE_SetupSparks(vPos, vDir, GetRandomInt(1, 2), GetRandomInt(1, 2));
			TE_SendToAll();
		}

		if (effects & EFFECT_EXPLOSIVE) {

			if (HasEntProp(victim, Prop_Data, "m_iMaxHealth") && GetEntProp(victim, Prop_Data, "m_iMaxHealth") > 1)
				CreateParticle(IMPACT_EXPLOSION_AMMO_BODY, vPos);
			else
				CreateParticle(IMPACT_EXPLOSION_AMMO_WORLD, vPos);
		}

		if (effects & EFFECT_INCENDIARY)
			CreateParticle(IMPACT_INCENDIARY_AMMO, vPos);

		if (effects & EFFECT_SPACEWARP)
			CreateParticle(PARTICLE_EXPLOSIVEAMMO_WARP, vPos);

		if (effects & EFFECT_SMOKE)
			CreateParticle(PARTICLE_EXPLOSIVEAMMO_SMOKE, vPos);

		if (effects & EFFECT_SPARKRED)
			CreateParticle(PARTICLE_SPARK_RED, vPos);

		if (effects & EFFECT_BLINKING)
			CreateParticle(PARTICLE_BLINKING, vPos);

		if (effects & EFFECT_FLASHING)
			CreateParticle(PARTICLE_FLASHING, vPos);

		if (effects & EFFECT_BLACKHOLE)
			CreateParticle(PARTICLE_BLACKHOLE, vPos);

		if (effects & EFFECT_HUGESPARK)
			CreateParticle(PARTICLE_HUGESPARK, vPos);

		if (effects & EFFECT_SPARKRAIN)
			CreateParticle(PARTICLE_SPARK_RAIN, vPos);

		if (effects & EFFECT_SMOKEEXPL)
			CreateParticle(PARTICLE_SMOKE_EXPLOSION, vPos);

		if (effects & EFFECT_EXPLOSION)
			CreateParticle(PARTICLE_EXPLOSION, vPos);
	}
	
	return Plugin_Continue;
}

void CreateParticle(const char[] name_particle, float vPos[3]) {

	int particle = CreateEntityByName("info_particle_system");

	if (particle != -1) {

		TeleportEntity(particle, vPos, NULL_VECTOR, NULL_VECTOR);

		DispatchKeyValue(particle, "effect_name", name_particle);
		DispatchKeyValue(particle, "targetname", "particle");

		DispatchSpawn(particle);
		ActivateEntity(particle);

		AcceptEntityInput(particle, "start");

		SetVariantString("OnUser1 !self:Kill::3.0:-1");
		AcceptEntityInput(particle, "AddOutput");
		AcceptEntityInput(particle, "FireUser1");
	}
}

// Taken from Silvers
void PrecacheParticle(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
		table = FindStringTable("ParticleEffectNames");
 
	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX ) {
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}