// (c) Michael "Sky" Toth
// Distributed under the GPLv3 license =)
#define NICK_MODEL						"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL					"models/survivors/survivor_producer.mdl"
#define COACH_MODEL						"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL						"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL						"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL					"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL						"models/survivors/survivor_manager.mdl"
#define BILL_MODEL						"models/survivors/survivor_namvet.mdl"
#define TEAM_SPECTATOR					1
#define TEAM_SURVIVOR					2
#define TEAM_INFECTED					3
#define MAX_ENTITIES					2048
#define MAX_CHAT_LENGTH					1024
#define COOPRECORD_DB					"db_season_coop"
#define SURVRECORD_DB					"db_season_surv"
#define PLUGIN_VERSION					"v3.4.7.8"
#define PROFILE_VERSION					"v1.5"
#define PLUGIN_CONTACT					"github.com/biaspark/"
#define PLUGIN_NAME						"RPG Construction Set"
#define PLUGIN_DESCRIPTION				"Fully-customizable and modular RPG, like the one for Atari."
#define CONFIG_EVENTS					"rpg/events.cfg"
#define CONFIG_MAINMENU					"rpg/mainmenu.cfg"
#define CONFIG_SURVIVORTALENTS			"rpg/talentmenu.cfg"
#define CONFIG_POINTS					"rpg/points.cfg"
#define CONFIG_MAPRECORDS				"rpg/maprecords.cfg"
#define CONFIG_STORE					"rpg/store.cfg"
#define CONFIG_TRAILS					"rpg/trails.cfg"
#define CONFIG_WEAPONS					"rpg/weapondamages.cfg"
#define CONFIG_COMMONAFFIXES			"rpg/commonaffixes.cfg"
#define CONFIG_CLASSNAMES				"rpg/classnames.cfg"
#define CONFIG_HANDICAP					"rpg/handicap.cfg"
#define LOGFILE							"rum_rpg.txt"
#define JETPACK_AUDIO					"ambient/gas/steam2.wav"
#define MODIFIER_HEALING				0
#define MODIFIER_TANKING				1
#define MODIFIER_DAMAGE					2	// not really used...
#define SURVIVOR_STATE_IGNORE			0
#define SURVIVOR_STATE_ENSNARED			1
#define SURVIVOR_STATE_INCAPACITATED	2
#define SURVIVOR_STATE_DEAD				3
#define FALLEN_SURVIVOR_MODEL			"models/infected/common_male_fallen_survivor.mdl"
#define HEALING_CONTRIBUTION			1
#define BUFFING_CONTRIBUTION			2
#define HEXING_CONTRIBUTION				3
//	================================
#define DEBUG     					false
/*	================================
 Version 3.4.7.8
  *** Augments in Profiles ***
	- Augments will now be saved to profiles.
		- When you delete an augment attached to a saved profile, the associated augment slot will be empty after the profile finishes loading.
		- ALL AUGMENTS ARE UNEQUIPPED when loading a profile, so load your profiles, use !loadoutname <current active profile name> then equip your augments and save to have your augments attached to your saved profile.
	- Augments that are saved to at least 1 profile will have the ! symbol at the end of their name.
	- Augments can be attached to as many profiles as you want.
	- The profiles the augments are attached to will be displayed on their profile inspection page.
	- If you missed it above, YOU CAN DELETE AUGMENTS ATTACHED TO PROFILES
	- Autodismantle CANNOT DELETE AUGMENTS ATTACHED TO PROFILES, but you can delete them manually.

  - you will always load into every new round with your preset weapons, and your health fully-loaded.
  	Whether you fail, complete the previous map, you will ALWAYS have everything pre-loaded.
  - Patched a visual bug where when a player only received +healing rating that the bonus would incorrectly show the players tanking bonus, or nothing if there was no tanking bonus.
  - Patched a bug where common infected were never giving score.
	Regarding Common Infected:

	With this update, all players who contribute towards infected common deaths will receive the score reward and assist/contribution experience for damage dealt and tanking received.
	Previously, by design, only the player who landed the killing bow would receive rewards, since common health used to be a static, low value.
	Now, since common infected health pools can reach into the thousands, everyone involved should be rewarded, when applicable.
  - Loading a profile while a round is active will no longer give the survivor the weapons saved to that profile.
  - Fixed a logic typo that caused survivor bots to reset when their level didn't = their starting level, instead of only when it was < their starting level.
  - Patched a bug that caused spectating players on map swap to have their HAT levels double-printed.
  - Patched a bug where players with no augments could not load a saved profile.
  - Patched a bug where players names would have their HAT levels repeatedly added if they were in spectator.
  - Redesigned menu formatting.
  - Patched another bug associated with invalid infected being detected on player_spawn
  - Fixed a typo preventing the jetpack from disabling, causing flying players to fall out of the sky like meteorites when tanks are nearby.
  - Redesigned how the enrage functionality works; enrage multiplier ADDS to the common count, but does not affect finale multiplier or increase z_common_limit past the limit set in the config
  - Patched loot drop pickup so that a player is picking up the correct bag every time.
  - Survivors screens will slightly-shake when they take damage, overriding the normal take damage shake that this plugin prevents from occurring.
	- unfortunately, adding support for the directional attack arrow upon damage taken __is not__ possible here.
  - Patched a bug that caused action ability positions to be set to INTEGER.INTEGER_MAX on generation due to an inaccurate guard statement.
  - Player names will be properly color-formatted when upgrading talents or killing infected.
  - Patched a crash that could occur if a talent loaded then went on cooldown and then ended its cooldown before the players data had finished fully loading.
  - Players who leave combat during finales or enrage on servers that allow it will now properly be rewarded any owed experience.
  - Redesigned/recoded how healing, tanking, and buffing contribution is calculated.
  - Added support for advertisements built into the RPG:
	- {HOST} - replaces the string with the server hostname
	- {RPGCMD} - replaces the string with the server's rpg menu command
	name the translation "server advertisement #"
	example:
	"server advertisement 1"
	{
		"en"	"{O}You are playing at {B}{HOST}\nSay {O}!{B}{RPGCMD} {O}into chat to open the Control Panel!"
	}

	Because advertisements are using minimal code and the translation file in conjunction with smlib for colors, you have to specify in the config.cfg the # of advertisements, or it defaults to 0.
	"number of advertisements?"								"0"
	"delay in seconds between advertisements?"				"180"


 Version 3.4.7.7
  - Fixed a crash that occurs when a player uses the !autodismantle command to clear their inventory, and then tries to inspect an augment that no longer exists.
	- When the command is used, the main menu will be forced up on the players.
  - Loot bags now spawn in different colors depending on rarity:
	- green: minor
	- blue:  major
	- gold:  perfect
  - Added the augment upgrade system! =)
	- 3 new config.cfg keys:				The scrap cost to make a randomized upgrade attempt in any category by default.
		"augment category upgrade cost?"	"50"
		"augment activator upgrade cost?"	"50"
		"augment target upgrade cost?"		"50"

 Version 3.4.7.6.2
  - Fixed a bug that was causing cleric talents to not fire because I had a typo in the GetAbilityStrengthByTrigger arguments.

 Version 3.4.7.6.1
 - Hotfix to patch an index out of bounds error in rpg_wrappers @ 6720 that I missed.

 Version 3.4.7.6
 - Optimized a lot of methods, leapfrogging references and memo's to reduce time complexity.
 - Menu optimizations.
 - Optimized methods associated with action bars talents; abilities/ammo circles;
	- Reduced the # of calculations by eliminating unnecessary calls.
 - Added support for the "holdFire" ability trigger. This triggers when a player is holding down their primary attack key.
 - Added a new talent key, "weapon name required?" which WILL NOT be checked if "weapons permitted?" is not set to -1.
	- Reason: There's no point in checking for a specific weapon required, if an entire category of weapons is specified as allowed.
	- Note: any item considered a weapon can be specified; e.g. "weapon name required?" "first_aid" will cause the talent to require the player have the first aid in hand to activate.
 - Added a redundancy to ensure that if a client joins on the id of a client who crashed, that it will NOT assume they are that client (a steamid check will now occur)
 - All healing received by allies of the activator will now add experience to the activators Medic proficiency.
 - The first page of the augment inventory now shows a players equipped augments, in order, before displaying non-equipped augments.

 Version 3.4.7.5
 - Cleaned-up/Refactored code, resulting in the removal of 1,500+ Arraylists.
	- Some of these were being populated, some of these were not, but none of them were necessary thanks to recent updates to the core RPG framework.
	- Most of these were kv-key lists
		- Most keys no longer need to be stored, since I use a custom sort so that regardless of how talents are filled in the config files, they are always
			formatted in the same way in the code, allowing me to do a FAST GetArrayCell(arraylist, POS_OF_RESULT_NEEDED) call as opposed to having to loop through
			the keys to find the correct index EVERY time.
		These get called from players hundreds or thousands of times per second.
	or
		- lists designed to grab the names of talents.

	However, in recent updates, I began storing these names in a single arraylist that parallels the talentlist arraylist as the talents were streamed-in.
	With the plugin stable, I felt it was a good time to clean some things up.
 - Some more optimzations to other sections of code.
 - Changes to loot pickup/theft code.
 - More memoization! DP DP DP seriously this mod wouldn't be possible w/o it.
 - Fixed an index oob error that could crash the server related to special infected bots.
 - Ledged players can no longer self-revive themselves by holding the use key.
 - Defibrillator override is only called when a player joins mid-round as the defibrillator fix extension functions properly on latest SM.
 - Patched survivor bots so they can never be a higher level than "new bot player starting level?"
 - Fallen survivors can drop defibrillators:
	"fallen survivor defib drop chance base?"	"0.01"		// the base chance a fallen survivor will drop a defib on death.
	"fallen survivor defib drop chance luck?	"0.01"		// multiplies this value against the player who killed the fallen survivor, then adds it to the base chance.
 - Patched out a hardcode that prevented survivor bots from having their talents auto-reset if they were in violation of the talent tree requirements.
	Talent tree requirements are now enforced on survivor bots.
 - Fixed an issue where it would sometimes incorrectly represent the owner of the augment as the person holding the augment, and thus saying the player stole it from themselves.

 Version 3.4.7.4
 - Optimizations, removing most ...Section[client] arraylists as they're deprecated.
 - Code cleanup.

 Version 3.4.7.3
 - Added multiple new ammo circle-focused talents, to let players focus their specialty more towards a spell caster, should that be their wish.
 - Added two new talent triggers:
	"enterammo"		- when a player enters an ammo circle. if the value is set to "any" it triggers on-cooldown when the player enters any ammo circle when they weren't in one before.
	"exitammo"		- when a player exits an ammo circle. if the value is set to "any" it triggers on-cooldown when the player exits an ammo circle, resulting in them not being in any more ammo circles.
	If the field is set to a value other than "any" then the talent will only trigger if the ammo that triggers the state change (in an ammo or not) is that specific ammo type.
 - Added talents for several previously-unused talent effects and one previously-unused ability trigger:
	Trigger:
					"spellbuff"
	Effects:
					"strengthup"
					"activetime"
					"staminacost"
					"cooldown"
					"range"
	These 5 new effects show up on new talents in the default config, and as a result will show up on augments and existing augments, depending on if it's a perfect, or it's major type, will be able to reroll these new categories.
 - Added support for buffing and healing score earning with two new config.cfg keys:
	"rating multiplier buffing?"							"0.1"	// default values if the keys are omitted.
	"rating multiplier healing?"							"0.1"
 - Refactored HasTalentUpgrades(client, char[] TalentName) in rpg_menu.sp

 Version 3.4.7.2
 - Head shots on common infected will now instant kill the common infected, dealing damage equal to their remaining health.
 - Common infected health bars will no longer appear.
 - "enrage time?" set to "0" or less will disable the enrage timer.
 - Patched a bug where action bar ability multipliers were incorrectly calculated. (Credit to Pez for this one)
 - Another optimization pass for action bar abilities.
 - Optimization pass for all abilities/spells, refactoring intensive method calls.
 - Augment Score now shows on the inspect and equip/compare augment screens.
 - Added support for the character sheet showing the players current average augment level with the {AUGAVGLVL} key for use in the translations file.
 - All player data will properly reset when a player leaves, ensuring that no one else ever inherits any part of their data.
 - Added support for individual enrage timers per map, using the syntax cvar "enrage time %s?" in your config.cfg where %s is the mapname - case-sensitive.
 - Added support for FFA loot mode, where any players with FFA loot mode can loot other players bags for themselves, if the other player also has FFA loot on.
	- Players can toggle their loot mode on and off by default in !rpg -> Settings
 - Original owner of an augment is shown on the augment page. If you are the original owner, it will say "You" as the owner.
	- Augments without an owner (from previous builds) will grandfather in and set the owner as whoever is currently holding them.
	- If a player isn't the original owner and doesn't meet the requirement to equip the augment, the missing requirement will be shown to them.
	- Players cannot loot/steal/pickup for the owner a loot bag if both players have FFA loot enabled, if the loot bag's loot score is below the player who is trying to pick it up's autodismantle threshold.
 - Handicap Level, Augment (Avg) Level, and Talent Level all show in chat (HAT)
 - Added !autodismantle perfect as an option; options are now clear/perfect/major/minor
 - Patched an error that could cause a memory leak
 - Fixed a bug where attributes were being calculated twice - they will now calculate their bonus to talents once.
 - Added support for action bar talents being affected by augments, indirectly through new talent triggers that modify those talents.
 - Optimized ammo talent methods; rewrote sections where unnecessary method calls were being used.
 - Fixed a bug where non-compounding talent calls were not calling.
 - Incorporated an unused, new method to compartmentalize multiple keys into a bit-shift call, freeing up 14 keys per talent, across 403 default talents, for over 4,800 freed keys, reducing memory use, and allowing for even more talents!
	- Please see void SetClientEffectState(client) in rpg_wrappers.sp
	- As part of this, added the "target status effect required?" key and redesigned the "activator status effect required?" key to also be bit-based.
	BOTH KEYS USE THE FOLLOWING BITS:
	1;		// ON FIRE		16;		// FROZEN		256;	// NOT BILED		4096;	// ON GROUND
	2;		// ACID BURN	32;		// SCORCHED		512;	// ENSNARED			8192;	// FLYING
	4;		// EXPLODING	64;		// STEAMING		1024;	// NOT ENSNARED		16384;	// CROUCHING
	8;		// SLOWED		128;	// BILED		2048;	// DROWNING
 - Fixed a bug where Infected Defender types were not always shielding other Infected from damage;
 	- Infected will be shielded from all damage, from all damage sources, including talents, even indirectly, if within range of Defender type Infected moving forward.
 - A player can only reflect damage up to their maximum health, even if the enemy infected player were to hit them for more than that value.
*****************FIREWORKS EMOJI*****************FIREWORKS EMOJI**********************FIREWORKS EMOJI***************************FIREWORKS EMOJI********************************
 - All existing talents should now be fully-functional! Saving this version build and posting it so I have something to fall back on when I break it again!
*****************FIREWORKS EMOJI*****************FIREWORKS EMOJI**********************FIREWORKS EMOJI***************************FIREWORKS EMOJI********************************

 Version 3.4.7.1
 - Fixed a bug where any damage dealt to standard common infected would kill it.
 - Added new config.cfg key:
   "invert walk and sprint?"	"1"		// -> Experimental mode, where walk and sprint are inverted; hold shift to sprint, but it comes at the cost of stamina. DOES NOT AFFECT SURVIVOR BOTS.

 - Fixed a bug that was causing stamina-consuming abilities/spells/talents to require more stamina as cost than intended.

 Version 3.4.6.9
 - Rewrote the logic for loading profiles onto other players and onto bots
 - Redesigned database structure for storing/loading saved profiles
 - Redesigned the logic for the !loadprofile command.
 - Optimizations for certain methods that see a lot of traffic.
 - Redesigned how non-player infected enemies die and are removed.

 Version 3.4.6.8
 - The survivors' jetpack will not function when survivors are in the start or end of map safe rooms.
 - Survivors can now take CRUSH damage (damagetype 1 / DMG_CRUSH)
 - Fixed a bug where proficiency talents would return negative numbers instead of the remainder, resulting in talents affected sometimes returning negative results.
 - Potential bug fix for jetpack, will need to investigate preventing jetpack use in the safe area some other way.
 - Enabled Buffing & Hexing experience, but neither currently earn score.
 - Patched a logic error that saw players who enable a handicap under the score earning level not circumventing that requirement and earning score.
   - now all players with handicap will earn score, regardless of meeting that level requirement, if set.
 - Changed the colours used for augment drops for better readability.
 - Fixed a bug where talents that weren't compounding talents would go on cooldown when compounding talents were calculated unintentionally.
   - As a result of this bug fix, talents that are compounding, such as many weapon damage talents, will now properly go on cooldown where they didn't before, regardless of having a cooldown or not.
 - Damage and Tanking contribution requirements have been optionally added.
   "damage contribution?"		"0.1"	// -> Players must deal 10% of any enemies health pool to receive damage score/damage experience.
   "tanking contribution?"		"0.5"	// -> Players must receive 50% of their maximum health (based on current buffs) in damage from an enemy to be eligible for tanking score/tanking experience from said enemy.
 
 Version 3.4.6.7
 - Fixed a typo that caused damage and health regen talents to not calculate properly in v3.4.6.6
 - Added support to give players proficiency levels with the !powerlevel command.
 - Corrected physics behaviour of loot bags so they do NOT interact with players.
 - Recoded how damage reduction and damage penalty talents & abilities are calculated.
 - Fallen Survivor super commons are now unhooked and set to 1 life so when they die they drop items organically.
	If this becomes an issue, I'll code in support for those items to drop off of the fallen survivor and then possibly
	add support for custom item drops special to the fallen survivor.
 - Recoded/redesigned how augment tiers are calculated.

 Version 3.4.6.6
 - Fixed a bug that reintroduced survivor bot name repeating the [handicap] [level] tag in its name.
 - Added a cooldown between uses for the !stuck command:
	"seconds between stuck command use?"	"120"	// default time of 2-minutes
 - Added the ability for server operators to include the option to disable handicap outright, with the "nohandicap" configname for the mainmenu.cfg
 - Several optimization passes.
 - Added a new key for talents:
	"ability category?"		// 0 healing, 1 damage, 2 tanking
	This lets the plugin know which type of proficiencies the talent is affected by without having to code support for each possible value, which would
	make supporting third-party extensions of the RPG impossible.
 - Proficiency talents now reflect their modifiers on all talents in the menu in real-time.
 - A few miscellaneous bug fixes
 - Removed 17 deprecated & unused keys for talents.
 - Cleaned up unused code & deprecated methods.

 Version 3.4.6.5
 - Witches will now startle when taking bullet damage.
 - Optimizations to certain intensive calls;
	void ForcedWeakness(client) integrated into SetClientTalentStrength as this is the only time the value can change.
		added a new variable bForcedWeakness[client] to hold the value of the call.
 - Survivor bot data will no longer save if there is an idle player attached to the bot.
 - A bug causing a player to take over a survivor bots data, overwriting their own data... has been patched.
 - Players who are defibbed back to life have their penalized score, bonus experience multiplier, and handicaps restored. Their lost experience, if applicable, is not restored.
 - Players can now starting with a variable incap health percentage in config.cfg.
	"incap health start?"									"0.5" // default if not present is 0.5 or 50%. If it's set to 100%, incap health regen will tick once and auto-res the player.
 - Added another config.cfg addition to load custom witch settings, but regardless of the key name, it can be used to load ANY other config for custom settings, etc.
	"custom witch config?"									"witch.cfg"	// if the set config cannot be found, nothing happens; no foul.
 - Fixed a bug where abilities (such as basilisk armor or last chance) could make a player immune to damage. This will now cap based on the following (not new) variable in the config.cfg:
	"max damage resistance?"								"0.9"	// if this key is not present, the default is 0.9.
 - Survivors receive a brief (one frame) invulnerability period when entering incap state now.

 Version 3.4.6.4
 - Added first iteration of gear comparator when considering whether to equip a new augment.
 - Reroll functionality is now in the mod!
 - Marketplace is removed - it detracts from the users individual experience in a shared-world.
 - Full augment info is displayed on the augment inventory page.
 - Fixed a bug that replicated survivor bot levels over and over.
 - Added "talent cooldown minimum value?" for talents, so that the starting cooldown time isn't the lowest possible cooldown time.
 - Rolled-back the change that saw attributes only affect augments. Attributes now affect talents - not augments - again.
 - Players can now use the !autodismantle feature for multiple purposes - type the !autodismantle command in chat for more info!
 - Players can now favourite augments they don't want to be destroyed by the !autodismantle command.
 - Players now have their handicap level reset if they die and are no longer eligible for their current handicap level - client is notified.
 - Only medkits can reset the incap count now.
 - FINALLY patched the bug that caused player data to not load properly during live rounds when connecting onto a bot.

 Version 3.4.6.3
 - Survivor bots with handicaps no longer have those handicaps contribute to the common limit.

 Version 3.4.6.2
 - Added a new variable to track whether a melee weapon is equipped or not.
 - Optimized the SetMyWeapons(client) method.
 - Fixed a math bug in GetTalentInfo()
 - Fixed a bug in GetAttributeMultiplier() where I was using the wrong variable for the calculation.
 - Bags will no longer be created and instead augment parts given when a potential item does not meet the players item loot% threshold setting.
 - Players can no longer choose to auto-destroy minor augments specifically under the new auto-dismantle on roll system, as minor augments are determined after the player picks the item up, not at the time of bag generation.
 - Redesigned attributes for linear (instead of exponential) multiplication.
 - Added a new variable to control if attribute talents are additive or multiplicative:
	"are attribute talents multiplicative?"			"0"			// By default, if this key is omitted attribute talents are additive.
 - Tanking now earns score.
 - Tanking now earns experience from common infected.

 Version 3.4.6.1
 
 - Removed hard-coded melee weapon damage cooldown due to potential bug crash related.
 - Redesigned healing to scale off of healing talents, not damage talents. This means healing will no longer scale with damage.
 - Fixed a bug where items in healing or throwable slots could be recorded as a clients weapon and the wrong type of proficiency would get called.
 - Heal strength will now display proper values on the ability bar.
 - Max health capped to 30,000 for survivors because engine breaks around 33k health

 Version 3.4.6.0
 - Fixed a bug in a certain calculation.
 - Optimized memory usage.
 - Optimized keyvalue arrays.
 - Survivor bots will now ignore Defender common affix mobs and hurt them as normal mobs due to the difficulty programming support for L4D2's AI to recognize Defenders.
 - Fixed melee weapon damage not working properly (it was registering as blast/explosion damage)
 - Changed hard-coded melee damage cooldown of 0.25s -> 0.1s
 - Optimized many methods to used memoized data.
 - Handicap levels now increase common infected allowance across the board == living survivor handicap levels.
 - Fixed a logic error causing a visual bug where infected health numbers would not drop (but the health bar would)

 -Rolled-back changes to the GetInfectedAbilityTrigger method as it was causing random crashing without any error logs.

 - Added more new keys for talents:
	"require ally on fire?"							"1"			// If 1, requires a teammate within "coherency range?" to have [Bu]rn stacks from fire.

 Version 3.4.5.9a
 - Spells/Abilities now receive buffs from augments and their governing attribute, where applicable.
 - Corrected an issue where spell/ability stamina cost was always being set to 1.
 - All damage/health of enemies is now calculated in the same method so enemy level/character data always shows accurate values.
 - Patched a rare bug where common infected would be designated as super commons, but not be super commons.
 - Added new keys for talents:
	"must be within coherency of talent?"			"cleric"	// this talent would only trigger if the activating player is within coherency range of a teammates cleric talent.
	"must be unhurt by si or witch?"				"1"			// if 1, talent is skipped if the target is common infected, or if the witch/special infected has hurt the survivor.
	"skip talent for augment roll?"					"1"			// for specialty talents designed for coherency triggers, so they don't roll as buffs on augments as they would buff nothing.
	"require ally with adrenaline?"					"1"			// If 1, must be paired with the "coherency range?" talent. If an ally within the coherency range has active adrenaline, this talent fires.
	"require ally below health percentage?"			"0.5"		// This talent requires an ally within coherency range that is at 50% health or lower.
	"require ensnared ally?"						"1"			// If 1, there must be an ensnared ally within the "coherency range?" for this talent to trigger.
	"target must be ally ensnarer?"					"1"			// If 1, the target of this talent must be a special infected that is ensnaring an ally in range.
	"multiply strength ensnared allies?"			"0.05"		// If > 0.0, increases the talent strength by multiples of this value, for each ensnared ally within "coherency range?"
	"require enemy in coherency range?"				"1"			// If 1, this talent will only activate if there is an enemy within the coherency range. Best used with talents that passively trigger, as they're on a timer.
	"enemy in coherency is target?"					"1"			// If 1, this talent will automatically set the target of the talents "target ability effects?" to an enemy special infected (or survivor) within coherency range.
	"no augment modifiers?"							"1"			// if set to 1, augments will not affect that specific talent
	"health percentage remaining required?" 		"0.75"		// % health required to trigger this talent.
	"health cost on activation?"					"0.01"		// 1% cost to health each time this talent triggers.
	"multiply strength downed allies?"				"0.05"		// % to multiply the talent strength for each incapacitated ally in range. (survivor only)
 - Added the "explosion" "ability trigger?" that fires off whenever a special infected, witch, or common infected takes damage from a pipebomb, fireworks, explosive ammo, or other explosive source triggered by the activator.

 Version 3.4.5.9
 - Added a new method in rpg_wrappers, GetClientsInRangeByState; Added 4 SURVIVOR STATE definitions to accompany it.

 - Several bug fixes:
	- buying ammo now restores the proper amount instead of the vanilla amount.
	- fire no longer triggers talents, and is only buffed if a player has fire damage increasing talents.
	- over-killing special infected will no longer provide more score than intended.
 - Patched an exploit that was being used to circumvent losing bonus multiplier.
 - Fixed a bug where enemy data could become bugged if a players handicap data didn't load properly.
 - Fixed a bug that required a player to swap weapons at the start of the round to activate the correct talents for that weapon.
 - Fixed a bug where common infected triggered OOB errors
 - Fixed a bug wherein super commons could occasionally error and no longer take damage

 There are a lot of keys that I added support for, but are either unused or were commented-out from when the mod had severely-poor time complexity.
 I've gone ahead and re-enabled a key for talents:
 "activator ability trigger to call?"

 I've added a new key that does the above but for the target(s) of talents, and renamed the key above for consistency from "ability trigger to call?"
 "target ability trigger to call?" - for example, being on the receiving end of another players AoE heal ability could fire a specific trigger that could fire off other
 talents, and those talents could each have different scenario requirements, creating even more potential for branching talent builds.

 At this time, the default talentmenu.cfg only contains one talent that takes advantage of this: Blood Warrior I, which triggers Blood Warrior II with this call.
 This means that Blood Warrior II can only trigger when Blood Warrior I triggers, and only triggers at this time if it's not on cooldown. Otherwise it will trigger the next
 time that Blood Warrior I triggers.
 This key allows you to fire off other talents based on certain scenarios, assuming the player has unlocked those talents.

 Version 3.4.5.8a
 - Fixed the double-loading of player augments when loading a saved profile.
 - Fixed a stack overflow bug related to the CreateAoE method - it could indefinitely call itself but that is no longer the case.
 - Fixed an error when a player left that it would not properly set the basename, so new joining players would have their name.
 - Fixed an error that caused new players to sometimes not create data due to a very rare index out of bounds error.
 - Players who are no longer eligible for a handicap level will have it taken from them on load.
 - Changed ability bar active/cooldown times to show as whole numbers instead of floats.

 Version 3.4.5.8
 - Survivor bots now have a handicap set equal to the highest handicap player in the server.
	- Survivor bots handicap level should now also display on their name / when players look @ them.
 - Re-ordered survivor augments to load AFTER the action bar has fully-loaded, to prevent handle/array errors.
 - Survey says I need to find a workaround for data storage when steam servers are down.
 - Fixed a logic error where new players names would be set blank.
 - All minor augments will now disassemble if a player sets minor disassembly to enabled.
	- Previously, minor augments that were "upgradeable" would not be disassembled.
 - Patched an oob error related to memoization of talents; should now be resolved.
 - Redid how common infected health is calculated and removed non-instanced storage of common infected health.
 - Refactored & Memoized ability triggers; redesigned IsAbilityFound in rpg_wrappers.sp
 - Corrected an issue where bot handicap values would not always be set to the correct value.
 - Redesigned damage and health calculations to use a new method called GetInfectedData in rpg_menu.sp
 - Restructured perfect augment menu name representation.
 - Now, target effect augments can roll even if activator effect augments don't roll.
 - Fixed an issue preventing some players with no saved data from saving data for the first time.
 - Finale survival bonus has been moved to the CallRoundIsOver() method, and players will now see the finale bonus if it applies to them.

 Version 3.4.5.7b
 - Patched a bug I created while memoizing action bar talent menu positions =)
 - Refactored/optimized several methods/calls related to the action bar.
 - Changed handicap level in player name to orange text... maybe let SO's customize this?
 - Formatted values in the handicap menu since gains/penalties can rise above 999%

 Version 3.4.5.7a
 - Fixed a bug with slow effect and killtimer.
 - Fixed a bug wherein sometimes players would load without a name.
 - Fixed a crash where survivor bots would save endlessly.
 - ISSLOW variable changed from Handle to bool.
 - Datascreen now reflects which limb a player is aiming at when calculating/showing damage.
 - Fixed a visual error in the menu where ability cooldown and active times were not displaying.
 - Handicap level (if applicable) now shows in chat and as part of player names; eg. [handicap] [level] name
 - Added static definitions for HITGROUP types.
 - Added Handle ActionBarMenuPos[] to memoize menu position of talents assigned to action bars.

 Version 3.4.5.7
 - Added !autodismantle feature. Using the command provides the syntax as a response in chat.
		!autodismantle minor - toggles on/off auto dismantling of minor augments.
		!autodismantle <score> - toggles the auto dismantling of ANY augment that rolls below this score value.
 - Rewrote !giveaugment to support both two methods of giving augments away.
		!giveaugment aim <augment id no.> - gives the augment to the survivor player you're aiming at.
		!giveaugment <name> <augment id no.> - gives the augment to the first survivor found whose name contains the substring provided.

		When a player gives another player an augment, it now will automatically try to re-open the gifters augment inventory.
 - Fixed a bug where the timer for talent cooldowns was not checking that the cooldown array size matched the # of talents, which could happen
   if a player disconnected after the cooldown was created, and that same client ID is replaced by another client before the cooldown finished.

 Version 3.4.5.6
 - Added config.cfg key "level required to earn score?" so new players can get accustomed to the mod for a few levels before difficulty starts to increase.
 - Handicaps, which can be set in handicap.cfg are now fully-integrated into the mod.
 - Added support for players setting a minimum required score for augments or they are auto-dismantled; !autodismantle <score>

 Version 3.4.5.5
 - Talents in talentmenu.cfg now hide/display to users based on whether a survivor or infected class can activate the talent via the "activator class required?" key.
		This should make it so that talents for both infected and survivor can be added to the different categories in each tree, but will only show to eligible players.
 - Fixed a bug that was consistently causing server crash when the start of map checkpoint door opened.
 - Todo: add a new key designed specifically for infected bots for score threshold requirements to activate layered talents.
 - Fixed a memory stack space exceeded error
 - Yay fixed the error that was crashing the server consistently; due to the way saving data works, we cannot do it on round end.
 - Augment equipped positions are saved whenever an augment is unequipped or equipped.
 - Added support for "give augment command?" key, so players can give their augments to other players (does not support selling at the moment)
 - Added Surname support for augments so they aren't bland "minor", "major" and "perfect" augments without souls any longer.
 - Added support for GetInfectedAbilityStrengthByTrigger in rpg_wrappers.sp for laying the ground work for infected talents.
 - Removed a GetAbilityStrengthByTrigger call that shouldn't exist.
 - Added support for hunter and jockey talents.
 - Added the "distance" and "pounced" ability triggers. Distance affects smoker/jockey/charger/hunter.
 - Patched CreatePlayerExplosion in rpg_wrappers.sp and fixed a logic error that caused all special infected/survivors to always get hit by certain explosions even when they were outside of range.

 Version 3.4.5.4
 - Added the "claw" ability trigger, which fires when a special infected hurts a survivor but does not currently have an ensnare victim.
 - Added the "poisonclaw" activator/target effect.
 - Also added the "burnclaw" trigger effect.
		poisonclaw adds a stack of acid burn [Ab] based on the talent strength.
		burnclaw adds a stack of burn [Bu] based on the talent strength.
 - Ability Trigger "v" now fires when a human infected player presses their primary mouse key.
 - "activator class required?" in talentmenu.cfg is no longer deprecated, though omitting the key or setting it to < 0 will ignore it.
		0 (survivor) 1 - smoker 2 - boomer 3 - hunter - 4 spitter - 5 jockey - 6 charger - 7 witch - 8 tank 9 common infected
        Support is added back for this key in preparation of adding special infected talents
 - reminder to swap bool IsClassAllowed(int zombieclass, int classesAllowed) to bitwise in a later update; Should be fast enough for now; this method was quick (and is still relatively fast)

 Version 3.4.5.3d
 - As there is not limitless memory, unlimited inventory space has caused... items to disappear into the ether when server memory is reached.
		- I've added a new kv, "max persistent loot inventory size?" with a default of 50. This should also keep the overall database size down, saving $$$
 - Updated the Central HUD (bottom, black semi-transparent background) text to not display a players level twice when looking at them.
 - Fixed a OOB logic error that could cause a crash when generating major or perfect augments.

 Version 3.4.5.3c
 - Added additional guard statements and checks to ensure that all players and infected are hooked; unhooked players/infected cannot deal/receive damage.
 - Players who are hit by or suffering from bomber explosions [Ex] debuff will be now placed in combat.
 - Refactored the RollLoot method and associated functions.

 Version 3.4.5.3b
 - Fixed a logic error in OnCommonInfectedCreated which didn't initialize common infected into players data pools on spawn
		causing common infected to not take environmental damage until either damaging a survivor or being damaged by a survivor.
 - Bomber explosion debuff will now affect common infected caught in the blast for both the super common death and when players explode.

 Version 3.4.5.3
 - Fixed a bug in Timer_DeleteLootBag in rpg_wrappers.sp that could occasionally cause a server crash.
 - Common infected will no longer be deleted in OnCommonInfectedCreated (also in rpg_wrappers.sp) during inactive rounds, as this could also occasionally cause a server crash.
 - Fixed a bug that could cause a crash when generating new loot for a player.

 Version 3.4.5.2
 - Added the option to specify how many roll attempts are made per player on kills. Note on common kills only the player who killed it gets the rolls.
	"roll attempts on common kill?"
	"roll attempts on supers kill?"
	"roll attempts on specials kill?"
	"roll attempts on witch kill?"
	"roll attempts on tank kill?"

	- These all default to 1, so specify in the config.cfg what the values should be.
	- Added a check when picking up bags to see if it's the same player looting multiple bags in succession. If it is, it'll only display the "x is searching a bag..." notice once every 3 seconds.
	- Refactored the GetBulletOrMeleeHealAmount(healer, target, damage, damagetype, bool isMelee) function in events.sp

 Version 3.4.5.1 Rebalance/redesign
 - Added 6 new ability triggers for new talents designed to stop magetanking (super strong with no drawbacks in all 3 areas) without limiting player agency:
	lessDamageMoreHeals
	lessDamageMoreTanky
	lessTankyMoreHeals
	lessTankyMoreDamage
	lessHealsMoreDamage
	lessHealsMoreTanky
 - Players with no augments equipped (or new players) will now have the proper levels of 0 applied to empty augment slots.
 - Fixed talent active time incorrectly being set to 0.0s for any applicable talent; talents in the menu should now also show the correct value for this.
 - Added wider potential force and potential physics impact ranges to loot bags on spawn.
 - MoreHeals does not apply to self-health regen
 - Fixed CLERIC visual effect not showing
	
	these talents ignore "activator ability effects?" and "target ability effects?" and "activator / target required?" fields should be set to -1 or omitted.
 Version 3.4.4.9a hotfix
 - Fixed an issue where talents reducing incoming damage would reduce the efficacy of talents based on incoming damage, such as thorns.
 - Added rating multiplier for augment levels to balance augments.
 - Fixed a bug where common infected receiving fatal damage would not die from that attack if it was from a bullet.
 - When a client leaves the game, their augment/inventory data is now properly cleared.

 Version 3.4.4.9
 - Fixed visual bugs on talent info screen for abilities with consecutive hit multipliers that were showing -100% instead of the correct value previously.
 - physics objects that can be interacted with can now be generated for loot, to give players a sense of loot being 'physical' objects.
   If loot bags are disabled and the loot system is enabled, loot will be auto-rolled in text chat and given to players automatically if the infected drops anything.
 	- Added new variables associated with this feature:
		"generate interactable loot bags?"						"1"
		"loot bags disappear after this many seconds?"			"10"
		"item drop model?"										"models/props_collectables/backpack.mdl"
 - FINALLY added support for pipe bombs & other explosives dealing variable damage against common infected.
	- values can be increased by talents triggered by "S"
 - Proficiency levels now affect your damage! By default, it's 1% per proficiency level.

 Version 3.4.4.8b
 - Misc bug fixes, performance optimizations.

 Version 3.4.4.8a
 - Second attempt to fix the lag issue.
 - Second attempt to fix certain super commons having a bunch of health.
 - Laying the groundwork for a new augment feature.
 - Added support for end of map loot rolls similar to the end of map rolls in the RPG that Patriot-Games used, this time for augments instead of SLATE/CARTEL.
 - Fixed some entity oob errors resulting from refactoring.
 - Fixed void return type for OnMapStart and OnMapEnd
 - Added a new native to ReadyUp 8.3 so RPG can let ReadyUp know when the round is failed/restarted by a vote of some sorts, either artificial or real.
	- native added: ReadyUp_RoundRestartedByVote();
 - Corrected bug causing end of map loot rolls to not reward to players who were under the augment roll required score.
		  Now, all living players will receive a guaranteed ( by default in my server settings, no idea for other server operators)
		  loot roll, even if they don't meet the requirements to roll augments under normal circumstances.
 + TO DO: Make commons take damage from pipebombs
 + TO DO: Make biled special/common infected be able to take damage from other infected - right now infected have no FF of any kind but this is because
		  It has been a low-priority fix.

 Version 3.4.4.7
 - Redesigned how augments are rolled to be friendlier to player time investment/reward and to bring minor augments in line with major/perfect and major in line with perfect.
   Augments from the augment beta test have been destroyed for all players - I'll be adding a variable to the database to give out free rolls soon, to reward the beta testers.
 - First attempt to fix the massive lag that is caused when a survivor swaps to spectator and back.

 Version 3.4.4.6
 - Added support for anti-camping, so that players too close to "last kill" spots won't earn experience.
   This can be used to enforce varying kinds of 'forward progression'

 Version 3.4.4.5
 - Removed datapack timer while I figure out some stuff.
 - scenario_end should now properly call when the variables are met.

 Version 3.4.4.4
 - Added SetClientTalentStrength(client) to call when an augment is equipped or unequipped.
 + To do: Add a comparator/confirmation screen when selecting an augment slot currently occupied by another augment.
 + Add support for survivor bots to use augments.
*/

