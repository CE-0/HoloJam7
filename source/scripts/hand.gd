class_name Hand
extends Node2D

# Selection of cards available for use by the player
# Arranges the cards for easy viewing and selection by player

const HAND_WIDTH: float = 750

var held_cards: Array[Card] = []
var focused_card: Card = null
var focused_index: int = -1

var mutex: Mutex = Mutex.new()

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func get_cards_count() -> int:
	return held_cards.size()

func add_card(new_card: Card) -> void:
	if new_card == null:
		return
	if held_cards.size() >= GameManager.MAX_CARDS_PER_HAND:
		push_error("Adding card to full hand")

	held_cards.append(new_card) # need to come up with a sorting method later
	#held_cards.insert(randi_range(0,held_cards.size()), new_card)
	new_card.reparent(self)
	arrange_cards()

func take_card(card: Card) -> bool:
	# take card from hand
	mutex.lock()
	var idx = held_cards.find(card)
	if idx == -1: 
		return false
	
	held_cards.pop_at(idx)
	mutex.unlock()
	arrange_cards()
	return true

func set_hand_focus(card: Card) -> void:
	# focus on new given card and release focus from previous
	# when this is called, the hovered card already did its focus actions
	# this method updates the hands knowledge of this and unfocuses the old one

	var next_idx = held_cards.find(card)
	# If this is the first card being focused, not a lot to do
	if focused_card:
		focused_card.z_index = focused_index + 50
		focused_card.unfocus()
		if next_idx < focused_index:
			AudioManager.play("CardSelectA")
		else:
			AudioManager.play("CardSelectB")
	else:
		AudioManager.play("CardSelectA")
	focused_card = card
	focused_index = next_idx

func arrange_cards() -> void:
	# determine where cards are held in hand / on screen
	var num: int = held_cards.size()
	if num == 0:
		return
	for i in range(0, num):
		# set card transform in hand
		# this function can be made into a more human curve later
		var card_x: float = (i+1)*HAND_WIDTH/(num+1) - HAND_WIDTH/2
		var card_y: float = (card_x/40.0)*(card_x/40.0)
		var rot: float = ((i+1)*1.0/(num+1)-0.5)*PI/4

		# save and apply transform, z index
		held_cards[i].set_neutral_transform(Transform2D(rot, Vector2(card_x,card_y)), 50 + i)
