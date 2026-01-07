class_name DayStateMachine
extends Node

# Tracks the states and phases of a day in the game
# 
# States outlined below
# Notable transitions:
#   Starts in SETUP
#   Automatically goes to ORDER, sets up order state machine
#   Timer running out moves to FAIL state
#   Finishing all orders moves to PASS state
#   FAIL state returns to SETUP of same day
#   PASS returns to SETUP of next day

enum DayState {
	SETUP, # Start of day phase, player can look at and manage deck
	ORDER, # Order loop is executing
	FAIL, # Reset current day
	PASS # After orders update deck and get ready for new day
}
var current_state: DayState = DayState.SETUP

var time_in_day: int = 300
var total_orders: int # theres redundant copies of this var, one in each machine

func _ready() -> void:
	GameManager.day_machine = self
	SignalBus.time_ran_out.connect(_on_time_ran_out)
	SignalBus.all_orders_completed.connect(_on_all_orders_completed)

func day_setup_phase() -> void:
	current_state = DayState.SETUP

	# determine number of orders for the day
	total_orders = 6
	GameManager.set_total_order_num(total_orders)

	# GameManager.order_gen.set_difficulty(a)

	GameManager.game_timer.setup(time_in_day)
	GameManager.dish_taste_reset()
	GameManager.fill_hand()

func day_order_phase() -> void:
	current_state = DayState.ORDER
	GameManager.game_timer.start()
	GameManager.order_machine.order_begin_phase() # a little direct

func day_pass_phase() -> void:
	print("day successful!")

	# stop player input

	# bring up interface to add / remove cards

func day_fail_phase() -> void:
	# Freeze input

	# Take order away, 

	# hide customer
	GameManager.customer.move_offscreen()

	# Reset to start of day
	print("day failed!")

func _on_time_ran_out() -> void:
	day_fail_phase()

func _on_all_orders_completed() -> void:
	day_pass_phase()

func _on_serve_pressed() -> void:
	# Instead of directly looking at the button, waits for a redirect from manager
	day_order_phase()
