/**
 * Time: 2015/05/27
 * Version: 1.1
 * - Support all game mode.
 * - Remake some auto trigger. Now it's auto trigger is simpler than before.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.3"

new bool:MapTrigger;
new bool:MapTriggerTwo;
new bool:MapTriggerThree;
new bool:MapTriggerFourth;
new bool:WarpTrigger;
new bool:WarpTriggerTwo;
new bool:WarpTriggerThree;
new bool:WarpTriggerFour;
new TriggeringBot;
new bool:GameRunning;
new bool:ScavengeRoundStarted;
new bool:FinaleHasStarted;
new bool:EscapeReady;
new bool:ConfirmFinaleTank1Death;
new bool:ConfirmFinaleTank2Death;
new bool:ConfirmPourFinale;
new bool:ConfirmPourFinale2;
new bool:GameOver;


public Plugin:myinfo =
{
	name = "Improved L4D2 Survivor AI Auto Trigger",
	author = "Xanaguy",
	description = "An improved version of ijj's variant of the L4D2 Survivor AI Auto Trigger",
	version = PLUGIN_VERSION,
	url = "NONE"
};

public OnPluginStart()
{
	CreateConVar("l4d2_survivoraitriggerfix_version", PLUGIN_VERSION, " Version of L4D2 Survivor AI Auto Trigger on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	CreateTimer(3.0, CheckAroundTriggers, 0, TIMER_REPEAT);
	
	HookEvent("finale_start", FinaleBegins);
	HookEvent("scavenge_round_start", ConfirmScavenge);
	HookEvent("scavenge_round_halftime", GameEnds);
	HookEvent("scavenge_round_finished", GameEnds);
	HookEvent("round_end", GameEnds);
	HookEvent("map_transition", GameEnds);
	HookEvent("mission_lost", GameEnds);
	HookEvent("finale_win", GameEnds);
	HookEvent("round_start_pre_entity", GameEnds);
	HookEvent("finale_vehicle_ready", EscapeTheHorde);
	HookEvent("tank_killed", ConfirmTankDeath);
	HookEvent("gascan_pour_completed", ConfirmFinalePour);
}

public OnMapStart()
{
	MapTrigger = false;
	MapTriggerTwo = false;
	MapTriggerThree = false;
	MapTriggerFourth = false;
	WarpTrigger = false;
	WarpTriggerTwo = false;
	WarpTriggerThree = false;
	WarpTriggerFour = false;
	FinaleHasStarted = false;
	ScavengeRoundStarted = false;
	EscapeReady = false;
	ConfirmFinaleTank1Death = false;
	ConfirmFinaleTank2Death = false;
	ConfirmPourFinale = false;
	ConfirmPourFinale2 = false;
	GameOver = false;
}

public OnMapEnd()
{
	MapTrigger = false;
	MapTriggerTwo = false;
	MapTriggerThree = false;
	MapTriggerFourth = false;
	WarpTrigger = false;
	WarpTriggerTwo = false;
	WarpTriggerThree = false;
	WarpTriggerFour = false;
	FinaleHasStarted = false;
	ScavengeRoundStarted = false;
	EscapeReady = false;
	ConfirmFinaleTank1Death = false;
	ConfirmFinaleTank2Death = false;
	ConfirmPourFinale = false;
	ConfirmPourFinale2 = false;
	GameOver = false;
}

public OnClientConnected(client)
{
	if (IsFakeClient(client)) return;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
			{
				GameRunning = true;
				return;
			}
		}
	}
	GameRunning = false;
}

public OnClientPutInServer(client)
{
	if (!IsFakeClient(client))
	{
		GameRunning = true;
	}
}

public OnClientDisconnect_Post(client)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
			{
				GameRunning = true;
				return;
			}
		}
	}
	GameRunning = false;
}

public Action:GameEnds(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(7.0, DelayedBoolReset);
	GameOver = true;
	FinaleHasStarted = false;
}

public Action:FinaleBegins(Handle:event, const String:name[], bool:dontBroadcast)
{
	FinaleHasStarted = true;
}

public Action:EscapeTheHorde(Handle:event, String:name[], bool:dontBroadcast)
{
	EscapeReady = true;
}

public Action:ConfirmScavenge(Handle:event, String:name[], bool:dontBroadcast)
{
	ScavengeRoundStarted = true;
}

public Action:ScavengeHalfTime(Handle:event, String:name[], bool:dontBroadcast)
{
	ScavengeRoundStarted = false;
}

public Action:ScavengeRoundConcluded(Handle:event, String:name[], bool:dontBroadcast)
{
	ScavengeRoundStarted = false;
}

public Action:ConfirmTankDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	if (FinaleHasStarted)
	{
		ConfirmFinaleTank1Death = true;
	}
	else
	{
		if (FinaleHasStarted && ConfirmFinaleTank1Death)
		{
			ConfirmFinaleTank2Death = true;
		}
	}
}

public Action:ConfirmFinalePour(Handle:event, String:name[], bool:dontBroadcast)
{
	if (FinaleHasStarted)
	{
		ConfirmPourFinale = true;
	}
	else
	{
		if (FinaleHasStarted && ConfirmPourFinale)
		{
			ConfirmPourFinale2 = true;
		}
	}
}

public Action:DelayedBoolReset(Handle:Timer)
{
	MapTrigger = false;
	MapTriggerTwo = false;
	MapTriggerThree = false;
	MapTriggerFourth = false;
	WarpTrigger = false;
	WarpTriggerTwo = false;
	WarpTriggerThree = false;
	WarpTriggerFour = false;
	FinaleHasStarted = false;
	EscapeReady = false;
	GameOver = false;
}

public Action:CheckAroundTriggers(Handle:timer)
{
	if (!GameRunning) return Plugin_Continue;
		
	if (!AllBotTeam()) return Plugin_Continue;
	
	if (GameOver) return Plugin_Continue;
	

	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	// Dead Center 1 is fine in Coop

	if (StrContains(mapname, "c1m2_streets", false) != -1)
	{
		// Dead Center 02
		// pos -6698.6 -962.6 448.4
		
		decl Float:pos1[3];
		pos1[0] = -6698.6;
		pos1[1] = -962.6;
		pos1[2] = 448.4;
		
		if (CheckforBots(pos1, 400.0) && !WarpTrigger)
		{
			//PrintToChatAll("\x04[AutoTrigger] \x01Bot found stuck near supermarket, initiating in 10 seconds.");
			//PrintToChatAll("\x04[AutoTrigger] \x01Crescendo will end 60 seconds after that.");
			PrintToChatAll("\x04[AutoTrigger] \x01The bots will deliver Whitaker's Cola...");

			// position cola: -7377.6 -1372.1 427.2
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -7377.6);
			WritePackFloat(posonedata, -1372.1);
			WritePackFloat(posonedata, 427.2);
			CreateTimer(10.0, WarpAllBots, posonedata);
			CreateTimer(10.0, CallSuperMarket);
			
			// position give cola: -5375.4 -2016.0 678.0
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -5375.4);
			WritePackFloat(postwodata, -2016.0);
			WritePackFloat(postwodata, 678.0);
			CreateTimer(65.0, WarpAllBots, postwodata);
			CreateTimer(70.0, CallTankerBoom);
			
			WarpTrigger = true;
		}
		
		new gunshop = FindEntityByName("gunshop_door_button", -1);
		
		decl Float:posx[3];
		
		if (gunshop > 0)
		{
			GetEntityAbsOrigin(gunshop, posx);
			if (CheckforBots(posx, 200.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Just in case the bots fail to call Whitaker the first time...");
				
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gunshop_door_button", "Press");
				
				MapTrigger = true;
			}
		}
	}
	
	if (StrContains(mapname, "c1m3_mall", false) != -1)
	{
		// Dead Center 03 - emergency door or windows
		// name door_hallway_lower4a, class prop_door_rotating, Input "Open"
		// they do the rest veeery slowly, but by themselves
		
		new door = FindEntityByName("door_hallway_lower4a", -1);
		
		decl Float:pos1[3];
		
		if (door > 0)
		{
			GetEntityAbsOrigin(door, pos1);
			if (CheckforBots(pos1, 200.0) && !MapTrigger)
			{
				//PrintToChatAll("\x04[AutoTrigger] \x01Bot found close to the Emergency Door, open sesame...");
				//PrintToChatAll("\x04[AutoTrigger] \x01Warping them all ahead in 30 seconds.");
				PrintToChatAll("\x04[AutoTrigger] \x01They open the door...");

				AcceptEntityInput(door, "Open");

				new Handle:posxdata = CreateDataPack();
				WritePackFloat(posxdata, 1207.4);
				WritePackFloat(posxdata, -3180.1);
				WritePackFloat(posxdata, 598.0);
				CreateTimer(30.0, WarpAllBots, posxdata);
				MapTrigger = true;
			}
		}
		
		new glass = FindEntityByName("breakble_glass_minifinale", -1);
		
		decl Float:pos2[3];
		
		if (glass > 0)
		{
			GetEntityAbsOrigin(glass, pos2);
			if (CheckforBots(pos2, 500.0) && !MapTrigger)
			{
				//PrintToChatAll("\x04[AutoTrigger] \x01Bot found close to the Alarmed Windows, open sesame...");
				//PrintToChatAll("\x04[AutoTrigger] \x01Warping them all ahead in 30 seconds.");
				PrintToChatAll("\x04[AutoTrigger] \x01They shoot out the store window...");

				new Handle:posxdata = CreateDataPack();
				WritePackFloat(posxdata, 1207.4);
				WritePackFloat(posxdata, -3180.1);
				WritePackFloat(posxdata, 598.0);
				CreateTimer(30.0, WarpAllBots, posxdata);
				MapTrigger = true;
			}
		}
		
		new escalator = FindEntityByName("escalator_upper_03-lift", -1);
		
		decl Float:pos3[3];
		
		if (escalator > 0)
		{
			GetEntityAbsOrigin(escalator, pos3);
			if (CheckforBots(pos3, 500.0) && !WarpTrigger)
			{
				//PrintToChatAll("\x04[AutoTrigger] \x01Bot found close to the Alarmed Windows, open sesame...");
				//PrintToChatAll("\x04[AutoTrigger] \x01Warping them all ahead in 30 seconds.");
				PrintToChatAll("\x04[AutoTrigger] \x01They can't go up that escalator thanks to nav... Warping...");

				new Handle:posxdata = CreateDataPack();
				WritePackFloat(posxdata, -537.854309);
				WritePackFloat(posxdata, -4196.386230);
				WritePackFloat(posxdata, 536.031250);
				CreateTimer(7.0, WarpAllBots, posxdata);
				WarpTrigger = true;
			}
		}
	}
	
	// Dead Center 4 - use ScavengeBots plugin
	if (StrContains(mapname, "c1m4_atrium", false) != -1)
	{
		//new button = FindEntityByName("button_elev_3rdfloor", -1);
		
		decl Float:pos1[3];
		pos1[0] = -4037.9;
		pos1[1] = -3411.3;
		pos1[2] = 598.0;
		//GetEntityAbsOrigin(button, pos1);
			
		if (CheckforBots(pos1, 200.0) && !MapTrigger)
		{
			//PrintToChatAll("\x04[AutoTrigger] \x01TEST01.");
			CreateTimer(5.0, BotsUnstick);
			MapTrigger = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = -4033.6;
		pos2[1] = -3415.1;
		pos2[2] = 66.0;
		
		if (CheckforBots(pos2, 200.0) && !MapTriggerTwo)
		{
			//PrintToChatAll("\x04[AutoTrigger] \x01TEST02.");
			CreateTimer(10.0, BotsStick);
			MapTriggerTwo = true;
		}
	}
	// Dark Carnival 1 is fine in Coop
	
	// Dark Carnival 2 is fine in Coop
	
	if (StrContains(mapname, "c2m3_coaster", false) != -1)
	{
		// Dark Carnival 03 - coaster buttons
		
		// Go: name minifinale_button, class func_button, Input "Press"
		// they do the rest veeery slowly, but by themselves
		
		new button = FindEntityByName("minifinale_button", -1);
		
		if (!IsValidEntity(button))
		{
			MapTrigger = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(button, pos1);
			
			if (CheckforBots(pos1, 250.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01They activate The Screaming Oak...");
				AcceptEntityInput(button, "Press");
				
				if (!IsVersus())
				{
					PrintToChatAll("\x04[AutoTrigger] \x01Campaign Survivor Bots suck at traversing the coaster. They will be warped in 3 minutes...");
					new Handle:postwodata = CreateDataPack();
					WritePackFloat(postwodata, -3572.179443);
					WritePackFloat(postwodata, 1450.377319);
					WritePackFloat(postwodata, 160.031250);
					CreateTimer(180.0, WarpAllBots, postwodata);
				}
				MapTrigger = true;

				//CreateTimer(250.0, C2M3WarpAllBotToThere);
			}
		}
	
		// c2m3 - after shut off the rollercoaster, warp them to the special spot
		decl Float:posx[3];
		posx[0] = -4029.9;
		posx[1] = 1428.9;
		posx[2] = 222.0;
		// confusion spot -4029.9 1428.9 222.0, teleport them off
		// to: -4315.1 2311.4 313.2
		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The coaster alarm has been disabled!");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -4315.1);
			WritePackFloat(posdata, 2311.4);
			WritePackFloat(posdata, 313.2);
			CreateTimer(50.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}

	}
	
	// Dark Carnival 4 is fine in Coop
	
	if (StrContains(mapname, "c2m5_concert", false) != -1)
	{
		if (MapTrigger) return Plugin_Continue;
		// map is Dark Carnival 5

		decl Float:pos1[3];
		pos1[0] = -3406.7;
		pos1[1] = 3003.2;
		pos1[2] = -193.9;
		
		if (CheckforBots(pos1, 200.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Lights...");
			//AcceptEntityInput(lightsbutton, "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "stage_lights_button", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrContains(mapname, "c3m1_plankcountry", false) != -1)
	{
		// Swamp Fever 01 - classic crescendo
		// they freakin KILL THEMSELVES by teleporting into the river, yay
		// name: ferry_button, func_button
		
		new button = FindEntityByName("ferry_button", -1);
		
		if (!IsValidEntity(button) && !MapTrigger)
		{
			SetConVarInt(FindConVar("sb_unstick"), 0);
			MapTrigger = true;

			PrintToChatAll("\x04[AutoTrigger] \x01The ferry was called...");
	
			CreateTimer(150.0, BotsUnstick);
		}
		/*
		decl Float:posx[3];
		posx[0] = -4340.6;
		posx[1] = 6068.1;
		posx[2] = 60.2;
		// confusion spot -4340.6 6068.1 60.2
		if (CheckforBots(posx, 100.0) && !MapTriggerTwo)
		{
			SetConVarInt(FindConVar("sb_unstick"), 1);
			MapTriggerTwo = true;
		}
		*/
	}
	
	// Swamp Fever 2 is fine in Coop

	if (StrContains(mapname, "c3m3_shantytown", false) != -1)
	{	
		decl Float:pos1[3];	
		
		pos1[0] = 198.193573;
		pos1[1] = -2813.822266;
		pos1[2] = -21.995037;
		
		if (CheckforBots(pos1, 200.0) && !WarpTrigger)
		{
		PrintToChatAll("\x04[AutoTrigger] \x01The plank will be lowered...");
			
		new Handle:posonedata = CreateDataPack();
		WritePackFloat(posonedata, -358.478455);
		WritePackFloat(posonedata, -4138.272461);
		WritePackFloat(posonedata, 79.031250);
		CreateTimer(15.0, WarpAllBots, posonedata);
		CreateTimer(15.0, BridgeMiniFinale);
			
		new Handle:postwodata = CreateDataPack();
		WritePackFloat(postwodata, -40.596180);
		WritePackFloat(postwodata, -4241.562500);
		WritePackFloat(postwodata, 110.183243);
		CreateTimer(30.0, WarpAllBots, postwodata);
			
		WarpTrigger = true;
		}

	}
	if (StrContains(mapname, "c3m4_plantation", false) != -1)
	{
		// map is Swamp Fever 4
		
		// getpos 1667.1 -114.4 286.0
		decl Float:pos1[3];
		pos1[0] = 1667.1;
		pos1[1] = -114.4;
		pos1[2] = 286.0;

		//new button = FindEntityByName("escape_gate_button", -1);
		
		// finale balcony coordinates - getpos 1524.9 1937.5 188.1	
		if (CheckforBots(pos1, 300.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Virgil has been contacted...");
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 1667.1);
			WritePackFloat(posonedata, -114.4);
			WritePackFloat(posonedata, 286.0);
			CreateTimer(0.1, WarpAllBots, posonedata);
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "escape_gate_button", "Press");
			//AcceptEntityInput(button, "Press");
			MapTrigger = true;

			CreateTimer(30.0, C3M4FinaleStart);
		}
	}
	
	//Hard Rain 1 - is fine in Coop
	
	if (StrContains(mapname, "c4m2_sugarmill_a", false) != -1)
	{
		// Hard Rain 02  -1413.3 -9390.2 671.1
		decl Float:pos1[3];
		pos1[0] = -1413.3;
		pos1[1] = -9390.2;
		pos1[2] = 671.1;
		// confusion spot -1413.3 -9390.2 671.1
		if (CheckforBots(pos1, 200.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Here comes the elevator...");
			SetConVarInt(FindConVar("sb_unstick"), 0);
			MapTrigger = true;
		}

		decl Float:pos2[3];
		pos2[0] = -1370.9;
		pos2[1] = -9549.0;
		pos2[2] = 190.2;
		// confusion spot -1370.9 -9549.0 190.2
		if (CheckforBots(pos2, 200.0) && !MapTriggerTwo)
		{
			SetConVarInt(FindConVar("sb_unstick"), 1);
			CreateTimer(1.0, C4M2BotsActions);
			CreateTimer(11.0, ResumeBotsActions);
			MapTriggerTwo = true;
		}
	}
	
	//Hard Rain 3 - is fine in Coop
	
	//Hard Rain 4 - is fine in Coop
	
	//Hard Rain 5 - is fine in Coop, astonishingly
	
	//The Parish 1 - is fine in Coop
	
	if (StrContains(mapname, "c5m2_park", false) != -1)
	{
		// c5m2_park - name finale_cleanse_entrance_door class prop_door_rotating "close"
		// huddle -9654.8 -5962.8 -166.8 -9645.740234 -5970.330566 -151.945755;
		// name finale_cleanse_exit_door, class prop_door_rotating "open" - a few secs later
		
		// -9614.2 -5981.5 -151.9;
		// ready into the trailer
		decl Float:pos1[3];
		pos1[0] = -9614.2;
		pos1[1] = -5981.5;
		pos1[2] = -151.9;
		
		if (CheckforBots(pos1, 100.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They are ready to run for the tower...");
			/*
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, pos1[0]);
			WritePackFloat(posdata, pos1[1]);
			WritePackFloat(posdata, pos1[2]);
			CreateTimer(0.5, WarpAllBots, posdata);
			*/
			CreateTimer(10.0, RunBusStationEvent);
			MapTrigger = true;
		}
	}
	
	//The Parish 3 - is fine in Coop
	
	if (StrContains(mapname, "c5m4_quarter", false) != -1)
	{
		//c5m4_quarter - huddle after crescendo -1487.0 684.0 109.0
		// teleport to -2179.3,389.3,302.0;
		// -2019.551636 494.859070 302.031250;
		// 70sec
		
		new button = FindEntityByName("tractor_button", -1);
		
		//decl Float:pos1[3];
		//pos1[0] = -1487.0;
		//pos1[1] = 684.0;
		//pos1[2] = 109.0;
		
		if (!IsValidEntity(button) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The tractor has started!");
			//CreateTimer(100.0, C5M4BotsActions);
			MapTrigger = true;
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -1864.4);
			WritePackFloat(posdata, 474.3);
			WritePackFloat(posdata, 302.0);
			CreateTimer(100.0, WarpAllBots, posdata);
		}
		/*
		decl Float:pos1[3];
		pos1[0] = -2179.3;
		pos1[1] = 389.3;
		pos1[2] = 302.0;
		if (CheckforBots(pos1, 100.0) && !MapTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots move on...");
			CreateTimer(5.0, ResumeBotsActions);
			MapTriggerTwo = true;
		}
		*/
	}

	if (StrContains(mapname, "c5m5_bridge", false) != -1)
	{
		// c5m5_bridge   pos -11591.227539 6172.690430 518.031250;
		// name radio_fake_button, class func_button "Press"
		// a little later standard finale call
		
		new button = FindEntityByName("radio_fake_button", -1);
		
		if (!IsValidEntity(button) && !MapTrigger)
		{
			MapTrigger = true;
			CreateTimer(13.0, C5M5FinaleStart);
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(button, pos1);
			
			if (CheckforBots(pos1, 200.0) && !MapTrigger)
			{
				//PrintToChatAll("\x04[AutoTrigger] \x01C5M5FinaleTrigger.");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio_fake_button", "Use");
				//AcceptEntityInput(button, "Press");
				
				CreateTimer(13.0, C5M5FinaleStart);
				MapTrigger = true;
			}
		}
	}

	//The Passing 01 - is fine in Coop

	if (StrContains(mapname, "c6m2_bedlam", false) != -1)
	{
		// The Passing 02
		decl Float:posx[3];
		posx[0] = 439.9;
		posx[1] = 1689.4;
		posx[2] = -125.1;
		// confusion spot 439.9 1689.4 -125.1, teleport them off
		// to: 36.9 1888.7 -1.9;
		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots proceed...");

			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 36.9);
			WritePackFloat(posdata, 1888.7);
			WritePackFloat(posdata, -1.9);
			CreateTimer(10.0, WarpAllBots, posdata);

			WarpTrigger = true;
		}
	}

	//The Passing 03 - use ScavengeBots plugin

	if (StrContains(mapname, "c7m1_docks", false) != -1)
	{
		// The Sacrifice 01
		
		decl Float:pos3[3];
		pos3[0] = 7889.744141;
		pos3[1] = -68.818085;
		pos3[2] = 27.752344;		
		
		if (CheckforBots(pos3, 200.0) && !WarpTriggerTwo && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01A fail-safe has been activated.");

			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, 7106.062012);
			WritePackFloat(postwodata, 675.531921);
			WritePackFloat(postwodata, 129.438416);
			CreateTimer(10.0, WarpAllBots, postwodata);
			CreateTimer(0.1, BotsStopMove);
			CreateTimer(3.0, BotsStartMove);
			WarpTrigger = true;
		}
		
		new button = FindEntityByName("tankdoorin_button", -1);
		
		if (!IsValidEntity(button))
		{
			MapTrigger = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(button, pos1);
			
			if (CheckforBots(pos1, 150.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Someone opens the door...");
				AcceptEntityInput(button, "Press");
				if (!IsVersus())
				CreateTimer(5.0, TankDoor01COOP);
				else if (!IsCoop())
				CreateTimer(5.0, TankDoor01VERSUS);

				MapTrigger = true;
			}
		}

		if (!IsValidEntity(FindEntityByName("tankdoorout_button", -1)))
		{
			MapTriggerTwo = true;
		}
		else
		{
			decl Float:pos2[3];
			GetEntityAbsOrigin(FindEntityByName("tankdoorout_button", -1), pos2);
			
			if (CheckforBots(pos2, 100.0) && !MapTriggerTwo)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The bots move on...");
				AcceptEntityInput(FindEntityByName("tankdoorout_button", -1), "Press");
				CreateTimer(5.0, TankDoor02);
				MapTriggerTwo = true;
			}
		}
	
		decl Float:posx[3];
		posx[0] = 4729.166016;
		posx[1] = 1270.755005;
		posx[2] = 200.843201;
		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots must go around these barrels...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 5030.492676);
			WritePackFloat(posdata, 1304.330444);
			WritePackFloat(posdata, 144.031250);
			CreateTimer(7.5, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}

	if (StrContains(mapname, "c7m2_barge", false) != -1)
	{
		// The Sacrifice 02
		decl Float:posx[3];
		posx[0] = -4355.0;
		posx[1] = -62.0;
		posx[2] = 62.0;
		// confusion spot -4355.0 -62.0 62.0, teleport them off
		// to: -5408.7 858.6 696.4
		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Thanks to the Scavenge exclusive ladder on the ship, the bots will instead be warped to the top of the pile of crap. This will result in the panic event.\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -5408.7);
			WritePackFloat(posdata, 858.6);
			WritePackFloat(posdata, 696.4);
			CreateTimer(10.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrContains(mapname, "c7m3_port", false) != -1)
	{
		// The Sacrifice 03

		if (!IsValidEntity(FindEntityByName("finale_start_button", -1)) && !MapTrigger)
		{
			MapTrigger = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(FindEntityByName("finale_start_button", -1), pos1);
			
			if (CheckforBots(pos1, 300.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01They see the boat and start the first generator.");
				AcceptEntityInput(FindEntityByName("finale_start_button", -1), "Press");
				CreateTimer(5.0, C7M3GeneratorStart);
				MapTrigger = true;

				CreateTimer(20.0, C7M3WarpBotsToGenerator1);
			}
		}

		if (!IsValidEntity(FindEntityByName("finale_start_button1", -1)) && MapTrigger && !MapTriggerTwo)
		{
			MapTriggerTwo = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(FindEntityByName("finale_start_button1", -1), pos1);
			
			if (CheckforBots(pos1, 300.0) && !MapTriggerTwo)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The second generator starts...");
				AcceptEntityInput(FindEntityByName("finale_start_button1", -1), "Press");
				CreateTimer(5.0, C7M3GeneratorStart1);
				MapTriggerTwo = true;

				CreateTimer(20.0, C7M3WarpBotsToGenerator2);
			}
		}
		
		if (!IsValidEntity(FindEntityByName("finale_start_button2", -1)) && MapTrigger && MapTriggerTwo && !MapTriggerThree)
		{
			MapTriggerThree = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(FindEntityByName("finale_start_button2", -1), pos1);
			
			if (CheckforBots(pos1, 300.0) && !MapTriggerThree)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The third generator starts...");
				AcceptEntityInput(FindEntityByName("finale_start_button2", -1), "Press");
				CreateTimer(5.0, C7M3GeneratorStart2);
				MapTriggerThree = true;
			}
		}

		decl Float:pos1[3];
		pos1[0] = -0.8;
		pos1[1] = -1360.1;
		pos1[2] = 56.5;

		if (CheckforBots(pos1, 100.0) && !MapTriggerFourth)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They're on the bridge...");
		
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -123.2);
			WritePackFloat(posdata, -1747.9);
			WritePackFloat(posdata, 314.0);
			CreateTimer(10.0, WarpAllBots, posdata);
			CreateTimer(12.0, C7M3BridgeStartButton);

			MapTriggerFourth = true;

			CreateTimer(30.0, C7M3GeneratorFinaleButtonStart);
		}
	}
	
	if (StrContains(mapname, "c8m3_sewers", false) != -1)
	{
		new c8m3button = FindEntityByName("washer_lift_button2", -1);
		
		if (!IsValidEntity(c8m3button))
		{
			WarpTrigger = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(c8m3button, pos1);
			
			if (CheckforBots(pos1, 200.0) && !WarpTrigger)
			{
				if (IsCoop())
				{
					PrintToChatAll("\x04[AutoTrigger] \x01The bots will teleport to after the hole drop in 60 seconds.\x01");
			
					new Handle:posdata = CreateDataPack();
					WritePackFloat(posdata, 10837.338867);
					WritePackFloat(posdata, 6953.696777);
					WritePackFloat(posdata, 200.227829);
					CreateTimer(60.0, WarpAllBots, posdata);
					
					WarpTrigger = true;
				}
				if (IsVersus())
				{
					PrintToChatAll("\x04[AutoTrigger] \x01The bots will teleport to after the hole drop in 45 seconds.\x01");
			
					new Handle:posdata = CreateDataPack();
					WritePackFloat(posdata, 10837.338867);
					WritePackFloat(posdata, 6953.696777);
					WritePackFloat(posdata, 200.227829);
					CreateTimer(45.0, WarpAllBots, posdata);
					
					WarpTrigger = true;
				}
			}
		}
	}
		
	if (StrContains(mapname, "c9m2_lots", false) != -1)
	{
		// Crash Course 02
		
		// Go: name finaleswitch_initial, class func_button_timed, Input "Press"
		// they do the rest veeery slowly, but by themselves
		
		new button = FindEntityByName("finaleswitch_initial", -1);
		
		if (!IsValidEntity(button))
		{
			MapTrigger = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(button, pos1);
			
			if (CheckforBots(pos1, 500.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Starting the generator...");
				AcceptEntityInput(button, "Press");
				CreateTimer(5.0, GeneratorStart);
				MapTrigger = true;

				// Crash Cause 02 - Generator Second Start
				CreateTimer(205.0, GeneratorStartTwoReady);
				CreateTimer(210.0, GeneratorStartTwo);
			}
		}
	}
	
	if (StrContains(mapname, "c10m3_ranchhouse", false) != -1)
	{
		// The Sacrifice 02
		decl Float:posx[3];
		posx[0] = -7451.890137;
		posx[1] = -2112.419922;
		posx[2] = -16.402706;

		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Just in case the bots are trying to get in through the window...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -7326.758301);
			WritePackFloat(posdata, -2100.379150);
			WritePackFloat(posdata, 8.031250);
			CreateTimer(5.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}

	if (StrContains(mapname, "c10m4_mainstreet", false) != -1)
	{
		// map is Death Toll 4

		new button = FindEntityByName("button", -1);

		decl Float:pos1[3];
		GetEntityAbsOrigin(button, pos1);

		if (CheckforBots(pos1, 200.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The forklift lowers...");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button", "Use");
			MapTrigger = true;
		}
	}

	if (StrContains(mapname, "c10m5_houseboat", false) != -1)
	{
		// map is Death Toll 5
		// 3884.3 -4144.5 -89.9
		//new button = FindEntityByName("radio_button", -1);

		decl Float:pos1[3];
		pos1[0] = 3884.3;
		pos1[1] = -4144.5;
		pos1[2] = -89.9;
		//GetEntityAbsOrigin(button, pos1);

		if (CheckforBots(pos1, 400.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01John Slater has been contacted...");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio_button", "Use");
			//UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "orator_boat_radio", "Kill");

			MapTrigger = true;

			CreateTimer(20.0, C10M5FinaleStart);
		}
	}

	if (StrContains(mapname, "c11m3_garage", false) != -1)
	{
		// map is Dead Air 3.

		new gascans = FindEntityByName("barricade_gas_can", -1);
		
		if (gascans == -1) // has it been destroyed already? continue without doing anything.
		{
			MapTrigger = true;
			return Plugin_Continue;
		}
			
		decl Float:pos1[3];
		GetEntityAbsOrigin(gascans, pos1);
	
		if (CheckforBots(pos1, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(gascans, "Ignite");
			MapTrigger = true;
		}
	}

	if (StrContains(mapname, "c11m5_runway", false) != -1)
	{
		// map is Dead Air 5
		// pos -5033.4 9164.0 -129.9
		
		new button = FindEntityByName("radio_fake_button", -1);
		
		if ((button == -1) && !MapTrigger && !FinaleHasStarted)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Preparing to fuel the plane...");
			CreateTimer(20.0, C11M5FinaleStart);
			MapTrigger = true;
		}
		
		decl Float:pos1[3];
		GetEntityAbsOrigin(button, pos1);

		if (CheckforBots(pos1, 1500.0) && !MapTrigger && !FinaleHasStarted)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio_fake_button", "Press");
			PrintToChatAll("\x04[AutoTrigger] \x01Preparing to fuel the plane...");
			CreateTimer(20.0, C11M5FinaleStart);
			MapTrigger = true;
		}
	}

	if (StrContains(mapname, "c12m2_traintunnel", false) != -1)
	{
		// map is BH2
		//decl Float:posdoor[3], Float:postriggerer[3], Float:anglestriggerer[3];
		decl Float:posdoor[3];
		
		posdoor[0] = -8605.0;
		posdoor[1] = -7530.0;
		posdoor[2] = -21.0;
		/*
		postriggerer[0] = -8600.0;
		postriggerer[1] = -7504.0;
		postriggerer[2] = -60.0;
		
		anglestriggerer[0] = 8.0;
		anglestriggerer[1] = -90.0;
		anglestriggerer[2] = 0.0;
		*/
		if (CheckforBots(posdoor, 300.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Opening the door...");
			MapTrigger = true;
			
			//TeleportEntity(TriggeringBot, postriggerer, anglestriggerer, NULL_VECTOR); // move bot infront of the door, facing it
			
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "emergency_door", "open");
		}
	}
	
	if (StrContains(mapname, "c12m3_bridge", false) != -1)
	{
		decl Float:posx[3];
		posx[0] = 5949.163086;
		posx[1] = -13298.776367;
		posx[2] = -72.499367;

		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Bots are going to derail the train car...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 8254.743164);
			WritePackFloat(posdata, -13578.223633);
			WritePackFloat(posdata, 0.031250);
			CreateTimer(20.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrContains(mapname, "c13m1_alpinecreek", false) != -1)
	{
		// Cold Stream 01
		
		decl Float:posx[3];
		posx[0] = 1068.9;
		posx[1] = 251.4;
		posx[2] = 766.0;

		if (CheckforBots(posx, 100.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bunker opens...");
			AcceptEntityInput(FindEntityByName("bunker_button", -1), "Press");
			MapTrigger = true;
		}
	}
	
	if (StrContains(mapname, "c13m2_southpinestream", false) != -1)
	{
		// Cold Stream 02
		
		decl Float:posx[3];
		posx[0] = 119.1;
		posx[1] = 5574.1;
		posx[2] = 334.0;

		if (CheckforBots(posx, 600.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots have shot the barrels...");
			
			CreateTimer(1.0, BotsStopMove);
			CreateTimer(7.0, C13M2Trigger);
			CreateTimer(11.0, BotsStartMove);
			MapTrigger = true;
		}
		
		decl Float:pos1[3];
		pos1[0] = 7894.451660;
		pos1[1] = 3310.191895;
		pos1[2] = 531.832458;
		
		if (CheckforBots(pos1, 500.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01To make sure the bots don't shortcut past the first road part, they will be teleported past the ladder in 30 seconds...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 6080.580078);
			WritePackFloat(posdata, 2591.295654);
			WritePackFloat(posdata, 767.495178);
			CreateTimer(30.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = -339.385284;
		pos2[1] = 8027.178711;
		pos2[2] = 46.031250;
		
		if (CheckforBots(pos2, 500.0) && !MapTriggerTwo)		
		{
			if (!IsVersus())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Poor bots will get swept up in the current...\x01");
			
				new Handle:postwodata = CreateDataPack();
				WritePackFloat(postwodata, 127.612053);
				WritePackFloat(postwodata, 8530.405273);
				WritePackFloat(postwodata, 82.031250);
				CreateTimer(10.0, WarpAllBots, postwodata);
				MapTriggerTwo = true;
			}
		}
		
	}

	if (StrContains(mapname, "c13m4_cutthroatcreek", false) != -1)
	{
		// Cold Stream 04
		// getpos -4127.968750 -7866.249023 433.031250;
		decl Float:posx[3];
		posx[0] = -4127.9;
		posx[1] = -7866.2;
		posx[2] = 433.0;

		if (CheckforBots(posx, 100.0))
		{
			new button = FindEntityByClassname(-1, "startbldg_door_button");
			
			if (!IsValidEntity(button) && !MapTrigger)
			{
				MapTrigger = true;
				CreateTimer(1.0, BotsStick);
				CreateTimer(20.0, FinaleStart);
				CreateTimer(23.0, BotsUnstick);
			}
		}
	}

	if (StrContains(mapname, "c14m1_junkyard", false) != -1)
	{
		// The Last Stand 01
		// pos -2348.668701 500.814484 -14.431280
		
		decl Float:pos1[3];
		pos1[0] = -2348.668701;
		pos1[1] = 500.814484;
		pos1[2] = -14.431280;
		
		if (CheckforBots(pos1, 400.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They trigger the fuel pump...");

			CreateTimer(10.0, C14M1PanicEvent);
			
			MapTrigger = true;
		}
	}

	if (StrEqual(mapname, "wth_1", true))
	{
		new gauntletdoor = FindEntityByName("finale_cleanse_exit_door", -1);
		
		decl Float:posx[3];
		
		if (gauntletdoor > 0)
		{
			GetEntityAbsOrigin(gauntletdoor, posx);
			if (CheckforBots(posx, 100.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Initiating gauntlet...");
				
				CreateTimer(5.0, RunBusStationEvent);
				
				MapTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "WTH_4", true))
	{
		new wthfourdoor = FindEntityByName("emergency_door", -1);
		
		decl Float:posx[3];
		
		if (wthfourdoor > 0)
		{
			GetEntityAbsOrigin(wthfourdoor, posx);
			if (CheckforBots(posx, 150.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm goes off...");
				
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "emergency_door", "Open");
				if (IsVersus())
				{
					new Handle:posthreedata = CreateDataPack();
					WritePackFloat(posthreedata, 7816.887695);
					WritePackFloat(posthreedata, 3431.855957);
					WritePackFloat(posthreedata, -1.536017);
					CreateTimer(45.0, WarpAllBots, posthreedata);
				}
				MapTrigger = true;
			}
		}
		
		new brushone = FindEntityByName("passing1", -1);
		
		decl Float:pos1[3];
		
		if (brushone > 0)
		{
			GetEntityAbsOrigin(brushone, pos1);
			if (CheckforBots(pos1, 150.0) && !WarpTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01A board bars the way...\x01");
			
				new Handle:posonedata = CreateDataPack();
				WritePackFloat(posonedata, 7816.887695);
				WritePackFloat(posonedata, 3431.855957);
				WritePackFloat(posonedata, -1.536017);
				CreateTimer(15.0, WarpAllBots, posonedata);
				WarpTrigger = true;
			}
		}
		
		new brushtwo = FindEntityByName("passing2", -1);
		
		decl Float:pos2[3];
		
		if (brushtwo > 0)
		{
			GetEntityAbsOrigin(brushtwo, pos2);
			if (CheckforBots(pos2, 150.0) && !WarpTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01A board bars the way...\x01");
			
				new Handle:postwodata = CreateDataPack();
				WritePackFloat(postwodata, 7816.887695);
				WritePackFloat(postwodata, 3431.855957);
				WritePackFloat(postwodata, -1.536017);
				CreateTimer(20.0, WarpAllBots, postwodata);
				WarpTrigger = true;
			}
		}
		
		decl Float:pos3[3];
		pos3[0] = 6800.031250;
		pos3[1] = -2137.921387;
		pos3[2] = -134.081757;

		if (CheckforBots(pos3, 200.0) && !WarpTriggerTwo && IsVersus())
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team moves through the alley...x01");
			
			new Handle:posfourdata = CreateDataPack();
			WritePackFloat(posfourdata, 6870.991699);
			WritePackFloat(posfourdata, 194.725510);
			WritePackFloat(posfourdata, -64.766510);
			CreateTimer(20.0, WarpAllBots, posfourdata);
			WarpTriggerTwo = true;
		}
	}
	
	if (StrEqual(mapname, "WTH_5", true))
	{
		new truck = FindEntityByName("prop_coop", -1);
		
		decl Float:posx[3];
		
		if (truck > 0)
		{
			GetEntityAbsOrigin(truck, posx);
			if (CheckforBots(posx, 1000.0) && !WarpTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01A vehicle bars the way...\x01");
			
				new Handle:posonedata = CreateDataPack();
				WritePackFloat(posonedata, -2985.330811);
				WritePackFloat(posonedata, 1508.161499);
				WritePackFloat(posonedata, -254.925522);
				CreateTimer(10.0, WarpAllBots, posonedata);
				WarpTrigger = true;
			}
		}
		
		decl Float:pos1[3];
		pos1[0] = 6800.031250;
		pos1[1] = -2137.921387;
		pos1[2] = -134.081757;

		if (CheckforBots(pos1, 200.0) && !WarpTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team approaches the radio...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 6870.991699);
			WritePackFloat(posdata, 194.725510);
			WritePackFloat(posdata, -64.766510);
			CreateTimer(20.0, WarpAllBots, posdata);
			WarpTriggerTwo = true;
		}
	}
	
	if (StrEqual(mapname, "uf1_boulevard", true))
	{
		new barrier = FindEntityByName("gateRestaurantRear", -1);
		
		decl Float:posx[3];
		
		if (barrier > 0)
		{
			GetEntityAbsOrigin(barrier, posx);
			if (CheckforBots(posx, 400.0) && !WarpTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The team moves out...\x01");
			
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, -209.543518);
				WritePackFloat(posdata, -2331.296875);
				WritePackFloat(posdata, 0.031250);
				CreateTimer(15.0, WarpAllBots, posdata);
				WarpTrigger = true;
			}
		}
		
		decl Float:pos1[3];
		pos1[0] = -1722.503174;
		pos1[1] = 4220.973633;
		pos1[2] = -5.968750;

		if (CheckforBots(pos1, 200.0) && !WarpTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team enters the bar...\x01");
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -5.968750);
			WritePackFloat(posonedata, 4097.378418);
			WritePackFloat(posonedata, 8.031250);
			CreateTimer(15.0, WarpAllBots, posonedata);
			WarpTriggerTwo = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = 834.767578;
		pos2[1] = 5349.852539;
		pos2[2] = 0.031250;

		if (CheckforBots(pos2, 1000.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team moves on...\x01");
			
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -1751.634888);
			WritePackFloat(postwodata, 4555.818848);
			WritePackFloat(postwodata, 0.178804);
			CreateTimer(20.0, WarpAllBots, postwodata);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "uf2_rooftops", true))
	{
		decl Float:posx[3];
		posx[0] = -2257.292969;
		posx[1] = -1573.922485;
		posx[2] = 0.031250;
		
		if (CheckforBots(posx, 50.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team ascends to the roof...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -1363.125000);
			WritePackFloat(posdata, -53.750000);
			WritePackFloat(posdata, 395.500000);
			CreateTimer(30.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
		
		decl Float:pos1[3];
		pos1[0] = -2059.250000;
		pos1[1] = 2464.000000;
		pos1[2] = 456.000000;
		
		if (CheckforBots(pos1, 200.0) && !WarpTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team ascends to the roof...\x01");
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -977.075439);
			WritePackFloat(posonedata, 3398.486816);
			WritePackFloat(posonedata, 815.158508);
			CreateTimer(20.0, WarpAllBots, posonedata);
			WarpTriggerTwo = true;
		}
	
		new bomb = FindEntityByName("crescendo_button", -1);
		
		decl Float:pos2[3];
		
		if (bomb > 0)
		{
			GetEntityAbsOrigin(bomb, pos2);
			if (CheckforBots(pos2, 500.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The fuse is lit...\x01");
				CreateTimer(9.0, UrbanFlightJoke);
				CreateTimer(10.0, TowerGoesBoom);
				CreateTimer(12.0, NeverMind);
				MapTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "uf3_harbor", true))
	{	
		new shelves = FindEntityByName("harbor_basement_shelves", -1);
		
		decl Float:posx[3];
		
		if (shelves > 0)
		{
			GetEntityAbsOrigin(shelves, posx);
			if (CheckforBots(posx, 400.0) && !WarpTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01I'll just pretend those shelves do not exist...\x01");
			
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, 1004.188477);
				WritePackFloat(posdata, -9064.051758);
				WritePackFloat(posdata, -188.726166);
				CreateTimer(5.0, WarpAllBots, posdata);
				WarpTrigger = true;
			}
		}
		
		new fence = FindEntityByName("gateFenceB", -1);
		
		decl Float:pos1[3];
		
		if (fence > 0)
		{
			GetEntityAbsOrigin(fence, pos1);
			if (CheckforBots(pos1, 350.0) && !WarpTriggerTwo)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01I'll just pretend this fence doesn't exist either...\x01");
			
				new Handle:posonedata = CreateDataPack();
				WritePackFloat(posonedata, 2691.872559);
				WritePackFloat(posonedata, -5233.146484);
				WritePackFloat(posonedata, -335.968750);
				CreateTimer(30.0, WarpAllBots, posonedata);
				WarpTriggerTwo = true;
			}
		}
		
		decl Float:pos2[3];
		
		pos2[0] = -15.383742;
		pos2[1] = -4634.599121;
		pos2[2] = 54.753826;
		
		if (CheckforBots(pos2, 400.0) && !WarpTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01A walk in the park...\x01");
			
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -514.125793);
			WritePackFloat(postwodata, -7851.909180);
			WritePackFloat(postwodata, 65.430542);
			CreateTimer(60.0, WarpAllBots, postwodata);
			WarpTriggerThree = true;
		}
		
		decl Float:pos3[3];
		
		pos3[0] = -1131.593750;
		pos3[1] = -7105.576172;
		pos3[2] = 57.446472;
		
		if (CheckforBots(pos3, 400.0) && !WarpTriggerFour)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team moves through the alley...\x01");
			
			new Handle:posthreedata = CreateDataPack();
			WritePackFloat(posthreedata, -2723.947266);
			WritePackFloat(posthreedata, -7346.039063);
			WritePackFloat(posthreedata, 51.546051);
			CreateTimer(10.0, WarpAllBots, posthreedata);
			WarpTriggerFour = true;
		}
	}
	
	if (StrEqual(mapname, "uf4_airfield", true))
	{
		new finaledoor = FindEntityByName("gas_storage_door", -1);
		
		decl Float:posx[3];
		
		if (finaledoor > 0)
		{
			GetEntityAbsOrigin(finaledoor, posx);
			if (CheckforBots(posx, 200.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The door opens...\x01");
				AcceptEntityInput(FindEntityByName("gas_storage_door", -1), "Open");
				MapTrigger = true;
			}
		}
		
		decl Float:pos1[3];
		
		pos1[0] = -234.250000;
		pos1[1] = 561.125000;
		pos1[2] = 26.250000;
		
		if (CheckforBots(pos1, 100.0) && MapTrigger && !WarpTrigger && !WarpTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The fail safe has been activated. Bots will warp to key points to activate objectives in complete order.\x01");
			CreateTimer(60.0, UF4FailSafeOne);
			CreateTimer(75.0, UF4FailSafeTwo);
			CreateTimer(135.0, UF4FailSafeThree);
			CreateTimer(165.0, UF4FailSafeFour);
			WarpTriggerTwo = true;
		}
		
		decl Float:pos2[3];
		
		pos2[0] = -687.250000;
		pos2[1] = 1059.625000;
		pos2[2] = 0.000000;
		
		if (CheckforBots(pos2, 100.0) && MapTrigger && !WarpTrigger && !WarpTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The fail safe has been activated. Bots will warp to key points to activate objectives in complete order.\x01");
			CreateTimer(60.0, UF4FailSafeOne);
			CreateTimer(75.0, UF4FailSafeTwo);
			CreateTimer(135.0, UF4FailSafeThree);
			CreateTimer(165.0, UF4FailSafeFour);
			WarpTriggerTwo = true;
		}
		
		if (EscapeReady && !WarpTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The game/round will end in 30 seconds.\x01");
			CreateTimer(30.0, UFFinish);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_ff01_woods", true))
	{
		decl Float:posx[3];
		
		posx[0] = -4813.489258;
		posx[1] = 2435.072266;
		posx[2] = -23.968750;
		
		if (CheckforBots(posx, 300.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team goes through the warehouse...\x01");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -3140.874756);
			WritePackFloat(posdata, 2651.445801);
			WritePackFloat(posdata, -23.968744);
			CreateTimer(10.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_ff02_factory", true))
	{
		new ffm2button = FindEntityByName("m2_panic_button", -1);
		
		decl Float:posx[3];
		
		if (ffm2button > 0)
		{
			GetEntityAbsOrigin(ffm2button, posx);
			if (CheckforBots(posx, 250.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Someone pushed the button...\x01");
				AcceptEntityInput(FindEntityByName("m2_panic_button", -1), "Press");
				MapTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "l4d2_ff03_highway", true))
	{
		decl Float:posx[3];
		
		posx[0] = 8680.014648;
		posx[1] = 1706.183350;
		posx[2] = -271.365356;
		
		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The elevator starts...\x01");
			AcceptEntityInput(FindEntityByName("m3_panic_button", -1), "Press");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_ff04_plant", true))
	{
		new caboosedoor = FindEntityByName("m4_panicdoor3", -1);
		
		decl Float:posx[3];
		
		if (caboosedoor > 0)
		{
			GetEntityAbsOrigin(caboosedoor, posx);
			if (CheckforBots(posx, 175.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01They gather in the caboose.\x01");
				CreateTimer(0.1, BotsStick);
				
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, -7009.856934);
				WritePackFloat(posdata, 2644.745361);
				WritePackFloat(posdata, -1569.218994);
				CreateTimer(0.2, WarpAllBots, posdata);
				
				CreateTimer(30.0, BotsUnstick);
				AcceptEntityInput(FindEntityByName("m4_panicdoor2", -1), "Close");
				MapTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "l4d2_ff05_station", true))
	{
		new fffinaleprep = FindEntityByName("coop_finale_button1", -1);
		
		decl Float:posx[3];
		
		if (fffinaleprep > 0)
		{
			GetEntityAbsOrigin(fffinaleprep, posx);
			if (CheckforBots(posx, 175.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The train conductor has been contacted...\x01");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "coop_finale_button1", "Use");
				MapTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "p84m3_tunnel", true))
	{
		new p83switch = FindEntityByName("garagepower_btn", -1);
		
		decl Float:posx[3];
		
		if (p83switch > 0)
		{
			GetEntityAbsOrigin(p83switch, posx);
			if (CheckforBots(posx, 500.0) && !MapTrigger)
			{
				AcceptEntityInput(FindEntityByName("garagepower_btn", -1), "Press");
				MapTrigger = true;
			}
		}
	}

	if (StrEqual(mapname, "p84m4_station", true))
	{
		decl Float:posx[3];
		
		posx[0] = -1619.330933;
		posx[1] = 398.351776;
		posx[2] = 294.317841;
		
		if (CheckforBots(posx, 100.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The cop needs their help.\x01");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -2881.040771);
			WritePackFloat(posdata, 165.394073);
			WritePackFloat(posdata, 188.076096);
			CreateTimer(10.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_daybreak01_hotel", true))
	{
		new checkpoint = FindEntityByName("checkpointdoor", -1);
		
		decl Float:pos1[3];
		
		GetEntityAbsOrigin(checkpoint, pos1);

		if (CheckforBots(pos1, 100.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The chapter ends...");
			AcceptEntityInput(checkpoint, "close");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 7145.191);
			WritePackFloat(posdata, 11606.381);
			WritePackFloat(posdata, -762.96875);
			CreateTimer(0.1, WarpAllBots, posdata);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_daybreak02_coastline", true))
	{
		new gascans = FindEntityByName("barricade_gas_can", -1);
		
		if (gascans == -1) // has it been destroyed already? continue without doing anything.
		{
			MapTrigger = true;
		}
			
		decl Float:pos1[3];
		GetEntityAbsOrigin(gascans, pos1);
	
		if (CheckforBots(pos1, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(gascans, "Ignite");
			CreateTimer(0.1, DayBreak03GasCans);
			MapTrigger = true;
		}
		
		new daybreakdoor = FindEntityByName("FortPointDoor1", -1);
		
		decl Float:posx[3];
		
		if (daybreakdoor > 0)
		{
			GetEntityAbsOrigin(daybreakdoor, posx);
			if (CheckforBots(posx, 150.0) && !MapTriggerTwo)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm goes off...");
				
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "FortPointDoor1", "Open");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "FortPointDoor2", "Open");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "fortpointblocker", "UnblockNav");

				MapTriggerTwo = true;
			}
		}
	}
	
	if (StrEqual(mapname, "l4d2_daybreak05_rescue", true))
	{
		new daybreaklock = FindEntityByName("button_lockdoor", -1);
		if (daybreaklock == -1)
		{
			MapTrigger = true;
		}
		decl Float:pos1[3];
		GetEntityAbsOrigin(daybreaklock, pos1);

		if (CheckforBots(pos1, 100.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The finale starts in 10 seconds.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 6299.7275);
			WritePackFloat(posdata, 7256.4473);
			WritePackFloat(posdata, -4591.9688);
			CreateTimer(0.1, WarpAllBots, posdata);
			CreateTimer(0.1, BotsStick);
			CreateTimer(0.5, DayBreak05PreFinale);
			CreateTimer(9.8, DayBreak05Finale);
			CreateTimer(10.0, BotsUnstick);
			MapTrigger = true;
		}
		if ((FinaleHasStarted && !MapTriggerTwo) || (ScavengeRoundStarted && !MapTriggerTwo))
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever1", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever2", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever3", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever4", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever5", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever6", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever7", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever8", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever9", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever10", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever11", "Press");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorlever12", "Press");
			MapTriggerTwo = true;
		}
	}
	if (StrEqual(mapname, "l4d2_wanli01", true))
	{
		new planecheckpoint = FindEntityByName("b_airplane_door_exit", -1);
		
		decl Float:posx[3];
		
		if (planecheckpoint > 0)
		{
			GetEntityAbsOrigin(planecheckpoint, posx);
			if (CheckforBots(posx, 300.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The team has collected all of their parachutes.");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para01A", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para01B", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para01C", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para01D", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para02A", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para02B", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para02C", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para02D", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para03A", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para03B", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para03C", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para03D", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para04A", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para04B", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para04C", "Use");
				UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "b_para04D", "Use");
				MapTrigger = true;
			}
		}
		
		decl Float:pos1[3];
		
		pos1[0] = -161.166092;
		pos1[1] = 1113.764648;
		pos1[2] = -47.968750;
		
		if (CheckforBots(pos1, 100.0) && !MapTriggerTwo)
		{
			AcceptEntityInput(FindEntityByName("b_airplane_door_exit", -1), "Use");
			MapTriggerTwo = true;
		}
	}	
	
	if (StrEqual(mapname, "l4d2_wanli02", true))
	{
		new fireworksbutton = FindEntityByName("fireworks_event_button", -1);
		
		decl Float:posx[3];
		
		if (fireworksbutton > 0)
		{
			GetEntityAbsOrigin(fireworksbutton, posx);
			if (CheckforBots(posx, 300.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01Hey, I wonder what these things do.");
				AcceptEntityInput(fireworksbutton, "Use");
			}
		}
	}
	
	if (StrEqual(mapname, "l4d2_wanli03", true))
	{
		decl Float:posx[3];
		
		posx[0] = -4120.485840;
		posx[1] = 2709.216064;
		posx[2] = 379.552490;

		if (CheckforBots(posx, 1500.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The ice melts... You have 7 minutes...");
			AcceptEntityInput(FindEntityByName("rescueboat_triggerfinale", -1), "ForceFinaleStart");
			CreateTimer(0.1, BotsStick);
			CreateTimer(60.0, IceMelt1);
			CreateTimer(120.0, IceMelt2);
			CreateTimer(180.0, IceMelt3);
			CreateTimer(240.0, IceMelt4);
			CreateTimer(300.0, IceMelt5);
			CreateTimer(360.0, IceMelt6);
			CreateTimer(420.0, IceMelt7);
			CreateTimer(420.1, BotsUnstick);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_roadtonowhere_route02", true))
	{
		new tankdoor = FindEntityByName("tankdoorin_button", -1);
	
		decl Float:pos1[3];
		GetEntityAbsOrigin(tankdoor, pos1);
		
		if (CheckforBots(pos1, 300.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Someone opens the door...");
			AcceptEntityInput(tankdoor, "Press");
			if (!IsVersus())
			{
				CreateTimer(5.0, TankDoor01COOP);
			}
			else if (!IsCoop())
			{
				CreateTimer(5.0, TankDoor01VERSUS);
			}
			MapTrigger = true;
		}

		new tankotherdoor = FindEntityByName("tankdoorout_button", -1);
		
		decl Float:pos2[3];
		GetEntityAbsOrigin(tankotherdoor, pos2);
			
		if (CheckforBots(pos2, 100.0) && !MapTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots move on...");
			AcceptEntityInput(FindEntityByName("tankdoorout_button", -1), "Press");
			CreateTimer(5.0, TankDoor02);
			MapTriggerTwo = true;
		}
	}

	if (StrEqual(mapname, "l4d2_roadtonowhere_route03", true))
	{
		new alarmdoor = FindEntityByName("emergency_door", -1);
		
		decl Float:posx[3];
		GetEntityAbsOrigin(alarmdoor, posx);
		
		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Someone opens the door...");
			if (IsCoop())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm will be disabled in 60 seconds.");
				CreateTimer(60.0, RoadToNoWhereFix);
			}
			if (IsVersus())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm will be disabled in 40 seconds.");
				CreateTimer(60.0, RoadToNoWhereFix);
			}
			else
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm will be disabled in 50 seconds.");
				CreateTimer(50.0, RoadToNoWhereFix);
				MapTrigger = true;
			}
		}
	}
		
	if (StrEqual(mapname, "l4d2_roadtonowhere_route04", true))
	{
		new alarmwindow = FindEntityByName("window_breakglass", -1);
		
		decl Float:posx[3];
		GetEntityAbsOrigin(alarmwindow, posx);
		
		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They break an alarmed window...");
			if (IsCoop())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm will be disabled in 30 seconds.");
				CreateTimer(30.0, RoadToNoWhereFix2);
			}
			if (IsVersus())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The alarm will be disabled in 10 seconds.");
				CreateTimer(10.0, RoadToNoWhereFix2);
			}
		}
	}
	
	if (StrEqual(mapname, "l4d2_roadtonowhere_route05", true))
	{
		decl Float:posx[3];
		posx[0] = -8343.231;
		posx[1] = 10529.924;
		posx[2] = 26.03125;

		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Fail-safe for the vent...");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -8654.613);
			WritePackFloat(posdata, 10918.472);
			WritePackFloat(posdata, 26.03125);
			CreateTimer(20.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "rr_highway1", true))
	{
		decl Float:posx[3];
		posx[0] = 504.38254;
		posx[1] = -293.03943;
		posx[2] = 64.03125;

		if (CheckforBots(posx, 200.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01A blown out bridge... Wait, why are we traveling by truck if that's the case?");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -1744.6862);
			WritePackFloat(posdata, 1461.7263);
			WritePackFloat(posdata, -525.11285);
			CreateTimer(20.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_stadium1_apartment", true))
	{	
		decl Float:pos1[3];
		pos1[0] = 340.527100;
		pos1[1] = 520.226379;
		pos1[2] = -2130.968750;
		
		if (CheckforBots(pos1, 500.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They must get the power back on...");
			CreateTimer(0.1, BotsStick);
			CreateTimer(60.0, SuicideBlitz2PowerSwitch);
			CreateTimer(75.0, SuicideBlitz2ReturnToElevator);
			MapTrigger = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = 342.217285;
		pos2[1] = 508.724915;
		pos2[2] = -3743.968750;
		
		if (CheckforBots(pos2, 300.0) && !MapTriggerTwo)
		{
			CreateTimer(0.1, BotsUnstick);
			MapTriggerTwo = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_stadium2_riverwalk", true))
	{
		decl Float:posx[3];
		posx[0] = 2213.667725;
		posx[1] = 6103.937988;
		posx[2] = -129.337051;
		
		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Someone shoots the gas can...");
			CreateTimer(10.0, SuicideBlitz2Gascan);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_stadium3_city1", true))
	{
		new sbprisonbutton = FindEntityByName("button_model", -1);
		
		decl Float:posx[3];
		GetEntityAbsOrigin(sbprisonbutton, posx);
		
		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The alarm has been disabled.");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "alarm_off_relay", "trigger");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_stadium4_city2", true))
	{
		decl Float:posx[3];
		posx[0] = -5330.817871;
		posx[1] = 5056.894531;
		posx[2] = -10.968750;
		
		if (CheckforBots(posx, 300.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The team crosses the plank... (60 seconds)");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -5803.865234);
			WritePackFloat(posdata, 5366.454590);
			WritePackFloat(posdata, 397.031250);
			CreateTimer(60.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_stadium5_stadium", true))
	{
		new sbradio = FindEntityByName("radio_btn", -1);
		
		decl Float:posx[3];
		GetEntityAbsOrigin(sbradio, posx);
		
		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They call for help...");
			AcceptEntityInput(FindEntityByName("radio_btn", -1), "Press");
			CreateTimer(0.1, BotsStick);
			CreateTimer(60.0, SuicideBlitz2FinaleRelay);
			CreateTimer(60.0, BotsUnstick);
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 6532.612793);
			WritePackFloat(posonedata, -4401.844238);
			WritePackFloat(posonedata, 443.843048);
			CreateTimer(61.0, WarpAllBots, posonedata);
			
			MapTrigger = true;
		}
		
		decl Float:pos1[3];
		pos1[0] = 8031.500000;
		pos1[1] = -4761.375000;
		pos1[2] = -12.000000;
		
		if (CheckforBots(pos1, 250.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01A fail-safe has been activated.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 7245.513672);
			WritePackFloat(posdata, -5023.473633);
			WritePackFloat(posdata, 152.031250);
			CreateTimer(10.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_7hours_later_01", true))
	{
		new SevenHours01 = FindEntityByName("checkpoint_entrance", -1);
		
		decl Float:posx[3];
		
		GetEntityAbsOrigin(SevenHours01, posx);
		
		if (CheckforBots(posx, 250.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The chapter ends...");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 8869.981);
			WritePackFloat(posdata, -3636.1667);
			WritePackFloat(posdata, 501.03262);
			CreateTimer(3.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_7hours_later_02", true))
	{
		new gascans = FindEntityByName("barricade_gas_can", -1);
		
		if (gascans == -1) // has it been destroyed already? continue without doing anything.
		{
			MapTrigger = true;
		}
			
		decl Float:pos1[3];
		GetEntityAbsOrigin(gascans, pos1);
	
		if (CheckforBots(pos1, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(gascans, "Ignite");
			MapTrigger = true;
		}
	}
		
	if (StrEqual(mapname, "l4d2_7hours_later_03", true))
	{
		decl Float:posx[3];
		posx[0] = 5127.115234;
		posx[1] = 2471.270752;
		posx[2] = -1004.028931;
		
		if (CheckforBots(posx, 2000.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots move on...");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 4152.597168);
			WritePackFloat(posdata, -1624.366943);
			WritePackFloat(posdata, -1057.730225);
			CreateTimer(45.0, WarpAllBots, posdata);
			
			CreateTimer(0.1, BotsStick);
			CreateTimer(45.0, BotsUnstick);
			
			WarpTrigger = true;
		}
		
		new bunkerdoor1 = FindEntityByName("level_end_entrance", -1);
		
		decl Float:pos1[3];
		GetEntityAbsOrigin(bunkerdoor1, pos1);
	
		if (CheckforBots(pos1, 500.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The generator starts, and the doors open.");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "generator_relay", "trigger");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "generator_soundscape_relay", "trigger");
			AcceptEntityInput(bunkerdoor1, "Open");
			CreateTimer(0.1, BotsStick);
			CreateTimer(45.0, BotsUnstick);
			MapTrigger = true;
		}
	}

	if (StrEqual(mapname, "l4d2_7hours_later_05", true))
	{
		new button = FindEntityByName("radio_fake_button", -1);
		
		if ((button == -1) && !MapTrigger && !FinaleHasStarted)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Preparing to fuel the plane...");
			CreateTimer(20.0, C11M5FinaleStart);
			MapTrigger = true;
		}
		
		decl Float:pos1[3];
		GetEntityAbsOrigin(button, pos1);

		if (CheckforBots(pos1, 500.0) && !MapTrigger && !FinaleHasStarted)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio_fake_button", "Press");
			PrintToChatAll("\x04[AutoTrigger] \x01Preparing to fuel the plane...");
			CreateTimer(20.0, C11M5FinaleStart);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "dm1_suburbs", true))
	{
		decl Float:posx[3];
		posx[0] = -2910.7952;
		posx[1] = 1376.5933;
		posx[2] = -11.96875;

		if (CheckforBots(posx, 100.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01A fail-safe has been activated.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -2522.4868);
			WritePackFloat(posdata, 2022.8943);
			WritePackFloat(posdata, 71.81948);
			CreateTimer(5.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "dm4_caves", true))
	{
		new gascans = FindEntityByName("barricade_gas_can", -1);
		
		if (gascans == -1) // has it been destroyed already? continue without doing anything.
		{
			MapTrigger = true;
		}
			
		decl Float:pos1[3];
		GetEntityAbsOrigin(gascans, pos1);
	
		if (CheckforBots(pos1, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(gascans, "Ignite");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "dm5_summit", true))
	{
		new dmradio = FindEntityByName("radio", -1);
		
		decl Float:pos1[3];
		GetEntityAbsOrigin(dmradio, pos1);
		
		if (CheckforBots(pos1, 500.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The Finale will start in one minute.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 2540.635254);
			WritePackFloat(posdata, 1328.842407);
			WritePackFloat(posdata, 368.031250);
			CreateTimer(60.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
	}	
	
	if (StrEqual(mapname, "dprm5_milltown_escape", true))
	{
		decl Float:posx[3];
		posx[0] = -5800.668945;
		posx[1] = 5730.528320;
		posx[2] = 100.031250;
		
		if (CheckforBots(posx, 125.0) && !MapTrigger && !FinaleHasStarted)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The Finale will start in thirty seconds.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -5799.499023);
			WritePackFloat(posdata, 7438.325195);
			WritePackFloat(posdata, 292.031250);
			CreateTimer(30.0, WarpAllBots, posdata);
			
			MapTrigger = true;
		}
	}	
	
	if (StrEqual(mapname, "l4d_yama_2", true))
	{
		decl Float:posx[3];
		posx[0] = -1009.031250;
		posx[1] = -10721.271484;
		posx[2] = -735.968750;
		
		if (CheckforBots(posx, 250.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots move through the building.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -798.257385);
			WritePackFloat(posdata, -10645.315430);
			WritePackFloat(posdata, -735.968750);
			CreateTimer(1.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
	}
	if (StrEqual(mapname, "l4d_yama_3", true))
	{
		decl Float:posx[3];
		posx[0] = 6009.167480;
		posx[1] = 9188.841797;
		posx[2] = 1721.531250;
		
		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The tram is on its way.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 5950.164551);
			WritePackFloat(posdata, 9178.969727);
			WritePackFloat(posdata, 1721.531250);
			CreateTimer(31.0, WarpAllBots, posdata);
			
			CreateTimer(0.1, Yama3TramTrigger);
			CreateTimer(0.1, BotsStick);
			CreateTimer(31.0, BotsStopMove);
			CreateTimer(31.5, Yama3Tram2Trigger);
			CreateTimer(60.0, BotsUnstick);
			CreateTimer(60.0, BotsStartMove);
			
			MapTrigger = true;
		}
		
		new Yama3Generator = FindEntityByName("generator_button", -1);
		
		decl Float:pos2[3];
		GetEntityAbsOrigin(Yama3Generator, pos2);
		
		if (CheckforBots(pos2, 500.0) && !MapTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Someone restores the power...");
			CreateTimer(0.1, BotsStick);
			AcceptEntityInput(Yama3Generator, "Press");
			CreateTimer(12.0, Yama3GeneratorEvent);
			CreateTimer(12.0, BotsUnstick);
			
			MapTriggerThree = true;
		}
		
		//if (IsCoop() || IsSurvival())
		//{
		//	MapTriggerTwo = true;
		//}
		
		//if (IsVersus() && !MapTriggerTwo)
		//{
		//	if (IsM12() && !MapTriggerTwo)
		//	{
		//	}
		//}
	}
	
	if (StrEqual(mapname, "l4d_yama_4", true))
	{
		decl Float:posx[3];
		posx[0] = 2778.998291;
		posx[1] = 6105.070313;
		posx[2] = -1503.468750;
		
		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The tram takes off...");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 2778.998291);
			WritePackFloat(posdata, 6105.070313);
			WritePackFloat(posdata, -1503.468750);
			CreateTimer(1.0, WarpAllBots, posdata);
			
			CreateTimer(1.1, Yama3Tram2Trigger);
			CreateTimer(1.1, BotsStick);
			CreateTimer(1.1, BotsStopMove);
			CreateTimer(30.0, BotsStartMove);
			CreateTimer(30.0, BotsUnstick);
			
			MapTrigger = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = -5532.913086;
		pos2[1] = -7339.814941;
		pos2[2] = 472.031250;
		
		if (CheckforBots(pos2, 250.0) && !MapTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They quickly move on.");
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -5594.154785);
			WritePackFloat(posonedata, -7937.647461);
			WritePackFloat(posonedata, 464.031250);
			CreateTimer(5.0, WarpAllBots, posonedata);
			
			MapTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "l4d_yama_5", true))
	{
		decl Float:posx[3];
		posx[0] = -115.434006;
		posx[1] = -1065.479736;
		posx[2] = -127.968750;
		
		if (CheckforBots(posx, 100.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The finale will start in 10 seconds.");
			CreateTimer(10.0, YamaFinale);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "cbm2_town", true))
	{
		decl Float:posx[3];
		posx[0] = 2307.6592;
		posx[1] = 3347.5374;
		posx[2] = -7.968752;

		if (CheckforBots(posx, 200.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The church bells will be disabled in 45 seconds.");
			
			new Handle:posonedata = CreateDataPack();
			
			WritePackFloat(posonedata, 3355.4392);
			WritePackFloat(posonedata, 3102.8496);
			WritePackFloat(posonedata, 176.03125);
			CreateTimer(45.0, WarpAllBots, posonedata);
			CreateTimer(45.1, BloodProofPanicButton);
			
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "cbm3_bunker", true))
	{
		new BloodProofTrain = FindEntityByName("finale_trigger", -1);
		if (BloodProofTrain == -1)
		{
			MapTrigger = true;
		}
		decl Float:posx[3];
		GetEntityAbsOrigin(BloodProofTrain, posx);

		if (CheckforBots(posx, 500.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The finale will begin in 10 seconds.");
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -5181.362);
			WritePackFloat(posonedata, -1947.4912);
			WritePackFloat(posonedata, 35.005466);
			CreateTimer(15.0, WarpAllBots, posonedata);
			CreateTimer(10.0, BloodProofFinale);
			MapTrigger = true;
		}
		
		new BloodProofElevator = FindEntityByName("elevator_button", -1);
		if (BloodProofElevator == -1)
		{
			WarpTrigger = true;
		}
		decl Float:pos1[3];
		GetEntityAbsOrigin(BloodProofElevator, pos1);

		if (CheckforBots(pos1, 500.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The elevator is out of power...");
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, 943.2632);
			WritePackFloat(postwodata, 12350.609);
			WritePackFloat(postwodata, 384.03125);
			CreateTimer(10.0, WarpAllBots, postwodata);
			CreateTimer(10.1, BloodProofGenerator);
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "bloodtracks_01", true))
	{
		new BloodTrackButton1 = FindEntityByName("firstbutton", -1);
		if (BloodTrackButton1 == -1)
		{
			MapTrigger = true;
		}
		decl Float:posx[3];
		GetEntityAbsOrigin(BloodTrackButton1, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			AcceptEntityInput(BloodTrackButton1, "Press");
			PrintToChatAll("\x04[AutoTrigger] \x01The crane has been activated.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -514.9055);
			WritePackFloat(posdata, 4941.2227);
			WritePackFloat(posdata, 330.94687);
			CreateTimer(30.0, WarpAllBots, posdata);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "bloodtracks_02", true))
	{
		decl Float:posx[3];
		posx[0] = 873.7083;
		posx[1] = -6259.8574;
		posx[2] = -1818.1196;

		if (CheckforBots(posx, 1000.0) && !MapTrigger)
		{
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 873.7083);
			WritePackFloat(posonedata, -6259.8574);
			WritePackFloat(posonedata, -1818.1196);
			CreateTimer(15.0, WarpAllBots, posonedata);
			CreateTimer(30.0, BloodTracksBoomMessage);
			CreateTimer(31.0, BotsStartMove);
			MapTrigger = true;
		}
		decl Float:pos1[3];
		pos1[0] = 873.7083;
		pos1[1] = -6259.8574;
		pos1[2] = -1818.1196;

		if (CheckforBots(pos1, 250.0) && !MapTriggerTwo)
		{
			CreateTimer(0.1, BotsStopMove);
			MapTriggerTwo = true;
		}
		decl Float:pos2[3];
		pos2[0] = 881.3888;
		pos2[1] = -6815.616;
		pos2[2] = -1818.1196;

		if (CheckforBots(pos2, 200.0) && !WarpTrigger)
		{
			if (!IsVersus())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The bots move too slowly in an infinite horde. They will warp to the end saferoom in 3 minutes..");
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, -514.9055);
				WritePackFloat(posdata, 4941.2227);
				WritePackFloat(posdata, 330.94687);
				CreateTimer(180.0, WarpAllBots, posdata);
				WarpTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "bloodtracks_03", true))
	{
		new BloodTrackDoor = FindEntityByName("pushdoor", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(BloodTrackDoor, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "doorrelay", "Trigger");
			MapTrigger = true;
		}
		new BloodTracksScavengeBypass = FindEntityByName("notscavengebrush", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(BloodTracksScavengeBypass, pos1);

		if (CheckforBots(pos1, 200.0) && !WarpTrigger)
		{
			if (!IsVersus() && !IsM12() && !IsScavenge())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01A brush is in the way. Warping bots ahead in 45 seconds.");
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, 2101.17);
				WritePackFloat(posdata, -3847.6663);
				WritePackFloat(posdata, -2791.9688);
				CreateTimer(45.0, WarpAllBots, posdata);
				WarpTrigger = true;
			}
			
			if (!IsCoop() && !IsSurvival())
			{
				PrintToChatAll("\x04[AutoTrigger] \x01A brush is in the way. Warping bots ahead in 20 seconds.");
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, 2101.17);
				WritePackFloat(posdata, -3847.6663);
				WritePackFloat(posdata, -2791.9688);
				CreateTimer(20.0, WarpAllBots, posdata);
				WarpTrigger = true;
			}
			else
			{
				PrintToChatAll("\x04[AutoTrigger] \x01A brush is in the way. Warping bots ahead in 30 seconds.");
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, 2101.17);
				WritePackFloat(posdata, -3847.6663);
				WritePackFloat(posdata, -2791.9688);
				CreateTimer(30.0, WarpAllBots, posdata);
				WarpTrigger = true;
			}
		}
	}
	
	if (StrEqual(mapname, "bloodtracks_04", true))
	{
		new BloodTrackRadio = FindEntityByName("radio", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(BloodTrackRadio, posx);

		if (CheckforBots(posx, 200.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio", "ForceFinaleStart");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "msd1_town", true))
	{
		new FCShelf = FindEntityByName("mt_bshelf_mbtt", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(FCShelf, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			CreateTimer(10.0, FarewellChenming1Intro1);
			CreateTimer(15.0, FarewellChenming1Intro2);
			PrintToChatAll("\x04[AutoTrigger] \x01The bots prepare to move out.");
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -9055.649);
			WritePackFloat(posdata, 1775.881);
			WritePackFloat(posdata, -14994.789);
			CreateTimer(20.0, WarpAllBots, posdata);
			MapTrigger = true;
		}
		
		decl Float:pos1[3];
		pos1[0] = 881.3888;
		pos1[1] = -6815.616;
		pos1[2] = -1818.1196;
		
		if (CheckforBots(pos1, 600.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They investigate the map...");
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 881.3888);
			WritePackFloat(posonedata, -6815.616);
			WritePackFloat(posonedata, -1818.1196);
			CreateTimer(5.0, WarpAllBots, posonedata);
			WarpTrigger = true;
		}
		
		new FCBarricade = FindEntityByName("mt_suiji2_bb2", -1);
		decl Float:pos2[3];
		GetEntityAbsOrigin(FCBarricade, pos2);

		if (CheckforBots(pos2, 300.0) && !WarpTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Fail-safe for the barricade.");
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -5336.3423);
			WritePackFloat(postwodata, -2583.5493);
			WritePackFloat(postwodata, -14987.969);
			CreateTimer(5.0, WarpAllBots, postwodata);
			WarpTriggerTwo = true;
		}
		
		new FCC4 = FindEntityByName("mt_c4_fangzhi", -1);
		decl Float:pos3[3];
		GetEntityAbsOrigin(FCC4, pos3);

		if (CheckforBots(pos3, 400.0) && !MapTriggerTwo)
		{
			CreateTimer(0.1, BotsStopMove);
			CreateTimer(5.0, FarewellChenming1C4);
			CreateTimer(10.0, BotsStartMove);
			MapTriggerTwo = true;
		}
		
		new FCTrainDoor = FindEntityByName("mt_rtrain_dbtt", -1);
		decl Float:pos4[3];
		GetEntityAbsOrigin(FCTrainDoor, pos4);

		if (CheckforBots(pos4, 300.0) && !MapTriggerThree)
		{
			CreateTimer(0.1, BotsStick);
			CreateTimer(5.0, FarewellChenming1TrainDoor);
			CreateTimer(5.1, BotsUnstick);
			
			new Handle:posfourthdata = CreateDataPack();
			WritePackFloat(posfourthdata, -1458.5002);
			WritePackFloat(posfourthdata, -2783.1628);
			WritePackFloat(posfourthdata, -14928.292);
			CreateTimer(7.0, WarpAllBots, posfourthdata);
			MapTriggerThree = true;
		}
		
		decl Float:pos5[3];
		pos5[0] = 2244.5063;
		pos5[1] = -2708.7224;
		pos5[2] = -14917.969;

		if (CheckforBots(pos5, 2000.0) && !WarpTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The chapter will end in 15 seconds.");
			
			new Handle:posthreedata = CreateDataPack();
			WritePackFloat(posthreedata, 2244.5063);
			WritePackFloat(posthreedata, -2708.7224);
			WritePackFloat(posthreedata, -14917.969);
			CreateTimer(15.0, WarpAllBots, posthreedata);
			
			new Handle:posfifthdata = CreateDataPack();
			WritePackFloat(posfifthdata, 1670.6831);
			WritePackFloat(posfifthdata, -2467.672);
			WritePackFloat(posfifthdata, -14925.969);
			CreateTimer(14.0, WarpAllBots, posfifthdata);
			
			CreateTimer(0.1, BotsStick);
			CreateTimer(15.1, BotsUnstick);
			WarpTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "msd2_gasstation", true))
	{
		new FCProgress = -1;
		while ((FCProgress = FindEntityByClassname(FCProgress, "game_scavenge_progress_display")) != -1)
		{
			if (GetEntProp(FCProgress, Prop_Send, "m_bActive", 1))
			{
				return Plugin_Continue;
			}
			if (!MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The bots will start collecting cans in 10 seconds.");
				
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, -5299.5776);
				WritePackFloat(posdata, -611.5952);
				WritePackFloat(posdata, 9373.031);
				CreateTimer(10.0, WarpAllBots, posdata);
				MapTrigger = true;
			}
		}
		
		decl Float:pos1[3];
		pos1[0] = -6930.7393;
		pos1[1] = -2501.1003;
		pos1[2] = 9357.7;
		if (CheckforBots(pos1, 600.0))
		{
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -6392.6313);
			WritePackFloat(posonedata, -903.43494);
			WritePackFloat(posonedata, 9356.031);
			CreateTimer(0.1, WarpAllBots, posonedata);
		}
	}
	
	if (StrEqual(mapname, "msdnew_tccity_newway", true))
	{
		decl Float:pos1[3];
		pos1[0] = -1463.2125;
		pos1[1] = -1668.0717;
		pos1[2] = -644.96875;
		
		if (CheckforBots(pos1, 600.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They must find the key...");
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -67.46766);
			WritePackFloat(posonedata, -2535.5662);
			WritePackFloat(posonedata, -529.5105);
			CreateTimer(15.0, WarpAllBots, posonedata);
			CreateTimer(15.1, FareWellChenming3Key);
			CreateTimer(0.1, BotsStick);
			CreateTimer(180.0, BotsUnstick);
			CreateTimer(30.0, FareWellChenming3Door);
			
			new Handle:posfourthdata = CreateDataPack();
			WritePackFloat(posfourthdata, -1416.718);
			WritePackFloat(posfourthdata, -942.2169);
			WritePackFloat(posfourthdata, -644.96875);
			CreateTimer(35.0, WarpAllBots, posfourthdata);
			
			new Handle:posthreedata = CreateDataPack();
			WritePackFloat(posthreedata, -1416.718);
			WritePackFloat(posthreedata, -942.2169);
			WritePackFloat(posthreedata, -644.96875);
			CreateTimer(179.0, WarpAllBots, posthreedata);
			MapTrigger = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = 5113.601;
		pos2[1] = 3075.1455;
		pos2[2] = -957.85315;

		if (CheckforBots(pos2, 300.0) && !MapTriggerTwo)
		{
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, 5113.601);
			WritePackFloat(postwodata, 3075.1455);
			WritePackFloat(postwodata, -957.85315);
			CreateTimer(0.1, WarpAllBots, postwodata);
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "ccm_xfm_closebtt", "Press");
			CreateTimer(7.0, FareWellChenming3Button);
			CreateTimer(0.1, BotsStick);
			MapTriggerTwo = true;
		}
		
		decl Float:pos3[3];
		pos3[0] = 5537.5244;
		pos3[1] = 3830.3096;
		pos3[2] = -895.27094;

		if (CheckforBots(pos3, 300.0) && !MapTriggerThree)
		{
			CreateTimer(150.0, BotsUnstick);
			MapTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_city17_02", true))
	{
		new C17Door = FindEntityByName("emergency_door", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(C17Door, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "emergency_door", "Open");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_city17_03", true))
	{
		new C17gascans = FindEntityByName("barricade_gas_can", -1);
		if (C17gascans == -1)
		{
			MapTrigger = true;
		}
		
		decl Float:posx[3];
		GetEntityAbsOrigin(C17gascans, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(C17gascans, "Ignite");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "c14m2_campground", true))
	{
		new DamItLogs = FindEntityByName("player_blocker_logs", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(DamItLogs, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The logs will move in 30 seconds.");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 1377.314);
			WritePackFloat(posdata, -7991.3955);
			WritePackFloat(posdata, 1220.0874);
			CreateTimer(30.0, WarpAllBots, posdata);
			CreateTimer(0.1, BotsStick);
			CreateTimer(31.0, BotsUnstick);
			CreateTimer(30.1, DamItButton);
			
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "c14m3_dam", true))
	{
		new DamItgascans = FindEntityByName("barricade_gas_can", -1);
		if (DamItgascans == -1)
		{
			MapTrigger = true;
		}
		
		decl Float:posx[3];
		GetEntityAbsOrigin(DamItgascans, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(DamItgascans, "Ignite");
			MapTrigger = true;
		}
		
		new DamItDoorButton = FindEntityByName("door_button", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(DamItDoorButton, pos1);

		if (CheckforBots(pos1, 900.0) && !MapTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They make a run for it...");
			AcceptEntityInput(DamItDoorButton, "Press");
			MapTriggerTwo = true;
		}
		
		new DamItGate = FindEntityByName("gate4", -1);
		decl Float:pos2[3];
		GetEntityAbsOrigin(DamItGate, pos2);

		if (CheckforBots(pos2, 300.0) && !MapTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Standby for the gate.");
			CreateTimer(0.1, BotsStick);
			MapTriggerThree = true;
		}
		
		new DamItElevator = FindEntityByName("elevator02", -1);
		decl Float:pos3[3];
		GetEntityAbsOrigin(DamItElevator, pos3);

		if (CheckforBots(pos3, 200.0) && !MapTriggerFourth)
		{
			CreateTimer(0.1, BotsUnstick);
			MapTriggerFourth = true;
		}
		
		new DamItElevator02 = FindEntityByName("elevator", -1);
		decl Float:pos4[3];
		GetEntityAbsOrigin(DamItElevator02, pos4);

		if (CheckforBots(pos4, 200.0) && !WarpTrigger)
		{
			CreateTimer(0.1, BotsStopMove);
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -1255.8767);
			WritePackFloat(posdata, -4854.0864);
			WritePackFloat(posdata, 1708.191);
			CreateTimer(3.0, WarpAllBots, posdata);
			CreateTimer(4.0, DamItElevator2);
			WarpTrigger = true;
		}
		
		decl Float:pos5[3];
		pos5[0] = -1262.7723;
		pos5[1] = -4856.5737;
		pos5[2] = 2432.0312;
		
		decl Float:pos6[3];
		pos6[0] = -1262.7723;
		pos6[1] = -4856.5737;
		pos6[2] = 2432.0312;

		if ((CheckforBots(pos5, 200.0) && !WarpTriggerTwo) || (CheckforBots(pos6, 200.0) && !WarpTriggerTwo))
		{
			CreateTimer(0.1, BotsStartMove);
			CreateTimer(0.2, BotsStick);
			
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -1028.9502);
			WritePackFloat(postwodata, -6265.917);
			WritePackFloat(postwodata, 2496.887);
			CreateTimer(15.0, WarpAllBots, postwodata);
			CreateTimer(15.1, BotsUnstick);
			WarpTriggerTwo = true;
		}

		if (FinaleHasStarted && !WarpTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The round/game will end in 90 seconds.");
			new Handle:posthreedata = CreateDataPack();
			WritePackFloat(posthreedata, 5891.305);
			WritePackFloat(posthreedata, -2273.051);
			WritePackFloat(posthreedata, 1206.3392);
			CreateTimer(90.0, WarpAllBots, posthreedata);
			WarpTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "dkr_m5_stadium", true))
	{
		decl Float:posx[3];
		posx[0] = 432.44824;
		posx[1] = 4631.059;
		posx[2] = -269.32016;

		if (CheckforBots(posx, 500.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Lights...");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "stage_lights_button", "Use");
			MapTrigger = true;
		}

		if (FinaleHasStarted && !MapTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Enjoy the show...");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -422.2746);
			WritePackFloat(posdata, 960.26495);
			WritePackFloat(posdata, 0.03125);
			CreateTimer(14.5, WarpAllBots, posdata);
			CreateTimer(15.0, DKRFireworks1);
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -420.49805);
			WritePackFloat(posonedata, 3795.1475);
			WritePackFloat(posonedata, 0.03125);
			CreateTimer(29.5, WarpAllBots, posonedata);
			CreateTimer(30.0, DKRFireworks2);
			
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, 918.40796);
			WritePackFloat(postwodata, 2386.9297);
			WritePackFloat(postwodata, -286.82074);
			CreateTimer(44.5, WarpAllBots, postwodata);
			CreateTimer(45.0, DKRFlashPots);
			
			new Handle:posthreedata = CreateDataPack();
			WritePackFloat(posthreedata, -761.8109);
			WritePackFloat(posthreedata, 2393.7964);
			WritePackFloat(posthreedata, 0.03125);
			CreateTimer(59.5, WarpAllBots, posthreedata);
			CreateTimer(60.0, DKRSpotLights);
			CreateTimer(75.0, DKRFinaleTank1);
			
			MapTriggerTwo = true;
		}

		if (FinaleHasStarted && ConfirmFinaleTank1Death && MapTriggerTwo && !MapTriggerThree)
		{
			CreateTimer(15.0, DKRFinalePhase2);
			
			new Handle:posfourdata = CreateDataPack();
			WritePackFloat(posfourdata, 378.65445);
			WritePackFloat(posfourdata, 1723.3558);
			WritePackFloat(posfourdata, -377.96875);
			CreateTimer(44.5, WarpAllBots, posfourdata);
			CreateTimer(45.0, DKRSpeakers);
			
			new Handle:posfivedata = CreateDataPack();
			WritePackFloat(posfivedata, 54.758644);
			WritePackFloat(posfivedata, 4131.7393);
			WritePackFloat(posfivedata, 0.03125);
			CreateTimer(59.5, WarpAllBots, posfivedata);
			CreateTimer(60.0, DKRScavenge);
			CreateTimer(240.0, DKRScavengeBypass);
			
			new Handle:possevendata = CreateDataPack();
			WritePackFloat(possevendata, 1397.6992);
			WritePackFloat(possevendata, 4068.0261);
			WritePackFloat(possevendata, -377.96875);
			CreateTimer(269.5, WarpAllBots, possevendata);
			CreateTimer(270.0, DKRGate1);
			
			new Handle:poseightdata = CreateDataPack();
			WritePackFloat(poseightdata, 2009.3824);
			WritePackFloat(poseightdata, 3919.076);
			WritePackFloat(poseightdata, -377.96875);
			CreateTimer(289.5, WarpAllBots, poseightdata);
			CreateTimer(290.0, DKRFireworksCluster3);
			CreateTimer(299.9, BotsStopMove);
			CreateTimer(300.0, DKRMic);
			
			new Handle:posninedata = CreateDataPack();
			WritePackFloat(posninedata, 918.40796);
			WritePackFloat(posninedata, 2386.9297);
			WritePackFloat(posninedata, 0.03125);
			CreateTimer(300.1, WarpAllBots, posninedata);
			CreateTimer(300.2, DKRMicGuarantee);
			CreateTimer(312.0, BotsStartMove);
			CreateTimer(312.1, DKRDisableMic);
			
			MapTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_deadcity01_riverside", true))
	{
		decl Float:posx[3];
		posx[0] = -2174.2773;
		posx[1] = -588.87006;
		posx[2] = -58.899265;

		if (CheckforBots(posx, 150.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Warping bots to the elevator to prevent shortcuts.");
			CreateTimer(15.0, DCII1Elevator);
			MapTrigger = true;
		}
		
		decl Float:pos1[3];
		pos1[0] = -2701.326;
		pos1[1] = -375.22253;
		pos1[2] = -183.96875;

		if (CheckforBots(pos1, 150.0) && !MapTrigger)
		{
			CreateTimer(0.1, BotsStopMove);
			CreateTimer(10.0, BotsStartMove);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_deadcity04_outpost", true))
	{
		new DCIIScvPrep = FindEntityByName("trigger_finale_btn", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(DCIIScvPrep, posx);

		if (CheckforBots(posx, 500.0) && !MapTrigger && !FinaleHasStarted)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The... 'finale' will begin in 20.");
			AcceptEntityInput(DCIIScvPrep, "Use");
			CreateTimer(20.0, DCIIScavengeEvent);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_deadcity05_plant", true))
	{
		decl Float:posx[3];
		posx[0] = 4744.4077;
		posx[1] = 10387.633;
		posx[2] = 424.03125;

		if (CheckforBots(posx, 200.0) && !MapTrigger)
		{
			CreateTimer(0.1, BotsStopMove);
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, posx[0]);
			WritePackFloat(posdata, posx[1]);
			WritePackFloat(posdata, posx[2]);
			CreateTimer(0.2, WarpAllBots, posdata);
			CreateTimer(0.3, RunBusStationEvent);
			CreateTimer(10.0, BotsStartMove);
			
			MapTrigger = true;
		}
	}
	if (StrEqual(mapname, "deathrow02_outskirts", true))
	{
		new DRDoor = FindEntityByName("Emergency_Exit_Door", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(DRDoor, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			AcceptEntityInput(DRDoor, "Open");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "cdta_02road", true))
	{
		new CDTAAlarm = FindEntityByName("gbutton", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(CDTAAlarm, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -7492.749);
			WritePackFloat(posdata, -6518.827);
			WritePackFloat(posdata, 431.99423);
			CreateTimer(30.0, WarpAllBots, posdata);
			
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "cdta_04onarail", true))
	{
		decl Float:posx[3];
		posx[0] = -1043.982;
		posx[1] = 3621.3691;
		posx[2] = 917.03125;

		if (CheckforBots(posx, 150.0) && !MapTrigger)
		{
			CreateTimer(0.1, BotsStopMove);
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -1504.7284);
			WritePackFloat(posdata, 3641.996);
			WritePackFloat(posdata, 973.63727);
			CreateTimer(3.0, WarpAllBots, posdata);
			CreateTimer(140.0, BotsStartMove);
			CreateTimer(140.1, CDTA04Train);
		}
	}
	
	if (StrEqual(mapname, "cdta_05finalroad", true))
	{
		if (!FinaleHasStarted)
		{
			SetConVarInt(FindConVar("sb_unstick"), 0);
		}
		else
		{
			SetConVarInt(FindConVar("sb_unstick"), 1);
		}
		
		new DAGasPump = FindEntityByName("fueltruck-button", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(DAGasPump, posx);

		if (CheckforBots(posx, 1000.0) && !MapTrigger && IsCoop())
		{
			CreateTimer(30.0, DAGasLever);
			PrintToChatAll("\x04[AutoTrigger] \x01Bots will collect the gas for the pilot in 30 seconds. And will return in 2 minutes after that.");
			
			new Handle:posxdata = CreateDataPack();
			WritePackFloat(posxdata, 212.18498);
			WritePackFloat(posxdata, -1118.3547);
			WritePackFloat(posxdata, 883.8139);
			CreateTimer(29.5, WarpAllBots, posxdata);
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -7792.7573);
			WritePackFloat(posdata, -7914.6284);
			WritePackFloat(posdata, 919.5485);
			CreateTimer(90.0, WarpAllBots, posdata);
			
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -8449.011);
			WritePackFloat(postwodata, -11884.115);
			WritePackFloat(postwodata, 855.9715);
			CreateTimer(150.0, WarpAllBots, postwodata);
			
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_diescraper1_apartment_361", true))
	{
		decl Float:posx[3];
		posx[0] = 10658.119;
		posx[1] = 7388.1016;
		posx[2] = 353.43677;

		if (CheckforBots(posx, 100.0) && !WarpTrigger)
		{
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 10643.413);
			WritePackFloat(posdata, 7374.211);
			WritePackFloat(posdata, 38.501827);
			CreateTimer(5.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_diescraper3_mid_361", true))
	{
		decl Float:posx[3];
		posx[0] = -428.14487;
		posx[1] = -596.2446;
		posx[2] = -1999.9688;

		if (CheckforBots(posx, 300.0) && !WarpTrigger)
		{
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 614.0295);
			WritePackFloat(posdata, -413.7362);
			WritePackFloat(posdata, -1999.9688);
			CreateTimer(30.0, WarpAllBots, posdata);
			WarpTrigger = true;
		}
		
		decl Float:pos1[3];
		pos1[0] = -428.14487;
		pos1[1] = -596.2446;
		pos1[2] = -1999.9688;

		if (CheckforBots(pos1, 300.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "generator_lever_button", "Use");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "store_shutter_nav", "UnblockNav");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_diescraper4_top_361", true))
	{
		new DSFinale = FindEntityByName("finale_radio", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(DSFinale, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "finale_radio", "ForceFinaleStart");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "ft_m5_finale", true))
	{
		decl Float:posx[3];
		posx[0] = 7052.859;
		posx[1] = 9295.024;
		posx[2] = 5760.0312;

		if (CheckforBots(posx, 300.0) && !WarpTrigger)
		{
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 7293.286);
			WritePackFloat(posdata, 9309.878);
			WritePackFloat(posdata, 5920.0312);
			CreateTimer(10.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_ahs_mallarea_vs", true))
	{
		new Finals = FindEntityByName("radio", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(Finals, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger && !FinaleHasStarted)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio", "ForceFinaleStart");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "splash1", true))
	{
		new splash1button = FindEntityByName("cres_button", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(splash1button, posx);

		if (CheckforBots(posx, 700.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "cres_button", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "splash3", true))
	{
		new splash3elevator = FindEntityByName("elevator", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(splash3elevator, posx);

		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			CreateTimer(0.1, BotsStopMove);
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 3766.673);
			WritePackFloat(posdata, -4858.7075);
			WritePackFloat(posdata, 130.07637);
			CreateTimer(15.0, WarpAllBots, posdata);
			CreateTimer(17.5, Splash3CreepyAssHousePre);
			CreateTimer(20.0, Splash3CreepyAssHouse);
			CreateTimer(90.0, BotsStartMove);
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 3795.4307);
			WritePackFloat(posonedata, -5232.4365);
			WritePackFloat(posonedata, -145.96875);
			CreateTimer(90.1, WarpAllBots, posonedata);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "splash4", true))
	{
		new splash4gate2 = FindEntityByName("gate2_button", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(splash4gate2, posx);

		if (CheckforBots(posx, 200.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Ladies and gentlemen, we hope you enjoy this Journey on Splash Mountain. The ride will begin in 10 seconds.");
			CreateTimer(3.0, Splash4Gate2Wheel);
			MapTrigger = true;
		}
		
		new splash4gate1 = FindEntityByName("wheel_turn1_button", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(splash4gate1, pos1);

		if (CheckforBots(pos1, 400.0) && !MapTriggerTwo)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01They find the missing wheel...");
			
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 2195.6565);
			WritePackFloat(posdata, -8696.019);
			WritePackFloat(posdata, 334.9983);
			CreateTimer(30.0, WarpAllBots, posdata);
			CreateTimer(35.0, Splash4BoatGate1);
			
			MapTriggerTwo = true;
		}
		
		decl Float:pos2[3];
		pos2[0] = 2964.408;
		pos2[1] = -7133.5186;
		pos2[2] = 968.03125;

		if (CheckforBots(pos2, 300.0) && !WarpTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01A dead end for the bots...");
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 2630.0293);
			WritePackFloat(posonedata, -7778.4897);
			WritePackFloat(posonedata, 970.03125);
			CreateTimer(10.0, WarpAllBots, posonedata);
			CreateTimer(15.0, Splash4BoatGate3);
			
			WarpTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "splash5", true))
	{
		decl Float:posx[3];
		posx[0] = -619.0;
		posx[1] = -6912.0;
		posx[2] = 437.5;
		
		if (CheckforBots(posx, 250.0))
		{
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, 680.625);
			WritePackFloat(posdata, -4217.25);
			WritePackFloat(posdata, 405.5);
			CreateTimer(0.1, WarpAllBots, posdata);
		}
		
		decl Float:pos1[3];
		pos1[0] = -2751.1519;
		pos1[1] = -2829.6992;
		pos1[2] = 586.03125;

		if (CheckforBots(pos1, 250.0) && !MapTrigger && !FinaleHasStarted)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01End of the line... This concludes our tour of Disney World. Now we gotta get the fuck out. The finale will commence in 10 seconds.");
			CreateTimer(10.0, Splash5FinaleStart);
			MapTrigger = true;
		}
		
		if (FinaleHasStarted && !MapTriggerTwo)
		{
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, 680.625);
			WritePackFloat(postwodata, -4217.25);
			WritePackFloat(postwodata, 405.5);
			CreateTimer(30.0, WarpAllBots, postwodata);
			CreateTimer(45.0, Splash5GasCan8);
			CreateTimer(60.0, Splash5GasCan3);
			CreateTimer(75.0, Splash5GasCan6);
			CreateTimer(90.0, Splash5GasCan4);
			
			MapTriggerTwo = true;
		}

		if (FinaleHasStarted && ConfirmPourFinale && !MapTriggerThree && !EscapeReady)
		{
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, 680.625);
			WritePackFloat(postwodata, -4217.25);
			WritePackFloat(postwodata, 405.5);
			CreateTimer(30.0, WarpAllBots, postwodata);
			CreateTimer(45.0, Splash5GasCan1);
			CreateTimer(60.0, Splash5GasCan2);
			CreateTimer(75.0, Splash5GasCan5);
			CreateTimer(90.0, Splash5GasCan7);
			MapTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "l4d_5tolifef03", true))
	{
		if (FinaleHasStarted && !MapTrigger && !EscapeReady)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The bots proceed in the finale...");
			
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -3083.1772);
			WritePackFloat(posonedata, 6923.102);
			WritePackFloat(posonedata, -469.52893);
			CreateTimer(120.0, WarpAllBots, posonedata);
			
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "gasfever_1", true))
	{
		new gasfever1button = FindEntityByName("gauntlet_trigger_on", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(gasfever1button, posx);

		if (CheckforBots(posx, 250.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gauntlet_trigger_on", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "gasfever_2", true))
	{
		decl Float:posx[3];
		posx[0] = -2143.649;
		posx[1] = -1546.7096;
		posx[2] = 5855.8857;

		if (CheckforBots(posx, 1000.0) && !WarpTrigger)
		{
			new Handle:posdata = CreateDataPack();
			WritePackFloat(posdata, -3230.1184);
			WritePackFloat(posdata, -845.41907);
			WritePackFloat(posdata, 5878.0024);
			CreateTimer(10.0, WarpAllBots, posdata);
			
			WarpTrigger = true;
		}
		
		new gasfever2button = FindEntityByName("Bridge_button", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(gasfever2button, pos1);

		if (CheckforBots(posx, 500.0) && !MapTrigger)
		{
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 782.5558);
			WritePackFloat(posonedata, 2314.9136);
			WritePackFloat(posonedata, 5893.675);
			CreateTimer(10.0, WarpAllBots, posonedata);
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "gasfever_3", true))
	{
		if (!IsValidEntity(FindEntityByName("finale_start_button", -1)) && !MapTrigger)
		{
			MapTrigger = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(FindEntityByName("finale_start_button", -1), pos1);

			if (CheckforBots(pos1, 300.0) && !MapTrigger)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01They start the first generator...");
				
				AcceptEntityInput(FindEntityByName("finale_start_button", -1), "Press");
				CreateTimer(5.0, C7M3GeneratorStart);
				MapTrigger = true;
				
				new Handle:posdata = CreateDataPack();
				WritePackFloat(posdata, 3108.4167);
				WritePackFloat(posdata, 10304.475);
				WritePackFloat(posdata, 5915.9194);
				CreateTimer(20.0, WarpAllBots, posdata);
			}
		}

		if (!IsValidEntity(FindEntityByName("finale_start_button1", -1)) && MapTrigger && !MapTriggerTwo)
		{
			MapTriggerTwo = true;
		}
		else
		{
			decl Float:pos1[3];
			GetEntityAbsOrigin(FindEntityByName("finale_start_button1", -1), pos1);

			if (CheckforBots(pos1, 300.0) && !MapTriggerTwo)
			{
				PrintToChatAll("\x04[AutoTrigger] \x01The second generator starts...");
				
				AcceptEntityInput(FindEntityByName("finale_start_button1", -1), "Press");
				CreateTimer(5.0, C7M3GeneratorStart1);
				MapTriggerTwo = true;
				new Handle:posonedata = CreateDataPack();
				WritePackFloat(posonedata, 1211.1577);
				WritePackFloat(posonedata, 9821.683);
				WritePackFloat(posonedata, 6102.237);
				CreateTimer(20.0, WarpAllBots, posonedata);
			}
		}

		if (!IsValidEntity(FindEntityByName("finale_start_button2", -1)) && MapTrigger && MapTriggerTwo && !MapTriggerThree)
		{
			MapTriggerThree = true;
		}
		
		decl Float:pos1[3];
		GetEntityAbsOrigin(FindEntityByName("finale_start_button2", -1), pos1);

		if (CheckforBots(pos1, 300.0) && !MapTriggerThree)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The third generator starts...");
			AcceptEntityInput(FindEntityByName("finale_start_button2", -1), "Press");
			CreateTimer(5.0, C7M3GeneratorStart2);
			MapTriggerThree = true;
		}
	}
	
	if (StrEqual(mapname, "jsgone01_crash", true))
	{
		new G60gascans = FindEntityByName("barricade_gas_can", -1);
		if (G60gascans == -1)
		{
			MapTrigger = true;
		}
		decl Float:posx[3];
		GetEntityAbsOrigin(G60gascans, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(G60gascans, "Ignite");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "jsgone02_end", true))
	{
		new G60Door = FindEntityByName("emergency_door", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(G60Door, posx);

		if (CheckforBots(posx, 200.0) && !MapTrigger && !FinaleHasStarted)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "emergency_door", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "suburbs2", true))
	{
		new LastLinePC = FindEntityByName("button1", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(LastLinePC, posx);

		if (CheckforBots(posx, 400.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button1", "Use");
			MapTrigger = true;
		}
		
		new LastLineGascan = FindEntityByName("gascan", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(LastLineGascan, pos1);

		if (CheckforBots(posx, 400.0) && !MapTriggerTwo)
		{
			CreateTimer(0.1, BotsStopMove);
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "relay1", "Trigger");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gascan", "Kill");
			CreateTimer(60.0, BotsStartMove);
			MapTriggerTwo = true;
		}
	}
	
	if (StrEqual(mapname, "busstation3", true))
	{
		if (FinaleHasStarted && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button4", "Kill");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button3", "Unlock");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button3", "Use");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button2", "Use");
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button1", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "campanar_coop_vs", true))
	{
		new LastSummergascans = FindEntityByName("barricade_gas_can", -1);
		if (LastSummergascans == -1)
		{
			MapTrigger = true;
		}
		
		decl Float:posx[3];
		GetEntityAbsOrigin(LastSummergascans, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(LastSummergascans, "Ignite");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "alboraya_coop_vs", true))
	{
		decl Float:posx[3];
		posx[0] = 8353.692;
		posx[1] = 8748.271;
		posx[2] = 64.03125;

		if (CheckforBots(posx, 150.0) && !WarpTrigger)
		{
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, 8077.6436);
			WritePackFloat(posonedata, 8622.418);
			WritePackFloat(posonedata, 64.03125);
			CreateTimer(10.0, WarpAllBots, posonedata);
			WarpTrigger = true;
		}
		
		new LastSummerButton = FindEntityByName("alarmstop1", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(LastSummerButton, pos1);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "alarmstop1", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "cullera_coop_vs", true))
	{
		decl Float:posx[3];
		posx[0] = -6187.5;
		posx[1] = -2410.0;
		posx[2] = -1370.375;

		if (CheckforBots(posx, 150.0) && !WarpTrigger)
		{
			CreateTimer(0.1, BotsStick);
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -5937.888);
			WritePackFloat(posonedata, 217.6694);
			WritePackFloat(posonedata, -1258.8883);
			CreateTimer(10.0, WarpAllBots, posonedata);
			CreateTimer(10.1, BotsUnstick);
			WarpTrigger = true;
		}
		
		new LastSummerRadio = FindEntityByName("radio", -1);
		decl Float:pos1[3];
		GetEntityAbsOrigin(LastSummerRadio, pos1);

		if (CheckforBots(posx, 200.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio", "ForceFinaleStart");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_sbtd_02", true))
	{
		new SBTDButton = FindEntityByName("slide_door_btn", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(SBTDButton, posx);

		if (CheckforBots(posx, 300.0) && !MapTrigger)
		{
			UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "slide_door_btn", "Use");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "l4d2_sbtd_03", true))
	{
		new SBTDgascans = FindEntityByName("barricade_gas_can", -1);
		if (SBTDgascans == -1)
		{
			MapTrigger = true;
		}
		
		decl Float:posx[3];
		GetEntityAbsOrigin(SBTDgascans, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01Down goes the wall...");
			AcceptEntityInput(SBTDgascans, "Ignite");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "eu03_oldtown_b16", true))
	{
		new TTgascans = FindEntityByName("barricade_gas_can", -1);
		if (TTgascans == -1)
		{
			MapTrigger = true;
		}
		
		decl Float:posx[3];
		GetEntityAbsOrigin(TTgascans, posx);

		if (CheckforBots(posx, 900.0) && !MapTrigger)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The barricade is burning...");
			AcceptEntityInput(TTgascans, "Ignite");
			MapTrigger = true;
		}
	}
	
	if (StrEqual(mapname, "wfp4_commstation", true))
	{
		new WF4Radio = FindEntityByName("wf4_final_cboxbtt", -1);
		decl Float:posx[3];
		GetEntityAbsOrigin(WF4Radio, posx);

		if (CheckforBots(posx, 200.0) && !MapTrigger && !FinaleHasStarted)
		{
			PrintToChatAll("\x04[AutoTrigger] \x01The finale will start in 30 seconds...");
			new Handle:posfourdata = CreateDataPack();
			WritePackFloat(posfourdata, -2326.9055);
			WritePackFloat(posfourdata, -7812.5933);
			WritePackFloat(posfourdata, -1519.9688);
			CreateTimer(29.5, WarpAllBots, posfourdata);
			CreateTimer(30.0, WF4FinaleStart);
			MapTrigger = true;
		}
		
		new WF4Button1 = FindEntityByName("wf4_generator_btt1", -1);
		new WF4Button2 = FindEntityByName("wf4_generator_btt2", -1);
		new WF4Button3 = FindEntityByName("wf4_generator_btt3", -1);
		new WF4Button4 = FindEntityByName("wf4_generator_btt4", -1);

		if (WF4Button1 == -1 && FinaleHasStarted && !MapTriggerTwo)
		{
			MapTriggerTwo = true;
		}

		if (WF4Button2 == -1 && FinaleHasStarted && !MapTriggerThree)
		{
			MapTriggerThree = true;
		}

		if (WF4Button3 == -1 && FinaleHasStarted && !MapTriggerFourth)
		{
			MapTriggerFourth = true;
		}

		if (WF4Button4 == -1 && FinaleHasStarted && !WarpTrigger)
		{
			WarpTrigger = true;
		}

		if (FinaleHasStarted && !MapTriggerTwo)
		{
			new Handle:posonedata = CreateDataPack();
			WritePackFloat(posonedata, -1524.4092);
			WritePackFloat(posonedata, -8447.203);
			WritePackFloat(posonedata, -1439.1017);
			CreateTimer(15.0, WarpAllBots, posonedata);
			CreateTimer(20.0, WF4TimedButton1);
			MapTriggerTwo = true;
		}
		
		decl Float:pos1[3];
		GetEntityAbsOrigin(WF4Button1, pos1);

		if (CheckforBots(pos1, 400.0) && FinaleHasStarted && !MapTriggerThree)
		{
			new Handle:postwodata = CreateDataPack();
			WritePackFloat(postwodata, -3187.8936);
			WritePackFloat(postwodata, -7767.919);
			WritePackFloat(postwodata, -1535.9688);
			CreateTimer(15.0, WarpAllBots, postwodata);
			CreateTimer(20.0, WF4TimedButton2);
			MapTriggerThree = true;
		}
		
		decl Float:pos2[3];
		GetEntityAbsOrigin(WF4Button2, pos2);

		if (CheckforBots(pos2, 400.0) && FinaleHasStarted && !MapTriggerFourth)
		{
			new Handle:posthreedata = CreateDataPack();
			WritePackFloat(posthreedata, -3633.8118);
			WritePackFloat(posthreedata, -8951.031);
			WritePackFloat(posthreedata, -1535.9688);
			CreateTimer(15.0, WarpAllBots, posthreedata);
			CreateTimer(20.0, WF4TimedButton3);
			MapTriggerFourth = true;
		}
		
		decl Float:pos3[3];
		GetEntityAbsOrigin(WF4Button3, pos3);

		if (CheckforBots(pos3, 400.0) && FinaleHasStarted && !WarpTrigger)
		{
			new Handle:posfifthdata = CreateDataPack();
			WritePackFloat(posfifthdata, -3633.8118);
			WritePackFloat(posfifthdata, -8951.031);
			WritePackFloat(posfifthdata, -1535.9688);
			CreateTimer(15.0, WarpAllBots, posfifthdata);
			CreateTimer(20.0, WF4TimedButton4);
			WarpTrigger = true;
		}

		if (FinaleHasStarted && MapTriggerTwo && !MapTriggerThree)
		{
			new Handle:possixdata = CreateDataPack();
			WritePackFloat(possixdata, -3187.8936);
			WritePackFloat(possixdata, -7767.919);
			WritePackFloat(possixdata, -1535.9688);
			CreateTimer(15.0, WarpAllBots, possixdata);
			CreateTimer(20.0, WF4TimedButton1);
			MapTriggerThree = true;
		}

		if (FinaleHasStarted && MapTriggerTwo && MapTriggerThree && !MapTriggerFourth)
		{
			new Handle:possevendata = CreateDataPack();
			WritePackFloat(possevendata, -3633.8118);
			WritePackFloat(possevendata, -8951.031);
			WritePackFloat(possevendata, -1535.9688);
			CreateTimer(15.0, WarpAllBots, possevendata);
			CreateTimer(20.0, WF4TimedButton2);
			MapTriggerFourth = true;
		}

		if (FinaleHasStarted && MapTriggerTwo && MapTriggerThree && MapTriggerFourth && !WarpTrigger)
		{
			new Handle:poseightdata = CreateDataPack();
			WritePackFloat(poseightdata, -3633.8118);
			WritePackFloat(poseightdata, -8951.031);
			WritePackFloat(poseightdata, -1535.9688);
			CreateTimer(15.0, WarpAllBots, poseightdata);
			CreateTimer(20.0, WF4TimedButton3);
			WarpTrigger = true;
		}
	}
	return Plugin_Continue;
}

public Action:WarpAllBots(Handle:Timer, Handle:posdata)
{
	ResetPack(posdata);
	decl Float:position[3];
	position[0] = ReadPackFloat(posdata);
	position[1] = ReadPackFloat(posdata);
	position[2] = ReadPackFloat(posdata);
	CloseHandle(posdata);
	
	PrintToChatAll("\x04[AutoTrigger] \x01Bots have been repositioned.");
	
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (IsPlayerAlive(target) && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a Survivor Bot
			{
				TeleportEntity(target, position, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
}

public Action:BotsStopMove(Handle:Timer)
{
	// Dead Center 02 - Go In The Market
	SetConVarInt(FindConVar("sb_move"), 0);
}

public Action:BotsStartMove(Handle:Timer)
{
	// Dead Center 02 - Out Off The Market
	SetConVarInt(FindConVar("sb_move"), 1);
}

public Action:BotsStick(Handle:Timer)
{
	// Cold Stream 04 - Finale Started
	SetConVarInt(FindConVar("sb_unstick"), 0);
}

public Action:BotsUnstick(Handle:Timer)
{
	// Cold Stream 04 - Finale Started
	SetConVarInt(FindConVar("sb_unstick"), 1);
}

public Action:BotsOffFire(Handle:Timer)
{
	// Cold Stream 04 - Finale Started
	SetConVarInt(FindConVar("sb_open_fire"), 0);
}

public Action:BotsOpenFire(Handle:Timer)
{
	// Cold Stream 04 - Finale Started
	SetConVarInt(FindConVar("sb_open_fire"), 1);
}

public Action:CallSuperMarket(Handle:Timer)
{
	// name store_doors, class prop_door_rotating - input "Open"
	AcceptEntityInput(FindEntityByName("store_doors", -1), "Open");
}

public Action:CallTankerBoom(Handle:Timer)
{
	// ent_fire tanker_destroy_relay trigger
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "tanker_destroy_relay", "trigger");
}

public Action:BridgeMiniFinale(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "bridge_button", "Use");
}

public Action:C4M2BotsActions(Handle:Timer)
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (IsPlayerAlive(target) && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a Survivor Bot
			{
				L4D2_RunScript("CommandABot({cmd=1,pos=Vector(-1125.9,-10181.1,179.6),bot=GetPlayerFromUserID(%i)})", GetClientUserId(target));
			}
		}
	}
}

public Action:C5M4BotsActions(Handle:Timer)
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (IsPlayerAlive(target) && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a Survivor Bot
			{
				L4D2_RunScript("CommandABot({cmd=1,pos=Vector(-2179.3,389.3,302.0),bot=GetPlayerFromUserID(%i)})", GetClientUserId(target));
			}
		}
	}
}

public Action:C6M2BotsActions(Handle:Timer)
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (IsPlayerAlive(target) && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a Survivor Bot
			{
				L4D2_RunScript("CommandABot({cmd=1,pos=Vector(36.9,1888.7,-1.9),bot=GetPlayerFromUserID(%i)})", GetClientUserId(target));
			}
		}
	}
}

public Action:ResumeBotsActions(Handle:Timer)
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (IsPlayerAlive(target) && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a Survivor Bot
			{
				L4D2_RunScript("CommandABot({cmd=3,bot=GetPlayerFromUserID(%i)})", GetClientUserId(target));
			}
		}
	}
}

public Action:RunBusStationEvent(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("finale_cleanse_entrance_door", -1), "Close");
	//PrintToChatAll("\x04[AutoTrigger] \x01They gather in the CEDA Trailer...");
	CreateTimer(5.0, RunBusStationEvent2);
}

public Action:RunBusStationEvent2(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("finale_cleanse_exit_door", -1), "Open");
	//PrintToChatAll("\x04[AutoTrigger] \x01They run for it...");
}
/*
public Action:C2M3WarpAllBotToThere(Handle:Timer)
{
	// c2m3 - after shut off the rollercoaster, warp them to the special spot
	decl Float:posx[3];
	posx[0] = -4029.9;
	posx[1] = 1428.9;
	posx[2] = 222.0;
	// confusion spot -4029.9 1428.9 222.0, teleport them off
	// to: -4315.1 2311.4 313.2
	if (CheckforBots(posx, 300.0) && !WarpTrigger)
	{
		PrintToChatAll("\x04[AutoTrigger] \x01Bot found at a stuck spot, warping them all ahead in 50 seconds");
		
		new Handle:posdata = CreateDataPack();
		WritePackFloat(posdata, -4315.1);
		WritePackFloat(posdata, 2311.4);
		WritePackFloat(posdata, 313.2);
		CreateTimer(50.0, WarpAllBots, posdata);
		WarpTrigger = true;
	}
}
public Action:C3M3WarpAllBotToThere(Handle:Timer)
{
	decl1 Float:posx[3];
	posx[0] = ;
	posx[1] = ;
	posx[2] = ;
	if (CheckForBots(posx, 2000.0) && !WarpTrigger)
	{
		PrintToChatAll("\x04[AutoTrigger] \x01Bots can't seem to simply lower the plank... I'll have to do it for them...");
		
		new Handle:posdata = CreateDataPack();
		WritePackFloat(posdata, -4315.1);
		WritePackFloat(posdata, 2311.4);
		WritePackFloat(posdata, 313.2);
		CreateTimer(50.0, WarpAllBots, posdata);
		WarpTrigger = true;
	}
}
*/
public Action:C3M4FinaleStart(Handle:Timer)
{
	PrintToChatAll("\x04[AutoTrigger] \x01Virgil is on his way!");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "escape_gate_triggerfinale", "Use");
}

public Action:C5M5FinaleStart(Handle:Timer)
{
	PrintToChatAll("\x04[AutoTrigger] \x01The bridge lowers...");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "finale", "Use");
}

public Action:C10M5FinaleStart(Handle:Timer)
{
	// c10m5 - finale start
	if (MapTrigger && !MapTriggerTwo)
	{
		PrintToChatAll("\x04[AutoTrigger] \x01John Slater is on his way!");
		UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio", "Use");
		MapTriggerTwo = true;
	}
}

public Action:C11M5FinaleStart(Handle:Timer)
{
	// c11m5 - finale start
	if (MapTrigger && !MapTriggerTwo && !FinaleHasStarted)
	{
		PrintToChatAll("\x04[AutoTrigger] \x01The plane is fueling up!");
		UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "radio", "Use");
		MapTriggerTwo = true;
	}
}

public Action:C14M1PanicEvent(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "fuel_button", "Press");
	CreateTimer(90.0, C14M1PanicEventPart2);
}

public Action:C14M1PanicEventPart2(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_counter", "SetValue", "", "4");
	CreateTimer(60.0, C14M1PanicEventPart3);
}

public Action:C14M1PanicEventPart3(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "drop_button", "Press");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "unblock_container_path", "UnblockNav");
}

public Action:GeneratorStart(Handle:Timer)
{
	// Crash Cause 02 - Generator Start
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finaleswitch_initial", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_lever", "Enable", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event_pre", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event", "GenerateGameEvent", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_start", "StopSound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_start_particles", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_light_switchable", "TurnOn", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_lights", "LightOn", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_run", "PlaySound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_switch_spark", "SparkOnce", "", "1");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_lever", "SetDefaultAnimation", "IDLE_DOWN", "0.1");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_lever", "SetAnimation", "DOWN", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_spark02", "SparkOnce", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_spark01", "SparkOnce", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "survivalmode_exempt", "Trigger", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_break_timer", "Enable", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_lever", "ForceFinaleStart", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_hint", "EndHint", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "survival_start_relay", "Trigger", "", "0");
}

public Action:GeneratorStartTwoReady(Handle:Timer)
{
	// Crash Cause 02 - Generator Second Start
	PrintToChatAll("\x04[AutoTrigger] \x01The generator has been restarted!");
	AcceptEntityInput(FindEntityByName("generator_switch", -1), "Press");
}

public Action:GeneratorStartTwo(Handle:Timer)
{
	// Crash Cause 02 - Generator Second Start
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_switch", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_lever", "Enable", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_start", "StopSound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_start_particles", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_light_switchable", "TurnOn", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_lights", "LightOn", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_run", "PlaySound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_switch_spark", "SparkOnce", "", "1");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_lever", "SetDefaultAnimation", "IDLE_DOWN", "0.1");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_lever", "SetAnimation", "DOWN", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_spark02", "SparkOnce", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "lift_spark01", "SparkOnce", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "survivalmode_exempt", "Trigger", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_lever", "ForceFinaleStart", "", "5");
}

public Action:TankDoor01COOP(Handle:Timer)
{
	// The Sacrifice 01 - Tank Door - In
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorin_button", "UnLock", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "coop_tank", "Trigger", "", "0+5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorin", "Open", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorin_button", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_sound_timer", "Disable", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "panic_event_relay", "Trigger", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "doorsound", "PlaySound", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_fog", "Enable", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_fog", "Disable", "", "5+0.5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "big_splash", "Stop", "", "5+2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "big_splash", "Start", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_door_clip", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "director", "EnableTankFrustration", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "battlefield_cleared", "UnblockNav", "", "5+60");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_car_camera_clip", "Kill", "", "5");
}

public Action:TankDoor01VERSUS(Handle:Timer)
{
	// The Sacrifice 01 - Tank Door - In
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorin_button", "UnLock", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "versus_tank", "Trigger", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorin", "Open", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorin_button", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_sound_timer", "Disable", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "panic_event_relay", "Trigger", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "doorsound", "PlaySound", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_fog", "Enable", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_fog", "Disable", "", "5+0.5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "big_splash", "Stop", "", "5+2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "big_splash", "Start", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_door_clip", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "director", "EnableTankFrustration", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "battlefield_cleared", "UnblockNav", "", "5+60");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tank_car_camera_clip", "Kill", "", "5");
}

public Action:TankDoor02(Handle:Timer)
{
	// The Sacrifice 01 - Tank Door - Out
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorout_button", "UnLock", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorout", "Open", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "tankdoorout_button", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "battlefield_cleared", "UnblockNav", "", "0");
}

public Action:TimedButtonTest(Handle:Timer)
{
	// The Sacrifice 01 - Tank Door - In
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gnomebutton", "UnLock", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gnomebutton", "Press", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gnomebutton", "Kill", "", "0");
} 

public Action:C7M3GeneratorStart(Handle:Timer)
{
	// The Sacrifice 03 - Generator Start
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_start_button", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_start", "StopSound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_run", "PlaySound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_start_particles", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_model2", "StopGlowing", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event_pre", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "mob_spawner_finale", "Enable", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator2_tankmessage_templated", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "relay_advance_finale_state", "Trigger", "", "2");
	//UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "", "", "", "0");
}

public Action:C7M3GeneratorStart1(Handle:Timer)
{
	// The Sacrifice 03 - Generator1 Start
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_start_button1", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_start1", "StopSound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_run1", "PlaySound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_start_particles1", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_model1", "StopGlowing", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "mob_spawner_finale", "Enable", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "relay_advance_finale_state", "Trigger", "", "2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event_pre1", "Kill", "", "0");
}

public Action:C7M3GeneratorStart2(Handle:Timer)
{
	// The Sacrifice 03 - Generator2 Start
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "finale_start_button2", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_start2", "StopSound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "sound_generator_run2", "PlaySound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_start_particles2", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_model3", "StopGlowing", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "mob_spawner_finale", "Enable", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator3_tankmessage_templated", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "relay_advance_finale_state", "Trigger", "", "2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "radio_game_event_pre2", "Kill", "", "0");
}

public Action:C7M3WarpBotsToGenerator1(Handle:Timer)
{
	// The Sacrifice 03 - Warp Bots to Generator1
	// c7m3 - after they start the first generator, warp them to the special spot,
	// there has an another generator
	// teleport them off to -1224.8 814.7 222.0
	PrintToChatAll("\x04[AutoTrigger] \x01Start c7m3 trigger1-1.");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -1224.8);
	WritePackFloat(posdata, 814.7);
	WritePackFloat(posdata, 222.0);
	CreateTimer(10.0, WarpAllBots, posdata);
}

public Action:C7M3WarpBotsToGenerator2(Handle:Timer)
{
	// The Sacrifice 03 - Warp Bots to Generator2
	// c7m3 - after they start the second generator, warp them to the special spot,
	// there has the last generator
	// teleport them off to 1781.9 678.1 -33.9
	PrintToChatAll("\x04[AutoTrigger] \x01Start c7m3 trigger2-1.");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, 1781.9);
	WritePackFloat(posdata, 678.1);
	WritePackFloat(posdata, -33.9);
	CreateTimer(10.0, WarpAllBots, posdata);
}

public Action:C7M3BridgeStartButton(Handle:Timer)
{
	// The Sacrifice 03 - C7M3 Bridge Start Button
	PrintToChatAll("\x04[AutoTrigger] \x01The bridge goes up...");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "bridge_start_button", "Use");
}

public Action:C7M3GeneratorFinaleButtonStart(Handle:Timer)
{
	// The Sacrifice 03 - Generator final button start
	PrintToChatAll("\x04[AutoTrigger] \x01Rest in peace, Survivor Bot...");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "generator_final_button_relay", "Trigger", "", "0");
}

public Action:C13M2Trigger(Handle:Timer)
{
	//PrintToChatAll("\x04[AutoTrigger] \x01Start c13m2 trigger.");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_barrels", "StopGlowing", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_barrels", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_clip", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_button", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_explosion", "Explode", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_fire", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_fire", "Stop", "", "10");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_fire_sound", "PlaySound", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_fire_sound", "StopSound", "", "11");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_shake", "StartShake", "", "2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_shake", "StopShake", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_murette", "Break", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_impact", "Explode", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_explosion_sound", "PlaySound", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "barrier", "Kill", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_smoke", "Start", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_smoke", "Stop", "", "10");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_dummy", "Kill", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "director", "BeginScript", "event_alarme", "3.2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_new_particle", "Start", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_new_particle1", "Start", "", "3.2");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_new_particle1", "Stop", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_new_particle", "Stop", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "ceda_truck_alarm", "PlaySound", "", "3.5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_nav_blocker", "UnblockNav", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_barrels_hurt_trigger", "Enable", "", "3");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "bridge_barrels_hurt_trigger", "Disable", "", "10");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "template_onslaught_hint", "ForceSpawn", "", "4");
}

public Action:UF4FailSafeOne(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, 128.350266);
	WritePackFloat(posdata, -42.504993);
	WritePackFloat(posdata, 512.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:UF4FailSafeTwo(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, 316.117584);
	WritePackFloat(posdata, 1012.142151);
	WritePackFloat(posdata, 60.612732);
	CreateTimer(0.1, WarpAllBots, posdata);
	AcceptEntityInput(FindEntityByName("garage_elevator_trigger", -1), "Press");
}

public Action:UF4FailSafeThree(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -213.626831);
	WritePackFloat(posdata, 3271.414551);
	WritePackFloat(posdata, 0.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:UF4FailSafeFour(Handle:Timer)
{
	WarpTriggerThree = true;
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -1944.317749);
	WritePackFloat(posdata, 3049.523682);
	WritePackFloat(posdata, 260.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
	AcceptEntityInput(FindEntityByName("hanger_door_trigger", -1), "Press");
}

public Action:UFFinish(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -1024.538818);
	WritePackFloat(posdata, 4051.666504);
	WritePackFloat(posdata, 53.531250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:UrbanFlightJoke(Handle:Timer)
{
	PrintToChatAll("\x04[AutoTrigger] \x01Huh. I guess this is a du-\x01");
}

public Action:TowerGoesBoom(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "crescendo_relay", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "crescendo_button", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "crescendo_suitcasebomb", "Kill");
}

public Action:NeverMind(Handle:Timer)
{
	PrintToChatAll("\x04[AutoTrigger] \x01Never mind...\x01");
}

public Action:IceMelt1(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block01", -1), "Break");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -3031.389893);
	WritePackFloat(posdata, 2597.083252);
	WritePackFloat(posdata, 496.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:IceMelt2(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block02", -1), "Break");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -3286.694092);
	WritePackFloat(posdata, 390.235321);
	WritePackFloat(posdata, 249.449005);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:IceMelt3(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block03", -1), "Break");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -1385.912109);
	WritePackFloat(posdata, 2924.836914);
	WritePackFloat(posdata, 237.437546);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:IceMelt4(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block04", -1), "Break");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -5834.841309);
	WritePackFloat(posdata, 4019.392334);
	WritePackFloat(posdata, 760.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:IceMelt5(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block05", -1), "Break");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -3031.389893);
	WritePackFloat(posdata, 2597.083252);
	WritePackFloat(posdata, 496.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:IceMelt6(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block06", -1), "Break");
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -3286.694092);
	WritePackFloat(posdata, 390.235321);
	WritePackFloat(posdata, 249.449005);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:IceMelt7(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("ice_block07", -1), "Break");
}

public Action:RoadToNoWhereFix(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, 7176.283691);
	WritePackFloat(posdata, -11124.616211);
	WritePackFloat(posdata, 263.031250);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:RoadToNoWhereFix2(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -2984.835938);
	WritePackFloat(posdata, 1130.597778);
	WritePackFloat(posdata, 293.519775);
	CreateTimer(0.1, WarpAllBots, posdata);
}

public Action:SuicideBlitz2PowerSwitch(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -587.908386);
	WritePackFloat(posdata, 703.629517);
	WritePackFloat(posdata, -2086.968750);
	CreateTimer(0.1, WarpAllBots, posdata);
	
	AcceptEntityInput(FindEntityByName("power restore floor cons", -1), "Press");
}

public Action:SuicideBlitz2ReturnToElevator(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, 375.483673);
	WritePackFloat(posdata, 503.492798);
	WritePackFloat(posdata, -2130.968750);
	CreateTimer(0.1, WarpAllBots, posdata);
	
	AcceptEntityInput(FindEntityByName("elevator button2", -1), "Press"); 
}

public Action:SuicideBlitz2FinaleRelay(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "grate_open_relay", "Trigger");
}

public Action:SuicideBlitz2Gascan(Handle:Timer)
{
	AcceptEntityInput(FindEntityByName("event_gascan", -1), "Ignite");
}

public Action:Yama3TramTrigger(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "engine_button", "Press");
}

public Action:Yama3Tram2Trigger(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "cablecar_door", "Press");
}

public Action:YamaFinale(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "scav_finale_starter", "ForceFinaleStart");
}

public Action:Yama3GeneratorEvent(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "generator_button", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "generator_door", "Unlock");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "generator_door", "Open");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "sound_generator_start", "StopSound");
}

public Action:DayBreak03GasCans(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gascan_relay", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "barricade_gas_can", "Kill");
}

public Action:DayBreak05PreFinale(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button_lockdoor", "Press");
}

public Action:DayBreak05Finale(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "finale_button", "Press");
}

public Action:BloodProofFinale(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "finale_trigger", "ForceFinaleStart");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "train_engine_relay", "Trigger");
}

public Action:BloodTracksBoomMessage(Handle:Timer)
{
	PrintToChatAll("\x04[AutoTrigger] \x01Motherf--");
	CreateTimer(0.5, BloodTracksBoom);
}

public Action:BloodTracksBoom(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "extra_triggers", "Trigger");
}

public Action:FarewellChenming1Intro1(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "mt_bshelf_mbtt", "Press");
}

public Action:FarewellChenming1Intro2(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "mt_start_wdoor", "Open");
}

public Action:FarewellChenming1C4(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "mt_c4_fangzhi", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "mt_c4_downtime", "Trigger");
}

public Action:FarewellChenming1TrainDoor(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "mt_rtrain_dbtt", "UnLock", "", "0");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "mt_rtrain_dmovel", "Open", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "mt_rtrain_dbtt", "Kill", "", "5");
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "doorsound", "PlaySound", "", "5");
}

public Action:FareWellChenming3Door(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "ccm_df_dbutton", "Press");
}

public Action:FareWellChenming3Key(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "ccm_df_keypick", "Press");
}

public Action:FareWellChenming3Button(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "ccm_dxtd_opbtt", "Press");
}

public Action:BloodProofPanicButton(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button_stop_panic", "Press");
}

public Action:BloodProofGenerator(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "power_button", "Press");
}

public Action:DamItButton(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button_remote", "Unlock");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "button_remote", "Press");
}

public Action:DamItElevator2(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "elevator_button01", "Press");
}

