/*
*	Prototype Grenades
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



#define PLUGIN_VERSION 		"1.48"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D & L4D2] Prototype Grenades
*	Author	:	SilverShot
*	Descrp	:	Creates a selection of different grenade types.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=318965
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.48 (30-Apr-2024)
	- Fixed physics objects not being pushed or broken if set within the config.
	- Fixed random rare crashes on map change. Thanks to "JustMadMan" for reporting.

1.47 (21-Apr-2024)
	- Added data setting "effect_types" for the "Extinguisher" type to set if the grenade can remove fires, boomer effect and Spitter acid. Requested by "blackbread183".
	- Fixed duplicate messages when equipping a grenade.

1.46 (22-Nov-2023)
	- Fixed not pushing the Witch. Thanks to "HarryPotter" for finding and fixing.

1.45 (07-Nov-2023)
	- Fixed the "Bullets" type damage becoming extremely high. Thanks to "HarryPotter" for finding and fixing.

1.44 (15-Jun-2022)
	- Added data setting "effect_freeze" for the "Freezer" type to set how long Survivors and Special Infected are frozen for. Requested by "weakestL4D2enjoyer".
	- Added data setting "damage_bonus" for the "Glow" type to set a damage multiplier while affected by the "Glow". Requested by "weakestL4D2enjoyer".
	- Changed the "BlackHole" type to not throw Survivors or Special Infected unless they are on the ground.
	- Changes to fix warnings when compiling on SourceMod 1.11.

1.43 (02-Feb-2022)
	- Fixed the "Medic" type not following the "targets" data settings. Thanks to "NoroHime" for reporting.
	- Fixed being able to select the "Airstrike" grenade type if disabled when using M2 to change types. Thanks to "KadabraZz" for reporting.

1.42 (29-Oct-2021)
	- Changed "Medic" grenade type to allow healing all targets specified, no longer only Survivors. Requested by "Dragokas".
	- Fixed "Bullets" and "Freezer" types not excluding the tank correctly.

1.41 (29-Sep-2021)
	- Changed method of creating an explosive to prevent it being visible (still sometimes shows, but probably less).

1.40 (19-Sep-2021)
	- Fixed users without access to the "sm_grenade" command from having different grenade modes when picking up grenades.
	- Thanks to "Darkwob" for reporting.

1.39 (25-Jul-2021)
	- Fixed index errors (replaced using "m_iHammerID" with a variable array). Thanks to "Elite Biker" for reporting.
	- L4D1: Fixed the "Airstrike" potentially showing in the menu.

1.38 (16-Jun-2021)
	- Added new grenade type "Weapon" to spawn weapons and items when the grenade explodes.
	- L4D2 only: Added new grenade type: "Airstrike" to call an Airstrike on the grenade explosion position. Requires the "F-18 Airstrike" plugin.
	- All translation files updated.
	- Config file updated.
	- Requested by "Darkwob"

1.37 (04-Jun-2021)
	- Now tests if clients have access to the "sm_grenade" command to restrict Prototype Grenades to specific users. Requested by "Darkwob".
	- Use the "sourcemod/configs/admin_overrides.cfg" to modify the command flags required.
	- Data config change: "Tesla" and "Black Hole" types no longer create a shake on explosion.

1.36 (10-Apr-2021)
	- Fixed not resetting gravity from the "Anti-Gravity" type when a client died. Thanks to "Voevoda" for reporting.

1.35 (27-Mar-2021)
	- L4D1: Fixed client console error about unknowing particle "sparks_generic_random" and "fireworks_sparkshower_01e" when using the "Flak" type.
	- Added "Flak" type "damage_type" config key value to specify which enemies catch on fire instead of stumble.
	- Changed "Flak" type damage to Blast instead of burn for Special Infected. Thanks to "sbeve" for reporting.
	- Data config "data/l4d_grenades.cfg" updated to reflect changes.

1.34 (04-Mar-2021)
	- Fixed affecting special infected ghosts. Thanks to "Voevoda" for reporting.

1.33 (23-Feb-2021)
	- Fixed errors caused by the last L4D2 update. Thanks to "sonic155" for reporting.

1.32 (15-Feb-2021)
	- Fixed healing with full health when players are black and white.

1.31 (30-Sep-2020)
	- Fixed compile errors on SM 1.11.

1.30a (24-Sep-2020)
	- Compatibility update for L4D2's "The Last Stand" update.
	- GameData .txt file updated.

1.30 (20-Sep-2020)
	- Fixed not working in L4D1 due to various L4D2 specific things not being ignored.
	- GameData for L4D1 updated to fix "CTerrorPlayer::OnStaggered" not being found when detoured by Left4DHooks.

1.29 (18-Sep-2020)
	- L4D2 only: Added new config keys "damage_acid_comm", "damage_acid_self", "damage_acid_spec" and "damage_acid_surv".
	- These control the "Chemical" type acid puddle damage. Thanks to "SilentBr" for requesting.
	- Data config "data/l4d_grenades.cfg" updated to reflect changes.

1.28 (10-Sep-2020)
	- Fixed "Glow" type not causing any damage. Thanks to "simvolist777" for reporting.

1.27 (01-Sep-2020)
	- Fixed "Glow" type not instantly removing on player death. Thanks to "piggies" for reporting.

1.26 (27-Aug-2020)
	- Fixed "mode_switch" option to block keybind control when using "2" value. Thanks to "Winn" for reporting.

1.25 (15-Jul-2020)
	- Added more checks to prevent gravity reset error. Thanks to "Voevoda" for reporting.

1.24 (14-May-2020)
	- Fixed grenade types not detonating on impact due to accidental deletion in 1.23 update.
	- Replaced some "point_hurt" damage calls with "SDKHooks_TakeDamage" function.
	- Support for compiling on SourceMod 1.11.

1.23 (10-May-2020)
	- Added better error log message when gamedata file is missing.
	- Added random grenade spin when thrown if Left4DHooks is detected.
	- Extra checks to prevent "IsAllowedGameMode" throwing errors.
	- Fixed grenades not sticking if enabled, unless they hit a client.
	- Various changes to tidy up code.
	- Various optimizations and fixes.

1.22 (01-Apr-2020)
	- Fixed "IsAllowedGameMode" from throwing errors when the "_tog" cvar was changed before MapStart.
	- Fixed not precaching "env_shake" which caused stutter on first explosion.

1.21 (03-Mar-2020)
	- Fixed 2 particles missing from being precached. Thanks to "foxhound27" for reporting.

1.20 (29-Feb-2020)
	- Fixed conflict with "Detonation Force" plugin. Thanks to "hoanganh81097" for reporting.
	- This will also fix conflicts with any other plugin detecting when a grenade projectile is destroyed.

1.19 (04-Feb-2020)
	- Fixed dissolve from "Vaporizer" type potentially causing godmode zombies.

1.18 (03-Feb-2020)
	- Fixed conflict with "Bile The World" plugin. Thanks to "3aljiyavslgazana" for reporting.
	- Plugin now compiled with SoureMod 1.10. Recompile yourself or time to upgrade your installation.

1.17 (13-Jan-2020)
	- Fixed players "semi-falling" when colliding the grenade. Thanks to "Dragokas" for reporting a fix.

1.16 (05-Jan-2020)
	- Added additional checks to prevent OnWeaponEquip errors. Thanks to "Mr. Man" for reporting.
	- Added Traditional Chinese translations. Thanks to "fbef0102" for providing.

1.15 (29-Nov-2019)
	- Added "messages" option in the config to disable hint messages as requested by "BlackSabbarh".
	- Fixed "preferences" option "0" not resetting grenade type when players take over bots. Thanks to "Voevoda" for reporting.

1.14 (24-Nov-2019)
	- Added Simplified Chinese translations. Thanks to "asd2323208" for providing.
	- Fix for potential godmode zombies when using LMC.
	- Fixed error msg: "Entity 157 (class 'pipe_bomb_projectile') reported ENTITY_CHANGE_NONE but 'm_flCreateTime' changed.".

1.13 (11-Nov-2019)
	- Added option "0" to "preferences" in the config to give stock grenades on pickup.

1.12 (10-Nov-2019)
	- Fixed breaking client preferences after map change due to last version fixes.

1.11 (09-Nov-2019)
	- Small optimizations.
	- Fixed breaking equip on round restart.
	- Fixed "Shield" type not working. Thanks to "fbef0102" for reporting.

1.10 (01-Nov-2019)
	- Changed the way grenade bounce sounds are replaced to prevent plugin conflicts. Thanks to "Lux" for the idea.
	- Optimizations: Changed string creation to static char for faster CPU cycles. Various string comparison changes.
	- Now only supports "Gear Transfer" plugin version 2.0 or greater to preserve random grenade type preferences.
	- Removed 1 frame delay on weapon equip from previous version of supporting "Gear Transfer" plugin.
	- Fixed "GrenadeMenu_Invalid" PrintToChat not replacing the colors. Thanks to "BHaType" for reporting.

1.9 (23-Oct-2019)
	- Fixed "Freezer" mode not preserving special infected render color. Thanks to "Dragokas" for reporting.

1.8 (23-Oct-2019)
	- Changed "Bullets" mode projectile sound.
	- Maybe fixed invalid entity errors again, reported by "KRUTIK".
	- Minor changes to late loading and turning the plugin on/off.

1.7 (18-Oct-2019)
	- Fixed handle memory leak.

1.6 (18-Oct-2019)
	- Fixed invalid entity errors reported by "KRUTIK".
	- Fixed L4D1 errors reported by "Dragokas".
	- Fixed not completely disabling everything when the plugin is turned off.
	- Now prevents ledge hanging when floating in Anti-Gravity.

1.5 (17-Oct-2019)
	- Added 6 new types: "Extinguisher", "Glow", "Anti-Gravity", "Fire Cluster", "Bullets" and "Flak".
	- Added command "sm_grenade" to open a menu for choosing the grenade type. Optional args to specify a type.
	- Added "mode_switch" in the config to control how to change grenade type. Menu and/or key combination.
	- Auto display and close menu with "mode_switch" when selecting a different type via key combination.
	- Changed L4D2 vocalizations from "throwing pipebomb" or "throwing molotov" etc to "throwing grenade" when not stock.
	- Changed grenade bounce impact sound.
	- Cleaned up the sounds by changing some and adding a few missing ones.
	- Feature to push and stumble Common Infected now works in L4D1.
	- Fixed wrong Deafen offset for L4D1 Linux. Fixes "Flashbang".
	- Fixed wrong OnStaggered signature for Linux L4D1. Fixes staggering clients.
	- Fixed "Freezer" type not following the "targets" setting.
	- Fixed "damage_tick" to function for most types. Values smaller than "effect_tick" will use the effect tick time.
	- Thanks to "Dragokas" for the menu ideas and reporting problems in L4D1.

	- Required updated files:
	- Config: l4d_grenades.cfg
	- Gamedata: l4d_grenades.txt
	- Translations: grenades.phrases.txt.

1.4 (10-Oct-2019)
	- Added Russian translations. Thanks to "KRUTIK" for providing.
	- Fixed OnNextEquip errors. Thanks to "KRUTIK" for reporting.

1.3 (10-Oct-2019)
	- Added support for "Gear Transfer" plugin. For persistent grenade types when "preferences" is set to random grenade mode.
	- Changed "Vaporizer" to inflict full damage on Common instead of range scaled. Original functionality before 1.1.

1.2 (10-Oct-2019)
	- Fixed OnWeaponDrop errors. Thanks to "BlackSabbarh" for reporting.
	- Some optimizations.

1.1 (08-Oct-2019)
	- Added "bots" in the config to control if bots can use Prototype Grenades. Requires external plugin.
	- Added "damage_special", "damage_survivors", "damage_tank", "damage_witch" and "damage_physics" in the config to scale damage.
	- Added "preferences" in the config to save a players selected mode, or give a random grenade type. Persistent with dropping.
	- Added "targets" in the config to control who can be affected by the grenade effects.
	- Changed "nade" in the config to use bit flags, which allows all grenade modes to work for all grenades.
	- Fixed map transition breaking the ability to change grenade modes.
	- Fixed over-healing when a player has temp health.
	- Fixed sometimes detonating immediately after throwing.
	- Fixed sounds not stopping when reloading the plugin during an active grenade.
	- Updated data config, plugin requires new version, or effects will break: l4d_grenades.cfg.

1.0 (03-Oct-2019)
	- Initial release.

========================================================================================
	Thanks:

	This plugin was made using source code from the following plugins.
	If I have used your code and not credited you, please let me know.

*	Thanks to "Lux" for "L4D_TE_Create_Particle" - stock function.
	https://gist.github.com/LuxLuma/73a8fab2b5f44ef800070bfd5e7fe257

*	Thanks to "AtomicStryker" for "[L4D & L4D2] Smoker Cloud Damage" - Modified IsVisibleTo() function.
	https://forums.alliedmods.net/showthread.php?p=866613

*	"Zuko & McFlurry" for "[L4D2] Weapon/Zombie Spawner" - Modified SetTeleportEndPoint() function.
	https://forums.alliedmods.net/showthread.php?t=109659

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>



//LMC
#undef REQUIRE_PLUGIN
#tryinclude <LMCCore>
#define REQUIRE_PLUGIN

#if !defined _LMCCore_included
	native int LMC_GetEntityOverlayModel(int iEntity);
#endif

bool	g_bLMC_Available;
//LMC



// DEFINES
#define CVAR_FLAGS				FCVAR_NOTIFY
#define CONFIG_DATA				"data/l4d_grenades.cfg"
#define GAMEDATA				"l4d_grenades"
#define GLOW_COLOR				38655 // Glow Mode color: GetColor("255 150 0");

#define EXT_FIRES (1<<0)
#define EXT_VOMIT (1<<1)
#define EXT_SPITS (1<<2)


// EFFECTS
#define MODEL_BOUNDING			"models/props/cs_militia/silo_01.mdl"
#define MODEL_CRATE				"models/props_junk/explosive_box001.mdl"
#define MODEL_GASCAN			"models/props_junk/gascan001a.mdl"
#define MODEL_SPRAYCAN			"models/props_junk/garbage_spraypaintcan01a.mdl"
#define MODEL_SPRITE			"models/sprites/glow01.spr"

#define PARTICLE_MUZZLE			"weapon_muzzle_flash_autoshotgun"
#define PARTICLE_BASHED			"screen_bashed"
#define PARTICLE_TRACERS		"weapon_tracers"
#define PARTICLE_TRACER_50		"weapon_tracers_50cal"
#define PARTICLE_SMOKER1		"smoker_smokecloud_cheap"
#define PARTICLE_SMOKER2		"smoker_spore_trail"
#define PARTICLE_BOOMER			"boomer_explode_E"
#define PARTICLE_SMOKE2			"apc_wheel_smoke2" // White smoke
#define PARTICLE_BURST			"gas_explosion_initialburst" // Large explosion
#define PARTICLE_BLAST			"gas_explosion_initialburst_blast" // Large explosion HD
#define PARTICLE_BLAST2			"weapon_pipebomb_water_child_fire" // Cluster explosion
#define PARTICLE_MINIG			"weapon_muzzle_flash_minigun" // Constant white flashing glow
#define PARTICLE_STEAM			"steam_long" // Small water steam
#define PARTICLE_BLACK			"smoke_window" // Large black smoke
#define PARTICLE_SMOKER			"smoker_smokecloud" // Smoker cloud
#define PARTICLE_IMPACT			"impact_steam" // Long water impact, points in 1 direction
#define PARTICLE_VOMIT			"boomer_vomit"
#define PARTICLE_TRAIL			"water_trail_directional"
#define PARTICLE_SPLASH			"weapon_pipebomb_water_splash" // Large water splash
#define PARTICLE_PIPE1			"weapon_pipebomb" // Explosion
#define PARTICLE_PIPE2			"weapon_pipebomb_child_fire" // Medium blast
#define PARTICLE_PIPE3			"weapon_pipebomb_water_child_flash" // Flash
#define PARTICLE_CHARGE			"charger_wall_impact_b"
#define PARTICLE_FLARE			"flare_burning"
#define PARTICLE_SPIT_T			"spitter_projectile_trail_old"
#define PARTICLE_SPIT_P			"spitter_projectile_explode"
#define PARTICLE_SMOKE			"apc_wheel_smoke1"
#define PARTICLE_DEFIB			"item_defibrillator_body"
#define PARTICLE_ELMOS			"st_elmos_fire_cp0"
#define PARTICLE_TES1			"electrical_arc_01"
#define PARTICLE_TES2			"electrical_arc_01_system"
#define PARTICLE_TES3			"st_elmos_fire"
#define PARTICLE_TES6			"impact_ricochet_sparks"
#define PARTICLE_TES7			"railroad_wheel_sparks"
#define PARTICLE_GSPARKS		"sparks_generic_random"
#define PARTICLE_SPARKS			"fireworks_sparkshower_01e"
#define PARTICLE_FIREWORK		"mini_fireworks"

#define SOUND_SHOOTING			"weapons/flash/flash01.wav"
#define SOUND_EXPLODE3			"weapons/hegrenade/explode3.wav"
#define SOUND_EXPLODE5			"weapons/hegrenade/explode5.wav"
#define SOUND_FIREWORK1			"ambient/atmosphere/firewerks_burst_01.wav"
#define SOUND_FIREWORK2			"ambient/atmosphere/firewerks_burst_02.wav"
#define SOUND_FIREWORK3			"ambient/atmosphere/firewerks_burst_03.wav"
#define SOUND_FIREWORK4			"ambient/atmosphere/firewerks_burst_04.wav"
#define SOUND_FREEZER			"physics/glass/glass_impact_bullet4.wav"
#define SOUND_BUTTON1			"buttons/blip2.wav"
#define SOUND_BUTTON2			"ui/menu_countdown.wav"
#define SOUND_FLICKER			"ambient/spacial_loops/lights_flicker.wav"
#define SOUND_GAS				"ambient/gas/cannister_loop.wav"
#define SOUND_GATE				"ambient/machines/floodgate_stop1.wav"
#define SOUND_NOISE				"ambient/atmosphere/noise2.wav"
#define SOUND_SPATIAL			"ambient/spacial_loops/computer_spatial_amb_loop.wav"
#define SOUND_SQUEAK			"ambient/random_amb_sfx/randommetalsqueak01.wav"
#define SOUND_STEAM				"ambient/gas/steam_loop1.wav"
#define SOUND_TUNNEL			"ambient/atmosphere/tunnel1.wav"
#define SOUND_SPLASH1			"ambient/water/water_splash1.wav"
#define SOUND_SPLASH2			"ambient/water/water_splash2.wav"
#define SOUND_SPLASH3			"ambient/water/water_splash3.wav"
#define SOUND_GIFT				"items/suitchargeok1.wav"

#define SPRITE_BEAM				"materials/sprites/laserbeam.vmt"
#define SPRITE_HALO				"materials/sprites/glow01.vmt"
#define SPRITE_GLOW				"sprites/blueglow1.vmt"
// L4D2 client? is missing "sprites/blueglow1.vmt" - used by env_entity_dissolver.
// Precache prevents server's error message, and clients can attempt to precache before round_start to avoid any possible stutter on the first attempt live in-game
// Error messages:
// Client:		Unable to load sprite material materials/sprites/blueglow1.vmt!
// Server:		Late precache of sprites/blueglow1.vmt

static const char g_sSoundsHit[][]	=
{
	"physics/plastic/plastic_barrel_impact_soft1.wav",
	"physics/plastic/plastic_barrel_impact_soft2.wav",
	"physics/plastic/plastic_barrel_impact_soft3.wav",
	"physics/plastic/plastic_barrel_impact_soft4.wav",
	"physics/plastic/plastic_barrel_impact_soft5.wav",
	"physics/plastic/plastic_barrel_impact_soft6.wav"
};

static const char g_sSoundsMiss[][]	=
{
	"weapons/fx/nearmiss/bulletltor08.wav",
	"weapons/fx/nearmiss/bulletltor10.wav",
	"weapons/fx/nearmiss/bulletltor11.wav",
	"weapons/fx/nearmiss/bulletltor13.wav",
	"weapons/fx/nearmiss/bulletltor14.wav"
};

static const char g_sSoundsZap[][]	=
{
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
};

// Grenade vocalizations unused by default. Maybe more, only briefly checked.
static const char g_sSoundsMissing[][]	=
{
	"player/survivor/voice/gambler/grenade10.wav",
	"player/survivor/voice/gambler/grenade12.wav"
};

// Weapons
#define	MAX_WEAPONS			10
#define	MAX_WEAPONS2		29
#define	MAX_MELEE			13

static char g_sWeapons[MAX_WEAPONS][] =
{
	"weapon_rifle",
	"weapon_autoshotgun",
	"weapon_hunting_rifle",
	"weapon_smg",
	"weapon_pumpshotgun",
	"weapon_pistol",
	"weapon_molotov",
	"weapon_pipe_bomb",
	"weapon_first_aid_kit",
	"weapon_pain_pills"
};
static char g_sWeaponModels[MAX_WEAPONS][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_pistol_a.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_medkit.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl"
};
static char g_sWeapons2[MAX_WEAPONS2 + MAX_MELEE][] =
{
	"weapon_rifle",
	"weapon_autoshotgun",
	"weapon_hunting_rifle",
	"weapon_smg",
	"weapon_pumpshotgun",
	"weapon_shotgun_chrome",
	"weapon_rifle_desert",
	"weapon_grenade_launcher",
	"weapon_rifle_m60",
	"weapon_rifle_ak47",
	"weapon_shotgun_spas",
	"weapon_smg_silenced",
	"weapon_sniper_military",
	"weapon_chainsaw",
	"weapon_rifle_sg552",
	"weapon_smg_mp5",
	"weapon_sniper_awp",
	"weapon_sniper_scout",
	"weapon_pistol",
	"weapon_pistol_magnum",
	"weapon_molotov",
	"weapon_pipe_bomb",
	"weapon_vomitjar",
	"weapon_first_aid_kit",
	"weapon_defibrillator",
	"weapon_pain_pills",
	"weapon_adrenaline",
	"weapon_upgradepack_explosive",
	"weapon_upgradepack_incendiary",
	"fireaxe",
	"baseball_bat",
	"cricket_bat",
	"crowbar",
	"frying_pan",
	"golfclub",
	"electric_guitar",
	"katana",
	"machete",
	"tonfa",
	"knife",
	"pitchfork",
	"shovel"
};
static char g_sWeaponModels2[MAX_WEAPONS2][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl",
	"models/w_models/weapons/w_grenade_launcher.mdl",
	"models/w_models/weapons/w_m60.mdl",
	"models/w_models/weapons/w_rifle_ak47.mdl",
	"models/w_models/weapons/w_shotgun_spas.mdl",
	"models/w_models/weapons/w_smg_a.mdl",
	"models/w_models/weapons/w_sniper_military.mdl",
	"models/weapons/melee/w_chainsaw.mdl",
	"models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_sniper_awp.mdl",
	"models/w_models/weapons/w_sniper_scout.mdl",
	"models/w_models/weapons/w_pistol_a.mdl",
	"models/w_models/weapons/w_desert_eagle.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_bile_flask.mdl",
	"models/w_models/weapons/w_eq_medkit.mdl",
	"models/w_models/weapons/w_eq_defibrillator.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",
	"models/w_models/weapons/w_eq_adrenaline.mdl",
	"models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"models/w_models/weapons/w_eq_incendiary_ammopack.mdl"
};



// ARRAYS etc
#define MAX_ENTS			2048									// Max ents
#define MAX_DATA			16										// Total data entries to read from a grenades config.
#define MAX_TYPES			20										// Number of grenade types.
#define MAX_WAIT			0.2										// Delay between +USE mode changes.
#define BEAM_OFFSET			100.0									// Increase beam diameter by this value to correct visual size.
#define BEAM_RINGS			5										// Number of beam rings.
#define SHAKE_RANGE			150.0									// How far to increase the shake from the effect range.

float	g_fLastTesla[MAX_ENTS];										// Last time damage taken, used by Tesla mode.
float	g_fLastEquip[MAXPLAYERS+1];									// Last time a weapon was equipped, prevent duplicate messages
float	g_fLastFreeze[MAXPLAYERS+1];								// Last time in the freezer area.
float	g_fLastShield[MAXPLAYERS+1];								// Last time in the shield, for damage hook.
float	g_fLastUse[MAXPLAYERS+1];									// Clients last time pressing +USE.
bool	g_bChangingTypesMenu[MAXPLAYERS+1];							// Store when clients are changing type, to close menu when ended.
int		g_iClientGrenadeType[MAXPLAYERS+1] = { -1, ... };			// The current mode a player has selected
int		g_iClientGrenadePref[MAXPLAYERS+1][3];						// Client cookie preferences - mode client last used for all grenades

float	g_GrenadeData[MAX_TYPES][MAX_DATA];							// Config data for all grenade modes.
int		g_GrenadeSlot[MAX_TYPES][2];								// [0]=L4D2, [1]=L4D1. Which grenade slot the grenade mode uses.
int		g_GrenadeTarg[MAX_TYPES];									// Who the grenade affects.
int		g_GrenadeType[2048];										// The type of grenade selected.
int		g_BeamSprite, g_HaloSprite;									// Beam Rings
int		g_fConfigExtEffect;											// Extinguisher - Effect modes
float	g_fConfigAcidComm;											// Chemical Mode - Acid damage - Common
float	g_fConfigAcidSelf;											// Chemical Mode - Acid damage - Self
float	g_fConfigAcidSpec;											// Chemical Mode - Acid damage - Special Infected
float	g_fConfigAcidSurv;											// Chemical Mode - Acid damage - Survivors
float	g_fConfigGlowBonus;											// Glow mode - damage bonus
float	g_fConfigFreezeTime;										// Freeze mode - freeze time
int		g_iConfigDmgType;											// Damage type. Only used for Flak type.
int		g_iConfigBots;												// Can bots use Prototype Grenades
int		g_iConfigStock;												// Which grenades have their default feature.
int		g_iConfigTypes;												// Which grenade modes are allowed.
int		g_iConfigBinds;												// Menu or Pressing keys to change mode.
int		g_iConfigMsgs;												// Display chat messages?
int		g_iConfigPrefs;												// Client preferences save/load mode or give random mode.
float	g_fConfigSurvivors;											// Survivors damage multiplier.
float	g_fConfigSpecial;											// Special Infected damage multiplier.
float	g_fConfigTank;												// Tank damage multiplier.
float	g_fConfigWitch;												// Witch damage multiplier.
float	g_fConfigPhysics;											// Physics props damage multiplier.
int		g_iEntityHurt;												// Hurt entity.
int		g_iParticleTracer;											// Particle index for TE.
int		g_iParticleTracer50;
int		g_iParticleBashed;
UserMsg	g_FadeUserMsgId;



// Optional natives related
bool g_bLeft4DHooks, g_bAirstrike, g_bAirstrikeValid;

// Optional native from Left4DHooks
native void L4D_OnITExpired(int client);
native int L4D_AngularVelocity(int entity, const float vecAng[3]);

// Optional native from L4D2 Airstrike
native void F18_ShowAirstrike(float origin[3], float direction);



// VARS - Weapons
ConVar g_hAmmoAutoShot, g_hAmmoChainsaw, g_hAmmoGL, g_hAmmoHunting, g_hAmmoM60, g_hAmmoRifle, g_hAmmoShotgun, g_hAmmoSmg, g_hAmmoSniper;
int g_iAmmoAutoShot, g_iAmmoChainsaw, g_iAmmoGL, g_iAmmoHunting, g_iAmmoM60, g_iAmmoRifle, g_iAmmoShotgun, g_iAmmoSmg, g_iAmmoSniper;
int g_iTotalChance, g_iChances[MAX_WEAPONS2 + MAX_MELEE];

// VARS
Handle g_hSDK_DissolveCreate, g_hSDK_ActivateSpit, g_hSDK_StaggerClient, g_hSDK_DeafenClient;
ConVar g_hCvarAllow, g_hDecayDecay, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog;
bool g_bCvarAllow, g_bMapStarted, g_bLeft4Dead2, g_bLateLoad, g_bHookFire, g_bBlockHook, g_bBlockSound;
int g_iClassTank, m_maxHealth;
Handle g_hCookie;
ArrayList g_hAlAcid;
bool g_bAcidSpawn;

enum
{
	INDEX_BOMB = 0,
	INDEX_CLUSTER,
	INDEX_FIREWORK,
	INDEX_SMOKE,
	INDEX_BLACKHOLE,
	INDEX_FLASHBANG,
	INDEX_SHIELD,
	INDEX_TESLA,
	INDEX_CHEMICAL,
	INDEX_FREEZER,
	INDEX_MEDIC,
	INDEX_VAPORIZER,
	INDEX_EXTINGUISHER,
	INDEX_GLOW,
	INDEX_ANTIGRAVITY,
	INDEX_FIRECLUSTER,
	INDEX_BULLETS,
	INDEX_FLAK,
	INDEX_AIRSTRIKE,
	INDEX_WEAPON
}

enum
{
	CONFIG_ELASTICITY = 0,
	CONFIG_GRAVITY,
	CONFIG_DMG_PHYSICS,
	CONFIG_DMG_SPECIAL,
	CONFIG_DMG_SURVIVORS,
	CONFIG_DMG_TANK,
	CONFIG_DMG_WITCH,
	CONFIG_DAMAGE,
	CONFIG_DMG_TICK,
	CONFIG_FUSE,
	CONFIG_SHAKE,
	CONFIG_STICK,
	CONFIG_STUMBLE,
	CONFIG_RANGE,
	CONFIG_TICK,
	CONFIG_TIME
}

enum
{
	TARGET_COMMON = 0,
	TARGET_SURVIVOR,
	TARGET_SPECIAL,
	TARGET_TANK,
	TARGET_WITCH,
	TARGET_PHYSICS
}



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Prototype Grenades",
	author = "SilverShot",
	description = "Creates a selection of different grenade types.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=318965"
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

	MarkNativeAsOptional("LMC_GetEntityOverlayModel"); // LMC
	MarkNativeAsOptional("L4D_AngularVelocity");
	MarkNativeAsOptional("F18_ShowAirstrike");

	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] sName)
{
	if( strcmp(sName, "LMCEDeathHandler") == 0 )
		g_bLMC_Available = true;
	else if( strcmp(sName, "left4dhooks") == 0 )
		g_bLeft4DHooks = true;
	else if( g_bLeft4Dead2 && strcmp(sName, "l4d2_airstrike") == 0 )
	{
		g_bAirstrike = true;

		// Assuming valid for late load
		if( g_bLateLoad )
			g_bAirstrikeValid = true;
	}
}

public void OnLibraryRemoved(const char[] sName)
{
	if( strcmp(sName, "LMCEDeathHandler") == 0 )
		g_bLMC_Available = false;
	else if( strcmp(sName, "left4dhooks") == 0 )
		g_bLeft4DHooks = false;
	else if( g_bLeft4Dead2 && strcmp(sName, "l4d2_airstrike") == 0 )
		g_bAirstrike = true;
}

public void OnPluginStart()
{
	// ====================================================================================================
	// GAMEDATA
	// ====================================================================================================
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA);
	if( FileExists(sPath) == false ) SetFailState("\n==========\nMissing required file: \"%s\".\nRead installation instructions again.\n==========", sPath);

	Handle hGameData = LoadGameConfigFile(GAMEDATA);
	if( hGameData == null ) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	// Deafen
	StartPrepSDKCall(SDKCall_Player);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "CTerrorPlayer::Deafen") == false )
		SetFailState("Failed to find signature: CTerrorPlayer::Deafen");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hSDK_DeafenClient = EndPrepSDKCall();
	if( g_hSDK_DeafenClient == null )
		SetFailState("Failed to create SDKCall: CTerrorPlayer::Deafen");

	// Dissolve
	StartPrepSDKCall(SDKCall_Static);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CEntityDissolve_Create") == false )
		SetFailState("Could not load the \"CEntityDissolve_Create\" gamedata signature.");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDK_DissolveCreate = EndPrepSDKCall();
	if( g_hSDK_DissolveCreate == null )
		SetFailState("Could not prep the \"CEntityDissolve_Create\" function.");

	// Stagger
	StartPrepSDKCall(SDKCall_Player);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::OnStaggered") == false )
		SetFailState("Could not load the 'CTerrorPlayer::OnStaggered' gamedata signature.");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDK_StaggerClient = EndPrepSDKCall();
	if( g_hSDK_StaggerClient == null )
		SetFailState("Could not prep the 'CTerrorPlayer::OnStaggered' function.");

	// Spitter Projectile
	if( g_bLeft4Dead2 )
	{
		StartPrepSDKCall(SDKCall_Static);
		if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Create") == false )
			SetFailState("Could not load the \"CSpitterProjectile_Create\" gamedata signature.");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hSDK_ActivateSpit = EndPrepSDKCall();
		if( g_hSDK_ActivateSpit == null )
			SetFailState("Could not prep the \"CSpitterProjectile_Create\" function.");
	}

	delete hGameData;



	// ====================================================================================================
	// CVARS
	// ====================================================================================================
	g_hCvarAllow = CreateConVar(	"l4d_grenades_allow",			"1",					"0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	g_hCvarModes = CreateConVar(	"l4d_grenades_modes",			"",						"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff = CreateConVar(	"l4d_grenades_modes_off",		"",						"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog = CreateConVar(	"l4d_grenades_modes_tog",		"0",					"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	CreateConVar(					"l4d_grenades_version",			PLUGIN_VERSION,			"Prototype Grenades plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,			"l4d_grenades");

	g_hDecayDecay = FindConVar("pain_pills_decay_rate");
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);

	// Weapons
	g_hAmmoRifle =			FindConVar("ammo_assaultrifle_max");
	g_hAmmoSmg =			FindConVar("ammo_smg_max");
	g_hAmmoHunting =		FindConVar("ammo_huntingrifle_max");

	g_hAmmoRifle.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoSmg.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoHunting.AddChangeHook(ConVarChanged_Cvars);

	if( g_bLeft4Dead2 )
	{
		g_hAmmoShotgun =	FindConVar("ammo_shotgun_max");
		g_hAmmoGL =			FindConVar("ammo_grenadelauncher_max");
		g_hAmmoChainsaw =	FindConVar("ammo_chainsaw_max");
		g_hAmmoAutoShot =	FindConVar("ammo_autoshotgun_max");
		g_hAmmoM60 =		FindConVar("ammo_m60_max");
		g_hAmmoSniper =		FindConVar("ammo_sniperrifle_max");

		g_hAmmoGL.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoChainsaw.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoAutoShot.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoM60.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoSniper.AddChangeHook(ConVarChanged_Cvars);
	} else {
		g_hAmmoShotgun =	FindConVar("ammo_buckshot_max");
	}

	g_hAmmoShotgun.AddChangeHook(ConVarChanged_Cvars);



	// ====================================================================================================
	// COMMANDS
	// ====================================================================================================
	RegConsoleCmd("sm_grenade",			Cmd_Grenade, 	"Opens a menu to choose the current grenades mode. Force change with args, usage: sm_grenade [type: 1 - 20]");
	RegAdminCmd("sm_grenade_reload",	Cmd_Reload,		ADMFLAG_ROOT, "Reloads the settings config.");
	RegAdminCmd("sm_grenade_spawn",		Cmd_SpawnSpawn,	ADMFLAG_ROOT, "Spawn grenade explosions: <type: 1 - 20>");
	RegAdminCmd("sm_grenade_throw",		Cmd_SpawnThrow,	ADMFLAG_ROOT, "Spawn grenade projectile: <type: 1 - 20>");



	// ====================================================================================================
	// OTHER
	// ====================================================================================================
	// Translations
	BuildPath(Path_SM, sPath, sizeof(sPath), "translations/grenades.phrases.txt");
	if( !FileExists(sPath) )
		SetFailState("Required translation file is missing: 'translations/grenades.phrases.txt'");

	LoadTranslations("grenades.phrases");



	// Saved client options
	g_hCookie = RegClientCookie("l4d_grenades_modes", "Prototype Grenades - Modes", CookieAccess_Protected);



	// Max char health
	m_maxHealth = FindSendPropInfo("CTerrorPlayerResource", "m_maxHealth");



	// UserMsg
	g_FadeUserMsgId = GetUserMessageId("Fade");



	// Late load
	if( g_bLateLoad )
	{
		LoadDataConfig();
		IsAllowed();
	}

	g_iClassTank = g_bLeft4Dead2 ? 8 : 5;

	if( g_bLeft4Dead2 )
		g_hAlAcid = new ArrayList();
}

public void OnPluginEnd()
{
	ResetPlugin(true);
}



// ====================================================================================================
//					CLIENT PREFS
// ====================================================================================================
public void OnClientPutInServer(int client)
{
	if( g_bCvarAllow )
	{
		SDKHook(client, SDKHook_WeaponEquip,	OnWeaponEquip);
		SDKHook(client, SDKHook_WeaponDrop,		OnWeaponDrop);
	}
}

public void OnClientCookiesCached(int client)
{
	if( g_bCvarAllow )
	{
		if( g_iConfigPrefs != 1 )
			g_iClientGrenadeType[client] = -1;
	}

	if( !IsFakeClient(client) )
	{
		// Get client cookies, set type if available or default.
		static char sCookie[10];
		static char sChars[3][3];
		GetClientCookie(client, g_hCookie, sCookie, sizeof(sCookie));

		if( strlen(sCookie) >= 5 )
		{
			ExplodeString(sCookie, ",", sChars, sizeof(sChars), sizeof(sChars[]));
		} else {
			sChars[0] = "0";
			sChars[1] = "0";
			sChars[2] = "0";
		}

		g_iClientGrenadePref[client][0] = StringToInt(sChars[0]);
		g_iClientGrenadePref[client][1] = StringToInt(sChars[1]);
		g_iClientGrenadePref[client][2] = StringToInt(sChars[2]);
	}
}

void SetCurrentNadePref(int client)
{
	// Get current nade if applicable.
	if( IsPlayerAlive(client) )
	{
		int weapon = GetPlayerWeaponSlot(client, 2);
		if( weapon != -1 )
		{
			OnWeaponEquip(client, weapon);
		}
	}
}

void SetClientPrefs(int client)
{
	if( !IsFakeClient(client) )
	{
		static char sCookie[10];
		Format(sCookie, sizeof(sCookie), "%d,%d,%d", g_iClientGrenadePref[client][0], g_iClientGrenadePref[client][1], g_iClientGrenadePref[client][2]);
		SetClientCookie(client, g_hCookie, sCookie);
	}
}



// ====================================================================================================
//					COMMANDS
// ====================================================================================================
Action Cmd_Reload(int client, int args)
{
	LoadDataConfig();
	if( client )
		PrintToChat(client, "\x04[\x05Grenade\x04] Reloaded config");
	else
		ReplyToCommand(client, "[Grenade] Reloaded config");
	return Plugin_Handled;
}

Action Cmd_SpawnThrow(int client, int args)
{
	DoSpawnCommand(client, args, true);
	return Plugin_Handled;
}

Action Cmd_SpawnSpawn(int client, int args)
{
	DoSpawnCommand(client, args, false);
	return Plugin_Handled;
}

void DoSpawnCommand(int client, int args, bool projectile)
{
	// Validate
	if( !client )
	{
		ReplyToCommand(client, "Command can only be used %s", IsDedicatedServer() ? "in game on a dedicated server." : "in chat on a Listen server.");
		return;
	}

	if( args != 1 )
	{
		ReplyToCommand(client, "Usage: sm_grenade_%s <1=Bomb, 2=Cluster, 3=Firework, 4=Smoke, 5=Black Hole, 6=Flashbang, 7=Shield, 8=Tesla, 9=Chemical, 10=Freeze, 11=Medic, 12=Vaporizer, 13=Extinguisher, 14=Glow, 15=Anti-Gravity, 16=Fire Cluster, 17=Bullets, 18=Flak, 19=Airstrike, 20=Weapon>", projectile ? "throw" : "spawn");
		return;
	}

	// Index
	char sTemp[4];
	GetCmdArg(1, sTemp, sizeof(sTemp));
	int index = StringToInt(sTemp);

	if( index < 1 || index > MAX_TYPES )
	{
		ReplyToCommand(client, "Usage: sm_grenade_%s <1=Bomb, 2=Cluster, 3=Firework, 4=Smoke, 5=Black Hole, 6=Flashbang, 7=Shield, 8=Tesla, 9=Chemical, 10=Freeze, 11=Medic, 12=Vaporizer, 13=Extinguisher, 14=Glow, 15=Anti-Gravity, 16=Fire Cluster, 17=Bullets, 18=Flak, 19=Airstrike, 20=Weapon>", projectile ? "throw" : "spawn");
		return;
	}

	// Create
	int entity = CreateEntityByName("pipe_bomb_projectile");
	if( entity != -1 )
	{
		SetEntityModel(entity, MODEL_SPRAYCAN);
		g_GrenadeType[entity] = index;								// Store mode type
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);		// Store owner
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);	// Store owner
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", view_as<float>({ 0.0, 0.0, 1.0 }));
		g_iClientGrenadeType[client] = index;

		float vPos[3];
		if( projectile )
		{
			float vAng[3];
			float vDir[3];
			GetClientEyePosition(client, vPos);
			GetClientEyeAngles(client, vAng);

			GetAngleVectors(vAng, vDir, NULL_VECTOR, NULL_VECTOR);
			vPos[0] += vDir[0] * 20;
			vPos[1] += vDir[1] * 20;
			vPos[2] += vDir[2] * 20;

			NormalizeVector(vDir, vDir);
			ScaleVector(vDir, 600.0);
			vDir[2] += 200.0;
			TeleportEntity(entity, vPos, NULL_VECTOR, vDir);
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vDir);
		} else {
			SetTeleportEndPoint(client, vPos);
			vPos[2] += 20.0;
			TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
		}
		DispatchSpawn(entity);

		static char translation[256];
		Format(translation, sizeof(translation), "GrenadeMod_Title_%d", index);
		PrintToChat(client, "\x04[\x05Grenade\x04] \x05Created: \x04%T", translation, client);
	}
}



// ====================================================================================================
//					MENU
// ====================================================================================================
Action Cmd_Grenade(int client, int args)
{
	if( !client )
	{
		ReplyToCommand(client, "Command can only be used %s", IsDedicatedServer() ? "in game on a dedicated server." : "in chat on a Listen server.");
		return Plugin_Handled;
	}

	// If grenade mode not allowed to change
	if( g_bCvarAllow == false || g_iConfigPrefs == 3 || CheckCommandAccess(client, "sm_grenade", 0) == false )
	{
		return Plugin_Handled;
	}

	if( args == 0 )
	{
		ShowGrenadeMenu(client);
	} else {
		// Validate weapon
		int iWeapon = GetPlayerWeaponSlot(client, 2);
		if( iWeapon > MaxClients && IsValidEntity(iWeapon) )
		{
			int type = IsGrenade(iWeapon);
			if( type )
			{
				char temp[4];
				GetCmdArg(1, temp, sizeof(temp));
				int index = StringToInt(temp);

				// Validate index
				if( index >= 0 && index <= MAX_TYPES )
				{
					g_iClientGrenadeType[client] = index - 1;
					GetGrenadeIndex(client, type); // Iterate to valid index.
					index = g_iClientGrenadeType[client];

					static char translation[256];
					Format(translation, sizeof(translation), "GrenadeMod_Title_%d", index);
					Format(translation, sizeof(translation), "%T %T", "GrenadeMod_Mode", client, translation, client);
					ReplaceColors(translation, sizeof(translation));
					PrintToChat(client, translation);
				}
			}
		}
	}

	return Plugin_Handled;
}

void ShowGrenadeMenu(int client)
{
	// Validate weapon
	int iWeapon = GetPlayerWeaponSlot(client, 2);
	if( iWeapon > MaxClients && IsValidEntity(iWeapon) )
	{
		int type = IsGrenade(iWeapon);
		if( type )
		{
			// Create menu
			Menu menu = new Menu(Menu_Grenade);
			static char text[64];
			static char temp[4];

			Format(text, sizeof(text), "%T", "GrenadeMenu_Title", client);
			menu.SetTitle(text);

			// Cycle through valid modes
			int selected;
			int count;
			int index;
			bool ins;

			for( int i = -1; i < MAX_TYPES; i++ )
			{
				ins = false;

				if( i == -1 )
				{
					index = 0;
					if( g_iConfigStock & (1<<(type - 1)) )
					{
						ins = true;
					}
				} else {
					if( g_GrenadeSlot[i][view_as<int>(!g_bLeft4Dead2)] & (1<<type - 1) && g_iConfigTypes & (1<<i) )
					{
						// Airstrike
						if( i != INDEX_AIRSTRIKE || (g_bLeft4Dead2 && g_bAirstrike && g_bAirstrikeValid) )
						{
							// Glow - ignored in L4D1
							if( i != INDEX_GLOW || g_bLeft4Dead2 )
							{
								ins = true;
								index = i + 1;
							}
						}
					}
				}

				// Add to menu
				if( ins )
				{
					if( index == g_iClientGrenadeType[client] )
						selected = count;
					count++;

					Format(text, sizeof(text), "GrenadeMod_Title_%d", index);
					Format(text, sizeof(text), "%s%T", index == g_iClientGrenadeType[client] ? "(*) " : "", text, client); // Mark selected
					IntToString(index, temp, sizeof(temp));
					menu.AddItem(temp, text);
				}
			}

			// Display
			menu.ExitButton = true;
			menu.DisplayAt(client, 7 * RoundToFloor(selected / 7.0), 30); // Display on selected page
			return;
		}
	}

	static char translation[256];
	Format(translation, sizeof(translation), "%T", "GrenadeMenu_Invalid", client);
	ReplaceColors(translation, sizeof(translation));
	PrintToChat(client, translation);
}

int Menu_Grenade(Menu menu, MenuAction action, int client, int index)
{
	switch( action )
	{
		case MenuAction_Select:
		{
			static char translation[256];

			// Validate weapon
			int iWeapon = GetPlayerWeaponSlot(client, 2);
			if( iWeapon > MaxClients && IsValidEntity(iWeapon) )
			{
				int type = IsGrenade(iWeapon);
				if( type )
				{
					// Get index
					static char sTemp[4];
					menu.GetItem(index, sTemp, sizeof(sTemp));
					index = StringToInt(sTemp);

					// Validate index
					g_iClientGrenadeType[client] = index - 1; // Iterate to valid index.
					GetGrenadeIndex(client, type);
					index = g_iClientGrenadeType[client];
					g_GrenadeType[iWeapon] = index + 1;

					// Print
					Format(translation, sizeof(translation), "GrenadeMod_Title_%d", index);
					Format(translation, sizeof(translation), "%T %T", "GrenadeMod_Mode", client, translation, client);
					ReplaceColors(translation, sizeof(translation));
					PrintToChat(client, translation);

					// Redisplay menu
					ShowGrenadeMenu(client);
				}
			} else {
				Format(translation, sizeof(translation), "%T", "GrenadeMenu_Invalid", client);
				ReplaceColors(translation, sizeof(translation));
				PrintToChat(client, translation);
			}
		}
		case MenuAction_End:
			delete menu;
	}

	return 0;
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
	g_iAmmoRifle		= g_hAmmoRifle.IntValue;
	g_iAmmoShotgun		= g_hAmmoShotgun.IntValue;
	g_iAmmoSmg			= g_hAmmoSmg.IntValue;
	g_iAmmoHunting		= g_hAmmoHunting.IntValue;

	if( g_bLeft4Dead2 )
	{
		g_iAmmoGL			= g_hAmmoGL.IntValue;
		g_iAmmoChainsaw		= g_hAmmoChainsaw.IntValue;
		g_iAmmoAutoShot		= g_hAmmoAutoShot.IntValue;
		g_iAmmoM60			= g_hAmmoM60.IntValue;
		g_iAmmoSniper		= g_hAmmoSniper.IntValue;
	}
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;

		AddNormalSoundHook(SoundHook);
		HookEvent("round_end",				Event_RoundEnd,			EventHookMode_PostNoCopy);
		HookEvent("bot_player_replace",		Event_BotReplace);

		if( g_bLeft4Dead2 )
		{
			HookEvent("player_death",		Event_PlayerDeath); // Chemical / Glow types
			HookEvent("player_spawn",		Event_PlayerSpawn); // Chemical Mode - Acid damage
		}

		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) )
			{
				// Hook WeaponEquip, get cookies
				OnClientPutInServer(i);
				OnClientCookiesCached(i);
				SetCurrentNadePref(i);

				// Chemical Mode - Acid damage
				if( g_bLeft4Dead2 )
				{
					SDKHook(i, SDKHook_OnTakeDamageAlive, OnAcidDamage);
				}
			}
		}

		// Chemical Mode - Acid damage
		if( g_bLeft4Dead2 )
		{
			int entity = -1;
			while( (entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE )
			{
				SDKHook(entity, SDKHook_OnTakeDamageAlive, OnAcidDamage);
			}

			entity = -1;
			while( (entity = FindEntityByClassname(entity, "witch")) != INVALID_ENT_REFERENCE )
			{
				SDKHook(entity, SDKHook_OnTakeDamageAlive, OnAcidDamage);
			}
		}
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		ResetPlugin(true);
		g_bCvarAllow = false;

		RemoveNormalSoundHook(SoundHook);
		UnhookEvent("round_end",			Event_RoundEnd,			EventHookMode_PostNoCopy);
		UnhookEvent("bot_player_replace",	Event_BotReplace);

		if( g_bLeft4Dead2 )
		{
			UnhookEvent("player_death",		Event_PlayerDeath); // Chemical / Glow types
			UnhookEvent("player_spawn",		Event_PlayerSpawn); // Chemical Mode - Acid damage

			for( int i = 1; i <= MaxClients; i++ )
			{
				if( IsClientInGame(i) )
				{
					SDKUnhook(i, SDKHook_OnTakeDamageAlive, OnAcidDamage);
					SDKUnhook(i, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);
				}
			}

			// Chemical Mode - Acid damage
			int entity = -1;
			while( (entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE )
			{
				SDKUnhook(entity, SDKHook_OnTakeDamageAlive, OnAcidDamage);
				SDKUnhook(entity, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);
			}

			entity = -1;
			while( (entity = FindEntityByClassname(entity, "witch")) != INVALID_ENT_REFERENCE )
			{
				SDKUnhook(entity, SDKHook_OnTakeDamageAlive, OnAcidDamage);
				SDKUnhook(entity, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);
			}
		}
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
//					MAP END / START
// ====================================================================================================
public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetPlugin(true);
}

public void OnMapStart()
{
	g_bMapStarted = true;

	// PRECACHE
	PrecacheModel(MODEL_BOUNDING, true);
	PrecacheModel(MODEL_CRATE, true);
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_SPRAYCAN, true);
	PrecacheModel(MODEL_SPRITE, true);
	PrecacheModel(SPRITE_GLOW, true);
	g_BeamSprite = PrecacheModel(SPRITE_BEAM);
	g_HaloSprite = PrecacheModel(SPRITE_HALO);

	if( g_bLeft4Dead2 )
		g_iParticleTracer50 = PrecacheParticle(PARTICLE_TRACER_50);
	g_iParticleTracer = PrecacheParticle(PARTICLE_TRACERS);
	g_iParticleBashed = PrecacheParticle(PARTICLE_BASHED);
	PrecacheParticle(PARTICLE_MUZZLE);
	PrecacheParticle(PARTICLE_SMOKER1);
	PrecacheParticle(PARTICLE_SMOKER2);
	PrecacheParticle(PARTICLE_BOOMER);
	PrecacheParticle(PARTICLE_SMOKE2);
	PrecacheParticle(PARTICLE_BURST);
	PrecacheParticle(PARTICLE_BLAST);
	PrecacheParticle(PARTICLE_BLAST2);
	PrecacheParticle(PARTICLE_MINIG);
	PrecacheParticle(PARTICLE_STEAM);
	PrecacheParticle(PARTICLE_BLACK);
	PrecacheParticle(PARTICLE_SMOKER);
	PrecacheParticle(PARTICLE_IMPACT);
	PrecacheParticle(PARTICLE_VOMIT);
	PrecacheParticle(PARTICLE_SPLASH);
	PrecacheParticle(PARTICLE_TRAIL);
	PrecacheParticle(PARTICLE_PIPE1);
	PrecacheParticle(PARTICLE_PIPE2);
	PrecacheParticle(PARTICLE_PIPE3);
	PrecacheParticle(PARTICLE_SMOKE);
	PrecacheParticle(PARTICLE_TES1);
	PrecacheParticle(PARTICLE_TES2);
	PrecacheParticle(PARTICLE_TES3);
	PrecacheParticle(PARTICLE_TES6);
	PrecacheParticle(PARTICLE_TES7);
	PrecacheParticle(PARTICLE_ELMOS);
	PrecacheParticle(PARTICLE_FIREWORK);

	if( g_bLeft4Dead2 )
	{
		PrecacheParticle(PARTICLE_SPARKS);
		PrecacheParticle(PARTICLE_GSPARKS);
		PrecacheParticle(PARTICLE_CHARGE);
		PrecacheParticle(PARTICLE_FLARE);
		PrecacheParticle(PARTICLE_SPIT_T);
		PrecacheParticle(PARTICLE_SPIT_P);
		PrecacheParticle(PARTICLE_DEFIB);

		PrecacheSound(SOUND_FIREWORK1, true);
		PrecacheSound(SOUND_FIREWORK2, true);
		PrecacheSound(SOUND_FIREWORK3, true);
		PrecacheSound(SOUND_FIREWORK4, true);
	}

	PrecacheSound(SOUND_SHOOTING, true);
	PrecacheSound(SOUND_EXPLODE3, true);
	PrecacheSound(SOUND_EXPLODE5, true);
	PrecacheSound(SOUND_FREEZER, true);
	PrecacheSound(SOUND_BUTTON1, true);
	PrecacheSound(SOUND_BUTTON2, true);
	PrecacheSound(SOUND_FLICKER, true);
	PrecacheSound(SOUND_GAS, true);
	PrecacheSound(SOUND_GATE, true);
	PrecacheSound(SOUND_NOISE, true);
	PrecacheSound(SOUND_SPATIAL, true);
	PrecacheSound(SOUND_SQUEAK, true);
	PrecacheSound(SOUND_STEAM, true);
	PrecacheSound(SOUND_TUNNEL, true);
	PrecacheSound(SOUND_SPLASH1, true);
	PrecacheSound(SOUND_SPLASH2, true);
	PrecacheSound(SOUND_SPLASH3, true);
	PrecacheSound(SOUND_GIFT, true);

	for( int i = 0; i < sizeof(g_sSoundsHit); i++ )			PrecacheSound(g_sSoundsHit[i], true);
	for( int i = 0; i < sizeof(g_sSoundsMiss); i++ )		PrecacheSound(g_sSoundsMiss[i], true);
	for( int i = 0; i < sizeof(g_sSoundsZap); i++ )			PrecacheSound(g_sSoundsZap[i], true);
	for( int i = 0; i < sizeof(g_sSoundsMissing); i++ )		PrecacheSound(g_sSoundsMissing[i], true);



	// Weapons
	int max;
	if( g_bLeft4Dead2 ) max = MAX_WEAPONS2;
	else max = MAX_WEAPONS;

	for( int i = 0; i < max; i++ )
	{
		PrecacheModel(g_bLeft4Dead2 ? g_sWeaponModels2[i] : g_sWeaponModels[i], true);
	}

	// Melee weapons
	if( g_bLeft4Dead2 )
	{
		// Taken from MeleeInTheSaferoom
		PrecacheModel("models/weapons/melee/v_bat.mdl", true);
		PrecacheModel("models/weapons/melee/v_cricket_bat.mdl", true);
		PrecacheModel("models/weapons/melee/v_crowbar.mdl", true);
		PrecacheModel("models/weapons/melee/v_electric_guitar.mdl", true);
		PrecacheModel("models/weapons/melee/v_fireaxe.mdl", true);
		PrecacheModel("models/weapons/melee/v_frying_pan.mdl", true);
		PrecacheModel("models/weapons/melee/v_golfclub.mdl", true);
		PrecacheModel("models/weapons/melee/v_katana.mdl", true);
		PrecacheModel("models/weapons/melee/v_machete.mdl", true);
		PrecacheModel("models/weapons/melee/v_tonfa.mdl", true);
		PrecacheModel("models/weapons/melee/v_pitchfork.mdl", true);
		PrecacheModel("models/weapons/melee/v_shovel.mdl", true);

		PrecacheModel("models/weapons/melee/w_bat.mdl", true);
		PrecacheModel("models/weapons/melee/w_cricket_bat.mdl", true);
		PrecacheModel("models/weapons/melee/w_crowbar.mdl", true);
		PrecacheModel("models/weapons/melee/w_electric_guitar.mdl", true);
		PrecacheModel("models/weapons/melee/w_fireaxe.mdl", true);
		PrecacheModel("models/weapons/melee/w_frying_pan.mdl", true);
		PrecacheModel("models/weapons/melee/w_golfclub.mdl", true);
		PrecacheModel("models/weapons/melee/w_katana.mdl", true);
		PrecacheModel("models/weapons/melee/w_machete.mdl", true);
		PrecacheModel("models/weapons/melee/w_tonfa.mdl", true);
		PrecacheModel("models/weapons/melee/w_pitchfork.mdl", true);
		PrecacheModel("models/weapons/melee/w_shovel.mdl", true);

		PrecacheGeneric("scripts/melee/baseball_bat.txt", true);
		PrecacheGeneric("scripts/melee/cricket_bat.txt", true);
		PrecacheGeneric("scripts/melee/crowbar.txt", true);
		PrecacheGeneric("scripts/melee/electric_guitar.txt", true);
		PrecacheGeneric("scripts/melee/fireaxe.txt", true);
		PrecacheGeneric("scripts/melee/frying_pan.txt", true);
		PrecacheGeneric("scripts/melee/golfclub.txt", true);
		PrecacheGeneric("scripts/melee/katana.txt", true);
		PrecacheGeneric("scripts/melee/machete.txt", true);
		PrecacheGeneric("scripts/melee/tonfa.txt", true);
		PrecacheGeneric("scripts/melee/pitchfork.txt", true);
		PrecacheGeneric("scripts/melee/shovel.txt", true);
	}



	// Pre-cache env_shake -_- WTF
	int shake = CreateEntityByName("env_shake");
	if( shake != -1 )
	{
		DispatchKeyValue(shake, "spawnflags", "8");
		DispatchKeyValue(shake, "amplitude", "16.0");
		DispatchKeyValue(shake, "frequency", "1.5");
		DispatchKeyValue(shake, "duration", "0.9");
		DispatchKeyValue(shake, "radius", "50");
		TeleportEntity(shake, view_as<float>({ 0.0, 0.0, -1000.0 }), NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(shake);
		ActivateEntity(shake);
		AcceptEntityInput(shake, "Enable");
		AcceptEntityInput(shake, "StartShake");
		RemoveEdict(shake);
	}



	// LOAD CONFIG
	if( g_bLateLoad )
	{
		g_bLateLoad = false; // No double load from lateload
	} else {
		LoadDataConfig();
	}
}



// ====================================================================================================
//					CONFIG
// ====================================================================================================
void LoadDataEntry(int index, KeyValues hFile, const char[] KeyName)
{
	if( hFile.JumpToKey(KeyName) )
	{
		g_GrenadeData[index][CONFIG_ELASTICITY]		=	hFile.GetFloat("elasticity",			0.4);
		g_GrenadeData[index][CONFIG_GRAVITY]		=	hFile.GetFloat("gravity",				1.0);
		g_GrenadeData[index][CONFIG_DMG_PHYSICS]	=	hFile.GetFloat("damage_physics",		1.0);
		g_GrenadeData[index][CONFIG_DMG_SPECIAL]	=	hFile.GetFloat("damage_special",		1.0);
		g_GrenadeData[index][CONFIG_DMG_SURVIVORS]	=	hFile.GetFloat("damage_survivors",		1.0);
		g_GrenadeData[index][CONFIG_DMG_TANK]		=	hFile.GetFloat("damage_tank",			1.0);
		g_GrenadeData[index][CONFIG_DMG_WITCH]		=	hFile.GetFloat("damage_witch",			1.0);
		g_GrenadeData[index][CONFIG_DAMAGE]			=	hFile.GetFloat("damage",				1.0);
		g_GrenadeData[index][CONFIG_DMG_TICK]		=	hFile.GetFloat("damage_tick",			1.0);
		g_GrenadeData[index][CONFIG_FUSE]			=	hFile.GetFloat("detonate_fuse",			0.0);
		g_GrenadeData[index][CONFIG_SHAKE]			=	hFile.GetFloat("detonate_shake",		0.0);
		g_GrenadeData[index][CONFIG_STICK]			=	hFile.GetFloat("detonate_stick",		0.0);
		g_GrenadeData[index][CONFIG_STUMBLE]		=	hFile.GetFloat("range_stumble",			0.0);
		g_GrenadeData[index][CONFIG_RANGE]			=	hFile.GetFloat("effect_range",			0.0);
		g_GrenadeData[index][CONFIG_TICK]			=	hFile.GetFloat("effect_tick",			0.0);
		g_GrenadeData[index][CONFIG_TIME]			=	hFile.GetFloat("effect_time",			0.0);
		g_GrenadeSlot[index][0]						=	hFile.GetNum("nade",					1);
		g_GrenadeSlot[index][1]						=	hFile.GetNum("nade_l4d1",				0);
		g_GrenadeTarg[index]						=	hFile.GetNum("targets",					31);
	}

	hFile.Rewind();
}

void LoadDataConfig()
{
	// Load Config
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_DATA);
	if( !FileExists(sPath) )
	{
		SetFailState("Missing config '%s' please re-install.", CONFIG_DATA);
	}

	// Import
	KeyValues hFile = new KeyValues("Grenades");
	if( !hFile.ImportFromFile(sPath) )
	{
		delete hFile;
		SetFailState("Error reading config '%s' please re-install.", CONFIG_DATA);
	}

	// Read
	if( hFile.JumpToKey("Settings") )
	{
		g_iConfigBots =					hFile.GetNum("bots",				0);
		g_iConfigBots =					Clamp(g_iConfigBots, 				0, (1<<MAX_TYPES) - 1);

		g_iConfigBinds =				hFile.GetNum("mode_switch",			3);
		g_iConfigBinds =				Clamp(g_iConfigBinds, 				1, 4);

		g_iConfigMsgs =					hFile.GetNum("messages",			1);
		g_iConfigMsgs =					Clamp(g_iConfigMsgs, 				0, 1);

		g_iConfigPrefs =				hFile.GetNum("preferences",			1);
		g_iConfigPrefs =				Clamp(g_iConfigPrefs, 				0, 3);

		g_fConfigSurvivors =			hFile.GetFloat("damage_survivors",	1.0);
		g_fConfigSurvivors =			Clamp(g_fConfigSurvivors, 			0.0, 1000.0);

		g_fConfigSpecial =				hFile.GetFloat("damage_special",	1.0);
		g_fConfigSpecial =				Clamp(g_fConfigSpecial, 			0.0, 1000.0);

		g_fConfigTank =					hFile.GetFloat("damage_tank",		1.0);
		g_fConfigTank =					Clamp(g_fConfigTank, 				0.0, 1000.0);

		g_fConfigWitch =				hFile.GetFloat("damage_witch",		1.0);
		g_fConfigWitch =				Clamp(g_fConfigWitch, 				0.0, 1000.0);

		g_fConfigPhysics =				hFile.GetFloat("damage_physics",	1.0);
		g_fConfigPhysics =				Clamp(g_fConfigPhysics, 			0.0, 1000.0);

		g_iConfigStock =				hFile.GetNum("stocks",				0);
		g_iConfigStock =				Clamp(g_iConfigStock, 				0, 7);

		g_iConfigTypes =				hFile.GetNum("types",				0);
		g_iConfigTypes =				Clamp(g_iConfigTypes, 				0, (1<<MAX_TYPES) - 1);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mod_Chemical") )
	{
		g_fConfigAcidComm =				hFile.GetFloat("damage_acid_comm",		1.0);
		g_fConfigAcidComm =				Clamp(g_fConfigAcidComm, 				0.0, 1000.0);
		g_fConfigAcidSelf =				hFile.GetFloat("damage_acid_self",		1.0);
		g_fConfigAcidSelf =				Clamp(g_fConfigAcidSelf, 				0.0, 1000.0);
		g_fConfigAcidSpec =				hFile.GetFloat("damage_acid_spec",		1.0);
		g_fConfigAcidSpec =				Clamp(g_fConfigAcidSpec, 				0.0, 1000.0);
		g_fConfigAcidSurv =				hFile.GetFloat("damage_acid_surv",		1.0);
		g_fConfigAcidSurv =				Clamp(g_fConfigAcidSurv, 				0.0, 1000.0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mod_Flak") )
	{
		g_iConfigDmgType =				hFile.GetNum("damage_type",				0);
		g_iConfigDmgType =				Clamp(g_iConfigDmgType, 				0, 31);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mod_Freezer") )
	{
		g_fConfigFreezeTime =			hFile.GetFloat("effect_freeze",			1.0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mod_Glow") )
	{
		g_fConfigGlowBonus =			hFile.GetFloat("damage_bonus",			1.0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mod_Glow") )
	{
		g_fConfigExtEffect =			hFile.GetNum("effect_types",			7);
		g_fConfigExtEffect =			Clamp(g_fConfigExtEffect, 				1, 7);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mod_Weapon") )
	{
		char sConfigWeapons[256];

		if( g_bLeft4Dead2 )
			hFile.GetString("weapons2",	sConfigWeapons, sizeof(sConfigWeapons));
		else
			hFile.GetString("weapons1",	sConfigWeapons, sizeof(sConfigWeapons));

		// Weighted chance
		int chance, index, total;
		char buffers[MAX_WEAPONS2 + MAX_MELEE][8];
		char temp[2][6];

		g_iTotalChance = 0;

		for( int i = 0; i < (g_bLeft4Dead2 ? MAX_WEAPONS2 + MAX_MELEE: MAX_WEAPONS); i++ )
		{
			g_iChances[i] = 0;
		}

		total = ExplodeString(sConfigWeapons, ",", buffers, sizeof(buffers), sizeof(buffers[]));

		for( int i = 0; i < total; i++ )
		{
			ExplodeString(buffers[i], ":", temp, sizeof(temp), sizeof(temp[]));
			chance = StringToInt(temp[1]);
			index = StringToInt(temp[0]) - 1;

			if( chance )
			{
				g_iTotalChance += chance;
				g_iChances[index] = g_iTotalChance;
			}
		}

		hFile.Rewind();
	}

	LoadDataEntry(INDEX_BOMB,			hFile,		"Mod_Bomb");
	LoadDataEntry(INDEX_CLUSTER,		hFile,		"Mod_Cluster");
	LoadDataEntry(INDEX_FIREWORK,		hFile,		"Mod_Firework");
	LoadDataEntry(INDEX_SMOKE,			hFile,		"Mod_Smoke");
	LoadDataEntry(INDEX_BLACKHOLE,		hFile,		"Mod_Black_Hole");
	LoadDataEntry(INDEX_FLASHBANG,		hFile,		"Mod_Flashbang");
	LoadDataEntry(INDEX_SHIELD,			hFile,		"Mod_Shield");
	LoadDataEntry(INDEX_TESLA,			hFile,		"Mod_Tesla");
	LoadDataEntry(INDEX_CHEMICAL,		hFile,		"Mod_Chemical");
	LoadDataEntry(INDEX_FREEZER,		hFile,		"Mod_Freezer");
	LoadDataEntry(INDEX_MEDIC,			hFile,		"Mod_Medic");
	LoadDataEntry(INDEX_VAPORIZER,		hFile,		"Mod_Vaporizer");
	LoadDataEntry(INDEX_EXTINGUISHER,	hFile,		"Mod_Extinguisher");
	LoadDataEntry(INDEX_GLOW,			hFile,		"Mod_Glow");
	LoadDataEntry(INDEX_ANTIGRAVITY,	hFile,		"Mod_Anti_Gravity");
	LoadDataEntry(INDEX_FIRECLUSTER,	hFile,		"Mod_Cluster_Fire");
	LoadDataEntry(INDEX_BULLETS,		hFile,		"Mod_Bullets");
	LoadDataEntry(INDEX_FLAK,			hFile,		"Mod_Flak");
	LoadDataEntry(INDEX_AIRSTRIKE,		hFile,		"Mod_Airstrike");
	LoadDataEntry(INDEX_WEAPON,			hFile,		"Mod_Weapon");

	delete hFile;
}

any Clamp(any value, any min = 0.0, any max)
{
	if( value < min )
		value = min;
	else if( value > max )
		value = max;
	return value;
}



// ====================================================================================================
//					L4D2 - F-18 AIRSTRIKE
// ====================================================================================================
public void F18_OnPluginState(int pluginstate)
{
	static int mystate;

	if( pluginstate == 1 && mystate == 0 )
	{
		mystate = 1;
		g_bAirstrikeValid = true;
	}
	else if( pluginstate == 0 && mystate == 1 )
	{
		mystate = 0;
		g_bAirstrikeValid = false;
	}
}

public void F18_OnRoundState(int roundstate)
{
	static int mystate;

	if( roundstate == 1 && mystate == 0 )
	{
		mystate = 1;
		g_bAirstrikeValid = true;
	}
	else if( roundstate == 0 && mystate == 1 )
	{
		mystate = 0;
		g_bAirstrikeValid = false;
	}
}



// ====================================================================================================
//					EVENTS - WEAPON EQUIP
// ====================================================================================================
void OnWeaponEquip(int client, int weapon)
{
	if( CheckCommandAccess(client, "sm_grenade", 0) == false )
	{
		g_iClientGrenadeType[client] = 0;
		return;
	}

	if( weapon > MaxClients && IsValidEntity(weapon) )
	{
		int type = IsGrenade(weapon);
		if( type )
		{
			// Random grenade prefs
			if( g_iConfigPrefs != 1 || g_iConfigBots && IsFakeClient(client) )
			{
				int index = g_GrenadeType[weapon]; // Was previously picked up / set type
				if( index > 0 )
				{
					g_iClientGrenadeType[client] = index - 1;
				} else {
					int types = g_iConfigBots && IsFakeClient(client) ? g_iConfigBots : g_iConfigTypes; // Allowed types for bots / players
					int min = MAX_TYPES;
					int max;
					int slot;

					// Cycle through modes
					for( int i = 0; i < MAX_TYPES; i++ )
					{
						if( g_GrenadeSlot[i][view_as<int>(!g_bLeft4Dead2)] & (1<<type - 1) && types & (1<<i) )
						{
							if( i < min )	min = i - 1;
							if( i > max)	max = i;
						}
					}

					slot = GetRandomInt(min, max);
					g_iClientGrenadeType[client] = slot == min ? -1 : slot;
					GetGrenadeIndex(client, type); // Iterate to valid index.
				}
			} else {
				g_iClientGrenadeType[client] = -1;
			}

			// Client prefs default
			if( g_iConfigPrefs == 0 )
			{
				g_iClientGrenadeType[client] = 0;
				g_iClientGrenadePref[client][type - 1] = 0;
			}
			else if( g_iClientGrenadeType[client] == -1 )
			{
				g_iClientGrenadeType[client] = g_iClientGrenadePref[client][type - 1];

				if( g_iClientGrenadeType[client] == -1 )
				{
					ThrowError("OnWeaponEquip == -1. This should never happen.");
				}
			}

			g_GrenadeType[weapon] = g_iClientGrenadeType[client] + 1; // Store type

			// Hints
			if( g_bCvarAllow && g_iConfigMsgs && g_fLastEquip[client] < GetGameTime() && !IsFakeClient(client) )
			{
				g_fLastEquip[client] = GetGameTime() + 0.5;

				static char translation[256];
				Format(translation, sizeof(translation), "GrenadeMod_Title_%d", g_iClientGrenadeType[client]);

				Format(translation, sizeof(translation), "%T %T", "GrenadeMod_Mode", client, translation, client);
				ReplaceColors(translation, sizeof(translation));
				PrintToChat(client, translation);

				// If grenade mode allowed to change
				if( g_iConfigPrefs != 3 )
				{
					if( g_iConfigBinds == 2 )
						Format(translation, sizeof(translation), "%T", "GrenadeMod_Hint2", client);
					else
						Format(translation, sizeof(translation), "%T", "GrenadeMod_Hint", client);

					ReplaceColors(translation, sizeof(translation));
					PrintToChat(client, translation);
				}
			}
		}
	}
}

void OnWeaponDrop(int client, int weapon)
{
	// Random grenade prefs
	if( g_iConfigPrefs != 1 && weapon != -1 && IsValidEntity(weapon) && IsValidEdict(weapon) )
	{
		// Validate weapon
		int type = IsGrenade(weapon);
		if( type )
		{
			g_GrenadeType[weapon] = g_iClientGrenadeType[client] + 1;
		}
	}
}



// ====================================================================================================
//					SOUND HOOK
// ====================================================================================================
// From "boomerjar##.wav" filenames.
int g_iGambl_InvalidBile[]	=	{08, 10};
int g_iMecha_InvalidBile[]	=	{08, 09, 10, 14, 13};
int g_iProdu_InvalidBile[]	=	{05, 07, 08, 09};
// From "Grenade##.wav" filenames.
int g_iCoach_InvalidNade[]	=	{08, 09, 10, 11, 12};
int g_iGambl_InvalidNade[]	=	{02, 03, 05, 06, 07, 08, 09, 11, 13};
int g_iMecha_InvalidNade[]	=	{03, 04, 05, 06, 07, 08, 11, 12, 13};
int g_iProdu_InvalidNade[]	=	{02, 03, 04, 05};
// Valid alternatives
int g_iCoach_ValidSample[]	=	{01, 02, 03, 04, 05, 06, 07};
int g_iGambl_ValidSample[]	=	{01, 04, 10, 12};
int g_iMecha_ValidSample[]	=	{01, 02, 09, 10};
int g_iProdu_ValidSample[]	=	{01, 06, 07};

Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	// Block molotov sound when throwing. Deleting the molotov straight away causes the sound to loop endlessly.
	if( g_bBlockSound )
	{
		if( strcmp(sample, "weapons/molotov/fire_loop_1.wav") == 0 )
		{
			volume = 0.0;
			return Plugin_Changed;
		}
	}



	// Replace Prototype Grenades bounce sound.
	// weapons/hegrenade/he_bounce-1.wav
	if( sample[0] == 'w' && sample[8] == 'h' && sample[18] == 'h' )
	{
		if( g_GrenadeType[entity] )
		{
			PlaySound(entity, g_sSoundsHit[GetRandomInt(0, sizeof(g_sSoundsHit) - 1)]);

			volume = 0.0;
			// volume = 0.6;
			// strcopy(sample, sizeof(sample), g_sSoundsHit[GetRandomInt(0, sizeof(g_sSoundsHit) - 1)]);
			return Plugin_Changed;
		}
	}



	// L4D2 survivors only.
	// Change players saying "throwing molotov" or "throwing pipebomb" to "throwing grenade" when a Prototype Grenade mode is selected.

	// Info for anyone who reads:
	// Players can vocalize from other objects, eg an "info_target" entity (see Mic plugin) and not a client index.
	// No point doing excess classname checking etc to block the rare vocalizations through non-player entities.
	// For other serious vocalization plugins this should be considered. Eg replacing a characters voices with another.
	if( g_bLeft4Dead2 && entity > 0 && entity <= MaxClients && g_iClientGrenadeType[entity] )
	{
		// player/survivor/voice/
		if( sample[0] == 'p' && sample[7] == 's' && sample[16] == 'v' )
		{
			// Coach, Gambler, Mechanic, Producer
			int dot;
			int pos;
			int edit;
			switch( sample[22] )
			{
				case 'G': pos = 30;
				case 'M': pos = 31;
				case 'P': pos = 31;
			}



			// "Grenade##.wav"
			if( pos && sample[pos] == 'G' && sample[pos + 9] == '.' )
			{
				dot = 9;
				sample[pos + dot] = '\x0';
				int num = StringToInt(sample[pos + dot - 2]); // Get grenade vocalize sound number.
				sample[pos + dot] = '.';

				switch( sample[22] ) // Match invalid number.
				{
					case 'C': for( int i = 0; i < sizeof(g_iCoach_InvalidNade); i++ ) if( num == g_iCoach_InvalidNade[i] ) { edit = g_iCoach_ValidSample[GetRandomInt(0, sizeof(g_iCoach_ValidSample) - 1)]; break; }
					case 'G': for( int i = 0; i < sizeof(g_iGambl_InvalidNade); i++ ) if( num == g_iGambl_InvalidNade[i] ) { edit = g_iGambl_ValidSample[GetRandomInt(0, sizeof(g_iGambl_ValidSample) - 1)]; break; }
					case 'M': for( int i = 0; i < sizeof(g_iMecha_InvalidNade); i++ ) if( num == g_iMecha_InvalidNade[i] ) { edit = g_iMecha_ValidSample[GetRandomInt(0, sizeof(g_iMecha_ValidSample) - 1)]; break; }
					case 'P': for( int i = 0; i < sizeof(g_iProdu_InvalidNade); i++ ) if( num == g_iProdu_InvalidNade[i] ) { edit = g_iProdu_ValidSample[GetRandomInt(0, sizeof(g_iProdu_ValidSample) - 1)]; break; }
				}
			}



			// boomerjar##.wav
			else if( pos && sample[pos] == 'B' && sample[pos + 6] == 'J' && sample[22] != 'C' ) // Not Coach
			{
				dot = 11;
				sample[pos + dot] = '\x0';
				int num = StringToInt(sample[pos + dot - 2]); // Get grenade vocalize sound number.
				sample[pos + dot] = '.';

				switch( sample[22] ) // Match invalid number.
				{
					case 'G': for( int i = 0; i < sizeof(g_iGambl_InvalidBile); i++ ) if( num == g_iGambl_InvalidBile[i] ) { edit = g_iGambl_ValidSample[GetRandomInt(0, sizeof(g_iGambl_ValidSample) - 1)]; break; }
					case 'M': for( int i = 0; i < sizeof(g_iMecha_InvalidBile); i++ ) if( num == g_iMecha_InvalidBile[i] ) { edit = g_iMecha_ValidSample[GetRandomInt(0, sizeof(g_iMecha_ValidSample) - 1)]; break; }
					case 'P': for( int i = 0; i < sizeof(g_iProdu_InvalidBile); i++ ) if( num == g_iProdu_InvalidBile[i] ) { edit = g_iProdu_ValidSample[GetRandomInt(0, sizeof(g_iProdu_ValidSample) - 1)]; break; }
				}

				if( edit ) // Replace name
				{
					sample[pos] = '\x0';
					StrCat(sample, sizeof(sample), "Grenade##.wav");
				}
			}

			if( edit ) // Replace invalid number with valid number
			{
				static char val[3];
				Format(val, sizeof(val), "%02d", edit);
				sample[pos + 7] = val[0];
				sample[pos + 8] = val[1];
				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}



// ====================================================================================================
//					RESET PLUGIN
// ====================================================================================================
void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client )
	{
		// Since players can spawn (admin command) without dieing, should unhook and rehook here.
		// FIXME: TODO: Many other plugins probably need updating for this or they'll have duplicate hooks.
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnAcidDamage);
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnAcidDamage);
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client && IsValidEntity(client) )
	{
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnAcidDamage);

		// Glow mode: Reset color on death
		if( GetEntProp(client, Prop_Send, "m_glowColorOverride") == GLOW_COLOR )
		{
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);
			SetEntProp(client, Prop_Send, "m_iGlowType", 0);
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
		}
	}
}

void Event_BotReplace(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("player"));
	if( client ) SetCurrentNadePref(client);
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

void ResetPlugin(bool all = false)
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		g_bChangingTypesMenu[i] = false;
		g_fLastEquip[i] = 0.0;
		g_fLastFreeze[i] = 0.0;
		g_fLastShield[i] = 0.0;
		g_fLastUse[i] = 0.0;

		if( all )
		{
			SDKUnhook(i, SDKHook_OnTakeDamageAlive,	OnShield);
			SDKUnhook(i, SDKHook_WeaponEquip,		OnWeaponEquip);
			SDKUnhook(i, SDKHook_WeaponDrop,		OnWeaponDrop);
		}
	}

	int entity = -1;
	while( (entity = FindEntityByClassname(entity, "pipe_bomb_projectile")) != INVALID_ENT_REFERENCE )
	{
		StopSounds(entity);
	}

	if( g_iEntityHurt && EntRefToEntIndex(g_iEntityHurt) != INVALID_ENT_REFERENCE )
	{
		RemoveEntity(g_iEntityHurt);
	}
}



// ====================================================================================================
//					CHANGE MODE
// ====================================================================================================
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	// Preferences allow to change grenade type, holding Shoot and pressing Shove
	if( g_bCvarAllow && g_iConfigPrefs != 3 && g_iConfigBinds != 2 )
	{
		if( buttons & IN_ATTACK )
		{
			if( buttons & IN_ATTACK2 )
			{
				// Check only a few times per second
				if( GetGameTime() - g_fLastUse[client] > MAX_WAIT )
				{
					g_fLastUse[client] = GetGameTime();

					// Validate weapon
					int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if( iWeapon > MaxClients && IsValidEntity(iWeapon) && CheckCommandAccess(client, "sm_grenade", 0) == true )
					{
						int type = IsGrenade(iWeapon);
						if( type )
						{
							// Cycle through modes
							int index = GetGrenadeIndex(client, type);

							g_GrenadeType[iWeapon] = index + 1;

							static char translation[256];
							Format(translation, sizeof(translation), "GrenadeMod_Title_%d", index);
							Format(translation, sizeof(translation), "%T %T", "GrenadeMod_Mode", client, translation, client);
							ReplaceColors(translation, sizeof(translation));
							PrintToChat(client, translation);

							if( g_iConfigBinds == 4 )
							{
								g_bChangingTypesMenu[client] = true;
								ShowGrenadeMenu(client);
							}
						}
					}
				}
			}
		}
		else if( g_bChangingTypesMenu[client] )
		{
			g_bChangingTypesMenu[client] = false;

			if( GetClientMenu(client, null) != MenuSource_None )
			{
				InternalShowMenu(client, "\10", 1); // Thanks to Zira
				CancelClientMenu(client, true, null);
			}
		}
	}

	return Plugin_Continue;
}

int GetGrenadeIndex(int client, int type)
{
	int index = g_iClientGrenadeType[client];

	if( index == -1 )
		index = 0;
	else
		index++;

	// Default to stock
	if( index == 0 || index > MAX_TYPES )
	{
		if( g_iConfigStock & (1<<(type - 1)) )
			index = 0;
		else
			index = 1;
	}

	// If modded
	if( index > 0 )
	{
		int types = g_iConfigBots && IsFakeClient(client) ? g_iConfigBots : g_iConfigTypes; // Allowed types for bots / players

		// Loop next
		for( int i = index - 1; i < MAX_TYPES; i++ )
		{
			// Skip Airstrike if invalid
			if( i == INDEX_AIRSTRIKE && (!g_bLeft4Dead2 || !g_bAirstrike || !g_bAirstrikeValid) )
			{
				i += 1;
			}

			if( g_GrenadeSlot[i][view_as<int>(!g_bLeft4Dead2)] & (1<<type - 1) && types & (1<<i) )
			{
				index = i + 1;
				break;
			}
			else if( i == MAX_TYPES - 1 )
			{
				// Allow stock
				if( g_iConfigStock & (1<<(type - 1)) )
				{
					index = 0;
				}
				else
				{
					// Loop from 0
					for( int x = 0; x < MAX_TYPES; x++ )
					{
						if( g_GrenadeSlot[i][view_as<int>(!g_bLeft4Dead2)] & (1<<type - 1) && types & (1<<x) )
						{
							index = x + 1;
							break;
						}
					}
				}
			}
		}
	}

	g_iClientGrenadeType[client] = index;
	g_iClientGrenadePref[client][type - 1] = index;
	SetClientPrefs(client);
	return index;
}



// ====================================================================================================
//					PROJECTILE THROWN
// ====================================================================================================
// Listen for thrown grenades to hook and replace.
public void OnEntityCreated(int entity, const char[] classname)
{
	if( entity < 0 || entity >= 2048 ) return;

	g_GrenadeType[entity] = 0;

	if( g_bCvarAllow )
	{
		if( !g_bBlockHook )
		{
			if(
				classname[0] == 'm' ||
				classname[0] == 'p' ||
				classname[0] == 'v'
			)
			{
				if(
					strncmp(classname, "molotov_projectile", 13) == 0 ||
					strncmp(classname, "pipe_bomb_projectile", 13) == 0 ||
					g_bLeft4Dead2 && strncmp(classname, "vomitjar_projectile", 13) == 0
				)
				{
					SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
					return;
				}
			}
		}

		
		if( g_bHookFire && strcmp(classname, "inferno") == 0 )
		{
			SDKHook(entity, SDKHook_ThinkPost, OnPostThink);
		}

		// Chemical Mode - Acid damage
		else if( g_bLeft4Dead2 )
		{
			if( g_bAcidSpawn )
			{
				if( strcmp(classname, "insect_swarm") == 0 )
				{
					g_hAlAcid.Push(entity);
					g_bAcidSpawn = false;
				}
			}

			if( strcmp(classname, "infected") == 0 || strcmp(classname, "witch") == 0 )
			{
				SDKHook(entity, SDKHook_OnTakeDamageAlive, OnAcidDamage);
			}
		}
	}
}

void OnPostThink(int entity)
{
	SetEntProp(entity, Prop_Send, "m_fireXDelta", 1, 1, 0);
	SetEntProp(entity, Prop_Send, "m_fireCount", 1);
}

void SpawnPost(int entity)
{
	// 1 frame later required to get velocity
	RequestFrame(OnNextFrame, EntIndexToEntRef(entity));

	// Stop molotov loop sound since it gets stuck.
	g_bBlockSound = true;
}

void OnNextFrame(int entity)
{
	g_bBlockSound = false;

	// Validate entity
	if( EntRefToEntIndex(entity) == INVALID_ENT_REFERENCE || !IsValidEntity(entity) )
		return;

	// Get Client
	int client = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	if( client > 0 && client <= MaxClients && IsClientInGame(client) )
	{
		int index = g_iClientGrenadeType[client];
		if( index > 0 && CheckCommandAccess(client, "sm_grenade", 0) == true )
		{
			// Game bug: when "weapon_oxygentank" and "weapon_propanetank" explode they create a "pipe_bomb_projectile". This prevents those erroneous ents.
			static float vTest[3];
			GetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vTest);
			if( vTest[0] == 0.0 && vTest[1] == 0.0 && vTest[2] == 0.0 )
				return;

			// Recreate projectile to deactivate it.
			entity = CreateProjectile(entity, client, index);
			if( entity == 0 )
				return;

			// Hurt entity
			CreateHurtEntity();

			// Detonate / Stick on contact
			float detonate = g_GrenadeData[index - 1][CONFIG_FUSE];
			if( detonate == 0.0 )
				SDKHook(entity, SDKHook_Touch, OnTouch_Detonate);
			else
				CreateTimer(detonate, Timer_Detonate, EntIndexToEntRef(entity));

			// Create projectile effects
			DoPrjEffects(entity, index);
		}
	}
}



// ====================================================================================================
//					PROJECTILE EFFECTS - Create projectile effects
// ====================================================================================================
void DoPrjEffects(int entity, int index)
{
	switch( index - 1 )
	{
		case INDEX_BOMB:			PrjEffects_Bomb				(entity);
		case INDEX_CLUSTER:			PrjEffects_Cluster			(entity);
		case INDEX_FIREWORK:		PrjEffects_Firework			(entity);
		case INDEX_SMOKE:			PrjEffects_Smoke			(entity);
		case INDEX_BLACKHOLE:		PrjEffects_BlackHole		(entity);
		case INDEX_FLASHBANG:		PrjEffects_Flashbang		(entity);
		case INDEX_SHIELD:			PrjEffects_Shield			(entity);
		case INDEX_TESLA:			PrjEffects_Tesla			(entity);
		case INDEX_CHEMICAL:		PrjEffects_Chemical			(entity);
		case INDEX_FREEZER:			PrjEffects_Freezer			(entity);
		case INDEX_MEDIC:			PrjEffects_Medic			(entity);
		case INDEX_VAPORIZER:		PrjEffects_Vaporizer		(entity);
		case INDEX_EXTINGUISHER:	PrjEffects_Extinguisher		(entity);
		case INDEX_GLOW:			PrjEffects_Glow				(entity);
		case INDEX_ANTIGRAVITY:		PrjEffects_AntiGravity		(entity);
		case INDEX_FIRECLUSTER:		PrjEffects_FireCluster		(entity);
		case INDEX_BULLETS:			PrjEffects_Bullets			(entity);
		case INDEX_FLAK:			PrjEffects_Flak				(entity);
		case INDEX_AIRSTRIKE:		PrjEffects_Airstrike		(entity);
		case INDEX_WEAPON:			PrjEffects_Weapon			(entity);
	}
}

void SetupPrjEffects(int entity, float vPos[3], const char[] color)
{
	// Grenade Pos
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Sprite
	CreateEnvSprite(entity, color);

	// Steam
	static float vAng[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAng);
	MakeEnvSteam(entity, vPos, vAng, color);

	// Light
	int light = MakeLightDynamic(entity, vPos);
	SetVariantEntity(light);
	SetVariantString(color);
	AcceptEntityInput(light, "color");
	AcceptEntityInput(light, "TurnOn");
}

// ====================================================================================================
//					PRJ EFFECT - BOMB
// ====================================================================================================
void PrjEffects_Bomb(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 0 0"); // Red

	// Particles
	DisplayParticle(entity,		PARTICLE_MINIG,			vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_FLARE,			vPos, NULL_VECTOR);
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,		vPos, NULL_VECTOR);
		DisplayParticle(entity,	PARTICLE_GSPARKS,		vPos, NULL_VECTOR, 0.2);
	}

	// Sound
	PlaySound(entity, SOUND_STEAM);
}

// ====================================================================================================
//					PRJ EFFECT - CLUSTER
// ====================================================================================================
void PrjEffects_Cluster(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 255 0"); // Yellow

	// Particles
	DisplayParticle(entity,		PARTICLE_MINIG,		vPos, NULL_VECTOR);
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
		DisplayParticle(entity,	PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
	}

	// Sound
	PlaySound(entity, SOUND_STEAM);
}

// ====================================================================================================
//					PRJ EFFECT - FIREWORK
// ====================================================================================================
void PrjEffects_Firework(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 150 0"); // Orange

	// Particles
	DisplayParticle(entity,		PARTICLE_MINIG,		vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_TES7,		vPos, NULL_VECTOR);
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
		DisplayParticle(entity, PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
	}
}

// ====================================================================================================
//					PRJ EFFECT - SMOKE
// ====================================================================================================
void PrjEffects_Smoke(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "100 100 100"); // Grey

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_SMOKE2,	vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_IMPACT,	vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_SMOKE,		vPos, NULL_VECTOR);

	// Sound
	PlaySound(entity, SOUND_GAS);
}

// ====================================================================================================
//					PRJ EFFECT - BLACK HOLE
// ====================================================================================================
void PrjEffects_BlackHole(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "200 0 255"); // Purple

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,	PARTICLE_DEFIB,		vPos, NULL_VECTOR, 0.5);

	// Sound
	PlaySound(entity, SOUND_SQUEAK);
	PlaySound(entity, SOUND_SPATIAL);
	PlaySound(entity, SOUND_FLICKER);
	PlaySound(entity, SOUND_TUNNEL);
	PlaySound(entity, SOUND_NOISE);
}

// ====================================================================================================
//					PRJ EFFECT - FLASHBANG
// ====================================================================================================
void PrjEffects_Flashbang(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 255 255"); // White

	// Particles
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
		DisplayParticle(entity,	PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
	}

	// Sound
	PlaySound(entity, SOUND_BUTTON1);
}

// ====================================================================================================
//					PRJ EFFECT - SHIELD
// ====================================================================================================
void PrjEffects_Shield(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "0 220 255"); // Light Blue

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,	PARTICLE_DEFIB,		vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_ELMOS,		vPos, NULL_VECTOR);

	// Sound
	PlaySound(entity, SOUND_SPATIAL);
	PlaySound(entity, SOUND_TUNNEL);
	PlaySound(entity, SOUND_NOISE);
}

// ====================================================================================================
//					PRJ EFFECT - TESLA
// ====================================================================================================
void PrjEffects_Tesla(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "0 50 155"); // Blue

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,	PARTICLE_DEFIB,		vPos, NULL_VECTOR, 0.5);
	DisplayParticle(entity,		PARTICLE_ELMOS,		vPos, NULL_VECTOR, 0.5);

	// Sound
	PlaySound(entity, SOUND_SQUEAK);
	PlaySound(entity, SOUND_SPATIAL);
	PlaySound(entity, SOUND_FLICKER);
	PlaySound(entity, SOUND_TUNNEL);
}

// ====================================================================================================
//					PRJ EFFECT - CHEMICAL
// ====================================================================================================
void PrjEffects_Chemical(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "150 255 0"); // Lime green

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,	PARTICLE_SPIT_T,	vPos, NULL_VECTOR);
	DisplayParticle(entity,		PARTICLE_VOMIT,		vPos, NULL_VECTOR);

	// Sound
	PlaySound(entity, SOUND_GAS);
}

// ====================================================================================================
//					PRJ EFFECT - FREEZER
// ====================================================================================================
void PrjEffects_Freezer(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "0 150 255"); // Light Blue

	// Particles
	DisplayParticle(entity, PARTICLE_STEAM,		vPos, NULL_VECTOR, 0.5);
	DisplayParticle(entity, PARTICLE_ELMOS,		vPos, NULL_VECTOR, 0.5);

	// Sound
	PlaySound(entity, SOUND_GAS);
	PlaySound(entity, SOUND_STEAM);
	PlaySound(entity, SOUND_NOISE);
}

// ====================================================================================================
//					PRJ EFFECT - MEDIC
// ====================================================================================================
void PrjEffects_Medic(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "0 150 0"); // Green

	// Sound
	PlaySound(entity, SOUND_TUNNEL);
	PlaySound(entity, SOUND_NOISE);
	PlaySound(entity, SOUND_SQUEAK);
}

// ====================================================================================================
//					PRJ EFFECT - VAPORIZER
// ====================================================================================================
void PrjEffects_Vaporizer(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "50 0 255"); // Purple

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,	PARTICLE_DEFIB,		vPos, NULL_VECTOR, 0.5);
	DisplayParticle(entity,		PARTICLE_TES2,		vPos, NULL_VECTOR, 0.5);
	DisplayParticle(entity,		PARTICLE_ELMOS,		vPos, NULL_VECTOR, 0.5);

	// Sound
	PlaySound(entity, SOUND_SQUEAK);
	PlaySound(entity, SOUND_SPATIAL);
	PlaySound(entity, SOUND_FLICKER);
	PlaySound(entity, SOUND_TUNNEL);
}

// ====================================================================================================
//					PRJ EFFECT - EXTINGUISHER
// ====================================================================================================
void PrjEffects_Extinguisher(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "0 50 255"); // Blue

	// Particles
	DisplayParticle(entity, PARTICLE_STEAM,		vPos, NULL_VECTOR, 0.5);
}

// ====================================================================================================
//					PRJ EFFECT - GLOW
// ====================================================================================================
void PrjEffects_Glow(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 150 0"); // Yellow-ish

	// Particles
	DisplayParticle(entity, PARTICLE_STEAM,		vPos, NULL_VECTOR, 0.5);

	// Sound
	PlaySound(entity, SOUND_TUNNEL);
	PlaySound(entity, SOUND_SPATIAL);
}

// ====================================================================================================
//					PRJ EFFECT - ANTI-GRAVITY
// ====================================================================================================
void PrjEffects_AntiGravity(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "0 255 100"); // Lime Green

	// Particles
	DisplayParticle(entity,		PARTICLE_ELMOS,		vPos, NULL_VECTOR, 0.5);

	// Sound
	PlaySound(entity, SOUND_TUNNEL);

	// Slow projectile
	CreateTimer(0.1, TimerSlowdown, EntIndexToEntRef(entity), TIMER_REPEAT);
}

Action TimerSlowdown(Handle timer, int entity)
{
	if( (entity = EntRefToEntIndex(entity)) != INVALID_ENT_REFERENCE )
	{
		static float vVel[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vVel);
		float speed = GetVectorLength(vVel);

		ScaleVector(vVel, speed < 100 ? 0.6 : 0.9);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vVel);

		if( speed > 20 )
		{
			return Plugin_Continue;
		}

		SetEntityGravity(entity, -0.01);
	}
	return Plugin_Stop;
}

// ====================================================================================================
//					PRJ EFFECT - CLUSTER
// ====================================================================================================
void PrjEffects_FireCluster(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 50 0"); // Orange

	// Particles
	DisplayParticle(entity,		PARTICLE_MINIG,		vPos, NULL_VECTOR);
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
		DisplayParticle(entity,	PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
	}

	// Sound
	PlaySound(entity, SOUND_STEAM);
}

// ====================================================================================================
//					PRJ EFFECT - BULLETS
// ====================================================================================================
void PrjEffects_Bullets(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 100 0"); // Yellow orange

	// Particles
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
		DisplayParticle(entity,	PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
	}

	// Sound
	PlaySound(entity, SOUND_FLICKER);
}

// ====================================================================================================
//					PRJ EFFECT - FLAK
// ====================================================================================================
void PrjEffects_Flak(int entity)
{
	// Grenade Pos + Effects
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 100 100"); // Rose

	// Particles
	if( g_bLeft4Dead2 )
	{
		DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
		DisplayParticle(entity,	PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
	} else {
		DisplayParticle(entity,	PARTICLE_FLARE,		vPos, NULL_VECTOR);
	}

	// Sound
	PlaySound(entity, SOUND_STEAM);
}

// ====================================================================================================
//					PRJ EFFECT - AIRSTRIKE
// ====================================================================================================
void PrjEffects_Airstrike(int entity)
{
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 0 0"); // Red
	DisplayParticle(entity,	PARTICLE_FLARE,		vPos, NULL_VECTOR);
}

// ====================================================================================================
//					PRJ EFFECT - WEAPON
// ====================================================================================================
void PrjEffects_Weapon(int entity)
{
	static float vPos[3];
	SetupPrjEffects(entity, vPos, "255 255 0"); // Yellow
	DisplayParticle(entity,	PARTICLE_FIREWORK,		vPos, NULL_VECTOR);
}



// ====================================================================================================
//					PROJECTILE EXPLODED
// ====================================================================================================
Action Timer_Detonate(Handle timer, int entity)
{
	if( g_bCvarAllow && (entity = EntRefToEntIndex(entity)) != INVALID_ENT_REFERENCE )
	{
		Detonate_Grenade(entity);
	}

	return Plugin_Continue;
}

void OnTouch_Detonate(int entity, int other)
{
	if( other > MaxClients )
	{
		/*
		// Don't hit attached objects to clients
		int parent = GetEntPropEnt(other, Prop_Send, "moveparent");

		// Is attached to something attached to clients?
		while( parent > MaxClients )
		{
			parent = GetEntPropEnt(parent, Prop_Send, "moveparent");
		}

		// Don't allow using when hitting attached object of grenade owner
		if( parent > 0 && parent <= MaxClients )
		{
			int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

			if( client == parent )
			{
				return;
			}
		}
		// */

		static char classname[10];
		GetEdictClassname(other, classname, sizeof(classname));
		if( strncmp(classname, "trigger_", 8) == 0 ) return;

		// Get index
		int index = g_GrenadeType[entity];

		// Stick to surface, unless hitting a client
		if( g_GrenadeData[index - 1][CONFIG_STICK] )
		{
			SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", view_as<float>({ 0.0, 0.0, 0.0 }));
			SetEntityMoveType(entity, MOVETYPE_NONE);
			SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
		}
	}

	Detonate_Grenade(entity);
	SDKUnhook(entity, SDKHook_Touch, OnTouch_Detonate);
}

