extends ViewportContainer

onready var viewport = $Viewport
onready var tab = get_parent()

func _ready():
	get_tree().connect("screen_resized", self, "on_resized")
	get_parent().connect("visibility_changed", self, "on_resized")
	set_viewport_size()
	_on_Graph_visibility_changed()

func set_viewport_size():
	yield(get_tree(), "idle_frame")
	viewport.size = rect_size

func on_resized():
	if viewport:
		viewport.size = Vector2(1,1)
		call_deferred("set_viewport_size")

func _input(event:InputEvent):
	if tab.visible:
		var e = event.duplicate(true)
		if e is InputEventMouse:
			e.position -= rect_global_position
		viewport.unhandled_input(e)


func _on_Graph_visibility_changed():
	$Viewport/Graph.active = tab.visible
	viewport.gui_disable_input = !tab.visible
