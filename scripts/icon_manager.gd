extends Control
class_name IconManager

@onready var apple: TextureButton = $Apple

const APPLE = preload("uid://cxgemclosvfdy")

var dragable_list: Array[Area2D] = []  # Now using Area2D
var currently_dragging: Area2D = null
var random: bool = false

# Not using, just for refrence
enum IconList {
	苹果 = 0,
	哑铃 = 1,
	灯泡 = 2,
	睡觉 = 3,
	垃圾桶 = 4,
	出门 = 5
}

func _ready() -> void:
	Console.add_command("activate_icon", activate_icon, ["icon"], true, "Activate specific icon.")
	var icon_list_param := [
		0, 1, 2, 3, 4, 5
	]
	Console.add_command_autocomplete_list("activate_icon", icon_list_param)
	Console.add_command("clean_all_dragable", clean_all_dragable, [], false, "Clean all dragable items.")
	Console.add_command("random_force_to_all_dragable", keep_random_force_to_all_dragable, [], false, "Add random force to all dragable items.")
	activate_icon(0)
	keep_random_force_to_all_dragable()

func activate_icon(icon: int) -> void:
	match icon:
		0:
			Global.print_info("Activating apple icon.", self)
			apple.visible = true

func _on_apple_pressed() -> void:
	var APPLE_ : RigidBody2D = APPLE.instantiate()
	APPLE_.name = "APPLE_" + str(len(dragable_list) + 1)
	Global.print_info("Spawning new apple with name " + APPLE_.name, self)
	dragable_list.append(APPLE_.get_child(1))
	add_child(APPLE_)

func set_other_dragable_off(where: Area2D) -> void:
	currently_dragging = where
	for apples in dragable_list:
		if apples and is_instance_valid(apples) and apples != where:
			# Disable input for other apples
			apples.set_process_input(false)
			apples.input_pickable = false
			# Optional: Visual feedback that they're disabled
			apples.modulate = Color(0.5, 0.5, 0.5)

func set_other_dragable_on(where: Area2D) -> void:
	currently_dragging = null
	for apples in dragable_list:
		if apples and is_instance_valid(apples) and apples != where:
			# Re-enable input for other apples
			apples.set_process_input(true)
			apples.input_pickable = true
			apples.modulate = Color(1, 1, 1)

func random_force_to_all_dragable() -> void:
	for child in get_children():
		if child != apple and child is RigidBody2D:
			var vx: float = randf_range(-500, 500)
			var vy: float = randf_range(-500, -50)
			var velocity = Vector2(vx, vy)
			child.linear_velocity = velocity

func keep_random_force_to_all_dragable() -> void:
	random = !random
	Global.print_info("Status: " + str(random), self)
	while random:
		random_force_to_all_dragable()
		await get_tree().create_timer(0.65).timeout

func clean_all_dragable() -> void:
	var result: int = 0
	for child in get_children():
		if child != apple:
			child.queue_free()
			Global.print_info(child.name + " removed!", self)
			result += 1
	Global.print_info("Total of " + str(result) + " dragables removed! Clean dragable list.", self)
	dragable_list.clear()
