# Charger Melee 350 Evidence

## Revised RED

After narrowing the rule to explicit declarations, the contract test rejected nine modes that inherited the plugin default but incorrectly carried a 350 override:

```text
coop_base
coop_hard
coop_fire
coop_himiko
realism_solo
mutation4_solo
mutation4_ez
community5_ez
coop_annelike
```

## GREEN

After removing those nine overrides:

```text
charger melee damage contract passed: 24 selectable modes checked, 4 explicit bit-2 modes fixed at 350
```

The four explicit modes are `community5_multi`, `mutation4_noobplus`, `community5_noobplus`, and `community5_himiko`. The test rejects a Charger melee override for explicit values `0` or `1` and for modes without an explicit `sm_aidmgfix_enable` declaration.

## Runtime Semantics

- `l4d2_melee_damage_control.sp` detects Charger separately from the general melee hitgroup fix.
- `l4d2_melee_damage_charger` defaults to `-1` (disabled).
- For a positive value, damage is `min(current Charger health, configured value)`, so the final hit cannot overkill.
- The four explicit bit-2 mode CFG files set `l4d2_melee_damage_charger 350`.
- No `sm_aidmgfix_enable` value or plugin source was changed.

## Scope

Runtime changes are limited to four mode-specific CFG files. README and the contract test document and protect the explicit-declaration boundary.

## Regression

All seven PowerShell tests passed after the correction. Repository checks found exactly four CFG files with `l4d2_melee_damage_charger 350` and exactly four README mode rows marked with 350.
