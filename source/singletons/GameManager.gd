extends Node

# Big boy tracker of everything that takes place in a game
# Primary job is to interface between objects that otherwise don't know about each other

# Careful of scopes of stuff pulled out into state machines

const MAX_CARDS_PER_HAND: int = 5
const REROLL_COST: int = 1

# These are filled externally
var draw_pile: Pile
var discard_pile: Pile
var hand: Hand

var HUD: GameUI
var debugHUD: DevHUD
var game_timer: GameTimer
var game_over_menu: GameOverMenu 
var card_select_menu : CardSelectMenu

var plate: OrderPlate
var cook: Customer
var customer: Customer
var order_gen: OrderGenerator

var day_machine: DayStateMachine
var order_machine: OrderStateMachine

var dish_taste = {
	"sweet": 0,
	"salty": 0,
	"sour": 0,
	"umami": 0
}
var current_order: Order
var total_orders: int

func _ready() -> void:
	SignalBus.discard.connect(_on_discard)
	SignalBus.reroll.connect(_on_reroll)
	SignalBus.card_tapped.connect(_on_card_tapped)
	SignalBus.pile_empty.connect(_on_pile_empty)
	SignalBus.serve_pressed.connect(_on_serve_pressed)
	SignalBus.restart_day.connect(_on_restart_day)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_0"):
		fill_hand()

func game_start() -> void:
	#await get_tree().process_frame
	# dev: fill draw pile with dummy deck
	var card_scene = preload("res://source/scenes/card.tscn")
	for x in range(0,20):
		var card = card_scene.instantiate()
		add_child(card)
		card.setup_from_card_num(randi_range(1,4))
		draw_pile.add_card(card)

	await get_tree().create_timer(0.5).timeout # ?
	day_machine.day_setup_phase()

func set_total_order_num(value: int) -> void:
	total_orders = value
	GameManager.HUD.set_total_orders(total_orders)

func get_new_order(order_num: int) -> void:
	current_order = order_gen.get_single_order()
	HUD.update_order_reqs(current_order.taste_reqs)
	HUD.set_order_name(current_order.recipe_name)
	HUD.update_dish_stats(dish_taste)
	HUD.update_current_order_num(order_num)

	# super awkward here
	customer.say_order(current_order)
	plate.set_food(current_order)
	await get_tree().create_timer(0.1).timeout
	plate.move_onscreen()

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

func reset_dish_hud() -> void:
	# Resets order reqs, order name, and dish stats
	dish_taste["sweet"] = 0
	dish_taste["salty"] = 0
	dish_taste["sour"] = 0
	dish_taste["umami"] = 0
	HUD.update_dish_stats(dish_taste)
	HUD.update_order_reqs(dish_taste)
	HUD.set_order_name("")

func draw_card_to_hand() -> void:
	# Move a single card from the draw pile to the hand
	var card: Card = draw_pile.draw_from()
	if card != null:
		hand.add_card(card)
		await get_tree().create_timer(0.15).timeout
		AudioManager.play("CardSelectB")

func fill_hand() -> void:
	# Check if players hand is full and if not draw cards from pile to add to it
	# Player should not have to automatically draw ever
	var cards_in_hand: int = hand.get_cards_count()
	var diff = MAX_CARDS_PER_HAND - cards_in_hand
	for x in range(0,diff):
		draw_card_to_hand()

func can_play_card() -> bool:
	# Called by cards to verify if playing is allowed
	# So far only restriction is must be during Order.Select phase
	# But leaving space for more
	if order_machine.current_state != order_machine.OrderState.SELECT:
		return false
	return true


func _on_discard(card: Card) -> void:
	hand.take_card(card)
	discard_pile.place_card(card)
	AudioManager.play("CardDiscard")

func _on_reroll(card: Card) -> void:
	AudioManager.play("CardDiscard")
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
		# If nothing in discard, can't do any work
		# also thats an error state
		if discard_pile.size() == 0:
			push_warning("Draw and discard piles both ran out")
			return
		var pack = discard_pile.remove_all_cards()
		draw_pile.add_cards(pack)
		draw_pile.shuffle()

		# Audio stuff
		await get_tree().create_timer(0.15).timeout
		AudioManager.play("CardShuffle")
		await get_tree().create_timer(0.67).timeout
		AudioManager.stop("CardShuffle")

func _on_serve_pressed() -> void:
	# redirect the signal to one of the two state machines, as need be
	if day_machine.current_state == day_machine.DayState.SETUP:
		day_machine._on_serve_pressed()
	elif day_machine.current_state == day_machine.DayState.ORDER:
		order_machine._on_serve_pressed()

func _on_restart_day() -> void:
	print("retrying day")
	order_machine.reset()
	reset_dish_hud()
	day_machine.day_setup_phase() 

func display_card_choices():
	pass

func on_end_day():
	print("day over, pick your cards")
	
