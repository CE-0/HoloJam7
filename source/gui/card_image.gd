class_name CardImage
extends Control

# Control only visual representation of cards
# Some annoying dupe code but w.e.

@export var card_num: int = -1
var prepped: bool = false

func _ready() -> void:
	if not prepped and card_num != -1:
		setup_from_card_num(card_num)

func set_count(value: int) -> void:
	$Count.text = str("x", value)

func setup_from_card_num(num: int) -> void:
	# given a card number as in the cube, update all variables to match
	prepped = true
	card_num = num
	#{ "image": "res://icon.svg", "name": "Card 0", "cost": 0.0, 
	# 	"taste_profile": { "sweet": 0.0, "salty": 0.0, "sour": 0.0, "umami": 0.0 } }
	var info: Dictionary = CardCube.get_card_info(num)
	print("info: ", info)
	
	$NameLabel.text = info["name"]
	$Cost.text = str(int(info["cost"]))
	$Control/StatA.text = str(int(info["taste_profile"]["sweet"]))
	$Control/StatB.text = str(int(info["taste_profile"]["salty"]))
	$Control/StatC.text = str(int(info["taste_profile"]["sour"]))
	$Control/StatD.text = str(int(info["taste_profile"]["umami"]))
