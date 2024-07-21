#if defined _readyup_included
 #endinput
#endif
#define _readyup_included

/*
 *	Called when the first client fully loads into the game.
 *	@noreturn
 */
forward ReadyUp_FirstClientLoaded();

/*
 *	Called when the saferoom door is OBLITERATED.
 *	@noreturn
 */
forward ReadyUp_SaferoomDoorDestroyed();

/*
 *	Called when the first client spawns, whether it's human or bot.
 *	@noreturn
 */
forward ReadyUp_FirstClientSpawn();

/*
 *	Called when all of the currently connected clients have fully loaded into the game.
 *	@noreturn
 */
forward ReadyUp_AllClientsLoaded();

/*
 *	Called when the Ready Up Period officially starts.
 *	@noreturn
 */
forward ReadyUp_ReadyUpStart();

/*
 *	Called when the Ready Up Period officially ends.
 *	@noreturn
 */
forward ReadyUp_ReadyUpEnd();

/*
 *	Called when the round ends. Does not fire in a failed mission in coop mode, instead see ReadyUp_CoopMapFailed.
 *
 *	@param gamemode		The gamemode type (0) Error (1) Coop (2) Versus (3) Survival
 *	@noreturn
 */
forward ReadyUp_RoundIsOver(int gamemode);

/*
 *	Called when the start of map saferoom door opens for the first time.
 *	@noreturn
 */
forward ReadyUp_CheckpointDoorStartOpened();

/*
 *	Called when the map transitions in coop gamemodes.
 *	@noreturn
 */
forward ReadyUp_CoopMapEnd();

/*
 *	Called when the finale of a campaign is completed.
 *	@noreturn
 */
forward ReadyUp_CampaignComplete();

/*
 *	Called when the round ends in coop due to a mission failure.
 *
 *	@param gamemode		The gamemode type (0) Error (1) Coop (2) Versus (3) Survival
 *	@noreturn
 */
forward ReadyUp_CoopMapFailed(int gamemode);

/*
 *	Called when the start of map Saferoom door is first locked.
 *	@noreturn
 */
forward ReadyUp_SaferoomLocked();

/*
 *	Called when a client fully loads into the game. This fires after OnClientPostAdminCheck
 *						and the load screen is no longer present for the user.
 *
 *	@param client		The userid of the player who has fully loaded.
 *	@noreturn
 */
forward ReadyUp_IsClientLoaded(int client);

/*
 *	Called when a ParsedConfig request has completed.
 *
 *	@param key			An adt_array holding all of the keys from a config file.
 *	@param value		An adt_array holding all of the values from a config file.
 *	@noreturn
 */
forward ReadyUp_LoadFromConfig(Handle key, Handle value);

/*
 *	Called when a ParsedConfig request has completed.
 *
 *	@param key			An adt_array holding all of the keys from a config file.
 *	@param value		An adt_array holding all of the values from a config file.
 *	@param section		An adt_array holding the current section of the config being parsed.
 *	@noreturn
 */
forward ReadyUp_LoadFromConfigEx(Handle key, Handle value, Handle section, char[] configname, int KeyCount);

/*
 *	Called when ReadyUp_ParseConfig() fails to parse.
 *
 *	@param config		path of config that could not be parsed.
 *	@param error		the error message explaining why the file failed to parse.
 *	@noreturn
 */
forward ReadyUp_ParseConfigFailed(char[] config, char[] error);

/*
 *	Called when a client uses one of the commands in the Ready Up Commands Library.
 *
 *	@param client		The userid of the player who used the command.
 *	@param command		The string command the player used.
 *	@noreturn
 */
forward ReadyUp_Command(int client, char[] command);

/*
 *	Called when a plugin or player requests the commands in the Ready Up Commands Library.
 *
 *	@param client		The userid of the player who used the command.
 *	@param commands		An adt_array holding all of the commands.
 *	@param descriptions	An adt_array holding all of the commands descriptions.
 *	@param flags		An adt_array holding all of the commands flags required.
 *	@noreturn
 */
forward ReadyUp_ListCommands(int client, Handle commands, Handle descriptions, Handle flags);

/*
 *	Called when a player actually disconnects from the server.
 *
 *	@param client		The userid of the player who disconnected.
 *	@noreturn
 */
forward ReadyUp_TrueDisconnect(int client);

/*
 *	Called when Ready Up is notified of a slot change by a module.
 *
 *	@noreturn
 */
forward ReadyUp_SlotChangeNotice();

/*
 *	Called when Ready Up is notified of any player being denied entry into the server.
 *
 *	@noreturn
 */
forward ReadyUp_FwdEntryDenied();

/*
 *	Called when Ready Up is sent a request for the header string.
 *
 *	@param header		The header string as defined in the readyup config.
 *	@noreturn
 */
forward ReadyUp_FwdGetHeader(const char[] header);

