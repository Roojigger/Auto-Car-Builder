extends Panel


func _on_show_options_pressed() -> void:
	visible = true
	get_node("../Show Options").visible = false


func _on_close_pressed() -> void:
	visible = false
	get_node("../Show Options").visible = true


func _on_switch_pressed() -> void:
	var json = get_node("../Grid/Vehicle").serialize()
	GameState.switch_to_driving(json)


func _on_save_pressed() -> void:
	var json = get_node("../Grid/Vehicle").serialize()
	var fdialog = FileDialog.new()
	fdialog.add_filter("*.json", "Vehcles")
	fdialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fdialog.root_subfolder = "res://Creations"
	add_child(fdialog)
	fdialog.popup_file_dialog()
	fdialog.file_selected.connect(func(path):
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(json))
		file.close()
		fdialog.queue_free()
	)
	
	


func _on_load_pressed() -> void:
	var fdialog = FileDialog.new()
	fdialog.add_filter("*.json", "Vehcles", "application/json")
	fdialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fdialog.root_subfolder = "res://Creations"
	add_child(fdialog)
	fdialog.popup_file_dialog()
	fdialog.file_selected.connect(func(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			get_node("../Grid/Vehicle").deserialize(json)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", path, " at line ", json.get_error_line())
		
		fdialog.queue_free()
	)
