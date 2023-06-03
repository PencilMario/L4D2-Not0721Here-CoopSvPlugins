ConVar g_cSmgAmmo, g_cShotGunAmmo, g_cAutoShotGunAmmo, g_cAssrultRifleAmmo, g_cHuntingRifleAmmo, 
    g_cSinperRifleAmmo, g_cM60Ammo, g_cGrenadeAmmo;

enum
{
    AMMO_SMG_MAX = 650,
    AMMO_SHOTGUN_MAX = 75,
    AMMO_AUTOSHOTGUN_MAX = 90,
    AMMO_ASSAULTRIFLE_MAX = 360,
    AMMO_HUNTINGRIFLE_MAX = 150,
    AMMO_SNIPERRIFLE_MAX = 150,
    AMMO_M60_MAX = 150,
    AMMO_GRENADELAUNCHER_MAX = 30
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

    RegServerCmd("sm_setammomulti", Cmd_SetAmmo);
}

public Action Cmd_SetAmmo(int args)
{
    int multi = GetCmdArgInt(1);
    g_cSmgAmmo.IntValue = AMMO_SMG_MAX * multi;
    g_cShotGunAmmo.IntValue = AMMO_SHOTGUN_MAX * multi;
    g_cAutoShotGunAmmo.IntValue = AMMO_AUTOSHOTGUN_MAX * multi;
    g_cAssrultRifleAmmo.IntValue = AMMO_ASSAULTRIFLE_MAX * multi;
    g_cHuntingRifleAmmo.IntValue = AMMO_HUNTINGRIFLE_MAX * multi;
    g_cSinperRifleAmmo.IntValue = AMMO_SNIPERRIFLE_MAX * multi;
    g_cM60Ammo.IntValue = AMMO_M60_MAX * multi;
    g_cGrenadeAmmo.IntValue = AMMO_GRENADELAUNCHER_MAX * multi;
    return Plugin_Handled;
}