class_name CardImage
extends Control

# Control only visual representation of cards
# Some annoying dupe code but w.e.

@export var card_num: int = -1
var prepped: bool = false

@onready var image_food: TextureRect = $sprites/image_food
@onready var image_generic: TextureRect = $sprites/image_generic
@onready var image_special = $sprites/image_special

func _ready() -> void:
	await get_tree().process_frame
	if not prepped and card_num != -1:
		setup_from_card_num(card_num)

func set_count(value: int) -> void:
	$Count.text = str("x", value)

#func set_card_num(num: int) -> void:
	## Store the card num now and act on it later
	#prepped = false
	#card_num = num

func setup_from_card_num(num: int) -> void:
	# given a card number as in the cube, update all variables to match
	prepped = true
	card_num = num

	# info: { "special": true, "image": "res://assets/ingredients/Egg.png", 
	# "name": "Egg", "cost": 2.0, 
	# "taste_profile": { "sweet": 0.0, "salty": 0.0, "sour": 0.0, "umami": 1.0 }, 
	# "bonus_power": 4.0, "bonus_profile": [0.0] }

	var info: Dictionary = CardCube.get_card_info(card_num)
	# print("info: ", info)

	# Ripped all this from the card.update_face method
	$NameLabel.text = info["name"]
	$Cost.text = str(int(info["cost"]))
	var special: bool = info["special"]

	$sprites/image_food.texture = load(info["image"])
	$sprites/image_generic.visible = not special
	$sprites/image_special.visible = special

	var bonus_power = info["bonus_power"]
	var bonus_profile = info["bonus_profile"]

	# All this for the string at the bottom
	var tasteDict: Dictionary = {
		"sweet" : int(info["taste_profile"]["sweet"]),
		"salty": int(info["taste_profile"]["salty"]),
		"sour": int(info["taste_profile"]["sour"]),
		"umami" : int(info["taste_profile"]["umami"])
	}

	var verbose_str: String = ""
	if tasteDict["sweet"] > 0:
		verbose_str = verbose_str + "+" + str(tasteDict["sweet"]) + " sweet\n"
	if tasteDict["salty"] > 0:
		verbose_str = verbose_str + "+" + str(tasteDict["salty"]) + " salty\n"
	if tasteDict["sour"] > 0:
		verbose_str = verbose_str + "+" + str(tasteDict["sour"]) + " sour\n"
	if tasteDict["umami"] > 0:
		verbose_str = verbose_str + "+" + str(tasteDict["umami"]) + " umami\n"

	if special:
		# + num or ?
		verbose_str = verbose_str + "+"
		if bonus_power is Array:
			verbose_str = verbose_str + "?"
		else:
			verbose_str = verbose_str + str(int(bonus_power))
		# + num or ?
		verbose_str = verbose_str + " to "
		if bonus_profile.size() == 1:
			verbose_str = verbose_str + str({0.0: "sw.", 1.0: "sa.", 2.0: "so.", 3.0: "um."}[bonus_profile[0]])
		else:
			verbose_str = verbose_str + "?"
	$Control/Verbose.text = verbose_str
