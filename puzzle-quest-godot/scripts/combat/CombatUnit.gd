extends RefCounted
class_name CombatUnit

## Data model for a combatant (player or enemy) in a battle.

var id: String
var display_name: String
var hp: int
var max_hp: int
var mana: Array[int]      # one per GemTypes color index (0..5)
var max_mana: Array[int]
var stats: Dictionary
var spells: Array[SpellData]
var is_player: bool

func _init(data: Dictionary, player: bool) -> void:
	id           = data.get("id", "unit")
	display_name = data.get("name", "Unknown")
	hp           = data.get("hp", 100)
	max_hp       = data.get("max_hp", hp)
	is_player    = player
	stats        = data.get("stats", {"strength": 5, "intelligence": 5, "defense": 3, "agility": 5})
	mana         = []
	max_mana     = []
	for i in 6:
		mana.append(0)
		max_mana.append(data.get("max_mana", [10,10,10,10,10,10])[i])
	spells = []
	for spell_id in data.get("spells", []):
		var sd := SpellData.from_id(spell_id)
		if sd:
			spells.append(sd)

func take_damage(amount: int, element: int) -> int:
	var mitigated := max(1, amount - _defense_mitigation(element))
	hp = max(0, hp - mitigated)
	return mitigated

func heal(amount: int) -> int:
	var healed := min(amount, max_hp - hp)
	hp += healed
	return healed

func gain_mana(color: int, amount: int) -> void:
	if color < 0 or color >= 6:
		return
	mana[color] = min(mana[color] + amount, max_mana[color])

func spend_mana(costs: Array[int]) -> bool:
	for i in costs.size():
		if mana[i] < costs[i]:
			return false
	for i in costs.size():
		mana[i] -= costs[i]
	return true

func is_alive() -> bool:
	return hp > 0

func hp_ratio() -> float:
	return float(hp) / float(max_hp) if max_hp > 0 else 0.0

func _defense_mitigation(element: int) -> int:
	var base := stats.get("defense", 0)
	# Could add elemental resistances here
	return base / 2
