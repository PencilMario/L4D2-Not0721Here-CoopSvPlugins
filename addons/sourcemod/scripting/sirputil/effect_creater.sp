#define Particle_st_elmos_fire "st_elmos_fire"
#define Particle_electrical_arc_01_system "electrical_arc_01_system"
#define Particle_gas_explosion_pump "gas_explosion_pump"
#define PARTICLE_WEAPON_TRACER		"weapon_tracers_50cal"
#define SOUND_SHOT					"weapons/50cal/50cal_shoot.wav"


#include <sdktools>

/**
 * 生成一个原地扩散式闪电
 * 
 * @param pos 闪电位置
 */
public void EC_PointElectronic(int pos[3]){
	char tname1[10];
	char tname2[10]; 
		 
	for(int i=0; i<1; i++)
	{
		new ent = CreateEntityByName("info_particle_target"); 
		DispatchSpawn(ent);  
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR); 
		
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
		
		ShowParticle(endpos, NULL_VECTOR, Particle_electrical_arc_01_system, 3.0);
    }

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