extends Control



enum MenuID {
	TITLE_SCREEN = 0,
	CONTROLS = 1,
	OPTIONS = 2,
	CREDITS = 3,
	EXTRAS = 4,
}
	
var current_menu : Control
var current_id   : MenuID


func _ready() -> void:
	current_menu = load("res://Scenes/Main Menu/title_screen.tscn").instantiate()
	add_child(current_menu)

func switch_menu(NewMenuID: MenuID) -> void:
	current_menu.queue_free()
	match NewMenuID:
		MenuID.TITLE_SCREEN:
			current_menu = load("res://Scenes/Main Menu/title_screen.tscn").instantiate()
		MenuID.CONTROLS:
			pass
		MenuID.OPTIONS:
			current_menu = load("res://Scenes/Main Menu/options.tscn").instantiate()
		MenuID.CREDITS:
			pass
		MenuID.EXTRAS:
			pass
	call_deferred("add_child", current_menu)




