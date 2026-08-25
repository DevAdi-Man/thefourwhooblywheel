extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var button_number_1: TextureButton = $UI/HBoxContainer/ButtonNumber1
@onready var button_number_2: TextureButton = $UI/HBoxContainer/ButtonNumber2
@onready var button_number_3: TextureButton = $UI/HBoxContainer/ButtonNumber3
@onready var button_number_4: TextureButton = $UI/HBoxContainer/ButtonNumber4
@onready var cart: Sprite2D = $UI/Control/Cart
@onready var character: TextureRect = $UI/Character
@onready var question: Label = $UI/Question
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var right_answer_sound: AudioStreamPlayer = $RightAnswerSound
@onready var question_sound: AudioStreamPlayer = $QuestionSound
@onready var sound_button: TextureButton = $UI/SoundButton

func _ready() -> void:
	button_number_1.pressed.connect(_on_wrong_button_pressed.bind(button_number_1))
	button_number_2.pressed.connect(_on_wrong_button_pressed.bind(button_number_2))
	button_number_3.pressed.connect(_on_wrong_button_pressed.bind(button_number_3))
	await get_tree().process_frame  # let HBoxContainer finish laying out children first

	# Hide wheel buttons until the question finishes
	var buttons: Array[TextureButton] = [button_number_1, button_number_2, button_number_3, button_number_4]
	for btn in buttons:
		btn.modulate.a = 0.0
		btn.visible = false
	MusicManager.sync_sound_button(sound_button)
	await _animate_intro()

func _animate_intro() -> void:
	# Fade + slide down in the question from the top
	question.modulate.a = 0.0
	var question_start_y := question.position.y
	question.position.y -= 60  # start further up for a clearer "coming from top" feel

	var question_tween := create_tween()
	question_tween.set_parallel(true)
	question_tween.tween_property(question, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	question_tween.tween_property(question, "position:y", question_start_y, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Character fade in alongside the question
	character.modulate.a = 0.0
	question_tween.tween_property(character, "modulate:a", 1.0, 0.5).set_delay(0.15)

	# Play the question narration and wait for both the tween and the sound to finish
	question_sound.play()
	await question_tween.finished
	if question_sound.playing:
		await question_sound.finished

	# Now reveal the wheel buttons rolling in from the left, one by one, spinning to their set position
	var buttons: Array[TextureButton] = [button_number_1, button_number_2, button_number_3, button_number_4]
	var stagger_delay := 0.15
	var roll_duration := 0.6
	var offset_x := 400.0

	for i in buttons.size():
		var btn: TextureButton = buttons[i]
		btn.visible = true

		# Rotate around the button's center, not its top-left corner
		btn.pivot_offset = btn.size / 2

		var target_pos := btn.position   # original position you set in editor
		var target_rot := btn.rotation   # original rotation you set in editor

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

func _press_feedback(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	var tween: Tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.8, 0.8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_button_number_4_pressed() -> void:
	right_answer_sound.play()
	_correct_feedback(button_number_4)


func _correct_feedback(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	var tween: Tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await right_answer_sound.finished
	LoadingScene.change_scene_with_loading("res://scene/third_scene.tscn",2.0)
