#include <sourcemod>
#include <sdktools>
#include <sdktools_functions> 
#include <sdkhooks> 

#define Particle_st_elmos_fire "st_elmos_fire"
#define Particle_electrical_arc_01_system "electrical_arc_01_system"
#define Particle_gas_explosion_pump "gas_explosion_pump"

new String:Sound_empty[]= "weapons/clipempty_pistol.wav";
new String:Sound_defibrillator_use[]=  "weapons/defibrillator/defibrillator_use.wav";
new String:Sound_charge[]=  "ui/alert_clink.wav";
new String:Sound_upgrade[]=  "ui/bigreward.wav";
new String:Sound_denny[]=  "ui/beep_error01.wav";
new String:Sound_hit[]=  "ambient/energy/zap1.wav";

#define Max_Enemy 100
 
new Handle:l4d_defi_damage_directhit;
new Handle:l4d_defi_damage_explode;
new Handle:l4d_defi_radius_explode;

new Handle:l4d_defi_damage_electricshock;
new Handle:l4d_defi_radius_electricshock;
new Handle:l4d_defi_charge_duration; 
new Handle:l4d_defi_charge_count_shot; 
new Handle:l4d_defi_charge_count_level; 
new Handle:l4d_defi_friendly_damage; 

new LastWeapon[MAXPLAYERS+1]; 
new LastButton[MAXPLAYERS+1]; 
new Float:Energe[MAXPLAYERS+1]; 
new Float:ShotTime[MAXPLAYERS+1];
new Float:ShockTime[MAXPLAYERS+1];
new Float:ShockCenterPos[MAXPLAYERS+1][3];
new Float:ShockStartPos[MAXPLAYERS+1][3];
new Float:LastTime[MAXPLAYERS+1]; 
new Enemys[MAXPLAYERS+1][Max_Enemy+1]; 
new bool:Reloading[MAXPLAYERS+1] 
new EnemyCount[MAXPLAYERS+1]; 
new ScanIndex[MAXPLAYERS+1] ; 
new DWeapon[MAXPLAYERS+1]; 
new Bullent[MAXPLAYERS+1];
new g_sprite=0;
public Plugin:myinfo = 
{
	name = "The New Weapon:Defibrillator",
	author = "XiaoHai",
	description = " ",
	version = "1.4",
	url = ""
}
new GameMode;
new L4D2Version;
public OnPluginStart()
{ 
	GameCheck(); 
	//L4D2Version=false;
	l4d_defi_damage_directhit = CreateConVar("l4d_defi_damage_directhit", "50.0",  "直击伤害");
	
	l4d_defi_damage_explode = CreateConVar("l4d_defi_damage_explode", "375.0",  "explode damage" );
	l4d_defi_radius_explode = CreateConVar("l4d_defi_radius_explode", "150.0",  "explode  radius" );	
	
	l4d_defi_damage_electricshock = CreateConVar("l4d_defi_damage_electricshock", "30.0",  "扩散电击伤害，使用鼠标中键时*6" );
	l4d_defi_radius_electricshock = CreateConVar("l4d_defi_radius_electricshock", "200.0",  "扩散电击索敌范围" );	
	
	l4d_defi_charge_duration = CreateConVar("l4d_defi_charge_duration", "5.0",  "charge_duration [5.0, -]seconds"); 
	l4d_defi_charge_count_shot = CreateConVar("l4d_defi_charge_count_shot", "8",  "[5, 10]");
	l4d_defi_charge_count_level = CreateConVar("l4d_defi_charge_count_level", "5", "[1, 5]");
	l4d_defi_friendly_damage = CreateConVar("l4d_defi_friendly_damage", "-5.0",  "damage for teamate [-1.0, 100.0] ");	
 	
	//AutoExecConfig(true, "defibrillator_l4d");

	HookEvent("player_use", player_use2);  
	HookEvent("round_end", round_end);
	HookEvent("round_start", round_end); 
	HookEvent("map_transition", round_end);	

	HookEvent("player_spawn", player_spawn);	
	HookEvent("player_death", player_death); 
	HookEvent("player_bot_replace", player_bot_replace );	  
	HookEvent("bot_player_replace", bot_player_replace );	 
	ResetAllState();
}
Start(client)
{
	if(client>0)
	{  		
		Reloading[client]=true;
		SDKUnhook(client, SDKHook_PreThink , ClientThink);
		SDKHook(client, SDKHook_PreThink , ClientThink);
	}
}

