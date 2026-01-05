class_name GameTimer
extends Control

var time_left_s: float = 0.0
var running: bool = false
@onready var label: Label = $Label

func _ready() -> void:
	GameManager.game_timer = self
	SignalBus.time_penalty.connect(_on_time_penalty)

func _process(delta: float) -> void:
	if running:
		decrement_time(delta)

func setup(new_time_s: float) -> void:
	# prepare timer values so player can see before starting
	time_left_s = new_time_s
	running = false
	update_face()

func start() -> void:
	running = true

func decrement_time(value_s: float) -> void:
	time_left_s = time_left_s - value_s
	time_left_s = max(time_left_s, 0.0)
	update_face()
	if time_left_s <= 0.0:
		running = false
		SignalBus.time_ran_out.emit()

func update_face() -> void:
	var seconds_left: int = round(time_left_s)
	label.text = "0:%02d" % seconds_left

func _on_time_penalty(value_s: float) -> void:
	if not running:
		return

	# play some visual feedback
	decrement_time(value_s)
