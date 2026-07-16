extends Control
class_name IconManager

@export var test: bool = false
@onready var apple: TextureButton = $Apple
@onready var dumbbell: TextureButton = $Dumbbell
@onready var sleep: TextureButton = $Sleep
@onready var light: TextureButton = $Light
@onready var trash_can: TextureButton = $TrashCan
@onready var outside: TextureButton = $Outside
@onready var hand: Sprite2D = $"../Hand"
@onready var anim: AnimationPlayer = $"../AnimationPlayer"

const APPLE = preload("uid://cxgemclosvfdy")

var dragable_list: Array[Area2D] = []
var allow_drag: bool = true
var currently_dragging: Area2D = null
var random: bool = false
var tween: Tween

# Not using, just for refrence
enum IconList {
	苹果 = 0,
	哑铃 = 1,
	灯泡 = 2,
	睡觉 = 3,
	垃圾桶 = 4,
	出门 = 5
}

var icon_list: Array

func _ready() -> void:
	icon_list = [
		apple,
		dumbbell,
		sleep,
		light,
		trash_can,
		outside
	]
	apple.visible = false
	dumbbell.visible = false
	sleep.visible = false
	light.visible = false
	trash_can.visible = false
	outside.visible = false
	hand.visible = false
	activate_icon(0)
	if test:
		keep_random_force_to_all_dragable()
	Console.add_command("activate_icon", activate_icon, ["icon"], true, "Activate specific icon.")
	var icon_list_param:PackedStringArray = [
		0, 1, 2, 3, 4, 5
	]
	Console.add_command_autocomplete_list("activate_icon", icon_list_param)
	Console.add_command("clean_all_dragable", clean_all_dragable, [], false, "Clean all dragable items.")
	Console.add_command("random_force_to_all_dragable", keep_random_force_to_all_dragable, [], false, "Add random force to all dragable items.")
	for icon in icon_list:
		var tweena = get_tree().create_tween().bind_node(icon).set_trans(Tween.TRANS_LINEAR)
		tweena.tween_property(icon, "scale", Vector2(7.15, 7.15), 1)
		tweena.tween_property(icon, "scale", Vector2(7, 7), 1)
		tweena.set_loops()

func activate_icon(icon: Variant) -> void:
	match icon:
		"0":
			Global.print_info("Activating apple icon.", self)
			apple.visible = true
		"1":
			Global.print_info("Activating dumbbell icon.", self)
			dumbbell.visible = true
		"2":
			Global.print_info("Activating sleep icon.", self)
			sleep.visible = true
		"3":
			Global.print_info("Activating light icon.", self)
			light.visible = true
		"4":
			Global.print_info("Activating trash can icon.", self)
			trash_can.visible = true
		"5":
			Global.print_info("Activating outside icon.", self)
			outside.visible = true
		0:
			Global.print_info("Activating apple icon.", self)
			apple.visible = true
		1:
			Global.print_info("Activating dumbbell icon.", self)
			dumbbell.visible = true
		2:
			Global.print_info("Activating sleep icon.", self)
			sleep.visible = true
		3:
			Global.print_info("Activating light icon.", self)
			light.visible = true
		4:
			Global.print_info("Activating trash can icon.", self)
			trash_can.visible = true
		5:
			Global.print_info("Activating outside icon.", self)
			outside.visible = true

func _on_apple_pressed() -> void:
	if hand.visible:
		hand.visible = false
		tween.kill()
		tween = null
		anim.play("want apple")
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
	if len(dragable_list) <= 0:
		Global.print_warning("Dragable list is empty, reset to false.", self)
		random = false
	Global.print_info("Status: " + str(random), self)
	while random and len(dragable_list) > 0:
		random_force_to_all_dragable()
		await get_tree().create_timer(0.65).timeout
	if len(dragable_list) <= 0 and random:
		Global.print_warning("Dragable list is empty, reset to false.", self)
		random = false

func clean_all_dragable() -> void:
	var result: int = 0
	for child in get_children():
		if child != apple and child != dumbbell and child != sleep and child != light and child != trash_can and child != outside:
			child.queue_free()
			Global.print_info(child.name + " removed!", self)
			result += 1
	Global.print_info("Total of " + str(result) + " dragables removed! Clean dragable list.", self)
	dragable_list.clear()

func start_hand_moving() -> void:
	hand.visible = true
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(hand, "position", Vector2(118, 505), 0.3)
	tween.tween_property(hand, "position", Vector2(118, 535), 0.3)
	tween.tween_property(hand, "position", Vector2(118, 565), 0.3)
	tween.tween_property(hand, "position", Vector2(118, 535), 0.3)
	tween.set_loops()
