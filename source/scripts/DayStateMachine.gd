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

var time_in_day: int = 60
var total_orders: int # theres redundant copies of this var, one in each machine
var current_day: int = 1

func _ready() -> void:
	GameManager.day_machine = self
	SignalBus.time_ran_out.connect(_on_time_ran_out)
	SignalBus.all_orders_completed.connect(_on_all_orders_completed)

func day_setup_phase() -> void:
	current_state = DayState.SETUP

	GameManager.HUD.set_current_day(current_day)
	GameManager.reset_dish_hud()
	GameManager.order_machine.reset()

	# New days can mean new values for a handful of variables
	# How many orders in the day? Average difficulty of orders? How long to finish the day?

	total_orders = 3
	GameManager.set_total_order_num(total_orders)
	GameManager.HUD.update_current_order_num(0)

	GameManager.order_gen.set_difficulty(current_day+2)

	GameManager.game_timer.setup(time_in_day)

	# Visual setup
	GameManager.HUD.fade_in(1.0)
	await get_tree().create_timer(0.25).timeout
	GameManager.cook.move_onscreen()
	await get_tree().create_timer(1.0).timeout
	GameManager.fill_hand()

func day_order_phase() -> void:
	current_state = DayState.ORDER
	GameManager.game_timer.start()
	GameManager.order_machine.order_begin_phase() # a little direct

func day_pass_phase() -> void:
	print("day successful!")
	current_state = DayState.PASS
	current_day = current_day + 1 # this doesn't visually update yet
	# bring up interface to add / remove cards 
	

	GameManager.cook.move_offscreen()
	await SignalBus.customer_done_moving 
	
	GameManager.begin_card_selection()

	# fade out?
	#GameManager.HUD.fade_out(1.0)

	# remove after card select works
	await get_tree().create_timer(2.0).timeout
	day_setup_phase()

func day_fail_phase() -> void:
	# This interrupts the order state machine so need to do some of that work
	print("day failed!")
	current_state = DayState.FAIL

	# Freeze input
	GameManager.order_machine.end_on_fail()

	# hide customer
	GameManager.customer.move_offscreen()

	# Reset to start of day
	GameManager.game_over_menu.reveal()

	await get_tree().create_timer(1.0).timeout
	GameManager.plate.move_offscreen(-1.0)
	GameManager.cook.move_offscreen()

func _on_time_ran_out() -> void:
	# different triggers can come in at nearly the same time
	if current_state != DayState.PASS:
		day_fail_phase()

func _on_all_orders_completed() -> void:
	day_pass_phase()

func _on_serve_pressed() -> void:
	# Instead of directly looking at the button, waits for a redirect from manager
	day_order_phase() 

func on_card_selection_confirmed(): 
	GameManager.HUD.fade_out(1.0)
	await get_tree().create_timer(2.0).timeout
	day_setup_phase()
