extends Node3D

@export_file("*.txt") var text_file_path: String

@onready var text_display_node: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	load_text()

func load_text():
	if is_instance_valid(text_display_node):
		if text_display_node.mesh is TextMesh:
			var file = FileAccess.open(text_file_path, FileAccess.READ)
			if FileAccess.get_open_error() == OK:
				
				var text_mesh = text_display_node.mesh as TextMesh
				text_mesh.text = file.get_as_text()
				
				file.close()
				print("Loaded text file into TextBox: " + text_file_path)
		else:
			printerr("Failed to load text file: " + text_file_path)
	else:
		printerr("MeshInstance3D must have assigned TextMesh resource. please change this code accordingly if you removed it.")