void Detonate_Grenade(int entity)
{
	// Validate client
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if( client > 0 && IsClientInGame(client) )
	{
		// Get index
		int index = g_GrenadeType[entity];
		if( index < 0 || index > MAX_TYPES) return;

		static float vPos[3];

		// Grenade Pos
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

		// Explosion start time
		SetEntPropFloat(entity, Prop_Data, "m_flCreateTime", GetGameTime());

		// Prevent error msg: "Entity 157 (class 'pipe_bomb_projectile') reported ENTITY_CHANGE_NONE but 'm_flCreateTime' changed."
		int offset = FindDataMapInfo(entity, "m_flCreateTime");
		ChangeEdictState(entity, offset);

		// Do explode
		Explode_Effects(client, entity, index, false);

		// Detonation duration
		float tick = g_GrenadeData[index - 1][CONFIG_TICK];
		if( tick != 0.0 )
		{
			CreateTimer(tick, Timer_Repeat_Explode, EntIndexToEntRef(entity), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}

		// Stop env_steam
		static char sTemp[64];
		Format(sTemp, sizeof(sTemp), "OnUser4 silv_steam_%d:TurnOff::0.0:-1", entity);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "AddOutput");
		Format(sTemp, sizeof(sTemp), "OnUser4 silv_steam_%d:Kill::2.0:-1", entity);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser4");
	}
}

