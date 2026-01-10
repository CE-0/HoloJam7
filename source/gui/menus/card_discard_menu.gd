class_name CardDiscardMenu
extends Control 

@onready var deck_grid = $"ScrollContainer/Deck Grid" 

var card_option = preload("res://source/gui/card_option.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.card_discard_menu = self
	for x in range(0, len(Global.deck)):
		var card = card_option.instantiate() 
		deck_grid.add_child(card)
		card.deck_idx = x 
		card.card_img.setup_from_card_num(Global.deck[x])

func update_grid(): 
	clear_children(deck_grid) 
	for x in range(0, len(Global.deck)):
		var card = card_option.instantiate() 
		deck_grid.add_child(card)
		card.deck_idx = x 
		card.card_img.setup_from_card_num(Global.deck[x])

func clear_children(node):
	for c in node.get_children():
		c.queue_free()

func remove_selection():
	for x in range(0, deck_grid.get_child_count()):
		if (deck_grid.get_child(x).checked):
			Global.deck[deck_grid.get_child(x).deck_idx] = -44
	Global.deck = Global.deck.filter(is_positive)

func is_positive(i : int):
	return i >= 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_next_pressed(): 
	remove_selection() 
	Global.save_data()
	self.hide()
	GameManager.continue_card_slection()
