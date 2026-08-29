# Atomic Tasks

- [x] Add `tests/l4d2_spitter_slime_contract.tests.ps1` and observe its missing-source failure.
- [x] Add the new SourcePawn ConVars and per-Spitter/child-entity state.
- [x] Add lifecycle hooks, idempotent cleanup, and the global slime update timer.
- [x] Add native visible slime creation, random local arcs, visible-survivor selection, tracking arcs, hit radius, and SDKDamage.
- [x] Add the `IN_ATTACK` ability forward replacement, gas-can ballistic launch, touch guard, particle/sound effects, SDKDamage blast targeting, and direct velocity knockback.
- [x] Compile the new plugin and generate `addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx`.
- [x] Switch only `versus_isfullshit` to the new loader and add all approved mode ConVars.
- [x] Delete the exact retired Supergirl source/binary after new compilation.
- [x] Run contract, compile, `git diff --check`, status/diff audit, and record residual live-server checks.
