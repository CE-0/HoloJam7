class_name PauseMenu
extends Control

var paused: bool = false

@onready var resume_button: TextureButton = %ResumeT
@onready var pause_menu_ui = %PauseFrame
#@onready var options_ui = %OptionsMenu

const pause_ui_pos_off = Vector2(0, -300)
const pause_ui_pos_on = Vector2.ZERO

func _ready() -> void:
	pause_menu_ui.position = pause_ui_pos_off
	paused = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if paused:
			unpause()
		else:
			pause()

func pause() -> void:
	paused = true
	get_tree().paused = true
	resume_button.grab_focus()
	self.show()
	AudioManager.soundtrack_reduce(0.25)

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_menu_ui, "position:y", pause_ui_pos_on.y, 0.1)

func unpause() -> void:
	pause_menu_ui.visible = true
	# options menu .visible = false
	paused = false
	get_tree().paused = false
	AudioManager.soundtrack_raise(0.25)

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_menu_ui, "position:y", pause_ui_pos_off.y, 0.1)
	await get_tree().create_timer(0.1).timeout

	self.hide()
	
func _on_resume_t_pressed() -> void:
	AudioManager.play("UISelectA")
	unpause()

func _on_options_t_pressed() -> void:
	AudioManager.play("UISelectA") 
	var options_menu_prld = preload("res://source/gui/menus/settings.tscn") 
	var options_menu = options_menu_prld.instantiate() 
	options_menu.z_index = 4
	add_child(options_menu)

func _on_quit_t_pressed() -> void:
	#AudioManager.play("UISelectA")
	GameManager.returning_to_menu = true
	paused = false
	get_tree().paused = false
	AudioManager.soundtrack_fade_out()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($FGFade, "color", Color.WHITE, 1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://source/gui/menus/title_screen.tscn")

func _on_resume_t_mouse_entered() -> void:
	AudioManager.play("UIHoverC")

func _on_options_t_mouse_entered() -> void:
	AudioManager.play("UIHoverB")

func _on_quit_t_mouse_entered() -> void:
	AudioManager.play("UIHoverA")
