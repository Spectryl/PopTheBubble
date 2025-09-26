extends Control

enum MenuID {
	TITLE_SCREEN = 0,
	CONTROLS = 1,
	OPTIONS = 2,
	CREDITS = 3,
	EXTRAS = 4,
}

var current_menu : Control

func switch_menu(NewMenuID: MenuID) -> void:
	current_menu.queue_free()
	match NewMenuID:
		MenuID.TITLE_SCREEN:
			pass
		MenuID.CONTROLS:
			pass
		MenuID.OPTIONS:
			pass
		MenuID.CREDITS:
			pass
		MenuID.EXTRAS:
			pass
	call_deferred("add_child", current_menu)

func _on_play_button_pressed() -> void:
	get_parent().switch_scene(GameMaster.GameActivity.GAME)
func _on_options_button_pressed() -> void:
	switch_menu(MenuID.OPTIONS)
func _on_credits_button_pressed() -> void:
	switch_menu(MenuID.CREDITS)
func _on_quit_button_pressed() -> void:
	get_tree().quit()
