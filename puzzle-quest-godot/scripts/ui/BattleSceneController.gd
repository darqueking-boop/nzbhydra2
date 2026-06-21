extends Node
class_name BattleSceneController

## Root controller for a combat scene. Wires together board, HUD, and CombatManager.

@onready var board_view: BoardView         = $BoardContainer/BoardView
@onready var board_controller: BoardController = $BoardContainer/BoardController
@onready var hud: HUDController            = $HUD
@onready var combat_manager_node: Node     = $CombatManagerNode
@onready var victory_panel: Control        = $VictoryPanel
@onready var defeat_panel: Control         = $DefeatPanel
@onready var enemy_sprite: TextureRect     = $EnemySprite
@onready var screen_flash: ColorRect       = $ScreenFlash

var combat_manager: CombatManager

func _ready() -> void:
	victory_panel.hide()
	defeat_panel.hide()

	var enemy_data: Dictionary = _get_current_enemy()
	combat_manager = CombatManager.new()
	combat_manager_node.add_child(combat_manager)
	combat_manager.setup(GameData.player, enemy_data, board_controller)

	board_view.controller = board_controller
	hud.setup(combat_manager)

	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.damage_dealt.connect(_on_damage_dealt_vfx)

func _get_current_enemy() -> Dictionary:
	# In a full game this would come from the world map selection
	return {
		"id": "enemy",
		"name": "Dark Slime",
		"hp": 80,
		"max_hp": 80,
		"stats": {"strength": 4, "intelligence": 3, "defense": 2, "agility": 3, "xp_reward": 50},
		"max_mana": [8, 8, 8, 8, 8, 0],
		"spells": ["shadow_bolt"],
	}

func _on_combat_ended(victory: bool) -> void:
	await get_tree().create_timer(0.5).timeout
	if victory:
		victory_panel.show()
		GameData.save()
	else:
		defeat_panel.show()

func _on_damage_dealt_vfx(target: String, amount: int, element: int) -> void:
	if not is_instance_valid(screen_flash):
		return
	var color := GemTypes.COLORS.get(element, Color.WHITE)
	color.a = 0.3
	screen_flash.color = color
	screen_flash.visible = true
	var tween := create_tween()
	tween.tween_property(screen_flash, "modulate:a", 0.0, 0.25)
	tween.tween_callback(screen_flash.hide)
