#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>
#pragma semicolon 1
#pragma newdecls required
#include <logger>

Logger log;
int g_useTargetRef[MAXPLAYERS + 1];
L4D2UseAction g_useAction[MAXPLAYERS + 1];
float g_useStartedAt[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Map Hint Translator",
	author = "AlliedModders LLC",
	description = "翻译三方图的提示",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	log = new Logger("map_hint_translator", LoggerType_NewLogFile);
	log.logfirst("test");

	HookEvent("instructor_server_hint_create", Event_InstructorHintCreate);
	HookEntityOutput("point_script_use_target", "OnUseFinished", Output_UseFinished);
	HookEntityOutput("point_script_use_target", "OnUseCancelled", Output_UseCancelled);
	HookEntityOutput("point_prop_use_target", "OnUseFinished", Output_UseFinished);
	HookEntityOutput("point_prop_use_target", "OnUseCancelled", Output_UseCancelled);
	HookEntityOutput("func_button_timed", "OnTimeUp", Output_UseFinished);
	HookEntityOutput("func_button_timed", "OnUnpressed", Output_UseCancelled);
}

public void OnClientDisconnect(int client)
{
	ClearUseState(client);
}

public void OnMapStart()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		ClearUseState(client);
	}

	for (int entity = MaxClients + 1; entity < GetMaxEntities(); entity++)
	{
		if (IsValidEntity(entity))
		{
			LogEntityText(entity, "Find");
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (IsTrackedClassname(classname))
	{
		RequestFrame(Frame_LogEntityText, EntIndexToEntRef(entity));
	}
}

public void Frame_LogEntityText(any entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
	{
		LogEntityText(entity, "OnEntityCreated");
	}
}

public void L4D2_OnStartUseAction_Post(L4D2UseAction action, int client, int target)
{
	if (!IsUseActionTracked(action) || !IsValidClient(client) || !IsValidEntity(target))
	{
		return;
	}

	int previousTarget = EntRefToEntIndex(g_useTargetRef[client]);
	if (previousTarget != INVALID_ENT_REFERENCE && IsValidEntity(previousTarget))
	{
		float duration = GetGameTime() - g_useStartedAt[client];
		LogUseEvent("USE_REPLACED", client, previousTarget, g_useAction[client], duration);
	}

	g_useTargetRef[client] = EntIndexToEntRef(target);
	g_useAction[client] = action;
	g_useStartedAt[client] = GetGameTime();
	LogUseEvent("USE_STARTED", client, target, action, 0.0);
}

public void Output_UseFinished(const char[] output, int caller, int activator, float delay)
{
	LogUseOutput("USE_FINISHED", caller, activator);
}

public void Output_UseCancelled(const char[] output, int caller, int activator, float delay)
{
	LogUseOutput("USE_CANCELLED", caller, activator);
}

public void Event_InstructorHintCreate(Event event, const char[] name, bool dontBroadcast)
{
	char hintName[128];
	char caption[256];
	event.GetString("hint_name", hintName, sizeof(hintName));
	event.GetString("hint_caption", caption, sizeof(caption));

	log.info("SHOW_REQUEST hint_name=%s target=%i caption=%s",
		hintName, event.GetInt("hint_target"), caption);
}

bool IsUseActionTracked(L4D2UseAction action)
{
	return action == L4D2UseAction_Button || action == L4D2UseAction_UsePointScript;
}

bool IsValidClient(int client)
{
	return client >= 1 && client <= MaxClients && IsClientInGame(client);
}

void LogUseOutput(const char[] eventName, int entity, int activator)
{
	if (!IsValidEntity(entity))
	{
		return;
	}

	int client = FindUseClient(entity, activator);
	if (client == 0)
	{
		return;
	}

	float duration = GetGameTime() - g_useStartedAt[client];
	LogUseEvent(eventName, client, entity, g_useAction[client], duration);
	ClearUseState(client);
}

int FindUseClient(int entity, int activator)
{
	int entityRef = EntIndexToEntRef(entity);
	if (IsValidClient(activator) && g_useTargetRef[activator] == entityRef)
	{
		return activator;
	}

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && g_useTargetRef[client] == entityRef)
		{
			return client;
		}
	}

	return 0;
}

