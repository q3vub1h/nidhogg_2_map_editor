extends Control
class_name gizmo2d

@export var is_dragging:bool = false
var drag_offset:Vector2 = Vector2.ZERO


func _ready():
	S.clicked_on_obj.connect(clicked_on_obj)
	connect("gui_input", _on_gui_input)

func clicked_on_obj(obj:map_object)->void:
	if obj==null:return
	get_tree().current_scene.selected_obj=obj;
	global_position=obj.global_position+obj.texture.get_size()/2

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_tree().current_scene.selected_obj!=null:
				drag_offset = get_tree().current_scene.selected_obj.global_position - get_global_mouse_position()
				is_dragging = true
		else:
			is_dragging = false

	elif event is InputEventMouseMotion and is_dragging and get_tree().current_scene.selected_obj:
		get_tree().current_scene.selected_obj.global_position = get_global_mouse_position() + drag_offset
		global_position = get_tree().current_scene.selected_obj.global_position+get_tree().current_scene.selected_obj.texture.get_size()/2

		S.selected_obj_param_changed.emit(
			"global_position:x",
			get_tree().current_scene.selected_obj.global_position.x
		)
		S.selected_obj_param_changed.emit(
			"global_position:y",
			get_tree().current_scene.selected_obj.global_position.y
		)
