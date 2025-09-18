extends Node3D
class_name Interactable

@export var use_text: String = "Interact"

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

# Override this method in child classes
func interact():
	pass

# Override this method if the interactable should play custom sound
func get_interaction_sound() -> AudioStream:
	return null

# Override this method if the interactable should play sound at custom volume
func get_interaction_volume() -> float:
	return 0.0
