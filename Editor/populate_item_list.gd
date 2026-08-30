extends ItemList


@export var items_json : JSON;

var categorised_items : Dictionary;

var selected_catagory : String = "Blocks";

var selected_part : String = "";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if items_json == null:
		print("No items; exiting")
		return;
	var items = items_json.data;
	for key in items:
		var item = items[key]
		var category = item["Category"]
		if categorised_items.has(category):
			categorised_items[category][key] = item
		else:
			categorised_items[category] = {key : item}
			
	# Set up CategoryList
	var catlist = get_node("/root/Control/CategoryList")
	catlist.clear()
	for category in categorised_items.keys():
		catlist.add_item(category)
	catlist.select(0)

var _prevsc = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if selected_catagory != _prevsc:
		clear()
		if selected_catagory != "":
			for item in categorised_items[selected_catagory].keys():
				add_item(item, load("res://Parts/Sprites/"+item+".png"), true)
		_prevsc = selected_catagory

func on_catagory_select(index : int):
	selected_catagory = categorised_items.keys()[index]

func on_part_select(index : int):
	selected_part = categorised_items[selected_catagory].keys()[index]
