# Transition Restore Fix Intent

**Requested outcome:** Repair transition restore so the plugin loads against its gamedata and selects the complete survivor save record, including weapon and item state.

**Scope:** Repair `addons/sourcemod/scripting/transition_restore_fix.sp`, keep `cfg/generalfixes.cfg` as the canonical explicit loader, remove invalid duplicate mode-config load lines, and add a PowerShell contract test. Keep the existing custom gamedata and the previously deleted root plugin artifact unchanged.

**Non-goals:** Do not modify Left 4 DHooks itself, add a `weapon_melee`-specific runtime special case, or restore `addons/sourcemod/plugins/transition_restore_fix.smx`.
