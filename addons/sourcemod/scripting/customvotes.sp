#pragma semicolon 1

// ====[ INCLUDES ]============================================================
#include <sourcemod>
#include <multicolors>
#if !defined REQUIRE_PLUGIN
#define REQUIRE_PLUGIN
#define CUSTOMVOTES_DEFINED_REQUIRE_PLUGIN
#endif
#include <nativevotes>
#if defined CUSTOMVOTES_DEFINED_REQUIRE_PLUGIN
#undef REQUIRE_PLUGIN
#undef CUSTOMVOTES_DEFINED_REQUIRE_PLUGIN
#endif

// ====[ DEFINES ]=============================================================
#define PLUGIN_NAME "Custom Votes"
#define PLUGIN_VERSION "2.0"
#define MAX_VOTE_TYPES 32
#define MAX_VOTE_MAPS 128
#define MAX_VOTE_OPTIONS 128

// ====[ HANDLES ]=============================================================
new Handle:g_hArrayVoteOptionName[MAX_VOTE_TYPES];
new Handle:g_hArrayVoteOptionResult[MAX_VOTE_TYPES];
new Handle:g_hArrayVoteMapList[MAX_VOTE_TYPES];
new Handle:g_hArrayRecentMaps;

// ====[ VARIABLES ]===========================================================
new g_iMapTime;
new g_iVoteCount;
new g_iActiveVoteIndex = -1;
new g_iActiveVoteInitiatorUserId;
new g_iActiveVoteSubject = -1;
new g_iActiveVoteEligibleClients;
new g_iActiveVoteYesVotes;
new g_iActiveVoteTargetUserId;
NativeVote g_hActiveNativeVote = null;
new g_iVoteType[MAX_VOTE_TYPES];
new g_iVoteDelay[MAX_VOTE_TYPES];
new g_iVoteCooldown[MAX_VOTE_TYPES];
new g_iVoteMinimum[MAX_VOTE_TYPES];
new g_iVoteImmunity[MAX_VOTE_TYPES];
new g_iVoteMaxCalls[MAX_VOTE_TYPES];
new g_iVotePasses[MAX_VOTE_TYPES];
new g_iVoteMaxPasses[MAX_VOTE_TYPES];
new g_iVoteMapRecent[MAX_VOTE_TYPES];
new g_iVoteCurrent[MAXPLAYERS + 1];
new g_iVoteRemaining[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new g_iVoteLast[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new bool:g_bVotePlayersBots[MAX_VOTE_TYPES];
new bool:g_bVotePlayersTeam[MAX_VOTE_TYPES];
new bool:g_bVoteMapCurrent[MAX_VOTE_TYPES];
new Float:g_flVoteRatio[MAX_VOTE_TYPES];
new String:g_strVoteName[MAX_VOTE_TYPES][MAX_NAME_LENGTH];
new String:g_strVoteConVar[MAX_VOTE_TYPES][MAX_NAME_LENGTH];
new String:g_strVoteOverride[MAX_VOTE_TYPES][MAX_NAME_LENGTH];
new String:g_strVoteCommand[MAX_VOTE_TYPES][255];
new String:g_strVoteChatTrigger[MAX_VOTE_TYPES][255];
new String:g_strVoteStartNotify[MAX_VOTE_TYPES][255];
new String:g_strVoteCallNotify[MAX_VOTE_TYPES][255];
new String:g_strVotePassNotify[MAX_VOTE_TYPES][255];
new String:g_strVoteFailNotify[MAX_VOTE_TYPES][255];
new String:g_strActiveVoteTargetIndex[16];
new String:g_strActiveVoteTargetId[16];
new String:g_strActiveVoteTargetAuth[32];
new String:g_strActiveVoteTargetName[MAX_NAME_LENGTH];
new String:g_strConfigFile[PLATFORM_MAX_PATH];
enum
{
	VoteType_Players = 0,
	VoteType_Map,
	VoteType_List,
	VoteType_Simple,
}

// ====[ PLUGIN ]==============================================================
public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "ReFlexPoison",
	description = PLUGIN_NAME,
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
}

// ====[ FUNCTIONS ]===========================================================
public OnPluginStart()
{
	CreateConVar("sm_customvotes_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);

	RegAdminCmd("sm_customvotes_reload", Command_Reload, ADMFLAG_ROOT, "Reloads the configuration file (Clears all votes)");
	RegAdminCmd("sm_votemenu", Command_ChooseVote, 0, "Opens the vote menu");

	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("customvotes.phrases");

	BuildPath(Path_SM, g_strConfigFile, sizeof(g_strConfigFile), "configs/customvotes.cfg");

	AddCommandListener(OnClientSayCmd, "say");
	AddCommandListener(OnClientSayCmd, "say_team");

	if(g_hArrayRecentMaps == INVALID_HANDLE)
		g_hArrayRecentMaps = CreateArray(MAX_NAME_LENGTH);
}

public OnMapStart()
{
	ResetActiveVote();
	g_iMapTime = 0;

	decl String:strMap[MAX_NAME_LENGTH];
	GetCurrentMap(strMap, sizeof(strMap));

	if(GetArraySize(g_hArrayRecentMaps) <= 0)
		PushArrayString(g_hArrayRecentMaps, strMap);
	else
	{
		ShiftArrayUp(g_hArrayRecentMaps, 0);
		SetArrayString(g_hArrayRecentMaps, 0, strMap);
	}

	Config_Load();
	CreateTimer(1.0, Timer_Second, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public OnClientConnected(iTarget)
{
	g_iVoteCurrent[iTarget] = -1;
	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
		g_iVoteRemaining[iTarget][iVote] = g_iVoteMaxCalls[iVote];
}

public OnClientDisconnect(iTarget)
{
	g_iVoteCurrent[iTarget] = -1;
	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
		g_iVoteRemaining[iTarget][iVote] = g_iVoteMaxCalls[iVote];
}

// ====[ COMMANDS ]============================================================
public Action:Command_Reload(iClient, iArgs)
{
	if(g_hActiveNativeVote != null && NativeVotes_IsVoteInProgress())
		NativeVotes_Cancel();
	Config_Load();
	return Plugin_Handled;
}

public Action:Command_ChooseVote(iClient, iArgs)
{
	if(!IsValidClient(iClient))
		return Plugin_Continue;

	if(IsAnyVoteInProgress())
	{
		CReplyToCommand(iClient, "[SM] %t", "Vote in Progress");
		CPrintToChat(iClient, "[SM] %t", "Vote in Progress");
		return Plugin_Handled;
	}

	if (GetClientTeam(iClient) == 1)//spec
	{
		CReplyToCommand(iClient, "[SM] 旁观者不允许投票");
		return Plugin_Handled;
	}

	Menu_ChooseVote(iClient);
	return Plugin_Handled;
}

public Action:OnClientSayCmd(iVoter, const String:strCmd[], iArgc)
{
	if(!IsValidClient(iVoter))
		return Plugin_Continue;

	decl String:strText[255];
	GetCmdArgString(strText, sizeof(strText));
	StripQuotes(strText);

	ReplaceString(strText, sizeof(strText), "!", "");
	ReplaceString(strText, sizeof(strText), "/", "");

	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
	{
		if(StrEqual(g_strVoteChatTrigger[iVote], strText))
		{
			g_iVoteCurrent[iVoter] = iVote;
			switch(g_iVoteType[iVote])
			{
				case VoteType_Players: Menu_PlayersVote(iVote, iVoter);
				case VoteType_Map: Menu_MapVote(iVote, iVoter);
				case VoteType_List: Menu_ListVote(iVote, iVoter);
				case VoteType_Simple: CastSimpleVote(iVote, iVoter);
			}
			break;
		}
	}

	return Plugin_Continue;
}

// ====[ MENUS ]===============================================================
public Menu_ChooseVote(iVoter)
{
	new Handle:hMenu = CreateMenu(MenuHandler_Vote);
	SetMenuTitle(hMenu, "Vote Menu:");

	decl String:strIndex[4];
	new iTime = GetTime();
	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
	{
		new iFlags;

		// Admin access
		if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
			{
			iFlags = ITEMDRAW_DISABLED;
			}

		// Max votes
		else if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
			{
			iFlags = ITEMDRAW_DISABLED;
			}

		// Max passes
		else if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
			{
			iFlags = ITEMDRAW_DISABLED;
			}

		// Cooldown
		else if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
			{
			iFlags = ITEMDRAW_DISABLED;
			}

		IntToString(iVote, strIndex, sizeof(strIndex));

		decl String:strName[56];
		strcopy(strName, sizeof(strName), g_strVoteName[iVote]);

		if(g_iVoteType[iVote] == VoteType_Simple)
		{
			if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
			{
				ReplaceString(strName, sizeof(strName), "{On|Off}", "Off", true);
				ReplaceString(strName, sizeof(strName), "{on|off}", "off", true);
			}
			else
			{
				ReplaceString(strName, sizeof(strName), "{On|Off}", "On", true);
				ReplaceString(strName, sizeof(strName), "{on|off}", "on", true);
			}
		}
		
		AddMenuItem(hMenu, strIndex, strName, iFlags);
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_Vote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[8];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = StringToInt(strBuffer);
		g_iVoteCurrent[iVoter] = iVote;

		switch(g_iVoteType[iVote])
		{
			case VoteType_Players: Menu_PlayersVote(iVote, iVoter);
			case VoteType_Map: Menu_MapVote(iVote, iVoter);
			case VoteType_List: Menu_ListVote(iVote, iVoter);
			case VoteType_Simple: CastSimpleVote(iVote, iVoter);
		}
	}
}

public Menu_PlayersVote(iVote, iVoter)
{
	if(IsAnyVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}

	new Handle:hMenu = CreateMenu(MenuHandler_PlayersVote);
	SetMenuTitle(hMenu, "%s:", g_strVoteName[iVote]);
	SetMenuExitBackButton(hMenu, true);

	new iCount;
	decl String:strUserId[8];
	decl String:strName[MAX_NAME_LENGTH + 12];

	new iVoterTeam = GetClientTeam(iVoter);
	for(new iTarget = 1; iTarget <= MaxClients; iTarget++) if(IsClientInGame(iTarget))
	{
		if(!g_bVotePlayersBots[iVote] && IsFakeClient(iTarget))
			continue;

		if(g_bVotePlayersTeam[iVote] && GetClientTeam(iTarget) != iVoterTeam)
			continue;

		new iFlags;
		if(iTarget == iVoter)
			iFlags = ITEMDRAW_DISABLED;

		new AdminId:idAdmin = GetUserAdmin(iTarget);
		if(idAdmin != INVALID_ADMIN_ID)
		{
			if(GetAdminImmunityLevel(idAdmin) >= g_iVoteImmunity[iVote])
				iFlags = ITEMDRAW_DISABLED;
		}

		IntToString(GetClientUserId(iTarget), strUserId, sizeof(strUserId));

		GetClientName(iTarget, strName, sizeof(strName));
		AddMenuItem(hMenu, strUserId, strName, iFlags);
		iCount++;
	}

	if(iCount <= 0)
	{
		CPrintToChat(iVoter, "%t", "No Valid Clients");
		return;
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_PlayersVote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Cancel && iParam2 == MenuCancel_ExitBack)
	{
		Menu_ChooseVote(iVoter);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[8];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = g_iVoteCurrent[iVoter];
		if(iVote == -1)
			return;

	if(IsAnyVoteInProgress())
		{
			CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
			return;
		}

		new iTarget = GetClientOfUserId(StringToInt(strBuffer));
		if(!IsValidClient(iTarget))
		{
			CPrintToChat(iVoter, "%t", "Player no longer available");
			Menu_ChooseVote(iVoter);
			return;
		}

		Vote_Players(iVote, iVoter, iTarget);
	}
}

public Vote_Players(iVote, iVoter, iTarget)
{
	StartNativeVote(iVote, iVoter, iTarget);
}
public Menu_MapVote(iVote, iVoter)
{
	if(IsAnyVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}

	new Handle:hMenu = CreateMenu(MenuHandler_MapVote);
	SetMenuTitle(hMenu, "%s:", g_strVoteName[iVote]);
	SetMenuExitBackButton(hMenu, true);

	decl String:strMap[MAX_NAME_LENGTH];
	decl String:strCurrentMap[MAX_NAME_LENGTH];
	decl String:strRecentMap[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];

	new iLastMapCount = GetArraySize(g_hArrayRecentMaps);
	if(iLastMapCount > g_iVoteMapRecent[iVote])
		iLastMapCount = g_iVoteMapRecent[iVote];

	new iMapCount = GetArraySize(g_hArrayVoteMapList[iVote]);
	if(iMapCount > MAX_VOTE_MAPS)
		iMapCount = MAX_VOTE_MAPS;

	for(new iMap = 0; iMap < iMapCount; iMap++)
	{
		new iFlags;
		if(g_bVoteMapCurrent[iVote])
		{
			GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));
			GetCurrentMap(strCurrentMap, sizeof(strCurrentMap));

			if(StrEqual(strMap, strRecentMap))
				iFlags = ITEMDRAW_DISABLED;
		}

		if(iLastMapCount > 0)
		{
			for(new iLastMap = 0; iLastMap < iLastMapCount; iLastMap++)
			{
				GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));
				GetArrayString(g_hArrayRecentMaps, iLastMap, strRecentMap, sizeof(strRecentMap));

				if(StrEqual(strMap, strRecentMap))
				{
					iFlags = ITEMDRAW_DISABLED;
					break;
				}
			}
		}

		Format(strBuffer, sizeof(strBuffer), "%s", strMap);
		AddMenuItem(hMenu, strMap, strBuffer, iFlags);
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_MapVote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Cancel && iParam2 == MenuCancel_ExitBack)
	{
		Menu_ChooseVote(iVoter);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[MAX_NAME_LENGTH];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = g_iVoteCurrent[iVoter];
		if(iVote == -1)
			return;

		if(IsAnyVoteInProgress())
		{
			CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
			return;
		}

		new iMap = -1;
		decl String:strMapName[MAX_NAME_LENGTH];
		for(new iMapList = 0; iMapList < GetArraySize(g_hArrayVoteMapList[iVote]); iMapList++)
		{
			GetArrayString(g_hArrayVoteMapList[iVote], iMapList, strMapName, sizeof(strMapName));
			if(StrEqual(strMapName, strBuffer))
			{
				iMap = iMapList;
				break;
			}
		}

		if(iMap == -1)
		{
			Menu_ChooseVote(iVoter);
			return;
		}

		Vote_Map(iVote, iVoter, iMap);
	}
}

