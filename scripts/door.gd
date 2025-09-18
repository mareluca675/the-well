extends Interactable
class_name Door

@export var door_speed: float = 2.0
@export var open_angle: float = 90.0

@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var squeak_audio: AudioStreamPlayer3D = $SqueakAudio

var is_open: bool = false
var is_moving: bool = false
var initial_rotation: Vector3
var target_rotation: Vector3

func _ready() -> void:
	super._ready()
	if use_text == "Interact":  # Only set default if not already customized
		use_text = "Open Door"
	initial_rotation = rotation_degrees
	target_rotation = initial_rotation

func interact():
	if is_moving:
		return

	is_moving = true

	# Toggle door state
	if is_open:
		# Close door
		target_rotation = initial_rotation
		use_text = "Open Door"
		is_open = false
	else:
		# Open door
		target_rotation = initial_rotation + Vector3(0, open_angle, 0)
		use_text = "Close Door"
		is_open = true

func get_interaction_sound() -> AudioStream:
	# Use the door squeak sound
	return preload("res://audio/sfx/door_squeak.ogg")

func _process(delta: float) -> void:
	if is_moving:
		# Smoothly rotate towards target
		rotation_degrees = rotation_degrees.move_toward(target_rotation, door_speed * 60 * delta)

		# Check if we've reached the target
		if rotation_degrees.distance_to(target_rotation) < 0.1:
			rotation_degrees = target_rotation
			is_moving = false