#define CVAR_SHOW								FCVAR_NOTIFY
#define DMG_HEADSHOT							2147483648
#define ZOMBIECLASS_SMOKER						1
#define ZOMBIECLASS_BOOMER						2
#define ZOMBIECLASS_HUNTER						3
#define ZOMBIECLASS_SPITTER						4
#define ZOMBIECLASS_JOCKEY						5
#define ZOMBIECLASS_CHARGER						6
#define ZOMBIECLASS_WITCH						7
#define ZOMBIECLASS_TANK						8
#define ZOMBIECLASS_SURVIVOR					0
#define TANKSTATE_TIRED							0
#define TANKSTATE_REFLECT						1
#define TANKSTATE_FIRE							2
#define TANKSTATE_DEATH							3
#define TANKSTATE_TELEPORT						4
#define TANKSTATE_HULK							5
#define EFFECTOVERTIME_ACTIVATETALENT			0
#define EFFECTOVERTIME_GETACTIVETIME			1
#define EFFECTOVERTIME_GETCOOLDOWN				2
#define DMG_SPITTERACID1						263168
#define DMG_SPITTERACID2						265216
#define CONTRIBUTION_TRACKER_HEALING			0
#define CONTRIBUTION_TRACKER_DAMAGE				1
#define CONTRIBUTION_TRACKER_TANKING			2
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <left4dhooks>
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN
public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_CONTACT,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "",
};

// from n^3 to n^2
// weapondamages.cfg
#define WEAPONINFO_DAMAGE						0
#define WEAPONINFO_OFFSET						1
#define WEAPONINFO_AMMO							2
#define WEAPONINFO_RANGE						3
#define WEAPONINFO_RANGE_REQUIRED				4
// for the talentmenu.cfg
#define ABILITY_TYPE							0
#define COMPOUNDING_TALENT						1
#define COMPOUND_WITH							2
#define ACTIVATOR_ABILITY_EFFECTS				3
#define TARGET_ABILITY_EFFECTS					4
#define SECONDARY_EFFECTS						5
#define WEAPONS_PERMITTED						6
#define HEALTH_PERCENTAGE_REQ					7
#define COHERENCY_RANGE							8
#define COHERENCY_MAX							9
#define COHERENCY_REQ							10
#define HEALTH_PERCENTAGE_REQ_TAR_REMAINING		11
#define HEALTH_PERCENTAGE_REQ_TAR_MISSING		12
#define ACTIVATOR_CLASS_REQ						13
#define REQUIRES_ZOOM							14
#define COMBAT_STATE_REQ						15
#define PLAYER_STATE_REQ						16
#define PASSIVE_ABILITY							17
#define REQUIRES_HEADSHOT						18
#define REQUIRES_LIMBSHOT						19
#define ACTIVATOR_STAGGER_REQ					20
#define TARGET_STAGGER_REQ						21
#define CANNOT_TARGET_SELF						22
#define REQ_ADRENALINE_EFFECT					23
#define DISABLE_IF_WEAKNESS						24
#define REQ_WEAKNESS							25
#define TARGET_CLASS_REQ						26
#define REQ_CONSECUTIVE_HITS					27
#define BACKGROUND_TALENT						28
#define STATUS_EFFECT_MULTIPLIER				29
#define MULTIPLY_RANGE							30
#define MULTIPLY_COMMONS						31
#define MULTIPLY_SUPERS							32
#define MULTIPLY_WITCHES						33
#define MULTIPLY_SURVIVORS						34
#define MULTIPLY_SPECIALS						35
#define STRENGTH_INCREASE_ZOOMED				36
#define STRENGTH_INCREASE_TIME_CAP				37
#define STRENGTH_INCREASE_TIME_REQ				38
#define ZOOM_TIME_HAS_MINIMUM_REQ				39
#define HOLDING_FIRE_STRENGTH_INCREASE			40
#define DAMAGE_TIME_HAS_MINIMUM_REQ				41
#define HEALTH_PERCENTAGE_REQ_MISSING			42
#define HEALTH_PERCENTAGE_REQ_MISSING_MAX		43
#define SECONDARY_ABILITY_TRIGGER				44
#define TARGET_IS_SELF							45
#define PRIMARY_AOE								46
#define SECONDARY_AOE							47
#define GET_TALENT_NAME							48
#define GET_TRANSLATION							49
#define GOVERNING_ATTRIBUTE						50
#define TALENT_TREE_CATEGORY					51
#define PART_OF_MENU_NAMED						52
#define GET_TALENT_LAYER						53
#define IS_TALENT_ABILITY						54
#define ACTION_BAR_NAME							55
#define NUM_TALENTS_REQ							56
#define TALENT_UPGRADE_STRENGTH_VALUE			57
#define TALENT_COOLDOWN_STRENGTH_VALUE			58
#define TALENT_ACTIVE_STRENGTH_VALUE			59
#define COOLDOWN_GOVERNOR_OF_TALENT				60
#define TALENT_STRENGTH_HARD_LIMIT				61
#define TALENT_IS_EFFECT_OVER_TIME				62
#define SPECIAL_AMMO_TALENT_STRENGTH			63
#define LAYER_COUNTING_IS_IGNORED				64
#define IS_ATTRIBUTE							65
#define HIDE_TRANSLATION						66
#define TALENT_ROLL_CHANCE						67
// spells
#define SPELL_INTERVAL_PER_POINT				68
#define SPELL_INTERVAL_FIRST_POINT				69
#define SPELL_RANGE_PER_POINT					70
#define SPELL_RANGE_FIRST_POINT					71
#define SPELL_STAMINA_PER_POINT					72
#define SPELL_BASE_STAMINA_REQ					73
#define SPELL_COOLDOWN_PER_POINT				74
#define SPELL_COOLDOWN_FIRST_POINT				75
#define SPELL_COOLDOWN_START					76
#define SPELL_ACTIVE_TIME_PER_POINT				77
#define SPELL_ACTIVE_TIME_FIRST_POINT			78
#define SPELL_AMMO_EFFECT						79
#define SPELL_EFFECT_MULTIPLIER					80
// abilities
#define ABILITY_ACTIVE_EFFECT					81
#define ABILITY_PASSIVE_EFFECT					82
#define ABILITY_COOLDOWN_EFFECT					83
#define ABILITY_IS_REACTIVE						84
#define ABILITY_TEAMS_ALLOWED					85
#define ABILITY_COOLDOWN_STRENGTH				86
#define ABILITY_MAXIMUM_PASSIVE_MULTIPLIER		87
#define ABILITY_MAXIMUM_ACTIVE_MULTIPLIER		88
#define ABILITY_ACTIVE_STATE_ENSNARE_REQ		89
#define ABILITY_ACTIVE_STRENGTH					90
#define ABILITY_PASSIVE_IGNORES_COOLDOWN		91
#define ABILITY_PASSIVE_STATE_ENSNARE_REQ		92
#define ABILITY_PASSIVE_STRENGTH				93
#define ABILITY_PASSIVE_ONLY					94
#define ABILITY_IS_SINGLE_TARGET				95
#define ABILITY_DRAW_DELAY						96
#define ABILITY_ACTIVE_DRAW_DELAY				97
#define ABILITY_PASSIVE_DRAW_DELAY				98
#define ATTRIBUTE_MULTIPLIER					99
#define ATTRIBUTE_USE_THESE_MULTIPLIERS			100
#define ATTRIBUTE_BASE_MULTIPLIER				101
#define ATTRIBUTE_DIMINISHING_MULTIPLIER		102
#define ATTRIBUTE_DIMINISHING_RETURNS			103
#define HUD_TEXT_BUFF_EFFECT_OVER_TIME			104
#define IS_SUB_MENU_OF_TALENTCONFIG				105
#define IS_AURA_INSTEAD							106
#define EFFECT_COOLDOWN_TRIGGER					107
#define EFFECT_INACTIVE_TRIGGER					108
#define ABILITY_REACTIVE_TYPE					109
#define ABILITY_ACTIVE_TIME						110
#define ABILITY_REQ_NO_ENSNARE					111
#define ABILITY_TOGGLE_EFFECT					112
#define ABILITY_COOLDOWN						113
#define EFFECT_ACTIVATE_PER_TICK				114
#define EFFECT_SECONDARY_EPT_ONLY				115
#define ABILITY_ACTIVE_END_ABILITY_TRIGGER		116
#define ABILITY_COOLDOWN_END_TRIGGER			117
#define ABILITY_DOES_DAMAGE						118
#define TALENT_IS_SPELL							119
#define ABILITY_TOGGLE_STRENGTH					120
#define TARGET_AND_LAST_TARGET_CLASS_MATCH		121
#define TARGET_RANGE_REQUIRED					122
#define TARGET_RANGE_REQUIRED_OUTSIDE			123
#define TARGET_MUST_BE_LAST_TARGET				124
#define ACTIVATOR_MUST_HAVE_HIGH_GROUND			125
#define TARGET_MUST_HAVE_HIGH_GROUND			126
#define ACTIVATOR_TARGET_MUST_EVEN_GROUND		127
#define ABILITY_EVENT_TYPE						128
#define LAST_KILL_MUST_BE_HEADSHOT				129
#define MULT_STR_CONSECUTIVE_HITS				130
#define MULT_STR_CONSECUTIVE_MAX				131
#define MULT_STR_CONSECUTIVE_DIV				132
#define CONTRIBUTION_TYPE_CATEGORY				133
#define CONTRIBUTION_COST						134
#define ITEM_NAME_TO_GIVE_PLAYER				135
#define HIDE_TALENT_STRENGTH_DISPLAY			136
#define ACTIVATOR_CALL_ABILITY_TRIGGER			137
#define TALENT_WEAPON_SLOT_REQUIRED				138
#define REQ_CONSECUTIVE_HEADSHOTS				139
#define MULT_STR_CONSECUTIVE_HEADSHOTS			140
#define MULT_STR_CONSECUTIVE_HEADSHOTS_MAX		141
#define MULT_STR_CONSECUTIVE_HEADSHOTS_DIV		142
#define IF_EOT_ACTIVE_ALLOW_ALL_WEAPONS			143
#define IF_EOT_ACTIVE_ALLOW_ALL_HITGROUPS		144
#define IF_EOT_ACTIVE_ALLOW_ALL_ENEMIES			145
#define ACTIVATOR_STATUS_EFFECT_REQUIRED		146
#define HEALTH_PERCENTAGE_REQ_ACT_REMAINING 	147
#define HEALTH_PERCENTAGE_ACTIVATION_COST		148
#define MULT_STR_NEARBY_DOWN_ALLIES				149
#define MULT_STR_NEARBY_ENSNARED_ALLIES			150
#define TALENT_NO_AUGMENT_MODIFIERS				151
#define TARGET_CALL_ABILITY_TRIGGER				152
#define COHERENCY_TALENT_NEARBY_REQUIRED		153
#define UNHURT_BY_SPECIALINFECTED_OR_WITCH		154
#define SKIP_TALENT_FOR_AUGMENT_ROLL			155
#define REQUIRE_ALLY_WITH_ADRENALINE			156
#define REQUIRE_ALLY_BELOW_HEALTH_PERCENTAGE	157
#define REQUIRE_ENSNARED_ALLY					158
#define REQUIRE_TARGET_HAS_ENSNARED_ALLY		159
#define REQUIRE_ENEMY_IN_COHERENCY_RANGE		160
#define ENEMY_IN_COHERENCY_IS_TARGET			161
#define REQUIRE_ALLY_ON_FIRE					162
#define TALENT_MINIMUM_COOLDOWN_TIME			163
#define ABILITY_CATEGORY						164
#define TARGET_STATUS_EFFECT_REQUIRED			165
#define ACTIVATOR_MUST_BE_IN_AMMO				166
#define TARGET_MUST_BE_IN_AMMO					167
#define TIME_SINCE_LAST_ACTIVATOR_ATTACK		168
#define WEAPON_NAME_REQUIRED					169
// because this value changes when we increase the static list of key positions
// we should create a reference for the IsAbilityFound method, so that it doesn't waste time checking keys that we know aren't equal.
#define TALENT_FIRST_RANDOM_KEY_POSITION		170
#define SUPER_COMMON_MAX_ALLOWED				0
#define SUPER_COMMON_AURA_EFFECT				1
#define SUPER_COMMON_RANGE_MIN					2
#define SUPER_COMMON_RANGE_PLAYER_LEVEL			3
#define SUPER_COMMON_RANGE_MAX					4
#define SUPER_COMMON_COOLDOWN					5
#define SUPER_COMMON_AURA_STRENGTH				6
#define SUPER_COMMON_STRENGTH_TARGET			7
#define SUPER_COMMON_LEVEL_STRENGTH				8
#define SUPER_COMMON_SPAWN_CHANCE				9
#define SUPER_COMMON_DRAW_TYPE					10
#define SUPER_COMMON_FIRE_IMMUNITY				11
#define SUPER_COMMON_MODEL_SIZE					12
#define SUPER_COMMON_GLOW						13
#define SUPER_COMMON_GLOW_RANGE					14
#define SUPER_COMMON_GLOW_COLOUR				15
#define SUPER_COMMON_BASE_HEALTH				16
#define SUPER_COMMON_HEALTH_PER_LEVEL			17
#define SUPER_COMMON_NAME						18
#define SUPER_COMMON_CHAIN_REACTION				19
#define SUPER_COMMON_DEATH_EFFECT				20
#define SUPER_COMMON_DEATH_BASE_TIME			21
#define SUPER_COMMON_DEATH_MAX_TIME				22
#define SUPER_COMMON_DEATH_INTERVAL				23
#define SUPER_COMMON_DEATH_MULTIPLIER			24
#define SUPER_COMMON_LEVEL_REQ					25
#define SUPER_COMMON_FORCE_MODEL				26
#define SUPER_COMMON_DAMAGE_EFFECT				27
#define SUPER_COMMON_ENEMY_MULTIPLICATION		28
#define SUPER_COMMON_ONFIRE_BASE_TIME			29
#define SUPER_COMMON_ONFIRE_LEVEL				30
#define SUPER_COMMON_ONFIRE_MAX_TIME			31
#define SUPER_COMMON_ONFIRE_INTERVAL			32
#define SUPER_COMMON_STRENGTH_SPECIAL			33
#define SUPER_COMMON_RAW_STRENGTH				34
#define SUPER_COMMON_RAW_COMMON_STRENGTH		35
#define SUPER_COMMON_RAW_PLAYER_STRENGTH		36
#define SUPER_COMMON_REQ_BILED_SURVIVORS		37
#define SUPER_COMMON_FIRST_RANDOM_KEY_POS		38
// for the events.cfg
#define EVENT_PERPETRATOR						0
#define EVENT_VICTIM							1
#define EVENT_SAMETEAM_TRIGGER					2
#define EVENT_PERPETRATOR_TEAM_REQ				3
#define EVENT_PERPETRATOR_ABILITY_TRIGGER		4
#define EVENT_VICTIM_TEAM_REQ					5
#define EVENT_VICTIM_ABILITY_TRIGGER			6
#define EVENT_DAMAGE_TYPE						7
#define EVENT_GET_HEALTH						8
#define EVENT_DAMAGE_AWARD						9
#define EVENT_GET_ABILITIES						10
#define EVENT_IS_PLAYER_NOW_IT					11
#define EVENT_IS_ORIGIN							12
#define EVENT_IS_DISTANCE						13
#define EVENT_MULTIPLIER_POINTS					14
#define EVENT_MULTIPLIER_EXPERIENCE				15
#define EVENT_IS_SHOVED							16
#define EVENT_IS_BULLET_IMPACT					17
#define EVENT_ENTERED_SAFEROOM					18
// for handicap.cfg
#define HANDICAP_TRANSLATION					0
#define HANDICAP_DAMAGE							1
#define HANDICAP_HEALTH							2
#define HANDICAP_LOOTFIND						3
#define HANDICAP_SCORE_REQUIRED					4
#define HANDICAP_SCORE_MULTIPLIER				5
// for easier tracking of hitgroups and insurance against inverting values while coding
#define HITGROUP_LIMB		2
#define HITGROUP_HEAD		1
#define HITGROUP_OTHER		0
// for easier tracking of contribution types
#define CONTRIBUTION_AWARD_DAMAGE				0
#define CONTRIBUTION_AWARD_TANKING				1
#define CONTRIBUTION_AWARD_BUFFING				2
#define CONTRIBUTION_AWARD_HEALING				3

