extends Node

# Running everything out of this test room
# Wont be final just a place to be messy and try stuff

var card_scene = preload("res://source/scenes/card.tscn")

var cards = []

func _ready() -> void:
	GameManager.draw_pile = $DrawPile
	GameManager.discard_pile = $DiscardPile
	GameManager.hand = $Hand
	GameManager.order_gen = $OrderGenerator

func _process(_delta: float) -> void:
	pass
	if Input.is_action_just_pressed("debug_0"):
		pass

		# spawn a card from nothing and add it to hand
		#var card = card_scene.instantiate()
		#add_child(card)
		#card.position = Vector2(randi_range(100, 1500), randi_range(100, 500))
		#$Hand.add_card(card)

		# draw a card from draw pile and add it to hand
		# var card: Card = $DrawPile.draw_card()
		# $Hand.add_card(card)

	if Input.is_action_just_pressed("debug_9"):
		pass
		# var card = card_scene.instantiate()
		# card.setup_from_card_num(randi_range(1,4))
		# cards.append(card)
		# $DrawPile.add_card(card)
