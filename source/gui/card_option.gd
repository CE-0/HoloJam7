class_name CardOption 
extends Control

@onready var checkbox = $CheckBox 
@onready var card_img = $CardImage 

var deck_idx : int 

func checked():
	return checkbox.button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
