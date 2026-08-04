# Baseline read set

- `Docs/aegis/specs/2026-08-04-maphint-deepl-fallback-design.md`: approved behavior and non-goals.
- `addons/sourcemod/scripting/maphint_translator.sp`: queue, retry, cache, waiter, and RIPExt owners.
- `tests/maphint_translator_ripext_contract.tests.ps1`: existing executable source contract.
- User-supplied `AGENTS.md` instructions: known-good compiler command applies to `MapChanger.sp`; for this plugin use the same SourcePawn 1.12 compiler and project include paths with the input/output changed to `maphint_translator.sp/.smx`.

No unresolved authority gap remains. Runtime calls to external APIs are not
available as a deterministic automated test, so response behavior is protected
by source contracts plus compilation; live provider verification remains a
deployment check.
