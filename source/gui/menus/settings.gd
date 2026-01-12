extends Control 

@onready var music_slider = $"Music Volume Slider" 
@onready var music_vol_display = $"Music Volume Slider/Volume Display"
@onready var sfx_slider = $"SFX Volume Slider"
@onready var sfx_vol_display = $"SFX Volume Slider/Volume Display" 

var prev_music_vol : float
var prev_sfx_vol : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_slider.value = Global.music_vol 
	sfx_slider.value = Global.sfx_vol 
	prev_music_vol = Global.music_vol
	prev_sfx_vol = Global.sfx_vol
	music_vol_display.text = str(floori(music_slider.value))
	sfx_vol_display.text = str(floori(sfx_slider.value))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func on_music_vol_changed(value : float): 
	Global.music_vol = value
	#Global.game_data["volume_settings"]["music"] = value 
	music_vol_display.text = str(floori(value)) 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.db_converter(value, "Music"))

func on_sfx_vol_changed(value : float): 
	Global.sfx_vol = value
	#Global.game_data["volume_settings"]["music"] = value 
	sfx_vol_display.text = str(floori(value)) 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.db_converter(value, "SFX"))

func save_settings():
	Global.save_data() 
	get_tree().change_scene_to_file("res://source/gui/menus/title_screen.tscn")

func back_to_main(): 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.db_converter(prev_music_vol, "Music"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.db_converter(prev_sfx_vol, "SFX"))
	Global.music_vol = prev_music_vol
	Global.sfx_vol = prev_sfx_vol
	get_tree().change_scene_to_file("res://source/gui/menus/title_screen.tscn")
