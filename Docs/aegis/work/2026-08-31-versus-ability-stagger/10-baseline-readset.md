# Baseline Read Set

## Authority and project constraints

- `AGENTS.md`: known-good SourcePawn compiler location and include paths; accepted legacy warnings.
- `README.md`: repository is the deployable L4D2 server plugin package.
- `Docs/aegis/README.md`: task records belong under the Aegis documentation tree.

## Relevant implementation facts

- `cfg/cfgogl/versus_isfullshit/confogl_plugins.cfg` loads `optional/L4D2 Hulking Tank.smx` and `optional/L4D2 Noxious Smoker.smx`.
- `addons/sourcemod/scripting/L4D2 Hulking Tank.sp` creates three ability paths that call `CTerrorPlayer::Fling`: Smouldering Earth, Titan Fist, and Titanic Bellow. Its incap follow-up uses the Titan Fist path.
- `addons/sourcemod/scripting/L4D2 Noxious Smoker.sp` calls `CTerrorPlayer::Fling` for Methane Blast, Tongue Whip, and Void Pocket, and calls `CTerrorPlayer::OnStaggered` for Methane Strike.
- The profile already owns mode-specific ConVar overrides in `cfg/cfgogl/versus_isfullshit/versus.cfg`.
- Existing repository contract tests are PowerShell scripts that read source/config files and throw a named failure when a contract is missing.

## User-approved design

Add one default-on, mode-configurable stagger gate to each custom plugin. The profile turns both gates off. The gate is checked at the custom call sites, leaving the damage and other ability logic intact.
