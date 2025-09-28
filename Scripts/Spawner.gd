class_name Spawner
extends Node

var spawn_timer : Timer

@export var wait_time : float = 7

func _ready() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = wait_time
	spawn_timer.timeout.connect(spawn_new_enemy)
	spawn_timer.start(1)
	spawn_timer.wait_time = wait_time
	
func spawn_new_enemy() -> void:
	push_error("Function spawn_new_enemy is not implemented")