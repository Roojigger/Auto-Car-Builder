extends BlockBehaviour

var node : String
var joint : Generic6DOFJoint3D

func _process(delta: float) -> void:
	if node and (get_node(node) and (get_node(node) is Generic6DOFJoint3D)):
		joint = get_node(node)

func _unhandled_input(event: InputEvent) -> void:
	if not joint: return;
	if (is_key_down(event, instance.settings["Key/Left"])):
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -1)
	elif (is_key_down(event, instance.settings["Key/Right"])):
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, 1)
	else:
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, 0)
