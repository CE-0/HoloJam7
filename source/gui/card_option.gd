class_name CardOption 
extends Control

@onready var card_img = $CardImage
@onready var rect = $CardImage/ColorRect

var deck_idx : int 

func checked() -> bool:
	return rect.visible == false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func toggle_rect():
	if (rect.visible):
		rect.hide()
	else:
		rect.show()

func _on_card_image_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		toggle_rect()
