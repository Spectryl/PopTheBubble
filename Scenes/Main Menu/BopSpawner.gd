extends Node
const BOP_SCENE = preload("res://Scenes/Bop.tscn")
@onready var WORLD = get_parent()
var current_wave : int = 1
var enemies_needed_to_die = -1
func spawn_new_enemy() -> void:
	var new_enemy 

	for i in range(current_wave):
		new_enemy = BOP_SCENE.instantiate()
		new_enemy.global_position = Vector2(randi_range(1000,3000), 385)
		new_enemy.health = 100 + randi_range(current_wave * 10, current_wave * 20)
		SoundMaster.play(SoundMaster.SFX.TELEPORT)
		WORLD.add_child(new_enemy)
	enemies_needed_to_die = current_wave
	current_wave += 1

func _physics_process(delta: float) -> void:
	get_parent().get_node("CanvasLayer").get_node("Label2").text = "Enemies Left: %d" % enemies_needed_to_die
	if enemies_needed_to_die <= 0:
		spawn_new_enemy()
		# sloppy code but time crunch...
		get_parent().get_node("CanvasLayer").get_node("Label").text = "Wave: %d" % (current_wave - 1)
	
		
	