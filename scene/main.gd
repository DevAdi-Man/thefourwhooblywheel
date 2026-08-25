extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var title: Label = $UI/Title
@onready var character: TextureRect = $UI/Character
@onready var play_button: TextureButton = $UI/PlayButton
@onready var cart: AnimatedSprite2D = $UI/Control/Cart
@onready var sound_button: TextureButton = $UI/SoundButton

func _ready() -> void:
	MusicManager.sync_sound_button(sound_button)
	_animate_intro()

func _animate_intro() -> void:
	# Fade + slide in title
	title.modulate.a = 0.0
	var title_start_pos := title.position
	title.position.y -= 60
	var intro_tween := create_tween()
	intro_tween.set_parallel(true)
	intro_tween.tween_property(title, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(title, "position:y", title_start_pos.y, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Fade in character slightly after
	character.modulate.a = 0.0
	intro_tween.tween_property(character, "modulate:a", 1.0, 0.5).set_delay(0.2)

	# Gentle idle bob on the play button so it feels alive
	_start_button_idle_pulse()

func _start_button_idle_pulse() -> void:
	var pulse_tween := create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(play_button, "modulate:a", 0.75, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(play_button, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_play_button_pressed() -> void:
	pressed_sound.play()

	# Quick press feedback (color punch, no scale/size change)
	var press_tween := create_tween()
	press_tween.tween_property(play_button, "modulate", Color(0.8, 0.8, 0.8), 0.1)
	press_tween.tween_property(play_button, "modulate", Color(1, 1, 1), 0.15)

	await pressed_sound.finished

	# Fade the whole scene out before switching
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 4096
	add_child(fade_rect)

	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.35).set_ease(Tween.EASE_IN)
	await fade_tween.finished

	LoadingScene.change_scene_with_loading("res://scene/second_screen.tscn", 2.0)

func _on_sound_button_pressed() -> void:
	pressed_sound.play()
	MusicManager.toggle_music()
	MusicManager.sync_sound_button(sound_button)

	# Small flash/pulse on the cart icon as feedback, no size change
	var sound_tween := create_tween()
	sound_tween.tween_property(cart, "modulate", Color(1.3, 1.3, 1.3), 0.1)
	sound_tween.tween_property(cart, "modulate", Color(1, 1, 1), 0.2)
