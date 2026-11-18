extends BlockBehaviour

var joint : HingeJoint3D

func attach_joint(l_joint: HingeJoint3D) -> void:
	joint = l_joint
	print(joint)

var target_angle: float = 0.0
var max_angle: float = 15

var gain := 5.0
var max_speed := 4.0  # rad/s

func _ready() -> void:
	while joint == null:
		if not is_inside_tree():
			return
		await get_tree().process_frame
	
	joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(max_angle))
	joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -deg_to_rad(max_angle))
	joint.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
	joint.set_param(HingeJoint3D.PARAM_MOTOR_MAX_IMPULSE, 2)
	
	joint.exclude_nodes_from_collision = true

func _physics_process(_delta: float) -> void:
	if not joint:
		return
	var error := angle_difference(get_hinge_angle(), target_angle)
	var velocity := -clampf(error * gain, -max_speed, max_speed)
	joint.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, velocity)
	

func _unhandled_input(event: InputEvent) -> void:
	if is_key_down(event, instance.settings["Key/Left"]):
		target_angle = max_angle
	elif is_key_down(event, instance.settings["Key/Right"]):
		target_angle = -max_angle
	else:
		target_angle = 0


var _rest_rel: Basis

func _capture_rest() -> void:
	var a: Node3D = get_node(joint.node_a)
	var b: Node3D = get_node(joint.node_b)
	_rest_rel = a.global_basis.orthonormalized().inverse() * b.global_basis.orthonormalized()

func get_hinge_angle() -> float:
	var a: Node3D = joint.get_node(joint.node_a)
	var b: Node3D = joint.get_node(joint.node_b)
	var rel := a.global_basis.orthonormalized().inverse() * b.global_basis.orthonormalized()
	var q := (rel * _rest_rel.inverse()).get_rotation_quaternion()

	# The hinge axis in body A's local space. This works when the joint is a child of node_a.
	var axis := joint.transform.basis.z

	var s := Vector3(q.x, q.y, q.z).dot(axis)
	return wrapf(2.0 * atan2(s, q.w), -PI, PI)  # radians, signed
