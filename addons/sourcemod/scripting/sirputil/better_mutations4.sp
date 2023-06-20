#include <left4dhooks>
bool g_bFixUnlimitSpawnsEnable = true;


void CheckValues()
{
    ConVar c_GameMode = FindConVar("mp_gamemode");
    char mode[32]
    c_GameMode.GetString(mode, sizeof(mode));
    if (StrEqual("mutations4", mode)) g_bFixUnlimitSpawnsEnable = true;
}

/*public Action L4D2_OnGetScriptValueFloat(const char[] key, float &retVal, int hScope)
{
    //PrintToConsoleAll("L4D2_OnGetScriptValueFloat: %s", key);
    if (!g_bFixUnlimitSpawnsEnable) return Plugin_Continue;

    return Plugin_Continue;
}*/

public Action L4D2_OnGetScriptValueInt(const char[] key, int &retVal, int hScope)
{   
    if (!g_bFixUnlimitSpawnsEnable) return Plugin_Continue;
    if (StrEqual("ShouldAllowSpecialsWithTank", key)){
        if (retVal != 0) { retVal = 0; return Plugin_Handled;}
    }
    if (StrEqual("RelaxMaxInterval", key)){
        if (retVal != 45) {retVal = 45; return Plugin_Handled;}
    }
    if (StrEqual("RelaxMinInterval", key)){
        if (retVal < 15) {retVal = 15; return Plugin_Handled;}
    }
    if (StrEqual("LockTempo", key)){
        if (retVal != 0) {retVal = 0; return Plugin_Handled;}
    }
    return Plugin_Continue;
}

/*public Action L4D2_OnGetScriptValue(const char[] key, fieldtype_t &type, VariantBuffer retVal, int hScope)
{
    if (!g_bFixUnlimitSpawnsEnable) return Plugin_Continue;
    PrintToConsoleAll("L4D2_OnGetScriptValue: %s", key);
    if (type == FIELD_BOOLEAN){
        
        if (StrEqual("ShouldAllowSpecialsWithTank", key)){
        if (retVal.m_int != 0) {type = FIELD_INTEGER; retVal.m_int = 0; return Plugin_Handled;}
        }
    }
    return Plugin_Continue;
}*/