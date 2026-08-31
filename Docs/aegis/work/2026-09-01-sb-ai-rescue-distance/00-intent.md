# Task Intent: Pinned Rescue Maximum Distance

## Requested outcome

Add a configurable maximum distance for the plugin's forced pinned-survivor rescue processing. The default is `5000`; the `versus_isfullshit` profile overrides it to `1500`.

## Scope

- Add `ib_help_pinned_max_distance` and cache its squared value.
- Use the existing `g_fClientAbsOrigin` process-window snapshot in the pinned rescue cheap gate.
- Skip the plugin's aim, weapon, visibility, shove, and attack work when the assigned Bot is beyond the configured distance.
- Keep all global snapshot refreshes owned by `runtime.inc` and scheduled by `ib_process_time`.
- Leave native `LiberateBesiegedFriend` movement behavior unchanged.

## Non-goals

- Do not make the plugin pathfind toward a pinned survivor.
- Do not intercept or change native movement actions in `actions.inc`.
- Do not continuously rebuild coordinator rankings as survivors move.

## Compatibility

Existing rescue assignment, nearest-Bot ranking, reaction interval, Jockey/Smoker aim handling, and native behavior remain unchanged when the CVar is at its default. A value of `0` disables only this distance limit.
