extends Node

var music_player: AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	music_player.stream = preload("res://assets/sounds/edugamery-music-7.mp3")
	music_player.play()

func toggle_music() -> void:
	if music_player.playing:
		music_player.stop()
	else:
		music_player.play()

func sync_sound_button(btn: TextureButton) -> void:
	btn.button_pressed = !music_player.playing
