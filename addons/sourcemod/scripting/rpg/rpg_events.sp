/* put the line below after all of the includes!
#pragma newdecls required
*/

// Every single event in the events.cfg is called by this function, and then sent off to a specific function.
// This way a separate template isn't required for events that have different event names.
public Action Event_Occurred(Handle event, char[] event_name, bool dontBroadcast) {

	//if (b_IsSurvivalIntermission) return Plugin_Handled;

	int a_Size						= 0;
	a_Size							= GetArraySize(a_Events);

	char EventName[PLATFORM_MAX_PATH];
	int eventresult = 0;


	char CurrMap[64];
	GetCurrentMap(CurrMap, sizeof(CurrMap));

	for (int i = 0; i < a_Size; i++) {

		EventSection						= GetArrayCell(a_Events, i, 2);
		GetArrayString(EventSection, 0, EventName, sizeof(EventName));

		if (StrEqual(EventName, event_name)) {

			//if (Call_Event(event, event_name, dontBroadcast, i) == -1) {

				/*if (StrEqual(EventName, "infected_hurt") || StrEqual(EventName, "player_hurt")) {

					

					//	Returns -1 when infected_hurt or player_hurt and the cause of the damage is not a common infected or a player
					//	or if the damage is "inferno" which can be discerned through the player_hurt event only; we have to resort to
					//	the prior for infected_hurt
					

					return Plugin_Handled;
				}*/
			//}
			eventresult = Call_Event(event, event_name, dontBroadcast, i);
			break;
		}
	}
	//if (StrEqual(EventName, "player_shoved", false)) PrintToChatAll("player shoved!");
	//if (StrEqual(EventName, "entity_shoved", false)) PrintToChatAll("entity shoved!");
	if (StrContains(EventName, "finale_radio_start", false) != -1) return Plugin_Continue;
	if (eventresult == -1 && b_IsActiveRound) return Plugin_Handled;
	return Plugin_Continue;
	//if (StrEqual(EventName, "infected_hurt") || StrEqual(EventName, "player_hurt")) return Plugin_Handled;
	//else return Plugin_Continue;
}

public SubmitEventHooks(value) {

	int size = GetArraySize(a_Events);
	char text[64];

	for (int i = 0; i < size; i++) {

		HookSection = GetArrayCell(a_Events, i, 2);
		GetArrayString(HookSection, 0, text, sizeof(text));
		if (StrEqual(text, "player_hurt", false) ||
			StrEqual(text, "infected_hurt", false)) {

			if (value == 0) UnhookEvent(text, Event_Occurred, EventHookMode_Pre);
			else HookEvent(text, Event_Occurred, EventHookMode_Pre);
		}
		else {

			if (value == 0) UnhookEvent(text, Event_Occurred);
			else HookEvent(text, Event_Occurred);
		}
	}
}

