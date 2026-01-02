extends Node

var card_scene = preload("res://source/scenes/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	if Input.is_action_just_pressed("debug_0"):
		pass

		# spawn a card from nothing and add it to hand
		#var card = card_scene.instantiate()
		#add_child(card)
		#card.position = Vector2(randi_range(100, 1500), randi_range(100, 500))
		#$Hand.add_card(card)
		
		# draw a card from draw pile and add it to hand
		var card: Card = $DrawPile.draw_card()
		$Hand.add_card(card)

	if Input.is_action_just_pressed("debug_9"):
		var card = card_scene.instantiate()
		$DrawPile.add_card(card)
