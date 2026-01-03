class_name Hand
extends Node2D

# Selection of cards available for use by the player
# Arranges the cards for easy viewing and selection by player

const HAND_WIDTH: float = 500.0

var held_cards: Array[Card] = []
var focused_card: Card = null

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func add_card(new_card: Card) -> void:
	if new_card == null:
		return

	held_cards.append(new_card) # need to come up with a sorting method later
	#held_cards.insert(randi_range(0,held_cards.size()), new_card)
	new_card.reparent(self)
	new_card.current_state = Card.State.HELD # This shouldn't be here
	arrange_cards()

func take_card(card: Card) -> bool:
	# take card from hand
	var idx = held_cards.find(card)
	if idx == -1: 
		return false
	
	held_cards.pop_at(idx)
	arrange_cards()
	return true

func set_hand_focus(card: Card) -> void:
	# focus on new given card and release focus from previous
	if focused_card:
		focused_card.z_index = held_cards.find(focused_card) + 50
		focused_card.unfocus()
	card.z_index = 99
	focused_card = card

func arrange_cards() -> void:
	# determine where cards are held in hand / on screen
	var num: int = held_cards.size()
	if num == 0:
		return

	for i in range(0, num):
		# set card transform in hand
		# this function can be made into a more human curve later
		var card_x: float = (i+1)*HAND_WIDTH/(num+1) - HAND_WIDTH/2

		# save and apply transform, z index
		held_cards[i].set_neutral_transform(Transform2D(0, Vector2(card_x,0)), 50 + i)
