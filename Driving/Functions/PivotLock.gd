extends RigidBody2D

var pivot_node: Node2D = null   # the hinge sprite — its global_position is the pivot
var local_offset: Vector2 = Vector2.ZERO
var target_rotation: float = 0.0
var ready_to_lock := false

func init(hinge_node: Node2D):
	pivot_node = hinge_node
	var pivot = hinge_node.pivot
	local_offset = (global_position - pivot).rotated(-rotation)
	target_rotation = rotation
	ready_to_lock = true

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if not ready_to_lock:
		return
	var pivot = pivot_node.pivot
	var new_offset = local_offset.rotated(target_rotation)
	state.transform = Transform2D(target_rotation, pivot + new_offset)
	state.angular_velocity = 0.0
