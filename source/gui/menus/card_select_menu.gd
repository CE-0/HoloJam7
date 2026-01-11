class_name CardSelectMenu 
extends Control 

const MAX_SELECT_COUNT: int = 3

@onready var new_choices_grid = %"Card Choices"

var card_option = preload("res://source/gui/card_option.tscn") 
var number_selected = 0 
var new_cards = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	GameManager.card_select_menu = self
	$"Control/Add Label".text = "Pick %d cards" % MAX_SELECT_COUNT
	#new_cards = new_choices_grid.get_children()
	new_cards = [1,2,3,4,11] # debug
	update_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(get_selected()) > MAX_SELECT_COUNT:
		%Confirm.modulate = Color("5d5d5d")
	else:
		%Confirm.modulate = Color.WHITE

func get_selected(): 
	var cards_picked = [] 
	for c in new_choices_grid.get_children():
		if (c.checked()):
			cards_picked.push_back(c)
	return cards_picked

#Updates the display of the current deck
func update_current_deck():
	pass

func update_grid():
	# mostly reusing logic from card_discard_menu
	
	# clear grid
	for child in new_choices_grid.get_children():
		new_choices_grid.remove_child(child)
		child.queue_free()
	
	# fill grid with options
	for x in new_cards:
		var card = card_option.instantiate() 
		new_choices_grid.add_child(card)
		card.deck_idx = x 
		card.get_child(0, true).setup_from_card_num(x)
		card.get_child(0, true).set_count(-1)

func on_confirm(): 
	var picks = get_selected()
	var num = len(picks)
	if (num > MAX_SELECT_COUNT):
		print("Choose only three cards, please")
		return 
	else:
		AudioManager.play("UISelectA")
		for p in picks:
			Global.deck.push_back(p.card_img.card_num) 
			Global.save_data()
		self.hide()
		# GameManager.day_machine.on_card_selection_confirmed()
		GameManager.continue_card_selection()
