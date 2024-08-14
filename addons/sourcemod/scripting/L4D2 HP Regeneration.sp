#include <sourcemod>
#pragma semicolon 1

#define L4D2 HP Regen
#define PLUGIN_VERSION "1.63"

#define ZOMBIECLASS_SMOKER 1
#define ZOMBIECLASS_BOOMER 2
#define ZOMBIECLASS_HUNTER 3
#define ZOMBIECLASS_SPITTER 4
#define ZOMBIECLASS_JOCKEY 5
#define ZOMBIECLASS_CHARGER 6
#define ZOMBIECLASS_TANK 8

new bool:isHooked = false;
new bool:isDelayed = false;
new bool:isSurvivor = false;
new bool:isInfected = false;
new bool:isTank = false;
new bool:isBWHealing = false;
new bool:clientRegen[MAXPLAYERS + 1] = false;
new bool:BWSurvivor[MAXPLAYERS + 1] = false;

new Handle:cvarEnable;
new Handle:cvarDelayEnable;
new Handle:clientTimer[MAXPLAYERS + 1];
new Handle:clientHurt[MAXPLAYERS + 1];
new Handle:cvarDamageStop;

new Handle:cvarEnableSurvivor;
new Handle:cvarEnableBWHealing;
new Handle:cvarTeam1;
new Handle:cvarTickRate1;
new Handle:cvarSurvivorHP;
new Handle:cvarSurvivor;
new Handle:cvarAmount1;
new Handle:cvarPercentSurvivor;

new Handle:cvarEnableInfected;
new Handle:cvarEnableTank;
new Handle:cvarTeam2;
new Handle:cvarTickRate2;
new Handle:cvarBoomer;
new Handle:cvarBoomerHealth;
new Handle:cvarCharger;
new Handle:cvarChargerHealth;
new Handle:cvarJockey;
new Handle:cvarJockeyHealth;
new Handle:cvarHunter;
new Handle:cvarHunterHealth;
new Handle:cvarSmoker;
new Handle:cvarSmokerHealth;
new Handle:cvarSpitter;
new Handle:cvarSpitterHealth;
new Handle:cvarTank;
new Handle:cvarTankHealth;
new Handle:cvarAmountBoomer;
new Handle:cvarAmountCharger;
new Handle:cvarAmountJockey;
new Handle:cvarAmountHunter;
new Handle:cvarAmountSmoker;
new Handle:cvarAmountSpitter;
new Handle:cvarAmountTank;
new Handle:cvarPercentBoomer;
new Handle:cvarPercentCharger;
new Handle:cvarPercentJockey;
new Handle:cvarPercentHunter;
new Handle:cvarPercentSmoker;
new Handle:cvarPercentSpitter;
new Handle:cvarPercentTank;

new BoomerHealth;
new ChargerHealth;
new HunterHealth;
new JockeyHealth;
new SmokerHealth;
new SpitterHealth;
new TankHealth;
new SurvivorHealth;
new iHPRegen;
new iMaxHP;

new String:modName[32];

public Plugin:myinfo = 
{
    name = "[L4D2] HP Regeneration",
    author = "Mortiegama",
    description = "Allows you to set custom HP regeneration levels for infected, survivors, and the tank.",
    version = PLUGIN_VERSION,
    url = ""
	// Thanks to:
	// MaTTe (mateo10) for making the original "HP Regeneration" plugin
	// Bl4nk for updating the plugin 
	// Graveeater for helping clean up some of the code
}

