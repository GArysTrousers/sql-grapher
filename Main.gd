extends Control


func _ready():
	_on_GoToGrapher_pressed()
	var flavour_selector = get_node('%Flavours')
	for f in Sql.flavour_names:
		flavour_selector.add_item(f)


func _on_GoToGrapher_pressed():
	$Grapher.show()
	$Comparator.hide()


func _on_GoToComparator_pressed():
	$Grapher.hide()
	$Comparator.show()

		
func _on_Flavours_item_selected(index):
	$Contribute.popup_centered()
