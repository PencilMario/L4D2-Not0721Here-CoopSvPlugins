#include <sourcemod>
#include <sdktools>
//#include <treeutil/treeutil.sp>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util>
//Define CVARS
#define MAX_SURVIVORS GetConVarInt(FindConVar("survivor_limit"))
#define MAX_INFECTED GetConVarInt(FindConVar("z_max_player_zombies"))
#define PLUGIN_VERSION "1.6"

#define	ASSAULT_RIFLE_OFFSET_IAMMO		12;
#define	SMG_OFFSET_IAMMO				20;
#define	PUMPSHOTGUN_OFFSET_IAMMO		28;
#define	AUTO_SHOTGUN_OFFSET_IAMMO		32;
#define	HUNTING_RIFLE_OFFSET_IAMMO		36;
#define	MILITARY_SNIPER_OFFSET_IAMMO	40;
#define	GRENADE_LAUNCHER_OFFSET_IAMMO	68;

// 最大特感数
ConVar g_cMaxSpecials;

// Sdk calls
new Handle:gConf = INVALID_HANDLE;
new Handle:fSHS = INVALID_HANDLE;
new Handle:fTOB = INVALID_HANDLE;


//Handles
new Handle:cc_plpOnConnect = INVALID_HANDLE;
new Handle:cc_plpTimer = INVALID_HANDLE;
new Handle:cc_plpAutoRefreshPanel = INVALID_HANDLE;
new Handle:cc_plpPaSTimer = INVALID_HANDLE;
new Handle:cc_plpPaShowscores = INVALID_HANDLE;
new Handle:cc_plpAnnounce = INVALID_HANDLE;
new Handle:cc_plpSelectTeam = INVALID_HANDLE;
new Handle:cc_plpHintStatic = INVALID_HANDLE;
new Handle:cc_plpSpectatorSelect = INVALID_HANDLE;
new Handle:cc_plpSurvivorSelect = INVALID_HANDLE;
new Handle:cc_plpInfectedSelect = INVALID_HANDLE;
new Handle:cc_plpShowBots = INVALID_HANDLE;


//Strings
new String:hintText[2048];


//CVARS
new plpOnConnect;
new plpTimer;
new plpPaSTimer;
new plpAutoRefreshPanel;
new plpPaShowscores;
new plpAnnounce;
new plpSelectTeam;
new plpHintStatic;
new plpSpectatorSelect;
new plpSurvivorSelect;
new plpInfectedSelect;
new plpShowBots;
new ClientAutoRefreshPanel[33];
new wantedrefresh[33];
new hintstatic[33];
new maxcl;


//Plugin Info Block
public Plugin:myinfo =
{
	name = "Playerlist Panel",
	author = "OtterNas3",
	description = "Shows Panel for Teams on Server",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
};


