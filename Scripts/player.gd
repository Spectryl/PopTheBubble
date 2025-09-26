class_name Player
extends CharacterBody2D
@export var SPEED : int
@export var ACCELERATION : int
@export var FRICTION : int
@export var JUMP_POWER : int
var GRAVITY : int = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dead : bool
var is_invincible : bool
var is_jumping : bool
var is_attacking : bool

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_landing()
	handle_player_input(delta)
	move_and_slide()
func handle_gravity(delta: float) -> void:
	if not is_on_floor(): velocity.y += GRAVITY * delta
func handle_player_input(delta: float) -> void:
	var direction = Input.get_axis("MoveLeft", "MoveRight")
	if direction != 0: velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION * delta)
	else: velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
	handle_player_jump()
func handle_player_jump() -> void:
	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_POWER * -1
		is_jumping = true
	# Short Hop/Cancel Jump
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0
		is_jumping = false
func handle_landing() -> void:
	if is_on_floor() and is_jumping:
		is_jumping = false
