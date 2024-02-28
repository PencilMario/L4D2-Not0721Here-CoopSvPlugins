#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sirputil/sirp_general.sp>
bool 	DEBUG			   = false;

ConVar Coin_Drop_Switch, Coin_Drop_Num, Coin_Drop_Model_Case, Coin_Drop_Model_Alpha, Coin_Drop_Clear_Time, Coin_Glow_Switch, Coin_Glow_Color, Coin_Glow_Range; 
ConVar Weapon_Drop_Glow_Switch, Weapon_Drop_Glow_Color, Weapon_Drop_Glow_Range;

int		g_Coin_Drop_Num, g_Coin_Drop_Model_Case, g_Coin_Drop_Model_Alpha, g_Coin_Drop_Clear_Time, g_Coin_Glow_Range;
char	g_Coin_Glow_Color[64];
bool	g_Coin_Drop_Switch, g_Coin_Glow_Switch;
bool	g_Weapon_Drop_Glow_Switch;
char	g_Weapon_Drop_Glow_Color[64];
int		g_Weapon_Drop_Glow_Range;

char c_models[][] = {
	"models/props_collectables/coin.mdl",		//0 金币
	"models/props_collectables/gold_bar.mdl",	//1 金砖
	"models/props_collectables/money_wad.mdl"	//2 钞票
};

public Plugin myinfo = {
	name 		= "死亡爆金币,死亡掉落装备冒金光",
	author 		= "CD意识STEAM_1:0:211123334 (Alliedmods:kazya3)",
	description = "老逼登爆装备",
	version 	= "1.1",
	url 		= "https://steamcommunity.com/profiles/76561198382512396/"
}

