extends Sprite2D

var force : float = 600;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("drive_forward"):
		get_parent().apply_force((Vector2.RIGHT*force).rotated(global_rotation), global_position-get_parent().global_position)

func _draw() -> void:
	if Input.is_action_pressed("drive_forward"):
		draw_line(global_position-get_parent().global_position, (Vector2.RIGHT*force).rotated(global_rotation) + (global_position-get_parent().global_position), Color(0,1,0))
	else:
		draw_line(global_position-get_parent().global_position, (Vector2.RIGHT*force).rotated(global_rotation) + (global_position-get_parent().global_position), Color(1,0,0))
	draw_circle(global_position-get_parent().global_position, .2, Color(1,1,1))
