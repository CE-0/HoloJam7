class_name DevHUD
extends Control

# UI for dev and testing, pulling stuff out to final as it finishes

func _ready() -> void:
	GameManager.debugHUD = self
	pass

func update_feedback_label(text: String) -> void:
	%DevFeedback.text = text

func _on_button_pressed() -> void:
	SignalBus.serve_pressed.emit()
