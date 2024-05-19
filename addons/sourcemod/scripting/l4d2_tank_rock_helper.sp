#pragma semicolon 1
#pragma newdecls required

#define MAX_CAL_TIME 6.5

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
enum
{
    BLOCK_TYPE_EVERYONE,
    BLOCK_TYPE_SURVIVORS,
    BLOCK_TYPE_PLAYER_INFECTED,
    BLOCK_TYPE_ALL_INFECTED,
    BLOCK_TYPE_ALL_PLAYERS_AND_PHYSICS_OBJECTS
};
int g_iTankRockOwner[MAXPLAYERS];
int Sprite1;
enum struct TankRock {
    float pos[3];
    float vec[3];
}
ArrayList g_iRockThrowQueue;
TankRock g_iTankRock[MAXPLAYERS];
float g_fClientViewang[MAXPLAYERS][3];
static const char validEntityName[][] =
{
    "prop_dynamic",
    "prop_physics",
    "prop_physics_multiplayer",
    "func_rotating",
    "infected",
    "tank_rock",
    "witch"
};
public Plugin myinfo = 
{
    name = "[L4D2] tank 计算石头轨迹",
    author = "Sir.P",
    description = "在tank丢饼时，计算石头的轨迹和落点",
    version = "1.0.1",
    url = "https://github.com/SirPlease/L4D2-Competitive-Rework"
}
public void OnPluginStart(){
    g_iRockThrowQueue = new ArrayList();
}
public void OnPluginEnd(){
    CloseHandle(g_iRockThrowQueue);
}
public void OnMapStart(){
    Sprite1 = PrecacheModel("materials/sprites/laserbeam.vmt");   
}
public Action L4D2_OnSelectTankAttack(int client, int &sequence){
    if (sequence>=48)
    g_iRockThrowQueue.Push(client);
    return Plugin_Continue;
}
public void OnEntityCreated(int Entity, const char[] Classname)
{
    if (!strcmp(Classname, "tank_rock")) return;
    int owner = g_iRockThrowQueue.Get(0);
    if (owner) {
        g_iRockThrowQueue.Erase(0);
    }
    g_iTankRockOwner[owner] = Entity;
    SDKHook(Entity, SDKHook_Think, OnThrowing);
}

int GetWhoOwnedRock(int ientity){
    for (int i = 1; i <= MaxClients; i++){
        if (IsClientInGame(i)){
            if (g_iTankRockOwner[i] == ientity) return i;
        }
    }
    return 0;
}

public void OnThrowing(int entity){
    int client = GetWhoOwnedRock(entity);
    if (!IsClientInGame(client)) return;
    //获取当前玩家视线方向矢量
    GetClientEyeAngles(client, g_fClientViewang[client]);
    GetAngleVectors(g_fClientViewang[client], g_fClientViewang[client], NULL_VECTOR, NULL_VECTOR);
    //计算tank出手力度
    ResetVectorLength(g_fClientViewang[client], 800.0);
    // 开始绘制曲线
    // 获取石头位置
    TankRock thisRock, StartPos, EndPos;

    //石头初始速度
    GetEntPropVector(entity, Prop_Send, "m_vecVelocity", thisRock.vec);
    bool throwed = GetVectorLength(thisRock.vec) > 0.0;
    GetClientAbsAngles(client, thisRock.vec);
    PrintToConsoleAll("OnThrowing:GetClientAbsAngles %f, %f, %f | Rock %N:%i", thisRock.vec[0], thisRock.vec[1], thisRock.vec[2], client, entity);
    ResetVectorLength(thisRock.vec, 800.0);
    //石头初始坐标
    if (!throwed){
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", thisRock.pos);
        g_iTankRock[client] = thisRock;
    }
    else{        // 已经出手，用出手前瞬间的数据
        thisRock = g_iTankRock[client];
    }    
    for (float i = 0.0; i+=0.1; i <= MAX_CAL_TIME){
        // 计算下0.1秒的tank石头位置
        StartPos = GetRockPos(thisRock, i);
        EndPos = GetRockPos(thisRock, i+0.1);
        // 向终点发出射线 预测是否可能碰撞
        Handle trace = TR_TraceRayFilterEx(StartPos.pos, EndPos.pos, MASK_NPCSOLID_BRUSHONLY,RayType_EndPoint,traceRayFilter);
        if (trace == null) break;
        // 如果碰撞，射线终点即为石头命中点
        if (TR_DidHit(trace)){
            TR_GetEndPosition(EndPos.pos, trace);
        }
        delete trace;
        // 绘制起点与终点连线
        TE_SetupBeamPoints(StartPos.pos, EndPos.pos, Sprite1, 0, 0, 1, 0.1, 2.0, 2.0,  1, 1.5, {75, 75, 255, 255}, 10);
    }
    return;
}

static bool traceRayFilter(int entity, int contentsMask, any data)
{
    // 射线撞击到自身或客户端实体，不允许穿过
    if (entity == data || (entity >= 1 && entity <= MaxClients)) { return false; }
    // 撞击到其他实体，检测类型
    static char className[64];
    GetEntityClassname(entity, className, sizeof(className));
    if (checkRayImpactEntityValid(className)) { return false; }
    // blocker 类型的，获取是否阻塞与阻塞类型
    if (strcmp(className, "env_physics_blocker") == 0 || strcmp(className, "env_player_blocker") == 0)
    {
        if (!HasEntProp(entity, Prop_Send, "m_bBlocked")) { return false; }
        if (GetEntProp(entity, Prop_Send, "m_bBlocked") != 1) { return true; }
        static int blockType;
        blockType = GetEntProp(entity, Prop_Send, "m_nBlockType");
        return (blockType == BLOCK_TYPE_SURVIVORS || blockType == BLOCK_TYPE_PLAYER_INFECTED);
    }
    return true;
}

static bool checkRayImpactEntityValid(const char[] className)
{
    static int i;
    for (i = 0; i < sizeof(validEntityName); i++)
    {
        if (strcmp(className, validEntityName[i]) == 0) { return false; }
    }
    return true;
}
// 获取石头
TankRock GetRockPos(TankRock rock, float time){
    TankRock result;
    result.pos[0] = rock.pos[0] + rock.vec[0] * time;
    result.pos[1] = rock.pos[1] + rock.vec[1] * time;
    result.pos[2] = rock.pos[2] + rock.vec[2] * time;

    result.vec = rock.vec;
    result.vec[2] -= 300.0 * time; //垂直速度-300/s 估计值
    return result;
}
void ResetVectorLength(float vector[3], float targetlength){
    float currentLength = GetVectorLength(vector);
    float factor = targetlength / currentLength;
    vector[0] = vector[0] * factor;
    vector[1] = vector[1] * factor;
    vector[2] = vector[2] * factor;
}