Stop(client)
{
	if(client>0)
	{
		ResetClientState(client);
		SDKUnhook(client, SDKHook_PreThink , ClientThink); 
	}
}
StopAll()
{
	for(new i=1; i<=MaxClients; i++)
	{ 
		if(IsClientInGame(i))
		{
			SDKUnhook(i, SDKHook_PreThink , ClientThink); 
		}
	}
	 
} 
public ClientThink(client)
{
	new weapon=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon" );
	new Float:time=GetEngineTime();
	new Float:lastTime=LastTime[client];
	LastTime[client]=time;
	new shotButton=IN_ATTACK; 
	new bool:shot1=false;
	new bool:shot2=false;

	if(L4D2Version==false)shotButton=IN_ATTACK2; 
	if(weapon!=LastWeapon[client])
	{ 
		if(IsDefiWeapon(weapon))
		{
			DWeapon[client]=weapon;
		}
		else
		{
			DWeapon[client]=0;
			LastButton[client]=0;
		}
	}
	LastWeapon[client]=weapon;
	if(DWeapon[client]>0)
	{
		new button=GetClientButtons(client);
		new lastButton=LastButton[client];
		LastButton[client]=button;
		new Float:chargeDuration=GetConVarFloat(l4d_defi_charge_duration);
 
		if(Reloading[client])
		{
			new Float:intervual=time-lastTime;
			if(intervual>0.1)intervual=0.1;
			else if(intervual<0.001)intervual=0.001; 
			if(Energe[client]<chargeDuration) Energe[client]+=intervual; 
			if(Energe[client]>chargeDuration)
			{
				Energe[client]=chargeDuration;
				EmitSoundToAll(Sound_charge, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				//Reloading[client]=false;
			}
		}
		if((button & IN_RELOAD ) && !(lastButton & IN_RELOAD))
		{	 
			Reloading[client]=true;
			if(Energe[client]>=chargeDuration) 
			{	 
				if(Bullent[client]<GetConVarInt(l4d_defi_charge_count_level))
				{
					Bullent[client]++;  
					Energe[client]=0.0;
					EmitSoundToAll(Sound_upgrade, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);

				}
				else
				{
					EmitSoundToAll(Sound_denny, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.6, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);

				}
			} 
			 
		}
		  
		new shotcount = RoundFloat((Energe[client]/GetConVarFloat(l4d_defi_charge_duration))*GetConVarFloat(l4d_defi_charge_count_shot));

		if((button & shotButton) && !(lastButton & shotButton) )shot1=true;
	 
		if((button & IN_ZOOM) && !(lastButton & IN_ZOOM))shot2=true;
		if(shot1 || shot2)
		{
			if(time-ShotTime[client]>0.3)
			{ 
				if((button & IN_USE) || shot2)
				{ 
					if(Bullent[client]>0 )
					{					
						if(button & IN_DUCK)StartElecShock(client, 0);
						else StartElecShock(client, 1);
					}
					else
					{
						EmitSoundToAll(Sound_empty, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
					}
				}
				else if(shotcount>0)
				{
					StartElecShock(client, 2); 
				}
				else
				{
					EmitSoundToAll(Sound_empty, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				}
			}
		}
		ShowHud(client,shotcount);
	}
	 
	new count=EnemyCount[client];
	int TargetMax[MAXPLAYERS];
	if(count>0)
	{ 
		TargetMax[client] = !shot1 ? 9999 : 2;
		new index=ScanIndex[client];
		if(index<count)
		{
			new enemy=Enemys[client][index]; 
			
			new Float:enemyPos[3];
			if(IsValidEnemy(client, enemy,enemyPos) && TargetMax[client] > 0)
			{
				//if(time-ShockTime[client]>0.2)
				{
					CreateElec2(ShockCenterPos[client], enemyPos);
					CopyVector(enemyPos, ShockStartPos[client]);
					EmitSoundToAll(Sound_hit, enemy, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, enemyPos, NULL_VECTOR, true, 0.0);
					float multi = 1.0;
					if (!shot1) multi = 4.0;
					DoPointHurtForInfected(enemy, client, GetConVarFloat(l4d_defi_damage_electricshock) * multi );
					ScanIndex[client]++;
					ShockTime[client]=time;
					if (shot1) TargetMax[client]--;
				}
			} 
			else
			{
				ScanIndex[client]++;
			}
		}
		else
		{
			EnemyCount[client]=0;
			ScanIndex[client]=0;
		} 
	}
}
ShowHud(client, shot)
{	 
	ShowBar(client,shot);
}
new String:Gauge1[2] = "#";
new String:Gauge2[2] = "="; 
ShowBar(client, shot)	 
{
	
	new Float:pos= Energe[client];
	new Float:max= GetConVarFloat(l4d_defi_charge_duration);
	new i ;
	decl String:ChargeBar[51];
	Format(ChargeBar, sizeof(ChargeBar), "");
 
	new Float:GaugeNum = pos/max*100;
	if(GaugeNum > 100.0)
		GaugeNum = 100.0;
	if(GaugeNum<0.0)
		GaugeNum = 0.0; 
	new p=RoundFloat( GaugeNum*0.5);
	for(i=0; i<p; i++)ChargeBar[i]=Gauge1[0];
	for( ; i<50; i++)ChargeBar[i]=Gauge2[0];
	 
	//if(p>=0 && p<100)ChargeBar[p] = Gauge3[0]; 
 	/* Display gauge */
	PrintCenterText(client, "Level %d\nShot %d \n<< %s >>", Bullent[client], shot, ChargeBar);
}
bool:IsValidEnemy(client, ent,  Float:enemyPos[3])
{
	if(ent>0 && IsValidEdict(ent) && IsValidEntity(ent))
	{
	 	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", enemyPos);
		enemyPos[2]+=40.0;
		if(GetVectorDistance(ShockCenterPos[client], enemyPos)< GetConVarFloat(l4d_defi_radius_electricshock))
		{
			return true;
		}	
		 
	}
	return false;
}
ScanEnemys(client, Float:hitpos[3])
{ 
	EnemyCount[client]=0;
	new count=0;
 
	for(new i=1 ; i<=MaxClients && count<Max_Enemy; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			//if(GetClientTeam(i)==2)continue;
			Enemys[client][count++]=i;
		}
	}
	new ent=-1;
	while ((ent = FindEntityByClassname(ent,  "infected" )) != -1 && count<Max_Enemy)
	{
		Enemys[client][count++]=ent;
	}
	EnemyCount[client]=count;
	ScanIndex[client]=0;
	CopyVector(hitpos, ShockCenterPos[client]);
	CopyVector(hitpos, ShockStartPos[client]);
}
StartElecShock(client, mode)
{
	new Float:pos[3];
	new Float:angle[3];
	new Float:hitpos[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client , angle);	 
	new victim=GetEnt(client, hitpos ,MASK_SHOT); 
	if(mode!=2)
	{
		new Float:distance=GetVectorDistance(pos, hitpos);
		if(distance<GetConVarFloat(l4d_defi_radius_explode) )
		{
			PrintHintText(client, "It is too dangerous to shot");
			EmitSoundToAll(Sound_denny, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, pos, NULL_VECTOR, true, 0.0);
			
			return;
		} 
	}
	CreateElec(client, pos, hitpos, angle, mode!=2); 
	if(victim>0)
	{ 
		DoPointHurtForInfected(victim, client, GetConVarFloat(l4d_defi_damage_directhit) );
	} 
	if(mode==0)
	{
		new Handle:h=CreateDataPack();
		WritePackCell(h, 1);
		WritePackFloat(h, hitpos[0]);
		WritePackFloat(h, hitpos[1]);
		WritePackFloat(h, hitpos[2]);
		CreateTimer(0.2, DelayExplode, h);
	}
	else if(mode==1)
	{
		ScanEnemys(client, hitpos);
	}
	if(mode==2)
	{
		ScanEnemys(client, hitpos);
		Energe[client]-=GetConVarFloat(l4d_defi_charge_duration)/GetConVarFloat(l4d_defi_charge_count_shot);
	}
	else
	{
		Bullent[client]--;
	}
	ShotTime[client]=GetEngineTime();
	ShockTime[client]=ShotTime[client];
	//Reloading[client]=false;
	new Float:v=1.0;
	if(mode==2 && L4D2Version==true)v=0.4;
	EmitSoundToAll(Sound_defibrillator_use, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, v, SNDPITCH_NORMAL, -1, pos, NULL_VECTOR, true, 0.0);
	if(mode!=2)EmitSoundToAll(Sound_defibrillator_use, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, hitpos, NULL_VECTOR, true, 0.0);
	else EmitSoundToAll(Sound_hit, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, hitpos, NULL_VECTOR, true, 0.0);
 
 
}
public Action:DelayExplode(Handle:timer, Handle:h)
{
	ResetPack(h);
 	new Float:pos[3];
	new explode=ReadPackCell(h);
	pos[0]=ReadPackFloat(h);
	pos[1]=ReadPackFloat(h);
	pos[2]=ReadPackFloat(h);	
	CloseHandle(h);
	Explode(pos, explode);
}
Explode(Float:pos[3],explode )
{
	explode=0;
	new Float:radius= GetConVarFloat(l4d_defi_radius_explode) ;
	new Float:damage=GetConVarFloat(l4d_defi_damage_explode) ;

	new ent1=0;		

	if(explode)
	{
		ent1=CreateEntityByName("prop_physics"); 
		DispatchKeyValue(ent1, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent1); 
		TeleportEntity(ent1, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(ent1, "break");
	}
		 
	
	
	new pointHurt = CreateEntityByName("point_hurt");    	
 	DispatchKeyValueFloat(pointHurt, "Damage", damage);        
	DispatchKeyValueFloat(pointHurt, "DamageRadius", radius);   
	if(L4D2Version==false)	DispatchKeyValue(pointHurt, "DamageType", "64"); 
	else DispatchKeyValue(pointHurt, "DamageType", "-2130706430"); 
 	DispatchKeyValue(pointHurt, "DamageDelay", "0.0");   
	DispatchSpawn(pointHurt);
	TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);  
	AcceptEntityInput(pointHurt, "Hurt");    
	CreateTimer(0.1, DeletePointHurt, pointHurt); 
 
	new push = CreateEntityByName("point_push");         
  	DispatchKeyValueFloat (push, "magnitude",damage*2.0);                     
	DispatchKeyValueFloat (push, "radius", radius);                     
  	SetVariantString("spawnflags 24");                     
	AcceptEntityInput(push, "AddOutput");
 	DispatchSpawn(push);   
	TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 	AcceptEntityInput(push, "Enable");
	CreateTimer(0.5, DeletePushForce, push);   
	

	ShowParticle(pos, NULL_VECTOR,Particle_gas_explosion_pump  , 1.0);	
		
}
CreateElec(client, Float:pos[3], Float:endpos[3], Float:angle[3], bool:show=true)
{   
	if(L4D2Version)
	{
		decl String:tname1[10];
		decl String:tname2[10]; 
		 
		for(new i=0; i<1; i++)
		{
			new ent = CreateEntityByName("info_particle_target"); 
			DispatchSpawn(ent);  
			TeleportEntity(ent, endpos, NULL_VECTOR, NULL_VECTOR); 
			
			Format(tname1, sizeof(tname1), "target%d", client);
			Format(tname2, sizeof(tname1), "target%d", ent);
			DispatchKeyValue(client, "targetname", tname1);
			DispatchKeyValue(ent, "targetname", tname2);
			
			new particle = CreateEntityByName("info_particle_system");
		 
			DispatchKeyValue(particle, "effect_name",  Particle_st_elmos_fire ); //st_elmos_fire fire_jet_01_flame
			DispatchKeyValue(particle, "cpoint1", tname2);
			DispatchKeyValue(particle, "parentname", tname1);
			DispatchSpawn(particle);
			ActivateEntity(particle); 
				
			SetVariantString(tname1);
			AcceptEntityInput(particle, "SetParent",particle, particle, 0);   
			SetVariantString("muzzle_flash"); 
			AcceptEntityInput(particle, "SetParentAttachment");
			new Float:v[3];
			SetVector(v, 0.0,  0.0,  0.0);  
			TeleportEntity(particle, v, NULL_VECTOR, NULL_VECTOR); 
			AcceptEntityInput(particle, "start");  
			CreateTimer(1.0, DeleteParticles, particle);
			CreateTimer(0.5, DeleteParticletargets, ent);
			
			if(show)ShowParticle(endpos, NULL_VECTOR, Particle_electrical_arc_01_system, 3.0);
		}
	}
	else
	{
		decl Float:newpos[3];
		decl Float:right[3];
		GetAngleVectors(angle, NULL_VECTOR, right, NULL_VECTOR);
		NormalizeVector(right, right);
		ScaleVector(right, 7.0);
		AddVectors(pos, right, newpos);	
		new color[4];
		color[0]=255;
		color[3]=255;
		 
		TE_SetupBeamPoints(newpos, endpos, g_sprite, 0, 0, 0, 0.1, 5.0, 5.0, 1, 0.0, color, 0);
		TE_SendToAll();

	}
	 
 
}
CreateElec2(Float:pos[3], Float:endpos[3] )
{   
	if(L4D2Version)
	{
	 
		decl String:tname2[10]; 
		 

		new ent = CreateEntityByName("info_particle_target"); 
		DispatchSpawn(ent);  
		TeleportEntity(ent, endpos, NULL_VECTOR, NULL_VECTOR); 
		
		 
		Format(tname2, sizeof(tname2), "target%d", ent); 
		DispatchKeyValue(ent, "targetname", tname2);
		
		new particle = CreateEntityByName("info_particle_system");
	 
		DispatchKeyValue(particle, "effect_name",  Particle_st_elmos_fire );  
		DispatchKeyValue(particle, "cpoint1", tname2);
		//DispatchKeyValue(particle, "parentname", tname1);
		DispatchSpawn(particle);
		ActivateEntity(particle); 

		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR); 
		AcceptEntityInput(particle, "start");  
		CreateTimer(1.0, DeleteParticles, particle);
		CreateTimer(0.5, DeleteParticletargets, ent);

		//ShowParticle(endpos, NULL_VECTOR, Particle_electrical_arc_01_system, 3.0); 
	}
	else
	{
 
		new color[4];
		color[0]=255;
		color[3]=255;
		 
		TE_SetupBeamPoints(pos, endpos, g_sprite, 0, 0, 0, 0.3, 2.0, 2.0, 1, 0.0, color, 0);
		TE_SendToAll();
	}
 
}
GetEnt(client,  Float:hitpos[3],  flag,Float:offset=-50.0)
{
	new Float:pos[3];
	new Float:angle[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client , angle);
	new Handle:trace=TR_TraceRayFilterEx(pos, angle, flag, RayType_Infinite, TraceRayDontHitSelf, client); 
	new ent=-1; 
	if(TR_DidHit(trace))
	{		 
		TR_GetEndPosition(hitpos, trace);
		ent=TR_GetEntityIndex(trace); 
		decl Float:vec[3];
		GetAngleVectors(angle, vec, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vec, vec);
		ScaleVector(vec,  offset);
		AddVectors(hitpos, vec, hitpos);
	}
	CloseHandle(trace);  
	return ent;
}

CreatePointHurt()
{
	new pointHurt=CreateEntityByName("point_hurt");
	if(pointHurt)
	{		 
		if(L4D2Version)	DispatchKeyValue(pointHurt,"DamageType","-2130706430"); 
		else DispatchKeyValue(pointHurt,"DamageType","64"); //64
		DispatchSpawn(pointHurt);
	}
	return pointHurt;
}
new String:N[10];
DoPointHurtForInfected(victim, attacker=0, Float:FireDamage)
{	
	if(victim<=MaxClients && IsClientInGame(victim) && GetClientTeam(victim)==2)FireDamage=GetConVarFloat(l4d_defi_friendly_damage)  ;
 	if(FireDamage==0.0)return;
	else if (FireDamage<0.0)
	{
		new hardhp = GetClientHealth(victim);
		SetEntityHealth(victim,  hardhp+RoundFloat(0.0-FireDamage));
		return;
	} 
 
	new g_PointHurt=CreatePointHurt();	 
			
	Format(N, 20, "target%d", victim);
	DispatchKeyValue(victim,"targetname", N);
	DispatchKeyValue(g_PointHurt,"DamageTarget", N); 
 	DispatchKeyValueFloat(g_PointHurt,"Damage", FireDamage); 
	AcceptEntityInput(g_PointHurt,"Hurt",(attacker>0)?attacker:-1);
	AcceptEntityInput(g_PointHurt,"kill" ); 
}
CopyVector(Float:source[3], Float:target[3])
{
	target[0]=source[0];
	target[1]=source[1];
	target[2]=source[2];
}
SetVector(Float:target[3], Float:x, Float:y, Float:z)
{
	target[0]=x;
	target[1]=y;
	target[2]=z;
}
public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data) 
	{
		return false; 
	} 
	return true;
}
ResetAllState()
{
	for(new i=1; i<=MaxClients; i++)
	{
		ResetClientState(i);
	}
}
ResetClientState(client)
{
	LastWeapon[client]=0;
	DWeapon[client]=0; 
	LastButton[client]=0;
	Energe[client]=0.0;
	Enemys[client][0]=0;
	EnemyCount[client]=0;
	Bullent[client]=0;
	ShotTime[client]=0.0;
	Reloading[client]=false;
}