//Plugin start
public OnPluginStart()
{
	//Load Translation file
	LoadTranslations("l4d_teamspanel.phrases");
	
	//SDK Calls (copied, credits to L4DSwitchPlayers)
	gConf = LoadGameConfigFile("l4dteamspanel");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	fSHS = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "TakeOverBot");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	fTOB = EndPrepSDKCall();
	

	//Reg Commands
	RegConsoleCmd("sm_teams", PrintTeamsToClient);
	RegConsoleCmd("sm_panel", PrintTeamsToClient);
	RegConsoleCmd("sm_spechud", PrintTeamsToClient);
	//Reg Cvars
	CreateConVar("l4d_plp_version", PLUGIN_VERSION, "Playerlist Panel Display Version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cc_plpOnConnect = CreateConVar("l4d_plp_onconnect", "0", "Show Playerlist Panel on connect?");
	cc_plpTimer = CreateConVar("l4d_plp_timer", "20", "How long, in seconds, the Playerlist Panel stay before it close automatic");
	cc_plpAutoRefreshPanel = CreateConVar("l4d_plp_autorefreshpanel", "1", "Should the Panel be static & refresh itself every second?");
	cc_plpPaShowscores = CreateConVar("l4d_plp_pashowscores", "0", "Show Playerlist Panel after Showscores? NO REFRESH!");
	cc_plpPaSTimer = CreateConVar("l4d_plp_pastimer", "5", "How long, in seconds, the Playerlist Panel stay after Showscores \nIf l4d_plp_pashowscores is = 1");
	cc_plpAnnounce = CreateConVar("l4d_plp_announce", "0", "Show Hint-Message about the command to players on Spectator?");
	cc_plpSelectTeam = CreateConVar ("l4d_plp_select_team", "0", "Should the user be able to select a team on Playerlist Panel?");
	cc_plpHintStatic = CreateConVar ("l4d_plp_hint_static", "0", "Should the Hint for Panel options be Static?");
	cc_plpSpectatorSelect = CreateConVar ("l4d_plp_select_team_spectator", "0", "If l4d_plp_select_team = 1 \nShould the Spectator selection be functional?");
	cc_plpSurvivorSelect = CreateConVar ("l4d_plp_select_team_survivor", "0", "If l4d_plp_select_team = 1 \nShould the Survivor selection be functional?");
	cc_plpInfectedSelect = CreateConVar ("l4d_plp_select_team_infected", "0", "If l4d_plp_select_team = 1 \nShould the Infected selection be functional?");
	cc_plpShowBots = CreateConVar ("l4d_plp_show_bots", "1", "Should bots be listed in Panel?");

	g_cMaxSpecials = FindConVar("sss_1P");
	//Execute the config file
	//AutoExecConfig(true, "l4d_teamspanel");

	//Hook Cvars
	HookConVarChange(cc_plpOnConnect, ConVarChanged);
	HookConVarChange(cc_plpTimer, ConVarChanged);
	HookConVarChange(cc_plpAutoRefreshPanel, ConVarChanged);
	HookConVarChange(cc_plpPaSTimer, ConVarChanged);
	HookConVarChange(cc_plpPaShowscores, ConVarChanged);
	HookConVarChange(cc_plpAnnounce, ConVarChanged);
	HookConVarChange(cc_plpSelectTeam, ConVarChanged);
	HookConVarChange(cc_plpHintStatic, ConVarChanged);
	HookConVarChange(cc_plpSpectatorSelect, ConVarChanged);
	HookConVarChange(cc_plpSurvivorSelect, ConVarChanged);
	HookConVarChange(cc_plpInfectedSelect, ConVarChanged);
	HookConVarChange(cc_plpShowBots, ConVarChanged);
	
	//Build Hint Text depending on cvars
	HintText();
	
	//Checking !REAL! MaxClients
	maxcl = maxclToolzDowntownCheck();
	
	//Re read CVARS
	ReadCvars();
}


//Search for running L4DToolz and/or L4Downtown (or none of them) to get correct Max Clients
maxclToolzDowntownCheck()
{
	new Handle:invalid = INVALID_HANDLE;
	new Handle:downtownrun = FindConVar("l4d_maxplayers");
	new Handle:toolzrun = FindConVar("sv_maxplayers");
	
	//Downtown is running!
	if (downtownrun != (invalid))
	{
		//Is Downtown used for slot patching? if yes use it for Max Players
		new downtown = (GetConVarInt(FindConVar("l4d_maxplayers")));
		if (downtown >= 1)
		{
			maxcl = (GetConVarInt(FindConVar("l4d_maxplayers")));
		}
	}

	//L4DToolz is running!
	if (toolzrun != (invalid))
	{
		//Is L4DToolz used for slot patching? if yes use it for Max Players
		new toolz = (GetConVarInt(FindConVar("sv_maxplayers")));
		if (toolz >= 1)
		{
			maxcl = (GetConVarInt(FindConVar("sv_maxplayers")));
		}
	}

	//No Downtown or L4DToolz running using fallback (possible x/32)
	if (downtownrun == (invalid) && toolzrun == (invalid))
	{
		maxcl = (MaxClients);
	}
	return maxcl;
}


