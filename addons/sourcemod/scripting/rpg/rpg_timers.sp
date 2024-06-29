/* put the line below after all of the includes!
#pragma newdecls required
*/

public Action Timer_ZeroGravity(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		ModifyGravity(client);
	}
	//ZeroGravityTimer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

public Action Timer_ResetCrushImmunity(Handle timer, any client) {
	if (IsLegitimateClient(client)) bIsCrushCooldown[client] = false;
	return Plugin_Stop;
}

public Action Timer_ResetBurnImmunity(Handle timer, any client) {

	if (IsLegitimateClient(client)) bIsBurnCooldown[client] = false;
	return Plugin_Stop;
}

public Action Timer_HealImmunity(Handle timer, any client) {

	if (IsLegitimateClient(client)) {

		HealImmunity[client] = false;
	}
	return Plugin_Stop;
}

// public Action Timer_IsMeleeCooldown(Handle timer, any client) {

// 	if (IsLegitimateClient(client)) { bIsMeleeCooldown[client] = false; }
// 	return Plugin_Stop;
// }

public Action Timer_ResetShotgunCooldown(Handle timer, any client) {
	if (IsLegitimateClient(client)) shotgunCooldown[client] = false;
	return Plugin_Stop;
}

void VerifyMinimumRating(int client, bool setMinimumRating = false) {
	int minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
	if (setMinimumRating || Rating[client] < minimumRating) Rating[client] = minimumRating;
}

// bool:AllowShotgunToTriggerNodes(client) {
// 	new bool:isshotgun = IsPlayerUsingShotgun(client);
// 	if (!isshotgun || isshotgun && !shotgunCooldown[client]) return true;
// 	return false;
// }

stock void CheckDifficulty() {
	char Difficulty[64];
	GetConVarString(FindConVar("z_difficulty"), Difficulty, sizeof(Difficulty));
	if (!StrEqual(Difficulty, sServerDifficulty, false)) SetConVarString(FindConVar("z_difficulty"), sServerDifficulty);
}

stock void GiveProfileItems(int client) {
	if (GetArraySize(hWeaponList[client]) == 2) {
		char text[64];
		GetArrayString(hWeaponList[client], 0, text, sizeof(text));
		if (!StrEqual(text, "none")) {
			QuickCommandAccessEx(client, text, _, true);
		}
		GetArrayString(hWeaponList[client], 1, text, sizeof(text));
		if (!StrEqual(text, "none")) {
			QuickCommandAccessEx(client, text, _, true);
		}
	}
}

public Action Timer_GiveLaserBeam(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
	}
	return Plugin_Stop;
}

/*public Action:Timer_DisplayHUD(Handle:timer) {

	if (!b_IsActiveRound) return Plugin_Stop;
	static iRotation = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && !IsFakeClient(i)) {

			if (GetClientTeam(i) == TEAM_SURVIVOR) {

				DisplayHUD(i, iRotation);
				if (bIsGiveProfileItems[i]) {

					bIsGiveProfileItems[i] = false;
					GiveProfileItems(i);
				}
			}
			else if (GetClientTeam(i) == TEAM_INFECTED) DisplayInfectedHUD(i, iRotation);
		}
	}
	if (iRotation != 1) iRotation = 1;
	else iRotation = 0;

	return Plugin_Continue;
}*/

public Action Timer_CheckDifficulty(Handle timer) {
	if (b_IsRoundIsOver) return Plugin_Stop;
	CheckDifficulty();
	return Plugin_Continue;
}
public Action Timer_TickingMine(Handle timer, any entity) {
	int size = GetArraySize(playerCustomEntitiesCreated);
	bool entityIsFoundInArray = false;
	for (int i = 0; i < size; i++) {
		if (GetArrayCell(playerCustomEntitiesCreated, i, 2) != entity) continue;
		if (!b_IsActiveRound || !IsValidEntity(entity)) {
			RemoveFromArray(playerCustomEntitiesCreated, i);
			return Plugin_Stop;
		}
		entityIsFoundInArray = true;
		float currentEngineTime = GetEngineTime();
		float timeUntilMineExplodes = GetArrayCell(playerCustomEntitiesCreated, i, 4);
		float AoESize = GetArrayCell(playerCustomEntitiesCreated, i, 3);
		int visualInterval = GetArrayCell(playerCustomEntitiesCreated, i, 5);
		SetArrayCell(playerCustomEntitiesCreated, i, visualInterval + 1, 5);
		if (visualInterval % 3 == 0) CreateRing(entity, AoESize, "red", "32.0", _, 0.5, _, true);
		
		float entityPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
		float commonPos[3];
		int ci = -1;
		int storedCommons = 0;
		if (timeUntilMineExplodes <= currentEngineTime) {
			// explode the mine
			int activator = GetArrayCell(playerCustomEntitiesCreated, i);
			int damage = GetArrayCell(playerCustomEntitiesCreated, i, 1);

			CreateExplosion(entity);
			// commons
			for (int survivor = 1; survivor <= MaxClients; survivor++) {
				if (!IsLegitimateClient(survivor)) continue;
				storedCommons = GetArraySize(CommonInfected[survivor]);
				for (int common = 0; common < storedCommons; common++) {
					ci = GetArrayCell(CommonInfected[survivor], common);
					if (!IsCommonInfected(ci)) continue;
					GetEntPropVector(ci, Prop_Send, "m_vecOrigin", commonPos);
					if (GetVectorDistance(entityPos, commonPos) > AoESize/2.0) continue;
					AddCommonInfectedDamage(activator, ci, damage);
				}
			}
			// specials
			for (int si = 0; si <= MaxClients; si++) {
				if (!IsLegitimateClientAlive(si) || GetClientTeam(si) != TEAM_INFECTED) continue;
				GetEntPropVector(si, Prop_Send, "m_vecOrigin", commonPos);
				if (GetVectorDistance(entityPos, commonPos) > AoESize/2.0) continue;
				AddSpecialInfectedDamage(activator, si, damage);
			}
			RemoveFromArray(playerCustomEntitiesCreated, i);
			return Plugin_Stop;
		}
		else if (timeUntilMineExplodes - currentEngineTime > 3.0) {
			for (int survivor = 1; survivor <= MaxClients; survivor++) {
				if (!IsLegitimateClient(survivor)) continue;
				storedCommons = GetArraySize(CommonInfected[survivor]);
				for (int common = 0; common < storedCommons; common++) {
					ci = GetArrayCell(CommonInfected[survivor], common);
					if (!IsCommonInfected(ci)) continue;
					GetEntPropVector(ci, Prop_Send, "m_vecOrigin", commonPos);
					if (GetVectorDistance(entityPos, commonPos) > AoESize/2.0) continue;
					SetArrayCell(playerCustomEntitiesCreated, i, GetEngineTime() + 3.0, 4);
					survivor = MaxClients+1;
					break;
				}
			}
		}
		break;
	}
	if (entityIsFoundInArray) return Plugin_Continue;
	return Plugin_Stop;
}

