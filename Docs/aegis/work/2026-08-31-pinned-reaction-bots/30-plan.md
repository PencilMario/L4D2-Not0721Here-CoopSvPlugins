# Survivor Bot AI Improver Performance Optimization Plan

> **For agentic workers:** This approved implementation is tracked inline with the task checkpoints.

**Goal:** Limit the Survivor Bot AI Improver's forced reaction to an immobilized teammate to the nearest configured number of survivor Bots, make `0` disable that plugin reaction, reduce repeated navigation/VScript/team scans for large survivor teams, write debug output to a dedicated log as well as the server console, and re-enable the plugin in `versus_isfullshit`.

**Architecture:** Add one integer ConVar to the existing `convars.inc` registration/cache path. Add a small helper in `rescue.inc` that ranks all alive survivor Bots by squared distance to the same pinned teammate, with client-index tie breaking. Gate only the forced shoot/shove branch in `bot_think.inc`; native rescue actions and unrelated AI remain unchanged. Centralize cache expiry through `GetProcessCacheExpiry()`, backed by `ib_process_time`, and use bounded caches/snapshots around expensive navigation, VScript, visibility, inventory, and common-infected scans.

**Baseline / Authority Refs:** `AGENTS.md`, `addons/sourcemod/scripting/l4d2_sb_ai_improver/README.md`, existing `convars.inc`/`state.inc` cache patterns, `bot_think.inc` pinned-friend branch, and `cfg/cfgogl/versus_isfullshit/shared_plugins.cfg`.

**Compatibility Boundary:** `ib_help_pinned_enabled`, reaction delay, shoot/shove range checks, visibility checks, and native `LiberateBesiegedFriend` behavior remain active. `ib_help_pinned_reaction_bots` defaults to `2`; `0` disables only this plugin's forced pinned-friend reaction. Cache freshness follows `ib_process_time`; caches are reset on map/round/client lifecycle boundaries. The mode loader is restored without changing unrelated plugin lines.

**Verification:** Run `tests/l4d2_sb_ai_pinned_reaction.tests.ps1` RED before production edits and GREEN afterward; compile `l4d2_sb_ai_improver.sp` with the project's SourcePawn 1.12 compiler; run module/config contracts and CRLF-aware diff checks.

### Task 1: Pinned-friend reaction limit

- [x] Add a failing static contract for the new ConVar, ranking helper, reaction gate, mode cvar, and loader.
- [x] Add the ConVar declaration, registration, hook, and cache assignment.
- [x] Add nearest-Bot ranking with `0` disable semantics.
- [x] Gate the forced pinned-friend reaction branch.
- [x] Configure the cvar and restore the mode loader.
- [x] Compile and run focused/regression verification.

### Task 2: Runtime logging and cache policy

- [x] Create `sb_ai_performance.log` through `logger.inc`.
- [x] Keep `ib_debug` console output and mirror the routed debug messages to that file.
- [x] Route performance threshold records to the dedicated file.
- [x] Add one shared `ib_process_time` cache-expiry helper and use it for all new cache writes.
- [x] Reset caches at map, round, and client lifecycle boundaries.

### Task 3: Large-team performance work

- [x] Cache nearest-nav-area, damaging-area/position, visibility, reachability, travel/distance, and `NavAreaBuildPath` results.
- [x] Cache the per-client last-known nav area used by `OnPlayerRunCmd`.
- [x] Cache TakeCover and acid-evasion VScript candidates and bound candidate attempts.
- [x] Merge the three ordinary-infected count scans into one pass.
- [x] Replace the ordinary-infected × all-survivors melee-target scan with a refreshed bitmask snapshot.
- [x] Cache repeated team inventory/item counts and nearby-Boomer checks.
- [x] Fix the friendly-fire distance target and TakeCover vertical-offset defects found during review.
- [x] Rebuild the tracked SMX and run the complete contract suite.
