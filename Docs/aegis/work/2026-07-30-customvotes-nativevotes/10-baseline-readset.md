# Baseline read set

- `Docs/aegis/specs/2026-07-30-customvotes-nativevotes-design.md`: approved behavior and compatibility boundary.
- `addons/sourcemod/scripting/customvotes.sp`: current owner of selection menus, accumulated votes, notifications, and commands.
- `addons/sourcemod/configs/customvotes.cfg`: public configuration examples and obsolete-key documentation.
- `addons/sourcemod/scripting/include/nativevotes.inc`: runtime API contract.
- `addons/sourcemod/scripting/nativevotes_votetest.sp`: repository examples for lifecycle and result display.

The user supplied SourcePawn 1.12.0.7221 compiler invocation is the authoritative
compile check. Baseline compilation succeeds with warnings 203 for unused
`iVote` parameters in `FormatVoterString` and `FormatTargetString`.