int iNumAdvertisements = 0;
int iAdvertisementCounter = 0;
int clientDeathTime[MAXPLAYERS + 1];
float fPainPillsHealAmount;
char customProfileKey[MAXPLAYERS + 1][64];
int augmentLoadPos[MAXPLAYERS + 1];
bool bIsLoadingCustomProfile[MAXPLAYERS + 1];
int iAugmentCategoryUpgradeCost;
int iAugmentActivatorUpgradeCost;
int iAugmentTargetUpgradeCost;
Handle augmentInventoryPosition[MAXPLAYERS + 1];
char currentClientSteamID[MAXPLAYERS + 1][64];
float fFallenSurvivorDefibChance;
float fFallenSurvivorDefibChanceLuck;
float fRewardPenaltyIfSurvivorBot;
int myCurrentTeam[MAXPLAYERS + 1];
Handle GetCoherencyValues[MAXPLAYERS + 1];
bool bClientIsInAnyAmmo[MAXPLAYERS + 1];
float fUpdateClientInterval;
float fAugmentLevelDifferenceForStolen;
int playerCurrentAugmentAverageLevel[MAXPLAYERS + 1];
int iDontAllowLootStealing[MAXPLAYERS + 1];
int clientEffectState[MAXPLAYERS + 1];
int iExperimentalMode;
float fTankingContribution;
float fDamageContribution;
float fHealingContribution;
float fBuffingContribution;
Handle GetValueFloatArray[MAXPLAYERS + 1];
int iStuckDelayTime;
int lastStuckTime[MAXPLAYERS + 1];
float fIncapHealthStartPercentage;
Handle tempStorage;
int iCurrentIncapCount[MAXPLAYERS + 1];
Handle ListOfWitchesWhoHaveBeenShot;
Handle ClientsPermittedToLoad;
bool b_IsIdle[MAXPLAYERS + 1];
Handle OnDeathHandicapValues[MAXPLAYERS + 1];
Handle EquipAugmentPanel[MAXPLAYERS + 1];
int iAugmentsAffectCooldowns;
int augmentRerollBuffPos[MAXPLAYERS + 1];
int augmentRerollBuffPosToSkip[MAXPLAYERS + 1];
int augmentRerollBuffType[MAXPLAYERS + 1];
int iAugmentCategoryRerollCost;
int iAugmentActivatorRerollCost;
int iAugmentTargetRerollCost;
int augmentSlotToEquipOn[MAXPLAYERS + 1];
int iMaximumCommonsPerPlayer;
bool hasMeleeWeaponEquipped[MAXPLAYERS + 1];
int iMaximumTanksPerPlayer;
Handle ModelsToPrecache;
Handle TalentMenuConfigs;
Handle TalentKey;
Handle TalentValue;
Handle TalentSection;
Handle TalentKeys;
Handle TalentValues;
Handle TalentSections;
Handle TalentTriggers;
Handle GetStrengthFloat[MAXPLAYERS + 1];
Handle TalentPositionsWithEffectName[MAXPLAYERS + 1];
Handle PlayerBuffVals[MAXPLAYERS + 1];
Handle AbilityTriggerValues[MAXPLAYERS + 1];
float fNoHandicapScoreMultiplier;
int iplayerDismantleMinorAugments[MAXPLAYERS + 1];
int iplayerSettingAutoDismantleScore[MAXPLAYERS + 1];
Handle SetHandicapValues[MAXPLAYERS + 1];
Handle HandicapSelectedValues[MAXPLAYERS + 1];
Handle HandicapValues[MAXPLAYERS + 1];
int iLevelRequiredToEarnScore;
int handicapLevel[MAXPLAYERS + 1];
int lastHealthDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
int iClientTypeToDisplayOnKill;
char MyCurrentWeapon[MAXPLAYERS + 1][64];
int takeDamageEvent[MAXPLAYERS + 1][2];
Handle possibleLootPool[MAXPLAYERS + 1];
int iSurvivorBotsAreImmuneToFireDamage;
int showNumLivingSurvivorsInHostname;
int iHideEnrageTimerUntilSecondsLeft;
float fTeleportTankHeightDistance;
//char playerChatClassName[MAXPLAYERS+1][64];
bool bWeaknessAssigned[MAXPLAYERS + 1];
int LastTargetClass[MAXPLAYERS + 1];
int iHealingPlayerInCombatPutInCombat;
Handle TimeOfEffectOverTime;
Handle EffectOverTime;
Handle currentEquippedWeapon[MAXPLAYERS + 1];	// bullets fired from current weapon; variable needs to be renamed.
Handle GetCategoryStrengthValues[MAXPLAYERS + 1];
bool bIsDebugEnabled = false;
int pistolXP[MAXPLAYERS + 1];
int meleeXP[MAXPLAYERS + 1];
int uziXP[MAXPLAYERS + 1];
int shotgunXP[MAXPLAYERS + 1];
int sniperXP[MAXPLAYERS + 1];
int assaultXP[MAXPLAYERS + 1];
int medicXP[MAXPLAYERS + 1];
int grenadeXP[MAXPLAYERS + 1];
float fProficiencyExperienceMultiplier;
float fProficiencyExperienceEarned;
//new iProficiencyMaxLevel;
int iProficiencyStart;
int iMaxIncap;
int iTanksPreset;
int ProgressEntity[MAXPLAYERS + 1];
//new Float:fScoutBonus;
//new Float:fTotemRating;
int iSurvivorRespawnRestrict;
bool bIsDefenderTank[MAXPLAYERS + 1];
float fOnFireDebuffDelay;
float fOnFireDebuff[MAXPLAYERS + 1];
//new iOnFireDebuffLimit;
int iSkyLevelMax;
int SkyLevel[MAXPLAYERS + 1];
int iIsSpecialFire;
Handle hThreatSort;
bool bIsHideThreat[MAXPLAYERS + 1];
//new Float:fTankThreatBonus;
int iTopThreat;
int iThreatLevel[MAXPLAYERS + 1];
int iThreatLevel_temp[MAXPLAYERS + 1];
Handle hThreatMeter;
int forceProfileOnNewPlayers;
bool bEquipSpells[MAXPLAYERS + 1];
Handle LoadoutConfigKeys[MAXPLAYERS + 1];
Handle LoadoutConfigValues[MAXPLAYERS + 1];
Handle LoadoutConfigSection[MAXPLAYERS + 1];
bool bIsGiveProfileItems[MAXPLAYERS + 1];
char sProfileLoadoutConfig[64];
int iIsWeaponLoadout[MAXPLAYERS + 1];
int iAwardBroadcast;
int iSurvivalCounter;
int iRestedDonator;
int iRestedRegular;
int iRestedSecondsRequired;
int iRestedMaximum;
int iFriendlyFire;
char sDonatorFlags[10];
float fDeathPenalty;
int iHardcoreMode;
int iDeathPenaltyPlayers;
Handle RoundStatistics;
bool bRushingNotified[MAXPLAYERS + 1];
bool bHasTeleported[MAXPLAYERS + 1];
bool IsAirborne[MAXPLAYERS + 1];
Handle RandomSurvivorClient;
int eBackpack[MAXPLAYERS + 1];
bool b_IsFinaleTanks;
char RatingType[64];
bool bJumpTime[MAXPLAYERS + 1];
float JumpTime[MAXPLAYERS + 1];
Handle AbilityConfigValues[MAXPLAYERS + 1];
bool IsGroupMember[MAXPLAYERS + 1];
int IsGroupMemberTime[MAXPLAYERS + 1];
Handle IsAbilityValues[MAXPLAYERS + 1];
Handle CheckAbilityKeys[MAXPLAYERS + 1];
Handle CheckAbilityValues[MAXPLAYERS + 1];
int StrugglePower[MAXPLAYERS + 1];
Handle CastValues[MAXPLAYERS + 1];
int ActionBarSlot[MAXPLAYERS + 1];
Handle ActionBarMenuPos[MAXPLAYERS + 1];
Handle ActionBar[MAXPLAYERS + 1];
bool DisplayActionBar[MAXPLAYERS + 1];
int ConsecutiveHits[MAXPLAYERS + 1];
int MyVomitChase[MAXPLAYERS + 1];
float JetpackRecoveryTime[MAXPLAYERS + 1];
bool b_IsHooked[MAXPLAYERS + 1];
int IsPvP[MAXPLAYERS + 1];
bool bJetpack[MAXPLAYERS + 1];
//new ServerLevelRequirement;
Handle TalentsAssignedValues[MAXPLAYERS + 1];
Handle CartelValueValues[MAXPLAYERS + 1];
int ReadyUpGameMode;
bool b_IsLoaded[MAXPLAYERS + 1];
bool LoadDelay[MAXPLAYERS + 1];
int LoadTarget[MAXPLAYERS + 1];
char CompanionNameQueue[MAXPLAYERS + 1][64];
bool HealImmunity[MAXPLAYERS + 1];
char Hostname[64];
char ProfileLoadQueue[MAXPLAYERS + 1][64];
bool bIsSettingsCheck;
Handle SuperCommonQueue;
bool bIsCrushCooldown[MAXPLAYERS + 1];
bool bIsBurnCooldown[MAXPLAYERS + 1];
bool ISBILED[MAXPLAYERS + 1];
int Rating[MAXPLAYERS + 1];
float RoundExperienceMultiplier[MAXPLAYERS + 1];
int BonusContainer[MAXPLAYERS + 1];
int CurrentMapPosition;
int DoomTimer;
bool b_IsRescueVehicleArrived;
int CleanseStack[MAXPLAYERS + 1];
float CounterStack[MAXPLAYERS + 1];
int MultiplierStack[MAXPLAYERS + 1];
char BuildingStack[MAXPLAYERS + 1];
Handle TempAttributes[MAXPLAYERS + 1];
Handle TempTalents[MAXPLAYERS + 1];
Handle PlayerProfiles[MAXPLAYERS + 1];
char LoadoutName[MAXPLAYERS + 1][64];
bool b_IsSurvivalIntermission;
float ISDAZED[MAXPLAYERS + 1];
//new Float:ExplodeTankTimer[MAXPLAYERS + 1];
int TankState[MAXPLAYERS + 1];
//new LastAttacker[MAXPLAYERS + 1];
bool b_IsFloating[MAXPLAYERS + 1];
//new Float:JumpPosition[MAXPLAYERS + 1][2][3];
float LastDeathTime[MAXPLAYERS + 1];
float SurvivorEnrage[MAXPLAYERS + 1][2];
int bHasWeakness[MAXPLAYERS + 1];
bool bForcedWeakness[MAXPLAYERS + 1];
int HexingContribution[MAXPLAYERS + 1];
int BuffingContribution[MAXPLAYERS + 1];
int HealingContribution[MAXPLAYERS + 1];
int TankingContribution[MAXPLAYERS + 1];
int CleansingContribution[MAXPLAYERS + 1];
float PointsContribution[MAXPLAYERS + 1];
int DamageContribution[MAXPLAYERS + 1];
float ExplosionCounter[MAXPLAYERS + 1][2];
Handle CoveredInVomit;
bool AmmoTriggerCooldown[MAXPLAYERS + 1];
Handle SpecialAmmoEffectValues[MAXPLAYERS + 1];
Handle ActiveAmmoCooldownValues[MAXPLAYERS + 1];
Handle PlayActiveAbilities[MAXPLAYERS + 1];
Handle PlayerActiveAmmo[MAXPLAYERS + 1];
Handle DrawSpecialAmmoKeys[MAXPLAYERS + 1];
Handle DrawSpecialAmmoValues[MAXPLAYERS + 1];
Handle SpecialAmmoStrengthValues[MAXPLAYERS + 1];
Handle WeaponLevel[MAXPLAYERS + 1];
Handle ExperienceBank[MAXPLAYERS + 1];
Handle MenuPosition[MAXPLAYERS + 1];
Handle IsClientInRangeSAValues[MAXPLAYERS + 1];
Handle SpecialAmmoData;
Handle SpecialAmmoSave;
float MovementSpeed[MAXPLAYERS + 1];
int IsPlayerDebugMode[MAXPLAYERS + 1];
char ActiveSpecialAmmo[MAXPLAYERS + 1][64];
float IsSpecialAmmoEnabled[MAXPLAYERS + 1][4];
bool bIsInCombat[MAXPLAYERS + 1];
float CombatTime[MAXPLAYERS + 1];
bool bIsSurvivorFatigue[MAXPLAYERS + 1];
int SurvivorStamina[MAXPLAYERS + 1];
float SurvivorConsumptionTime[MAXPLAYERS + 1];
float SurvivorStaminaTime[MAXPLAYERS + 1];
bool ISSLOW[MAXPLAYERS + 1];
float fSlowSpeed[MAXPLAYERS + 1];
Handle ISFROZEN[MAXPLAYERS + 1];
float ISEXPLODETIME[MAXPLAYERS + 1];
Handle ISEXPLODE[MAXPLAYERS + 1];
Handle ISBLIND[MAXPLAYERS + 1];
Handle EntityOnFire;
Handle EntityOnFireName;
Handle CommonInfected[MAXPLAYERS + 1];
Handle RCAffixes[MAXPLAYERS + 1];
Handle h_CommonKeys;
Handle h_CommonValues;
Handle SearchKey_Section;
Handle h_CAKeys;
Handle h_CAValues;
Handle CommonList;
Handle CommonAffixes;// the array holding the common entity id and the affix associated with the common infected. If multiple affixes, multiple keyvalues for the entity id will be created instead of multiple entries.
Handle a_CommonAffixes;			// the array holding the config data
Handle a_HandicapLevels;		// handicap levels so we can customize them at any time in a config file and nothing has to be hard-coded.
int UpgradesAwarded[MAXPLAYERS + 1];
int UpgradesAvailable[MAXPLAYERS + 1];
bool b_IsDead[MAXPLAYERS + 1];
int ExperienceDebt[MAXPLAYERS + 1];
Handle damageOfSpecialInfected;
Handle damageOfWitch;
Handle damageOfSpecialCommon;
Handle damageOfCommonInfected;
Handle InfectedHealth[MAXPLAYERS + 1];
Handle SpecialCommon[MAXPLAYERS + 1];
Handle WitchList;
Handle WitchDamage[MAXPLAYERS + 1];
Handle Give_Store_Keys;
Handle Give_Store_Values;
Handle Give_Store_Section;
bool bIsMeleeCooldown[MAXPLAYERS + 1];
Handle a_WeaponDamages;
char Public_LastChatUser[64];
char Infected_LastChatUser[64];
char Survivor_LastChatUser[64];
char Spectator_LastChatUser[64];
char currentCampaignName[64];
Handle h_KilledPosition_X[MAXPLAYERS + 1];
Handle h_KilledPosition_Y[MAXPLAYERS + 1];
Handle h_KilledPosition_Z[MAXPLAYERS + 1];
bool bIsEligibleMapAward[MAXPLAYERS + 1];
bool b_FirstLoad = false;
bool b_MapStart = false;
bool b_HardcoreMode[MAXPLAYERS + 1];
int PreviousRoundIncaps[MAXPLAYERS + 1];
int RoundIncaps[MAXPLAYERS + 1];
char CONFIG_MAIN[64];
bool b_IsCampaignComplete;
bool b_IsRoundIsOver;
bool b_IsCheckpointDoorStartOpened;
int resr[MAXPLAYERS + 1];
int LastPlayLength[MAXPLAYERS + 1];
int RestedExperience[MAXPLAYERS + 1];
int MapRoundsPlayed;
char LastSpoken[MAXPLAYERS + 1][512];
Handle RPGMenuPosition[MAXPLAYERS + 1];
bool b_IsInSaferoom[MAXPLAYERS + 1];
Handle hDatabase												=	INVALID_HANDLE;
char ConfigPathDirectory[64];
char LogPathDirectory[64];
char PurchaseTalentName[MAXPLAYERS + 1][64];
int PurchaseTalentPoints[MAXPLAYERS + 1];
Handle a_Trails;
Handle TrailsKeys[MAXPLAYERS + 1];
Handle TrailsValues[MAXPLAYERS + 1];
bool b_IsFinaleActive;
int RoundDamage[MAXPLAYERS + 1];
//int RoundDamageTotal;
int SpecialsKilled;
Handle MOTValues[MAXPLAYERS + 1];
Handle DamageValues[MAXPLAYERS + 1];
Handle DamageSection[MAXPLAYERS + 1];
Handle BoosterKeys[MAXPLAYERS + 1];
Handle BoosterValues[MAXPLAYERS + 1];
Handle StoreChanceKeys[MAXPLAYERS + 1];
Handle StoreChanceValues[MAXPLAYERS + 1];
char PathSetting[64];
int OriginalHealth[MAXPLAYERS + 1];
bool b_IsLoadingStore[MAXPLAYERS + 1];
int FreeUpgrades[MAXPLAYERS + 1];
Handle StoreTimeKeys[MAXPLAYERS + 1];
Handle StoreTimeValues[MAXPLAYERS + 1];
Handle StoreKeys[MAXPLAYERS + 1];
Handle StoreValues[MAXPLAYERS + 1];
Handle StoreMultiplierKeys[MAXPLAYERS + 1];
Handle StoreMultiplierValues[MAXPLAYERS + 1];
Handle a_Store_Player[MAXPLAYERS + 1];
bool b_IsLoadingTrees[MAXPLAYERS + 1];
bool b_IsArraysCreated[MAXPLAYERS + 1];
Handle a_Store;
int PlayerUpgradesTotal[MAXPLAYERS + 1];
float f_TankCooldown;
float DeathLocation[MAXPLAYERS + 1][3];
int TimePlayed[MAXPLAYERS + 1];
bool b_IsLoading[MAXPLAYERS + 1];
int LastLivingSurvivor;
float f_OriginStart[MAXPLAYERS + 1][3];
float f_OriginEnd[MAXPLAYERS + 1][3];
int t_Distance[MAXPLAYERS + 1];
int t_Healing[MAXPLAYERS + 1];
bool b_IsActiveRound;
bool b_IsFirstPluginLoad;
char s_rup[32];
Handle MainKeys;
Handle MainValues;
Handle a_Menu_Talents;
Handle a_Menu_Main;
Handle a_Events;
Handle a_Points;
Handle a_Pets;
Handle a_Database_Talents;
Handle a_Database_Talents_Defaults;
Handle a_Database_Talents_Defaults_Name;
Handle MenuKeys[MAXPLAYERS + 1];
Handle MenuValues[MAXPLAYERS + 1];
Handle AbilityMultiplierCalculator[MAXPLAYERS + 1];
Handle MenuSection[MAXPLAYERS + 1];
Handle TriggerValues[MAXPLAYERS + 1];
Handle PreloadTalentValues[MAXPLAYERS + 1];
Handle MyTalentStrengths[MAXPLAYERS + 1];
Handle MyTalentStrength[MAXPLAYERS + 1];
Handle AbilityKeys[MAXPLAYERS + 1];
Handle AbilityValues[MAXPLAYERS + 1];
Handle ChanceValues[MAXPLAYERS + 1];
Handle PurchaseKeys[MAXPLAYERS + 1];
Handle PurchaseValues[MAXPLAYERS + 1];
Handle EventSection;
Handle HookSection;
Handle CallKeys;
Handle CallValues;
Handle DirectorKeys;
Handle DirectorValues;
Handle DatabaseKeys;
Handle DatabaseValues;
Handle DatabaseSection;
Handle a_Database_PlayerTalents_Bots;
Handle PlayerAbilitiesCooldown_Bots;
Handle PlayerAbilitiesImmune_Bots;
Handle LoadDirectorSection;
Handle QueryDirectorKeys;
Handle QueryDirectorValues;
Handle QueryDirectorSection;
Handle FirstDirectorKeys;
Handle FirstDirectorValues;
Handle FirstDirectorSection;
Handle a_Database_PlayerTalents[MAXPLAYERS + 1];
Handle a_Database_PlayerTalents_Experience[MAXPLAYERS + 1];
Handle PlayerAbilitiesName;
Handle PlayerAbilitiesCooldown[MAXPLAYERS + 1];
Handle a_DirectorActions;
Handle a_DirectorActions_Cooldown;
int PlayerLevel[MAXPLAYERS + 1];
int PlayerLevelUpgrades[MAXPLAYERS + 1];
int TotalTalentPoints[MAXPLAYERS + 1];
int ExperienceLevel[MAXPLAYERS + 1];
int SkyPoints[MAXPLAYERS + 1];
char MenuSelection[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char MenuSelection_p[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char MenuName_c[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float Points[MAXPLAYERS + 1];
int DamageAward[MAXPLAYERS + 1][MAXPLAYERS + 1];
int DefaultHealth[MAXPLAYERS + 1];
char white[4];
char green[4];
char blue[4];
char orange[4];
bool b_IsBlind[MAXPLAYERS + 1];
bool b_IsImmune[MAXPLAYERS + 1];
float SpeedMultiplier[MAXPLAYERS + 1];
float SpeedMultiplierBase[MAXPLAYERS + 1];
bool b_IsJumping[MAXPLAYERS + 1];
Handle g_hEffectAdrenaline = INVALID_HANDLE;
Handle g_hCallVomitOnPlayer = INVALID_HANDLE;
Handle hRoundRespawn = INVALID_HANDLE;
Handle g_hCreateAcid = INVALID_HANDLE;
float GravityBase[MAXPLAYERS + 1];
bool b_GroundRequired[MAXPLAYERS + 1];
int CoveredInBile[MAXPLAYERS + 1][MAXPLAYERS + 1];
int CommonKills[MAXPLAYERS + 1];
int CommonKillsHeadshot[MAXPLAYERS + 1];
char OpenedMenu_p[MAXPLAYERS + 1][512];
char OpenedMenu[MAXPLAYERS + 1][512];
int ExperienceOverall[MAXPLAYERS + 1];
int ExperienceLevel_Bots;
int PlayerLevel_Bots;
float Points_Director;
Handle CommonInfectedQueue;
int g_oAbility = 0;
Handle g_hIsStaggering = INVALID_HANDLE;
Handle g_hSetClass = INVALID_HANDLE;
Handle g_hCreateAbility = INVALID_HANDLE;
Handle gd = INVALID_HANDLE;
bool b_IsDirectorTalents[MAXPLAYERS + 1];
int LoadPos[MAXPLAYERS + 1];
int LoadPos_Director;
ConVar g_Steamgroup;
ConVar g_svCheats;
ConVar g_Gamemode;
int RoundTime;
int g_iSprite = 0;
int g_BeaconSprite = 0;
int iNoSpecials;
bool b_HasDeathLocation[MAXPLAYERS + 1];
bool b_IsMissionFailed;
Handle CCASection;
Handle CCAKeys;
Handle CCAValues;
int LastWeaponDamage[MAXPLAYERS + 1];
float UseItemTime[MAXPLAYERS + 1];
Handle NewUsersRound;
Handle MenuStructure[MAXPLAYERS + 1];
Handle TankState_Array[MAXPLAYERS + 1];
bool bIsGiveIncapHealth[MAXPLAYERS + 1];
Handle TheLeaderboards[MAXPLAYERS + 1];
Handle TheLeaderboardsDataFirst[MAXPLAYERS + 1];
Handle TheLeaderboardsDataSecond[MAXPLAYERS + 1];
int TheLeaderboardsPage[MAXPLAYERS + 1];// 10 entries at a time, until the end of time.
bool bIsMyRanking[MAXPLAYERS + 1];
int TheLeaderboardsPageSize[MAXPLAYERS + 1];
int CurrentRPGMode;
bool IsSurvivalMode = false;
int BestRating[MAXPLAYERS + 1];
int MyRespawnTarget[MAXPLAYERS + 1];
bool RespawnImmunity[MAXPLAYERS + 1];
char TheDBPrefix[64];
int LastAttackedUser[MAXPLAYERS + 1];
Handle LoggedUsers;
Handle TalentTreeValues[MAXPLAYERS + 1];
Handle TalentExperienceValues[MAXPLAYERS + 1];
Handle TalentActionValues[MAXPLAYERS + 1];
bool bIsTalentTwo[MAXPLAYERS + 1];
Handle CommonDrawKeys;
Handle CommonDrawValues;
bool bAutoRevive[MAXPLAYERS + 1];
bool bIsClassAbilities[MAXPLAYERS + 1];
bool bIsDisconnecting[MAXPLAYERS + 1];
int LoadProfileRequestName[MAXPLAYERS + 1];
char TheCurrentMap[64];
bool IsEnrageNotified;
int ClientActiveStance[MAXPLAYERS + 1];
Handle SurvivorsIgnored[MAXPLAYERS + 1];
bool HasSeenCombat[MAXPLAYERS + 1];
int MyBirthday[MAXPLAYERS + 1];
//======================================
//Main config static variables.
//======================================
float fSuperCommonLimit;
float fBurnPercentage;
int iTankRush;
int iTanksAlways;
float fSprintSpeed;
int iRPGMode;
int DirectorWitchLimit;
float fCommonQueueLimit;
float fDirectorThoughtDelay;
float fDirectorThoughtHandicap;
float fDirectorThoughtProcessMinimum;
int iSurvivalRoundTime;
float fDazedDebuffEffect;
int ConsumptionInt;
float fStamJetpackInterval;
float fStamSprintInterval;
float fStamRegenTime;
float fStamRegenTimeAdren;
float fBaseMovementSpeed;
//float fFatigueMovementSpeed;
int iPlayerStartingLevel;
int iBotPlayerStartingLevel;
float fOutOfCombatTime;
int iWitchDamageInitial;
float fWitchDamageScaleLevel;
float fSurvivorDamageBonus;
float fSurvivorHealthBonus;
int iEnrageTime;
float fWitchDirectorPoints;
float fEnrageDirectorPoints;
float fCommonDamageLevel;
int iBotLevelType;
float fCommonDirectorPoints;
int iDisplayHealthBars;
float fDamagePlayerLevel[7];
float fHealthPlayerLevel[7];
int iBaseSpecialDamage[7];
int iBaseSpecialInfectedHealth[7];
float fPointsMultiplierInfected;
float fPointsMultiplier;
float fHealingMultiplier;
float fBuffingMultiplier;
float fHexingMultiplier;
float TanksNearbyRange;
int iCommonAffixes;
int BroadcastType;
int iDoomTimer;
int iSurvivorStaminaMax;
float fRatingMultSpecials;
float fRatingMultSupers;
float fRatingMultCommons;
float fRatingMultTank;
float fRatingMultWitch;
float fTeamworkExperience;
float fItemMultiplierLuck;
float fItemMultiplierTeam;
char sQuickBindHelp[64];
float fPointsCostLevel;
int PointPurchaseType;
int iTankLimitVersus;
float fHealRequirementTeam;
int iSurvivorBaseHealth;
int iSurvivorBotBaseHealth;
char spmn[64];
float fHealthSurvivorRevive;
char RestrictedWeapons[1024];
int iMaxLevel;
int iMaxLevelBots;
int iExperienceStart;
float fExperienceMultiplier;
float fExperienceMultiplierHardcore;
char sBotTeam[64];
int iNumAugments;
int iActionBarSlots;
char MenuCommand[64];
int HostNameTime;
int DoomSUrvivorsRequired;
int DoomKillTimer;
float fVersusTankNotice;
int AllowedCommons;
int AllowedMegaMob;
int AllowedMobSpawn;
int AllowedMobSpawnFinale;
//new AllowedPanicInterval;
int RespawnQueue;
int MaximumPriority;
float fUpgradeExpCost;
int iWitchHealthBase;
float fWitchHealthMult;
int RatingPerLevel;
int RatingPerAugmentLevel;
int RatingPerLevelSurvivorBots;
int iCommonBaseHealth;
float fCommonLevelHealthMult;
int iServerLevelRequirement;
float GroupMemberBonus;
float FinSurvBon;
int RaidLevMult;
int iIgnoredRating;
int iIgnoredRatingMax;
int iInfectedLimit;
float SurvivorExperienceMult;
float SurvivorExperienceMultTank;
float TheScorchMult;
float TheInfernoMult;
float fAdrenProgressMult;
float DirectorTankCooldown;
int DisplayType;
char sDirectorTeam[64];
float fRestedExpMult;
float fSurvivorExpMult;
int iDebuffLimit;
int iRatingSpecialsRequired;
int iRatingTanksRequired;
char sDbLeaderboards[64];
int iIsLifelink;
char sItemModel[512];
int iSurvivorGroupMinimum;
Handle PreloadKeys;
Handle PreloadValues;
Handle persistentCirculation;
int iEnrageAdvertisement;
int iJoinGroupAdvertisement;
int iNotifyEnrage;
char sBackpackModel[64];
bool bIsNewPlayer[MAXPLAYERS + 1];
Handle MyGroup[MAXPLAYERS + 1];
int iCommonsLimitUpper;
bool bIsInCheckpoint[MAXPLAYERS + 1];
float fCoopSurvBon;
int iMinSurvivors;
int PassiveEffectDisplay[MAXPLAYERS + 1];
char sServerDifficulty[64];
int iSpecialsAllowed;
char sSpecialsAllowed[64];
int iSurvivorModifierRequired;
float fEnrageMultiplier;
bool bHealthIsSet[MAXPLAYERS + 1];
int iIsLevelingPaused[MAXPLAYERS + 1];
int iIsBulletTrails[MAXPLAYERS + 1];
Handle ActiveStatuses[MAXPLAYERS + 1];
int InfectedTalentLevel;
float fEnrageModifier;
float LastAttackTime[MAXPLAYERS + 1];
Handle hWeaponList[MAXPLAYERS + 1];
int MyStatusEffects[MAXPLAYERS + 1];
int iShowLockedTalents;
Handle PassiveStrengthValues[MAXPLAYERS + 1];
Handle PassiveTalentName[MAXPLAYERS + 1];
int iChaseEnt[MAXPLAYERS + 1];
int iTeamRatingRequired;
float fTeamRatingBonus;
float fRatingPercentLostOnDeath;
int PlayerCurrentMenuLayer[MAXPLAYERS + 1];
int iMaxLayers;
Handle TranslationOTNValues[MAXPLAYERS + 1];
Handle acdrValues[MAXPLAYERS + 1];
Handle GetLayerStrengthValues[MAXPLAYERS + 1];
int iCommonInfectedBaseDamage;
int playerPageOfCharacterSheet[MAXPLAYERS + 1];
int nodesInExistence;
int iShowTotalNodesOnTalentTree;
Handle PlayerEffectOverTime[MAXPLAYERS + 1];
Handle PlayerEffectOverTimeEffects[MAXPLAYERS + 1];
float fSpecialAmmoInterval;
Handle CooldownEffectTriggerValues[MAXPLAYERS + 1];
Handle IsSpellAnAuraValues[MAXPLAYERS + 1];
float fStaggerTickrate;
Handle StaggeredTargets;
Handle staggerBuffer;
bool staggerCooldownOnTriggers[MAXPLAYERS + 1];
Handle CallAbilityCooldownTriggerValues[MAXPLAYERS + 1];
Handle GetIfTriggerRequirementsMetValues[MAXPLAYERS + 1];
bool ShowPlayerLayerInformation[MAXPLAYERS + 1];
Handle GAMValues[MAXPLAYERS + 1];
char RPGMenuCommand[64];
int RPGMenuCommandExplode;
//new PrestigeLevel[MAXPLAYERS + 1];
char DefaultProfileName[64];
char DefaultBotProfileName[64];
char DefaultInfectedProfileName[64];
Handle GetGoverningAttributeValues[MAXPLAYERS + 1];
int iTanksAlwaysEnforceCooldown;
Handle WeaponResultValues[MAXPLAYERS + 1];
Handle WeaponResultSection[MAXPLAYERS + 1];
bool shotgunCooldown[MAXPLAYERS + 1];
float fRatingFloor;
char negativeStatusEffects[MAXPLAYERS + 1][64];
char positiveStatusEffects[MAXPLAYERS + 1][64];
char clientTrueHealthDisplay[MAXPLAYERS + 1][64];
char clientContributionHealthDisplay[MAXPLAYERS + 1][64];
int iExperienceDebtLevel;
int iExperienceDebtEnabled;
float fExperienceDebtPenalty;
int iShowDamageOnActionBar;
int iDefaultIncapHealth;
Handle GetTalentValueSearchValues[MAXPLAYERS + 1];
Handle GetTalentStrengthSearchValues[MAXPLAYERS + 1];
int iSkyLevelNodeUnlocks;
Handle GetTalentKeyValueValues[MAXPLAYERS + 1];
Handle ApplyDebuffCooldowns[MAXPLAYERS + 1];
int iCanSurvivorBotsBurn;
char defaultLoadoutWeaponPrimary[64];
char defaultLoadoutWeaponSecondary[64];
//int iDeleteCommonsFromExistenceOnDeath;
int iShowDetailedDisplayAlways;
int iCanJetpackWhenInCombat;
Handle ZoomcheckDelayer[MAXPLAYERS + 1];
Handle zoomCheckList;
float fquickScopeTime;
Handle holdingFireList;
int iEnsnareLevelMultiplier;
int lastBaseDamage[MAXPLAYERS + 1];
int lastTarget[MAXPLAYERS + 1];
int iSurvivorBotsBonusLimit;
float fSurvivorBotsNoneBonus;
bool bTimersRunning[MAXPLAYERS + 1];
int iShowAdvertToNonSteamgroupMembers;
int displayBuffOrDebuff[MAXPLAYERS + 1];
int iStrengthOnSpawnIsStrength;
Handle SetNodesKeys;
Handle SetNodesValues;
float fDrawHudInterval;
bool ImmuneToAllDamage[MAXPLAYERS + 1];
int iPlayersLeaveCombatDuringFinales;
int iAllowPauseLeveling;
//new iDropAcidOnLastDebuffDrop;
float fMaxDamageResistance;
float fStaminaPerPlayerLevel;
float fStaminaPerSkyLevel;
int LastBulletCheck[MAXPLAYERS + 1];
int iSpecialInfectedMinimum;
int iEndRoundIfNoHealthySurvivors;
int iEndRoundIfNoLivingHumanSurvivors;
float fAcidDamagePlayerLevel;
float fAcidDamageSupersPlayerLevel;
char ClientStatusEffects[MAXPLAYERS + 1][2][64];
float fTankMovementSpeed_Burning;
float fTankMovementSpeed_Hulk;
float fTankMovementSpeed_Death;
int iResetPlayerLevelOnDeath;
int iStartingPlayerUpgrades;
char serverKey[64];
bool playerHasAdrenaline[MAXPLAYERS + 1];
bool playerInSlowAmmo[MAXPLAYERS + 1];
int leaderboardPageCount;
float fForceTankJumpHeight;
float fForceTankJumpRange;
int iResetDirectorPointsOnNewRound;
int iMaxServerUpgrades;
int iExperienceLevelCap;
bool LastHitWasHeadshot[MAXPLAYERS + 1];
char acmd[20];
char abcmd[20];
//int iDeleteSupersOnDeath;
//int iShoveStaminaCost;
float fLootChanceTank;
float fLootChanceWitch;
float fLootChanceSpecials;
float fLootChanceSupers;
float fLootChanceCommons;
int iLootEnabled;
float fUpgradesRequiredPerLayer;
int iEnsnareRestrictions;
int levelToSet[MAXPLAYERS+1];
char steamIdSearch[MAXPLAYERS+1][64];
char baseName[MAXPLAYERS+1][64];
float fSurvivorBufferBonus;
int iCommonInfectedSpawnDelayOnNewRound;
int scoreRequiredForLeaderboard;
bool bIsClientCurrentlyStaggered[MAXPLAYERS +1];
char loadProfileOverrideFlags[64];
int iUpgradesRequiredForLoot;
Handle playerContributionTracker[MAXPLAYERS + 1];
Handle playerCustomEntitiesCreated;
int lastEntityDropped[MAXPLAYERS + 1];
int ConsecutiveHeadshots[MAXPLAYERS + 1];
int iUseLinearLeveling;
int currentWeaponCategory[MAXPLAYERS + 1];
int iUniqueServerCode;
int lootDropCounter;
Handle myUnlockedCategories[MAXPLAYERS + 1];
Handle myUnlockedActivators[MAXPLAYERS + 1];
Handle myUnlockedTargets[MAXPLAYERS + 1];
Handle myLootDropCategoriesAllowed[MAXPLAYERS + 1];
Handle myLootDropTargetEffectsAllowed[MAXPLAYERS + 1];
Handle myLootDropActivatorEffectsAllowed[MAXPLAYERS + 1];
Handle LootDropCategoryToBuffValues[MAXPLAYERS + 1];
Handle myAugmentSavedProfiles[MAXPLAYERS + 1];
Handle myAugmentIDCodes[MAXPLAYERS + 1];
Handle myAugmentCategories[MAXPLAYERS + 1];
Handle myAugmentOwners[MAXPLAYERS + 1];
Handle myAugmentOwnersName[MAXPLAYERS + 1];
Handle myAugmentInfo[MAXPLAYERS + 1];
int iAugmentLevelDivisor;
float fAugmentRatingMultiplier;
float fAugmentActivatorRatingMultiplier;
float fAugmentTargetRatingMultiplier;
Handle equippedAugments[MAXPLAYERS + 1];
Handle equippedAugmentsCategory[MAXPLAYERS + 1];
int iRatingRequiredForAugmentLootDrops;
Handle GetAugmentTranslationKeys[MAXPLAYERS + 1];
Handle GetAugmentTranslationVals[MAXPLAYERS + 1];
float fAugmentTierChance;
Handle equippedAugmentsActivator[MAXPLAYERS + 1];
Handle equippedAugmentsTarget[MAXPLAYERS + 1];
Handle myAugmentActivatorEffects[MAXPLAYERS + 1];
Handle myAugmentTargetEffects[MAXPLAYERS + 1];
Handle equippedAugmentsIDCodes[MAXPLAYERS + 1];
int AugmentClientIsInspecting[MAXPLAYERS + 1];
int augmentParts[MAXPLAYERS + 1];
int itemToDisassemble[MAXPLAYERS + 1];
char sCategoriesToIgnore[512];
float fAntiFarmDistance;
int iAntiFarmMax;
Handle lootRollData[MAXPLAYERS + 1];
float fLootBagExpirationTimeInSeconds;
Handle playerLootOnGround[MAXPLAYERS + 1];
Handle playerLootOnGroundId[MAXPLAYERS + 1];
int iExplosionBaseDamagePipe;
int iExplosionBaseDamage;
float fProficiencyLevelDamageIncrease;
int playerCurrentAugmentLevel[MAXPLAYERS + 1];
Handle possibleLootPoolTarget[MAXPLAYERS + 1];
Handle possibleLootPoolActivator[MAXPLAYERS + 1];
int iJetpackEnabled;
float fJumpTimeToActivateJetpack;
int iNumLootDropChancesPerPlayer[5];
char lastPlayerGrab[64];
int iInventoryLimit;
char sDeleteBotFlags[64];
int iMultiplierForAugmentLootDrops;

public Action CMD_DropWeapon(int client, int args) {
	int CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntity(CurrentEntity) || CurrentEntity < 1) return Plugin_Handled;
	char EntityName[64];
	GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));
	if (StrContains(EntityName, "melee", false) != -1) return Plugin_Handled;
	int Entity					=	CreateEntityByName(EntityName);
	DispatchSpawn(Entity);
	lastEntityDropped[client] = Entity;
	GetAbilityStrengthByTrigger(client, client, "dropitem", _, _, _, _, _, _, _, _, _, _, _, _, _, Entity);
	float Origin[3];
	GetClientAbsOrigin(client, Origin);
	Origin[2] += 64.0;
	TeleportEntity(Entity, Origin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(Entity, MOVETYPE_VPHYSICS);
	if (GetWeaponSlot(Entity) < 2) SetEntProp(Entity, Prop_Send, "m_iClip1", GetEntProp(CurrentEntity, Prop_Send, "m_iClip1"));
	AcceptEntityInput(CurrentEntity, "Kill");
	return Plugin_Handled;
}

public Action CMD_IAmStuck(int client, int args) {
	int timeremaining = lastStuckTime[client] - GetTime();
	if (timeremaining <= 0 && !bIsInCombat[client] && L4D2_GetInfectedAttacker(client) == -1 && !AnyTanksNearby(client, 5096.0)) {
		int target = FindAnyRandomClient(true, client);
		if (target > 0) {
			GetClientAbsOrigin(target, DeathLocation[client]);
			TeleportEntity(client, DeathLocation[client], NULL_VECTOR, NULL_VECTOR);
			SetEntityMoveType(client, MOVETYPE_WALK);
			lastStuckTime[client] = GetTime() + iStuckDelayTime;
		}
		else PrintToChat(client, "\x04Can't find anyone to teleport you to, sorry bud.");
	}
	else {
		char text[64];
		Format(text, sizeof(text), "\x04You can't use this command right now.");
		if (timeremaining > 0) Format(text, sizeof(text), "%s \x04You must wait \x03%d \x04second(s).", text, timeremaining);
	}

	return Plugin_Handled;
}

stock void DoGunStuff(int client) {
	int targetgun = GetPlayerWeaponSlot(client, 0); //get the players primary weapon
	if (!IsValidEdict(targetgun)) return; //check for validity
	int iAmmoOffset = FindDataMapInfo(client, "m_iAmmo"); //get the iAmmo Offset
	iAmmoOffset = GetEntData(client, (iAmmoOffset + GetWeaponResult(client, 1)));
	//PrintToChat(client, "reserve remaining: %d | reserve cap: %d", iAmmoOffset, GetWeaponResult(client, 2));
	return;
}

stock void CMD_OpenRPGMenu(int client) {
	ClearArray(MenuStructure[client]);	// keeps track of the open menus.
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

public void OnPluginStart() {
	OnMapStartFunc(); // The very first thing that must happen before anything else happens.
	CreateConVar("rpgmaker_version", PLUGIN_VERSION, "version of RPGMaker 2 Construction Kit");
	SetConVarString(FindConVar("rpgmaker_version"), PLUGIN_VERSION);
	g_Steamgroup = FindConVar("sv_steamgroup");
	SetConVarFlags(g_Steamgroup, GetConVarFlags(g_Steamgroup) & ~FCVAR_NOTIFY);
	g_svCheats = FindConVar("sv_cheats");
	SetConVarFlags(g_svCheats, GetConVarFlags(g_svCheats) & ~FCVAR_NOTIFY);
	g_Gamemode = FindConVar("mp_gamemode");
	LoadTranslations("skyrpg.phrases");
	BuildPath(Path_SM, ConfigPathDirectory, sizeof(ConfigPathDirectory), "configs/readyup/");
	if (!DirExists(ConfigPathDirectory)) CreateDirectory(ConfigPathDirectory, 777);
	BuildPath(Path_SM, LogPathDirectory, sizeof(LogPathDirectory), "logs/readyup/rpg/");
	if (!DirExists(LogPathDirectory)) CreateDirectory(LogPathDirectory, 777);
	BuildPath(Path_SM, LogPathDirectory, sizeof(LogPathDirectory), "logs/readyup/rpg/%s", LOGFILE);
	//if (!FileExists(LogPathDirectory)) SetFailState("[SKYRPG LOGGING] please create file at %s", LogPathDirectory);
	RegAdminCmd("debugrpg", Cmd_debugrpg, ADMFLAG_KICK);
	RegAdminCmd("resettpl", Cmd_ResetTPL, ADMFLAG_KICK);
	RegAdminCmd("deleteprofiles", CMD_DeleteProfiles, ADMFLAG_ROOT);
	// These are mandatory because of quick commands, so I hardcode the entries.
	RegConsoleCmd("autodismantle", CMD_AutoDismantle);
	RegConsoleCmd("rollloot", CMD_RollLoot);
	RegConsoleCmd("price", CMD_SetAugmentPrice);
	RegConsoleCmd("say", CMD_ChatCommand);
	RegConsoleCmd("say_team", CMD_TeamChatCommand);
	RegConsoleCmd("callvote", CMD_BlockVotes);
	RegConsoleCmd("votemap", CMD_BlockIfReadyUpIsActive);
	RegConsoleCmd("vote", CMD_BlockVotes);
	//RegConsoleCmd("talentupgrade", CMD_TalentUpgrade);
	RegConsoleCmd("loadoutname", CMD_LoadoutName);
	RegConsoleCmd("stuck", CMD_IAmStuck);
	RegConsoleCmd("ff", CMD_TogglePvP);
	//RegConsoleCmd("revive", CMD_RespawnYumYum);
	//RegConsoleCmd("abar", CMD_ActionBar);
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
	staggerBuffer = CreateConVar("sm_vscript_res", "", "returns results from vscript check on stagger");
}

public Action CMD_WITCHESCOUNT(int client, int args) {
	PrintToChat(client, "Witches: %d", GetArraySize(WitchList));
	return Plugin_Handled;
}

public Action CMD_FBEGIN(int client, int args) {
	ReadyUpEnd_Complete();
	return Plugin_Handled;
}

public Action CMD_DeleteProfiles(int client, int args) {
	if (DeleteAllProfiles(client)) PrintToChat(client, "all saved profiles are deleted.");
	return Plugin_Handled;
}
public Action CMD_BlockVotes(int client, int args) {
	return Plugin_Handled;
}

public Action CMD_BlockIfReadyUpIsActive(int client, int args) {
	if (!b_IsRoundIsOver) return Plugin_Continue;
	return Plugin_Handled;
}

public int ReadyUp_SetSurvivorMinimum(int minSurvs) {
	iMinSurvivors = minSurvs;
}

public void ReadyUp_GetMaxSurvivorCount(int count) {
	// if (count <= 1) bIsSoloHandicap = true;
	// else bIsSoloHandicap = false;
}

stock void UnhookAll() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKUnhook(i, SDKHook_TraceAttack, OnTraceAttack);
			SDKUnhook(i, SDKHook_WeaponSwitch, OnWeaponSwitch);
			b_IsHooked[i] = false;
		}
	}
}

