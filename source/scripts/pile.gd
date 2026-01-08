class_name Pile
extends Node2D

# Generic class for a pile, a group of cards
# Used for draw pile and discard pile

# Index 0 is bottom of pile, index size()-1 is top of pile
var cards: Array[Card] = []

@onready var label: Label = $Label # how many cards are in the pile

func _ready() -> void:
	pass
	update_count()

func size() -> int:
	return cards.size()

func add_card(card: Card) -> void:
	# This method is for adding cards to the pile under the hood,
	# During initial setup or reshuffling
	# The card is not in the tree or visible to the player
	cards.push_back(card)
	update_count()

func add_cards(pile: Array[Card]) -> void:
	for card in pile:
		card.reparent(self)
		cards.push_back(card)
	update_count()

func remove_all_cards() -> Array[Card]:
	# pop everything, usually to empty this or move cards to another pile
	var last: Array[Card] = []
	while cards.size() > 0:
		last.append(cards.pop_back())
	update_count()
	return last

func place_card(card: Card) -> void:
	# This method is for placing cards from the board or hand into the pile
	# Including handling the visible movement

	card.reparent(self)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "transform", Transform2D(PI, Vector2(0.1,0.1), 0, Vector2.ZERO), 0.4)
	await get_tree().create_timer(0.35).timeout
	card.hide()

	cards.push_back(card)
	card.current_state = card.State.PILE # replace
	update_count()

func draw_from() -> Card:
	if cards.size() <= 0:
		push_warning("Tried to draw a card from empty pile ", self.name)
		return null

	var last: Card = cards.pop_back()
	if last.get_parent():
		last.get_parent().remove_child(last)
	add_child(last)

	# replace with animated draw
	last.position = Vector2.ZERO
	last.scale = Vector2(0.2, 0.2)
	last.rotation = -1.5*PI # I want the card to spin more but godot simplifies the rots past 360
	last.show()

	update_count()
	return last

func shuffle() -> void:
	# There's a really 
	cards.shuffle()
	
	# This animation has 0 to do with the players ability to draw from the pile
	# TODO: play sound
	$CardBack.rotation = PI
	$CardBack2.rotation = -PI
	$CardBack3.rotation = 0
	
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property($CardBack, "rotation", 0, 0.3)
	tween2.tween_property($CardBack2, "rotation", 0, 0.3)
	tween3.tween_property($CardBack3, "rotation", PI, 0.3)

func set_card_backs_visible(value: bool) -> void:
	$CardBack.visible = value
	$CardBack2.visible = value
	$CardBack3.visible = value

func update_count() -> void:
	var count: int = cards.size()
	label.text = str(count)
	if count == 0:
		# standin for 
		#await get_tree().process_frame
		set_card_backs_visible(false)
		SignalBus.pile_empty.emit(self)
	else:
		set_card_backs_visible(true)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# View the piles in the pack_viewer
	if Input.is_action_just_pressed("view_pile"):
		SignalBus.view_pack.emit(cards)
