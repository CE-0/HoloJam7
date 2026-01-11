class_name PackViewer
extends Control

# The primary function of this class is to be given a set of cards to display for the viewer
# For example, checking the cards still in the draw pile
# But futher, while viewing these cards, secondary interactions can be done in a ui like this
# So this class will enable the following functions:
#
# View the cards currently in draw pile
# View the cards currently in discard pile
# View the daily rewarded cards, and select a subset to add to the main deck
# View the main deck, and remove a subset of cards permanently

# NOTE: Design the layout of this with size set to 1920,1080
# Then change it to 1280,720 for export

@onready var image_scene: Resource = preload("res://source/gui/card_image.tscn")
@onready var grid: GridContainer = %CardGrid

func _ready() -> void:
	self.hide()
	SignalBus.view_pack.connect(_on_view_pack)

func clear_grid() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

func _on_view_pack(description: String, cards: Array[Card]) -> void:
	# TODO: add special note for empty pack
	AudioManager.play("UIHoverC")
	clear_grid()

	%Description.text = description
	%EmptyLabel.visible = (cards.size() == 0)
	
	# First count how many of each card is in the pile
	var count_dict = {}
	for card in cards:
		var num: int = card.get_num()
		if not num in count_dict:
			count_dict[num] = 1
		else:
			count_dict[num] = count_dict[num] + 1

	# Then create the card images needed to represent them
	var images: Array[CardImage] = []
	for item in count_dict:
		var image: CardImage = image_scene.instantiate()
		image.setup_from_card_num(item)
		image.set_count(count_dict[item])
		images.append(image)

	# Sort then add to grid
	#images.sort_custom(sort_by_num)
	images.sort_custom(func(a,b): return a.card_num < b.card_num)
	for image in images:
		grid.add_child(image)
	self.show()

func _on_close_button_pressed() -> void:
	AudioManager.play("UIHoverA")
	self.hide()
