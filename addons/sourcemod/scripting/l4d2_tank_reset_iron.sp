#define MAX_HITTABLES 2048
#include <logger>
//#include <l4d2_hittable_control>
// 铁坐标
float g_HittableOrigin[MAX_HITTABLES][3];
// 铁角度
float g_HittableAngle[MAX_HITTABLES][3];
int Hittables[100];
bool g_bHittableControlExists;
Logger log;

public void OnPluginStart(){
	log = new Logger("tank_reset_iron", LoggerType_NewLogFile);
	log.info("安可sb")
	RegConsoleCmd("sm_resetprop", CMD_ResetProps);
}    
public void OnMapStart(){
	SaveTankProps()
}
public Action CMD_ResetProps(int client, int args){
	ResetAllTankProps();
	return Plugin_Handled;
}
void SaveTankProps()
{
	log.info("SaveTankProps")
	int iEntCount = GetMaxEntities();
	for (int i = MaxClients; i < iEntCount; i++) {
		if (IsTankProp(i)) {
			// 保存铁的位置
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", g_HittableOrigin[i])
			GetEntPropVector(i, Prop_Send, "m_angRotation", g_HittableAngle[i]); 
			log.info("保存铁%i - pos: %.2f, %.2f, %.2f | ang %.2f, %.2f, %.2f", i,g_HittableOrigin[i][0],g_HittableOrigin[i][1],g_HittableOrigin[i][2],
				g_HittableAngle[i][0], g_HittableAngle[i][1], g_HittableAngle[i][2])
		}
	}
}
void ResetAllTankProps(){
	log.info("SaveTankProps")
	int iEntCount = GetMaxEntities();
	for (int i = MaxClients; i < iEntCount; i++) {
		if (IsTankProp(i)) {
			// 保存铁的位置
			SetEntPropVector(i, Prop_Send, "m_vecOrigin", g_HittableOrigin[i]);
			SetEntPropVector(i, Prop_Send, "m_angRotation", g_HittableAngle[i]);
			log.info("还原铁%i - pos: %.2f, %.2f, %.2f | ang %.2f, %.2f, %.2f", i,g_HittableOrigin[i][0],g_HittableOrigin[i][1],g_HittableOrigin[i][2],
				g_HittableAngle[i][0], g_HittableAngle[i][1], g_HittableAngle[i][2])
		}
	}

}
public void OnAllPluginsLoaded()
{
	g_bHittableControlExists = LibraryExists("l4d2_hittable_control");
}

bool IsTankProp(int iEntity)
{
	if (!IsValidEdict(iEntity)) {
		return false;
	}

	// CPhysicsProp only
	if (!HasEntProp(iEntity, Prop_Send, "m_hasTankGlow")) {
		return false;
	}

	bool bHasTankGlow = (GetEntProp(iEntity, Prop_Send, "m_hasTankGlow", 1) == 1);
	if (!bHasTankGlow) {
		return false;
	}

	// Exception
	bool bAreForkliftsUnbreakable = true;
	//if (g_bHittableControlExists)
	//{
	//	bAreForkliftsUnbreakable = AreForkliftsUnbreakable();
	//}
	//else
	//{
	//	bAreForkliftsUnbreakable = false;
	//}

	char sModel[PLATFORM_MAX_PATH];
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if (strcmp("models/props/cs_assault/forklift.mdl", sModel) == 0 && bAreForkliftsUnbreakable == false) {
		return false;
	}

	return true;
}
