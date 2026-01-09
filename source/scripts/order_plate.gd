class_name OrderPlate
extends Node2D

var initial_pos: Vector2

func _ready() -> void:
	initial_pos = self.position
	self.position = initial_pos + Vector2(-1.0*1000.0,0)

func move_onscreen() -> void:
	self.scale.x = abs(self.scale.x)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos, 0.3)

func move_offscreen(dir: float = -1.0) -> void:
	# same as usual but specify a direction to move
	# >0 is right, <0 is left

	# TODO: change this to shrinking into the customer for a pass
	self.scale.x = self.scale.x*-1
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos + Vector2(dir*2000,0), 0.4)
	await tween.finished
	reset_offscreen()

func reset_offscreen() -> void:
	self.hide()
	self.position = initial_pos + Vector2(-1000.0,0)
	self.show()

func set_food(order: Order) -> void:
	%Food.texture = load(order.image_path)
