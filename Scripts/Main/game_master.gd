class_name GameMaster extends Node



var current_scene : Node
var current_activity : GameActivity
enum GameActivity {
	MAIN_MENU = 0,
	GAME = 1,
}

func _ready() -> void:
	switch_scene(GameActivity.MAIN_MENU)

func switch_scene(NewActiviy : GameActivity) -> void:
	if current_scene != null: 
		current_scene.call_deferred("queue_free")
		
	match NewActiviy:
		GameActivity.MAIN_MENU:
			current_scene = load("res://Scenes/Main Menu/MainMenuMaster.tscn").instantiate()
			current_activity = GameActivity.MAIN_MENU
		GameActivity.GAME:
			current_scene = load("res://Scenes/Main Menu/MainMenuMaster.tscn").instantiate()
			current_activity = GameActivity.GAME
	add_child(current_scene)
	
