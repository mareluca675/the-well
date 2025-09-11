extends Node3D

var dialog_lines = []
var current_line_index = 0
var current_char_index = 0
var is_typing = false
var text_mesh

var typing_timer = Timer.new()
var disappear_timer = Timer.new()

func _ready():
	text_mesh = $TextMesh
	
	typing_timer.wait_time = 0.1 
	typing_timer.connect("timeout", on_typing_timeout)
	add_child(typing_timer)
	
	disappear_timer.wait_time = 3.0 
	disappear_timer.connect("timeout", on_disappear_timeout)
	add_child(disappear_timer)
	

func on_dialog_request(lines):
	self.dialog_lines = lines
	start_next_line()

func start_next_line():
	text_mesh.visible = true
	current_char_index = 0
	if current_line_index < dialog_lines.size():
		is_typing = true
		text_mesh.mesh.text = ""
		typing_timer.start()
	else:
		current_line_index = 0
		text_mesh.visible = false

func on_typing_timeout():
	if is_typing:
		if current_char_index < dialog_lines[current_line_index].length():
			text_mesh.mesh.text += dialog_lines[current_line_index][current_char_index]
			current_char_index += 1
		else:
			is_typing = false
			typing_timer.stop()
			disappear_timer.start()

func on_disappear_timeout():
	disappear_timer.stop()
	current_line_index += 1 
	start_next_line()
