class_name GameOverMenu
extends Control

func _ready() -> void:
	GameManager.game_over_menu = self

func reveal() -> void:
	# extra flair here later
	self.modulate = Color.TRANSPARENT
	self.show()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 2.0)

func _on_retry_pressed() -> void:
	self.hide()
	SignalBus.restart_day.emit()

func _on_main_menu_pressed() -> void:
	self.hide()
	AudioManager.soundtrack_fade_out()
	get_tree().change_scene_to_file("res://source/gui/menus/title_screen.tscn")

func _on_retry_mouse_entered() -> void:
	AudioManager.play("UIHoverC")

func _on_main_menu_mouse_entered() -> void:
	AudioManager.play("UIHoverA")
