extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(col:Sql.Column):
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Name.text = col.name
	if col.foreign_key:
		var fk = Label.new()
		fk.text = "FK"
		fk.add_color_override("font_color", Color.green)
		fk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fk)
