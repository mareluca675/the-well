extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1) var mouseSens := 0.25

@export_group("movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0

@export_group("environment")
@export var gravity := 100

@onready var camera_pivot: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var camera_input_direction := Vector2.ZERO
var last_movement_direction := Vector3.BACK

func _input(event: InputEvent) -> void:
	# focus window on LMB click
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	# show cursor when not focused
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		# mouse is moving
		event is InputEventMouseMotion and 
		# mouse is inside game window
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	if is_camera_motion: 
		# convert mouse movement to camera direction
		camera_input_direction = event.relative * mouseSens
		


func _physics_process(delta: float) -> void:
	camera_pivot.rotation.x += camera_input_direction.y * delta
	# limit vertical camera angle
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	
	camera_pivot.rotation.y -= camera_input_direction.x * delta
	
	# set camera movement to 0 when mouse is not moved
	camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# get axis relative to camera view
	var forward := camera.global_basis.z
	var side := camera.global_basis.x
	
	var move_direction := forward * raw_input.y + side * raw_input.x
	# prevent walking into the sky/ground when camera pointed up/down
	move_direction.y = 0.0
	
	move_direction = move_direction.normalized()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	move_and_slide()

	if move_direction.length() > 0:
		last_movement_direction = move_direction
		
	# smoothly turn player model towards moving direction
	var target_angle := Vector3.BACK.signed_angle_to(last_movement_direction, Vector3.UP)
	global_rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
