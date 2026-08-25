extends CanvasLayer

@onready var loading_label: Label = $Control/LoadingLabel
@onready var running_character: AnimatedSprite2D = $Control/RunningCharacter
@onready var dots_label: Label = $Control/DotsLabel


var dot_count: int = 0
var max_dots: int = 5
var dot_timer: float = 0.0
var dot_interval: float = 0.35  # how fast dots cycle

func _ready() -> void:
	visible = false
	#pass

func _process(delta: float) -> void:
	if not visible:
		return

	dot_timer += delta
	if dot_timer >= dot_interval:
		dot_timer = 0.0
		dot_count = (dot_count + 1) % (max_dots + 1)
		dots_label.text = ".".repeat(dot_count)

func show_loading() -> void:
	dot_count = 0
	dot_timer = 0.0
	#loading_label.text = str("Loading")
	dots_label.text = ""
	visible = true

	if not running_character.is_playing():
		running_character.play()

func hide_loading() -> void:
	visible = false

func change_scene_with_loading(path: String, min_duration: float = 1.0) -> void:
	show_loading()

	var start_time := Time.get_ticks_msec()

	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame

	var elapsed := (Time.get_ticks_msec() - start_time) / 1000.0
	if elapsed < min_duration:
		await get_tree().create_timer(min_duration - elapsed).timeout

	var next_scene: PackedScene = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(next_scene)
	hide_loading()
