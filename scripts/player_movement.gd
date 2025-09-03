extends CharacterBody3D

const SPEED = 100.0
const CROUCH_MOD = 0.5
const SPRINT_MOD = 2
const JUMP_VELOCITY = 50
const CAMERA_SENS = 0.003
const GRAVITY = 100

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * CAMERA_SENS
		rotation.x -= event.relative.y * CAMERA_SENS
		rotation.x = clamp(rotation.x, -1, 1.2)

func _physics_process(delta):
	# Player movement script
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var crouching = Input.is_action_pressed("crouch")
	var sprinting = Input.is_action_pressed("run")
	var modifier
	
	if crouching:
		modifier = CROUCH_MOD
	elif sprinting:
		modifier = SPRINT_MOD
	else:
		modifier = 1
	
	if direction:
		velocity.x = direction.x * SPEED * modifier
		velocity.z = direction.z * SPEED * modifier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * modifier)
		velocity.z = move_toward(velocity.z, 0, SPEED * modifier)
	
	move_and_slide()
	
	# Raycast for object interaction script
	
	# Collision Mask layer 8 for interactive items
	var player_raycast = %PlayerRaycast
	var interact_text = $UI/InteractText
	
	# Hide the text initially
	interact_text.hide()
	
	# Check if the player raycasts collides with something
	if player_raycast.is_colliding():
		# If yes, we get the collider
		var target = player_raycast.get_collider()
		
		# and check if we can interact with it
		if target and target.has_method("interact"):
			interact_text.show()
			
			# Checking if the player pressed the interact key
			if Input.is_action_just_pressed("interact"):
				target.interact()
