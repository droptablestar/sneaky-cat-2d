# Current Game State

## What Works
- Cat: moves, jumps, hides (fades when hidden), camera follows with smoothing
- Dog: patrols, detects via raycast, chases, shows `!` alert bubble, catches cat
- Human: placed in level_01, patrols right side (x 750–1050), guards Fish3 and exit
- Level 01: floor, dog (mid), human (right), 4 hide spots (shelf, couch, tabletop, bookcase), 4 fish, exit door
- HUD: fish counter top-left, flash overlay, CAUGHT!/YOU WIN! message
- Lighting: two PointLight2D sources at window positions, CanvasModulate ambient, projected floor shadows drawn per object
- Visual depth: 3D box-room background, z_index ordering (background → floor → props → collectibles → enemies → cat → HUD)
- Character art: procedural `_draw()` with rounded shapes, outlines, and details (cat has ears/tail/whiskers/eye, dog has floppy ears/snout/collar, human has hair/arms/shoes)
- Furniture art: each hide spot has unique visuals (shelf with brackets/items, purple couch with cushions/armrests, table with drawer, bookcase with colored books)
- Fish: oval body with dorsal/pectoral fins, forked tail, golden glow aura
- Exit door: paneled door with frame, hinges, knob plate, lock/open glow indicator

## Win / Lose
- Win: collect all 4 fish, reach the exit door
- Lose: dog touches cat while not hidden → screen flash → level resets
