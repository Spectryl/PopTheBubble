extends Control


func _on_button_pressed() -> void:
	get_parent().switch_menu(get_parent().MenuID.TITLE_SCREEN)