public Action Timer_ShowHUD(Handle timer, any client) {
	if (!b_IsActiveRound || !IsLegitimateClient(client)) return Plugin_Stop;
	if (!IsPlayerAlive(client)) return Plugin_Continue;

	int playerTeam = -1;
	int mymaxhealth = -1;
	float healregenamount = 0.0;
	char pct[10];
	Format(pct, 10, "%");
	int ThisRoundTime = -1;
	ThisRoundTime = RPGRoundTime();
	playerTeam = GetClientTeam(client);

	if (PlayerLevel[client] > iMaxLevel) SetTotalExperienceByLevel(client, iMaxLevel, true);
	TimePlayed[client]++;
	//if (TotalHumanSurvivors() < 1) RoundTime++;	// we don't count time towards enrage if there are no human survivors.
	//decl String:targetSteamID[64];
	if (iShowAdvertToNonSteamgroupMembers == 1 && !IsGroupMember[client]) {
		IsGroupMemberTime[client]++;
		if (IsGroupMemberTime[client] % iJoinGroupAdvertisement == 0) {
			PrintToChat(client, "%T", "join group advertisement", client, GroupMemberBonus * 100.0, pct, orange, blue, orange, blue, orange, blue, green, orange);
		}
	}
	displayBuffOrDebuff[client] = (displayBuffOrDebuff[client] == 0) ? 1 : 0;
	if (!IsFakeClient(client)) DisplayHUD(client, displayBuffOrDebuff[client]);
	if (ReadyUpGameMode != 3 && bIsGiveProfileItems[client]) {
		bIsGiveProfileItems[client] = false;
		GiveProfileItems(client);
	}
	if (playerTeam == TEAM_SURVIVOR && CurrentRPGMode >= 1) {
		healregenamount = 0.0;
		mymaxhealth = GetMaximumHealth(client);
		if (ThisRoundTime < iEnrageTime && L4D2_GetInfectedAttacker(client) == -1) {
			healregenamount = GetAbilityStrengthByTrigger(client, _, "p", _, 0, _, _, "h", _, _, 0);	// activator, target, trigger ability, effects, zombieclass, damage
			if (healregenamount > 0.0) {
				float clericHealPercentage = GetTalentStrengthByKeyValue(client, ACTIVATOR_ABILITY_EFFECTS, "cleric", false);
				float clericRange = GetStrengthByKeyValueFloat(client, ACTIVATOR_ABILITY_EFFECTS, "cleric", COHERENCY_RANGE);
				if (clericHealPercentage > 0.0) {
					if (clericRange <= 0.0) clericRange = 512.0;
					healregenamount *= clericHealPercentage;
					if (healregenamount < 1.0) healregenamount = 1.1;
					new playersInRange = 0;
					new Float:clientPos[3];
					GetClientAbsOrigin(client, clientPos);
					for (new teammate = 1; teammate <= MaxClients; teammate++) {
						if (teammate == client) continue;
						if (!IsLegitimateClientAlive(teammate) || GetClientTeam(teammate) != TEAM_SURVIVOR) continue;
						float teammatePos[3];
						GetClientAbsOrigin(teammate, teammatePos);
						if (GetVectorDistance(clientPos, teammatePos) > clericRange || GetClientHealth(teammate) >= GetMaximumHealth(teammate)) continue;
						playersInRange++;
						HealPlayer(teammate, client, healregenamount, 'h', true);
					}
					if (playersInRange > 0) CreateRing(client, clericRange, "green", "32.0", false, 1.0);
				}
			}
		}
		//ModifyHealth(client, GetAbilityStrengthByTrigger(client, client, "p", _, 0, _, _, "H"), 0.0);
		ModifyHealth(client);
		if (GetClientHealth(client) > mymaxhealth) SetEntityHealth(client, mymaxhealth);
	}
	GetAbilityStrengthByTrigger(client, client, "p", _, _, _, _, _, _, _, 0); // percentage passives
	RemoveStoreTime(client);
	LastPlayLength[client]++;
	if (ReadyUpGameMode != 3 && CurrentRPGMode >= 1 && ThisRoundTime >= iEnrageTime) {
		if (SurvivorEnrage[client][1] == 0.0) {
			EnrageBlind(client, 100);
			SurvivorEnrage[client][1] = 1.0;
		}
		else {
			SurvivorEnrage[client][1] = 0.0;
		}
	}
	return Plugin_Continue;
}



// public Action Timer_ShowHUD(Handle timer) {
// 	if (!b_IsActiveRound) {
// 		return Plugin_Stop;
// 	}
// 	static playerTeam = -1;
// 	static mymaxhealth = -1;
// 	static float healregenamount = 0.0;
// 	static char pct[10];
// 	Format(pct, sizeof(pct), "%");
// 	int ThisRoundTime = RPGRoundTime();
// 	for (int client = 1; client <= MaxClients; client++) {
// 		if (!IsLegitimateClient(client) || !IsPlayerAlive(client) || !b_IsLoaded[client]) continue;
// 		playerTeam = GetClientTeam(client);
// 		if (playerTeam == TEAM_SPECTATOR) continue;
// 		if (PlayerLevel[client] > iMaxLevel) SetTotalExperienceByLevel(client, iMaxLevel, true);
// 		TimePlayed[client]++;
// 		//if (TotalHumanSurvivors() < 1) RoundTime++;	// we don't count time towards enrage if there are no human survivors.
// 		//decl String:targetSteamID[64];
// 		if (iShowAdvertToNonSteamgroupMembers == 1 && !IsGroupMember[client]) {
// 			IsGroupMemberTime[client]++;
// 			if (IsGroupMemberTime[client] % iJoinGroupAdvertisement == 0) {
// 				PrintToChat(client, "%T", "join group advertisement", client, GroupMemberBonus * 100.0, pct, orange, blue, orange, blue, orange, blue, green, orange);
// 			}
// 		}
// 		displayBuffOrDebuff[client] = (displayBuffOrDebuff[client] == 0) ? 1 : 0;
// 		if (!IsFakeClient(client)) DisplayHUD(client, displayBuffOrDebuff[client]);
// 		if (bIsGiveProfileItems[client]) {
// 			bIsGiveProfileItems[client] = false;
// 			GiveProfileItems(client);
// 		}
// 		if ((playerTeam == TEAM_SURVIVOR) && CurrentRPGMode >= 1) {
// 			healregenamount = 0.0;				
// 			mymaxhealth = GetMaximumHealth(client);
// 			if (ThisRoundTime < iEnrageTime && L4D2_GetInfectedAttacker(client) == -1) {
// 				healregenamount = GetAbilityStrengthByTrigger(client, _, "p", _, 0, _, _, "h", _, true, 0, _, _, _, _, true);	// activator, target, trigger ability, effects, zombieclass, damage
// 				if (healregenamount > 0.0) {
// 					HealPlayer(client, client, healregenamount, 'h', true);
// 					float clericHealPercentage = GetTalentStrengthByKeyValue(client, ACTIVATOR_ABILITY_EFFECTS, "cleric");
// 					if (clericHealPercentage > 0.0) {
// 						healregenamount *= clericHealPercentage;
// 						int playersInRange = 0;
// 						float clientPos[3];
// 						GetClientAbsOrigin(client, clientPos);
// 						for (int teammate = 1; teammate <= MaxClients; teammate++) {
// 							if (teammate == client) continue;
// 							if (!IsLegitimateClientAlive(teammate) || GetClientTeam(teammate) != TEAM_SURVIVOR) continue;
// 							float teammatePos[3];
// 							GetClientAbsOrigin(teammate, teammatePos);
// 							if (GetVectorDistance(clientPos, teammatePos) > 384.0 || GetClientHealth(teammate) >= GetMaximumHealth(teammate)) continue;
// 							playersInRange++;
// 							HealPlayer(teammate, client, healregenamount, 'h', true);
// 						}
// 						if (playersInRange > 0) CreateRing(client, 384.0, "green", "32.0", _, 0.5, _, true);
// 					}
// 				}
// 			}
// 			SetMaximumHealth(client);
// 			//ModifyHealth(client, GetAbilityStrengthByTrigger(client, client, "p", _, 0, _, _, "H"), 0.0);
// 			if (GetClientHealth(client) > mymaxhealth) SetEntityHealth(client, mymaxhealth);
// 		}
// 		if (playerTeam != TEAM_SPECTATOR) {
// 			//GetAbilityStrengthByTrigger(client, client, "p");	// raw passives
// 			GetAbilityStrengthByTrigger(client, client, "p", _, _, _, _, _, _, _, 0); // percentage passives
// 		}
// 		RemoveStoreTime(client);
// 		LastPlayLength[client]++;
// 		if (ReadyUpGameMode != 3 && CurrentRPGMode >= 1 && ThisRoundTime >= iEnrageTime) {
// 			if (SurvivorEnrage[client][1] == 0.0) {
// 				EnrageBlind(client, 100);
// 				SurvivorEnrage[client][1] = 1.0;
// 			}
// 			else {
// 				SurvivorEnrage[client][1] = 0.0;
// 			}
// 		}
// 	}
// 	return Plugin_Continue;
// }

stock LedgedSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsLedged(i)) count++;
	}
	return count;
}

stock bool NoLivingHumanSurvivors() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || !IsPlayerAlive(i)) continue;
		return false;
	}
	return true;
}

stock bool NoHealthySurvivors(bool bMustNotBeABot = false) {

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || IsIncapacitated(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (bMustNotBeABot && IsFakeClient(i)) continue;
		return false;
	}
	return true;
}

stock HumanSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}
	return count;
}

public Action Timer_TeleportRespawn(Handle timer, any client) {

	if (b_IsActiveRound && IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) {
		//ChangeHook(client, true);

		int target = MyRespawnTarget[client];

		if (target != client && IsLegitimateClientAlive(target)) {

			GetClientAbsOrigin(target, DeathLocation[target]);
			TeleportEntity(client, DeathLocation[target], NULL_VECTOR, NULL_VECTOR);
			MyRespawnTarget[client] = client;
		}
		else TeleportEntity(client, DeathLocation[client], NULL_VECTOR, NULL_VECTOR);
		b_HasDeathLocation[client] = false;
	}
	return Plugin_Stop;
}

public Action Timer_GiveMaximumHealth(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		GiveMaximumHealth(client);		// So instant heal doesn't put a player above their maximum health pool.
	}

	return Plugin_Stop;
}

public Action Timer_DestroyCombustion(Handle timer, any entity)
{
	if (!IsValidEntity(entity)) return Plugin_Stop;
	AcceptEntityInput(entity, "Kill");
	return Plugin_Stop;
}

/*public Action:Timer_DestroyDiscoveryItem(Handle:timer, any:entity) {

	if (IsValidEntity(entity)) {

		new client				= FindAnyRandomClient();

		if (client == -1) return Plugin_Stop;

		decl String:EName[64];
		GetEntPropString(entity, Prop_Data, "m_iName", EName, sizeof(EName));
		if (StrEqual(EName, "slate") || IsStoreItem(client, EName) || IsTalentExists(EName)) {

			if (!AcceptEntityInput(entity, "Kill")) RemoveEdict(entity);
		}
	}

	return Plugin_Stop;
}*/