/*
 *	Called when Ready Up is notified of any player being allowed entry into the server.
 *
 *	@param client		The userid of the client who was allowed to enter the server.
 *	@noreturn
 */
forward ReadyUp_FwdEntryAllowed(int client);

/*
 *	Called when Ready Up is notified of any player being assigned to a team.
 *
 *	@param client		The userid of the client who was assigned to a team.
 *	@param team			The team the client was assigned to.
 *	@noreturn
 */
forward ReadyUp_FwdTeamAssigned(int client, int team);

/*
 *	Called when a module asks Ready Up to send information to another module.
 *
 *	@param nameConfig	The name of the config of the target module.
 *	@param nameCommand	The name of the command to send to the target module.
 *	@param value		The value of the command to send to the target module.
 *	@noreturn
 */
forward ReadyUp_FwdCallModule(char[] nameConfig, char[] nameCommand, int value);

/*
 *	Called when a player connects to the server, this sets the minimum survivors that should exist.
 *
 */
forward ReadyUp_SetSurvivorMinimum(int iMin);

/*
 *	Called when a plugin creates a companion.
 *
 */
forward ReadyUp_CreateCompanion(int client, char[] CompanionName);

/*
 *	Called when a client joins a team.
 *
 *	@param client		The userid of the client who joined a team.
 *	@noreturn
 */
forward ReadyUp_FwdChangeTeam(int client, int team);

/*
 *	Called when friendly fire values are transferred across modules.
 *
 *	@noreturn
 */
forward ReadyUp_FwdFriendlyFire(int client, int victim, int amount, int victimamount, int isfire, int bonusDamage);

/*
 *	Called on ReadyUp_NtvIsEmptyOnDisconnect().
 *
 *	@noreturn
 */
forward ReadyUp_IsEmptyOnDisconnect();

/*
 *	Called when a module calls ReadyUp_NtvGetMapList from Ready Up requesting the maplist.cfg rotation information.
 *
 *	@noreturn
 */
forward ReadyUp_FwdGetMapList(Handle MapList1, Handle MapList2, Handle MapListIdentifier, Handle MapListDescription);

/*
 *	Called when a module calls ReadyUp_NtvGetCampaignName from Ready Up requesting the current campaign name.
 *
 *	@param description	The name of the current campaign in rotation.
 *	@noreturn
 */
forward ReadyUp_FwdGetCampaignName(const char[] mapname);

/*
 *	Called when a plugin invokes a change to the maximum infected count.
 *
 *	@param count	The maximum infected count.
 *	@noreturn
 */
forward ReadyUp_SetInfectedBotLimit(int infectedCount);

/*
 *
 *	Called when a group user request is sent
 *
 *	@param client		The client id
 *	@param groupStatus	The status of membership (1 - member, 0 no member)
 */
forward ReadyUp_GroupMemberStatus(int client, int groupStatus);

/*
 *
 *	For stat tracking plugins (receiving info)
 *
 *	@param client		The client id
 *	@param type         The type of statistic to receive.
 *  @param amount       The amount to add to the specified statistic type.
 */
forward ReadyUp_FwdStatistics(int client, int type, int amount);

/*
 *
 *	When a survivor player enters the end of map checkpoint.
 *
 *	@param client		The client id
 */
forward ReadyUp_SurvivorEnteredCheckpoint(int client);

/*
 *
 *	For stat tracking plugins (sending info)
 *
 *	@param client		The client id
 *	@param type         The type of statistic to send out.
 *  @param amount       The amount to add to the specified statistic type.
 */
native ReadyUp_NtvStatistics(int client, int type, int amount);

/*
 *	Calls forward ReadyUp_IsEmptyOnDisconnect()
 *
 *	@noreturn;
 */
native ReadyUp_NtvIsEmptyOnDisconnect();

/*
 *	Call to request a users group status.
 *
 *	@param client	The client id
 *	@param groupStatus The clients group status
 */
native ReadyUp_NtvGroupMemberStatus(int client, int groupStatus);

/*
 *	Called when SKYRPG solo survivor handicap is locked into place.
 *
 *	@param handicaplevel	The handicap level of the player.
 *	@noreturn;
 */
native ReadyUp_NtvHandicapChanged(int handicaplevel);

/*
 *
 *	1 if it's the finale map
 *	0 if it's the first map
 *	-1 if it's any map in between
 *
 */
forward ReadyUp_GetCampaignStatus(int mapposition);

/*
 *
 *	Called when a plugin needs to create a new companion for a survivor.
 *
 */
native ReadyUp_NtvCreateCompanion(int client, char[] CompanionName);

/*
 *	Called when Ready Up is notified when a client controls a survivor.
 *
 *	@param client		The userid of the client who is now controlling the survivor.
 *	@noreturn
 */
