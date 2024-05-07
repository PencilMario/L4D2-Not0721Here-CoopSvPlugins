#pragma semicolon 1
#pragma newdecls required

#include <sourcemod> 
#include <sdktools>
#include <l4d2_skills>
#define MY_EXPORT_NAME "超级气球商店"
#define SURPLUS(%1) 	i_MaxWeapon-ClientWeapon[%1]
 
ConVar cv_MaxWeapon, cv_AmmoTime, cv_Disable; 
KeyValues kv;
bool b_Disable;
float f_AmmoTime, ClientAmmoTime[MAXPLAYERS + 1];
int i_MaxWeapon, ClientWeapon[MAXPLAYERS + 1], ClientMelee[MAXPLAYERS + 1];
char MeleeName[][] = {"暂无", "砍刀", "消防斧", "小刀", "武士刀", "马格南", "电吉他", "警棍", "平底锅", "撬棍", "草叉", "铲子", "普通小手枪"};
char filePath[PLATFORM_MAX_PATH];

public Plugin myinfo =  
{ 
    name = "[L4D2]Shop", 
    author = "奈", 
    description = "商店(本地文本控制)", 
    version = "2.2", 
    url = "https://github.com/NanakaNeko/l4d2_plugins_coop" 
}

public void OnPluginStart() 
{ 
    loadFile();
    //RegConsoleCmd("sm_gw", ShowMenu, "商店菜单"); 
    //RegConsoleCmd("sm_buy", ShowMenu, "商店菜单");

    //RegAdminCmd("sm_shop", SwitchShop, ADMFLAG_ROOT, "开关商店");
    

    cv_Disable = CreateConVar("l4d2_shop_disable", "0", "商店开关 开:0 关:1", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    cv_MaxWeapon = CreateConVar("l4d2_weapon_number", "999", "每关单人可用上限", FCVAR_NOTIFY, true, 0.0);
    cv_AmmoTime = CreateConVar("l4d2_give_ammo_time", "180.0", "补充子弹的最小间隔时间,小于0.0关闭功能", FCVAR_NOTIFY);
    HookEvent("round_start", Event_Reset, EventHookMode_Pre);
    HookEvent("mission_lost", Event_Reset, EventHookMode_Post);
    HookEvent("player_death", Event_player_death, EventHookMode_Post);
    HookConVarChange(cv_Disable, CvarChanged);
    HookConVarChange(cv_MaxWeapon, CvarChanged);
    HookConVarChange(cv_AmmoTime, CvarChanged);
    getCvar();
}  
public void OnAllPluginsLoaded()
{
    Skills_AddMenuItem("skills_shop", "超级气球超市", ItemMenuCallback);
}
public void ItemMenuCallback( int client, const char[] item )
{
    ShowMenu(client, 0);
}
void CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    getCvar();
}

public void OnConfigsExecuted()
{
    getCvar();
}

void getCvar()
{
    b_Disable = GetConVarBool(cv_Disable);
    i_MaxWeapon = GetConVarInt(cv_MaxWeapon);
    f_AmmoTime = GetConVarFloat(cv_AmmoTime);
}

public void OnClientPostAdminCheck(int client)
{
    if(!IsFakeClient(client))
    {
        ClientSaveToFileLoad(client);	
    }
    ClientAmmoTime[client] = 0.0;
}

public void OnClientDisconnect(int client)
{
    if(!IsFakeClient(client))
    {
        ClientSaveToFileSave(client);
    }
}

public void loadFile()
{
    kv = new KeyValues("ClientMelee");
    BuildPath(Path_SM, filePath, sizeof(filePath), "data/Melee.txt");
    if (FileExists(filePath))
        FileToKeyValues(kv, filePath);
    else
        KeyValuesToFile(kv, filePath);
}

public void ClientSaveToFileSave(int client)
{
    char user_id[128];
    GetClientAuthId(client, AuthId_Engine, user_id, sizeof(user_id), true);
    KvJumpToKey(kv, user_id, true);
    KvSetNum(kv, "Melee", ClientMelee[client]);
    KvGoBack(kv);
    KvRewind(kv);
    KeyValuesToFile(kv, filePath);
}