public Call_Event(Handle event, char[] event_name, bool dontBroadcast, pos) {
	//CallKeys							= GetArrayCell(a_Events, pos, 0);
	CallValues							= GetArrayCell(a_Events, pos, 1);
	char ThePerp[64];
	GetArrayString(CallValues, EVENT_PERPETRATOR, ThePerp, sizeof(ThePerp));
	int attacker = GetClientOfUserId(GetEventInt(event, ThePerp));
	GetArrayString(CallValues, EVENT_VICTIM, ThePerp, sizeof(ThePerp));
	int victim = GetClientOfUserId(GetEventInt(event, ThePerp));
	bool IsLegitimateClientAttacker = IsLegitimateClient(attacker);
	int attackerTeam = -1;
	int attackerZombieClass = -1;
	bool IsFakeClientAttacker = false;
	if (IsLegitimateClientAttacker) {
		attackerTeam = myCurrentTeam[attacker];
		IsFakeClientAttacker = IsFakeClient(attacker);
		attackerZombieClass = FindZombieClass(attacker);
	}
	int victimType = -1;
	int victimTeam = -1;
	//new bool:IsFakeClientVictim = false;
	if (IsCommonInfected(victim)) victimType = 0;
	else if (IsWitch(victim)) victimType = 1;
	else if (IsLegitimateClient(victim)) {
		victimType = 2;
		victimTeam = myCurrentTeam[victim];
		//IsFakeClientVictim = IsFakeClient(victim);
	}
	if (IsLegitimateClientAttacker) {
		if (victimType != -1) {
			if (victimType == 1 && FindListPositionByEntity(victim, WitchList) < 0) OnWitchCreated(victim);
			char abilityTriggerActivator[64];
			char abilityTriggerTarget[64];
			GetArrayString(CallValues, EVENT_PERPETRATOR_TEAM_REQ, abilityTriggerActivator, sizeof(abilityTriggerActivator));
			if (!StrEqual(abilityTriggerActivator, "-1")) {
				Format(ThePerp, sizeof(ThePerp), "%d", attackerTeam);
				if (StrContains(abilityTriggerActivator, ThePerp) != -1) {
					GetArrayString(CallValues, EVENT_PERPETRATOR_ABILITY_TRIGGER, abilityTriggerActivator, sizeof(abilityTriggerActivator));
					if (!StrEqual(abilityTriggerActivator, "-1")) GetAbilityStrengthByTrigger(attacker, victim, abilityTriggerActivator);
				}
			}
			GetArrayString(CallValues, EVENT_VICTIM_TEAM_REQ, abilityTriggerTarget, sizeof(abilityTriggerTarget));
			if (!StrEqual(abilityTriggerTarget, "-1")) {
				Format(ThePerp, sizeof(ThePerp), "%d", victimTeam);
				if (StrContains(abilityTriggerTarget, ThePerp) != -1) {
					GetArrayString(CallValues, EVENT_VICTIM_ABILITY_TRIGGER, abilityTriggerTarget, sizeof(abilityTriggerTarget));
					if (!StrEqual(abilityTriggerTarget, "-1")) GetAbilityStrengthByTrigger(victim, attacker, abilityTriggerTarget);
				}
			}
		}
		if (StrEqual(event_name, "defibrillator_used")) {
			int oldrating = GetArrayCell(tempStorage, victim, 0);
			int oldhandicap = GetArrayCell(tempStorage, victim, 1);
			float oldmultiplier = GetArrayCell(tempStorage, victim, 2);
			Rating[victim] = oldrating;
			handicapLevel[victim] = oldhandicap;
			RoundExperienceMultiplier[victim] = oldmultiplier;
			PrintToChatAll("%t", "rise again", white, orange, white);
		}
		if (StrEqual(event_name, "ammo_pickup")) {
			GiveAmmoBack(attacker, 999);	// whenever a player picks up an ammo pile, we want to give them their full ammo reserves - vanilla + talents.
		}
	}
	char weapon[64];
	if (StrEqual(event_name, "player_left_start_area") && IsLegitimateClientAttacker) {
		if (attackerTeam == TEAM_SURVIVOR) {
			//if (IsFakeClientAttacker && attackerTeam == TEAM_SURVIVOR && !b_IsLoaded[attacker]) IsClientLoadedEx(attacker);
			if (b_IsInSaferoom[attacker]) {
				b_IsInSaferoom[attacker] = false;
			}
		}
	}
	if (b_IsActiveRound && IsLegitimateClientAttacker) {
		char[] messageToSendToClient = new char[MAX_CHAT_LENGTH];
		if (StrEqual(event_name, "player_entered_checkpoint")) {
			if (!IsFakeClient(attacker) && !bIsInCheckpoint[attacker]) {
				Format(messageToSendToClient, MAX_CHAT_LENGTH, "{B} Your damage/experience is {O}DISABLED {B}while in the safe room.");
				Client_PrintToChat(attacker, true, messageToSendToClient);
			}
			bIsInCheckpoint[attacker] = true;
		}
		if (StrEqual(event_name, "player_left_checkpoint")) {
			if (!IsFakeClient(attacker) && bIsInCheckpoint[attacker]) {
				Format(messageToSendToClient, MAX_CHAT_LENGTH, "{B}You have left the safe area. {O}Your damage/experience is {B}ENABLED.");
				Client_PrintToChat(attacker, true, messageToSendToClient);
			}
			bIsInCheckpoint[attacker] = false;
		}
	}
	if (StrEqual(event_name, "player_incapacitated")) {
		IncapacitateOrKill(victim, attacker);
	}
	if (StrEqual(event_name, "player_spawn")) {
		if (IsLegitimateClientAttacker) {
			ClearArray(ActiveStatuses[attacker]);
			myCurrentTeam[attacker] = GetClientTeam(attacker);
			if (myCurrentTeam[attacker] != TEAM_SPECTATOR && !b_IsHooked[attacker]) ChangeHook(attacker, true);
			if (attackerTeam == TEAM_SURVIVOR) {
				RefreshSurvivor(attacker);
				RaidInfectedBotLimit();
				ResetContributionTracker(attacker);
			}
			else {
				int damagePos = FindListPositionByEntity(attacker, damageOfSpecialInfected);
				if (damagePos == -1) {
					damagePos = GetArraySize(damageOfSpecialInfected);
					ResizeArray(damageOfSpecialInfected, damagePos+1);
					SetArrayCell(damageOfSpecialInfected, damagePos, attacker);
				}
				SetArrayCell(damageOfSpecialInfected, damagePos, 0, 1);
				DamageContribution[attacker] = 0;
				//SetInfectedHealth(attacker, 99999);
				if (!IsFakeClientAttacker) PlayerSpawnAbilityTrigger(attacker);
				ClearArray(PlayerAbilitiesCooldown[attacker]);
				ClearArray(InfectedHealth[attacker]);
				ResizeArray(InfectedHealth[attacker], 1);	// infected player stores their actual health (from talents, abilities, etc.) locally...
				bHealthIsSet[attacker] = false;
				//if (!b_IsHooked[attacker]) {
				CreateMyHealthPool(attacker);
				//}
				if (attackerZombieClass == ZOMBIECLASS_TANK) {
					ClearArray(TankState_Array[attacker]);
					bHasTeleported[attacker] = false;
					if (iTanksPreset == 1) {
						int iRand = GetRandomInt(1, 3);
						if (iRand == 1) ChangeTankState(attacker, "hulk");
						else if (iRand == 2) ChangeTankState(attacker, "death");
						else if (iRand == 3) ChangeTankState(attacker, "burn");
					}
				}
				InitInfectedHealthForSurvivors(attacker);
			}
		}
	}
	if (!b_IsActiveRound || IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR && !b_IsLoaded[attacker]) return 0;		// don't track ANYTHING when it's not an active round.
	char curEquippedWeapon[64];
	if (StrEqual(event_name, "weapon_reload") || StrEqual(event_name, "bullet_impact")) {
		int WeaponId =	GetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon");
		if (IsValidEntity(WeaponId)) GetEntityClassname(WeaponId, curEquippedWeapon, sizeof(curEquippedWeapon));
		else Format(curEquippedWeapon, sizeof(curEquippedWeapon), "-1");
	}
	if (victimTeam == TEAM_SURVIVOR) {
		if (StrEqual(event_name, "revive_success")) {
			if (attacker != victim) {
				GetAbilityStrengthByTrigger(victim, attacker, "R", _, 0);
				GetAbilityStrengthByTrigger(attacker, victim, "r", _, 0);
			}
			SetEntPropEnt(victim, Prop_Send, "m_reviveOwner", -1);
			SetEntPropEnt(attacker, Prop_Send, "m_reviveTarget", -1);
			int reviveOwner = GetEntPropEnt(victim, Prop_Send, "m_reviveOwner");
			if (IsLegitimateClient(reviveOwner)) SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
			GiveMaximumHealth(victim);
		}
	}
	GetArrayString(CallValues, EVENT_DAMAGE_TYPE, ThePerp, sizeof(ThePerp));
	int damagetype = GetEventInt(event, ThePerp);
	if (StrEqual(event_name, "finale_radio_start") && !b_IsFinaleActive) {
		// When the finale is active, players can earn experience whilst camping (not moving from a spot, re: farming)
		b_IsFinaleActive = true;
		if (GetInfectedCount(ZOMBIECLASS_TANK) < 1) b_IsFinaleTanks = true;
		if (iTankRush == 1) {
			PrintToChatAll("%t", "the zombies are coming", blue, orange, blue);
			ExecCheatCommand(FindAnyRandomClient(), "director_force_panic_event");
		}
	}
	if (StrEqual(event_name, "finale_vehicle_ready")) {
		// When the vehicle arrives, the finale is no longer active, but no experience can be earned. This stops farming.
		if (b_IsFinaleActive) {
			b_IsFinaleActive = false;
			b_IsRescueVehicleArrived = true;
		}
		//PrintToChatAll("%t", "Experience Gains Disabled", orange, white, orange, white, blue);
	}
	// Declare the values that can be defined by the event config, so we know whether to consider them.
	//new RPGMode						= iRPGMode;	// 1 experience 2 experience & points
	char AbilityUsed[PLATFORM_MAX_PATH];
	char abilities[PLATFORM_MAX_PATH];
	GetArrayString(CallValues, EVENT_GET_HEALTH, ThePerp, sizeof(ThePerp));
	int healthvalue = GetEventInt(event, ThePerp);
	int isdamageaward = GetArrayCell(CallValues, EVENT_DAMAGE_AWARD);
	GetArrayString(CallValues, EVENT_GET_ABILITIES, abilities, sizeof(abilities));
	int tagability = GetArrayCell(CallValues, EVENT_IS_PLAYER_NOW_IT);
	int originvalue = GetArrayCell(CallValues, EVENT_IS_ORIGIN);
	int distancevalue = GetArrayCell(CallValues, EVENT_IS_DISTANCE);
	float multiplierpts = GetArrayCell(CallValues, EVENT_MULTIPLIER_POINTS);
	float multiplierexp = GetArrayCell(CallValues, EVENT_MULTIPLIER_EXPERIENCE);
	int isshoved = GetArrayCell(CallValues, EVENT_IS_SHOVED);
	int bulletimpact = GetArrayCell(CallValues, EVENT_IS_BULLET_IMPACT);
	int isinsaferoom = GetArrayCell(CallValues, EVENT_ENTERED_SAFEROOM);
	if (bulletimpact == 1) {
		if (attackerTeam == TEAM_SURVIVOR) {
			int bulletsFired = 0;
			if (!StrEqual(curEquippedWeapon, "-1")) {
				GetTrieValue(currentEquippedWeapon[attacker], curEquippedWeapon, bulletsFired);
				SetTrieValue(currentEquippedWeapon[attacker], curEquippedWeapon, bulletsFired + 1);
			}
			float Coords[3];
			Coords[0] = GetEventFloat(event, "x");
			Coords[1] = GetEventFloat(event, "y");
			Coords[2] = GetEventFloat(event, "z");
			//new Float:TargetPos[3];
			//new target = GetAimTargetPosition(attacker, TargetPos);
			//if (AllowShotgunToTriggerNodes(attacker)) LastWeaponDamage[attacker] = GetBaseWeaponDamage(attacker, target, Coords[0], Coords[1], Coords[2], damagetype);
			//LastWeaponDamage[attacker] = GetBaseWeaponDamage(attacker, target, Coords[0], Coords[1], Coords[2], damagetype);	// expensive way
			// better way because events fire after ontakedamage, so lastBaseDamage[attacker] IS the above methods most-recent result.
			LastWeaponDamage[attacker] = lastBaseDamage[attacker];
			if (iIsBulletTrails[attacker] == 1) {
				float EyeCoords[3];
				GetClientEyePosition(attacker, EyeCoords);
				// Adjust the coords so they line up with the gun
				EyeCoords[2] -= 10.0;
				int TrailsColours[4];
				TrailsColours[3] = 200;
				char ClientModel[64];
				char TargetModel[64];
				GetClientModel(attacker, ClientModel, sizeof(ClientModel));
				int bulletsize		= GetArraySize(a_Trails);
				for (int i = 0; i < bulletsize; i++) {
					TrailsKeys[attacker] = GetArrayCell(a_Trails, i, 0);
					TrailsValues[attacker] = GetArrayCell(a_Trails, i, 1);
					FormatKeyValue(TargetModel, sizeof(TargetModel), TrailsKeys[attacker], TrailsValues[attacker], "model affected?");
					if (StrEqual(TargetModel, ClientModel)) {
						TrailsColours[0]		= GetKeyValueInt(TrailsKeys[attacker], TrailsValues[attacker], "red?");
						TrailsColours[1]		= GetKeyValueInt(TrailsKeys[attacker], TrailsValues[attacker], "green?");
						TrailsColours[2]		= GetKeyValueInt(TrailsKeys[attacker], TrailsValues[attacker], "blue?");
						break;
					}
				}
				for (int i = 1; i <= MaxClients; i++) {
					if (IsLegitimateClient(i) && !IsFakeClient(i)) {
						TE_SetupBeamPoints(EyeCoords, Coords, g_iSprite, 0, 0, 0, 0.06, 0.09, 0.09, 1, 0.0, TrailsColours, 0);
						TE_SendToClient(i);
					}
				}
			}
		}
	}
	// if (StrEqual(event_name, "player_hurt") || StrEqual(event_name, "infected_hurt")) {
	// 	if (IsLegitimateClientAttacker) {
	// 		if (!CheckIfHeadshot(attacker, victim, event, healthvalue))	CheckIfLimbDamage(attacker, victim, event, healthvalue);
	// 		/*if (IsPlayerUsingShotgun(attacker)) {
	// 			if (shotgunCooldown[attacker]) return 0;
	// 			shotgunCooldown[attacker] = true;
	// 			CreateTimer(0.1, Timer_ResetShotgunCooldown, attacker, TIMER_FLAG_NO_MAPCHANGE);
	// 		}*/
	// 	}
	// 	//if (victimType == 2 && !b_IsHooked[victim]) ChangeHook(victim, true);
	// 	//if (IsLegitimateClientAlive(victim) && GetClientTeam(victim) == TEAM_SURVIVOR && !b_IsHooked[victim]) ChangeHook(victim, true);
	// 	//if (IsLegitimateClientAttacker && IsFakeClientAttacker && attackerTeam == TEAM_SURVIVOR && !b_IsLoaded[attacker]) IsClientLoadedEx(attacker);
	// 	//if (victimTeam == TEAM_SURVIVOR && IsFakeClientVictim && !b_IsLoaded[victim]) IsClientLoadedEx(victim);
	// }
	// if (victimTeam == TEAM_INFECTED) {
	// 	SetEntityHealth(victim, 400000);
	// }
	if (tagability == 1 && victimType == 2) {
		if (!ISBILED[victim]) CreateTimer(15.0, Timer_RemoveBileStatus, victim, TIMER_FLAG_NO_MAPCHANGE);
		ISBILED[victim] = true;
	}
	if (tagability == 2 && IsLegitimateClientAttacker) ISBILED[attacker] = false;
	if (isdamageaward == 1) {
		if (IsLegitimateClientAttacker && victimType == 2 && attackerTeam == victimTeam) {
			if (!(damagetype & DMG_BURN) && !StrEqual(weapon, "inferno")) {
				// damage-based triggers now only occur under the circumstances in the code above. No longer do we have triggers for same-team damaging. Maybe at a later date, but it will not be the same ability trigger.
				GetAbilityStrengthByTrigger(attacker, victim, "d", _, healthvalue);
				GetAbilityStrengthByTrigger(victim, attacker, "l", _, healthvalue);
			}
			else ReadyUp_NtvFriendlyFire(attacker, victim, healthvalue, GetClientHealth(victim), 1, 0);
		}
		//if (victimType == 2 && victimTeam == TEAM_INFECTED) SetEntityHealth(victim, 40000);
		if (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR && isinsaferoom == 1) bIsInCheckpoint[attacker] = true;
	}
	if (isshoved == 1 && victimType == 2 && IsLegitimateClientAttacker && victimTeam != attackerTeam) {
		if (victimTeam == TEAM_INFECTED) SetEntityHealth(victim, GetClientHealth(victim) + healthvalue);
		GetAbilityStrengthByTrigger(victim, attacker, "H", _, 0);
	}
	if (isshoved == 2 && IsLegitimateClientAttacker && victimType == 0 && !IsCommonStaggered(victim)) {
		int staggeredSize = GetArraySize(StaggeredTargets);
		ResizeArray(StaggeredTargets, staggeredSize + 1);
		SetArrayCell(StaggeredTargets, staggeredSize, victim, 0);
		SetArrayCell(StaggeredTargets, staggeredSize, 2.0, 1);
	}
	if (StrEqual(event_name, "weapon_reload")) {
		if (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR) {
			ConsecutiveHits[attacker] = 0;	// resets on reload.
			RemoveFromTrie(currentEquippedWeapon[attacker], curEquippedWeapon);
		}
	}
	if (StrEqual(event_name, "player_spawn") && IsLegitimateClientAttacker && attackerTeam == TEAM_INFECTED) {
		if (IsFakeClientAttacker) {
			int changeClassId = 0;
			if (iSpecialsAllowed == 0 && attackerZombieClass != ZOMBIECLASS_TANK) {
				ForcePlayerSuicide(attacker);
			}
			else SetClientTalentStrength(attacker, true);
			if (iSpecialsAllowed == 1 && !StrEqual(sSpecialsAllowed, "-1")) {
				char myClass[5];
				Format(myClass, sizeof(myClass), "%d", attackerZombieClass);
				if (StrContains(sSpecialsAllowed, myClass) == -1) {
					while (StrContains(sSpecialsAllowed, myClass) == -1) {
						changeClassId = GetRandomInt(1,6);
						Format(myClass, sizeof(myClass), "%d", changeClassId);
					}
					ChangeInfectedClass(attacker, changeClassId);
				}
			}
			// In solo games, we restrict the number of ensnarement infected.
			IsAirborne[attacker] = false;
			b_GroundRequired[attacker] = false;
			HasSeenCombat[attacker] = false;
			MyBirthday[attacker] = GetTime();
			int iTankCount = GetInfectedCount(ZOMBIECLASS_TANK);
			int iTankLimit = DirectorTankLimit();
			int theClient = FindAnyRandomClient();
			int iSurvivors = TotalHumanSurvivors();
			int iSurvivorBots = TotalSurvivors() - iSurvivors;
			int iLivSurvs = LivingSurvivorCount();
			if (iSurvivorBots >= 2) iSurvivorBots /= 2;
			int requiredTankCount = GetAlwaysTanks(iSurvivors);
			if (attackerZombieClass == ZOMBIECLASS_TANK) {
				if (b_IsFinaleActive && b_IsFinaleTanks) {
					b_IsFinaleTanks = false;
					int numTanksToSpawnOnFinale = LivingHumanSurvivors()/2;
					if (numTanksToSpawnOnFinale > 4) numTanksToSpawnOnFinale = 4;
					else if (numTanksToSpawnOnFinale < 1) numTanksToSpawnOnFinale = 1;
					for (int i = 0; i + iTankCount < numTanksToSpawnOnFinale; i++) {
						ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
					}
				}
				/*else {
					if (iTankCount > iTankLimit || f_TankCooldown != -1.0) {

						//PrintToChatAll("killing tank.");
						//ForcePlayerSuicide(attacker);
					}
				}*/
			}
			if (iNoSpecials == 1 || iTankRush == 1) {
				if (attackerZombieClass != ZOMBIECLASS_TANK) {
					//if (!IsEnrageActive())
					ForcePlayerSuicide(attacker);
					if (iSurvivors >= 1 && (iTankCount < requiredTankCount || !b_IsFinaleActive && iTankCount < iTankLimit)) {
						ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
					}
				}
			}
			else if (iEnsnareRestrictions == 1 && attackerZombieClass != ZOMBIECLASS_TANK) {
				int iEnsnaredCount = EnsnaredInfected();
				int livingSurvivors = LivingHumanSurvivors();
				int ensnareBonus = (livingSurvivors > 1) ? livingSurvivors - 1 : 0;
				if (IsEnsnarer(attacker)) {
					if (iInfectedLimit == -2 && iEnsnaredCount > RaidCommonBoost(_, true) + ensnareBonus ||
					iInfectedLimit == -1 ||
					iInfectedLimit == 0 && iEnsnaredCount > livingSurvivors ||
					iInfectedLimit > 0 && iEnsnaredCount > iInfectedLimit ||
					iIsLifelink > 1 && iLivSurvs < iIsLifelink && iLivSurvs < iMinSurvivors) {
						while (IsEnsnarer(attacker, changeClassId)) {
							changeClassId = GetRandomInt(1,6);
						}
						ChangeInfectedClass(attacker, changeClassId);
					}
					else ChangeInfectedClass(attacker, _, true);	// doesn't change class but sets base health and speeds.
				}
				else ChangeInfectedClass(attacker, _, true);
			}
			else ChangeInfectedClass(attacker, _, true);
		}
		else SetSpecialInfectedHealth(attacker, attackerZombieClass);
	}
	if (StrEqual(event_name, "ability_use")) {
		if (attackerTeam == TEAM_INFECTED) {
			GetAbilityStrengthByTrigger(attacker, victim, "infected_abilityuse");
			GetEventString(event, "ability", AbilityUsed, sizeof(AbilityUsed));
			if (StrContains(AbilityUsed, "ability_throw") != -1) {
				if (!(GetEntityFlags(attacker) & FL_ONFIRE) && !SurvivorsInRange(attacker, 1024.0)) ChangeTankState(attacker, "burn");
				else {
					ChangeTankState(attacker, "hulk");
					if (!SurvivorsInRange(attacker, fForceTankJumpRange)) ForceClientJump(attacker, fForceTankJumpHeight);
				}
			}
			/*if (StrContains(AbilityUsed, abilities, false) != -1) {

				if (FindZombieClass(attacker) == ZOMBIECLASS_HUNTER) PrintToChatAll("Pouncing!");

				// check for any abilities that are based on abilityused.
				GetClientAbsOrigin(attacker, Float:f_OriginStart[attacker]);
				//GetAbilityStrengthByTrigger(attacker, 0, 'A', FindZombieClass(attacker), healthvalue);
				GetAbilityStrengthByTrigger(attacker, _, 'A', FindZombieClass(attacker), healthvalue);	// activator, target, trigger ability, effects, zombieclass, damage
			}*/
		}
	}
	if (IsLegitimateClientAttacker && attackerTeam == TEAM_INFECTED) {
		float Distance = 0.0;
		float fTalentStrength = 0.0;
		if (originvalue > 0 || distancevalue > 0) {
			if (originvalue == 1 || distancevalue == 1) {
				GetClientAbsOrigin(attacker, f_OriginStart[attacker]);
				if (attackerZombieClass != ZOMBIECLASS_HUNTER &&
					attackerZombieClass != ZOMBIECLASS_SPITTER) {
					fTalentStrength = GetAbilityStrengthByTrigger(attacker, _, "Q", _, 0);
				}
				if (attackerZombieClass == ZOMBIECLASS_HUNTER) {
					// check for any abilities that are based on abilityused.
					GetClientAbsOrigin(attacker, f_OriginStart[attacker]);
					//GetAbilityStrengthByTrigger(attacker, 0, 'A', FindZombieClass(attacker), healthvalue);
					GetAbilityStrengthByTrigger(attacker, _, "A", _, healthvalue);
				}
				if (attackerZombieClass == ZOMBIECLASS_CHARGER) {
					CreateTimer(0.1, Timer_ChargerJumpCheck, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if (originvalue == 2 || distancevalue == 2) {
				int ensnareVictim = L4D2_GetSurvivorVictim(attacker);
				fTalentStrength = GetAbilityStrengthByTrigger(attacker, _, "q", _, 0);
				if (CheckActiveStatuses(attacker, "lunge", false, true) == 0) {
					SetEntityRenderMode(attacker, RENDER_NORMAL);
					SetEntityRenderColor(attacker, 255, 255, 255, 255);
					fTalentStrength += GetAbilityStrengthByTrigger(attacker, _, "A", _, 0);
					if (ensnareVictim != -1) GetAbilityStrengthByTrigger(attacker, ensnareVictim, "pounced", _, lastHealthDamage[ensnareVictim][attacker]);
				}
				GetClientAbsOrigin(attacker, f_OriginEnd[attacker]);
				if (victimType == 2 && victimTeam == TEAM_SURVIVOR) {
					Distance = GetVectorDistance(f_OriginStart[attacker], f_OriginEnd[attacker]);
					if (fTalentStrength > 0.0) Distance += (Distance * fTalentStrength);
					//SetClientTotalHealth(victim, RoundToCeil(Distance), _, true);
					if (ensnareVictim != -1) GetAbilityStrengthByTrigger(attacker, ensnareVictim, "distance", _, RoundToCeil(Distance));
				}
			}
			if (attackerZombieClass == ZOMBIECLASS_JOCKEY || (distancevalue == 2 && t_Distance[attacker] > 0)) {
				if (distancevalue == 1) t_Distance[attacker] = GetTime();
				if (distancevalue == 2) {
					t_Distance[attacker] = GetTime() - t_Distance[attacker];
					multiplierexp *= t_Distance[attacker];
					multiplierpts *= t_Distance[attacker];
					t_Distance[attacker] = 0;
				}
			}
			else {
				if (distancevalue == 3 && victimType == 2) GetClientAbsOrigin(victim, f_OriginStart[attacker]);
				if (distancevalue == 2 || originvalue == 2 || distancevalue == 4 && victimType == 2) {
					if (distancevalue == 4) GetClientAbsOrigin(victim, f_OriginEnd[attacker]);
					//new Float:Distance = GetVectorDistance(f_OriginStart[attacker], f_OriginEnd[attacker]);
					multiplierexp *= Distance;
					multiplierpts *= Distance;
				}
			}
			if (originvalue == 2 || distancevalue == 2 || distancevalue == 4) {
				if (iRPGMode >= 1 && multiplierexp > 0.0 && (iExperienceLevelCap < 1 || PlayerLevel[attacker] < iExperienceLevelCap)) {
					ExperienceLevel[attacker] += RoundToCeil(multiplierexp);
					ExperienceOverall[attacker] += RoundToCeil(multiplierexp);
					ConfirmExperienceAction(attacker);
					if (iAwardBroadcast > 0 && !IsFakeClientAttacker) PrintToChat(attacker, "%T", "distance experience", attacker, white, green, RoundToCeil(multiplierexp), white);
				}
				if (iRPGMode != 1 && multiplierpts > 0.0) {

					Points[attacker] += multiplierpts;
					if (iAwardBroadcast > 0 && !IsFakeClientAttacker) PrintToChat(attacker, "%T", "distance points", attacker, white, green, multiplierpts, white);
				}
			}
		}
	}
	return 0;
}

// stock bool AddOTEffect(client, target, char[] clientSteamID, float fStrength, OTtype = 0) {
// 	float fClientStrength = 0.0;
// 	float fTargetStrength = 0.0;
// 	float fIntervalTime = 0.0;
// 	//new Float:fCurrentEffectStrength = 0.0;
// 	int iNewEffectStrength = 0;
// 	char SearchKey[64];
// 	GetClientAuthId(target, AuthId_Steam2, SearchKey, sizeof(SearchKey));
// 	Format(SearchKey, sizeof(SearchKey), "%s:%s:%d", clientSteamID, SearchKey, OTtype);
// 	if (OTtype == 0) {
// 		fClientStrength = GetAbilityStrengthByTrigger(client, client, "outhealingbonus", _, 0, _, _, "d", 1, true);	// we need a way to return a default value if there are no points in a category without using global variables. delete when this is solved.
// 		fIntervalTime	= GetAbilityStrengthByTrigger(client, client, "healingtickrate", _, 0, _, _, "d", 1, true);
// 		fTargetStrength = GetAbilityStrengthByTrigger(target, target, "inchealingbonus", _, 0, _, _, "d", 1, true);
// 		iNewEffectStrength = RoundToCeil((fClientStrength + fTargetStrength) * fStrength);	// uhhhhhhh this is a balance modifier for PvE/PvP
// 	}
// 	else if (OTtype == 1) {
// 		fClientStrength = GetAbilityStrengthByTrigger(client, client, "outdamagebonus", _, 0, _, _, "d", 1, true);
// 		fIntervalTime	= GetAbilityStrengthByTrigger(client, client, "damagetickrate", _, 0, _, _, "d", 1, true);
// 		fTargetStrength = GetAbilityStrengthByTrigger(target, target, "incdamagebonus", _, 0, _, _, "d", 1, true);
// 	}
// 	int size = GetArraySize(EffectOverTime);
// 	ResizeArray(EffectOverTime, size + 1);
// 	SetArrayCell(EffectOverTime, size, fIntervalTime, 0);
// 	SetArrayCell(EffectOverTime, size, fIntervalTime, 1);
// 	SetArrayCell(EffectOverTime, size, iNewEffectStrength, 2);
// 	GetAbilityStrengthByTrigger(client, client, "damagebonus", _, 0, _, _, "d", 1, true);
// }

public Action Timer_ChargerJumpCheck(Handle timer, any client) {

	if (IsClientInGame(client) && IsFakeClient(client) && myCurrentTeam[client] == TEAM_INFECTED) {

		if (FindZombieClass(client) != ZOMBIECLASS_CHARGER || !IsPlayerAlive(client)) return Plugin_Stop;
		int victim = L4D2_GetSurvivorVictim(client);
		if (victim == -1) return Plugin_Continue;
		if ((GetEntityFlags(client) & FL_ONGROUND)) {

			GetAbilityStrengthByTrigger(client, victim, "v", _, 0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

stock bool PlayerCastSpell(client) {

	int CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

	if (!IsValidEntity(CurrentEntity) || CurrentEntity < 1) return false;
	char EntityName[64];


	GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));

	int Entity					=	CreateEntityByName(EntityName);
	DispatchSpawn(Entity);

	float Origin[3];
	GetClientAbsOrigin(client, Origin);

	Origin[2] += 64.0;

	TeleportEntity(Entity, Origin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(Entity, MOVETYPE_VPHYSICS);

	if (GetWeaponSlot(Entity) < 2) SetEntProp(Entity, Prop_Send, "m_iClip1", GetEntProp(CurrentEntity, Prop_Send, "m_iClip1"));
	AcceptEntityInput(CurrentEntity, "Kill");

	return true;
}

stock CreateGravityAmmo(client, float Force, Range, bool UseTheForceLuke=false) {

	int entity		= CreateEntityByName("point_push");
	if (!IsValidEntity(entity)) return -1;
	char value[64];

	float Origin[3];
	float Angles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
	Angles[0] += -90.0;

	DispatchKeyValueVector(entity, "origin", Origin);
	DispatchKeyValueVector(entity, "angles", Angles);
	Format(value, sizeof(value), "%d", Range / 2);
	DispatchKeyValue(entity, "radius", value);
	if (!UseTheForceLuke) DispatchKeyValueFloat(entity, "magnitude", Force * -1.0);
	else DispatchKeyValueFloat(entity, "magnitude", Force);
	DispatchKeyValue(entity, "spawnflags", "8");
	AcceptEntityInput(entity, "Enable");
	return entity;
}

stock bool GetActiveSpecialAmmoType(client, effect) {

	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", effect);
	char TheAmmoEffect[10];
	GetSpecialAmmoEffect(TheAmmoEffect, sizeof(TheAmmoEffect), client, ActiveSpecialAmmo[client]);

	if (StrContains(TheAmmoEffect, EffectT, true) != -1) return true;
	return false;
}

stock bool IsClientInRangeSpecialAmmoBoolean(client, char[] EffectT = "any") {
	if (client < 1) return false;
	if (GetArraySize(SpecialAmmoData) < 1) return false;
	bool clientIsLegitimate = IsLegitimateClient(client);
	//decl String:EffectT[4];
	if (clientIsLegitimate && !IsPlayerAlive(client)) return false;
	float ClientPos[3];
	if (clientIsLegitimate) GetClientAbsOrigin(client, ClientPos);
	else {
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	}
	for (int i = 0; i < GetArraySize(SpecialAmmoData); i++) {
		float EntityPos[3];
		char TalentInfo[4][512];
		char value[10];
		//if (i < 0) i = 0;
		// TalentInfo[0] = TalentName of ammo.
		// TalentInfo[1] = Talent Strength (so use StringToInt)
		// TalentInfo[2] = Talent Damage
		// TalentInfo[3] = Talent Interval
		int owner = FindClientByIdNumber(GetArrayCell(SpecialAmmoData, i, 7));
		int pos			= GetArrayCell(SpecialAmmoData, i, 3);
		if (!StrEqual(EffectT, "any")) {
			IsClientInRangeSAValues[owner]				= GetArrayCell(a_Menu_Talents, pos, 1);
			GetArrayString(IsClientInRangeSAValues[owner], SPELL_AMMO_EFFECT, value, sizeof(value));
			if (StrContains(EffectT, value, true) == -1) continue;	// a talent could allow multiple ammo types through. e.g. EffectT = bh (bean bag or heal)
		}
		GetArrayString(a_Database_Talents, pos, TalentInfo[0], sizeof(TalentInfo[]));
		//GetTalentNameAtMenuPosition(owner, pos, TalentInfo[0], sizeof(TalentInfo[]));

		float t_Range		= GetSpecialAmmoStrength(owner, TalentInfo[0], 3, _, _, pos);
		EntityPos[0] = GetArrayCell(SpecialAmmoData, i, 0);
		EntityPos[1] = GetArrayCell(SpecialAmmoData, i, 1);
		EntityPos[2] = GetArrayCell(SpecialAmmoData, i, 2);
		if (GetVectorDistance(ClientPos, EntityPos) > (t_Range / 2)) continue;
		return true;
	}
	return false;
}

/*

	Checks whether a player is within range of a special ammo, and if they are, how affected they are.
	GetStatusOnly is so we know whether to start the revive bar for revive ammo, without triggering the actual effect, we just want to know IF they're affected, for example.
	If ammoposition is >= 0 AND GetStatus is enabled, it will return only for the ammo in question.
*/

stock float IsClientInRangeSpecialAmmo(client, char[] EffectT, AmmoPosition = -1, int realowner = 0, int experienceCalculator = 0, int experienceTarget = -1) {
	if (GetArraySize(SpecialAmmoData) < 1) return 0.0;
	bool clientIsLegitimate = IsLegitimateClient(client);
	//decl String:EffectT[4];
	if (!clientIsLegitimate || !IsPlayerAlive(client)) return 0.0;
	float ClientPos[3];
	if (clientIsLegitimate) GetClientAbsOrigin(client, ClientPos);
	else {
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	}

	//Format(EffectT, sizeof(EffectT), "%c", effect);
	float EffectStrength = 0.0;
	float EffectStrengthBonus = 0.0;
	for (int i = (AmmoPosition > 0) ? AmmoPosition : 0; i < GetArraySize(SpecialAmmoData); i++) {
		if (i < 0) break;
		float EntityPos[3];
		char TalentInfo[4][512];
		char value[10];
		//if (i < 0) i = 0;
		// TalentInfo[0] = TalentName of ammo.
		// TalentInfo[1] = Talent Strength (so use StringToInt)
		// TalentInfo[2] = Talent Damage
		// TalentInfo[3] = Talent Interval
		int owner = FindClientByIdNumber(GetArrayCell(SpecialAmmoData, i, 7));
		int pos			= GetArrayCell(SpecialAmmoData, i, 3);
		if (pos < 0) continue;
		IsClientInRangeSAValues[owner]				= GetArrayCell(a_Menu_Talents, pos, 1);
		GetArrayString(IsClientInRangeSAValues[owner], SPELL_AMMO_EFFECT, value, sizeof(value));
		if (!StrEqual(value, EffectT, true)) continue;	// if this ammo isn't the ammo type we're checking, skip.
		GetArrayString(a_Database_Talents, pos, TalentInfo[0], sizeof(TalentInfo[]));
		//GetTalentNameAtMenuPosition(owner, pos, TalentInfo[0], sizeof(TalentInfo[]));

		float t_Range		= GetSpecialAmmoStrength(owner, TalentInfo[0], 3, _, _, pos);
		EntityPos[0] = GetArrayCell(SpecialAmmoData, i, 0);
		EntityPos[1] = GetArrayCell(SpecialAmmoData, i, 1);
		EntityPos[2] = GetArrayCell(SpecialAmmoData, i, 2);
		if (GetVectorDistance(ClientPos, EntityPos) > (t_Range / 2)) continue;

		if (realowner == 0 || realowner == owner) {

			float EffectStrengthValue = GetArrayCell(IsClientInRangeSAValues[owner], SPECIAL_AMMO_TALENT_STRENGTH);
			float fSpellBuffStrUp = GetAbilityStrengthByTrigger(owner, _, "spellbuff", _, _, _, _, "strengthup", 0, true);
			if (fSpellBuffStrUp > 0.0) EffectStrengthValue += (EffectStrengthValue * fSpellBuffStrUp);

			float EffectMultiplierValue = GetArrayCell(IsClientInRangeSAValues[owner], SPELL_EFFECT_MULTIPLIER);

			if (EffectStrength == 0.0) EffectStrength = EffectStrengthValue;
			else EffectStrengthBonus += EffectMultiplierValue;
			if (experienceCalculator > 0) {
				// the owner of this ammo that is buffing a player that has benefitted from it and is not just idling inside its field deserves to be rewarded
				// so we're going to give them buffing experience.
				int buffingExperienceToAwardTheOwner = RoundToCeil(experienceCalculator * EffectStrengthValue);
				//if (EffectStrengthBonus > 0.0) buffingExperienceToAwardTheOwner += RoundToCeil(experienceCalculator * EffectMultiplierValue);
				if (!clientIsLegitimate || myCurrentTeam[client] != myCurrentTeam[owner]) AwardExperience(owner, HEXING_CONTRIBUTION, buffingExperienceToAwardTheOwner);
				else {
					AwardExperience(owner, BUFFING_CONTRIBUTION, buffingExperienceToAwardTheOwner);
					AddContributionToEngagedEnemiesOfAlly(owner, client, CONTRIBUTION_AWARD_BUFFING, buffingExperienceToAwardTheOwner, experienceTarget);
				}
			}
		}
		if (AmmoPosition >= 0) break;
	}
	if (EffectStrengthBonus > 0.0) EffectStrength += (EffectStrength * EffectStrengthBonus);
	return EffectStrength;
}

public Action Timer_AmmoTriggerCooldown(Handle timer, any client) {

	if (IsLegitimateClient(client)) AmmoTriggerCooldown[client] = false;
	return Plugin_Stop;
}

stock AdvertiseAction(client, char[] TalentName, bool isSpell = false) {

	char TalentName_Temp[64];
	char Name[64];
	char text[64];

	GetTranslationOfTalentName(client, TalentName, text, sizeof(text), _, true);
	if (StrEqual(text, "-1")) GetTranslationOfTalentName(client, TalentName, text, sizeof(text), true);

	GetFormattedPlayerName(client, Name, sizeof(Name));
	char printer[512];
	Format(TalentName_Temp, sizeof(TalentName_Temp), "%t", text);
	if (isSpell) Format(printer, sizeof(printer), "%t", "player uses spell", Name, TalentName_Temp);
	else Format(printer, sizeof(printer), "%t", "player uses ability", Name, TalentName_Temp);
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
		Client_PrintToChat(i, true, printer);
	}
}

stock float GetSpellCooldown(client, char[] spellChar = "o", int pos) {	// by default, pass ANY value other than L

	float SpellCooldown = GetAbilityValue(client, ABILITY_COOLDOWN, pos);
	if (SpellCooldown == -1.0) return 0.0;
	float TheAbilityMultiplier = (!StrEqual(spellChar, "L")) ? GetAbilityMultiplier(client, "L", -1) : -1.0;

	if (TheAbilityMultiplier != -1.0) {

		if (TheAbilityMultiplier < 0.0) TheAbilityMultiplier = 0.1;
		else if (TheAbilityMultiplier > 0.0) { //cooldowns are reduced

			SpellCooldown -= (SpellCooldown * TheAbilityMultiplier);
			if (SpellCooldown < 0.0) SpellCooldown = 0.0;
		}
	}
	return SpellCooldown;
}

stock bool UseAbility(client, target = -1, char[] TalentName, Handle Values, float TargetPos[3], int menuPos) {

	if (!b_IsActiveRound || GetAmmoCooldownTime(client, TalentName, true) != -1.0 || IsAbilityActive(client, TalentName, _, _, menuPos)) return false;
	if (IsLegitimateClientAlive(target)) GetClientAbsOrigin(target, TargetPos);

	float TheAbilityMultiplier = 0.0;
	int myAttacker = L4D2_GetInfectedAttacker(client);
	if (GetArrayCell(Values, ABILITY_REQ_NO_ENSNARE) == 1 && myAttacker != -1) return false;

	float ClientPos[3];
	GetClientAbsOrigin(client, ClientPos);

	int MySecondary = GetPlayerWeaponSlot(client, 1);
	char MyWeapon[64];

	char Effects[64];
	//int menuPos = GetMenuPosition(client, TalentName);
	float SpellCooldown = GetSpellCooldown(client, _, menuPos);

	//new MyAttacker = L4D2_GetInfectedAttacker(client);
	int MyStamina = GetPlayerStamina(client);
	int MyBonus = 0;
	//new MyMaxHealth = GetMaximumHealth(client);
	GetArrayString(Values, ABILITY_TOGGLE_EFFECT, Effects, sizeof(Effects));
	if (!StrEqual(Effects, "-1")) {
		if (StrEqual(Effects, "stagger", true)) {
			if (myAttacker == -1 || IsIncapacitated(client)) return false;	// knife cannot trigger if you are not a victim.
			ReleasePlayer(client);
			//EmitSoundToClient(client, "player/heartbeatloop.wav");
			//StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		}
		else if (StrEqual(Effects, "r", true)) {

			if (!IsPlayerAlive(client) && b_HasDeathLocation[client] && GetTime() - clientDeathTime[client] < 60) {

				RespawnImmunity[client] = true;
				MyRespawnTarget[client] = -1;
				SDKCall(hRoundRespawn, client);
				CreateTimer(0.1, Timer_TeleportRespawn, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(0.1, Timer_GiveMaximumHealth, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, Timer_ImmunityExpiration, client, TIMER_FLAG_NO_MAPCHANGE);

				int oldrating = GetArrayCell(tempStorage, client, 0);
				int oldhandicap = GetArrayCell(tempStorage, client, 1);
				float oldmultiplier = GetArrayCell(tempStorage, client, 2);
				Rating[client] = oldrating;
				handicapLevel[client] = oldhandicap;
				RoundExperienceMultiplier[client] = oldmultiplier;

				PrintToChatAll("%t", "rise again", white, orange, white);
			}
			else return false;
		}
		else if (StrEqual(Effects, "P", true)) {
			// Toggles between pistol / magnum
			if (IsValidEntity(MySecondary)) {
				GetEntityClassname(MySecondary, MyWeapon, sizeof(MyWeapon));
				RemovePlayerItem(client, MySecondary);
				AcceptEntityInput(MySecondary, "Kill");
			}
			if (StrContains(MyWeapon, "magnum", false) == -1 && StrContains(MyWeapon, "pistol", false) != -1) {

				// give them a magnum.
				ExecCheatCommand(client, "give", "pistol_magnum");
			}
			else {

				// make them dual wield.
				ExecCheatCommand(client, "give", "pistol");
				CreateTimer(0.5, Timer_GiveSecondPistol, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(Effects, "T", true)) {
			GetClientStance(client, GetAmmoCooldownTime(client, TalentName, true));
		}
	}
	/*if (StrContains(Effects, "S", true) != -1) {
		StaggerPlayer(client, client);
	}*/
	GetArrayString(Values, ABILITY_ACTIVE_EFFECT, Effects, sizeof(Effects));
	if (!StrEqual(Effects, "-1")) {

		//if (AbilityTime > 0.0) IsAbilityActive(client, TalentName, AbilityTime);
		//We check active time another way now

		if (StrEqual(Effects, "A", true)) { // restores stamina

			TheAbilityMultiplier = GetAbilityMultiplier(client, "A", 1);
			MyBonus = RoundToCeil(MyStamina * TheAbilityMultiplier);
			if (SurvivorStamina[client] + MyBonus > MyStamina) {

				SurvivorStamina[client] = MyStamina;
			}
			else SurvivorStamina[client] += MyBonus;
		}
		if (StrEqual(Effects, "H", true)) {	// heals the individual

			TheAbilityMultiplier = GetAbilityMultiplier(client, "H", 1);
			HealPlayer(client, client, TheAbilityMultiplier, 'h');
		}
		if (StrEqual(Effects, "t", true)) {	// instantly lowers threat by a percentage

			TheAbilityMultiplier = GetAbilityMultiplier(client, "t", 1);
			iThreatLevel[client] -= RoundToFloor(iThreatLevel[client] * TheAbilityMultiplier);
		}
	}

	//if (menupos >= 0) CheckActiveAbility(client, menupos, _, _, true, true);
	//AdvertiseAction(client, TalentName, false);
	//IsAmmoActive(client, TalentName, SpellCooldown, true);

	// We do this AFTER we've activated the talent.
	if (GetArrayCell(Values, ABILITY_IS_REACTIVE) == 2) {	// instant, one-time-use abilities that have a cast-bar and then fire immediately.
		if (GetAbilityMultiplier(client, Effects, 5) == -2.0) {
			int reactiveType = GetArrayCell(Values, ABILITY_REACTIVE_TYPE);
			if (reactiveType == 1) StaggerPlayer(client, GetAnyPlayerNotMe(client));
			else if (reactiveType == 2) {
				float fActiveTime = GetArrayCell(Values, ABILITY_ACTIVE_TIME);
				CreateProgressBar(client, fActiveTime);
				Handle datapack;
				CreateDataTimer(fActiveTime, Timer_ReactiveCast, datapack, TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(datapack, client);
				WritePackCell(datapack, GetMaximumHealth(client) * (GetArrayCell(Values, ABILITY_ACTIVE_STRENGTH)));
			}
			AdvertiseAction(client, TalentName, false);
			IsAmmoActive(client, TalentName, SpellCooldown, true);
		}
	}
	else {
		AdvertiseAction(client, TalentName, false);
		IsAmmoActive(client, TalentName, SpellCooldown, true);
	}

	return true;
}

public Action Timer_ReactiveCast(Handle timer, Handle datapack) {
	ResetPack(datapack);
	int client = ReadPackCell(datapack);
	if (IsLegitimateClient(client)) {
		int amount = ReadPackCell(datapack);
		CreateFireEx(client);
		DoBurn(client, client, amount);

		// we also do this burn damage to all supers, witches, and specials in range of the fire.
		// because molotov is a set size, trying to match that here.
		float cpos[3];
		GetClientAbsOrigin(client, cpos);
		float tpos[3];
		// specials
		for (int target = 1; target <= MaxClients; target++) {
			if (!IsLegitimateClient(target) || myCurrentTeam[target] != TEAM_INFECTED) continue;
			GetClientAbsOrigin(target, tpos);
			if (GetVectorDistance(cpos, tpos) > 256.0) continue;
			DoBurn(target, client, amount);
		}
		// supers
		int common;
		/*for (new target = 0; target < GetArraySize(CommonInfected); target++) {
			common = GetArrayCell(CommonInfected, target);
			if (!IsSpecialCommon(common)) continue;
			GetEntPropVector(common, Prop_Send, "m_vecOrigin", tpos);
			if (GetVectorDistance(cpos, tpos) > 256.0) continue;
			DoBurn(common, client, amount);
		}*/
		// witches
		for (int target = 0; target < GetArraySize(WitchList); target++) {
			common = GetArrayCell(WitchList, target);
			if (!IsWitch(common)) continue;
			GetEntPropVector(common, Prop_Send, "m_vecOrigin", tpos);
			if (GetVectorDistance(cpos, tpos) > 256.0) continue;
			DoBurn(common, client, amount);
		}
	}
	return Plugin_Stop;
}

public Action Timer_GiveSecondPistol(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		ExecCheatCommand(client, "give", "pistol");
	}
	return Plugin_Stop;
}

/* returns the # of unlocks a player will receive for the next prestige
   Put this here because we're going to use this to verify # of player upgrades.
*/
stock GetPrestigeLevelNodeUnlocks(level) {
	if (iSkyLevelNodeUnlocks > 0) return iSkyLevelNodeUnlocks;
	return level;
}

stock bool CastSpell(client, target = -1, char[] TalentName, float TargetPos[3], float visualDelayTime = 1.0, int menuPos) {

	if (!b_IsActiveRound || !IsLegitimateClientAlive(client) || L4D2_GetInfectedAttacker(client) != -1 || GetAmmoCooldownTime(client, TalentName) != -1.0) return false;
	if (IsSpellAnAura(client, menuPos)) {
		GetClientAbsOrigin(client, TargetPos);
		target = client;
	}
	else if (IsLegitimateClientAlive(target)) GetClientAbsOrigin(target, TargetPos);	// if the target is -1 / not alive, TargetPos will have been sent through.

	if (bIsSurvivorFatigue[client]) return false;

	int StaminaCost = RoundToCeil(GetSpecialAmmoStrength(client, TalentName, 2, _, _, menuPos));
 	if (SurvivorStamina[client] < StaminaCost) return false;
 	SurvivorStamina[client] -= StaminaCost;
	if (SurvivorStamina[client] <= 0) {

		bIsSurvivorFatigue[client] = true;
		IsSpecialAmmoEnabled[client][0] = 0.0;
	}

	//IsAbilityActive(client, TalentName, AbilityTime);

	AdvertiseAction(client, TalentName, true);

	//new Float:SpellCooldown = GetSpecialAmmoStrength(client, TalentName, 1);
	//IsAmmoActive(client, TalentName, SpellCooldown);	// place it on cooldown for the lifetime (not the interval, even if it's greater)

	char key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));

	float f_TotalTime = GetSpecialAmmoStrength(client, TalentName, _, _, _, menuPos);
	float SpellCooldown = f_TotalTime + GetSpecialAmmoStrength(client, TalentName, 1, _, _, menuPos);
	
	// It's going to be a headache re-structuring this, so i am doing it in a sequence. to make it easier interval will just clone totaltime for now.
	float f_Interval = f_TotalTime; //GetSpecialAmmoStrength(client, TalentName, 4);
	if (IsSpellAnAura(client, menuPos)) f_Interval = fSpecialAmmoInterval;	// Auras follow players and re-draw on every tick.

	//if (f_Interval > f_TotalTime) f_Interval = f_TotalTime;
	IsAmmoActive(client, TalentName, SpellCooldown);

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i)) DrawSpecialAmmoTarget(i, menuPos, TargetPos[0], TargetPos[1], TargetPos[2], f_Interval, client, TalentName, target);
	}

	int bulletStrength = GetBaseWeaponDamage(client, target, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET);
	//bulletStrength = RoundToCeil(GetAbilityStrengthByTrigger(client, -2, "D", _, bulletStrength, _, _, "d", 1, true, _, _, _, DMG_BULLET));
	float amSTR = GetSpecialAmmoStrength(client, TalentName, 5, _, _, menuPos);
	if (amSTR > 0.0) bulletStrength = RoundToCeil(bulletStrength * amSTR);
	//decl String:SpecialAmmoData_s[512];
	//Format(SpecialAmmoData_s, sizeof(SpecialAmmoData_s), "%3.3f %3.3f %3.3f}%s{%d{%d{%3.2f}%s}%3.2f}%d}%3.2f}%d", TargetPos[0], TargetPos[1], TargetPos[2], TalentName, GetTalentStrength(client, TalentName), GetBaseWeaponDamage(client, -1, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET), f_Interval, key, SpellCooldown, -1, GetSpecialAmmoStrength(client, TalentName, 1), target);
	//Format(SpecialAmmoData_s, sizeof(SpecialAmmoData_s), "%3.3f %3.3f %3.3f}%s{%d{%d{%3.2f}%s}%3.2f}%d}%3.2f}%d", TargetPos[0], TargetPos[1], TargetPos[2], TalentName, GetTalentStrength(client, TalentName), bulletStrength, f_Interval, key, f_TotalTime, -1, GetSpecialAmmoStrength(client, TalentName, 1), target);
												//13908.302 2585.922 32.133}adren ammo{1{20{15.00}STEAM_1:1:440606022}15.00}-1}30.00}-1
	//PrintToChatAll("%d", StringToInt(key[10]));
	int sadsize = GetArraySize(SpecialAmmoData);

	ResizeArray(SpecialAmmoData, sadsize + 1);
	SetArrayCell(SpecialAmmoData, sadsize, TargetPos[0], 0);
	SetArrayCell(SpecialAmmoData, sadsize, TargetPos[1], 1);
	SetArrayCell(SpecialAmmoData, sadsize, TargetPos[2], 2);
	SetArrayCell(SpecialAmmoData, sadsize, menuPos, 3); //GetTalentNameAtMenuPosition(client, pos, String:TheString, stringSize) instead of storing TalentName
	//SetArrayCell(SpecialAmmoData, sadsize, GetTalentStrength(client, TalentName), 4);
	SetArrayCell(SpecialAmmoData, sadsize, 1, 4);
	SetArrayCell(SpecialAmmoData, sadsize, bulletStrength, 5);
	SetArrayCell(SpecialAmmoData, sadsize, f_Interval, 6);
	// only captures the #ID: STEAM_0:1:<--cuts off the front, only stores the numbers: 440606022 - is faster than parsing a string every time.
	SetArrayCell(SpecialAmmoData, sadsize, StringToInt(key[10]), 7);
	SetArrayCell(SpecialAmmoData, sadsize, f_TotalTime, 8);
	SetArrayCell(SpecialAmmoData, sadsize, -1, 9);
	SetArrayCell(SpecialAmmoData, sadsize, GetSpecialAmmoStrength(client, TalentName, 1, _, _, menuPos), 10);	// float.
	SetArrayCell(SpecialAmmoData, sadsize, target, 11);
	SetArrayCell(SpecialAmmoData, sadsize, visualDelayTime, 12);	// original value must be stored.
	SetArrayCell(SpecialAmmoData, sadsize, visualDelayTime, 13);



	//PushArrayString(Handle:SpecialAmmoData, SpecialAmmoData_s);
	return true;
}

stock DoBurn(attacker, victim, baseWeaponDamage) {
	//if (iTankRush == 1 && FindZombieClass(victim) == ZOMBIECLASS_TANK) return;
	bool IsLegitimateClientVictim = IsLegitimateClientAlive(victim);
	if (IsLegitimateClientVictim) {
		bIsBurnCooldown[victim] = true;
		CreateTimer(1.0, Timer_ResetBurnImmunity, victim, TIMER_FLAG_NO_MAPCHANGE);
	}
 	int hAttacker = attacker;
 	if (!IsLegitimateClient(hAttacker)) hAttacker = -1;
	bool IsCommonInfectedVictim = IsCommonInfected(victim);
 	if (IsCommonInfectedVictim || IsWitch(victim) && !(GetEntityFlags(victim) & FL_ONFIRE)) {
		if (IsCommonInfectedVictim) {
			if (!IsSpecialCommon(victim)) OnCommonInfectedCreated(victim, true);
			else AddSpecialCommonDamage(attacker, victim, baseWeaponDamage, true);
		}
		else {
			AddWitchDamage(attacker, victim, baseWeaponDamage, true);
		}
	}
 	if (IsLegitimateClientVictim && GetClientStatusEffect(victim, "burn") < iDebuffLimit) {
		if (ISEXPLODE[victim] == INVALID_HANDLE) CreateAndAttachFlame(victim, RoundToCeil(baseWeaponDamage * TheInfernoMult), 10.0, 0.5, hAttacker, "burn");
		else CreateAndAttachFlame(victim, RoundToCeil((baseWeaponDamage * TheInfernoMult) * TheScorchMult), 10.0, 0.5, hAttacker, "burn");
 	}
}

stock BeanBagAmmo(client, float force, TalentClient) {
	if (!IsCommonInfected(client) && !IsLegitimateClientAlive(client)) return;
	if (!IsLegitimateClientAlive(TalentClient)) return;
	float Velocity[3];
	Velocity[0]	=	GetEntPropFloat(TalentClient, Prop_Send, "m_vecVelocity[0]");
	Velocity[1]	=	GetEntPropFloat(TalentClient, Prop_Send, "m_vecVelocity[1]");
	Velocity[2]	=	GetEntPropFloat(TalentClient, Prop_Send, "m_vecVelocity[2]");
	float Vec_Pull;
	float Vec_Lunge;
	/*if (client != TalentClient) {

		//new CartXP = RoundToCeil(GetClassMultiplier(TalentClient, force, "enX", true));
		//AddTalentExperience(TalentClient, "endurance", RoundToCeil(force));
	}*/
	Vec_Pull	=	GetRandomFloat(force * -1.0, force);
	Vec_Lunge	=	GetRandomFloat(force * -1.0, force);
	Velocity[2]	+=	force;
	if (Vec_Pull < 0.0 && Velocity[0] > 0.0) Velocity[0] *= -1.0;
	Velocity[0] += Vec_Pull;
	if (Vec_Lunge < 0.0 && Velocity[1] > 0.0) Velocity[1] *= -1.0;
	Velocity[1] += Vec_Lunge;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
}

/*

	When a client who has special ammo enabled has an eligible target highlighted, we want to draw an aura around that target (just for the client)
	This aura will cycle appropriately as a player cycles their active ammo.

	I have consciously made the decision (ahead of time, having this foresight) to design it so special ammos cannot be used on self. If a client
	wants to use a defensive ammo, for example, on themselves, they would need to shoot an applicable target (enemy, teammate, vehicle... lol) and then step
	into the range.
*/

// no one sees my special ammo because it should be drawing it based on MY size not theirs but it's drawing it based on theirs and if they have zero points in the talent then they can't see it.
stock DrawSpecialAmmoTarget(int TargetClient, int CurrentPos,
							float PosX=0.0, float PosY=0.0, float PosZ=0.0,
							float f_ActiveTime=0.0, int owner=0, char[] TalentName ="none", int Target = -1) {		// If we aren't actually drawing..? Stoned idea lost in thought but expanded somewhat not on the original path
	int client = TargetClient;
	if (owner != 0) client = owner;
	if (iRPGMode <= 0) return -1;
	//int CurrentPos	= GetMenuPosition(client, TalentName);
	DrawSpecialAmmoValues[client]	= GetArrayCell(a_Menu_Talents, CurrentPos, 1);

	float AfxRange			= GetSpecialAmmoStrength(client, TalentName, 3, _, _, CurrentPos);
	float AfxRangeBonus = GetAbilityStrengthByTrigger(client, TargetClient, "aamRNG", _, 0, _, _, "d", 1, true);
	if (AfxRangeBonus > 0.0) AfxRangeBonus *= (1.0 + AfxRangeBonus);
	char AfxDrawPos[64];
	char AfxDrawColour[64];
	int drawpos = TALENT_FIRST_RANDOM_KEY_POSITION;
	int drawcolor = TALENT_FIRST_RANDOM_KEY_POSITION;
	DrawSpecialAmmoKeys[client]		= GetArrayCell(a_Menu_Talents, CurrentPos, 0);
	while (drawpos >= 0 && drawcolor >= 0) {
		drawpos = FormatKeyValue(AfxDrawPos, sizeof(AfxDrawPos), DrawSpecialAmmoKeys[client], DrawSpecialAmmoValues[client], "draw pos?", _, _, drawpos, false);
		drawcolor = FormatKeyValue(AfxDrawColour, sizeof(AfxDrawColour), DrawSpecialAmmoKeys[client], DrawSpecialAmmoValues[client], "draw colour?", _, _, drawcolor, false);
		if (drawpos < 0 || drawcolor < 0) return -1;
		//if (StrEqual(AfxDrawColour, "-1", false)) return -1;		// if there's no colour, we return otherwise you'll get errors like this: TE_Send Exception reported: No TempEntity call is in progress (return 0 here would cause endless loop set to -1 as it is ignored i broke the golden rule lul)
		CreateRingSoloEx(-1, AfxRange, AfxDrawColour, AfxDrawPos, false, f_ActiveTime, TargetClient, PosX, PosY, PosZ);
		drawpos++;
		drawcolor++;
	}
	return 2;
}

/*

	We need to get the talent name of the active special ammo.
	This way when an ammo activate triggers it only goes through if that ammo is the type the player currently has selected.
*/
stock bool GetActiveSpecialAmmo(client, char[] TalentName) {

	if (!StrEqual(TalentName, ActiveSpecialAmmo[client], false)) return false;
	// So if the talent is the one equipped...
	return true;
}

stock CreateProgressBar(client, float TheTime, bool NahDestroyItInstead=false, bool NoAdrenaline=false) {

	if (TheTime >= 1.0) {

		float fActionTimeToReduce = GetAbilityStrengthByTrigger(client, client, "progbarspeed", _, 0, _, _, _, 1, true);
		if (fActionTimeToReduce > 0.0) TheTime *= (1.0 - fActionTimeToReduce);
	}

	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	if (NahDestroyItInstead) SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", 0.0);
	else {

		float TheRealTime = TheTime;
		if (!NoAdrenaline && HasAdrenaline(client)) TheRealTime *= fAdrenProgressMult;

		SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", TheRealTime);
		UseItemTime[client] = TheRealTime + GetEngineTime();
	}
}

stock AdjustProgressBar(client, float TheTime) { SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", TheTime); }

stock bool ActiveProgressBar(client) {

	if (GetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration") <= 0.0) return false;
	return true;
}

public Action Timer_ImmunityExpiration(Handle timer, any client) {

	if (IsLegitimateClient(client)) RespawnImmunity[client] = false;
	return Plugin_Stop;
}

stock Defibrillator(client, target = 0, bool IgnoreDistance = false) {
	if (target > 0 && IsLegitimateClientAlive(target)) return;
	int restore = (target == -1) ? 1 : 0;
	if (restore == 1) target = 0;
	// respawn people near the player.
	int respawntarget = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClientAlive(i) && myCurrentTeam[i] == TEAM_SURVIVOR) {
			respawntarget = i;
			break;
		}
	}
	float Origin[3];
	if (client > 0) GetClientAbsOrigin(client, Origin);
	// target defaults to 0.
	for (int i = target; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && !IsPlayerAlive(i) && myCurrentTeam[i] == TEAM_SURVIVOR && (i != client || target == 0) && i != target) {
			if (target > 0 && i != target) continue;
			if (target == 0 && b_HasDeathLocation[i] && (IgnoreDistance || GetVectorDistance(Origin, DeathLocation[i]) < 256.0)) {
				if (restore == 1) {
					int oldrating = GetArrayCell(tempStorage, i, 0);
					int oldhandicap = GetArrayCell(tempStorage, i, 1);
					float oldmultiplier = GetArrayCell(tempStorage, i, 2);
					Rating[i] = oldrating;
					handicapLevel[i] = oldhandicap;
					RoundExperienceMultiplier[i] = oldmultiplier;
				}
				PrintToChatAll("%t", "rise again", white, orange, white);
				RespawnImmunity[i] = true;
				MyRespawnTarget[i] = i;
				SDKCall(hRoundRespawn, i);
				CreateTimer(0.1, Timer_TeleportRespawn, i, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, Timer_ImmunityExpiration, i, TIMER_FLAG_NO_MAPCHANGE);
			}
			else if (target == 0 && !b_HasDeathLocation[i] && IsLegitimateClientAlive(respawntarget)) {
				SDKCall(hRoundRespawn, i);
				RespawnImmunity[i] = true;
				MyRespawnTarget[i] = respawntarget;
				CreateTimer(0.1, Timer_TeleportRespawn, i, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, Timer_ImmunityExpiration, i, TIMER_FLAG_NO_MAPCHANGE);
			}
			//SDKCall(hRoundRespawn, i);
			//if (client > 0) LastDeathTime[i] = GetEngineTime() + StringToFloat(GetConfigValue("death weakness time?"));
			//b_HasDeathLocation[i] = false;
		}
	}
}

/*public Action:Timer_BeaconCorpses(Handle:timer) {

	new CurrentEntity			=	-1;
	decl String:EntityName[64];
	if (!b_IsActiveRound) return Plugin_Stop;

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsIncapacitated(i)) continue;

		BeaconCorpsesCounter[i] += 0.01;
		if (BeaconCorpsesCounter[i] < 0.25) continue;

		CurrentEntity										= GetEntPropEnt(i, Prop_Data, "m_hActiveWeapon");
		if (IsValidEntity(CurrentEntity)) GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));
		if (StrContains(EntityName, "defib", false) == -1) continue;

		BeaconCorpsesCounter[i] = 0.0;
		BeaconCorpsesInRange(i);
	}
	return Plugin_Continue;
}*/

stock InventoryItem(client, char[] EntityName = "none", bool bIsPickup = false, entity = -1) {

	char ItemName[64];

	int ExplodeCount = GetDelimiterCount(EntityName, ":");
	char[][] Classname = new char[ExplodeCount][64];
	ExplodeString(EntityName, ":", Classname, ExplodeCount, 64);

	if (bIsPickup) {	// Picking up the entity. We store it in the users inventory.

		GetEntityClassname(entity, Classname[0], 64);
		GetEntPropString(entity, Prop_Data, "m_iName", ItemName, sizeof(ItemName));
	}
	else {		// Creating the entity. Defaults to -1

		entity	= CreateEntityByName(Classname[0]);
		DispatchKeyValue(entity, "targetname", Classname[1]);
		DispatchKeyValue(entity, "rendermode", "5");
		DispatchKeyValue(entity, "spawnflags", "0");
		DispatchSpawn(entity);
		//TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	}
}

stock bool IsCommonStaggered(client) {
	//decl String:clientId[2][64];
	//decl String:text[64];
	//static Float:timeRemaining = 0.0;
	for (int i = 0; i < GetArraySize(StaggeredTargets); i++) {
		//GetArrayString(StaggeredTargets, i, text, sizeof(text));
		//ExplodeString(text, ":", clientId, 2, 64);
		if (GetArrayCell(StaggeredTargets, i, 0) == client) return true;
		//if (StringToInt(clientId[0]) == client) return true;
	}
	return false;
}

public Action Timer_StaggerTimer(Handle timer) {
	//decl String:clientId[2][64];
	//decl String:text[64];
	if (!b_IsActiveRound) {
		ClearArray(StaggeredTargets);
		return Plugin_Stop;
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		//IsStaggered(i);
		if (SDKCall(g_hIsStaggering, i)) bIsClientCurrentlyStaggered[i] = true;
		else bIsClientCurrentlyStaggered[i] = false;
	}
	static float timeRemaining = 0.0;
	for (int i = 0; i < GetArraySize(StaggeredTargets); i++) {
		//GetArrayString(StaggeredTargets, i, text, sizeof(text));
		//ExplodeString(text, ":", clientId, 2, 64);
		//timeRemaining = StringToFloat(clientId[1]);
		timeRemaining = GetArrayCell(StaggeredTargets, i, 1);
		if (timeRemaining <= fStaggerTickrate) RemoveFromArray(StaggeredTargets, i);
		else {
			SetArrayCell(StaggeredTargets, i, timeRemaining - fStaggerTickrate, 1);
			//Format(text, sizeof(text), "%s:%3.3f", clientId[0], timeRemaining - fStaggerTickrate);
			//SetArrayString(StaggeredTargets, i, text);
		}
	}
	return Plugin_Continue;
}

stock EntityWasStaggered(victim, attacker = 0) {
	bool bIsLegitimateAttacker = IsLegitimateClient(attacker);
	bool bIsLegitimateVictim = IsLegitimateClient(victim);
	int attackerTeam = (bIsLegitimateAttacker) ? myCurrentTeam[attacker] : 0;
	int victimTeam = (bIsLegitimateVictim) ? myCurrentTeam[victim] : 0;
	if (bIsLegitimateAttacker && (!bIsLegitimateVictim || victimTeam != attackerTeam)) GetAbilityStrengthByTrigger(attacker, victim, "didStagger");
	if (bIsLegitimateVictim && (!bIsLegitimateAttacker || attackerTeam != victimTeam)) GetAbilityStrengthByTrigger(victim, attacker, "wasStagger");
}

public Action Timer_ResetStaggerCooldownOnTriggers(Handle timer, any client) {
	if (IsLegitimateClient(client)) staggerCooldownOnTriggers[client] = false;
	return Plugin_Stop;
}

// bool AllLivingSurvivorsInCheckpoint() {
// 	for (int i = 1; i <= MaxClients; i++) {
// 		if (!IsLegitimateClientAlive(i)) continue;
// 		if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
// 		if (!bIsInCheckpoint[i]) return false;
// 	}
// 	return true;
// }

//void GetClientWeap

public Action OnPlayerRunCmd(client, &buttons) {
	int clientFlags = GetEntityFlags(client);
	bool clientIsSurvivor = (myCurrentTeam[client] == TEAM_SURVIVOR) ? true : false;
	bool IsClientIncapacitated = IsIncapacitated(client);
	bool IsClientAlive = IsLegitimateClientAlive(client);
	bool IsBiledOn = ISBILED[client];
	float TheTime = GetEngineTime();
	int MyAttacker = L4D2_GetInfectedAttacker(client);
	bool isRunning = (buttons & IN_SPEED) ? true : false;
	bool isMoving = (buttons & (IN_FORWARD|IN_BACK|IN_MOVELEFT|IN_MOVERIGHT)) ? true : false;
	if (iExperimentalMode == 1 && clientIsSurvivor && !IsFakeClient(client)) {
		if (isRunning && !bIsSurvivorFatigue[client]) {
			buttons &= ~IN_SPEED;
		}
		else if (isMoving) {
			buttons |= IN_SPEED;
		}
	}
	bool IsHoldingPrimaryFire = (buttons & IN_ATTACK) ? true : false;
	bool isClientOnSolidGround = (clientFlags & FL_ONGROUND) ? true : false;
	bool isClientOnFire = (clientFlags & FL_ONFIRE) ? true : false;
	bool isClientInWater = (clientFlags & FL_INWATER) ? true : false;
	bool isClientHoldingReload = (buttons & IN_RELOAD) ? true : false;
	int weaponEntity = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	bool weaponIsValid = IsValidEntity(weaponEntity);
	// call the stagger ability triggers only when a fresh stagger occurs (and not if multiple staggers happen too-often within each other (2.0 seconds is slightly-longer than one stagger.))
	if (!staggerCooldownOnTriggers[client] && SDKCall(g_hIsStaggering, client)) {
		staggerCooldownOnTriggers[client] = true;
		CreateTimer(2.0, Timer_ResetStaggerCooldownOnTriggers, client, TIMER_FLAG_NO_MAPCHANGE);
		EntityWasStaggered(client);
	}
	if (clientIsSurvivor) {
		if (isClientOnFire && (isClientInWater || IsBiledOn)) {
			RemoveAllDebuffs(client, "burn");
			ExtinguishEntity(client);
		}
		if (isClientInWater && GetClientStatusEffect(client, "acid") > 0) {
			RemoveAllDebuffs(client, "acid");
		}
	}
	else if (buttons & IN_ATTACK) {
		if (FindZombieClass(client) == ZOMBIECLASS_SMOKER) {
			int victim = L4D2_GetSurvivorVictim(client);
			if (victim != -1) GetAbilityStrengthByTrigger(client, victim, "v", _, 0);
		}
	}
	if ((buttons & IN_ZOOM) && ZoomcheckDelayer[client] == INVALID_HANDLE) ZoomcheckDelayer[client] = CreateTimer(0.1, Timer_ZoomcheckDelayer, client, TIMER_FLAG_NO_MAPCHANGE);
	if (IsHoldingPrimaryFire) {
		int bulletsRemaining = 0;
		if (IsValidEntity(weaponEntity)) {
			bulletsRemaining = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
			if (bulletsRemaining == LastBulletCheck[client]) bulletsRemaining = 0;
			else LastBulletCheck[client] = bulletsRemaining;
		}
		if (bulletsRemaining > 0 && GetEntProp(weaponEntity, Prop_Data, "m_bInReload") != 1 && MyAttacker == -1) {
			holdingFireCheckToggle(client, true);
		}
	}
	else holdingFireCheckToggle(client);
	bool isHoldingUseKey = (buttons & IN_USE) ? true : false;
	// if (!isClientOnSolidGround) {
	// 	Autoloot(client);
	// }
	// else 
	if (isHoldingUseKey) {
		IsPlayerTryingToPickupLoot(client);
	}
	if (isHoldingUseKey) {
			// if (b_IsActiveRound && ReadyUpGameMode != 3) {
			// 	if (StrContains(EName, "checkpoint", false) != -1) {
			// 		entity = GetEntProp(entity, Prop_Send, "m_eDoorState");
			// 		PrintToChat(client, "entity door state is %d", entity);
			// 		buttons &= ~IN_USE;
			// 		return Plugin_Changed;
			// 	}
			// }
		if (b_IsRoundIsOver && (ReadyUpGameMode == 3 || StrContains(TheCurrentMap, "zerowarn", false) != -1)) {
			char EName[64];
			int entity = GetClientAimTarget(client, false);
			if (entity != -1) {
				GetEntityClassname(entity, EName, sizeof(EName));
				if (StrContains(EName, "weapon", false) != -1 || StrContains(EName, "physics", false) != -1) return Plugin_Continue;
				buttons &= ~IN_USE;
				return Plugin_Changed;
			}
		}
	}
	if (IsClientAlive && b_IsActiveRound) {
		if (myCurrentTeam[client] == TEAM_INFECTED && FindZombieClass(client) == ZOMBIECLASS_TANK) {
			if (!IsAirborne[client] && !isClientOnSolidGround) IsAirborne[client] = true;	// when the tank lands, aoe explosion!
			else if (IsAirborne[client] && isClientOnSolidGround) {
				IsAirborne[client] = false;	// the tank has landed; explosion;
				CreateExplosion(client, _, client, true);
			}
			int myLifetime = GetTime() - MyBirthday[client];
			if (MyBirthday[client] > 0) {
				int numSurvivorsNear = NearbySurvivors(client, 2056.0);
				//if there are no nearby survivors (tank spawned ahead or people are rushing)
				if (numSurvivorsNear < 1) {
					// if we've been around for a while, kill the tank
					if (myLifetime > 120) DeleteMeFromExistence(client);
					else SetSpeedMultiplierBase(client, 2.0);	// otherwise make him super fast so he can catch the survivors.
				}	// but if survivors are nearby, reset the tanks speed based on his current mutation.
				else CheckTankSubroutine(client);
			}
		}

		/*if (clientTeam == TEAM_SURVIVOR) {

			//CheckIfItemPickup(client);
			//CheckBombs(client);
			if (IsFakeClient(client) && !bIsInCheckpoint[client]) {

				if (SurvivorsSaferoomWaiting()) SurvivorBotsRegroup(client);
			}
		}*/
		bool isClientHoldingJump = (buttons & IN_JUMP) ? true : false;
		if (isClientHoldingJump) bJumpTime[client] = true;
		else {

			bJumpTime[client] = false;
			JumpTime[client] = 0.0;
		}
		if (!IsLegitimateClientAlive(MyAttacker)) StrugglePower[client] = 0;

		if (CombatTime[client] <= TheTime && bIsInCombat[client] && (iPlayersLeaveCombatDuringFinales == 1 || !b_IsFinaleActive)) {

			bIsInCombat[client] = false;
			iThreatLevel[client] = 0;
			ResetContributionTracker(client);
			if (!IsSurvivalMode) AwardExperience(client);
		}
		else if (CombatTime[client] > TheTime || b_IsFinaleActive && iPlayersLeaveCombatDuringFinales == 0) {
			bIsInCombat[client] = true;
		}
		//if (GetClientTeam(client) == TEAM_INFECTED) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
		// if (clientTeam == TEAM_SURVIVOR) {
		// 	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", MovementSpeed[client]);
		// }
		if (ISDAZED[client] > TheTime) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue") * fDazedDebuffEffect);
		else if (ISDAZED[client] <= TheTime && ISDAZED[client] != 0.0) {
			BlindPlayer(client, _, 0);	// wipe the dazed effect.
			ISDAZED[client] = 0.0;
		}
		if (clientIsSurvivor) {
			char EntityName[64];
			if (weaponIsValid) {
				GetEdictClassname(weaponEntity, EntityName, sizeof(EntityName));
				if (isClientHoldingReload) GetInfectedAbilityStrengthByTrigger(client, client, "holdReload");
			}
			bool theClientHasAnActiveProgressBar = ActiveProgressBar(client);
			bool theClientHasPainPills = (!weaponIsValid || StrContains(EntityName, "pain_pills", false) == -1) ? false : true;
			bool theClientHasAdrenaline = (!weaponIsValid || StrContains(EntityName, "adrenaline", false) == -1) ? false : true;
			bool theClientHasFirstAid = (!weaponIsValid || StrContains(EntityName, "first_aid", false) == -1) ? false : true;
			bool theClientHasDefib = (!weaponIsValid || StrContains(EntityName, "defib", false) == -1) ? false : true;
			//new CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

			//Format(EntityName, sizeof(EntityName), "}");
			if (weaponIsValid) {
				if (StrContains(EntityName, "chainsaw", false) != -1 && (buttons & IN_RELOAD) && GetEntProp(weaponEntity, Prop_Data, "m_iClip1") < 10) {
					SetEntProp(weaponEntity, Prop_Data, "m_iClip1", 30);
					buttons &= ~IN_RELOAD;
				}
				if (theClientHasAnActiveProgressBar &&
					weaponEntity != ProgressEntity[client] ||
					!IsClientAlive ||
					(!isClientOnSolidGround && !IsClientIncapacitated) ||
					MyAttacker != -1 ||
					!weaponIsValid && !IsClientIncapacitated ||
					!theClientHasPainPills && !theClientHasAdrenaline && !theClientHasFirstAid && !theClientHasDefib && !IsClientIncapacitated) {
					CreateProgressBar(client, 0.0, true);
					UseItemTime[client] = 0.0;
					theClientHasAnActiveProgressBar = false;
					if (GetEntPropEnt(client, Prop_Send, "m_reviveOwner") == client) {
						SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
						SetEntPropEnt(client, Prop_Send, "m_reviveTarget", -1);
					}
				}
			}
			int PlayerMaxStamina = GetPlayerStamina(client);

			if (MyAttacker == -1 && (IsClientIncapacitated || (weaponIsValid && (theClientHasPainPills || theClientHasAdrenaline || theClientHasFirstAid || theClientHasDefib)))) {

				//blocks the use of meds on people. will add an option in the menu later for now allowing.
				/*if ((buttons & IN_ATTACK2) && !IsIncapacitated(client)) {

					if (StrContains(EntityName, "first_aid", false) != -1) {

						buttons &= ~IN_ATTACK2;
						return Plugin_Changed;
					}
				}*/
				int reviveOwner = -1;
				if (!IsClientAlive ||
					(!IsHoldingPrimaryFire && theClientHasAnActiveProgressBar && !IsClientIncapacitated) ||
					(!isHoldingUseKey && theClientHasAnActiveProgressBar && IsClientIncapacitated)) {

					CreateProgressBar(client, 0.0, true);
					UseItemTime[client] = 0.0;
					theClientHasAnActiveProgressBar = false;
					reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
					if (reviveOwner == client) {

						SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
						SetEntPropEnt(client, Prop_Send, "m_reviveTarget", -1);
					}
					/*
					if (IsLegitimateClientAlive(reviveOwner) && GetClientTeam(reviveOwner) == TEAM_SURVIVOR) {

						SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
						SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
					}*/
				}
				bool playerOnLedge = IsLedged(client);
				if (IsClientAlive && ((IsHoldingPrimaryFire && !IsClientIncapacitated) || (isHoldingUseKey && IsClientIncapacitated && !playerOnLedge))) {
					if (!IsClientIncapacitated) buttons &= ~IN_ATTACK;
					else buttons &= ~IN_USE;
					if (UseItemTime[client] < TheTime) {
						if (theClientHasAnActiveProgressBar) {
							UseItemTime[client] = 0.0;
							CreateProgressBar(client, 0.0, true);
							if (!IsClientIncapacitated) {
								int healTarget = GetClientAimTarget(client);
								if (!IsLegitimateClientAlive(healTarget) || myCurrentTeam[healTarget] != myCurrentTeam[client] || !ClientsWithinRange(client, healTarget, 96.0)) healTarget = client;
								if (theClientHasPainPills) {
									float fPainPillsHeal = GetTempHealth(healTarget) + (GetMaximumHealth(healTarget) * fPainPillsHealAmount);
									HealPlayer(client, healTarget, fPainPillsHeal, 'h', true);//SetTempHealth(client, client, GetTempHealth(client) + (GetMaximumHealth(client) * 0.3), false);		// pills add 10% of your total health in temporary health.
									AcceptEntityInput(weaponEntity, "Kill");
									GetAbilityStrengthByTrigger(client, healTarget, "usepainpills", _, RoundToCeil(fPainPillsHeal));
									GetAbilityStrengthByTrigger(client, healTarget, "healsuccess", _, RoundToCeil(fPainPillsHeal));
								}
								else if (theClientHasAdrenaline) {
									SetAdrenalineState(client);
									int StaminaBonus = RoundToCeil(PlayerMaxStamina * 0.25);
									if (SurvivorStamina[client] + StaminaBonus >= PlayerMaxStamina) {
										SurvivorStamina[client] = PlayerMaxStamina;
										bIsSurvivorFatigue[client] = false;
									}
									else SurvivorStamina[client] += StaminaBonus;
									AcceptEntityInput(weaponEntity, "Kill");
								}
								// else if (theClientHasDefib) {
								// 	Defibrillator(client, -1);
								// 	AcceptEntityInput(weaponEntity, "Kill");
								// }
								else if (theClientHasFirstAid) {
									int iFirstAidHealAmount = GetMaximumHealth(healTarget) - GetClientHealth(healTarget);
									GiveMaximumHealth(healTarget);
									RefreshSurvivor(healTarget);
									AcceptEntityInput(weaponEntity, "Kill");
									GetAbilityStrengthByTrigger(client, healTarget, "usefirstaid", _, iFirstAidHealAmount);
									GetAbilityStrengthByTrigger(client, healTarget, "healsuccess", _, iFirstAidHealAmount);
								}
							}
							else {
								ReviveDownedSurvivor(client);
								OnPlayerRevived(client, client);
							}
						}
						else {
							if (IsClientIncapacitated && UseItemTime[client] < TheTime) {
								reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
								if (!IsLegitimateClientAlive(reviveOwner)) {
									SetEntPropEnt(client, Prop_Send, "m_reviveOwner", client);
									ProgressEntity[client]			=	weaponEntity;
									CreateProgressBar(client, 5.0);	// you can pick yourself up for free but it takes a bit.
								}
							}
							if (!IsClientIncapacitated && UseItemTime[client] < TheTime) {
								float fProgressBarCompletionTime = -1.0;
								if (theClientHasPainPills) fProgressBarCompletionTime = 2.0;
								else if (theClientHasAdrenaline) fProgressBarCompletionTime = 1.0;
								else if (theClientHasFirstAid) fProgressBarCompletionTime = 5.0;
								if (fProgressBarCompletionTime != -1.0) {
									ProgressEntity[client]			=	weaponEntity;
									CreateProgressBar(client, fProgressBarCompletionTime);
								}
							}
							if (theClientHasAnActiveProgressBar) SetEntPropEnt(client, Prop_Send, "m_reviveOwner", client);
						}
					}
					return Plugin_Changed;
				}
			}
			// For drawing special ammo.
			if (bIsSurvivorFatigue[client]) {
				IsSpecialAmmoEnabled[client][0] = 0.0;
				Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
			}
			if ((ReadyUp_GetGameMode() != 3 || !b_IsSurvivalIntermission) && iRPGMode >= 1) {
				bool IsJetpackBroken = (isClientOnFire || IsBiledOn);
				if (!IsJetpackBroken) IsJetpackBroken = AnyTanksNearby(client);
				/*
					Add or remove conditions from the following line to determine when the jetpack automatically disables.
					When adding new conditions, consider a switch so server operators can choose which of them they want to use.
				*/
				if (bJetpack[client] && (iCanJetpackWhenInCombat == 1 || !bIsInCombat[client]) && (!isClientHoldingJump || IsJetpackBroken || MyAttacker != -1)) {
					ToggleJetpack(client, true);
				}
				bool isSprinting = (iExperimentalMode == 1 && isRunning && isMoving) ? true : false;
				if ((bJetpack[client] || !bJetpack[client] && !isClientOnSolidGround) ||
					isClientHoldingJump && SurvivorStamina[client] >= ConsumptionInt && !bIsSurvivorFatigue[client] && !ISSLOW[client] && ISFROZEN[client] == INVALID_HANDLE ||
					isSprinting) {
					if (MyAttacker == -1 && !ISSLOW[client] && ISFROZEN[client] == INVALID_HANDLE) {
						if (SurvivorConsumptionTime[client] <= TheTime && (isClientHoldingJump || isSprinting)) {
							if (bJetpack[client]) {
								float nextSprintInterval = GetAbilityStrengthByTrigger(client, client, "jetpack", _, 0, _, _, "flightcost", _, _, 2);
								if (nextSprintInterval > 0.0) SurvivorConsumptionTime[client] = TheTime + fStamJetpackInterval + (fStamJetpackInterval * nextSprintInterval);
								else SurvivorConsumptionTime[client] = TheTime + fStamJetpackInterval;
							}
							else SurvivorConsumptionTime[client] = TheTime + fStamSprintInterval;
							if (!bIsSurvivorFatigue[client]) SurvivorStamina[client] -= ConsumptionInt;
							if (SurvivorStamina[client] <= 0 || IsJetpackBroken) {
								bIsSurvivorFatigue[client] = true;
								IsSpecialAmmoEnabled[client][0] = 0.0;
								SurvivorStamina[client] = 0;
								if (bJetpack[client]) ToggleJetpack(client, true);
							}
						}
						if (!bIsSurvivorFatigue[client] && !bJetpack[client] && (isClientHoldingJump && (JumpTime[client] >= fJumpTimeToActivateJetpack)) && (iCanJetpackWhenInCombat == 1 || !bIsInCombat[client]) && !IsJetpackBroken && JetpackRecoveryTime[client] <= GetEngineTime() && MyAttacker == -1) ToggleJetpack(client);
						if (!bJetpack[client]) MovementSpeed[client] = fSprintSpeed;
					}
					buttons &= ~IN_SPEED;
					return Plugin_Changed;
				}
				if (!bJetpack[client]) {
					if (SurvivorStaminaTime[client] < TheTime && SurvivorStamina[client] < PlayerMaxStamina) {
						if (!HasAdrenaline(client)) SurvivorStaminaTime[client] = TheTime + fStamRegenTime;
						else SurvivorStaminaTime[client] = TheTime + fStamRegenTimeAdren;
						SurvivorStamina[client]++;
					}
					// if (!bIsSurvivorFatigue[client]) MovementSpeed[client] = fBaseMovementSpeed;
					// else MovementSpeed[client] = fFatigueMovementSpeed;
					if (ISSLOW[client]) MovementSpeed[client] *= fSlowSpeed[client];
					if (SurvivorStamina[client] >= PlayerMaxStamina) {
						bIsSurvivorFatigue[client] = false;
						SurvivorStamina[client] = PlayerMaxStamina;
					}
				}
			}
		}
	}
	return Plugin_Changed;
}

stock bool AnyTanksInExistence() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || myCurrentTeam[i] != TEAM_INFECTED) continue;
		if (FindZombieClass(i) == ZOMBIECLASS_TANK) return true;
	}
	return false;
}

stock bool IsPlayerOnGroundOutsideOfTankZone(tank) {
	float fTankPos[3];
	float fClientPos[3];
	GetClientAbsOrigin(tank, fTankPos);
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;	// only player clients allowed.
		if (myCurrentTeam[i] != TEAM_SURVIVOR) continue;	// only survivors.
		if (!(GetEntityFlags(i) & FL_ONGROUND)) continue;	// only players with feet on the ground.
		GetClientAbsOrigin(i, fClientPos);
		if (HeightDifference(fClientPos[2], fTankPos[2]) >= fTeleportTankHeightDistance) {
			// teleport tank to survivor.
			TeleportEntity(tank, fClientPos, NULL_VECTOR, NULL_VECTOR);
			return true;
		}
	}
	return false;
}

