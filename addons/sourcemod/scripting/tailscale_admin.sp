#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Tailscale Admin",
	author = "OpenAI",
	description = "Grants root admin flag to clients connecting from Tailscale IPv4 addresses.",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientConnected(client))
		{
			GrantTailscaleAdmin(client);
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	GrantTailscaleAdmin(client);
}

static void GrantTailscaleAdmin(int client)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client))
	{
		return;
	}

	char ip[64];
	if (!GetClientIP(client, ip, sizeof(ip), true))
	{
		return;
	}

	if (!IsTailscaleIPv4(ip))
	{
		return;
	}

	int flags = GetUserFlagBits(client);
	if ((flags & ADMFLAG_ROOT) == 0)
	{
		SetUserFlagBits(client, flags | ADMFLAG_ROOT);
		LogMessage("Granted root admin flag to Tailscale client %N (%s)", client, ip);
	}
}

static bool IsTailscaleIPv4(const char[] ip)
{
	int octets[4];
	int octetIndex = 0;
	int value = 0;
	bool hasDigit = false;

	for (int i = 0; ip[i] != '\0'; i++)
	{
		if (ip[i] >= '0' && ip[i] <= '9')
		{
			value = (value * 10) + (ip[i] - '0');
			if (value > 255)
			{
				return false;
			}

			hasDigit = true;
			continue;
		}

		if (ip[i] == '.')
		{
			if (!hasDigit || octetIndex >= 3)
			{
				return false;
			}

			octets[octetIndex++] = value;
			value = 0;
			hasDigit = false;
			continue;
		}

		return false;
	}

	if (!hasDigit || octetIndex != 3)
	{
		return false;
	}

	octets[3] = value;

	return octets[0] == 100 && octets[1] >= 64 && octets[1] <= 127;
}
