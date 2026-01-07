class_name GameUI
extends Control

# NOTE: This currently doesnt scale to resolution AT ALL

var total_orders: int = 0

@onready var reqA_label: Label = %ReqA
@onready var reqB_label: Label = %ReqB
@onready var reqC_label: Label = %ReqC
@onready var reqD_label: Label = %ReqD

@onready var dishA_label: Label = %DishA
@onready var dishB_label: Label = %DishB
@onready var dishC_label: Label = %DishC
@onready var dishD_label: Label = %DishD

@onready var order_nums: Label = %OrderProgress
@onready var order_name: Label = %OrderName

# Clock works on its own

func _ready() -> void:
	pass
	GameManager.HUD = self

func update_order_reqs(taste_reqs: Dictionary) -> void:
	var temp: int = taste_reqs["sweet"]
	reqA_label.text = str(temp, " sweet")
	reqA_label.visible = (temp != 0)

	temp = taste_reqs["salty"]
	reqB_label.text = str(temp, " salty")
	reqB_label.visible = (temp != 0)

	temp = taste_reqs["sour"]
	reqC_label.text = str(temp, " sour")
	reqC_label.visible = (temp != 0)

	temp = taste_reqs["umami"]
	reqD_label.text = str(temp, " umami")
	reqD_label.visible = (temp != 0)

func update_dish_stats(taste_state: Dictionary) -> void:
	var temp: int = taste_state["sweet"]
	dishA_label.text = str(temp, " sweet")
	dishA_label.visible = (temp != 0)

	temp = taste_state["salty"]
	dishB_label.text = str(temp, " salty")
	dishB_label.visible = (temp != 0)

	temp = taste_state["sour"]
	dishC_label.text = str(temp, " sour")
	dishC_label.visible = (temp != 0)

	temp = taste_state["umami"]
	dishD_label.text = str(temp, " umami")
	dishD_label.visible = (temp != 0)

func set_order_name(name_s: String) -> void:
	order_name.text = str("1x ", name_s)

func set_total_orders(value: int) -> void:
	total_orders = value

func update_current_order_num(value: int) -> void:
	# todo: resize or something for double digit orders
	order_nums.text = "%d/%d" % [value, total_orders]
