# Verification Evidence

## Structural contract

Command: `& tests/l4d2_sb_ai_improver_modules.tests.ps1`

Expected result: all responsibility modules exist in the include graph, Left4DHooks precedes VScript, normal modules remain below 35 KB, and the composition root is below 100 lines. `bot_think.inc` has a 45 KB exception because it contains the original cohesive decision function.

## Compiler

Compiler: `E:/GithubKu/L4d2_0721sv_plugins/spcomp.exe`, SourcePawn 1.12.0.7221.

The exact user-provided include paths are used and output is written to the temporary directory rather than the live plugin directory.

Baseline after include-order repair:

- Code: 230,544 bytes
- Data: 3,483,756 bytes
- Stack/heap: 16,932 bytes
- Total requirements: 3,731,232 bytes

Modular source:

- Code: 230,544 bytes
- Data: 3,483,756 bytes
- Stack/heap: 16,932 bytes
- Total requirements: 3,731,232 bytes

## Compatibility notes

- Top-level `static` declarations became plugin-global declarations because SourcePawn treats `static` symbols in included files as file-private. Function-local `static` declarations remain unchanged.
- Three cross-module multidimensional string tables became ordinary global arrays because SourcePawn rejects non-static multidimensional `const` arrays. No writes to these tables were introduced.
- Compiled code, data, stack/heap, and total requirement sizes match the buildable baseline.
- The composition root is 79 lines and the implementation is distributed across 23 responsibility modules.
- Runtime bot behavior on a live L4D2 server remains unverified; this pass intentionally does not change AI algorithms or scheduling.
