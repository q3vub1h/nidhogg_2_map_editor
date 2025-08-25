extends Node

@onready var exe_path:String = OS.get_executable_path().get_base_dir()
@onready var app_settings_path:String = exe_path + "/config.ini"

var default_maps_path:String = "fdg"

var to_save_load:PackedStringArray = ["default_maps_path"]

func _ready() -> void:
	save_to_file()

func save_to_file()->void:
	print(app_settings_path)
	var settings_file = FileAccess.open(app_settings_path,FileAccess.WRITE)

	for i in to_save_load.size():
		var index = to_save_load[i]
		var value = get_indexed(index)

		settings_file.store_line(index+"="+value)

	settings_file.close()

#func load_from_file()->void:
