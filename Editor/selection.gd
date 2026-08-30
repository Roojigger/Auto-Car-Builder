extends Control


@export var selection : Sprite2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(selection != null):
		visible = true
		size = selection.get_rect().size + Vector2.ONE
		position = selection.position
	else:
		visible = false


func _on_delete_pressed() -> void:
	selection.queue_free()
