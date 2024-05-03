#pragma semicolon 1

#define PLUGIN_NAME 		"HUD Player Display Manager"
#define PLUGIN_AUTHOR 		"gabuch2"
#define PLUGIN_DESCRIPTION 	"If there are more than 4 survivors on the team, only show the nearest 3 in the HUD."
#define PLUGIN_VERSION 		"1.0.1"
#define PLUGIN_URL			"https://github.com/szGabu/L4D2HudDisplayManager"

#define DEBUG false
#define PER_PLAYER_OPTIONAL false

#define L4D_TEAM_SURVIVORS 	2
#define L4D_TEAM_FOUR		4

#include <sourcemod>
#include <sdktools>
#include <sendproxy>
#include <sdkhooks>

#pragma newdecls required

ConVar	g_cvarEnabled;
ConVar	g_cvarQueryTime;

int		g_iTerrorPlayerManagerEnt = -1;

int		g_iNearbyPlayers[MAXPLAYERS+1][4];
int		g_iObserverMode[MAXPLAYERS+1];
int		g_iObserverTarget[MAXPLAYERS+1];
float	g_fDeadSpot[MAXPLAYERS+1][3];

bool	g_bCvarEnabled;
float	g_fCvarQueryTime;

Handle	g_hTimer;

enum struct DistData
{
    int index;
    float dist;
}

public Plugin myinfo =  
{  
    name = PLUGIN_NAME,  
    author = PLUGIN_AUTHOR,  
    description = PLUGIN_DESCRIPTION,  
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
}  

public void OnPluginStart()  
{  
    g_cvarEnabled = CreateConVar("sm_l4d2_hud_display_enabled", "1", "Enables HUD Player Display Manager.", FCVAR_DONTRECORD | FCVAR_NOTIFY);
    g_cvarQueryTime = CreateConVar("sm_l4d2_hud_display_query_time", "3", "Determines the time between position checks. Less is smoother, but may lead to increased overhead. 3.0 is my personal recommended value but you can adjust it as needed.", FCVAR_DONTRECORD | FCVAR_NOTIFY);
    CreateConVar("sm_l4d2_hud_display_version", PLUGIN_VERSION, "Version of HUD Player Display Manager", FCVAR_DONTRECORD | FCVAR_NOTIFY);
    g_cvarEnabled.AddChangeHook(ConVarChanged_Cvars);
    g_cvarQueryTime.AddChangeHook(ConVarChanged_Cvars);

    GetCvars();
}

