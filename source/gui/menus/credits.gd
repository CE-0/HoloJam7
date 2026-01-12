extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_enter_scene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func on_enter_scene():
	if (Global.game_finished):
		Global.deck = Global.default_deck 
		Global.save_data() 
		Global.game_finished = false
	else:
		return

func on_main_menu_pressed(): 
	get_tree().change_scene_to_file("res://source/gui/menus/title_screen.tscn")
