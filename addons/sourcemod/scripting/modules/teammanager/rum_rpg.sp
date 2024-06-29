 /**
 * =============================================================================
 * Ready Up - RPG By Michael toth
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */
#define NICK_MODEL				"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL			"models/survivors/survivor_producer.mdl"
#define COACH_MODEL				"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL				"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL				"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL			"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL				"models/survivors/survivor_manager.mdl"
#define BILL_MODEL				"models/survivors/survivor_namvet.mdl"
#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3
#define MAX_ENTITIES		2048
#define MAX_CHAT_LENGTH		1024
#define COOPRECORD_DB				"db_season_coop"
#define SURVRECORD_DB				"db_season_surv"
#define PLUGIN_VERSION				"v1.98.4"
#define CLASS_VERSION				"v1.0"
#define PROFILE_VERSION				"v1.3"
#define LOOT_VERSION				"v0.0"
#define PLUGIN_CONTACT				"Skye!"
#define PLUGIN_NAME					"RPG Construction Set"
#define PLUGIN_DESCRIPTION			"Fully-customizable and modular RPG, like the one for Atari."
#define CONFIG_EVENTS				"rpg/events.cfg"
#define CONFIG_MAINMENU				"rpg/mainmenu.cfg"
#define CONFIG_MENUTALENTS			"rpg/talentmenu.cfg"
#define CONFIG_POINTS				"rpg/points.cfg"
#define CONFIG_MAPRECORDS			"rpg/maprecords.cfg"
#define CONFIG_STORE				"rpg/store.cfg"
#define CONFIG_TRAILS				"rpg/trails.cfg"
#define CONFIG_PETS					"rpg/pets.cfg"
#define CONFIG_WEAPONS				"rpg/weapondamages.cfg"
#define CONFIG_COMMONAFFIXES		"rpg/commonaffixes.cfg"
#define CONFIG_CLASSNAMES			"rpg/classnames.cfg"
#define LOGFILE						"rum_rpg.txt"
#define JETPACK_AUDIO				"ambient/gas/steam2.wav"
//	================================
#define DEBUG     					false
//	================================
#define CVAR_SHOW					FCVAR_NOTIFY | FCVAR_PLUGIN
#define DMG_HEADSHOT				2147483648
#define ZOMBIECLASS_SMOKER											1
#define ZOMBIECLASS_BOOMER											2
#define ZOMBIECLASS_HUNTER											3
#define ZOMBIECLASS_SPITTER											4
#define ZOMBIECLASS_JOCKEY											5
#define ZOMBIECLASS_CHARGER											6
#define ZOMBIECLASS_WITCH											7
#define ZOMBIECLASS_TANK											8
#define ZOMBIECLASS_SURVIVOR										0
#define TANKSTATE_TIRED												0
#define TANKSTATE_REFLECT											1
#define TANKSTATE_FIRE												2
#define TANKSTATE_DEATH												3
#define TANKSTATE_TELEPORT											4
#define TANKSTATE_HULK												5
#define EFFECTOVERTIME_ACTIVATETALENT	0
#define EFFECTOVERTIME_GETACTIVETIME	1
#define EFFECTOVERTIME_GETCOOLDOWN		2
#define DMG_SPITTERACID1 263168
#define DMG_SPITTERACID2 265216
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <l4d2_direct>
#include "wrap.inc"
#include "left4downtown.inc"
#include "l4d_stocks.inc"
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN
public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_CONTACT,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "",
};
// from n^3 to n^2
// for the talentmenu.cfg
#define ABILITY_TYPE						0
#define COMPOUNDING_TALENT					1
#define COMPOUND_WITH						2
#define ACTIVATOR_ABILITY_EFFECTS			3
#define TARGET_ABILITY_EFFECTS				4
#define SECONDARY_EFFECTS					5
#define WEAPONS_PERMITTED					6
#define HEALTH_PERCENTAGE_REQ				7
#define COHERENCY_RANGE						8
#define COHERENCY_MAX						9
#define COHERENCY_REQ						10
#define HEALTH_PERCENTAGE_REQ_TAR_REMAINING	11
#define HEALTH_PERCENTAGE_REQ_TAR_MISSING	12
#define ACTIVATOR_TEAM_REQ					13
#define ACTIVATOR_CLASS_REQ					14
#define REQUIRES_ZOOM						15
#define COMBAT_STATE_REQ					16
#define PLAYER_STATE_REQ					17
#define PASSIVE_ABILITY						18
#define REQUIRES_HEADSHOT					19
#define REQUIRES_LIMBSHOT					20
#define REQUIRES_CROUCHING					21
#define ACTIVATOR_STAGGER_REQ				22
#define TARGET_STAGGER_REQ					23
#define CANNOT_TARGET_SELF					24
#define MUST_BE_JUMPING_OR_FLYING			25
#define VOMIT_STATE_REQ_ACTIVATOR			26
#define VOMIT_STATE_REQ_TARGET				27
#define REQ_ADRENALINE_EFFECT				28
#define DISABLE_IF_WEAKNESS					29
#define REQ_WEAKNESS						30
#define TARGET_CLASS_REQ					31
#define CLEANSE_TRIGGER						32
#define REQ_CONSECUTIVE_HITS				33
#define BACKGROUND_TALENT					34
#define STATUS_EFFECT_MULTIPLIER			35
#define MULTIPLY_RANGE						36
#define MULTIPLY_COMMONS					37
#define MULTIPLY_SUPERS						38
#define MULTIPLY_WITCHES					39
#define MULTIPLY_SURVIVORS					40
#define MULTIPLY_SPECIALS					41
#define STRENGTH_INCREASE_ZOOMED			42
#define STRENGTH_INCREASE_TIME_CAP			43
#define STRENGTH_INCREASE_TIME_REQ			44
#define ZOOM_TIME_HAS_MINIMUM_REQ			45
#define HOLDING_FIRE_STRENGTH_INCREASE		46
#define DAMAGE_TIME_HAS_MINIMUM_REQ			47
#define HEALTH_PERCENTAGE_REQ_MISSING		48
#define HEALTH_PERCENTAGE_REQ_MISSING_MAX	49
#define IS_OWN_TALENT						50
#define SECONDARY_ABILITY_TRIGGER			51
#define TARGET_IS_SELF						52
#define PRIMARY_AOE							53
#define SECONDARY_AOE						54
#define GET_TALENT_NAME						55
#define GET_TRANSLATION						56
#define GOVERNING_ATTRIBUTE					57
#define TALENT_TREE_CATEGORY				58
#define PART_OF_MENU_NAMED					59
#define GET_TALENT_LAYER					60
#define IS_TALENT_ABILITY					61
#define ACTION_BAR_NAME						62
#define NUM_TALENTS_REQ						63
#define TALENT_UPGRADE_STRENGTH_VALUE		64
#define TALENT_UPGRADE_SCALE				65
#define TALENT_COOLDOWN_STRENGTH_VALUE		66
#define TALENT_COOLDOWN_SCALE				67
#define TALENT_ACTIVE_STRENGTH_VALUE		68
#define TALENT_ACTIVE_SCALE					69
#define COOLDOWN_GOVERNOR_OF_TALENT			70
#define TALENT_STRENGTH_HARD_LIMIT			71
#define TALENT_IS_EFFECT_OVER_TIME			72
#define SPECIAL_AMMO_TALENT_STRENGTH		73
#define LAYER_COUNTING_IS_IGNORED			74
#define IS_ATTRIBUTE						75
#define HIDE_TRANSLATION					76
#define TALENT_ROLL_CHANCE					77
// spells
#define SPELL_INTERVAL_PER_POINT			78
#define SPELL_INTERVAL_FIRST_POINT			79
#define SPELL_RANGE_PER_POINT				80
#define SPELL_RANGE_FIRST_POINT				81
#define SPELL_STAMINA_PER_POINT				82
#define SPELL_BASE_STAMINA_REQ				83
#define SPELL_COOLDOWN_PER_POINT			84
#define SPELL_COOLDOWN_FIRST_POINT			85
#define SPELL_COOLDOWN_START				86
#define SPELL_ACTIVE_TIME_PER_POINT			87
#define SPELL_ACTIVE_TIME_FIRST_POINT		88
#define SPELL_AMMO_EFFECT					89
#define SPELL_EFFECT_MULTIPLIER				90
// abilities
#define ABILITY_ACTIVE_EFFECT				91
#define ABILITY_PASSIVE_EFFECT				92
#define ABILITY_COOLDOWN_EFFECT				93
#define ABILITY_IS_REACTIVE					94
#define ABILITY_TEAMS_ALLOWED				95
#define ABILITY_COOLDOWN_STRENGTH			96
#define ABILITY_MAXIMUM_PASSIVE_MULTIPLIER	97
#define ABILITY_MAXIMUM_ACTIVE_MULTIPLIER	98
#define ABILITY_ACTIVE_STATE_ENSNARE_REQ	99
#define ABILITY_ACTIVE_STRENGTH				100
#define ABILITY_PASSIVE_IGNORES_COOLDOWN	101
#define ABILITY_PASSIVE_STATE_ENSNARE_REQ	102
#define ABILITY_PASSIVE_STRENGTH			103
#define ABILITY_PASSIVE_ONLY				104
#define ABILITY_IS_SINGLE_TARGET			105
#define ABILITY_DRAW_DELAY					106
#define ABILITY_ACTIVE_DRAW_DELAY			107
#define ABILITY_PASSIVE_DRAW_DELAY			108
#define ATTRIBUTE_MULTIPLIER				109
#define ATTRIBUTE_USE_THESE_MULTIPLIERS		110
#define ATTRIBUTE_BASE_MULTIPLIER			111
#define ATTRIBUTE_DIMINISHING_MULTIPLIER	112
#define ATTRIBUTE_DIMINISHING_RETURNS		113
#define HUD_TEXT_BUFF_EFFECT_OVER_TIME		114
#define IS_SUB_MENU_OF_TALENTCONFIG			115
#define IS_TALENT_TYPE						116
#define ITEM_ITEM_ID						117
#define ITEM_RARITY							118
#define OLD_ATTRIBUTE_EXPERIENCE_START		119
#define OLD_ATTRIBUTE_EXPERIENCE_MULTIPLIER	120
#define IS_AURA_INSTEAD						121
#define EFFECT_COOLDOWN_TRIGGER				122
#define EFFECT_INACTIVE_TRIGGER				123
#define ABILITY_REACTIVE_TYPE				124
#define ABILITY_ACTIVE_TIME					125
#define ABILITY_REQ_NO_ENSNARE				126
#define ABILITY_SKY_LEVEL_REQ				127
#define ABILITY_TOGGLE_EFFECT				128
#define SPELL_HUMANOID_ONLY					129
#define SPELL_INANIMATE_ONLY				130
#define SPELL_ALLOW_COMMONS					131
#define SPELL_ALLOW_SPECIALS				132
#define SPELL_ALLOW_SURVIVORS				133
#define ABILITY_COOLDOWN					134
#define EFFECT_ACTIVATE_PER_TICK			135
#define EFFECT_SECONDARY_EPT_ONLY			136
#define ABILITY_ACTIVE_END_ABILITY_TRIGGER	137
#define ABILITY_COOLDOWN_END_TRIGGER		138
#define ABILITY_DOES_DAMAGE					139
#define TALENT_IS_SPELL						140
#define TALENT_MINIMUM_LEVEL_REQ			141
#define ABILITY_TOGGLE_STRENGTH				142
#define TARGET_AND_LAST_TARGET_CLASS_MATCH	143
#define TARGET_RANGE_REQUIRED				144
#define TARGET_RANGE_REQUIRED_OUTSIDE		145
#define TARGET_MUST_BE_LAST_TARGET			146
#define ACTIVATOR_MUST_BE_ON_FIRE			147
#define ACTIVATOR_MUST_SUFFER_ACID_BURN		148
#define ACTIVATOR_MUST_BE_EXPLODING			149
#define ACTIVATOR_MUST_BE_SLOW				150
#define ACTIVATOR_MUST_BE_FROZEN			151
#define ACTIVATOR_MUST_BE_SCORCHED			152
#define ACTIVATOR_MUST_BE_STEAMING			153
#define ACTIVATOR_MUST_BE_DROWNING			154
#define ACTIVATOR_MUST_HAVE_HIGH_GROUND		155
#define TARGET_MUST_HAVE_HIGH_GROUND		156
#define ACTIVATOR_TARGET_MUST_EVEN_GROUND	157
#define TARGET_MUST_BE_IN_THE_AIR			158
#define ABILITY_EVENT_TYPE					159
#define LAST_KILL_MUST_BE_HEADSHOT			160
// because this value changes when we increase the static list of key positions
// we should create a reference for the IsAbilityFound method, so that it doesn't waste time checking keys that we know aren't equal.
#define TALENT_FIRST_RANDOM_KEY_POSITION	161
// for super commons.
#define SUPER_COMMON_MAX_ALLOWED			0
#define SUPER_COMMON_AURA_EFFECT			1
#define SUPER_COMMON_RANGE_MIN				2
#define SUPER_COMMON_RANGE_PLAYER_LEVEL		3
#define SUPER_COMMON_RANGE_MAX				4
#define SUPER_COMMON_COOLDOWN				5
#define SUPER_COMMON_AURA_STRENGTH			6
#define SUPER_COMMON_STRENGTH_TARGET		7
#define SUPER_COMMON_LEVEL_STRENGTH			8
#define SUPER_COMMON_SPAWN_CHANCE			9
#define SUPER_COMMON_DRAW_TYPE				10
#define SUPER_COMMON_FIRE_IMMUNITY			11
#define SUPER_COMMON_MODEL_SIZE				12
#define SUPER_COMMON_GLOW					13
#define SUPER_COMMON_GLOW_RANGE				14
#define SUPER_COMMON_GLOW_COLOUR			15
#define SUPER_COMMON_BASE_HEALTH			16
#define SUPER_COMMON_HEALTH_PER_LEVEL		17
#define SUPER_COMMON_NAME					18
#define SUPER_COMMON_CHAIN_REACTION			19
#define SUPER_COMMON_DEATH_EFFECT			20
#define SUPER_COMMON_DEATH_BASE_TIME		21
#define SUPER_COMMON_DEATH_MAX_TIME			22
#define SUPER_COMMON_DEATH_INTERVAL			23
#define SUPER_COMMON_DEATH_MULTIPLIER		24
#define SUPER_COMMON_LEVEL_REQ				25
#define SUPER_COMMON_FORCE_MODEL			26
#define SUPER_COMMON_DAMAGE_EFFECT			27
#define SUPER_COMMON_ENEMY_MULTIPLICATION	28
#define SUPER_COMMON_ONFIRE_BASE_TIME		29
#define SUPER_COMMON_ONFIRE_LEVEL			30
#define SUPER_COMMON_ONFIRE_MAX_TIME		31
#define SUPER_COMMON_ONFIRE_INTERVAL		32
#define SUPER_COMMON_STRENGTH_SPECIAL		33
#define SUPER_COMMON_RAW_STRENGTH			34
#define SUPER_COMMON_RAW_COMMON_STRENGTH	35
#define SUPER_COMMON_RAW_PLAYER_STRENGTH	36
#define SUPER_COMMON_REQ_BILED_SURVIVORS	37
#define SUPER_COMMON_FIRST_RANDOM_KEY_POS	38

