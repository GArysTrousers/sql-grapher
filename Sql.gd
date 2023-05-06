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


# Data classes
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
		
