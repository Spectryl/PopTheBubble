class_name Player
extends CharacterBody2D
@export var SPEED : int
@export var ACCELERATION : int
@export var FRICTION : int
@export var JUMP_POWER : int
@export var FAST_FALL_SPEED : int
var GRAVITY : int = ProjectSettings.get_setting("physics/2d/default_gravity")

# States
var is_dead : bool
var is_invincible : bool
var is_jumping : bool
var is_falling : bool
@export var is_attacking : bool
var looking_left : bool
var looking_right : bool
var on_attack_cooldown : bool = false
var is_poking : bool
var on_poke_cooldown : bool = false

var health : int = 100
var max_health : int 

@onready var WORLD = get_parent()
@onready var ANIMATION_PLAYER = $AnimationPlayer
@onready var ANIMATION_TREE: AnimationTree = $AnimationTree
@onready var RIG			  = $Rig
@onready var ATTACKCDTIMER	= $AttackCooldownTimer
@onready var NEEDLECDTIMER  = $NeedleCoolDownTImer
const BUBBLES_SCENE = preload("res://Scenes/bubble.tscn")
const NEEDLE_SCENE  = preload("res://Scenes/needle.tscn")




func _physics_process(delta: float) -> void:
	if is_dead: return
	handle_gravity(delta)
	handle_landing()
	handle_player_movement(delta)
	handle_player_attacks()
	handle_player_animation()
	move_and_slide()
func handle_gravity(delta: float) -> void:
	if not is_on_floor(): velocity.y += GRAVITY * delta
func handle_player_movement(delta: float) -> void:
	var direction = Input.get_axis("MoveLeft", "MoveRight")
	if direction != 0: velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION * delta)
	else: velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
	looking_left = velocity.x < 0
	looking_right = !looking_left
	handle_player_jump()
func handle_player_jump() -> void:
	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_POWER * -1
		is_jumping = true
		if not (ANIMATION_PLAYER.current_animation == "attacking" or ANIMATION_PLAYER.current_animation == "attacking_needle"): 
			ANIMATION_PLAYER.play("jump_squat")
			SoundMaster.play(SoundMaster.SFX.JUMPING)
	# Short Hop/Cancel Jump
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0
		is_jumping = false
		is_falling = true
		if not (ANIMATION_PLAYER.current_animation == "attacking" or ANIMATION_PLAYER.current_animation == "attacking_needle"): ANIMATION_PLAYER.play("falling")
	if velocity.y > 0 and not is_falling and not is_on_floor():
		is_falling = true
		if not (ANIMATION_PLAYER.current_animation == "attacking" or ANIMATION_PLAYER.current_animation == "attacking_needle"): ANIMATION_PLAYER.play("falling")
func handle_landing() -> void:
	if Input.is_action_pressed("MoveDown"):
		velocity.y += FAST_FALL_SPEED
	if is_on_floor() and is_falling:
		is_jumping = false
		is_falling = false
		if not (ANIMATION_PLAYER.current_animation == "attacking" or ANIMATION_PLAYER.current_animation == "attacking_needle"): 
			ANIMATION_PLAYER.play("landing")
			SoundMaster.play(SoundMaster.SFX.LANDING)
	
func handle_player_attacks() -> void:
	if Input.is_action_pressed("Attack") and on_poke_cooldown == false:
		ANIMATION_PLAYER.play("attacking_needle")
		on_poke_cooldown = true
		NEEDLECDTIMER.start()
		SoundMaster.play(SoundMaster.SFX.ATTACKING)
	if Input.is_action_just_pressed("Bubbles") and on_attack_cooldown == false:
		ANIMATION_PLAYER.play("attacking")
		on_attack_cooldown = true
		ATTACKCDTIMER.start()
		SoundMaster.play(SoundMaster.SFX.ATTACKING)
func create_bubble() -> void:
	var new_bubble = BUBBLES_SCENE.instantiate()
	new_bubble.global_position = global_position
	WORLD.add_child(new_bubble)
	
	var shoot_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	if shoot_direction == Vector2.ZERO:
		shoot_direction = Vector2(-1,0) if looking_left else Vector2(1,0)
	new_bubble.apply_central_impulse(shoot_direction * new_bubble.BUBBLE_SPEED)

func create_needle() -> void:
	var new_needle = NEEDLE_SCENE.instantiate()
	new_needle.global_position = global_position
	new_needle.global_position.y -= 50
	WORLD.add_child(new_needle)
	
	var shoot_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	if shoot_direction == Vector2.ZERO:
		shoot_direction = Vector2(-1,0) if looking_left else Vector2(1,0)
	new_needle.scale.x = -1 if shoot_direction.x == -1 else 1
	new_needle.apply_central_impulse(shoot_direction * new_needle.NEEDLE_SPEED)
	

func handle_player_animation() -> void:
	RIG.scale.x = .25 if looking_left else -.25
	if not is_jumping and not is_falling and not (ANIMATION_PLAYER.current_animation == "attacking" or ANIMATION_PLAYER.current_animation == "attacking_needle"):
		if abs(velocity.x) > 1 and is_on_floor():ANIMATION_PLAYER.play("walking")
		else:ANIMATION_PLAYER.play("idle")
	##ANIMATION_PLAYER.play("idle")
	##if is_jumping:
		##if velocity.y < 0: ANIMATION_PLAYER.play("jumping")
		##if velocity.y > 0: ANIMATION_PLAYER.play("falling")

func _on_attack_cooldown_timer_timeout() -> void:
	on_attack_cooldown = false
func _on_needle_cool_down_t_imer_timeout() -> void:
	on_poke_cooldown = false

func take_poison_damage(damage_taken : int) -> void:
	health -= damage_taken
	SoundMaster.play(SoundMaster.SFX.HURT)
	if health <= 0:
		take_death()

func take_death() -> void:
	is_dead = true
	$CPUParticles2D.emitting = true
	$Rig.visible = false
	$CollisionShape2D.set_deferred("disabled",true)
	get_parent().get_node("CanvasLayer1").visible = false
	get_parent().get_node("CanvasLayer2").visible = true
