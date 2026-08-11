# Transition Restore Fix Evidence

## RED

Before the SourcePawn change:

```text
pwsh -NoProfile -File tests/transition_restore_fix_contract.tests.ps1
```

Failed as expected because the source requested `SavedPlayerCount` while the gamedata defines `SavedPlayersCount`.

## GREEN

After the SourcePawn change:

```text
transition restore contract passed.
```

The test verifies plural address lookups, the `PlayerSaveData::Restore` detour, both bot-data selectors, the matching gamedata keys, and the canonical explicit plugin loader.

The review hardening also verifies conditional saved-model precaching, valid survivor entities, and non-reuse of consumed bot records. A missing exact bot match falls back to the game's original record instead of forcing a mismatched or duplicated inventory record.

## Compile

The project SourcePawn 1.12 compiler completed successfully:

```text
Code size:         14652 bytes
Data size:         6028 bytes
Stack/heap size:   16908 bytes
Total requirements: 37588 bytes
```

Output: `addons/sourcemod/plugins/fix/transition_restore_fix.smx`.

## Regression

13 of 14 repository PowerShell tests passed. The existing `check_release_updater_names.ps1` is blocked by the missing repository file `install_release_updaters.sh`; it is unrelated to this change. `git diff --check`, transition-specific final invariants, and explicit-load invariants passed.

## Runtime gap

No live L4D2 server was available. Chapter transition and mission-restart inventory preservation, including `weapon_melee`, still require manual server verification.
