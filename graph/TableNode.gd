extends RigidBody2D

var data:Sql.Table

var grabbed:bool = false

func init(table):
	data = table
	
func _ready():
	get_node("%TableName").text = data.name
	for col in data.cols:
		var l = Label.new()
		l.text = col.name
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		get_node("%Columns").add_child(l)
	
	yield(get_tree(), "idle_frame")
	$CollisionShape2D.shape.extents = $Info.rect_size / 2
	
func _physics_process(delta):
	if grabbed:
		if !Input.is_action_pressed("left_click"):
			grabbed = false
#		global_position = get_global_mouse_position()
		apply_central_impulse(get_global_mouse_position() - global_position)
	
func _on_Table_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				grabbed = true
			else:
				pass
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed:
				pass
			else:
				pass
