# Ill keep it a buck-fifty.  I A.I. this part because I could not get the nav agent to work with this and I don't get this schizo code

extends CharacterBody2D

@export var SPEED : float = 300.0
@export var ACCELERATION : float = 20.0
@export var FRICTION : float = 25.0
@export var JUMP_POWER : int = 800
@export var FAST_FALL_SPEED : int = 1500
var GRAVITY : int = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dead : bool
var is_invincible : bool
var is_jumping : bool
var is_falling : bool
@export var is_attacking : bool
var looking_left : bool = true
var looking_right : bool = false
var on_attack_cooldown : bool = false

@export var health : float = 100
var max_health : int 

const PATH_POINT_RADIUS = 30.0 
const JUMP_THRESHOLD = 50.0 
const DROP_THRESHOLD = 75.0 
var target_node: CharacterBody2D 
var delete_timer : Timer
@onready var WORLD = get_parent()
@onready var ANIMATION_PLAYER = $AnimationPlayer
@onready var ANIMATION_TREE: AnimationTree = $AnimationTree
@onready var RIG            = $Rig
@onready var ATTACKCDTIMER  = $AttackCooldownTimer
@onready var NAV_AGENT: NavigationAgent2D = $NavigationAgent2D 
const BUBBLES_SCENE = preload("res://Scenes/orange_bubble.tscn")

enum EnemyStates {
	SEARCHING,
	HUNTING,
	EVADING,
	STALKING
}

var current_state : EnemyStates = EnemyStates.SEARCHING
var current_search_place : Vector2 = Vector2.ZERO

func _ready() -> void:
	target_node = WORLD.get_node_or_null("Player") 
	
	if target_node:
		current_state = EnemyStates.HUNTING
		
	current_search_place = global_position
	
	NAV_AGENT.avoidance_enabled = true
	delete_timer = Timer.new()
	delete_timer .wait_time = 1.01
	delete_timer .one_shot = true
	add_child(delete_timer)
	delete_timer .timeout.connect(_on_delete_timer_timeout)


func _physics_process(delta: float) -> void:
	if is_dead: return
	handle_gravity(delta)
	handle_landing()
	
	match current_state:
		EnemyStates.SEARCHING:
			search_for_player(delta)
		EnemyStates.HUNTING:
			hunt_target(delta) 
			handle_enemy_attacks()
		EnemyStates.EVADING:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		EnemyStates.STALKING:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
			
	handle_enemy_animation()
	move_and_slide()

func search_for_player(delta) -> void:
	if NAV_AGENT.is_navigation_finished() or global_position.distance_to(current_search_place) < PATH_POINT_RADIUS * 2:
		current_search_place = Vector2(randi_range(0,4000), randi_range(0,2000))
		NAV_AGENT.target_position = current_search_place

	move_along_path(delta)

func hunt_target(delta) -> void:
	if not target_node or not is_instance_valid(target_node):
		current_state = EnemyStates.SEARCHING
		return

	NAV_AGENT.target_position = target_node.global_position
	
	move_along_path(delta)

func move_along_path(delta):
	if NAV_AGENT.is_navigation_finished():
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		return
		
	var next_point = NAV_AGENT.get_next_path_position()
	
	var direction_to_point = (next_point - global_position)
	
	var desired_velocity_x = 0.0
	
	if direction_to_point.x > PATH_POINT_RADIUS:
		desired_velocity_x = SPEED
		looking_right = true
		looking_left = false
	elif direction_to_point.x < -PATH_POINT_RADIUS:
		desired_velocity_x = -SPEED
		looking_left = true
		looking_right = false
	
	if desired_velocity_x != 0:
		velocity.x = lerp(velocity.x, desired_velocity_x, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		
	if is_on_floor() and direction_to_point.y < -JUMP_THRESHOLD:
		if abs(direction_to_point.x) < 200:
			velocity.y = -JUMP_POWER
			is_jumping = true
			is_falling = false
			
	elif is_on_floor() and direction_to_point.y > DROP_THRESHOLD:
		pass 
	
	elif is_on_floor() and global_position.distance_to(next_point) < PATH_POINT_RADIUS:
		velocity.x = 0.0

func handle_enemy_attacks() -> void:
	if target_node and global_position.distance_to(target_node.global_position) < 500:
		if on_attack_cooldown == false:
			velocity.x = 0
			
			ANIMATION_PLAYER.play("attacking")
			on_attack_cooldown = true
			ATTACKCDTIMER.start()
			SoundMaster.play(SoundMaster.SFX.ATTACKING)

func create_bubble() -> void:
	var new_bubble = BUBBLES_SCENE.instantiate()
	new_bubble.global_position = global_position
	WORLD.add_child(new_bubble)
	
	var shoot_direction = Vector2.ZERO
	if target_node and is_instance_valid(target_node):
		shoot_direction = (target_node.global_position - global_position).normalized()
	else:
		shoot_direction = Vector2(-1,0) if looking_left else Vector2(1,0)

	new_bubble.call("apply_central_impulse", shoot_direction * new_bubble.BUBBLE_SPEED)

func _on_attack_cooldown_timer_timeout() -> void:
	on_attack_cooldown = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_state = EnemyStates.HUNTING
		if not target_node:
			target_node = body
		print("found u")

func handle_gravity(delta: float) -> void:
	if not is_on_floor(): 
		velocity.y += GRAVITY * delta

func handle_landing() -> void:
	if is_on_floor():
		velocity.y = 0
		if is_falling:
			is_jumping = false
			is_falling = false
			if not ANIMATION_PLAYER.current_animation == "attacking": 
				ANIMATION_PLAYER.play("landing")
				SoundMaster.play(SoundMaster.SFX.LANDING)
	else:
		if velocity.y > 0 and not is_jumping:
			is_falling = true

func handle_enemy_animation() -> void:
	RIG.scale.x = .25 if looking_left else -.25
	if not is_jumping and not is_falling and not ANIMATION_PLAYER.current_animation == "attacking":
		if abs(velocity.x) > 1 and is_on_floor():ANIMATION_PLAYER.play("walking")
		else:ANIMATION_PLAYER.play("idle")

func take_poison_damage(damage_taken : int) -> void:
	health -= damage_taken
	if health <= 0:
		get_parent().get_node("BopSpawner").enemies_needed_to_die -= 1
		take_death()
func take_death() -> void:
	is_dead = true
	$CPUParticles2D.emitting = true
	$Rig.visible = false
	$CollisionShape2D.set_deferred("disabled",true)
	delete_timer.start()
func _on_delete_timer_timeout() -> void:
	call_deferred("queue_free")