stock float HeightDifference(float clientZ, float tankZ) {
	if (clientZ == tankZ) return 0.0;
	float fDistance = clientZ - tankZ;
	if (fDistance < 0.0) fDistance *= 1.0;	// distance should not be able to reach negatives using this algorithm
	return fDistance;
}

stock ToggleJetpack(client, DisableJetpack = false) {
	if (iJetpackEnabled != 1) return;

	float ClientPos[3];
	GetClientAbsOrigin(client, ClientPos);
	if (!DisableJetpack && !bJetpack[client] && !AnyTanksInExistence()) {

		EmitSoundToAll(JETPACK_AUDIO, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, ClientPos, NULL_VECTOR, true, 0.0);
		SetEntityMoveType(client, MOVETYPE_FLY);
		bJetpack[client] = true;
	}
	else if (DisableJetpack && bJetpack[client]) {

		StopSound(client, SNDCHAN_WEAPON, JETPACK_AUDIO);
		//EmitSoundToAll(JETPACK_AUDIO, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, ClientPos, NULL_VECTOR, true, 0.0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		bJetpack[client] = false;
	}
}

stock bool IsEveryoneBoosterTime() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && myCurrentTeam[i] != TEAM_SPECTATOR && !HasBoosterTime(i)) return false;
	}
	return true;
}

