#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <logger>

Logger HintLog;
char curmap[64];
enum HintEntClass{
    info_target_instructor_hint,
    env_instructor_hint,
    HintEntClass_Size
}


static const char HintEntityClassName[HintEntClass_Size][128] = {
    "info_target_instructor_hint",
    "env_instructor_hint"
}
public void OnMapStart(){
    GetCurrentMap(curmap, sizeof(curmap));
}

public void OnPluginStart(){
    HintLog = new Logger("HintLog", LoggerType_NewLogFile);
    if (HintLog.FileSize > 10*1024*1024) HintLog.DelLogFile();// 10M
}

public void OnEntityCreated(int iEntity, const char[] sClassname){
    if (StrEqual(HintEntityClassName[env_instructor_hint], sClassname)) {
        HintLog.info("实体：%s / %i 地图：%s", HintEntityClassName[env_instructor_hint], iEntity, curmap);
        char buffer[128];
        if (HasEntProp(iEntity, Prop_Data, "m_iszCaption"))
        {
            GetEntPropString(iEntity, Prop_Data, "m_iszCaption", buffer, sizeof(buffer));
            HintLog.info("m_iszCaption(hint_caption): %s", buffer);
        }else{
            HintLog.info("实体无Prop: \"m_iszCaption\"");
        }

        if (HasEntProp(iEntity, Prop_Data, "hint_caption"))
        {
            GetEntPropString(iEntity, Prop_Data, "hint_caption", buffer, sizeof(buffer));
            HintLog.info("hint_caption(hint_caption): %s", buffer);
        }else{
            HintLog.info("实体无Prop: \"hint_caption\"");
        }
    }
}