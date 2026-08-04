# Verification evidence

## TDD evidence

- DeepL contract RED: `tests/maphint_translator_ripext_contract.tests.ps1`
  exited 1 with `DeepL key ConVar is missing` before provider implementation.
- Startup-progress contract RED: the same test exited 1 with
  `progress ConVar is missing` before progress implementation.
- Both slices reached GREEN with `maphint_translator RIPExt contract passed`.

## Compilation

SourcePawn 1.12.0.7221 compiled
`addons/sourcemod/scripting/maphint_translator.sp` to
`addons/sourcemod/plugins/maphint_translator.smx` successfully. Final size:

```text
Code size:         41880 bytes
Data size:         185980 bytes
Stack/heap size:      18180 bytes
Total requirements:  246040 bytes
```

No compiler warnings or errors were reported.

## Static regression checks

- `git diff --check`: no output.
- Runtime translation entry points pass `startupScan=false`.
- Only the `OnMapStart` entity enumeration passes `startupScan=true` and adds
  to the outstanding discovery count.
- Unique startup texts remain processing through DeepSeek retries and the
  single DeepL fallback, then move once to success or failure.

## Residual risk

No live DeepSeek or DeepL credentials were used during automated verification.
Deployment should confirm one successful DeepL Free request and the in-game
rendering/truncation behavior of `PrintHintTextToAll` with a representative long
map hint. API keys remain protected and are never logged by the plugin.
