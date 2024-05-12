/*
*	Extra Menu API - Test Plugin
*	Copyright (C) 2022 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



#define PLUGIN_VERSION 		"1.4"

/*======================================================================================
	Plugin Info:

*	Name	:	[ANY] Extra Menu API - Test Plugin
*	Author	:	SilverShot
*	Descrp	:	Allows plugins to create menus with more than 1-7 selectable entries and more functionality.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=338863
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.4 (15-Oct-2022)
	- Added the alternative buttons demonstration to the "ExtraMenu_Create" native.

1.2 (15-Aug-2022)
	- Added a "meter" options demonstration.

1.0 (30-Jul-2022)
	- Initial release.

======================================================================================*/


#include <sourcemod>
#include <extra_menu>
#include <logger>
#pragma semicolon 1
#pragma newdecls required


int g_iMenuID;
ExtraMenu g_Extramenu;
Logger log;

int g_RemoveLobby,g_nbUpdate,g_byPassSteam, g_Auto, g_Snum, g_Stime, g_SDPSlim, g_STP,
    g_Relax, g_RelaxFast, g_Fixm4,
    g_FF, g_MultiAmmo, g_MultiMed, g_TP, g_KB, g_Healsys, g_weaponrule, g_killback = -1;


// ====================================================================================================
//					PLUGIN INFO
// ====================================================================================================
public Plugin myinfo =
{
	name = "[ANY] Extra Menu API - Test Plugin",
	author = "SilverShot",
	description = "Allows plugins to create menus with more than 1-7 selectable entries and more functionality.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=338863"
}



// ====================================================================================================
//					MAIN FUNCTIONS
// ====================================================================================================
public void OnPluginStart()
{
	log = new Logger("extra_test", LoggerType_NewLogFile);
	log.lograw("========================================");
	RegAdminCmd("sm_menutest", CmdMenuTest, ADMFLAG_ROOT);
	RegAdminCmd("sm_menutest2", CmdMenuTest2, ADMFLAG_ROOT);
}

