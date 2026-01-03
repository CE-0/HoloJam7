extends Node

# Big boy tracker of everything that takes place in a day
# Order state machine could be elsewhere, depending

var draw_pile: Pile
var discard_pile: Pile
var hand: Hand

# dev
var score = {
	"a": 0,
	"b": 0,
	"c": 0,
	"d": 0
}


func _ready() -> void:
	SignalBus.discard.connect(_on_discard)
	SignalBus.card_tapped.connect(_on_card_tapped)
	SignalBus.pile_empty.connect(_on_pile_empty)
	SignalBus.serve_pressed.connect(_on_serve_pressed)

func _process(delta: float) -> void:
	pass

func add_values_to_score(tastes: Dictionary) -> void:
	score["a"] = score["a"] + tastes["sweet"]
	score["b"] = score["b"] + tastes["salty"]
	score["c"] = score["c"] + tastes["sour"]
	score["d"] = score["d"] + tastes["umami"]
	print(score)

func score_reset() -> void:
	score["a"] = 0
	score["b"] = 0
	score["c"] = 0
	score["d"] = 0
	print(score)

func _on_discard(card: Card) -> void:
	hand.take_card(card)
	discard_pile.place_card(card)

func _on_card_tapped(card: Card) -> void:
	add_values_to_score(card.get_taste_values())
	hand.take_card(card)
	discard_pile.place_card(card)

func _on_pile_empty(pile: Pile) -> void:
	# If there's very few cards so both packs are empty, it can cause some soft locks
	if pile == draw_pile:
		var pack = discard_pile.remove_all_cards()
		if pack.size() > 0:
			draw_pile.add_cards(pack)

func _on_serve_pressed() -> void:
	# take away order, disable card usage
	# 

	pass
	score_reset()
