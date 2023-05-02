extends TextEdit

var command_keywords = [
	"CREATE",
	"DATABASE",
	"TABLE",
	"USE"
]
var key_keywords = [
	"KEY",
	"PRIMARY",
	"UNIQUE",
	"FOREIGN",
]

var command_color = Color('#7bdedc')
var key_color = Color('#ca74e6')
var name_color = Color('#ffffff')
var comment_color = Color('#666666')


# Called when the node enters the scene tree for the first time.
func _ready():
	syntax_highlighting = true
	
	for k in command_keywords:
		add_keyword_color(k, command_color)
	for k in key_keywords:
		add_keyword_color(k, key_color)
		
	add_color_region('`', '`', name_color, false)
	add_color_region('/*', '*/', comment_color, false)
	add_color_region('--', '', comment_color, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
