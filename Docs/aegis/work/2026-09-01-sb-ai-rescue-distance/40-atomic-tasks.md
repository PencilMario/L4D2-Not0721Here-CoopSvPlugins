# Atomic Tasks: Pinned Rescue Maximum Distance

1. Add distance CVar, cache, helper, gate, and profile assertions to the existing rescue contract.
2. Run the target contract and record the expected RED failure.
3. Add the CVar handle and squared cache state.
4. Register, hook, and synchronize the CVar in convars.inc.
5. Add the cached-origin distance helper and connect it to IsPinnedFriendReactionAllowed().
6. Add the 1500 versus profile override.
7. Run the target contract GREEN.
8. Compile the plugin with the project SourcePawn compiler.
9. Run all PowerShell contracts and git diff --check.
