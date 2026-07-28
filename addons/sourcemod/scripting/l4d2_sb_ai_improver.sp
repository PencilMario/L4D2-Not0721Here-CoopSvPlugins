/*======================================================================================
	This is a modified version of Bot Improver

	Notable changes here:

	OnPlayerRunCmd()
	SurvivorBotThink() - slight change for witch targeting, also changed item scavenge behavior
	CheckEntityForStuff()
	CheckForItemsToScavenge()
	GetItemFromArrayList()
	GetWeaponClassname()
	GetWeaponMaxAmmo()
	GetWeaponTier()
	SurvivorHasPistol() and similar
	GetSurvivorTeamInventoryCount() - new
	GetClientDistanceToItem() - to replace GetEntityDistance()
	L4D2_OnFindScavengeItem()

	GetNavDistance() - to replace GetVectorTravelDistance(). If you pass an entity ID to it, it will remember
	if distance to the entity could not be measured, and won't hammer the server with more useless calculations. Yay!

	GetClientTravelDistance() - L4D2_IsReachable is used instead of L4D2_NavAreaBuildPath. It does essentially same thing,
	outputs same boolean, and does not cause as much lag as the other function.

	LBI_IsReachablePosition() - argument to ignore LOS when picking nearest nav area.
	LBI_IsPathToPositionDangerous() - L4D2_IsReachable is used instead of L4D2_NavAreaBuildPath. Additional cutoff for amount of processed nav areas.
	DTR_OnFindUseEntity() - prevent bots from grabbing items from absurd distances.
	VScript_TryGetPathableLocationWithin() - new

======================================================================================*/

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>


#include <adt_trie>
#include <logger>
#include <dhooks>
#include <left4dhooks>
#include <vscript> //https://github.com/FortyTwoFortyTwo/VScript
#undef REQUIRE_EXTENSIONS
#include <actions>
#define REQUIRE_EXTENSIONS

#include "l4d2_sb_ai_improver/state.inc"

#include "l4d2_sb_ai_improver/lifecycle.inc"

#include "l4d2_sb_ai_improver/convars.inc"

#include "l4d2_sb_ai_improver/bootstrap.inc"

#include "l4d2_sb_ai_improver/events.inc"

#include "l4d2_sb_ai_improver/debug.inc"

#include "l4d2_sb_ai_improver/runtime.inc"

#include "l4d2_sb_ai_improver/bot_think.inc"

#include "l4d2_sb_ai_improver/combat.inc"

#include "l4d2_sb_ai_improver/movement.inc"

#include "l4d2_sb_ai_improver/aiming.inc"

#include "l4d2_sb_ai_improver/rescue.inc"

#include "l4d2_sb_ai_improver/grenades.inc"

#include "l4d2_sb_ai_improver/weapons.inc"

#include "l4d2_sb_ai_improver/navigation.inc"

#include "l4d2_sb_ai_improver/actions.inc"
