#if defined _automatic_healing_included
 #endinput
#endif
#define _automatic_healing_included

public SharedPlugin __pl_automatic_healing = 
{
    name = "automatic_healing",
    file = "automatic_healing.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_automatic_healing_SetNTVOptional()
{
    MarkNativeAsOptional("AutomaticHealing_WaitToHeal");
}
#endif

/**
 * @brief restart someone's healing
 *
 * @param client        client index
 *
 * @return	true if actually restart the healing, false if needn't.
 *
 * @error   invalid client index, or client not in game, or client not an alive and none-incapacitated survivor.
 */
native bool AutomaticHealing_WaitToHeal(int client);