// for the events.cfg
#define EVENT_PERPETRATOR					0
#define EVENT_VICTIM						1
#define EVENT_SAMETEAM_TRIGGER				2
#define EVENT_PERPETRATOR_TEAM_REQ			3
#define EVENT_PERPETRATOR_ABILITY_TRIGGER	4
#define EVENT_VICTIM_TEAM_REQ				5
#define EVENT_VICTIM_ABILITY_TRIGGER		6
#define EVENT_DAMAGE_TYPE					7
#define EVENT_GET_HEALTH					8
#define EVENT_DAMAGE_AWARD					9
#define EVENT_GET_ABILITIES					10
#define EVENT_IS_PLAYER_NOW_IT				11
#define EVENT_IS_ORIGIN						12
#define EVENT_IS_DISTANCE					13
#define EVENT_MULTIPLIER_POINTS				14
#define EVENT_MULTIPLIER_EXPERIENCE			15
#define EVENT_IS_SHOVED						16
#define EVENT_IS_BULLET_IMPACT				17
#define EVENT_ENTERED_SAFEROOM				18
new iSurvivorBotsAreImmuneToFireDamage;
new showNumLivingSurvivorsInHostname;
new iHideEnrageTimerUntilSecondsLeft;
new Float:fTeleportTankHeightDistance;
new String:playerChatClassName[MAXPLAYERS+1][64];
new bool:bWeaknessAssigned[MAXPLAYERS + 1];
new String:LastTargetClass[MAXPLAYERS + 1][10];
new iHealingPlayerInCombatPutInCombat;
new Handle:TimeOfEffectOverTime;
new Handle:EffectOverTime;
new Handle:currentEquippedWeapon[MAXPLAYERS + 1];	// bullets fired from current weapon; variable needs to be renamed.
new Handle:GetCategoryStrengthKeys[MAXPLAYERS + 1];
new Handle:GetCategoryStrengthValues[MAXPLAYERS + 1];
new Handle:GetCategoryStrengthSection[MAXPLAYERS + 1];
new bool:bIsDebugEnabled = false;
new pistolXP[MAXPLAYERS + 1];
new meleeXP[MAXPLAYERS + 1];
new uziXP[MAXPLAYERS + 1];
new shotgunXP[MAXPLAYERS + 1];
new sniperXP[MAXPLAYERS + 1];
new assaultXP[MAXPLAYERS + 1];
new medicXP[MAXPLAYERS + 1];
new grenadeXP[MAXPLAYERS + 1];
new Float:fProficiencyExperienceMultiplier;
new Float:fProficiencyExperienceEarned;
//new iProficiencyMaxLevel;
new iProficiencyStart;
new iMaxIncap;
new Handle:hExecuteConfig = INVALID_HANDLE;
new iTanksPreset;
new ProgressEntity[MAXPLAYERS + 1];
//new Float:fScoutBonus;
//new Float:fTotemRating;
new iSurvivorRespawnRestrict;
new bool:bIsDefenderTank[MAXPLAYERS + 1];
new Float:fOnFireDebuffDelay;
new Float:fOnFireDebuff[MAXPLAYERS + 1];
//new iOnFireDebuffLimit;
new iSkyLevelMax;
new SkyLevel[MAXPLAYERS + 1];
new iIsSpecialFire;
new iIsRatingEnabled;
new Handle:hThreatSort;
new bool:bIsHideThreat[MAXPLAYERS + 1];
//new Float:fTankThreatBonus;
new iTopThreat;
new iThreatLevel[MAXPLAYERS + 1];
new iThreatLevel_temp[MAXPLAYERS + 1];
new Handle:hThreatMeter;
new forceProfileOnNewPlayers;
new bool:bEquipSpells[MAXPLAYERS + 1];
new Handle:LoadoutConfigKeys[MAXPLAYERS + 1];
new Handle:LoadoutConfigValues[MAXPLAYERS + 1];
new Handle:LoadoutConfigSection[MAXPLAYERS + 1];
new bool:bIsGiveProfileItems[MAXPLAYERS + 1];
new String:sProfileLoadoutConfig[64];
new iIsWeaponLoadout[MAXPLAYERS + 1];
new iAwardBroadcast;
new iSurvivalCounter;
new iRestedDonator;
new iRestedRegular;
new iRestedSecondsRequired;
new iRestedMaximum;
new iFriendlyFire;
new String:sDonatorFlags[10];
new Float:fDeathPenalty;
new iHardcoreMode;
new iDeathPenaltyPlayers;
new Handle:RoundStatistics;
new bool:bRushingNotified[MAXPLAYERS + 1];
new bool:bHasTeleported[MAXPLAYERS + 1];
new bool:IsAirborne[MAXPLAYERS + 1];
new Handle:RandomSurvivorClient;
new eBackpack[MAXPLAYERS + 1];
new bool:b_IsFinaleTanks;
new String:RatingType[64];
new bool:bJumpTime[MAXPLAYERS + 1];
new Float:JumpTime[MAXPLAYERS + 1];
new Handle:AbilityConfigKeys[MAXPLAYERS + 1];
new Handle:AbilityConfigValues[MAXPLAYERS + 1];
new Handle:AbilityConfigSection[MAXPLAYERS + 1];
new bool:IsGroupMember[MAXPLAYERS + 1];
new IsGroupMemberTime[MAXPLAYERS + 1];
new Handle:GetAbilityKeys[MAXPLAYERS + 1];
new Handle:GetAbilityValues[MAXPLAYERS + 1];
new Handle:GetAbilitySection[MAXPLAYERS + 1];
new Handle:IsAbilityKeys[MAXPLAYERS + 1];
new Handle:IsAbilityValues[MAXPLAYERS + 1];
new Handle:IsAbilitySection[MAXPLAYERS + 1];
new Handle:CheckAbilityKeys[MAXPLAYERS + 1];
new Handle:CheckAbilityValues[MAXPLAYERS + 1];
new Handle:CheckAbilitySection[MAXPLAYERS + 1];
new StrugglePower[MAXPLAYERS + 1];
new Handle:GetTalentStrengthKeys[MAXPLAYERS + 1];
new Handle:GetTalentStrengthValues[MAXPLAYERS + 1];
new Handle:CastKeys[MAXPLAYERS + 1];
new Handle:CastValues[MAXPLAYERS + 1];
new Handle:CastSection[MAXPLAYERS + 1];
new ActionBarSlot[MAXPLAYERS + 1];
new Handle:ActionBar[MAXPLAYERS + 1];
new bool:DisplayActionBar[MAXPLAYERS + 1];
new ConsecutiveHits[MAXPLAYERS + 1];
new MyVomitChase[MAXPLAYERS + 1];
new Float:JetpackRecoveryTime[MAXPLAYERS + 1];
new bool:b_IsHooked[MAXPLAYERS + 1];
new IsPvP[MAXPLAYERS + 1];
new bool:bJetpack[MAXPLAYERS + 1];
//new ServerLevelRequirement;
new Handle:TalentsAssignedKeys[MAXPLAYERS + 1];
new Handle:TalentsAssignedValues[MAXPLAYERS + 1];
new Handle:CartelValueKeys[MAXPLAYERS + 1];
new Handle:CartelValueValues[MAXPLAYERS + 1];
new ReadyUpGameMode;
new bool:b_IsLoaded[MAXPLAYERS + 1];
new bool:LoadDelay[MAXPLAYERS + 1];
new LoadTarget[MAXPLAYERS + 1];
new String:CompanionNameQueue[MAXPLAYERS + 1][64];
new bool:HealImmunity[MAXPLAYERS + 1];
new String:Hostname[64];
new String:ProfileLoadQueue[MAXPLAYERS + 1][64];
new bool:bIsSettingsCheck;
new Handle:SuperCommonQueue;
new bool:bIsCrushCooldown[MAXPLAYERS + 1];
new bool:bIsBurnCooldown[MAXPLAYERS + 1];
new bool:ISBILED[MAXPLAYERS + 1];
new Rating[MAXPLAYERS + 1];
new Float:RoundExperienceMultiplier[MAXPLAYERS + 1];
new BonusContainer[MAXPLAYERS + 1];
new CurrentMapPosition;
new DoomTimer;
new CleanseStack[MAXPLAYERS + 1];
new Float:CounterStack[MAXPLAYERS + 1];
new MultiplierStack[MAXPLAYERS + 1];
new String:BuildingStack[MAXPLAYERS + 1];
new Handle:TempAttributes[MAXPLAYERS + 1];
new Handle:TempTalents[MAXPLAYERS + 1];
new Handle:PlayerProfiles[MAXPLAYERS + 1];
new String:LoadoutName[MAXPLAYERS + 1][64];
new bool:b_IsSurvivalIntermission;
new Float:ISDAZED[MAXPLAYERS + 1];
//new Float:ExplodeTankTimer[MAXPLAYERS + 1];
new TankState[MAXPLAYERS + 1];
//new LastAttacker[MAXPLAYERS + 1];
new bool:b_IsFloating[MAXPLAYERS + 1];
//new Float:JumpPosition[MAXPLAYERS + 1][2][3];
new Float:LastDeathTime[MAXPLAYERS + 1];
new Float:SurvivorEnrage[MAXPLAYERS + 1][2];
new bool:bHasWeakness[MAXPLAYERS + 1];
new HexingContribution[MAXPLAYERS + 1];
new BuffingContribution[MAXPLAYERS + 1];
new HealingContribution[MAXPLAYERS + 1];
new TankingContribution[MAXPLAYERS + 1];
new CleansingContribution[MAXPLAYERS + 1];
new Float:PointsContribution[MAXPLAYERS + 1];
new DamageContribution[MAXPLAYERS + 1];
new Float:ExplosionCounter[MAXPLAYERS + 1][2];
new Handle:CoveredInVomit;
new bool:AmmoTriggerCooldown[MAXPLAYERS + 1];
new Handle:SpecialAmmoEffectKeys[MAXPLAYERS + 1];
new Handle:SpecialAmmoEffectValues[MAXPLAYERS + 1];
new Handle:ActiveAmmoCooldownKeys[MAXPLAYERS +1];
new Handle:ActiveAmmoCooldownValues[MAXPLAYERS + 1];
new Handle:PlayActiveAbilities[MAXPLAYERS + 1];
new Handle:PlayerActiveAmmo[MAXPLAYERS + 1];
new Handle:SpecialAmmoKeys[MAXPLAYERS + 1];
new Handle:SpecialAmmoValues[MAXPLAYERS + 1];
new Handle:SpecialAmmoSection[MAXPLAYERS + 1];
new Handle:DrawSpecialAmmoKeys[MAXPLAYERS + 1];
new Handle:DrawSpecialAmmoValues[MAXPLAYERS + 1];
new Handle:SpecialAmmoStrengthKeys[MAXPLAYERS + 1];
new Handle:SpecialAmmoStrengthValues[MAXPLAYERS + 1];
new Handle:WeaponLevel[MAXPLAYERS + 1];
new Handle:ExperienceBank[MAXPLAYERS + 1];
new Handle:MenuPosition[MAXPLAYERS + 1];
new Handle:IsClientInRangeSAKeys[MAXPLAYERS + 1];
new Handle:IsClientInRangeSAValues[MAXPLAYERS + 1];
new Handle:SpecialAmmoData;
new Handle:SpecialAmmoSave;
new Float:MovementSpeed[MAXPLAYERS + 1];
new IsPlayerDebugMode[MAXPLAYERS + 1];
new String:ActiveSpecialAmmo[MAXPLAYERS + 1][64];
new Float:IsSpecialAmmoEnabled[MAXPLAYERS + 1][4];
new bool:bIsInCombat[MAXPLAYERS + 1];
new Float:CombatTime[MAXPLAYERS + 1];
new Handle:AKKeys[MAXPLAYERS + 1];
new Handle:AKValues[MAXPLAYERS + 1];
new Handle:AKSection[MAXPLAYERS + 1];
new bool:bIsSurvivorFatigue[MAXPLAYERS + 1];
new SurvivorStamina[MAXPLAYERS + 1];
new Float:SurvivorConsumptionTime[MAXPLAYERS + 1];
new Float:SurvivorStaminaTime[MAXPLAYERS + 1];
new Handle:ISSLOW[MAXPLAYERS + 1];
new Float:fSlowSpeed[MAXPLAYERS + 1];
new Handle:ISFROZEN[MAXPLAYERS + 1];
new Float:ISEXPLODETIME[MAXPLAYERS + 1];
new Handle:ISEXPLODE[MAXPLAYERS + 1];
new Handle:ISBLIND[MAXPLAYERS + 1];
new Handle:EntityOnFire;
new Handle:EntityOnFireName;
new Handle:CommonInfected;
new Handle:RCAffixes[MAXPLAYERS + 1];
new Handle:h_CommonKeys;
new Handle:h_CommonValues;
new Handle:SearchKey_Section;
new Handle:h_CAKeys;
new Handle:h_CAValues;
new Handle:CommonList;
new Handle:CommonAffixes;			// the array holding the common entity id and the affix associated with the common infected. If multiple affixes, multiple keyvalues for the entity id will be created instead of multiple entries.
new Handle:a_CommonAffixes;			// the array holding the config data
new UpgradesAwarded[MAXPLAYERS + 1];
new UpgradesAvailable[MAXPLAYERS + 1];
new Handle:InfectedAuraKeys[MAXPLAYERS + 1];
new Handle:InfectedAuraValues[MAXPLAYERS + 1];
new Handle:InfectedAuraSection[MAXPLAYERS + 1];
new bool:b_IsDead[MAXPLAYERS + 1];
new ExperienceDebt[MAXPLAYERS + 1];
new Handle:TalentUpgradeKeys[MAXPLAYERS + 1];
new Handle:TalentUpgradeValues[MAXPLAYERS + 1];
new Handle:TalentUpgradeSection[MAXPLAYERS + 1];
new Handle:InfectedHealth[MAXPLAYERS + 1];
new Handle:SpecialCommon[MAXPLAYERS + 1];
new Handle:WitchList;
new Handle:WitchDamage[MAXPLAYERS + 1];
new Handle:Give_Store_Keys;
new Handle:Give_Store_Values;
new Handle:Give_Store_Section;
new bool:bIsMeleeCooldown[MAXPLAYERS + 1];
new Handle:a_Classnames;
new Handle:a_WeaponDamages;
new Handle:MeleeKeys[MAXPLAYERS + 1];
new Handle:MeleeValues[MAXPLAYERS + 1];
new Handle:MeleeSection[MAXPLAYERS + 1];
new String:Public_LastChatUser[64];
new String:Infected_LastChatUser[64];
new String:Survivor_LastChatUser[64];
new String:Spectator_LastChatUser[64];
new String:currentCampaignName[64];
new Handle:h_KilledPosition_X[MAXPLAYERS + 1];
new Handle:h_KilledPosition_Y[MAXPLAYERS + 1];
new Handle:h_KilledPosition_Z[MAXPLAYERS + 1];
new bool:bIsEligibleMapAward[MAXPLAYERS + 1];
new bool:b_ConfigsExecuted;
new bool:b_FirstLoad;
new bool:b_MapStart;
new bool:b_HardcoreMode[MAXPLAYERS + 1];
new PreviousRoundIncaps[MAXPLAYERS + 1];
new RoundIncaps[MAXPLAYERS + 1];
new String:CONFIG_MAIN[64];
new bool:b_IsCampaignComplete;
new bool:b_IsRoundIsOver;
new RatingHandicap[MAXPLAYERS + 1];
new bool:bIsHandicapLocked[MAXPLAYERS + 1];
new bool:b_IsCheckpointDoorStartOpened;
new resr[MAXPLAYERS + 1];
new LastPlayLength[MAXPLAYERS + 1];
new RestedExperience[MAXPLAYERS + 1];
new MapRoundsPlayed;
new String:LastSpoken[MAXPLAYERS + 1][512];
new Handle:RPGMenuPosition[MAXPLAYERS + 1];
new bool:b_IsInSaferoom[MAXPLAYERS + 1];
new Handle:hDatabase												=	INVALID_HANDLE;
new String:ConfigPathDirectory[64];
new String:LogPathDirectory[64];
new String:PurchaseTalentName[MAXPLAYERS + 1][64];
new PurchaseTalentPoints[MAXPLAYERS + 1];
new Handle:a_Trails;
new Handle:TrailsKeys[MAXPLAYERS + 1];
new Handle:TrailsValues[MAXPLAYERS + 1];
new bool:b_IsFinaleActive;
new RoundDamage[MAXPLAYERS + 1];
new RoundDamageTotal;
new SpecialsKilled;
new Handle:LockedTalentKeys;
new Handle:LockedTalentValues;
new Handle:LockedTalentSection;
new Handle:MOTKeys[MAXPLAYERS + 1];
new Handle:MOTValues[MAXPLAYERS + 1];
new Handle:MOTSection[MAXPLAYERS + 1];
new Handle:DamageKeys[MAXPLAYERS + 1];
new Handle:DamageValues[MAXPLAYERS + 1];
new Handle:DamageSection[MAXPLAYERS + 1];
new Handle:BoosterKeys[MAXPLAYERS + 1];
new Handle:BoosterValues[MAXPLAYERS + 1];
new Handle:StoreChanceKeys[MAXPLAYERS + 1];
new Handle:StoreChanceValues[MAXPLAYERS + 1];
new Handle:StoreItemNameSection[MAXPLAYERS + 1];
new Handle:StoreItemSection[MAXPLAYERS + 1];
new String:PathSetting[64];
new Handle:SaveSection[MAXPLAYERS + 1];
new OriginalHealth[MAXPLAYERS + 1];
new bool:b_IsLoadingStore[MAXPLAYERS + 1];
new Handle:LoadStoreSection[MAXPLAYERS + 1];
new FreeUpgrades[MAXPLAYERS + 1];
new Handle:StoreTimeKeys[MAXPLAYERS + 1];
new Handle:StoreTimeValues[MAXPLAYERS + 1];
new Handle:StoreKeys[MAXPLAYERS + 1];
new Handle:StoreValues[MAXPLAYERS + 1];
new Handle:StoreMultiplierKeys[MAXPLAYERS + 1];
new Handle:StoreMultiplierValues[MAXPLAYERS + 1];
new Handle:a_Store_Player[MAXPLAYERS + 1];
new bool:b_IsLoadingTrees[MAXPLAYERS + 1];
new bool:b_IsArraysCreated[MAXPLAYERS + 1];
new Handle:a_Store;
new PlayerUpgradesTotal[MAXPLAYERS + 1];
new Float:f_TankCooldown;
new Float:DeathLocation[MAXPLAYERS + 1][3];
new TimePlayed[MAXPLAYERS + 1];
new bool:b_IsLoading[MAXPLAYERS + 1];
new LastLivingSurvivor;
new Float:f_OriginStart[MAXPLAYERS + 1][3];
new Float:f_OriginEnd[MAXPLAYERS + 1][3];
new t_Distance[MAXPLAYERS + 1];
new t_Healing[MAXPLAYERS + 1];
new bool:b_IsActiveRound;
new bool:b_IsFirstPluginLoad;
new String:s_rup[32];
new Handle:MainKeys;
new Handle:MainValues;
new Handle:a_Menu_Talents;
new Handle:a_Menu_Main;
new Handle:a_Events;
new Handle:a_Points;
new Handle:a_Pets;
new Handle:a_Database_Talents;
new Handle:a_Database_Talents_Defaults;
new Handle:a_Database_Talents_Defaults_Name;
new Handle:MenuKeys[MAXPLAYERS + 1];
new Handle:MenuValues[MAXPLAYERS + 1];
new Handle:MenuSection[MAXPLAYERS + 1];
new Handle:TriggerKeys[MAXPLAYERS + 1];
new Handle:TriggerValues[MAXPLAYERS + 1];
new Handle:TriggerSection[MAXPLAYERS + 1];
new Handle:AbilityKeys[MAXPLAYERS + 1];
new Handle:AbilityValues[MAXPLAYERS + 1];
new Handle:AbilitySection[MAXPLAYERS + 1];
new Handle:ChanceKeys[MAXPLAYERS + 1];
new Handle:ChanceValues[MAXPLAYERS + 1];
new Handle:ChanceSection[MAXPLAYERS + 1];
new Handle:PurchaseKeys[MAXPLAYERS + 1];
new Handle:PurchaseValues[MAXPLAYERS + 1];
new Handle:EventSection;
new Handle:HookSection;
new Handle:CallKeys;
new Handle:CallValues;
//new Handle:CallSection;
new Handle:DirectorKeys;
new Handle:DirectorValues;
//new Handle:DirectorSection;
new Handle:DatabaseKeys;
new Handle:DatabaseValues;
new Handle:DatabaseSection;
new Handle:a_Database_PlayerTalents_Bots;
new Handle:PlayerAbilitiesCooldown_Bots;
new Handle:PlayerAbilitiesImmune_Bots;
new Handle:BotSaveKeys;
new Handle:BotSaveValues;
new Handle:BotSaveSection;
new Handle:LoadDirectorSection;
new Handle:QueryDirectorKeys;
new Handle:QueryDirectorValues;
new Handle:QueryDirectorSection;
new Handle:FirstDirectorKeys;
new Handle:FirstDirectorValues;
new Handle:FirstDirectorSection;
new Handle:a_Database_PlayerTalents[MAXPLAYERS + 1];
new Handle:a_Database_PlayerTalents_Experience[MAXPLAYERS + 1];
new Handle:PlayerAbilitiesName;
new Handle:PlayerAbilitiesCooldown[MAXPLAYERS + 1];
//new Handle:PlayerAbilitiesImmune[MAXPLAYERS + 1][MAXPLAYERS + 1];
new Handle:PlayerInventory[MAXPLAYERS + 1];
new Handle:PlayerEquipped[MAXPLAYERS + 1];
new Handle:a_DirectorActions;
new Handle:a_DirectorActions_Cooldown;
new PlayerLevel[MAXPLAYERS + 1];
new PlayerLevelUpgrades[MAXPLAYERS + 1];
new TotalTalentPoints[MAXPLAYERS + 1];
new ExperienceLevel[MAXPLAYERS + 1];
new SkyPoints[MAXPLAYERS + 1];
new String:MenuSelection[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
new String:MenuSelection_p[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
new String:MenuName_c[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
new Float:Points[MAXPLAYERS + 1];
new DamageAward[MAXPLAYERS + 1][MAXPLAYERS + 1];
new DefaultHealth[MAXPLAYERS + 1];
new String:white[4];
new String:green[4];
new String:blue[4];
new String:orange[4];
new bool:b_IsBlind[MAXPLAYERS + 1];
new bool:b_IsImmune[MAXPLAYERS + 1];
new Float:SpeedMultiplier[MAXPLAYERS + 1];
new Float:SpeedMultiplierBase[MAXPLAYERS + 1];
new bool:b_IsJumping[MAXPLAYERS + 1];
new Handle:g_hEffectAdrenaline = INVALID_HANDLE;
new Handle:g_hCallVomitOnPlayer = INVALID_HANDLE;
new Handle:hRoundRespawn = INVALID_HANDLE;
new Handle:g_hCreateAcid = INVALID_HANDLE;
new Float:GravityBase[MAXPLAYERS + 1];
new bool:b_GroundRequired[MAXPLAYERS + 1];
new CoveredInBile[MAXPLAYERS + 1][MAXPLAYERS + 1];
new CommonKills[MAXPLAYERS + 1];
new CommonKillsHeadshot[MAXPLAYERS + 1];
new String:OpenedMenu_p[MAXPLAYERS + 1][512];
new String:OpenedMenu[MAXPLAYERS + 1][512];
new ExperienceOverall[MAXPLAYERS + 1];
//new String:CurrentTalentLoading_Bots[128];
//new Handle:a_Database_PlayerTalents_Bots;
//new Handle:PlayerAbilitiesCooldown_Bots;				// Because [designation] = ZombieclassID
new ExperienceLevel_Bots;
//new ExperienceOverall_Bots;
//new PlayerLevelUpgrades_Bots;
new PlayerLevel_Bots;
//new TotalTalentPoints_Bots;
new Float:Points_Director;
new Handle:CommonInfectedQueue;
new g_oAbility = 0;
new Handle:g_hIsStaggering = INVALID_HANDLE;
new Handle:g_hSetClass = INVALID_HANDLE;
new Handle:g_hCreateAbility = INVALID_HANDLE;
new Handle:gd = INVALID_HANDLE;
//new Handle:DirectorPurchaseTimer = INVALID_HANDLE;
new bool:b_IsDirectorTalents[MAXPLAYERS + 1];
//new LoadPos_Bots;
new LoadPos[MAXPLAYERS + 1];
new LoadPos_Director;
new Handle:g_Steamgroup;
new Handle:g_Tags;
new Handle:g_Gamemode;
new RoundTime;
new g_iSprite = 0;
new g_BeaconSprite = 0;
new iNoSpecials;
//new bool:b_FirstClientLoaded;
new bool:b_HasDeathLocation[MAXPLAYERS + 1];
new bool:b_IsMissionFailed;
new Handle:CCASection;
new Handle:CCAKeys;
new Handle:CCAValues;
new LastWeaponDamage[MAXPLAYERS + 1];
new Float:UseItemTime[MAXPLAYERS + 1];
new Handle:NewUsersRound;
new bool:bIsSoloHandicap;
new Handle:MenuStructure[MAXPLAYERS + 1];
new Handle:TankState_Array[MAXPLAYERS + 1];
new bool:bIsGiveIncapHealth[MAXPLAYERS + 1];
new Handle:TheLeaderboards[MAXPLAYERS + 1];
new Handle:TheLeaderboardsData[MAXPLAYERS + 1];
new TheLeaderboardsPage[MAXPLAYERS + 1];		// 10 entries at a time, until the end of time.
new bool:bIsMyRanking[MAXPLAYERS + 1];
new TheLeaderboardsPageSize[MAXPLAYERS + 1];
new CurrentRPGMode;
new bool:IsSurvivalMode = false;
new BestRating[MAXPLAYERS + 1];
new MyRespawnTarget[MAXPLAYERS + 1];
new bool:RespawnImmunity[MAXPLAYERS + 1];
new String:TheDBPrefix[64];
new LastAttackedUser[MAXPLAYERS + 1];
new Handle:LoggedUsers;
new Handle:TalentTreeKeys[MAXPLAYERS + 1];
new Handle:TalentTreeValues[MAXPLAYERS + 1];
new Handle:TalentExperienceKeys[MAXPLAYERS + 1];
new Handle:TalentExperienceValues[MAXPLAYERS + 1];
new Handle:TalentActionKeys[MAXPLAYERS + 1];
new Handle:TalentActionValues[MAXPLAYERS + 1];
new Handle:TalentActionSection[MAXPLAYERS + 1];
new bool:bIsTalentTwo[MAXPLAYERS + 1];
new Handle:CommonDrawKeys;
new Handle:CommonDrawValues;
new bool:bAutoRevive[MAXPLAYERS + 1];
new bool:bIsClassAbilities[MAXPLAYERS + 1];
new bool:bIsDisconnecting[MAXPLAYERS + 1];
new Handle:LegitClassSection[MAXPLAYERS + 1];
new LoadProfileRequestName[MAXPLAYERS + 1];
//new String:LoadProfileRequest[MAXPLAYERS + 1];
new String:TheCurrentMap[64];
new bool:IsEnrageNotified;
//new bool:bIsNewClass[MAXPLAYERS + 1];
new ClientActiveStance[MAXPLAYERS + 1];
new Handle:SurvivorsIgnored[MAXPLAYERS + 1];
new bool:HasSeenCombat[MAXPLAYERS + 1];
new MyBirthday[MAXPLAYERS + 1];
//======================================
//Main config static variables.
//======================================
new Float:fSuperCommonLimit;
new Float:fBurnPercentage;
new iTankRush;
new iTanksAlways;
new Float:fSprintSpeed;
new iRPGMode;
new DirectorWitchLimit;
new Float:fCommonQueueLimit;
new Float:fDirectorThoughtDelay;
new Float:fDirectorThoughtHandicap;
new Float:fDirectorThoughtProcessMinimum;
new iSurvivalRoundTime;
new Float:fDazedDebuffEffect;
new ConsumptionInt;
new Float:fStamSprintInterval;
new Float:fStamRegenTime;
new Float:fStamRegenTimeAdren;
new Float:fBaseMovementSpeed;
new Float:fFatigueMovementSpeed;
new iPlayerStartingLevel;
new iBotPlayerStartingLevel;
new Float:fOutOfCombatTime;
new iWitchDamageInitial;
new Float:fWitchDamageScaleLevel;
new Float:fSurvivorDamageBonus;
new Float:fSurvivorHealthBonus;
new iEnrageTime;
new Float:fWitchDirectorPoints;
new Float:fEnrageDirectorPoints;
new Float:fCommonDamageLevel;
new iBotLevelType;
new Float:fCommonDirectorPoints;
new iDisplayHealthBars;
new iMaxDifficultyLevel;
new Float:fDamagePlayerLevel[7];
new Float:fHealthPlayerLevel[7];
new iBaseSpecialDamage[7];
new iBaseSpecialInfectedHealth[7];
new Float:fPointsMultiplierInfected;
new Float:fPointsMultiplier;
new Float:fHealingMultiplier;
new Float:fBuffingMultiplier;
new Float:fHexingMultiplier;
new Float:TanksNearbyRange;
new iCommonAffixes;
new BroadcastType;
new iDoomTimer;
new iSurvivorStaminaMax;
new Float:fRatingMultSpecials;
new Float:fRatingMultSupers;
new Float:fRatingMultCommons;
new Float:fRatingMultTank;
new Float:fRatingMultWitch;
new Float:fTeamworkExperience;
new Float:fItemMultiplierLuck;
new Float:fItemMultiplierTeam;
new String:sQuickBindHelp[64];
new Float:fPointsCostLevel;
new PointPurchaseType;
new iTankLimitVersus;
new Float:fHealRequirementTeam;
new iSurvivorBaseHealth;
new iSurvivorBotBaseHealth;
new String:spmn[64];
new Float:fHealthSurvivorRevive;
new String:RestrictedWeapons[1024];
new iMaxLevel;
new iExperienceStart;
new Float:fExperienceMultiplier;
new String:sBotTeam[64];
new iActionBarSlots;
new String:MenuCommand[64];
new HostNameTime;
new DoomSUrvivorsRequired;
new DoomKillTimer;
new Float:fVersusTankNotice;
new AllowedCommons;
new AllowedMegaMob;
new AllowedMobSpawn;
new AllowedMobSpawnFinale;
//new AllowedPanicInterval;
new RespawnQueue;
new MaximumPriority;
new Float:fUpgradeExpCost;
new iHandicapLevelDifference;
new iWitchHealthBase;
new Float:fWitchHealthMult;
new RatingPerLevel;
new RatingPerLevelSurvivorBots;
new iCommonBaseHealth;
new Float:fCommonLevelHealthMult;
new iServerLevelRequirement;
new iRoundStartWeakness;
new Float:GroupMemberBonus;
new Float:FinSurvBon;
new RaidLevMult;
new iIgnoredRating;
new iIgnoredRatingMax;
new iInfectedLimit;
new Float:SurvivorExperienceMult;
new Float:SurvivorExperienceMultTank;
//new Float:SurvivorExperienceMultHeal;
new Float:TheScorchMult;
new Float:TheInfernoMult;
new Float:fAmmoHighlightTime;
new Float:fAdrenProgressMult;
new Float:DirectorTankCooldown;
new DisplayType;
new String:sDirectorTeam[64];
new Float:fRestedExpMult;
new Float:fSurvivorExpMult;
new iDebuffLimit;
new iRatingSpecialsRequired;
new iRatingTanksRequired;
new String:sDbLeaderboards[64];
new iIsLifelink;
new RatingPerHandicap;
new Handle:ItemDropArray;
new String:sItemModel[512];
new iSurvivorGroupMinimum;
/*new Float:fDropChanceSpecial;
new Float:fDropChanceCommon;
new Float:fDropChanceWitch;
new Float:fDropChanceTank;
new Float:fDropChanceInfected;*/
new Handle:PreloadKeys;
new Handle:PreloadValues;
new Handle:ItemDropKeys;
new Handle:ItemDropValues;
new Handle:ItemDropSection;
new Handle:persistentCirculation;
new iRarityMax;
new iEnrageAdvertisement;
new iJoinGroupAdvertisement;
new iNotifyEnrage;
new String:sBackpackModel[64];
new String:ItemDropArraySize[64];
new bool:bIsNewPlayer[MAXPLAYERS + 1];
new Handle:MyGroup[MAXPLAYERS + 1];
new iCommonsLimitUpper;
new bool:bIsInCheckpoint[MAXPLAYERS + 1];
new Float:fCoopSurvBon;
new iMinSurvivors;
new PassiveEffectDisplay[MAXPLAYERS + 1];
new String:sServerDifficulty[64];
new iSpecialsAllowed;
new String:sSpecialsAllowed[64];
new iSurvivorModifierRequired;
new Float:fEnrageMultiplier;
new OverHealth[MAXPLAYERS + 1];
new bool:bHealthIsSet[MAXPLAYERS + 1];
new iIsLevelingPaused[MAXPLAYERS + 1];
new iIsBulletTrails[MAXPLAYERS + 1];
new Handle:ActiveStatuses[MAXPLAYERS + 1];
new InfectedTalentLevel;
new Float:fEnrageModifier;
new Float:LastAttackTime[MAXPLAYERS + 1];
new Handle:hWeaponList[MAXPLAYERS + 1];
new Handle:GCVKeys[MAXPLAYERS + 1];
new Handle:GCVValues[MAXPLAYERS + 1];
new Handle:GCVSection[MAXPLAYERS + 1];
new MyStatusEffects[MAXPLAYERS + 1];
new iShowLockedTalents;
//new Handle:GCMKeys[MAXPLAYERS + 1];
//new Handle:GCMValues[MAXPLAYERS + 1];
new Handle:PassiveStrengthKeys[MAXPLAYERS + 1];
new Handle:PassiveStrengthValues[MAXPLAYERS + 1];
new Handle:PassiveTalentName[MAXPLAYERS + 1];
new Handle:UpgradeCategoryKeys[MAXPLAYERS + 1];
new Handle:UpgradeCategoryValues[MAXPLAYERS + 1];
new Handle:UpgradeCategoryName[MAXPLAYERS + 1];
new iChaseEnt[MAXPLAYERS + 1];
new iTeamRatingRequired;
new Float:fTeamRatingBonus;
new Float:fRatingPercentLostOnDeath;
new PlayerCurrentMenuLayer[MAXPLAYERS + 1];
new iMaxLayers;
new Handle:TranslationOTNKeys[MAXPLAYERS + 1];
new Handle:TranslationOTNValues[MAXPLAYERS + 1];
new Handle:TranslationOTNSection[MAXPLAYERS + 1];
new Handle:acdrKeys[MAXPLAYERS + 1];
new Handle:acdrValues[MAXPLAYERS + 1];
new Handle:acdrSection[MAXPLAYERS + 1];
new Handle:GetLayerStrengthKeys[MAXPLAYERS + 1];
new Handle:GetLayerStrengthValues[MAXPLAYERS + 1];
new Handle:GetLayerStrengthSection[MAXPLAYERS + 1];
new iCommonInfectedBaseDamage;
new playerPageOfCharacterSheet[MAXPLAYERS + 1];
new nodesInExistence;
new iShowTotalNodesOnTalentTree;
new Handle:PlayerEffectOverTime[MAXPLAYERS + 1];
new Handle:PlayerEffectOverTimeEffects[MAXPLAYERS + 1];
new Handle:CheckEffectOverTimeKeys[MAXPLAYERS + 1];
new Handle:CheckEffectOverTimeValues[MAXPLAYERS + 1];
new Float:fSpecialAmmoInterval;
new Float:fEffectOverTimeInterval;
new Handle:FormatEffectOverTimeKeys[MAXPLAYERS + 1];
new Handle:FormatEffectOverTimeValues[MAXPLAYERS + 1];
new Handle:FormatEffectOverTimeSection[MAXPLAYERS + 1];
new Handle:CooldownEffectTriggerKeys[MAXPLAYERS + 1];
new Handle:CooldownEffectTriggerValues[MAXPLAYERS + 1];
new Handle:IsSpellAnAuraKeys[MAXPLAYERS + 1];
new Handle:IsSpellAnAuraValues[MAXPLAYERS + 1];
new Float:fStaggerTickrate;
new Handle:StaggeredTargets;
new Handle:staggerBuffer;
new bool:staggerCooldownOnTriggers[MAXPLAYERS + 1];
new Handle:CallAbilityCooldownTriggerKeys[MAXPLAYERS + 1];
new Handle:CallAbilityCooldownTriggerValues[MAXPLAYERS + 1];
new Handle:CallAbilityCooldownTriggerSection[MAXPLAYERS + 1];
new Handle:GetIfTriggerRequirementsMetKeys[MAXPLAYERS + 1];
new Handle:GetIfTriggerRequirementsMetValues[MAXPLAYERS + 1];
new Handle:GetIfTriggerRequirementsMetSection[MAXPLAYERS + 1];
new bool:ShowPlayerLayerInformation[MAXPLAYERS + 1];
new Handle:GAMKeys[MAXPLAYERS + 1];
new Handle:GAMValues[MAXPLAYERS + 1];
new Handle:GAMSection[MAXPLAYERS + 1];
new String:RPGMenuCommand[64];
new RPGMenuCommandExplode;
//new PrestigeLevel[MAXPLAYERS + 1];
new String:DefaultProfileName[64];
new String:DefaultBotProfileName[64];
new String:DefaultInfectedProfileName[64];
new Handle:GetGoverningAttributeKeys[MAXPLAYERS + 1];
new Handle:GetGoverningAttributeValues[MAXPLAYERS + 1];
new Handle:GetGoverningAttributeSection[MAXPLAYERS + 1];
new iTanksAlwaysEnforceCooldown;
new Handle:WeaponResultKeys[MAXPLAYERS + 1];
new Handle:WeaponResultValues[MAXPLAYERS + 1];
new Handle:WeaponResultSection[MAXPLAYERS + 1];
new bool:shotgunCooldown[MAXPLAYERS + 1];
new Float:fRatingFloor;
new String:clientStatusEffectDisplay[MAXPLAYERS + 1][64];
new String:clientTrueHealthDisplay[MAXPLAYERS + 1][64];
new String:clientContributionHealthDisplay[MAXPLAYERS + 1][64];
new iExperienceDebtLevel;
new iExperienceDebtEnabled;
new Float:fExperienceDebtPenalty;
new iShowDamageOnActionBar;
new iDefaultIncapHealth;
new Handle:GetAbilityCooldownKeys[MAXPLAYERS + 1];
new Handle:GetAbilityCooldownValues[MAXPLAYERS + 1];
new Handle:GetAbilityCooldownSection[MAXPLAYERS + 1];
new Handle:GetTalentValueSearchKeys[MAXPLAYERS + 1];
new Handle:GetTalentValueSearchValues[MAXPLAYERS + 1];
new Handle:GetTalentValueSearchSection[MAXPLAYERS + 1];
new iSkyLevelNodeUnlocks;
new Handle:GetTalentKeyValueKeys[MAXPLAYERS + 1];
new Handle:GetTalentKeyValueValues[MAXPLAYERS + 1];
new Handle:GetTalentKeyValueSection[MAXPLAYERS + 1];
new Handle:ApplyDebuffCooldowns[MAXPLAYERS + 1];
new iCanSurvivorBotsBurn;
new String:defaultLoadoutWeaponPrimary[64];
new String:defaultLoadoutWeaponSecondary[64];
new iDeleteCommonsFromExistenceOnDeath;
new iShowDetailedDisplayAlways;
new iCanJetpackWhenInCombat;
new Handle:ZoomcheckDelayer[MAXPLAYERS + 1];
new Handle:zoomCheckList;
new Float:fquickScopeTime;
new Handle:holdingFireList;
new iEnsnareLevelMultiplier;
new Handle:CommonInfectedHealth;
new lastBaseDamage[MAXPLAYERS + 1];
new lastTarget[MAXPLAYERS + 1];
new String:lastWeapon[MAXPLAYERS + 1][64];
new iSurvivorBotsBonusLimit;
new Float:fSurvivorBotsNoneBonus;
new bool:bTimersRunning[MAXPLAYERS + 1];
new iShowAdvertToNonSteamgroupMembers;
new displayBuffOrDebuff[MAXPLAYERS + 1];
new Handle:TalentAtMenuPositionSection[MAXPLAYERS + 1];
new iStrengthOnSpawnIsStrength;
new Handle:SetNodesKeys;
new Handle:SetNodesValues;
new Float:fDrawHudInterval;
new bool:ImmuneToAllDamage[MAXPLAYERS + 1];
new iPlayersLeaveCombatDuringFinales;
new iAllowPauseLeveling;
//new iDropAcidOnLastDebuffDrop;
new Float:fMaxDamageResistance;
new Float:fStaminaPerPlayerLevel;
new Float:fStaminaPerSkyLevel;
new LastBulletCheck[MAXPLAYERS + 1];
new iSpecialInfectedMinimum;
new iEndRoundIfNoHealthySurvivors;
new iEndRoundIfNoLivingHumanSurvivors;
new Float:fAcidDamagePlayerLevel;
new Float:fAcidDamageSupersPlayerLevel;
new String:ClientStatusEffects[MAXPLAYERS + 1][2][64];
new Float:fTankMovementSpeed_Burning;
new Float:fTankMovementSpeed_Hulk;
new Float:fTankMovementSpeed_Death;
new iResetPlayerLevelOnDeath;
new iStartingPlayerUpgrades;
new String:serverKey[64];
new bool:playerHasAdrenaline[MAXPLAYERS + 1];
new bool:playerInSlowAmmo[MAXPLAYERS + 1];
new leaderboardPageCount;
new Float:fForceTankJumpHeight;
new Float:fForceTankJumpRange;
new iResetDirectorPointsOnNewRound;
new iMaxServerUpgrades;
new iExperienceLevelCap;
new bool:LastHitWasHeadshot[MAXPLAYERS + 1];
new String:acmd[20];
new String:abcmd[20];
new iDeleteSupersOnDeath;
new iShoveStaminaCost;
new Float:fLootChanceTank;
new Float:fLootChanceSpecials;
new Float:fLootChanceSupers;
new Float:fLootChanceCommons;
new iLootEnabled;
new Float:fUpgradesRequiredPerLayer;
new iEnsnareRestrictions;
new levelToSet[MAXPLAYERS+1];
new String:steamIdSearch[MAXPLAYERS+1][64];
new iDontStoreInfectedInArray;
new String:baseName[MAXPLAYERS+1][64];
new Float:fSurvivorBufferBonus;
new iCommonInfectedSpawnDelayOnNewRound;
new scoreRequiredForLeaderboard;
new bool:bIsClientCurrentlyStaggered[MAXPLAYERS +1];
new String:loadProfileOverrideFlags[64];

public Action:CMD_DropWeapon(client, args) {
	new CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntity(CurrentEntity) || CurrentEntity < 1) return Plugin_Handled;
	decl String:EntityName[64];
	GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));
	if (StrContains(EntityName, "melee", false) != -1) return Plugin_Handled;
	new Entity					=	CreateEntityByName(EntityName);
	DispatchSpawn(Entity);
	new Float:Origin[3];
	GetClientAbsOrigin(client, Origin);
	Origin[2] += 64.0;
	TeleportEntity(Entity, Origin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(Entity, MOVETYPE_VPHYSICS);
	if (GetWeaponSlot(Entity) < 2) SetEntProp(Entity, Prop_Send, "m_iClip1", GetEntProp(CurrentEntity, Prop_Send, "m_iClip1"));
	AcceptEntityInput(CurrentEntity, "Kill");
	return Plugin_Handled;
}

public Action:CMD_IAmStuck(client, args) {
	if (L4D2_GetInfectedAttacker(client) == -1 && !AnyTanksNearby(client, 512.0)) {
		new target = FindAnyRandomClient(true, client);
		if (target > 0) {
			GetClientAbsOrigin(target, Float:DeathLocation[client]);
			TeleportEntity(client, DeathLocation[client], NULL_VECTOR, NULL_VECTOR);
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
	}
	return Plugin_Handled;
}

stock DoGunStuff(client) {
	new targetgun = GetPlayerWeaponSlot(client, 0); //get the players primary weapon
	if (!IsValidEdict(targetgun)) return; //check for validity
	new iAmmoOffset = FindDataMapOffs(client, "m_iAmmo"); //get the iAmmo Offset
	iAmmoOffset = GetEntData(client, (iAmmoOffset + GetWeaponResult(client, 1)));
	PrintToChat(client, "reserve remaining: %d | reserve cap: %d", iAmmoOffset, GetWeaponResult(client, 2));
	return;
}

stock CMD_OpenRPGMenu(client) {
	ClearArray(Handle:MenuStructure[client]);	// keeps track of the open menus.
	//VerifyAllActionBars(client);	// Because.
	if (LoadProfileRequestName[client] != -1) {
		if (!IsLegitimateClient(LoadProfileRequestName[client])) LoadProfileRequestName[client] = -1;
	}
	iIsWeaponLoadout[client] = 0;
	bEquipSpells[client] = false;
	PlayerCurrentMenuLayer[client] = 1;
	ShowPlayerLayerInformation[client] = false;
	if (iAllowPauseLeveling != 1 && iIsLevelingPaused[client] == 1) iIsLevelingPaused[client] = 0;
	BuildMenu(client, "main");
	/*new count = GetEntProp(client, Prop_Send, "m_iShovePenalty", 4);
	PrintToChat(client, "shove penalty: %d", count);
	if (count < 1) {
		SetEntProp(client, Prop_Send, "m_iShovePenalty", 10);
		SetEntPropFloat(client, Prop_Send, "m_flNextShoveTime", 900.0);
	}
	else {
		SetEntProp(client, Prop_Send, "m_iShovePenalty", 0);
		SetEntPropFloat(client, Prop_Send, "m_flNextShoveTime", 1.0);
	}*/
	//PrintToChat(client, "penalty soon: %d", count);
}

public OnPluginStart() {
	CreateConVar("skyrpg_version", PLUGIN_VERSION, "version header", CVAR_SHOW);
	SetConVarString(FindConVar("skyrpg_version"), PLUGIN_VERSION);
	g_Steamgroup = FindConVar("sv_steamgroup");
	SetConVarFlags(g_Steamgroup, GetConVarFlags(g_Steamgroup) & ~FCVAR_NOTIFY);
	g_Tags = FindConVar("sv_tags");
	SetConVarFlags(g_Tags, GetConVarFlags(g_Tags) & ~FCVAR_NOTIFY);
	g_Gamemode = FindConVar("mp_gamemode");
	LoadTranslations("skyrpg.phrases");
	BuildPath(Path_SM, ConfigPathDirectory, sizeof(ConfigPathDirectory), "configs/readyup/");
	if (!DirExists(ConfigPathDirectory)) CreateDirectory(ConfigPathDirectory, 777);
	BuildPath(Path_SM, LogPathDirectory, sizeof(LogPathDirectory), "logs/readyup/rpg/");
	if (!DirExists(LogPathDirectory)) CreateDirectory(LogPathDirectory, 777);
	BuildPath(Path_SM, LogPathDirectory, sizeof(LogPathDirectory), "logs/readyup/rpg/%s", LOGFILE);
	if (!FileExists(LogPathDirectory)) SetFailState("[SKYRPG LOGGING] please create file at %s", LogPathDirectory);
	RegAdminCmd("debugrpg", Cmd_debugrpg, ADMFLAG_KICK);
	RegAdminCmd("resettpl", Cmd_ResetTPL, ADMFLAG_KICK);
	RegAdminCmd("origin", Cmd_GetOrigin, ADMFLAG_KICK);
	RegAdminCmd("deleteprofiles", CMD_DeleteProfiles, ADMFLAG_ROOT);
	// These are mandatory because of quick commands, so I hardcode the entries.
	RegConsoleCmd("say", CMD_ChatCommand);
	RegConsoleCmd("say_team", CMD_TeamChatCommand);
	RegConsoleCmd("callvote", CMD_BlockVotes);
	RegConsoleCmd("votemap", CMD_BlockIfReadyUpIsActive);
	RegConsoleCmd("vote", CMD_BlockVotes);
	//RegConsoleCmd("talentupgrade", CMD_TalentUpgrade);
	RegConsoleCmd("loadoutname", CMD_LoadoutName);
	RegConsoleCmd("stuck", CMD_IAmStuck);
	RegConsoleCmd("ff", CMD_TogglePvP);
	RegConsoleCmd("revive", CMD_RespawnYumYum);
	//RegConsoleCmd("abar", CMD_ActionBar);
	RegConsoleCmd("handicap", CMD_Handicap);
	RegAdminCmd("firesword", CMD_FireSword, ADMFLAG_KICK);
	RegAdminCmd("fbegin", CMD_FBEGIN, ADMFLAG_KICK);
	RegAdminCmd("witches", CMD_WITCHESCOUNT, ADMFLAG_KICK);
	//RegAdminCmd("staggertest", CMD_STAGGERTEST, ADMFLAG_KICK);
	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");
	HookUserMessage(GetUserMessageId("SayText2"), TextMsg, true);
	gd = LoadGameConfigFile("rum_rpg");
	if (gd != INVALID_HANDLE) {
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "SetClass");
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSetClass = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CreateAbility");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hCreateAbility = EndPrepSDKCall();
		g_oAbility = GameConfGetOffset(gd, "oAbility");
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CSpitterProjectile_Detonate");
		g_hCreateAcid = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CTerrorPlayer_OnAdrenalineUsed");
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hEffectAdrenaline = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hCallVomitOnPlayer = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "RoundRespawn");
		hRoundRespawn = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "IsStaggering");
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		g_hIsStaggering = EndPrepSDKCall();
	}
	else {
		SetFailState("Error: Unable to load Gamedata rum_rpg.txt");
	}
	CheckDifficulty();
	staggerBuffer = CreateConVar("sm_vscript_res", "", "returns results from vscript check on stagger");
}

