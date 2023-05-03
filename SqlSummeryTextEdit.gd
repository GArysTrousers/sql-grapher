extends TextEdit

var datatypes = [
	"int",
	"varchar",
	"decimal",
	"date",
	"time",
	"datetime",
]

var words = {
	'PK': Palette.yellow,
	'FK': Palette.green,
	'UNIQUE': Palette.purple,
}

func _ready():
	syntax_highlighting = true
	
	add_color_region('	', ':', Palette.white, false)

	for i in datatypes:
		add_keyword_color(i, Palette.gray)
	for w in words:
		add_keyword_color(w, words[w])
	
	add_color_override("number_color", Palette.purple)
	add_color_override("function_color", Palette.cyan)
