# Map Hint DeepL Fallback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fall back once to configurable DeepL after DeepSeek retries fail and optionally show startup-only aggregate translation progress to all players.

**Architecture:** Keep the existing single-request queue and shared terminal success/failure paths. Tag map-start entity scans explicitly, track unique startup texts independently from provider retries, and hold each text in processing state while it moves from DeepSeek to DeepL.

**Tech Stack:** SourcePawn 1.12, SourceMod, RIPExt JSON/HTTP, PowerShell contract tests.

**Baseline / Authority Refs:** `Docs/aegis/specs/2026-08-04-maphint-deepl-fallback-design.md`, `Docs/aegis/work/2026-08-04-maphint-deepl-fallback/10-baseline-readset.md`, and the user-supplied compilation instructions.

**Compatibility Boundary:** Preserve existing DeepSeek ConVars and retry semantics, cache file format, de-duplicated serial queue, entity and console waiter behavior, and existing RIPExt endpoint/parser contracts.

**Verification:** Run `tests/maphint_translator_ripext_contract.tests.ps1`, compile `maphint_translator.sp` with SourcePawn 1.12, and run `git diff --check`.

---

### Task 1: Lock the DeepL fallback contract

**Files:**
- Modify: `tests/maphint_translator_ripext_contract.tests.ps1`
- Modify: `addons/sourcemod/scripting/maphint_translator.sp`

**Why this task exists:** A terminal DeepSeek failure currently deletes waiters without another provider. The fallback must retain the active text until one DeepL request succeeds or fails.

**Impact / Compatibility:** DeepSeek remains primary and retains its configured retries. DeepL uses the same terminal cache/writeback code; no provider runs concurrently.

**Repair Track:** Change the terminal branch owned by `RetryOrCompleteTranslation`; after retry exhaustion it starts DeepL when configured. Provider-specific callbacks share terminal completion helpers.

**Retirement Track:** The direct `CompleteTranslationFailure` call after exhausted DeepSeek retries retires only when a DeepL key exists. It remains the canonical path when no fallback is configured or DeepL fails.

**Verification:** The PowerShell contract fails before implementation, then passes; SourcePawn compilation succeeds.

- [ ] **Step 1: Add failing DeepL source contracts**

Add assertions requiring these literal contracts:

```powershell
if (-not $source.Contains('sm_maphint_translate_deepl_key')) { throw 'DeepL key ConVar is missing' }
if (-not $source.Contains('https://api-free.deepl.com/v2/translate')) { throw 'DeepL Free endpoint is not the default' }
if (-not $source.Contains('DeepL-Auth-Key %s')) { throw 'DeepL authorization contract is missing' }
if (-not $source.Contains('body.SetString("target_lang", "ZH-HANS")')) { throw 'DeepL target language contract is missing' }
if (-not $source.Contains('OnDeepLTranslationResponse')) { throw 'DeepL response callback is missing' }
if (-not $source.Contains('StartDeepLTranslation(sourceText)')) { throw 'DeepSeek terminal failure does not start DeepL' }
```

- [ ] **Step 2: Run the contract and verify RED**

Run:

```powershell
& '.\tests\maphint_translator_ripext_contract.tests.ps1'
```

Expected: failure `DeepL key ConVar is missing`.

- [ ] **Step 3: Implement the minimal DeepL provider path**

Add protected key and configurable URL ConVars, cached strings, refresh hooks,
`BuildDeepLRequest`, `StartDeepLTranslation`, and
`OnDeepLTranslationResponse`. The JSON request shape is:

```sourcepawn
JSONObject body = new JSONObject();
JSONArray texts = new JSONArray();
texts.PushString(text);
body.Set("text", texts);
body.SetString("target_lang", "ZH-HANS");
```

The response parser reads `translations[0].text`. Replace retry exhaustion with:

```sourcepawn
if (g_deepLApiKey[0] != '\0')
{
    StartDeepLTranslation(sourceText);
    return;
}
CompleteTranslationFailure(sourceText);
```

The fallback callback calls the existing success/cache/writeback path on a
valid non-empty response and `CompleteTranslationFailure` otherwise.

- [ ] **Step 4: Run contract and compile to verify GREEN**

Run the test from Step 2, then:

```powershell
& 'E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe' `
  'E:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\maphint_translator.sp' `
  '-oE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\plugins\maphint_translator.smx' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting\include' `
  '-iE:\GithubKu\L4D2-Not0721Here-CoopSvPlugins\addons\sourcemod\scripting' `
  '-iE:\GithubKu\L4D2-Competitive-Rework\addons\sourcemod\scripting\include'
```

Expected: contract prints `maphint_translator RIPExt contract passed`; compiler
reports `Compilation successful.` (legacy warnings are acceptable).

- [ ] **Step 5: Commit the provider slice**

```powershell
git add tests/maphint_translator_ripext_contract.tests.ps1 addons/sourcemod/scripting/maphint_translator.sp addons/sourcemod/plugins/maphint_translator.smx
git commit -m "feat(maphint): 增加 DeepL 翻译兜底"
```

### Task 2: Track and display the startup translation batch

**Files:**
- Modify: `tests/maphint_translator_ripext_contract.tests.ps1`
- Modify: `addons/sourcemod/scripting/maphint_translator.sp`

**Why this task exists:** Players need progress for initial map preparation, without later gameplay translations producing noisy hints.

**Impact / Compatibility:** Only calls originating from explicitly tagged `OnMapStart` scans enter progress state. Cache hits and duplicate online texts do not increase totals.

**Repair Track:** Thread `bool startupScan` through scheduled scan retries, property processing, and queue registration. Track outstanding scan discovery separately so asynchronous frames cannot end the batch early.

**Retirement Track:** No old progress owner exists. Normal `OnEntityCreated`, event, and console paths stay untagged and never display hints.

**Verification:** Contract assertions cover the ConVar, scan tag, unique text map, exact hint template, and derived processing count; compilation proves SourcePawn type correctness.

- [ ] **Step 1: Add failing startup-progress source contracts**

```powershell
if (-not $source.Contains('sm_maphint_translate_progress')) { throw 'progress ConVar is missing' }
if (-not $source.Contains('StringMap g_startupTranslationTexts')) { throw 'unique startup translation tracking is missing' }
if (-not $source.Contains('ScheduleEntityTranslation(entity, 0, true)')) { throw 'map-start scans are not tagged' }
if (-not $source.Contains('ScheduleEntityTranslation(entity, 0, false)')) { throw 'runtime scans are not excluded' }
if (-not $source.Contains('int processing = g_startupTotal - g_startupSucceeded - g_startupFailed')) { throw 'processing count contract is missing' }
if (-not $source.Contains('[地图翻译] 正在翻译:%s\n总计: %i, 成功: %i, 失败: %i, 处理中: %i')) { throw 'progress hint format changed' }
```

- [ ] **Step 2: Run the contract and verify RED**

Run the Task 1 contract command.

Expected: failure `progress ConVar is missing`.

- [ ] **Step 3: Implement startup discovery and progress state**

Add the progress ConVar, a `StringMap` set of startup texts, counters for total,
success, failure, and outstanding startup scans. Reset them in `OnMapStart`.
Extend scan scheduling and retry packs with `bool startupScan`; decrement the
outstanding scan count only when each originally scheduled entity reaches a
terminal scan result. Register a unique startup cache miss before queueing:

```sourcepawn
if (startupScan && !g_startupTranslationTexts.ContainsKey(text))
{
    g_startupTranslationTexts.SetValue(text, 1);
    g_startupTotal++;
}
```

On each provider start and each terminal result call a helper that derives
`processing` and uses the approved `PrintHintTextToAll` template. Terminal
success/failure updates only occur when the source text exists in the startup
map, and the entry is removed after being counted exactly once.

- [ ] **Step 4: Run contract and compile to verify GREEN**

Run the Task 1 test and compiler commands.

Expected: contract passes and compiler reports `Compilation successful.`.

- [ ] **Step 5: Run final regression checks**

```powershell
& '.\tests\maphint_translator_ripext_contract.tests.ps1'
git diff --check
git status --short
```

Expected: contract passes, `git diff --check` emits no output, and status lists
only the intended source, test, binary, and Aegis task-record changes.

- [ ] **Step 6: Commit the progress slice and evidence**

Record command results and the live-provider residual risk in
`Docs/aegis/work/2026-08-04-maphint-deepl-fallback/50-evidence.md`, then run:

```powershell
git add Docs/aegis addons/sourcemod/scripting/maphint_translator.sp addons/sourcemod/plugins/maphint_translator.smx tests/maphint_translator_ripext_contract.tests.ps1
git commit -m "feat(maphint): 显示开图翻译进度"
```