public Action Timer_SlowPlayer(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplierBase[client]);
	}
	//SlowMultiplierTimer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

stock GetTimePlayed(client, char[] s, size) {
	int seconds = TimePlayed[client];
	int minutes = 0;
	int hours = 0;
	int days = 0;
	while (seconds >= 86400) {
		days++;
		seconds -= 86400;
	}
	while (seconds >= 3600) {
		hours++;
		seconds -= 3600;
	}
	while (seconds >= 60) {
		minutes++;
		seconds -= 60;
	}
	Format(s, size, "Playtime:");
	if (days > 1) Format(s, size, "%s %d Days,", s, days);
	else if (days > 0) Format(s, size, "%s %d Day,", s, days);
	if (hours > 1) Format(s, size, "%s %d Hours,", s, hours);
	else if (hours > 0) Format(s, size, "%s %d Hour,", s, hours);
	if (minutes > 1) Format(s, size, "%s %d Minutes,", s, minutes);
	else if (minutes > 0) Format(s, size, "%s %d Minute,", s, minutes);
	if (seconds > 1) Format(s, size, "%s %d Seconds", s, seconds);
	else if (seconds > 0) Format(s, size, "%s %d Second", s, seconds);
}

/*public Action:Timer_AwardSkyPoints(Handle:timer) {

	if (!b_IsActiveRound) return Plugin_Stop;

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) {

			CheckSkyPointsAward(i);
		}
	}

	return Plugin_Continue;
}

stock CheckSkyPointsAward(client) {

	new SkyPointsAwardTime		=	GetConfigValueInt("sky points awarded _");
	new SkyPointsAwardValue		=	GetConfigValueInt("sky points time required?");
	new SkyPointsAwardAmount	=	GetConfigValueInt("sky points award amount?");

	new seconds					=	0;
	new minutes					=	0;
	new hours					=	0;
	new days					=	0;
	new oldminutes				=	0;
	new oldhours				=	0;
	new olddays					=	0;

	seconds				=	TimePlayed[client];
	while (seconds >= 86400) {

		olddays++;
		seconds -= 86400;
	}
	while (seconds >= 3600) {

		oldhours++;
		seconds -= 3600;
	}
	while (seconds >= 60) {

		oldminutes++;
		seconds -= 60;
	}

	TimePlayed[client]++;

	seconds = TimePlayed[client];

	while (seconds >= 86400) {

		days++;
		seconds -= 86400;
	}
	while (seconds >= 3600) {

		hours++;
		seconds -= 3600;
	}
	while (seconds >= 60) {

		minutes++;
		seconds -= 60;

	}
	if (SkyPointsAwardTime == 2 && days != olddays && days % SkyPointsAwardValue == 0) AwardSkyPoints(client, SkyPointsAwardAmount);
	if (SkyPointsAwardTime == 1 && hours != oldhours && hours % SkyPointsAwardValue == 0) AwardSkyPoints(client, SkyPointsAwardAmount);
	if (SkyPointsAwardTime == 0 && minutes != oldminutes && minutes % SkyPointsAwardValue == 0) AwardSkyPoints(client, SkyPointsAwardAmount);
}*/

/*public Action:Timer_SpeedIncrease(Handle:timer, any:client) {

	if (IsLegitimateClientAlive(client)) {

		SpeedIncrease(client);
	}
	//SpeedMultiplierTimer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}*/

public Action Timer_BlindPlayer(Handle timer, any client) {

	if (IsLegitimateClient(client)) BlindPlayer(client);
	return Plugin_Stop;
}

public Action Timer_FrozenPlayer(Handle timer, any client) {

	if (IsLegitimateClient(client)) FrozenPlayer(client, _, 0);
	return Plugin_Stop;
}

stock float GetActiveZoomTime(client) {
	int listClient = 0;
	float activeZoomTimeTime = 0.0;
	float activeZoomTime = GetEngineTime();
	for (int i = 0; i < GetArraySize(zoomCheckList); i++) {
		listClient = GetArrayCell(zoomCheckList, i, 0);
		if (client != listClient) continue;
		activeZoomTimeTime = GetArrayCell(zoomCheckList, i, 1);
		activeZoomTime -= activeZoomTimeTime;
		return activeZoomTime;
	}
	return 0.0;
}

stock bool isQuickscopeKill(client) {
	int listClient = 0;
	float fClientHoldingFireTime = 0.0;
	float killDelayAfterScope = GetEngineTime();
	for (int i = 0; i < GetArraySize(zoomCheckList); i++) {
		listClient = GetArrayCell(zoomCheckList, i, 0);
		if (client != listClient) continue;
		fClientHoldingFireTime = GetArrayCell(zoomCheckList, i, 1);
		killDelayAfterScope -= fClientHoldingFireTime;
		if (killDelayAfterScope <= fquickScopeTime) return true;
		return false;
	}
	return false;
}

stock zoomCheckToggle(client, bool insert = false) {
	int listClient = 0;
	for (int i = 0; i < GetArraySize(zoomCheckList); i++) {
		listClient = GetArrayCell(zoomCheckList, i, 0);
		if (client != listClient) continue;
		if (insert) return;
		// The user is unscoping so we remove them from the array.
		RemoveFromArray(zoomCheckList, i);
	}
	if (insert) {
		// we don't even get here if the user is already in the list.
		int size = GetArraySize(zoomCheckList);
		ResizeArray(zoomCheckList, size + 1);
		SetArrayCell(zoomCheckList, size, client, 0);
		SetArrayCell(zoomCheckList, size, GetEngineTime(), 1);
	}
	return;
}