//Prepare & Print Playerlist Panel
public BuildPrintPanel(client)
{
	//Get correct Max Clients
	maxcl = maxclToolzDowntownCheck();

	//Build panel
	new Handle:TeamPanel = CreatePanel();
	SetPanelTitle(TeamPanel, ">> 玩家列表菜单 <<");
	DrawPanelText(TeamPanel, " \n");
	new count;
	new i, sumall, sumspec, sumsurv, suminf;
	new String:text[256];
	char hpstatus[150];
	//Counting
	sumall = CountAllHumanPlayers();
	sumspec = CountPlayersTeam(1);
	sumsurv = CountPlayersTeam(2);
	suminf = CountPlayersTeamAlive(3)
	
	
	//Draw Spectators count line
	Format(text, sizeof(text), "->臭ob的 (%d)", sumspec);
	
	//Slectable Spectators or not
	DrawPanelItem(TeamPanel, text);
	//DrawPanelText(TeamPanel, "");

	//Get & Draw Spectator Player Names
	count = 1;
	bool skip = false;
	for (i=1;i<=MaxClients;i++)
	{
		if (skip) continue;
		if (sumspec > 4){
			Format(text, sizeof(text), "一万个旁观，不干了！");
			DrawPanelText(TeamPanel, text);
			skip = true;
		}
		if (IsValidPlayer(i) && GetClientTeam(i) == 1)
		{
			Format(text, sizeof(text), "%d. %N", count, i);
			DrawPanelText(TeamPanel, text);
			count++;
		}
	}
	DrawPanelText(TeamPanel, " \n");
	
	//Draw Survivors count line
	Format(text, sizeof(text), "->生还者 (%d) ", sumsurv);
	DrawPanelItem(TeamPanel, text);
	//DrawPanelText(TeamPanel, " \n");

	//Get & Draw Survivor Player Names
	count = 1;
	for (i=1;i<=MaxClients;i++)
	{
		if (plpShowBots > 0)
		{
			if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2)
			{
				GetClientHealthStatus(i, hpstatus, sizeof(hpstatus));
				Format(text, sizeof(text), "%N - %s", i, hpstatus);
				DrawPanelText(TeamPanel, text);
				count++;
			}
		}
		else
		{
			if (IsValidPlayer(i) && GetClientTeam(i) == 2)
			{
				GetClientHealthStatus(i, hpstatus, sizeof(hpstatus));
				Format(text, sizeof(text), "%N - %s", i, hpstatus);
				DrawPanelText(TeamPanel, text);
				count++;
			}
		}
	}
	DrawPanelText(TeamPanel, " \n");

	//Draw Infected part depending on gamemode
	//
	//Gamemode is Versus
	//Draw Infected count line
	Format(text, sizeof(text), "->特殊感染者 (%d/%d)", suminf, g_cMaxSpecials.IntValue);
	DrawPanelItem(TeamPanel, text);
	//DrawPanelText(TeamPanel, " \n");
	count = 0;
	int i_SiTypeCount[L4D2Infected_Size];
	for (i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i)){
			if (!IsPlayerAlive(i)) continue;
			int type = GetInfectedClass(i);
			if (type != -1) {
				i_SiTypeCount[type]++;
				count++
			}
		}
	}
	//Format(text, sizeof(text), "总计: %i\n", count);
	//DrawPanelText(TeamPanel, text);
	Format(text, sizeof(text), "Smoker: %i", i_SiTypeCount[L4D2Infected_Smoker]);
	if (i_SiTypeCount[L4D2Infected_Smoker] > 0) DrawPanelText(TeamPanel, text);
	Format(text, sizeof(text), "Boomer: %i", i_SiTypeCount[L4D2Infected_Boomer]);
	if (i_SiTypeCount[L4D2Infected_Boomer] > 0) DrawPanelText(TeamPanel, text);
	Format(text, sizeof(text), "Hunter: %i", i_SiTypeCount[L4D2Infected_Hunter]);
	if (i_SiTypeCount[L4D2Infected_Hunter] > 0) DrawPanelText(TeamPanel, text);
	Format(text, sizeof(text), "Spitter: %i", i_SiTypeCount[L4D2Infected_Spitter]);
	if (i_SiTypeCount[L4D2Infected_Spitter] > 0) DrawPanelText(TeamPanel, text);
	Format(text, sizeof(text), "Jockey: %i", i_SiTypeCount[L4D2Infected_Jockey]);
	if (i_SiTypeCount[L4D2Infected_Jockey] > 0) DrawPanelText(TeamPanel, text);
	Format(text, sizeof(text), "Charger: %i", i_SiTypeCount[L4D2Infected_Charger]);
	if (i_SiTypeCount[L4D2Infected_Charger] > 0) DrawPanelText(TeamPanel, text);
	
	if (i_SiTypeCount[L4D2Infected_Tank] > 0){
		DrawPanelText(TeamPanel, "\n");
		Format(text, sizeof(text), "->坦克 (%d) ", i_SiTypeCount[L4D2Infected_Tank]);
		DrawPanelItem(TeamPanel, text);
		//DrawPanelText(TeamPanel, "\n");
		count = 1;
		for (i = 1; i <= MaxClients; i++){
			if (!IsClientInGame(i)) continue;
			if (GetInfectedClass(i) == L4D2Infected_Tank){
				GetClientHealthStatus(i, hpstatus, sizeof(hpstatus));
				Format(text, sizeof(text), "Tank%d - %s", count++, hpstatus);
				DrawPanelText(TeamPanel, text);
			}
		}
	}

	//Draw Total connected Players & Draw Final
	//DrawPanelText(TeamPanel, " \n");
	//Format(text, sizeof(text), "\x04已连接: %d/%d", sumall, maxcl);
	//DrawPanelText(TeamPanel, text);
	

	//Draw Total connected Players & Draw Final
	DrawPanelText(TeamPanel, " \n");
	Format(text, sizeof(text), ">> 玩家总计: %d/%d <<", sumall, maxcl);
	DrawPanelText(TeamPanel, text);


	//Send Panel to client
	if (plpSelectTeam == 1)
	{
		SendPanelToClient(TeamPanel, client, TeamPanelHandlerB, plpTimer);
		CloseHandle(TeamPanel);
	}
	if (plpSelectTeam == 0)
	{
		SendPanelToClient(TeamPanel, client, TeamPanelHandler, plpTimer);
		CloseHandle(TeamPanel);
	}
}


