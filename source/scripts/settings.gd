extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_settings():
	Global.save_data() 
	get_tree().change_scene_to_file("res://source/gui/menus/title_screen.tscn")
