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

#if defined _ptg_inc_included
 #endinput
#endif
#define _ptg_inc_included

/**
 * Draw survivor escape path in L4D1 or L4D2.
 *
 * @param client       Client entity index for which to draw beams. Must be a real in game client.
 * @param duration     Beam lifetime.
 * @param backward     Draw backwards-going path.
 * @param join_client  Visually connect client origin to nearest point in survivor path. Can be expensive.
 */
native void L4D_Path_To_Goal(int client = -1, float duration = 5.0, bool backward = false, bool join_client = true);

public SharedPlugin __pl_l4d_path_to_goal =
{
    name     = "l4d_path_to_goal",
    file     = "l4d_path_to_goal.smx",
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_path_to_goal_SetNTVOptional()
{
    MarkNativeAsOptional("L4D_Path_To_Goal");
}
#endif

#if defined _NATIVE_ONLY
 #endinput
#endif

#pragma semicolon 1
#pragma newdecls required

#define DEBUG 0 // 1 for basic debug, 2 for details, 3 for EXTREME amount of detail

#include <sourcemod>
#include <left4dhooks>
#include <dhooks>
#include <gvazdas_navmesh_utils>

#define PLUGIN_NAME			    "l4d_path_to_goal"
#define GAMEDATA_FILE           PLUGIN_NAME
#define CONFIG_FILENAME         PLUGIN_NAME

#define NAV_COOLDOWN 3.1416 // GameTime cooldown after nav events fire before Guide_Prep can be requested

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define VMT_LASERBEAM         "sprites/laserbeam.vmt"
#define VMT_LASERBEAM_WHITE   "sprites/white.vmt"
#define VMT_LASERBEAM_CUSTOM  "sprites/bloodspray.vmt"

ConVar g_hCvarAlive;
#define ACCEPT_ALL   0 // accept all players
#define ACCEPT_ALIVE 1 // accept only alive players
#define ACCEPT_DEAD  2 // accept only non-alive players

// Data structure for guide points
enum struct Cell
{
	float flow;
    Address navArea;
	float center[3]; // cell position slightly above ground
}

// How are two nav areas connected?
enum ConnectionType {
    CONNECTED_NOT = 0,
    CONNECTED_ADJACENT = 1, // dir
    CONNECTED_LADDER = 2, // ladder
    CONNECTED_ELEVATOR = 3 // elevator
};

// Connection to navArea
enum struct NavConnection
{
	Address navArea;
    ConnectionType connectiontype;
}

// GetNavConnections filter
#define CON_KEEP_ALL 0 // keep all adjacent connections
#define CON_KEEP_FORWARD 1 // keep only forward-going adjacent connections
#define CON_KEEP_BACKWARD 2 // keep only backwards-going adjacent connections

ArrayList g_GuideCells;
ConVar g_hCvarMPGameMode, g_hCvarEnable, g_hCvarMax, g_hCvarSurvivors, g_hCvarInfected, g_hCvarSpec, g_hCvarBudget, g_hCvarDetourBudget, g_hCvarFinaleAuto, g_hCvarZM;
bool gamemode_guidable, guide_ready, guide_prep, map_started, nav_started, enable, g_bL4D2, finale, finale_rescue, finale_gauntlet;
int g_iLaser, g_iLaserCustom, g_iLaserWhite;
float t_nav = -1.0; // nav event gametime
Handle timer_nav;
//char mapName[PLATFORM_MAX_PATH];
char g_sCustomKeys[MAXPLAYERS+1][PLATFORM_MAX_PATH]; // customization keys -> modify DrawBeam
float g_BeamDelay[MAXPLAYERS+1];

DynamicDetour g_hRecomputeFlowDetour;
Handle g_hRecomputeFlow;
bool g_bFlowRecomputeHooked;

bool finale_stitched; // finale guide was drawn
bool finale_backwards; // rescue vehicle is not at max flow -> flow cannot be used for guiding

bool elevator_available, blocked_available; // check fi l4dhooks is up to date

ConVar g_hCvarFinale;
#define FINALE_ALWAYS 0 
#define FINALE_STARTED 1
#define FINALE_RESCUE 2
#define FINALE_NEVER 3
bool g_bFoundRescueVehicle;
float g_fMaxFlow, g_fFlowRescueVehicle;

int color_forward[4] = {25,255,25,255};
int color_backward[4] = {128,10,10,128};

//bool g_bHitLadder = false; // kill me
#if DEBUG
int g_iHitEntity, g_iHitSurfaceProps, g_iHitSurfaceFlags;
char g_sHitSurfaceName[64];
#endif

bool is_prep_cooldown() // Prevent Guide_Prep() from firing if navmesh just changed
{
    if (t_nav<=0.0 || finale_rescue) return false;
    if ((t_nav+NAV_COOLDOWN)>GetGameTime()) return true;
    return false;
}

void GetCvars()
{
    if (enable != g_hCvarEnable.BoolValue)
    {
        enable = g_hCvarEnable.BoolValue;
        if (!enable && guide_ready) Guide_Cleanup();
        beams_cooldown_reset(_,true); // reset all requests and cooldowns
    }
}

// Player cooldown
enum struct PlayerTime
{
	float t_engine;
    float t_game;
    float t_cooldown;
}
PlayerTime g_PlayerTime[MAXPLAYERS+1];

// Data structure for requests to draw beams
enum struct CellRequest
{
	float duration;
    bool backward;
	bool join_client;
}
CellRequest g_CellRequests[MAXPLAYERS+1];

// Check if any client has a request queued after nav cooldown has expired or guide is ready to draw beams.
Action Timer_CheckRequests(Handle timer = null)
{
    // If both handles are null, allow to pass. Otherwise only allow expected handle through.
    if ( (timer != null || timer_nav != null) &&  timer != timer_nav) return Plugin_Stop;
    float t_left = (t_nav+NAV_COOLDOWN) - GetGameTime();
    if (t_left>0.0)
    {
        if (t_left<0.1) t_left = 0.1;
        timer_nav = CreateTimer(t_left,Timer_CheckRequests,_,TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }
    timer_nav = null;
    #if DEBUG>1
    LogMessage("Timer_CheckRequests");
    #endif
    if (!enable || !map_started || !nav_started || !gamemode_guidable || g_iLaser==0 || guide_prep) return Plugin_Stop;

    for (int i = 1; i <= MaxClients; i++) // Draw beams immediately for pending clients
    {
        if (g_CellRequests[i].duration <= 0.0) continue;
        if (!IsValidClient(i) || IsFakeClient(i))
        {
            g_CellRequests[i].duration = -1.0;
            continue;
        }
        if (guide_ready)
        {
            static CellRequest request;
            request = g_CellRequests[i];
            RequestGuide(i,request.duration,request.backward,request.join_client);
        }
        else
        {
            Guide_Prep();
            break;
        }
    }
    return Plugin_Stop;
}

// Draw beams for all clients. Use client's last duration for RequestGuide if available, or override=true to force duration.
void Guide_All_Clients(float duration = 5.0, bool override = false)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_CellRequests[i].duration>=0.1) continue; // already requested
        if (!override && g_PlayerTime[i].t_cooldown>0.1) g_CellRequests[i].duration = g_PlayerTime[i].t_cooldown*2.0;
        else g_CellRequests[i].duration = duration;
    }
    Timer_CheckRequests(null);
}

Action Timer_Guide_All_Clients(Handle timer = null, float duration = 5.0)
{
    Guide_All_Clients(duration);
    return Plugin_Continue;
}

// Use Gauntlet-type logic for stitching escape route with rescue vehicle.
bool use_gauntlet_logic()
{
    if (!finale) return false;
    return finale_gauntlet || g_hCvarFinale.IntValue == FINALE_ALWAYS;
}

int g_iClosestFlow, g_iClosestDist, g_iStart; // closest cell by flow, by distance, and final determination.
float g_RequestFirstPos[3]; // for hint system
float g_fRequestFlow; // for hint system
int g_iForward, g_iBackward; // temporary cell position for green and red beams

// Draw survivor path for client, for duration in seconds
// backward: include backwards-going path.
// join_client: draw connection between client's origin and nearest point in survivor path.
// return true if beams were drawn
bool RequestGuide(int client, float duration = 5.0, bool backward = false, bool join_client = true)
{
    #if DEBUG
    float t = GetEngineTime();
    #endif
    if (!enable || !map_started || !nav_started || !gamemode_guidable || duration<=0.0 || g_iLaser==0 || !IsValidClient(client) || IsFakeClient(client)) return false;

    int team = GetClientTeam(client);
    bool alive = IsPlayerAlive(client);

    bool whitelist = false; // L4D2 Zombie Master whitelist
    if (g_bL4D2 && g_hCvarZM!=null && g_hCvarZM.BoolValue && team!=TEAM_SURVIVOR)
    {
        whitelist = team==TEAM_INFECTED;
        if (!whitelist)
        {
            static char targetName[16];
            GetEntPropString(client, Prop_Data, "m_iName", targetName, sizeof(targetName));
            whitelist = strncmp(targetName,"zm_client",9,false) == 0;
        }
    }

    if (!whitelist) // Check if player is blocked from drawing beams
    {
        switch (team) // Check team
        {
            case TEAM_SPECTATOR:
            {
                if (!g_hCvarSpec.BoolValue) return false;
            }
            case TEAM_SURVIVOR:
            {
                if (!g_hCvarSurvivors.BoolValue) return false;
            }
            case TEAM_INFECTED:
            {
                if (!g_hCvarInfected.BoolValue) return false;
            }
        }

        if (g_hCvarAlive.IntValue>0) // 0 -> all states allowed
        {
            switch (alive)
            {
                case true:
                {
                    if (g_hCvarAlive.IntValue == ACCEPT_DEAD) return false; // only accepts dead players
                }
                default:
                {
                    if (g_hCvarAlive.IntValue == ACCEPT_ALIVE) return false; // only accepts alive players
                }
            }
        }
    }

    if (beams_cooldown(client)) return false;
    if (duration < 0.1) duration = 0.1; // prevent beams with infinite lifetime
    beams_cooldown_update(client,duration);

    // Store info of latest request from client
    g_CellRequests[client].join_client = join_client;
    g_CellRequests[client].duration = duration;
    g_CellRequests[client].backward = backward;
    g_BeamDelay[client] = 0.0;

    if (!guide_ready)
    {
        Guide_Prep();
        if (!guide_ready || g_GuideCells==null) return false;
    }
    else if (g_GuideCells==null || g_GuideCells.Length<=0) return false;

    static float last_pos[3], origin[3];

    bool self_origin = true;
    int target = client;
    if (!alive) // Check who their chase camera is set to. Take that origin instead.
    {
        int observermode = GetEntProp(client, Prop_Send, "m_iObserverMode");
        if (observermode==4 || observermode==5)
        {
            target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
            if (IsValidEntity(target) && target!=INVALID_ENT_REFERENCE)
            {
                self_origin = false;
                if (IsValidClient(target)) alive = IsPlayerAlive(target);
            }
            else target = client;
        }
    }
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", origin);
    float flow = L4D_GetFlowFromPoint(origin);

    g_iStart = -1;
    g_iClosestFlow = -1;
    g_iClosestDist = -1;

    Address navArea = L4D_GetNearestNavArea(origin,500.0,true,alive,false,TEAM_SURVIVOR);
    if (navArea != Address_Null)
    {
        g_iClosestFlow = g_GuideCells.FindValue(navArea,1);
        g_iStart = g_iClosestFlow;
        if (flow<=0.0)
        {
            L4D_GetNavAreaCenter(navArea,last_pos);
            flow = L4D_GetFlowFromPoint(last_pos);
        }
    }
    g_fRequestFlow = flow;

    last_pos = origin;
    if (alive || !self_origin) last_pos[2] += 16.0;
    if (alive)
    {
        switch (GetEntProp(target, Prop_Send, "m_nWaterLevel"))
        {
            case 1: last_pos[2] += 16.0;
            case 2: last_pos[2] += 32.0;
        }
    }
    else if (self_origin) last_pos[2] -= 16.0; // origin is client eye pos

    static Cell cell;

    bool use_flow = flow>0.0 && flow<=g_fMaxFlow && ( !finale_stitched || !finale_backwards || (use_gauntlet_logic() && flow<g_fFlowRescueVehicle) ); 

    if (g_iStart<0) // if we aren't standing on a guide cell, search all guide cells.
    {
        float min_dist = -1.0;
        float min_dist_flow = -1.0;
        float dist, dist_flow;
        for (int i = 0; i < g_GuideCells.Length; i++)
        {
            g_GuideCells.GetArray(i,cell,sizeof(Cell));
            bool end = true;
            //bool vecdist = false;
            if (min_dist<0.0 || min_dist>256.0) // end if very close cell already found
            {
                end = false;
                dist = GetVectorDistance(last_pos,cell.center,true);
                //vecdist = true;
                if (min_dist<0.0 || dist<min_dist)
                {
                    min_dist = dist;
                    g_iClosestDist = i;
                }
            }
            if (use_flow && min_dist_flow!=0.0) // exact flow match means we found the cell already
            {
                end = false;
                dist_flow = FloatAbs(cell.flow - flow);
                //if (vecdist && dist>(dist_flow*dist_flow)) continue;
                if (min_dist_flow<0.0 || dist_flow<min_dist_flow)
                {
                    min_dist_flow = dist_flow;
                    g_iClosestFlow = i;
                }
            }
            if (end) break;
        }
    }

    if (g_iClosestFlow==g_iClosestDist)
    {
        g_iClosestFlow = -1;
        g_iStart = g_iClosestDist;
    }
    else
    {
        g_iStart = (g_iClosestFlow>=0) ? g_iClosestFlow : g_iClosestDist;
    }
    g_iForward = g_iStart;
    g_iBackward = g_iStart;
    int i_draw = 0; // how many beams were drawn

    // Try cell splitting technique first. If it fails try usual LOS adjustments
    static float pos_split[3];
    bool LOS = false;
    bool found_split = try_guide_cellsplit(last_pos,pos_split,g_iForward) && twopos_traversable(last_pos,pos_split);
    if (found_split)
    {
        if (g_iForward>=g_GuideCells.Length) g_iForward = g_GuideCells.Length - 1;
        g_iBackward = g_iForward - 1;
        if (join_client) i_draw += DrawBeam(client,last_pos,pos_split,duration,color_forward,256.0);
        g_GuideCells.GetArray(g_iForward,cell,sizeof(Cell));
        i_draw += DrawBeam(client,pos_split,cell.center,duration,color_forward);
        if (backward && g_iBackward>=0)
        {
            g_GuideCells.GetArray(g_iBackward,cell,sizeof(Cell));
            i_draw += DrawBeam(client,cell.center,pos_split,duration,color_backward);
        }
        last_pos = pos_split;
        LOS = true;
        g_iStart = g_iForward;
    }

    if (!LOS) LOS = cell_traversable(g_iStart,last_pos);

    // Try starting at a more reasonable position with LOS
    if (!found_split)
    {
        if ( (join_client || !LOS) && (g_iStart+1)<g_GuideCells.Length && cell_traversable(g_iStart+1,last_pos,_,250.0))
        {
            g_iStart += 1; // Move forward
            LOS = true;
        }
        else if (g_iStart>0 && !LOS && cell_traversable(g_iStart-1,last_pos,_,250.0))
        {
            g_iStart -=1; // Move backward
            LOS = true;
        }
        g_iForward = g_iStart;
        g_iBackward = g_iStart;
    }

    g_GuideCells.GetArray(g_iForward,cell,sizeof(Cell));

    if (join_client) // Connect client to starting cell
    {
        int num_beams = (!LOS && navArea!=Address_Null) ? detour_join(client,navArea,last_pos,flow,duration,team) : 0;
        if (num_beams<=0)
        {
            if (!found_split && GetVectorDistance(last_pos,cell.center,true)>=256.0)
            {
                DrawBeam(client,last_pos,cell.center,duration,color_forward);
                i_draw += 1;
            }
            g_RequestFirstPos = cell.center;
        }
        else
        {
            g_GuideCells.GetArray(g_iForward,cell,sizeof(Cell)); // detour_join may have changed g_iForward
            i_draw += num_beams;
        }
    }
    if (i_draw<g_hCvarMax.IntValue) // detour_join may have hit beam limit
    {
        static float pos_forward[3], pos_backward[3];
        g_GuideCells.GetArray(g_iForward,pos_forward,3,2);
        g_GuideCells.GetArray(g_iBackward,pos_backward,3,2);
        bool end = false;
        while (!end && i_draw<g_hCvarMax.IntValue)
        {
            end = true;
            if ((g_iForward+1)<g_GuideCells.Length)
            {
                g_iForward += 1;
                g_GuideCells.GetArray(g_iForward,cell,sizeof(Cell));
                DrawBeam(client,pos_forward,cell.center,duration,color_forward);
                pos_forward = cell.center;
                end = false;
                i_draw += 1;
                if (i_draw>=g_hCvarMax.IntValue) break;
            }
            if (backward && g_iBackward>0)
            {
                g_iBackward -= 1;
                g_GuideCells.GetArray(g_iBackward,cell,sizeof(Cell));
                DrawBeam(client,cell.center,pos_backward,duration,color_backward);
                pos_backward = cell.center;
                end = false;
                i_draw += 1;
            }
        }
    }
    if (i_draw>0)
    {
        #if DEBUG
        LogMessage("RequestGuide: client %d flow %f cells %d g_iStart %d (%f ms)", client, flow, i_draw, g_iStart, (GetEngineTime()-t)*1000.0);
        #endif
        return true;
    }
    return false;
}

