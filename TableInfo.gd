extends PanelContainer


var data

func _ready():
	pass # Replace with function body.


func init(table, add_to_col_node_group:bool = false):
	data = table
	get_node("%TableName").text = data.name
	for col in data.cols:
		var l = preload("res://graph/ColumnNode.tscn").instance()
		l.init(col, add_to_col_node_group)
		get_node("%Columns").add_child(l)

func set_type_visible(value:bool):
	for c in $List/Columns.get_children():
		c.set_type_visible(value)