Action Timer_Repeat_Explode(Handle timer, int entity)
{
	if( g_bCvarAllow && (entity = EntRefToEntIndex(entity)) != INVALID_ENT_REFERENCE )
	{
		// Get index
		int index = g_GrenadeType[entity];

		// Validate client
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if( client > 0 && IsClientInGame(client) )
		{
			// Do explode
			Explode_Effects(client, entity, index);
		}

		// Check duration
		if( GetGameTime() - GetEntPropFloat(entity, Prop_Data, "m_flCreateTime") > g_GrenadeData[index - 1][CONFIG_TIME] )
		{
			InputKill(entity, 0.2);

			// Stop sounds
			StopSounds(entity);
			return Plugin_Stop;
		}

		return Plugin_Continue;
	}

	return Plugin_Stop;
}



// ====================================================================================================
//					EXPLOSION EFFECTS - Create explosion effects
// ====================================================================================================
void Explode_Effects(int client, int entity, int index, bool fromTimer = true)
{
	CreateHurtEntity();

	switch( index - 1 )
	{
		case INDEX_BOMB:			Explode_Bomb			(client, entity, index);
		case INDEX_CLUSTER:			Explode_Cluster			(client, entity, index, fromTimer);
		case INDEX_FIREWORK:		Explode_Firework		(client, entity, index, fromTimer);
		case INDEX_SMOKE:			Explode_Smoke			(client, entity, index, fromTimer);
		case INDEX_BLACKHOLE:		Explode_BlackHole		(client, entity, index, fromTimer);
		case INDEX_FLASHBANG:		Explode_Flashbang		(client, entity, index);
		case INDEX_SHIELD:			Explode_Shield			(entity, index, fromTimer);
		case INDEX_TESLA:			Explode_Tesla			(client, entity, index, fromTimer);
		case INDEX_CHEMICAL:		Explode_Chemical		(client, entity, index, fromTimer);
		case INDEX_FREEZER:			Explode_Freezer			(client, entity, index, fromTimer);
		case INDEX_MEDIC:			Explode_Medic			(entity, index);
		case INDEX_VAPORIZER:		Explode_Vaporizer		(client, entity, index, fromTimer);
		case INDEX_EXTINGUISHER:	Explode_Extinguisher	(client, entity, index);
		case INDEX_GLOW:			Explode_Glow			(client, entity, index);
		case INDEX_ANTIGRAVITY:		Explode_AntiGravity		(client, entity, index);
		case INDEX_FIRECLUSTER:		Explode_Cluster			(client, entity, index, fromTimer);
		case INDEX_BULLETS:			Explode_Bullets			(client, entity, index, fromTimer);
		case INDEX_FLAK:			Explode_Flak			(client, entity, index);
		case INDEX_AIRSTRIKE:		Explode_Airstrike		(client, entity, index);
		case INDEX_WEAPON:			Explode_Weapon			(client, entity, index);
	}

	// Detonation duration - instant explode only
	float tick = g_GrenadeData[index - 1][CONFIG_TICK];
	float time = g_GrenadeData[index - 1][CONFIG_TIME];
	if( tick == 0.0 || time == 0.0 )
	{
		InputKill(entity, 0.2);

		// Stop sounds
		StopSounds(entity);
	}
}



