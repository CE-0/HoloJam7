class_name DevHUD
extends Control

func _on_button_pressed() -> void:
	SignalBus.serve_pressed.emit()
