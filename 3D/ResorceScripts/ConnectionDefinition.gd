class_name Connection
extends Resource

@export var body_a: int          # index into assembly.bodies
@export var body_b: int
@export var anchor: Vector3      # joint position, in assembly space
@export var axis: Vector3 = Vector3.UP
@export var hinge_cell: Vector3i   # block.origin of the hinge block
@export_enum("Body A", "Body B") var owner_body: int = 0
 
