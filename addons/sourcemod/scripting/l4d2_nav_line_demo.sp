#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define PLUGIN_VERSION "0.1.0"
#define GAMEDATA_FILE "l4d_predict_tank_glow"
#define KEY_GETNEXTESCAPESTEP "TerrorNavArea::GetNextEscapeStep"
#define KEY_m_vecCenter "CNavArea::m_vecCenter"
#define NULL_NAV_AREA view_as<TerrorNavArea>(0)

Handle g_hSDKCall_GetNextEscapeStep;
int g_iOffs_m_vecCenter = -1;

methodmap TerrorNavArea
{
    public bool Valid()
    {
        return this != NULL_NAV_AREA;
    }

    public TerrorNavArea GetNextEscapeStep(int &traverseType = 0)
    {
        return SDKCall(g_hSDKCall_GetNextEscapeStep, this, traverseType);
    }

    public void GetCenter(float vec[3])
    {
        Address base = view_as<Address>(this);
        vec[0] = LoadFromAddress(base + view_as<Address>(g_iOffs_m_vecCenter), NumberType_Int32);
        vec[1] = LoadFromAddress(base + view_as<Address>(g_iOffs_m_vecCenter + 4), NumberType_Int32);
        vec[2] = LoadFromAddress(base + view_as<Address>(g_iOffs_m_vecCenter + 8), NumberType_Int32);
    }
}

public Plugin myinfo =
{
    name = "[L4D2] NAV Line Demo",
    author = "sp, OpenAI",
    description = "Builds and draws a demo NAV route from start saferoom door to end saferoom door.",
    version = PLUGIN_VERSION,
    url = ""
};

ConVar g_cvEnabled;
ConVar g_cvSearchDist;
ConVar g_cvIgnoreBlockers;
ConVar g_cvDrawInterval;
ConVar g_cvBeamWidth;
ConVar g_cvBeamColor;
ConVar g_cvMaxAreas;
ConVar g_cvRenderRange;

ArrayList g_hRoutePoints;
Handle g_hDrawTimer;
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iRouteSegments;
bool g_bRouteReady;
bool g_bRouteVisible;
float g_fRouteLength;

