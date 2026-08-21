# Atomic Tasks: Survivor Bot Bone Query Guard

- [x] Add `tests/l4d2_sb_ai_bone_guard.tests.ps1` with the canonical-owner and fallback assertions.
- [x] Run the new test and capture the expected RED failure before production edits.
- [x] Add `LBI_IsBoneQueryReady` and `LBI_LookupBone` to `navigation.inc`.
- [x] Route `LBI_GetBonePosition` through the guarded wrapper and recheck before `GetBonePosition`.
- [x] Add origin fallback and early return to both bone-based aiming paths.
- [x] Run the new guard test and the existing module contract test.
- [x] Compile `l4d2_sb_ai_improver.sp` to a temporary SMX and the tracked plugin artifact with the project compiler and include paths.
- [x] Run `git diff --check`, review the diff, and verify only the intended live plugin binary was rebuilt.
