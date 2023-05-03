extends Node2D

onready var Tables = $Tables 

var active:bool = true
var lock_rotation = true

var connections = []
var force:Vector2
var force_magnitude:float = 0.5

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if active:
		for con in connections:
			force = con.get_force()
			con.a.apply_central_impulse(force * force_magnitude)
			con.b.apply_central_impulse(-force * force_magnitude)
		update()
	
func _draw():
	for con in connections:
		draw_line(con.a.position, con.b.position, Color.white, 3, true)
		
func set_database(db:Sql.Database):
	var table_map = {}
	for i in db.tables.size():
		var t = preload("res://graph/TableNode.tscn").instance()
		t.init(db.tables[i])
		Tables.add_child(t)
		t.position.x = i * 100
		t.position.y = rand_range(-50, 50)
		table_map[db.tables[i].name] = t
	
	for table in db.tables:
		for col in table.cols:
			if col.foreign_key:
				make_connection(
					table_map[table.name],
					table_map[col.foreign_key.table_name],
					300
				)

func make_connection(a, b, dist, remove_if_exists:bool = false):
	if !a or !b:
		return
	for con in connections:
		if con.is_same(a, b):
			if remove_if_exists:
				connections.erase(con)
			return
	connections.append(Connection.new(a, b, dist))

func _on_LockRotation_pressed():
	if get_node("%LockRotation").pressed:
		print("locked")
		for t in get_tree().get_nodes_in_group("table_nodes"):
			t.mode = RigidBody2D.MODE_CHARACTER
			t.rotation = 0
	else:
		print("unlocked")
		for t in get_tree().get_nodes_in_group("table_nodes"):
			t.mode = RigidBody2D.MODE_RIGID

class Connection:
	var a:Node2D
	var b:Node2D
	var dist:float
	func _init(a:Node2D, b:Node2D, dist:float):
		self.a = a
		self.b = b
		self.dist = dist
	
	func get_force():
		return a.position.direction_to(b.position) * (a.position.distance_to(b.position) - dist)
	func is_same(a, b):
		return (self.a == a && self.b == b) || (self.b == a && self.a == b)
