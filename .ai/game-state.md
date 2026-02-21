# Current Game State

## What Works
- Cat: moves, jumps, hides (fades when hidden), camera follows with smoothing
- Dog: patrols, detects via raycast, chases, shows `!` alert bubble, catches cat
- Human: scripted but not placed in level_01 yet
- Level 01: floor, one dog, two hide spots (shelf + couch), 3 fish, exit door
- HUD: fish counter top-left, flash overlay, CAUGHT!/YOU WIN! message

## Win / Lose
- Win: collect all 3 fish, reach the exit door
- Lose: dog touches cat while not hidden → screen flash → level resets