public int ReadyUp_TrueDisconnect(int client) {
	if (b_IsLoaded[client]) SavePlayerData(client, true);
	// only set to false if a REAL player leaves - this way bots don't repeatedly load their data.
	b_IsLoaded[client] = false;
	// the best redundancy check to tower over all others. no more collisions when a player connects on a client that is not yet timed out to a crashed player!
	Format(currentClientSteamID[client], sizeof(currentClientSteamID[]), "-1");
	DisconnectDataReset(client);
}

stock DisconnectDataReset(int client) {
	b_IsLoaded[client] = false;
	PlayerLevel[client] = 0;
	Format(baseName[client], sizeof(baseName[]), "[RPG DISCO]");
	if (IsFakeClient(client)) return;
	IsClearedToLoad(client, _, true);
	if (bIsInCombat[client]) IncapacitateOrKill(client, _, _, true, true, true);
	bTimersRunning[client] = false;
	staggerCooldownOnTriggers[client] = false;
	ISBILED[client] = false;
	DisplayActionBar[client] = false;
	IsPvP[client] = 0;
	b_IsFloating[client] = false;
	b_IsLoading[client] = false;
	b_HardcoreMode[client] = false;
	//WipeDebuffs(_, client, true);
	IsPlayerDebugMode[client] = 0;
	CleanseStack[client] = 0;
	CounterStack[client] = 0.0;
	MultiplierStack[client] = 0;
	LoadTarget[client] = -1;
	ImmuneToAllDamage[client] = false;
	bIsSettingsCheck = true;
}

stock CreateAllArrays() {
	if (b_FirstLoad) return;
	LogMessage("=====\t\tRunning first-time load of RPG.\t\t=====");
	if (ModelsToPrecache == INVALID_HANDLE) ModelsToPrecache = CreateArray(16);
	if (TalentMenuConfigs == INVALID_HANDLE) TalentMenuConfigs = CreateArray(32);
	if (holdingFireList == INVALID_HANDLE) holdingFireList = CreateArray(16);
	if (zoomCheckList == INVALID_HANDLE) zoomCheckList = CreateArray(16);
	if (hThreatSort == INVALID_HANDLE) hThreatSort = CreateArray(16);
	if (hThreatMeter == INVALID_HANDLE) hThreatMeter = CreateArray(16);
	if (LoggedUsers == INVALID_HANDLE) LoggedUsers = CreateArray(16);
	if (SuperCommonQueue == INVALID_HANDLE) SuperCommonQueue = CreateArray(16);
	if (CommonInfectedQueue == INVALID_HANDLE) CommonInfectedQueue = CreateArray(16);
	if (CoveredInVomit == INVALID_HANDLE) CoveredInVomit = CreateArray(16);
	if (NewUsersRound == INVALID_HANDLE) NewUsersRound = CreateArray(16);
	if (SpecialAmmoData == INVALID_HANDLE) SpecialAmmoData = CreateArray(16);
	if (SpecialAmmoSave == INVALID_HANDLE) SpecialAmmoSave = CreateArray(16);
	if (MainKeys == INVALID_HANDLE) MainKeys = CreateArray(16);
	if (MainValues == INVALID_HANDLE) MainValues = CreateArray(16);
	if (a_Menu_Talents == INVALID_HANDLE) a_Menu_Talents = CreateArray(4);
	if (a_Menu_Main == INVALID_HANDLE) a_Menu_Main = CreateArray(3);
	if (a_Events == INVALID_HANDLE) a_Events = CreateArray(3);
	if (a_Points == INVALID_HANDLE) a_Points = CreateArray(3);
	if (a_Pets == INVALID_HANDLE) a_Pets = CreateArray(3);
	if (a_Store == INVALID_HANDLE) a_Store = CreateArray(3);
	if (a_Trails == INVALID_HANDLE) a_Trails = CreateArray(3);
	if (a_Database_Talents == INVALID_HANDLE) a_Database_Talents = CreateArray(16);
	if (a_Database_Talents_Defaults == INVALID_HANDLE) a_Database_Talents_Defaults 	= CreateArray(16);
	if (a_Database_Talents_Defaults_Name == INVALID_HANDLE) a_Database_Talents_Defaults_Name				= CreateArray(16);
	if (EventSection == INVALID_HANDLE) EventSection									= CreateArray(16);
	if (HookSection == INVALID_HANDLE) HookSection										= CreateArray(16);
	if (CallKeys == INVALID_HANDLE) CallKeys										= CreateArray(16);
	if (CallValues == INVALID_HANDLE) CallValues										= CreateArray(16);
	if (DirectorKeys == INVALID_HANDLE) DirectorKeys									= CreateArray(16);
	if (DirectorValues == INVALID_HANDLE) DirectorValues									= CreateArray(16);
	if (DatabaseKeys == INVALID_HANDLE) DatabaseKeys									= CreateArray(16);
	if (DatabaseValues == INVALID_HANDLE) DatabaseValues									= CreateArray(16);
	if (DatabaseSection == INVALID_HANDLE) DatabaseSection									= CreateArray(16);
	if (a_Database_PlayerTalents_Bots == INVALID_HANDLE) a_Database_PlayerTalents_Bots					= CreateArray(16);
	if (PlayerAbilitiesCooldown_Bots == INVALID_HANDLE) PlayerAbilitiesCooldown_Bots					= CreateArray(16);
	if (PlayerAbilitiesImmune_Bots == INVALID_HANDLE) PlayerAbilitiesImmune_Bots						= CreateArray(16);
	if (LoadDirectorSection == INVALID_HANDLE) LoadDirectorSection								= CreateArray(16);
	if (QueryDirectorKeys == INVALID_HANDLE) QueryDirectorKeys								= CreateArray(16);
	if (QueryDirectorValues == INVALID_HANDLE) QueryDirectorValues								= CreateArray(16);
	if (QueryDirectorSection == INVALID_HANDLE) QueryDirectorSection							= CreateArray(16);
	if (FirstDirectorKeys == INVALID_HANDLE) FirstDirectorKeys								= CreateArray(16);
	if (FirstDirectorValues == INVALID_HANDLE) FirstDirectorValues								= CreateArray(16);
	if (FirstDirectorSection == INVALID_HANDLE) FirstDirectorSection							= CreateArray(16);
	if (PlayerAbilitiesName == INVALID_HANDLE) PlayerAbilitiesName								= CreateArray(16);
	if (a_DirectorActions == INVALID_HANDLE) a_DirectorActions								= CreateArray(3);
	if (a_DirectorActions_Cooldown == INVALID_HANDLE) a_DirectorActions_Cooldown						= CreateArray(16);
	if (Give_Store_Keys == INVALID_HANDLE) Give_Store_Keys							= CreateArray(16);
	if (Give_Store_Values == INVALID_HANDLE) Give_Store_Values							= CreateArray(16);
	if (Give_Store_Section == INVALID_HANDLE) Give_Store_Section							= CreateArray(16);
	if (a_WeaponDamages == INVALID_HANDLE) a_WeaponDamages = CreateArray(16);
	if (a_CommonAffixes == INVALID_HANDLE) a_CommonAffixes = CreateArray(16);
	if (a_HandicapLevels == INVALID_HANDLE) a_HandicapLevels = CreateArray(16);
	if (CommonList == INVALID_HANDLE) CommonList = CreateArray(16);
	if (WitchList == INVALID_HANDLE) WitchList				= CreateArray(16);
	if (CommonAffixes == INVALID_HANDLE) CommonAffixes	= CreateArray(16);
	if (h_CAKeys == INVALID_HANDLE) h_CAKeys = CreateArray(16);
	if (h_CAValues == INVALID_HANDLE) h_CAValues = CreateArray(16);
	if (SearchKey_Section == INVALID_HANDLE) SearchKey_Section = CreateArray(16);
	if (CCASection == INVALID_HANDLE) CCASection = CreateArray(16);
	if (CCAKeys == INVALID_HANDLE) CCAKeys = CreateArray(16);
	if (CCAValues == INVALID_HANDLE) CCAValues = CreateArray(16);
	if (h_CommonKeys == INVALID_HANDLE) h_CommonKeys = CreateArray(16);
	if (h_CommonValues == INVALID_HANDLE) h_CommonValues = CreateArray(16);
	//if (CommonInfected == INVALID_HANDLE) CommonInfected = CreateArray(16);
	if (EntityOnFire == INVALID_HANDLE) EntityOnFire = CreateArray(16);
	if (EntityOnFireName == INVALID_HANDLE) EntityOnFireName = CreateArray(16);
	if (CommonDrawKeys == INVALID_HANDLE) CommonDrawKeys = CreateArray(16);
	if (CommonDrawValues == INVALID_HANDLE) CommonDrawValues = CreateArray(16);
	if (PreloadKeys == INVALID_HANDLE) PreloadKeys = CreateArray(16);
	if (PreloadValues == INVALID_HANDLE) PreloadValues = CreateArray(16);
	if (persistentCirculation == INVALID_HANDLE) persistentCirculation = CreateArray(16);
	if (RandomSurvivorClient == INVALID_HANDLE) RandomSurvivorClient = CreateArray(16);
	if (RoundStatistics == INVALID_HANDLE) RoundStatistics = CreateArray(16);
	if (EffectOverTime == INVALID_HANDLE) EffectOverTime = CreateArray(16);
	if (TimeOfEffectOverTime == INVALID_HANDLE) TimeOfEffectOverTime = CreateArray(16);
	if (StaggeredTargets == INVALID_HANDLE) StaggeredTargets = CreateArray(16);
	if (SetNodesKeys == INVALID_HANDLE) SetNodesKeys = CreateArray(16);
	if (SetNodesValues == INVALID_HANDLE) SetNodesValues = CreateArray(16);
	if (playerCustomEntitiesCreated == INVALID_HANDLE) playerCustomEntitiesCreated = CreateArray(16);
	if (ClientsPermittedToLoad == INVALID_HANDLE) ClientsPermittedToLoad = CreateArray(16);
	if (ListOfWitchesWhoHaveBeenShot == INVALID_HANDLE) ListOfWitchesWhoHaveBeenShot = CreateArray(8);
	if (tempStorage == INVALID_HANDLE) tempStorage = CreateArray(16);
	if (damageOfSpecialInfected == INVALID_HANDLE) damageOfSpecialInfected = CreateArray(16);
	if (damageOfWitch == INVALID_HANDLE) damageOfWitch = CreateArray(16);
	if (damageOfSpecialCommon == INVALID_HANDLE) damageOfSpecialCommon = CreateArray(16);
	if (damageOfCommonInfected == INVALID_HANDLE) damageOfCommonInfected = CreateArray(16);
	ResizeArray(tempStorage, MAXPLAYERS + 1);
	for (int i = 1; i <= MAXPLAYERS; i++) {
		itemToDisassemble[i] = -1;
		augmentParts[i] = 0;
		LastDeathTime[i] = 0.0;
		MyVomitChase[i] = -1;
		b_IsFloating[i] = false;
		DisplayActionBar[i] = false;
		ActionBarSlot[i] = -1;
		b_IsIdle[i] = false;
		if (GetCoherencyValues[i] == INVALID_HANDLE) GetCoherencyValues[i] = CreateArray(16);
		if (GetValueFloatArray[i] == INVALID_HANDLE) GetValueFloatArray[i] = CreateArray(8);
		if (CommonInfected[i] == INVALID_HANDLE) CommonInfected[i] = CreateArray(16);
		if (possibleLootPool[i] == INVALID_HANDLE) possibleLootPool[i] = CreateArray(16);
		if (currentEquippedWeapon[i] == INVALID_HANDLE) currentEquippedWeapon[i] = CreateTrie();
		if (GetCategoryStrengthValues[i] == INVALID_HANDLE) GetCategoryStrengthValues[i] = CreateArray(16);
		if (PassiveStrengthValues[i] == INVALID_HANDLE) PassiveStrengthValues[i] = CreateArray(16);
		if (PassiveTalentName[i] == INVALID_HANDLE) PassiveTalentName[i] = CreateArray(16);
		if (TranslationOTNValues[i] == INVALID_HANDLE) TranslationOTNValues[i] = CreateArray(16);
		if (hWeaponList[i] == INVALID_HANDLE) hWeaponList[i] = CreateArray(16);
		if (LoadoutConfigKeys[i] == INVALID_HANDLE) LoadoutConfigKeys[i] = CreateArray(16);
		if (LoadoutConfigValues[i] == INVALID_HANDLE) LoadoutConfigValues[i] = CreateArray(16);
		if (LoadoutConfigSection[i] == INVALID_HANDLE) LoadoutConfigSection[i] = CreateArray(16);
		if (ActiveStatuses[i] == INVALID_HANDLE) ActiveStatuses[i] = CreateArray(16);
		if (AbilityConfigValues[i] == INVALID_HANDLE) AbilityConfigValues[i] = CreateArray(16);
		if (IsAbilityValues[i] == INVALID_HANDLE) IsAbilityValues[i] = CreateArray(16);
		if (CheckAbilityKeys[i] == INVALID_HANDLE) CheckAbilityKeys[i] = CreateArray(16);
		if (CheckAbilityValues[i] == INVALID_HANDLE) CheckAbilityValues[i] = CreateArray(16);
		if (CastValues[i] == INVALID_HANDLE) CastValues[i] = CreateArray(16);
		if (ActionBar[i] == INVALID_HANDLE) ActionBar[i] = CreateArray(16);
		if (ActionBarMenuPos[i] == INVALID_HANDLE) ActionBarMenuPos[i] = CreateArray(16);
		if (TalentsAssignedValues[i] == INVALID_HANDLE) TalentsAssignedValues[i] = CreateArray(16);
		if (CartelValueValues[i] == INVALID_HANDLE) CartelValueValues[i] = CreateArray(16);
		if (TalentActionValues[i] == INVALID_HANDLE) TalentActionValues[i] = CreateArray(16);
		if (TalentExperienceValues[i] == INVALID_HANDLE) TalentExperienceValues[i] = CreateArray(16);
		if (TalentTreeValues[i] == INVALID_HANDLE) TalentTreeValues[i] = CreateArray(16);
		if (TheLeaderboards[i] == INVALID_HANDLE) TheLeaderboards[i] = CreateArray(16);
		if (TheLeaderboardsDataFirst[i] == INVALID_HANDLE) TheLeaderboardsDataFirst[i] = CreateArray(8);
		if (TheLeaderboardsDataSecond[i] == INVALID_HANDLE) TheLeaderboardsDataSecond[i] = CreateArray(8);
		if (TankState_Array[i] == INVALID_HANDLE) TankState_Array[i] = CreateArray(16);
		if (MenuStructure[i] == INVALID_HANDLE) MenuStructure[i] = CreateArray(16);
		if (TempAttributes[i] == INVALID_HANDLE) TempAttributes[i] = CreateArray(16);
		if (TempTalents[i] == INVALID_HANDLE) TempTalents[i] = CreateArray(16);
		if (PlayerProfiles[i] == INVALID_HANDLE) PlayerProfiles[i] = CreateArray(32);
		if (SpecialAmmoEffectValues[i] == INVALID_HANDLE) SpecialAmmoEffectValues[i] = CreateArray(16);
		if (ActiveAmmoCooldownValues[i] == INVALID_HANDLE) ActiveAmmoCooldownValues[i] = CreateArray(16);
		if (PlayActiveAbilities[i] == INVALID_HANDLE) PlayActiveAbilities[i] = CreateArray(16);
		if (PlayerActiveAmmo[i] == INVALID_HANDLE) PlayerActiveAmmo[i] = CreateArray(16);
		if (DrawSpecialAmmoKeys[i] == INVALID_HANDLE) DrawSpecialAmmoKeys[i] = CreateArray(16);
		if (DrawSpecialAmmoValues[i] == INVALID_HANDLE) DrawSpecialAmmoValues[i] = CreateArray(16);
		if (SpecialAmmoStrengthValues[i] == INVALID_HANDLE) SpecialAmmoStrengthValues[i] = CreateArray(16);
		if (WeaponLevel[i] == INVALID_HANDLE) WeaponLevel[i] = CreateArray(16);
		if (ExperienceBank[i] == INVALID_HANDLE) ExperienceBank[i] = CreateArray(16);
		if (MenuPosition[i] == INVALID_HANDLE) MenuPosition[i] = CreateArray(16);
		if (IsClientInRangeSAValues[i] == INVALID_HANDLE) IsClientInRangeSAValues[i] = CreateArray(16);
		if (InfectedHealth[i] == INVALID_HANDLE) InfectedHealth[i] = CreateArray(16);
		if (WitchDamage[i] == INVALID_HANDLE) WitchDamage[i]	= CreateArray(16);
		if (SpecialCommon[i] == INVALID_HANDLE) SpecialCommon[i] = CreateArray(16);
		if (MenuKeys[i] == INVALID_HANDLE) MenuKeys[i]								= CreateArray(16);
		if (MenuValues[i] == INVALID_HANDLE) MenuValues[i]							= CreateArray(16);
		if (AbilityMultiplierCalculator[i] == INVALID_HANDLE) AbilityMultiplierCalculator[i] = CreateArray(16);
		if (MenuSection[i] == INVALID_HANDLE) MenuSection[i]							= CreateArray(16);
		if (TriggerValues[i] == INVALID_HANDLE) TriggerValues[i]						= CreateArray(16);
		if (PreloadTalentValues[i] == INVALID_HANDLE) PreloadTalentValues[i]			= CreateArray(16);
		if (MyTalentStrengths[i] == INVALID_HANDLE) MyTalentStrengths[i]				= CreateArray(16);
		if (MyTalentStrength[i] == INVALID_HANDLE) MyTalentStrength[i]					= CreateArray(16);
		if (AbilityKeys[i] == INVALID_HANDLE) AbilityKeys[i]							= CreateArray(16);
		if (AbilityValues[i] == INVALID_HANDLE) AbilityValues[i]						= CreateArray(16);
		if (ChanceValues[i] == INVALID_HANDLE) ChanceValues[i]							= CreateArray(16);
		if (PurchaseKeys[i] == INVALID_HANDLE) PurchaseKeys[i]						= CreateArray(16);
		if (PurchaseValues[i] == INVALID_HANDLE) PurchaseValues[i]						= CreateArray(16);
		if (a_Database_PlayerTalents[i] == INVALID_HANDLE) a_Database_PlayerTalents[i]				= CreateArray(16);
		if (a_Database_PlayerTalents_Experience[i] == INVALID_HANDLE) a_Database_PlayerTalents_Experience[i] = CreateArray(16);
		if (PlayerAbilitiesCooldown[i] == INVALID_HANDLE) PlayerAbilitiesCooldown[i]				= CreateArray(16);
		if (acdrValues[i] == INVALID_HANDLE) acdrValues[i] = CreateArray(16);
		if (GetLayerStrengthValues[i] == INVALID_HANDLE) GetLayerStrengthValues[i] = CreateArray(16);
		if (a_Store_Player[i] == INVALID_HANDLE) a_Store_Player[i]						= CreateArray(16);
		if (StoreKeys[i] == INVALID_HANDLE) StoreKeys[i]							= CreateArray(16);
		if (StoreValues[i] == INVALID_HANDLE) StoreValues[i]							= CreateArray(16);
		if (StoreMultiplierKeys[i] == INVALID_HANDLE) StoreMultiplierKeys[i]					= CreateArray(16);
		if (StoreMultiplierValues[i] == INVALID_HANDLE) StoreMultiplierValues[i]				= CreateArray(16);
		if (StoreTimeKeys[i] == INVALID_HANDLE) StoreTimeKeys[i]						= CreateArray(16);
		if (StoreTimeValues[i] == INVALID_HANDLE) StoreTimeValues[i]						= CreateArray(16);
		if (StoreChanceKeys[i] == INVALID_HANDLE) StoreChanceKeys[i]						= CreateArray(16);
		if (StoreChanceValues[i] == INVALID_HANDLE) StoreChanceValues[i]					= CreateArray(16);
		if (TrailsKeys[i] == INVALID_HANDLE) TrailsKeys[i]							= CreateArray(16);
		if (TrailsValues[i] == INVALID_HANDLE) TrailsValues[i]							= CreateArray(16);
		if (DamageValues[i] == INVALID_HANDLE) DamageValues[i]					= CreateArray(16);
		if (DamageSection[i] == INVALID_HANDLE) DamageSection[i]				= CreateArray(16);
		if (MOTValues[i] == INVALID_HANDLE) MOTValues[i] = CreateArray(16);
		if (BoosterKeys[i] == INVALID_HANDLE) BoosterKeys[i]							= CreateArray(16);
		if (BoosterValues[i] == INVALID_HANDLE) BoosterValues[i]						= CreateArray(16);
		if (RPGMenuPosition[i] == INVALID_HANDLE) RPGMenuPosition[i]						= CreateArray(16);
		if (h_KilledPosition_X[i] == INVALID_HANDLE) h_KilledPosition_X[i]				= CreateArray(16);
		if (h_KilledPosition_Y[i] == INVALID_HANDLE) h_KilledPosition_Y[i]				= CreateArray(16);
		if (h_KilledPosition_Z[i] == INVALID_HANDLE) h_KilledPosition_Z[i]				= CreateArray(16);
		if (RCAffixes[i] == INVALID_HANDLE) RCAffixes[i] = CreateArray(16);
		if (SurvivorsIgnored[i] == INVALID_HANDLE) SurvivorsIgnored[i] = CreateArray(16);
		if (MyGroup[i] == INVALID_HANDLE) MyGroup[i] = CreateArray(16);
		if (PlayerEffectOverTime[i] == INVALID_HANDLE) PlayerEffectOverTime[i] = CreateArray(16);
		if (PlayerEffectOverTimeEffects[i] == INVALID_HANDLE) PlayerEffectOverTimeEffects[i] = CreateArray(16);
		if (CooldownEffectTriggerValues[i] == INVALID_HANDLE) CooldownEffectTriggerValues[i] = CreateArray(16);
		if (IsSpellAnAuraValues[i] == INVALID_HANDLE) IsSpellAnAuraValues[i] = CreateArray(16);
		if (CallAbilityCooldownTriggerValues[i] == INVALID_HANDLE) CallAbilityCooldownTriggerValues[i] = CreateArray(16);
		if (GetIfTriggerRequirementsMetValues[i] == INVALID_HANDLE) GetIfTriggerRequirementsMetValues[i] = CreateArray(16);
		if (GAMValues[i] == INVALID_HANDLE) GAMValues[i] = CreateArray(16);
		if (GetGoverningAttributeValues[i] == INVALID_HANDLE) GetGoverningAttributeValues[i] = CreateArray(16);
		if (WeaponResultValues[i] == INVALID_HANDLE) WeaponResultValues[i] = CreateArray(16);
		if (WeaponResultSection[i] == INVALID_HANDLE) WeaponResultSection[i] = CreateArray(16);
		if (GetTalentValueSearchValues[i] == INVALID_HANDLE) GetTalentValueSearchValues[i] = CreateArray(16);
		if (GetTalentStrengthSearchValues[i] == INVALID_HANDLE) GetTalentStrengthSearchValues[i] = CreateArray(16);
		if (GetTalentKeyValueValues[i] == INVALID_HANDLE) GetTalentKeyValueValues[i] = CreateArray(16);
		if (ApplyDebuffCooldowns[i] == INVALID_HANDLE) ApplyDebuffCooldowns[i] = CreateArray(16);
		if (playerContributionTracker[i] == INVALID_HANDLE) {
			playerContributionTracker[i] = CreateArray(16);
			ResizeArray(playerContributionTracker[i], 4);
		}
		if (myLootDropCategoriesAllowed[i] == INVALID_HANDLE) myLootDropCategoriesAllowed[i] = CreateArray(16);
		if (LootDropCategoryToBuffValues[i] == INVALID_HANDLE) LootDropCategoryToBuffValues[i] = CreateArray(16);
		if (myAugmentIDCodes[i] == INVALID_HANDLE) myAugmentIDCodes[i] = CreateArray(16);
		if (myAugmentSavedProfiles[i] == INVALID_HANDLE) myAugmentSavedProfiles[i] = CreateArray(16);
		if (myAugmentCategories[i] == INVALID_HANDLE) myAugmentCategories[i] = CreateArray(16);
		if (myAugmentOwners[i] == INVALID_HANDLE) myAugmentOwners[i] = CreateArray(16);
		if (myAugmentOwnersName[i] == INVALID_HANDLE) myAugmentOwnersName[i] = CreateArray(16);
		if (myAugmentInfo[i] == INVALID_HANDLE) myAugmentInfo[i] = CreateArray(16);
		if (equippedAugments[i] == INVALID_HANDLE) equippedAugments[i] = CreateArray(16);
		if (equippedAugmentsCategory[i] == INVALID_HANDLE) equippedAugmentsCategory[i] = CreateArray(16);
		if (GetAugmentTranslationKeys[i] == INVALID_HANDLE) GetAugmentTranslationKeys[i] = CreateArray(16);
		if (GetAugmentTranslationVals[i] == INVALID_HANDLE) GetAugmentTranslationVals[i] = CreateArray(16);
		if (myLootDropTargetEffectsAllowed[i] == INVALID_HANDLE) myLootDropTargetEffectsAllowed[i] = CreateArray(16);
		if (myLootDropActivatorEffectsAllowed[i] == INVALID_HANDLE) myLootDropActivatorEffectsAllowed[i] = CreateArray(16);
		if (equippedAugmentsActivator[i] == INVALID_HANDLE) equippedAugmentsActivator[i] = CreateArray(16);
		if (equippedAugmentsTarget[i] == INVALID_HANDLE) equippedAugmentsTarget[i] = CreateArray(16);
		if (myAugmentActivatorEffects[i] == INVALID_HANDLE) myAugmentActivatorEffects[i] = CreateArray(16);
		if (myAugmentTargetEffects[i] == INVALID_HANDLE) myAugmentTargetEffects[i] = CreateArray(16);
		if (equippedAugmentsIDCodes[i] == INVALID_HANDLE) equippedAugmentsIDCodes[i] = CreateArray(16);
		if (lootRollData[i] == INVALID_HANDLE) lootRollData[i] = CreateArray(16);
		if (playerLootOnGround[i] == INVALID_HANDLE) playerLootOnGround[i] = CreateArray(16);
		if (playerLootOnGroundId[i] == INVALID_HANDLE) playerLootOnGroundId[i] = CreateArray(16);
		if (possibleLootPoolTarget[i] == INVALID_HANDLE) possibleLootPoolTarget[i] = CreateArray(16);
		if (possibleLootPoolActivator[i] == INVALID_HANDLE) possibleLootPoolActivator[i] = CreateArray(16);
		if (HandicapValues[i] == INVALID_HANDLE) HandicapValues[i] = CreateArray(16);
		if (HandicapSelectedValues[i] == INVALID_HANDLE) HandicapSelectedValues[i] = CreateArray(16);
		if (SetHandicapValues[i] == INVALID_HANDLE) SetHandicapValues[i] = CreateArray(16);
		if (AbilityTriggerValues[i] == INVALID_HANDLE) AbilityTriggerValues[i] = CreateArray(16);
		if (TalentPositionsWithEffectName[i] == INVALID_HANDLE) TalentPositionsWithEffectName[i] = CreateArray(16);
		if (PlayerBuffVals[i] == INVALID_HANDLE) PlayerBuffVals[i] = CreateArray(16);
		if (GetStrengthFloat[i] == INVALID_HANDLE) GetStrengthFloat[i] = CreateArray(16);
		if (myUnlockedCategories[i] == INVALID_HANDLE) myUnlockedCategories[i] = CreateArray(16);
		if (myUnlockedActivators[i] == INVALID_HANDLE) myUnlockedActivators[i] = CreateArray(16);
		if (myUnlockedTargets[i] == INVALID_HANDLE) myUnlockedTargets[i] = CreateArray(16);
		if (EquipAugmentPanel[i] == INVALID_HANDLE) EquipAugmentPanel[i] = CreateArray(16);
		if (OnDeathHandicapValues[i] == INVALID_HANDLE) OnDeathHandicapValues[i] = CreateArray(8);
		if (augmentInventoryPosition[i] == INVALID_HANDLE) augmentInventoryPosition[i] = CreateArray(16);
	}
	CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	b_FirstLoad = true;
}

