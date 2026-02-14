extends Node2D

@export_category("nodes")
@export var anim : AnimationPlayer

func _ready() -> void:
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/logo.tscn")
