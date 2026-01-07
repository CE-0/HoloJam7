class_name Order
extends Node

# Class representing an order that comes from a customer

@export var recipe_name: String
@export var image_path: String
@export var taste_reqs : Dictionary = {
	"sweet" : 0,
	"salty": 0,
	"sour": 0,
	"umami" : 0
}

func _ready() -> void:
	recipe_name = "blank recipe"
	image_path = "res://icon.svg"

func setup_reqs(reqs: Array[int]) -> void:
	taste_reqs["sweet"] = reqs[0]
	taste_reqs["salty"] = reqs[1]
	taste_reqs["sour"] = reqs[2]
	taste_reqs["umami"] = reqs[3]

func set_recipe_name(value: String) -> void:
	recipe_name = value

func setup_from_data(data: Dictionary) -> void:
	taste_reqs["sweet"] = data["taste_reqs"]["sweet"]
	taste_reqs["salty"] = data["taste_reqs"]["salty"]
	taste_reqs["sour"] = data["taste_reqs"]["sour"]
	taste_reqs["umami"] = data["taste_reqs"]["umami"]
	recipe_name = data["name"]
	image_path = data["image"]