ArrayList i_candidates,i_explored;

// See if pos can be connected to a split inbetween two cells. return true on success
// Outputs pos_split, and sets correct i_forward (closest first green cell)
stock bool try_guide_cellsplit(float pos[3],float pos_split[3], int &i_forward)
{
    if (g_GuideCells.Length<=1) return false;
    if (i_candidates==null) i_candidates = new ArrayList();
    if (i_explored==null) i_explored = new ArrayList();
    i_candidates.Clear();
    i_explored.Clear();

    // Each index in i_candidates will be g_iBackward from which split is drawn towards i_forward
    if (g_iClosestFlow>=0)
    {
        if (g_iClosestFlow < (g_GuideCells.Length-1)) i_candidates.Push(g_iClosestFlow);
        if (g_iClosestFlow>0) i_candidates.Push(g_iClosestFlow-1);
        if (g_iClosestDist < 0) // search more
        {
            if (g_iClosestFlow < (g_GuideCells.Length-2)) i_candidates.Push(g_iClosestFlow+1);
            if (g_iClosestFlow>1) i_candidates.Push(g_iClosestFlow-2);
        }
    }
    if (g_iClosestDist>=0 && g_iClosestDist!=g_iClosestFlow)
    {
        if (g_iClosestDist < (g_GuideCells.Length-1)) i_candidates.Push(g_iClosestDist);
        if (g_iClosestDist>0) i_candidates.Push(g_iClosestDist-1);
        if (g_iClosestFlow < 0) // search more
        {
            if (g_iClosestDist < (g_GuideCells.Length-2)) i_candidates.Push(g_iClosestDist+1);
            if (g_iClosestDist>1) i_candidates.Push(g_iClosestDist-2);
        }
    }

    float dist;
    float best_dist = -1.0;
    static float pos_temp[3], pos_start[3], pos_end[3];
    int i_cell, i_forward_best;
    for (int i = 0; i < i_candidates.Length; i++)
    {
        i_cell = i_candidates.Get(i);
        if (i_explored.FindValue(i_cell)>=0) continue;
        i_explored.Push(i_cell);
        g_GuideCells.GetArray(i_cell,pos_start,3,2);
        dist = GetVectorDistance(pos,pos_start,true);
        if (best_dist<0.0 || dist<best_dist)
        {
            i_forward_best = i_cell+1; pos_split = pos_start;
            best_dist = dist; if (best_dist<=256.0) break; // if very close to client position, we found our answer
        }
        g_GuideCells.GetArray(i_cell+1,pos_end,3,2);
        dist = GetVectorDistance(pos,pos_end,true);
        if (best_dist<0.0 || dist<best_dist)
        {
            i_forward_best = i_cell+1+1; pos_split = pos_end;
            best_dist = dist; if (best_dist<=256.0) break; // if very close to client position, we found our answer
        }
        if (!project_forward(pos_start,pos_end,pos,pos_temp)) continue;
        dist = GetVectorDistance(pos,pos_temp,true);
        if (best_dist<0.0 || dist<best_dist)
        {
            i_forward_best = i_cell+1; pos_split = pos_temp;
            best_dist = dist; if (best_dist<=256.0) break; // if very close to client position, we found our answer
        }
    }
    if (best_dist>=0.0)
    {
        i_forward = i_forward_best;
        return true;
    }
    return false;
}

// Find closest guide cell for given flow value. 
// If check_LOS, wiggle cell forward/backward to improve LOS for given vector position
int get_flow_iStart(float flow, bool check_LOS = true, float pos[3])
{
    int i_start = 0;
    static Cell cell;
    for (int i = 0; i < g_GuideCells.Length; i++)
    {
        g_GuideCells.GetArray(i,cell,sizeof(Cell));
        if ( cell.flow >= flow )
        {
            i_start = i;
            break;
        }
    }
    if (check_LOS)
    {
        if ((i_start+1)<g_GuideCells.Length && cell_traversable(i_start+1,pos,_,250.0))
        {
            i_start += 1; // Move forward
        }
        else if (i_start>0 && !cell_traversable(i_start,pos) && cell_traversable(i_start-1,pos,_,250.0))
        {
            i_start -=1; // Move backward
        }
    }
    return i_start;
}

ArrayList ConAdj, AdjNN, queue;
ArrayList explored;

// detour client_join, return how many beams were drawn
int detour_join(int client, Address navArea, float pos[3], float flow, float duration, int team = TEAM_SURVIVOR)
{
    float t = GetEngineTime();
    #if DEBUG>1
    LogMessage("detour_join %f", flow);
    #endif

    float budget = g_hCvarDetourBudget.FloatValue;

    float flow_target = g_fMaxFlow;
    bool explore_backwards = false;
    if (finale && finale_stitched && finale_backwards)
    {
        explore_backwards = true;
        flow_target = g_fFlowRescueVehicle;
    }

    static float pos_curr[3], pos_last[3];
    float flow_curr = flow;
    float d_flow_curr = FloatAbs(flow-flow_target);
    pos_curr = pos;
    if (ConAdj==null) ConAdj = new ArrayList(sizeof(NavConnection));
    if (AdjNN==null) AdjNN = new ArrayList(); // nearest neighbor explore for dips in flow when about to climb a ladder
    if (queue==null) queue = new ArrayList(3);
    if (explored==null) explored = new ArrayList();
    explored.Clear();
    queue.Clear();
    queue.PushArray(pos);
        
    Address navArea_curr = navArea;
    float flow_temp, flow_best, dz, dz_best, d_flow_temp;
    static float pos_temp[3], pos_best[3], pos_split[3], pos_end[3];
    Address navArea_best;
    bool best_steep = false;
    float d_flow_best = d_flow_curr;
    int i;
    static Cell cell;
    int i_found;

    bool success = false;
    while (navArea_curr != Address_Null)
    {
        bool found = false;
        flow_best = flow_curr;
        d_flow_best = d_flow_curr;
        best_steep = false; 
        int count = GetNavConnections(navArea_curr,ConAdj,team,true,true,true,CON_KEEP_FORWARD);
        static NavConnection nav_connection;
        for (i = 0; i < count; i++)
        {
            ConAdj.GetArray(i,nav_connection,sizeof(NavConnection));
            if (nav_connection.navArea == Address_Null || nav_connection.connectiontype <= CONNECTED_NOT) continue;
            if (nav_connection.navArea == navArea_curr) continue;
            if (explored.FindValue(nav_connection.navArea)>=0) continue;
            explored.Push(nav_connection.navArea);
            if (blocked_available && L4D_NavArea_IsBlocked(nav_connection.navArea,team,true)) continue;
            flow_temp =  L4D2Direct_GetTerrorNavAreaFlow(nav_connection.navArea);
            d_flow_temp = FloatAbs(flow_temp-flow_target);
            #if DEBUG>1
                LogMessage("detour_join %d %.1f try %d %d %.1f", navArea_curr, flow_curr, nav_connection.connectiontype, nav_connection.navArea, flow_temp);
            #endif
            int count2 = navArea_ladder_navAreas(nav_connection.navArea,AdjNN,team); // ladder intervention. flow dips when stepping onto ladder navmeshes...
            for (int i2 = 0; i2 < count2; i2++)
            {
                Address adjArea = AdjNN.Get(i2);
                if (adjArea == Address_Null || adjArea == navArea_curr || adjArea == nav_connection.navArea) continue;
                float new_flow = L4D2Direct_GetTerrorNavAreaFlow(adjArea);
                float new_d_flow = FloatAbs(new_flow-flow_target);
                if (new_d_flow<d_flow_temp)
                {
                    #if DEBUG>1
                    LogMessage("Ladder intervention %.1f -> %.1f", flow_temp, new_flow);
                    #endif
                    d_flow_temp = new_d_flow;
                }
            }
            if (d_flow_temp>d_flow_curr) continue;
            L4D_GetNavAreaCenter(nav_connection.navArea,pos_temp); pos_temp[2] += 16.0;
            dz = pos_temp[2] - pos_curr[2];
            bool steep = nav_connection.connectiontype == CONNECTED_ADJACENT && nav_too_steep(navArea_curr,nav_connection.navArea);
            if (found && steep)
            {
                if (!best_steep || dz>dz_best)
                {
                    #if DEBUG>1
                    LogMessage("detour_join steep or dz skip");
                    #endif
                    continue; // prefer to go down than up
                }
            }
            else if (!steep)
            {
                int spawnAttrs = L4D_GetNavArea_SpawnAttributes(nav_connection.navArea);
                success = (!explore_backwards && spawnAttrs & NAV_SPAWN_ESCAPE_ROUTE) || (finale_stitched && spawnAttrs & NAV_SPAWN_RESCUE_VEHICLE);
            }
            if ( success || d_flow_temp<=d_flow_best || (best_steep && d_flow_temp<=d_flow_curr ) )
            {
                flow_best = flow_temp;
                d_flow_best = d_flow_temp;
                navArea_best = nav_connection.navArea;
                pos_best = pos_temp;
                found = true;
                best_steep = steep;
                dz_best = dz;
                if (success) break;
            }
        }

        if (!found) // Try searching for unconnected ladders in vicinity
        {
            if (try_ladder(flow_curr,pos_curr,cell))
            {
                found = true;
                flow_best = cell.flow;
                navArea_best = cell.navArea;
                pos_best = cell.center;
            }
        }

        if (found)
        {
            if (pos_underwater(pos_best))
            {
                pos_best[2] += 16.0;
                if (pos_underwater(pos_best)) pos_best[2] += 16.0;
            }
            bool LOS = twopos_traversable(pos_curr,pos_best);
            if (!LOS)
            {
                static float pos_lifted[3];
                pos_lifted = pos_best;
                pos_lifted[2] += 16.0;
                LOS = twopos_traversable(pos_curr,pos_lifted);
                if (LOS) pos_best = pos_lifted;
            }
            if (!LOS)
            {
                static float pos_mid[3];
                if (LOS_rescue_cheap(pos_curr,pos_best,pos_mid)) queue.PushArray(pos_mid);
                else if (queue.Length == 1) // Try nav center of client origin
                {
                    L4D_GetNavAreaCenter(navArea,pos_mid);
                    pos_mid[2] += 16.0;
                    if (pos_underwater(pos_mid)) pos_mid[2] += 32.0;
                    if (twopos_traversable(pos_curr,pos_mid) && twopos_traversable(pos_best,pos_mid)) queue.PushArray(pos_mid);
                }
                queue.PushArray(pos_best);
            }
            else if (queue.Length>1)
            {
                queue.GetArray(queue.Length-2,pos_last,3);
                if (twopos_traversable(pos_best,pos_last) && midpoint_valid_ground(pos_last,pos_best)) queue.SetArray(queue.Length-1,pos_best,3);
                else queue.PushArray(pos_best);
            }
            else queue.PushArray(pos_best);
            #if DEBUG>1
            LogMessage("detour_join found %d %.1f -> %d %.1f", navArea_curr, flow_curr, navArea_best, flow_best);
            #endif
            pos_curr = pos_best;
            navArea_curr = navArea_best;
            flow_curr = flow_best;
            d_flow_curr = d_flow_best;
            
            i_found = g_GuideCells.FindValue(navArea_best,1);
            if (!success)
            {
                success = i_found>=0;
                if (!success)
                {
                    success = !explore_backwards && queue.Length >= g_hCvarMax.IntValue;
                    if (!success)
                    {
                        int spawnAttrs = L4D_GetNavArea_SpawnAttributes(navArea_curr);
                        success = (!explore_backwards && spawnAttrs & NAV_SPAWN_ESCAPE_ROUTE) || (finale_stitched && spawnAttrs & NAV_SPAWN_RESCUE_VEHICLE);
                    }
                }
            }
            if (success)
            {
                g_iStart = (i_found>=0) ? i_found : get_flow_iStart(flow_curr,true,pos_curr);
                g_iClosestFlow = g_iStart;
                g_iClosestDist = g_iStart;
                if (i_found<0 && try_guide_cellsplit(pos_curr,pos_split,g_iForward) && twopos_traversable(pos_curr,pos_split))
                {
                    g_iBackward = g_iForward - 1;
                    g_iStart = g_iForward;
                }
                else
                {
                    g_iForward = g_iStart; g_iBackward = g_iStart;
                }
                #if DEBUG>1
                LogMessage("detour_join success flow %f i_forward %d i_backward %d", flow_curr, g_iForward, g_iBackward);
                #endif
                g_GuideCells.GetArray(g_iForward,cell,sizeof(Cell));
                if (g_iForward == g_iBackward) pos_end = cell.center;
                else pos_end = pos_split;
                if (queue.Length>1 && twopos_traversable(pos_curr,pos_end))
                {
                    queue.GetArray(queue.Length-2,pos_last,3);
                    if (twopos_traversable(pos_last,pos_end)) queue.Erase(queue.Length-1);
                }
                break;
            }
        }

        if (!found || success) break;

        if ( budget>0.0 && ((GetEngineTime()-t)*1000.0)>budget )
        {
            #if DEBUG
            LogMessage("detour_join exceeded budget");
            #endif
            break;
        }

    }

    int beams = 0; 
    if (success) // Path found, draw beams.
    {
        queue.GetArray(0,pos_curr,3);
        for (i = 1; i < queue.Length; i++)
		{
			queue.GetArray(i,pos_temp,3);
            beams += DrawBeam(client,pos_curr,pos_temp,duration,color_forward);
            pos_curr = pos_temp;
            if (beams==1) g_RequestFirstPos = pos_curr;
            if (beams>=g_hCvarMax.IntValue) break;
        }
        if (beams<g_hCvarMax.IntValue)
        {
            if (g_iForward==g_iBackward) beams += DrawBeam(client,pos_curr,pos_end,duration,color_forward);
            else
            {
                beams += DrawBeam(client,pos_curr,pos_split,duration,color_forward);
                beams += DrawBeam(client,pos_split,cell.center,duration,color_forward);
                if (g_CellRequests[client].backward && g_iBackward>=0)
                {
                    g_GuideCells.GetArray(g_iBackward,cell,sizeof(Cell));
                    beams += DrawBeam(client,cell.center,pos_split,duration,color_backward);
                }
            }
        }
    }

    #if DEBUG
    LogMessage("detour_join %f ms, %d beams", (GetEngineTime()-t)*1000.0, beams);
    #endif

    return beams;
}

