extends Node2D

@export_category("nodes")
@export var anim : AnimationPlayer
const LOGO = preload("uid://c40kfcmql7n5y")

func _ready() -> void:
	await anim.animation_finished
	get_tree().change_scene_to_packed(LOGO)
