extends TabContainer

func _ready():
	$Parser.connect("database_imported", $Graph/GraphHolder/Viewport/Graph, "import_database")

