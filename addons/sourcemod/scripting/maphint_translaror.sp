#include <sourcemod>
#include <sdkhooks>
#pragma semicolon 1
#pragma newdecls required
#include <logger>
bool isHint[2048];
char buffer[128];
Logger log;
public Plugin myinfo =
{
	name = "Map Hint Translator",
	author = "AlliedModders LLC",
	description = "翻译三方图的提示",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart(){
	log = new Logger("map_hint_translator", LoggerType_NewLogFile);
	log.logfirst("test");
}


public void OnMapStart(){
	char maxname[32];
	for(int i = 1; i <= 2048; i++){
		GetEntityClassname(i, maxname, sizeof(maxname));
		if(strcmp(maxname, "env_instructor_hint") == 0){
			isHint[i] = true;
			get_hint_text(i, buffer, sizeof(buffer));
			log.info("Find env_instructor_hint: %i:%s", i, buffer);
		}
	}
}

public void get_hint_text(int index, char[] text, int maxlength){
	if(isHint[index]){
		GetEntPropString(index, Prop_Send ,"m_iszCaption", text, maxlength);
	}
}

public void OnEntityCreated(int entity, const char[] classname){
	if(StrEqual(classname, "env_instructor_hint")){
		get_hint_text(entity, buffer, sizeof(buffer));
		log.info("OnEntityCreated env_instructor_hint: %i:%s", entity, buffer);
	}
}
