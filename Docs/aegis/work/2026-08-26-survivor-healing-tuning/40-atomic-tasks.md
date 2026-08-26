# Atomic Tasks

- [x] Add the static healing contract test and confirm it fails on the old 60/0.15 profile and unmodified plugin.
- [x] Change only `automatic_healing_repeat_interval`, `automatic_healing_max`, and add `level_start_heal_health` in `versus.cfg`; leave `automatic_healing_health` absent.
- [x] Add the guarded `m_iMaxHealth` assignment to `level_start_heal.sp`.
- [x] Re-run the contract test and compile `level_start_heal.smx` with the project SourcePawn compiler.
- [x] Run binary existence, diff-check, status, and source/config review; record evidence and residual runtime risk.