// Data structure for beam client preferences
//enum struct GuidePref
//{
//	int ModelIndex;
//    int HaloIndex;
//    float duration;
//    float amp;
//    float start_width;
//    float end_width;
//    int color_forward[4];
//    int color_backward[4];
//    void Init()
//    {
//        this.ModelIndex = g_iLaser;
//        this.HaloIndex = 0;
//        this.duration = 5.0;
//        this.amp = 0.0;
//        this.start_width = 1.5;
//        this.end_width = 1.5;
//        this.color_forward = color_forward;
//        this.color_backward = color_backward;
//    }
//}

//GuidePref g_GuidePrefs[MAXPLAYERS+1];

// Draw beam with given color for client from pos_start to pos_end for duration. Don't draw if distance squared is below min_dist_sq.
// Return number of drawn beams.
int DrawBeam(int client, float pos_start[3], float pos_end[3], float duration = 5.0, int color[4] = {25,255,25,255}, float min_dist_sq = -1.0)
{
    if (g_iLaser==0) return 0;
    if (min_dist_sq>0.0 && GetVectorDistance(pos_start,pos_end,true)<min_dist_sq) return 0;
    if (duration<0.1) duration = 0.1;
    float start_width = 1.5;
    int fade_length = 10;
    float amp = 0.0;
    
    // Set .vmt to draw
    int laser = g_iLaser;
    if (g_sCustomKeys[client][0]!=0)
    {
        if (g_sCustomKeys[client][0]=='c' && g_iLaserCustom!=0) laser = g_iLaserCustom;
        else if (g_sCustomKeys[client][0]=='w' && g_iLaserWhite!=0) laser = g_iLaserWhite;
    }
    
    // Set "shake"
    if (g_sCustomKeys[client][1]=='s') amp = 1.0;
    
    // Set thickness
    if (g_sCustomKeys[client][2]!=0)
    {
        if (g_sCustomKeys[client][2]=='l') start_width *= 2.0; // large
        else if (g_sCustomKeys[client][2]=='s') start_width /= 2.0; // small
    }

    // Set "arrow"
    float end_width = start_width*1.05;
    if (g_sCustomKeys[client][3]=='a')
    {
        start_width /= 1.25;
        end_width = 1.5*start_width;
    }

    #if DEBUG>2
    LogMessage("client %d duration %f laser %d custom %s", client, duration, laser, g_sCustomKeys[client]);
    #endif
    TE_SetupBeamPoints(pos_start,pos_end,laser,0,0,0,duration,start_width,end_width,fade_length,amp,color,0);
    TE_SendToClient(client,g_BeamDelay[client]);
    if (g_sCustomKeys[client][4]=='d') g_BeamDelay[client] += 0.05;
    return 1;
}

void Check_Guidable()
{
    gamemode_guidable = !L4D_IsSurvivalMode();
    if (gamemode_guidable && g_bL4D2) gamemode_guidable = !L4D2_IsScavengeMode();
    if (!map_started || !nav_started) return;
    if (guide_ready && !gamemode_guidable) Guide_Cleanup();
}

#define STAGE_NONE 0 // Prep not running
#define STAGE_PREP 1 // First frame of Prep
#define STAGE_COLLECT 2 // Get all ESCAPE_ROUTE, CHECKPOINT, PLAYER_START and RESCUE_VEHICLE navmeshes
#define STAGE_SORT 3 // Sort ESCAPE_ROUTE by flow
#define STAGE_FIX 4 // Clean up bad connections between navmeshes. Certified Valve Product Moment (TM)
#define STAGE_BUILD 5 // Build static g_GuideCells with continuity and line-of-sight.
#define STAGE_FINALE 6 // If there is RESCUE_VEHICLE
#define STAGE_VALIDATE 7 // Tighten connections between cells, remove cells with mutual LOS.
#define STAGE_END 8 // Guide ready.

int g_iPrepStage, g_iLoop;
float g_fFlowStart, g_fFlowCheckpoint, g_tFrameStart;
ArrayList allAreas, all_cells, RescueVehicleCells;
bool g_bMissingStart, g_bMissingCheckpoint, g_bFoundStart, g_bFoundCheckpoint;
Address g_aNavStart, g_aNavCheckpoint, g_aNavRescueVehicle;


#if DEBUG
float g_fPrepTotalTime;
int g_iPrepFrames, g_iErased, g_iNavBlocked, g_iTotalCollected, g_iTighten;
#endif

void Guide_Prep()
{
    if (!enable || !gamemode_guidable || !map_started || !nav_started || guide_prep || is_prep_cooldown()) return;
    #if DEBUG>1
    LogMessage("Guide_Prep");
    #endif
    guide_prep = true;
    g_iPrepStage = STAGE_PREP;
    #if DEBUG
    g_iPrepFrames = 0;
    #endif
    timer_nav = null;
    OnFramePrep(true);
}

void Guide_Cleanup()
{
    g_iPrepStage = STAGE_NONE; // tell guide prep to cancel
    if (guide_ready)
    {
        #if DEBUG>1
        LogMessage("Guide_Cleanup");
        #endif
        guide_ready = false;
        delete g_GuideCells;
    }
}

bool frame_budget_exceeded()
{
    if (g_hCvarBudget.FloatValue <= 0.0) return false;
    float dt_ms = (GetEngineTime()-g_tFrameStart)*1000.0;
    bool exceeded = dt_ms >= g_hCvarBudget.FloatValue;
    return exceeded;
}

ArrayList explored_finale;

