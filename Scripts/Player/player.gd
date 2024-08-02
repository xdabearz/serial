extends CharacterBody2D

#TODO BEFORE MOVING ON
# Double jump feels bad currently
# THe bounce when you spam jump on land. Need a minimum jump height and a delay on landing
# A stationary turret that fires at the player and can be destroyed
# Melee combo attack while on the ground

#BUGS
#Cant collid with spikes :(

var input
@export var speed = 100.0
@export var gravity = 5

#VARIABLE FOR JUMPING
var jump_count = 0
var jump_timer = 0.0
var acceleration = 10 #used to smooth out wall kicks
@export var is_jumping = false
var jump_time_limit = 0.2
@export var max_jump = 2
@export var jump_force = 200

#Dodging
@export var dodge_force = 100
@export var dodge_cooldown = 0.5

#Wall Jumping
@onready var wall = $wall_ray
@export var wallslide_speed = 0.3

# STATE MANAGEMENT
var current_state = player_states.MOVE
enum player_states {MOVE, ATTACK, DEAD, DODGE}

# Called when the node enters the scene tree for the first time.
func _ready():
	$attack/attack_collider.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player_data.health <= 0:
		current_state = player_states.DEAD
	
	match current_state:
		player_states.MOVE:
			movement(delta)
		player_states.ATTACK:
			attack(delta)
		player_states.DODGE:   
			dodging()
		player_states.DEAD:
			dead()
	
func movement(delta):
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input != 0:
		if input > 0:
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed)
			$PlayerSprite.scale.x = 1
			wall.scale.x = 1
			$attack.position.x = 14
			$anim.play("Walk")
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$PlayerSprite.scale.x = -1
			wall.scale.x = -1
			$attack.position.x = -14
			$anim.play("Walk")
			
	if input == 0:
		velocity.x = 0
		$anim.play("Idle")
		
		
	if !is_on_floor():
		if velocity.y < 0:
			$anim.play("Jump")
		if velocity.y > 0:
			$anim.play("Fall")
	#Jumping Code
	if is_on_floor():
		jump_count = 0
	

	if Input.is_action_just_pressed("ui_accept") && is_on_floor() && jump_count < max_jump:
		jump_timer += delta
		is_jumping = true

		jump_count += 1
		velocity.y -= jump_force
		velocity.x = input
	
	if is_jumping:
		jump_timer += delta
		if Input.is_action_just_released("ui_accept"):
			# If the button is released early, stop accelerating upwards after the minimum jump height
			if jump_timer >= jump_time_limit:
				is_jumping = false
		elif jump_timer >= jump_time_limit:
		# Force stop jumping after a certain time to ensure minimum height
			is_jumping = false
	
	if is_jumping && Input.is_action_just_pressed("ui_accept") && jump_count < max_jump:
		jump_count += 1
		velocity.y -= jump_force
		velocity.x = input
	if is_jumping && Input.is_action_just_released("ui_accept") && jump_count < max_jump:
		velocity.y = jump_force
		velocity.x = input
	else:
		gravity_force()
		
	#TODO: Wall slide FUCKING SUCKS
	if wall_collider() && Input.is_action_just_pressed("ui_accept") && !is_on_floor():
		#TOKNOW: Wall sliding animations would go here
		if velocity.x > 0:
			#velocity = Vector2(-200, -150)
			velocity.x = lerp(-1000, 0, acceleration * delta)
			velocity.y = -200
		elif velocity.x < 0:
			#velocity = Vector2(200, -150)
			velocity.x = lerp(1000, 0, acceleration * delta)
			velocity.y = -200
		
	if Input.is_action_just_pressed("ui_attack"):
		current_state = player_states.ATTACK
		
	if Input.is_action_just_pressed("ui_dodge"):
		current_state = player_states.DODGE
		
	gravity_force()
	move_and_slide()

#TODO clamp fall so its the same
func gravity_force():
	if !wall_collider():
		velocity.y += gravity
	elif wall_collider():
		velocity.y += wallslide_speed
	
func attack(delta):
	$anim.play("Attack")
	input_movement(delta)
	
#TODISCUSS - DO we want iframes on the dodge? I assume no
#Everything about this is awful
func dodging():
	if velocity.x > 0:
		velocity.x += dodge_force
		await get_tree().create_timer(dodge_cooldown).timeout
	elif velocity.x < 0:
		velocity.x -= dodge_force
		await get_tree().create_timer(dodge_cooldown).timeout
	else:
		if $PlayerSprite.scale.x == 1:
			velocity.x += dodge_force
			await get_tree().create_timer(dodge_cooldown).timeout
			current_state = player_states.MOVE
		if $PlayerSprite.scale.x == -1:
			velocity.x -= dodge_force
			await get_tree().create_timer(dodge_cooldown).timeout
			current_state = player_states.MOVE
		
	move_and_slide()
	
func dead():
	$anim.play("Dead")
	velocity.x = 0
	gravity_force()
	move_and_slide()
	
	await $anim.animation_finished
	player_data.health = 4
	player_data.currency = 0 #TODO Just for Demo, wipes currency on death
	if get_tree():
		get_tree().reload_current_scene()
	
#TONOTE: Specifically movement for attacking/using an action. Might be better named
func input_movement(delta):
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input != 0:
		if input > 0:
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed)
			$PlayerSprite.scale.x = 1
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$PlayerSprite.scale.x = -1
		if input == 0:
			velocity.x = 0
		
	gravity_force()
	move_and_slide()

func wall_collider():
	return wall.is_colliding()

func reset_states():
	current_state = player_states.MOVE
