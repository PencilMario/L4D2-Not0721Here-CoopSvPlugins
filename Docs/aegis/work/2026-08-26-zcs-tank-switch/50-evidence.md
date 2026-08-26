# Zombie Character Select Tank Switch Evidence

## Verification

- RED: `pwsh -NoProfile -File tests/l4d2_zcs_tank_switch.tests.ps1` failed on the incomplete baseline with the expected missing Tank limit reload, selection helper, class cycle, and HUD/limit integration.
- GREEN: the same contract test returned exit code `0` and printed `Zombie Character Select Tank contract passed`.
- Compile: SourcePawn Compiler `1.12.0.7221` compiled `l4d2_zcs_redux.sp` to a temporary `.smx` with exit code `0`. The compiler reported the existing `CreateDialog` deprecation warning and the two pre-existing unused SI-name array warnings.
- Final main-worktree compile: the same compiler produced the temporary `.smx` with exit code `0` and two pre-existing unused SI-name array warnings.
- Whitespace: `git diff --check -- addons/sourcemod/scripting/l4d2_zcs_redux.sp` returned exit code `0`; the CRLF-aware check also passed for the changed source, test, and evidence files. The full main-worktree diff still flags trailing `CR` bytes on the pre-existing user-edited `versus.cfg` additions, which were preserved unchanged.

## Scope proven

- `zcs_tank_limit` is created with default `0` and bounds `0..10`.
- Tank is accepted by `sm_buy tank`, the ghost class-selection path, the class cycle (`Charger -> Tank -> Smoker`), per-class counting/limits, and the HUD.
- Tank has an independent limit slot and is excluded from the ordinary special-infected total.
- No Tank cooldown ConVar was added; the existing cooldown delay assignments remain limited to the six ordinary special-infected classes.

## Runtime follow-up

No live L4D2 server was available, so materialization and engine-side Tank switching remain unverified. Manual check: set `zcs_tank_limit 1`, enter ghost state, cycle to Tank or issue `sm_buy tank`, materialize, and verify a second Tank selection is rejected while ordinary SI totals are unchanged.
