#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <logger>

#pragma semicolon 1
#pragma newdecls required

#define CMD_LENGTH 128
#define MAX_BUFFER_LENGTH 1024

// 存储击杀数据的结构体
enum struct KillData {
    int client;         // 击杀者
    int victim;         // 被击杀者
    bool headshot;      // 是否爆头
    char weapon[32];    // 使用的武器
    float distance;     // 击杀距离
    int attackTicks;    // 攻击用的tick数
    float delta;        // 最大角度变化
    float total_delta;  // 总角度变化
    char targetInfo[64];// 目标信息
    float latency;      // 延迟
    float packetLoss;   // 丢包率
    char shotType[32];  // 射击类型
}

// 存储伤害数据的结构体
enum struct DamageData {
    int client;
    char targetInfo[64];
    char weapon[32];
    bool headshot;
    float damage;
    float distance;
    int attackTicks;
    float delta;
    float total_delta;
    float latency;
    float packetLoss;
}

// 全局变量
Logger log;                                            // 日志记录器
float g_PlayerAngles[MAXPLAYERS + 1][CMD_LENGTH][3];  // 玩家角度历史记录
float g_PlayerTimes[MAXPLAYERS + 1][CMD_LENGTH];      // 玩家时间历史记录
int g_PlayerButtons[MAXPLAYERS + 1][CMD_LENGTH];      // 玩家按键历史记录
int g_PlayerIndex[MAXPLAYERS + 1];                    // 玩家历史记录索引
bool g_IsMonitored[MAXPLAYERS + 1];                   // 玩家是否被监控
int g_MonitoringAdmin[MAXPLAYERS + 1];                // 监控该玩家的管理员

// 插件信息
public Plugin myinfo = {
    name = "Aim Monitor",
    author = "Hana",
    description = "Monitor player aim data",
    version = "1.6",
    url = "https://steamcommunity.com/profiles/76561197983870853/"
};

// 插件启动时注册命令和事件
public void OnPluginStart() {
    RegAdminCmd("sm_monitor", Command_Monitor, ADMFLAG_GENERIC, "开始监控指定玩家");
    RegAdminCmd("sm_mt", Command_Monitor, ADMFLAG_GENERIC, "开始监控指定玩家");
    RegAdminCmd("sm_unmonitor", Command_Unmonitor, ADMFLAG_GENERIC, "停止监控指定玩家");
    RegAdminCmd("sm_unmt", Command_Unmonitor, ADMFLAG_GENERIC, "停止监控指定玩家");
    
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("player_hurt", Event_PlayerHurt);

    log = new Logger("aim_monitor", LoggerType_NewLogFile);
}

// 地图开始时重置所有监控状态
public void OnMapStart() {
    for(int i = 1; i <= MaxClients; i++) {
        g_IsMonitored[i] = false;
        g_MonitoringAdmin[i] = 0;
        g_PlayerIndex[i] = 0;
        SDKUnhook(i, SDKHook_PostThinkPost, OnPlayerPostThinkPost);
    }
}

// 玩家断开连接时清理监控状态
public void OnClientDisconnect(int client) {
    g_IsMonitored[client] = false;
    g_MonitoringAdmin[client] = 0;
    g_PlayerIndex[client] = 0;
    SDKUnhook(client, SDKHook_PostThinkPost, OnPlayerPostThinkPost);
}

// 玩家进入服务器时初始化状态
public void OnClientPutInServer(int client) {
    g_IsMonitored[client] = false;
    g_MonitoringAdmin[client] = 0;
}

// 开始监控命令处理
public Action Command_Monitor(int client, int args) {
    if(args < 1) {
        PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x02用法: /monitor \"玩家\"");
        return Plugin_Handled;
    }
    
    char arg[65];
    GetCmdArg(1, arg, sizeof(arg));
    
    int target = FindTarget(client, arg, true);
    if(target == -1)
        return Plugin_Handled;
        
    if(g_IsMonitored[target]) {
        PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x01玩家 \x03%N \x01已经在被监控中", target);
        return Plugin_Handled;
    }
    
    if(IsValidClient(target)) {
        int team = GetClientTeam(target);
        if(team != 2) {
            PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x02只能监控生还者团队的玩家");
            return Plugin_Handled;
        }
    }

    char targetName[MAX_NAME_LENGTH];
    GetClientName(target, targetName, sizeof(targetName));
    
    g_IsMonitored[target] = true;
    g_MonitoringAdmin[target] = client;
    SDKHook(target, SDKHook_PostThinkPost, OnPlayerPostThinkPost);
    
    PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x01开始监控玩家 \x03%N", target);
    
    return Plugin_Handled;
}