public Action:DKRFireworks1(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "fireworks_logic_relay", "Trigger");
}

public Action:DKRFireworks2(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "fireworks_logic_relay", "Trigger");
}

public Action:DKRFlashPots(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "flashpot_logic_relay", "Trigger");
}

public Action:DKRSpotLights(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "spotlight_logic_relay", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "spotlight_relay1", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "spotlight_relay2", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "spotlight_relay3", "Trigger");
}

public Action:DKRFinaleTank1(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "tank1_logic_relay", "Trigger");
}

public Action:DKRFinalePhase2(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "stage2_logic_relay", "Trigger");
}

public Action:DKRSpeakers(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "speaker_logic_relay", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "speaker_relay", "Trigger");
}

public Action:DKRScavenge(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "morelights_relay", "Trigger");
}

public Action:DKRScavengeBypass(Handle:Timer)
{
	if (!ConfirmPourFinale)
	{
		UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "scav_counter2", "SetValue", "", "1");
	}
}

public Action:DKRGate1(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate_open", "Open");
}

public Action:DKRFireworksCluster3(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "fireworkscluster_relay", "Trigger");
}

public Action:DKRMic(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "mic_relay", "Trigger");
}

public Action:DKRMicGuarantee(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "touch_counter", "SetValue", "", "1");
}

