void CreateAllSDKCalls(Handle hGameData)
{
	if ((g_iNavArea_Center = GameConfGetOffset(hGameData, "CNavArea::m_center")) == -1)
		SetFailState("Failed to get CNavArea::m_center offset.");
	if ((g_iNavArea_Parent = GameConfGetOffset(hGameData, "CNavArea::m_parent")) == -1)
		SetFailState("Failed to get CNavArea::m_parent offset.");
	if ((g_iNavArea_NWCorner = GameConfGetOffset(hGameData, "CNavArea::m_nwCorner")) == -1)
		SetFailState("Failed to get CNavArea::m_nwCorner offset.");
	if ((g_iNavArea_SECorner = GameConfGetOffset(hGameData, "CNavArea::m_seCorner")) == -1)
		SetFailState("Failed to get CNavArea::m_seCorner offset.");
	if ((g_iNavArea_InvDXCorners = GameConfGetOffset(hGameData, "CNavArea::m_invDxCorners")) == -1)
		SetFailState("Failed to get CNavArea::m_invDxCorners offset.");
	if ((g_iNavArea_InvDYCorners = GameConfGetOffset(hGameData, "CNavArea::m_invDyCorners")) == -1)
		SetFailState("Failed to get CNavArea::m_invDyCorners offset.");
	if ((g_iNavArea_DamagingTickCount = GameConfGetOffset(hGameData, "CNavArea::m_damagingTickCount")) == -1)
		SetFailState("Failed to get CNavArea::m_damagingTickCount offset.");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseEntity::CalcAbsolutePosition");
	if ((g_hCalcAbsolutePosition = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseEntity::CalcAbsolutePosition signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "CBaseCombatWeapon::GetMaxClip1");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hGetMaxClip1 = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseCombatWeapon::GetMaxClip1 virtual!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SurvivorBot::IsReachable<CNavArea>");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsReachableNavArea = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SurvivorBot::IsReachable<CNavArea> signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SurvivorBot::IsAvailable");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsAvailable = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SurvivorBot::IsAvailable signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::FindUseEntity");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hFindUseEntity = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CTerrorPlayer::FindUseEntity signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::IsInCombat");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsInCombat = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CTerrorPlayer::IsInCombat signature!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CNavArea::MarkAsBlocked");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hMarkNavAreaAsBlocked = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CNavArea::MarkAsBlocked signature!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SurvivorLegsRetreat::SurvivorLegsRetreat");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hSurvivorLegsRetreat = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SurvivorLegsRetreat::SurvivorLegsRetreat signature!");

}

Handle g_hOnFindUseEntity;
Handle g_hOnInfernoTouchNavArea;
Handle g_hOnGetAvoidRange;

void CreateAllDetours(Handle hGameData)
{
	g_hOnFindUseEntity = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_CBaseEntity, ThisPointer_CBaseEntity);
	if (!g_hOnFindUseEntity)SetFailState("Failed to setup detour for CTerrorPlayer::FindUseEntity");
	if (!DHookSetFromConf(g_hOnFindUseEntity, hGameData, SDKConf_Signature, "CTerrorPlayer::FindUseEntity"))
		SetFailState("Failed to load CTerrorPlayer::FindUseEntity signature from gamedata");
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Float);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Float);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Float);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Bool);
	DHookAddParam(g_hOnFindUseEntity, HookParamType_Bool);
	if (!DHookEnableDetour(g_hOnFindUseEntity, true, DTR_OnFindUseEntity))
		SetFailState("Failed to detour CTerrorPlayer::FindUseEntity.");

	g_hOnInfernoTouchNavArea = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_CBaseEntity);
	if (!g_hOnInfernoTouchNavArea)SetFailState("Failed to setup detour for CInferno::IsTouching<CNavArea>");
	if (!DHookSetFromConf(g_hOnInfernoTouchNavArea, hGameData, SDKConf_Signature, "CInferno::IsTouching<CNavArea>"))
		SetFailState("Failed to load CInferno::IsTouching<CNavArea> signature from gamedata");
	DHookAddParam(g_hOnInfernoTouchNavArea, HookParamType_Int);
	if (!DHookEnableDetour(g_hOnInfernoTouchNavArea, true, DTR_OnInfernoTouchNavArea))
		SetFailState("Failed to detour CInferno::IsTouching<CNavArea>.");

	g_hOnGetAvoidRange = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Float, ThisPointer_CBaseEntity);
	if (!g_hOnGetAvoidRange)SetFailState("Failed to setup detour for SurvivorBot::GetAvoidRange");
	if (!DHookSetFromConf(g_hOnGetAvoidRange, hGameData, SDKConf_Signature, "SurvivorBot::GetAvoidRange"))
		SetFailState("Failed to load SurvivorBot::GetAvoidRange signature from gamedata");
	DHookAddParam(g_hOnGetAvoidRange, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(g_hOnGetAvoidRange, true, DTR_OnSurvivorBotGetAvoidRange))
		SetFailState("Failed to detour SurvivorBot::GetAvoidRange.");
}

