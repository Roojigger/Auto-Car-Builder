extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().linear_damp  = 1
	get_parent().angular_damp = .1


func _physics_process(_delta):
	pass