// ====================================================================================================
//					EXPLOSION FX - BOMB
// ====================================================================================================
void Explode_Bomb(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_BLAST);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(entity,		PARTICLE_CHARGE,	vPos, NULL_VECTOR);
	DisplayParticle(entity,			PARTICLE_BURST,		vPos, NULL_VECTOR);
	DisplayParticle(entity,			PARTICLE_PIPE1,		vPos, NULL_VECTOR);

	// Sound
	if( g_bLeft4Dead2 )
	{
		int random = GetRandomInt(1, 4);
		switch( random )
		{
			case 1: PlaySound(entity, SOUND_FIREWORK1);
			case 2: PlaySound(entity, SOUND_FIREWORK2);
			case 3: PlaySound(entity, SOUND_FIREWORK3);
			case 4: PlaySound(entity, SOUND_FIREWORK4);
		}
	} else {
		if( GetRandomInt(0, 1) ) PlaySound(entity, SOUND_EXPLODE3);
		else PlaySound(entity, SOUND_EXPLODE5);
	}
}

// ====================================================================================================
//					EXPLOSION FX - CLUSTER
// ====================================================================================================
void Explode_Cluster(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	if( fromTimer == false )
	{
		// Explosion
		CreateExplosion(client, entity, index, 0.0, vPos, DMG_BLAST);

		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);
	}

	// Particles
	DisplayParticle(entity, PARTICLE_BLAST,			vPos, NULL_VECTOR);
	DisplayParticle(entity, PARTICLE_BLAST2,		vPos, NULL_VECTOR);
	DisplayParticle(entity, PARTICLE_PIPE2,			vPos, NULL_VECTOR);

	// Sound
	if( g_bLeft4Dead2 )
	{
		int random = GetRandomInt(1, 4);
		switch( random )
		{
			case 1: PlaySound(entity, SOUND_FIREWORK1);
			case 2: PlaySound(entity, SOUND_FIREWORK2);
			case 3: PlaySound(entity, SOUND_FIREWORK3);
			case 4: PlaySound(entity, SOUND_FIREWORK4);
		}
	} else {
		if( GetRandomInt(0, 1) ) PlaySound(entity, SOUND_EXPLODE3);
		else PlaySound(entity, SOUND_EXPLODE5);
	}

	// Projectiles
	static float vVel[3];
	int max = 3;
	int particle;
	vPos[2] += 10.0;

	if( index - 1 == INDEX_FIRECLUSTER ) max = 1;

	for( int i = 0; i < max; i++ )
	{
		// Create new projectile
		g_bBlockHook = true;
		entity = CreateEntityByName("pipe_bomb_projectile");
		g_bBlockHook = false;

		if( entity != -1 )
		{
			// Fire and forget - cluster projectiles
			InputKill(entity, 3.0);

			g_GrenadeType[entity] = index;								// Store mode type
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); // Store owner

			// Set origin and velocity
			if( index - 1 == INDEX_FIRECLUSTER )
			{
				vVel[0] = GetRandomFloat(-g_GrenadeData[index - 1][CONFIG_RANGE], g_GrenadeData[index - 1][CONFIG_RANGE] / 2);
				vVel[1] = GetRandomFloat(-g_GrenadeData[index - 1][CONFIG_RANGE], g_GrenadeData[index - 1][CONFIG_RANGE] / 2);
				vVel[2] = GetRandomFloat(270.0, g_GrenadeData[index - 1][CONFIG_RANGE]);
			} else {
				vVel[0] = GetRandomFloat(-g_GrenadeData[index - 1][CONFIG_RANGE], g_GrenadeData[index - 1][CONFIG_RANGE]);
				vVel[1] = GetRandomFloat(-g_GrenadeData[index - 1][CONFIG_RANGE], g_GrenadeData[index - 1][CONFIG_RANGE]);
				vVel[2] = GetRandomFloat(270.0, g_GrenadeData[index - 1][CONFIG_RANGE] / 2);
			}

			TeleportEntity(entity, vPos, NULL_VECTOR, vVel);
			DispatchSpawn(entity);
			SetEntityModel(entity, MODEL_SPRAYCAN); // Model after Dispatch otherwise the projectile effects (flashing light + trail) show.
			SetEntityRenderMode(entity, RENDER_NONE);

			// Particles
			particle = DisplayParticle(entity,		PARTICLE_MINIG,		vPos, NULL_VECTOR);
			InputKill(particle, 3.0);

			if( g_bLeft4Dead2 )
			{
				particle = DisplayParticle(entity,	PARTICLE_SPARKS,	vPos, NULL_VECTOR);
				InputKill(particle, 3.0);

				particle = DisplayParticle(entity,	PARTICLE_GSPARKS,	vPos, NULL_VECTOR, 0.2);
				InputKill(particle, 3.0);
			}

			SDKHook(entity, SDKHook_Touch, OnTouchTrigger_Cluster);
		}
	}
}