public OnPluginStart()
{
	CreateConVar("sm_hpregeneration_mortversion", PLUGIN_VERSION, "HpRegeneration Mort Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	cvarEnable = CreateConVar("sm_hpregeneration_enable", "1", "Enables the HpRegeneration plugin (Def 1)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarDelayEnable = CreateConVar("sm_hpregeneration_delayenable", "0", "Enables a delay in regeneration due to damage.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarDamageStop = CreateConVar("sm_hpregeneration_delaydamage", "2", "How long after damage stops that regeneration begins (Def 2)", FCVAR_PLUGIN, true, 1.0, false, _);

	cvarEnableSurvivor = CreateConVar("sm_hpregeneration_enablesurvivor", "0", "Enables regeneration for the Survivors (Def 1)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarEnableBWHealing = CreateConVar("sm_hpregeneration_enablebwhealing", "0", "Enables regeneration for Survivors while they are Black and White (Def 1)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarTeam1 = CreateConVar("sm_hpregeneration_team1", "2", "Sets the team to affect by teamindex value (Def 2)", FCVAR_PLUGIN, true, 0.0); 
	cvarTickRate1 = CreateConVar("sm_hpregeneration_tickrate1", "3", "Time, in seconds, between each regeneration tick (Def 3)", FCVAR_PLUGIN, true, 1.0, false, _);
	cvarSurvivor = CreateConVar("sm_hpregeneration_survivor", "1", "Survivor Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarSurvivorHP = CreateConVar("sm_hpregeneration_survivorhealth", "100", "Health to regenerate to, based on the control mode (Def 100)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmount1 = CreateConVar("sm_hpregeneration_survivoramount", "1", "Amount of life to heal per regeneration tick (Def 1)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentSurvivor = CreateConVar("sm_hpregeneration_survivorpercent", "1.0", "Amount of life to heal per regeneration tick (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);


	cvarEnableInfected = CreateConVar("sm_hpregeneration_enableinfected", "1", "Enables regeneration for the Infected (Def 1)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarEnableTank = CreateConVar("sm_hpregeneration_enabletank", "1", "Enables regeneration for the Tank (Def 0)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarTeam2 = CreateConVar("sm_hpregeneration_team2", "3", "Sets the team to affect by teamindex value (Def 3)", FCVAR_PLUGIN, true, 0.0); 
	cvarTickRate2 = CreateConVar("sm_hpregeneration_tickrate2", "1", "Time, in seconds, between each regeneration tick (Def 1)", FCVAR_PLUGIN, true, 1.0, false, _);

	cvarBoomer = CreateConVar("sm_hpregeneration_boomer", "0", "Boomer Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar, 2 - Regenerate by In-game Health)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarBoomerHealth = CreateConVar("sm_hpregeneration_boomerhealth", "1", "Health to regenerate to, based on the control mode (Def 50)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountBoomer = CreateConVar("sm_hpregeneration_boomeramount", "1", "Amount of life to heal per regeneration tick (Def 5)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentBoomer = CreateConVar("sm_hpregeneration_boomerpercent", "1.0", "Percent of life to regenerate based on health cvar (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);

	cvarCharger = CreateConVar("sm_hpregeneration_charger", "0", "Charger Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar, 2 - Regenerate by In-game Health)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarChargerHealth = CreateConVar("sm_hpregeneration_chargerhealth", "600", "Health to regenerate to, based on the control mode (Def 600)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountCharger = CreateConVar("sm_hpregeneration_chargeramount", "1", "Amount of life to heal per regeneration tick (Def 5)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentCharger = CreateConVar("sm_hpregeneration_chargerpercent", "1.0", "Amount of life to heal per regeneration tick (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);

	cvarJockey = CreateConVar("sm_hpregeneration_jockey", "0", "Jockey Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar, 2 - Regenerate by In-game Health)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarJockeyHealth = CreateConVar("sm_hpregeneration_jockeyhealth", "325", "Health to regenerate to, based on the control mode (Def 325)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountJockey = CreateConVar("sm_hpregeneration_jockeyamount", "1", "Amount of life to heal per regeneration tick (Def 5)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentJockey = CreateConVar("sm_hpregeneration_jockeypercent", "1.0", "Amount of life to heal per regeneration tick (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);

	cvarHunter = CreateConVar("sm_hpregeneration_hunter", "0", "Hunter Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar, 2 - Regenerate by In-game Health)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarHunterHealth = CreateConVar("sm_hpregeneration_hunterhealth", "250", "Health to regenerate to, based on the control mode (Def 250)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountHunter = CreateConVar("sm_hpregeneration_hunteramount", "5", "Amount of life to heal per regeneration tick (Def 5)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentHunter = CreateConVar("sm_hpregeneration_hunterpercent", "1.0", "Amount of life to heal per regeneration tick (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);

	cvarSmoker = CreateConVar("sm_hpregeneration_smoker", "0", "Smoker Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar, 2 - Regenerate by In-game Health)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarSmokerHealth = CreateConVar("sm_hpregeneration_smokerhealth", "250", "Health to regenerate to, based on the control mode (Def 250)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountSmoker = CreateConVar("sm_hpregeneration_smokeramount", "1", "Amount of life to heal per regeneration tick (Def 5)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentSmoker = CreateConVar("sm_hpregeneration_smokerpercent", "1.0", "Amount of life to heal per regeneration tick (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);

	cvarSpitter = CreateConVar("sm_hpregeneration_spitter", "0", "Boomer Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar, 2 - Regenerate by In-game Health)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarSpitterHealth = CreateConVar("sm_hpregeneration_spitterhealth", "100", "Health to regenerate to, based on the control mode (Def 100)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountSpitter = CreateConVar("sm_hpregeneration_spitteramount", "1", "Amount of life to heal per regeneration tick (Def 5)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentSpitter = CreateConVar("sm_hpregeneration_spitterpercent", "1.0", "Amount of life to heal per regeneration tick (Def 1.0)", FCVAR_PLUGIN, true, 0.0, false, _);

	cvarTank = CreateConVar("sm_hpregeneration_tank", "1", "Tank Regeneration Mode (0 - Regenerate by %, 1 - Regenerate by Cvar)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarTankHealth = CreateConVar("sm_hpregeneration_tankhealth", "6000", "Health to regenerate to, based on the control mode (Def 6000)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarAmountTank = CreateConVar("sm_hpregeneration_tankamount", "50", "Amount of life to heal per regeneration tick (Def 0)", FCVAR_PLUGIN, true, 0.0, false, _);
	cvarPercentTank = CreateConVar("sm_hpregeneration_tankpercent", "0", "Amount of life to heal per regeneration tick (Def 0.0)", FCVAR_PLUGIN, true, 0.0, false, _);


	RegAdminCmd("sm_hpsurvivor", Command_SurvivorRegen, ADMFLAG_KICK, "sm_hpsurvivor <0 or 1>");
	RegAdminCmd("sm_hpinfected", Command_InfectedRegen, ADMFLAG_KICK," sm_hpinfected <0 or 1> ");
	RegAdminCmd("sm_hptank", Command_TankRegen, ADMFLAG_KICK, "sm_hptank <0 or 1>");
	RegAdminCmd("sm_hpdelay", Command_DelayRegen, ADMFLAG_KICK, " sm_hpdelay <0 or 1> ");

	//AutoExecConfig(true, "plugin.L4D2.HPRegen");
	CreateTimer(3.0, OnPluginStart_Delayed);
	GetGameFolderName(modName, sizeof(modName));
}

public Action:OnPluginStart_Delayed(Handle:timer)
{
	if (GetConVarInt(cvarEnable))
	{
		isHooked = true;
		LogMessage("[HpRegeneration] - Loaded");
	}

	if (GetConVarInt(cvarDelayEnable))
	{
		isDelayed = true;
	}

	if (GetConVarInt(cvarEnableSurvivor))
	{
		isSurvivor = true;
	}

	if (GetConVarInt(cvarEnableInfected))
	{
		isInfected = true;
	}

	if (GetConVarInt(cvarEnableTank))
	{
		isTank = true;
	}

	if (GetConVarInt(cvarEnableBWHealing))
	{
		isBWHealing = true;
	}

	HookEvent("heal_success", event_HealSuccess);
	HookEvent("player_hurt", event_PlayerHurt);
	HookEvent("player_incapacitated", event_PlayerIncapped);
	HookEvent("player_death", event_PlayerDeath);
	HookEvent("player_team", event_PlayerTeam);
	HookEvent("revive_success", event_ReviveSuccess);
	HookEvent("round_end", event_RoundEnd);

	new BoomerType = GetConVarInt(cvarBoomer);
	if (BoomerType == 0)
	{
		new iHPMax = GetConVarInt(FindConVar("z_exploding_health"));
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentBoomer);
		BoomerHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (BoomerType == 1)
	{
		BoomerHealth = GetConVarInt(cvarBoomerHealth);		
	}

	if (BoomerType == 2)
	{
		BoomerHealth = GetConVarInt(FindConVar("z_exploding_health"));		
	}

	new ChargerType = GetConVarInt(cvarCharger);
	if (ChargerType == 0)
	{
		new iHPMax = GetConVarInt(FindConVar("z_charger_health"));
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentCharger);
		ChargerHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (ChargerType == 1)
	{
		ChargerHealth = GetConVarInt(cvarChargerHealth);		
	}

	if (ChargerType == 2)
	{
		ChargerHealth = GetConVarInt(FindConVar("z_charger_health"));		
	}

	new HunterType = GetConVarInt(cvarHunter);
	if (HunterType == 0)
	{
		new iHPMax = GetConVarInt(FindConVar("z_hunter_health"));
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentHunter);
		HunterHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (HunterType == 1)
	{
		HunterHealth = GetConVarInt(cvarHunterHealth);		
	}

	if (HunterType == 2)
	{
		HunterHealth = GetConVarInt(FindConVar("z_hunter_health"));		
	}

	new JockeyType = GetConVarInt(cvarJockey);
	if (JockeyType == 0)
	{
		new iHPMax = GetConVarInt(FindConVar("z_jockey_health"));
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentJockey);
		JockeyHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (JockeyType == 1)
	{
		JockeyHealth = GetConVarInt(cvarJockeyHealth);		
	}

	if (JockeyType == 2)
	{
		JockeyHealth = GetConVarInt(FindConVar("z_jockey_health"));		
	}

	new SmokerType = GetConVarInt(cvarSmoker);
	if (SmokerType == 0)
	{
		new iHPMax = GetConVarInt(FindConVar("z_gas_health"));
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentSmoker);
		SmokerHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (SmokerType == 1)
	{
		SmokerHealth = GetConVarInt(cvarSmokerHealth);		
	}

	if (SmokerType == 2)
	{
		SmokerHealth = GetConVarInt(FindConVar("z_gas_health"));		
	}

	new SpitterType = GetConVarInt(cvarSpitter);
	if (SpitterType == 0)
	{
		new iHPMax = GetConVarInt(FindConVar("z_spitter_health"));
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentSpitter);
		SpitterHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (SpitterType == 1)
	{
		SpitterHealth = GetConVarInt(cvarSpitterHealth);		
	}

	if (SpitterType == 2)
	{
		SpitterHealth = GetConVarInt(FindConVar("z_spitter_health"));		
	}

	new TankType = GetConVarInt(cvarTank);
	if (TankType == 0)
	{
		new iHPMax = GetConVarInt(cvarTankHealth);
		new Float:iHPRegenPer = GetConVarFloat(cvarPercentTank);
		TankHealth = RoundToZero(iHPMax*iHPRegenPer);
	}

	if (TankType == 1)
	{
		TankHealth = GetConVarInt(cvarTankHealth);		
	}

	new SurvivorType = GetConVarInt(cvarSurvivor);
	if (SurvivorType == 0)
	{
		new sHPMax = GetConVarInt(cvarSurvivorHP);
		new Float:sHPRegenPer = GetConVarFloat(cvarPercentSurvivor);
		SurvivorHealth = RoundToZero(sHPMax*sHPRegenPer);
	}

	if (SurvivorType == 1)
	{
		SurvivorHealth = GetConVarInt(cvarSurvivorHP);		
	}
}


public event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (isHooked)
	{
		if (clientTimer[client] == INVALID_HANDLE && isSurvivor == true && IsValidClient(client) && GetClientTeam(client) == GetConVarInt(cvarTeam1)) {
			clientTimer[client] = CreateTimer(GetConVarFloat(cvarTickRate1), RegenTick, client, TIMER_REPEAT); 
 	  } 
 	  
 	  	if (clientTimer[client] == INVALID_HANDLE && isInfected == true && IsValidClient(client) && GetClientTeam(client) == GetConVarInt(cvarTeam2)) {
			clientTimer[client] = CreateTimer(GetConVarFloat(cvarTickRate2), RegenTick, client, TIMER_REPEAT); 
 	  }

	}

	if (IsValidClient(client) && isDelayed)
	{
		clientHurt[client] = CreateTimer(GetConVarFloat(cvarDamageStop), DamageStop, client);
		clientRegen[client] = true;
	}	
}

public Action:RegenTick(Handle:timer, any:client)
{
	if (IsValidClient(client) && !clientRegen[client])
	{
	if (GetClientTeam(client) == GetConVarInt(cvarTeam1) && !IsPlayerIncapped(client)) 
		{
		new sHP = GetClientHealth(client);
		new Float:sBuffHP = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
		new sHPRegen = GetConVarInt(cvarAmount1);
		new sMaxHP = SurvivorHealth;

		if (BWSurvivor[client] && isBWHealing)
		{
			sMaxHP = (SurvivorHealth - 1);
		}
		else if (BWSurvivor[client] && !isBWHealing){return;}

		if ((sHPRegen + sHP + sBuffHP) <= sMaxHP) 
		{
    			SetEntProp(client, Prop_Send, "m_iHealth", sHPRegen + sHP, 1);
		}
		else if ((sHP + sBuffHP < sMaxHP) && (sMaxHP < (sHPRegen + sHP + sBuffHP)) )
		{
			SetEntProp(client, Prop_Send, "m_iHealth", sMaxHP, 1);

			if(clientTimer[client] != INVALID_HANDLE)
			{
 				KillTimer(clientTimer[client]);
				clientTimer[client] = INVALID_HANDLE;
			}
		}
		}

	else if (GetClientTeam(client) == GetConVarInt(cvarTeam2)) 
	{
	new class = GetEntProp(client, Prop_Send, "m_zombieClass");
	new iHP = GetClientHealth(client);

	switch (class)  
	{	
	case ZOMBIECLASS_BOOMER:
		{
		iHPRegen = GetConVarInt(cvarAmountBoomer);
		iMaxHP = BoomerHealth;
		}

	case ZOMBIECLASS_CHARGER:
		{
		iHPRegen = GetConVarInt(cvarAmountCharger);
		iMaxHP = ChargerHealth;
		}

	case ZOMBIECLASS_JOCKEY:
		{
		iHPRegen = GetConVarInt(cvarAmountJockey);
		iMaxHP = JockeyHealth;
		}

	case ZOMBIECLASS_HUNTER:
		{
		iHPRegen = GetConVarInt(cvarAmountHunter);
		iMaxHP = HunterHealth;
		}

	case ZOMBIECLASS_SMOKER:
		{
		iHPRegen = GetConVarInt(cvarAmountSmoker);
		iMaxHP = SmokerHealth;
		}

	case ZOMBIECLASS_SPITTER:
		{
		iHPRegen = GetConVarInt(cvarAmountSpitter);
		iMaxHP = SpitterHealth;
		}

	case ZOMBIECLASS_TANK:
		{
		if (isTank == true)
			{
			iHPRegen = GetConVarInt(cvarAmountTank);
			iMaxHP = TankHealth;
			}
		}
	}

	if ((iHPRegen + iHP) <= iMaxHP)
	{
  		SetEntProp(client, Prop_Send, "m_iHealth", iHPRegen + iHP, 1);
	}
	else if ((iHP < iMaxHP) && (iMaxHP < (iHPRegen + iHP)) )
	{
		SetEntProp(client, Prop_Send, "m_iHealth", iMaxHP, 1);

		if(clientTimer[client] != INVALID_HANDLE)
		{
 			KillTimer(clientTimer[client]);
			clientTimer[client] = INVALID_HANDLE;
		}

	}
	}
	}
}

public Action:DamageStop(Handle:timer, any:client)
{
	if (!IsPlayerOnFire(client) && IsValidClient(client))
	{
		clientRegen[client] = false;
	}

	if (IsPlayerOnFire(client) && IsValidClient(client))
	{
		clientHurt[client] = CreateTimer(GetConVarFloat(cvarDamageStop), DamageStop, client);
	}
}

public event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (clientTimer[client] != INVALID_HANDLE)
	{
   		CloseHandle(clientTimer[client]);
		clientTimer[client] = INVALID_HANDLE;
		BWSurvivor[client] = false;
		clientRegen[client] = false;
	}  
}

public event_PlayerIncapped(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidClient(client) && clientTimer[client] != INVALID_HANDLE)
	{
   		CloseHandle(clientTimer[client]);
		clientTimer[client] = INVALID_HANDLE;
	}  
}

public event_ReviveSuccess(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "subject"));
	if (IsValidClient(client) && GetEventBool(event, "lastlife"))
	{
		BWSurvivor[client] = true;
	}  
}

public event_HealSuccess(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "subject"));
	if (IsValidClient(client))
	{
		BWSurvivor[client] = false;
	}  
}

public event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidClient(client) && clientTimer[client] != INVALID_HANDLE)
	{
   		CloseHandle(clientTimer[client]);
		clientTimer[client] = INVALID_HANDLE;
		BWSurvivor[client] = false;
		clientRegen[client] = false;
	}  
}

public event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    	for (new client=1; client<=MaxClients; client++)
	{
	if (IsValidClient(client) && clientTimer[client] != INVALID_HANDLE)
	{
   		CloseHandle(clientTimer[client]);
		clientTimer[client] = INVALID_HANDLE;
		BWSurvivor[client] = false;
		clientRegen[client] = false;
	} 
	}
}

public OnClientDisconnect(client)
{
	if (clientTimer[client] != INVALID_HANDLE)
	{
   		CloseHandle(clientTimer[client]);
		clientTimer[client] = INVALID_HANDLE;
		BWSurvivor[client] = false;
		clientRegen[client] = false;
	}  
}

public IsValidClient(client)
{
	if (client == 0)
		return false;

	if (!IsClientConnected(client))
		return false;
	
	//if (IsFakeClient(client))
		//return false;
	
	if (!IsClientInGame(client))
		return false;
	
	if (!IsPlayerAlive(client))
		return false;

	if (!IsValidEntity(client))
		return false;

	return true;
}

bool:IsPlayerOnFire(client)
{
	if (IsValidClient(client))
	{
		if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE) return true;
		else return false;
	}
	else return false;
}

bool:IsPlayerIncapped(client)
{
	if (IsValidClient(client))
	{
		if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
		else return false;
	}
	else return false;
}


public Action:Command_SurvivorRegen(client, args)
{
	if (isSurvivor == false)
	{
		isSurvivor = true;
		ReplyToCommand(client, "[HP] HP Regen has been enabled for the Survivors.");
		PrintToChatAll("\x04%N\x01 has enabled HP Regeneration for Survivors.", client);
	}

	else if (isSurvivor == true)	
	{
		isSurvivor = false;
		Reset_Survivor();
		ReplyToCommand(client, "[HP] HP Regen has been disabled for the Survivors.");
		PrintToChatAll("\x04%N\x01 has disabled HP Regeneration for Survivors.", client);
	}
	return Plugin_Handled;
}

public Action:Command_InfectedRegen(client, args)
{
	if (isInfected == false)
	{
		isInfected = true;
		ReplyToCommand(client, "[HP] HP Regen has been enabled for the Infected.");
		PrintToChatAll("\x04%N\x01 has enabled HP Regeneration for Infected.", client);
	}

	else if (isInfected == true)	
	{
		isInfected = false;
		Reset_Infected();
		ReplyToCommand(client, "[HP] HP Regen has been disabled for the Infected.");
		PrintToChatAll("\x04%N\x01 has disabled HP Regeneration for Infected.", client);
	}
	return Plugin_Handled;
}

public Action:Command_TankRegen(client, args)
{
	if (isTank == false)
	{
		isTank = true;
		Reset_Tank();
		ReplyToCommand(client, "[HP] HP Regen has been enabled for the Tank.");
		PrintToChatAll("\x04%N\x01 has enabled HP Regeneration for Tank.", client);
	}

	else if (isTank == true)	
	{
		isTank = false;
		ReplyToCommand(client, "[HP] HP Regen has been disabled for the Tank.");
		PrintToChatAll("\x04%N\x01 has disabled HP Regeneration for Tank.", client);
	}
	return Plugin_Handled;
}

public Action:Command_DelayRegen(client, args)
{
	if (isDelayed == false)
	{
		isDelayed = true;
		ReplyToCommand(client, "[HP] HP Regen will be delayed while taking damage.");
		PrintToChatAll("\x04%N\x01 has enabled delaying HP Regen while taking damage.", client);
	}

	else if (isDelayed == true)	
	{
		isDelayed = false;
		ReplyToCommand(client, "[HP] HP Regen will no longer be delayed while taking damage.");
		PrintToChatAll("\x04%N\x01 has disabled the delaying HP Regen while taking damage.", client);
	}
	return Plugin_Handled;
}

public Reset_Survivor()
{
    	for (new client=1; client<=MaxClients; client++)
	{
	if (IsValidClient(client) && GetClientTeam(client) == GetConVarInt(cvarTeam1) && clientTimer[client] != INVALID_HANDLE)
		{
 			CloseHandle(clientTimer[client]);
			clientTimer[client] = INVALID_HANDLE;
		}
	}
}

public Reset_Infected()
{
    	for (new client=1; client<=MaxClients; client++)
	{
		if (IsValidClient(client) && GetClientTeam(client) == GetConVarInt(cvarTeam2) && clientTimer[client] != INVALID_HANDLE)
		{
 			CloseHandle(clientTimer[client]);
			clientTimer[client] = INVALID_HANDLE;
		}
	}
}

public Reset_Tank()
{
    	for (new client=1; client<=MaxClients; client++)
	{
	if (IsValidClient(client) && GetClientTeam(client) == GetConVarInt(cvarTeam2)) 
	{
		new class = GetEntProp(client, Prop_Send, "m_zombieClass");

		if (class == ZOMBIECLASS_TANK && clientTimer[client] != INVALID_HANDLE)
		{
   			CloseHandle(clientTimer[client]);
			clientTimer[client] = INVALID_HANDLE;
		}
	}
	}
}