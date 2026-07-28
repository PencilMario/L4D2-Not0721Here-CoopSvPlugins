# Intent

Split `l4d2_sb_ai_improver.sp` into internal include modules without changing bot behavior. Existing SourcePawn 1.12 compilation incompatibilities may be repaired separately when required to establish a buildable baseline.

Non-goals: algorithm changes, scheduling changes, ConVar renames, plugin-to-plugin APIs, and performance claims based solely on file splitting.
