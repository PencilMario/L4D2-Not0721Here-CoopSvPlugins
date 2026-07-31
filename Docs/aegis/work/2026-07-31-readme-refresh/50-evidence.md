# README Refresh Evidence

## Scope

- Runtime configuration and plugin files were read as authority but not modified.
- The content change is limited to `Docs/readme.md`.
- Task records were updated under `Docs/aegis/`.

## Configuration Coverage

Compared every directory under `cfg/cfgogl/` with `addons/sourcemod/configs/matchmodes.txt` and the rewritten README.

```text
menu_modes_documented=24/24
non_menu_directory=profession
```

`profession` is not exposed by the current match-mode menu and was not presented as a selectable configuration.

## Structural Validation

PowerShell checks over the final Markdown reported:

```text
details_tags=24/24
code_fences=4
local_links=10
broken_local_links=0
```

## Stale Terminology Scan

Scanned `Docs/readme.md` for:

```text
mutation4_expect
realisn_jimen
script_reloader
sm_setspawn
sm_setinterval
```

Result: zero matches.

## Whitespace And Scope

`git diff --check` completed without errors. Before recording evidence, the content diff was:

```text
Docs/readme.md | 1012 lines changed
385 insertions, 627 deletions
```

The initial rewrite reduced the README from 1012 lines to 385 lines while documenting all 24 current menu configurations.

## Follow-up: AI Damage Fix Coverage

The README now records the effective `sm_aidmgfix_enable` value for all 24 menu configurations. Values were compared against every mode CFG, with the plugin default of `3` used when a mode does not override the ConVar; all 24 mappings matched. The historical plugin source confirms the bitmask semantics: `1` for AI Hunter skeet/pounce handling, `2` for AI Charger charging damage, `3` for both, and `0` for off. `z_pounce_damage_interrupt` is `150` in `cfg/cfgogl/coop_base/shared_cvars.cfg`.

The current README length after this follow-up is 399 lines.

## Drift Check

- Original intent: update stale README content and improve formatting.
- Compatibility boundary: configuration names and intentional display names are preserved from the current menu definition.
- Runtime owners: unchanged.
- Retired duplicate: the copied full plugin load list was replaced by categorized summaries and canonical links.
- Decision: continue to final diff review and completion verification.