public Action Timer_ZoomcheckDelayer(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (IsPlayerZoomed(client)) {
		// trigger nodes that fire when a player zooms in (like effects over time)
		zoomCheckToggle(client, true);
	}
	else zoomCheckToggle(client);
	ZoomcheckDelayer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

stock float GetHoldingFireTime(client) {
	int listClient = 0;
	float fClientHoldingFireTime = 0.0;
	float holdingFireTime = GetEngineTime();
	for (int i = 0; i < GetArraySize(holdingFireList); i++) {
		listClient = GetArrayCell(holdingFireList, i, 0);
		if (listClient != client) continue;
		fClientHoldingFireTime = GetArrayCell(holdingFireList, i, 1);
		holdingFireTime -= fClientHoldingFireTime;
		return holdingFireTime;
	}
	return 0.0;
}

stock holdingFireCheckToggle(client, bool insert = false) {
	int listClient = 0;
	for (int i = 0; i < GetArraySize(holdingFireList); i++) {
		listClient = GetArrayCell(holdingFireList, i, 0);
		if (listClient != client) continue;
		if (insert) return;
		// The user is unscoping so we remove them from the array.
		RemoveFromArray(holdingFireList, i);
	}
	if (insert) {
		// we don't even get here if the user is already in the list.
		int size = GetArraySize(holdingFireList);
		ResizeArray(holdingFireList, size + 1);
		SetArrayCell(holdingFireList, size, client, 0);
		SetArrayCell(holdingFireList, size, GetEngineTime(), 1);
	}
	return;
}

/*public Action:Timer_HoldingFireDelayer(Handle:timer, any:client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	new weaponEntity = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	new bulletsRemaining = 0;
	if (IsValidEntity(weaponEntity)) bulletsRemaining = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
	if (bulletsRemaining > 0 && GetEntProp(weaponEntity, Prop_Data, "m_bInReload") != 1 && L4D2_GetInfectedAttacker(client) == -1) {
		// trigger nodes that fire when a player zooms in (like effects over time)
		holdingFireCheckToggle(client, true);
	}
	else holdingFireCheckToggle(client);
	holdingFireDelayer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}*/

public Action Timer_Blinder(Handle timer, any client) {

	if (ISBLIND[client] == INVALID_HANDLE) return Plugin_Stop;

	if (!b_IsActiveRound || !IsLegitimateClient(client) || !IsSpecialCommonInRange(client, 'l')) {

		BlindPlayer(client);
		KillTimer(ISBLIND[client]);
		ISBLIND[client] = INVALID_HANDLE;
		//CloseHandle(ISBLIND[client]);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_Freezer(Handle timer, any client) {
	if (!b_IsActiveRound || !IsLegitimateClient(client) || !IsPlayerAlive(client) || !IsSpecialCommonInRange(client, 'r')) {
		/*

			If the client is scorched, they no longer freeze.
		*/
		//KillTimer(ISFROZEN[client]);
		ISFROZEN[client] = INVALID_HANDLE;
		FrozenPlayer(client, _, 0);
		return Plugin_Stop;
	}
	float Velocity[3];
	SetEntityMoveType(client, MOVETYPE_WALK);
	Velocity[0]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	Velocity[1]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	Velocity[2]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	Velocity[2] += 32.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
	SetEntityMoveType(client, MOVETYPE_NONE);
	return Plugin_Continue;
}

// public ReadyUp_FwdChangeTeam(client, team) {

// 	if (IsLegitimateClient(client)) {

// 		if (team == TEAM_SURVIVOR) {

// 			ChangeHook(client, true);
// 			if (!b_IsLoading[client] && !b_IsLoaded[client]) OnClientLoaded(client);
// 		}
// 		else if (team != TEAM_SURVIVOR) {

// 			//LogToFile(LogPathDirectory, "%N is no longer a survivor, unhooking.", client);
// 			// if (bIsInCombat[client]) {

// 			// 	IncapacitateOrKill(client, _, _, true, false, true);
// 			// }
// 			ChangeHook(client);
// 		}
// 	}
// }

public ReadyUp_FwdChangeTeam(client, team) {
	if (bIsInCombat[client]) IncapacitateOrKill(client, _, _, true, true, true);
	CreateTimer(0.2, Timer_ChangeTeamCheck, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ChangeTeamCheck(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (GetClientTeam(client) == TEAM_SURVIVOR) {
		//ChangeHook(client, true);
		if (!b_IsLoading[client] && !b_IsLoaded[client]) OnClientLoaded(client);
	}
	//else ChangeHook(client);
	return Plugin_Stop;
}

stock void ChangeHook(client, bool bHook = false) {

	b_IsHooked[client] = bHook;
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_TraceAttack, OnTraceAttack);
	SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
	if (b_IsHooked[client]) {
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
		SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
	}
}

/*public ReadyUp_FwdChangeTeam(client, team) {

	if (team != TEAM_SURVIVOR) {

		if (bIsInCombat[client]) {

			IncapacitateOrKill(client, _, _, true, false, true);
		}

		b_IsHooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	else if (team == TEAM_SURVIVOR && !b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}*/

public Action Timer_DetectGroundTouch(Handle timer, any client) {

	if (IsClientHuman(client) && IsPlayerAlive(client)) {

		if (GetClientTeam(client) == TEAM_SURVIVOR && !(GetEntityFlags(client) & FL_ONGROUND) && b_IsJumping[client] && L4D2_GetInfectedAttacker(client) == -1 && !AnyTanksNearby(client)) return Plugin_Continue;
		b_IsJumping[client] = false;
		ModifyGravity(client);
	}
	return Plugin_Stop;
}

public Action Timer_ResetGravity(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) ModifyGravity(client);
	return Plugin_Stop;
}

public Action Timer_CloakingDeviceBreakdown(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	return Plugin_Stop;
}

/*public Action:Timer_RemoveImmune(Handle:timer, Handle:packy) {

	ResetPack(packy);
	new client			=	ReadPackCell(packy);
	new pos				=	ReadPackCell(packy);
	new owner			=	ReadPackCell(packy);

	if (client != -1 && IsClientActual(client) && !IsFakeClient(client)) {

		SetArrayString(PlayerAbilitiesImmune[client], pos, "0");
	}
	else {

		SetArrayString(PlayerAbilitiesImmune_Bots, pos, "0");
	}
	if (IsLegitimateClient(owner)) SetArrayString(PlayerAbilitiesImmune[owner][client], pos, "0");

	return Plugin_Stop;
}*/


stock ResetCDImmunity(client) {

	int size = 0;
	/*for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i)) continue;

		size = GetArraySize(PlayerAbilitiesImmune[client][i]);
		for (new y = 0; y < size; y++) {

			SetArrayString(PlayerAbilitiesImmune[client][i], y, "0");
		}
	}*/

	/*for (new i = 1; i <= MAXPLAYERS; i++) {

		//if (!IsLegitimateClient(i)) continue;
		for (new y = 1; y <= MAXPLAYERS; y++) {

			//if (!IsLegitimateClient(y)) continue;
			size = GetArraySize(PlayerAbilitiesImmune[i][y]);
			for (new z = 0; z < size; z++) {

				SetArrayString(PlayerAbilitiesImmune[i][y], z, "0");
			}
		}
	}*/

	if (IsLegitimateClient(client)) {

		size = GetArraySize(PlayerAbilitiesCooldown[client]);
		for (int i = 0; i < size; i++) {

			SetArrayString(PlayerAbilitiesCooldown[client], i, "0");
		}
		/*size = GetArraySize(PlayerAbilitiesImmune[client]);
		for (new i = 0; i < size; i++) {

			SetArrayString(PlayerAbilitiesImmune[client], i, "0");
		}*/
	}
	else if (client == -1) {

		size = GetArraySize(PlayerAbilitiesCooldown_Bots);
		for (int i = 0; i < size; i++) {

			SetArrayString(PlayerAbilitiesCooldown_Bots, i, "0");
		}
		size = GetArraySize(PlayerAbilitiesImmune_Bots);
		for (int i = 0; i < size; i++) {

			SetArrayString(PlayerAbilitiesImmune_Bots, i, "0");
		}
	}
}

public Action Timer_Slow(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (!b_IsActiveRound || !IsPlayerAlive(client) || !ISSLOW[client]) {
		SetSpeedMultiplierBase(client);
		fSlowSpeed[client] = 1.0;
		//KillTimer(ISSLOW[client]);
		ISSLOW[client] = false;
		return Plugin_Stop;
	}
	//SetEntityMoveType(client, MOVETYPE_WALK);
	SetSpeedMultiplierBase(client);
	fSlowSpeed[client] = 1.0;
	//KillTimer(ISSLOW[client]);
	ISSLOW[client] = false;
	return Plugin_Stop;
}

public Action Timer_Explode(Handle timer, Handle packagey) {

	ResetPack(packagey);

	int client 		= ReadPackCell(packagey);
	if (!IsLegitimateClientAlive(client)) {

		ISEXPLODETIME[client] = 0.0;
		KillTimer(ISEXPLODE[client]);
		ISEXPLODE[client] = INVALID_HANDLE;
		//CloseHandle(ISBLIND[client]);
		//CloseHandle(packagey);
		return Plugin_Stop;
	}
	CombatTime[client] = GetEngineTime() + fOutOfCombatTime;
	bIsInCombat[client] = true;

	float ClientPosition[3];
	GetClientAbsOrigin(client, ClientPosition);

	float flStrengthAura = ReadPackCell(packagey) * 1.0;
	float flStrengthTarget = ReadPackFloat(packagey);
	float flStrengthLevel = ReadPackFloat(packagey);
	float flRangeMax = ReadPackFloat(packagey);
	float flDeathMultiplier = ReadPackFloat(packagey);
	float flDeathBaseTime = ReadPackFloat(packagey);
	float flDeathInterval = ReadPackFloat(packagey);
	float flDeathMaxTime = ReadPackFloat(packagey);
	char StAuraColour[64];
	char StAuraPos[64];
	ReadPackString(packagey, StAuraColour, sizeof(StAuraColour));
	ReadPackString(packagey, StAuraPos, sizeof(StAuraPos));
	int iLevelRequired = ReadPackCell(packagey);

	int NumLivingEntities = LivingEntitiesInRange(client, ClientPosition, flRangeMax);
	bool bIsLegitimateClient = IsLegitimateClient(client);

	if (!b_IsActiveRound || !bIsLegitimateClient || bIsLegitimateClient && !IsPlayerAlive(client) || ISEXPLODETIME[client] >= flDeathBaseTime && NumLivingEntities < 1 || ISEXPLODETIME[client] >= flDeathMaxTime) {

		ISEXPLODETIME[client] = 0.0;
		KillTimer(ISEXPLODE[client]);
		ISEXPLODE[client] = INVALID_HANDLE;
		//CloseHandle(ISBLIND[client]);
		//CloseHandle(packagey);
		return Plugin_Stop;
	}
	float flStrengthTotal = flStrengthAura + ((flStrengthTarget * NumLivingEntities) + (flStrengthLevel * PlayerLevel[client]));

	float TargetPosition[3];
	flStrengthTotal *= flDeathMultiplier;

	if (FindZombieClass(client) == ZOMBIECLASS_TANK && IsCoveredInBile(client)) {

		ISEXPLODETIME[client] += flDeathInterval;
		return Plugin_Continue;
	}
	CreateRing(client, flRangeMax, StAuraColour, StAuraPos);
	CreateExplosion(client);
	int ReflectDebuff = 0;
	flStrengthTotal += flStrengthTotal * IsClientInRangeSpecialAmmo(client, "d", _, _, RoundToCeil(flStrengthTotal));
	flStrengthTotal += flStrengthTotal * IsClientInRangeSpecialAmmo(client, "E", _, _, RoundToCeil(flStrengthTotal));
	flStrengthTotal = flStrengthTotal * (1.0 - IsClientInRangeSpecialAmmo(client, "D", _, _, RoundToCeil(flStrengthTotal)));

	int DamageValue = RoundToCeil(flStrengthTotal);
	if (!IsFakeClient(client)) {
		ScreenShake(client);
		SetClientTotalHealth(_, client, DamageValue);
	}
	bool isTargetClientABot;
	float ammoStr = 0.0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || i == client) continue;
		if (GetClientTeam(i) == TEAM_SURVIVOR && PlayerLevel[i] < iLevelRequired) continue;	// we add infected later.

		GetClientAbsOrigin(i, TargetPosition);
		if (GetVectorDistance(ClientPosition, TargetPosition) > (flRangeMax / 2)) continue;
		CombatTime[i] = GetEngineTime() + fOutOfCombatTime;
		bIsInCombat[i] = true;

		CreateExplosion(i);	// boom boom audio and effect on the location.
		isTargetClientABot = IsFakeClient(i);
		if (!isTargetClientABot) ScreenShake(i);

		//if (DamageValue > GetClientHealth(i)) IncapacitateOrKill(i);
		//else SetEntityHealth(i, GetClientHealth(i) - DamageValue);
		if (GetClientTeam(i) == TEAM_SURVIVOR && !isTargetClientABot) {
			ammoStr = IsClientInRangeSpecialAmmo(i, "D", _, _, DamageValue);
			if (ammoStr > 0.0) SetClientTotalHealth(client, i, RoundToCeil(DamageValue * (1.0 - ammoStr)));
			else SetClientTotalHealth(client, i, DamageValue);
			ammoStr = IsClientInRangeSpecialAmmo(i, "R", _, _, DamageValue);
			if (ammoStr > 0.0) {

				ReflectDebuff = RoundToCeil(DamageValue * ammoStr);
				SetClientTotalHealth(i, client, ReflectDebuff);
				CreateAndAttachFlame(i, ReflectDebuff, 3.0, 0.5, i, "reflect");
			}
		}
		else if (GetClientTeam(i) == TEAM_INFECTED) {

			if (IsSpecialCommonInRange(i, 'd')) {
				ammoStr = IsClientInRangeSpecialAmmo(client, "D", _, _, DamageValue);
				if (ammoStr > 0.0) {

					ReflectDebuff = RoundToCeil(DamageValue * (1.0 - ammoStr));
					CreateAndAttachFlame(client, ReflectDebuff, 3.0, 0.5, i, "reflect");
				}
				else CreateAndAttachFlame(client, DamageValue, 3.0, 0.5, i, "reflect");
			}
			else AddSpecialInfectedDamage(client, i, DamageValue);
		}
	}
	float cpos[3];
	flRangeMax /= 2;
	for (int i = 0; i < GetArraySize(CommonInfected[client]); i++) {
		int common = GetArrayCell(CommonInfected[client], i);
		if (!IsCommonInfected(common) || IsSpecialCommon(common)) continue;
		GetEntPropVector(common, Prop_Send, "m_vecOrigin", cpos);
		if (GetVectorDistance(ClientPosition, cpos) > flRangeMax) continue;
		AddCommonInfectedDamage(client, common, DamageValue);
	}
	ISEXPLODETIME[client] += flDeathInterval;

	return Plugin_Continue;
}