public Vote_Map(iVote, iVoter, iMap)
{
	StartNativeVote(iVote, iVoter, iMap);
}
public Menu_ListVote(iVote, iVoter)
{
	if(IsAnyVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}

	new Handle:hMenu = CreateMenu(MenuHandler_ListVote);
	SetMenuTitle(hMenu, "%s:", g_strVoteName[iVote]);
	SetMenuExitBackButton(hMenu, true);

	decl String:strIndex[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];
	decl String:strOptionName[MAX_NAME_LENGTH];
	for(new iOption = 0; iOption < GetArraySize(g_hArrayVoteOptionName[iVote]); iOption++)
	{
		GetArrayString(g_hArrayVoteOptionName[iVote], iOption, strOptionName, sizeof(strOptionName));
		Format(strBuffer, sizeof(strBuffer), "%s", strOptionName);

		IntToString(iOption, strIndex, sizeof(strIndex));

		AddMenuItem(hMenu, strIndex, strBuffer);
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_ListVote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Cancel && iParam2 == MenuCancel_ExitBack)
	{
		Menu_ChooseVote(iVoter);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[MAX_NAME_LENGTH];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = g_iVoteCurrent[iVoter];
		if(iVote == -1)
		{
			return;
		}

		if(IsAnyVoteInProgress())
		{
			CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
			return;
		}

		new iOption = StringToInt(strBuffer);
		Vote_List(iVote, iVoter, iOption);
	}
}