void OnFramePrep(bool new_frame = true)
{
    if (!enable || guide_ready || !gamemode_guidable || !map_started || !nav_started || g_iPrepStage<=STAGE_NONE || g_iPrepStage>=STAGE_END)
    {
        guide_prep = false;
        g_iPrepStage = STAGE_NONE;
        timer_nav = null;
        return;
    }
    static float pos[3];
    float flow;
    static Cell cell, cell_before, cell_after;
    Address navArea;
    bool budget_spent = false; // same variable for all stages
    if (new_frame)
    {
        #if DEBUG
        g_iPrepFrames += 1;
        #if DEBUG>2
        LogMessage("OnFramePrep %d %d", g_iPrepFrames, g_iPrepStage);
        #endif
        #endif
        g_tFrameStart = GetEngineTime();
    }
    switch (g_iPrepStage)
    {
        case STAGE_PREP:
        {

            g_fMaxFlow = L4D2Direct_GetMapMaxFlowDistance();
            if (g_fMaxFlow<=0.0)
            {
                guide_prep = false;
                g_iPrepStage = STAGE_NONE;
                #if DEBUG
                    LogMessage("WARNING: L4D2Direct_GetMapMaxFlowDistance returned <=0.0");
                #endif
                return;
            }

            delete allAreas;
            allAreas = new ArrayList();
            L4D_GetAllNavAreas(allAreas);
            if (allAreas.Length<=1)
            {
                delete allAreas;
                guide_prep = false;
                #if DEBUG
                    LogMessage("WARNING: L4D_GetAllNavAreas returned no areas");
                #endif
                return;
            }


            g_fFlowRescueVehicle = -1.0;
            g_bFoundRescueVehicle = false;

            delete all_cells;
            all_cells = new ArrayList(sizeof(Cell)); // Collect nav areas in survivor path
            
            delete g_GuideCells;
            g_GuideCells = new ArrayList(sizeof(Cell));

            delete RescueVehicleCells;
            RescueVehicleCells = new ArrayList(sizeof(Cell));

            g_bMissingStart = true; // do we have a confirmed start area navmesh in g_GuideCells?
            g_bMissingCheckpoint = true; // do we have a confirmed end area navmesh in g_GuideCells?
            
            g_bFoundStart = false;
            g_bFoundCheckpoint = false;
            
            g_fFlowStart = g_fMaxFlow;
            g_fFlowCheckpoint = 0.0;

            finale_stitched = false;
            finale_backwards = false;

            g_iLoop = 0;
            #if DEBUG
            g_fPrepTotalTime = 0.0;
            g_iErased = 0;
            g_iNavBlocked = 0;
            g_iTotalCollected = 0;
            g_iTighten = 0;
            #endif
        }
        case STAGE_COLLECT:
        {
            if (allAreas==null || all_cells==null)
            {
                guide_prep = false;
                return;
            }
            while (g_iLoop<allAreas.Length)
            {
                if (frame_budget_exceeded()) { budget_spent = true; break; }
                navArea = allAreas.Get(g_iLoop);
                g_iLoop += 1;
                if (!navArea) continue;
                flow = L4D2Direct_GetTerrorNavAreaFlow(navArea);
                //if (flow>g_fMaxFlow) continue;
                int navSpawnAttrs = L4D_GetNavArea_SpawnAttributes(navArea);
                bool rescue = (navSpawnAttrs & NAV_SPAWN_RESCUE_VEHICLE) > 0;
                //if (rescue && flow <= 0.0)
                //{
                //    rescue = false;
                //    LogMessage("NAV_SPAWN_RESCUE_VEHICLE at <= 0.0 flow! BOOOOOO! THROW TOMATOES AT THE MAPPER!");
                //}

                if (rescue && g_hCvarFinale.IntValue < FINALE_NEVER) // Rescue navareas might be blocked until rescue vehicle arrives.
                {
                    if (flow>g_fFlowRescueVehicle)
                    {
                        g_bFoundRescueVehicle = true;
                        g_fFlowRescueVehicle = flow;
                        g_aNavRescueVehicle = navArea;
                    }
                }

                if (blocked_available && L4D_NavArea_IsBlocked(navArea,TEAM_SURVIVOR,true))
                {
                    #if DEBUG
                    g_iNavBlocked += 1;
                    #endif
                    continue;
                }

                bool checkpoint = navSpawnAttrs & NAV_SPAWN_PLAYER_START || navSpawnAttrs & NAV_SPAWN_CHECKPOINT;

                if (flow >= 0.0 && navSpawnAttrs & NAV_SPAWN_ESCAPE_ROUTE)
                {
                    
                    int i_found = all_cells.FindValue(flow,0);
                    if (i_found>=0)
                    {
                        #if DEBUG
                        LogMessage("STAGE_COLLECT WARNING: %d flow %f identical to %d", g_iLoop, flow, i_found);
                        #endif
                        continue; // if identical flow exists, ignore this cell
                    }
                    
                    L4D_GetNavAreaCenter(navArea,pos);
                    pos[2] += 16.0;
                    if (pos_underwater(pos))
                    {
                        pos[2] += 16.0;
                        if (pos_underwater(pos)) pos[2] += 16.0;
                    }
                    cell.navArea = navArea;
                    cell.center = pos;
                    cell.flow = flow;
                    all_cells.PushArray(cell);
                    if (g_bMissingStart && checkpoint && flow<=(g_fMaxFlow*0.1)) g_bMissingStart = false;
                    if (g_bMissingCheckpoint && (checkpoint || rescue) && flow>=(g_fMaxFlow*0.25)) g_bMissingCheckpoint = false;
                    //#if DEBUG>2
                    //    LogMessage("%d %f %f", g_iLoop, flow);
                    //#endif
                }
                
                if (checkpoint)
                {
                    if (flow<g_fFlowStart) // Find smallest flow starting position
                    {
                        g_bFoundStart = true;
                        g_aNavStart = navArea;
                        g_fFlowStart = flow;
                    }
                    if (flow>g_fFlowCheckpoint) // Find biggest flow ending position
                    {
                        g_bFoundCheckpoint = true;
                        g_aNavCheckpoint = navArea;
                        g_fFlowCheckpoint = flow;
                    }
                }

            }
            
            if (!budget_spent) // Stage has ended, prep for next stage.
            {
                if (g_bMissingStart && g_bFoundStart)
                {
                    cell.navArea = g_aNavStart;
                    L4D_GetNavAreaCenter(g_aNavStart,pos);
                    pos[2] += 16.0; 
                    if (pos_underwater(pos)) pos[2] += 16.0;
                    cell.center = pos;
                    cell.flow = g_fFlowStart;
                    all_cells.PushArray(cell);
                }
                if (g_bMissingCheckpoint && g_bFoundCheckpoint)
                {
                    cell.navArea = g_aNavCheckpoint;
                    L4D_GetNavAreaCenter(g_aNavCheckpoint,pos);
                    pos[2] += 16.0;
                    if (pos_underwater(pos)) pos[2] += 16.0;
                    cell.center = pos;
                    cell.flow = g_fFlowCheckpoint;
                    all_cells.PushArray(cell);
                }

                delete allAreas;

                #if DEBUG>1
                    LogMessage("Initial cell num %d", all_cells.Length);
                #endif

                if (all_cells.Length <= 1)
                {
                    delete all_cells;
                    guide_prep = false;
                    #if DEBUG
                    LogMessage("WARNING: all_cells has no cells");
                    #endif
                    return;
                }

                if (g_bFoundRescueVehicle)
                {
                    cell.navArea = g_aNavRescueVehicle;
                    cell.flow = g_fFlowRescueVehicle;
                    L4D_GetNavAreaCenter(cell.navArea,pos);
                    pos[2] += 16.0;
                    if (pos_underwater(pos)) pos[2] += 16.0;
                    cell.center = pos;
                    RescueVehicleCells.PushArray(cell); 
                }

            }
        }
        case STAGE_SORT:
        {
            if (all_cells==null || g_GuideCells==null)
            {
                guide_prep = false;
                return;
            }
            #if DEBUG
            g_iTotalCollected = all_cells.Length;
            #endif
            all_cells.SortCustom(SortFlow);
            all_cells.GetArray(0,cell,sizeof(Cell));
            g_GuideCells.PushArray(cell);
            g_iLoop = 1;
        }
        case STAGE_FIX:
        {
            if (all_cells==null)
            {
                guide_prep = false;
                return;
            }
            while (all_cells.Length>1 && g_iLoop<all_cells.Length)
            {
                if (frame_budget_exceeded()) { budget_spent = true; break; }
                all_cells.GetArray(g_iLoop,cell,sizeof(Cell));
                all_cells.GetArray(g_iLoop-1,cell_before,sizeof(Cell));
                if (!cell_connected(cell_before,cell) && !twopos_traversable(cell_before.center,cell.center))
                {
                    #if DEBUG
                    LogMessage("STAGE_FIX: %d (%.1f) -> %d (%.1f) not connected", g_iLoop-1, cell_before.flow, g_iLoop, cell.flow);
                    #endif
                    explore_stitch(all_cells,g_iLoop);
                }
                g_iLoop += 1;
            }
            if (!budget_spent) g_iLoop = 1;
        }
        case STAGE_BUILD:
        {
            if (all_cells==null || g_GuideCells==null)
            {
                guide_prep = false;
                return;
            }
            while (g_iLoop<all_cells.Length)
            {
                if (frame_budget_exceeded()) { budget_spent = true; break; }
                all_cells.GetArray(g_iLoop,cell,sizeof(Cell));
                guide_add_cell(g_GuideCells,cell);
                g_iLoop += 1;
            }
            if (!budget_spent) // Stage has ended, prep for next stage
            {
                delete all_cells;
                if (g_GuideCells.Length <= 1)
                {
                    delete g_GuideCells;
                    guide_prep = false;
                    return;
                }
                if (g_bFoundRescueVehicle)
                {
                    float max_guide_flow = g_GuideCells.Get(g_GuideCells.Length-1,0);
                    #if DEBUG
                    LogMessage("rescue vehicle flow %f max guide flow %f", g_fFlowRescueVehicle, max_guide_flow);
                    #endif
                    finale_backwards = g_fFlowRescueVehicle<max_guide_flow;
                    if (explored_finale==null) explored_finale = new ArrayList();
                    explored_finale.Clear();
                }
                g_iLoop = 1;
            }
        }
        case STAGE_FINALE:
        {
            if (RescueVehicleCells == null || RescueVehicleCells.Length <= 0 || g_hCvarFinale.IntValue == FINALE_NEVER)
                g_bFoundRescueVehicle = false;

            if (g_bFoundRescueVehicle)
            {
                RescueVehicleCells.GetArray(RescueVehicleCells.Length-1,cell,sizeof(Cell));
                static float pos_curr[3];
                float flow_curr = cell.flow;
                pos_curr = cell.center;
                if (ConAdj==null) ConAdj = new ArrayList(sizeof(NavConnection));
                if (AdjNN==null) AdjNN = new ArrayList(); // nearest neighbor explore for dips in flow when about to climb a ladder

                Address navArea_curr = cell.navArea;
                float flow_temp, flow_best;
                static float pos_temp[3], pos_best[3];
                Address navArea_best;
                float dz, dz_best;

                // when finale is backwards, we start at some flow value and must go to max flow. 
                // -> when finale_backwards, set increasing=true

                while (navArea_curr != Address_Null)
                {
                    if (frame_budget_exceeded()) { budget_spent = true; break; }
                    bool found = false;
                    flow_best = flow_curr;
                    bool best_steep = false;
                    int count = GetNavConnections(navArea_curr,ConAdj,TEAM_SURVIVOR,true,true,true,CON_KEEP_ALL);
                    static NavConnection nav_connection;
                    for (int i = 0; i < count; i++)
                    {
                        ConAdj.GetArray(i,nav_connection,sizeof(NavConnection));
                        if (nav_connection.navArea == Address_Null || nav_connection.connectiontype <= CONNECTED_NOT) continue;
                        if (nav_connection.navArea == navArea_curr) continue;
                        if (blocked_available && L4D_NavArea_IsBlocked(nav_connection.navArea,TEAM_SURVIVOR,true)) continue;
                        if (explored_finale.FindValue(nav_connection.navArea)>=0) continue;
                        explored_finale.Push(nav_connection.navArea);
                        flow_temp = L4D2Direct_GetTerrorNavAreaFlow(nav_connection.navArea);
                        #if DEBUG>1
                            LogMessage("STAGE_FINALE (%d %.1f) try %d %d %.1f", navArea_curr, flow_curr, nav_connection.connectiontype, nav_connection.navArea, flow_temp);
                        #endif
                        int count2 = navArea_ladder_navAreas(nav_connection.navArea,AdjNN,TEAM_SURVIVOR); // ladder intervention. flow dips when stepping onto ladder navmeshes...
                        for (int i2 = 0; i2 < count2; i2++)
                        {
                            Address adjArea = AdjNN.Get(i2);
                            if (adjArea == Address_Null || adjArea == navArea_curr || adjArea == nav_connection.navArea) continue;
                            float new_flow = L4D2Direct_GetTerrorNavAreaFlow(adjArea);
                            if (flow_better(new_flow,flow_temp,finale_backwards))
                            {
                                #if DEBUG>1
                                LogMessage("STAGE_FINALE Ladder intervention %.1f -> %.1f", flow_temp, new_flow);
                                #endif
                                flow_temp = new_flow;
                            }
                        }
                        if (!flow_better(flow_temp,flow_curr,finale_backwards)) continue; // finale_backwards -> increasing -> from finale vehicle we go up in flow to get to radio.
                        L4D_GetNavAreaCenter(nav_connection.navArea,pos_temp);
                        pos_temp[2] += 16.0;
                        dz = pos_curr[2] - pos_temp[2];
                        bool steep = nav_connection.connectiontype == CONNECTED_ADJACENT && nav_too_steep(navArea_curr,nav_connection.navArea);
                        if (found && steep)
                        {
                            if (!best_steep || dz>dz_best) continue; // prefer to go down than up
                        }
                        if ( flow_better(flow_temp,flow_best,finale_backwards) || (best_steep && flow_better(flow_temp,flow_curr,finale_backwards)) )
                        {
                            flow_best = flow_temp;
                            navArea_best = nav_connection.navArea;
                            pos_best = pos_temp;
                            found = true;
                            best_steep = steep;
                            dz_best = dz;
                        }
                    }
                    
                    if (!found)
                    {
                        if (try_ladder(flow_curr,pos_curr,cell,finale_backwards))
                        {
                            found = true;
                            flow_best = cell.flow;
                            navArea_best = cell.navArea;
                            pos_best = cell.center;
                        }
                    }

                    if (found)
                    {
                        if (pos_underwater(pos_best)) pos_best[2] += 32.0;
                        pos_curr = pos_best;
                        navArea_curr = navArea_best;
                        flow_curr = flow_best;
                        cell.flow = flow_curr;
                        cell.navArea = navArea_curr;
                        cell.center = pos_curr;
                        guide_add_cell(RescueVehicleCells,cell);
                    }
                    else break;
                }
                if (!budget_spent)
                {
                    explored_finale.Clear();
                    #if DEBUG
                    LogMessage("Rescue vehicle cells %d", RescueVehicleCells.Length);
                    #endif
                    if (should_stitch_finale()) stitch_finale();
                }
            }
            g_iLoop = 1;
        }
        case STAGE_VALIDATE:
        {
            if (g_GuideCells != null && g_GuideCells.Length>2)
            {
                while (g_iLoop<(g_GuideCells.Length-1))
                {
                    if (frame_budget_exceeded()) { budget_spent = true; break; }
                    g_GuideCells.GetArray(g_iLoop+1,cell_after,sizeof(Cell));
                    g_GuideCells.GetArray(g_iLoop,cell,sizeof(Cell));
                    g_GuideCells.GetArray(g_iLoop-1,cell_before,sizeof(Cell));
                    //if ( !midpoint_valid_ground(cell.center,cell_after.center) )
                    //{
                    //    if (valid_ground(cell.center) && valid_ground(cell_after.center) && LOS_rescue_cheap(cell.center,cell_after.center,pos,true)) // grounded LOS rescue
                    //    {
                    //        g_GuideCells.ShiftUp(g_iLoop+1);
                    //        cell.center = pos;
                    //        cell.flow = (cell.flow+cell_after.flow)/2.0;
                    //        g_GuideCells.SetArray(g_iLoop+1,cell,sizeof(Cell));
                    //        //g_iLoop += 1;
                    //        continue;
                    //    }
                    //}
                    if (triple_valid_ground(cell_before.center,cell_after.center) && twopos_traversable(cell_before.center,cell_after.center))
                    {
                        g_GuideCells.Erase(g_iLoop); // Erase cells with mutual LOS
                        #if DEBUG
                        g_iErased += 1;
                        #endif
                        if (g_iLoop>1) g_iLoop -= 1;
                        continue;
                    }
                    
                    if (!vecdiff_too_steep(cell_before.center,cell.center))
                    {
                        if (project_forward(cell_before.center,cell.center,cell_after.center,pos) && valid_ground(pos) && twopos_traversable(pos,cell_before.center) && twopos_traversable(pos,cell_after.center))
                        {
                            cell.center = pos; // Tighten connection
                            g_GuideCells.SetArray(g_iLoop,cell,sizeof(Cell));
                            #if DEBUG
                            g_iTighten += 1;
                            #endif
                            if (g_iLoop>1) g_iLoop -= 1;
                            continue;
                        }
                        if (project_forward(cell.center,cell_after.center,cell_before.center,pos) && valid_ground(pos) && twopos_traversable(pos,cell_before.center) && twopos_traversable(pos,cell_after.center))
                        {
                            cell.center = pos; // Tighten connection
                            g_GuideCells.SetArray(g_iLoop,cell,sizeof(Cell));
                            #if DEBUG
                            g_iTighten += 1;
                            #endif
                            if (g_iLoop>1) g_iLoop -= 1;
                            continue;
                        }
                        else
                        {
                            get_midpoint(cell_before.center,cell.center,pos);
                            if (valid_ground(pos) && twopos_traversable(pos,cell_before.center) && twopos_traversable(pos,cell_after.center))
                            {
                                cell.center = pos; // Tighten connection
                                g_GuideCells.SetArray(g_iLoop,cell,sizeof(Cell));
                                #if DEBUG
                                g_iTighten += 1;
                                #endif
                            }
                        }
                    }
                    #if DEBUG>2
                        LogMessage("%d %f", g_iLoop, cell.flow);
                    #endif
                    g_iLoop += 1;
                }
            }
        }
        default:
        {
            guide_prep = false;
            return;
        }
    }
    
    if (!budget_spent) g_iPrepStage += 1;

    if (g_iPrepStage>STAGE_NONE && g_iPrepStage<STAGE_END)
    {
        if (budget_spent || frame_budget_exceeded())
        {
            RequestFrame(OnFramePrep,true);
            #if DEBUG
            g_fPrepTotalTime += (GetEngineTime()-g_tFrameStart);
            #endif
            return;
        }
        else OnFramePrep(false);
    }
    else
    {
        guide_prep = false;
        guide_ready = true;
        beams_cooldown_reset(); // reset cooldowns but not requests to draw
        delete allAreas;
        delete all_cells;
        #if DEBUG
        g_fPrepTotalTime += (GetEngineTime()-g_tFrameStart);
        LogMessage("Final cell num %d (%d collected %d erased %d tighten %d blocked) (%f ms %d frames)",
        g_GuideCells.Length, g_iTotalCollected, g_iErased, g_iTighten, g_iNavBlocked, g_fPrepTotalTime*1000.0, g_iPrepFrames);
        #endif
        g_iPrepStage = STAGE_NONE;
        timer_nav = null;
        if (finale_stitched && finale_rescue && g_hCvarFinaleAuto.BoolValue) Guide_All_Clients();
        else Timer_CheckRequests(null); // Draw beams immediately for pending clients
    }

}