stock CreateDamageStatusEffect(client, type = 0, target = 0, damage = 0, owner = 0, float RangeOverride = 0.0) {
	if (!IsSpecialCommon(client)) return;
	float AfxRange = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_PLAYER_LEVEL);
	float AfxStrengthLevel = GetCommonValueFloatAtPos(client, SUPER_COMMON_LEVEL_STRENGTH);
	float AfxRangeMax = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MAX);
	int AfxMultiplication = GetCommonValueIntAtPos(client, SUPER_COMMON_ENEMY_MULTIPLICATION);
	int AfxStrength = GetCommonValueIntAtPos(client, SUPER_COMMON_AURA_STRENGTH);
	float AfxStrengthTarget = GetCommonValueFloatAtPos(client, SUPER_COMMON_STRENGTH_TARGET);
	float AfxRangeBase = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MIN);
	float OnFireBase = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_BASE_TIME);
	float OnFireLevel = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_LEVEL);
	float OnFireMax = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_MAX_TIME);
	float OnFireInterval = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_INTERVAL);
	int AfxLevelReq = GetCommonValueIntAtPos(client, SUPER_COMMON_LEVEL_REQ);
	float ClientPosition[3];
	float TargetPosition[3];
	int t_Strength = 0;
	float t_Range = 0.0;
	float t_OnFireRange = 0.0;
	if (damage > 0) {//AfxStrength = damage;	// if we want to base the damage on a specific value, we can override here.
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPosition);
		int NumLivingEntities = LivingEntitiesInRange(client, ClientPosition, AfxRangeMax);
		if (NumLivingEntities > 1) damage = (damage / NumLivingEntities);
		if (target == 0 || IsLegitimateClient(target)) {
			for (int i = 1; i <= MaxClients; i++) {
				if (!IsLegitimateClientAlive(i) || (target != 0 && i != target) || PlayerLevel[i] < AfxLevelReq) continue;		// if type is 1 and target is 0 acid is spread to all players nearby. but if target is not 0 it is spread to only the player the acid zombie hits. or whatever type uses it.
				GetClientAbsOrigin(i, TargetPosition);
				if (RangeOverride == 0.0) {
					if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[i] - AfxLevelReq);
					else t_Range = AfxRangeMax;
					if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
					else t_Range += AfxRangeBase;
				}
				else t_Range = RangeOverride;
				if (GetVectorDistance(ClientPosition, TargetPosition) > (t_Range / 2)) continue;
				if (AfxMultiplication == 1) {
					if (AfxStrengthTarget < 0.0) t_Strength = AfxStrength * NumLivingEntities;
					else t_Strength = RoundToCeil(AfxStrength * (NumLivingEntities * AfxStrengthTarget));
				}
				else t_Strength = AfxStrength;
				if (AfxStrengthLevel > 0.0) t_Strength += RoundToCeil(t_Strength * ((PlayerLevel[i] - AfxLevelReq) * AfxStrengthLevel));
				t_OnFireRange = OnFireLevel * (PlayerLevel[i] - AfxLevelReq);
				t_OnFireRange += OnFireBase;
				if (t_OnFireRange > OnFireMax) t_OnFireRange = OnFireMax;
				if (IsSpecialCommonInRange(client, 'b')) t_Strength *= 2;//t_Strength = GetSpecialCommonDamage(t_Strength, client, 'b', i);
				if (type == 0) CreateAndAttachFlame(i, t_Strength, t_OnFireRange, OnFireInterval, _, "burn");		// Static time for now.
				else if (type == 4) {
					CreateAndAttachFlame(i, t_Strength, t_OnFireRange, OnFireInterval, _, "acid");
					break;	// to prevent buffer overflow only allow it on one client.
				}
			}
		}
	}
	else CreateFireEx(client);
	//ClearSpecialCommon(client);
}

