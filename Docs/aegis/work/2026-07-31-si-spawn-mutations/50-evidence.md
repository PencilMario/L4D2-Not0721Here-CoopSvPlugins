# SI Spawn Mutation Class Limits Evidence

## Red-green evidence

- RED: `pwsh -NoProfile -File tests/si_spawn_mutation_limits.tests.ps1`
  exited 1 before implementation and reported missing `mp_gamemode`, refresh
  callback, all three mutation mappings, and documentation.
- Intermediate: after the SourcePawn change, the same test exited 1 only for
  the three missing documentation entries.
- GREEN: after the README change, the focused contract exited 0 and reported
  all three mappings, hot refresh, and engine-limit documentation present.

## Build evidence

The user-provided SourcePawn 1.12.0.7221 compiler built
`addons/sourcemod/scripting/Si_SpawnSetting.sp` to
`addons/sourcemod/plugins/Si_SpawnSetting.smx` with the repository scripting
and include paths plus the Competitive-Rework include path. The first green
build exited 0 with code size 43052 bytes, data size 14340 bytes, and total
requirements 75916 bytes.

## Regression evidence

All eight `tests/*.ps1` scripts exited 0 after implementation, including the
new mutation contract. `git diff --check` was clean after restoring the source
file's minimal line-ending diff.

## Compatibility and residual risk

- General-mode allocation and DPS-limit code remain unchanged and are reached
  whenever the mutation allocator returns false.
- No class-limit clamp was added; 14 per class remains an engine constraint.
- The generated tracked SMX is updated by the verified compiler command.
- Runtime switching on a live Left 4 Dead 2 server was not exercised locally.
  Operators can set `mp_gamemode` to `mutation17`, `mutation16`, `mutation11`,
  and a normal mode in turn, then inspect Director class limits without a map
  change.
