class_name FeedbackBubble
extends TextureRect

@export var react_int: int = 0

var initial_pos: Vector2
var react_array = []

@onready var path_ehh = preload("res://assets/characters/Ehh.png")
@onready var path_yay = preload("res://assets/characters/YAY.png")
@onready var path_what = preload("res://assets/characters/WhatTheFrick.png")
@onready var reaction_tex: TextureRect = %Reaction

func _ready() -> void:
	# 0: yay
	# 1: ehh
	# 2: what
	react_array = [path_yay, path_ehh, path_what]
	
	initial_pos = self.position
	self.position = initial_pos + Vector2(500.0,0)
	
	#reaction_play()

func reaction_play(react: int) -> void:
	reaction_tex.texture = react_array[react]
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos, 0.25)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", initial_pos + Vector2(500,0), 0.25)
