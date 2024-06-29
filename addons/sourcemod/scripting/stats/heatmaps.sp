ArrayList g_HeatMapEntities;
bool IsHeatMapVisualActive() { return g_HeatMapEntities != null; }
void ClearHeatMapEntities() {
	if(g_HeatMapEntities != null) {
		for(int i = 0 ; i < g_HeatMapEntities.Length; i++) {
			int ref = g_HeatMapEntities.Get(i);
			if(IsValidEntity(ref)) {
				RemoveEntity(ref);
			}
		}
		delete g_HeatMapEntities;
	}
}


enum HeatMapType {
	HeatMap_LedgeGrab,
	HeatMap_Incap,
	HeatMap_Death,
	HeatMap_Periodic,

	HeatMap_Any
	// TODO: boomed, periodic, jump?
	// maybe separate for fall death?
}
bool g_heatMapTypes[HeatMap_Any] = { true, true, true, false }; 
char g_heatMapPlayer[32];
int HEATMAP_TYPE_COLOR[HeatMap_Any][3] = {
	{ 30, 187, 201 }, // ledges
	{ 208, 208, 37 }, // incaps
	{ 255, 0, 0 }, // deaths
	{ 255, 255, 255 }, // periodic
};
char HEATMAP_ANIM[HeatMap_Any][] = {
	"idle_incap_hanging1",
	"idle_incap",
	"die_incap",
	""
};

float HEATMAP_ANIM_ANIM_FRAME[HeatMap_Any] = {
	0.0,
	0.0,
	1.0,
	0.0
};

char HEATMAP_IDS[view_as<int>(HeatMap_Any)+1][] = {
	"ledges",
	"incaps",
	"deaths",
	"periodic",
	"(all)"
};

enum struct PendingHeatMapData {
	HeatMapType type;
	int timestamp;
	// Round to nearest integer, so we can count occurrences
	int pos[3];
}

void ShowHeatMapMenu(int client) {
	Menu menu = new Menu(MainMenuHandler);
	menu.SetTitle("Heat Map Visualizer");
	menu.AddItem("f", "Filter Types");
	menu.AddItem("p", "Filter Player");
	if(IsHeatMapVisualActive())
		menu.AddItem("t", "Enabled: ON");
	else
		menu.AddItem("t", "Enabled: OFF");
	menu.Display(client, 0);
}
int MainMenuHandler(Menu menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		static char info[2];
		menu.GetItem(param2, info, sizeof(info));
		switch(info[0]) {
			case 'f': ShowHeatMapFilters(client);
			case 'p': ShowHeatMapPlayer(client);
			case 't': {
				if(IsHeatMapVisualActive())
					ClearHeatMapEntities();
				else
					GetHeatMapData(client);
				ShowHeatMapMenu(client);
			}
		}
	} else if (action == MenuAction_End)	
		delete menu;
	return 0;
}
void ShowHeatMapFilters(int client) {
	Menu menu = new Menu(FilterHandler);
	menu.SetTitle("Heatmap: Select types");
	char id[4], display[32];
	for(int i = 0; i < view_as<int>(HeatMap_Any); i++) {
		IntToString(i, id, sizeof(id));
		if(g_heatMapTypes[i])
			Format(display, sizeof(display), "%s (ON)", HEATMAP_IDS[i]);
		else
			Format(display, sizeof(display), "%s (OFF)", HEATMAP_IDS[i]);
		menu.AddItem(id, display);
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}
int FilterHandler(Menu menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		static char info[4];
		menu.GetItem(param2, info, sizeof(info));
		int i = StringToInt(info);
		g_heatMapTypes[i] = !g_heatMapTypes[i];
		if(g_heatMapTypes[i])
			ReplyToCommand(client, "Type \x05%s: \x04ON", HEATMAP_IDS[i]);
		else
			ReplyToCommand(client, "Type \x04%s: \x04OFF", HEATMAP_IDS[i]);
		if(IsHeatMapVisualActive()) {
			GetHeatMapData(client);
		}
		ShowHeatMapFilters(client)
	} else if(action == MenuAction_Cancel) {
		if(param2 == MenuCancel_ExitBack) ShowHeatMapMenu(client);
	} else if (action == MenuAction_End) {
		delete menu;
	} 
	return 0;
}
void ShowHeatMapPlayer(int client) {
	Menu menu = new Menu(PlayerHandler);
	menu.SetTitle("Heatmap: Select player");
	menu.AddItem("", "[ Enter SteamID ]");
	char steamid[32], display[32];
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2) {
			GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid));
			GetClientName(i, display, sizeof(display));
			menu.AddItem(steamid, display);
		}
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}
int PlayerHandler(Menu menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		static char steamid[32];
		menu.GetItem(param2, steamid, sizeof(steamid));
		if(StrEqual(steamid, "")) {
			ReplyToCommand(client, "Use sm_heatmaps player <steamid>");
			ShowHeatMapMenu(client)
		} else {
			strcopy(g_heatMapPlayer, sizeof(g_heatMapPlayer), steamid);
			ReplyToCommand(client, "Filter set: %s", steamid);
			GetHeatMapData(client);
			ShowHeatMapPlayer(client);
		}
	} else if(action == MenuAction_Cancel) {
		if(param2 == MenuCancel_ExitBack) ShowHeatMapMenu(client);
	} else if (action == MenuAction_End) {
		delete menu;
	} 
	return 0;
}

