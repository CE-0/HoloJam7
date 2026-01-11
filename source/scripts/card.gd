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
@export var special: bool = false

# Bonus power can be an int or an array of two ints or null
# If it's an int, it will apply that constant value to one of the taste profiles
# if its an array, the array defines a range of values to be randomly selected from, then applied
var bonus_power: Variant
# Bonus profile is an array with 1-4 items representing the taste profiles or null
# The rng selected profile will be the target of the bonus power
var bonus_profile: Variant
# Note I said ints but json stores floats so work with that for now

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

@onready var image_generic: Sprite2D = %image_generic
@onready var image_special: Sprite2D = %image_special
@onready var image_food: Sprite2D = %image_food

func _ready() -> void:
	pass
	# setup_from_card_num(card_num)

func _process(_delta: float) -> void:
	pass

func setup_from_card_num(num: int) -> void:
	# Look up the given card number in the cube and setup with that info
	# Info todo: image
	var info = CardCube.get_card_info(num)

	card_num = num
	card_name = info["name"]
	cost = int(info["cost"])
	special = info["special"]
	image_path = info["image"]

	tasteDict["sweet"] = int(info["taste_profile"]["sweet"])
	tasteDict["salty"] = int(info["taste_profile"]["salty"])
	tasteDict["sour"] = int(info["taste_profile"]["sour"])
	tasteDict["umami"] = int(info["taste_profile"]["umami"])

	if info["special"]:
		bonus_power = info["bonus_power"]
		bonus_profile = info["bonus_profile"]
	else:
		bonus_power = null
		bonus_power = null

	update_face()

func get_taste_values() -> Dictionary:
	var last = tasteDict.duplicate_deep()

	# Normal cards are done
	if not special:
		return last

	# Resolve haachama values
	# read or rng the power
	var power = 0
	if bonus_power is Array:
		power = randi_range(bonus_power[0], bonus_power[1])
	else:
		power = bonus_power

	# rng the target (always an array)
	var target = bonus_profile.pick_random()

	# apply bonus
	var idx = ["sweet", "salty", "soul", "umami"][target]
	last[idx] = last[idx] + power
	return last

func get_cost() -> int:
	return cost

func get_num() -> int:
	return card_num

func update_face() -> void:
	# pass all card info to the card ui
	$NameLabel.text = card_name
	$Cost.text = str(cost)

	image_food.texture = load(image_path)
	image_generic.visible = not special
	image_special.visible = special

	# Bonus text
	# not implemented atm
	var bonus_a = ""
	var bonus_b = ""
	var bonus_c = ""
	var bonus_d = ""
	# if special:
	# 	if 0.0 in bonus_profile:
	# 		bonus_a = "+?"
	# 	if 1.0 in bonus_profile:
	# 		bonus_b = "+?"
	# 	if 2.0 in bonus_profile:
	# 		bonus_c = "+?"
	# 	if 3.0 in bonus_profile:
	# 		bonus_d = "+?"

	var verbose_str: String = ""
	if tasteDict["sweet"] > 0:# or (special and 1.0 in bonus_profile):
		verbose_str = verbose_str + "+" + str(tasteDict["sweet"]) + bonus_a + " sweet\n"
	if tasteDict["salty"] > 0:# or (special and 2.0 in bonus_profile):
		verbose_str = verbose_str + "+" + str(tasteDict["salty"]) + bonus_b + " salty\n"
	if tasteDict["sour"] > 0:# or (special and 3.0 in bonus_profile):
		verbose_str = verbose_str + "+" + str(tasteDict["sour"]) + bonus_c + " sour\n"
	if tasteDict["umami"] > 0:# or (special and 4.0 in bonus_profile):
		verbose_str = verbose_str + "+" + str(tasteDict["umami"]) + bonus_d + " umami\n"

	# I'd like to indicate which tastes can get the bonus, but will have to come back to that
	# For now, if the numbers are known, fill them in
	# if not, use ? marks
	# +? to ?
	# +4 to ?
	# +? to sw.
	if special:
		# + num or ?
		verbose_str = verbose_str + "+"
		if bonus_power is Array:
			verbose_str = verbose_str + "?"
		else:
			verbose_str = verbose_str + str(int(bonus_power))
		# + num or ?
		verbose_str = verbose_str + " to "
		if bonus_profile.size() == 1:
			verbose_str = verbose_str + str({0.0: "sw.", 1.0: "sa.", 2.0: "so.", 3.0: "um."}[bonus_profile[0]])
		else:
			verbose_str = verbose_str + "?"

		# trying fuller text
		# might work but its very wide
		# for item in bonus_profile:
		# 	verbose_str = verbose_str + " " + str({0: "sw.", 1: "sa.", 2: "so.", 3: "um."}[int(item)])
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

	var parent = self.get_parent()
	if parent is Hand:
		parent.set_hand_focus(null)

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
	#  Tricky mouse over edge cases
	if current_state != State.FOCUS:
		if not GameManager.hand.has_focused_card():
			if current_state == State.HELD:
				self.focus_on()

	# Click events
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
