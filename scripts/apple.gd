extends RigidBody2D

@export var drag_test: bool = false
var allow_drag: bool = false
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if drag_test:
		Global.print_info("Drag test enabled, won't check if mouse is in apple position", self)
		allow_drag = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if allow_drag and event.is_pressed():
			Global.print_info("Drag the apple", self)
			dragging = true
			drag_offset = global_position - event.global_position
		if allow_drag and event.is_released():
			Global.print_info("Stop drag", self)
			dragging = false
			drag_offset = Vector2.ZERO
			if linear_velocity.y > -16.4 and linear_velocity.y <= 0:
				linear_velocity.y = 10

func _physics_process(delta):
	if dragging:
		var target_position = get_global_mouse_position() + drag_offset
		var current_position = global_position
		var velocity_needed = (target_position - current_position) / delta
		linear_velocity = velocity_needed

func _on_mouse_entered() -> void:
	if not drag_test:
		Global.print_info("Mouse entered", self)
		allow_drag = true

func _on_mouse_exited() -> void:
	if not drag_test:
		Global.print_info("Mouse exited", self)
		allow_drag = false
