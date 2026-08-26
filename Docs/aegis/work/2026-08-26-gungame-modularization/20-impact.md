# Impact Statement Draft

- Affected layer: one private SourcePawn compilation unit and its local include/gamedata/translation dependencies.
- Runtime owner: the existing single Gun Game `.smx`; no new runtime plugin boundary.
- Invariants: lifecycle callbacks have one owner, shared arrays/handles have one declaration, entity and timer cleanup stays with the creating module, and all public commands/ConVars/data formats remain stable.
- Highest risks: implicit cross-region globals, callback ordering, timer payloads, entity reuse, duplicated hooks, and accidental public staging of paid code.
- Non-goals: gameplay changes, dependency modernization, public release, remote Git operations, and server deployment.
