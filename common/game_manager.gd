extends Node3D

var window_has_focus: bool = true


func _ready() -> void:
	
	setup_input()


func _unhandled_input(event: InputEvent) -> void:
	handle_window_focus(event)


func handle_window_focus(event: InputEvent) -> void:
	if window_has_focus and event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		window_has_focus = false
	
	if not window_has_focus and event.is_action_pressed("attack"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		window_has_focus = true
	
	if window_has_focus and event.is_action_pressed("F11"):
		toggle_fullscreen()


func setup_input() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func toggle_fullscreen() -> void:
	var window = get_window()
	if window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN or window.mode == Window.MODE_FULLSCREEN:
		window.mode = Window.MODE_WINDOWED
		call_deferred("_set_window_size")
	else:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN

func _set_window_size() -> void:
	var window = get_window()
	window.size = Vector2i(1152, 648)
	window.move_to_center()