Action Command_Heatmaps(int client, int args) {
	if(args == 0) {
		ShowHeatMapMenu(client);
	} else {
		char arg[32];
		GetCmdArg(1, arg, sizeof(arg));
		if(StrEqual(arg, "player")) {
			GetCmdArg(2, arg, sizeof(arg));
			char escaped[65];
			if(!g_db.Escape(arg, escaped, sizeof(escaped)) || strlen(escaped) > 31 || StrContains(escaped, "STEAM_") == -1) {
				ReplyToCommand(client, "Invalid steamid. Must be in format of STEAM_#:#:#####");
			} else {
				strcopy(g_heatMapPlayer, sizeof(g_heatMapPlayer), escaped);
				ReplyToCommand(client, "Player filter set to: %s", g_heatMapPlayer);
			}
		} else if(StrEqual(arg, "filter")) {
			GetCmdArg(2, arg, sizeof(arg));
			HeatMapType type = GetHeatMapType(arg);
			if(type == HeatMap_Any) {
				for(int i = 0; i < view_as<int>(HeatMap_Any); i++) {
					Format(arg, sizeof(arg), "%s %s", arg, HEATMAP_IDS[i]);
				}
				ReplyToCommand(client, "Unknown filter. Must be one of: %s", arg);
				return Plugin_Handled;
			} else {
				g_heatMapTypes[type] = !g_heatMapTypes[type];
				if(g_heatMapTypes[type]) {
					ReplyToCommand(client, "Filter: %s (ON)", HEATMAP_IDS[type]);
				} else {
					ReplyToCommand(client, "Filter: %s (OFF)", HEATMAP_IDS[type]);
				}
				if(IsHeatMapVisualActive()) {
					GetHeatMapData(client);
				}
			}
		} else {
			ReplyToCommand(client, "Syntax: sm_heatmap <\"player\"/\"filter\"> <player name / filter name>");
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}

int CreateHeatMapVisual(HeatMapType type, float pos[3], int count) {
	int entity;
	if(type == HeatMap_Periodic) {
		int alpha = 128 + (count * 8);
		entity = CreateHeatMapEntity(type, pos, alpha);
	} else {
		int alpha = count * 16;
		entity = CreateHeatMapStatue(type, pos, alpha);
	}
	return entity;
}

int CreateHeatMapEntity(HeatMapType type, float pos[3], int alpha = 255) {
	PrecacheModel("models/props_fortifications/orange_cone001_reference.mdl");
	int entity = CreateEntityByName("prop_dynamic");
	if(entity == -1) return -1; 
	DispatchKeyValue(entity, "disableshadows", "1");
	DispatchKeyValue(entity, "model", "models/props_fortifications/orange_cone001_reference.mdl");
	DispatchKeyValue(entity, "targetname", "stats_heatmap_visual");
	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	if(!DispatchSpawn(entity)) return -1;
	SetEntityRenderColor(entity, 256 - alpha, alpha, 256 - alpha, 255);
	g_HeatMapEntities.Push(EntIndexToEntRef(entity));
	return entity;
}
int CreateHeatMapStatue(HeatMapType type, float pos[3], int alpha = 255) {
	PrecacheModel("models/survivors/survivor_teenangst.mdl");
	int entity = CreateEntityByName("commentary_dummy");
	if(entity == -1) return -1;
	DispatchKeyValue(entity, "disableshadows", "1");
	DispatchKeyValue(entity, "model", "models/survivors/survivor_teenangst.mdl");
	DispatchKeyValue(entity, "targetname", "stats_heatmap_visual");
	DispatchKeyValue(entity, "StartingAnim", HEATMAP_ANIM[type]);
	if(type == HeatMap_LedgeGrab)
		pos[2] -= 72.0;
	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	if(!DispatchSpawn(entity)) return -1;
	SetEntPropFloat(entity, Prop_Send, "m_flCycle", HEATMAP_ANIM_ANIM_FRAME[type]);
	SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);    
	L4D2_SetEntityGlow(entity, L4D2Glow_Constant, 10000, 0, HEATMAP_TYPE_COLOR[type], false);
	SetEntityRenderMode(entity, RENDER_TRANSALPHA);
	SetEntityRenderColor(entity, 255, 255, 255, alpha);
	g_HeatMapEntities.Push(EntIndexToEntRef(entity));
	return entity;
}

int GetTotalEntitiesCount() {
	int count = 0;	    
	int max = GetMaxEntities();
	for (int i = 0; i < max; i++) {
		if(IsValidEntity(i)) {
			count++;
		}
	}
	return count;
}


void GetHeatMapData(int respondToUser = 0) {
	char query[1024];
	// TODO: dynamically select types instead of filtering out visually
	if(g_heatMapPlayer[0] == '\0')
		Format(query, sizeof(query), "SELECT x,y,z,COUNT(*) as count,type FROM stats_heatmaps WHERE map='%s' GROUP BY x,y,z", game.name);
	else
		Format(query, sizeof(query), "SELECT x,y,z,COUNT(*) as count,type FROM stats_heatmaps WHERE map='%s' AND SUBSTRING(steamid, 11) = '%s' GROUP BY x,y,z", game.name, g_heatMapPlayer);
	
	int userid = respondToUser > 0 ? GetClientUserId(respondToUser) : 0;
	SQL_TQuery(g_db, DBCT_FetchHeatMap, query, userid);
}

void DBCT_FetchHeatMap(Handle db, DBResultSet results, const char[] error, int respondToUserId) {
	if(db == null || results == null) {
		LogError("DBCT_FetchHeatMap returned error: %s", error);
		int respondTo = GetClientOfUserId(respondToUserId);
		if(respondTo > 0) {
			PrintToChat(respondTo, "Error fetching data");
		}
	} else {
		ClearHeatMapEntities();
		int respondTo = GetClientOfUserId(respondToUserId);
		if(respondTo > 0) {
			PrintToChat(respondTo, "Enabled heatmap visualization. Enter command again to turn off.");
		} else {
			return; // just ignore if they left
		}
		int allowedPoints = (GetMaxEntities() - GetTotalEntitiesCount()) - 200;
		allowedPoints = MathMin(allowedPoints, 900);
		g_HeatMapEntities = new ArrayList();
		while(results.FetchRow() && allowedPoints > 0) {
			int type = results.FetchInt(4);
			// Ignore disabled types
			if(!g_heatMapTypes[type]) continue;

			float pos[3];
			pos[0] = results.FetchFloat(0);
			pos[1] = results.FetchFloat(1);
			pos[2] = results.FetchFloat(2);
			int count = results.FetchInt(3);
			
			if(type >= view_as<int>(HeatMap_Any))
				type = view_as<int>(HeatMap_Periodic);
			int entity = CreateHeatMapVisual(view_as<HeatMapType>(type), pos, count);
			if(entity != -1) {
				allowedPoints--;
			}
		}
		if(results.RowCount == 0) {
			ReplyToCommand(respondTo, "No data found for this map.");
			delete g_HeatMapEntities;
		} else {
			PrintToChat(respondTo, "Showing \x04%d\x01/%d points", g_HeatMapEntities.Length, results.RowCount);
			if(allowedPoints <= 0) {
				// TODO: pagination
				PrintToChat(respondTo, "Warn: Ran out of visualization budget. Try filtering certain types.");
			} 
		} 
	}
}
HeatMapType GetHeatMapType(const char arg[32]) {
	for(int i = 0; i < view_as<int>(HeatMap_Any); i++) {
		if(StrEqual(arg, HEATMAP_IDS[i])) {
			return view_as<HeatMapType>(i);
		}
	}
	return HeatMap_Any;
}