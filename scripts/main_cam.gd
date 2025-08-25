extends Camera2D

const ZOOM_SPEED:float = 5
const ZOOM_STEP:float = 0.1
const MIN_ZOOM:float = 0.2
const MAX_ZOOM:float = 1.5
const ACCELERATION:float = 300
const FRICTION:float = 0.01

var speed:Vector2 = Vector2.ZERO
var target_zoom: float = 1.0

var drag:bool = false
var last_mouse_pos:Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("scrolldown"):
		target_zoom = max(target_zoom - ZOOM_STEP, MIN_ZOOM)
	elif Input.is_action_pressed("scrollup"):
		target_zoom = min(target_zoom + ZOOM_STEP, MAX_ZOOM)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			drag = event.pressed
			if drag:
				last_mouse_pos = event.position
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and drag:
		var current_mouse_pos = event.position
		var difference = last_mouse_pos - current_mouse_pos
		global_position += difference
		last_mouse_pos = current_mouse_pos
		get_viewport().set_input_as_handled()


func handle_zoom(delta)->void:
	zoom = zoom.lerp(Vector2.ONE * target_zoom, ZOOM_SPEED * delta)

func handle_movement(delta)->void:
	var input_dir = Input.get_vector("left","right","up","down")
	var zoom_vec = zoom

	speed += input_dir * ACCELERATION * delta
	speed = speed / zoom_vec

	self.global_position += speed

	speed = speed * FRICTION * delta

func _process(delta: float) -> void:
	handle_zoom(delta)
	handle_movement(delta)
