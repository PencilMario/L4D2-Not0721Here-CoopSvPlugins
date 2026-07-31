# SI spawn mutation class-limit design

## Intent

Preserve the special-infected class restrictions of three official mutation
modes while continuing to let `Si_SpawnSetting.sp` own the total special count,
respawn interval, automatic scaling, Relax behavior, and Director script-value
overrides.

The affected game modes are:

| Game mode | Display name | Allowed classes |
| --- | --- | --- |
| `mutation17` | Riding My Survivor / 骑乘派对 | Jockey only |
| `mutation16` | Flu Season / 感染季节 | Boomer and Spitter only |
| `mutation11` | Hunting Party / 寻猎派对 | Hunter only |

## Allocation behavior

Class-limit calculation reads the current `mp_gamemode` value and selects one
allocation order:

- `mutation17`: allocate every slot to Jockey.
- `mutation16`: alternate slots between Boomer and Spitter.
- `mutation11`: allocate every slot to Hunter.
- Every other mode: retain the existing Hunter, Jockey, Smoker, Charger,
  Spitter, Boomer allocation and DPS-limit behavior unchanged.

`si_spawn_max_specials` remains the total allocation count. In `mutation16`, an
odd count gives the first class in the defined order one additional slot. The
mode-specific allocation ignores `si_spawn_dps_special_limit`, because applying
that general-mode filter would remove one or both of the mutation's required
classes.

The engine limits a single special-infected class to 14 simultaneous
instances. This is documented operational information, not a plugin validation
rule: the implementation does not clamp class limits to 14. Consequently,
Mutation 16 can reach 14 Boomers plus 14 Spitters, for 28 simultaneous special
infected when the configured total and engine state permit it.

## Refresh lifecycle

The plugin obtains the existing `mp_gamemode` ConVar during startup and hooks
its changes. A game-mode change recalculates cached Director values immediately,
so server operators do not need to reload the plugin or change the map. Startup,
round-start, automatic-scaling, and administrator setting changes continue to
use the existing `RefreshDirectorSettings` path.

If `mp_gamemode` cannot be found, allocation falls back to the existing general
six-class behavior. No new public ConVar or command is introduced.

## Compatibility boundary

Only the three named mutations receive specialized class allocation. Mode-name
matching is case-insensitive. All other modes retain their current class order,
DPS-limit semantics, configuration surface, chat output, and scaling rules.

The change does not enforce the engine's per-class limit, modify mutation
VScript files, or alter spawn timing and Relax behavior.

## Documentation

The repository configuration guide's spawn-mechanism section will list the
three mutation mappings, state that the DPS limit is bypassed for their fixed
class sets, and explain the engine's 14-per-class limit. It will explicitly
state that Mutation 16 can therefore have up to 28 simultaneous special
infected across its two allowed classes.

## Verification

1. Add a source-level regression check that initially fails until all three
   mutation mappings, their allowed allocation orders, and the game-mode change
   refresh hook exist.
2. Verify the general allocation and DPS-limit path remains present.
3. Compile `Si_SpawnSetting.sp` with the repository's SourceMod compiler and
   include tree.
4. Run the focused regression check, `git diff --check`, and inspect the final
   diff for unrelated changes.
5. Runtime verification should change `mp_gamemode` among the three mutations
   and a normal mode, then inspect Director class limits and confirm they update
   without a map change.

## Design inputs

- Task intent: support the official class restrictions of Mutation 17,
  Mutation 16, and Mutation 11, and document the engine limit.
- Baseline read set: `Si_SpawnSetting.sp`, the spawn-mechanism section of
  `Docs/readme.md`, recent SI Director-hook and naming specifications, and the
  repository compiler layout.
- Impact: cached class-limit calculation, game-mode change lifecycle, focused
  regression coverage, and operator documentation. Public configuration and
  all unrelated modes are compatibility invariants.

