extends Node2D

@export_category("nodes")
@export var anim : AnimationPlayer

func _ready() -> void:
	anim.play("warning")
