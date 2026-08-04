# Map hint DeepL fallback and startup progress design

## Intent

Extend `maphint_translator.sp` so a failed DeepSeek translation can fall back to
DeepL, and optionally show aggregate translation progress for the map-start
entity scan. Preserve the existing cache, queue, entity writeback, console
output, and DeepSeek retry behavior.

## Translation flow

1. A cache miss enters the existing serial translation queue.
2. DeepSeek receives the request and uses the existing retry limit and delay.
3. After all DeepSeek attempts fail, the plugin sends one DeepL request when a
   DeepL API key is configured.
4. A successful response from either provider uses the same cache persistence,
   entity waiter writeback, and console waiter output path.
5. A missing DeepL key or one failed DeepL request completes the translation as
   failed and removes its pending waiters.

DeepL does not receive its own retry loop. This keeps it a bounded fallback and
avoids multiplying latency and API usage.

## Configuration

Add these ConVars:

- `sm_maphint_translate_deepl_key`: protected DeepL API key, empty by default,
  and excluded from generated config recording.
- `sm_maphint_translate_deepl_api_url`: DeepL endpoint, defaulting to the Free
  API endpoint `https://api-free.deepl.com/v2/translate`. Operators can set it
  to `https://api.deepl.com/v2/translate` for DeepL Pro.
- `sm_maphint_translate_progress`: enables map-start translation progress hints,
  default `1`.

The DeepL request uses `Authorization: DeepL-Auth-Key <key>`, JSON content, and
`target_lang` set to `ZH-HANS`. The response translation comes from the first
entry in the `translations` array.

## Startup progress

The startup batch consists only of unique cache-miss texts discovered by the
entity scan initiated in `OnMapStart`. Cache hits do not count because they do
not require online translation. Later entity creation, instructor events, and
server `say` translations are outside this batch even if the initial batch is
still running.

Each startup text remains in the processing count across DeepSeek retries and
the DeepL fallback. It moves exactly once to success or failure at the terminal
result. Duplicate texts share one queue item and one progress item.

When enabled, starting or completing work on a startup text refreshes the hint
for all players with this format:

```text
[地图翻译] 正在翻译:<当前文本>
总计: 10, 成功: 5, 失败: 2, 处理中: 3
```

The current text is the startup text whose provider request is being started or
whose terminal result was just recorded. The processing count is
`total - success - failure`. Once no startup items remain, the terminal update
is shown once and later translations never display progress.

## State and error handling

Provider state must remain associated with the existing request ID so stale
callbacks cannot finish the active queue item. Transitioning from DeepSeek to
DeepL keeps the queue occupied by that text; the next queued text does not start
until the fallback completes.

HTTP transport errors, non-2xx status codes, missing response fields, and empty
translations are failures. Logs distinguish the provider and failure reason.
No API key value is logged.

## Verification

Extend the PowerShell source contract test first so it fails until the source
contains the approved ConVars, Free endpoint, DeepL authorization and response
contracts, fallback transition, and startup-only progress bookkeeping. Then
compile `maphint_translator.sp` with the repository SourcePawn compiler and run
the contract test again.

## Compatibility and non-goals

- Existing DeepSeek ConVars and retry semantics remain unchanged.
- Existing cache file format remains unchanged.
- Requests remain serial; no concurrent provider calls are introduced.
- DeepL glossary configuration, batching, usage reporting, and retries are out
  of scope.
- Progress does not include cache hits or translations triggered after the
  map-start scan.

## Design inputs

**Task intent:** Ensure failed DeepSeek requests can still produce Simplified
Chinese translations, while making the initial online translation workload
visible to players.

**Baseline read set:** `addons/sourcemod/scripting/maphint_translator.sp`,
`tests/maphint_translator_ripext_contract.tests.ps1`, recent commits affecting
the translator, and the project compilation instructions supplied by the user.

**Impact:** One plugin source file, its source contract test, generated plugin
binary, and operator-facing ConVars. RIPExt, the cache contract, and entity
writeback behavior remain the compatibility boundary.
