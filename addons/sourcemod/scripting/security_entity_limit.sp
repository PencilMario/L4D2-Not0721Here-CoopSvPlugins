#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <logger>

#define PLUGIN_VERSION "0.5.5"
#pragma newdecls required

int g_iHighestIndex = 100;

float g_flSpawnTime[2049] = {0.0};

bool g_bLogActions = false;
bool g_bShowCounter[MAXPLAYERS+1];
bool g_bCleaningMode = false;
bool g_bCriticalState = false;
Logger log;
Handle g_hCounterHud;

ConVar g_cvarLogEnable;

public Plugin myinfo =
{
	name = "Security Entity Limit!",
	author = "Benoist3012",
	description = "Remove old entities when server is near the entity limit!",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=265902"
}
public void OnPluginStart()
{
	log = new Logger("entity_log", LoggerType_NewLogFile);
	CreateConVar("sm_sel_version", PLUGIN_VERSION, "Security Entity Limit version", FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_cvarLogEnable = CreateConVar("sm_sel_log_enabled", "1", "Enable or Disable SEL logs?", FCVAR_NONE, true, 0.0, true, 1.0);
	g_cvarLogEnable.AddChangeHook(ConVar_SelLogToggle);
	g_bLogActions = g_cvarLogEnable.BoolValue;
	
	log.info("Security Entity Limit [SEL] Activate!");
	RegAdminCmd("sm_sel_show_counter", Command_Counter, ADMFLAG_SLAY);
	
	g_hCounterHud = CreateHudSynchronizer();
	log.info("[SEL]Current version: %s\nPlugin made by Benoist3012!", PLUGIN_VERSION);
	
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	// HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_Post);
}

public void OnMapStart()
{
	g_bCleaningMode = false;
	g_bCriticalState = false;
}

public Action Event_RoundStart(Event event, const char[] sEventName, bool db)
{
	g_iHighestIndex = 100;
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "*")) != -1 && iEnt < 2048)
	{
		if (iEnt > g_iHighestIndex)
			g_iHighestIndex = iEnt;
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	char buffer[64];
	if (64 < iEntity < 2049)
	{
		g_flSpawnTime[iEntity] = GetGameTime();
		
		if (iEntity >= 2000)
		{
			if (g_bLogActions && !g_bCriticalState)
			{
				log.info("[SEL]!!!WARNING!!! Server reached the critical limit, SEL is now blocking every entities from spawning.");
				g_bCriticalState = true;
			}
			SDKHook(iEntity, SDKHook_Spawn, Hook_NoSpawn);
			SDKHook(iEntity, SDKHook_SpawnPost, Hook_SpawnNkill);
		}
		else
		{
			g_bCriticalState = false;
		}
		
		if (iEntity >= 1950)
		{
			if (g_bLogActions && !g_bCleaningMode && iEntity < 2000)
			{
				log.info("[SEL]The server is close of the limit, cleanning mode enabled");
				g_bCleaningMode = true;
			}
			
			int iMaxEntitiesKill = 20, iCounter = 0;
			float flTime;
			
			for (int iEnt = g_iHighestIndex+1 ; iEnt < 2048 && iCounter <= iMaxEntitiesKill; iEnt++)
			{
				if(IsValidEntity(iEnt))
				{
					flTime = g_flSpawnTime[iEnt];
					if(120.0 <= (GetGameTime() - flTime))
					{
						AcceptEntityInput(iEnt, "Kill");
						GetEntityClassname(iEnt,buffer,sizeof(buffer));
						if (g_bLogActions)
							log.info("[SEL] Entity %i(%s) has been deleted", iEnt, buffer);
						iCounter++;
					}
				}
			}
			
			if (iCounter < iMaxEntitiesKill)
			{
				for (int iEnt = g_iHighestIndex+1 ; iEnt < 2048 && iCounter <= iMaxEntitiesKill; iEnt++)
				{
					if(IsValidEntity(iEnt))
					{
						AcceptEntityInput(iEnt, "Kill");
						if (g_bLogActions)
							log.info("[SEL]No old entities in the map, the entity %i(%s) has been deleted",iEnt,buffer);
						iCounter++;
					}
				}
			}
		}
		else
		{
			g_bCriticalState = false;
			g_bCleaningMode = false;
		}
	}
}

public Action Hook_NoSpawn(int iEntity)
{
	SDKUnhook(iEntity, SDKHook_Spawn, Hook_NoSpawn);
	return Plugin_Handled;
}

public Action Hook_SpawnNkill(int iEntity)
{
	AcceptEntityInput(iEntity, "Kill");
	SDKUnhook(iEntity, SDKHook_SpawnPost, Hook_SpawnNkill);
	return Plugin_Continue;
}

public void OnEntityDestroyed(int iEntity)
{
	if(2048 >= iEntity > 0)
		g_flSpawnTime[iEntity] = 0.0;
}

public Action Command_Counter(int iClient, int iArgs)
{
	if (iClient <= 0 || iClient > MaxClients) return Plugin_Handled;
	
	if (g_bShowCounter[iClient])
	{
		g_bShowCounter[iClient] = false;
		ReplyToCommand(iClient, "[SEL]Counter disabled!");
		SetHudTextParams(0.035, 0.45, 400.0, 255, 255, 255, 255);
		ShowSyncHudText(iClient, g_hCounterHud," ");
	}
	else
	{
		g_bShowCounter[iClient] = true;
		ReplyToCommand(iClient, "[SEL]Counter enabled!");
	}
	return Plugin_Handled;
}

public void OnGameFrame()
{
	int iCounter = 0;
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "*")) != -1 && iEnt < 2048)
		iCounter++;
	
	for(int i = 1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) &&  g_bShowCounter[i])
		{
			SetHudTextParams(0.035, 0.15, 400.0, 255, 255, 255, 255);
			if (g_bCriticalState)
				PrintHintText(i,"[SEL]!!!警告，服务器实体数量已接近崩溃值!!! (阻止实体生成清理垃圾实体) 当前地图实体: %i/2048", iCounter);
			else if (g_bCleaningMode)
				PrintHintText(i,"[SEL]服务器实体已接近上限值!(清理中) 当前地图实体: %i/2000", iCounter);
			else
				PrintHintText(i,"[SEL]当前地图实体: %i", iCounter);
		}
	}
}

public void OnClientPutInServer(int iClient)
{
	g_bShowCounter[iClient] = false;
	SetHudTextParams(0.035, 0.15, 400.0, 255, 255, 255, 255);
	ShowSyncHudText(iClient, g_hCounterHud," ");
}

public void ConVar_SelLogToggle(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (strcmp(newValue, "0") == 0)
		g_bLogActions = false;
	else
		g_bLogActions = true;
}