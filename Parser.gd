extends Control

signal database_imported(db_list)

func _ready():
	call_deferred("parse_input")


func _on_Import_pressed():
	parse_input()


func parse_input():
	var text = get_node("%SqlInput").text
	text = Sql.clean_input(text)
	get_node("%CleanerOutput").text = text
	
	var commands = Sql.split_input_to_commands(text)
	var db_list = Sql.create_db_from_commands(commands)
	
	var output = ""
	for db in db_list:
		output += db.to_string()
	get_node("%ParserOutput").text = output
	
	emit_signal("database_imported", db_list)




func _on_Debug_toggled(button_pressed):
	get_node("%CleanerOutput").visible = button_pressed


func _on_LinkButton_pressed():
	OS.shell_open("https://github.com/GArysTrousers/sql-grapher")
