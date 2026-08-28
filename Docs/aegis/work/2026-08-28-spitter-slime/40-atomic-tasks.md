# Atomic Tasks

- [ ] Add `tests/l4d2_spitter_slime_contract.tests.ps1` and observe its missing-source failure.
- [ ] Add the new SourcePawn ConVars and per-Spitter/child-entity state.
- [ ] Add lifecycle hooks, idempotent cleanup, and the global slime update timer.
- [ ] Add native visible slime creation, random local arcs, visible-survivor selection, tracking arcs, hit radius, and SDKDamage.
- [ ] Add the `IN_ATTACK` ability forward replacement, gas-can ballistic launch, touch guard, particle/sound effects, SDKDamage blast targeting, and direct velocity knockback.
- [ ] Compile the new plugin and generate `addons/sourcemod/plugins/optional/l4d2_spitter_slime.smx`.
- [ ] Switch only `versus_isfullshit` to the new loader and add all approved mode ConVars.
- [ ] Delete the exact retired Supergirl source/binary after new compilation.
- [ ] Run contract, compile, `git diff --check`, status/diff audit, and record residual live-server checks.
