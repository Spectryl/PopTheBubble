extends Node2D

var enemies_left : int = 25




func _on_quit_button_pressed() -> void:
	get_parent().switch_scene(GameMaster.GameActivity.MAIN_MENU)


func _on_play_again_button_pressed() -> void:
	get_parent().switch_scene(GameMaster.GameActivity.GAME)