public Action:DKRDisableMic(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "touch_counter", "SetValue", "", "0");
}

public Action:DAGasLever(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "fueltruck-button", "Use");
}

public Action:DCII1Elevator(Handle:Timer)
{
	new Handle:posdata = CreateDataPack();
	WritePackFloat(posdata, -3414.9094);
	WritePackFloat(posdata, -800.1222);
	WritePackFloat(posdata, -57.860825);
	CreateTimer(0.1, WarpAllBots, posdata);
	MapTrigger = false;
}

public Action:DCIIScavengeEvent(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "trigger_finale", "ForceFinaleStart");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "roadway_door_2", "Open");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "relay_scavenge_postIO", "Trigger");
}

public Action:Splash3CreepyAssHousePre(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "", "Press");
}

public Action:Splash3CreepyAssHouse(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "elev_button", "Use");
}

public Action:Splash4Gate2Wheel(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate2_button", "Press");
	PrintToChatAll("\x04[AutoTrigger] \x01Please keep your hands, feet, and weapons inside the ride at all times. Or just run like hell to the second gate.");
	CreateTimer(7.0, Splash4Gate2WheelStart);
}

public Action:Splash4Gate2WheelStart(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "boat_train", "StartForward");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate1_brush", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate1_navblocker", "UnblockNav");
}