native ReadyUp_FwdSurvivorControl(int client);

/*
 *	Called when a plugin requests to find out whether or not it's the last map of a given campaign.
 *
 *	@noreturn
 */
native ReadyUp_NtvIsCampaignFinale();

/*
 *	Called to determine if any other configs are currently being processed.
 *	This is a test forward to see if it corrects the errors printed to log.
 *	@return				1 if currently processing, 0 if not processing.
 */
native ReadyUp_NtvConfigProcessing();

/*
 *	Called when friendly fire values are transferred across modules.
 *
 *	@noreturn
 */
native ReadyUp_NtvFriendlyFire(int client, int victim, int amount, int victimamount, int isfire, int bonusDamage);

/*
 *	Checks whether or not the teams are flipped.
 *	@return				True if the teams are flipped, false if they are not.
 */
native bool:ReadyUp_IsTeamsFlipped();

/*
 *  Lets readyup know the round failed due to a restartvote of some sort.
 *  @noreturn
 */
native ReadyUp_RoundRestartedByVote();

/*
 *	Attempts to parse the specified file path.
 *
 *	@param config		The name of the config. .../configs/readyup/ is the base path.
 *	@noreturn
 */
native ReadyUp_ParseConfig(char[] config);

/*
 *	Returns the current gamemode. (0) Error (1) Coop (2) Versus (3) Survival
 *	@noreturn
 */
native ReadyUp_GetGameMode();

/*
 *	Attempts to register a command in the Ready Up Commands Library.
 *
 *	@param command		The command string to register.
 *	@param description	The command description.
 *	@param flags		The flags required to use the command.
 *	@return				True if successful, otherwise false.
 */
native ReadyUp_RegisterCommand(char[] command, char[] description, int flags);

/*
 *	Attempts to unregister a command in the Ready Up Commands Library.
 *
 *	@param command		The command string to unregister.
 *	@return				True if successful, otherwise false.
 */
native ReadyUp_RemoveCommand(char[] command);

/*
 *	Calls the ReadyUp_ListCommands forward.
 *
 *	@param client		The userid of the player who used the command.
 *	@noreturn
 */
native ReadyUp_GetCommands(int client);

/*
 *	Called when a module notifies Ready Up of a slot change.
 *
 *	@noreturn
 */
native ReadyUp_SlotChangeSuccess();

/*
 *	Calls the ReadyUp_FwdGetHeader forward when a module requests the header string.
 *
 *	@noreturn
 */
native ReadyUp_NtvGetHeader();

/*
 *	Calls the ReadyUp_FwdEntryDenied forward when a module notifies Ready Up of a player being denied entry to the server.
 *
 *	@noreturn
 */
native ReadyUp_NtvEntryDenied();

/*
 *	Calls the ReadyUp_FwdEntryAllowed forward when a module notifies Ready Up of a player being allowed entry to the server.
 *
 *	@param client		The userid of the player who was allowed entry.
 *	@noreturn
 */
native ReadyUp_NtvEntryAllowed(int client);

/*
 *	Calls the ReadyUp_FwdTeamAssigned forward when a module notifies Ready Up of a player being assigned to a team.
 *
 *	@param client		The userid of the client who was assigned to a team.
 *	@param team			The team the client was assigned to.
 *	@noreturn
 */
native ReadyUp_NtvTeamAssigned(int client, int team);

/*
 *	Calls the ReadyUp_FwdChangeTeam forward when a module REQUESTS that a players team change.
 *	Any module using the assigned forward can manage teams, such as the playerplus module.
 *
 *	@param client		The userid of the client who wants to change teams.
 *	@param team			The team the client wants to change to.
 *	@noreturn
 */
native ReadyUp_NtvChangeTeam(int client, int team);

/*
 *	Calls the ReadyUp_FwdSurvivorControl forward when a module notifies Ready Up when a client controls a survivor.
 *
 *	@param client		The userid of the client who is now controlling the survivor.
 *	@noreturn
 */
native ReadyUp_NtvSurvivorControl(int client);

/*
 *	Calls the ReadyUp_FwdCallModule forward when a module asks Ready Up to send information to another module.
 *
 *	@param nameConfig	The name of the config of the target module.
 *	@param nameCommand	The name of the command to send to the target module.
 *	@param value		The value of the command to send to the target module.
 *	@noreturn
 */
native ReadyUp_NtvCallModule(char[] nameConfig, char[] nameCommand, int value);

/*
 *	Calls the ReadyUp_FwdGetMapList forward which sends the maplist.cfg rotation to any modules that use the information.
 *
 *	@noreturn
 */
native ReadyUp_NtvGetMapList();

/*
 *	Calls the ReadyUp_FwdGetCampaignName forward which sends the current campaign name to any modules that use the information.
 *
 *	@noreturn
 */
 native ReadyUp_NtvGetCampaignName();