stock FindEntityInArrayBinarySearch(Handle hArray, target) {
	int left = 0, right = GetArraySize(hArray);
	int middle;
	int ent;
	while (left < right) {
		middle = (left + right) / 2;
		ent = GetArrayCell(hArray, middle);
		if (ent == target) return middle;
		if (ent < target) left = middle + 1;
		else right = middle;
	}
	return -1;
}

// inserting entity into an arraylist in ascending order so it's compatible with binary search
stock InsertIntoArrayAscending(Handle hArray, entity) {
	int size = GetArraySize(hArray);
	int left = 0, right = size;
	if (right < 1) {	// if the array is empty, just push.
		PushArrayCell(hArray, entity);
		return 0;
	}
	else if (right < 2) {	// another outlier check to prevent array oob.
		if (entity > GetArrayCell(hArray, 0)) {
			PushArrayCell(hArray, entity);
			return 1;
		}
		else {
			ResizeArray(hArray, size+1);
			ShiftArrayUp(hArray, size);
			SetArrayCell(hArray, size, entity);
			return 0;
		}
	}
	else {
		int middle = (left + right) / 2;
		int middleEnt = GetArrayCell(hArray, middle);
		int leftEnt = GetArrayCell(hArray, middle - 1);
		while (entity < leftEnt || entity > middleEnt) {
			middle = (left + right) / 2;
			middleEnt = GetArrayCell(hArray, middle);
			leftEnt = GetArrayCell(hArray, middle - 1);
			if (entity < leftEnt) right--;
			else if (entity > middleEnt) left++;
			else break;
		}
		ResizeArray(hArray, size+1);
		ShiftArrayUp(hArray, middle);	// middle is now undefined.
		SetArrayCell(hArray, middle, entity);	// place new entity in middle.
		return middle;
	}
}

