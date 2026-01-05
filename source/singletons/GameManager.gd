extends Node

# Big boy tracker of everything that takes place in a day
# Primary job is to interface between objects that otherwise don't know about each other

# Order state machine could be elsewhere, depending
# Mostly just don't know if that messes up the visible scope of objects

const MAX_CARDS_PER_HAND: int = 5
const REROLL_COST: int = 1

# State machine for day loop
enum DayState {
	SETUP, # Start of day phase, player can look at and manage deck
	ORDER, # Order loop is executing
	FAIL, # Reset current day
	PASS # After orders update deck and get ready for new day
}
var day_state: DayState = DayState.SETUP

# These are filled externally
var draw_pile: Pile
var discard_pile: Pile
var hand: Hand
var HUD: DevHUD
var order_machine: OrderStateMachine
var game_timer: GameTimer
var order_gen: OrderGenerator

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
	SignalBus.serve_pressed.connect(_on_serve_pressed)
	SignalBus.time_ran_out.connect(_on_time_ran_out)


	# dev fill draw pile with dummy deck
	await get_tree().process_frame
	var card_scene = preload("res://source/scenes/card.tscn")
	for x in range(0,20):
		var card = card_scene.instantiate()
		card.setup_from_card_num(randi_range(1,4))
		draw_pile.add_card(card)

	await get_tree().create_timer(0.5).timeout
	day_setup_phase()

func _process(delta: float) -> void:
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


func day_setup_phase() -> void:
	day_state = DayState.SETUP
	game_timer.setup(30)
	fill_hand()

func day_order_phase() -> void:
	day_state = DayState.ORDER
	game_timer.start()
	order_machine.order_begin_phase() # a little direct

func day_pass_phase() -> void:
	# stop player input
	# remove customer and dish WIP
	# allow 
	print("day successful!")

func day_fail_phase() -> void:
	# Take order away, hide customer
	# Reset to start of day
	print("day failed!")

func _on_discard(card: Card) -> void:
	hand.take_card(card)
	discard_pile.place_card(card)

func _on_reroll(card: Card) -> void:
	hand.take_card(card)
	discard_pile.place_card(card)
	SignalBus.time_penalty.emit(REROLL_COST)
	draw_card_to_hand()

func _on_card_tapped(card: Card) -> void:
	SignalBus.time_penalty.emit(card.get_cost())
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

func _on_serve_pressed() -> void:
	# redirect the signal to one of the two state machines, as need be
	if day_state == DayState.SETUP:
		day_order_phase()
	elif day_state == DayState.ORDER:
		order_machine._on_serve_pressed()

func _on_time_ran_out() -> void:
	day_fail_phase()