public void ClientSaveToFileLoad(int client)
{
    char user_id[128];
    GetClientAuthId(client, AuthId_Engine, user_id, sizeof(user_id), true);
    KvJumpToKey(kv, user_id, true);
    ClientMelee[client] = KvGetNum(kv, "Melee", 0);
    KvGoBack(kv);
    KvRewind(kv);
}

//玩家死亡重置次数
public void Event_player_death(Event event, const char []name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    ClientWeapon[client] = 0;
    ClientAmmoTime[client] = 0.0;
}

//回合开始或失败重开重置次数
public Action Event_Reset(Event event, const char []name, bool dontBroadcast)
{
    for(int client = 1; client <= MaxClients; client++){
        ClientWeapon[client] = 0;
        ClientAmmoTime[client] = 0.0;
    }
    return Plugin_Continue;
}

//开局发近战武器
public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
    if(b_Disable)
        return Plugin_Stop;
    for(int i=1;i<=MaxClients;i++)
        if(!NoValidPlayer(i) && GetClientTeam(i) == 2)
        {
            CreateTimer(0.5, Timer_AutoGive, i, TIMER_FLAG_NO_MAPCHANGE);
        }
    return Plugin_Stop;
}

//开关商店
public Action SwitchShop(int client, int args)
{
    char info[4];
    if(args == 0)
    {
        if(b_Disable)
            PrintToChat(client, "\x01[\x04!\x01] \x03商店已关闭,打开请输入\x04!shop on");
        else
            PrintToChat(client, "\x01[\x04!\x01] \x03商店已开启,关闭请输入\x04!shop off");
    }
    else if(args == 1)
    {
        GetCmdArg(1, info, sizeof(info));
        if (strcmp(info, "on", false) == 0)
        {
            b_Disable = false;
            PrintToChatAll("\x01[\x04!\x01] \x03管理员打开商店");
        }
        else if (strcmp(info, "off", false) == 0)
        {
            b_Disable = true;
            PrintToChatAll("\x01[\x04!\x01] \x03管理员关闭商店");
        }
        else
            PrintToChat(client, "\x01[\x04!\x01] \x03请输入正确的命令!");
    }
    return Plugin_Handled;
}

//主面板菜单
public Action ShowMenu(int client, int args)
{
    if(b_Disable)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03商店未开启");
        return Plugin_Handled;
    }
    if( !NoValidPlayer(client) && GetClientTeam(client) == 2 )
    {
        Menu menu = new Menu(ShowMenuDetail);
        menu.SetTitle("商店菜单\n-----------\n团队积分：");
        menu.AddItem("gun", "垃圾枪【全场2000点】");
        menu.AddItem("melee", "逆天近战【全场500点】");
        menu.AddItem("item", "超级好东西【全场4000点】");
        menu.AddItem("meleeSelect", "出门近战【每次250点】");
        menu.Display(client, 20);
    }
    return Plugin_Handled;
}

//主面板菜单选择后执行
public int ShowMenuDetail(Menu menu, MenuAction action, int client, int num)
{
    if (action == MenuAction_Select)
    {
        switch(num)
        {
            case 0:
            {
                WeaponMenu(client);
            }
            case 1:
            {
                MeleeMenu(client);
            }
            case 2:
            {
                ItemMenu(client);
            }
            case 3:
            {
                MeleeSelect(client);
            }
        }
    }
    if (action == MenuAction_End)	
        delete menu;
    return 0;
}

public void ItemMenu(int client) 
{
    float money = Skills_GetTeamMoney(); 
    Menu menu = new Menu(ItemMenu_back);
    menu.SetTitle("道具(剩余:%.0f)\n------------------", money);
    menu.AddItem("item1", "土质手雷");
    menu.AddItem("item2", "燃烧瓶");
    menu.AddItem("item3", "胆汁");
    menu.AddItem("item4", "油桶");
    menu.AddItem("item5", "针（可用于倒地自起）");
    menu.AddItem("item6", "网瘾治疗器（可作为武器/治疗他人）");
    menu.AddItem("item7", "马格南");
    menu.Display(client, 20);

} 

