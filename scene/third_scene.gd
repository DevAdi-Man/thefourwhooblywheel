extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var right_answer_sound: AudioStreamPlayer = $RightAnswerSound
@onready var question: Label = $UI/Question
@onready var question_2: Label = $UI/Question2
@onready var card_button_1: TextureButton = $UI/Card/GridContainer/CardButton1
@onready var card_button_2: TextureButton = $UI/Card/GridContainer/CardButton2
@onready var card_button_3: TextureButton = $UI/Card/GridContainer/CardButton3
@onready var card_button_4: TextureButton = $UI/Card/GridContainer/CardButton4
@onready var character: TextureRect = $UI/Character
@onready var cart: Sprite2D = $UI/Control/Cart
@onready var question_sound: AudioStreamPlayer = $QuestionSound
@onready var question_1_sound: AudioStreamPlayer = $Question1Sound
@onready var sound_button: TextureButton = $UI/SoundButton
@onready var next_button: TextureButton = $UI/NextButton

var correct_found: int = 0
const TOTAL_CORRECT: int = 2

func _ready() -> void:
	next_button.visible = false
	# Correct answers (4-legged animals)
	card_button_1.pressed.connect(_on_right_button_pressed.bind(card_button_1))
	card_button_2.pressed.connect(_on_right_button_pressed.bind(card_button_2))
	# Wrong answers
	card_button_3.pressed.connect(_on_wrong_button_pressed.bind(card_button_3))
	card_button_4.pressed.connect(_on_wrong_button_pressed.bind(card_button_4))

	await get_tree().process_frame  # let GridContainer/CenterContainer finish layout first

	# Hide cards until both questions finish
	var cards: Array[TextureButton] = [card_button_1, card_button_2, card_button_3, card_button_4]
	for btn in cards:
		btn.modulate.a = 0.0
		btn.visible = false
	MusicManager.sync_sound_button(sound_button)
	await _animate_intro()

func _animate_intro() -> void:
	# Question 1: slide down from top + play its narration, wait for both
	question.modulate.a = 0.0
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
	question_2.modulate.a = 0.0
	var question_2_start_y := question_2.position.y
	question_2.position.y -= 60

	var question_2_tween := create_tween()
	question_2_tween.set_parallel(true)
	question_2_tween.tween_property(question_2, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	question_2_tween.tween_property(question_2, "position:y", question_2_start_y, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	question_1_sound.play()
	await question_2_tween.finished
	if question_1_sound.playing:
		await question_1_sound.finished

	# Character fade in
	character.modulate.a = 0.0
	var char_tween := create_tween()
	char_tween.tween_property(character, "modulate:a", 1.0, 0.5)

	# Now reveal the grid cards, popping in one by one with a slight bounce
	var cards: Array[TextureButton] = [card_button_1, card_button_2, card_button_3, card_button_4]
	var stagger_delay := 0.12
	var pop_duration := 0.4

	for i in cards.size():
		var btn: TextureButton = cards[i]
		btn.visible = true
		btn.pivot_offset = btn.size / 2   # scale from center, not corner

		btn.scale = Vector2(0.0, 0.0)
		btn.modulate.a = 0.0

		var delay := i * stagger_delay

		var card_tween := create_tween()
		card_tween.set_parallel(true)
		card_tween.tween_property(btn, "scale", Vector2(1.0, 1.0), pop_duration).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.tween_property(btn, "modulate:a", 1.0, pop_duration * 0.6).set_delay(delay)

func _on_back_button_pressed() -> void:
	var tree := get_tree()
	pressed_sound.play()
	await pressed_sound.finished

	LoadingScene.change_scene_with_loading("res://scene/second_screen.tscn", 2.0)

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
	btn.button_pressed = true
	# Prevent this button from being tapped again and double-counting
	#btn.disabled = true

	correct_found += 1
	if correct_found >= TOTAL_CORRECT:
		await right_answer_sound.finished
		next_button.visible = true

func _press_feedback(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	var tween: Tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.8, 0.8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _correct_feedback(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	var tween: Tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _on_next_button_pressed() -> void:
	pressed_sound.play()
	await MusicManager.splash_icon(next_button)
	LoadingScene.change_scene_with_loading("res://scene/fourth_scene.tscn")