public Action:Splash4BoatGate1(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wheel_turn1_button", "Press");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate2_boat_start_relay", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate2_brush", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate2_navblocker", "UnblockNav");
}

public Action:Splash4BoatGate3(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate3_wheel", "Press");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate3_boat_start_relay", "Trigger");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate3_brush", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "gate3_navblocker", "UnblockNav");
}

public Action:Splash5FinaleStart(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "4");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button0", "Kill");
	
}

public Action:Splash5GasCan8(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "1");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button8", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car8", "StopGlowing");
}

public Action:Splash5GasCan3(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "2");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button3", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car3", "StopGlowing");
}

public Action:Splash5GasCan6(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "3");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button6", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car6", "StopGlowing");
}

public Action:Splash5GasCan4(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "4");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button4", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car4", "StopGlowing");
}

public Action:Splash5GasCan1(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "1");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button1", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car1", "StopGlowing");
}

public Action:Splash5GasCan2(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "2");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button2", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car2", "StopGlowing");
}

public Action:Splash5GasCan5(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "3");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button5", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car5", "StopGlowing");
}

public Action:Splash5GasCan7(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "gascan_counter", "SetValue", "", "4");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "siphon_button7", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "car7", "StopGlowing");
}

public Action:CDTA04Train(Handle:Timer)
{
	if (!MapTrigger)
	{
		MapTrigger = true;
	}
}

