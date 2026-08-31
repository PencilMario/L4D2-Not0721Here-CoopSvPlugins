# Survivor Bot Rescue Performance Optimization Design

## Decision

Use an event-driven rescue coordinator as the canonical owner of the forced pinned-friend relationship. A grab event records the victim, attacker, and attacker class, builds the existing nearest-Bot rank row once, and assigns only the configured number of candidate Bots. Release, death, revive, round, map, and client lifecycle events invalidate or rebuild the affected state. The usercmd path reads these arrays and does not rediscover the attacker with `L4D_GetPinnedInfected`.

The coordinator keeps one rescue assignment per Bot. If multiple victims are active, a Bot is assigned to the closest eligible victim; rank rows remain per victim so the configured nearest-Bot rule is still deterministic. Existing `IsPinnedFriendReactionAllowed` remains the public gate but becomes an O(1) coordinator/rank lookup instead of rebuilding a rank cache from the usercmd path.

## Rescue evaluation path

The per-usercmd branch first checks the plugin rescue bitmask, coordinator assignment, reaction delay, and `g_fSurvivorBot_NextPinnedRescueThinkTime`. Failed checks return before attacker lookup, bone lookup, or Trace. A successful evaluation schedules the next per-Bot rescue interval before doing visibility and action work. Existing shoot/shove distance checks, weapon safety checks, and `PressAttackButton` cadence remain unchanged.

## Jockey/Smoker aiming

Jockey rescue aim uses the already updated attacker centroid. Smoker rescue aim uses the custom ability's `m_tipPosition` when the ability/property/position is valid, otherwise the cached attacker centroid. Both paths perform one direct `IsVisibleVector` check and never call the generic bone enumerator. Hunter/Charger and other non-Jockey/Smoker rescue targets retain `GetTargetAimPart` plus the existing visual-contact behavior.

## State and invalidation

`state.inc` owns coordinator attacker/class/active arrays, per-Bot assigned victim/attacker arrays, and the per-Bot rescue interval. `rescue.inc` owns coordinator transitions and ranking. `events.inc` only translates game events into coordinator calls. `ResetPinnedReactionCaches` clears every coordinator row, assignment, rank, and interval. Map/round/client resets invoke that owner.

## Compatibility boundary

The existing `ib_help_pinned_reaction_bots` default of `2`, nearest ranking, tie-breaking, and `0` disable behavior remain. `ib_help_pinned_enabled=0` still prevents forced rescue action. `ib_help_pinned_shootrange`, `ib_help_pinned_shoverange`, reaction delay, weapon restrictions, visibility blindness checks, and native rescue behavior remain. The generic aiming path is retired only for Jockey/Smoker forced rescue; it remains active for unrelated targeting and other rescue classes.

## Verification and residual risk

The new static contract must fail before production edits and pass after each implementation slice. The plugin is compiled with the project SourcePawn 1.12 compiler and all repository PowerShell contracts are rerun. There is no local live L4D2 server in the workspace, so event field behavior, actual log/frame-time reduction with ten Bots, and installed-extension compatibility require an in-game smoke test.

## Working drafts

- Task intent: `00-intent.md`.
- Baseline read set: `10-baseline-readset.md`.
- Impact statement: this design's state, runtime, event, aim, and compatibility sections.

The user approved implementing all three optimization stages with “这三个都做吧”.
