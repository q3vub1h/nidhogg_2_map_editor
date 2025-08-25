extends Node2D

const MAP_ASSETS_PATH = "res://assets/unpacked/"
const TILE_SIZE = 1

@onready var gui = $gui
@onready var map_node = $map

var is_in_gui:bool = false

var map_objs:Array[map_object]

@export var selected_obj:map_object = null

func _ready()->void:
	get_window().title = "Nidhogg 2 map editor"
	S.show_room.connect(show_map_room)
	S.delete_room.connect(delete_map_room)
	S.new_map.connect(func():clear_map())
	S.save_map.connect(save_map)
	S.open_map.connect(open_map)
	#open_map(r"D:\Games\Nidhogg 2\Nidhogg 2 v23.11.2017\maps\volcano.txt")

func clear_map()->void:
	map_objs = []
	for i in map_node.get_children():
		i.queue_free()
	S.map_cleared.emit()
	get_window().title = "Nidhogg 2 map editor"

func open_map(map_file_path)->void:
	clear_map()

	var map_file = FileAccess.get_file_as_string(map_file_path)

	var ids:Array[String] = []

	var inum = 0
	var maxinum = -1

	var room:Node2D

	for line in map_file.split("\n"):
		if inum == maxinum: break
		line = line.strip_edges()
		if line == "":continue

		var line_info: Array = line.split("|")
		var params_size = line_info.size()-3

		var id = line_info[0]
		if id == "Room":
			S.add_room.emit(line_info[1])
			room = add_map_room(line_info[1])
			await get_tree().process_frame
			continue
		var x_pos:int = int(line_info[1])
		var y_pos:int = int(line_info[2])
		var pos:Vector2i = Vector2i(x_pos,y_pos)
		var repeat_x:int = int(line_info[3]) #for coll is x_size
		var repeat_y:int = int(line_info[4]) #for coll is y_size
		var flip_h:int = int(line_info[5])
		var p4:int = int(line_info[6])
		var p5:int = int(line_info[7])
		ids.append(id)

		var found = find_files_with_string(id)
		#print("to find: ",id)
		#print("found: ",found)
		if found.size()==0:printerr("cannot find:",id);continue

		var map_obj = map_object.new()
		map_obj.centered = false
		map_obj.name = id
		map_obj.global_position = pos*TILE_SIZE
		map_obj.texture = load(MAP_ASSETS_PATH+found[0])
		map_obj.id = id
		map_obj.repeat_x = repeat_x
		map_obj.repeat_y = repeat_y
		map_obj.flip_h = true if flip_h==1 else false
		map_obj.p4 = p4
		map_obj.p5 = p5
		room.add_child(map_obj)
		map_obj.owner = room.get_tree().edited_scene_root

		map_objs.append(map_obj)

		inum += 1

	print("map loaded")
	S.map_loaded.emit()
	get_window().title = "Nidhogg 2 map editor: "+str(map_file_path)

func save_map(path:String)->void:
	var map_file = FileAccess.open(path, FileAccess.WRITE)
	if not map_file:
		printerr(FileAccess.get_open_error())
		return

	var rooms: Array[String] = []
	for room in map_node.get_children():
		rooms.append(room.name)

	for i in range(rooms.size()):
		var room_name = rooms[i]
		map_file.store_line("Room|"+room_name)

		var room_node = map_node.get_node(room_name)
		if room_node:
			for map_obj in room_node.get_children():
				if map_obj is map_object:
					map_file.store_line(
						map_obj.id+"|"+
						map_obj.global_position.x+"|"+
						map_obj.global_position.y+"|"+
						map_obj.repeat_x+"|"+
						map_obj.repeat_y+"|"+
						map_obj.p4+"|"+
						map_obj.p5
						)

	map_file.close()

func add_map_room(s:String)->Node2D:
	var room_name = s
	var new_room = Node2D.new()
	new_room.name = room_name
	map_node.add_child(new_room)
	new_room.owner = map_node.get_tree().edited_scene_root
	return new_room

func show_map_room(s:String,b:bool)->void:
	for i in map_node.get_children():
		if i.name == s:
			i.visible = b

func delete_map_room(s:String):
	for i in map_node.get_children():
		if i.name == s:
			i.queue_free()

func find_files_with_string(search_string: String) -> Array:
	var found_files = []

	var dir = DirAccess.open(MAP_ASSETS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			#print(file_name)
			if not dir.current_is_dir():
				var to_search:String = search_string.replace("_","").to_lower()
				var sprite:String = file_name.replace("_","").replace(".png","").replace(".gif","").replace(".import","").to_lower()
				if to_search in sprite:
					found_files.append(file_name)
			file_name = dir.get_next()
			#await get_tree().process_frame
		dir.list_dir_end()
	else:
		printerr("Cant open dir: ", MAP_ASSETS_PATH)

	return found_files
