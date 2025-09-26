class_name Bubble
extends RigidBody2D

@export var BUBBLE_SPEED : int

@onready var sprite = get_node("Sprite2D")



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Poisonable"):
		pass
