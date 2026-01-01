class_name TitleScreen
extends Control

@onready var newgame_B: Button = %New
@onready var blackscreen: ColorRect = $BlackScreen

func _ready() -> void:
	newgame_B.grab_focus()
	$BlackScreen.visible = false
	# How-to overlay
	# Audio setup
	# Game state stuff
	pass



func _on_new_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://source/scenes/game.tscn")

func _on_continue_pressed() -> void:
	pass
	# get_tree().change_scene_to_file(path to scene select)

func _on_how_pressed() -> void:
	pass
	# tutorial or how-to page

func _on_options_pressed() -> void:
	pass

func _on_credits_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://source/gui/credits.tscn")

func _on_quit_pressed() -> void:
	blackscreen.visible = true
	get_tree().quit()
