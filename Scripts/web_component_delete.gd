extends Node
func _ready() -> void:
	if OS.has_feature("web"): 
		get_parent().call_deferred("queue_free")
	call_deferred("queue_free")