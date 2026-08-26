# Baseline Read Set

## Authority

- `AGENTS.md`: local compiler and include-path conventions.
- `README.md`: repository purpose and deployment boundary.
- `Docs/aegis/README.md` and `Docs/aegis/INDEX.md`: local task-record conventions.

## Target

- `addons/sourcemod/scripting/L4D2_NEW_GG_3_9_2026_CN.sp`: private 2026 L4D2 Gun Game source, 20,112 lines and 596,115 bytes.
- Existing `addons/sourcemod/scripting/modules/` and `confoglcompmod.sp`: repository patterns for textual include composition.

## Reference-only dependency source

- `D:\Windows\Download\L4D_GunGame\scripts\L4D2_NEW_GG_3_9_2026_CN.sp`: SHA-256 matches the workspace target.
- `D:\Windows\Download\L4D_GunGame\scripts\spcomp.exe`: legacy SourcePawn 1.6 compiler that compiles the baseline.
- `D:\Windows\Download\L4D_GunGame\scripts\include\smlib.inc` and `socket.inc`: legacy include references.
- `D:\Windows\Download\L4D_GunGame\scripts\translations\gungame.phrases.txt`: translation dependency reference.
- `D:\Windows\Download\L4D_GunGame\addons\sourcemod\gamedata\l4d_takeover.txt`, `l4drespawn.txt`, and `gg_weapons.txt`: gamedata references.

The reference directory is read-only for this task. Its pre-existing dirty state is not part of the implementation and must not be normalized.
