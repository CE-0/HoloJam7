extends Node 

var default_save = "res://source/data/savedata.json" 
var save_path = "user://hcmsavedata.json"

var game_data : Dictionary
var music_vol : float
var sfx_vol : float 

var deck : Array[int]

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	game_data = load_file()
	music_vol = game_data["volume_settings"]["music"] 
	sfx_vol = game_data["volume_settings"]["sfx"] 
	deck = game_data["player_data"]["deck"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
