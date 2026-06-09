extends Node2D

@export_category("nodes")
@export var anim : AnimationPlayer
const LOGO = preload("uid://c40kfcmql7n5y")

func _ready() -> void:
	Console.add_command("force_end", Global.force_play, ["ending number"], 1, "Play corrsponding ending with number you given.")
	var endings: PackedStringArray = ["11"]
	Console.add_command_autocomplete_list("force_end", endings)
	await anim.animation_finished
	get_tree().change_scene_to_packed(LOGO)
