extends Node
class_name BoardController

## Orchestrates the board state machine: idle → animating → resolving → idle.
## Emits EventBus signals after each resolution step.

enum State { IDLE, ANIMATING, RESOLVING, GAME_OVER }

var model: BoardModel
var state: State = State.IDLE
var score: int = 0
var combo: int = 0

signal board_updated(model: BoardModel)
signal cells_cleared(positions: Array, gem_counts: Dictionary)
signal cells_fallen(new_positions: Dictionary)  # {Vector2i: int} col → new gem type at empty rows
signal no_moves_left()

func _ready() -> void:
	model = BoardModel.new()
	EventBus.board_resolved.connect(_on_board_resolved)

func try_swap(from: Vector2i, to: Vector2i) -> void:
	if state != State.IDLE:
		return
	if not model.is_adjacent(from, to):
		EventBus.swap_attempted.emit(from, to, false)
		return
	if not model.would_match(from, to):
		EventBus.swap_attempted.emit(from, to, false)
		return
	model.swap(from, to)
	state = State.ANIMATING
	EventBus.swap_attempted.emit(from, to, true)
	board_updated.emit(model)
	# After swap animation completes the view calls resolve_step()

func resolve_step() -> void:
	var matches := model.find_matches()
	if matches.is_empty():
		combo = 0
		state = State.IDLE
		EventBus.board_resolved.emit()
		if not model.has_valid_moves():
			state = State.GAME_OVER
			no_moves_left.emit()
		return

	combo += 1
	state = State.RESOLVING
	var counts := model.clear_matches(matches)
	_apply_score(counts, combo)
	_emit_combat_events(counts)

	var all_positions: Array = []
	for group in matches:
		all_positions.append_array(group)
	cells_cleared.emit(all_positions, counts)

func after_clear_animation() -> void:
	model.apply_gravity()
	model.fill_random()
	board_updated.emit(model)
	# View calls resolve_step() again after fall animation

func _apply_score(counts: Dictionary, multiplier: int) -> void:
	var gained := 0
	for type in counts:
		gained += counts[type] * 10 * multiplier
	score += gained
	EventBus.score_changed.emit(score)

func _emit_combat_events(counts: Dictionary) -> void:
	for type in counts:
		var amt: int = counts[type]
		match type:
			GemTypes.Type.RED:
				EventBus.damage_dealt.emit("enemy", amt * 2, GemTypes.Type.RED)
			GemTypes.Type.BLUE, GemTypes.Type.GREEN, GemTypes.Type.YELLOW, GemTypes.Type.PURPLE:
				EventBus.mana_gained.emit(type, amt)
			GemTypes.Type.SKULL:
				EventBus.damage_dealt.emit("enemy", amt * 3, GemTypes.Type.SKULL)
			GemTypes.Type.GOLD:
				GameData.player["gold"] += amt

func _on_board_resolved() -> void:
	pass
