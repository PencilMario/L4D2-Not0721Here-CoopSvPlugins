#define PLUGIN_NAME "[L4D2] Consistent Client-sided Survivor Ragdolls"
#define PLUGIN_AUTHOR "Shadowysn"
#define PLUGIN_DESC "Enable survivor ragdolls on all deaths!"
#define PLUGIN_VERSION "1.1.5"
#define PLUGIN_URL "https://forums.alliedmods.net/showthread.php?p=2673001"
#define PLUGIN_NAME_SHORT "Consistent Client-sided Survivor Ragdolls"
#define PLUGIN_NAME_TECH "c_survivor_ragdoll"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>

#pragma newdecls required
#pragma semicolon 1

//#define EF_NODRAW 32
#define SECONDARY_SLOT 1

bool g_bEnabled, g_bRagdollLimit, g_bDropDual, g_bLedgeEnabled;
int g_iRemoveBody;
bool g_bIsSequel = false;

//bool g_bFalling[MAXPLAYERS+1];
bool g_bHasDual[MAXPLAYERS+1];

bool g_bLateLoad = false;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLateLoad = late;
	if (GetEngineVersion() == Engine_Left4Dead2)
	{
		g_bIsSequel = true;
		return APLRes_Success;
	}
	else if (GetEngineVersion() == Engine_Left4Dead)
	{ return APLRes_Success; }
	strcopy(error, err_max, "Plugin only supports Left 4 Dead and Left 4 Dead 2.");
	return APLRes_SilentFailure;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

TopMenu hTopMenu;

public void OnPluginStart()
{
	ConVar hTempCvar = CreateConVar("sm_custom_survivor_ragdoll_ver", PLUGIN_VERSION, PLUGIN_NAME_SHORT..." version.", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	if (hTempCvar != null)
		hTempCvar.SetString(PLUGIN_VERSION);
	
	if (g_bIsSequel)
	{
		hTempCvar = CreateConVar("sm_custom_survivor_ragdoll", "1", "Toggle usage of non-ledge based ragdoll deaths.", FCVAR_NONE, true, 0.0, true, 1.0);
		hTempCvar.AddChangeHook(CC_CSR_Enabled);
		g_bEnabled = hTempCvar.BoolValue;
		
		hTempCvar = CreateConVar("sm_"...PLUGIN_NAME_TECH..."_staticbody", "0", "0 - Make static body invisible. 1 - Remove static body. 2 - Do nothing. 3 - Make static body transparent.", FCVAR_NONE, true, 0.0, true, 3.0);
		hTempCvar.AddChangeHook(CC_CSR_RemoveBody);
		g_iRemoveBody = hTempCvar.IntValue;
		
		hTempCvar = CreateConVar("sm_"...PLUGIN_NAME_TECH..."_nolimit", "0", "0 - Use game's preferred ragdoll limits. 1 - Use CI ragdoll limits. (Beware - this could wreak havoc on older computers!)", FCVAR_NONE, true, 0.0, true, 1.0);
		hTempCvar.AddChangeHook(CC_CSR_RagdollLimit);
		g_bRagdollLimit = hTempCvar.BoolValue;
		
		hTempCvar = CreateConVar("sm_"...PLUGIN_NAME_TECH..."_dual_drop", "0", "Toggle whether players should drop their extra pistol upon death.", FCVAR_NONE, true, 0.0, true, 1.0);
		hTempCvar.AddChangeHook(CC_CSR_DropDual);
		g_bDropDual = hTempCvar.BoolValue;
		
		hTempCvar = CreateConVar("sm_"...PLUGIN_NAME_TECH..."_ledge", "1", "Toggle preventing ledge deaths from making victims unrevivable.", FCVAR_NONE, true, 0.0, true, 1.0);
		hTempCvar.AddChangeHook(CC_CSR_LedgeEnabled);
		g_bLedgeEnabled = hTempCvar.BoolValue;
		
		HookEvent("player_spawn", player_use, EventHookMode_Pre);
		HookEvent("player_death", player_death, EventHookMode_Pre);
		//HookEvent("player_death", player_death_pre, EventHookMode_Pre);
		HookEvent("player_hurt", player_hurt_pre, EventHookMode_Pre);
		//HookEvent("player_ledge_release", player_ledge_release, EventHookMode_Post);
		//HookEvent("player_ledge_grab", player_ledge_grab, EventHookMode_Post);
		HookEvent("player_use", player_use, EventHookMode_Post);
		
		if (g_bLateLoad)
		{
			for (int i = 1; i < MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsSurvivor(i)) continue;
				
				int pistol = GetPlayerWeaponSlot(i, SECONDARY_SLOT);
				if (pistol == -1) continue;
				
				char strClassname[15];
				GetEntityClassname(pistol, strClassname, sizeof(strClassname));
				if (strcmp(strClassname, "weapon_pistol") != 0) continue;
				
				int isDual = 0;
				if (HasEntProp(pistol, Prop_Send, "m_isDualWielding"))
				{ isDual = GetEntProp(pistol, Prop_Send, "m_isDualWielding"); }
				
				if (isDual > 0)
				{ g_bHasDual[i] = true; }
				else if (isDual <= 0 && g_bHasDual[i])
				{ g_bHasDual[i] = false; }
			}
		}
	}
	
	delete hTempCvar;
	
	RegAdminCmd("sm_ragdoll", Command_Ragdoll, ADMFLAG_CHEATS, "Spawn a client ragdoll on yourself.");
	//RegAdminCmd("sm_testrag_ply", Command_RagdollPly, ADMFLAG_CHEATS, "Ragdoll Test on Players");
	
	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}
	AutoExecConfig(true);
}

