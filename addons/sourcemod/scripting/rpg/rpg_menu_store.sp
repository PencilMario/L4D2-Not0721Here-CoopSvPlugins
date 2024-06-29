/* put the line below after all of the includes!
#pragma newdecls required
*/

void BuildStoreMenu(int client) {

	Handle menu					=	CreateMenu(BuildStoreHandle);
	
	char text[512];
	Format(text, sizeof(text), "%T", "Store Header", client, SkyPoints[client]);
	SetMenuTitle(menu, text);
	char Name[64];
	char Name_Temp[64];
	char pct[4];
	Format(pct, sizeof(pct), "%");

	int StoreCost					=	0;
	int Duration					=	0;
	float ItemStrength			=	0.0;
	int Seconds						=	0;

	int Hours						=	0;
	int Minutes						=	0;

	int Amount						=	0;
	float AmountMin				=	0.0;
	float AmountMax				=	0.0;


	char durationtext[512];

	int size						=	GetArraySize(a_Store);

	for (int i = 0; i < size; i++) {

		MenuKeys[client]			=	GetArrayCell(a_Store, i, 0);
		MenuValues[client]			=	GetArrayCell(a_Store, i, 1);
		MenuSection[client]			=	GetArrayCell(a_Store, i, 2);

		GetArrayString(MenuSection[client], 0, Name, sizeof(Name));

		Hours						=	0;
		Minutes						=	0;
		StoreCost		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "store cost?");
		Duration		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "duration?");
		ItemStrength	= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "item strength?");
		Amount			= GetKeyValueInt(MenuKeys[client], MenuValues[client], "amount?");
		AmountMin		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "amount min?");
		AmountMax		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "amount max?");

		if (Duration == 0) Format(durationtext, sizeof(durationtext), "");
		else {

			while (Duration >= 3600) {

				Hours++;
				Duration -= 3600;
			}
			while (Duration >= 60) {

				Minutes++;
				Duration -= 60;
			}
			Format(durationtext, sizeof(durationtext), "%dH %dM %dS", Hours, Minutes, Duration);
		}
		Format(Name_Temp, sizeof(Name_Temp), "%T", Name, client);
		if (ItemStrength > 0.0) {

			char Store_Player_Value[512];
			GetArrayString(a_Store_Player[client], i, Store_Player_Value, sizeof(Store_Player_Value));

			if (StringToInt(Store_Player_Value) < 1) Format(durationtext, sizeof(durationtext), "%s (%3.1f%s)", durationtext, ItemStrength * 100.0, pct);
			else {

				Seconds					=	StringToInt(Store_Player_Value);
				Hours					=	0;
				Minutes					=	0;
				while (Seconds >= 3600) {

					Hours++;
					Seconds -= 3600;
				}
				while (Seconds >= 60) {

					Minutes++;
					Seconds -= 60;
				}
				Format(durationtext, sizeof(durationtext), "%s (%3.1f%s)\n%dH %dM %dS", durationtext, ItemStrength * 100.0, pct, Hours, Minutes, Seconds);
			}
		}
		char AmountText[64];
		Format(AmountText, sizeof(AmountText), "");
		if (AmountMax > AmountMin && AmountMax != 0) Format(AmountText, sizeof(AmountText), "%T", "Store Amount Range", client, RoundToFloor(AmountMin * CheckExperienceRequirement(client)), RoundToFloor(AmountMax * CheckExperienceRequirement(client)));
		else if (AmountMin > 0) Format(AmountText, sizeof(AmountText), "%T", "Store Amount Static", client, RoundToFloor(AmountMin * CheckExperienceRequirement(client)));
		else if (Amount > 0) Format(AmountText, sizeof(AmountText), "%T", "Store Amount Static", client, Amount);
		if (strlen(AmountText) >= 1) Format(AmountText, sizeof(AmountText), "(%s)", AmountText);
		Format(Name_Temp, sizeof(Name_Temp), "%T", "Store Option", client, Name_Temp, StoreCost, durationtext, AmountText);
		AddMenuItem(menu, Name_Temp, Name_Temp);
	}

	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, client, 0);
}