stock OnMapStartFunc() {
	if (!b_MapStart) {
		b_MapStart = true;
		if (!b_FirstLoad) CreateAllArrays();
		CreateTimer(10.0, Timer_GetCampaignName, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	SetSurvivorsAliveHostname();
}

public void OnAllPluginsLoaded() {
}

public ReadyUp_GetCampaignStatus(mapposition) {
	CurrentMapPosition = mapposition;
}

public void OnMapStart() {
	SetConVarInt(FindConVar("director_no_death_check"), 0);	// leave 0 until figure out why scenario_end doesn't work anymore.
	SetConVarInt(FindConVar("sv_rescue_disabled"), 0);
	SetConVarInt(FindConVar("z_common_limit"), 0);	// there are no commons until the round starts in all game modes to give players a chance to move.
	iTopThreat = 0;
	// When the server restarts, for any reason, RPG will properly load.
	//if (!b_FirstLoad) OnMapStartFunc();
	// This can call more than once, and we only want it to fire once.
	// The variable resets to false when a map ends.
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel(FALLEN_SURVIVOR_MODEL, true);
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	PrecacheModel("models/infected/witch_bride.mdl", true);
	PrecacheModel("models/infected/witch.mdl", true);
	PrecacheModel("models/props_interiors/toaster.mdl", true);
	int modelprecacheSize = GetArraySize(ModelsToPrecache);
	if (modelprecacheSize > 0) {
		for (int i = 0; i < modelprecacheSize; i++) {
			char modelName[64];
			GetArrayString(ModelsToPrecache, i, modelName, 64);
			if (IsModelPrecached(modelName)) continue;
			PrecacheModel(modelName, true);
		}
	}

	PrecacheSound(JETPACK_AUDIO, true);
	g_iSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_BeaconSprite = PrecacheModel("materials/sprites/halo01.vmt", true);
	b_IsActiveRound = false;
	MapRoundsPlayed = 0;
	b_IsCampaignComplete			= false;
	b_IsRoundIsOver					= true;
	b_IsCheckpointDoorStartOpened	= false;
	b_IsMissionFailed				= false;
	ClearArray(SpecialAmmoData);
	ClearArray(CommonAffixes);
	ClearArray(WitchList);
	ClearArray(EffectOverTime);
	ClearArray(TimeOfEffectOverTime);
	ClearArray(StaggeredTargets);
	GetCurrentMap(TheCurrentMap, sizeof(TheCurrentMap));
	Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "%srpg/%s.cfg", ConfigPathDirectory, TheCurrentMap);
	if (!FileExists(CONFIG_MAIN)) Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "rpg/config.cfg");
	else Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "rpg/%s.cfg", TheCurrentMap);
	UnhookAll();
	SetSurvivorsAliveHostname();
	CheckGamemode();
}

stock ResetValues(client) {
	b_HasDeathLocation[client] = false;
}

public void OnMapEnd() {
	if (b_MapStart) b_MapStart = false;
	if (b_IsActiveRound) b_IsActiveRound = false;
	for (int i = 1; i <= MaxClients; i++) {
		if (ISEXPLODE[i] != INVALID_HANDLE) {
			KillTimer(ISEXPLODE[i]);
			ISEXPLODE[i] = INVALID_HANDLE;
		}
		ClearArray(CommonInfected[i]);
	}
	ClearArray(NewUsersRound);
}

public Action Timer_GetCampaignName(Handle timer) {
	ReadyUp_NtvGetCampaignName();
	ReadyUp_NtvIsCampaignFinale();
	return Plugin_Stop;
}

stock CheckGamemode() {
	char TheGamemode[64];
	GetConVarString(g_Gamemode, TheGamemode, sizeof(TheGamemode));
	char TheRequiredGamemode[64];
	GetConfigValue(TheRequiredGamemode, sizeof(TheRequiredGamemode), "gametype?");

	if (!StrEqual(TheRequiredGamemode, "-1") && !StrEqual(TheGamemode, TheRequiredGamemode, false)) {
		LogMessage("Gamemode did not match, changing to %s", TheRequiredGamemode);
		SetConVarString(g_Gamemode, TheRequiredGamemode);
		char TheMapname[64];
		GetCurrentMap(TheMapname, sizeof(TheMapname));
		ServerCommand("changelevel %s", TheMapname);
	}
}

bool SetTalentConfigs() {
	int size = GetArraySize(MainKeys);
	//char result[64];
	//int len = -1;
	ClearArray(TalentMenuConfigs);
	for (int i = 0; i < size; i++) {
		char configname[64];
		GetArrayString(MainKeys, i, configname, 64);
		if (!StrEqual(configname, "talent config?")) continue;
		GetArrayString(MainValues, i, configname, 64);
		PushArrayString(TalentMenuConfigs, configname);
	}
	// ClearArray(SetKeys);
	// ClearArray(SetVals);
	if (GetArraySize(TalentMenuConfigs) > 0) return true;
	return false;
}

bool IsTalentConfig(char[] configname) {
	int size = GetArraySize(TalentMenuConfigs);
	for (int i = 0; i < size; i++) {
		char talentconfig[64];
		GetArrayString(TalentMenuConfigs, i, talentconfig, 64);
		if (StrEqual(configname, talentconfig)) return true;
	}
	return false;
}

public Action Timer_ExecuteConfig(Handle timer) {
	if (ReadyUp_NtvConfigProcessing() == 0) {
		// These are processed one-by-one in a defined-by-dependencies order, but you can place them here in any order you want.
		// I've placed them here in the order they load for uniformality.
		ReadyUp_ParseConfig(CONFIG_MAIN);
		ReadyUp_ParseConfig(CONFIG_EVENTS);
		ReadyUp_ParseConfig(CONFIG_SURVIVORTALENTS);
		SetTalentConfigs();
		for (int i = 0; i < GetArraySize(TalentMenuConfigs); i++) {
			char configname[64];
			GetArrayString(TalentMenuConfigs, i, configname, 64);
			ReadyUp_ParseConfig(configname);
		}		
		ReadyUp_ParseConfig(CONFIG_POINTS);
		ReadyUp_ParseConfig(CONFIG_STORE);
		ReadyUp_ParseConfig(CONFIG_TRAILS);
		ReadyUp_ParseConfig(CONFIG_MAINMENU);
		ReadyUp_ParseConfig(CONFIG_WEAPONS);
		ReadyUp_ParseConfig(CONFIG_COMMONAFFIXES);
		ReadyUp_ParseConfig(CONFIG_HANDICAP);
		//ReadyUp_ParseConfig(CONFIG_CLASSNAMES);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_AutoRes(Handle timer) {
	if (b_IsCheckpointDoorStartOpened) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && myCurrentTeam[i] == TEAM_SURVIVOR) {
			if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
			else if (IsIncapacitated(i)) ExecCheatCommand(i, "give", "health");
		}
	}
	return Plugin_Continue;
}

stock bool AnyHumans() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

public ReadyUp_ReadyUpStart() {
	lootDropCounter = 0;	// reset the loot drop counter.
	CheckDifficulty();
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
	bool TeleportPlayers = false;
	float teleportIntoSaferoom[3];
	if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -300.968750;
		TeleportPlayers = true;
	}

	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			if (b_IsLoaded[i] && myCurrentTeam[i] == TEAM_SURVIVOR && ReadyUpGameMode != 3) {
				CreateTimer(1.0, Timer_Pregame, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			if (TeleportPlayers) TeleportEntity(i, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
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
			if (!IsFakeClient(i)) continue;
			if (b_IsLoaded[i]) GiveMaximumHealth(i);
		}
	}
	RefreshSurvivorBots();
}

public ReadyUp_ReadyUpEnd() {
	ReadyUpEnd_Complete();
}

public Action Timer_Defibrillator(Handle timer, any client) {
	if (IsLegitimateClient(client) && !IsPlayerAlive(client)) {
		Defibrillator(0, client);
	}
	return Plugin_Stop;
}

public ReadyUpEnd_Complete() {

	if (b_IsRoundIsOver) {
		b_IsRoundIsOver = false;
		CreateTimer(30.0, Timer_CheckDifficulty, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CheckDifficulty();
		b_IsMissionFailed = false;
		ClearArray(CommonAffixes);
		b_IsCheckpointDoorStartOpened = false;
		char pct[4];
		Format(pct, sizeof(pct), "%");
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i)) continue;
			if (IsFakeClient(i) && !b_IsLoaded[i]) IsClientLoadedEx(i);
			if (!IsFakeClient(i) && RoundExperienceMultiplier[i] > 0.0) {
				char saferoomName[64];
				GetClientName(i, saferoomName, sizeof(saferoomName));
				PrintToChatAll("%t", "round bonus multiplier", blue, saferoomName, white, orange, (1.0 + RoundExperienceMultiplier[i]) * 100.0, orange, pct, white);
			}
		}
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || !b_IsLoaded[i]) continue;
			staggerCooldownOnTriggers[i] = false;
			ISBILED[i] = false;
			bHasWeakness[i] = 0;
			SurvivorEnrage[i][0] = 0.0;
			SurvivorEnrage[i][1] = 0.0;
			ISDAZED[i] = 0.0;
			if (myCurrentTeam[i] == TEAM_SURVIVOR) {
				SurvivorStamina[i] = GetPlayerStamina(i) - 1;
				SetMaximumHealth(i);
				GiveMaximumHealth(i);
			}
			bIsSurvivorFatigue[i] = false;
			LastWeaponDamage[i] = 1;
			HealingContribution[i] = 0;
			TankingContribution[i] = 0;
			DamageContribution[i] = 0;
			PointsContribution[i] = 0.0;
			HexingContribution[i] = 0;
			BuffingContribution[i] = 0;
			b_IsFloating[i] = false;
			SetMyWeapons(i);
		}
	}
}

