/** ===================================================================================================================

								Lista De Cambios Por Ernecio
								
	[03/10/2020] Versión 1.3.5
	
	- Actualizado bajo las nuevas declaraciones de SM 1.10
	- Correcion de función nativa GetEntityRenderColor (Se sigue utilizando la función).
	- Creadas nuevas definiciones de tipos de Tanks en base a la función GetEntityRenderColor.
	
	[03/15/2020] Versión 1.3.6
	
	- Soporte para Left Dead 1 añadido (13 Tans Trabajando de 16).
	- Correcion SDKCallVomitOnPlayer para Left 4 Dead 1 directamente desde su direcotio.
	- Soporte completo de Gravity Tank en Left 4 Dead 1 ya que al morir no se eliminabá el campo de atracción.

	[30/30/2020] Versión 1.3.7
	
	- Soporte extra para SM 1.10
	- Correción de constantes en los Events.
	- Agragados comprobadores de indice de usuario y entidades.
	- Correción de sombras en Shield Tank.
	
	[04/25/2020] Versión 1.3.8 ( 16 Tanks Funcionando Para Left 4 Dead 1 )
	
	- Corrección de sangría suelta en algunas secciones del código.
	- Soporte para Ice Tank en Left 4 Dead 1
	- Nuevos efectos visuales y de sonido para Ice Tank.
	- Al no existir el infectado Jockey en Left 4 Dead 1 este se ha cambiado por Hunter, dando como resultado a
	  Hunter Tank, tomando el lugar de Jockey Tank, esto no afecta a Left 4 Dead 2.
	- Al no existir el infectado Spitter en Left 4 Dead 1, se ha agregadó un Super Tank similar en 
	  Left 4 Dead 1, Dando como resultado a Nauseating Tank, que se basa en la misma idea de Spitter Tank, cuando
	  el Tank arroja una roca esta explota con vomito de Boomer, esto no afecta a Left 4 Dead 2.
	- Soporte en SDKHook_OnTakeDamage para Fire Tank en Left 4 Dead 1 (Habilidad de ataque especial al recibir daño).
	- Soporte en SDKHook_OnTakeDamage para Meteor Tank en Left 4 Dead 1 (Habilidad de ataque especial al recibir daño).
	- Optimizaciones y funciones nativas de Damage Types, esto en SDKHook_OnTakeDamage.
	- Firmas actualizadas para Left 4 Dead 1/2.
	
	- Se corrigió errores en consola de Meteor Tank.
	- Se ha quitado la funcion de aumento de infectados(z_max_player_zombies) porque porduce conflictos con 
	  configuraciones del archivo Server.cfg y y en mi caso con el Plugin Super Versus.
	  
	[05/08/2020] Versión 1.3.9
	
	- Corrección para Heal Tank, problemas en bits para Left 4 Dead 1, corrección cuando el Tank supera mas 31K de HP 
	  su vida de hace negativa al recuperar vida a su punto máximo de nuevo.
	  
	[05/11/2020] Versión 1.4.0
	
	- Corrección de advertencias en consola por Tabla de datos fuera de rango para Cobalt Tank 
	  (Advertencias solo en Left 4 Dead 1, no afecta Left 4 Dead 2).
	- Agregadas funciones de recuperación de indice de usuario ha Shock Tank y Meteor Tank.
	
	=================================================================================================================== */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>

#define PLUGIN_VERSION "1.4.0"

#define FFADE_IN 0x0001
#define FFADE_OUT 0x0002
#define FFADE_MODULATE 0x0004
#define FFADE_STAYOUT 0x0008
#define FFADE_PURGE 0x0010

/* Particles */
#define PARTICLE_SPAWN		"smoker_smokecloud"
#define PARTICLE_FIRE		"aircraft_destroy_fastFireTrail"
#define PARTICLE_WARP		"electrical_arc_01_system"
#define PARTICLE_ICE		"steam_manhole"
//#define PARTICLE_WATER	"water_splash"
#define PARTICLE_WATER 		"weapon_pipebomb_water_splash"
#define PARTICLE_SPIT		"spitter_areaofdenial_glow2"
#define PARTICLE_SPITPROJ	"spitter_projectile"
#define PARTICLE_ELEC		"electrical_arc_01_parent"
#define PARTICLE_BLOOD		"boomer_explode_D"
#define PARTICLE_EXPLODE	"boomer_explode"
#define PARTICLE_METEOR		"smoke_medium_01"
#define PARTICLE_EMBERS 	"barrel_fly_embers"

#define PARTICLE_DEATH	"gas_explosion_main"
#define SOUND_EXPLODE	"animation/bombing_run_01.wav"

/* Tank Types By Render Color */
#define FIRE_TANK 		12800
#define GRAVITY_TANK 	333435
#define ICE_TANK 		0100170
#define COBALT_TANK 	0105255 // 105255
#define METEOR_TANK 	1002525
#define JUMPER_TANK 	2002550
#define JOCKEY_TANK 	2552000
#define SMASHER_TANK 	7080100
#define SPAWN_TANK 		7595105
#define SPITTER_TANK 	12115128
#define HEAL_TANK 		100255200
#define GHOST_TANK 		100100100
#define SHOCK_TANK 		100165255
#define WARP_TANK 		130130255
#define SHIELD_TANK 	135205255
#define WITCH_TANK 		255200255
#define DEFAULT_TANK 	255255255

#define ZC_TANK         8

/*Arrays*/
int TankAlive[MAXPLAYERS+1];
int TankAbility[MAXPLAYERS+1];
int Rock[MAXPLAYERS+1];
int ShieldsUp[MAXPLAYERS+1];
int PlayerSpeed[MAXPLAYERS+1];

/*
	Super Tanks:
	1 - Spawn
	2 - Smasher
	3 - Warp
	4 - Meteor
	5 - Spitter/Nauseating
	6 - Heal
	7 - Fire
	8 - Ice
	9 - Jockey/Hunter
	10 - Ghost
	11 - Shock
	12 - Witch
	13 - Shield
	14 - Cobalt
	15 - Jumper
	16 - Gravity
*/

/*Misc*/
int iTankWave;
int iNumTanks;
int iFrame;
int iTick;

/*Handles*/
ConVar hSuperTanksEnabled;
ConVar hDisplayHealthCvar;
ConVar hWave1Cvar;
ConVar hWave2Cvar;
ConVar hWave3Cvar;
ConVar hFinaleOnly;
ConVar hDefaultTanks;
ConVar hGamemodeCvar;

ConVar hDefaultOverride;
ConVar hDefaultExtraHealth;
ConVar hDefaultSpeed;
ConVar hDefaultThrow;
ConVar hDefaultFireImmunity;

ConVar hSpawnEnabled;
ConVar hSpawnExtraHealth;
ConVar hSpawnSpeed;
ConVar hSpawnThrow;
ConVar hSpawnFireImmunity;
ConVar hSpawnCommonAmount;
ConVar hSpawnCommonInterval;

ConVar hSmasherEnabled;
ConVar hSmasherExtraHealth;
ConVar hSmasherSpeed;
ConVar hSmasherThrow;
ConVar hSmasherFireImmunity;
ConVar hSmasherMaimDamage;
ConVar hSmasherCrushDamage;
ConVar hSmasherRemoveBody;

ConVar hWarpEnabled;
ConVar hWarpExtraHealth;
ConVar hWarpSpeed;
ConVar hWarpThrow;
ConVar hWarpFireImmunity;
ConVar hWarpTeleportDelay;

ConVar hMeteorEnabled;
ConVar hMeteorExtraHealth;
ConVar hMeteorSpeed;
ConVar hMeteorThrow;
ConVar hMeteorFireImmunity;
ConVar hMeteorStormDelay;
ConVar hMeteorStormDamage;

ConVar hSpitterEnabled;
ConVar hSpitterExtraHealth;
ConVar hSpitterSpeed;
ConVar hSpitterThrow;
ConVar hSpitterFireImmunity;

ConVar hHealEnabled;
ConVar hHealExtraHealth;
ConVar hHealSpeed;
ConVar hHealThrow;
ConVar hHealFireImmunity;
ConVar hHealHealthCommons;
ConVar hHealHealthSpecials;
ConVar hHealHealthTanks;

ConVar hFireEnabled;
ConVar hFireExtraHealth;
ConVar hFireSpeed;
ConVar hFireThrow;
ConVar hFireFireImmunity;

ConVar hIceEnabled;
ConVar hIceExtraHealth;
ConVar hIceSpeed;
ConVar hIceThrow;
ConVar hIceFireImmunity;

ConVar hJockeyEnabled;
ConVar hJockeyExtraHealth;
ConVar hJockeySpeed;
ConVar hJockeyThrow;
ConVar hJockeyFireImmunity;

ConVar hGhostEnabled;
ConVar hGhostExtraHealth;
ConVar hGhostSpeed;
ConVar hGhostThrow;
ConVar hGhostFireImmunity;
ConVar hGhostDisarm;

ConVar hShockEnabled;
ConVar hShockExtraHealth;
ConVar hShockSpeed;
ConVar hShockThrow;
ConVar hShockFireImmunity;
ConVar hShockStunDamage;
ConVar hShockStunMovement;

ConVar hWitchEnabled;
ConVar hWitchExtraHealth;
ConVar hWitchSpeed;
ConVar hWitchThrow;
ConVar hWitchFireImmunity;
ConVar hWitchMaxWitches;

ConVar hShieldEnabled;
ConVar hShieldExtraHealth;
ConVar hShieldSpeed;
ConVar hShieldThrow;
ConVar hShieldFireImmunity;
ConVar hShieldShieldsDownInterval;

ConVar hCobaltEnabled;
ConVar hCobaltExtraHealth;
ConVar hCobaltSpeed;
ConVar hCobaltThrow;
ConVar hCobaltFireImmunity;
ConVar hCobaltSpecialSpeed;

ConVar hJumperEnabled;
ConVar hJumperExtraHealth;
ConVar hJumperSpeed;
ConVar hJumperThrow;
ConVar hJumperFireImmunity;
ConVar hJumperJumpDelay;

ConVar hGravityEnabled;
ConVar hGravityExtraHealth;
ConVar hGravitySpeed;
ConVar hGravityThrow;
ConVar hGravityFireImmunity;
ConVar hGravityPullForce;

static Handle SDKSpitBurst = INVALID_HANDLE;
static Handle SDKVomitOnPlayer = INVALID_HANDLE;

bool bSuperTanksEnabled;
int iWave1Cvar;
int iWave2Cvar;
int iWave3Cvar;
bool bFinaleOnly;
bool bDisplayHealthCvar;
bool bDefaultTanks;

bool bTankEnabled[16+1];
int iTankExtraHealth[16+1];
float flTankSpeed[16+1];
float flTankThrow[16+1];
bool bTankFireImmunity[16+1];

bool bDefaultOverride;
int iSpawnCommonAmount;
int iSpawnCommonInterval;
int iSmasherMaimDamage;
int iSmasherCrushDamage;
bool bSmasherRemoveBody;
int iWarpTeleportDelay;
int iMeteorStormDelay;
float flMeteorStormDamage;
int iHealHealthCommons;
int iHealHealthSpecials;
int iHealHealthTanks;
bool bGhostDisarm;
int iShockStunDamage;
float flShockStunMovement;
int iWitchMaxWitches;
float flShieldShieldsDownInterval;
float flCobaltSpecialSpeed;
int iJumperJumpDelay;
float flGravityPullForce;

static bool bL4DTwo;
static int FCVAR_CUSTOM_REPLICATED;

public Plugin myinfo = 
{
	name 		= "[L4D1 AND L4D2] Super Tanks",
	author 		= "Machine, Modified By Ernecio",
	description = "Provides Sixteen Unique Types Of Tanks.",
	version 	= PLUGIN_VERSION,
	url 		= "<URL>"
}

/**
 * Called on pre plugin start.
 *
 * @param hMyself        Handle to the plugin.
 * @param bLate          Whether or not the plugin was loaded "late" (after map load).
 * @param sError         Error message buffer in case load failed.
 * @param Error_Max      Maximum number of characters for error message buffer.
 * @return               APLRes_Success for load success, APLRes_Failure or APLRes_SilentFailure otherwise.
 */
public APLRes AskPluginLoad2( Handle hMyself, bool bLate, char[] sError, int Error_Max )
{	
	EngineVersion Engine = GetEngineVersion();
	if ( Engine != Engine_Left4Dead && Engine != Engine_Left4Dead2 )
	{
		strcopy( sError, Error_Max, "This plugin \"Super Tanks\" only runs in the \"Left 4 Dead 1/2\" Games!" );
		return APLRes_SilentFailure;
	}
	
	bL4DTwo = ( Engine == Engine_Left4Dead2 );
	return APLRes_Success;
}

