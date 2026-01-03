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

func load_json_file(filePath: String) -> Dictionary:
	if not FileAccess.file_exists(filePath):
		# raise error
		return {}

	var dataFile = FileAccess.open(filePath, FileAccess.READ)
	var parsed = JSON.parse_string(dataFile.get_as_text())
	return parsed

func get_card_info(card_num: int) -> Dictionary:
	var card_str: String = str(card_num) # dict keys are strings
	assert(card_str in raw_data, "Tried to read card info for nonexistent number")

	# Validate that the data exists, even if its blank
	var last = raw_data[card_str]
	var valid: bool = true
	valid = valid and "name" in last
	valid = valid and "cost" in last
	valid = valid and "image" in last
	valid = valid and "taste_profile" in last
	if not valid:
		push_warning("Incomplete card info ", card_num)
		return {}

	return last
