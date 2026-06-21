extends Node
class_name CombatManager

## Manages a single battle: turn order, spell casting, win/loss conditions.

enum TurnPhase { PLAYER_TURN, ENEMY_TURN, RESOLVING }

var player: CombatUnit
var enemy: CombatUnit
var phase: TurnPhase = TurnPhase.PLAYER_TURN
var turn_number: int = 0
var extra_turns: int = 0  # accumulated from spells / large matches

var _board_controller: BoardController

func setup(player_data: Dictionary, enemy_data: Dictionary, board: BoardController) -> void:
	player = CombatUnit.new(player_data, true)
	enemy  = CombatUnit.new(enemy_data, false)
	_board_controller = board

	# Wire board events into combat
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.mana_gained.connect(_on_mana_gained)
	EventBus.board_resolved.connect(_on_board_resolved)

	EventBus.combat_started.emit(player_data, enemy_data)
	_start_player_turn()

func cast_spell(spell: SpellData) -> void:
	if phase != TurnPhase.PLAYER_TURN:
		return
	if not player.spend_mana(spell.mana_cost):
		return

	EventBus.spell_cast.emit(player.id, spell.spell_id)
	_apply_spell(spell, player, enemy)
	_check_win_loss()

func _apply_spell(spell: SpellData, caster: CombatUnit, target: CombatUnit) -> void:
	match spell.effect_type:
		SpellData.EffectType.DAMAGE:
			var dmg := spell.effect_value + caster.stats.get("intelligence", 0)
			var dealt := target.take_damage(dmg, spell.effect_element)
			EventBus.damage_dealt.emit(target.id, dealt, spell.effect_element)
		SpellData.EffectType.HEAL:
			caster.heal(spell.effect_value)
		SpellData.EffectType.MANA_STEAL:
			for i in 6:
				var stolen := mini(target.mana[i], spell.effect_value)
				target.mana[i] -= stolen
				caster.gain_mana(i, stolen)
		SpellData.EffectType.EXTRA_TURN:
			extra_turns += spell.effect_value
		SpellData.EffectType.SUMMON_SKULLS:
			_place_skulls_on_board(spell.effect_value)
		SpellData.EffectType.BOARD_DESTROY:
			_destroy_most_common_color()

func _start_player_turn() -> void:
	turn_number += 1
	phase = TurnPhase.PLAYER_TURN
	_board_controller.state = BoardController.State.IDLE
	EventBus.turn_changed.emit(true)

func _start_enemy_turn() -> void:
	phase = TurnPhase.ENEMY_TURN
	EventBus.turn_changed.emit(false)
	await get_tree().create_timer(1.0).timeout
	_enemy_act()

func _enemy_act() -> void:
	# Simple AI: try to cast the first affordable spell; otherwise do a random swap
	for spell in enemy.spells:
		if _can_afford(enemy, spell):
			_apply_spell(spell, enemy, player)
			EventBus.spell_cast.emit(enemy.id, spell.spell_id)
			break
	# Enemy also "plays" the board: pick a random valid swap
	_enemy_board_move()

func _enemy_board_move() -> void:
	var model := _board_controller.model
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			var pos := Vector2i(c, r)
			for neighbor in [Vector2i(c+1, r), Vector2i(c, r+1)]:
				if model.is_adjacent(pos, neighbor) and model.would_match(pos, neighbor):
					_board_controller.try_swap(pos, neighbor)
					return
	# No match found; shuffle board instead
	_shuffle_board()
	_start_player_turn()

func _on_board_resolved() -> void:
	if extra_turns > 0:
		extra_turns -= 1
		_start_player_turn()
		return
	match phase:
		TurnPhase.PLAYER_TURN:
			_check_win_loss()
			if player.is_alive() and enemy.is_alive():
				_start_enemy_turn()
		TurnPhase.ENEMY_TURN:
			_check_win_loss()
			if player.is_alive() and enemy.is_alive():
				_start_player_turn()

func _on_damage_dealt(target_id: String, amount: int, element: int) -> void:
	var unit := _unit_by_id(target_id)
	if unit:
		unit.take_damage(amount, element)
	_check_win_loss()

func _on_mana_gained(color: int, amount: int) -> void:
	if phase == TurnPhase.PLAYER_TURN:
		player.gain_mana(color, amount)
	else:
		enemy.gain_mana(color, amount)

func _check_win_loss() -> void:
	if not enemy.is_alive():
		_end_combat(true)
	elif not player.is_alive():
		_end_combat(false)

func _end_combat(victory: bool) -> void:
	EventBus.combat_ended.emit(victory)
	if victory:
		var xp := enemy.stats.get("xp_reward", 50)
		GameData.gain_xp(xp)
		GameData.player["hp"] = player.hp  # carry over HP
	else:
		GameData.player["hp"] = 1  # survive with 1 HP (classic PQ behaviour)

func _can_afford(unit: CombatUnit, spell: SpellData) -> bool:
	for i in spell.mana_cost.size():
		if unit.mana[i] < spell.mana_cost[i]:
			return false
	return true

func _unit_by_id(id: String) -> CombatUnit:
	if player and player.id == id:
		return player
	if enemy and enemy.id == id:
		return enemy
	return null

func _place_skulls_on_board(count: int) -> void:
	var model := _board_controller.model
	var placed := 0
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			if model.get_gem(c, r) != GemTypes.Type.SKULL:
				model.set_gem(c, r, GemTypes.Type.SKULL)
				placed += 1
				if placed >= count:
					return

func _destroy_most_common_color() -> void:
	var model := _board_controller.model
	var freq: Dictionary = {}
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			var t := model.get_gem(c, r)
			if t >= 0 and t < GemTypes.Type.SKULL:
				freq[t] = freq.get(t, 0) + 1
	var best_type := -1
	var best_count := 0
	for t in freq:
		if freq[t] > best_count:
			best_count = freq[t]
			best_type = t
	if best_type == -1:
		return
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			if model.get_gem(c, r) == best_type:
				model.set_gem(c, r, -1)

func _shuffle_board() -> void:
	var model := _board_controller.model
	var all_types: Array[int] = []
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			all_types.append(model.get_gem(c, r))
	all_types.shuffle()
	var idx := 0
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			model.set_gem(c, r, all_types[idx])
			idx += 1
