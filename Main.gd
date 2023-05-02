extends Control

func _ready():
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
					var db = Database.new().parse(c)
					db_list.append(db)
				"USE":
					var db_name = parse_use(c)
					for i in db_list.size():
						if db_list[i].name == db_name:
							selected_db_index = i
							break
				"CREATE TABLE":
					if selected_db_index >= 0:
						var table = Table.new().parse(c)
						db_list[selected_db_index].tables.append(table)
	
	var output = ""
	for db in db_list:
		output += db.to_string()
	get_node("%ParserOutput").text = output

func parse_use(command:String):
	var re = RegEx.new()
	re.compile('USE `(.+)`')
	return re.search(command).get_string(1)
	
class Database:
	var name:String
	var tables:Array = []
	
	func parse(command:String) -> Database:
		var res = Sql.parse(command, Sql.CreateDatabase)
		name = res.get_string("name")
		return self
	
	func _to_string():
		var tbs = ""
		for t in tables:
			tbs += t.to_string() + '\n'
		var output = "Name: %s\n%s" % [name, tbs]
		return output
		
class Table:
	var name:String
	var cols:Array = []
	
	func parse(command:String) -> Table:
		var res = Sql.parse(command, Sql.CreateTable)
		name = res.get_string("name")
		var cols_commands = res.get_string("cols").split(',')
		
		for c in cols_commands:
			if Sql.parse(c, Sql.CreateColumn):
				cols.append(Column.new().parse(c))
			elif Sql.parse(c, Sql.SetPrimaryKey):
				add_primary_key(c)
			elif Sql.parse(c, Sql.SetUniqueKey):
				add_unique_key(c)
			elif Sql.parse(c, Sql.SetForeignKey):
				add_foreign_key(c)
		return self
	
	func add_primary_key(command):
		var res = Sql.parse(command, Sql.SetPrimaryKey)
		if res:
			var col = res.get_string('name')
			for c in cols.size():
				if cols[c].name == col:
					cols[c].primary_key = true
					return
	
	func add_unique_key(command):
		var res = Sql.parse(command, Sql.SetUniqueKey)
		if res:
			var col = res.get_string('name')
			for c in cols.size():
				if cols[c].name == col:
					cols[c].unique_key = true
					return
	
	func add_foreign_key(command):
		var res = Sql.parse(command, Sql.SetForeignKey)
		if res:
			var local_key = res.get_string('l_key')
			var foreign_table = res.get_string('f_table')
			var foreign_key = res.get_string('f_key')
			for c in cols.size():
				if cols[c].name == local_key:
					cols[c].foreign_key = ForeignKey.new(foreign_table, foreign_key)
		
	func _to_string():
		var cols_str = ""
		for c in cols:
			cols_str += c.to_string() + '\n'
		var output = "%s (\n%s)" % [name, cols_str]
		return output

class Column:
	var name:String
	var type:String
	var primary_key:bool
	var unique_key:bool
	var foreign_key:ForeignKey
	
	func parse(command:String) -> Column:
		var re = RegEx.new()
		var res
		res = Sql.parse(command, Sql.CreateColumn)
		name = res.get_string("name")
		type = res.get_string("type")
		return self
		
	func _to_string():
		var output = "\t%s: %s" % [name, type]
		if primary_key:
			output += " PK"
		if unique_key:
			output += " UNIQUE"
		if foreign_key:
			output += " FK %s(%s)" % [foreign_key.table_name, foreign_key.col_name]
		return output
		
		
class ForeignKey:
	var table_name:String
	var col_name:String
		
	func _init(t, c):
		table_name = t
		col_name = c
		
		
		
		
		
