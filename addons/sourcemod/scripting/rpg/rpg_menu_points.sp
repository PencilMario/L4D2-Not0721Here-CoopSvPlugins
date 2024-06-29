/* put the line below after all of the includes!
#pragma newdecls required
*/

stock void BuildPointsMenu(int client, char[] MenuName, char[] ConfigName = "none") {

	Handle menu					=	CreateMenu(BuildPointsMenuHandle);
	char OpenedMenu_t[64];
	Format(OpenedMenu_t, sizeof(OpenedMenu_t), "%s", MenuName);
	OpenedMenu[client]				=	OpenedMenu_t;

	char text[PLATFORM_MAX_PATH];
	char Name[64];
	char Name_Temp[64];

	float PointCost				=	0.0;
	float PointCostMinimum		=	0.0;
	int ExperienceCost				=	0;
	int menuPos						=	-1;
	char Command[64];
	char IsCooldown[64];
	Format(IsCooldown, sizeof(IsCooldown), "0");
	char quickCommand[64];
	//decl String:campaignSupported[512];
	//Format(campaignSupported, sizeof(campaignSupported), "-1");

	char teamsAllowed[64];
	char gamemodesAllowed[64];
	char flagsAllowed[64];
	char currentGamemode[64];
	char clientTeam[64];

	int iWeaponCat = 0;

	// Collect player team and server gamemode.
	Format(currentGamemode, sizeof(currentGamemode), "%d", ReadyUp_GetGameMode());
	Format(clientTeam, sizeof(clientTeam), "%d", GetClientTeam(client));

	int size						=	GetArraySize(a_Points);
	int iPreGameFree				=	0;
	if (size < 1) SetFailState("POINT MENU SIZE COULD NOT BE FOUND!!!");

	ClearArray(RPGMenuPosition[client]);
	char pos[4];

	for (int i = 0; i < size; i++) {

		MenuKeys[client]						=	GetArrayCell(a_Points, i, 0);
		MenuValues[client]						=	GetArrayCell(a_Points, i, 1);
		MenuSection[client]						=	GetArrayCell(a_Points, i, 2);

		GetArrayString(MenuSection[client], 0, Name, sizeof(Name));
		
		if (iIsWeaponLoadout[client] > 0) {

			iWeaponCat = GetKeyValueInt(MenuKeys[client], MenuValues[client], "weapon category?");
			if (iWeaponCat < 0 || iIsWeaponLoadout[client] - 1 != iWeaponCat) continue;
		}
		else if (!TalentListingFound(client, MenuKeys[client], MenuValues[client], MenuName)) continue;
		menuPos++;

		Format(pos, sizeof(pos), "%d", i);
		PushArrayString(RPGMenuPosition[client], pos);

		Format(quickCommand, sizeof(quickCommand), "none");

		// Reset data in display requirement variables to default values.
		Format(teamsAllowed, sizeof(teamsAllowed), "123");			// 1 (Spectator) 2 (Survivor) 3 (Infected) players allowed.
		Format(gamemodesAllowed, sizeof(gamemodesAllowed), "123");	// 1 (Coop) 2 (Versus) 3 (Survival) game mode variants allowed.
		Format(flagsAllowed, sizeof(flagsAllowed), "-1");			// -1 means no flag requirements specified.


		
		// Collect the display requirement variables values.
		FormatKeyValue(teamsAllowed, sizeof(teamsAllowed), MenuKeys[client], MenuValues[client], "team?", teamsAllowed);
		FormatKeyValue(gamemodesAllowed, sizeof(gamemodesAllowed), MenuKeys[client], MenuValues[client], "gamemode?", gamemodesAllowed);
		FormatKeyValue(flagsAllowed, sizeof(flagsAllowed), MenuKeys[client], MenuValues[client], "flags?", flagsAllowed);
		
		PointCost			= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost?");
		ExperienceCost		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "experience cost?");
		FormatKeyValue(Command, sizeof(Command), MenuKeys[client], MenuValues[client], "command?", Command);
		PointCostMinimum	= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost minimum?");
		FormatKeyValue(quickCommand, sizeof(quickCommand), MenuKeys[client], MenuValues[client], "quick bind?");
		Format(quickCommand, sizeof(quickCommand), "!%s", quickCommand);
		//FormatKeyValue(campaignSupported, sizeof(campaignSupported), MenuKeys[client], MenuValues[client], "campaign supported?", campaignSupported);

		iPreGameFree = GetKeyValueInt(MenuKeys[client], MenuValues[client], "pre-game free?");

		// If the player doesn't meet the requirements to have access to this menu option, we skip it.
		if (StrContains(teamsAllowed, clientTeam, false) == -1 || StrContains(gamemodesAllowed, currentGamemode, false) == -1 ||
			(!StrEqual(flagsAllowed, "-1", false) && !HasCommandAccess(client, flagsAllowed))) {

			menuPos--;
			continue;
		}

		if (StrEqual(Command, "respawn") && (IsPlayerAlive(client) || !b_HasDeathLocation[client] || b_HardcoreMode[client])) {

			menuPos--;
			continue;
		}

		/*if (!StrEqual(campaignSupported, "-1", false) && StrContains(campaignSupported, currentCampaignName, false) == -1) {

			menuPos--;
			continue;
		}*/
		Format(Name_Temp, sizeof(Name_Temp), "%T", Name, client);
		if (FindCharInString(Command, ':') != -1) Format(text, sizeof(text), "%T", "Buy Menu Option 1", client, Name_Temp, quickCommand);
		else {

			if (StrEqual(MenuName, "director menu")) {

				PointCost				+= (GetKeyValueFloat(MenuKeys[client], MenuValues[client], "cost handicap?") * LivingHumanSurvivors());
				if (PointCost > 1.0) PointCost = 1.0;
				PointCostMinimum		+=	(GetKeyValueFloat(MenuKeys[client], MenuValues[client], "min cost handicap?") * LivingHumanSurvivors());

				if (Points_Director > 0.0) PointCost *= Points_Director;
				if (PointCost < PointCostMinimum) PointCost = PointCostMinimum;

				if (menuPos < GetArraySize(a_DirectorActions_Cooldown)) GetArrayString(a_DirectorActions_Cooldown, menuPos, IsCooldown, sizeof(IsCooldown));
			}
			if (StringToInt(IsCooldown) > 0) Format(text, sizeof(text), "%T", "Buy Menu Option Cooldown", client, Name_Temp);
			else {

				if (!StrEqual(MenuName, "director menu")) {

					if (Points[client] == 0.0 || Points[client] > 0.0 && (Points[client] * PointCost) < PointCostMinimum) PointCost = PointCostMinimum;
					else {

						PointCost += (PointCost * fPointsCostLevel);
						//if (PointCost > 1.0) PointCost = 1.0;
						PointCost *= Points[client];
					}
				}

				if (iPreGameFree == 1 && !b_IsActiveRound) PointCost = 0.0;

				if (iIsWeaponLoadout[client] > 0) Format(text, sizeof(text), "%s", Name_Temp);
				else {

					if (PointPurchaseType == 0) Format(text, sizeof(text), "%T", "Buy Menu Option 2", client, Name_Temp, PointCost, quickCommand);
					else if (PointPurchaseType == 1) Format(text, sizeof(text), "%T", "Buy Menu Option 3", client, Name_Temp, ExperienceCost, quickCommand);
				}
			}
		}
		AddMenuItem(menu, text, text);
	}

	if (!StrEqual(MenuName, "director menu")) BuildMenuTitle(client, menu);
	else BuildMenuTitle(client, menu, -1);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public BuildPointsMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		char ConfigName[64];
		Format(ConfigName, sizeof(ConfigName), "%s", MenuSelection[client]);
		char MenuName[64];
		Format(MenuName, sizeof(MenuName), "%s", OpenedMenu[client]);

		char Name[64];
		char Command[64];
		char Parameter[64];
		//decl String:campaignSupported[512];
		//Format(campaignSupported, sizeof(campaignSupported), "-1");	// If there's no value for it, ignore.

		float PointCost				=	0.0;
		float PointCostMinimum		=	0.0;
		int ExperienceCost				=	0;
		int Count						=	0;
		int CountHandicap				=	0;
		int Drop						=	0;
		char Model[64];
		char IsCooldown[64];
		Format(IsCooldown, sizeof(IsCooldown), "0");
		int TargetClient				=	-1;
		int PCount						=	0;

		char teamsAllowed[64];
		char gamemodesAllowed[64];
		char flagsAllowed[64];
		char currentGamemode[64];
		char clientTeam[64];

		char pos[4];

		// Collect player team and server gamemode.
		Format(currentGamemode, sizeof(currentGamemode), "%d", ReadyUp_GetGameMode());
		Format(clientTeam, sizeof(clientTeam), "%d", GetClientTeam(client));

		//new size						=	GetArraySize(a_Points);

		int menuPos						=	0;
		int iPreGameFree				=	0;
		int iWeaponCat					=	-1;

		GetArrayString(RPGMenuPosition[client], slot, pos, sizeof(pos));

		int ipos = StringToInt(pos);
		MenuKeys[client]						=	GetArrayCell(a_Points, ipos, 0);
		MenuValues[client]						=	GetArrayCell(a_Points, ipos, 1);
		MenuSection[client]						=	GetArrayCell(a_Points, ipos, 2);

		GetArrayString(MenuSection[client], 0, Name, sizeof(Name));
		if (iIsWeaponLoadout[client] > 0) {

			iWeaponCat = GetKeyValueInt(MenuKeys[client], MenuValues[client], "weapon category?");
			SetArrayString(hWeaponList[client], iWeaponCat, Name);
			iIsWeaponLoadout[client] = 0;
			SpawnLoadoutEditor(client);
			return;
		}
		//else if (!TalentListingFound(client, MenuKeys[client], MenuValues[client], MenuName)) continue;
		menuPos++;

		// Reset data in display requirement variables to default values.
		Format(teamsAllowed, sizeof(teamsAllowed), "123");			// 1 (Spectator) 2 (Survivor) 3 (Infected) players allowed.
		Format(gamemodesAllowed, sizeof(gamemodesAllowed), "123");	// 1 (Coop) 2 (Versus) 3 (Survival) game mode variants allowed.
		Format(flagsAllowed, sizeof(flagsAllowed), "-1");			// -1 means no flag requirements specified.
			
		// Collect the display requirement variables values.
		FormatKeyValue(teamsAllowed, sizeof(teamsAllowed), MenuKeys[client], MenuValues[client], "team?", teamsAllowed);
		FormatKeyValue(gamemodesAllowed, sizeof(gamemodesAllowed), MenuKeys[client], MenuValues[client], "gamemode?", gamemodesAllowed);
		FormatKeyValue(flagsAllowed, sizeof(flagsAllowed), MenuKeys[client], MenuValues[client], "flags?", flagsAllowed);
			
		PointCost			= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost?");
		ExperienceCost		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "experience cost?");
		FormatKeyValue(Command, sizeof(Command), MenuKeys[client], MenuValues[client], "command?", Command);
		PointCostMinimum	= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost minimum?");
		//FormatKeyValue(campaignSupported, sizeof(campaignSupported), MenuKeys[client], MenuValues[client], "campaign supported?", campaignSupported);
		FormatKeyValue(Parameter, sizeof(Parameter), MenuKeys[client], MenuValues[client], "parameter?", Parameter);
		FormatKeyValue(Model, sizeof(Model), MenuKeys[client], MenuValues[client], "model?", Model);
		Count				= GetKeyValueInt(MenuKeys[client], MenuValues[client], "count?");
		CountHandicap		= GetKeyValueInt(MenuKeys[client], MenuValues[client], "count handicap?");
		Drop				= GetKeyValueInt(MenuKeys[client], MenuValues[client], "drop?");
		PCount				= GetKeyValueInt(MenuKeys[client], MenuValues[client], "pcount?");
		if (PCount < 1) PCount = 1;

		// If the player doesn't meet the requirements to have access to this menu option, we skip it.
		/*if (StrContains(teamsAllowed, clientTeam, false) == -1 || StrContains(gamemodesAllowed, currentGamemode, false) == -1 ||
			(!StrEqual(flagsAllowed, "-1", false) && !HasCommandAccess(client, flagsAllowed))) {

			menuPos--;
			continue;
		}

		if (StrEqual(Command, "respawn") && (IsPlayerAlive(client) || !b_HasDeathLocation[client])) {

			menuPos--;
			continue;
		}
		if (!StrEqual(campaignSupported, "-1", false) && StrContains(campaignSupported, currentCampaignName, false) == -1) {

			menuPos--;
			continue;
		}*/

		//PrintToChatAll("Item name: %s Menu Position: %d Slot: %d", Name, menuPos, slot);
		//PrintToChatAll("menuPos: %d Slot+1: %d", menuPos, slot+1);
		//if (menuPos == slot + 1) break;
	//}

		int CommonQueueMaxx = GetConfigValueInt("common queue limit?");
		//PrintToChatAll("Item name: %s Menu Position: %d Slot: %d", Name, menuPos, slot);
		if (FindCharInString(Command, ':') != -1) {

			if (StrEqual(MenuName, "director menu")) BuildPointsMenu(client, Command[1], ConfigName);
			else if (StrEqual(Command[1], "director priority")) BuildDirectorPriorityMenu(client);
			else if (StrEqual(Command[1], "MainMenu")) BuildMenu(client);
			else BuildPointsMenu(client, Command[1], ConfigName);
		}
		else {

			if (!StrEqual(MenuName, "director menu")) {

				if (GetClientTeam(client) == TEAM_INFECTED) {

					if (StringToInt(Parameter) == 8 && ActiveTanks() >= iTankLimitVersus) {

						PrintToChat(client, "%T", "Tank Limit Reached", client, orange, green, iTankLimitVersus, white);
						BuildPointsMenu(client, MenuName, ConfigName);
						return;
					}
					else if (StringToInt(Parameter) == 8 && f_TankCooldown != -1.0) {

						PrintToChat(client, "%T", "Tank On Cooldown", client, orange, white);
						BuildPointsMenu(client, MenuName, ConfigName);
						return;
					}
				}
				if (ExperienceCost > 0) ExperienceCost *= (fExperienceMultiplier * (PlayerLevel[client] - 1));

				if (Points[client] == 0.0 || Points[client] > 0.0 && (Points[client] * PointCost) < PointCostMinimum) PointCost = PointCostMinimum;
				else {

					// If the cost is not the minimum cost, then point cost is determined based on the point cost (a percentage multiplier)
					// which is then cast against a multiplier determined by the level of the player.
					// Doing this allows us to set initially low point costs which rise as a player rises in level.
					PointCost += (PointCost * fPointsCostLevel);
					//if (PointCost > 1.0) PointCost = 1.0;
					PointCost *= Points[client];
				}
				//else PointCost *= Points[client];

				iPreGameFree = GetKeyValueInt(MenuKeys[client], MenuValues[client], "pre-game free?");

				if ((StrEqual(Parameter, "health") && GetClientHealth(client) < GetMaximumHealth(client) || !StrEqual(Parameter, "health")) && (!StrEqual(Parameter, "health") && b_HardcoreMode[client] || !b_HardcoreMode[client]) && (PointPurchaseType == 0 && (Points[client] >= PointCost || PointCost == 0.0 || (!b_IsActiveRound && iPreGameFree == 1) || IsGhost(client) && StrEqual(Command, "change class") && StringToInt(Parameter) != 8)) ||
					(PointPurchaseType == 1 && (ExperienceLevel[client] >= ExperienceCost || ExperienceCost == 0 || IsGhost(client) && StrEqual(Command, "change class") && StringToInt(Parameter) != 8))) {

					if (!StrEqual(Command, "change class") || StrEqual(Command, "change class") && StrEqual(Parameter, "8") || StrEqual(Command, "change class") && IsPlayerAlive(client) && !IsGhost(client)) {

						if (PointPurchaseType == 0 && (Points[client] >= PointCost || PointCost == 0.0 || (!b_IsActiveRound && iPreGameFree == 1))) {

							if (PointCost > 0.0 && Points[client] >= PointCost || PointCost <= 0.0) {

								if (iPreGameFree != 1 || b_IsActiveRound) Points[client] -= PointCost;
							}
						}
						else if (PointPurchaseType == 1 && (ExperienceLevel[client] >= ExperienceCost || ExperienceCost == 0)) ExperienceLevel[client] -= ExperienceCost;
					}

					if (StrEqual(Parameter, "common") && StrContains(Model, ".mdl", false) != -1) {

						Count = Count + (CountHandicap * LivingSurvivorCount());

						for (int i = Count; i > 0 && GetArraySize(CommonInfectedQueue) < CommonQueueMaxx; i--) {

							if (Drop == 1) {

								ResizeArray(CommonInfectedQueue, GetArraySize(CommonInfectedQueue) + 1);
								ShiftArrayUp(CommonInfectedQueue, 0);
								SetArrayString(CommonInfectedQueue, 0, Model);
								TargetClient		=	FindLivingSurvivor();
								if (TargetClient > 0) ExecCheatCommand(TargetClient, Command, Parameter);
							}
							else PushArrayString(CommonInfectedQueue, Model);
						}
					}
					else if (StrEqual(Command, "change class")) {

						//if (IsGhost(client) && StringToInt(GetConfigValue("points purchase type?")) == 0) Points[client] += PointCost;
						//else if (IsGhost(client) && StringToInt(GetConfigValue("points purchase type?")) == 1) ExperienceLevel[client] += ExperienceCost;
						if (!IsGhost(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && PointPurchaseType == 0) Points[client] += PointCost;
						else if (!IsGhost(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
						else if (!IsGhost(client) && IsPlayerAlive(client) && FindZombieClass(client) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(client) != -1 && PointPurchaseType == 0) Points[client] += PointCost;
						else if (!IsGhost(client) && IsPlayerAlive(client) && FindZombieClass(client) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(client) != -1 && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
						if (FindZombieClass(client) != ZOMBIECLASS_TANK) ChangeInfectedClass(client, StringToInt(Parameter));
					}
					else if (StrEqual(Command, "respawn")) {

						SDKCall(hRoundRespawn, client);
						CreateTimer(0.2, Timer_TeleportRespawn, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					else if (StrEqual(Command, "melee")) {

						// Get rid of their old weapon
						//CheckIfRemoveWeapon(client, Parameter);
						L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);

						int ent			= CreateEntityByName("weapon_melee");

						DispatchKeyValue(ent, "melee_script_name", Parameter);
						DispatchSpawn(ent);

						EquipPlayerWeapon(client, ent);
						//ExecCheatCommand(client, Command, Parameter);
					}
					else {

						//CheckIfRemoveWeapon(client, Parameter);

						if ((PointCost == 0.0 || (iPreGameFree == 1 && !b_IsActiveRound)) && GetClientTeam(client) == TEAM_SURVIVOR) {

							if (StrContains(Parameter, "pistol", false) != -1 || IsMeleeWeaponParameter(Parameter)) {

								//if (StrContains(Parameter, "pistol", false) != -1 && IsDualWield(client)) {

								L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
								//}
							}
							else L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
						}
						//PrintToChat(client, "You bought %s using the %s command", Parameter, Command);
						for (int i = 0; i <= PCount; i++) {

							ExecCheatCommand(client, Command, Parameter);
						}
						if (StrEqual(Parameter, "health")) {

							CreateTimer(0.2, Timer_GiveMaximumHealth, client, TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
			else {

				if (menuPos < GetArraySize(a_DirectorActions_Cooldown)) GetArrayString(a_DirectorActions_Cooldown, menuPos, IsCooldown, sizeof(IsCooldown));
				if (StringToInt(IsCooldown) > 0 && GetConfigValueInt("menu override director cooldown?") == 0) PrintToChat(client, "%T", "Menu Option is On Cooldown", client, green, Name, white);
				else {

					if (PointPurchaseType == 0) {

						if (Points_Director == 0.0 || Points_Director > 0.0 && (Points_Director * PointCost) < PointCostMinimum) PointCost = PointCostMinimum;
						else PointCost *= Points_Director;

						if (Points_Director >= PointCost) {

							Points_Director -= PointCost;

							if (StrEqual(Parameter, "common") && StrContains(Model, ".mdl", false) != -1) {

								for (int i = Count; i > 0 && GetArraySize(CommonInfectedQueue) < CommonQueueMaxx; i--) {

									if (Drop == 1) {

										ResizeArray(CommonInfectedQueue, GetArraySize(CommonInfectedQueue) + 1);
										ShiftArrayUp(CommonInfectedQueue, 0);
										SetArrayString(CommonInfectedQueue, 0, Model);
										TargetClient		=	FindLivingSurvivor();
										if (TargetClient > 0) ExecCheatCommand(TargetClient, Command, Parameter);
									}
									else PushArrayString(CommonInfectedQueue, Model);
								}
							}
							else ExecCheatCommand(client, Command, Parameter);
						}
					}
					else if (PointPurchaseType == 1) {

						if (ExperienceLevel_Bots >= ExperienceCost || ExperienceCost == 0) ExperienceLevel_Bots -= ExperienceCost;
						if (StrEqual(Parameter, "common") && StrContains(Model, ".mdl", false) != -1) {

							for (int i = Count; i > 0 && GetArraySize(CommonInfectedQueue) < CommonQueueMaxx; i--) {

								if (Drop == 1) {

									ResizeArray(CommonInfectedQueue, GetArraySize(CommonInfectedQueue) + 1);
									ShiftArrayUp(CommonInfectedQueue, 0);
									SetArrayString(CommonInfectedQueue, 0, Model);
									TargetClient		=	FindLivingSurvivor();
									if (TargetClient > 0) ExecCheatCommand(TargetClient, Command, Parameter);
								}
								else PushArrayString(CommonInfectedQueue, Model);
							}
						}
						else ExecCheatCommand(client, Command, Parameter);
					}
				}
			}
			BuildPointsMenu(client, MenuName, ConfigName);
		}
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			if (iIsWeaponLoadout[client] == 0) BuildMenu(client);
			else SpawnLoadoutEditor(client);
		}
	}
	else if (action == MenuAction_End) {

		CloseHandle(menu);
	}
}