public Vote_List(iVote, iVoter, iOption)
{
	StartNativeVote(iVote, iVoter, iOption);
}
public CastSimpleVote(iVote, iVoter)
{
	if(IsAnyVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}

	Vote_Simple(iVote, iVoter);
}

public Vote_Simple(iVote, iVoter)
{
	StartNativeVote(iVote, iVoter, -1);
}
stock bool:IsAnyVoteInProgress()
{
	return IsVoteInProgress() || NativeVotes_IsVoteInProgress();
}

stock ResetActiveVote()
{
	g_hActiveNativeVote = null;
	g_iActiveVoteIndex = -1;
	g_iActiveVoteInitiatorUserId = 0;
	g_iActiveVoteSubject = -1;
	g_iActiveVoteEligibleClients = 0;
	g_iActiveVoteYesVotes = 0;
	g_iActiveVoteTargetUserId = 0;
	g_strActiveVoteTargetIndex[0] = '\0';
	g_strActiveVoteTargetId[0] = '\0';
	g_strActiveVoteTargetAuth[0] = '\0';
	g_strActiveVoteTargetName[0] = '\0';
}

stock GetActiveVoteRequiredVotes()
{
	new iRequired = RoundToCeil(float(g_iActiveVoteEligibleClients) * g_flVoteRatio[g_iActiveVoteIndex]);
	if(iRequired < g_iVoteMinimum[g_iActiveVoteIndex])
		iRequired = g_iVoteMinimum[g_iActiveVoteIndex];
	return iRequired > 0 ? iRequired : 1;
}

