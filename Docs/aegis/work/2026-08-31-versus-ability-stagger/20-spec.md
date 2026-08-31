# Versus Ability Stagger Design

## Goal

Prevent only the custom Tank and Smoker abilities from applying survivor hard-stagger/fling behavior in `versus_isfullshit`, while retaining their damage and other effects.

## Architecture

Each plugin owns a new boolean ConVar:

- `l4d_htm_ability_stagger`, default `1`.
- `l4d_nsm_ability_stagger`, default `1`.

The Tank helper functions check the first control immediately before their SDK Fling call. The Smoker ability code checks the second control immediately before each SDK Fling or direct `OnStaggered` call. The profile sets both controls to `0`.

This keeps the behavior boundary local to the two plugin owners. A global Left4DHooks stagger blocker is intentionally not used because it could also suppress ordinary Tank attack reactions or stagger events from unrelated plugins.

## Affected behavior

- Tank: Smouldering Earth, Titan Fist (including the incap follow-up), and Titanic Bellow no longer call the custom Fling SDK function when disabled.
- Smoker: Methane Blast, Tongue Whip, and Void Pocket no longer call the custom Fling SDK function when disabled; Methane Strike no longer calls the custom `OnStaggered` SDK function when disabled. Methane Blast has two guarded Fling call sites, one for each blast range.
- All existing damage calls and ability state/cooldown logic remain in place.

## Compatibility and non-goals

- Default `1` preserves existing behavior outside this mode.
- Ordinary Tank claw attacks, Charger/Hunter behavior, global stagger hooks, and unrelated plugins are out of scope.
- The profile-specific setting does not change the plugin's globally compiled default.

## Verification

The PowerShell contract test verifies the new default-on ConVars, profile-off overrides, and guards around every custom stagger call. The two SourcePawn files are compiled with the repository's known-good compiler. A live server smoke test remains the runtime verification step after deployment.
