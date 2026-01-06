class_name Customer
extends Node2D

@export var order_attrs : Dictionary = {
	"sweet":0,
	"salty":0,
	"umami":0,
	"sour":0
} 
var satisfaction_pts : float

var initial_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = self.position
	self.position = initial_pos + Vector2(1000.0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move_onscreen() -> void:
	self.scale = Vector2(1, 1)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos, 0.8)
	await tween.finished
	SignalBus.customer_done_moving.emit()

func move_offscreen() -> void:
	self.scale = Vector2(-1, 1)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos + Vector2(1000,0), 0.6)
	await tween.finished
	SignalBus.customer_done_moving.emit()
