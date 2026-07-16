extends RigidBody2D

@export var drag_test: bool = false

# References
@onready var area: Area2D = $Area2D

# Drag state
var allow_drag: bool
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_gravity_scale: float = 0.0

func _ready() -> void:
	original_gravity_scale = gravity_scale
	
	# Make sure Area2D can receive input
	area.input_pickable = true
	
	# Connect Area2D signals
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_area_input_event)
	
	if drag_test:
		Global.print_info("Drag test enabled", self)
		allow_drag = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Safety check: if mouse is released but we're still dragging
		if not event.is_pressed() and dragging:
			# Force stop dragging
			stop_drag()
			get_viewport().set_input_as_handled()

# Area2D input event - THIS IS THE KEY
func _on_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and allow_drag and not dragging:
			start_drag(event.global_position)
			get_viewport().set_input_as_handled()  # CRITICAL: Prevents multiple grabs
		
		elif event.is_released() and dragging:
			stop_drag()
			get_viewport().set_input_as_handled()  # CRITICAL: Prevents multiple grabs

func start_drag(mouse_position: Vector2) -> void:
	dragging = true
	drag_offset = global_position - mouse_position
	
	# Freeze physics while dragging (prevents unwanted collisions)
	#freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Visual feedback
	z_index = 10
	modulate = Color(1.2, 1.2, 1.2)
	
	# Tell parent to disable other apples
	#if get_parent().has_method("set_other_dragable_off"):
	#	get_parent().set_other_dragable_off(area)

func stop_drag() -> void:
	dragging = false
	drag_offset = Vector2.ZERO
	
	# Unfreeze physics
	#freeze = false
	gravity_scale = original_gravity_scale
	
	# Small bounce effect when releasing
	if linear_velocity.y > -16.4 and linear_velocity.y <= 0:
		linear_velocity.y = 10
	
	# Reset visual
	z_index = 0
	modulate = Color(1, 1, 1)
	
	# Tell parent to re-enable other apples
	#if get_parent().has_method("set_other_dragable_on"):
	#	get_parent().set_other_dragable_on(area)

func _process(_delta: float) -> void:
	allow_drag = get_parent().allow_drag

func _physics_process(delta: float) -> void:
	if dragging:
		# VELOCITY-BASED MOVEMENT (maintains physics/collisions)
		var target_position = get_global_mouse_position() + drag_offset
		var current_position = global_position
		var velocity_needed = (target_position - current_position) / delta
		
		# Apply velocity (works with physics even when frozen)
		linear_velocity = velocity_needed
		
		# Optional: Limit max speed to prevent teleporting
		var max_speed = 2000.0
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed

func _on_mouse_entered() -> void:
	if not drag_test:
		allow_drag = true
		# Optional: Hover effect
		modulate = Color(1.1, 1.1, 1.1)

func _on_mouse_exited() -> void:
	if not drag_test:
		allow_drag = false
		if not dragging:
			modulate = Color(1, 1, 1)
