#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#define CVAR_FLAGS FCVAR_PLUGIN
#define PLUGIN_VERSION "22"

#define ZOMBIECLASS_SMOKER	1
#define ZOMBIECLASS_BOOMER	2
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_SPITTER	4
#define ZOMBIECLASS_JOCKEY	5
#define ZOMBIECLASS_CHARGER	6
new ZOMBIECLASS_TANK=	5;
new L4D2Version=false;

public Plugin:myinfo = 
{
	name = "Recover And Drop",
	author = "Pan Xiaohai",
	description = "Recover And Drop",
	version = "1.23",
	url = "http://forums.alliedmods.net"
}

new Handle:l4d_loot_enabled;
 
new Handle:l4d_loot_boss_show_msg;
new Handle:l4d_kill_show_msg;
 
 

new Handle:l4d_loot_hunter;
new Handle:l4d_loot_boomer;
new Handle:l4d_loot_smoker;
new Handle:l4d_loot_spitter;
new Handle:l4d_loot_jockey;
new Handle:l4d_loot_charger;
new Handle:l4d_loot_tank;
new Handle:l4d_loot_witch;

new Handle:l4d_loot_hunter_num;
new Handle:l4d_loot_boomer_num;
new Handle:l4d_loot_smoker_num;
new Handle:l4d_loot_spitter_num;
new Handle:l4d_loot_jockey_num ;
new Handle:l4d_loot_charger_num;
new Handle:l4d_loot_tank_num;
new Handle:l4d_loot_witch_num;


new Handle:l4d_loot_killtank_reward;
new Handle:l4d_loot_killwitch_reward;	
 

new Handle:l4d_kill_addhp_enabled;
new Handle:l4d_kill_addhp_lt50_mult;

new Handle:l4d_kill_addhp_distance;



new Handle: l4d_kill_addhp_weapon_pistol_1 ;
new Handle: l4d_kill_addhp_weapon_msg_1 ;
new Handle: l4d_kill_addhp_weapon_rifle_1 ;
new Handle: l4d_kill_addhp_weapon_sniper_1 ;
new Handle: l4d_kill_addhp_weapon_shotgun_1 ;
new Handle: l4d_kill_addhp_weapon_melee ;
  
new Handle: l4d_kill_addhp_weapon_pistol_2 ;
new Handle: l4d_kill_addhp_weapon_msg_2 ;
new Handle: l4d_kill_addhp_weapon_rifle_2 ;
new Handle: l4d_kill_addhp_weapon_sniper_2 ;
new Handle: l4d_kill_addhp_weapon_shotgun_2 ;
new Handle: l4d_kill_addhp_weapon_other;

new Handle: l4d_kill_addhp_hunter_1 ;
new Handle: l4d_kill_addhp_smoker_1 ;
new Handle: l4d_kill_addhp_boomer_1 ;
new Handle: l4d_kill_addhp_spitter_1 ;
new Handle: l4d_kill_addhp_jockey_1 ;
new Handle: l4d_kill_addhp_charger_1 ; 

new Handle: l4d_kill_addhp_hunter_2 ;
new Handle: l4d_kill_addhp_smoker_2 ;
new Handle: l4d_kill_addhp_boomer_2 ;
new Handle: l4d_kill_addhp_spitter_2 ;
new Handle: l4d_kill_addhp_jockey_2 ;
new Handle: l4d_kill_addhp_charger_2 ; 
 
new Handle:l4d_kill_addhp_tank;
new Handle:l4d_kill_addhp_witch;	
 

new Handle:l4d_kill_addhp_mult;
new Handle:l4d_loot_headshot ;
new Handle:l4d_loot_headshotno ;

new Handle:l4d_kill_addhp_headshot_mult;
new Handle:l4d_kill_addhp_noheadshot_mult;

new Handle:l4d_kill_addhp_healthlimit;

new Handle:l4d_loot_weapon;
new Handle:l4d_loot_weapon_melee;
new Handle:l4d_loot_health;
new Handle:l4d_loot_item;
 