// Look for closest survivor ladder manually, quite expensive. Output cell_ladder
stock bool try_ladder(float flow_curr,float pos_curr[3],Cell cell_ladder,bool flow_increasing = true)
{
    int entity = INVALID_ENT_REFERENCE;
    int closest = -1;
    static float mins[3],maxs[3],pos_temp[3],pos_best[3];
    float best_dist = -1.0;
    float flow_best = -1.0;
    float flow_temp;
    bool found = false;
    Address navArea_best;
    while ((entity = FindEntityByClassname(entity, "func_simpleladder")) != INVALID_ENT_REFERENCE)
    {
        int team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
        if (team!=0 && team!=TEAM_SURVIVOR) continue;
        GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);
        float dist = GetVectorDistance(pos_curr,maxs,true);
        if (best_dist<0.0 || dist<best_dist)
        {
            closest = entity;
            best_dist = dist;
        }
        GetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
        dist = GetVectorDistance(pos_curr,maxs,true);
        if (best_dist<0.0 || dist<best_dist)
        {
            closest = entity;
            best_dist = dist;
        }
    }
    if (closest>0 && best_dist<100000.0)
    {
        //LogMessage("Found survivor ladder %d %f", closest, best_dist);
        flow_best = flow_curr;
        for (int i_nav = 0; i_nav < 2; i_nav++)
        {
            if (i_nav==0) GetEntPropVector(closest, Prop_Send, "m_vecMaxs", pos_temp);
            else GetEntPropVector(closest, Prop_Send, "m_vecMins", pos_temp);
            Address adjArea = L4D_GetNearestNavArea(pos_temp,500.0,true,false,false,TEAM_SURVIVOR);
            if (adjArea == Address_Null) continue;
            flow_temp = L4D2Direct_GetTerrorNavAreaFlow(adjArea);
            switch (flow_increasing)
            {
                case true: { if (flow_temp<=flow_best) continue; }
                default: { if (flow_temp>=flow_best) continue; }
            }
            //L4D_GetNavAreaCenter(adjArea,pos_temp);
            pos_temp[2] += 16.0;
            flow_best = flow_temp;
            navArea_best = adjArea;
            pos_best = pos_temp;
            found = true;
        }
    }
    if (found)
    {
        cell_ladder.flow = flow_best;
        cell_ladder.navArea = navArea_best;
        cell_ladder.center = pos_best;
        return true;
    }
    return false;
}

// Check if escape vehicle should be connected to RequestGuide
bool should_stitch_finale()
{
    if (!enable || !map_started || !nav_started || finale_stitched || !g_bFoundRescueVehicle) return false;
    switch (g_hCvarFinale.IntValue)
    {
        case FINALE_NEVER: return false;
        case FINALE_RESCUE: return finale && finale_rescue;
        case FINALE_STARTED: return finale;
        default: return true;
    }
}

// Check if two cells are nearly identical. max_distance sets how far apart they can be.
bool cells_almost_identical(Cell cell1, Cell cell2, float max_distance = 250.0)
{
    if (cell1.navArea != Address_Null && cell1.navArea == cell2.navArea) return true;
    return GetVectorDistance(cell1.center,cell2.center)<=max_distance && twopos_traversable(cell1.center,cell2.center);
}

void stitch_finale()
{
    if (!enable || finale_stitched) return;
    if (g_GuideCells == null || RescueVehicleCells == null) return;
    static Cell cell, cell2;
    g_GuideCells.GetArray(g_GuideCells.Length-1,cell2,sizeof(Cell));

    #if DEBUG
    int erased = 0;
    #endif

    int i_finale_cut = -1; // which guide cell meets with rescue
    int i_finale_cut_rescue = -1; // which rescue cell meets with guide
    g_iLoop = 0;
    while (g_iLoop>=0 && g_iLoop<=(RescueVehicleCells.Length-1))
    {
        RescueVehicleCells.GetArray(g_iLoop,cell,sizeof(Cell));
        if ( g_iLoop==0 && cells_almost_identical(cell,cell2) )
        {
            g_GuideCells.PushArray(cell,sizeof(Cell));
            finale_backwards = false;
            finale_stitched = true;
            #if DEBUG
            LogMessage("Rescue zone is close to last guide cell. Added 1 cell.");
            #endif
            return;
        }
        if (cell.navArea != Address_Null)
        {
            i_finale_cut = g_GuideCells.FindValue(cell.navArea,1);
            if (i_finale_cut>=0)
            {
                i_finale_cut_rescue = g_iLoop;
                break;
            }
        }
        g_iLoop += 1;
    }

    if ( (!finale_backwards || use_gauntlet_logic()) && i_finale_cut_rescue>=0 && i_finale_cut>0)
    {
        // keep g_GuideCells up to i_finale_cut. keep i_finale_cut
        g_GuideCells.Resize(i_finale_cut+1);
        // keep RescueVehicleCells up to i_finale_cut_rescue. don't keep i_finale_cut_rescue
        RescueVehicleCells.Resize(i_finale_cut_rescue);
        #if DEBUG
        LogMessage("Finale resize g_GuideCells %d RescueVehicleCells %d", i_finale_cut+1, i_finale_cut_rescue);
        #endif
    }

    if (!finale_backwards) // simplest case. extend guide cells to escape vehicle
    {
        #if DEBUG
        LogMessage("Finale increasing in flow, erased %d cells, added %d cells", erased, RescueVehicleCells.Length);
        #endif
    }
    else
    {
        if (use_gauntlet_logic())
        {
            // Erase g_GuideCells after rescue flow
            g_iLoop = g_GuideCells.Length-1;
            while (g_iLoop>=0 && g_iLoop<=(g_GuideCells.Length-1))
            {
                if (g_GuideCells.Get(g_iLoop,0)>=g_fFlowRescueVehicle)
                {
                    g_GuideCells.Erase(g_iLoop);
                    #if DEBUG
                    erased += 1;
                    #endif
                }
                else g_iLoop -= 1;
            }
            #if DEBUG
            LogMessage("Gauntlet flow backwards, erased %d cells, added %d cells", erased, RescueVehicleCells.Length);
            #endif
        }
        else
        {
            // Keep only last guide cell, connect to rescue zone.
            #if DEBUG
            LogMessage("Finale flow backwards, guide from radio only. %d cells", RescueVehicleCells.Length);
            #endif
            g_GuideCells.GetArray(g_GuideCells.Length-1,cell,sizeof(Cell));
            g_GuideCells.Clear();
            g_GuideCells.PushArray(cell,sizeof(Cell));
        }
    }
    // Merge g_GuideCells with rescue vehicle cells
    // in RescueVehicleCells, the first cell is the rescue position (the very last point).
    g_iLoop = RescueVehicleCells.Length-1;
    while (g_iLoop>=0 && g_iLoop<=(RescueVehicleCells.Length-1))
    {
        RescueVehicleCells.GetArray(g_iLoop,cell,sizeof(Cell));
        g_GuideCells.PushArray(cell,sizeof(Cell));
        g_iLoop -= 1;
    }
    finale_stitched = true;
}

// i_start is where the disconnected navmesh is. i_start-1 should be a good navarea.
ArrayList cells_explore;
#define STITCH_GAP_OK 2 // how many cells ahead to check for further disjointed navAreas
stock bool explore_stitch(ArrayList cells, int &i_start, int max_steps = 50)
{
    if (i_start<=1 || i_start>=cells.Length) return false;
    static Cell cell, cell2;

    int stitch_gap = STITCH_GAP_OK;
    //if (strncmp(mapName,"c7m2",4,false)==0) stitch_gap = 20; // i just want to talk to the mapper

    // Determine i_min>=i_start, where i_min is the furthest away cell index where disconnection was detected
    int i_min = i_start;
    int num_good = 0;
    int i = i_start+1;
    cells.GetArray(i_start,cell,sizeof(Cell)); // i_start-1 is the cell already explored. i_start does not have LOS.
    while (num_good<=stitch_gap && i<(cells.Length))
    {
        cells.GetArray(i,cell2,sizeof(Cell));
        if ( !cell_connected(cell,cell2) || !twopos_traversable(cell.center,cell2.center) )
        {
            num_good = 0;
            i_min = i-1;
        }
        else num_good += 1;
        cell = cell2;
        i += 1;
    }
    
    #if DEBUG
    LogMessage("explore_stitch i_start %d i_min %d", i_start, i_min);
    #endif

    int num_delete;

    if (i_min>i_start) // Delete chain of bad navmeshes
    {
        num_delete = i_min-i_start+1;
        #if DEBUG
        LogMessage("explore_stitch deleted %d cells", num_delete);
        #endif
        while (num_delete>0 && i_start<(cells.Length-1))
        {
            cells.Erase(i_start);
            num_delete -= 1;
        }
    }
    else if (i_start>0 && i_start<(cells.Length-1)) // is i_start+1 connected to i_start-1?
    {
        cells.GetArray(i_start-1,cell,sizeof(Cell));
        cells.GetArray(i_start+1,cell2,sizeof(Cell));
        if (cell_connected(cell,cell2) && (twopos_traversable(cell.center,cell2.center) || LOS_rescue_cheap(cell.center,cell2.center,_) ))
        {
            cells.Erase(i_start);
            #if DEBUG
            LogMessage("explore_stitch %d deleted", i_start);
            #endif
            return true;
        }
    }

    if (cells.Length<=1) return false;

    if (cells_explore==null) cells_explore = new ArrayList(sizeof(Cell));
    if (ConAdj==null) ConAdj = new ArrayList(sizeof(NavConnection));
    if (AdjNN==null) AdjNN = new ArrayList(); // nearest neighbor explore for dips in flow when about to climb a ladder
    cells_explore.Clear();
    if (explored==null) explored = new ArrayList();
    explored.Clear();

    cells.GetArray(i_start-1,cell,sizeof(Cell));
    static float pos_curr[3], pos_temp[3], pos_best[3];
    pos_curr = cell.center;
    float flow_curr = cell.flow;
    bool success = false; // success when we hit a forward navArea in cells
    Address navArea_curr = cell.navArea;
    Address navArea_best = navArea_curr;
    pos_best = pos_curr;
    float flow_temp, dz, dz_best;

    int steps = 0;
    int i_end = -1;
    while (steps<max_steps)
    {
        bool found = false;
        bool best_steep = false;
        float flow_best = flow_curr;
        int count = GetNavConnections(navArea_curr,ConAdj,TEAM_SURVIVOR,true,true,true,CON_KEEP_FORWARD);
        static NavConnection nav_connection;
        for (i = 0; i < count; i++)
        {
            ConAdj.GetArray(i,nav_connection,sizeof(NavConnection));
            if (nav_connection.navArea == Address_Null || nav_connection.connectiontype <= CONNECTED_NOT) continue;
            if (nav_connection.navArea == navArea_curr) continue;
            if (explored.FindValue(nav_connection.navArea)>=0) continue;
            explored.Push(nav_connection.navArea);
            if (blocked_available && L4D_NavArea_IsBlocked(nav_connection.navArea,TEAM_SURVIVOR,true)) continue;
            flow_temp = L4D2Direct_GetTerrorNavAreaFlow(nav_connection.navArea);
            int count2 = navArea_ladder_navAreas(nav_connection.navArea,AdjNN,TEAM_SURVIVOR); // ladder intervention. flow dips when stepping onto ladder navmeshes...
            for (int i2 = 0; i2 < count2; i2++)
            {
                Address adjArea = AdjNN.Get(i2);
                if (adjArea == Address_Null || adjArea == navArea_curr || adjArea == nav_connection.navArea) continue;
                float new_flow = L4D2Direct_GetTerrorNavAreaFlow(adjArea);
                if (new_flow>flow_temp)
                {
                    #if DEBUG>1
                    LogMessage("Ladder intervention %.1f -> %.1f", flow_temp, new_flow);
                    #endif
                    flow_temp = new_flow;
                }
            }
            if (flow_temp<flow_curr) continue;
            L4D_GetNavAreaCenter(nav_connection.navArea,pos_temp); pos_temp[2] += 16.0;
            if (pos_underwater(pos_temp))
            {
                pos_temp[2] += 16.0;
                if (pos_underwater(pos_temp)) pos_temp[2] += 16.0;
            }
            dz = pos_temp[2] - pos_curr[2];
            bool steep = nav_connection.connectiontype == CONNECTED_ADJACENT && nav_too_steep(navArea_curr,nav_connection.navArea);
            if (found && steep)
            {
                if (!best_steep || dz>dz_best) continue; // prefer to go down than up
            }
            else if (!steep)
            {
                i_end = cells.FindValue(nav_connection.navArea,1);
                if (i_end>=i_start) success = true;
            }
            if ( success || flow_temp>=flow_best || (best_steep && flow_temp>=flow_curr) )
            {
                flow_best = flow_temp;
                navArea_best = nav_connection.navArea;
                pos_best = pos_temp;
                found = true;
                best_steep = steep;
                dz_best = dz;
                if (success) break;
            }
        }
        
        if (found)
        {
            cell.flow = flow_best;
            cell.navArea = navArea_best;
            cell.center = pos_best;
        }
        else found = try_ladder(flow_curr,pos_curr,cell);
        if (!found) break;

        pos_curr = cell.center;
        navArea_curr = cell.navArea;
        flow_curr = cell.flow;
        #if DEBUG>1
        LogMessage("explore_stitch %d found %f", i_start, flow_best);
        #endif
        cells_explore.PushArray(cell,sizeof(Cell));
        if (!success) i_end = cells.FindValue(navArea_curr,1);
        if (i_end>=0)
        {
            //if (i_end<i_start) break; // fail
            success = i_end>=i_start;
            if (success) break;
        } 
        steps += 1;
    }

    #if DEBUG
    LogMessage("explore_stitch %d %d %d", i_start, success, cells_explore.Length);
    #endif

    if (success)
    {
        cells_explore.GetArray(0,cell,sizeof(Cell));
        cells.SetArray(i_start,cell,sizeof(Cell));
        num_delete = i_end-i_start;
        int num_deleted = num_delete;
        while (num_delete>0 && i_start<(cells.Length-1))
        {
            cells.Erase(i_start+1);
            num_delete -= 1;
        }
        if (cells_explore.Length>1)
        {
            for (i = cells_explore.Length-1; i >= 1; i--)
            {
                cells_explore.GetArray(i,cell,sizeof(Cell));
                if ( i_start<(cells.Length-1) )
                {
                    cells.ShiftUp(i_start+1);
                    cells.SetArray(i_start+1,cell,sizeof(Cell));
                }
                else
                {
                    cells.PushArray(cell,sizeof(Cell));
                }
            }
        }
        i_start += num_deleted;
    }

    return success;
}

