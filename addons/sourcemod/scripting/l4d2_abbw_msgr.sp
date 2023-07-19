#include <sourcemod>   

public Plugin:myinfo =   
{   
    name = "通告信息",   
    author = "通告信息",   
    description = "通告信息",   
    version = "5.0.0",   
    url = "通告信息"  
};  

public OnClientPutInServer(client)
{
	CreateTimer(20.0, TimerAnnounce, client);
}

public Action:TimerAnnounce(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
        PrintToChat(client, "\x04[提示] \x05输入指令 \x04!maps \x05投票更换第三方地图");
	}
}