void CC_CSR_Enabled(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_bEnabled =		convar.BoolValue; }
void CC_CSR_RemoveBody(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_iRemoveBody =		convar.IntValue; }
void CC_CSR_RagdollLimit(ConVar convar, const char[] oldValue, const char[] newValue)	{ g_bRagdollLimit =	convar.BoolValue; }
void CC_CSR_DropDual(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_bDropDual =		convar.BoolValue; }
void CC_CSR_LedgeEnabled(ConVar convar, const char[] oldValue, const char[] newValue)	{ g_bLedgeEnabled =	convar.BoolValue; }

void CreateRagdoll(int client)
{
	int Ragdoll = CreateEntityByName("cs_ragdoll");
	float fPos[3], fAng[3];
	GetClientAbsOrigin(client, fPos); GetClientAbsAngles(client, fAng);
	
	TeleportEntity(Ragdoll, fPos, fAng, NULL_VECTOR);
	
	SetEntPropVector(Ragdoll, Prop_Send, "m_vecRagdollOrigin", fPos);
	SetEntProp(Ragdoll, Prop_Send, "m_nModelIndex", GetEntProp(client, Prop_Send, "m_nModelIndex"));
	SetEntProp(Ragdoll, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntPropEnt(Ragdoll, Prop_Send, "m_hPlayer", client);
	SetEntProp(Ragdoll, Prop_Send, "m_iDeathPose", GetEntProp(client, Prop_Send, "m_nSequence"));
	SetEntProp(Ragdoll, Prop_Send, "m_iDeathFrame", GetEntProp(client, Prop_Send, "m_flAnimTime"));
	SetEntProp(Ragdoll, Prop_Send, "m_nForceBone", GetEntProp(client, Prop_Send, "m_nForceBone"));
	float velfloat[3];
	if (g_bIsSequel)
	{
		velfloat[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]")*30;
		velfloat[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]")*30;
		velfloat[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]")*30;
	}
	else
	{
		velfloat[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		velfloat[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		velfloat[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	}
	SetEntPropVector(Ragdoll, Prop_Send, "m_vecForce", velfloat);
	
	if (IsSurvivor(client))
	{
		if (!g_bRagdollLimit)
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 4); }
		else
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 1); }
		SetEntProp(Ragdoll, Prop_Send, "m_survivorCharacter", GetEntProp(client, Prop_Send, "m_survivorCharacter"));
	}
	else if (GetClientTeam(client) == 3)
	{
		int infclass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (g_bRagdollLimit)
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 1); }
		else if (infclass == 8)
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 3); }
		else
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 2); }
		SetEntProp(Ragdoll, Prop_Send, "m_zombieClass", infclass);
		
		int effect = GetEntPropEnt(client, Prop_Send, "m_hEffectEntity");
		if (effect != -1)
		{
			char effectclass[13]; 
			GetEntityClassname(effect, effectclass, sizeof(effectclass));
			if (strcmp(effectclass, "entityflame", false) == 0)
			{ SetEntProp(Ragdoll, Prop_Send, "m_bOnFire", 1); }
		}
	}
	else
	{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 1); }
	
	int prev_ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsPlayerAlive(client) && prev_ragdoll == -1)
	{
		//SetEntProp(client, Prop_Send, "m_bClientSideRagdoll", 1);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", Ragdoll);
	}
	else
	{
		//CreateTimer(1.5, Timer_RemoveInvis, client, TIMER_FLAG_NO_MAPCHANGE);
		//int EFlags = GetEntProp(client, Prop_Send, "m_fEffects");
		//EFlags &= EF_NODRAW;
		//SetEntProp(client, Prop_Send, "m_fEffects", EFlags);
		SetVariantString("OnUser1 !self:Kill::1.0:-1");
		AcceptEntityInput(Ragdoll, "AddOutput");
		AcceptEntityInput(Ragdoll, "FireUser1");
	}
	
	DispatchSpawn(Ragdoll);
	ActivateEntity(Ragdoll);
}

