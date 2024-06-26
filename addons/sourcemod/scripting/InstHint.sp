#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define MODEL_MARK_FIELD 	"materials/sprites/laserbeam.vmt"

#define DeathTime 10.0
int g_iFieldModelIndex;
public Plugin myinfo = 
{
	name = "[L4D2] Skills Core",
	author = "BHaType",
	description = "Main Plugin",
	version = "0.0",
	url = "SDKCall"
};

Menu g_hMain;
ConVar cCooldown;
float g_flTime[MAXPLAYERS + 1];

static const char g_szText[][] =
{
	"走这里",
	"保持警惕",
	"这里有东西",
	"在这里防御",
	"危险！",
	"别去",
	"这里有机关",
	"我们有人太分散了"
};

public void OnPluginStart()
{
	g_hMain = new Menu(VMainHandler);
	g_hMain.AddItem("icon_door", "走这里");
	g_hMain.AddItem("icon_alert_red", "保持警惕");
	g_hMain.AddItem("icon_info", "这里有东西");
	g_hMain.AddItem("icon_shield", "在这里防御");
	g_hMain.AddItem("icon_skull", "危险！");
	g_hMain.AddItem("icon_no", "别去");
	g_hMain.AddItem("icon_button", "这里有机关");
	g_hMain.AddItem("icon_alert_red", "我们有人太分散了");
	g_hMain.SetTitle("提示：主菜单");
	AddCommandListener(Vocalize_Listener, "vocalize");

	cCooldown = CreateConVar("sm_hint_cooldown", "10.0", "Cooldown", 0);
	//AutoExecConfig(true, "l4d2_hint");
	RegConsoleCmd("sm_hint", cHint);
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
		g_flTime[i] = 0.0;
	g_iFieldModelIndex = PrecacheModel(MODEL_MARK_FIELD, true);
}

public Action Vocalize_Listener(int client, const char[] command, int argc)
{

	static char sCmdString[32];
	if (GetCmdArgString(sCmdString, sizeof(sCmdString)) > 1)
	{
		if (strncmp(sCmdString, "playerwaithere", 14, false) == 0)
		{
			FakeClientCommand(client, "sm_hint");
		}
	}
	

	return Plugin_Continue;
}


public Action cHint (int client, int args)
{
	if (!client)
		return Plugin_Handled;
		
	g_hMain.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int VMainHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Select )
	{
		//g_hMain.Display(client, MENU_TIME_FOREVER);
		
		if (GetGameTime() - g_flTime[client] < cCooldown.FloatValue)
		{
			PrintToChat(client, "\x04冷却时间 \x03%.2f", cCooldown.FloatValue - (GetGameTime() - g_flTime[client]));
			return;
		}
		
		static int iFixaw;
		iFixaw++;
		g_flTime[client] = GetGameTime();
		
		char szMenuItem[24], szTemp[64], szParent[36];
		menu.GetItem(index, szMenuItem, sizeof szMenuItem);

		float vOrigin[3], vAngles[3], vEnd[3];
			
		GetClientEyeAngles(client, vAngles);
		GetClientEyePosition(client, vOrigin);
		GetClientEyePosition(client, vEnd);
			
		Handle TraceRay = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilter, client);
				
		if (TR_DidHit(TraceRay))
			TR_GetEndPosition(vOrigin, TraceRay);
			float timeLimit = GetGameTime() + 20.0;
			float fieldDuration = (timeLimit - GetGameTime() < 1.0 ? timeLimit - GetGameTime() : 1.0);
			TE_SetupBeamPoints(vEnd, vOrigin, g_iFieldModelIndex, 0, 0, 0, 5.0, 2.0, 2.0, 1, 0.0, {255, 20, 147, 255}, 5);
			TE_SendToAll();
		vOrigin[2] += 25.0;
		delete TraceRay;

		Format(szTemp, sizeof szTemp, "%i_name", client * iFixaw);
		
		CreateTarget(vOrigin, szTemp, szParent);
		CreateInstructorHint(vOrigin, szTemp, szMenuItem, g_szText[index]);
		PrintToChatAll("\x03[\x04%N\x03] - \x05%s", client, g_szText[index]);
	}
}

public bool TraceFilter (int entity, int mask, int client)
{
	if (entity == client)
		return false;
	return true;
}

int CreateTarget(float vOrigin[3], const char[] name, const char[] parent)
{
	int entity = CreateEntityByName("info_target_instructor_hint");
	DispatchKeyValue(entity, "parentname", parent);
	DispatchKeyValue(entity, "targetname", name);
	DispatchSpawn(entity);
	TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
	
	char szBuffer[36];
	Format(szBuffer, sizeof szBuffer, "OnUser1 !self:Kill::%f:-1", DeathTime);

	SetVariantString(szBuffer); 
	AcceptEntityInput(entity, "AddOutput"); 
	AcceptEntityInput(entity, "FireUser1");
	
	return entity;
}

int CreateInstructorHint(float vOrigin[3], const char[] target, const char[] icon_name, const char[] text)
{
	int entity = CreateEntityByName("env_instructor_hint");
	DispatchKeyValue(entity, "hint_timeout", "10");
	DispatchKeyValue(entity, "hint_allow_nodraw_target", "1");
	DispatchKeyValue(entity, "hint_target", target);
	DispatchKeyValue(entity, "hint_auto_start", "1");
	DispatchKeyValue(entity, "hint_color", "255 20 147");
	DispatchKeyValue(entity, "hint_icon_offscreen", icon_name);
	DispatchKeyValue(entity, "hint_instance_type", "0");
	DispatchKeyValue(entity, "hint_icon_onscreen", icon_name);
	DispatchKeyValue(entity, "hint_caption", text);
	DispatchKeyValue(entity, "hint_static", "0");
	DispatchKeyValue(entity, "hint_nooffscreen", "0");
	DispatchKeyValue(entity, "hint_icon_offset", "15");
	DispatchKeyValue(entity, "hint_range", "0");
	DispatchKeyValue(entity, "hint_forcecaption", "1");
	DispatchSpawn(entity);
	TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "ShowHint");
	
	char szBuffer[36];
	Format(szBuffer, sizeof szBuffer, "OnUser1 !self:Kill::%f:-1", DeathTime);

	SetVariantString(szBuffer); 
	AcceptEntityInput(entity, "AddOutput"); 
	AcceptEntityInput(entity, "FireUser1");
}