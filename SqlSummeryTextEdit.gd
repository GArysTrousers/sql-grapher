extends TextEdit

const colors = {
	'white': Color('#ffffff'),
	'gray': Color('#bbbbbb'),
	'yellow': Color('#f7e476'),
	'purple': Color('#ca74e6'),
	'green': Color('#a1e55a'),
	'blue': Color('#accce4'),
	'cyan': Color('#7bdedc'),
	'orange': Color('#ffc384'),
}

var command_color = Color('#7bdedc')
var key_color = Color('#ca74e6')
var name_color = Color('#ffffff')
var comment_color = Color('#666666')
var datatype_color = Color('#7bdedc')
var table_color = Color('#cb4d68')

var datatypes = [
	"int",
	"varchar",
	"decimal",
	"date",
	"time",
	"datetime",
]

var words = {
	'PK': colors.yellow,
	'FK': colors.green,
	'UNIQUE': colors.purple,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	syntax_highlighting = true
	
	add_color_region('	', ':', colors.white, false)

	for i in datatypes:
		add_keyword_color(i, colors.gray)
	for w in words:
		add_keyword_color(w, words[w])
	
	add_color_override("number_color", key_color)
	add_color_override("function_color", colors.cyan)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
