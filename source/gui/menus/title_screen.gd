class_name TitleScreen
extends Control

@onready var newgame_B: TextureButton = %New
@onready var blackscreen: ColorRect = $BlackScreen

func _ready() -> void:
	newgame_B.grab_focus()
	$BlackScreen.visible = false

	# How-to overlay

	# Audio setup
	AudioManager.set_soundtrack("BgmMenu")
	await get_tree().create_timer(1.0).timeout
	AudioManager.soundtrack_start()

	# Game state stuff
	pass



func _on_new_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://source/scenes/game.tscn")
	AudioManager.play("UISelectA")
	AudioManager.soundtrack_fade_out()
	get_tree().change_scene_to_file("res://source/settings/dev_room_1.tscn")

func _on_continue_pressed() -> void:
	pass
	# get_tree().change_scene_to_file(path to scene select)

func _on_how_pressed() -> void:
	pass
	# tutorial or how-to page

func _on_options_pressed() -> void:
	AudioManager.play("UISelectA")
	pass

func _on_credits_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://source/gui/credits.tscn")

func _on_quit_pressed() -> void:
	blackscreen.visible = true
	get_tree().quit()

func _on_new_mouse_entered() -> void:
	AudioManager.play("UIHoverC")

func _on_options_mouse_entered() -> void:
	AudioManager.play("UIHoverB")

func _on_quit_mouse_entered() -> void:
	AudioManager.play("UIHoverA")