// 停止监控命令处理
public Action Command_Unmonitor(int client, int args) {
    if(args < 1) {
        PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x02用法: /unmonitor \"玩家\"");
        return Plugin_Handled;
    }
    
    char arg[65];
    GetCmdArg(1, arg, sizeof(arg));
    
    int target = FindTarget(client, arg, true);
    if(target == -1)
        return Plugin_Handled;
        
    if(!g_IsMonitored[target]) {
        PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x01玩家 \x03%N \x01未被监控", target);
        return Plugin_Handled;
    }

    char adminName[MAX_NAME_LENGTH];
    GetClientName(client, adminName, sizeof(adminName));
    char targetName[MAX_NAME_LENGTH];
    GetClientName(target, targetName, sizeof(targetName));
    
    g_IsMonitored[target] = false;
    g_MonitoringAdmin[target] = 0;
    SDKUnhook(target, SDKHook_PostThinkPost, OnPlayerPostThinkPost);
    
    PrintToChat(client, "\x01[\x04Aim Monitor\x01] \x01停止监控玩家 \x03%N", target);
    
    return Plugin_Handled;
}

// 记录玩家的瞄准数据
public Action OnPlayerPostThinkPost(int client) {
    if(!IsValidClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2)
        return Plugin_Continue;
        
    if(!g_IsMonitored[client])
        return Plugin_Continue;
        
    int admin = g_MonitoringAdmin[client];
    if(!IsValidClient(admin)) {
        g_IsMonitored[client] = false;
        g_MonitoringAdmin[client] = 0;
        return Plugin_Continue;
    }
    
    float angles[3];
    GetClientEyeAngles(client, angles);
    
    int index = g_PlayerIndex[client];
    g_PlayerAngles[client][index] = angles;
    g_PlayerTimes[client][index] = GetGameTime();
    g_PlayerButtons[client][index] = GetClientButtons(client);
    
    if(++index >= CMD_LENGTH)
        index = 0;
    g_PlayerIndex[client] = index;
    
    return Plugin_Continue;
}

// 处理玩家死亡事件
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    bool headshot = event.GetBool("headshot");
    char weapon[32];
    event.GetString("weapon", weapon, sizeof(weapon));
    
    if(!IsValidClient(attacker) || !IsValidClient(victim))
        return;
        
    if(GetClientTeam(attacker) != 2)
        return;
        
    ProcessKill(attacker, victim, headshot, weapon);
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) {
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    float damage = event.GetFloat("dmg_health");
    
    // 基础验证
    if(!IsValidClient(attacker) || !g_IsMonitored[attacker]) {
        return;
    }
    
    if(!IsValidClient(victim) || GetClientTeam(victim) != 3) {
        return;
    }
    
    // 获取基础数据
    char weapon[32];
    event.GetString("weapon", weapon, sizeof(weapon));
    bool headshot = event.GetInt("hitgroup") == 1;
    
    float attackerPos[3], victimPos[3];
    GetClientEyePosition(attacker, attackerPos);
    GetClientEyePosition(victim, victimPos);
    float distance = GetVectorDistance(attackerPos, victimPos);
    
    // 分析伤害前的瞄准数据
    float delta = 0.0, total_delta = 0.0;
    int currentTick = g_PlayerIndex[attacker];
    int startTick = currentTick;
    float currentTime = GetGameTime();
    int attackTicks = 0;
    
    // 往前追溯200ms(约10tick)的数据
    for(int i = 0; i < CMD_LENGTH; i++) {
        if(--startTick < 0) 
            startTick = CMD_LENGTH - 1;
            
        // 只分析200ms内的数据
        if(currentTime - g_PlayerTimes[attacker][startTick] > 0.2)
            break;
            
        // 统计射击次数
        if(g_PlayerButtons[attacker][startTick] & IN_ATTACK)
            attackTicks++;
            
        if(i > 0) {
            int nextTick = (startTick + 1) % CMD_LENGTH;
            float tdelta = GetAngleDelta(g_PlayerAngles[attacker][startTick], g_PlayerAngles[attacker][nextTick]);
            if(tdelta > delta)
                delta = tdelta;
            total_delta += tdelta;
        }
    }
    
    // 构建数据并输出
    char targetInfo[64];
    int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
    char className[32];
    GetZombieClassName(zombieClass, className, sizeof(className));
    Format(targetInfo, sizeof(targetInfo), "%N(%s)", victim, className);
    
    DamageData data;
    data.client = attacker;
    strcopy(data.targetInfo, sizeof(data.targetInfo), targetInfo);
    strcopy(data.weapon, sizeof(data.weapon), weapon);
    data.headshot = headshot;
    data.damage = damage;
    data.distance = distance;
    data.attackTicks = attackTicks;
    data.delta = delta;
    data.total_delta = total_delta;
    data.latency = GetClientLatency(attacker, NetFlow_Both);
    data.packetLoss = GetClientAvgLoss(attacker, NetFlow_Both);
    
    int admin = g_MonitoringAdmin[attacker];
    if(IsValidClient(admin)) {
        PrintDamageData(admin, data);
        LogDamageData(data);
    }
}

