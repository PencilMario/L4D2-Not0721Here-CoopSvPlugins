DirectorOptions <-
{
   	ActiveChallenge = 1
	cm_AggressiveSpecials 			= true
	cm_ShouldHurry 					= 1
	cm_SpecialRespawnInterval 		= 15 //Time for an SI spawn slot to become available
	cm_SpecialSlotCountdownTime 	= 3
	
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
}

MapData <-{
	g_nSI 	= 3
	g_nTime = 3
}

function update_diff()
{
    local timer = Convars.GetInt("SS_Time");
    local Si1p = Convars.GetInt("sss_1P");
	local SpecialLimits = [0,0,0,0,0,0];
	local index = 0;
	local Sifix = Si1p;
	if (Si1p < 6){
		Sifix = 6
	}
	for(local a = 0; a <= Sifix; a+=1){
		SpecialLimits[index] += 1;
		index += 1;
		if (index > 5){
			index = 0;
		}
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

update_diff();
