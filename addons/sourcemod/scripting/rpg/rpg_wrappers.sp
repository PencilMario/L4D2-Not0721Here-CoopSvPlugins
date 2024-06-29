/* put the line below after all of the includes!
#pragma newdecls required
*/

/*
 *	Provides a shortcut method to calling ANY value from keys found in CONFIGS/READYUP/RPG/CONFIG.CFG
 *	@return		-1		if the requested key could not be found.
 *	@return		value	if the requested key is found.
 */
stock void GetConfigValue(char[] TheString, int TheSize, char[] KeyName, char[] sDefaultVal = "-1") {
	static char text[512];
	int a_Size			= GetArraySize(MainKeys);
	for (int i = 0; i < a_Size; i++) {

		GetArrayString(MainKeys, i, text, sizeof(text));

		if (StrEqual(text, KeyName)) {

			GetArrayString(MainValues, i, TheString, TheSize);
			return;
		}
	}
	Format(TheString, TheSize, "%s", sDefaultVal);
}

stock float GetConfigValueFloat(char[] KeyName, float fDefaultVal = -1.0) {
	
	static char text[512];

	int a_Size			= GetArraySize(MainKeys);

	for (int i = 0; i < a_Size; i++) {

		GetArrayString(MainKeys, i, text, sizeof(text));

		if (StrEqual(text, KeyName)) {

			GetArrayString(MainValues, i, text, sizeof(text));
			return StringToFloat(text);
		}
	}
	return fDefaultVal;
}

stock int GetConfigValueInt(char[] KeyName, int defaultValue = -1) {
	
	static char text[512];

	int a_Size			= GetArraySize(MainKeys);

	for (int i = 0; i < a_Size; i++) {

		GetArrayString(MainKeys, i, text, sizeof(text));

		if (StrEqual(text, KeyName)) {

			GetArrayString(MainValues, i, text, sizeof(text));
			return StringToInt(text);
		}
	}
	return defaultValue;
}

/*
 *	Checks if any survivors are incapacitated.
 *	@return		true/false		depending on the result.
 */
stock bool AnySurvivorsIncapacitated() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsIncapacitated(i)) return true;
	}
	return false;
}

/*
 *	Checks if there are any non-bot, non-spectator players in the game.
 *	@return		true/false		depending on the result.
 */
stock bool IsPlayersParticipating() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) return true;
	}
	return false;
}

stock int GetAnyPlayerNotMe(int client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || i == client) continue;
		return i;
	}
	return -1;
}

stock int FindAnyClient() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		return i;
	}
	return -1;
}

/*
 *	Finds a random, non-infected client in-game.
 *	@return		client index if found.
 *	@return		-1 if not found.
 */
stock int FindAnyRandomClient(bool bMustBeAlive = false, int ignoreclient = 0) {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && !IsLedged(i) && (GetEntityFlags(i) & FL_ONGROUND) && i != ignoreclient) {

			if (bMustBeAlive && IsPlayerAlive(i) || !bMustBeAlive) return i;
		}
	}
	return -1;
}

stock bool IsMeleeWeaponParameter(char[] parameter) {

	if (StrEqual(parameter, "fireaxe", false) ||
		StrEqual(parameter, "cricket_bat", false) ||
		StrEqual(parameter, "tonfa", false) ||
		StrEqual(parameter, "frying_pan", false) ||
		StrEqual(parameter, "golfclub", false) ||
		StrEqual(parameter, "electric_guitar", false) ||
		StrEqual(parameter, "katana", false) ||
		StrEqual(parameter, "machete", false) ||
		StrEqual(parameter, "crowbar", false)) return true;
	return false;
}

// stock int GetMeleeWeaponDamage(int attacker, int victim, char[] weapon) {

// 	int zombieclass				= FindZombieClass(victim);
// 	int size					= GetArraySize(a_Melee_Damage);
// 	int healthvalue				= 0;

// 	char s_zombieclass[4];

// 	for (int i = 0; i < size; i++) {

// 		MeleeKeys[attacker]		= GetArrayCell(a_Melee_Damage, i, 0);
// 		MeleeValues[attacker]	= GetArrayCell(a_Melee_Damage, i, 1);
// 		MeleeSection[attacker]	= GetArrayCell(a_Melee_Damage, i, 2);

// 		GetArrayString(MeleeSection[attacker], 0, s_zombieclass, sizeof(s_zombieclass));
// 		if (StringToInt(s_zombieclass) == zombieclass) {

// 			healthvalue			= RoundToCeil(GetKeyValueFloat(MeleeKeys[attacker], MeleeValues[attacker], weapon) * GetMaximumHealth(victim));
// 			if (healthvalue > GetClientTotalHealth(victim)) healthvalue		= GetClientTotalHealth(victim);
// 			return healthvalue;
// 		}
// 	}
// 	return 0;
// }

/*
 *	Checks to see if the client has an active experience booster.
 *	If the client does, ExperienceValue is multiplied against the booster value and returned.
 *	@return (ExperienceValue * Multiplier)		where Multiplier is modified based on the result of AddMultiplier(client, i)
 */
stock float CheckExperienceBooster(int client, int ExperienceValue) {

	// Return ExperienceValue as it is if the client doesn't have a booster active.
	char key[64];
	char value[64];

	float Multiplier					= 0.0;	// 1.0 is the DEFAULT (Meaning NO CHANGE)

	int size								= GetArraySize(a_Store);
	int size2								= 0;
	for (int i = 0; i < size; i++) {

		StoreKeys[client]					= GetArrayCell(a_Store, i, 0);
		StoreValues[client]					= GetArrayCell(a_Store, i, 1);

		size2								= GetArraySize(StoreKeys[client]);
		for (int ii = 0; ii < size2; ii++) {

			GetArrayString(StoreKeys[client], ii, key, sizeof(key));
			GetArrayString(StoreValues[client], ii, value, sizeof(value));

			if (StrEqual(key, "item effect?") && StrEqual(value, "x")) {

				Multiplier += AddMultiplier(client, i);		// If the client has no time in it, it just adds 0.0.
			}
		}
	}

	return Multiplier;
}

/*
 *	Checks to see whether:
 *	a.) The position in the store is an experience booster
 *	b.) If it is, if the client has time remaining in it.
 *	@return		Float:value			time remaining on experience booster. 0.0 if it could not be found.
 */
stock float AddMultiplier(int client, int pos) {

	if (!IsLegitimateClient(client) || pos >= GetArraySize(a_Store_Player[client])) return 0.0;
	char ClientValue[64];
	GetArrayString(a_Store_Player[client], pos, ClientValue, sizeof(ClientValue));

	char key[64];
	char value[64];

	if (StringToInt(ClientValue) > 0) {

		StoreMultiplierKeys[client]			= GetArrayCell(a_Store, pos, 0);
		StoreMultiplierValues[client]		= GetArrayCell(a_Store, pos, 1);

		int size							= GetArraySize(StoreMultiplierKeys[client]);
		for (int i = 0; i < size; i++) {

			GetArrayString(StoreMultiplierKeys[client], i, key, sizeof(key));
			GetArrayString(StoreMultiplierValues[client], i, value, sizeof(value));

			if (StrEqual(key, "item strength?")) return StringToFloat(value);
		}
	}

	return 0.0;		// It wasn't found, so no multiplier is added.
}

stock int GetShotgunPelletCount(int client) {

	int CurrentEntity								= GetPlayerWeaponSlot(client, 0);

	char EntityName[64];
	if (IsValidEntity(CurrentEntity)) GetEntityClassname(CurrentEntity, EntityName, sizeof(EntityName));
	if (StrContains(EntityName, "shotgun", false) != -1) {
		if (StrContains(EntityName, "pump", false) != -1) return 8;
		if (StrContains(EntityName, "chrome", false) != -1 || StrContains(EntityName, "spas", false) != -1) return 9;
		if (StrContains(EntityName, "auto", false) != -1) return 11;
	}
	return 0;
}

stock bool IsPlayerUsingShotgun(int client) {

	int CurrentEntity								= GetPlayerWeaponSlot(client, 0);

	char EntityName[64];
	if (IsValidEntity(CurrentEntity)) GetEntityClassname(CurrentEntity, EntityName, sizeof(EntityName));
	if (StrContains(EntityName, "shotgun", false) != -1) return true;
	return false;
}

stock void GetMeleeWeapon(int client, char[] Weapon, int size) {
	int g_iActiveWeaponOffset = 0;
	int iWeapon = 0;
	GetClientWeapon(client, Weapon, size);
	if (StrEqual(Weapon, "weapon_melee", false)) {
		g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
		GetEntityClassname(iWeapon, Weapon, size);
		GetEntPropString(iWeapon, Prop_Data, "m_strMapSetScriptName", Weapon, size);
	}
	else Format(Weapon, size, "null");
}

// we format the string for the name of the target, but we also send back an int result to let the code know
// how to interpret the results (and what information to show on the weapons page of the character sheet)
stock int DataScreenTargetName(int client, char[] stringRef, int size) {
	//char text[64];
	float TargetPos[3];
	char hitgroup[4];
	int target = GetAimTargetPosition(client, TargetPos, hitgroup, 4);
	//GetClientAimTargetEx(client, text, sizeof(text), true);
	//new target = StringToInt(text);
	if (target == -1) return -1;
	else {
		if (IsLegitimateClient(target)) {
			GetClientName(target, stringRef, size);
			return 4;
		}
		else if (IsWitch(target)) {
			Format(stringRef, size, "%T", "witch aim target", client);
			return 3;
		}
		else if (IsSpecialCommon(target)) {
			Format(stringRef, size, "%T", "special common aim target", client);
			return 2;
		}
		else {
			Format(stringRef, size, "%T", "common aim target", client);
			return 1;
		}
	}
}

stock int DataScreenWeaponDamage(int client, bool isHealing = false) {
	float TargetPos[3];
	int hitgroup = -1;
	char hitspot[4];
	int target = GetAimTargetPosition(client, TargetPos, hitspot, 4);
	if (strlen(hitspot) > 0) hitgroup = StringToInt(hitspot);
	return GetBaseWeaponDamage(client, target, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET, _, true, hitgroup, isHealing);
}

stock int GetWeaponProficiencyType(int client) {
	// char Weapon[64];
	// GetClientWeapon(client, Weapon, sizeof(Weapon));
	if (StrContains(MyCurrentWeapon[client], "pistol", false) != -1) return 0;
	if (hasMeleeWeaponEquipped[client]) return 1;
	if (StrContains(MyCurrentWeapon[client], "smg", false) != -1) return 2;
	if (StrContains(MyCurrentWeapon[client], "shotgun", false) != -1) return 3;
	if (StrContains(MyCurrentWeapon[client], "sniper", false) != -1 || StrContains(MyCurrentWeapon[client], "hunting", false) != -1) return 4;
	if (StrContains(MyCurrentWeapon[client], "rifle", false) != -1) return 5;
	return -1;	// should never occur
}
/*
	result 1 to get the offset, which is used to determine how much reserve ammo there is remaining.
	result 2 to get the max amount of reserve ammo this weapon can hold.
	result 3 to get the current amount of reserve ammo is remaining.
	result 4 is the amount of ammo to return to the magazine
	result 5 is to give the player the max amount of reserve ammo
*/
stock int GetWeaponResult(int client, int result = 0, int amountToAdd = 0) {
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	if (!IsValidEntity(iWeapon)) return -1;
	char Weapon[64];
	char WeaponName[64];
	GetEntityClassname(iWeapon, Weapon, sizeof(Weapon));
	int size = GetArraySize(a_WeaponDamages);
	float fValue = 0.0;
	int targetgun = GetPlayerWeaponSlot(client, 0);
	int wOffset = 0;
	if (result >= 3) {
		if (!IsValidEdict(targetgun)) return -1;
		targetgun = FindDataMapInfo(client, "m_iAmmo");
		wOffset = GetWeaponResult(client, 1);
	}

	for (int i = 0; i < size; i++) {
		WeaponResultSection[client] = GetArrayCell(a_WeaponDamages, i, 2);
		GetArrayString(WeaponResultSection[client], 0, WeaponName, sizeof(WeaponName));
		if (!StrEqual(WeaponName, Weapon, false)) continue;
		//WeaponResultKeys[client] = GetArrayCell(a_WeaponDamages, i, 0);
		WeaponResultValues[client] = GetArrayCell(a_WeaponDamages, i, 1);
		if (result == 0) {
			fValue = GetArrayCell(WeaponResultValues[client], WEAPONINFO_RANGE);
			int rounded = RoundToCeil(fValue);
			fValue = GetAbilityStrengthByTrigger(client, _, "gunRNG", _, rounded, _, _, "d", 1, true);
			if (bIsInCombat[client]) fValue = GetAbilityStrengthByTrigger(client, _, "ICwRNG", _, rounded, _, _, "d", 1, true);
			else fValue = GetAbilityStrengthByTrigger(client, _, "OCwRNG", _, rounded, _, _, "d", 1, true);
			return RoundToCeil(fValue);
		}
		if (result == 1) return GetArrayCell(WeaponResultValues[client], WEAPONINFO_OFFSET);
		if (result == 2 || result == 5) {
			int value = GetArrayCell(WeaponResultValues[client], WEAPONINFO_AMMO);
			value += RoundToCeil(GetAbilityStrengthByTrigger(client, _, "ammoreserve", _, value, _, _, "ammoreserve", 0, true));
			if (result == 5) SetEntData(client, (targetgun + wOffset), value);
			return value;
		}
		if (result == 3) {
			return GetEntData(client, (targetgun + wOffset));
		}
		if (result == 4) {
			SetEntData(client, (targetgun + wOffset), GetEntData(client, (targetgun + wOffset)) + amountToAdd);
			return amountToAdd;
		}
		break;
	}
	return -1;
}

stock int GetBaseWeaponDamage(int client, int target, float impactX = 0.0, float impactY = 0.0, float impactZ = 0.0, int damagetype, bool bGetBaseDamage = false, bool IsDataSheet = false, int hitgroup = -1, bool isHealing = false) {
	// bool targetIsCommonInfected = (IsCommonInfected(target) && !IsSpecialCommon(target));
	// if (targetIsCommonInfected && IsCommonInfected(lastTarget[client])) return lastBaseDamage[client];
	char WeaponName[512];
	bool IsMelee = hasMeleeWeaponEquipped[client];
	// not a boolean because this variable can have other results under edge cases
	int dontActivateTalentCooldown = (IsDataSheet) ? 1 : 0;
	//bool IsTank = (IsLegitimateClient(target) && FindZombieClass(target) == ZOMBIECLASS_TANK) ? true : false;
	// we only want this to return true for standard commons, not super commons.
	//bool IsCommonInfectedTarget = (IsCommonInfected(target)) ? true : false;
	// To help cut down on the cost of calculating damage on EVERY event...
	// if we know the damage is going to be the same, why calculate it again?
	// If the target is a common infected, if their last target was a common infected or super common, we don't calculate damage and instead return the last calculated damage value.
	//if (IsCommonInfectedTarget && (target == lastTarget[client] || IsCommonInfected(lastTarget[client])) && StrEqual(Weapon, lastWeapon[client])) { return lastBaseDamage[client]; }
	int WeaponDamage = 0;
	float WeaponRange = 0.0;
	float WeaponDamageRangePenalty = 0.0;
	float RangeRequired = 0.0;

	float cpos[3];
	float tpos[3];
	GetClientAbsOrigin(client, cpos);
	if (target != -1) {
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);
	}
	else {
		tpos[0] = impactX;
		tpos[1] = impactY;
		tpos[2] = impactZ;
	}
	float Distance = GetVectorDistance(cpos, tpos);
	int baseWeaponTemp = 0;
	int size = GetArraySize(a_WeaponDamages);
	float TheAbilityMultiplier;
	float MaxMultiplier;
	int clientFlags = GetEntityFlags(client);
	int weaponProficiencyLevel = GetProficiencyData(client, GetWeaponProficiencyType(client), _, _, true);
	float healStrength = 0.0;
	bool IsLegitimateTargetAlive = (IsLegitimateClientAlive(target)) ? true : false;
	for (int i = 0; i < size; i++) {
		DamageSection[client] = GetArrayCell(a_WeaponDamages, i, 2);
		GetArrayString(DamageSection[client], 0, WeaponName, sizeof(WeaponName));
		if (!StrEqual(WeaponName, MyCurrentWeapon[client], false)) continue;

		//DamageKeys[client] = GetArrayCell(a_WeaponDamages, i, 0);
		DamageValues[client] = GetArrayCell(a_WeaponDamages, i, 1);
		WeaponDamage = GetArrayCell(DamageValues[client], WEAPONINFO_DAMAGE);
 		baseWeaponTemp = WeaponDamage;
		// if (IsDataSheet) // we don't need this if statement anymore since the dontActivateTalentCooldown boolean is set based on the variable.
		if (!isHealing) {
			if (IsDataSheet) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "D", _, WeaponDamage, _, _, "d", 2, true, _, hitgroup, _, damagetype, 0));	// cooldowns will NOT trigger
			else baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "D", _, WeaponDamage, _, _, "d", 2, true, _, hitgroup, _, damagetype, 0, true));	// cooldowns will trigger
		}
		else {
			if (!IsMelee) {
				if (IsDataSheet) healStrength = GetAbilityStrengthByTrigger(client, target, "hB", _, 0, _, _, "d", 2, true, _, hitgroup, _, damagetype, 0);	// cooldowns will NOT trigger
				else healStrength = GetAbilityStrengthByTrigger(client, target, "hB", _, 0, _, _, "d", 2, true, _, hitgroup, _, damagetype, 0, true);	// cooldowns will trigger
			}
			else {
				if (IsDataSheet) healStrength = GetAbilityStrengthByTrigger(client, target, "hM", _, 0, _, _, "d", 2, true, _, hitgroup, _, damagetype, 0);	// cooldowns will NOT trigger
				else healStrength = GetAbilityStrengthByTrigger(client, target, "hM", _, 0, _, _, "d", 2, true, _, hitgroup, _, damagetype, 0, true);	// cooldowns will trigger
			}
			if (IsLegitimateTargetAlive) {
				TheAbilityMultiplier = GetAbilityMultiplier(target, "expo");
				if (TheAbilityMultiplier > 0.0) healStrength += RoundToCeil(healStrength * TheAbilityMultiplier);
			}
			if (healStrength <= 0.0) return 0;
			WeaponDamage = RoundToCeil(WeaponDamage * healStrength);
			baseWeaponTemp = WeaponDamage;
		}
		// if ((clientFlags & IN_DUCK)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "crouch", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));
 		// if ((clientFlags & FL_INWATER)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "wtr", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));
 		// else if (!(clientFlags & FL_ONGROUND)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "grnd", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));
 		// if ((clientFlags & FL_ONFIRE)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "onfire", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));

 		// The player, above, receives a flat damage increase of 50% just for having adrenaline active.
 		// Now, we increase their damage if they're in rage ammo, which is a separate thing, although it also provides the adrenaline buff.
		if (fSurvivorBufferBonus > 0.0 && IsSpecialCommonInRange(client, 'b')) baseWeaponTemp += RoundToCeil(WeaponDamage * fSurvivorBufferBonus);
 		//if (IsClientInRangeSpecialAmmo(client, "a") == -2.0) baseWeaponTemp += RoundToCeil(WeaponDamage * IsClientInRangeSpecialAmmo(client, "a", false));
		int weaponDamageExperienceCalculator = (!IsDataSheet) ? WeaponDamage : 0;
		float ammoStr = IsClientInRangeSpecialAmmo(client, "d", _, _, weaponDamageExperienceCalculator);
 		if (ammoStr > 0.0) baseWeaponTemp += RoundToCeil(WeaponDamage * ammoStr);
		ammoStr = IsClientInRangeSpecialAmmo(client, "E", _, _, weaponDamageExperienceCalculator);
 		if (ammoStr > 0.0) baseWeaponTemp += RoundToCeil(WeaponDamage * ammoStr);
		ammoStr = IsClientInRangeSpecialAmmo(target, "E", _, _, weaponDamageExperienceCalculator);
 		if (ammoStr > 0.0) baseWeaponTemp += RoundToCeil(WeaponDamage * ammoStr);

		if (!IsDataSheet) {
			// some ammos don't increase damage directly HERE, but we still give experience benefits because they buffed damage elsewhere.
			IsClientInRangeSpecialAmmo(client, "a", _, _, weaponDamageExperienceCalculator);
		}
		//}
		//else
		// if (damagetype == DMG_BURN) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "G", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));	// THE 1 simply means that it adds the damagevalue before multiplying; if the player has no points in the talent, they do the base damage instead.
		// if (damagetype == DMG_BLAST) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "S", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));
		// if (damagetype == DMG_CLUB) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "U", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));
	 	// if (damagetype == DMG_SLASH) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "u", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype, dontActivateTalentCooldown));
		
		WeaponRange = GetArrayCell(DamageValues[client], WEAPONINFO_RANGE);
		int rangeRounded = RoundToCeil(WeaponRange);

		//if (!IsMelee && (damagetype & DMG_BULLET)) {
		if (!IsMelee) {
			WeaponRange += GetAbilityStrengthByTrigger(client, target, "gunRNG", _, rangeRounded, _, _, "d", 2, true, _, hitgroup, _, damagetype, dontActivateTalentCooldown);
			baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "gunDMG", _, WeaponDamage, _, _, "d", 2, true, _, hitgroup, _, damagetype, dontActivateTalentCooldown));

			if (bIsInCombat[client]) {
				WeaponRange += GetAbilityStrengthByTrigger(client, target, "ICwRNG", _, rangeRounded, _, _, "d", 2, true, _, _, _, damagetype, dontActivateTalentCooldown);
				baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "ICwDMG", _, WeaponDamage, _, _, "d", 2, true, _, hitgroup, _, damagetype, dontActivateTalentCooldown));
			}
			else {
				WeaponRange += GetAbilityStrengthByTrigger(client, target, "OCwRNG", _, rangeRounded, _, _, "d", 2, true, _, _, _, damagetype, dontActivateTalentCooldown);
				baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "OCwDMG", _, WeaponDamage, _, _, "d", 2, true, _, hitgroup, _, damagetype, dontActivateTalentCooldown));
			}
		}
		else {
			baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "mDMG", _, WeaponDamage, _, _, "d", 2, true, _, hitgroup, _, damagetype, dontActivateTalentCooldown));
		}
		if (baseWeaponTemp > 0) WeaponDamage = baseWeaponTemp;

		TheAbilityMultiplier = GetAbilityMultiplier(client, "N");
		if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		TheAbilityMultiplier = GetAbilityMultiplier(client, "C");
		if (TheAbilityMultiplier != -1.0) {
			MaxMultiplier = GetAbilityMultiplier(client, "C", 3);
			if (ConsecutiveHits[client] > 0) TheAbilityMultiplier *= ConsecutiveHits[client];
			if (TheAbilityMultiplier > MaxMultiplier) TheAbilityMultiplier = MaxMultiplier;
			if (TheAbilityMultiplier > 0.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier); // damage dealt is increased
		}
		if (!(clientFlags & FL_ONGROUND)) {
			TheAbilityMultiplier = GetAbilityMultiplier(client, "K");
			if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		}
		if ((clientFlags & FL_INWATER)) {
			TheAbilityMultiplier = GetAbilityMultiplier(client, "a");
			if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		}
		if ((clientFlags & FL_ONFIRE)) {
			TheAbilityMultiplier = GetAbilityMultiplier(client, "f");
			if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		}
		RangeRequired = 0.0;
		if (!IsMelee) {
			if (Distance > WeaponRange && WeaponRange > 0.0) {

				/*

					In order to balance weapons and prevent one weapon from being the all-powerful go-to choice
					a weapon fall-off range is introduced.
					The amount of damage when receiving this penalty is equal to
					RoundToCeil(((Distance - WeaponRange) / WeaponRange) * damage);

					We subtract this value from overall damage.

					Some weapons (like certain sniper rifles) may not have a fall-off range.
				*/
				WeaponDamageRangePenalty = 1.0 - ((Distance - WeaponRange) / WeaponRange);
				WeaponDamage = RoundToCeil(WeaponDamage * WeaponDamageRangePenalty);
				if (WeaponDamage < 1) WeaponDamage = 1;		// If you're double the range or greater, congrats, bb gun.
			}
			if (Distance <= RangeRequired && RangeRequired > 0.0) {

				WeaponDamageRangePenalty = 1.0 - ((RangeRequired - Distance) / RangeRequired);
				WeaponDamage = RoundToCeil(WeaponDamage * WeaponDamageRangePenalty);
				if (WeaponDamage < 1) WeaponDamage = 1;
			}
		}
		if (!IsDataSheet) {
			lastBaseDamage[client] = WeaponDamage;
			//Format(lastWeapon[client], sizeof(lastWeapon[]), "%s", Weapon);
			lastTarget[client] = target;
		}
		if (weaponProficiencyLevel > 0) WeaponDamage += RoundToCeil((weaponProficiencyLevel * fProficiencyLevelDamageIncrease) * WeaponDamage);
		return WeaponDamage;
	}
	//LogMessage("Could not find header for %s", Weapon);
	return 0;
}

stock bool IsSurvivor(int client) {

	if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	return false;
}

stock bool IsFireDamage(int damagetype) {

	if (damagetype == 8 || damagetype == 2056 || damagetype == 268435464) return true;
	return false;
}

stock void GetSurvivorBotName(int client, char[] TheBuffer, int TheSize) {

	char TheModel[64];
	GetClientModel(client, TheModel, sizeof(TheModel));	// helms deep creates bots that aren't necessarily on the survivor team.
		
	if (StrEqual(TheModel, NICK_MODEL)) Format(TheBuffer, TheSize, "Nick");
	else if (StrEqual(TheModel, ROCHELLE_MODEL)) Format(TheBuffer, TheSize, "Rochelle");
	else if (StrEqual(TheModel, COACH_MODEL)) Format(TheBuffer, TheSize, "Coach");
	else if (StrEqual(TheModel, ELLIS_MODEL)) Format(TheBuffer, TheSize, "Ellis");
	else if (StrEqual(TheModel, LOUIS_MODEL)) Format(TheBuffer, TheSize, "Louis");
	else if (StrEqual(TheModel, ZOEY_MODEL)) Format(TheBuffer, TheSize, "Zoey");
	else if (StrEqual(TheModel, BILL_MODEL)) Format(TheBuffer, TheSize, "Bill");
	else if (StrEqual(TheModel, FRANCIS_MODEL)) Format(TheBuffer, TheSize, "Francis");
}

stock void ForceLoadDefaultProfiles(int loadtarget) {
	if (!IsLegitimateClient(loadtarget)) return;
	if (GetClientTeam(loadtarget) == TEAM_SURVIVOR) {
		if (IsFakeClient(loadtarget)) {
			SetTotalExperienceByLevel(loadtarget, iBotPlayerStartingLevel);
			LoadProfileEx(loadtarget, DefaultBotProfileName);
		}
		else {
			SetTotalExperienceByLevel(loadtarget, iPlayerStartingLevel);
			LoadProfileEx(loadtarget, DefaultProfileName);
		}
	}
	else LoadProfileEx(loadtarget, DefaultInfectedProfileName);
	return;
}

stock bool IsSurvivorPlayer(int client) {

	if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	return false;
}

stock bool CommonInfectedModel(int ent, char[] SearchKey) {

	char ModelName[64];
 	GetEntPropString(ent, Prop_Data, "m_ModelName", ModelName, sizeof(ModelName));
 	if (StrContains(ModelName, SearchKey, false) != -1) return true;
 	return false;
}

stock int GetSurvivorsInRange(int client, float Distance) {

	float cpos[3];
	float spos[3];
	int count = 0;
	GetClientAbsOrigin(client, cpos);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(cpos, spos) <= Distance) count++;
	}
	return count;
}

stock bool SurvivorsWithinRange(int client, float Distance) {

	float cpos[3];
	float spos[3];
	GetClientAbsOrigin(client, cpos);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(cpos, spos) <= Distance) return true;
	}
	return false;
}

stock int DoesClientHaveTheHighGround(float cpos[3], int target) {
	float tpos[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);
	if (cpos[2] > tpos[2]) return 1;	// client is above target
	if (cpos[2] < tpos[2]) return -1;	// client is below target
	return 0;							// client and target are on same level.
}

stock float GetTargetRange(int client, int target) {
	float cpos[3];
	float tpos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", cpos);
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);

	return GetVectorDistance(cpos, tpos);
}

stock bool IsClientInRange(int client, int target, float range) {

	float cpos[3];
	float tpos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", cpos);
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);

	if (GetVectorDistance(cpos, tpos) <= range) return true;
	return false;
}

stock bool CheckTankState(int client, char[] StateName) {

	char text[64];
	for (int i = 0; i < GetArraySize(TankState_Array[client]); i++) {

		GetArrayString(TankState_Array[client], i, text, sizeof(text));
		if (StrEqual(text, StateName)) return true;	
	}
	//if (GetArraySize(TankState_Array[client]))
	return false;
}

stock int ChangeTankState(int client, char[] StateName, bool IsDelete = false, bool GetState = false) {

	if (!b_IsActiveRound) return -1;
	if (!IsLegitimateClientAlive(client) || FindZombieClass(client) != ZOMBIECLASS_TANK) return -3;

	char text[64];
	int size = GetArraySize(TankState_Array[client]);

	char sCurState[64];
	if (size > 0) GetArrayString(TankState_Array[client], 0, sCurState, sizeof(sCurState));

	if (GetState || IsDelete) {

		//if (size < 1 && IsDelete) return 0;
		if (size < 1) return 0;
		if (StrEqual(text, StateName)) {

			if (!IsDelete) return 1;
			ClearArray(TankState_Array[client]);
			return -1;
		}
	}
	else {

		if (iTanksPreset == 0 && size > 0 && !StrEqual(sCurState, StateName) || size < 1) {

			if (size > 0) SetArrayString(TankState_Array[client], 0, StateName);
			else PushArrayString(TankState_Array[client], StateName);

			if (iTanksPreset == 1) {

				char sTank[64];
				Format(sTank, sizeof(sTank), "tank spawn:%s", StateName);
				char sText[64];
				for (int i = 1; i <= MaxClients; i++) {
					if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
					Format(sText, sizeof(sText), "%T", sTank, i);
					PrintToChat(i, "%T", "tank spawn notification", i, orange, sText, white, blue);
				}
			}

			if (StrEqual(StateName, "hulk")) {
				SetSpeedMultiplierBase(client, fTankMovementSpeed_Hulk);
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 255, 0, 255);
			}
			else if (StrEqual(StateName, "death")) {

				//ClearArray(Handle:TankState_Array[client]);	// you who walks through the valley of death loses everything.
				SetSpeedMultiplierBase(client, fTankMovementSpeed_Death);
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 0, 0, 255);
			}
			else if (StrEqual(StateName, "burn")) {
				SetSpeedMultiplierBase(client, fTankMovementSpeed_Burning);
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 255, 0, 0, 200);
			}
			else if (StrEqual(StateName, "teleporter")) {

				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 50, 50, 255, 200);

				if (b_IsActiveRound) FindRandomSurvivorClient(client, true);
			}
		}
		return 2;
	}
	return -2;
}

stock int FindClientOnSurvivorTeam() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		return i;
	}
	return 0;
}

stock void FindRandomSurvivorClient(int client, bool bIsTeleportTo = false, bool bPrioritizeTanks = true) {

	if (!IsLegitimateClientAlive(client) || !b_IsActiveRound) return;

	ClearArray(RandomSurvivorClient);
	//char ClassRoles[64];
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (client == i) continue;
			PushArrayCell(RandomSurvivorClient, i);
		}
	}
	if (bPrioritizeTanks && GetArraySize(RandomSurvivorClient) < 1) {

		//if (TotalHumanSurvivors() >= 4)
		FindRandomSurvivorClient(client, bIsTeleportTo, false);	// now all clients are viable.
		return;
	}
	int size = GetArraySize(RandomSurvivorClient);
	if (size < 1) return;

	int target = GetRandomInt(1, size);
	target = GetArrayCell(RandomSurvivorClient, target - 1);

	float Origin[3];
	GetClientAbsOrigin(target, Origin);
	/*char text[64];
	GetClientAimTargetEx(target, text, sizeof(text));

	char aimtarget[3][64];
	ExplodeString(text, " ", aimtarget, 3, 64);

	new Float:Origin[3];
	Origin[0] = StringToFloat(aimtarget[0]);
	Origin[1] = StringToFloat(aimtarget[1]);
	Origin[2] = StringToFloat(aimtarget[2]);*/
	TeleportEntity(client, Origin, NULL_VECTOR, NULL_VECTOR);
	/*if (GetClientTeam(client) == TEAM_SURVIVOR && bRushingNotified[client]) {

		bRushingNotified[client] = false;
	}*/
	if (GetClientTeam(client) == TEAM_INFECTED) bHasTeleported[client] = true;
}

/*bool:AnySurvivorInRange(client, Float:Range) {

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i)) continue;
		if (IsClientInRange(client, i, Range)) return true;
	}
	return false;
}*/

stock CheckTankSubroutine(tank, survivor = 0, damage = 0, bool TankIsVictim = false) {

	if (iRPGMode == -1) return;
	if (!IsLegitimateClientAlive(tank) || FindZombieClass(tank) != ZOMBIECLASS_TANK) return;	

	//if (IsSurvivalMode) return;

	int DeathState		= ChangeTankState(tank, "death", _, true);

	if (DeathState != 1 && (IsSpecialCommonInRange(tank, 'w') || IsClientInRangeSpecialAmmo(tank, "W") > 0.0)) {

		//ChangeTankState(client, "hulk", true);
		ChangeTankState(tank, "death");
	}
	int tankFlags = GetEntityFlags(tank);

	//if (survivor == 0 && damage == 0 && !(GetEntityFlags(tank) & FL_ONFIRE) && !SurvivorsInRange(tank)) ChangeTankState(tank, "teleporter");

	//new TankEnrageMechanic			= GetConfigValueInt("boss tank enrage count?");
	//new Float:TankTeleportMechanic	= GetConfigValueFloat("boss tank teleport distance?");

	if (tankFlags & FL_INWATER) {

		ChangeTankState(tank, "burn", true);
	}
	//bool IsDeath = false;

	//new DeathState		= ChangeTankState(tank, "death", _, true);
	int BurnState		= ChangeTankState(tank, "burn", _, true);
	//bool IsOnFire = false;
	if ((tankFlags & FL_ONFIRE) && BurnState != 1) {

		ExtinguishEntity(tank);
	}
	bool IsBiled	= IsCoveredInBile(tank);
	int IsHulkState		= ChangeTankState(tank, "hulk", _, true);

	if (bIsDefenderTank[tank] || DeathState == 1) {
		SetSpeedMultiplierBase(tank, fTankMovementSpeed_Death);
		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		if (bIsDefenderTank[tank]) SetEntityRenderColor(tank, 0, 0, 255, 255);
		else SetEntityRenderColor(tank, 0, 0, 0, 150);
	}
	else if (IsHulkState == 1) {
		SetSpeedMultiplierBase(tank, fTankMovementSpeed_Hulk);

		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(tank, 0, 255, 0, 200);
	}
	else if (BurnState == 1) {

		SetSpeedMultiplierBase(tank, fTankMovementSpeed_Burning);

		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(tank, 255, 0, 0, 200);
		if (!(tankFlags & FL_ONFIRE)) IgniteEntity(tank, 3.0);
	}
	if (BurnState != 1) ExtinguishEntity(tank);
	/*if (BurnState) {

		SetSpeedMultiplierBase(tank, 1.0);
		ChangeTankState(tank, "hulk", true);
		IsHulkState = 0;
		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(tank, 255, 0, 0, 255);
	}*/
	bool IsLegitimateClientSurvivor = IsLegitimateClient(survivor);
	int survivorTeam = -1;
	if (IsLegitimateClientSurvivor) survivorTeam = GetClientTeam(survivor);
	if (survivor == 0 || !IsLegitimateClientSurvivor || survivorTeam != TEAM_SURVIVOR) return;

	//char ClassRoles[64];

	//new Float:IsSurvivorWeak = IsClientInRangeSpecialAmmo(survivor, "W");
	//new Float:IsSurvivorReflect = 0.0;
	bool IsSurvivorBiled = false;
	if (!TankIsVictim) {

		if (BurnState == 1) {

			int Count = GetClientStatusEffect(survivor, "burn");

			if (!IsSurvivorBiled && Count < iDebuffLimit) {

				//if (IsSurvivorReflect) CreateAndAttachFlame(tank, RoundToCeil(damage * 0.1), 10.0, 1.0, survivor, "burn");
				//else
				if (Count == 0) Count = 1;
				CreateAndAttachFlame(survivor, RoundToCeil((damage * fBurnPercentage) / Count), 10.0, 0.5, tank, "burn");
			}
		}
		if (DeathState == 0) ChangeTankState(tank, "hulk");
		else if (IsHulkState == 1) ChangeTankState(tank, "death");
		else if (DeathState == 1) {

			int SurvivorHealth = GetClientTotalHealth(survivor);

			int SurvivorHalfHealth = SurvivorHealth / 2;
			if (SurvivorHalfHealth / GetMaximumHealth(survivor) > 0.25) {

				SetClientTotalHealth(tank, survivor, SurvivorHalfHealth);
				AddSpecialInfectedDamage(survivor, tank, SurvivorHalfHealth, true);
			}
		}
		else if (IsHulkState == 1) {

			CreateExplosion(survivor, damage, tank, true);
		}
	}
	else {

		if (IsBiled) {

			if (BurnState == 1) ChangeTankState(tank, "hulk");
			if (!ISBILED[survivor]) {
				SDKCall(g_hCallVomitOnPlayer, survivor, tank, true);
				CreateTimer(15.0, Timer_RemoveBileStatus, survivor, TIMER_FLAG_NO_MAPCHANGE);
				ISBILED[survivor] = true;
			}
		}
	}
}

public Action Hook_SetTransmit(entity, client) {
	
	if(EntIndexToEntRef(entity) == eBackpack[client]) return Plugin_Handled;
	return Plugin_Continue;
}

// returning plugin stop in here actually prevents you from switching weapons... great for if fatigued.
public Action OnWeaponSwitch(client, weapon) {
	if (b_IsActiveRound && IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) CreateTimer(0.1, Timer_SetMyWeapons, client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action Timer_SetMyWeapons(Handle timer, any client) {
	SetMyWeapons(client);
	return Plugin_Stop;
}

public Action OnTraceAttack(victim, &attacker, &inflictor, float &damage, &damagetype, &ammotype, hitbox, hitgroup) {
	if (IsLegitimateClient(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR) {
		takeDamageEvent[attacker][0] = ammotype;
		takeDamageEvent[attacker][1] = hitgroup;
	}
	return Plugin_Continue;
}

/*
// requests
// 1 - common health, 2 common damage
// 3 witch health, 4 witch damage
// 5 special health, 6 special damage
stock GetCharacterSheetData(client, char[] stringRef, theSize, request, zombieclass = 0)
*/

/*
 *	SDKHooks function.
 *	We're using it to prevent any melee damage, due to the bizarre way that melee damage is handled, it's hit or miss whether it is changed.
 *	@return Plugin_Changed		if a melee weapon was used.
 *	@return Plugin_Continue		if a melee weapon was not used.
 */
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage_ignore, int &damagetype) {
	if (!b_IsActiveRound || b_IsSurvivalIntermission) {

		damage_ignore = 0.0;
		return Plugin_Handled;
	}
	/*if (IsCommonInfected(victim) && !IsSpecialCommon(victim)) {
		damage_ignore = 9999.0;
		return Plugin_Changed;
	}*/
	int survivorIncomingDamage = RoundToCeil(damage_ignore);
	float damage = damage_ignore;
	if (damage <= 0.0) {
		damage_ignore = 0.0;
		return Plugin_Handled;
		/* So survivor bots will now damage jimmy gibbs and riot police as if they were not uncommon infected.
		// If we don't do this, the bots don't understand that the weapons that the uncommons are immune to, and if they are in
		// possession of said weapon, will just shoot the bots indefinitely.
		if (!IsSurvivorBot(attacker)) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}*/
	}
	char stringRef[64];
	float ammoStr = 0.0;
	bool bIsEnrageActive = IsEnrageActive();
	int baseWeaponDamage = 0;
	int loadtarget = -1;
	float TheAbilityMultiplier = 0.0;
	int cTank = -1;
	bool IsSurvivorBotVictim = IsLegitimateClient(victim) && IsFakeClient(victim) && GetClientTeam(victim) == TEAM_SURVIVOR;
	bool IsSurvivorBotAttacker = IsLegitimateClient(attacker) && IsFakeClient(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR;

 	int ReflectIncomingDamage = 0;
	int theCount = LivingSurvivorCount();
	/*
		Code for LEGITIMATE attackers goes here.
		This only handles survivors and special infected attackers; witches, commons, and super attackers are at the bottom of this method.
	*/
	bool IsLegitimateClientVictim = IsLegitimateClient(victim);
	int victimTeam = -1;
	bool IsFakeClientVictim;
	if (IsLegitimateClientVictim) {
		victimTeam = GetClientTeam(victim);
		IsFakeClientVictim = IsFakeClient(victim);
		if (ImmuneToAllDamage[victim]) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
	}
	bool IsLegitimateClientAttacker = IsLegitimateClient(attacker);
	//if (IsLegitimateClientAttacker && GetClientTeam(attacker) == TEAM_SURVIVOR) PrintToChatAll("%N attacked!", attacker);
	int attackerTeam = -1;
	bool IsFakeClientAttacker;
	if (IsLegitimateClientAttacker) {
		attackerTeam = GetClientTeam(attacker);
		IsFakeClientAttacker = IsFakeClient(attacker);
		if (attackerTeam == TEAM_INFECTED && (IsWitch(victim) || IsLegitimateClientVictim && attackerTeam == victimTeam)) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
	}
	int victimType = -1;
	int attackerType = -1;
	int survivorAmmotype = -1;
	int survivorHitgroup = -1;
	if (IsLegitimateClientAttacker) {
		if (attackerTeam == TEAM_SURVIVOR || !IsFakeClientAttacker) {
			if (b_IsLoading[attacker]) {	// infected bots shouldn't hold up here anymore.
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			else if (!IsFakeClientAttacker && SkyLevel[attacker] < 1 && PlayerLevel[attacker] < iPlayerStartingLevel || (IsFakeClientAttacker || IsSurvivorBotAttacker) && PlayerLevel[attacker] < iBotPlayerStartingLevel) {
				loadtarget = attacker;
				ForceLoadDefaultProfiles(loadtarget);
			}
		}
		b_IsDead[attacker] = false;
		LastAttackTime[attacker] = GetEngineTime();
		if (!HasSeenCombat[attacker]) HasSeenCombat[attacker] = true;
		if (attackerTeam == TEAM_SURVIVOR) {
			survivorAmmotype = takeDamageEvent[attacker][0];
			survivorHitgroup = takeDamageEvent[attacker][1];
			if (inflictor > MaxClients && ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_NERVEGAS))) {
				char classname[64];
				GetEdictClassname(inflictor, classname, sizeof(classname));
				if (StrContains(classname, "pipe_bomb") == -1) baseWeaponDamage = iExplosionBaseDamage;
				else baseWeaponDamage = iExplosionBaseDamagePipe;
				baseWeaponDamage += RoundToCeil(GetAbilityStrengthByTrigger(attacker, victim, "S", _, baseWeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
				GetAbilityStrengthByTrigger(attacker, victim, "explosion", _, baseWeaponDamage, _, _, _, _, _, _, _, _, damagetype, _, _, survivorHitgroup);
			}
			else baseWeaponDamage = GetBaseWeaponDamage(attacker, victim, _, _, _, damagetype, _, _, survivorHitgroup);

			if (bAutoRevive[attacker] && !IsIncapacitated(attacker)) bAutoRevive[attacker] = false;
			victimType = (IsSpecialCommon(victim)) ? 0 :
							   (IsCommonInfected(victim)) ? 1 :
							   (IsWitch(victim)) ? 2 :
							   (IsLegitimateClientVictim && victimTeam != TEAM_SURVIVOR) ? 3 :
							   (IsLegitimateClientVictim && victimTeam == TEAM_SURVIVOR) ? 4 : 5;
			
			
			CallTriggerByHitgroup(attacker, victim, survivorHitgroup, survivorAmmotype, baseWeaponDamage);

			int survivorResult = IfSurvivorIsAttackerDoStuff(attacker, victim, baseWeaponDamage, damagetype, victimType, survivorAmmotype, survivorHitgroup, inflictor);
			if (survivorResult == -1) {
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			ReadyUp_NtvStatistics(attacker, 0, baseWeaponDamage);
			ReadyUp_NtvStatistics(victim, 8, baseWeaponDamage);
			if (survivorResult == -2) {
				damage_ignore = (baseWeaponDamage * 1.0);
				return Plugin_Changed;
			}
		}
		else if (attackerTeam == TEAM_INFECTED) {
			if (bIsEnrageActive) damage *= fEnrageModifier;
			if (FindZombieClass(attacker) == ZOMBIECLASS_TANK) cTank = attacker;
		}
	}
	if (IsLegitimateClientVictim) {
		if (b_IsLoading[victim]) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
		else if (!IsFakeClientVictim && SkyLevel[victim] < 1 && PlayerLevel[victim] < iPlayerStartingLevel || (IsFakeClientVictim || IsSurvivorBotVictim) && PlayerLevel[victim] < iBotPlayerStartingLevel) {
			loadtarget = victim;
			ForceLoadDefaultProfiles(loadtarget);
		}
		b_IsDead[victim] = false;
		if (RespawnImmunity[victim]) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
		LastAttackTime[victim] = GetEngineTime();
		if (!HasSeenCombat[victim]) HasSeenCombat[victim] = true;
		if ((damagetype & DMG_CRUSH)) {
			if (bIsCrushCooldown[victim]) {
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			else {
				bIsCrushCooldown[victim] = true;
				CreateTimer(1.0, Timer_ResetCrushImmunity, victim, TIMER_FLAG_NO_MAPCHANGE);

				char crushedName[64];
				GetClientName(victim, crushedName, sizeof(crushedName));

				int crushDamage = RoundToCeil(damage_ignore);
				TheAbilityMultiplier = GetAbilityMultiplier(victim, "F");
				if (TheAbilityMultiplier > 0.0) crushDamage -= RoundToCeil(crushDamage * TheAbilityMultiplier);
				SetClientTotalHealth(attacker, victim, crushDamage, _, true);
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
		}
		if (victimTeam == TEAM_SURVIVOR) {
			/*	==============================================================================================
				A quick check to see if survivor bots are immune to fire damage, since bots are dumb
				==============================================================================================*/
			if (IsSurvivorBotVictim && iSurvivorBotsAreImmuneToFireDamage == 1 && (damagetype & DMG_BURN)) {
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			/*	==============================================================================================
				We need to calculate the attackers damage before we calculate the victims damage taken.
				==============================================================================================*/
			bool isCommonInfectedAttacker = IsCommonInfected(attacker);
			attackerType = (isCommonInfectedAttacker) ? 1 :
							   (IsWitch(attacker)) ? 2 :
							   (IsLegitimateClientAttacker && attackerTeam == TEAM_INFECTED) ? 3 :
							   (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR) ? 4 : 5;
			if (attackerType <= 3) {
				CombatTime[victim] = GetEngineTime() + fOutOfCombatTime;
				JetpackRecoveryTime[victim] = GetEngineTime() + 1.0;
				ToggleJetpack(victim, true);
				if (attackerType == 3) {
					survivorIncomingDamage = IfInfectedIsAttackerDoStuff(attacker, victim);
					ReadyUp_NtvStatistics(attacker, 1, survivorIncomingDamage);
					ReadyUp_NtvStatistics(victim, 8, survivorIncomingDamage);
					if (survivorIncomingDamage == -1) {
						damage_ignore = 0.0;
						return Plugin_Handled;
					}
				}
				else if (attackerType == 2) {
					int i_WitchDamage = GetCharacterSheetData(victim, stringRef, 64, 4, _, attacker);
					if (IsSpecialCommonInRange(attacker, 'b')) i_WitchDamage *= 2;//i_WitchDamage += GetSpecialCommonDamage(i_WitchDamage, attacker, 'b', victim);
					SetClientTotalHealth(attacker, victim, i_WitchDamage);
					ReceiveWitchDamage(victim, attacker, i_WitchDamage);
					float fDirectorPointAward = (fWitchDirectorPoints * i_WitchDamage);
					if (!IsSurvivalMode && RPGRoundTime() >= iEnrageTime) fDirectorPointAward *= fEnrageDirectorPoints;
					if (fDirectorPointAward > 0.0) Points_Director += fDirectorPointAward;
					// Reflect damage.
					ammoStr = IsClientInRangeSpecialAmmo(victim, "R", _, _, i_WitchDamage);
					if (ammoStr > 0.0) ReflectIncomingDamage = RoundToCeil(i_WitchDamage * ammoStr);
					if (ReflectIncomingDamage > 0) AddWitchDamage(victim, attacker, ReflectIncomingDamage, _, _, survivorAmmotype, survivorHitgroup);
					survivorIncomingDamage = i_WitchDamage;
				}
				else if (isCommonInfectedAttacker) {
					survivorIncomingDamage = IfCommonInfectedIsAttackerDoStuff(attacker, victim, damagetype, theCount);
					if (survivorIncomingDamage == -1) {
						damage_ignore = 0.0;
						return Plugin_Handled;
					}
				}
			}
			/*	============================================================
				We can now calculate the damage the victim will take.
				============================================================*/
			if (!IsSurvivorBotVictim || iCanSurvivorBotsBurn == 1) {
				char effectToCreate[10];
				if ((damagetype & DMG_BURN) && !DebuffOnCooldown(victim, "burn")) Format(effectToCreate, sizeof(effectToCreate), "burn");
				else if ((damagetype & DMG_SPITTERACID1 || damagetype & DMG_SPITTERACID2) && !DebuffOnCooldown(victim, "acid")) Format(effectToCreate, sizeof(effectToCreate), "acid");
				else Format(effectToCreate, sizeof(effectToCreate), "-1");

				if (!StrEqual(effectToCreate, "-1")) {
					int iBurnCounter = GetClientStatusEffect(victim, effectToCreate);
					if (iBurnCounter < iDebuffLimit && fOnFireDebuff[victim] <= 0.0) {

						if (fOnFireDebuff[victim] == -1.0) {

							ExtinguishEntity(victim);
							fOnFireDebuff[victim] = 0.0;
						}
						else {

							fOnFireDebuff[victim] = fOnFireDebuffDelay;
							PushArrayString(Handle:ApplyDebuffCooldowns[victim], effectToCreate);
							if (iRPGMode >= 1) {
								float fAcidDamage = (attackerType == 1) ? fAcidDamageSupersPlayerLevel : fAcidDamagePlayerLevel;
								if (iBotLevelType == 1) {
									if (StrEqual(effectToCreate, "acid")) survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (SurvivorLevels() * fAcidDamage));
									else survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (SurvivorLevels() * fBurnPercentage));
								}
								else {
									if (StrEqual(effectToCreate, "acid")) survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (GetDifficultyRating(victim) * fAcidDamage));
									else survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (GetDifficultyRating(victim) * fBurnPercentage));
								}
							}
							//PrintToChatAll("DoT Damage: %d %d", survivorIncomingDamage, survivorIncomingDamage * (iBurnCounter + 1));
							CreateAndAttachFlame(victim, survivorIncomingDamage * (iBurnCounter + 1), 10.0, 0.5, FindInfectedClient(true), effectToCreate);
						}
					}
					damage_ignore = 0.0;
					return Plugin_Handled;
				}
			}
			if (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR) {
				if (SameTeam_OnTakeDamage(attacker, victim, baseWeaponDamage, _, damagetype, survivorHitgroup)) {
					damage_ignore = 0.0;
					return Plugin_Handled;
				}
			}
			if (damagetype & DMG_FALL) {
				int DMGFallDamage = RoundToCeil(damage_ignore);
				int MyInfectedAttacker = L4D2_GetInfectedAttacker(victim);
				if (MyInfectedAttacker != -1) DMGFallDamage = RoundToCeil(DMGFallDamage * 0.4);
				TheAbilityMultiplier = GetAbilityMultiplier(victim, "F");
				if (TheAbilityMultiplier > 0.0) DMGFallDamage -= RoundToCeil(DMGFallDamage * TheAbilityMultiplier);
				if (DMGFallDamage < 100) {
					DMGFallDamage = RoundToCeil((damage_ignore * 0.01) * GetMaximumHealth(victim));
					SetClientTotalHealth(_, victim, DMGFallDamage, _, true);
				}
				else if (DMGFallDamage >= 100 && DMGFallDamage < 200) SetClientTotalHealth(_, victim, GetClientTotalHealth(victim), _, true);
				else IncapacitateOrKill(victim, _, _, true);
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			if (damagetype & DMG_DROWN) {
				if (!IsIncapacitated(victim)) SetClientTotalHealth(_, victim, GetClientTotalHealth(victim));
				else IncapacitateOrKill(victim, _, _, true);
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
		}
		else {	// infected victim.
			if (FindZombieClass(victim) == ZOMBIECLASS_TANK) cTank = victim;
		}
	}
	if (cTank > 0) {
		if (!bIsDefenderTank[cTank] && IsSpecialCommonInRange(cTank, 't')) {
			// tank copies nearby defender abilities, permanently.
			bIsDefenderTank[cTank] = true;
			SetEntityRenderMode(cTank, RENDER_TRANSCOLOR);
			SetEntityRenderColor(cTank, 0, 0, 255, 200);
		}
	}
	
 	//new StaminaCost = 0;
 	//new baseWeaponTemp = 0;
	// IgnoreTeam = 1 when the attacker is survivor.
	// IgnoreTeam = 2 when the attacker is infected.
	// IgnoreTeam = 3 when the victim is infected.
	// IgnoreTeam = 4 when the victim is common/witch
	// IgnoreTeam = 5 when the attacker is common/witch
	//damage_ignore = 0.0;
	//return Plugin_Handled;

	damage_ignore = baseWeaponDamage * 1.0;
	/*if (victimType == 3 && victimTeam == TEAM_INFECTED ||
		victimType == 1 && FindListPositionByEntity(victim, Handle:CommonInfected) >= 0 ||
		victimType == 2 && FindListPositionByEntity(victim, Handle:WitchList) >= 0) {*/
	if (victimType <= 2) {
		damage_ignore = 0.0;
		if (victimType == 2 && !WitchShot(victim)) {
			SetEntProp(victim, Prop_Send, "m_mobRush", 1);
			damage_ignore = 1.0;
			return Plugin_Changed;
		}
		return Plugin_Handled;
	}
	if (victimType == 3) {
		//if (victimType != 1 || IsSpecialCommon(victim) || !IsCommonInfectedDead(victim)) SetInfectedHealth(victim, 50000);	// we don't want NPC zombies to die prematurely.
		return Plugin_Changed;
	}
	if (IsLegitimateClientVictim && victimTeam == TEAM_SURVIVOR) {
		damage_ignore = survivorIncomingDamage * 1.0;
		return Plugin_Changed;
	}
	return Plugin_Changed;
}

bool WitchShot(int client, bool destroy = false) {
	int size = GetArraySize(ListOfWitchesWhoHaveBeenShot);
	for (int i = 0; i < size; i++) {
		int c = GetArrayCell(ListOfWitchesWhoHaveBeenShot, i);
		if (client != c) continue;
		if (destroy) RemoveFromArray(ListOfWitchesWhoHaveBeenShot, i);
		return true;
	}
	PushArrayCell(ListOfWitchesWhoHaveBeenShot, client);
	return false;
}

/*
 *
 * IfCommonInfectedIsAttackerDoStuff(attacker, victim, damagetype, survivorCount)
 * 
 */
stock int IfCommonInfectedIsAttackerDoStuff(attacker, victim, damagetype, survivorCount) {
	char stringRef[64];
	int CommonsDamage = GetCharacterSheetData(victim, stringRef, 64, 2, _, attacker);//GetInfectedData(victim, attacker, true);
	float ammoStr = 0.0;
	if (IsSpecialCommonInRange(attacker, 'b')) CommonsDamage *= 2;//CommonsDamage += GetSpecialCommonDamage(CommonsDamage, attacker, 'b', victim);
	if (!(damagetype & DMG_DIRECT)) {
		if (b_IsJumping[victim]) ModifyGravity(victim);
		float fCommonDirectorAward = (fCommonDirectorPoints * CommonsDamage);
		if (!IsSurvivalMode && RPGRoundTime() >= iEnrageTime) fCommonDirectorAward *= fEnrageDirectorPoints;
		if (fCommonDirectorAward > 0.0) Points_Director += fCommonDirectorAward;
		GetAbilityStrengthByTrigger(victim, attacker, "Y", _, CommonsDamage);
		SetClientTotalHealth(attacker, victim, CommonsDamage);
		ReceiveCommonDamage(victim, attacker, CommonsDamage);
	}
	char TheCommonValue[64];
	bool attackerIsSpecial = IsSpecialCommon(attacker);
	if (attackerIsSpecial) {
		char slevelrequired[10];
		GetCommonValueAtPos(slevelrequired, sizeof(slevelrequired), attacker, SUPER_COMMON_LEVEL_REQ);
		if (PlayerLevel[victim] >= StringToInt(slevelrequired)) {
			GetCommonValueAtPos(TheCommonValue, sizeof(TheCommonValue), attacker, SUPER_COMMON_AURA_EFFECT);

			// Flamers explode when they receive or take damage.
			if (StrEqual(TheCommonValue, "f", true)) CreateDamageStatusEffect(attacker, _, victim, CommonsDamage);
			else if (StrEqual(TheCommonValue, "a", true)) CreateBomberExplosion(attacker, victim, TheCommonValue, CommonsDamage);
			else if (StrEqual(TheCommonValue, "E", true)) {
				char deatheffectshappen[10];
				GetCommonValueAtPos(deatheffectshappen, sizeof(deatheffectshappen), attacker, SUPER_COMMON_DEATH_EFFECT);
				CreateDamageStatusEffect(attacker, _, victim, CommonsDamage);
				CreateBomberExplosion(attacker, victim, deatheffectshappen);
				ClearSpecialCommon(attacker, _, CommonsDamage, victim);
			}
		}
	}
	int BuffDamage = 0;
	ammoStr = IsClientInRangeSpecialAmmo(victim, "R", _, _, CommonsDamage);
	if (ammoStr > 0.0) BuffDamage = RoundToCeil(CommonsDamage * ammoStr);
	if (BuffDamage > 0) {
		if (!attackerIsSpecial) AddCommonInfectedDamage(victim, attacker, BuffDamage);
		else {
			GetCommonValueAtPos(TheCommonValue, sizeof(TheCommonValue), attacker, SUPER_COMMON_AURA_EFFECT);
			if (!StrEqual(TheCommonValue, "d", true)) AddSpecialCommonDamage(victim, attacker, BuffDamage);
			else {	// if a player tries to reflect damage at a reflector, it's moot (ie reflects back to the player) so in this case the player takes double damage, though that's after mitigations.
				SetClientTotalHealth(attacker, victim, BuffDamage);
				ReceiveCommonDamage(victim, attacker, BuffDamage);
			}
		}
	}
	if (IsSpecialCommonInRange(attacker, 'f')) DoBurn(attacker, victim, CommonsDamage);
	int damageToReturn = (BuffDamage > 0) ? BuffDamage : CommonsDamage;
	TankingContribution[victim] += RoundToCeil(damageToReturn * SurvivorExperienceMultTank);
	return damageToReturn;
}

stock int IfInfectedIsAttackerDoStuff(attacker, victim) {
	CombatTime[victim] = GetEngineTime() + fOutOfCombatTime;
	if (b_IsJumping[victim]) ModifyGravity(victim);
	int infectedZombieClass = FindZombieClass(attacker);
	char stringRef[64];
	int totalIncomingDamage = GetCharacterSheetData(victim, stringRef, 64, 6, infectedZombieClass, attacker);//GetInfectedData(victim, attacker, true);
	if (IsSpecialCommonInRange(attacker, 'b')) totalIncomingDamage *= 2; //totalIncomingDamage += GetSpecialCommonDamage(totalIncomingDamage, attacker, 'b', victim);
	if (totalIncomingDamage < 0) totalIncomingDamage = 0;
	SetClientTotalHealth(attacker, victim, totalIncomingDamage);
	AddSpecialInfectedDamage(victim, attacker, totalIncomingDamage, true);	// bool is tanking instead.
	if (infectedZombieClass == ZOMBIECLASS_TANK) CheckTankSubroutine(attacker, victim, totalIncomingDamage);
	if (IsFakeClient(attacker)) {
		DamageContribution[attacker] += totalIncomingDamage;
	}
	bool bIsInfectedSwarm = false;
	char weapon[64];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if (StrEqual(weapon, "insect_swarm")) bIsInfectedSwarm = true;
	int grabbedVictim = L4D2_GetSurvivorVictim(attacker);
	if (grabbedVictim != -1 && IsFakeClient(attacker)) GetAbilityStrengthByTrigger(attacker, grabbedVictim, "v", _, totalIncomingDamage);
	if (grabbedVictim == -1) GetAbilityStrengthByTrigger(attacker, victim, "claw", _, totalIncomingDamage);
	if (bIsInfectedSwarm) GetAbilityStrengthByTrigger(attacker, victim, "T", _, totalIncomingDamage);
	GetAbilityStrengthByTrigger(attacker, victim, "D", _, totalIncomingDamage);
	int ensnarer = L4D2_GetInfectedAttacker(victim);
	if (ensnarer == attacker) GetAbilityStrengthByTrigger(victim, attacker, "s", _, totalIncomingDamage);
	// If the infected player dealing the damage isn't the player hurting the victim, we give the victim a chance to strike at both! This is balance!
	if (attacker != ensnarer) GetAbilityStrengthByTrigger(victim, attacker, "V", _, totalIncomingDamage);
	if (ensnarer != -1) GetAbilityStrengthByTrigger(victim, ensnarer, "V", _, totalIncomingDamage);
	// TheAbilityMultiplier = GetAbilityStrengthByTrigger(victim, attacker, "lessTankyMoreHeals", _, totalIncomingDamage, _, _, "o", 2, true);
	// if (TheAbilityMultiplier > 0.0) totalIncomingDamage += RoundToCeil(totalIncomingDamage * TheAbilityMultiplier);
	int ReflectIncomingDamage = 0;
	float ammoStr = IsClientInRangeSpecialAmmo(victim, "R", _, _, totalIncomingDamage);
	if (!bIsInfectedSwarm && ammoStr > 0.0) ReflectIncomingDamage = RoundToCeil(totalIncomingDamage * ammoStr);
	if (ReflectIncomingDamage > 0) AddSpecialInfectedDamage(victim, attacker, ReflectIncomingDamage);
	if (IsSpecialCommonInRange(attacker, 'f')) DoBurn(attacker, victim, totalIncomingDamage);
	return totalIncomingDamage;
}

stock int IfSurvivorIsAttackerDoStuff(attacker, victim, baseWeaponDamage, damagetype, victimType, ammotype = -1, hitgroup = -1, int inflictor = -1) {
						// 0 super, 1 common, 2 witch
	//if (bIsMeleeCooldown[attacker] && (StrContains(MyCurrentWeapon[attacker], "melee", false) != -1 || StrContains(MyCurrentWeapon[attacker], "chainsaw", false) != -1)) return -1;

	LastWeaponDamage[attacker] = baseWeaponDamage;
	if (iDisplayHealthBars == 1) DisplayInfectedHealthBars(attacker, victim);
	if (victimType <= 4) {
		if (LastAttackedUser[attacker] == victim) ConsecutiveHits[attacker]++;
		else {
			LastAttackedUser[attacker] = victim;
			ConsecutiveHits[attacker] = 0;
		}
	}
	if (victimType <= 2) return TryToDamageNonPlayerInfected(attacker, victim, baseWeaponDamage, damagetype, ammotype, hitgroup);
	else if (victimType == 3) {
		if (TryToDamagePlayerInfected(attacker, victim, baseWeaponDamage, damagetype, ammotype, hitgroup) == -1) return -1;
		if (IsSpecialCommonInRange(attacker, 'd') && (damagetype & DMG_BULLET)) {
			SetClientTotalHealth(victim, attacker, baseWeaponDamage);
		}
	}
	return 0;
}

stock int TryToDamagePlayerInfected(attacker, victim, baseWeaponDamage, damagetype, ammotype = -1, hitgroup = -1) {
	//if (!IsLegitimateClient(victim) || GetClientTeam(victim) != TEAM_INFECTED) return 0;
	//Checks if a Common Defender or a Defender Tank is in range if the 2nd arg isn't left blank
	if (!IsFakeClient(attacker) && (IsSpecialCommonInRange(victim, 't') || DrawSpecialInfectedAffixes(victim, victim) == 1)) {
		// If a Defender is within range, the entity is immune.
		// If the entity is a tyrant, it's also immune.
		return -1;
	}
	if (L4D2_GetSurvivorVictim(victim) != -1) GetAbilityStrengthByTrigger(victim, attacker, "t", _, baseWeaponDamage, _, _, _, _, _, _, hitgroup, _, damagetype);
	bool bIsMeleeAttack = hasMeleeWeaponEquipped[attacker];
	int zombieclass = FindZombieClass(victim);
	if (((damagetype & DMG_BURN) && iIsSpecialFire != 1 || (!bIsMeleeAttack && zombieclass == ZOMBIECLASS_TANK && TankState[victim] == TANKSTATE_DEATH)) && IsPlayerAlive(victim)) return -1;
	if ((damagetype & DMG_BURN) && zombieclass == ZOMBIECLASS_TANK && TankState[victim] == TANKSTATE_FIRE) return -1;
	//if (StrContains(weapon, "molotov", false) != -1) return -1;// || !IsPlayerAlive(victim) || RestrictedWeaponList(weapon)) return -1;
	// if (!bIsMeleeCooldown[attacker] && bIsMeleeAttack) {
	// 	bIsMeleeCooldown[attacker] = true;
	// 	CreateTimer(0.1, Timer_IsMeleeCooldown, attacker, TIMER_FLAG_NO_MAPCHANGE);
	// }
	//if (AllowShotgunToTriggerNodes(attacker)) {
	GetAbilityStrengthByTrigger(attacker, victim, "D", _, baseWeaponDamage, _, _, _, _, _, _, hitgroup, _, damagetype);
	GetAbilityStrengthByTrigger(victim, attacker, "L", _, baseWeaponDamage, _, _, _, _, _, _, hitgroup, _, damagetype);
		
	if (zombieclass == ZOMBIECLASS_TANK) CheckTankSubroutine(victim, attacker, baseWeaponDamage, true);
	//}
	AddSpecialInfectedDamage(attacker, victim, baseWeaponDamage, _, _, ammotype, hitgroup);
	//CombatTime[attacker] = GetEngineTime() + fOutOfCombatTime;
	return -1;
}

stock int TryToDamageNonPlayerInfected(attacker, victim, baseWeaponDamage, damagetype, ammotype = -1, hitgroup = -1) {
	//if (!IsWitch(victim) && !IsCommonInfected(victim)) return 0;
	//Checks if a Common Defender or a Defender Tank is in range if the 2nd arg isn't left blank
	if (IsSpecialCommonInRange(victim, 't') || DrawSpecialInfectedAffixes(victim, victim) == 1) {
		// If a Defender is within range, the entity is immune.
		// If the entity is a tyrant, it's also immune.
		return -1;
	}
	//bool isDifferentVictim = (LastAttackedUser[attacker] == victim) ? false : true;
	char TheCommonValue[10];
	bool isVictimSpecial = IsSpecialCommon(victim);
	// if (!bIsMeleeAttack || isDifferentVictim || !bIsMeleeCooldown[attacker]) {
	// 	bool allowshotgun = true;// AllowShotgunToTriggerNodes(attacker);
	// 	if (!bIsMeleeCooldown[attacker] && bIsMeleeAttack) {
	// 		bIsMeleeCooldown[attacker] = true;
	// 		CreateTimer(0.1, Timer_IsMeleeCooldown, attacker, TIMER_FLAG_NO_MAPCHANGE);
	// 	}
	// 	if (allowshotgun) {
	GetAbilityStrengthByTrigger(attacker, victim, "D", _, baseWeaponDamage, _, _, _, _, _, _, hitgroup, _, damagetype);
		//GetAbilityStrengthByTrigger(victim, attacker, "L", _, baseWeaponDamage, _, _, _, _, _, _, hitgroup, _, damagetype);
		//}
	if (IsWitch(victim)) {
		//if (FindListPositionByEntity(victim, Handle:WitchList) >= 0) {
		AddWitchDamage(attacker, victim, baseWeaponDamage, _, _, ammotype, hitgroup);
		//}
	}
	else if (isVictimSpecial) {
		if (AddSpecialCommonDamage(attacker, victim, baseWeaponDamage, _, _, ammotype, hitgroup) > 1) return baseWeaponDamage;
	}
	else if (IsCommonInfected(victim)) {
		if (AddCommonInfectedDamage(attacker, victim, baseWeaponDamage, _, damagetype, ammotype, hitgroup) > 1) return -2;
	}
	if (CheckTeammateDamages(victim, attacker) < 1.0) {
		if (isVictimSpecial) {
			GetCommonValueAtPos(TheCommonValue, sizeof(TheCommonValue), victim, SUPER_COMMON_DAMAGE_EFFECT);
			// The bomber explosion initially targets itself so that the chain-reaction (if enabled) doesn't go indefinitely.
			if (StrEqual(TheCommonValue, "f", true)) CreateDamageStatusEffect(victim, _, attacker, baseWeaponDamage);
			// Cannot trigger on survivor bots because they're frankly too stupid and it wouldn't be fair.
			else if (StrEqual(TheCommonValue, "d", true)) CreateDamageStatusEffect(victim, 3, attacker, baseWeaponDamage);		// attacker is not target but just used to pass for reference.
		}
	}
	//CombatTime[attacker] = GetEngineTime() + fOutOfCombatTime;
	//}
	return 1;
}

stock SpawnAnyInfected(client) {

	if (IsLegitimateClientAlive(client)) {

		char InfectedName[20];
		int rand = GetRandomInt(1,6);
		if (rand == 1) Format(InfectedName, sizeof(InfectedName), "smoker");
		else if (rand == 2) Format(InfectedName, sizeof(InfectedName), "boomer");
		else if (rand == 3) Format(InfectedName, sizeof(InfectedName), "hunter");
		else if (rand == 4) Format(InfectedName, sizeof(InfectedName), "spitter");
		else if (rand == 5) Format(InfectedName, sizeof(InfectedName), "jockey");
		else Format(InfectedName, sizeof(InfectedName), "charger");
		Format(InfectedName, sizeof(InfectedName), "%s auto", InfectedName);

		ExecCheatCommand(client, "z_spawn_old", InfectedName);
	}
}

stock GetInfectedCount(zombieclass = 0) {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED && (zombieclass == 0 || FindZombieClass(i) == zombieclass)) count++;
	}
	return count;
}

stock CreateMyHealthPool(client, bool IMeanDeleteItInstead = false) {

	int whatami = 3;
	if (IsSpecialCommon(client)) {
		whatami = 1;
		if (IMeanDeleteItInstead) {
			ForceClearSpecialCommon(client);
			return;
		}
	}
	else if (IsWitch(client)) whatami = 2;
	else if (IsCommonInfected(client)) return;

	/*if (IsLegitimateClientAlive(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && iTankRush == 1) {

		SetSpeedMultiplierBase(client, 1.0);
	}*/

	/*if (!b_IsFinaleActive && IsEnrageActive() && whatami == 3 && IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_INFECTED && FindZombieClass(client) == ZOMBIECLASS_TANK && !IsTyrantExist()) {

		IsTyrant[client] = true;
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 0, 255, 0, 255);
	}
	else*/
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		if (!IMeanDeleteItInstead) {
			if (!b_IsLoaded[i] || GetClientTeam(i) != TEAM_SURVIVOR) continue;
			if (whatami == 1) AddSpecialCommonDamage(i, client, -1);
			else if (whatami == 2) AddWitchDamage(i, client, -1);
			else if (whatami == 3) AddSpecialInfectedDamage(i, client, -1);
			continue;
		}
		if (whatami == 1) AddSpecialCommonDamage(i, client, -2);
		else if (whatami == 2) AddWitchDamage(i, client, -2);
		else if (whatami == 3) AddSpecialInfectedDamage(i, client, -2);
	}
	return;
}

stock EnsnaredInfected() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED && IsEnsnarer(i)) count++;
	}
	return count;
}

stock bool IsEnsnarer(client, class = 0) {

	int zombieclass = class;
	if (class == 0) zombieclass = FindZombieClass(client);
	if (zombieclass == ZOMBIECLASS_HUNTER ||
		zombieclass == ZOMBIECLASS_SMOKER ||
		zombieclass == ZOMBIECLASS_JOCKEY ||
		zombieclass == ZOMBIECLASS_CHARGER) return true;
	return false;
}

/*bool:HasInstanceGenerated(client, target) {
	if (FindListPositionByEntity(target, InfectedHealth[client]) >= 0) return true;
	return false;
}*/

stock InitInfectedHealthForSurvivors(client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		AddSpecialInfectedDamage(i, client, -1);
	}
}

bool hasTargetHurtClient(client, target, type = 0) {
	int pos = (type == 0) ? FindListPositionByEntity(target, InfectedHealth[client]) :
			  (type == 1) ? FindListPositionByEntity(target, WitchDamage[client]) : -1;
	if (pos < 0) return false;
	if (type == 0 && GetArrayCell(InfectedHealth[client], pos, 3) > 0 || type == 1 && GetArrayCell(WitchDamage[client], pos, 3) > 0) return true;
	return false;
}

stock AddSpecialInfectedDamage(client, target, TotalDamage = 0, bool IsTankingInstead = false, damagevariant = -1, ammotype = -1, hitgroup = -1) {
	int isEntityPos = FindListPositionByEntity(target, InfectedHealth[client]);
	//new f 0;
	if (isEntityPos >= 0 && TotalDamage <= -1) {
		// delete the mob.
		RemoveFromArray(InfectedHealth[client], isEntityPos);
		if (TotalDamage == -2) return 0;
		isEntityPos = -1;
	}
	int myzombieclass = FindZombieClass(target);
	if (myzombieclass < 1 || myzombieclass > 6 && myzombieclass != 8) return 0;
	if (isEntityPos < 0) {
		isEntityPos = GetArraySize(InfectedHealth[client]);
		ResizeArray(InfectedHealth[client], isEntityPos + 1);
		SetArrayCell(InfectedHealth[client], isEntityPos, target, 0);
		//An infected wasn't added on spawn to this player, so we add it now based on class.
		int t_InfectedHealth = (myzombieclass != ZOMBIECLASS_TANK) ? iBaseSpecialInfectedHealth[myzombieclass - 1] : iBaseSpecialInfectedHealth[myzombieclass - 2];
		OriginalHealth[target] = t_InfectedHealth;
		DefaultHealth[target] = t_InfectedHealth;
		GetAbilityStrengthByTrigger(target, _, "a", _, 0);
		//if (DefaultHealth[target] < OriginalHealth[target]) DefaultHealth[target] = OriginalHealth[target];
		char stringRef[64];
		SetArrayCell(InfectedHealth[client], isEntityPos, GetCharacterSheetData(client, stringRef, 64, 5, myzombieclass), 1);
		SetArrayCell(InfectedHealth[client], isEntityPos, 0, 2);
		SetArrayCell(InfectedHealth[client], isEntityPos, 0, 3);
		SetArrayCell(InfectedHealth[client], isEntityPos, 0, 4);
		// This slot is only for versus/human infected players; health remaining after "ARMOR" (global health) is gone.

		if (!bHealthIsSet[target]) {

			bHealthIsSet[target] = true;
			ResizeArray(InfectedHealth[target], GetArraySize(InfectedHealth[target]) + 1);
			SetArrayCell(InfectedHealth[target], 0, DefaultHealth[target], 5);
			SetArrayCell(InfectedHealth[target], 0, 0, 6);
			//SetArrayCell(Handle:InfectedHealth[client], isEntityPos, t_InfectedHealth, 5);
		}
	}
	if (TotalDamage < 1) return 0;

	int i_DamageBonus = TotalDamage;
	int i_InfectedMaxHealth = GetArrayCell(InfectedHealth[client], isEntityPos, 1);
	int i_InfectedCurrent = 0;
	if (!IsTankingInstead) i_InfectedCurrent = GetArrayCell(InfectedHealth[client], isEntityPos, 2);
	else i_InfectedCurrent = GetArrayCell(InfectedHealth[client], isEntityPos, 3);
	if (i_InfectedCurrent < 0) i_InfectedCurrent = 0;
	//if (i_DamageBonus > TrueHealthRemaining) i_DamageBonus = TrueHealthRemaining;

	if (!IsTankingInstead) {
		//int i_HealthRemaining = i_InfectedMaxHealth - i_InfectedCurrent;
		int i_HealthRemaining = RoundToCeil(i_InfectedMaxHealth * (1.0 - CheckTeammateDamages(target, client, _, true)));
		if (i_DamageBonus > i_HealthRemaining) i_DamageBonus = i_HealthRemaining;

		if (!IsFakeClient(client) && IsSpecialCommonInRange(target, 't')) return 0;
		if (damagevariant != 2 && i_DamageBonus > 0) {
			GetProficiencyData(client, GetWeaponProficiencyType(client), RoundToCeil(i_DamageBonus * fProficiencyExperienceEarned));

			SetArrayCell(InfectedHealth[client], isEntityPos, i_InfectedCurrent + i_DamageBonus, 2);
			//RoundDamageTotal += (i_DamageBonus);
			RoundDamage[client] += (i_DamageBonus);
		}
		else {

			SetArrayCell(InfectedHealth[client], isEntityPos, i_InfectedMaxHealth - i_DamageBonus, 1);	// lowers the total health pool if variant = 2 (bot damage)
		}
		SetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE) + i_DamageBonus);
	}
	else {
		i_InfectedCurrent += i_DamageBonus;
		SetArrayCell(InfectedHealth[client], isEntityPos, i_InfectedCurrent, 3);
		//SetArrayCell(Handle:playerContributionTracker[client], CONTRIBUTION_TRACKER_TANKING, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_TANKING) + i_DamageBonus);
	}
	ThreatCalculator(client, i_DamageBonus);
	CheckTeammateDamagesEx(client, target, i_DamageBonus, _, ammotype, hitgroup);
	return 0;
}

stock ThreatCalculator(client, iThreatAmount) {
	if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) {
		float TheAbilityMultiplier = GetAbilityMultiplier(client, "t");
		if (TheAbilityMultiplier != -1.0) {
			TheAbilityMultiplier *= (iThreatAmount * 1.0);
			iThreatLevel[client] += (iThreatAmount - RoundToFloor(TheAbilityMultiplier));
		}
		else {
			iThreatLevel[client] += iThreatAmount;
		}
	}
}

stock AddSpecialCommonDamage(client, entity, playerDamage, bool IsStatusDamage = false, damagevariant = -1, ammotype = -1, hitgroup = -1) {
	//if (!IsSpecialCommon(entity)) return 1;
	int pos		= FindListPositionByEntity(entity, CommonList);
	if (pos < 0 || !IsFakeClient(client) && IsSpecialCommonInRange(entity, 't')) return 1;
	int damageTotal = -1;
	int my_pos	= FindListPositionByEntity(entity, SpecialCommon[client]);
	if (my_pos >= 0 && playerDamage <= -1) {
		// delete the mob.
		ForceClearSpecialCommon(entity, client);
		//RemoveFromArray(SpecialCommon[client], my_pos);
		if (playerDamage == -2) return 0;
		my_pos = -1;
	}
	char text[64];
	GetCommonValueAtPos(text, sizeof(text), entity, SUPER_COMMON_NAME);
	if (StrEqual(text, "-1")) {
		// a weird error so let's kill the infected mob and wipe it from player data.
		ForceClearSpecialCommon(entity);
		return 0;
	}
	if (my_pos < 0) {
		int CommonHealth = GetCommonValueIntAtPos(entity, SUPER_COMMON_BASE_HEALTH);
		if (iBotLevelType == 1) CommonHealth += RoundToCeil(CommonHealth * (SurvivorLevels() * GetCommonValueFloatAtPos(entity, SUPER_COMMON_HEALTH_PER_LEVEL)));
		else CommonHealth += RoundToCeil(CommonHealth * (GetDifficultyRating(client) * GetCommonValueFloatAtPos(entity, SUPER_COMMON_HEALTH_PER_LEVEL)));

		if (handicapLevel[client] > 0) {
			float handicapLevelHealth = GetArrayCell(HandicapSelectedValues[client], 1);
			int handicapHealthBonus = RoundToCeil(CommonHealth * handicapLevelHealth);
			if (handicapHealthBonus > 0) CommonHealth += handicapHealthBonus;
		}
		// only add raid health if > 4 survivors.
		int theCount = LivingSurvivorCount();
		if (iSurvivorModifierRequired > 0 && fSurvivorHealthBonus > 0.0 && theCount >= iSurvivorModifierRequired) CommonHealth += RoundToCeil(CommonHealth * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorHealthBonus));
		int my_size	= GetArraySize(SpecialCommon[client]);
		ResizeArray(SpecialCommon[client], my_size + 1);
		SetArrayCell(SpecialCommon[client], my_size, entity, 0);
		SetArrayCell(SpecialCommon[client], my_size, CommonHealth, 1);
		SetArrayCell(SpecialCommon[client], my_size, 0, 2);
		SetArrayCell(SpecialCommon[client], my_size, 0, 3);
		SetArrayCell(SpecialCommon[client], my_size, 0, 4);
		my_pos = my_size;
	}
	if (playerDamage >= 0) {
		damageTotal = GetArrayCell(SpecialCommon[client], my_pos, 2);
		//new TrueHealthRemaining = RoundToCeil((1.0 - CheckTeammateDamages(entity, client)) * healthTotal);	// in case other players have damaged the mob - we can't just assume the remaining health without comparing to other players.
		if (damageTotal < 0) damageTotal = 0;
		//if (playerDamage > TrueHealthRemaining) playerDamage = TrueHealthRemaining;
		int maxHP = GetArrayCell(SpecialCommon[client], my_pos, 1) - damageTotal;
		maxHP = RoundToCeil(maxHP * (1.0 - CheckTeammateDamages(entity, client, _, true)));
		if (playerDamage > maxHP) playerDamage = maxHP;
		SetArrayCell(SpecialCommon[client], my_pos, damageTotal + playerDamage, 2);
		if (playerDamage > 0) {
			GetProficiencyData(client, GetWeaponProficiencyType(client), RoundToCeil(playerDamage * fProficiencyExperienceEarned));
			SetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE) + playerDamage);
			if (CheckTeammateDamagesEx(client, entity, playerDamage, _, ammotype, hitgroup) > 0) return playerDamage;
		}
	}
	return 1;
}

void AwardExperience(client, type = 0, AMOUNT = 0, bool TheRoundHasEnded=false) {

	char pct[4];
	Format(pct, sizeof(pct), "%");

	if (type == -1){//} && RoundExperienceMultiplier[client] > 0.0) {	//	This occurs when a player fully loads-in to a game, and is bonus container from previous round.

		//new RewardWaiting = RoundToCeil(BonusContainer[client] * RoundExperienceMultiplier[client]);
		//BonusContainer[client] += RoundToCeil(BonusContainer[client] * RoundExperienceMultiplier[client]);
		//PrintToChat(client, "%T", "bonus experience waiting", client, blue, green, AddCommasToString(RewardWaiting), blue, orange, blue, orange, blue, green, RoundExperienceMultiplier[client] * 100.0, pct);
		//PrintToChat(client, "%T", "round bonus private", )
		return;
	}

	//int InfectedBotLevelType = iBotLevelType;

	if (!TheRoundHasEnded && AMOUNT > 0) {//} && (bIsInCombat[client] || InfectedBotLevelType == 1 || b_IsFinaleActive || IsEnrageActive() || DoomTimer != 0)) {

		int bAMOUNT = AMOUNT;
		// Commented here because we multiply by REM in the ReceivedInfectedDamageAward call.
		// if (RoundExperienceMultiplier[client] > 0.0) {

		// 	bAMOUNT = AMOUNT + RoundToCeil(AMOUNT * RoundExperienceMultiplier[client]);
		// }
		// else bAMOUNT = AMOUNT;
		if (type == 1) HealingContribution[client] += bAMOUNT;
		else if (type == 2) BuffingContribution[client] += bAMOUNT;
		else if (type == 3) HexingContribution[client] += bAMOUNT;
	}
	if (TheRoundHasEnded || !b_IsFinaleActive && !IsEnrageActive() && AMOUNT == 0 && !bIsInCombat[client]) {

		//float PointsMultiplier = fPointsMultiplier;
		float HealingMultiplier = fHealingMultiplier;
		float BuffingMultiplier = fBuffingMultiplier;
		float HexingMultiplier = fHexingMultiplier;

		if (IsPlayerAlive(client)) {

			int h_Contribution = 0;
			if (HealingContribution[client] > 0) h_Contribution = RoundToCeil(HealingContribution[client] * HealingMultiplier);

			// float SurvivorPoints = 0.0;
			// if (h_Contribution > 0) SurvivorPoints = (h_Contribution * (PointsMultiplier * HealingMultiplier));

			int Bu_Contribution = 0;
			if (BuffingContribution[client] > 0) Bu_Contribution = RoundToCeil(BuffingContribution[client] * BuffingMultiplier);

			// if (Bu_Contribution > 0) SurvivorPoints += (Bu_Contribution * (PointsMultiplier * BuffingMultiplier));

			int He_Contribution = 0;
			if (HexingContribution[client] > 0) He_Contribution = RoundToCeil(HexingContribution[client] * HexingMultiplier);
			// if (He_Contribution > 0) SurvivorPoints += (He_Contribution * (PointsMultiplier * HexingMultiplier));

			//ReceiveInfectedDamageAward(client, 0, DamageContribution[client], PointsContribution[client], TankingContribution[client], h_Contribution, Bu_Contribution, He_Contribution, TheRoundHasEnded);
			ReceiveInfectedDamageAward(client, 0, DamageContribution[client], PointsContribution[client], TankingContribution[client], h_Contribution, Bu_Contribution, He_Contribution, TheRoundHasEnded);
		}
		HealingContribution[client] = 0;
		PointsContribution[client] = 0.0;
		TankingContribution[client] = 0;
		DamageContribution[client] = 0;
		BuffingContribution[client] = 0;
		HexingContribution[client] = 0;
			//ReceiveInfectedDamageAward(i, client, SurvivorExperience, SurvivorPoints, t_Contribution, h_Contribution);
	}
}

// stock bool IsClassType(client, char[] SearchString) {
// }

stock GetPassiveStrength(client, char[] SearchKey, char[] TalentName, TheSize = 64) {

	if (IsLegitimateClient(client)) {

		int size = GetArraySize(a_Menu_Talents);
		char SearchValue[64];
		//char TalentName[64];
		Format(TalentName, TheSize, "-1");
		int pos = -1;

		for (int i = 0; i < size; i++) {

			PassiveStrengthKeys[client] = GetArrayCell(a_Menu_Talents, i, 0);
			PassiveStrengthValues[client] = GetArrayCell(a_Menu_Talents, i, 1);

			
			GetArrayString(PassiveStrengthValues[client], PASSIVE_ABILITY, SearchValue, sizeof(SearchValue));
			
			if (!StrEqual(SearchKey, SearchValue)) continue;
			PassiveTalentName[client] = GetArrayCell(a_Menu_Talents, i, 2);
			GetArrayString(PassiveTalentName[client], 0, TalentName, TheSize);

			pos = GetDatabasePosition(client, TalentName);
			if (pos >= 0) {

				//GCMKeys[client] = PassiveStrengthKeys[client];
				//GCMValues[client] = PassiveStrengthValues[client];

				return GetArrayCell(a_Database_PlayerTalents[client], pos);
			}
			break;	// should never get here unless there's a spelling mistake in code/config
		}
	}
	return 0;
}

stock GetDatabasePosition(client, char[] TalentName) {

	int size				=	0;
	if (client != -1) size	=	GetArraySize(a_Database_PlayerTalents[client]);
	else size				=	GetArraySize(a_Database_PlayerTalents_Bots);
	char text[64];

	for (int i = 0; i < size; i++) {

		GetArrayString(a_Database_Talents, i, text, sizeof(text));
		if (StrEqual(TalentName, text)) return i;
	}
	return -1;
}

stock TalentRequirementsMet(client, Handle Keys, Handle Values, char[] sTalentList = "none", TheSize = 0, requiredTalentsToUnlock = 0) {
	int pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	char TalentName[64];
	char text[64];
	char talentTranslation[64];
	int count = 0;
	while (pos >= 0) {
		pos = FormatKeyValue(TalentName, sizeof(TalentName), Keys, Values, "talents required?", _, _, pos, false);
		int menuPos = GetMenuPosition(client, TalentName);
		if (menuPos >= 0) menuPos = GetArrayCell(MyTalentStrength[client], menuPos);
		if (!StrEqual(sTalentList, "none")) {
			if (pos < 0) {
				Format(sTalentList, TheSize, "%s", text);
				break;
			}

			if (menuPos < 1) {
				count++;
				GetTranslationOfTalentName(client, TalentName, talentTranslation, sizeof(talentTranslation), true);
				Format(talentTranslation, sizeof(talentTranslation), "%T", talentTranslation, client);
				if (count > 1) Format(text, sizeof(text), "%s\n%s", text, talentTranslation);
				else Format(text, sizeof(text), "%s", talentTranslation);
			}
			else requiredTalentsToUnlock--;
		}
		else {
			if (menuPos > 0) requiredTalentsToUnlock--;
			else count++;
		}
		if (TheSize == -1) return count;
		if (pos == -1) break;
		pos++;
	}
	return requiredTalentsToUnlock;
	//return true;
	//return (requiredTalentsToUnlock <= 0) ? true : false;
}

/*bool:DontAllowShotgunDamage(client) {
	if (IsLegitimateClient(client) && IsPlayerUsingShotgun(client) && shotgunCooldown[client]) return true;
	return false;
}*/

stock bool IsStatusEffectFound(client, Handle Keys, Handle Values) {
	char statusEffectToSearchFor[64];
	int pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	while (pos >= 0) {
		pos = FormatKeyValue(statusEffectToSearchFor, sizeof(statusEffectToSearchFor), Keys, Values, "positive effect required?", _, _, pos, false);
		if (pos == -1) break;
		// if we can't find the positive status effect.
		if (StrContains(ClientStatusEffects[client][1], statusEffectToSearchFor, true) == -1) return false;
		pos++;
	}
	pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	while (pos >= 0) {
		pos = FormatKeyValue(statusEffectToSearchFor, sizeof(statusEffectToSearchFor), Keys, Values, "negative effect required?", _, _, pos, false);
		if (pos == -1) break;
		// if we can't find the negative status effect.
		if (StrContains(ClientStatusEffects[client][0], statusEffectToSearchFor, true) == -1) return false;
		pos++;
	}
	// If all status effects are found (or none are found)
	return true;
}

stock bool IsAbilityFound(int client, int pos, char[] abilityT) {
	AbilityTriggerValues[client]	= GetArrayCell(a_Menu_Talents, pos, 3);
	int size = GetArraySize(AbilityTriggerValues[client]);
	char trigger[64];
	for (int i = 0; i < size; i++) {
		GetArrayString(AbilityTriggerValues[client], i, trigger, 64);
		if (StrEqual(abilityT, trigger, true)) return true;
	}
	return false;
}

stock GetGoverningAttribute(client, char[] TalentName, char[] governingAttribute, theSize) {
	char text[64];
	int size = GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {
		GetGoverningAttributeSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(GetGoverningAttributeSection[client], 0, text, sizeof(text));
		if (!StrEqual(TalentName, text)) continue;

		//GetGoverningAttributeKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		GetGoverningAttributeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(GetGoverningAttributeValues[client], GOVERNING_ATTRIBUTE, text, sizeof(text));
		if (StrEqual(text, "-1")) Format(governingAttribute, theSize, "-1");
		else GetTranslationOfTalentName(client, text, governingAttribute, theSize, true, _, true);
		break;
	}
}

stock GetTranslationOfTalentName(client, char[] nameOfTalent, char[] translationText, theSize, bool bGetTalentNameInstead = false, bool bJustKiddingActionBarName = false, bool returnResult = false) {
	char talentName[64];
	int size = GetArraySize(a_Menu_Talents);

	for (int i = 0; i < size; i++) {
		TranslationOTNSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(TranslationOTNSection[client], 0, talentName, sizeof(talentName));
		if (!returnResult && !StrEqual(talentName, nameOfTalent) ||
			returnResult && StrContains(talentName, nameOfTalent, false) == -1) continue;
		TranslationOTNValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);
		// Just a quick hack, I'll fix this later when I have time.
		// it works why change it?
		if (bJustKiddingActionBarName) {
			GetArrayString(TranslationOTNValues[client], ACTION_BAR_NAME, translationText, theSize);
		}
		else if (!bGetTalentNameInstead) {
			GetArrayString(TranslationOTNValues[client], GET_TRANSLATION, translationText, theSize);
			//if (StrEqual(translationText, "-1")) SetFailState("No \"translation?\" set for Talent %s in /configs/readyup/rpg/talentmenu.cfg", talentName);
			//else break;
		}
		else {
			GetArrayString(TranslationOTNValues[client], GET_TALENT_NAME, translationText, theSize);
			if (!returnResult && StrEqual(translationText, "-1")) Format(translationText, theSize, "%s", talentName);
		}
		break;
	}
}

bool alliesInRangeOnFire(int activator, float fCoherencyRange) {
	float cpos[3];
	GetClientAbsOrigin(activator, cpos);
	int activatorTeam = GetClientTeam(activator);
	for (int i = 1; i <= MaxClients; i++) {
		if (i == activator || !IsLegitimateClientAlive(i) || GetClientTeam(i) != activatorTeam) continue;
		float tpos[3];
		GetClientAbsOrigin(i, tpos);
		if (GetVectorDistance(cpos, tpos) > fCoherencyRange) continue;
		if (GetClientStatusEffect(i, "burn") < 1) continue;
		return true;
	}
	return false;
}

bool alliesInRangeWithAdrenaline(int activator, float fCoherencyRange) {
	float cpos[3];
	GetClientAbsOrigin(activator, cpos);
	int activatorTeam = GetClientTeam(activator);
	for (int i = 1; i <= MaxClients; i++) {
		if (i == activator || !IsLegitimateClientAlive(i) || GetClientTeam(i) != activatorTeam) continue;
		float tpos[3];
		GetClientAbsOrigin(i, tpos);
		if (GetVectorDistance(cpos, tpos) > fCoherencyRange) continue;
		if (!HasAdrenaline(i)) continue;
		return true;
	}
	return false;
}

stock float GetInfectedAbilityStrengthByTrigger(activator, targetPlayer = 0, char[] AbilityT, zombieclass = 0, damagevalue = 0,
										bool IsOverdriveStacks = false, bool IsCleanse = false, char[] ResultEffects = "none",
										ResultType = 0, bool bDontActuallyActivate = false, typeOfValuesToRetrieve = 1,
										hitgroup = -1, char[] abilityTrigger = "none", damagetype = -1, countAllTalentsRegardlessOfState = 0,
										bool bCooldownAlwaysActivates = false, entityIdToPassThrough = -1, int allowRecursiveSelf = 0) {
	int ASize = GetArraySize(a_Menu_Talents);
	if (GetArraySize(MyTalentStrength[activator]) != ASize) return 0.0;
	
	int activatorClass = FindZombieClass(activator);
	if (activatorClass == 1) activatorClass = 2;
	else if (activatorClass == 2) activatorClass = 4;
	else if (activatorClass == 3) activatorClass = 8;
	else if (activatorClass == 4) activatorClass = 16;
	else if (activatorClass == 5) activatorClass = 32;
	else if (activatorClass == 6) activatorClass = 64;
	else if (activatorClass == 8) activatorClass = 256;

	float p_Strength			= 0.0;
	float t_Strength			= 0.0;
	float p_Time				= 0.0;
	bool bIsCompounding = (StrEqual(ResultEffects, "none")) ? false : true;
	char TalentName[64];
	bool targetBileStatus = IsCoveredInBile(targetPlayer);
	float activatorPos[3];
	GetEntPropVector(activator, Prop_Send, "m_vecOrigin", activatorPos);
	int activatorFlags = GetEntityFlags(activator);
	int activatorButtons = GetEntProp(activator, Prop_Data, "m_nButtons");
	bool isTargetLegitimate = IsLegitimateClient(targetPlayer);
	int targetFlags = (isTargetLegitimate) ? GetEntityFlags(targetPlayer) : -1;
	int activatorCombatState = (bIsInCombat[activator]) ? 1 : 0;
	//int survivorVictim = L4D2_GetSurvivorVictim(activator);
	float fPercentageHealthRemaining = ((GetClientHealth(activator) * 1.0) / (GetMaximumHealth(activator) * 1.0));
	float fPercentageHealthRequired = 0.0;
	float fPercentageHealthRequiredMax = 0.0;
	//float fPercentageHealthMissing = 1.0 - fPercentageHealthRemaining;
	float fPercentageHealthTargetRemaining = GetClientHealthPercentage(activator, targetPlayer, true);
	//float fPercentageHealthTargetMissing = 1.0 - fPercentageHealthTargetRemaining;
	float fTargetRange = (activator != targetPlayer) ? GetTargetRange(activator, targetPlayer) : -1.0;
	bool activatorIsOnFire = (GetClientStatusEffect(activator, "burn") > 0) ? true : false;
	bool activatorIsFakeClient = IsFakeClient(activator);
	if (MyStatusEffects[activator] < 0) MyStatusEffects[activator] = 0;

	//if (IsFakeClient(activator)) return 0.0;
	for (int i = 0; i < ASize; i++) {
		TriggerValues[activator]	= GetArrayCell(a_Menu_Talents, i, 1);
		
		int activatorClassesAllowed = GetArrayCell(TriggerValues[activator], ACTIVATOR_CLASS_REQ);
		if (activatorClassesAllowed != -1 && !clientClassIsAllowed(activatorClassesAllowed, activatorClass)) continue;

		if (bIsCompounding) {
			int isThisTalentACompoundingTalent = GetArrayCell(TriggerValues[activator], COMPOUNDING_TALENT);
			if (isThisTalentACompoundingTalent != 1) continue;
		}

		TriggerSection[activator]	= GetArrayCell(a_Menu_Talents, i, 2);
		TriggerKeys[activator]		= GetArrayCell(a_Menu_Talents, i, 0);

		GetArrayString(TriggerSection[activator], 0, TalentName, sizeof(TalentName));
		// infected bots always have a point in every talent.
		int TheTalentStrength = (!activatorIsFakeClient) ? GetArrayCell(MyTalentStrength[activator], i) : 1;
		if (TheTalentStrength < 1) continue;
		bool bIsEffectOverTime = (GetArrayCell(TriggerValues[activator], TALENT_IS_EFFECT_OVER_TIME) == 1) ? true : false;
		bool isEffectOverTimeActive = (!bIsEffectOverTime || !EffectOverTimeActive(activator, i)) ? false : true;
		if (!isEffectOverTimeActive && !IsAbilityFound(activator, i, AbilityT)) continue;
		if (countAllTalentsRegardlessOfState == 0 && !isEffectOverTimeActive && IsAbilityCooldown(activator, TalentName)) continue;
		int isRawType = (GetArrayCell(TriggerValues[activator], ABILITY_TYPE) == 3) ? 1 : 0;
		// overriding typeOfValuesToRetrieve in header skips this next statement
		if (bIsCompounding && (typeOfValuesToRetrieve == 1 && isRawType == 1 || typeOfValuesToRetrieve == 2 && isRawType == 0)) continue;
		char activatoreffects[64];
		char targeteffects[64];
		int target = targetPlayer;
		if (!StrEqual(ResultEffects, "ignore")) {
			GetArrayString(TriggerValues[activator], ACTIVATOR_ABILITY_EFFECTS, activatoreffects, sizeof(activatoreffects));
			GetArrayString(TriggerValues[activator], TARGET_ABILITY_EFFECTS, targeteffects, sizeof(targeteffects));
			if (!StrEqual(targeteffects, "-1") && target != activator) ResultType = 1;
			else if (!StrEqual(activatoreffects, "-1")) ResultType = 0;
			else continue;	// if both targeteffects and activatoreffects are empty or activatoreffects is empty but the activator is the target, continue
			if (bIsCompounding) {
				if (ResultType == 0 && StrContains(ResultEffects, activatoreffects, true) == -1) continue;
				if (ResultType >= 1 && StrContains(ResultEffects, targeteffects, true) == -1) continue;
			}
		}
		// We can now make sure ability triggers are only required if the talent is not an effect over time, or if it is that it is false.
		int combatStateReq = GetArrayCell(TriggerValues[activator], COMBAT_STATE_REQ);
		if (combatStateReq >= 0 && combatStateReq != activatorCombatState) continue;
		if (activator != targetPlayer) {
			float fTargetRangeRequired = GetArrayCell(TriggerValues[activator], TARGET_RANGE_REQUIRED);
			if (fTargetRangeRequired > 0.0) {
				if (activator == target) continue;	// talents requiring a target range can't trigger if the activator is the target.
				bool bTargetMustBeWithinRange = (GetArrayCell(TriggerValues[activator], TARGET_RANGE_REQUIRED_OUTSIDE) != 1) ? true : false;
				if (bTargetMustBeWithinRange && fTargetRange > fTargetRangeRequired) continue;
				if (!bTargetMustBeWithinRange && fTargetRange <= fTargetRangeRequired) continue;
			}
		}
		int iLastTargetResult = GetArrayCell(TriggerValues[activator], TARGET_MUST_BE_LAST_TARGET);
		if (targetPlayer != lastTarget[activator] && iLastTargetResult == 1 || targetPlayer == lastTarget[activator] && iLastTargetResult == 0) continue;
		if ((targetFlags == -1 || (targetFlags & FL_ONGROUND)) && GetArrayCell(TriggerValues[activator], TARGET_MUST_BE_IN_THE_AIR) == 1) continue;

		if (GetArrayCell(TriggerValues[activator], TARGET_IS_SELF) == 1) target = activator;
		if (activator != target) {
			int activatorHighGroundResult = DoesClientHaveTheHighGround(activatorPos, target);
			if (activatorHighGroundResult != 1 && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_HAVE_HIGH_GROUND) == 1) continue;
			if (activatorHighGroundResult != -1 && GetArrayCell(TriggerValues[activator], TARGET_MUST_HAVE_HIGH_GROUND) == 1) continue;
			if (activatorHighGroundResult != 0 && GetArrayCell(TriggerValues[activator], ACTIVATOR_TARGET_MUST_EVEN_GROUND) == 1) continue;
		}

		if (GetArrayCell(TriggerValues[activator], ACTIVATOR_STATUS_EFFECT_REQUIRED) == 1) {
			if (!activatorIsOnFire && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_ON_FIRE) == 1) continue;
			if (ISEXPLODE[activator] == INVALID_HANDLE && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_EXPLODING) == 1) continue;
			if (!ISSLOW[activator] && !playerInSlowAmmo[activator] && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_SLOW) == 1) continue;
			if (ISFROZEN[activator] == INVALID_HANDLE && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_FROZEN) == 1) continue;
			if (!(activatorFlags & FL_INWATER) && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_DROWNING) == 1) continue;
		}
		float f_Strength	=	1.0;
		int iInfectedInRange = 0;
		char secondaryEffects[64];
		GetArrayString(TriggerValues[activator], SECONDARY_EFFECTS, secondaryEffects, sizeof(secondaryEffects));
		char activatorCallAbilityTrigger[64];
		GetArrayString(TriggerValues[activator], ACTIVATOR_CALL_ABILITY_TRIGGER, activatorCallAbilityTrigger, sizeof(activatorCallAbilityTrigger));
		char targetCallAbilityTrigger[64];
		GetArrayString(TriggerValues[activator], TARGET_CALL_ABILITY_TRIGGER, targetCallAbilityTrigger, sizeof(targetCallAbilityTrigger));

		fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ);
		if (fPercentageHealthRequired > 0.0 && fPercentageHealthRemaining > fPercentageHealthRequired) continue;
		fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], COHERENCY_RANGE);
		if (fPercentageHealthRequired > 0.0) {
			iInfectedInRange = NumSurvivorsInRange(activator, fPercentageHealthRequired, TEAM_INFECTED);
			int iCoherencyMax = GetArrayCell(TriggerValues[activator], COHERENCY_MAX);
			if (iCoherencyMax > 0 && iInfectedInRange > iCoherencyMax) iInfectedInRange = iCoherencyMax;
			if (iInfectedInRange < 1 && GetArrayCell(TriggerValues[activator], COHERENCY_REQ) == 1) continue;
		}
		if (target != activator) {	// target exists and is not the activator.
			fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_TAR_REMAINING);
			if (fPercentageHealthRequired > 0.0 && fPercentageHealthTargetRemaining < fPercentageHealthRequired) continue;
			fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_TAR_MISSING);
			if (fPercentageHealthRequired > 0.0 && 1.0 - fPercentageHealthTargetRemaining < fPercentageHealthRequired) continue;
		}
		char TheString[64];
		GetArrayString(TriggerValues[activator], PASSIVE_ABILITY, TheString, sizeof(TheString));
		if (!StrEqual(TheString, "-1")) continue;	// passive abilities from classes don't trigger here, they have specific points of trigger!

		if (!(activatorButtons & IN_DUCK) && GetArrayCell(TriggerValues[activator], REQUIRES_CROUCHING) == 1) continue;
		if (activator == target && GetArrayCell(TriggerValues[activator], CANNOT_TARGET_SELF) == 1) continue;
		if ((activatorFlags & FL_ONGROUND) && GetArrayCell(TriggerValues[activator], MUST_BE_JUMPING_OR_FLYING) == 1) continue;
		if (!ISBILED[activator] && GetArrayCell(TriggerValues[activator], VOMIT_STATE_REQ_ACTIVATOR) == 1) continue;
		if (!targetBileStatus && GetArrayCell(TriggerValues[activator], VOMIT_STATE_REQ_TARGET) == 1) continue;
		if (bHasWeakness[activator] > 0) {
			if (GetArrayCell(TriggerValues[activator], DISABLE_IF_WEAKNESS) == 1) continue;
		}
		else if (GetArrayCell(TriggerValues[activator], REQ_WEAKNESS) == 1) continue;
		// with this key, we can fire off nodes every x consecutive hits.
		int consecutiveHitsRequired = GetArrayCell(TriggerValues[activator], REQ_CONSECUTIVE_HITS);
		if (consecutiveHitsRequired > 0 && (ConsecutiveHits[activator] < 1 || ConsecutiveHits[activator] % consecutiveHitsRequired != 0)) continue;

		float f_EachPoint				= GetArrayCell(MyTalentStrengths[activator], i);
		float f_Time					= GetArrayCell(MyTalentStrengths[activator], i, 1);
		float f_Cooldown				= GetArrayCell(MyTalentStrengths[activator], i, 2);
		f_Strength				= f_EachPoint;
		int maxConsecutiveHitsToCount = 0;
		int maxConsecutiveHitsDivide = 0;

		if (GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_HITS) == 1) {
			maxConsecutiveHitsToCount = GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_MAX);
			if (maxConsecutiveHitsToCount > ConsecutiveHits[activator]) maxConsecutiveHitsToCount = ConsecutiveHits[activator];
			if (maxConsecutiveHitsToCount < 1) maxConsecutiveHitsToCount = 0;
			maxConsecutiveHitsDivide = GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_DIV);
			if (maxConsecutiveHitsDivide > 0 && maxConsecutiveHitsToCount > 0) maxConsecutiveHitsToCount = RoundToCeil((maxConsecutiveHitsToCount * 1.0) / (maxConsecutiveHitsDivide * 1.0));
			//f_Strength			*= maxConsecutiveHitsToCount;
		}
		if (maxConsecutiveHitsToCount > 0) {
			f_Strength			*= maxConsecutiveHitsToCount;
		}
		// we don't put the node on cooldown if we're not activating it.
		//if (!bDontActuallyActivate
		// we call the dontActuallyActivate functionality in actual damage calculations for certain events for better time complexity
		// so we're now using countAllTalentsRegardlessOfState which is yet... another new argument for this call.
		p_Strength += f_Strength;
		p_Time += f_Time;
		// background talents toggle bDontActuallyActivate here, because we do still want them to go on cooldown, and if we set it before the CreateCooldown method is called, they will not go on cooldown.
		// bDontActuallyActivate can be forcefully-called elsewhere, which is why it's ordered this way.
		if (GetArrayCell(TriggerValues[activator], BACKGROUND_TALENT) == 1) bDontActuallyActivate = true;
		// if (activator == target) Format(MultiplierText, sizeof(MultiplierText), "tS_%s", activatoreffects);
		// else Format(MultiplierText, sizeof(MultiplierText), "tS_%s", targeteffects);
		bool bIsStatusEffects = (GetArrayCell(TriggerValues[activator], STATUS_EFFECT_MULTIPLIER) == 1) ? true : false;
		float fMultiplyRange = GetArrayCell(TriggerValues[activator], MULTIPLY_RANGE);
		if (fMultiplyRange > 0.0) { // this talent multiplies its strength by the # of a certain type of entities in range.
			int iMultiplyCount = 0;
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_COMMONS) == 1) iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 0);
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_SUPERS) == 1) iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 1);
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_WITCHES) == 1) iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 2);
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_SURVIVORS) == 1) iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 3);
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_SPECIALS) == 1) iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 4);
			if (iMultiplyCount > 0) p_Strength *= iMultiplyCount;
		}
		fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_MISSING);
		if (fPercentageHealthRequired > 0.0 && 1.0 - fPercentageHealthRemaining >= fPercentageHealthRequired) {	// maximum bonus (eg: 0.4 (40%) missing) we require 0.2 (20%) to be missing. 40% > 20%, so:
			fPercentageHealthRequiredMax = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_MISSING_MAX);	// say we only want to allow the buff once at 20%, and not twice at 40%:
			fPercentageHealthRequired = (fPercentageHealthRequiredMax > 0.0 && ((1.0 - fPercentageHealthRemaining) / fPercentageHealthRequired) > fPercentageHealthRequiredMax) ?	// 40% / 20% = 2.0 , if we set the max to 1.0 (to allow the buff just once:
										fPercentageHealthRequiredMax :							// true (so we set the max to 1.0 as in our sample scenario)
										((1.0 - fPercentageHealthRemaining) / fPercentageHealthRequired);	// false (but doesn't happen in our example scenario)
			p_Strength += (p_Strength * fPercentageHealthRequired);
		}
		if (iInfectedInRange > 0) p_Strength += (p_Strength * iInfectedInRange);
		if (bIsCompounding) {
			if (p_Strength > 0.0) {
				if (!bIsStatusEffects) t_Strength += p_Strength;
				else t_Strength += (p_Strength * MyStatusEffects[activator]);
			}
		}
		else {
			char secondaryTrigger[64];
			GetArrayString(TriggerValues[activator], SECONDARY_ABILITY_TRIGGER, secondaryTrigger, sizeof(secondaryTrigger));
			if (bIsStatusEffects) p_Strength = (p_Strength * MyStatusEffects[activator]);
			if (ResultType >= 1) {
				if (!bDontActuallyActivate) {
					if (!isEffectOverTimeActive && bIsEffectOverTime) EffectOverTimeActive(activator, i, GetEngineTime() + GetArrayCell(TriggerValues[activator], TALENT_ACTIVE_STRENGTH_VALUE));
					ActivateAbilityEx(activator, target, damagevalue, targeteffects, p_Strength, p_Time, target, _, isRawType,
										GetArrayCell(TriggerValues[activator], PRIMARY_AOE), secondaryEffects,
										GetArrayCell(TriggerValues[activator], SECONDARY_AOE), hitgroup, secondaryTrigger,
										abilityTrigger, damagetype, _, activatorCallAbilityTrigger, entityIdToPassThrough, _, targetCallAbilityTrigger);
				}
			}
			else {
				if (!bDontActuallyActivate) {
					if (!isEffectOverTimeActive && bIsEffectOverTime) EffectOverTimeActive(activator, i, GetEngineTime() + GetArrayCell(TriggerValues[activator], TALENT_ACTIVE_STRENGTH_VALUE));
					ActivateAbilityEx(activator, activator, damagevalue, activatoreffects, p_Strength, p_Time, target, _, isRawType,
																GetArrayCell(TriggerValues[activator], PRIMARY_AOE), secondaryEffects,
																GetArrayCell(TriggerValues[activator], SECONDARY_AOE), hitgroup, secondaryTrigger,
																abilityTrigger, damagetype, _, activatorCallAbilityTrigger, entityIdToPassThrough, _, targetCallAbilityTrigger);
				}
			}
		}
		if (!bDontActuallyActivate || bCooldownAlwaysActivates) {
			// certain ammos need to reward buffing/hexing experience at this time.
			if (bHasWeakness[activator] == 2 && GetArrayCell(TriggerValues[activator], REQ_WEAKNESS) == 1) {
				IsClientInRangeSpecialAmmo(activator, "W", _, _, RoundToCeil(p_Strength * damagevalue));
			}
			if (f_Cooldown > 0.0) CreateCooldown(activator, GetTalentPosition(activator, TalentName), f_Cooldown);
		}
		p_Strength = 0.0;
		p_Time = 0.0;
	}
	if (damagevalue > 0 && t_Strength > 0.0) {

		if (ResultType == 0 || ResultType == 2) return (t_Strength * damagevalue);
		if (ResultType == 1) return (damagevalue + (t_Strength * damagevalue));
	}
	return t_Strength;
}

bool anyNearbyAlliesBelowHealthPercentage(int activator, float requireAllyBelowHealthPercentage, float fCoherencyRange) {
	// Get the origin position.
	float cpos[3];
	GetClientAbsOrigin(activator, cpos);
	int activatorTeam = GetClientTeam(activator);
	// We're going to check in a circle around this position for any teammates below the health requirement.
	for (int i = 1; i <= MaxClients; i++) {
		if (i == activator || !IsLegitimateClientAlive(i) || GetClientTeam(i) != activatorTeam) continue;
		// Get the position of the player so we can check if they're inside the circle.
		float tpos[3];
		GetClientAbsOrigin(i, tpos);
		// if they're not, well, it ends here.
		if (GetVectorDistance(cpos, tpos) > fCoherencyRange) continue;
		float fPercentageHealthRemaining = ((GetClientHealth(i) * 1.0) / (GetMaximumHealth(i) * 1.0));
		// If the player is in the circle, but is above the required health percentage, it ends here.
		if (fPercentageHealthRemaining >= requireAllyBelowHealthPercentage) continue;
		return true;
	}
	return false;
}

int enemyInRange(int activator, float fCoherencyRange) {
	float cpos[3];
	GetClientAbsOrigin(activator, cpos);
	int team = GetClientTeam(activator);
	for (int i = 1; i <= MaxClients; i++) {
		if (i == activator || !IsLegitimateClientAlive(i) || team == GetClientTeam(i)) continue;
		float tpos[3];
		GetClientAbsOrigin(i, tpos);
		if (GetVectorDistance(cpos, tpos) > fCoherencyRange) continue;
		return i;
	}
	return -1;
}

stock float GetAbilityStrengthByTrigger(activator, targetPlayer = 0, char[] AbilityT, zombieclass = 0, damagevalue = 0,
										bool IsOverdriveStacks = false, bool IsCleanse = false, char[] ResultEffects = "none",
										ResultType = 0, bool bDontActuallyActivate = false, typeOfValuesToRetrieve = 1,
										hitgroup = -1, char[] abilityTrigger = "none", damagetype = -1, countAllTalentsRegardlessOfState = 0,
										bool bCooldownAlwaysActivates = false, entityIdToPassThrough = -1, int allowRecursiveSelf = 0) {// activator, target, trigger ability, survivor effects, infected effects, 
														//common effects, zombieclass, damage typeofvalues: 0 (all) 1 (NO RAW) 2(raw values only)
	if (iRPGMode <= 0 || !IsLegitimateClient(activator)) return 0.0;
	int activatorTeamInt = GetClientTeam(activator);
	if (activatorTeamInt == TEAM_INFECTED) return GetInfectedAbilityStrengthByTrigger(activator, targetPlayer, AbilityT, zombieclass, damagevalue, IsOverdriveStacks, IsCleanse, ResultEffects,
																					ResultType, bDontActuallyActivate, typeOfValuesToRetrieve, hitgroup, abilityTrigger, damagetype, countAllTalentsRegardlessOfState,
																					bCooldownAlwaysActivates, entityIdToPassThrough, allowRecursiveSelf);

	if (activatorTeamInt == TEAM_SURVIVOR && GetArraySize(MyTalentStrengths[activator]) != GetArraySize(a_Menu_Talents)) return 0.0;
	//if (activatorTeamInt == TEAM_INFECTED) return 0.0;
	int ASize = GetArraySize(a_Menu_Talents);
	if (GetArraySize(MyTalentStrength[activator]) != ASize) return 0.0;
	// ResultType:
	// 0 Activator
	// 1 Target, but returns additive*multiplicative result.
	// 2 Target, but returns multiplicative result.
	//ResultEffects are so when compounding talents we know which type to pull from.
	//This is an alternative to GetAbilityStrengthByTrigger for talents that need it, and maybe eventually the whole system.
	if (targetPlayer == -2) targetPlayer = FindAnyRandomClient();
	if (targetPlayer < 1 || !IsLegitimateClient(targetPlayer) && !IsCommonInfected(targetPlayer) && !IsWitch(targetPlayer)) targetPlayer = activator;
	//int talenttarget = 0;
	bool isTargetLegitimate = IsLegitimateClient(targetPlayer);
	bool isWitch = IsWitch(targetPlayer);
	int targetTeam = (isTargetLegitimate) ? GetClientTeam(targetPlayer) : -1;

	int targetClass = (isTargetLegitimate) ? (targetTeam == TEAM_SURVIVOR) ? 0 : FindZombieClass(targetPlayer) : (isWitch) ? 7 : (IsCommonInfected(targetPlayer)) ? 9 : -1;
	if (targetClass == 0) targetClass = 1;
	else if (targetClass == 1) targetClass = 2;
	else if (targetClass == 2) targetClass = 4;
	else if (targetClass == 3) targetClass = 8;
	else if (targetClass == 4) targetClass = 16;
	else if (targetClass == 5) targetClass = 32;
	else if (targetClass == 6) targetClass = 64;
	else if (targetClass == 7) targetClass = 128;
	else if (targetClass == 8) targetClass = 256;
	else if (targetClass == 9) targetClass = 512;

	int activatorClass = 1;
	float p_Strength			= 0.0;
	float t_Strength			= 0.0;
	float p_Time				= 0.0;
	bool bIsCompounding = (StrEqual(ResultEffects, "none")) ? false : true;
	char TalentName[64];
	// Player stagger status is now updated every fStaggerTickrate instead of every time this func is called.
	// Should reduce overhead.
	bool targetIsStaggered = false;
	if (activator == targetPlayer) targetIsStaggered = bIsClientCurrentlyStaggered[activator];
	else if (isTargetLegitimate) targetIsStaggered = bIsClientCurrentlyStaggered[targetPlayer];// : IsCommonStaggered(targetPlayer);
	bool targetBileStatus = IsCoveredInBile(targetPlayer);
	int hitgroupType = GetHitgroupType(hitgroup);
	bool isScoped = false;
	float playerZoomTime = 0.0;
	float playerHoldingFireTime = 0.0;
	float activatorPos[3];
	GetEntPropVector(activator, Prop_Send, "m_vecOrigin", activatorPos);
	if (!IsFakeClient(activator)) {
		playerHoldingFireTime = GetHoldingFireTime(activator);
		isScoped = IsPlayerZoomed(activator);
		if (isScoped) playerZoomTime = GetActiveZoomTime(activator);
	}
	float fPlayerMaxHoldingFireTime = 0.0;
	//bool IsAFakeClient = IsFakeClient(activator);
	int activatorFlags = GetEntityFlags(activator);
	int activatorButtons = GetEntProp(activator, Prop_Data, "m_nButtons");
	int targetFlags = (isTargetLegitimate) ? GetEntityFlags(targetPlayer) : -1;
	//bool isTargetInTheAir = (targetFlags != -1 && !(targetFlags & FL_ONGROUND)) ? true : false;
	//bool activatorIsDucking = (activatorButtons & IN_DUCK) ? true : false;
	int activatorCombatState = (bIsInCombat[activator]) ? 1 : 0;
	int infectedAttacker = L4D2_GetInfectedAttacker(activator);
	bool incapState = IsIncapacitated(activator);
	bool ledgeState = (incapState) ? IsLedged(activator) : false;
	float fPercentageHealthRemaining = ((GetClientHealth(activator) * 1.0) / (GetMaximumHealth(activator) * 1.0));
	float fPercentageHealthRequired = 0.0;
	float fPercentageHealthRequiredMax = 0.0;
	//float fPercentageHealthMissing = 1.0 - fPercentageHealthRemaining;
	float fPercentageHealthTargetRemaining = GetClientHealthPercentage(activator, targetPlayer, true);
	//float fPercentageHealthTargetMissing = 1.0 - fPercentageHealthTargetRemaining;
	float fTargetRange = (activator != targetPlayer) ? GetTargetRange(activator, targetPlayer) : -1.0;
	bool activatorIsOnFire = (GetClientStatusEffect(activator, "burn") > 0) ? true : false;
	bool activatorIsSufferingAcidBurn = (GetClientStatusEffect(activator, "acid") > 0) ? true : false;
	int activatorCurrentWeaponSlot = GetWeaponSlot(lastEntityDropped[activator]);
	int targetEnsnaredSurvivor = (targetTeam == TEAM_INFECTED) ? L4D2_GetSurvivorVictim(targetPlayer) : -1;
	bool targetIsInfectedAndHasSurvivorEnsnared = (targetEnsnaredSurvivor != -1) ? true : false;

	//if (IsFakeClient(activator)) return 0.0;
	for (int i = 0; i < ASize; i++) {
		TriggerSection[activator]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(TriggerSection[activator], 0, TalentName, sizeof(TalentName));
		// infected bots always have a point in every talent.
		int TheTalentStrength = GetArrayCell(MyTalentStrength[activator], i);
		if (TheTalentStrength < 1) continue;

		TriggerKeys[activator]		= GetArrayCell(a_Menu_Talents, i, 0);
		TriggerValues[activator]	= GetArrayCell(a_Menu_Talents, i, 1);
		if (bIsCompounding) {
			int isThisTalentACompoundingTalent = GetArrayCell(TriggerValues[activator], COMPOUNDING_TALENT);
			if (isThisTalentACompoundingTalent != 1) continue;
		}

		int activatorClassesAllowed = GetArrayCell(TriggerValues[activator], ACTIVATOR_CLASS_REQ);
		if (activatorClassesAllowed != -1 && !clientClassIsAllowed(activatorClassesAllowed, activatorClass)) continue;

		// We need to check if this is an effect over time first because active effects have to skip the trigger check to be always active.
		bool bIsEffectOverTime = (GetArrayCell(TriggerValues[activator], TALENT_IS_EFFECT_OVER_TIME) == 1) ? true : false;
		bool isEffectOverTimeActive = (!bIsEffectOverTime || !EffectOverTimeActive(activator, i)) ? false : true;
		if (!isEffectOverTimeActive && !IsAbilityFound(activator, i, AbilityT)) continue;
		if (countAllTalentsRegardlessOfState == 0 && !isEffectOverTimeActive && IsAbilityCooldown(activator, TalentName)) continue;

		bool bIsEffectOverTimeIgnoresClass = (!isEffectOverTimeActive || GetArrayCell(TriggerValues[activator], IF_EOT_ACTIVE_ALLOW_ALL_ENEMIES) != 1) ? false : true;

		int targetClassesAllowed = GetArrayCell(TriggerValues[activator], TARGET_CLASS_REQ);
		if (targetClassesAllowed != -1 && !bIsEffectOverTimeIgnoresClass && (!isTargetLegitimate || !clientClassIsAllowed(targetClassesAllowed, targetClass))) continue;
		
		int isRawType = (GetArrayCell(TriggerValues[activator], ABILITY_TYPE) == 3) ? 1 : 0;
		// overriding typeOfValuesToRetrieve in header skips this next statement
		if (bIsCompounding && (typeOfValuesToRetrieve == 1 && isRawType == 1 || typeOfValuesToRetrieve == 2 && isRawType == 0)) continue;
		char activatoreffects[64];
		char targeteffects[64];
		int target = targetPlayer;

		if (!StrEqual(ResultEffects, "ignore")) {
			GetArrayString(TriggerValues[activator], ACTIVATOR_ABILITY_EFFECTS, activatoreffects, sizeof(activatoreffects));
			GetArrayString(TriggerValues[activator], TARGET_ABILITY_EFFECTS, targeteffects, sizeof(targeteffects));
			if (!StrEqual(targeteffects, "-1") && target != activator) ResultType = 1;
			else if (!StrEqual(activatoreffects, "-1")) ResultType = 0;
			else continue;	// if both targeteffects and activatoreffects are empty or activatoreffects is empty but the activator is the target, continue
			if (bIsCompounding) {
				if (ResultType == 0 && StrContains(ResultEffects, activatoreffects, true) == -1) continue;
				if (ResultType >= 1 && StrContains(ResultEffects, targeteffects, true) == -1) continue;
			}
		}
		// We can now make sure ability triggers are only required if the talent is not an effect over time, or if it is that it is false.
		int combatStateReq = GetArrayCell(TriggerValues[activator], COMBAT_STATE_REQ);
		if (combatStateReq >= 0 && combatStateReq != activatorCombatState) continue;

		char coherencyTalentNearbyRequired[64];
		GetArrayString(TriggerValues[activator], COHERENCY_TALENT_NEARBY_REQUIRED, coherencyTalentNearbyRequired, sizeof(coherencyTalentNearbyRequired));
		if (!StrEqual(coherencyTalentNearbyRequired, "-1") && !IsPlayerWithinBuffRange(activator, coherencyTalentNearbyRequired)) continue;

		float fCoherencyRange = GetArrayCell(TriggerValues[activator], COHERENCY_RANGE);
		int requireAllyWithAdren = GetArrayCell(TriggerValues[activator], REQUIRE_ALLY_WITH_ADRENALINE);
		if (requireAllyWithAdren == 1 && !alliesInRangeWithAdrenaline(activator, fCoherencyRange)) continue;

		int requireAllyOnFire = GetArrayCell(TriggerValues[activator], REQUIRE_ALLY_ON_FIRE);
		if (requireAllyOnFire == 1 && !alliesInRangeOnFire(activator, fCoherencyRange)) continue;

		int targetMustHaveAllyEnsnared = GetArrayCell(TriggerValues[activator], REQUIRE_TARGET_HAS_ENSNARED_ALLY);
		if (targetMustHaveAllyEnsnared == 1) {
			if (!targetIsInfectedAndHasSurvivorEnsnared || !ClientsWithinRange(activator, target, fCoherencyRange)) continue;
		}

		float requireAllyBelowHealthPercentage = GetArrayCell(TriggerValues[activator], REQUIRE_ALLY_BELOW_HEALTH_PERCENTAGE);
		if (requireAllyBelowHealthPercentage > 0.0 && !anyNearbyAlliesBelowHealthPercentage(activator, requireAllyBelowHealthPercentage, fCoherencyRange)) continue;

		int iMustNotBeHurtBySpecialInfectedOrWitch = GetArrayCell(TriggerValues[activator], UNHURT_BY_SPECIALINFECTED_OR_WITCH);
		if (iMustNotBeHurtBySpecialInfectedOrWitch == 1) {
			if (!isTargetLegitimate && !isWitch) continue;	// talents with this flag only work on special infected and witches as common infected/super common infected don't track tanking damage
			if (hasTargetHurtClient(activator, target, isTargetLegitimate ? 0 : 1)) continue;
		}
		//if (!IsValidValue_Int(TriggerValues[activator], COMBAT_STATE_REQ, activatorCombatState)) continue;
		// GetArrayString(TriggerValues[activator], TARGET_CLASS_REQ, TargetClassRequired, sizeof(TargetClassRequired));
		// bool bIsEffectOverTimeIgnoresClass = (!isEffectOverTimeActive || GetKeyValueIntAtPos(TriggerValues[activator], IF_EOT_ACTIVE_ALLOW_ALL_ENEMIES) != 1) ? false : true;
		// bool bAllowAllClasses = (bIsEffectOverTimeIgnoresClass || StrEqual(TargetClassRequired, "-1", false)) ? true : false;
		// if (!bAllowAllClasses && StrContains(TargetClassRequired, TargetClass, false) == -1) continue;
		//bool bAllowAllClasses = (bIsEffectOverTimeIgnoresClass || classesAllowed == -1) ? true : false;

		int iContributionTypeCategory = GetArrayCell(TriggerValues[activator], CONTRIBUTION_TYPE_CATEGORY);
		if (iContributionTypeCategory >= 0 && GetArrayCell(playerContributionTracker[activator], iContributionTypeCategory) < GetArrayCell(TriggerValues[activator], CONTRIBUTION_COST)) continue;
		int iWeaponSlotRequired = GetArrayCell(TriggerValues[activator], TALENT_WEAPON_SLOT_REQUIRED);
		if (iWeaponSlotRequired >= 0 && activatorCurrentWeaponSlot != iWeaponSlotRequired) continue;
		if (!LastHitWasHeadshot[activator] && GetArrayCell(TriggerValues[activator], LAST_KILL_MUST_BE_HEADSHOT) == 1) continue;
		if (GetArrayCell(TriggerValues[activator], TARGET_AND_LAST_TARGET_CLASS_MATCH) == 1 && targetClass != LastTargetClass[activator]) continue;
		if (activator != targetPlayer) {
			float fTargetRangeRequired = GetArrayCell(TriggerValues[activator], TARGET_RANGE_REQUIRED);
			if (fTargetRangeRequired > 0.0) {
				if (activator == target) continue;	// talents requiring a target range can't trigger if the activator is the target.
				bool bTargetMustBeWithinRange = (GetArrayCell(TriggerValues[activator], TARGET_RANGE_REQUIRED_OUTSIDE) != 1) ? true : false;
				if (bTargetMustBeWithinRange && fTargetRange > fTargetRangeRequired) continue;
				if (!bTargetMustBeWithinRange && fTargetRange <= fTargetRangeRequired) continue;
			}
		}
		int iLastTargetResult = GetArrayCell(TriggerValues[activator], TARGET_MUST_BE_LAST_TARGET);
		if (targetPlayer != lastTarget[activator] && iLastTargetResult == 1 || targetPlayer == lastTarget[activator] && iLastTargetResult == 0) continue;
		if ((targetFlags == -1 || (targetFlags & FL_ONGROUND)) && GetArrayCell(TriggerValues[activator], TARGET_MUST_BE_IN_THE_AIR) == 1) continue;

		if (GetArrayCell(TriggerValues[activator], TARGET_IS_SELF) == 1) target = activator;
		if (activator != target) {
			int activatorHighGroundResult = DoesClientHaveTheHighGround(activatorPos, target);
			if (activatorHighGroundResult != 1 && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_HAVE_HIGH_GROUND) == 1) continue;
			if (activatorHighGroundResult != -1 && GetArrayCell(TriggerValues[activator], TARGET_MUST_HAVE_HIGH_GROUND) == 1) continue;
			if (activatorHighGroundResult != 0 && GetArrayCell(TriggerValues[activator], ACTIVATOR_TARGET_MUST_EVEN_GROUND) == 1) continue;
		}

		if (GetArrayCell(TriggerValues[activator], ACTIVATOR_STATUS_EFFECT_REQUIRED) == 1) {
			if (!activatorIsOnFire && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_ON_FIRE) == 1) continue;
			if (!activatorIsSufferingAcidBurn && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_SUFFER_ACID_BURN) == 1) continue;
			if (ISEXPLODE[activator] == INVALID_HANDLE && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_EXPLODING) == 1) continue;
			if (!ISSLOW[activator] && !playerInSlowAmmo[activator] && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_SLOW) == 1) continue;
			if (ISFROZEN[activator] == INVALID_HANDLE && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_FROZEN) == 1) continue;
			if ((!activatorIsOnFire || !activatorIsSufferingAcidBurn) && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_SCORCHED) == 1) continue;
			if ((!activatorIsOnFire || ISFROZEN[activator] == INVALID_HANDLE) && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_STEAMING) == 1) continue;
			if (!(activatorFlags & FL_INWATER) && GetArrayCell(TriggerValues[activator], ACTIVATOR_MUST_BE_DROWNING) == 1) continue;
		}
		//if (!IsStatusEffectFound(activator, TriggerKeys[activator], TriggerValues[activator])) continue;

		float f_Strength	=	1.0;
		//iStrengthOverride = 0;
		//bIsCompounding = false;
		int iSurvivorsInRange = 0;

		// if bcompounding is enabled we need to make sure talents that are not compounding talents don't get calculated. right now they do.

		/*if (GetKeyValueIntAtPos(TriggerValues[activator], COMPOUNDING_TALENT) == 1) {
			bIsCompounding = true;
			if (StrEqual(ResultEffects, "none", false)) GetArrayString(TriggerValues[activator], COMPOUND_WITH, ResultEffects, sizeof(ResultEffects[]));
			if (StrEqual(ResultEffects, "-1", false)) continue;
		}*/
		char secondaryEffects[64];
		GetArrayString(TriggerValues[activator], SECONDARY_EFFECTS, secondaryEffects, sizeof(secondaryEffects));
		char nameOfItemToGivePlayer[64];
		GetArrayString(TriggerValues[activator], ITEM_NAME_TO_GIVE_PLAYER, nameOfItemToGivePlayer, sizeof(nameOfItemToGivePlayer));
		char activatorCallAbilityTrigger[64];
		GetArrayString(TriggerValues[activator], ACTIVATOR_CALL_ABILITY_TRIGGER, activatorCallAbilityTrigger, sizeof(activatorCallAbilityTrigger));
		char targetCallAbilityTrigger[64];
		GetArrayString(TriggerValues[activator], TARGET_CALL_ABILITY_TRIGGER, targetCallAbilityTrigger, sizeof(targetCallAbilityTrigger));

		fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_ACT_REMAINING);
		if (fPercentageHealthRequired > 0.0 && fPercentageHealthRemaining < fPercentageHealthRequired) continue;

		float fPercentageHealthActivationCost = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_ACTIVATION_COST);
		if (fPercentageHealthActivationCost > 0.0 && fPercentageHealthActivationCost >= fPercentageHealthRemaining) continue;
		/*
			This statement must come after the bIsCompounding check as we force a result type based on whether
			targeteffects or activatoreffects field is filled out in the talent.
		*/
		// if (target != activator && ResultType >= 1) {
		// 	if (targetEntityType == -1) continue;
		// 	if (StrEqual(targeteffects, "0")) continue;
		// }
		bool bIsEffectOverTimeIgnoresWeapon = (isEffectOverTimeActive && GetArrayCell(TriggerValues[activator], IF_EOT_ACTIVE_ALLOW_ALL_WEAPONS) == 1) ? true : false;
		if (!bIsEffectOverTimeIgnoresWeapon) {
			int iWeaponsPermitted = GetArrayCell(TriggerValues[activator], WEAPONS_PERMITTED);
			if (iWeaponsPermitted >= 10 && !clientWeaponCategoryIsAllowed(activator, iWeaponsPermitted)) continue;
		}

		fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ);
		if (fPercentageHealthRequired > 0.0 && fPercentageHealthRemaining > fPercentageHealthRequired) continue;
		if (fCoherencyRange > 0.0) {
			iSurvivorsInRange = NumSurvivorsInRange(activator, fCoherencyRange);
			int iCoherencyMax = GetArrayCell(TriggerValues[activator], COHERENCY_MAX);
			if (iCoherencyMax > 0 && iSurvivorsInRange > iCoherencyMax) iSurvivorsInRange = iCoherencyMax;
			if (iSurvivorsInRange < 1 && GetArrayCell(TriggerValues[activator], COHERENCY_REQ) == 1) continue;
		}
		if (targetClass >= 0 && target != activator) {	// target exists and is not the activator.
			fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_TAR_REMAINING);
			if (fPercentageHealthRequired > 0.0 && fPercentageHealthTargetRemaining < fPercentageHealthRequired) continue;
			fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_TAR_MISSING);
			if (fPercentageHealthRequired > 0.0 && 1.0 - fPercentageHealthTargetRemaining < fPercentageHealthRequired) continue;
		}
		
		if (!isScoped && GetArrayCell(TriggerValues[activator], REQUIRES_ZOOM) == 1) continue;

		char TheString[10];
		GetArrayString(TriggerValues[activator], PLAYER_STATE_REQ, TheString, sizeof(TheString));
		if (!ComparePlayerState(activator, TheString, incapState, ledgeState, infectedAttacker)) continue;

		GetArrayString(TriggerValues[activator], PASSIVE_ABILITY, TheString, sizeof(TheString));
		if (!StrEqual(TheString, "-1")) continue;	// passive abilities from classes don't trigger here, they have specific points of trigger!

		if (!isEffectOverTimeActive || GetArrayCell(TriggerValues[activator], IF_EOT_ACTIVE_ALLOW_ALL_HITGROUPS) != 1) {
			if (GetArrayCell(TriggerValues[activator], REQUIRES_HEADSHOT) == 1 && hitgroupType != HITGROUP_HEAD) continue;
			if (GetArrayCell(TriggerValues[activator], REQUIRES_LIMBSHOT) == 1 && hitgroupType != HITGROUP_LIMB) continue;
		}
		if (!(activatorButtons & IN_DUCK) && GetArrayCell(TriggerValues[activator], REQUIRES_CROUCHING) == 1) continue;
		if (!bIsClientCurrentlyStaggered[activator] && GetArrayCell(TriggerValues[activator], ACTIVATOR_STAGGER_REQ) == 1) continue;
		if (!targetIsStaggered && GetArrayCell(TriggerValues[activator], TARGET_STAGGER_REQ) == 1) continue;
		if (activator == target && GetArrayCell(TriggerValues[activator], CANNOT_TARGET_SELF) == 1) continue;
		if ((activatorFlags & FL_ONGROUND) && GetArrayCell(TriggerValues[activator], MUST_BE_JUMPING_OR_FLYING) == 1) continue;
		if (!ISBILED[activator] && GetArrayCell(TriggerValues[activator], VOMIT_STATE_REQ_ACTIVATOR) == 1) continue;
		if (!targetBileStatus && GetArrayCell(TriggerValues[activator], VOMIT_STATE_REQ_TARGET) == 1) continue;

		if (!playerHasAdrenaline[activator] && GetArrayCell(TriggerValues[activator], REQ_ADRENALINE_EFFECT) == 1) continue;
		if (bHasWeakness[activator] > 0) {
			if (GetArrayCell(TriggerValues[activator], DISABLE_IF_WEAKNESS) == 1) continue;
		}
		else if (GetArrayCell(TriggerValues[activator], REQ_WEAKNESS) == 1) continue;
		// with this key, we can fire off nodes every x consecutive hits.
		int consecutiveHitsRequired = GetArrayCell(TriggerValues[activator], REQ_CONSECUTIVE_HITS);
		if (consecutiveHitsRequired > 0 && (ConsecutiveHits[activator] < 1 || ConsecutiveHits[activator] % consecutiveHitsRequired != 0)) continue;

		int consecutiveHeadshotsRequired = GetArrayCell(TriggerValues[activator], REQ_CONSECUTIVE_HEADSHOTS);
		if (consecutiveHeadshotsRequired > 0 && (ConsecutiveHeadshots[activator] < 1 || ConsecutiveHeadshots[activator] % consecutiveHeadshotsRequired != 0)) continue;

		// f_EachPoint				= GetTalentInfo(activator, TriggerValues[activator], _, _, TalentName, talenttarget, iStrengthOverride);
		// f_Time					= GetTalentInfo(activator, TriggerValues[activator], 2, _, TalentName, talenttarget, iStrengthOverride);
		// f_Cooldown				= GetTalentInfo(activator, TriggerValues[activator], 3, _, TalentName, talenttarget, iStrengthOverride);
		// no need to calculate each time. Only run these calculations when a player puts a point in or removes a point from a talent.
		float f_EachPoint				= GetArrayCell(MyTalentStrengths[activator], i);
		float f_Time					= GetArrayCell(MyTalentStrengths[activator], i, 1);
		float f_Cooldown				= GetArrayCell(MyTalentStrengths[activator], i, 2);
		f_Strength				= f_EachPoint;

		// More Multiplying talents by a certain number of things...
		float multStrengthByNearbyAllies = GetArrayCell(TriggerValues[activator], MULT_STR_NEARBY_DOWN_ALLIES);
		if (multStrengthByNearbyAllies > 0.0) {
			int numOfAlliesInRange = GetClientsInRangeByState(activator, fCoherencyRange, true, _, SURVIVOR_STATE_INCAPACITATED);
			if (numOfAlliesInRange > 0) f_Strength += f_Strength * (numOfAlliesInRange * multStrengthByNearbyAllies);
		}
		int numOfEnsnaredAlliesInRange = GetClientsInRangeByState(activator, fCoherencyRange, true, _, SURVIVOR_STATE_ENSNARED);
		int requireEnsnaredAlly = GetArrayCell(TriggerValues[activator], REQUIRE_ENSNARED_ALLY);
		if (requireEnsnaredAlly == 1 && numOfEnsnaredAlliesInRange < 1) continue;

		int requireEnemyInCoherencyRange = GetArrayCell(TriggerValues[activator], REQUIRE_ENEMY_IN_COHERENCY_RANGE);
		int enemyInCoherencyRangeIsTarget = GetArrayCell(TriggerValues[activator], ENEMY_IN_COHERENCY_IS_TARGET);
		int enemyPlayerInRange = -1;
		if (requireEnemyInCoherencyRange == 1) {
			enemyPlayerInRange = enemyInRange(activator, fCoherencyRange);
			if (enemyPlayerInRange == -1) continue;
			target = enemyPlayerInRange;
		}

		float multStrengthByNearbyEnsnaredAllies = GetArrayCell(TriggerValues[activator], MULT_STR_NEARBY_ENSNARED_ALLIES);
		if (multStrengthByNearbyEnsnaredAllies > 0.0 && numOfEnsnaredAlliesInRange > 0) f_Strength += f_Strength * (numOfEnsnaredAlliesInRange * multStrengthByNearbyEnsnaredAllies);

		int maxConsecutiveHitsToCount = 0;
		int maxConsecutiveHitsDivide = 0;
		int maxConsecutiveHeadshotsToCount = 0;
		int maxConsecutiveHeadshotsDivide = 0;

		if (GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_HITS) == 1) {
			maxConsecutiveHitsToCount = GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_MAX);
			if (maxConsecutiveHitsToCount > ConsecutiveHits[activator]) maxConsecutiveHitsToCount = ConsecutiveHits[activator];
			if (maxConsecutiveHitsToCount < 1) maxConsecutiveHitsToCount = 0;
			maxConsecutiveHitsDivide = GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_DIV);
			if (maxConsecutiveHitsDivide > 0 && maxConsecutiveHitsToCount > 0) maxConsecutiveHitsToCount = RoundToCeil((maxConsecutiveHitsToCount * 1.0) / (maxConsecutiveHitsDivide * 1.0));
			//f_Strength			*= maxConsecutiveHitsToCount;
		}
		if (GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_HEADSHOTS) == 1) {
			maxConsecutiveHeadshotsToCount = GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_HEADSHOTS_MAX);
			if (maxConsecutiveHeadshotsToCount > ConsecutiveHeadshots[activator]) maxConsecutiveHeadshotsToCount = ConsecutiveHeadshots[activator];
			if (maxConsecutiveHeadshotsToCount < 1) maxConsecutiveHeadshotsToCount = 0;
			maxConsecutiveHeadshotsDivide = GetArrayCell(TriggerValues[activator], MULT_STR_CONSECUTIVE_HEADSHOTS_DIV);
			if (maxConsecutiveHeadshotsDivide > 0 && maxConsecutiveHeadshotsToCount > 0) maxConsecutiveHeadshotsToCount = RoundToCeil((maxConsecutiveHeadshotsToCount * 1.0) / (maxConsecutiveHeadshotsDivide * 1.0));
			//f_Strength			*= maxConsecutiveHeadshotsToCount;
		}
		if (maxConsecutiveHitsToCount > 0 || maxConsecutiveHeadshotsToCount > 0) {
			f_Strength			*= (maxConsecutiveHitsToCount + maxConsecutiveHeadshotsToCount);
		}

		// we don't put the node on cooldown if we're not activating it.
		//if (!bDontActuallyActivate
		// we call the dontActuallyActivate functionality in actual damage calculations for certain events for better time complexity
		// so we're now using countAllTalentsRegardlessOfState which is yet... another new argument for this call.
		p_Strength = f_Strength;
		p_Time += f_Time;
		// background talents toggle bDontActuallyActivate here, because we do still want them to go on cooldown, and if we set it before the CreateCooldown method is called, they will not go on cooldown.
		// bDontActuallyActivate can be forcefully-called elsewhere, which is why it's ordered this way.
		if (GetArrayCell(TriggerValues[activator], BACKGROUND_TALENT) == 1) bDontActuallyActivate = true;
		// if (activator == target) Format(MultiplierText, sizeof(MultiplierText), "tS_%s", activatoreffects);
		// else Format(MultiplierText, sizeof(MultiplierText), "tS_%s", targeteffects);
		bool bIsStatusEffects = (GetArrayCell(TriggerValues[activator], STATUS_EFFECT_MULTIPLIER) == 1) ? true : false;
		
		float fMultiplyRange = GetArrayCell(TriggerValues[activator], MULTIPLY_RANGE);
		if (fMultiplyRange > 0.0) { // this talent multiplies its strength by the # of a certain type of entities in range.
			int iMultiplyCount = 0;
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_COMMONS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 0);
			}
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_SUPERS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 1);
			}
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_WITCHES) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 2);
			}
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_SURVIVORS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 3);
			}
			if (GetArrayCell(TriggerValues[activator], MULTIPLY_SPECIALS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 4);
			}
			if (iMultiplyCount > 0) p_Strength *= iMultiplyCount;
		}
		fMultiplyRange = GetArrayCell(TriggerValues[activator], STRENGTH_INCREASE_ZOOMED);
		if (fMultiplyRange > 0.0) {
			// If we want a cap on when staying zoomed in stops increasing the strength...
			float fPlayerMaxZoomTime = GetArrayCell(TriggerValues[activator], STRENGTH_INCREASE_TIME_CAP);
			if (fPlayerMaxZoomTime > 0.0 && playerZoomTime > fPlayerMaxZoomTime) playerZoomTime = fPlayerMaxZoomTime;
			// If we only want the bonus to be applied when a minimum amount of time has passed...
			fPlayerMaxZoomTime = GetArrayCell(TriggerValues[activator], STRENGTH_INCREASE_TIME_REQ);
			// no minimum time is required	or	player meets or exceeds time requirement.
			if (fPlayerMaxZoomTime <= 0.0 || playerZoomTime >= fPlayerMaxZoomTime) p_Strength += (f_Strength * (playerZoomTime / fMultiplyRange));
			else {
				// If the player doesn't meet the time requirement for this perk to give a bonus, we need to check if this is an x-increase over time perk, and don't fire if it is.
				if (GetArrayCell(TriggerValues[activator], ZOOM_TIME_HAS_MINIMUM_REQ) == 1) continue;
			}
		}
		fMultiplyRange = GetArrayCell(TriggerValues[activator], HOLDING_FIRE_STRENGTH_INCREASE);
		if (fMultiplyRange > 0.0) {
			// If we want a cap on when staying zoomed in stops increasing the strength...
			fPlayerMaxHoldingFireTime = GetArrayCell(TriggerValues[activator], STRENGTH_INCREASE_TIME_CAP);
			if (fPlayerMaxHoldingFireTime > 0.0 && playerHoldingFireTime > fPlayerMaxHoldingFireTime) playerHoldingFireTime = fPlayerMaxHoldingFireTime;
			// If we only want the bonus to be applied when a minimum amount of time has passed...
			fPlayerMaxHoldingFireTime = GetArrayCell(TriggerValues[activator], STRENGTH_INCREASE_TIME_REQ);
			// no minimum time is required	or	player meets or exceeds time requirement.
			if (fPlayerMaxHoldingFireTime <= 0.0 || playerHoldingFireTime >= fPlayerMaxHoldingFireTime) p_Strength += (f_Strength * (playerHoldingFireTime / fMultiplyRange));
			else {
				// If the player doesn't meet the time requirement for this perk to give a bonus, we need to check if this is an x-increase over time perk, and don't fire if it is.
				if (GetArrayCell(TriggerValues[activator], DAMAGE_TIME_HAS_MINIMUM_REQ) == 1) continue;
			}
		}
		fPercentageHealthRequired = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_MISSING);
		if (fPercentageHealthRequired > 0.0 && 1.0 - fPercentageHealthRemaining >= fPercentageHealthRequired) {	// maximum bonus (eg: 0.4 (40%) missing) we require 0.2 (20%) to be missing. 40% > 20%, so:
			fPercentageHealthRequiredMax = GetArrayCell(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_MISSING_MAX);	// say we only want to allow the buff once at 20%, and not twice at 40%:
			fPercentageHealthRequired = (fPercentageHealthRequiredMax > 0.0 && ((1.0 - fPercentageHealthRemaining) / fPercentageHealthRequired) > fPercentageHealthRequiredMax) ?	// 40% / 20% = 2.0 , if we set the max to 1.0 (to allow the buff just once:
										fPercentageHealthRequiredMax :							// true (so we set the max to 1.0 as in our sample scenario)
										((1.0 - fPercentageHealthRemaining) / fPercentageHealthRequired);	// false (but doesn't happen in our example scenario)
			p_Strength += (f_Strength * fPercentageHealthRequired);
		}
		if (iSurvivorsInRange > 0) p_Strength += (f_Strength * iSurvivorsInRange);
		if (bIsCompounding) {
			if (!bIsStatusEffects) t_Strength += p_Strength;
			else t_Strength += (p_Strength * MyStatusEffects[activator]);
		}
		else {
			if (!IsOverdriveStacks) {
				char secondaryTrigger[64];
				GetArrayString(TriggerValues[activator], SECONDARY_ABILITY_TRIGGER, secondaryTrigger, sizeof(secondaryTrigger));
				if (bIsStatusEffects) p_Strength = (p_Strength * MyStatusEffects[activator]);
				if (ResultType >= 1) {
					if (!bDontActuallyActivate) {
						if (!isEffectOverTimeActive && bIsEffectOverTime) EffectOverTimeActive(activator, i, GetEngineTime() + GetArrayCell(TriggerValues[activator], TALENT_ACTIVE_STRENGTH_VALUE));
						// If this is an effect over time
						//if (!AllowEffectOverTimeToContinue(activator, TriggerValues[activator], TalentName, damagevalue, targeteffects, target, p_Strength)) continue;
						// eotStrength = GetEffectOverTimeStrength(activator, targeteffects);
						// if (eotStrength > 0.0) p_Strength *= eotStrength;
						if (iContributionTypeCategory >= 0) SetArrayCell(playerContributionTracker[activator], iContributionTypeCategory, GetArrayCell(playerContributionTracker[activator], iContributionTypeCategory) - GetArrayCell(TriggerValues[activator], CONTRIBUTION_COST));
						ActivateAbilityEx(activator, target, damagevalue, targeteffects, p_Strength, p_Time, target, _, isRawType,
											GetArrayCell(TriggerValues[activator], PRIMARY_AOE), secondaryEffects,
											GetArrayCell(TriggerValues[activator], SECONDARY_AOE), hitgroup, secondaryTrigger,
											abilityTrigger, damagetype, nameOfItemToGivePlayer, activatorCallAbilityTrigger, entityIdToPassThrough, fPercentageHealthActivationCost, targetCallAbilityTrigger);
					}
				}
				else {
					if (!bDontActuallyActivate) {
						// If this is an effect over time
						//if (!AllowEffectOverTimeToContinue(activator, TriggerValues[activator], TalentName, damagevalue, activatoreffects, target, p_Strength)) continue;
						// eotStrength = GetEffectOverTimeStrength(activator, activatoreffects);
						// if (eotStrength > 0.0) p_Strength *= eotStrength;
						if (!isEffectOverTimeActive && bIsEffectOverTime) EffectOverTimeActive(activator, i, GetEngineTime() + GetArrayCell(TriggerValues[activator], TALENT_ACTIVE_STRENGTH_VALUE));
						if (iContributionTypeCategory >= 0) SetArrayCell(playerContributionTracker[activator], iContributionTypeCategory, GetArrayCell(playerContributionTracker[activator], iContributionTypeCategory) - GetArrayCell(TriggerValues[activator], CONTRIBUTION_COST));
						ActivateAbilityEx(activator, activator, damagevalue, activatoreffects, p_Strength, p_Time, target, _, isRawType,
																	GetArrayCell(TriggerValues[activator], PRIMARY_AOE), secondaryEffects,
																	GetArrayCell(TriggerValues[activator], SECONDARY_AOE), hitgroup, secondaryTrigger,
																	abilityTrigger, damagetype, nameOfItemToGivePlayer, activatorCallAbilityTrigger, entityIdToPassThrough, fPercentageHealthActivationCost, targetCallAbilityTrigger);
					}
				}
			}
			else {

				if (!bIsStatusEffects) t_Strength += p_Strength;
				else t_Strength += (p_Strength * MyStatusEffects[activator]);
			}
		}
		if (!bDontActuallyActivate || bCooldownAlwaysActivates) {
			// certain ammos need to reward buffing/hexing experience at this time.
			if (bHasWeakness[activator] == 2 && GetArrayCell(TriggerValues[activator], REQ_WEAKNESS) == 1) {
				IsClientInRangeSpecialAmmo(activator, "W", _, _, RoundToCeil(p_Strength * damagevalue));
			}
			if (f_Cooldown > 0.0) CreateCooldown(activator, GetTalentPosition(activator, TalentName), f_Cooldown);
		}
		p_Strength = 0.0;
		p_Time = 0.0;
	}
	//if (StrEqual(ResultEffects, "o", true)) PrintToChat(activator, "damage reduction: %3.3f", t_Strength);
	if (targetPlayer != activator) LastTargetClass[activator] = targetClass;
	if (damagevalue > 0 && t_Strength > 0.0) {

		if (ResultType == 0 || ResultType == 2) return (t_Strength * damagevalue);
		if (ResultType == 1) return (damagevalue + (t_Strength * damagevalue));
	}
	if (t_Strength < 0.0) t_Strength = 0.0;
	return t_Strength;
}

stock bool clientClassIsAllowed(classCategoriesAllowed, classCategory) {
	return classCategory & classCategoriesAllowed > 0;
}

stock bool clientWeaponCategoryIsAllowed(client, weaponCategoriesAllowed) {
	int weaponCategories = currentWeaponCategory[client];
	return weaponCategories & weaponCategoriesAllowed > 0;
	// new weaponsAllowed = weaponCategoriesAllowed;
	// while (weaponCategories != 0) {
	// 	while (weaponsAllowed != 0) {
	// 		if (weaponCategories % 100 == weaponsAllowed % 100) return true;
	// 		weaponsAllowed /= 100;
	// 	}
	// 	weaponCategories /= 100;
	// 	weaponsAllowed = weaponCategoriesAllowed;
	// }
	//return false;
}

stock SetMyWeapons(client) {
	if (!IsLegitimateClient(client) || GetClientTeam(client) != TEAM_SURVIVOR) return;
	char PlayerWeapon[64];
	GetClientWeapon(client, PlayerWeapon, 64);
	// Skip if it's not weapon slot 0 or 1.
	if (StrContains(PlayerWeapon, "smg", false) == -1 &&
		StrContains(PlayerWeapon, "shotgun", false) == -1 &&
		StrContains(PlayerWeapon, "sniper", false) == -1 &&
		StrContains(PlayerWeapon, "rifle", false) == -1 &&
		StrContains(PlayerWeapon, "melee", false) == -1 &&
		StrContains(PlayerWeapon, "pistol", false) == -1 &&
		StrContains(PlayerWeapon, "chainsaw", false) == -1) return;
	if (StrContains(PlayerWeapon, "melee", false) != -1) {
		int g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		int iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
		GetEntityClassname(iWeapon, PlayerWeapon, sizeof(PlayerWeapon));
		GetEntPropString(iWeapon, Prop_Data, "m_strMapSetScriptName", MyCurrentWeapon[client], 64);
		hasMeleeWeaponEquipped[client] = true;
		currentWeaponCategory[client]  =																											4096;	// MELEE WEAPONS ONLY (NO GUNS)-------------22
	}
	else if (StrContains(PlayerWeapon, "weapon_", false) != -1) {
		int WeaponId = -1;
		if (StrContains(PlayerWeapon, "pistol", false) == -1 && StrContains(PlayerWeapon, "chainsaw", false) == -1) WeaponId = GetPlayerWeaponSlot(client, 0);
		else WeaponId = GetPlayerWeaponSlot(client, 1);
		if (IsValidEntity(WeaponId)) GetEntityClassname(WeaponId, MyCurrentWeapon[client], 64);
		hasMeleeWeaponEquipped[client] = false;
		currentWeaponCategory[client]  =																											2048;	// ALL GUNS---------------------------------21
		bool isHuntingRifle = (StrContains(PlayerWeapon, "hunting", false) != -1) ? true : false;
		if (StrContains(PlayerWeapon, "smg", false) != -1) currentWeaponCategory[client] =																1;	// all smg									10
		if (StrContains(PlayerWeapon, "shotgun", false) != -1) currentWeaponCategory[client] +=															2;	// all shotguns								11
		if (StrContains(PlayerWeapon, "pump", false) != -1 || StrContains(PlayerWeapon, "chrome", false) != -1) currentWeaponCategory[client] +=		4;	// tier 1 shotguns (pumps)------------------12
		if (!isHuntingRifle && StrContains(PlayerWeapon, "rifle", false) != -1) currentWeaponCategory[client] +=										8; // all rifles (including m60)				13
		if (isHuntingRifle || StrContains(PlayerWeapon, "sniper", false) != -1) currentWeaponCategory[client] +=										16; // all snipers (hunting rifle too)			14
		if (StrContains(PlayerWeapon, "pistol", false) != -1) currentWeaponCategory[client] +=															32;	// all pistols								15
		if (StrContains(PlayerWeapon, "magnum", false) != -1) currentWeaponCategory[client] +=															64;	// magnum pistol----------------------------16
		if (StrContains(PlayerWeapon, "pistol", false) != -1 && StrContains(PlayerWeapon, "magnum", false) == -1) currentWeaponCategory[client] +=		128;	// dual pistols							17
		if (StrContains(PlayerWeapon, "magnum", false) != -1 || StrContains(PlayerWeapon, "awp", false) != -1) currentWeaponCategory[client] +=			256;	// 50 cal weapons (magnum and awp)		18
		if (StrContains(PlayerWeapon, "awp", false) != -1 || StrContains(PlayerWeapon, "scout", false) != -1) currentWeaponCategory[client] +=			512;	// sniper rifles (bolt only)			19
		if (StrContains(PlayerWeapon, "hunting", false) != -1 || StrContains(PlayerWeapon, "military", false) != -1) currentWeaponCategory[client] +=	1024;	// DMRS (semi-auto snipers)				20
		if ((StrContains(PlayerWeapon, "smg", false) != -1 || StrContains(PlayerWeapon, "chrome", false) != -1 ||
			StrContains(PlayerWeapon, "pump", false) != -1 || StrContains(PlayerWeapon, "pistol", false) != -1) ||
			StrContains(PlayerWeapon, "hunting", false) != -1) currentWeaponCategory[client] +=															8192;	// TIER 1 WEAPONS ONLY					23
		if (StrContains(PlayerWeapon, "spas", false) != -1 || StrContains(PlayerWeapon, "autoshotgun", false) != -1 ||
			StrContains(PlayerWeapon, "sniper", false) != -1 ||
			StrContains(PlayerWeapon, "rifle", false) != -1 && StrContains(PlayerWeapon, "hunting", false) == -1) currentWeaponCategory[client] +=		16384;	// TIER 2 WEAPONS ONLY					24
	}
}

stock bool EffectOverTimeActive(activator, talentMenuPos, float fEffectTime = 0.0) {
	int size = GetArraySize(PlayerEffectOverTime[activator]);
	if (fEffectTime <= 0.0) { // check if it's active and return true if it is.
		for (int i = 0; i < size; i++) {
			if (GetArrayCell(PlayerEffectOverTime[activator], i) != talentMenuPos) continue;
			if (GetArrayCell(PlayerEffectOverTime[activator], i, 1) > GetEngineTime()) return true;	// effect over time is active.
			else {																					// effect over time has ended - remove it.
				RemoveFromArray(PlayerEffectOverTime[activator], i);
				return false;
			}
		}
		return false;																				// effect over time not found, false.
	}
	else {
		ResizeArray(PlayerEffectOverTime[activator], size+1);
		SetArrayCell(PlayerEffectOverTime[activator], size, talentMenuPos);
		SetArrayCell(PlayerEffectOverTime[activator], size, GetEngineTime() + fEffectTime);
	}
	return true;
}

stock bool EnemiesWithinExplosionRange(client, float TheRange, TheStrength) {

	if (!IsLegitimateClientAlive(client)) return false;
	float MyRange[3];
	GetClientAbsOrigin(client, MyRange);

	//int ent = -1;

	bool IsInRangeTheRange = false;
	int RealStrength = TheStrength * GetClientHealth(client);
	if (RealStrength < 1) return false;

	float TheirRange[3];
	bool isClientFake = IsFakeClient(client);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || i == client || GetClientTeam(i) == TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, TheirRange);
		if (GetVectorDistance(MyRange, TheirRange) <= TheRange) {

			if (!IsInRangeTheRange) {

				IsInRangeTheRange = true;
				CreateAmmoExplosion(client, MyRange[0], MyRange[1], MyRange[2]);		// Boom!
			}
			if (!isClientFake && IsSpecialCommonInRange(i, 't')) continue;	// even though the mob is within the explosion range, it is immune because a defender is nearby.
			AddSpecialInfectedDamage(client, i, RealStrength, _, 1);
			CheckTeammateDamagesEx(client, i, RealStrength);
		}
	}
	/*new zombieLimit = GetArraySize(Handle:CommonInfected);
	for (new zombie = 0; zombie < zombieLimit; zombie++) {

		ent = GetArrayCell(Handle:CommonInfected, zombie);
		if (!IsCommonInfected(ent)) continue;	// || IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, _, i) != -2.0) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TheirRange);
		if (GetVectorDistance(MyRange, TheirRange) <= TheRange) {

			if (!IsInRangeTheRange) {

				IsInRangeTheRange = true;
				CreateAmmoExplosion(client, MyRange[0], MyRange[1], MyRange[2]);
			}

			if (IsSpecialCommon(ent)) AddSpecialCommonDamage(client, ent, RealStrength, _, 1);
			else AddCommonInfectedDamage(client, ent, RealStrength, _, 1);
		}
	}
	zombieLimit = GetArraySize(WitchList);
	for (new zombie = 0; zombie < zombieLimit; zombie++) {

		ent = GetArrayCell(Handle:WitchList, zombie);
		if (!IsWitch(ent)) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TheirRange);
		if (GetVectorDistance(MyRange, TheirRange) <= TheRange) {

			if (!IsInRangeTheRange) {

				IsInRangeTheRange = true;
				CreateAmmoExplosion(client, MyRange[0], MyRange[1], MyRange[2]);
			}
			AddWitchDamage(client, ent, RealStrength, _, 1);
		}
	}*/
	return IsInRangeTheRange;
}

stock bool ComparePlayerState(client, char[] CombatState, bool incapState, bool ledgeState, infectedAttacker) {

	if (StrEqual(CombatState, "-1") || StrContains(CombatState, "0") != -1) return true;

	if (incapState && StrContains(CombatState, "1") != -1) return true;
	if (!incapState && StrContains(CombatState, "2") != -1) return true;
	if (infectedAttacker == -1 && !incapState && StrContains(CombatState, "3") != -1) return true;
	if (ledgeState && StrContains(CombatState, "4") != -1) return true;
	return false;
}

stock GetPIV(client, float Distance, bool IsSameTeam = true) {

	float ClientOrigin[3];
	float iOrigin[3];

	GetClientAbsOrigin(client, ClientOrigin);

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || i == client) continue;
		if (IsSameTeam && GetClientTeam(client) != GetClientTeam(i)) continue;
		GetClientAbsOrigin(i, iOrigin);
		if (GetVectorDistance(ClientOrigin, iOrigin) <= Distance) count++;
	}
	return count;
}

stock float GetPlayerDistance(client, target) {

	float ClientDistance[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientDistance);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientDistance);

	float TargetDistance[3];
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetDistance);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetDistance);

	return GetVectorDistance(ClientDistance, TargetDistance);
}

stock bool AbilityChanceSuccess(client, char[] s_TalentName = "none") {
	if (IsLegitimateClient(client)) {
		int pos				=	FindChanceRollAbility(client, s_TalentName);
		if (pos == -1) return false;

		char talentname[64];

		float i_EachPoint	=	0.0;
		//int i_Strength		=	0;
		int range			=	0;
		//int i_Strength_Temp	=	0;
		//float i_EachPoint_Temp = 0.0;

		//AbilityKeys[client]			= GetArrayCell(a_Menu_Talents, pos, 0);
		AbilityValues[client]		= GetArrayCell(a_Menu_Talents, pos, 1);
		AbilitySection[client]		= GetArrayCell(a_Menu_Talents, pos, 2);

		GetArrayString(AbilitySection[client], 0, talentname, sizeof(talentname));
		if (GetArrayCell(MyTalentStrength[client], pos) < 1) return false;

		i_EachPoint				= GetTalentInfo(client, AbilityValues[client], _, _, talentname);
		range					= RoundToCeil(1.0 / (i_EachPoint * 100.0));

		range				=	GetRandomInt(1, range);

		if (range <= 1) return true;
	}
	return false;
}

stock GetCategoryStrength(client, char[] sTalentCategory, bool bGetMaximumTreePointsInstead = false) {
	if (!IsLegitimateClient(client)) return 0;
	int count = 0;
	char sText[64];
	char sTalentName[64];
	int iStrength = 0;

	int size = GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {
		//GetCategoryStrengthKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		GetCategoryStrengthValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(GetCategoryStrengthValues[client], TALENT_TREE_CATEGORY, sText, sizeof(sText));
		if (!StrEqual(sTalentCategory, sText, false)) continue;
		
		GetCategoryStrengthSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(GetCategoryStrengthSection[client], 0, sTalentName, sizeof(sTalentName));

		if (bGetMaximumTreePointsInstead) count++;
		else {
			iStrength = GetTalentStrength(client, sTalentName, _, i);
			if (iStrength > 0) count++;
		}
	}
	return count;
}

stock VerifyClientUnlockedTalentEligibility(client) {
	for (int i = 0; i < iMaxLayers-1; i++) {
		if (GetLayerUpgradeStrength(client, i, true) == -1) break;
	}
}

stock int GetLayerUpgradeStrength(client, layer = 1, bool bIsCheckEligibility = false, bool bResetLayer = false,
								bool countAllOptionsOnLayer = false, bool getAllLayerNodes = false, bool ignoreAttributes = false) {
	int size = GetArraySize(a_Menu_Talents);
	int count = 0;
	int clientTeam = GetClientTeam(client);
	char TalentName[64];
	for (int i = 0; i < size; i++) {										// loop through this talents keyfile.
		GetLayerStrengthKeys[client] = GetArrayCell(a_Menu_Talents, i, 0);	// "keys"
		GetLayerStrengthValues[client] = GetArrayCell(a_Menu_Talents, i, 1);// "values"

		int activatorClassesAllowed = GetArrayCell(GetLayerStrengthValues[client], ACTIVATOR_CLASS_REQ);
		if (activatorClassesAllowed > -1) {
			int isSurvivorTalent		= (activatorClassesAllowed % 2 == 1) ? 1 : 0;
			int isInfectedTalent		= (activatorClassesAllowed > 1) ? 1 : 0;
			if (isSurvivorTalent == 1 && clientTeam != TEAM_SURVIVOR) continue;
			if (isInfectedTalent == 1 && clientTeam != TEAM_INFECTED) continue;
		}

		GetLayerStrengthSection[client] = GetArrayCell(a_Menu_Talents, i, 2);	// Array holding the "name" of the talent.
		GetArrayString(GetLayerStrengthSection[client], 0, TalentName, sizeof(TalentName));
		// talents are ordered by "layers" (think a 3-d talent tree)
		if (GetArrayCell(GetLayerStrengthValues[client], GET_TALENT_LAYER) != layer) continue;
		if (ignoreAttributes && GetArrayCell(GetLayerStrengthValues[client], IS_ATTRIBUTE) == 1) continue;
		if (getAllLayerNodes) {	// we just want to get how many nodes are on this layer, even the ones that we ignore for layer count.
			count++;
			continue;
		}
		if (!countAllOptionsOnLayer && GetArrayCell(GetLayerStrengthValues[client], LAYER_COUNTING_IS_IGNORED) == 1) continue;
		if (bResetLayer) {
			count = GetArrayCell(MyTalentStrength[client], i);
			if (count < 1) continue;
			PlayerUpgradesTotal[client]--;	// nodes can only be upgraded once regardless of their unlock cost.
			FreeUpgrades[client]++;//= nodeUnlockCost;
			AddTalentPoints(client, TalentName, 0);	// This func actually SETS the talent points to the value you specify... SetTalentPoints?
			continue;
		}
		new currTalentStrength = GetArrayCell(MyTalentStrength[client], i);
		if (currTalentStrength > 0) count += currTalentStrength;	// how many talent points have the player invested in this node?
	}
	if (bResetLayer) return -2;	// for logging purposes.
	if (bIsCheckEligibility && count < RoundToCeil(GetLayerUpgradeStrength(client, layer, _, _, _, true, true) * fUpgradesRequiredPerLayer)) {	// we only check the eligibility of the layer the player just locked(refunded) their node in.
		for (int i = layer + 1; i <= iMaxLayers; i++) {	// if any layer is found to not meet eligibility, all subsequent layers are reset.
			GetLayerUpgradeStrength(client, i, _, true);
		}
		return -1;	// logging
	}
	return count;
}

stock GetTalentKeyValue(client, char[] TalentName, pos, char[] storage, storageLocSize) {
	int size = GetArraySize(a_Menu_Talents);
	char result[64];
	for (int i = 0; i < size; i++) {
		GetTalentKeyValueSection[client]		= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(GetTalentKeyValueSection[client], 0, result, sizeof(result));
		if (!StrEqual(result, TalentName)) continue;

		//GetTalentKeyValueKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		GetTalentKeyValueValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(GetTalentKeyValueValues[client], pos, storage, storageLocSize);
		break;
	}
}

stock float GetTalentStrengthByKeyValue(client, pos, char[] searchValue, bool skipTalentsOnCooldown = true, bool returnFirstResult = false) {
	int size = GetArraySize(a_Menu_Talents);
	char result[64];
	float fTotalTalentStrength = 0.0;
	char talentName[64];
	for (int talent = 0; talent < size; talent++) {
		if (GetArrayCell(MyTalentStrength[client], talent) < 1) continue;

		GetTalentStrengthSearchValues[client]		= GetArrayCell(a_Menu_Talents, talent, 1);
		GetArrayString(GetTalentStrengthSearchValues[client], pos, result, sizeof(result));
		if (!StrEqual(result, searchValue)) continue;

		GetTalentStrengthSearchSection[client]		= GetArrayCell(a_Menu_Talents, talent, 2);
		GetArrayString(GetTalentStrengthSearchSection[client], 0, talentName, sizeof(talentName));
		if (skipTalentsOnCooldown && IsAbilityCooldown(client, talentName)) continue;

		float fThisTalentStrength = GetTalentInfo(client, GetTalentStrengthSearchValues[client], _, _, talentName);
		if (fThisTalentStrength > 0.0) {
			if (returnFirstResult) return fThisTalentStrength;
			fTotalTalentStrength += fThisTalentStrength;
		}
	}
	return fTotalTalentStrength;
}

stock float GetStrengthByKeyValueFloat(client, int pos, char[] searchValue, int resultPos, int tpos = -1) {
	int size = GetArraySize(a_Menu_Talents);
	char result[64];
	if (GetArraySize(MyTalentStrength[client]) != size) ResizeArray(MyTalentStrength[client], size);
	for (int i = (tpos == -1) ? 0 : tpos; i < size; i++) {
		GetStrengthFloat[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(GetStrengthFloat[client], pos, result, sizeof(result));
		if (!StrEqual(result, searchValue)) continue;

		// found the talent with the required value to the search key.
		GetTalentValueSearchSection[client]		= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(GetTalentValueSearchSection[client], 0, result, sizeof(result));
		int count = GetArrayCell(MyTalentStrength[client], i);
		if (count < 1) {
			if (tpos == -1) continue;
			return 0.0;
		}
		// the talent has at least 1 point in it, so we get the target key's value and return it.
		float fResult = GetArrayCell(GetStrengthFloat[client], resultPos);
		return fResult;
	}
	return 0.0;
}

stock GetTalentPointsByKeyValue(client, pos, char[] searchValue, bool getFirstTalentResult = true) {
	int size = GetArraySize(a_Menu_Talents);
	char result[64];
	int count = 0;
	int total = 0;
	if (GetArraySize(MyTalentStrength[client]) != size) ResizeArray(MyTalentStrength[client], size);
	for (int i = 0; i < size; i++) {
		//GetTalentValueSearchKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		GetTalentValueSearchValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		GetArrayString(GetTalentValueSearchValues[client], pos, result, sizeof(result));
		if (!StrEqual(result, searchValue)) continue;
		// we found a talent with the search value required, so we want to get its name.
		GetTalentValueSearchSection[client]		= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(GetTalentValueSearchSection[client], 0, result, sizeof(result));
		// and its strength.
		count = GetArrayCell(MyTalentStrength[client], i);
		if (count < 1) continue;
		// if there are multiple nodes with the same function, but we only care if at least one is unlocked
		if (getFirstTalentResult) return count;
		total += count;
	}
	return total;
}

stock GetTalentStrength(client, char[] TalentName, target = 0, pos = -1, bool containsTalentName = false) {
	int size				=	GetArraySize(a_Database_PlayerTalents[client]);
	char text[64];
	int count = 0;


	for (int i = 0; i < size; i++) {
		GetArrayString(a_Database_Talents, i, text, sizeof(text));
		if (containsTalentName) {
			if (StrContains(text, TalentName, false) != -1) count += GetArrayCell(a_Database_PlayerTalents[client], i);
		}
		else if (StrEqual(TalentName, text)) {
			return GetArrayCell(a_Database_PlayerTalents[client], i);
		}
	}
	return count;
}

/*
	This method lets us make it so all talent nodes have a key field named "attribute?"

	Server operators can set these to any custom value, as long as there is an attribute node with that name made.
	The attributes multiplier, weighed based on several factors seen below, scales all factors of the talent.

	These include strength, active time, cooldown time, passive time, etc.
	If you don't want a node connected to an attribute, omit "attribute?" from the node.
*/
stock float GetAttributeMultiplier(client, char[] TalentName) {
	int size = GetArraySize(a_Menu_Talents);
	//int iStrength = 0;
	char text[64];
	//float baseMultiplier;
	//float dimMultiplier;
	//int dimPoint;
	//bool multipliersSet = false;
	size = GetArraySize(a_Menu_Talents);
	float attributeStrength = 0.0;
	float totalAttributeStrength = 0.0;
	for (int i = 0; i < size; i++) {
		int str = GetArrayCell(MyTalentStrength[client], i);
		if (str < 1) continue;

		GAMKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		GAMValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);

		/*	Is this node an attribute node?
			we count how many attribute nodes the player has unlocked to determine the multiplier of said attribute.
		*/
		GetArrayString(GAMValues[client], ATTRIBUTE_MULTIPLIER, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;

		GetArrayString(GAMValues[client], TALENT_UPGRADE_STRENGTH_VALUE, text, 64);
		if (StrContains(text, ".") == -1) attributeStrength = StringToInt(text) * 1.0;
		else attributeStrength = StringToFloat(text);
		if (attributeStrength > 0.0) totalAttributeStrength += attributeStrength;
	}
	/*new Float:currStrength = 0.0;
	for (new i = 1; i <= iStrength; i++) {
		if (i % dimPoint == 0) baseMultiplier *= dimMultiplier;
		currStrength += baseMultiplier;
	}
	return currStrength;*/
	return totalAttributeStrength;
}

stock GetKeyPos(Handle Keys, char[] SearchKey) {

	char key[64];
	int size = GetArraySize(Keys);
	for (int i = 0; i < size; i++) {

		GetArrayString(Keys, i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) return i;
	}
	return -1;
}

stock bool FoundCooldownReduction(char[] TalentName, char[] CooldownList) {
	int ExplodeCount = GetDelimiterCount(CooldownList, "|") + 1;
	if (ExplodeCount == 1) {
		if (StrContains(TalentName, CooldownList, false) != -1) return true;
	}
	else {
		char[][] cooldownTalentName = new char[ExplodeCount][64];
		ExplodeString(CooldownList, "|", cooldownTalentName, ExplodeCount, 64);
		for (int i = 0; i < ExplodeCount; i++) {
			if (StrContains(TalentName, cooldownTalentName[i], false) != -1) return true;
		}
	}
	return false;
}

stock FormatKeyValue(char[] TheValue, TheSize, Handle Keys, Handle Values, char[] SearchKey, char[] DefaultValue = "none", bool:bDebug = false, pos = 0, bool incrementPos = true) {

	char key[512];

	int size = GetArraySize(Keys);
	if (pos > 0 && incrementPos) pos++;
	for (int i = pos; i < size; i++) {

		GetArrayString(Keys, i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) {

			GetArrayString(Values, i, TheValue, TheSize);
			return i;
		}
	}
	if (StrEqual(DefaultValue, "none", false)) Format(TheValue, TheSize, "-1");
	else Format(TheValue, TheSize, "%s", DefaultValue);
	return -1;
}

stock float GetKeyValueFloat(Handle Keys, Handle Values, char[] SearchKey, char[] DefaultValue = "none", bool:bDebug = false, pos = 0) {

	char key[64];
	if (pos > 0) pos++;
	int size = GetArraySize(Keys);
	for (int i = pos; i < size; i++) {

		GetArrayString(Keys, i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) {

			GetArrayString(Values, i, key, sizeof(key));
			return StringToFloat(key);
		}
	}
	if (StrEqual(DefaultValue, "none", false)) return -1.0;
	return StringToFloat(DefaultValue);
}

// bool IsValidValue_Int(Handle Values, pos, compare) {
// 	char val[64];
// 	GetArrayString(Values, pos, val, 64);
// 	int result = StringToInt(val);
// 	if (result == -1 || result == compare) return true;
// 	return false;
// }

stock GetKeyValueIntAtPos(Handle Values, pos) {
	char key[64];
	GetArrayString(Values, pos, key, sizeof(key));
	return StringToInt(key);
}

stock float GetKeyValueFloatAtPos(Handle Values, pos) {
	char key[64];
	GetArrayString(Values, pos, key, sizeof(key));
	return StringToFloat(key);
}

stock GetKeyValueInt(Handle Keys, Handle Values, char[] SearchKey, char[] DefaultValue = "none", bool:bDebug = false) {

	char key[64];

	int size = GetArraySize(Keys);
	for (int i = 0; i < size; i++) {

		GetArrayString(Keys, i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) {

			GetArrayString(Values, i, key, sizeof(key));
			return StringToInt(key);
		}
	}
	if (StrEqual(DefaultValue, "none", false)) return -1;
	return StringToInt(DefaultValue);
}

stock GetMenuOfTalent(client, char[] TalentName, char[] TheText, TheSize) {

	char s_TalentName[64];

	int size = GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {

		//MOTKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
		MOTValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		MOTSection[client]		= GetArrayCell(a_Menu_Talents, i, 2);

		GetArrayString(MOTSection[client], 0, s_TalentName, sizeof(s_TalentName));
		if (!StrEqual(s_TalentName, TalentName, false)) continue;
		GetArrayString(MOTValues[client], PART_OF_MENU_NAMED, TheText, TheSize);
		return;
	}
	Format(TheText, TheSize, "-1");
}

stock FindChanceRollAbility(client, char[] s_TalentName = "none") {

	if (IsLegitimateClient(client)) {

		int a_Size			=	0;

		a_Size		= GetArraySize(a_Menu_Talents);

		char TalentName[64];
		char MenuName[64];

		for (int i = 0; i < a_Size; i++) {

			//ChanceKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
			ChanceValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
			ChanceSection[client]		= GetArrayCell(a_Menu_Talents, i, 2);

			//GetArrayString(Handle:ChanceSection[client], 0, TalentName, sizeof(TalentName));
			GetArrayString(ChanceValues[client], PART_OF_MENU_NAMED, TalentName, sizeof(TalentName));
			GetMenuOfTalent(client, s_TalentName, MenuName, sizeof(MenuName));
			if (!StrEqual(TalentName, MenuName, false)) continue;

			GetArrayString(ChanceValues[client], ACTIVATOR_ABILITY_EFFECTS, TalentName, sizeof(TalentName));

			if (StrContains(TalentName, "C", true) != -1) return i;
		}
	}
	return -1;
}

stock GetWeaponSlot(entity) {

	if (IsValidEntity(entity)) {

		char Classname[64];
		GetEntityClassname(entity, Classname, sizeof(Classname));

		if (StrContains(Classname, "pistol", false) != -1 || StrContains(Classname, "chainsaw", false) != -1) return 1;
		if (StrContains(Classname, "molotov", false) != -1 || StrContains(Classname, "pipe_bomb", false) != -1 || StrContains(Classname, "vomitjar", false) != -1) return 2;
		if (StrContains(Classname, "defib", false) != -1 || StrContains(Classname, "first_aid", false) != -1) return 3;
		if (StrContains(Classname, "adren", false) != -1 || StrContains(Classname, "pills", false) != -1) return 4;
		return 0;
	}
	return -1;
}

stock SurvivorPowerSlide(client) {
	float vel[3];
	vel[0]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vel[1]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	vel[2]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

	if (vel[0] > 0.0) vel[0] += 100.0;
	else vel[0] -= 100.0;
	if (vel[1] > 0.0) vel[1] += 100.0;
	else vel[1] -= 100.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
}

stock BeanBag(client, float force) {

	if (IsLegitimateClientAlive(client)) {

		int myteam = GetClientTeam(client);

		if (myteam == TEAM_INFECTED && L4D2_GetSurvivorVictim(client) != -1 || (GetEntityFlags(client) & FL_ONGROUND)) {

			float Velocity[3];

			Velocity[0]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
			Velocity[1]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
			Velocity[2]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

			float Vec_Pull;
			float Vec_Lunge;

			Vec_Pull	=	GetRandomFloat(force * -1.0, force);
			Vec_Lunge	=	GetRandomFloat(force * -1.0, force);
			Velocity[2]	+=	force;

			if (Vec_Pull < 0.0 && Velocity[0] > 0.0) Velocity[0] *= -1.0;
			Velocity[0] += Vec_Pull;

			if (Vec_Lunge < 0.0 && Velocity[1] > 0.0) Velocity[1] *= -1.0;
			Velocity[1] += Vec_Lunge;

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
			if (myteam == TEAM_INFECTED) {

				int victim = L4D2_GetSurvivorVictim(client);
				if (victim != -1) TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, Velocity);
			}
		}
	}
}

stock CreateExplosion(client, damage = 0, attacker = 0, bool IsAOE = false, float fRange = 96.0) {

	int entity 				= CreateEntityByName("env_explosion");
	float loc[3];
	float tloc[3];
	int totalIncomingDamage = 0, aClient = 0;
	if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_INFECTED) aClient = client;
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, loc);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", loc);

	DispatchKeyValue(entity, "fireballsprite", "sprites/zerogxplode.spr");
	DispatchKeyValue(entity, "iMagnitude", "0");	// we don't want the fireball dealing damage - we do this manually.
	DispatchKeyValue(entity, "iRadiusOverride", "0");
	DispatchKeyValue(entity, "rendermode", "5");
	DispatchKeyValue(entity, "spawnflags", "0");
	DispatchSpawn(entity);
	TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "explode");

	int zombieclass = -1;
	if (aClient > 0) zombieclass = FindZombieClass(client);
	if (damage > 0 || zombieclass == ZOMBIECLASS_TANK) {
		if (IsAOE) {
			for (int i = 1; i <= MaxClients; i++) {
				if (!IsLegitimateClientAlive(i)) continue;
				if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
				GetClientAbsOrigin(i, tloc);
				if (GetVectorDistance(loc, tloc) > fRange) continue;
				if (totalIncomingDamage > 0) {
					SetClientTotalHealth(aClient, i, totalIncomingDamage);
					if (aClient > 0 && GetClientTeam(aClient) == TEAM_INFECTED) AddSpecialInfectedDamage(i, client, totalIncomingDamage, true);
				}
				if (zombieclass == ZOMBIECLASS_TANK) {
					// tank aoe jump explosion.
					ScreenShake(i);
				}
			}
			return;
		}

		if (IsWitch(client)) {

			if (FindListPositionByEntity(client, WitchList) >= 0) AddWitchDamage(attacker, client, damage);
			else OnWitchCreated(client, true);
		}
		else if (IsSpecialCommon(client)) AddSpecialCommonDamage(attacker, client, damage);
		else if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(attacker) && FindZombieClass(attacker) == ZOMBIECLASS_TANK) {
			if ((GetEntityFlags(client) & FL_ONGROUND)) {

				if (CheckActiveAbility(client, totalIncomingDamage, 1) > 0.0) {

					if (GetClientTotalHealth(client) <= totalIncomingDamage) ChangeTankState(attacker, "hulk", true);

					SetClientTotalHealth(attacker, client, totalIncomingDamage);
					AddSpecialInfectedDamage(client, attacker, totalIncomingDamage, true);	// bool is tanking instead.
				}
			}
			else {

				// If a player follows the mechanic successfully, hulk ends and changes to death state.

				//ChangeTankState(attacker, "hulk", true);
				//ChangeTankState(attacker, "death");
			}
		}
	}
}

stock CreateAmmoExplosion(client, float PosX=0.0, float PosY=0.0, float PosZ=0.0) {

	int entity 				= CreateEntityByName("env_explosion");
	float loc[3];
	loc[0] = PosX;
	loc[1] = PosY;
	loc[2] = PosZ;

	DispatchKeyValue(entity, "fireballsprite", "sprites/zerogxplode.spr");
	DispatchKeyValue(entity, "iMagnitude", "0");	// we don't want the fireball dealing damage - we do this manually.
	DispatchKeyValue(entity, "iRadiusOverride", "0");
	DispatchKeyValue(entity, "rendermode", "5");
	DispatchKeyValue(entity, "spawnflags", "0");
	DispatchSpawn(entity);
	TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "explode");
	if (IsValidEntity(entity)) AcceptEntityInput(entity, "Kill");
}

stock ScreenShake(client) {

	int entity = CreateEntityByName("env_shake");

	float loc[3];
	GetClientAbsOrigin(client, loc);
	if(entity >= 0)
	{
		DispatchKeyValue(entity, "spawnflags", "8");
		DispatchKeyValue(entity, "amplitude", "16.0");
		DispatchKeyValue(entity, "frequency", "1.5");
		DispatchKeyValue(entity, "duration", "0.9");
		DispatchKeyValue(entity, "radius", "0.0");
		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "Enable");

		TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "StartShake");

		SetVariantString("OnUser1 !self:Kill::1.1:1");
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

stock ZeroGravity(client, victim, float g_TalentStrength, float g_TalentTime) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(victim)) {

		if (L4D2_GetSurvivorVictim(victim) != -1 || ((GetEntityFlags(victim) & FL_ONGROUND) || !b_GroundRequired[victim])) {


		//if (GetEntityFlags(victim) & FL_ONGROUND || !b_GroundRequired[victim]) {

			//if (ZeroGravityTimer[victim] == INVALID_HANDLE) {

			float vel[3];
			vel[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
			vel[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
			vel[2] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[2]");
			//ZeroGravityTimer[victim] = 
			CreateTimer(g_TalentTime, Timer_ZeroGravity, victim, TIMER_FLAG_NO_MAPCHANGE);
			SetEntityGravity(victim, GravityBase[victim] - g_TalentStrength);
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);

			int survivor = L4D2_GetSurvivorVictim(victim);
			if (survivor != -1) {

				//ZeroGravityTimer[survivor] = 
				CreateTimer(g_TalentTime, Timer_ZeroGravity, survivor, TIMER_FLAG_NO_MAPCHANGE);
				SetEntityGravity(survivor, GravityBase[survivor] - g_TalentStrength);
				TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, vel);
			}
			//}
		}
	}
}

stock SlowPlayer(client, float g_TalentStrength, float g_TalentTime) {

	if (IsLegitimateClientAlive(client) && !ISSLOW[client]) {

		//if (SlowMultiplierTimer[client] != INVALID_HANDLE) {

		//	KillTimer(SlowMultiplierTimer[client]);
		//	SlowMultiplierTimer[client] = INVALID_HANDLE;
		//}
		//SlowMultiplierTimer[client] = 
		ISSLOW[client] = true;
		CreateTimer(g_TalentTime, Timer_Slow, client, TIMER_FLAG_NO_MAPCHANGE);
		fSlowSpeed[client] = g_TalentStrength;
	}
}

stock CreateLineSoloEx(client, target, char[] DrawColour, char[] DrawPos, float lifetime = 0.5, targetClient = 0) {

	float ClientPos[3];
	float TargetPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetPos);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);

	ClientPos[2] += StringToFloat(DrawPos);
	TargetPos[2] += StringToFloat(DrawPos);

	if (StrEqual(DrawColour, "green", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 255, 0, 200}, 50);
	else if (StrEqual(DrawColour, "red", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 0, 200}, 50);
	else if (StrEqual(DrawColour, "blue", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 255, 200}, 50);
	else if (StrEqual(DrawColour, "purple", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 255, 200}, 50);
	else if (StrEqual(DrawColour, "yellow", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 0, 200}, 50);
	else if (StrEqual(DrawColour, "orange", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 69, 0, 200}, 50);
	else if (StrEqual(DrawColour, "black", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 0, 200}, 50);
	else if (StrEqual(DrawColour, "brightblue", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {132, 112, 255, 200}, 50);
	else if (StrEqual(DrawColour, "darkgreen", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {178, 34, 34, 200}, 50);
	else if (StrEqual(DrawColour, "white", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 255, 200}, 50);
	else return 0;
	TE_SendToClient(targetClient);
	return 1;
}
stock CreateRingSoloEx(client, float RingAreaSize, char[] DrawColour, char[] DrawPos, bool IsPulsing = true, float lifetime = 1.0, targetClient, float PosX=0.0, float PosY=0.0, float PosZ=0.0) {
	float ClientPos[3];
	if (client != -1) {
		if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
		else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	}
	else {
		ClientPos[0] = PosX;
		ClientPos[1] = PosY;
		ClientPos[2] = PosZ;
	}
	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;

	ClientPos[2] += 20.0;
	ClientPos[2] += StringToFloat(DrawPos);

	//float t_ClientPos[3];
	//t_ClientPos = ClientPos;

	if (StrEqual(DrawColour, "green", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "red", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "blue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "purple", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "yellow", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "orange", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "black", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "brightblue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "darkgreen", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
	else if (StrEqual(DrawColour, "white", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
	else return 0;
	TE_SendToClient(targetClient);
	return 1;
}
stock CreateRingEx(client, float RingAreaSize, char[] DrawColour, float DrawPos, bool IsPulsing = true, float lifetime = 1.0, targetClient = 0) {

	float ClientPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);

	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;

	ClientPos[2] += DrawPos;
	if (StrEqual(DrawColour, "green", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "red", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "blue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "purple", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "yellow", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "orange", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "black", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "brightblue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "darkgreen", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
	else if (StrEqual(DrawColour, "white", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
	else return 0;
	TE_SendToAll();
	return 1;
}























stock CreateLineSolo(client, target, char[] DrawColour, char[] DrawPos, float lifetime = 0.5, targetClient = 0) {

	float ClientPos[3];
	float TargetPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetPos);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	float t_ClientPos[3];
	t_ClientPos = ClientPos;
	float t_TargetPos[3];
	t_TargetPos = TargetPos;

	for (int i = 0; i < DrawColourCount; i++) {

		t_ClientPos = ClientPos;
		t_TargetPos = TargetPos;

		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);
		t_TargetPos[2] += StringToFloat(t_DrawPos[i]);

		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 69, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {132, 112, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {178, 34, 34, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 255, 200}, 50);
		else continue;
		TE_SendToClient(targetClient);
	}
}
stock CreateRingSolo(client, float RingAreaSize, char[] DrawColour, char[] DrawPos, bool IsPulsing = true, float lifetime = 1.0, targetClient, float PosX=0.0, float PosY=0.0, float PosZ=0.0) {

	float ClientPos[3];
	//if (!IsWitch(client) && !IsCommonInfected(client)) GetClientAbsOrigin(client, ClientPos);
	if (client != -1) {

		if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
		else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	}
	else {

		ClientPos[0] = PosX;
		ClientPos[1] = PosY;
		ClientPos[2] = PosZ;
	}

	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;
	//LogMessage("==============\nDraw Colour: %s\n===============", DrawColour);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	ClientPos[2] += 20.0;

	float t_ClientPos[3];
	t_ClientPos = ClientPos;

	for (int i = 0; i < DrawColourCount; i++) {

		t_ClientPos = ClientPos;

		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);

		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
		else continue;
		TE_SendToClient(targetClient);
	}
}

// line 840
stock CreateLine(client, target, char[] DrawColour, char[] DrawPos, float lifetime = 0.5, targetClient = 0) {

	float ClientPos[3];
	float TargetPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetPos);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	float t_ClientPos[3];
	t_ClientPos = ClientPos;
	float t_TargetPos[3];
	t_TargetPos = TargetPos;

	for (int i = 0; i < DrawColourCount; i++) {
		t_ClientPos = ClientPos;
		t_TargetPos = TargetPos;
		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);
		t_TargetPos[2] += StringToFloat(t_DrawPos[i]);
		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 69, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {132, 112, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {178, 34, 34, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 255, 200}, 50);
		else continue;
		TE_SendToAll();
	}
}

stock CreateRing(client, float RingAreaSize, char[] DrawColour, char[] DrawPos, bool IsPulsing = true, float lifetime = 1.0, targetClient = 0, bool ringStartsAtMaxSize = false) {

	float ClientPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);

	float pulserange = (ringStartsAtMaxSize) ? RingAreaSize : (IsPulsing) ? 32.0 : RingAreaSize - 32.0;
	// if (IsPulsing) pulserange = 32.0;
	// else pulserange = RingAreaSize - 32.0;
	//LogMessage("==============\nDraw Colour: %s\n===============", DrawColour);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	float t_ClientPos[3];
	t_ClientPos = ClientPos;

	for (int i = 0; i < DrawColourCount; i++) {
		t_ClientPos = ClientPos;
		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);
		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
		else continue;
		TE_SendToAll();
	}
}

/*stock BeaconCorpsesInRange(client) {

	new Float:ClientPos[3];
	GetClientAbsOrigin(client, ClientPos);
	new Float:Pos[3];

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i) || IsPlayerAlive(i)) continue;
		if (GetVectorDistance(ClientPos, DeathLocation[i]) < 1024.0) {

			Pos[0] = DeathLocation[i][0];
			Pos[1] = DeathLocation[i][1];
			Pos[2] = DeathLocation[i][2] + 40.0;
			TE_SetupBeamRingPoint(Pos, 128.0, 256.0, g_iSprite, g_BeaconSprite, 0, 15, 0.5, 2.0, 0.5, {20, 20, 150, 150}, 50, 0);
			TE_SendToClient(client);
		}
	}
}*/

stock CreateBeacons(client, float Distance) {

	float Pos[3];
	float Pos2[3];

	GetClientAbsOrigin(client, Pos);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClientAlive(i) && i != client && GetClientTeam(i) != GetClientTeam(client)) {

			GetClientAbsOrigin(i, Pos2);
			if (GetVectorDistance(Pos, Pos2) > Distance) continue;

			Pos2[2] += 20.0;
			TE_SetupBeamRingPoint(Pos2, 32.0, 128.0, g_iSprite, g_BeaconSprite, 0, 15, 0.5, 2.0, 0.5, {20, 20, 150, 150}, 50, 0);
			TE_SendToClient(client);
		}
	}
}

stock FrozenPlayer(client, float effectTime = 3.0, amount = 100) {
	if (IsLegitimateClient(client)) {
		if (amount < 0) amount = 0;
		if (amount > 0) {
			if (effectTime > 0.0) {
				CreateTimer(effectTime, Timer_FrozenPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
				SetEntityMoveType(client, MOVETYPE_NONE);
			}
			else if (ISFROZEN[client] == INVALID_HANDLE) {
				ISFROZEN[client] = CreateTimer(0.25, Timer_Freezer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				SetEntityMoveType(client, MOVETYPE_NONE);
			}
		}
		else SetEntityMoveType(client, MOVETYPE_WALK);

		if (!IsFakeClient(client)) {

			int clients[2];
			clients[0] = client;
			UserMsg BlindMsgID = GetUserMessageId("Fade");
			Handle message = StartMessageEx(BlindMsgID, clients, 1);

			BfWriteShort(message, 1536);
			BfWriteShort(message, 1536);
			
			if (amount == 0) BfWriteShort(message, (0x0001 | 0x0010));
			else BfWriteShort(message, (0x0002 | 0x0008));

			BfWriteByte(message, 132);
			BfWriteByte(message, 112);
			BfWriteByte(message, 255);
			BfWriteByte(message, amount);

			EndMessage();
		}	
	}
}

stock EnrageBlind(client, amount=0) {

	if (IsLegitimateClient(client) && !IsFakeClient(client)) {

		int clients[2];
		clients[0] = client;
		UserMsg BlindMsgID = GetUserMessageId("Fade");
		Handle message = StartMessageEx(BlindMsgID, clients, 1);
		BfWriteShort(message, 1536);
		BfWriteShort(message, 1536);
		
		if (amount == 0)
		{
			BfWriteShort(message, (0x0001 | 0x0010));
		}
		else
		{
			BfWriteShort(message, (0x0002 | 0x0008));
		}

		if (amount > 0) {

			BfWriteByte(message, 100);
			BfWriteByte(message, 20);
			BfWriteByte(message, 20);
		}
		else {

			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
		}
		BfWriteByte(message, amount);
		EndMessage();
	}
}

stock BlindPlayer(client, float effectTime = 3.0, amount = 0) {

	if (IsLegitimateClient(client) && !IsFakeClient(client)) {

		int clients[2];
		clients[0] = client;
		UserMsg BlindMsgID = GetUserMessageId("Fade");
		Handle message = StartMessageEx(BlindMsgID, clients, 1);
		BfWriteShort(message, 1536);
		BfWriteShort(message, 1536);
		
		if (amount == 0)
		{
			BfWriteShort(message, (0x0001 | 0x0010));
		}
		else
		{
			BfWriteShort(message, (0x0002 | 0x0008));
		}

		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		
		if (amount > 0) {

			//b_IsBlind[client] = true;
			if (effectTime > 0.0) CreateTimer(effectTime, Timer_BlindPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
			else {

				/*

					Special Commons set an effect time of 0.0.
				*/
				if (ISBLIND[client] == INVALID_HANDLE) ISBLIND[client] = CreateTimer(0.25, Timer_Blinder, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			BfWriteByte(message, amount);
		}
		else {

			//b_IsBlind[client] = false;
			BfWriteByte(message, 0);
		}
		EndMessage();
	}
}

stock CreateFireEx(client) {
	float pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	CreateFire(pos);
}

//static const String:MODEL_PIPEBOMB[] = "models/w_models/weapons/w_eq_pipebomb.mdl;"

static const char MODEL_GASCAN[] = "models/props_junk/gascan001a.mdl";
stock CreateFire(const float BombOrigin[3])
{
	int entity = CreateEntityByName("prop_physics");
	DispatchKeyValue(entity, "physdamagescale", "0.0");
	if (!IsModelPrecached(MODEL_GASCAN))
	{
		PrecacheModel(MODEL_GASCAN);
	}
	DispatchKeyValue(entity, "model", MODEL_GASCAN);
	DispatchSpawn(entity);
	TeleportEntity(entity, BombOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(entity, MOVETYPE_VPHYSICS);
	AcceptEntityInput(entity, "Break");
}

stock bool EnemyCombatantsWithinRange(client, float f_Distance) {

	float d_Client[3];
	float e_Client[3]
	GetClientAbsOrigin(client, d_Client);
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) != GetClientTeam(client)) {

			GetClientAbsOrigin(i, e_Client);
			if (GetVectorDistance(d_Client, e_Client) <= f_Distance) return true;
		}
	}
	return false;
}

stock bool IsTanksActive() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) == ZOMBIECLASS_TANK) return true;
	}
	return false;
}

stock ModifyGravity(client, float g_Gravity = 0.8, float g_Time = 0.0, bool b_Jumping = false) {

	if (IsLegitimateClientAlive(client)) {

		//if (b_IsJumping[client]) return;	// survivors only, for the moon jump ability
		if (b_Jumping) {

			b_IsJumping[client] = true;
			CreateTimer(0.1, Timer_DetectGroundTouch, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (g_Gravity == 0.8) SetEntityGravity(client, g_Gravity);
		else {

			if (g_Gravity > 1.0 && g_Gravity < 100.0) g_Gravity *= 0.01;
			else if (g_Gravity > 1.0 && g_Gravity < 1000.0) g_Gravity *= 0.001;
			else if (g_Gravity > 1.0 && g_Gravity < 10000.0) g_Gravity *= 0.0001;
			g_Gravity = 0.8 - g_Gravity;
			if (g_Gravity < 0.1) g_Gravity = 0.1;
			SetEntityGravity(client, g_Gravity);
		}
		if (g_Gravity < 0.8 && !b_Jumping) CreateTimer(g_Time, Timer_ResetGravity, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock bool OnPlayerRevived(client, targetclient) {

	if (SetTempHealth(client, targetclient, GetMaximumHealth(targetclient) * fHealthSurvivorRevive, true)) return true;
	return false;
}

stock float GetTempHealth(client) {

	return GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
}

stock SetMaximumHealth(client) {
	if (!IsLegitimateClient(client)) return 1;
	int ClientTeam = GetClientTeam(client);

	if (ClientTeam != TEAM_SURVIVOR) return DefaultHealth[client];

	bool playerIsIncapacitated = IsIncapacitated(client);

	//GetAbilityStrengthByTrigger(client, _, "p", _, 0, _, _, "h", _, true, 0, _, _, _, _, true);
	int isRaw = RoundToCeil(GetAbilityStrengthByTrigger(client, client, "p", _, 0, _, _, "H", _, true, 2));			// 2 gets ONLY raw returns
	if (isRaw < 0) isRaw = 0;

	float TheAbilityMultiplier = GetAbilityMultiplier(client, "V");
	//if (TheAbilityMultiplier == -1.0) TheAbilityMultiplier = 0.0;
	if (TheAbilityMultiplier != -1) isRaw += RoundToCeil(isRaw * TheAbilityMultiplier);
	// health values are now only raw values.

	if (!playerIsIncapacitated) {
		float ammoStr = IsClientInRangeSpecialAmmo(client, "O", _, _, isRaw);
		if (ammoStr > 0.0) isRaw += RoundToCeil(isRaw * ammoStr);
	}
	if (isRaw > 30000) isRaw = 30000;
	if (playerIsIncapacitated) DefaultHealth[client] = iDefaultIncapHealth + isRaw;
	else DefaultHealth[client] = iSurvivorBaseHealth + isRaw;

	SetEntProp(client, Prop_Send, "m_iMaxHealth", DefaultHealth[client]);

	if (playerIsIncapacitated && bIsGiveIncapHealth[client]) {
		if (L4D2_GetInfectedAttacker(client) == -1) GiveMaximumHealth(client, RoundToCeil(DefaultHealth[client] * fIncapHealthStartPercentage));
		else GiveMaximumHealth(client, DefaultHealth[client]);
		bIsGiveIncapHealth[client] = false;
	}
	if (GetClientHealth(client) > DefaultHealth[client]) GiveMaximumHealth(client);
	return DefaultHealth[client];
}

stock FindZombieClass(client) {
	if (IsLegitimateClient(client)) {
		if (GetClientTeam(client) == TEAM_SURVIVOR) return 0;
		return GetEntProp(client, Prop_Send, "m_zombieClass");
	}
	if (IsWitch(client)) return 7;
	if (IsCommonInfected(client)) return 9;
	return -1;
}

stock SetInfectedHealth(client, value) {
	if (IsValidEntity(client)) {
		SetConVarInt(FindConVar("z_health"), value);
		SetEntProp(client, Prop_Data, "m_iHealth", value);
		SetEntProp(client, Prop_Data, "m_iMaxHealth", value);
	}
}

stock GetInfectedMaxHealth(entity) {
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}

stock float GetInfectedHealthPercentage(client) {
	float healthRemaining = GetEntProp(client, Prop_Data, "m_iHealth") * 1.0;
	float healthMax = GetEntProp(client, Prop_Data, "m_iMaxHealth") * 1.0;
	return healthRemaining/healthMax;
}

stock GetInfectedHealth(client) {

	return GetEntProp(client, Prop_Data, "m_iHealth");
}

stock SetBaseHealth(client) {

	SetEntProp(client, Prop_Data, "m_iMaxHealth", DefaultHealth[client]);
}

stock GiveMaximumHealth(client, healthOverride = 0) {

	if (IsLegitimateClientAlive(client) && b_IsLoaded[client]) {
		if (healthOverride == 0) healthOverride = GetMaximumHealth(client);

		GetAbilityStrengthByTrigger(client, _, "a");

		if (GetClientTeam(client) == TEAM_INFECTED || !IsIncapacitated(client)) SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
		else SetEntPropFloat(client, Prop_Send, "m_healthBuffer", healthOverride * 1.0);
		
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime() * 1.0);
		SetEntityHealth(client, healthOverride);
	}
}

stock GetMaximumHealth(client)
{
	if (IsLegitimateClient(client)) {

		//return GetEntProp(client, Prop_Send, "m_iMaxHealth");
		int iMaxHealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
		if (iMaxHealth > 30000) return 30000;
		return iMaxHealth;
	}
	else return 0;
}

// This is for active statuses, not buffs/talents/etc.
CheckActiveStatuses(client, char[] sStatus, bool bGetStatus = true, bool bDeleteStatus = false) {

	char text[64];

	int size = GetArraySize(ActiveStatuses[client]);

	for (int i = 0; i < size; i++) {

		GetArrayString(ActiveStatuses[client], i, text, sizeof(text));
		if (StrEqual(sStatus, text)) {

			if (!bDeleteStatus || bGetStatus) return 2;	// 2 - Cannot add status because it is already in effect.
			RemoveFromArray(ActiveStatuses[client], i);
			return 0;									// 0 - means the status was deleted.
		}
	}
	if (!bDeleteStatus && !bGetStatus) {

		PushArrayString(ActiveStatuses[client], sStatus);
		return 1;										// 1 - status inserted
	}
	return -1;											// -1 - status not found.
}

stock CloakingDevice(client) {

	int theresult = CheckActiveStatuses(client, "lunge");

	if (IsLegitimateClientAlive(client) && theresult == -1) {

		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 0);
		//CreateTimer(g_Time, Timer_CloakingDeviceBreakdown, client, TIMER_FLAG_NO_MAPCHANGE);

		CheckActiveStatuses(client, "lunge", false);	// adds the lunge effect to the active statuses.
	}
}

stock AbsorbDamage(client, float s_Strength, damage) {

	if (IsLegitimateClientAlive(client)) {

		if (GetClientTeam(client) == TEAM_INFECTED || !IsIncapacitated(client)) {

			int absorb = RoundToFloor(s_Strength);
			if (absorb > damage) absorb = damage;

			SetEntityHealth(client, GetClientHealth(client) + absorb);
		}
	}
}

stock DamagePlayer(client, victim, float s_Strength) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(victim)) {

		int d_Damage = RoundToFloor(s_Strength);

		if (GetClientHealth(victim) > 1) {

			if (GetClientHealth(victim) + 1 < d_Damage) d_Damage = GetClientHealth(victim) - 1;
			if (d_Damage > 0) {

				DamageAward[client][victim] += d_Damage;
				SetEntityHealth(victim, GetClientHealth(victim) - d_Damage);
			}
		}
	}
}

stock WipeDamageAward(client) {

	for (int i = 1; i <= MaxClients; i++) {

		DamageAward[client][i] = 0;
	}
}

void ReflectDamage(int client, int target, int AttackDamage) {
	int enemytype = -1;
	int enemyteam = -1;
	if (IsSpecialCommon(target)) enemytype = 1;
	else if (IsCommonInfected(target)) enemytype = 0;
	else if (IsWitch(target)) enemytype = 2;
	else if (IsLegitimateClientAlive(target)) {
		enemytype = 3;
		enemyteam = GetClientTeam(target);
	}
	if (enemytype == 1) AddSpecialCommonDamage(client, target, AttackDamage);
	else if (enemytype == 0) AddCommonInfectedDamage(client, target, AttackDamage);
	else if (enemytype == 2) AddWitchDamage(client, target, AttackDamage);
	else if (enemytype == 3 && enemyteam == TEAM_INFECTED) AddSpecialInfectedDamage(client, target, AttackDamage);
	if (enemytype > 0) {
		if (LastAttackedUser[client] == target) ConsecutiveHits[client]++;
		else {
			LastAttackedUser[client] = target;
			ConsecutiveHits[client] = 0;
		}
	}
	if (enemytype < 3 || enemyteam == TEAM_INFECTED) {
		CheckTeammateDamagesEx(client, target, AttackDamage);
	}
	if (iDisplayHealthBars == 1) DisplayInfectedHealthBars(client, target);
}

int CheckTeammateDamagesEx(int client, int target, int TotalDamage, bool bSpellDeath = false, int ammotype = -1, int hitgroup = -1) {
	if (TotalDamage < 1) return 0;
	if (CheckTeammateDamages(target, client) >= 1.0 || CheckTeammateDamages(target, client, true) >= 1.0) {
		char eName[64];
		char cName[64];
		Format(cName, 64, "none");
		GetClientName(client, cName, sizeof(cName));
		char formattedDamage[10];
		AddCommasToString(TotalDamage, formattedDamage, 10);
		
		// new shotgunPelletCount = GetShotgunPelletCount(client);
		// shotgunPelletCount = (shotgunPelletCount > 0) ? TotalDamage * shotgunPelletCount : TotalDamage;
		if (IsLegitimateClient(target)) {
			if (FindZombieClass(target) == ZOMBIECLASS_TANK) {
				GetClientName(target, eName, sizeof(eName));
				PrintToChatAll("%t", "player damage to special", blue, cName, white, orange, eName, white, green, formattedDamage, white);
			}
			//{1}{2} {3}lands the killing blow on {4}{5} {6}for {7}{8} {9}damage

			GetAbilityStrengthByTrigger(client, target, "e", _, TotalDamage, _, _, _, _, _, _, hitgroup);
			GetAbilityStrengthByTrigger(target, client, "E", _, TotalDamage, _, _, _, _, _, _, hitgroup);
			CalculateInfectedDamageAward(target, client);
		}
		else {
			if (IsWitch(target)) {
				Format(eName, sizeof(eName), "%t", "witch");
				PrintToChatAll("%t", "player damage to special", blue, cName, white, orange, eName, white, green, formattedDamage, white);
				GetAbilityStrengthByTrigger(client, target, "witchkill", _, TotalDamage, _, _, _, _, _, _, hitgroup);
				CalculateInfectedDamageAward(target, client);
				OnWitchCreated(target, true);
			}
			else if (IsSpecialCommon(target)) {
				// GetCommonValueAtPos(eName, sizeof(eName), target, SUPER_COMMON_NAME);
				// Format(eName, sizeof(eName), "Common %s", eName);
				// PrintToChatAll("%t", "player damage to special", blue, cName, white, orange, eName, white, green, TotalDamage, white);

				GetAbilityStrengthByTrigger(client, target, "superkill", _, TotalDamage, _, _, _, _, _, _, hitgroup);
				ClearSpecialCommon(target, _, TotalDamage, client);
			}
			else if (IsCommonInfected(target)) {
				GetAbilityStrengthByTrigger(client, target, "C", _, TotalDamage, _, _, _, _, _, _, hitgroup);
				//GetAbilityStrengthByTrigger(client, target, "killcommon", _, TotalDamage, _, _, _, _, _, _, hitgroup);
				CalculateInfectedDamageAward(target, client);

				RollLoot(client, target);
				OnCommonInfectedCreated(target, true, client);
			}
		}
		return TotalDamage;
	}
	return 0;
}

/*stock ReflectDamage(client, victim, Float:g_TalentStrength, d_Damage) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(victim)) {

		new reflectHealth = RoundToFloor(g_TalentStrength);
		new reflectValue = 0;
		if (reflectHealth > d_Damage) reflectHealth = d_Damage;
		if (!IsIncapacitated(client) && IsPlayerAlive(client)) {

			if (GetClientHealth(client) > reflectHealth) reflectValue = reflectHealth;
			else reflectValue = GetClientHealth(client) - 1;
			SetEntityHealth(client, GetClientHealth(client) - reflectValue);
			DamageAward[client][victim] -= reflectValue;
			DamageAward[victim][client] += reflectValue;
		}
	}
}*/

stock SendPanelToClientAndClose(Handle panel, client, MenuHandler:handler, time) {

	SendPanelToClient(panel, client, handler, time);
	CloseHandle(panel);
}

stock CreateAcid(client, victim, float radius = 128.0) {
	if (IsCommonInfected(client) || IsLegitimateClient(client)) {
		if (IsLegitimateClientAlive(victim)) {
			float pos[3];
			if (IsLegitimateClient(victim)) GetClientAbsOrigin(victim, pos);
			else GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 96.0;
			int acidball = CreateEntityByName("spitter_projectile");
			if (IsValidEntity(acidball)) {
				DispatchSpawn(acidball);
				SetEntPropEnt(acidball, Prop_Send, "m_hThrower", client);
				SetEntPropFloat(acidball, Prop_Send, "m_DmgRadius", radius);
				SetEntProp(acidball, Prop_Send, "m_bIsLive", 1);
				TeleportEntity(acidball, pos, NULL_VECTOR, NULL_VECTOR);
				SDKCall(g_hCreateAcid, acidball);
			}
		}
	}
}

stock ForceClientJump(activator, float g_TalentStrength, victim = 0) {

	if (IsLegitimateClient(activator)) {

		if (GetEntityFlags(activator) & FL_ONGROUND || victim > 0 && GetEntityFlags(victim) & FL_ONGROUND) {

			//new attacker = -1;
			//if (GetClientTeam(activator) != TEAM_INFECTED) attacker = L4D2_GetInfectedAttacker(activator);
			//if (attacker == -1 || !IsClientActual(attacker) || GetClientTeam(attacker) != TEAM_INFECTED || (FindZombieClass(attacker) != ZOMBIECLASS_JOCKEY && FindZombieClass(attacker) != ZOMBIECLASS_CHARGER)) attacker = -1;

			float vel[3];
			vel[0] = GetEntPropFloat(activator, Prop_Send, "m_vecVelocity[0]");
			vel[1] = GetEntPropFloat(activator, Prop_Send, "m_vecVelocity[1]");
			vel[2] = GetEntPropFloat(activator, Prop_Send, "m_vecVelocity[2]");
			vel[2] += g_TalentStrength;
			if (victim == 0) TeleportEntity(activator, NULL_VECTOR, NULL_VECTOR, vel);
			else TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);
		}
	}
}

void ActivateAbilityEx(int activator, int target, int d_Damage, char[] Effects, float g_TalentStrength, float g_TalentTime, int victim = 0,
						char[] Trigger = "0", int isRaw = 0, float AoERange = 0.0, char[] secondaryEffects = "-1",
						float secondaryAoERange = 0.0, int hitgroup = -1, char[] secondaryTrigger = "-1", char[] AbilityTriggerIgnore = "none",
						int damagetype = -1, char[] nameOfItemToGivePlayer = "-1", char[] activatorCallAbilityTrigger = "-1", int entityIdToPassThrough = -1, float healthActivationCost = 0.0, char[] targetCallAbilityTrigger = "-1") {
	//return;

	//PrintToChat(activator, "damage %d Effects: %s Strength: %3.2f", d_Damage, Effects, g_TalentStrength);
	// Activator is ALWAYS the person who holds the talent. The TARGET is who the ability ALWAYS activates on.

	/*
		It lags a lot when it has to check the string for a specific substring every single time, so we need to call activateabilityex multiple times for each different effect, instead.
	*/
	if (IsFireDamage(damagetype) || StrEqual(Effects, "d")) return;	// should never happen, but if it does.
	int healthCost = (healthActivationCost <= 0.0) ? 0 : RoundToCeil(healthActivationCost * GetMaximumHealth(activator));
	if (healthCost > 0) SetClientTotalHealth(activator, activator, healthCost);

	if (g_TalentStrength > 0.0) {
		// When a node successfully fires, it can call custom ability triggers.
		if (!StrEqual(secondaryTrigger, "-1")) GetAbilityStrengthByTrigger(activator, target, secondaryTrigger, _, RoundToCeil(g_TalentStrength), _, _, _, _, _, _, hitgroup, _, damagetype);

		// a single node can fire off two effects at maximum. I haven't personally used it to fire off more than one but the option exists.
		if (!StrEqual(secondaryEffects, "-1")) {
			ActivateAbilityEx(activator, target, d_Damage, secondaryEffects, g_TalentStrength, g_TalentTime, victim, Trigger, isRaw, secondaryAoERange, _, _, hitgroup, _, _, damagetype);
		}
		//int activatorTeam = GetClientTeam(activator);

		int iDamage = (isRaw == 1 || d_Damage == 0) ? RoundToCeil(g_TalentStrength) : RoundToCeil(d_Damage * g_TalentStrength);
		int talentStr = RoundToCeil(g_TalentStrength);
		int anyPlayerNotMe = GetAnyPlayerNotMe(target);
		if (StrEqual(Effects, "vampire")) {
			HealPlayer(activator, activator, g_TalentStrength, 'h', true);
		}
		else if (StrEqual(Effects, "createmine")) {
			int numOfEntities = GetArraySize(playerCustomEntitiesCreated);
			ResizeArray(playerCustomEntitiesCreated, numOfEntities+1);
			// 0 - activator
			// 1 - damage
			// 2 - entity
			// 3 - size of mine proximity
			// 4 - how long until this mine auto-explodes?
			// 5 - visual interval, so we know when to show the proximity ring to players.
			SetArrayCell(playerCustomEntitiesCreated, numOfEntities, activator);
			SetArrayCell(playerCustomEntitiesCreated, numOfEntities, RoundToCeil(g_TalentStrength), 1);
			SetArrayCell(playerCustomEntitiesCreated, numOfEntities, entityIdToPassThrough, 2);
			SetArrayCell(playerCustomEntitiesCreated, numOfEntities, AoERange, 3);
			SetArrayCell(playerCustomEntitiesCreated, numOfEntities, GetEngineTime() + 30.0, 4);
			SetArrayCell(playerCustomEntitiesCreated, numOfEntities, 0, 5);
			CreateTimer(0.5, Timer_TickingMine, entityIdToPassThrough, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (StrEqual(Effects, "aoeheal")) {	// testing this version instead of the above for readability.
			CreateAoE(activator, AoERange, (g_TalentStrength < 1.0) ? RoundToCeil(d_Damage * g_TalentStrength) : RoundToCeil(g_TalentStrength), _, _, hitgroup, damagetype, targetCallAbilityTrigger);
		}
		else if (StrEqual(Effects, "ffexplode")) {
			CreatePlayerExplosion(activator, 384.0, RoundToCeil(d_Damage * g_TalentStrength), false);
		}
		// else if (StrEqual(Effects, "noffexplode")) {
		// 	CreatePlayerExplosion(activator, 384.0, (g_TalentStrength < 1.0) ? RoundToCeil(d_Damage * g_TalentStrength) : RoundToCeil(g_TalentStrength));
		// }
		else if (StrEqual(Effects, "poisonclaw")) {
			int acid = RoundToFloor(iDamage * (GetDifficultyRating(victim) * fAcidDamagePlayerLevel));
			AwardExperience(activator, HEXING_CONTRIBUTION, acid);

			acid += acid * (GetClientStatusEffect(victim, "acid") + 1);
			CreateAndAttachFlame(victim, acid, 10.0, 0.5, FindInfectedClient(true), "acid");
		}
		else if (StrEqual(Effects, "burnclaw")) {
			int burn = RoundToFloor(iDamage * (GetDifficultyRating(victim) * fBurnPercentage));
			AwardExperience(activator, HEXING_CONTRIBUTION, burn);

			burn += burn * (GetClientStatusEffect(victim, "burn") + 1);
			CreateAndAttachFlame(victim, burn, 10.0, 0.5, FindInfectedClient(true), "burn");
		}
		else if (StrEqual(Effects, "maghalfempty")) {
			// this goes up here and we're gonna recursively call for "d"
			//ActivateAbilityEx(activator, target, d_Damage, String:Effects[], Float:g_TalentStrength, Float:g_TalentTime, victim = 0, String:Trigger[] = "0")
			char curEquippedWeapon[64];
			int bulletsFired = 0;
			int WeaponId =	GetEntPropEnt(activator, Prop_Data, "m_hActiveWeapon");
			if (IsValidEntity(WeaponId)) {
				int bulletsRemaining = GetEntProp(WeaponId, Prop_Send, "m_iClip1");
				GetEntityClassname(WeaponId, curEquippedWeapon, sizeof(curEquippedWeapon));
				GetTrieValue(currentEquippedWeapon[activator], curEquippedWeapon, bulletsFired);
				if (bulletsFired >= bulletsRemaining) {
					// we only do something if the mag is half or more empty.
					int totalMagSize = bulletsFired + bulletsRemaining;
					float fMagazineExhausted = ((bulletsFired * 1.0)/(totalMagSize * 1.0));

					ActivateAbilityEx(activator, target, d_Damage, secondaryEffects, (fMagazineExhausted * g_TalentStrength), g_TalentTime, victim, Trigger, isRaw, secondaryAoERange, _, _, hitgroup, _, _, damagetype);
				}
			}
		}
		else if (StrEqual(Effects, "parry") && IsLegitimateClientAlive(activator) && IsLegitimateClientAlive(target)) {
			StaggerPlayer(target, (activator == target) ? anyPlayerNotMe : activator);
		}
		else if (StrEqual(Effects, "a") && !HasAdrenaline(target)) SDKCall(g_hEffectAdrenaline, target, g_TalentTime);
		else if (StrEqual(Effects, "A") && GetClientTeam(target) == TEAM_SURVIVOR && b_HasDeathLocation[target]) {

			if (!IsPlayerAlive(target)) {

				SDKCall(hRoundRespawn, target);
				b_HasDeathLocation[target] = false;
				CreateTimer(1.0, Timer_TeleportRespawn, target, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(Effects, "b")) {
			if (!IsLegitimateClient(target) || GetClientTeam(target) == TEAM_SURVIVOR || L4D2_GetSurvivorVictim(target) == -1) BeanBag(target, g_TalentStrength);
		}
		else if (StrEqual(Effects, "c")) CreateAndAttachFlame(target, iDamage, g_TalentTime, 0.5, activator, "burn");
		else if (StrEqual(Effects, "acidburn")) CreateAndAttachFlame(target, iDamage, g_TalentTime, 0.5, activator, "acid");
		else if (StrEqual(Effects, "f") && IsLegitimateClient(target)) CreateFireEx(target);
		else if (StrEqual(Effects, "E")) {

			// Healing based on damage RECEIVED.
			HealPlayer(target, activator, (d_Damage * g_TalentStrength) * 1.0, 'h', true);
		}
		else if (StrEqual(Effects, "e")) CreateBeacons(target, g_TalentStrength);
		else if (StrEqual(Effects, "g")) ModifyGravity(target, g_TalentStrength, g_TalentTime, true);
		else if (StrEqual(Effects, "h")) {
			HealPlayer(target, activator, g_TalentStrength, 'h', true);
		}
		else if (StrEqual(Effects, "u")) {

			HealPlayer(target, activator, g_TalentStrength, 'h', true);
		}
		// the difference is U affects only players not the caster and u affects everyone. we will code a change later on to free this char
		else if (StrEqual(Effects, "U")) {

			if (target != activator && IsLegitimateClientAlive(activator)) {

				HealPlayer(target, activator, g_TalentStrength, 'h', true);
			}
		}
		/*else if (StrEqual(Effects, "H")) {

			//ModifyHealth(target, GetAbilityStrengthByTrigger(activator, activator, 'p', FindZombieClass(activator), d_Damage, _, _, "H"), g_TalentTime);
			//ModifyHealth(target, iDamage * 1.0, g_TalentTime, isRaw);
			SetMaximumHealth(target);
		}*/
		else if (StrEqual(Effects, "i") && IsLegitimateClientAlive(target) && !ISBILED[target]) {
			SDKCall(g_hCallVomitOnPlayer, target, activator, true);
			CreateTimer(15.0, Timer_RemoveBileStatus, target, TIMER_FLAG_NO_MAPCHANGE);
			ISBILED[target] = true;
		}
		else if (StrEqual(Effects, "j")) ForceClientJump(activator, g_TalentStrength, target);
		else if (StrEqual(Effects, "l")) CloakingDevice(target);
		else if (StrEqual(Effects, "m")) DamagePlayer(activator, target, g_TalentStrength);
		// There are 3 different result effects for giving ammo back, depending on the request.
		else if (StrEqual(Effects, "r1bullet")) {	// refund a single bullet. great for heal bullet proficiency.
			GiveAmmoBack(activator, 1 * talentStr, _, activator);
		}
		else if (StrEqual(Effects, "rrbullet")) { // refund a raw amount, not based on magazine size.
			GiveAmmoBack(activator, talentStr, _, activator);
		}
		else if (StrEqual(Effects, "rpbullet")) {
			GiveAmmoBack(activator, _, g_TalentStrength, activator);
		}
		else if (StrEqual(Effects, "aoedamage")) {
			//DealAOEDamage(target, g_TalentStrength, AoERange);
		}
		else if (StrEqual(Effects, "R")) {
			ReflectDamage(activator, target, iDamage);
		}
		else if (StrEqual(Effects, "s")) SlowPlayer(target, g_TalentStrength, g_TalentTime);
		else if (StrEqual(Effects, "speed")) SlowPlayer(target, 1.0 + g_TalentStrength, g_TalentTime);
		else if (StrEqual(Effects, "S")) {

			StaggerPlayer(target, activator);
			//ExecCheatCommand(target, "sm_slap");// this is a workaround but i dont really want the ability in the game anymore. freebies != soulslike
			//char clientname[64];
			//GetClientName(target, clientname, sizeof(clientname));
			//ExecCheatCommand(-1, "sm_slap", clientname);
		}
		else if (StrEqual(Effects, "t")) CreateAcid(activator, target, 512.0);
		else if (StrEqual(Effects, "T")) HealPlayer(target, activator, iDamage * 1.0, 'T');
		else if (StrEqual(Effects, "z")) ZeroGravity(activator, target, g_TalentStrength, g_TalentTime);
		else if (StrEqual(Effects, "revive")) ReviveDownedSurvivor(target, activator);
		else if (StrEqual(Effects, "giveitem") && !StrEqual(nameOfItemToGivePlayer, "-1")) {
			ExecCheatCommand(activator, "give", nameOfItemToGivePlayer);
		}
		if (!StrEqual(activatorCallAbilityTrigger, "-1")) {
			GetAbilityStrengthByTrigger(activator, target, activatorCallAbilityTrigger, _, RoundToCeil(d_Damage * g_TalentStrength), _, _, _, _, _, _, hitgroup, _, damagetype);
		}
		if (activator != target && !StrEqual(targetCallAbilityTrigger, "-1")) {
			GetAbilityStrengthByTrigger(target, activator, targetCallAbilityTrigger, _, RoundToCeil(d_Damage * g_TalentStrength), _, _, _, _, _, _, hitgroup, _, damagetype);
		}
	}
	return;
}

stock GiveAmmoBack(client, rawToReturn = 0, float percentageToReturn = 0.0, activator = 0) {
	if (activator == 0) activator = client;
	int reserveCap = GetWeaponResult(client, 2);
	int reserveRemaining = GetWeaponResult(client, 3);
	int returnAmount = rawToReturn;
	if (rawToReturn == 0 && percentageToReturn > 0.0) {
		returnAmount = RoundToCeil(reserveCap * percentageToReturn);
	}
	if (reserveRemaining == reserveCap) return 0;
	if (reserveRemaining + returnAmount > reserveCap) returnAmount = reserveCap - reserveRemaining;
	if (activator != client) AwardExperience(activator, 2, returnAmount);
	return GetWeaponResult(client, 4, returnAmount);
}

stock bool GetResultByVScript(client, char[] scriptCallByRef, bool printResults = false) {
	int entity = CreateEntityByName("logic_script");
	if (entity >= 0) {
		DispatchSpawn(entity);
		char text[96];
		Format(text, sizeof(text), "Convars.SetValue(\"sm_vscript_res\", \"\" + %s + \"\");", scriptCallByRef);
		SetVariantString(text);
		AcceptEntityInput(entity, "RunScriptCode");
		AcceptEntityInput(entity, "Kill");
		GetConVarString(staggerBuffer, text, sizeof(text));
		SetConVarString(staggerBuffer, "");
		if (StrEqual(text, "true", false)) return true;
	}
	return false;
}

stock bool IsCoveredInBile(client) {
	if (!IsLegitimateClient(client)) return false;
	return (ISBILED[client]) ? true : false;
}

/*stock bool:IsStaggered(client) {
	if (!IsLegitimateClient(client)) {
		// if the client is not a player client
		if (!IsCommonStaggered(client)) return false;
		return true;
	}
	if (SDKCall(g_hIsStaggering, client)) {
		bIsClientCurrentlyStaggered[client] = true;
		return true;
	}
	bIsClientCurrentlyStaggered[client] = false;
	return false;
}*/

public Action Timer_RemoveBileStatus(Handle timer, any client) {
	if (IsLegitimateClient(client)) ISBILED[client] = false;
	return Plugin_Stop;
}
/*void StaggerClient(int userid, const float vPos[3])
{
	static int iScriptLogic = INVALID_ENT_REFERENCE;
	if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
	{
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			LogError("Could not create 'logic_script");

		DispatchSpawn(iScriptLogic);
	}

	char sBuffer[96];
	Format(sBuffer, sizeof(sBuffer), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", userid, RoundFloat(vPos[0]), RoundFloat(vPos[1]), RoundFloat(vPos[2]));
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
	RemoveEntity(iScriptLogic);
}*/

stock StaggerPlayer(target, activator) {
	float pos[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);

	char text[96];
	int ent = CreateEntityByName("logic_script");
	if (ent >= 0) {
		DispatchSpawn(ent);
		Format(text, sizeof(text), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", activator, RoundFloat(pos[0]), RoundFloat(pos[1]), RoundFloat(pos[2]));
		SetVariantString(text);
		AcceptEntityInput(ent, "RunScriptCode");
		AcceptEntityInput(ent, "Kill");
		//PrintToChatAll("%s", text);

		EntityWasStaggered(target, activator);
	}
}

// ???
// stock float GetMagazineRemaining(client, bool bIsPercentage = false) {

// }


/*new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new weaponIndex = GetPlayerWeaponSlot(client, 0);
	
	if(weaponIndex == -1)
		return Plugin_Continue;
	
	new String:classname[64];
	
	GetEdictClassname(weaponIndex, classname, sizeof(classname));
	
	if(StrEqual(classname, "weapon_rifle_m60") || StrEqual(classname, "weapon_grenade_launcher"))
	{
		new iClip1 = GetEntProp(weaponIndex, Prop_Send, "m_iClip1");
		new iPrimType = GetEntProp(weaponIndex, Prop_Send, "m_iPrimaryAmmoType");
		
		if(StrEqual(classname, "weapon_rifle_m60"))
		{
			SetEntProp(client, Prop_Send, "m_iAmmo", ((GetConVarInt(hM60Ammo)+150)-iClip1), _, iPrimType);
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_iAmmo", ((GetConVarInt(hGLAmmo)+1)-iClip1), _, iPrimType);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;


stock bool:CanIReloadTheM60(client) {

	new PlayerWeapon = GetPlayerWeaponSlot(client, 0);
	if (IsValidEntity(PlayerWeapon)) {

		char Classname[64];
		GetEdictClassname(PlayerWeapon, Classname, sizeof(Classname));
		if (StrContains(Classname, "m60", false) != -1) {

			new PlayerAmmo = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
			if (PlayerAmmo < 150) return true;
		}
	}
	return false;
}

stock ReturnClipOnReload(client, activator = -1) {

	if (activator == -1 || !IsLegitimateClient(activator)) activator = client;
	new PlayerWeapon = GetPlayerWeaponSlot(client, 0);	// we only refill primary ammo
	if (!IsValidEntity(PlayerWeapon)) return 0;
	char Classname[64];
	GetEdictClassname(PlayerWeapon, Classname, sizeof(Classname));

	new PlayerAmmo	= GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
	new AmmoType	= GetEntProp(PlayerWeapon, Prop_Send, "m_iPrimaryAmmoType");

	if (StrContains(Classname, "m60", false) != -1) {	// the m60 doesn't have reserve ammo, so we call this differently for the m60

		SetEntProp(PlayerWeapon, Prop_Send, "m_iAmmo", 300 - PlayerAmmo);
	}
	else if (StrContains(Classname, "launcher", false) != -1) {

	}
	else {

	}
	return 1;
}*/

stock RestoreHealBullet(client, bulletsRestored = 1) {

	if (!hasMeleeWeaponEquipped[client]) {

		int WeaponSlot = GetActiveWeaponSlot(client);
		int PlayerWeapon = GetPlayerWeaponSlot(client, WeaponSlot);
		if (PlayerWeapon < 0 || !IsValidEntity(PlayerWeapon)) return;
		int bullets = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
		if (bullets + bulletsRestored < 200) SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", bullets + bulletsRestored);
		else SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 200);
	}
}

stock ModifyPlayerAmmo(target, float g_TalentStrength) {

	int PlayerWeapon = GetPlayerWeaponSlot(target, 0);
	if (!IsValidEntity(PlayerWeapon)) return;

	int PlayerAmmo = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
	//new PlayerMaxAmmo = GetEntProp(PlayerWeapon, Prop_Send, "m_iMaxClip1", 1);
	int PlayerAmmoAward = RoundToCeil(g_TalentStrength * PlayerAmmo);
	PlayerAmmoAward = GetRandomInt(1, PlayerAmmoAward);

	/*

		If the players clip reaches the max, it resets to the default.
	*/
	//new PlayerMaxIncrease = PlayerMaxAmmo + RoundToCeil(PlayerMaxAmmo * g_TalentStrength);
	SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", PlayerAmmo + PlayerAmmoAward, 1);

	//if (PlayerAmmo + PlayerAmmoAward >= PlayerMaxIncrease) SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", PlayerMaxAmmo, 1);
}

stock bool RestrictedWeaponList(char[] WeaponName) {	// Some weapons might be insanely powerful, so we see if they're in this string and don't let them damage multiplier if they are.

	if (StrContains(RestrictedWeapons, WeaponName, false) != -1) return true;
	return false;
}

stock ConfirmExperienceAction(client, bool TheRoundHasEnded = false, bool IsAllowLevelUp = false) {

	if (!IsLegitimateClient(client)) return;

	int ExperienceRequirement = CheckExperienceRequirement(client, _, PlayerLevel[client]);

	if (iIsLevelingPaused[client] == 1 || PlayerLevel[client] >= iMaxLevel) {

		if (ExperienceLevel[client] > ExperienceRequirement) {

			ExperienceOverall[client] -= (ExperienceLevel[client] - ExperienceRequirement);
			ExperienceLevel[client] = ExperienceRequirement;
		}
	}
	if (ExperienceLevel[client] >= ExperienceRequirement && PlayerLevel[client] < iMaxLevel && (iIsLevelingPaused[client] == 0 || IsAllowLevelUp)) {

		char Name[64];
		GetClientName(client, Name, sizeof(Name));
		//else GetSurvivorBotName(client, Name, sizeof(Name));
		int count = 0;
		int MaxLevel = iMaxLevel;

		while (ExperienceLevel[client] >= ExperienceRequirement) {
			ExperienceLevel[client] -= ExperienceRequirement;
			if (PlayerLevel[client] + count <= MaxLevel)	count++;
			if (PlayerLevel[client] + count < MaxLevel) {

				ExperienceRequirement		= CheckExperienceRequirement(client, _, PlayerLevel[client] + count);
			}
			else {

				//ExperienceLevel[client]		= 1;
				ExperienceRequirement		= CheckExperienceRequirement(client, _, MaxLevel);
			}
		}
		if (ExperienceLevel[client] < 1) ExperienceLevel[client] = 1;
		if (count >= 1) {

			if (count > 0) {

				if (PlayerLevel[client] < MaxLevel) {

					PlayerLevel[client] += count;
					UpgradesAwarded[client] += count;
					UpgradesAvailable[client] += count;
					TotalTalentPoints[client] += count;
					if (!IsFakeClient(client)) PrintToChat(client, "%T", "upgrade awarded", client, white, green, orange, white, count);
					PlayerLevelUpgrades[client] = 0;
				}

				if (count == 1) PrintToChatAll("%t", "player level up", green, white, green, Name, PlayerLevel[client]);
				else {
					char formattedLevel[64];
					AddCommasToString(PlayerLevel[client], formattedLevel, sizeof(formattedLevel));
					PrintToChatAll("%t", "player multiple level up", blue, Name, white, green, count, white, blue, formattedLevel);
				}
				FormatPlayerName(client);
			}
			else {

				// experience resets & cartel are awarded, but no level if at cap

				//ExperienceLevel[client] = 1;
			}
			// Whenever a player levels, we also level up talents that have earned enough experience for at least 1 point gain.
			ConfirmExperienceActionTalents(client, _, TheRoundHasEnded);

			bIsSettingsCheck = true;
		}
	}
}

stock ConfirmExperienceActionTalents(client, bool WipeXP = false, bool TheRoundHasEnded = false) {

	if (!IsLegitimateClient(client)) return;
	char Name[64];
	GetClientName(client, Name, sizeof(Name));
	if (WipeXP) {
	
		int WipedExperience = RoundToCeil(ExperienceLevel[client] * fDeathPenalty);
		if (WipedExperience > 1) {

			ExperienceOverall[client] -= WipedExperience;
			ExperienceLevel[client] -= WipedExperience;
			char clientName[64];
			GetClientName(client, clientName, sizeof(clientName));
			char wipedXPAmount[64];
			AddCommasToString(WipedExperience, wipedXPAmount, sizeof(wipedXPAmount));
			PrintToChatAll("%t", "death penalty", blue, orange, green, wipedXPAmount, blue, clientName);
			// a member of your group has died!
			// you have lost x experience!
		}
	}
}

void SetProficiencyData(int client, int proficiencyType, int iLevelsToGive) {
	if (proficiencyType < 0 || proficiencyType > 7) return;
	int iExperienceEarned = 0;
	int curLevel = 0;// GetProficiencyData(client, proficiencyType, _, _, true);
	int targetLevel = iLevelsToGive;
	while (curLevel < targetLevel) {
 		iExperienceEarned += iProficiencyStart + RoundToCeil(iProficiencyStart * (fProficiencyExperienceMultiplier * curLevel));
		curLevel++;
	}
	if (proficiencyType == 0) pistolXP[client] = iExperienceEarned;
	else if (proficiencyType == 1) meleeXP[client] = iExperienceEarned;
	else if (proficiencyType == 2) uziXP[client] = iExperienceEarned;
	else if (proficiencyType == 3) shotgunXP[client] = iExperienceEarned;
	else if (proficiencyType == 4) sniperXP[client] = iExperienceEarned;
	else if (proficiencyType == 5) assaultXP[client] = iExperienceEarned;
	else if (proficiencyType == 6) medicXP[client] = iExperienceEarned;
	else if (proficiencyType == 7) grenadeXP[client] = iExperienceEarned;

	char proficiencyName[64];
	char playerName[64];
	GetClientName(client, playerName, sizeof(playerName));
	if (proficiencyType == 0) Format(proficiencyName, sizeof(proficiencyName), "%t", "pistol proficiency up");
	else if (proficiencyType == 1) Format(proficiencyName, sizeof(proficiencyName), "%t", "melee proficiency up");
	else if (proficiencyType == 2) Format(proficiencyName, sizeof(proficiencyName), "%t", "uzi proficiency up");
	else if (proficiencyType == 3) Format(proficiencyName, sizeof(proficiencyName), "%t", "shotgun proficiency up");
	else if (proficiencyType == 4) Format(proficiencyName, sizeof(proficiencyName), "%t", "sniper proficiency up");
	else if (proficiencyType == 5) Format(proficiencyName, sizeof(proficiencyName), "%t", "assault proficiency up");
	else if (proficiencyType == 6) Format(proficiencyName, sizeof(proficiencyName), "%t", "medic proficiency up");
	else if (proficiencyType == 7) Format(proficiencyName, sizeof(proficiencyName), "%t", "grenade proficiency up");
	PrintToChatAll("%t", "proficiency level up", blue, playerName, white, orange, proficiencyName, white, blue, curLevel);
}

/*
	return types:
	0 - level	1 - experience	2 - experience requirement
*/
stock GetProficiencyData(client, proficiencyType = 0, iExperienceEarned = 0, iReturnType = 0, bGetLevel = false) {
	if (proficiencyType == -1) return 1;
	int proficiencyExperience = pistolXP[client];
	if (proficiencyType == 1) proficiencyExperience = meleeXP[client];
	else if (proficiencyType == 2) proficiencyExperience = uziXP[client];
	else if (proficiencyType == 3) proficiencyExperience = shotgunXP[client];
	else if (proficiencyType == 4) proficiencyExperience = sniperXP[client];
	else if (proficiencyType == 5) proficiencyExperience = assaultXP[client];
	else if (proficiencyType == 6) proficiencyExperience = medicXP[client];
	else if (proficiencyType == 7) proficiencyExperience = grenadeXP[client];

	//PrintToChat(client, "%d %d", proficiencyType, iExperienceEarned);

	/*
		get current level
	*/
	int curLevel = 1;
	if (!bGetLevel) curLevel = GetProficiencyData(client, proficiencyType, _, _, true);
	proficiencyExperience += iExperienceEarned;	// else not necessary as we are passing 0 for iExperienceEarned in curLevel

	int proficiencyLevel = 0;
	int experienceRequirement = iProficiencyStart;
	//new Float:experienceMultiplier = 0.0;
	while (proficiencyExperience >= experienceRequirement) {
		proficiencyExperience -= experienceRequirement;
		proficiencyLevel++;
		experienceRequirement = iProficiencyStart + RoundToCeil(iProficiencyStart * (fProficiencyExperienceMultiplier * proficiencyLevel));
	}
	if (bGetLevel) return proficiencyLevel;
	if (iReturnType == 1) return proficiencyExperience;
	if (iReturnType == 2) return experienceRequirement;
	if (iExperienceEarned > 0) {
		if (proficiencyType == 0) pistolXP[client] += iExperienceEarned;
		else if (proficiencyType == 1) meleeXP[client] += iExperienceEarned;
		else if (proficiencyType == 2) uziXP[client] += iExperienceEarned;
		else if (proficiencyType == 3) shotgunXP[client] += iExperienceEarned;
		else if (proficiencyType == 4) sniperXP[client] += iExperienceEarned;
		else if (proficiencyType == 5) assaultXP[client] += iExperienceEarned;
		else if (proficiencyType == 6) medicXP[client] += iExperienceEarned;
		else if (proficiencyType == 7) grenadeXP[client] += iExperienceEarned;
	}
	if (curLevel < proficiencyLevel) {
		char proficiencyName[64];
		char playerName[64];
		GetClientName(client, playerName, sizeof(playerName));
		if (proficiencyType == 0) Format(proficiencyName, sizeof(proficiencyName), "%t", "pistol proficiency up");
		else if (proficiencyType == 1) Format(proficiencyName, sizeof(proficiencyName), "%t", "melee proficiency up");
		else if (proficiencyType == 2) Format(proficiencyName, sizeof(proficiencyName), "%t", "uzi proficiency up");
		else if (proficiencyType == 3) Format(proficiencyName, sizeof(proficiencyName), "%t", "shotgun proficiency up");
		else if (proficiencyType == 4) Format(proficiencyName, sizeof(proficiencyName), "%t", "sniper proficiency up");
		else if (proficiencyType == 5) Format(proficiencyName, sizeof(proficiencyName), "%t", "assault proficiency up");
		else if (proficiencyType == 6) Format(proficiencyName, sizeof(proficiencyName), "%t", "medic proficiency up");
		else if (proficiencyType == 7) Format(proficiencyName, sizeof(proficiencyName), "%t", "grenade proficiency up");
		PrintToChatAll("%t", "proficiency level up", blue, playerName, white, orange, proficiencyName, white, blue, proficiencyLevel);
	}
	return curLevel;
}

/*stock StrengthValue(client) {

	if (GetRandomInt(1, 100) <= Luck[client]) return GetRandomInt(0, Strength[client]);
	return 0;
}*/

/*stock bool:IsAbilityImmune(owner, client, String:TalentName[]) {

	if (IsLegitimateClient(client)) {

		new a_Size				=	0;
		if (!IsFakeClient(client)) a_Size					=	GetArraySize(a_Database_PlayerTalents[client]);
		else a_Size											=	GetArraySize(a_Database_PlayerTalents_Bots);

		char Name[PLATFORM_MAX_PATH];

		for (new i = 0; i < a_Size; i++) {

			GetArrayString(Handle:a_Database_Talents, i, Name, sizeof(Name));
			if (StrEqual(Name, TalentName)) {

				char t_Cooldown[8];
				GetArrayString(Handle:PlayerAbilitiesImmune[owner][client], i, t_Cooldown, sizeof(t_Cooldown));

				//if (!IsFakeClient(client)) GetArrayString(Handle:PlayerAbilitiesImmune[client], i, t_Cooldown, sizeof(t_Cooldown));
				//else GetArrayString(Handle:PlayerAbilitiesImmune_Bots, i, t_Cooldown, sizeof(t_Cooldown));
				if (StrEqual(t_Cooldown, "1")) return true;
				break;
			}
		}
	}
	return false;
}*/

stock bool SurvivorsBiled() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsCoveredInBile(i)) return true;
	}
	return false;
}

stock SuperCommonsInPlay(char[] Name) {

	int size = GetArraySize(CommonAffixes);
	char text[64];
	int count = 0;
	int ent = -1;
	for (int i = 0; i < size; i++) {
		ent = GetArrayCell(CommonAffixes, i); //GetArrayString(Handle:CommonAffixes, i, text, sizeof(text));
		if (IsValidEntity(ent)) {
			GetEntPropString(ent, Prop_Data, "m_iName", text, sizeof(text));
			if (StrEqual(text, Name)) count++;
		}
	}
	return count;
}

stock bool RollChanceIsSuccessful(client, float rollChance) {
	if (rollChance <= 0.0 || GetRandomInt(1, RoundToCeil(1.0 / rollChance)) == 1) return true;
	return false;
}

/*

	This function is called when a common infected is spawned, and attempts to roll for affixes.
*/
stock CreateCommonAffix(entity) {
	if (iCommonAffixes < 1 || LivingHumanSurvivors() < 1) return 0;
	if (GetArraySize(CommonAffixes) >= GetSuperCommonLimit()) return 0;	// there's a maximum limit on the # of super commons.
	int size = GetArraySize(a_CommonAffixes);
	float RollChance = 0.0;
	char Section_Name[64];
	char AuraEffectCCA[55];
	char ForceName[64];
	char Model[64];
	Format(ForceName, sizeof(ForceName), "none");
	if (GetArraySize(SuperCommonQueue) > 0) {
		GetArrayString(SuperCommonQueue, 0, ForceName, sizeof(ForceName));
		RemoveFromArray(SuperCommonQueue, 0);
	}
	int maxallowed = 1;
	//char iglowColour[3][4];
	//char glowColour[10];
	float ModelSize = 1.0;
	bool SurvivorsAreBiled = SurvivorsBiled();
	for (int i = 0; i < size; i++) {
		CCAKeys				= GetArrayCell(a_CommonAffixes, i, 0);
		CCAValues			= GetArrayCell(a_CommonAffixes, i, 1);
		//if (GetArraySize(AfxSection) < 1 || GetArraySize(AfxKeys) < 1) continue;
		if (GetArrayCell(CCAValues, SUPER_COMMON_REQ_BILED_SURVIVORS) == 1 && !SurvivorsAreBiled) continue;
		maxallowed = GetArrayCell(CCAValues, SUPER_COMMON_MAX_ALLOWED);
		if (maxallowed < 0) maxallowed = 1;
		if (SuperCommonsInPlay(Section_Name) >= maxallowed) continue;
		RollChance = GetArrayCell(CCAValues, SUPER_COMMON_SPAWN_CHANCE);
		if (StrEqual(ForceName, "none", false) && GetRandomInt(1, RoundToCeil(1.0 / RollChance)) > 1) continue;		// == 1 for successful roll
		CCASection			= GetArrayCell(a_CommonAffixes, i, 2);
		GetArrayString(CCASection, 0, Section_Name, sizeof(Section_Name));
		if (!StrEqual(ForceName, "none", false) && !StrEqual(Section_Name, ForceName, false)) continue;
		SetEntPropString(entity, Prop_Data, "m_iName", Section_Name);
		PushArrayCell(CommonAffixes, entity);
		OnCommonCreated(entity);
		//	Now that we've confirmed this common is special, let's go ahead and activate pertinent functions...
		//	Doing some of these, repeatedly, in a timer is a) wasteful and b) crashy. I know, from experience.
		GetArrayString(CCAValues, SUPER_COMMON_AURA_EFFECT, AuraEffectCCA, sizeof(AuraEffectCCA));
		//FormatKeyValue(AuraEffectCCA, sizeof(AuraEffectCCA), CCAKeys, CCAValues, "aura effect?");
		if (StrEqual(AuraEffectCCA, "f", true)) CreateAndAttachFlame(entity, _, _, _, _, "burn");
		ModelSize = GetArrayCell(CCAValues, SUPER_COMMON_MODEL_SIZE);
		if (ModelSize > 0.0) SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelSize);
		GetArrayString(CCAValues, SUPER_COMMON_FORCE_MODEL, Model, sizeof(Model));
		//FormatKeyValue(Model, sizeof(Model), CCAKeys, CCAValues, "force model?");
		if (IsModelPrecached(Model)) SetEntityModel(entity, Model);
		else if (GetArraySize(CommonInfectedQueue) > 0) {
			GetArrayString(CommonInfectedQueue, 0, Model, sizeof(Model));
			if (IsModelPrecached(Model)) SetEntityModel(entity, Model);
			RemoveFromArray(CommonInfectedQueue, 0);
		}
		return 1;		// we only create one affix on a common. maybe we'll allow more down the road.
	}
	return 0;
	// If no special common affix was successful, it's a standard common.

	//ClearArray(Handle:AfxSection);
	//ClearArray(Handle:AfxKeys);
	//ClearArray(Handle:AfxValues);
	//LogMessage("This common remains normal... %d", entity);
}

stock RemoveAllDebuffs(client, char[] debuffName) {
	int size = GetArraySize(EntityOnFire);
	char text[64];
	for (int i = 0; i < size; i++) {
		if (client != GetArrayCell(EntityOnFire, i, 0)) continue;	// client isn't the client owning this debuff
		GetArrayString(EntityOnFireName, i, text, sizeof(text));
		if (!StrEqual(debuffName, text)) continue;
		RemoveFromArray(EntityOnFireName, i);
		RemoveFromArray(EntityOnFire, i);
		size--;
		if (i > 0) i--;
	}
}

/*

		2nd / 3rd args have defaults for use with special common infected.
		When these special commons explode, they can apply custom versions of these flames to players
		and the plugin will check every so often to see if a player has such an entity attached to them.
		If they do, they'll burn. Players can have multiple of these, so it is dangerous.
*/
void CreateAndAttachFlame(int client, int damage = 0, float lifetime = 10.0, float tickInt = 1.0, int owner = -1, char[] DebuffName = "burn", float tickIntContinued = -2.0) {
	if (IsSurvivalMode && IsCommonInfected(client)) {
		OnCommonInfectedCreated(client, true);
		return;
	}
	bool isLegitimate = IsLegitimateClient(client);
	if (isLegitimate) {
		float TheAbilityMultiplier = GetAbilityMultiplier(client, "B");
		if (TheAbilityMultiplier > 0.0) damage += RoundToCeil(damage * TheAbilityMultiplier);
		if (tickIntContinued <= 0.0) tickIntContinued = tickInt;
	}
	/* old code:
	Format(t_EntityOnFire, sizeof(t_EntityOnFire), "%d+%d+%3.2f+%3.2f+%3.2f+%s+%s", client, damage, lifetime, tickInt, tickIntContinued, SteamID, DebuffName);
	PushArrayString(Handle:EntityOnFire, t_EntityOnFire);*/
	int size = GetArraySize(EntityOnFire);
	ResizeArray(EntityOnFire, size + 1);	// we're going to add to the top.
	SetArrayCell(EntityOnFire, size, client, 0);	// structured by blocks (3d array list)
	SetArrayCell(EntityOnFire, size, damage, 1);
	SetArrayCell(EntityOnFire, size, lifetime, 2);
	SetArrayCell(EntityOnFire, size, tickInt, 3);
	SetArrayCell(EntityOnFire, size, tickIntContinued, 4);
	SetArrayCell(EntityOnFire, size, owner, 5);
	ResizeArray(EntityOnFireName, size + 1);	// strings need to be stored in a separate list.
	SetArrayString(EntityOnFireName, size, DebuffName);
	//bNoNewFireDebuff[client] = false;
	if (IsLegitimateClient(client)) DebuffOnCooldown(client, DebuffName, true); // using an array so we can store all the cooldowns in one place. this removes the cooldown.
	if (isLegitimate && StrEqual(DebuffName, "burn", false)) IgniteEntity(client, lifetime);
	//if (StrEqual(DebuffName, "acid", false) && (IsLegitimateClient(client) || damage == 0 && IsCommonInfected(client))) CreateAcid(FindInfectedClient(true), client, 48.0);
	if (damage == 0 && StrEqual(DebuffName, "acid", false) && IsCommonInfected(client)) CreateAcid(FindInfectedClient(true), client, 48.0);
	//}
}

stock RemoveClientStatusEffect(client, char[] EffectName = "all") {
	char text[64];
	if (!IsLegitimateClient(client)) return 0;
	for (int i = 0; i < GetArraySize(EntityOnFire); i++) {
		if (GetArrayCell(EntityOnFire, i, 0) != client) continue;
		if (!StrEqual(EffectName, "all")) {
			GetArrayString(EntityOnFireName, i, text, sizeof(text));
			if (!StrEqual(EffectName, text)) continue;
		}
		RemoveFromArray(EntityOnFire, i);
		RemoveFromArray(EntityOnFireName, i);
		return 1;
	}
	return 0;
}

stock GetClientStatusEffect(client, char[] EffectName = "burn") {
	int Count = 0;
	char TalentName[64];
	if (!IsLegitimateClient(client) || IsFakeClient(client)) return 0;
	for (int i = 0; i < GetArraySize(EntityOnFire); i++) {
		if (GetArrayCell(EntityOnFire, i, 0) != client) continue;
		GetArrayString(EntityOnFireName, i, TalentName, sizeof(TalentName));
		if (!StrEqual(EffectName, TalentName)) continue;
		Count++;
	}
	return Count;
}

/*stock bool:IsClientStatusEffect(client, bool:RemoveIt=false, String:EffectName[] = "burn") {
	char TalentName[64];
	new targetClient = -1;
	if (!IsLegitimateClient(client) || IsFakeClient(client)) return false;	// survivor bots can't be affected by status effects for balance purposes.

	for (new i = 0; i < GetArraySize(Handle:EntityOnFire); i++) {
		targetClient = GetArrayCell(EntityOnFire, i, 5);
		if (client != targetClient) continue;
		GetArrayString(EntityOnFireName, i, TalentName, sizeof(TalentName));
		if (!StrEqual(EffectName, TalentName)) continue;
		if (RemoveIt) {
			RemoveFromArray(Handle:EntityOnFire, i);
			RemoveFromArray(EntityOnFireName, i);
		}
		return true;
	}
	return false;
}*/

stock ClearRelevantData() {

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsClientActual(i) || !IsClientInGame(i)) continue;
		ResetOtherData(i);
	}
	//ClearArray(Handle:WitchList);
}

stock WipeDebuffs(bool IsEndOfCampaign = false, client = -1, bool IsDisconnect = false) {

	if (client == -1) {

		//ResetArray(Handle:CommonInfected);
		ResetArray(WitchList);
		ResetArray(CommonList);

		if (IsEndOfCampaign) {

			ClearArray(EntityOnFire);
			ClearArray(CommonInfectedQueue);
			ClearArray(CommonList);
			Points_Director = 0.0;

			for (int i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClient(i)) Points[i] = 0.0;
			}
		}
	}
	else {

		b_HardcoreMode[client] = false;
		ResetCDImmunity(client);
		EnrageBlind(client, 0);

		if (IsDisconnect) {
			//ClearArray(CommonInfected[client]);
			CleanseStack[client] = 0;
			CounterStack[client] = 0.0;
			MultiplierStack[client] = 0;
			Format(BuildingStack[client], sizeof(BuildingStack[]), "none");

			Points[client] = 0.0;
		}
		b_IsFloating[client] = false;
		if (b_IsActiveRound) {
			b_IsInSaferoom[client] = false;
			bIsInCheckpoint[client] = false;
		}
		else {
			b_IsInSaferoom[client] = true;
			bIsInCheckpoint[client] = true;
		}
		b_IsBlind[client]				= false;
		b_IsImmune[client]				= false;
		b_IsJumping[client]				= false;
		CommonKills[client]				= 0;
		CommonKillsHeadshot[client]		= 0;
		bIsMeleeCooldown[client]			= false;
		shotgunCooldown[client]			= false;
		AmmoTriggerCooldown[client] = false;
		ExplosionCounter[client][0] = 0.0;
		ExplosionCounter[client][1] = 0.0;
		HealingContribution[client] = 0;
		TankingContribution[client] = 0;
		DamageContribution[client] = 0;
		PointsContribution[client] = 0.0;
		HexingContribution[client] = 0;
		BuffingContribution[client] = 0;
		CleansingContribution[client] = 0;
		ResetContributionTracker(client);
		WipeDamageContribution(client);
	}
}

stock ResetContributionTracker(client) {
	ClearArray(playerContributionTracker[client]);
	ResizeArray(playerContributionTracker[client], 4);
	for (int i = 0; i < 4; i++) SetArrayCell(playerContributionTracker[client], i, 0);
}

/*public Action:Timer_QuickscopeCheck(Handle:timer) {
	if (!b_IsActiveRound) {
		ClearArray(quickscopeCheck);
		return Plugin_Stop;
	}
	// format is %d:time for client id, time activated.

}*/

public Action Timer_EntityOnFire(Handle timer) {
	if (!b_IsActiveRound) {
		return Plugin_Stop;
	}
	static Client = 0;
	static damage = 0;
	static Owner = 0;
	static float FlTime = 0.0;
	static float TickInt = 0.0;
	static float TickIntOriginal = 0.0;
	static t_Damage = 0;
	//char t_Delim[2][64];
	static char ModelName[64];
	static DamageShield = 0;
	static char TalentName[64];
	bool IsClientAlive = false;
	bool IsClientSurvivor;
	float ammoStr = 0.0;
	for (int i = 0; i < GetArraySize(EntityOnFire); i++) {
		Client = GetArrayCell(EntityOnFire, i, 0);
		IsClientAlive = IsLegitimateClientAlive(Client);
		IsClientSurvivor = (IsClientAlive && GetClientTeam(Client) == TEAM_SURVIVOR) ? true : false;
		if (!IsCommonInfected(Client) && !IsWitch(Client) && !IsClientAlive) {
			RemoveFromArray(EntityOnFire, i);
			RemoveFromArray(EntityOnFireName, i);
			continue;
		}
		if ((GetEntityFlags(Client) & FL_INWATER)) {
			ExtinguishEntity(Client);
			RemoveFromArray(EntityOnFire, i);
			RemoveFromArray(EntityOnFireName, i);
			continue;
		}
		GetArrayString(EntityOnFireName, i, TalentName, sizeof(TalentName));
		damage = GetArrayCell(EntityOnFire, i, 1);
		FlTime = GetArrayCell(EntityOnFire, i, 2);
		TickInt = GetArrayCell(EntityOnFire, i, 3);
		TickIntOriginal = GetArrayCell(EntityOnFire, i, 4);
		Owner = GetArrayCell(EntityOnFire, i, 5);
		if (Owner != -1) Owner = FindClientByIdNumber(Owner);
		if (TickInt - 0.5 <= 0.0) {
			TickInt = TickIntOriginal;
			t_Damage = RoundToCeil(damage / (FlTime / TickInt));
			//damage -= t_Damage;
			// HERE WE FIND OUT IF THE COMMON OR WITCH OR WHATEVER IS IMMUNE TO THE DAMAGE
			//CODEBEAN
			GetEntPropString(Client, Prop_Data, "m_ModelName", ModelName, sizeof(ModelName));
			if (IsClientSurvivor ||
				!IsSpecialCommonInRangeEx(Client, "jimmy") && StrContains(ModelName, "jimmy", false) == -1 && (Owner > 0 && IsFakeClient(Owner) || !IsSpecialCommonInRange(Client, 't'))) {
				if (IsClientAlive) {
					ammoStr = IsClientInRangeSpecialAmmo(Client, "D", _, _, t_Damage);
					if (ammoStr > 0.0) {
						DamageShield = RoundToCeil(t_Damage * (1.0 - ammoStr));
						if (DamageShield > 0) {
							CombatTime[Client] = GetEngineTime() + fOutOfCombatTime;
							SetClientTotalHealth(Owner, Client, DamageShield);
							AddSpecialInfectedDamage(Client, Owner, DamageShield, true);
						}
					}
					else {
						CombatTime[Client] = GetEngineTime() + fOutOfCombatTime;
						SetClientTotalHealth(Owner, Client, t_Damage);
						AddSpecialInfectedDamage(Client, Owner, t_Damage, true);
					}
				}
				else EntityStatusEffectDamage(Client, t_Damage);
				if (Client != Owner && IsLegitimateClientAlive(Owner) && (!IsLegitimateClient(Client) || GetClientTeam(Client) != GetClientTeam(Owner))) {
					HexingContribution[Owner] += t_Damage;
					GetAbilityStrengthByTrigger(Client, Owner, "L", _, t_Damage);
				}
			}
		}
		if (FlTime - 0.5 <= 0.0 || damage <= 0) {
			RemoveFromArray(EntityOnFire, i);
			RemoveFromArray(EntityOnFireName, i);
			continue;
		}
		SetArrayCell(EntityOnFire, i, damage - t_Damage, 1);
		SetArrayCell(EntityOnFire, i, FlTime - 0.5, 2);
		SetArrayCell(EntityOnFire, i, TickInt - 0.5, 3);
	}
	return Plugin_Continue;
}

stock CreateCombustion(client, float g_Strength, float f_Time)
{
	int entity				= CreateEntityByName("env_fire");
	float loc[3];
	GetClientAbsOrigin(client, loc);

	char s_Strength[64];
	Format(s_Strength, sizeof(s_Strength), "%3.3f", g_Strength);

	DispatchKeyValue(entity, "StartDisabled", "0");
	DispatchKeyValue(entity, "damagescale", s_Strength);
	char s_Health[64];
	Format(s_Health, sizeof(s_Health), "%3.3f", f_Time);

	DispatchKeyValue(entity, "fireattack", "2");
	DispatchKeyValue(entity, "firesize", "128");
	DispatchKeyValue(entity, "health", s_Health);
	DispatchKeyValue(entity, "ignitionpoint", "1");
	DispatchSpawn(entity);

	TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "Enable");
	AcceptEntityInput(entity, "StartFire");
	
	CreateTimer(f_Time, Timer_DestroyCombustion, entity, TIMER_FLAG_NO_MAPCHANGE);
}


// FIX THIS FIRST
stock GetSpecialCommonDamage(damage, client, Effect, victim) {

	/*

		Victim is always a survivor, and is only used to pass to the GetCommonsInRange function which uses their level
		to determine its range of buff.
	*/
	float f_Strength = 1.0;

	float ClientPos[3];
	float fEntPos[3];
	if (!IsLegitimateClient(client)) GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	else GetClientAbsOrigin(client, ClientPos);

	int ent = -1;
	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", Effect);

	char AuraEffectIsh[10];
	for (int i = 0 ; i < GetArraySize(CommonAffixes); i++) {

		ent = GetArrayCell(CommonAffixes, i);
		if (ent == client || !IsSpecialCommon(ent)) continue;
		GetCommonValueAtPos(AuraEffectIsh, sizeof(AuraEffectIsh), ent, SUPER_COMMON_AURA_EFFECT);
		if (StrContains(AuraEffectIsh, EffectT, true) != -1) {

			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntPos);
			
			//	If the damaging common is in range of an entity meeting the specific effect, then we add its effects. In this case, it's damage.
			
			if (IsInRange(fEntPos, ClientPos, GetCommonValueFloatAtPos(ent, SUPER_COMMON_RANGE_MAX))) {
				f_Strength += (GetCommonValueFloatAtPos(ent, SUPER_COMMON_STRENGTH_SPECIAL) * GetEntitiesInRange(ent, victim));
			}
		}
	}
	return RoundToCeil(damage * f_Strength);
}

stock GetEntitiesInRange(client, victim) {
	float ClientPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);

	float AfxRange		= GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_PLAYER_LEVEL) * PlayerLevel[victim];
	float AfxRangeMax	= GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MAX);
	float AfxRangeBase	= GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MIN);
	if (AfxRange + AfxRangeBase > AfxRangeMax) AfxRange = AfxRangeMax;
	else AfxRange += AfxRangeBase;
	float EntPos[3];
	int count = 0;
	//int ent = -1;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED) {
			GetClientAbsOrigin(i, EntPos);
			if (IsInRange(ClientPos, EntPos, AfxRange)) count++;
		}
	}
	return count;
}

stock bool IsSpecialCommonInRangeEx(client, char[] vEntity="none", bool IsAuraEffect = true) {	// false for death effect

	float ClientPos[3];
	float fEntPos[3];
	bool bIsLegitimateClient = IsLegitimateClient(client);
	if (!bIsLegitimateClient) GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	else GetClientAbsOrigin(client, ClientPos);

	int ent = -1;
	//new Effect = 't';
	for (int i = 0; i < GetArraySize(CommonAffixes); i++) {
		ent = GetArrayCell(CommonAffixes, i);
		if (ent == client || !IsCommonInfected(ent)) continue;
		if (!StrEqual(vEntity, "none", false)) {
			if(!CommonInfectedModel(ent, vEntity)) continue;
		}

		/*

			At a certain level, like a lower one, it's just too much having to deal with auras, so some players will absolutely be oblivious to the shit
			going on and killing other players who CAN see them.
		*/
		if (bIsLegitimateClient && PlayerLevel[client] < GetCommonValueIntAtPos(ent, SUPER_COMMON_LEVEL_REQ)) return false;

		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntPos);
		if (IsInRange(fEntPos, ClientPos, GetCommonValueFloatAtPos(ent, SUPER_COMMON_RANGE_MAX))) return true;
	}
	return false;
}

stock bool IsSpecialCommonInRange(client, Effect = -1, vEntity = -1, bool IsAuraEffect = true, infectedTarget = 0) {	// false for death effect

	float ClientPos[3];
	float fEntPos[3];
	bool bIsLegitimateClient = IsLegitimateClient(client);
	if (!bIsLegitimateClient) GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	else GetClientAbsOrigin(client, ClientPos);

	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", Effect);

	char TheAuras[10];
	char TheDeaths[10];

	if (vEntity != -1) {

		GetCommonValueAtPos(TheAuras, sizeof(TheAuras), vEntity, SUPER_COMMON_AURA_EFFECT);
		GetCommonValueAtPos(TheDeaths, sizeof(TheDeaths), vEntity, SUPER_COMMON_DEATH_EFFECT);

		float AfxRange = GetCommonValueFloatAtPos(vEntity, SUPER_COMMON_RANGE_PLAYER_LEVEL);
		//new Float:AfxStrengthLevel = StringToFloat(GetCommonValue(vEntity, "level strength?"));
		float AfxRangeMax = GetCommonValueFloatAtPos(vEntity, SUPER_COMMON_RANGE_MAX);
		//new AfxMultiplication = StringToInt(GetCommonValue(vEntity, "enemy multiplication?"));
		//new AfxStrength = StringToInt(GetCommonValue(vEntity, "aura strength?"));
		//new AfxChain = StringToInt(GetCommonValue(vEntity, "chain reaction?"));
		//new Float:AfxStrengthTarget = StringToFloat(GetCommonValue(vEntity, "strength target?"));
		float AfxRangeBase = GetCommonValueFloatAtPos(vEntity, SUPER_COMMON_RANGE_MIN);
		int AfxLevelReq = GetCommonValueIntAtPos(vEntity, SUPER_COMMON_LEVEL_REQ);

		if (bIsLegitimateClient && GetClientTeam(client) == TEAM_SURVIVOR && PlayerLevel[client] < AfxLevelReq) return false;

		//new Float:SourcLoc[3];
		//new Float:TargetPosition[3];
		//new t_Strength = 0;
		float t_Range = 0.0;

		if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[client] - AfxLevelReq);
		else t_Range = AfxRangeMax;
		if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
		else t_Range += AfxRangeBase;

		if (IsAuraEffect && StrContains(TheAuras, EffectT, true) != -1 || !IsAuraEffect && StrContains(TheDeaths, EffectT, true) != -1) {

			GetEntPropVector(vEntity, Prop_Send, "m_vecOrigin", fEntPos);
			if (IsInRange(fEntPos, ClientPos, AfxRangeMax)) {
				infectedTarget = vEntity;
				return true;
			}
		}
	}
	else {

		int ent = -1;
		for (int i = 0; i < GetArraySize(CommonAffixes); i++) {

			ent = GetArrayCell(CommonAffixes, i);
			
			if (ent == client) continue;
			if (!IsCommonInfected(ent)) {
				RemoveFromArray(CommonAffixes, i);
				continue;
			}
			if (vEntity >= 0 && ent != vEntity) continue;

			GetCommonValueAtPos(TheAuras, sizeof(TheAuras), ent, SUPER_COMMON_AURA_EFFECT);
			GetCommonValueAtPos(TheDeaths, sizeof(TheDeaths), ent, SUPER_COMMON_DEATH_EFFECT);

			/*

				At a certain level, like a lower one, it's just too much having to deal with auras, so some players will absolutely be oblivious to the shit
				going on and killing other players who CAN see them.
			*/
			if (bIsLegitimateClient && PlayerLevel[client] < GetCommonValueIntAtPos(ent, SUPER_COMMON_LEVEL_REQ)) return false;

			if (IsAuraEffect && StrContains(TheAuras, EffectT, true) != -1 || !IsAuraEffect && StrContains(TheDeaths, EffectT, true) != -1) {

				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntPos);
				if (IsInRange(fEntPos, ClientPos, GetCommonValueFloatAtPos(ent, SUPER_COMMON_RANGE_MAX))) {
					infectedTarget = ent;
					return true;
				}
			} 
		}
	}
	return false;
}

/*

	This timer runs 100 times / second. =)
	Overseer of the Common Affixes Program or CAP.
*/

public Action Timer_CommonAffixes(Handle timer) {

	if (!b_IsActiveRound) {

		for (int i = 1; i <= MaxClients; i++) {

			//ClearArray(CommonAffixesCooldown[i]);
			ClearArray(SpecialCommon[i]);
		}
		//ResetArray(Handle:CommonInfected);
		ResetArray(WitchList);
		ResetArray(CommonList);
		ResetArray(CommonAffixes);
		return Plugin_Stop;
	}
	static ent = -1;
	static IsCommonAffixesEnabled = -2;
	if (IsCommonAffixesEnabled == -2) IsCommonAffixesEnabled = iCommonAffixes;
	if (IsCommonAffixesEnabled == 2) {
		for (int zombie = 0; zombie < GetArraySize(CommonAffixes); zombie++) {
			ent = GetArrayCell(CommonAffixes, zombie);
			if (IsCommonInfected(ent)) DrawCommonAffixes(ent);
		}
	}
	// tanks with cloned abilities
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_INFECTED || FindZombieClass(i) != ZOMBIECLASS_TANK) continue;
		if (bIsDefenderTank[i]) {

			// draw defender tank rings
			DrawSpecialInfectedAffixes(i);
		}
	}
	return Plugin_Continue;
}

stock GetCommonVisuals(char[] TheString, TheSize, entity, key = 0, pos = 0) {
	char AffixName[2][64];
	int ent = -1;
	int size = GetArraySize(CommonAffixes);
	for (int i = 0; i < size; i++) {

		//GetArrayString(Handle:CommonAffixes, i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent)) {
			RemoveFromArray(CommonAffixes, i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));
		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) return -1;
		h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
		h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
		if (key == 0) return FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, "draw colour?", _, _, pos);
		else return FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, "draw pos?", _, _, pos);
	}
	Format(TheString, TheSize, "-1");
	return -1;
}

stock GetCommonValueAtPos(char[] TheString, TheSize, entity, valPos, pos = 0, bool incrementNonZeroPos = true) {
	char AffixName[2][64];
	int ent = -1;
	if (pos > 0 && incrementNonZeroPos) pos++;
	int size = GetArraySize(CommonAffixes);
	for (int i = pos; i < size; i++) {

		//GetArrayString(Handle:CommonAffixes, i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent)) {
			RemoveFromArray(CommonAffixes, i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.

		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		//if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		if (ent >= 0) {

			//h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
			h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
			GetArrayString(h_CommonValues, valPos, TheString, TheSize);
			//FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, Key);
			return i;
		}
	}
	Format(TheString, TheSize, "-1");
	return -1;
}

stock GetCommonValueIntAtPos(entity, pos) {
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = GetArraySize(CommonAffixes);
	for (int i = 0; i < size; i++) {

		//GetArrayString(Handle:CommonAffixes, i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent)) {

			RemoveFromArray(CommonAffixes, i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));
		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) continue;//LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		//h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
		h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
		GetArrayString(h_CommonValues, pos, text, sizeof(text));
		return StringToInt(text);
	}
	return -1;
}

stock float GetCommonValueFloatAtPos(entity, pos, char[] Section_Name = "none") {	// can override the section
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = GetArraySize(CommonAffixes);
	for (int i = 0; i < size; i++) {

		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent) || !IsCommonInfected(ent)) {
			RemoveFromArray(CommonAffixes, i);
			i--;
			size--;
			ForceClearSpecialCommon(ent);
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) {
			LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
			RemoveFromArray(CommonAffixes, i);
			i--;
			size--;
			ForceClearSpecialCommon(entity);
			continue;
		}
		else {

			//h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
			h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
			GetArrayString(h_CommonValues, pos, text, sizeof(text));
			return StringToFloat(text);
		}
	}
	return -1.0;
}

stock GetCommonValue(char[] TheString, TheSize, entity, char[] Key, pos = 0, bool incrementNonZeroPos = true) {
	char AffixName[2][64];
	int ent = -1;
	if (pos > 0 && incrementNonZeroPos) pos++;
	int size = GetArraySize(CommonAffixes);
	for (int i = pos; i < size; i++) {

		//GetArrayString(Handle:CommonAffixes, i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent) || !IsCommonInfected(ent)) {
			RemoveFromArray(CommonAffixes, i);
			i--;
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.

		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		//if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		if (ent >= 0) {

			h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
			h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
			FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, Key, _, _, SUPER_COMMON_FIRST_RANDOM_KEY_POS, false);
			return i;
		}
	}
	Format(TheString, TheSize, "-1");
	return -1;
}

stock GetCommonValueInt(entity, char[] Key) {
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = GetArraySize(CommonAffixes);
	for (int i = 0; i < size; i++) {

		//GetArrayString(Handle:CommonAffixes, i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent) || !IsCommonInfected(ent)) {

			RemoveFromArray(CommonAffixes, i);
			i--;
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));
		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) continue;//LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
		h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
		FormatKeyValue(text, sizeof(text), h_CommonKeys, h_CommonValues, Key);
		return StringToInt(text);
	}
	return -1;
}

stock float GetCommonValueFloat(entity, char[] Key, char[] Section_Name = "none") {	// can override the section
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = GetArraySize(CommonAffixes);
	for (int i = 0; i < size; i++) {

		ent = GetArrayCell(CommonAffixes, i);
		if (!IsValidEntity(ent) || !IsCommonInfected(ent)) {
			RemoveFromArray(CommonAffixes, i);
			size--;
			i--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		else {

			h_CommonKeys		= GetArrayCell(a_CommonAffixes, ent, 0);
			h_CommonValues		= GetArrayCell(a_CommonAffixes, ent, 1);
			FormatKeyValue(text, sizeof(text), h_CommonKeys, h_CommonValues, Key);
			return StringToFloat(text);
		}
	}
	return -1.0;
}

stock bool IsInRange(float EntitLoc[3], float TargetLo[3], float AllowsMaxRange, float ModeSize = 1.0) {

	//new Float:ModelSize = 48.0 * ModeSize;
	
	if (GetVectorDistance(EntitLoc, TargetLo) <= (AllowsMaxRange / 2)) return true;
	return false;
}

stock DrawSpecialInfectedAffixes(client, target = -1, float fRange = 256.0) {
	if (target != -1) {
		float clientPos[3];
		float targetPos[3];
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPos);
		for (client = 1; client <= MaxClients; client++) {
			if (client == target || !IsLegitimateClient(client) || FindZombieClass(client) != ZOMBIECLASS_TANK || !bIsDefenderTank[client]) continue;
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPos);
			if (GetVectorDistance(clientPos, targetPos) <= fRange) return 1;
		}
		return 0;
	}
	char AfxDrawColour[10];
	char AfxDrawPos[10];
	if (FindZombieClass(client) == ZOMBIECLASS_TANK) {
		if (bIsDefenderTank[client]) {
			Format(AfxDrawColour, sizeof(AfxDrawColour), "blue:blue");
			Format(AfxDrawPos, sizeof(AfxDrawPos), "20.0:30.0");
		}
	}
	else return 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
		CreateRingSolo(client, fRange, AfxDrawColour, AfxDrawPos, false, 0.25, i);
	}
	return 1;
}

stock DrawCommonAffixes(entity, char[] sForceAuraEffect = "none") {
	char AfxEffect[64];
	char AfxDrawColour[64];
	float AfxRangeMax = -1.0;
	char AfxDrawPos[64];
	int AfxDrawType = -1;

	float EntityPos[3];
	float TargetPos[3];

	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", EntityPos);

	GetCommonValueAtPos(AfxEffect, sizeof(AfxEffect), entity, SUPER_COMMON_AURA_EFFECT);
	AfxRangeMax		= GetCommonValueFloatAtPos(entity, SUPER_COMMON_RANGE_MAX);
	AfxDrawType		= GetCommonValueIntAtPos(entity, SUPER_COMMON_DRAW_TYPE);
	if (AfxDrawType == -1) return;

	int AfxLevelReq = GetCommonValueIntAtPos(entity, SUPER_COMMON_LEVEL_REQ);



	int drawColourPos = 0;
	int drawPosPos = 0;
	while (drawColourPos >= 0 && drawPosPos >= 0) {
		drawColourPos	= GetCommonVisuals(AfxDrawColour, sizeof(AfxDrawColour), entity, 0, drawColourPos);
		drawPosPos		= GetCommonVisuals(AfxDrawPos, sizeof(AfxDrawPos), entity, 1, drawPosPos);
		if (drawColourPos < 0 || drawPosPos < 0) return;
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
			if (GetClientTeam(i) == TEAM_SURVIVOR && PlayerLevel[i] < AfxLevelReq) continue;
			if (AfxDrawType == 0) CreateRingSoloEx(entity, AfxRangeMax, AfxDrawColour, AfxDrawPos, false, 0.25, i);
		}
	}

	

	//Now we execute the effects, after all players have clearly seen them.

	int t_Strength			= 0;
	int AfxStrength			= GetCommonValueIntAtPos(entity, SUPER_COMMON_AURA_STRENGTH);
	int AfxMultiplication	= GetCommonValueIntAtPos(entity, SUPER_COMMON_ENEMY_MULTIPLICATION);
	float AfxStrengthLevel = GetCommonValueFloatAtPos(entity, SUPER_COMMON_LEVEL_STRENGTH);
	
	if (AfxMultiplication == 1) t_Strength = AfxStrength * LivingEntitiesInRange(entity, EntityPos, AfxRangeMax);
	else t_Strength = AfxStrength;

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || PlayerLevel[i] < AfxLevelReq) continue;
		GetClientAbsOrigin(i, TargetPos);

		// Player is outside the applicable range.
		if (!IsInRange(EntityPos, TargetPos, AfxRangeMax)) continue;

		if (AfxStrengthLevel > 0.0) t_Strength += RoundToCeil(t_Strength * (PlayerLevel[i] * AfxStrengthLevel));

		//If they are not immune to the effects, we consider the effects.
		
		if (StrContains(AfxEffect, "d", true) != -1) {

			//if (t_Strength > GetClientHealth(i)) IncapacitateOrKill(i);
			//else SetEntityHealth(i, GetClientHealth(i) - t_Strength);
			SetClientTotalHealth(entity, i, t_Strength);
		}
		if (StrContains(AfxEffect, "l", true) != -1) {


			//	We don't want multiple blinders to spam blind a player who is already blind.
			//	Furthermore, we don't want it to accidentally blind a player AFTER it dies and leave them permablind.

			//	ISBLIND is tied a timer, and when the timer reverses the blind, it will close the handle.
			if (ISBLIND[i] == INVALID_HANDLE) BlindPlayer(i, 0.0, 255);
		}
		if (StrContains(AfxEffect, "r", true) != -1) {

			//

			//	Freeze players, teleport them up a lil bit.

			//
			if (ISFROZEN[i] == INVALID_HANDLE) FrozenPlayer(i, 0.0);
		}
	}
}

stock LivingEntitiesInRangeByType(client, float effectRange, targetTeam = 0) {
	int count = 0;
	int target = 0;
	float ClientPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	float TargetPos[3];
	if (targetTeam >= 3) {	// 3 survivor, 4 infected
		for (int i = 1; i <= MaxClients; i++) {
			if (i == client) continue;
			if (!IsLegitimateClientAlive(i)) continue;
			if (GetClientTeam(i) + 1 != targetTeam) continue;

			GetClientAbsOrigin(i, TargetPos);
			if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
			count++;
		}
	}
	else if (targetTeam <= 1) { // special commons
		// for (new i = 0; i < GetArraySize(Handle:CommonAffixes); i++) {
		// 	target = GetArrayCell(CommonAffixes, i);
		// 	GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);
		// 	if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
		// 	count++;
		// }
		for (int i = 0; i < GetArraySize(CommonInfected[client]); i++) {
			int common = GetArrayCell(CommonInfected[client], i);
			if (!IsCommonInfected(common)) continue;
			GetEntPropVector(common, Prop_Send, "m_vecOrigin", TargetPos);
			if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
			count++;
		}
	}
	else if (targetTeam == 2) { // witches
		for (int i = 0; i < GetArraySize(WitchList); i++) {
			target = GetArrayCell(WitchList, i);
			if (!IsWitch(target)) continue;

			GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);
			if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
			count++;
		}
	}
	return count;
}

stock LivingEntitiesInRange(entity, float SourceLoc[3], float EffectRange, targetType = 0) {

	int count = 0;
	float Pos[3];
	if (targetType != 1) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClientAlive(i)) {
				if (targetType != 4) {
					if (targetType == 2 && GetClientTeam(i) != TEAM_SURVIVOR) continue;
					else if (targetType == 3 && GetClientTeam(i) != TEAM_INFECTED) continue;
				}

				GetClientAbsOrigin(i, Pos);
				if (!IsInRange(SourceLoc, Pos, EffectRange)) continue;
				count++;
			}
		}
	}
	//new ent = -1;
	//if (targetType <= 1) {
		// new survivor = FindClientOnSurvivorTeam();
		// if (survivor > 0) {
		// 	new size = GetArraySize(CommonInfected[survivor]);
		// 	for (new i = 0; i < size; i++) {
		// 		new ent = GetArrayCell(CommonInfected[survivor], i);
		// 		if (!IsCommonInfected(ent) || ent == entity) continue;
		// 		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", Pos);
		// 		if (GetVectorDistance(SourceLoc, Pos) > EffectRange) continue;
		// 		count++;
		// 	}
		// }
		// for (new i = 0; i < GetArraySize(Handle:CommonAffixes); i++) {
		// 	ent = GetArrayCell(Handle:CommonAffixes, i);
		// 	if (!IsCommonInfected(ent)) continue;
		// 	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", Pos);
		// 	if (!IsInRange(SourceLoc, Pos, EffectRange)) continue;
		// 	count++;
		// }
	//}
	return count;
}

stock bool IsAbilityCooldown(client, char[] TalentName) {

	int a_Size				=	0;
	a_Size					=	GetArraySize(a_Database_PlayerTalents[client]);
	if (GetArraySize(PlayerAbilitiesCooldown[client]) != a_Size) ResizeArray(PlayerAbilitiesCooldown[client], a_Size);
	char Name[PLATFORM_MAX_PATH];
	char t_Cooldown[8];
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_Database_Talents, i, Name, sizeof(Name));
		if (StrEqual(Name, TalentName)) {
			GetArrayString(PlayerAbilitiesCooldown[client], i, t_Cooldown, sizeof(t_Cooldown));
			if (StrEqual(t_Cooldown, "1")) return true;
			break;
		}
	}
	return false;
}

stock GetTalentNameAtMenuPosition(client, pos, char[] TheString, stringSize) {
	TalentAtMenuPositionSection[client] = GetArrayCell(a_Menu_Talents, pos, 2);
	GetArrayString(TalentAtMenuPositionSection[client], 0, TheString, stringSize);
}

stock GetMenuPosition(client, char[] TalentName) {
	int size						=	GetArraySize(a_Menu_Talents);
	char Name[PLATFORM_MAX_PATH];
	for (int i = 0; i < size; i++) {
		MenuPosition[client]				= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(MenuPosition[client], 0, Name, sizeof(Name));
		if (StrEqual(Name, TalentName)) return i;
	}
	return -1;
}


stock GetTalentPosition(client, char[] TalentName) {
	int pos = -1;
	int a_Size				=	0;
	a_Size					=	GetArraySize(a_Database_PlayerTalents[client]);
	char Name[PLATFORM_MAX_PATH];
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_Database_Talents, i, Name, sizeof(Name));
		if (StrEqual(Name, TalentName)) return i;
	}
	return pos;
}

stock RemoveImmunities(client) {

	// We remove all immunities when a round ends, otherwise they may not properly remove and then players become immune, forever.
	int size = 0;
	if (client == -1) {

		size = GetArraySize(PlayerAbilitiesCooldown_Bots);
		for (int i = 0; i < size; i++) {

			//SetArrayString(PlayerAbilitiesImmune_Bots, i, "0");
			SetArrayString(PlayerAbilitiesCooldown_Bots, i, "0");
		}
		for (int i = 1; i <= MAXPLAYERS; i++) {

			RemoveImmunities(i);
		}
	}
	else {

		size = GetArraySize(PlayerAbilitiesCooldown[client]);
		for (int i = 0; i < size; i++) {

			//SetArrayString(PlayerAbilitiesImmune[client], i, "0");
			SetArrayString(PlayerAbilitiesCooldown[client], i, "0");
		}
	}
}

/*stock CreateImmune(activator, client, pos, Float:f_Cooldown) {

	if (IsLegitimateClient(client)) {

		//if (!IsFakeClient(client)) SetArrayString(PlayerAbilitiesImmune[client], pos, "1");
		//else SetArrayString(PlayerAbilitiesImmune_Bots, pos, "1");
		SetArrayString(PlayerAbilitiesImmune[client][activator], pos, "1");

		new Handle:packy;
		CreateDataTimer(f_Cooldown, Timer_RemoveImmune, packy, TIMER_FLAG_NO_MAPCHANGE);
		if (IsFakeClient(client)) client = -1;
		WritePackCell(packy, client);
		WritePackCell(packy, pos);
		WritePackCell(packy, activator);
	}
}*/

stock GetAimTargetPosition(client, float TargetPos[3], char[] hitgroup, int size) {
	float ClientEyeAngles[3];
	float ClientEyePosition[3];
	GetClientEyeAngles(client, ClientEyeAngles);
	GetClientEyePosition(client, ClientEyePosition);
	int aimTarget = 0;

	Handle trace = TR_TraceRayFilterEx(ClientEyePosition, ClientEyeAngles, MASK_SHOT, RayType_Infinite, TraceRayIgnoreSelf, client);
	if (TR_DidHit(trace)) {
		aimTarget = TR_GetEntityIndex(trace);
		if (IsCommonInfected(aimTarget) || IsWitch(aimTarget) || IsLegitimateClient(aimTarget)) {
			GetEntPropVector(aimTarget, Prop_Send, "m_vecOrigin", TargetPos);
			Format(hitgroup, size, "%d", TR_GetHitGroup(trace));
		}
		else {
			aimTarget = -1;
			TR_GetEndPosition(TargetPos, trace);
		}
	}
	CloseHandle(trace);
	return aimTarget;
}

stock bool ClientsWithinRange(client, target, float fDistance = 96.0) {
	float clientPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPos);
	float targetPos[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPos);

	if (GetVectorDistance(clientPos, targetPos) <= fDistance) return true;
	return false;
}

// GetTargetOnly is set to true only when casting single-target spells, which require an actual target.
stock GetClientAimTargetEx(client, char[] TheText, TheSize, bool GetTargetOnly = false) {

	float ClientEyeAngles[3];
	float ClientEyePosition[3];
	float ClientLookTarget[3];

	GetClientEyeAngles(client, ClientEyeAngles);
	GetClientEyePosition(client, ClientEyePosition);

	Handle trace = TR_TraceRayFilterEx(ClientEyePosition, ClientEyeAngles, MASK_SHOT, RayType_Infinite, TraceRayIgnoreSelf, client);

	if (TR_DidHit(trace)) {

		int Target = TR_GetEntityIndex(trace);
		if (GetTargetOnly) {

			if (IsLegitimateClientAlive(Target)) Format(TheText, TheSize, "%d", Target);
			else Format(TheText, TheSize, "-1");
		}
		else {

			TR_GetEndPosition(ClientLookTarget, trace);
			Format(TheText, TheSize, "%3.3f %3.3f %3.3f", ClientLookTarget[0], ClientLookTarget[1], ClientLookTarget[2]);
		}
	}
	CloseHandle(trace);
}

public bool TraceRayIgnoreSelf(entity, mask, any client) {
	
	if (entity < 1 || entity == client) return false;
	return true;
}

stock GetAbilityDataPosition(client, pos) {
	for (int i = 0; i < GetArraySize(PlayActiveAbilities[client]); i++) {
		if (GetArrayCell(PlayActiveAbilities[client], i, 0) == pos) return i;
	}
	return -1;
}

public Action Timer_SpecialAmmoData(Handle timer, any client) {

	if (!b_IsActiveRound || !IsLegitimateClient(client) || !bTimersRunning[client]) {
		return Plugin_Stop;
	}
	if (GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Continue;
	float EntityPos[3];
	char TalentInfo[4][512];
	int dataClient = 0;
	float f_TimeRemaining = 0.0;
	int WorldEnt = -1;
	//new ent = -1;
	int drawtarget = -1;
	char DataAmmoEffect[10];
	float AmmoStrength = 0.0;
	int auraMenuPosition = 0;
	bool IsPlayerSameTeam;
	int dataAmmoType = 0;
	int bulletStrength = 0;
	float fVisualDelay = 0.0;
	int numOfStatusEffects = GetClientStatusEffect(client);
	float ammoStr = 0.0;
	CheckActiveAbility(client, -1, _, _, true);	// draws effects for any active ability this client has.
	for (int i = 0; i < GetArraySize(SpecialAmmoData); i++) {
		dataClient = FindClientByIdNumber(GetArrayCell(SpecialAmmoData, i, 7));
		WorldEnt = GetArrayCell(SpecialAmmoData, i, 9);
		// if (!IsLegitimateClientAlive(dataClient)) {
		// 	RemoveFromArray(Handle:SpecialAmmoData, i);
		// 	if (WorldEnt > 0 && IsValidEntity(WorldEnt)) AcceptEntityInput(WorldEnt, "Kill");
		// 	continue;
		// }

		AmmoStrength = 0.0;
		dataAmmoType = 0;
		bulletStrength = 0;
		drawtarget = GetArrayCell(SpecialAmmoData, i, 11);
		//Format(DataAmmoEffect, sizeof(DataAmmoEffect), "0");	// reset it after each go.
		
		//TalentInfo[0] = TalentName of ammo.
		//TalentInfo[1] = Talent Strength (so use StringToInt)
		//TalentInfo[2] = Talent Damage
		//TalentInfo[3] = Talent Interval
		
		GetTalentNameAtMenuPosition(client, GetArrayCell(SpecialAmmoData, i, 3), TalentInfo[0], sizeof(TalentInfo[]));
		GetSpecialAmmoEffect(DataAmmoEffect, sizeof(DataAmmoEffect), client, TalentInfo[0]);
		if (StrEqual(DataAmmoEffect, "x", true)) dataAmmoType = 1;
		else if (StrEqual(DataAmmoEffect, "h", true)) dataAmmoType = 2;
		else if (StrEqual(DataAmmoEffect, "F", true)) dataAmmoType = 3;
		else if (StrEqual(DataAmmoEffect, "b", true)) dataAmmoType = 4;
		else if (StrEqual(DataAmmoEffect, "a", true)) dataAmmoType = 5;
		else if (StrEqual(DataAmmoEffect, "H", true)) dataAmmoType = 6;
		else if (StrEqual(DataAmmoEffect, "B", true)) dataAmmoType = 7;
		else if (StrEqual(DataAmmoEffect, "C", true)) dataAmmoType = 8;
		
		bulletStrength = GetArrayCell(SpecialAmmoData, i, 5);
		if (dataClient == client) {	// if this player is the owner of this spell or talent...
			if (IsSpellAnAura(client, TalentInfo[0])) {
				GetClientAbsOrigin(client, EntityPos);
				// update the location of the ammo/spell/whatever
				SetArrayCell(SpecialAmmoData, i, EntityPos[0], 0);
				SetArrayCell(SpecialAmmoData, i, EntityPos[1], 1);
				SetArrayCell(SpecialAmmoData, i, EntityPos[2], 2);
				fVisualDelay = GetArrayCell(SpecialAmmoData, i, 13);
				fVisualDelay -= fSpecialAmmoInterval;
				if (fVisualDelay > 0.0) SetArrayCell(SpecialAmmoData, i, fVisualDelay, 13);
				else {
					SetArrayCell(SpecialAmmoData, i, GetArrayCell(SpecialAmmoData, i, 12), 13);
					auraMenuPosition = GetMenuPosition(client, TalentInfo[0]);
					for (int ii = 1; ii <= MaxClients; ii++) {
						if (!IsLegitimateClient(ii) || IsFakeClient(ii)) continue;
						DrawSpecialAmmoTarget(ii, auraMenuPosition, EntityPos[0], EntityPos[1], EntityPos[2], fSpecialAmmoInterval, client, TalentInfo[0], drawtarget);
					}
				}
			}
			else {
				EntityPos[0] = GetArrayCell(SpecialAmmoData, i, 0);
				EntityPos[1] = GetArrayCell(SpecialAmmoData, i, 1);
				EntityPos[2] = GetArrayCell(SpecialAmmoData, i, 2);
			}
			f_TimeRemaining = GetArrayCell(SpecialAmmoData, i, 8);
			f_TimeRemaining -= fSpecialAmmoInterval;
			if (f_TimeRemaining <= 0.0) {
				RemoveFromArray(SpecialAmmoData, i);
				if (IsValidEntity(WorldEnt)) AcceptEntityInput(WorldEnt, "Kill");
				continue;
			}
			// Anything that was changed needs to be reinserted.
			SetArrayCell(SpecialAmmoData, i, f_TimeRemaining, 8);
			if (iStrengthOnSpawnIsStrength != 1) SetArrayCell(SpecialAmmoData, i, GetSpecialAmmoStrength(client, TalentInfo[0], 1), 10);

			if (dataAmmoType == 1) CreateAmmoExplosion(client, EntityPos[0], EntityPos[1], EntityPos[2]);
			// if (dataAmmoType >= 1 && dataAmmoType <= 3) {
			// 	for (new zombie = 0; zombie < GetArraySize(Handle:CommonInfected); zombie++) {
			// 		ent = GetArrayCell(Handle:CommonInfected, zombie);
			// 		if (IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, _, i) == -2.0) {
			// 			AmmoStrength			= (IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, false, _, bulletStrength * 1.0)) * bulletStrength;
			// 			if (AmmoStrength <= 0.0) continue;

			// 			if (dataAmmoType == 1) ExplosiveAmmo(ent, RoundToCeil(AmmoStrength), client);
			// 			else if (dataAmmoType == 2) LeechAmmo(ent, RoundToCeil(AmmoStrength), client);
			// 			else if (dataAmmoType == 3) DoBurn(client, ent, RoundToCeil(AmmoStrength));
			// 		}
			// 	}
			// }
		}
		ammoStr = IsClientInRangeSpecialAmmo(client, DataAmmoEffect, _, _, bulletStrength);
		if (ammoStr > 0.0) {
			IsPlayerSameTeam = (client == dataClient || GetClientTeam(client) == GetClientTeam(dataClient)) ? true : false;

			AmmoStrength			= ammoStr * bulletStrength;
			//if (AmmoStrength <= 0.0) continue;

			if (!IsPlayerSameTeam) {	// the owner of the ammo and the player inside of it are NOT on the same team.
				if (dataAmmoType == 1) ExplosiveAmmo(client, RoundToCeil(AmmoStrength), dataClient);
				else if (dataAmmoType == 2) LeechAmmo(client, RoundToCeil(AmmoStrength), dataClient);
				else if (dataAmmoType == 3) {
					if (ISEXPLODE[client] == INVALID_HANDLE) CreateAndAttachFlame(client, RoundToCeil(AmmoStrength), f_TimeRemaining, f_TimeRemaining, dataClient);
					else CreateAndAttachFlame(client, RoundToCeil(AmmoStrength * TheScorchMult), f_TimeRemaining, f_TimeRemaining, dataClient);
				}
				else if (dataAmmoType == 4) BeanBagAmmo(client, AmmoStrength, dataClient);
			}
			else {
				if (dataAmmoType == 5 && !HasAdrenaline(client)) SetAdrenalineState(client, f_TimeRemaining);
				else if (dataAmmoType == 6) HealingAmmo(client, RoundToCeil(AmmoStrength), dataClient);
				else if (dataAmmoType == 7 && !ISBILED[client]) {
					SDKCall(g_hCallVomitOnPlayer, client, dataClient, true);
					CreateTimer(20.0, Timer_RemoveBileStatus, client, TIMER_FLAG_NO_MAPCHANGE);
					ISBILED[client] = true;
				}
				else if (dataAmmoType == 8 && numOfStatusEffects > 0) RemoveClientStatusEffect(client); //TransferStatusEffect(client, dataClient);
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_StartPlayerTimers(Handle timer) {
	if (!b_IsActiveRound) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		if (bTimersRunning[i] || !b_IsLoaded[i]) continue;
		bTimersRunning[i] = true;
		CreateTimer(fSpecialAmmoInterval, Timer_AmmoActiveTimer, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(fSpecialAmmoInterval, Timer_SpecialAmmoData, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(fDrawHudInterval, Timer_ShowHUD, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(fSpecialAmmoInterval, Timer_ShowActionBar, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action Timer_ShowActionBar(Handle timer, any client) {
	if (!b_IsActiveRound || !IsLegitimateClient(client)) return Plugin_Stop;
	if (GetClientTeam(client) == TEAM_SPECTATOR || IsFakeClient(client)) return Plugin_Continue;

	if (!bIsHideThreat[client]) SendPanelToClientAndClose(ShowThreatMenu(client), client, ShowThreatMenu_Init, 1); //ShowThreatMenu(i);
	else if (DisplayActionBar[client]) ShowActionBar(client);
	return Plugin_Continue;
}

// public Action Timer_ShowActionBar(Handle timer) {
// 	if (!b_IsActiveRound) return Plugin_Stop;
// 	for (int i = 1; i <= MaxClients; i++) {
// 		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
// 		if (!bIsHideThreat[i]) SendPanelToClientAndClose(ShowThreatMenu(i), i, ShowThreatMenu_Init, 1); //ShowThreatMenu(i);
// 		else if (DisplayActionBar[i]) ShowActionBar(i);
// 	}
// 	return Plugin_Continue;
// }

public Action Timer_AmmoActiveTimer(Handle timer, any client) {

	if (!b_IsActiveRound || !IsLegitimateClient(client) || !bTimersRunning[client]) {
		bTimersRunning[client] = false;
		ClearArray(PlayerActiveAmmo[client]);
		ClearArray(PlayActiveAbilities[client]);
		ClearArray(playerLootOnGround[client]);
		return Plugin_Stop;
	}
	if (GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Continue; 
	bHasWeakness[client] = PlayerHasWeakness(client);
	//SortThreatMeter();
	char result[64];
	//new currTalentStrength = 0;
	float talentTimeRemaining = 0.0;
	int triggerRequirementsAreMet = 0;
	if (bJumpTime[client]) JumpTime[client] += fSpecialAmmoInterval;
	if (fOnFireDebuff[client] > 0.0) {
		fOnFireDebuff[client] -= fSpecialAmmoInterval;
		if (fOnFireDebuff[client] <= 0.0) fOnFireDebuff[client] = -1.0;
	}
	// if (!IsFakeClient(client)) {
	// 	if (!bIsHideThreat[client]) SendPanelToClientAndClose(ShowThreatMenu(client), client, ShowThreatMenu_Init, 1); //ShowThreatMenu(i);
	// 	else if (DisplayActionBar[client]) ShowActionBar(client);
	// }
	// timer for the cooldowns of anything on the action bar (ammos, abilities)
	int size = GetArraySize(PlayerActiveAmmo[client]);
	if (size > 0) {
		for (int i = 0; i < size; i++) {
			talentTimeRemaining = GetArrayCell(PlayerActiveAmmo[client], i, 1);
			if (talentTimeRemaining - fSpecialAmmoInterval <= 0.0) {
				RemoveFromArray(PlayerActiveAmmo[client], i);
				size--;
				if (i > 0) i--;
				continue;
			}
			SetArrayCell(PlayerActiveAmmo[client], i, talentTimeRemaining - fSpecialAmmoInterval, 1);
		}
	}
	size = GetArraySize(PlayActiveAbilities[client]);
	for (int i = 0; i < size; i++) {
		GetTalentNameAtMenuPosition(client, GetArrayCell(PlayActiveAbilities[client], i, 0), result, sizeof(result));
		// currTalentStrength = GetTalentStrength(client, result);
		// if (currTalentStrength < 1) {
		// 	RemoveFromArray(PlayActiveAbilities[client], i);
		// 	continue;
		// }
		talentTimeRemaining = GetArrayCell(PlayActiveAbilities[client], i, 1);
		triggerRequirementsAreMet = GetArrayCell(PlayActiveAbilities[client], i, 2);
		if (triggerRequirementsAreMet == 1 && !IsAbilityActive(client, result) && IsAbilityActive(client, result, fSpecialAmmoInterval)) {
			CallAbilityCooldownAbilityTrigger(client, result, true);
		}
		if (talentTimeRemaining - fSpecialAmmoInterval <= 0.0) {
			if (triggerRequirementsAreMet == 1) CallAbilityCooldownAbilityTrigger(client, result);
			RemoveFromArray(PlayActiveAbilities[client], i);
			size--;
			if (i > 0) i--;	// all the data shifts down by 1 when we remove an ability, so if we can shift i down by 1, we do.
		}
		else {
			SetArrayCell(PlayActiveAbilities[client], i, talentTimeRemaining - fSpecialAmmoInterval, 1);
		}
	}
	return Plugin_Continue;
}

stock bool BotsOnSurvivorTeam() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		return true;
	}
	return false;
}

stock bool SetActiveAbilityConditionsMet(client, char[] TalentName, bool GetIfConditionIsAlreadyMet = false) {

	int size = GetArraySize(PlayActiveAbilities[client]);
	int areConditionsMet = 0;
	//char text[64];
	char result[3][64];
	for (int i = 0; i < size; i++) {
		GetTalentNameAtMenuPosition(client, GetArrayCell(PlayActiveAbilities[client], i, 0), result[0], sizeof(result[]));
		if (!StrEqual(result[0], TalentName)) continue;
		areConditionsMet = GetArrayCell(PlayActiveAbilities[client], i, 2);
		if (GetIfConditionIsAlreadyMet) {
			if (areConditionsMet == 1) return true;
			return false;
		}
		if (areConditionsMet == 1) return true;
		SetArrayCell(PlayActiveAbilities[client], i, 1, 2);	// sets conditions met to true.
		return true;
	}
	return false;
}

stock bool IsSpellAnAura(client, char[] TalentName) {
	int pos = GetTalentPosition(client, TalentName);
	IsSpellAnAuraKeys[client]	= GetArrayCell(a_Menu_Talents, pos, 0);
	IsSpellAnAuraValues[client] = GetArrayCell(a_Menu_Talents, pos, 1);
	return (GetArrayCell(IsSpellAnAuraValues[client], IS_AURA_INSTEAD) == 1) ? true : false;
}

stock bool IsTriggerCooldownEffect(client, target, char[] TalentName, bool isActivePeriodEndInstead = false) {
	int pos = GetTalentPosition(client, TalentName);
	if (pos == -1) return false;// log an error? can this statement EVEN HAPPEN?
	if (GetArrayCell(MyTalentStrength[client], GetMenuPosition(client, TalentName)) < 1) return false;
	//CooldownEffectTriggerKeys[client]	= GetArrayCell(a_Menu_Talents, pos, 0);
	CooldownEffectTriggerValues[client] = GetArrayCell(a_Menu_Talents, pos, 1);

	char CooldownEffect[64];
	if (!isActivePeriodEndInstead) GetArrayString(CooldownEffectTriggerValues[client], EFFECT_COOLDOWN_TRIGGER, CooldownEffect, sizeof(CooldownEffect));
	else GetArrayString(CooldownEffectTriggerValues[client], EFFECT_INACTIVE_TRIGGER, CooldownEffect, sizeof(CooldownEffect));
	if (StrEqual(CooldownEffect, "-1")) return false;
	// We could theoretically 'chain' multiple effect over times with each other using this...
	// Or we could have one talent split up into multiple "cycles" and each node unlocks an additional cycle.
	GetAbilityStrengthByTrigger(client, target, CooldownEffect);
	return true;
}																		// 0 to insert, 1 to get the active time, 2 to get the cooldow

stock bool IsAmmoEffectActive(client, char[] TalentName) {
	float fCooldown = GetAmmoCooldownTime(client, TalentName);
	if (fCooldown == -1.0) return false;
	float fAmmoCooldownTime = fCooldown;
	fCooldown = GetSpecialAmmoStrength(client, TalentName);

	float fAmmoCooldown = fCooldown + GetSpecialAmmoStrength(client, TalentName, 1);
	fCooldown = fCooldown - (fAmmoCooldown - fAmmoCooldownTime);
	if (fCooldown > 0.0) return true;
	return false;
}

stock CheckActiveAmmoCooldown(client, char[] TalentName, bool bActivateCooldown=false) {

	/*

		The original function is below. Rewritten after adding new functionality to function as originally intended.
	*/
	if (!IsLegitimateClient(client)) return -1;
	if (IsAmmoActive(client, TalentName)) return 2;	// even if bActivateCooldown, if it is on cooldown already, we don't create another cooldown.
	else if (bActivateCooldown) IsAmmoActive(client, TalentName, GetSpecialAmmoStrength(client, TalentName, 1));
	else return 1;
	return 0;
}

stock bool IsAmmoActive(client, char[] TalentName, float f_Delay=0.0, bool IsActiveAbility = false) {
	char result[2][64];
	int pos = -1;
	int size = -1;
	if (f_Delay == 0.0) {
		size = GetArraySize(PlayerActiveAmmo[client]);
		if (IsActiveAbility) size = GetArraySize(PlayActiveAbilities[client]);
		for (int i = 0; i < size; i++) {
			if (!IsActiveAbility) {
				GetTalentNameAtMenuPosition(client, GetArrayCell(PlayerActiveAmmo[client], i, 0), result[0], sizeof(result[]));
			}
			else {
				GetTalentNameAtMenuPosition(client, GetArrayCell(PlayActiveAbilities[client], i, 0), result[0], sizeof(result[]));
			}
			if (StrEqual(result[0], TalentName, false)) return true;

		}
		return false;
	}
	else {
		pos = GetMenuPosition(client, TalentName);
		if (!IsActiveAbility) {
			size = GetArraySize(PlayerActiveAmmo[client]);
			ResizeArray(PlayerActiveAmmo[client], size + 1);
			SetArrayCell(PlayerActiveAmmo[client], size, pos, 0);	// storing the position of the talent instead of the talent so we don't have to store a string.
			SetArrayCell(PlayerActiveAmmo[client], size, f_Delay, 1);
		}
		else {
			size = GetArraySize(PlayActiveAbilities[client]);
			ResizeArray(PlayActiveAbilities[client], size + 1);
			SetArrayCell(PlayActiveAbilities[client], size, pos, 0);
			SetArrayCell(PlayActiveAbilities[client], size, f_Delay, 1);
			SetArrayCell(PlayActiveAbilities[client], size, GetIfTriggerRequirementsMetAlways(client, TalentName), 2);
			SetArrayCell(PlayActiveAbilities[client], size, 0.0, 3);	// so that all abilities active/passive visual effects show on the first tick.
		}
	}
	return false;
}

stock float GetAmmoCooldownTime(client, char[] TalentName, bool IsActiveTimeInstead = false) {

	//Push to an array.
	char result[3][64];
	int size = GetArraySize(PlayerActiveAmmo[client]);
	float timeRemaining = 0.0;
	if (IsActiveTimeInstead) size = GetArraySize(PlayActiveAbilities[client]);
	for (int i = 0; i < size; i++) {

		if (!IsActiveTimeInstead) {
			GetTalentNameAtMenuPosition(client, GetArrayCell(PlayerActiveAmmo[client], i, 0), result[0], sizeof(result[]));
			timeRemaining = GetArrayCell(PlayerActiveAmmo[client], i, 1);
		}
		else {
			GetTalentNameAtMenuPosition(client, GetArrayCell(PlayActiveAbilities[client], i, 0), result[0], sizeof(result[]));
			timeRemaining = GetArrayCell(PlayActiveAbilities[client], i, 1);
		}
		if (StrEqual(result[0], TalentName, false)) return timeRemaining;
	}
	return -1.0;
}
// GETARRAYCELL MIGHT NOT WORK WITH GETABILITYVALUE GetKeyValueFloatAtPos
stock float GetAbilityValue(client, char[] TalentName, valuePos) {

	char TheTalent[64];

	int size = GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {
		AbilityConfigSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(AbilityConfigSection[client], 0, TheTalent, sizeof(TheTalent));
		if (!StrEqual(TheTalent, TalentName)) continue;
		AbilityConfigValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		return GetArrayCell(AbilityConfigValues[client], valuePos);
	}
	return -1.0;
}

stock bool IsAbilityInstant(client, char[] TalentName) {

	if (GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME) > 0.0) return false;
	return true;
}

stock bool CallAbilityCooldownAbilityTrigger(client, char[] TalentName, bool activePeriodNotCooldownPeriodEnds = false) {
	char text[64];
	int size = GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {
		CallAbilityCooldownTriggerSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(CallAbilityCooldownTriggerSection[client], 0, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;

		CallAbilityCooldownTriggerKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		CallAbilityCooldownTriggerValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);
		if (activePeriodNotCooldownPeriodEnds) GetArrayString(CallAbilityCooldownTriggerValues[client], ABILITY_ACTIVE_END_ABILITY_TRIGGER, text, sizeof(text));
		else GetArrayString(CallAbilityCooldownTriggerValues[client], ABILITY_COOLDOWN_END_TRIGGER, text, sizeof(text));
		if (StrEqual(text, "-1")) break;

		GetAbilityStrengthByTrigger(client, L4D2_GetInfectedAttacker(client), text);
		return true;
	}
	return false;
}

stock GetIfTriggerRequirementsMetAlways(client, char[] TalentName) {
	char text[64];
	int size = GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {
		GetIfTriggerRequirementsMetSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(GetIfTriggerRequirementsMetSection[client], 0, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;
		//GetIfTriggerRequirementsMetKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		GetIfTriggerRequirementsMetValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);
		// Reactive abilities start with their requirements for active end or cooldown end ability triggers to fire, not met.
		if (GetArrayCell(GetIfTriggerRequirementsMetValues[client], ABILITY_IS_REACTIVE) == 1) return 0;
		break;
	}
	// If we get here, we meet the requirements.
	return 1;
}

bool AbilityIsInactiveAndOnCooldown(client, char[] TalentName, float fCooldownRemaining) {
	if (fCooldownRemaining == -1.0) return false;

	float AmmoCooldownTime = GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME);
	if (AmmoCooldownTime == -1.0) return false;

	float fAmmoCooldownTime = GetSpellCooldown(client, TalentName);
	AmmoCooldownTime = AmmoCooldownTime - (fAmmoCooldownTime - fCooldownRemaining);
	if (AmmoCooldownTime > 0.0) return false;
	return true;
}

// by default this function does not handle instants, so we use an override to force it.
stock float GetAbilityMultiplier(client, char[] abilityT, override = 0, char[] TalentName_t = "none") { // we need the option to force certain results in the menus (1) active (2) passive
	if (GetArraySize(ActionBarMenuPos[client]) != iActionBarSlots ||
		GetArraySize(MyTalentStrength[client]) != GetArraySize(a_Menu_Talents)) return -1.0;
	char TalentName[64];
	//char abilityT[4];


	float totalStrength = 0.0, theStrength = 0.0;
	bool foundone = false;

	//if (StrEqual(TalentName_t, "none")) Format(abilityT, sizeof(abilityT), "%c", ability);
	char MyTeam[6];
	char TheTeams[6];
	Format(MyTeam, sizeof(MyTeam), "%d", GetClientTeam(client));

	int size = GetArraySize(a_Menu_Talents);
	if (override == 0) size = GetArraySize(ActionBar[client]);
	float fCooldownRemaining = 0.0;
	int isReactive = 0;

	char activeEffect[10];
	char passiveEffect[10];
	char cooldownEffect[10];
	bool IsCurrentlyActive;
	int combatStateRequired;
	//char allowedWeapons[64];
	//char clientWeapon[64];
	int pos = -1;
	bool talentPassiveIsActive = false;
	for (int i = 0; i < size; i++) {
		bool isActionBar = false;
		if (override != 0) {
			pos = i;
			GetAbilityArray[client]				= GetArrayCell(a_Menu_Talents, pos, 2);
			GetArrayString(GetAbilityArray[client], 0, TalentName, sizeof(TalentName));
		}
		else {
			isActionBar = true;
			GetArrayString(ActionBar[client], i, TalentName, sizeof(TalentName));
			//pos = GetMenuPosition(client, TalentName);
			pos = GetArrayCell(ActionBarMenuPos[client], i);
		}
		if (pos < 0 || pos >= size) continue;
		if (StrEqual(TalentName_t, "none")) {
			if (isActionBar && GetArrayCell(MyTalentStrength[client], pos) <= 0) continue;
			//if (!IsAbilityEquipped(client, TalentName, pos)) continue;
		}
		else if (!StrEqual(TalentName, TalentName_t)) continue;

		GetAbilityArray[client]				= GetArrayCell(a_Menu_Talents, pos, 1);
		if (GetArrayCell(GetAbilityArray[client], IS_TALENT_ABILITY) != 1) continue;
		combatStateRequired = GetArrayCell(GetAbilityArray[client], COMBAT_STATE_REQ);
		// if no combat state is set, it will return -1, and then work regardless of their combat status.
		if (combatStateRequired == 0 && bIsInCombat[client] ||
			combatStateRequired == 1 && !bIsInCombat[client]) continue;
		int iWeaponsPermitted = GetArrayCell(GetAbilityArray[client], WEAPONS_PERMITTED);
		if (iWeaponsPermitted >= 10 && !clientWeaponCategoryIsAllowed(client, iWeaponsPermitted)) continue;
		GetArrayString(GetAbilityArray[client], ABILITY_ACTIVE_EFFECT, activeEffect, sizeof(activeEffect));
		GetArrayString(GetAbilityArray[client], ABILITY_PASSIVE_EFFECT, passiveEffect, sizeof(passiveEffect));
		GetArrayString(GetAbilityArray[client], ABILITY_COOLDOWN_EFFECT, cooldownEffect, sizeof(cooldownEffect));

		IsCurrentlyActive = IsAbilityActive(client, TalentName, _, abilityT);

		isReactive = GetArrayCell(GetAbilityArray[client], ABILITY_IS_REACTIVE);
		if (isReactive != 1 && override == 5) continue;
		if (isReactive == 1 && override != 5) continue;
		
		GetArrayString(GetAbilityArray[client], ABILITY_TEAMS_ALLOWED, TheTeams, sizeof(TheTeams));
		if (StrContains(TheTeams, MyTeam) == -1) continue;

		fCooldownRemaining = GetAmmoCooldownTime(client, TalentName, true);
		if (override != -1 && AbilityIsInactiveAndOnCooldown(client, TalentName, fCooldownRemaining)) {
			return -1.0;
		}
		talentPassiveIsActive = (GetAmmoCooldownTime(client, TalentName) == -1.0) ? true : false;

		//if (override == 0 && GetAmmoCooldownTime(client, TalentName, true) != -1.0 || override == 1) {
		if (override == 4 || !IsCurrentlyActive && !talentPassiveIsActive) {
			theStrength = GetArrayCell(GetAbilityArray[client], ABILITY_COOLDOWN_STRENGTH);
			if (override == 4 || fCooldownRemaining > 0.0 && theStrength > 0.0) {
				if (!StrEqual(abilityT, cooldownEffect)) continue;
				if (theStrength > 0.0) return theStrength;
			}
		}
		if (override == 3) {

			if (!IsCurrentlyActive) return GetArrayCell(GetAbilityArray[client], ABILITY_MAXIMUM_PASSIVE_MULTIPLIER);
			else return GetArrayCell(GetAbilityArray[client], ABILITY_MAXIMUM_ACTIVE_MULTIPLIER);
		}
		else if (override == 1 || IsCurrentlyActive) {

			if (StrEqual(TalentName_t, "none")) {
				if (!StrEqual(abilityT, activeEffect)) continue;
				
				if (override != 1 && GetArrayCell(GetAbilityArray[client], ABILITY_ACTIVE_STATE_ENSNARE_REQ) == 1 && L4D2_GetInfectedAttacker(client) == -1) continue;
				if (override == 5) {
					// this only happens if the requirements to trigger are met (and cannot trigger if they've been met before.)
					if (!SetActiveAbilityConditionsMet(client, TalentName, true)) {
						SetActiveAbilityConditionsMet(client, TalentName);
						return -2.0;	// this is how we know that reactive abilities are active (and can thus trigger)
					}
					else return -3.0;	// this is the return if the reactive effect has already triggered (reactive can only trigger once during their active period.)
				}
			}
			theStrength = GetArrayCell(GetAbilityArray[client], ABILITY_ACTIVE_STRENGTH);
		}
		else if (override == 2 || talentPassiveIsActive || GetArrayCell(GetAbilityArray[client], ABILITY_PASSIVE_IGNORES_COOLDOWN) == 1) {
			if (StrEqual(TalentName_t, "none")) {
				if (!StrEqual(abilityT, passiveEffect)) continue;
				if (override != 2 && GetArrayCell(GetAbilityArray[client], ABILITY_PASSIVE_STATE_ENSNARE_REQ) == 1 && L4D2_GetInfectedAttacker(client) == -1) continue;
			}
			theStrength = GetArrayCell(GetAbilityArray[client], ABILITY_PASSIVE_STRENGTH);
		}
		else continue;	// If it's not active, or it's on cooldown, we ignore its value.
		if (override == 4) {
			totalStrength += ((1.0 - totalStrength) * theStrength);
		} 
		else totalStrength += theStrength;
		foundone = true;
	}
	if (!foundone) totalStrength = -1.0;
	return totalStrength;
}

stock bool IsAbilityEquipped(client, char[] TalentName, int pos) {

	char text[64];

	int size = iActionBarSlots;
	if (GetArraySize(ActionBar[client]) != size) ResizeArray(ActionBar[client], size);
	int menSize = GetArraySize(a_Menu_Talents);
	if (GetArraySize(MyTalentStrength[client]) != menSize) {
		ResizeArray(MyTalentStrength[client], menSize);
		return false;
	}
	for (int i = 0; i < size; i++) {
		GetArrayString(ActionBar[client], i, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;
		if (GetArrayCell(MyTalentStrength[client], pos) > 0) return true;
		break;
	}
	return false;
}

stock bool IsAbilityActive(client, char[] TalentName, float timeToAdd = 0.0, char[] checkEffect = "none") {
	if (StrEqual(checkEffect, "L")) return false;

	float fCooldownRemaining = GetAmmoCooldownTime(client, TalentName, true);
	if (fCooldownRemaining == -1.0) return false;
	if (GetAbilityValue(client, TalentName, ABILITY_COOLDOWN) == -1.0) return false;

	float AmmoCooldownTime		 = GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME);
	if (AmmoCooldownTime == -1.0) return false;

	float fAmmoCooldownTime = GetSpellCooldown(client, TalentName);
	AmmoCooldownTime				 = AmmoCooldownTime - (fAmmoCooldownTime - fCooldownRemaining) + timeToAdd;

	if (AmmoCooldownTime < 0.0) return false;
	return true;
}

stock float GetValueFloat(client, char[] talentName, pos) {
	int menuPos = GetMenuPosition(client, talentName);
	GetValueFloatArray[client] = GetArrayCell(a_Menu_Talents, menuPos, 1);
	return GetArrayCell(GetValueFloatArray[client], pos);
}

/*

	Return different types of results about the special ammo. 0, the default, returns its active time
	0	Ability Time
	1	Cooldown Time
	2	Stamina Cost
	3	Range
	4	Interval Time
	5	Effect Strength
*/
stock float GetSpecialAmmoStrength(client, char[] TalentName, resulttype=0, bool bGetNextUpgrade=false, TalentStrengthOverride = 0) {

	int pos							=	GetMenuPosition(client, TalentName);
	if (pos == -1) return -1.0;		// no ammo is selected.
	int TheStrength = GetArrayCell(MyTalentStrength[client], pos);
	float f_Str					=	TheStrength * 1.0;
	float baseTalentStrength	= 0.0;
	float i_FirstPoint			= 0.0;
	float i_FirstPoint_Temp		= 0.0;
	//new Float:i_Time_Temp			= 0.0;
	//new Float:i_Cooldown_Temp		= 0.0;
	//new Float:f_Min					= 0.0;
	float i_EachPoint			= 0.0;
	float i_EachPoint_Temp		= 0.0;
	float i_CooldownStart		= 0.0;
	if (TalentStrengthOverride != 0) f_Str = TalentStrengthOverride * 1.0;
	else if (bGetNextUpgrade) f_Str++;		// We add 1 point if we're showing the next upgrade value.

	//SpecialAmmoStrengthKeys[client]			= GetArrayCell(a_Menu_Talents, pos, 0);
	SpecialAmmoStrengthValues[client]		= GetArrayCell(a_Menu_Talents, pos, 1);

	char governingAttribute[64];
	GetGoverningAttribute(client, TalentName, governingAttribute, sizeof(governingAttribute));
	float attributeMult = 0.0;
	if (!StrEqual(governingAttribute, "-1")) attributeMult = GetAttributeMultiplier(client, governingAttribute);

	/*new Cons = GetTalentStrength(client, "constitution");
	new Agil = GetTalentStrength(client, "agility");
	new Resi = GetTalentStrength(client, "resilience");
	new Tech = GetTalentStrength(client, "technique");
	new Endu = GetTalentStrength(client, "endurance");*/
	//new Luck = GetTalentStrength(client, "luck");

	float f_StrEach = f_Str - 1;
	float TheAbilityMultiplier = 0.0;

	if (f_Str > 0.0) {

		if (resulttype == 0) {		// Ability Time

			i_FirstPoint		=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_ACTIVE_TIME_FIRST_POINT);
			i_FirstPoint_Temp	=	(i_FirstPoint * attributeMult);	// Constitution increases the first point value of spells.
			//if (attributeMult > 0.0) i_FirstPoint += (i_FirstPoint * attributeMult);
			i_FirstPoint		+= i_FirstPoint_Temp;


			
			i_EachPoint			=	(GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_ACTIVE_TIME_PER_POINT));
			i_EachPoint			+=	(i_EachPoint * attributeMult);
			if (i_EachPoint < 0.0) i_EachPoint = 0.0;

			i_EachPoint *= f_StrEach;

			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "activetime", 0, true);
		}
		else if (resulttype == 1) {		// Cooldown Time

			i_CooldownStart			=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_COOLDOWN_START);
			i_FirstPoint			=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_COOLDOWN_FIRST_POINT);
			i_EachPoint				=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_COOLDOWN_PER_POINT);

			i_EachPoint_Temp		=	(i_EachPoint * attributeMult)
			i_EachPoint_Temp		-=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint -= i_EachPoint_Temp;
			if (i_EachPoint < 0.0) i_EachPoint = 0.0;


			TheAbilityMultiplier = GetAbilityMultiplier(client, "L");
			if (TheAbilityMultiplier != -1.0) {

				if (TheAbilityMultiplier < 0.0) TheAbilityMultiplier = 0.1;
				else if (TheAbilityMultiplier > 0.0) { //cooldowns are reduced

					i_FirstPoint		*= TheAbilityMultiplier;
					i_EachPoint			*= TheAbilityMultiplier;
				}
			}

			i_EachPoint *= f_StrEach;

			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str			+=	i_CooldownStart;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "cooldown", 0, true);
			// If talents reduce the cooldown time, we need to make sure the cooldown is never less than the active time - or they could have multiple of the same spell active at one time.
			if (f_Str < 0.0) f_Str = 0.0;//f_Str = GetSpecialAmmoStrength(client, TalentName, _, bGetNextUpgrade, TalentStrengthOverride);
		}
		else if (resulttype == 2) {		// Stamina Cost

			int baseStamReq = GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_BASE_STAMINA_REQ);
			i_FirstPoint						=	baseStamReq * 1.0;
			i_FirstPoint_Temp					=	(i_FirstPoint * attributeMult);
			if (i_FirstPoint_Temp > 0.0) i_FirstPoint += i_FirstPoint_Temp;
			baseTalentStrength = i_FirstPoint;

			int pointStamReq = GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_STAMINA_PER_POINT);
			i_EachPoint							=	pointStamReq * 1.0;
			i_EachPoint_Temp					=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint += i_EachPoint_Temp;
			if (i_EachPoint < 0.0) i_EachPoint = 0.0;

			i_EachPoint *= f_StrEach;

			f_Str								=	i_FirstPoint + i_EachPoint;
			if (f_Str < baseTalentStrength) f_Str = baseTalentStrength;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "staminacost", 0, true);
			if (f_Str < 1.0) f_Str = 1.0;
			// we do class multiplier after because we want to allow classes to modify the restrictions
		}
		else if (resulttype == 3) {		// Range

			i_FirstPoint						=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_RANGE_FIRST_POINT);
			i_FirstPoint_Temp					=	(i_FirstPoint * attributeMult);
			i_FirstPoint						+=	i_FirstPoint_Temp;



			i_EachPoint							=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_RANGE_PER_POINT);
			i_EachPoint_Temp					=	(i_EachPoint * attributeMult);
			i_EachPoint_Temp					-=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint += i_EachPoint_Temp;

			i_EachPoint *= f_StrEach;

			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "range", 0, true);
		}
		else if (resulttype == 4) {		// Interval

			i_FirstPoint		=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_INTERVAL_FIRST_POINT);
			i_FirstPoint_Temp	=	(i_FirstPoint * attributeMult);
			i_FirstPoint		+=	i_FirstPoint_Temp;

			i_EachPoint			=	GetArrayCell(SpecialAmmoStrengthValues[client], SPELL_INTERVAL_PER_POINT);
			i_EachPoint_Temp	=	(i_EachPoint * attributeMult);
			i_EachPoint_Temp	-=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint += i_EachPoint_Temp;

			i_EachPoint *= f_StrEach;
			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "interval", 0, true);
		}
	}
	//if (resulttype == 3) return (f_Str / 2);	// we always measure from the center-point.
	f_Str += (f_Str * GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "strengthup", 0, true));

	char governingAttributeText[64];
	GetArrayString(SpecialAmmoStrengthValues[client], GOVERNING_ATTRIBUTE, governingAttributeText, sizeof(governingAttributeText));
	if (!StrEqual(governingAttributeText, "-1")) {
		float governingAttributeMultiplier = GetAttributeMultiplier(client, governingAttributeText);
		if (governingAttributeMultiplier > 0.0) f_Str += (f_Str * governingAttributeMultiplier);
	}


	// char activatorEffects[64];
	// GetArrayString(SpecialAmmoStrengthValues[client], ACTIVATOR_ABILITY_EFFECTS, activatorEffects, 64);
	// char targetEffects[64];
	// GetArrayString(SpecialAmmoStrengthValues[client], TARGET_ABILITY_EFFECTS, targetEffects, 64);
	// int skipAugmentModifiers = GetArrayCell(SpecialAmmoStrengthValues[client], TALENT_NO_AUGMENT_MODIFIERS);
	// if (skipAugmentModifiers != 1) {
	// 	float fCategoryAugmentBuff = GetCategoryAugmentBuff(client, TalentName, f_Str);
	// 	float fCategoryTalentBuff = GetCategoryTalentBuff(client, activatorEffects, targetEffects);
	// 	if (fCategoryAugmentBuff > 0.0) f_Str += (f_Str * fCategoryAugmentBuff);
	// 	if (fCategoryTalentBuff > 0.0) f_Str += (f_Str * fCategoryTalentBuff);
	// }
	return f_Str;
}

/*stock CreateActiveTime(client, String:TalentName[], Float:f_Delay) {

	if (IsLegitimateClient(client)) {

		if (IsAmmoActive(client, TalentName)) return 2;	// we don't need to initiate the ammo's activation period if it's already active.
		IsAmmoActive(client, TalentName, f_Delay);
		return 1;
	}
	return 0;
}*/

public Action Timer_RemoveCooldown(Handle timer, Handle packi) {

	ResetPack(packi);
	int client				=	ReadPackCell(packi);
	int pos					=	ReadPackCell(packi);
	char StackType[64];
	ReadPackString(packi, StackType, sizeof(StackType));
	//new StackCount			=	ReadPackCell(packi);
	int target				=	ReadPackCell(packi);
	float f_Cooldown	= ReadPackFloat(packi);


	if (StrEqual(StackType, "none", false)) {

		if (IsLegitimateClient(client)) {
			if (GetArraySize(PlayerAbilitiesCooldown[client]) < pos) ResizeArray(PlayerAbilitiesCooldown[client], pos + 1);
			SetArrayString(PlayerAbilitiesCooldown[client], pos, "0");
		}
	}
	else if (IsLegitimateClient(target)) {

		CleanseStack[client]--;		// again we will open this for more expansion later.

		CounterStack[target] -= f_Cooldown;
		if (CounterStack[target] <= 0.0) {

			MultiplierStack[target] = 0;
			Format(BuildingStack[target], sizeof(BuildingStack[]), "none");
		}
	}
	return Plugin_Stop;
}

stock void CreateCooldown(client, pos, float f_Cooldown, char[] StackType = "none", StackCount = 0, target = 0) {
	if (pos < 0) return;
	if (IsLegitimateClient(client)) {
		if (target == 0) target = client;
		if (GetArraySize(PlayerAbilitiesCooldown[client]) < pos) ResizeArray(PlayerAbilitiesCooldown[client], pos + 1);
		SetArrayString(PlayerAbilitiesCooldown[client], pos, "1");
		Handle packi;
		CreateDataTimer(f_Cooldown, Timer_RemoveCooldown, packi, TIMER_FLAG_NO_MAPCHANGE);
		//if (IsFakeClient(client)) client = -1;
		WritePackCell(packi, client);
		WritePackCell(packi, pos);
		if (!StrEqual(StackType, "none", false)) {
			CounterStack[target] += f_Cooldown;		// we subtract this value when the datatimer executes and if it is <= 0.0 then we set the building stack type to none.
			if (!StrEqual(StackType, BuildingStack[target], false)) {
				MultiplierStack[target] = 0;	// if the cleanse removes a different effect, we reset the overdrive, but it is also refreshed.
				Format(BuildingStack[target], sizeof(BuildingStack[]), "%s", StackType);
				PrintToChat(target, "%T", "building stack change", target, orange, blue, StackType, orange, green, f_Cooldown, blue);
			}
		}
		// So we can let clients build special stacks.
		WritePackString(packi, StackType);
		//WritePackCell(packi, StackCount);
		WritePackCell(packi, target);
		WritePackFloat(packi, f_Cooldown);
	}
}

stock bool HasAbilityPoints(client, char[] TalentName) {

	if (IsLegitimateClientAlive(client)) {

		// Check if the player has any ability points in the specified ability

		int a_Size				=	0;
		//if (client != -1)
		a_Size		=	GetArraySize(a_Database_PlayerTalents[client]);
		//else a_Size						=	GetArraySize(a_Database_PlayerTalents_Bots);

		char Name[PLATFORM_MAX_PATH];

		for (int i = 0; i < a_Size; i++) {

			GetArrayString(a_Database_Talents, i, Name, sizeof(Name));
			if (StrEqual(Name, TalentName)) {

				//if (client != -1)
				GetArrayString(a_Database_PlayerTalents[client], i, Name, sizeof(Name));
				//else GetArrayString(Handle:a_Database_PlayerTalents_Bots, i, Name, sizeof(Name));
				if (StringToInt(Name) > 0) return true;
			}
		}
	}
	return false;
}

/*stock AwardSkyPoints(client, amount) {

	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "donator package flag?");


	if (HasCommandAccess(client, thetext)) amount = RoundToCeil(amount * 2.0);
	SkyPoints[client] += amount;
	char Name[64];
	GetClientName(client, Name, sizeof(Name));

	GetConfigValue(thetext, sizeof(thetext), "sky points menu name?");
	PrintToChatAll("%t", "Sky Points Award", green, amount, orange, thetext, white, green, Name, white);
}*/

stock GetUpgradeExperienceCost(client, bool b_IsLevelUp = false) {

	int experienceCost = 0;
	if (IsLegitimateClient(client)) {

		//if (client == -1) return RoundToCeil(CheckExperienceRequirement(-1) * ((PlayerLevelUpgrades_Bots + 1) * fUpgradeExpCost));
		
		//new Float:Multiplier		= (PlayerUpgradesTotal[client] * 1.0) / (MaximumPlayerUpgrades(client) * 1.0);
		if (fUpgradeExpCost < 1.0) experienceCost		= RoundToCeil(CheckExperienceRequirement(client) * ((UpgradesAwarded[client] + 1) * fUpgradeExpCost));
		else experienceCost = CheckExperienceRequirement(client);
		//experienceCost				= RoundToCeil(CheckExperienceRequirement(client) * Multiplier);
	}
	return experienceCost;
}

stock PrintToSurvivors(RPGMode, char[] SurvivorName, char[] InfectedName, SurvExp, float SurvPoints) {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (RPGMode == 1) PrintToChat(i, "%T", "Experience Earned Total Team Survivor", i, white, blue, white, orange, white, green, white, SurvivorName, InfectedName, SurvExp);
			else if (RPGMode == 2) PrintToChat(i, "%T", "Experience Points Earned Total Team Survivor", i, white, blue, white, orange, white, green, white, green, white, SurvivorName, InfectedName, SurvExp, SurvPoints);
		}
	}
}

stock PrintToInfected(RPGMode, char[] SurvivorName, char[] InfectedName, InfTotalExp, float InfTotalPoints) {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) {

			if (RPGMode == 1) PrintToChat(i, "%T", "Experience Earned Total Team", i, white, orange, white, green, white, InfectedName, InfTotalExp);
			else if (RPGMode == 2) PrintToChat(i, "%T", "Experience Points Earned Total Team", i, white, orange, white, green, white, green, white, InfectedName, InfTotalExp, InfTotalPoints);
		}
	}
}

stock ResetOtherData(client) {

	if (IsLegitimateClient(client)) {

		for (int i = 1; i <= MAXPLAYERS; i++) {

			DamageAward[client][i]		=	0;
			DamageAward[i][client]		=	0;
			CoveredInBile[client][i]	=	-1;
			CoveredInBile[i][client]	=	-1;
		}
	}
}

stock LivingInfected(bool KillAll=false) {

	int countt = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) != ZOMBIECLASS_TANK) {

			if (KillAll) ForcePlayerSuicide(i);
			else countt++;
		}
	}
	return countt;
}

stock LivingSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}
	return count;
}

stock TotalSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}
	return count;
}

stock ChangeInfectedClass(client, zombieclass = 0, bool dontChangeClass = false) {
	bool clientIsFake = IsLegitimateClient(client) && IsFakeClient(client);

	if (clientIsFake || IsLegitimateClient(client)) {

		if (GetClientTeam(client) == TEAM_INFECTED) {

			if (!dontChangeClass) {
				if (!IsGhost(client)) SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
				int wi;
				while ((wi = GetPlayerWeaponSlot(client, 0)) != -1) {

					RemovePlayerItem(client, wi);
					AcceptEntityInput(wi, "Kill");
				}
				SDKCall(g_hSetClass, client, zombieclass);
				if (clientIsFake) {
					if (zombieclass == 1) SetClientInfo(client, "name", "Smoker");
					else if (zombieclass == 2) SetClientInfo(client, "name", "Boomer");
					else if (zombieclass == 3) SetClientInfo(client, "name", "Hunter");
					else if (zombieclass == 4) SetClientInfo(client, "name", "Spitter");
					else if (zombieclass == 5) SetClientInfo(client, "name", "Jockey");
					else if (zombieclass == 6) SetClientInfo(client, "name", "Charger");
					else if (zombieclass == 8) SetClientInfo(client, "name", "Tank");
				}
				AcceptEntityInput(MakeCompatEntRef(GetEntProp(client, Prop_Send, "m_customAbility")), "Kill");
				if (IsPlayerAlive(client)) SetEntProp(client, Prop_Send, "m_customAbility", GetEntData(SDKCall(g_hCreateAbility, client), g_oAbility));
				if (!IsGhost(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);		// client can be killed again.
			}
			SpeedMultiplier[client] = 1.0;		// defaulting the speed. It'll get modified in speed modifer spawn talents.
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplier[client]);
			SetSpecialInfectedHealth(client, zombieclass);
			//GetAbilityStrengthByTrigger(client, _, "a", FindZombieClass(client), 0);	// activator, target, trigger ability, effects, zombieclass, damage
		}
	}
}

stock bool HasIdlePlayer(int bot) {
    int userid = GetEntData(bot, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
    int client = GetClientOfUserId(userid);
    if (IsLegitimateClient(client) && !IsFakeClient(client) && GetClientTeam(client) != TEAM_SURVIVOR) return true;
    return false;
}

stock bool IsClientIdle(int client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || !HasIdlePlayer(i)) continue;
		int userid = GetEntData(i, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
		int spec = GetClientOfUserId(userid);
		if (spec == client) return true;
	}
	return false;
}

stock SetSpecialInfectedHealth(attacker, zombieclass = 0) {
	int t_InfectedHealth = 0;
	int myzombieclass = (zombieclass == 0) ? FindZombieClass(attacker) : zombieclass;

	t_InfectedHealth = (myzombieclass != ZOMBIECLASS_TANK) ? iBaseSpecialInfectedHealth[myzombieclass - 1] : iBaseSpecialInfectedHealth[myzombieclass - 2];

	OriginalHealth[attacker] = t_InfectedHealth;
	GetAbilityStrengthByTrigger(attacker, _, "a", _, 0);

	DefaultHealth[attacker] = OriginalHealth[attacker];
}

stock TotalHumanSurvivors(ignore = -1) {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (ignore != -1 && i == ignore) continue;
		if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

stock LivingHumanSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

stock HumanPlayersInGame() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) count++;
	}
	return count;
}

public Action Cmd_debugrpg(client, args) {
	if (bIsDebugEnabled) {
		PrintToChatAll("\x04rpg debug disabled");
		bIsDebugEnabled = false;
	}
	else {
		PrintToChatAll("\x03rpg debug enabled");
		bIsDebugEnabled = true;
	}
	return Plugin_Handled;
}

public Action Cmd_ResetTPL(client, args) { PlayerLevelUpgrades[client] = 0; return Plugin_Handled; }
//public Action Cmd_ResetTPL(client, args) { PlayerLevelUpgrades[client] = 0; }

stock bool StringExistsArray(char[] Name, Handle array) {

	char text[PLATFORM_MAX_PATH];

	int a_Size			=	GetArraySize(array);

	for (int i = 0; i < a_Size; i++) {

		GetArrayString(array, i, text, sizeof(text));

		if (StrEqual(Name, text)) return true;
	}

	return false;
}

stock AddCommasToString(value, char[] theString, theSize) 
{
	char buffer[64];
	char separator[2];
	separator = ",";
	buffer[0] = '\0'; 
	int divisor = 1000; 
	int offcut = 0;
	
	while (value >= 1000 || value <= -1000)
	{
		offcut = value % divisor;
		value = RoundToFloor(float(value) / float(divisor));
		Format(buffer, sizeof(buffer), "%s%03.d%s", separator, offcut, buffer); 
	}
	
	Format(theString, theSize, "%d%s", value, buffer);
}

stock ReceiveCommonDamage(client, entity, playerDamageTaken) {
	if (IsSpecialCommon(entity)) AddSpecialCommonDamage(client, entity, playerDamageTaken, true);
	else AddCommonInfectedDamage(client, entity, playerDamageTaken, true);
}

stock ReceiveWitchDamage(client, entity, playerDamageTaken) {

	if (!IsWitch(entity)) {

		OnWitchCreated(entity, true);
		return;
	}
	int pos = FindListPositionByEntity(entity, WitchList);
	if (pos < 0) {

		OnWitchCreated(entity);
		pos = FindListPositionByEntity(entity, WitchList);
	}

	int my_size = GetArraySize(WitchDamage[client]);
	int my_pos = FindListPositionByEntity(entity, WitchDamage[client]);
	if (my_pos < 0) {

		int WitchHealth = iWitchHealthBase;
		if (iBotLevelType == 0) WitchHealth += RoundToCeil(WitchHealth * (GetDifficultyRating(client) * fWitchHealthMult));
		else WitchHealth += RoundToCeil(WitchHealth * (SurvivorLevels() * fWitchHealthMult));

		ResizeArray(WitchDamage[client], my_size + 1);
		SetArrayCell(WitchDamage[client], my_size, entity, 0);
		SetArrayCell(WitchDamage[client], my_size, WitchHealth, 1);
		SetArrayCell(WitchDamage[client], my_size, 0, 2);
		SetArrayCell(WitchDamage[client], my_size, playerDamageTaken, 3);
		SetArrayCell(WitchDamage[client], my_size, 0, 4);
	}
	else {

		SetArrayCell(WitchDamage[client], my_pos, GetArrayCell(WitchDamage[client], my_pos, 3) + playerDamageTaken, 3);
	}
}

stock EntityStatusEffectDamage(client, damage) {

	/*

		This function rotates through the list of all players who have an initialized health pool with this entity.
		If they don't, it will create one.

		To simulate the illusion of the entity taking fire damage when players are not dealing damage to it, we instead
		remove the value from its total health pool. Everyone's CNT bars will rise, and the entity's E.HP bar will fall.
	*/
	int pos = -1;
	bool ClientIsWitch = IsWitch(client);
	if (ClientIsWitch) pos = FindListPositionByEntity(client, WitchList);
	if (pos < 0) return;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		AddWitchDamage(i, client, 0, true);	// If the player doesn't have the witch, it will be initialized for them.
		AddWitchDamage(i, client, damage * -1, true);		// After we verify initialization, we multiple damage by -1 so the function knows to remove health instead of add contribution.
	}
}

stock GetDifficultyRating(client) {
	if (!IsLegitimateClient(client) || GetClientTeam(client) != TEAM_SURVIVOR || !b_IsLoaded[client]) return 1;
	int iRatingPerLevel = (!IsFakeClient(client)) ? RatingPerLevel : RatingPerLevelSurvivorBots;
	iRatingPerLevel *= TotalPointsAssigned(client);
	int trueAugmentLevel = (!IsFakeClient(client) && playerCurrentAugmentLevel[client] > 0) ? playerCurrentAugmentLevel[client] * RatingPerAugmentLevel : 0;
	//if (iRatingPerAugmentLevel < 0) iRatingPerAugmentLevel = 0;
	return iRatingPerLevel + trueAugmentLevel + Rating[client];
}
//if (CheckTeammateDamages(target, client) >= 1.0 || CheckTeammateDamages(target, client, true) >= 1.0) {
stock AddCommonInfectedDamage(client, entity, playerDamage = 0, bool IsStatusDamage = false, damagetype = -1, ammotype = -1, hitgroup = -1) {
	int pos		= FindListPositionByEntity(entity, CommonInfected[client]);
	
	if (pos < 0) {
		//OnCommonInfectedCreated(entity);
		pos = GetArraySize(CommonInfected[client]);
		ResizeArray(CommonInfected[client], pos+1);
		SetArrayCell(CommonInfected[client], pos, entity);
		char stringRef[64];
		SetArrayCell(CommonInfected[client], pos, GetCharacterSheetData(client, stringRef, 64, 1), 1);
		SetArrayCell(CommonInfected[client], pos, 0, 2);
	}
	//if (IsSpecialCommonInRange(entity, 't')) return 1;
	if (playerDamage < 1) return 1;
	if (!IsStatusDamage) {
		int commonDamageReceived = GetArrayCell(CommonInfected[client], pos, 2);
		int commonHealthRemaining = GetArrayCell(CommonInfected[client], pos, 1);
		commonHealthRemaining = RoundToCeil(commonHealthRemaining * (1.0 - CheckTeammateDamages(entity, client, _, true)));
		if (commonHealthRemaining < commonDamageReceived) playerDamage = commonHealthRemaining;
		else if (playerDamage > commonHealthRemaining - commonDamageReceived) playerDamage = commonHealthRemaining - commonDamageReceived;
		DamageContribution[client] += RoundToFloor(playerDamage * SurvivorExperienceMult);
		SetArrayCell(CommonInfected[client], pos, commonDamageReceived + playerDamage, 2);
		SetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE) + playerDamage);
		CheckTeammateDamagesEx(client, entity, playerDamage, _, ammotype, hitgroup);
		return playerDamage;
	}
	int tankingDamageReceived = GetArrayCell(CommonInfected[client], pos, 3);
	SetArrayCell(CommonInfected[client], pos, tankingDamageReceived + playerDamage, 3);
	return -1 * playerDamage;
}

stock AddWitchDamage(client, entity, playerDamageToWitch, bool IsStatusDamage = false, damagevariant = -1, ammotype = -1, hitgroup = -1) {

	if (!IsWitch(entity)) {

		OnWitchCreated(entity, true);
		return 1;
	}
	if (!IsFakeClient(client) && IsSpecialCommonInRange(entity, 't')) return 1;

	int damageTotal = -1;
	int healthTotal = -1;
	int pos		= FindListPositionByEntity(entity, WitchList);
	if (pos < 0) return -1;
	if (client == -1) {
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
			AddWitchDamage(i, entity, playerDamageToWitch, _, 2);	// 2 so we subtract from her health but don't reward any players.
		}
		return 1;
	}

	int my_size	= GetArraySize(WitchDamage[client]);
	int my_pos	= FindListPositionByEntity(entity, WitchDamage[client]);
	// create an instance of the witch for the player, because one wasn't found.
	if (my_pos < 0) {
		ResizeArray(WitchDamage[client], my_size + 1);
		SetArrayCell(WitchDamage[client], my_size, entity, 0);
		char stringRef[64];
		SetArrayCell(WitchDamage[client], my_size, GetCharacterSheetData(client, stringRef, 64, 3), 1);
		SetArrayCell(WitchDamage[client], my_size, 0, 2);
		SetArrayCell(WitchDamage[client], my_size, 0, 3);
		SetArrayCell(WitchDamage[client], my_size, 0, 4);
		my_pos = my_size;
	}
	if (playerDamageToWitch >= 0) {
		healthTotal = GetArrayCell(WitchDamage[client], my_pos, 1);
		healthTotal = RoundToCeil(healthTotal * (1.0 - CheckTeammateDamages(entity, client, _, true)));
		//new TrueHealthRemaining = RoundToCeil((1.0 - CheckTeammateDamages(entity, client)) * healthTotal);	// in case other players have damaged the mob - we can't just assume the remaining health without comparing to other players.
		if (damagevariant != 2) {
			damageTotal = GetArrayCell(WitchDamage[client], my_pos, 2);
			if (damageTotal < 0) damageTotal = 0;
			if (healthTotal < playerDamageToWitch) playerDamageToWitch = healthTotal;
			//if (IsSpecialCommonInRange(entity, 't')) return 1;
			//if (playerDamageToWitch > TrueHealthRemaining) playerDamageToWitch = TrueHealthRemaining;

			SetArrayCell(WitchDamage[client], my_pos, damageTotal + playerDamageToWitch, 2);
			if (playerDamageToWitch > 0) {
				GetProficiencyData(client, GetWeaponProficiencyType(client), RoundToCeil(playerDamageToWitch * fProficiencyExperienceEarned));
				SetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_DAMAGE) + playerDamageToWitch);
			}
		}
		else SetArrayCell(WitchDamage[client], my_pos, healthTotal - playerDamageToWitch, 1);
	}
	else {

		/*

			When the witch is burning, or hexed (ie it is simply losing health) we come here instead.
			Negative values detract from the overall health instead of adding player contribution.
		*/
		damageTotal = GetArrayCell(WitchDamage[client], my_pos, 1);
		SetArrayCell(WitchDamage[client], my_pos, damageTotal + playerDamageToWitch, 1);
	}
	CheckTeammateDamagesEx(client, entity, playerDamageToWitch, _, ammotype, hitgroup);
	ThreatCalculator(client, playerDamageToWitch);
	return 1;
}

/*

	This function removes a dying (or dead) common infected from all client cooldown arrays.
*/
stock RemoveCommonAffixes(entity) {

	int size = GetArraySize(CommonAffixes);
	int ent = -1;

	for (int i = 0; i < size; i++) {

		//CASection			= GetArrayCell(CommonAffixes, i, 2);
		//if (GetArraySize(CASection) < 1) continue;
		//GetArrayString(Handle:CommonAffixes, i, SectionName, sizeof(SectionName));
		//if (StrContains(SectionName, EntityId, false) == -1) continue;
		ent = GetArrayCell(CommonAffixes, i);
		if (entity != ent) continue;
		RemoveFromArray(CommonAffixes, i);
		break;
	}
	/*for (new i = 1; i <= MaxClients; i++) {

		size = GetArraySize(CommonAffixesCooldown[i]);
		for (new y = 0; y < size; y++) {

			RCAffixes[i]			= GetArrayCell(CommonAffixesCooldown[i], y, 2);
			GetArrayString(Handle:RCAffixes[i], 0, SectionName, sizeof(SectionName));
			if (StrContains(SectionName, EntityId, false) == -1) continue;
			RemoveFromArray(Handle:CommonAffixesCooldown[i], y);
			break;
		}
	}*/
}

stock FindInfectedClient(bool GetClient=false) {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_INFECTED) {

			if (GetClient) return i;
			count++;
		}
	}
	return count;
}
/*
stock GetExplosionDamage(target, damage, survivor) {
	new TheStrength = GetTalentStrength(survivor, "explosive ammo");
	if (TheStrength > 0) {	// when a healers health regen tics, it heals all teammates nearby, too.

		new Float:explosionrange = GetSpecialAmmoStrength(survivor, "explosive ammo", 3) * 2.0;
		new Float:TargetPos[3];
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);
		TheStrength = LivingEntitiesInRange(target, TargetPos, explosionrange);
		if (TheStrength > 0) return (damage / TheStrength);
	}
	return 0;
}*/

stock CreateAoE(int owner, float fRangeOfEffect, amount, effectType = 0, bool bMustBeSameTeamAsOwner = true, int hitgroup, int damagetype, char[] targetCallAbilityTrigger) {
	float ownerPos[3];
	GetEntPropVector(owner, Prop_Send, "m_vecOrigin", ownerPos);
	int playersInRange = 0;
	int ownerTeam = GetClientTeam(owner);
	bool bHasTargetAbilityTrigger = (StrEqual(targetCallAbilityTrigger, "-1")) ? false : true;
	for (int teammate = 1; teammate <= MaxClients; teammate++) {
		if (teammate == owner) continue;
		if (!IsLegitimateClientAlive(teammate) || bMustBeSameTeamAsOwner && GetClientTeam(teammate) != ownerTeam) continue;
		float teammatePos[3];
		GetClientAbsOrigin(teammate, teammatePos);
		if (GetVectorDistance(ownerPos, teammatePos) > 384.0 || GetClientHealth(teammate) >= GetMaximumHealth(teammate)) continue;
		playersInRange++;
		if (effectType == 0) HealPlayer(teammate, owner, amount * 1.0, 'h', true);
		if (bHasTargetAbilityTrigger) GetAbilityStrengthByTrigger(teammate, owner, targetCallAbilityTrigger, _, amount, _, _, _, _, _, _, hitgroup, _, damagetype);
	}
	char effectColor[64];
	if (effectType == 0) Format(effectColor, sizeof(effectColor), "green:green");
	if (playersInRange > 0) CreateRing(owner, 384.0, effectColor, "32.0:48.0", _, 0.5);
}

stock CreatePlayerExplosion(client, float fRangeOfExplosion, damageToDealToEligibleTargets, bool bDontHurtAllies = true, bool bShowExplosionRingVisual = false) {
	float originOfExplosion[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", originOfExplosion);

	float realPlayerOrigin[3];
	CreateExplosion(client);
	ScreenShake(client);
	CreateRing(client, fRangeOfExplosion * 2.0, "red:red:red", "32.0:48.0:64.0", _, 0.5, _, true);

	for (int realPlayer = 1; realPlayer <= MaxClients; realPlayer++) {
		if (realPlayer == client || !IsLegitimateClientAlive(realPlayer)) continue;
		int team = GetClientTeam(realPlayer);
		//if (bDontHurtAllies && team == GetClientTeam(client) || team == TEAM_SURVIVOR && (PlayerLevel[realPlayer] < 20 || IsFakeClient(realPlayer))) continue;
		if (team == GetClientTeam(client) || team == TEAM_SURVIVOR && (PlayerLevel[realPlayer] < 20 || IsFakeClient(realPlayer))) continue;
		GetEntPropVector(realPlayer, Prop_Send, "m_vecOrigin", realPlayerOrigin);
		if (GetVectorDistance(originOfExplosion, realPlayerOrigin) > fRangeOfExplosion) continue;
		if (!IsFakeClient(realPlayer)) ScreenShake(realPlayer);
		if (FindZombieClass(realPlayer) == ZOMBIECLASS_TANK) ChangeTankState(realPlayer, "fire", true);
		if (GetClientTeam(realPlayer) == TEAM_INFECTED) AddSpecialInfectedDamage(client, realPlayer, damageToDealToEligibleTargets);
		else SetClientTotalHealth(client, realPlayer, damageToDealToEligibleTargets);
	}
	// witches.
	for (int pos = 0; pos < GetArraySize(WitchList); pos++) {
		int witch = GetArrayCell(WitchList, pos);
		if (!IsWitch(witch)) continue;	// pruned elsewhere
		GetEntPropVector(witch, Prop_Send, "m_vecOrigin", realPlayerOrigin);
		if (GetVectorDistance(originOfExplosion, realPlayerOrigin) > fRangeOfExplosion) continue;
		AddWitchDamage(client, witch, damageToDealToEligibleTargets);
	}
	// special commons
	for (int pos = 0; pos < GetArraySize(CommonList); pos++) {
		int common = GetArrayCell(CommonList, pos);
		if (!IsSpecialCommon(common)) continue;	// pruned elsewhere
		GetEntPropVector(common, Prop_Send, "m_vecOrigin", realPlayerOrigin);
		if (GetVectorDistance(originOfExplosion, realPlayerOrigin) > fRangeOfExplosion) continue;
		AddSpecialCommonDamage(client, common, damageToDealToEligibleTargets);
	}
	// commons
	for (int pos = 0; pos < GetArraySize(CommonInfected[client]); pos++) {
		int common = GetArrayCell(CommonInfected[client], pos);
		if (IsSpecialCommon(common) || !IsCommonInfected(common)) continue;	// pruned elsewhere
		GetEntPropVector(common, Prop_Send, "m_vecOrigin", realPlayerOrigin);
		if (GetVectorDistance(originOfExplosion, realPlayerOrigin) > fRangeOfExplosion) continue;
		AddCommonInfectedDamage(client, common, damageToDealToEligibleTargets);
	}
}

stock ClearSpecialCommon(entity, bool IsCommonEntity = true, playerDamage = 0, lastAttacker = -1) {

	if (CommonList == INVALID_HANDLE) return 0;

	char TheDraws[64];
	char ThePos[64];

	int pos = FindListPositionByEntity(entity, CommonList);
	if (pos >= 0) {

		if (IsCommonEntity && IsSpecialCommon(entity)) {

			char CommonEntityEffect[55];
			GetCommonValueAtPos(CommonEntityEffect, sizeof(CommonEntityEffect), entity, SUPER_COMMON_DEATH_EFFECT);
			// if (IsLegitimateClientAlive(lastAttacker) && GetClientTeam(lastAttacker) == TEAM_SURVIVOR && StrContains(CommonEntityEffect, "f", true) != -1) {
			// 	CreateDamageStatusEffect(entity);
			// }
			if (StrContains(CommonEntityEffect, "f", true) != -1) {
				CreateDamageStatusEffect(entity);
			}

			for (int y = 1; y <= MaxClients; y++) {

				if (!IsLegitimateClientAlive(y)) continue; // || GetClientTeam(y) != TEAM_SURVIVOR) continue;
				if (StrContains(CommonEntityEffect, "x", true) != -1 && IsSpecialCommonInRange(y, 'x', entity, false)) {
					CreateBomberExplosion(entity, y, "x");
				}
				if (StrContains(CommonEntityEffect, "b", true) != -1 && IsSpecialCommonInRange(y, 'b', entity, false) && FindInfectedClient() > 0 && !ISBILED[y]) {
					SDKCall(g_hCallVomitOnPlayer, y, FindInfectedClient(true), true);
					CreateTimer(15.0, Timer_RemoveBileStatus, y, TIMER_FLAG_NO_MAPCHANGE);
					ISBILED[y] = true;
				}
				if (StrContains(CommonEntityEffect, "a", true) != -1 && IsSpecialCommonInRange(y, 'a', entity, false) && FindInfectedClient() > 0) {

					CreateAcid(FindInfectedClient(true), y, 48.0);
					break;
				}
				if (StrContains(CommonEntityEffect, "e", true) != -1 && IsSpecialCommonInRange(y, 'e', entity, false)) {	// false so we compare death effect instead of aura effect which defaults to true

					if (ISEXPLODE[y] == INVALID_HANDLE) {

						ISEXPLODETIME[y] = 0.0;
						Handle packagey;
						ISEXPLODE[y] = CreateDataTimer(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_INTERVAL), Timer_Explode, packagey, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(packagey, y);
						WritePackCell(packagey, GetCommonValueIntAtPos(entity, SUPER_COMMON_AURA_STRENGTH));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_STRENGTH_TARGET));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_LEVEL_STRENGTH));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_RANGE_MAX));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_MULTIPLIER));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_BASE_TIME));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_INTERVAL));
						WritePackFloat(packagey, GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_MAX_TIME));
						GetCommonValue(TheDraws, sizeof(TheDraws), entity, "draw colour?");
						WritePackString(packagey, TheDraws);
						GetCommonValue(ThePos, sizeof(ThePos), entity, "draw pos?");
						WritePackString(packagey, ThePos);
						WritePackCell(packagey, GetCommonValueIntAtPos(entity, SUPER_COMMON_LEVEL_REQ));
					}
				}
				if (StrContains(CommonEntityEffect, "s", true) != -1 && IsSpecialCommonInRange(y, 's', entity, false)) {

					if (!ISSLOW[y]) {

						SetSpeedMultiplierBase(y, GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_MULTIPLIER));
						SetEntityMoveType(y, MOVETYPE_WALK);
						ISSLOW[y] = true;
						CreateTimer(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_BASE_TIME), Timer_Slow, y, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				if (StrContains(CommonEntityEffect, "f", true) != -1) {

					CreateDamageStatusEffect(entity, _, y, playerDamage, lastAttacker);
					//if (FindZombieClass(y) == ZOMBIECLASS_TANK) ChangeTankState(y, "burn");
				}
			}
			CalculateInfectedDamageAward(entity, lastAttacker);
			//SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		}
		ForceClearSpecialCommon(entity);
		//if (pos < GetArraySize(CommonList)) RemoveFromArray(CommonList, pos);
		//RemoveCommonAffixes(entity);
		//OnCommonInfectedCreated(entity, true);
		//if (IsCommonInfected(entity)) AcceptEntityInput(entity, "BecomeRagdoll");
		//if (iDeleteSupersOnDeath == 1 && IsValidEntity(entity)) AcceptEntityInput(entity, "Kill");
	}
	//if (IsValidEntity(entity)) SetInfectedHealth(entity, 1);	// this is so it dies right away.
	return playerDamage;
}

stock GetTeamRatingAverage(teamToGatherRatingOf = 2) {	// 2 == survivors
	int rating = 0;
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != teamToGatherRatingOf || PlayerLevel[i] < iLevelRequiredToEarnScore) continue;
		rating += Rating[i];
		if (!IsFakeClient(i)) count++;
	}
	if (count > 1) rating /= count;
	return rating;
}

stock OnCommonCreated(entity, bool bIsDestroyed = false, bool isSpecial = false) {

	//char EntityId[64];
	//Format(EntityId, sizeof(EntityId), "%d", entity);
	if (!bIsDestroyed) PushArrayCell(CommonList, entity);
	else if (isSpecial || IsSpecialCommon(entity)) ClearSpecialCommon(entity);
}
stock GetCommonBaseHealth(client = 0) {
	int ratingVal = (client == 0) ? GetTeamRatingAverage() : GetDifficultyRating(client);
	return (iCommonBaseHealth + RoundToCeil(iCommonBaseHealth * (ratingVal * fCommonLevelHealthMult)));
}

void OnCommonInfectedCreated(int entity, bool bIsDestroyed = false, int attacker = 0) {
	if (!b_IsActiveRound) {
		//if (IsCommonInfected(entity)) AcceptEntityInput(entity, "Kill");
		return;
	}
	if (IsSpecialCommon(entity)) return;
	if (bIsDestroyed) {
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i)) continue;
			int pos = FindListPositionByEntity(entity, CommonInfected[i]);
			if (pos < 0) continue;
			RemoveFromArray(CommonInfected[i], pos);
		}
		SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		if (!CommonInfectedModel(entity, FALLEN_SURVIVOR_MODEL)) AcceptEntityInput(entity, "BecomeRagdoll");
		else SetEntProp(entity, Prop_Data, "m_iHealth", 1);
		if (attacker > 0) CalculateInfectedDamageAward(entity, attacker);
	}
	else {
		// Add this common infected to every survivors data pool.
		// This ensures that if the infected touches, say fire for example, before being damaged by a survivor, it takes damage from it.
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i)) continue;
			AddCommonInfectedDamage(i, entity);	// with 0 damage, it will only insert the common into the players data pool, and only if it's not already inserted.
		}
	}
}

/*

	Witches are created different than other infected.
	If we want to track them and then remove them when they die
	we need to write custom code for it.

	This function serves to manage, maintain, and remove dead witches
	from both the list of active witches as well as reward players who
	hurt them and then reset that said damage as well.
*/
stock OnWitchCreated(entity, bool bIsDestroyed = false, lastHitAttacker = 0) {

	if (WitchList == INVALID_HANDLE) return;

	if (!bIsDestroyed) {

		/*

			When a new witch is created, we add them to the list, and then we
			make sure all survivor players lists are the same size.
		*/
		//LogMessage("[WITCH_LIST] Witch Created %d", entity);
		PushArrayCell(WitchList, entity);
		//SetInfectedHealth(entity, 50000);
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		//SDKHook(entity, SDKHook_TraceAttack, OnTraceAttack);

		//CreateMyHealthPool(entity);
	}
	else {

		/*

			When a Witch dies, we reward all players who did damage to the witch
			and then we remove the row of the witch id in both the witch list
			and in player lists.
		*/
		int pos = FindListPositionByEntity(entity, WitchList);
		if (pos < 0) {

			LogMessage("[WITCH_LIST] Could not find Witch by id %d", entity);
		}
		else {

			CalculateInfectedDamageAward(entity, lastHitAttacker, pos);
			//ogMessage("[WITCH_LIST] Witch %d Killed", entity);
			//SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
			//AcceptEntityInput(entity, "Kill");
			//RemoveFromArray(Handle:WitchList, pos);		// Delete the witch. Forever. now occurs in CalculateInfectedDamageAward()
		}
		WitchShot(entity, true);	// deletes this witch from the list of witches that have been triggered.
	}
}

stock FindEntityInString(char[] SearchKey, char[] Delim = ":") {

	if (StrContains(SearchKey, Delim, false) == -1) return -1;
	char tExploded[2][64];

	ExplodeString(SearchKey, Delim, tExploded, 2, 64);
	return StringToInt(tExploded[1]);
}

stock GetArraySizeEx(char[] SearchKey, char[] Delim = ":") {

	int count = 0;
	for (int i = 0; i <= strlen(SearchKey); i++) {

		if (StrContains(SearchKey[i], Delim, false) != -1) count++;
	}
	if (count == 0) return -1;
	return count + 1;
}

stock FindDelim(char[] EntityName, char[] Delim = ":") {

	char DelimStr[2];

	for (int i = 0; i <= strlen(EntityName); i++) {

		Format(DelimStr, sizeof(DelimStr), "%s", EntityName[i]);
		if (StrContains(DelimStr, Delim, false) != -1) {

			// Found it!
			return i + 1;
		}
	}
	return -1;
}

stock GetDelimiterCount(char[] TextCase, char[] Delimiter) {

	int count = 0;
	char Delim[2];
	for (int i = 0; i <= strlen(TextCase); i++) {

		Format(Delim, sizeof(Delim), "%s", TextCase[i]);
		if (StrContains(Delim, Delimiter, false) != -1) count++;
	}
	return count;
}

stock FindListPositionBySearchKey(char[] SearchKey, Handle h_SearchList, block = 0, bool bDebug = false) {
	// Some parts of rpg are formatted differently, so we need to check by entityname instead of id.
	char SearchId[64];
	int size = GetArraySize(h_SearchList);
	for (int i = 0; i < size; i++) {
		SearchKey_Section						= GetArrayCell(h_SearchList, i, block);
		if (GetArraySize(SearchKey_Section) < 1) {
			continue;
		}
		GetArrayString(SearchKey_Section, 0, SearchId, sizeof(SearchId));
		if (StrEqual(SearchId, SearchKey, false)) {
			return i;
		}
	}
	return -1;
}

bool SurvivorsSaferoomWaiting() {
	int count = 0;
	int numOfLivingHumanSurvivors = LivingHumanSurvivors();
	if (numOfLivingHumanSurvivors < 1) return false;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && !IsFakeClient(i) && bIsInCheckpoint[i]) count++;
	}
	if (count >= numOfLivingHumanSurvivors) return true;
	return false;
}

void SurvivorBotsRegroup() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		float pos[3];
		GetClientAbsOrigin(i, pos);
		for (int j = 1; j <= MaxClients; j++) {
			if (!IsLegitimateClient(j) || !IsFakeClient(j) || GetClientTeam(j) != TEAM_SURVIVOR) continue;
			TeleportEntity(j, pos, NULL_VECTOR, NULL_VECTOR);
		}
		return;
	}
}

stock bool IsSurvivorInAGroup(client) {
	if (IsFakeClient(client)) return false;	// we don't penalize players if bots die, so we always assume bots "aren't in a group" during this phase
	ClearArray(MyGroup[client]);
	// Checks if a player is in a group, right before they die.
	// While the dying player loses it all, group members will also lose a percentage of their XP, based on their group size.
	// Small groups have a larger split of the total XP, which means they also take a larger penalty when one of their members goes out.
	float Origin[3];
	GetClientAbsOrigin(client, Origin);
	float Pos[3];
	char AuthID[64];
	for (int i = 1; i <= MaxClients; i++) {
		if (i == client || !IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i)) continue;
		GetClientAbsOrigin(i, Pos);
		if (GetVectorDistance(Origin, Pos) <= 1536.0 || IsPlayerRushing(i)) {	// rushers get treated like they're a member of everyone who dies group, so that they are punished every time someone dies.
			GetClientAuthId(i, AuthId_Steam2, AuthID, sizeof(AuthID));
			PushArrayString(MyGroup[client], AuthID);
		}
	}
	if (GetArraySize(MyGroup[client]) < iSurvivorGroupMinimum) return false;
	return true;
}

stock bool IsPlayerRushing(client, float fDistance = 2048.0) {

	int TotalClients = LivingHumanSurvivors();
	int MyGroupSize = GroupSize(client);
	int LargestGroup = GroupSize();

	if (!AnyGroups() && MyGroupSize >= LargestGroup || TotalClients <= iSurvivorGroupMinimum || NearbySurvivors(client, fDistance, true, true) >= iSurvivorGroupMinimum) return false;
	return true;
}

stock float SurvivorRushingMultiplier(client, bool IsForTankTeleport = false) {

	int SurvivorsCount	= LivingHumanSurvivors();
	if (SurvivorsCount <= iSurvivorGroupMinimum) return 1.0;	// no penalty if less players than group minimum exist.

	int SurvivorsNear	= NearbySurvivors(client, 1536.0, true, true);
	if (SurvivorsNear >= iSurvivorGroupMinimum) return 1.0; // If the player is in a group of players, they take no penalty.
	else if (IsForTankTeleport) return -2.0;					// If tanks are trying to find a player to teleport to, if this player isn't in a group, they are eligible targets.

	float GetMultiplier = 1.0 / SurvivorsCount;
	GetMultiplier *= SurvivorsNear;
	return GetMultiplier;
}

stock bool AnyGroups() {

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (NearbySurvivors(i, 1536.0, true) >= iSurvivorGroupMinimum) return true;
	}
	return false;
}

stock GroupSize(client = 0) {

	if (client > 0) return NearbySurvivors(client, 1536.0, true);
	int largestGroup = 0;
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (client == i || !IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count = NearbySurvivors(i, 1536.0, true);
		if (count > largestGroup) largestGroup = count;
	}
	return count;
}

stock NearbySurvivors(client, float range = 512.0, bool Survivors = false, bool IsRushing = false) {

	float pos[3];
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, pos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float spos[3];

	int count = 0;
	int TheTime = GetTime();

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && i != client) {

			if (Survivors && IsFakeClient(i)) continue;
			if (IsRushing && (MyBirthday[i] == 0 || (TheTime - MyBirthday[i]) < 60 || NearbySurvivors(i, 1536.0, true) < iSurvivorGroupMinimum)) {

				// If a player has only been in the game a short time, or is not near enough survivors to be in a group, we consider them part of everyone's group.

				count++;
				continue;
			}

			GetClientAbsOrigin(i, spos);
			if (GetVectorDistance(pos, spos) <= range) count++;
		}
	}
	return count;
}

stock NumSurvivorsInRange(client, float range = 512.0, int team = 2) {

	float pos[3];
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, pos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float spos[3];
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != team || i == client) continue;
		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(pos, spos) <= range) count++;
	}
	return count;
}

stock bool SurvivorsInRange(client, float range = 512.0, bool NoSurvivorBots = false) {

	float pos[3];
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, pos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float spos[3];

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || i == client) continue;
		if (NoSurvivorBots && IsFakeClient(i)) continue;

		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(pos, spos) <= range) return true;
	}
	return false;
}

stock bool AnyTanksNearby(client, float range = 0.0) {

	if (range == 0.0) range = TanksNearbyRange;

	float pos[3];
	float ipos[3];
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) == ZOMBIECLASS_TANK) {

			GetClientAbsOrigin(client, pos);
			GetClientAbsOrigin(i, ipos);
			if (GetVectorDistance(pos, ipos) <= range) return true;
		}
	}
	return false;
}

stock bool IsVectorsCrossed(client, float torigin[3], float aorigin[3], float f_Distance) {

	float porigin[3];
	float vorigin[3];
	MakeVectorFromPoints(torigin, aorigin, vorigin);
	if (GetVectorDistance(porigin, vorigin) <= f_Distance) return true;
	return false;
}

bool ForceClearSpecialCommon(entity, int client = 0, bool killMob = true) {
	int pos		= FindListPositionByEntity(entity, CommonList);
	if (client == 0) {
		if (pos >= 0) RemoveFromArray(CommonList, pos); // bug with common/specials/infected having insane hp is deleting entity from array instead of the position where entity was found xD
		pos			= FindListPositionByEntity(entity, CommonAffixes);
		if (pos >= 0) RemoveFromArray(CommonAffixes, pos);
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || client > 0 && i != client) continue;
		pos			= FindListPositionByEntity(entity, CommonInfected[i]);
		if (pos >= 0) RemoveFromArray(CommonInfected[i], pos);
		pos			= FindListPositionByEntity(entity, SpecialCommon[i]);
		if (pos >= 0) RemoveFromArray(SpecialCommon[i], pos);
	}
	if (client == 0 && killMob && IsCommonInfected(entity)) {
		SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		if (!CommonInfectedModel(entity, FALLEN_SURVIVOR_MODEL)) AcceptEntityInput(entity, "BecomeRagdoll");
		else SetEntProp(entity, Prop_Data, "m_iHealth", 1);
	}
	return true;
}

public OnEntityDestroyed(entity) {
	// if (IsFallenSurvivor(entity)) {
	// 	new defibOrMedkit = GetRandomInt(1,2);
	// }
	if (!b_IsActiveRound || !IsCommonInfected(entity)) return;
	if (!IsSpecialCommon(entity)) ClearSpecialCommon(entity);
	OnCommonInfectedCreated(entity, true);
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		int ent = FindListPositionByEntity(entity, CommonInfected[i]);
		if (ent >= 0) RemoveFromArray(CommonInfected[i], ent);
	}
	SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	//SDKUnhook(entity, SDKHook_TraceAttack, OnTraceAttack);
}

// bool:IsFallenSurvivor(entity) {
// 	if (entity <= 0 || !IsValidEntity(entity)) return false;
// 	char classname[64];
// 	GetEntityClassname(entity, classname, sizeof(classname));
// 	return strcmp(classname, "fallen") == 0;
// }

bool IsPlayerZoomed(client) {
	return (GetEntPropEnt(client, Prop_Send, "m_hZoomOwner") == -1) ? false : true;
}

/*bool:IsPlayerHoldingFire(client) {
	if (GetEntityFlags(client) & IN_ATTACK) return true;
	return false;
}*/

stock GetRockOwner(ent) {
	float fTankPos[3];
	float fRockPos[3];
	int tank = -1;
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fRockPos);
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_INFECTED || FindZombieClass(i) != ZOMBIECLASS_TANK) continue;
		GetClientAbsOrigin(i, fTankPos);
		if (GetVectorDistance(fTankPos, fRockPos) >= 64.0) continue;

		tank = i;
		break;
	}
	if (tank != -1) {
		PrintToChatAll("\x04Tank \x03evolves \x04into Burn Tank!");
		ChangeTankState(tank, "burn");
		FindRandomSurvivorClient(tank, true);
		IsPlayerOnGroundOutsideOfTankZone(tank);
	}
}

public OnEntityCreated(entity, const char[] classname) {

	//if (!b_IsActiveRound) return;
	OnEntityCreatedEx(entity, classname);
}

stock OnEntityCreatedEx(entity, const char[] classname, bool creationOverride = false) {
	if (!b_IsActiveRound && IsCommonInfected(entity)) {
		AcceptEntityInput(entity, "Kill");
		return;
	}
	if (StrEqual(classname, "tank_rock", false)) {
		//CreateTimer(1.4, Timer_DestroyRock, entity, TIMER_FLAG_NO_MAPCHANGE);
		GetRockOwner(entity);
		return;
	}
	if (b_IsActiveRound && IsWitch(entity)) {
		//SetInfectedHealth(entity, 50000);
		OnWitchCreated(entity);
	}
	if (creationOverride || IsCommonInfected(entity)) {
		// SetInfectedHealth(entity, 500);
		if (CreateCommonAffix(entity) == 0) {
			if (GetArraySize(CommonInfectedQueue) > 0) {
				char Model[64];
				GetArrayString(CommonInfectedQueue, 0, Model, sizeof(Model));
				if (IsModelPrecached(Model)) SetEntityModel(entity, Model);
				RemoveFromArray(CommonInfectedQueue, 0);
			}
			OnCommonInfectedCreated(entity);
		}
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		//SDKHook(entity, SDKHook_TraceAttack, OnTraceAttack);
	}
}

bool IsWitch(entity) {

	if (entity <= 0 || !IsValidEntity(entity)) return false;

	char className[16];
	GetEntityClassname(entity, className, sizeof(className));
	return strcmp(className, "witch") == 0;
}

bool IsCommonInfected(entity) {
	if (entity <= 0 || !IsValidEntity(entity)) return false;
	char className[16];
	GetEntityClassname(entity, className, sizeof(className));
	return strcmp(className, "infected") == 0;
}

stock ExperienceBarBroadcast(client, char[] sStatusEffects) {

	char eBar[64];
	char currExperience[64];
	char currExperienceTarget[64];
	if (GetClientTeam(client) == TEAM_SURVIVOR) {
		ExperienceBar(client, eBar, sizeof(eBar));
		AddCommasToString(ExperienceLevel[client], currExperience, sizeof(currExperience));
		AddCommasToString(CheckExperienceRequirement(client), currExperienceTarget, sizeof(currExperienceTarget));

		if (BroadcastType == 0) PrintHintText(client, "%T", "Hint Text Broadcast 0", client, eBar);
		if (BroadcastType == 1) PrintHintText(client, "%T", "Hint Text Broadcast 1", client, eBar, currExperience, currExperienceTarget);
		if (BroadcastType == 2) PrintHintText(client, "%T", "Hint Text Broadcast 2", client, eBar, currExperience, currExperienceTarget, Points[client]);
	}
	else if (GetClientTeam(client) == TEAM_INFECTED) {

		ExperienceBar(client, eBar, sizeof(eBar), 1);	// armor
		char aBar[64];
		ExperienceBar(client, aBar, sizeof(aBar), 2);	// actual health
		int tHealth = GetArrayCell(InfectedHealth[client], 0, 5);	// total health
		int dHealth = GetArrayCell(InfectedHealth[client], 0, 6);	// damage to health

		AddCommasToString(tHealth - dHealth, currExperience, sizeof(currExperience));
		AddCommasToString(tHealth, currExperienceTarget, sizeof(currExperienceTarget));

		PrintHintText(client, "%T", "Infected Health Broadcast", client, eBar, aBar, currExperience, currExperienceTarget, sStatusEffects);
	}
}

stock CheckTankingDamage(infected, client) {

	int pos = -1;
	int cDamage = 0;

	bool bIsLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;

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
	// Have decided commons shouldn't award tanking damage; it's too easy to abuse.

	if (pos < 0) return 0;

	if (bIsLegitimateClient) cDamage = GetArrayCell(InfectedHealth[client], pos, 3);
	else if (bIsWitch) cDamage = GetArrayCell(WitchDamage[client], pos, 3);
	else if (bIsSpecialCommon) cDamage = GetArrayCell(SpecialCommon[client], pos, 3);
	
	/*

		If the player dealt more damage to the special than took damage from it, they do not receive tanking rewards.
	*/
	return cDamage;
}

stock WipeDamageContribution(client) {

	/*

		This function will completely wipe out a players contribution and earnings.
		Use this when a player dies to essentially "give back" the health equal to contribution.
		Other players can then earn the contribution that is restored, albeit a mob that was about to die would
		suddenly gain a bunch of its life force back.
	*/
	if (IsLegitimateClient(client)) {

		ClearArray(InfectedHealth[client]);
		ClearArray(WitchDamage[client]);
		ClearArray(SpecialCommon[client]);
	}
}

stock float CheckTeammateDamages(infected, client = -1, bool bIsMyDamageOnly = false, bool skipMyDamage = false) {

	/*

		Common Infected have a shared-health pool, as a result we compare a players
		damage only when considering commons damage; the player who deals the killing blow
		on a common will receive the bonus.

		However, special commons and special infected will have separate health pools.
	*/

	float isDamageValue = 0.0;
	int pos = -1;
	int cHealth = 0;
	int tHealth = 0;
	float tBonus = 0.0;
	int enemytype = -1;
	if (IsLegitimateClient(infected)) enemytype = 0;
	else if (IsWitch(infected)) enemytype = 1;
	else if (IsSpecialCommon(infected)) enemytype = 2;
	else if (IsCommonInfected(infected)) enemytype = 3;
	else return 0.0;
	//else if (IsCommonInfected(infected)) enemytype = 3;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (skipMyDamage && client == i) continue;
		if (bIsMyDamageOnly && client != i) continue;
		/*
			isDamageValue is a percentage of the total damage a player has dealt to the special infected.
			We calculate this by taking the player damage contribution and dividing it by the total health of the infected.
			we then add this value, and return the total of all players.
			if the value > or = to 1.0, the infected player dies.

			This health bar will display two health bars.
			True health: The actual health the infected player has remaining
			E. Health: The health the infected has FOR YOU
		*/
		if (enemytype == 0) {

			pos = FindListPositionByEntity(infected, InfectedHealth[i]);
			if (pos < 0) continue;	// how?
			cHealth = GetArrayCell(InfectedHealth[i], pos, 2);
			tHealth = GetArrayCell(InfectedHealth[i], pos, 1);
		}
		else if (enemytype == 1) {

			pos = FindListPositionByEntity(infected, WitchDamage[i]);
			if (pos < 0) continue;
			cHealth = GetArrayCell(WitchDamage[i], pos, 2);
			tHealth = GetArrayCell(WitchDamage[i], pos, 1);
		}
		else if (enemytype == 2) {

			pos = FindListPositionByEntity(infected, SpecialCommon[i]);
			if (pos < 0) continue;
			cHealth = GetArrayCell(SpecialCommon[i], pos, 2);
			tHealth = GetArrayCell(SpecialCommon[i], pos, 1);
		}
		else if (enemytype == 3) {

			pos = FindListPositionByEntity(infected, CommonInfected[i]);
			if (pos < 0) continue;
			cHealth = GetArrayCell(CommonInfected[i], pos, 2);
			tHealth = GetArrayCell(CommonInfected[i], pos, 1);
		}
		tBonus = (cHealth * 1.0) / (tHealth * 1.0);
		isDamageValue += tBonus;
	}
	//PrintToChatAll("Damage percent: %3.3f", isDamageValue);
	if (isDamageValue > 1.0) isDamageValue = 1.0;
	return isDamageValue;
}

stock DisplayInfectedHealthBars(survivor, infected) {

	if (iRPGMode == -1) return;

	char text[512];
	bool c = false;
	if (IsLegitimateClient(infected)) GetClientName(infected, text, sizeof(text));
	else if (IsWitch(infected)) Format(text, sizeof(text), "Bitch");
	else if (IsCommonInfected(infected)) {
		if (IsSpecialCommon(infected)) {
			GetCommonValueAtPos(text, sizeof(text), infected, SUPER_COMMON_NAME);
			if (StrEqual(text, "-1")) {
				// a weird error so let's kill the infected mob and wipe it from player data.
				ForceClearSpecialCommon(infected);
				return;
			}
		}
		else {
			Format(text, sizeof(text), "Common");
			c = true;
		}
	}

	//Format(text, sizeof(text), "%s %s", GetConfigValue("director team name?"), text);
	GetInfectedHealthBar(survivor, infected, false, clientContributionHealthDisplay[survivor], sizeof(clientContributionHealthDisplay[]));
	if (LivingSurvivors() > 1 && !c) {
		GetInfectedHealthBar(survivor, infected, true, clientTrueHealthDisplay[survivor], sizeof(clientTrueHealthDisplay[]));
		Format(text, sizeof(text), "E.HP%s(%s)\nCNT%s", clientTrueHealthDisplay[survivor], text, clientContributionHealthDisplay[survivor]);
	}
	else Format(text, sizeof(text), "CNT%s(%s)", clientContributionHealthDisplay[survivor], text);
	PrintCenterText(survivor, text);
}
// effecttype 0 -> negative
// effecttype 1 -> positive
stock GetStatusEffects(client, EffectType = 0, char[] theStringToStoreItIn, theSizeOfTheString) {

	int Count = 0;
	int iNumStatusEffects = 0;
	// NEGATIVE effects
	//new printClient = client;

	//char TargetName[64];
	//GetClientAimTargetEx(client, TargetName, sizeof(TargetName), true);
	//client = StringToInt(TargetName);
	//if (!IsLegitimateClientAlive(client) || GetClientTeam(client) != GetClientTeam(printClient)) client = printClient;
	int clientFlags = GetEntityFlags(client);
	int clientButtons = GetEntProp(client, Prop_Data, "m_nButtons");
	if (EffectType == 0) {

		//new AcidCount = GetClientStatusEffect(client, Handle:EntityOnFire, "acid");
		int FireCount = GetClientStatusEffect(client, "burn");
		int AcidCount = GetClientStatusEffect(client, "acid");
		Format(theStringToStoreItIn, theSizeOfTheString, "[-]");
		if (DoomTimer != 0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Dm%d]", theStringToStoreItIn, iDoomTimer - DoomTimer);
		if (bIsSurvivorFatigue[client]) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Fa]", theStringToStoreItIn);

		//Count = GetClientStatusEffect(client, "burn");
		if (FireCount > 0) iNumStatusEffects++;
		if (FireCount >= 3) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bu++]", theStringToStoreItIn);
		else if (FireCount >= 2) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bu++]", theStringToStoreItIn);
		else if (FireCount > 0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bu]", theStringToStoreItIn);

		//Count = GetClientStatusEffect(client, "acid");
		if (AcidCount > 0) iNumStatusEffects++;
		if (AcidCount >= 3) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ab++]", theStringToStoreItIn);
		else if (AcidCount >= 2) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ab+]", theStringToStoreItIn);
		else if (AcidCount > 0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ab]", theStringToStoreItIn);

		Count = GetClientStatusEffect(client, "reflect");
		if (Count > 0) iNumStatusEffects++;
		if (Count >= 3) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Re++]", theStringToStoreItIn);
		else if (Count >= 2) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Re+]", theStringToStoreItIn);
		else if (Count > 0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Re]", theStringToStoreItIn);

		if (ISBLIND[client] != INVALID_HANDLE) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bl]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (ISEXPLODE[client] != INVALID_HANDLE || IsClientInRangeSpecialAmmo(client, "x") > 0.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ex]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (ISFROZEN[client] != INVALID_HANDLE) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Fr]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		float isSlowSpeed = IsClientInRangeSpecialAmmo(client, "s");
		if (ISSLOW[client] || isSlowSpeed > 0.0) {
			if (isSlowSpeed > 0.0) playerInSlowAmmo[client] = true;
			else playerInSlowAmmo[client] = false;
			if (fSlowSpeed[client] == 1.0) {
				if (ISSLOW[client]) ISSLOW[client] = false;
			}
			else {
				if (fSlowSpeed[client] < 1.0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Sl]", theStringToStoreItIn);
				else Format(theStringToStoreItIn, theSizeOfTheString, "%s[Sp]", theStringToStoreItIn);
				iNumStatusEffects++;
			}
		}
		//if (ISSLOW[client] != INVALID_HANDLE) Format(theStringToStoreItIn, theSizeOfTheString, "[Sl]%s", theStringToStoreItIn);
		
		if (ISFROZEN[client] != INVALID_HANDLE && FireCount > 0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[St]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (FireCount > 0 && AcidCount > 0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Sc]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (!(clientFlags & FL_ONGROUND)) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Fl]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (bIsInCombat[client]) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ic]", theStringToStoreItIn);
		if (ISBILED[client]) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bi]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (ISDAZED[client] > GetEngineTime()) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Dz]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		if (bHasWeakness[client] > 0) {

			if (bHasWeakness[client] < 3) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Wk]", theStringToStoreItIn);
			else Format(theStringToStoreItIn, theSizeOfTheString, "%s[Shadow]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		if (IsSpecialCommonInRange(client, 'd')) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Re]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		/*if (IsActiveAmmoCooldown(client, 'H')) Format(theStringToStoreItIn, theSizeOfTheString, "[HeA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'h')) Format(theStringToStoreItIn, theSizeOfTheString, "[LeA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'b')) Format(theStringToStoreItIn, theSizeOfTheString, "[BeA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 's')) Format(theStringToStoreItIn, theSizeOfTheString, "[SlA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'x')) Format(theStringToStoreItIn, theSizeOfTheString, "[ExA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'g')) Format(theStringToStoreItIn, theSizeOfTheString, "[GrA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'B')) Format(theStringToStoreItIn, theSizeOfTheString, "[BiA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'O')) Format(theStringToStoreItIn, theSizeOfTheString, "[OdA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'E')) Format(theStringToStoreItIn, theSizeOfTheString, "[BkA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'a')) Format(theStringToStoreItIn, theSizeOfTheString, "[AdA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'W')) Format(theStringToStoreItIn, theSizeOfTheString, "[DkA]%s", theStringToStoreItIn);*/

		//if (printClient != client) Format(theStringToStoreItIn, theSizeOfTheString, "%s\n%s", TargetName, theStringToStoreItIn);
	}
	else if (EffectType == 1) {		// POSITIVE EFFECTS

		Format(theStringToStoreItIn, theSizeOfTheString, "[+]");
		//if (printClient != client) Format(theStringToStoreItIn, theSizeOfTheString, "%s\n%s", TargetName, theStringToStoreItIn);
		if (!bIsInCombat[client]) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Oc]", theStringToStoreItIn);
		// if (IsClientInRangeSpecialAmmo(client, "b") == -2.0) {
		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Be]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		if ((clientButtons & IN_DUCK)) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Cr]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		// if (IsClientInRangeSpecialAmmo(client, "h") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Le]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "g") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Gr]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "H") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[He]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "d") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Da]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "D") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ds]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "R") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Re]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "B") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bi]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "O") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Od]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		// if (IsClientInRangeSpecialAmmo(client, "E") == -2.0) {

		// 	Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bk]", theStringToStoreItIn);
		// 	iNumStatusEffects++;
		// }
		if (HasAdrenaline(client)) {
			// we need to add a boolean here as well so methods that need this information don't loop in perpetuity.
			playerHasAdrenaline[client] = true;
			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ad]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		else playerHasAdrenaline[client] = false;
		if (clientFlags & FL_INWATER) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Wa]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
	}
	Format(ClientStatusEffects[client][EffectType], 64, "%s", theStringToStoreItIn);
	//PrintToChat(client, "%s", ClientStatusEffects[client][EffectType]);
	//if (EffectType == 0) Format(theStringToStoreItIn, theSizeOfTheString, "[-]%s", theStringToStoreItIn);
	//else Format(theStringToStoreItIn, theSizeOfTheString, "[+]%s", theStringToStoreItIn);

	if (IsPvP[client] != 0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[PvP]", theStringToStoreItIn);

	MyStatusEffects[client] = iNumStatusEffects;
}

/*stock ToggleTank(client, bool:bDisableTank = false) {

	if (!bDisableTank && (!IsValidEntity(MyVomitChase[client]) || MyVomitChase[client] == -1)) {

		char TargetName[64];

		if (IsValidEntity(MyVomitChase[client])) {

			AcceptEntityInput(MyVomitChase[client], "Kill");
			MyVomitChase[client] = -1;
		}
		MyVomitChase[client] = CreateEntityByName("info_goal_infected_chase");
		if (IsValidEntity(MyVomitChase[client])) {

			new Float:ClientPos[3];
			GetClientAbsOrigin(client, ClientPos);
			ClientPos[2] += 20.0;

			DispatchKeyValueVector(MyVomitChase[client], "origin", ClientPos);
			Format(TargetName, sizeof(TargetName), "goal_infected%d", client);
			DispatchKeyValue(MyVomitChase[client], "targetname", TargetName);
			GetClientName(client, TargetName, sizeof(TargetName));
			DispatchKeyValue(client, "parentname", TargetName);
			DispatchSpawn(MyVomitChase[client]);
			SetVariantString(TargetName);
			AcceptEntityInput(MyVomitChase[client], "SetParent", MyVomitChase[client], MyVomitChase[client], 0);
			ActivateEntity(MyVomitChase[client]);
			AcceptEntityInput(MyVomitChase[client], "Enable");
		}
	}
	else if (bDisableTank) {

		if (IsValidEntity(MyVomitChase[client])) AcceptEntityInput(MyVomitChase[client], "Kill");
		MyVomitChase[client] = -1;
	}
}*/

stock bool IsClientCleansing(client) {

	if (IsClientInRangeSpecialAmmo(client, "C") > 0.0) return true;// && !IsPlayerFeeble(client)) return true;
	return false;
}

stock bool IsActiveAmmoCooldown(client, effect = '0', char[] activeTalentSearchKey = "none") {
	char result[2][64];
	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", effect);
	int size = GetArraySize(PlayerActiveAmmo[client]);
	int pos = -1;
	char text[64];
	for (int i = 0; i < size; i++) {
		pos = GetArrayCell(PlayerActiveAmmo[client], i);
		GetTalentNameAtMenuPosition(client, pos, result[0], sizeof(result[]));
		if (pos < 0) continue;	// wtf?
		//ActiveAmmoCooldownKeys[client]				= GetArrayCell(a_Menu_Talents, pos, 0);
		ActiveAmmoCooldownValues[client]			= GetArrayCell(a_Menu_Talents, pos, 1);
		if (StrEqual(activeTalentSearchKey, "none")) {
			GetArrayString(ActiveAmmoCooldownValues[client], SPELL_AMMO_EFFECT, text, sizeof(text));
			if (StrContains(text, EffectT, true) == -1) continue;
		}
		else {
			GetArrayString(ActiveAmmoCooldownValues[client], ABILITY_ACTIVE_EFFECT, text, sizeof(text));
			if (!StrEqual(text, activeTalentSearchKey, true)) continue;	// case sensitive
		}
		if (CheckActiveAmmoCooldown(client, result[0]) == 2) return true;
	}
	return false;
}

stock GetSpecialAmmoEffect(char[] TheValue, TheSize, client, char[] TalentName) {
	int pos			= GetMenuPosition(client, TalentName);
	if (pos >= 0) {
		SpecialAmmoEffectValues[client]			= GetArrayCell(a_Menu_Talents, pos, 1);

		GetArrayString(SpecialAmmoEffectValues[client], SPELL_AMMO_EFFECT, TheValue, TheSize);
	}
}

stock GetPlayerStamina(client) {

	/*

		This function gets a players maximum stamina, which is important so they don't regenerate beyond it.
	*/
	/*new StaminaMax = GetConfigValueInt("survivor stamina?");
	new StaminaMax_Temp = 0;
	new Endu = GetTalentStrength(client, "endurance");
	for (new i = 0; i < Endu; i++) {

		StaminaMax_Temp += RoundToCeil(StaminaMax * GetConfigValueFloat("endurance stam?"));
	}
	StaminaMax += StaminaMax_Temp;*/

	int StaminaMax = iSurvivorStaminaMax + RoundToCeil(PlayerLevel[client] * fStaminaPerPlayerLevel) + RoundToCeil(SkyLevel[client] * fStaminaPerSkyLevel);
	int StaminaBonus = RoundToCeil(GetAbilityStrengthByTrigger(client, client, "getstam", _, 0, _, _, "stamina", _, _, 2));
	if (StaminaBonus > 0) StaminaMax += StaminaBonus;

	float TheAbilityMultiplier = 0.0;
	TheAbilityMultiplier = GetAbilityMultiplier(client, "T");
	//if (TheAbilityMultiplier == -1.0) TheAbilityMultiplier = 0.0;	// no change
	if (TheAbilityMultiplier != -1) StaminaMax += RoundToCeil(StaminaMax * TheAbilityMultiplier);
	// Here we make sure that the players current stamina never goes above their maximum stamina.
	if (SurvivorStamina[client] > StaminaMax) SurvivorStamina[client] = StaminaMax;
	return StaminaMax;
}

// Not needed until versus support is added, and that won't be until infected talents are added.
// stock DisplayInfectedHUD(client, statusType) {
// 	GetStatusEffects(client, statusType, clientStatusEffectDisplay[client], sizeof(clientStatusEffectDisplay[]));
// 	ExperienceBarBroadcast(client, clientStatusEffectDisplay[client]);
// }

stock DisplayHUD(client, statusType) {

	if (iRPGMode >= 1) {
		GetStatusEffects(client, 0, negativeStatusEffects[client], sizeof(negativeStatusEffects[]));
		GetStatusEffects(client, 1, positiveStatusEffects[client], sizeof(positiveStatusEffects[]));

		if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_INFECTED && !IsFakeClient(client)) {

			int healthremaining = GetHumanInfectedHealth(client);
			if (healthremaining > 0) SetEntityHealth(client, GetHumanInfectedHealth(client));
		}

		char text[64];
		//char text2[64];
		char testelim[1];
		char EnemyName[64];
		float TargetPos[3];
		char hitgroup[4];
		int enemycombatant = GetAimTargetPosition(client, TargetPos, hitgroup, 4);
		int enemytype = -1;
		//GetClientAimTargetEx(client, EnemyName, sizeof(EnemyName), true);
		//new enemycombatant = LastAttackedUser[client];
		//new enemycombatant = StringToInt(EnemyName);
		//if (!IsWitch(enemycombatant) && !IsLegitimateClientAlive(enemycombatant) || IsLegitimateClientAlive(enemycombatant) && !IsFakeClient(enemycombatant)) enemycombatant = -1;
		if (IsSpecialCommon(enemycombatant)) enemytype = 0;
		else if (IsCommonInfected(enemycombatant)) enemytype = 3;
		else if (IsWitch(enemycombatant)) enemytype = 1;
		else if (IsLegitimateClientAlive(enemycombatant)) enemytype = 2;
		
		if (enemytype != -1) {
			if (iDisplayHealthBars == 1) DisplayInfectedHealthBars(client, enemycombatant);
			if (enemytype == 3) Format(EnemyName, sizeof(EnemyName), "Common");
			else if (enemytype == 0) GetCommonValueAtPos(EnemyName, sizeof(EnemyName), enemycombatant, SUPER_COMMON_NAME);
			else if (enemytype == 1) Format(EnemyName, sizeof(EnemyName), "Witch");
			else GetClientName(enemycombatant, EnemyName, sizeof(EnemyName));
		}
		else enemycombatant = -1;
		Format(testelim, sizeof(testelim), " ");
		if (enemytype == 2 && GetClientTeam(enemycombatant) == TEAM_SURVIVOR) {

			char TheClass[64];
			int myClassLevel = CartelLevel(enemycombatant);
			if (myClassLevel < 0) myClassLevel = 0;

			Format(TheClass, sizeof(TheClass), "%T", "Vanilla", client);
			//}
			//Format(EnemyName, sizeof(EnemyName), "%s %s Lv.%d", TheClass, EnemyName, PlayerLevel[enemycombatant]);
			//if (IsPvP[enemycombatant] != 0) Format(EnemyName, sizeof(EnemyName), "%s[PvP]", EnemyName);
		}

		//if (!StrEqual(ActiveSpecialAmmo[client], "none")) Format(text, sizeof(text), "HC %s %s STA %s %s %s", testelim, testelim, testelim, testelim, ActiveSpecialAmmo[client]);
		char targetHealthText[16];
		char targetMaxHealthText[16];
		int enemyHealth = -1;
		if (enemytype != -1) enemyHealth = GetTargetHealth(client, enemycombatant);
		if (bJetpack[client]) {

			int PlayerMaxStamina = GetPlayerStamina(client);
			float PlayerCurrStamina = ((SurvivorStamina[client] * 1.0) / (PlayerMaxStamina * 1.0)) * 100.0;

			char pct[4];
			Format(pct, sizeof(pct), "%");

			Format(text, sizeof(text), "Jetpack Fuel: %3.2f%s\n%s %s", PlayerCurrStamina, pct, positiveStatusEffects[client], negativeStatusEffects[client]);
		}
		else if (iShowDetailedDisplayAlways == 1 && enemytype != -1 && enemyHealth > 0 && !StrEqual(EnemyName, "-1")) {
			if (enemytype != 2 || GetClientTeam(enemycombatant) != TEAM_SURVIVOR) {
				AddCommasToString(enemyHealth, targetHealthText, sizeof(targetHealthText));
				int infectedHealthVal = GetInfectedHealthBar(client, enemycombatant, _, targetMaxHealthText, _, true);
				if (infectedHealthVal > 0) {
					AddCommasToString(infectedHealthVal, targetMaxHealthText, sizeof(targetMaxHealthText));
					Format(text, sizeof(text), "%s: %s/%sHP\n%s\n%s", EnemyName, targetHealthText, targetMaxHealthText, positiveStatusEffects[client], negativeStatusEffects[client]);
				}
				else Format(text, sizeof(text), "%s: %sHP\n%s\n%s", EnemyName, targetHealthText, positiveStatusEffects[client], negativeStatusEffects[client]);
			}
			else if (GetClientTeam(enemycombatant) == TEAM_SURVIVOR) {
				AddCommasToString(GetTargetHealth(client, enemycombatant, true), targetHealthText, sizeof(targetHealthText));
				AddCommasToString(GetMaximumHealth(enemycombatant), targetMaxHealthText, sizeof(targetMaxHealthText));
				Format(text, sizeof(text), "%s: %s/%sHP\n%s\n%s", EnemyName, targetHealthText, targetMaxHealthText, positiveStatusEffects[client], negativeStatusEffects[client]);
			}
		}
		else {
			Format(text, sizeof(text), "%s\n%s", positiveStatusEffects[client], negativeStatusEffects[client]);
		}
		if (strlen(text) > 1) PrintHintText(client, text);
	}
}

stock GetPlayerStaminaBar(client, char[] eBar, theSize) {

	Format(eBar, theSize, "[----------]");
	if (IsLegitimateClientAlive(client)) {

		/*

			Players have a stamina bar.
		*/

		float eCnt = 0.0;
		float ePct = (SurvivorStamina[client] * 1.0 / (GetPlayerStamina(client) * 1.0)) * 100.0;
		for (int i = 1; i < strlen(eBar); i++) {

			if (eCnt + 10.0 <= ePct) {

				eBar[i] = '~';
				eCnt += 10.0;
			}
		}
	}
}

stock float GetTankingContribution(survivor, infected) {

	int TotalHealth = 0;
	int DamageTaken = 0;

	bool bLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;

	int pos = -1;
	if (IsLegitimateClient(infected)) {
		pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
		bLegitimateClient = true;
	}
	else if (IsWitch(infected)) {
		pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
		bIsWitch = true;
	}
	else if (IsSpecialCommon(infected)) {
		pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);
		bIsSpecialCommon = true;
	}

	if (pos < 0) return 0.0;

	if (bIsWitch) {

		TotalHealth		= GetArrayCell(WitchDamage[survivor], pos, 1);
		DamageTaken		= GetArrayCell(WitchDamage[survivor], pos, 3);
	}
	else if (bIsSpecialCommon) {

		TotalHealth		= GetArrayCell(SpecialCommon[survivor], pos, 1);
		DamageTaken		= GetArrayCell(SpecialCommon[survivor], pos, 3);
	}
	else if (bLegitimateClient && GetClientTeam(infected) == TEAM_INFECTED) {

		TotalHealth		= GetArrayCell(InfectedHealth[survivor], pos, 1);
		DamageTaken		= GetArrayCell(InfectedHealth[survivor], pos, 3);
	}
	if (DamageTaken == 0) return 0.0;
	if (DamageTaken > TotalHealth) return 1.0;
	//new Float:TheDamageTaken = (DamageTaken * 1.0) / (TotalHealth * 1.0);
	return ((DamageTaken * 1.0) / (TotalHealth * 1.0));
}

stock GetTargetHealth(client, target, bool MyHealth = false) {

	int TotalHealth = 0;
	int DamageDealt = 0;
	int pos = -1;
	bool bIsSpecialCommon;
	bool bIsCommonInfected;
	bool bIsWitch;
	bool bIsLegitimateClient;
	if (IsSpecialCommon(target)) {
		pos = FindListPositionByEntity(target, SpecialCommon[client]);
		bIsSpecialCommon = true;
	}
	else if (IsCommonInfected(target)) {
		pos = FindListPositionByEntity(target, CommonInfected[client]);
		bIsCommonInfected = true;
	}
	else if (IsWitch(target)) {
		pos = FindListPositionByEntity(target, WitchDamage[client]);
		bIsWitch = true;
	}
	else if (IsLegitimateClientAlive(target)) {
		if (GetClientTeam(target) == TEAM_INFECTED) {
			pos = FindListPositionByEntity(target, InfectedHealth[client]);
			bIsLegitimateClient = true;
		}
		else return GetClientHealth(target);
	}

	if (pos >= 0) {
		if (bIsWitch) {
			TotalHealth		= GetArrayCell(WitchDamage[client], pos, 1);
			DamageDealt		= GetArrayCell(WitchDamage[client], pos, 2);
		}
		else if (bIsLegitimateClient) {
			TotalHealth		= GetArrayCell(InfectedHealth[client], pos, 1);
			DamageDealt		= GetArrayCell(InfectedHealth[client], pos, 2);
		}
		else if (bIsSpecialCommon) {
			TotalHealth		= GetArrayCell(SpecialCommon[client], pos, 1);
			DamageDealt		= GetArrayCell(SpecialCommon[client], pos, 2);
		}
		else if (bIsCommonInfected) {
			TotalHealth		= GetArrayCell(CommonInfected[client], pos, 1);
			DamageDealt		= GetArrayCell(CommonInfected[client], pos, 2);
		}
		if (!MyHealth) TotalHealth = RoundToCeil((1.0 - CheckTeammateDamages(target, client)) * TotalHealth);
		else TotalHealth -= DamageDealt;
	}
	return TotalHealth;
}

stock GetHumanInfectedHealth(client) {

	float isHealthRemaining = CheckTeammateDamages(client);
	return RoundToCeil(GetMaximumHealth(client) * isHealthRemaining);
}

stock float GetClientHealthPercentageSurvivor(client, bool GetHealthRemaining = false) {
	float fHealthRemaining = (GetClientHealth(client) * 1.0) / (GetMaximumHealth(client) * 1.0);
	if (GetHealthRemaining) return fHealthRemaining;
	return 1.0 - fHealthRemaining;
}

stock bool IsInfectedTarget(client) {
	if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_INFECTED) return true;
	if (IsWitch(client) || IsSpecialCommon(client) || IsCommonInfected(client)) return true;
	return false;
}

stock float GetClientHealthPercentage(client, target, bool GetHealthRemaining = false) {
	int pos = -1;
	if (IsLegitimateClient(target)) {
		if (GetClientTeam(target) == TEAM_INFECTED) pos = FindListPositionByEntity(target, InfectedHealth[client]);
		else return GetClientHealthPercentageSurvivor(target, GetHealthRemaining);
	}
	else if (IsWitch(target)) pos = FindListPositionByEntity(target, WitchDamage[client]);
	else if (IsSpecialCommon(target)) pos = FindListPositionByEntity(target, SpecialCommon[client]);
	else if (IsCommonInfected(target)) pos = FindListPositionByEntity(target, CommonInfected[client]);

	if (pos < 0) return -1.0;
	float fHealthRemaining = CheckTeammateDamages(target, client);
	if (GetHealthRemaining) return 1.0 - fHealthRemaining;
	return fHealthRemaining;
}

stock GetInfectedHealthBar(survivor, infected, bool bTrueHealth = false, char[] eBar, theSize = 64, bool getHealthValue = false) {
	if (!getHealthValue) Format(eBar, theSize, "[----------------------------------------]");
	int pos = 0;
	bool bIsLegitimateClient;
	bool bIsWitch;
	bool bIsSpecialCommon;
	if (IsLegitimateClient(infected)) {
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
	}
	if (pos >= 0) {
		float isHealthRemaining = 1.0;
		isHealthRemaining = CheckTeammateDamages(infected, survivor);
		// isDamageContribution is the total damage the player has, themselves, dealt to the special infected.
		int isDamageContribution = 0;
		int isTotalHealth = 0;
		if (bIsLegitimateClient) {
			isDamageContribution = GetArrayCell(InfectedHealth[survivor], pos, 2);
			isTotalHealth = GetArrayCell(InfectedHealth[survivor], pos, 1);
		}
		else if (bIsWitch) {
			isDamageContribution = GetArrayCell(WitchDamage[survivor], pos, 2);
			isTotalHealth = GetArrayCell(WitchDamage[survivor], pos, 1);
		}
		else if (bIsSpecialCommon) {
			isDamageContribution = GetArrayCell(SpecialCommon[survivor], pos, 2);
			isTotalHealth = GetArrayCell(SpecialCommon[survivor], pos, 1);
		}
		else {
			isDamageContribution = GetArrayCell(CommonInfected[survivor], pos, 2);
			isTotalHealth = GetArrayCell(CommonInfected[survivor], pos, 1);
		}
		if (getHealthValue) return isTotalHealth;
		//new Float:tPct = 100.0 - (isHealthRemaining * 100.0);
		//new Float:yPct = ((isDamageContribution * 1.0) / (isTotalHealth * 1.0) * 100.0);
		float ePct = 0.0;
		if (bTrueHealth) ePct = 100.0 - (isHealthRemaining * 100.0);
		else ePct = ((isDamageContribution * 1.0) / (isTotalHealth * 1.0) * 100.0);
		float eCnt = 0.0;
		for (int i = 1; i + 1 < strlen(eBar); i++) {
			if (eCnt + 2.5 < ePct) {
				eBar[i] = '|';
				eCnt += 2.5;
			}
		}
	}
	return 0;
}

stock ExperienceBar(client, char[] sTheString, iTheSize, iBarType = 0, bool bReturnValue = false) {// 0 XP, 1 Infected armor (humans only), 2 Infected Health from talents, etc. (humans only)

	//char eBar[256];
	float ePct = 0.0;
	if (iBarType == 0) ePct = ((ExperienceLevel[client] * 1.0) / (CheckExperienceRequirement(client) * 1.0)) * 100.0;
	else if (iBarType == 1) ePct = 100.0 - CheckTeammateDamages(client) * 100.0;
	else if (iBarType == 2) {

		ePct = (GetArrayCell(InfectedHealth[client], 0, 6) / GetArrayCell(InfectedHealth[client], 0, 5)) * 100.0;
	}
	if (bReturnValue) {

		Format(sTheString, iTheSize, "%3.3f", ePct);
	}
	else {

		float eCnt = 0.0;
		//Format(eBar, sizeof(eBar), "[--------------------]");
		Format(sTheString, iTheSize, "[....................]");

		for (int i = 1; i + 1 <= strlen(sTheString); i++) {

			if (eCnt + 10.0 < ePct) {

				sTheString[i] = '|';
				eCnt += 5.0;
			}
		}
	}

	//return eBar;
}

stock MenuExperienceBar(client, currXP = -1, nextXP = -1, char[] eBar, theSize) {

	float ePct = 0.0;
	if (currXP == -1) currXP = ExperienceLevel[client];
	if (nextXP == -1) nextXP = CheckExperienceRequirement(client);
	ePct = ((currXP * 1.0) / (nextXP * 1.0)) * 100.0;

	float eCnt = 0.0;
	Format(eBar, theSize, "[__________]");

	for (int i = 1; i + 1 <= strlen(eBar); i++) {

		if (eCnt < ePct) {

			eBar[i] = '~';
			eCnt += 10.0;
		}
	}
}

public Action CMD_TeamChatCommand(client, args) {

	if (QuickCommandAccess(client, args, true)) {

		// Set colors for chat
		if (ChatTrigger(client, args, true)) return Plugin_Continue;
		else return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action CMD_ChatCommand(client, args) {

	if (QuickCommandAccess(client, args, false)) {

		// Set Colors for chat
		if (ChatTrigger(client, args, false)) return Plugin_Continue;
		else return Plugin_Handled;
	}
	return Plugin_Handled;
}

stock CartelLevel(client) {

	//new CartelStrength = GetTalentStrength(client, "constitution") + GetTalentStrength(client, "agility") + GetTalentStrength(client, "resilience") + GetTalentStrength(client, "technique") + GetTalentStrength(client, "endurance") + GetTalentStrength(client, "luck");
	//return CartelStrength;
	return PlayerLevel[client];
}

stock bool IsOpenRPGMenu(char[] searchString) {
	char[][] RPGCommands = new char[RPGMenuCommandExplode][16];
	ExplodeString(RPGMenuCommand, ",", RPGCommands, RPGMenuCommandExplode, 16);
	for (int i = 0; i < RPGMenuCommandExplode; i++) {
		if (StrContains(searchString, RPGCommands[i], false) != -1) return true;
	}
	return false;
}

public bool ChatTrigger(client, args, bool teamOnly) {

	if (!IsLegitimateClient(client)) return true;
	char[] sBuffer = new char[MAX_CHAT_LENGTH];
	char[] Message = new char[MAX_CHAT_LENGTH];
	char authString[64];
	GetClientAuthId(client, AuthId_Steam2, authString, sizeof(authString));
	GetCmdArg(1, sBuffer, MAX_CHAT_LENGTH);
	if (sBuffer[0] == '!' && IsOpenRPGMenu(sBuffer)) {
		CMD_OpenRPGMenu(client);
		return false;	// if we want to suppress the chat command
	}
	Format(LastSpoken[client], sizeof(LastSpoken[]), "%s", sBuffer);
	int clientTeam = GetClientTeam(client);
	if (iRPGMode > 0) {
		if (clientTeam == TEAM_SURVIVOR) {
			if (handicapLevel[client] > 0) Format(Message, MAX_CHAT_LENGTH, "{B}[{O}%d{B}] [{G}%d{B}] %s {N}-> {B}%s", handicapLevel[client], PlayerLevel[client], baseName[client], sBuffer);
			else Format(Message, MAX_CHAT_LENGTH, "{B}[{G}%d{B}] %s {N}-> {B}%s", PlayerLevel[client], baseName[client], sBuffer);
		}
		else if (clientTeam == TEAM_INFECTED) Format(Message, MAX_CHAT_LENGTH, "{R}[{G}%d{R}] %s {N}-> {R}%s", PlayerLevel[client], baseName[client], sBuffer);
		else if (clientTeam == TEAM_SPECTATOR) Format(Message, MAX_CHAT_LENGTH, "{GRA}[{G}%d{GRA}] %s {N}-> {GRA}%s", PlayerLevel[client], baseName[client], sBuffer);
		if (SkyLevel[client] >= 1) Format(Message, MAX_CHAT_LENGTH, "{N}Prestige{G}%d %s", SkyLevel[client], Message);
	}

	if (clientTeam == TEAM_SPECTATOR) Format(Message, MAX_CHAT_LENGTH, "{GRA}SPEC %s", Message);
	else {
		if (IsGhost(client)) Format(Message, MAX_CHAT_LENGTH, "{B}GHOST %s", Message);
		else if (!IsPlayerAlive(client)) Format(Message, MAX_CHAT_LENGTH, "{R}DEAD %s", Message);
		else if (IsIncapacitated(client)) Format(Message, MAX_CHAT_LENGTH, "{R}INCAP %s", Message);
	}
	if (teamOnly) {
		if (clientTeam == TEAM_SURVIVOR) Format(Message, MAX_CHAT_LENGTH, "{B}TEAM %s", Message);
		else if (clientTeam == TEAM_INFECTED) Format(Message, MAX_CHAT_LENGTH, "{R}TEAM %s", Message);
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && GetClientTeam(i) == clientTeam) Client_PrintToChat(i, true, Message);
		}
		if (clientTeam == TEAM_SPECTATOR) Format(Spectator_LastChatUser, sizeof(Spectator_LastChatUser), "%s", authString);
		else if (clientTeam == TEAM_SURVIVOR) Format(Survivor_LastChatUser, sizeof(Survivor_LastChatUser), "%s", authString);
		else if (clientTeam == TEAM_INFECTED) Format(Infected_LastChatUser, sizeof(Infected_LastChatUser), "%s", authString);
	}
	else {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i)) Client_PrintToChat(i, true, Message);
		}
	}
	return false;
}

stock GetTargetClient(client, char[] TargetName) {
	char Name[64];
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && i != client && GetClientTeam(i) == GetClientTeam(client)) {
			GetClientName(i, Name, sizeof(Name));
			if (StrContains(Name, TargetName, false) != -1) return i;
		}
	}
	return -1;
}

stock TeamworkRewardNotification(client, target, float PointCost, char[] ItemName) {

	// Client is the user who purchased the item.
	// Target is the user who received it the item.
	// PointCost is the actual price the client paid - to determine their experience reward.
	if (client == target || b_IsFinaleActive) return;
	if (PointCost > fTeamworkExperience) PointCost = fTeamworkExperience;
	// there's no teamwork in 'i'
	int experienceReward	= RoundToCeil(PointCost * (fItemMultiplierTeam * (GetRandomInt(1, GetTalentStrength(client, "luck")) * fItemMultiplierLuck)));
	char ClientName[MAX_NAME_LENGTH];
	GetClientName(client, ClientName, sizeof(ClientName));
	char ItemName_s[64];
	Format(ItemName_s, sizeof(ItemName_s), "%T", ItemName, target);
	PrintToChat(target, "%T", "received item from teammate", target, green, ItemName_s, white, blue, ClientName);
	// {1}{2} {3}purchased and given to you by {4}{5}
	Format(ItemName_s, sizeof(ItemName_s), "%T", ItemName, client);
	GetClientName(target, ClientName, sizeof(ClientName));
	PrintToChat(client, "%T", "teamwork reward notification", client, green, ClientName, white, blue, ItemName_s, white, green, experienceReward);
	// {1}{2} {3}has received {4}{5}{6}: {7}{8}
	if (iExperienceLevelCap < 1 || PlayerLevel[client] < iExperienceLevelCap) {
		ExperienceLevel[client] += experienceReward;
		ExperienceOverall[client] += experienceReward;
		ConfirmExperienceAction(client);
		GetProficiencyData(client, 6, experienceReward);
	}
}

stock GetActiveWeaponSlot(client) {
	if (StrEqual(MyCurrentWeapon[client], "weapon_melee", false) || StrContains(MyCurrentWeapon[client], "pistol", false) != -1 || StrContains(MyCurrentWeapon[client], "chainsaw", false) != -1) return 1;
	return 0;
}

public Action CMD_FireSword(client, args) {
	char Weapon[64];
	int g_iActiveWeaponOffset = 0;
	int iWeapon = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		GetClientWeapon(i, Weapon, sizeof(Weapon));
		if (StrEqual(Weapon, "weapon_melee", false)) {
			g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
			iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
		}
		else {
			if (StrContains(Weapon, "pistol", false) == -1) iWeapon = GetPlayerWeaponSlot(client, 0);
			else iWeapon = GetPlayerWeaponSlot(client, 1);
		}
		if (IsValidEntity(iWeapon)) {
			ExtinguishEntity(iWeapon);
			IgniteEntity(iWeapon, 30.0);
		}
	}
	return Plugin_Handled;
}

public Action CMD_LoadoutName(client, args) {

	if (args < 1) {

		PrintToChat(client, "!loadoutname <name identifier>");
		return Plugin_Handled;
	}
	GetCmdArg(1, LoadoutName[client], sizeof(LoadoutName[]));
	if (strlen(LoadoutName[client]) < 3 || strlen(LoadoutName[client]) > 20) {
		Format(LoadoutName[client], 64, "none");
		PrintToChat(client, "loadout name must be >= 3 && <= 20 characters long.");
		return Plugin_Handled;
	}
	if (StrContains(LoadoutName[client], "SavedProfile", false) != -1) {

		PrintToChat(client, "invalid loadout name, try again.");
		return Plugin_Handled;
	}
	ReplaceString(LoadoutName[client], sizeof(LoadoutName[]), "+", " ");	// this way the delimiter only shows where it's supposed to.
	SQL_EscapeString(hDatabase, LoadoutName[client], LoadoutName[client], sizeof(LoadoutName[]));
	Format(LoadoutName[client], sizeof(LoadoutName[]), "%s", LoadoutName[client]);
	PrintToChat(client, "%T", "loadout name set", client, orange, green, LoadoutName[client]);
	return Plugin_Handled;
}

stock float GetMissingHealth(client) {

	return ((GetClientHealth(client) * 1.0) / (GetMaximumHealth(client) * 1.0));
}

stock bool QuickCommandAccess(client, args, bool b_IsTeamOnly) {

	if (IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SPECTATOR) CMD_CastAction(client, args);
	char Command[64];
	GetCmdArg(1, Command, sizeof(Command));
	StripQuotes(Command);
	if (Command[0] != '/' && Command[0] != '!') return true;

	return QuickCommandAccessEx(client, Command, b_IsTeamOnly);
}

stock bool QuickCommandAccessEx(client, char[] sCommand, bool b_IsTeamOnly = false, bool bGiveProfileItem = false, bool bIsItemExists = false) {

	int TargetClient = -1;
	char SplitCommand[2][64];
	char Command[64];
	Format(Command, sizeof(Command), "%s", sCommand);
	if (!bIsItemExists && !bGiveProfileItem && StrContains(Command, " ", false) != -1) {

		ExplodeString(Command, " ", SplitCommand, 2, 64);
		Format(Command, sizeof(Command), "%s", SplitCommand[0]);
		TargetClient	 = GetTargetClient(client, SplitCommand[1]);
		if (StrContains(Command, "revive", false) != -1 && TargetClient != client) return false;
	//	if (StrContains(Command, "@") != -1 && HasCommandAccess(client, GetConfigValue("reload configs flags?"))) {

		//	if (StrContains(Command, "commons", true) != -1) WipeAllCommons();
			//else if (StrContains(Command, "supercommons", true) != -1) WipeAllCommons(true);
		//}
	}

	char text[512];
	char cost[64];
	char bind[64];
	char pointtext[64];
	char description[512];
	char team[64];
	char CheatCommand[64];
	char CheatParameter[64];
	char Model[64];
	char Count[64];
	char CountHandicap[64];
	char Drop[64];
	float PointCost		= 0.0;
	float PointCostM	= 0.0;
	char MenuName[64];
	float f_GetMissingHealth = 1.0;

	int size					=	0;
	char Description_Old[512];
	char ItemName[64];
	char IsRespawn[64];
	int RemoveClient = -1;
	int iWeaponCat = -1;
	int iTargetClient = -1;
	int iCommonQueueLimit = GetCommonQueueLimit();

	//if (StringToInt(GetConfigValue("rpg mode?")) != 1) BuyItem(client, Command[1]);

	if ((iRPGMode != 1 || !b_IsActiveRound || bIsItemExists || bGiveProfileItem) && iRPGMode >= 0) {

		//GetConfigValue(thetext, sizeof(thetext), "quick bind help?");

		if (StrEqual(Command[1], sQuickBindHelp, false)) {

			size						=	GetArraySize(a_Points);

			for (int i = 0; i < size; i++) {

				MenuKeys[client]		=	GetArrayCell(a_Points, i, 0);
				MenuValues[client]		=	GetArrayCell(a_Points, i, 1);

				//size2					=	GetArraySize(MenuKeys[client]);

				PointCost				= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost?");
				if (PointCost < 0.0) continue;

				PointCostM				= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost minimum?");
				FormatKeyValue(bind, sizeof(bind), MenuKeys[client], MenuValues[client], "quick bind?");
				Format(bind, sizeof(bind), "!%s", bind);
				FormatKeyValue(description, sizeof(description), MenuKeys[client], MenuValues[client], "description?");
				Format(description, sizeof(description), "%T", description, client);
				FormatKeyValue(team, sizeof(team), MenuKeys[client], MenuValues[client], "team?");

				/*
						
						Determine the actual cost for the player.
				*/
				
				if (Points[client] == 0.0 || Points[client] > 0.0 && (Points[client] * PointCost) < PointCostM) PointCost = PointCostM;
				else {

					PointCost += (PointCost * fPointsCostLevel);
					//if (PointCost > 1.0) PointCost = 1.0;
					PointCost *= Points[client];
				}
				Format(cost, sizeof(cost), "%3.3f", PointCost);
				

				if (StringToInt(team) != GetClientTeam(client)) continue;
				Format(pointtext, sizeof(pointtext), "%T", "Points", client);
				Format(pointtext, sizeof(pointtext), "%s %s", cost, pointtext);

				Format(text, sizeof(text), "%T", "Command Information", client, orange, bind, white, green, pointtext, white, blue, description);
				if (StrEqual(Description_Old, bind, false)) continue;		// in case there are duplicates
				Format(Description_Old, sizeof(Description_Old), "%s", bind);
				PrintToConsole(client, text);
			}
			PrintToChat(client, "%T", "Commands Listed Console", client, orange, white, green);
		}
		else {

			size						=	GetArraySize(a_Points);

			int iPreGameFree			=	0;

			for (int i = 0; i < size; i++) {

				MenuKeys[client]		=	GetArrayCell(a_Points, i, 0);
				MenuValues[client]		=	GetArrayCell(a_Points, i, 1);
				MenuSection[client]		=	GetArrayCell(a_Points, i, 2);

				GetArrayString(MenuSection[client], 0, ItemName, sizeof(ItemName));

				PointCost		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost?");
				PointCostM		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost minimum?");
				FormatKeyValue(bind, sizeof(bind), MenuKeys[client], MenuValues[client], "quick bind?");
				FormatKeyValue(team, sizeof(team), MenuKeys[client], MenuValues[client], "team?");
				FormatKeyValue(CheatCommand, sizeof(CheatCommand), MenuKeys[client], MenuValues[client], "command?");
				FormatKeyValue(CheatParameter, sizeof(CheatParameter), MenuKeys[client], MenuValues[client], "parameter?");

				if (bIsItemExists && StrEqual(Command, ItemName)) return true;

				iWeaponCat = GetKeyValueInt(MenuKeys[client], MenuValues[client], "weapon category?");
				if (bGiveProfileItem) {

					if (StrEqual(Command, ItemName)) {

						if (iWeaponCat == 0) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
						else if (iWeaponCat == 1) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);

						if (!StrEqual(CheatCommand, "melee")) ExecCheatCommand(client, CheatCommand, CheatParameter);
						else {

							int ent			= CreateEntityByName("weapon_melee");

							DispatchKeyValue(ent, "melee_script_name", CheatParameter);
							DispatchSpawn(ent);

							EquipPlayerWeapon(client, ent);
						}
						return true;
					}
					continue;
				}

				if (StrEqual(Command[1], bind, false) && StringToInt(team) == GetClientTeam(client)) {		// we found the bind the player used, and the player is on the appropriate team.

					FormatKeyValue(Model, sizeof(Model), MenuKeys[client], MenuValues[client], "model?");
					FormatKeyValue(Count, sizeof(Count), MenuKeys[client], MenuValues[client], "count?");
					FormatKeyValue(CountHandicap, sizeof(CountHandicap), MenuKeys[client], MenuValues[client], "count handicap?");
					FormatKeyValue(Drop, sizeof(Drop), MenuKeys[client], MenuValues[client], "drop?");
					FormatKeyValue(MenuName, sizeof(MenuName), MenuKeys[client], MenuValues[client], "part of menu named?");
					FormatKeyValue(IsRespawn, sizeof(IsRespawn), MenuKeys[client], MenuValues[client], "isrespawn?");
					iPreGameFree = GetKeyValueInt(MenuKeys[client], MenuValues[client], "pre-game free?");

					if (StringToInt(IsRespawn) == 1) {

						if (TargetClient == -1) {

							if (!b_HasDeathLocation[client] || IsPlayerAlive(client) || IsEnrageActive()) return false;
						}
						if (TargetClient != -1) {

							if (IsPlayerAlive(TargetClient) || IsEnrageActive()) return false;
						}
					}
					if (TargetClient != -1 && IsPlayerAlive(TargetClient)) {

						if (IsIncapacitated(TargetClient)) f_GetMissingHealth	= 0.0;	// Player is incapped, has no missing life.
						else f_GetMissingHealth	= GetMissingHealth(TargetClient);
					}

					int ExperienceCost			=	GetKeyValueInt(MenuKeys[client], MenuValues[client], "experience cost?");
					if (ExperienceCost > 0) {

						float fExperienceCostMultiplier = GetKeyValueFloat(MenuKeys[client], MenuValues[client], "experience multiplier?");
						if (fExperienceCostMultiplier == -1.0) fExperienceCostMultiplier = fExperienceMultiplier;
						if (ExperienceCost > 0) ExperienceCost = RoundToCeil(ExperienceCost * (fExperienceCostMultiplier * (PlayerLevel[client] - 1)));
					}
					int TargetClient_s			=	0;

					if (FindCharInString(CheatCommand, ':') != -1) {

						BuildPointsMenu(client, CheatCommand[1], CONFIG_POINTS);		// Always CONFIG_POINTS for quick commands
					}
					else {

						if (GetClientTeam(client) == TEAM_INFECTED) {

							if (StringToInt(CheatParameter) == 8 && ActiveTanks() >= iTankLimitVersus) {

								PrintToChat(client, "%T", "Tank Limit Reached", client, orange, green, iTankLimitVersus, white);
								return false;
							}
							else if (StringToInt(CheatParameter) == 8 && f_TankCooldown != -1.0) {

								PrintToChat(client, "%T", "Tank On Cooldown", client, orange, white);
								return false;
							}
						}
						if (Points[client] == 0.0 || Points[client] > 0.0 && (Points[client] * PointCost) < PointCostM) PointCost = PointCostM;
						else PointCost *= Points[client];

						if (Points[client] >= PointCost ||
							PointCost == 0.0 ||
							(!b_IsActiveRound && iPreGameFree == 1) ||
							GetClientTeam(client) == TEAM_INFECTED && StrEqual(CheatCommand, "change class", false) && StringToInt(CheatParameter) != 8 && (TargetClient == -1 && IsGhost(client) || TargetClient != -1 && IsGhost(TargetClient))) {

							if (!StrEqual(CheatCommand, "change class") ||
								StrEqual(CheatCommand, "change class") && StrEqual(CheatParameter, "8") ||
								StrEqual(CheatCommand, "change class") && (TargetClient == -1 && IsPlayerAlive(client) && !IsGhost(client) || TargetClient != -1 && IsPlayerAlive(TargetClient) && !IsGhost(TargetClient))) {

								if (PointPurchaseType == 0 && (Points[client] >= PointCost || PointCost == 0.0 || (!b_IsActiveRound && iPreGameFree == 1))) {

									if (PointCost > 0.0 && Points[client] >= PointCost || PointCost <= 0.0) {

										if (iPreGameFree != 1 || b_IsActiveRound) Points[client] -= PointCost;
									}
								}
								else if (PointPurchaseType == 1 && (ExperienceLevel[client] >= ExperienceCost || ExperienceCost == 0)) ExperienceLevel[client] -= ExperienceCost;
							}

							if (StrEqual(CheatParameter, "common") && StrContains(Model, ".mdl", false) != -1) {

								Format(Count, sizeof(Count), "%d", StringToInt(Count) + (StringToInt(CountHandicap) * LivingSurvivorCount()));

								for (int iii = StringToInt(Count); iii > 0 && GetArraySize(CommonInfectedQueue) < iCommonQueueLimit; iii--) {

									if (StringToInt(Drop) == 1) {

										ResizeArray(CommonInfectedQueue, GetArraySize(CommonInfectedQueue) + 1);
										ShiftArrayUp(CommonInfectedQueue, 0);
										SetArrayString(CommonInfectedQueue, 0, Model);
										TargetClient_s		=	FindLivingSurvivor();
										if (TargetClient_s > 0) ExecCheatCommand(TargetClient_s, CheatCommand, CheatParameter);
									}
									else PushArrayString(CommonInfectedQueue, Model);
								}
							}
							else if (StrEqual(CheatCommand, "change class")) {

								// We don't give them points back if ghost because we don't take points if ghost.
								//if (IsGhost(client) && PointPurchaseType == 0) Points[client] += PointCost;
								//else if (IsGhost(client) && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
								if ((!IsGhost(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && TargetClient == -1 ||
									TargetClient != -1 && !IsGhost(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_TANK) && PointPurchaseType == 0) Points[client] += PointCost;
								else if ((!IsGhost(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && TargetClient == -1 || TargetClient != -1 && !IsGhost(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_TANK) && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
								else if ((!IsGhost(client) && IsPlayerAlive(client) && FindZombieClass(client) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(client) != -1 && TargetClient == -1 ||
										  TargetClient != -1 && !IsGhost(TargetClient) && IsPlayerAlive(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(TargetClient) == -1) && PointPurchaseType == 0) Points[client] += PointCost;
								else if ((!IsGhost(client) && IsPlayerAlive(client) && FindZombieClass(client) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(client) != -1 && TargetClient == -1 ||
										  TargetClient != -1 && !IsGhost(TargetClient) && IsPlayerAlive(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(TargetClient) == -1) && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
								if (FindZombieClass(client) != ZOMBIECLASS_TANK && TargetClient == -1 || TargetClient != -1 && FindZombieClass(TargetClient) != ZOMBIECLASS_TANK) {

									if (TargetClient == -1) ChangeInfectedClass(client, StringToInt(CheatParameter));
									else ChangeInfectedClass(TargetClient, StringToInt(CheatParameter));

									if (TargetClient != -1) TeamworkRewardNotification(client, TargetClient, PointCost, ItemName);
								}
							}
							else if (StringToInt(IsRespawn) == 1) {

								if (TargetClient == -1 && !IsPlayerAlive(client) && b_HasDeathLocation[client]) {

									SDKCall(hRoundRespawn, client);
									b_HasDeathLocation[client] = false;
									CreateTimer(1.0, Timer_TeleportRespawn, client, TIMER_FLAG_NO_MAPCHANGE);
								}
								else if (TargetClient != -1 && !IsPlayerAlive(TargetClient) && b_HasDeathLocation[TargetClient]) {

									SDKCall(hRoundRespawn, TargetClient);
									b_HasDeathLocation[TargetClient] = false;
									CreateTimer(1.0, Timer_TeleportRespawn, TargetClient, TIMER_FLAG_NO_MAPCHANGE);

									TeamworkRewardNotification(client, TargetClient, PointCost, ItemName);
								}
							}
							else {

								//CheckIfRemoveWeapon(client, CheatParameter);
								RemoveClient = client;
								if (IsLegitimateClientAlive(TargetClient)) RemoveClient = TargetClient;
								if ((PointCost == 0.0 || (iPreGameFree == 1 && !b_IsActiveRound)) && GetClientTeam(RemoveClient) == TEAM_SURVIVOR) {

									// there is no code here to give a player a FREE weapon forcefully because that would be fucked up. TargetClient just gets ignored here.
									if (StrContains(CheatParameter, "pistol", false) != -1 || IsMeleeWeaponParameter(CheatParameter)) L4D_RemoveWeaponSlot(RemoveClient, L4DWeaponSlot_Secondary);
									else L4D_RemoveWeaponSlot(RemoveClient, L4DWeaponSlot_Primary);
								}
								if (IsMeleeWeaponParameter(CheatParameter)) {

									// Get rid of their old weapon
									if (TargetClient == -1)	L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
									else L4D_RemoveWeaponSlot(TargetClient, L4DWeaponSlot_Secondary);

									int ent			= CreateEntityByName("weapon_melee");

									DispatchKeyValue(ent, "melee_script_name", CheatParameter);
									DispatchSpawn(ent);

									if (TargetClient == -1) EquipPlayerWeapon(client, ent);
									else EquipPlayerWeapon(TargetClient, ent);
								}
								else {

									if (StrContains(CheatParameter, "pistol", false) != -1) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
									else if (iWeaponCat >= 0 && iWeaponCat <= 1) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);

									if (TargetClient == -1) {

										iTargetClient = client;

										if (StrEqual(CheatParameter, "health")) {

											if (L4D2_GetInfectedAttacker(client) != -1) Points[client] += PointCost;
											else {

												ExecCheatCommand(client, CheatCommand, CheatParameter);
												GiveMaximumHealth(client);		// So instant heal doesn't put a player above their maximum health pool.
											}
										}
										else ExecCheatCommand(client, CheatCommand, CheatParameter);
									}
									else {

										iTargetClient = TargetClient;

										if (StrEqual(CheatParameter, "health")) {

											if (L4D2_GetInfectedAttacker(TargetClient) != -1 || f_GetMissingHealth > fHealRequirementTeam) Points[client] += PointCost;
											else {

												ExecCheatCommand(TargetClient, CheatCommand, CheatParameter);
												GiveMaximumHealth(TargetClient);		// So instant heal doesn't put a player above their maximum health pool.
											}
										}
										else ExecCheatCommand(TargetClient, CheatCommand, CheatParameter);
									}
									if (StrContains(CheatParameter, "pistol", false) != -1 && StrContains(CheatParameter, "magnum", false) == -1) {

										CreateTimer(0.5, Timer_GiveSecondPistol, iTargetClient, TIMER_FLAG_NO_MAPCHANGE);
									}
									if (iWeaponCat == 0 && SkyLevel[client] > 0) CreateTimer(0.5, Timer_GiveLaserBeam, iTargetClient, TIMER_FLAG_NO_MAPCHANGE);
								}
								if (TargetClient != -1) {

									if (StrEqual(CheatParameter, "health", false) && L4D2_GetInfectedAttacker(TargetClient) == -1 && f_GetMissingHealth <= fHealRequirementTeam || !StrEqual(CheatParameter, "health", false)) {

										if (StrEqual(CheatParameter, "health", false)) TeamworkRewardNotification(client, TargetClient, PointCost * (1.0 - f_GetMissingHealth), ItemName);
										else TeamworkRewardNotification(client, TargetClient, PointCost, ItemName);
									}
								}
							}
							//if (TargetClient != -1) LogMessage("%N bought %s for %N", client, CheatParameter, TargetClient);
						}
						else {

							if (PointPurchaseType == 0) PrintToChat(client, "%T", "Not Enough Points", client, orange, white, PointCost);
							else if (PointPurchaseType == 1) PrintToChat(client, "%T", "Not Enough Experience", client, orange, white, ExperienceCost);
						}
					}
					break;
				}
			}
			if (bIsItemExists) return false;
		}
	}
	if (Command[0] == '!') return true;
	return false;
}

stock SetSpeedMultiplierBase(attacker, float amount = 1.0) {

	if (GetClientTeam(attacker) == TEAM_SURVIVOR) SetEntPropFloat(attacker, Prop_Send, "m_flLaggedMovementValue", fBaseMovementSpeed);
	else SetEntPropFloat(attacker, Prop_Send, "m_flLaggedMovementValue", amount);
}

stock PlayerSpawnAbilityTrigger(attacker) {

	if (IsLegitimateClientAlive(attacker)) {

		TankState[attacker] = TANKSTATE_TIRED;

		SetSpeedMultiplierBase(attacker);

		SpeedMultiplier[attacker] = SpeedMultiplierBase[attacker];		// defaulting the speed. It'll get modified in speed modifer spawn talents.
		
		if (GetClientTeam(attacker) == TEAM_INFECTED) DefaultHealth[attacker] = GetClientHealth(attacker);
		else {

			if (!IsFakeClient(attacker)) DefaultHealth[attacker] = iSurvivorBaseHealth;
			else DefaultHealth[attacker] = iSurvivorBotBaseHealth;
		}
		b_IsImmune[attacker] = false;

		GetAbilityStrengthByTrigger(attacker, _, "a", _, 0);
		if (GetClientTeam(attacker) != TEAM_SURVIVOR) {

			GiveMaximumHealth(attacker);
			CreateMyHealthPool(attacker);		// when the infected spawns, if there are any human players, they'll automatically be added to their pools to ensure that bots don't one-shot them.
		}
	}
}

stock bool NoHumanInfected() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) return false;
	}

	return true;
}

stock InfectedBotSpawn(client) {

	//new Float:HealthBonus = 0.0;
	//new Float:SpeedBonus = 0.0;

	//if (IsLegitimateClient(client)) {

		/*

			In the new health adjustment system, it is based on the number of living players as well as their total level.
			Health bonus is multiplied by the number of total levels of players alive in the session.
		*/
		/*char InfectedHealthBonusType[64];
		Format(InfectedHealthBonusType, sizeof(InfectedHealthBonusType), "(%d) infected health bonus", FindZombieClass(client));
		HealthBonus = StringToFloat(GetConfigValue(InfectedHealthBonusType)) * (SurvivorLevels() * 1.0);*/

		//GetAbilityStrengthByTrigger(client, _, 'a', 0, 0);
	//}
}

stock TruRating(client) {

	int TrueRating = (IsFakeClient(client)) ? RatingPerLevelSurvivorBots : RatingPerLevel;
	//TrueRating *= PlayerLevel[client];
	TrueRating *= CartelLevel(client);
	TrueRating += Rating[client];
	return TrueRating;
}

stock bool CheckServerLevelRequirements(client) {

	if (iServerLevelRequirement > 0) {

		if (IsFakeClient(client)) {

			if (PlayerLevel[client] < iServerLevelRequirement) SetTotalExperienceByLevel(client, iServerLevelRequirement);
			return true;
		}
		LogMessage("Level required to enter is %d and %N is %d", iServerLevelRequirement, client, PlayerLevel[client]);
	}
	if (IsFakeClient(client)) return true;
	char LevelKickMessage[128];
	if (iServerLevelRequirement == -2 && !IsGroupMember[client]) {

		// some servers can allow only steamgroup members to join.
		// this prevents people who are trying to quick-match a vanilla game from joining the server if you activate it.
		b_IsLoading[client] = true;
		Format(LevelKickMessage, sizeof(LevelKickMessage), "Only steamgroup members can access this server.");
		KickClient(client, LevelKickMessage);
		return false;
	}
	if (PlayerLevel[client] < iServerLevelRequirement) {

		b_IsLoading[client] = true;	// prevent saving data on kick

		Format(LevelKickMessage, sizeof(LevelKickMessage), "Your level: %d\nSorry, you must be level %d to enter this server.", PlayerLevel[client], iServerLevelRequirement);
		KickClient(client, LevelKickMessage);
		return false;
	}
	else bIsSettingsCheck = true;
	//EnforceServerTalentMaximum(client);
	return true;
}

stock GetSpecialInfectedLimit(bool IsTankLimit = false) {

	int speciallimit = 0;
	int Dividend = iRatingSpecialsRequired;
	if (IsTankLimit) Dividend = iRatingTanksRequired;
	int maxRatingForTanks = iMaximumTanksPerPlayer * iRatingTanksRequired;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			speciallimit += (IsTankLimit && Rating[i] > maxRatingForTanks) ? maxRatingForTanks : Rating[i];
		}
	}
	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		speciallimit -= ignoredRating;
		if (speciallimit < 0) speciallimit = 0;
	}
	speciallimit = RoundToFloor(speciallimit * 1.0 / Dividend * 1.0);
	if (!IsTankLimit && iSpecialInfectedMinimum >= 0) {
		if (iSpecialInfectedMinimum > 0) speciallimit += iSpecialInfectedMinimum;
		else speciallimit += TotalSurvivors();
	}
	
	/*if (speciallimit < 1) {

		if (b_IsFinaleActive) speciallimit = 2;
		else speciallimit = 1;
	}*/
	return speciallimit;
}

stock RaidCommonBoost(bool bInfectedTalentStrength = false, bool IsEnsnareMultiplier = false) {

	int totalTeamRating = 0;
	int maxRatingForCommons = iMaximumCommonsPerPlayer * RaidLevMult;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i)) continue;
		if (Rating[i] < 0) Rating[i] = 0;
		if (Rating[i] > maxRatingForCommons) totalTeamRating += maxRatingForCommons;
		else totalTeamRating += Rating[i];
	}
	int Multiplier = RaidLevMult;
	if (bInfectedTalentStrength) Multiplier = InfectedTalentLevel;
	else if (IsEnsnareMultiplier) Multiplier = iEnsnareLevelMultiplier;

	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		totalTeamRating -= ignoredRating;
		if (totalTeamRating < 0) totalTeamRating = 0;
	}

	if (Multiplier > 0) totalTeamRating /= Multiplier;
	if (totalTeamRating < 1) totalTeamRating = 0;
	return totalTeamRating;
}

stock HumanSurvivorLevels() {

	int fff = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			fff += Rating[i];
		}
	}
	//if (StringToInt(GetConfigValue("infected bot level type?")) == 1) return f;	// player combined level
	//if (LivingHumanSurvivors() > 0) return f / LivingHumanSurvivors();
	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		fff -= ignoredRating;
		if (fff < 0) fff = 0;
	}
	return fff;
}

stock SurvivorLevels() {

	int fff = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			fff += Rating[i];
		}
	}
	//if (StringToInt(GetConfigValue("infected bot level type?")) == 1) return f;	// player combined level
	//if (LivingHumanSurvivors() > 0) return f / LivingHumanSurvivors();
	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		fff -= ignoredRating;
		if (fff < 0) fff = 0;
	}
	return fff;
}

bool IsLegitimateClient(client) {

	if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) return false;
	return true;
}

stock bool IsLegitimateClientAlive(client) {

	if (IsLegitimateClient(client) && IsPlayerAlive(client)) return true;
	return false;
}

stock RaidInfectedBotLimit() {

	/*new count = LivingHumanSurvivors() + 1;
	new CurrInfectedLevel = SurvivorLevels();
	new RaidLevelRequirement = RaidLevMult;
	while (CurrInfectedLevel >= RaidLevelRequirement) {

		CurrInfectedLevel -= RaidLevelRequirement;
		count++;
	}
	new HumanInGame = HumanPlayersInGame();
	if (HumanInGame > 4) count = HumanInGame;*/

	bIsSettingsCheck = true;
	int count = GetSpecialInfectedLimit();

	ReadyUp_NtvHandicapChanged(count);
}

stock RefreshSurvivor(client, bool IsUnhook = false) {
	if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) {
		iCurrentIncapCount[client] = 0;
		SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 0);
		//if (IsFakeClient(client)) {

			//SetMaximumHealth(client);
			//Rating[client] = 1;
			//PlayerLevel[client] = iPlayerStartingLevel;
		//}
	}
}

public Action Timer_CheckForExperienceDebt(Handle timer, any client) {

	if (!IsLegitimateClient(client)) return Plugin_Stop;
	return Plugin_Stop;
}

stock DeleteMeFromExistence(client) {

	int pos = -1;

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i)) continue;
		pos = FindListPositionByEntity(client, InfectedHealth[i]);
		if (pos >= 0) RemoveFromArray(InfectedHealth[i], pos);
	}
	ForcePlayerSuicide(client);
}

stock IncapacitateOrKill(client, attacker = 0, healthvalue = 0, bool bIsFalling = false, bool bIsLifelinkPenalty = false, bool ForceKill = false) {
	bool isPlayerASurvivorBot = IsFakeClient(client);
	if ((ForceKill || IsLegitimateClientAlive(client)) && (GetClientTeam(client) != TEAM_INFECTED || isPlayerASurvivorBot)) {
		bool isClientIncapacitated = IsIncapacitated(client);
		//new IncapCounter	= GetEntProp(client, Prop_Send, "m_currentReviveCount");
		if (ForceKill || isClientIncapacitated || bIsFalling && !IsLedged(client) || bHasWeakness[client] > 0 || iCurrentIncapCount[client] >= iMaxIncap) {
			//if (FindZombieClass(attacker) == ZOMBIECLASS_JOCKEY) PrintToChatAll("jockey did the incap.");
			if (!ForceKill) {
				GetClientAbsOrigin(client, DeathLocation[client]);
				b_HasDeathLocation[client] = true;
				SetArrayCell(tempStorage, client, Rating[client], 0);
				SetArrayCell(tempStorage, client, handicapLevel[client], 1);
				SetArrayCell(tempStorage, client, RoundExperienceMultiplier[client], 2);
			}
			HealingContribution[client] = 0;
			DamageContribution[client] = 0;
			PointsContribution[client] = 0.0;
			TankingContribution[client] = 0;
			BuffingContribution[client] = 0;
			HexingContribution[client] = 0;
			ResetContributionTracker(client);
			char PlayerName[64];
			char PlayerID[64];
			if (!isPlayerASurvivorBot) {

				GetClientName(client, PlayerName, sizeof(PlayerName));
				GetClientAuthId(client, AuthId_Steam2, PlayerID, sizeof(PlayerID));
				if (!StrEqual(serverKey, "-1")) Format(PlayerID, sizeof(PlayerID), "%s%s", serverKey, PlayerID);
			}
			else {

				GetSurvivorBotName(client, PlayerName, sizeof(PlayerName));
				Format(PlayerID, sizeof(PlayerID), "%s%s", sBotTeam, PlayerName);
			}
			char pct[4];
			Format(pct, sizeof(pct), "%");
			if (iRPGMode >= 0 && IsPlayerAlive(client)) {

				if (iIsLevelingPaused[client] == 1 || PlayerLevel[client] >= iMaxLevel || PlayerLevel[client] >= iHardcoreMode && fDeathPenalty > 0.0 && (iDeathPenaltyPlayers < 1 || TotalHumanSurvivors() >= iDeathPenaltyPlayers)) ConfirmExperienceActionTalents(client, true);

				if (iIsLevelingPaused[client] == 1 || PlayerLevel[client] >= iMaxLevel) {

					ExperienceOverall[client] -= (ExperienceLevel[client] - 1);
					ExperienceLevel[client] = 1;
				}

				int LivingHumansCounter = LivingSurvivors() - 1;
				if (LivingHumansCounter < 0) LivingHumansCounter = 0;

				PrintToChatAll("%t", "teammate has died", blue, PlayerName, orange, green, (LivingHumansCounter * fSurvivorExpMult) * 100.0, pct);
				if (RoundExperienceMultiplier[client] > 0.0) {

					PrintToChatAll("%t", "bonus container burst", blue, PlayerName, orange, green, 100.0 * RoundExperienceMultiplier[client], orange, pct);
					BonusContainer[client] = 0;
					RoundExperienceMultiplier[client] = 0.0;
				}
			}

			char text[512];
			char ColumnName[64];
			//new TheGameMode = ReadyUp_GetGameMode();
			if (Rating[client] > BestRating[client]) {

				BestRating[client] = Rating[client];
				Format(ColumnName, sizeof(ColumnName), "%s", sDbLeaderboards);
				if (StrEqual(ColumnName, "-1")) {

					if (ReadyUpGameMode != 3) Format(ColumnName, sizeof(ColumnName), "%s", COOPRECORD_DB);
					else Format(ColumnName, sizeof(ColumnName), "%s", SURVRECORD_DB);
				}
				Format(text, sizeof(text), "UPDATE `%s` SET `%s` = '%d' WHERE `steam_id` = '%s';", TheDBPrefix, ColumnName, BestRating[client], PlayerID);
				SQL_TQuery(hDatabase, QueryResults, text, client);
			}
			//if (ReadyUpGameMode != 3)
			if (fRatingPercentLostOnDeath > 0.0) {
				Rating[client] = RoundToCeil(Rating[client] * (1.0 - fRatingPercentLostOnDeath)) + 1;
				int minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
				if (Rating[client] < minimumRating) Rating[client] = minimumRating;

				if (handicapLevel[client] > 0) {
					OnDeathHandicapValues[client]	= GetArrayCell(a_HandicapLevels, handicapLevel[client]-1, 1);
					int scoreRequired	 = GetArrayCell(OnDeathHandicapValues[client], HANDICAP_SCORE_REQUIRED);
					if (Rating[client] < scoreRequired) {
						handicapLevel[client] = 0;
						SetClientHandicapValues(client);
						FormatPlayerName(client);
						PrintToChat(client, "\x04Score requirement for current handicap level not met. \x03Handicap level reset.");
					}
				}
			}

			if (!isPlayerASurvivorBot) {

				char MyName[64];
				GetClientName(client, MyName, sizeof(MyName));
				if (!CheckServerLevelRequirements(client)) {

					PrintToChatAll("%t", "player no longer eligible", blue, MyName, orange);
					return;
				}
			}
			RaidInfectedBotLimit();

			if (iIsLifelink == 1 && !bIsLifelinkPenalty) {	// prevents looping

				for (int i = 1; i <= MaxClients; i++) {

					if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) IncapacitateOrKill(i, _, _, true, true);		// second true prevents this loop from being triggered by the function.
				}
			}
			if (iResetPlayerLevelOnDeath == 1) {
				if (!IsFakeClient(client)) PlayerLevel[client] = iPlayerStartingLevel;
				else PlayerLevel[client] = iBotPlayerStartingLevel;
				SkyLevel[client] = 0;
				ExperienceLevel[client] = 0;
				ExperienceOverall[client] = 0;
			}
			ForcePlayerSuicide(client);
			iCurrentIncapCount[client] = 0;
			iThreatLevel[client] = 0;
			bIsGiveProfileItems[client] = true;		// so when the player returns to life, their weapon loadout for that profile will be given to them.
			MyBirthday[client] = 0;
			bIsInCombat[client] = false;
			MyRespawnTarget[client] = client;

			RefreshSurvivor(client);

			GetAbilityStrengthByTrigger(client, attacker, "E", _, 0);
			if (attacker > 0) GetAbilityStrengthByTrigger(attacker, client, "e", _, healthvalue);
			if (IsLegitimateClientAlive(attacker) && FindZombieClass(attacker) == ZOMBIECLASS_TANK) {

				if (IsFakeClient(attacker)) ChangeTankState(attacker, "death");
			}
			if (!IsFakeClient(client)) SavePlayerData(client);
		}
		else if (!isClientIncapacitated) ForceIncapSurvivor(client, attacker, healthvalue);
	}
}

public ForceIncapSurvivor(client, attacker, healthvalue) {
	ImmuneToAllDamage[client] = true;
	CreateTimer(2.0, Timer_RemoveDamageImmunity, client, TIMER_FLAG_NO_MAPCHANGE);

	ReadyUp_NtvStatistics(client, 3, 1);
	ReadyUp_NtvStatistics(attacker, 4, 1);

	SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	iThreatLevel[client] /= 2;
	bIsGiveIncapHealth[client] = true;
	SetMaximumHealth(client);
	b_HasDeathLocation[client] = false;
	if (attacker != 0 && IsLegitimateClient(attacker)) GetAbilityStrengthByTrigger(client, attacker, "N", _, healthvalue);
	else GetAbilityStrengthByTrigger(client, attacker, "n", _, healthvalue);
	RoundIncaps[client]++;
	int infectedAttacker = L4D2_GetInfectedAttacker(client);

	if (infectedAttacker == -1) GetAbilityStrengthByTrigger(client, attacker, "n", _, healthvalue);
	else {
		//CreateTimer(1.0, Timer_IsIncapacitated, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		GetAbilityStrengthByTrigger(client, attacker, "N", _, healthvalue);
		if (infectedAttacker == attacker) GetAbilityStrengthByTrigger(attacker, client, "m", _, healthvalue);
		else GetAbilityStrengthByTrigger(client, infectedAttacker, "m", _, healthvalue);
	}
}

public Action Timer_RemoveDamageImmunity(Handle timer, any client) {
	if (IsLegitimateClient(client)) ImmuneToAllDamage[client] = false;
	return Plugin_Stop;
}
	/*
	// ---------------------------
	//  Hit Group standards
	// ---------------------------
	#define HITGROUP_GENERIC     0
	#define HITGROUP_HEAD        1
	#define HITGROUP_CHEST       2
	#define HITGROUP_STOMACH     3
	#define HITGROUP_LEFTARM     4
	#define HITGROUP_RIGHTARM    5
	#define HITGROUP_LEFTLEG     6
	#define HITGROUP_RIGHTLEG    7
	#define HITGROUP_GEAR        10            // alerts NPC, but doesn't do damage or bleed (1/100th damage)
	*/

stock GetHitgroupType(hitgroup) {
	if (hitgroup >= 4 && hitgroup <= 7) return HITGROUP_LIMB;	// limb
	if (hitgroup == 1) return HITGROUP_HEAD;					// headshot
	return HITGROUP_OTHER;										// not a limb
}

// stock bool CheckIfLimbDamage(attacker, victim, Handle event, damage) {
// 	if (GetClientTeam(attacker) == TEAM_SURVIVOR) {
// 		if (!b_IsHooked[attacker]) ChangeHook(attacker, true);
// 		int hitgroup = GetEventInt(event, "hitgroup");
// 		if (hitgroup >= 4 && hitgroup <= 7) {
// 			GetAbilityStrengthByTrigger(attacker, victim, "limbshot", _, damage, _, _, _, _, _, _, hitgroup);
// 			return true;
// 		}
// 	}
// 	return false;
// }

void CallTriggerByHitgroup(int attacker, int victim, int hitgroup, int ammotype, int damage) {
	int type = GetHitgroupType(hitgroup);
	if (type == HITGROUP_LIMB) GetAbilityStrengthByTrigger(attacker, victim, "limbshot", _, damage, _, _, _, _, _, _, hitgroup, _, ammotype);
	if (type == HITGROUP_HEAD) {
		GetAbilityStrengthByTrigger(attacker, victim, "headshot", _, damage, _, _, _, _, _, _, hitgroup, _, ammotype);
		if (IsCommonInfected(victim) && !IsSpecialCommon(victim)) AddCommonInfectedDamage(attacker, victim, GetCommonBaseHealth(attacker));	// if someone shoots a common infected in the head, we want to auto-kill it.
	}
}

/*
	GetAbilityStrengthByTrigger(activator, target = 0, String:AbilityT[], zombieclass = 0, damagevalue = 0,
										bool:IsOverdriveStacks = false, bool:IsCleanse = false, String:ResultEffects[] = "none", ResultType = 0,
										bool:bDontActuallyActivate = false, typeOfValuesToRetrieve = 1, hitgroup = -1)
*/

// stock bool CheckIfHeadshot(attacker, victim, Handle event, damage) {
// 	if (GetClientTeam(attacker) == TEAM_SURVIVOR) {
// 		if (!b_IsHooked[attacker]) ChangeHook(attacker, true);
// 		int hitgroup = GetEventInt(event, "hitgroup");
// 		if (hitgroup == 1) {
// 			ConsecutiveHeadshots[attacker]++;
// 			GetAbilityStrengthByTrigger(attacker, victim, "headshot", _, damage, _, _, _, _, _, _, hitgroup);
// 			if (IsCommonInfected(victim) && !IsSpecialCommon(victim)) {
// 				AddCommonInfectedDamage(attacker, victim, GetCommonBaseHealth(attacker));	// if someone shoots a common infected in the head, we want to auto-kill it.
// 			}
// 			LastHitWasHeadshot[attacker] = true;
// 			return true;
// 		}
// 		ConsecutiveHeadshots[attacker] = 0;
// 		LastHitWasHeadshot[attacker] = false;
// 	}
// 	return false;
// }

stock bool EquipBackpack(client) {

	if (eBackpack[client] > 0 && IsValidEntity(eBackpack[client])) {

		AcceptEntityInput(eBackpack[client], "Kill");
		eBackpack[client] = 0;
	}

	if (eBackpack[client] > 0 && IsValidEntity(eBackpack[client]) || !IsLegitimateClientAlive(client)) return false;	// backpack is already created.
	float Origin[3];

	int entity = CreateEntityByName("prop_dynamic_override");

	GetClientAbsOrigin(client, Origin);

	char text[64];
	Format(text, sizeof(text), "%d", client);
	DispatchKeyValue(entity, "model", sBackpackModel);
	//DispatchKeyValue(entity, "parentname", text);
	DispatchSpawn(entity);

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);
	SetVariantString("spine");
	AcceptEntityInput(entity, "SetParentAttachment");

	// Lux
	AcceptEntityInput(entity, "DisableCollision");
	SetEntProp(entity, Prop_Send, "m_noGhostCollision", 1, 1);
	SetEntProp(entity, Prop_Data, "m_CollisionGroup", 0x0004);
	float dFault[3];
	SetEntPropVector(entity, Prop_Send, "m_vecMins", dFault);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", dFault);
	// Lux

	//TeleportEntity(entity, g_vPos[index], g_vAng[index], NULL_VECTOR);
	SetEntProp(entity, Prop_Data, "m_iEFlags", 0);


	Origin[0] += 10.0;

	TeleportEntity(entity, Origin, NULL_VECTOR, NULL_VECTOR);
	eBackpack[client] = entity;

	return true;
}

stock bool GetClientStance(client, float fChaseTime = 20.0) {

	//if (stance == ClientActiveStance[client]) return true;
	/*if (bChangeStance) {

		ClientActiveStance[client] = stance;

		if (stance == 1) {

			new entity = CreateEntityByName("info_goal_infected_chase");
			if (entity > 0)
			{
				iChaseEnt[client] = EntIndexToEntRef(entity);

				DispatchSpawn(entity);
				new Float:vPos[3];
				GetClientAbsOrigin(client, vPos);
				vPos[2] += 20.0;
				TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", client);

				char temp[32];
				Format(temp, sizeof temp, "OnUser4 !self:Kill::300.0:-1");
				SetVariantString(temp);
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser4");

				//iChaseEnt[client] = entity;
			}
		}
		else {

			if(iChaseEnt[client] && EntRefToEntIndex(iChaseEnt[client]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[client], "Kill");
			iChaseEnt[client] = -1;
		}
		return true;
	}*/
	if (ClientActiveStance[client] == 1) return false;

	int entity = CreateEntityByName("info_goal_infected_chase");
	if (entity > 0) {
		
		iChaseEnt[client] = entity;//EntIndexToEntRef(entity);

		DispatchSpawn(entity);
		float vPos[3];
		GetClientAbsOrigin(client, vPos);
		vPos[2] += 20.0;
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);

		char temp[32];
		Format(temp, sizeof temp, "OnUser4 !self:Kill::%f:-1", fChaseTime);
		SetVariantString(temp);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser4");

		ClientActiveStance[client] = 1;
		CreateTimer(fChaseTime, Timer_ForcedThreat, client, TIMER_FLAG_NO_MAPCHANGE);

		iThreatLevel[client] = iTopThreat + 1;

		return true;
	}
	return false;
}

public Action Timer_ForcedThreat(Handle timer, any client) {

	if (IsLegitimateClient(client)) {

		ClientActiveStance[client] = 0;
		if(iChaseEnt[client] > 0 && IsValidEntity(iChaseEnt[client])) AcceptEntityInput(iChaseEnt[client], "Kill");
		iChaseEnt[client] = -1;
	}
	return Plugin_Stop;
}

stock bool IsAllSurvivorsDead() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) return false;
	}
	return true;
}

stock GiveAdrenaline(client, bool Remove=false) {

	if (Remove) SetEntProp(client, Prop_Send, "m_bAdrenalineActive", 0);
	else if (!HasAdrenaline(client)) SetEntProp(client, Prop_Send, "m_bAdrenalineActive", 1);
}

stock bool HasAdrenaline(client) {

	if (IsClientInRangeSpecialAmmo(client, "a") > 0.0) return true;
	return (GetEntProp(client, Prop_Send, "m_bAdrenalineActive") == 1);
}

/*stock bool:IsDualWield(client) {

	return bool:GetEntProp(client, Prop_Send, "m_isDualWielding");
}*/

stock bool IsLedged(client) {

	return (GetEntProp(client, Prop_Send, "m_isHangingFromLedge") == 1);
}

stock bool FallingFromLedge(client) {

	return (GetEntProp(client, Prop_Send, "m_isFallingFromLedge") == 1);
}

void SetAdrenalineState(int client, float time = 10.0) {

	if (!HasAdrenaline(client)) SDKCall(g_hEffectAdrenaline, client, time);
}

int GetClientTotalHealth(int client) {

	int SolidHealth			= GetClientHealth(client);
	float TempHealth	= GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	//if (IsIncapacitated(client)) TempHealth = 0.0;

	if (!IsIncapacitated(client)) return RoundToCeil(SolidHealth + TempHealth);
	else return RoundToCeil(TempHealth);
}
 
void SetClientTotalHealth(int attacker = -1, int client, int damage, bool IsSetHealthInstead = false, bool bIgnoreMultiplier = false) {
	if (ImmuneToAllDamage[client] || bIsGiveIncapHealth[client]) return;
	float fHealthBuffer = 0.0;
	int realDamage = 0;

	if (IsSetHealthInstead) {

		SetMaximumHealth(client);
		SetEntityHealth(client, damage);
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", damage * 1.0);
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
		return;
	}

	if (IsLegitimateClient(attacker) && GetClientTeam(attacker) != GetClientTeam(client)) lastHealthDamage[client][attacker] = damage;

	if (GetClientTeam(client) == TEAM_SURVIVOR) {
		ReadyUp_NtvStatistics(client, 7, damage);

		fHealthBuffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
		if (fHealthBuffer > 0.0) {

			if (damage >= fHealthBuffer) {	// temporary health is always checked first.

				if (IsIncapacitated(client)) IncapacitateOrKill(client);	// kill
				else {

					SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
					SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
					damage -= RoundToFloor(fHealthBuffer);
					if (attacker != client) SetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_TANKING, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_TANKING) + RoundToFloor(fHealthBuffer));
				}
			}
			else {

				fHealthBuffer -= damage;
				SetEntityHealth(client, RoundToCeil(fHealthBuffer));
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", fHealthBuffer);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
				damage = 0;
			}
		}
		if (IsPlayerAlive(client)) {
			realDamage = GetClientTotalHealth(client);
			if (damage >= realDamage) IncapacitateOrKill(client);	// hint: they won't be killed.
			else if (!IsIncapacitated(client)) {
				realDamage = damage;
				SetEntityHealth(client, GetClientHealth(client) - damage);
			}
			if (attacker != client) SetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_TANKING, GetArrayCell(playerContributionTracker[client], CONTRIBUTION_TRACKER_TANKING) + realDamage);
		}
	}
	else {
		ReadyUp_NtvStatistics(client, 8, damage);
		if (damage >= GetClientHealth(client)) {
			CalculateInfectedDamageAward(client, attacker);
		}
		else SetEntityHealth(client, GetClientHealth(client) - damage);
	}
}

stock RestoreClientTotalHealth(client, damage) {

	int SolidHealth			= GetClientHealth(client);
	float TempHealth	= 0.0;
	if (GetClientTeam(client) == TEAM_SURVIVOR) TempHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	if (RoundToFloor(TempHealth) > 0) {

		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", TempHealth + damage);
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	}
	else SetEntityHealth(client, SolidHealth + damage);
}

stock bool SetTempHealth(client, targetclient, float TemporaryHealth=30.0, bool IsRevive=false, bool IsInNeedOfPickup=false) {

	if (!IsLegitimateClientAlive(targetclient)) return false;
	if (IsRevive) {

		if (IsInNeedOfPickup) ReviveDownedSurvivor(targetclient, client);

		// When a player revives someone (or is revived) we call the SetTempHealth function and here
		// It simply calls itself 
		GetAbilityStrengthByTrigger(targetclient, client, "R", _, 0);
		GetAbilityStrengthByTrigger(client, targetclient, "r", _, 0);
		//GiveMaximumHealth(targetclient);
	}
	else {

		SetEntPropFloat(targetclient, Prop_Send, "m_healthBuffer", TemporaryHealth);
		SetEntPropFloat(targetclient, Prop_Send, "m_healthBufferTime", GetGameTime());
	}
	return true;
}

/*stock ModifyTempHealth(client, Float:health) {

	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", health);
}*/

/*stock SetClientMaximumTempHealth(client) {

	SetMaximumHealth(client);
	SetEntityHealth(client, 1);
	SetClientTempHealth(client, GetMaximumHealth(client) - 1);
}*/

stock ModifyHealth(client){//}, float TalentStrength, float TalentTime, isRawValue = 0) {

	if (!IsLegitimateClientAlive(client)) return;
	SetMaximumHealth(client);
}

stock void ReviveDownedSurvivor(client, int activator = 0) {
	SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
	iCurrentIncapCount[client]++;
	if (iCurrentIncapCount[client] >= iMaxIncap) SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 1);
	int reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
	if (IsLegitimateClientAlive(reviveOwner)) {
		SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
		SetEntityMoveType(reviveOwner, MOVETYPE_WALK);
	}
	SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntityHealth(client, RoundToCeil(GetMaximumHealth(client) * fHealthSurvivorRevive));
	if (client != activator) GetAbilityStrengthByTrigger(client, activator, "R", _, 0);
	GetAbilityStrengthByTrigger(activator, client, "r", _, 0);
}

/*
if (RoundToFloor(PlayerHealth_Temp + HealAmount) >= GetMaximumHealth(client) && IsIncapacitated(client)) {

		//SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
		ReviveDownedSurvivor(client);
		GetAbilityStrengthByTrigger(client, activator, 'R', FindZombieClass(client), 0);
		GetAbilityStrengthByTrigger(activator, client, 'r', FindZombieClass(activator), 0);
		GiveMaximumHealth(client);
	}
	*/

stock bool IsBeingRevived(client) {

	int target = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
	if (IsLegitimateClientAlive(target)) return true;
	return false;
}

stock ReleasePlayer(client) {
	int attacker = L4D2_GetInfectedAttacker(client);
	if (attacker > 0) {
		CalculateInfectedDamageAward(attacker, client);
		return attacker;
	}
	/* Charger */
	/*attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_pummelAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_pummelVictim", -1);
		//SetEntPropEnt(attacker, Prop_Send, "m_isCharging", 0);
		SetEntPropEnt(client, Prop_Send, "m_isHangingFromTongue", 0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_carryVictim", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_isCharging", 0);
		SetEntPropEnt(client, Prop_Send, "m_isHangingFromTongue", 0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_pounceVictim", -1);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_tongueVictim", -1);
		SetEntPropEnt(client, Prop_Send, "m_isHangingFromTongue", 0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_jockeyVictim", -1);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}*/
	return -1;
}

stock HealPlayer(client, activator, float f_TalentStrength, ability, bool IsStrength = false) {	// must heal for abilities that instant-heal
	if (!IsLegitimateClient(client) || !IsPlayerAlive(client) || bIsGiveIncapHealth[client]) return 0;
	bool bIsIncapacitated = IsIncapacitated(client);
	// if (bIsIncapacitated && bHasWeakness[client]) return 0;
	int MyMaximumHealth = GetMaximumHealth(client);
	int PlayerHealth = GetClientHealth(client);
	/*if (PlayerHealth >= MyMaximumHealth && !IsIncapacitated(client)) {

		SetMaximumHealth(client);
		return 0;
	}*/
	if (L4D2_GetInfectedAttacker(client) != -1) return 0;
	float TalentStrength = GetAbilityMultiplier(activator, "E");
	if (TalentStrength == -1.0) TalentStrength = 0.0;
	TalentStrength = (TalentStrength > 0.0) ? f_TalentStrength + (TalentStrength * f_TalentStrength) : f_TalentStrength;
	//if (!IsIncapacitated(client)) PlayerHealth = GetClientHealth(client) * 1.0;
	float PlayerHealth_Temp = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	int HealAmount = (TalentStrength < 1.0 || !IsStrength) ? RoundToCeil(GetMaximumHealth(client) * TalentStrength) : RoundToCeil(TalentStrength);
	if (HealAmount < 1) return 0;
	// if (TalentStrength == 1.0) {
	// 	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
	// 	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	// 	GiveMaximumHealth(client);
	// 	return HealAmount;
	// }
	HealAmount = (PlayerHealth + HealAmount < MyMaximumHealth) ? HealAmount : MyMaximumHealth - PlayerHealth;
	int NewHealth = PlayerHealth + HealAmount;
	if (bIsIncapacitated) {
		if (NewHealth < MyMaximumHealth) {
			// Incap health can't exceed actual player health - or they get instantly ressed.
			// that's wrong and i'll fix it, later. noted.
			SetEntityHealth(client, NewHealth);
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", NewHealth * 1.0);
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime() * 1.0);
		}
		// We auto-revive any survivor who heals over their maximum incap health.
		// We also give them a default health on top of the overheal, to help them maybe not get knocked again, immediately.
		// You don't die if you get incapped too many times, but it would be a pretty annoying game play loop.
		else {
		//if (!IsBeingRevived(client)) {
			if (!IsLedged(client)) ReviveDownedSurvivor(client);
		}
		/*else {
			SetEntityHealth(client, MyMaximumHealth);
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", MyMaximumHealth * 1.0);
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
		}*/
	}
	else {

		if (RoundToCeil(PlayerHealth + PlayerHealth_Temp + HealAmount) >= MyMaximumHealth) {

			int TempDiff = MyMaximumHealth - (PlayerHealth + HealAmount);

			if (TempDiff > 0) {

				HealAmount = MyMaximumHealth - RoundToFloor(PlayerHealth + PlayerHealth_Temp);

				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
				GiveMaximumHealth(client);
			}
			else {

				SetEntityHealth(client, PlayerHealth + HealAmount);
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", TempDiff * 1.0);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
			}
		}
		else {

			SetEntityHealth(client, PlayerHealth + HealAmount);
			if (PlayerHealth_Temp > 0.0) {
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", PlayerHealth_Temp);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
			}
		}
	}
	if (HealAmount > MyMaximumHealth - PlayerHealth) HealAmount = MyMaximumHealth - PlayerHealth;
	if (HealAmount > 0) {
		AwardExperience(activator, 1, HealAmount);
		SetArrayCell(playerContributionTracker[activator], CONTRIBUTION_TRACKER_HEALING, GetArrayCell(playerContributionTracker[activator], CONTRIBUTION_TRACKER_HEALING) + HealAmount);
		if (IsLegitimateClientAlive(activator)) {
			//if (!dontFireTriggers) {
			if (activator != client) {
				//GetAbilityStrengthByTrigger(activator, client, "healally", _, HealAmount);
				GetAbilityStrengthByTrigger(client, activator, "wasHealed", _, HealAmount);
			}
			else GetAbilityStrengthByTrigger(activator, client, "healself", _, HealAmount);
			//}
			float TheAbilityMultiplier = GetAbilityMultiplier(activator, "t");
			if (TheAbilityMultiplier != -1.0) {

				TheAbilityMultiplier *= (HealAmount * 1.0);
				iThreatLevel[activator] += (HealAmount - RoundToFloor(TheAbilityMultiplier));
			}
			else {

				iThreatLevel[activator] += HealAmount;
			}
		}
		// friendly fire module is no longer used - depricated //if (ability == 'T') ReadyUp_NtvFriendlyFire(activator, client, 0 - HealAmount, GetClientHealth(client), 1, 0);	// we "subtract" negative values from health.
	}
	//PrintToChat(client, "heal amount: %d", HealAmount);
	return HealAmount;		// to prevent cartel being awarded for overheal.
}

stock EnableHardcoreMode(client, bool Disable=false) {

	if (!Disable) {
	
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 0, 0, 255);
		SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 1);
		EmitSoundToClient(client, "player/heartbeatloop.wav");
	}
	else {

		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
	}
}

/*

	Helping new players adjust to the game brought on the idea of Pets.
	Pets provide benefits to the user, and can be changed at any time.

	Pets that have not yet been discovered are hidden from player view.
	This function properly positions the pet.
*/
/*
new entity = CreateEntityByName("prop_dynamic_override");
	if( entity != -1 )
	{
		SetEntityModel(entity, g_sModels[index]);
		DispatchSpawn(entity);
		if( g_bLeft4Dead2 )
		{
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", g_fSize[index]);
		}

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);
		SetVariantString("eyes");
		AcceptEntityInput(entity, "SetParentAttachment");
		TeleportEntity(entity, g_vPos[index], g_vAng[index], NULL_VECTOR);
		SetEntProp(entity, Prop_Data, "m_iEFlags", 0);

		if( g_iCvarOpaq )
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, g_iCvarOpaq);
		}

		g_iSelected[client] = index;
		g_iHatIndex[client] = EntIndexToEntRef(entity);

		if( !g_bHatView[client] )
			SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);

		if( g_bTranslation == false )
		{
			CPrintToChat(client, "%s%t", CHAT_TAG, "Hat_Wearing", g_sNames[index]);
		}
		else
		{
			char sMsg[128];
			Format(sMsg, sizeof(sMsg), "Hat %d", index + 1);
			Format(sMsg, sizeof(sMsg), "%T", sMsg, client);
			CPrintToChat(client, "%s%t", CHAT_TAG, "Hat_Wearing", sMsg);
		}

		return true;
	}
*/

void ScenarioEnd(int client, const char[] s = "scenario_end") {
	int iFlags = GetCommandFlags(s);
	if (IsFakeClient(client)) {
        SetCommandFlags(s, iFlags & ~FCVAR_CHEAT);
        FakeClientCommand(client, "%s", s);
        SetCommandFlags(s, iFlags);
    }
	else {
        int uFlags = GetUserFlagBits(client);
        SetUserFlagBits(client, ADMFLAG_ROOT);
        SetCommandFlags(s, iFlags & ~FCVAR_CHEAT);
        FakeClientCommand(client, "%s", s);
        SetCommandFlags(s, iFlags);
        SetUserFlagBits(client, uFlags);
    }
}

void ExecCheatCommand(int client = 0, const char[] command, const char[] parameters = "") {
	if (StrEqual(parameters, "ammo")) {
		// we handle refilling ammo differently since we use custom values for reserve amount.
		GetWeaponResult(client, 5);
		return;
	}
	int iFlags = GetCommandFlags(command);
	SetCommandFlags(command, iFlags & ~FCVAR_CHEAT);
	if(client < 1) ServerCommand("%s %s",command,parameters);
	else FakeClientCommand(client,"%s %s",command,parameters);
	SetCommandFlags(command, iFlags);
}

stock bool IsClientActual(client) {
	if (client < 1 || client > MaxClients || !IsClientConnected(client)) return false;
	return true;
}

stock bool IsClientBot(client) {
	if (!IsClientActual(client)) return false;
	if (IsFakeClient(client)) return true;
	return false;
}

stock bool IsClientHuman(client) {
	if (IsClientActual(client) && IsClientInGame(client) && !IsFakeClient(client)) return true;
	return false;
}

stock bool IsGhost(client) {
	return bool:GetEntProp(client, Prop_Send, "m_isGhost", 1);
}

stock bool HasCommandAccessEx(client, char[] permissions) {
	if (!IsClientActual(client)) return false;
	int flags = GetUserFlagBits(client);
	int cflags = ReadFlagString(permissions);
	if (flags & cflags) return true;
	return false;
}

stock int ValidSurvivors() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i)) count++;
	}
	return count;
}

// targetstate = 0 (ignore) 1 (ensnared) 2 (incapacitated) 3 (dead)
stock int GetClientsInRangeByState(int client, float range, bool sameTeam = false, bool allowBots = true, int targetState = 0) {
	int count = 0;
	int team = GetClientTeam(client);
	float cpos[3];
	GetClientAbsOrigin(client, cpos);
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || i == client) continue;
		if (!allowBots && IsFakeClient(i)) continue;
		if (sameTeam && GetClientTeam(i) != team) continue;
		if (targetState == 1 && L4D2_GetInfectedAttacker(i) == -1) continue;
		if (targetState == 2 && !IsIncapacitated(i)) continue;
		if (targetState == 3 && IsPlayerAlive(i)) continue;
		float tpos[3];
		GetClientAbsOrigin(i, tpos);
		if (GetVectorDistance(cpos, tpos) > range) continue;
		count++;
	}
	return count;
}

stock int PlayersInVicinity(client, float range) {
	float pos[3];
	float cpos[3];
	int count = 0;
	GetClientAbsOrigin(client, cpos);
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == GetClientTeam(client) && i != client && IsPlayerAlive(i)) {
			GetClientAbsOrigin(i, pos);
			if (GetVectorDistance(cpos, pos) <= range) count++;
		}
	}
	return count;
}

stock bool PlayersOutOfRange(entity, float range) {
	float tPos[3];
	if (entity > 0 && IsValidEntity(entity)) {
		char CName[128];
		GetEntityClassname(entity, CName, sizeof(CName));
		if (StrEqual(CName, "prop_door_rotating_checkpoint", false)) {
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", tPos);
			float pPos[3];
			for (new i = 1; i <= MaxClients; i++) {
				if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || !IsPlayerAlive(i)) continue;
				GetClientAbsOrigin(i, Float:pPos);
				if (GetVectorDistance(pPos, tPos) > range) return true;
			}
			return false;
		}
		else return false;
	}
	return true;
}

stock bool IsSurvival() {
	char GameType[128];
	GetConVarString(FindConVar("mp_gamemode"), GameType, 128);
	if (StrEqual(GameType, "survival")) return true;
	return false;
}

stock bool IsIncapacitated(client) {
	return (GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1) ? true : false;
}

stock void CreateItemDrop(int owner, int client) {
	float Origin[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, Origin);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);

	char text[64];
	GetClientAuthId(owner, AuthId_Steam2, text, 64);
	Format(text, sizeof(text), "loot_%s", text);
	int entity = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(entity, "targetname", text);
	DispatchKeyValue(entity, "spawnflags", "1029");
	DispatchKeyValue(entity, "solid", "6");
	DispatchKeyValue(entity, "model", sItemModel);
	DispatchSpawn(entity);

	// SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	// SetEntityRenderColor(entity, 255, 255, 255, 255);
	CreateTimer(fLootBagExpirationTimeInSeconds, Timer_DeleteLootBag, entity, TIMER_FLAG_NO_MAPCHANGE);

	float vel[3];
	vel[0] = GetRandomFloat(-10000.0, 1000.0);
	vel[1] = GetRandomFloat(-1000.0, 1000.0);
	vel[2] = GetRandomFloat(100.0, 1000.0);

	Origin[2] += 32.0;
	TeleportEntity(entity, Origin, NULL_VECTOR, vel);
	//SetEntityMoveType(entity, MOVETYPE_VPHYSICS);
}

// stock void Autoloot(client) {
// 	float myPos[3];
// 	GetClientAbsOrigin(client, myPos);
// 	char entityClassname[64];
// 	float pos[3];
// 	for (int i = 0; i < MAX_ENTITIES; i++) {
// 		if (!IsValidEntity(i)) continue;
// 		GetEntityClassname(i, entityClassname, sizeof(entityClassname));
// 		if (StrContains(entityClassname, "physics") == -1) continue;
// 		GetEntPropString(i, Prop_Data, "m_iName", entityClassname, sizeof(entityClassname));
// 		if (StrContains(entityClassname, "loot") == -1) continue;
// 		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos);
// 		if (GetVectorDistance(myPos, pos) > 64.0) continue;
// 		IsPlayerTryingToPickupLoot(client, i, entityClassname);
// 	}
// }

stock bool IsPlayerTryingToPickupLoot(client, int entity = -1, char[] classname = "none") {
	char entityClassname[64];
	char text[512];
	if (entity == -1) {
		entity = GetClientAimTarget(client, false);
		if (entity == -1) return false;
		GetEntityClassname(entity, entityClassname, sizeof(entityClassname));
		if (StrContains(entityClassname, "physics") == -1) return false;	// not a loot object
		GetEntPropString(entity, Prop_Data, "m_iName", entityClassname, sizeof(entityClassname));
		if (StrContains(entityClassname, "loot") == -1) return false;		// not specifically loot (we will change this to allow types later, maybe)
		// okay, so it's a loot object. Is the player close enough to pick it up?
		float myPos[3];
		GetClientAbsOrigin(client, myPos);
		float lootPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", lootPos);
		if (GetVectorDistance(myPos, lootPos) > 64.0) return false;			// no.
	}
	else Format(entityClassname, sizeof(entityClassname), "%s", classname);

	char name[64];
	GetClientName(client, name, sizeof(name));
	// int currentGameTime = GetTime();
	// if (lastItemTime + 5 < currentGameTime || !StrEqual(name, lastPlayerGrab)) {
	// 	Format(text, sizeof(text), "{B}%s {N}is searching a {O}bag...", name);
	// }
	// lastItemTime = currentGameTime;
	GetClientName(client, lastPlayerGrab, sizeof(lastPlayerGrab));
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
		Client_PrintToChat(i, true, text);
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
		char key[64];
		GetClientAuthId(i, AuthId_Steam2, key, 64);
		if (StrContains(entityClassname, key) == -1) continue;
		int size = GetArraySize(playerLootOnGround[i]);
		if (size > 0) {
			if (GetArraySize(myAugmentIDCodes[i]) < iInventoryLimit) {
				GenerateAndGivePlayerAugment(i, GetArrayCell(playerLootOnGround[i], size-1), true);
			}
			else {
				augmentParts[i]++;
				// Format(text, 64, "{O}Inventory Full; {G}+1 {O}scrap");
				// Client_PrintToChat(client, true, text);
			}
			RemoveFromArray(playerLootOnGround[i], size-1);	// we remove the oldest loot drop stored for this player from their "queue"
			AcceptEntityInput(entity, "Kill");
			return true;
		}
		break;
	}
	return false;
}

public Action Timer_DeleteLootBag(Handle timer, any entity) {
	if (!b_IsActiveRound) return Plugin_Stop;
	char text[512];
	if (IsValidEntity(entity)) {
		GetEntPropString(entity, Prop_Data, "m_iName", text, sizeof(text));
		if (StrContains(text, "loot") == -1) return Plugin_Stop;
		AcceptEntityInput(entity, "Kill");	// delete the loot bag.
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
			char key[64];
			GetClientAuthId(i, AuthId_Steam2, key, 64);
			if (StrContains(text, key) == -1) continue;
			int size = GetArraySize(playerLootOnGround[i]);
			if (size > 0) RemoveFromArray(playerLootOnGround[i], size-1);	// we remove the oldest loot drop stored for this player from their "queue"
			break;
		}
	}
	return Plugin_Stop;
}