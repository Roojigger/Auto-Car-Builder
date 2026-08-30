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
									- Vector2(6.5,7) + grid.offset \
									- Vector2(0,0)) / 32 \
								) * 32 - build_area.size / 2) + Vector2(6.5,7)
		
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
				node.name = selpart+'#'+str(Time.get_ticks_msec())
				
				node.position = mouse_cell_pos
				if not would_part_overlap(preview_node):
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
				if would_part_overlap(preview_node):
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
	#if event.is_action_pressed("editor_zoom+") or event.is_action_pressed("editor_zoom-"):
		#var delta = Input.get_axis("editor_zoom-", "editor_zoom+")
		#grid.zoomby(delta) # No zoom for now
	if event.is_action_pressed("editor_switch_part+") or event.is_action_pressed("editor_switch_part-"):
		var delta : int = Input.get_axis("editor_switch_part-", "editor_switch_part+")
		var selected = parts_list.get_selected_items()  # returns Array[int] (supports multi-select)
		if selected.size() > 0:
			var index = fmod((selected[0] - delta), parts_list.item_count)
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
