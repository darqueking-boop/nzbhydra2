extends Node

## Manages SFX and music playback with pooling and volume control.

const SFX_POOL_SIZE := 8

var _music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index := 0

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)
	_apply_volumes()

func play_music(stream: AudioStream, fade_in: float = 0.5) -> void:
	if _music_player.playing:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_in * 0.5)
		await tween.finished
	_music_player.stream = stream
	_music_player.volume_db = -80.0
	_music_player.play()
	var tween2 := create_tween()
	tween2.tween_property(_music_player, "volume_db", linear_to_db(GameData.config["music_volume"]), fade_in * 0.5)

func play_sfx(stream: AudioStream, pitch: float = 1.0) -> void:
	var player := _sfx_pool[_sfx_index % SFX_POOL_SIZE]
	_sfx_index += 1
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = linear_to_db(GameData.config["sfx_volume"])
	player.play()

func stop_music() -> void:
	_music_player.stop()

func _apply_volumes() -> void:
	_music_player.volume_db = linear_to_db(GameData.config["music_volume"])