// Add cell to cells. If there is no LOS, attempt rescue. If check_ladder, add ladder mounting points.
void guide_add_cell(ArrayList cells, Cell cell, bool check_ladder = true)
{
    if (cells.Length<1) // no shortcuts available
    {
        cells.PushArray(cell);
        return;
    }
    static Cell cell_prev, cell_prev2;
    cells.GetArray(cells.Length-1,cell_prev,sizeof(Cell)); // last cell
    
    bool prev2 = cells.Length>=2;
    if (prev2) cells.GetArray(cells.Length-2,cell_prev2,sizeof(Cell));

    bool LOS = twopos_traversable(cell.center,cell_prev.center);
    if (!LOS) // Try lifting cells
    {
        static Cell cell_lifted;
        cell_lifted = cell; cell_lifted.center[2] += 16.0;
        LOS = twopos_traversable(cell_lifted.center,cell_prev.center);
        if (LOS) cell = cell_lifted;
        else
        {
            cell_lifted = cell_prev; cell_lifted.center[2] += 16.0;
            if (twopos_traversable(cell_lifted.center,cell.center) && ( !prev2 || twopos_traversable(cell_lifted.center,cell_prev2.center) ) )
            {
                cell_prev = cell_lifted;
                cells.SetArray(cells.Length-1,cell_prev,sizeof(Cell));
                LOS = true;
            }
        }
    }
    
    if (LOS)
    {
        if (prev2 && triple_valid_ground(cell_prev2.center,cell.center) && twopos_traversable(cell.center,cell_prev2.center))
            cells.SetArray(cells.Length-1,cell,sizeof(Cell));
        else 
            cells.PushArray(cell);
    }
    else if (!cell_rescue(cells,cell_prev,cell,cell_prev2,prev2))
    {
        if (check_ladder) // Add ladder attachment points
        {
            int ladder = ladder_from_to(cell_prev.navArea,cell.navArea);
            if (ladder>0 && !twopos_traversable(cell_prev.center,cell.center))
            {
                static float pos1[3],pos2[3];
                GetEntPropVector(ladder, Prop_Send, "m_vecMaxs", pos1);
                GetEntPropVector(ladder, Prop_Send, "m_vecMins", pos2);
                SortTwoVectorsClosest(cell_prev.center,pos1,pos2);
                if (!navmesh_xy_too_far(cell_prev.navArea,pos1) && !navmesh_xy_too_far(cell.navArea,pos2))
                {
                    pos1[2] = L4D_NavArea_GetZ(cell_prev.navArea,pos1); pos1[2] += 16.0;
                    pos2[2] = L4D_NavArea_GetZ(cell.navArea,pos2); pos2[2] += 16.0;
                    
                    static Cell cell_ladder;
                    
                    cell_ladder = cell_prev;
                    cell_ladder.center = pos1;
                    // wiggle pos1 around so it has LOS with cell_prev
                    //guide_add_cell(cells,cell_ladder,false);
                    cells.PushArray(cell_ladder);
                    
                    cell_ladder = cell;
                    cell_ladder.center = pos2;
                    // wiggle pos2 around so it has LOS with cell
                    //guide_add_cell(cells,cell_ladder,false);
                    cells.PushArray(cell_ladder);
                }
            }
        }
        cells.PushArray(cell);
    }
}

// Two cells cannot see each other. Attempt to remedy this. prev2 if cell before previous cell exists. return true on success
bool cell_rescue(ArrayList cells, Cell cell_old, Cell cell_new, Cell cell_prev2, bool prev2 = true)
{
    static Cell cell;
    static Address navAreas[2];
    static float diff[3], diff_candidate[3], diff_template[3], pos_candidate[3], pos_template[3];

    ArrayList pos_candidates = new ArrayList(3);
    SubtractVectors(cell_new.center,cell_old.center,diff);
    diff_candidate = diff;

    bool flat = FloatAbs(diff[2])<=1.0; // flat -> nothing to do in z direction
    int i_turns_flat = 1;
    if (!flat) i_turns_flat += 1; // two turns if not flat
    int i_turns_mid = 2; // one cycle at old cell, then one cycle at midpoint

    if (elevator_available)
    {
        
        if (cell_new.navArea!=Address_Null) // clip cell_old.center to cell_new.navArea
        {
            pos_candidate = cell_old.center;
            navmesh_clip(cell_new.navArea,pos_candidate);
            pos_candidate[2] += 16.0; pos_candidates.PushArray(pos_candidate);
        }
        if (cell_old.navArea!=Address_Null) // clip cell_new.center to cell_old.navArea
        {
            pos_candidate = cell_new.center;
            navmesh_clip(cell_old.navArea,pos_candidate);
            pos_candidate[2] += 16.0; pos_candidates.PushArray(pos_candidate);
        }
        
        for (int dir = 0; dir < 4; dir++) // Add all 4 corners of navmesh. These are usually in very good positions for LOS.
        {
            L4D_NavArea_GetCorner(cell_new.navArea,view_as<NavCornerType>(dir),pos_candidate); pos_candidate[2] += 16.0; pos_candidates.PushArray(pos_candidate);
            L4D_NavArea_GetCorner(cell_old.navArea,view_as<NavCornerType>(dir),pos_candidate); pos_candidate[2] += 16.0; pos_candidates.PushArray(pos_candidate);
        }
    }
    else
    {
        // Add known corners of navmesh - crappy method
        L4D_GetNavAreaPos(cell_new.navArea,pos_candidate); pos_candidate[2] += 16.0; pos_candidates.PushArray(pos_candidate);
        L4D_GetNavAreaPos(cell_old.navArea,pos_candidate); pos_candidate[2] += 16.0; pos_candidates.PushArray(pos_candidate);
    }

    for (int i_turn_flat = 0; i_turn_flat < i_turns_flat; i_turn_flat++)
    {
        diff_template = diff;
        if (i_turn_flat==1) diff_template[2] = 0.0;
        for (int i_turn_mid = 0; i_turn_mid < i_turns_mid; i_turn_mid++) 
        {
            if (i_turn_mid==1) // Try wiggling at midpoint
            {
                diff_candidate = diff; ScaleVector(diff_candidate,0.5);
                AddVectors(cell_old.center,diff_candidate,pos_template);
            }
            else pos_template = cell_old.center;

            if (i_turn_mid==0)
            {
                diff_candidate = diff_template; ScaleVector(diff_candidate,0.5); // half
                AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
            }

            diff_candidate = diff_template; diff_candidate[0] = 0.0; // dy
            AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
            diff_candidate[1] *= 0.5; // dy/2
            AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
            
            diff_candidate = diff_template; diff_candidate[1] = 0.0; // dx
            AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
            diff_candidate[0] *= 0.5; // dx/2
            AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
            
            diff_candidate = diff_template; ScaleVector(diff_candidate,0.25); // quarter
            AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);

            if (diff_template[2] != 0.0) // z is not flat
            {
                diff_candidate = diff_template; diff_candidate[0] = 0.0; diff_candidate[1] = 0.0; // dz
                AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
                diff_candidate[2] *= 0.5; // dz/2
                AddVectors(pos_template,diff_candidate,pos_candidate); pos_candidates.PushArray(pos_candidate);
            }

            // Try small static wiggles
            AddVectors(pos_template,{16.0,0.0,0.0},pos_candidate); pos_candidates.PushArray(pos_candidate);
            AddVectors(pos_template,{-16.0,0.0,0.0},pos_candidate); pos_candidates.PushArray(pos_candidate);
            AddVectors(pos_template,{0.0,16.0,0.0},pos_candidate); pos_candidates.PushArray(pos_candidate);
            AddVectors(pos_template,{0.0,-16.0,0.0},pos_candidate); pos_candidates.PushArray(pos_candidate);
            AddVectors(pos_template,{0.0,0.0,16.0},pos_candidate); pos_candidates.PushArray(pos_candidate);
        }
    }

    // Priority: projected first, then stragglers.
    ArrayList pos_candidates2 = new ArrayList(3); // lower priority candidates

    bool success = false;
    bool priority = elevator_available;
    while (!success)
    {
        int length = (priority) ? pos_candidates.Length : pos_candidates2.Length;
        for (int i = 0; i<length; i++) 
        {
            bool projected = false;
            if (priority) pos_candidates.GetArray(i,pos_candidate,sizeof(pos_candidate));
            else pos_candidates2.GetArray(i,pos_candidate,sizeof(pos_candidate));
            pos_template = pos_candidate;
            if (priority && elevator_available) // try to project xy onto navmesh z
            {
                // Get appropriate z value for given xy position. Useful for slopes, stairs etc.
                projected = project_navmesh_xy(cell_new.navArea,pos_candidate);
                if (!projected) projected = project_navmesh_xy(cell_old.navArea,pos_candidate);
                if (projected)
                {
                    pos_candidate[2] += 16.0;
                    projected = GetVectorDistance(pos_template,pos_candidate,true)>5.0; // if we're in the exact same place, doesn't matter
                }
            }
            if (pos_underwater(pos_candidate))
            {
                pos_candidate[2] += 16.0;
                if (pos_underwater(pos_candidate)) pos_candidate[2] += 16.0;
            }
            bool traversable = twopos_traversable(cell_new.center,pos_candidate) && twopos_traversable(cell_old.center,pos_candidate);
            if (!traversable)
            {
                if (!projected) continue;
                pos_candidates2.PushArray(pos_template); // Try non-projected candidate later
                continue;
            }
            float d_flow = GetVectorDistance(cell_old.center,pos_candidate);
            cell.flow = cell_old.flow + d_flow;
            if (cell.flow>=cell_new.flow) cell.flow = (cell_old.flow + cell_new.flow)/2.0;
            cell.navArea = Address_Null;
            cell.center = pos_candidate;
            if (prev2 && triple_valid_ground(cell_prev2.center,cell.center) && twopos_traversable(cell.center,cell_prev2.center))
                cells.SetArray(cells.Length-1,cell,sizeof(Cell));
            else
                cells.PushArray(cell);
            success = true;
            break;
        }
        if (priority) priority = false; // try unprojected candidates now
        else break;
    }
    delete pos_candidates;
    delete pos_candidates2;
    if (success)
    {
        cells.PushArray(cell_new);
        return true;
    }
    
    navAreas[0] = cell_new.navArea;
    navAreas[1] = cell_old.navArea;
    ArrayList adjAreas = new ArrayList();
    for (int i_nav = 0; i_nav < sizeof(navAreas); i_nav++) // Check adjacent areas
    {
        Address navArea = navAreas[i_nav];
        if (navArea == Address_Null) continue;
        for (int dir = 0; dir < 4; dir++) // Enqueue adjacent nav areas (all 4 directions)
        {
            adjAreas.Clear();
            L4D_NavArea_GetAdjacentAreas(navArea, dir, adjAreas);
            for (int i = 0; i < adjAreas.Length; i++)
            {
                Address adjArea = adjAreas.Get(i);
                if (adjArea == Address_Null) continue;
                if (blocked_available && L4D_NavArea_IsBlocked(adjArea,TEAM_SURVIVOR,true)) continue;
                for (int i_try = 0; i_try < 2; i_try++)
                {
                    if (i_try == 0) L4D_GetNavAreaCenter(adjArea,pos_candidate);
                    else L4D_GetNavAreaPos(adjArea,pos_candidate);
                    pos_candidate[2] += 16.0;
                    if (pos_underwater(pos_candidate)) pos_candidate[2] += 16.0;
                    if (twopos_traversable(pos_candidate,cell_new.center) && twopos_traversable(pos_candidate,cell_old.center))
                    {
                        float d_flow = GetVectorDistance(cell_old.center,pos_candidate);
                        cell.flow = cell_old.flow + d_flow;
                        if (cell.flow>=cell_new.flow) cell.flow = (cell_old.flow + cell_new.flow)/2.0;
                        cell.navArea = adjArea;
                        cell.center = pos_candidate;
                        cells.PushArray(cell);
                        cells.PushArray(cell_new);
                        delete adjAreas;
                        return true;
                    }
                }
            }
        }
    }
    delete adjAreas;

    return success;
}

