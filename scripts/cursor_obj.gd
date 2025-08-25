extends Node2D

var map_objs:Array[map_object]

@onready var obj_name_label = $obj_name

var mouse_pos:Vector2
var hovered_obj:map_object

func _ready() -> void:
	S.map_loaded.connect(get_map_objs)
	#$obj_menu.hide()

func _process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	hovered_obj = get_hovered_obj()
	if hovered_obj!=null:
		obj_name_label.global_position = mouse_pos
		obj_name_label.text = hovered_obj.id

func _input(_event: InputEvent) -> void:
	if get_tree().current_scene.is_in_gui==true:return
	if Input.is_action_just_pressed("lclick"):
		if hovered_obj!=null:
			S.clicked_on_obj.emit(hovered_obj)
		#else:
			#S.clicked_on_obj.emit(null)
			#show_obj_menu(true,hovered_obj)

func get_map_objs()->void:
	map_objs = get_tree().current_scene.map_objs

func get_hovered_obj()->map_object:
	if map_objs == []:return null
	obj_name_label.text = ""

	for map_obj:map_object in map_objs:
		if is_instance_valid(map_obj)==false:return
		if map_obj.get_parent().visible==false:continue
		var rect = Rect2(map_obj.global_position - map_obj.offset,map_obj.texture.get_size())
		if rect.has_point(mouse_pos)==true:
			return map_obj
	return null

func show_obj_menu(b:bool,obj:map_object=null)->void:
	if b==false:
		$obj_menu.visible=b
		for i in $obj_menu/v.get_children():i.queue_free()
		return
	$obj_menu.visible=b
	$obj_menu.global_position = mouse_pos
	var setts:Array[String] = ["id","params"]
	for i in setts:
		var le = LineEdit.new()
		le.name = i
		le.placeholder_text = i
		le.text = str(obj.get(i))
		le.mouse_filter = Control.MOUSE_FILTER_PASS
		le.text_changed.connect(func(t):obj.set(i,t) )
		$obj_menu/v.add_child(le)
		le.owner = $obj_menu
