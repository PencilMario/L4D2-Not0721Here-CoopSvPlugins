# Zombie Character Select Tank Switch Intent

**Requested outcome:** Add Tank as a selectable infected class in `l4d2_zcs_redux.sp`, controlled by a new `zcs_tank_limit` ConVar whose default is `0`.

**Scope:** Extend the existing ghost class-cycle, `sm_buy` selection, per-class counting, limit checks, cooldown-state arrays, and HUD display to include Tank. Keep Tank outside the ordinary special-infected total. Preserve the existing six-class limits and the current `versus.cfg` changes in the main worktree.

**Semantics:** `zcs_tank_limit 0` disables Tank selection; `1` through `10` allow at most that many active Tanks. The ConVar is enforced through the existing `zcs_respect_limits` path, matching the other `zcs_*_limit` settings.

**Non-goals:** Do not add Tank cooldown tuning, change Director Tank spawning, count Tank against the ordinary SI total, or modify unrelated mode configuration.


