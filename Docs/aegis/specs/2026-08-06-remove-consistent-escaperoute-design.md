# Remove Consistent Escape Route Plugin

**Status:** Approved

## Intent

Remove the versus-only `l4d_consistent_escaperoute` plugin from this campaign-server package, and add the missing `l4d2_source_keyvalues` dependency required by the existing VScript purifier. The package must stop loading the former and load the latter before its consumer.

## Scope

- Remove the `sm plugins load fix/l4d_consistent_escaperoute.smx` line from `cfg/generalfixes.cfg`.
- Remove `addons/sourcemod/plugins/fix/l4d_consistent_escaperoute.smx`.
- Remove `addons/sourcemod/gamedata/l4d_consistent_escaperoute.txt`.
- Add the upstream `addons/sourcemod/scripting/l4d2_source_keyvalues.sp` source from `fdxx/l4d2_source_keyvalues` at commit `c07cb559a62c14fa61c17f1244f185e2078f4330`.
- Compile `addons/sourcemod/plugins/l4d2_source_keyvalues.smx` and load it before `fix/l4d2_vscript_purifier.smx`.
- Add the upstream GPL-3.0 license text at `LICENSES/l4d2_source_keyvalues-GPL-3.0.txt`.
- Leave `left4dhooks`, `l4d_predict_tank_glow`, and all other fix plugins unchanged.

## Compatibility Boundary

The campaign package must continue loading all remaining entries in `generalfixes.cfg`. The new plugin must use the existing matching include and gamedata, expose the `l4d2_source_keyvalues` library, and load before its consumer. No shared gamedata is removed. The retired plugin's missing `TheEscapeRoute` startup error is expected to disappear from future server logs.

## Verification

Confirm that no deployment or source file outside `Docs/aegis` references `l4d_consistent_escaperoute`, the retired paths no longer exist, the new source compiles successfully, and `git diff --check` succeeds.
