extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rotation_player: AnimationPlayer = $RotationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const Logo_Voice = [
	preload("uid://cf13bhib85q7u"),
	preload("uid://yiktgdp1806n"),
	preload("uid://rrmhat5c1ast"),
	preload("uid://brh4g1u1ylpd4"),
	preload("uid://ct58gwtfxoong")
]
const ding_dong = preload("uid://dtgjlrl64koaq")

func _ready() -> void:
	rotation_player.animation_finished.connect(Callable(self, "rotation_finished"))
	await animation_player.animation_finished
	audio_stream_player.stream = Logo_Voice[randi_range(0, 4)]
	audio_stream_player.play()
	await audio_stream_player.finished
	await get_tree().create_timer(1).timeout
	audio_stream_player.stream = ding_dong
	audio_stream_player.play()
	await audio_stream_player.finished
	get_tree().change_scene_to_file("res://scenes/lang_selection.tscn")

func rotation_finished(_anim_name: StringName) -> void:
	rotation_player.play("logo_rotation")
