class_name CardDiscardMenu
extends Control 

@onready var deck_grid = $"Control/ScrollContainer/Deck Grid"

var card_option = preload("res://source/gui/card_option.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_grid()
	GameManager.card_discard_menu = self 

func update_grid(): 
	if (deck_grid.get_child_count() > 0):
		clear_children(deck_grid) 
	
	for x in range(0, len(Global.deck)):
		var card = card_option.instantiate() 
		card.deck_idx = x 
		card.get_child(0, true).setup_from_card_num(Global.deck[x]) 
		deck_grid.add_child(card)

func clear_children(node):
	if (node.get_child_count() > 0):
		for c in range(node.get_child_count() - 1, -1, -1):
			node.get_child(c).queue_free()
	else: 
		return

func remove_selection():
	for x in range(0, deck_grid.get_child_count()):
		if (deck_grid.get_child(x).checked()):
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
	GameManager.continue_card_selection()