bool ParseDataFile()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/ib_data.cfg");
	if( FileExists(sPath) == false )
		SetFailState("\n==========\n[IB] Missing required file: \"%s\".\n==========", sPath);

	g_hWeaponToIDMap = CreateTrie();
	g_hWeaponMdlMap = CreateTrie();
	g_hMeleeMdlToID = CreateTrie();
	g_hMeleePref = CreateTrie();
	g_iDataFileSection = 0;

	SMCParser parser = new SMCParser();
	parser.OnEnterSection = DataFile_NewSection;
	parser.OnKeyValue = DataFile_KeyValue;
	parser.OnLeaveSection = DataFile_EndSection;
	parser.OnEnd = DataFile_End;

	char error[128];
	int line = 0, col = 0;
	SMCError result = parser.ParseFile(sPath, line, col);

	if( result != SMCError_Okay )
	{
		parser.GetErrorString(result, error, sizeof(error));
		SetFailState("%s on line %d, col %d of %s [%d]", error, line, col, sPath, result);
	}

	delete parser;
	return (result == SMCError_Okay);
}

SMCResult DataFile_NewSection(SMCParser parser, const char[] section, bool quotes)
{
	g_iDataFileValueID = 0;
	return SMCParse_Continue;
}

SMCResult DataFile_KeyValue(SMCParser parser, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	static int iValue;

	switch(g_iDataFileSection)
	{
		case 0:
		{
			iValue = StringToInt(value);
			//PrintToServer("ParseDataFile %s %d", key, iValue);
			g_hMeleePref.SetValue(key, iValue);
		}
		case 1:
		{
			strcopy( IBWeaponName[g_iDataFileValueID], 32, key );
			g_hWeaponToIDMap.SetValue(key, view_as<L4D2WeaponId>(g_iDataFileValueID));
			g_iDataFileValueID++;
		}
		case 2:
		{
			g_hWeaponMdlMap.SetString(key, value);
		}
		case 3:
		{
			g_hMeleeMdlToID.SetString(key, value);
		}
	}

	return SMCParse_Continue;
}

SMCResult DataFile_EndSection(SMCParser parser)
{
	g_iDataFileSection++;
	return SMCParse_Continue;
}

void DataFile_End(SMCParser parser, bool halted, bool failed)
{
	if( failed )
		SetFailState("Error: could not load data file.");
}

void CreateVScriptCommandDetour()
{
	g_vsCommand = VScript_CreateGlobalFunction("L4B_CommandIssued");
	g_vsCommand.SetParam(1, FIELD_INTEGER);
	g_vsCommand.SetParam(2, FIELD_INTEGER);
	g_vsCommand.SetParam(3, FIELD_INTEGER);
	g_vsCommand.Return = FIELD_BOOLEAN;
	g_vsCommand.SetFunctionEmpty();
	g_vsCommand.CreateDetour().Enable(Hook_Post, Detour_CommandIssued);
}
