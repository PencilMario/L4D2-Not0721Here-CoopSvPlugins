#include <sourcemod>
#include <logger>
KeyValues g_hModesKV;
char g_cConfigPath[PLATFORM_MAX_PATH];
ConVar g_cReadycfg;
ConVar g_CcfgLoadName;
Logger log
public void OnPluginStart(){
    log = new Logger("config_show");
    g_CcfgLoadName = CreateConVar("config_name", "");
    BuildPath(Path_SM, g_cConfigPath, sizeof(g_cConfigPath), "configs/matchmodes.txt");
    g_hModesKV = new KeyValues("MatchModes");
    if (!g_hModesKV.ImportFromFile(g_cConfigPath)) {
		SetFailState("Couldn't load matchmodes.txt!");
	}

    g_cReadycfg = FindConVar("l4d_ready_cfg_name");
    if (g_cReadycfg == null) g_cReadycfg = CreateConVar("l4d_ready_cfg_name", "Left 4 Dead 2", "Ready cvar", FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);
    g_CcfgLoadName = CreateConVar("config_name", "Left 4 Dead 2", "配置的键", FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);

    g_CcfgLoadName.AddChangeHook(OnConvarChanged);
}

bool FindConfigName(const char[] sConfig, char[] sName, const int iMaxLength)
{
	g_hModesKV.Rewind();

	if (g_hModesKV.GotoFirstSubKey()) {
		do {
			if (g_hModesKV.JumpToKey(sConfig)) {
				g_hModesKV.GetString("name", sName, iMaxLength);
				return true;
			}
		} while (g_hModesKV.GotoNextKey(false));
	}

	return false;
}

void OnConvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    char buffer[128];
    
    if (FindConfigName(newValue, buffer, sizeof(buffer))) g_cReadycfg.SetString(buffer);
    else {
        log.warning("无法找到该配置: %s", newValue);
        g_cReadycfg.GetDefault(buffer, sizeof(buffer));
        g_cReadycfg.SetString(buffer);
    }
}

