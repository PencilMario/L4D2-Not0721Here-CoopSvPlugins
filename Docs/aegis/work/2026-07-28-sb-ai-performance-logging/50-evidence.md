# Evidence

- Contract: tests/l4d2_sb_ai_performance_logging.tests.ps1 covers Logger inclusion, ConVars, threshold conversion, unified warning output, and wrappers for nine hot paths.
- Structural regression: tests/l4d2_sb_ai_improver_modules.tests.ps1 protects the modular include graph.
- Compiler: SourcePawn 1.12.0.7221 using the user-provided compiler and include paths.
- Retirement: the old Profiler dependency and PrintToServer slow-navigation messages were removed. GetEngineTime wrappers and Logger.warning are the sole slow-calculation owner.

Runtime usage:

    ib_performance_logging 1
    ib_performance_threshold_ms 1.0

Output: addons/sourcemod/logs/sb_ai_performance.log.

Residual risk: actual server load and log frequency require a live campaign test. Logger warnings intentionally also appear in the server console according to logger.inc behavior.
