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
@export var max_jump = 2
@export var jump_force = 300

# STATE MANAGEMENT
var current_state = player_states.MOVE
enum player_states {MOVE, ATTACK, DEAD}

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
		player_states.DEAD:
			dead()
	
func movement(delta):
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input != 0:
		if input > 0:
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed)
			$PlayerSprite.scale.x = 1
			$attack.position.x = 14
			$anim.play("Walk")
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$PlayerSprite.scale.x = -1
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
	
	#TODO: There needs to be a very tiny delay after landing on the floor before jump activates again
	if Input.is_action_pressed("ui_accept") && is_on_floor() && jump_count < max_jump:
		jump_count += 1
		velocity.y -= jump_force
		velocity.x = input
		
	if !is_on_floor() && Input.is_action_just_pressed("ui_accept") && jump_count < max_jump:
		jump_count += 1
		velocity.y -= jump_force
		velocity.x = input
	if !is_on_floor() && Input.is_action_just_released("ui_accept") && jump_count < max_jump:
		velocity.y = gravity
		velocity.x = input
	else:
		gravity_force()
		
	if Input.is_action_just_pressed("ui_attack"):
		current_state = player_states.ATTACK
		
	gravity_force()
	move_and_slide()

#TODO clamp fall so its the same
func gravity_force():
	velocity.y += gravity
	
func attack(delta):
	$anim.play("Attack")
	input_movement(delta)
	
func dead():
	$anim.play("Dead")
	velocity.x = 0
	gravity_force()
	move_and_slide()
	
	await $anim.animation_finished
	player_data.health = 4
	player_data.currency = 0 #TODO Just for Demo
	if get_tree():
		get_tree().reload_current_scene()
	
	
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

func reset_states():
	current_state = player_states.MOVE
