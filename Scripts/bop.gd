extends	CharacterBody2D

#	---	Exported	Properties	---
@export	var	SPEED	:	int	=	300
@export	var	ACCELERATION	:	float	=	20.0
@export	var	FRICTION	:	float	=	25.0
@export	var	JUMP_POWER	:	int	=	800
@export	var	FAST_FALL_SPEED	:	int	=	1500
var	GRAVITY	:	int	=	ProjectSettings.get_setting("physics/2d/default_gravity")
	
#	---	States	&	Health	---
var	is_dead	:	bool
var	is_invincible	:	bool
var	is_jumping	:	bool
var	is_falling	:	bool
@export	var	is_attacking	:	bool
var	looking_left	:	bool	=	true	#	Start	looking	left
var	looking_right	:	bool	=	false
var	on_attack_cooldown	:	bool	=	false

var	health	:	int
var	max_health	:	int	

#	---	Pathfinding	Constants	---
#	The	distance	to	the	next	path	point	at	which	the	agent	considers	it	"reached"
const	PATH_POINT_RADIUS	=	30.0	
#	How	high	the	next	path	point	must	be	to	trigger	a	jump	attempt
const	JUMP_THRESHOLD	=	50.0	
#	Reference	to	the	target	node	(Player)
var	target_node:	CharacterBody2D	

#	---	Node	References	---
@onready	var	WORLD	=	get_parent()
@onready	var	ANIMATION_PLAYER	=	$AnimationPlayer
@onready	var	ANIMATION_TREE:	AnimationTree	=	$AnimationTree
@onready	var	RIG						=	$Rig
@onready	var	ATTACKCDTIMER	=	$AttackCooldownTimer
#	NEW:	Navigation	Agent	reference	(MUST	be	a	child	node)
@onready	var	NAV_AGENT:	NavigationAgent2D	=	$NavigationAgent2D	
const	BUBBLES_SCENE	=	preload("res://Scenes/bubble.tscn")

enum	EnemyStates	{
		SEARCHING,
		HUNTING,
		EVADING,
		STALKING
}

var	current_state	:	EnemyStates	=	EnemyStates.SEARCHING
var	current_search_place	:	Vector2	=	Vector2.ZERO	#	Changed	to	Vector2	for	global	position

func	_ready()	->	void:
		#	Attempt	to	find	the	player	in	the	world.
		target_node	=	WORLD.get_node_or_null("Player")	
		
		#	If	the	player	is	found	early,	start	hunting.
		if	target_node:
				current_state	=	EnemyStates.HUNTING
				
		#	Start	the	enemy	at	a	known	search	place	(its	current	location)
		current_search_place	=	global_position

func	_physics_process(delta:	float)	->	void:
		handle_gravity(delta)
		handle_landing()
		
		match	current_state:
				EnemyStates.SEARCHING:
					search_for_player(delta)
				EnemyStates.HUNTING:
					hunt_target(delta)	#	Call	the	new	hunting	function
				EnemyStates.EVADING:
					velocity.x	=	lerp(velocity.x,	0.0,	FRICTION	*	delta)
				EnemyStates.STALKING:
					velocity.x	=	lerp(velocity.x,	0.0,	FRICTION	*	delta)
					
		handle_enemy_animation()	#	Corrected	function	name	call
		move_and_slide()

#	---	Core	Movement	Functions	---

func	search_for_player(delta)	->	void:
		#	1.	Choose	a	new	random	place	if	the	current	one	is	reached
		if	global_position.distance_to(current_search_place)	<	PATH_POINT_RADIUS	*	2	or	not	is_on_floor():
				#	Get	a	new	random	search	place	within	the	world	bounds	(adjust	4000/2000	as	needed)
				current_search_place	=	Vector2(randi_range(0,4000),	randi_range(0,2000))

		#	2.	Set	the	current	search	place	as	the	path	goal
		NAV_AGENT.target_position	=	current_search_place
		
		#	3.	Use	the	navigation	logic	to	move	toward	the	search	place
		move_along_path(delta)

func	hunt_target(delta)	->	void:
		if	not	target_node	or	not	is_instance_valid(target_node):
				current_state	=	EnemyStates.SEARCHING
				return

		#	1.	Update	Path	Goal	to	the	player's	position
		NAV_AGENT.target_position	=	target_node.global_position
		
		#	2.	Use	the	navigation	logic	to	move	toward	the	player
		move_along_path(delta)

#	---	Pathfinding	Movement	Helper	---

func	move_along_path(delta):
		#	Get	the	next	point	on	the	calculated	path
		var	next_point	=	NAV_AGENT.get_next_path_position()
		
		#	Calculate	the	vector	from	the	enemy	to	the	next	path	point
		var	direction_to_point	=	(next_point	-	global_position)
		
		var	desired_velocity_x	=	0.0
		
		#	1.	Horizontal	Movement
		if	direction_to_point.x	>	PATH_POINT_RADIUS:
				desired_velocity_x	=	SPEED
				looking_right	=	true
				looking_left	=	false
		elif	direction_to_point.x	<	-PATH_POINT_RADIUS:
				desired_velocity_x	=	-SPEED
				looking_left	=	true
				looking_right	=	false
		
		#	Apply	acceleration/friction	for	smooth	horizontal	movement
		if	desired_velocity_x	!=	0:
				velocity.x	=	lerp(velocity.x,	desired_velocity_x,	ACCELERATION	*	delta)
		else:
				velocity.x	=	lerp(velocity.x,	0.0,	FRICTION	*	delta)
				
		#	2.	Platformer	Jump	Logic	(To	reach	higher	points	on	the	path)
		#	Check	if	the	next	path	point	is	significantly	above	the	enemy	AND	the	enemy	is	on	the	floor
		if	is_on_floor()	and	direction_to_point.y	<	-JUMP_THRESHOLD:
				#	Check	if	the	next	point	is	horizontally	close	enough	to	make	a	jump	attempt
				if	abs(direction_to_point.x)	<	200:	#	Max	horizontal	distance	to	attempt	a	jump
						velocity.y	=	-JUMP_POWER
						is_jumping	=	true
						is_falling	=	false	#	Reset	falling	state	on	jump

#	---	Other	Functions	---

func	_on_area_2d_body_entered(body:	Node2D)	->	void:
		if	body.is_in_group("player"):
				current_state	=	EnemyStates.HUNTING
				#	Check	if	target	node	is	already	set	or	set	it	here
				if	not	target_node:
						target_node	=	body
				print("found	u")

func	handle_gravity(delta:	float)	->	void:
		if	not	is_on_floor():	velocity.y	+=	GRAVITY	*	delta
		else:	velocity.y	=	0

func	handle_landing()	->	void:
		if	is_on_floor()	and	is_falling:
				is_jumping	=	false
				is_falling	=	false
				if	not	ANIMATION_PLAYER.current_animation	==	"attacking":	ANIMATION_PLAYER.play("landing")

func	handle_enemy_animation()	->	void:	#	Renamed	function
		RIG.scale.x	=	.25	if	looking_left	else	-.25
		if	not	is_jumping	and	not	is_falling	and	not	ANIMATION_PLAYER.current_animation	==	"attacking":
				if	abs(velocity.x)	>	1	and	is_on_floor():ANIMATION_PLAYER.play("walking")
				else:ANIMATION_PLAYER.play("idle")
