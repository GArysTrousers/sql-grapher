extends Node2D

onready var Tables = $Tables 
onready var GraphSettings = $UI/GraphSettings

var active:bool = true

var tables = []
var connections = []
var force:Vector2
var force_magnitude:float = 0.2
var fk_distance:float = 320
var fk_force:float = 0.2
var repel_distance:float = 250
var repel_force: float = 0.5

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if active:
		for a in tables:
			for b in tables:
				if a != b and a.position.distance_to(b.position) < repel_distance:
					a.apply_central_impulse(
						a.position.direction_to(b.position) 
						* (a.position.distance_to(b.position) - repel_distance * GraphSettings.distance_multiplier)
						* repel_force)
		if GraphSettings.connection_forces:
			for con in connections:
				force = con.get_force(fk_distance * GraphSettings.distance_multiplier)
				con.a.apply_central_impulse(force * force_magnitude)
				con.b.apply_central_impulse(-force * force_magnitude)
		update()
	
func _draw():
	for con in connections:
		draw_line(con.a.position, con.b.position, Palette.green, 3, true)
		var mid:Vector2 = con.mid_point()
		draw_colored_polygon([
			mid, 
			mid + 20 * con.a_to_b().rotated(PI * 0.8), 
			mid + 20 * con.a_to_b().rotated(PI * -0.8)], 
			Palette.green, PoolVector2Array(), null, null, true)
		
func set_database(db:Sql.Database):
	connections = []
	tables = []
	for t in $Tables.get_children():
		t.queue_free()
		
	var table_map = {}
	for i in db.tables.size():
		var t = preload("res://graph/TableNode.tscn").instance()
		t.init(db.tables[i])
		Tables.add_child(t)
		t.position.x = i * 100
		t.position.y = rand_range(-50, 50)
		table_map[db.tables[i].name] = t
		tables.append(t)
	
	for table in db.tables:
		for col in table.cols:
			if col.foreign_key:
				make_connection(
					table_map[table.name],
					table_map[col.foreign_key.table_name]
				)
	

func make_connection(a, b, remove_if_exists:bool = false):
	if !a or !b:
		return
	for con in connections:
		if con.is_same(a, b):
			if remove_if_exists:
				connections.erase(con)
			return
	connections.append(Connection.new(a, b))

class Connection:
	var a:Node2D
	var b:Node2D
	func _init(a:Node2D, b:Node2D):
		self.a = a
		self.b = b
	
	func get_force(dist):
		return a.position.direction_to(b.position) * (a.position.distance_to(b.position) - dist)
	func is_same(a, b):
		return (self.a == a && self.b == b) || (self.b == a && self.a == b)
	func mid_point():
		return (a.position + b.position) / 2
	func a_to_b():
		return a.position.direction_to(b.position)