//TeamPanelHandler
public TeamPanelHandler(Handle:TeamPanel, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		if (wantedrefresh[param1] == 0)
		{
			ClientAutoRefreshPanel[param1] = 0;
			hintstatic[param1] = 0;
		}
	}
	else if (action == MenuAction_Select)
	{
		if (param2 >= 1)
		{
			ClientAutoRefreshPanel[param1] = 0;
			hintstatic[param1] = 0;
		}
	}
}
public void GetClientHealthStatus(int client, char[] buffer, int len){
	char info[100];
	if (IsPlayerAlive(client)){
		int health = GetSurvivorPermanentHealth(client) + (GetClientTeam(client) == 2 ? GetSurvivorTemporaryHealth(client) : 0);
		Format(buffer, len, "%dHP", health)
	}else{
		Format(buffer, len, "死亡")
	}
	
	if (GetClientTeam(client) == TEAM_SURVIVOR){
		if (GetSurvivorTemporaryHealth(client) > 0) Format(buffer, len, "#%s", buffer);
		if (IsPlayerAlive(client)){
			GetWeaponInfo(client, info, sizeof(info));
			Format(buffer, len, "%s [%s]", buffer, info);
		}
		if (!IsFakeClient(client)){
			if (GetClientAvgLatency(client, NetFlow_Both) > 0.125) Format(buffer, len, "%s[Ping:%.0f]", buffer, GetClientAvgLatency(client, NetFlow_Both)*1000);
			if (GetClientAvgLoss(client, NetFlow_Both) > 0.05) Format(buffer, len, "%s[Loss]", buffer);
			if (GetClientAvgChoke(client, NetFlow_Both) > 0.05) Format(buffer, len, "%s[Choke]", buffer);
		}
		if (IsHangingFromLedge(client)) Format(buffer, len, "%s[挂边]", buffer);
		if ((IsIncapacitated(client) || GetSurvivorIncapCount(client) > 0) && IsPlayerAlive(client)) Format(buffer, len, "%s[倒地#%d]", buffer, IsIncapacitated(client) ? GetSurvivorIncapCount(client) + 1 : GetSurvivorIncapCount(client));
		if (GetClientPinnedInfectedType(client) != -1){
			switch (GetClientPinnedInfectedType(client)){
				case L4D2Infected_Hunter:
					Format(buffer, len, "%s[被HT控]", buffer);
				case L4D2Infected_Smoker:
					Format(buffer, len, "%s[被舌头控]", buffer);
				case L4D2Infected_Jockey:
					Format(buffer, len, "%s[被猴子控]", buffer);
				case L4D2Infected_Charger:
					Format(buffer, len, "%s[被牛控]", buffer);
			}
		}
	}
	if (GetClientTeam(client) == L4D2Team_Infected){
		if (IsEntityOnFire(client)) Format(buffer, len, "%s[点燃]", buffer);
	}
}

//TeamPanelHandlerB
public TeamPanelHandlerB(Handle:TeamPanel, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 1)
		{
			if (plpSpectatorSelect == 1)
			{
				PerformSwitch(param1, 1);
			}
			ClientAutoRefreshPanel[param1] = 0;
			hintstatic[param1] = 0;
		}
		else if (param2 == 2)
		{
			if (plpSurvivorSelect == 1)
			{
				PerformSwitch(param1, 2);
			}
			ClientAutoRefreshPanel[param1] = 0;
			hintstatic[param1] = 0;
		}
		else if (param2 == 3)
		{
			if (plpInfectedSelect == 1)
			{
				PerformSwitch(param1, 3);
			}
			ClientAutoRefreshPanel[param1] = 0;
			hintstatic[param1] = 0;
		}
	}
	else if (action == MenuAction_Cancel)
	{
		ClientAutoRefreshPanel[param1] = 0;
		hintstatic[param1] = 0;
	}
}


