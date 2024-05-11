ConVar g_cSmgAmmo, g_cShotGunAmmo, g_cAutoShotGunAmmo, g_cAssrultRifleAmmo, g_cHuntingRifleAmmo, 
    g_cSinperRifleAmmo, g_cM60Ammo, g_cGrenadeAmmo, g_cChainsawAmmo;

#include <extra_menu>
int g_RemoveLobby,g_nbUpdate,g_byPassSteam, g_Auto, g_Snum, g_Stime, g_SDPSlim
ExtraMenu servermenu
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
    BuildMenu();

}

public void BuildMenu()
{
    servermenu = ExtraMenu(false, "", false);
    servermenu.AddEntry                         ("<服务器控制菜单 Page1>");
    servermenu.AddEntry                         ("使用W/S选择选项, A/D进行调整");
    servermenu.AddEntry                         ("  ");
    servermenu.AddEntry                         ("A. 服务器控制")
    g_RemoveLobby = servermenu.AddEntryOnly     ("1. 移除大厅匹配")
    g_nbUpdate = servermenu.AddEntryAdd         ("2. 小僵尸刷新率: _OPT_", false, 0.014, 0.01, 0.014, 0.12)
    g_byPassSteam = servermenu.AddEntrySwitch   ("3. 跳过steam验证", false, 0);
    servermenu.AddEntry                         ("  ");
    servermenu.AddEntry                         ("B. 多特控制");
    g_Auto = servermenu.AddEntrySwitch          ("1. 自动调节刷特: _OPT_", false, 1);
    g_Snum = servermenu.AddEntryAdd             ("2. 特感刷新数量: 最高同屏_OPT_只", 0, 1, 0, 28);
    g_Stime = servermenu.AddEntryAdd            ("3. 特感刷新时间: 每个Slot_OPT_s", 0, 5, 0, 80);
    g_SDPSlim = servermenu.AddEntryAdd          ("4. DPS特感最大数: _OPT_只", false, 0, 1, 0, 28);
    
    servermenu.AddEntry                         ("  ");
    servermenu.AddEntry                         ("C. 多特Relax阶段控制");
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