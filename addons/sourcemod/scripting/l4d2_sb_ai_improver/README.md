# Survivor Bot AI Improver modules

`l4d2_sb_ai_improver.sp` is the composition root. These files are textual SourcePawn modules and compile into one SMX. Include order is significant because it preserves the declaration order of the original source.

## Plugin setup

- `state.inc`: plugin metadata, constants, configuration handles, and shared runtime state.
- `lifecycle.inc`: plugin load and startup callbacks.
- `convars.inc`: ConVar creation, change hooks, and cached values.
- `bootstrap.inc`: gamedata parsing, SDKCalls, detours, and VScript registration.
- `events.inc`: round, client, survivor, and infected event handlers.
- `debug.inc`: administrative diagnostics.

## Bot execution

- `runtime.inc`: `OnPlayerRunCmd` snapshots and lightweight runtime forwards.
- `bot_think.inc`: the existing central bot decision routine.
- `combat.inc`: damage hooks and Witch/Tank combat reactions.
- `movement.inc`: cover, move-position commands, and pathable-location VScript calls.
- `aiming.inc`: fire safety, aim point, and target shootability.
- `rescue.inc`: immobilized-survivor rescue checks and look commands.
- `grenades.inc`: grenade eligibility and trajectory calculations.

## World model

- `weapons.inc`: firing timing, ammo access, and bile/adrenaline state.
- `scavenging.inc`: item selection and scavenge candidate evaluation.
- `entity_registry.inc`: entity lifecycle and categorized entity lists.
- `weapon_data.inc`: weapon/melee maps, tiers, model data, and entity predicates.
- `perception.inc`: infected selection, visibility memory, view cones, and traces.
- `inventory.inc`: weapon slots and team inventory queries.
- `utilities.inc`: shared client/entity/vector helpers.
- `navigation.inc`: nav-area geometry, travel distance, reachability, and path danger.
- `detours.inc`: runtime detour implementations that modify engine AI queries.
- `actions.inc`: BehaviorActions callbacks.

## Boundary

Do not reorder includes casually. Cross-module state is intentionally owned by `state.inc`; modules should not introduce duplicate state owners. Performance changes to `bot_think.inc`, `scavenging.inc`, `perception.inc`, or `navigation.inc` should be profiled and reviewed separately from structural moves.