void OnTouchTrigger_Cluster(int entity, int target)
{
	static char classname[10];
	GetEdictClassname(target, classname, sizeof(classname));
	if( strncmp(classname, "trigger_", 8) == 0 ) return;

	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);
	DisplayParticle(entity, PARTICLE_BLAST2,		vPos, NULL_VECTOR);
	DisplayParticle(entity, PARTICLE_PIPE2,			vPos, NULL_VECTOR);

	InputKill(entity, 0.1);

	// Hurt enemies
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int index = g_GrenadeType[entity];

	if( index - 1 == INDEX_CLUSTER )
		CreateExplosion(client, entity, INDEX_CLUSTER + 1, 200.0, vPos, DMG_BLAST);
	else
	{
		if( g_bLeft4Dead2 ) // Property "m_fireXDelta" does not exist in L4D1. TODO: Make compatible alternative effect.
			g_bHookFire = true;
		CreateFires(entity, client, true);
		g_bHookFire = false;
	}

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE] / 2, 200.0, vPos);
}

// ====================================================================================================
//					EXPLOSION FX - FIREWORK
// ====================================================================================================
void Explode_Firework(int client, int entity, int index, bool fromTimer)
{
	// Only want to trigger effects on initial detonation. Timers will fire past the effect life time when deleting, sometimes wanted in other modes.
	if( fromTimer == false )
	{
		// Grenade Pos
		static float vPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

		// Explosion
		CreateExplosion(client, entity, index, 0.0, vPos, DMG_BURN);

		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

		// Particles
		DisplayParticle(entity, PARTICLE_BLAST,			vPos, NULL_VECTOR);
		DisplayParticle(entity, PARTICLE_BLAST2,		vPos, NULL_VECTOR);
		DisplayParticle(entity, PARTICLE_PIPE2,			vPos, NULL_VECTOR);

		// Sound
		if( GetRandomInt(0, 1) ) PlaySound(entity, SOUND_EXPLODE3);
		else PlaySound(entity, SOUND_EXPLODE5);

		// Fire
		CreateFires(entity, client, !g_bLeft4Dead2);

		// Fire Particles
		if( g_bLeft4Dead2 == false )
		{
			DisplayParticle(entity,		PARTICLE_TES6,			vPos, NULL_VECTOR);
			DisplayParticle(entity,		PARTICLE_TES7,			vPos, NULL_VECTOR);
		} else {
			DisplayParticle(entity,		PARTICLE_GSPARKS,		vPos, NULL_VECTOR);
		}
	}
}

// ====================================================================================================
//					EXPLOSION FX - SMOKE
// ====================================================================================================
void Explode_Smoke(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	if( fromTimer == false )
	{
		// Explosion
		CreateExplosion(client, entity, index, 0.0, vPos, DMG_NERVEGAS);

		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);
	}

	// Particles
	DisplayParticle(entity, PARTICLE_BLACK,			vPos, NULL_VECTOR);
	DisplayParticle(entity, PARTICLE_SMOKER,		vPos, NULL_VECTOR);
}

// ====================================================================================================
//					EXPLOSION FX - BLACK HOLE
// ====================================================================================================
void Explode_BlackHole(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Create Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_GENERIC);

	if( fromTimer == false )
	{
		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

		// Particles
		if( g_bLeft4Dead2 )
			DisplayParticle(entity,		PARTICLE_CHARGE,	vPos, NULL_VECTOR);
		DisplayParticle(entity,			PARTICLE_TES2,		vPos, NULL_VECTOR, 1.0);
	}

	// Sound
	PlaySound(entity, g_sSoundsZap[GetRandomInt(0, sizeof(g_sSoundsZap) - 1)]);

	// Beam Ring
	float range = g_GrenadeData[index - 1][CONFIG_RANGE] * 2 + BEAM_OFFSET;
	CreateBeamRing(entity, { 255, 0, 255, 255 }, range - (range / BEAM_RINGS), 0.1);
}

// ====================================================================================================
//					EXPLOSION FX - FLASHBANG
// ====================================================================================================
void Explode_Flashbang(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_GENERIC);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

	// Particles
	int ent;
	if( g_bLeft4Dead2 )
	{
		ent = DisplayParticle(0,	PARTICLE_CHARGE,		vPos, NULL_VECTOR);
		if( ent ) InputKill(ent, 1.0);
	}
	ent = DisplayParticle(0,		PARTICLE_PIPE3,			vPos, NULL_VECTOR);
	if( ent ) InputKill(ent, 1.0);

	// Sound
	if( GetRandomInt(0, 1) ) PlaySound(entity, SOUND_EXPLODE3);
	else PlaySound(entity, SOUND_EXPLODE5);

	// Kill flashbang
	RemoveEntity(entity);
}

// ====================================================================================================
//					EXPLOSION FX - SHIELD
// ====================================================================================================
void Explode_Shield(int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Particles
	DisplayParticle(entity, PARTICLE_TES2,		vPos, NULL_VECTOR);

	// Sound
	PlaySound(entity, SOUND_BUTTON1);

	// Beam rings
	float range = g_GrenadeData[index - 1][CONFIG_RANGE] * 2 + BEAM_OFFSET;
	static bool flip; // Should be stored globally to avoid conflict on multiple shields, but meh
	flip = !flip;
	CreateBeamRing(entity, { 0, 220, 255, 255 }, flip ? 0.1 : range - (range / BEAM_RINGS), flip ? range - (range / BEAM_RINGS) : 0.1);

	if( fromTimer == false )
	{
		// Create Trigger
		TriggerMultipleDamage(entity, index, range, vPos);
	}
}

void OnTouchTriggerShield(int target)
{
	if( target <= MaxClients && GetClientTeam(target) == 2 )
	{
		if( g_fLastShield[target] == 0.0 )
		{
			SDKHook(target, SDKHook_OnTakeDamageAlive, OnShield);
		}

		g_fLastShield[target] = GetGameTime();
	}
}

Action OnShield(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	// Check hook time
	if( GetGameTime() - g_fLastShield[victim] > 0.5 )
	{
		g_fLastShield[victim] = 0.0;
		SDKUnhook(victim, SDKHook_OnTakeDamageAlive, OnShield);
		return Plugin_Continue;
	}

	if( GetClientTeam(victim) == 2 )
	{
		damage *= (100 - g_GrenadeData[INDEX_SHIELD][CONFIG_DAMAGE]) / 100;
		if( damage < 0.0 ) damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

// ====================================================================================================
//					EXPLOSION FX - TESLA
// ====================================================================================================
void Explode_Tesla(int client, int grenade, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(grenade, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, grenade, index, 0.0, vPos, DMG_PLASMA, true);

	// Particles
	if( GetGameTime() - g_fLastTesla[grenade] >= 1.8 )
	{
		DisplayParticle(grenade, PARTICLE_TES2, vPos, NULL_VECTOR);
		g_fLastTesla[grenade] = GetGameTime();
	}

	if( fromTimer == false )
	{
		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);
	}
}

void TeslaShock(int grenade, int target)
{
	static char sTemp[32];
	static float vPos[3];
	int entity;
	int iType = GetRandomInt(0, 1);



	// PARTICLE TARGET
	entity = CreateEntityByName(g_bLeft4Dead2 ? "info_particle_target" : "info_particle_system");

	if( iType == 0 )
		DispatchKeyValue(entity, "effect_name", PARTICLE_TES1);
	else if( iType == 1 )
		DispatchKeyValue(entity, "effect_name", PARTICLE_TES3);

	Format(sTemp, sizeof(sTemp), "tesla%d%d%d", entity, grenade, target);
	DispatchKeyValue(entity, "targetname", sTemp);

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", grenade);
	vPos[2] = 10.0;
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Start");

	InputKill(entity, 1.5);



	// PARTICLE
	entity = CreateEntityByName("info_particle_system");
	DispatchKeyValue(entity, "cpoint1", sTemp);
	if( iType == 0 )
		DispatchKeyValue(entity, "effect_name", PARTICLE_TES1);
	else if( iType == 1 )
		DispatchKeyValue(entity, "effect_name", PARTICLE_TES3);

	AcceptEntityInput(entity, "Start");

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", target);
	vPos[2] = GetRandomFloat(10.0, 50.0);
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);

	InputKill(entity, 1.2);



	// SOUND
	PlaySound(entity, g_sSoundsZap[GetRandomInt(0, sizeof(g_sSoundsZap) - 1)]);
}

// ====================================================================================================
//					EXPLOSION FX - CHEMICAL
// ====================================================================================================
void Explode_Chemical(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_BULLET);

	if( fromTimer == false )
	{
		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

		// Particles
		if( g_bLeft4Dead2 )
		{
			// Would prefer the particles above the grenade, but need to parent so it moves with the grenade and not bugged.
			DisplayParticle(entity, PARTICLE_SPIT_P,		vPos, NULL_VECTOR, 0.5);

			// SetParent forces this particle to 0,0,0 on the parent entity, to teleport slightly above it cannot be parented.
			// vPos[2] += 10.0;
			// entity = DisplayParticle(0, PARTICLE_SPIT_P,		vPos, NULL_VECTOR, 0.5);
			// vPos[2] -= 10.0;

			// Fire and forget itself
			// InputKill(entity, g_GrenadeData[index - 1][CONFIG_TIME]);
		}
		else
		{
			DisplayParticle(entity, PARTICLE_TRAIL,			vPos, NULL_VECTOR, 0.5);
			DisplayParticle(entity, PARTICLE_SPLASH,		vPos, NULL_VECTOR, 0.7);
			DisplayParticle(entity, PARTICLE_STEAM,			vPos, NULL_VECTOR, 0.5);
		}

		// Spitter Goo
		if( g_bLeft4Dead2 )
		{
			vPos[1] += 5.0;
			vPos[2] += 5.0;
			g_bAcidSpawn = true;
			entity = SDKCall(g_hSDK_ActivateSpit, vPos, view_as<float>({ 0.0, 0.0, 0.0 }), view_as<float>({ 0.0, 0.0, 0.0 }), view_as<float>({ 0.0, 0.0, 0.0 }), client);
			SetEntPropEnt(entity, Prop_Data, "m_hThrower", client);
			vPos[1] -= 5.0;
			vPos[2] -= 5.0;
		}
	}
}

