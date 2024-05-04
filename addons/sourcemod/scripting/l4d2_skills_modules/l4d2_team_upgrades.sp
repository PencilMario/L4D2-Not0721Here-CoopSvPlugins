#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#include <l4d2_skills>
#include <left4dhooks>

#define MY_EXPORT_NAME "团队升级"

#define MAX_UPGRADES 12
#define UPGRADE_NAME_LENGTH 64

public Plugin myinfo =
{
	name = "[L4D2] Team Upgrades",
	author = "BHaType",
	description = "Adds team upgrades to skills menu",
	version = "1.1",
	url = "https://github.com/Vinillia/l4d2_skills"
};

typedef UpgradeAction = function bool(int buyer); 

enum struct SettingsManager
{
	StringMap settings;
	
	void SetValue(const char[] key, any value)
	{
		this.settings.SetValue(key, value);
	}
	
	any GetValue(const char[] key, any defaultValue = 0)
	{
		any value;
		
		if (!this.settings.GetValue(key, value))
			return defaultValue;
		
		return value;
	}

	void ExportInt(KeyValues kv, const char[] key, int defaultValue = 0)
	{
		int value;
		EXPORT_INT_DEFAULT(key, value, defaultValue);
		this.SetValue(key, value);
	}

	void ExportFloat(KeyValues kv, const char[] key, float defaultValue = 0.0)
	{
		float value;		
		EXPORT_FLOAT_DEFAULT(key, value, defaultValue);
		this.SetValue(key, value);
	}
}

enum struct TeamUpgrade
{
	char name[UPGRADE_NAME_LENGTH];
	float cost;

	UpgradeAction action;
}

TeamUpgrade g_TeamUpgrades[MAX_UPGRADES];
int g_iUpgradesCount;

SettingsManager g_SettingsManager;
ConVar survivor_crouch_speed;
float survivor_crouch_speed_default;
bool g_bAirdropAvailable;
bool g_bLateLoad;

native bool CreateAirdrop( const float vOrigin[3], const float vAngles[3], int initiator = 0, bool trace_to_sky = true );

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("CreateAirdrop");
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_SettingsManager.settings = new StringMap();
	
	survivor_crouch_speed = FindConVar("survivor_crouch_speed");
	survivor_crouch_speed_default = survivor_crouch_speed.FloatValue;

	RegAdminCmd("sm_teamupgrades_invoke", sm_teamupgrades_invoke, ADMFLAG_CHEATS);
}

public void OnAllPluginsLoaded()
{
	g_bAirdropAvailable = GetFeatureStatus(FeatureType_Native, "CreateAirdrop") == FeatureStatus_Available;

	Skills_AddMenuItem("skills_team_upgrades", "团队强化", ItemMenuCallback);
	
	Skills_RequestConfigReload();
}

public void OnPluginEnd()
{
	survivor_crouch_speed.FloatValue = survivor_crouch_speed_default;
}

public Action sm_teamupgrades_invoke( int client, int args )
{
	char name[UPGRADE_NAME_LENGTH];
	GetCmdArg(1, name, sizeof name);

	for(int i; i < g_iUpgradesCount; i++)
	{
		if (StrContains(g_TeamUpgrades[i].name, name, false) != -1)
		{
			InvokeUpgradeAction(i, client);
			return Plugin_Handled;
		}
	}

	Skills_ReplyToCommand(client, "Failed to find upgrade %s", name);
	return Plugin_Handled;
}

public void ItemMenuCallback( int client, const char[] item )
{
	ShowClientShop(client);
}

void ShowClientShop( int client, int selection = 0 )
{
	Menu menu = new Menu(VMenuHandler);
	char buffer[64], temp[4];

	for(int i; i < g_iUpgradesCount; i++)
	{
		IntToString(i, temp, sizeof temp);
		Format(buffer, sizeof buffer, "%s - %.0f", g_TeamUpgrades[i].name, g_TeamUpgrades[i].cost);
		menu.AddItem(temp, buffer);
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.SetTitle("Skills: 团队加成");
	menu.DisplayAt(client, selection, MENU_TIME_FOREVER);
}

public int VMenuHandler( Menu menu, MenuAction action, int client, int index )
{
	switch( action )
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if( index == MenuCancel_ExitBack || index == MenuCancel_NoDisplay )
				FakeClientCommand(client, "sm_skills");
		}
		case MenuAction_Select:
		{	
			ShowClientShop(client, menu.Selection);

			float money, cost;
			int upgradeID;
			char item[8];

			menu.GetItem(index, item, sizeof item);
			upgradeID = StringToInt(item);
			money = Skills_GetTeamMoney(); 
			cost = g_TeamUpgrades[upgradeID].cost;

			if (money - cost < 0)
			{
				Skills_PrintToChat(client, "\x03没有足够的 \x04团队\x5积分");
				return 0;
			}

			if (!InvokeUpgradeAction(upgradeID, client))
			{
				Skills_PrintToChat(client, "\x04升级 \x03%s \x04正在\x05使用中", g_TeamUpgrades[upgradeID].name);
				return 0;
			}

			Skills_SetTeamMoney(money - cost);
			Skills_PrintToChatAll("\x05%N \x04买了 \x03%s \x04团队升级", client, g_TeamUpgrades[upgradeID].name);
		}
	}
	
	return 0;
}

