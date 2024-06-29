/*	Database Definitions	*/
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define STEAM_ID_LENGTH 64

new Handle:hDatabase = INVALID_HANDLE;

public DBConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("Unable to connect to database: %s", error);
		//return;
	}

	hDatabase = hndl;
	LogMessage("Successfully connected to the database.");
}

MySQL_Init()
{
	new String:Error[255];
	hDatabase = SQL_Connect("teammanager", false, Error, sizeof(Error));
	if (hDatabase == INVALID_HANDLE)
	{
		LogMessage("Unable to connect to database: %s", Error);
		return;
	}
	else
	{
		LogMessage("Connected to database, successfully!");
	}
	SQL_FastQuery(hDatabase, "SET NAMES \"UTF8\"");

	decl String:TQuery[2048];

	// Set up the tables
	Format(TQuery, sizeof(TQuery), "CREATE TABLE IF NOT EXISTS `rankings` (`steam_id` varchar(32) NOT NULL, PRIMARY KEY (`steam_id`)) ENGINE=InnoDB;");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` CHARACTER SET utf8 COLLATE utf8_general_ci;");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `CK` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `CKA` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SK` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SD` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SDA` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `RE` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SI` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `ID` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `IDA` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `II` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `IRP` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SRP` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `Name` varchar(32) NOT NULL;");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `RankAvg` int(8) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SDT` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `IDT` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SDTA` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `IDTA` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `SDTR` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	Format(TQuery, sizeof(TQuery), "ALTER TABLE `rankings` ADD `IDTR` int(32) NOT NULL DEFAULT '0';");
	SQL_TQuery(hDatabase, SendQuery, TQuery);
	return;
}

public SendQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("%s", error);
		return;
	}
}

public SendQueryData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new bool:bFound = false;
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendQueryData] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data))
	{
		bFound = true;
		CommonKills[data] = SQL_FetchInt(hndl, 0);
		SpecialKills[data] = SQL_FetchInt(hndl, 1);
		SurvivorDamage[data] = SQL_FetchInt(hndl, 2);
		Rescues[data] = SQL_FetchInt(hndl, 3);
		SurvivorIncaps[data] = SQL_FetchInt(hndl, 4);
		InfectedDamage[data] = SQL_FetchInt(hndl, 5);
		InfectedIncaps[data] = SQL_FetchInt(hndl, 6);
		InfectedRoundsPlayed[data] = SQL_FetchInt(hndl, 7);
		SurvivorRoundsPlayed[data] = SQL_FetchInt(hndl, 8);
		CommonKillsAverage[data] = SQL_FetchInt(hndl, 9);
		SurvivorDamageAverage[data] = SQL_FetchInt(hndl, 10);
		InfectedDamageAverage[data] = SQL_FetchInt(hndl, 11);
		SurvivorDamageTaken[data] = SQL_FetchInt(hndl, 12);
		InfectedDamageTaken[data] = SQL_FetchInt(hndl, 13);
		SurvivorDamageTakenAverage[data] = SQL_FetchInt(hndl, 14);
		InfectedDamageTakenAverage[data] = SQL_FetchInt(hndl, 15);
		SurvivorDamageTakenRank[data] = SQL_FetchInt(hndl, 16);
		InfectedDamageTakenRank[data] = SQL_FetchInt(hndl, 17);
	}
	if (IsLegitimateClient(data))
	{
		if (!bFound)
		{
			LogMessage("[SendQueryData] (%N) New player! Creating default profile and saving.", data);
			CreatePlayerData(data);
		}
		else
		{
			if (!bLoadAttempted[data]) bLoadAttempted[data] = true;
			IsLoading[data] = false;
			GetClientRank(data);
			LogMessage("[SendQueryData] (%N) Player data has loaded successfully.", data);
		}
	}
}

public GetTop10Query(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[GetTop10Query] %s", error);
		return;
	}
	new i = 0;
	while (i <= 9 && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, TopRankedPlayers[i++], sizeof(TopRankedPlayers[]));
	}
}

public SendRankMaximumQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendRankMaximumQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) RankMaximum = SQL_FetchInt(hndl, 0);
}

public SendCommonsQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendCommonsQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) CommonRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendCommonsAverageQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendCommonsAverageQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) CommonKillsAverageRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendSpecialQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendSpecialQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) SpecialRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendSDamageQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendSDamageQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) SurvivorDamageRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendSDamageAverageQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendSDamageAverageQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) SurvivorDamageAverageRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendRescueQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendRescueQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) RescuesRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendSIncapsQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendSIncapsQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) SurvivorIncapsRank[data] = SQL_FetchInt(hndl, 0) - 1;
}

public SurvivorSendDamageTakenQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SurvivorSendDamageTakenQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) SurvivorDamageTakenRank[data] = SQL_FetchInt(hndl, 0) - 1;
}

public SurvivorSendDamageTakenQueryAverage(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SurvivorSendDamageTakenQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) SurvivorDamageTakenAverageRank[data] = SQL_FetchInt(hndl, 0) - 1;
}


public InfectedSendDamageTakenQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[InfectedSendDamageTakenQueryAverage] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) InfectedDamageTakenRank[data] = SQL_FetchInt(hndl, 0) - 1;
}

