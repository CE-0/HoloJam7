class_name CardSelectMenu 
extends Control 

@onready var new_choices_grid = $"Card Choices"
@onready var current_deck_grid = $"Current Deck" 

var new_options = null
var current_deck = null
var number_selected = 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_options = new_choices_grid.get_children() 
	current_deck = current_deck_grid.get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

#Updates the display of the current deck
func update_current_deck():
	pass

func on_confirm():
	if (number_selected != 5):
		print("Choose five cards, please")
		return 
	else: 
		self.hide()
		GameManager.day_machine.on_card_selection_confirmed()