public Action Timer_IsNotImmune(Handle timer, any client) {

	if (IsLegitimateClient(client)) b_IsImmune[client] = false;
	return Plugin_Stop;
}

bool ScenarioEndConditionsMet() {
	int numberOfLivingHumanSurvivors 	= LivingHumanSurvivors();
	int numberOfLivingSurvivors	  		= LivingSurvivors();
	//int numberOfHumanSurvivors		  	= TotalHumanSurvivors();
	// if there are no survivors at all, we let the game run, but don't advance the enrage timer.
	if (TotalSurvivors() < 1) {
		RoundTime = 0;
		return false;
	}
	// If we end the round when there's no human survivors alive, this will also end rounds if no human survivors exist.
	if (iEndRoundIfNoLivingHumanSurvivors == 1 && numberOfLivingHumanSurvivors < 1) return true;
	// Requires all survivors to be completely dead if iEndRoundIfNoHealthySurvivors = 0
	if (iEndRoundIfNoHealthySurvivors == 0) {
		// either there are no living human survivors and we require it, or all survivors are dead.
		if (numberOfLivingSurvivors < 1) return true;
	}
	// If all living survivors are dead, or they're all hanging from ledges, or they're all incapped/dead/ledged.
	else if (numberOfLivingSurvivors < 1 || numberOfLivingSurvivors == LedgedSurvivors() || NoHealthySurvivors()) return true;
	return false;
}

public Action Timer_CheckIfHooked(Handle timer) {

	if (!b_IsActiveRound) {
		iSurvivalCounter = 0;
		return Plugin_Stop;
	}
	if (showNumLivingSurvivorsInHostname == 1) SetSurvivorsAliveHostname();
	static CurRPG = -2;
	static RoundSeconds = 0;
	RoundSeconds = RPGRoundTime(true);
	if (IsSurvivalMode) {
		iSurvivalCounter++;
		if (iSurvivalCounter >= iSurvivalRoundTime) {

			for (int i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClient(i)) {
					if (GetClientTeam(i) == TEAM_SURVIVOR) {
						IsSpecialAmmoEnabled[i][0] = 0.0;
						if (IsPlayerAlive(i)) AwardExperience(i, _, _, true);
						else Defibrillator(i, _, true);
					}
				}
			}
			iSurvivalCounter = 0;
			bIsSettingsCheck = true;
		}
	}
	if (RoundSeconds % HostNameTime == 0) {
		PrintToChatAll("%t", "playing in server name", orange, blue, Hostname, orange, blue, MenuCommand, orange);
	}
	if (SurvivorsSaferoomWaiting()) SurvivorBotsRegroup();
	if (ScenarioEndConditionsMet()) {
		int c = FindAnyClient();
		if (c > 0) {
			b_IsMissionFailed = true;
			ScenarioEnd(c);
			CallRoundIsOver();
			return Plugin_Stop;
		}
	}
	static char text[64];
	int secondsUntilEnrage = GetSecondsUntilEnrage();
	if (!IsSurvivalMode && iEnrageTime > 0 && RoundSeconds > 0 && RPGRoundTime() < iEnrageTime && (secondsUntilEnrage <= iHideEnrageTimerUntilSecondsLeft && secondsUntilEnrage % 60 == 0 || (RoundSeconds % iEnrageAdvertisement) == 0)) {
		TimeUntilEnrage(text, sizeof(text));
		PrintToChatAll("%t", "enrage in...", orange, green, text, orange);
	}
	if (CurRPG == -2) CurRPG = iRPGMode;
	for (int i = 1; i <= MaxClients; i++) {
		if (CurRPG < 1 || !IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (bHasWeakness[i] > 0) {
			SetEntityRenderMode(i, RENDER_TRANSCOLOR);
			SetEntityRenderColor(i, 0, 0, 0, 255);
			if (bHasWeakness[i] < 3) SetEntProp(i, Prop_Send, "m_bIsOnThirdStrike", 1);
			else SetEntProp(i, Prop_Send, "m_bIsOnThirdStrike", 0);
			if (!IsFakeClient(i) && !bWeaknessAssigned[i]) {
				//EmitSoundToClient(i, "player/heartbeatloop.wav");
				bWeaknessAssigned[i] = true;
			}
		}
		else {
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);
			if (!IsFakeClient(i) && bWeaknessAssigned[i]) {
				StopSound(i, SNDCHAN_AUTO, "player/heartbeatloop.wav");
				bWeaknessAssigned[i] = false;
			}
			SetEntProp(i, Prop_Send, "m_bIsOnThirdStrike", 0);
		}
	}
	return Plugin_Continue;
}

public Action Timer_Doom(Handle timer) {

	if (!b_IsActiveRound || DoomSUrvivorsRequired == 0) {

		DoomTimer = 0;
		return Plugin_Stop;
	}
	int SurvivorCount = LivingSurvivors();
	if (DoomSUrvivorsRequired == -1 && SurvivorCount != TotalSurvivors() ||
		DoomSUrvivorsRequired > 0 && SurvivorCount < DoomSUrvivorsRequired) {

		if (DoomTimer == 0) PrintToChatAll("%t", "you are doomed", orange);
		DoomTimer++;
	}
	else DoomTimer = 0;

	if (DoomTimer >= DoomKillTimer) {

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
				HealingContribution[i] = 0;
				PointsContribution[i] = 0.0;
				TankingContribution[i] = 0;
				DamageContribution[i] = 0;
				BuffingContribution[i] = 0;
				HexingContribution[i] = 0;

				ForcePlayerSuicide(i);
			}
		}
		if (DoomTimer == DoomKillTimer) PrintToChatAll("%t", "survivors are doomed", orange);
		if (LivingHumanSurvivors() < 1) return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_TankCooldown(Handle timer) {

	static float Counter								=	0.0;

	if (!b_IsActiveRound) {

		Counter											=	0.0;
		return Plugin_Stop;
	}
	Counter												+=	1.0;
	f_TankCooldown										-=	1.0;
	if (f_TankCooldown < 1.0) {

		Counter											=	0.0;
		f_TankCooldown									=	-1.0;
		for (int i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && (GetClientTeam(i) == TEAM_INFECTED || ReadyUp_GetGameMode() != 2)) {

				PrintToChat(i, "%T", "Tank Cooldown Complete", i, orange, white);
			}
		}

		return Plugin_Stop;
	}
	if (Counter >= fVersusTankNotice) {

		Counter											=	0.0;
		for (int i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && (GetClientTeam(i) == TEAM_INFECTED || ReadyUp_GetGameMode() != 2)) {

				PrintToChat(i, "%T", "Tank Cooldown Remaining", i, green, f_TankCooldown, white, orange, white);
			}
		}
	}

	return Plugin_Continue;
}

