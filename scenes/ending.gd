extends Control

@onready var you_win_title: Sprite2D = $"You Win Title"
@onready var ending_sprite: Sprite2D = $EndingControls/EndingSprite
@onready var bgm: AudioStreamPlayer = $BGM

func _ready() -> void:
	if not OS.has_feature("editor"):
		if Global.ending > 0 and Global.ending_audio != null and Global.ending_sprite != null and Global.ending_title != null:
			print("Setting up for ending "+str(Global.ending))
			you_win_title.texture = Global.ending_title
			ending_sprite.texture = Global.ending_sprite
			bgm.stream = Global.ending_audio
			bgm.play()
		else:
			push_error("Not initalized ending! This probably is en error!")
			get_tree().change_scene_to_file("res://scenes/lang_selection.tscn")
	else:
		print("Running in editor, proceeding with default ending.")
		bgm.play()

func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		print("Key got pressed!")
		Global.return_from_ending = true
		bgm.stream_paused = true
		Global.ending_audio = bgm.stream
		Global.audio_seek = bgm.get_playback_position()
		get_tree().change_scene_to_file("res://scenes/lang_selection.tscn")

func _on_bgm_finished() -> void:
	bgm.play()
