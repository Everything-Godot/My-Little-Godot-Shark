extends Node2D

@export_category("nodes")
@export var anim : AnimationPlayer

func _ready() -> void:
	Console.add_command("force_end", Global.force_play, ["ending number"], 1, "Play corrsponding ending with number you given.")
	var endings: PackedStringArray = ["11"]
	Console.add_command_autocomplete_list("force_end", endings)
	await anim.animation_finished
	Global.get_to_scene("res://scenes/logo.tscn")