public void OnAllPluginsLoaded(){
	if (LibraryExists("extra_menu")) OnLibraryAdded("extra_menu");
}
public void OnLibraryAdded(const char[] name)
{
	if( strcmp(name, "extra_menu") == 0 )
	{
		// Menu movement type: False = W/A/S/D. True = 1/3/4/5
		bool buttons_nums = true;
		// bool buttons_nums = false;

		// Create a new menu
		int menu_id;

		if( buttons_nums )
			menu_id = ExtraMenu_Create(false, "", buttons_nums); // No back button, no translation, 1/2/3/4 type selection menu
		else
			menu_id = ExtraMenu_Create(); // W/A/S/D type selection menu

		// Add the entries
		ExtraMenu_AddEntry(menu_id, "VARIOUS OPTIONS:",								MENU_ENTRY);
		if( !buttons_nums )
			ExtraMenu_AddEntry(menu_id, "Use W/S to move row and A/D to select",	MENU_ENTRY);
		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY); // Space to add blank entry
		ExtraMenu_AddEntry(menu_id, "1. God Mode: _OPT_",							MENU_SELECT_ONOFF);
		ExtraMenu_AddEntry(menu_id, "2. No Clip: _OPT_",							MENU_SELECT_ONOFF);
		ExtraMenu_AddEntry(menu_id, "3. Beam Ring: _OPT_",							MENU_SELECT_ONOFF);
		ExtraMenu_AddEntry(menu_id, "4. Player Speed: _OPT_",						MENU_SELECT_ADD, false, 250, 10, 100, 300);
		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY);
		ExtraMenu_AddEntry(menu_id, "VARIABLE OPTIONS:",							MENU_ENTRY);

		ExtraMenu_AddEntry(menu_id, "5. Difficulty: _OPT_",							MENU_SELECT_LIST);
		ExtraMenu_AddOptions(menu_id, "Easy|Normal|Hard|Expert");					// Various selectable options

		ExtraMenu_AddEntry(menu_id, "6. Test Opts: _OPT_",							MENU_SELECT_LIST);
		ExtraMenu_AddOptions(menu_id, "Tester");									// Various selectable options

		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY);
		ExtraMenu_AddEntry(menu_id, "INSTANT CMDS:",								MENU_ENTRY);
		ExtraMenu_AddEntry(menu_id, "7. Slay Self",									MENU_SELECT_ONLY);
		ExtraMenu_AddEntry(menu_id, "8. Default On: _OPT_",							MENU_SELECT_ONOFF, false, 1);
		ExtraMenu_AddEntry(menu_id, "9. Close After Use",							MENU_SELECT_ONLY, true);
		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY); // Space to add blank entry
		ExtraMenu_AddEntry(menu_id, "10. Meter: _OPT_",								MENU_SELECT_LIST);
		ExtraMenu_AddOptions(menu_id, "□□□□□□□□□□|■□□□□□□□□□|■■□□□□□□□□|■■■□□□□□□□|■■■■□□□□□□|■■■■■□□□□□|■■■■■■□□□□|■■■■■■■□□□|■■■■■■■■□□|■■■■■■■■■□|■■■■■■■■■■");	// Various selectable options
		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY); // Space to add blank entry

		ExtraMenu_NewPage(menu_id); // New Page

		ExtraMenu_AddEntry(menu_id, "SECOND PAGE OPTIONS:",							MENU_ENTRY);
		if( !buttons_nums )
			ExtraMenu_AddEntry(menu_id, "Use W/S to move row and A/D to select",	MENU_ENTRY);
		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY); // Space to add blank entry
		ExtraMenu_AddEntry(menu_id, "1. Test1: _OPT_",								MENU_SELECT_ONOFF);
		ExtraMenu_AddEntry(menu_id, "2. Test2: _OPT_",								MENU_SELECT_ONOFF);
		ExtraMenu_AddEntry(menu_id, "3. Test3: _OPT_",								MENU_SELECT_ONOFF);
		ExtraMenu_AddEntry(menu_id, " ",											MENU_ENTRY); // Space to add blank entry

		// Store your menu ID to use later
		g_iMenuID = menu_id;
		g_Extramenu = ExtraMenu(false, "", false);
    	g_Extramenu.AddEntry                         ("<服务器控制菜单 Page1>");
    	g_Extramenu.AddEntry                         ("使用W/S选择选项, A/D进行调整");
    	g_Extramenu.AddEntry                         ("  ");
    	g_Extramenu.AddEntry                         ("A. 服务器控制");
    	g_RemoveLobby = g_Extramenu.AddEntryOnly     ("1. 移除大厅匹配");
    	g_nbUpdate = g_Extramenu.AddEntryAdd         ("2. 小僵尸刷新率: 0.0_OPT_", false, GetConvarFloattoIntEx("nb_update_frequency", 1000.0), 5, 10, 100);
    	g_byPassSteam = g_Extramenu.AddEntrySwitch   ("3. 跳过steam验证", false, 0);
    	g_Extramenu.AddEntry                         ("  ");
    	g_Extramenu.AddEntry                         ("B. 多特控制");
    	g_Auto = g_Extramenu.AddEntrySwitch          ("1. 自动调节刷特: _OPT_", false, GetConvarIntEx("sm_ss_automode"));
    	g_Snum = g_Extramenu.AddEntryAdd             ("2. 特感刷新数量: 最高同屏_OPT_只", false, GetConvarIntEx("sss_1P"), 1, 0, 28);
    	g_Stime = g_Extramenu.AddEntryAdd            ("3. 特感刷新时间: 每个Slot_OPT_s", false, GetConvarIntEx("SS_Time"), 5, 0, 80);
    	g_SDPSlim = g_Extramenu.AddEntryAdd          ("4. DPS特感最大数: _OPT_只", false, GetConvarIntEx("SS_DPSSiLimit"), 1, 0, 28);
    	g_STP = g_Extramenu.AddEntrySwitch           ("5. 不可见特感自动传送 _OPT_", false, GetConvarIntEx("teleport_enable"));
    	g_Extramenu.AddEntry                         ("  ");
    	g_Extramenu.AddEntry                         ("C. 多特Relax阶段控制");
    	g_Relax = g_Extramenu.AddEntrySwitch         ("1. Relax阶段 _OPT_", false, GetConvarIntEx("SS_Relax"));
    	g_RelaxFast = g_Extramenu.AddEntrySelect     ("2. 快速补特： _OPT_", "关闭|特感类CD锁定1s|特感类CD锁定1s*踢出死亡特感");
    	g_Fixm4 = g_Extramenu.AddEntrySwitch         ("3. 绝境不停刷修复 _OPT_", false, GetConvarIntEx("sm_ss_fixm4spawn"));
    	g_Extramenu.NewPage();
	
    	g_Extramenu.AddEntry                         ("D. 舒适设置");
    	g_FF = g_Extramenu.AddEntrySwitch            ("1. 阻止友伤 _OPT_",false, GetConvarIntEx("nff_enable"));
    	g_MultiAmmo = g_Extramenu.AddEntryAdd        ("2. 设置备弹 *_OPT_", false, 1, 1, 1, 100);
    	g_MultiMed = g_Extramenu.AddEntryAdd         ("3. 设置医疗物品 *_OPT_", false, 1, 1, 100);
    	g_TP = g_Extramenu.AddEntryAdd               ("4. 传送全体生还至 ->_OPT_%", false, 0, 3, 0, 110);
    	g_KB = g_Extramenu.AddEntryOnly              ("5. 踢出Bot");
    	g_Healsys = g_Extramenu.AddEntrySwitch       ("6. 呼吸回血+击杀回血 _OPT_", false, GetConvarIntEx("automatic_healing_enable"));
    	g_weaponrule = g_Extramenu.AddEntrySelect    ("7. 调整武器配置强度 _OPT_", "v1|v2|v3");
    	g_killback = g_Extramenu.AddEntrySwitch      ("8. 特感血条和击杀反馈 _OPT_", false, GetConvarIntEx("l4d_infectedhp"));

		/*g_Extramenu = ExtraMenu(false, "", buttons_nums);
		g_Extramenu.AddEntry		("VARIOUS OPTIONS:");
		g_Extramenu.AddEntryText	(" ");
		log.info("菜单1God Mode index：%i", g_Extramenu.AddEntrySwitch	("1. God Mode: _OPT_"));
		g_Extramenu.AddEntrySwitch	("2. No Clip: _OPT_");
		g_Extramenu.AddEntrySwitch	("3. Beam Ring: _OPT_");
		g_Extramenu.AddEntryAdd		("4. Player Speed: _OPT_", 	false, 250, 10, 100, 400);
		g_Extramenu.AddEntryText	(" ");
		g_Extramenu.AddEntryText	("VARIABLE OPTIONS:");
		g_Extramenu.AddEntrySelect	("5. Difficulty: _OPT_", 	"Easy|Normal|Hard|Expert");
		g_Extramenu.AddEntrySelect	("6. Test Opts: _OPT_", 	"Tester");
		g_Extramenu.AddEntry		(" ");
		g_Extramenu.AddEntry		("INSTANT CMDS:");
		g_Extramenu.AddEntryOnly	("7. Slay Self");
		g_Extramenu.AddEntrySwitch	("8. Default On: _OPT_", false, 1);
		log.info("菜单9Close After Use index：%i", g_Extramenu.AddEntryOnly	("9. Close After Use", true));
		g_Extramenu.AddEntry		("	");
		g_Extramenu.AddEntrySelect	("10. Meter: _OPT_", "□□□□□□□□□□|■□□□□□□□□□|■■□□□□□□□□|■■■□□□□□□□|■■■■□□□□□□|■■■■■□□□□□|■■■■■■□□□□|■■■■■■■□□□|■■■■■■■■□□|■■■■■■■■■□|■■■■■■■■■■");
		g_Extramenu.NewPage();

		g_Extramenu.AddEntry		("SECOND PAGE OPTIONS:");
		g_Extramenu.AddEntry		(" ");
		g_Extramenu.AddEntrySwitch	("1. Test1: _OPT_");
		g_Extramenu.AddEntrySwitch	("2. Test2: _OPT_");
		g_Extramenu.AddEntrySwitch	("3. Test3: _OPT_");
		g_Extramenu.AddEntryAdd		("4. Test: _OPT_", 	false, 0, 0.01, 0.0, 1.0);

		g_Extramenu.AddEntry		(" ");*/
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if( strcmp(name, "extra_menu") == 0 )
	{
		OnPluginEnd();
	}
}