// Two vector positions do not have LOS. See if a vector position inbetween can fix it. Ground to accept only grounded positions.
// Result stored in pos_mid. Returns true on success.
bool LOS_rescue_cheap(float pos1[3], float pos2[3], float pos_mid[3] = {0.0,0.0,0.0}, bool ground = false)
{
    static float diff[3], diff_candidate[3];
    SubtractVectors(pos2,pos1,diff);
    
    // dx only
    if (FloatAbs(diff[0])>=5.0)
    {
        diff_candidate = diff; diff_candidate[1] = 0.0; diff_candidate[2] = 0.0;
        AddVectors(pos1,diff_candidate,pos_mid);
        if ( (!ground || valid_ground(pos_mid)) && twopos_traversable(pos_mid,pos1) && twopos_traversable(pos_mid,pos2) ) return true;
    }

    // dy only
    if (FloatAbs(diff[1])>=5.0)
    {
        diff_candidate = diff; diff_candidate[0] = 0.0; diff_candidate[2] = 0.0;
        AddVectors(pos1,diff_candidate,pos_mid);
        if ( (!ground || valid_ground(pos_mid)) && twopos_traversable(pos_mid,pos1) && twopos_traversable(pos_mid,pos2) ) return true;
    }

    // dz only
    if (FloatAbs(diff[2])>=5.0)
    {
        diff_candidate = diff; diff_candidate[0] = 0.0; diff_candidate[1] = 0.0;
        AddVectors(pos1,diff_candidate,pos_mid);
        if ( (!ground || valid_ground(pos_mid)) && twopos_traversable(pos_mid,pos1) && twopos_traversable(pos_mid,pos2) ) return true;
    }

    return false;
}

// Check if client is on cooldown for drawing beams
bool beams_cooldown(int client)
{
    //return false;
    //if (playertime.t_engine<0.0 && playertime.t_game<0.0) return false;
    if (g_PlayerTime[client].t_game<=0.0) return false;
    //if ( (playertime.t_engine+playertime.t_cooldown/2.0)>=GetEngineTime() ) return true;
    if ( (g_PlayerTime[client].t_game+g_PlayerTime[client].t_cooldown)>GetGameTime() ) return true;
    return false;
}

// Client just rendered beams for given duration. Set cooldown to half the duration.
void beams_cooldown_update(int client, float duration = -1.0)
{
    static PlayerTime playertime;
    playertime = g_PlayerTime[client];
    if (duration < 0.0)
    {
        duration = playertime.t_cooldown;
        if (duration < 0.0) return;
    }
    else duration /= 2.0;
    if (duration<0.1) duration = 0.1; // reduce server load
    //playertime.t_engine = GetEngineTime();
    playertime.t_game = GetGameTime();
    playertime.t_cooldown = duration;
    g_PlayerTime[client] = playertime;
    g_CellRequests[client].duration = -1.0;
}

// Reset all beam cooldowns. If client is specified, reset only for that client
// If request, reset beam requests too
void beams_cooldown_reset(int client = -1, bool request = false)
{
    if (!enable) return;
    static PlayerTime playertime;
    if (client>0)
    {
        playertime = g_PlayerTime[client];
        playertime.t_game = -1.0; playertime.t_engine = -1.0; playertime.t_cooldown = -1.0;
        g_PlayerTime[client] = playertime;
        if (request) g_CellRequests[client].duration = -1.0;
        return;
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        playertime = g_PlayerTime[i];
        playertime.t_game = -1.0; playertime.t_engine = -1.0; playertime.t_cooldown = -1.0;
        g_PlayerTime[i] = playertime;
        if (request) g_CellRequests[i].duration = -1.0;
    }
}

int SortFlow(int index1, int index2, Handle array, Handle hndl)
{
    float flow1 = view_as<ArrayList>(array).Get(index1,0);
    float flow2 = view_as<ArrayList>(array).Get(index2,0);
    if (flow1 > flow2) return 1;
    else if (flow1 < flow2) return -1;
    return 0;
}

// Test if it's possible to travel to cell position from given position
bool cell_traversable(int i, float pos[3], bool world_only = true, float max_distance = -1.0)
{
    static Cell cell;
    g_GuideCells.GetArray(i,cell,sizeof(Cell));
    return twopos_traversable(pos,cell.center,world_only,max_distance);
}

//static int MASK_PTG = MASK_PLAYERSOLID | MASK_VISIBLE | CONTENTS_DETAIL;
static int MASK_PTG = MASK_PLAYERSOLID;

#define DX_HULL 8.0
#define DZ_HULL 30.0

// Test if you can travel between two vector positions without an obstruction. world_only to hit only world and static props. ladder to accept traversability if ladder was hit
bool twopos_traversable(float pos1[3], float pos2[3], bool world_only = true, float max_distance = -1.0, bool hull = true)
//bool twopos_traversable(float pos1[3], float pos2[3], bool world_only = true, float max_distance = -1.0, bool hull = true, bool ladder = true)
{
    //g_bHitLadder = false;
    if (max_distance>0.0 && GetVectorDistance(pos1,pos2)>max_distance) return false;
    if (hull)
    {
        if (world_only) TR_TraceHullFilter(pos1,pos2,{-DX_HULL,-DX_HULL,1.0},{DX_HULL,DX_HULL,DZ_HULL},MASK_PTG,TraceFilterStatic);
        else            TR_TraceHullFilter(pos1,pos2,{-DX_HULL,-DX_HULL,1.0},{DX_HULL,DX_HULL,DZ_HULL},MASK_PTG,TraceFilterNoClients);
    }
    else
    {
       if (world_only) TR_TraceRayFilter(pos1,pos2,MASK_PTG,RayType_EndPoint,TraceFilterStatic);
       else TR_TraceRayFilter(pos1,pos2,MASK_PTG,RayType_EndPoint,TraceFilterNoClients);
    }
    //if (ladder && g_bHitLadder) return true;
    if (!TR_DidHit(INVALID_HANDLE)) return true;
    #if DEBUG
    g_iHitEntity = TR_GetEntityIndex(INVALID_HANDLE);
    g_iHitSurfaceProps = TR_GetSurfaceProps(INVALID_HANDLE);
    g_iHitSurfaceFlags = TR_GetSurfaceFlags(INVALID_HANDLE);
    TR_GetSurfaceName(INVALID_HANDLE,g_sHitSurfaceName,sizeof(g_sHitSurfaceName));
    #endif
    return false;
}

bool TraceFilterStatic(int entity, int contentsMask)
{
    if (entity == 0)
    {
        //LogMessage("TraceFilterStatic hit %d", entity);
        return true;
    }
    if (entity > 0 && entity <= MaxClients) return false;
    static char class[16];
    GetEntityClassname(entity,class,sizeof(class));
    //LogMessage("TraceFilterStatic hit %d %s", entity, class);
    switch (class[0])
    {
        case 'p':
        {
            if (strncmp(class,"prop_static",11,false)==0) return true;
        }
        case 'f':
        {
            if (strncmp(class,"func_brush",10,false)==0) return true;
            if (strncmp(class,"func_simpleladder",17,false)==0) return false;
            //g_bHitLadder = strncmp(class,"func_simpleladder",17,false)==0;
        }
    }
    return false;
}

bool TraceFilterNoClients(int entity, int contentsMask)
{
    if (entity > 0 && entity <= MaxClients) return false;
    return true;
}

stock bool pos_underwater(const float pos[3])
{
	static float top[3], bottom[3];
    bottom = pos;
    top = pos; top[2] += 64.0;
	TR_TraceRay(top,bottom,MASK_WATER,RayType_EndPoint);
	if (TR_DidHit(INVALID_HANDLE)) return true;
    return false;
}

// Get midpoint between pos1 and pos2.
stock void get_midpoint(float pos1[3], float pos2[3], float pos_mid[3])
{
    static float vDiff[3];
    MakeVectorFromPoints(pos1,pos2,vDiff);
    ScaleVector(vDiff,0.5);
    AddVectors(pos1,vDiff,pos_mid);
}

// Try to project pos onto line between pos_start and pos_end. Update pos_mid if success.
stock bool project_forward(float pos_start[3], float pos_end[3], float pos[3], float pos_mid[3])
{
    static float vDiff[3], vDiff2[3];
    MakeVectorFromPoints(pos_start,pos_end,vDiff);
    float mag_sq = GetVectorDotProduct(vDiff,vDiff);
    if (mag_sq<=0.0) return false;
    MakeVectorFromPoints(pos_start,pos,vDiff2);
    float dot = GetVectorDotProduct(vDiff,vDiff2);
    if (dot<=0.0) return false; // not pointing in the right direction
    float scale = dot/mag_sq;
    if (scale>=0.999 || scale<=0.001) return false; // projection is crappy
    ScaleVector(vDiff,scale);
    AddVectors(pos_start,vDiff,pos_mid);
    return true;
}

#define DZ_TOO_HIGH 50.0 // how high survivors can jump
#define DZ_TOO_LOW 200.0 // fall damage

// See if going from pos1 to pos2 is too steep (potentially dangerous, or obstacle too tall.)
// This is mostly useless.
stock bool vecdiff_too_steep(float pos1[3], float pos2[3])
{
    static float diff[3];
    SubtractVectors(pos2,pos1,diff); // how to move to go from from pos1 to pos2
    if (FloatAbs(diff[2])<=DZ_TOO_HIGH) return false;
    float length = GetVectorLength(diff);
    if (length<=DZ_TOO_HIGH) return false;
    float ratio = diff[2] / length;
    return FloatAbs(ratio)>=0.75;
}

stock bool cell_step_too_steep(Cell cell_before,Cell cell_after)
{
    if (cell_before.navArea != Address_Null && cell_after.navArea != Address_Null)
        return nav_too_steep(cell_before.navArea,cell_after.navArea);
    return vecdiff_too_steep(cell_before.center,cell_after.center);
    //float dz = FloatAbs(cell_before.center[2]-cell_after.center[2]);
    //return dz >= DZ_TOO_HIGH;
}

// See if from -> to is too steep
stock bool nav_too_steep(Address from, Address to)
{
    if (from==Address_Null || to==Address_Null) return false;
    static float pos1[3], pos2[3];
    L4D_GetNavAreaCenter(from,pos1);
    L4D_GetNavAreaCenter(to,pos2);
    float dz = pos2[2]-pos1[2];
    bool up = dz >= 0.0;
    dz = FloatAbs(dz);
    if (dz<DZ_TOO_HIGH) return false;
    static float size1[3], size2[3];
    L4D_GetNavAreaSize(from,size1);
    L4D_GetNavAreaSize(to,size2);
    dz -= FloatAbs(size1[2]/2.0);
    dz -= FloatAbs(size2[2]/2.0);
    if (up) return dz>=DZ_TOO_HIGH;
    else return dz>=DZ_TOO_LOW;
}

// Check if ground is valid at both positions and inbetween.
stock bool triple_valid_ground(float pos1[3], float pos2[3])
{
    if (!valid_ground(pos1)) return false;
    if (!valid_ground(pos2)) return false;
    return midpoint_valid_ground(pos1,pos2);
}

// Check if midpoint between two vector positions is reasonably close to the ground.
stock bool midpoint_valid_ground(float pos1[3], float pos2[3])
{
    static float diff[3], pos_mid[3];
    SubtractVectors(pos2,pos1,diff); // how to move to go from from pos1 to pos2
    if (GetVectorLength(diff,true)<=4096.0) return true;
    ScaleVector(diff,0.5);
    AddVectors(pos1,diff,pos_mid);
    return valid_ground(pos_mid);
}

#define GROUND_WIDTH 16.0

stock bool valid_ground(float pos[3])
{
    static float pos_down[3];
    pos_down = pos; pos_down[2] -= 35.0;
    TR_TraceHullFilter(pos,pos_down,{-GROUND_WIDTH,-GROUND_WIDTH,2.0},{GROUND_WIDTH,GROUND_WIDTH,5.0},MASK_PTG|MASK_WATER,TraceFilterStatic);
    return TR_DidHit(INVALID_HANDLE);
    //if (TR_DidHit(INVALID_HANDLE))
    //{
        //static float pos_hit[3],normal[3];
        //TR_GetPlaneNormal(INVALID_HANDLE,normal);
        //LogMessage("Ground hit %f %f %f", normal[0], normal[1], normal[2]);
    //    return true;
    //}
    // TR_GetEndPosition(float pos[3], Handle hndl)
    // TR_GetPlaneNormal(Handle hndl, float normal[3])
    //return false;
}

