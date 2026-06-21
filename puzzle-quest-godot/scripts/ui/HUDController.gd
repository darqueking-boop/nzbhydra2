extends CanvasLayer
class_name HUDController

## Drives all in-battle HUD elements: health/mana bars, spell buttons, score.

@onready var player_hp_bar: ProgressBar   = $PlayerPanel/HPBar
@onready var player_hp_label: Label       = $PlayerPanel/HPLabel
@onready var enemy_hp_bar: ProgressBar    = $EnemyPanel/HPBar
@onready var enemy_hp_label: Label        = $EnemyPanel/HPLabel
@onready var mana_bars: HBoxContainer     = $ManaPanel/ManaBars
@onready var spell_container: HBoxContainer = $SpellPanel/Spells
@onready var score_label: Label           = $ScoreLabel
@onready var turn_label: Label            = $TurnLabel
@onready var combo_label: Label           = $ComboLabel
@onready var combat_log: RichTextLabel    = $CombatLog/Log

var _combat_manager: CombatManager
var _mana_bar_nodes: Array[ProgressBar] = []

func setup(manager: CombatManager) -> void:
	_combat_manager = manager
	_build_mana_bars()
	_build_spell_buttons()
	_connect_signals()
	refresh_all()

func refresh_all() -> void:
	_update_hp()
	_update_mana()

func _connect_signals() -> void:
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.mana_gained.connect(_on_mana_gained)
	EventBus.spell_cast.connect(_on_spell_cast)
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.turn_changed.connect(_on_turn_changed)
	EventBus.level_up.connect(_on_level_up)

func _build_mana_bars() -> void:
	for child in mana_bars.get_children():
		child.queue_free()
	_mana_bar_nodes.clear()
	for i in 6:
		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = _combat_manager.player.max_mana[i]
		bar.value = _combat_manager.player.mana[i]
		bar.custom_minimum_size = Vector2(40, 120)
		bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = GemTypes.COLORS.get(i, Color.GRAY)
		bar.add_theme_stylebox_override("fill", stylebox)
		mana_bars.add_child(bar)
		_mana_bar_nodes.append(bar)

func _build_spell_buttons() -> void:
	for child in spell_container.get_children():
		child.queue_free()
	for spell in _combat_manager.player.spells:
		var btn := Button.new()
		btn.text = spell.display_name
		btn.tooltip_text = "%s\nCost: %s" % [spell.description, _format_mana_cost(spell.mana_cost)]
		btn.pressed.connect(_combat_manager.cast_spell.bind(spell))
		spell_container.add_child(btn)

func _update_hp() -> void:
	var p := _combat_manager.player
	var e := _combat_manager.enemy
	player_hp_bar.max_value = p.max_hp
	player_hp_bar.value = p.hp
	player_hp_label.text = "%d / %d" % [p.hp, p.max_hp]
	enemy_hp_bar.max_value = e.max_hp
	enemy_hp_bar.value = e.hp
	enemy_hp_label.text = "%d / %d" % [e.hp, e.max_hp]

func _update_mana() -> void:
	var mana := _combat_manager.player.mana
	for i in _mana_bar_nodes.size():
		_mana_bar_nodes[i].value = mana[i] if i < mana.size() else 0

func _on_damage_dealt(target: String, amount: int, element: int) -> void:
	_update_hp()
	var color_name := GemTypes.NAMES.get(element, "")
	_log("[color=#ff6666]%s takes %d %s damage![/color]" % [target, amount, color_name])
	_flash_hp_bar(target == _combat_manager.player.id)

func _on_mana_gained(color: int, amount: int) -> void:
	_update_mana()

func _on_spell_cast(caster: String, spell_id: String) -> void:
	_log("[color=#cc88ff]%s casts %s![/color]" % [caster, spell_id])
	_update_hp()
	_update_mana()

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_turn_changed(is_player: bool) -> void:
	turn_label.text = "YOUR TURN" if is_player else "ENEMY TURN"
	turn_label.modulate = Color.GREEN if is_player else Color.RED

func _on_level_up(level: int) -> void:
	_log("[color=#ffdd00]Level Up! Now level %d[/color]" % level)

func _log(msg: String) -> void:
	combat_log.append_text(msg + "\n")
	combat_log.scroll_to_line(combat_log.get_line_count())

func _flash_hp_bar(is_player: bool) -> void:
	var bar := player_hp_bar if is_player else enemy_hp_bar
	var tween := create_tween()
	tween.tween_property(bar, "modulate", Color.RED, 0.1)
	tween.tween_property(bar, "modulate", Color.WHITE, 0.2)

func _format_mana_cost(cost: Array[int]) -> String:
	var parts := []
	for i in cost.size():
		if cost[i] > 0:
			parts.append("%d %s" % [cost[i], GemTypes.NAMES.get(i, "?")])
	return ", ".join(parts) if parts else "Free"
