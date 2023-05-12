extends Control


func _ready():
	$Input/Input/Input.connect("databases_imported", $Compare/Analiser, "set_databases")


func _on_Import_pressed():
	pass # Replace with function body.