stock ApplyOnOffString(iVote, String:strBuffer[], iBufferSize, bool:bCommandValue = false)
{
	new Handle:hConVar = FindConVar(g_strVoteConVar[iVote]);
	new bool:bEnabled = hConVar != INVALID_HANDLE && GetConVarBool(hConVar);
	if(bCommandValue)
		ReplaceString(strBuffer, iBufferSize, "{On|Off}", bEnabled ? "0" : "1", false);
	else if(bEnabled)
	{
		ReplaceString(strBuffer, iBufferSize, "{On|Off}", "Off", true);
		ReplaceString(strBuffer, iBufferSize, "{on|off}", "off", true);
	}
	else
	{
		ReplaceString(strBuffer, iBufferSize, "{On|Off}", "On", true);
		ReplaceString(strBuffer, iBufferSize, "{on|off}", "on", true);
	}
}

stock FormatActiveSubjectString(String:strBuffer[], iBufferSize, bool:bCommandValue = false)
{
	switch(g_iVoteType[g_iActiveVoteIndex])
	{
		case VoteType_Players: FormatTargetString(GetClientOfUserId(g_iActiveVoteTargetUserId), strBuffer, iBufferSize);
		case VoteType_Map: FormatMapString(g_iActiveVoteIndex, g_iActiveVoteSubject, strBuffer, iBufferSize);
		case VoteType_List: FormatOptionString(g_iActiveVoteIndex, g_iActiveVoteSubject, strBuffer, iBufferSize);
		case VoteType_Simple: ApplyOnOffString(g_iActiveVoteIndex, strBuffer, iBufferSize, bCommandValue);
	}
}

stock FormatActiveNotification(String:strBuffer[], iBufferSize, iVoter = 0)
{
	FormatVoteString(strBuffer, iBufferSize);
	if(!IsValidClient(iVoter))
		iVoter = GetClientOfUserId(g_iActiveVoteInitiatorUserId);
	if(IsValidClient(iVoter))
		FormatVoterString(iVoter, strBuffer, iBufferSize);
	FormatActiveSubjectString(strBuffer, iBufferSize);
}

stock BuildActiveVoteTitle(String:strTitle[], iTitleSize)
{
	strcopy(strTitle, iTitleSize, g_strVoteName[g_iActiveVoteIndex]);
	decl String:strSubject[MAX_NAME_LENGTH];
	new bool:bAppendSubject = true;
	switch(g_iVoteType[g_iActiveVoteIndex])
	{
		case VoteType_Players: strcopy(strSubject, sizeof(strSubject), g_strActiveVoteTargetName);
		case VoteType_Map: GetArrayString(g_hArrayVoteMapList[g_iActiveVoteIndex], g_iActiveVoteSubject, strSubject, sizeof(strSubject));
		case VoteType_List: GetArrayString(g_hArrayVoteOptionName[g_iActiveVoteIndex], g_iActiveVoteSubject, strSubject, sizeof(strSubject));
		case VoteType_Simple:
		{
			ApplyOnOffString(g_iActiveVoteIndex, strTitle, iTitleSize);
			bAppendSubject = false;
		}
	}
	if(bAppendSubject)
		Format(strTitle, iTitleSize, "%s (%s)", g_strVoteName[g_iActiveVoteIndex], strSubject);
	CRemoveTags(strTitle, iTitleSize);
}