public void OnPluginStart()
{

	if ( bL4DTwo )
		FCVAR_CUSTOM_REPLICATED = FCVAR_REPLICATED;
	else 
		FCVAR_CUSTOM_REPLICATED = FCVAR_DONTRECORD;
	
	CreateConVar("st_version", PLUGIN_VERSION, "Super Tanks Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	hSuperTanksEnabled 		= CreateConVar("st_on", 					"1", 		"Is Super Tanks enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hDisplayHealthCvar 		= CreateConVar("st_display_health",			"0", 		"Display tanks health in crosshair?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hWave1Cvar 				= CreateConVar("st_wave1_tanks", 			"1", 		"Default number of tanks in the 1st wave of finale.", FCVAR_NOTIFY,true,0.0,true,5.0);
	hWave2Cvar 				= CreateConVar("st_wave2_tanks", 			"2", 		"Default number of tanks in the 2nd wave of finale.", FCVAR_NOTIFY,true,0.0,true,5.0);
	hWave3Cvar 				= CreateConVar("st_wave3_tanks", 			"1", 		"Default number of tanks in the finale escape.", FCVAR_NOTIFY,true,0.0,true,5.0);
	hFinaleOnly 			= CreateConVar("st_finale_only", 			"0", 		"Create Super Tanks in finale only?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hDefaultTanks 			= CreateConVar("st_default_tanks", 			"0", 		"Only use default tanks?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hGamemodeCvar 			= FindConVar("mp_gamemode");
	
	hDefaultOverride 		= CreateConVar("st_default_override", 		"0", 		"Setting this to 1 will allow further customization to default tanks.", FCVAR_NOTIFY,true,0.0,true,1.0);
	hDefaultExtraHealth 	= CreateConVar("st_default_extra_health", 	"0", 		"Default Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hDefaultSpeed 			= CreateConVar("st_default_speed", 			"1.0", 		"Default Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hDefaultThrow 			= CreateConVar("st_default_throw", 			"5.0", 		"Default Tanks rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hDefaultFireImmunity 	= CreateConVar("st_default_fire_immunity", 	"0", 		"Are Default Tanks immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	
	hSpawnEnabled 			= CreateConVar("st_spawn", 					"1", 		"Is Spawn Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpawnExtraHealth 		= CreateConVar("st_spawn_extra_health", 	"0", 		"Spawn Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSpawnSpeed 			= CreateConVar("st_spawn_speed", 			"1.0", 		"Spawn Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hSpawnThrow 			= CreateConVar("st_spawn_throw", 			"10.0", 	"Spawn Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hSpawnFireImmunity 		= CreateConVar("st_spawn_fire_immunity", 	"0", 		"Is Spawn Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpawnCommonAmount 		= CreateConVar("st_spawn_common_amount", 	"8", 		"Number of common infected spawned by the Spawn Tank.", FCVAR_NOTIFY,true,1.0,true,50.0);
	hSpawnCommonInterval 	= CreateConVar("st_spawn_common_interval", 	"20", 		"Spawn Tanks common infected spawn interval.", FCVAR_NOTIFY,true,1.0,true,60.0);

	hSmasherEnabled 		= CreateConVar("st_smasher", 				"1", 		"Is Smasher Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hSmasherExtraHealth 	= CreateConVar("st_smasher_extra_health", 	"0", 		"Smasher Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSmasherSpeed 			= CreateConVar("st_smasher_speed", 			"0.70", 	"Smasher Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hSmasherThrow 			= CreateConVar("st_smasher_throw", 			"30.0", 	"Smasher Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hSmasherFireImmunity 	= CreateConVar("st_smasher_fire_immunity", 	"0", 		"Is Smasher Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hSmasherMaimDamage 		= CreateConVar("st_smasher_maim_damage", 	"1", 		"Smasher Tanks maim attack will set victims health to this amount.", FCVAR_NOTIFY,true,1.0,true,99.0);
	hSmasherCrushDamage 	= CreateConVar("st_smasher_crush_damage", 	"30", 		"Smasher Tanks claw attack damage.", FCVAR_NOTIFY,true,0.0,true,1000.0);
	hSmasherRemoveBody 		= CreateConVar("st_smasher_remove_body", 	"0", 		"Smasher Tanks crush attack will remove survivors death body?", FCVAR_NOTIFY|FCVAR_CUSTOM_REPLICATED, true, 0.0, true, 1.0 );

	hWarpEnabled 			= CreateConVar("st_warp", 					"1", 		"Is Warp Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hWarpExtraHealth 		= CreateConVar("st_warp_extra_health", 		"0", 		"Warp Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hWarpSpeed 				= CreateConVar("st_warp_speed", 			"1.0", 		"Warp Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hWarpThrow 				= CreateConVar("st_warp_throw", 			"9.0", 		"Warp Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hWarpFireImmunity 		= CreateConVar("st_warp_fire_immunity", 	"0", 		"Is Warp Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hWarpTeleportDelay 		= CreateConVar("st_warp_teleport_delay", 	"30", 		"Warp Tanks Teleport Delay Interval.", FCVAR_NOTIFY,true,1.0,true,60.0);

	hMeteorEnabled 			= CreateConVar("st_meteor", 				"1", 		"Is Meteor Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hMeteorExtraHealth 		= CreateConVar("st_meteor_extra_health", 	"0", 		"Meteor Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hMeteorSpeed 			= CreateConVar("st_meteor_speed", 			"1.0", 		"Meteor Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hMeteorThrow 			= CreateConVar("st_meteor_throw", 			"10.0", 	"Meteor Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hMeteorFireImmunity 	= CreateConVar("st_meteor_fire_immunity", 	"0", 		"Is Meteor Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hMeteorStormDelay 		= CreateConVar("st_meteor_storm_delay", 	"30", 		"Meteor Tanks Meteor Storm Delay Interval.", FCVAR_NOTIFY,true,1.0,true,60.0);
	hMeteorStormDamage 		= CreateConVar("st_meteor_storm_damage", 	"5.0", 		"Meteor Tanks falling meteor damage.", FCVAR_NOTIFY,true,0.0,true,1000.0);

	hSpitterEnabled 		= CreateConVar("st_spitter", 				"1", 		bL4DTwo ? "Is Spitter Tank Enabled?" : "Is Nauseating Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpitterExtraHealth 	= CreateConVar("st_spitter_extra_health", 	"0", 		bL4DTwo ? "Spitter Tanks receive this many additional hitpoints." : "Nauseating Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSpitterSpeed 			= CreateConVar("st_spitter_speed", 			"1.0", 		bL4DTwo ? "Spitter Tanks default movement speed." : "Nauseating Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hSpitterThrow 			= CreateConVar("st_spitter_throw", 			"6.0", 		bL4DTwo ? "Spitter Tank rock throw ability interval." : "Nauseating Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hSpitterFireImmunity 	= CreateConVar("st_spitter_fire_immunity", 	"1", 		bL4DTwo ? "Is Spitter Tank immune to fire?" : "Is Nauseating Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);

	hHealEnabled 			= CreateConVar("st_heal", 					"1", 		"Is Heal Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hHealExtraHealth 		= CreateConVar("st_heal_extra_health", 		"0", 		"Heal Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hHealSpeed 				= CreateConVar("st_heal_speed", 			"1.0", 		"Heal Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hHealThrow 				= CreateConVar("st_heal_throw", 			"15.0", 	"Heal Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hHealFireImmunity 		= CreateConVar("st_heal_fire_immunity", 	"0", 		"Is Heal Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hHealHealthCommons 		= CreateConVar("st_heal_health_commons", 	"50", 		"Heal Tanks receive this much health per second from being near a common infected.", FCVAR_NOTIFY,true,0.0,true,1000.0);
	hHealHealthSpecials 	= CreateConVar("st_heal_health_specials", 	"50", 		"Heal Tanks receive this much health per second from being near a special infected.", FCVAR_NOTIFY,true,0.0,true,1000.0);
	hHealHealthTanks 		= CreateConVar("st_heal_health_tanks", 		"50", 		"Heal Tanks receive this much health per second from being near another tank.", FCVAR_NOTIFY,true,0.0,true,1000.0);

	hFireEnabled 			= CreateConVar("st_fire", 					"1", 		"Is Fire Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hFireExtraHealth 		= CreateConVar("st_fire_extra_health", 		"0", 		"Fire Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hFireSpeed 				= CreateConVar("st_fire_speed", 			"1.0", 		"Fire Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hFireThrow 				= CreateConVar("st_fire_throw", 			"6.0", 		"Fire Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hFireFireImmunity 		= CreateConVar("st_fire_fire_immunity", 	"1", 		"Is Fire Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);

	hIceEnabled 			= CreateConVar("st_ice", 					"1", 		"Is Ice Tank Enabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	hIceExtraHealth 		= CreateConVar("st_ice_extra_health", 		"0", 		"Ice Tanks receive this many additional hitpoints.", FCVAR_NOTIFY, true, 0.0, true, 100000.0 );
	hIceSpeed 				= CreateConVar("st_ice_speed", 				"1.0", 		"Ice Tanks default movement speed.", FCVAR_NOTIFY, true, 0.0, true, 2.0 );
	hIceThrow 				= CreateConVar("st_ice_throw", 				"6.0", 		"Ice Tank rock throw ability interval.", FCVAR_NOTIFY, true, 0.0, true, 999.0 );
	hIceFireImmunity 		= CreateConVar("st_ice_fire_immunity", 		"1", 		"Is Ice Tank immune to fire?", FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	hJockeyEnabled 			= CreateConVar("st_jockey", 				"1", 		bL4DTwo ? "Is Jockey Tank Enabled?" : "Is Hunter Tank Enabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hJockeyExtraHealth 		= CreateConVar("st_jockey_extra_health", 	"0", 		bL4DTwo ? "Jockey Tanks receive this many additional hitpoints." : "Hunter Tanks receive this many additional hitpoints.", FCVAR_NOTIFY, true, 0.0, true, 100000.0);
	hJockeySpeed 			= CreateConVar("st_jockey_speed", 			"1.33", 	bL4DTwo ? "Jockey Tanks default movement speed." : "Hunter Tanks default movement speed.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	hJockeyThrow 			= CreateConVar("st_jockey_throw", 			"7.0", 		bL4DTwo ? "Jockey Tank jockey throw ability interval." : "Hunter Tank hunter throw ability interval.", FCVAR_NOTIFY,true, 0.0, true, 999.0);
	hJockeyFireImmunity 	= CreateConVar("st_jockey_fire_immunity", 	"1", 		bL4DTwo ? "Is Jockey Tank immune to fire?" : "Is Hunter Tank immune to fire?" , FCVAR_NOTIFY, true, 0.0, true, 1.0);

	hGhostEnabled 			= CreateConVar("st_ghost", 					"1", 		"Is Ghost Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hGhostExtraHealth 		= CreateConVar("st_ghost_extra_health", 	"0", 		"Ghost Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hGhostSpeed 			= CreateConVar("st_ghost_speed", 			"1.0", 		"Ghost Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hGhostThrow 			= CreateConVar("st_ghost_throw", 			"15.0", 	"Ghost Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hGhostFireImmunity 		= CreateConVar("st_ghost_fire_immunity", 	"0", 		"Is Ghost Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hGhostDisarm 			= CreateConVar("st_ghost_disarm", 			"0", 		"Does Ghost Tank have a chance of disarming an attacking melee survivor?", FCVAR_NOTIFY,true,0.0,true,1.0);

	hShockEnabled 			= CreateConVar("st_shock", 					"1", 		"Is Shock Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hShockExtraHealth 		= CreateConVar("st_shock_extra_health", 	"0", 		"Shock Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hShockSpeed 			= CreateConVar("st_shock_speed", 			"1.0", 		"Shock Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hShockThrow 			= CreateConVar("st_shock_throw", 			"10.0", 	"Shock Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hShockFireImmunity 		= CreateConVar("st_shock_fire_immunity", 	"0", 		"Is Shock Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hShockStunDamage 		= CreateConVar("st_shock_stun_damage", 		"5", 		"Shock Tanks stun damage.", FCVAR_NOTIFY,true,0.0,true,1000.0);
	hShockStunMovement 		= CreateConVar("st_shock_stun_movement", 	"0.50", 	"Shock Tanks stun reduce survivors speed to this amount.", FCVAR_NOTIFY,true,0.0,true,1.0);

	hWitchEnabled 			= CreateConVar("st_witch", 					"1", 		"Is Witch Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hWitchExtraHealth 		= CreateConVar("st_witch_extra_health", 	"0", 		"Witch Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hWitchSpeed 			= CreateConVar("st_witch_speed", 			"1.0", 		"Witch Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hWitchThrow 			= CreateConVar("st_witch_throw", 			"7.0", 		"Witch Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hWitchFireImmunity 		= CreateConVar("st_witch_fire_immunity", 	"0", 		"Is Witch Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hWitchMaxWitches 		= CreateConVar("st_witch_max_witches", 		"10",	 	"Maximum number of witches converted from common infected by the Witch Tank.", FCVAR_NOTIFY,true,0.0,true,100.0);

	hShieldEnabled 			= CreateConVar("st_shield", 				"1", 		"Is Shield Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hShieldExtraHealth 		= CreateConVar("st_shield_extra_health", 	"0", 		"Shield Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hShieldSpeed 			= CreateConVar("st_shield_speed", 			"1.0", 		"Shield Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hShieldThrow 			= CreateConVar("st_shield_throw", 			"8.0", 		"Shield Tank propane throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hShieldFireImmunity 	= CreateConVar("st_shield_fire_immunity", 	"1", 		"Is Shield Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hShieldShieldsDownInterval = CreateConVar("st_shield_shields_down_interval", "45.0", "When Shield Tanks shields are disabled, how long before shields activate again.", FCVAR_NOTIFY,true,0.1,true,60.0);

	hCobaltEnabled 			= CreateConVar("st_cobalt", 				"1", 		"Is Cobalt Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hCobaltExtraHealth 		= CreateConVar("st_cobalt_extra_health", 	"0", 		"Cobalt Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hCobaltSpeed 			= CreateConVar("st_cobalt_speed", 			"1.0", 		"Cobalt Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hCobaltThrow 			= CreateConVar("st_cobalt_throw", 			"999.0", 	"Cobalt Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hCobaltFireImmunity 	= CreateConVar("st_cobalt_fire_immunity", 	"0", 		"Is Cobalt Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hCobaltSpecialSpeed 	= CreateConVar("st_cobalt_Special_speed", 	"1.80", 	"Cobalt Tanks movement value when speeding towards a survivor.", FCVAR_NOTIFY,true,1.0,true,5.0);

	hJumperEnabled 			= CreateConVar("st_jumper", 				"1", 		"Is Jumper Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hJumperExtraHealth 		= CreateConVar("st_jumper_extra_health", 	"0", 		"Jumper Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hJumperSpeed 			= CreateConVar("st_jumper_speed", 			"1.0", 		"Jumper Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hJumperThrow 			= CreateConVar("st_jumper_throw", 			"999.0", 	"Jumper Tank rock throw ability interval.", FCVAR_NOTIFY,true,0.0,true,999.0);
	hJumperFireImmunity 	= CreateConVar("st_jumper_fire_immunity", 	"0", 		"Is Jumper Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hJumperJumpDelay 		= CreateConVar("st_jumper_jump_delay", 		"3", 		"Jumper Tanks delay interval to jump again.", FCVAR_NOTIFY,true,1.0,true,60.0);

	hGravityEnabled 		= CreateConVar("st_gravity", 				"1", 		"Is Gravity Tank Enabled?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hGravityExtraHealth 	= CreateConVar("st_gravity_extra_health", 	"0", 		"Gravity Tanks receive this many additional hitpoints.", FCVAR_NOTIFY,true,0.0,true,100000.0);
	hGravitySpeed 			= CreateConVar("st_gravity_speed", 			"1.0", 		"Gravity Tanks default movement speed.", FCVAR_NOTIFY,true,0.0,true,2.0);
	hGravityThrow 			= CreateConVar("st_gravity_throw", 			"10.0", 	"Gravity Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hGravityFireImmunity 	= CreateConVar("st_gravity_fire_immunity", 	"1", 		"Is Gravity Tank immune to fire?", FCVAR_NOTIFY,true,0.0,true,1.0);
	hGravityPullForce 		= CreateConVar("st_gravity_pull_force", 	"-20.0", 	"Gravity Tanks pull force value. Higher negative values equals greater pull forces.", FCVAR_NOTIFY,true,-200.0,true,0.0);

	bSuperTanksEnabled = hSuperTanksEnabled.BoolValue;
	bDisplayHealthCvar = hDisplayHealthCvar.BoolValue;
	iWave1Cvar = hWave1Cvar.IntValue;
	iWave2Cvar = hWave2Cvar.IntValue;
	iWave3Cvar = hWave3Cvar.IntValue;
	bFinaleOnly = hFinaleOnly.BoolValue;
	bDefaultTanks = hDefaultTanks.BoolValue;
	bDefaultOverride = hDefaultOverride.BoolValue;

	bTankEnabled[1] = hSpawnEnabled.BoolValue;
	bTankEnabled[2] = hSmasherEnabled.BoolValue;
	bTankEnabled[3] = hWarpEnabled.BoolValue;
	bTankEnabled[4] = hMeteorEnabled.BoolValue;
	bTankEnabled[5] = hSpitterEnabled.BoolValue;
	bTankEnabled[6] = hHealEnabled.BoolValue;
	bTankEnabled[7] = hFireEnabled.BoolValue;
	bTankEnabled[8] = hIceEnabled.BoolValue;
	bTankEnabled[9] = hJockeyEnabled.BoolValue;
	bTankEnabled[10] = hGhostEnabled.BoolValue;
	bTankEnabled[11] = hShockEnabled.BoolValue;
	bTankEnabled[12] = hWitchEnabled.BoolValue;
	bTankEnabled[13] = hShieldEnabled.BoolValue;
	bTankEnabled[14] = hCobaltEnabled.BoolValue;
	bTankEnabled[15] = hJumperEnabled.BoolValue;
	bTankEnabled[16] = hGravityEnabled.BoolValue;

	iTankExtraHealth[0] = hDefaultExtraHealth.IntValue;
	iTankExtraHealth[1] = hSpawnExtraHealth.IntValue;
	iTankExtraHealth[2] = hSmasherExtraHealth.IntValue;
	iTankExtraHealth[3] = hWarpExtraHealth.IntValue;
	iTankExtraHealth[4] = hMeteorExtraHealth.IntValue;
	iTankExtraHealth[5] = hSpitterExtraHealth.IntValue;
	iTankExtraHealth[6] = hHealExtraHealth.IntValue;
	iTankExtraHealth[7] = hFireExtraHealth.IntValue;
	iTankExtraHealth[8] = hIceExtraHealth.IntValue;
	iTankExtraHealth[9] = hJockeyExtraHealth.IntValue;
	iTankExtraHealth[10] = hGhostExtraHealth.IntValue;
	iTankExtraHealth[11] = hShockExtraHealth.IntValue;
	iTankExtraHealth[12] = hWitchExtraHealth.IntValue;
	iTankExtraHealth[13] = hShieldExtraHealth.IntValue;
	iTankExtraHealth[14] = hCobaltExtraHealth.IntValue;
	iTankExtraHealth[15] = hJumperExtraHealth.IntValue;
	iTankExtraHealth[16] = hGravityExtraHealth.IntValue;

	flTankSpeed[0] = hDefaultSpeed.FloatValue;
	flTankSpeed[1] = hSpawnSpeed.FloatValue;
	flTankSpeed[2] = hSmasherSpeed.FloatValue;
	flTankSpeed[3] = hWarpSpeed.FloatValue;
	flTankSpeed[4] = hMeteorSpeed.FloatValue;
	flTankSpeed[5] = hSpitterSpeed.FloatValue;
	flTankSpeed[6] = hHealSpeed.FloatValue;
	flTankSpeed[7] = hFireSpeed.FloatValue;
	flTankSpeed[8] = hIceSpeed.FloatValue;
	flTankSpeed[9] = hJockeySpeed.FloatValue;
	flTankSpeed[10] = hGhostSpeed.FloatValue;
	flTankSpeed[11] = hShockSpeed.FloatValue;
	flTankSpeed[12] = hWitchSpeed.FloatValue;
	flTankSpeed[13] = hShieldSpeed.FloatValue;
	flTankSpeed[14] = hCobaltSpeed.FloatValue;
	flTankSpeed[15] = hJumperSpeed.FloatValue;
	flTankSpeed[16] = hGravitySpeed.FloatValue;

	flTankThrow[0] = hDefaultThrow.FloatValue;
	flTankThrow[1] = hSpawnThrow.FloatValue;
	flTankThrow[2] = hSmasherThrow.FloatValue;
	flTankThrow[3] = hWarpThrow.FloatValue;
	flTankThrow[4] = hMeteorThrow.FloatValue;
	flTankThrow[5] = hSpitterThrow.FloatValue;
	flTankThrow[6] = hHealThrow.FloatValue;
	flTankThrow[7] = hFireThrow.FloatValue;
	flTankThrow[8] = hIceThrow.FloatValue;
	flTankThrow[9] = hJockeyThrow.FloatValue;
	flTankThrow[10] = hGhostThrow.FloatValue;
	flTankThrow[11] = hShockThrow.FloatValue;
	flTankThrow[12] = hWitchThrow.FloatValue;
	flTankThrow[13] = hShieldThrow.FloatValue;
	flTankThrow[14] = hCobaltThrow.FloatValue;
	flTankThrow[15] = hJumperThrow.FloatValue;
	flTankThrow[16] = hGravityThrow.FloatValue;

	bTankFireImmunity[0] = hDefaultFireImmunity.BoolValue;
	bTankFireImmunity[1] = hSpawnFireImmunity.BoolValue;
	bTankFireImmunity[2] = hSmasherFireImmunity.BoolValue;
	bTankFireImmunity[3] = hWarpFireImmunity.BoolValue;
	bTankFireImmunity[4] = hMeteorFireImmunity.BoolValue;
	bTankFireImmunity[5] = hSpitterFireImmunity.BoolValue;
	bTankFireImmunity[6] = hHealFireImmunity.BoolValue;
	bTankFireImmunity[7] = hFireFireImmunity.BoolValue;
	bTankFireImmunity[8] = hIceFireImmunity.BoolValue;
	bTankFireImmunity[9] = hJockeyFireImmunity.BoolValue;
	bTankFireImmunity[10] = hGhostFireImmunity.BoolValue;
	bTankFireImmunity[11] = hShockFireImmunity.BoolValue;
	bTankFireImmunity[12] = hWitchFireImmunity.BoolValue;
	bTankFireImmunity[13] = hShieldFireImmunity.BoolValue;
	bTankFireImmunity[14] = hCobaltFireImmunity.BoolValue;
	bTankFireImmunity[15] = hJumperFireImmunity.BoolValue;
	bTankFireImmunity[16] = hGravityFireImmunity.BoolValue;

	iSpawnCommonAmount = hSpawnCommonAmount.IntValue;
	iSpawnCommonInterval = hSpawnCommonInterval.IntValue;
	iSmasherMaimDamage = hSmasherMaimDamage.IntValue;
	iSmasherCrushDamage = hSmasherCrushDamage.IntValue;
	bSmasherRemoveBody = hSmasherRemoveBody.BoolValue;
	iWarpTeleportDelay = hWarpTeleportDelay.IntValue;
	iMeteorStormDelay = hMeteorStormDelay.IntValue;
	flMeteorStormDamage = hMeteorStormDamage.FloatValue;
	iHealHealthCommons = hHealHealthCommons.IntValue;
	iHealHealthSpecials = hHealHealthSpecials.IntValue;
	iHealHealthTanks = hHealHealthTanks.IntValue;
	bGhostDisarm = hGhostDisarm.BoolValue;
	iShockStunDamage = hShockStunDamage.IntValue;
	flShockStunMovement = hShockStunMovement.FloatValue;
	iWitchMaxWitches = hWitchMaxWitches.IntValue;
	flShieldShieldsDownInterval = hShieldShieldsDownInterval.FloatValue;
	flCobaltSpecialSpeed = hCobaltSpecialSpeed.FloatValue;
	iJumperJumpDelay = hJumperJumpDelay.IntValue;
	flGravityPullForce = hGravityPullForce.FloatValue;

	hSuperTanksEnabled.AddChangeHook( SuperTanksCvarChanged );
	hDisplayHealthCvar.AddChangeHook( SuperTanksSettingsChanged );
	hWave1Cvar.AddChangeHook( SuperTanksSettingsChanged );
	hWave2Cvar.AddChangeHook( SuperTanksSettingsChanged );
	hWave3Cvar.AddChangeHook( SuperTanksSettingsChanged );
	hFinaleOnly.AddChangeHook( SuperTanksSettingsChanged);
	hDefaultTanks.AddChangeHook( SuperTanksSettingsChanged );
	hDefaultOverride.AddChangeHook( DefaultTanksSettingsChanged );
	hGamemodeCvar.AddChangeHook( GamemodeCvarChanged );

	hSpawnEnabled.AddChangeHook( TanksSettingsChanged );
	hSmasherEnabled.AddChangeHook( TanksSettingsChanged );
	hWarpEnabled.AddChangeHook( TanksSettingsChanged );
	hMeteorEnabled.AddChangeHook( TanksSettingsChanged );
	hSpitterEnabled.AddChangeHook( TanksSettingsChanged );
	hHealEnabled.AddChangeHook( TanksSettingsChanged );
	hFireEnabled.AddChangeHook( TanksSettingsChanged );
	hIceEnabled.AddChangeHook( TanksSettingsChanged );
	hJockeyEnabled.AddChangeHook( TanksSettingsChanged );
	hGhostEnabled.AddChangeHook( TanksSettingsChanged );
	hShockEnabled.AddChangeHook( TanksSettingsChanged );
	hWitchEnabled.AddChangeHook( TanksSettingsChanged );
	hShieldEnabled.AddChangeHook( TanksSettingsChanged );
	hCobaltEnabled.AddChangeHook( TanksSettingsChanged );
	hJumperEnabled.AddChangeHook( TanksSettingsChanged );
	hGravityEnabled.AddChangeHook( TanksSettingsChanged );

	hDefaultExtraHealth.AddChangeHook( TanksSettingsChanged );
	hSpawnExtraHealth.AddChangeHook( TanksSettingsChanged );
	hSmasherExtraHealth.AddChangeHook( TanksSettingsChanged );
	hWarpExtraHealth.AddChangeHook( TanksSettingsChanged );
	hMeteorExtraHealth.AddChangeHook( TanksSettingsChanged );
	hSpitterExtraHealth.AddChangeHook( TanksSettingsChanged );
	hHealExtraHealth.AddChangeHook( TanksSettingsChanged );
	hFireExtraHealth.AddChangeHook( TanksSettingsChanged );
	hIceExtraHealth.AddChangeHook( TanksSettingsChanged );
	hJockeyExtraHealth.AddChangeHook( TanksSettingsChanged );
	hGhostExtraHealth.AddChangeHook( TanksSettingsChanged );
	hShockExtraHealth.AddChangeHook( TanksSettingsChanged );
	hWitchExtraHealth.AddChangeHook( TanksSettingsChanged );
	hShieldExtraHealth.AddChangeHook( TanksSettingsChanged );
	hCobaltExtraHealth.AddChangeHook( TanksSettingsChanged );
	hJumperExtraHealth.AddChangeHook( TanksSettingsChanged );
	hGravityExtraHealth.AddChangeHook( TanksSettingsChanged );

	hDefaultSpeed.AddChangeHook( TanksSettingsChanged );
	hSpawnSpeed.AddChangeHook( TanksSettingsChanged );
	hSmasherSpeed.AddChangeHook( TanksSettingsChanged );
	hWarpSpeed.AddChangeHook( TanksSettingsChanged );
	hMeteorSpeed.AddChangeHook( TanksSettingsChanged );
	hSpitterSpeed.AddChangeHook( TanksSettingsChanged );
	hHealSpeed.AddChangeHook( TanksSettingsChanged );
	hFireSpeed.AddChangeHook( TanksSettingsChanged );
	hIceSpeed.AddChangeHook( TanksSettingsChanged );
	hJockeySpeed.AddChangeHook( TanksSettingsChanged );
	hGhostSpeed.AddChangeHook( TanksSettingsChanged );
	hShockSpeed.AddChangeHook( TanksSettingsChanged );
	hWitchSpeed.AddChangeHook( TanksSettingsChanged );
	hShieldSpeed.AddChangeHook( TanksSettingsChanged );
	hCobaltSpeed.AddChangeHook( TanksSettingsChanged );
	hJumperSpeed.AddChangeHook( TanksSettingsChanged );
	hGravitySpeed.AddChangeHook( TanksSettingsChanged);

	hDefaultThrow.AddChangeHook( TanksSettingsChanged );
	hSpawnThrow.AddChangeHook( TanksSettingsChanged );
	hSmasherThrow.AddChangeHook( TanksSettingsChanged );
	hWarpThrow.AddChangeHook( TanksSettingsChanged );
	hMeteorThrow.AddChangeHook( TanksSettingsChanged );
	hSpitterThrow.AddChangeHook( TanksSettingsChanged );
	hHealThrow.AddChangeHook( TanksSettingsChanged );
	hFireThrow.AddChangeHook( TanksSettingsChanged );
	hIceThrow.AddChangeHook( TanksSettingsChanged );
	hJockeyThrow.AddChangeHook( TanksSettingsChanged );
	hGhostThrow.AddChangeHook( TanksSettingsChanged );
	hShockThrow.AddChangeHook( TanksSettingsChanged );
	hWitchThrow.AddChangeHook( TanksSettingsChanged );
	hShieldThrow.AddChangeHook( TanksSettingsChanged );
	hCobaltThrow.AddChangeHook( TanksSettingsChanged );
	hJumperThrow.AddChangeHook( TanksSettingsChanged );
	hGravityThrow.AddChangeHook( TanksSettingsChanged);

	hDefaultFireImmunity.AddChangeHook( TanksSettingsChanged );
	hSpawnFireImmunity.AddChangeHook( TanksSettingsChanged );
	hSmasherFireImmunity.AddChangeHook( TanksSettingsChanged );
	hWarpFireImmunity.AddChangeHook( TanksSettingsChanged );
	hMeteorFireImmunity.AddChangeHook( TanksSettingsChanged );
	hSpitterFireImmunity.AddChangeHook( TanksSettingsChanged );
	hHealFireImmunity.AddChangeHook( TanksSettingsChanged );
	hFireFireImmunity.AddChangeHook( TanksSettingsChanged );
	hIceFireImmunity.AddChangeHook( TanksSettingsChanged );
	hJockeyFireImmunity.AddChangeHook( TanksSettingsChanged );
	hGhostFireImmunity.AddChangeHook( TanksSettingsChanged );
	hShockFireImmunity.AddChangeHook( TanksSettingsChanged );
	hWitchFireImmunity.AddChangeHook( TanksSettingsChanged );
	hShieldFireImmunity.AddChangeHook( TanksSettingsChanged );
	hCobaltFireImmunity.AddChangeHook( TanksSettingsChanged );
	hJumperFireImmunity.AddChangeHook( TanksSettingsChanged );
	hGravityFireImmunity.AddChangeHook( TanksSettingsChanged);

	hSpawnCommonAmount.AddChangeHook( TanksSettingsChanged );
	hSpawnCommonInterval.AddChangeHook( TanksSettingsChanged );
	hSmasherMaimDamage.AddChangeHook( TanksSettingsChanged );
	hSmasherCrushDamage.AddChangeHook( TanksSettingsChanged );
	hWarpTeleportDelay.AddChangeHook( TanksSettingsChanged );
	hMeteorStormDelay.AddChangeHook( TanksSettingsChanged );
	hMeteorStormDamage.AddChangeHook( TanksSettingsChanged );
	hHealHealthCommons.AddChangeHook( TanksSettingsChanged );
	hHealHealthSpecials.AddChangeHook( TanksSettingsChanged );
	hHealHealthTanks.AddChangeHook( TanksSettingsChanged );
	hGhostDisarm.AddChangeHook( TanksSettingsChanged );
	hShockStunDamage.AddChangeHook( TanksSettingsChanged );
	hShockStunMovement.AddChangeHook( TanksSettingsChanged );
	hWitchMaxWitches.AddChangeHook( TanksSettingsChanged );
	hShieldShieldsDownInterval.AddChangeHook( TanksSettingsChanged );
	hCobaltSpecialSpeed.AddChangeHook( TanksSettingsChanged );
	hJumperJumpDelay.AddChangeHook( TanksSettingsChanged );
	hGravityPullForce.AddChangeHook( TanksSettingsChanged );

	HookEvent("ability_use", Ability_Use);
	HookEvent("finale_escape_start", Finale_Escape_Start);
	HookEvent("finale_start", Finale_Start, EventHookMode_Pre);
	HookEvent("finale_vehicle_leaving", Finale_Vehicle_Leaving);
	HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
	HookEvent("player_death", Player_Death);
	HookEvent("tank_spawn", Tank_Spawn);
	HookEvent("round_end", Round_End);
	HookEvent("round_start", Round_Start);

	CreateTimer(0.1,TimerUpdate01, _, TIMER_REPEAT);
	CreateTimer(1.0,TimerUpdate1, _, TIMER_REPEAT);

	InitSDKCalls();
	InitStartUp();

	AutoExecConfig( true, "SuperTanks" );
}

//=============================
// StartUp
//=============================
stock void InitSDKCalls()
{
	Handle ConfigFile = LoadGameConfigFile("SuperTanks");
	Handle MySDKCall = INVALID_HANDLE;

	/////////////
	//SpitBurst//
	/////////////
	if ( bL4DTwo )
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CSpitterProjectile_Detonate");
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		MySDKCall = EndPrepSDKCall();
		if (MySDKCall == INVALID_HANDLE)
		{
			SetFailState("Cant initialize CSpitterProjectile_Detonate SDKCall");
		}
		SDKSpitBurst = CloneHandle(MySDKCall, SDKSpitBurst);
	}
	
	/////////////////
	//VomitOnPlayer//
	/////////////////
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	if (MySDKCall == INVALID_HANDLE)
	{
		SetFailState("Cant initialize CTerrorPlayer_OnVomitedUpon SDKCall");
	}
	SDKVomitOnPlayer = CloneHandle(MySDKCall, SDKVomitOnPlayer);

	CloseHandle(ConfigFile);
	CloseHandle(MySDKCall);
}

stock void SDKCallSpitBurst(int client)
{
	SDKCall(SDKSpitBurst, client, true);
}

stock void SDKCallVomitOnPlayer(int victim, int attacker)
{
	SDKCall(SDKVomitOnPlayer, victim, attacker, true);
}

stock void InitStartUp()
{
	if (bSuperTanksEnabled)
	{
		char sGamemode[24];
		GetConVarString( FindConVar("mp_gamemode"), sGamemode, sizeof(sGamemode));
		if (!StrEqual(sGamemode, "versus", false) && !StrEqual(sGamemode, "coop", false) && !StrEqual(sGamemode, "survival", false))
		{
			PrintToServer("[SuperTanks] This plugin is only compatible in versus or coop gamemodes.");
			PrintToServer("[SuperTanks] Plugin Disabled.");
			hSuperTanksEnabled.SetBool( false );		
		}
	}
}

//=============================
// Events
//=============================
public void GamemodeCvarChanged(Handle hConvar, const char[] sOldValue, const char[] sNewValue)
{
	if (bSuperTanksEnabled)
	{
		if (hConvar == hGamemodeCvar)
		{
			if (StrEqual(sOldValue, sNewValue, false)) return;

			if (!StrEqual(sNewValue, "versus", false) && !StrEqual(sNewValue, "coop", false) && !StrEqual(sNewValue, "survival", false))
			{
				PrintToServer("[SuperTanks] This plugin is only compatible in versus, survival or coop gamemodes.");
				PrintToServer("[SuperTanks] Plugin Disabled.");
				hSuperTanksEnabled.SetBool( false );
			}
		}
	}
}

public void SuperTanksCvarChanged(Handle hConvar, const char[] sOldValue, const char[] sNewValue)
{
	if (hConvar == hSuperTanksEnabled)
	{
		int oldval = StringToInt( sOldValue );
		int newval = StringToInt( sNewValue );

		if (newval == oldval) return;

		if (newval == 1)
		{
			char sGamemode[24];
			GetConVarString(FindConVar("mp_gamemode"), sGamemode, sizeof(sGamemode));
			if (!StrEqual(sGamemode, "versus", false) && !StrEqual(sGamemode, "coop", false) && !StrEqual(sGamemode, "survival", false))
			{
				PrintToServer("[SuperTanks] This plugin is only compatible in versus or coop gamemodes.");
				PrintToServer("[SuperTanks] Plugin Disabled.");
				hSuperTanksEnabled.SetBool( false );		
			}	
		}
		bSuperTanksEnabled = hSuperTanksEnabled.BoolValue;
	}
}

public void SuperTanksSettingsChanged(Handle hConvar, const char[] sOldValue, const char[] sNewValue)
{
	bDisplayHealthCvar = hDisplayHealthCvar.BoolValue;
	iWave1Cvar = hWave1Cvar.IntValue;
	iWave2Cvar = hWave2Cvar.IntValue;
	iWave3Cvar = hWave3Cvar.IntValue;
	bFinaleOnly = hFinaleOnly.BoolValue;
	bDefaultTanks = hDefaultTanks.BoolValue;
}

public void DefaultTanksSettingsChanged(Handle hConvar, const char[] sOldValue, const char[] sNewValue)
{
	if (hConvar == hDefaultOverride)
	{
		int oldval = StringToInt(sOldValue);
		int newval = StringToInt(sNewValue);

		if (newval == oldval) return;

		if (newval == 0)
		{
			hDefaultExtraHealth.SetInt( 0 );
			hDefaultSpeed.SetFloat( 1.0 );
			hDefaultThrow.SetFloat( 5.0);
			hDefaultFireImmunity.SetBool( false );
		}
	}
	bDefaultOverride = hDefaultOverride.BoolValue;
}

public void TanksSettingsChanged(Handle hConvar, const char[] sOldValue, const char[] sNewValue)
{
	bTankEnabled[1] = hSpawnEnabled.BoolValue;
	bTankEnabled[2] = hSmasherEnabled.BoolValue;
	bTankEnabled[3] = hWarpEnabled.BoolValue;
	bTankEnabled[4] = hMeteorEnabled.BoolValue;
	bTankEnabled[5] = hSpitterEnabled.BoolValue;
	bTankEnabled[6] = hHealEnabled.BoolValue;
	bTankEnabled[7] = hFireEnabled.BoolValue;
	bTankEnabled[8] = hIceEnabled.BoolValue;
	bTankEnabled[9] = hJockeyEnabled.BoolValue;
	bTankEnabled[10] = hGhostEnabled.BoolValue;
	bTankEnabled[11] = hShockEnabled.BoolValue;
	bTankEnabled[12] = hWitchEnabled.BoolValue;
	bTankEnabled[13] = hShieldEnabled.BoolValue;
	bTankEnabled[14] = hCobaltEnabled.BoolValue;
	bTankEnabled[15] = hJumperEnabled.BoolValue;
	bTankEnabled[16] = hGravityEnabled.BoolValue;

	iTankExtraHealth[0] = hDefaultExtraHealth.IntValue;
	iTankExtraHealth[1] = hSpawnExtraHealth.IntValue;
	iTankExtraHealth[2] = hSmasherExtraHealth.IntValue;
	iTankExtraHealth[3] = hWarpExtraHealth.IntValue;
	iTankExtraHealth[4] = hMeteorExtraHealth.IntValue;
	iTankExtraHealth[5] = hSpitterExtraHealth.IntValue;
	iTankExtraHealth[6] = hHealExtraHealth.IntValue;
	iTankExtraHealth[7] = hFireExtraHealth.IntValue;
	iTankExtraHealth[8] = hIceExtraHealth.IntValue;
	iTankExtraHealth[9] = hJockeyExtraHealth.IntValue;
	iTankExtraHealth[10] = hGhostExtraHealth.IntValue;
	iTankExtraHealth[11] = hShockExtraHealth.IntValue;
	iTankExtraHealth[12] = hWitchExtraHealth.IntValue;
	iTankExtraHealth[13] = hShieldExtraHealth.IntValue;
	iTankExtraHealth[14] = hCobaltExtraHealth.IntValue;
	iTankExtraHealth[15] = hJumperExtraHealth.IntValue;
	iTankExtraHealth[16] = hGravityExtraHealth.IntValue;

	flTankSpeed[0] = hDefaultSpeed.FloatValue;
	flTankSpeed[1] = hSpawnSpeed.FloatValue;
	flTankSpeed[2] = hSmasherSpeed.FloatValue;
	flTankSpeed[3] = hWarpSpeed.FloatValue;
	flTankSpeed[4] = hMeteorSpeed.FloatValue;
	flTankSpeed[5] = hSpitterSpeed.FloatValue;
	flTankSpeed[6] = hHealSpeed.FloatValue;
	flTankSpeed[7] = hFireSpeed.FloatValue;
	flTankSpeed[8] = hIceSpeed.FloatValue;
	flTankSpeed[9] = hJockeySpeed.FloatValue;
	flTankSpeed[10] = hGhostSpeed.FloatValue;
	flTankSpeed[11] = hShockSpeed.FloatValue;
	flTankSpeed[12] = hWitchSpeed.FloatValue;
	flTankSpeed[13] = hShieldSpeed.FloatValue;
	flTankSpeed[14] = hCobaltSpeed.FloatValue;
	flTankSpeed[15] = hJumperSpeed.FloatValue;
	flTankSpeed[16] = hGravitySpeed.FloatValue;

	flTankThrow[0] = hDefaultThrow.FloatValue;
	flTankThrow[1] = hSpawnThrow.FloatValue;
	flTankThrow[2] = hSmasherThrow.FloatValue;
	flTankThrow[3] = hWarpThrow.FloatValue;
	flTankThrow[4] = hMeteorThrow.FloatValue;
	flTankThrow[5] = hSpitterThrow.FloatValue;
	flTankThrow[6] = hHealThrow.FloatValue;
	flTankThrow[7] = hFireThrow.FloatValue;
	flTankThrow[8] = hIceThrow.FloatValue;
	flTankThrow[9] = hJockeyThrow.FloatValue;
	flTankThrow[10] = hGhostThrow.FloatValue;
	flTankThrow[11] = hShockThrow.FloatValue;
	flTankThrow[12] = hWitchThrow.FloatValue;
	flTankThrow[13] = hShieldThrow.FloatValue;
	flTankThrow[14] = hCobaltThrow.FloatValue;
	flTankThrow[15] = hJumperThrow.FloatValue;
	flTankThrow[16] = hGravityThrow.FloatValue;

	bTankFireImmunity[0] = hDefaultFireImmunity.BoolValue;
	bTankFireImmunity[1] = hSpawnFireImmunity.BoolValue;
	bTankFireImmunity[2] = hSmasherFireImmunity.BoolValue;
	bTankFireImmunity[3] = hWarpFireImmunity.BoolValue;
	bTankFireImmunity[4] = hMeteorFireImmunity.BoolValue;
	bTankFireImmunity[5] = hSpitterFireImmunity.BoolValue;
	bTankFireImmunity[6] = hHealFireImmunity.BoolValue;
	bTankFireImmunity[7] = hFireFireImmunity.BoolValue;
	bTankFireImmunity[8] = hIceFireImmunity.BoolValue;
	bTankFireImmunity[9] = hJockeyFireImmunity.BoolValue;
	bTankFireImmunity[10] = hGhostFireImmunity.BoolValue;
	bTankFireImmunity[11] = hShockFireImmunity.BoolValue;
	bTankFireImmunity[12] = hWitchFireImmunity.BoolValue;
	bTankFireImmunity[13] = hShieldFireImmunity.BoolValue;
	bTankFireImmunity[14] = hCobaltFireImmunity.BoolValue;
	bTankFireImmunity[15] = hJumperFireImmunity.BoolValue;
	bTankFireImmunity[16] = hGravityFireImmunity.BoolValue;

	iSpawnCommonAmount = hSpawnCommonAmount.IntValue;
	iSpawnCommonInterval = hSpawnCommonInterval.IntValue;
	iSmasherMaimDamage = hSmasherMaimDamage.IntValue;
	iSmasherCrushDamage = hSmasherCrushDamage.IntValue;
	bSmasherRemoveBody = hSmasherRemoveBody.BoolValue;
	iWarpTeleportDelay = hWarpTeleportDelay.IntValue;
	iMeteorStormDelay = hMeteorStormDelay.IntValue;
	flMeteorStormDamage = hMeteorStormDamage.FloatValue;
	iHealHealthCommons = hHealHealthCommons.IntValue;
	iHealHealthSpecials = hHealHealthSpecials.IntValue;
	iHealHealthTanks = hHealHealthTanks.IntValue;
	bGhostDisarm = hGhostDisarm.BoolValue;
	iShockStunDamage = hShockStunDamage.IntValue;
	flShockStunMovement = hShockStunMovement.FloatValue;
	iWitchMaxWitches = hWitchMaxWitches.IntValue;
	flShieldShieldsDownInterval = hShieldShieldsDownInterval.FloatValue;
	flCobaltSpecialSpeed = hCobaltSpecialSpeed.FloatValue;
	iJumperJumpDelay = hJumperJumpDelay.IntValue;
	flGravityPullForce = hGravityPullForce.FloatValue;	
}

public void OnMapStart()
{
	PrecacheParticle(PARTICLE_SPAWN);
	PrecacheParticle(PARTICLE_FIRE);
	PrecacheParticle(PARTICLE_WARP);
	PrecacheParticle(PARTICLE_ICE);
	PrecacheParticle(PARTICLE_WATER); // New Particle.
	PrecacheParticle(PARTICLE_SPIT);
	PrecacheParticle(PARTICLE_SPITPROJ);
	PrecacheParticle(PARTICLE_ELEC);
	PrecacheParticle(PARTICLE_BLOOD);
	PrecacheParticle(PARTICLE_DEATH);
	PrecacheParticle(PARTICLE_EXPLODE);
	PrecacheParticle(PARTICLE_METEOR);
	PrecacheParticle(PARTICLE_EMBERS); // New Particle.
	
	CheckModelPreCache("models/props_junk/gascan001a.mdl");
	CheckModelPreCache("models/props_junk/propanecanister001a.mdl");
	CheckModelPreCache("models/infected/witch.mdl");
	CheckModelPreCache("models/infected/witch_bride.mdl");
	CheckModelPreCache("models/props_vehicles/tire001c_car.mdl");
	CheckModelPreCache("models/props_unique/airport/atlas_break_ball.mdl");
	CheckModelPreCache("models/props_debris/concrete_chunk01a.mdl"); // Fixed
	CheckModelPreCache("models/infected/hulk.mdl"); // Fixed
	CheckSoundPreCache("ambient/fire/gascan_ignite1.wav");
	CheckSoundPreCache("player/charger/hit/charger_smash_02.wav");
	CheckSoundPreCache("npc/infected/action/die/male/death_42.wav");
	CheckSoundPreCache("npc/infected/action/die/male/death_43.wav");
	CheckSoundPreCache("ambient/energy/zap1.wav");
	CheckSoundPreCache("ambient/energy/zap5.wav");
	CheckSoundPreCache("ambient/energy/zap7.wav");
	CheckSoundPreCache("player/spitter/voice/warn/spitter_spit_02.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_01.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_02.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_03.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_04.wav");
	CheckSoundPreCache("player/boomer/explode/explo_medium_09.wav"); // New Sound.
	CheckSoundPreCache("physics/glass/glass_impact_bullet4.wav"); // New Sound.
	PrecacheSound(SOUND_EXPLODE, true);
}

stock void CheckModelPreCache(const char[] Modelfile)
{
	if (!IsModelPrecached(Modelfile))
	{
		PrecacheModel(Modelfile, true);
		PrintToServer("[Super Tanks]Precaching Model:%s",Modelfile);
	}
}

stock void CheckSoundPreCache(const char[] Soundfile)
{
	//if (!IsSoundPrecached(Soundfile)) //Removed, Function not working
	//{
		PrecacheSound(Soundfile, true);
		PrintToServer("[Super Tanks]Precaching Sound:%s",Soundfile);
	//}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
	TankAbility[client] = 1;
	Rock[client] = 1;
	ShieldsUp[client] = 1;
	PlayerSpeed[client] = 1;
}

public Action Ability_Use( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );

	if (bSuperTanksEnabled)
	{
		if (client > 0)
		{
			if (IsClientInGame(client))
			{
				if (IsTank(client))
				{
					int index = GetSuperTankByRenderColor(GetEntityRender_RGB(client));
					if (index >= 0 && index <= 16)
					{
						if (index != 0 || (index == 0 && bDefaultOverride))
						{
							ResetInfectedAbility(client, flTankThrow[index]);
						}
					}
				}
			}
		}
	}
}

public Action Finale_Escape_Start( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	iTankWave = 3;
}

public Action Finale_Start( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	iTankWave = 1;
}

public Action Finale_Vehicle_Leaving( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	iTankWave = 4;
}

public Action Finale_Vehicle_Ready( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	iTankWave = 3;
}

public Action Player_Death( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );

	if (bSuperTanksEnabled)
	{
		if (client > 0 && IsClientInGame(client))
		{
			SetEntityGravity(client, 1.0);
			
			if( bL4DTwo ) 
			{
				SetEntProp(client, Prop_Send, "m_iGlowType", 0);
				SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
			}
			
			if (IsTank(client))
			{
				ExecTankDeath(client);
				float Pos[3];
				GetClientAbsOrigin(client, Pos);
				EmitSoundToAll(SOUND_EXPLODE, client);
				if( bL4DTwo )
				ShowParticle(Pos, PARTICLE_DEATH, 5.0);
				LittleFlower(Pos, 0);
				LittleFlower(Pos, 1);
			}	
			else if (GetClientTeam(client) == 2)
			{
				int entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					float Origin[3], EOrigin[3];
					GetClientAbsOrigin(client, Origin);
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", EOrigin);
					if (Origin[0] == EOrigin[0] && Origin[1] == EOrigin[1] && Origin[2] == EOrigin[2])
					{
						SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					}
				}
			}
			
		}
	}
}

public Action Round_End( Event hEevent, const char[] sEvent_Name, bool bDontBroadcast )
{
	if (bSuperTanksEnabled)
	{
		for (int i=1;i<=MaxClients;i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && IsFakeClient(i) && GetClientTeam(i) == 3 && !IsTank(i))
			{
				if (CountInfectedAll() > 16)
				{
					KickClient(i);
				}
			}
		}
	}
}

public Action Round_Start( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	if (bSuperTanksEnabled)
	{
		iTick = 0;
		iTankWave = 0;
		iNumTanks = 0;
/*
		int flags = GetConVarFlags( FindConVar("z_max_player_zombies") );
		SetConVarBounds( FindConVar("z_max_player_zombies"), ConVarBound_Upper, false );
		SetConVarFlags( FindConVar("z_max_player_zombies"), flags & ~FCVAR_NOTIFY );
		
		if ( bL4DTwo ) 
		{
			FindConVar("z_hunter_limit").IntValue = 32;
			FindConVar("z_jockey_limit").IntValue = 32;
			FindConVar("z_charger_limit").IntValue = 32;
			FindConVar("z_boomer_limit").IntValue = 32;
			FindConVar("z_spitter_limit").IntValue = 32;
		}
		else
		{
			FindConVar("z_hunter_limit").IntValue = 32;
			FindConVar("z_exploding_limit").IntValue = 32;
		}
*/		
		for( int client = 1; client <= MaxClients; client ++ )
		{
			TankAbility[client] = 0;
			Rock[client] = 0;
			ShieldsUp[client] = 0;
			PlayerSpeed[client] = 0;
		}
	}
}

public Action Tank_Spawn( Event hEvent, const char[] sEvent_Name, bool bDontBroadcast )
{
	int client =  GetClientOfUserId( hEvent.GetInt( "userid" ) );

	CountTanks();

	if (bSuperTanksEnabled)
	{
		if (client > 0 && IsClientInGame(client))
		{
			TankAlive[client] = 1;
			TankAbility[client] = 0;
			CreateTimer(0.0, TankSpawnTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.0, TankSpawnHPTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE);
			if (!bFinaleOnly || (bFinaleOnly && iTankWave > 0))
			{
				RandomizeTank(client);
				switch(iTankWave)
				{
					case 1:
					{
						if (iNumTanks < iWave1Cvar)
						{
							CreateTimer(5.0, SpawnTankTimer, _, TIMER_FLAG_NO_MAPCHANGE);
						}
						else if (iNumTanks > iWave1Cvar)
						{
							if (IsFakeClient(client))
							{
								KickClient(client);
							}
						}
					}
					case 2:
					{
						if (iNumTanks < iWave2Cvar)
						{
							CreateTimer(5.0, SpawnTankTimer, _, TIMER_FLAG_NO_MAPCHANGE);
						}
						else if (iNumTanks > iWave2Cvar)
						{
							if (IsFakeClient(client))
							{
								KickClient(client);
							}
						}
					}
					case 3:
					{
						if (iNumTanks < iWave3Cvar)
						{
							CreateTimer(5.0, SpawnTankTimer, _, TIMER_FLAG_NO_MAPCHANGE);
						}
						else if (iNumTanks > iWave3Cvar)
						{
							if (IsFakeClient(client))
							{
								KickClient(client);
							}
						}
					}
				}
			}
		}
	}
}

public Action TankSpawnHPTimer( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if (client > 0)
	{
		if (IsTank(client))
		{
			int index = GetSuperTankByRenderColor(GetEntityRender_RGB(client));
			if (index >= 0 && index <= 16)
			{
				if (index != 0 || (index == 0 && bDefaultOverride))
				{
					char TankName[MAX_TARGET_LENGTH];
					switch(index)
					{
						case 0: {TankName = "坦克"; }
						case 1: {TankName = "生成坦克"; }
						case 2: {TankName = "粉碎坦克";}
						case 3: {TankName = "跃迁坦克";}
						case 4: {TankName = "流星坦克";}
						case 5: {TankName = "喷吐坦克";}
						case 6: {TankName = "治疗坦克";}
						case 7: {TankName = "火焰坦克";}
						case 8: {TankName = "冰霜坦克";}
						case 9: {TankName = "骑乘坦克";}
						case 10: {TankName = "幽灵坦克";}
						case 11: {TankName = "电击坦克";}
						case 12: {TankName = "女巫坦克";}
						case 13: {TankName = "护盾坦克";}
						case 14: {TankName = "钴蓝坦克";}
						case 15: {TankName = "跳跃坦克";}
						case 16: {TankName = "重力坦克";}
					}					
					int health = GetEntProp(client, Prop_Send, "m_iHealth") + iTankExtraHealth[index];
					float speed = flTankSpeed[index];
					CPrintToChatAll("{olive}[超级坦克]{blue}%s{olive}\n{blue} 类型 {orange}: {olive}%d,{blue} 速度 {orange}: {olive}%.1f", TankName, index, speed);
				}
			}
		}
	}
}

//=============================
// TANK CONTROLLER
//=============================
public void TankController()
{
	CountTanks();
	if (iNumTanks > 0)
	{
		for (int i=1; i<=MaxClients; i++)
		{
			if (IsTank(i))
			{
				int index = GetSuperTankByRenderColor(GetEntityRender_RGB(i));
				if (index >= 0 && index <= 16)
				{
					if (index != 0 || (index == 0 && bDefaultOverride))
					{
						SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flTankSpeed[index]);
						switch(index)
						{
							case 1:
							{
								iTick += 1;
								if (iTick >= iSpawnCommonInterval)
								{
									for (int count=1; count<=iSpawnCommonAmount; count++)
									{
										if( bL4DTwo )
											CheatCommand(i, "z_spawn_old", "zombie area");
										else 
											CheatCommand(i, "z_spawn", "zombie area"); 
									}
									iTick = 0;
								}
							}
							case 3:
							{
								TeleportTank(i);
							}
							case 4:
							{
								if (TankAbility[i] == 0)
								{
									int random = GetRandomInt(1,iMeteorStormDelay);
									if (random == 1)
									{
										StartMeteorFall(i);
									}
								}
							}
							case 6:
							{
								HealTank( i );
							}
							case 7:
							{
								IgniteEntity(i, 1.0);
							}
							case 10:
							{
								InfectedCloak(i);
								if (CountSurvRange(i) == CountSurvivorsAliveAll())
								{
									SetEntityRenderMode( i, view_as<RenderMode>( 3 ) ); // Other case RENDER_GLOW
									SetEntityRenderColor(i, 100, 100, 100, 50);
									EmitSoundToAll("npc/infected/action/die/male/death_43.wav", i);
								}
								else
								{
									SetEntityRenderMode( i, view_as<RenderMode>( 3 ) ); // Other Case RENDER_GLOW
									SetEntityRenderColor(i, 100, 100, 100, 150);
									EmitSoundToAll("npc/infected/action/die/male/death_42.wav", i);
								}
							}
							case 12:
							{
								SpawnWitch(i);
							}
							case 13:
							{
								if (ShieldsUp[i] > 0 && bL4DTwo)
								{
									int glowcolor = RGB_TO_INT(120, 90, 150);
									
									SetEntProp(i, Prop_Send, "m_iGlowType", 2);
									SetEntProp(i, Prop_Send, "m_bFlashing", 2);
									SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
								}
								else if ( bL4DTwo )
								{
									SetEntProp(i, Prop_Send, "m_iGlowType", 0);
									SetEntProp(i, Prop_Send, "m_bFlashing", 0);
									SetEntProp(i, Prop_Send, "m_glowColorOverride", 0);
								}
							}
							case 14:
							{
								if (TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									int random = GetRandomInt(1,9);
									if (random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect, GetClientUserId( i ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if (TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flCobaltSpecialSpeed);
								}
							}
							case 16:
							{
								SetEntityGravity(i, 0.5);
							}
						}
						if (bTankFireImmunity[index])
						{
							if (IsPlayerBurning(i))
							{
								ExtinguishEntity(i);
								SetEntPropFloat(i, Prop_Send, "m_burnPercent", 1.0);
							}
						}
					}
				}	
			}
		}
	}
}

public Action TankSpawnTimer( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if (client > 0)
	{
		if (IsTank(client))
		{
			int index = GetSuperTankByRenderColor(GetEntityRender_RGB(client));
			if (index >= 0 && index <= 16)
			{
				if (index != 0 || (index == 0 && bDefaultOverride))
				{
					switch(index)
					{
						case 1:
						{
							CreateTimer(1.2, Timer_AttachSPAWN, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Spawn Tank");
							}
							SetEntityRenderColor(client, 75, 95, 105, 255);
						}
						case 2:
						{
							if( bL4DTwo )
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								int glowcolor = RGB_TO_INT(50, 50, 50);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Smasher Tank");
							}
							SetEntityRenderColor(client, 70, 80, 100, 255);
						}
						case 3:
						{
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Warp Tank");
							}
							SetEntityRenderColor(client, 130, 130, 255, 255);
						}
						case 4:
						{
							CreateTimer(0.1, MeteorTankTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachMETEOR, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Meteor Tank");
							}
							SetEntityRenderColor(client, 100, 25, 25, 255);
						}
						case 5:
						{
							CreateTimer( bL4DTwo ? 2.0 : 1.0, Timer_AttachSPIT, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", bL4DTwo ? "Spitter Tank" : "Nauseating Tank" );
							}
							SetEntityRenderColor(client, 12, 115, 128, 255);
						}
						case 6:
						{
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Heal Tank");
							}
							SetEntityRenderColor(client, 100, 255, 200, 255);
						}
						case 7:
						{
							CreateTimer(0.8, Timer_AttachFIRE, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Fire Tank");
							}
							SetEntityRenderColor(client, 128, 0, 0, 255);
						}
						case 8:
						{
							CreateTimer(2.0, Timer_AttachICE, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Ice Tank");
							}
							SetEntityRenderColor(client, 0, 100, 170, 200);
							SetEntityRenderMode( client, view_as<RenderMode>( 3 ) );
						}
						case 9:
						{
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", bL4DTwo ? "Jockey Tank" : "Hunter Tank" );
							}
							SetEntityRenderColor(client, 255, 200, 0, 255);
						}
						case 10:
						{
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Ghost Tank");
							}
							SetEntityRenderMode( client, view_as<RenderMode>( 3 ) );// Other Case RENDER_GLOW
							SetEntityRenderColor(client, 100, 100, 100, 0);
						}
						case 11:
						{
							CreateTimer(0.8, Timer_AttachELEC, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Shock Tank");
							}
							SetEntityRenderColor(client, 100, 165, 255, 255);
						}
						case 12:
						{
							CreateTimer(2.0, Timer_AttachBLOOD, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Witch Tank");
							}
							SetEntityRenderColor(client, 255, 200, 255, 255); 
						}
						case 13:
						{
							if (ShieldsUp[client] == 0)
							{
								ActivateShield(client);
							}
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Shield Tank");
							}
							SetEntityRenderColor(client, 135, 205, 255, 255);
						}
						case 14:
						{
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Cobalt Tank");
							}
							SetEntityRenderColor(client, 0, 105, 255, 255);
						}
						case 15:
						{
							CreateTimer(0.1, JumperTankTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, JumpTimer, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Jumper Tank");
							}
							SetEntityRenderColor(client, 200, 255, 0, 255);
						}
						case 16:
						{
							CreateTimer(0.1, GravityTankTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE);
							if (IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Gravity Tank");
							}
							SetEntityRenderColor(client, 33, 34, 35, 255);
						}
					}
					if (iTankExtraHealth[index] > 0)
					{
						int health = GetEntProp(client, Prop_Send, "m_iHealth");
						int maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
						SetEntProp(client, Prop_Send, "m_iMaxHealth", maxhealth + iTankExtraHealth[index]);
						SetEntProp(client, Prop_Send, "m_iHealth", health + iTankExtraHealth[index]);
					}
					ResetInfectedAbility(client, flTankThrow[index]);
				}
			}
		}
	}
}

//=============================
// Speed on Ground and in Water
//=============================
stock void SpeedRebuild(int client)
{
	float value;
	if (PlayerSpeed[client] > 0)
	{
		value = flShockStunMovement;
	}
	else
	{
		value = 1.0;
	}
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", value);
}

//=============================
// FUNCTIONS
//=============================
public void OnEntityCreated(int entity, const char[] classname)
{
	if (bSuperTanksEnabled)
	{
		if (StrEqual(classname, "tank_rock", true))
		{
			CreateTimer(0.1, RockThrowTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (!IsServerProcessing()) return;

	if (bSuperTanksEnabled)
	{
		if (entity > 32 && IsValidEntity(entity))
		{
			char classname[32];
			GetEdictClassname(entity, classname, sizeof(classname));
			if (StrEqual(classname, "tank_rock", true))
			{
				int color = GetEntityRender_RGB(entity);
				switch(color)
				{
					//Fire
					case FIRE_TANK:
					{
						int prop = CreateEntityByName("prop_physics");
						if (prop > 32 && IsValidEntity(prop))
						{
							float Pos[3];
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);
							Pos[2] += 10.0;
							DispatchKeyValue(prop, "model", "models/props_junk/gascan001a.mdl");
							DispatchSpawn(prop);
							SetEntData(prop, GetEntSendPropOffs(prop, "m_CollisionGroup"), 1, 1, true);
							TeleportEntity(prop, Pos, NULL_VECTOR, NULL_VECTOR);
							AcceptEntityInput(prop, "break");
						}
					}
					//Spitter
					case SPITTER_TANK:
					{
						if ( bL4DTwo )
						{
							int x = CreateFakeClient("Spitter");
							if (x > 0)
							{
								float Pos[3];
								GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);
								TeleportEntity(x, Pos, NULL_VECTOR, NULL_VECTOR);	
								SDKCallSpitBurst(x);
								KickClient(x);
							}
						}
						else
						{
							Explode_Puke( entity );
						}
					}
				}
			}
		}
	}
}

/* ============================================================= 
						Nauseating Tank
   ============================================================= */
   
stock void Explode_Puke( int entity )
{	
	static float vPos[3];
	
	int attacker = CreateFakeClient("Boomer");
	
	GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", vPos );
	
	EmitSoundToAll( "player/boomer/explode/explo_medium_09.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, vPos, NULL_VECTOR, true, 0.0 );
	
	CreateParticle( entity, PARTICLE_EXPLODE, 3.0, vPos[2] += 5 );
	
	float vEnd[3];
	for( int i = 1; i <= MaxClients; i ++ )
	{
		if( IsClientInGame( i ) && GetClientTeam( i ) == 2 && IsPlayerAlive( i ) )
		{
			GetClientAbsOrigin( i, vEnd );
			if( GetVectorDistance( vPos, vEnd ) <= 250 )
			{
				if ( attacker > 0 ) 
				{
					SDKCallVomitOnPlayer( i, attacker );
					PushSurvivor( i, entity );
//					CPrintToChatAll( "{default}Entity{orange}[{lightgreen}%i{orange}]{default} Atacante{orange}[{lightgreen}%N{orange}]{default} Victíma{orange}[{lightgreen}%N{orange}]", entity, attacker, i ); // Test.
				}
			}
		}
	}
	
	if ( attacker > 0 )
		KickClient( attacker );
}

stock void PushSurvivor( int target, int entity )
{
	float HeadingVector[3];
	float AimVector[3];
	float vPower = 150.0;
	
	GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", HeadingVector );

	AimVector[0] = Cosine( DegToRad( HeadingVector[1] ) ) * vPower;
	AimVector[1] = Sine( DegToRad( HeadingVector[1] ) ) * vPower;
	
	float vCurrent[3];
	GetEntPropVector(target, Prop_Data, "m_vecVelocity", vCurrent);
	
	float vResulting[3];
	vResulting[0] = vCurrent[0] + AimVector[0];
	vResulting[1] = vCurrent[1] + AimVector[1];
	vResulting[2] = vPower * 2;
	
	TeleportEntity( target, NULL_VECTOR, NULL_VECTOR, vResulting );
}

/* ============================================================= */

stock int Pick()
{
	int count;
	int[] clients = new int[MaxClients];
	for(int i = 1; i<= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
			clients[count++] = i; 
	
	return clients[GetRandomInt(0, count-1)];
}

stock bool IsSpecialInfected(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		char classname[32];
		GetEntityNetClass(client, classname, sizeof(classname));
		if (StrEqual(classname, "Smoker", false) || StrEqual(classname, "Boomer", false) || StrEqual(classname, "Hunter", false) || StrEqual(classname, "Spitter", false) || StrEqual(classname, "Jockey", false) || StrEqual(classname, "Charger", false))
		{
			return true;
		}
	}
	return false;
}

stock bool IsValidClient(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		return true;
	}
	return false;
}

stock bool IsTank(int client)
{
	if( client > 0 && client <= MaxClients && IsClientInGame( client ) && GetClientTeam( client ) == 3 )
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( class == ( bL4DTwo ? 8 : 5 ) )
		    return true;
	}
	return false;
}

stock bool IsSurvivor(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		return true;
	}
	return false;
}

stock bool IsWitch(int i)
{
	if (IsValidEntity(i))
	{
		char  classname[32];
		GetEdictClassname(i, classname, sizeof(classname));
		if (StrEqual(classname, "witch"))
			return true;
		
		return false;
	}
	
	return false;
}

stock void CountTanks()
{
	iNumTanks = 0;
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsTank(i))
		{
			iNumTanks++;
		}
	}
}

public Action TankLifeCheck(Handle timer, any client)
{
	if (IsClientInGame(client) && GetClientTeam(client) == 3)
	{
		int lifestate = GetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_lifeState"));
		if (lifestate == 0)
		{
			int bot = CreateFakeClient("Tank");
			if (bot > 0)
			{
				float  Origin[3], Angles[3];
				GetClientAbsOrigin(client, Origin);
				GetClientAbsAngles(client, Angles);
				KickClient(client);
				TeleportEntity(bot, Origin, Angles, NULL_VECTOR);
				SpawnInfected(bot, 8, true);
			}
		}	
	}
}

stock void RandomizeTank(int client)
{
	if (!bDefaultTanks)
	{
		int count;
		int TempArray[16+1];

		for ( int index = 1; index <= 16; index ++ )
		{
			if (bTankEnabled[index])
			{
				TempArray[count+1] = index;
				count++;	
			}
		}
		if (count > 0)
		{
			int random = GetRandomInt(1,count);
			int tankpick = TempArray[random];
			switch(tankpick)
			{
				case 1: SetEntityRenderColor(client, 75, 95, 105, 255); 		// Spawn
				case 2: SetEntityRenderColor(client, 70, 80, 100, 255); 		// Smasher
				case 3: SetEntityRenderColor(client, 130, 130, 255, 255); 		// Warp
				case 4: SetEntityRenderColor(client, 100, 25, 25, 255); 		// Meteor
				case 5: SetEntityRenderColor(client, 12, 115, 128, 255); 		// Spitter
				case 6: SetEntityRenderColor(client, 100, 255, 200, 255); 		// Heal
				case 7: SetEntityRenderColor(client, 128, 0, 0, 255); 			// Fire
				case 8:
				{
						SetEntityRenderMode( client, view_as<RenderMode>( 3 ) );// Other Case RENDER_GLOW
						SetEntityRenderColor(client, 0, 100, 170, 200); 		// Ice
				}
				case 9: SetEntityRenderColor(client, 255, 200, 0, 255); 		// Jockey
				case 10:
				{
						SetEntityRenderMode( client, view_as<RenderMode>( 3 ) );// Other Case RENDER_GLOW
						SetEntityRenderColor(client, 100, 100, 100, 0); 		// Ghost
				}
				case 11: SetEntityRenderColor(client, 100, 165, 255, 255); 		// Shock
				case 12: SetEntityRenderColor(client, 255, 200, 255, 255); 		// Witch
				case 13: SetEntityRenderColor(client, 135, 205, 255, 255); 		// Shield
				case 14: SetEntityRenderColor(client, 0, 105, 255, 255); 		// Cobalt
				case 15: SetEntityRenderColor(client, 200, 255, 0, 255); 		// Jumper
				case 16: SetEntityRenderColor(client, 33, 34, 35, 255); 		// Gravity
			}
		}
	}
}

bool SpawnInfected(int client, int Class, bool bAuto = true)
{
	bool[] resetGhostState = new bool[MaxClients+1];
	bool[] resetIsAlive = new bool[MaxClients+1];
	bool[] resetLifeState = new bool[MaxClients+1];
	ChangeClientTeam(client, 3);
	char g_sBossNames[9+1][10] = { "", "smoker", "boomer", "hunter", "spitter", "jockey", "charger", "witch", "tank", "survivor" };
	char options[30];
	if (Class < 1 || Class > 8) return false;
	if (GetClientTeam(client) != 3) return false;
	if (!IsClientInGame(client)) return false;
	if (IsPlayerAlive(client)) return false;
	
	for (int i=1; i<=MaxClients; i++){ 
		if (i == client) continue; 				// Don't disable the chosen one
		if (!IsClientInGame(i)) continue; 		// Not ingame? skip
		if (GetClientTeam(i) != 3) continue; 	// Not infected? skip
		if (IsFakeClient(i)) continue; 			// A bot? skip
		
		if (IsPlayerGhost(i)){
			resetGhostState[i] = true;
			SetPlayerGhostStatus(i, false);
			resetIsAlive[i] = true; 
			SetPlayerIsAlive(i, true);
		}
		else if (!IsPlayerAlive(i)){
			resetLifeState[i] = true;
			SetPlayerLifeState(i, false);
		}
	}
	
	Format(options, sizeof(options), "%s%s", g_sBossNames[Class], ( bAuto ? " auto" : "" ) );
	
	CheatCommand( client, bL4DTwo ? "z_spawn_old" : "z_spawn", options); 
	
	if (IsFakeClient(client)) KickClient(client);
	
//	We restore the player's status
	for (int i=1; i<=MaxClients; i++){
		if (resetGhostState[i]) SetPlayerGhostStatus(i, true);
		if (resetIsAlive[i]) SetPlayerIsAlive(i, false);
		if (resetLifeState[i]) SetPlayerLifeState(i, true);
	}

	return true;
}

stock void SetPlayerGhostStatus(int client, bool ghost)
{
	if(ghost)
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	else
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
}

stock void SetPlayerIsAlive(int client, bool alive)
{
	int offset = FindSendPropInfo("CTransitioningPlayer", "m_isAlive");
	if (alive) SetEntData(client, offset, 1, 1, true);
	else SetEntData(client, offset, 0, 1, true);
}

stock void SetPlayerLifeState(int client, bool ready)
{
	if (ready) SetEntProp(client, Prop_Data, "m_lifeState", 1, 1);
	else SetEntProp(client, Prop_Data, "m_lifeState", 0, 1);
}

bool IsPlayerGhost( int client )
{
	if( GetEntProp( client, Prop_Send, "m_isGhost", 1 ) ) 
		return true;
	
	return false;
}

bool IsPlayerIncap( int client )
{
	if( GetEntProp( client, Prop_Send, "m_isIncapacitated", 1 ) ) 
		return true;
	
	return false;
}

stock int NearestSurvivor(int j)
{
	int target;
	float InfectedPos[3], SurvivorPos[3], nearest = 0.0;
   	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 /* && ChaseTarget[i] == 0 */)
		{
			GetClientAbsOrigin(j, InfectedPos);
			GetClientAbsOrigin(i, SurvivorPos);
			float distance = GetVectorDistance(InfectedPos, SurvivorPos);
			if (nearest == 0.0)
			{
				nearest = distance;
				target = i;
			}
			else if (nearest > distance)
			{
				nearest = distance;
				target = i;
			}
		} 
	}
	
	return target;
}

stock int CountSurvivorsAliveAll()
{
	int count = 0;
	for (int i=1; i<=MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
			count++;
	
	return count;
}

stock int CountInfectedAll()
{
	int count = 0;
	for (int i=1;i<=MaxClients;i++)
		if (IsClientInGame(i) && GetClientTeam(i) == 3)
			count++;
	
	return count;
}

bool IsPlayerBurning(int i)
{
	float IsBurning = GetEntPropFloat(i, Prop_Send, "m_burnPercent");
	if( IsBurning > 0 ) 
		return true;
	
	return false;
}

public Action CreateParticle(int target, char[] particlename, float time, float origin)
{
	if (target > 0)
	{
   		int particle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(particle))
		{
			float pos[3];
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
			pos[2] += origin;
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(particle, "effect_name", particlename);
			DispatchKeyValue(particle, "targetname", "particle");
			DispatchSpawn(particle);
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
			CreateTimer(time, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action AttachParticle(int target, char[] particlename, float time, float origin)
{
	if (target > 0 && IsValidEntity(target))
	{
   		int particle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(particle))
		{
			float pos[3];
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
			pos[2] += origin;
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
			char tName[64];
			Format(tName, sizeof(tName), "Attach%d", target);
			DispatchKeyValue(target, "targetname", tName);
			GetEntPropString(target, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(particle, "scale", "");
			DispatchKeyValue(particle, "effect_name", particlename);
			DispatchKeyValue(particle, "parentname", tName);
			DispatchKeyValue(particle, "targetname", "particle");
			DispatchSpawn(particle);
			ActivateEntity(particle);
			SetVariantString(tName);
			AcceptEntityInput(particle, "SetParent", particle, particle);
			AcceptEntityInput(particle, "Enable");
			AcceptEntityInput(particle, "start");
			CreateTimer(time, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action PrecacheParticle(char[] particlename)
{
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(particle))
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.1, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
	}  
}

public Action DeleteParticles(Handle timer, any particle)
{
	if (IsValidEntity(particle))
	{
		char classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
			AcceptEntityInput(particle, "Kill");
	}
}

public void PerformFade(int client, int duration, int unknown, int type1, int type2, const int Color[4]) 
{
	switch(type1)
	{
		case 1: type1 = FFADE_IN;
		case 2: type1 = FFADE_OUT;
		case 4: type1 = FFADE_MODULATE;
		case 8: type1 = FFADE_STAYOUT;
		case 10: type1 = FFADE_PURGE;
	}
	
	switch(type2)
	{
		case 1: type2 = FFADE_IN;
		case 2: type2 = FFADE_OUT;
		case 4: type2 = FFADE_MODULATE;
		case 8: type2 = FFADE_STAYOUT;
		case 10: type2 = FFADE_PURGE;
	}
	
	Handle hFadeClient=StartMessageOne("Fade", client);
	BfWriteShort(hFadeClient, duration);
	BfWriteShort(hFadeClient, unknown);
   	BfWriteShort(hFadeClient, (type1|type2));
	BfWriteByte(hFadeClient, Color[0]);
	BfWriteByte(hFadeClient, Color[1]);
	BfWriteByte(hFadeClient, Color[2]);
	BfWriteByte(hFadeClient, Color[3]);
	EndMessage();
}

public void ScreenShake(int target, float intensity)
{
	Handle msg;
	msg = StartMessageOne("Shake", target);
	
	BfWriteByte(msg, 0);
 	BfWriteFloat(msg, intensity);
 	BfWriteFloat(msg, 10.0);
 	BfWriteFloat(msg, 3.0);
	EndMessage();
}

public Action RockThrowTimer(Handle hTimer)
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		int thrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
		if (thrower > 0 && thrower < 33 && IsTank(thrower))
		{
			int color = GetEntityRender_RGB(thrower);
			switch(color)
			{
				//Fire Tank
				case FIRE_TANK:
				{
					SetEntityRenderColor( entity, 128, 0, 0, 255);
					CreateTimer( 0.8, Timer_AttachFIRE_Rock, EntIndexToEntRef( entity ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
				}
				//Ice Tank
				case ICE_TANK:
				{
					SetEntityRenderMode( entity, view_as<RenderMode>( 3 ) );
					SetEntityRenderColor(entity, 0, 100, 170, 180);
				}
				//Jockey Tank
				case JOCKEY_TANK:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, JockeyThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Spitter Tank
				case SPITTER_TANK:
				{
					SetEntityRenderMode( entity, view_as<RenderMode>( 3 ) );
					SetEntityRenderColor(entity, 121, 151, 28, 30);
					
					if ( bL4DTwo )
					{
						CreateTimer( 0.8, Timer_SpitSound, thrower, TIMER_FLAG_NO_MAPCHANGE );
						CreateTimer( 0.8, Timer_AttachSPIT_Rock, EntIndexToEntRef( entity ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
					}
				}
				//Shock Tank
				case SHOCK_TANK:
				{
					CreateTimer( 0.8, Timer_AttachELEC_Rock, EntIndexToEntRef( entity ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
				}
				//Shield Tank
				case SHIELD_TANK:
				{
					Rock[thrower] = entity;
					CreateTimer( 0.1, PropaneThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
				}
			}
		}
	}
}

public Action PropaneThrow(Handle timer, any client)
{
	float velocity[3];
	int entity = Rock[client];
	if (IsValidEntity(entity))
	{
		int g_iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		float v = GetVectorLength(velocity);
		if (v > 500.0)
		{
			int propane = CreateEntityByName("prop_physics");
			if (IsValidEntity(propane))
			{
				DispatchKeyValue(propane, "model", "models/props_junk/propanecanister001a.mdl");
				DispatchSpawn(propane);
				float Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				float speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(propane, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action JockeyThrow( Handle hTimer, any client )
{
	float velocity[3];
	int entity = Rock[client];
	if (IsValidEntity(entity))
	{
		int g_iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		float v = GetVectorLength(velocity);
		if (v > 500.0)
		{
			int bot = CreateFakeClient( bL4DTwo ? "Jockey" : "Hunter" ); // Se puede dejar con cual quiera de los nicks tanto para L4D1 y 2.
			if (bot > 0)
			{
				if( bL4DTwo )
					SpawnInfected( bot, 5, true );
				else
					SpawnInfected( bot, 3, false);
				
				float Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				float speed = GetConVarFloat( FindConVar( "z_tank_throw_force" ) );
				ScaleVector( velocity, speed * 1.4 );
				TeleportEntity( bot, Pos, NULL_VECTOR, velocity );
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action JumpTimer(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (client > 0 && IsTank(client))
	{
		int flags = GetEntityFlags(client);
		if (flags & FL_ONGROUND)
		{
			int random = GetRandomInt(1,iJumperJumpDelay);
			if (random == 1)
			{
				if (GetNearestSurvivorDist(client) > 200 && GetNearestSurvivorDist(client) < 2000)
				{
					FakeJump(client);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public void FakeJump(int client)
{
	if (client > 0 && IsTank(client))
	{
		float vecVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecVelocity);
		if (vecVelocity[0] > 0.0 && vecVelocity[0] < 500.0)
		{
			vecVelocity[0] += 500.0;
		}
		else if (vecVelocity[0] < 0.0 && vecVelocity[0] > -500.0)
		{
			vecVelocity[0] += -500.0;
		}
		if (vecVelocity[1] > 0.0 && vecVelocity[1] < 500.0)
		{
			vecVelocity[1] += 500.0;
		}
		else if (vecVelocity[1] < 0.0 && vecVelocity[1] > -500.0)
		{
			vecVelocity[1] += -500.0;
		}
		vecVelocity[2] += 750.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
	}
}

public void SkillFlameClaw(int target)
{
	if (target > 0)
	{
		if (IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			IgniteEntity(target, 3.0);
			EmitSoundToAll("ambient/fire/gascan_ignite1.wav", target);
			PerformFade(target, 500, 250, 10, 1, {100, 50, 0, 150});
		}
	}
}

public void SkillIceClaw(int target)
{
	if (target > 0)
	{
		if (IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			SetEntityRenderMode( target, view_as<RenderMode>( 3 ) );
			SetEntityRenderColor(target, 0, 100, 170, 180);
			SetEntityMoveType(target, MOVETYPE_NONE);
//			SetEntityMoveType(target, MOVETYPE_VPHYSICS); // Causa bloqueo en L4D1
			EmitSoundToAll( "physics/glass/glass_impact_bullet4.wav", target );
			CreateTimer(5.0, Timer_UnFreeze, GetClientUserId( target ), TIMER_FLAG_NO_MAPCHANGE);
			PerformFade(target, 500, 250, 10, 1, {0, 50, 100, 150});
		}
	}
}

public void SkillFlameGush(int target)
{
	if (target > 0)
	{
		if (IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 3)
		{
			float pos[3];
			GetClientAbsOrigin(target, pos);
			int entity = CreateEntityByName("prop_physics");
			if (IsValidEntity(entity))
			{
				pos[2] += 10.0;
				DispatchKeyValue(entity, "model", "models/props_junk/gascan001a.mdl");
				DispatchSpawn(entity);
				SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
				TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				AcceptEntityInput(entity, "break");
			}
		}
	}
}

public void SkillGravityClaw(int target)
{
	if (target > 0)
	{
		if (IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			SetEntityGravity(target, 0.3);
			CreateTimer(2.0, Timer_ResetGravity, GetClientUserId( target ), TIMER_FLAG_NO_MAPCHANGE);
			PerformFade(target, 500, 250, 10, 1, {100, 50, 100, 150});
			ScreenShake(target, 5.0);
		}
	}
}

public Action MeteorTankTimer(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (client > 0 && IsTank(client))
	{
		int color = GetEntityRender_RGB(client);
		if (color == METEOR_TANK)
		{
			float Origin[3], Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			int ent[5];
			for (int count=1; count<=4; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if (IsValidEntity(ent[count]))
				{
					char tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
					DispatchKeyValue(ent[count], "targetname", "RockEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("relbow");
						case 2:SetVariantString("lelbow");
						case 3:SetVariantString("rshoulder");
						case 4:SetVariantString("lshoulder");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					SetEntityRenderColor(ent[count], 100, 25, 25, 255 ); // New Function.
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					switch(count)
					{
						case 1, 2: if ( bL4DTwo ) SetEntPropFloat( ent[count], Prop_Data, "m_flModelScale", 0.4 );
						case 3, 4: if ( bL4DTwo ) SetEntPropFloat( ent[count], Prop_Data, "m_flModelScale", 0.5 );
					}
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
					Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
					Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
					
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}

public Action JumperTankTimer(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (client > 0 && IsTank(client))
	{
		int color = GetEntityRender_RGB(client);
		if (color == JUMPER_TANK)
		{
			float Origin[3], Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += 90.0;
			int ent[3];
			for (int count=1; count<=2; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if (IsValidEntity(ent[count]))
				{
					char tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_vehicles/tire001c_car.mdl");
					DispatchKeyValue(ent[count], "targetname", "TireEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("rfoot");
						case 2:SetVariantString("lfoot");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}

public Action GravityTankTimer(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (client > 0 && IsTank(client))
	{
		int color = GetEntityRender_RGB(client);
		if (color == GRAVITY_TANK)
		{
			float Origin[3], Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += -90.0;
			int entity = CreateEntityByName("beam_spotlight");
			if (IsValidEntity(entity))
			{
				char tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(entity, "targetname", "LightEntity");
				DispatchKeyValue(entity, "parentname", tName);
				DispatchKeyValueVector(entity, "origin", Origin);
				DispatchKeyValueVector(entity, "angles", Angles);
				DispatchKeyValue(entity, "spotlightwidth", "10");
				DispatchKeyValue(entity, "spotlightlength", "60");
				DispatchKeyValue(entity, "spawnflags", "3");
				DispatchKeyValue(entity, "rendercolor", "100 100 100");
				DispatchKeyValue(entity, "renderamt", "125");
				DispatchKeyValue(entity, "maxspeed", "100");
				DispatchKeyValue(entity, "HDRColorScale", "0.7");
				DispatchKeyValue(entity, "fadescale", "1");
				DispatchKeyValue(entity, "fademindist", "-1");
				DispatchSpawn(entity);
				SetVariantString(tName);
				AcceptEntityInput(entity, "SetParent", entity, entity);
				SetVariantString("mouth");
				AcceptEntityInput(entity, "SetParentAttachment");
				AcceptEntityInput(entity, "Enable");
				AcceptEntityInput(entity, "DisableCollision");
				SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
			}
			int blackhole = CreateEntityByName("point_push");
			if (IsValidEntity(blackhole))
			{
				char tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(blackhole, "targetname", "BlackholeEntity");
				DispatchKeyValue(blackhole, "parentname", tName);
				DispatchKeyValueVector(blackhole, "origin", Origin);
				DispatchKeyValueVector(blackhole, "angles", Angles);
				DispatchKeyValue(blackhole, "radius", "750");
				DispatchKeyValueFloat(blackhole, "magnitude", flGravityPullForce);
				DispatchKeyValue(blackhole, "spawnflags", "8");
				SetVariantString(tName);
				AcceptEntityInput(blackhole, "SetParent", blackhole, blackhole);
				AcceptEntityInput(blackhole, "Enable");
				
				SetEntPropEnt( blackhole, Prop_Send, "m_hOwnerEntity", client);
				if ( bL4DTwo ) SetEntProp( blackhole, Prop_Send, "m_glowColorOverride", client);
			}
		}
	}
}

public Action BlurEffect( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if( client > 0 && IsTank( client ) && TankAbility[client] == 1 )
	{
		float TankPos[3], TankAng[3];
		GetClientAbsOrigin( client, TankPos );
		GetClientAbsAngles( client, TankAng );
		
		int Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		int entity = CreateEntityByName("prop_dynamic");
		
		if( IsValidEntity( entity ) )
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "6");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor( entity, 0, 105, 255, 255 );
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat( entity, Prop_Send, "m_flPlaybackRate", bL4DTwo ? 15.0 : 5.0 ); // Originalmente 15.0
			
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			
			CreateTimer(0.3, RemoveBlurEffect, EntIndexToEntRef( entity ), TIMER_FLAG_NO_MAPCHANGE);
			
			return Plugin_Continue;
		}		
	}
	
	return Plugin_Stop;
}

public Action RemoveBlurEffect( Handle hTimer, any EntityID )
{
	int entity = EntRefToEntIndex( EntityID );
	if( IsValidEntity( entity ) )
	{
		char sClassName[32];
		GetEdictClassname( entity, sClassName, sizeof( sClassName ) );
		if (StrEqual( sClassName, "prop_dynamic"))
		{
			char sModel[128];
			GetEntPropString( entity, Prop_Data, "m_ModelName", sModel, sizeof( sModel ) );
			if( StrEqual( sModel, "models/infected/hulk.mdl" ) )
			{
				AcceptEntityInput( entity, "Kill" );
			}
		}	
	}
}

public void SkillSmashClaw(int target)
{
	int health = GetEntProp(target, Prop_Data, "m_iHealth");
	if (health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iSmasherMaimDamage);
		float hbuffer = float(health) - float(iSmasherMaimDamage);
		if (hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	PerformFade(target, 800, 300, 10, 1, {10, 0, 0, 250});
	ScreenShake(target, 30.0);
}

public void SkillSmashClawKill(int client, int attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	
	DealDamagePlayer(client, attacker, DMG_BULLET, iSmasherCrushDamage);
	DealDamagePlayer(client, attacker, DMG_BULLET, iSmasherCrushDamage);
	
	CreateTimer(0.1, RemoveDeathBody, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE);
}

public Action RemoveDeathBody( Handle hTimer, any UserID )
{
	if (bSmasherRemoveBody)
	{
		int client = GetClientOfUserId( UserID );
		if( client > 0 )
		{
			if (IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				int entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if (client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}

public void SkillElecClaw(int target, int tank)
{
	if (target > 0)
	{
		if (IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			PlayerSpeed[target] += 3;
			
			DataPack hPack = new DataPack(); // New Syntax.
			hPack.WriteCell( GetClientUserId( target ) );
			hPack.WriteCell( GetClientUserId( tank ) );
			hPack.WriteCell( 4 );
			
			CreateTimer(5.0, Timer_Volt, hPack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			
			PerformFade(target, 250, 100, 10, 1, {50, 150, 250, 100});
			ScreenShake(target, 15.0);
			AttachParticle(target, PARTICLE_ELEC, 2.0, 30.0);
			EmitSoundToAll("ambient/energy/zap1.wav", target);
		}
	}
}

public Action Timer_Volt( Handle hTimer, DataPack hPack )
{	
	hPack.Reset( false );
	int client = GetClientOfUserId( hPack.ReadCell() );
	int tank = GetClientOfUserId( hPack.ReadCell() );
	int amount = hPack.ReadCell();

	if (client > 0 && tank > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && PlayerSpeed[client] == 0 && IsTank(tank))
		{
			if (amount > 0)
			{
				PlayerSpeed[client] += 2;
				ScreenShake(client, 2.0);
				DealDamagePlayer(client, tank, DMG_BULLET, iShockStunDamage);
				AttachParticle(client, PARTICLE_ELEC, 2.0, 30.0);
				
				int random = GetRandomInt(1,2);
				if (random == 1) 
				{
					EmitSoundToAll("ambient/energy/zap5.wav", client);
				}
				else
				{
					EmitSoundToAll("ambient/energy/zap7.wav", client);
				}
				
				hPack.Reset( true );
				hPack.WriteCell( GetClientUserId( client ) );
				hPack.WriteCell( GetClientUserId( tank ) );
				hPack.WriteCell( amount - 1 );
				
				return Plugin_Continue;
			}
		}
	}
	
	CloseHandle(hPack);
	return Plugin_Stop;
}

stock void StartMeteorFall( int client )
{
	TankAbility[client] = 1;
	float vPos[3];
	GetClientEyePosition( client, vPos );	
	
	DataPack hPack = new DataPack(); // New Syntax.
	
	hPack.WriteCell( GetClientUserId( client ) );
	hPack.WriteFloat( vPos[0] );
	hPack.WriteFloat( vPos[1] );
	hPack.WriteFloat( vPos[2] );
	hPack.WriteFloat( GetEngineTime() );
	
	CreateTimer( 0.6, UpdateMeteorFall, hPack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
}

public Action UpdateMeteorFall( Handle hTimer, DataPack hPack )
{
	hPack.Reset();
	float vPos[3];
	int client = GetClientOfUserId( hPack.ReadCell() );
	
	vPos[0] = hPack.ReadFloat();
	vPos[1] = hPack.ReadFloat();
	vPos[2] = hPack.ReadFloat();
	
	float fTime = hPack.ReadFloat();
	
	if( ( GetEngineTime() - fTime ) > 5.0 )
	{
		TankAbility[client] = 0;
	}
	
	int entity = -1;
	if (IsTank(client) && TankAbility[client] == 1)
	{
		float angle[3], velocity[3], hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos( vPos, angle, hitpos, client, true );
		float dis = GetVectorDistance( vPos, hitpos );
		if (GetVectorDistance( vPos, hitpos) > 2000.0 )
		{
			dis = 1600.0;
		}
		float T[3];
		MakeVectorFromPoints( vPos, hitpos, T );
		NormalizeVector( T, T );
		ScaleVector(T, dis - 40.0);
		AddVectors( vPos, T, hitpos );
		
		if (dis > 100.0)
		{
			int ent = CreateEntityByName("tank_rock");
			if (ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				float angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if (TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			int ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if (client == ownerent)
			{
				ExplodeMeteor(entity, ownerent);
			}
		}
		
		CloseHandle(hPack);
		return Plugin_Stop;
	}
	
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		int ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if (client == ownerent)
		{
			if (OnGroundUnits(entity) < 200.0)
			{
				ExplodeMeteor(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}

public float OnGroundUnits(int i_Ent)
{
	if (!(GetEntityFlags(i_Ent) & (FL_ONGROUND)))
	{ 
		Handle h_Trace; 
		float f_Origin[3], f_Position[3], f_Down[3] = { 90.0, 0.0, 0.0 };
		
		GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin);
		h_Trace = TR_TraceRayFilterEx(f_Origin, f_Down, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, TraceRayDontHitSelfAndLive, i_Ent);

		if (TR_DidHit(h_Trace))
		{
			float f_Units;
			TR_GetEndPosition(f_Position, h_Trace);
			
			f_Units = f_Origin[2] - f_Position[2];

			CloseHandle(h_Trace);
			
			return f_Units;
		}
		CloseHandle(h_Trace);
	} 
	
	return 0.0;
}

stock int GetRayHitPos(float pos[3], float angle[3], float hitpos[3], int ent = 0, bool useoffset = false)
{
	Handle hTrace;
	int Hit = 0;
	
	hTrace = TR_TraceRayFilterEx( pos, angle, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfAndLive, ent );
	if (TR_DidHit( hTrace ) )
	{
		TR_GetEndPosition(hitpos, hTrace);
		Hit = TR_GetEntityIndex( hTrace );
	}
	
	delete hTrace;
//	CloseHandle( hTrace );
	
	if (useoffset)
	{
		float v[3];
		MakeVectorFromPoints(hitpos, pos, v);
		NormalizeVector(v, v);
		ScaleVector(v, 15.0);
		AddVectors(hitpos, v, hitpos);
	}
	return Hit;
}

stock void ExplodeMeteor(int entity, int client)
{
	if (IsValidEntity(entity))
	{
		char classname[20];
		GetEdictClassname(entity, classname, 20);
		if (!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		int ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		int pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flMeteorStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if (IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		int push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action DeletePushForce(Handle timer, any ent)
{
	if (IsValidEntity(ent))
	{
		char classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "point_push", false))
		{
			AcceptEntityInput(ent, "Kill"); 
		}
	}
}

public Action DeletePointHurt(Handle timer, any ent)
{
	if (IsValidEntity(ent))
	{
		char classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "point_hurt", false))
		{
			AcceptEntityInput(ent, "Kill"); 
		}
	}
}

public bool TraceRayDontHitSelfAndLive(int entity, int mask, any data)
{
	if (entity == data) 
	{
		return false; 
	}
	else if (entity>0 && entity<=MaxClients)
	{
		if(IsClientInGame(entity))
		{
			return false;
		}
	}
	return true;
}

stock void ExecTankDeath(int client)
{
	TankAlive[client] = 0;
	TankAbility[client] = 0;

	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char model[128];
            	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		if (StrEqual(model, "models/props_debris/concrete_chunk01a.mdl"))
		{
			int owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if (owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
		else if (StrEqual(model, "models/props_vehicles/tire001c_car.mdl"))
		{
			int owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if (owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
		else if (StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
		{
			int owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if (owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
	}
	while ((entity = FindEntityByClassname(entity, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		int owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
	while ( ( entity = FindEntityByClassname( entity, "point_push" ) ) != INVALID_ENT_REFERENCE )
	{
		if( bL4DTwo )
		{
			int Owner = GetEntProp( entity, Prop_Send, "m_glowColorOverride" );
			if (Owner == client )
				RemoveEntity( entity );
		}
		int Owner = GetEntPropEnt( entity, Prop_Send, "m_hOwnerEntity" );
		if (Owner == client )
			RemoveEntity( entity );
	}
	
	switch(iTankWave)
	{
		case 1: CreateTimer(5.0, TimerTankWave2, _, TIMER_FLAG_NO_MAPCHANGE);
		case 2: CreateTimer(5.0, TimerTankWave3, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action TimerTankWave2(Handle timer)
{
	CountTanks();
	if (iNumTanks == 0)
	{
		iTankWave = 2;
	}
}

public Action TimerTankWave3(Handle timer)
{
	CountTanks();
	if (iNumTanks == 0)
	{
		iTankWave = 3;
	}
}

public Action SpawnTankTimer(Handle timer)
{
	CountTanks();
	if (iTankWave == 1)
	{
		if (iNumTanks < iWave1Cvar)
		{
			int bot = CreateFakeClient("Tank");
			if (bot > 0)
			{
				SpawnInfected(bot, 8, true);
			}
		}
	}
	else if (iTankWave == 2)
	{
		if (iNumTanks < iWave2Cvar)
		{
			int bot = CreateFakeClient("Tank");
			if (bot > 0)
			{
				SpawnInfected(bot, 8, true);
			}
		}
	}
	else if (iTankWave == 3)
	{
		if (iNumTanks < iWave3Cvar)
		{
			int bot = CreateFakeClient("Tank");
			if (bot > 0)
			{
				SpawnInfected(bot, 8, true);
			}
		}
	}
}

public Action Timer_UnFreeze( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if (client > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			SetEntityRenderMode( client, view_as<RenderMode>( 3 ) );
			SetEntityRenderColor(client, 255, 255, 255, 255);
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
	}
}

public Action Timer_ResetGravity( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if (client > 0)
	{
		if (IsClientInGame(client))
		{
			SetEntityGravity(client, 1.0);
		}
	}
}

public Action Timer_AttachSPAWN(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == SPAWN_TANK)
	{
		AttachParticle(client, PARTICLE_SPAWN, 1.2, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_AttachFIRE(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == FIRE_TANK)
	{
		AttachParticle(client, PARTICLE_FIRE, 0.8, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_AttachFIRE_Rock(Handle hTimer, any EntityID)
{
	int entity = EntRefToEntIndex( EntityID );
	if (IsValidEntity(entity))
	{
		char  classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "tank_rock"))
		{
			IgniteEntity(entity, 100.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action Timer_AttachICE(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == ICE_TANK)
	{
		if( bL4DTwo )
			AttachParticle(client, PARTICLE_ICE, 2.0, 30.0);
		else 
			CreateParticle(client, PARTICLE_WATER, 2.0, 0.0);
		
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_SpitSound(Handle timer, any client)
{
	if (IsTank(client) && GetEntityRender_RGB(client) == SPITTER_TANK)
	{
		EmitSoundToAll("player/spitter/voice/warn/spitter_spit_02.wav", client);
	}
}

public Action Timer_AttachSPIT(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == SPITTER_TANK)
	{
		if( bL4DTwo )
			AttachParticle(client, PARTICLE_SPIT, 2.0, 30.0);
		else
			AttachParticle(client, PARTICLE_EMBERS, 1.0, 15.0 );
		
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_AttachSPIT_Rock(Handle hTimer, any EntityID)
{
	int entity = EntRefToEntIndex( EntityID );
	if (IsValidEntity(entity))
	{
		char sClassName[32];
		GetEdictClassname( entity, sClassName, sizeof( sClassName ) );
		if (StrEqual(sClassName, "tank_rock"))
		{
			AttachParticle(entity, PARTICLE_SPITPROJ, 0.8, 0.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action Timer_AttachELEC(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == SHOCK_TANK)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_AttachELEC_Rock(Handle hTimer, any EntityID)
{
	int entity = EntRefToEntIndex( EntityID );
	if (IsValidEntity(entity))
	{
		char  classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "tank_rock"))
		{
			AttachParticle(entity, PARTICLE_ELEC, 0.8, 0.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action Timer_AttachBLOOD(Handle timer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == WITCH_TANK)
	{
		AttachParticle(client, PARTICLE_BLOOD, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_AttachMETEOR(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId( UserID );
	if (IsTank(client) && GetEntityRender_RGB(client) == METEOR_TANK)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action ActivateShieldTimer(Handle timer, any client)
{
	ActivateShield(client);
}

stock void ActivateShield(int client)
{
	if (IsTank(client) && GetEntityRender_RGB(client) == SHIELD_TANK && ShieldsUp[client] == 0)
	{
		float Origin[3];
		GetClientAbsOrigin(client, Origin);
		Origin[2] -= 120.0;
		int entity = CreateEntityByName("prop_dynamic");
		if (IsValidEntity(entity))
		{
			char tName[64];
			Format(tName, sizeof(tName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", tName);
			GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(entity, "targetname", "Player");
			DispatchKeyValue(entity, "parentname", tName);
			DispatchKeyValue(entity, "model", "models/props_unique/airport/atlas_break_ball.mdl");
			DispatchKeyValueVector(entity, "origin", Origin);
			DispatchSpawn(entity);
			SetVariantString(tName);
			AcceptEntityInput(entity, "SetParent", entity, entity);
			AcceptEntityInput(entity, "DisableShadow"); // New funtion.
			SetEntityRenderMode(entity, view_as<RenderMode>( 3 ) );
			SetEntityRenderColor(entity, 25, 125, 125, 50);
			SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
			SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
		}
		ShieldsUp[client] = 1;
	}
}

stock void DeactivateShield(int client)
{
	if (IsTank(client) && GetEntityRender_RGB(client) == SHIELD_TANK && ShieldsUp[client] == 1)
	{
		int entity = -1;
		while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			char model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if (StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
			{
				int owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
				if (owner == client)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
		}
		CreateTimer(flShieldShieldsDownInterval, ActivateShieldTimer, client, TIMER_FLAG_NO_MAPCHANGE);
		ShieldsUp[client] = 0;
	}
}

stock void TeleportTank(int client)
{
	int random = GetRandomInt(1,iWarpTeleportDelay);
	if (random == 1)
	{
		int target = Pick();
		if (target)
		{
			float Origin[3], Angles[3];
			GetClientAbsOrigin(target, Origin);
			GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}

stock int CountWitches()
{
	int count;
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "witch")) != INVALID_ENT_REFERENCE)
	{
		count++;
	}
	return count;
}

stock void SpawnWitch(int client)
{
	int count;
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		if(count < 4 && CountWitches() < iWitchMaxWitches)
		{
			float TankPos[3], InfectedPoS[3], InfectedAng[3];
			GetClientAbsOrigin(client, TankPos);
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPoS);
			GetEntPropVector(entity, Prop_Send, "m_angRotation", InfectedAng);
			float distance = GetVectorDistance(InfectedPoS, TankPos);
			if(distance < 100.0)
			{
				AcceptEntityInput(entity, "Kill");
				int witch = CreateEntityByName("witch");
				DispatchSpawn(witch);
				ActivateEntity(witch);
				TeleportEntity(witch, InfectedPoS, InfectedAng, NULL_VECTOR);
				SetEntProp(witch, Prop_Send, "m_hOwnerEntity", WITCH_TANK);
				count++;
			}
		}
	}
}

/* ========================================================================================================== */

stock void HealTank(int client)
{
	int infectedfound = 0;
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		float TankPos[3], InfectedPoS[3];
		GetClientAbsOrigin(client, TankPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPoS);
		float distance = GetVectorDistance(InfectedPoS, TankPos);
		if (distance <= 500)
		{
			int health = GetEntProp(client, Prop_Send, "m_iHealth");
			int maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			if (health <= (maxhealth - iHealHealthCommons) && health > 500)
			{
//				SetEntProp(client, Prop_Data, "m_iHealth", health + iHealHealthCommons);
				SetEntityHealth( client, health + iHealHealthCommons ); // Corrección
			}
			else if (health > 500)
			{
//				SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				SetEntityHealth( client, maxhealth ); // Corrección
			}
			
			if (health > 500)
			{
				if( bL4DTwo )
				{
					int glowcolor = RGB_TO_INT(0, 185, 0);
				
					SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
					SetEntProp(client, Prop_Send, "m_iGlowType", 3);
					SetEntProp(client, Prop_Send, "m_bFlashing", 1);
					
					infectedfound = 1;
				}
			}
		}
	}
	
	for (int i = 1; i <= MaxClients; i ++)
	{
		if (IsSpecialInfected( i ))
		{
			float TankPos[3], InfectedPoS[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPoS);
			float distance = GetVectorDistance(TankPos, InfectedPoS);
			if (distance <= 500)
			{
				int health = GetEntProp(client, Prop_Send, "m_iHealth");
				int maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if (health <= (maxhealth - iHealHealthSpecials) && health > 500)
				{
//					SetEntProp(client, Prop_Data, "m_iHealth", health + iHealHealthSpecials);
					SetEntityHealth( client, health + iHealHealthSpecials ); // Corrección
				}
				else if (health > 500)
				{
//					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
					SetEntityHealth( client, maxhealth ); // Corrección
				}
				if (health > 500 && infectedfound < 2)
				{
					if( bL4DTwo )
					{
						int glowcolor = RGB_TO_INT(0, 220, 0);
						
						SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
						SetEntProp(client, Prop_Send, "m_iGlowType", 3);
						SetEntProp(client, Prop_Send, "m_bFlashing", 1);
						
						infectedfound = 1;
					}
				}
			}
		}
		else if (IsTank(i) && i != client)
		{
			float TankPos[3], InfectedPoS[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPoS);
			float distance = GetVectorDistance(TankPos, InfectedPoS);
			
			if (distance <= 500)
			{
				int health = GetEntProp(client, Prop_Send, "m_iHealth");
				int maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				
				if (health <= (maxhealth - iHealHealthTanks) && health > 500)
				{
//					SetEntProp(client, Prop_Data, "m_iHealth", health + iHealHealthTanks);
					SetEntityHealth( client, health + iHealHealthTanks ); // Corrección
				}
				else if (health > 500)
				{
//					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
					SetEntityHealth( client, maxhealth ); // Corrección
				}
				if (health > 500)
				{
					if( bL4DTwo )
					{
						int glowcolor = RGB_TO_INT(0, 255, 0);
					
						SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
						SetEntProp(client, Prop_Send, "m_iGlowType", 3);
						SetEntProp(client, Prop_Send, "m_bFlashing", 1);
					
						infectedfound = 2;
					}
				}
			}
		}
	}
	
	if( infectedfound == 0 )
	{
		if( bL4DTwo ) 
		{
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(client, Prop_Send, "m_iGlowType", 0);
			SetEntProp(client, Prop_Send, "m_bFlashing", 0);
		}
	}
}

stock void InfectedCloak(int client)
{
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsSpecialInfected(i))
		{
			float TankPos[3], InfectedPoS[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPoS);
			float distance = GetVectorDistance(TankPos, InfectedPoS);
			if (distance < 500)
			{
				SetEntityRenderMode( i, view_as<RenderMode>( 3 ) );
				SetEntityRenderColor(i, 255, 255, 255, 50 );
			}
			else
			{
				SetEntityRenderMode( i, view_as<RenderMode>( 3 ) );
				SetEntityRenderColor(i, 255, 255, 255, 255);
			}
		}
	}
}

stock int CountSurvRange(int client)
{
	int count = 0;
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			float TankPos[3], PlayerPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, PlayerPos);
			float distance = GetVectorDistance(TankPos, PlayerPos);
			if (distance > 120)
			{
				count++;
			}
		}
	}
	return count;
}

stock int GetEntityRender_RGB( int entity )
{	
	if ( entity > 0 )
	{
		int RGBA[4];
		char sRGBA[10];
		GetEntityRenderColor( entity, RGBA[0], RGBA[1], RGBA[2], RGBA[3] ); // Getting The Original Native Function.
		Format( sRGBA, sizeof( sRGBA ), "%i%i%i", RGBA[0], RGBA[1], RGBA[2] );
		int ColorIndex = StringToInt( sRGBA );
		return ColorIndex;
	}
	
	return 0;	
}

stock int RGB_TO_INT(int red, int green, int blue) 
{
	return (red * 65536) + (green * 256) + blue;
}

public Action OnPlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (bSuperTanksEnabled)
	{
		if (damage > 0.0 && IsValidClient(victim))
		{
			static char sClassName[32];
			if (GetClientTeam(victim) == 2)
			{
				if (IsWitch(attacker))
				{
					if (GetEntProp(attacker, Prop_Send, "m_hOwnerEntity") == WITCH_TANK)
					{
						damage = 16.0;
					}
				}
				else if (IsTank(attacker) && damagetype != 2)
				{
					int color = GetEntityRender_RGB(attacker);
					switch(color)
					{
						//Fire Tank
						case FIRE_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw") || StrEqual(sClassName, "weapon_tank_rock"))
							{
								SkillFlameClaw(victim);
							}
						}
						//Gravity Tank
						case GRAVITY_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw"))
							{
								SkillGravityClaw(victim);
							}
						}
						//Ice Tank
						case ICE_TANK:
						{
							int flags = GetEntityFlags(victim);
							if (flags & FL_ONGROUND)
							{
								if( GetRandomInt( 1, 3 ) == 1 )
								{
									SkillIceClaw(victim);
								}
							}
						}
						//Cobalt Tank
						case COBALT_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Smasher Tank
						case SMASHER_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw"))
							{
								if( GetRandomInt( 1, 2 ) == 1 )
								{
									SkillSmashClawKill(victim, attacker);
								}
								else
								{
									SkillSmashClaw(victim);
								}
							}
						}
						//Spawn Tank
						case SPAWN_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw"))
							{
								if( GetRandomInt( 1, 4 ) == 1 )
								{
									SDKCallVomitOnPlayer(victim, attacker);
								}
							}
						}
						//Shock Tank
						case SHOCK_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw"))
							{
								SkillElecClaw(victim, attacker);
							}
						}
						//Warp Tank
						case WARP_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_tank_claw"))
							{
								int dmg = RoundFloat( damage / 2 );
								DealDamagePlayer( victim, attacker, DMG_BULLET, dmg );
							}
						}
					}
				}
			}
			else if (IsTank(victim))
			{
				if ( damagetype == DMG_BURN || damagetype == DMG_PREVENT_PHYSICS_FORCE + DMG_BURN || damagetype == DMG_DIRECT + DMG_BURN ) // Nueva Definición
				{
					int index = GetSuperTankByRenderColor(GetEntityRender_RGB(victim));
					if (index >= 0 && index <= 16)
					{
						if (bTankFireImmunity[index])
						{
							if (index != 0 || (index == 0 && bDefaultOverride))
							{
								return Plugin_Handled;
							}
						}
					}
				}
				if (IsSurvivor(attacker))
				{
					int color = GetEntityRender_RGB(victim);
					switch(color)
					{
						//Fire Tank
						case FIRE_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_melee"))
							{
								if (GetRandomInt( 1, 4 ) == 1)
								{
									SkillFlameGush(victim);
								}
							}
							else if ( !bL4DTwo && StrEqual( sClassName, "player" ) )
							{
								if( GetRandomInt( 0, 100 ) == 100) // Hay mayor posibilidad de porcentaje con la escopeta debido a la cantidad de perdigones.
								{
									if( TankAbility[victim] == 0 )
									{
										SkillFlameGush( victim );
									}
								}
							}
						}
						//Meteor Tank
						case METEOR_TANK:
						{
							GetEdictClassname( inflictor, sClassName, sizeof(sClassName));
							if( StrEqual( sClassName, "weapon_melee" ) )
							{
								if (GetRandomInt( 1, 2 ) == 1)
								{
									if (TankAbility[victim] == 0)
									{
										StartMeteorFall(victim);
									}
								}
							}
							else if ( !bL4DTwo && StrEqual( sClassName, "player" ) )
							{
								if( GetRandomInt( 0, 100 ) <= 10 ) // Hay mayor posibilidad de porcentaje con la escopeta debido a la cantidad de perdigones.
								{
									if( TankAbility[victim] == 0 )
									{
										StartMeteorFall( victim );
									}
								}
							}
						}
						//Spitter Tank
						case SPITTER_TANK:
						{
							GetEdictClassname(inflictor, sClassName, sizeof(sClassName));
							if (StrEqual(sClassName, "weapon_melee"))
							{
								if( GetRandomInt( 1, 4 ) == 1 )
								{
									int x = CreateFakeClient("Spitter");
									if (x > 0)
									{
										float Pos[3];
										GetClientAbsOrigin(victim, Pos);
										TeleportEntity(x, Pos, NULL_VECTOR, NULL_VECTOR);	
										SDKCallSpitBurst( x );
										KickClient( x );
									}
								}
							}
						}
						//Ghost Tank
						case GHOST_TANK:
						{
							if( bGhostDisarm )
							{
								GetEdictClassname( inflictor, sClassName, sizeof( sClassName ) );
								if( StrEqual( sClassName, "weapon_melee" ) )
								{
									if( GetRandomInt( 1 , 4 ) == 1 )
									{
										ForceWeaponDrop( attacker, 1 );
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
								else if ( !bL4DTwo && StrEqual( sClassName, "player" ) )
								{
									if ( GetRandomInt( 1, 100 ) <= 10 ) 
									{
										ForceWeaponDrop( attacker, 0 );
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
							}
						}
						//Shield Tank
						case SHIELD_TANK:
						{
							if ( damagetype == DMG_BLAST || damagetype == DMG_BLAST_SURFACE + DMG_BLAST || damagetype == DMG_AIRBOAT || damagetype == DMG_PLASMA + DMG_BLAST ) // Nueva Función.
							{
								if( ShieldsUp[victim] == 1 )
								{
									DeactivateShield( victim );
								}
							}
							else
							{
								if( ShieldsUp[victim] == 1 )
								{
									return Plugin_Handled;
								}
							}
						}
					}
				}
			}
		}
	}
	
	return Plugin_Changed;
}

stock void DealDamagePlayer(int target, int attacker, int dmgtype, int dmg)
{
	if (target > 0 && target <= MaxClients)
	{
		if (IsClientInGame(target) && IsPlayerAlive(target))
		{
   	 		char damage[16];
			IntToString(dmg, damage, 16);
   	 		char type[16];
			IntToString(dmgtype, type, 16);
			int pointHurt = CreateEntityByName("point_hurt");
			if (pointHurt)
			{
				DispatchKeyValue(target, "targetname", "hurtme");
				DispatchKeyValue(pointHurt, "Damage", damage);
				DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");
				DispatchKeyValue(pointHurt, "DamageType", type);
				DispatchSpawn(pointHurt);
				AcceptEntityInput(pointHurt, "Hurt", attacker);
				AcceptEntityInput(pointHurt, "Kill");
				DispatchKeyValue(target, "targetname", "donthurtme");
			}
		}
	}
}

stock void DealDamageEntity(int target, int attacker, int dmgtype, int dmg)
{
	if (target > 32)
	{
		if (IsValidEntity(target))
		{
   	 		char damage[16];
			IntToString(dmg, damage, 16);
   	 		char type[16];
			IntToString(dmgtype, type, 16);
			int pointHurt = CreateEntityByName("point_hurt");
			if (pointHurt)
			{
				DispatchKeyValue(target, "targetname", "hurtme");
				DispatchKeyValue(pointHurt, "Damage", damage);
				DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");
				DispatchKeyValue(pointHurt, "DamageType", type);
				DispatchSpawn(pointHurt);
				AcceptEntityInput(pointHurt, "Hurt", attacker);
				AcceptEntityInput(pointHurt, "Kill");
				DispatchKeyValue(target, "targetname", "donthurtme");
			}
		}
	}
}

stock void ForceWeaponDrop( int client, int slot ) // Nueva Función.
{
	if( GetPlayerWeaponSlot( client, slot ) > 0 )
		SDKHooks_DropWeapon( client, GetPlayerWeaponSlot( client, slot ), NULL_VECTOR, NULL_VECTOR );
}

stock void ResetInfectedAbility(int client, float time)
{
	if (client > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
		{
			int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
			if (ability > 0)
			{
				SetEntPropFloat(ability, Prop_Send, "m_duration", time);
				SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + time);
			}
		}
	}
}

stock int GetNearestSurvivorDist(int client)
{
    float PlayerPos[3], TargetPos[3], NeaRest = 0.0, distance = 0.0;
    if(client > 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetClientAbsOrigin(client, PlayerPos);
   			for(int i = 1; i <= MaxClients; i++)
    		{
        		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
				{
					GetClientAbsOrigin(i, TargetPos);
					distance = GetVectorDistance(PlayerPos, TargetPos);
					if(NeaRest == 0.0)
					{
						NeaRest = distance;
					}
					else if(NeaRest > distance)
					{
						NeaRest = distance;
					}
				}
			}
		}
    }
    return RoundFloat(distance);
}

stock int GetSuperTankByRenderColor( int color )
{
	switch( color )
	{
		case DEFAULT_TANK: 	return 0; 	// Default Tank
		case SPAWN_TANK: 	return 1; 	// Spawn Tank
		case SMASHER_TANK: 	return 2; 	// Smasher Tank
		case WARP_TANK: 	return 3; 	// Warp Tank
		case METEOR_TANK: 	return 4; 	// Meteor Tank
		case SPITTER_TANK: 	return 5; 	// Spitter Tank
		case HEAL_TANK: 	return 6; 	// Heal Tank	
		case FIRE_TANK: 	return 7; 	// Fire Tank
		case ICE_TANK: 		return 8; 	// Ice Tank
		case JOCKEY_TANK: 	return 9; 	// Jockey Tank
		case GHOST_TANK: 	return 10; 	// Ghost Tank
		case SHOCK_TANK: 	return 11; 	// Shock Tank
		case WITCH_TANK: 	return 12; 	// Witch Tank
		case SHIELD_TANK: 	return 13; 	// Shield Tank
		case COBALT_TANK: 	return 14; 	// Cobalt Tank
		case JUMPER_TANK: 	return 15; 	// Jumper Tank
		case GRAVITY_TANK: 	return 16; 	// Gravity Tank
	}
	
	return -1;
}

//=============================
// COMMANDS
//=============================
stock void CheatCommand(int client, const char[] command, const char[] arguments)
{
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments );
	SetCommandFlags(command, flags | FCVAR_CHEAT);
}

stock void DirectorCommand(int client, char[] command)
{
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s", command);
	SetCommandFlags(command, flags | FCVAR_CHEAT);
}

//=============================
// GAMEFRAME
//=============================
public void OnGameFrame()
{
	if (!IsServerProcessing()) return;

	if (bSuperTanksEnabled)
	{
		iFrame++;
		if (iFrame >= 3)
		{
			for (int i=1; i<=MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
				{
					SpeedRebuild(i);
				}
			}
			iFrame = 0;
		}
	}
}

//=============================
// TIMER 0.1
//=============================
public Action TimerUpdate01(Handle hTimer)
{
	if (!IsServerProcessing()) return Plugin_Continue;

	if (bSuperTanksEnabled && bDisplayHealthCvar)
	{
		for (int i=1; i<=MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 2)
			{
				int entity = GetClientAimTarget(i, false);
				if (IsValidEntity(entity))
				{
					char sClassName[32];
					GetEdictClassname(entity, sClassName, sizeof(sClassName));
					if (StrEqual(sClassName, "player", false))
					{
						if (entity > 0)
						{
							if (IsTank(entity))
							{
								int health = GetClientHealth(entity);
								PrintHintTextToAll("%N (%d HP)", entity, health);
							}
						}
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

//=============================
// TIMER 1.0
//=============================
public Action TimerUpdate1(Handle hTimer)
{
	if (!IsServerProcessing()) return Plugin_Continue;

	if (bSuperTanksEnabled)
	{
		TankController();
//		FindConVar("z_max_player_zombies").IntValue = 32;
		for (int i=1; i<=MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) == 2)
				{
					if (PlayerSpeed[i] > 0)
					{
						PlayerSpeed[i] -= 1;
					}
				}
				else if (GetClientTeam(i) == 3)
				{
						int zombie = GetEntData(i, FindSendPropInfo("CTerrorPlayer", "m_zombieClass"));
						if (zombie == 8)
						{
							CreateTimer(3.0, TankLifeCheck, i, TIMER_FLAG_NO_MAPCHANGE);
						}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void LittleFlower(float pos[3], int type)
{
	/* Cause fire(type=0) or explosion(type=1) */
	int entity = CreateEntityByName("prop_physics");
	if (IsValidEntity(entity))
	{
		pos[2] += 10.0;
		if (type == 0)
			/* fire */
			DispatchKeyValue(entity, "model", "models/props_junk/gascan001a.mdl");
		else
			DispatchKeyValue(entity, "model", "models/props_junk/propanecanister001a.mdl");
		DispatchSpawn(entity);
		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "break");
	}
}

public void ShowParticle(float pos[3], char[] particlename, float time)
{
	/* Show particle effect you like */
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(time, DeleteParticles, particle);
	}  
}