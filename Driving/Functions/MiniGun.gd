extends Sprite2D


@export var speed : float = 0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	print("start gun: ", self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var new_rot = Vector2.RIGHT.angle_to(get_global_mouse_position()-global_position)
	rotation = rotate_toward(rotation, new_rot, speed)
	print("start gun: ", self)
