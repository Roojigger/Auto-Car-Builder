extends Panel


func _on_show_options_pressed() -> void:
	visible = true
	get_node("../Show Options").visible = false


func _on_close_pressed() -> void:
	visible = false
	get_node("../Show Options").visible = true


func _on_switch_pressed() -> void:
	pass # Replace with function body.


func _on_save_pressed() -> void:
	pass # Replace with function body.


func _on_load_pressed() -> void:
	pass # Replace with function body.
