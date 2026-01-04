extends Node

# Big boy tracker of everything that takes place in a day
# Primary job is to interface between objects that otherwise don't know about each other

# Order state machine could be elsewhere, depending
# Mostly just don't know if that messes up the visible scope of objects

const MAX_CARDS_PER_HAND: int = 5

# State machine for day loop



# These are filled externally
var draw_pile: Pile
var discard_pile: Pile
var hand: Hand
var HUD: DevHUD
var order_machine: OrderStateMachine

var current_order: Order

var dish_taste = {
	"sweet": 0,
	"salty": 0,
	"sour": 0,
	"umami": 0
}


func _ready() -> void:
	SignalBus.discard.connect(_on_discard)
	SignalBus.reroll.connect(_on_reroll)
	SignalBus.card_tapped.connect(_on_card_tapped)
	SignalBus.pile_empty.connect(_on_pile_empty)
	

	#await get_tree().process_frame
	#order_begin_phase()

func _process(delta: float) -> void:
	pass
	if Input.is_action_just_pressed("debug_0"):
		fill_hand()

func add_values_to_dish(tastes: Dictionary) -> void:
	dish_taste["sweet"] = dish_taste["sweet"] + tastes["sweet"]
	dish_taste["salty"] = dish_taste["salty"] + tastes["salty"]
	dish_taste["sour"] = dish_taste["sour"] + tastes["sour"]
	dish_taste["umami"] = dish_taste["umami"] + tastes["umami"]
	HUD.update_dish_stats(dish_taste)
	#print(dish_taste)

func eval_score() -> int:
	# A score of 0 means the dish perfectly matched the taste
	var score = 0

	# simple algebra
	score = score + abs(current_order.taste_reqs["sweet"] - dish_taste["sweet"])
	score = score + abs(current_order.taste_reqs["salty"] - dish_taste["salty"])
	score = score + abs(current_order.taste_reqs["sour"] - dish_taste["sour"])
	score = score + abs(current_order.taste_reqs["umami"] - dish_taste["umami"])

	print("Lost ", score, " points! Good enough! Keep going!")
	return -score

func dish_taste_reset() -> void:
	dish_taste["sweet"] = 0
	dish_taste["salty"] = 0
	dish_taste["sour"] = 0
	dish_taste["umami"] = 0
	HUD.update_dish_stats(dish_taste)

func draw_card_to_hand() -> void:
	# Move a single card from the draw pile to the hand
	var card: Card = draw_pile.draw_card()
	if card != null:
		hand.add_card(card)

func fill_hand() -> void:
	# Check if players hand is full and if not draw cards from pile to add to it
	# Player should not have to automatically draw ever
	var cards_in_hand: int = hand.get_cards_count()
	var diff = MAX_CARDS_PER_HAND - cards_in_hand
	for x in range(0,diff):
		draw_card_to_hand()

func _on_discard(card: Card) -> void:
	hand.take_card(card)
	discard_pile.place_card(card)

func _on_reroll(card: Card) -> void:
	hand.take_card(card)
	discard_pile.place_card(card)
	draw_card_to_hand()

func _on_card_tapped(card: Card) -> void:
	add_values_to_dish(card.get_taste_values())
	hand.take_card(card)
	discard_pile.place_card(card)
	draw_card_to_hand()

func _on_pile_empty(pile: Pile) -> void:
	# If there's very few cards so both packs are empty, it can cause some soft locks
	if pile == draw_pile:
		var pack = discard_pile.remove_all_cards()
		if pack.size() > 0:
			draw_pile.add_cards(pack)
			draw_pile.shuffle()
