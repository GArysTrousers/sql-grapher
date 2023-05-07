extends Control


func _ready():
	$TabContainer/Parser.connect("database_imported", $TabContainer/Graph/GraphHolder/Viewport/Graph, "import_database")


