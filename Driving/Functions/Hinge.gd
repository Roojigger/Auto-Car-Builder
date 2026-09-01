extends Node2D

@export var max_steer_angle: float = 20.0

var target_angle_deg: float = 0

var joint: PinJoint2D = null
var other_body: RigidBody2D = null
var body: RigidBody2D = null

var rotation_fix = 0

var pivot: Vector2

func _ready():
	await get_tree().process_frame
	var best_joint = null
	var best_dist = INF
	body = get_parent()
	for j in get_connected_joints(body):
		if j is PinJoint2D:
			var d = j.position.distance_to(position)
			if d < best_dist:
				best_dist = d
				best_joint = j
	
	if best_joint:
		joint = best_joint
		other_body = get_node(joint.node_b) if joint.node_a == body.get_path() else get_node(joint.node_a)
		joint.motor_enabled = true
		joint.angular_limit_enabled = false
		joint.disable_collision = true   # PinJoint2D has this built in
		joint.softness = 0.1
		joint.bias = 0.05
		pivot = joint.global_position
	else:
		print("No PinJoint2D found on ", name)
		
	if other_body:
		other_body.set_script(load("res://Driving/Functions/PivotLock.gd"))
		other_body.call_deferred("init", self)


func _process(_delta: float) -> void:
	target_angle_deg = Input.get_axis("drive_steer_left", "drive_steer_right") * max_steer_angle

func _physics_process(_delta):
	if joint:
		pivot = joint.global_position
	if other_body and other_body.has_method("init"):
		other_body.target_rotation = body.rotation + deg_to_rad(target_angle_deg)

func get_connected_joints(rb: RigidBody2D) -> Array:
	var all_joints = get_tree().get_nodes_in_group("joints")  # if you've grouped them
	var connected = []
	for joint in all_joints:
		if joint.node_a == rb.get_path() or joint.node_b == rb.get_path():
			connected.append(joint)
	return connected
