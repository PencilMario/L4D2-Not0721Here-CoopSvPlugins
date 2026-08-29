# Atomic Tasks

- [x] Add `tests/l4d2_spitter_slime_contract.tests.ps1` and observe its missing-source failure.
- [x] Add the new SourcePawn ConVars and per-Spitter/child-entity lifecycle state, including idle and tracking timeouts.
- [x] Replace manual slime position integration with engine-owned `MOVETYPE_FLYGRAVITY` velocity steering, preserve bounce speed, and use the configurable 2x tracking speed / `< 100` default hit boundary.
- [x] Add lifecycle hooks, idempotent cleanup, and the global slime update timer.
- [x] Add native visible slime creation, random local velocity, visible-survivor selection, tracking velocity, lifecycle deletion, hit radius, and SDKDamage.
- [x] Add the `IN_ATTACK` ability forward replacement, gas-can ballistic launch, touch guard, particle/sound effects, SDKDamage blast targeting, and direct velocity knockback.
- [x] Compile the new plugin and regenerate `addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx`.
- [x] Switch only `versus_isfullshit` to the new loader and add the existing approved mode ConVars.
- [x] Delete the exact retired Supergirl source/binary after the previous compilation.
- [x] Run the updated contract, compile, `git diff --check`, status/diff audit, and record residual live-server checks.