// Always clean up the menu when finished
public void OnPluginEnd()
{
	ExtraMenu_Delete(g_iMenuID);
	g_Extramenu.Close();
}

// Display menu
Action CmdMenuTest(int client, int args)
{
	ExtraMenu_Display(client, g_iMenuID, MENU_TIME_FOREVER);
	//g_Extramenu.Show(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
// Display menu
Action CmdMenuTest2(int client, int args)
{
	//ExtraMenu_Display(client, g_iMenuID, MENU_TIME_FOREVER);
	PrintToChatAll("CmdMenuTest2 - client:%i", client);
	g_Extramenu.Show(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public void ExtraMenu_OnSelect(int client, int menu_id, int option, int value){
    if (menu_id != g_Extramenu._index) return;
    if (option == g_RemoveLobby) {
        ServerCommand("sm_unreserve;sm_cvar sv_force_unreserved 1; sm_cvar sv_tags hidden; sm_cvar sv_steamgroup 0");
    }
    else if (option == g_nbUpdate) {
        ServerCommand("sm_cvar nb_update_frequency %.2f", float(value) / 1000.0);
    }
    else if (option == g_byPassSteam) {
        ServerCommand("sm_cvar sv_steam_bypass %i", value);
    }
    else if (option == g_Auto) {
        ServerCommand("sm_cvar sm_ss_automode %i", value);
    }
    else if (option == g_Snum) {
        ServerCommand("sm_SetAiSpawns %i", value);
    }
    else if (option == g_Stime) {
        ServerCommand("sm_SetAiTime %i", value);
    }
    else if (option == g_SDPSlim) {
        ServerCommand("sm_cvar SS_DPSSiLimit %i", value);
    }
    else if (option == g_STP) {
        ServerCommand("sm_cvar teleport_enable %i", value);
    }
    else if (option == g_Relax) {
        ServerCommand("sm_cvar SS_Relax %i; sm_reloadscript");
    }
    else if (option == g_RelaxFast) {
        ServerCommand("sm_cvar SS_FastRespawn %i; sm_reloadscript");
    }
    else if (option == g_Fixm4) {
        ServerCommand("sm_cvar sm_ss_fixm4spawn %i", value);
    }
    else if (option == g_FF) {
        ServerCommand("sm_cvar nff_enable %i", value);
    }
    else if (option == g_MultiAmmo) {
        ServerCommand("sm_setammomulti %i", value);
    }
    else if (option == g_MultiMed) {
        ServerCommand("sm_mmn %i; sm_mmy %i", value, value);
    }
    else if (option == g_TP) {
        ServerCommand("sm_warptoper %.2f", float(value) / 100.0);
    }
    else if (option == g_KB) {
        ServerCommand("sm_kickbot");
    }
    else if (option == g_Healsys) {
        ServerCommand("sm_cvar automatic_healing_enable %i; sm_cvar sm_killheal_enable %i", value, value);
    }
    else if (option == g_weaponrule) {
        if (value == 0) {
            ServerCommand("exec cfgogl\\coop_base\\weapon_improve_v1.cfg");
        }
        else if (value == 1) {
            ServerCommand("exec cfgogl\\coop_base\\weapon_improve_v1.cfg");
        }
        else if (value == 2) {
            ServerCommand("exec cfgogl\\coop_base\\weapon_improve_v1.cfg");
        }
    }
    else if (option == g_killback) {
        ServerCommand("sm_cvar sound_enable %i;l4d_infectedhp %i;", value, value);
    }    
}


int GetConvarIntEx(char[] cvar){
    ConVar c = FindConVar(cvar);
    if (c != null){
        return c.IntValue;
    }else{
        return -1;
    }
}

int GetConvarFloattoIntEx(char[] cvar, float multi){
    ConVar c = FindConVar(cvar);
    if (c != null){
        return RoundToCeil(c.FloatValue * multi);
    }else{
        return -1;
    }
}


