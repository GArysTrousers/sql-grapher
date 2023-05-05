extends Control

func _ready():
	var flavour_selector = get_node('%Flavours')
	for f in Sql.flavour_names:
		flavour_selector.add_item(f)
	parse_input()


func _on_Import_pressed():
	parse_input()


func parse_input():
	var text = get_node("%SqlInput").text
	
	var re = RegEx.new()
	# remove line comments
	re.compile('--.+\n')
	text = re.sub(text, '\n', true)
	# remove inline comments
	re.compile('/[*].+[*]/')
	text = re.sub(text, '', true)
	# remove blank commands
	re.compile('\n;')
	text = re.sub(text, '\n', true)
	# remove blank lines
	re.compile('\n{2,}')
	text = re.sub(text, '\n\n', true)
	# remove first blank lines
	re.compile('^\n{2,}')
	text = re.sub(text, '', true)
	# remove decimal brackets
	re.compile('decimal\\(\\d+,\\d+\\)')
	text = re.sub(text, 'decimal()', true)
	
	get_node("%CleanerOutput").text = text
	
	# remove blank lines
	re.compile('\n')
	text = re.sub(text, '', true)
	# remove extra spaces
	re.compile(' {2,}')
	text = re.sub(text, ' ', true)
	
	var commands = text.split(';')
	
	var db_list = []
	var selected_db_index = -1
	for c in commands:
		var res = Sql.parse(c, Sql.Command)
		if res:
			match res.get_string('command'):
				"CREATE DATABASE":
					var db = Sql.Database.new().parse(c)
					db_list.append(db)
				"USE":
					var db_name = parse_use(c)
					for i in db_list.size():
						if db_list[i].name == db_name:
							selected_db_index = i
							break
				"CREATE TABLE":
					if selected_db_index >= 0:
						var table = Sql.Table.new().parse(c)
						db_list[selected_db_index].tables.append(table)
	
	var output = ""
	for db in db_list:
		output += db.to_string()
	get_node("%ParserOutput").text = output
	
	if db_list.size() > 0:
		$TabContainer/Graph/ViewportContainer/Viewport/Graph.set_database(db_list[0])

func parse_use(command:String):
	var re = RegEx.new()
	re.compile('USE `(.+)`')
	return re.search(command).get_string(1)

		
		
		
		


func _on_Flavours_item_selected(index):
	pass # Replace with function body.


func _on_Debug_toggled(button_pressed):
	get_node("%CleanerOutput").visible = button_pressed
