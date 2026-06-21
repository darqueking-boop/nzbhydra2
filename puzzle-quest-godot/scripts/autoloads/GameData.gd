extends Node

## Persistent game state singleton. Holds player progress, unlocks, and config.

const SAVE_PATH := "user://savegame.cfg"

var player := {
	"name": "Hero",
	"level": 1,
	"xp": 0,
	"xp_to_next": 100,
	"hp": 100,
	"max_hp": 100,
	"mana": [0, 0, 0, 0, 0, 0],  # one per gem color
	"gold": 0,
	"spells": [],
	"items": [],
	"stats": {
		"strength": 5,
		"intelligence": 5,
		"agility": 5,
		"defense": 3,
	}
}

var campaign := {
	"current_chapter": 0,
	"completed_battles": [],
	"unlocked_areas": ["starting_town"],
}

var config := {
	"sfx_volume": 1.0,
	"music_volume": 0.8,
	"screen_shake": true,
}

func save() -> void:
	var cfg := ConfigFile.new()
	_dict_to_cfg(cfg, "player", player)
	_dict_to_cfg(cfg, "campaign", campaign)
	_dict_to_cfg(cfg, "config", config)
	cfg.save(SAVE_PATH)

func load_save() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	_cfg_to_dict(cfg, "player", player)
	_cfg_to_dict(cfg, "campaign", campaign)
	_cfg_to_dict(cfg, "config", config)
	return true

func gain_xp(amount: int) -> void:
	player["xp"] += amount
	EventBus.xp_gained.emit(amount)
	while player["xp"] >= player["xp_to_next"]:
		_level_up()

func _level_up() -> void:
	player["xp"] -= player["xp_to_next"]
	player["level"] += 1
	player["xp_to_next"] = int(player["xp_to_next"] * 1.4)
	player["max_hp"] += 10
	player["hp"] = player["max_hp"]
	player["stats"]["strength"] += 1
	player["stats"]["defense"] += 1
	EventBus.level_up.emit(player["level"])

func _dict_to_cfg(cfg: ConfigFile, section: String, data: Dictionary) -> void:
	for key in data:
		cfg.set_value(section, key, data[key])

func _cfg_to_dict(cfg: ConfigFile, section: String, data: Dictionary) -> void:
	for key in cfg.get_section_keys(section):
		if key in data:
			data[key] = cfg.get_value(section, key)
