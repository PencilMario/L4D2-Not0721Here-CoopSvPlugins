//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>
#include <dhooks>
#include <l4d_path_to_goal>

#define PLUGIN_VERSION 			"1.58 2026-07-27"

public Plugin myinfo =
{
	name = "[L4D1/L4D2] Path To Goal",
	author = "gvazdas, zyiks",
	description = "Automatic path to goal indicator for Survivor team.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=352685, https://github.com/gvazdas/l4d2_zombie_master"
}

public void OnPluginStart()
{
    AutoExecConfig(true, CONFIG_FILENAME);
    LoadTranslations("l4d_path_to_goal.phrases");

    RegConsoleCmd("path_to_goal",       CmdRequestGuide, "Point where to go to progress in the map.");
    RegConsoleCmd("pathtogoal",         CmdRequestGuide, "Point where to go to progress in the map.");
    RegConsoleCmd("wheretogo",          CmdRequestGuide, "Point where to go to progress in the map.");
    RegConsoleCmd("imlost",             CmdRequestGuide, "Point where to go to progress in the map.");
    RegConsoleCmd("guide",              CmdRequestGuide, "Point where to go to progress in the map.");
    RegConsoleCmd("ptg",                CmdRequestGuide, "Point where to go to progress in the map.");

    g_bL4D2 = GetEngineVersion()==Engine_Left4Dead2;
    LoadSDK();
    
    RegAdminCmd("l4d_path_to_goal_recalculate", CmdRecalculate, ADMFLAG_ROOT,"Recalculate guide points.");
    RegAdminCmd("l4d_path_to_goal_print",       CmdPrint, ADMFLAG_ROOT,"Print g_GuideCells.");
    if (g_bL4D2) RegAdminCmd("l4d_path_to_goal_rescue", CmdRescue, ADMFLAG_ROOT,"Send in rescue vehicle.");
    RegAdminCmd("l4d_path_to_goal_ground", CmdGround, ADMFLAG_ROOT,"Check if origin is near ground.");
    #if DEBUG
    RegAdminCmd("l4d_path_to_goal_validate", CmdValidate, ADMFLAG_ROOT,"Print validation results for cell index if provided, or closest cell to player.");
    #endif
    RegAdminCmd("l4d_path_to_goal_recomputeflow", CmdRecomputeFlow, ADMFLAG_ROOT,"Force TerrorNavMesh::RecomputeFlowDistances to fire.");

    g_hCvarEnable = CreateConVar("l4d_path_to_goal_enable", "1",
    "0=OFF, 1=ON.",
    FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
  	
    g_hCvarMax = CreateConVar("l4d_path_to_goal_max", "32",
    "Max beams per request. Increasing this can potentially cause crashes for clients.",
    FCVAR_NOTIFY, true, 1.0, true, 1000.0);

    g_hCvarSurvivors = CreateConVar("l4d_path_to_goal_survivor", "1",
    "Allow survivors to request.",
    FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_hCvarInfected = CreateConVar("l4d_path_to_goal_infected", "1",
    "Allow infected to request.",
    FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_hCvarSpec = CreateConVar("l4d_path_to_goal_spec", "1",
    "Allow observers/spectators to request.",
    FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_hCvarAlive = CreateConVar("l4d_path_to_goal_alive", "0",
    "Allow request based on alive state: 0=all,1=alive only,2=dead only.",
    FCVAR_NOTIFY, true, 0.0, true, 2.0);

    g_hCvarBudget = CreateConVar("l4d_path_to_goal_budget", "0.5",
    "Max CPU budget (ms per frame) for escape route calculation. Larger budget makes requests available faster at the expense of server lag. 0 for infinite budget.",
    FCVAR_NOTIFY, true, 0.0, true, 1000.0);

    g_hCvarDetourBudget = CreateConVar("l4d_path_to_goal_detour_budget", "10.0",
    "Max CPU budget (ms) for detour beams. 0 for infinite budget.",
    FCVAR_NOTIFY, true, 0.0, true, 100.0);

    #if DEBUG
    SetConVarFloat(g_hCvarDetourBudget,0.0);
    #endif

    g_hCvarFinale = CreateConVar("l4d_path_to_goal_finale", "1",
    "On Finale maps, connect to rescue vehicle... 0: ALWAYS, 1: FINALE STARTED, 2: RESCUE ARRIVED, 3: NEVER",FCVAR_NOTIFY, true, 0.0, true, 3.0);

    g_hCvarFinaleAuto = CreateConVar("l4d_path_to_goal_finale_auto", "0",
    "Automatically draw beams to rescue vehicle for all clients. l4d_path_to_goal_finale must be less than 3.",FCVAR_NOTIFY, true, 0.0, true, 1.0);

  	g_hCvarMPGameMode = FindConVar("mp_gamemode");
  	g_hCvarMPGameMode.AddChangeHook(ConVarGameMode);
    
    t_nav = -1.0;
    Check_Guidable();
    GetCvars();
    
    nav_started = true;
    guide_prep = false;
    HookEvent("round_start_post_nav",     evtPostNav,        EventHookMode_PostNoCopy);
    HookEvent("nav_blocked",              evtNavBlocked,     EventHookMode_Post);
    HookEvent("nav_generate",             evtNavGenerate,    EventHookMode_PostNoCopy);
	HookEvent("finale_start", 			  evtFinaleStart,    EventHookMode_PostNoCopy);
	HookEvent("finale_radio_start", 	  evtFinaleStart,    EventHookMode_PostNoCopy);
    HookEvent("finale_vehicle_ready", 	  evtFinaleVehicle,  EventHookMode_PostNoCopy);
    if (g_bL4D2)
    {
    HookEvent("gauntlet_finale_start", 	  evtGauntletStart,  EventHookMode_PostNoCopy);
    HookEvent("finale_vehicle_incoming",  evtFinaleVehicle,  EventHookMode_PostNoCopy);
    }

}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    if(GetEngineVersion()!=Engine_Left4Dead2 && GetEngineVersion()!=Engine_Left4Dead)
	{
		strcopy(error,err_max,"Plugin only supports L4D1/L4D2.");
		return APLRes_SilentFailure;
	}
    MarkNativeAsOptional("L4D_NavArea_GetZ");
    MarkNativeAsOptional("L4D_NavArea_GetElevator");
    MarkNativeAsOptional("L4D_NavArea_IsBlocked");
    MarkNativeAsOptional("L4D_NavArea_GetCorner");
    MarkNativeAsOptional("L4D_NavArea_GetLadder");
    CreateNative("L4D_Path_To_Goal", Native_RequestGuide);
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
    elevator_available = GetFeatureStatus(FeatureType_Native,"L4D_NavArea_GetElevator")==FeatureStatus_Available;
    blocked_available = GetFeatureStatus(FeatureType_Native,"L4D_NavArea_IsBlocked")==FeatureStatus_Available;
    if (!elevator_available || !blocked_available) LogMessage("Please update l4dhooks for better performance.");
    if (g_bL4D2) g_hCvarZM = FindConVar("zm_enable"); // check if zombie master is active
}

void evtFinaleVehicle(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG
    LogMessage("evtFinaleVehicle");
    #endif
    if (finale) finale_rescue = true;
    if (!enable) return;
    if (finale_rescue && g_hCvarFinale.IntValue < FINALE_NEVER)
    {
        if (guide_ready && !finale_stitched && should_stitch_finale()) stitch_finale();
        if (g_hCvarFinaleAuto.BoolValue) CreateTimer(2.0, Timer_Guide_All_Clients, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

void evtFinaleStart(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG
    LogMessage("evtFinaleStart");
    #endif
    finale = true;
    if (guide_ready && !finale_stitched && should_stitch_finale()) stitch_finale();
}

void evtGauntletStart(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG
    LogMessage("evtGauntletStart");
    #endif
    finale = true;
    if (!use_gauntlet_logic() && finale_stitched) Guide_Cleanup(); // need to recalculate cells
    finale_gauntlet = true;
    if (!enable) return;
    if (guide_ready && !finale_stitched && should_stitch_finale()) stitch_finale();
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetCvars();
}

void evtPostNav(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG>1
        LogMessage("round_start_post_nav");
    #endif
    nav_started = true;
    finale = false;
    finale_rescue = false;
    finale_gauntlet = false;
    NavChanged();
}

void evtNavBlocked(Event event, const char[] name, bool dontBroadcast)
{
    if (!enable || !nav_started || !map_started) return;
    Address navArea = L4D_GetNavAreaByID(event.GetInt("area"));
    if (navArea == Address_Null) return;
    #if DEBUG>1
    bool blocked = event.GetBool("blocked");
    LogMessage("nav_blocked escape %d blocked %d area %d", navArea_escape(navArea), blocked, navArea);
    #endif
    if (!g_bFlowRecomputeHooked || finale) NavChanged();
}

void evtNavGenerate(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG>1
    LogMessage("nav_generate");
    #endif
    NavChanged();
}

void ConVarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	RequestFrame(Check_Guidable);
}

//int client_hint;

Action CmdRequestGuide(int client, int args)
{
    if (!enable || !map_started || !nav_started || !gamemode_guidable || !IsValidClient(client) || IsFakeClient(client)) return Plugin_Continue;
    float duration = 5.0;
    bool backward = GetClientTeam(client)!=TEAM_SURVIVOR;
    
    static char arg[16];
    int i = 0;
    g_sCustomKeys[client] = "              ";
    //g_GuidePrefs[client].Init();
    while (i>=0 && i<=10)
    {
        if (args>i) {GetCmdArg(i+1,arg,sizeof(arg)); process_cmd_arg(client,arg,duration,backward);}
        else break;
        i += 1;
    }

    switch (RequestGuide(client,duration,backward))
    {
        case true: // beams drawn
        {
            static float eye_client[3], ang_client[3], ang_beam[3];
            GetClientEyePosition(client,eye_client);

            float dx = FloatAbs(eye_client[0] - g_RequestFirstPos[0]);
            float dy = FloatAbs(eye_client[1] - g_RequestFirstPos[1]);
            if (dx<=5.0 && dy<=5.0) // Direction will be spurious if we are on the point
            {
                if (g_fRequestFlow>0.0) ReplyToCommand(client, "[PTG|%.0f|%.0f] %t%t", g_fRequestFlow, g_fMaxFlow, "ptg_look", "ptg_down");
                else ReplyToCommand(client, "[PTG] %t%t", "ptg_look", "ptg_down");
                return Plugin_Continue;
            }

            GetClientEyeAngles(client,ang_client);
    
            SubtractVectors(g_RequestFirstPos,eye_client,ang_beam);
            GetVectorAngles(ang_beam,ang_beam);  
            if (ang_beam[0] > 180.0) ang_beam[0] -= 360.0;
            if (ang_beam[1] > 180.0) ang_beam[1] -= 360.0;
            SubtractVectors(ang_beam,ang_client,ang_beam);
            //LogMessage("%.1f %.1f %.1f", ang_beam[0], ang_beam[1], ang_beam[2]);

            static char str1[PLATFORM_MAX_PATH], str2[PLATFORM_MAX_PATH];
            
            if (FloatAbs(ang_beam[1]) < 90.0) Format(str1,sizeof(str1),"%T", "ptg_ahead", client);
            else Format(str1,sizeof(str1),"%T", "ptg_behind", client);
            //else if ( FloatAbs(FloatAbs(ang_beam[1])-180.0) <= 45.0 ) Format(str1,sizeof(str1),"%T", "ptg_behind", client);
            //else if (ang_beam[1]>0.0) Format(str1,sizeof(str1),"%T", "ptg_left", client);
            //else Format(str1,sizeof(str1),"%T", "ptg_right", client);

            if (ang_beam[0]>=30.0) Format(str2,sizeof(str2),"%T", "ptg_down", client);
            else if (ang_beam[0]<=(-30.0)) Format(str2,sizeof(str2),"%T", "ptg_up", client);
            else str2 = "\0";
            if (g_fRequestFlow>0.0) ReplyToCommand(client, "[PTG|%.0f|%.0f] %t%s %s", g_fRequestFlow, g_fMaxFlow, "ptg_look", str1, str2);
            else ReplyToCommand(client, "[PTG] %t%s %s", "ptg_look", str1, str2);

            // Instructor Hint
            //client_hint = client;
            //int entity = CreateEntityByName("info_target"); 
            //DispatchKeyValue(entity, "targetname", "ptg_hint");
            //DispatchKeyValue(entity, "spawnflags", "2");
            //DispatchSpawn(entity);
            //TeleportEntity(entity, g_RequestFirstPos, NULL_VECTOR, NULL_VECTOR);
            //SDKHook(entity, SDKHook_SetTransmit, TransmitInfoTarget);
            //static char szBuffer[36];
            //Format(szBuffer, sizeof szBuffer, "OnUser1 !self:Kill::%f:-1", duration);
            //SetVariantString(szBuffer); 
            //AcceptEntityInput(entity, "AddOutput"); 
            //AcceptEntityInput(entity, "FireUser1");
            //entity = CreateEntityByName("env_instructor_hint");
            //DispatchKeyValueFloat(entity, "hint_timeout", duration);
            //DispatchKeyValue(entity, "hint_allow_nodraw_target", "1");
            //DispatchKeyValue(entity, "hint_target", "ptg_hint"); //a entity's targetname
            //DispatchKeyValue(entity, "hint_auto_start", "1");
            //DispatchKeyValue(entity, "hint_color", "255 255 255");
            //DispatchKeyValue(entity, "hint_icon_offscreen", "icon_door");
            //DispatchKeyValue(entity, "hint_instance_type", "2");
            //DispatchKeyValue(entity, "hint_icon_onscreen", "icon_door");
            //DispatchKeyValue(entity, "hint_caption", "PTG");
            //DispatchKeyValue(entity, "hint_static", "0");
            //DispatchKeyValue(entity, "hint_nooffscreen", "0");
            //DispatchKeyValue(entity, "hint_icon_offset", "0");
            //DispatchKeyValue(entity, "hint_range", "10000");
            //DispatchKeyValue(entity, "hint_forcecaption", "0");
            //DispatchKeyValue(entity, "hint_suppress_rest", "1");
            //DispatchSpawn(entity);
            //TeleportEntity(entity, g_RequestFirstPos, NULL_VECTOR, NULL_VECTOR); 
            //SetVariantString(szBuffer); 
            //AcceptEntityInput(entity, "AddOutput"); 
            //AcceptEntityInput(entity, "FireUser1");
        }
        default: // beams not drawn
        {
            if (!guide_ready && g_CellRequests[client].duration > 0.0) ReplyToCommand(client, "[PTG] %t", "ptg_wait");
        }
    }
    return Plugin_Continue;
}

//Action TransmitInfoTarget(int entity, int client)
//{
//	 if (client==client_hint)
//   {
//        static float pos1[3],pos2[3];
//        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos1);
//        GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos2); pos2[2] += 16.0;
//        if (GetVectorDistance(pos1,pos2,true)<=1024.0)
//        {
//            AcceptEntityInput(entity, "Kill");
//            return Plugin_Handled;
//        }
//        return Plugin_Continue;
//    }
//    return Plugin_Handled;
//}

// add custom flags for client from arg: duration, backward, g_sCustomKeys[client]
stock void process_cmd_arg(int client, char arg[16], float &duration, bool &backward)
{
    float duration_new = StringToFloat(arg);
    if (duration_new>=0.1)
    {
        duration = duration_new;
        return;
    }
    switch (CharToLower(arg[0]))
    {
        case 'a':
        {
            g_sCustomKeys[client][3] = 'a'; // arrow. beam increases in width from start to end
            return;
        }
        case 'b':
        {
            backward = true;
            return;
        }
        case 'c':
        {
            if (g_iLaserCustom!=0) g_sCustomKeys[client][0] = 'c'; // VMT_LASERBEAM_CUSTOM
            return;
        }
        case 'd':
        {
            g_sCustomKeys[client][4] = 'd'; // delay between beam draws, looks cool
            return;
        }
        case 's':
        {
            if (strncmp(arg,"small",5,false)==0) g_sCustomKeys[client][2] = 's'; // small beam size
            else if (strncmp(arg,"shake",5,false)==0) g_sCustomKeys[client][1] = 's'; // shake beam
            return;
        }
        case 'l':
        {
            g_sCustomKeys[client][2] = 'l'; // large beam size
            return;
        }
        case 'w':
        {
            if (g_iLaserWhite!=0) g_sCustomKeys[client][0] = 'w'; // VMT_LASERBEAM_WHITE
            return;
        }
    }
}

Action CmdRecalculate(int client, int args)
{
    if (!enable || !map_started || !nav_started || !gamemode_guidable) return Plugin_Continue;
    if (!guide_prep)
    {
        Guide_Cleanup();
        Guide_Prep();
    }
    else ReplyToCommand(client, "[PTG] %t", "ptg_busy");
    return Plugin_Continue;
}

Action CmdPrint(int client, int args)
{
    if (!guide_ready || g_GuideCells==null || g_GuideCells.Length<=0) return Plugin_Continue;
    static Cell cell;
    ReplyToCommand(client, "index navArea flow pos");
    for (int i = 0; i < g_GuideCells.Length; i++)
    {
        g_GuideCells.GetArray(i,cell,sizeof(Cell));
        ReplyToCommand(client, "%d %d %.1f (%.1f %1.f %.1f)", i, cell.navArea, cell.flow, cell.center[0], cell.center[1], cell.center[2]);
    }
    return Plugin_Continue;
}

#if DEBUG
Action CmdValidate(int client, int args)
{
    if (!guide_ready || g_GuideCells == null || g_GuideCells.Length<1) return Plugin_Continue;
    int i = 0;
    if (args>0)
    {
        i = GetCmdArgInt(1);
        if (i<0) i = 0;
        else if (i>=g_GuideCells.Length) i = g_GuideCells.Length-1;
    }
    else if (IsValidClient(client))
    {
        if (!RequestGuide(client,5.0,true)) return Plugin_Continue;
        i = g_iStart;
    }

    static Cell cell, cell_before, cell_after;
    
    g_GuideCells.GetArray(i,cell,sizeof(Cell));
    ReplyToCommand(client, "%d %d %.1f (%.1f %1.f %.1f)", i, cell.navArea, cell.flow, cell.center[0], cell.center[1], cell.center[2]);
    ReplyToCommand(client, "valid ground %d", valid_ground(cell.center));
    if (IsValidClient(client))
    {
        static float pos_down[3], pos_up[3];
        pos_down = cell.center; pos_down[2] -= 1000.0;
        pos_up = cell.center; pos_up[2] += 1000.0;
        DrawBeam(client,pos_down,pos_up);
    }
    bool cell_behind = (i-1)>=0;
    bool cell_ahead = (i+1)<g_GuideCells.Length;

    if (cell_behind)
    {
        g_GuideCells.GetArray(i-1,cell_before,sizeof(Cell));
        ReplyToCommand(client, "behind LOS %d (hit %d props %d flags %d name %s)",
        twopos_traversable(cell_before.center,cell.center), g_iHitEntity, g_iHitSurfaceProps, g_iHitSurfaceFlags, g_sHitSurfaceName);
    }
    if (cell_ahead)
    {
        g_GuideCells.GetArray(i+1,cell_after,sizeof(Cell));
        ReplyToCommand(client, "ahead LOS %d (hit %d props %d flags %d name %s)",
        twopos_traversable(cell_after.center,cell.center), g_iHitEntity, g_iHitSurfaceProps, g_iHitSurfaceFlags, g_sHitSurfaceName);
    }
    if (cell_behind && cell_ahead)
    {
        ReplyToCommand(client, "ahead-behind LOS %d (hit %d props %d flags %d name %s) mid-ground %d",
        twopos_traversable(cell_after.center,cell_before.center), g_iHitEntity, g_iHitSurfaceProps, g_iHitSurfaceFlags, g_sHitSurfaceName, midpoint_valid_ground(cell_after.center,cell_before.center));
    }
    return Plugin_Continue;
}
#endif

Action CmdRescue(int client, int args)
{
    L4D2_SendInRescueVehicle();
    return Plugin_Continue;
}

Action CmdGround(int client, int args)
{
    if (!IsValidClient(client) || IsFakeClient(client)) return Plugin_Stop;
    static float pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    ReplyToCommand(client,"Ground %d",valid_ground(pos));
    return Plugin_Continue;
}

Action CmdRecomputeFlow(int client, int args)
{
    if (g_hRecomputeFlow == null) return Plugin_Continue;
    Address ptr_navmesh = L4D_GetPointer(POINTER_NAVMESH);
    if (ptr_navmesh == Address_Null) return Plugin_Continue;
    SDKCall(g_hRecomputeFlow,ptr_navmesh);
    return Plugin_Continue;
}

public void OnMapStart()
{
	g_iLaser = PrecacheModel(VMT_LASERBEAM, true);
    g_iLaserWhite = PrecacheModel(VMT_LASERBEAM_WHITE, true);
    g_iLaserCustom = PrecacheModel(VMT_LASERBEAM_CUSTOM, true);
    RequestFrame(MapStarted);
    //GetCurrentMap(mapName, sizeof(mapName));
}

void MapStarted()
{
    map_started = true;
    t_nav = -1.0;
    timer_nav = null;
}

public void OnMapEnd()
{
    map_started = false;
    nav_started = false;
    t_nav = -1.0;
    Guide_Cleanup();
    guide_prep = false;
    g_iPrepStage = STAGE_NONE;
    beams_cooldown_reset(_,true); // reset all requests and cooldowns
    timer_nav = null;
    finale = false;
}

public void OnPluginEnd()
{
    Guide_Cleanup();
    guide_prep = false;
    g_iPrepStage = STAGE_NONE;
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client) || IsFakeClient(client)) return;
    beams_cooldown_reset(client,true); // reset cooldown and last request from client
    g_sCustomKeys[client] = "";
}

// NATIVE //

void Native_RequestGuide(Handle plugin, int numParams)
{
    if (!enable || !gamemode_guidable || !nav_started || !map_started) return;
    int client = (numParams>0) ? GetNativeCell(1) : -1;
    float duration = (numParams>1) ? view_as<float>(GetNativeCell(2)) : 5.0;
    bool backward = (numParams>2) ? view_as<bool>(GetNativeCell(3)) : false;
    bool join_client = (numParams>3) ? view_as<bool>(GetNativeCell(4)) : true;
    RequestGuide(client,duration,backward,join_client);
}