extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var right_answer_sound: AudioStreamPlayer = $RightAnswerSound
@onready var question_sound: AudioStreamPlayer = $QuestionSound
@onready var question_2_sound: AudioStreamPlayer = $Question2Sound
@onready var sound_button: TextureButton = $UI/SoundButton
@onready var cart: Sprite2D = $UI/Control/Cart
@onready var button_card_1: TextureButton = $UI/BoxContainer/ButtonCard1
@onready var button_card_2: TextureButton = $UI/BoxContainer/ButtonCard2
@onready var button_card_3: TextureButton = $UI/BoxContainer/ButtonCard3
@onready var question: Label = $UI/Question
@onready var question_2: Label = $UI/Question2

func _ready() -> void:
	# Card 2 is the correct answer; Cards 1 and 3 are wrong
	button_card_1.pressed.connect(_on_wrong_button_pressed.bind(button_card_1))
	button_card_2.pressed.connect(_on_right_button_pressed.bind(button_card_2))
	button_card_3.pressed.connect(_on_wrong_button_pressed.bind(button_card_3))

	await get_tree().process_frame  # let BoxContainer finish laying out children first

	MusicManager.sync_sound_button(sound_button)

	# Hide questions and cards until their turn
	question.modulate.a = 0.0
	question_2.modulate.a = 0.0
	var cards: Array[TextureButton] = [button_card_1, button_card_2, button_card_3]
	for btn in cards:
		btn.modulate.a = 0.0
		btn.visible = false

	await _animate_intro()

func _animate_intro() -> void:
	# Question 1: slide down from top + play its narration, wait for both
	var question_start_y := question.position.y
	question.position.y -= 60

	var question_tween := create_tween()
	question_tween.set_parallel(true)
	question_tween.tween_property(question, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	question_tween.tween_property(question, "position:y", question_start_y, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	question_sound.play()
	await question_tween.finished
	if question_sound.playing:
		await question_sound.finished

	# Question 2: slide down from top + play its narration, wait for both
	var question_2_start_y := question_2.position.y
	question_2.position.y -= 60

	var question_2_tween := create_tween()
	question_2_tween.set_parallel(true)
	question_2_tween.tween_property(question_2, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	question_2_tween.tween_property(question_2, "position:y", question_2_start_y, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	question_2_sound.play()
	await question_2_tween.finished
	if question_2_sound.playing:
		await question_2_sound.finished

	# Now reveal the cards rolling in from the left, one by one, spinning to their set position
	var cards: Array[TextureButton] = [button_card_1, button_card_2, button_card_3]
	var stagger_delay := 0.15
	var roll_duration := 0.6
	var offset_x := 400.0

	for i in cards.size():
		var btn: TextureButton = cards[i]
		btn.visible = true

		# Rotate/scale around the button's center, not its top-left corner
		btn.pivot_offset = btn.size / 2

		var target_pos := btn.position   # original position set in editor
		var target_rot := btn.rotation   # original rotation set in editor

		# Start off-screen to the left and pre-rotated
		btn.position.x = target_pos.x - offset_x
		btn.rotation = target_rot - TAU  # one full spin (TAU = 360°)
		btn.modulate.a = 0.0

		var delay := i * stagger_delay

		var btn_tween := create_tween()
		btn_tween.set_parallel(true)
		btn_tween.tween_property(btn, "position:x", target_pos.x, roll_duration).set_delay(delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		btn_tween.tween_property(btn, "rotation", target_rot, roll_duration).set_delay(delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		btn_tween.tween_property(btn, "modulate:a", 1.0, roll_duration * 0.5).set_delay(delay)

func _on_back_button_pressed() -> void:
	var tree := get_tree()
	pressed_sound.play()
	await pressed_sound.finished

	LoadingScene.change_scene_with_loading("res://scene/main.tscn",2.0)

func _on_sound_button_pressed() -> void:
	pressed_sound.play()
	MusicManager.toggle_music()
	MusicManager.sync_sound_button(sound_button)

	# Small flash/pulse on the cart icon as feedback, no size change
	var sound_tween := create_tween()
	sound_tween.tween_property(cart, "modulate", Color(1.3, 1.3, 1.3), 0.1)
	sound_tween.tween_property(cart, "modulate", Color(1, 1, 1), 0.2)

func _on_wrong_button_pressed(btn: TextureButton) -> void:
	wrong_sound.play()
	_press_feedback(btn)

func _on_right_button_pressed(btn: TextureButton) -> void:
	right_answer_sound.play()
	_correct_feedback(btn)

func _press_feedback(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	var tween: Tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.8, 0.8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _correct_feedback(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	var tween: Tween = create_tween()
	# Scale down and STAY there (no bounce back to 1.0)
	tween.tween_property(btn, "scale", Vector2(0.85, 0.85), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await right_answer_sound.finished
	LoadingScene.change_scene_with_loading("res://scene/main.tscn",2.0)