public Action:WF4FinaleStart(Handle:Timer)
{
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_final_cboxbtt", "Use");
}

public Action:WF4TimedButton1(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "wf4_generator_counter", "SetValue", "", "1");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_btt1", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_fake1", "StopGlowing");
}

public Action:WF4TimedButton2(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "wf4_generator_counter", "SetValue", "", "2");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_btt2", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_fake2", "StopGlowing");
}

public Action:WF4TimedButton3(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "wf4_generator_counter", "SetValue", "", "3");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_btt3", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_fake3", "StopGlowing");
}

public Action:WF4TimedButton4(Handle:Timer)
{
	UnflagAndExecuteCommandTwo(TriggeringBot, "ent_fire", "wf4_generator_counter", "SetValue", "", "4");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_btt4", "Kill");
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "wf4_generator_fake4", "StopGlowing");
}

public Action:FinaleStart(Handle:Timer)
{
	if (FinaleHasStarted) return Plugin_Continue;
	
	if (!TriggeringBot) TriggeringBot = GetAnyValidClient();
	else if (!IsClientInGame(TriggeringBot)) TriggeringBot = GetAnyValidClient();
	
	if (!TriggeringBot) return Plugin_Continue;
	UnflagAndExecuteCommand(TriggeringBot, "ent_fire", "trigger_finale", "");
	PrintToChatAll("\x04[AutoTrigger] \x01The finale has started!");
	return Plugin_Continue;
}

