#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define PLUGIN_VERSION "1.1"

int g_MaxSpawnOnce = 0,
	g_iSIFix;

ConVar g_Onoff,
	   g_Interval;

bool   b_IsReset = false,
	   b_HasRest = false,
	   b_IsNeedBlock = false;

float	g_fInterval,
		SITimer[6];

public Plugin myinfo =
{
	name		= "[L4D2] 导演刷特刷尸潮修复实验",
	author		= "洛琪希",
	description = "防止导演系统在一帧刷满28特和帧满尸潮,现在每隔0.05秒生成5个特感、尸潮生成时每秒只生成30只僵尸",
	version		= PLUGIN_VERSION,
	url			= "https://steamcommunity.com/profiles/76561198812009299/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "插件只支持求生之路2");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_Onoff = CreateConVar("dire_fix", "1", "是否开启修复. 1=开启,0=关闭.", FCVAR_NOTIFY);
	g_Interval = CreateConVar("dire_time", "0.05", "隔多少秒刷新5只特感.可选范围0.0~0.1,超过0.1会被自动修正为0.1", FCVAR_NOTIFY);

	AutoExecConfig(true, "l4d2_director_spawn_fix");
	g_Onoff.AddChangeHook(ConVarChanged);
	g_Interval.AddChangeHook(ConVarChanged);
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsSIFix();
}

public void OnMapStart()
{
	IsSIFix();
}

void IsSIFix()
{
	g_iSIFix = g_Onoff.IntValue;
	g_fInterval = g_Interval.FloatValue;
	if(g_fInterval >= 0.1)
		g_fInterval = 0.1;
}

public Action L4D_OnSpawnSpecial(int &zombieClass, const float vecPos[3], const float vecAng[3])
{
	if (g_iSIFix == 0)
		return Plugin_Continue;

	if(!b_IsReset)
	{
		for(int i = 1; i < 7; i++)
		{
			CountdownTimer SiTimer = L4D2Direct_GetSIClassSpawnTimer(i);
			SITimer[i-1] = CTimer_GetTimestamp(SiTimer);
		}
		b_IsReset = true;
		g_MaxSpawnOnce = 0;
		CreateTimer(1.0, RefreshBool);
	}
	
	if(g_MaxSpawnOnce >= 5 && !b_IsNeedBlock)
		b_IsNeedBlock = true;
	
	if(b_IsNeedBlock)
	{
		if(!b_HasRest)
		{
			b_HasRest = true;
			CreateTimer(g_fInterval, ResetSpecialsCountdownTime);
		}
		return Plugin_Handled;
	}
		
	return Plugin_Continue;
}


public void L4D_OnSpawnSpecial_Post(int client, int zombieClass, const float vecPos[3], const float vecAng[3])
{
	g_MaxSpawnOnce = g_MaxSpawnOnce + 1;
}


public Action L4D_OnGetScriptValueFloat(const char[] key, float &retVal)
{
	if(strcmp(key, "MobRechargeRate") == 0)
	{
		retVal = 0.034;
		FindConVar("z_mob_recharge_rate").FloatValue = 0.034;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action L4D_OnGetScriptValueInt(const char[] key, int &retVal)
{
	if(strcmp(key, "BuildUpMinInterval") == 0)
	{
		retVal = 16;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action ResetSpecialsCountdownTime(Handle timer)
{
	b_IsNeedBlock = false;
	b_IsReset = false;
	b_HasRest 	= false;
	
	for (int i = 1; i < 7; i++)
	{
		CountdownTimer SiTimer = L4D2Direct_GetSIClassSpawnTimer(i);
		if(SITimer[i-1] <= 1.0)		
			CTimer_SetTimestamp(SiTimer, 0.0);
		else
			CTimer_SetTimestamp(SiTimer, SITimer[i-1]);
	}
	return Plugin_Continue;
}


public Action RefreshBool(Handle timer)
{
	b_IsReset = false;
	return Plugin_Continue;
}