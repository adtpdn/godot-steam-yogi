extends Camera3D

const ray_length = 1000

var result

func _input(event):
	pass
	# Check if the input event is mouse left button 
	# Set to token decoupled
	#if event.is_action_pressed("left_click"):
		## Returns a 3D position in world space
		#var from = project_ray_origin(event.position)
		## Returns a normal vector in world space
		#var to = from + project_ray_normal(event.position) * ray_length
		## Returns the current World3D resource this Node3D node is registered to
		## Direct access to physics 3D space state
		#var space_state = get_world_3d().direct_space_state
		## ray_query for the physcis ray query in 3D
		#var ray_query = PhysicsRayQueryParameters3D.new()
		## Set the ray_query from and to
		#ray_query.from = from
		#ray_query.to = to
		## Intersect ray in given space with ray_query
		#result = space_state.intersect_ray(ray_query)
		##print(result)
		#if result:
			#get_tree().call_group("units", "move_to", result.position)


func set_token_to_mouse():
	# Get the viewport and get the mouse position on the camera
	# The example of the result : (507, 163). It's a Vector 2
	var mouse_pos = get_viewport().get_mouse_position()
	# Set the ray_length 
	var ray_length = 1000 #int
	# Function project_ray_origin is returns a 3D position in world space, from Vector2D base on the camera
	# That is the result of projecting a point on the Viewport rectangle by the inverse camera projection.
	# Return a Vector3
	var from = project_ray_origin(mouse_pos)
	#print("FROM:",from)
	# Return a Vector3
	var to = from + project_ray_normal(mouse_pos) * ray_length
	#print("To:",to)
	# Returns the current World3D resource this Node3D node is registered to.
	# Direct access into the 3D physics
	var space = get_world_3d().direct_space_state
	## LEARN MORE
	# Configure the value of from and to for the intersect_ray function 
	var ray_query = PhysicsRayQueryParameters3D.new() # need to read this
	# Set the ray_query from 
	ray_query.from = from
	# Set the ray_query to
	ray_query.to = to
	# Set the intersect_ray with from and to variable from ray_query
	# Return a dictionary 
	result = space.intersect_ray(ray_query)
	#print(result)
	#print("SET TOKEN TO MOUSE")