Action OnAcidDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	// if( damagetype == (DMG_ENERGYBEAM | DMG_RADIATION) || damagetype == (DMG_ENERGYBEAM | DMG_RADIATION | DMG_PREVENT_PHYSICS_FORCE) )
	// 1024 (1<<10) DMG_ENERGYBEAM
	// 2048 (1<<11) DMG_PREVENT_PHYSICS_FORCE
	// 262144 (1<<18) DMG_RADIATION

	if( damagetype == 263168 || damagetype == 265216 ) // 265216 at end of entity life when fading out
	{
		int entity;
		int len = g_hAlAcid.Length;

		// Match inflictor with one we created
		for( int i = 0; i < len; i++ )
		{
			entity = g_hAlAcid.Get(i);

			// Clear invalid ents
			if( EntRefToEntIndex(entity) == INVALID_ENT_REFERENCE )
			{
				g_hAlAcid.Erase(i);
				i--;
			}

			// Modify damage
			if( entity == inflictor )
			{
				if( victim > 0 && victim <= MaxClients )
				{
					if( victim == attacker )
					{
						damage *= g_fConfigAcidSelf;
						return Plugin_Changed;
					}
					else
					{
						int team = GetClientTeam(victim);
						if( team == 2 ) damage *= g_fConfigAcidSurv;
						else if( team == 3 ) damage *= g_fConfigAcidSpec;
						return Plugin_Changed;
					}
				}
				else if( victim > MaxClients )
				{
					damage *= g_fConfigAcidComm;
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}

// ====================================================================================================
//					EXPLOSION FX - FREEZER
// ====================================================================================================
void Explode_Freezer(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	if( fromTimer == false )
	{
		// Explosion
		CreateExplosion(client, entity, index, 0.0, vPos, DMG_GENERIC);

		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

		// Trigger
		float range = g_GrenadeData[index - 1][CONFIG_RANGE];
		TriggerMultipleDamage(entity, index, range, vPos);
	}

	// Particles
	DisplayParticle(entity, PARTICLE_SPLASH, vPos, NULL_VECTOR);

	// Sound
	int random = GetRandomInt(1, 3);
	switch( random )
	{
		case 1: PlaySound(entity, SOUND_SPLASH1);
		case 2: PlaySound(entity, SOUND_SPLASH2);
		case 3: PlaySound(entity, SOUND_SPLASH3);
	}
}

void OnTouchTriggerFreezer2(int entity, int target)
{
	if( target > MaxClients )
	{
		static char classname[12];
		GetEdictClassname(target, classname, sizeof(classname));

		int targ = g_GrenadeTarg[INDEX_FREEZER];
		if( (targ & (1 << TARGET_COMMON) && strcmp(classname, "infected") == 0) || (targ & (1 << TARGET_WITCH) && strcmp(classname, "witch") == 0) )
		{
			if( g_bLeft4Dead2 )
				SetEntPropFloat(target, Prop_Data, "m_flFrozen", 0.3); // Only exists in L4D2

			PlaySound(target, SOUND_FREEZER);

			static float vPos[3];
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", vPos);
			int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			PushCommon(client, target, vPos);
		}
	}
}

void OnTouchTriggerFreezer(int target)
{
	if( target <= MaxClients )
	{
		int targ = g_GrenadeTarg[INDEX_FREEZER];

		if( (targ & (1<<TARGET_SURVIVOR) || targ & (1<<TARGET_SPECIAL)) )
		{
			if( GetEntProp(target, Prop_Send, "m_fFlags") & FL_ONGROUND )
			{
				bool pass;

				int team = GetClientTeam(target);
				if( team == 2 && targ & (1<<TARGET_SURVIVOR) )
					pass = true;
				else if( team == 3 && targ & (1<<TARGET_SPECIAL) && GetEntProp(target, Prop_Send, "m_zombieClass") != g_iClassTank )
					pass = true;
				else if( team == 3 && targ & (1<<TARGET_TANK) && GetEntProp(target, Prop_Send, "m_zombieClass") == g_iClassTank )
					pass = true;

				// Ignore ghosts
				if( team == 3 && GetEntProp(target, Prop_Send, "m_isGhost") == 1 )
					pass = false;

				if( pass )
				{
					if( GetGameTime() - g_fLastFreeze[target] > g_fConfigFreezeTime )
					{
						CreateTimer(0.5, TimerFreezer, GetClientUserId(target), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

						PlaySound(target, SOUND_FREEZER);

						if( GetEntProp(target, Prop_Send, "m_clrRender") == -1 )
						{
							SetEntityRenderColor(target, 0, 128, 255, 192);
						}
					}

					if( GetEntityMoveType(target) != MOVETYPE_NONE )
						SetEntityMoveType(target, MOVETYPE_NONE); // Has to be outside the timer, if player staggers they'll be able to move, so constantly apply.

					g_fLastFreeze[target] = GetGameTime();
				}
			}
		}
	}
}

Action TimerFreezer(Handle timer, int client)
{
	if( (client = GetClientOfUserId(client)) && IsClientInGame(client) && IsPlayerAlive(client) )
	{
		if( GetGameTime() - g_fLastFreeze[client] < g_fConfigFreezeTime )
		{
			if( GetEntityMoveType(client) != MOVETYPE_NONE )
				SetEntityMoveType(client, MOVETYPE_NONE);

			return Plugin_Continue;
		}

		PlaySound(client, SOUND_FREEZER);

		if( GetEntProp(client, Prop_Send, "m_clrRender") == -1056997376 ) // Our render color
			SetEntityRenderColor(client, 255, 255, 255, 255);

		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	return Plugin_Stop;
}

// ====================================================================================================
//					EXPLOSION FX - MEDIC
// ====================================================================================================
void Explode_Medic(int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

	// Sound
	PlaySound(entity, SOUND_BUTTON2);

	// Beam Ring
	float range = g_GrenadeData[index - 1][CONFIG_RANGE] * 2 + BEAM_OFFSET;
	CreateBeamRing(entity, { 0, 150, 0, 255 }, 0.1, range - (range / BEAM_RINGS));

	// Heal targets
	int targ = g_GrenadeTarg[INDEX_MEDIC];
	int team;
	bool pass;

	int iHeal = RoundFloat(g_GrenadeData[index - 1][CONFIG_DAMAGE]);
	int iHealth;
	int iMax;
	float fHealth;
	float fRange = g_GrenadeData[index - 1][CONFIG_RANGE];
	float vEnd[3];



	// Survivors and Special Infected
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame(i) && IsPlayerAlive(i) )
		{
			team = GetClientTeam(i);
			if( team == 2 && targ & (1<<TARGET_SURVIVOR) )
				pass = true;
			else if( team == 3 && targ & (1<<TARGET_SPECIAL) && GetEntProp(i, Prop_Send, "m_zombieClass") != g_iClassTank )
				pass = true;
			else if( team == 3 && targ & (1<<TARGET_TANK) && GetEntProp(i, Prop_Send, "m_zombieClass") == g_iClassTank )
				pass = true;

			if( pass )
			{
				GetClientAbsOrigin(i, vEnd);
				if( GetVectorDistance(vPos, vEnd) <= fRange )
				{
					// Check for Black and White health:
					bool bBlackAndWhite;
					if( team == 2 )
					{
						if( g_bLeft4Dead2 )
							bBlackAndWhite = view_as<bool>(GetEntProp(i, Prop_Send, "m_bIsOnThirdStrike", 1));
						else
							bBlackAndWhite = GetEntProp(i, Prop_Send, "m_currentReviveCount") >= GetMaxReviveCount();
					}

					if( bBlackAndWhite )
					{
						fHealth = GetTempHealth(i);
						if( fHealth < 100 )
						{
							fHealth += g_GrenadeData[index - 1][CONFIG_DAMAGE];

							if( fHealth > 100.0 )
								fHealth = 100.0;

							SetTempHealth(i, fHealth);
						}
					} else {
						iHealth = GetClientHealth(i);
						iMax = GetClientMaxHealth(i);
	
						if( iHealth < iMax )
						{
							iHealth += iHeal;
							if( iHealth > iMax )
								iHealth = iMax;

							if( team == 2 )
							{
								fHealth = GetTempHealth(i);
								if( iHealth + fHealth > 100 )
								{
									fHealth = 100.0 - iHealth;
									SetTempHealth(i, fHealth);
								}
							}

							SetEntityHealth(i, iHealth);
						}
					}
				}
			}
		}
	}



	// Common
	if( targ & (1<<TARGET_COMMON) )
	{
		int target = -1;

		while( (target = FindEntityByClassname(target, "infected")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vEnd);
			if( GetVectorDistance(vPos, vEnd) <= fRange )
			{
				iMax = GetEntProp(target, Prop_Data, "m_iMaxHealth");
				iHealth = GetEntProp(target, Prop_Data, "m_iHealth");
				iHealth += iHeal;

				if( iHealth > iMax )
					iHealth = iMax;

				SetEntProp(target, Prop_Data, "m_iHealth", iHealth);
			}
		}
	}



	// Witch
	if( targ & (1<<TARGET_WITCH) )
	{
		int target = -1;

		while( (target = FindEntityByClassname(target, "witch")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vEnd);
			if( GetVectorDistance(vPos, vEnd) <= fRange )
			{
				iMax = GetEntProp(target, Prop_Data, "m_iMaxHealth");
				iHealth = GetEntProp(target, Prop_Data, "m_iHealth");
				iHealth += iHeal;

				if( iHealth > iMax )
					iHealth = iMax;

				SetEntProp(target, Prop_Data, "m_iHealth", iHealth);
			}
		}
	}
}

int GetClientMaxHealth(int client)
{
	int entity = GetPlayerManager();

	if( entity != INVALID_ENT_REFERENCE )
	{
		return GetEntData(entity, m_maxHealth + (client * 4));
	}

	return 0;
}

int GetPlayerManager()
{
	static int entity = INVALID_ENT_REFERENCE;
	if( entity == INVALID_ENT_REFERENCE || EntRefToEntIndex(entity) == INVALID_ENT_REFERENCE )
	{
		entity = FindEntityByClassname(-1, "terror_player_manager");
		if( entity != INVALID_ENT_REFERENCE ) entity = EntIndexToEntRef(entity);
	}

	return entity;
}

// Stock taken from "LMC_Black_and_White_Notifier" by "Lux".
// https://github.com/LuxLuma/LMC_Black_and_White_Notifier/blob/master/LMC_Black_and_White_Notifier.sp
int GetMaxReviveCount()
{
	static Handle hMaxReviveCount = INVALID_HANDLE;
	if (hMaxReviveCount == INVALID_HANDLE)
	{
		hMaxReviveCount = FindConVar("survivor_max_incapacitated_count");
		if (hMaxReviveCount == INVALID_HANDLE)
		{
			return -1;
		}
	}
	
	return GetConVarInt(hMaxReviveCount);
}

// ====================================================================================================
//					EXPLOSION FX - VAPORIZER
// ====================================================================================================
void Explode_Vaporizer(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_BULLET, true);

	// Shake
	if( fromTimer == false )
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);
}

void DissolveCommon(int client, int entity, int target, float fDamage)
{
	// Pos
	static float vPos[3], vEnd[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vPos);
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", vEnd);
	vEnd[2] += 50;

	// Beam
	TE_SetupBeamPoints(vPos, vEnd, g_BeamSprite, g_HaloSprite, 30, 0, 0.2, 1.0, 2.0, 0, 0.0, { 50, 50, 150, 150 }, 0);
	TE_SendToAll();

	// Sound
	PlaySound(target, g_sSoundsZap[GetRandomInt(0, 7)]);

	// Damage - only dissolve when dead
	if( GetEntProp(target, Prop_Data, "m_iHealth") - fDamage > 0 )
		return;

	// Dissolve
	int iOverlayModel = -1;
	if( g_bLMC_Available )
		iOverlayModel = LMC_GetEntityOverlayModel(target);

	if( target <= MaxClients )
	{
		int clone = AttachFakeRagdoll(target);
		if( clone > 0 )
		{
			SetEntityRenderMode(clone, RENDER_NONE); // Hide and dissolve clone - method to show more particles
			DissolveTarget(client, clone, GetEntProp(target, Prop_Send, "m_zombieClass") == 2 ? 0 : target); // Exclude boomer to producer gibs
		}
	} else {
		SetEntityRenderFx(target, RENDERFX_FADE_FAST);
		if( iOverlayModel < 1 )
			DissolveTarget(client, target);
		else
			DissolveTarget(client, target, iOverlayModel);
	}
}

void DissolveTarget(int client, int target, int iOverlayModel = 0)
{
	// CreateEntityByName "env_entity_dissolver" has broken particles, this way works 100% of the time
	float time = GetRandomFloat(0.2, 0.7);

	int dissolver = SDKCall(g_hSDK_DissolveCreate, iOverlayModel ? iOverlayModel : target, "", GetGameTime() + time, 2, false);
	if( dissolver > MaxClients && IsValidEntity(dissolver) )
	{
		if( target > MaxClients )
		{
			// Have to kill here because this function is called above the actual hurt in CreateExplosion.
			SDKHooks_TakeDamage(target, client, client, float(GetEntProp(target, Prop_Data, "m_iHealth") - 10), DMG_GENERIC);

			// Prevent common infected from crashing the server when taking damage from the dissolver.
			SDKHook(target, SDKHook_OnTakeDamage, OnCommonDamage);

			// Prevent immortal common infected if they fail to die from the dissolver.
			// Bug should not happen because the SDKHook was in the wrong section in version <= 1.5 (from Dissolve Infected plugin).
			InputKill(target, time + 0.5);
		}

		SetEntPropFloat(dissolver, Prop_Send, "m_flFadeOutStart", 0.0); // Fixes broken particles

		int fader = CreateEntityByName("func_ragdoll_fader");
		if( fader != -1 )
		{
			static float vec[3];
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", vec);
			TeleportEntity(fader, vec, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(fader);

			SetEntPropVector(fader, Prop_Send, "m_vecMaxs", view_as<float>({ 50.0, 50.0, 50.0 }));
			SetEntPropVector(fader, Prop_Send, "m_vecMins", view_as<float>({ -50.0, -50.0, -50.0 }));
			SetEntProp(fader, Prop_Send, "m_nSolidType", 2);

			InputKill(fader, 0.1);
		}
	}
}

int AttachFakeRagdoll(int target)
{
	int entity = CreateEntityByName("prop_dynamic_ornament");
	if( entity != -1 )
	{
		static char sModel[64];
		GetEntPropString(target, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		DispatchKeyValue(entity, "model", sModel);
		DispatchSpawn(entity);

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target);
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetAttached", target);
	}

	return entity;
}

Action OnCommonDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	// Block dissolver damage to common, otherwise server will crash.
	if( damage == 10000 && damagetype == (g_bLeft4Dead2 ? 5982249 : 33540137) )
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// ====================================================================================================
//					EXPLOSION FX - EXTINGUISHER
// ====================================================================================================
void Explode_Extinguisher(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_BULLET, true);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE] + SHAKE_RANGE, vPos);

	// Particles
	DisplayParticle(entity, PARTICLE_SPLASH, vPos, NULL_VECTOR, 0.7);

	// Sound
	int random = GetRandomInt(1, 3);
	switch( random )
	{
		case 1: PlaySound(entity, SOUND_SPLASH1);
		case 2: PlaySound(entity, SOUND_SPLASH2);
		case 3: PlaySound(entity, SOUND_SPLASH3);
	}

	float vEnd[3];

	// Extinguish fires
	if( g_fConfigExtEffect & EXT_FIRES )
	{
		int inferno = -1;
		while( (inferno = FindEntityByClassname(inferno, "inferno")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(inferno, Prop_Data, "m_vecAbsOrigin", vEnd);
			if( GetVectorDistance(vPos, vEnd) < g_GrenadeData[INDEX_EXTINGUISHER][CONFIG_RANGE] )
			{
				RemoveEntity(inferno);
			}
		}

		inferno = -1;
		while( (inferno = FindEntityByClassname(inferno, "fire_cracker_blast")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(inferno, Prop_Data, "m_vecAbsOrigin", vEnd);
			if( GetVectorDistance(vPos, vEnd) < g_GrenadeData[INDEX_EXTINGUISHER][CONFIG_RANGE] )
			{
				RemoveEntity(inferno);
			}
		}
	}

	// Extinguish Spitter acid
	if( g_bLeft4Dead2 && g_fConfigExtEffect & EXT_SPITS )
	{
		int swarm = -1;
		while( (swarm = FindEntityByClassname(swarm, "insect_swarm")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(swarm, Prop_Data, "m_vecAbsOrigin", vEnd);
			if( GetVectorDistance(vPos, vEnd) < g_GrenadeData[INDEX_EXTINGUISHER][CONFIG_RANGE] )
			{
				RemoveEntity(swarm);
			}
		}

		swarm = -1;
		while( (swarm = FindEntityByClassname(swarm, "insect_swarm")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(swarm, Prop_Data, "m_vecAbsOrigin", vEnd);
			if( GetVectorDistance(vPos, vEnd) < g_GrenadeData[INDEX_EXTINGUISHER][CONFIG_RANGE] )
			{
				RemoveEntity(swarm);
			}
		}
	}
}

// ====================================================================================================
//					EXPLOSION FX - GLOW
// ====================================================================================================
void Explode_Glow(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_BULLET, true);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE], vPos);

	// Particles
	int particle = DisplayParticle(0, PARTICLE_BOOMER, vPos, NULL_VECTOR);
	if( particle ) InputKill(particle, 3.0);

	particle = DisplayParticle(0, PARTICLE_SMOKER1, vPos, NULL_VECTOR);
	if( particle ) InputKill(particle, 3.0);

	particle = DisplayParticle(0, PARTICLE_SMOKER2, vPos, NULL_VECTOR);
	if( particle ) InputKill(particle, 3.0);

	// Sound
	PlaySound(entity, SOUND_GATE, SNDLEVEL_RAIDSIREN);
}

// ====================================================================================================
//					EXPLOSION FX - ANTI-GRAVITY
// ====================================================================================================
void Explode_AntiGravity(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	CreateExplosion(client, entity, index, 0.0, vPos, DMG_BULLET, true);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE], vPos);

	// Sound
	PlaySound(entity, SOUND_BUTTON2, SNDLEVEL_RAIDSIREN);

	// Beam Ring
	float range = g_GrenadeData[index - 1][CONFIG_RANGE] * 2 + BEAM_OFFSET;
	CreateBeamRing(entity, { 0, 255, 100, 255 }, range - (range / BEAM_RINGS), 0.1);
}

// ====================================================================================================
//					EXPLOSION FX - BULLETS
// ====================================================================================================
void Explode_Bullets(int client, int entity, int index, bool fromTimer)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Explosion
	if( fromTimer == false )
	{
		CreateExplosion(client, entity, index, 0.0, vPos, DMG_BULLET, true);

		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE], vPos);
	}

	// Sound
	if( GetRandomInt(0,3) == 3 )
		PlaySound(entity, g_sSoundsMiss[GetRandomInt(0, sizeof(g_sSoundsMiss) - 1)]);
	PlaySound(entity, SOUND_SHOOTING, SNDLEVEL_RAIDSIREN);



	// Bullets
	Handle trace;
	static char classname[16];
	static float vEnd[3], vAng[3];
	float fDamage;
	int particle;
	int target;
	int targ;
	bool pass;
	vPos[2] += 5.0;

	for( int x = 1; x <= 8; x++ )
	{
		fDamage = g_GrenadeData[index - 1][CONFIG_DAMAGE];
		vAng[0] = GetRandomFloat(-20.0, 5.0); // How far up/down tracers point (0=Horizontal, -90=Up.)
		vAng[1] = GetRandomFloat(-180.0, 180.0); // Random direction

		// Trace + Particles
		trace = TR_TraceRayFilterEx(vPos, vAng, MASK_SHOT, RayType_Infinite, _TraceFilter);
		TR_GetEndPosition(vEnd, trace);

		if( g_bLeft4Dead2 && GetRandomInt(0, 3) == 0 )
			L4D_TE_Create_Particle(vPos, vEnd, g_iParticleTracer50);
		else
			L4D_TE_Create_Particle(vPos, vEnd, g_iParticleTracer);

		if( x <= 3 )
		{
			particle = DisplayParticle(0, PARTICLE_MUZZLE, vPos, vAng);
			InputKill(particle, 0.01);
		}

		// /* // Test to show traces:
		// #include <neon_beams> // Put outside of function
		// float vEnd[3];
		// TR_GetEndPosition(vEnd, trace);
		// NeonBeams_TempMap(0, vPos, vEnd, 5.0);
		// */

		// Validate entity hit
		if( TR_DidHit(trace) )
		{
			target = TR_GetEntityIndex(trace);
			targ = g_GrenadeTarg[index - 1];
			pass = false;

			// Valid target. Scale damage
			if( target > 0 && target <= MaxClients && (targ & (1<<TARGET_SURVIVOR) || targ & (1<<TARGET_SPECIAL)) )
			{
				int team = GetClientTeam(target);
				if( team == 2 && targ & (1<<TARGET_SURVIVOR) )
				{
					fDamage = fDamage * g_fConfigSurvivors * g_GrenadeData[index - 1][CONFIG_DMG_SURVIVORS];
					pass = true;
				}
				else if( team == 3 && targ & (1<<TARGET_SPECIAL) && GetEntProp(target, Prop_Send, "m_zombieClass") != g_iClassTank )
				{
					fDamage = fDamage * g_fConfigSpecial * g_GrenadeData[index - 1][CONFIG_DMG_SPECIAL];
					pass = true;
				}
				else if( team == 3 && targ & (1<<TARGET_TANK) && GetEntProp(target, Prop_Send, "m_zombieClass") == g_iClassTank )
				{
					fDamage = fDamage * g_fConfigTank * g_GrenadeData[index - 1][CONFIG_DMG_TANK];
					pass = true;
				}
			}

			if( target > MaxClients && (targ & (1<<TARGET_WITCH) || targ & (1<<TARGET_COMMON) || targ & (1<<TARGET_PHYSICS)) )
			{
				// Check classname
				GetEdictClassname(target, classname, sizeof(classname));

				if( targ & (1 << TARGET_WITCH) && strcmp(classname, "witch") == 0 )
				{
					fDamage = fDamage * g_fConfigWitch * g_GrenadeData[index - 1][CONFIG_DMG_WITCH];

					pass = true;
				}
				else if( targ & (1 << TARGET_COMMON) && strcmp(classname, "infected") == 0 )
				{
					pass = true;
				}
				else if( targ & (1<<TARGET_PHYSICS) )
				{
					if(
						strcmp(classname, "prop_physics") == 0 ||
						strcmp(classname, "weapon_gascan") == 0
					)
					{
						fDamage = fDamage * g_fConfigPhysics * g_GrenadeData[index - 1][CONFIG_DMG_PHYSICS];

						pass = true;
					}
				}
			}

			if( pass )
			{
				SDKHooks_TakeDamage(target, client, client, fDamage, DMG_BULLET);
			}
		}

		delete trace;
	}
}

// ====================================================================================================
//					EXPLOSION FX - FLAK
// ====================================================================================================
void Explode_Flak(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE], vPos);

	// Sound
	if( g_bLeft4Dead2 )
	{
		int random = GetRandomInt(1, 4);
		switch( random )
		{
			case 1: PlaySound(entity, SOUND_FIREWORK1);
			case 2: PlaySound(entity, SOUND_FIREWORK2);
			case 3: PlaySound(entity, SOUND_FIREWORK3);
			case 4: PlaySound(entity, SOUND_FIREWORK4);
		}
	} else {
		if( GetRandomInt(0, 1) ) PlaySound(entity, SOUND_EXPLODE3);
		else PlaySound(entity, SOUND_EXPLODE5);
	}

	// Random position
	vPos[0] += GetRandomFloat(-g_GrenadeData[index - 1][CONFIG_RANGE], g_GrenadeData[index - 1][CONFIG_RANGE]);
	vPos[1] += GetRandomFloat(-g_GrenadeData[index - 1][CONFIG_RANGE], g_GrenadeData[index - 1][CONFIG_RANGE]);
	vPos[2] += GetRandomFloat(75.0, 120.0);

	// Sparks
	int spark = CreateEntityByName("env_spark");
	DispatchKeyValue(spark, "angles", "-90 0 0");
	DispatchKeyValue(spark, "TrailLength", "1");
	DispatchKeyValue(spark, "Magnitude", "5");
	TeleportEntity(spark, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(spark);
	ActivateEntity(spark);
	AcceptEntityInput(spark, "SparkOnce");
	InputKill(spark, 0.5);

	// Particles
	if( g_bLeft4Dead2 )
		DisplayParticle(spark,		PARTICLE_CHARGE,	vPos, NULL_VECTOR);
	DisplayParticle(spark,			PARTICLE_BLAST,		vPos, NULL_VECTOR);
	DisplayParticle(spark,			PARTICLE_PIPE2,		vPos, NULL_VECTOR);

	// Explosion
	vPos[2] -= 75.0;
	CreateExplosion(client, entity, index, 150.0, vPos, DMG_BLAST);
}

// ====================================================================================================
//					EXPLOSION FX - AIRSTRIKE
// ====================================================================================================
void Explode_Airstrike(int client, int entity, int index)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Shake
	CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE], vPos);

	// Sound
	int random = GetRandomInt(1, 4);
	switch( random )
	{
		case 1: PlaySound(entity, SOUND_FIREWORK1);
		case 2: PlaySound(entity, SOUND_FIREWORK2);
		case 3: PlaySound(entity, SOUND_FIREWORK3);
		case 4: PlaySound(entity, SOUND_FIREWORK4);
	}

	F18_ShowAirstrike(vPos, GetRandomFloat(0.0, 180.0));

	// Explosion
	vPos[2] -= 75.0;
	CreateExplosion(client, entity, index, 150.0, vPos, DMG_BLAST);
}

