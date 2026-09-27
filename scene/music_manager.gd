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

func splash_icon(button: TextureButton) -> void:
	button.pivot_offset = button.size / 2
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.06)
	await tween.finished