Action Command_Ragdoll(int client, any args)
{
	if (!IsClientInGame(client))
	{
		ReplyToCommand(client, "[SM] You are not in-game!");
		return Plugin_Handled;
	}
	if (!IsSurvivor(client) && GetClientTeam(client) != 3)
	{
		ReplyToCommand(client, "[SM] You are not on a valid team!");
		return Plugin_Handled;
	}
	
	CreateRagdoll(client);
	return Plugin_Handled;
}

/*Action Command_RagdollPly(int client, any args)
{
	if (args < 1 || args > 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_testrag_ply <player> - test a ragdoll");
		return Plugin_Handled;
	}
	char plyent[64];
	GetCmdArg(1, plyent, sizeof(plyent));
	
	int player = FindTarget(client, plyent);
	
	if ( player == -1 )
	{
		ReplyToCommand(client, "[SM] There is no player!");
		return Plugin_Handled;
	}
	if ( !IsClientInGame(player) )
	{
		ReplyToCommand(client, "[SM] They are not in-game!");
		return Plugin_Handled;
	}
	if (!IsSurvivor(player) && GetClientTeam(player) != 3)
	{
		ReplyToCommand(client, "[SM] They are not on a valid team!");
		return Plugin_Handled;
	}
	
	CreateRagdoll(client);
	return Plugin_Handled;
}*/

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bIsSequel || !g_bEnabled)
		return;
	
	if (classname[0] != 's' )
		return;
	
	if (strcmp(classname, "survivor_death_model", false) == 0)
		SDKHook(entity, SDKHook_SpawnPost, SpawnPostDeathModel);
}

void SpawnPostDeathModel(int entity)
{
	if (!IsValidEntity(entity)) return;
	SDKUnhook(entity, SDKHook_SpawnPost, SpawnPostDeathModel);
	
	switch (g_iRemoveBody)
	{
		case 0:
		{ SetEntityRenderMode(entity, RENDER_NONE); }
		case 1:
		{ AcceptEntityInput(entity, "Kill"); }
		case 3:
		{ SetEntityRenderMode(entity, RENDER_TRANSCOLOR); DispatchKeyValue(entity, "renderamt", "127"); }
	}
}

/*void player_death_pre(Event event, const char[] name, bool dontbroadcast)
{ // It's too late to drop the weapon, as it's already been removed.
	int userID = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userID);
	if (!IsValidClient(client))
	return;
	
	if (!IsSurvivor(client))
	return;
	
	if (GetConVarBool(DropSecondary))
	{
		int weapon = GetPlayerWeaponSlot(client, 1); // 1 = Secondary
		if (IsValidEntity(weapon))
		{ SDKHooks_DropWeapon(client, weapon); }
	}
}*/

void player_death(Event event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client == 0 || IsPlayerAlive(client)) return;
	
	//if (g_bFalling[client])
	//{ g_bFalling[client] = false; }
	
	if (!g_bIsSequel) return;
	
	TestForDual(client);
	
	if (!g_bEnabled) return;
	if (!IsSurvivor(client) || GetEntPropEnt(client, Prop_Send, "m_hRagdoll") != -1) return;
	
	CreateRagdoll(client);
}