stock TimeUntilEnrage(char[] TheText, TheSize) {
	if (!IsEnrageActive()) {
		int Seconds = (iEnrageTime * 60) - (GetTime() - RoundTime);
		int Minutes = 0;
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
	int secondsLeftUntilEnrage = (iEnrageTime * 60) - (GetTime() - RoundTime);
	return secondsLeftUntilEnrage;
}

stock RPGRoundTime(bool IsSeconds = false) {
	int Seconds = GetTime() - RoundTime;
	if (IsSeconds) return Seconds;
	int Minutes = 0;
	while (Seconds >= 60) {
		Minutes++;
		Seconds -= 60;
	}
	return Minutes;
}

stock bool IsEnrageActive() {
	if (!b_IsActiveRound || IsSurvivalMode || iEnrageTime < 1) return false;
	if (RPGRoundTime() < iEnrageTime) return false;
	if (!IsEnrageNotified && iNotifyEnrage == 1) {
		IsEnrageNotified = true;
		PrintToChatAll("%t", "enrage period", orange, blue, orange);
	}
	return true;
}

bool IsPlayerWithinBuffRange(client, char[] effectName) {
	ClearArray(TalentPositionsWithEffectName[client]);
	int size = GetArraySize(a_Menu_Talents);
	char result[64];
	for (int i = 0; i < size; i++) {
		PlayerBuffVals[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(PlayerBuffVals[client], ACTIVATOR_ABILITY_EFFECTS, result, sizeof(result));
		if (!StrEqual(result, effectName)) continue;
		PushArrayCell(TalentPositionsWithEffectName[client], i);
	}
	size = GetArraySize(TalentPositionsWithEffectName[client]);
	float cpos[3];
	GetClientAbsOrigin(client, cpos);
	for (int i = 1; i <= MaxClients; i++) {
		// skip client, dead players, and players not on clients team
		if (i == client || !IsLegitimateClientAlive(i) || myCurrentTeam[i] != myCurrentTeam[client]) continue;
		float ipos[3];
		GetClientAbsOrigin(i, ipos);
		for (int ii = 0; ii < size; ii++) {
			int pos = GetArrayCell(TalentPositionsWithEffectName[client], ii);
			float fRange = GetStrengthByKeyValueFloat(i, ACTIVATOR_ABILITY_EFFECTS, effectName, COHERENCY_RANGE, pos);
			if (fRange <= 0.0) continue;	// no talents with this specification found.
			if (GetVectorDistance(cpos, ipos) > fRange) continue;	// if the client is not within player i's coherency range
			return true;
		}
	}
	return false;	// client is not within range of this talent for any player on their team that has it.
}

stock int PlayerHasWeakness(client) {	// order of least-intensive calculations to most.
	if (bForcedWeakness[client]) return 3;
	if (iCurrentIncapCount[client] >= iMaxIncap || IsSpecialCommonInRange(client, 'w')) return 1;
	if (IsClientInRangeSpecialAmmo(client, "W")) return 2;
	return 0;
}

public ReadyUp_CheckpointDoorStartOpened() {
	if (!b_IsCheckpointDoorStartOpened) {
		b_IsCheckpointDoorStartOpened		= true;
		SetBotClientHandicapValues();
		b_IsRescueVehicleArrived = false;
		b_IsActiveRound = true;
		bIsSettingsCheck = true;
		IsEnrageNotified = false;
		b_IsFinaleTanks = false;
		ClearArray(ListOfWitchesWhoHaveBeenShot);
		ClearArray(persistentCirculation);
		ClearArray(CoveredInVomit);
		if (CurrentMapPosition == 0) {
			ClearArray(RoundStatistics);
			ResizeArray(RoundStatistics, 5);
			for (int i = 0; i < 5; i++) {
				SetArrayCell(RoundStatistics, i, 0);
				SetArrayCell(RoundStatistics, i, 0, 1);	// first map of campaign, reset the total.
			}
		}
		else {
			if (GetArraySize(RoundStatistics) < 5) ResizeArray(RoundStatistics, 5);
			for (int i = 0; i < 5; i++) {
				SetArrayCell(RoundStatistics, i, 0);
			}
		}
		char pct[4];
		Format(pct, sizeof(pct), "%");
		char text[64];
		int survivorCounter = TotalHumanSurvivors();
		bool AnyBotsOnSurvivorTeam = BotsOnSurvivorTeam();
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i)) continue;
			SetMyWeapons(i);
			if (IsFakeClient(i)) continue;
			bIsMeleeCooldown[i] = false;
			iCurrentIncapCount[i] = 0;
			if (GroupMemberBonus > 0.0) {
				if (IsGroupMember[i]) PrintToChat(i, "%T", "group member bonus", i, blue, GroupMemberBonus * 100.0, pct, green, orange);
				else PrintToChat(i, "%T", "group member benefit", i, orange, blue, GroupMemberBonus * 100.0, pct, green, blue);
			}
			if (!AnyBotsOnSurvivorTeam && fSurvivorBotsNoneBonus > 0.0 && survivorCounter <= iSurvivorBotsBonusLimit) PrintToChat(i, "%T", "group no survivor bots bonus", i, blue, fSurvivorBotsNoneBonus * 100.0, pct, green, orange);
			if (RoundExperienceMultiplier[i] > 0.0) PrintToChat(i, "%T", "survivalist bonus experience", i, blue, orange, green, RoundExperienceMultiplier[i] * 100.0, white, pct);
		}
		CheckDifficulty();
		RoundTime					=	GetTime();
		int ent = -1;
		if (ReadyUpGameMode != 3) {
			while ((ent = FindEntityByClassname(ent, "witch")) != -1) {
				// Some maps, like Hard Rain pre-spawn a ton of witches - we want to add them to the witch table.
				OnWitchCreated(ent);
			}
			char thetext[64];
			GetConfigValue(thetext, sizeof(thetext), "path setting?");
			if (ReadyUpGameMode != 3 && !StrEqual(thetext, "none")) {
				if (!StrEqual(thetext, "random")) ServerCommand("sm_forcepath %s", thetext);
				else {
					if (StrEqual(PathSetting, "none")) {
						int random = GetRandomInt(1, 100);
						if (random <= 33) Format(PathSetting, sizeof(PathSetting), "easy");
						else if (random <= 66) Format(PathSetting, sizeof(PathSetting), "medium");
						else Format(PathSetting, sizeof(PathSetting), "hard");
					}
					ServerCommand("sm_forcepath %s", PathSetting);
				}
			}
		}
		else {
			IsSurvivalMode = true;
		}
		b_IsCampaignComplete				= false;
		if (ReadyUpGameMode != 3) b_IsRoundIsOver						= false;
		if (ReadyUpGameMode == 2) MapRoundsPlayed = 0;	// Difficulty leniency does not occur in versus.
		SpecialsKilled				=	0;
		//RoundDamageTotal			=	0;
		b_IsFinaleActive			=	false;
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || !b_IsLoaded[i] || myCurrentTeam[i] != TEAM_SURVIVOR) continue;
			if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
			VerifyMinimumRating(i);
			HealImmunity[i] = false;
			if (b_IsLoaded[i]) {
				SetMaximumHealth(i);
				GiveMaximumHealth(i);
			}
		}
		f_TankCooldown				=	-1.0;
		ResetCDImmunity(-1);
		DoomTimer = 0;
		if (ReadyUpGameMode != 2 && fDirectorThoughtDelay > 0.0) CreateTimer(1.0, Timer_DirectorPurchaseTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (RespawnQueue > 0) CreateTimer(1.0, Timer_RespawnQueue, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		RaidInfectedBotLimit();
		CreateTimer(1.0, Timer_StartPlayerTimers, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_CheckIfHooked, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(GetConfigValueFloat("settings check interval?"), Timer_SettingsCheck, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (DoomSUrvivorsRequired != 0) CreateTimer(1.0, Timer_Doom, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Timer_EntityOnFire, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		// Fire status effect
		CreateTimer(1.0, Timer_ThreatSystem, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		// threat system modulator
		CreateTimer(fStaggerTickrate, Timer_StaggerTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(fDrawHudInterval, Timer_ShowHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(fSpecialAmmoInterval, Timer_ShowActionBar, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (iCommonAffixes > 0) {
			ClearArray(CommonAffixes);
			CreateTimer(1.0, Timer_CommonAffixes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		ClearRelevantData();
		LastLivingSurvivor = 1;
		int size = GetArraySize(a_DirectorActions);
		ResizeArray(a_DirectorActions_Cooldown, size);
		for (int i = 0; i < size; i++) SetArrayString(a_DirectorActions_Cooldown, i, "0");
		int theCount = LivingSurvivorCount();
		if (iSurvivorModifierRequired > 0 && fSurvivorExpMult > 0.0 && theCount >= iSurvivorModifierRequired) {
			PrintToChatAll("%t", "teammate bonus experience", blue, green, ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorExpMult) * 100.0, pct);
		}
		RefreshSurvivorBots();
		if (iResetDirectorPointsOnNewRound == 1) Points_Director = 0.0;
		char currentMapEnrageTimerText[64];
		Format(currentMapEnrageTimerText, sizeof(currentMapEnrageTimerText), "enrage time %s?", TheCurrentMap);
		int iEnrageTimeCurrentMap			= GetConfigValueInt(currentMapEnrageTimerText);
		if (iEnrageTimeCurrentMap > 0) {
			iEnrageTime							= iEnrageTimeCurrentMap;
			iHideEnrageTimerUntilSecondsLeft	= iEnrageTime/3;
		}
		else LogMessage("No custom enrage timer cvar found in your config.cfg: %s", currentMapEnrageTimerText);
		if (iEnrageTime > 0) {
			TimeUntilEnrage(text, sizeof(text));
			PrintToChatAll("%t", "time until things get bad", orange, green, text, orange);
		}
	}
}

stock RefreshSurvivorBots() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && IsFakeClient(i)) RefreshSurvivor(i);
	}
}

stock SetClientMovementSpeed(client) {
	if (IsValidEntity(client)) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", fBaseMovementSpeed);
}

stock ResetCoveredInBile(client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			CoveredInBile[client][i] = -1;
			CoveredInBile[i][client] = -1;
		}
	}
}

stock FindTargetClient(client, char[] arg) {
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	int targetclient;
	if ((target_count = ProcessTargetString(
		arg,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) > 0) {
		for (int i = 0; i < target_count; i++) targetclient = target_list[i];
	}
	return targetclient;
}

stock CMD_CastAction(client, args) {
	char actionpos[64];
	GetCmdArg(1, actionpos, sizeof(actionpos));
	if (StrContains(actionpos, acmd, false) != -1 && !StrEqual(abcmd, actionpos[1], false)) {
		CastActionEx(client, actionpos, sizeof(actionpos));
	}
}

stock CastActionEx(client, char[] t_actionpos = "none", TheSize, pos = -1) {
	int ActionSlots = iActionBarSlots;
	if (pos == -1) pos = StringToInt(t_actionpos[strlen(t_actionpos) - 1]) - 1;//StringToInt(actionpos[strlen(actionpos) - 1]);
	if (pos >= 0 && pos < ActionSlots) {
		int menuPos = GetArrayCell(ActionBarMenuPos[client], pos);
		if (menuPos < 0 || GetArrayCell(MyTalentStrength[client], menuPos) < 1) return;
		
		CastValues[client]			= GetArrayCell(a_Menu_Talents, menuPos, 1);
		if (GetArrayCell(CastValues[client], ABILITY_PASSIVE_ONLY) == 1) return;
		int AbilityTalent = 0;
		float TargetPos[3];
		char TalentName[64];
		GetArrayString(a_Database_Talents, menuPos, TalentName, sizeof(TalentName));

		char hitgroup[4];
		//CastKeys[client]			= GetArrayCell(a_Menu_Talents, menuPos, 0);
		//CastSection[client]			= GetArrayCell(a_Menu_Talents, i, 2);
		AbilityTalent = GetArrayCell(CastValues[client], IS_TALENT_ABILITY);
		int RequiresTarget = GetArrayCell(CastValues[client], ABILITY_IS_SINGLE_TARGET);
		float visualDelayTime = GetArrayCell(CastValues[client], ABILITY_DRAW_DELAY);
		if (visualDelayTime < 1.0) visualDelayTime = 1.0;
		if (RequiresTarget > 0) {
			RequiresTarget = GetAimTargetPosition(client, TargetPos, hitgroup, 4);
			if (IsLegitimateClientAlive(RequiresTarget)) {
				if (AbilityTalent != 1) CastSpell(client, RequiresTarget, TalentName, TargetPos, visualDelayTime, menuPos);
				else UseAbility(client, RequiresTarget, TalentName, CastValues[client], TargetPos, menuPos);
			}
		}
		else {
			GetAimTargetPosition(client, TargetPos, hitgroup, 4);
			if (AbilityTalent != 1) CastSpell(client, _, TalentName, TargetPos, visualDelayTime, menuPos);
			else {
				CheckActiveAbility(client, pos, _, _, true, true);
				UseAbility(client, _, TalentName, CastValues[client], TargetPos, menuPos);
			}
		}
	}
	else {
		PrintToChat(client, "%T", "Action Slot Range", client, white, blue, ActionSlots, white);
	}
}

stock MySurvivorCompanion(client) {
	char SteamId[64];
	char CompanionSteamId[64];
	GetClientAuthId(client, AuthId_Steam2, SteamId, sizeof(SteamId));
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && myCurrentTeam[i] == TEAM_SURVIVOR && IsFakeClient(i)) {

			GetEntPropString(i, Prop_Data, "m_iName", CompanionSteamId, sizeof(CompanionSteamId));
			if (StrEqual(CompanionSteamId, SteamId, false)) return i;
		}
	}
	return -1;
}

public Action CMD_TogglePvP(client, args) {
	int TheTime = RoundToCeil(GetEngineTime());
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

public Action CMD_SetAugmentPrice(client, args) {
	if (args < 2) {
		PrintToChat(client, "\x04!price <augmentId> <price>");
		return Plugin_Handled;
	}
	int size = GetArraySize(myAugmentIDCodes[client]);
	char arg[512];
	char arg2[64];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	int augmentSlotToModify = StringToInt(arg);
	if (augmentSlotToModify >= 0 && augmentSlotToModify < size) {
		int augmentPrice = StringToInt(arg2);
		if (augmentPrice > 10000) augmentPrice = 10000;
		if (augmentPrice < 0) augmentPrice = 0;
		SetArrayCell(myAugmentInfo[client], augmentSlotToModify, augmentPrice, 1);
		PrintToChat(client, "\x04augment price set: \x03%d", augmentPrice);
	}
	else PrintToChat(client, "\x04augment id could not be found. \x03no price adjustments were made.");
	return Plugin_Handled;
}

public Action CMD_GiveLevel(client, args) {
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "give player level flags?");
	if ((HasCommandAccess(client, thetext) || client == 0) && args > 1) {
		char arg[512];
		char arg2[64];
		char arg3[64];
		GetCmdArg(1, arg, sizeof(arg));
		GetCmdArg(2, arg2, sizeof(arg2));
		GetCmdArg(3, arg3, sizeof(arg3));
		int targetclient = 0;
		bool hasSTEAM = (StrContains(arg, "STEAM", true) != -1) ? true : false;
		if (!hasSTEAM) targetclient = FindTargetClient(client, arg);
		if (args < 3 || hasSTEAM) {
			if (hasSTEAM) {
				char tquery[512];
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
					char Name[64];
					GetClientName(targetclient, Name, sizeof(Name));
					PrintToChatAll("%t", "client level set", Name, green, white, blue, PlayerLevel[targetclient]);
					FormatPlayerName(targetclient);
				}
			}
		}
		else if (args == 3 && IsLegitimateClient(targetclient) && StrContains(arg2, "rating", false) != -1) {
			Rating[targetclient] = StringToInt(arg3);
			BestRating[targetclient] = StringToInt(arg3);
		}
		else if (args == 4 && IsLegitimateClient(targetclient) && StrContains(arg2, "proficiency", false) != -1) {
			char arg4[64];
			GetCmdArg(4, arg4, sizeof(arg4));
			SetProficiencyData(targetclient, StringToInt(arg3), StringToInt(arg4));
		}
	}
	return Plugin_Handled;
}

stock GetExperienceRequirement(newlevel) {
	int baseExperienceCounter = (newlevel > iHardcoreMode) ? iHardcoreMode : newlevel;
	int hardExperienceCounter = (newlevel > iHardcoreMode) ? newlevel - iHardcoreMode : 0;

	float fExpMult = fExperienceMultiplier * (baseExperienceCounter - 1);
	float fExpHard = fExperienceMultiplierHardcore * (hardExperienceCounter - 1);
	return iExperienceStart + RoundToCeil(iExperienceStart * (fExpMult + fExpHard));
}

stock CheckExperienceRequirement(client, bool bot = false, iLevel = 0, previousLevelRequirement = 0) {
	int experienceRequirement = 0;
	if (IsLegitimateClient(client)) {
		int levelToCalculateFor = (iLevel == 0) ? PlayerLevel[client] : iLevel;

		experienceRequirement			=	iExperienceStart;
		float experienceMultiplier	=	0.0;
		float hardcoreMultiplier	=	0.0;

		int baseExperienceCounter = (levelToCalculateFor > iHardcoreMode) ? iHardcoreMode : levelToCalculateFor;
		int hardExperienceCounter = (levelToCalculateFor > iHardcoreMode) ? levelToCalculateFor - iHardcoreMode : 0;

		if (iUseLinearLeveling == 1) {
			experienceMultiplier 			=	fExperienceMultiplier * (baseExperienceCounter - 1);
			hardcoreMultiplier				=	fExperienceMultiplierHardcore * (hardExperienceCounter - 1);
			experienceRequirement			=	iExperienceStart + RoundToCeil(iExperienceStart * (experienceMultiplier + hardcoreMultiplier));
		}
		else if (previousLevelRequirement != 0) {
			if (PlayerLevel[client] < iHardcoreMode) experienceRequirement			=	previousLevelRequirement + RoundToCeil(previousLevelRequirement * fExperienceMultiplier);
			else experienceRequirement			=	previousLevelRequirement + RoundToCeil(previousLevelRequirement * fExperienceMultiplierHardcore);
		}
		else if (levelToCalculateFor > 1) {
			for (int i = 1; i < levelToCalculateFor; i++) {
				if (i < iHardcoreMode) experienceRequirement		+=	RoundToCeil(experienceRequirement * fExperienceMultiplier);
				else experienceRequirement		+=	RoundToCeil(experienceRequirement * fExperienceMultiplierHardcore);
			}
		}
	}
	return experienceRequirement;
}

stock GetPlayerLevel(client) {
	int iExperienceOverall = ExperienceOverall[client];
	int iLevel = 1;
	int ExperienceRequirement = CheckExperienceRequirement(client, false, iLevel);
	while (iExperienceOverall >= ExperienceRequirement && iLevel < iMaxLevel) {
		if (iIsLevelingPaused[client] == 1 && iExperienceOverall == ExperienceRequirement) break;
		iExperienceOverall -= ExperienceRequirement;
		iLevel++;
		ExperienceRequirement = CheckExperienceRequirement(client, false, iLevel, ExperienceRequirement);
	}
	return iLevel;
}

stock GetTotalExperienceByLevel(newlevel) {
	int experienceTotal = 0;
	if (newlevel > iMaxLevel) newlevel = iMaxLevel;
	for (int i = 1; i <= newlevel; i++) {
		if (newlevel == i) break;
		experienceTotal += GetExperienceRequirement(i);
	}
	experienceTotal++;
	return experienceTotal;
}

stock SetTotalExperienceByLevel(client, newlevel, bool giveMaxXP = false) {
	int oldlevel = PlayerLevel[client];
	ExperienceOverall[client] = 0;
	ExperienceLevel[client] = 0;
	if (newlevel > iMaxLevel) newlevel = iMaxLevel;
	PlayerLevel[client] = newlevel;
	for (int i = 1; i <= newlevel; i++) {
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

public Action CMD_ReloadConfigs(client, args) {
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "reload configs flags?");

	if (HasCommandAccess(client, thetext)) {
		CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		PrintToChat(client, "Reloading Config.");
	}
	return Plugin_Handled;
}

public ReadyUp_FirstClientLoaded() {
	RefreshSurvivorBots();
	ReadyUpGameMode = ReadyUp_GetGameMode();
}

public Action CMD_SharePoints(client, args) {
	if (args < 2) {
		char thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "reload configs flags?");

		PrintToChat(client, "%T", "Share Points Syntax", client, orange, white, thetext);
		return Plugin_Handled;
	}

	char arg[MAX_NAME_LENGTH];
	char arg2[10];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	float SharePoints = 0.0;
	if (StrContains(arg2, ".", false) == -1) SharePoints = StringToInt(arg2) * 1.0;
	else SharePoints = StringToFloat(arg2);

	if (SharePoints > Points[client]) return Plugin_Handled;

	int targetclient = FindTargetClient(client, arg);
	if (!IsLegitimateClient(targetclient)) return Plugin_Handled;
	char Name[MAX_NAME_LENGTH];
	GetClientName(targetclient, Name, sizeof(Name));
	char GiftName[MAX_NAME_LENGTH];
	GetClientName(client, GiftName, sizeof(GiftName));
	Points[client] -= SharePoints;
	Points[targetclient] += SharePoints;

	PrintToChatAll("%t", "Share Points Given", blue, GiftName, white, green, SharePoints, white, blue, Name); 
	return Plugin_Handled;
}

public Action CMD_ActionBar(client, args) {
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

/*public Action CMD_GiveInventoryItem(client, args) {
	if (args < 2) {
		PrintToChat(client, "\x04!giveaugment <name> <augment id>");
		return Plugin_Handled;
	}

	char arg[MAX_NAME_LENGTH];
	char arg2[4];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	int targetclient = 0;
	if (StrEqual(arg, "aim", false)) targetclient = GetClientAimTarget(client, true);
	else {
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || IsFakeClient(i) || i == client) continue;
			char playerName[64];
			GetClientName(i, playerName, 64);
			if (StrContains(playerName, arg, false) == -1) continue;
			targetclient = i;
			break;
		}
	}
	if (!IsLegitimateClient(targetclient) || GetClientTeam(targetclient) != TEAM_SURVIVOR || IsFakeClient(targetclient)) return Plugin_Handled;
	char Name[MAX_NAME_LENGTH];
	GetClientName(targetclient, Name, sizeof(Name));
	int pos = StringToInt(arg2);
	int eq = GetArrayCell(myAugmentInfo[client], pos, 3);
	if (eq >= 0 && eq < iNumAugments) {
		PrintToChat(client, "\x04Ownership of equipped augments cannot be transferred.");
		return Plugin_Handled;
	}

	char key[64];
	GetClientAuthId(targetclient, AuthId_Steam2, key, sizeof(key));
	char itemCode[64];
	GetArrayString(myAugmentIDCodes[client], pos, itemCode, 64);
	char category[64];
	GetArrayString(myAugmentCategories[client], pos, category, sizeof(category));
	int itemRating = GetArrayCell(myAugmentInfo[client], pos);
	char activatorEffects[64];
	int activatorEffectRating = GetArrayCell(myAugmentInfo[client], pos, 4);
	GetArrayString(myAugmentActivatorEffects[client], pos, activatorEffects, sizeof(activatorEffects));
	char targetEffects[64];
	int targetEffectRating = GetArrayCell(myAugmentInfo[client], pos, 5);
	GetArrayString(myAugmentTargetEffects[client], pos, targetEffects, sizeof(targetEffects));
	char originalOwner[64];
	GetArrayString(myAugmentOwners[client], pos, originalOwner, sizeof(originalOwner));

	RemoveFromArray(myAugmentIDCodes[client], pos);
	RemoveFromArray(myAugmentCategories[client], pos);
	RemoveFromArray(myAugmentOwners[client], pos);
	RemoveFromArray(myAugmentInfo[client], pos);
	RemoveFromArray(myAugmentActivatorEffects[client], pos);
	RemoveFromArray(myAugmentTargetEffects[client], pos);
	
	int size = GetArraySize(myAugmentIDCodes[targetclient]);
	ResizeArray(myAugmentIDCodes[targetclient], size+1);
	ResizeArray(myAugmentCategories[targetclient], size+1);
	ResizeArray(myAugmentOwners[targetclient], size+1);
	ResizeArray(myAugmentInfo[targetclient], size+1);
	ResizeArray(myAugmentActivatorEffects[targetclient], size+1);
	ResizeArray(myAugmentTargetEffects[targetclient], size+1);

	SetArrayCell(myAugmentInfo[targetclient], size, itemRating);
	SetArrayCell(myAugmentInfo[targetclient], size, 0, 1);	// item cost
	SetArrayCell(myAugmentInfo[targetclient], size, 0, 2);	// not for sale
	SetArrayCell(myAugmentInfo[targetclient], size, -1, 3); // not equipped
	SetArrayCell(myAugmentInfo[targetclient], size, activatorEffectRating, 4);
	SetArrayCell(myAugmentInfo[targetclient], size, targetEffectRating, 5);
	SetArrayString(myAugmentOwners[targetclient], size, originalOwner);
	SetArrayString(myAugmentCategories[targetclient], size, category);
	SetArrayString(myAugmentIDCodes[targetclient], size, itemCode);
	SetArrayString(myAugmentActivatorEffects[targetclient], size, activatorEffects);
	SetArrayString(myAugmentTargetEffects[targetclient], size, targetEffects);
	char sql[512];
	Format(sql, sizeof(sql), "UPDATE `%s_loot` SET `steam_id` = '%s' WHERE (`itemid` = '%s');", TheDBPrefix, key, itemCode);
	SQL_TQuery(hDatabase, QueryResults, sql);

	PrintToChat(client, "You gave %N an augment.", targetclient);
	PrintToChat(targetclient, "%N gave you an augment... Check it out.", client);
	Augments_Inventory(client);
	return Plugin_Handled;
}*/

public Action CMD_GiveStorePoints(client, args) {
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "give store points flags?");
	if (!HasCommandAccess(client, thetext)) { PrintToChat(client, "You don't have access."); return Plugin_Handled; }
	if (args < 2) {
		PrintToChat(client, "%T", "Give Store Points Syntax", client, orange, white);
		return Plugin_Handled;
	}
	char arg[MAX_NAME_LENGTH];
	char arg2[4];
	GetCmdArg(1, arg, sizeof(arg));
	if (args > 1) {
		GetCmdArg(2, arg2, sizeof(arg2));
	}
	int targetclient = FindTargetClient(client, arg);
	char Name[MAX_NAME_LENGTH];
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

public Action CMD_CollectBonusExperience(client, args) {
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
		if (myCurrentTeam[i] == TEAM_INFECTED && IsFakeClient(i)) continue;	// infected bots are skipped.
		//ToggleTank(i, true);
		if (b_IsMissionFailed && LivingSurvs > 0 && myCurrentTeam[i] == TEAM_SURVIVOR) {
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
		for (int i = 0; i < 5; i++) {
			SetArrayCell(RoundStatistics, i, GetArrayCell(RoundStatistics, i) + GetArrayCell(RoundStatistics, i, 1), 1);
		}
		int pEnt = -1;
		char pText[2][64];
		char text[64];
		int pSize = GetArraySize(persistentCirculation);
		for (int i = 0; i < pSize; i++) {
			GetArrayString(persistentCirculation, i, text, sizeof(text));
			ExplodeString(text, ":", pText, 2, 64);
			pEnt = StringToInt(pText[0]);
			if (IsValidEntity(pEnt)) AcceptEntityInput(pEnt, "Kill");
		}
		ClearArray(persistentCirculation);
		b_IsRoundIsOver					= true;
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i)) continue;
			bTimersRunning[i] = false;
			ClearArray(playerLootOnGround[i]);
			ClearArray(playerLootOnGroundId[i]);
			ClearArray(CommonInfected[i]);
		}
		if (b_IsActiveRound) b_IsActiveRound = false;
		SetSurvivorsAliveHostname();
		int Seconds			= GetTime() - RoundTime;
		int Minutes			= 0;
		while (Seconds >= 60) {
			Minutes++;
			Seconds -= 60;
		}
		//common is 0
		//super is 1
		//witch is 2
		//si is 3
		//tank is 4
		char roundStatisticsText[6][64];
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
				int livingSurvs = LivingSurvivors() - 1;
				float fRoundExperienceBonus = (livingSurvs > 0) ? fCoopSurvBon * livingSurvs : 0.0;
				char pct[4];
				Format(pct, sizeof(pct), "%");
				//RoundExperienceMultiplier[i] += FinSurvBon;
				float fExperienceBonus = fRoundExperienceBonus;
				if (b_IsRescueVehicleArrived) fExperienceBonus += FinSurvBon;
				// if (fRoundExperienceBonus > 0.0) {
				// 	PrintToChatAll("%t", "living survivors experience bonus", orange, blue, orange, white, blue, fExperienceBonus * 100.0, white, pct, orange);
				// }
				ClearArray(damageOfSpecialInfected);
				ClearArray(damageOfWitch);
				ClearArray(damageOfSpecialCommon);
				ClearArray(damageOfCommonInfected);
				for (int i = 1; i <= MaxClients; i++) {
					if (IsLegitimateClient(i)) {
						ClearArray(WitchDamage[i]);
						ClearArray(InfectedHealth[i]);
						ClearArray(SpecialCommon[i]);
						ClearArray(CommonInfected[i]);
						ImmuneToAllDamage[i] = false;
						iThreatLevel[i] = 0;
						bIsInCombat[i] = false;
						fSlowSpeed[i] = 1.0;
						if (myCurrentTeam[i] != TEAM_SURVIVOR || !IsPlayerAlive(i)) continue;
						if (Rating[i] < 0 && CurrentMapPosition != 1) VerifyMinimumRating(i);
						if (RoundExperienceMultiplier[i] < 0.0) RoundExperienceMultiplier[i] = 0.0;
						if (fExperienceBonus > 0.0) {
							float scoreMult = GetScoreMultiplier(i);
							if (scoreMult > 0.0) {
								scoreMult = (scoreMult * fExperienceBonus);
								RoundExperienceMultiplier[i] += scoreMult;
								PrintToChat(i, "%T", "living survivors experience bonus", i, orange, blue, orange, white, blue, scoreMult * 100.0, white, pct, orange);
							}
						}
						//else PrintToChat(i, "no round bonus applied.");
						AwardExperience(i, _, _, true);
					}
				}
			}
		}
		int humanSurvivorsInGame = TotalHumanSurvivors();
		// only save data on round end if there is at least 1 human on the survivor team.
		// rounds will constantly loop if the survivor team is all bots.
		if (humanSurvivorsInGame > 0) {
			for (int i = 1; i <= MaxClients; i++) {
				if (!IsLegitimateClient(i)) continue;
				if (myCurrentTeam[i] == TEAM_INFECTED && IsFakeClient(i)) continue;	// infected bots are skipped.
				//ToggleTank(i, true);
				if (b_IsMissionFailed) {
					if (myCurrentTeam[i] == TEAM_SURVIVOR) {
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
				//if (b_IsMissionFailed && CurrentMapPosition != 1 || !IsFakeClient(i))
				SavePlayerData(i);
			}
		}
		//CreateTimer(1.0, Timer_SaveAndClear, _, TIMER_FLAG_NO_MAPCHANGE);
		b_IsCheckpointDoorStartOpened	= false;
		RemoveImmunities(-1);
		ClearArray(LoggedUsers);		// when a round ends, logged users are removed.
		b_IsActiveRound = false;
		MapRoundsPlayed++;
		ClearArray(WitchList);
		ClearArray(CommonList);
		ClearArray(EntityOnFire);
		ClearArray(EntityOnFireName);
		ClearArray(CommonInfectedQueue);
		ClearArray(SuperCommonQueue);
		ClearArray(StaggeredTargets);
		ClearArray(SpecialAmmoData);
		ClearArray(CommonAffixes);
		ClearArray(EffectOverTime);
		ClearArray(TimeOfEffectOverTime);
		if (b_IsMissionFailed && StrContains(TheCurrentMap, "zerowarn", false) != -1) {
			// need to force-teleport players here on new spawn: 4087.998291 11974.557617 -269.968750
			CreateTimer(5.0, Timer_ResetMap, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (StrContains(TheCurrentMap, "helms", false) != -1) {
			CreateTimer(3.0, Timer_ResetMap, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Timer_ResetMap(Handle timer) {
	//if (StrContains(TheCurrentMap, "helms", false) != -1) L4D_RestartScenarioFromVote(TheCurrentMap);
	if (StrContains(TheCurrentMap, "helms", false) != -1) ServerCommand("changelevel %s", TheCurrentMap);
	return Plugin_Stop;
}

stock ResetArray(Handle TheArray) {

	ClearArray(TheArray);
}

public ReadyUp_ParseConfigFailed(char[] config, char[] error) {

	if (StrEqual(config, CONFIG_MAIN) ||
		StrEqual(config, CONFIG_EVENTS) ||
		StrEqual(config, CONFIG_SURVIVORTALENTS) ||
		IsTalentConfig(config) ||
		StrEqual(config, CONFIG_MAINMENU) ||
		StrEqual(config, CONFIG_POINTS) ||
		StrEqual(config, CONFIG_STORE) ||
		StrEqual(config, CONFIG_TRAILS) ||
		StrEqual(config, CONFIG_WEAPONS) ||
		StrEqual(config, CONFIG_COMMONAFFIXES) ||
		StrEqual(config, CONFIG_HANDICAP)) {// ||
		//StrEqual(config, CONFIG_CLASSNAMES)) {

		SetFailState("%s , %s", config, error);
	}
}

stock RegisterConsoleCommands() {
	char thetext[64];
	if (!b_IsFirstPluginLoad) {
		b_IsFirstPluginLoad = true;
		LoadMainConfig();
		if (hDatabase == INVALID_HANDLE) {
			MySQL_Init();
		}
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
		// GetConfigValue(thetext, sizeof(thetext), "give augment command?");
		// RegConsoleCmd(thetext, CMD_GiveInventoryItem);
		GetConfigValue(thetext, sizeof(thetext), "give level command?");
		RegConsoleCmd(thetext, CMD_GiveLevel);
		GetConfigValue(thetext, sizeof(thetext), "share points command?");
		RegConsoleCmd(thetext, CMD_SharePoints);
		GetConfigValue(thetext, sizeof(thetext), "buy menu command?");
		RegConsoleCmd(thetext, CMD_BuyMenu);
		GetConfigValue(thetext, sizeof(thetext), "abilitybar menu command?");
		RegConsoleCmd(thetext, CMD_ActionBar);
		//RegConsoleCmd("collect", CMD_CollectBonusExperience);
		GetConfigValue(thetext, sizeof(thetext), "load profile command?");
		RegConsoleCmd(thetext, CMD_LoadProfileEx);
		//RegConsoleCmd("backpack", CMD_Backpack);
		//etConfigValue(thetext, sizeof(thetext), "rpg data force save?");
		//RegConsoleCmd(thetext, CMD_SaveData);
	}
	ReadyUp_NtvGetHeader();
	GetConfigValue(thetext, sizeof(thetext), "item drop model?");
	PrecacheModel(thetext, true);
	GetConfigValue(thetext, sizeof(thetext), "backpack model?");
	PrecacheModel(thetext, true);
}

public ReadyUp_LoadFromConfigEx(Handle key, Handle value, Handle section, char[] configname, keyCount) {
	//PrintToChatAll("Size: %d config: %s", GetArraySize(Handle:key), configname);
	if (!StrEqual(configname, CONFIG_MAIN) &&
		!StrEqual(configname, CONFIG_EVENTS) &&
		!StrEqual(configname, CONFIG_SURVIVORTALENTS) &&
		!IsTalentConfig(configname) &&
		!StrEqual(configname, CONFIG_MAINMENU) &&
		!StrEqual(configname, CONFIG_POINTS) &&
		!StrEqual(configname, CONFIG_STORE) &&
		!StrEqual(configname, CONFIG_TRAILS) &&
		!StrEqual(configname, CONFIG_WEAPONS) &&
		!StrEqual(configname, CONFIG_COMMONAFFIXES) &&
		!StrEqual(configname, CONFIG_HANDICAP)) return;// &&
		//!StrEqual(configname, CONFIG_CLASSNAMES)) return;
	bool configIsForTalents = (IsTalentConfig(configname) || StrEqual(configname, CONFIG_SURVIVORTALENTS));
	char s_key[64];
	char s_value[64];
	char s_section[64];
	if (StrEqual(configname, CONFIG_MAIN)) {
		int a_Size						= GetArraySize(key);
		for (int i = 0; i < a_Size; i++) {
			GetArrayString(key, i, s_key, sizeof(s_key));
			GetArrayString(value, i, s_value, sizeof(s_value));
			PushArrayString(MainKeys, s_key);
			PushArrayString(MainValues, s_value);
			if (!StrEqual(s_key, "rpg mode?")) continue;
			CurrentRPGMode = StringToInt(s_value);
		}
		RegisterConsoleCommands();
		return;
	}
	if (configIsForTalents) TalentKeys		=					CreateArray(12);
	else					TalentKeys		=					CreateArray(16);
	if (configIsForTalents) TalentValues	=					CreateArray(9);
	else					TalentValues	=					CreateArray(16);
	TalentSections	=					CreateArray(10);
	int lastPosition = 0;
	int counter = 0;
	if (keyCount > 0) {
		if (configIsForTalents) ResizeArray(a_Menu_Talents, keyCount);
		else if (StrEqual(configname, CONFIG_MAINMENU)) ResizeArray(a_Menu_Main, keyCount);
		else if (StrEqual(configname, CONFIG_EVENTS)) ResizeArray(a_Events, keyCount);
		else if (StrEqual(configname, CONFIG_POINTS)) ResizeArray(a_Points, keyCount);
		else if (StrEqual(configname, CONFIG_STORE)) ResizeArray(a_Store, keyCount);
		else if (StrEqual(configname, CONFIG_TRAILS)) ResizeArray(a_Trails, keyCount);
		else if (StrEqual(configname, CONFIG_WEAPONS)) ResizeArray(a_WeaponDamages, keyCount);
		else if (StrEqual(configname, CONFIG_COMMONAFFIXES)) ResizeArray(a_CommonAffixes, keyCount);
		else if (StrEqual(configname, CONFIG_HANDICAP)) ResizeArray(a_HandicapLevels, keyCount);
		//else if (StrEqual(configname, CONFIG_CLASSNAMES)) ResizeArray(a_Classnames, keyCount);
	}
	int a_Size						= GetArraySize(key);
	int talentsLoaded = 0;
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(key, i, s_key, sizeof(s_key));
		GetArrayString(value, i, s_value, sizeof(s_value));
		if (!StrEqual(s_key, "EOM")) {
			PushArrayString(TalentKeys, s_key);
			PushArrayString(TalentValues, s_value);
			continue;
		}
		GetArrayString(section, i, s_section, sizeof(s_section));
		PushArrayString(TalentSections, s_section);

		if (configIsForTalents) SetConfigArrays(configname, a_Menu_Talents, TalentKeys, TalentValues, TalentSections, GetArraySize(a_Menu_Talents), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_MAINMENU)) SetConfigArrays(configname, a_Menu_Main, TalentKeys, TalentValues, TalentSections, GetArraySize(a_Menu_Main), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_EVENTS)) SetConfigArrays(configname, a_Events, TalentKeys, TalentValues, TalentSections, GetArraySize(a_Events), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_POINTS)) SetConfigArrays(configname, a_Points, TalentKeys, TalentValues, TalentSections, GetArraySize(a_Points), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_STORE)) SetConfigArrays(configname, a_Store, TalentKeys, TalentValues, TalentSections, GetArraySize(a_Store), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_TRAILS)) SetConfigArrays(configname, a_Trails, TalentKeys, TalentValues, TalentSections, GetArraySize(a_Trails), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_WEAPONS)) SetConfigArrays(configname, a_WeaponDamages, TalentKeys, TalentValues, TalentSections, GetArraySize(a_WeaponDamages), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_COMMONAFFIXES)) SetConfigArrays(configname, a_CommonAffixes, TalentKeys, TalentValues, TalentSections, GetArraySize(a_CommonAffixes), lastPosition - counter);
		else if (StrEqual(configname, CONFIG_HANDICAP)) SetConfigArrays(configname, a_HandicapLevels, TalentKeys, TalentValues, TalentSections, GetArraySize(a_HandicapLevels), lastPosition - counter);
		//else if (StrEqual(configname, CONFIG_CLASSNAMES)) SetConfigArrays(configname, a_Classnames, TalentKeys, TalentValues, tTalentSection, GetArraySize(a_Classnames), lastPosition - counter);
		
		lastPosition = i + 1;
		if (configIsForTalents) {
			talentsLoaded++;
		}
		ClearArray(TalentKeys);
		ClearArray(TalentValues);
		ClearArray(TalentSections);
	}

	//CloseHandle(TalentKeys);
	//CloseHandle(TalentValues);
	//CloseHandle(TalentSection);

	if (StrEqual(configname, CONFIG_POINTS)) {
		if (a_DirectorActions != INVALID_HANDLE) ClearArray(a_DirectorActions);
		a_DirectorActions			=	CreateArray(3);
		if (a_DirectorActions_Cooldown != INVALID_HANDLE) ClearArray(a_DirectorActions_Cooldown);
		a_DirectorActions_Cooldown	=	CreateArray(16);
		int size						=	GetArraySize(a_Points);
		Handle Keys					=	CreateArray(16);
		Handle Values				=	CreateArray(16);
		Handle Section				=	CreateArray(10);
		int sizer						=	0;
		for (int i = 0; i < size; i++) {
			Keys						=	GetArrayCell(a_Points, i, 0);
			Values						=	GetArrayCell(a_Points, i, 1);
			Section						=	GetArrayCell(a_Points, i, 2);
			int size2					=	GetArraySize(Keys);
			for (int ii = 0; ii < size2; ii++) {
				GetArrayString(Keys, ii, s_key, sizeof(s_key));
				GetArrayString(Values, ii, s_value, sizeof(s_value));
				if (StrEqual(s_key, "model?")) PushArrayString(ModelsToPrecache, s_value); //PrecacheModel(s_value, true);
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
	}
	if (StrEqual(configname, CONFIG_EVENTS)) SubmitEventHooks(1);
	ReadyUp_NtvGetHeader();
	/*

		We need to preload an array full of all the positions of item drops.
		Faster than searching every time.
	*/
	if (StrEqual(configname, CONFIG_COMMONAFFIXES) && GetArraySize(ModelsToPrecache) > 0) {
		CreateTimer(10.0, Timer_PrecacheReset, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_PrecacheReset(Handle timer) {
	char cur[64];
	GetCurrentMap(cur, 64);
	ServerCommand("changelevel %s", cur);
	return Plugin_Stop;
}

/*
	These specific variables can be called the same way, every time, so we declare them globally.
	These are all from the config.cfg (main config file)
	We don't load other variables in this way because they are dynamically loaded and unloaded.
*/
stock LoadMainConfig() {
	GetConfigValue(sServerDifficulty, sizeof(sServerDifficulty), "server difficulty?");
	CheckDifficulty();
	GetConfigValue(sDeleteBotFlags, sizeof(sDeleteBotFlags), "delete bot flags?");

	iClientTypeToDisplayOnKill			= GetConfigValueInt("infected kill messages to display?", 0);
	fProficiencyExperienceMultiplier 	= GetConfigValueFloat("proficiency requirement multiplier?");
	fProficiencyExperienceEarned 		= GetConfigValueFloat("experience multiplier proficiency?");
	fRatingPercentLostOnDeath			= GetConfigValueFloat("rating percentage lost on death?");
	//iProficiencyMaxLevel				= GetConfigValueInt("proficience level max?");
	iProficiencyStart					= GetConfigValueInt("proficiency level start?");
	iTeamRatingRequired					= GetConfigValueInt("team count rating bonus?");
	fTeamRatingBonus					= GetConfigValueFloat("team player rating bonus?");
	iTanksPreset						= GetConfigValueInt("preset tank type on spawn?");
	iSurvivorRespawnRestrict			= GetConfigValueInt("respawn queue players ignored?");
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
	fDirectorThoughtDelay				= GetConfigValueFloat("director thought process delay?", 1.0);
	fDirectorThoughtHandicap			= GetConfigValueFloat("director thought process handicap?", 0.0);
	fDirectorThoughtProcessMinimum		= GetConfigValueFloat("director thought process minimum?", 1.0);
	iSurvivalRoundTime					= GetConfigValueInt("survival round time?");
	fDazedDebuffEffect					= GetConfigValueFloat("dazed debuff effect?");
	ConsumptionInt						= GetConfigValueInt("stamina consumption interval?");
	fStamSprintInterval					= GetConfigValueFloat("stamina sprint interval?", 0.12);
	fStamJetpackInterval				= GetConfigValueFloat("stamina jetpack interval?", 0.05);
	fStamRegenTime						= GetConfigValueFloat("stamina regeneration time?");
	fStamRegenTimeAdren					= GetConfigValueFloat("stamina regeneration time adren?");
	fBaseMovementSpeed					= GetConfigValueFloat("base movement speed?");
	//fFatigueMovementSpeed				= GetConfigValueFloat("fatigue movement speed?");
	iPlayerStartingLevel				= GetConfigValueInt("new player starting level?");
	iBotPlayerStartingLevel				= GetConfigValueInt("new bot player starting level?");
	if (iMaxLevelBots < iBotPlayerStartingLevel) iMaxLevelBots = iBotPlayerStartingLevel;
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
	scoreRequiredForLeaderboard			= GetConfigValueInt("player score required for leaderboard?");
	char text[64];
	char text2[64];
	char text3[64];
	char text4[64];
	for (int i = 0; i < 7; i++) {
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
	iMaxLevelBots						= GetConfigValueInt("max level bots?", -1);
	iExperienceStart					= GetConfigValueInt("experience start?");
	fExperienceMultiplier				= GetConfigValueFloat("requirement multiplier?");
	fExperienceMultiplierHardcore		= GetConfigValueFloat("requirement multiplier hardcore?");
	GetConfigValue(sBotTeam, sizeof(sBotTeam), "survivor team?");
	iActionBarSlots						= GetConfigValueInt("action bar slots?");
	iNumAugments						= GetConfigValueInt("augment slots?", 3);
	GetConfigValue(MenuCommand, sizeof(MenuCommand), "rpg menu command?");
	ReplaceString(MenuCommand, sizeof(MenuCommand), ",", " or ", true);
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
	iWitchHealthBase					= GetConfigValueInt("base witch health?");
	fWitchHealthMult					= GetConfigValueFloat("level witch multiplier?");
	iCommonBaseHealth					= GetConfigValueInt("common base health?");
	fCommonLevelHealthMult				= GetConfigValueFloat("common level health?");
	GroupMemberBonus					= GetConfigValueFloat("steamgroup bonus?");
	RaidLevMult							= GetConfigValueInt("raid level multiplier?");
	iIgnoredRating						= GetConfigValueInt("rating to ignore?");
	iIgnoredRatingMax					= GetConfigValueInt("max rating to ignore?");
	iInfectedLimit						= GetConfigValueInt("ensnare infected limit?");
	TheScorchMult						= GetConfigValueFloat("scorch multiplier?");
	TheInfernoMult						= GetConfigValueFloat("inferno multiplier?");
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
	GetConfigValue(sItemModel, sizeof(sItemModel), "item drop model?");
	iEnrageAdvertisement				= GetConfigValueInt("enrage advertise time?");
	iNotifyEnrage						= GetConfigValueInt("enrage notification?");
	iJoinGroupAdvertisement				= GetConfigValueInt("join group advertise time?");
	GetConfigValue(sBackpackModel, sizeof(sBackpackModel), "backpack model?");
	GetConfigValue(sCategoriesToIgnore, sizeof(sCategoriesToIgnore), "talent categories to skip for loot?");
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
	//fEffectOverTimeInterval				= GetConfigValueFloat("effect over time tick rate?");
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
	//iDeleteCommonsFromExistenceOnDeath	= GetConfigValueInt("delete commons from existence on death?");
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
	//iDeleteSupersOnDeath				= GetConfigValueInt("delete super commons on death?", 1);
	//iShoveStaminaCost					= GetConfigValueInt("shove stamina cost?", 10);
	iLootEnabled						= GetConfigValueInt("loot system enabled?", 1);
	fLootChanceTank						= GetConfigValueFloat("loot chance tank?", 1.0);
	fLootChanceWitch					= GetConfigValueFloat("loot chance witch?", 0.5);
	fLootChanceSpecials					= GetConfigValueFloat("loot chance specials?", 0.1);
	fLootChanceSupers					= GetConfigValueFloat("loot chance supers?", 0.01);
	fLootChanceCommons					= GetConfigValueFloat("loot chance commons?", 0.001);
	fUpgradesRequiredPerLayer			= GetConfigValueFloat("layer upgrades required?", 0.3);
	iEnsnareRestrictions				= GetConfigValueInt("ensnare restrictions?", 1);
	fTeleportTankHeightDistance			= GetConfigValueFloat("teleport tank height distance?", 512.0);
	fSurvivorBufferBonus				= GetConfigValueFloat("common buffers survivors effect?", 2.0);
	iCommonInfectedSpawnDelayOnNewRound	= GetConfigValueInt("new round spawn common delay?", 30);
	iHideEnrageTimerUntilSecondsLeft	= GetConfigValueInt("hide enrage timer until seconds left?", iEnrageTime/3);
	showNumLivingSurvivorsInHostname	= GetConfigValueInt("show living survivors in hostname?", 0);
	iUpgradesRequiredForLoot			= GetConfigValueInt("assigned upgrades required for loot?", 5);
	iUseLinearLeveling					= GetConfigValueInt("experience requirements are linear?", 0);
	iUniqueServerCode					= GetConfigValueInt("unique server code?", 10);
	iAugmentLevelDivisor				= GetConfigValueInt("augment level divisor?", 1000);
	fAugmentRatingMultiplier			= GetConfigValueFloat("augment bonus category rating multiplier?", 0.00001);
	fAugmentActivatorRatingMultiplier	= GetConfigValueFloat("augment bonus activator rating multiplier?", 0.000005);
	fAugmentTargetRatingMultiplier		= GetConfigValueFloat("augment bonus target rating multiplier?", 0.000005);
	iRatingRequiredForAugmentLootDrops	= GetConfigValueInt("rating required for augment drops?", 30000);
	fAugmentTierChance					= GetConfigValueFloat("augment tier chance?", 0.75);
	fAntiFarmDistance					= GetConfigValueFloat("anti farm kill distance?");
	iAntiFarmMax						= GetConfigValueInt("anti farm kill max locations?");
	fLootBagExpirationTimeInSeconds		= GetConfigValueFloat("loot bags disappear after this many seconds?", 10.0);
	iExplosionBaseDamagePipe			= GetConfigValueInt("base pipebomb damage?", 500);
	iExplosionBaseDamage				= GetConfigValueInt("base explosion damage for non pipebomb sources?", 500);
	fProficiencyLevelDamageIncrease		= GetConfigValueFloat("weapon proficiency level bonus damage?", 0.01);
	iJetpackEnabled						= GetConfigValueInt("jetpack enabled?", 1);
	fJumpTimeToActivateJetpack			= GetConfigValueFloat("jump press time to activate jetpack?", 0.4);
	iNumLootDropChancesPerPlayer[0]		= GetConfigValueInt("roll attempts on common kill?", 1);
	iNumLootDropChancesPerPlayer[1]		= GetConfigValueInt("roll attempts on supers kill?", 1);
	iNumLootDropChancesPerPlayer[2]		= GetConfigValueInt("roll attempts on specials kill?", 1);
	iNumLootDropChancesPerPlayer[3]		= GetConfigValueInt("roll attempts on witch kill?", 1);
	iNumLootDropChancesPerPlayer[4]		= GetConfigValueInt("roll attempts on tank kill?", 1);
	iInventoryLimit						= GetConfigValueInt("max persistent loot inventory size?", 50);
	iLevelRequiredToEarnScore			= GetConfigValueInt("level required to earn score?", 10);
	fNoHandicapScoreMultiplier			= GetConfigValueFloat("base score multiplier (no handicap?)", 0.05);
	iMaximumTanksPerPlayer				= GetConfigValueInt("maximum tank spawns per player?", 2);
	iMaximumCommonsPerPlayer			= GetConfigValueInt("maximum common increase per player?", 30);
	iAugmentCategoryRerollCost			= GetConfigValueInt("augment category reroll cost?", 100);
	iAugmentActivatorRerollCost			= GetConfigValueInt("augment activator reroll cost?", 200);
	iAugmentTargetRerollCost			= GetConfigValueInt("augment target reroll cost?", 300);
	iMultiplierForAugmentLootDrops		= GetConfigValueInt("augment score tier multiplier?", 2);
	iAugmentsAffectCooldowns			= GetConfigValueInt("augment affects cooldowns?", 1);
	fIncapHealthStartPercentage			= GetConfigValueFloat("incap health start?", 0.5);
	iStuckDelayTime						= GetConfigValueInt("seconds between stuck command use?", 120);
	fTankingContribution				= GetConfigValueFloat("tanking contribution?", 1.0);
	fDamageContribution					= GetConfigValueFloat("damage contribution?", 0.2);
	fHealingContribution				= GetConfigValueFloat("healing contribution?", 0.15);
	fBuffingContribution				= GetConfigValueFloat("buffing contribution?", 0.3);
	iExperimentalMode					= GetConfigValueInt("invert walk and sprint?", 1);
	fAugmentLevelDifferenceForStolen	= GetConfigValueFloat("equip stolen augment average range?", 0.1);
	fUpdateClientInterval				= GetConfigValueFloat("update client data tickrate?", 0.5);
	fRewardPenaltyIfSurvivorBot			= GetConfigValueFloat("reward penalty if target is survivor bot?", 0.1);
	fFallenSurvivorDefibChance			= GetConfigValueFloat("fallen survivor defib drop chance base?", 0.01);
	fFallenSurvivorDefibChanceLuck		= GetConfigValueFloat("fallen survivor defib drop chance luck?", 0.01);
	iAugmentCategoryUpgradeCost			= GetConfigValueInt("augment category upgrade cost?", 50);
	iAugmentActivatorUpgradeCost		= GetConfigValueInt("augment activator upgrade cost?", 50);
	iAugmentTargetUpgradeCost			= GetConfigValueInt("augment target upgrade cost?", 50);
	fPainPillsHealAmount				= GetConfigValueFloat("on use pain killers heal?", 0.3);
	iNumAdvertisements					= GetConfigValueInt("number of advertisements?", 0);
	HostNameTime						= GetConfigValueInt("delay in seconds between advertisements?", 180);

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

public Action CMD_AutoDismantle(client, args) {
	int lootFindBonus = 0;
	if (handicapLevel[client] > 0) lootFindBonus = GetArrayCell(HandicapSelectedValues[client], 2);
	if (args < 1) {
		PrintToChat(client, "\x04!autodismantle <score>\n\x03augments that roll under %d score will be auto-dismantled. \x04limit: \x03%d", iplayerSettingAutoDismantleScore[client], BestRating[client] + lootFindBonus);
		PrintToChat(client, "\x04!autodismantle clear/perfect/major/minor - \x03Deletes \x04all/perfect/major/minor augments \x03not equipped or favourited.");
		return Plugin_Handled;
	}

	char arg[64];
	GetCmdArg(1, arg, 64);
	char key[64];
	char tquery[512];
	int size = 0;
	int refunded = 0;
	char effects[64];
	int isEquipped = 0;
	if (StrEqual(arg, "clear")) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		Format(tquery, sizeof(tquery), "DELETE FROM `%s_loot` WHERE `isequipped` = '-1' AND `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);

		size = GetArraySize(myAugmentInfo[client]);
		for (int i = size-1; i >= 0; i--) {
			isEquipped = GetArrayCell(myAugmentInfo[client], i, 3);
			if (isEquipped != -1) continue;

			RemoveFromArray(myAugmentIDCodes[client], i);
			RemoveFromArray(myAugmentCategories[client], i);
			RemoveFromArray(myAugmentOwners[client], i);
			RemoveFromArray(myAugmentOwnersName[client], i);
			RemoveFromArray(myAugmentInfo[client], i);
			RemoveFromArray(myAugmentTargetEffects[client], i);
			RemoveFromArray(myAugmentActivatorEffects[client], i);
			RemoveFromArray(myAugmentSavedProfiles[client], i);
			refunded++;
		}
		PrintToChat(client, "\x04Deleted \x03all \x04non-favourited, non-equipped augments.\n+\x03%d \x05scrap", refunded);
		augmentParts[client] += refunded;
	}
	else if (StrEqual(arg, "minor")) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		Format(tquery, sizeof(tquery), "DELETE FROM `%s_loot` WHERE `isequipped` = '-1' AND `acteffects` = '-1' AND `tareffects` = '-1' AND `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);

		size = GetArraySize(myAugmentInfo[client]);
		for (int i = size-1; i >= 0; i--) {
			isEquipped = GetArrayCell(myAugmentInfo[client], i, 3);
			if (isEquipped != -1) continue;
			GetArrayString(myAugmentTargetEffects[client], i, effects, sizeof(effects));
			if (!StrEqual(effects, "-1")) continue;
			GetArrayString(myAugmentActivatorEffects[client], i, effects, sizeof(effects));
			if (!StrEqual(effects, "-1")) continue;
			RemoveFromArray(myAugmentTargetEffects[client], i);
			RemoveFromArray(myAugmentActivatorEffects[client], i);
			RemoveFromArray(myAugmentIDCodes[client], i);
			RemoveFromArray(myAugmentCategories[client], i);
			RemoveFromArray(myAugmentOwners[client], i);
			RemoveFromArray(myAugmentOwnersName[client], i);
			RemoveFromArray(myAugmentInfo[client], i);
			RemoveFromArray(myAugmentSavedProfiles[client], i);
			refunded++;
		}
		PrintToChat(client, "\x04Deleted all \x03Minor \x04non-favourited, non-equipped augments.\n+\x03%d \x05scrap", refunded);
		augmentParts[client] += refunded;
	}
	else if (StrEqual(arg, "major")) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		Format(tquery, sizeof(tquery), "DELETE FROM `%s_loot` WHERE (`isequipped` = '-1' AND `acteffects` = '-1' AND `tareffects` != '-1' AND `steam_id` = '%s') OR (`isequipped` = '-1' AND `acteffects` != '-1' AND `tareffects` = '-1' AND `steam_id` = '%s');", TheDBPrefix, key, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);
		char othereffects[64];
		size = GetArraySize(myAugmentInfo[client]);
		for (int i = size-1; i >= 0; i--) {
			isEquipped = GetArrayCell(myAugmentInfo[client], i, 3);
			if (isEquipped != -1) continue;
			GetArrayString(myAugmentTargetEffects[client], i, effects, sizeof(effects));
			GetArrayString(myAugmentActivatorEffects[client], i, othereffects, sizeof(othereffects));
			if (!StrEqual(effects, "-1") && !StrEqual(othereffects, "-1") ||
				StrEqual(effects, "-1") && StrEqual(othereffects, "-1")) continue;
			RemoveFromArray(myAugmentTargetEffects[client], i);
			RemoveFromArray(myAugmentActivatorEffects[client], i);
			RemoveFromArray(myAugmentIDCodes[client], i);
			RemoveFromArray(myAugmentCategories[client], i);
			RemoveFromArray(myAugmentOwners[client], i);
			RemoveFromArray(myAugmentOwnersName[client], i);
			RemoveFromArray(myAugmentInfo[client], i);
			RemoveFromArray(myAugmentSavedProfiles[client], i);
			refunded++;
		}
		PrintToChat(client, "\x04Deleted all \x03Major \x04non-favourited, non-equipped augments.\n+\x03%d \x05scrap", refunded);
		augmentParts[client] += refunded;
	}
	else if (StrEqual(arg, "perfect")) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		Format(tquery, sizeof(tquery), "DELETE FROM `%s_loot` WHERE `isequipped` = '-1' AND `acteffects` != '-1' AND `tareffects` != '-1' AND `steam_id` = '%s';", TheDBPrefix, key, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);
		char othereffects[64];
		size = GetArraySize(myAugmentInfo[client]);
		for (int i = size-1; i >= 0; i--) {
			isEquipped = GetArrayCell(myAugmentInfo[client], i, 3);
			if (isEquipped != -1) continue;
			GetArrayString(myAugmentTargetEffects[client], i, effects, sizeof(effects));
			GetArrayString(myAugmentActivatorEffects[client], i, othereffects, sizeof(othereffects));
			if (StrEqual(effects, "-1") || StrEqual(othereffects, "-1")) continue;
			RemoveFromArray(myAugmentTargetEffects[client], i);
			RemoveFromArray(myAugmentActivatorEffects[client], i);
			RemoveFromArray(myAugmentIDCodes[client], i);
			RemoveFromArray(myAugmentCategories[client], i);
			RemoveFromArray(myAugmentOwners[client], i);
			RemoveFromArray(myAugmentOwnersName[client], i);
			RemoveFromArray(myAugmentInfo[client], i);
			RemoveFromArray(myAugmentSavedProfiles[client], i);
			refunded++;
		}
		PrintToChat(client, "\x04Deleted all \x03Perfect \x04non-favourited, non-equipped augments.\n+\x03%d \x05scrap", refunded);
		augmentParts[client] += refunded;
	}
	else {
		int auto = StringToInt(arg);
		if (auto > 0 && auto <= BestRating[client] + lootFindBonus) {
			iplayerSettingAutoDismantleScore[client] = auto;
			PrintToChat(client, "\x04I will auto dismantle any augments of \x03%d \x04score or lower.", iplayerSettingAutoDismantleScore[client]);
		}
		return Plugin_Handled;
	}// if any dismantling occurs, we forcefully open the menu so they can't do anything in the inventory.
	BuildMenu(client);
	return Plugin_Handled;
}

public Action CMD_RollLoot(client, args) {
	//GenerateAndGivePlayerAugment(client);
	return Plugin_Handled;
}

stock RollLoot(client, enemyClient) {
	if (iLootEnabled == 0 || IsFakeClient(client) || Rating[client] < iRatingRequiredForAugmentLootDrops) return;
	
	int lootPoolSize = GetArraySize(possibleLootPool[client]);
	if (lootPoolSize < iUpgradesRequiredForLoot) return;
	
	int zombieclass = FindZombieClass(enemyClient);
	float fLootChance = (zombieclass == 10) ? fLootChanceCommons :					// common
						(zombieclass == 9) ? fLootChanceSupers :					// super
						(zombieclass == 7) ? fLootChanceWitch :						// witch
						(zombieclass == 8) ? fLootChanceTank :						// tank
						(zombieclass > 0) ? fLootChanceSpecials : 0.0;				// special infected
	if (fLootChance == 0.0) return;
	
	// in borderlands you have a low chance of getting loot, so they throw a ton of roll attempts at you.
	// sometimes you get an overwhelming amount, sometimes you get one item, sometimes you get nothing.
	int numOfRollsToAttempt = (zombieclass == 10) ? iNumLootDropChancesPerPlayer[0] :
							(zombieclass == 9) ? iNumLootDropChancesPerPlayer[1] :
							(zombieclass == 7) ? iNumLootDropChancesPerPlayer[3] :
							(zombieclass == 8) ? iNumLootDropChancesPerPlayer[4] : iNumLootDropChancesPerPlayer[2];
	int numOfAugmentPartsToReturn = 0;
	for (int i = numOfRollsToAttempt; i > 0; i--) {
		int roll = GetRandomInt(1, RoundToCeil(1.0 / fLootChance));
		if (roll != 1) continue;
		
		int result = GenerateAugment(client, enemyClient);
		if (result == -2) numOfAugmentPartsToReturn++;
	}
	if (numOfAugmentPartsToReturn > 0) {
		augmentParts[client] += numOfAugmentPartsToReturn;
		if (numOfAugmentPartsToReturn > 1) {
			char text[64];
			Format(text, 64, "{G}+%d {O}scrap", numOfAugmentPartsToReturn);
			Client_PrintToChat(client, true, text);
		}
	}
}

stock void PickupAugment(int client, int owner, char[] ownerSteamID = "none", char[] ownerName = "none", int pos) {
	int size = GetArraySize(myAugmentIDCodes[client]);
	ResizeArray(myAugmentIDCodes[client], size+1);
	ResizeArray(myAugmentCategories[client], size+1);
	ResizeArray(myAugmentOwners[client], size+1);
	ResizeArray(myAugmentOwnersName[client], size+1);
	ResizeArray(myAugmentInfo[client], size+1);
	ResizeArray(myAugmentActivatorEffects[client], size+1);
	ResizeArray(myAugmentTargetEffects[client], size+1);
	ResizeArray(myAugmentSavedProfiles[client], size+1);
	char nosaved[64];
	Format(nosaved, sizeof(nosaved), "none");
	SetArrayString(myAugmentSavedProfiles[client], size, nosaved);

	// [0] - category score roll
	// [1] - category position
	// [2] - activator score roll
	// [3] - activator position
	// [4] - target score roll
	// [5] = target position
	// [6] = handicap score bonus (used for upgrading later)
	//int pos = GetArraySize(playerLootOnGround[owner])-1;
	char sItemCode[64];
	GetArrayString(playerLootOnGroundId[owner], pos, sItemCode, sizeof(sItemCode));
	SetArrayString(myAugmentIDCodes[client], size, sItemCode);

	char buffedCategory[64];
	GetArrayString(myLootDropCategoriesAllowed[owner], GetArrayCell(playerLootOnGround[owner], pos, 1), buffedCategory, 64);

	char menuText[64];
	int len = GetAugmentTranslation(client, buffedCategory, menuText);
	Format(menuText, 64, "%T", menuText, client);

	SetArrayString(myAugmentCategories[client], size, buffedCategory);

	int augmentItemScore = GetArrayCell(playerLootOnGround[owner], pos);
	char key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	SetArrayString(myAugmentOwners[client], size, ownerSteamID);
	SetArrayString(myAugmentOwnersName[client], size, ownerName);
	SetArrayCell(myAugmentInfo[client], size, augmentItemScore);	// item rating (cell 4 is activatorRating and cell5 is targetRating)
	SetArrayCell(myAugmentInfo[client], size, 0, 1);			// item cost
	SetArrayCell(myAugmentInfo[client], size, 0, 2);			// is item for sale
	SetArrayCell(myAugmentInfo[client], size, -1, 3);			// which augment slot the item is equipped in - -1 for no slot.


	int augmentActivatorRating = -1;
	int augmentTargetRating = -1;
	char activatorEffects[64];
	char targetEffects[64];

	int maxpossibleroll = GetArrayCell(playerLootOnGround[owner], pos, 6);
	SetArrayCell(myAugmentInfo[client], size, maxpossibleroll, 6);

	int maxPossibleActivatorScore = 0;
	int maxPossibleTargetScore = 0;

	int apos = GetArrayCell(playerLootOnGround[owner], pos, 3);
	if (apos >= 0) {
		GetArrayString(myLootDropActivatorEffectsAllowed[owner], apos, activatorEffects, 64);
		SetArrayString(myAugmentActivatorEffects[client], size, activatorEffects);
		augmentActivatorRating = GetArrayCell(playerLootOnGround[owner], pos, 2);
		maxPossibleActivatorScore = GetArrayCell(playerLootOnGround[owner], pos, 7);
		SetArrayCell(myAugmentInfo[client], size, maxPossibleActivatorScore, 7);
	}
	else {
		augmentActivatorRating = -1;
		Format(activatorEffects, 64, "-1");
		SetArrayString(myAugmentActivatorEffects[client], size, "-1");
		SetArrayCell(myAugmentInfo[client], size, -1, 7);
	}
	SetArrayCell(myAugmentInfo[client], size, augmentActivatorRating, 4);

	int tpos = GetArrayCell(playerLootOnGround[owner], pos, 5);
	if (tpos >= 0) {
		GetArrayString(myLootDropTargetEffectsAllowed[owner], tpos, targetEffects, 64);
		SetArrayString(myAugmentTargetEffects[client], size, targetEffects);
		augmentTargetRating = GetArrayCell(playerLootOnGround[owner], pos, 4);
		maxPossibleTargetScore = GetArrayCell(playerLootOnGround[owner], pos, 8);
		SetArrayCell(myAugmentInfo[client], size, maxPossibleTargetScore, 8);
	}
	else {
		augmentTargetRating = -1;
		Format(targetEffects, 64, "-1");
		SetArrayString(myAugmentTargetEffects[client], size, "-1");
		SetArrayCell(myAugmentInfo[client], size, -1, 8);
	}
	SetArrayCell(myAugmentInfo[client], size, augmentTargetRating, 5);
	char augmentStrengthText[64];
	if (augmentActivatorRating == -1 && augmentTargetRating == -1) {
		Format(augmentStrengthText, 64, "{B}Minor");
	}
	else {
		char majorname[64];
		char perfectname[64];
		GetAugmentSurname(client, size, majorname, sizeof(majorname), perfectname, sizeof(perfectname), false);
		if (!StrEqual(majorname, "-1")) Format(majorname, sizeof(majorname), "%t", majorname);
		if (!StrEqual(perfectname, "-1")) Format(perfectname, sizeof(perfectname), "%t", perfectname);
		if (!StrEqual(majorname, "-1") && !StrEqual(perfectname, "-1")) Format(augmentStrengthText, 64, "{B}Perfect {O}%s %s", majorname, perfectname);
		else if (!StrEqual(majorname, "-1")) Format(augmentStrengthText, 64, "{B}Major {O}%s", majorname);
		else Format(augmentStrengthText, 64, "{B}Major {O}%s", perfectname);
	}
	char name[64];
	GetClientName(client, name, sizeof(name));
	char text[512];
	Format(text, sizeof(text), "{B}%s {N}{OBTAINTYPE} a {B}+{OG}%3.1f{O}PCT %s {OG}%s {O}%s {B}augment", name, (augmentItemScore * fAugmentRatingMultiplier) * 100.0, augmentStrengthText, menuText, buffedCategory[len]);
	if (StrContains(ownerSteamID, key, false) != -1) ReplaceString(text, sizeof(text), "{OBTAINTYPE}", "found", true);
	else {
		ReplaceString(text, sizeof(text), "{OBTAINTYPE}", "stole", true);
		Format(text, sizeof(text), "%s {N}from {O}%s", text, ownerName);
	}
	ReplaceString(text, sizeof(text), "PCT", "%%", true);
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
		Client_PrintToChat(i, true, text);
	}
	if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	char tquery[512];
	Format(tquery, sizeof(tquery), "INSERT INTO `%s_loot` (`firstownername`, `firstowner`, `steam_id`, `itemid`, `rating`, `category`, `price`, `isforsale`, `isequipped`, `acteffects`, `actrating`, `tareffects`, `tarrating`, `maxscoreroll`, `maxactroll`, `maxtarroll`) VALUES ('%s', '%s', '%s', '%s', '%d', '%s', '%d', '%d', '%d', '%s', '%d', '%s', '%d', '%d', '%d', '%d');", TheDBPrefix, ownerName, ownerSteamID, key, sItemCode, augmentItemScore, buffedCategory, 0, 0, -1, activatorEffects, augmentActivatorRating, targetEffects, augmentTargetRating, maxpossibleroll, maxPossibleActivatorScore, maxPossibleTargetScore);
	SQL_TQuery(hDatabase, QueryResults, tquery);
}

stock int GenerateAugment(int client, int spawnTarget) {
	if (IsFakeClient(client)) return 0;
	int min = Rating[client];
	int max = (min + iRatingRequiredForAugmentLootDrops > BestRating[client]) ? min + iRatingRequiredForAugmentLootDrops : BestRating[client];
	int lootFindBonus = 0;
	if (handicapLevel[client] > 0) {
		lootFindBonus = GetArrayCell(HandicapSelectedValues[client], 2);
	}
	int potentialItemRating = GetRandomInt(min, max+lootFindBonus);
	if (potentialItemRating < iplayerSettingAutoDismantleScore[client]) {
		// we give the player augment parts instead because they don't want this item.
		return -2;
	}
	int lootPool = GetArraySize(myLootDropCategoriesAllowed[client]);
	if (lootPool < 1) return 0;
	int thisAugmentRatingRequiredForNextTier = iRatingRequiredForAugmentLootDrops;
	int count = 0;
	int scoreReserve[2];
	while (potentialItemRating >= thisAugmentRatingRequiredForNextTier && count < 3) {
		count++;
		if (count == 3) break;
		thisAugmentRatingRequiredForNextTier = (count * iMultiplierForAugmentLootDrops) * iRatingRequiredForAugmentLootDrops;
		scoreReserve[count-1] = thisAugmentRatingRequiredForNextTier;
	}
	count--;
	int lootsize = 0;
	int lootrolls[3];
	int subScores[3];
	thisAugmentRatingRequiredForNextTier = (count < 1) ? iRatingRequiredForAugmentLootDrops : (count * iMultiplierForAugmentLootDrops) * iRatingRequiredForAugmentLootDrops;
	while (potentialItemRating >= thisAugmentRatingRequiredForNextTier) {
		count--;
		int reserve = (count > 0) ? scoreReserve[count-1] : 0;
		int subMax = (thisAugmentRatingRequiredForNextTier < potentialItemRating - reserve) ? potentialItemRating : potentialItemRating - reserve;
		int roll = GetRandomInt(thisAugmentRatingRequiredForNextTier, subMax);
		potentialItemRating -= roll;
		lootrolls[lootsize] = roll;
		subScores[lootsize] = subMax;	// max score that can ever roll on this augment for this category.
		thisAugmentRatingRequiredForNextTier = (count < 1) ? iRatingRequiredForAugmentLootDrops : (count * iMultiplierForAugmentLootDrops) * iRatingRequiredForAugmentLootDrops;
		if (lootsize < 2 && potentialItemRating >= thisAugmentRatingRequiredForNextTier) lootsize++;
		else break;
	}
	// [0] - category score roll
	// [1] - category position
	// [2] - activator score roll
	// [3] - activator position
	// [4] - target score roll
	// [5] - target position
	// [6] - max category score roll
	// [7] - max activator score roll
	// [8] - max target score roll
	int size = GetArraySize(playerLootOnGround[client]);
	ResizeArray(playerLootOnGround[client], size+1);
	ResizeArray(playerLootOnGroundId[client], size+1);
	SetArrayCell(playerLootOnGround[client], size, lootrolls[0]);
	
	// for the crafting update, tracking the max possible roll for this augment, so when a player decides to roll for upgrades
	// they can't exceed what this items max roll originally would be.
	// this means this system can be used to upgrade existing gear if nothing good is dropping, but doesn't eliminate the necessity
	// of finding new loot at higher scores and handicaps.
	SetArrayCell(playerLootOnGround[client], size, max+lootFindBonus, 6);
	SetArrayCell(playerLootOnGround[client], size, -1, 7);
	SetArrayCell(playerLootOnGround[client], size, -1, 8);

	char sItemCode[64];
	FormatTime(sItemCode, 64, "%y%m%d%H%M%S", GetTime());
	lootDropCounter++;
	Format(sItemCode, 64, "%d%s%d", iUniqueServerCode, sItemCode, lootDropCounter);
	SetArrayString(playerLootOnGroundId[client], size, sItemCode);

	int pos = GetRandomInt(0, lootPool-1);
	SetArrayCell(playerLootOnGround[client], size, pos, 1);

	int possibilities = RoundToCeil(1.0 / fAugmentTierChance);
	int type = GetRandomInt(1, possibilities);
	char activatorEffects[64];
	char targetEffects[64];

	pos = GetRandomInt(0, GetArraySize(possibleLootPoolActivator[client])-1);
	if (type == 1 && lootsize > 0 && pos < GetArraySize(myLootDropActivatorEffectsAllowed[client])) {
		GetArrayString(myLootDropActivatorEffectsAllowed[client], pos, activatorEffects, 64);
		SetArrayCell(playerLootOnGround[client], size, lootrolls[1], 2);
		SetArrayCell(playerLootOnGround[client], size, pos, 3);
		SetArrayCell(playerLootOnGround[client], size, subScores[1], 7);
	}
	else {
		SetArrayCell(playerLootOnGround[client], size, -1, 2);
		SetArrayCell(playerLootOnGround[client], size, -1, 3);
	}
	type = GetRandomInt(1, possibilities);
	pos = GetRandomInt(0, GetArraySize(possibleLootPoolTarget[client])-1);
	if (type == 1 && lootsize > 1 && pos < GetArraySize(myLootDropTargetEffectsAllowed[client])) {
		GetArrayString(myLootDropTargetEffectsAllowed[client], pos, targetEffects, 64);
		SetArrayCell(playerLootOnGround[client], size, lootrolls[2], 4);
		SetArrayCell(playerLootOnGround[client], size, pos, 5);
		SetArrayCell(playerLootOnGround[client], size, subScores[2], 8);
	}
	else {
		SetArrayCell(playerLootOnGround[client], size, -1, 4);
		SetArrayCell(playerLootOnGround[client], size, -1, 5);
	}
	SetArrayCell(playerLootOnGround[client], size, size, 9);
	CreateItemDrop(client, spawnTarget, size);
	return 1;
}

stock void GetUniqueAugmentLootDropItemCode(char[] sTime) {
	FormatTime(sTime, 64, "%y%m%d%H%M%S", GetTime());
	lootDropCounter++;
	Format(sTime, 64, "%d%s%d", iUniqueServerCode, sTime, lootDropCounter);
}

stock bool ArrayContains(Handle array, char[] val) {
	int size = GetArraySize(array);
	for (int i = 0; i < size; i++) {
		char text[64];
		GetArrayString(array, i, text, 64);
		if (StrEqual(val, text)) return true;
	}
	return false;
}

stock void SetLootDropCategories(client) {
	ClearArray(possibleLootPool[client]);
	ClearArray(possibleLootPoolActivator[client]);
	ClearArray(possibleLootPoolTarget[client]);
	ClearArray(myLootDropCategoriesAllowed[client]);
	ClearArray(myLootDropTargetEffectsAllowed[client]);
	ClearArray(myLootDropActivatorEffectsAllowed[client]);
	ClearArray(myUnlockedCategories[client]);
	ClearArray(myUnlockedActivators[client]);
	ClearArray(myUnlockedTargets[client]);
	int size = GetArraySize(a_Menu_Talents);
	if (GetArraySize(MyTalentStrength[client]) != size) ResizeArray(MyTalentStrength[client], size);
	int explodeCount = GetDelimiterCount(sCategoriesToIgnore, ",") + 1;
	char[][] categoriesToSkip = new char[explodeCount][64];
	ExplodeString(sCategoriesToIgnore, ",", categoriesToSkip, explodeCount, 64);
	char talentName[64];
	for (int i = 0; i < size; i++) {
		if (GetArrayCell(MyTalentStrength[client], i) < 1) continue;
		LootDropCategoryToBuffValues[client]			= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(LootDropCategoryToBuffValues[client], PART_OF_MENU_NAMED, talentName, sizeof(talentName));
		bool bSkipThisTalent = false;
		for (int ii = 0; ii < explodeCount; ii++) {
			if (StrContains(talentName, categoriesToSkip[ii]) == -1) continue;
			bSkipThisTalent = true;
			break;
		}
		if (bSkipThisTalent) continue;
		PushArrayCell(possibleLootPool[client], i);
		GetArrayString(LootDropCategoryToBuffValues[client], TALENT_TREE_CATEGORY, talentName, sizeof(talentName));
		PushArrayString(myLootDropCategoriesAllowed[client], talentName);
		if (!ArrayContains(myUnlockedCategories[client], talentName)) PushArrayString(myUnlockedCategories[client], talentName);
		//if (GetArrayCell(LootDropCategoryToBuffValues[client], SKIP_TALENT_FOR_AUGMENT_ROLL) != 1) {
		GetArrayString(LootDropCategoryToBuffValues[client], ACTIVATOR_ABILITY_EFFECTS, talentName, sizeof(talentName));
		if (!StrEqual(talentName, "-1") && !StrEqual(talentName, "0")) {
			PushArrayString(myLootDropActivatorEffectsAllowed[client], talentName);
			if (!ArrayContains(myUnlockedActivators[client], talentName)) PushArrayString(myUnlockedActivators[client], talentName);
			PushArrayCell(possibleLootPoolActivator[client], i);
		}
		//}

		GetArrayString(LootDropCategoryToBuffValues[client], TARGET_ABILITY_EFFECTS, talentName, sizeof(talentName));
		if (!StrEqual(talentName, "-1") && !StrEqual(talentName, "0")) {
			PushArrayString(myLootDropTargetEffectsAllowed[client], talentName);
			if (!ArrayContains(myUnlockedTargets[client], talentName)) PushArrayString(myUnlockedTargets[client], talentName);
			PushArrayCell(possibleLootPoolTarget[client], i);
		}
	}
}

//public Action:CMD_Backpack(client, args) { EquipBackpack(client); return Plugin_Handled; }
public Action CMD_BuyMenu(client, args) {
	if (iRPGMode < 0 || iRPGMode == 1 && b_IsActiveRound) return Plugin_Handled;
	BuildPointsMenu(client, "Buy Menu", "rpg/points.cfg");
	return Plugin_Handled;
}

public Action CMD_DataErase(client, args) {
	char arg[MAX_NAME_LENGTH];
	if (args > 0 && HasCommandAccess(client, sDeleteBotFlags)) {
		GetCmdArg(1, arg, sizeof(arg));
		int targetclient = FindTargetClient(client, arg);
		if (IsLegitimateClient(targetclient) && myCurrentTeam[targetclient] != TEAM_INFECTED) DeleteAndCreateNewData(targetclient);
	}
	else DeleteAndCreateNewData(client);
	return Plugin_Handled;
}

public Action CMD_DataEraseBot(client, args) {
	DeleteAndCreateNewData(client, true);
	return Plugin_Handled;
}

stock DeleteAndCreateNewData(client, bool IsBot = false) {
	char key[64];
	char tquery[1024];
	char pct[4];
	Format(pct, sizeof(pct), "%");
	if (!IsBot) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);

		Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);

		Format(tquery, sizeof(tquery), "DELETE FROM `%s_loot` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);

		ResetData(client);
		CreateNewPlayerEx(client);

		PrintToChat(client, "data erased, new data created.");	// not bothering with a translation here, since it's a debugging command.
	}
	else {
		if (HasCommandAccess(client, sDeleteBotFlags)) {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsLegitimateClient(i) && IsFakeClient(i)) KickClient(i);
			}
			Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE '%s%s%s';", TheDBPrefix, pct, sBotTeam, pct);
			SQL_TQuery(hDatabase, QueryResults, tquery, client);

			PrintToChatAll("%t", "bot data deleted", orange, blue);
		}
	}
}

