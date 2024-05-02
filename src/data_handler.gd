# Godot 4.2.1 Stable

extends Node

var item_data := {}
var item_grid_data := {}
@onready var item_data_path = "res://data/item_data.json"

func _ready() -> void:
	load_data(item_data_path)
	set_grid_data()

func load_data(a_path) -> void:
	if not FileAccess.file_exists(a_path):
		print("Item data file not found")
	var item_data_file = FileAccess.open(a_path, FileAccess.READ)
	# Read JSON as string
	item_data = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	print(item_data)

func set_grid_data():
	for item in item_data.keys():
		var temp_grid_array := []
		# JSON.parse_string to format dictionary into array
		# by storing as temp_grid_array
		# { "1": { "Name": "Red", "Grid": "0,0" } }
		# to : { "1": ["0", "0"] }
		for point in item_data[item]["Grid"].split(","):
			temp_grid_array.push_back(point)
		item_grid_data[item] = temp_grid_array
	#print(item_grid_data)
	