public OnPluginStart()
{
	SetRandomSeed(GetSysTickCount());
	
 	l4d_loot_enabled = CreateConVar("l4d_loot_enabled", "0", "0: disable loot from boss, 1: enable", FCVAR_PLUGIN);
	l4d_loot_boss_show_msg = CreateConVar("l4d_loot_boss_show_msg", "1", "0:disable print loot message in HintBox, 1:disable ", FCVAR_PLUGIN);
 

	l4d_loot_hunter = CreateConVar("l4d_loot_hunter", "4.0", "loot of hunter %[0-100]", FCVAR_PLUGIN);
	l4d_loot_smoker = CreateConVar("l4d_loot_smoker", "5.0", "loot of smoker %[0-100]", FCVAR_PLUGIN);
	l4d_loot_boomer = CreateConVar("l4d_loot_boomer", "5.0", "loot of Boomer %[0-100]", FCVAR_PLUGIN);
	l4d_loot_spitter = CreateConVar("l4d_loot_spitter", "4.0", "loot of spitter %[0-100]", FCVAR_PLUGIN);
	l4d_loot_jockey = CreateConVar("l4d_loot_jockey", "4.0", "loot of jockey %[0-100]", FCVAR_PLUGIN);
	l4d_loot_charger = CreateConVar("l4d_loot_charger", "4.0", "loot of charger %[0-100]", FCVAR_PLUGIN);
	l4d_loot_tank = CreateConVar("l4d_loot_tank", "70", "loot of tank %[0-100]", FCVAR_PLUGIN);
	l4d_loot_witch = CreateConVar("l4d_loot_witch", "60", "loot of witch %[0-100]", FCVAR_PLUGIN);

	l4d_loot_hunter_num = CreateConVar("l4d_loot_hunter_num", "1", "loot count of hunter ", FCVAR_PLUGIN);
	l4d_loot_smoker_num = CreateConVar("l4d_loot_smoker_num", "1", "loot count of smoker ", FCVAR_PLUGIN);
	l4d_loot_boomer_num = CreateConVar("l4d_loot_boomer_num", "1", "loot count of Boomer ", FCVAR_PLUGIN);	
	l4d_loot_spitter_num = CreateConVar("l4d_loot_spitter_num", "1", "loot count of spitter ", FCVAR_PLUGIN);
	l4d_loot_jockey_num = CreateConVar("l4d_loot_jockey_num", "1", "loot count of jockey ", FCVAR_PLUGIN);
	l4d_loot_charger_num = CreateConVar("l4d_loot_charger_num", "1", "loot count of charger ", FCVAR_PLUGIN);
	l4d_loot_tank_num = CreateConVar("l4d_loot_tank_num", "4", "loot count of tank ", FCVAR_PLUGIN);
	l4d_loot_witch_num = CreateConVar("l4d_loot_witch_num", "3", "loot count of witch ", FCVAR_PLUGIN);

	l4d_loot_headshot = CreateConVar("l4d_loot_headshot", "3.0", "loot factor with headshot", FCVAR_PLUGIN);
 	l4d_loot_headshotno = CreateConVar("l4d_loot_headshotno", "1.0", "loot factor without headshot", FCVAR_PLUGIN);
   
  
	l4d_loot_killtank_reward = CreateConVar("l4d_loot_killtank_reward", "60", "probability of reward for kill tank %[0-100]", FCVAR_PLUGIN);
	l4d_loot_killwitch_reward = CreateConVar("l4d_loot_killwitch_reward", "50", "probability of reward for kill witch %[0-100]", FCVAR_PLUGIN);
  	l4d_kill_addhp_tank = CreateConVar("l4d_kill_addhp_tank", "50", "health recover for kill tank", FCVAR_PLUGIN);
	l4d_kill_addhp_witch = CreateConVar("l4d_kill_addhp_witch", "50", "health recover for kill witch", FCVAR_PLUGIN);
 
	l4d_loot_weapon = CreateConVar("l4d_loot_weapon", "25.0", "probability of loot guns %", FCVAR_PLUGIN);
	l4d_loot_weapon_melee = CreateConVar("l4d_loot_weapon_melee", "25.0", "probability of loot melee weapon %", FCVAR_PLUGIN);
	l4d_loot_health = CreateConVar("l4d_loot_health", "15.0", "probability of loot Medical supplies %", FCVAR_PLUGIN);
	l4d_loot_item = CreateConVar("l4d_loot_item", "35.0", "probability of loot items %", FCVAR_PLUGIN);

	l4d_kill_addhp_enabled = CreateConVar("l4d_kill_addhp_enabled", "0", "0: disable health recover, 1:eanble", FCVAR_PLUGIN);
	l4d_kill_addhp_mult = CreateConVar("l4d_kill_addhp_mult", "0.1", "health recover factor", FCVAR_PLUGIN);
	l4d_kill_addhp_lt50_mult = CreateConVar("l4d_kill_addhp_lt50_mult", "3.0", "health recover factor when health < 50", FCVAR_PLUGIN);
	l4d_kill_addhp_healthlimit = CreateConVar("l4d_kill_addhp_healthlimit", "200.0", "health limit", FCVAR_PLUGIN);

	l4d_kill_show_msg = CreateConVar("l4d_kill_show_msg", "0", "print kill messge 1:in chat 2: int hintbox, 3:all, 0:disable", FCVAR_PLUGIN);


	l4d_kill_addhp_noheadshot_mult = CreateConVar("l4d_kill_addhp_noheadshot_mult", "1.0", "health recover multiple without headshot ", FCVAR_PLUGIN);
	l4d_kill_addhp_headshot_mult = CreateConVar("l4d_kill_addhp_headshot_mult", "3.0", "health recover multiple with headshot ", FCVAR_PLUGIN);

	l4d_kill_addhp_weapon_pistol_1 = CreateConVar("l4d_kill_addhp_weapon_pistol_1", "8.0", "health recover factor of pistol killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_msg_1 = CreateConVar("l4d_kill_addhp_weapon_msg_1", "4.0", "health recover factor of smg", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_rifle_1 = CreateConVar("l4d_kill_addhp_weapon_rifle_1", "3.0", "health recover factor of rifle killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_sniper_1 = CreateConVar("l4d_kill_addhp_weapon_sniper_1", "2.0", "health recover factor of sniper killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_shotgun_1 = CreateConVar("l4d_kill_addhp_weapon_shotgun_1", "4.0", "health recover factor of shotgun killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_melee = CreateConVar("l4d_kill_addhp_weapon_melee", "30.0", "health recover factor of melee killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_other = CreateConVar("l4d_kill_addhp_weapon_other", "1.0", "health recover factor of ohter weapon killing", FCVAR_PLUGIN);
  
	l4d_kill_addhp_weapon_pistol_2 = CreateConVar("l4d_kill_addhp_weapon_pistol_2", "30.0", "health recover factor of long range pistol killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_msg_2 = CreateConVar("l4d_kill_addhp_weapon_msg_2", "16.0", "health recover factor of long range smg killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_rifle_2 = CreateConVar("l4d_kill_addhp_weapon_rifle_2", "13.0", "health recover factor of long range rifle killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_sniper_2 = CreateConVar("l4d_kill_addhp_weapon_sniper_2", "12.0", "health recover factor of long range sniper killing", FCVAR_PLUGIN);
	l4d_kill_addhp_weapon_shotgun_2 = CreateConVar("l4d_kill_addhp_weapon_shotgun_2", "20.0", "health recover factor of long range shotgun killing", FCVAR_PLUGIN);

 	l4d_kill_addhp_distance = CreateConVar("l4d_kill_addhp_distance", "1200.0", "long range", FCVAR_PLUGIN);

 	l4d_kill_addhp_hunter_1 = CreateConVar("l4d_kill_addhp_hunter_1", "3.0", "health recover factor for hunter killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_smoker_1 = CreateConVar("l4d_kill_addhp_smoker_1", "3.0", "health recover factor for smoker killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_boomer_1 = CreateConVar("l4d_kill_addhp_boomer_1", "3.0", "health recover factor for boomer killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_spitter_1 = CreateConVar("l4d_kill_addhp_spitter_1", "3.0", "health recover factor for spitter killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_jockey_1 = CreateConVar("l4d_kill_addhp_jockey_1", "3.0", "health recover factor for jockey killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_charger_1 = CreateConVar("l4d_kill_addhp_charger_1", "3.0", "health recover factor for charger killing", FCVAR_PLUGIN);

 	l4d_kill_addhp_hunter_2 = CreateConVar("l4d_kill_addhp_hunter_2", "1.0", "health recover factor for long range hunter killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_smoker_2 = CreateConVar("l4d_kill_addhp_smoker_2", "1.0", "health recover factor for long range smoker killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_boomer_2 = CreateConVar("l4d_kill_addhp_boomer_2", "1.0", "health recover factor for long range boomer killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_spitter_2 = CreateConVar("l4d_kill_addhp_spitter_2", "1.0", "health recover factor for long range spitter killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_jockey_2 = CreateConVar("l4d_kill_addhp_jockey_2", "1.0", "health recover factor for long range jockey killing", FCVAR_PLUGIN);
 	l4d_kill_addhp_charger_2 = CreateConVar("l4d_kill_addhp_charger_2", "1.0", "health recover factor for long range charger killing", FCVAR_PLUGIN);


	AutoExecConfig(true, "kill_drop_v22");
 
	decl String:GameName[16];
	GetGameFolderName(GameName, sizeof(GameName));
	if (StrEqual(GameName, "left4dead2", false))
	{
		ZOMBIECLASS_TANK=8;
		L4D2Version=true;
	}	
	else
	{
		ZOMBIECLASS_TANK=5;
		L4D2Version=false;
	}
 
		HookEvent("player_incapacitated_start", Event_PlayerIncapacitated);
		HookEvent("player_death", Event_PlayerDeath);
		HookEvent("witch_killed", Event_WitchKilled);
 
	 
}

public ShowKillMsgOnChat()
{
	new d=GetConVarInt(l4d_kill_show_msg);
	if(d==1 || d==3)return true;
	else return false;
}
public ShowKillMsgOnPanel()
{
	new d=GetConVarInt(l4d_kill_show_msg);
	if(d==2 || d==3)return true;
	else return false;
}
 
AddHealth(client, Float:add)
{
	if(add<=0.0)return;
	new hardhp = GetClientHealth(client) + 0; 

	if(GetClientTeam(client) == 2) 
	{
		new addhp;
		new Float:fhp=hardhp*1.0;
		new Float:newhp=add;
		if(fhp<50.0)
		{
			newhp=add*(1.0+ (50.0-fhp)*GetConVarFloat(l4d_kill_addhp_lt50_mult)/50.0);
		}
		addhp=RoundFloat(newhp);
		if(hardhp+addhp<=RoundFloat(GetConVarFloat(l4d_kill_addhp_healthlimit)))
		{
			SetEntityHealth(client, hardhp + addhp);
		}
		else
		{
			SetEntityHealth(client, RoundFloat(GetConVarFloat(l4d_kill_addhp_healthlimit)));
		}
	}
	return;
}
 

public Action:Event_WitchKilled(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
	if(GetConVarInt(l4d_loot_enabled)==0)
	{
		return Plugin_Continue;
	}
	new ClientId = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(!IsValidClient(ClientId))return Plugin_Continue;

	if(GetClientTeam(ClientId) != 2)return Plugin_Continue;

	new r=GetRandomInt(0, 100);
 	if(r < RoundFloat(GetConVarFloat(l4d_loot_killwitch_reward)))
	{
 
		new r1=0;
		if(L4D2Version)	r1=GetRandomInt(0, 3);
		else 	r1=GetRandomInt(0, 1);
		if(r1==0)
		{
			Give(ClientId, "first_aid_kit");
			PrintToChatAll("\x04Witch\x03 finally killed by \x04%N \x03and earned a \x04first aid kit",ClientId);
 		}
		if(r1==1)
		{
			Give(ClientId, "pain_pills");
			PrintToChatAll("\x04Witch\x03 finally killed by \x04%N \x03and earned a \x04pills",ClientId);
		}
		if(r1==2)
		{
			Give(ClientId, "adrenaline");
			PrintToChatAll("\x04Witch\x03 finally killed by \x04%N \x03and earned a \x04adrenaline",ClientId);
		}
		if(r1==3)
		{
			Give(ClientId, "defibrillator");
			PrintToChatAll("\x04Witch\x03 finally killed by \x04%N \x03and earned a \x04defibrillator",ClientId);
		}
	}
	else
	{
		PrintToChatAll("\x04Witch\x03 finally killed by\x04 %N \x03",ClientId);
	}

	CreateTimer(2.0, witchreward, ClientId);

	CreateTimer(5.0, BossDeadLaught);

	if(GetConVarInt(l4d_kill_addhp_enabled)>0)
	{
		AddHealth(ClientId, GetConVarFloat(l4d_kill_addhp_witch));
	}
	return Plugin_Continue;
}
 
public Action:Event_PlayerIncapacitated(Handle:hEvent, const String:strName[], bool:DontBroadcast)
{

	if(GetConVarInt(l4d_loot_enabled)==0)
	{
		return Plugin_Continue;
	}

	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	decl String:player_name[65];
	GetClientName(client, player_name, sizeof(player_name));

	decl String:buff[165];

 	new attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
  
 
 	new r;
	r= GetRandomInt(0, 100);
 	
	if (attacker != 0 )
	{
		decl String:player_name2[65];
		GetClientName(attacker, player_name2, sizeof(player_name2));
		if( GetClientTeam(attacker) ==2) 
		{
			Format(buff, sizeof(buff), "\x04 %s \x03 incapacitated\x04 %s", player_name2, player_name);
			PrintToChatAll(buff);
			//PrintHintTextToAll(buff);
		}
		else if(GetClientTeam(attacker) ==3)
		{
 			Format(buff, sizeof(buff), "\x04 %s \x03 incapacitated\x04 %s", player_name2, player_name);
			PrintToChatAll(buff);
			//PrintHintTextToAll(buff);
		}
	}
	else
	{
 			Format(buff, sizeof(buff), "\x04 %s \x03incapacitated", player_name);
			PrintToChatAll(buff);
	}
	CreateTimer(3.0, IcapCry, client);

	new min=5;
	new max=35; 

	return Plugin_Continue;
}
public Action:IcapCry(Handle:timer, any:target)
{
	ClientCommand(target, "vocalize PlayerDeath");
}

bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	return false;
}

public Action:Event_PlayerDeath(Handle:hEvent, const String:strName[], bool:DontBroadcast)
{
	if(GetConVarInt(l4d_loot_enabled)==0)
	{
		return Plugin_Continue;
	}
	 
	new victim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
 	new attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

	if (!IsValidClient(victim)) 
	{
 		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == 2)
	{
 		 
 		if (attacker != 0 )
		{
 			if(GetClientTeam(attacker)==2) 
			{

				PrintToChatAll("\x04 %N \x03killed\x04 %N ", attacker, victim);
				PrintHintTextToAll("%N killed %N ", attacker, victim);
			}
			else 
			{
 				PrintToChatAll("\x04 %N \x03killed\x04 %N", attacker, victim);
				PrintHintTextToAll("%N killed %N ", attacker, victim);
			}
		}
		else
		{
			 
			PrintToChatAll("\x04 %N \x03dead", victim);
			PrintHintTextToAll("%N dead", victim);
		}
		return Plugin_Continue;
	}
	if(GetClientTeam(victim) != 3)
	{
		return Plugin_Continue;
	}

	decl Float:v1[3];
	decl Float:v2[3];
	GetClientEyePosition(victim, v1);
	if(IsValidClient(attacker))
	{
		GetClientEyePosition(attacker, v2);	
	}
	else
	{
	    GetClientEyePosition(victim, v2);
	}
	new Float:fdist = GetVectorDistance(v1, v2);
	new dist=RoundFloat(fdist); 

	new class = GetEntProp(victim, Prop_Send, "m_zombieClass");

	new bool:headshot=GetEventBool(hEvent, "headshot");
	 
	new Float:lootheadmult=1.0;
	new Float:headhpmult=1.0;
	new Float:kindmult=1.0;

	new Float:weapon1=1.0;
	new Float:weapon2=1.0;
	new Float:weaponmult=1.0;

	new Float:addhpmult=GetConVarFloat(l4d_kill_addhp_mult);
	new difficult=1;
	
	decl String:weapon[65];
 	GetEventString(hEvent, "weapon", weapon,sizeof(weapon));
	if(StrContains(weapon, "pistol")>=0)
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_pistol_1);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_pistol_2);
		//PrintToChatAll("weapon : pistol ");
	}
	else if(StrContains(weapon, "smg")>=0)
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_msg_1);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_msg_2);
		//PrintToChatAll("weapon :  smg");
	}
	else if(StrContains(weapon, "hunting_rifle")>=0 || StrContains(weapon, "sniper")>=0)
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_sniper_1);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_sniper_2);
		//PrintToChatAll("weapon :  awp");
	}
	else if(StrContains(weapon, "rifle")>=0)
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_rifle_1);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_rifle_2);
		//PrintToChatAll("weapon :  rifle");
	}
	else if(StrContains(weapon, "shotgun")>=0 || StrContains(weapon, "launcher")>=0)
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_shotgun_1);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_shotgun_2);
		//PrintToChatAll("weapon :  shotgun");
	}
 	else if( StrContains(weapon, "melee")>=0 ||  StrContains(weapon, "chainsaw")>=0)
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_melee);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_melee);
		//PrintToChatAll("weapon :  other");
	}
 	else  
	{
		weapon1=GetConVarFloat(l4d_kill_addhp_weapon_other);
		weapon2=GetConVarFloat(l4d_kill_addhp_weapon_other);
		//PrintToChatAll("weapon :  other");
	}

	decl String:name[65];
	GetClientName(attacker, name, sizeof(name));
 
	decl String:chatmsg[165];
	decl String:hintmsg[165];
	decl String:lootmsg[165];
 ///////////////////////////////////////////////////////////////
 
