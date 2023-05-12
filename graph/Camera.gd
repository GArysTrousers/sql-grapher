extends Camera2D

var move_input:Vector2
onready var target_position:Vector2 = position
onready var target_zoom:Vector2 = zoom
onready var graph = get_parent()

func _process(delta):
	move_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position = position.linear_interpolate(target_position, delta * 10)
	zoom = zoom.linear_interpolate(target_zoom, delta * 10)

func _unhandled_input(event):
	if graph.active:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP:
				target_zoom /= 1.1
				target_position -= 0.1 * ((get_viewport_rect().size / 2) - get_viewport().get_mouse_position()) * zoom
			elif event.button_index == BUTTON_WHEEL_DOWN:
				target_zoom *= 1.1
				target_position += 0.1 * ((get_viewport_rect().size / 2) - get_viewport().get_mouse_position()) * zoom
		elif event is InputEventMouseMotion:
			if Input.is_action_pressed("right_click"):
				target_position += -event.relative * zoom
