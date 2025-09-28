class_name OrangeBubble
extends RigidBody2D 

@export var BUBBLE_SPEED : int
@export var POISON_DAMAGE : int
@export var POISON_INTERVAL : float = 0.5 
@export var TIMER_LENGTH : float
@export var DELETE_TIMER_LENGTH : float

@onready var sprite = get_node("Sprite2D")
var active_timer : Timer
var delete_timer : Timer

var bodies_inside: Array[Node] = []
var time_since_last_damage: float = 0.0

func _ready() -> void:
	active_timer = Timer.new()
	active_timer.wait_time = TIMER_LENGTH
	active_timer.one_shot = true
	add_child(active_timer)
	active_timer.timeout.connect(_on_active_timer_timeout)
	active_timer.start()
	
	delete_timer = Timer.new()
	delete_timer .wait_time = DELETE_TIMER_LENGTH
	delete_timer .one_shot = true
	add_child(delete_timer)
	delete_timer .timeout.connect(_on_delete_timer_timeout)
	active_timer.start()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not bodies_inside.has(body):
		bodies_inside.append(body)

func _on_body_exited(body: Node) -> void:
	if bodies_inside.has(body):
		bodies_inside.erase(body)

func _process(delta: float) -> void:
	time_since_last_damage += delta

	if time_since_last_damage >= POISON_INTERVAL:
		for body in bodies_inside:
			if body != null:
				body.take_poison_damage(POISON_DAMAGE) 
		time_since_last_damage = 0.0
# Trashfish code : D
func _on_active_timer_timeout() -> void:
	$CPUParticles2D.emitting = true
	$Sprite2D.visible = false
	freeze = true
	delete_timer.start()
func _on_delete_timer_timeout() -> void:
	call_deferred("queue_free")
