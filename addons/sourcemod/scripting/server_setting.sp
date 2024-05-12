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
#pragma semicolon 1
#pragma newdecls required


ExtraMenu g_Extramenu;

int g_RemoveLobby,g_nbUpdate,g_byPassSteam, g_Auto, g_Snum, g_Stime, g_SDPSlim, g_STP,
    g_Relax, g_RelaxFast, g_Fixm4,
    g_FF, g_MultiAmmo, g_MultiMed, g_TP, g_KB, g_Healsys, g_weaponrule, g_killback = -1;


// ====================================================================================================
//					PLUGIN INFO
// ====================================================================================================



// ====================================================================================================
//					MAIN FUNCTIONS
// ====================================================================================================
public void OnPluginStart()
{
    RegAdminCmd("sm_setmenu", CmdMenuTest, ADMFLAG_ROOT);
}
public void OnAllPluginsLoaded(){
	if (LibraryExists("extra_menu")) OnLibraryAdded("extra_menu");
}
public void OnLibraryAdded(const char[] name)
{
    if( strcmp(name, "extra_menu") == 0 )
    {
        g_Extramenu = ExtraMenu(false, "", false);
        g_Extramenu.AddEntry                         ("<服务器控制菜单 Page1>");
        g_Extramenu.AddEntry                         ("使用W/S选择选项, A/D进行调整");
        g_Extramenu.AddEntry                         ("  ");
        g_Extramenu.AddEntry                         ("A. 服务器控制");
        g_RemoveLobby = g_Extramenu.AddEntryOnly     ("1. 移除大厅匹配");
        g_nbUpdate = g_Extramenu.AddEntryAdd         ("2. 小僵尸刷新率: 0.0_OPT_", false, GetConvarFloattoIntEx("nb_update_frequency", 1000.0), 5, 10, 100);
        g_byPassSteam = g_Extramenu.AddEntrySwitch   ("3. 跳过steam验证 _OPT_", false, 0);
        g_Extramenu.AddEntry                         ("  ");
        g_Extramenu.AddEntry                         ("B. 多特控制");
        g_Auto = g_Extramenu.AddEntrySwitch          ("1. 自动调节刷特: _OPT_", false, GetConvarIntEx("sm_ss_automode"));
        g_Snum = g_Extramenu.AddEntryAdd             ("2. 特感刷新数量: 最高同屏_OPT_只", false, GetConvarIntEx("sss_1P"), 1, 0, 28);
        g_Stime = g_Extramenu.AddEntryAdd            ("3. 特感刷新时间: 每个Slot_OPT_s", false, GetConvarIntEx("SS_Time"), 5, 0, 80);
        g_SDPSlim = g_Extramenu.AddEntryAdd          ("4. DPS特感最大数: _OPT_只", false, GetConvarIntEx("SS_DPSSiLimit"), 1, 0, 28);
        g_STP = g_Extramenu.AddEntrySwitch           ("5. 不可见特感自动传送 _OPT_", false, GetConvarIntEx("teleport_enable"));
        g_Extramenu.NewPage();
        g_Extramenu.AddEntry                         ("<服务器控制菜单 Page2>");
        g_Extramenu.AddEntry                         ("使用W/S选择选项, A/D进行调整");
        g_Extramenu.AddEntry                         ("  ");

        g_Extramenu.AddEntry                         ("C. 多特Relax阶段控制");
        g_Relax = g_Extramenu.AddEntrySwitch         ("1. Relax阶段 _OPT_", false, GetConvarIntEx("SS_Relax"));
        g_RelaxFast = g_Extramenu.AddEntrySelect     ("2. 快速补特： _OPT_", "关闭|特感类CD锁定1s|特感类CD锁定1s*踢出死亡特感");
        g_Fixm4 = g_Extramenu.AddEntrySwitch         ("3. 绝境不停刷修复 _OPT_", false, GetConvarIntEx("sm_ss_fixm4spawn"));
        
        g_Extramenu.AddEntry                         ("  ");
        g_Extramenu.AddEntry                         ("D. 舒适设置");
        g_FF = g_Extramenu.AddEntrySwitch            ("1. 阻止友伤 _OPT_",false, GetConvarIntEx("nff_enable"));
        g_MultiAmmo = g_Extramenu.AddEntryAdd        ("2. 设置备弹 *_OPT_", false, 1, 1, 1, 100);
        g_MultiMed = g_Extramenu.AddEntryAdd         ("3. 设置医疗物品 *_OPT_", false, 1, 1, 100);
        g_TP = g_Extramenu.AddEntryAdd               ("4. 传送全体生还至 ->_OPT_%", false, 0, 3, 0, 110);
        g_KB = g_Extramenu.AddEntryOnly              ("5. 踢出Bot");
        g_Healsys = g_Extramenu.AddEntrySwitch       ("6. 呼吸回血+击杀回血 _OPT_", false, GetConvarIntEx("automatic_healing_enable"));
        g_weaponrule = g_Extramenu.AddEntrySelect    ("7. 调整武器配置强度 _OPT_", "v1|v2|v3");
        g_killback = g_Extramenu.AddEntrySwitch      ("8. 特感血条和击杀反馈 _OPT_", false, GetConvarIntEx("l4d_infectedhp"));

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
    g_Extramenu.Close();
}

// Display menu
Action CmdMenuTest(int client, int args)
{
    g_Extramenu.Show(client, MENU_TIME_FOREVER);
    return Plugin_Handled;
}

public void ExtraMenu_OnSelect(int client, int menu_id, int option, int value){
    if (menu_id != g_Extramenu._index) return;
    if (option == g_RemoveLobby) {
        ServerCommand("sm_unreserve;sm_cvar sv_force_unreserved 1; sm_cvar sv_tags hidden; sm_cvar sv_steamgroup 0");
    }
    else if (option == g_nbUpdate) {
        ServerCommand("sm_cvar nb_update_frequency %.4f", float(value) / 1000.0);
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