public int ItemMenu_back(Menu menu, MenuAction action, int client, int num)
{
    float money = Skills_GetTeamMoney(); 
    if (money < 4000.0){
        Skills_PrintToChat(client, "\x05你的队伍 \x04没有足够的 \x03积分");
        return 0;
    }
    if (action == MenuAction_Select)
    {
        switch (num) 
        { 
            case 0: 
            { 
                GiveCommand(client, "pipe_bomb");
            }
            case 1: 
            { 
                GiveCommand(client, "molotov");
            }
            case 2: 
            { 
                GiveCommand(client, "vomitjar");
            }
            case 3:
            { 
                GiveCommand(client, "gascan");
            }
            case 4:
            { 
                GiveCommand(client, "adrenaline");
            }
            case 5:
            { 
                GiveCommand(client, "defibrillator");
            }
            case 6:
            { 
                GiveCommand(client, "pistol_magnum");
            }
        }
        Skills_SetTeamMoney(money-4000.0);
    }
    else if (action == MenuAction_End)	
        delete menu;
    return 0;

}
//白嫖武器菜单
public void WeaponMenu(int client) 
{
    float money = Skills_GetTeamMoney(); 
    Menu menu = new Menu(WeaponMenu_back);
    menu.SetTitle("武器(剩余:%.0f)\n------------------", money);
    menu.AddItem("weapon1", "AK47");
    menu.AddItem("weapon2", "30连");
    menu.AddItem("weapon3", "一代连喷");
    menu.AddItem("weapon4", "AWP");
    menu.AddItem("weapon5", "M60");
    menu.Display(client, 20);
} 

//白嫖武器菜单选择后执行
public int WeaponMenu_back(Menu menu, MenuAction action, int client, int num)
{
    float money = Skills_GetTeamMoney(); 
    if (money < 2000.0){
        Skills_PrintToChat(client, "\x05你的队伍 \x04没有足够的 \x03积分");
        return 0;
    }
    if (action == MenuAction_Select)
    {
        switch (num) 
        { 
            case 0: 
            { 
                GiveCommand(client, "rifle_ak47");
            }
            case 1: 
            { 
                GiveCommand(client, "sniper_military");
            }
            case 2: 
            { 
                GiveCommand(client, "autoshotgun");
            }
            case 3:
            { 
                GiveCommand(client, "sniper_awp");
            }
            case 4:
            {
                GiveCommand(client, "rifle_m60");
            }
        }
        Skills_SetTeamMoney(money-2000.0);
    }
    if (action == MenuAction_End)	
        delete menu;
    return 0;
}

//白嫖近战菜单
public void MeleeMenu(int client) 
{ 
    Menu menu = new Menu(MeleeMenu_back);
    menu.SetTitle("近战(剩余:%.0f)\n------------------",Skills_GetTeamMoney());
    menu.AddItem("melee1", "砍刀");
    menu.AddItem("melee2", "消防斧");
    menu.AddItem("melee3", "小刀");
    menu.AddItem("melee4", "武士刀");
    menu.AddItem("melee5", "电吉他");
    menu.AddItem("melee6", "警棍");
    menu.AddItem("melee7", "平底锅");
    menu.AddItem("melee8", "撬棍");
    menu.AddItem("melee9", "草叉");
    menu.AddItem("melee10", "铲子");
    menu.Display(client, 20);
}

//白嫖近战菜单选择后执行
public int MeleeMenu_back(Menu menu, MenuAction action, int client, int num)
{
    float money = Skills_GetTeamMoney(); 
    if (money < 500.0){
        Skills_PrintToChat(client, "\x05你的队伍 \x04没有足够的 \x03积分");
        return 0;
    }
    if (action == MenuAction_Select)
    {
        switch(num)
        {
            case 0://砍刀
            {
                GiveCommand(client, "machete");
            }
            case 1://消防斧
            {
                GiveCommand(client, "fireaxe");
            }
            case 2://小刀
            {
                GiveCommand(client, "knife");
            }
            case 3://武士刀
            {
                GiveCommand(client, "katana");
            }
            case 4://电吉他
            {
                GiveCommand(client, "electric_guitar");
            }
            case 5://警棍
            {
                GiveCommand(client, "tonfa");
            }
            case 6://平底锅
            {
                GiveCommand(client, "frying_pan");
            }
            case 7://撬棍
            {
                GiveCommand(client, "crowbar");
            }
            case 8://草叉
            {
                GiveCommand(client, "pitchfork");
            }
            case 9://铲子
            {
                GiveCommand(client, "shovel");
            }
        }
        Skills_SetTeamMoney(money-500.0);
    }
    if (action == MenuAction_End)	
        delete menu;
    return 0;
}


