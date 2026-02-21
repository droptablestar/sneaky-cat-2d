# Current Game State

## What Works
- Cat: moves, jumps, hides (fades when hidden), camera follows with smoothing
- Dog: patrols, detects via raycast, chases, shows `!` alert bubble, catches cat
- Human: placed in level_01, patrols right side (x 750–1050), guards Fish3 and exit
- Level 01: floor, dog (mid), human (right), 4 hide spots (shelf, couch, tabletop, bookcase), 4 fish, exit door
- HUD: fish counter top-left, flash overlay, CAUGHT!/YOU WIN! message

## Win / Lose
- Win: collect all 4 fish, reach the exit door
- Lose: dog touches cat while not hidden → screen flash → level resets