stock GetSuperCommonLimit() {
	return RoundToCeil((AllowedCommons + RaidCommonBoost()) * fSuperCommonLimit);
}

stock GetCommonQueueLimit() {
	return RoundToCeil((AllowedCommons + RaidCommonBoost()) * fCommonQueueLimit);
}

public Action Timer_SettingsCheck(Handle timer) {

	if (!b_IsActiveRound) {

		SetConVarInt(FindConVar("z_common_limit"), 0);	// no commons unless active round.
		return Plugin_Stop;
	}
	if (RPGRoundTime(true) < iCommonInfectedSpawnDelayOnNewRound) {
		SetConVarInt(FindConVar("z_common_limit"), 0);
		return Plugin_Continue;
	}

	int RaidLevelCounter = RaidCommonBoost();
	bool bIsEnrage = false;

	if (!bIsSettingsCheck) return Plugin_Continue;
	bIsSettingsCheck = false;

	bIsEnrage = IsEnrageActive();

	if (bIsEnrage) RaidLevelCounter = RoundToCeil(fEnrageMultiplier * RaidLevelCounter);
	int CommonAllowed = AllowedCommons + RaidLevelCounter;
	if (CommonAllowed <= iCommonsLimitUpper) SetConVarInt(FindConVar("z_common_limit"), CommonAllowed);
	else SetConVarInt(FindConVar("z_common_limit"), iCommonsLimitUpper);
	if (iTankRush != 1) SetConVarInt(FindConVar("z_reserved_wanderers"), RaidLevelCounter);
	else {

		//if (AllowedCommons + RaidLevelCounter)

		SetConVarInt(FindConVar("z_reserved_wanderers"), 0);
		SetConVarInt(FindConVar("director_always_allow_wanderers"), 0);
	}
	SetConVarInt(FindConVar("z_mega_mob_size"), AllowedMegaMob + RaidLevelCounter);
	SetConVarInt(FindConVar("z_mob_spawn_max_size"), AllowedMobSpawn + RaidLevelCounter);
	SetConVarInt(FindConVar("z_mob_spawn_finale_size"), AllowedMobSpawnFinale + RaidLevelCounter);

	return Plugin_Continue;
}

// int TotalHandicapLevel() {
// 	int count = 0;
// 	for (int i = 1; i <= MaxClients; i++) {
// 		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i) || handicapLevel[i] < 1) continue;
// 		count += handicapLevel[i];
// 	}
// 	return count;
// }

bool IsSurvivorsHealthy() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && L4D2_GetInfectedAttacker(i) == -1) return true;
	}
	return false;
}

/*public Action:Timer_IsSpecialCommonInRange(Handle:timer) {
	if (!b_IsActiveRound) return Plugin_Stop;
	static commonInfected = 0;

	for (new i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i)) continue;
		if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
		commonInfected = 0;
		IsSpecialCommonInRange(i, 'x', _, _, commonInfected);			// kamikazi
		if (commonInfected > 0) { // if it's a kamikazi, we force it to die, so it can trigger its effects on players in the vicinity.
			ClearSpecialCommon(commonInfected);
			commonInfected = 0;
		}
		IsSpecialCommonInRange(i, 'X', _, _, commonInfected);			// life drainer
	}
	return Plugin_Continue;
}*/

public Action Timer_RespawnQueue(Handle timer) {

	static Counter										=	-1;
	static TimeRemaining								=	0;
	static RandomClient									=	-1;
	static char text[64];

	if (!b_IsActiveRound || b_IsFinaleActive) {

		Counter = -1;
		return Plugin_Stop;
	}
	if (TotalHumanSurvivors() > iSurvivorRespawnRestrict) {

		/*	When there are a lot of players on the server, we want to maintain the difficulty that is experienced by lower level players.
			To prevent inflation on an exponential level, we just remove systems that aren't needed to compensate for players when there
			are less players in the server.
			Due to higher survivability and other important factors, removing the respawn queue feels like a pretty solid balance choice.
		*/
		return Plugin_Continue;
	}

	static bool bIsHealth = false;
	bIsHealth = IsSurvivorsHealthy();

	if (!IsSurvivalMode && bIsHealth) Counter++;
	else Counter = iSurvivalCounter;
	TimeRemaining = RespawnQueue - Counter;
	if (TimeRemaining <= 0) RandomClient = FindAnyRandomClient(true);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsPlayerAlive(i)) continue;
		if (TimeRemaining > 0) {

			if (!IsFakeClient(i)) {

				if (bIsHealth) Format(text, sizeof(text), "%T", "respawn queue", i, TimeRemaining);
				else Format(text, sizeof(text), "%T", "respawn queue paused", i, TimeRemaining);
				PrintHintText(i, text);
			}
		}
		else if (IsLegitimateClientAlive(RandomClient)) {

			GetClientAbsOrigin(RandomClient, DeathLocation[i]);
			SDKCall(hRoundRespawn, i);
			b_HasDeathLocation[i] = true;
			MyRespawnTarget[i] = -1;
			CreateTimer(3.0, Timer_TeleportRespawn, i, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(3.0, Timer_GiveMaximumHealth, i, TIMER_FLAG_NO_MAPCHANGE);

			RandomClient = FindAnyRandomClient(true);
		}
	}
	if (Counter >= RespawnQueue) Counter = 0;
	return Plugin_Continue;
}

public Action Timer_AcidCooldown(Handle timer, any client) {
	if (IsLegitimateClient(client)) DebuffOnCooldown(client, "acid", true);
	return Plugin_Stop;
}

bool DebuffOnCooldown(client, char[] debuffToSearchFor, bool removeDebuffCooldown = false) {
	char result[64];
	int size = GetArraySize(ApplyDebuffCooldowns[client]);
	for (int pos = 0; pos < size; pos++) {
		GetArrayString(ApplyDebuffCooldowns[client], pos, result, sizeof(result));
		if (!StrEqual(debuffToSearchFor, result)) continue;
		if (!removeDebuffCooldown) return true;
		RemoveFromArray(ApplyDebuffCooldowns[client], pos);
		break;
	}
	return false;
}

stock bool IsClientSorted(client) {

	int size = GetArraySize(hThreatSort);
	//new target = -1;
	for (int i = 0; i < size; i++) {

		if (client == GetArrayCell(hThreatSort, i)) return true;
	}
	return false;
}

public Action Timer_PlayTime(Handle timer) {
	if (!b_IsActiveRound) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
		TimePlayed[i]++;
	}
	return Plugin_Continue;
}

stock SortThreatMeter() {

	ClearArray(hThreatSort);
	ClearArray(hThreatMeter);
	int cTopThreat = -1;
	int cTopClient = -1;
	int cTotalClients = 0;
	int size = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		cTotalClients++;
	}
	while (GetArraySize(hThreatSort) < cTotalClients) {

		cTopThreat = 0;
		for (int i = 1; i <= MaxClients; i++) {

			if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsClientSorted(i)) continue;
			if (iThreatLevel[i] > cTopThreat) {

				cTopThreat = iThreatLevel[i];
				cTopClient = i;
			}
		}
		if (cTopThreat > 0) {
			//Format(text, sizeof(text), "%d+%d", cTopClient, cTopThreat);
			//PushArrayString(Handle:hThreatMeter, text);
			size = GetArraySize(hThreatMeter);
			ResizeArray(hThreatMeter, size + 1);
			SetArrayCell(hThreatMeter, size, cTopClient, 0);
			SetArrayCell(hThreatMeter, size, cTopThreat, 1);
			PushArrayCell(hThreatSort, cTopClient);
		}
		else break;
	}
}

