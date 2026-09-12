extends Node

var window_has_focus: bool = true


func _ready() -> void:
	
	setup_input()


func _unhandled_input(event: InputEvent) -> void:
	handle_window_focus(event)


func handle_window_focus(event: InputEvent) -> void:
	if window_has_focus and event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		window_has_focus = false
	
	if not window_has_focus and event.is_action_pressed("Mouse_left_button"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		window_has_focus = true


func setup_input() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
