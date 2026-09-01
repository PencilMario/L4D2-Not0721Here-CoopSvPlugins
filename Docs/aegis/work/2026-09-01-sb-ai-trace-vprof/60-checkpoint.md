# Todo Checkpoint Draft

## Current state

- Active slice: Task 1, Trace category instrumentation.
- Completed: isolated worktree created; clean baseline tests 30/30 passed.
- Pending: implementer changes, targeted test, spec/code-quality review, compile.
- Blockers: no local L4D2 live server; runtime VProf re-sampling remains external.
- Next: review Task 1 diff, then run targeted/full static tests and compiler.

## Drift check

- Scope: instrumentation first; no behavior or cache semantics changed yet.
- Compatibility: public forwards/ConVars and existing Trace branches must remain unchanged.
- Retirement: per-Trace diagnostics must stay behind the performance-logging gate and can be removed after live attribution.
- Decision: continue.