public Action Timer_ThreatSystem(Handle timer) {

	static cThreatTarget			= -1;
	static cThreatOld				= -1;
	static cThreatLevel				= 0;
	static cThreatEnt				= -1;
	static count					= 0;
	static char temp[64];
	static float vPos[3];

	if (!b_IsActiveRound) {
		iSurvivalCounter = -1;

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClient(i)) {

				iThreatLevel_temp[i] = 0;
				iThreatLevel[i] = 0;
			}
		}

		count = 0;
		cThreatLevel = 0;
		iTopThreat = 0;
		// it happens due to ent shifting
		//if (!IsLegitimateClient(cThreatEnt) && cThreatEnt != -1 && EntRefToEntIndex(cThreatEnt) != INVALID_ENT_REFERENCE) AcceptEntityInput(cThreatEnt, "Kill");
		if (!IsLegitimateClient(cThreatEnt) && cThreatEnt > 0) AcceptEntityInput(cThreatEnt, "Kill");
		cThreatEnt = -1;

		return Plugin_Stop;
	}
	//if (IsLegitimateClient(cThreatEnt)) cThreatEnt = -1;
	iSurvivalCounter++;
	SortThreatMeter();
	count++;

	cThreatOld = cThreatTarget;
	cThreatLevel = 0;
	

	if (GetArraySize(hThreatMeter) < 1) {

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

				if (!IsPlayerAlive(i)) {

					iThreatLevel_temp[i] = 0;
					iThreatLevel[i] = 0;
					
					continue;
				}
				if (iThreatLevel[i] > cThreatLevel) {

					cThreatTarget = i;
					cThreatLevel = iThreatLevel[i];
				}
			}
		}
	}
	else {

		//GetArrayString(Handle:hThreatMeter, 0, temp, sizeof(temp));
		//ExplodeString(temp, "+", iThreatInfo, 2, 64);
		//client+threat
		cThreatTarget = GetArrayCell(hThreatMeter, 0, 0);
		//cThreatTarget = StringToInt(iThreatInfo[0]);
		
		//GetClientName(iClient, text, sizeof(text));
		//iThreatTarget = StringToInt(iThreatInfo[1]);
		cThreatLevel = iThreatLevel[cThreatTarget];
	}

	iTopThreat = cThreatLevel;	// when people use taunt, it sets iTopThreat + 1;
	if (cThreatOld != cThreatTarget || count >= 20) {

		count = 0;
		if (cThreatEnt > 0) AcceptEntityInput(cThreatEnt, "Kill");
		cThreatEnt = -1;
	}

	if (cThreatEnt == -1 && IsLegitimateClientAlive(cThreatTarget)) {

		cThreatEnt = CreateEntityByName("info_goal_infected_chase");
		if (cThreatEnt > 0) {
			
			cThreatEnt = EntIndexToEntRef(cThreatEnt);

			DispatchSpawn(cThreatEnt);
			//new Float:vPos[3];
			GetClientAbsOrigin(cThreatTarget, vPos);
			vPos[2] += 20.0;
			TeleportEntity(cThreatEnt, vPos, NULL_VECTOR, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(cThreatEnt, "SetParent", cThreatTarget);

			//decl String:temp[32];
			Format(temp, sizeof temp, "OnUser4 !self:Kill::20.0:-1");
			SetVariantString(temp);
			AcceptEntityInput(cThreatEnt, "AddOutput");
			AcceptEntityInput(cThreatEnt, "FireUser4");
		}
	}

	return Plugin_Continue;
}

public Action Timer_DirectorPurchaseTimer(Handle timer) {
	static Counter										=	-1;
	static float DirectorDelay							=	0.0;
	if (!b_IsActiveRound) {
		Counter											=	-1;
		return Plugin_Stop;
	}
	static theClient									=	-1;
	static theTankStartTime								=	-1;
	int iTankCount = GetInfectedCount(ZOMBIECLASS_TANK);
	int iTankLimit = GetSpecialInfectedLimit(true);
	int iInfectedCount = GetInfectedCount();
	int iSurvivors = TotalHumanSurvivors();
	int iSurvivorBots = TotalSurvivors() - iSurvivors;
	int LivingSerfs = LivingSurvivorCount();
	int requiredAlwaysTanks = GetAlwaysTanks(iSurvivors);
	int currentTime = GetTime();
	if (iSurvivorBots >= 2) iSurvivorBots /= 2;
	theClient = FindAnyRandomClient();
	if (requiredAlwaysTanks >= 1 && iTankCount < requiredAlwaysTanks && (iTanksAlwaysEnforceCooldown == 0 || f_TankCooldown == -1.0) || iTankRush == 1 && !b_IsFinaleActive && iTankCount < (iSurvivors + iSurvivorBots)) {
		ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
	}
	else if (iTankRush == 0) {

		if (iInfectedCount < (iSurvivors + iSurvivorBots)) {

			SpawnAnyInfected(theClient);
		}
	}
	int iTankRequired = GetAlwaysTanks(iSurvivors);
	if (iTankRequired != 0) {

		if (theTankStartTime == -1) theTankStartTime = GetConfigValueInt("tank rush delay?");//theTankStartTime = GetRandomInt(30, 60);
		if (theTankStartTime == 0 || RPGRoundTime(true) >= theTankStartTime) {

			theTankStartTime = 0;

			if (iInfectedCount - iTankCount < (iSurvivors)) SpawnAnyInfected(theClient);
			//if (!b_IsFinaleActive && iTankCount < iTankLimit && iTankCount < iTanksAlways) {
			// no finale active			don't force on this server		or if we do and not on cooldown
			if (!b_IsFinaleActive && (iTanksAlwaysEnforceCooldown == 0 || f_TankCooldown == -1.0) && ((iTankRequired > 0 && iTankCount < iTankLimit + iTankRequired) || (iTankRequired == 0 && iTankCount < iSurvivors + iSurvivorBots))) {

				if (IsLegitimateClientAlive(theClient))	ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
			}
		}
	}
	if (Counter == -1 || b_IsSurvivalIntermission || LivingSerfs < 1) {

		Counter = RoundToCeil(currentTime + DirectorDelay);
		return Plugin_Continue;
	}
	else if (Counter > currentTime) {

		// We still spawn specials, out of range of players to enforce the active special limit.
		return Plugin_Continue;
	}
	//PrintToChatAll("%t", "Director Think Process", orange, white);

	DirectorDelay	 = (fDirectorThoughtHandicap > 0.0) ? fDirectorThoughtDelay - (LivingSerfs * fDirectorThoughtHandicap) : fDirectorThoughtDelay;
	if (DirectorDelay < fDirectorThoughtProcessMinimum) DirectorDelay = fDirectorThoughtProcessMinimum;
	Counter = RoundToCeil(currentTime + DirectorDelay);

	int size				=	GetArraySize(a_DirectorActions);

	for (int i = 1; i <= MaximumPriority; i++) { CheckDirectorActionPriority(i, size); }

	return Plugin_Continue;
}

stock GetAlwaysTanks(survivors) {

	if (iTanksAlways > 0) return iTanksAlways;
	if (iTanksAlways < 0) {
		return RoundToFloor((survivors * 1.0)/(iTanksAlways * -1));
	}
	return 0;
}

stock CheckDirectorActionPriority(pos, size) {

	char text[64];
	char talentName[64];
	for (int i = 0; i < size; i++) {

		if (i < GetArraySize(a_DirectorActions_Cooldown)) GetArrayString(a_DirectorActions_Cooldown, i, text, sizeof(text));
		else break;
		if (StringToInt(text) > 0) continue;			// Purchase still on cooldown.
		DirectorKeys					=	GetArrayCell(a_DirectorActions, i, 2);
		GetArrayString(DirectorKeys, 0, talentName, sizeof(talentName));
		
		DirectorKeys					=	GetArrayCell(a_DirectorActions, i, 0);
		DirectorValues					=	GetArrayCell(a_DirectorActions, i, 1);
		if (GetKeyValueInt(DirectorKeys, DirectorValues, "priority?") != pos) continue;
		if (!DirectorPurchase_Valid(DirectorKeys, DirectorValues, i)) continue;
		// lol? if (GetKeyValueInt(DirectorKeys, DirectorValues, "priority?") != pos || !DirectorPurchase_Valid(DirectorKeys, DirectorValues, i)) continue;
		DirectorPurchase(DirectorKeys, DirectorValues, i, talentName);
	}
}

stock bool DirectorPurchase_Valid(Handle Keys, Handle Values, pos) {

	float PointCost		=	0.0;
	float PointCostMin	=	0.0;
	char Cooldown[64];

	GetArrayString(a_DirectorActions_Cooldown, pos, Cooldown, sizeof(Cooldown));
	if (StringToInt(Cooldown) > 0) return false;

	PointCost				=	GetKeyValueFloat(Keys, Values, "point cost?") + (GetKeyValueFloat(Keys, Values, "cost handicap?") * LivingHumanSurvivors());
	if (PointCost > 1.0) PointCost = 1.0;
	PointCostMin			=	GetKeyValueFloat(Keys, Values, "point cost minimum?") + (GetKeyValueFloat(Keys, Values, "min cost handicap?") * LivingHumanSurvivors());

	if (Points_Director > 0.0) PointCost *= Points_Director;
	if (PointCost < PointCostMin) PointCost = PointCostMin;

	if (Points_Director >= PointCost) return true;
	return false;
}

stock bool bIsDirectorTankEligible() {

	if (ActiveTanks() < DirectorTankLimit()) return true;
	return false;
}

stock ActiveTanks() {
	int iSurvivors = TotalHumanSurvivors();
	//new iSurvivorBots = TotalSurvivors() - iSurvivors;
	int count = GetAlwaysTanks(iSurvivors);

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && FindZombieClass(i) == ZOMBIECLASS_TANK) count++;
	}
	return count;
}

stock DirectorTankLimit() {
	return GetSpecialInfectedLimit(true);
}

stock GetWitchCount() {

	int count = 0;
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "witch")) != INVALID_ENT_REFERENCE) {

		// Some maps, like Hard Rain pre-spawn a ton of witches - we want to add them to the witch table.
		count++;
	}
	return count;
}

