extends Node2D
@export var on = true

@export var offset = Vector2(0,0)
@export var zoom = 1
@export var zoom_bounds = [0.25, 4] 

var moved = false

func _ready() -> void:
	queue_redraw()
var debug_marker_pos = null

func _draw():
	if on:
		var size = get_parent().size
		var grid_size = 32 * zoom
		var ofst = (offset - Vector2(fmod(size.x/2, 32), fmod(size.y/2, 32))) * zoom
		for i in range(int((ofst.x - size.x) / grid_size) - 1, int((size.x + ofst.x) / grid_size) + 1):
			var x = i * grid_size - ofst.x
			draw_line(Vector2(x, -size.y - 100), Vector2(x, size.y + 100), "000000")
		for i in range(int((ofst.y - size.y) / grid_size) - 1, int((size.y + ofst.y) / grid_size) + 1):
			var y = i * grid_size - ofst.y
			draw_line(Vector2(-size.x - 100, y), Vector2(size.x + 100, y), "000000")
	if debug_marker_pos != null:
		draw_circle(debug_marker_pos, 4, Color.RED)
		
var dragging = false
var drag_start_pos = Vector2.ZERO
var start = Vector2.ZERO

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_pan"):
		dragging = true
		start = (-get_viewport().get_mouse_position() - offset) + get_viewport_rect().size
		drag_start_pos = get_viewport().get_mouse_position()
		moved = false
	elif Input.is_action_just_released("ui_pan"):
		dragging = false
	
	if dragging:
		offset = (-get_viewport().get_mouse_position() - start) + get_viewport_rect().size
		get_node("Vehicle").position = -offset
		queue_redraw()
		if get_viewport().get_mouse_position().distance_to(drag_start_pos) > 20:  # small threshold
			moved = true
		
	

func zoomby(delta : float):
	zoom += delta * .1
	zoom = clamp(zoom, zoom_bounds[0], zoom_bounds[1])
	get_node("Vehicle").scale = Vector2.ONE * zoom
	queue_redraw()


func _on_home_pressed() -> void:
	offset = Vector2.ZERO
	start = Vector2.ZERO
	drag_start_pos = Vector2.ZERO
	zoom = 1
	get_node("Vehicle").scale = Vector2.ONE
	dragging = false
	get_node("Vehicle").position = Vector2.ZERO
	queue_redraw()


func _on_grid_toggle_pressed() -> void:
	on = !on
	queue_redraw()