// this bool return true if a Bot was found in a radius around the given position, and sets TriggeringBot to it.
bool:CheckforBots(Float:position[3], Float:distancesetting)
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (IsPlayerAlive(target) && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a Survivor Bot
			{
				if (IsPlayerIncapped(target)) // incapped doesnt count
					return false;
				
				decl Float:targetPos[3];
				GetClientAbsOrigin(target, targetPos);
				new Float:distance = GetVectorDistance(targetPos, position); // check Survivor Bot Distance from checking point
				
				if (distance < distancesetting)
				{
					TriggeringBot = target;
					return true;
				}
				else
				{
					continue;
				}
			}
		}
	}
	return false;
}

stock FindEntityByName(String:name[], any:startcount)
{
	decl String:classname[128];
	new maxentities = GetMaxEntities();
	
	for (new i = startcount; i <= maxentities; i++)
	{
		if (!IsValidEntity(i)) continue; // exclude invalid entities.
		
		GetEdictClassname(i, classname, 128);
		
		if (FindDataMapOffs(i, "m_iName") == -1) continue;
		
		decl String:iname[128];
		GetEntPropString(i, Prop_Data, "m_iName", iname, sizeof(iname));
		if (strcmp(name, iname, false) == 0) return i;
	}
	return -1;
}

