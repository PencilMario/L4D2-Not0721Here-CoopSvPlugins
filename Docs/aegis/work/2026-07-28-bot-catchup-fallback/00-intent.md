# Intent

Change each survivor Bot's catch-up reference to its nearest living human survivor. Use map-flow progress when valid and fall back to the legacy world-distance rule when Flow is unavailable. When every living human is inside the ending checkpoint and no living survivor is incapacitated or hanging, teleport living Bots outside the checkpoint to the nearest eligible human.

The existing invisibility multiplier, sustained adrenaline, and common-infected shove kill remain. In fallback mode the adrenaline threshold is 10000 world units, corresponding to the Flow rule's 10-step threshold.