public Action:player_use2(Handle:event, const String:name[], bool:dontBroadcast)
{  
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client>0 && GetClientTeam(client)==2)
	{ 	   
		new ent=GetPlayerWeaponSlot(client, 3);
		if(IsDefiWeapon(ent))
		{ 
			Start(client);
			PrintToChat(client,"电击器需对任意物品按E以后激活，按R提升等级，开火单体低伤/中键大范围中伤/蹲下中键爆炸高伤");
		} 
	}	
} 

bool:IsDefiWeapon(ent)
{
	if(ent>0 && IsValidEdict(ent) && IsValidEntity(ent))
	{
		decl String:item[64];
		GetEdictClassname(ent, item, sizeof(item));
		if(L4D2Version)
		{
			if(StrEqual(item, "weapon_defibrillator"))
			{
				return true;
			}
		}
		else 
		{
			if(StrEqual(item, "weapon_first_aid_kit"))
			{
				return true;
			}
		}
	}
	return false;
}
public player_bot_replace(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(Spawn_Event, "player"));
	new bot = GetClientOfUserId(GetEventInt(Spawn_Event, "bot"));   
	Stop(client);
	Stop(bot);

}
public bot_player_replace(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(Spawn_Event, "player"));
	new bot = GetClientOfUserId(GetEventInt(Spawn_Event, "bot"));    
	Stop(client);
	Stop(bot);
}
public Action:player_spawn(Handle:hEvent, const String:strName[], bool:DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));  
	Stop(client);
 
}
public Action:player_death(Handle:hEvent, const String:strName[], bool:DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));  
	Stop(client);

}

