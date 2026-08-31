# Evidence Bundle

## RED: contract catches the missing behavior

Command:

```powershell
pwsh -NoProfile -File .\tests\versus_ability_stagger_contract.tests.ps1
```

Result: exit code `1` with the expected missing-ConVar, missing-profile-setting, and unguarded-call failures. The baseline call counts reported by the test were 3 Tank Fling calls, 4 Smoker Fling calls, and 1 Smoker direct stagger call.

## GREEN: source/config contract passes

Command:

```powershell
pwsh -NoProfile -File .\tests\versus_ability_stagger_contract.tests.ps1
```

Result: exit code `0`, output `Versus ability stagger contract passed`.

The contract now requires the fixed baseline of 3 Tank Fling calls, 4 Smoker Fling calls, and 1 Smoker direct stagger call. It also checks each affected ability and confirms Tank and Smoker damage calls remain outside the optional stagger guards.

## Advisory code review

The independent review found no Critical issue. It confirmed all 3 Tank and 5 Smoker custom stagger SDK call sites are gated and identified the contract false-negative gap; that gap was fixed with exact call counts and per-ability assertions. Runtime behavior remains intentionally unverified because no L4D2 server is available.

## Final compilation and hygiene

Both changed SourcePawn files were compiled with `E:\GithubKu\L4d2_0721sv_plugins\spcomp.exe` 1.12.0.7221 and the repository include paths. Both commands exited `0`; Tank emitted 14 existing warnings and Smoker emitted 11 existing warnings, with no compiler errors.

```text
Tank code size: 33880 bytes; total requirements: 63152 bytes
Smoker code size: 38880 bytes; total requirements: 70812 bytes
```

`git diff --check` exited `0` after the final source/config changes. The final contract run exited `0` with `Versus ability stagger contract passed`.

## Remaining evidence

SourcePawn compiler output, binary timestamps, and final diff checks will be recorded after compilation.
