extends VBoxContainer

var connection_forces = true
var lock_rotation = true
var distance_multiplier = 1

func _ready():
	$ConnectionForces.pressed = connection_forces
	$LockRotation.pressed = lock_rotation
	$DistanceMultiplier.value = distance_multiplier

func _on_ConnectionForces_pressed():
	connection_forces = $ConnectionForces.pressed

func _on_LockRotation_pressed():
	if $LockRotation.pressed:
		for t in get_tree().get_nodes_in_group("table_nodes"):
			t.mode = RigidBody2D.MODE_CHARACTER
	else:
		for t in get_tree().get_nodes_in_group("table_nodes"):
			t.mode = RigidBody2D.MODE_RIGID


func _on_DistanceMultiplier_value_changed(value):
	distance_multiplier = value