// 处理击杀数据
void ProcessKill(int client, int victim, bool headshot, const char[] weapon) {
    if (StrEqual(weapon, "world", false) || client == victim) {
        return;
    }
    
    float killpos[3], victimpos[3];
    GetClientEyePosition(client, killpos);
    GetClientEyePosition(victim, victimpos);
    float distance = GetVectorDistance(killpos, victimpos);

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(GetClientUserId(victim));
    pack.WriteCell(headshot);
    pack.WriteString(weapon);
    pack.WriteCell(g_PlayerIndex[client]);
    pack.WriteFloat(distance);
    
    CreateTimer(0.05, Timer_ProcessKill, pack);
}

// 延迟处理击杀数据
public Action Timer_ProcessKill(Handle timer, DataPack pack) {
    pack.Reset();
    
    int client = GetClientOfUserId(pack.ReadCell());
    int victim = GetClientOfUserId(pack.ReadCell());
    bool headshot = pack.ReadCell();
    
    char weapon[32];
    pack.ReadString(weapon, sizeof(weapon));
    
    int fallback_index = pack.ReadCell();
    float distance = pack.ReadFloat();
    
    delete pack;

    if(!IsValidClient(client) || !IsValidClient(victim)) {
        return Plugin_Stop;
    }
    
    float delta = 0.0, total_delta = 0.0;
    int ind, shotindex = -1;
    bool foundShot = false;
    int attackTicks = 0;
    
    char targetInfo[64];
    int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
    if(zombieClass < 1 || zombieClass > 6) {
        return Plugin_Stop;
    }
    
    char className[32];
    GetZombieClassName(zombieClass, className, sizeof(className));
    Format(targetInfo, sizeof(targetInfo), "%N(%s)", victim, className);
    
    float tickInterval = GetTickInterval();
    int ticksPerSecond = RoundToCeil(1.0 / tickInterval);
    
    // 分析玩家的瞄准数据
    ind = g_PlayerIndex[client];
    for(int i = 0; i < ticksPerSecond; i++) {
        if(--ind < 0)
            ind = CMD_LENGTH - 1;
            
        if(GetGameTime() - g_PlayerTimes[client][ind] > 1.0)
            break;
            
        if(g_PlayerButtons[client][ind] & IN_ATTACK) {
            foundShot = true;
            attackTicks++;
            
            if(shotindex == -1)
                shotindex = ind;
        }
        else if(foundShot) {
            break;
        }
        
        if(i > 0 && shotindex != -1) {
            int nextInd = (ind + 1) % CMD_LENGTH;
            float tdelta = GetAngleDelta(g_PlayerAngles[client][ind], g_PlayerAngles[client][nextInd]);
            if(tdelta > delta)
                delta = tdelta;
            total_delta += tdelta;
        }
    }
    
    if(shotindex == -1) {
        shotindex = fallback_index;
    }

    // 构建击杀数据
    KillData data;
    data.client = client;
    data.victim = victim;
    data.headshot = headshot;
    strcopy(data.weapon, sizeof(data.weapon), weapon);
    data.distance = distance;
    data.attackTicks = attackTicks;
    data.delta = delta;
    data.total_delta = total_delta;
    strcopy(data.targetInfo, sizeof(data.targetInfo), targetInfo);
    data.latency = GetClientLatency(client, NetFlow_Both);
    data.packetLoss = GetClientAvgLoss(client, NetFlow_Both);

    if(attackTicks <= 1)
        Format(data.shotType, sizeof(data.shotType), "[1shot]%s", headshot ? "[爆头]" : "");
    else
        Format(data.shotType, sizeof(data.shotType), "%s", headshot ? "[爆头]" : "");

    int admin = g_MonitoringAdmin[client];
    if(!IsValidClient(admin))
        return Plugin_Stop;
        
    PrintKillData(admin, data);
    LogKillData(data);
    
    return Plugin_Stop;
}

