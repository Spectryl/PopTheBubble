extends Control
@onready var master_bus_index : int = AudioServer.get_bus_index("Master")


func _on_sound_slider_value_changed(value : float) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))


func _on_button_pressed() -> void:
	get_parent().switch_menu(get_parent().MenuID.TITLE_SCREEN)