public void OnPluginStart()
{
    LoadRouteSDK();

    g_cvEnabled = CreateConVar("l4d2_navline_enabled", "1", "Enable NAV line demo.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvSearchDist = CreateConVar("l4d2_navline_search_dist", "1000.0", "Max distance to search for a NavArea near each saferoom door.", FCVAR_NOTIFY, true, 64.0);
    g_cvIgnoreBlockers = CreateConVar("l4d2_navline_ignore_blockers", "1", "Ignore NAV blockers while validating route.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvDrawInterval = CreateConVar("l4d2_navline_draw_interval", "0.5", "How often to redraw temp beam route.", FCVAR_NOTIFY, true, 0.1, true, 5.0);
    g_cvBeamWidth = CreateConVar("l4d2_navline_width", "3.0", "Temp beam width.", FCVAR_NOTIFY, true, 0.5, true, 32.0);
    g_cvBeamColor = CreateConVar("l4d2_navline_color", "0 255 128 220", "Route color as R G B A.", FCVAR_NOTIFY);
    g_cvMaxAreas = CreateConVar("l4d2_navline_max_areas", "2048", "Safety cap for escape-step traversal.", FCVAR_NOTIFY, true, 16.0, true, 8192.0);
    g_cvRenderRange = CreateConVar("l4d2_navline_render_range", "1250.0", "Only render route segments near a player within this distance.", FCVAR_NOTIFY, true, 1.0);

    RegAdminCmd("sm_navline", Command_ToggleRoute, ADMFLAG_ROOT, "Toggle the cached demo NAV line display.");
    RegAdminCmd("sm_navline_clear", Command_ClearRoute, ADMFLAG_ROOT, "Clear the demo NAV line.");
    RegAdminCmd("sm_navline_length", Command_RouteLength, ADMFLAG_ROOT, "Print the cached demo NAV line length.");

    g_hRoutePoints = new ArrayList(3);
}

void LoadRouteSDK()
{
    Handle conf = LoadGameConfigFile(GAMEDATA_FILE);
    if (conf == null)
        SetFailState("Missing gamedata \"" ... GAMEDATA_FILE ... "\"");

    StartPrepSDKCall(SDKCall_Raw);
    if (!PrepSDKCall_SetFromConf(conf, SDKConf_Signature, KEY_GETNEXTESCAPESTEP))
        SetFailState("Missing signature \"" ... KEY_GETNEXTESCAPESTEP ... "\"");

    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
    g_hSDKCall_GetNextEscapeStep = EndPrepSDKCall();
    if (g_hSDKCall_GetNextEscapeStep == null)
        SetFailState("Failed to prepare SDKCall for \"" ... KEY_GETNEXTESCAPESTEP ... "\"");

    g_iOffs_m_vecCenter = GameConfGetOffset(conf, KEY_m_vecCenter);
    if (g_iOffs_m_vecCenter == -1)
        SetFailState("Missing offset \"" ... KEY_m_vecCenter ... "\"");

    delete conf;
}

public void OnMapStart()
{
    g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
    g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
    ClearRoute();

    if (g_cvEnabled.BoolValue)
        CreateTimer(3.0, Timer_DelayedBuildRoute, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd()
{
    ClearRoute();
}

public Action Command_ToggleRoute(int client, int args)
{
    if (!EnsureRouteBuilt())
    {
        ReplyToCommand(client, "[NavLine] Failed to build route. Check server console for details.");
        return Plugin_Handled;
    }

    if (g_bRouteVisible)
    {
        StopDrawingRoute();
        ReplyToCommand(client, "[NavLine] Route display off. Length: %.1f units (%d segments).", g_fRouteLength, g_iRouteSegments);
    }
    else
    {
        StartDrawingRoute();
        ReplyToCommand(client, "[NavLine] Route display on. Length: %.1f units (%d segments).", g_fRouteLength, g_iRouteSegments);
    }

    return Plugin_Handled;
}

public Action Command_ClearRoute(int client, int args)
{
    ClearRoute();
    ReplyToCommand(client, "[NavLine] Route cleared.");
    return Plugin_Handled;
}

public Action Command_RouteLength(int client, int args)
{
    if (!EnsureRouteBuilt())
    {
        ReplyToCommand(client, "[NavLine] Failed to build route. Check server console for details.");
        return Plugin_Handled;
    }

    ReplyToCommand(client, "[NavLine] Route length: %.1f units (%d segments, %d points).", g_fRouteLength, g_iRouteSegments, g_hRoutePoints.Length);
    return Plugin_Handled;
}

public Action Timer_DelayedBuildRoute(Handle timer)
{
    if (g_cvEnabled.BoolValue)
        BuildRoute();

    return Plugin_Stop;
}

public Action Timer_DrawRoute(Handle timer)
{
    if (!g_cvEnabled.BoolValue || !g_bRouteReady || !g_bRouteVisible)
    {
        g_hDrawTimer = null;
        return Plugin_Stop;
    }

    DrawRoute();
    return Plugin_Continue;
}

bool EnsureRouteBuilt()
{
    if (g_bRouteReady)
        return true;

    return BuildRoute();
}

bool BuildRoute()
{
    ClearRoute();

    int startDoor = L4D_GetCheckpointFirst();
    int endDoor = L4D_GetCheckpointLast();

    if (!IsValidEntity(startDoor) || !IsValidEntity(endDoor))
    {
        PrintToServer("[NavLine] Failed to find both checkpoint doors. start=%d end=%d", startDoor, endDoor);
        return false;
    }

    float startPos[3], endPos[3];
    GetEntPropVector(startDoor, Prop_Send, "m_vecOrigin", startPos);
    GetEntPropVector(endDoor, Prop_Send, "m_vecOrigin", endPos);

    Address startNav = FindNearestDoorNavArea(startPos);
    Address endNav = FindNearestDoorNavArea(endPos);

    if (startNav == Address_Null || endNav == Address_Null)
    {
        PrintToServer("[NavLine] Failed to find door NavAreas. start=%x end=%x", startNav, endNav);
        return false;
    }

    bool ignoreBlockers = g_cvIgnoreBlockers.BoolValue;
    if (!L4D2_NavAreaBuildPath(startNav, endNav, 0.0, 2, ignoreBlockers))
    {
        PrintToServer("[NavLine] L4D2_NavAreaBuildPath failed between saferoom door NavAreas.");
        return false;
    }

    if (!CollectEscapeRoutePoints(view_as<TerrorNavArea>(startNav), view_as<TerrorNavArea>(endNav)))
    {
        PrintToServer("[NavLine] Path exists, but escape-step traversal did not produce enough points.");
        return false;
    }

    g_iRouteSegments = g_hRoutePoints.Length - 1;
    g_fRouteLength = CalculateRouteLength();
    g_bRouteReady = true;

    PrintToServer("[NavLine] Built start-door to end-door NAV route. points=%d segments=%d length=%.1f", g_hRoutePoints.Length, g_iRouteSegments, g_fRouteLength);
    return true;
}

Address FindNearestDoorNavArea(const float pos[3])
{
    float maxDist = g_cvSearchDist.FloatValue;
    Address nav = view_as<Address>(L4D_GetNearestNavArea(pos, maxDist, true, true, true, 2));
    if (nav != Address_Null)
        return nav;

    return view_as<Address>(L4D_GetNearestNavArea(pos, maxDist, true, false, false, 2));
}

bool CollectEscapeRoutePoints(TerrorNavArea startNav, TerrorNavArea endNav)
{
    if (!startNav.Valid() || !endNav.Valid())
        return false;

    ArrayList seen = new ArrayList();
    TerrorNavArea nav = startNav;
    int maxAreas = g_cvMaxAreas.IntValue;
    bool reachedEnd = false;

    for (int i = 0; i < maxAreas && nav.Valid(); i++)
    {
        if (seen.FindValue(view_as<int>(nav)) != -1)
            break;

        seen.Push(view_as<int>(nav));
        PushNavCenter(nav);

        if (nav == endNav)
        {
            reachedEnd = true;
            break;
        }

        int traverseType = 0;
        TerrorNavArea next = nav.GetNextEscapeStep(traverseType);
        if (!next.Valid())
            break;

        nav = next;
    }

    if (!reachedEnd)
        PushNavCenter(endNav);

    delete seen;
    return g_hRoutePoints.Length >= 2;
}

void PushNavCenter(TerrorNavArea nav)
{
    float pos[3];
    nav.GetCenter(pos);
    pos[2] += 12.0;
    g_hRoutePoints.PushArray(pos, sizeof(pos));
}

void DrawRoute()
{
    if (g_iBeamSprite == -1 || g_hRoutePoints.Length < 2)
        return;

    int color[4];
    GetBeamColor(color);

    float life = g_cvDrawInterval.FloatValue + 0.1;
    float width = g_cvBeamWidth.FloatValue;
    float renderRangeSq = g_cvRenderRange.FloatValue * g_cvRenderRange.FloatValue;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || IsFakeClient(client))
            continue;

        DrawRouteForClient(client, renderRangeSq, life, width, color);
    }
}

void DrawRouteForClient(int client, float renderRangeSq, float life, float width, const int color[4])
{
    float clientPos[3];
    GetClientAbsOrigin(client, clientPos);

    ArrayList segments = new ArrayList(2);
    float start[3], end[3];

    for (int i = 0; i < g_hRoutePoints.Length - 1; i++)
    {
        g_hRoutePoints.GetArray(i, start, sizeof(start));
        g_hRoutePoints.GetArray(i + 1, end, sizeof(end));

        float distanceSq = GetPointSegmentDistanceSquared(clientPos, start, end);
        if (distanceSq > renderRangeSq)
            continue;

        int item[2];
        item[0] = i;
        item[1] = view_as<int>(distanceSq);
        segments.PushArray(item, sizeof(item));
    }

    segments.SortCustom(SortSegmentsByDistanceAsc);

    for (int i = 0; i < segments.Length; i++)
    {
        int segmentIndex = segments.Get(i, 0);
        g_hRoutePoints.GetArray(segmentIndex, start, sizeof(start));
        g_hRoutePoints.GetArray(segmentIndex + 1, end, sizeof(end));

        TE_SetupBeamPoints(start, end, g_iBeamSprite, g_iHaloSprite, 0, 0, life, width, width, 1, 0.0, color, 0);
        TE_SendToClient(client);
    }

    delete segments;
}

public int SortSegmentsByDistanceAsc(int index1, int index2, Handle array, Handle hndl)
{
    ArrayList segments = view_as<ArrayList>(array);
    float distance1 = view_as<float>(segments.Get(index1, 1));
    float distance2 = view_as<float>(segments.Get(index2, 1));

    if (distance1 < distance2)
        return -1;

    if (distance1 > distance2)
        return 1;

    return 0;
}

float GetPointSegmentDistanceSquared(const float point[3], const float start[3], const float end[3])
{
    float seg[3], toPoint[3];
    MakeVectorFromPoints(start, end, seg);
    MakeVectorFromPoints(start, point, toPoint);

    float lenSq = GetVectorDotProduct(seg, seg);
    if (lenSq <= 0.0001)
        return GetVectorDistance(point, start, true);

    float t = GetVectorDotProduct(toPoint, seg) / lenSq;
    if (t < 0.0)
        t = 0.0;
    else if (t > 1.0)
        t = 1.0;

    float nearest[3];
    nearest[0] = start[0] + seg[0] * t;
    nearest[1] = start[1] + seg[1] * t;
    nearest[2] = start[2] + seg[2] * t;

    return GetVectorDistance(point, nearest, true);
}

float CalculateRouteLength()
{
    if (g_hRoutePoints.Length < 2)
        return 0.0;

    float total;
    float start[3], end[3];

    for (int i = 0; i < g_hRoutePoints.Length - 1; i++)
    {
        g_hRoutePoints.GetArray(i, start, sizeof(start));
        g_hRoutePoints.GetArray(i + 1, end, sizeof(end));
        total += GetVectorDistance(start, end);
    }

    return total;
}

void StartDrawingRoute()
{
    if (!g_bRouteReady)
        return;

    g_bRouteVisible = true;

    if (g_hDrawTimer == null)
        g_hDrawTimer = CreateTimer(g_cvDrawInterval.FloatValue, Timer_DrawRoute, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    DrawRoute();
}

void StopDrawingRoute()
{
    if (g_hDrawTimer != null)
    {
        delete g_hDrawTimer;
        g_hDrawTimer = null;
    }

    g_bRouteVisible = false;
}

void GetBeamColor(int color[4])
{
    char buffer[64];
    g_cvBeamColor.GetString(buffer, sizeof(buffer));

    char parts[4][8];
    int count = ExplodeString(buffer, " ", parts, sizeof(parts), sizeof(parts[]));

    color[0] = (count > 0) ? StringToInt(parts[0]) : 0;
    color[1] = (count > 1) ? StringToInt(parts[1]) : 255;
    color[2] = (count > 2) ? StringToInt(parts[2]) : 128;
    color[3] = (count > 3) ? StringToInt(parts[3]) : 220;

    for (int i = 0; i < 4; i++)
        color[i] = ClampInt(color[i], 0, 255);
}

int ClampInt(int value, int minValue, int maxValue)
{
    if (value < minValue)
        return minValue;

    if (value > maxValue)
        return maxValue;

    return value;
}

void ClearRoute()
{
    StopDrawingRoute();

    if (g_hRoutePoints != null)
        g_hRoutePoints.Clear();

    g_iRouteSegments = 0;
    g_fRouteLength = 0.0;
    g_bRouteReady = false;
}