public void OnPluginEnd()
{
    for(int iClient = 1; iClient < MaxClients; iClient++)
    {
        if(IsClientConnected(iClient) && GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
        {
            UnhookClient(iClient);
        }
    }
}

public void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
    if(GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
    {
        HookClient(iClient);
    }
}

public void OnClientDisconnect(int iClient)
{
    if(iClient)
        UnhookClient(iClient);
}

public void Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

    if(iClient && IsClientInGame(iClient) && GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
        GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", g_fDeadSpot[iClient]);
}

public void OnMapStart() 
{
    if(g_cvarEnabled)
        RequestFrame(OnFrameStart);
}

public Action Timer_NearPlayersLoop(Handle timer)
{
    #if DEBUG
    PrintToServer("[DEBUG] Calling Timer_NearPlayersLoop()");
    #endif	
    for (int iClient = 1; iClient <= MaxClients; iClient++) 
    {
        if(IsClientInGame(iClient) && IsClientConnected(iClient) && GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
        {
            ArrayList players = new ArrayList(sizeof(DistData));

            if(!IsPlayerAlive(iClient))
            {
                g_iObserverTarget[iClient] = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
                g_iObserverMode[iClient] = GetEntProp(iClient, Prop_Send, "m_iObserverMode");
                #if DEBUG
                PrintToServer("[DEBUG] g_iObserverTarget[%d] (%N) is %d", iClient, iClient, g_iObserverTarget[iClient]);
                PrintToServer("[DEBUG] g_iObserverMode[%d] (%N) is %d", iClient, iClient, g_iObserverMode[iClient]);
                #endif
            }

            for (int iTarget = 1; iTarget <= MaxClients; iTarget++) 
            {
                if(iTarget != iClient && IsClientInGame(iTarget) && IsClientConnected(iTarget) && GetClientTeam(iTarget) == L4D_TEAM_SURVIVORS)
                {
                    DistData data;
                    data.index = iTarget;
                    if(IsPlayerAlive(iTarget))
                        data.dist = GetEntitiesDistance(iClient, iTarget);
                    else
                    {
                        if(g_fDeadSpot[iTarget][0] == 0.0 && g_fDeadSpot[iTarget][1] == 0.0 && g_fDeadSpot[iTarget][2] == 0.0)
                            continue;
                        data.dist = GetEntityDistanceToVector(iClient, g_fDeadSpot[iTarget]);
                    }
                    players.PushArray(data);
                }
            }

            players.SortCustom(SortByDist);

            //ArrayList.find is extremely expensive (on SendProxy) this should work instead
            for (int iNearbyIndex = 0; iNearbyIndex < 3; iNearbyIndex++) 
            {
                if(players.Length > iNearbyIndex)
                    g_iNearbyPlayers[iClient][iNearbyIndex] = players.Get(iNearbyIndex, DistData::index); 
            }

            delete players;
        }
    }

    return Plugin_Continue;
}

public void FindTerrorManager()
{
    g_iTerrorPlayerManagerEnt = FindEntityByClassname(g_iTerrorPlayerManagerEnt, "terror_player_manager");
    #if DEBUG
    PrintToServer("[DEBUG] terror_player_manager is %d", g_iTerrorPlayerManagerEnt);
    #endif
}

public void OnFrameStart()
{
    FindTerrorManager();
    #if DEBUG
    PrintToServer("[DEBUG] OnFrameStart() is called and condition passed, starting Timer.");
    #endif
    g_hTimer = CreateTimer(g_fCvarQueryTime, Timer_NearPlayersLoop, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd() 
{
    g_iTerrorPlayerManagerEnt = -1;
}

public Action SurvivorTeamCallback(int iEntity, char[] propname, int &iValue, int iElement, int iClient)
{
    // Check if the client is in the survivor team and in a valid game state
    if (GetSurvivorCount() > 4 && iClient != iElement && IsClientInGame(iElement) && IsClientInGame(iClient) && GetClientTeam(iElement) == L4D_TEAM_SURVIVORS && GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
    {
        int iSelfEnt = (IsPlayerAlive(iClient) || g_iObserverMode[iClient] == 6) ? iClient : g_iObserverTarget[iClient];

        // Check if iSelfEnt is a valid client and in the survivor team
        if (iSelfEnt > 0 && iSelfEnt <= MaxClients && IsClientInGame(iSelfEnt) && GetClientTeam(iSelfEnt) == L4D_TEAM_SURVIVORS)
        {
            if (iSelfEnt != iElement) // Skip unnecessary checks if iSelfEnt is the spectator
            {
                bool bFoundNearest = false;
                for (int iIndex = 0; iIndex <= 3; iIndex++)
                {
                    if (iElement == g_iNearbyPlayers[iSelfEnt][iIndex])
                    {
                        bFoundNearest = true;
                        break;
                    }
                }

                if (!bFoundNearest)
                {
                    iValue = L4D_TEAM_FOUR;
                    return Plugin_Changed;
                }
            }
        }
    }
    
    return Plugin_Stop;
}

float GetEntitiesDistance(int iEnt1, int iEnt2)
{
    float fOrig1[3];
    GetEntPropVector(iEnt1, Prop_Send, "m_vecOrigin", fOrig1);
    
    float fOrig2[3];
    GetEntPropVector(iEnt2, Prop_Send, "m_vecOrigin", fOrig2);

    return GetVectorDistance(fOrig1, fOrig2);
}

float GetEntityDistanceToVector(int iEnt1, const float fOrig2[3])
{
    float fOrig1[3];
    GetEntPropVector(iEnt1, Prop_Send, "m_vecOrigin", fOrig1);

    return GetVectorDistance(fOrig1, fOrig2);
}

int GetSurvivorCount()
{
    int iSurvCount = 0;
    
    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if(IsClientConnected(iClient) && IsClientInGame(iClient) && GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
            iSurvCount++;
    }
    return iSurvCount;
}

int SortByDist(int index1, int index2, Handle array, Handle hndl)
{
    float dist1 = view_as<ArrayList>(array).Get(index1, DistData::dist);
    float dist2 = view_as<ArrayList>(array).Get(index2, DistData::dist);
    return dist1 > dist2;
}

void ResetAllValues()
{
    for (int iTarget = 1; iTarget <= MaxClients; iTarget++) 
    {
        g_iNearbyPlayers[iTarget] = {0, 0, 0, 0};
        g_fDeadSpot[iTarget] = {0.0, 0.0, 0.0}; //reset dead spot on map start
        g_iObserverMode[iTarget] = 0;
        g_iObserverTarget[iTarget] = 0;

        UnhookClient(iTarget);
    }
}

void HookClient(int iClient)
{
    if(iClient)
    {
        if(IsValidEntity(iClient) && IsClientConnected(iClient) && GetClientTeam(iClient) == L4D_TEAM_SURVIVORS)
        {
            if(g_iTerrorPlayerManagerEnt == -1)
                FindTerrorManager();

            if(!SendProxy_IsHookedArrayProp(g_iTerrorPlayerManagerEnt, "m_iTeam", iClient))
#if PER_PLAYER_OPTIONAL
                SendProxy_HookArrayProp(g_iTerrorPlayerManagerEnt, "m_iTeam", iClient, Prop_Int, SurvivorTeamCallback, true);
#else
                SendProxy_HookArrayProp(g_iTerrorPlayerManagerEnt, "m_iTeam", iClient, Prop_Int, SurvivorTeamCallback);
#endif
        }
    }
}

void UnhookClient(int iClient)
{
    if(iClient)
    {
        if(SendProxy_IsHookedArrayProp(g_iTerrorPlayerManagerEnt, "m_iTeam", iClient))
#if PER_PLAYER_OPTIONAL
            SendProxy_UnhookArrayProp(g_iTerrorPlayerManagerEnt, "m_iTeam", iClient, Prop_Int, SurvivorTeamCallback, true);
#else
            SendProxy_UnhookArrayProp(g_iTerrorPlayerManagerEnt, "m_iTeam", iClient, Prop_Int, SurvivorTeamCallback);
#endif
    }
}

void HookAllClients()
{
    for (int iTarget = 1; iTarget <= MaxClients; iTarget++) 
    {
        HookClient(iTarget);
    }
}

void UnhookAllClients()
{
    for (int iTarget = 1; iTarget <= MaxClients; iTarget++) 
    {
        UnhookClient(iTarget);
    }
}

void HookEvents()
{
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

void UnhookEvents()
{
    UnhookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    UnhookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
    GetCvars();
}

void GetCvars()
{
    g_bCvarEnabled = g_cvarEnabled.BoolValue;
    g_fCvarQueryTime = g_cvarQueryTime.FloatValue;

    if(g_bCvarEnabled)
    {
        #if DEBUG
        PrintToServer("[DEBUG] Plugin enabled, hooking everything.");
        #endif	
        HookEvents();
        HookAllClients();
        RequestFrame(OnFrameStart);
    }
    else
    {
        #if DEBUG
        PrintToServer("[DEBUG] Plugin disabled. Bye bye.");
        #endif	
        UnhookEvents();
        UnhookAllClients();
        KillTimer(g_hTimer);
        ResetAllValues();
    }
}