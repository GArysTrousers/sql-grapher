extends Control


func set_databases(name1:String, db1:Sql.Database, name2:String, db2:Sql.Database):
	var tables = []
	for t in db1.tables:
		tables.append(t.name)
	for t in db2.tables:
		if !tables.has(t.name):
			tables.append(t.name)
	
	add_db_names(name1, name2)
	
	for t_name in tables:
		if db1.get_table(t_name):
			var t = preload("res://TableInfo.tscn").instance()
			$Scroll/Tables.add_child(t)
			t.init(db1.get_table(t_name))
			t.set_type_visible(true)
		else:
			var l = Label.new()
			l.text = "No table named '%s'" % t_name
			$Scroll/Tables.add_child(l)
			
		if db2.get_table(t_name):
			var t = preload("res://TableInfo.tscn").instance()
			$Scroll/Tables.add_child(t)
			t.init(db2.get_table(t_name))
			t.set_type_visible(true)
		else:
			var l = Label.new()
			l.text = "No table named '%s'" % t_name
			$Scroll/Tables.add_child(l)

func add_db_names(n1, n2):
	var l1 = Label.new()
	l1.text = n1
	l1.align = Label.ALIGN_CENTER
	$Scroll/Tables.add_child(l1)
	
	var l2 = Label.new()
	l2.text = n2
	l2.align = Label.ALIGN_CENTER
	$Scroll/Tables.add_child(l2)
