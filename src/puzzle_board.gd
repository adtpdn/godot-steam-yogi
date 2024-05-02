# Godot 4.2.1 Stable
extends Node

@onready var grid_container = $GUI_Area/PuzzleBoard
@onready var guiarea = $GUI_Area
@onready var pg_container = $LeftContainer/GoalBoard
# Main Ref
@onready var slot = preload("res://scenes/slot.tscn")
@onready var item_scene = preload("res://scenes/item.tscn")
@onready var col_count = grid_container.columns # 5
@onready var goal_col = pg_container.columns # 3
@onready var root = $"."
@onready var window_size = get_window().size

# Mouse Input Bound Area
@onready var puzzleboard_area = Vector2(grid_container.size)

# DEBUG UI
@onready var pos_debug_ui = $Panel/Container/Pos
@onready var item_debug_ui = $Panel/Container/Item
# Generator Goals
@onready var is_goals_set := false

# PuzzleBoard
var grid_array := []

var item_held = null
var item_selected = false

var current_slot = null

# Hover and Click
var slot_selected = false
var slot_held = null
@onready var slot_choosen
# ---
var can_place := false
var icon_anchor : Vector2

# PuzzleGoal
var pg_array := []
var pg_icon_anchor : Vector2

# Call for ready
func _ready() -> void:
	
# make 25x slot of inventory
	for key in range(25):
		create_slot(grid_container)
	
# make 9x slot for puzzlegoal
	for key in range(9):
		create_slot(pg_container)

# Call every tick-frame

func _process(delta: float) -> void:
	if slot_selected and Input.is_action_just_pressed("mouse_leftclick"):
		#print("Test click by _on_slot_mouse_entered")
		slot_choosen = current_slot
		print("Slot Choosen : ", slot_choosen.slot_ID, "  Node : ", slot_choosen)
		Utils.set_btn_state(Utils.btn_state.Select)
		#slot_selected = true
		pos_debug_ui.text = str(slot_choosen.slot_ID)
		slot_choosen.states = 3
		slot_selected = false

# Create Slot for X, can be reusable
func create_slot(x):
	var slot_instantiated = slot.instantiate()
	# give slot id number, return number in array
	if x == pg_container:
		slot_instantiated.slot_ID = pg_array.size()
		pg_array.push_back(slot_instantiated)
	else:
		slot_instantiated.slot_ID = grid_array.size()
		# push back new slot
		grid_array.push_back(slot_instantiated)
	# loop instantiate, and force giving readable name (:true)
	x.add_child(slot_instantiated, true)
	# connect signal to slot
	if x == pg_container:
		pass
	else:
		slot_instantiated.slot_mouse_entered.connect(_on_slot_mouse_entered)
		slot_instantiated.slot_mouse_exited.connect(_on_slot_mouse_exited)

# Signal Receiver
func _on_slot_mouse_entered(slot):
	# a_Slot.set_color(a_Slot.States.TAKEN) #DEBUG
	icon_anchor = Vector2(window_size) # set icon anchor size to current window
	current_slot = slot
	
	if slot_selected: # Set current_slot to hover state
		current_slot.set_color(slot.States.HOVER)
	else:
		current_slot.set_color(slot.States.DEFAULT)

func _on_slot_mouse_exited(slot):
	# a_Slot.set_color(a_Slot.States.DEFAULT) #DEBUG
	pos_debug_ui.text = "NULL"
	
	if slot_selected:
		Utils.pre_check_grid_item_stored()
	if slot_choosen != null:
		clear_grids()
		slot_choosen.set_color(slot.States.HOVER)

# Button for Spawning Item
func _on_spawn_item_button_pressed() -> void:
	var new_item = item_scene.instantiate()
	var spawn_loc = $LeftContainer/SpawnItemButton.get_position() # dirty way to call button.position
	new_item.set_position(spawn_loc) # set new instantiate root item position to button position
	# loop instantiate, and force giving readable name (:true)
	add_child(new_item, true)
	new_item.load_item(randi_range(1,4))
	new_item.selected = true

	item_held = new_item
	item_debug_ui.text = str(item_held.item_ID) # Print Debug

# Generate Random Item on GoalBoard
func generate_random_goal():	
	for slot in pg_array:
		var pg_slot_ID = slot.slot_ID
		var token_cell = pg_slot_ID + icon_anchor.x * goal_col +icon_anchor.y
		var token = item_scene.instantiate()
		# Formatting
		token.name = "Goal" + "0"
		pg_container.add_child(token, true)
		token.add_to_group("Goals")
		slot.item_stored = token
		token.load_item(randi_range(1,4))
		token.grid_anchor = slot
		token._snap_to(pg_array[pg_slot_ID].global_position)

# Queue Free Random Goals 
func remove_random_goal():
	pg_container.queue_free()

# Button for Random Item
func _on_shuffle_goals_pressed() -> void:
	# Switch for button
	if is_goals_set == false:
		generate_random_goal()
		is_goals_set = true
	else:
		var goals = get_tree().get_nodes_in_group("Goals")
		for goal in goals:
			goal.queue_free()
		is_goals_set = false

# Function to check raw neighborhood from a_Slot
func check_neighbor(slot):
	var grid_to_check
	var filtered_arr = []
	var arr = []
	var id = []
	
	for grid in item_held.item_grids:
		grid_to_check = slot.slot_ID + grid[0] * col_count

	match grid_to_check:
		0:
			id = [0,0,0,0,1,0,5,6]
		1,2,3:
			id = [0,0,0,-1,1,4,5,6]
		4:
			id = [0,0,0,-1,0,4,5,0]
		5,10,15:
			id = [0-5,-4,0,1,0,5,6]
		6,7,8,11,12,13,16,17,18:
			id = [-6,-5,-4,-1,1,4,5,6]
		9,14,19:
			id = [-6,-5,0,-1,0,4,5,0]
		21,22,23:
			id = [-6,-5,-4,-1,1,0,0,0]
		20:
			id = [0,-5,-4,0,1,0,0,0]
		24:
			id = [-6,-5,0,-1,0,0,0,0]
	
	arr = id # append id[] rules to arr[]
	
	# Append rules to filtered_arr
	for i in arr:
		if i != 0:
			filtered_arr.append(i + grid_to_check)
	# Acess filtered_arr key, and set the key.states taken
	for key in range(filtered_arr.size()):
		var value_k = filtered_arr[key]
		grid_array[value_k].set_color(grid_array[value_k].States.FREE)
	
	print("Current neighbor : ", filtered_arr) # Debug Number

# Set Grids
func set_grids(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] * col_count # + grid[1] if not rect
		pos_debug_ui.text = str(a_Slot.slot_ID)
		var line_switch_check = a_Slot.slot_ID % col_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= col_count:
			continue
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue

		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			if grid[0] < icon_anchor.x: icon_anchor.x = grid[0] # can be set for grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

# Clear Grids
func clear_grids():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

# Select Btn GUI
func _on_select_pressed():
	Utils._on_select_pressed.emit()
	#Utils.pre_check_grid_item_stored()
	slot_selected = true

# Deselect Btn GUI
func _on_deselect_pressed():
	slot_selected = false
	slot_choosen = null
	Utils.set_btn_state(Utils.btn_state.Idle) # Set to Idle 
	clear_grids()

# Spawn item on choosen slot
func _on_spawn_item_on_choosen_button_pressed():
	Utils._on_spawn_item_to_choosen_slot.emit()
	Utils.spawn_on_choosen_slot(slot_choosen)
