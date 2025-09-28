extends RigidBody2D
@export var NEEDLE_SPEED : int

func _on_timer_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("OrangeBubble"):
		body._on_active_timer_timeout()
		
