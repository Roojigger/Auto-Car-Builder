extends Node

var pending_vehicle_json = null

func switch_to_driving(json):
	pending_vehicle_json = json
	get_tree().change_scene_to_file("res://Driving/Driving.tscn")
