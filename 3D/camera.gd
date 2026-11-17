extends Camera3D

@export var sensitivity := 0.003
@export var move_speed := 5.0
@export var sprint_multiplier := 3.0

@export_group("Raycast")
@export var use_raycast := true
@export_flags_3d_physics var collision_mask := 0xFFFFFFFF
@export var ray_length := 1000.0
@export var zoom_fraction := 0.15   # fraction of the distance to the hit point per scroll tick
@export var min_hit_distance := 0.5 # won't zoom closer than this to the hit point

@export_group("Fallbacks (no hit or raycast off)")
@export var orbit_around_origin := true
@export var orbit_distance := 10.0
@export var zoom_step := 1.0

var yaw := 0.0
var pitch := 0.0
var pivot := Vector3.ZERO
var was_orbiting := false

@export var vehicle_scene: PackedScene   # assign vehicle.tscn in the inspector

func _ready() -> void:
	var e := global_basis.get_euler()
	pitch = e.x
	yaw = e.y

# Returns the hit position, or null if nothing was hit
func _raycast(origin: Vector3, dir: Vector3) -> Variant:
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * ray_length, collision_mask)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit.position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(-1.0)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_look(event.relative)
		
	elif event is InputEventKey and event.pressed and not event.echo \
			and event.physical_keycode == KEY_R:
		respawn_vehicle()

func _zoom(direction: float) -> void:
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := project_ray_origin(mouse)
	var ray_dir := project_ray_normal(mouse)

	if use_raycast:
		var hit = _raycast(ray_origin, ray_dir)
		if hit != null:
			var dist := global_position.distance_to(hit)
			if direction > 0.0:
				# Zoom in, but stop short of the surface
				var step := minf(dist * zoom_fraction, maxf(dist - min_hit_distance, 0.0))
				global_position += ray_dir * step
			else:
				global_position -= ray_dir * dist * zoom_fraction
			return

	# Fallback: move along the view direction
	global_position -= global_basis.z * zoom_step * direction

func _look(relative: Vector2) -> void:
	var orbiting := Input.is_key_pressed(KEY_CTRL)

	if orbiting and not was_orbiting:
		pivot = _choose_pivot()
	was_orbiting = orbiting

	var old_basis := Basis.from_euler(Vector3(pitch, yaw, 0.0))

	yaw -= relative.x * sensitivity
	pitch = clampf(pitch - relative.y * sensitivity, -PI / 2.0 + 0.01, PI / 2.0 - 0.01)

	var new_basis := Basis.from_euler(Vector3(pitch, yaw, 0.0))

	if orbiting:
		var delta_rot := new_basis * old_basis.inverse()
		global_position = pivot + delta_rot * (global_position - pivot)

	global_basis = new_basis

func _choose_pivot() -> Vector3:
	if use_raycast:
		var hit = _raycast(global_position, -global_basis.z)
		if hit != null:
			return hit
	if orbit_around_origin:
		return Vector3.ZERO
	return global_position - global_basis.z * orbit_distance

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var move := Vector3.ZERO
		if Input.is_physical_key_pressed(KEY_W): move -= global_basis.z
		if Input.is_physical_key_pressed(KEY_S): move += global_basis.z
		if Input.is_physical_key_pressed(KEY_A): move -= global_basis.x
		if Input.is_physical_key_pressed(KEY_D): move += global_basis.x
		if Input.is_physical_key_pressed(KEY_E): move += Vector3.UP
		if Input.is_physical_key_pressed(KEY_Q): move -= Vector3.UP

		if move != Vector3.ZERO:
			var speed := move_speed
			if Input.is_key_pressed(KEY_SHIFT):
				speed *= sprint_multiplier
			global_position += move.normalized() * speed * delta
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		was_orbiting = false


func respawn_vehicle() -> void:
	var old := get_node("../Vehicle")
	var xform: Transform3D
	if (old):
		xform = old.global_transform  # or a stored spawn transform
		old.queue_free()
	
	await get_tree().process_frame
	var new_vehicle := vehicle_scene.instantiate()
	add_sibling(new_vehicle)
	new_vehicle.name = "Vehicle"
	new_vehicle.global_transform = xform
