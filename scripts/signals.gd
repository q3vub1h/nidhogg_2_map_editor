extends Node

signal new_map
signal open_map(s)
signal save_map(s)

signal add_room(s)
signal show_room(s,b)
signal delete_room(s)

signal map_loaded
signal map_cleared
signal map_saved

signal clicked_on_obj(obj)
signal selected_obj_param_changed(param, new_value)
