extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var grid : Node2D = get_parent()
@onready var build_area : Control = get_parent().get_parent()
@onready var parts_list : ItemList = get_node("/root/Control/PartsList")

var preview_node = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_viewport().gui_get_hovered_control() == build_area:
		var mouse_cell_pos = (floor(((build_area.get_local_mouse_position() ) \
									+ grid.offset \
									+ Vector2(12.79999, -4.0)) / 32\
								) * 32 - build_area.size / 2) - Vector2(12.79999, -4.0)
								
		
		
		if Input.is_action_just_released("editor_pick") and not grid.moved: 
			get_node("Selection").selection = null
			var part = get_sprite_under_mouse(get_children())
			if part != null and part != preview_node and part != get_node("Selection"):
				parts_list.selected_part = part.name.split("#")[0]
			else:
				parts_list.selected_part = ""
				parts_list.deselect_all()
		elif Input.is_action_just_released("ui_cancel"):
			get_node("Selection").selection = null
			parts_list.selected_part = ""
			parts_list.deselect_all()
		elif parts_list.selected_part != "":
			get_node("Selection").selection = null
			if Input.is_action_just_released("ui_click"):
				var selpart = parts_list.selected_part
				
				var node = Sprite2D.new()
				node.centered = false
				node.texture = load("res://Parts/sprites/"+selpart+".png")
				
				node.position = mouse_cell_pos
				
				node.name = selpart + '#' + str(roundi(mouse_cell_pos.x / 32)) + ',' + str(roundi(mouse_cell_pos.y / 32)) +'#'+str(Time.get_ticks_msec())
				if "Top Mounted" in parts_list.items_json.data[selpart]["Flags"]:
					if would_part_overlap(preview_node):
						node.z_index = 1
						add_child(node)
				elif not would_part_overlap(preview_node):
					add_child(node)
			else: # ghost
				var selpart = parts_list.selected_part
				if not preview_node:
					preview_node = Sprite2D.new()
					preview_node.centered = false
					preview_node.z_index = 2
					preview_node.name = "Preview"
					add_child(preview_node)
				
				preview_node.texture = load("res://Parts/sprites/"+selpart+".png")
				preview_node.position = mouse_cell_pos
				
				if "Top Mounted" in parts_list.items_json.data[selpart]["Flags"]:
					if would_part_overlap(preview_node):
						preview_node.modulate = Color(1, 1, 1, 0.5)
					else:
						preview_node.modulate = Color(1, 0.3, 0.4, 0.5)
				elif would_part_overlap(preview_node):
					preview_node.modulate = Color(1, 0.3, 0.4, 0.5)
				else:
					preview_node.modulate = Color(1, 1, 1, 0.5)
		elif Input.is_action_just_released("editor_select"): 
			var part = get_sprite_under_mouse(get_children())
			if part != null:
				get_node("Selection").selection = part
			else:
				get_node("Selection").selection = null
		else:
			if preview_node: preview_node.queue_free();
	else:
		if preview_node: preview_node.queue_free();

func _input(event):
	if get_viewport().gui_get_hovered_control() == build_area:
		if event.is_action_pressed("editor_zoom+") or event.is_action_pressed("editor_zoom-"):
			var delta = Input.get_axis("editor_zoom-", "editor_zoom+")
			grid.zoomby(delta) # No zoom for now
		elif event.is_action_pressed("editor_switch_part+") or event.is_action_pressed("editor_switch_part-"):
			@warning_ignore("narrowing_conversion")
			var delta : int = Input.get_axis("editor_switch_part-", "editor_switch_part+")
			var selected = parts_list.get_selected_items()  # returns Array[int] (supports multi-select)
			if selected.size() > 0:
				var index = fmod((selected[0] - delta), parts_list.item_count)
				while index < 0:
					index += parts_list.item_count
				parts_list.select(index)
				parts_list.on_part_select(index) # as select is silent

func would_part_overlap(part: Sprite2D) -> bool:
	for node in get_children():
		if not node is Sprite2D:
			continue
		if node == preview_node:
			continue
		
		if sprites_overlap(part, node):
			return true
	return false

func serialize():
	var parts = []
	for node in get_children():
		if not node is Sprite2D:
			continue
		if node == preview_node:
			continue
		
		var split = node.name.split('#')
		var part = split[0]
		var pos = Vector2i(int(split[1].split(',')[0]), int(split[1].split(',')[1]))
		parts.append({"part": part, "pos": [pos.x, pos.y]})
	var json = JSON.parse_string('{ "parts" : '+str(parts)+'}')
	return json

func deserialize(json : JSON):
	## First delete all parts
	for node in get_children():
		if not node is Sprite2D:
			continue
		node.queue_free()
	## Then load the parts back from json
	for part in json.data["parts"]:
		var node = Sprite2D.new()
		node.name = part['part'] + '#' + str(part['pos'][0]) + ',' + str(part['pos'][1]) +'#'+str(Time.get_ticks_msec())
		
		node.position = Vector2(part['pos'][0]*32, part['pos'][1]*32)
		
		node.centered = false
		node.texture = load("res://Parts/sprites/"+part['part']+".png")
		
		add_child(node)

func sprites_overlap(a: Sprite2D, b: Sprite2D) -> bool:
	var rect_a = a.get_rect()
	rect_a.position += a.global_position
	var rect_b = b.get_rect()
	rect_b.position += b.global_position
	return rect_a.intersects(rect_b)

func get_sprite_under_mouse(sprites: Array) -> Sprite2D:
	var mouse_pos = get_global_mouse_position()
	for sprite in sprites:
		if not sprite is Sprite2D:
			continue
		var rect = sprite.get_rect()
		rect.position += sprite.global_position
		if rect.has_point(mouse_pos):
			return sprite
	return null

func is_mouse_over(node : Node) -> bool:
	return Rect2(Vector2.ZERO, node.size).has_point(node.get_local_mouse_position())
