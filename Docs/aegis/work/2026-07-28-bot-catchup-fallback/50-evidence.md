# Evidence

## Results

- RED: `tests/bot_catchup_speed_contract.tests.ps1` failed at the missing `FindNearestLivingHuman` contract before implementation.
- GREEN: the same contract test printed `bot_catchup_speed contract passed` after implementation.
- Compile: SourcePawn Compiler 1.12.0.7221 compiled the final plugin without errors or warnings; code size was 10884 bytes and total requirements were 35920 bytes. The refreshed SMX is 9252 bytes.
- Behavior boundaries represented in the contract: nearest living human selection, per-Bot Flow validation, 1000-unit fallback steps, 10000-unit fallback adrenaline threshold, ending-checkpoint guards, teleport, and stuck correction.

## Residual risk

Static contracts and compilation cannot prove custom-map Flow behavior or checkpoint bounds at runtime. Test one standard campaign map and one known no-Flow/custom map on a live server.
