# block_behaviour.gd
class_name BlockBehaviour
extends Node3D

var body: VoxelBody
var instance: BlockInstance
var mesh : MeshInstance3D
var collition : CollisionShape3D


func setup(p_body: VoxelBody, p_instance: BlockInstance, p_mesh: MeshInstance3D, p_collition: CollisionShape3D) -> void:
	body = p_body
	instance = p_instance
	mesh = p_mesh
	collition = p_collition

func _unhandled_input(event: InputEvent) -> void:
	pass  # override in thrusters, wheels, etc.
	
func is_key_down(event: InputEvent, code : Key) -> bool: return event is InputEventKey and event.is_pressed() and event.physical_keycode == code