stock UnflagAndExecuteCommand(client, String:command[], String:parameter1[]="", String:parameter2[]="")
{
	if (!client || !IsClientInGame(client)) client = GetAnyValidClient();
	if (!client || !IsClientInGame(client)) return;
	
	new userflags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, parameter1, parameter2);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}

stock UnflagAndExecuteCommandTwo(client, String:command[], String:parameter1[]="", String:parameter2[]="", String:parameter3[]="", String:parameter4[]="")
{
	if (!client || !IsClientInGame(client)) client = GetAnyValidClient();
	if (!client || !IsClientInGame(client)) return;
	
	new userflags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s %s %s", command, parameter1, parameter2, parameter3, parameter4);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}

//entity abs origin code from here
//http://forums.alliedmods.net/showpost.php?s=e5dce96f11b8e938274902a8ad8e75e9&p=885168&postcount=3
stock GetEntityAbsOrigin(entity,Float:origin[3])
{
	if (entity > 0 && IsValidEntity(entity))
	{
		decl Float:mins[3], Float:maxs[3];
		GetEntPropVector(entity,Prop_Send,"m_vecOrigin",origin);
		GetEntPropVector(entity,Prop_Send,"m_vecMins",mins);
		GetEntPropVector(entity,Prop_Send,"m_vecMaxs",maxs);
		
		origin[0] += (mins[0] + maxs[0]) * 0.5;
		origin[1] += (mins[1] + maxs[1]) * 0.5;
		origin[2] += (mins[2] + maxs[2]) * 0.5;
	}
}

stock bool:IsVersus()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "versus", false) > -1)
		return true;
	return false;
}

