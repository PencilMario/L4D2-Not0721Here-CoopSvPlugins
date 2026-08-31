# Verification Evidence

- Compiler command: project SourcePawn compiler `1.12.0.7221` compiled `l4d2_sb_ai_improver.sp` to `addons/sourcemod/plugins/l4d2_sb_ai_improver.smx`; exit code `0`. Reported data size: `13,689,604` bytes.
- Complete contract command: iterated every `tests/*.tests.ps1` in sorted order; all `23` tests passed, including the pinned-reaction, navigation-cache, performance-file/debug, infected-count, inventory-cache, path-danger, and remaining-optimization contracts.
- Scoped whitespace check: `git -c core.whitespace=cr-at-eol diff --check` passed for the changed source, loader, cvar, and test files.
- Full whitespace check: reports only the two preserved trailing-space lines in the user-modified `cfg/cfgogl/versus_isfullshit/confogl.cfg`; those historical formatting changes were intentionally not rewritten.
- Configuration evidence: `shared_plugins.cfg` loads `l4d2_sb_ai_improver.smx`; `versus.cfg` enables performance logging/debug and sets `ib_help_pinned_reaction_bots 2`.

## Residual Risk

- No live Left 4 Dead 2 server session was available, so in-game navigation/VScript behavior, runtime cvar reload, logger file creation, and measured 10+ Bot frame time remain unverified.
- Cache results can remain valid for at most one current `ib_process_time` window and may therefore be up to that interval behind moving world state.
- The rebuilt SMX is tracked and corresponds to the verified source, but deployment/load compatibility with the server's installed extensions and gamedata still requires an in-game smoke test.
