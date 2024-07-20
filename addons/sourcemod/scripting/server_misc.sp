ConVar g_cSmgAmmo, g_cShotGunAmmo, g_cAutoShotGunAmmo, g_cAssrultRifleAmmo, g_cHuntingRifleAmmo, 
    g_cSinperRifleAmmo, g_cM60Ammo, g_cGrenadeAmmo, g_cChainsawAmmo;

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
    ServerCommand("sm_weapon weapon_chainsaw clipsize %i", RoundToNearest(float(AMMO_CHAINSAW_MAX) * multi))
    return Plugin_Handled;
}