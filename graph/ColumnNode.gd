extends HBoxContainer

func init(col:Sql.Column):
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Info/Name.text = col.name
	$Info/DataType.text = ':' + col.type
	$Info/DataType.add_color_override("font_color", Palette.blue)
	if col.primary_key:
		add_tag("PK", Palette.yellow)
	if col.foreign_key:
		add_tag("FK", Palette.green)
	if col.unique_key:
		add_tag("UNQ", Palette.purple)

func add_tag(text:String, color:Color):
	var tag = Label.new()
	tag.text = text
	tag.add_color_override("font_color", color)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Tags.add_child(tag)

func set_type_visible(value):
	$Info/DataType.visible = value
