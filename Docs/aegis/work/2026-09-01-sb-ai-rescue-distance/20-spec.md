# Pinned Rescue Maximum Distance Design

## Decision

Add `ib_help_pinned_max_distance` with a default of `5000.0` units. Cache the squared value in `g_fCvar_HelpPinnedFriend_MaxDistance_Sqr` during the existing `UpdateConVarValues()` pass. A value of `0` means the distance limit is disabled.

`rescue.inc` will own a small helper that compares the assigned Bot's cached absolute origin with the pinned survivor's cached absolute origin. `IsPinnedFriendReactionAllowed()` will call it only after the existing cheap identity/coordinator checks and before the rescue interval, weapon checks, aim, visibility, or action work. The helper will use only `g_fClientAbsOrigin`; it will never call an entity-position native. Those positions are refreshed only by `runtime.inc` under the existing `GetProcessCacheExpiry()` / `ib_process_time` clock.

The coordinator's rank rows will not be filtered permanently at rebuild time. Assignments are intentionally stable between coordinator rebuilds; filtering ranks there could fail to notice a Bot that later moves within range. The per-evaluation gate preserves dynamic distance behavior with O(1) state lookup plus one squared-distance comparison for the already assigned Bots.

The `versus_isfullshit` profile will set the CVar to `1500`. `actions.inc` will remain unchanged, so native `LiberateBesiegedFriend` movement is outside this plugin-distance policy.

## Alternatives considered

1. Filter only coordinator ranks: fewer assigned candidates, but a Bot excluded while far away cannot become eligible when it approaches until another coordinator rebuild.
2. Rebuild coordinator rankings every process window: dynamic, but adds repeated ranking work and conflicts with the event-driven coordinator's performance goal.
3. Gate each assigned rescue evaluation: one cheap comparison on at most the configured rescue Bots, preserves dynamic eligibility, and does not add a second position-update clock. This is the selected approach.

## Acceptance criteria

- The plugin registers `ib_help_pinned_max_distance` with default `5000` and a non-negative lower bound.
- The cached threshold is squared in `UpdateConVarValues()` and updates through the normal CVar hook path.
- A non-zero threshold rejects an assigned Bot whose cached-origin distance from the pinned survivor is greater than the threshold.
- A zero threshold does not reject based on distance.
- The gate is part of `IsPinnedFriendReactionAllowed()` before `TryBeginPinnedRescueThink()` and all expensive rescue action work.
- The profile contains exactly `confogl_addcvar ib_help_pinned_max_distance 1500`.
- No global snapshot refresh or native movement hook is added.

## Residual risk

Static tests and compilation can prove source contracts, but this workspace has no live L4D2 server. In-game verification of the exact spatial boundary and frame-time improvement remains a manual server smoke test.
