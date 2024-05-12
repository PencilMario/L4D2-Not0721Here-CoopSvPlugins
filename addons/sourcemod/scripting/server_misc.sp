ConVar g_cSmgAmmo, g_cShotGunAmmo, g_cAutoShotGunAmmo, g_cAssrultRifleAmmo, g_cHuntingRifleAmmo, 
    g_cSinperRifleAmmo, g_cM60Ammo, g_cGrenadeAmmo, g_cChainsawAmmo;

#include <extra_menu>
#include <adminmenu>
int g_RemoveLobby,g_nbUpdate,g_byPassSteam, g_Auto, g_Snum, g_Stime, g_SDPSlim, g_STP,
    g_Relax, g_RelaxFast, g_Fixm4,
    g_FF, g_MultiAmmo, g_MultiMed, g_TP, g_KB, g_Healsys, g_weaponrule, g_killback = -1;
ExtraMenu servermenu;
TopMenu hAdminMenu = null;
enum
{
    AMMO_SMG_MAX = 650,
    AMMO_SHOTGUN_MAX = 75,
    AMMO_AUTOSHOTGUN_MAX = 90,
    AMMO_ASSAULTRIFLE_MAX = 360,
    AMMO_HUNTINGRIFLE_MAX = 150,
    AMMO_SNIPERRIFLE_MAX = 150,
    AMMO_M60_MAX = 150,
    AMMO_GRENADELAUNCHER_MAX = 30,
    AMMO_CHAINSAW_MAX = 20
}