/////////////////////////////////////////////////////////////////////////
	new Float:loot_num;
	new Float:loot_p;
	new Float:y1;
	new Float:y2;
	new bool:show=false;
	if (class == ZOMBIECLASS_HUNTER)
	{
		loot_p=GetConVarFloat(l4d_loot_hunter);
		loot_num=GetConVarFloat(l4d_loot_hunter_num);
		y1=GetConVarFloat(l4d_kill_addhp_hunter_1);
		y2=GetConVarFloat(l4d_kill_addhp_hunter_2);
		show=true;
		//PrintToChatAll("ZOMBIECLASS_HUNTER");
	}
	else if (class == ZOMBIECLASS_SMOKER)
	{
		loot_p=GetConVarFloat(l4d_loot_smoker);
		loot_num=GetConVarFloat(l4d_loot_smoker_num);
		y1=GetConVarFloat(l4d_kill_addhp_smoker_1);
		y2=GetConVarFloat(l4d_kill_addhp_smoker_2);
		show=true;
		//PrintToChatAll("ZOMBIECLASS_SMOKER");
  	}
	else if (class == ZOMBIECLASS_BOOMER)
	{
		loot_p=GetConVarFloat(l4d_loot_boomer);
		loot_num=GetConVarFloat(l4d_loot_boomer_num);
		y1=GetConVarFloat(l4d_kill_addhp_boomer_1);
		y2=GetConVarFloat(l4d_kill_addhp_boomer_2);
		show=true;
 		//PrintToChatAll("ZOMBIECLASS_BOOMER");
	} 
	else if (class == ZOMBIECLASS_SPITTER)
	{
		loot_p=GetConVarFloat(l4d_loot_spitter);
		loot_num=GetConVarFloat(l4d_loot_spitter_num);
		y1=GetConVarFloat(l4d_kill_addhp_spitter_1);
		y2=GetConVarFloat(l4d_kill_addhp_spitter_2);
		show=true;
		//PrintToChatAll("ZOMBIECLASS_SPITTER");
	}
	else if (class == ZOMBIECLASS_JOCKEY)
	{
		loot_p=GetConVarFloat(l4d_loot_jockey);
		loot_num=GetConVarFloat(l4d_loot_jockey_num);
		y1=GetConVarFloat(l4d_kill_addhp_jockey_1);
		y2=GetConVarFloat(l4d_kill_addhp_jockey_2);
		show=true;
		//PrintToChatAll("ZOMBIECLASS_JOCKEY");
	}
	else if (class == ZOMBIECLASS_CHARGER)
	{
		loot_p=GetConVarFloat(l4d_loot_charger);
		loot_num=GetConVarFloat(l4d_loot_charger_num);
		y1=GetConVarFloat(l4d_kill_addhp_charger_1);
		y2=GetConVarFloat(l4d_kill_addhp_charger_2);
		show=true;
		//PrintToChatAll("ZOMBIECLASS_CHARGER");
	}
	if(show)
	{
		Format(lootmsg, sizeof(lootmsg), "%N droped some thing", victim);
		if(IsValidClient(attacker))
		{
			if(GetClientTeam(attacker) == 3)
			{
				if(ShowKillMsgOnChat() )PrintToChatAll("\x04%N\x03 ------> \x04%N", attacker, victim);
				SpawnItemFromDieResult(victim, loot_p, loot_num, lootmsg);
				return Plugin_Continue;
			}
		}
		else
		{
			if(ShowKillMsgOnChat())PrintToChatAll("\x04%N\x03 dead", victim);
			SpawnItemFromDieResult(victim, loot_p, loot_num,lootmsg);
			return Plugin_Continue;
		}
 		if(headshot)
		{
			lootheadmult=GetConVarFloat(l4d_loot_headshot);
			headhpmult=GetConVarFloat(l4d_kill_addhp_headshot_mult);
			Format(hintmsg, sizeof(hintmsg),  "headshot", dist);
        	Format(chatmsg, sizeof(chatmsg), "\x04%N\x03 -headshot-> \x04%N", attacker,victim);
 		
			ClientCommand(attacker, "vocalize PlayerNiceShot");
			CreateTimer(1.0, OneLaught, attacker);
		}
		else
		{
			 lootheadmult=GetConVarFloat(l4d_loot_headshotno);
			 headhpmult=GetConVarFloat(l4d_kill_addhp_noheadshot_mult);

			 Format(hintmsg, sizeof(hintmsg),  "kill", dist);
        	 Format(chatmsg, sizeof(chatmsg), "\x04%N\x03 ------> \x04%N", attacker,victim);
			
		}
 
		new Float:x1=0.0;
		new Float:x2=GetConVarFloat(l4d_kill_addhp_distance);

		kindmult=(fdist*(y2-y1)-x1*y2+y1*x2)/(x2-x1);

		y1=weapon1;
		y2=weapon2;
		weaponmult=(fdist*(y2-y1)-x1*y2+y1*x2)/(x2-x1);
		new Float:addhp= headhpmult*kindmult*weaponmult*addhpmult;
		difficult=RoundFloat(addhp);
 
 		if(GetConVarInt(l4d_kill_addhp_enabled)>0)
		{
			AddHealth(attacker, addhp);
		}
		Format(hintmsg, sizeof(hintmsg),  "%s, hp + %i", hintmsg, difficult);

 		if(ShowKillMsgOnChat())
		{
        	Format(chatmsg, sizeof(chatmsg), "%s\x03 (%i)", chatmsg, difficult);
			PrintToChatAll(chatmsg);
		}

 		if(SpawnItemFromDieResult(victim, loot_p*lootheadmult, loot_num,lootmsg)==0)
		{
 			if(ShowKillMsgOnPanel())PrintHintText(attacker, hintmsg);
		}
	}

	if (class == ZOMBIECLASS_TANK)
	{
		if(IsValidClient(attacker) && GetClientTeam(attacker) == 2)
		{	
			new r=GetRandomInt(0, 100);
			if(r < RoundFloat(GetConVarFloat(l4d_loot_killtank_reward)))
			{

				new r1=0;
				if(L4D2Version)	r1=GetRandomInt(0, 3);
				else 	r1=GetRandomInt(0, 1);
				if(r1==0)
				{
					Give(attacker, "first_aid_kit");
					PrintToChatAll("\x04%N\x03 finally killed by\x04 %N \x03and earned a \x04first aid kit",victim, attacker);
 				}
				if(r1==1)
				{
					Give(attacker, "pain_pills");
					PrintToChatAll("\x04%N\x03 finally killed by\x04 %N \x03and earned a \x04pills",victim, attacker);
				}
				if(r1==2)
				{
					Give(attacker, "adrenaline");
					PrintToChatAll("\x04%N\x03 finally killed by\x04 %N \x03and earned a \x04adrenaline",victim, attacker);
				}
				if(r1==3)
				{
					Give(attacker, "defibrillator");
					PrintToChatAll("\x04%N\x03 finally killed by\x04 %N \x03and earned a \x04defibrillator",victim, attacker);
				}
 
			}
			else
			{
				 Format(chatmsg, sizeof(chatmsg), "\x04%N\x03 finally killed by\x04 %N",victim, attacker);
			}

			if(GetConVarInt(l4d_kill_addhp_enabled)>0)
			{
				AddHealth(attacker, GetConVarFloat(l4d_kill_addhp_tank));
			}
		}
 		else  if(attacker==victim)
		{
 			Format(chatmsg, sizeof(chatmsg), "\x04%N\x03 killed self", victim);
		}
		else
		{
 			Format(chatmsg, sizeof(chatmsg), "\x04%N\x03 dead",victim);
		}
  		SpawnItemFromDieResult(victim, GetConVarFloat(l4d_loot_tank), GetConVarFloat(l4d_loot_tank_num),"Tank droped some thing");
		CreateTimer(5.0, BossDeadLaught);
 		if(ShowKillMsgOnChat())
		{
			 PrintToChatAll(chatmsg);
		} 
	}
	return Plugin_Continue;
}
public Action:witchreward(Handle:timer, any:ClientId)
{
 
	decl String:buff[165];

	Format(buff, sizeof(buff), "Witch was robbed by %N", ClientId);
	new res=SpawnItemFromDieResult(ClientId, GetConVarFloat(l4d_loot_witch), GetConVarFloat(l4d_loot_witch_num), buff);
	if( ShowKillMsgOnChat() && res>0) 
	{
		PrintToChatAll("\x04Witch\x03 was robbed by\x04 %N",ClientId);
	}
}
public Action:BossDeadLaught(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		if (GetClientTeam(i) == 2)
		{
			ClientCommand(i, "vocalize PlayerLaugh");
		}
	} 
}
public Action:OneLaught(Handle:timer, Handle:target)
{
	ClientCommand(target, "vocalize PlayerLaugh");
}