void player_use(Event event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client == 0 || !IsPlayerAlive(client)) return;
	
	if (!g_bIsSequel || !IsSurvivor(client)) return;
	
	/*int target = EntIndexToEntRef(GetEventInt(event, "targetid"));
	char temp_str[128];
	GetEntityClassname(target, temp_str, sizeof(temp_str));
	if (StrContains(temp_str, "pistol") < 0) return;*/
	
	int pistol = GetPlayerWeaponSlot(client, SECONDARY_SLOT);
	if (pistol == -1) return;
	//GetEntityClassname(pistol, temp_str, sizeof(temp_str));
	//if (!StrEqual(temp_str, "weapon_pistol")) return;
	
	int isDual = 0;
	if (HasEntProp(pistol, Prop_Send, "m_isDualWielding"))
	{ isDual = GetEntProp(pistol, Prop_Send, "m_isDualWielding"); }
	//PrintToChatAll("%i", isDual);
	
	if (isDual > 0 && !g_bHasDual[client])
	{ g_bHasDual[client] = true; }
	else if (isDual <= 0 && g_bHasDual[client])
	{ g_bHasDual[client] = false; }
}

void TestForDual(int client)
{
	//PrintToChatAll("%i", g_bHasDual[client]);
	if (!g_bHasDual[client] || !g_bDropDual) return;
	
	g_bHasDual[client] = false;
	
	float fPos[3];
	float fAng[3];
	GetClientEyePosition(client, fPos);
	GetClientAbsAngles(client, fAng);
	
	float velfloat[3]; // Doesn't work
	velfloat[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]")*30;
	velfloat[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]")*30;
	velfloat[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]")*30;
	
	int drop = CreateEntityByName("weapon_pistol_spawn");
	TeleportEntity(drop, fPos, fAng, velfloat);
	DispatchKeyValue(drop, "count", "1");
	DispatchKeyValue(drop, "solid", "6");
	DispatchKeyValue(drop, "spawnflags", "3");
	
	DispatchSpawn(drop);
	ActivateEntity(drop);
}

void player_hurt_pre(Event event, const char[] name, bool dontbroadcast)
{
	if (!g_bIsSequel || !g_bLedgeEnabled) return;
	
	//PrintToChatAll("LedgeRelease");
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client == 0) return;
	
	//PrintToChatAll("%i", client);
	
	int health = GetEventInt(event, "health");
	if (health > 0) return;
	
	if (GetEntProp(client, Prop_Send, "m_isFallingFromLedge") > 0)
	{ SetEntProp(client, Prop_Send, "m_isFallingFromLedge", 0); }
}

// Below code is for the Menu.
public void AdminMenu_RagdollTest(TopMenu topmenu, 
					  TopMenuAction action,
					  TopMenuObject object_id,
					  int param,
					  char[] buffer,
					  int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Spawn ragdoll on", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		TestRagdollMenu(param);
	}
}

void TestRagdollMenu(int client)
{
	Handle menu = CreateMenu(MenuHandler_TestRagdoll);
	
	char title[24];
	Format(title, sizeof(title), "Spawn ragdoll on:", client);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	AddTargetsToMenu(menu, client, true, false);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_TestRagdoll(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);
		
		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(client, "[SM] Player no longer available");
		}
		else if (!CanUserTarget(client, target))
		{
			PrintToChat(client, "[SM] Unable to target");
		}
		else
		{
			CreateRagdoll(target);
		}
		
		if (IsClientInGame(client) && !IsClientInKickQueue(client))
		{
			TestRagdollMenu(client);
		}
	}
	return 0;
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	// Block us from being called twice
	if (topmenu == hTopMenu)
	{ return; }
	
	hTopMenu = topmenu;
	
	if (topmenu == null)
	{ return; }
	
	TopMenuObject player_commands = FindTopMenuCategory(topmenu, ADMINMENU_PLAYERCOMMANDS);

	if (player_commands != INVALID_TOPMENUOBJECT)
	{
		AddToTopMenu(topmenu, "sm_testragmenu", TopMenuObject_Item, AdminMenu_RagdollTest, player_commands, "sm_testragmenu", ADMFLAG_CHEATS);
	}
}

stock bool IsSurvivor(int client)
{ int team = GetClientTeam(client); return (team == 2 || team == 4); }

/*stock bool IsValidClient(int client, bool replaycheck = true, bool isLoop = false)
{
	if ((isLoop || client > 0 && client <= MaxClients) && IsClientInGame(client))
	{
		if (HasEntProp(client, Prop_Send, "m_bIsCoaching")) // TF2, CSGO?
			if (view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsCoaching"))) return false;
		if (replaycheck)
		{
			if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
		}
		return true;
	}
	return false;
}*/