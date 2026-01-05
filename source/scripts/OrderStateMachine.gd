class_name OrderStateMachine
extends Node

# Tracks the states and phases of the order loop
# I feel a bit weird about having most functionality be by calling GameManager but its fine
# 
# States outlined below
# Notable transitions:
#   Starts in Wait
#   Pressing Start button moves from Wait to Begin
#   After Begin work is done, automatically transitions to Select
#   Pressing Serve button moves from Select to Serve
#   After Serve work is done, automatically transitions to Begin
#   When the day timer hits 0, abruptly transition to Wait
#
# These transitions should only happen if the day machine is in its order phase

enum OrderState {
	WAIT, # waiting for order to start
	BEGIN, # receiving order from customer
	SELECT, # selecting ingredient cards
	SERVE # serve order and collect feedback
}
var order_state: OrderState = OrderState.WAIT

func _ready() -> void:
	GameManager.order_machine = self

func order_begin_phase() -> void:
	# All the work done before a player can select cards
	order_state = OrderState.BEGIN

	# GameManager.order_gen.set_difficulty(a)
	GameManager.current_order = GameManager.order_gen.get_single_order()

	# Tell customer window what customer to display
	# customer_window.show_customer(daily_orders.customer_name)

	# Tell order window what order to display
	GameManager.HUD.update_order_reqs(GameManager.current_order.taste_reqs)
	GameManager.HUD.update_dish_stats(GameManager.dish_taste)

	# Fill hand with cards (backup)
	GameManager.fill_hand()

	# continue automatically
	order_select_phase()

func order_select_phase() -> void:
	# Phase for player to play and reroll cards
	order_state = OrderState.SELECT

func order_serve_phase() -> void:
	# Phase to complete the order and finish the loop
	order_state = OrderState.SERVE

	# Take order away

	# Hide customer

	# Collect feedback
	var score: int = GameManager.eval_score()
	# and do what with the score
	GameManager.HUD.update_feedback_label(str("dish score: ", score))
	GameManager.dish_taste_reset()

	# Fill hand with cards
	GameManager.fill_hand()
	
	# automatically return to begin phase
	# I actually don't like the stack growing like this
	order_begin_phase()

func _on_serve_pressed() -> void:
	# Instead of directly looking at the button, waits for 
	# a redirect from manager, to prevent changing states multiple times in a frame

	if order_state == OrderState.SELECT:
		order_serve_phase()
