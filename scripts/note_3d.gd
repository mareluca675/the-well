extends Node3D
class_name Note3D

@export var use_text: String = "Read"
@export var note_contents: String = "Hello!"
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var note_mesh: CSGBox3D = $NoteMesh

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func interact():
	player.show_note(self)
	collision_shape_3d.disabled = true
	note_mesh.hide()
	pass