public Action CMD_DirectorTalentToggle(client, args) {
	char thetext[64];
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

stock SetConfigArrays(char[] Config, Handle Main, Handle Keys, Handle Values, Handle Section, size, last, bool setConfigArraysDebugger = false) {
	bool configIsForTalents = (IsTalentConfig(Config) || StrEqual(Config, CONFIG_SURVIVORTALENTS));

	char text[64];
	if (configIsForTalents) TalentKey		=					CreateArray(12);
	else					TalentKey		=					CreateArray(16);
	if (configIsForTalents) TalentValue		=					CreateArray(9);
	else					TalentValue		=					CreateArray(16);
	TalentSection = CreateArray(16);
	if (configIsForTalents) TalentTriggers	= CreateArray(8);

	char key[64];
	char value[64];
	int a_Size = GetArraySize(Keys);
	//setConfigArraysDebugger = true;
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(Keys, i, key, sizeof(key));
		GetArrayString(Values, i, value, sizeof(value));
		PushArrayString(TalentKey, key);
		PushArrayString(TalentValue, value);
	}
	int pos = 0;
	int sortSize = 0;
	// Sort the keys/values for TALENTS ONLY /w.
	if (configIsForTalents) {
		if (FindStringInArray(TalentKey, "weapon name required?") == -1) {
			PushArrayString(TalentKey, "weapon name required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "time since last activator attack?") == -1) {
			PushArrayString(TalentKey, "time since last activator attack?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "target must be in ammo?") == -1) {
			PushArrayString(TalentKey, "target must be in ammo?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator must be in ammo?") == -1) {
			PushArrayString(TalentKey, "activator must be in ammo?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target status effect required?") == -1) {
			PushArrayString(TalentKey, "target status effect required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "ability category?") == -1) {
			PushArrayString(TalentKey, "ability category?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "talent cooldown minimum value?") == -1) {
			PushArrayString(TalentKey, "talent cooldown minimum value?");
			PushArrayString(TalentValue, "0.0");
		}
		if (FindStringInArray(TalentKey, "require ally on fire?") == -1) {
			PushArrayString(TalentKey, "require ally on fire?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "enemy in coherency is target?") == -1) {
			PushArrayString(TalentKey, "enemy in coherency is target?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require enemy in coherency range?") == -1) {
			PushArrayString(TalentKey, "require enemy in coherency range?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target must be ally ensnarer?") == -1) {
			PushArrayString(TalentKey, "target must be ally ensnarer?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require ensnared ally?") == -1) {
			PushArrayString(TalentKey, "require ensnared ally?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require ally below health percentage?") == -1) {
			PushArrayString(TalentKey, "require ally below health percentage?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "require ally with adrenaline?") == -1) {
			PushArrayString(TalentKey, "require ally with adrenaline?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "skip talent for augment roll?") == -1) {
			PushArrayString(TalentKey, "skip talent for augment roll?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "must be unhurt by si or witch?") == -1) {
			PushArrayString(TalentKey, "must be unhurt by si or witch?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "must be within coherency of talent?") == -1) {
			PushArrayString(TalentKey, "must be within coherency of talent?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "target ability trigger to call?") == -1) {
			PushArrayString(TalentKey, "target ability trigger to call?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "no augment modifiers?") == -1) {
			PushArrayString(TalentKey, "no augment modifiers?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "multiply strength ensnared allies?") == -1) {
			PushArrayString(TalentKey, "multiply strength ensnared allies?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "multiply strength downed allies?") == -1) {
			PushArrayString(TalentKey, "multiply strength downed allies?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "health cost on activation?") == -1) {
			PushArrayString(TalentKey, "health cost on activation?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "health percentage remaining required?") == -1) {
			PushArrayString(TalentKey, "health percentage remaining required?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "activator status effect required?") == -1) {
			PushArrayString(TalentKey, "activator status effect required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active effect allows all classes?") == -1) {
			PushArrayString(TalentKey, "active effect allows all classes?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active effect allows all hitgroups?") == -1) {
			PushArrayString(TalentKey, "active effect allows all hitgroups?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "active effect allows all weapons?") == -1) {
			PushArrayString(TalentKey, "active effect allows all weapons?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "mult str div same headshots?") == -1) {
			PushArrayString(TalentKey, "mult str div same headshots?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "mult str max same headshots?") == -1) {
			PushArrayString(TalentKey, "mult str max same headshots?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "mult str by same headshots?") == -1) {
			PushArrayString(TalentKey, "mult str by same headshots?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "require consecutive headshots?") == -1) {
			PushArrayString(TalentKey, "require consecutive headshots?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "weapon slot required?") == -1) {
			PushArrayString(TalentKey, "weapon slot required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "activator ability trigger to call?") == -1) {
			PushArrayString(TalentKey, "activator ability trigger to call?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "hide talent strength display?") == -1) {
			PushArrayString(TalentKey, "hide talent strength display?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "give player this item on trigger?") == -1) {
			PushArrayString(TalentKey, "give player this item on trigger?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "contribution cost required?") == -1) {
			PushArrayString(TalentKey, "contribution cost required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "contribution category required?") == -1) {
			PushArrayString(TalentKey, "contribution category required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "mult str div same hits?") == -1) {
			PushArrayString(TalentKey, "mult str div same hits?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "mult str max same hits?") == -1) {
			PushArrayString(TalentKey, "mult str max same hits?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "mult str by same hits?") == -1) {
			PushArrayString(TalentKey, "mult str by same hits?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "last hit must be headshot?") == -1) {
			PushArrayString(TalentKey, "last hit must be headshot?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "event type?") == -1) {
			PushArrayString(TalentKey, "event type?");
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
		if (FindStringInArray(TalentKey, "toggle effect?") == -1) {
			PushArrayString(TalentKey, "toggle effect?");
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
		if (FindStringInArray(TalentKey, "talent active time strength value?") == -1) {
			PushArrayString(TalentKey, "talent active time strength value?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "talent cooldown strength value?") == -1) {
			PushArrayString(TalentKey, "talent cooldown strength value?");
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
			if (StrEqual(text, "ability trigger?")) {
				GetArrayString(TalentValue, pos, text, sizeof(text));
				int triggerSize = GetArraySize(TalentTriggers);
				ResizeArray(TalentTriggers, triggerSize+1);
				SetArrayString(TalentTriggers, triggerSize, text);
				RemoveFromArray(TalentKey, pos);
				RemoveFromArray(TalentValue, pos);
				continue;
			}
			else if (
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
			pos == 13 && !StrEqual(text, "activator class required?") ||
			pos == 14 && !StrEqual(text, "requires zoom?") ||
			pos == 15 && !StrEqual(text, "combat state required?") ||
			pos == 16 && !StrEqual(text, "player state required?") ||
			pos == 17 && !StrEqual(text, "passive ability?") ||
			pos == 18 && !StrEqual(text, "requires headshot?") ||
			pos == 19 && !StrEqual(text, "requires limbshot?") ||
			pos == 20 && !StrEqual(text, "activator stagger required?") ||
			pos == 21 && !StrEqual(text, "target stagger required?") ||
			pos == 22 && !StrEqual(text, "cannot target self?") ||
			pos == 23 && !StrEqual(text, "require adrenaline effect?") ||
			pos == 24 && !StrEqual(text, "disabled if weakness?") ||
			pos == 25 && !StrEqual(text, "require weakness?") ||
			pos == 26 && !StrEqual(text, "target class required?") ||
			pos == 27 && !StrEqual(text, "require consecutive hits?") ||
			pos == 28 && !StrEqual(text, "background talent?") ||
			pos == 29 && !StrEqual(text, "status effect multiplier?") ||
			pos == 30 && !StrEqual(text, "multiply range?") ||
			pos == 31 && !StrEqual(text, "multiply commons?") ||
			pos == 32 && !StrEqual(text, "multiply supers?") ||
			pos == 33 && !StrEqual(text, "multiply witches?") ||
			pos == 34 && !StrEqual(text, "multiply survivors?") ||
			pos == 35 && !StrEqual(text, "multiply specials?") ||
			pos == 36 && !StrEqual(text, "strength increase while zoomed?") ||
			pos == 37 && !StrEqual(text, "strength increase time cap?") ||
			pos == 38 && !StrEqual(text, "strength increase time required?") ||
			pos == 39 && !StrEqual(text, "no effect if zoom time is not met?") ||
			pos == 40 && !StrEqual(text, "strength increase while holding fire?") ||
			pos == 41 && !StrEqual(text, "no effect if damage time is not met?") ||
			pos == 42 && !StrEqual(text, "health percentage required missing?") ||
			pos == 43 && !StrEqual(text, "health percentage required missing max?") ||
			pos == 44 && !StrEqual(text, "secondary ability trigger?") ||
			pos == 45 && !StrEqual(text, "target is self?") ||
			pos == 46 && !StrEqual(text, "primary aoe?") ||
			pos == 47 && !StrEqual(text, "secondary aoe?") ||
			pos == 48 && !StrEqual(text, "talent name?") ||
			pos == 49 && !StrEqual(text, "translation?") ||
			pos == 50 && !StrEqual(text, "governing attribute?") ||
			pos == 51 && !StrEqual(text, "talent tree category?") ||
			pos == 52 && !StrEqual(text, "part of menu named?") ||
			pos == 53 && !StrEqual(text, "layer?") ||
			pos == 54 && !StrEqual(text, "is ability?") ||
			pos == 55 && !StrEqual(text, "action bar name?") ||
			pos == 56 && !StrEqual(text, "required talents required?") ||
			pos == 57 && !StrEqual(text, "talent upgrade strength value?") ||
			pos == 58 && !StrEqual(text, "talent cooldown strength value?") ||
			pos == 59 && !StrEqual(text, "talent active time strength value?") ||
			pos == 60 && !StrEqual(text, "governs cooldown of talent named?") ||
			pos == 61 && !StrEqual(text, "talent hard limit?") ||
			pos == 62 && !StrEqual(text, "is effect over time?") ||
			pos == 63 && !StrEqual(text, "effect strength?") ||
			pos == 64 && !StrEqual(text, "ignore for layer count?") ||
			pos == 65 && !StrEqual(text, "is attribute?") ||
			pos == 66 && !StrEqual(text, "hide translation?") ||
			pos == 67 && !StrEqual(text, "roll chance?")) {
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
			pos == 68 && !StrEqual(text, "interval per point?") ||
			pos == 69 && !StrEqual(text, "interval first point?") ||
			pos == 70 && !StrEqual(text, "range per point?") ||
			pos == 71 && !StrEqual(text, "range first point value?") ||
			pos == 72 && !StrEqual(text, "stamina per point?") ||
			pos == 73 && !StrEqual(text, "base stamina required?") ||
			pos == 74 && !StrEqual(text, "cooldown per point?") ||
			pos == 75 && !StrEqual(text, "cooldown first point?") ||
			pos == 76 && !StrEqual(text, "cooldown start?") ||
			pos == 77 && !StrEqual(text, "active time per point?") ||
			pos == 78 && !StrEqual(text, "active time first point?") ||
			pos == 79 && !StrEqual(text, "ammo effect?") ||
			pos == 80 && !StrEqual(text, "effect multiplier?") ||
			pos == 81 && !StrEqual(text, "active effect?") ||
			pos == 82 && !StrEqual(text, "passive effect?") ||
			pos == 83 && !StrEqual(text, "cooldown effect?") ||
			pos == 84 && !StrEqual(text, "reactive ability?") ||
			pos == 85 && !StrEqual(text, "teams allowed?") ||
			pos == 86 && !StrEqual(text, "cooldown strength?") ||
			pos == 87 && !StrEqual(text, "maximum passive multiplier?") ||
			pos == 88 && !StrEqual(text, "maximum active multiplier?") ||
			pos == 89 && !StrEqual(text, "active requires ensnare?") ||
			pos == 90 && !StrEqual(text, "active strength?") ||
			pos == 91 && !StrEqual(text, "passive ignores cooldown?") ||
			pos == 92 && !StrEqual(text, "passive requires ensnare?") ||
			pos == 93 && !StrEqual(text, "passive strength?") ||
			pos == 94 && !StrEqual(text, "passive only?") ||
			pos == 95 && !StrEqual(text, "is single target?") ||
			pos == 96 && !StrEqual(text, "draw delay?") ||
			pos == 97 && !StrEqual(text, "draw effect delay?") ||
			pos == 98 && !StrEqual(text, "passive draw delay?") ||
			pos == 99 && !StrEqual(text, "attribute?") ||
			pos == 100 && !StrEqual(text, "use these multipliers?") ||
			pos == 101 && !StrEqual(text, "base multiplier?") ||
			pos == 102 && !StrEqual(text, "diminishing multiplier?") ||
			pos == 103 && !StrEqual(text, "diminishing returns?") ||
			pos == 104 && !StrEqual(text, "buff bar text?") ||
			pos == 105 && !StrEqual(text, "is sub menu?") ||
			pos == 106 && !StrEqual(text, "is aura instead?") ||
			pos == 107 && !StrEqual(text, "cooldown trigger?") ||
			pos == 108 && !StrEqual(text, "inactive trigger?") ||
			pos == 109 && !StrEqual(text, "reactive type?") ||
			pos == 110 && !StrEqual(text, "active time?") ||
			pos == 111 && !StrEqual(text, "cannot be ensnared?") ||
			pos == 112 && !StrEqual(text, "toggle effect?") ||
			pos == 113 && !StrEqual(text, "cooldown?") ||
			pos == 114 && !StrEqual(text, "activate effect per tick?") ||
			pos == 115 && !StrEqual(text, "secondary ept only?") ||
			pos == 116 && !StrEqual(text, "active end ability trigger?") ||
			pos == 117 && !StrEqual(text, "cooldown end ability trigger?") ||
			pos == 118 && !StrEqual(text, "does damage?") ||
			pos == 119 && !StrEqual(text, "special ammo?")) {
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
			pos == 120 && !StrEqual(text, "toggle strength?") ||
			pos == 121 && !StrEqual(text, "target class must be last target class?") ||
			pos == 122 && !StrEqual(text, "target range required?") ||
			pos == 123 && !StrEqual(text, "target must be outside range required?") ||
			pos == 124 && !StrEqual(text, "target must be last target?") ||
			pos == 125 && !StrEqual(text, "activator high ground?") ||
			pos == 126 && !StrEqual(text, "target high ground?") ||
			pos == 127 && !StrEqual(text, "activator neither high or low ground?") ||
			pos == 128 && !StrEqual(text, "event type?") ||
			pos == 129 && !StrEqual(text, "last hit must be headshot?") ||
			pos == 130 && !StrEqual(text, "mult str by same hits?") ||
			pos == 131 && !StrEqual(text, "mult str max same hits?") ||
			pos == 132 && !StrEqual(text, "mult str div same hits?") ||
			pos == 133 && !StrEqual(text, "contribution category required?") ||
			pos == 134 && !StrEqual(text, "contribution cost required?") ||
			pos == 135 && !StrEqual(text, "give player this item on trigger?") ||
			pos == 136 && !StrEqual(text, "hide talent strength display?") ||
			pos == 137 && !StrEqual(text, "activator ability trigger to call?") ||
			pos == 138 && !StrEqual(text, "weapon slot required?") ||
			pos == 139 && !StrEqual(text, "require consecutive headshots?") ||
			pos == 140 && !StrEqual(text, "mult str by same headshots?") ||
			pos == 141 && !StrEqual(text, "mult str max same headshots?") ||
			pos == 142 && !StrEqual(text, "mult str div same headshots?") ||
			pos == 143 && !StrEqual(text, "active effect allows all weapons?") ||
			pos == 144 && !StrEqual(text, "active effect allows all hitgroups?") ||
			pos == 145 && !StrEqual(text, "active effect allows all classes?") ||
			pos == 146 && !StrEqual(text, "activator status effect required?") ||
			pos == 147 && !StrEqual(text, "health percentage remaining required?") ||
			pos == 148 && !StrEqual(text, "health cost on activation?") ||
			pos == 149 && !StrEqual(text, "multiply strength downed allies?") ||
			pos == 150 && !StrEqual(text, "multiply strength ensnared allies?") ||
			pos == 151 && !StrEqual(text, "no augment modifiers?") ||
			pos == 152 && !StrEqual(text, "target ability trigger to call?") ||
			pos == 153 && !StrEqual(text, "must be within coherency of talent?") ||
			pos == 154 && !StrEqual(text, "must be unhurt by si or witch?") ||
			pos == 155 && !StrEqual(text, "skip talent for augment roll?") ||
			pos == 156 && !StrEqual(text, "require ally with adrenaline?") ||
			pos == 157 && !StrEqual(text, "require ally below health percentage?") ||
			pos == 158 && !StrEqual(text, "require ensnared ally?") ||
			pos == 159 && !StrEqual(text, "target must be ally ensnarer?") ||
			pos == 160 && !StrEqual(text, "require enemy in coherency range?") ||
			pos == 161 && !StrEqual(text, "enemy in coherency is target?") ||
			pos == 162 && !StrEqual(text, "require ally on fire?") ||
			pos == 163 && !StrEqual(text, "talent cooldown minimum value?") ||
			pos == 164 && !StrEqual(text, "ability category?") ||
			pos == 165 && !StrEqual(text, "target status effect required?") ||
			pos == 166 && !StrEqual(text, "activator must be in ammo?") ||
			pos == 167 && !StrEqual(text, "target must be in ammo?") ||
			pos == 168 && !StrEqual(text, "time since last activator attack?") ||
			pos == 169 && !StrEqual(text, "weapon name required?")) {
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
		for (int i = 0; i < sortSize; i++) {
			if (i == TALENT_IS_EFFECT_OVER_TIME || i == ACTIVATOR_CLASS_REQ || i == TARGET_CLASS_REQ || i == ABILITY_TYPE ||
			i == IF_EOT_ACTIVE_ALLOW_ALL_ENEMIES || i == COMBAT_STATE_REQ || i == CONTRIBUTION_TYPE_CATEGORY ||
			i == CONTRIBUTION_COST || i == TALENT_WEAPON_SLOT_REQUIRED || i == LAST_KILL_MUST_BE_HEADSHOT ||
			i == TARGET_AND_LAST_TARGET_CLASS_MATCH || i == TARGET_RANGE_REQUIRED || i == TARGET_RANGE_REQUIRED_OUTSIDE ||
			i == TARGET_MUST_BE_LAST_TARGET || i == TARGET_IS_SELF || i == ACTIVATOR_STATUS_EFFECT_REQUIRED  || i == TARGET_STATUS_EFFECT_REQUIRED ||
			i == ACTIVATOR_MUST_HAVE_HIGH_GROUND || i == TARGET_MUST_HAVE_HIGH_GROUND || i == ACTIVATOR_TARGET_MUST_EVEN_GROUND ||
			i == IF_EOT_ACTIVE_ALLOW_ALL_WEAPONS || i == WEAPONS_PERMITTED || i == HEALTH_PERCENTAGE_REQ ||
			i == COHERENCY_RANGE || i == COHERENCY_MAX || i == COHERENCY_REQ ||
			i == HEALTH_PERCENTAGE_REQ_TAR_REMAINING || i == HEALTH_PERCENTAGE_REQ_TAR_MISSING || i == HEALTH_PERCENTAGE_REQ_ACT_REMAINING ||
			i == REQUIRES_ZOOM || i == IF_EOT_ACTIVE_ALLOW_ALL_HITGROUPS || i == REQUIRES_HEADSHOT ||
			i == REQUIRES_LIMBSHOT || i == HEALTH_PERCENTAGE_ACTIVATION_COST ||
			i == TALENT_NO_AUGMENT_MODIFIERS || i == REQUIRE_ENEMY_IN_COHERENCY_RANGE || i == ENEMY_IN_COHERENCY_IS_TARGET) {// || i == UNHURT_BY_SPECIALINFECTED_OR_WITCH) {
				GetArrayString(TalentValue, i, text, sizeof(text));
				if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
				else SetArrayCell(TalentValue, i, StringToInt(text));	//int
			}
			else if (i == ACTIVATOR_STAGGER_REQ || i == TARGET_STAGGER_REQ ||
			i == CANNOT_TARGET_SELF || i == REQ_ADRENALINE_EFFECT || i == DISABLE_IF_WEAKNESS ||
			i == REQ_WEAKNESS || i == REQ_CONSECUTIVE_HITS ||
			i == REQ_CONSECUTIVE_HEADSHOTS || i == MULT_STR_CONSECUTIVE_HITS || i == MULT_STR_CONSECUTIVE_MAX ||
			i == MULT_STR_CONSECUTIVE_DIV || i == MULT_STR_CONSECUTIVE_HEADSHOTS ||
			i == MULT_STR_CONSECUTIVE_HEADSHOTS_MAX || i == MULT_STR_CONSECUTIVE_HEADSHOTS_DIV ||
			i == BACKGROUND_TALENT || i == STATUS_EFFECT_MULTIPLIER || i == MULTIPLY_RANGE ||
			i == MULTIPLY_COMMONS || i == MULTIPLY_SUPERS || i == MULTIPLY_WITCHES || i == MULTIPLY_SURVIVORS ||
			i == MULTIPLY_SPECIALS || i == STRENGTH_INCREASE_ZOOMED || i == STRENGTH_INCREASE_TIME_CAP ||
			i == STRENGTH_INCREASE_TIME_REQ || i == ZOOM_TIME_HAS_MINIMUM_REQ ||
			i == HOLDING_FIRE_STRENGTH_INCREASE || i == STRENGTH_INCREASE_TIME_CAP ||
			i == DAMAGE_TIME_HAS_MINIMUM_REQ || i == HEALTH_PERCENTAGE_REQ_MISSING ||
			i == HEALTH_PERCENTAGE_REQ_MISSING_MAX ||
			i == TALENT_ACTIVE_STRENGTH_VALUE || i == PRIMARY_AOE || i == SECONDARY_AOE) {
				GetArrayString(TalentValue, i, text, sizeof(text));
				if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
				else SetArrayCell(TalentValue, i, StringToInt(text));	//int
			}
			else if (i == GET_TALENT_LAYER || i == IS_ATTRIBUTE || i == LAYER_COUNTING_IS_IGNORED ||
			i == ATTRIBUTE_BASE_MULTIPLIER || i == IS_SUB_MENU_OF_TALENTCONFIG ||
			i == IS_AURA_INSTEAD ||
			i == ABILITY_IS_REACTIVE || i == IS_TALENT_ABILITY || i == ABILITY_COOLDOWN_STRENGTH ||
			i == ABILITY_MAXIMUM_PASSIVE_MULTIPLIER || i == ABILITY_MAXIMUM_ACTIVE_MULTIPLIER ||
			i == ABILITY_ACTIVE_STATE_ENSNARE_REQ || i == ABILITY_ACTIVE_STRENGTH || i == ABILITY_PASSIVE_IGNORES_COOLDOWN ||
			i == ABILITY_PASSIVE_STATE_ENSNARE_REQ || i == ABILITY_PASSIVE_STRENGTH || i == SPELL_ACTIVE_TIME_FIRST_POINT ||
			i == SPELL_ACTIVE_TIME_PER_POINT || i == SPELL_COOLDOWN_START || i == SPELL_COOLDOWN_FIRST_POINT ||
			i == SPELL_COOLDOWN_PER_POINT || i == SPELL_BASE_STAMINA_REQ || i == SPELL_STAMINA_PER_POINT ||
			i == SPELL_RANGE_FIRST_POINT || i == SPELL_RANGE_PER_POINT || i == SPELL_INTERVAL_FIRST_POINT ||
			i == SPELL_INTERVAL_PER_POINT || i == ABILITY_REQ_NO_ENSNARE || i == ABILITY_ACTIVE_TIME ||
			i == ABILITY_REACTIVE_TYPE || i == ABILITY_DRAW_DELAY || i == ABILITY_IS_SINGLE_TARGET ||
			i == ABILITY_PASSIVE_ONLY) {
				GetArrayString(TalentValue, i, text, sizeof(text));
				if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
				else SetArrayCell(TalentValue, i, StringToInt(text));	//int
			}
			else if (i == TIME_SINCE_LAST_ACTIVATOR_ATTACK || i == ABILITY_EVENT_TYPE || i == TALENT_IS_SPELL || i == NUM_TALENTS_REQ ||
			i == HIDE_TALENT_STRENGTH_DISPLAY || i == HIDE_TRANSLATION || i == ABILITY_ACTIVE_DRAW_DELAY ||
			i == ABILITY_PASSIVE_DRAW_DELAY || i == TALENT_ROLL_CHANCE || i == SPECIAL_AMMO_TALENT_STRENGTH ||
			i == ABILITY_TOGGLE_STRENGTH || i == ABILITY_COOLDOWN || i == SPELL_EFFECT_MULTIPLIER || i == COMPOUNDING_TALENT ||
			i == MULT_STR_NEARBY_DOWN_ALLIES || i == MULT_STR_NEARBY_ENSNARED_ALLIES || i == REQUIRE_TARGET_HAS_ENSNARED_ALLY ||
			i == REQUIRE_ENSNARED_ALLY || i == SKIP_TALENT_FOR_AUGMENT_ROLL || i == REQUIRE_ALLY_WITH_ADRENALINE || i == REQUIRE_ALLY_BELOW_HEALTH_PERCENTAGE ||
			i == REQUIRE_ALLY_ON_FIRE || i == TALENT_MINIMUM_COOLDOWN_TIME || i == ABILITY_CATEGORY) {
				GetArrayString(TalentValue, i, text, sizeof(text));
				if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
				else SetArrayCell(TalentValue, i, StringToInt(text));	//int
			}
		}
		int ASize = GetArraySize(a_Menu_Talents);
		for (int client = 1; client <= MAXPLAYERS; client++) {
			ResizeArray(MyTalentStrength[client], ASize);
			ResizeArray(MyTalentStrengths[client], ASize);
			for (int i = 0; i < ASize; i++) {
				// preset all talents to being unclaimed.
				SetArrayCell(MyTalentStrengths[client], i, 0.0);
				SetArrayCell(MyTalentStrengths[client], i, 0.0, 1);
				SetArrayCell(MyTalentStrengths[client], i, 0.0, 2);
				SetArrayCell(MyTalentStrength[client], i, 0);
			}
		}

		// for (int client = 1; client <= MAXPLAYERS; client++) {
		// 	ResizeArray(PlayerAbilitiesCooldown[client], ASize);
		// 	ResizeArray(a_Database_PlayerTalents[client], ASize);
		// 	ResizeArray(a_Database_PlayerTalents_Experience[client], ASize);
		// 	for (int i = 0; i < ASize; i++) {
		// 		SetArrayCell(a_Database_PlayerTalents[client], i, 0);
		// 		SetArrayString(PlayerAbilitiesCooldown[client], i, "0");
		// 		SetArrayCell(a_Database_PlayerTalents_Experience[client], i, 0);
		// 	}
		// }
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
		for (int i = 0; i < sortSize; i++) {
			if (i == EVENT_DAMAGE_AWARD || i == EVENT_IS_PLAYER_NOW_IT || i == EVENT_IS_ORIGIN ||
			i == EVENT_IS_DISTANCE || i == EVENT_MULTIPLIER_POINTS || i == EVENT_MULTIPLIER_EXPERIENCE ||
			i == EVENT_IS_SHOVED || i == EVENT_IS_BULLET_IMPACT || i == EVENT_ENTERED_SAFEROOM ||
			i == EVENT_SAMETEAM_TRIGGER) {
				GetArrayString(TalentValue, i, text, sizeof(text));
				if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
				else SetArrayCell(TalentValue, i, StringToInt(text));	//int
			}
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
		for (int i = 0; i < sortSize; i++) {
			char tk[64];
			GetArrayString(TalentKey, i, tk, sizeof(tk));
			GetArrayString(TalentValue, i, text, sizeof(text));
			if (i == SUPER_COMMON_REQ_BILED_SURVIVORS || i == SUPER_COMMON_MAX_ALLOWED || i == SUPER_COMMON_SPAWN_CHANCE ||
			i == SUPER_COMMON_MODEL_SIZE) {
				if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
				else SetArrayCell(TalentValue, i, StringToInt(text));	//int
			}
			if (StrContains(text, ".mdl") == -1) continue;
			PushArrayString(ModelsToPrecache, text);
		}
	}
	else if (StrEqual(Config, CONFIG_HANDICAP)) {
		if (FindStringInArray(TalentKey, "translation?") == -1) {
			PushArrayString(TalentKey, "translation?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "damage bonus?") == -1) {
			PushArrayString(TalentKey, "damage bonus?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "health bonus?") == -1) {
			PushArrayString(TalentKey, "health bonus?");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "loot find?") == -1) {
			PushArrayString(TalentKey, "loot find?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "score required?") == -1) {
			PushArrayString(TalentKey, "score required?");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "score multiplier?") == -1) {
			PushArrayString(TalentKey, "score multiplier?");
			PushArrayString(TalentValue, "-1.0");
		}
		sortSize = GetArraySize(TalentKey);
		pos = 0;
		while (pos < sortSize) {
			GetArrayString(TalentKey, pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "translation?") ||
			pos == 1 && !StrEqual(text, "damage bonus?") ||
			pos == 2 && !StrEqual(text, "health bonus?") ||
			pos == 3 && !StrEqual(text, "loot find?") ||
			pos == 4 && !StrEqual(text, "score required?") ||
			pos == 5 && !StrEqual(text, "score multiplier?")) {
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
		for (int i = 0; i < sortSize; i++) {
			GetArrayString(TalentValue, i, text, sizeof(text));
			//if (StrEqual(text, "EOM")) continue;
			if (i == HANDICAP_TRANSLATION) continue;
			if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
			else SetArrayCell(TalentValue, i, StringToInt(text));	//int
		}
	}
	else if (StrEqual(Config, CONFIG_WEAPONS)) {
		if (FindStringInArray(TalentKey, "damage") == -1) {
			PushArrayString(TalentKey, "damage");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "range") == -1) {
			PushArrayString(TalentKey, "range");
			PushArrayString(TalentValue, "-1.0");
		}
		if (FindStringInArray(TalentKey, "offset") == -1) {
			PushArrayString(TalentKey, "offset");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "ammo") == -1) {
			PushArrayString(TalentKey, "ammo");
			PushArrayString(TalentValue, "-1");
		}
		if (FindStringInArray(TalentKey, "range required?") == -1) {
			PushArrayString(TalentKey, "range required?");
			PushArrayString(TalentValue, "-1.0");
		}
		sortSize = GetArraySize(TalentKey);
		pos = 0;
		while (pos < sortSize) {
			GetArrayString(TalentKey, pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "damage") ||
			pos == 1 && !StrEqual(text, "offset") ||
			pos == 2 && !StrEqual(text, "ammo") ||
			pos == 3 && !StrEqual(text, "range") ||
			pos == 4 && !StrEqual(text, "range required?")) {
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
		for (int i = 0; i < sortSize; i++) {
			GetArrayString(TalentValue, i, text, sizeof(text));
			//if (StrEqual(text, "EOM")) continue;
			if (StrContains(text, ".") != -1) SetArrayCell(TalentValue, i, StringToFloat(text));	//float
			else SetArrayCell(TalentValue, i, StringToInt(text));	//int
		}
	}
	GetArrayString(Section, 0, text, sizeof(text));
	PushArrayString(TalentSection, text);

	ResizeArray(Main, size + 1);
	SetArrayCell(Main, size, TalentKey, 0);
	SetArrayCell(Main, size, TalentValue, 1);
	SetArrayCell(Main, size, TalentSection, 2);
	if (configIsForTalents) {
		PushArrayString(a_Database_Talents, text);
		SetArrayCell(Main, size, TalentTriggers, 3);
	}
}

public ReadyUp_FwdGetHeader(const char[] header) {
	strcopy(s_rup, sizeof(s_rup), header);
}

public ReadyUp_FwdGetCampaignName(const char[] mapname) {
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
stock bool IsSpecialCommon(entity) {
	if (FindListPositionByEntity(entity, CommonList) >= 0) {
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
