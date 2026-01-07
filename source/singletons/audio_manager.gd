extends Node

# Autoload singelton that plays the music and sound effects of the game

var current_ost: NodePath

func _ready() -> void:
	#print("audio ready")
	#start ost
	pass
	#for child in get_children():
		#print("playing ", child.name)
		#child.play()
		#await child.finished

func _process(_delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("debug_0"):
		#play("TestBeep")

func soundtrack_start() -> void:
	# logic here to pick between songs?
	pass

func soundtrack_stop() -> void:
	pass
	stop(current_ost)

func play(sound: NodePath):
	# sound is the name of the node of the sound to play
	# sound is case sensitive
	var sound_node = get_node_or_null(sound)
	assert(sound_node != null, str("Sound ", sound, " does not exist"))
	sound_node.play()

func stop(sound: NodePath):
	var sound_node = get_node_or_null(sound)
	assert(sound_node != null, str("Sound ", sound, " does not exist"))
	sound_node.stop()

func play_random_tap_sound() -> void:
	var options: Array[String] = ["Sizzle", "Chop"]
	options.shuffle()
	play(options[0])
