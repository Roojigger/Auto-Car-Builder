class_name Assembly
extends Node3D

@export var bodies: Array[BodyData] = []
@export var connections: Array[Connection] = []

func _ready() -> void:
	var nodes: Array[VoxelBody] = []
	for data in bodies:
		var body := VoxelBody.new()
		body.blocks = data.blocks
		add_child(body)
		nodes.append(body)

	for c in connections:
		var joint := HingeJoint3D.new()
		add_child(joint)
		# HingeJoint3D rotates around its local Z axis, so aim Z along c.axis
		joint.transform = Transform3D(
			Basis(Quaternion(Vector3.BACK, c.axis.normalized())),
			c.anchor
		)
		# NodePaths only resolve once everything is in the tree
		joint.node_a = joint.get_path_to(nodes[c.body_a])
		joint.node_b = joint.get_path_to(nodes[c.body_b])
		
		
		var host: VoxelBody = nodes[c.body_a if c.owner_body == 0 else c.body_b]
		var beh = host.behaviours.get(c.hinge_cell)
		if beh and beh.has_method("attach_joint"):
			beh.attach_joint(joint)
