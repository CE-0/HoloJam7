class_name CardDiscardMenu
extends Control 

const MAX_REMOVE_COUNT: int = 3

@onready var deck_grid = $"Control/ScrollContainer/Deck Grid"

var card_option = preload("res://source/gui/card_option.tscn") 
var can_continue: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_grid()
	GameManager.card_discard_menu = self 
	%SubHeader.text = "Select up to %d cards to remove" % MAX_REMOVE_COUNT

func _process(delta: float) -> void:
	if get_selected_count() > MAX_REMOVE_COUNT:
		can_continue = false
		$Control/Next.modulate = Color("5d5d5d")
	else:
		can_continue = true
		$Control/Next.modulate = Color.WHITE

func update_grid(): 
	if (deck_grid.get_child_count() > 0):
		clear_children(deck_grid) 

	for x in range(0, len(Global.deck)):
		var card = card_option.instantiate() 
		deck_grid.add_child(card)
		card.deck_idx = x
		card.get_child(0, true).setup_from_card_num(Global.deck[x])
		card.get_child(0, true).set_count(-1)

func clear_children(node):
	if node.get_child_count() <= 0:
		return
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func remove_selection():
	for x in range(0, deck_grid.get_child_count()):
		if (deck_grid.get_child(x).checked()):
			Global.deck[deck_grid.get_child(x).deck_idx] = -44
	Global.deck = Global.deck.filter(is_positive)

func is_positive(i : int):
	return i >= 0

func get_selected_count() -> int:
	var count: int = 0
	for x in range(0, deck_grid.get_child_count()):
		if (deck_grid.get_child(x).checked()):
			count = count +1
	return count

func on_next_pressed():
	if not can_continue:
		return
	AudioManager.play("UISelectA")
	remove_selection() 
	Global.save_data()
	self.hide()
	# GameManager.continue_card_selection()
	GameManager.day_machine.on_card_selection_confirmed()
