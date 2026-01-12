extends Node 

#var default_save = "res://source/data/savedata.json"
var default_save = "res://source/data/defaultdata.json"
var save_path = "user://hcmsavedata.json"

var game_data : Dictionary
var music_vol : float
var sfx_vol : float
var window_size: int = 720 # manual default 

var deck = null 

var game_finished = false 
var previous_scene: String = "" # used for some music overrides

#Default data for the game 
var default_deck = [1, 2, 3, 4, 1, 2, 3, 4, 6, 8]

func check_file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)

func load_file():
	if(check_file_exists(save_path)): 
		return load_data(save_path)
	else:
		return load_data(default_save)

func load_data(filePath : String):
	if not FileAccess.file_exists(filePath):
		# raise error
		return

	var dataFile = FileAccess.open(filePath, FileAccess.READ)
	var parsed = JSON.parse_string(dataFile.get_as_text()) 
	return parsed

func save_data():
	game_data["player_data"]["deck"] = deck 
	game_data["volume_settings"]["music"] = music_vol 
	game_data["volume_settings"]["sfx"] = sfx_vol 
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		# Convert your data to JSON string
		var json_string = JSON.stringify(game_data)
		# Write the JSON string to file
		file.store_string(json_string)
		file.close()
	else:
		print("Error: Could not save file to path")
	return 

func db_converter(input, bus): 
	match bus:
		"Music":
			return ((input/100)*10-1)-((100-input)*0.25)
		"SFX":
			return ((input/100)*10-14)-((100-input)*0.25)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Default visuals
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	if screen_size.y < 1080 and window_size != 720:
		set_window_720()

	#game_data = load_data(default_save) # temp until newgame / continue options are added
	game_data = load_file()
	music_vol = game_data["volume_settings"]["music"] 
	sfx_vol = game_data["volume_settings"]["sfx"] 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.db_converter(music_vol, "Music"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.db_converter(sfx_vol, "SFX"))
	deck = default_deck 
	save_data() 
	game_data = load_file() 
	deck = []
	
	for item in game_data["player_data"]["deck"]: # change json floats to ints
		deck.append(int(item))
	deck.sort()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_0"):
		toggle_window_size()

func toggle_window_size() -> void:
	# This only works on desktop pretty sure
	if window_size == 720:
		set_window_1080()
	else:
		set_window_720()

func set_window_1080() -> void:
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	window_size = 1080

func set_window_720() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	window_size = 720
	DisplayServer.window_set_position(Vector2(0,125)) # so the title bar is still visible
