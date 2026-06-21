extends Control
class_name SettingsController

@onready var sfx_slider: HSlider   = $VBox/SFXRow/SFXSlider
@onready var music_slider: HSlider = $VBox/MusicRow/MusicSlider
@onready var shake_check: CheckBox = $VBox/ShakeCheck
@onready var back_btn: Button      = $VBox/BackBtn

func _ready() -> void:
	sfx_slider.value   = GameData.config["sfx_volume"]
	music_slider.value = GameData.config["music_volume"]
	shake_check.button_pressed = GameData.config["screen_shake"]

	sfx_slider.value_changed.connect(func(v): GameData.config["sfx_volume"] = v)
	music_slider.value_changed.connect(func(v):
		GameData.config["music_volume"] = v
		AudioManager._apply_volumes())
	shake_check.toggled.connect(func(v): GameData.config["screen_shake"] = v)
	back_btn.pressed.connect(_save_and_back)

func _save_and_back() -> void:
	GameData.save()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
