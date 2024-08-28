#define Particle_st_elmos_fire "st_elmos_fire"
#define Particle_electrical_arc_01_system "electrical_arc_01_system"
#define Particle_gas_explosion_pump "gas_explosion_pump"
#define PARTICLE_WEAPON_TRACER		"weapon_tracers_50cal"
#define SOUND_SHOT					"weapons/50cal/50cal_shoot.wav"


#include <sdktools>
#include <sourcemod>

public void EC_PrecacheEffects(){
	PrecacheParticle(Particle_st_elmos_fire);
	PrecacheParticle(Particle_electrical_arc_01_system);	
	PrecacheParticle(Particle_gas_explosion_pump); 
}

int PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	int index = FindStringIndex(table, sEffectName);
	if( index == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
		index = FindStringIndex(table, sEffectName);
	}

	return index;
}

/**
 * 生成一个原地扩散式闪电
 * 
 * @param pos 闪电位置
 */
public void EC_PointElectronic(float pos[3]){
	ShowParticle(pos, NULL_VECTOR, Particle_electrical_arc_01_system, 3.0);
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

/**
 * 生成一个点对点闪电
 * 
 * @param pos 起始位置
 * @param endpos 结束位置  
 */
public void EC_Point2PointElectronic(int pos[3], int endpos[3]){
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
}


public void EC_Fire50Bullet(float pos[3], float endpos[3])
{
    EmitSoundToAll(SOUND_SHOT);
 	char temp[16]="";
	int target = CreateEntityByName("info_particle_target");
	Format(temp, 64, "cptarget%d", target);
	DispatchKeyValue(target, "targetname", temp);
	TeleportEntity(target, endpos, NULL_VECTOR, NULL_VECTOR);
	ActivateEntity(target);

	int particle = CreateEntityByName("info_particle_system");
	DispatchKeyValue(particle, "effect_name", PARTICLE_WEAPON_TRACER);
	DispatchKeyValue(particle, "cpoint1", temp);
	DispatchSpawn(particle);
	ActivateEntity(particle);
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(particle, "start");
	CreateTimer(0.01, DeleteParticletargets, EntIndexToEntRef(target), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.01, DeleteParticles, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
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