extends Control


func set_databases(name1:String, db1:Sql.Database, name2:String, db2:Sql.Database):
	add_db_names(name1, name2)
	
	for c in $Scroll/Tables.get_children():
		c.queue_free()
	var tables = []
	for t in db1.tables:
		tables.append(t.name)
	for t in db2.tables:
		if !tables.has(t.name):
			tables.append(t.name)
	
	for t_name in tables:
		var result = PoolStringArray()
		var result_label = Label.new()
		result_label.size_flags_horizontal = SIZE_EXPAND
		result_label.align = Label.ALIGN_CENTER
		result_label.valign = Label.VALIGN_CENTER
		
		var t1 = db1.get_table(t_name)
		var t2 = db2.get_table(t_name)
		if t1:
			var t = preload("res://TableInfo.tscn").instance()
			$Scroll/Tables.add_child(t)
			t.init(db1.get_table(t_name))
			t.set_type_visible(true)
		else:
			$Scroll/Tables.add_child(Label.new())
			result.append("No table named '%s' in %s" % [t_name, name1])
			
		if t2:
			var t = preload("res://TableInfo.tscn").instance()
			$Scroll/Tables.add_child(t)
			t.init(db2.get_table(t_name))
			t.set_type_visible(true)
		else:
			$Scroll/Tables.add_child(Label.new())
			result.append("No table named '%s' in %s" % [t_name, name2])
		
		if t1 and t2:
			result.append_array(compare_tables(t1, t2))
		
		result_label.text = result.join('\n')
		if result_label.text == "":
			result_label.text = "Match"
			
		$Scroll/Tables.add_child(result_label)

func add_db_names(n1, n2):
	var l1 = Label.new()
	l1.text = n1
	l1.align = Label.ALIGN_CENTER
	$Scroll/Tables.add_child(l1)
	
	var l2 = Label.new()
	l2.text = n2
	l2.align = Label.ALIGN_CENTER
	$Scroll/Tables.add_child(l2)
	
	var r = Label.new()
	r.text = "Results"
	r.align = Label.ALIGN_CENTER
	$Scroll/Tables.add_child(r)

func compare_tables(t1:Sql.Table, t2:Sql.Table) -> PoolStringArray:
	var result = PoolStringArray()
	var cols = []
	for c1 in t1.cols:
		var c2 = t2.get_col_by_name(c1.name)
		if !c2:
			result.append("Table 1 doesn't have column '%s'" % c1.name)
		elif c1.to_string() != c2.to_string():
			result.append("Column '%s' is different" % c1.name)
	for c2 in t2.cols:
		var c1 = t1.get_col_by_name(c2.name)
		if !c1:
			result.append("Table 1 doesn't have column '%s'" % c2.name)
	
	return result
	
