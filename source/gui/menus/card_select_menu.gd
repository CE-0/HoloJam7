class_name CardSelectMenu 
extends Control 

@onready var new_choices_grid = $"Card Choices"

var number_selected = 0 
var new_cards = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_cards = new_choices_grid.get_children() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

#Updates the display of the current deck
func update_current_deck():
	pass

func on_confirm():
	if (number_selected > 3):
		print("Choose only three cards, please")
		return 
	else: 
		self.hide()
		GameManager.day_machine.on_card_selection_confirmed()