stock bool:StartNativeVote(iVote, iVoter, iSubject)
{
	if(!IsValidClient(iVoter))
		return false;
	if(GetClientTeam(iVoter) <= 1)
	{
		CPrintToChat(iVoter, "[SM] 旁观者不允许投票");
		return false;
	}
	if(IsAnyVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return false;
	}
	if(!NativeVotes_IsVoteTypeSupported(NativeVotesType_Custom_YesNo))
	{
		CPrintToChat(iVoter, "[SM] NativeVotes Custom Yes/No is not supported.");
		return false;
	}

	new iPlayers[MAXPLAYERS + 1], iTotal, iVoterTeam = GetClientTeam(iVoter);
	for(new iClient = 1; iClient <= MaxClients; iClient++)
	{
		if(!IsClientInGame(iClient) || IsFakeClient(iClient) || GetClientTeam(iClient) <= 1)
			continue;
		if(g_iVoteType[iVote] == VoteType_Players && (iClient == iSubject || (g_bVotePlayersTeam[iVote] && GetClientTeam(iClient) != iVoterTeam)))
			continue;
		iPlayers[iTotal++] = iClient;
	}
	if(iTotal <= 0 || iTotal < g_iVoteMinimum[iVote])
	{
		CPrintToChat(iVoter, "%t", "Not Enough Valid Clients");
		return false;
	}

	ResetActiveVote();
	g_iActiveVoteIndex = iVote;
	g_iActiveVoteInitiatorUserId = GetClientUserId(iVoter);
	g_iActiveVoteSubject = iSubject;
	g_iActiveVoteEligibleClients = iTotal;
	if(g_iVoteType[iVote] == VoteType_Players)
	{
		g_iActiveVoteTargetUserId = GetClientUserId(iSubject);
		IntToString(iSubject, g_strActiveVoteTargetIndex, sizeof(g_strActiveVoteTargetIndex));
		IntToString(g_iActiveVoteTargetUserId, g_strActiveVoteTargetId, sizeof(g_strActiveVoteTargetId));
		GetClientAuthId(iSubject, AuthId_Steam2, g_strActiveVoteTargetAuth, sizeof(g_strActiveVoteTargetAuth));
		GetClientName(iSubject, g_strActiveVoteTargetName, sizeof(g_strActiveVoteTargetName));
	}

	NativeVote vote = new NativeVote(NativeVoteHandler, NativeVotesType_Custom_YesNo, NATIVEVOTES_ACTIONS_DEFAULT | MenuAction_Select);
	if(vote == null)
	{
		ResetActiveVote();
		CPrintToChat(iVoter, "[SM] Unable to create NativeVotes vote.");
		return false;
	}
	g_hActiveNativeVote = vote;
	vote.Initiator = iVoter;
	decl String:strTitle[192];
	BuildActiveVoteTitle(strTitle, sizeof(strTitle));
	vote.SetDetails("%s", strTitle);
	NativeVotes_SetResultCallback(vote, NativeVoteResultHandler);
	if(!vote.DisplayVote(iPlayers, iTotal, 30, VOTEFLAG_NO_REVOTES))
	{
		vote.Close();
		ResetActiveVote();
		CPrintToChat(iVoter, "[SM] Unable to display NativeVotes vote.");
		return false;
	}

	if(g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		g_iVoteRemaining[iVoter][iVote]--;
		CPrintToChat(iVoter, "%t", "Votes Remaining", g_iVoteRemaining[iVoter][iVote]);
	}
	g_iVoteLast[iVoter][iVote] = GetTime();
	if(g_strVoteStartNotify[iVote][0])
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVoteStartNotify[iVote]);
		FormatActiveNotification(strNotification, sizeof(strNotification), iVoter);
		ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
		ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);
		CPrintToChatAll("%s", strNotification);
	}
	return true;
}

public int NativeVoteHandler(NativeVote vote, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(vote != g_hActiveNativeVote || g_iActiveVoteIndex < 0)
				return 0;
			if(param2 == NATIVEVOTES_VOTE_YES)
				g_iActiveVoteYesVotes++;
			if(g_strVoteCallNotify[g_iActiveVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iActiveVoteIndex]);
				FormatActiveNotification(strNotification, sizeof(strNotification), param1);
				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", param2 == NATIVEVOTES_VOTE_YES ? "Yes" : "No", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", param2 == NATIVEVOTES_VOTE_YES ? "yes" : "no", true);
				CPrintToChatAll("%s", strNotification);
			}
		}
		case MenuAction_VoteCancel:
		{
			if(vote == g_hActiveNativeVote && g_iActiveVoteIndex >= 0)
			{
				vote.DisplayFail(param1 == VoteCancel_NoVotes ? NativeVotesFail_NotEnoughVotes : NativeVotesFail_Generic);
				NotifyActiveVoteFailure();
			}
		}
		case MenuAction_End:
		{
			new bool:bWasActive = vote == g_hActiveNativeVote;
			vote.Close();
			if(bWasActive)
				ResetActiveVote();
		}
	}
	return 0;
}

public void NativeVoteResultHandler(NativeVote vote, int num_votes, int num_clients, const int[] client_indexes, const int[] client_votes, int num_items, const int[] item_indexes, const int[] item_votes)
{
	if(vote != g_hActiveNativeVote || g_iActiveVoteIndex < 0)
		return;
	g_iActiveVoteYesVotes = 0;
	for(new iItem = 0; iItem < num_items; iItem++)
		if(item_indexes[iItem] == NATIVEVOTES_VOTE_YES)
			g_iActiveVoteYesVotes = item_votes[iItem];

	if(g_iActiveVoteYesVotes < GetActiveVoteRequiredVotes())
	{
		vote.DisplayFail(NativeVotesFail_Loses);
		NotifyActiveVoteFailure();
		return;
	}

	g_iVotePasses[g_iActiveVoteIndex]++;
	if(g_strVoteCommand[g_iActiveVoteIndex][0])
	{
		decl String:strCommand[255];
		strcopy(strCommand, sizeof(strCommand), g_strVoteCommand[g_iActiveVoteIndex]);
		FormatVoteString(strCommand, sizeof(strCommand));
		FormatActiveSubjectString(strCommand, sizeof(strCommand), true);
		ServerCommand(strCommand);
	}
	if(g_strVotePassNotify[g_iActiveVoteIndex][0])
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVotePassNotify[g_iActiveVoteIndex]);
		FormatActiveNotification(strNotification, sizeof(strNotification));
		CPrintToChatAll("%s", strNotification);
	}
	decl String:strTitle[192];
	BuildActiveVoteTitle(strTitle, sizeof(strTitle));
	vote.DisplayPass("%s", strTitle);
}

