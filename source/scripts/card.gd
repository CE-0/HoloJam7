class_name Card
extends StaticBody2D

@export var card_num: int
@export var card_name: String
@export var image_path: String
@export var cost: int
@export var tasteDict : Dictionary = {
	"sweet" : 0,
	"salty": 0,
	"sour": 0,
	"umami" : 0
}

enum State {
	PILE,
	HELD,
	FOCUS,	# Looking closer at the card in the hand
	TAPPED
}
var current_state: int = State.HELD

var tween_t: Tween # tween dedicated to transform
var neutral_transform: Transform2D
var neutral_z_idx: int

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func setup_from_card_num(num: int) -> void:
	# Look up the given card number in the cube and setup with that info
	# Info todo: image
	var info = CardCube.get_card_info(num)
	
	card_num = num
	card_name = info["name"]
	cost = int(info["cost"])

	tasteDict["sweet"] = int(info["taste_profile"]["sweet"])
	tasteDict["salty"] = int(info["taste_profile"]["salty"])
	tasteDict["sour"] = int(info["taste_profile"]["sour"])
	tasteDict["umami"] = int(info["taste_profile"]["umami"])

	update_face()

func get_taste_values() -> Dictionary:
	return tasteDict

func get_cost() -> int:
	return cost

func get_num() -> int:
	return card_num

func update_face() -> void:
	# pass all card info to the card ui
	$NameLabel.text = card_name
	$Control/StatA.text = str(tasteDict["sweet"])
	$Control/StatB.text = str(tasteDict["salty"])
	$Control/StatC.text = str(tasteDict["sour"])
	$Control/StatD.text = str(tasteDict["umami"])
	$Cost.text = str(cost)
	
	var verbose_str: String = ""
	if tasteDict["sweet"] > 0:
		verbose_str = verbose_str + str(tasteDict["sweet"]) + "x sweet\n" 
	if tasteDict["salty"] > 0:
		verbose_str = verbose_str + str(tasteDict["salty"]) + "x salty\n" 
	if tasteDict["sour"] > 0:
		verbose_str = verbose_str + str(tasteDict["sour"]) + "x sour\n" 
	if tasteDict["umami"] > 0:
		verbose_str = verbose_str + str(tasteDict["umami"]) + "x umami\n" 
	$Control/Verbose.text = verbose_str

func focus_on() -> void:
	# transform the card so it's easier to read
	# larger, more centered, in front of hand
	if current_state != State.HELD:
		return
	
	# interrupt settling from unfocus
	if tween_t:
		tween_t.kill()
		self.transform = neutral_transform

	# 1 frame transform
	self.scale = Vector2(2.0, 2.0) # todo: const all these
	# self.position = self.position + Vector2(0,-135) # -50
	self.global_position = Vector2(self.global_position.x, 876)
	self.rotation = 0.0
	self.z_index = 99

	# Error happens when parent is already discard but still trying to focus
	# (self.get_parent() as Hand).set_hand_focus(self)
	var parent = self.get_parent()
	if parent is Hand:
		parent.set_hand_focus(self)
		current_state = State.FOCUS

func unfocus() -> void:
	# return card to neutral state in hand
	if current_state != State.FOCUS:
		return

	# ease back
	tween_t = get_tree().create_tween()
	tween_t.tween_property(self, "transform", neutral_transform, 0.3)
	self.z_index = neutral_z_idx
	current_state = State.HELD

func set_neutral_transform(transform_n: Transform2D, zidx: int) -> void:
	# set the base transform for the card when it is held in hand
	# focusing on a card will deviate from this neutral state,
	# then losing focus will ease back to this base
	if current_state == State.TAPPED:
		return

	self.neutral_transform = transform_n
	self.neutral_transform = Transform2D(transform_n.get_rotation(), Vector2(1.5,1.5), 0, transform_n.get_origin())
	self.neutral_z_idx = zidx

	tween_t = get_tree().create_tween()
	tween_t.tween_property(self, "transform", neutral_transform, 0.3)
	self.z_index = zidx

	current_state = State.HELD

func tap() -> void:
	# Select the card for play
	# Play animations and update states
	if current_state != State.FOCUS:
		return
	if not GameManager.can_play_card():
		return
	current_state = State.TAPPED

	# Flourish / appply to recipe animation
	# TODO: real animation / feedback
	AudioManager.play_random_tap_sound()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", self.position + Vector2(0,-400), 0.1)
	await tween.finished
	await get_tree().create_timer(0.5).timeout

	# At this signal the card has been "played", but manager has to apply points then discard it
	SignalBus.card_tapped.emit(self)

func _on_mouse_entered() -> void:
	if current_state == State.HELD:
		self.focus_on()

func _on_mouse_exited() -> void:
	if current_state == State.FOCUS:
		self.unfocus()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass
	if current_state == State.FOCUS:
		if Input.is_action_just_pressed("play_card"):
			#print("Playing card!")
			self.tap()
		if Input.is_action_just_pressed("reroll_card"):
			#print("Discarding card!")
			if not GameManager.can_play_card():
				return
			current_state = State.PILE
			# SignalBus.discard.emit(self)
			SignalBus.reroll.emit(self)