stock DirectorPurchase(Handle Keys, Handle Values, pos, char[] TalentName) {

	char Command[64];
	char Parameter[64];
	char Model[64];
	int IsPlayerDrop		=	0;
	int Count				=	0;

	float PointCost		=	0.0;
	float PointCostMin	=	0.0;

	float MinimumDelay	=	0.0;

	PointCost				=	GetKeyValueFloat(Keys, Values, "point cost?") + (GetKeyValueFloat(Keys, Values, "cost handicap?") * LivingHumanSurvivors());
	PointCostMin			=	GetKeyValueFloat(Keys, Values, "point cost minimum?") + (GetKeyValueFloat(Keys, Values, "min cost handicap?") * LivingHumanSurvivors());
	FormatKeyValue(Parameter, sizeof(Parameter), Keys, Values, "parameter?");
	Count					=	GetKeyValueInt(Keys, Values, "count?");
	int CountHandicap		=	GetKeyValueInt(Keys, Values, "count handicap?");
	Count += (CountHandicap * LivingSurvivorCount());
	FormatKeyValue(Command, sizeof(Command), Keys, Values, "command?");
	IsPlayerDrop			=	GetKeyValueInt(Keys, Values, "drop?");
	FormatKeyValue(Model, sizeof(Model), Keys, Values, "model?");
	MinimumDelay			=	GetKeyValueFloat(Keys, Values, "minimum delay?");

	if (PointCost > 1.0) {

		PointCost			=	1.0;
	}

	bool bIsEnrage = IsEnrageActive();

	//if (ReadyUp_GetGameMode() != 3 && b_IsFinaleActive && StrContains(Parameter, "witch", false) == -1 && StrContains(Parameter, "tank", false) == -1) return;

	if (DirectorWitchLimit == 0) DirectorWitchLimit = LivingSurvivorCount();


	if (StrContains(Parameter, "witch", false) != -1 && (IsSurvivalMode || GetWitchCount() >= DirectorWitchLimit || GetArraySize(WitchList) + 1 >= DirectorWitchLimit)) return;
	if (StrContains(Parameter, "tank", false) != -1 && (IsSurvivalMode || (ActiveTanks() >= DirectorTankLimit() && !bIsEnrage || bIsEnrage && ActiveTanks() >= LivingHumanSurvivors()) || f_TankCooldown != -1.0)) return;

	if (StrEqual(Parameter, "common")) {

		if (GetArraySize(CommonInfectedQueue) + Count >= GetCommonQueueLimit()) {

			return;
		}
	}

	/*if ((StrEqual(Command, "director_force_panic_event") || IsPlayerDrop) && b_IsFinaleActive) {

		return;
	}*/
	//if (!IsEnrageActive() && StrEqual(Command, "director_force_panic_event")) return;

	if (Points_Director > 0.0) PointCost *= Points_Director;
	if (PointCost < PointCostMin) PointCost = PointCostMin;

	if (Points_Director < PointCost) return;

	if (LivingSurvivorCount() < GetKeyValueInt(Keys, Values, "living survivors?")) return;

	int Client				=	FindLivingSurvivor();
	if (Client < 1) return;
	char sTalentName[64];
	Format(sTalentName, sizeof(sTalentName), "%t", TalentName);

	PrintToChatAll("%t", "director purchase announcement", orange, blue, green, sTalentName, orange, green, PointCost, orange);

	Points_Director -= PointCost;

	if (!IsEnrageActive() && MinimumDelay > 0.0) {

		SetArrayString(a_DirectorActions_Cooldown, pos, "1");
		MinimumDelay = MinimumDelay - (LivingHumanSurvivors() * fDirectorThoughtHandicap) - (GetKeyValueFloat(Keys, Values, "delay handicap?") * LivingHumanSurvivors());
		if (MinimumDelay < 0.0) MinimumDelay = 1.0;
		fDirectorThoughtDelay = fDirectorThoughtDelay - (LivingHumanSurvivors() * fDirectorThoughtHandicap);
		if (fDirectorThoughtDelay < 0.0) fDirectorThoughtDelay = 0.0;
		CreateTimer(fDirectorThoughtDelay + MinimumDelay, Timer_DirectorActions_Cooldown, pos, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (!StrEqual(Parameter, "common")) ExecCheatCommand(Client, Command, Parameter);
	else {
		char superCommonType[64];
		FormatKeyValue(superCommonType, sizeof(superCommonType), Keys, Values, "supercommon?");
		SpawnCommons(Client, Count, Command, Parameter, Model, IsPlayerDrop, superCommonType);
	}
}

/*stock InsertInfected(survivor, infected) {

	CreateListPositionByEntity(survivor, infected, InfectedHealth[survivor]);
	new isArraySize = GetArraySize(Handle:InfectedHealth[survivor]);
	new t_InfectedHealth = 0;
	ResizeArray(Handle:InfectedHealth[survivor], isArraySize + 1);
	SetArrayCell(Handle:InfectedHealth[survivor], isArraySize, infected, 0);

	//An infected wasn't added on spawn to this player, so we add it now based on class.
	if (FindZombieClass(infected) == ZOMBIECLASS_TANK) t_InfectedHealth = 4000;
	else if (FindZombieClass(infected) == ZOMBIECLASS_HUNTER || FindZombieClass(infected) == ZOMBIECLASS_SMOKER) t_InfectedHealth = 250;
	else if (FindZombieClass(infected) == ZOMBIECLASS_BOOMER) t_InfectedHealth = 50;
	else if (FindZombieClass(infected) == ZOMBIECLASS_SPITTER) t_InfectedHealth = 100;
	else if (FindZombieClass(infected) == ZOMBIECLASS_CHARGER) t_InfectedHealth = 600;
	else if (FindZombieClass(infected) == ZOMBIECLASS_JOCKEY) t_InfectedHealth = 325;

	decl String:ss_InfectedHealth[64];
	Format(ss_InfectedHealth, sizeof(ss_InfectedHealth), "(%d) infected health bonus", FindZombieClass(infected));

	if (StringToInt(GetConfigValue("infected bot level type?")) == 1) t_InfectedHealth += t_InfectedHealth * RoundToCeil(HumanSurvivorLevels() * StringToFloat(GetConfigValue(ss_InfectedHealth)));
	else t_InfectedHealth += t_InfectedHealth * RoundToCeil(PlayerLevel[survivor] * StringToFloat(GetConfigValue(ss_InfectedHealth)));
	if (HandicapLevel[survivor] > 0) t_InfectedHealth += t_InfectedHealth * RoundToCeil(HandicapLevel[survivor] * StringToFloat(GetConfigValue("handicap health increase?")));

	SetArrayCell(Handle:InfectedHealth[survivor], isArraySize, t_InfectedHealth, 1);
	SetArrayCell(Handle:InfectedHealth[survivor], isArraySize, 0, 2);
	SetArrayCell(Handle:InfectedHealth[survivor], isArraySize, 0, 3);
	if (isArraySize == 0) return -1;
	return isArraySize;
}*/

stock SpawnCommons(Client, Count, char[] Command, char[] Parameter, char[] Model, IsPlayerDrop, char[] SuperCommon = "none") {

	int TargetClient				=	-1;
	int CommonQueueLimit = GetCommonQueueLimit();
	if (StrContains(Model, ".mdl", false) != -1) {

		for (int i = Count; i > 0 && GetArraySize(CommonInfectedQueue) < CommonQueueLimit; i--) {

			if (IsPlayerDrop == 1) {

				ResizeArray(CommonInfectedQueue, GetArraySize(CommonInfectedQueue) + 1);
				ShiftArrayUp(CommonInfectedQueue, 0);
				SetArrayString(CommonInfectedQueue, 0, Model);
				TargetClient		=	FindLivingSurvivor();
				if (StrContains(SuperCommon, "-", false) == -1 && !StrEqual(SuperCommon, "none", false)) PushArrayString(SuperCommonQueue, SuperCommon);
				if (TargetClient > 0) ExecCheatCommand(TargetClient, Command, Parameter);
			}
			else PushArrayString(CommonInfectedQueue, Model);
		}
	}
}

stock FindAnotherSurvivor(client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (i == client) continue;
		return i;
	}
	return -1;
}

stock FindLivingSurvivor(bool noBOT = false) {


	/*new Client = -1;
	while (Client == -1 && LivingSurvivorCount() > 0) {

		Client = GetRandomInt(1, MaxClients);
		if (!IsClientInGame(Client) || !IsClientHuman(Client) || !IsPlayerAlive(Client) || GetClientTeam(Client) != TEAM_SURVIVOR) Client = -1;
	}
	return Client;*/
	int livingSurvivors = LivingSurvivorCount();
	for (int i = LastLivingSurvivor; i <= MaxClients && livingSurvivors > 0; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
			if (noBOT && IsFakeClient(i)) continue;

			LastLivingSurvivor = i;
			return i;
		}
	}
	LastLivingSurvivor = 1;
	if (LivingSurvivorCount() < 1) return -1;
	return -1;
}

stock LivingSurvivorCount(ignore = -1) {

	int Count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && (ignore == -1 || i != ignore)) Count++;
	}
	return Count;
}

public Action Timer_DirectorActions_Cooldown(Handle timer, any pos) {

	SetArrayString(a_DirectorActions_Cooldown, pos, "0");
	return Plugin_Stop;
}
