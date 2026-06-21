extends Control
class_name MainMenuController

@onready var new_game_btn: Button   = $VBox/NewGameBtn
@onready var continue_btn: Button   = $VBox/ContinueBtn
@onready var settings_btn: Button   = $VBox/SettingsBtn
@onready var quit_btn: Button       = $VBox/QuitBtn
@onready var version_label: Label   = $VersionLabel

func _ready() -> void:
	version_label.text = ProjectSettings.get_setting("application/config/version", "1.0.0")
	var save_exists := GameData.load_save()
	continue_btn.disabled = not save_exists

	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(get_tree().quit)

func _on_new_game() -> void:
	GameData.player["level"]  = 1
	GameData.player["xp"]     = 0
	GameData.player["hp"]     = 100
	GameData.player["max_hp"] = 100
	GameData.player["gold"]   = 0
	GameData.player["mana"]   = [0, 0, 0, 0, 0, 0]
	GameData.player["spells"] = ["fireball", "heal_wave"]
	_change_scene("res://scenes/WorldMap.tscn")

func _on_continue() -> void:
	_change_scene("res://scenes/WorldMap.tscn")

func _on_settings() -> void:
	_change_scene("res://scenes/Settings.tscn")

func _change_scene(path: String) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file(path)
