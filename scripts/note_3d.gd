extends Interactable
class_name Note3D

@export var note_contents: String = "Hello!"
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var note_mesh: CSGBox3D = $NoteMesh

func _ready() -> void:
	super._ready()
	if use_text == "Interact":  # Only set default if not already customized
		use_text = "Read"

func interact():
	player.show_note(self)
	collision_shape_3d.disabled = true
	note_mesh.hide()

func get_interaction_sound() -> AudioStream:
	# Use the paper grab sound for notes
	return preload("res://audio/sfx/papergrab3.ogg")