// Determine if entity is solid to players and zombies from m_CollisionGroup, m_nSolidType and m_usSolidFlags
stock bool entity_solid(int entity)
{
    if (GetEntProp(entity, Prop_Send, "m_nSolidType") == 0) return false;
    if (GetEntProp(entity, Prop_Send, "m_usSolidFlags") & 0x0004) return false; // FSOLID_NOT_SOLID 
    switch (GetEntProp(entity, Prop_Send, "m_CollisionGroup"))
    {
        case 1: return false; // COLLISION_GROUP_DEBRIS
        case 2: return false; // COLLISION_GROUP_DEBRIS_TRIGGER
    }
    return true;
}

///////////// Connections

// Fill conList with NavConnection (navArea+connection_type) to navArea. returns length of array
stock int GetNavConnections(Address navArea, ArrayList conList, int team = TEAM_SURVIVOR,
                            bool adjacent = true, bool elevator = true, bool ladder = true, int filter = CON_KEEP_FORWARD)
{
    if (navArea == Address_Null) return 0;
    conList.Clear();
    ArrayList tempList = new ArrayList();
    static NavConnection nav_connection;
    Address adjArea;
    int i;
    if (adjacent)
    {
        for (int dir = 0; dir < 4; dir++)
        {
            tempList.Clear();
            L4D_NavArea_GetAdjacentAreas(navArea, dir, tempList);
            for (i = 0; i < tempList.Length; i++)
            {
                adjArea = tempList.Get(i);
                if (adjArea == Address_Null || adjArea == navArea) continue;
                if (navmesh_adjacent_too_far(navArea,adjArea))
                {
                    #if DEBUG>1
                        LogMessage("navmesh_adjacent_too_far %d -> %d", navArea, adjArea);
                    #endif
                    continue;
                }
                switch (filter)
                {
                    case CON_KEEP_FORWARD:
                    {
                        if (!adjacent_connected(navArea,adjArea)) continue;
                    }
                    case CON_KEEP_BACKWARD:
                    {
                        if (!adjacent_connected(adjArea,navArea)) continue;
                    }
                    default: // CON_KEEP_ALL
                    {
                        if (!adjacent_connected(navArea,adjArea) && !adjacent_connected(adjArea,navArea)) continue;
                    }
                }
                nav_connection.navArea = adjArea;
                nav_connection.connectiontype = CONNECTED_ADJACENT;
                conList.PushArray(nav_connection);
            }
        }
    }
    if (elevator && team!=TEAM_INFECTED) // typically only survivors can use elevators
    {
        adjArea = navArea_elevator_navArea(navArea);
        if (adjArea != Address_Null)
        {
            nav_connection.navArea = adjArea;
            nav_connection.connectiontype = CONNECTED_ELEVATOR;
            conList.PushArray(nav_connection);
        }
    }
    if (ladder)
    {
        int count = navArea_ladder_navAreas(navArea,tempList,team);
        for (i = 0; i < count; i++)
        {
            adjArea = tempList.Get(i);
            nav_connection.navArea = adjArea;
            nav_connection.connectiontype = CONNECTED_LADDER;
            conList.PushArray(nav_connection);
        }                
    }
    delete tempList;
    return conList.Length;
}

// Check if connection from -> to can be made.
// check_ladder manually searches for nearby func_simpleladder
//stock bool cell_connected(Cell from, Cell to)
stock bool cell_connected(Cell from, Cell to, bool check_ladder = true)
{
    if (from.navArea != Address_Null && to.navArea != Address_Null)
    { 
        if (navArea_connected(from.navArea,to.navArea)) return true;
    }
    if (check_ladder) // manual ladder search, expensive
    {
        static Cell cell;
        if (try_ladder(from.flow,from.center,cell) && cell_connected(cell,to,false)) return true;
    }
    return false;
}

// Check if connection from -> to can be made.
stock bool navArea_connected(Address from, Address to, int team = TEAM_SURVIVOR)
{
    if (from == Address_Null || to == Address_Null) return false;
    if (from == to) return true;
    if (elevator_from_to(from,to)>0) return true;
    if (ladder_from_to(from,to,team)>0) return true;
    if (navmesh_adjacent_too_far(from,to))
    {
        #if DEBUG>1
            LogMessage("navmesh_adjacent_too_far %d -> %d", from, to);
        #endif
        return false;
    }
    return adjacent_connected(from,to);
}

// Check if from -> to is connected adjacently
stock bool adjacent_connected(Address from, Address to)
{
    for (int dir = 0; dir < 4; dir++)
    {
        if (L4D_NavArea_IsConnected(from,to,dir)) return true;
    }
    return false;
}

ArrayList ladders1, ladders2;

// Return func_simpleladder connecting from -> to. returns -1 on failure.
stock int ladder_from_to(Address from, Address to, int team = TEAM_SURVIVOR, bool verify = true)
{
    if (from == Address_Null || to == Address_Null) return -1;
    if (ladders1 == null) ladders1 = new ArrayList();
    ladders1.Clear();
    int count1 = NavArea_GetLadders(from,ladders1);
    if (count1<=0) return -1;

    if (ladders2 == null) ladders2 = new ArrayList();
    ladders2.Clear();
    int count2 = NavArea_GetLadders(to,ladders2);
    if (count2<=0) return -1;

    for (int i1 = 0; i1 < ladders1.Length; i1++)
    {
        int ladder = ladders1.Get(i1);
        if (ladder<=0 || !IsValidEntity(ladder)) continue;
        for (int i2 = 0; i2 < ladders2.Length; i2++)
        {
            if (ladders2.Get(i2)==ladder)
            {
                if (verify) // verify classname
                {
                    static char class[32];
                    GetEntityClassname(ladder,class,sizeof(class));
                    if (strncmp(class,"func_simpleladder",17,false)!=0) continue;
                }
                int team_ladder = GetEntProp(ladder, Prop_Send, "m_iTeamNum");
                if (team_ladder==0 || team_ladder==team) return ladder;
            }
        }
    }
    return -1;
}

// Find other navAreas connected to navArea via ladder.
stock int navArea_ladder_navAreas(Address from, ArrayList navList, int team = TEAM_SURVIVOR, bool verify = true)
{
    if (from==Address_Null || !elevator_available) return 0;
    if (ladders1 == null) ladders1 = new ArrayList();
    ladders1.Clear();
    int count = NavArea_GetLadders(from,ladders1);
    if (count<=0) return 0;
    navList.Clear();
    static float start[3];
    L4D_GetNavAreaCenter(from,start);
    for (int i = 0; i < ladders1.Length; i++)
    {
        int ladder = ladders1.Get(i);
        if (ladder<=0 || !IsValidEntity(ladder)) continue;
        if (verify) // verify classname
        {
            static char class[32];
            GetEntityClassname(ladder,class,sizeof(class));
            if (strncmp(class,"func_simpleladder",17,false)!=0) continue;
        }
        int team_ladder = GetEntProp(ladder, Prop_Send, "m_iTeamNum");
        if (team_ladder!=0 && team_ladder!=team) continue;
        static float pos1[3],pos2[3];
        GetEntPropVector(ladder, Prop_Send, "m_vecMaxs", pos1);
        GetEntPropVector(ladder, Prop_Send, "m_vecMins", pos2);
        SortTwoVectorsClosest(start,pos1,pos2);
        if (navmesh_xy_too_far(from,pos1)) continue;
        Address to = L4D_GetNearestNavArea(pos2,500.0,true,false,false,TEAM_SURVIVOR);
        #if DEBUG>1
        LogMessage("navArea_ladder_navAreas %d -> %d", from, to);
        #endif
        if (to==Address_Null || to==from) continue;
        navList.Push(to);
    }
    return navList.Length;
}

// Fill ladderList with func_simpleladder connected to navArea.
stock int NavArea_GetLadders(Address navArea, ArrayList ladderList)
{
    if (!elevator_available || navArea == Address_Null) return 0;
    return L4D_NavArea_GetLadder(navArea,ladderList);
}

// Return func_elevator connecting from -> to. returns -1 on failure.
stock int elevator_from_to(Address from, Address to)
{
    if (!elevator_available || from == Address_Null || to == Address_Null) return -1;
    int elevator = NavArea_GetElevator(from);
    if (elevator<=0 || !IsValidEntity(elevator)) return -1;
    if (elevator == NavArea_GetElevator(to)) return elevator;
    return -1;
}

// Get other navArea connecting navArea via elevator
stock Address navArea_elevator_navArea(Address from)
{
    if (from==Address_Null || !elevator_available) return Address_Null;
    int elevator = NavArea_GetElevator(from);
    if (elevator<=0 || !IsValidEntity(elevator)) return Address_Null;
    static float start[3],pos[3],pos1[3],pos2[3];
    L4D_GetNavAreaCenter(from,start);
    GetEntPropVector(elevator, Prop_Send, "m_vecOrigin", pos);
    pos1 = pos; pos2 = pos;
    pos1[2] = GetEntPropFloat(elevator, Prop_Send, "m_movementStartZ");
    pos2[2] = GetEntPropFloat(elevator, Prop_Send, "m_destinationFloorPosition");
    SortTwoVectorsClosest(start,pos1,pos2);
    Address to = L4D_GetNearestNavArea(pos2,500.0,true,false,false,TEAM_SURVIVOR);
    if (to==Address_Null || to==from) return Address_Null;
    return to;
}

// Wrapper for L4D_NavArea_GetElevator with classname verification.
// Fixes exception in custom campaign "Military Industrial Complex II"
stock int NavArea_GetElevator(const Address from)
{
    if (from==Address_Null || !elevator_available) return -1;
    int elevator = L4D_NavArea_GetElevator(from);
    if (elevator<=0 || !IsValidEntity(elevator)) return -1;
    static char class[16];
    GetEntityClassname(elevator,class,sizeof(class));
    if (strncmp(class,"func_elevator",13,false)==0) return elevator;
    return -1;
}

// Check if nav area is relevant to survivor escape path.
stock bool navArea_escape(Address navArea)
{
    if (navArea == Address_Null) return false;
    int spawnAttrs = L4D_GetNavArea_SpawnAttributes(navArea);
    if (spawnAttrs & NAV_SPAWN_ESCAPE_ROUTE) return true;
    if (spawnAttrs & NAV_SPAWN_CHECKPOINT) return true;
    if (spawnAttrs & NAV_SPAWN_PLAYER_START) return true;
    if (spawnAttrs & NAV_SPAWN_RESCUE_VEHICLE) return true;
    return false;
}

// Acknowledge navmesh change. Ptg must be recalculated after NAV_COOLDOWN. If recompute, recalculate without cooldown.
stock void NavChanged(bool recompute = false)
{
    Guide_Cleanup();
    t_nav = GetGameTime();
    if (recompute) t_nav = t_nav - NAV_COOLDOWN + 0.1;
    if (!enable || !gamemode_guidable || !map_started || !nav_started || timer_nav != null) return;
    if (finale && finale_rescue && finale_stitched && g_hCvarFinaleAuto.BoolValue) Guide_All_Clients();
    else timer_nav = CreateTimer( (recompute) ? 0.1 : NAV_COOLDOWN , Timer_CheckRequests, _, TIMER_FLAG_NO_MAPCHANGE );
}

// return true if given flow value is better than old value. increasing=true if better is bigger.
stock bool flow_better(const float flow_new, const float flow_old, const bool increasing = true)
{
    if (increasing) return (flow_new)>=flow_old;
    else return (flow_new)<=flow_old;
}

stock bool IsValidClient(int client, bool replaycheck = true)
{
	if (client<1 || client>MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

///////////// SDK

void LoadSDK()
{
    g_bFlowRecomputeHooked = false;
    g_hRecomputeFlow = null;
    g_hRecomputeFlowDetour = null;
    Handle gd = LoadGameConfigFile(PLUGIN_NAME);
    if (gd == null)
    {
        LogMessage("Missing gamedata file: %s.txt", PLUGIN_NAME);
        delete gd;
        return;
    }

    StartPrepSDKCall(SDKCall_Raw);
    if (!PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "TerrorNavMesh::RecomputeFlowDistances"))
    {
        LogMessage("RecomputeFlowDistances PrepSDKCall_SetFromConf failed");
    }
    g_hRecomputeFlow = EndPrepSDKCall();
    if (g_hRecomputeFlow == null)
    {
        LogMessage("RecomputeFlowDistances SDKCall setup failed");
    }

    g_hRecomputeFlowDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
    if (g_hRecomputeFlowDetour == null)
    {
        LogMessage("RecomputeFlowDistances DHookCreateDetour failed");
    }
    if (!DHookSetFromConf(g_hRecomputeFlowDetour, gd, SDKConf_Signature, "TerrorNavMesh::RecomputeFlowDistances"))
    {
        LogMessage("RecomputeFlowDistances failed");
        g_hRecomputeFlowDetour = null;
    }
    if (g_hRecomputeFlowDetour != null)
    {
        g_bFlowRecomputeHooked = g_hRecomputeFlowDetour.Enable(Hook_Post, Hook_RecomputeFlowPost);
    }
    delete gd;
}

public MRESReturn Hook_RecomputeFlowPost(Address pThis)
{
    #if DEBUG>1
    LogMessage("RecomputeFlowDistances");
    #endif
    NavChanged(true);
    return MRES_Ignored;
}