// ====================================================================================================
//					EXPLOSION FX - WEAPON
// ====================================================================================================
void Explode_Weapon(int client, int entity, int index)
{
	SetEntityRenderMode(entity, RENDER_NONE);

	// Weighted chance
	int model = -1;
	int rand = GetRandomInt(1, g_iTotalChance);

	for( int i = 0; i < (g_bLeft4Dead2 ? MAX_WEAPONS2 + MAX_MELEE : MAX_WEAPONS); i++ )
	{
		if( rand <= g_iChances[i] )
		{
			model = i;
			break;
		}
	}

	if( model == -1 ) return;

	// Grenade Pos
	static float vPos[3], vAng[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);
	vAng[1] = GetRandomFloat(1.0, 360.0);

	// Create
	if( model >= 29 )
	{
		// Melee:
		entity = CreateEntityByName("weapon_melee");
		if( entity == -1 )
			ThrowError("Failed to create entity 'weapon_melee'.");

		DispatchKeyValue(entity, "melee_script_name", g_sWeapons2[model]);

		vPos[2] += 20.0;
		TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
		vPos[2] -= 40.0;

		DispatchSpawn(entity);
	} else {
		// Weapons:
		entity = -1;
		entity = CreateEntityByName(g_bLeft4Dead2 ? g_sWeapons2[model] : g_sWeapons[model]);

		if( entity != -1 )
		{
			DispatchKeyValue(entity, "solid", "6");
			DispatchKeyValue(entity, "model", g_bLeft4Dead2 ? g_sWeaponModels2[model] : g_sWeaponModels[model]);
			DispatchKeyValue(entity, "rendermode", "3");
			DispatchKeyValue(entity, "disableshadows", "1");

			vPos[2] += 10.0;
			TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
			vPos[2] -= 30.0;
			DispatchSpawn(entity);

			int ammo;
			model += 1;

			if( !g_bLeft4Dead2 )
			{
				switch( model )
				{
					case 1:					ammo = g_iAmmoRifle;
					case 2:					ammo = g_iAmmoAutoShot;
					case 3:					ammo = g_iAmmoHunting;
					case 4:					ammo = g_iAmmoSmg;
					case 5:					ammo = g_iAmmoShotgun;
				}
			}
			else
			{
				switch( model )
				{
					case 4, 16:				ammo = g_iAmmoSmg;
					case 1, 7, 10, 15:		ammo = g_iAmmoRifle;
					case 5, 6:				ammo = g_iAmmoShotgun;
					case 2, 11:				ammo = g_iAmmoAutoShot;
					case 14:				ammo = g_iAmmoM60;
					case 22:				ammo = g_iAmmoChainsaw;
					case 8:					ammo = g_iAmmoGL;
					case 3, 13, 17, 18:		ammo = g_iAmmoSniper;
				}
			}

			if( !g_bLeft4Dead2 && model == 1 ) ammo = g_iAmmoShotgun;

			SetEntProp(entity, Prop_Send, "m_iExtraPrimaryAmmo", ammo, 4);
		}
	}

	if( entity != -1 )
	{
		// Shake
		CreateShake(g_GrenadeData[index - 1][CONFIG_SHAKE], g_GrenadeData[index - 1][CONFIG_RANGE], vPos);

		// Sound
		PlaySound(entity, SOUND_GIFT);

		// Particles
		DisplayParticle(entity, PARTICLE_FIREWORK, vPos, NULL_VECTOR);

		// Explosion
		CreateExplosion(client, entity, index, 150.0, vPos, DMG_BLAST);
	}
}



// ====================================================================================================
//					STOCKS - CREATE PROJECTILE
// ====================================================================================================
int CreateProjectile(int entity, int client, int index)
{
	// Save origin and velocity
	static float vPos[3], vAng[3], vVel[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAng);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);
	GetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vVel);

	// Prevent conflict with "Bile The World" and "Detonation force" plugins.
	DispatchKeyValue(entity, "classname", "weapon_pistol");

	// Kill entity
	RemoveEntity(entity);

	// Create new projectile
	g_bBlockHook = true;
	entity = CreateEntityByName("pipe_bomb_projectile"); // prop_physics_override doesn't work with MODEL_SPRAYCAN.
	g_bBlockHook = false;

	if( entity == -1 )
	{
		return 0;
	}

	DispatchKeyValue(entity, "spawnflags", "4");					// Don't collide with player. Thanks to "Dragokas".
	g_GrenadeType[entity] = index;									// Store mode type
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);		// Store owner
	SetEntPropFloat(entity, Prop_Data, "m_flGravity", g_GrenadeData[index - 1][CONFIG_GRAVITY]);
	SetEntPropFloat(entity, Prop_Data, "m_flElasticity", g_GrenadeData[index - 1][CONFIG_ELASTICITY]);

	// Set origin and velocity
	static float vDir[3];
	GetAngleVectors(vAng, vDir, NULL_VECTOR, NULL_VECTOR);
	vPos[0] += vDir[0] * 10;
	vPos[1] += vDir[1] * 10;
	vPos[2] += vDir[2] * 10;
	TeleportEntity(entity, vPos, vAng, vVel);
	DispatchSpawn(entity);
	SetEntityModel(entity, MODEL_SPRAYCAN); // Model after Dispatch otherwise the projectile effects (flashing light + trail) show and model doesn't change.

	// Randomly spin grenade with Left4DHooks
	if( g_bLeft4DHooks )
	{
		L4D_AngularVelocity(entity, view_as<float>({ 0.0, 1000.0, 0.0}));
	}

	// Fire and forget - if plugins unloaded the entity and fx will still be deleted.
	float tick = g_GrenadeData[index - 1][CONFIG_TICK];
	float time = g_GrenadeData[index - 1][CONFIG_TIME];

	// + 10 to account for flight time before impact.
	InputKill(entity, (time > tick ? time : tick) + g_GrenadeData[index - 1][CONFIG_FUSE] + 10.0);

	return entity;
}



// ====================================================================================================
//					STOCKS - GRENADE MODE
// ====================================================================================================
int IsGrenade(int weapon)
{
	static char classname[20];
	GetEdictClassname(weapon, classname, sizeof(classname));

	if( strcmp(classname[7], "molotov") == 0 )							return 1;
	if( strcmp(classname[7], "pipe_bomb") == 0 )						return 2;
	if( g_bLeft4Dead2 && strcmp(classname[7], "vomitjar") == 0 )		return 3;

	return 0;
}

void ReplaceColors(char[] translation, int size)
{
	ReplaceString(translation, size, "{white}",		"\x01");
	ReplaceString(translation, size, "{cyan}",		"\x03");
	ReplaceString(translation, size, "{orange}",	"\x04");
	ReplaceString(translation, size, "{green}",		"\x05");
}



// ====================================================================================================
//					STOCKS - SOUND
// ====================================================================================================
void PlaySound(int entity, const char[] sound, int level = SNDLEVEL_NORMAL)
{
	EmitSoundToAll(sound, entity, level == SNDLEVEL_RAIDSIREN ? SNDCHAN_ITEM : SNDCHAN_AUTO, level);
}

void StopSounds(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, SOUND_FLICKER);
	StopSound(entity, SNDCHAN_AUTO, SOUND_GAS);
	StopSound(entity, SNDCHAN_AUTO, SOUND_GATE);
	StopSound(entity, SNDCHAN_AUTO, SOUND_NOISE);
	StopSound(entity, SNDCHAN_AUTO, SOUND_SPATIAL);
	StopSound(entity, SNDCHAN_AUTO, SOUND_SQUEAK);
	StopSound(entity, SNDCHAN_AUTO, SOUND_STEAM);
	StopSound(entity, SNDCHAN_AUTO, SOUND_TUNNEL);
}



// ====================================================================================================
//					STOCKS - STAGGER
// ====================================================================================================
void PushCommon(int client, int target, float vPos[3], bool common = true)
{
	// Cannot use SDKHooks_TakeDamage because it doesn't push in the correct direction.
	CreateHurtEntity();

	if( common && g_bLeft4Dead2 )			DispatchKeyValue(g_iEntityHurt, "DamageType", "33554432");	// DMG_AIRBOAT (1<<25)	// Common L4D2
	else if( common )						DispatchKeyValue(g_iEntityHurt, "DamageType", "536870912");	// DMG_BUCKSHOT (1<<29)	// Common L4D1
	else									DispatchKeyValue(g_iEntityHurt, "DamageType", "64");		// DMG_BLAST (1<<6) // Witch

	DispatchKeyValue(g_iEntityHurt, "Damage", "1");
	DispatchKeyValue(target, "targetname", "silvershot");
	TeleportEntity(g_iEntityHurt, vPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(g_iEntityHurt, "Hurt", client, client);
	DispatchKeyValue(target, "targetname", "");
}

void StaggerClient(int userid, const float vPos[3])
{
	if( g_bLeft4Dead2 )
	{
		// Credit to Timocop on VScript function
		static int iScriptLogic = INVALID_ENT_REFERENCE;
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
		{
			iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
			if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
				LogError("Could not create 'logic_script");

			DispatchSpawn(iScriptLogic);
		}

		static char sBuffer[96];
		Format(sBuffer, sizeof(sBuffer), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", userid, RoundFloat(vPos[0]), RoundFloat(vPos[1]), RoundFloat(vPos[2]));
		SetVariantString(sBuffer);
		AcceptEntityInput(iScriptLogic, "RunScriptCode");
		RemoveEntity(iScriptLogic);
	} else {
		userid = GetClientOfUserId(userid);
		SDKCall(g_hSDK_StaggerClient, userid, userid, vPos); // Stagger: SDKCall method
	}
}



// ====================================================================================================
//					STOCKS - EXPLOSION
// ====================================================================================================
void CreateExplosion(int client, int entity, int index, float range = 0.0, float vPos[3], int damagetype = DMG_GENERIC, bool ignorePhysics = false)
{
	index -= 1;
	int targ = g_GrenadeTarg[index];
	if( targ == 0 ) return;



	// Damage tick timeout. Tesla and Vaporizer have their own timeout.
	if( index != INDEX_TESLA && index != INDEX_VAPORIZER )
	{
		if( GetGameTime() - g_fLastTesla[entity] < g_GrenadeData[index][CONFIG_DMG_TICK] ) return;
		g_fLastTesla[entity] = GetGameTime();
	}



	// Range
	float range_damage;
	float range_stumble;
	if( range == 0.0 )
	{
		range_damage		= g_GrenadeData[index][CONFIG_RANGE];
		range_stumble		= g_GrenadeData[index][CONFIG_STUMBLE];
	} else {
		// From Cluster projectiles
		range_damage		= range;
		range_stumble		= range;
	}



	// Vars
	ArrayList aGodMode = new ArrayList(); // GodMode list, prevent players/common/witch from taking env_explosion damage.
	float damage = g_GrenadeData[index][CONFIG_DAMAGE];
	float fDamage, fDistance;
	static float vEnd[3];
	static char sTemp[16];
	int team;
	int i;



	// Hurt survivors/special/common/witch with scaled damage
	vPos[2] -= 5.0;
	CreateHurtEntity();



	// ==================================================
	// PLAYERS - SURVIVORS + SPECIAL INFECTED
	// ==================================================
	// Loop through players, workout range and scale damage according distance. Stumble if needed.
	// Enable godmode so the explosion below does not hurt, and only our scaled damage affects clients.
	// ==================================================
	if( (targ & (1<<TARGET_SURVIVOR) || targ & (1<<TARGET_SPECIAL)) )
	{
		int clients[MAXPLAYERS+1]; // Flashbang
		int flashcount;
		bool tank;

		for( i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) && IsPlayerAlive(i) )
			{
				team = GetClientTeam(i);
				if( team == 2 ? targ & (1<<TARGET_SURVIVOR) : targ & (1<<TARGET_SPECIAL) )
				{
					if( team == 3 && GetEntProp(i, Prop_Send, "m_isGhost") == 1 ) continue; // Ignore ghosts
	
					GetEntPropVector(i, Prop_Data, "m_vecOrigin", vEnd);
					fDistance = GetVectorDistance(vPos, vEnd);

					// Stumble
					// In range, not Cluster projectiles, not Tesla, not BlackHole, not Anti-Gravity
					if( range == 0.0 && range_stumble && fDistance < range_stumble && index != INDEX_TESLA && index != INDEX_BLACKHOLE && index != INDEX_ANTIGRAVITY )
					{
						StaggerClient(GetClientUserId(i), vPos);
					}

					// Scale Damage to Range
					if( fDistance <= range_damage )
					{
						if( index == INDEX_VAPORIZER )
						{
							fDamage = damage; // Full damage
						} else {
							fDamage = fDistance / (index == INDEX_TESLA ? range_damage * 2 : range_damage); // Double Tesla range so damage is more when entering.
							fDamage = damage * fDamage;
							fDamage = damage - fDamage;
						}

						if( team == 3 )
						{
							if( GetEntProp(i, Prop_Send, "m_zombieClass") == g_iClassTank )
							{
								tank = true;

								if( targ & (1<<TARGET_TANK) )
									fDamage = fDamage * g_fConfigTank * g_GrenadeData[index][CONFIG_DMG_TANK];
								else
									fDamage = 0.0;
							}
							else
							{
								tank = false;

								fDamage = fDamage * g_fConfigSpecial * g_GrenadeData[index][CONFIG_DMG_SPECIAL];
							}
						} else {
							fDamage = fDamage * g_fConfigSurvivors * g_GrenadeData[index][CONFIG_DMG_SURVIVORS];
						}

						// Round to 1 because damage fall off scaling can set the value to above 0 and below 1. So affected guaranteed to lose 1 HP.
						if( fDamage > 0.0 && fDamage < 1.0 )
							fDamage = 1.0;

						if( fDamage > 0.0 )
						{
							// ==================================================
							// Grenade mode specific things:
							// ==================================================
							if( GrenadeSpecificExplosion(i, client, entity, index + 1, TARGET_SURVIVOR, 0.0, fDistance, vPos, vEnd) == false )
								fDamage = 0.0;

							// Damage
							if( fDamage != 0.0 && (!g_bLeft4Dead2 || index != INDEX_CHEMICAL) ) // Chemical mode in L4D2 only needs to damage non-survivor, the spit already damages them.
							{
								clients[flashcount++] = i;

								// Hurt
								// Cannot use SDKHooks_TakeDamage because it doesn't push in the correct direction.
								FloatToString(fDamage, sTemp, sizeof(sTemp));
								DispatchKeyValue(g_iEntityHurt, "Damage", sTemp);

								if( index == INDEX_FLAK && ((team == 2 && g_iConfigDmgType & TARGET_SURVIVOR) || (team == 3 && g_iConfigDmgType & TARGET_SPECIAL) || (tank && g_iConfigDmgType & TARGET_TANK)) )
								{
									DispatchKeyValue(g_iEntityHurt, "DamageType", "8");
								} else {
									IntToString(damagetype, sTemp, sizeof(sTemp));
									DispatchKeyValue(g_iEntityHurt, "DamageType", sTemp);
								}
								DispatchKeyValue(i, "targetname", "silvershot");

								if( i == client ) // Otherwise can't hurt self. Also to avoid red flash on Flashbang
									AcceptEntityInput(g_iEntityHurt, "Hurt");
								else
									AcceptEntityInput(g_iEntityHurt, "Hurt", client, client);

								DispatchKeyValue(i, "targetname", "");
							}
						}

						// GodMode
						aGodMode.Push(i);
						SetEntProp(i, Prop_Data, "m_takedamage", 0); // Prevent taking damage from env_explosion
					}
				}
			}
		}

		// Flashbang
		if( flashcount && index == INDEX_FLASHBANG )
		{
			// Blind
			Handle message = StartMessageEx(g_FadeUserMsgId, clients, flashcount);
			BfWrite bf = UserMessageToBfWrite(message);
			bf.WriteShort(RoundFloat(g_GrenadeData[index][CONFIG_TIME]) * 1000);
			bf.WriteShort(100);
			bf.WriteShort(0x0001);
			bf.WriteByte(255);
			bf.WriteByte(255);
			bf.WriteByte(255);
			bf.WriteByte(240);
			EndMessage();

			L4D_TE_Create_Particle(_, _, g_iParticleBashed, _, _, false);
			TE_Send(clients, flashcount);
		}
	}



	// ==================================================
	// COMMON INFECTED - Loop
	// ==================================================
	if( targ & (1 << TARGET_COMMON) )
	{
		int numTesla;
		int numVapo;

		i = -1;
		while( (i = FindEntityByClassname(i, "infected")) != INVALID_ENT_REFERENCE && GetEntProp(i, Prop_Data, "m_iHealth") > 0 )
		{
			GetEntPropVector(i, Prop_Data, "m_vecOrigin", vEnd);
			fDistance = GetVectorDistance(vPos, vEnd);
			if( fDistance <= range_damage )
			{
				if( index == INDEX_VAPORIZER )
				{
					fDamage = damage;
				} else {
					fDamage = fDistance / (index == INDEX_TESLA ? range_damage * 2 : range_damage);
					fDamage = damage * fDamage;
					fDamage = damage - fDamage;
				}



				if( fDamage != 0.0 )
				{
					// ==================================================
					// Grenade mode specific things:
					// ==================================================
					if( GrenadeSpecificExplosion(i, client, entity, index + 1, TARGET_COMMON, fDamage, fDistance, vPos, vEnd) == false )
						fDamage = 0.0;



					// Damage
					if( fDamage != 0.0 )
					{
						// Cannot use SDKHooks_TakeDamage because it doesn't push in the correct direction.
						FloatToString(fDamage, sTemp, sizeof(sTemp));
						DispatchKeyValue(g_iEntityHurt, "Damage", sTemp);

						if( range_stumble && fDistance <= range_stumble )
						{
							if( g_bLeft4Dead2 )		DispatchKeyValue(g_iEntityHurt, "DamageType", "33554432");	// DMG_AIRBOAT (1<<25)	// Common L4D2
							else					DispatchKeyValue(g_iEntityHurt, "DamageType", "536870912");	// DMG_BUCKSHOT (1<<29)	// Common L4D1
						}
						else
						{
							if( index == INDEX_FLAK && g_iConfigDmgType & TARGET_COMMON )
							{
								DispatchKeyValue(g_iEntityHurt, "DamageType", "8");
							} else {
								DispatchKeyValue(g_iEntityHurt, "DamageType", "0");
							}
						}

						DispatchKeyValue(i, "targetname", "silvershot");

						if( index == INDEX_BLACKHOLE )
						{
							static float vAng[3];
							MakeVectorFromPoints(vPos, vEnd, vAng);
							NormalizeVector(vAng, vAng);
							vEnd[0] += vAng[0] * 10;
							vEnd[1] += vAng[1] * 10;
							vEnd[2] += vAng[2] * 10;
							TeleportEntity(g_iEntityHurt, vEnd, NULL_VECTOR, NULL_VECTOR);
						} else {
							TeleportEntity(g_iEntityHurt, vPos, NULL_VECTOR, NULL_VECTOR);
						}

						AcceptEntityInput(g_iEntityHurt, "Hurt", client, client);
						DispatchKeyValue(i, "targetname", "");
					}
				}



				// GodMode
				aGodMode.Push(i);
				SetEntProp(i, Prop_Data, "m_takedamage", 0); // Prevent taking damage from env_explosion



				if( fDamage != 0.0 )
				{
					if( index == INDEX_TESLA )
					{
						if( numTesla++ >= 3 )
						{
							numTesla = 0;
							break;
						}
					}
					else if( index == INDEX_VAPORIZER )
					{
						if( numVapo++ >= 2 )
						{
							numVapo = 0;
							break;
						}
					}
				}
			}
		}
	}



	// ==================================================
	// WITCH - Loop
	// ==================================================
	if( targ & (1 << TARGET_WITCH) )
	{
		i = -1;
		while( (i = FindEntityByClassname(i, "witch")) != INVALID_ENT_REFERENCE )
		{
			GetEntPropVector(i, Prop_Data, "m_vecOrigin", vEnd);
			fDistance = GetVectorDistance(vPos, vEnd);
			if( fDistance <= range_damage )
			{
				if( index == INDEX_VAPORIZER )
				{
					fDamage = damage;
				} else {
					fDamage = fDistance / (index == INDEX_TESLA ? range_damage * 2 : range_damage);
					fDamage = damage * fDamage;
					fDamage = damage - fDamage;
					fDamage = fDamage * g_fConfigWitch * g_GrenadeData[index][CONFIG_DMG_WITCH];
				}



				if( fDamage != 0.0 )
				{
					// ==================================================
					// Grenade mode specific things:
					// ==================================================
					if( GrenadeSpecificExplosion(i, client, entity, index + 1, TARGET_WITCH, 0.0, fDistance, vPos, vEnd) == false )
						fDamage = 0.0;



					// Damage
					if( fDamage != 0.0 )
					{
						// Cannot use SDKHooks_TakeDamage because it doesn't push in the correct direction.
						FloatToString(fDamage, sTemp, sizeof(sTemp));
						DispatchKeyValue(g_iEntityHurt, "Damage", sTemp);

						if( range_stumble && fDistance <= range_stumble )
						{
							DispatchKeyValue(g_iEntityHurt, "DamageType", "64"); // DMG_BLAST (1<<6) // Witch
						}
						else
						{
							if( index == INDEX_FLAK && g_iConfigDmgType & TARGET_WITCH )
							{
								DispatchKeyValue(g_iEntityHurt, "DamageType", "8");
							} else {
								DispatchKeyValue(g_iEntityHurt, "DamageType", "0");
							}
						}

						DispatchKeyValue(i, "targetname", "silvershot");
						TeleportEntity(g_iEntityHurt, index == INDEX_BLACKHOLE ? vEnd : vPos, NULL_VECTOR, NULL_VECTOR);
						AcceptEntityInput(g_iEntityHurt, "Hurt", client, client);
						DispatchKeyValue(i, "targetname", "");
					}
				}



				// GodMode
				aGodMode.Push(i);
				SetEntProp(i, Prop_Data, "m_takedamage", 0); // Prevent taking damage from env_explosion
			}
		}
	}



	// ==================================================
	// PHYSICS EXPLOSION
	// ==================================================
	if( ignorePhysics == false && targ & (1 << TARGET_PHYSICS) )
	{
		if( g_GrenadeData[index][CONFIG_DMG_PHYSICS] )
		{
			int explo = CreateEntityByName("env_explosion");
			fDamage = damage * g_fConfigPhysics * g_GrenadeData[index][CONFIG_DMG_PHYSICS];
			// FloatToString(fDamage, sTemp, sizeof(sTemp));
			// DispatchKeyValue(explo, "iMagnitude", sTemp);
			// FloatToString(range_damage, sTemp, sizeof(sTemp));
			// DispatchKeyValue(explo, "iRadiusOverride", sTemp);
			DispatchKeyValueFloat(explo, "iMagnitude", fDamage * 2);
			// DispatchKeyValue(explo, "spawnflags", "18301"); // This did not allow physics objects to be pushed or broken, at least when testing in L4D2
			DispatchKeyValue(explo, "spawnflags", "1916");
			SetEntPropEnt(explo, Prop_Send, "m_hOwnerEntity", client);
			TeleportEntity(explo, vPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(explo);
			AcceptEntityInput(explo, "Explode");

			InputKill(explo, 0.3);
		}
	}



	// Reset GodMode
	for( i = 0; i < aGodMode.Length; i++ )
	{
		SetEntProp(aGodMode.Get(i), Prop_Data, "m_takedamage", 2);
	}

	delete aGodMode;
}



// ====================================================================================================
//					STOCKS - GRENADE SPECIFIC EXPLOSION
// ====================================================================================================
bool GrenadeSpecificExplosion(int target, int client, int entity, int index, int type, float fDamage, float fDistance, float vPos[3], float vEnd[3])
{
	// ==================================================
	// BLACKHOLE - Pull into center
	// ==================================================
	if( index -1 == INDEX_BLACKHOLE )
	{
		if( type == TARGET_SURVIVOR )
		{
			if( GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") != -1 ) // Must be on ground
			{
				MakeVectorFromPoints(vEnd, vPos, vEnd);
				NormalizeVector(vEnd, vEnd);
				ScaleVector(vEnd, fDistance);

				if( fDistance < 150 && GetEntProp(target, Prop_Send, "m_fFlags") & FL_ONGROUND == 0 ) // Reduce height when in air near center
					vEnd[2] = 100.0;
				else
					vEnd[2] = 300.0;

				TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vEnd);
			}
		}
		else
		{
			if( type == TARGET_WITCH )
			{
				static float vAng[3];
				MakeVectorFromPoints(vPos, vEnd, vAng);
				NormalizeVector(vAng, vAng);
				vEnd[0] += vAng[0] * 10;
				vEnd[1] += vAng[1] * 10;
				vEnd[2] += vAng[2] * 10;

				PushCommon(client, target, vEnd, false);
			}
		}
	}

	// ==================================================
	// TESLA - Push away
	// ==================================================
	else if( index -1 == INDEX_TESLA )
	{
		// Check duration
		if( GetGameTime() - g_fLastTesla[target] >= g_GrenadeData[INDEX_TESLA][CONFIG_DMG_TICK] )
		{
			g_fLastTesla[entity] = GetGameTime();
			g_fLastTesla[target] = GetGameTime();

			GetEntPropVector(target, Prop_Data, "m_vecOrigin", vEnd);
			vPos[2] += 50.0;
			vEnd[2] += 50.0;
			if( IsVisibleTo(vPos, vEnd) )
			{
				if( type == TARGET_SURVIVOR )
				{
					MakeVectorFromPoints(vPos, vEnd, vEnd);
					NormalizeVector(vEnd, vEnd);
					ScaleVector(vEnd, 400.0);
					vEnd[2] = 300.0;
					TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vEnd);
				}

				TeslaShock(entity, target);
				vPos[2] -= 50.0;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	// ==================================================
	// FLASHBANG - Blind
	// ==================================================
	else if( index -1 == INDEX_FLASHBANG )
	{
		if( type == TARGET_SURVIVOR )
		{
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", vEnd);
			vPos[2] += 50.0;
			vEnd[2] += 50.0;
			if( IsVisibleTo(vPos, vEnd) )
			{
				SDKCall(g_hSDK_DeafenClient, target, 1.0, 0.0, 0.01 );
			}
		}
	}

	// ==================================================
	// VAPORIZER - Dissolve
	// ==================================================
	else if( index -1 == INDEX_VAPORIZER )
	{
		if( GetGameTime() - GetEntPropFloat(target, Prop_Data, "m_flCreateTime") > g_GrenadeData[index - 1][CONFIG_DMG_TICK] )
		{
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", vEnd);
			vEnd[2] += 50.0;
			if( IsVisibleTo(vPos, vEnd) )
			{
				SetEntPropFloat(target, Prop_Data, "m_flCreateTime", GetGameTime());

				// Does not happen here?
				// Prevent error msg: "Entity 157 (class 'pipe_bomb_projectile') reported ENTITY_CHANGE_NONE but 'm_flCreateTime' changed."
				// int offset = FindDataMapInfo(target, "m_flCreateTime");
				// ChangeEdictState(target, offset);

				DissolveCommon(client, entity, target, fDamage);
				return true;
			}
		}

		return false;
	}

	// ==================================================
	// GLOW
	// ==================================================
	else if( index -1 == INDEX_GLOW )
	{
		if( g_GrenadeType[target] == 0 && GetEntProp(target, Prop_Send, "m_glowColorOverride") == 0 ) // Avoid conflict with Mutant Zombies and already glowing.
		{
			if( g_fConfigGlowBonus != 1.0 )
				SDKHook(target, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);

			SetEntProp(target, Prop_Send, "m_nGlowRange", RoundFloat(g_GrenadeData[index - 1][CONFIG_RANGE] * 4));
			SetEntProp(target, Prop_Send, "m_iGlowType", 3); // 2 = Requires line of sight. 3 = Glow through walls.
			SetEntProp(target, Prop_Send, "m_glowColorOverride", GLOW_COLOR);

			CreateTimer(g_GrenadeData[index - 1][CONFIG_TIME], TimerResetGlow, target <= MaxClients ? GetClientUserId(target) : EntIndexToEntRef(target));
		}
	}

	// ==================================================
	// ANTI-GRAVITY - Teleport up
	// ==================================================
	else if( index -1 == INDEX_ANTIGRAVITY )
	{
		if( type == TARGET_SURVIVOR )
		{
			static float vVel[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsVelocity", vVel);
			if( GetEntProp(target, Prop_Send, "m_fFlags") & FL_ONGROUND )
				vVel[2] = 350.0;
			else
				vVel[2] = 100.0;
			TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vVel);

			AcceptEntityInput(client, "DisableLedgeHang");
			SetEntityGravity(target, 0.4);
			CreateTimer(0.1, TimerResetGravity, GetClientUserId(target), TIMER_REPEAT);
		}
	}

	// ==================================================
	// EXTINGUISHER
	// ==================================================
	else if( index -1 == INDEX_EXTINGUISHER )
	{
		if( g_fConfigExtEffect & EXT_FIRES )
		{
			ExtinguishEntity(target);
		}

		if( g_bLeft4DHooks && g_fConfigExtEffect & EXT_VOMIT )
		{
			L4D_OnITExpired(target);
		}

		return false;
	}

	return true;
}

Action TimerResetGravity(Handle timer, int target)
{
	target = GetClientOfUserId(target);
	if( target && IsClientInGame(target) )
	{
		if( GetEntProp(target, Prop_Send, "m_fFlags") & FL_ONGROUND || !IsPlayerAlive(target) )
		{
			AcceptEntityInput(target, "EnableLedgeHang");
			SetEntityGravity(target, 1.0);
		} else {
			return Plugin_Continue;
		}
	}

	return Plugin_Stop;
}

Action TimerResetGlow(Handle timer, int target)
{
	target = ValidTargetRef(target);
	if( target && GetEntProp(target, Prop_Send, "m_glowColorOverride") == GLOW_COLOR )
	{
		SDKUnhook(target, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);
		SetEntProp(target, Prop_Send, "m_nGlowRange", 0);
		SetEntProp(target, Prop_Send, "m_iGlowType", 0);
		SetEntProp(target, Prop_Send, "m_glowColorOverride", 0);
	}

	return Plugin_Continue;
}

Action OnTakeDamageGlow(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if( GetEntProp(victim, Prop_Send, "m_glowColorOverride") != GLOW_COLOR )
	{
		SDKUnhook(victim, SDKHook_OnTakeDamageAlive, OnTakeDamageGlow);
		return Plugin_Continue;
	}

	damage *= g_fConfigGlowBonus;
	return Plugin_Changed;
}

int ValidTargetRef(int target)
{
	if( target < 0 )
	{
		if( (target = EntRefToEntIndex(target)) != INVALID_ENT_REFERENCE )
			return target;
	} else {
		target = GetClientOfUserId(target);
		return target;
	}

	return 0;
}

/*
int GetColor(char[] sTemp)
{
	if( sTemp[0] == 0 )
		return 0;

	char sColors[3][4];
	int color = ExplodeString(sTemp, " ", sColors, sizeof(sColors), sizeof(sColors[]));

	if( color != 3 )
		return 0;

	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);

	return color;
}
// */



// ====================================================================================================
//					STOCKS - SHAKE
// ====================================================================================================
void CreateShake(float intensity, float range, float vPos[3])
{
	if( intensity == 0.0 ) return;

	int entity = CreateEntityByName("env_shake");
	if( entity == -1 )
	{
		LogError("Failed to create 'env_shake'");
		return;
	}

	static char sTemp[8];
	FloatToString(intensity, sTemp, sizeof(sTemp));
	DispatchKeyValue(entity, "amplitude", sTemp);
	DispatchKeyValue(entity, "frequency", "1.5");
	DispatchKeyValue(entity, "duration", "0.9");
	FloatToString(range, sTemp, sizeof(sTemp));
	DispatchKeyValue(entity, "radius", sTemp);
	DispatchKeyValue(entity, "spawnflags", "8");
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Enable");

	AcceptEntityInput(entity, "StartShake");
	RemoveEdict(entity);
}



// ====================================================================================================
//					STOCKS - HEALTH
// ====================================================================================================
float GetTempHealth(int client)
{
	float fGameTime = GetGameTime();
	float fHealthTime = GetEntPropFloat(client, Prop_Send, "m_healthBufferTime");
	float fHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	fHealth -= (fGameTime - fHealthTime) * g_hDecayDecay.FloatValue;
	return fHealth < 0.0 ? 0.0 : fHealth;
}

void SetTempHealth(int client, float fHealth)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", fHealth < 0.0 ? 0.0 : fHealth );
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}



// ====================================================================================================
//					STOCKS - HURT
// ====================================================================================================
void CreateHurtEntity()
{
	if( !g_iEntityHurt || EntRefToEntIndex(g_iEntityHurt) == INVALID_ENT_REFERENCE )
	{
		g_iEntityHurt = CreateEntityByName("point_hurt");
		DispatchKeyValue(g_iEntityHurt, "DamageTarget", "silvershot");
		DispatchSpawn(g_iEntityHurt);
		g_iEntityHurt = EntIndexToEntRef(g_iEntityHurt);
	}
}

void CreateFires(int target, int client, bool gascan)
{
	int entity = CreateEntityByName("prop_physics");
	if( entity != -1 )
	{
		if( gascan )		SetEntityModel(entity, MODEL_GASCAN);
		else				SetEntityModel(entity, MODEL_CRATE);

		// Hide from view (multiple hides still show the gascan for a split second sometimes, but works better than only using 1 of them)
		SDKHook(entity, SDKHook_SetTransmit, OnTransmitExplosive);

		// Hide from view
		int flags = GetEntityFlags(entity);
		SetEntityFlags(entity, flags|FL_EDICT_DONTSEND);

		// Make invisible
		SetEntityRenderMode(entity, RENDER_TRANSALPHAADD);
		SetEntityRenderColor(entity, 0, 0, 0, 0);

		// Prevent collision and movement
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1, 1);
		SetEntityMoveType(entity, MOVETYPE_NONE);

		// Teleport
		static float vPos[3];
		GetEntPropVector(target, Prop_Data, "m_vecOrigin", vPos);
		vPos[2] += 10.0;
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		// Spawn
		DispatchSpawn(entity);

		// Set attacker
		SetEntPropEnt(entity, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(entity, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());

		// Explode
		AcceptEntityInput(entity, "Break");
	}
}

Action OnTransmitExplosive(int entity, int client)
{
	return Plugin_Handled;
}

void InputKill(int entity, float time)
{
	static char temp[40];
	Format(temp, sizeof(temp), "OnUser4 !self:Kill::%f:-1", time);
	SetVariantString(temp);
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser4");
}



// ====================================================================================================
//					STOCKS - TRIGGER
// ====================================================================================================
void TriggerMultipleDamage(int entity, int index, float range, float vPos[3])
{
	int trigger = CreateEntityByName("trigger_multiple");
	DispatchKeyValue(trigger, "spawnflags", "1");
	DispatchKeyValue(trigger, "entireteam", "0");
	DispatchKeyValue(trigger, "allowincap", "1");
	DispatchKeyValue(trigger, "allowghost", "0");
	SetEntityModel(trigger, MODEL_BOUNDING);

	g_GrenadeType[trigger] = index;

	// Box size
	range /= 2;
	static float vMins[3];
	vMins[0] = -range;
	vMins[1] = -range;
	static float vMaxs[3];
	vMaxs[0] = range;
	vMaxs[1] = range;
	vMaxs[2] = 70.0;

	SetEntPropVector(trigger, Prop_Send, "m_vecMins", vMins);
	SetEntPropVector(trigger, Prop_Send, "m_vecMaxs", vMaxs);

	TeleportEntity(trigger, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(trigger);

	SetEntProp(trigger, Prop_Send, "m_nSolidType", 2);

	SetVariantString("!activator");
	AcceptEntityInput(trigger, "SetParent", entity);

	// Collision hooks
	SDKHook(trigger, SDKHook_Touch, OnTouchTriggerMultple);

	// Freezer collision
	if( index - 1 == INDEX_FREEZER && (g_GrenadeTarg[INDEX_FREEZER] & (1 << TARGET_COMMON) || g_GrenadeTarg[INDEX_FREEZER] & (1 << TARGET_WITCH)) ) // Freezer and common only
		SDKHook(trigger, SDKHook_StartTouch, OnTouchTriggerFreezer2);
}

void OnTouchTriggerMultple(int trigger, int target)
{
	// Check duration
	int index = g_GrenadeType[trigger] - 1;

	// Check classname
	static char classname[10];
	GetEdictClassname(target, classname, sizeof(classname));
	if(
		(index == INDEX_SHIELD && strcmp(classname, "player") == 0) ||
		(index != INDEX_SHIELD && (strcmp(classname, "player") == 0 || strcmp(classname, "infected") == 0 || strcmp(classname, "witch") == 0))
	)
	{
		switch( index )
		{
			case INDEX_FREEZER:	OnTouchTriggerFreezer	(target);
			case INDEX_SHIELD:	OnTouchTriggerShield	(target);
		}
	}
}



// ====================================================================================================
//					STOCKS - FX
// ====================================================================================================
int MakeLightDynamic(int target, const float vPos[3])
{
	int entity = CreateEntityByName("light_dynamic");
	if( entity == -1 )
	{
		LogError("Failed to create 'light_dynamic'");
		return 0;
	}

	DispatchKeyValue(entity, "_light", "0 255 0 0");
	DispatchKeyValue(entity, "brightness", "0.1");
	DispatchKeyValueFloat(entity, "spotlight_radius", 32.0);
	DispatchKeyValueFloat(entity, "distance", 600.0);
	DispatchKeyValue(entity, "style", "6");
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "TurnOff");

	// Attach
	if( target )
	{
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target);
	}

	return entity;
}

void MakeEnvSteam(int target, const float vPos[3], const float vAng[3], const char[] sColor)
{
	int entity = CreateEntityByName("env_steam");
	if( entity == -1 )
	{
		LogError("Failed to create 'env_steam'");
		return;
	}

	static char sTemp[16];
	Format(sTemp, sizeof(sTemp), "silv_steam_%d", target);
	DispatchKeyValue(entity, "targetname", sTemp);
	DispatchKeyValue(entity, "SpawnFlags", "1");
	DispatchKeyValue(entity, "rendercolor", sColor);
	DispatchKeyValue(entity, "SpreadSpeed", "10");
	DispatchKeyValue(entity, "Speed", "100");
	DispatchKeyValue(entity, "StartSize", "5");
	DispatchKeyValue(entity, "EndSize", "10");
	DispatchKeyValue(entity, "Rate", "50");
	DispatchKeyValue(entity, "JetLength", "100");
	DispatchKeyValue(entity, "renderamt", "150");
	DispatchKeyValue(entity, "InitialState", "1");
	TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "TurnOn");

	// Attach
	if( target )
	{
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target);
	}

	return;
}

