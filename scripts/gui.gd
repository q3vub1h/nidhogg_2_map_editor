extends CanvasLayer

const params_to_edit = {
	"id":0,
	"global_position:x":1,
	"global_position:y":1,
	"repeat_x":1,
	"repeat_y":1,
	"flip_h":2,
	"p4":1,
	"p5":1
	}

func _ready() -> void:
	S.add_room.connect(add_room)
	S.clicked_on_obj.connect(clicked_on_obj)
	#S.delete_room.connect(delete_room)
	#S.show_room.connect(show_room)
	S.new_map.connect(delete_all_rooms)
	S.selected_obj_param_changed.connect(obj_param_changed)

	create_param_editor()
	enable_all_params(false)

func enable_all_params(b:bool,obj:map_object=null)->void:
	for i in $side_menu/inspector.get_children():
		var param_editor:Control = i.get_child(1)

		#print(param_editor,b)
		match param_editor.get_class():
			"CheckBox": param_editor.disabled = !b
			"SpinBox": param_editor.editable = b
			"LineEdit": param_editor.editable = b
			_: printerr("no such param editor ",param_editor)

func create_param_editor()->void:
	for key in params_to_edit.keys():
		var v = params_to_edit.get(key)

		var param_editor:Control

		match v:
			0:
				param_editor = LineEdit.new()
				param_editor.text_changed.connect(func(s):S.selected_obj_param_changed.emit(key,s))
			1:
				param_editor = SpinBox.new()
				param_editor.value_changed.connect(func(f):S.selected_obj_param_changed.emit(key,f))
				param_editor.min_value = -99999
				param_editor.max_value = 99999
			2:
				param_editor = CheckBox.new()
				param_editor.toggled.connect(func(b):S.selected_obj_param_changed.emit(key,b))

		var param_temp = %param_temp.duplicate()
		param_temp.name = key
		param_temp.get_node("name").text = key
		param_temp.show()

		param_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		param_editor.mouse_filter = Control.MOUSE_FILTER_PASS

		param_temp.add_child(param_editor)
		$side_menu/inspector.add_child(param_temp)

		param_editor.owner = param_temp
		param_temp.owner = $side_menu/inspector

func clicked_on_obj(obj:map_object)->void:
	if obj==null: enable_all_params(false); return
	enable_all_params(true,obj)
	#print(obj.get_indexed("global_position_x"))
	for key in params_to_edit.keys():
		var value = obj.get_indexed(key)
		#print(value)
		var param_editor = $side_menu/inspector.get_node(key.replace(":","_")).get_child(1)
		#print(param_editor)

		match param_editor.get_class():
			"CheckBox": param_editor.button_pressed = bool(value)
			"SpinBox": param_editor.value = float(value)
			"LineEdit": param_editor.text = str(value)
			_: printerr("no such param editor ",param_editor)

func obj_param_changed(param:String,new_value:float)->void:
	var obj = get_tree().current_scene.selected_obj
	if obj == null: return
	print(obj,param," ",new_value)
	var param_editor = $side_menu/inspector.get_node(param.replace(":","_")).get_child(1)
	obj.set_indexed(param,new_value)
	#print(param_editor)
	match param_editor.get_class():
		"CheckBox": param_editor.button_pressed = bool(new_value)
		"SpinBox": param_editor.value = float(new_value)
		"LineEdit": param_editor.text = str(new_value)
		_: printerr("no such param editor ",param_editor)

func get_rooms()->Array[String]:
	var rooms:Array[String]
	for i in $side_menu/rooms/v.get_children():
		rooms.append(i.get_node("name").text)
	return rooms

func add_room(s:String):
	var room = %room_temp.duplicate()
	room.name = s
	room.get_node("name").text = s
	room.show()
	room.get_node("delete").pressed.connect(func():delete_room(s);S.delete_room.emit(s) )
	room.get_node("name").toggled.connect(func(b): S.show_room.emit(s,b) )

	$side_menu/rooms/v.add_child(room)

func delete_all_rooms():
	for i in $side_menu/rooms/v.get_children():
		i.queue_free()

func delete_room(s:String):
	for i in $side_menu/rooms/v.get_children():
		if i.name == s:
			print("deleted room: ",i.name)
			i.queue_free()

func _on_file_id_pressed(id: int) -> void:
	match id:
		1: S.new_map.emit()
		2: $save_as_map_dialog.popup()
		3: $open_map_dialog.popup()
		4: get_tree().quit();return

func _on_open_map_dialog_file_selected(path: String) -> void:
	S.open_map.emit(path)
	delete_all_rooms()

func _on_save_map_dialog_file_selected(path: String) -> void:
	S.save_map.emit(path)

func _on_add_room_pressed() -> void:
	var room_name:String = $side_menu/rooms/v/make_new/room_name.text
	var room_name_text: String = room_name.strip_edges()
	if room_name_text == "": return
	for i in get_rooms(): if i == room_name_text: return
	S.add_room.emit(room_name_text)


func _on_side_menu_mouse_entered() -> void:
	get_tree().current_scene.is_in_gui=true
	#if get_tree().current_scene.is_in_gui==true:return

func _on_side_menu_mouse_exited() -> void:
	get_tree().current_scene.is_in_gui=false
