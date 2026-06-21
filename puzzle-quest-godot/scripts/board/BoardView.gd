extends Node2D
class_name BoardView

## Renders the BoardModel using GemNode children and drives animations.

const GEM_SIZE := 64.0

@export var controller: BoardController

var _gems: Array = []  # [col][row] → GemNode or null
var _selected: GemNode = null
var _pending_falls := 0

func _ready() -> void:
	_init_gem_grid()
	controller.board_updated.connect(_on_board_updated)
	controller.cells_cleared.connect(_on_cells_cleared)

func _init_gem_grid() -> void:
	_gems.clear()
	for c in BoardModel.COLS:
		_gems.append([])
		for r in BoardModel.ROWS:
			_gems[c].append(null)
	_rebuild_from_model()

func _rebuild_from_model() -> void:
	for child in get_children():
		child.queue_free()
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			_spawn_gem(c, r, controller.model.get_gem(c, r))

func _spawn_gem(c: int, r: int, type: int) -> GemNode:
	var gem := GemNode.new()
	gem.gem_type = type
	gem.grid_pos = Vector2i(c, r)
	gem.position = _grid_to_pixel(c, r)
	gem.set_process_input(false)
	gem.mouse_filter = Control.MOUSE_FILTER_STOP if gem is Control else 0
	gem.gem_clicked.connect(_on_gem_clicked)
	add_child(gem)
	_gems[c][r] = gem
	return gem

func _grid_to_pixel(c: int, r: int) -> Vector2:
	return Vector2(c * GEM_SIZE, r * GEM_SIZE)

func _on_gem_clicked(gem: GemNode) -> void:
	if controller.state != BoardController.State.IDLE:
		return
	if _selected == null:
		_selected = gem
		gem.set_selected(true)
	elif _selected == gem:
		gem.set_selected(false)
		_selected = null
	else:
		var from := _selected.grid_pos
		var to := gem.grid_pos
		_selected.set_selected(false)
		_selected = null
		controller.try_swap(from, to)

func _on_board_updated(model: BoardModel) -> void:
	# Sync all gem visuals to model state
	_pending_falls = 0
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			var type := model.get_gem(c, r)
			var existing: GemNode = _gems[c][r]
			if existing == null and type != -1:
				var g := _spawn_gem(c, r, type)
				# Spawn above board and fall in
				g.position.y = -GEM_SIZE
				_pending_falls += 1
				g.animate_fall(_grid_to_pixel(c, r).y)
			elif existing != null and type == -1:
				existing.queue_free()
				_gems[c][r] = null
			elif existing != null:
				if existing.grid_pos != Vector2i(c, r):
					existing.grid_pos = Vector2i(c, r)
					_pending_falls += 1
					existing.animate_fall(_grid_to_pixel(c, r).y)
				existing.gem_type = type
				existing.refresh_visuals()

	if _pending_falls == 0:
		_after_animations()
	else:
		# Wait for longest fall; rough estimate
		await get_tree().create_timer(0.5).timeout
		_after_animations()

func _on_cells_cleared(positions: Array, _counts: Dictionary) -> void:
	var max_delay := 0.0
	for pos in positions:
		var gem: GemNode = _gems[pos.x][pos.y]
		if gem:
			var tween := gem.animate_pop()
			max_delay = max(max_delay, 0.2)
			_gems[pos.x][pos.y] = null
	await get_tree().create_timer(max_delay + 0.05).timeout
	controller.after_clear_animation()

func _after_animations() -> void:
	controller.resolve_step()
