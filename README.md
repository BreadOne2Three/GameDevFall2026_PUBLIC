# GameDevFall2026_PUBLIC

## Terrarium

A tiny god-game ecosystem in Godot 4.6. Creatures (bats, dogs, slimes, humans) have needs —
hunger, thirst, energy, fun, social, bladder — and a utility-AI brain that picks what to do about them.
You keep them alive (or don't).

### Controls
| Input | Does |
|---|---|
| Drag a creature | pick up; release to throw (hard hits hurt, and they remember) |
| Double-click a creature | pet (reward) |
| Right-click a creature | flick (punish) |
| Right-click ground | drop food |
| Click a dropping / water dish | clean / refill |
| Space / Tab | pause / speed 1×·2×·4× |
| 1–4 | bring back an extinct species (bat, dog, slime, human) |
| D / H | AI debug overlay / hide hints |

### How the AI works
- **Utility AI** (`components/brain_component.gd`): every action under a creature's `Brain` node scores itself; the best one runs. Tweak `ramp_start`/`ramp_end`/`max_score` or draw a `score_curve` in the inspector.
- **Reinforcement learning** (`components/learning_component.gd`): pets and flicks shift per-action biases. Potty-train a creature by flicking it after it goes on the floor (or petting it after it uses the litter box).
- **Genetics** (`components/genome.gd`): babies blend their parents' speed, size, metabolism and (for slimes) color, with small mutations.
- **Starving** is species-specific: dogs hunt, bats drain blood, slimes scavenge, humans beg.

### Tests
`tests/run.sh` (set `GODOT=/path/to/Godot` if it isn't in `~/Downloads/Godot.app`).