public OnPluginStart(){
	Coin_Drop_Switch		= CreateConVar("L4D2_Coin_Drop_Switch", 		"1", 			"是否死亡后掉落金币",							FCVAR_NOTIFY, true, 0.0, true, 1.0);
	Coin_Drop_Num			= CreateConVar("L4D2_Coin_Drop_Num", 			"15", 			"死亡后掉落多少金币",							FCVAR_NOTIFY, true, 0.0, true, 999.0);
	Coin_Drop_Model_Case	= CreateConVar("L4D2_Coin_Drop_Model_Case", 	"3", 			"金币模型,0:金币1:金砖:2:钞票3:随机",			 FCVAR_NOTIFY, true, 0.0, true, 3.0);
	Coin_Drop_Model_Alpha	= CreateConVar("L4D2_Coin_Drop_Model_Alpha", 	"255", 			"金币透明度",									FCVAR_NOTIFY, true, 0.0, true, 255.0);
	Coin_Drop_Clear_Time	= CreateConVar("L4D2_Coin_Drop_Clear_Time", 	"5", 			"金币清理时间",									FCVAR_NOTIFY, true, 0.0, true, 999.0);
	Coin_Glow_Switch		= CreateConVar("L4D2_Coin_Glow_Switch", 		"0", 			"金币是否发光描边",								FCVAR_NOTIFY, true, 0.0, true, 1.0);
	Coin_Glow_Color			= CreateConVar("L4D2_Coin_Glow_Color", 			"255 170 0", 	"金币发光描边颜色",					 			FCVAR_NOTIFY);
	Coin_Glow_Range			= CreateConVar("L4D2_Coin_Glow_Range", 			"2000", 		"金币发光范围",									FCVAR_NOTIFY, true, 0.0, true, 9999.0);
	Weapon_Drop_Glow_Switch	= CreateConVar("L4D2_Weapon_Drop_Glow_Switch", 	"0", 			"死亡掉落的武器是否发光描边",					 FCVAR_NOTIFY, true, 0.0, true, 1.0);
	Weapon_Drop_Glow_Color	= CreateConVar("L4D2_Weapon_Drop_Glow_Color", 	"255 170 0", 	"死亡掉落的武器发光描边颜色",					 FCVAR_NOTIFY);
	Weapon_Drop_Glow_Range	= CreateConVar("L4D2_Weapon_Drop_Glow_Range", 	"2000", 		"死亡掉落的武器发光范围",						 FCVAR_NOTIFY, true, 0.0, true, 9999.0);
	// SDKHOOK
	for (int i = 1; i <= MaxClients; i++){
		if (IsClientInGame(i)) SDKHook(i, SDKHook_WeaponDropPost , OnWeaponDropped);
	}

	GetCvars();
	Coin_Drop_Switch.AddChangeHook(ConVarChanges); 
	Coin_Drop_Num.AddChangeHook(ConVarChanges); 
	Coin_Drop_Model_Case.AddChangeHook(ConVarChanges); 
	Coin_Drop_Model_Alpha.AddChangeHook(ConVarChanges); 
	Coin_Drop_Clear_Time.AddChangeHook(ConVarChanges); 
	Coin_Glow_Switch.AddChangeHook(ConVarChanges); 
	Coin_Glow_Color.AddChangeHook(ConVarChanges); 
	Coin_Glow_Range.AddChangeHook(ConVarChanges);

	HookEvent("player_death",				Event_PlayerDeath);

	AutoExecConfig(true, "l4d2_drop_coins_v1.1");
}
//////////////////////////////////////////初始化相关//////////////////////////////////////////
public void ConVarChanges(ConVar convar, const char[] oldValue, const char[] newValue){
	GetCvars();
}
void GetCvars(){
	g_Coin_Drop_Switch 			= GetConVarBool(Coin_Drop_Switch);
	g_Coin_Drop_Num 			= GetConVarInt(Coin_Drop_Num);
	g_Coin_Drop_Model_Case 		= GetConVarInt(Coin_Drop_Model_Case); 
	g_Coin_Drop_Model_Alpha		= GetConVarInt(Coin_Drop_Model_Alpha); 
	g_Coin_Drop_Clear_Time 		= GetConVarInt(Coin_Drop_Clear_Time);
	g_Coin_Glow_Switch			= GetConVarBool(Coin_Glow_Switch);
	if(g_Coin_Glow_Switch){
		g_Coin_Glow_Range 			= GetConVarInt(Coin_Glow_Range); 
		GetConVarString(Coin_Glow_Color, g_Coin_Glow_Color, sizeof(g_Coin_Glow_Color));
	}
	g_Weapon_Drop_Glow_Switch = GetConVarBool(Weapon_Drop_Glow_Switch);
	if(g_Coin_Glow_Switch){
		g_Weapon_Drop_Glow_Range	= GetConVarInt(Weapon_Drop_Glow_Range); 
		GetConVarString(Weapon_Drop_Glow_Color, g_Weapon_Drop_Glow_Color, sizeof(g_Weapon_Drop_Glow_Color));
	}
}

// 缓存
public void OnMapStart()
{
	for ( int i = 0; i < sizeof(c_models); i++ ){
		PrecacheModel(c_models[i]);
	}
}

