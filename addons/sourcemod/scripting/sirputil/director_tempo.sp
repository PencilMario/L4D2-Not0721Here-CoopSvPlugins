#include <left4dhooks>
Address g_pDirector;
GameData g_hGameData_uDirector;
GameData g_hGameData_dhook;

int m_iTempoState_offset;
int m_ChangeTempoTimer_offset;//ctimer
int m_fMobSpawnSize_offset;
int m_flEndFadeFlowDistance_offset;

enum DirectorTempoState
{
    TEMPO_BUILDUP = 0,
    TEMPO_SUSTAIN_PEAK = 1,
    TEMPO_PEAK_FADE = 2,
    TEMPO_RELAX = 3
};

void LoadSPDirectorData()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/%s.txt", "left4dhooks.l4d2");
    if(FileExists(sPath) == false) 
        SetFailState("\n==========\nMissing required file: \"%s\".\n==========", sPath);
    g_hGameData_dhook = LoadGameConfigFile("left4dhooks.l4d2")

    BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/%s.txt", "sp_director");
    if(FileExists(sPath) == false) 
        SetFailState("\n==========\nMissing required file: \"%s\".\n==========", sPath);
    g_hGameData_uDirector = LoadGameConfigFile("sp_director")

    g_pDirector = g_hGameData_dhook.GetAddress("CDirector");
    if (!g_pDirector) SetFailState("Failed to get CDirector");

    m_iTempoState_offset = g_hGameData_uDirector.GetOffset("CDirector::m_iTempoState") + view_as<int>(g_pDirector);
    if (m_iTempoState_offset - view_as<int>(g_pDirector) <= 0) SetFailState("Failed to get CDirector::m_iTempoState");
    m_ChangeTempoTimer_offset = g_hGameData_uDirector.GetOffset("CDirector::m_ChangeTempoTimer") + view_as<int>(g_pDirector);
    if (m_ChangeTempoTimer_offset - view_as<int>(g_pDirector) <= 0) SetFailState("Failed to get CDirector::m_ChangeTempoTimer");
    m_fMobSpawnSize_offset = g_hGameData_uDirector.GetOffset("CDirector::m_fMobSpawnSize") + view_as<int>(g_pDirector);
    if (m_fMobSpawnSize_offset - view_as<int>(g_pDirector) <= 0) SetFailState("Failed to get CDirector::m_fMobSpawnSize");
    m_flEndFadeFlowDistance_offset = g_hGameData_uDirector.GetOffset("CDirector::m_flEndFadeFlowDistance") + view_as<int>(g_pDirector);
    if (m_flEndFadeFlowDistance_offset - view_as<int>(g_pDirector) <= 0) SetFailState("Failed to get CDirector::m_flEndFadeFlowDistance");


}


public CountdownTimer Direct_GetChangeTempoTimer(){
    //ValidateAddress(g_pDirector, "g_pDirector");
    //ValidateOffset(m_ChangeTempoTimer_offset, "CDirector::m_ChangeTempoTimer");
    return view_as<CountdownTimer>(view_as<Address>(m_ChangeTempoTimer_offset));
}   

public float Direct_GetMobSize(){
    //ValidateAddress(g_pDirector, "g_pDirector");
    //ValidateOffset(m_fMobSpawnSize_offset, "CDirector::m_fMobSpawnSize");
    float num = view_as<float>(LoadFromAddress(view_as<Address>(m_fMobSpawnSize_offset), NumberType_Int32));
    return num > 0.0 ? num : 0.0;
}
public float Direct_GetEndFadeFlowDistance(){
    //ValidateAddress(g_pDirector, "g_pDirector");
    //ValidateOffset(m_fMobSpawnSize_offset, "CDirector::m_fMobSpawnSize");
    float num = view_as<float>(LoadFromAddress(view_as<Address>(m_flEndFadeFlowDistance_offset), NumberType_Int32));
    return num > 0.0 ? num : 0.0;
}
public DirectorTempoState Direct_GetCurrentState()
{
    //ValidateAddress(g_pDirector, "g_pDirector");
    //ValidateOffset(m_iTempoState_offset, "CDirector::m_iTempoState");
    
    return view_as<DirectorTempoState>(LoadFromAddress(view_as<Address>(m_iTempoState_offset), NumberType_Int32));

}

