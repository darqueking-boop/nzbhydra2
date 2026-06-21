extends Node

## Populates SpellData._registry with all built-in spells on startup.

func _ready() -> void:
	_register_all()

func _register_all() -> void:
	# --- Fire spells ---
	SpellData.register(SpellData.make(
		"fireball", "Fireball", "Deal 20 fire damage to the enemy.",
		[5, 0, 0, 0, 0, 0], SpellData.EffectType.DAMAGE, 20, GemTypes.Type.RED))

	SpellData.register(SpellData.make(
		"inferno", "Inferno", "Deal 40 fire damage and burn skulls to flame.",
		[10, 0, 0, 0, 0, 0], SpellData.EffectType.DAMAGE, 40, GemTypes.Type.RED))

	# --- Water spells ---
	SpellData.register(SpellData.make(
		"heal_wave", "Healing Wave", "Restore 25 HP.",
		[0, 5, 0, 0, 0, 0], SpellData.EffectType.HEAL, 25, GemTypes.Type.BLUE))

	SpellData.register(SpellData.make(
		"mana_drain", "Mana Drain", "Steal 3 mana of each color from the enemy.",
		[0, 8, 0, 0, 0, 0], SpellData.EffectType.MANA_STEAL, 3, GemTypes.Type.BLUE))

	# --- Nature spells ---
	SpellData.register(SpellData.make(
		"regen", "Regeneration", "Heal 5 HP for 3 turns.",
		[0, 0, 6, 0, 0, 0], SpellData.EffectType.HEAL, 5, GemTypes.Type.GREEN))

	# --- Lightning spells ---
	SpellData.register(SpellData.make(
		"chain_lightning", "Chain Lightning", "Deal 15 damage; if match made this turn, repeat.",
		[0, 0, 0, 7, 0, 0], SpellData.EffectType.DAMAGE, 15, GemTypes.Type.YELLOW))

	SpellData.register(SpellData.make(
		"haste", "Haste", "Take an extra turn immediately.",
		[0, 0, 0, 10, 0, 0], SpellData.EffectType.EXTRA_TURN, 1, GemTypes.Type.YELLOW))

	# --- Shadow spells ---
	SpellData.register(SpellData.make(
		"shadow_bolt", "Shadow Bolt", "Deal 30 shadow damage, ignoring half armor.",
		[0, 0, 0, 0, 8, 0], SpellData.EffectType.DAMAGE, 30, GemTypes.Type.PURPLE))

	SpellData.register(SpellData.make(
		"skull_barrage", "Skull Barrage", "Place 4 skull gems on the board.",
		[0, 0, 0, 0, 12, 0], SpellData.EffectType.SUMMON_SKULLS, 4, GemTypes.Type.SKULL))

	# --- Multi-color spells ---
	SpellData.register(SpellData.make(
		"board_clear", "Purge", "Destroy all gems of the most common color.",
		[3, 3, 3, 3, 3, 0], SpellData.EffectType.BOARD_DESTROY, 0, GemTypes.Type.WILDCARD))
