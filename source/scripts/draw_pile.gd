class_name DrawPile
extends Node2D

# Potentially make this just a generic Pile class

# Holds the cards yet to be drawn in game
# Typically a subsection of all of the possible cards in the Deck
#
# Instead of every card being in the tree at all times,
# should hold bare representations of cards
# Then instance the Card proper when drawn

# Index 0 is bottom of deck, index size()-1 is top of deck
var cards: Array[Card] = []

@onready var label: Label = $Label # how many cards are in the pile

func _ready() -> void:
	pass
	update_count()

func add_card(card: Card) -> void:
	# For now, cards are only added to the deck during initial setup and
	# reshuffling discard pile
	cards.push_back(card)
	update_count()

func add_cards(pile: Array[Card]) -> void:
	pass

func draw_card() -> Card:
	if cards.size() <= 0:
		push_warning("Tried to draw a card from empty pile ", self.name)
		return

	var last: Card = cards.pop_back()
	add_child(last)

	# replace with animated draw
	last.position = Vector2.ZERO
	last.scale = Vector2(0.2, 0.2)
	last.rotation = -1.5*PI # I want the card to spin more but godot simplifies the rots past 360

	update_count()
	return last

func shuffle() -> void:
	cards.shuffle()

func update_count() -> void:
	label.text = str(cards.size())
