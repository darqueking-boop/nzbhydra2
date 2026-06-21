extends Node2D
class_name GemNode

## Visual representation of a single gem on the board.

const GEM_SIZE := 64.0
const FALL_SPEED := 800.0  # pixels/sec
const SELECT_SCALE := Vector2(1.15, 1.15)

var gem_type: int = GemTypes.Type.RED
var grid_pos: Vector2i = Vector2i.ZERO
var is_selected: bool = false

var _sprite: ColorRect
var _label: Label
var _tween: Tween

signal gem_clicked(gem: GemNode)

func _ready() -> void:
	_sprite = ColorRect.new()
	_sprite.size = Vector2(GEM_SIZE - 4, GEM_SIZE - 4)
	_sprite.position = Vector2(2, 2)
	add_child(_sprite)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size = Vector2(GEM_SIZE, GEM_SIZE)
	_label.add_theme_font_size_override("font_size", 22)
	add_child(_label)

	refresh_visuals()

func refresh_visuals() -> void:
	_sprite.color = GemTypes.COLORS.get(gem_type, Color.WHITE)
	_label.text = _icon_for_type(gem_type)

func set_selected(value: bool) -> void:
	is_selected = value
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", SELECT_SCALE if value else Vector2.ONE, 0.15)

func animate_fall(target_y: float) -> void:
	if _tween:
		_tween.kill()
	var dist := abs(target_y - position.y)
	var duration := dist / FALL_SPEED
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self, "position:y", target_y, duration)

func animate_pop() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08)
	_tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
	return _tween

func animate_shake() -> void:
	if _tween:
		_tween.kill()
	var original := position
	_tween = create_tween()
	_tween.tween_property(self, "position:x", original.x - 6, 0.05)
	_tween.tween_property(self, "position:x", original.x + 6, 0.05)
	_tween.tween_property(self, "position:x", original.x, 0.05)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		gem_clicked.emit(self)

func _icon_for_type(t: int) -> String:
	match t:
		GemTypes.Type.RED:    return "🔥"
		GemTypes.Type.BLUE:   return "💧"
		GemTypes.Type.GREEN:  return "🌿"
		GemTypes.Type.YELLOW: return "⚡"
		GemTypes.Type.PURPLE: return "🔮"
		GemTypes.Type.SKULL:  return "💀"
		GemTypes.Type.GOLD:   return "🪙"
		GemTypes.Type.WILDCARD: return "✨"
	return "?"
