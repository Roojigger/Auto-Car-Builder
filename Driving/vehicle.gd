extends Node2D

@export var default_car : JSON;

@export var parts_json : JSON;
var part_data;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState.pending_vehicle_json != null:
		var json = GameState.pending_vehicle_json
		part_data = parts_json.data;
		deserialize(json)
	else:
		part_data = parts_json.data;
		deserialize(default_car.data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_child(0):
		get_node("Camera2D").position = get_bounds(get_child(1)).get_center()
		
	

func get_bounds(node : Node) -> Rect2:
	var sprites : Array = node.find_children("*", "Sprite2D", true, false)
	if sprites.size() == 0:
		print("No sprites?")
		return Rect2(0, 0, 0, 0)
	
	var first_rect = Rect2(sprites[0].global_position, sprites[0].get_rect().size)
	var bounds : Rect2 = first_rect
	for i in range(1, sprites.size()):
		var sprite = sprites[i]
		var rect = Rect2(sprite.global_position, sprite.get_rect().size)
		bounds = bounds.merge(rect)
	
	return bounds

func set_position_keep_children(node: Node2D, new_position: Vector2) -> void:
	var delta = new_position - node.position
	node.position = new_position
	for child in node.get_children():
		if child is Node2D:
			child.position -= delta

func _uf_find(parent: Array, i: int) -> int:
	while parent[i] != i:
		parent[i] = parent[parent[i]]
		i = parent[i]
	return i

func _uf_union(parent: Array, a: int, b: int) -> void:
	var ra = _uf_find(parent, a)
	var rb = _uf_find(parent, b)
	if ra != rb:
		parent[ra] = rb

func deserialize(json) -> void:
	if json == null:
		print("Json is null")
		return

	for node in get_children():
		if not node is Sprite2D:
			continue
		node.queue_free()

	var parts = json["parts"]
	var n = parts.size()

	# --- Pass 1: compute per-part world data + connector world positions ---
	var part_info = []
	for part in parts:
		var pd = part_data[part['part']]
		var size = Vector2i(pd['Dims'][0], pd['Dims'][1])
		var world_pos = Vector2(part['pos'][0]*32, part['pos'][1]*32)

		var connectors = []
		for connector in pd['Connectors']:
			var local_jpos = Vector2(connector[0][0]*32, connector[0][1]*32) + Vector2(16,16)
			var on_top = false
			match connector[1]:
				"U": local_jpos += Vector2.UP    * 16
				"D": local_jpos += Vector2.DOWN  * 16
				"L": local_jpos += Vector2.LEFT  * 16
				"R": local_jpos += Vector2.RIGHT * 16
				"B": local_jpos += Vector2.ZERO  * 16; on_top = true;
			var is_pin = connector.size() > 2 and connector[2] == "Pin"
			connectors.append({
				"world": local_jpos + world_pos,
				"pin": is_pin,
				"on_top": on_top
			})

		part_info.append({
			"part": part,
			"size": size,
			"world_pos": world_pos,
			"connectors": connectors,
			"sprite_texture": "res://Parts/sprites/"+part['part']+".png",
			"script_path": ("res://Driving/Functions/"+pd['Script']) if pd.has('Script') else "",
		})
		
	# --- Pass 2: match connectors; weld (union) unless either side is "Pin" ---
	var parent = []
	for i in range(n):
		parent.append(i)

	var joint_connections = []
	var used = {}
	for i in range(n):
		for ci in range(part_info[i]["connectors"].size()):
			var key_i = str(i) + "_" + str(ci)
			if used.has(key_i):
				continue
			var conn_i = part_info[i]["connectors"][ci]
			for j in range(n):
				if j == i:
					continue
				for cj in range(part_info[j]["connectors"].size()):
					var key_j = str(j) + "_" + str(cj)
					if used.has(key_j):
						continue
					var conn_j = part_info[j]["connectors"][cj]
					if conn_i["world"].distance_to(conn_j["world"]) < (8 if not (conn_i["on_top"] or conn_j["on_top"]) else 40):
						used[key_i] = true
						used[key_j] = true
						if conn_i["pin"] or conn_j["pin"]:
							joint_connections.append({"a": i, "b": j, "pos": conn_i["world"], "t": "pint"})
						else:
							_uf_union(parent, i, j)
						break
					
				if used.has(key_i):
					break

	# --- Pass 3: one RigidBody2D per weld-group ---
	var group_root = {}
	var part_body = []
	part_body.resize(n)

	for i in range(n):
		var root = _uf_find(parent, i)
		if not group_root.has(root):
			var rb = RigidBody2D.new()
			rb.mass = 0.01
			rb.position = part_info[i]["world_pos"]
			rb.name = part_info[i]["part"]['part'] + '#group#' + str(root) + '#' + str(Time.get_ticks_msec())
			group_root[root] = rb
			add_child(rb)
		part_body[i] = group_root[root]

	# --- Pass 4: attach sprites/shapes, sum mass, collect (not apply) script path ---

	for i in range(n):
		var info = part_info[i]
		var rb = part_body[i]
		var local_offset = info["world_pos"] - rb.position

		var node = Sprite2D.new()
		node.centered = false
		node.texture = load(info["sprite_texture"])
		node.position = local_offset
		node.name = info["part"]['part'] + '_sprite#' + str(Vector2i(local_offset/32))

		var colshp = CollisionShape2D.new()
		colshp.shape = RectangleShape2D.new()
		colshp.shape.size = info["size"] * 32
		colshp.position = local_offset + info["size"] * 32 / 2.
		colshp.name = info["part"]['part'] + '_colshp#' + str(Vector2i(local_offset/32))

		if info["script_path"] != "" and FileAccess.file_exists(info["script_path"]):
			node.set_script(load(info["script_path"]))  # node = the Sprite2D, not rb
			print(node, ": ", info["script_path"])
		
		rb.add_child(colshp)
		rb.add_child(node)
		rb.mass += info["size"].x * info["size"].y
		

	# --- Pass 5: real joints only between separate (pin-connected) bodies ---
	for jc in joint_connections:
		var body_a = part_body[jc["a"]]
		var body_b = part_body[jc["b"]]
		if body_a == body_b:
			continue

		var joint = PinJoint2D.new()
		joint.add_to_group("joints")
		joint.bias = 1.0
		joint.angular_limit_enabled = false
		#joint.angular_limit_lower = deg_to_rad(-35)
		#joint.angular_limit_upper = deg_to_rad(35)
		joint.position = jc["pos"] - body_a.position
		joint.node_a = body_a.get_path()
		joint.node_b = body_b.get_path()
		joint.name = "joint#" + str(jc["pos"]) + "#" + str(joint.get_rid())
		body_a.add_child(joint)
		
	# --- Pass 6: Calulate center of mass for all bodies ---
	for rb in get_children():
		if rb is not RigidBody2D:
			continue
		rb.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
		rb.center_of_mass = get_bounds(rb).get_center()
		
	
	