//出门近战选择菜单
public void MeleeSelect(int client)
{
    if( !NoValidPlayer(client) && GetClientTeam(client) == 2 )
    {
        Menu menu = new Menu(MeleeSelect_back);
        menu.SetTitle("选择出门近战,当前为%s\n-------------",MeleeName[ClientMelee[client]]);
        menu.AddItem("none", "清除武器");
        menu.AddItem("machete", "砍刀");
        menu.AddItem("fireaxe", "消防斧");
        menu.AddItem("knife", "小刀");
        menu.AddItem("katana", "武士刀");
        menu.AddItem("pistol_magnum", "呃呃，这个懒得改了，别选");
        menu.AddItem("electric_guitar", "电吉他");
        menu.AddItem("tonfa", "警棍");
        menu.AddItem("frying_pan", "平底锅");
        menu.AddItem("crowbar", "撬棍");
        menu.AddItem("pitchfork", "草叉");
        menu.AddItem("shovel", "铲子");
        menu.AddItem("pistol", "普通小手枪");
        menu.Display(client, 20);
    }
}

//出门近战选择后执行
public int MeleeSelect_back(Menu menu, MenuAction action, int client, int num)
{

    if (action == MenuAction_Select)
    {
        switch(num)
        {
            case 0://清除武器
            {
                ClientMelee[client]=0;
                PrintToChat(client,"\x01[\x04!\x01] \x03出门近战武器设置已清除");
            }
            case 1://砍刀
            {
                ClientMelee[client]=1;
                PrintMeleeSelect(client);
            }
            case 2://消防斧
            {
                ClientMelee[client]=2;
                PrintMeleeSelect(client);
            }
            case 3://小刀
            {
                ClientMelee[client]=3;
                PrintMeleeSelect(client);
            }
            case 4, 5://武士刀
            {
                ClientMelee[client]=4;
                PrintMeleeSelect(client);
            }

            case 6://电吉他
            {
                ClientMelee[client]=6;
                PrintMeleeSelect(client);
            }
            case 7://警棍
            {
                ClientMelee[client]=7;
                PrintMeleeSelect(client);
            }
            case 8://平底锅
            {
                ClientMelee[client]=8;
                PrintMeleeSelect(client);
            }
            case 9://撬棍
            {
                ClientMelee[client]=9;
                PrintMeleeSelect(client);
            }
            case 10://草叉
            {
                ClientMelee[client]=10;
                PrintMeleeSelect(client);
            }
            case 11://铲子
            {
                ClientMelee[client]=11;
                PrintMeleeSelect(client);
            }
            case 12://普通小手枪
            {
                ClientMelee[client]=12;
                PrintMeleeSelect(client);
            }
        }
    }
    if (action == MenuAction_End)	
        delete menu;
    return 0;
}

//出门近战选择后聊天框展示
void PrintMeleeSelect(int client)
{
    PrintToChat(client,"\x01[\x04!\x01] \x05出门近战武器设为\x03%s", MeleeName[ClientMelee[client]]);
}

//出门发放近战
public Action Timer_AutoGive(Handle timer, any client)
{
    float money = Skills_GetTeamMoney(); 
    if (money < 250.0){
        if (ClientMelee[client]) Skills_PrintToChat(client, "\x05你的队伍 \x04没有足够的 \x03积分\x05，无法发放出门近战喽");
        return Plugin_Continue;
    }else
    {
        Skills_SetTeamMoney(money-250.0);
    }
    if (ClientMelee[client] == 1)
    {
        DeleteMelee(client);
        GiveCommand(client, "machete");
    }
    if (ClientMelee[client] == 2)
    {
        DeleteMelee(client);
        GiveCommand(client, "fireaxe");
    }
    if (ClientMelee[client] == 3)
    {
        DeleteMelee(client);
        GiveCommand(client, "knife");
    }
    if (ClientMelee[client] == 4)
    {
        DeleteMelee(client);
        GiveCommand(client, "katana");
    }
    if (ClientMelee[client] == 5)
    {
        DeleteMelee(client);
        GiveCommand(client, "pistol_magnum");
    }
    if (ClientMelee[client] == 6)
    {
        DeleteMelee(client);
        GiveCommand(client, "electric_guitar");
    }
    if (ClientMelee[client] == 7)
    {
        DeleteMelee(client);
        GiveCommand(client, "tonfa");
    }
    if (ClientMelee[client] == 8)
    {
        DeleteMelee(client);
        GiveCommand(client, "frying_pan");
    }
    if (ClientMelee[client] == 9)
    {
        DeleteMelee(client);
        GiveCommand(client, "crowbar");
    }
    if (ClientMelee[client] == 10)
    {
        DeleteMelee(client);
        GiveCommand(client, "pitchfork");
    }
    if (ClientMelee[client] == 11)
    {
        DeleteMelee(client);
        GiveCommand(client, "shovel");
    }
    if (ClientMelee[client] == 12)
    {
        DeleteMelee(client);
        GiveCommand(client, "pistol");
    }
    
    return Plugin_Continue;
}

