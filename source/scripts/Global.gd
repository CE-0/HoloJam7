extends Node 

var save_path = "res://source/data/savedata.json"

var music_vol : float
var sfx_vol : float

func load_data(filePath : String):
	if not FileAccess.file_exists(filePath):
		# raise error
		return

	var dataFile = FileAccess.open(filePath, FileAccess.READ)
	var parsed = JSON.parse_string(dataFile.get_as_text()) 
	return parsed

func save_data():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_vol = load_data(save_path)["volume_settings"]["music"] 
	sfx_vol = load_data(save_path)["volume_settings"]["sfx"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
