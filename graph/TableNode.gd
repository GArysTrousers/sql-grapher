extends RigidBody2D

var data:Sql.Table

var grabbed:bool = false

func init(table):
	data = table
	
func _ready():
	$TableInfo.init(data)
	
	yield(get_tree(), "idle_frame")
	$CollisionShape2D.shape.extents = $TableInfo.rect_size / 2
	
func _physics_process(delta):
	if grabbed:
		if !Input.is_action_pressed("left_click"):
			grabbed = false
		apply_central_impulse(get_global_mouse_position() - global_position)

func _integrate_forces(state):
	if mode == MODE_CHARACTER:
		rotation = 0


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
