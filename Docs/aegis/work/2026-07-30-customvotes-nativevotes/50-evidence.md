# Verification evidence

## Automated evidence

- Migration contract:
  `Docs/aegis/work/2026-07-30-customvotes-nativevotes/verify.ps1`
  exited 0 with `CustomVotes NativeVotes migration contract passed.`
- SourcePawn build: the user-supplied `spcomp.exe` 1.12.0.7221 command exited
  0 with no errors or warnings. The generated `customvotes.smx` requires
  190816 bytes according to the compiler and is written to the repository
  plugins directory.
- Retirement search: accumulated-vote owners, `VoteMenu(`, and parsing of the
  legacy `vote`/`multiple` keys produced zero matches in `customvotes.sp`.
- `git diff --check` exited 0 after normalizing the source file back to the
  repository's LF line endings.
- `addons/sourcemod/plugins/nativevotes.smx` exists, and the include is loaded
  with `REQUIRE_PLUGIN` semantics.
- `BuildActiveVoteTitle` removes Multicolors tags before NativeVotes receives
  the details/pass text; chat notifications retain their `CPrintToChatAll`
  color processing.

## Review evidence

Independent code review found one Important issue: NativeVotes could have been
optional under include configurations that did not predefine `REQUIRE_PLUGIN`.
The include is now wrapped in a conditional required-dependency definition, and
the static contract checks that definition. The reviewer found no other
Important or Critical issue in result counts, threshold calculation,
cancellation ordering, target identity, or simple-vote substitution.

## Runtime residual risk

No L4D2 server session was available in this environment. Runtime-check the
native vote panel for player, map, list, and simple votes; pass, threshold loss,
no-vote, and cancellation; team-restricted pools; spectators and bots; target
disconnect and slot reuse; map transition/plugin unload; config reload during a
vote; and conflict with another SourceMod or NativeVotes vote.

Confidence is B: compile, static retirement, API-source inspection, and
independent review cover the implementation directly, while actual game UI and
server lifecycle behavior remain unverified.