public Action:CMD_WITCHESCOUNT(client, args) {
	PrintToChat(client, "Witches: %d", GetArraySize(WitchList));
	return Plugin_Handled;
}

public Action:CMD_FBEGIN(client, args) {
	ReadyUpEnd_Complete();
}

public Action:Cmd_GetOrigin(client, args) {
	new Float:OriginP[3];
	decl String:sMelee[64];
	GetMeleeWeapon(client, sMelee, sizeof(sMelee));
	GetClientAbsOrigin(client, OriginP);
	PrintToChat(client, "[0] %3.3f [1] %3.3f [2] %3.3f\n%s", OriginP[0], OriginP[1], OriginP[2], sMelee);
	return Plugin_Handled;
}

public Action:CMD_DeleteProfiles(client, args) {
	if (DeleteAllProfiles(client)) PrintToChat(client, "all saved profiles are deleted.");
	return Plugin_Handled;
}
public Action:CMD_BlockVotes(client, args) {
	return Plugin_Handled;
}

public Action:CMD_BlockIfReadyUpIsActive(client, args) {
	if (!b_IsRoundIsOver) return Plugin_Continue;
	return Plugin_Handled;
}

public ReadyUp_SetSurvivorMinimum(minSurvs) {
	iMinSurvivors = minSurvs;
}

public ReadyUp_GetMaxSurvivorCount(count) {
	if (count <= 1) bIsSoloHandicap = true;
	else bIsSoloHandicap = false;
}

stock UnhookAll() {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			b_IsHooked[i] = false;
		}
	}
}

public ReadyUp_TrueDisconnect(client) {
	if (bIsInCombat[client]) IncapacitateOrKill(client, _, _, true, true, true);
	bTimersRunning[client] = false;
	//ChangeHook(client);
	staggerCooldownOnTriggers[client] = false;
	ISBILED[client] = false;
	DisplayActionBar[client] = false;
	IsPvP[client] = 0;
	b_IsFloating[client] = false;
	b_IsLoading[client] = false;
	b_HardcoreMode[client] = false;
	//WipeDebuffs(_, client, true);
	if (b_IsLoaded[client]) SavePlayerData(client, true);
	IsPlayerDebugMode[client] = 0;
	CleanseStack[client] = 0;
	CounterStack[client] = 0.0;
	MultiplierStack[client] = 0;
	LoadTarget[client] = -1;
	ImmuneToAllDamage[client] = false;
	b_IsLoaded[client] = false;		// only set to false if a REAL player leaves - this way bots don't repeatedly load their data.
	// Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	// Format(BuildingStack[client], sizeof(BuildingStack[]), "none");
	// Format(LoadoutName[client], sizeof(LoadoutName[]), "none");
	//CreateTimer(1.0, Timer_RemoveSaveSafety, client, TIMER_FLAG_NO_MAPCHANGE);
	bIsSettingsCheck = true;
	// if (b_IsActiveRound && ScenarioEndConditionsMet()) {	// If the disconnecting player was the last living human survivor, if the round is live, we end the round.
	// 	b_IsMissionFailed = true;
	// 	ForceServerCommand("scenario_end");
	// 	CallRoundIsOver();
	// }
}
/*public ReadyUp_FwdChangeTeam(client, team) {

	if (team == TEAM_SPECTATOR) {

		if (bIsInCombat[client]) {

			IncapacitateOrKill(client, _, _, true, true);
		}

		b_IsHooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	else if (team == TEAM_SURVIVOR && !b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}*/

//stock LoadConfigValues() {
//}

public OnAllPluginsLoaded() {
	OnMapStartFunc();
	CheckDifficulty();
}

