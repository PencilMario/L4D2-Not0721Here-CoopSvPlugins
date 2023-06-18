DirectorOptions <-
{
   	ActiveChallenge = 1
	cm_AggressiveSpecials 			= true
	cm_ShouldHurry 					= 1
	cm_SpecialRespawnInterval 		= 15 //Time for an SI spawn slot to become available
	cm_SpecialSlotCountdownTime 	= 0
	
	cm_AllowPillConversion = 0
	cm_AllowSurvivorRescue = 0
	SurvivorMaxIncapacitatedCount = 0
	
	DominatorLimit 			= 3
	cm_BaseSpecialLimit 	= 3
	cm_MaxSpecials 			= 3
	BoomerLimit 			= 1
	SpitterLimit 			= 0
	HunterLimit 			= 1
	JockeyLimit 			= 1
	ChargerLimit 			= 1
	SmokerLimit 			= 0
	

	
    DefaultItems =
 	[
 		"weapon_smg",
 		"weapon_pistol",
        "weapon_pistol",
 	]

 	function GetDefaultItem( idx )
 	{
 		if ( idx < DefaultItems.len() )
 		{
 			return DefaultItems[idx];
 		}
 		return 0;
 	}
 	weaponsToConvert =
	{
		weapon_first_aid_kit =	"weapon_pain_pills_spawn"
		weapon_adrenaline =	"weapon_pain_pills_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}
	TempHealthDecayRate = 0.001
	function RecalculateHealthDecay()
	{
		if ( Director.HasAnySurvivorLeftSafeArea() )
		{
			TempHealthDecayRate = 0.27 // pain_pills_decay_rate default
		}
	}
}

MapData <-{
	g_nSI 	= 3
	g_nTime = 3
}


function update_diff()
{
    local timer = (Convars.GetFloat("SS_Time")).tointeger()
    local Si1p = (Convars.GetFloat("sss_1P")).tointeger()
	local relax = (Convars.GetFloat("SS_Relax")).tointeger()
	local dpslim = (Convars.GetFloat("SS_DPSSiLimit")).tointeger()

	local SpecialLimits = [0,0,0,0,0,0];
	local index = 0;
	local Sifix = Si1p;
	if (Si1p < 6){
		Sifix = 6
	}
	for(local a = 1; a <= Sifix; a+=1){
		SpecialLimits[index] += 1;
		index += 1;
		if (SpecialLimits[4]+SpecialLimits[5] >= dpslim){
			if (index > 3){
				index = 0;
			}
		}
		if (index > 5){
			index = 0;
		}
	}

	if (relax != 1){
		DirectorOptions.LookTempo <- true
		DirectorOptions.IntensityRelaxThreshold <- 1.01
    	DirectorOptions.RelaxMaxFlowTravel <- 0.0
    	DirectorOptions.RelaxMaxInterval <- 0.5
    	DirectorOptions.RelaxMinInterval <- 0.0
		DirectorOptions.SustainPeakMinTime <- 0
		DirectorOptions.SustainPeakMaxTime <- 0.1
		Convars.SetValue("director_special_battlefield_respawn_interval",2)
		Convars.SetValue("director_special_initial_spawn_delay_max", 1)
		Convars.SetValue("director_special_initial_spawn_delay_max_extra", 2)
		Convars.SetValue("director_special_initial_spawn_delay_min", 0)
		Convars.SetValue("director_special_finale_offer_length", 1)
		Convars.SetValue("director_special_original_offer_length", 1)
	}
	else
	{
		try 
		{
			delete DirectorOptions.LookTempo
			delete DirectorOptions.IntensityRelaxThreshold 
    		delete DirectorOptions.RelaxMaxFlowTravel 
    		delete DirectorOptions.RelaxMaxInterval 
    		delete DirectorOptions.RelaxMinInterval 
			delete DirectorOptions.SustainPeakMinTim
			delete DirectorOptions.SustainPeakMaxTime 
		}
		catch (e)
		{	
			
		}
		Convars.SetValue("director_special_battlefield_respawn_interval",10)
		Convars.SetValue("director_special_initial_spawn_delay_max", 60)
		Convars.SetValue("director_special_initial_spawn_delay_max_extra", 180)
		Convars.SetValue("director_special_initial_spawn_delay_min", 30)
		Convars.SetValue("director_special_finale_offer_length", 10)
		Convars.SetValue("director_special_original_offer_length", 30)
	}

    DirectorOptions.cm_SpecialRespawnInterval = timer
    DirectorOptions.cm_SpecialSlotCountdownTime = timer
    DirectorOptions.HunterLimit = SpecialLimits[0]
    DirectorOptions.JockeyLimit = SpecialLimits[1]
    DirectorOptions.SmokerLimit = SpecialLimits[2]
    DirectorOptions.ChargerLimit = SpecialLimits[3]
    DirectorOptions.SpitterLimit = SpecialLimits[4]
	DirectorOptions.BoomerLimit = SpecialLimits[5]
    MapData.g_nSI = Si1p
    
    DirectorOptions.cm_BaseSpecialLimit = MapData.g_nSI
    DirectorOptions.cm_MaxSpecials      = MapData.g_nSI
    DirectorOptions.DominatorLimit      = MapData.g_nSI
}

function Update()
{
	DirectorOptions.RecalculateHealthDecay();
}
update_diff();
g_ModeScript.update_diff();

