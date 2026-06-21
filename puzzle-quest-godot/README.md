# Puzzle Quest – Godot 4 Game Engine

A modular match-3 RPG game engine inspired by *Puzzle Quest*, built with **Godot 4.2+** and GDScript.

---

## Architecture

```
puzzle-quest-godot/
├── project.godot              # Godot project config + autoloads
├── scenes/
│   ├── MainMenu.tscn          # Title screen
│   ├── WorldMap.tscn          # Overworld encounter selector
│   ├── Battle.tscn            # Full combat scene
│   └── Settings.tscn          # Audio / display settings
├── scripts/
│   ├── autoloads/
│   │   ├── EventBus.gd        # Central signal hub (decouples all systems)
│   │   ├── GameData.gd        # Persistent player state + save/load
│   │   └── AudioManager.gd    # Pooled SFX + fade-in music
│   ├── board/
│   │   ├── GemTypes.gd        # Gem color enum, colors, spawn weights
│   │   ├── BoardModel.gd      # Pure data model – match detection, gravity
│   │   ├── BoardController.gd # State machine: idle → animating → resolving
│   │   ├── BoardView.gd       # Node2D renderer, drives GemNode animations
│   │   ├── GemNode.gd         # Single gem visual + click/animation
│   │   └── BoardTest.gd       # Headless unit tests for BoardModel
│   ├── combat/
│   │   ├── CombatUnit.gd      # Player/enemy data (HP, mana, stats, spells)
│   │   ├── SpellData.gd       # Spell definition resource + registry
│   │   ├── SpellRegistry.gd   # Registers all built-in spells at startup
│   │   └── CombatManager.gd   # Turn order, spell casting, win/loss, AI
│   └── ui/
│       ├── HUDController.gd   # In-battle HUD: HP bars, mana bars, spells
│       ├── DamageNumber.gd    # Floating damage/heal popup
│       ├── BattleSceneController.gd  # Wires board + HUD + combat
│       ├── MainMenuController.gd
│       ├── WorldMapController.gd
│       └── SettingsController.gd
└── assets/icons/icon.svg
```

---

## Core Systems

### Match-3 Board
| Class | Role |
|---|---|
| `GemTypes` | 8 gem types: Fire🔥 Water💧 Nature🌿 Lightning⚡ Shadow🔮 Skull💀 Gold🪙 Wild✨ |
| `BoardModel` | Pure logic: flood-fill match detection, gravity, shuffle, validity checks |
| `BoardController` | State machine + score accumulator + combat event emission |
| `BoardView` | Pixel-to-grid mapping, GemNode lifecycle, fall animations |

### Combat
- **CombatUnit** – tracks HP, per-color mana pools, stat block, spell list
- **CombatManager** – alternating player/enemy turns; enemy AI picks valid swaps
- **SpellData** – resource-based spell definitions with 9 effect types
- **SpellRegistry** – 10 built-in spells across all gem colors

### Gem Combat Roles
| Gem | Effect |
|---|---|
| 🔥 Fire (RED) | 2× Strength damage to enemy |
| 💧 Water (BLUE) | +1 Blue mana per gem cleared |
| 🌿 Nature (GREEN) | +1 Green mana per gem cleared |
| ⚡ Lightning (YELLOW) | +1 Yellow mana per gem cleared |
| 🔮 Shadow (PURPLE) | +1 Purple mana per gem cleared |
| 💀 Skull | 3× direct damage (ignores class bonuses) |
| 🪙 Gold | +1 Gold coin |
| ✨ Wild | Matches any color |

### Signals (EventBus)
All systems communicate exclusively through `EventBus` signals — no direct references between board, combat, and UI layers.

---

## Getting Started

1. Install **Godot 4.2+** from [godotengine.org](https://godotengine.org/)
2. Open Godot → **Import** → select `puzzle-quest-godot/project.godot`
3. Press **F5** to run (starts at `MainMenu.tscn`)

### Run headless tests
```bash
godot --headless -s scripts/board/BoardTest.gd
```

---

## Extending the Engine

### Add a new spell
```gdscript
# In SpellRegistry.gd _register_all():
SpellData.register(SpellData.make(
    "my_spell", "My Spell", "Description here.",
    [0, 0, 5, 0, 0, 0],            # mana cost per color
    SpellData.EffectType.DAMAGE,    # effect type
    35,                             # effect value
    GemTypes.Type.GREEN))           # element
```

### Add a new enemy
```gdscript
# Pass to WorldMapController.ENCOUNTER_DATA or directly to CombatManager.setup():
{
    "id": "boss_dragon", "name": "Dragon King",
    "hp": 350, "max_hp": 350,
    "stats": {"strength": 15, "intelligence": 12, "defense": 8, "agility": 5, "xp_reward": 300},
    "max_mana": [15, 10, 10, 10, 15, 0],
    "spells": ["fireball", "inferno", "skull_barrage"],
}
```

### Add a new gem effect type
1. Add the variant to `GemTypes.Type` and update `COLORS`, `NAMES`, `SPAWN_WEIGHTS`
2. Handle the new type in `BoardController._emit_combat_events()`
3. Optionally add a matching `SpellData.EffectType` and handle it in `CombatManager._apply_spell()`

---

## License
MIT
