extends Control
class_name WorldMapController

## Overworld map screen. Shows encounter nodes the player can visit.

const ENCOUNTER_DATA: Array[Dictionary] = [
	{
		"id": "enc_01", "name": "Forest Slime",
		"pos": Vector2(240, 320),
		"enemy": {
			"id": "forest_slime", "name": "Forest Slime",
			"hp": 60, "max_hp": 60,
			"stats": {"strength": 3, "intelligence": 2, "defense": 1, "agility": 2, "xp_reward": 30},
			"max_mana": [6, 6, 6, 6, 6, 0], "spells": [],
		}
	},
	{
		"id": "enc_02", "name": "Dark Knight",
		"pos": Vector2(480, 200),
		"enemy": {
			"id": "dark_knight", "name": "Dark Knight",
			"hp": 120, "max_hp": 120,
			"stats": {"strength": 8, "intelligence": 4, "defense": 6, "agility": 3, "xp_reward": 90},
			"max_mana": [10, 10, 10, 10, 10, 0], "spells": ["shadow_bolt"],
		}
	},
	{
		"id": "enc_03", "name": "Fire Drake",
		"pos": Vector2(720, 300),
		"enemy": {
			"id": "fire_drake", "name": "Fire Drake",
			"hp": 200, "max_hp": 200,
			"stats": {"strength": 12, "intelligence": 8, "defense": 5, "agility": 6, "xp_reward": 150},
			"max_mana": [15, 10, 8, 10, 10, 0], "spells": ["fireball", "inferno"],
		}
	},
]

@onready var player_label: Label = $PlayerInfo/NameLabel
@onready var hp_label: Label     = $PlayerInfo/HPLabel
@onready var level_label: Label  = $PlayerInfo/LevelLabel
@onready var gold_label: Label   = $PlayerInfo/GoldLabel

var _selected_enemy: Dictionary = {}

func _ready() -> void:
	_refresh_player_info()
	_build_encounter_buttons()

func _refresh_player_info() -> void:
	var p := GameData.player
	player_label.text = p.get("name", "Hero")
	level_label.text  = "Level %d" % p.get("level", 1)
	hp_label.text     = "HP: %d / %d" % [p.get("hp", 100), p.get("max_hp", 100)]
	gold_label.text   = "Gold: %d" % p.get("gold", 0)

func _build_encounter_buttons() -> void:
	for enc in ENCOUNTER_DATA:
		var completed := enc["id"] in GameData.campaign["completed_battles"]
		var btn := Button.new()
		btn.text = ("✓ " if completed else "") + enc["name"]
		btn.position = enc["pos"]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.modulate = Color(0.5, 0.5, 0.5, 1) if completed else Color.WHITE
		btn.pressed.connect(_on_encounter_selected.bind(enc))
		add_child(btn)

func _on_encounter_selected(enc: Dictionary) -> void:
	# Store enemy data for the battle scene to retrieve
	_selected_enemy = enc["enemy"]
	# Use a simple autoload approach: store on GameData temporarily
	GameData.player["_pending_enemy"] = _selected_enemy
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")
