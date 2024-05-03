#if !defined _SENDPROXYMANAGER_INC_
#define _SENDPROXYMANAGER_INC_

#define SENDPROXY_LIB "sendproxy13"

enum SendPropType {
	Prop_Int,
	Prop_Float,
	Prop_String,
	Prop_Vector = 4,
	Prop_Max
};

typeset SendProxyCallback
{
	function Action (const int iEntity, const char[] cPropName, int &iValue, const int iElement, const int iClient); //Prop_Int
	function Action (const int iEntity, const char[] cPropName, float &flValue, const int iElement, const int iClient); //Prop_Float
	function Action (const int iEntity, const char[] cPropName, char cModifiedValue[4096], const int iElement, const int iClient); //Prop_String
	function Action (const int iEntity, const char[] cPropName, float vecValues[3], const int iElement, const int iClient); //Prop_Vector
};

typeset SendProxyCallbackGamerules
{
	function Action (const char[] cPropName, int &iValue, const int iElement, const int iClient); //Prop_Int
	function Action (const char[] cPropName, float &flValue, const int iElement, const int iClient); //Prop_Float
	function Action (const char[] cPropName, char cModifiedValue[4096], const int iElement, const int iClient); //Prop_String
	function Action (const char[] cPropName, float vecValues[3], const int iElement, const int iClient); //Prop_Vector
};

typeset PropChangedCallback
{
	function void(const int iEntity, const char[] cPropName, const int iOldValue, const int iNewValue, const int iElement); //Prop_Int
	function void(const int iEntity, const char[] cPropName, const float flOldValue, const float flNewValue, const int iElement); //Prop_Int
	function void(const int iEntity, const char[] cPropName, const char[] cOldValue, const char[] cNewValue, const int iElement); //Prop_String
	function void(const int iEntity, const char[] cPropName, const float vecOldValue[3], const float vecNewValue[3], const int iElement); //Prop_Vector
};

typeset GameRulesPropChangedCallback
{
	function void(const char[] cPropName, const int iOldValue, const int iNewValue, const int iElement); //Prop_Int
	function void(const char[] cPropName, const float flOldValue, const float flNewValue, const int iElement); //Prop_Int
	function void(const char[] cPropName, const char[] cOldValue, const char[] cNewValue, const int iElement); //Prop_String
	function void(const char[] cPropName, const float vecOldValue[3], const float vecNewValue[3], const int iElement); //Prop_Vector
};

//Returns true upon success, false upon failure
native bool SendProxy_Hook(const int iEntity, const char[] cPropName, const SendPropType stType, const SendProxyCallback pCallback);
native bool SendProxy_HookGameRules(const char[] cPropName, const SendPropType stType, const SendProxyCallbackGamerules pCallback);
native bool SendProxy_HookArrayProp(const int iEntity, const char[] cPropName, const int iElement, const SendPropType stType, const SendProxyCallback pCallback);
native bool SendProxy_UnhookArrayProp(const int iEntity, const char[] cPropName, const int iElement, const SendPropType stType, const SendProxyCallback pCallback);
native bool SendProxy_Unhook(const int iEntity, const char[] cPropName, const SendProxyCallback pCallback);
native bool SendProxy_UnhookGameRules(const char[] cPropName, const SendProxyCallbackGamerules pCallback);
native bool SendProxy_IsHooked(const int iEntity, const char[] cPropName);
native bool SendProxy_IsHookedGameRules(const char[] cPropName);
native bool SendProxy_HookArrayPropGamerules(const char[] cPropName, const int iElement, const SendPropType stType, const SendProxyCallbackGamerules pCallback);
native bool SendProxy_UnhookArrayPropGamerules(const char[] cPropName, const int iElement, const SendPropType stType, const SendProxyCallbackGamerules pCallback);
native bool SendProxy_IsHookedArrayProp(const int iEntity, const char[] cPropName, const int iElement);
native bool SendProxy_IsHookedArrayPropGamerules(const char[] cPropName, const int iElement);

