extends Control
signal databases_imported(db1, db2)


func _ready():
	call_deferred("import")
	
func import():
	var db1 = parse_input($Database1/SqlInput.text)
	var db2 = parse_input($Database2/SqlInput.text)
	
	emit_signal("databases_imported", 
	$Database1/Name.text, db1[0], 
	$Database2/Name.text, db2[0])

func parse_input(text):
	text = Sql.clean_input(text)
	var commands = Sql.split_input_to_commands(text)
	var db_list = Sql.create_db_from_commands(commands)
	return db_list


func _on_Import_pressed():
	import()
