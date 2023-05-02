extends Node

var flavour = Flavours.MySQL

enum Flavours {
	MySQL
}
enum {
	Command,
	CreateDatabase,
	CreateTable,
	CreateColumn,
	SetPrimaryKey,
	SetUniqueKey,
	SetForeignKey,
}

var patterns = {
	Flavours.MySQL: {
		Command: '^(?<command>CREATE TABLE|USE|CREATE DATABASE)',
		CreateDatabase: 'CREATE DATABASE (IF NOT EXISTS )?`(?<name>[^`]+)`',
		CreateTable: 'CREATE TABLE (IF NOT EXISTS)? `(?<name>[^`]+)` \\((?<cols>.+)\\)',
		CreateColumn: '^\\s*`(?<name>.+)` (?<type>\\S+)',
		SetPrimaryKey: '^\\s*PRIMARY KEY \\(`?(?<name>[^`]+)`?\\)',
		SetUniqueKey: '^\\s*UNIQUE KEY (`[^`]+`)? \\(`?(?<name>[^`]+)`?\\)',
		SetForeignKey: 'FOREIGN KEY \\(`?(?<l_key>[^`]+)`?\\) REFERENCES `?(?<f_table>[^`]+)`?\\s*\\(`?(?<f_key>[^`]+)`?\\)'
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
