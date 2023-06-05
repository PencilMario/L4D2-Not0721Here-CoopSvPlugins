#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

public Plugin myinfo =
{
	name = "[L4D2] 显示弹药剩余",
	author = "SirP",
	description = "用于在修改备弹的服务器中提示超过1024的备弹",
	version = "0.2",
	url = ""
};

public void OnPluginStart()
{
    /*RegConsoleCmd("sm_printammoremain", Call_AmmoPrint, "6");*/
    HookEvent("weapon_reload", Reload_WeaponEvent, EventHookMode_Post);
}

public Action Reload_WeaponEvent(Event event, const String:name[], bool:dontBroadcast){
    int playerid = event.GetInt("userid");
    int client = GetClientOfUserId(playerid);
    int primary = GetPlayerWeaponSlot(client, 0);
    int bakammo = GetWeaponBackupAmmo(client, primary);
    if (1000 > bakammo && bakammo > 950){
        CPrintToChat(client, "{green}[{lightgreen}!{green}] {default}当剩余子弹低于950后将不再提示此信息");
    }
    if (bakammo > 950){
        CPrintToChat(client, "{green}[{lightgreen}!{green}] {default}剩余子弹 \x0B> {olive}%d", bakammo);
    }
    return Plugin_Continue
}

/*public Action Call_AmmoPrint(int client, int args){
    int primary = GetPlayerWeaponSlot(client, 0);
    int bakammo = GetWeaponBackupAmmo(client, primary);
    if (1100 > bakammo && bakammo > 1000){
        CPrintToChat(client, "{green}[{lightgreen}!{green}] {default}当剩余子弹低于950后将不再提示此信息");
    }
    if (bakammo > 950){
        CPrintToChat(client, "{green}[{lightgreen}!{green}] {default}剩余子弹 \x0B> {olive}%d", bakammo);
    }
    return Plugin_Continue
}*/

public int GetWeaponBackupAmmo(int owner, int weapon){
    return GetEntProp(owner, Prop_Data, "m_iAmmo", _, GetWeaponAmmoType(weapon));
}

public int GetWeaponAmmoType(int weapon)
{
    return GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");
}