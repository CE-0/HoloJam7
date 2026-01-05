class_name OrderGenerator
extends Node

# This script writes and delivers the orders to the higher level controller
# Orders are generated slightly randomly about an average difficulty which increases each day
# Difficulty is the sum of the required taste points ie: 1 sweet, 2 sour = 3 difficulty

# Possible orders are stored in menu.json
# The taste stats defined there are ratios that can be scaled as need to be hit a particular difficulty

# Order data:
# recipe_name: String
# image_path: String
# taste_reqs : Dictionary = {
# 	"sweet" : 0,
# 	"salty": 0,
# 	"sour": 0,
# 	"umami" : 0
# }

var order_scene: Resource = preload("res://source/scenes/order.tscn")
var menu_data_path = "res://source/data/menu.json"
var raw_data: Dictionary = {}
var menu_size: int

var current_difficulty: int = 12

func _ready() -> void:
	raw_data = load_json_file(menu_data_path)
	menu_size = raw_data.size()
	var z = get_single_order()

func set_difficulty(value: int) -> void:
	current_difficulty = value

func get_single_order() -> Order:
	# todo: some way of locking some orders behind a min day / difficulty
	var r = randi_range(0,menu_size-1)
	# r = 2
	var menu_item: Dictionary = raw_data[str(r)]
	# print(menu_item)
	var last: Order = order_scene.instantiate()
	var reqs: Array[int] = [
		menu_item["taste_reqs"]["sweet"],
		menu_item["taste_reqs"]["salty"],
		menu_item["taste_reqs"]["sour"],
		menu_item["taste_reqs"]["umami"]
	]
	last.setup_reqs(reqs)
	scale_taste_to_difficulty(last)
	return last

func scale_taste_to_difficulty(new_order: Order) -> void:
	var curr = new_order.taste_reqs
	var reqs: Array[float] = [
		curr["sweet"],
		curr["salty"],
		curr["sour"],
		curr["umami"]
	]
	# print(reqs)
	var sum = 0
	for item in reqs:
		sum = sum + item
	for i in range(0,4):
		reqs[i] = reqs[i] / sum
	# print(reqs)
	for i in range(0,4):
		reqs[i] = reqs[i] * current_difficulty
	# print(reqs)

	var reqsi: Array[int] = [reqs[0],reqs[1],reqs[2],reqs[3]]
	new_order.setup_reqs(reqsi)
	# print(new_order.taste_reqs)

func load_json_file(filePath: String) -> Dictionary:
	if not FileAccess.file_exists(filePath):
		# raise error
		return {}
	
	var dataFile = FileAccess.open(filePath, FileAccess.READ)
	var parsed = JSON.parse_string(dataFile.get_as_text())
	return parsed
