# CustomVotes NativeVotes migration design

## Intent

Replace every final yes/no voting session in `customvotes.sp` with the L4D2
NativeVotes interface. SourceMod menus remain only for choosing a vote type and
its player, map, or configured option. Selecting that subject immediately
starts one NativeVotes session; the accumulated-selection voting mode is
retired completely.

The migration preserves configured commands, cooldowns, call limits, pass
limits, notifications, target substitution, and subject-selection behavior.
Vote thresholds change deliberately to use only the clients eligible for the
current NativeVotes session.

## Voting flow

1. A client opens the existing custom vote menu or uses a configured chat
   trigger.
2. Player, map, and list votes use their existing SourceMod selection menus to
   choose a subject. A simple vote has no subject-selection step.
3. The plugin validates access, cooldown, minimum eligible clients, NativeVotes
   support, and whether either SourceMod or NativeVotes already owns a vote.
4. The plugin creates a `NativeVotesType_Custom_YesNo` vote and displays it to
   the eligible client pool for 30 seconds.
5. NativeVotes supplies the final result counts. The plugin evaluates the
   configured threshold, displays the native pass or failure screen, emits the
   configured notification, and executes the configured command on success.
6. Completion, cancellation, display failure, map transition, and plugin unload
   all clear the active-vote context.

## Eligible clients and threshold

Bots and spectators never enter a NativeVotes pool. Player-target votes also
exclude the target. When a player vote enables its existing team restriction,
only non-spectator human clients on the initiator's team are eligible. Other
vote types include every non-spectator human client.

The required yes votes are:

```text
max(minimum, ceil(eligible_client_count * ratio))
```

`minimum` also remains the minimum eligible-client count required to start the
vote. Abstentions therefore count against passage because the denominator is
the full eligible pool, while ineligible clients do not affect the threshold.

## Active vote context

Because only one vote may run at a time, one global context owns the active
session. It stores the configured vote index, initiator userid, subject kind,
subject index where applicable, eligible-client count, and stable player-target
identity data (userid, SteamID, and name). The context is initialized before
display and reset atomically on every terminal path.

Player commands must not act on a reused client slot. If the target disconnects,
the stored SteamID and name remain available for notification formatting, but a
command that requires a live client index must not be applied to a replacement
client.

## Retired state and configuration

The refactor removes the per-client target, map, option, and simple-vote boolean
arrays; SteamID/IP accumulated-vote recovery arrays; vote-count helper
functions; and accumulated-vote checks triggered by connect, authorization, or
disconnect events. Selection-menu labels no longer show accumulated counts.

The legacy `vote` and `multiple` configuration keys are accepted but ignored so
existing configuration files continue to load. They are documented as obsolete
in the repository configuration example. No ordinary-menu voting fallback is
provided when NativeVotes is absent or unsupported.

## Notifications and results

`startnotify` is emitted only after NativeVotes successfully displays the
session. `callnotify` is emitted when an eligible client selects Yes or No.
`passnotify` and the configured server command run exactly once after the custom
threshold passes. `failnotify` runs once when the threshold fails, the vote has
no votes, or the session is cancelled after display.

Every completed NativeVotes session calls an appropriate native pass or failure
display API so the L4D2 vote panel is cleared correctly. A display failure closes
the new handle, clears context, and reports the failure to the initiator without
consuming a successful pass.

## Compatibility boundary

The plugin gains a required runtime dependency on NativeVotes and includes the
repository's `nativevotes.inc`. It does not fall back to SourceMod vote menus.
Subject-selection menus and the public `sm_votemenu`, reload command, and chat
triggers remain intact.

The configured ratio now uses the eligible NativeVotes pool rather than every
connected human. This intentionally fixes team-restricted votes being blocked
by humans who could not receive the vote.

## Verification

1. Compile `customvotes.sp` with the repository compiler and include directory.
2. Search `customvotes.sp` for retired accumulated-vote arrays and require zero
   matches.
3. Check player, map, list, and simple votes with pass, threshold loss, no-vote,
   cancellation, and display-failure paths.
4. Check player votes with team restriction, spectators, bots, target exclusion,
   target disconnect, and client-slot reuse.
5. Check custom ratio and minimum values against the exact eligible pool.
6. Check cooldown, maximum calls, maximum passes, every notification, command
   substitution, and conflicts with another SourceMod or NativeVotes vote.
7. Run `git diff --check` and inspect the changed-file list for unrelated edits.

## Design inputs

- Task intent: retain subject-selection menus but hard-cut all final voting over
  to NativeVotes and remove accumulated menu voting completely.
- Baseline read set: `customvotes.sp`, `customvotes.cfg`, `nativevotes.inc`, the
  repository NativeVotes test plugins, recent project design records, and the
  current clean worktree.
- Impact: final vote UI, result collection, eligibility calculation, disconnect
  handling, configuration documentation, and runtime dependencies change;
  selection menus, public entry points, configured actions, and notification
  formats remain owned by CustomVotes.
- Non-goals: replacing subject-selection menus with NativeVotes, changing the
  configuration file format broadly, or migrating the entire plugin to modern
  SourcePawn syntax.
