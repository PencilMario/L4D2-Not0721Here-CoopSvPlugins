# Atomic Tasks

- [x] Add a PowerShell contract test that requires default-on Tank/Smoker gates, profile-off overrides, and guard coverage for every custom Fling/OnStagger call.
- [x] Run the new contract test and record its expected failure before source changes.
- [x] Add `l4d_htm_ability_stagger` and guard the three Hulking Tank Fling helpers while retaining their existing damage calls.
- [x] Add `l4d_nsm_ability_stagger` and guard the Noxious Smoker Fling/OnStagger calls while retaining other ability logic.
- [x] Add both `confogl_addcvar` overrides to `cfg/cfgogl/versus_isfullshit/versus.cfg`.
- [x] Re-run the contract test and compile both changed plugins with SourcePawn 1.12.
- [x] Run diff hygiene checks and record verification evidence.
