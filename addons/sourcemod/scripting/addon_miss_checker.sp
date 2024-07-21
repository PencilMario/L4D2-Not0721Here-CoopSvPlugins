#include <sourcemod>
#include <filenetwork>
#include <logger>

#define MAX_FEATURES 7

#pragma newdecls required

Logger log
enum QueueState
{
        QueueState_Ignore = 0,
        QueueState_Queued = 1,
}

enum struct FeatureState{
    bool hasfeature[MAX_FEATURES];
    int queue_id[MAX_FEATURES];
}

enum struct FeatureInfo{
    int feature_id;
    char feature_name[32];
    char feature_file[128];
    char feature_description[128];
    char download_url[128];
    bool use_valve_fs;
    char valve_path_id[32];
}

QueueState clientQueueState[MAXPLAYERS+1];
FeatureState clientFeatureState[MAXPLAYERS+1];
FeatureInfo featureInfo[MAX_FEATURES];

int currentQueueClient;
int currentQueueFeature;
int featureId = 0;
bool globalLocked = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("addAddonFeature", Native_AddAddonFeature);
	CreateNative("isClientHasAddonFeature", Native_AddAddonFeature);
	
	RegPluginLibrary("addon_miss_checker");

	return APLRes_Success;
}

public void OnPluginStart(){
    log = new Logger("mod_checker", LoggerType_NewLogFile);
    for(int client = 1; client<=MaxClients; client++)
        clientQueueState[client] = QueueState_Ignore;
}
public int Native_isClientHasAddonFeature(Handle plugin, int params){
    int client = GetNativeCell(1);
    int feature = GetNativeCell(2);
    return clientFeatureState[client].hasfeature[feature];
}
public int Native_AddAddonFeature(Handle plugin, int params){
    FeatureInfo info;
    GetNativeString(1, info.feature_name, sizeof(info.feature_name));
    GetNativeString(2, info.feature_file, sizeof(info.feature_file));
    GetNativeString(3, info.feature_description, sizeof(info.feature_description));
    GetNativeString(4, info.download_url, sizeof(info.download_url));
    featureInfo[featureId].use_valve_fs = GetNativeCell(5);
    GetNativeString(6, info.valve_path_id, sizeof(info.valve_path_id));
    featureInfo[featureId] = info;
    info.feature_id = featureId++;
    return featureInfo[featureId].feature_id;
}

public void OnClientDisconnect(int client){
    clientQueueState[client] = QueueState_Ignore;
}

public void OnClientPutInServer(int client){
    BeginScan(client);
}
public void OnMapStart(){
    CreateTimer(5.0, Timer_ProcessQueue, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}
void BeginScan(int client)
{
    CreateTimer(3.0, Timer_AppendClientToQueue, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action Timer_AppendClientToQueue(Handle tmr, int client)
{
        if(IsValidClient(client))
                clientQueueState[client] = QueueState_Queued;

        return Plugin_Continue;
}

public Action Timer_ProcessQueue(Handle tmr, any data)
{
        if(globalLocked)
                return Plugin_Continue;
        for(int client = 1; client<=MaxClients; client++)
        {
                if(!IsValidClient(client))
                        continue;

                if(clientQueueState[client] == QueueState_Queued)
                {
                        globalLocked = true;
                        currentQueueClient = client;
                        log.info("Timer_ProcessQueue::Processing client %d", client);
                        StartProcessingClient(client);
                        return Plugin_Continue;
                }
        }
        return Plugin_Continue;
}

public Action Timer_ProcessFeature(Handle tmr, int client)
{
        if(globalLocked)
                return Plugin_Continue;
        for(int feature = 0; feature<=MAX_FEATURES; feature++)
        {
            if (FileExists(featureInfo[feature].feature_file, featureInfo[feature].use_valve_fs, featureInfo[feature].valve_path_id)){
                bool res = DeleteFile(featureInfo[feature].feature_file, featureInfo[feature].use_valve_fs, featureInfo[feature].valve_path_id);
                log.info("Timer_ProcessFeature::Deleting file in server %s result %i", featureInfo[feature].feature_file, res);
            }
                clientFeatureState[client].queue_id[feature] = FileNet_RequestFile(client, featureInfo[feature].feature_file, HandleRequestFileResult, feature);
        }
}

public void HandleRequestFileResult(int client, const char[] file, int id, bool success, int feature){
    log.info("FileNet_RequestFileResult::Client %d file %s id %d success %i feature %i", client, file, id, success, feature);
    if (success){
        if (FileExists(featureInfo[feature].feature_file, featureInfo[feature].use_valve_fs, featureInfo[feature].valve_path_id)){
            clientFeatureState[client].hasfeature[feature] = true;
        }
    }
    clientFeatureState[client].hasfeature[feature] = false;
    clientFeatureState[client].queue_id[feature] = 0;
    for (int i = 0; i<MAX_FEATURES; i++){
        if (clientFeatureState[client].queue_id[i] != 0){
            return;
        }
    }
    globalLocked = false;

}

void StartProcessingClient(int client)
{
    CreateTimer(3.0, Timer_ProcessFeature, client, TIMER_FLAG_NO_MAPCHANGE);
}

stock bool IsValidClient(int client, bool botcheck = true)
{
	return (1 <= client && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (botcheck ? !IsFakeClient(client) : true));
}

public void showMissMenu(int client){
    Menu menu = new Menu();
    menu.SetTitle(">>> 模组缺失 <<<\n为了保护你的游戏体验, 相关功能已对你禁用, 选择以查看信息");
}