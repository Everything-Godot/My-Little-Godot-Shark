extends Node

var force_command: bool = false
var ending: int = 0
var ending_sprite: AtlasTexture = null
var ending_title: AtlasTexture = null
var ending_audio: AudioStreamMP3 = null
var return_from_ending: bool = false
var audio_seek: float = 0.0

func force_play(end: String) -> void:
	force_command = true
	Console.print_info("Try to play ending "+str(end))
	ending = int(end)
	match ending:
		11:
			ending_sprite = load("res://textures/endings/11/logo.tres")
			ending_title = load("res://textures/endings/11/title.tres")
			ending_audio = load("res://media/普通结局BGM.mp3")
			get_tree().change_scene_to_file("res://scenes/ending.tscn")
		_:
			Console.print_warning("Ending "+str(ending)+" not found!")

func play_ending(end: int) -> void:
	ending = end
	match ending:
		11:
			ending_sprite = load("res://textures/endings/11/logo.tres")
			ending_title = load("res://textures/endings/11/title.tres")
			ending_audio = load("res://media/普通结局BGM.mp3")
			get_tree().change_scene_to_file("res://scenes/ending.tscn")
		_:
			push_warning("Ending "+str(ending)+" not found!")