//清除副武器，这样不会出门重复刷武器
void DeleteMelee(int client)
{
    int item = GetPlayerWeaponSlot(client, 1);
    if (IsValidEntity(item) && IsValidEdict(item))
    {
        RemovePlayerItem(client, item);
    }
}

//补充子弹指令
public Action GiveAmmo(int client, int args)
{
    if(b_Disable)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03商店未开启");
        return Plugin_Handled;
    }
    if(f_AmmoTime < 0.0)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03补充子弹已关闭");
        return Plugin_Handled;
    }
    if (GetClientTeam(client) == 2 && !NoValidPlayer(client))
    {
        float fTime = GetEngineTime() - ClientAmmoTime[client] - f_AmmoTime;
        if (fTime < 0.0)
        {
            PrintToChat(client, "\x01[\x04!\x01] \x05请等待\x04%.1f\x05秒后补充子弹", FloatAbs(fTime));
            return Plugin_Handled;
        }
        GiveCommand(client, "ammo");
        ClientAmmoTime[client] = GetEngineTime();
    }
    return Plugin_Handled;
}

//cheat命令
void GiveCommand(int client, char[] args = "")
{
    int iFlags = GetCommandFlags("give");
    SetCommandFlags("give", iFlags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "give %s", args);
    SetCommandFlags("give", iFlags);
}

//判断玩家
bool NoValidPlayer(int Client)
{
    if (Client < 1 || Client > MaxClients)
        return true;
    if (!IsClientConnected(Client) || !IsClientInGame(Client))
        return true;
    if (IsFakeClient(Client))
        return true;
    if (!IsPlayerAlive(Client))
        return true;

    return false;
}

//白嫖武器判定
bool judge(int client)
{
    if(NoValidPlayer(client))  
        return true; 
        
    if(GetClientTeam(client) != 2) 
    { 
        PrintToChat(client, "\x01[\x04!\x01] \x03武器菜单仅对生还生效"); 
        return true; 
    } 

    if(ClientWeapon[client] >= i_MaxWeapon)  
    { 
        PrintToChat(client, "\x01[\x04!\x01] \x03已达到每关白嫖上限"); 
        return true; 
    }
    return false;
}

//快速白嫖铁喷
public Action GiveChr(int client,int args) 
{ 
    if(b_Disable)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03商店未开启");
        return Plugin_Handled;
    }
    if(judge(client))
        return Plugin_Handled;
    GiveCommand(client, "shotgun_chrome");
    return Plugin_Handled; 
}

//快速白嫖木喷
public Action GivePum(int client,int args) 
{ 
    if(b_Disable)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03商店未开启");
        return Plugin_Handled;
    }
    if(judge(client))
        return Plugin_Handled;
    GiveCommand(client, "pumpshotgun");
    return Plugin_Handled; 
}

//快速白嫖消音冲锋
public Action GiveSmg(int client,int args) 
{ 
    if(b_Disable)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03商店未开启");
        return Plugin_Handled;
    }
    if(judge(client))
        return Plugin_Handled;
    GiveCommand(client, "smg_silenced"); 
    return Plugin_Handled; 
}

//快速白嫖冲锋
public Action GiveUzi(int client,int args) 
{ 
    if(b_Disable)
    {
        PrintToChat(client, "\x01[\x04!\x01] \x03商店未开启");
        return Plugin_Handled;
    }
    if(judge(client))
        return Plugin_Handled;
    GiveCommand(client, "smg");
    return Plugin_Handled; 
}