//Deprecated functions
//here SendPropType is autodetected, this may be unsafe now
#pragma deprecated Use SendProxy_HookPropChangeSafe instead.
native bool SendProxy_HookPropChange(const int iEntity, const char[] cPropName, const PropChangedCallback pCallback);
#pragma deprecated Use SendProxy_HookPropChangeGameRulesSafe instead.
native bool SendProxy_HookPropChangeGameRules(const char[] cPropName, const GameRulesPropChangedCallback pCallback);

native bool SendProxy_HookPropChangeSafe(const int iEntity, const char[] cPropName, const SendPropType stType, const PropChangedCallback pCallback);
native bool SendProxy_HookPropChangeGameRulesSafe(const char[] cPropName, const SendPropType stType, const GameRulesPropChangedCallback pCallback);
native bool SendProxy_HookPropChangeArray(const int iEntity, const char[] cPropName, const int iElement, const SendPropType stType, const PropChangedCallback pCallback);
native bool SendProxy_HookPropChangeArrayGameRules(const char[] cPropName, const int iElement, const SendPropType stType, const PropChangedCallback pCallback);
native bool SendProxy_IsPropChangeHooked(const int iEntity, const char[] cPropName);
native bool SendProxy_IsPropChangeHookedGameRules(const char[] cPropName);
native bool SendProxy_IsPropChangeArrayHooked(const int iEntity, const char[] cPropName, const int iElement);
native bool SendProxy_IsPropChangeArrayHookedGameRules(const char[] cPropName, const int iElement);
//these functions returns always true and because they are "void", so, we don't care about value they return because it always same
native void SendProxy_UnhookPropChangeArray(const int iEntity, const char[] cPropName, const int iElement, const PropChangedCallback pCallback);
native void SendProxy_UnhookPropChangeArrayGameRules(const char[] cPropName, const int iElement, const PropChangedCallback pCallback);

#if !defined REQUIRE_EXTENSIONS
public __ext_sendproxymanager_SetNTVOptional()
{
    MarkNativeAsOptional("SendProxy_Hook");
    MarkNativeAsOptional("SendProxy_HookGameRules");
    MarkNativeAsOptional("SendProxy_HookArrayProp");
    MarkNativeAsOptional("SendProxy_UnhookArrayProp");
    MarkNativeAsOptional("SendProxy_Unhook");
    MarkNativeAsOptional("SendProxy_UnhookGameRules");
    MarkNativeAsOptional("SendProxy_IsHooked");
    MarkNativeAsOptional("SendProxy_IsHookedGameRules");
    MarkNativeAsOptional("SendProxy_HookPropChange");
    MarkNativeAsOptional("SendProxy_HookPropChangeGameRules");
    MarkNativeAsOptional("SendProxy_UnhookPropChange");
    MarkNativeAsOptional("SendProxy_UnhookPropChangeGameRules");
    MarkNativeAsOptional("SendProxy_HookArrayPropGamerules");
    MarkNativeAsOptional("SendProxy_UnhookArrayPropGamerules");
    MarkNativeAsOptional("SendProxy_IsHookedArrayProp");
    MarkNativeAsOptional("SendProxy_IsHookedArrayPropGamerules");
    MarkNativeAsOptional("SendProxy_HookPropChangeArray");
    MarkNativeAsOptional("SendProxy_UnhookPropChangeArray");
    MarkNativeAsOptional("SendProxy_HookPropChangeArrayGameRules");
    MarkNativeAsOptional("SendProxy_UnhookPropChangeArrayGameRules");
    MarkNativeAsOptional("SendProxy_IsPropChangeHooked");
    MarkNativeAsOptional("SendProxy_IsPropChangeHookedGameRules");
    MarkNativeAsOptional("SendProxy_IsPropChangeArrayHooked");
    MarkNativeAsOptional("SendProxy_IsPropChangeArrayHookedGameRules");
    MarkNativeAsOptional("SendProxy_HookPropChangeSafe");
    MarkNativeAsOptional("SendProxy_HookPropChangeGameRulesSafe");
}
#endif  

public Extension __ext_sendproxymanager = 
{
	name = "SendProxy Manager",
	file = "sendproxy.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#endif