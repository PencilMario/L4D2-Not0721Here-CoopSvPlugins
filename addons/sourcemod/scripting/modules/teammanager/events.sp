public ReadyUp_FwdStatistics(client, type, amount) {
	if (IsLegitimateClient(client)) {
		if (type == 0) SurvivorDamage[client] += amount;
		else if (type == 1) InfectedDamage[client] += amount;
		else if (type == 2) CommonKills[client]++;
		else if (type == 3) SurvivorIncaps[client]++;
		else if (type == 4) InfectedIncaps[client]++;
		else if (type == 5) Rescues[client]++;
		else if (type == 6) SpecialKills[client]++;
		else if (type == 7) SurvivorDamageTaken[client] += amount;
		else if (type == 8) InfectedDamageTaken[client] += amount;
	}
}

public Action:Event_PlayerHurt(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));

	//CheckLoadAttemptEveryone();
	if (IsClientHuman(attacker) && !bRoundOver && !bLoadAttempted[attacker])
	{
		bLoadAttempted[attacker] = true;
		IsLoading[attacker] = true;
		LoadPlayerData(attacker);
		return;
	}
	//if (IsClientHuman(victim) && !IsLoading[victim] && (!IsLegitimateClient(victim) || GetClientTeam(attacker) != GetClientTeam(victim))) {

	//}
	if (IsClientHuman(attacker) && !IsLoading[attacker] && IsClientActual(victim) && GetClientTeam(attacker) != GetClientTeam(victim))
	{
		new damage = GetEventInt(event, "dmg_health");
		if (GetClientTeam(attacker) == TEAM_SURVIVOR) SurvivorDamage[attacker] += damage;
		else if (GetClientTeam(attacker) == TEAM_INFECTED) InfectedDamage[attacker] += damage;
	}
}

public Action:Event_InfectedDeath(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (IsClientHuman(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR)
	{
		if (!bRoundOver && !bLoadAttempted[attacker])
		{
			bLoadAttempted[attacker] = true;
			IsLoading[attacker] = true;
			LoadPlayerData(attacker);
			return;
		}
		if (!IsLoading[attacker]) CommonKills[attacker]++;
	}
}

public Action:Event_PlayerIncapacitated(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsClientActual(attacker) && !IsLoading[attacker] && IsClientHuman(victim) && GetClientTeam(attacker) != GetClientTeam(victim))
	{
		SurvivorIncaps[victim]++;
		InfectedIncaps[attacker]++;
	}
}

public Action:Event_ChokeStopped(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new savior = GetClientOfUserId(GetEventInt(event, "userid"));
	new type = GetEventInt(event, "release_type");
	if (type != 4 && type != 2) return;

	if (IsClientHuman(savior) && !IsLoading[savior])
	{
		Rescues[savior]++;
	}
}

public Action:Event_JockeyRideEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new savior = GetClientOfUserId(GetEventInt(event, "rescuer"));
	if (IsClientHuman(savior) && !IsLoading[savior])
	{
		Rescues[savior]++;
	}
}

public Action:Event_PounceStopped(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new savior = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientHuman(savior) && !IsLoading[savior])
	{
		Rescues[savior]++;
	}
}

public Action:Event_ReviveSuccess(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new savior = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject = GetClientOfUserId(GetEventInt(event, "subject"));
	
	if (IsClientHuman(savior) && !IsLoading[savior] && IsClientActual(subject) && savior != subject)
	{
		Rescues[savior]++;
	}
}

public Action:Event_PlayerDeath(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (IsClientHuman(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR && IsClientActual(client) && GetClientTeam(client) == TEAM_INFECTED) SpecialKills[attacker]++;
}