stock NotifyActiveVoteFailure()
{
	if(g_iActiveVoteIndex < 0 || !g_strVoteFailNotify[g_iActiveVoteIndex][0])
		return;
	decl String:strNotification[255];
	strcopy(strNotification, sizeof(strNotification), g_strVoteFailNotify[g_iActiveVoteIndex]);
	FormatActiveNotification(strNotification, sizeof(strNotification));
	CPrintToChatAll("%s", strNotification);
}
public Config_Load()
{
	if(!FileExists(g_strConfigFile))
	{
		SetFailState("Configuration file %s not found!", g_strConfigFile);
		return;
	}

	new Handle:hKeyValues = CreateKeyValues("Custom Votes");
	if(!FileToKeyValues(hKeyValues, g_strConfigFile) || !KvGotoFirstSubKey(hKeyValues))
	{
		SetFailState("Improper structure for configuration file %s!", g_strConfigFile);
		return;
	}

	g_iVoteCount = 0;

	for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
		g_iVoteCurrent[iVoter] = -1;

	for(new iVote = 0; iVote < MAX_VOTE_TYPES; iVote++)
	{
		g_iVoteDelay[iVote] = 0;
		g_iVoteMinimum[iVote] = 0;
		g_iVoteImmunity[iVote] = 0;
		g_iVoteMaxCalls[iVote] = 0;
		g_iVotePasses[iVote] = 0;
		g_iVoteMaxPasses[iVote] = 0;
		g_iVoteMapRecent[iVote] = 0;
		g_bVotePlayersBots[iVote] = false;
		g_bVotePlayersTeam[iVote] = false;
		g_bVoteMapCurrent[iVote] = false;
		g_flVoteRatio[iVote] = 0.0;
		strcopy(g_strVoteName[iVote], sizeof(g_strVoteName[]), "");
		strcopy(g_strVoteConVar[iVote], sizeof(g_strVoteConVar[]), "");
		strcopy(g_strVoteOverride[iVote], sizeof(g_strVoteOverride[]), "");
		strcopy(g_strVoteCommand[iVote], sizeof(g_strVoteCommand[]), "");
		strcopy(g_strVoteChatTrigger[iVote], sizeof(g_strVoteChatTrigger[]), "");
		strcopy(g_strVoteStartNotify[iVote], sizeof(g_strVoteStartNotify[]), "");
		strcopy(g_strVoteCallNotify[iVote], sizeof(g_strVoteCallNotify[]), "");
		strcopy(g_strVotePassNotify[iVote], sizeof(g_strVotePassNotify[]), "");
		strcopy(g_strVoteFailNotify[iVote], sizeof(g_strVoteFailNotify[]), "");

		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
		{
			g_iVoteRemaining[iVoter][iVote] = 0;
			g_iVoteLast[iVoter][iVote] = 0;
		}

		if(g_hArrayVoteOptionName[iVote] != INVALID_HANDLE)
		{
			CloseHandle(g_hArrayVoteOptionName[iVote]);
			g_hArrayVoteOptionName[iVote] = INVALID_HANDLE;
		}

		if(g_hArrayVoteOptionResult[iVote] != INVALID_HANDLE)
		{
			CloseHandle(g_hArrayVoteOptionResult[iVote]);
			g_hArrayVoteOptionResult[iVote] = INVALID_HANDLE;
		}

		if(g_hArrayVoteMapList[iVote] != INVALID_HANDLE)
		{
			CloseHandle(g_hArrayVoteMapList[iVote]);
			g_hArrayVoteMapList[iVote] = INVALID_HANDLE;
		}
	}

	new iVote;
	do
	{
		// Name of vote
		KvGetSectionName(hKeyValues, g_strVoteName[iVote], sizeof(g_strVoteName[]));

		// Type of vote (Valid types: players, map, list)
		decl String:strType[24];
		KvGetString(hKeyValues, "type", strType, sizeof(strType));

		if(StrEqual(strType, "players"))
			g_iVoteType[iVote] = VoteType_Players;
		else if(StrEqual(strType, "map"))
			g_iVoteType[iVote] = VoteType_Map;
		else if(StrEqual(strType, "list"))
			g_iVoteType[iVote] = VoteType_List;
		else if(StrEqual(strType, "simple"))
			g_iVoteType[iVote] = VoteType_Simple;
		else
		{
			LogError("Invalid vote type for vote %s", g_strVoteName[iVote]);
			continue;
		}

		// Delay in seconds before players vote after the map has changed
		g_iVoteDelay[iVote] = KvGetNum(hKeyValues, "delay");

		// Delay in seconds before players can vote again after casting a selection
		g_iVoteCooldown[iVote] = KvGetNum(hKeyValues, "cooldown");

		// Minimum votes required for the vote to pass (Overrides ratio)
		g_iVoteMinimum[iVote] = KvGetNum(hKeyValues, "minimum");

		// Admins with equal or higher immunity are removed from the vote
		g_iVoteImmunity[iVote] = KvGetNum(hKeyValues, "immunity");

		// Maximum times a player can vote
		g_iVoteMaxCalls[iVote] = KvGetNum(hKeyValues, "maxcalls");
		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
			g_iVoteRemaining[iVoter][iVote] = g_iVoteMaxCalls[iVote];

		// Maximum times a player can cast a selection
		g_iVoteMaxPasses[iVote] = KvGetNum(hKeyValues, "maxpasses");

		// Ratio of players required to cast a selection for the vote to pass
		g_flVoteRatio[iVote] = KvGetFloat(hKeyValues, "ratio");

		// Control variable being changed
		KvGetString(hKeyValues, "cvar", g_strVoteConVar[iVote], sizeof(g_strVoteConVar[]));

		// Admin override (Use this with admin_overrides.cfg to prohibit access from specific players)
		KvGetString(hKeyValues, "override", g_strVoteOverride[iVote], sizeof(g_strVoteOverride[]));

		// Command(s) ran when a vote is passed
		KvGetString(hKeyValues, "command", g_strVoteCommand[iVote], sizeof(g_strVoteCommand[]));

		// Chat trigger to open the vote selections (Do not include ! or / in the trigger)
		KvGetString(hKeyValues, "chattrigger", g_strVoteChatTrigger[iVote], sizeof(g_strVoteChatTrigger[]));

		// Printed to everyone's chat when a player starts a vote
		KvGetString(hKeyValues, "start_notify", g_strVoteStartNotify[iVote], sizeof(g_strVoteStartNotify[]));

		// Printed to everyone's chat when a player casts a selection
		KvGetString(hKeyValues, "call_notify", g_strVoteCallNotify[iVote], sizeof(g_strVoteCallNotify[]));

		// Printed to everyone's chat when the vote passes
		KvGetString(hKeyValues, "pass_notify", g_strVotePassNotify[iVote], sizeof(g_strVotePassNotify[]));

		// Printed to everyone's chat when the vote fails to pass
		KvGetString(hKeyValues, "fail_notify", g_strVoteFailNotify[iVote], sizeof(g_strVoteFailNotify[]));

		switch(g_iVoteType[iVote])
		{
			case VoteType_Players:
			{
				// Allows/disallows casting selections on bots
				g_bVotePlayersBots[iVote] = bool:KvGetNum(hKeyValues, "bots");

				// Restricts players to only casting selections on team members
				g_bVotePlayersTeam[iVote] = bool:KvGetNum(hKeyValues, "team");

			}
			case VoteType_Map:
			{
				// How many recent maps will be removed from the vote selections
				g_iVoteMapRecent[iVote] = KvGetNum(hKeyValues, "recentmaps");

				// Allows/disallows casting selections on the current map
				g_bVoteMapCurrent[iVote] = bool:KvGetNum(hKeyValues, "currentmap");

				// List of maps to populate the selection list
				decl String:strMapList[24];
				KvGetString(hKeyValues, "maplist", strMapList, sizeof(strMapList), "default");

				g_hArrayVoteMapList[iVote] = CreateArray(MAX_NAME_LENGTH);
				ReadMapList(g_hArrayVoteMapList[iVote], _, strMapList, MAPLIST_FLAG_CLEARARRAY | MAPLIST_FLAG_NO_DEFAULT);
			}
			case VoteType_List:
			{
				if(!KvGotoFirstSubKey(hKeyValues, false))
					continue;

				do
				{
					if(!KvGotoFirstSubKey(hKeyValues, false))
						continue;

					g_hArrayVoteOptionName[iVote] = CreateArray(16);
					g_hArrayVoteOptionResult[iVote] = CreateArray(16);
					do
					{
						// Vote option name
						decl String:strOptionName[MAX_NAME_LENGTH];
						KvGetSectionName(hKeyValues, strOptionName, sizeof(strOptionName));
						PushArrayString(g_hArrayVoteOptionName[iVote], strOptionName);

						// Vote option result
						decl String:strOptionResult[MAX_NAME_LENGTH];
						KvGetString(hKeyValues, NULL_STRING, strOptionResult, sizeof(strOptionResult));
						PushArrayString(g_hArrayVoteOptionResult[iVote], strOptionResult);
					}
					while(KvGotoNextKey(hKeyValues, false));
					KvGoBack(hKeyValues);
				}
				while(KvGotoNextKey(hKeyValues, false));
				KvGoBack(hKeyValues);
			}
		}
		iVote++;
	}
	while(KvGotoNextKey(hKeyValues, false));
	CloseHandle(hKeyValues);

	g_iVoteCount = iVote;
	LogMessage("Configuration file %s loaded.", g_strConfigFile);
}