stock OnMapStartFunc() {
	if (!b_MapStart) {
		b_MapStart								= true;
		CreateTimer(1.0, Timer_CheckDifficulty, _, TIMER_REPEAT);
		//LoadConfigValues();
		LogMessage("=====\t\tLOADING RPG\t\t=====");
		//new String:fubar[64];
		if (holdingFireList == INVALID_HANDLE || !b_FirstLoad) holdingFireList = CreateArray(32);
		if (zoomCheckList == INVALID_HANDLE || !b_FirstLoad) zoomCheckList = CreateArray(32);
		if (hThreatSort == INVALID_HANDLE || !b_FirstLoad) hThreatSort = CreateArray(32);
		if (hThreatMeter == INVALID_HANDLE || !b_FirstLoad) hThreatMeter = CreateArray(32);
		if (LoggedUsers == INVALID_HANDLE || !b_FirstLoad) LoggedUsers = CreateArray(32);
		if (SuperCommonQueue == INVALID_HANDLE || !b_FirstLoad) SuperCommonQueue = CreateArray(32);
		if (CommonInfectedQueue == INVALID_HANDLE || !b_FirstLoad) CommonInfectedQueue = CreateArray(32);
		if (CoveredInVomit == INVALID_HANDLE || !b_FirstLoad) CoveredInVomit = CreateArray(32);
		if (NewUsersRound == INVALID_HANDLE || !b_FirstLoad) NewUsersRound = CreateArray(32);
		if (SpecialAmmoData == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoData = CreateArray(32);
		if (SpecialAmmoSave == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoSave = CreateArray(32);
		if (MainKeys == INVALID_HANDLE || !b_FirstLoad) MainKeys = CreateArray(32);
		if (MainValues == INVALID_HANDLE || !b_FirstLoad) MainValues = CreateArray(32);
		if (a_Menu_Talents == INVALID_HANDLE || !b_FirstLoad) a_Menu_Talents = CreateArray(3);
		if (a_Menu_Main == INVALID_HANDLE || !b_FirstLoad) a_Menu_Main = CreateArray(3);
		if (a_Events == INVALID_HANDLE || !b_FirstLoad) a_Events = CreateArray(3);
		if (a_Points == INVALID_HANDLE || !b_FirstLoad) a_Points = CreateArray(3);
		if (a_Pets == INVALID_HANDLE || !b_FirstLoad) a_Pets = CreateArray(3);
		if (a_Store == INVALID_HANDLE || !b_FirstLoad) a_Store = CreateArray(3);
		if (a_Trails == INVALID_HANDLE || !b_FirstLoad) a_Trails = CreateArray(3);
		if (a_Database_Talents == INVALID_HANDLE || !b_FirstLoad) a_Database_Talents = CreateArray(32);
		if (a_Database_Talents_Defaults == INVALID_HANDLE || !b_FirstLoad) a_Database_Talents_Defaults 	= CreateArray(32);
		if (a_Database_Talents_Defaults_Name == INVALID_HANDLE || !b_FirstLoad) a_Database_Talents_Defaults_Name				= CreateArray(32);
		if (EventSection == INVALID_HANDLE || !b_FirstLoad) EventSection									= CreateArray(32);
		if (HookSection == INVALID_HANDLE || !b_FirstLoad) HookSection										= CreateArray(32);
		if (CallKeys == INVALID_HANDLE || !b_FirstLoad) CallKeys										= CreateArray(32);
		if (CallValues == INVALID_HANDLE || !b_FirstLoad) CallValues										= CreateArray(32);
		if (DirectorKeys == INVALID_HANDLE || !b_FirstLoad) DirectorKeys									= CreateArray(32);
		if (DirectorValues == INVALID_HANDLE || !b_FirstLoad) DirectorValues									= CreateArray(32);
		if (DatabaseKeys == INVALID_HANDLE || !b_FirstLoad) DatabaseKeys									= CreateArray(32);
		if (DatabaseValues == INVALID_HANDLE || !b_FirstLoad) DatabaseValues									= CreateArray(32);
		if (DatabaseSection == INVALID_HANDLE || !b_FirstLoad) DatabaseSection									= CreateArray(32);
		if (a_Database_PlayerTalents_Bots == INVALID_HANDLE || !b_FirstLoad) a_Database_PlayerTalents_Bots					= CreateArray(32);
		if (PlayerAbilitiesCooldown_Bots == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesCooldown_Bots					= CreateArray(32);
		if (PlayerAbilitiesImmune_Bots == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesImmune_Bots						= CreateArray(32);
		if (BotSaveKeys == INVALID_HANDLE || !b_FirstLoad) BotSaveKeys										= CreateArray(32);
		if (BotSaveValues == INVALID_HANDLE || !b_FirstLoad) BotSaveValues									= CreateArray(32);
		if (BotSaveSection == INVALID_HANDLE || !b_FirstLoad) BotSaveSection									= CreateArray(32);
		if (LoadDirectorSection == INVALID_HANDLE || !b_FirstLoad) LoadDirectorSection								= CreateArray(32);
		if (QueryDirectorKeys == INVALID_HANDLE || !b_FirstLoad) QueryDirectorKeys								= CreateArray(32);
		if (QueryDirectorValues == INVALID_HANDLE || !b_FirstLoad) QueryDirectorValues								= CreateArray(32);
		if (QueryDirectorSection == INVALID_HANDLE || !b_FirstLoad) QueryDirectorSection							= CreateArray(32);
		if (FirstDirectorKeys == INVALID_HANDLE || !b_FirstLoad) FirstDirectorKeys								= CreateArray(32);
		if (FirstDirectorValues == INVALID_HANDLE || !b_FirstLoad) FirstDirectorValues								= CreateArray(32);
		if (FirstDirectorSection == INVALID_HANDLE || !b_FirstLoad) FirstDirectorSection							= CreateArray(32);
		if (PlayerAbilitiesName == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesName								= CreateArray(32);
		if (a_DirectorActions == INVALID_HANDLE || !b_FirstLoad) a_DirectorActions								= CreateArray(3);
		if (a_DirectorActions_Cooldown == INVALID_HANDLE || !b_FirstLoad) a_DirectorActions_Cooldown						= CreateArray(32);
		if (LockedTalentKeys == INVALID_HANDLE || !b_FirstLoad) LockedTalentKeys							= CreateArray(32);
		if (LockedTalentValues == INVALID_HANDLE || !b_FirstLoad) LockedTalentValues						= CreateArray(32);
		if (LockedTalentSection == INVALID_HANDLE || !b_FirstLoad) LockedTalentSection						= CreateArray(32);
		if (Give_Store_Keys == INVALID_HANDLE || !b_FirstLoad) Give_Store_Keys							= CreateArray(32);
		if (Give_Store_Values == INVALID_HANDLE || !b_FirstLoad) Give_Store_Values							= CreateArray(32);
		if (Give_Store_Section == INVALID_HANDLE || !b_FirstLoad) Give_Store_Section							= CreateArray(32);
		if (a_WeaponDamages == INVALID_HANDLE || !b_FirstLoad) a_WeaponDamages = CreateArray(32);
		if (a_CommonAffixes == INVALID_HANDLE || !b_FirstLoad) a_CommonAffixes = CreateArray(32);
		if (CommonList == INVALID_HANDLE || !b_FirstLoad) CommonList = CreateArray(32);
		if (WitchList == INVALID_HANDLE || !b_FirstLoad) WitchList				= CreateArray(32);
		if (CommonAffixes == INVALID_HANDLE || !b_FirstLoad) CommonAffixes	= CreateArray(32);
		if (h_CAKeys == INVALID_HANDLE || !b_FirstLoad) h_CAKeys = CreateArray(32);
		if (h_CAValues == INVALID_HANDLE || !b_FirstLoad) h_CAValues = CreateArray(32);
		if (SearchKey_Section == INVALID_HANDLE || !b_FirstLoad) SearchKey_Section = CreateArray(32);
		if (CCASection == INVALID_HANDLE || !b_FirstLoad) CCASection = CreateArray(32);
		if (CCAKeys == INVALID_HANDLE || !b_FirstLoad) CCAKeys = CreateArray(32);
		if (CCAValues == INVALID_HANDLE || !b_FirstLoad) CCAValues = CreateArray(32);
		if (h_CommonKeys == INVALID_HANDLE || !b_FirstLoad) h_CommonKeys = CreateArray(32);
		if (h_CommonValues == INVALID_HANDLE || !b_FirstLoad) h_CommonValues = CreateArray(32);
		if (CommonInfected == INVALID_HANDLE || !b_FirstLoad) CommonInfected = CreateArray(32);
		if (EntityOnFire == INVALID_HANDLE || !b_FirstLoad) EntityOnFire = CreateArray(32);
		if (EntityOnFireName == INVALID_HANDLE || !b_FirstLoad) EntityOnFireName = CreateArray(32);
		if (CommonDrawKeys == INVALID_HANDLE || !b_FirstLoad) CommonDrawKeys = CreateArray(32);
		if (CommonDrawValues == INVALID_HANDLE || !b_FirstLoad) CommonDrawValues = CreateArray(32);
		if (ItemDropArray == INVALID_HANDLE || !b_FirstLoad) ItemDropArray = CreateArray(32);
		if (PreloadKeys == INVALID_HANDLE || !b_FirstLoad) PreloadKeys = CreateArray(32);
		if (PreloadValues == INVALID_HANDLE || !b_FirstLoad) PreloadValues = CreateArray(32);
		if (ItemDropKeys == INVALID_HANDLE || !b_FirstLoad) ItemDropKeys = CreateArray(32);
		if (ItemDropValues == INVALID_HANDLE || !b_FirstLoad) ItemDropValues = CreateArray(32);
		if (ItemDropSection == INVALID_HANDLE || !b_FirstLoad) ItemDropSection = CreateArray(32);
		if (persistentCirculation == INVALID_HANDLE || !b_FirstLoad) persistentCirculation = CreateArray(32);
		if (RandomSurvivorClient == INVALID_HANDLE || !b_FirstLoad) RandomSurvivorClient = CreateArray(32);
		if (RoundStatistics == INVALID_HANDLE || !b_FirstLoad) RoundStatistics = CreateArray(16);
		if (EffectOverTime == INVALID_HANDLE || !b_FirstLoad) EffectOverTime = CreateArray(32);
		if (TimeOfEffectOverTime == INVALID_HANDLE || !b_FirstLoad) TimeOfEffectOverTime = CreateArray(32);
		if (StaggeredTargets == INVALID_HANDLE || !b_FirstLoad) StaggeredTargets = CreateArray(32);
		if (CommonInfectedHealth == INVALID_HANDLE || !b_FirstLoad) CommonInfectedHealth = CreateArray(32);
		if (SetNodesKeys == INVALID_HANDLE || !b_FirstLoad) SetNodesKeys = CreateArray(32);
		if (SetNodesValues == INVALID_HANDLE || !b_FirstLoad) SetNodesValues = CreateArray(32);
		
		for (new i = 1; i <= MAXPLAYERS; i++) {
			LastDeathTime[i] = 0.0;
			MyVomitChase[i] = -1;
			b_IsFloating[i] = false;
			DisplayActionBar[i] = false;
			ActionBarSlot[i] = -1;
			if (currentEquippedWeapon[i] == INVALID_HANDLE || !b_FirstLoad) currentEquippedWeapon[i] = CreateTrie();
			if (GetCategoryStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetCategoryStrengthKeys[i] = CreateArray(32);
			if (GetCategoryStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) GetCategoryStrengthValues[i] = CreateArray(32);
			if (GetCategoryStrengthSection[i] == INVALID_HANDLE || !b_FirstLoad) GetCategoryStrengthSection[i] = CreateArray(32);
			//if (GCMKeys[i] == INVALID_HANDLE || !b_FirstLoad) GCMKeys[i] = CreateArray(32);
			//if (GCMValues[i] == INVALID_HANDLE || !b_FirstLoad) GCMValues[i] = CreateArray(32);
			if (PassiveStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) PassiveStrengthKeys[i] = CreateArray(32);
			if (PassiveStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) PassiveStrengthValues[i] = CreateArray(32);
			if (PassiveTalentName[i] == INVALID_HANDLE || !b_FirstLoad) PassiveTalentName[i] = CreateArray(32);
			if (UpgradeCategoryKeys[i] == INVALID_HANDLE || !b_FirstLoad) UpgradeCategoryKeys[i] = CreateArray(32);
			if (UpgradeCategoryValues[i] == INVALID_HANDLE || !b_FirstLoad) UpgradeCategoryValues[i] = CreateArray(32);
			if (UpgradeCategoryName[i] == INVALID_HANDLE || !b_FirstLoad) UpgradeCategoryName[i] = CreateArray(32);
			if (TranslationOTNKeys[i] == INVALID_HANDLE || !b_FirstLoad) TranslationOTNKeys[i] = CreateArray(32);
			if (TranslationOTNValues[i] == INVALID_HANDLE || !b_FirstLoad) TranslationOTNValues[i] = CreateArray(32);
			if (TranslationOTNSection[i] == INVALID_HANDLE || !b_FirstLoad) TranslationOTNSection[i] = CreateArray(32);
			if (GCVKeys[i] == INVALID_HANDLE || !b_FirstLoad) GCVKeys[i] = CreateArray(32);
			if (GCVValues[i] == INVALID_HANDLE || !b_FirstLoad) GCVValues[i] = CreateArray(32);
			if (GCVSection[i] == INVALID_HANDLE || !b_FirstLoad) GCVSection[i] = CreateArray(32);
			if (hWeaponList[i] == INVALID_HANDLE || !b_FirstLoad) hWeaponList[i] = CreateArray(32);
			if (LoadoutConfigKeys[i] == INVALID_HANDLE || !b_FirstLoad) LoadoutConfigKeys[i] = CreateArray(32);
			if (LoadoutConfigValues[i] == INVALID_HANDLE || !b_FirstLoad) LoadoutConfigValues[i] = CreateArray(32);
			if (LoadoutConfigSection[i] == INVALID_HANDLE || !b_FirstLoad) LoadoutConfigSection[i] = CreateArray(32);
			if (ActiveStatuses[i] == INVALID_HANDLE || !b_FirstLoad) ActiveStatuses[i] = CreateArray(32);
			if (AbilityConfigKeys[i] == INVALID_HANDLE || !b_FirstLoad) AbilityConfigKeys[i] = CreateArray(32);
			if (AbilityConfigValues[i] == INVALID_HANDLE || !b_FirstLoad) AbilityConfigValues[i] = CreateArray(32);
			if (AbilityConfigSection[i] == INVALID_HANDLE || !b_FirstLoad) AbilityConfigSection[i] = CreateArray(32);
			if (GetAbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityKeys[i] = CreateArray(32);
			if (GetAbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityValues[i] = CreateArray(32);
			if (GetAbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilitySection[i] = CreateArray(32);
			if (IsAbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) IsAbilityKeys[i] = CreateArray(32);
			if (IsAbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) IsAbilityValues[i] = CreateArray(32);
			if (IsAbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) IsAbilitySection[i] = CreateArray(32);
			if (CheckAbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) CheckAbilityKeys[i] = CreateArray(32);
			if (CheckAbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) CheckAbilityValues[i] = CreateArray(32);
			if (CheckAbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) CheckAbilitySection[i] = CreateArray(32);
			if (GetTalentStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentStrengthKeys[i] = CreateArray(32);
			if (GetTalentStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentStrengthValues[i] = CreateArray(32);
			if (CastKeys[i] == INVALID_HANDLE || !b_FirstLoad) CastKeys[i] = CreateArray(32);
			if (CastValues[i] == INVALID_HANDLE || !b_FirstLoad) CastValues[i] = CreateArray(32);
			if (CastSection[i] == INVALID_HANDLE || !b_FirstLoad) CastSection[i] = CreateArray(32);
			if (ActionBar[i] == INVALID_HANDLE || !b_FirstLoad) ActionBar[i] = CreateArray(32);
			if (TalentsAssignedKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentsAssignedKeys[i] = CreateArray(32);
			if (TalentsAssignedValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentsAssignedValues[i] = CreateArray(32);
			if (CartelValueKeys[i] == INVALID_HANDLE || !b_FirstLoad) CartelValueKeys[i] = CreateArray(32);
			if (CartelValueValues[i] == INVALID_HANDLE || !b_FirstLoad) CartelValueValues[i] = CreateArray(32);
			if (LegitClassSection[i] == INVALID_HANDLE || !b_FirstLoad) LegitClassSection[i] = CreateArray(32);
			if (TalentActionKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentActionKeys[i] = CreateArray(32);
			if (TalentActionValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentActionValues[i] = CreateArray(32);
			if (TalentActionSection[i] == INVALID_HANDLE || !b_FirstLoad) TalentActionSection[i] = CreateArray(32);
			if (TalentExperienceKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentExperienceKeys[i] = CreateArray(32);
			if (TalentExperienceValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentExperienceValues[i] = CreateArray(32);
			if (TalentTreeKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentTreeKeys[i] = CreateArray(32);
			if (TalentTreeValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentTreeValues[i] = CreateArray(32);
			if (TheLeaderboards[i] == INVALID_HANDLE || !b_FirstLoad) TheLeaderboards[i] = CreateArray(32);
			if (TheLeaderboardsData[i] == INVALID_HANDLE || !b_FirstLoad) TheLeaderboardsData[i] = CreateArray(32);
			if (TankState_Array[i] == INVALID_HANDLE || !b_FirstLoad) TankState_Array[i] = CreateArray(32);
			if (PlayerInventory[i] == INVALID_HANDLE || !b_FirstLoad) PlayerInventory[i] = CreateArray(32);
			if (PlayerEquipped[i] == INVALID_HANDLE || !b_FirstLoad) PlayerEquipped[i] = CreateArray(32);
			if (MenuStructure[i] == INVALID_HANDLE || !b_FirstLoad) MenuStructure[i] = CreateArray(32);
			if (TempAttributes[i] == INVALID_HANDLE || !b_FirstLoad) TempAttributes[i] = CreateArray(32);
			if (TempTalents[i] == INVALID_HANDLE || !b_FirstLoad) TempTalents[i] = CreateArray(32);
			if (PlayerProfiles[i] == INVALID_HANDLE || !b_FirstLoad) PlayerProfiles[i] = CreateArray(32);
			if (SpecialAmmoEffectKeys[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoEffectKeys[i] = CreateArray(32);
			if (SpecialAmmoEffectValues[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoEffectValues[i] = CreateArray(32);
			if (ActiveAmmoCooldownKeys[i] == INVALID_HANDLE || !b_FirstLoad) ActiveAmmoCooldownKeys[i] = CreateArray(32);
			if (ActiveAmmoCooldownValues[i] == INVALID_HANDLE || !b_FirstLoad) ActiveAmmoCooldownValues[i] = CreateArray(32);
			if (PlayActiveAbilities[i] == INVALID_HANDLE || !b_FirstLoad) PlayActiveAbilities[i] = CreateArray(32);
			if (PlayerActiveAmmo[i] == INVALID_HANDLE || !b_FirstLoad) PlayerActiveAmmo[i] = CreateArray(32);
			if (SpecialAmmoKeys[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoKeys[i] = CreateArray(32);
			if (SpecialAmmoValues[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoValues[i] = CreateArray(32);
			if (SpecialAmmoSection[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoSection[i] = CreateArray(32);
			if (DrawSpecialAmmoKeys[i] == INVALID_HANDLE || !b_FirstLoad) DrawSpecialAmmoKeys[i] = CreateArray(32);
			if (DrawSpecialAmmoValues[i] == INVALID_HANDLE || !b_FirstLoad) DrawSpecialAmmoValues[i] = CreateArray(32);
			if (SpecialAmmoStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoStrengthKeys[i] = CreateArray(32);
			if (SpecialAmmoStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoStrengthValues[i] = CreateArray(32);
			if (WeaponLevel[i] == INVALID_HANDLE || !b_FirstLoad) WeaponLevel[i] = CreateArray(32);
			if (ExperienceBank[i] == INVALID_HANDLE || !b_FirstLoad) ExperienceBank[i] = CreateArray(32);
			if (MenuPosition[i] == INVALID_HANDLE || !b_FirstLoad) MenuPosition[i] = CreateArray(32);
			if (IsClientInRangeSAKeys[i] == INVALID_HANDLE || !b_FirstLoad) IsClientInRangeSAKeys[i] = CreateArray(32);
			if (IsClientInRangeSAValues[i] == INVALID_HANDLE || !b_FirstLoad) IsClientInRangeSAValues[i] = CreateArray(32);
			if (InfectedAuraKeys[i] == INVALID_HANDLE || !b_FirstLoad) InfectedAuraKeys[i] = CreateArray(32);
			if (InfectedAuraValues[i] == INVALID_HANDLE || !b_FirstLoad) InfectedAuraValues[i] = CreateArray(32);
			if (InfectedAuraSection[i] == INVALID_HANDLE || !b_FirstLoad) InfectedAuraSection[i] = CreateArray(32);
			if (TalentUpgradeKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentUpgradeKeys[i] = CreateArray(32);
			if (TalentUpgradeValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentUpgradeValues[i] = CreateArray(32);
			if (TalentUpgradeSection[i] == INVALID_HANDLE || !b_FirstLoad) TalentUpgradeSection[i] = CreateArray(32);
			if (InfectedHealth[i] == INVALID_HANDLE || 	!b_FirstLoad) InfectedHealth[i] = CreateArray(32);
			if (WitchDamage[i] == INVALID_HANDLE || !b_FirstLoad) WitchDamage[i]	= CreateArray(32);
			if (SpecialCommon[i] == INVALID_HANDLE || !b_FirstLoad) SpecialCommon[i] = CreateArray(32);
			if (MenuKeys[i] == INVALID_HANDLE || !b_FirstLoad) MenuKeys[i]								= CreateArray(32);
			if (MenuValues[i] == INVALID_HANDLE || !b_FirstLoad) MenuValues[i]							= CreateArray(32);
			if (MenuSection[i] == INVALID_HANDLE || !b_FirstLoad) MenuSection[i]							= CreateArray(32);
			if (TriggerKeys[i] == INVALID_HANDLE || !b_FirstLoad) TriggerKeys[i]							= CreateArray(32);
			if (TriggerValues[i] == INVALID_HANDLE || !b_FirstLoad) TriggerValues[i]						= CreateArray(32);
			if (TriggerSection[i] == INVALID_HANDLE || !b_FirstLoad) TriggerSection[i]						= CreateArray(32);
			if (AbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) AbilityKeys[i]							= CreateArray(32);
			if (AbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) AbilityValues[i]						= CreateArray(32);
			if (AbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) AbilitySection[i]						= CreateArray(32);
			if (ChanceKeys[i] == INVALID_HANDLE || !b_FirstLoad) ChanceKeys[i]							= CreateArray(32);
			if (ChanceValues[i] == INVALID_HANDLE || !b_FirstLoad) ChanceValues[i]							= CreateArray(32);
			if (PurchaseKeys[i] == INVALID_HANDLE || !b_FirstLoad) PurchaseKeys[i]						= CreateArray(32);
			if (PurchaseValues[i] == INVALID_HANDLE || !b_FirstLoad) PurchaseValues[i]						= CreateArray(32);
			if (ChanceSection[i] == INVALID_HANDLE || !b_FirstLoad) ChanceSection[i]						= CreateArray(32);
			if (a_Database_PlayerTalents[i] == INVALID_HANDLE || !b_FirstLoad) a_Database_PlayerTalents[i]				= CreateArray(32);
			if (a_Database_PlayerTalents_Experience[i] == INVALID_HANDLE || !b_FirstLoad) a_Database_PlayerTalents_Experience[i] = CreateArray(32);
			if (PlayerAbilitiesCooldown[i] == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesCooldown[i]				= CreateArray(32);
			if (acdrKeys[i] == INVALID_HANDLE || !b_FirstLoad) acdrKeys[i] = CreateArray(32);
			if (acdrValues[i] == INVALID_HANDLE || !b_FirstLoad) acdrValues[i] = CreateArray(32);
			if (acdrSection[i] == INVALID_HANDLE || !b_FirstLoad) acdrSection[i] = CreateArray(32);
			if (GetLayerStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetLayerStrengthKeys[i] = CreateArray(32);
			if (GetLayerStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) GetLayerStrengthValues[i] = CreateArray(32);
			if (GetLayerStrengthSection[i] == INVALID_HANDLE || !b_FirstLoad) GetLayerStrengthSection[i] = CreateArray(32);
			if (a_Store_Player[i] == INVALID_HANDLE || !b_FirstLoad) a_Store_Player[i]						= CreateArray(32);
			if (StoreKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreKeys[i]							= CreateArray(32);
			if (StoreValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreValues[i]							= CreateArray(32);
			if (StoreMultiplierKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreMultiplierKeys[i]					= CreateArray(32);
			if (StoreMultiplierValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreMultiplierValues[i]				= CreateArray(32);
			if (StoreTimeKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreTimeKeys[i]						= CreateArray(32);
			if (StoreTimeValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreTimeValues[i]						= CreateArray(32);
			if (LoadStoreSection[i] == INVALID_HANDLE || !b_FirstLoad) LoadStoreSection[i]						= CreateArray(32);
			if (SaveSection[i] == INVALID_HANDLE || !b_FirstLoad) SaveSection[i]							= CreateArray(32);
			if (StoreChanceKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreChanceKeys[i]						= CreateArray(32);
			if (StoreChanceValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreChanceValues[i]					= CreateArray(32);
			if (StoreItemNameSection[i] == INVALID_HANDLE || !b_FirstLoad) StoreItemNameSection[i]					= CreateArray(32);
			if (StoreItemSection[i] == INVALID_HANDLE || !b_FirstLoad) StoreItemSection[i]						= CreateArray(32);
			if (TrailsKeys[i] == INVALID_HANDLE || !b_FirstLoad) TrailsKeys[i]							= CreateArray(32);
			if (TrailsValues[i] == INVALID_HANDLE || !b_FirstLoad) TrailsValues[i]							= CreateArray(32);
			if (DamageKeys[i] == INVALID_HANDLE || !b_FirstLoad) DamageKeys[i]						= CreateArray(32);
			if (DamageValues[i] == INVALID_HANDLE || !b_FirstLoad) DamageValues[i]					= CreateArray(32);
			if (DamageSection[i] == INVALID_HANDLE || !b_FirstLoad) DamageSection[i]				= CreateArray(32);
			if (MOTKeys[i] == INVALID_HANDLE || !b_FirstLoad) MOTKeys[i] = CreateArray(32);
			if (MOTValues[i] == INVALID_HANDLE || !b_FirstLoad) MOTValues[i] = CreateArray(32);
			if (MOTSection[i] == INVALID_HANDLE || !b_FirstLoad) MOTSection[i] = CreateArray(32);
			if (BoosterKeys[i] == INVALID_HANDLE || !b_FirstLoad) BoosterKeys[i]							= CreateArray(32);
			if (BoosterValues[i] == INVALID_HANDLE || !b_FirstLoad) BoosterValues[i]						= CreateArray(32);
			if (RPGMenuPosition[i] == INVALID_HANDLE || !b_FirstLoad) RPGMenuPosition[i]						= CreateArray(32);
			if (h_KilledPosition_X[i] == INVALID_HANDLE || !b_FirstLoad) h_KilledPosition_X[i]				= CreateArray(32);
			if (h_KilledPosition_Y[i] == INVALID_HANDLE || !b_FirstLoad) h_KilledPosition_Y[i]				= CreateArray(32);
			if (h_KilledPosition_Z[i] == INVALID_HANDLE || !b_FirstLoad) h_KilledPosition_Z[i]				= CreateArray(32);
			if (MeleeKeys[i] == INVALID_HANDLE || !b_FirstLoad) MeleeKeys[i]						= CreateArray(32);
			if (MeleeValues[i] == INVALID_HANDLE || !b_FirstLoad) MeleeValues[i]					= CreateArray(32);
			if (MeleeSection[i] == INVALID_HANDLE || !b_FirstLoad) MeleeSection[i]					= CreateArray(32);
			if (RCAffixes[i] == INVALID_HANDLE || !b_FirstLoad) RCAffixes[i] = CreateArray(32);
			if (AKKeys[i] == INVALID_HANDLE || !b_FirstLoad) AKKeys[i]						= CreateArray(32);
			if (AKValues[i] == INVALID_HANDLE || !b_FirstLoad) AKValues[i]					= CreateArray(32);
			if (AKSection[i] == INVALID_HANDLE || !b_FirstLoad) AKSection[i]					= CreateArray(32);
			if (SurvivorsIgnored[i] == INVALID_HANDLE || !b_FirstLoad) SurvivorsIgnored[i] = CreateArray(32);
			if (MyGroup[i] == INVALID_HANDLE || !b_FirstLoad) MyGroup[i] = CreateArray(32);
			if (PlayerEffectOverTime[i] == INVALID_HANDLE || !b_FirstLoad) PlayerEffectOverTime[i] = CreateArray(32);
			if (PlayerEffectOverTimeEffects[i] == INVALID_HANDLE || !b_FirstLoad) PlayerEffectOverTimeEffects[i] = CreateArray(32);
			if (CheckEffectOverTimeKeys[i] == INVALID_HANDLE || !b_FirstLoad) CheckEffectOverTimeKeys[i] = CreateArray(32);
			if (CheckEffectOverTimeValues[i] == INVALID_HANDLE || !b_FirstLoad) CheckEffectOverTimeValues[i] = CreateArray(32);
			if (FormatEffectOverTimeKeys[i] == INVALID_HANDLE || !b_FirstLoad) FormatEffectOverTimeKeys[i] = CreateArray(32);
			if (FormatEffectOverTimeValues[i] == INVALID_HANDLE || !b_FirstLoad) FormatEffectOverTimeValues[i] = CreateArray(32);
			if (FormatEffectOverTimeSection[i] == INVALID_HANDLE || !b_FirstLoad) FormatEffectOverTimeSection[i] = CreateArray(32);
			if (CooldownEffectTriggerKeys[i] == INVALID_HANDLE || !b_FirstLoad) CooldownEffectTriggerKeys[i] = CreateArray(32);
			if (CooldownEffectTriggerValues[i] == INVALID_HANDLE || !b_FirstLoad) CooldownEffectTriggerValues[i] = CreateArray(32);
			if (IsSpellAnAuraKeys[i] == INVALID_HANDLE || !b_FirstLoad) IsSpellAnAuraKeys[i] = CreateArray(32);
			if (IsSpellAnAuraValues[i] == INVALID_HANDLE || !b_FirstLoad) IsSpellAnAuraValues[i] = CreateArray(32);
			if (CallAbilityCooldownTriggerKeys[i] == INVALID_HANDLE || !b_FirstLoad) CallAbilityCooldownTriggerKeys[i] = CreateArray(32);
			if (CallAbilityCooldownTriggerValues[i] == INVALID_HANDLE || !b_FirstLoad) CallAbilityCooldownTriggerValues[i] = CreateArray(32);
			if (CallAbilityCooldownTriggerSection[i] == INVALID_HANDLE || !b_FirstLoad) CallAbilityCooldownTriggerSection[i] = CreateArray(32);
			if (GetIfTriggerRequirementsMetKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetIfTriggerRequirementsMetKeys[i] = CreateArray(32);
			if (GetIfTriggerRequirementsMetValues[i] == INVALID_HANDLE || !b_FirstLoad) GetIfTriggerRequirementsMetValues[i] = CreateArray(32);
			if (GetIfTriggerRequirementsMetSection[i] == INVALID_HANDLE || !b_FirstLoad) GetIfTriggerRequirementsMetSection[i] = CreateArray(32);
			if (GAMKeys[i] == INVALID_HANDLE || !b_FirstLoad) GAMKeys[i] = CreateArray(32);
			if (GAMValues[i] == INVALID_HANDLE || !b_FirstLoad) GAMValues[i] = CreateArray(32);
			if (GAMSection[i] == INVALID_HANDLE || !b_FirstLoad) GAMSection[i] = CreateArray(32);
			if (GetGoverningAttributeKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetGoverningAttributeKeys[i] = CreateArray(32);
			if (GetGoverningAttributeValues[i] == INVALID_HANDLE || !b_FirstLoad) GetGoverningAttributeValues[i] = CreateArray(32);
			if (GetGoverningAttributeSection[i] == INVALID_HANDLE || !b_FirstLoad) GetGoverningAttributeSection[i] = CreateArray(32);
			if (WeaponResultKeys[i] == INVALID_HANDLE || !b_FirstLoad) WeaponResultKeys[i] = CreateArray(32);
			if (WeaponResultValues[i] == INVALID_HANDLE || !b_FirstLoad) WeaponResultValues[i] = CreateArray(32);
			if (WeaponResultSection[i] == INVALID_HANDLE || !b_FirstLoad) WeaponResultSection[i] = CreateArray(32);
			if (GetAbilityCooldownKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityCooldownKeys[i] = CreateArray(32);
			if (GetAbilityCooldownValues[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityCooldownValues[i] = CreateArray(32);
			if (GetAbilityCooldownSection[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityCooldownSection[i] = CreateArray(32);
			if (GetTalentValueSearchKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentValueSearchKeys[i] = CreateArray(32);
			if (GetTalentValueSearchValues[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentValueSearchValues[i] = CreateArray(32);
			if (GetTalentValueSearchSection[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentValueSearchSection[i] = CreateArray(32);
			if (GetTalentKeyValueKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentKeyValueKeys[i] = CreateArray(32);
			if (GetTalentKeyValueValues[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentKeyValueValues[i] = CreateArray(32);
			if (GetTalentKeyValueSection[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentKeyValueSection[i] = CreateArray(32);
			if (ApplyDebuffCooldowns[i] == INVALID_HANDLE || !b_FirstLoad) ApplyDebuffCooldowns[i] = CreateArray(32);
			if (TalentAtMenuPositionSection[i] == INVALID_HANDLE || !b_FirstLoad) TalentAtMenuPositionSection[i] = CreateArray(32);
		}

		if (!b_FirstLoad) b_FirstLoad = true;
		//LogMessage("AWAITING PARAMETERS");

		if (!b_ConfigsExecuted) {
			b_ConfigsExecuted = true;
			if (hExecuteConfig == INVALID_HANDLE) hExecuteConfig = CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(10.0, Timer_GetCampaignName, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	ReadyUp_NtvIsCampaignFinale();
	SetSurvivorsAliveHostname();
}

public ReadyUp_GetCampaignStatus(mapposition) {
	CurrentMapPosition = mapposition;
}

public OnMapStart() {
	iTopThreat = 0;
	// When the server restarts, for any reason, RPG will properly load.
	//if (!b_FirstLoad) OnMapStartFunc();
	// This can call more than once, and we only want it to fire once.
	// The variable resets to false when a map ends.
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel("models/infected/common_male_fallen_survivor.mdl", true);
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	PrecacheModel("models/infected/witch_bride.mdl", true);
	PrecacheModel("models/infected/witch.mdl", true);
	PrecacheModel("models/props_interiors/toaster.mdl", true);
	PrecacheSound(JETPACK_AUDIO, true);

	g_iSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_BeaconSprite = PrecacheModel("materials/sprites/halo01.vmt");
	b_IsActiveRound = false;
	MapRoundsPlayed = 0;
	b_IsCampaignComplete			= false;
	b_IsRoundIsOver					= true;
	b_IsCheckpointDoorStartOpened	= false;
	b_IsMissionFailed				= false;
	ClearArray(CommonInfected);
	ClearArray(CommonInfectedHealth);
	ClearArray(Handle:SpecialAmmoData);
	ClearArray(CommonAffixes);
	ClearArray(WitchList);
	ClearArray(EffectOverTime);
	ClearArray(TimeOfEffectOverTime);
	ClearArray(Handle:StaggeredTargets);
	GetCurrentMap(TheCurrentMap, sizeof(TheCurrentMap));
	Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "%srpg/%s.cfg", ConfigPathDirectory, TheCurrentMap);
	//LogMessage("CONFIG_MAIN DEFAULT: %s", CONFIG_MAIN);
	if (!FileExists(CONFIG_MAIN)) Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "rpg/config.cfg");
	else Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "rpg/%s.cfg", TheCurrentMap);
	SetConVarInt(FindConVar("director_no_death_check"), 1);
	SetConVarInt(FindConVar("sv_rescue_disabled"), 0);
	SetConVarInt(FindConVar("z_common_limit"), 0);	// there are no commons until the round starts in all game modes to give players a chance to move.
	CheckDifficulty();
	UnhookAll();
	SetSurvivorsAliveHostname();
}

stock ResetValues(client) {

	// Yep, gotta do this *properly*
	b_HasDeathLocation[client] = false;
}

public OnMapEnd() {
	if (b_IsActiveRound) b_IsActiveRound = false;
	for (new i = 1; i <= MaxClients; i++) {
		if (ISEXPLODE[i] != INVALID_HANDLE) {
			KillTimer(ISEXPLODE[i]);
			ISEXPLODE[i] = INVALID_HANDLE;
		}
	}
	ClearArray(Handle:NewUsersRound);
}

public Action:Timer_GetCampaignName(Handle:timer) {
	ReadyUp_NtvGetCampaignName();
	return Plugin_Stop;
}

public OnConfigsExecuted() {
	if (!b_ConfigsExecuted) {
		b_ConfigsExecuted = true;
		if (hExecuteConfig == INVALID_HANDLE) {
			hExecuteConfig = CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		CreateTimer(10.0, Timer_GetCampaignName, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock CheckGamemode() {
	decl String:TheGamemode[64];
	GetConVarString(g_Gamemode, TheGamemode, sizeof(TheGamemode));
	decl String:TheRequiredGamemode[64];
	GetConfigValue(TheRequiredGamemode, sizeof(TheRequiredGamemode), "gametype?");
	if (!StrEqual(TheRequiredGamemode, "-1") && !StrEqual(TheGamemode, TheRequiredGamemode, false)) {
		LogMessage("Gamemode did not match, changing to %s", TheRequiredGamemode);
		PrintToChatAll("Gamemode did not match, changing to %s", TheRequiredGamemode);
		SetConVarString(g_Gamemode, TheRequiredGamemode);
		decl String:TheMapname[64];
		GetCurrentMap(TheMapname, sizeof(TheMapname));
		ServerCommand("changelevel %s", TheMapname);
	}
}

public Action:Timer_ExecuteConfig(Handle:timer) {
	if (ReadyUp_NtvConfigProcessing() == 0) {
		// These are processed one-by-one in a defined-by-dependencies order, but you can place them here in any order you want.
		// I've placed them here in the order they load for uniformality.
		ReadyUp_ParseConfig(CONFIG_MAIN);
		ReadyUp_ParseConfig(CONFIG_EVENTS);
		ReadyUp_ParseConfig(CONFIG_MENUTALENTS);
		ReadyUp_ParseConfig(CONFIG_POINTS);
		ReadyUp_ParseConfig(CONFIG_STORE);
		ReadyUp_ParseConfig(CONFIG_TRAILS);
		ReadyUp_ParseConfig(CONFIG_MAINMENU);
		ReadyUp_ParseConfig(CONFIG_WEAPONS);
		ReadyUp_ParseConfig(CONFIG_PETS);
		ReadyUp_ParseConfig(CONFIG_COMMONAFFIXES);
		//ReadyUp_ParseConfig(CONFIG_CLASSNAMES);

		hExecuteConfig = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:Timer_AutoRes(Handle:timer) {
	if (b_IsCheckpointDoorStartOpened) return Plugin_Stop;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
			else if (IsIncapacitated(i)) ExecCheatCommand(i, "give", "health");
		}
	}
	return Plugin_Continue;
}

stock bool:AnyHumans() {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

public ReadyUp_ReadyUpStart() {
	CheckDifficulty();
	CheckGamemode();
	RoundTime = 0;
	b_IsRoundIsOver = true;
	iTopThreat = 0;
	SetSurvivorsAliveHostname();
	CreateTimer(1.0, Timer_AutoRes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	/*
	When a new round starts, we want to forget who was the last person to speak on different teams.
	*/
	Format(Public_LastChatUser, sizeof(Public_LastChatUser), "none");
	Format(Spectator_LastChatUser, sizeof(Spectator_LastChatUser), "none");
	Format(Survivor_LastChatUser, sizeof(Survivor_LastChatUser), "none");
	Format(Infected_LastChatUser, sizeof(Infected_LastChatUser), "none");
	new bool:TeleportPlayers = false;
	new Float:teleportIntoSaferoom[3];
	if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -300.968750;
		TeleportPlayers = true;
	}
	for (new i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			if (CurrentMapPosition == 0 && b_IsLoaded[i] && GetClientTeam(i) == TEAM_SURVIVOR) GiveProfileItems(i);
			//if (GetClientTeam(i) == TEAM_SURVIVOR) GiveProfileItems(i);
			if (TeleportPlayers) TeleportEntity(i, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
			//if (GetClientTeam(i) == TEAM_SURVIVOR && !b_IsLoaded[i]) IsClientLoadedEx(i);
			staggerCooldownOnTriggers[i] = false;
			ISBILED[i] = false;
			iThreatLevel[i] = 0;
			bIsEligibleMapAward[i] = true;
			HealingContribution[i] = 0;
			TankingContribution[i] = 0;
			DamageContribution[i] = 0;
			PointsContribution[i] = 0.0;
			HexingContribution[i] = 0;
			BuffingContribution[i] = 0;
			b_IsFloating[i] = false;
			ISDAZED[i] = 0.0;
			bIsInCombat[i] = false;
			b_IsInSaferoom[i] = true;
			// Anti-Farm/Anti-Camping system stuff.
			ClearArray(h_KilledPosition_X[i]);		// We clear all positions from the array.
			ClearArray(h_KilledPosition_Y[i]);
			ClearArray(h_KilledPosition_Z[i]);
			/*if (b_IsMissionFailed && GetClientTeam(i) == TEAM_SURVIVOR && IsFakeClient(i)) {

				if (!b_IsLoading[i]) {

					b_IsLoaded[i] = false;
					OnClientLoaded(i);
				}
			}*/
		}
	}
	RefreshSurvivorBots();
}

public ReadyUp_ReadyUpEnd() {
	ReadyUpEnd_Complete();
}

public Action:Timer_Defibrillator(Handle:timer, any:client) {

	if (IsLegitimateClient(client) && !IsPlayerAlive(client)) Defibrillator(0, client);
	return Plugin_Stop;
}

public ReadyUpEnd_Complete() {
	/*PrintToChatAll("DOor opened");
	b_IsCheckpointDoorStartOpened = true;
	b_IsActiveRound = true;*/
	if (b_IsRoundIsOver) {

		CheckDifficulty();
		b_IsMissionFailed = false;
		//if (ReadyUp_GetGameMode() == 3) {
		b_IsRoundIsOver = false;
		ClearArray(CommonInfected);
		ClearArray(CommonInfectedHealth);
		ClearArray(CommonAffixes);
			//b_IsSurvivalIntermission = true;
			//CreateTimer(5.0, Timer_AutoRes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//}
		//RoundTime					=	GetTime();
		b_IsCheckpointDoorStartOpened = false;
		for (new i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && IsFakeClient(i) && !b_IsLoaded[i]) IsClientLoadedEx(i);
		}

		if (iRoundStartWeakness == 1) {

			for (new i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
					staggerCooldownOnTriggers[i] = false;
					ISBILED[i] = false;
					bHasWeakness[i] = true;
					SurvivorEnrage[i][0] = 0.0;
					SurvivorEnrage[i][1] = 0.0;
					ISDAZED[i] = 0.0;
					if (b_IsLoaded[i]) {
						SurvivorStamina[i] = GetPlayerStamina(i) - 1;
						SetMaximumHealth(i);
					}
					else if (!b_IsLoading[i]) OnClientLoaded(i);
					//}
					bIsSurvivorFatigue[i] = false;
					LastWeaponDamage[i] = 1;
					HealingContribution[i] = 0;
					TankingContribution[i] = 0;
					DamageContribution[i] = 0;
					PointsContribution[i] = 0.0;
					HexingContribution[i] = 0;
					BuffingContribution[i] = 0;
					b_IsFloating[i] = false;
					bIsHandicapLocked[i] = false;
				}
			}
		}
	}
}

stock TimeUntilEnrage(String:TheText[], TheSize) {
	if (!IsEnrageActive()) {
		new Seconds = (iEnrageTime * 60) - (GetTime() - RoundTime);
		new Minutes = 0;
		while (Seconds >= 60) {
			Seconds -= 60;
			Minutes++;
		}
		if (Seconds == 0) {
			Format(TheText, TheSize, "%d minute", Minutes);
			if (Minutes > 1) Format(TheText, TheSize, "%ss", TheText);
		}
		else if (Minutes == 0) Format(TheText, TheSize, "%d seconds", Seconds);
		else {
			if (Minutes > 1) Format(TheText, TheSize, "%d minutes, %d seconds", Minutes, Seconds);
			else Format(TheText, TheSize, "%d minute, %d seconds", Minutes, Seconds);
		}
	}
	else Format(TheText, TheSize, "ACTIVE");
}

stock GetSecondsUntilEnrage() {
	new secondsLeftUntilEnrage = (iEnrageTime * 60) - (GetTime() - RoundTime);
	return secondsLeftUntilEnrage;
}

stock RPGRoundTime(bool:IsSeconds = false) {
	new Seconds = GetTime() - RoundTime;
	if (IsSeconds) return Seconds;
	new Minutes = 0;
	while (Seconds >= 60) {
		Minutes++;
		Seconds -= 60;
	}
	return Minutes;
}

stock bool:IsEnrageActive() {
	if (!b_IsActiveRound || IsSurvivalMode || iEnrageTime < 1) return false;
	if (RPGRoundTime() < iEnrageTime) return false;
	if (!IsEnrageNotified && iNotifyEnrage == 1) {
		IsEnrageNotified = true;
		PrintToChatAll("%t", "enrage period", orange, blue, orange);
	}
	return true;
}

stock bool:PlayerHasWeakness(client) {
	if (!IsLegitimateClientAlive(client)) return false;
	if (IsSpecialCommonInRange(client, 'w')) return true;
	if (IsClientInRangeSpecialAmmo(client, "W", true) == -2.0) return true;	// the player is not weak if inside cleansing ammo.*
	if (GetTalentStrengthByKeyValue(client, ACTIVATOR_ABILITY_EFFECTS, "weakness") > 0) return true;
	return false;
}

public ReadyUp_CheckpointDoorStartOpened() {
	if (!b_IsCheckpointDoorStartOpened) {
		b_IsCheckpointDoorStartOpened		= true;
		b_IsActiveRound = true;
		bIsSettingsCheck = true;
		IsEnrageNotified = false;
		b_IsFinaleTanks = false;
		for (new i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) ForcePlayerSuicide(i);
		}
		ClearArray(Handle:persistentCirculation);
		ClearArray(Handle:CoveredInVomit);
		ClearArray(RoundStatistics);
		ResizeArray(RoundStatistics, 5);
		for (new i = 0; i < 5; i++) {

			SetArrayCell(Handle:RoundStatistics, i, 0);
			if (CurrentMapPosition == 0) SetArrayCell(Handle:RoundStatistics, i, 0, 1);	// first map of campaign, reset the total.
		}
		decl String:pct[4];
		Format(pct, sizeof(pct), "%");
		new iMaxHandicap = 0;
		new iMinHandicap = RatingPerLevel;
		decl String:text[64];
		new survivorCounter = TotalHumanSurvivors();
		new bool:AnyBotsOnSurvivorTeam = BotsOnSurvivorTeam();
		for (new i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i)) {
				bIsMeleeCooldown[i] = false;
				if (!IsFakeClient(i)) {
					if (iTankRush == 1) RatingHandicap[i] = RatingPerLevel;
					else {
						iMaxHandicap = GetMaxHandicap(i);
						if (RatingHandicap[i] < iMinHandicap) RatingHandicap[i] = iMinHandicap;
						else if (RatingHandicap[i] > iMaxHandicap) RatingHandicap[i] = iMaxHandicap;
					}
					if (GroupMemberBonus > 0.0) {
						if (IsGroupMember[i]) PrintToChat(i, "%T", "group member bonus", i, blue, GroupMemberBonus * 100.0, pct, green, orange);
						else PrintToChat(i, "%T", "group member benefit", i, orange, blue, GroupMemberBonus * 100.0, pct, green, blue);
					}
					if (!AnyBotsOnSurvivorTeam && fSurvivorBotsNoneBonus > 0.0 && survivorCounter <= iSurvivorBotsBonusLimit) {
						PrintToChat(i, "%T", "group no survivor bots bonus", i, blue, fSurvivorBotsNoneBonus * 100.0, pct, green, orange);
					}
					if (RoundExperienceMultiplier[i] > 0.0) {
						PrintToChat(i, "%T", "survivalist bonus experience", i, blue, orange, green, RoundExperienceMultiplier[i] * 100.0, white, pct);
					}
				}
				else SetBotHandicap(i);
			}
		}
		if (CurrentMapPosition != 0 || ReadyUpGameMode == 3) CheckDifficulty();
		RoundTime					=	GetTime();
		new ent = -1;
		if (ReadyUpGameMode != 3) {
			while ((ent = FindEntityByClassname(ent, "witch")) != -1) {
				// Some maps, like Hard Rain pre-spawn a ton of witches - we want to add them to the witch table.
				OnWitchCreated(ent);
			}
		}
		else {
			IsSurvivalMode = true;
			for (new i = 1; i <= MaxClients; i++) {
				if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
					VerifyMinimumRating(i, true);
					RespawnImmunity[i] = false;
				}
			}
			// decl String:TheCurr[64];
			// GetCurrentMap(TheCurr, sizeof(TheCurr));
			// if (StrContains(TheCurr, "helms_deep", false) != -1) {
			// 	// the bot has to be teleported to the machine gun, because samurai blocks the teleportation in the actual map scripting
			// 	new Float:TeleportBots[3];
			// 	TeleportBots[0] = 1572.749146;
			// 	TeleportBots[1] = -871.468811;
			// 	TeleportBots[2] = 62.031250;
			// 	decl String:TheModel[64];
			// 	for (new i = 1; i <= MaxClients; i++) {
			// 		if (IsLegitimateClientAlive(i) && IsFakeClient(i)) {
			// 			GetClientModel(i, TheModel, sizeof(TheModel));
			// 			if (StrEqual(TheModel, LOUIS_MODEL)) TeleportEntity(i, TeleportBots, NULL_VECTOR, NULL_VECTOR);
			// 		}
			// 	}
			// 	PrintToChatAll("\x04Man the gun, Louis!");
			// }
		}
		b_IsCampaignComplete				= false;
		if (ReadyUpGameMode != 3) b_IsRoundIsOver						= false;
		if (ReadyUpGameMode == 2) MapRoundsPlayed = 0;	// Difficulty leniency does not occur in versus.
		SpecialsKilled				=	0;
		RoundDamageTotal			=	0;
		b_IsFinaleActive			=	false;
		decl String:thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "path setting?");
		if (ReadyUpGameMode != 3 && !StrEqual(thetext, "none")) {
			if (!StrEqual(thetext, "random")) ServerCommand("sm_forcepath %s", thetext);
			else {
				if (StrEqual(PathSetting, "none")) {
					new random = GetRandomInt(1, 100);
					if (random <= 33) Format(PathSetting, sizeof(PathSetting), "easy");
					else if (random <= 66) Format(PathSetting, sizeof(PathSetting), "medium");
					else Format(PathSetting, sizeof(PathSetting), "hard");
				}
				ServerCommand("sm_forcepath %s", PathSetting);
			}
		}
		for (new i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
				if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
				VerifyMinimumRating(i);
				HealImmunity[i] = false;
				if (b_IsLoaded[i]) GiveMaximumHealth(i);
				else if (!b_IsLoading[i]) OnClientLoaded(i);
			}
		}
		f_TankCooldown				=	-1.0;
		ResetCDImmunity(-1);
		DoomTimer = 0;
		if (ReadyUpGameMode != 2) {
			// It destroys itself when a round ends.
			if (fDirectorThoughtDelay > 0.0) CreateTimer(1.0, Timer_DirectorPurchaseTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (!bIsSoloHandicap && RespawnQueue > 0) CreateTimer(1.0, Timer_RespawnQueue, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		RaidInfectedBotLimit();
		CreateTimer(1.0, Timer_StartPlayerTimers, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_CheckIfHooked, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(GetConfigValueFloat("settings check interval?"), Timer_SettingsCheck, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (DoomSUrvivorsRequired != 0) CreateTimer(1.0, Timer_Doom, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Timer_EntityOnFire, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		// Fire status effect
		CreateTimer(1.0, Timer_ThreatSystem, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		// threat system modulator
		CreateTimer(fStaggerTickrate, Timer_StaggerTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(fDrawHudInterval, Timer_ShowHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(fSpecialAmmoInterval, Timer_ShowActionBar, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (GetConfigValueInt("common affixes?") > 0) {
			ClearArray(Handle:CommonAffixes);
			CreateTimer(1.0, Timer_CommonAffixes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		ClearRelevantData();
		LastLivingSurvivor = 1;
		new size = GetArraySize(a_DirectorActions);
		ResizeArray(a_DirectorActions_Cooldown, size);
		for (new i = 0; i < size; i++) SetArrayString(a_DirectorActions_Cooldown, i, "0");
		new theCount = LivingSurvivorCount();
		if (iSurvivorModifierRequired > 0 && fSurvivorExpMult > 0.0 && theCount >= iSurvivorModifierRequired) {
			PrintToChatAll("%t", "teammate bonus experience", blue, green, ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorExpMult) * 100.0, pct);
		}
		RefreshSurvivorBots();
		if (iResetDirectorPointsOnNewRound == 1) Points_Director = 0.0;
		if (iEnrageTime > 0) {
			TimeUntilEnrage(text, sizeof(text));
			PrintToChatAll("%t", "time until things get bad", orange, green, text, orange);
		}
	}
}

stock RefreshSurvivorBots() {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsSurvivorBot(i)) {
			//if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
			RefreshSurvivor(i);
		}
	}
}

stock SetClientMovementSpeed(client) {
	if (IsValidEntity(client)) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", fBaseMovementSpeed);
}

stock ResetCoveredInBile(client) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			CoveredInBile[client][i] = -1;
			CoveredInBile[i][client] = -1;
		}
	}
}

stock FindTargetClient(client, String:arg[]) {
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	new targetclient;
	if ((target_count = ProcessTargetString(
		arg,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) > 0)
	{
		for (new i = 0; i < target_count; i++) targetclient = target_list[i];
	}
	return targetclient;
}

stock CMD_CastAction(client, args) {
	decl String:actionpos[64];
	GetCmdArg(1, actionpos, sizeof(actionpos));
	if (StrContains(actionpos, acmd, false) != -1 && !StrEqual(abcmd, actionpos[1], false)) {
		CastActionEx(client, actionpos, sizeof(actionpos));
	}
}

stock CastActionEx(client, String:t_actionpos[] = "none", TheSize, pos = -1) {
	new ActionSlots = iActionBarSlots;
	decl String:actionpos[64];
	if (pos == -1) pos = StringToInt(t_actionpos[strlen(t_actionpos) - 1]) - 1;//StringToInt(actionpos[strlen(actionpos) - 1]);
	if (pos >= 0 && pos < ActionSlots) {
		//pos--;	// shift down 1 for the array.
		GetArrayString(Handle:ActionBar[client], pos, actionpos, sizeof(actionpos));
		if (IsTalentExists(actionpos)) { //PrintToChat(client, "%T", "Action Slot Empty", client, white, orange, blue, pos+1);
			new size =	GetArraySize(a_Menu_Talents);
			new RequiresTarget = 0;
			new AbilityTalent = 0;
			new Float:TargetPos[3];
			decl String:TalentName[64];
			new Float:visualDelayTime = 0.0;
			for (new i = 0; i < size; i++) {
				CastKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
				CastValues[client]			= GetArrayCell(a_Menu_Talents, i, 1);
				CastSection[client]			= GetArrayCell(a_Menu_Talents, i, 2);
				GetArrayString(Handle:CastSection[client], 0, TalentName, sizeof(TalentName));
				if (!StrEqual(TalentName, actionpos)) continue;
				AbilityTalent = GetKeyValueIntAtPos(CastValues[client], IS_TALENT_ABILITY);
				if (GetKeyValueIntAtPos(CastValues[client], ABILITY_PASSIVE_ONLY) == 1) continue;
				if (AbilityTalent != 1 && GetTalentStrength(client, actionpos) < 1) {
					// talent exists but user has no points in it from a respec or whatever so we remove it.
					// we don't tell them either, next time they use it they'll find out.
					Format(actionpos, TheSize, "none");
					SetArrayString(Handle:ActionBar[client], pos, actionpos);
				}
				else {
					RequiresTarget = GetKeyValueIntAtPos(CastValues[client], ABILITY_IS_SINGLE_TARGET);
					visualDelayTime = GetKeyValueFloatAtPos(CastValues[client], ABILITY_DRAW_DELAY);
					if (visualDelayTime < 1.0) visualDelayTime = 1.0;
					if (RequiresTarget > 0) {
						//GetClientAimTargetEx(client, actionpos, TheSize, true);
						RequiresTarget = GetAimTargetPosition(client, TargetPos);//StringToInt(actionpos);
						if (IsLegitimateClientAlive(RequiresTarget)) {
							if (AbilityTalent != 1) CastSpell(client, RequiresTarget, TalentName, TargetPos, visualDelayTime);
							else UseAbility(client, RequiresTarget, TalentName, CastKeys[client], CastValues[client], TargetPos);
						}
					}
					else {
						GetAimTargetPosition(client, TargetPos);
						/*GetClientAimTargetEx(client, actionpos, TheSize);
						ExplodeString(actionpos, " ", tTargetPos, 3, 64);
						TargetPos[0] = StringToFloat(tTargetPos[0]);
						TargetPos[1] = StringToFloat(tTargetPos[1]);
						TargetPos[2] = StringToFloat(tTargetPos[2]);*/
						if (AbilityTalent != 1) CastSpell(client, _, TalentName, TargetPos, visualDelayTime);
						else {
							CheckActiveAbility(client, pos, _, _, true, true);
							UseAbility(client, _, TalentName, CastKeys[client], CastValues[client], TargetPos);
						}
					}
				}
				break;
			}
		}
	}
	else {
		PrintToChat(client, "%T", "Action Slot Range", client, white, blue, ActionSlots, white);
	}
}

public Action:CMD_GetWeapon(client, args) {
	decl String:s[64];
	GetClientWeapon(client, s, sizeof(s));
	if (StrEqual(s, "weapon_melee")) {
		new iWeapon = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		iWeapon = GetEntDataEnt2(client, iWeapon);
		GetEntityClassname(iWeapon, s, sizeof(s));
		GetEntPropString(iWeapon, Prop_Data, "m_strMapSetScriptName", s, sizeof(s));
	}
	PrintToChat(client, "%s", s);
	return Plugin_Handled;
}

stock MySurvivorCompanion(client) {

	decl String:SteamId[64], String:CompanionSteamId[64];
	GetClientAuthString(client, SteamId, sizeof(SteamId));

	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsFakeClient(i)) {

			GetEntPropString(i, Prop_Data, "m_iName", CompanionSteamId, sizeof(CompanionSteamId));
			if (StrEqual(CompanionSteamId, SteamId, false)) return i;
		}
	}
	return -1;
}

public Action:CMD_CompanionOptions(client, args) {

	/*if (GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Handled;
	decl String:TheCommand[64], String:TheName[64], String:tquery[512], String:thetext[64], String:SteamId[64];
	GetCmdArg(1, TheCommand, sizeof(TheCommand));
	if (args > 1) {

		new companion = MySurvivorCompanion(client);

		if (companion == -1) {	// no companion active.

			if (StrEqual(TheCommand, "create", false)) {	// creates a companion.

				if (args == 2) {

					GetCmdArg(2, TheName, sizeof(TheName));
					ReplaceString(TheName, sizeof(TheName), "+", " ");

					Format(CompanionNameQueue[client], sizeof(CompanionNameQueue[]), "%s", TheName);
					GetClientAuthString(client, SteamId, sizeof(SteamId));

					Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE `companionowner` = '%s';", TheDBPrefix, SteamId);
					SQL_TQuery(hDatabase, Query_CheckCompanionCount, tquery, client);
				}
				else {

					GetConfigValue(thetext, sizeof(thetext), "companion command?");
					PrintToChat(client, "!%s create <name>", thetext);
				}
			}
			else if (StrEqual(TheCommand, "load", false)) {	// opens the comapnion load menu.

			}
		}
		else {	// player has a companion active.

			if (StrEqual(TheCommand, "delete", false)) {	// we delete the companion.

			}
			else if (StrEqual(TheCommand, "edit", false)) {	// opens the talent menu for the companion.

			}
			else if (StrEqual(TheCommand, "save", false)) {	// saves the companion, you should always do this before loading a new one.

			}
		}
	}
	else {

		// display the available commands to the user.
	}*/
	return Plugin_Handled;
}

public Action:CMD_TogglePvP(client, args) {
	new TheTime = RoundToCeil(GetEngineTime());
	if (IsPvP[client] != 0) {
		if (IsPvP[client] + 30 <= TheTime) {
			IsPvP[client] = 0;
			PrintToChat(client, "%T", "PvP Disabled", client, white, orange);
		}
	}
	else {
		IsPvP[client] = TheTime + 30;
		PrintToChat(client, "%T", "PvP Enabled", client, white, blue);
	}
	return Plugin_Handled;
}

public Action:CMD_GiveLevel(client, args) {
	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "give player level flags?");
	if ((HasCommandAccess(client, thetext) || client == 0) && args > 1) {
		decl String:arg[512], String:arg2[64], String:arg3[64];
		GetCmdArg(1, arg, sizeof(arg));
		GetCmdArg(2, arg2, sizeof(arg2));
		GetCmdArg(3, arg3, sizeof(arg3));
		new targetclient = 0;
		new bool:hasSTEAM = (StrContains(arg, "STEAM", true) != -1) ? true : false;
		if (!hasSTEAM) targetclient = FindTargetClient(client, arg);
		if (args < 3 || hasSTEAM) {
			if (hasSTEAM) {
				decl String:tquery[512];
				Format(steamIdSearch[client], 64, "%s%s", serverKey, arg);
				PrintToChat(client, "looking up %s to see if it exists...", steamIdSearch[client]);
				Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, steamIdSearch[client]);
				//Format(steamIdSearch[client], 64, "%s", arg2);
				levelToSet[client] = StringToInt(arg2);
				if (levelToSet[client] > iMaxLevel) levelToSet[client] = iMaxLevel;
				SQL_TQuery(hDatabase, Query_FindDataAndApplyChange, tquery, client);
			}
			else {
				if (IsLegitimateClient(targetclient) && PlayerLevel[targetclient] != StringToInt(arg2)) {

					SetTotalExperienceByLevel(targetclient, StringToInt(arg2));
					decl String:Name[64];
					GetClientName(targetclient, Name, sizeof(Name));
					PrintToChatAll("%t", "client level set", Name, green, white, blue, PlayerLevel[targetclient]);
					FormatPlayerName(targetclient);
				}
			}
		}
		else {
			if (IsLegitimateClient(targetclient)) {
				if (StrContains(arg3, "rating", false) != -1) Rating[targetclient] = StringToInt(arg2);
				else ModifyCartelValue(targetclient, arg3, StringToInt(arg2));
			}
		}
	}
	return Plugin_Handled;
}

stock GetExperienceRequirement(newlevel) {
	new Float:fExpMult = fExperienceMultiplier * (newlevel - 1);
	return iExperienceStart + RoundToCeil(iExperienceStart * fExpMult);
}

stock CheckExperienceRequirement(client, bool:bot = false, iLevel = 0) {
	new experienceRequirement = 0;
	if (IsLegitimateClient(client)) {
		experienceRequirement			=	iExperienceStart;
		new Float:experienceMultiplier	=	0.0;
		if (iLevel == 0) experienceMultiplier		=	fExperienceMultiplier * (PlayerLevel[client] - 1);
		else experienceMultiplier 					=	fExperienceMultiplier * (iLevel - 1);
		experienceRequirement			=	iExperienceStart + RoundToCeil(iExperienceStart * experienceMultiplier);
	}
	return experienceRequirement;
}

stock GetPlayerLevel(client) {
	new iExperienceOverall = ExperienceOverall[client];
	new iLevel = 1;
	new ExperienceRequirement = CheckExperienceRequirement(client, false, iLevel);
	while (iExperienceOverall >= ExperienceRequirement && iLevel < iMaxLevel) {
		if (iIsLevelingPaused[client] == 1 && iExperienceOverall == ExperienceRequirement) break;
		iExperienceOverall -= ExperienceRequirement;
		iLevel++;
		ExperienceRequirement = CheckExperienceRequirement(client, false, iLevel);
	}
	return iLevel;
}

stock GetTotalExperienceByLevel(newlevel) {
	new experienceTotal = 0;
	if (newlevel > iMaxLevel) newlevel = iMaxLevel;
	for (new i = 1; i <= newlevel; i++) {
		if (newlevel == i) break;
		experienceTotal += GetExperienceRequirement(i);
	}
	experienceTotal++;
	return experienceTotal;
}

stock SetTotalExperienceByLevel(client, newlevel, bool:giveMaxXP = false) {

	new oldlevel = PlayerLevel[client];
	ExperienceOverall[client] = 0;
	ExperienceLevel[client] = 0;
	if (newlevel > iMaxLevel) newlevel = iMaxLevel;
	PlayerLevel[client] = newlevel;
	for (new i = 1; i <= newlevel; i++) {

		if (newlevel == i) break;
		ExperienceOverall[client] += CheckExperienceRequirement(client, false, i);
	}

	ExperienceOverall[client]++;
	ExperienceLevel[client]++;	// i don't like 0 / level, so i always do 1 / level as the minimum.
	if (giveMaxXP) ExperienceOverall[client] = CheckExperienceRequirement(client, false, iMaxLevel);
	if (oldlevel > PlayerLevel[client]) ChallengeEverything(client);
	else if (PlayerLevel[client] > oldlevel) {
		FreeUpgrades[client] += (PlayerLevel[client] - oldlevel);
	}
}

public Action:CMD_ReloadConfigs(client, args) {

	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "reload configs flags?");

	if (HasCommandAccess(client, thetext)) {

		CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		PrintToChat(client, "Reloading Config.");
	}

	return Plugin_Handled;
}

public ReadyUp_FirstClientLoaded() {

	//CreateTimer(1.0, Timer_ShowHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	OnMapStartFunc();
	RefreshSurvivorBots();
	ReadyUpGameMode = ReadyUp_GetGameMode();
}

public Action:CMD_SharePoints(client, args) {

	if (args < 2) {

		decl String:thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "reload configs flags?");

		PrintToChat(client, "%T", "Share Points Syntax", client, orange, white, thetext);
		return Plugin_Handled;
	}

	decl String:arg[MAX_NAME_LENGTH], String:arg2[10];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	new Float:SharePoints = 0.0;
	if (StrContains(arg2, ".", false) == -1) SharePoints = StringToInt(arg2) * 1.0;
	else SharePoints = StringToFloat(arg2);

	if (SharePoints > Points[client]) return Plugin_Handled;

	new targetclient = FindTargetClient(client, arg);
	if (!IsLegitimateClient(targetclient)) return Plugin_Handled;

	decl String:Name[MAX_NAME_LENGTH];
	GetClientName(targetclient, Name, sizeof(Name));
	decl String:GiftName[MAX_NAME_LENGTH];
	GetClientName(client, GiftName, sizeof(GiftName));

	Points[client] -= SharePoints;
	Points[targetclient] += SharePoints;

	PrintToChatAll("%t", "Share Points Given", blue, GiftName, white, green, SharePoints, white, blue, Name); 
	return Plugin_Handled;
}

stock GetMaxHandicap(client) {

	new iMaxHandicap = RatingPerHandicap;
	iMaxHandicap *= CartelLevel(client);
	iMaxHandicap += RatingPerLevel;

	return iMaxHandicap;
}

stock VerifyHandicap(client) {

	new iMaxHandicap = GetMaxHandicap(client);
	new iMinHandicap = RatingPerLevel;

	if (RatingHandicap[client] < iMinHandicap) RatingHandicap[client] = iMinHandicap;
	if (RatingHandicap[client] > iMaxHandicap) RatingHandicap[client] = iMaxHandicap;
}

public Action:CMD_Handicap(client, args) {
	if (iIsRatingEnabled != 1) return Plugin_Handled;
	new iMaxHandicap = GetMaxHandicap(client);
	new iMinHandicap = RatingPerLevel;
	if (RatingHandicap[client] < iMinHandicap) RatingHandicap[client] = iMinHandicap;
	if (RatingHandicap[client] > iMaxHandicap) RatingHandicap[client] = iMaxHandicap;
	if (args < 1) {

		PrintToChat(client, "%T", "handicap range", client, white, orange, iMinHandicap, white, orange, iMaxHandicap);
	}
	else {
		if (!bIsHandicapLocked[client]) {
			decl String:arg[10];
			GetCmdArg(1, arg, sizeof(arg));
			new iSetHandicap = StringToInt(arg);
			if (iSetHandicap >= iMinHandicap && iSetHandicap <= iMaxHandicap) {
				RatingHandicap[client] = iSetHandicap;
			}
			else if (iSetHandicap < iMinHandicap) RatingHandicap[client] = iMinHandicap;
			else if (iSetHandicap > iMaxHandicap) RatingHandicap[client] = iMaxHandicap;
		}
		else {
			PrintToChat(client, "%T", "player handicap locked", client, orange);
		}
	}

	PrintToChat(client, "%T", "player handicap", client, blue, orange, green, RatingHandicap[client]);
	return Plugin_Handled;
}

stock SetBotHandicap(client) {
	if (IsSurvivorBot(client)) {
		new iLowHandicap = RatingPerLevelSurvivorBots;
		for (new i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
			if (RatingHandicap[i] > iLowHandicap) iLowHandicap = RatingHandicap[i];
		}
		RatingHandicap[client] = iLowHandicap;
	}
	return RatingHandicap[client];
}

public Action:CMD_ActionBar(client, args) {
	if (!DisplayActionBar[client]) {
		PrintToChat(client, "%T", "action bar displayed", client, white, blue);
		DisplayActionBar[client] = true;
	}
	else {
		PrintToChat(client, "%T", "action bar hidden", client, white, orange);
		DisplayActionBar[client] = false;
		ActionBarSlot[client] = -1;
	}
	return Plugin_Handled;
}

public Action:CMD_GiveStorePoints(client, args) {
	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "give store points flags?");
	if (!HasCommandAccess(client, thetext)) { PrintToChat(client, "You don't have access."); return Plugin_Handled; }
	if (args < 2) {
		PrintToChat(client, "%T", "Give Store Points Syntax", client, orange, white);
		return Plugin_Handled;
	}
	decl String:arg[MAX_NAME_LENGTH], String:arg2[4];
	GetCmdArg(1, arg, sizeof(arg));
	if (args > 1) {
		GetCmdArg(2, arg2, sizeof(arg2));
	}
	new targetclient = FindTargetClient(client, arg);
	decl String:Name[MAX_NAME_LENGTH];
	GetClientName(targetclient, Name, sizeof(Name));
	SkyPoints[targetclient] += StringToInt(arg2);
	PrintToChat(client, "%T", "Store Points Award Given", client, white, green, arg2, white, orange, Name);
	PrintToChat(targetclient, "%T", "Store Points Award Received", client, white, green, arg2, white);
	return Plugin_Handled;
}

public ReadyUp_CampaignComplete() {
	if (!b_IsCampaignComplete) {
		b_IsCampaignComplete			= true;
		CallRoundIsOver();
		WipeDebuffs(true);
	}
}

public Action:CMD_MyWeapon(client, args){
	decl String:myWeapon[64];
	GetWeaponName(client, myWeapon, sizeof(myWeapon));
	PrintToChat(client, "%s", myWeapon);
	return Plugin_Handled;
}
public Action:CMD_CollectBonusExperience(client, args) {
	/*if (CurrentMapPosition != 0 && RoundExperienceMultiplier[client] > 0.0 && BonusContainer[client] > 0 && !b_IsActiveRound) {
		new RewardWaiting = RoundToCeil(BonusContainer[client] * RoundExperienceMultiplier[client]);
		ExperienceLevel[client] += RewardWaiting;
		ExperienceOverall[client] += RewardWaiting;
		decl String:Name[64];
		GetClientName(client, Name, sizeof(Name));
		PrintToChatAll("%t", "collected bonus container", blue, Name, white, green, blue, AddCommasToString(RewardWaiting));
		BonusContainer[client] = 0;
		RoundExperienceMultiplier[client] = 0.0;
		ConfirmExperienceAction(client);
	}*/

	return Plugin_Handled;
}

public ReadyUp_RoundIsOver(gamemode) {
	CallRoundIsOver();
}

/*public Action:Timer_SaveAndClear(Handle:timer) {
	new LivingSurvs = TotalHumanSurvivors();
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		if (GetClientTeam(i) == TEAM_INFECTED && IsFakeClient(i)) continue;	// infected bots are skipped.
		//ToggleTank(i, true);
		if (b_IsMissionFailed && LivingSurvs > 0 && GetClientTeam(i) == TEAM_SURVIVOR) {
			RoundExperienceMultiplier[i] = 0.0;
			// So, the round ends due a failed mission, whether it's coop or survival, and we reset all players ratings.
			VerifyMinimumRating(i, true);
		}
		if(iChaseEnt[i] && EntRefToEntIndex(iChaseEnt[i]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[i], "Kill");
		iChaseEnt[i] = -1;
		SaveAndClear(i);
	}
	return Plugin_Stop;
}*/

stock CallRoundIsOver() {
	if (!b_IsRoundIsOver) {
		for (new i = 0; i < 5; i++) {
			SetArrayCell(Handle:RoundStatistics, i, GetArrayCell(RoundStatistics, i) + GetArrayCell(RoundStatistics, i, 1), 1);
		}
		new pEnt = -1;
		decl String:pText[2][64];
		decl String:text[64];
		new pSize = GetArraySize(persistentCirculation);
		for (new i = 0; i < pSize; i++) {
			GetArrayString(persistentCirculation, i, text, sizeof(text));
			ExplodeString(text, ":", pText, 2, 64);
			pEnt = StringToInt(pText[0]);
			if (IsValidEntity(pEnt)) AcceptEntityInput(pEnt, "Kill");
		}
		ClearArray(persistentCirculation);
		b_IsRoundIsOver					= true;
		for (new i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i)) bTimersRunning[i] = false;
		}
		if (b_IsActiveRound) b_IsActiveRound = false;
		SetSurvivorsAliveHostname();
		new Seconds			= GetTime() - RoundTime;
		new Minutes			= 0;
		while (Seconds >= 60) {
			Minutes++;
			Seconds -= 60;
		}
		//common is 0
		//super is 1
		//witch is 2
		//si is 3
		//tank is 4
		decl String:roundStatisticsText[6][64];
		PrintToChatAll("%t", "Round Time", orange, blue, Minutes, white, blue, Seconds, white);
		if (CurrentMapPosition != 1 || ReadyUp_GetGameMode() == 3) {
			AddCommasToString(GetArrayCell(RoundStatistics, 0), roundStatisticsText[0], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 1), roundStatisticsText[1], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 2), roundStatisticsText[2], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 3), roundStatisticsText[3], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 4), roundStatisticsText[4], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 0) + GetArrayCell(RoundStatistics, 1) + GetArrayCell(RoundStatistics, 2) + GetArrayCell(RoundStatistics, 3) + GetArrayCell(RoundStatistics, 4), roundStatisticsText[5], sizeof(roundStatisticsText[]));

			PrintToChatAll("%t", "round statistics", orange, orange, blue,
							roundStatisticsText[0], orange, blue,
							roundStatisticsText[1], orange, blue,
							roundStatisticsText[2], orange, blue,
							roundStatisticsText[3], orange, blue,
							roundStatisticsText[4], orange, green,
							roundStatisticsText[5], green, green);
		}
		else {
			AddCommasToString(GetArrayCell(RoundStatistics, 0, 1), roundStatisticsText[0], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 1, 1), roundStatisticsText[1], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 2, 1), roundStatisticsText[2], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 3, 1), roundStatisticsText[3], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 4, 1), roundStatisticsText[4], sizeof(roundStatisticsText[]));
			AddCommasToString(GetArrayCell(RoundStatistics, 0, 1) + GetArrayCell(RoundStatistics, 1, 1) + GetArrayCell(RoundStatistics, 2, 1) + GetArrayCell(RoundStatistics, 3, 1) + GetArrayCell(RoundStatistics, 4, 1), roundStatisticsText[5], sizeof(roundStatisticsText[]));

			PrintToChatAll("%t", "campaign statistics", orange, orange, blue,
							roundStatisticsText[0], orange, blue,
							roundStatisticsText[1], orange, blue,
							roundStatisticsText[2], orange, blue,
							roundStatisticsText[3], orange, blue,
							roundStatisticsText[4], orange, green,
							roundStatisticsText[5], green, green);
		}
		if (!b_IsMissionFailed) {
			//InfectedLevel = HumanSurvivorLevels();
			if (!IsSurvivalMode) {
				new livingSurvs = LivingSurvivors() - 1;
				new Float:fRoundExperienceBonus = (livingSurvs > 0) ? fCoopSurvBon * livingSurvs : 0.0;
				decl String:pct[4];
				Format(pct, sizeof(pct), "%");
				if (fRoundExperienceBonus > 0.0) PrintToChatAll("%t", "living survivors experience bonus", orange, blue, orange, white, blue, fRoundExperienceBonus * 100.0, white, pct, orange);
				for (new i = 1; i <= MaxClients; i++) {
					if (IsLegitimateClient(i)) {
						ClearArray(WitchDamage[i]);
						ClearArray(InfectedHealth[i]);
						ClearArray(SpecialCommon[i]);
						ImmuneToAllDamage[i] = false;
						iThreatLevel[i] = 0;
						bIsInCombat[i] = false;
						fSlowSpeed[i] = 1.0;
						if (GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i)) {
							if (Rating[i] < 0 && CurrentMapPosition != 1) VerifyMinimumRating(i);
							if (RoundExperienceMultiplier[i] < 0.0) RoundExperienceMultiplier[i] = 0.0;
							if (CurrentMapPosition != 1) {

								if (fRoundExperienceBonus > 0.0) RoundExperienceMultiplier[i] += fRoundExperienceBonus;
								//PrintToChat(i, "xp bonus of %3.3f added : %3.3f bonus", fCoopSurvBon, RoundExperienceMultiplier[i]);
 							}
							//else PrintToChat(i, "no round bonus applied.");
							AwardExperience(i, _, _, true);
						}
					}
				}
			}
		}

		new humanSurvivorsInGame = TotalHumanSurvivors();
		// only save data on round end if there is at least 1 human on the survivor team.
		// rounds will constantly loop if the survivor team is all bots.
		if (humanSurvivorsInGame > 0) {
			for (new i = 1; i <= MaxClients; i++) {
				if (!IsLegitimateClient(i)) continue;
				if (GetClientTeam(i) == TEAM_INFECTED && IsFakeClient(i)) continue;	// infected bots are skipped.
				//ToggleTank(i, true);
				if (b_IsMissionFailed) {
					if (GetClientTeam(i) == TEAM_SURVIVOR) {
						RoundExperienceMultiplier[i] = 0.0;
						// So, the round ends due a failed mission, whether it's coop or survival, and we reset all players ratings.
						//VerifyMinimumRating(i, true);
						// reduce player ratings by the amount it would go down if they died, when they lose the round.
						//Rating[i] = RoundToCeil(Rating[i] * (1.0 - fRatingPercentLostOnDeath)) + 1;
					}
					//if(IsValidEntity(iChaseEnt[i]) && iChaseEnt[i] > 0 && EntRefToEntIndex(iChaseEnt[i]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[i], "Kill");
					//iChaseEnt[i] = -1;
				}
				/*if (iChaseEnt[i] > 0 && IsValidEntity(iChaseEnt[i])) {
					AcceptEntityInput(iChaseEnt[i], "Kill");
					iChaseEnt[i] = -1;
				}*/
				SavePlayerData(i);
			}
		}
		//CreateTimer(1.0, Timer_SaveAndClear, _, TIMER_FLAG_NO_MAPCHANGE);
		b_IsCheckpointDoorStartOpened	= false;
		RemoveImmunities(-1);
		ClearArray(Handle:LoggedUsers);		// when a round ends, logged users are removed.
		b_IsActiveRound = false;
		MapRoundsPlayed++;
		ClearArray(CommonInfected);
		ClearArray(WitchList);
		ClearArray(CommonList);
		ClearArray(EntityOnFire);
		ClearArray(EntityOnFireName);
		ClearArray(CommonInfectedQueue);
		ClearArray(SuperCommonQueue);
		ClearArray(StaggeredTargets);
		ClearArray(CommonInfectedHealth);
		ClearArray(SpecialAmmoData);
		ClearArray(CommonAffixes);
		ClearArray(EffectOverTime);
		ClearArray(TimeOfEffectOverTime);
		if (b_IsMissionFailed && StrContains(TheCurrentMap, "zerowarn", false) != -1) {
			PrintToChatAll("\x04Due to VScripts issue, this map must be restarted to prevent a server crash.");
			LogMessage("Restarting %s map to avoid VScripts crash.", TheCurrentMap);
			// need to force-teleport players here on new spawn: 4087.998291 11974.557617 -269.968750
			CreateTimer(5.0, Timer_ResetMap, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

// we need to check the zombie class since the way I create special infected, they have the same team as survivors.
bool:IsValidZombieClass(client) {	// 9 for survivor
	new zombieclass = GetEntProp(client, Prop_Send, "m_zombieClass");
	if (zombieclass >= 1 && zombieclass <= 8) return true;
	return false;
}

public Action:Timer_ResetMap(Handle:timer) {
	if (StrContains(TheCurrentMap, "helms", false) != -1) ForceServerCommand("scenario_end");
	ServerCommand("changelevel %s", TheCurrentMap);
	return Plugin_Stop;
}

stock ResetArray(Handle:TheArray) {

	ClearArray(Handle:TheArray);
}

public ReadyUp_ParseConfigFailed(String:config[], String:error[]) {

	if (StrEqual(config, CONFIG_MAIN) ||
		StrEqual(config, CONFIG_EVENTS) ||
		StrEqual(config, CONFIG_MENUTALENTS) ||
		StrEqual(config, CONFIG_MAINMENU) ||
		StrEqual(config, CONFIG_POINTS) ||
		StrEqual(config, CONFIG_STORE) ||
		StrEqual(config, CONFIG_TRAILS) ||
		StrEqual(config, CONFIG_WEAPONS) ||
		StrEqual(config, CONFIG_PETS) ||
		StrEqual(config, CONFIG_COMMONAFFIXES)) {// ||
		//StrEqual(config, CONFIG_CLASSNAMES)) {

		SetFailState("%s , %s", config, error);
	}
}

public ReadyUp_LoadFromConfigEx(Handle:key, Handle:value, Handle:section, String:configname[], keyCount) {
	//PrintToChatAll("Size: %d config: %s", GetArraySize(Handle:key), configname);
	if (!StrEqual(configname, CONFIG_MAIN) &&
		!StrEqual(configname, CONFIG_EVENTS) &&
		!StrEqual(configname, CONFIG_MENUTALENTS) &&
		!StrEqual(configname, CONFIG_MAINMENU) &&
		!StrEqual(configname, CONFIG_POINTS) &&
		!StrEqual(configname, CONFIG_STORE) &&
		!StrEqual(configname, CONFIG_TRAILS) &&
		!StrEqual(configname, CONFIG_WEAPONS) &&
		!StrEqual(configname, CONFIG_PETS) &&
		!StrEqual(configname, CONFIG_COMMONAFFIXES)) return;// &&
		//!StrEqual(configname, CONFIG_CLASSNAMES)) return;
	decl String:s_key[512];
	decl String:s_value[512];
	decl String:s_section[512];
	new Handle:TalentKeys		=					CreateArray(32);
	new Handle:TalentValues		=					CreateArray(32);
	new Handle:TalentSection	=					CreateArray(32);
	new lastPosition = 0;
	new counter = 0;
	if (keyCount > 0) {
		if (StrEqual(configname, CONFIG_MENUTALENTS)) ResizeArray(a_Menu_Talents, keyCount);
		else if (StrEqual(configname, CONFIG_MAINMENU)) ResizeArray(a_Menu_Main, keyCount);
		else if (StrEqual(configname, CONFIG_EVENTS)) ResizeArray(a_Events, keyCount);
		else if (StrEqual(configname, CONFIG_POINTS)) ResizeArray(a_Points, keyCount);
		else if (StrEqual(configname, CONFIG_PETS)) ResizeArray(a_Pets, keyCount);
		else if (StrEqual(configname, CONFIG_STORE)) ResizeArray(a_Store, keyCount);
		else if (StrEqual(configname, CONFIG_TRAILS)) ResizeArray(a_Trails, keyCount);
		else if (StrEqual(configname, CONFIG_WEAPONS)) ResizeArray(a_WeaponDamages, keyCount);
		else if (StrEqual(configname, CONFIG_COMMONAFFIXES)) ResizeArray(a_CommonAffixes, keyCount);
		//else if (StrEqual(configname, CONFIG_CLASSNAMES)) ResizeArray(a_Classnames, keyCount);
	}
	new a_Size						= GetArraySize(key);
	for (new i = 0; i < a_Size; i++) {
		GetArrayString(Handle:key, i, s_key, sizeof(s_key));
		GetArrayString(Handle:value, i, s_value, sizeof(s_value));
		PushArrayString(TalentKeys, s_key);
		PushArrayString(TalentValues, s_value);

		if (StrEqual(configname, CONFIG_MAIN)) {

			PushArrayString(Handle:MainKeys, s_key);
			PushArrayString(Handle:MainValues, s_value);
			if (StrEqual(s_key, "rpg mode?")) {

				CurrentRPGMode = StringToInt(s_value);
				LogMessage("=====\t\tRPG MODE SET TO %d\t\t=====", CurrentRPGMode);
			}
		}

		if (StrEqual(s_key, "EOM")) {

			GetArrayString(Handle:section, i, s_section, sizeof(s_section));
			PushArrayString(TalentSection, s_section);

			if (StrEqual(configname, CONFIG_MENUTALENTS)) SetConfigArrays(configname, a_Menu_Talents, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Menu_Talents), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_MAINMENU)) SetConfigArrays(configname, a_Menu_Main, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Menu_Main), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_EVENTS)) SetConfigArrays(configname, a_Events, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Events), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_POINTS)) SetConfigArrays(configname, a_Points, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Points), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_PETS)) SetConfigArrays(configname, a_Pets, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Pets), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_STORE)) SetConfigArrays(configname, a_Store, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Store), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_TRAILS)) SetConfigArrays(configname, a_Trails, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Trails), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_WEAPONS)) SetConfigArrays(configname, a_WeaponDamages, TalentKeys, TalentValues, TalentSection, GetArraySize(a_WeaponDamages), lastPosition - counter);
			else if (StrEqual(configname, CONFIG_COMMONAFFIXES)) SetConfigArrays(configname, a_CommonAffixes, TalentKeys, TalentValues, TalentSection, GetArraySize(a_CommonAffixes), lastPosition - counter);
			//else if (StrEqual(configname, CONFIG_CLASSNAMES)) SetConfigArrays(configname, a_Classnames, TalentKeys, TalentValues, TalentSection, GetArraySize(a_Classnames), lastPosition - counter);
			
			lastPosition = i + 1;
		}
	}
	//CloseHandle(TalentKeys);
	//CloseHandle(TalentValues);
	//CloseHandle(TalentSection);

	if (StrEqual(configname, CONFIG_POINTS)) {

		if (a_DirectorActions != INVALID_HANDLE) ClearArray(a_DirectorActions);
		a_DirectorActions			=	CreateArray(3);
		if (a_DirectorActions_Cooldown != INVALID_HANDLE) ClearArray(a_DirectorActions_Cooldown);
		a_DirectorActions_Cooldown	=	CreateArray(32);

		new size						=	GetArraySize(a_Points);
		new Handle:Keys					=	CreateArray(32);
		new Handle:Values				=	CreateArray(32);
		new Handle:Section				=	CreateArray(32);
		
		new sizer						=	0;

		for (new i = 0; i < size; i++) {

			Keys						=	GetArrayCell(a_Points, i, 0);
			Values						=	GetArrayCell(a_Points, i, 1);
			Section						=	GetArrayCell(a_Points, i, 2);

			new size2					=	GetArraySize(Keys);
			for (new ii = 0; ii < size2; ii++) {

				GetArrayString(Handle:Keys, ii, s_key, sizeof(s_key));
				GetArrayString(Handle:Values, ii, s_value, sizeof(s_value));

				if (StrEqual(s_key, "model?")) PrecacheModel(s_value, false);
				else if (StrEqual(s_key, "director option?") && StrEqual(s_value, "1")) {

					sizer				=	GetArraySize(a_DirectorActions);

					ResizeArray(a_DirectorActions, sizer + 1);
					SetArrayCell(a_DirectorActions, sizer, Keys, 0);
					SetArrayCell(a_DirectorActions, sizer, Values, 1);
					SetArrayCell(a_DirectorActions, sizer, Section, 2);
					ResizeArray(a_DirectorActions_Cooldown, sizer + 1);
					SetArrayString(a_DirectorActions_Cooldown, sizer, "0");						// 0 means not on cooldown. 1 means on cooldown. This resets every map.
				}
			}
		}
		/*
		CloseHandle(Keys);
		CloseHandle(Values);
		CloseHandle(Section);*/
		// We only attempt connection to the database in the instance that there are no open connections.
		//if (hDatabase == INVALID_HANDLE) {

		//	MySQL_Init();
		//}
	}

	decl String:thetext[64];
	if (StrEqual(configname, CONFIG_MAIN) && !b_IsFirstPluginLoad) {
		b_IsFirstPluginLoad = true;
		if (hDatabase == INVALID_HANDLE) {

			MySQL_Init();
		}
		
		LoadMainConfig();
		RegConsoleCmd("getwep", CMD_GetWeapon);
		GetConfigValue(RPGMenuCommand, sizeof(RPGMenuCommand), "rpg menu command?");
		RPGMenuCommandExplode = GetDelimiterCount(RPGMenuCommand, ",") + 1;
		GetConfigValue(thetext, sizeof(thetext), "drop weapon command?");
		RegConsoleCmd(thetext, CMD_DropWeapon);
		GetConfigValue(thetext, sizeof(thetext), "director talent command?");
		RegConsoleCmd(thetext, CMD_DirectorTalentToggle);
		GetConfigValue(thetext, sizeof(thetext), "rpg data erase?");
		RegConsoleCmd(thetext, CMD_DataErase);
		GetConfigValue(thetext, sizeof(thetext), "rpg bot data erase?");
		RegConsoleCmd(thetext, CMD_DataEraseBot);
		//GetConfigValue(thetext, sizeof(thetext), "give store points command?");
		//RegConsoleCmd(thetext, CMD_GiveStorePoints);
		GetConfigValue(thetext, sizeof(thetext), "give level command?");
		RegConsoleCmd(thetext, CMD_GiveLevel);
		GetConfigValue(thetext, sizeof(thetext), "share points command?");
		RegConsoleCmd(thetext, CMD_SharePoints);
		GetConfigValue(thetext, sizeof(thetext), "buy menu command?");
		RegConsoleCmd(thetext, CMD_BuyMenu);
		GetConfigValue(thetext, sizeof(thetext), "abilitybar menu command?");
		RegConsoleCmd(thetext, CMD_ActionBar);
		//RegConsoleCmd("collect", CMD_CollectBonusExperience);
		RegConsoleCmd("myweapon", CMD_MyWeapon);
		GetConfigValue(thetext, sizeof(thetext), "companion command?");
		RegConsoleCmd(thetext, CMD_CompanionOptions);
		GetConfigValue(thetext, sizeof(thetext), "load profile command?");
		RegConsoleCmd(thetext, CMD_LoadProfileEx);
		//RegConsoleCmd("backpack", CMD_Backpack);
		//etConfigValue(thetext, sizeof(thetext), "rpg data force save?");
		//RegConsoleCmd(thetext, CMD_SaveData);
	}
	if (StrEqual(configname, CONFIG_EVENTS)) SubmitEventHooks(1);
	ReadyUp_NtvGetHeader();
	if (StrEqual(configname, CONFIG_MAIN)) {
		GetConfigValue(thetext, sizeof(thetext), "item drop model?");
		PrecacheModel(thetext, true);
		GetConfigValue(thetext, sizeof(thetext), "backpack model?");
		PrecacheModel(thetext, true);
	}
	/*

		We need to preload an array full of all the positions of item drops.
		Faster than searching every time.
	*/
	if (StrEqual(configname, CONFIG_MENUTALENTS)) {
		ClearArray(ItemDropArray);
		new mySize = GetArraySize(a_Menu_Talents);
		new curSize= -1;
		new pos = 0;
		for (new i = 0; i <= iRarityMax; i++) {
			for (new j = 0; j < mySize; j++) {
				//PreloadKeys				= GetArrayCell(a_Menu_Talents, j, 0);
				PreloadValues			= GetArrayCell(a_Menu_Talents, j, 1);
				if (GetKeyValueIntAtPos(PreloadValues, ITEM_ITEM_ID) != 1) continue;
				//PushArrayCell(ItemDropArray, i);
				if (GetKeyValueIntAtPos(PreloadValues, ITEM_RARITY) != i) continue;
				curSize = GetArraySize(ItemDropArray);
				if (pos == curSize) ResizeArray(ItemDropArray, curSize + 1);
				SetArrayCell(ItemDropArray, pos, j, i);
				pos++;
			}
			if (i == 0) Format(ItemDropArraySize, sizeof(ItemDropArraySize), "%d", pos);
			else Format(ItemDropArraySize, sizeof(ItemDropArraySize), "%s,%d", ItemDropArraySize, pos);
			pos = 0;
		}
	}
}
/*
	These specific variables can be called the same way, every time, so we declare them globally.
	These are all from the config.cfg (main config file)
	We don't load other variables in this way because they are dynamically loaded and unloaded.
*/
stock LoadMainConfig() {
	GetConVarString(FindConVar("z_difficulty"), sServerDifficulty, sizeof(sServerDifficulty));
	if (strlen(sServerDifficulty) < 4) GetConfigValue(sServerDifficulty, sizeof(sServerDifficulty), "server difficulty?");
	fProficiencyExperienceMultiplier 	= GetConfigValueFloat("proficiency requirement multiplier?");
	fProficiencyExperienceEarned 		= GetConfigValueFloat("experience multiplier proficiency?");
	fRatingPercentLostOnDeath			= GetConfigValueFloat("rating percentage lost on death?");
	//iProficiencyMaxLevel				= GetConfigValueInt("proficience level max?");
	iProficiencyStart					= GetConfigValueInt("proficiency level start?");
	iTeamRatingRequired					= GetConfigValueInt("team count rating bonus?");
	fTeamRatingBonus					= GetConfigValueFloat("team player rating bonus?");
	iTanksPreset						= GetConfigValueInt("preset tank type on spawn?");
	iSurvivorRespawnRestrict			= GetConfigValueInt("respawn queue players ignored?");
	iIsRatingEnabled					= GetConfigValueInt("handicap enabled?");
	iIsSpecialFire						= GetConfigValueInt("special infected fire?");
	iSkyLevelMax						= GetConfigValueInt("max sky level?");
	//iOnFireDebuffLimit				= GetConfigValueInt("standing in fire debuff limit?");
	fOnFireDebuffDelay					= GetConfigValueFloat("standing in fire debuff delay?");
	//fTankThreatBonus					= GetConfigValueFloat("tank threat bonus?");
	forceProfileOnNewPlayers			= GetConfigValueInt("Force Profile On New Player?");
	iShowLockedTalents					= GetConfigValueInt("show locked talents?");
	iAwardBroadcast						= GetConfigValueInt("award broadcast?");
	GetConfigValue(loadProfileOverrideFlags, sizeof(loadProfileOverrideFlags), "profile override flags?");
	GetConfigValue(sSpecialsAllowed, sizeof(sSpecialsAllowed), "special infected classes?");
	iSpecialsAllowed					= GetConfigValueInt("special infected allowed?");
	iSpecialInfectedMinimum				= GetConfigValueInt("special infected minimum?");
	fEnrageMultiplier					= GetConfigValueFloat("enrage multiplier?");
	iRestedDonator						= GetConfigValueInt("rested experience earned donator?");
	iRestedRegular						= GetConfigValueInt("rested experience earned non-donator?");
	iRestedSecondsRequired				= GetConfigValueInt("rested experience required seconds?");
	iRestedMaximum						= GetConfigValueInt("rested experience maximum?");
	iFriendlyFire						= GetConfigValueInt("friendly fire enabled?");
	GetConfigValue(sDonatorFlags, sizeof(sDonatorFlags), "donator package flag?");
	GetConfigValue(sProfileLoadoutConfig, sizeof(sProfileLoadoutConfig), "profile loadout config?");
	iHardcoreMode						= GetConfigValueInt("hardcore mode?");
	fDeathPenalty						= GetConfigValueFloat("death penalty?");
	iDeathPenaltyPlayers				= GetConfigValueInt("death penalty players required?");
	iTankRush							= GetConfigValueInt("tank rush?");
	iTanksAlways						= GetConfigValueInt("tanks always active?");
	iTanksAlwaysEnforceCooldown 		= GetConfigValueInt("tanks always enforce cooldown?");
	fSprintSpeed						= GetConfigValueFloat("sprint speed?");
	iRPGMode							= GetConfigValueInt("rpg mode?");
	DirectorWitchLimit					= GetConfigValueInt("director witch limit?");
	fCommonQueueLimit					= GetConfigValueFloat("common queue limit?");
	fDirectorThoughtDelay				= GetConfigValueFloat("director thought process delay?");
	fDirectorThoughtHandicap			= GetConfigValueFloat("director thought process handicap?");
	fDirectorThoughtProcessMinimum		= GetConfigValueFloat("director thought process minimum?");
	iSurvivalRoundTime					= GetConfigValueInt("survival round time?");
	fDazedDebuffEffect					= GetConfigValueFloat("dazed debuff effect?");
	ConsumptionInt						= GetConfigValueInt("stamina consumption interval?");
	fStamSprintInterval					= GetConfigValueFloat("stamina sprint interval?");
	fStamRegenTime						= GetConfigValueFloat("stamina regeneration time?");
	fStamRegenTimeAdren					= GetConfigValueFloat("stamina regeneration time adren?");
	fBaseMovementSpeed					= GetConfigValueFloat("base movement speed?");
	fFatigueMovementSpeed				= GetConfigValueFloat("fatigue movement speed?");
	iPlayerStartingLevel				= GetConfigValueInt("new player starting level?");
	iBotPlayerStartingLevel				= GetConfigValueInt("new bot player starting level?");
	fOutOfCombatTime					= GetConfigValueFloat("out of combat time?");
	iWitchDamageInitial					= GetConfigValueInt("witch damage initial?");
	fWitchDamageScaleLevel				= GetConfigValueFloat("witch damage scale level?");
	fSurvivorDamageBonus				= GetConfigValueFloat("survivor damage bonus?");
	fSurvivorHealthBonus				= GetConfigValueFloat("survivor health bonus?");
	iSurvivorModifierRequired			= GetConfigValueInt("survivor modifier requirement?");
	iEnrageTime							= GetConfigValueInt("enrage time?");
	fWitchDirectorPoints				= GetConfigValueFloat("witch director points?");
	fEnrageDirectorPoints				= GetConfigValueFloat("enrage director points?");
	fCommonDamageLevel					= GetConfigValueFloat("common damage scale level?");
	iBotLevelType						= GetConfigValueInt("infected bot level type?");
	fCommonDirectorPoints				= GetConfigValueFloat("common infected director points?");
	iDisplayHealthBars					= GetConfigValueInt("display health bars?");
	iMaxDifficultyLevel					= GetConfigValueInt("max difficulty level?");
	scoreRequiredForLeaderboard			= GetConfigValueInt("player score required for leaderboard?");
	decl String:text[64], String:text2[64], String:text3[64], String:text4[64];
	for (new i = 0; i < 7; i++) {
		if (i == 6) {
			Format(text, sizeof(text), "(%d) damage player level?", i + 2);
			Format(text2, sizeof(text2), "(%d) infected health bonus", i + 2);
			Format(text3, sizeof(text3), "(%d) base damage?", i + 2);
			Format(text4, sizeof(text4), "(%d) base infected health?", i + 2);
		}
		else {
			Format(text, sizeof(text), "(%d) damage player level?", i + 1);
			Format(text2, sizeof(text2), "(%d) infected health bonus", i + 1);
			Format(text3, sizeof(text3), "(%d) base damage?", i + 1);
			Format(text4, sizeof(text4), "(%d) base infected health?", i + 1);
		}
		fDamagePlayerLevel[i]			= GetConfigValueFloat(text);
		fHealthPlayerLevel[i]			= GetConfigValueFloat(text2);
		iBaseSpecialDamage[i]			= GetConfigValueInt(text3);
		iBaseSpecialInfectedHealth[i]	= GetConfigValueInt(text4);
	}
	fAcidDamagePlayerLevel				= GetConfigValueFloat("acid damage spitter player level?");
	fAcidDamageSupersPlayerLevel		= GetConfigValueFloat("acid damage supers player level?");
	fPointsMultiplierInfected			= GetConfigValueFloat("points multiplier infected?");
	fPointsMultiplier					= GetConfigValueFloat("points multiplier survivor?");
	SurvivorExperienceMult				= GetConfigValueFloat("experience multiplier survivor?");
	SurvivorExperienceMultTank			= GetConfigValueFloat("experience multiplier tanking?");
	fHealingMultiplier					= GetConfigValueFloat("experience multiplier healing?");
	fBuffingMultiplier					= GetConfigValueFloat("experience multiplier buffing?");
	fHexingMultiplier					= GetConfigValueFloat("experience multiplier hexing?");
	TanksNearbyRange					= GetConfigValueFloat("tank nearby ability deactivate?");
	iCommonAffixes						= GetConfigValueInt("common affixes?");
	BroadcastType						= GetConfigValueInt("hint text type?");
	iDoomTimer							= GetConfigValueInt("doom kill timer?");
	iSurvivorStaminaMax					= GetConfigValueInt("survivor stamina?");
	fRatingMultSpecials					= GetConfigValueFloat("rating multiplier specials?");
	fRatingMultSupers					= GetConfigValueFloat("rating multiplier supers?");
	fRatingMultCommons					= GetConfigValueFloat("rating multiplier commons?");
	fRatingMultTank						= GetConfigValueFloat("rating multiplier tank?");
	fRatingMultWitch					= GetConfigValueFloat("rating multiplier witch?");
	fTeamworkExperience					= GetConfigValueInt("maximum teamwork experience?") * 1.0;
	fItemMultiplierLuck					= GetConfigValueFloat("buy item luck multiplier?");
	fItemMultiplierTeam					= GetConfigValueInt("buy teammate item multiplier?") * 1.0;
	GetConfigValue(sQuickBindHelp, sizeof(sQuickBindHelp), "quick bind help?");
	fPointsCostLevel					= GetConfigValueFloat("points cost increase per level?");
	PointPurchaseType					= GetConfigValueInt("points purchase type?");
	iTankLimitVersus					= GetConfigValueInt("versus tank limit?");
	fHealRequirementTeam				= GetConfigValueFloat("teammate heal health requirement?");
	iSurvivorBaseHealth					= GetConfigValueInt("survivor health?");
	iSurvivorBotBaseHealth				= GetConfigValueInt("survivor bot health?");
	GetConfigValue(spmn, sizeof(spmn), "sky points menu name?");
	fHealthSurvivorRevive				= GetConfigValueFloat("survivor revive health?");
	GetConfigValue(RestrictedWeapons, sizeof(RestrictedWeapons), "restricted weapons?");
	iMaxLevel							= GetConfigValueInt("max level?");
	iExperienceStart					= GetConfigValueInt("experience start?");
	fExperienceMultiplier				= GetConfigValueFloat("requirement multiplier?");
	GetConfigValue(sBotTeam, sizeof(sBotTeam), "survivor team?");
	iActionBarSlots						= GetConfigValueInt("action bar slots?");
	GetConfigValue(MenuCommand, sizeof(MenuCommand), "rpg menu command?");
	ReplaceString(MenuCommand, sizeof(MenuCommand), ",", " or ", true);
	HostNameTime						= GetConfigValueInt("display server name time?");
	DoomSUrvivorsRequired				= GetConfigValueInt("doom survivors ignored?");
	DoomKillTimer						= GetConfigValueInt("doom kill timer?");
	fVersusTankNotice					= GetConfigValueFloat("versus tank notice?");
	AllowedCommons						= GetConfigValueInt("common limit base?");
	AllowedMegaMob						= GetConfigValueInt("mega mob limit base?");
	AllowedMobSpawn						= GetConfigValueInt("mob limit base?");
	AllowedMobSpawnFinale				= GetConfigValueInt("mob finale limit base?");
	//AllowedPanicInterval				= GetConfigValueInt("mega mob max interval base?");
	RespawnQueue						= GetConfigValueInt("survivor respawn queue?");
	MaximumPriority						= GetConfigValueInt("director priority maximum?");
	fUpgradeExpCost						= GetConfigValueFloat("upgrade experience cost?");
	iHandicapLevelDifference			= GetConfigValueInt("handicap level difference required?");
	iWitchHealthBase					= GetConfigValueInt("base witch health?");
	fWitchHealthMult					= GetConfigValueFloat("level witch multiplier?");
	iCommonBaseHealth					= GetConfigValueInt("common base health?");
	fCommonLevelHealthMult				= GetConfigValueFloat("common level health?");
	iRoundStartWeakness					= GetConfigValueInt("weakness on round start?");
	GroupMemberBonus					= GetConfigValueFloat("steamgroup bonus?");
	RaidLevMult							= GetConfigValueInt("raid level multiplier?");
	iIgnoredRating						= GetConfigValueInt("rating to ignore?");
	iIgnoredRatingMax					= GetConfigValueInt("max rating to ignore?");
	iInfectedLimit						= GetConfigValueInt("ensnare infected limit?");
	TheScorchMult						= GetConfigValueFloat("scorch multiplier?");
	TheInfernoMult						= GetConfigValueFloat("inferno multiplier?");
	fAmmoHighlightTime					= GetConfigValueFloat("special ammo highlight time?");
	fAdrenProgressMult					= GetConfigValueFloat("adrenaline progress multiplier?");
	DirectorTankCooldown				= GetConfigValueFloat("director tank cooldown?");
	DisplayType							= GetConfigValueInt("survivor reward display?");
	GetConfigValue(sDirectorTeam, sizeof(sDirectorTeam), "director team name?");
	fRestedExpMult						= GetConfigValueFloat("rested experience multiplier?");
	fSurvivorExpMult					= GetConfigValueFloat("survivor experience bonus?");
	iDebuffLimit						= GetConfigValueInt("debuff limit?");
	iRatingSpecialsRequired				= GetConfigValueInt("specials rating required?");
	iRatingTanksRequired				= GetConfigValueInt("tank rating required?");
	GetConfigValue(sDbLeaderboards, sizeof(sDbLeaderboards), "db record?");
	iIsLifelink							= GetConfigValueInt("lifelink enabled?");
	RatingPerHandicap					= GetConfigValueInt("rating level handicap?");
	GetConfigValue(sItemModel, sizeof(sItemModel), "item drop model?");
	iRarityMax							= GetConfigValueInt("item rarity max?");
	iEnrageAdvertisement				= GetConfigValueInt("enrage advertise time?");
	iNotifyEnrage						= GetConfigValueInt("enrage notification?");
	iJoinGroupAdvertisement				= GetConfigValueInt("join group advertise time?");
	GetConfigValue(sBackpackModel, sizeof(sBackpackModel), "backpack model?");
	iSurvivorGroupMinimum				= GetConfigValueInt("group member minimum?");
	fBurnPercentage						= GetConfigValueFloat("burn debuff percentage?");
	fSuperCommonLimit					= GetConfigValueFloat("super common limit?");
	iCommonsLimitUpper					= GetConfigValueInt("commons limit max?");
	FinSurvBon							= GetConfigValueFloat("finale survival bonus?");
	fCoopSurvBon 						= GetConfigValueFloat("coop round survival bonus?");
	iMaxIncap							= GetConfigValueInt("survivor max incap?");
	iMaxLayers							= GetConfigValueInt("max talent layers?");
	iCommonInfectedBaseDamage			= GetConfigValueInt("common infected base damage?");
	iShowTotalNodesOnTalentTree			= GetConfigValueInt("show upgrade maximum by nodes?");
	fDrawHudInterval					= GetConfigValueFloat("hud display tick rate?");
	fSpecialAmmoInterval				= GetConfigValueFloat("special ammo tick rate?");
	fEffectOverTimeInterval				= GetConfigValueFloat("effect over time tick rate?");
	//fStaggerTime						= GetConfigValueFloat("stagger debuff time?");
	fStaggerTickrate					= GetConfigValueFloat("stagger tickrate?");
	fRatingFloor						= GetConfigValueFloat("rating floor?");
	iExperienceDebtLevel				= GetConfigValueInt("experience debt level?");
	iExperienceDebtEnabled				= GetConfigValueInt("experience debt enabled?");
	fExperienceDebtPenalty				= GetConfigValueFloat("experience debt penalty?");
	iShowDamageOnActionBar				= GetConfigValueInt("show damage on action bar?");
	iDefaultIncapHealth					= GetConfigValueInt("default incap health?");
	iSkyLevelNodeUnlocks				= GetConfigValueInt("sky level default node unlocks?");
	iCanSurvivorBotsBurn				= GetConfigValueInt("survivor bots debuffs allowed?");
	iSurvivorBotsAreImmuneToFireDamage	= GetConfigValueInt("survivor bots immune to fire damage?", 1);	// we make survivor bots immune to fire damage by default.
	iDeleteCommonsFromExistenceOnDeath	= GetConfigValueInt("delete commons from existence on death?");
	iShowDetailedDisplayAlways			= GetConfigValueInt("show detailed display to survivors always?");
	iCanJetpackWhenInCombat				= GetConfigValueInt("can players jetpack when in combat?");
	fquickScopeTime						= GetConfigValueFloat("delay after zoom for quick scope kill?");
	iEnsnareLevelMultiplier				= GetConfigValueInt("ensnare level multiplier?");
	iNoSpecials							= GetConfigValueInt("disable non boss special infected?");
	fSurvivorBotsNoneBonus				= GetConfigValueFloat("group bonus if no survivor bots?");
	iSurvivorBotsBonusLimit				= GetConfigValueInt("no survivor bots group bonus requirement?");
	iShowAdvertToNonSteamgroupMembers	= GetConfigValueInt("show advertisement to non-steamgroup members?");
	iStrengthOnSpawnIsStrength			= GetConfigValueInt("spells,auras,ammos strength set on spawn?");
	iHealingPlayerInCombatPutInCombat	= GetConfigValueInt("healing a player in combat places you in combat?");
	iPlayersLeaveCombatDuringFinales	= GetConfigValueInt("do players leave combat during finales?");
	iAllowPauseLeveling					= GetConfigValueInt("let players pause their leveling?");
	fMaxDamageResistance				= GetConfigValueFloat("max damage resistance?", 0.99);
	fStaminaPerPlayerLevel				= GetConfigValueFloat("stamina increase per player level?");
	fStaminaPerSkyLevel					= GetConfigValueFloat("stamina increase per prestige level?");
	iEndRoundIfNoHealthySurvivors		= GetConfigValueInt("end round if all survivors are incapped?");
	iEndRoundIfNoLivingHumanSurvivors	= GetConfigValueInt("end round if no living human survivors?", 1);
	fTankMovementSpeed_Burning			= GetConfigValueFloat("fire tank movement speed?", 1.0);	// if this key is omitted, a default value is set. these MUST be > 0.0, so the default is hard-coded.
	fTankMovementSpeed_Hulk				= GetConfigValueFloat("hulk tank movement speed?", 0.75);
	fTankMovementSpeed_Death			= GetConfigValueFloat("death tank movement speed?", 0.5);
	iResetPlayerLevelOnDeath			= GetConfigValueInt("reset player level on death?");
	iStartingPlayerUpgrades				= GetConfigValueInt("new player starting upgrades?", 0);
	leaderboardPageCount				= GetConfigValueInt("leaderboard players per page?", 5);
	fForceTankJumpHeight				= GetConfigValueFloat("force tank to jump power?", 500.0);
	fForceTankJumpRange					= GetConfigValueFloat("force tank to jump range?", 256.0);
	iResetDirectorPointsOnNewRound		= GetConfigValueInt("reset director points every round?", 1);
	iMaxServerUpgrades					= GetConfigValueInt("max upgrades allowed?");
	iExperienceLevelCap					= GetConfigValueInt("player level to stop earning experience?", 0);
	iDeleteSupersOnDeath				= GetConfigValueInt("delete super commons on death?", 1);
	iShoveStaminaCost					= GetConfigValueInt("shove stamina cost?", 10);
	iLootEnabled						= GetConfigValueInt("loot system enabled?", 1);
	fLootChanceTank						= GetConfigValueFloat("loot chance tank?", 1.0);
	fLootChanceSpecials					= GetConfigValueFloat("loot chance specials?", 0.1);
	fLootChanceSupers					= GetConfigValueFloat("loot chance supers?", 0.01);
	fLootChanceCommons					= GetConfigValueFloat("loot chance commons?", 0.001);
	fUpgradesRequiredPerLayer			= GetConfigValueFloat("layer upgrades required?", 0.3);
	iEnsnareRestrictions				= GetConfigValueInt("ensnare restrictions?", 1);
	iDontStoreInfectedInArray			= GetConfigValueInt("dont store infected in array?", 1);
	fTeleportTankHeightDistance			= GetConfigValueFloat("teleport tank height distance?", 512.0);
	fSurvivorBufferBonus				= GetConfigValueFloat("common buffers survivors effect?", 2.0);
	iCommonInfectedSpawnDelayOnNewRound	= GetConfigValueInt("new round spawn common delay?", 30);
	iHideEnrageTimerUntilSecondsLeft	= GetConfigValueInt("hide enrage timer until seconds left?", iEnrageTime/3);
	showNumLivingSurvivorsInHostname	= GetConfigValueInt("show living survivors in hostname?", 0);
	GetConfigValue(acmd, sizeof(acmd), "action slot command?");
	GetConfigValue(abcmd, sizeof(abcmd), "abilitybar menu command?");
	GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
	GetConfigValue(DefaultBotProfileName, sizeof(DefaultBotProfileName), "new bot player profile?");
	GetConfigValue(DefaultInfectedProfileName, sizeof(DefaultInfectedProfileName), "new infected player profile?");
	GetConfigValue(defaultLoadoutWeaponPrimary, sizeof(defaultLoadoutWeaponPrimary), "default loadout primary weapon?");
	GetConfigValue(defaultLoadoutWeaponSecondary, sizeof(defaultLoadoutWeaponSecondary), "default loadout secondary weapon?");
	GetConfigValue(serverKey, sizeof(serverKey), "server steam key?");
	LogMessage("Main Config Loaded.");
}

//public Action:CMD_Backpack(client, args) { EquipBackpack(client); return Plugin_Handled; }
public Action:CMD_BuyMenu(client, args) {
	if (iRPGMode < 0 || iRPGMode == 1 && b_IsActiveRound) return Plugin_Handled;
	//if (StringToInt(GetConfigValue("rpg mode?")) != 1) 
	BuildPointsMenu(client, "Buy Menu", "rpg/points.cfg");
	return Plugin_Handled;
}

public Action:CMD_DataErase(client, args) {
	decl String:arg[MAX_NAME_LENGTH];
	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "delete bot flags?");
	if (args > 0 && HasCommandAccess(client, thetext)) {
		GetCmdArg(1, arg, sizeof(arg));
		new targetclient = FindTargetClient(client, arg);
		if (IsLegitimateClient(targetclient) && GetClientTeam(targetclient) != TEAM_INFECTED) DeleteAndCreateNewData(targetclient);
	}
	else DeleteAndCreateNewData(client);
	return Plugin_Handled;
}

public Action:CMD_DataEraseBot(client, args) {
	DeleteAndCreateNewData(client, true);
	return Plugin_Handled;
}

stock DeleteAndCreateNewData(client, bool:IsBot = false) {
	decl String:key[64];
	decl String:tquery[1024];
	decl String:text[64];
	decl String:pct[4];
	Format(pct, sizeof(pct), "%");
	if (!IsBot) {
		GetClientAuthString(client, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);
		ResetData(client);
		CreateNewPlayerEx(client);
		PrintToChat(client, "data erased, new data created.");	// not bothering with a translation here, since it's a debugging command.
	}
	else {
		GetConfigValue(text, sizeof(text), "delete bot flags?");
		if (HasCommandAccess(client, text)) {

			for (new i = 1; i <= MaxClients; i++) {

				if (IsSurvivorBot(i)) KickClient(i);
			}

			Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE '%s%s%s';", TheDBPrefix, pct, sBotTeam, pct);
			//Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE 'STEAM';", TheDBPrefix);
			SQL_TQuery(hDatabase, QueryResults, tquery, client);
			LogMessage("%s", tquery);
			PrintToChatAll("%t", "bot data deleted", orange, blue);
		}
	}
}

public Action:CMD_DirectorTalentToggle(client, args) {
	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "director talent flags?");
	if (HasCommandAccess(client, thetext)) {

		if (b_IsDirectorTalents[client]) {

			b_IsDirectorTalents[client]			= false;
			PrintToChat(client, "%T", "Director Talents Disabled", client, white, green);
		}
		else {

			b_IsDirectorTalents[client]			= true;
			PrintToChat(client, "%T", "Director Talents Enabled", client, white, green);
		}
	}
	return Plugin_Handled;
}

stock SetConfigArrays(String:Config[], Handle:Main, Handle:Keys, Handle:Values, Handle:Section, size, last) {

	decl String:text[64];
	//GetArrayString(Section, 0, text, sizeof(text));

	new Handle:TalentKey = CreateArray(32);
	new Handle:TalentValue = CreateArray(32);
	new Handle:TalentSection = CreateArray(32);

	decl String:key[64];
	decl String:value[64];
	new a_Size = GetArraySize(Keys);
	for (new i = last; i < a_Size; i++) {

		GetArrayString(Handle:Keys, i, key, sizeof(key));
		GetArrayString(Handle:Values, i, value, sizeof(value));
		//if (StrEqual(key, "EOM")) continue;	// we don't care about the EOM key at this point.

		PushArrayString(TalentKey, key);
		PushArrayString(TalentValue, value);
	}
	new pos = 0;
	new sortSize = 0;
	// Sort the keys/values for TALENTS ONLY /w.
	if (StrEqual(Config, CONFIG_MENUTALENTS)) {
		if (FindStringInArray(TalentKey, "last hit must be headshot?") == -1) {
			PushArrayString(TalentKey, "last hit must be headshot?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "event type?") == -1) {
			PushArrayString(TalentKey, "event type?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target must be in the air?") == -1) {
			PushArrayString(TalentKey, "target must be in the air?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator neither high or low ground?") == -1) {
			PushArrayString(TalentKey, "activator neither high or low ground?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target high ground?") == -1) {
			PushArrayString(TalentKey, "target high ground?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator high ground?") == -1) {
			PushArrayString(TalentKey, "activator high ground?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator drowning?") == -1) {
			PushArrayString(TalentKey, "requires activator drowning?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator steaming?") == -1) {
			PushArrayString(TalentKey, "requires activator steaming?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator scorched?") == -1) {
			PushArrayString(TalentKey, "requires activator scorched?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator frozen?") == -1) {
			PushArrayString(TalentKey, "requires activator frozen?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator slowed?") == -1) {
			PushArrayString(TalentKey, "requires activator slowed?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator exploding?") == -1) {
			PushArrayString(TalentKey, "requires activator exploding?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator acid burn?") == -1) {
			PushArrayString(TalentKey, "requires activator acid burn?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires activator on fire?") == -1) {
			PushArrayString(TalentKey, "requires activator on fire?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target must be last target?") == -1) {
			PushArrayString(TalentKey, "target must be last target?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target must be outside range required?") == -1) {
			PushArrayString(TalentKey, "target must be outside range required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target range required?") == -1) {
			PushArrayString(TalentKey, "target range required?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "target class must be last target class?") == -1) {
			PushArrayString(TalentKey, "target class must be last target class?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "toggle strength?") == -1) {
			PushArrayString(TalentKey, "toggle strength?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "minimum level required?") == -1) {
			PushArrayString(TalentKey, "minimum level required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "special ammo?") == -1) {
			PushArrayString(TalentKey, "special ammo?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "does damage?") == -1) {
			PushArrayString(TalentKey, "does damage?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown end ability trigger?") == -1) {
			PushArrayString(TalentKey, "cooldown end ability trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active end ability trigger?") == -1) {
			PushArrayString(TalentKey, "active end ability trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "secondary ept only?") == -1) {
			PushArrayString(TalentKey, "secondary ept only?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activate effect per tick?") == -1) {
			PushArrayString(TalentKey, "activate effect per tick?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown?") == -1) {
			PushArrayString(TalentKey, "cooldown?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "allow survivors?") == -1) {
			PushArrayString(TalentKey, "allow survivors?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "allow specials?") == -1) {
			PushArrayString(TalentKey, "allow specials?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "allow commons?") == -1) {
			PushArrayString(TalentKey, "allow commons?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "inanimate only?") == -1) {
			PushArrayString(TalentKey, "inanimate only?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "humanoid only?") == -1) {
			PushArrayString(TalentKey, "humanoid only?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "toggle effect?") == -1) {
			PushArrayString(TalentKey, "toggle effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "sky level requirement?") == -1) {
			PushArrayString(TalentKey, "sky level requirement?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cannot be ensnared?") == -1) {
			PushArrayString(TalentKey, "cannot be ensnared?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active time?") == -1) {
			PushArrayString(TalentKey, "active time?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "reactive type?") == -1) {
			PushArrayString(TalentKey, "reactive type?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "inactive trigger?") == -1) {
			PushArrayString(TalentKey, "inactive trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown trigger?") == -1) {
			PushArrayString(TalentKey, "cooldown trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "is aura instead?") == -1) {
			PushArrayString(TalentKey, "is aura instead?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requirement multiplier?") == -1) {
			PushArrayString(TalentKey, "requirement multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "experience start?") == -1) {
			PushArrayString(TalentKey, "experience start?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "rarity?") == -1) {
			PushArrayString(TalentKey, "rarity?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "is item?") == -1) {
			PushArrayString(TalentKey, "is item?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "talent type?") == -1) {
			PushArrayString(TalentKey, "talent type?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "is sub menu?") == -1) {
			PushArrayString(TalentKey, "is sub menu?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "buff bar text?") == -1) {
			PushArrayString(TalentKey, "buff bar text?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "diminishing returns?") == -1) {
			PushArrayString(TalentKey, "diminishing returns?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "diminishing multiplier?") == -1) {
			PushArrayString(TalentKey, "diminishing multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "base multiplier?") == -1) {
			PushArrayString(TalentKey, "base multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "use these multipliers?") == -1) {
			PushArrayString(TalentKey, "use these multipliers?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "attribute?") == -1) {
			PushArrayString(TalentKey, "attribute?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "passive draw delay?") == -1) {
			PushArrayString(TalentKey, "passive draw delay?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "draw effect delay?") == -1) {
			PushArrayString(TalentKey, "draw effect delay?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "draw delay?") == -1) {
			PushArrayString(TalentKey, "draw delay?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "is single target?") == -1) {
			PushArrayString(TalentKey, "is single target?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "passive only?") == -1) {
			PushArrayString(TalentKey, "passive only?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "passive strength?") == -1) {
			PushArrayString(TalentKey, "passive strength?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "passive requires ensnare?") == -1) {
			PushArrayString(TalentKey, "passive requires ensnare?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "passive ignores cooldown?") == -1) {
			PushArrayString(TalentKey, "passive ignores cooldown?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active strength?") == -1) {
			PushArrayString(TalentKey, "active strength?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "active requires ensnare?") == -1) {
			PushArrayString(TalentKey, "active requires ensnare?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "maximum active multiplier?") == -1) {
			PushArrayString(TalentKey, "maximum active multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "maximum passive multiplier?") == -1) {
			PushArrayString(TalentKey, "maximum passive multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "cooldown strength?") == -1) {
			PushArrayString(TalentKey, "cooldown strength?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "teams allowed?") == -1) {
			PushArrayString(TalentKey, "teams allowed?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "reactive ability?") == -1) {
			PushArrayString(TalentKey, "reactive ability?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown effect?") == -1) {
			PushArrayString(TalentKey, "cooldown effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "passive effect?") == -1) {
			PushArrayString(TalentKey, "passive effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active effect?") == -1) {
			PushArrayString(TalentKey, "active effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "effect multiplier?") == -1) {
			PushArrayString(TalentKey, "effect multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "ammo effect?") == -1) {
			PushArrayString(TalentKey, "ammo effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "interval per point?") == -1) {
			PushArrayString(TalentKey, "interval per point?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "interval first point?") == -1) {
			PushArrayString(TalentKey, "interval first point?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "range per point?") == -1) {
			PushArrayString(TalentKey, "range per point?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "range first point value?") == -1) {
			PushArrayString(TalentKey, "range first point value?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "stamina per point?") == -1) {
			PushArrayString(TalentKey, "stamina per point?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "base stamina required?") == -1) {
			PushArrayString(TalentKey, "base stamina required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown per point?") == -1) {
			PushArrayString(TalentKey, "cooldown per point?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown first point?") == -1) {
			PushArrayString(TalentKey, "cooldown first point?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown start?") == -1) {
			PushArrayString(TalentKey, "cooldown start?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active time per point?") == -1) {
			PushArrayString(TalentKey, "active time per point?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active time first point?") == -1) {
			PushArrayString(TalentKey, "active time first point?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "roll chance?") == -1) {
			PushArrayString(TalentKey, "roll chance?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "hide translation?") == -1) {
			PushArrayString(TalentKey, "hide translation?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "is attribute?") == -1) {
			PushArrayString(TalentKey, "is attribute?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "ignore for layer count?") == -1) {
			PushArrayString(TalentKey, "ignore for layer count?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "effect strength?") == -1) {
			PushArrayString(TalentKey, "effect strength?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "is effect over time?") == -1) {
			PushArrayString(TalentKey, "is effect over time?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "talent hard limit?") == -1) {
			PushArrayString(TalentKey, "talent hard limit?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "governs cooldown of talent named?") == -1) {
			PushArrayString(TalentKey, "governs cooldown of talent named?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "talent active time scale?") == -1) {
			PushArrayString(TalentKey, "talent active time scale?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "talent active time strength value?") == -1) {
			PushArrayString(TalentKey, "talent active time strength value?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "talent cooldown scale?") == -1) {
			PushArrayString(TalentKey, "talent cooldown scale?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "talent cooldown strength value?") == -1) {
			PushArrayString(TalentKey, "talent cooldown strength value?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "talent upgrade scale?") == -1) {
			PushArrayString(TalentKey, "talent upgrade scale?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "talent upgrade strength value?") == -1) {
			PushArrayString(TalentKey, "talent upgrade strength value?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "required talents required?") == -1) {
			PushArrayString(TalentKey, "required talents required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "action bar name?") == -1) {
			PushArrayString(TalentKey, "action bar name?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "is ability?") == -1) {
			PushArrayString(TalentKey, "is ability?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "layer?") == -1) {
			PushArrayString(TalentKey, "layer?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "part of menu named?") == -1) {
			PushArrayString(TalentKey, "part of menu named?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "talent tree category?") == -1) {
			PushArrayString(TalentKey, "talent tree category?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "governing attribute?") == -1) {
			PushArrayString(TalentKey, "governing attribute?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "translation?") == -1) {
			PushArrayString(TalentKey, "translation?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "talent name?") == -1) {
			PushArrayString(TalentKey, "talent name?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "secondary aoe?") == -1) {
			PushArrayString(TalentKey, "secondary aoe?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "primary aoe?") == -1) {
			PushArrayString(TalentKey, "primary aoe?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "target is self?") == -1) {
			PushArrayString(TalentKey, "target is self?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "secondary ability trigger?") == -1) {
			PushArrayString(TalentKey, "secondary ability trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "is own talent?") == -1) {
			PushArrayString(TalentKey, "is own talent?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "health percentage required missing max?") == -1) {
			PushArrayString(TalentKey, "health percentage required missing max?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "health percentage required missing?") == -1) {
			PushArrayString(TalentKey, "health percentage required missing?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "no effect if damage time is not met?") == -1) {
			PushArrayString(TalentKey, "no effect if damage time is not met?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "strength increase while holding fire?") == -1) {
			PushArrayString(TalentKey, "strength increase while holding fire?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "no effect if zoom time is not met?") == -1) {
			PushArrayString(TalentKey, "no effect if zoom time is not met?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "strength increase time required?") == -1) {
			PushArrayString(TalentKey, "strength increase time required?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "strength increase time cap?") == -1) {
			PushArrayString(TalentKey, "strength increase time cap?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "strength increase while zoomed?") == -1) {
			PushArrayString(TalentKey, "strength increase while zoomed?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "multiply specials?") == -1) {
			PushArrayString(TalentKey, "multiply specials?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiply survivors?") == -1) {
			PushArrayString(TalentKey, "multiply survivors?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiply witches?") == -1) {
			PushArrayString(TalentKey, "multiply witches?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiply supers?") == -1) {
			PushArrayString(TalentKey, "multiply supers?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiply commons?") == -1) {
			PushArrayString(TalentKey, "multiply commons?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiply range?") == -1) {
			PushArrayString(TalentKey, "multiply range?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "status effect multiplier?") == -1) {
			PushArrayString(TalentKey, "status effect multiplier?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "background talent?") == -1) {
			PushArrayString(TalentKey, "background talent?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require consecutive hits?") == -1) {
			PushArrayString(TalentKey, "require consecutive hits?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cleanse trigger?") == -1) {
			PushArrayString(TalentKey, "cleanse trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target class required?") == -1) {
			PushArrayString(TalentKey, "target class required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require weakness?") == -1) {
			PushArrayString(TalentKey, "require weakness?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "disabled if weakness?") == -1) {
			PushArrayString(TalentKey, "disabled if weakness?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require adrenaline effect?") == -1) {
			PushArrayString(TalentKey, "require adrenaline effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target vomit state required?") == -1) {
			PushArrayString(TalentKey, "target vomit state required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "vomit state required?") == -1) {
			PushArrayString(TalentKey, "vomit state required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cannot be touching earth?") == -1) {
			PushArrayString(TalentKey, "cannot be touching earth?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cannot target self?") == -1) {
			PushArrayString(TalentKey, "cannot target self?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target stagger required?") == -1) {
			PushArrayString(TalentKey, "target stagger required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator stagger required?") == -1) {
			PushArrayString(TalentKey, "activator stagger required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires crouching?") == -1) {
			PushArrayString(TalentKey, "requires crouching?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires limbshot?") == -1) {
			PushArrayString(TalentKey, "requires limbshot?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires headshot?") == -1) {
			PushArrayString(TalentKey, "requires headshot?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "passive ability?") == -1) {
			PushArrayString(TalentKey, "passive ability?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "player state required?") == -1) {
			PushArrayString(TalentKey, "player state required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "combat state required?") == -1) {
			PushArrayString(TalentKey, "combat state required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "requires zoom?") == -1) {
			PushArrayString(TalentKey, "requires zoom?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator class required?") == -1) {
			PushArrayString(TalentKey, "activator class required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator team required?") == -1) {
			PushArrayString(TalentKey, "activator team required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "health percentage missing required target?") == -1) {
			PushArrayString(TalentKey, "health percentage missing required target?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "health percentage remaining required target?") == -1) {
			PushArrayString(TalentKey, "health percentage remaining required target?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "coherency required?") == -1) {
			PushArrayString(TalentKey, "coherency required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "coherency max?") == -1) {
			PushArrayString(TalentKey, "coherency max?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "coherency range?") == -1) {
			PushArrayString(TalentKey, "coherency range?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "health percentage required?") == -1) {
			PushArrayString(TalentKey, "health percentage required?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "weapons permitted?") == -1) {
			PushArrayString(TalentKey, "weapons permitted?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "secondary effects?") == -1) {
			PushArrayString(TalentKey, "secondary effects?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target ability effects?") == -1) {
			PushArrayString(TalentKey, "target ability effects?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator ability effects?") == -1) {
			PushArrayString(TalentKey, "activator ability effects?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "compound with?") == -1) {
			PushArrayString(TalentKey, "compound with?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "compounding talent?") == -1) {
			PushArrayString(TalentKey, "compounding talent?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "ability type?") == -1) {
			PushArrayString(TalentKey, "ability type?");
			PushArrayString(TalentValue, "-1");
		}
		sortSize = GetArraySize(TalentKey);
		pos = 0;
		while (pos < sortSize) {
			GetArrayString(TalentKey, pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "ability type?") ||
			pos == 1 && !StrEqual(text, "compounding talent?") ||
			pos == 2 && !StrEqual(text, "compound with?") ||
			pos == 3 && !StrEqual(text, "activator ability effects?") ||
			pos == 4 && !StrEqual(text, "target ability effects?") ||
			pos == 5 && !StrEqual(text, "secondary effects?") ||
			pos == 6 && !StrEqual(text, "weapons permitted?") ||
			pos == 7 && !StrEqual(text, "health percentage required?") ||
			pos == 8 && !StrEqual(text, "coherency range?") ||
			pos == 9 && !StrEqual(text, "coherency max?") ||
			pos == 10 && !StrEqual(text, "coherency required?") ||
			pos == 11 && !StrEqual(text, "health percentage remaining required target?") ||
			pos == 12 && !StrEqual(text, "health percentage missing required target?") ||
			pos == 13 && !StrEqual(text, "activator team required?") ||
			pos == 14 && !StrEqual(text, "activator class required?") ||
			pos == 15 && !StrEqual(text, "requires zoom?") ||
			pos == 16 && !StrEqual(text, "combat state required?") ||
			pos == 17 && !StrEqual(text, "player state required?") ||
			pos == 18 && !StrEqual(text, "passive ability?") ||
			pos == 19 && !StrEqual(text, "requires headshot?") ||
			pos == 20 && !StrEqual(text, "requires limbshot?") ||
			pos == 21 && !StrEqual(text, "requires crouching?") ||
			pos == 22 && !StrEqual(text, "activator stagger required?") ||
			pos == 23 && !StrEqual(text, "target stagger required?") ||
			pos == 24 && !StrEqual(text, "cannot target self?") ||
			pos == 25 && !StrEqual(text, "cannot be touching earth?") ||
			pos == 26 && !StrEqual(text, "vomit state required?") ||
			pos == 27 && !StrEqual(text, "target vomit state required?") ||
			pos == 28 && !StrEqual(text, "require adrenaline effect?") ||
			pos == 29 && !StrEqual(text, "disabled if weakness?") ||
			pos == 30 && !StrEqual(text, "require weakness?") ||
			pos == 31 && !StrEqual(text, "target class required?") ||
			pos == 32 && !StrEqual(text, "cleanse trigger?") ||
			pos == 33 && !StrEqual(text, "require consecutive hits?") ||
			pos == 34 && !StrEqual(text, "background talent?") ||
			pos == 35 && !StrEqual(text, "status effect multiplier?") ||
			pos == 36 && !StrEqual(text, "multiply range?") ||
			pos == 37 && !StrEqual(text, "multiply commons?") ||
			pos == 38 && !StrEqual(text, "multiply supers?") ||
			pos == 39 && !StrEqual(text, "multiply witches?") ||
			pos == 40 && !StrEqual(text, "multiply survivors?") ||
			pos == 41 && !StrEqual(text, "multiply specials?") ||
			pos == 42 && !StrEqual(text, "strength increase while zoomed?") ||
			pos == 43 && !StrEqual(text, "strength increase time cap?") ||
			pos == 44 && !StrEqual(text, "strength increase time required?") ||
			pos == 45 && !StrEqual(text, "no effect if zoom time is not met?") ||
			pos == 46 && !StrEqual(text, "strength increase while holding fire?") ||
			pos == 47 && !StrEqual(text, "no effect if damage time is not met?") ||
			pos == 48 && !StrEqual(text, "health percentage required missing?") ||
			pos == 49 && !StrEqual(text, "health percentage required missing max?") ||
			pos == 50 && !StrEqual(text, "is own talent?") ||
			pos == 51 && !StrEqual(text, "secondary ability trigger?") ||
			pos == 52 && !StrEqual(text, "target is self?") ||
			pos == 53 && !StrEqual(text, "primary aoe?") ||
			pos == 54 && !StrEqual(text, "secondary aoe?") ||
			pos == 55 && !StrEqual(text, "talent name?") ||
			pos == 56 && !StrEqual(text, "translation?") ||
			pos == 57 && !StrEqual(text, "governing attribute?") ||
			pos == 58 && !StrEqual(text, "talent tree category?") ||
			pos == 59 && !StrEqual(text, "part of menu named?") ||
			pos == 60 && !StrEqual(text, "layer?") ||
			pos == 61 && !StrEqual(text, "is ability?") ||
			pos == 62 && !StrEqual(text, "action bar name?") ||
			pos == 63 && !StrEqual(text, "required talents required?") ||
			pos == 64 && !StrEqual(text, "talent upgrade strength value?") ||
			pos == 65 && !StrEqual(text, "talent upgrade scale?") ||
			pos == 66 && !StrEqual(text, "talent cooldown strength value?") ||
			pos == 67 && !StrEqual(text, "talent cooldown scale?") ||
			pos == 68 && !StrEqual(text, "talent active time strength value?") ||
			pos == 69 && !StrEqual(text, "talent active time scale?") ||
			pos == 70 && !StrEqual(text, "governs cooldown of talent named?") ||
			pos == 71 && !StrEqual(text, "talent hard limit?") ||
			pos == 72 && !StrEqual(text, "is effect over time?") ||
			pos == 73 && !StrEqual(text, "effect strength?") ||
			pos == 74 && !StrEqual(text, "ignore for layer count?") ||
			pos == 75 && !StrEqual(text, "is attribute?") ||
			pos == 76 && !StrEqual(text, "hide translation?") ||
			pos == 77 && !StrEqual(text, "roll chance?")) {
				ResizeArray(TalentKey, sortSize+1);
				ResizeArray(TalentValue, sortSize+1);
				SetArrayString(TalentKey, sortSize, text);
				GetArrayString(TalentValue, pos, text, sizeof(text));
				SetArrayString(TalentValue, sortSize, text);
				RemoveFromArray(TalentKey, pos);
				RemoveFromArray(TalentValue, pos);
				continue;
			}	// had to split this argument up due to internal compiler error on arguments exceeding 80
			else if (
			pos == 78 && !StrEqual(text, "interval per point?") ||
			pos == 79 && !StrEqual(text, "interval first point?") ||
			pos == 80 && !StrEqual(text, "range per point?") ||
			pos == 81 && !StrEqual(text, "range first point value?") ||
			pos == 82 && !StrEqual(text, "stamina per point?") ||
			pos == 83 && !StrEqual(text, "base stamina required?") ||
			pos == 84 && !StrEqual(text, "cooldown per point?") ||
			pos == 85 && !StrEqual(text, "cooldown first point?") ||
			pos == 86 && !StrEqual(text, "cooldown start?") ||
			pos == 87 && !StrEqual(text, "active time per point?") ||
			pos == 88 && !StrEqual(text, "active time first point?") ||
			pos == 89 && !StrEqual(text, "ammo effect?") ||
			pos == 90 && !StrEqual(text, "effect multiplier?") ||
			pos == 91 && !StrEqual(text, "active effect?") ||
			pos == 92 && !StrEqual(text, "passive effect?") ||
			pos == 93 && !StrEqual(text, "cooldown effect?") ||
			pos == 94 && !StrEqual(text, "reactive ability?") ||
			pos == 95 && !StrEqual(text, "teams allowed?") ||
			pos == 96 && !StrEqual(text, "cooldown strength?") ||
			pos == 97 && !StrEqual(text, "maximum passive multiplier?") ||
			pos == 98 && !StrEqual(text, "maximum active multiplier?") ||
			pos == 99 && !StrEqual(text, "active requires ensnare?") ||
			pos == 100 && !StrEqual(text, "active strength?") ||
			pos == 101 && !StrEqual(text, "passive ignores cooldown?") ||
			pos == 102 && !StrEqual(text, "passive requires ensnare?") ||
			pos == 103 && !StrEqual(text, "passive strength?") ||
			pos == 104 && !StrEqual(text, "passive only?") ||
			pos == 105 && !StrEqual(text, "is single target?") ||
			pos == 106 && !StrEqual(text, "draw delay?") ||
			pos == 107 && !StrEqual(text, "draw effect delay?") ||
			pos == 108 && !StrEqual(text, "passive draw delay?") ||
			pos == 109 && !StrEqual(text, "attribute?") ||
			pos == 110 && !StrEqual(text, "use these multipliers?") ||
			pos == 111 && !StrEqual(text, "base multiplier?") ||
			pos == 112 && !StrEqual(text, "diminishing multiplier?") ||
			pos == 113 && !StrEqual(text, "diminishing returns?") ||
			pos == 114 && !StrEqual(text, "buff bar text?") ||
			pos == 115 && !StrEqual(text, "is sub menu?") ||
			pos == 116 && !StrEqual(text, "talent type?") ||
			pos == 117 && !StrEqual(text, "is item?") ||
			pos == 118 && !StrEqual(text, "rarity?") ||
			pos == 119 && !StrEqual(text, "experience start?") ||
			pos == 120 && !StrEqual(text, "requirement multiplier?") ||
			pos == 121 && !StrEqual(text, "is aura instead?") ||
			pos == 122 && !StrEqual(text, "cooldown trigger?") ||
			pos == 123 && !StrEqual(text, "inactive trigger?") ||
			pos == 124 && !StrEqual(text, "reactive type?") ||
			pos == 125 && !StrEqual(text, "active time?") ||
			pos == 126 && !StrEqual(text, "cannot be ensnared?") ||
			pos == 127 && !StrEqual(text, "sky level requirement?") ||
			pos == 128 && !StrEqual(text, "toggle effect?") ||
			pos == 129 && !StrEqual(text, "humanoid only?") ||
			pos == 130 && !StrEqual(text, "inanimate only?") ||
			pos == 131 && !StrEqual(text, "allow commons?") ||
			pos == 132 && !StrEqual(text, "allow specials?") ||
			pos == 133 && !StrEqual(text, "allow survivors?") ||
			pos == 134 && !StrEqual(text, "cooldown?") ||
			pos == 135 && !StrEqual(text, "activate effect per tick?") ||
			pos == 136 && !StrEqual(text, "secondary ept only?") ||
			pos == 137 && !StrEqual(text, "active end ability trigger?") ||
			pos == 138 && !StrEqual(text, "cooldown end ability trigger?") ||
			pos == 139 && !StrEqual(text, "does damage?") ||
			pos == 140 && !StrEqual(text, "special ammo?")) {
				ResizeArray(TalentKey, sortSize+1);
				ResizeArray(TalentValue, sortSize+1);
				SetArrayString(TalentKey, sortSize, text);
				GetArrayString(TalentValue, pos, text, sizeof(text));
				SetArrayString(TalentValue, sortSize, text);
				RemoveFromArray(TalentKey, pos);
				RemoveFromArray(TalentValue, pos);
				continue;
			}
			else if (
				pos == 141 && !StrEqual(text, "minimum level required?") ||
				pos == 142 && !StrEqual(text, "toggle strength?") ||
				pos == 143 && !StrEqual(text, "target class must be last target class?") ||
				pos == 144 && !StrEqual(text, "target range required?") ||
				pos == 145 && !StrEqual(text, "target must be outside range required?") ||
				pos == 146 && !StrEqual(text, "target must be last target?") ||
				pos == 147 && !StrEqual(text, "requires activator on fire?") ||			// [Bu]
				pos == 148 && !StrEqual(text, "requires activator acid burn?") ||		// [Ab]
				pos == 149 && !StrEqual(text, "requires activator exploding?") ||		// [Ex]
				pos == 150 && !StrEqual(text, "requires activator slowed?") ||			// [Sl]
				pos == 151 && !StrEqual(text, "requires activator frozen?") ||			// [Fr]
				pos == 152 && !StrEqual(text, "requires activator scorched?") ||		// [Sc]
				pos == 153 && !StrEqual(text, "requires activator steaming?") ||		// [St]
				pos == 154 && !StrEqual(text, "requires activator drowning?") ||		// [Wa]
				pos == 155 && !StrEqual(text, "activator high ground?") ||
				pos == 156 && !StrEqual(text, "target high ground?") ||
				pos == 157 && !StrEqual(text, "activator neither high or low ground?") ||
				pos == 158 && !StrEqual(text, "target must be in the air?") ||
				pos == 159 && !StrEqual(text, "event type?") ||
				pos == 160 && !StrEqual(text, "last hit must be headshot?")){
				ResizeArray(TalentKey, sortSize+1);
				ResizeArray(TalentValue, sortSize+1);
				SetArrayString(TalentKey, sortSize, text);
				GetArrayString(TalentValue, pos, text, sizeof(text));
				SetArrayString(TalentValue, sortSize, text);
				RemoveFromArray(TalentKey, pos);
				RemoveFromArray(TalentValue, pos);
				continue;
			}
			pos++;
		}
	}
	else if (StrEqual(Config, CONFIG_EVENTS)) {
		if (FindStringInArray(TalentKey, "entered saferoom?") == -1) {
			PushArrayString(TalentKey, "entered saferoom?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "bulletimpact?") == -1) {
			PushArrayString(TalentKey, "bulletimpact?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "shoved?") == -1) {
			PushArrayString(TalentKey, "shoved?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiplier exp?") == -1) {
			PushArrayString(TalentKey, "multiplier exp?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiplier points?") == -1) {
			PushArrayString(TalentKey, "multiplier points?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "distance?") == -1) {
			PushArrayString(TalentKey, "distance?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "origin?") == -1) {
			PushArrayString(TalentKey, "origin?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "tag ability?") == -1) {
			PushArrayString(TalentKey, "tag ability?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "abilities?") == -1) {
			PushArrayString(TalentKey, "abilities?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "damage award?") == -1) {
			PushArrayString(TalentKey, "damage award?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "health?") == -1) {
			PushArrayString(TalentKey, "health?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "damage type?") == -1) {
			PushArrayString(TalentKey, "damage type?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "victim ability trigger?") == -1) {
			PushArrayString(TalentKey, "victim ability trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "victim team required?") == -1) {
			PushArrayString(TalentKey, "victim team required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "perpetrator ability trigger?") == -1) {
			PushArrayString(TalentKey, "perpetrator ability trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "perpetrator team required?") == -1) {
			PushArrayString(TalentKey, "perpetrator team required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "same team event trigger?") == -1) {
			PushArrayString(TalentKey, "same team event trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "victim?") == -1) {
			PushArrayString(TalentKey, "victim?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "perpetrator?") == -1) {
			PushArrayString(TalentKey, "perpetrator?");
			PushArrayString(TalentValue, "-1");
		}
		sortSize = GetArraySize(TalentKey);
		pos = 0;
		while (pos < sortSize) {
			GetArrayString(TalentKey, pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "perpetrator?") ||
			pos == 1 && !StrEqual(text, "victim?") ||
			pos == 2 && !StrEqual(text, "same team event trigger?") ||
			pos == 3 && !StrEqual(text, "perpetrator team required?") ||
			pos == 4 && !StrEqual(text, "perpetrator ability trigger?") ||
			pos == 5 && !StrEqual(text, "victim team required?") ||
			pos == 6 && !StrEqual(text, "victim ability trigger?") ||
			pos == 7 && !StrEqual(text, "damage type?") ||
			pos == 8 && !StrEqual(text, "health?") ||
			pos == 9 && !StrEqual(text, "damage award?") ||
			pos == 10 && !StrEqual(text, "abilities?") ||
			pos == 11 && !StrEqual(text, "tag ability?") ||
			pos == 12 && !StrEqual(text, "origin?") ||
			pos == 13 && !StrEqual(text, "distance?") ||
			pos == 14 && !StrEqual(text, "multiplier points?") ||
			pos == 15 && !StrEqual(text, "multiplier exp?") ||
			pos == 16 && !StrEqual(text, "shoved?") ||
			pos == 17 && !StrEqual(text, "bulletimpact?") ||
			pos == 18 && !StrEqual(text, "entered saferoom?")) {
				ResizeArray(TalentKey, sortSize+1);
				ResizeArray(TalentValue, sortSize+1);
				SetArrayString(TalentKey, sortSize, text);
				GetArrayString(TalentValue, pos, text, sizeof(text));
				SetArrayString(TalentValue, sortSize, text);
				RemoveFromArray(TalentKey, pos);
				RemoveFromArray(TalentValue, pos);
				continue;
			}
			pos++;
		}
	}
	else if (StrEqual(Config, CONFIG_COMMONAFFIXES)) {
		if (FindStringInArray(TalentKey, "require bile?") == -1) {
			PushArrayString(TalentKey, "require bile?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "raw player strength?") == -1) {
			PushArrayString(TalentKey, "raw player strength?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "raw common strength?") == -1) {
			PushArrayString(TalentKey, "raw common strength?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "raw strength?") == -1) {
			PushArrayString(TalentKey, "raw strength?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "strength special?") == -1) {
			PushArrayString(TalentKey, "strength special?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "onfire interval?") == -1) {
			PushArrayString(TalentKey, "onfire interval?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "onfire max time?") == -1) {
			PushArrayString(TalentKey, "onfire max time?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "onfire level?") == -1) {
			PushArrayString(TalentKey, "onfire level?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "onfire base time?") == -1) {
			PushArrayString(TalentKey, "onfire base time?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "enemy multiplication?") == -1) {
			PushArrayString(TalentKey, "enemy multiplication?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "damage effect?") == -1) {
			PushArrayString(TalentKey, "damage effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "force model?") == -1) {
			PushArrayString(TalentKey, "force model?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "level required?") == -1) {
			PushArrayString(TalentKey, "level required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "death multiplier?") == -1) {
			PushArrayString(TalentKey, "death multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "death interval?") == -1) {
			PushArrayString(TalentKey, "death interval?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "death max time?") == -1) {
			PushArrayString(TalentKey, "death max time?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "death base time?") == -1) {
			PushArrayString(TalentKey, "death base time?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "death effect?") == -1) {
			PushArrayString(TalentKey, "death effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "chain reaction?") == -1) {
			PushArrayString(TalentKey, "chain reaction?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "name?") == -1) {
			PushArrayString(TalentKey, "name?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "health per level?") == -1) {
			PushArrayString(TalentKey, "health per level?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "base health?") == -1) {
			PushArrayString(TalentKey, "base health?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "glow colour?") == -1) {
			PushArrayString(TalentKey, "glow colour?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "glow range?") == -1) {
			PushArrayString(TalentKey, "glow range?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "glow?") == -1) {
			PushArrayString(TalentKey, "glow?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "model size?") == -1) {
			PushArrayString(TalentKey, "model size?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "fire immunity?") == -1) {
			PushArrayString(TalentKey, "fire immunity?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "draw type?") == -1) {
			PushArrayString(TalentKey, "draw type?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "chance?") == -1) {
			PushArrayString(TalentKey, "chance?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "level strength?") == -1) {
			PushArrayString(TalentKey, "level strength?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "strength target?") == -1) {
			PushArrayString(TalentKey, "strength target?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "aura strength?") == -1) {
			PushArrayString(TalentKey, "aura strength?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "cooldown?") == -1) {
			PushArrayString(TalentKey, "cooldown?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "range max?") == -1) {
			PushArrayString(TalentKey, "range max?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "range player level?") == -1) {
			PushArrayString(TalentKey, "range player level?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "range minimum?") == -1) {
			PushArrayString(TalentKey, "range minimum?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "aura effect?") == -1) {
			PushArrayString(TalentKey, "aura effect?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "max allowed?") == -1) {
			PushArrayString(TalentKey, "max allowed?");
			PushArrayString(TalentValue, "-1");
		}
		sortSize = GetArraySize(TalentKey);
		pos = 0;
		while (pos < sortSize) {
			GetArrayString(TalentKey, pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "max allowed?") ||
			pos == 1 && !StrEqual(text, "aura effect?") ||
			pos == 2 && !StrEqual(text, "range minimum?") ||
			pos == 3 && !StrEqual(text, "range player level?") ||
			pos == 4 && !StrEqual(text, "range max?") ||
			pos == 5 && !StrEqual(text, "cooldown?") ||
			pos == 6 && !StrEqual(text, "aura strength?") ||
			pos == 7 && !StrEqual(text, "strength target?") ||
			pos == 8 && !StrEqual(text, "level strength?") ||
			pos == 9 && !StrEqual(text, "chance?") ||
			pos == 10 && !StrEqual(text, "draw type?") ||
			pos == 11 && !StrEqual(text, "fire immunity?") ||
			pos == 12 && !StrEqual(text, "model size?") ||
			pos == 13 && !StrEqual(text, "glow?") ||
			pos == 14 && !StrEqual(text, "glow range?") ||
			pos == 15 && !StrEqual(text, "glow colour?") ||
			pos == 16 && !StrEqual(text, "base health?") ||
			pos == 17 && !StrEqual(text, "health per level?") ||
			pos == 18 && !StrEqual(text, "name?") ||
			pos == 19 && !StrEqual(text, "chain reaction?") ||
			pos == 20 && !StrEqual(text, "death effect?") ||
			pos == 21 && !StrEqual(text, "death base time?") ||
			pos == 22 && !StrEqual(text, "death max time?") ||
			pos == 23 && !StrEqual(text, "death interval?") ||
			pos == 24 && !StrEqual(text, "death multiplier?") ||
			pos == 25 && !StrEqual(text, "level required?") ||
			pos == 26 && !StrEqual(text, "force model?") ||
			pos == 27 && !StrEqual(text, "damage effect?") ||
			pos == 28 && !StrEqual(text, "enemy multiplication?") ||
			pos == 29 && !StrEqual(text, "onfire base time?") ||
			pos == 30 && !StrEqual(text, "onfire level?") ||
			pos == 31 && !StrEqual(text, "onfire max time?") ||
			pos == 32 && !StrEqual(text, "onfire interval?") ||
			pos == 33 && !StrEqual(text, "strength special?") ||
			pos == 34 && !StrEqual(text, "raw strength?") ||
			pos == 35 && !StrEqual(text, "raw common strength?") ||
			pos == 36 && !StrEqual(text, "raw player strength?") ||
			pos == 37 && !StrEqual(text, "require bile?")) {
				ResizeArray(TalentKey, sortSize+1);
				ResizeArray(TalentValue, sortSize+1);
				SetArrayString(TalentKey, sortSize, text);
				GetArrayString(TalentValue, pos, text, sizeof(text));
				SetArrayString(TalentValue, sortSize, text);
				RemoveFromArray(TalentKey, pos);
				RemoveFromArray(TalentValue, pos);
				continue;
			}
			pos++;
		}
	}
	GetArrayString(Handle:Section, size, text, sizeof(text));
	PushArrayString(TalentSection, text);
	/*if (StrEqual(Config, CONFIG_MENUTALENTS) || StrEqual(Config, CONFIG_EVENTS)) {
		LogMessage("%s", text);
		sortSize = GetArraySize(TalentKey);
		for (new i = 0; i < sortSize; i++) {
			GetArrayString(TalentKey, i, key, sizeof(key));
			GetArrayString(TalentValue, i, value, sizeof(value));
			LogMessage("\t\"%s\"\t\t\"%s\"", key, value);
		}
	}*/
	if (StrEqual(Config, CONFIG_MENUTALENTS)) PushArrayString(a_Database_Talents, text);
	ResizeArray(Main, size + 1);
	SetArrayCell(Main, size, TalentKey, 0);
	SetArrayCell(Main, size, TalentValue, 1);
	SetArrayCell(Main, size, TalentSection, 2);
}

public ReadyUp_FwdGetHeader(const String:header[]) {
	strcopy(s_rup, sizeof(s_rup), header);
}

public ReadyUp_FwdGetCampaignName(const String:mapname[]) {
	strcopy(currentCampaignName, sizeof(currentCampaignName), mapname);
}

public ReadyUp_CoopMapFailed(iGamemode) {
	if (!b_IsMissionFailed) {
		b_IsMissionFailed	= true;
		Points_Director = 0.0;
	}
}

// stock bool:IsCommonRegistered(entity) {
// 	if (FindListPositionByEntity(entity, Handle:CommonList) >= 0 ||
// 		FindListPositionByEntity(entity, Handle:CommonInfected) >= 0) return true;
// 	return false;
// }
stock bool:IsSpecialCommon(entity) {
	if (FindListPositionByEntity(entity, Handle:CommonList) >= 0) {
		if (IsCommonInfected(entity)) return true;
		else ClearSpecialCommon(entity, false);
	}
	return false;
}

#include "rpg/rpg_menu.sp"
#include "rpg/rpg_menu_points.sp"
#include "rpg/rpg_menu_store.sp"
#include "rpg/rpg_menu_director.sp"
#include "rpg/rpg_timers.sp"
#include "rpg/rpg_wrappers.sp"
#include "rpg/rpg_events.sp"
#include "rpg/rpg_database.sp"