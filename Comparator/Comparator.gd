extends Control


func _ready():
	$Input/Input.connect("databases_imported", $Analise/Analiser, "set_databases")