stock FindListPositionByEntity(entity, Handle h_SearchList, block = 0) {

	int size = GetArraySize(h_SearchList);
	if (size < 1) return -1;
	for (int i = 0; i < size; i++) {

		if (GetArrayCell(h_SearchList, i, block) == entity) return i;
	}
	return -1;	// returns false
}

stock FindCommonInfectedTargetInArray(Handle hArray, target) {
	int size = GetArraySize(hArray);
	for (int i = 0; i < size; i++) {
		if (i >= size - 1 - i) break;
		if (GetArrayCell(hArray, i) == target) return i;
		if (GetArrayCell(hArray, size - 1 - i) == target) return size-1-i;
	}
	return -1;
}

stock ExplosiveAmmo(client, damage, TalentClient) {
	if (IsWitch(client)) AddWitchDamage(TalentClient, client, damage);
	else if (IsSpecialCommon(client)) AddSpecialCommonDamage(TalentClient, client, damage);
	else if (IsLegitimateClientAlive(client)) {
		if (myCurrentTeam[client] == TEAM_INFECTED) AddSpecialInfectedDamage(TalentClient, client, damage);
		else SetClientTotalHealth(TalentClient, client, damage);	// survivor teammates don't reward players with experience or damage bonus, but they'll take damage from it.
	}
}

stock HealingAmmo(client, healing, TalentClient, bool IsCritical=false) {
	if (!IsLegitimateClientAlive(client) || !IsLegitimateClientAlive(TalentClient)) return;
	HealPlayer(client, TalentClient, healing * 1.0, 'h', true);
}

stock LeechAmmo(client, damage, TalentClient) {
	if (IsWitch(client)) AddWitchDamage(TalentClient, client, damage);
	else if (IsSpecialCommon(client)) AddSpecialCommonDamage(TalentClient, client, damage);
	else if (IsLegitimateClientAlive(client)) {
		if (myCurrentTeam[client] == TEAM_INFECTED) AddSpecialInfectedDamage(TalentClient, client, damage);
		else SetClientTotalHealth(TalentClient, client, damage);
	}
	if (IsLegitimateClientAlive(TalentClient) && myCurrentTeam[TalentClient] == TEAM_SURVIVOR) {
		//if (IsCritical || !IsCriticalHit(client, healing, TalentClient))	// maybe add this to leech? that would be cool.!
		HealPlayer(TalentClient, TalentClient, damage * 1.0, 'h', true);
	}
}

stock CreateBomberExplosion(client, target, char[] Effects, basedamage = 0) {

	//if (IsLegitimateClient(target) && !IsPlayerAlive(target)) return;
	if (!IsLegitimateClientAlive(target)) return;
	/*

		When a bomber dies, it explodes.
	*/
	float AfxRange = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_PLAYER_LEVEL);
	float AfxStrengthLevel = GetCommonValueFloatAtPos(client, SUPER_COMMON_LEVEL_STRENGTH);
	float AfxRangeMax = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MAX);
	int AfxMultiplication = GetCommonValueIntAtPos(client, SUPER_COMMON_ENEMY_MULTIPLICATION);
	int AfxStrength = GetCommonValueIntAtPos(client, SUPER_COMMON_AURA_STRENGTH);
	int AfxChain = GetCommonValueIntAtPos(client, SUPER_COMMON_CHAIN_REACTION);
	float AfxStrengthTarget = GetCommonValueFloatAtPos(client, SUPER_COMMON_STRENGTH_TARGET);
	float AfxRangeBase = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MIN);
	int AfxLevelReq = GetCommonValueIntAtPos(client, SUPER_COMMON_LEVEL_REQ);
	int isRaw = GetCommonValueIntAtPos(client, SUPER_COMMON_RAW_STRENGTH);
	int rawCommon = GetCommonValueIntAtPos(client, SUPER_COMMON_RAW_COMMON_STRENGTH);
	int rawPlayer = GetCommonValueIntAtPos(client, SUPER_COMMON_RAW_PLAYER_STRENGTH);


	if (IsSpecialCommon(client) && myCurrentTeam[target] == TEAM_SURVIVOR && PlayerLevel[target] < AfxLevelReq) return;

	float SourcLoc[3];
	float TargetPosition[3];
	int t_Strength = 0;
	float t_Range = 0.0;

	GetClientAbsOrigin(target, SourcLoc);
	//else GetEntPropVector(target, Prop_Send, "m_vecOrigin", SourcLoc);
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", TargetPosition);

	if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[target] - AfxLevelReq);
	else t_Range = AfxRangeMax;
	if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
	else t_Range += AfxRangeBase;

	if (myCurrentTeam[target] == TEAM_SURVIVOR && target != client) {

		if (PlayerLevel[target] < AfxLevelReq) return;
		if (GetVectorDistance(SourcLoc, TargetPosition) > (t_Range / 2)) return;
	}

	int NumLivingEntities = 0;
	int rawStrength = 0;
	int abilityStrength = 0;
	if (isRaw == 0) {
		NumLivingEntities = LivingEntitiesInRange(client, SourcLoc, AfxRangeMax);
		if (AfxMultiplication == 1) {
			if (AfxStrengthTarget < 0.0) t_Strength = basedamage + (AfxStrength * NumLivingEntities);
			else t_Strength = RoundToCeil(basedamage + (AfxStrength * (NumLivingEntities * AfxStrengthTarget)));
		}
		else t_Strength = (basedamage + AfxStrength);
	}
	else {
		rawStrength = rawCommon * LivingEntitiesInRange(client, SourcLoc, AfxRangeMax, 1);
		rawStrength += rawPlayer * LivingEntitiesInRange(client, SourcLoc, AfxRangeMax, 4);
	}

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || PlayerLevel[i] < AfxLevelReq) continue;
		GetClientAbsOrigin(i, TargetPosition);

		if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[i] - AfxLevelReq);
		else t_Range = AfxRangeMax;
		if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
		else t_Range += AfxRangeBase;
		if (GetVectorDistance(SourcLoc, TargetPosition) > (t_Range / 2) || StrContains(negativeStatusEffects[i], "[Fl]", false) != -1) continue;		// player not within blast radius, takes no damage. Or playing is floating.

		// Because range can fluctuate, we want to get the # of entities within range for EACH player individually.
		if (isRaw == 0) {
			abilityStrength = t_Strength;
		}
		else {
			abilityStrength = rawStrength;
		}
		if (AfxStrengthLevel > 0.0) abilityStrength += RoundToCeil(abilityStrength * ((PlayerLevel[i] - AfxLevelReq) * AfxStrengthLevel));

		//if (t_Strength > GetClientHealth(i)) IncapacitateOrKill(i);
		//else SetEntityHealth(i, GetClientHealth(i) - t_Strength);
		if (abilityStrength > 0) SetClientTotalHealth(client, i, abilityStrength);

		if (client == target) {

			// To prevent a never-ending chain reaction, we don't allow it to target the bomber that caused it.

			if (myCurrentTeam[i] == TEAM_SURVIVOR && AfxChain == 1) CreateBomberExplosion(client, i, Effects);
		}
	}
	if (StrContains(Effects, "e", true) != -1 || StrContains(Effects, "x", true) != -1) {

		CreateExplosion(target);	// boom boom audio and effect on the location.
		if (!IsFakeClient(target)) ScreenShake(target);
	}
	if (StrContains(Effects, "B", true) != -1) {

		if (!ISBILED[target]) {

			SDKCall(g_hCallVomitOnPlayer, target, client, true);
			CreateTimer(15.0, Timer_RemoveBileStatus, target, TIMER_FLAG_NO_MAPCHANGE);
			ISBILED[target] = true;
			StaggerPlayer(target, client);
		}
	}
	if (StrContains(Effects, "a", true) != -1) {

		CreateDamageStatusEffect(client, 4, target, abilityStrength);
	}

	if (client == target) CreateBomberExplosion(client, 0, Effects);
}

stock CheckMinimumRate(client) {
	if (Rating[client] < 0) Rating[client] = 0;
}

stock float GetScoreMultiplier(int client) {
	if (GetArraySize(HandicapSelectedValues[client]) != 4) SetClientHandicapValues(client, true);
	float scoreMultiplier = (handicapLevel[client] > 0) ? GetArrayCell(HandicapSelectedValues[client], 3) : fNoHandicapScoreMultiplier;
	return scoreMultiplier;
}

stock GetRatingRewardForDamage(survivor, infected) {
	float myDamageContribution = CheckTeammateDamages(infected, survivor, true);
	if (myDamageContribution < fDamageContribution) return 0;
	
	int RatingRewardDamage = 0;
	float RatingMultiplier = 0.0;
	if (IsLegitimateClient(infected) && myCurrentTeam[infected] == TEAM_INFECTED) {
		if (FindZombieClass(infected) != ZOMBIECLASS_TANK) RatingMultiplier = fRatingMultSpecials;
		else RatingMultiplier = fRatingMultTank;
	}
	else if (IsWitch(infected)) RatingMultiplier = fRatingMultWitch;
	else if (IsSpecialCommon(infected)) RatingMultiplier = fRatingMultSupers;
	else if (IsCommonInfected(infected)) RatingMultiplier = fRatingMultCommons;

	RatingRewardDamage = RoundToFloor(myDamageContribution * 100.0);
	RatingRewardDamage = RoundToFloor(RatingRewardDamage * RatingMultiplier);
	return RatingRewardDamage;
}

stock CheckTankingDamage(infected, client) {

	int pos = -1;
	int cDamage = 0;

	bool bIsLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;
	bool bIsCommon;

	if (IsLegitimateClient(infected)) {
		pos = FindListPositionByEntity(infected, InfectedHealth[client]);
		bIsLegitimateClient = true;
	}
	else if (IsWitch(infected)) {
		pos = FindListPositionByEntity(infected, WitchDamage[client]);
		bIsWitch = true;
	}
	else if (IsSpecialCommon(infected)) {
		pos = FindListPositionByEntity(infected, SpecialCommon[client]);
		bIsSpecialCommon = true;
	}
	else if (IsCommonInfected(infected)) {
		pos = FindListPositionByEntity(infected, CommonInfected[client]);
		bIsCommon = true;
	}
	// Have decided commons shouldn't award tanking damage; it's too easy to abuse.

	if (pos < 0) return 0;

	if (bIsLegitimateClient) cDamage = GetArrayCell(InfectedHealth[client], pos, 3);
	else if (bIsWitch) cDamage = GetArrayCell(WitchDamage[client], pos, 3);
	else if (bIsSpecialCommon) cDamage = GetArrayCell(SpecialCommon[client], pos, 3);
	else if (bIsCommon) cDamage = GetArrayCell(CommonInfected[client], pos, 3);

	return cDamage;
}