stock bool:IsCoop()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "coop", false) > -1)
		return true;
	return false;
}

stock bool:IsM12()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "mutation12", false) > -1)
		return true;
	return false;
}

stock bool:IsScavenge()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "scavenge", false) > -1)
		return true;
	return false;
}

stock bool:IsSurvival()
{
	decl String:gamemode[56];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
	if (StrContains(gamemode, "survival", false) > -1)
		return true;
	return false;
}

stock bool:AllBotTeam()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			if (!IsFakeClient(client)) return false;
		}
	}
	return true;
}

stock bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated"))
		return true;
	return false;
}

stock GetAnyValidClient()
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target)) return target;
	}
	return -1;
}

stock AutoCommand(client, const String:command[], const String:arguments[], any:...)
{
	new String:vscript[PLATFORM_MAX_PATH];
	VFormat(vscript, sizeof(vscript), arguments, 4);	

	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags ^ FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, vscript);
	SetCommandFlags(command, flags | FCVAR_CHEAT);
}

// Thanks to Lux's advice and Timocop's implementation

stock L4D2_RunScript(const String:sCode[], any:...)
{
	static iScriptLogic = INVALID_ENT_REFERENCE;
	if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic)) {
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			SetFailState("Could not create 'logic_script'");
		
		DispatchSpawn(iScriptLogic);
	}
	
	static String:sBuffer[512];
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2);
	
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}