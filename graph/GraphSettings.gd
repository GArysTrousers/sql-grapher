extends VBoxContainer

var attraction_forces = true
var repulsion_forces = true
var lock_rotation = true
var show_fk_labels = false
var show_data_types = false
var distance_multiplier = 1

func _ready():
	$AttractionForces.pressed = attraction_forces
	$RepulsionForces.pressed = repulsion_forces
	$LockRotation.pressed = lock_rotation
	$ShowFkLabels.pressed = show_fk_labels
	$ShowDataTypes.pressed = show_data_types
	$DistanceMultiplier.value = distance_multiplier
	
	_on_GraphSettings_mouse_exited()

func _on_GraphSettings_mouse_entered():
	modulate.a = 1

func _on_GraphSettings_mouse_exited():
	modulate.a = 0.2


func _on_AttractionForces_toggled(button_pressed):
	attraction_forces = button_pressed


func _on_RepulsionForces_toggled(button_pressed):
	repulsion_forces = button_pressed


func _on_LockRotation_toggled(button_pressed):
	if button_pressed:
		for t in get_tree().get_nodes_in_group("table_nodes"):
			t.mode = RigidBody2D.MODE_CHARACTER
	else:
		for t in get_tree().get_nodes_in_group("table_nodes"):
			t.mode = RigidBody2D.MODE_RIGID

func _on_ShowFkLabels_toggled(button_pressed):
	show_fk_labels = button_pressed
	
func _on_ShowDataTypes_toggled(button_pressed):
	show_data_types = button_pressed
	for c in get_tree().get_nodes_in_group("col_nodes"):
		c.set_type_visible(button_pressed)
	
func _on_DistanceMultiplier_value_changed(value):
	distance_multiplier = value




