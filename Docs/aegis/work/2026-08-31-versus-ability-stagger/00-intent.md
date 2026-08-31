# Task Intent

## Requested outcome

In the `versus_isfullshit` configuration, abilities supplied by the custom Tank and Smoker plugins must no longer hard-stagger or fling survivors. The abilities' non-stagger effects remain active.

## Scope

- `L4D2 Hulking Tank.sp` and its compiled optional plugin.
- `L4D2 Noxious Smoker.sp` and its compiled optional plugin.
- `cfg/cfgogl/versus_isfullshit/versus.cfg`.
- A static contract test for the SourcePawn/configuration boundary.

## Acceptance criteria

1. The mode sets separate Tank and Smoker ability-stagger controls to `0`.
2. The plugin source gates only its own ability-induced `Fling`/`OnStaggered` calls.
3. Damage and other ability paths remain reachable when the controls are disabled.
4. The default value of each new control is `1`, preserving behavior in other modes.
5. The contract test passes and both changed plugins compile with the project's SourcePawn 1.12 compiler.

## Compatibility boundary

The change must not block normal Tank attacks, unrelated plugins, or the same plugins when the new controls retain their default value.

## Known verification limit

No running L4D2 server is available in this workspace, so the final runtime animation/physics result requires an in-game smoke test after deployment.