stock void GiveClientStoreItem(int client, int pos) {

	char slotvalue[64];

	int Duration		= 0;
	int Amount			= 0;
	float AmountMin	= 0.0;
	float AmountMax	= 0.0;

	char ItemEffect[64];
	char SectionName[64];

	Give_Store_Keys				= GetArrayCell(a_Store, pos, 0);
	Give_Store_Values			= GetArrayCell(a_Store, pos, 1);
	Give_Store_Section			= GetArrayCell(a_Store, pos, 2);

	GetArrayString(Give_Store_Section, 0, SectionName, sizeof(SectionName));

	Duration		= GetKeyValueInt(Give_Store_Keys, Give_Store_Values, "duration?");
	FormatKeyValue(ItemEffect, sizeof(ItemEffect), Give_Store_Keys, Give_Store_Values, "item effect?");
	Amount			= GetKeyValueInt(Give_Store_Keys, Give_Store_Values, "amount?");
	AmountMin		= GetKeyValueFloat(Give_Store_Keys, Give_Store_Values, "amount min?");
	AmountMax		= GetKeyValueFloat(Give_Store_Keys, Give_Store_Values, "amount max?");

	if (Duration > 0) {

		GetArrayString(a_Store_Player[client], pos, slotvalue, sizeof(slotvalue));
		Duration += StringToInt(slotvalue);
		Format(slotvalue, sizeof(slotvalue), "%d", Duration);
		SetArrayString(a_Store_Player[client], pos, slotvalue);
		LogMessage("%N receives xp boost, was %d seconds is now %d seconds", client, StringToInt(slotvalue), StringToInt(slotvalue) + Duration);
	}
	/*if (FindCharInString(ItemEffect, 'r') != -1) {

		ChallengeEverything(client);
	}*/
	if (FindCharInString(ItemEffect, 't') != -1) {

		/*

			The player receives a free upgrade. In order to not cause issues we need to treat this as if the player earned the experience for their upgrade.
		*/
		while (Amount > 0) {

			ExperienceLevel[client] = GetUpgradeExperienceCost(client);
			ConfirmExperienceAction(client);
			Amount--;
		}
	}
	if (FindCharInString(ItemEffect, 'e') != -1) {

		if (AmountMin > AmountMax) AmountMax					= AmountMin;
		if (AmountMin != AmountMax) AmountMin					= GetRandomFloat(AmountMin, AmountMax);
		ExperienceLevel[client]								+=	RoundToFloor(AmountMin * CheckExperienceRequirement(client));
		ExperienceOverall[client]							+=	RoundToFloor(AmountMin * CheckExperienceRequirement(client));
		if (ExperienceLevel[client] > CheckExperienceRequirement(client)) {

			ExperienceOverall[client] -= (ExperienceLevel[client] - CheckExperienceRequirement(client));
			ExperienceLevel[client] = CheckExperienceRequirement(client);
		}
	}
}

stock ChallengeEverything(client) {
	TotalTalentPoints[client]							=	0;
	UpgradesAvailable[client]							=	0;
	FreeUpgrades[client]								=	MaximumPlayerUpgrades(client);
	PlayerUpgradesTotal[client] = 0;
	WipeTalentPoints(client);
}

public BuildStoreHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		char key[64];

		char slotvalue[64];


		int StoreCost				=	0;
		int Duration				=	0;
		float AmountMin			=	0.0;
		float AmountMax			=	0.0;
		char ItemEffect[64];

		MenuKeys[client]			=	GetArrayCell(a_Store, slot, 0);
		MenuValues[client]			=	GetArrayCell(a_Store, slot, 1);

		StoreCost		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "store cost?");
		Duration		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "duration?");
		FormatKeyValue(ItemEffect, sizeof(ItemEffect), MenuKeys[client], MenuValues[client], "item effect?");
		AmountMin		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "amount min?");
		AmountMax		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "amount max?");

		if (SkyPoints[client] >= StoreCost && GetArraySize(a_Store_Player[client]) == GetArraySize(a_Store)) {

			SkyPoints[client] -= StoreCost;
			if (Duration > 0) {

				GetArrayString(a_Store_Player[client], slot, slotvalue, sizeof(slotvalue));
				Format(slotvalue, sizeof(slotvalue), "%d", StringToInt(slotvalue) + Duration);
				SetArrayString(a_Store_Player[client], slot, slotvalue);
			}
			if (FindCharInString(ItemEffect, 'r') != -1) {

				ChallengeEverything(client);
			}
			if (FindCharInString(ItemEffect, 'e') != -1) {

				if (AmountMin > AmountMax) AmountMax					= AmountMin;
				if (AmountMin != AmountMax) AmountMin					= GetRandomFloat(AmountMin, AmountMax);
				ExperienceLevel[client]								+=	RoundToFloor(AmountMin * CheckExperienceRequirement(client));
				ExperienceOverall[client]							+=	RoundToFloor(AmountMin * CheckExperienceRequirement(client));
				if (ExperienceLevel[client] > CheckExperienceRequirement(client)) {

					ExperienceOverall[client] -= (ExperienceLevel[client] - CheckExperienceRequirement(client));
					ExperienceLevel[client] = CheckExperienceRequirement(client);
				}
			}
		}
		else if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) {

			GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
			if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
			LoadStoreData(client, key);
		}
		BuildStoreMenu(client);
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) BuildMenu(client);
	}
	else if (action == MenuAction_End) {

		CloseHandle(menu);
	}
}

stock RemoveStoreTime(client) {

	char key[64];
	char PlayerValue[64];

	int size								= GetArraySize(a_Store);
	if (!b_IsLoadingStore[client] && GetArraySize(a_Store_Player[client]) != size) {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		LoadStoreData(client, key);
		return;				// If their data hasn't loaded for the store, we skip them.
	}
	if (b_IsLoadingStore[client]) return;		// If their data is currently loading, we skip them.
	for (int i = 0; i < size; i++) {

		StoreTimeKeys[client]				= GetArrayCell(a_Store, i, 0);
		StoreTimeValues[client]				= GetArrayCell(a_Store, i, 1);

		if (GetKeyValueInt(StoreTimeKeys[client], StoreTimeValues[client], "duration?") > 0) {

			GetArrayString(a_Store_Player[client], i, PlayerValue, sizeof(PlayerValue));
			if (StringToInt(PlayerValue) > 0) {

				Format(PlayerValue, sizeof(PlayerValue), "%d", StringToInt(PlayerValue) - 1);
				SetArrayString(a_Store_Player[client], i, PlayerValue);
			}
		}
	}
}

stock bool HasBoosterTime(client) {

	char key[64];
	char val[64];
	char pva[64];

	int size			= GetArraySize(a_Store);
	if (!b_IsLoadingStore[client] || GetArraySize(a_Store_Player[client]) != size) {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		LoadStoreData(client, key);
		return true;
	}
	if (b_IsLoadingStore[client]) return true;
	int size2			= 0;
	for (int i = 0; i < size; i++) {

		BoosterKeys[client]		= GetArrayCell(a_Store, i, 0);
		BoosterValues[client]	= GetArrayCell(a_Store, i, 1);
		size2					= GetArraySize(BoosterKeys[client]);

		for (int ii = 0; ii < size2; ii++) {

			GetArrayString(BoosterKeys[client], ii, key, sizeof(key));
			GetArrayString(BoosterValues[client], ii, val, sizeof(val));

			if (StrEqual(key, "duration?") && StringToInt(val) > 0) {

				GetArrayString(a_Store_Player[client], i, pva, sizeof(pva));
				if (StringToInt(pva) > 0) return true;
			}
		}
	}
	return false;
}
