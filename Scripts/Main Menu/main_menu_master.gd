extends Control

@onready var play_button : Button = $MarginContainer/VBoxContainer/PlayButton
@onready var options_button : Button = $MarginContainer/VBoxContainer/OptionsButton
@onready var credits_button : Button = $MarginContainer/VBoxContainer/CreditsButton
@onready var quit_button : Button	= $MarginContainer/VBoxContainer/QuitButton

enum MenuID {
	TITLE_SCREEN = 0,
	CONTROLS = 1,
	OPTIONS = 2,
	CREDITS = 3,
	EXTRAS = 4,
}
	
var current_menu : Control

const HOVER_SCALE = Vector2(1.1, 1.1)
const DEFAULT_SCALE = Vector2(1.0,1.0)
const TWEEN_DURATION = .15

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


func _tween_button_scale(button: Control, target_scale: Vector2, reset_z: bool = false) -> void:
	var existing_tween = button.get_meta("current_tween", null)
	if existing_tween:
		existing_tween.kill()
	var tween = create_tween()
	button.set_meta("current_tween", tween)
	tween.tween_property(
		button, 
		"scale", 
		target_scale, 
		TWEEN_DURATION
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if reset_z:
		tween.finished.connect(func(): button.z_index = 0)
	else:
		button.z_index = 1
func _on_play_button_mouse_entered() -> void:
	_tween_button_scale(play_button, HOVER_SCALE)
func _on_play_button_mouse_exited() -> void:
	_tween_button_scale(play_button, DEFAULT_SCALE, true)
func _on_options_button_mouse_entered() -> void:
	_tween_button_scale(options_button, HOVER_SCALE)
func _on_options_button_mouse_exited() -> void:
	_tween_button_scale(options_button, DEFAULT_SCALE, true) 
func _on_credits_button_mouse_entered() -> void:
	_tween_button_scale(credits_button, HOVER_SCALE)
func _on_credits_button_mouse_exited() -> void:
	_tween_button_scale(credits_button, DEFAULT_SCALE, true)
func _on_quit_button_mouse_entered() -> void:
	_tween_button_scale(quit_button, HOVER_SCALE)
func _on_quit_button_mouse_exited() -> void:
	_tween_button_scale(quit_button, DEFAULT_SCALE, true)