Give(Client, String:itemId[])
{
	new String:command[] = "give";
	new flags = GetCommandFlags(command);
	
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(Client, "%s %s", command, itemId);
	SetCommandFlags(command, flags);
}

 

SpawnItemFromDieResult(client, Float:fp, Float:fnum, String:msg[])
{
	
	new p=RoundFloat(fp);
	new num=RoundFloat(fnum);
	new r;
	r= GetRandomInt(0, 100);
	if(r < p)
	{
		new a=RoundFloat(GetConVarFloat(l4d_loot_health));
		new b=RoundFloat(GetConVarFloat(l4d_loot_weapon));
		new c=RoundFloat(GetConVarFloat(l4d_loot_weapon_melee));
		new d=RoundFloat(GetConVarFloat(l4d_loot_item));
		if(!L4D2Version)
		{
			b=b+c;
			c=0;
		}
		if(GetConVarInt(l4d_loot_boss_show_msg)>0) PrintHintTextToAll(msg);

		for(new i=0; i<num ; i++)
		{
		 
			r=GetRandomInt(0, a+b+c+d);
			new r1=0;
			if(r<a)
			{
				if(L4D2Version)r1=GetRandomInt(0, 4);
				else r1=GetRandomInt(0, 1);
				if(r1==0) Give(client, "first_aid_kit");
				if(r1==1)	Give(client, "pain_pills");	
				if(r1==3)	Give(client, "adrenaline");
				if(r1==4)	Give(client, "defibrillator");
				
			}
	
			else if(r<(a+b))
			{
				if(L4D2Version)r1=GetRandomInt(0, 15);
				else r1=GetRandomInt(0, 2);
				if(r1==0) Give(client, "rifle");
				if(r1==1) Give(client, "autoshotgun");
				if(r1==2)	Give(client, "hunting_rifle");
 
				if(r1==3) Give(client, "pistol_magnum");
				if(r1==4) Give(client, "pistol_magnum");
				if(r1==5) Give(client, "rifle_ak47");
				if(r1==6) Give(client, "rifle_ak47");
				if(r1==7) Give(client, "rifle_ak47");


				if(r1==8) Give(client, "shotgun_spas");	
				
				if(r1==9) Give(client, "rifle_desert");
				if(r1==10) Give(client, "rifle_sg552");

				if(r1==11) Give(client, "grenade_launcher");

				if(r1==12) Give(client, "sniper_awp");
				if(r1==13) Give(client, "sniper_military");
				if(r1==14) Give(client, "sniper_scout");
				if(r1==15) Give(client, "grenade_launcher");
		
			}
			else if(r<(a+b+c))
			{
				r1=GetRandomInt(0, 11);
				if(r1==0) Give(client, "chainsaw");
				if(r1==1) Give(client, "fireaxe");
				if(r1==2)	Give(client, "electric_guitar");

				if(r1==3) Give(client, "crowbar");
				if(r1==4) Give(client, "katana");
				if(r1==5) Give(client, "katana");
				if(r1==6) Give(client, "weapon_fireworkcrate");
				if(r1==7) Give(client, "golfclub");
				if(r1==8) Give(client, "frying_pan");
				if(r1==9) Give(client, "machete");
				if(r1==10) Give(client, "cricket_bat");
				if(r1==11) Give(client, "baseball_bat");
 
 
 			}
			else 
			{
			 	if(L4D2Version)r1=GetRandomInt(0, 6);
				else r1=GetRandomInt(0, 2);
				if(r1==0) Give(client, "molotov");
				if(r1==1) Give(client, "pipe_bomb");
				if(r1==2)	Give(client, "gascan");
				if(r1==3) Give(client, "vomitjar");
				if(r1==4) Give(client, "weapon_upgradepack_explosive");
				if(r1==5) Give(client, "weapon_upgradepack_incendiary");
				if(r1==6) Give(client, "weapon_fireworkcrate");
 			}
		}
		return 1;
	}
	else
	{
		return 0;
	}
}
 
stock bool:IsValidClient(iClient)
{
    if (iClient <= 0) return false;
    if (iClient > MaxClients) return false;
    if(!IsClientInGame(iClient))return false;
 	return true;
}
 