stock GetRatingRewardForTanking(survivor, infected) {
	int damageReceived = 0;
	float RatingMultiplier = 0.0;
	int pos = -1;
	bool bIsLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;
	bool bIsCommon;
	if (IsLegitimateClient(infected) && myCurrentTeam[infected] == TEAM_INFECTED) {
		pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
		bIsLegitimateClient = true;
	}
	else if (IsWitch(infected)) {
		pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
		bIsWitch = true;
	}
	else if (IsSpecialCommon(infected)) {
		pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);
		bIsSpecialCommon = true;
	}
	else if (IsCommonInfected(infected)) {
		pos = FindListPositionByEntity(infected, CommonInfected[survivor]);
		bIsCommon = true;
	}
	if (pos < 0) return 0;

	if (bIsWitch) {
		damageReceived		= GetArrayCell(WitchDamage[survivor], pos, 3);
		RatingMultiplier = fRatingMultWitch;
	}
	else if (bIsSpecialCommon) {
		damageReceived		= GetArrayCell(SpecialCommon[survivor], pos, 3);
		RatingMultiplier = fRatingMultSupers;
	}
	else if (bIsCommon) {
		damageReceived		= GetArrayCell(CommonInfected[survivor], pos, 3);
		RatingMultiplier = fRatingMultCommons;
	}
	else if (bIsLegitimateClient) {
		damageReceived		= GetArrayCell(InfectedHealth[survivor], pos, 3);
		if (FindZombieClass(infected) != ZOMBIECLASS_TANK) RatingMultiplier = fRatingMultSpecials;
		else RatingMultiplier = fRatingMultTank;
	}
	int damageReceivedRequired = RoundToCeil(GetMaximumHealth(survivor) * fTankingContribution);
	if (damageReceived < damageReceivedRequired) return 0;

	int maxScore = RoundToFloor(100.0 * RatingMultiplier);
	if (damageReceived > maxScore) damageReceived = maxScore;
	return damageReceived;
}

stock GetRatingRewardForBuffing(survivor, infected) {
	float RatingMultiplier = 0.0;
	int pos = -1;
	bool bIsLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;
	bool bIsCommon;
	if (IsLegitimateClient(infected) && myCurrentTeam[infected] == TEAM_INFECTED) {
		pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
		bIsLegitimateClient = true;
	}
	else if (IsWitch(infected)) {
		pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
		bIsWitch = true;
	}
	else if (IsSpecialCommon(infected)) {
		pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);
		bIsSpecialCommon = true;
	}
	else if (IsCommonInfected(infected)) {
		pos = FindListPositionByEntity(infected, CommonInfected[survivor]);
		bIsCommon = true;
	}
	if (pos < 0) return 0;

	int buffingDone = 0;
	int tHealth = 0;
	if (bIsWitch) {
		buffingDone		= GetArrayCell(WitchDamage[survivor], pos, 7);
		tHealth			= GetArrayCell(WitchDamage[survivor], pos, 1);
		RatingMultiplier = fRatingMultWitch;
	}
	else if (bIsSpecialCommon) {
		buffingDone		= GetArrayCell(SpecialCommon[survivor], pos, 7);
		tHealth			= GetArrayCell(SpecialCommon[survivor], pos, 1);
		RatingMultiplier = fRatingMultSupers;
	}
	else if (bIsCommon) {
		buffingDone		= GetArrayCell(CommonInfected[survivor], pos, 7);
		tHealth			= GetArrayCell(CommonInfected[survivor], pos, 1);
		RatingMultiplier = fRatingMultCommons;
	}
	else if (bIsLegitimateClient) {
		buffingDone		= GetArrayCell(InfectedHealth[survivor], pos, 7);
		tHealth			= GetArrayCell(InfectedHealth[survivor], pos, 1);
		if (FindZombieClass(infected) != ZOMBIECLASS_TANK) RatingMultiplier = fRatingMultSpecials;
		else RatingMultiplier = fRatingMultTank;
	}
	float fBuffContribution = (buffingDone * 1.0) / (tHealth * 1.0);
	if (fBuffContribution < fBuffingContribution) return 0;
	if (fBuffContribution > 1.0) fBuffContribution = 1.0;
	
	int score = RoundToFloor((100.0 * RatingMultiplier) * fBuffContribution);
	return score;
}

stock GetRatingRewardForHealing(survivor, infected) {
	int healingProvided = 0;
	float RatingMultiplier = 0.0;
	int pos = -1;
	bool bIsLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;
	bool bIsCommon;
	if (IsLegitimateClient(infected) && myCurrentTeam[infected] == TEAM_INFECTED) {
		pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
		bIsLegitimateClient = true;
	}
	else if (IsWitch(infected)) {
		pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
		bIsWitch = true;
	}
	else if (IsSpecialCommon(infected)) {
		pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);
		bIsSpecialCommon = true;
	}
	else if (IsCommonInfected(infected)) {
		pos = FindListPositionByEntity(infected, CommonInfected[survivor]);
		bIsCommon = true;
	}
	if (pos < 0) return 0;

	int infectedDamageDealt = -1;

	if (bIsWitch) {
		healingProvided		= GetArrayCell(WitchDamage[survivor], pos, 8);
		RatingMultiplier = fRatingMultWitch;

		infectedDamageDealt = FindListPositionByEntity(infected, damageOfWitch);
		if (infectedDamageDealt == -1) return 0;
		infectedDamageDealt = GetArrayCell(damageOfWitch, infectedDamageDealt, 1);
	}
	else if (bIsSpecialCommon) {
		healingProvided		= GetArrayCell(SpecialCommon[survivor], pos, 8);
		RatingMultiplier = fRatingMultSupers;

		infectedDamageDealt = FindListPositionByEntity(infected, damageOfSpecialCommon);
		if (infectedDamageDealt == -1) return 0;
		infectedDamageDealt = GetArrayCell(damageOfSpecialCommon, infectedDamageDealt, 1);
	}
	else if (bIsCommon) {
		healingProvided		= GetArrayCell(CommonInfected[survivor], pos, 8);
		RatingMultiplier = fRatingMultCommons;

		infectedDamageDealt = FindListPositionByEntity(infected, damageOfCommonInfected);
		if (infectedDamageDealt == -1) return 0;
		infectedDamageDealt = GetArrayCell(damageOfCommonInfected, infectedDamageDealt, 1);
	}
	else if (bIsLegitimateClient) {
		healingProvided		= GetArrayCell(InfectedHealth[survivor], pos, 8);
		if (FindZombieClass(infected) != ZOMBIECLASS_TANK) RatingMultiplier = fRatingMultSpecials;
		else RatingMultiplier = fRatingMultTank;

		infectedDamageDealt = FindListPositionByEntity(infected, damageOfSpecialInfected);
		if (infectedDamageDealt == -1) return 0;
		infectedDamageDealt = GetArrayCell(damageOfSpecialInfected, infectedDamageDealt, 1);
	}
	float fHealContribution = (healingProvided * 1.0) / (infectedDamageDealt * 1.0);
	if (fHealContribution < fHealingContribution) return 0;
	if (fHealContribution > 1.0) fHealContribution = 1.0;

	int score = RoundToFloor((100.0 * RatingMultiplier) * fHealContribution);
	return score;
}