public void Skills_OnGetSettings( KeyValues kv )
{
	EXPORT_START(MY_EXPORT_NAME);

	EXPORT_SECTION_START("基础生命")
	{
		g_SettingsManager.ExportInt(kv, "more_health_add", 15);
		RegisterUpgrade(kv, "基础生命", OnHealthUpgrade);
		EXPORT_SECTION_END();
	}

	EXPORT_SECTION_START("提高蹲下移速")
	{
		g_SettingsManager.ExportFloat(kv, "crouch_speed", 300.0);
		g_SettingsManager.ExportFloat(kv, "crouch_duration", 120.0);
		RegisterUpgrade(kv, "提高蹲下移速", OnCrouchUpgrade);
		EXPORT_SECTION_END();
	}

	EXPORT_SECTION_START("全队肾上腺素")
	{
		g_SettingsManager.ExportFloat(kv, "adrenaline_team_duration", 30.0);
		g_SettingsManager.ExportInt(kv, "adrenaline_team_heal", 1);
		RegisterUpgrade(kv, "全队肾上腺素", OnAdrenalineTeam);
		EXPORT_SECTION_END();
	}

	if (g_bAirdropAvailable)
	{
		EXPORT_SECTION_START("呼叫空投")
		{
			RegisterUpgrade(kv, "呼叫空投", OnAirdrop);
			EXPORT_SECTION_END();
		}
	}

	EXPORT_FINISH();
}

bool RegisterUpgrade(KeyValues kv, const char[] name, UpgradeAction action)
{
	if (g_iUpgradesCount == MAX_UPGRADES)
	{
		ERROR("Reached limit of upgrades %i/%i", g_iUpgradesCount, MAX_UPGRADES);
		return false;
	}
	
	int i = g_iUpgradesCount++;
	
	strcopy(g_TeamUpgrades[i].name, UPGRADE_NAME_LENGTH, name);
	g_TeamUpgrades[i].action = action;

	EXPORT_FLOAT_DEFAULT("cost", g_TeamUpgrades[i].cost, 5000.0);
	return true;
}

bool InvokeUpgradeAction(int upgradeID, int buyer)
{
	bool pass;

	Call_StartFunction(null, g_TeamUpgrades[upgradeID].action);
	Call_PushCell(buyer);
	Call_Finish(pass);

	return pass;
}

public bool OnCrouchUpgrade(int buyer)
{
	float duration = g_SettingsManager.GetValue("crouch_duration");
	float newSpeed = g_SettingsManager.GetValue("crouch_speed");

	if (survivor_crouch_speed_default == newSpeed)
		return false;

	CreateTimer(duration, timer_reset_crouch_speed);
	survivor_crouch_speed.FloatValue = newSpeed;
	return true;
}

public bool OnAirdrop(int buyer)
{
	float vOrigin[3], vAngles[3];

	GetClientEyePosition(buyer, vOrigin);
	GetClientEyeAngles(buyer, vAngles);

	CreateAirdrop(vOrigin, vAngles);
	return true;
}

public bool OnHealthUpgrade(int buyer)
{
	Skills_ForEveryClient(SFF_CLIENTS | SFF_ALIVE, UpgradeClientHealth);
	return true;
}

public bool OnAdrenalineTeam(int buyer)
{
	Skills_ForEveryClient(SFF_CLIENTS | SFF_ALIVE, UseClientAdrenaline);	
	return true;
}

bool UpgradeClientHealth(int cl)
{
	int add = g_SettingsManager.GetValue("more_health_add");	
	int newValue = GetEntProp(cl, Prop_Send, "m_iMaxHealth");
	SetEntProp(cl, Prop_Send, "m_iMaxHealth", newValue + add);
	return true;
}

bool UseClientAdrenaline(int cl)
{	
	float duration = g_SettingsManager.GetValue("adrenaline_team_duration");
	bool heal = g_SettingsManager.GetValue("adrenaline_team_heal");
	L4D2_UseAdrenaline(cl, duration, heal);
	return true;
}

public Action timer_reset_crouch_speed(Handle timer)
{
	Skills_PrintToChatAll("\x03提高蹲下移速 \x04效果加成\x05已结束");
	survivor_crouch_speed.FloatValue = survivor_crouch_speed_default;
	return Plugin_Continue;
}