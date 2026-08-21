# Evidence: Survivor Bot Bone Query Guard

## RED

Command:

```powershell
& '.\tests\l4d2_sb_ai_bone_guard.tests.ps1'
```

Result: exit code `1`, with the expected missing-contract failure:
`Missing required bone guard contract: bool LBI_IsBoneQueryReady(int iEntity)`.

## GREEN and regression checks

Commands:

```powershell
& '.\tests\l4d2_sb_ai_bone_guard.tests.ps1'
& '.\tests\l4d2_sb_ai_improver_modules.tests.ps1'
```

Results:

- `l4d2_sb_ai bone guard contract passed`
- `l4d2_sb_ai_improver module contract passed`

## Compiler

The approved SourcePawn 1.12 compiler and project include paths compiled `l4d2_sb_ai_improver.sp` to a temporary SMX and then to the tracked `addons/sourcemod/plugins/l4d2_sb_ai_improver.smx`.

Final compiler output:

```text
Code size:         235452 bytes
Data size:         3488080 bytes
Stack/heap size:   17088 bytes
Total requirements: 3740620 bytes
```

Both compiler invocations exited with code `0`.

## Scope and residual risk

- `git diff --check` exited with code `0`.
- The only SourcePawn changes are `aiming.inc` and `navigation.inc`.
- The tracked `l4d2_sb_ai_improver.smx` was intentionally rebuilt.
- No gamedata, unrelated plugin, server process, or server configuration was changed.
- Runtime reproduction on Linux L4D2, especially `c3m2_swamp`, remains unverified. The readiness check is defensive but cannot make the model check and engine SDKCall atomic.