//////////////////////////////////////////死亡//////////////////////////////////////////
public void Event_PlayerDeath(Event event, const char[] name, bool dontbroadcast)
{
	if(!g_Coin_Drop_Switch)	return;
	if(entityCount() > (1900 - g_Coin_Drop_Num)) return; //防止太多实体炸服 一张图最多允许2048,我还额外给地图预留了148个槽位
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!isSurvivor(victim))	return;
	for(int i; i < g_Coin_Drop_Num; i ++){
		int coin = CreateEntityByName("prop_physics_override");
		if(IsValidEnt(coin)){
			
			int index = g_Coin_Drop_Model_Case == 3 ? GetRandomInt(0,sizeof(c_models)-1) : g_Coin_Drop_Model_Case;
			DispatchKeyValue(coin, "model", c_models[index]);
			float CoinPos[3];
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", CoinPos);
			// DispatchKeyValueVector(coin, "origin", CoinPos);
			DispatchKeyValue(coin, "solid", "0");
			DispatchKeyValue(coin, "spawnflags", "8454"); // "Don`t take physics damage" + "Generate output on +USE" + "Force Server Side" + "ignore player"
			DispatchSpawn(coin);
			char io[64];
			FormatEx(io, sizeof(io), "OnUser1 !self:kill::%d.0:-1", g_Coin_Drop_Clear_Time);
			SetVariantString(io);
			AcceptEntityInput(coin, "AddOutput");
			SetEntityRenderMode(coin, RENDER_TRANSCOLOR);
			if(g_Coin_Drop_Clear_Time >= 3){
				char io2[64];
				FormatEx(io2, sizeof(io2), "OnUser1 !self:AddOutput:renderfx 6:%d.0:-1", g_Coin_Drop_Clear_Time - 3);
				SetVariantString(io2);
				AcceptEntityInput(coin, "AddOutput");
			}
			AcceptEntityInput(coin, "FireUser1");
			if(g_Coin_Drop_Model_Alpha < 255){
				// SetEntityRenderMode(coin, RenderMode:3);
				SetEntityRenderColor(coin, 255, 255, 255, g_Coin_Drop_Model_Alpha);
			}

			if(g_Coin_Glow_Switch) createWeaponGlow(coin, g_Coin_Glow_Color, 2, g_Coin_Glow_Range);
			float force[3];
			force[0] = GetRandomFloat(-200.0, 200.0);
			force[1] = GetRandomFloat(-200.0, 200.0);
			force[2] = 800.0;
			float CoinAngle[3];
			CoinAngle[0] = GetRandomFloat(-180.0, 180.0);
			CoinAngle[1] = GetRandomFloat(-180.0, 180.0);
			CoinAngle[2] = GetRandomFloat(-180.0, 180.0);
			
			TeleportEntity(coin, CoinPos, CoinAngle, force);
		}
	}
	PrintToChatAll("%s \x04老逼登 \x03%N \x04爆金币啦!",SP_TAG, victim);
}

////////////////////////////////  sdkhook相关   ////////////////////////////////
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponDropPost , OnWeaponDropped);
}
public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_WeaponDropPost, OnWeaponDropped);
}
public void OnWeaponDropped(int client, int weapon)
{
	if (!IsValidEnt(weapon) || !isSurvivor(client) || !g_Weapon_Drop_Glow_Switch) return;
	if (GetClientHealth(client) > 0) {
		createWeaponGlow(weapon, "0 0 0", 2, g_Weapon_Drop_Glow_Range);
	}
	else {
		createWeaponGlow(weapon, g_Weapon_Drop_Glow_Color, 2, g_Weapon_Drop_Glow_Range);
	}
}
//////////////////////////////// 创建武器轮廓   ////////////////////////////////
public void createWeaponGlow(int weapon, char[] colors, int type, int range)
{
	SetEntProp(weapon, Prop_Send, "m_iGlowType", type);
	SetEntProp(weapon, Prop_Send, "m_glowColorOverride", GetColor(colors));
	SetEntProp(weapon, Prop_Send, "m_nGlowRange", range);
}

//////////////////////////////// func ////////////////////////////////
int entityCount(){
	int count = 0, ent = -1;
	while ((ent = FindEntityByClassname(ent, "*")) != -1)
	{
		count++;
	}
	if (DEBUG) PrintToChatAll("[debug] entity count: %d", count);
	return count;
}
int GetColor(char[] sTemp){
	if (strcmp(sTemp, "") == 0) return 0;
	char sColors[3][4];
	int	 iColor = ExplodeString(sTemp, " ", sColors, 3, 4);
	if (iColor != 3) return 0;
	iColor = StringToInt(sColors[0]);
	iColor += 256 * StringToInt(sColors[1]);
	iColor += 65536 * StringToInt(sColors[2]);
	return iColor;
}
bool isClientValid(int client, bool NoBot = true){
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	if (!IsClientInGame(client)) return false;
	if (NoBot){
		if (IsFakeClient(client)) return false;
	}
	return true;
}
bool isSurvivor(int client){
	return isClientValid(client) && GetClientTeam(client) == 2;
}
bool IsValidEnt(int entity){
	return (entity > 0 && entity > MaxClients && IsValidEntity(entity) && entity != INVALID_ENT_REFERENCE);
}