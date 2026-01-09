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
var current_state: OrderState = OrderState.WAIT

var current_order_num: int = 0

func _ready() -> void:
	GameManager.order_machine = self

func reset() -> void:
	current_order_num = 0
	current_state = OrderState.WAIT

func order_begin_phase() -> void:
	# All the work done before a player can select cards
	current_state = OrderState.BEGIN

	# ususally increment at end
	if current_order_num == 0:
		current_order_num = current_order_num + 1

	# Show customer and order
	GameManager.customer.move_onscreen()
	await SignalBus.customer_done_moving

	await get_tree().create_timer(0.4).timeout
	GameManager.get_new_order(current_order_num)

	# Fill hand with cards (backup)
	GameManager.fill_hand()

	# continue automatically
	order_select_phase()

func order_select_phase() -> void:
	# Phase for player to play and reroll cards
	current_state = OrderState.SELECT

func order_serve_phase() -> void:
	# Phase to complete the order and finish the loop
	current_state = OrderState.SERVE

	# Take order away
	GameManager.plate.move_offscreen(1.0)

	# Hide customer
	GameManager.customer.move_offscreen()
	await SignalBus.customer_done_moving

	# Collect feedback
	var score: int = GameManager.eval_score()
	# and do what with the score
	GameManager.debugHUD.update_feedback_label(str("dish score: ", score))
	GameManager.reset_dish_hud()

	# Fill hand with cards
	GameManager.fill_hand()
	
	if current_order_num == GameManager.total_orders:
		SignalBus.all_orders_completed.emit()
		current_state = OrderState.WAIT
	else:
		current_order_num = current_order_num + 1
		# automatically return to begin phase
		# I actually don't like the stack growing like this
		order_begin_phase()

func end_on_fail() -> void:
	# Cleanup work after timer ran out failure
	# Not a full reset, keep order num etc
	current_state = OrderState.WAIT

func _on_serve_pressed() -> void:
	# Instead of directly looking at the button, waits for 
	# a redirect from manager, to prevent changing states multiple times in a frame

	if current_state == OrderState.SELECT:
		order_serve_phase()
