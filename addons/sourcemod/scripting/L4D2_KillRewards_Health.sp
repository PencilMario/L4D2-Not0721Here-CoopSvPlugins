#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define PLUGIN_VERSION "1.1"

new Handle:RewardPlugin;
new Handle:RewardHealth;
new Handle:RewardMessage;
new Handle:ReviveMessage;
new Handle:ReviveHealth;
new Handle:HealMessage;
new Handle:HealHealth;
new Handle:DefibrMessage;
new Handle:DefibrHealth;
new Handle:RandomHealMax;
new Handle:RandomHealMin;

new Handle:KillInfected;
new Handle:KillInfectedNum;
new Handle:KillInfected1;
new Handle:KillHeadShot;
new Handle:RewardHealthMax;

new Handle:KillWitchHeal;
new Handle:KillTankHeal;

new KillCount[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "[L4D2]血量奖励",
	description = "幸存者帮助队友，击杀特感 奖励生命值",
	author = "藤野深月",
	version = PLUGIN_VERSION,
	url = ""
};

public OnPluginStart()
{
	/* 插件参数 */
	CreateConVar("L4D2_CoverRewards_Version", PLUGIN_VERSION, "[L4D2] 血量奖励 插件版本");
	RewardPlugin		=		CreateConVar("L4D2_Reward_Plugin",			"0", 		"是否启用奖励插件？[0=关闭 1=开启]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	RewardMessage		=		CreateConVar("L4D2_Reward_Message",			"0", 		"保护队友奖励模式[0=固定 1=随机]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	ReviveMessage		=		CreateConVar("L4D2_Revive_Message",			"0",  	"拉起倒地队友奖励模式[0=固定 1=随机]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HealMessage			=		CreateConVar("L4D2_Heal_Message",				"0",  	"治疗队友奖励模式[0=固定 1=随机]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	DefibrMessage		=		CreateConVar("L4D2_Defibr_Message",			"0",  	"电击队友奖励模式[0=固定 1=随机]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	RewardHealth		=		CreateConVar("L4D2_Reward_Health",			"2",  	"保护队友固定奖励的血量值");
	ReviveHealth		=		CreateConVar("L4D2_Revive_Health",			"3",  	"拉起倒地固定奖励的血量值");
	HealHealth			=		CreateConVar("L4D2_Heal_Health",				"5",  	"治疗队友固定奖励的血量值");
	DefibrHealth		=		CreateConVar("L4D2_Defibr_Health",			"10",  	"电击队友固定奖励的血量值");
	RandomHealMin		=		CreateConVar("L4D2_Random_HealMin",			"1",	 	"[随机模式]设置随机奖励模式的最小值");
	RandomHealMax		=		CreateConVar("L4D2_Random_HealMax",			"10", 	"[随机模式]设置随机奖励模式的最大值");
	
	KillInfected		=		CreateConVar("L4D2_Kill_Infected",			"3", 		"击杀特感奖励的血量值");
	KillHeadShot		=		CreateConVar("L4D2_Kill_HeadShot",			"7", 		"爆头击杀特感奖励的血量值");
	KillInfected1		=		CreateConVar("L4D2_Kill_Infected1",			"1", 		"击杀普通奖励的血量值[达到击杀数触发]");
	KillInfectedNum	=		CreateConVar("L4D2_KillInfected_Num",		"1", 		"击杀多少普通感染者可触发奖励？");
	KillWitchHeal		=		CreateConVar("L4D2_KillWitch_Heal",			"10", 	"击杀 Wtich 可恢复多少血量值？");
	KillTankHeal		=		CreateConVar("L4D2_KillTank_Heal",			"10", 	"击杀 Tank 可恢复多少血量值");
	
	RewardHealthMax	=		CreateConVar("L4D2_Reward_HealthMax",		"200", 	"设置幸存者获得血量奖励的最高上限", FCVAR_NOTIFY, true, 100.0, true, 999.0);
	
	
	//RegConsoleCmd("sm_show", Command_Show, "插件信息显示");
	/* HOOK */
	HookEvent("award_earned", Achievement_Earned);
	HookEvent("revive_success",			Event_ReviveSuccess);
	HookEvent("heal_success",			Event_HealSuccess);
	HookEvent("defibrillator_used",		Event_DefibrillatorUsed);
	HookEvent("player_death",			Event_PlayerDeath);//玩家死亡
	HookEvent("infected_death", 	Event_KillInfected);
	HookEvent("witch_killed",			Event_WitchKilled);
	HookEvent("tank_killed",			Event_TankKilled);
	/* Config */
	AutoExecConfig(true, "L4D2_KillRewards_Health");
}

/* Witch死亡 */
public Action:Event_WitchKilled(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new eventhealth = GetEntProp(attacker, Prop_Data, "m_iHealth");
	
	if(IsValidPlayer(attacker) && GetClientTeam(attacker) == 2)
	{
		new Rewards = GetConVarInt(KillWitchHeal);
		if (!IsPlayerIncapped(attacker))
		{
			if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
			{
				SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
				PrintToChat(attacker, "\x04[提示]\x03击杀 Witch 奖励 %d 点生命值", Rewards);
			}
			else
				SetEntProp(attacker, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
		}
		else
			SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
		
		Health(attacker);
	}
}

/* Tank死亡 */
public Action:Event_TankKilled(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new eventhealth = GetEntProp(attacker, Prop_Data, "m_iHealth");
	
	if(IsValidPlayer(attacker) && GetClientTeam(attacker) == 2)
	{
		new Rewards = GetConVarInt(KillTankHeal);
		if (!IsPlayerIncapped(attacker))
		{
			if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
			{
				SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
				PrintToChat(attacker, "\x04[提示]\x03击杀 Tank 奖励 %d 点生命值", Rewards);
			}
			else
				SetEntProp(attacker, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
		}
		else
			SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
		Health(attacker);
	}
}

/* 击杀普感 */
public Action:Event_KillInfected(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new eventhealth = GetEntProp(attacker, Prop_Data, "m_iHealth");
	
	if(IsValidPlayer(attacker) && GetClientTeam(attacker) == 2)
	{
		KillCount[attacker] += 1;
		//触发奖励
		new Rewards = GetConVarInt(KillInfected1);
		new KillNum = GetConVarInt(KillInfectedNum);
		
		if( KillNum == KillCount[attacker] && Rewards > 0 )
		{
			KillCount[attacker] -= KillNum;
			if (!IsPlayerIncapped(attacker))
			{
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(attacker, "\x04[提示]\x03击杀 %d 普通感染者 奖励 %d 点生命值", KillNum, Rewards);
				}
				else
					SetEntProp(attacker, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			else
				SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
			
			Health(attacker);
		}
	}
}

/* 玩家死亡 */
public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	bool headshot = GetEventBool(event, "headshot");
	new eventhealth = GetEntProp(attacker, Prop_Data, "m_iHealth");
	
	if(IsValidPlayer(victim) && IsValidPlayer(attacker))
	{
		new iClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
		if(GetClientTeam(attacker) == 2 && GetClientTeam(victim) == 3 && iClass <= 6)
		{
			//检测玩家是否倒地
			if (!IsPlayerIncapped(attacker))
			{
				if(headshot)
				{
					new Rewards = GetConVarInt(KillHeadShot);
					if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
					{
						SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
						//PrintToChat(attacker, "\x04[提示]\x03爆头击杀 %N 奖励 %d 点生命值", victim, Rewards);
					}
					else
						SetEntProp(attacker, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
				}
				if(!headshot)
				{
					new Rewards = GetConVarInt(KillInfected);
					if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
					{
						SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
						//PrintToChat(attacker, "\x04[提示]\x03击杀 %N 奖励 %d 点生命值", victim, Rewards);
					}
					else
						SetEntProp(attacker, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
				}
				Health(attacker);
			}
			else
			{
				if(headshot)
				{
					new Rewards = GetConVarInt(KillHeadShot);
					SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
				}
				if(!headshot)
				{
					new Rewards = GetConVarInt(KillInfected);
					SetEntProp(attacker, Prop_Data, "m_iHealth", GetEntProp(attacker, Prop_Data, "m_iHealth") + Rewards);
				}
			}
		}
	}
}

/* 保护队友 */
public Achievement_Earned(Handle:event, String:name[], bool:Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	new achievementid = GetEventInt(event, "award");
	new eventhealth = GetEntProp(Client, Prop_Data, "m_iHealth");
	
	if (GetConVarInt(RewardPlugin) == 1)
	{
		if (achievementid == 67)
		{
			if (GetConVarInt(RewardMessage) == 1)
			{
				new Rewards = GetRandomInt(GetConVarInt(RandomHealMin), GetConVarInt(RandomHealMax));
				//检测玩家是否倒地
				if (!IsPlayerIncapped(Client))
				{
					if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
					{
						SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
						PrintToChat(Client, "\x04[提示]\x03保护队友奖励 %d 点生命值", Rewards);
					}
					else
						SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
			}
			else
			{
				new Rewards = GetConVarInt(RewardHealth);
				//检测玩家是否倒地
				if (IsPlayerIncapped(Client))
				{
					if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
					{
						SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
						PrintToChat(Client, "\x04[提示]\x03保护队友奖励 %d 点生命值", Rewards);
					}
					else
						SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
			}
			Health(Client);
		}
	}
}

/* 拉起队友 */
public Action:Event_ReviveSuccess(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	new Subject = GetClientOfUserId(GetEventInt(event, "subject"));
	new eventhealth = GetEntProp(Client, Prop_Data, "m_iHealth");
	
	//new bool:Isledge = GetEventBool(event, "ledge_hang");  && !Isledge
	
	if (GetConVarInt(RewardPlugin) == 1)
	{
		if (IsValidPlayer(Client) && Client != Subject && GetClientTeam(Client) == 2 && !IsFakeClient(Client))
		{
			if(GetConVarInt(ReviveMessage) == 1)
			{
				new Rewards = GetRandomInt(GetConVarInt(RandomHealMin), GetConVarInt(RandomHealMax));
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(Client, "\x04[提示]\x03拉起队友随机奖励 %d 点生命值", Rewards);
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			else
			{
				new Rewards = GetConVarInt(ReviveHealth);
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(Client, "\x04[提示]\x03拉起队友奖励 %d 点生命值", Rewards);
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			Health(Client);
		}
	}
}

/* 电击队友 */
public Action:Event_DefibrillatorUsed(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	new eventhealth = GetEntProp(Client, Prop_Data, "m_iHealth");
	
	if (GetConVarInt(RewardPlugin) == 1)
	{
		if (IsValidPlayer(Client) && GetClientTeam(Client) == 2 && !IsFakeClient(Client))
		{
			if(GetConVarInt(DefibrMessage) == 1)
			{
				new Rewards = GetRandomInt(GetConVarInt(RandomHealMin), GetConVarInt(RandomHealMax));
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(Client, "\x04[提示]\x03电击队友随机奖励 %d 点生命值", Rewards);
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			else
			{
				new Rewards = GetConVarInt(DefibrHealth);
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(Client, "\x04[提示]\x03电击队友奖励 %d 点生命值", Rewards);
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			Health(Client);
		}
	}
}

/* 治疗幸存者 */
public Action:Event_HealSuccess(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	new Target = GetClientOfUserId(GetEventInt(event, "subject"));
	new eventhealth = GetEntProp(Client, Prop_Data, "m_iHealth");
	
	if (GetConVarInt(RewardPlugin) == 1)
	{
		if (IsValidPlayer(Client) && GetClientTeam(Client) == 2  && Client != Target)
		{
			if(GetConVarInt(HealMessage) == 1)
			{
				new Rewards = GetRandomInt(GetConVarInt(RandomHealMin), GetConVarInt(RandomHealMax));
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(Client, "\x04[提示]\x03治疗队友随机奖励 %d 点生命值", Rewards);
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			else
			{
				new Rewards = GetConVarInt(HealHealth);
				if ( (eventhealth + Rewards) <= GetConVarInt(RewardHealthMax) )
				{
					SetEntProp(Client, Prop_Data, "m_iHealth", GetEntProp(Client, Prop_Data, "m_iHealth") + Rewards);
					PrintToChat(Client, "\x04[提示]\x03治疗队友奖励 %d 点生命值", Rewards);
				}
				else
					SetEntProp(Client, Prop_Data, "m_iHealth", GetConVarInt(RewardHealthMax));
			}
			Health(Client);
		}
	}
}

public Health(Client)
{
	if(IsValidPlayer(Client) && IsValidEntity(Client))
	{
		SetEntProp(Client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(Client, Prop_Send, "m_bFlashing", 1);
		SetEntProp(Client, Prop_Send, "m_glowColorOverride", 119911);
		CreateTimer(1.0, Timer_He, Client);
	}
}

public Action:Timer_He(Handle:timer, any:Client)
{
	if(IsValidPlayer(Client) && IsValidEntity(Client))
	{
		new RGB_GLOW = RGB_TO_INT(255, 255, 255);
		SetEntProp(Client, Prop_Send, "m_iGlowType", 0);
		SetEntProp(Client, Prop_Send, "m_bFlashing", 0);
		SetEntProp(Client, Prop_Send, "m_glowColorOverride", RGB_GLOW);
	}
	return Plugin_Handled;
}

RGB_TO_INT(red, green, blue)
{
	return green * 256 + blue * 65536 + red;
}

stock bool:IsValidPlayer(Client, bool:AllowBot = true, bool:AllowDeath = true)
{
	if (Client < 1 || Client > MaxClients)
		return false;
	if (!IsClientConnected(Client) || !IsClientInGame(Client))
		return false;
	if (!AllowBot)
	{
		if (IsFakeClient(Client))
			return false;
	}
	if (!AllowDeath)
	{
		if (!IsPlayerAlive(Client))
			return false;
	}	
	return true;
}

//检测玩家是否倒地
stock bool:IsPlayerIncapped(Client)
{
	if (GetEntProp(Client, Prop_Send, "m_isIncapacitated") == 1)
		return true;
	else
		return false;
}

/*
public Action:Command_Show(client, args)
{
	PrintToChatAll("\x03==========================\x09\x09\x09\x09\x03");
	PrintToChatAll("\x04|插件名稱:保護玩家\x09\x09\x09\x09\x09\x09\x04");
	PrintToChatAll("\x04|插件作者:奇奈cheryl\x09\x09\x09\x04");
	PrintToChatAll("\x03==========================\x09\x09\x09\x09\x03");
	return Plugin_Handled;
}
*/

//new Handle:HealMaxNum;
//HealMaxNum		=		CreateConVar("L4D2_Heal_MaxNum",			"30",  	"治疗队友奖励触发生效的血量(低于此值才可触发)");