public Action:round_end(Handle:event, const String:name[], bool:dontBroadcast)
{  
	ResetAllState();
	StopAll();
}  
/*Anamedcapability.Thisisdistinctlydifferentfromcheckingfora
* new String:Sound_empty[]= "weapons/clipempty_pistol.wav";
new String:Sound_defibrillator_use[]=  "weapons/defibrillator/defibrillator_use.wav";
new String:Sound_charge[]=  "ui/alert_clink.wav";
new String:Sound_upgrade[]=  "ui/bigreward.wav";
new String:Sound_denny[]=  "ui/beep_error01.wav";
new String:Sound_hit[]=  "ambient/energy/zap1.wav";
*/
public OnMapStart()
{
	if(L4D2Version)
	{
		PrecacheParticle(Particle_st_elmos_fire);
		PrecacheParticle(Particle_electrical_arc_01_system);	
		PrecacheParticle(Particle_gas_explosion_pump); 
	}
	else
	{
		g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");	
		Sound_defibrillator_use="buttons/Button10.wav";
	}
	PrecacheSound(Sound_charge, true);
	PrecacheSound(Sound_defibrillator_use, true);
	PrecacheSound(Sound_empty, true);
	PrecacheSound(Sound_hit, true);
	PrecacheSound(Sound_upgrade, true);	
} 

