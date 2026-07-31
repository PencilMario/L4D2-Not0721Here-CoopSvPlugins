# Charger Melee 350 Evidence

## RED

Before changing mode CFG files:

```text
charger_melee_damage_contract failed
13 selectable modes with effective sm_aidmgfix_enable=3 were missing l4d2_melee_damage_charger 350
```

The failure was the intended missing-configuration assertion.

## GREEN

After adding explicit overrides to the bit-2 modes:

```text
charger melee damage contract passed: 24 selectable modes checked, 13 modes fixed at 350
```

The test also rejects any 350 override when the effective AI damage bitmask is `0` or `1`.

## Runtime Semantics

- `l4d2_melee_damage_control.sp` hooks melee damage to infected survivors and detects Charger separately.
- `l4d2_melee_damage_charger` controls fixed Charger damage and defaults to `-1` (disabled).
- For a positive value, damage is `min(current Charger health, configured value)`, so the final hit cannot overkill.
- The affected mode CFG files now set `l4d2_melee_damage_charger 350` alongside the effective `sm_aidmgfix_enable=3` behavior.
- Modes with `sm_aidmgfix_enable=0` retain no Charger melee override.

## Scope

Changed runtime owners are limited to 13 mode-specific CFG files. No `sm_aidmgfix_enable` values or plugin source were changed. README and the contract test document and protect the binding.

## Regression

All seven PowerShell checks under `tests/` passed:

```text
bot_catchup_speed contract passed
charger melee damage contract passed: 24 selectable modes checked, 13 modes fixed at 350
release updater naming checks passed
unreservelobby empty timeout checks passed
l4d_teamspanel ConVar regression check passed
l4d2_sb_ai_improver module contract passed
l4d2_sb_ai performance logging contract passed
ALL_POWERSHELL_TESTS_PASSED
```
