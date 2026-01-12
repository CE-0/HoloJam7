class_name Customer
extends Node2D

# I'm gonna cheat and use this to generally tell if the object is a customer or haachama
@export var exit_dir: float = 1.0

var initial_pos: Vector2
var text_bubble: Sprite2D

var sprite_fan: Resource = preload("res://assets/characters/Fan2.png")
var sprite_bau: Resource = preload("res://assets/characters/Bau.png")
var sprite_baubau: Resource = preload("res://assets/characters/BauBau.png")
var sprite_fbk: Resource = preload("res://assets/characters/FBK.png")

var fan_sprites = [sprite_fan, sprite_bau, sprite_baubau, sprite_fbk]

func _ready() -> void:
	initial_pos = self.position
	self.position = initial_pos + Vector2(exit_dir*1000.0,0)
	text_bubble = get_node_or_null("Bubble")
	if text_bubble != null:
		text_bubble.hide()

func _process(delta: float) -> void:
	pass

func move_onscreen() -> void:
	random_sprite()

	self.scale.x = abs(self.scale.x)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos, 0.8)
	await tween.finished
	SignalBus.customer_done_moving.emit()

func move_offscreen() -> void:
	if text_bubble != null:
		text_bubble.hide()

	self.scale.x = self.scale.x*-1
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos + Vector2(exit_dir*1000,0), 0.6)
	await tween.finished
	SignalBus.customer_done_moving.emit()

func say_order(order: Order) -> void:
	if text_bubble == null:
		return
	if exit_dir == -1.0:
		return
	%Food.texture = load(order.image_path)
	text_bubble.show()
	await get_tree().create_timer(1.25).timeout
	text_bubble.hide()

func random_sprite() -> void:
	# If customer (not cook) pick one of available sprites
	if exit_dir == -1.0:
		return
	$Character.texture = fan_sprites.pick_random()
