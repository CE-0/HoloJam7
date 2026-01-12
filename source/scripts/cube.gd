class_name Cube
extends Node

# Like a magic cube, holds info for every legal card in the game
# Autoload?

var cube_data_path = "res://source/data/cube.json"
var raw_data: Dictionary = {}

func _ready() -> void:
	pass
	raw_data = load_json_file(cube_data_path)
	pass
	#get_reward_cards(2,2,1,1)

func load_json_file(filePath: String) -> Dictionary:
	if not FileAccess.file_exists(filePath):
		# raise error
		return {}

	var dataFile = FileAccess.open(filePath, FileAccess.READ)
	var parsed = JSON.parse_string(dataFile.get_as_text()) 
	return parsed

func get_card_info(card_num: int) -> Dictionary:
	var card_str: String = str(card_num) # dict keys are strings
	assert(card_str in raw_data, str("Tried to read card info for nonexistent number ", card_num))

	# Validate that the data exists, even if its blank
	var last = raw_data[card_str]
	var valid: bool = true
	valid = valid and "name" in last
	valid = valid and "cost" in last
	valid = valid and "image" in last
	valid = valid and "taste_profile" in last
	valid = valid and "special" in last
	# if special is true, these two must exist. If false, dont really care
	if last["special"]:
		valid = valid and "bonus_power" in last
		valid = valid and "bonus_profile" in last
	assert(valid, str("Incomplete card info ", card_num))

	return last

func get_reward_cards(col_a: int, col_b: int, col_c: int, wild: int) -> Array[int]:
	# Pick num cards to be offered to the player at the end of the day
	# parameters are int vals corresponding to number of cards to pull from that group
	# col a: 1-8
	# col b: 11-14
	# col c: 30-34
	# wildcard: any
	# There's a lot of hardcoding going on here but thats the sitch
	var last: Array[int] = []

	# dupe protection: reroll dupes once
	for i in range(col_a):
		var next = randi_range(1,8)
		if next in last:
			next = randi_range(1,8)
		last.append(next)

	for i in range(col_b):
		var next = randi_range(11,14)
		if next in last:
			next = randi_range(11,14)
		last.append(next)

	for i in range(col_c):
		var next = randi_range(30,34)
		if next in last:
			next = randi_range(30,34)
		last.append(next)

	for i in range(wild):
		var options = raw_data.keys()
		options.shuffle()
		var next = int(options[0])
		if next in last:
			next = int(options[1])
		last.append(next)

	last.sort()
	print(last)
	return last