void CreateEnvSprite(int target, const char[] sColor)
{
	int entity = CreateEntityByName("env_sprite");
	if( entity == -1)
	{
		LogError("Failed to create 'env_sprite'");
		return;
	}

	DispatchKeyValue(entity, "rendercolor", sColor);
	DispatchKeyValue(entity, "model", MODEL_SPRITE);
	DispatchKeyValue(entity, "spawnflags", "3");
	DispatchKeyValue(entity, "rendermode", "9");
	DispatchKeyValue(entity, "GlowProxySize", "0.1");
	DispatchKeyValue(entity, "renderamt", "175");
	DispatchKeyValue(entity, "scale", "0.1");
	DispatchSpawn(entity);

	// Attach
	if( target )
	{
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target);
	}
}

void CreateBeamRing(int entity, int iColor[4], float min, float max)
{
	// Grenade Pos
	static float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);

	// Make beam rings
	for( int i = 1; i <= BEAM_RINGS; i++ )
	{
		vPos[2] += 20;
		TE_SetupBeamRingPoint(vPos, min, max, g_BeamSprite, g_HaloSprite, 0, 15, 1.0, 1.0, 2.0, iColor, 20, 0);
		TE_SendToAll();
	}
}



// ====================================================================================================
//					STOCKS - PARTICLES
// ====================================================================================================
int DisplayParticle(int target, const char[] sParticle, const float vPos[3], const float vAng[3], float refire = 0.0)
{
	int entity = CreateEntityByName("info_particle_system");
	if( entity == -1)
	{
		LogError("Failed to create 'info_particle_system'");
		return 0;
	}

	DispatchKeyValue(entity, "effect_name", sParticle);
	TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "start");

	// Refire
	if( refire )
	{
		static char sTemp[48];
		Format(sTemp, sizeof(sTemp), "OnUser1 !self:Stop::%f:-1", refire - 0.05);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "AddOutput");
		Format(sTemp, sizeof(sTemp), "OnUser1 !self:FireUser2::%f:-1", refire);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");

		SetVariantString("OnUser2 !self:Start::0:-1");
		AcceptEntityInput(entity, "AddOutput");
		SetVariantString("OnUser2 !self:FireUser1::0:-1");
		AcceptEntityInput(entity, "AddOutput");
	}

	// Attach
	if( target )
	{
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target);
	}

	return entity;
}

int PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	int index = FindStringIndex(table, sEffectName);
	if( index == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
		index = FindStringIndex(table, sEffectName);
	}

	return index;
}



// ====================================================================================================
//					STOCKS - TRACERAY
// ====================================================================================================
stock bool IsVisibleTo(float position[3], float targetposition[3])
{
	static float vAngles[3], vLookAt[3];
	position[2] += 50.0;

	MakeVectorFromPoints(position, targetposition, vLookAt); // compute vector from start to target
	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace

	// execute Trace
	static Handle trace;
	trace = TR_TraceRayFilterEx(position, vAngles, MASK_ALL, RayType_Infinite, _TraceFilter);

	static bool isVisible;
	isVisible = false;

	if( TR_DidHit(trace) )
	{
		static float vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint

		if( GetVectorDistance(position, vStart) + 25.0 >= GetVectorDistance(position, targetposition) )
			isVisible = true; // if trace ray length plus tolerance equal or bigger absolute distance, you hit the target
	}
	else
		isVisible = false;

	position[2] -= 50.0;
	delete trace;
	return isVisible;
}

bool _TraceFilter(int entity, int contentsMask)
{
	if( !entity || !IsValidEntity(entity) ) // dont let WORLD, or invalid ents be hit
		return false;

	// Don't hit triggers
	static char classname[10];
	GetEdictClassname(entity, classname, sizeof(classname));
	if( strncmp(classname, "trigger_", 8) == 0 ) return false;

	return true;
}

bool SetTeleportEndPoint(int client, float vPos[3])
{
	GetClientEyePosition(client, vPos);
	static float vAng[3];
	GetClientEyeAngles(client, vAng);

	static Handle trace;
	trace = TR_TraceRayFilterEx(vPos, vAng, MASK_SHOT, RayType_Infinite, ExcludeSelf_Filter, client);

	if( TR_DidHit(trace) )
	{
		TR_GetEndPosition(vPos, trace);

		static float vDir[3];
		GetAngleVectors(vAng, vDir, NULL_VECTOR, NULL_VECTOR);
		vPos[0] -= vDir[0] * 10;
		vPos[1] -= vDir[1] * 10;
		vPos[2] -= vDir[2] * 10;
	}
	else
	{
		delete trace;
		return false;
	}

	delete trace;
	return true;
}

bool ExcludeSelf_Filter(int entity, int contentsMask, int client)
{
	if( entity == client )
		return false;
	return true;
}



// ====================================================================================================
//					STOCKS - TEMPENT PARTICLE - By Lux
// ====================================================================================================
/*
*	iParticleIndex = "ParticleString" index location in String table "ParticleEffectNames"
*	iEntIndex = entity index usually used for attachpoints
*	fDelay = delay for TE_SendToAll
*	SendToAll = if send to all false call send to clients your self
*	sParticleName =  particle name only used if iParticleIndex -1 it will find the index for you
*	iAttachmentIndex =  attachpoint index there is no way to get this currently with sm, gotta decompile the model :p
*	ParticleAngles =  angles usually effects particles that have no gravity
*	iFlags = 1 required for attachpoints as well as damage type ^^
*	iDamageType = saw it being used in impact effect dispatch and attachpoints need to be set to use (maybe)
*	fMagnitude = no idea saw being used with pipebomb blast (needs testing)
*	fScale = guess its particle scale but most dont scale (needs testing)
*/
stock bool L4D_TE_Create_Particle(float fParticleStartPos[3]={0.0, 0.0, 0.0},
								float fParticleEndPos[3]={0.0, 0.0, 0.0},
								int iParticleIndex=-1,
								int iEntIndex=0,
								float fDelay=0.0,
								bool SendToAll=true,
								char sParticleName[64]="",
								int iAttachmentIndex=0,
								float fParticleAngles[3]={0.0, 0.0, 0.0},
								int iFlags=0,
								int iDamageType=0,
								float fMagnitude=0.0,
								float fScale=1.0,
								float fRadius=0.0)
{
	TE_Start("EffectDispatch");
	TE_WriteFloat(g_bLeft4Dead2 ? "m_vOrigin.x"	:	"m_vStart[0]",		fParticleStartPos[0]);
	TE_WriteFloat(g_bLeft4Dead2 ? "m_vOrigin.y"	:	"m_vStart[1]",		fParticleStartPos[1]);
	TE_WriteFloat(g_bLeft4Dead2 ? "m_vOrigin.z"	:	"m_vStart[2]",		fParticleStartPos[2]);
	TE_WriteFloat(g_bLeft4Dead2 ? "m_vStart.x"	:	"m_vOrigin[0]",		fParticleEndPos[0]);//end point usually for bulletparticles or ropes
	TE_WriteFloat(g_bLeft4Dead2 ? "m_vStart.y"	:	"m_vOrigin[1]",		fParticleEndPos[1]);
	TE_WriteFloat(g_bLeft4Dead2 ? "m_vStart.z"	:	"m_vOrigin[2]",		fParticleEndPos[2]);

	static int iEffectIndex = INVALID_STRING_INDEX;
	if( iEffectIndex < 0 )
	{
		iEffectIndex = __FindStringIndex2(FindStringTable("EffectDispatch"), "ParticleEffect");
		if( iEffectIndex == INVALID_STRING_INDEX )
			SetFailState("Unable to find EffectDispatch/ParticleEffect indexes");
	}

	TE_WriteNum("m_iEffectName", iEffectIndex);

	if( iParticleIndex < 0 )
	{
		static int iParticleStringIndex = INVALID_STRING_INDEX;
		iParticleStringIndex = __FindStringIndex2(iEffectIndex, sParticleName);
		if( iParticleStringIndex == INVALID_STRING_INDEX )
			return false;

		TE_WriteNum("m_nHitBox", iParticleStringIndex);
	}
	else
		TE_WriteNum("m_nHitBox", iParticleIndex);

	TE_WriteNum("entindex", iEntIndex);
	TE_WriteNum("m_nAttachmentIndex", iAttachmentIndex);

	TE_WriteVector("m_vAngles", fParticleAngles);

	TE_WriteNum("m_fFlags", iFlags);
	TE_WriteFloat("m_flMagnitude", fMagnitude);// saw this being used in pipebomb needs testing what it does probs shaking screen?
	TE_WriteFloat("m_flScale", fScale);
	TE_WriteFloat("m_flRadius", fRadius);// saw this being used in pipebomb needs testing what it does probs shaking screen?
	TE_WriteNum("m_nDamageType", iDamageType);// this shit is required dunno why for attachpoint emitting valve probs named it wrong

	if( SendToAll )
	{
		TE_SendToAll(fDelay);
		// TE_SendToAllInRange(fParticleStartPos, RangeType_Visibility, GetTickInterval());
	}

	return true;
}

// Credit smlib https://github.com/bcserv/smlib
/*
 * Rewrite of FindStringIndex, because in my tests
 * FindStringIndex failed to work correctly.
 * Searches for the index of a given string in a string table.
 *
 * @param tableidx		A string table index.
 * @param str			String to find.
 * @return				String index if found, INVALID_STRING_INDEX otherwise.
 */
stock int __FindStringIndex2(int tableidx, const char[] str)
{
	static char buf[1024];

	int numStrings = GetStringTableNumStrings(tableidx);
	for( int i=0; i < numStrings; i++ )
	{
		ReadStringTable(tableidx, i, buf, sizeof(buf));

		if( strcmp(buf, str) == 0 )
		{
			return i;
		}
	}

	return INVALID_STRING_INDEX;
}