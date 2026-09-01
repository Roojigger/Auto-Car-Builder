extends Sprite2D

@export var drive_force: float = 2000.0
@export var grip: float = 8.0
@export var forward_dir: Vector2 = Vector2.RIGHT  # local direction this wheel "points", adjust per part orientation

var body: RigidBody2D = null

func _ready():
	body = get_parent()

func _physics_process(_delta):
	if not body:
		return
	
	var wheel_world_pos = body.to_global(position)
	var offset = wheel_world_pos - body.global_position
	
	# --- Drive force (forward/back input) ---
	var input_amount = 0.0
	if Input.is_action_pressed("drive_forward"):
		input_amount += 1.0
	if Input.is_action_pressed("drive_backward"):
		input_amount -= 1.0
	
	var forward_world = forward_dir.rotated(body.rotation)
	
	if input_amount != 0.0:
		body.apply_force(forward_world * drive_force * input_amount, offset)
	
	# --- Lateral friction/grip at this wheel's contact point ---
	var vel_at_wheel = body.linear_velocity + body.angular_velocity * offset.orthogonal()
	var right_world = forward_world.orthogonal()
	
	var side_speed = vel_at_wheel.dot(right_world)
	var friction_force = -right_world * side_speed * grip
	body.apply_force(friction_force, offset)