void CalculateInfectedDamageAward(int client, int killerblow = 0, int entityPos = -1) {
	bool IsLegitimateClientClient = IsLegitimateClient(client);
	int clientTeam = -1;
	if (IsLegitimateClientClient) clientTeam = myCurrentTeam[client];
	int clientZombieClass = -1;
	if (clientTeam != -1) clientZombieClass = FindZombieClass(client);
	int ClientType = (IsLegitimateClientClient && clientTeam == TEAM_INFECTED) ? 0 :
					 (IsWitch(client)) ? 1 :
					 (IsSpecialCommon(client)) ? 2 : 
					 (IsCommonInfected(client)) ? 3 : -1;
	if (ClientType == -1) {
		LogMessage("Invalid clienttype");
		return;
	}
	bool IsLegitimateClientKiller = IsLegitimateClient(killerblow);
	int killerClientTeam = -1;
	if (IsLegitimateClientKiller) killerClientTeam = myCurrentTeam[killerblow];
	/*if (ClientType >= 0 && IsLegitimateClientKiller && killerClientTeam == TEAM_SURVIVOR) {
		if (isQuickscopeKill(killerblow)) {
			// If the user met the server operators standards for a quickscope kill, we do something.
			GetAbilityStrengthByTrigger(killerblow, client, "quickscope");
		}
	}*/
	//CreateItemRoll(client, killerblow);	// all infected types can generate an item roll
	float SurvivorPoints = 0.0;
	int SurvivorExperience = 0;
	float PointsMultiplier = fPointsMultiplier;
	float ExperienceMultiplier = SurvivorExperienceMult;
	float TankingMultiplier = SurvivorExperienceMultTank;
	//new Float:HealingMultiplier = SurvivorExperienceMultHeal;
	//new Float:RatingReductionMult = 0.0;
	int t_Contribution = 0;
	float TheAbilityMultiplier = 0.0;
	if (IsLegitimateClientKiller && ClientType == 0 && killerClientTeam == TEAM_SURVIVOR) {
		GetAbilityStrengthByTrigger(killerblow, client, "specialkill");
		TheAbilityMultiplier = GetAbilityMultiplier(killerblow, "I");
		if (TheAbilityMultiplier > 0.0) { // heal because you dealt the killing blow
			HealPlayer(killerblow, killerblow, TheAbilityMultiplier * GetMaximumHealth(killerblow), 'h', true);
		}
		TheAbilityMultiplier = GetAbilityMultiplier(killerblow, "l");
		if (TheAbilityMultiplier > 0.0) {
			// Creates fire on the target and deals AOE explosion.
			CreateExplosion(client, RoundToCeil(lastBaseDamage[killerblow] * TheAbilityMultiplier), killerblow, true);
			CreateFireEx(client);
		}
	}
	//new owner = 0;
	//if (IsLegitimateClientAlive(commonkiller) && GetClientTeam(commonkiller) == TEAM_SURVIVOR) owner = commonkiller;
	float i_DamageContribution = 0.0000;
	// If it's a special common, we activate its death abilities.
	if (ClientType == 2) {
		char TheEffect[10];
		GetCommonValueAtPos(TheEffect, sizeof(TheEffect), client, SUPER_COMMON_AURA_EFFECT);
		CreateBomberExplosion(client, client, TheEffect);	// bomber aoe
	}
	int iLivingSurvivors = LivingSurvivors();
	//decl String:MyName[64];
	char killerName[64];
	char killedName[64];
	if (ClientType != 3 && (ClientType > 0 || IsLegitimateClientClient)) {
		if (IsLegitimateClientClient) GetClientName(client, killedName, sizeof(killedName));
		else {
			if (ClientType == 1) Format(killedName, sizeof(killedName), "Witch");
			else {
				GetCommonValueAtPos(killedName, sizeof(killedName), client, SUPER_COMMON_NAME);
				Format(killedName, sizeof(killedName), "Common %s", killedName);
			}
		}
		// if (IsLegitimateClientKiller) {
		// 	GetClientName(killerblow, killerName, sizeof(killerName));
		// 	PrintToChatAll("%t", "player killed special infected", blue, killerName, white, orange, killedName);
		// }
		// else if (ClientType != 2) {
		// 	PrintToChatAll("%t", "killed special infected", orange, killedName, white);
		// }
		if (iClientTypeToDisplayOnKill == -1 || ClientType <= iClientTypeToDisplayOnKill) {
			if (!IsLegitimateClientKiller) PrintToChatAll("%t", "killed special infected", orange, killedName, white);
			else {
				GetFormattedPlayerName(killerblow, killerName, sizeof(killerName));
				char advertisement[512];
				Format(advertisement, sizeof(advertisement), "%t", "player killed special infected", blue, killerName, white, orange, killedName);
				for (int i = 1; i <= MaxClients; i++) {
					if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
					Client_PrintToChat(i, true, advertisement);
				}
				//PrintToChatAll("%t", "player killed special infected", blue, killerName, white, orange, killedName);
			}
		}
	}
	bool survivorsRequiredForBonusRating = (iLivingSurvivors > iTeamRatingRequired) ? true : false;
	bool bSomeoneHurtThisInfected = false;
	
	for (int i = 1; i <= MaxClients; i++) {
		int SurvivorDamage = 0;
		int pos = -1;
		int RatingBonusTank = 0;
		int RatingBonusBuffing = 0;
		int RatingBonusHealing = 0;
		int RatingBonus = 0;
		int RatingTeamBonus = 0;
		int RatingTeamBonusTank = 0;
		int RatingTeamBonusBuffing = 0;
		int RatingTeamBonusHealing = 0;
		SurvivorExperience = 0;
		SurvivorPoints = 0.0;
		i_DamageContribution = 0.0000;
		if (!IsLegitimateClient(i) || myCurrentTeam[i] != TEAM_SURVIVOR) continue;
		if (ClientType == 0) pos = FindListPositionByEntity(client, InfectedHealth[i]);
		else if (ClientType == 1) pos = FindListPositionByEntity(client, WitchDamage[i]);
		else if (ClientType == 2) pos = FindListPositionByEntity(client, SpecialCommon[i]);
		else if (ClientType == 3) pos = FindListPositionByEntity(client, CommonInfected[i]);
		if (pos < 0) continue;
		if (IsPlayerAlive(i)) {
			// if (bIsInCheckpoint[i]) {
			// 	if (ClientType == 0) RemoveFromArray(Handle:InfectedHealth[i], pos);
			// 	else if (ClientType == 1) RemoveFromArray(Handle:WitchDamage[i], pos);
			// 	else if (ClientType == 2) RemoveFromArray(Handle:SpecialCommon[i], pos);
			// 	continue;
			// }
			if (LastAttackedUser[i] == client) LastAttackedUser[i] = -1;
			if (ClientType == 0) SurvivorDamage = GetArrayCell(InfectedHealth[i], pos, 2);
			else if (ClientType == 1) SurvivorDamage = GetArrayCell(WitchDamage[i], pos, 2);
			else if (ClientType == 2) SurvivorDamage = GetArrayCell(SpecialCommon[i], pos, 2);
			else if (ClientType == 3) SurvivorDamage = GetArrayCell(CommonInfected[i], pos, 2);
			// to prevent abuse farming of higher handicap levels, players must contribute a certain percentage in at least one category.
			float scoreMult = GetScoreMultiplier(i);

			if (scoreMult > 0.0) {
				RatingBonus = RoundToCeil(GetRatingRewardForDamage(i, client) * scoreMult);
				RatingBonusTank = RoundToCeil(GetRatingRewardForTanking(i, client) * scoreMult);
				if (ClientType <= 1) {
					RatingBonusBuffing = RoundToCeil(GetRatingRewardForBuffing(i, client) * scoreMult);
					RatingBonusHealing = RoundToCeil(GetRatingRewardForHealing(i, client) * scoreMult);
				}
			}
			if (iAntiFarmMax > 0) {
				if (CheckKillPositions(i)) continue;
				CheckKillPositions(i, true);
			}
			if (killerblow != i) GetAbilityStrengthByTrigger(i, client, "assist");
			if (RatingBonus > 0 || RatingBonusTank > 0 || RatingBonusBuffing > 0 || RatingBonusHealing > 0) RollLoot(i, client);
			if (!bSomeoneHurtThisInfected) bSomeoneHurtThisInfected = true;
			CheckMinimumRate(i);
			if (PlayerLevel[i] >= iLevelRequiredToEarnScore || handicapLevel[i] > 0) {
				
				char ratingBonusText[64];
				char ratingBonusTankText[64];
				char ratingBonusBuffingText[64];
				char ratingBonusHealingText[64];
				if (!survivorsRequiredForBonusRating) {
					if (RatingBonus > 0) {
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonus, ratingBonusText, sizeof(ratingBonusText));
							Format(ratingBonusText, sizeof(ratingBonusText), "%T", "rating increase", i, white, blue, ratingBonusText, orange);
						}
						Rating[i] += RatingBonus;
					}
					if (RatingBonusTank > 0) {
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonusTank, ratingBonusTankText, sizeof(ratingBonusTankText));
							Format(ratingBonusTankText, sizeof(ratingBonusTankText), "%T", "rating increase for tanking", i, white, blue, ratingBonusTankText, orange);
						}
						Rating[i] += RatingBonusTank;
					}
					if (RatingBonusBuffing > 0) {
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonusBuffing, ratingBonusBuffingText, sizeof(ratingBonusBuffingText));
							Format(ratingBonusBuffingText, sizeof(ratingBonusBuffingText), "%T", "rating increase for buffing", i, white, blue, ratingBonusBuffingText, orange);
						}
						Rating[i] += RatingBonusBuffing;
					}
					if (RatingBonusHealing > 0) {
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonusHealing, ratingBonusHealingText, sizeof(ratingBonusHealingText));
							Format(ratingBonusHealingText, sizeof(ratingBonusHealingText), "%T", "rating increase for healing", i, white, blue, ratingBonusHealingText, orange);
						}
						Rating[i] += RatingBonusHealing;
					}
				}
				else {
					if (RatingBonus > 0) {
						RatingTeamBonus = RoundToCeil(RatingBonus * ((iLivingSurvivors - iTeamRatingRequired) * fTeamRatingBonus));
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonus+RatingTeamBonus, ratingBonusText, sizeof(ratingBonusText));
							Format(ratingBonusText, sizeof(ratingBonusText), "%T", "rating increase", i, white, blue, ratingBonusText, orange);
						}
						Rating[i] += RatingBonus;
					}
					if (RatingBonusTank > 0) {
						RatingTeamBonusTank = RoundToCeil(RatingBonusTank * ((iLivingSurvivors - iTeamRatingRequired) * fTeamRatingBonus));
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonusTank+RatingTeamBonusTank, ratingBonusTankText, sizeof(ratingBonusTankText));
							Format(ratingBonusTankText, sizeof(ratingBonusTankText), "%T", "rating increase for tanking", i, white, blue, ratingBonusTankText, orange);
						}
						Rating[i] += RatingBonusTank;
					}
					if (RatingBonusBuffing > 0) {
						RatingTeamBonusBuffing = RoundToCeil(RatingBonusBuffing * ((iLivingSurvivors - iTeamRatingRequired) * fTeamRatingBonus));
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonusBuffing+RatingTeamBonusBuffing, ratingBonusBuffingText, sizeof(ratingBonusBuffingText));
							Format(ratingBonusBuffingText, sizeof(ratingBonusBuffingText), "%T", "rating increase for buffing", i, white, blue, ratingBonusBuffingText, orange);
						}
						Rating[i] += RatingBonusBuffing;
					}
					if (RatingBonusHealing > 0) {
						RatingTeamBonusHealing = RoundToCeil(RatingBonusHealing * ((iLivingSurvivors - iTeamRatingRequired) * fTeamRatingBonus));
						if (ClientType < iClientTypeToDisplayOnKill) {
							AddCommasToString(RatingBonusHealing+RatingTeamBonusHealing, ratingBonusHealingText, sizeof(ratingBonusHealingText));
							Format(ratingBonusHealingText, sizeof(ratingBonusHealingText), "%T", "rating increase for healing", i, white, blue, ratingBonusHealingText, orange);
						}
						Rating[i] += RatingBonusHealing;
					}
				}
				if (!IsFakeClient(i) && ClientType < iClientTypeToDisplayOnKill) {
					bool isModified = false;
					char printer[512];
					if (RatingBonus > 0) {
						isModified = true;
						Format(printer, sizeof(printer), "%s", ratingBonusText);
					}
					if (RatingBonusTank > 0) {
						if (isModified) Format(printer, sizeof(printer), "%s\n%s", printer, ratingBonusTankText);
						else {
							Format(printer, sizeof(printer), "%s", ratingBonusTankText);
							isModified = true;
						}
					}
					if (RatingBonusBuffing > 0) {
						if (isModified) Format(printer, sizeof(printer), "%s\n%s", printer, ratingBonusBuffingText);
						else {
							Format(printer, sizeof(printer), "%s", ratingBonusBuffingText);
							isModified = true;
						}
					}
					if (RatingBonusHealing > 0) {
						if (isModified) Format(printer, sizeof(printer), "%s\n%s", printer, ratingBonusHealingText);
						else Format(printer, sizeof(printer), "%s", ratingBonusHealingText);
					}
					if (isModified) PrintToChat(i, "%s", printer);
				}
			}
			bIsSettingsCheck = true;		// whenever rating is earned for anything other than common infected kills, we want to check the settings to see if a boost to commons is necessary.
			if (i == killerblow) {
				TheAbilityMultiplier = GetAbilityMultiplier(i, "R");
				if (TheAbilityMultiplier > 0.0) { // heal because you dealt the killing blow
					HealPlayer(i, i, TheAbilityMultiplier * RatingBonus, 'h', true);
				}
			}
			// if (SurvivorDamage > 0) {
			// 	SurvivorExperience = RoundToFloor(SurvivorDamage * ExperienceMultiplier);
			// 	SurvivorPoints = SurvivorDamage * PointsMultiplier;
			// }
			i_DamageContribution = CheckTeammateDamages(client, i, true);
			if (i_DamageContribution > 0.0) {
				SurvivorExperience = RoundToFloor(SurvivorDamage * ExperienceMultiplier);
				SurvivorPoints = SurvivorDamage * PointsMultiplier;
			}
			if (ClientType != 3 && RatingBonusTank > 0) {
				t_Contribution = CheckTankingDamage(client, i);
				if (t_Contribution > 0) {
					t_Contribution = RoundToCeil(t_Contribution * TankingMultiplier);
					SurvivorPoints += (t_Contribution * (PointsMultiplier * TankingMultiplier));
				}
			}
			//h_Contribution = HealingContribution[i];
			//HealingContribution[i] = 0;
			//CreateLootItem(i, i_DamageContribution, CheckTankingDamage(client, i), RoundToCeil(h_Contribution * HealingMultiplier));
			// if (h_Contribution > 0) {
			// 	h_Contribution = RoundToCeil(h_Contribution * HealingMultiplier);
			// 	SurvivorPoints += (h_Contribution * (PointsMultiplier * HealingMultiplier));
			// }
			//if (!bIsInCombat[i]) ReceiveInfectedDamageAward(i, client, SurvivorExperience, SurvivorPoints, t_Contribution, h_Contribution, Bu_Contribution, He_Contribution);
			//HealingContribution[i] += h_Contribution;
			TankingContribution[i] += t_Contribution;
			PointsContribution[i] += SurvivorPoints;
			DamageContribution[i] += SurvivorExperience;
		}
		if (ClientType == 0) RemoveFromArray(InfectedHealth[i], pos);
		else if (ClientType == 1) RemoveFromArray(WitchDamage[i], pos);
		else if (ClientType == 2) {
			RemoveFromArray(SpecialCommon[i], pos);
			pos			= FindListPositionByEntity(client, CommonInfected[i]);
			if (pos >= 0) RemoveFromArray(CommonInfected[i], pos);
		}
		else if (ClientType == 3) RemoveFromArray(CommonInfected[i], pos);
		//if (!bIsInCombat[i]) AwardExperience(i);
	}
	if (bSomeoneHurtThisInfected) {
		if (ClientType == 0) {
			SpecialsKilled++;
			ReadyUp_NtvStatistics(killerblow, 6, 1);
			if (clientZombieClass != ZOMBIECLASS_TANK) SetArrayCell(RoundStatistics, 3, GetArrayCell(RoundStatistics, 3) + 1);
			else SetArrayCell(RoundStatistics, 4, GetArrayCell(RoundStatistics, 4) + 1);

			if (IsFakeClient(client)) {
				float fDirectorPointsEarned = (DamageContribution[client] * fPointsMultiplierInfected);
				if (!IsSurvivalMode && iEnrageTime > 0 && RPGRoundTime() >= iEnrageTime) fDirectorPointsEarned *= fEnrageDirectorPoints;
				if (fDirectorPointsEarned > 0.0) {
					Points_Director += fDirectorPointsEarned;
					// decl String:InfectedName[64];
					// GetClientName(client, InfectedName, sizeof(InfectedName));
					// PrintToChatAll("%t", "director points earned", orange, green, fDirectorPointsEarned, orange, InfectedName);
					DamageContribution[client] = 0;
				}
			}
		}
		else if (ClientType == 1) SetArrayCell(RoundStatistics, 2, GetArrayCell(RoundStatistics, 2) + 1);
		else if (ClientType == 2) {
			if (CommonInfectedModel(client, FALLEN_SURVIVOR_MODEL) && killerClientTeam == TEAM_SURVIVOR) {
				float fModifiedDefibChance = fFallenSurvivorDefibChance;
				int curLuck = GetTalentStrength(killerblow, "luck");
				if (curLuck > 0) fModifiedDefibChance += (curLuck * fFallenSurvivorDefibChanceLuck);
				if (GetRandomInt(1, RoundToCeil(1.0 / fModifiedDefibChance)) == 1) {
					int defib = CreateEntityByName("weapon_defibrillator_spawn");
					float vel[3];
					vel[0] = GetRandomFloat(-10000.0, 1000.0);
					vel[1] = GetRandomFloat(-1000.0, 1000.0);
					vel[2] = GetRandomFloat(100.0, 1000.0);

					float Origin[3];
					GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
					Origin[2] += 32.0;
					DispatchKeyValue(defib, "spawnflags", "1");
					DispatchSpawn(defib);
					ActivateEntity(defib);
					TeleportEntity(defib, Origin, NULL_VECTOR, vel);
				}
			}
			ReadyUp_NtvStatistics(killerblow, 2, 1);
			SetArrayCell(RoundStatistics, 1, GetArrayCell(RoundStatistics, 1) + 1);
		}
		else if (ClientType == 3) {
			ReadyUp_NtvStatistics(killerblow, 2, 1);
			SetArrayCell(RoundStatistics, 0, GetArrayCell(RoundStatistics, 0) + 1);
		}
	}
	if (ClientType == 1) {
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		//SDKUnhook(client, SDKHook_TraceAttack, OnTraceAttack);
		AcceptEntityInput(client, "Kill");
		if (entityPos >= 0) RemoveFromArray(WitchList, entityPos);		// Delete the witch. Forever.
	}
	if (IsLegitimateClientClient && clientTeam == TEAM_INFECTED) {

		if (clientZombieClass == ZOMBIECLASS_TANK) bIsDefenderTank[client] = false;

		if (iTankRush != 1 && clientZombieClass == ZOMBIECLASS_TANK && DirectorTankCooldown > 0.0 && f_TankCooldown == -1.0) {

			f_TankCooldown				=	DirectorTankCooldown;

			CreateTimer(1.0, Timer_TankCooldown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		ClearArray(TankState_Array[client]);
		MyBirthday[client] = 0;
		CreateMyHealthPool(client, true);
		ChangeHook(client);
		ForcePlayerSuicide(client);

		if (b_IsFinaleActive && GetInfectedCount(ZOMBIECLASS_TANK) < 1) {

			b_IsFinaleTanks = true;	// next time the event tank spawns, it will allow it to spawn multiple tanks.
		}
	}
	int damagePos = (ClientType == 0) ? FindListPositionByEntity(client, damageOfSpecialInfected) :
					(ClientType == 1) ? FindListPositionByEntity(client, damageOfWitch) :			// if below, ClientType = 3
					(ClientType == 2) ? FindListPositionByEntity(client, damageOfSpecialCommon) : FindListPositionByEntity(client, damageOfCommonInfected);
	if (damagePos >= 0) {
		if (ClientType == 0) RemoveFromArray(damageOfSpecialInfected, damagePos);
		else if (ClientType == 1) RemoveFromArray(damageOfWitch, damagePos);
		else if (ClientType == 2) RemoveFromArray(damageOfSpecialCommon, damagePos);
		else RemoveFromArray(damageOfCommonInfected, damagePos);
	}
}

stock ReceiveInfectedDamageAward(client, infected, e_reward, float p_reward, t_reward, h_reward , bu_reward, he_reward, bool TheRoundHasEnded = false) {
	int RPGMode									= iRPGMode;
	if (RPGMode < 0) return;
	//new RPGBroadcast							= StringToInt(GetConfigValue("award broadcast?"));
	char InfectedName[64];
	//decl String:InfectedTeam[64];
	int enemytype = -1;
	if (infected > 0) {
		if (IsLegitimateClient(infected)) {
			GetClientName(infected, InfectedName, sizeof(InfectedName));
			enemytype = 3;
		}
		else if (IsWitch(infected)) {
			Format(InfectedName, sizeof(InfectedName), "Witch");
			enemytype = 2;
		}
		else if (IsSpecialCommon(infected)) {
			GetCommonValueAtPos(InfectedName, sizeof(InfectedName), infected, SUPER_COMMON_NAME);
			enemytype = 1;
		}
		else if (IsCommonInfected(infected)) {
			Format(InfectedName, sizeof(InfectedName), "Common");
			enemytype = 0;
		}
		Format(InfectedName, sizeof(InfectedName), "%s %s", sDirectorTeam, InfectedName);
	}
	//new Float:fRoundMultiplier = 1.0;
	if (RoundExperienceMultiplier[client] > 0.0) {
		//fRoundMultiplier += RoundExperienceMultiplier[client];
		if (e_reward > 0) e_reward = RoundToCeil(e_reward * RoundExperienceMultiplier[client]);
		if (h_reward > 0) h_reward = RoundToCeil(h_reward * RoundExperienceMultiplier[client]);
		if (t_reward > 0) t_reward = RoundToCeil(t_reward * RoundExperienceMultiplier[client]);
		if (bu_reward > 0) bu_reward = RoundToCeil(bu_reward * RoundExperienceMultiplier[client]);
		if (he_reward > 0) he_reward = RoundToCeil(he_reward * RoundExperienceMultiplier[client]);
	}
	int RestedAwardBonus = 0;
	if (RestedExperience[client] > 0) {
		if (e_reward > 0) RestedAwardBonus = RoundToFloor(e_reward * fRestedExpMult);
		if (h_reward > 0) RestedAwardBonus += RoundToFloor(h_reward * fRestedExpMult);
		if (t_reward > 0) RestedAwardBonus += RoundToFloor(t_reward * fRestedExpMult);
		if (bu_reward > 0) RestedAwardBonus += RoundToFloor(bu_reward * fRestedExpMult);
		if (he_reward > 0) RestedAwardBonus += RoundToFloor(he_reward * fRestedExpMult);

		if (RestedAwardBonus >= RestedExperience[client]) {
			RestedAwardBonus = RestedExperience[client];
			RestedExperience[client] = 0;
		}
		else if (RestedAwardBonus < RestedExperience[client]) {
			RestedExperience[client] -= RestedAwardBonus;
		}
	}
	int ExperienceBooster = (e_reward > 0) ? RoundToFloor(e_reward * CheckExperienceBooster(client, e_reward)) : 0;
	if (ExperienceBooster < 1) ExperienceBooster = 0;
	//new Float:TeammateBonus = 0.0;//(LivingSurvivors() - 1) * fSurvivorExpMult;
	float multiplierBonus = 0.0;
	int theCount = LivingSurvivorCount();
	if (iSurvivorModifierRequired > 0 && fSurvivorExpMult > 0.0 && theCount >= iSurvivorModifierRequired) {
		float TeammateBonus = (theCount - (iSurvivorModifierRequired - 1)) * fSurvivorExpMult;
		if (TeammateBonus > 0.0) multiplierBonus += TeammateBonus;
	}
	if (IsGroupMember[client] && GroupMemberBonus > 0.0) multiplierBonus += GroupMemberBonus;
	if (!BotsOnSurvivorTeam() && TotalHumanSurvivors() <= iSurvivorBotsBonusLimit && fSurvivorBotsNoneBonus > 0.0) multiplierBonus += fSurvivorBotsNoneBonus;

	if (multiplierBonus > 0.0) {
		if (e_reward > 0) e_reward += RoundToCeil(multiplierBonus * e_reward);
		if (h_reward > 0) h_reward += RoundToCeil(multiplierBonus * h_reward);
		if (t_reward > 0) t_reward += RoundToCeil(multiplierBonus * t_reward);
		if (bu_reward > 0) bu_reward += RoundToCeil(multiplierBonus * bu_reward);
		if (he_reward > 0) he_reward += RoundToCeil(multiplierBonus * he_reward);
	}
	if (e_reward < 1) e_reward = 0;
	if (h_reward < 1) h_reward = 0;
	if (t_reward < 1) t_reward = 0;
	if (bu_reward < 1) bu_reward = 0;
	if (he_reward < 1) he_reward = 0;
	//h_reward = RoundToCeil(GetClassMultiplier(client, h_reward * 1.0, "hXP"));
	//t_reward = RoundToCeil(GetClassMultiplier(client, t_reward * 1.0, "tXP"));
	//if (!TheRoundHasEnded) {
	// Previously, if a player completed a round without ever leaving combat, they would receive no bonus container.
	BonusContainer[client] = 0;	// if the player enables it mid-match, this ensures the bonus container is always 0 for paused levelers.
	//	0 = Points Only
	//	1 = RPG Only
	//	2 - RPG + Points
	if (RPGMode > 0 && (iExperienceLevelCap < 1 || PlayerLevel[client] < iExperienceLevelCap)) {
		if (!TheRoundHasEnded && DisplayType > 0 && (infected == 0 || enemytype > 0)) {								// \x04Jockey \x01killed: \x04 \x03experience
			char rewardText[64];
			if (e_reward > 0) {
				AddCommasToString(e_reward, rewardText, sizeof(rewardText));
				if (infected > 0) PrintToChat(client, "%T", "base experience reward", client, orange, InfectedName, white, green, rewardText, blue);
				else if (infected == 0) PrintToChat(client, "%T", "damage experience reward", client, orange, green, white, green, rewardText, blue);
			}
			if (DisplayType == 2) {
				if (RestedAwardBonus > 0) {
					AddCommasToString(RestedAwardBonus, rewardText, sizeof(rewardText));
					PrintToChat(client, "%T", "rested experience reward", client, green, white, green, rewardText, blue);
				}
				if (ExperienceBooster > 0) {
					AddCommasToString(ExperienceBooster, rewardText, sizeof(rewardText));
					PrintToChat(client, "%T", "booster experience reward", client, green, white, green, rewardText, blue);
				}
			}
			if (t_reward > 0) {
				AddCommasToString(t_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "tanking experience reward", client, green, white, green, rewardText, blue);
			}
			if (h_reward > 0) {
				AddCommasToString(h_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "healing experience reward", client, green, white, green, rewardText, blue);
			}
			if (bu_reward > 0) {
				AddCommasToString(bu_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "buffing experience reward", client, green, white, green, rewardText, blue);
			}
			if (he_reward > 0) {
				AddCommasToString(he_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "hexing experience reward", client, green, white, green, rewardText, blue);
			}
		}
		int TotalExperienceEarned = (e_reward + RestedAwardBonus + ExperienceBooster + t_reward + h_reward + bu_reward + he_reward);
 		ExperienceLevel[client] += TotalExperienceEarned;
		ExperienceOverall[client] += TotalExperienceEarned;
		//GetProficiencyData(client, GetWeaponProficiencyType(client), TotalExperienceEarned);
		ConfirmExperienceAction(client, TheRoundHasEnded);
	}
	if (!TheRoundHasEnded && RPGMode >= 0 && RPGMode != 1 && p_reward > 0.0) {
		Points[client] += p_reward;
		if (DisplayType > 0 && (infected == 0 || enemytype > 0)) PrintToChat(client, "%T", "points from damage reward", client, green, white, green, p_reward, blue);
	}
}

stock GetBulletOrMeleeHealAmount(healer, target, damage, damagetype, int hitgroup = -1) {
	if (damagetype & DMG_BULLET || damagetype & DMG_SLASH || damagetype & DMG_CLUB) {
		//GetBaseWeaponDamage(client, target, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET, _, true, hitgroup, isHealing);
		int iHealerAmount = GetBaseWeaponDamage(healer, target, _, _, _, damagetype, _, _, hitgroup, true);
		return iHealerAmount;
	}
	return 0;
}

// Curious RPG System option?
// Points earned from hurting players used to unlock abilities, while experienced earned to increase level determines which abilities a player has access to.
// This way, even if the level is different, everyone starts with the same footing.
// Optional RPG System. Maybe call it "buy rpg mode?"
stock bool SameTeam_OnTakeDamage(healer, target, damage, bool IsDamageTalent = false, int damagetype = -1, int hitgroup) {
	//if (!AllowShotgunToTriggerNodes(healer)) return false;
	//if (HealImmunity[target] ||
	if (bIsInCheckpoint[target]) return true;
	int iHealerAmount = GetBulletOrMeleeHealAmount(healer, target, damage, damagetype, hitgroup);
	if (iHealerAmount < 1) return true;
	if (iHealingPlayerInCombatPutInCombat == 1 && bIsInCombat[target]) {
		CombatTime[healer] = GetEngineTime() + fOutOfCombatTime;
		bIsInCombat[healer] = true;
	}
	if (StrContains(MyCurrentWeapon[healer], "pistol", false) == -1) GiveAmmoBack(healer, 1);
	HealPlayer(target, healer, iHealerAmount * 1.0, 'h', true);
	if (IsDamageTalent) {
		GetAbilityStrengthByTrigger(healer, target, "d", FindZombieClass(healer), iHealerAmount);
		if (damagetype & DMG_CLUB) GetAbilityStrengthByTrigger(healer, target, "U", _, iHealerAmount);
		if (damagetype & DMG_SLASH) GetAbilityStrengthByTrigger(healer, target, "u", _, iHealerAmount);
	}
	if (LastAttackedUser[healer] == target) ConsecutiveHits[healer]++;
	else {
		LastAttackedUser[healer] = target;
		ConsecutiveHits[healer] = 0;
	}
	return true;
}
