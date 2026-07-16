extends Control

@onready var you_win_title: Sprite2D = $"You Win Title"
@onready var ending_sprite: Sprite2D = $EndingControls/EndingSprite
@onready var bgm: AudioStreamPlayer = $BGM

var ready_yet := false

func _ready() -> void:
	if not OS.has_feature("editor") or Global.ending > 0:
		if Global.ending_audio != null and Global.ending_sprite != null and Global.ending_title != null:
			Global.print_info("Setting up for ending " + str(Global.ending), self)
			you_win_title.texture = Global.ending_title
			ending_sprite.texture = Global.ending_sprite
			bgm.stream = Global.ending_audio
			bgm.play()
			await get_tree().create_timer(1).timeout
		else:
			Global.print_error("Not initalized ending! This probably is en error!", self)
			get_tree().change_scene_to_file("res://scenes/lang_selection.tscn")
	elif Global.ending == 0 and not OS.has_feature("editor"):
		Global.print_error("Not initalized ending! This probably is en error!", self)
		get_tree().change_scene_to_file("res://scenes/lang_selection.tscn")
	else:
		Global.print_info("Running in editor, proceeding with default ending.", self)
		await get_tree().create_timer(1).timeout
		bgm.play()
	if Global.force_command:
		Global.print_info("Since you got force to ending, so we need to disable the key listener for about 3 seconds in order to show the ending correctly.", self)
		await get_tree().create_timer(3).timeout
		Global.force_command = false
	ready_yet = true

func _input(event: InputEvent) -> void:
	if not Global.force_command and ready_yet:
		if event.is_pressed():
			Global.print_info("Some key got pressed!", self)
			Global.return_from_ending = true
			bgm.stream_paused = true
			Global.ending_audio = bgm.stream
			Global.audio_seek = bgm.get_playback_position()
			Global.get_to_scene("res://scenes/lang_selection.tscn")

func _on_bgm_finished() -> void:
	bgm.play()
