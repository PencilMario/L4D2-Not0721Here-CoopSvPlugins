void CreateAndHookConVars()
{
	g_hCvar_GameDifficulty 							= FindConVar("z_difficulty");
	g_hCvar_SurvivorLimpHealth 						= FindConVar("survivor_limp_health");
	g_hCvar_TankRockHealth 							= FindConVar("z_tank_throw_health");
	g_hCvar_GasCanUseDuration 						= FindConVar("gas_can_use_duration");
	g_hCvar_ChaseBileRange							= FindConVar("z_notice_it_range");
	g_hCvar_ServerGravity							= FindConVar("sv_gravity");
	g_hCvar_BileCoverDuration_Bot					= FindConVar("vomitjar_duration_infected_bot");
	g_hCvar_BileCoverDuration_PZ					= FindConVar("vomitjar_duration_infected_pz");

	g_hCvar_MaxMeleeSurvivors 						= FindConVar("sb_max_team_melee_weapons");
	g_hCvar_BotsShootThrough 						= FindConVar("sb_allow_shoot_through_survivors");
	g_hCvar_BotsFriendlyFire 						= FindConVar("sb_friendlyfire");
	g_hCvar_BotsDisabled 							= FindConVar("sb_stop");
	g_hCvar_BotsDontShoot 							= FindConVar("sb_dont_shoot");
	g_hCvar_BotsVomitBlindTime 						= FindConVar("sb_vomit_blind_time");

	g_hCvar_MaxAmmo_Pistol							= FindConVar("ammo_pistol_max");
	g_hCvar_MaxAmmo_AssaultRifle					= FindConVar("ammo_assaultrifle_max");
	g_hCvar_MaxAmmo_SMG								= FindConVar("ammo_smg_max");
	g_hCvar_MaxAmmo_M60								= FindConVar("ammo_m60_max");
	g_hCvar_MaxAmmo_Shotgun							= FindConVar("ammo_shotgun_max");
	g_hCvar_MaxAmmo_AutoShotgun						= FindConVar("ammo_autoshotgun_max");
	g_hCvar_MaxAmmo_HuntRifle						= FindConVar("ammo_huntingrifle_max");
	g_hCvar_MaxAmmo_SniperRifle						= FindConVar("ammo_sniperrifle_max");
	g_hCvar_MaxAmmo_PipeBomb						= FindConVar("ammo_pipebomb_max");
	g_hCvar_MaxAmmo_Molotov							= FindConVar("ammo_molotov_max");
	g_hCvar_MaxAmmo_VomitJar						= FindConVar("ammo_vomitjar_max");
	g_hCvar_MaxAmmo_PainPills						= FindConVar("ammo_painpills_max");
	g_hCvar_MaxAmmo_GrenLauncher					= FindConVar("ammo_grenadelauncher_max");
	g_hCvar_MaxAmmo_Adrenaline						= FindConVar("ammo_adrenaline_max");
	g_hCvar_MaxAmmo_Chainsaw						= FindConVar("ammo_chainsaw_max");
	g_hCvar_MaxAmmo_AmmoPack						= FindConVar("ammo_ammo_pack_max");
	g_hCvar_MaxAmmo_Medkit							= FindConVar("ammo_firstaid_max");

	g_hCvar_Ammo_Type_Override 						= CreateConVar("ib_ammotype_override", "", "If your server has weapons with modified ammo types/amounts, put them here in a following format: \"weapon_id:ammo_max weapon_id:ammo_max ...\"", FCVAR_NOTIFY);

	g_hCvar_ImprovedMelee_Enabled 					= CreateConVar("ib_melee_enabled", "1", "Enables survivor bots' improved melee behaviour.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ImprovedMelee_MaxCount 					= CreateConVar("ib_melee_max_team", "2", "The total number of melee weapons allowed on the team. <0: Bots never use melee>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_SwitchCount 				= CreateConVar("ib_melee_switch_count", "3", "The nearby infected count required for bot to switch to their melee weapon.", FCVAR_NOTIFY, true, 1.0);
	g_hCvar_ImprovedMelee_SwitchRange 				= CreateConVar("ib_melee_switch_range", "250", "Range at which bot's target should be to switch to melee weapon.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_ApproachRange				= CreateConVar("ib_melee_approach_range", "120", "Range at which bot's target should be to approach it. <0: Disable Approaching>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_AimRange 					= CreateConVar("ib_melee_aim_range", "125", "Range at which bot's target should be to start taking aim at it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_AttackRange 				= CreateConVar("ib_melee_attack_range", "70", "Range at which bot's target should be to start attacking it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_ShoveChance 				= CreateConVar("ib_melee_shove_chance", "4", "Chance for bot to bash target instead of attacking with melee. <0: Disable Bashing>", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_ImprovedMelee_ChainsawLimit 			= CreateConVar("ib_melee_chainsaw_limit", "1", "The total number of chainsaws allowed on the team. <0: Bots never use chainsaw>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ImprovedMelee_SwitchCount2 				= CreateConVar("ib_melee_chainsaw_switch_count", "6", "The nearby infected count required for bot to switch to chainsaw.", FCVAR_NOTIFY, true, 1.0);

	g_hCvar_TargetSelection_Enabled					= CreateConVar("ib_targeting_enabled", "1", "Enables survivor bots' improved target selection.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TargetSelection_ShootRange				= CreateConVar("ib_targeting_range", "2000", "Range at which target need to be for bots to start firing at it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange2				= CreateConVar("ib_targeting_range_shotgun", "750", "Range at which target need to be for bots to start firing at it with shotgun.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange3				= CreateConVar("ib_targeting_range_sniperrifle", "3000", "Range at which target need to be for bots to start firing at it with sniper rifle.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_ShootRange4				= CreateConVar("ib_targeting_range_pistol", "1500", "Range at which target need to be for bots to start firing at it with secondary weapon.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_TargetSelection_IgnoreDociles			= CreateConVar("ib_targeting_ignoredociles", "1", "If bots shouldn't target common infected that are currently not attacking survivors.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_GrenadeThrow_Enabled 					= CreateConVar("ib_gren_enabled", "1", "Enables survivor bots throwing grenades.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_GrenadeThrow_GrenadeTypes				= CreateConVar("ib_gren_types", "7", "What grenades should survivor bots throw? <1: Pipe-Bomb, 2: Molotov, 4: Bile Bomb. Add numbers together.>", FCVAR_NOTIFY, true, 1.0, true, 7.0);
	g_hCvar_GrenadeThrow_ThrowRange					= CreateConVar("ib_gren_throw_range", "1500", "Range at which target needs to be for bot to throw grenade at it.", FCVAR_NOTIFY);
	g_hCvar_GrenadeThrow_HordeSize 					= CreateConVar("ib_gren_horde_size_multiplier", "5.0", "Infected count required to throw grenade Multiplier (Value * SurvivorCount).", FCVAR_NOTIFY, true, 1.0);
	g_hCvar_GrenadeThrow_NextThrowTime1 			= CreateConVar("ib_gren_next_throw_time_min", "20", "First number to pick to randomize next grenade throw time.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_GrenadeThrow_NextThrowTime2 			= CreateConVar("ib_gren_next_throw_time_max", "30", "Second number to pick to randomize next grenade throw time.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_TankRock_ShootEnabled 					= CreateConVar("ib_shootattankrocks_enabled", "1", "Enables survivor bots shooting tank's thrown rocks.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TankRock_ShootRange 					= CreateConVar("ib_shootattankrocks_range", "1500", "Range at which rock needs to be for bot to start shooting at it.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_AutoShove_Enabled						= CreateConVar("ib_autoshove_enabled", "1", "Makes survivor bots automatically shove every nearby infected. <0: Disabled, 1: All infected, 2: Only if infected is behind them>", FCVAR_NOTIFY, true, 0.0, true, 2.0);

	g_hCvar_HelpPinnedFriend_Enabled				= CreateConVar("ib_help_pinned_enabled", "3", "Makes survivor bots force attack pinned survivor's SI if possible. <0: Disabled, 1: Shoot at attacker, 2: Shove the attacker if close enough. Add numbers together.>", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_HelpPinnedFriend_ShootRange				= CreateConVar("ib_help_pinned_shootrange", "2000", "Range at which bots will start firing at SI.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_HelpPinnedFriend_ShoveRange				= CreateConVar("ib_help_pinned_shoverange", "75", "Range at which bots will start to bash SI.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_HelpPinnedFriend_ReactionBots				= CreateConVar("ib_help_pinned_reaction_bots", "2", "Limits pinned-friend reaction to the nearest survivor Bots. 0: Plugin does not process this reaction; >0: nearest Bots only.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_HelpPinnedFriend_ReactionInterval				= CreateConVar("ib_help_pinned_reaction_interval", "0.15", "Minimum interval between forced pinned-friend rescue evaluations for the same Bot.", FCVAR_NOTIFY, true, 0.05, true, 2.0);
	g_hCvar_HelpPinnedFriend_MaxDistance					= CreateConVar("ib_help_pinned_max_distance", "5000", "Maximum distance at which the plugin processes a pinned survivor rescue. 0: No distance limit.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_DefibRevive_Enabled						= CreateConVar("ib_defib_revive_enabled", "1", "Enable bots reviving dead players with defibrillators if they have one available.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DefibRevive_ScanDist 					= CreateConVar("ib_defib_revive_distance", "2000", "Range at which survivor's dead body should be for bot to consider it reviveable.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_FireBash_Chance1						= CreateConVar("ib_shove_chance_pump", "4", "Chance at which survivor bot may shove after firing a pump-action shotgun. <0: Disabled, 1: Always>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_FireBash_Chance2						= CreateConVar("ib_shove_chance_css", "3", "Chance at which survivor bot may shove after firing a bolt-action sniper rifle. <0: Disabled, 1: Always>", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_ItemScavenge_Models						= CreateConVar("ib_grab_models", "0", "If enabled, objects with certain models will be considered as scavengeable items.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ItemScavenge_Items 						= CreateConVar("ib_grab_enabled", "16383", "Enable improved bot item scavenging for specified items. <0: Disable, 1: Pipe Bomb, 2: Molotov, 4: Bile Bomb, 8: Medkit, 16: Defibrillator, 32: UpgradePack, 64: Pain Pills, 128: Adrenaline, 256: Laser Sights, 512: Ammopack, 1024: Ammopile, 2048: Chainsaw, 4096: Secondary Weapons, 8192: Primary Weapons. Add numbers together>", FCVAR_NOTIFY, true, 0.0, true, 16383.0);
	g_hCvar_ItemScavenge_ApproachRange 				= CreateConVar("ib_grab_distance", "300", "Distance at which item should be for bot to move it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_ApproachVisibleRange 		= CreateConVar("ib_grab_visible_distance", "600", "Distance at which a visible item should be for bot to move it.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_PickupRange 				= CreateConVar("ib_grab_pickup_distance", "100", "Distance at which item should be for bot to able to pick it up.", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_MapSearchRange 			= CreateConVar("ib_grab_mapsearchdistance", "2500", "How close should the item be to the survivor bot to able to count it when searching?", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_ItemScavenge_NoHumansRangeMultiplier	= CreateConVar("ib_grab_nohumans_rangemultiplier", "1.2", "The bots' scavenge distance is multiplied to this value when there's no human players left in the team.", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_BotWeaponPreference_Nick 				= CreateConVar("ib_pref_nick", "1", "Bot Nick's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Rochelle 			= CreateConVar("ib_pref_rochelle", "1", "Bot Rochelle's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Coach 				= CreateConVar("ib_pref_coach", "2", "Bot Coach's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Ellis 				= CreateConVar("ib_pref_ellis", "3", "Bot Ellis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Bill  				= CreateConVar("ib_pref_bill", "1", "Bot Bill's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Zoey 				= CreateConVar("ib_pref_zoey", "3", "Bot Zoey's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Francis 			= CreateConVar("ib_pref_francis", "2", "Bot Francis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_Louis 				= CreateConVar("ib_pref_louis", "1", "Bot Louis's weapon preference. <0: Default, 1: Assault Rifle, 2: Shotgun, 3: Sniper Rifle, 4: SMG, 5: Secondary Weapon>", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCvar_BotWeaponPreference_ForceMagnum 		= CreateConVar("ib_pref_magnums_only", "0", "If every survivor bot should only use magnum instead of regular pistol if possible.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_SwapSameTypePrimaries 					= CreateConVar("ib_mix_primaries", "1", "Makes survivor bots change their primary weapon subtype if there's too much of the same one, Ex. change AK-47 to M16 or SPAS-12 to Autoshotgun.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_SwapSameTypeGrenades 					= CreateConVar("ib_mix_grenades", "1", "Makes survivor bots change their grenade type if there's too much of the same one, Ex. Pipe-Bomb to Molotov.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvar_T3_Refill 								= CreateConVar("ib_t3_refill", "3", "Should bots pick up ammo when carrying a Tier 3 weapon? Keep disabled if your server does not allow that. <0: Disabled, 1: Grenade Launcher, 2: M60, 3: Both>", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_MaxWeaponTier3_M60 						= CreateConVar("ib_t3_limit_m60", "2", "The total number of M60s allowed on the team. <0: Bots never use M60>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_MaxWeaponTier3_GLauncher 				= CreateConVar("ib_t3_limit_gl", "2", "The total number of grenade launchers allowed on the team. <0: Bots never use grenade launcher>", FCVAR_NOTIFY, true, 0.0);

	g_hCvar_Vision_FieldOfView 						= CreateConVar("ib_vision_fov", "75.0", "The field of view of survivor bots.", FCVAR_NOTIFY, true, 0.0, true, 180.0);
	g_hCvar_Vision_NoticeTimeScale 					= CreateConVar("ib_vision_noticetimescale", "1.1", "The time required for bots to notice enemy target is multiplied to this value.", FCVAR_NOTIFY, true, 0.0, true, 4.0);

	g_hCvar_SpitterAcidEvasion						= CreateConVar("ib_evade_spit", "1", "Enables survivor bots' improved spitter acid evasion", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_AlwaysCarryProp							= CreateConVar("ib_alwayscarryprop", "1", "If enabled, survivor bot will keep holding the prop it currently has unless it's swarmed by a mob, every teammate needs help, or it wants to use an item.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_KeepMovingInCombat						= CreateConVar("ib_keepmovingincombat", "1", "If bots shouldn't stop moving in combat when there's no human players in team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_SwitchOffCSSWeapons						= CreateConVar("ib_avoid_css", "0", "If bots should change their primary weapon to other one if they're using CSS weapons.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_ChargerEvasion							= CreateConVar("ib_evade_charge", "1", "Enables survivor bots's charger dodging behavior.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DeployUpgradePacks						= CreateConVar("ib_deployupgradepacks", "1", "If bots should deploy their upgrade pack when available and not in combat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_DontSwitchToPistol						= CreateConVar("ib_dontswitchtopistol", "0", "If bots shouldn't switch to their pistol while they have sniper rifle equiped.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_TakeCoverFromRocks						= CreateConVar("ib_takecoverfromtankrocks", "1", "If bots should take cover from tank's thrown rocks.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_AvoidTanksWithProp						= CreateConVar("ib_avoidtanksnearpunchableprops", "1", "If bots should avoid and retreat from tanks that are nearby punchable props like cars.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_NoFallDmgOnLadderFail					= CreateConVar("ib_nofalldmgonladderfail", "0", "If enabled, survivor bots won't take fall damage if they were climbing a ladder just before that.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_WitchBehavior_WalkWhenNearby			= CreateConVar("ib_witchbehavior_walkwhennearby", "0", "Survivor bots will start walking near witch if they're this range near her and she's not disturbed. <0: Disabled>", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_WitchBehavior_AllowCrowning = CreateConVar("ib_witchbehavior_allowcrowning", "1", "Allows survivor bots to crown witch on their path if they're holding any shotgun type weapon. <0: Disabled; 1: Only if survivor team doesn't have any human players; 2:Enabled>", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_hCvar_NextProcessTime = CreateConVar("ib_process_time", "0.2", "Bots' data computing time delay (infected count, nearby friends, etc). Increasing the value might help increasing the game performance, but slow down bots.", FCVAR_NOTIFY, true, 0.033);
	CreateDegradedConVars();
	g_hCvar_PerformanceLogging = CreateConVar("ib_performance_logging", "0", "Log calculations exceeding the configured threshold.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_PerformanceThresholdMs = CreateConVar("ib_performance_threshold_ms", "1.0", "Slow calculation logging threshold in milliseconds.", FCVAR_NOTIFY, true, 0.1);
	g_hCvar_Debug									= CreateConVar("ib_debug", "0", "Spam console/chat in hopes of finding a a clue for your problems. Prints WILL LAG on Windows GUI!", FCVAR_NOTIFY, true, 0.0, true, 1024.0);

	g_hCvar_GameDifficulty.AddChangeHook(OnConVarChanged);
	g_hCvar_SurvivorLimpHealth.AddChangeHook(OnConVarChanged);
	g_hCvar_TankRockHealth.AddChangeHook(OnConVarChanged);
	g_hCvar_GasCanUseDuration.AddChangeHook(OnConVarChanged);
	g_hCvar_ChaseBileRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ServerGravity.AddChangeHook(OnConVarChanged);
	g_hCvar_BileCoverDuration_Bot.AddChangeHook(OnConVarChanged);
	g_hCvar_BileCoverDuration_PZ.AddChangeHook(OnConVarChanged);

	g_hCvar_MaxAmmo_Pistol.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_AssaultRifle.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_SMG.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_M60.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Shotgun.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_AutoShotgun.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_HuntRifle.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_SniperRifle.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_PipeBomb.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Molotov.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_VomitJar.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_PainPills.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_GrenLauncher.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Adrenaline.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Chainsaw.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_AmmoPack.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxAmmo_Medkit.AddChangeHook(OnConVarChanged);

	g_hCvar_Ammo_Type_Override.AddChangeHook(OnConVarChanged);

	g_hCvar_MaxMeleeSurvivors.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsShootThrough.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsFriendlyFire.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsDisabled.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsDontShoot.AddChangeHook(OnConVarChanged);
	g_hCvar_BotsVomitBlindTime.AddChangeHook(OnConVarChanged);

	g_hCvar_ImprovedMelee_MaxCount.AddChangeHook(OnConVarChanged);

	g_hCvar_ImprovedMelee_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_SwitchCount.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_SwitchRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_ApproachRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_AimRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_AttackRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_ShoveChance.AddChangeHook(OnConVarChanged);

	g_hCvar_ImprovedMelee_ChainsawLimit.AddChangeHook(OnConVarChanged);
	g_hCvar_ImprovedMelee_SwitchCount2.AddChangeHook(OnConVarChanged);

	g_hCvar_TargetSelection_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange2.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange3.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_ShootRange4.AddChangeHook(OnConVarChanged);
	g_hCvar_TargetSelection_IgnoreDociles.AddChangeHook(OnConVarChanged);

	g_hCvar_GrenadeThrow_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_GrenadeTypes.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_ThrowRange.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_HordeSize.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_NextThrowTime1.AddChangeHook(OnConVarChanged);
	g_hCvar_GrenadeThrow_NextThrowTime2.AddChangeHook(OnConVarChanged);

	g_hCvar_TankRock_ShootEnabled.AddChangeHook(OnConVarChanged);
	g_hCvar_TankRock_ShootRange.AddChangeHook(OnConVarChanged);

	g_hCvar_AutoShove_Enabled.AddChangeHook(OnConVarChanged);

	g_hCvar_HelpPinnedFriend_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_ShootRange.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_ShoveRange.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_ReactionBots.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_ReactionInterval.AddChangeHook(OnConVarChanged);
	g_hCvar_HelpPinnedFriend_MaxDistance.AddChangeHook(OnConVarChanged);

	g_hCvar_DefibRevive_Enabled.AddChangeHook(OnConVarChanged);
	g_hCvar_DefibRevive_ScanDist.AddChangeHook(OnConVarChanged);

	g_hCvar_FireBash_Chance1.AddChangeHook(OnConVarChanged);
	g_hCvar_FireBash_Chance2.AddChangeHook(OnConVarChanged);

	g_hCvar_ItemScavenge_Models.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_Items.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_ApproachRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_ApproachVisibleRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_PickupRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_MapSearchRange.AddChangeHook(OnConVarChanged);
	g_hCvar_ItemScavenge_NoHumansRangeMultiplier.AddChangeHook(OnConVarChanged);

	g_hCvar_BotWeaponPreference_ForceMagnum.AddChangeHook(OnConVarChanged);

	g_hCvar_BotWeaponPreference_Nick.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Louis.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Bill.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Rochelle.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Zoey.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Ellis.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Coach.AddChangeHook(OnConVarChanged);
	g_hCvar_BotWeaponPreference_Francis.AddChangeHook(OnConVarChanged);

	g_hCvar_SwapSameTypePrimaries.AddChangeHook(OnConVarChanged);
	g_hCvar_SwapSameTypeGrenades.AddChangeHook(OnConVarChanged);

	g_hCvar_T3_Refill.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxWeaponTier3_M60.AddChangeHook(OnConVarChanged);
	g_hCvar_MaxWeaponTier3_GLauncher.AddChangeHook(OnConVarChanged);

	g_hCvar_Vision_FieldOfView.AddChangeHook(OnConVarChanged);
	g_hCvar_Vision_NoticeTimeScale.AddChangeHook(OnConVarChanged);

	g_hCvar_SpitterAcidEvasion.AddChangeHook(OnConVarChanged);
	g_hCvar_AlwaysCarryProp.AddChangeHook(OnConVarChanged);
	g_hCvar_KeepMovingInCombat.AddChangeHook(OnConVarChanged);
	g_hCvar_SwitchOffCSSWeapons.AddChangeHook(OnConVarChanged);
	g_hCvar_ChargerEvasion.AddChangeHook(OnConVarChanged);
	g_hCvar_DeployUpgradePacks.AddChangeHook(OnConVarChanged);
	g_hCvar_DontSwitchToPistol.AddChangeHook(OnConVarChanged);
	g_hCvar_TakeCoverFromRocks.AddChangeHook(OnConVarChanged);
	g_hCvar_AvoidTanksWithProp.AddChangeHook(OnConVarChanged);
	g_hCvar_NoFallDmgOnLadderFail.AddChangeHook(OnConVarChanged);

	g_hCvar_WitchBehavior_WalkWhenNearby.AddChangeHook(OnConVarChanged);
	g_hCvar_WitchBehavior_AllowCrowning.AddChangeHook(OnConVarChanged);

	g_hCvar_NextProcessTime.AddChangeHook(OnConVarChanged);
	g_hCvar_PerformanceLogging.AddChangeHook(OnPerformanceLoggingChanged);
	g_hCvar_PerformanceThresholdMs.AddChangeHook(OnConVarChanged);
	g_hCvar_Debug.AddChangeHook(OnConVarChanged);
}

public void OnAllPluginsLoaded()
{
	UpdateConVarValues();
}

public void OnConfigsExecuted()
{
	UpdateConVarValues();
	g_bPinnedRescueRecoveryPending = g_bLateLoad;
}

void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	UpdateConVarValues();
	if (convar == g_hCvar_NextProcessTime)
	{
		for (int i = 1; i <= MaxClients; i++)
			g_fClientGlobalInfo_Expiry[i] = 0.0;
	}
	if (convar == g_hCvar_HelpPinnedFriend_ReactionBots)
		RebuildPinnedRescueCoordinator();
}

void UpdateConVarValues()
{
	g_hCvar_GameDifficulty.GetString(g_sCvar_GameDifficulty, sizeof(g_sCvar_GameDifficulty));
	g_iCvar_SurvivorLimpHealth 							= g_hCvar_SurvivorLimpHealth.IntValue;
	g_iCvar_TankRockHealth 								= g_hCvar_TankRockHealth.IntValue;
	g_fCvar_GasCanUseDuration 							= g_hCvar_GasCanUseDuration.FloatValue;
	g_fCvar_ChaseBileRange 								= g_hCvar_ChaseBileRange.FloatValue;
	g_fCvar_ServerGravity 								= g_hCvar_ServerGravity.FloatValue;
	g_fCvar_BileCoverDuration_Bot 						= g_hCvar_BileCoverDuration_Bot.FloatValue;
	g_fCvar_BileCoverDuration_PZ 						= g_hCvar_BileCoverDuration_PZ.FloatValue;

	g_iCvar_MaxAmmo_Pistol								= g_hCvar_MaxAmmo_Pistol.IntValue;
	g_iCvar_MaxAmmo_AssaultRifle						= g_hCvar_MaxAmmo_AssaultRifle.IntValue;
	g_iCvar_MaxAmmo_SMG									= g_hCvar_MaxAmmo_SMG.IntValue;
	g_iCvar_MaxAmmo_M60									= g_hCvar_MaxAmmo_M60.IntValue;
	g_iCvar_MaxAmmo_Shotgun								= g_hCvar_MaxAmmo_Shotgun.IntValue;
	g_iCvar_MaxAmmo_AutoShotgun							= g_hCvar_MaxAmmo_AutoShotgun.IntValue;
	g_iCvar_MaxAmmo_HuntRifle							= g_hCvar_MaxAmmo_HuntRifle.IntValue;
	g_iCvar_MaxAmmo_SniperRifle							= g_hCvar_MaxAmmo_SniperRifle.IntValue;
	g_iCvar_MaxAmmo_PipeBomb							= g_hCvar_MaxAmmo_PipeBomb.IntValue;
	g_iCvar_MaxAmmo_Molotov								= g_hCvar_MaxAmmo_Molotov.IntValue;
	g_iCvar_MaxAmmo_VomitJar							= g_hCvar_MaxAmmo_VomitJar.IntValue;
	g_iCvar_MaxAmmo_PainPills							= g_hCvar_MaxAmmo_PainPills.IntValue;
	g_iCvar_MaxAmmo_GrenLauncher						= g_hCvar_MaxAmmo_GrenLauncher.IntValue;
	g_iCvar_MaxAmmo_Adrenaline							= g_hCvar_MaxAmmo_Adrenaline.IntValue;
	g_iCvar_MaxAmmo_Chainsaw							= g_hCvar_MaxAmmo_Chainsaw.IntValue;
	g_iCvar_MaxAmmo_AmmoPack							= g_hCvar_MaxAmmo_AmmoPack.IntValue;
	g_iCvar_MaxAmmo_Medkit								= g_hCvar_MaxAmmo_Medkit.IntValue;

	char sArgs[32];
	g_hCvar_Ammo_Type_Override.GetString( sArgs, sizeof(sArgs));
	if (strcmp(sArgs, g_sCvar_Ammo_Type_Override))
	{
		PrintToServer("UpdateConVarValues: InitMaxAmmo");
		strcopy(g_sCvar_Ammo_Type_Override, sizeof(g_sCvar_Ammo_Type_Override), sArgs);
		InitMaxAmmo();
	}

	g_bCvar_BotsShootThrough 							= g_hCvar_BotsShootThrough.BoolValue;
	g_bCvar_BotsFriendlyFire 							= g_hCvar_BotsFriendlyFire.BoolValue;
	g_bCvar_BotsDisabled								= g_hCvar_BotsDisabled.BoolValue;
	g_bCvar_BotsDontShoot								= g_hCvar_BotsDontShoot.BoolValue;
	g_fCvar_BotsVomitBlindTime							= g_hCvar_BotsVomitBlindTime.FloatValue;

	g_hCvar_MaxMeleeSurvivors.IntValue					= g_hCvar_ImprovedMelee_MaxCount.IntValue;
	g_iCvar_MaxMeleeSurvivors 							= g_hCvar_MaxMeleeSurvivors.IntValue;

	g_bCvar_ImprovedMelee_Enabled 						= g_hCvar_ImprovedMelee_Enabled.BoolValue;
	g_iCvar_ImprovedMelee_SwitchCount 					= g_hCvar_ImprovedMelee_SwitchCount.IntValue;
	g_iCvar_ImprovedMelee_ShoveChance 					= g_hCvar_ImprovedMelee_ShoveChance.IntValue;
	g_fCvar_ImprovedMelee_SwitchRange 					= (g_hCvar_ImprovedMelee_SwitchRange.FloatValue*g_hCvar_ImprovedMelee_SwitchRange.FloatValue);
	g_fCvar_ImprovedMelee_ApproachRange 				= (g_hCvar_ImprovedMelee_ApproachRange.FloatValue*g_hCvar_ImprovedMelee_ApproachRange.FloatValue);
	g_fCvar_ImprovedMelee_AimRange_Sqr					= (g_hCvar_ImprovedMelee_AimRange.FloatValue*g_hCvar_ImprovedMelee_AimRange.FloatValue);
	g_fCvar_ImprovedMelee_AttackRange 					= g_hCvar_ImprovedMelee_AttackRange.FloatValue;
	g_fCvar_ImprovedMelee_AttackRange_Sqr 				= (g_hCvar_ImprovedMelee_AttackRange.FloatValue * g_hCvar_ImprovedMelee_AttackRange.FloatValue);

	g_iCvar_ImprovedMelee_ChainsawLimit 				= g_hCvar_ImprovedMelee_ChainsawLimit.IntValue;
	g_iCvar_ImprovedMelee_SwitchCount2 					= g_hCvar_ImprovedMelee_SwitchCount2.IntValue;

	g_bCvar_TargetSelection_Enabled						= g_hCvar_TargetSelection_Enabled.BoolValue;
	g_fCvar_TargetSelection_ShootRange					= g_hCvar_TargetSelection_ShootRange.FloatValue;
	g_fCvar_TargetSelection_ShootRange2					= g_hCvar_TargetSelection_ShootRange2.FloatValue;
	g_fCvar_TargetSelection_ShootRange3					= g_hCvar_TargetSelection_ShootRange3.FloatValue;
	g_fCvar_TargetSelection_ShootRange4					= g_hCvar_TargetSelection_ShootRange4.FloatValue;
	g_bCvar_TargetSelection_IgnoreDociles				= g_hCvar_TargetSelection_IgnoreDociles.BoolValue;

	g_bCvar_BotWeaponPreference_ForceMagnum 			= g_hCvar_BotWeaponPreference_ForceMagnum.BoolValue;

	g_iCvar_BotWeaponPreference_Nick 					= g_hCvar_BotWeaponPreference_Nick.IntValue;
	g_iCvar_BotWeaponPreference_Louis 					= g_hCvar_BotWeaponPreference_Louis.IntValue;
	g_iCvar_BotWeaponPreference_Bill 					= g_hCvar_BotWeaponPreference_Bill.IntValue;
	g_iCvar_BotWeaponPreference_Rochelle 				= g_hCvar_BotWeaponPreference_Rochelle.IntValue;
	g_iCvar_BotWeaponPreference_Zoey 					= g_hCvar_BotWeaponPreference_Zoey.IntValue;
	g_iCvar_BotWeaponPreference_Ellis 					= g_hCvar_BotWeaponPreference_Ellis.IntValue;
	g_iCvar_BotWeaponPreference_Coach 					= g_hCvar_BotWeaponPreference_Coach.IntValue;
	g_iCvar_BotWeaponPreference_Francis 				= g_hCvar_BotWeaponPreference_Francis.IntValue;

	g_bCvar_GrenadeThrow_Enabled 						= g_hCvar_GrenadeThrow_Enabled.BoolValue;
	g_iCvar_GrenadeThrow_GrenadeTypes 					= g_hCvar_GrenadeThrow_GrenadeTypes.IntValue;
	g_fCvar_GrenadeThrow_ThrowRange 					= g_hCvar_GrenadeThrow_ThrowRange.FloatValue;
	g_fCvar_GrenadeThrow_HordeSize 						= g_hCvar_GrenadeThrow_HordeSize.FloatValue;
	g_fCvar_GrenadeThrow_NextThrowTime1 				= g_hCvar_GrenadeThrow_NextThrowTime1.FloatValue;
	g_fCvar_GrenadeThrow_NextThrowTime2 				= g_hCvar_GrenadeThrow_NextThrowTime2.FloatValue;

	g_bCvar_TankRock_ShootEnabled						= g_hCvar_TankRock_ShootEnabled.BoolValue;
	g_fCvar_TankRock_ShootRange							= (g_hCvar_TankRock_ShootRange.FloatValue*g_hCvar_TankRock_ShootRange.FloatValue);

	g_bCvar_DefibRevive_Enabled 						= g_hCvar_DefibRevive_Enabled.BoolValue;
	g_fCvar_DefibRevive_ScanDist 						= g_hCvar_DefibRevive_ScanDist.FloatValue;

	g_iCvar_FireBash_Chance1 							= g_hCvar_FireBash_Chance1.IntValue;
	g_iCvar_FireBash_Chance2 							= g_hCvar_FireBash_Chance2.IntValue;

	g_iCvar_AutoShove_Enabled 							= g_hCvar_AutoShove_Enabled.BoolValue;

	g_iCvar_HelpPinnedFriend_Enabled 					= g_hCvar_HelpPinnedFriend_Enabled.IntValue;
	g_iCvar_HelpPinnedFriend_ReactionBots = g_hCvar_HelpPinnedFriend_ReactionBots.IntValue;
	g_fCvar_HelpPinnedFriend_ReactionInterval = g_hCvar_HelpPinnedFriend_ReactionInterval.FloatValue;
	g_fCvar_HelpPinnedFriend_MaxDistance_Sqr = (g_hCvar_HelpPinnedFriend_MaxDistance.FloatValue * g_hCvar_HelpPinnedFriend_MaxDistance.FloatValue);
	g_fCvar_HelpPinnedFriend_ShootRange_Sqr				= (g_hCvar_HelpPinnedFriend_ShootRange.FloatValue * g_hCvar_HelpPinnedFriend_ShootRange.FloatValue);
	g_fCvar_HelpPinnedFriend_ShoveRange_Sqr 			= (g_hCvar_HelpPinnedFriend_ShoveRange.FloatValue * g_hCvar_HelpPinnedFriend_ShoveRange.FloatValue);

	g_iCvar_ItemScavenge_Models 						= g_hCvar_ItemScavenge_Models.IntValue;
	g_iCvar_ItemScavenge_Items 							= g_hCvar_ItemScavenge_Items.IntValue;
	g_fCvar_ItemScavenge_ApproachRange 					= g_hCvar_ItemScavenge_ApproachRange.FloatValue;
	g_fCvar_ItemScavenge_ApproachVisibleRange 			= g_hCvar_ItemScavenge_ApproachVisibleRange.FloatValue;
	g_fCvar_ItemScavenge_PickupRange 					= g_hCvar_ItemScavenge_PickupRange.FloatValue;
	g_fCvar_ItemScavenge_PickupRange_Sqr				= (g_hCvar_ItemScavenge_PickupRange.FloatValue * g_hCvar_ItemScavenge_PickupRange.FloatValue);
	g_fCvar_ItemScavenge_MapSearchRange_Sqr				= (g_hCvar_ItemScavenge_MapSearchRange.FloatValue * g_hCvar_ItemScavenge_MapSearchRange.FloatValue);
	g_fCvar_ItemScavenge_NoHumansRangeMultiplier 		= g_hCvar_ItemScavenge_NoHumansRangeMultiplier.FloatValue;

	g_bCvar_SwapSameTypePrimaries 						= g_hCvar_SwapSameTypePrimaries.BoolValue;
	g_bCvar_SwapSameTypeGrenades 						= g_hCvar_SwapSameTypeGrenades.BoolValue;

	g_iCvar_T3_Refill									= g_hCvar_T3_Refill.IntValue;
	g_iCvar_MaxWeaponTier3_M60 							= g_hCvar_MaxWeaponTier3_M60.IntValue;
	g_iCvar_MaxWeaponTier3_GLauncher 					= g_hCvar_MaxWeaponTier3_GLauncher.IntValue;

	g_fCvar_Vision_FieldOfView 							= g_hCvar_Vision_FieldOfView.FloatValue;
	g_fCvar_Vision_NoticeTimeScale 						= g_hCvar_Vision_NoticeTimeScale.FloatValue;

	g_bCvar_SpitterAcidEvasion							= g_hCvar_SpitterAcidEvasion.BoolValue;
	g_bCvar_AlwaysCarryProp								= g_hCvar_AlwaysCarryProp.BoolValue;
	g_bCvar_SwitchOffCSSWeapons							= g_hCvar_SwitchOffCSSWeapons.BoolValue;
	g_bCvar_ChargerEvasion								= g_hCvar_ChargerEvasion.BoolValue;
	g_bCvar_DeployUpgradePacks							= g_hCvar_DeployUpgradePacks.BoolValue;
	g_bCvar_DontSwitchToPistol							= g_hCvar_DontSwitchToPistol.BoolValue;
	g_bCvar_TakeCoverFromRocks							= g_hCvar_TakeCoverFromRocks.BoolValue;
	g_bCvar_AvoidTanksWithProp							= g_hCvar_AvoidTanksWithProp.BoolValue;
	g_bCvar_NoFallDmgOnLadderFail						= g_hCvar_NoFallDmgOnLadderFail.BoolValue;

	if (g_bMapStarted)
	{
		char sShouldHurryCode[64]; FormatEx(sShouldHurryCode, sizeof(sShouldHurryCode), "DirectorScript.GetDirectorOptions().cm_ShouldHurry <- %i", g_hCvar_KeepMovingInCombat.IntValue);
		L4D2_ExecVScriptCode(sShouldHurryCode);
	}

	g_fCvar_WitchBehavior_WalkWhenNearby = g_hCvar_WitchBehavior_WalkWhenNearby.FloatValue;
	g_iCvar_WitchBehavior_AllowCrowning 				= g_hCvar_WitchBehavior_AllowCrowning.IntValue;

	g_fCvar_NextProcessTime = g_hCvar_NextProcessTime.FloatValue;
	UpdateDegradedConVarValues();
	g_bCvar_PerformanceLogging = g_hCvar_PerformanceLogging.BoolValue;
	g_fCvar_PerformanceThresholdMs = g_hCvar_PerformanceThresholdMs.FloatValue;
	g_bPerformanceBudgetEnabled = g_bCvar_PerformanceLogging;
	g_iCvar_Debug = g_hCvar_Debug.IntValue;
}

Handle g_hCalcAbsolutePosition;

Handle g_hLookupBone;
Handle g_hGetBonePosition;

Handle g_hGetMaxClip1;
Handle g_hFindUseEntity;
Handle g_hIsInCombat;

Handle g_hIsReachableNavArea;
Handle g_hIsAvailable;

Handle g_hMarkNavAreaAsBlocked;

Handle g_hSurvivorLegsRetreat;

int g_iNavArea_Center;
int g_iNavArea_Parent;
int g_iNavArea_NWCorner;
int g_iNavArea_SECorner;
int g_iNavArea_InvDXCorners;
int g_iNavArea_InvDYCorners;
int g_iNavArea_DamagingTickCount;
