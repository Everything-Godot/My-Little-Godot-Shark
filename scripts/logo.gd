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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation_player.animation_finished.connect(Callable(self, "rotation_finished"))
	await animation_player.animation_finished
	audio_stream_player.stream = Logo_Voice[randi_range(0, 4)]
	audio_stream_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func rotation_finished(_anim_name: StringName) -> void:
	rotation_player.play("logo_rotation")
