extends CharacterBody3D

# ============================ Player code ============================

class_name Player

@export_group("Camera")
@export_range(0.0, 1) var mouseSens := 0.25

@export_group("Movement")
@export var move_speed := 5.0
@export var acceleration := 800.0
@export var jump_power := 12.0
@export var crouch_mod := 0.5
@export var sprint_mod := 2

@export_group("Environment")
@export var gravity := -50.0

@onready var camera_pivot: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

@onready var shape_cast_3d: ShapeCast3D = $Head/Camera3D/ShapeCast3D

var camera_input_direction := Vector2.ZERO
var last_movement_direction := Vector3.BACK

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.set_current(true)
	note_control.hide()
	pause_control.hide()

func _input(event) -> void:
	# Camera motion
	var is_camera_motion := (
		# mouse is moving
		event is InputEventMouseMotion and 
		
		# mouse is inside game window
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	if is_camera_motion: 
		# convert mouse movement to camera direction
		camera_input_direction = event.relative * mouseSens
	
	# Press ESC to toggle mouse capture mode
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			is_paused = true
			show_pause_menu()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			is_paused = false
			pause_control.hide()
		
		if reading_note:
			close_note()
		return	
	
	if reading_note:
		if event is InputEventKey:
			if Input.is_action_just_pressed("interact"):
				close_note()
		return
		
	if is_paused:
		return
		
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact"):
			if shape_cast_3d.is_colliding():
				var collider = shape_cast_3d.get_collider(0)
				if collider.get_parent().has_method("interact"):
					collider.get_parent().interact()
					paper_audio.play()


func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	# Raycast script
	
	if shape_cast_3d.is_colliding():
		if shape_cast_3d.get_collider(0).get_parent().has_method("interact"):
			interact_container.show()
			var collider_thing = shape_cast_3d.get_collider(0).get_parent()
			interact_label.text = collider_thing.use_text
		else:
			if interact_container.visible:
				interact_container.hide()
	elif interact_container.visible:
		interact_container.hide()
	
	if reading_note:
		return
	
	# Player movement script
	
	# rotating the camera
	camera_pivot.rotation.y -= camera_input_direction.x * delta
	camera_pivot.rotation.x -= camera_input_direction.y * delta
	
	# limit vertical camera angle
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI / 3.0, PI / 3.0)
	
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
	
	var movement_mod = 1
	camera_pivot.position.y = 1
	
	if Input.is_action_pressed("crouch"):
		movement_mod = crouch_mod
		camera_pivot.position.y = 0.5
	elif Input.is_action_pressed("sprint"):
		movement_mod = sprint_mod
	else:
		movement_mod = 1
		
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed * movement_mod, acceleration * delta)
	velocity.y = y_velocity + gravity * delta
	
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_power
	
	move_and_slide()

# ============================ Note code ============================

@onready var interact_container: Control = $UIControl/InteractContainer

@onready var interact_label: Label = $UIControl/InteractContainer/HBoxContainer/InteractLabel

@onready var note_control: Control = $NoteControl
@onready var note_texture: TextureRect = $NoteControl/NoteTexture
@onready var note_text_label: Label = $NoteControl/NoteTexture/NoteTextLabel

@onready var paper_audio: AudioStreamPlayer = $PaperAudio

@onready var pause_control: Control = $PauseControl
@onready var notes_btn_container: VBoxContainer = $PauseControl/NotesBtnContainer

var notes_acquired:Array[Note3D]
var current_note:Note3D

var reading_note:bool = false
var is_paused:bool = false

func show_note(note:Note3D) -> void:
	reading_note = true
	note_text_label.text = note.note_contents
	note_control.show()
	current_note = note
	if !notes_acquired.has(current_note):
		notes_acquired.append(current_note)
		
func close_note():
	if current_note:
		current_note = null
	reading_note = false
	note_control.hide()

# ============================ UI code ============================

func show_pause_menu():
	pause_control.show()
	
	for i in notes_btn_container.get_children():
		i.queue_free()
		
	for note:Note3D in notes_acquired:
		var new_btn:Button = Button.new()
		new_btn.text = note.name
		notes_btn_container.add_child(new_btn)
		new_btn.pressed.connect(note.interact)