void PrintDamageData(int admin, DamageData data) {
    PrintToChat(admin, "\x01[\x04Aim Info\x01] \x03%N\x01 伤害 \x04%s\x01 | 伤害:\x04%.1f\x01 射击Tick:\x04%d\x01 2帧角度:\x04%.1f\x01 总角度:\x04%.1f\x01",
        data.client,
        data.targetInfo,
        data.damage,
        data.attackTicks,
        data.delta,
        data.total_delta);
}

void LogDamageData(DamageData data) {
    if(!IsValidClient(data.client)) {
        return;
    }
    
    log.info(
        "[%N]伤害数据 目标:%s 武器:<%s%s> 伤害:%.1f 距离:%.1f 射击Tick:%d 2帧角度:%.1f 总角度:%.1f 延迟:%dms/%.1f%%",
        data.client,
        data.targetInfo,
        data.weapon,
        data.headshot ? "[爆头]" : "",
        data.damage,
        data.distance,
        data.attackTicks,
        data.delta,
        data.total_delta,
        RoundToNearest(data.latency * 1000.0),
        data.packetLoss);
}

// 向管理员显示击杀数据
void PrintKillData(int admin, KillData data) {
    char clientName[MAX_NAME_LENGTH];
    if(IsValidClient(data.client)) {
        GetClientName(data.client, clientName, sizeof(clientName));
    } else {
        strcopy(clientName, sizeof(clientName), "未知");
    }

    PrintToChat(admin, "\x01[\x04Aim Info\x01] \x03%s\x01 击杀 \x04%s\x01 | 射击Tick:\x04%d\x01 2帧角度:\x04%.1f\x01 总角度:\x04%.1f\x01",
        clientName,
        data.targetInfo,
        data.attackTicks,
        data.delta,
        data.total_delta);
}

// 记录击杀数据到日志
void LogKillData(KillData data) {
    if(!IsValidClient(data.client)) {
        return;
    }
    
    log.info(
        "[%N] 击杀数据 目标:%s 武器:<%s%s> 距离:%.1f 射击Tick:%d 2帧角度:%.1f 总角度:%.1f 延迟:%dms/%.1f%%",
        data.client,
        data.targetInfo,
        data.weapon,
        data.shotType,
        data.distance,
        data.attackTicks,
        data.delta,
        data.total_delta,
        RoundToNearest(data.latency * 1000.0),
        data.packetLoss);
}

// 获取特感类名
void GetZombieClassName(int zombieClass, char[] buffer, int maxlen) {
    switch(zombieClass) {
        case 1: strcopy(buffer, maxlen, "Smoker");
        case 2: strcopy(buffer, maxlen, "Boomer");
        case 3: strcopy(buffer, maxlen, "Hunter");
        case 4: strcopy(buffer, maxlen, "Spitter");
        case 5: strcopy(buffer, maxlen, "Jockey");
        case 6: strcopy(buffer, maxlen, "Charger");
        case 7: strcopy(buffer, maxlen, "Witch");
        case 8: strcopy(buffer, maxlen, "Tank");
        default: strcopy(buffer, maxlen, "Unknown");
    }
}

// 计算角度变化
float GetAngleDelta(float angles1[3], float angles2[3]) {
    float p1[3], p2[3], delta;
    
    p1[0] = angles1[0];
    p2[0] = angles2[0];
    p1[1] = angles1[1];
    p2[1] = angles2[1];
    
    p1[2] = 0.0;
    p2[2] = 0.0;
    
    delta = GetVectorDistance(p1, p2);
    
    int normal = 5;
    while(delta > 180.0 && normal > 0) {
        normal--;
        delta = FloatAbs(delta - 360.0);
    }
    
    return delta;
}

// 检查客户端是否有效
bool IsValidClient(int client) {
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}