//Send the Panel to the Client
public Action:PrintTeamsToClient(client, args)
{
	if (plpAutoRefreshPanel == 1 && plpSelectTeam == 0)
	{
		wantedrefresh[client] = 1;
		ClientAutoRefreshPanel[client] = 1;
		if (plpHintStatic == 1)
		{
			hintstatic[client] = 1;
			CreateTimer(3.0, HintStaticTimer, client, TIMER_REPEAT);
		}
		CreateTimer(1.0, RefreshPanel, client, TIMER_REPEAT);
	}
	if (plpAutoRefreshPanel == 0)	
	{
		wantedrefresh[client] = 0;
		plpTimer = GetConVarInt(cc_plpTimer);
		if (plpSelectTeam == 1)
		{
			if (IsValidPlayer(client)) PrintHintText(client, "%s", hintText);
		}
		if (plpSelectTeam == 0)
		{
			if (IsValidPlayer(client)) PrintHintText(client, "Press '0' \nTo close the Panel!");
		}
		BuildPrintPanel(client);
	}
	if (plpAutoRefreshPanel == 1 && plpSelectTeam == 1)
	{
		wantedrefresh[client] = 0;
		plpTimer = GetConVarInt(cc_plpTimer);
		if (plpSelectTeam == 1)
		{
			if (IsValidPlayer(client)) PrintHintText(client, "%s", hintText);
		}
		if (plpSelectTeam == 0)
		{
			if (IsValidPlayer(client)) PrintHintText(client, "Press '0' \nTo close the Panel!");
		}
		BuildPrintPanel(client);
	}
	return Plugin_Handled;
}


