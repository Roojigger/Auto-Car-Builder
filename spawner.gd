extends Node2D

@export var carData  : JSON;
@export var partData : JSON;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_car()
	
func load_car():
	var data = carData.data

	for i in range(len(data["parts"])):
		var part = data["parts"][i]
		var node = Sprite2D.new()
		node.position = Vector2(part["pos"][0] * 32, part["pos"][1] * 32)
		var sprite = load("res://Parts/Sprites".path_join(part["part"])+".png")
		if sprite != null:
			node.texture = sprite
			node.centered = false
		else:
			print("res://Parts/Sprites".path_join(part["part"])+".png" + " Not found")
			
		add_child(node)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
