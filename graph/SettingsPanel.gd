extends PanelContainer


func _ready():
	_on_SettingsPanel_mouse_exited()


func _on_SettingsPanel_mouse_entered():
	self_modulate.a = 0.9


func _on_SettingsPanel_mouse_exited():
	self_modulate.a = 0
