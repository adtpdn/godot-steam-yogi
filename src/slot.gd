# Godot 4.2.1 Stable

extends TextureRect

signal slot_mouse_entered(slot)
signal slot_mouse_exited(slot)
#signal _on_gui_area_mouse_entered(slot)

@onready var filter = $StatusFilter
@onready var region = $/root/Control/GUI_Area
#@onready var regionpos = region.get_position()

var slot_ID
var is_hovering := false
enum States {
	DEFAULT, 
	TAKEN, 
	FREE,
	HOVER
}
var states := States.DEFAULT
var item_stored = null

func set_color(a_state = States.DEFAULT) -> void:
	match a_state:
		States.DEFAULT:
			filter.color = Color(Color.WHITE, 0.0)
		States.TAKEN:
			filter.color = Color(Color.DARK_RED, 0.5)
		States.FREE:
			filter.color = Color(Color.GREEN, 0.5)
		States.HOVER:
			filter.color = Color(Color.BLACK, 0.5)

func _process(delta: float) -> void:
	
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			emit_signal("slot_mouse_entered", self)
	else:
		if is_hovering:
			is_hovering = false
			emit_signal("slot_mouse_exited", self)
			
	#if Rect2(regionpos, region.size).has_point(get_global_mouse_position()):
		#if not is_hovering:
			#is_hovering = true
			#emit_signal("slot_mouse_entered", self)
	#else:
		#if is_hovering:
			#is_hovering = false
			#emit_signal("slot_mouse_exited", self)
