extends Node

var flavour = Flavours.MySQL

enum Flavours {
	MySQL,
	PostgreSQL,
	SQLServer
}
const flavour_names = ["MySQL", "PostgreSQL", "SQL Server"]
	

enum {
	Command,
	CreateDatabase,
	CreateTable,
	CreateColumn,
	SetPrimaryKey,
	SetUniqueKey,
	SetForeignKey,
	NotSupportedColumns,
}

var patterns = {
	Flavours.MySQL: {
		Command: '^(?<command>CREATE TABLE|USE|CREATE DATABASE)',
		CreateDatabase: 'CREATE DATABASE (IF NOT EXISTS )?`(?<name>[^`]+)`',
		CreateTable: 'CREATE TABLE (IF NOT EXISTS)? `?(?<name>[^`]+)`?\\s*\\((?<cols>.+)\\)',
		CreateColumn: '^\\s*`?(?<name>[^\\s`]+)`? (?<type>[^(\\s]+)',
		SetPrimaryKey: '^\\s*PRIMARY KEY \\((?<names>(?>`[^`]+`\\|?)+)\\)',
		SetUniqueKey: '^\\s*UNIQUE KEY (`[^`]+`)? \\(`?(?<name>[^`]+)`?\\)',
		SetForeignKey: 'FOREIGN KEY \\(`?(?<l_key>[^`]+)`?\\) REFERENCES `?(?<f_table>[^`]+)`?\\s*\\(`?(?<f_key>[^`]+)`?\\)',
		NotSupportedColumns: '^\\s*(KEY|CONSTRAINT)',
	}
}

var active:Dictionary

func _ready():
	set_flavour(Flavours.MySQL)
	
func set_flavour(new_flavour):
	flavour = new_flavour
	active = {}
	for p in patterns[flavour]:
		active[p] = RegEx.new()
		active[p].compile(patterns[flavour][p])

func get(pattern) -> RegEx:
	return active[pattern]

func parse(command, pattern) -> RegExMatch:
	return get(pattern).search(command)


func clean_input(text:String) -> String:
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
	return text

func split_input_to_commands(text:String) -> PoolStringArray:
	var re = RegEx.new()
	# remove blank lines
	re.compile('\n')
	text = re.sub(text, '', true)
	# remove extra spaces
	re.compile(' {2,}')
	text = re.sub(text, ' ', true)
	
	return text.split(';')

func create_db_from_commands(commands:PoolStringArray) -> Array:
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
					var db_name = Sql.parse_use(c)
					for i in db_list.size():
						if db_list[i].name == db_name:
							selected_db_index = i
							break
				"CREATE TABLE":
					if selected_db_index >= 0:
						var table = Sql.Table.new().parse(c)
						db_list[selected_db_index].tables.append(table)
	return db_list
	

func parse_use(command:String):
	var re = RegEx.new()
	re.compile('USE `(.+)`')
	return re.search(command).get_string(1)

# Data classes
class Database:
	var name:String
	var tables:Array = []
	
	func parse(command:String) -> Database:
		var res = Sql.parse(command, Sql.CreateDatabase)
		name = res.get_string("name")
		return self
	
	func get_table(table_name:String):
		for t in tables:
			if t.name == table_name:
				return t
		return null
	
	func _to_string():
		var tbs = ""
		for t in tables:
			tbs += t.to_string() + '\n'
		var output = "Database: %s\n%s" % [name, tbs]
		return output
		

class Table:
	var name:String
	var cols:Array = []
	
	func parse(command:String) -> Table:
		var reg = RegEx.new()
		reg.compile("`,`")
		command = reg.sub(command, '`|`')
		var res = Sql.parse(command, Sql.CreateTable)
		name = res.get_string("name")
		var cols_commands = res.get_string("cols").split(',')
		
		for c in cols_commands:
			if Sql.parse(c, Sql.SetPrimaryKey):
				add_primary_key(c)
			elif Sql.parse(c, Sql.SetUniqueKey):
				add_unique_key(c)
			elif Sql.parse(c, Sql.SetForeignKey):
				add_foreign_key(c)
			elif Sql.parse(c, Sql.NotSupportedColumns):
				continue
			elif Sql.parse(c, Sql.CreateColumn):
				cols.append(Column.new().parse(c))
		return self
	
	func add_primary_key(command):
		var res = Sql.parse(command, Sql.SetPrimaryKey)
		if res:
			var col:String = res.get_string('names')
			col = col.replace('`', '')
			var pks = col.split('|')
			for c in cols.size():
				if pks.has(cols[c].name):
					cols[c].primary_key = true
	
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
		