public InfectedSendDamageTakenQueryAverage(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[InfectedSendDamageTakenQueryAverage] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) InfectedDamageTakenAverageRank[data] = SQL_FetchInt(hndl, 0) - 1;
}





public SendIDamageQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendIDamageQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) InfectedDamageRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendIDamageAverageQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendIDamageAverageQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) InfectedDamageAverageRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public SendIIncapsQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[SendIIncapsQuery] %s", error);
		return;
	}
	while (SQL_FetchRow(hndl) && IsLegitimateClient(data) && !IsFakeClient(data)) InfectedIncapsRank[data] = SQL_FetchInt(hndl, 0) + 1;
}

public CreatePlayerData(client)
{
	if (IsLoading[client]) IsLoading[client] = false;
	CommonKills[client] = 0;
	SpecialKills[client] = 0;
	SurvivorDamage[client] = 0;
	Rescues[client] = 0;
	SurvivorIncaps[client] = 0;
	InfectedDamage[client] = 0;
	InfectedIncaps[client] = 0;
	InfectedRoundsPlayed[client] = 0;
	SurvivorRoundsPlayed[client] = 0;
	CommonKillsAverage[client] = 0;
	SurvivorDamageAverage[client] = 0;
	InfectedDamageAverage[client] = 0;
	SurvivorDamageTaken[client] = 0;
	InfectedDamageTaken[client] = 0;
	SurvivorDamageTakenRank[client] = 0;
	InfectedDamageTakenRank[client] = 0;
	GetClientRank(client);
}

public ClearPlayerData(client)
{
	CommonKills[client] = 0;
	SpecialKills[client] = 0;
	SurvivorDamage[client] = 0;
	Rescues[client] = 0;
	SurvivorIncaps[client] = 0;
	InfectedDamage[client] = 1;
	InfectedIncaps[client] = 0;
	InfectedRoundsPlayed[client] = 0;
	SurvivorRoundsPlayed[client] = 0;
	CommonKillsAverage[client] = 0;
	SurvivorDamageAverage[client] = 0;
	InfectedDamageAverage[client] = 0;
	SurvivorDamageTaken[client] = 0;
	InfectedDamageTaken[client] = 0;
	SurvivorDamageTakenRank[client] = 0;
	InfectedDamageTakenRank[client] = 0;
	IsLoading[client] = false;
}

public SavePlayerData(cl)
{
	if (IsLegitimateClient(cl) && !IsFakeClient(cl)) {

		decl String:TQuery[2048];
		decl String:Key[STEAM_ID_LENGTH];
		decl String:Name[256];
		decl String:PName[256];
		GetClientAuthString(cl, Key, sizeof(Key));
		GetClientName(cl, PName, sizeof(PName));
		SQL_EscapeString(hDatabase, PName, Name, sizeof(Name));
		if (StrEqual(Key, "BOT")) return;
		// If the player has data, it's impossible for them to have no damage on either team
		if (SurvivorDamage[cl] > 0 || InfectedDamage[cl] > 0)
		{
			if (Rank[cl] < 1 || (InfectedRoundsPlayed[cl] + SurvivorRoundsPlayed[cl]) < 30) Rank[cl] = 99999;

			Format(TQuery, sizeof(TQuery), "REPLACE INTO `rankings` (`steam_id`, `CK`, `SK`, `SD`, `RE`, `SI`, `ID`, `II`, `IRP`, `SRP`, `CKA`, `SDA`, `IDA`, `Name`, `RankAvg`, `SDT`, `IDT`, `SDTA`, `IDTA`, `SDTR`, `IDTR`) VALUES ('%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d');", Key, CommonKills[cl], SpecialKills[cl], SurvivorDamage[cl], Rescues[cl], SurvivorIncaps[cl], InfectedDamage[cl], InfectedIncaps[cl], InfectedRoundsPlayed[cl], SurvivorRoundsPlayed[cl], CommonKillsAverage[cl], SurvivorDamageAverage[cl], InfectedDamageAverage[cl], PName, Rank[cl], SurvivorDamageTaken[cl], InfectedDamageTaken[cl], SurvivorDamageTakenAverage[cl], InfectedDamageTakenAverage[cl], SurvivorDamageTakenRank[cl], InfectedDamageTakenRank[cl]);
			SQL_TQuery(hDatabase, SendQuery, TQuery, cl);
		}
	}
}

public LoadPlayerData(client)
{
	if (IsLegitimateClient(client) && !IsFakeClient(client)) {

		decl String:TQuery[2048];
		decl String:Key[STEAM_ID_LENGTH];
		GetClientAuthString(client, Key, sizeof(Key));
		Format(TQuery, sizeof(TQuery), "SELECT `CK`, `SK`, `SD`, `RE`, `SI`, `ID`, `II`, `IRP`, `SRP`, `CKA`, `SDA`, `IDA`, `SDT`, `IDT`, `SDTA`, `IDTA`, `SDTR`, `IDTR` FROM `rankings` WHERE (`steam_id` = '%s');", Key);
		SQL_TQuery(hDatabase, SendQueryData, TQuery, client);
	}
}

stock SaveAllPlayers()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClient(i) && !IsFakeClient(i)) SavePlayerData(i);
	}
}