public Action:Timer_Second(Handle:hTimer)
{
	g_iMapTime++;
}

// ====[ STOCKS ]==============================================================
stock bool:IsValidClient(iClient)
{
	if(iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
		return false;
	return true;
}

stock FormatVoterString(iVoter, String:strBuffer[], iBufferSize)
{
	decl String:strVoter[MAX_NAME_LENGTH];
	IntToString(iVoter, strVoter, sizeof(strVoter));

	QuoteString(strVoter, sizeof(strVoter));
	ReplaceString(strBuffer, iBufferSize, "{VOTER_INDEX}", strVoter, false);

	decl String:strVoterId[MAX_NAME_LENGTH];
	IntToString(GetClientUserId(iVoter), strVoterId, sizeof(strVoterId));

	QuoteString(strVoterId, sizeof(strVoterId));
	ReplaceString(strBuffer, iBufferSize, "{VOTER_ID}", strVoterId, false);

	decl String:strVoterSteamId[MAX_NAME_LENGTH];
	GetClientAuthId(iVoter, AuthId_Steam2, strVoterSteamId, sizeof(strVoterSteamId));

	QuoteString(strVoterSteamId, sizeof(strVoterSteamId));
	ReplaceString(strBuffer, iBufferSize, "{VOTER_STEAMID}", strVoterSteamId, false);

	decl String:strVoterName[MAX_NAME_LENGTH];
	GetClientName(iVoter, strVoterName, sizeof(strVoterName));

	QuoteString(strVoterName, sizeof(strVoterName));
	ReplaceString(strBuffer, iBufferSize, "{VOTER_NAME}", strVoterName, false);
}

stock FormatVoteString(String:strBuffer[], iBufferSize)
{
	decl String:strVoteAmount[MAX_NAME_LENGTH];
	IntToString(g_iActiveVoteYesVotes, strVoteAmount, sizeof(strVoteAmount));

	QuoteString(strVoteAmount, sizeof(strVoteAmount));
	ReplaceString(strBuffer, iBufferSize, "{VOTE_AMOUNT}", strVoteAmount, false);

	decl String:strVoteRequired[MAX_NAME_LENGTH];
	IntToString(GetActiveVoteRequiredVotes(), strVoteRequired, sizeof(strVoteRequired));

	QuoteString(strVoteRequired, sizeof(strVoteRequired));
	ReplaceString(strBuffer, iBufferSize, "{VOTE_REQUIRED}", strVoteRequired, false);
}

stock FormatTargetString(iTarget, String:strBuffer[], iBufferSize)
{
	// Check if target disconnected (Anti-Grief)
	if(!IsValidClient(iTarget))
	{
		decl String:strAntiGrief[255];
		strcopy(strAntiGrief, sizeof(strAntiGrief), "0");
		QuoteString(strAntiGrief, sizeof(strAntiGrief));
		ReplaceString(strBuffer, iBufferSize, "{TARGET_INDEX}", strAntiGrief, false);

		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strActiveVoteTargetId);
		QuoteString(strAntiGrief, sizeof(strAntiGrief));
		ReplaceString(strBuffer, iBufferSize, "{TARGET_ID}", strAntiGrief, false);

		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strActiveVoteTargetAuth);
		QuoteString(strAntiGrief, sizeof(strAntiGrief));
		ReplaceString(strBuffer, iBufferSize, "{TARGET_STEAMID}", strAntiGrief, false);

		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strActiveVoteTargetName);
		QuoteString(strAntiGrief, sizeof(strAntiGrief));
		ReplaceString(strBuffer, iBufferSize, "{TARGET_NAME}", strAntiGrief, false);
		return;
	}

	decl String:strTarget[MAX_NAME_LENGTH];
	IntToString(iTarget, strTarget, sizeof(strTarget));

	QuoteString(strTarget, sizeof(strTarget));
	ReplaceString(strBuffer, iBufferSize, "{TARGET_INDEX}", strTarget, false);

	decl String:strTargetId[MAX_NAME_LENGTH];
	IntToString(GetClientUserId(iTarget), strTargetId, sizeof(strTargetId));

	QuoteString(strTargetId, sizeof(strTargetId));
	ReplaceString(strBuffer, iBufferSize, "{TARGET_ID}", strTargetId, false);

	decl String:strTargetSteamId[MAX_NAME_LENGTH];
	GetClientAuthId(iTarget, AuthId_Steam2, strTargetSteamId, sizeof(strTargetSteamId));

	QuoteString(strTargetSteamId, sizeof(strTargetSteamId));
	ReplaceString(strBuffer, iBufferSize, "{TARGET_STEAMID}", strTargetSteamId, false);

	decl String:strTargetName[MAX_NAME_LENGTH];
	GetClientName(iTarget, strTargetName, sizeof(strTargetName));

	QuoteString(strTargetName, sizeof(strTargetName));
	ReplaceString(strBuffer, iBufferSize, "{TARGET_NAME}", strTargetName, false);
}