void LogUseEvent(const char[] eventName, int client, int entity, L4D2UseAction action, float duration)
{
	char steamId[32] = "UNKNOWN";
	char classname[64];
	char targetname[128];
	char useText[256];
	int hammerId = -1;

	GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), false);
	GetEntityClassname(entity, classname, sizeof(classname));
	GetOptionalEntPropString(entity, "m_iName", targetname, sizeof(targetname));
	GetEntityUseText(entity, useText, sizeof(useText));
	if (HasEntProp(entity, Prop_Data, "m_iHammerID"))
	{
		hammerId = GetEntProp(entity, Prop_Data, "m_iHammerID");
	}

	log.info("%s client=%i name=%N steamid=%s entity=%i class=%s targetname=%s hammerid=%i action=%i duration=%.2f text=%s",
		eventName, client, client, steamId, entity, classname, targetname, hammerId, action, duration, useText);
}

void ClearUseState(int client)
{
	g_useTargetRef[client] = INVALID_ENT_REFERENCE;
	g_useAction[client] = L4D2UseAction_None;
	g_useStartedAt[client] = 0.0;
}

bool IsTrackedClassname(const char[] classname)
{
	return StrEqual(classname, "env_instructor_hint")
		|| StrEqual(classname, "point_script_use_target")
		|| StrEqual(classname, "point_prop_use_target")
		|| StrEqual(classname, "func_button_timed");
}

void LogEntityText(int entity, const char[] source)
{
	char classname[64];
	GetEntityClassname(entity, classname, sizeof(classname));

	if (!IsTrackedClassname(classname))
	{
		return;
	}

	if (StrEqual(classname, "env_instructor_hint"))
	{
		LogTextProperty(entity, classname, source, "m_iszCaption");
		return;
	}

	LogTextProperty(entity, classname, source, "m_iszUseText");
	LogTextProperty(entity, classname, source, "m_iszProgressBarText");
	LogTextProperty(entity, classname, source, "m_sUseString");
	LogTextProperty(entity, classname, source, "m_sUseSubString");
}

void LogTextProperty(int entity, const char[] classname, const char[] source, const char[] property)
{
	char text[256];
	bool found;

	if (HasEntProp(entity, Prop_Send, property))
	{
		GetEntPropString(entity, Prop_Send, property, text, sizeof(text));
		found = true;
	}
	else if (HasEntProp(entity, Prop_Data, property))
	{
		GetEntPropString(entity, Prop_Data, property, text, sizeof(text));
		found = true;
	}

	if (found && text[0] != '\0')
	{
		log.info("%s %s: %i:%s=%s", source, classname, entity, property, text);
	}
}

bool GetOptionalEntPropString(int entity, const char[] property, char[] text, int maxlength)
{
	text[0] = '\0';
	if (HasEntProp(entity, Prop_Send, property))
	{
		GetEntPropString(entity, Prop_Send, property, text, maxlength);
		return true;
	}
	if (HasEntProp(entity, Prop_Data, property))
	{
		GetEntPropString(entity, Prop_Data, property, text, maxlength);
		return true;
	}

	return false;
}

void GetEntityUseText(int entity, char[] text, int maxlength)
{
	static const char properties[][] =
	{
		"m_iszUseText",
		"m_iszProgressBarText",
		"m_sUseString",
		"m_sUseSubString"
	};

	text[0] = '\0';
	for (int i = 0; i < sizeof(properties); i++)
	{
		if (GetOptionalEntPropString(entity, properties[i], text, maxlength) && text[0] != '\0')
		{
			return;
		}
	}
}