//Show Announcement for !teams Command
public Action:AnnounceCommand(Handle:timer)
{
	if (plpAnnounce >0)
	{
		for(new i=1; i<=32; i++)
		{
			if (IsValidPlayer(i) && GetClientTeam(i) == 1)
			{
				PrintHintText(i, "Say !teams to see a list of Players \nThen 2 for Survivor \nOr 3 for Infected");
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Dow we Show Panel On Connect? (on by default)
public Action:OnConnect(Handle:timer, any:client)
{
	if (plpOnConnect == 1 && ClientAutoRefreshPanel[client] == 1)
	{
		if (plpSelectTeam == 1)
		{
			hintstatic[client] = 0;
			plpTimer = GetConVarInt(cc_plpTimer);
		}
		else
		{
			plpTimer = 0;
		}
		CreateTimer(3.0, RefreshPanel, client, TIMER_REPEAT);
		if (plpSelectTeam == 0 && plpHintStatic == 1)
		{
			hintstatic[client] = 1;
			CreateTimer(4.0, HintStaticTimer, client, TIMER_REPEAT);
		}
		if (plpHintStatic == 0)
		{
			hintstatic[client] = 0;
			CreateTimer(4.0, HintStaticTimer, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if (plpOnConnect == 1 && ClientAutoRefreshPanel[client] == 0)
	{
		hintstatic[client] = 0;
		wantedrefresh[client] = 0;
		plpTimer = GetConVarInt(cc_plpTimer);
		if (plpSelectTeam == 1)
		{
			if (IsValidPlayer(client)) PrintHintText(client, "%s", hintText);
		}
		if (plpSelectTeam == 0)
		{
			if (IsValidPlayer(client)) PrintHintText(client, "Press '0' \nTo close the Panel!");
		}
		BuildPrintPanel(client);
	}
}


//HintStatic Timer
public Action:HintStaticTimer(Handle:Timer, any:client)
{
	if (hintstatic[client] == 1)
	{
		if (IsValidPlayer(client)) PrintHintText(client, "Press '0' \nTo close the Panel!");
	}
	return Plugin_Stop;
}

//Refreshing Panel Timer
public Action:RefreshPanel(Handle:Timer, any:client)
{
	if (ClientAutoRefreshPanel[client] == 1)
	{
		if (plpSelectTeam == 1)
		{
			plpTimer = GetConVarInt(cc_plpTimer);
		}
		else
		{
			plpTimer = 0;
		}
		BuildPrintPanel(client);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}


//Check if Player fresh connected
public OnClientPostAdminCheck(client)
{
	if (IsValidPlayer(client) && plpAutoRefreshPanel == 1)
	{
		ClientAutoRefreshPanel[client] = 1;
		wantedrefresh[client] = 1;
	}
	if (IsValidPlayer(client) && plpAutoRefreshPanel == 0)
	{
		ClientAutoRefreshPanel[client] = 0;
		wantedrefresh[client] = 0;
	}
	//Only show Playerlist Panel to "new" connected Players
	if (IsValidPlayer(client) && GetClientTime(client) <= 120)
	{
		CreateTimer(5.0, OnConnect, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}


//Client Disconnects
public OnClientDisconnect(client)
{
	if (IsValidPlayer(client))
	{
		ClientAutoRefreshPanel[client] = 0;
		wantedrefresh[client] = 0;
		hintstatic[client] = 0;
	}
}



//Cvar changed check
public ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ReadCvars();
}


//Re-Read Cvars
public ReadCvars()
{
	plpAutoRefreshPanel=GetConVarInt(cc_plpAutoRefreshPanel);
	plpHintStatic=GetConVarInt(cc_plpHintStatic);
	plpSelectTeam=GetConVarInt(cc_plpSelectTeam);
	plpSpectatorSelect=GetConVarInt(cc_plpSpectatorSelect);
	plpSurvivorSelect=GetConVarInt(cc_plpSurvivorSelect);
	plpInfectedSelect=GetConVarInt(cc_plpInfectedSelect);
	plpOnConnect=GetConVarInt(cc_plpOnConnect);
	plpPaSTimer=GetConVarInt(cc_plpPaSTimer);
	plpAnnounce=GetConVarInt(cc_plpAnnounce);
	plpPaShowscores=GetConVarInt(cc_plpPaShowscores);
	plpTimer=GetConVarInt(cc_plpTimer);
	plpShowBots=GetConVarInt(cc_plpShowBots);
	HintText();
}


//Show Playerlist Panel after Scoreboard
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3])
{
	//Check if its a valid player
	if (!IsValidPlayer(client)) return Plugin_Continue;
	if (plpPaShowscores == 1)
	{
		if (buttons & IN_SCORE)
		{
			wantedrefresh[client] = 0;
			ClientAutoRefreshPanel[client] = 0;
			plpTimer = plpPaSTimer;
			if (plpSelectTeam == 1)
			{
				if (IsValidPlayer(client)) PrintHintText(client, "%s", hintText);
			}
			if (plpSelectTeam == 0)
			{
				if (IsValidPlayer(client)) PrintHintText(client, "Press '0' \nTo close the Panel!");
			}
			if (IsValidPlayer(client))
			{
				BuildPrintPanel(client);
			}
		}
	}  
	return Plugin_Continue;
}  


//Check of Full Teams (copied, credits to L4DSwitchPlayers)
bool:IsTeamFull (team)
{
	// Spectator's team is never full :P
	if (team == 1)
		return false;
	
	new max;
	new count;
	new i;
	
	// we count the players in the survivor's team
	if (team == 2)
	{
		max = MAX_SURVIVORS;
		count = 0;
		for (i=1;i<=MaxClients;i++)
			if (IsValidPlayer(i) && GetClientTeam(i)==2)
				count++;
		}
	else if (team == 3) // we count the players in the infected's team
	{
		max = MAX_INFECTED;
		count = 0;
		for (i=1;i<=MaxClients;i++)
			if (IsValidPlayer(i) && GetClientTeam(i)==3)
				count++;
		}
	
	// If full ...
	if (count >= max)
		return true;
	else
	return false;
}


//Do switching of Client (copied and edited, credits to L4DSwitchPlayers)
PerformSwitch (client, team)
{
	if (!IsValidPlayer(client))
	{
		return;
	}
	
	// If teams are the same ...
	if (GetClientTeam(client) == team)
	{
		PrintToChat(client, "Hello? You are already on that team!");
		return;
	}
	
	// If we should check if teams are fulll ...
	// We check if target team is full...
	if (IsTeamFull(team))
	{
		if (team == 2)
		{
			PrintToChat(client, "The \x03Survivor\x01's team is already full.");
		}
		if (team == 3)
		{
			PrintToChat(client, "The \x03Infected\x01's team is already full.");
		}
		return;
	}
	
	// If player was on infected .... 
	if (GetClientTeam(client) == 3)
	{
		// ... and he wasn't a tank ...
		new String:iClass[100];
		GetClientModel(client, iClass, sizeof(iClass));
		if (StrContains(iClass, "hulk", false) == -1)
			ForcePlayerSuicide(client);	// we kill him
	}
	
	// If target is survivors .... we need to do a little trick ....
	if (team == 1 || team == 3)// We change it's team ...
	{
		ChangeClientTeam(client, team);
	}
	if (team == 2)
	{
		// first we switch to spectators ..
		ChangeClientTeam(client, 1); 
		
		// Search for an empty bot
		for (new bot=0;bot<=32;bot++)
		{
			if (bot && IsClientConnected(bot) && IsFakeClient(bot) && (GetClientTeam(bot) == 2))
			{
				// force player to spec humans
				SDKCall(fSHS, bot, client); 
		
				// force player to take over bot
				SDKCall(fTOB, client, true);
				return;
			}
		}	
	}
}


//Hint Text
public HintText()
{
	//Define text parts
	new String:specTextOn[] = "1 to join Spectator";
	new String:specTextOff[] = "Spec = !spectate";
	new String:survTextOn[] = "2 to join Survivor";
	new String:survTextOff[] = "Survivor = !jointeam2";
	new String:infTextOn[] = "3 to join Infected";
	new String:infTextOff[] = "Infected = !jointeam3";
	new String:secondLine[] = "\nPress '0' to just close the Panel!"
	
	//Check selectable switches and format text
	if (plpSpectatorSelect == 1 && plpSurvivorSelect == 1 && plpInfectedSelect == 1)
	{
		Format(hintText, 255, "%s | %s | %s%s", specTextOn, survTextOn, infTextOn, secondLine);
	}
	if (plpSpectatorSelect == 1 && plpSurvivorSelect == 0 && plpInfectedSelect == 0)
	{
		Format(hintText, 255, "%s | %s | %s%s", specTextOn, survTextOff, infTextOff, secondLine);
	}
	if (plpSpectatorSelect == 1 && plpSurvivorSelect == 1 && plpInfectedSelect == 0)
	{
		Format(hintText, 255, "%s | %s | %s%s", specTextOn, survTextOn, infTextOff, secondLine);
	}
	if (plpSpectatorSelect == 1 && plpSurvivorSelect == 0 && plpInfectedSelect == 1)
	{
		Format(hintText, 255, "%s | %s | %s%s", specTextOn, survTextOff, infTextOn, secondLine);
	}
	if (plpSpectatorSelect == 0 && plpSurvivorSelect == 1 && plpInfectedSelect == 1)
	{
		Format(hintText, 255, "%s | %s | %s%s", specTextOff, survTextOn, infTextOn, secondLine);
	}
	if (plpSpectatorSelect == 0 && plpSurvivorSelect == 1 && plpInfectedSelect == 0)
	{
		Format(hintText, 255, "%s | %s | %s%s", specTextOff, survTextOn, infTextOff, secondLine);
	}
	if (plpSpectatorSelect == 0 && plpSurvivorSelect == 0 && plpInfectedSelect == 1)
	{
		Format(hintText, sizeof(hintText), "%s | %s | %s %s", specTextOff, survTextOff, infTextOn, secondLine);
	}
}


//Event Map Start
public OnMapStart()
{
	if (plpAnnounce >= 1)
	{
		CreateTimer(15.0, AnnounceCommand, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}


//Is Valid Player
public IsValidPlayer(client)
{
	if (client == 0)
		return false;
	
	if (!IsClientConnected(client))
		return false;
	
	if (IsFakeClient(client))
		return false;
	
	if (!IsClientInGame(client))
		return false;
	
	return true;
}


//Count all Players
public CountAllHumanPlayers()
{
	new Count = 0;
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{
			Count++;
		}
	}
	return Count;
}


//Count Players Team
public CountPlayersTeam(int team)
{
	new Count = 0;
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == team)
		{
			Count++;
		}
	}
	return Count;
}
public CountPlayersTeamAlive(int team)
{
	new Count = 0;
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == team && IsPlayerAlive(i))
		{
			Count++;
		}
	}
	return Count;
}

void GetWeaponInfo(int client, char[] info, int length)
{
	static char buffer[32];
	
	int activeWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int primaryWep = GetPlayerWeaponSlot(client, L4D2WeaponSlot_Primary);
	int activeWepId = IdentifyWeapon(activeWep);
	int primaryWepId = IdentifyWeapon(primaryWep);
	
	// Let's begin with what player is holding,
	// but cares only pistols if holding secondary.
	switch (activeWepId)
	{
		case WEPID_PISTOL, WEPID_PISTOL_MAGNUM:
		{
			if (activeWepId == WEPID_PISTOL && !!GetEntProp(activeWep, Prop_Send, "m_isDualWielding"))
			{
				// Dual Pistols Scenario
				// Straight use the prefix since full name is a bit long.
				Format(buffer, sizeof(buffer), "DP");
			}
			else GetLongWeaponName(activeWepId, buffer, sizeof(buffer));
			
			FormatEx(info, length, "%s %i", buffer, GetWeaponClipAmmo(activeWep));
		}
		default:
		{
			GetLongWeaponName(primaryWepId, buffer, sizeof(buffer));
			FormatEx(info, length, "%s %i/%i", buffer, GetWeaponClipAmmo(primaryWep), GetWeaponExtraAmmo(client, primaryWepId));
		}
	}
	
	// Format our result info
	if (primaryWep == -1)
	{
		// In case with no primary,
		// show the melee full name.
		if (activeWepId == WEPID_MELEE || activeWepId == WEPID_CHAINSAW)
		{
			int meleeWepId = IdentifyMeleeWeapon(activeWep);
			GetLongMeleeWeaponName(meleeWepId, info, length);
		}
	}
	else
	{
		// Default display -> [Primary <In Detail> | Secondary <Prefix>]
		// Holding melee included in this way
		// i.e. [Chrome 8/56 | M]
		if (GetSlotFromWeaponId(activeWepId) != L4D2WeaponSlot_Secondary || activeWepId == WEPID_MELEE || activeWepId == WEPID_CHAINSAW)
		{
			GetMeleePrefix(client, buffer, sizeof(buffer));
			Format(info, length, "%s | %s", info, buffer);
		}

		// Secondary active -> [Secondary <In Detail> | Primary <Ammo Sum>]
		// i.e. [Deagle 8 | Mac 700]
		else
		{
			GetLongWeaponName(primaryWepId, buffer, sizeof(buffer));
			Format(info, length, "%s | %s %i", info, buffer, GetWeaponClipAmmo(primaryWep) + GetWeaponExtraAmmo(client, primaryWepId));
		}
	}
}

stock int GetWeaponExtraAmmo(int client, int wepid)
{
	static int ammoOffset;
	if (!ammoOffset) ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
	
	int offset;
	switch (wepid)
	{
		case WEPID_RIFLE, WEPID_RIFLE_AK47, WEPID_RIFLE_DESERT, WEPID_RIFLE_SG552:
			offset = ASSAULT_RIFLE_OFFSET_IAMMO
		case WEPID_SMG, WEPID_SMG_SILENCED:
			offset = SMG_OFFSET_IAMMO
		case WEPID_PUMPSHOTGUN, WEPID_SHOTGUN_CHROME:
			offset = PUMPSHOTGUN_OFFSET_IAMMO
		case WEPID_AUTOSHOTGUN, WEPID_SHOTGUN_SPAS:
			offset = AUTO_SHOTGUN_OFFSET_IAMMO
		case WEPID_HUNTING_RIFLE:
			offset = HUNTING_RIFLE_OFFSET_IAMMO
		case WEPID_SNIPER_MILITARY, WEPID_SNIPER_AWP, WEPID_SNIPER_SCOUT:
			offset = MILITARY_SNIPER_OFFSET_IAMMO
		case WEPID_GRENADE_LAUNCHER:
			offset = GRENADE_LAUNCHER_OFFSET_IAMMO
		default:
			return -1;
	}
	return GetEntData(client, ammoOffset + offset);
} 

stock int GetClientPinnedInfectedType(int client)
{
	if (!IsClientInGame(client)) { return -1; }
	else if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) { return L4D2Infected_Smoker; }
	else if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) { return L4D2Infected_Hunter; }
	else if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0 || GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) { return L4D2Infected_Charger; }
	else if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) { return L4D2Infected_Jockey; }
	return -1;
}

stock int GetWeaponClipAmmo(int weapon)
{
	return (weapon > 0 ? GetEntProp(weapon, Prop_Send, "m_iClip1") : -1);
}

void GetMeleePrefix(int client, char[] prefix, int length)
{
	int secondary = GetPlayerWeaponSlot(client, L4D2WeaponSlot_Secondary);
	if (secondary == -1)
		return;
	
	static char buf[4];
	switch (IdentifyWeapon(secondary))
	{
		case WEPID_NONE: buf = "N";
		case WEPID_PISTOL: buf = (GetEntProp(secondary, Prop_Send, "m_isDualWielding") ? "DP" : "P");
		case WEPID_PISTOL_MAGNUM: buf = "DE";
		case WEPID_MELEE: buf = "M";
		default: buf = "?";
	}

	strcopy(prefix, length, buf);
}
//End of Plugin
