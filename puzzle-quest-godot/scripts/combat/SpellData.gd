extends Resource
class_name SpellData

## Definition of a castable spell. Load from resources or define inline.

enum EffectType {
	DAMAGE,          # Deal damage to target
	HEAL,            # Restore HP
	MANA_STEAL,      # Drain enemy mana
	BOARD_DESTROY,   # Destroy all gems of a color
	EXTRA_TURN,      # Grant another turn
	BUFF_STAT,       # Temporarily boost a stat
	DEBUFF_ENEMY,    # Reduce enemy stat
	SUMMON_SKULLS,   # Add skull gems to board
}

@export var spell_id: String = ""
@export var display_name: String = "Unknown Spell"
@export var description: String = ""
@export var icon_path: String = ""
@export var mana_cost: Array[int] = [0, 0, 0, 0, 0, 0]  # cost per color
@export var effect_type: EffectType = EffectType.DAMAGE
@export var effect_value: int = 10
@export var effect_element: int = GemTypes.Type.RED
@export var duration_turns: int = 0  # 0 = instant

static var _registry: Dictionary = {}

static func register(sd: SpellData) -> void:
	_registry[sd.spell_id] = sd

static func from_id(id: String) -> SpellData:
	return _registry.get(id, null)

## Convenience factory for code-defined spells.
static func make(id: String, name: String, desc: String,
		cost: Array[int], type: EffectType, value: int, element: int = 0) -> SpellData:
	var sd := SpellData.new()
	sd.spell_id      = id
	sd.display_name  = name
	sd.description   = desc
	sd.mana_cost     = cost
	sd.effect_type   = type
	sd.effect_value  = value
	sd.effect_element = element
	return sd