public Plugin myinfo = {
    name = "ammo",
    author = "sp",
    description = "调节备弹",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart(){
    g_cSmgAmmo = FindConVar("ammo_smg_max");
    g_cShotGunAmmo = FindConVar("ammo_shotgun_max");
    g_cAutoShotGunAmmo = FindConVar("ammo_autoshotgun_max");
    g_cAssrultRifleAmmo = FindConVar("ammo_assaultrifle_max");
    g_cHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
    g_cSinperRifleAmmo = FindConVar("ammo_sniperrifle_max");
    g_cM60Ammo = FindConVar("ammo_m60_max");
    g_cGrenadeAmmo = FindConVar("ammo_grenadelauncher_max");
    g_cChainsawAmmo = FindConVar("ammo_chainsaw_max");

    RegServerCmd("sm_setammomulti", Cmd_SetAmmo);
    RegConsoleCmd("sm_showsvmenu", Cmd_Menu);
    
    TopMenu topmenu;
    if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
    {
      /* If so, manually fire the callback */
      OnAdminMenuReady(topmenu);
    }
}
public void OnLibraryAdded(const char[] name)
{
    if( strcmp(name, "extra_menu") == 0 ) {
        servermenu = ExtraMenu(false, "", false);
        servermenu.AddEntry                         ("<服务器控制菜单 Page1>");
        servermenu.AddEntry                         ("使用W/S选择选项, A/D进行调整");
        servermenu.AddEntry                         ("  ");
        servermenu.AddEntry                         ("A. 服务器控制")
        g_RemoveLobby = servermenu.AddEntryOnly     ("1. 移除大厅匹配")
        g_nbUpdate = servermenu.AddEntryAdd         ("2. 小僵尸刷新率: 0.0_OPT_", false, GetConvarFloattoIntEx("nb_update_frequency", 1000.0), 5, 10, 100)
        g_byPassSteam = servermenu.AddEntrySwitch   ("3. 跳过steam验证 _OPT_", false, 0);
        servermenu.AddEntry                         ("  ");
        servermenu.AddEntry                         ("B. 多特控制");
        g_Auto = servermenu.AddEntrySwitch          ("1. 自动调节刷特: _OPT_", false, GetConvarIntEx("sm_ss_automode"));
        g_Snum = servermenu.AddEntryAdd             ("2. 特感刷新数量: 最高同屏_OPT_只", false, GetConvarIntEx("sss_1P"), 1, 0, 28);
        g_Stime = servermenu.AddEntryAdd            ("3. 特感刷新时间: 每个Slot_OPT_s", false, GetConvarIntEx("SS_Time"), 5, 0, 80);
        g_SDPSlim = servermenu.AddEntryAdd          ("4. DPS特感最大数: _OPT_只", false, GetConvarIntEx("SS_DPSSiLimit"), 1, 0, 28);
        g_STP = servermenu.AddEntrySwitch           ("5. 不可见特感自动传送", false, GetConvarIntEx("teleport_enable"));
        servermenu.AddEntry                         ("  ");
        servermenu.NewPage()
        servermenu.AddEntry                         ("<服务器控制菜单 Page2>");
        servermenu.AddEntry                         ("使用W/S选择选项, A/D进行调整");
        servermenu.AddEntry                         ("  ");
        servermenu.AddEntry                         ("C. 多特Relax阶段控制");
        g_Relax = servermenu.AddEntrySwitch         ("1. Relax阶段 _OPT_", false, GetConvarIntEx("SS_Relax"));
        g_RelaxFast = servermenu.AddEntrySelect     ("2. 快速补特： _OPT_", "关闭|特感类CD锁定1s|特感类CD锁定1s*踢出死亡特感");
        g_Fixm4 = servermenu.AddEntrySwitch         ("3. 绝境不停刷修复 _OPT_", false, GetConvarIntEx("sm_ss_fixm4spawn"));
        

        
        servermenu.AddEntry                         ("  ");
        servermenu.AddEntry                         ("D. 舒适设置");
        g_FF = servermenu.AddEntrySwitch            ("1. 阻止友伤 _OPT_",false, GetConvarIntEx("nff_enable"));
        g_MultiAmmo = servermenu.AddEntryAdd        ("2. 设置备弹 *_OPT_", false, 1, 1, 1, 100);
        g_MultiMed = servermenu.AddEntryAdd         ("3. 设置医疗物品 *_OPT_", false, 1, 1, 100);
        g_TP = servermenu.AddEntryAdd               ("4. 传送全体生还至 ->_OPT_%", false, 0, 3, 0, 110);
        g_KB = servermenu.AddEntryOnly              ("5. 踢出Bot");
        g_Healsys = servermenu.AddEntrySwitch       ("6. 呼吸回血+击杀回血 _OPT_", false, GetConvarIntEx("automatic_healing_enable"))
        g_weaponrule = servermenu.AddEntrySelect    ("7. 调整武器配置强度 _OPT_", "v1|v2|v3");
        g_killback = servermenu.AddEntrySwitch      ("8. 特感血条和击杀反馈 _OPT_", false, GetConvarIntEx("l4d_infectedhp"));
        servermenu.AddEntry                         ("  ");

    }
}
public void OnLibraryRemoved(const char[] name)
{
  if (StrEqual(name, "adminmenu", false))
  {
    hAdminMenu = null;
  }
}
public void OnPluginEnd(){
    servermenu.Close();
}
/// Register our menus with SourceMod
public OnAdminMenuReady(Handle:menu) {
    /* If the category is third party, it will have its own unique name. */
    TopMenuObject sv_commands = FindTopMenuCategory(menu, ADMINMENU_SERVERCOMMANDS);
    if (menu == hAdminMenu && sv_commands != INVALID_TOPMENUOBJECT)
    {
      return;
    }
    AddToTopMenu(menu, "游戏规则设置", TopMenuObject_Item, Menu_CategoryHandler, sv_commands);
    hAdminMenu = menu;
}

public void Menu_CategoryHandler(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, client, String:buffer[], maxlength) {
	switch (action)
    {    
        case TopMenuAction_DisplayOption:
        {
          strcopy(buffer, maxlength, "游戏规则设置项");
        }
        case TopMenuAction_SelectOption , TopMenuAction_DrawOption:
        {
          //do
            //BuildMenu()
            servermenu.Show(client);
        }
    }
}

public void ExtraMenu_OnSelect(int client, int menu_id, int option, int value){
    if (menu_id != servermenu._index) return;
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
public Action Cmd_Menu(int client, int args)
{
    //BuildMenu()
    servermenu.Show(client);
    PrintToConsoleAll("Cmd_Menu")
    return Plugin_Handled;
}
public Action Cmd_SetAmmo(int args)
{
    char num[32];
    GetCmdArg(1, num, sizeof(num));
    float multi = StringToFloat(num);
    g_cSmgAmmo.IntValue = RoundToNearest(float(AMMO_SMG_MAX) * multi);
    g_cShotGunAmmo.IntValue = RoundToNearest(float(AMMO_SHOTGUN_MAX) * multi);
    g_cAutoShotGunAmmo.IntValue = RoundToNearest(float(AMMO_AUTOSHOTGUN_MAX) * multi);
    g_cAssrultRifleAmmo.IntValue = RoundToNearest(float(AMMO_ASSAULTRIFLE_MAX) * multi);
    g_cHuntingRifleAmmo.IntValue = RoundToNearest(float(AMMO_HUNTINGRIFLE_MAX) * multi);
    g_cSinperRifleAmmo.IntValue = RoundToNearest(float(AMMO_SNIPERRIFLE_MAX) * multi);
    g_cM60Ammo.IntValue = RoundToNearest(float(AMMO_M60_MAX) * multi);
    g_cGrenadeAmmo.IntValue = RoundToNearest(float(AMMO_GRENADELAUNCHER_MAX) * multi);
    g_cChainsawAmmo.IntValue = RoundToNearest(float(AMMO_CHAINSAW_MAX) * multi);
    return Plugin_Handled;
}