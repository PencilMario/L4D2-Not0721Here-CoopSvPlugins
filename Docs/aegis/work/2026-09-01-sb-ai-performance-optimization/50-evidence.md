# Evidence Bundle Draft

## Static contracts

Command: `Get-ChildItem tests/*.tests.ps1 | Sort-Object Name | ForEach-Object { pwsh -NoProfile -File $_.FullName }`

Result: 30 test scripts ran in name order; every script returned exit code 0 (`TOTAL=30 PASSED=30 FAILED=0`). Coverage includes module graph, performance budget/logging, RunCmd/runtime budget, visibility/navigation/infected-count caches, inventory/entity/scavenge, rescue/pinned-reaction, bone guard, and repository regression contracts.

## SourcePawn build

Command: project-specified SourcePawn 1.12 compiler with the three required include paths, outputting `addons/sourcemod/plugins/l4d2_sb_ai_improver.smx`.

Result: exit code 0; compiler emitted no errors and produced the `.smx`; Code size 287564 bytes; Data size 13756472 bytes; Stack/heap size 17300 bytes; Total requirements 14061336 bytes. This compiler invocation did not print a literal `Compilation successful.` line.

## Formatting

Command: `git diff --check`

Result: exit code 0; no whitespace errors.

## Compatibility decision

`CheckForItemsToScavenge` still evaluates its category lists through the existing priority/eligibility branches. A single merged candidate scan is intentionally deferred because the lists use different weapon IDs, pickup rules, priority ordering, and reachability semantics; merging them without a behavior-equivalence fixture would exceed the compatibility boundary.

## Cache expiry policy

Command: PowerShell audit over all `addons/sourcemod/scripting/l4d2_sb_ai_improver/*.inc` assignments to `Cache_Expiry`, `GlobalInfo_Expiry`, `Inventory_Expiry`, and `g_fBotProcessing_NextProcessTime`.

Result: 59 expiry assignments checked; `CACHE_EXPIRY_AUDIT=PASS`. Query-cache expiry assignments use `GetProcessCacheExpiry()`, which resolves to `GetGameTime() + g_fCvar_NextProcessTime` (`ib_process_time`). Lifecycle invalidation remains `0.0`. Fixed durations found in behavior timers or vision-notice memory are intentionally outside the query-cache policy.

## Runtime gap

No local L4D2 server is available. A fixed campaign/ten-Bot live sample comparing RunCmd P50/P95/P99, Base_TraceFilter count, rescue action latency, and behavior outcomes remains unverified. Repeat the same campaign conditions once a server is available.

## Evidence boundary

Used summarized baseline evidence from `D:\Windows\Download\战役-console (1).txt`; the full raw console log was not loaded into this final prompt. Fresh verification used the commands above and current source tree.

Confidence: B for static/build integrity; C for runtime performance and behavior because live sampling is unavailable.