GameCheck()
{
	decl String:GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	
	
	if (StrEqual(GameName, "survival", false))
		GameMode = 3;
	else if (StrEqual(GameName, "versus", false) || StrEqual(GameName, "teamversus", false) || StrEqual(GameName, "scavenge", false) || StrEqual(GameName, "teamscavenge", false))
		GameMode = 2;
	else if (StrEqual(GameName, "coop", false) || StrEqual(GameName, "realism", false))
		GameMode = 1;
	else
	{
		GameMode = 0;
 	}
	GameMode=GameMode+0;
	GetGameFolderName(GameName, sizeof(GameName));
	if (StrEqual(GameName, "left4dead2", false))
	{
 
		L4D2Version=true;
 
	}	
	else
	{
 
		L4D2Version=false;
 
	}
 
}
 
public PrecacheParticle(String:particlename[])
{
	new particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.01, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
	} 
}
public Action:DeleteParticles(Handle:timer, any:particle)
{
	 if (IsValidEntity(particle))
	 {
		 decl String:classname[64];
		 GetEdictClassname(particle, classname, sizeof(classname));
		 if (StrEqual(classname, "info_particle_system", false))
			{
				AcceptEntityInput(particle, "stop");
				AcceptEntityInput(particle, "kill");
				RemoveEdict(particle);
				 
			}
	 }
}
public ShowParticle(Float:pos[3], Float:ang[3],String:particlename[], Float:time)
{
	new particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		
		DispatchKeyValue(particle, "effect_name", particlename); 
		DispatchSpawn(particle);
		ActivateEntity(particle);
		
		
		TeleportEntity(particle, pos, ang, NULL_VECTOR);
		AcceptEntityInput(particle, "start");		
		CreateTimer(time, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
		return particle;
	}  
	return 0;
}
public Action:DeleteParticletargets(Handle:timer, any:target)
{
	 if (IsValidEntity(target))
	 {
		 decl String:classname[64];
		 GetEdictClassname(target, classname, sizeof(classname));
		 if (StrEqual(classname, "info_particle_target", false))
			{
				AcceptEntityInput(target, "stop");
				AcceptEntityInput(target, "kill");
				RemoveEdict(target);
				 
			}
	 }
}
public Action:DeletePointHurt(Handle:timer, any:ent)
{
	 if (ent> 0 && IsValidEntity(ent) && IsValidEdict(ent))
	 {
		 decl String:classname[64];
		 GetEdictClassname(ent, classname, sizeof(classname));
		 if (StrEqual(classname, "point_hurt", false))
				{
					AcceptEntityInput(ent, "Kill"); 
					RemoveEdict(ent);
				}
		 }

}
public Action:DeletePushForce(Handle:timer, any:ent)
{
	 if (ent> 0 && IsValidEntity(ent) && IsValidEdict(ent))
	 {
		 decl String:classname[64];
		 GetEdictClassname(ent, classname, sizeof(classname));
		 if (StrEqual(classname, "point_push", false))
				{
 					AcceptEntityInput(ent, "Disable");
					AcceptEntityInput(ent, "Kill"); 
					RemoveEdict(ent);
				}
	 }
}