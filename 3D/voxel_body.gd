extends RigidBody3D
class_name VoxelBody

@export var blocks: Array[BlockInstance] = []

func _ready() -> void:
	
	for block in blocks:
		
		var mesh_inst = MeshInstance3D.new()
		var col_shape = CollisionShape3D.new()
		
		mesh_inst.mesh = block.type.mesh
		col_shape.shape = block.type.collision_shape
		
		var f := Vector3(block.type.footprint)
		var b := Orientation.to_basis(block.orientation)
		var t := Transform3D(b, Vector3(block.origin) + (b * f).abs() * 0.5)
		mesh_inst.transform = t
		col_shape.transform = t
		
		add_child(mesh_inst)
		add_child(col_shape)
		
		if block.type.behaviour_script and block.type.behaviour_script.can_instantiate():
			var behaviour = Node3D.new()
			behaviour.set_script(block.type.behaviour_script)
			behaviour.setup(self, block, mesh_inst, col_shape)
			add_child(behaviour)
		
	