stock FormatMapString(iVote, iMap, String:strBuffer[], iBufferSize)
{
	decl String:strMap[MAX_NAME_LENGTH];
	GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));

	QuoteString(strMap, sizeof(strMap));
	ReplaceString(strBuffer, iBufferSize, "{MAP_NAME}", strMap, false);

	decl String:strCurrentMap[MAX_NAME_LENGTH];
	GetCurrentMap(strCurrentMap, sizeof(strCurrentMap));

	QuoteString(strCurrentMap, sizeof(strCurrentMap));
	ReplaceString(strBuffer, iBufferSize, "{CURRENT_MAP_NAME}", strCurrentMap, false);
}

stock FormatOptionString(iVote, iOption, String:strBuffer[], iBufferSize)
{
	decl String:strOptionName[MAX_NAME_LENGTH];
	GetArrayString(g_hArrayVoteOptionName[iVote], iOption, strOptionName, sizeof(strOptionName));

	QuoteString(strOptionName, sizeof(strOptionName));
	ReplaceString(strBuffer, iBufferSize, "{OPTION_NAME}", strOptionName, false);

	decl String:strOptionResult[MAX_NAME_LENGTH];
	GetArrayString(g_hArrayVoteOptionResult[iVote], iOption, strOptionResult, sizeof(strOptionResult));

	QuoteString(strOptionResult, sizeof(strOptionResult));
	ReplaceString(strBuffer, iBufferSize, "{OPTION_RESULT}", strOptionResult, false);
}

stock QuoteString(String:strBuffer[], iBuffersize)
{
	Format(strBuffer, iBuffersize + 4, "\"%s\"", strBuffer);
}
