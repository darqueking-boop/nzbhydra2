extends RefCounted
class_name GemTypes

## Defines all gem colors/types and their combat roles.

enum Type {
	RED    = 0,  # Fire / Strength damage
	BLUE   = 1,  # Water / Mana generation
	GREEN  = 2,  # Nature / Healing
	YELLOW = 3,  # Lightning / Agility bonus
	PURPLE = 4,  # Shadow / Spell power
	SKULL  = 5,  # Direct damage to enemy
	GOLD   = 6,  # Coins / XP bonus
	WILDCARD = 7, # Matches any color
}

const COUNT := 8

const COLORS: Dictionary = {
	Type.RED:      Color(0.9, 0.2, 0.2),
	Type.BLUE:     Color(0.2, 0.4, 0.9),
	Type.GREEN:    Color(0.2, 0.8, 0.3),
	Type.YELLOW:   Color(0.95, 0.85, 0.1),
	Type.PURPLE:   Color(0.7, 0.2, 0.9),
	Type.SKULL:    Color(0.85, 0.85, 0.85),
	Type.GOLD:     Color(1.0, 0.75, 0.0),
	Type.WILDCARD: Color(1.0, 1.0, 1.0),
}

const NAMES: Dictionary = {
	Type.RED:      "Fire",
	Type.BLUE:     "Water",
	Type.GREEN:    "Nature",
	Type.YELLOW:   "Lightning",
	Type.PURPLE:   "Shadow",
	Type.SKULL:    "Skull",
	Type.GOLD:     "Gold",
	Type.WILDCARD: "Wild",
}

## Weights for random spawning (SKULL and WILDCARD spawn less often)
const SPAWN_WEIGHTS: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 0.4, 0.3, 0.1]

static func weighted_random(exclude: Array[int] = []) -> int:
	var total := 0.0
	for i in COUNT:
		if i not in exclude:
			total += SPAWN_WEIGHTS[i]
	var roll := randf() * total
	var acc := 0.0
	for i in COUNT:
		if i in exclude:
			continue
		acc += SPAWN_WEIGHTS[i]
		if roll <= acc:
			return i
	return Type.RED
